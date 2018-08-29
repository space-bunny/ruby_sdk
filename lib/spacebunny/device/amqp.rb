require 'bunny'

module Spacebunny
  module Device
    class Amqp < Base
      DEFAULT_CHANNEL_OPTIONS = { passive: true }
      ACK_TYPES = [:manual, :auto]

      attr_reader :built_channels, :built_exchanges, :client

      def initialize(*args)
        super(:amqp, *args)
        @built_channels = {}
        @built_exchanges = {}
      end

      def connect
        # 'Fix' attributes: start from common connection configs and adjust attributes to match what Bunny
        # wants as connection args
        connection_params = connection_configs.dup
        connection_params[:user] = connection_params.delete :device_id
        connection_params[:password] = connection_params.delete :secret
        # Default on a tls connection
        unless connection_params[:tls] == false
          connection_params[:port] = connection_params.delete(:tls_port)
        end
        connection_params[:log_level] = connection_params.delete(:log_level) || ::Logger::ERROR

        # Re-create client every time connect is called
        @client = Bunny.new(connection_params)
        @client.start
        logger.info 'Connected to SpaceBunny'
      end

      def disconnect
        super
        @built_exchanges = {}
        @built_channels = {}
        client.stop if client
        logger.info 'Disconnected from SpaceBunny'
      end

      def input_channel
        return @input_channel if @input_channel
        @input_channel = client.create_channel
      end

      def on_receive(options = {})
        unless block_given?
          raise BlockRequired
        end
        blocking = options.fetch :wait, false
        to_ack, auto_ack = parse_ack options.fetch(:ack, :manual)

        input_queue.subscribe(block: blocking, manual_ack: to_ack) do |delivery_info, metadata, payload|
          message = Device::Message.new self, options, delivery_info, metadata, payload

          # Skip message if required
          if message.blacklisted?
            message.nack
            next
          end

          yield message

          # If ack is :auto then ack current message
          if to_ack && auto_ack
            message.ack
          end
        end
      end
      alias_method :inbox, :on_receive

      def publish(channel_name, message, options = {})
        if check_client
          channel_key = if options[:with_confirm]
                          "#{channel_name}_confirm"
                        else
                          channel_name
                        end.to_sym

          unless @built_exchanges[channel_key]
            @built_exchanges[channel_key] = create_channel(channel_name, options)
          end
          # Call Bunny "publish"
          res = @built_exchanges[channel_key].publish message, channel_options(channel_name, options)
          @logger.debug 'Message published'
          res
        else
          @logger.debug 'Message NOT published due to client not connected'
          false
        end
      end

      def wait_for_publish_confirms
        results = {}
        threads = []
        @built_channels.each do |name, channel|
          if channel.using_publisher_confirmations?
            threads << Thread.new do
              results[name] = { all_confirmed: channel.wait_for_confirms, nacked_set: channel.nacked_set }
            end
          end
        end
        threads.map{ |t| t.join }
        results
      end

      private

      # Merge default channel options with provided ones
      def channel_options(channel, options)
        options.merge({routing_key: "#{id}.#{channel}" })
      end

      # Check if client has been prepared.
      def check_client
        unless client
          raise ClientNotSetup
        end
        unless client.connected?
          if raise_on_error
            raise ClientNotConnected
          else
            @logger.error 'Client not connected! Check internet connection'
            return false
          end
        end
        true
      end

      def create_channel(name, options = {})
        with_channel_check name do
          channel = client.create_channel
          if options.delete(:with_confirm)
            channel.confirm_select
          end
          @built_channels[name] = channel
          channel.direct(id, DEFAULT_CHANNEL_OPTIONS)
        end
      end

      def input_queue
        return @input_queue if @input_queue
        @input_queue = input_channel.queue "#{id}.inbox", passive: true
      end

      def parse_ack(ack)
        to_ack = false
        auto_ack = false
        if ack
          raise AckTypeError unless ACK_TYPES.include?(ack)
          to_ack = true
          case ack
            when :manual
              auto_ack = false
            when :auto
              auto_ack = true
          end
        end
        return to_ack, auto_ack
      end
    end
  end
end
