require("rubygems")
require("eventmachine")
require("em-http")
require("benchmark")

require: "../lib/em-fancy.fy"

FancySpec describe: Async with: {
  def request {
    EM::HttpRequest new("http://www.postrank.com")
  }

  def time: block {
    Benchmark realtime() { block call }
  }

  def time_of_couple_serial_requests {
    time: { 2 times: { wait: (self request get) }}
  }

  it: "should let use EM-operations outside EM.run block" when: {
    try {
      self request get
      true should == true # should happen
    } catch Exception {
      true should == false # should not happen
    }
  }

  # it "should not block async operations" do
  #   time { request.get }.should be < 0.01
  # end

  # it "#wait should block until async operation returns" do
  #   time { wait request.get }.should be > 0.05
  # end

  # it '#wait should return result of async operation' do
  #   wait(request.get).response.should include("<!DOCTYPE html>")
  # end

  # it "#wait should not block other async operations" do
  #   batch_duration = time { Array.new(5) { request.get }.map {|it| wait it }}
  #   batch_duration.should be < time_of_couple_serial_requests
  # end

  # it "should iterate over async enumerable yielding results of async operations" do
  #   Array.new(5) { request.get }.async.each do |it|
  #     it.response.should include("<!DOCTYPE html>")
  #   end
  # end

  # it "should iterate over async enumerable via transparent callbacks" do
  #   time { Array.new(5) { request.get }.async.map do |it|
  #     it.response
  #   end }.should be < time_of_couple_serial_requests
  # end

  # it "should handle mixed array with non-deferrable and deferrable objects" do
  #   result = [request.get, "hey"].async.to_a
  #   result[0].should == "hey"
  #   result[1].response.should include("<!DOCTYPE html>")
  # end
}
