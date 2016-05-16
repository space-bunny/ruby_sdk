# require 'active_support/core_ext/hash/keys'

module Spacebunny
  class << self
    attr_accessor :logger
  end
end

require 'spacebunny/version'
require 'spacebunny/utils'
require 'spacebunny/logger'
require 'spacebunny/exceptions'
require 'spacebunny/endpoint_connection'
require 'spacebunny/device/base'
require 'spacebunny/device/message'
require 'spacebunny/device/amqp'
require 'spacebunny/live_stream/base'
require 'spacebunny/live_stream/message'
require 'spacebunny/live_stream/amqp'

def path_to_resources(path)
  File.join(File.dirname(File.expand_path(__FILE__)), path)
end
