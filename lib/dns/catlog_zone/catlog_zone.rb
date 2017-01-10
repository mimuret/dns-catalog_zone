# The MIT License (MIT)
#
# Copyright (c) 2016 Manabu Sonoda
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'digest/sha1'
require 'dns/catlog_zone'
require 'dnsruby'

module Dns
  module CatlogZone
    # for catlog zone
    class CatlogZone
      include Dns::CatlogZone
      include Dns::CatlogZone::ZoneHelper

      attr_reader :masters, :notifies, :allow_transfers
      attr_reader :zones

      # initialize zone
      def initialize(zonename, rrsets)
        @rrsets = rrsets
        @zonename = Dnsruby::Name.create(zonename).to_s + '.'
        @zones = {}
        @templates = {}
        @masters = {}
        @notifies = {}
        @allow_transfers = {}

        version_name = Dnsruby::Name.create("version.#{@zonename}")
        masters_name = Dnsruby::Name.create("masters.#{@zonename}")
        notifies_name = Dnsruby::Name.create("notifies.#{@zonename}")
        transfer_name = Dnsruby::Name.create("allow-transfer.#{@zonename}")

        @rrsets.each do |rr|
          # version
          if rr.name == version_name && rr.type == Dnsruby::Types::TXT
            @version = rr.strings.join('')
          end
          # global master option
          add_masters(rr, '.') if rr.name == masters_name
          add_masters(rr, rr.name.labels[0]) if rr.name.subdomain_of?(masters_name)

          # global notify option
          add_notifies(rr, '.') if rr.name == notifies_name
          add_notifies(rr, rr.name.labels[0]) if rr.name.subdomain_of?(notifies_name)

          # global allow-transfer option
          add_allow_transfers(rr, '.') if rr.name == transfer_name
          add_allow_transfers(rr, rr.name.labels[0]) if rr.name.subdomain_of?(transfer_name)
        end
        case @version
        when '1'
          parse_v1
        else
          require 'pp'
          raise ValidateError, "#{@version} is unknown Catalog zone schema version"
        end
      end

      private

      def parse_zones
        zones_str = Dnsruby::Name.create("zones.#{@zonename}")
        # step 1 load zones
        @rrsets.each do |rr|
          next unless rr.name.subdomain_of?(zones_str)
          next unless rr.type == Dnsruby::Types::PTR
          mhash = Digest::SHA1.hexdigest(rr.domainname.canonical)
          if mhash != rr.name.labels[0].to_s
            raise ValidateError, "#{rr.name.labels[0]} PTR #{mhash} is not equal hash."
          end
          @zones[rr.name.labels[0].to_s] = Dns::CatlogZone::Zone.new(rr.domainname)
        end
      end

      def parse_zones_options
        zones_name = Dnsruby::Name.create("zones.#{@zonename}")
        @rrsets.each do |rr|
          next unless rr.name.subdomain_of?(zones_name)
          label = type = mhash = nil
          if @zones[rr.name.labels[1].to_s]
            label = '.'
            type = rr.name.labels[0].to_s
            mhash = rr.name.labels[1].to_s
          elsif @zones[rr.name.labels[2].to_s]
            label = rr.name.labels[0].to_s
            type = rr.name.labels[1].to_s
            mhash = rr.name.labels[2].to_s
          end

          case type
          when 'masters'
            @zones[mhash].add_masters(rr, label)
          when 'notifies'
            @zones[mhash].add_notifies(rr, label)
          when 'allow-transfer'
            @zones[mhash].add_allow_transfers(rr, label)
          end
        end
      end

      def parse_v1
        # step 1 load zones
        parse_zones
        # step 2 load options
        parse_zones_options
      end
    end
  end
end
