require 'helper'

module Dns
  module CatlogZone
    class TestProviderBase < Minitest::Test
      def test_provider_base
        setting = Setting.new('example')
        setting.software = 'base'
        base = Dns::CatlogZone::Provider::Base.new(setting)
        assert_instance_of Dns::CatlogZone::Provider::Base,
                           base,
                           'create provider base'
        assert base.make(nil)
        assert base.reconfig
        assert base.reload
        assert base.validate
        assert_equal base.write, ''
        assert_equal base.output('test'), 'test'
        assert_equal base.output('hoge'), 'testhoge'
        assert_equal base.output_r('oooo'), "testhogeoooo\n"
        assert_equal base.write, "testhogeoooo\n"
      end
    end
  end
end
