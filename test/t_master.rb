require 'helper'
require 'dnsruby'

module Dns
  module CatalogZone
    class TestMaster < Minitest::Test
      def test_master
        master = Master.new
        master.add_address('192.168.0.2')
        master.add_address('2001:DB8::2')

        assert_includes master.addresses, '192.168.0.2'
        assert_includes master.addresses, '2001:DB8::2'
      end
      def test_parse_master
        master = Master.new
        a = Dnsruby::RR.create(name: 'example.net',
                               type: Dnsruby::Types.A,
                               address: '192.168.10.1')
        aaaa = Dnsruby::RR.create(name: 'example.net',
                                  type: Dnsruby::Types.AAAA,
                                  address: '2001:db8::10')
        txt = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.TXT,
                                 strings: 'hogehoge')

        master.parse_master(a)
        master.parse_master(aaaa)
        master.parse_master(txt)

        assert_includes master.addresses, '192.168.10.1'
        assert_includes master.addresses, '2001:DB8::10'
        assert_includes master.tsig, 'hogehoge'
      end
    end
  end
end
