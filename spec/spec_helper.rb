$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'tempfile'
require 'ostruct'

require 'hashie'
require 'rspec'
require 'fakefs/safe'
require 'mocha'
require 'bio'
require 'scaffolder/test/helpers'
require 'scaffolder'

require 'scaffolder/tool'
Dir["#{File.dirname(__FILE__)}/../lib/scaffolder/tool/*.rb"].each do |f|
  require File.expand_path(f)
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require File.expand_path(f)
end

RSpec.configure do |config|
  config.mock_with :mocha

  include Scaffolder::Test::Helpers

  def mock_command_line_settings(scaf_file = mock, seq_file = mock, hash_args={})
    settings = mock

    settings.stubs(:rest).returns([scaf_file,seq_file])
    settings.stubs(:sequence_file).returns(seq_file)
    settings.stubs(:scaffold_file).returns(scaf_file)

    hash_args.each do |key,value|
      settings.expects(:[]).with(key).returns(value)
    end

    settings
  end

end
