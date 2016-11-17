require 'spec_helper'

describe Spacebunny::Device::Base do
  let(:protocol) { :amqp }
  let(:device_key) { 'nice_api_key' }

  context 'attr_accessors' do
    subject(:base_class) { Spacebunny::Device::Base.new(protocol, device_key) }

    it { should have_attr_accessor :key }
    it { should have_attr_accessor :api_endpoint }
    it { should have_attr_accessor :id }
    it { should have_attr_accessor :name }
    it { should have_attr_accessor :host }
    it { should have_attr_accessor :secret }
    it { should have_attr_accessor :vhost }
    it { should have_attr_accessor :channels }
    it { should have_attr_reader :log_to }
    it { should have_attr_reader :log_level }
    it { should have_attr_reader :logger }
    it { should have_attr_reader :custom_connection_configs }
    it { should have_attr_reader :auto_connection_configs }
    it { should have_attr_reader :connection_configs }
    it { should have_attr_reader :auto_configs }
  end
end
