module GitHub::Deprecation
  class DelayedQueue < Array
    def initialize
      @started  = false
    end

    def start!(&callback)
      @started  = true
      @callback = callback
      each {|e| @callback.call(e)} if @callback
    end

    def pause!
      @started = false
    end

    def enqueue(*items)
      self.push(*items)
      items.each {|e| @callback.call(e)} if @started && @callback
    end
  end
end