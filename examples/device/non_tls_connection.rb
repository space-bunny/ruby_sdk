require 'spacebunny'
require 'json'

# Prerequisites: you have created a device through the Space Bunny's web interface. You also have a 'data' channel (name
# is not mandatory, but we'll use this for our example). You have also enabled 'data' channel for the device. See our
# Getting Started [link] for a quick introduction to Space Bunny's base concepts.

# Once everything is set up get your device's API key from Space Bunny's web application: on the web interface,
# go to devices section and create or pick an existing device. Click on the 'SHOW CONFIGURATION' link, copy the API key
# and substitute it here:

device_key = 'your_awesome_device_key'

# Let's instantiate a Space Bunny client, providing the device's API key, that's the fastest and simplest method
# to create a new client.
# Provide `tls: false` to instantiate a NON-tls secured connection

dev = Spacebunny::Device.new device_key, tls: false

# An equivalent method for providing the API key is through options: Spacebunny::Device.new(key: key)

# We need to call 'connect' in order to open the communication with Space Bunny platform

dev.connect

# At this point the SDK is auto-configured and ready to use.
# Configurations are automatically lazy-fetched by the SDK itself when calling 'connect'.

# PUBLISHING MESSAGES

# As said in the prerequisites, we'll assume that 'data' channel is enabled for your device.
# If you're in doubt, please check that this is true through Space Bunny's web interface, by clicking on the device
# 'edit' (pencil icon) and verifying that 'data' channel is present and enabled for this device. Take a look at Getting
# Started [link] for a quick introduction to Space Bunny's base concepts.

# Let's publish, for instance, some JSON. Payload can be everything you want, Space Bunny does not impose any constraint
# on format or content of payload.

# Publish one message every second for a minute.
count = 0
60.times do
  # Generate some random data
  payload = {
      count: count,
      greetings: "Hello from #{dev.name}!",
      temp: rand(20.0..25.0),
      foo: rand(100..200)
  }.to_json

  # Hint: the channel name can also be a string e.g: 'data'
  dev.publish :data, payload

  # 'publish' takes two mandatory arguments (channel's name and payload) and a variety of options: one of these options is
  # the 'with_confirm' flag: when set to true this requires Space Bunny's platform to confirm the receipt of the message.
  # This is useful when message delivery assurance is mandatory for your use case.
  # Take a look at SDK's documentation for further details.

  # Give some feedback on what has been published
  puts "Published #{payload}"

  # Take a nap...
  sleep 1
  # Update counter
  count += 1
end
