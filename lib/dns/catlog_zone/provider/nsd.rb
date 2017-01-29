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

require 'ipaddr'
require 'dns/catlog_zone/provider/base'

module Dns
  module CatlogZone
    module Provider
      class Nsd < Base
        def make(catlog_zone)
          global_config(catlog_zone)
          zones_config(catlog_zone)
        end

        private
        
        def global_config(catlog_zone)
          output "pattern:\n"
          output "\tname: \"CatlogZone\"\n"
          catlog_zone.masters.each_pair do |label, master|
            output output_master(master, "#{label}.masters")
          end
          catlog_zone.notifies.each_pair do |label, notify|
            output output_notify(notify, "#{label}.notifies")
          end
          catlog_zone.allow_transfers.each_pair do |label,prefixes|
            output output_prefixes(prefixes)
          end
        end

        def output_master(master, label = 'global')
          request_xfr = []
          allow_notify = []
          master.addresses.each do |addr|
            ipa = IPAddr.new(addr)
            plen = ipa.ipv4? ? 32 : 128
            tsig = master.tsig || 'NOKEY'
            request_xfr << "\trequest-xfr: #{addr} port #{master.port} #{tsig}\n"
            allow_notify << "\tallow-notify: #{addr}/#{plen} port #{master.port} #{tsig}\n"
          end
          output = request_xfr.join + allow_notify.join
          return "\t# #{label}\n#{output}" unless output.empty?
        end

        def output_notify(notify, label = 'global')
          notifies = []
          provide_xfr = []
          notify.addresses.each do |addr|
            ipa = IPAddr.new(addr)
            plen = ipa.ipv4? ? 32 : 128
            tsig = notify.tsig || 'NOKEY'
            notifies << "\tnotify: #{addr} port #{notify.port} #{tsig}\n"
            provide_xfr << "\tprovide-xfr: #{addr}/#{plen} port #{notify.port} #{tsig}\n"
          end
          output = notifies.join + provide_xfr.join
          return "\t# #{label}\n#{output}" unless output.empty?
        end

        def output_prefixes(_prefixes)
          ''
        end

        def zones_config(catlog_zone)
          catlog_zone.zones.each_pair do |_hash, zone|
            output "zones:\n"
            output "\tinclude-pattern: \"CatlogZone\"\n"
            output "\tname: \"#{zone.zonename}\"\n"
            output "\tzonefile: \"#{zonepath(zone)}\"\n"
            zone.masters.each_pair do |label, master|
              output output_master(master, "#{label}.masters")
            end
            zone.notifies.each_pair do |label, notify|
              output output_notify(notify, "#{label}.notifies")
            end
          end
        end
      end
    end
  end
end
