require 'helper'
require 'dnsruby'

module Dns
  module CatlogZone
    class TestPrefixes < Minitest::Test
      def test_prefixes
        prefixes = Prefixes.new

        d_prefixes = Dnsruby::Prefixes.create(['1:192.168.0.1/24',
                                               '2:2001:DB8::6/128'])

        prefixes.add_prefixes(d_prefixes)

        assert_equal prefixes.prefixes[0].af, 1, 'APL IPv4 AF=1'
        assert_equal prefixes.prefixes[0].prefix_length, 24, 'prefix length'
        assert_equal prefixes.prefixes[0].address.to_s, '192.168.0.1', 'ipv4 addr'
        assert_equal prefixes.prefixes[1].af, 2, 'APL IPv4 AF=2'
        assert_equal prefixes.prefixes[1].prefix_length, 128, 'prefix length'
        assert_equal prefixes.prefixes[1].address.to_s, '2001:DB8::6', 'ipv6 addr'

      end

      def test_parse_apl
        prefixes = Prefixes.new
        apl = Dnsruby::RR.create(name: 'example.net',
                                 type: Dnsruby::Types.APL,
                                 prefixes: '1:10.0.0.1/32 2:::1/128')
        prefixes.parse_apl(apl)
        assert_equal prefixes.prefixes[0].af, 1, 'APL IPv4 AF=1'
        assert_equal prefixes.prefixes[0].prefix_length, 32, 'prefix length'
        assert_equal prefixes.prefixes[0].address.to_s, '10.0.0.1', 'ipv4 addr'
        assert_equal prefixes.prefixes[1].af, 2, 'APL IPv4 AF=2'
        assert_equal prefixes.prefixes[1].prefix_length, 128, 'prefix length'
        assert_equal prefixes.prefixes[1].address.to_s, '::1', 'ipv6 addr'

      end
    end
  end
end
