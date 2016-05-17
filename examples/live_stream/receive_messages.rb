require 'spacebunny'

# Prerequisites:
# - You have created a Live Stream named 'live_data' through the SpaceBunny's web interface.
# - The Live Stream has, as sources, two devices' 'data' channel.
# See our Getting Started [link] for a quick introduction to SpaceBunny's base concepts.

# Once everything is set up go to Users section on SpaceBunny Web UI, select one user and click on 'Access Keys'
# Pick or create one access key and copy 'Client' and 'Secret'.

client = 'live_stream_key_client'
secret = 'live_stream_key_secret'

# Instantiate a Spacebunny::LiveStream (AMQP by default) client, providing the 'client' and 'secret' options.

live = Spacebunny::LiveStream.new client: client, secret: secret

# We need to call 'connect' in order to open the communication with SpaceBunny platform

live.connect

# At this point the SDK is auto-configured and ready to use.
# Configurations are automatically lazy-fetched by the SDK itself.

# RECEIVING MESSAGES

# For the sake of this test, we need first to publish some message.
# If you have configured correctly your Live Stream from Web Interface, it should have at least two devices' data
# channels as sources: pick one of the devices and copy its Api Key. Fire up another terminal, edit
# examples/device/auto_config_publish.rb   paste the Device Key and run the script.

puts 'Waiting for live messages'

# Receiving messages is trivial:

live.message_from_cache :live_data, wait: true, ack: :auto do |message|
  puts "Received: #{message.payload}"
end

# An alternative to the 'message_from_cache' method is:
# live.message_from :live_data, from_cache: true, wait: true, ack: :auto do |message|
#   puts "Received #{message.payload}"
# end

# Now fire up another terminal, copy the other device's Api Key and replace it in the auto_config_publish.rb
# script. If you take a look at the output of running live_stream/receive_messages.rb (this running script)
# you should see that messages from the devices are almost alternated.

# You may notice that we used 'message_from_cache' method: each LiveStream has its own cache that will keep always
# last 100 messages (FIFO, when there are more than 100 messages, the oldest ones get discarded).
# If you want to consume messages in a parallel way, you should use the cache and connect as many LiveStream Clients
# as you need: this way messages will be equally and uniquely distributed to clients.
# A nacked message will return to the queue and will be delivered to the next available client.

# Conversely, if you want that each client will receive a copy of each message, don't use the cache:

# live.message_from :live_data, wait: true, ack: :auto do |message|
#   puts "Received a copy of #{message.payload}"
# end

# Every client subscribed to the LiveStream in this way will receive a copy of the message.

### Options and notes
#
# A Ruby block must be supplied to the 'message_from' and 'message_from_cache' methods.
# These methods yield a Device::Message object that wrap all the useful data:
#
# dev.message_from do |message|
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

# message_from (message_from_cache) methods' options:
# 'wait' (default false) causes the script to wait forever on the receive block. This is useful
# for 'read-only' scripts like workers or similar.
# 'ack' option can have two values: :manual (default) or :auto. When :manual you are responsible to ack the messages,
# for instance:
#
# dev.message_from(block: true, ack: :manual) do |message|
#   puts "Received: #{message.payload}"
#   message.ack
# end
#
# When 'ack' is :auto then the SDK will automatically ack the messages when the code provided in the message_from block
# has terminated execution. This behaviour is useful in cases in which the code executed inside the message_from block
# will always lead to an acked message (no matter the operations' result).
# If your code can lead to errors and, for instance, the message must be reprocessed, you must use :manual ack
# and manually call 'ack' as seen in the example above.
# Call 'nack' in case the message needs to be reprocessed and it will remain on SpaceBunny until successfully
# acked. For instance:

# dev.message_from(block: true, ack: :manual) do |message|
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
#                     discarded by SpaceBunny. If true message will made
#                     requeued and made available for delivery again
