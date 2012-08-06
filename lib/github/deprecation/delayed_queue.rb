module GitHub::Deprecation
  class DelayedQueue < Array
    def initialize
      @started  = false
    end

    def start!(&callback)
      @started  = true
      @callback = callback
      process!
    end

    def pause!
      @started = false
    end

    def enqueue(*items)
      self.push(*items)
      process!
    end

    private
    def process!
      shift(size).each {|e| @callback.call(e)} if @started && @callback
    end
  end
end