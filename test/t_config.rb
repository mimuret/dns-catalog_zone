require 'helper'

module Dns
  module CatlogZone
    class TestConfig < Minitest::Test
      def test_config_not_read
        assert_raises ConfigNotFound, 'can not read' do
          Config.read('test/dummy')
        end
      end

      def test_config_read_error
        assert_raises NameError, 'can not read ' do
          Config.read('test/config/ErrorFile')
        end
      end

      def test_config_read_success
        config = Config.read('test/config/CatlogZone')
        assert_instance_of Config, config, 'can read'
      end
    end
  end
end
