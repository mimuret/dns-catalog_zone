require 'helper'

module Dns
  module CatalogZone
    class TestProviderBase < Minitest::Test
      def test_provider_nsd
        setting = Setting.new('example')
        setting.software = 'nsd'
        nsd = Dns::CatalogZone::Provider.create(setting)
        assert_instance_of Dns::CatalogZone::Provider::Nsd,
                           nsd,
                           'create provider nsd'
      end
    end
  end
end
