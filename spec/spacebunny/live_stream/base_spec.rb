require 'spec_helper'

describe Spacebunny::LiveStream::Base do
  let(:protocol) { :amqp }
  let(:client) { 'a_fake_client' }
  let(:secret) { 'a_fake_secret' }

  context 'attr_accessors' do
    subject(:live_stream_class) { Spacebunny::LiveStream::Base.new protocol, client: client, secret: secret }

    it { should have_attr_accessor :api_endpoint }
    it { should have_attr_accessor :auto_recover }
    it { should have_attr_accessor :client }
    it { should have_attr_accessor :secret }
    it { should have_attr_accessor :host }
    it { should have_attr_accessor :vhost }
    it { should have_attr_accessor :live_streams }
    it { should have_attr_reader :log_to }
    it { should have_attr_reader :log_level }
    it { should have_attr_reader :logger }
    it { should have_attr_reader :custom_connection_configs }
    it { should have_attr_reader :auto_connection_configs }
    it { should have_attr_reader :connection_configs }
    it { should have_attr_reader :auto_configs }
  end
end