require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/minitest'

require 'train-habitat'

require 'byebug'
require 'json'

#============================================================================#
#                          Actual Test Helper
#============================================================================#

module InspecHabitat
  module UnitTestHelper
    def check_definition(opts)
      it 'should meet the basic definition of a resource' do
        klass = opts[:klass]
        meta = klass.metadata

        klass.must_be :<, Inspec::Plugins::Resource
        meta.name.wont_be_empty
        meta.example.wont_be_empty
        meta.desc.wont_be_empty
        meta.supports.must_equal({ platform: 'habitat' })
        klass.instance_methods.must_include(:exist?)
        klass.instance_methods.must_include(:exists?)
      end
    end

    def seek_test(_opts)
      # TODO
      describe 'when seeking the resource' do
        describe 'when the resource is locatable' do
          it 'should be found'
        end
        describe 'when the resource is not locatable' do
          it 'should throw an exception'
        end
      end
    end
  end
end

#============================================================================#
#                          Resource DSL Mocking
#============================================================================#

# Dummy - this is the superclass
# Loading enough of inspec to get this is
# a nightmare, though; so we just fake it here.
module Inspec
  module Plugins
    class Resource
      class << self
        attr_reader :metadata
      end

      def self.name(val)
        @metadata ||= OpenStruct.new
        @metadata[:name] = val
      end

      def self.desc(val)
        @metadata ||= OpenStruct.new
        @metadata[:desc] = val
      end

      def self.supports(val)
        @metadata ||= OpenStruct.new
        @metadata[:supports] = val
      end

      def self.example(val)
        @metadata ||= OpenStruct.new
        @metadata[:example] = val
      end
    end
  end
end

# Returns the resource superclass
module Inspec
  def self.resource(_version)
    Inspec::Plugins::Resource
  end
end
