require 'uri/http'
require 'uri/https'

# Handle retrieve of Device and LiveStream configs from APIs endpoint

module Spacebunny
  class EndpointConnection
    DEFAULT_OPTIONS = {
        scheme: 'http',
        host: 'api.demo.spacebunny.io', #'https://api.spacebunny.io',
        port: 80,
        api_version: '/v1',
        configs_path: {
            device: '/device_configurations',
            live_stream: '/access_key_configurations'
        }
    }.freeze

    attr_accessor :scheme, :host, :port, :api_version, :configs_path

    def initialize(options = {})
      unless options.is_a? Hash
        fail ArgumentError, 'connection options must be an Hash'
      end
      options = merge_with_default options
      @key = options[:key]
      @client = options[:client]
      @secret = options[:secret]

      ensure_credentials_have_been_provided
      # API endpoint params
      @scheme = options[:scheme]
      @host = options[:host]
      @port = options[:port]
      @api_version = options[:api_version]
      @configs_path = options[:configs_path]
    end

    def configs
      unless @configs
        @configs = fetch
      end
      @configs
    end

    def configs_path
      if @configs_path.is_a? Hash
        if device?
          @configs_path[:device]
        else
          @configs_path[:live_stream]
        end
      else
        @configs_path
      end
    end

    # Contact APIs endpoint to retrieve configs
    def fetch
      uri = nil
      case scheme
        when 'http'
          uri = URI::HTTP.build host: host, port: port, path: "#{api_version}#{configs_path}"
        when 'https'
          uri = URI::HTTPS.build host: host, port: port, path: "#{api_version}#{configs_path}"
      end

      unless uri
        raise SchemeNotValid.new(scheme)
      end

      response = contact_endpoint_with uri
      content = JSON.parse(response, symbolize_names: true) rescue nil
      status = response.status
      if status != 200
        if content
          phrase = "Auto-configuration failed:  #{response.status} => #{content[:error]}"
          if status == 401
            if device?
              phrase = "#{phrase}. Is Device Key correct?"
            else
              phrase = "#{phrase} Are Client and Secret correct?"
            end
          end
        else
          phrase = "#{response.status}"
        end
        raise EndpointError, phrase
      end
      content
    end

    private

    def ensure_credentials_have_been_provided
      if !@key && !(@client && @secret)
        raise DeviceKeyOrClientAndSecretRequired
      end
    end

    def device?
      !@key.nil?
    end

    def contact_endpoint_with(uri)
      if device?
        request = HTTP.headers('Device-Key' => @key)
      else
        request = HTTP.headers('Live-Stream-Key-Client' => @client, 'Live-Stream-Key-Secret' => @secret)
      end
      request = request.headers(content_type: 'application/json', accept: 'application/json')
      begin
        request.get(uri.to_s)
      rescue => e
        logger.error e.message
        logger.error e.backtrace.join "\n"
        raise EndPointNotReachable
      end
    end

    def logger
      Spacebunny.logger
    end

    def merge_with_default(options)
      DEFAULT_OPTIONS.merge(options) { |key, old_val, new_val| new_val.nil? ? old_val : new_val }
    end
  end
end
