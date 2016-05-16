require 'spacebunny'
require 'json'

# Prerequisites: you have created a device through the Space Bunny's web interface. You also have a 'data' channel (name
# is not mandatory, but we'll use this for our example). You have also enabled 'data' channel for the device. See our
# Getting Started [link] for a quick introduction to Space Bunny's base concepts.

# If for some reason or use case it's not possible or desirable to use auto-configuration, Space Bunny's Ruby SDK
# permits to manually configure the connection with various methods.

# First of all go to Space Bunny's web interface, go to the devices section and create or pick an existing device.
# Click on the 'SHOW CONFIGURATION' link and, from the 'Full configuration' section, copy the configuration from the
# "Ruby" section and customize it to your needs.

# Replace with device's Ruby configs hash copied from web inteface
configs = {
    :connection => {
        :host        => "api.demo.spacebunny.io",
        :protocols   => {
            :amqp      => {
                :port => 5672
            },
            :mqtt      => {
                :port => 1883
            },
            :stomp     => {
                :port => 61613
            },
            :web_stomp => {
                :port => 15674
            }
        },
        :device_name => "device_1",
        :device_id   => "your_dev_id",
        :secret      => "your_dev_secret",
        :vhost       => "your_vhost"
    },
    :channels   => [
        {
            :id         => "one_channel_id",
            :name       => "channel_name"
        }
    ]
}

dev = Spacebunny::Device.new configs

# An alternative method is to create an 'empty' client instance and then fill connection params
# before calling 'connect':
#
# dev = Spacebunny::Device.new
# dev.connection_options = {
#     connection: {
#         device_id: '9999aa99-9999-9aaa-aa99-aa9a999a9999',
#         secret: 'top_secret',
#         host: 'spacebunny.io',
#         protocols: {
#             amqp: { port: 5672}
#         },
#         vhost: '11111bb1-1111-1bbb-bb11-11bb11bbbbbb'
#     }
# }
#
# Set the channels at a later time
# dev.channels = [:data]

dev.connect

# At this point the client is ready to operate.
# Publish one message every second for a minute.

60.times do
  # Generate some random data
  payload = { greetings: 'Hello, World!', temp: rand(20.0..25.0), foo: rand(100..200) }.to_json

  dev.publish :data, payload

  # Give some feedback on what has been published
  puts "Published #{payload}"

  # Take a nap...
  sleep 1
end
