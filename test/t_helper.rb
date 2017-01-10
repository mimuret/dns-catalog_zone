require 'helper'
require 'dnsruby'
module Dns
  module CatlogZone
    class TestHelper < Minitest::Test
      include Dns::CatlogZone
      include Dns::CatlogZone::ZoneHelper
      def setup
        @masters = {}
        @notifies = {}
        @allow_transfers = {}
      end

      def test_host_rr
        a = Dnsruby::RR.create(name: 'example.net',
                               type: Dnsruby::Types.A,
                               address: '192.168.0.1')
        aaaa = Dnsruby::RR.create(name: 'example.net',
                                  type: Dnsruby::Types.AAAA,
                                  address: '2001:db8::1')
        cname = Dnsruby::RR.create(name: 'example.net',
                                   type: Dnsruby::Types.CNAME,
                                   domainname: 'example.jp')
        assert host_rr?(a), 'A is host rr'
        assert host_rr?(aaaa), 'AAAA is host rr'
        refute host_rr?(cname), 'cname is not host rr'
      end

      def test_txt_rr
        txt = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.TXT,
                                 strings: 'hogehoge')
        spf = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.SPF,
                                 strings: 'hogehoge')
        assert txt_rr?(txt), 'TXT is txt rr'
        refute txt_rr?(spf), 'SPF is not txt rr'
      end

      def test_ptr_rr
        ptr = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.PTR,
                                 domainname: 'hogehoge')
        dname = Dnsruby::RR.create(name: 'example.net',
                                   type: Dnsruby::Types.DNAME,
                                   domainname: 'hogehoge')
        assert ptr_rr?(ptr), 'PTR is ptr rr'
        refute ptr_rr?(dname), 'DNAME is not ptr rr'
      end

      def test_ptr_rr
        apl = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.APL,
                                 prefixes: '1:10.0.0.1/32 2:::/0 2:::1/128')
        assert apl_rr?(apl), 'APL is apl rr'
      end

      def test_add_masters
        a = Dnsruby::RR.create(name: 'example.net',
                               type: Dnsruby::Types.A,
                               address: '192.168.0.1')
        aaaa = Dnsruby::RR.create(name: 'example.net',
                                  type: Dnsruby::Types.AAAA,
                                  address: '2001:DB8::1')
        txt = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.TXT,
                                 strings: 'hogehoge')
        add_masters(a, 'label')
        add_masters(aaaa, 'label')
        add_masters(txt, 'label')
        assert_instance_of Master, @masters['label'], 'add masters'
        assert_includes @masters['label'].addresses, '192.168.0.1'
        assert_includes @masters['label'].addresses, '2001:DB8::1'
        assert_includes @masters['label'].tsig, 'hogehoge'
      end

      def test_add_notifies
        a = Dnsruby::RR.create(name: 'example.net',
                               type: Dnsruby::Types.A,
                               address: '192.168.0.1')
        aaaa = Dnsruby::RR.create(name: 'example.net',
                                  type: Dnsruby::Types.AAAA,
                                  address: '2001:DB8::1')
        txt = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.TXT,
                                 strings: 'hogehoge')
        add_notifies(a, 'label')
        add_notifies(aaaa, 'label')
        add_notifies(txt, 'label')
        assert_instance_of Master, @notifies['label'], 'add notifies'
        assert_includes @notifies['label'].addresses, '192.168.0.1'
        assert_includes @notifies['label'].addresses, '2001:DB8::1'
        assert_includes @notifies['label'].tsig, 'hogehoge'
      end

      def test_add_allow_transfers
        a = Dnsruby::RR.create(name: 'example.net',
                               type: Dnsruby::Types.A,
                               address: '192.168.0.1')
        aaaa = Dnsruby::RR.create(name: 'example.net',
                                  type: Dnsruby::Types.AAAA,
                                  address: '2001:DB8::1')
        txt = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.TXT,
                                 strings: 'hogehoge')
        apl = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.APL,
                                 prefixes: '1:10.0.0.1/32 2:::1/128')

        add_allow_transfers(a, 'label')
        add_allow_transfers(aaaa, 'label')
        add_allow_transfers(txt, 'label')
        add_allow_transfers(apl, 'label')
        assert_instance_of Prefixes,
                           @allow_transfers['label'],
                           'add allow_transfers'
        assert_includes @allow_transfers['label'].prefixes[0].address.to_s,
                        '10.0.0.1',
                        'add APL 10.0.0.1'
        assert_includes @allow_transfers['label'].prefixes[1].address.to_s,
                        '::1',
                        'add APL ::1'
      end
    end
  end
end
