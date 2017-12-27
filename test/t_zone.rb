require 'helper'

module Dns
  module CatalogZone
    class TestZone < Minitest::Test
      def test_zone
        zone = Zone.new(Dnsruby::Name.create('example.jp'))
        assert_instance_of Hash, zone.masters
        assert_instance_of Hash, zone.notifies
        assert_instance_of Hash, zone.allow_transfers
      end
    end
  end
end
