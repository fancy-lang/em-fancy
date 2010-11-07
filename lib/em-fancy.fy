require("fiber")
require("rubygems")
require("eventmachine")
require("lib/em-fancy/extensions/kernel")
require("lib/em-fancy/extensions/enumerable")

Fiber = Rubinius Fiber

class Async {
  extend(self)
  read_slots: ['evented_loop]

  class Enumerator {
    include: FancyEnumerable
    include: Enumerable

    def initialize: @collection {
      @total = @collection size
    }

    def each: block {
      @finished = 0
      @block = block
      iterate_collection = {
        @collection each: |it| {
          it respond_to?: 'callback: . if_true: {
            it callback: |result| { finished: result }
          } else: {
            finished: it
          }
        }
      }

      Async evented_loop resume: <['block => iterate_collection, 'smart => true ]>
    }

    def finished: result {
      @block call: [result]
      @finished = @finished + 1
      Async send 'next_iteration: params: [{ Fiber yield: @collection } if: (@finished == @total)]
    }
  }

  @evented_loop = Fiber new() {
    EM run() { next_iteration: nil }
  }

  def wait: object {
    handle_callback = {
      object callback: |args| { next_iteration: (Fiber yield: args) }
    }
    @evented_loop resume(<[ 'block => handle_callback, 'smart => true ]>)
  }

  def next_iteration: options {
    options if_do: {
      options['block] if_do: {
        block = options
      }
    } else: {
      block = nil
    }

    block if_do: {
      options['smart] if_do: {
        block call
      } else: {
        instructions = Fiber yield(block && (block call))
        EM next_tick() {
          next_iteration: instructions
        }
      }
    }
  }

  @evented_loop resume()
}
