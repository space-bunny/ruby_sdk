require 'bunny'

module Spacebunny
  module LiveStream
    class Amqp < Base
      DEFAULT_QUEUE_OPTIONS = { passive: true }
      DEFAULT_EXCHANGE_OPTIONS = { passive: true }
      ACK_TYPES = [:manual, :auto]

      attr_reader :built_live_streams, :client

      def initialize(*args)
        super(:amqp, *args)
        @built_live_streams = {}
      end

      def connect
        # 'Fix' attributes: start from common connection configs and adjust attributes to match what Bunny
        # wants as connection args
        connection_params = connection_configs.dup
        connection_params[:user] = connection_params.delete :client
        connection_params[:password] = connection_params.delete :secret
        connection_params[:recover_from_connection_close] = connection_params.delete :auto_recover

        # Re-create client every time connect is called
        @client = Bunny.new(connection_params)
        @client.start
      end

      def channel_from_name(name)
        # In @built_channels ci sono in realtà gli exchange!
        with_channel_check name do
          @built_exchanges[name]
        end
      end

      def disconnect
        super
        client.stop
      end

      # Subscribe for messages coming from Live Stream with name 'name'
      # Each subscriber will receive a copy of messages flowing through the Live Stream
      def message_from(name, options = {}, &block)
        receive_message_from name, options, &block
      end

      # Subscribe for messages coming from cache of Live Stream with name 'name'
      # The Live Stream will dispatch a message to the first ready subscriber in a round-robin fashion.
      def message_from_cache(name, options = {}, &block)
        options[:from_cache] = true
        receive_message_from name, options, &block
      end

      private

      def check_client
        raise ClientNotConnected, 'Client not connected. Did you call client.connect?' unless client_connected?
      end

      def client_connected?
        client && client.status.eql?(:open)
      end

      def live_stream_data_from_name(name)
        # Find the live_stream from provided name
        unless live_stream_data = live_streams.find { |ls| ls[:name] == name }
          raise LiveStreamNotFound.new(name)
        end
        live_stream_data
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

      def receive_message_from(name, options)
        unless block_given?
          raise BlockRequired
        end
        name = name.to_s
        blocking = options.fetch :wait, false
        to_ack, auto_ack = parse_ack options.fetch(:ack, :manual)
        from_cache = options.fetch :from_cache, false

        check_client
        ls_channel = client.create_channel
        live_stream_name = "#{live_stream_data_from_name(name)[:id]}.live_stream"
        if from_cache
          live_stream = ls_channel.queue live_stream_name, DEFAULT_QUEUE_OPTIONS
        else
          ls_exchange = ls_channel.fanout live_stream_name, DEFAULT_EXCHANGE_OPTIONS
          live_stream = ls_channel.queue("#{client}_#{Time.now.to_f}.live_stream.temp", auto_delete: true)
                            .bind ls_exchange, routing_key: '#'
        end

        live_stream.subscribe(block: blocking, manual_ack: to_ack) do |delivery_info, metadata, payload|
          message = LiveStream::Message.new ls_channel, options, delivery_info, metadata, payload

          yield message

          # If ack is :auto then ack current message
          if to_ack && auto_ack
            message.ack
          end
        end
      end
    end
  end
end
