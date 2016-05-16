require 'json'
require 'http'

module Spacebunny
  module Device

    # Proxy to Base.new
    def self.new(*args)
      Amqp.new *args
    end

    class Base
      attr_accessor :key, :api_endpoint, :auto_recover, :id, :name, :host, :secret, :vhost, :channels
      attr_reader :log_to, :log_level, :logger, :custom_connection_configs, :auto_connection_configs,
                  :connection_configs, :auto_configs, :tls, :tls_cert, :tls_key, :tls_ca_certificates, :verify_peer

      def initialize(protocol, *args)
        @protocol = protocol
        @custom_connection_configs = {}
        @auto_connection_configs = {}
        options = args.extract_options.deep_symbolize_keys
        key = args.first

        @key = key || options[:key]
        @api_endpoint = options[:api_endpoint] || {}

        extract_custom_connection_configs_from options
        set_channels options[:channels]

        @log_to = options[:log_to] || STDOUT
        @log_level = options[:log_level] || ::Logger::WARN
        @logger = options[:logger] || build_logger
      end

      def api_endpoint=(options)
        unless options.is_a? Hash
          raise ArgumentError, 'api_endpoint must be an Hash. See doc for further info'
        end
        @api_endpoint = options.deep_symbolize_keys
      end

      def connection_configs
        return @connection_configs if @connection_configs
        if auto_configure?
         # If key is specified, retrieve configs from APIs endpoint
          @auto_configs = EndpointConnection.new(@api_endpoint.merge(key: @key)).configs
          normalize_and_add_channels @auto_configs[:channels]
          @auto_connection_configs = normalize_auto_connection_configs
        end
        # Build final connection_configs
        @connection_configs = merge_connection_configs
        # Check for required params presence
        check_connection_configs
        @connection_configs
      end

      def connect
      end

      def connection_options=(options)
        unless options.is_a? Hash
          raise ArgumentError, 'connection_options must be an Hash. See doc for further info'
        end
        extract_custom_connection_configs_from options.with_indifferent_access
      end

      def disconnect
        @connection_configs = nil
      end

      # Stub method: must be implemented on the class responsible to handle the protocol
      def publish(channel, message, options = {})
        logger.warn "publish method must be implemented on class responsibile to handle protocol '#{@protocol}'"
      end

      # Stub method: must be implemented on the class responsible to handle the protocol
      def on_receive(options = {}, &block)
        logger.warn "on_receive method must be implemented on class responsibile to handle protocol '#{@protocol}'"
      end

      def auto_recover
        connection_configs[:auto_recover]
      end

      def id
        connection_configs[:device_id]
      end

      def name
        connection_configs[:device_name]
      end

      def host
        connection_configs[:host]
      end

      def secret
        connection_configs[:secret]
      end

      def vhost
        connection_configs[:vhost]
      end

      protected

      # @protected
      def auto_configure?
        !@key.nil?
      end

      def with_channel_check(name)
        unless res = channels.include?(name)
          logger.warn <<-MSG

            You're going to publish on channel '#{name}', but it does not appear a configured channel.
            If using auto-configuration (device-key) associate the channel to device '#{@auto_configs[:connection][:name]}'
            from web interface.
            If providing manual configuration, please specify channels list through the :channels option
            or through given setter, e.g. client.channels = [:first_channel, :second_channel, ... ])

          MSG
        end
        if block_given?
          yield
        else
          res
        end
      end

      private

      # @private
      # Check if channels are an array
      def set_channels(channels)
        if channels && !channels.is_a?(Array)
          raise ChannelsMustBeAnArray
        end
        normalize_and_add_channels(channels)
      end

      # @private
      # Check for required params presence
      def check_connection_configs
        raise DeviceIdMissing unless @connection_configs[:device_id]
      end

      # @private
      # Merge auto_connection_configs and custom_connection_configs
      def merge_connection_configs
        auto_connection_configs.merge(custom_connection_configs) do |key, old_val, new_val|
          if new_val.nil?
            old_val
          else
            new_val
          end
        end
      end

      # @private
      def build_logger
        logger          = ::Logger.new(@log_to)
        logger.level    = normalize_log_level
        logger.progname = 'Spacebunny'
        Spacebunny.logger = logger
      end

      # @private
      def extract_custom_connection_configs_from(options)
        # Auto_recover from connection.close by default
        if options[:connection]
          @custom_connection_configs[:auto_recover] = options[:connection][:auto_recover] || true
          @custom_connection_configs[:host] = options[:connection][:host]
          @custom_connection_configs[:port] = options[:connection][:protocols][@protocol][:port]
          @custom_connection_configs[:vhost] = options[:connection][:vhost]
          @custom_connection_configs[:device_id] = options[:connection][:device_id]
          @custom_connection_configs[:device_name] = options[:connection][:device_name],
          @custom_connection_configs[:secret] = options[:connection][:secret]
        end
      end

      # @private
      def merge_device_connection(configs)
        configs.merge custom_connection_configs
      end

      # @private
      def normalize_and_add_channels(chs)
        @channels = [] unless @channels
        return unless chs
        chs.each do |ch|
          case ch
            when Hash
              @channels << ch[:name].to_sym
            else
              ch.to_sym
          end
        end
      end

      # @private
      # Translate from auto configs given by APIs endpoint to a common format
      def normalize_auto_connection_configs
        {
            host: @auto_configs[:connection][:host],
            port: @auto_configs[:connection][:protocols][@protocol][:port],
            vhost: @auto_configs[:connection][:vhost],
            device_id: @auto_configs[:connection][:device_id],
            device_name: @auto_configs[:connection][:device_name],
            secret: @auto_configs[:connection][:secret]
        }
      end

      # @private
      def normalize_log_level
        case @log_level
          when :debug, ::Logger::DEBUG, 'debug' then ::Logger::DEBUG
          when :info,  ::Logger::INFO,  'info'  then ::Logger::INFO
          when :warn,  ::Logger::WARN,  'warn'  then ::Logger::WARN
          when :error, ::Logger::ERROR, 'error' then ::Logger::ERROR
          when :fatal, ::Logger::FATAL, 'fatal' then ::Logger::FATAL
          else
            Logger::WARN
        end
      end
    end
  end
end
