require 'helper'

module Dns
  module CatalogZone
    class TestProvider < Minitest::Test
      def test_create
        setting = Setting.new('example')
        setting.software = 'nsd'
        nsd = Provider.create(setting)
        assert_instance_of Dns::CatalogZone::Provider::Nsd,
                           nsd,
                           'create provider nsd'
        setting.software = 'knot'
        knot = Provider.create(setting)
        assert_instance_of Dns::CatalogZone::Provider::Knot,
                           knot,
                           'create provider knot'
        setting.software = 'yadifa'
        yadifa = Provider.create(setting)
        assert_instance_of Dns::CatalogZone::Provider::Yadifa,
                           yadifa,
                           'create provider yadifa'
        assert_raises Dns::CatalogZone::ValidateError do
          setting.software = 'test'
          Provider.create(setting)
        end
      end
    end
  end
end
