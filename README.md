<p align="center">
  <img width="480" src="assets/logo.png"/>
</p>

[![Build Status](https://travis-ci.org/space-bunny/ruby_sdk.svg)](https://travis-ci.org/space-bunny/ruby_sdk)
[![Gem Version](https://badge.fury.io/rb/spacebunny.svg)](https://badge.fury.io/rb/spacebunny)

[Space Bunny](http://spacebunny.io) is the IoT platform that makes it easy for you and your devices to send and
exchange messages with a server or even with each other. You can store the data, receive timely event notifications,
monitor live streams and remotely control your devices. Easy to use, and ready to scale at any time.

This is the source code repository for Ruby SDK.
Please feel free to contribute!

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'spacebunny'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spacebunny

After you have signed up for a [Space Bunny](http://spacebunny.io)'s account, follow the
[Getting Started](http://getting_started_link) guide for a one minute introduction to the platform concepts
and a super rapid setup.

This SDK provides Device and LiveStream clients and currently supports the AMQP protocol.

### Device - Basic usage

Pick a device, view its configurations and copy the Device Key. Instantiate a new `Spacebunny::Device` client,
providing the Device Key:

```ruby
dev = Spacebunny::Device.new 'device_key'
```

the SDK will auto-configure, contacting [Space Bunny APIs](http://doc.spacebunny.io/api) endpoint, retrieving the
connection configurations and required parameters. Nothing remains but to connect:

```ruby
dev.connect
```

##### Publish

Ok, all set up! Let's publish some message:

```ruby
# We're assuming you have created a 'data' channel and you have enabled it for your device

# Let's publish, for instance, some JSON. Payload can be everything you want,
# Space Bunny does not impose any constraint on format or content.

require 'json'  # to convert our payload to JSON

# Publish one message every second for a minute.
60.times do
  # Generate some random data
  payload = { greetings: 'Hello, World!', temp: rand(20.0..25.0), foo: rand(100..200) }.to_json
    
  # Publish
  dev.publish :data, payload
  
  # Give feedback on what has been published
  puts "Published: #{payload}"

  # Take a nap...
  sleep 1
end
```

Let's check out that our data is really being sent by going to our web dashboard: navigate to devices, select the
device and click on 'LIVE DATA'. Select the 'data' channel from the dropdown and click **Start**.
Having published data as JSON allows Space Bunny's web UI to parse them and visualize a nice
realtime graph: On the **Chart** tab write `temp` in the input field and press enter.
You'll see the graph of the `temp` parameter being rendered. If you want to plot more parameters,
just use a comma as separator e.g: temp, pressure, voltage
On the **Messages** tab you'll see raw messages' payloads received on this channel.

##### Inbox

Waiting for and reading messages from the device's Inbox is trivial:

```ruby
dev.inbox(wait: true, ack: :auto) do |message|
  puts "Received: #{message.payload}"
end
```

`wait` option (default false) causes the script to wait forever on the receive block

`ack` option can have two values: `:manual` (default) or `:auto`. When `:manual` you are responsible to ack the messages,
for instance:

```ruby
dev.inbox(block: true, ack: :manual) do |message|
  puts "Received: #{message.payload}"
  # Manually ack the message
  message.ack
end
```
This permits to handle errors or other critical situations

### Live Stream - Basic usage

For accessing a Live Stream a Live Stream Key's is required. On SpaceBunny's Web UI, go to the Streams section,
click on "Live Stream Keys" and pick or create one.

```ruby
live = Spacebunny::LiveStream.new client: 'live_stream_key_client', secret: 'live_stream_key_secret'
```

Similarly to the Device client, the SDK will auto-configure itself, contacting [Space Bunny APIs](http://doc.spacebunny.io/api)
endpoint, retrieving the connection configurations and required parameters. Nothing remains but to connect:

```ruby
live.connect
```

##### Reading live messages

Each LiveStream has its own cache that will keep always last 100 messages (FIFO, when there are more than 100 messages,
the oldest ones get discarded). If you want to consume messages in a parallel way, you shoul use the cache and connect
 as many LiveStream clients as you need: this way messages will be equally distributed to clients.

```ruby
live.message_from_cache :some_live_stream, wait: true, ack: :auto do |message|
  puts "Received from cache: #{message.payload}"
end

# An equivalent method is:
# live.message_from :some_live_stream, from_cache: true, wait: true, ack: :auto do |message|
#   puts "Received from cache: #{message.payload}"
# end
```

Conversely, if you want that each client will receive a copy of each message, don't use the cache:

```ruby
live.message_from :some_live_stream, wait: true, ack: :auto do |message|
  puts "Received a copy of: #{message.payload}"
end
```

Every client subscribed to the LiveStream in this way will receive a copy of the message.

### TLS

Instantiating a TLS-secured connection is trivial:

```ruby
# For a Device

dev = Spacebunny::Device.new key, tls: true

# Similarly, for a Live Stream

live = Spacebunny::LiveStream.new client, secret, tls: true
```

## More examples and options

Take a look at the ```examples``` directory for more code samples and further details about available options.


### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/FancyPixel/spacebunny_ruby.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere
to the [Contributor Covenant](contributor-covenant.org) code of conduct.

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
