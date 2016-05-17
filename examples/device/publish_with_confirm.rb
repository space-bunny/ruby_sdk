require 'spacebunny'
require 'json'

# Prerequisites: you have created a device through the SpaceBunny's web interface. You also have a 'data' channel (name
# is not mandatory, but we'll use this for our example). You have also enabled 'data' channel for the device. See our
# Getting Started [link] for a quick introduction to SpaceBunny's base concepts.

# Once everything is set up get your device's API key from SpaceBunny's web application: on the web interface,
# go to devices section and create or pick an existing device. Click on the 'SHOW CONFIGURATION' link, copy the API key
# and substitute it here:

device_key = 'your_awesome_device_key'

# Let's instantiate a SpaceBunny client, providing the device's API key, that's the fastest and simplest method
# to create a new client. If, for some reason, you need to customize the settings, take a look at
# examples/manual_config.rb for an example of connection settings customization.

dev = Spacebunny::Device.new key

# An equivalent method for providing the API key is through options: Spacebunny::Device.new(key: key)

# We need to call 'connect' in order to open the communication with SpaceBunny platform

dev.connect

# At this point the SDK is auto-configured and ready to use.
# Configurations are automatically lazy-fetched by the SDK itself when calling 'connect'.

# PUBLISHING MESSAGES WITH CONFIRM

# As said in the prerequisites, we'll assume that 'data' channel is enabled for your device.
# If you're in doubt, please check that this is true through SpaceBunny's web interface, by clicking on the device
# 'edit' (pencil icon) and verifying that 'data' channel is present and enabled for this device. Take a look at Getting
# Started [link] for a quick introduction to SpaceBunny's base concepts.

# Let's publish, for instance, some JSON. Payload can be everything you want, SpaceBunny does not impose any constraint
# on format or content of payload.

# Publish one message every second for a minute.
count = 0
5.times do
  # Generate some random data
  payload = {
      count: count,
      greetings: 'Hello, World!',
      temp: rand(20.0..25.0),
      foo: rand(100..200)
  }.to_json

  # Hint: the channel name can also be a string e.g: 'data'
  dev.publish :data, payload, with_confirm: true

  # 'publish' takes two mandatory arguments (channel's name and payload) and a variety of options: one of these options is
  # the 'with_confirm' flag: when set to true this requires SpaceBunny's platform to confirm the receipt of the message.
  # This is useful when message delivery assurance is mandatory for your use case.
  # Take a look at SDK's documentation for further details.

  # Give some feedback on what has been published
  puts "Published #{payload}"

  # Take a nap...
  sleep 1
  # Update counter
  count += 1
end

# Wait for publish confirmations: wait for SpaceBunny to confirm that all published messages have been
# accepted.
result = dev.wait_for_publish_confirms

# 'wait_for_publish_confirms' waits for every message published, regardless the channel, blocking execution until
# every confirm (or nack) has been received. 'wait_for_publish_confirms' returns an Hash whose keys are the channels'
# names on which you have published some message.
# For instance:

result.each do |channel, status|
  # If result is false, some message has been nacked. A message may be nacked by SpaceBunny's platform if, for some
  # reason, it cannot take responsibility for the message
  unless status[:all_confirmed]
    # do something with nacked messages
    status[:nacked_set].each do |nacked_message|
      # do something with nacked message
    end
  end
end
