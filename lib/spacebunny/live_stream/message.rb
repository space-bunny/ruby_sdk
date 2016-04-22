module Spacebunny
  module LiveStream
    class Message
      attr_reader  :live_stream, :sender_id, :channel_name, :delivery_info, :metadata, :payload

      def initialize(live_stream, options, delivery_info, metadata, payload)
        @live_stream = live_stream
        @options = options
        @delivery_info = delivery_info
        @metadata = metadata
        @payload = payload

        set_sender_id_and_channel
      end

      def ack(options = {})
        multiple = options.fetch :multiple, false
        @live_stream.acknowledge @delivery_info.delivery_tag, multiple
      end

      def nack(options = {})
        multiple = options.fetch :multiple, false
        requeue = options.fetch :requeue, false
        @live_stream.nack @delivery_info.delivery_tag, multiple, requeue
      end

      def from_api?
        !@metadata[:headers].nil? && @metadata[:headers]['x-from-sb-api']
      end

      private

      def set_sender_id_and_channel
        @sender_id, @channel_name = @delivery_info[:routing_key].split('.')
      end
    end
  end
end
