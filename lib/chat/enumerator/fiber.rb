module Chat
  class EnumeratorFiber
    def initialize(sentinel, &block)
      @sentinel = sentinel
      @fiber = Fiber.new(&block)
    end

    def each
      return enum_for(:each) unless block_given?
      loop do
        r = @fiber.resume
        break if r.equal?(@sentinel)
        raise r if r.is_a? Exception
        yield r
      end
    end
  end
end
