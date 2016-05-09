<p align="center">
  <img width="480" src="assets/logo.png"/>
</p>

[![Build Status](https://travis-ci.org/space-bunny/ruby_sdk.svg)](https://travis-ci.org/space-bunny/ruby_sdk)
[![Gem Version](https://badge.fury.io/rb/space_bunny.svg)](https://badge.fury.io/rb/spacebunny)

[Space Bunny](http://spacebunny.io) is the IoT platform that makes it easy for you and your devices to send and exchange messages with a server or even with each other. You can store the data, receive timely event notifications, monitor live streams and remotely control your devices. Easy to use, and ready to scale at any time.

This is the source code repository for Ruby SDK.
Please feel free to contribute!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spacebunny'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spacebunny

## Basic usage

After you have signed up to [Space Bunny](http://spacebunny.io)'s platform, follow the [Getting Started](http://getting_started_link) 
guide for a one minute introduction to the platform concepts and a super rapid setup.

Pick a device, view its configurations and copy the Device Key. Instantiate a new `Spacebunny::Device` client providing the Device Key:

```ruby
dev = Spacebunny::Device.new 'device_magic_key'
```

the SDK will auto-configure, contacting [Space Bunny APIs](http://api_doc_link) endpoint, retrieving the connection configurations and required parameters.
Nothing remains but to connect:

```ruby
dev.connect
```

### Publish

Ok, all set! Let's publish some messages:

```ruby
# We're assuming you have created a 'data' channel and you have enabled it for your device

# Let's publish, for instance, some JSON. Payload can be everything you want, Space Bunny does not impose any constraint
# on format or content.

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
device and click on 'LIVE DATA'. Select the 'data' channel from the dropdown and click 'START'.
Having published data as JSON allows Space Bunny's web UI to parse them and visualize a nice
realtime graph: On the 'Graphic' tab write `temp` in the input field and press enter.
You'll see the graph of the _temp_ parameter being rendered. If you want to plot more parameters, just use a comma as separator
e.g: temp, pressure, voltage
On the 'Messages' tab you'll see raw messages' payloads received on this channel.

### Subscribe

Waiting for and reading messages received from Space Bunny is as easy as publishing:
```ruby



```

Take a look at the ```examples``` directory for code samples.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/FancyPixel/spacebunny_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
