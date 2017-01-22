require 'helper'

module Dns
  module CatlogZone
    class TestProviderBase < Minitest::Test
      def test_provider_nsd
        setting = Setting.new('example')
        setting.software = 'nsd'
        nsd = Dns::CatlogZone::Provider.create(setting)
        assert_instance_of Dns::CatlogZone::Provider::Nsd,
                           nsd,
                           'create provider nsd'
      end
    end
  end
end
