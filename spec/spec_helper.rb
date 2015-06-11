# Copyright (c) 2000-2013 Baidu, Inc.
require 'simplecov'
SimpleCov.start

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'support/active_record'
require 'rack/test'
require 'rspec'
require 'eventmachine'
require 'base'
require 'database'
require 'worker'

module Akb
  module_function
  def run_in_eventloop(&blk)
    EM.run do
      blk.call
      EM.stop
    end
  end

  def close_eventloop_after(time, &blk)
    EM.run do
      blk.call
      EM.add_timer(time) { EM.stop }
    end
  end
end


