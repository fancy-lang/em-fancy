module Kernel
  def wait(object)
    Async.wait object
  end

  alias_method "wait:", :wait
end
