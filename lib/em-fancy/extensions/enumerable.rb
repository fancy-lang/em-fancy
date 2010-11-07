module Enumerable
  def async
    Async::Enumerator.new self
  end

  alias_method ":async", :async
end
