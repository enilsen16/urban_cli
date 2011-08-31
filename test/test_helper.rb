require 'minitest/autorun'
require 'ostruct'
require 'pry'
require 'redgreen'
require 'urban'
require 'urban/cli'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

TEST_PHRASE = OpenStruct.new({
  word: 'impromptu',
  definitions: [
    'Something that is made up on the spot and given little time to gather and present. Usually referring to speeches that are given only a few minutes to prepare for.',
    'On the spot',
    'Something that is made up on the spot.  Can also mean a speech that was made with little or no preparation.'
]})

def load_file(filename)
  contents = ''
  File.open(File.expand_path("../data/#{filename}", __FILE__)) do |file|
    contents = file.read
  end
  contents
end

module Stub
  def stub(name, &block)
    self.class.send(:undef_method, name)
    self.class.send(:define_method, name, &block)
  end
end

class String
  def to_args
    self.split(' ')
  end
end

