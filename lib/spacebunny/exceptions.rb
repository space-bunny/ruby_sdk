module Spacebunny
  class DeviceKeyOrClientAndSecretRequired < Exception
    def initialize(message = nil)
      message = message || "A valid 'Api Key' or valid 'Client' and 'Secret' are required for auto-configuration"
      super(message)
    end
  end

  class DeviceKeyOrConfigurationsRequired < Exception
    def initialize(message = nil)
      message = message || 'Neither key or connection options provided!'
      super(message)
    end
  end

  class AckTypeError < Exception
    def initialize(message = nil)
      message = message || "Ack type not valid. Use one of #{Spacebunny::AmqpClient::ACK_TYPES.map{ |t| ":#{t}" }.join(', ')}"
      super(message)
    end
  end

  class BlockRequired < Exception
    def initialize(message = nil)
      message = message || 'block missing. Please provide a block'
      super(message)
    end
  end

  class ChannelsMustBeAnArray < Exception
    def initialize
      message = "channels option must be an Array. E.g. [:data, :alarms]"
      super(message)
    end
  end

  class ChannelNotExists < Exception
    def initialize(channel = nil)
      message = if channel
                  "Channel '#{channel}' does not exists. Is this channel enabled for the device or did you specified it on client initialization?"
                else
                  'Channel does not exists'
                end
      super(message)
    end
  end

  class ClientRequired < Exception
    def initialize(message = nil)
      message = message || "Missing mandatory 'client'. Spacebunny::LiveStream.new(:client => 'a_valid_client', :secret: 'a_valid_secret')"
      super(message)
    end
  end

  class LiveStreamFormatError < Exception
    def initialize
      message = "Live Stream not correctly formatted. It must be an Hash with at least 'name' and 'id' attributes"
      super(message)
    end
  end

  class LiveStreamNotFound < Exception
    def initialize(name = nil)
      message = if name
                  "Live Stream '#{name}' not found. Did you created and configured it?"
                else
                  'Live Stream not found'
                end
      super(message)
    end
  end

  class LiveStreamParamError < Exception
    def initialize(live_stream_name, param_name)
      live_stream_name = live_stream_name || 'no-name-provided'
      "Live Stream '#{live_stream_name}' misses mandatory '#{param_name}' param"
      super(message)
    end
  end

  class SecretRequired < Exception
    def initialize(message = nil)
      message = message || "Missing mandatory 'secret' Spacebunny::LiveStream.new(:client => 'a_valid_client', :secret: 'a_valid_secret')"
      super(message)
    end
  end

  class ClientNotConnected < Exception
    def initialize(message = nil)
      message = message || 'Client not connected!'
      super(message)
    end
  end

  class DeviceIdMissing < Exception
    def initialize(message = nil)
      message = message || "missing mandatory 'device_id' parameter. Please provide it on client initialization (see doc) or use auto-configuration"
      super(message)
    end
  end

  class EndpointError < Exception
    def initialize(message = nil)
      message = message || 'Error while contacting endpoint for auto-configuration'
      super(message)
    end
  end

  class EndPointNotReachable < Exception
    def initialize(message = nil)
      message = message || 'Endpoint not reachable'
      super(message)
    end
  end

  class ProtocolNotRegistered < Exception
    def initialize(protocol)
      message = "protocol #{protocol} is not registered"
      super(message)
    end
  end

  class SchemeNotValid < Exception
    def initialize(scheme)
      message = "Provided scheme #{scheme} is not valid"
      super(message)
    end
  end

  class StreamsMustBeAnArray < Exception
    def initialize
      message = "streams option must be an Array"
      super(message)
    end
  end
end
