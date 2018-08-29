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
# Also provide  tls: true to  establish a NON tls-encrypted connection

live = Spacebunny::LiveStream.new client: client, secret: secret, tls: false
live.connect

live.message_from_cache :live_data, ack: :auto, wait: true do |message|
  puts "Received: #{message.payload}"
end
