require 'spacebunny'
require 'json'

# Prerequisites: you have created a device through the Space Bunny's web interface. See our Getting Started [link]
# for a quick introduction to Space Bunny's base concepts.

# Once everything is set up get your device's API key from Space Bunny's web application: on the web interface,
# go to devices section and create or pick an existing device. Click on the 'SHOW CONFIGURATION' link, copy the API key
# and substitute it here:

key = 'your_awesome_device_key'

# Let's instantiate a Space Bunny (AMQP by default) client, providing the device's API key, that's the fastest and simplest method
# to create a new client. If, for some reason, you need to customize the settings, take a look at
# examples/manual_config.rb for an example of connection settings customization.

dev = Spacebunny::Device.new key

# An equivalent method for providing the API key is through options: Spacebunny::Device.new(key: key)

# We need to call 'connect' in order to open the communication with Space Bunny platform

dev.connect

# At this point the SDK is auto-configured and ready to use.
# Configurations are automatically lazy-fetched by the SDK itself when calling 'connect'.


# RECEIVING MESSAGES

puts "Waiting for messages. Publish some from Space Bunny's web interface to try this out:"

# Receiving messages is trivial:

dev.inbox(wait: true, ack: :auto) do |message|
  puts "Received: #{message.payload}"
end

# A Ruby block must be supplied to the 'inbox' method. It yields a Device::Message object containing
# all the useful data:
#
# dev.inbox do |message|
#   puts "payload: #{message.payload}"
#
#   # metadata that can be accessed as an Hash.
#   # metadata[:headers] contains the message's headers for instance
#   puts "metadata: #{message.metadata}"
#
#   # sender_id (id of the device that sent the message)
#   puts "sender_id: #{message.sender_id}"
#
#   # channel name i.e. the name of the channel on which the message has been published
#   puts "channel_name: #{message.channel_name}"
#
#   # Connection and other low level info
#   puts "delivery_info: #{message.delivery_info}"
# end

# inbox method's options:
# 'wait' (default false) causes the script to wait forever on the receive block. This is useful
# for 'read-only' scripts like workers or similar.
# 'ack' option can have two values: :manual (default) or :auto. When :manual you are responsible to ack the messages,
# for instance:
#
# dev.inbox(block: true, ack: :manual) do |message|
#   puts "Received: #{message.payload}"
#   message.ack
# end
# When 'ack' is :auto then the SDK will automatically ack the messages when the code provided in the inbox block
# has terminated execution. This behaviour is useful in cases in which the code executed inside the inbox block
# will always lead to an acked message (no matter the operations' result).
# If your code can lead to errors and, for instance, the message must be reprocessed, you must use :manual ack
# and manually call 'ack' as seen in the example above.
# Call 'nack' in case the message needs to be reprocessed and it will remain on Space Bunny until successfully
# acked. For instance:

# dev.inbox(block: true, ack: :manual) do |message|
#   puts message.payload
#
#   begin
#     # Do something nasty...
#     raise
#
#     # If everything is ok, ack
#     # (note that this code will never be reached)
#     message.ack
#   rescue Exception => e
#     message.nack
#   end
# end

# ack options are:
#   multiple: false   ack multiple messages at once. Ack all the unacked
#                     messages up to the current one

# nack options are:
#   multiple: false   nack multiple messages at once. Nack all the messages up
#                     to the current one
#   requeue: false    requeue message. If false (default), the message will be
#                     discarded by Space Bunny. If true message will made
#                     requeued and made available for delivery again


# Other 'inbox' options:
# 'discard_from_api' (default false) causes the SDK to filter out messages published through APIs (or WEB UI) or
# generally sent directly through Space Bunny's platform.
# 'discard_mine' (default false) causes the SKD to filter out auto-messages i.e. messages sent from this device
# and, for some reason, returned to the sender. This can happen in some particular situation such as when using m2m
# groups.
