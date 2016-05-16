require 'json'
require 'http'

module Spacebunny
  module LiveStream

    # Proxy to Base.new
    def self.new(*args)
      Amqp.new *args
    end

    class Base
      attr_accessor :api_endpoint, :auto_recover, :client, :secret, :host, :vhost, :live_streams
      attr_reader :log_to, :log_level, :logger, :custom_connection_configs, :auto_connection_configs,
                  :connection_configs, :auto_configs

      def initialize(protocol, *args)
        @protocol = protocol
        @custom_connection_configs = {}
        @auto_connection_configs = {}
        options = args.extract_options.deep_symbolize_keys

        @client = options[:client] || raise(ClientRequired)
        @secret = options[:secret] || raise(SecretRequired)
        @api_endpoint = options[:api_endpoint] || {}

        extract_custom_connection_configs_from options
        set_live_streams options[:live_streams]

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
          @auto_configs = EndpointConnection.new(@api_endpoint.merge(client: @client, secret: @secret)).configs
          check_and_add_live_streams @auto_configs[:live_streams]
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
      def on_receive(options = {})
        logger.warn "on_receive method must be implemented on class responsibile to handle protocol '#{@protocol}'"
      end

      def auto_configure?
        @client && @secret
      end

      def auto_recover
        connection_configs[:auto_recover]
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

      private

      # @private
      # Check if live_streams are an array
      def set_live_streams(live_streams)
        if live_streams && !live_streams.is_a?(Array)
          raise StreamsMustBeAnArray
        end
        check_and_add_live_streams(live_streams)
      end

      # @private
      # Check for required params presence
      def check_connection_configs
        # Do nothing ATM
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
          @custom_connection_configs[:port] = options[:connection][:device][@protocol][:port]
          @custom_connection_configs[:vhost] = options[:connection][:vhost]
          @custom_connection_configs[:client] = options[:connection][:client]
          @custom_connection_configs[:secret] = options[:connection][:secret]
        end
      end

      # @private
      def check_and_add_live_streams(chs)
        @live_streams = [] unless @live_streams
        return unless chs
        chs.each do |ch|
          case ch
            when Hash
              ch.symbolize_keys!
              # Check for required attributes
              [:id, :name].each do |attr|
                unless ch[attr]
                  raise LiveStreamParamError(ch[:name], attr)
                end
              end
              @live_streams << ch
            else
              raise LiveStreamFormatError
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
            client: @auto_configs[:connection][:client],
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
