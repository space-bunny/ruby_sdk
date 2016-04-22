module Spacebunny
  # Log on multiple outputs at the same time
  #
  # Usage example:
  #
  # log_file = File.open("log/debug.log", "a")
  # Logger.new Spacebunny::Logger.new(STDOUT, log_file)

  class Logger
    def initialize(*args)
      @streams = []
      args.each do |a|
        case a
          when String
            # This is a file path
            puts File.open(a, 'a+').inspect
            @streams << File.open(a, 'a+')
          else
            @streams << a
        end
      end
    end

    def write(*args)
      @streams.each do |lo|
        lo.write(*args)
        lo.flush
      end
    end

    def close
      @streams.each(&:close)
    end
  end
end
