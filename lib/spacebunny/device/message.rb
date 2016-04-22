module Spacebunny
  module Device
    class Message
      attr_reader  :device, :sender_id, :channel_name, :delivery_info, :metadata, :payload

      def initialize(device, options, delivery_info, metadata, payload)
        @device = device
        @options = options
        @delivery_info = delivery_info
        @metadata = metadata
        @payload = payload

        extract_options
        set_sender_id_and_channel
      end

      def ack(options = {})
        multiple = options.fetch :multiple, false
        @device.input_channel.acknowledge @delivery_info.delivery_tag, multiple
      end

      def nack(options = {})
        multiple = options.fetch :multiple, false
        requeue = options.fetch :requeue, false
        @device.input_channel.nack @delivery_info.delivery_tag, multiple, requeue
      end

      def blacklisted?
        # Discard packet if it has been sent from me
        if @discard_mine && @device.id.eql?(@sender_id) && !from_api?
          return true
        end
        # Discard packet if has been published from APIs
        if @discard_from_api && from_api?
          return true
        end
        false
      end

      def from_api?
        !@metadata[:headers].nil? && @metadata[:headers]['x-from-sb-api']
      end

      private

      def extract_options
        @discard_mine = @options.fetch :discard_mine, false
        @discard_from_api = @options.fetch :discard_from_api, false
      end

      def set_sender_id_and_channel
        @sender_id, @channel_name = @delivery_info[:routing_key].split('.')
      end
    end
  end
end
