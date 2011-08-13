$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'tempfile'
require 'ostruct'

require 'rspec'
require 'fakefs/safe'
require 'mocha'
require 'bio'
require 'scaffolder/test/helpers'
require 'scaffolder'

require 'scaffolder/tool'
require 'scaffolder/tool_index'
require 'scaffolder/binary_helper'
Dir["#{File.dirname(__FILE__)}/../lib/scaffolder/tool/*.rb"].each do |f|
  require File.expand_path(f)
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require File.expand_path(f)
end

RSpec.configure do |config|
  config.mock_with :mocha

  include Scaffolder::Test
  include Scaffolder::Test::Helpers

  def tool_subclasses
    ObjectSpace.each_object.map{|obj| obj.class }.select do |cls|
      cls.superclass == Scaffolder::Tool
    end
  end

  class MockSettings

    attr :scaf_file
    attr :seq_file

    def initialize(scaf_file = nil, seq_file = nil, command_args = {})
      @scaf_file, @seq_file, = scaf_file, seq_file
      @args = command_args
    end

    def rest
      [scaf_file,seq_file]
    end

    def [](arg)
      @args[arg]
    end

  end

end
