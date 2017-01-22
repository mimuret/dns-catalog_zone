require 'helper'

module Dns
  module CatlogZone
    class TestProvider < Minitest::Test
      def test_create
        setting = Setting.new('example')
        setting.software = 'nsd'
        nsd = Provider.create(setting)
        assert_instance_of Dns::CatlogZone::Provider::Nsd,
                           nsd,
                           'create provider nsd'
        setting.software = 'knot'
        knot = Provider.create(setting)
        assert_instance_of Dns::CatlogZone::Provider::Knot,
                           knot,
                           'create provider knot'
        setting.software = 'yadifa'
        yadifa = Provider.create(setting)
        assert_instance_of Dns::CatlogZone::Provider::Yadifa,
                           yadifa,
                           'create provider yadifa'
        assert_raises Dns::CatlogZone::ValidateError do
          setting.software = 'test'
          Provider.create(setting)
        end
      end
    end
  end
end
