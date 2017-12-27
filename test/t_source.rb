require 'helper'

module Dns
  module CatalogZone
    class TestSource < Minitest::Test
      def test_create
        setting = Setting.new('example')
        setting.source = 'file'
        file = Source.create(setting)
        assert_instance_of Dns::CatalogZone::Source::File,
                           file,
                           'create source file'
        setting.source = 'axfr'
        axfr = Source.create(setting)
        assert_instance_of Dns::CatalogZone::Source::Axfr,
                           axfr,
                           'create provider axfr'
        assert_raises Dns::CatalogZone::ValidateError do
          setting.source = 'test'
          Source.create(setting)
        end
      end
    end
  end
end
