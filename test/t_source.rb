require 'helper'

module Dns
  module CatlogZone
    class TestSource < Minitest::Test
      def test_create
        setting = Setting.new('example')
        setting.source = 'file'
        file = Source.create(setting)
        assert_instance_of Dns::CatlogZone::Source::File,
                           file,
                           'create source file'
        setting.source = 'axfr'
        axfr = Source.create(setting)
        assert_instance_of Dns::CatlogZone::Source::Axfr,
                           axfr,
                           'create provider axfr'
        assert_raises Dns::CatlogZone::ValidateError do
          setting.source = 'test'
          Source.create(setting)
        end
      end
    end
  end
end
