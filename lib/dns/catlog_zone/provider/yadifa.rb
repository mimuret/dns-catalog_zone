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

require 'dns/catlog_zone/provider/base'

module Dns
  module CatlogZone
    module Provider
      class Yadifa < Base
        def initialize(setting)
          @setting = setting
          @output = ''
          @type = 'master'
          @templates = []
          @acls = []
          @remotes = []
          @zones = []
          @masters = []
          @notifies = []
        end

        def make(catlog_zone)
          global_config(catlog_zone)
          zones_config(catlog_zone)
        end

        def global_config(catlog_zone)
          allow_transfers = []

          catlog_zone.masters.each_pair do |_label, master|
            add_master(master, @masters)
          end
          catlog_zone.notifies.each_pair do |_label, notify|
            add_notify(notify, @notifies)
          end
          catlog_zone.allow_transfers.each_pair do |_label, prefixes|
            add_prefixes(prefixes, allow_transfers)
          end

          output_r '<main>'
          # for master
          unless @masters.empty?
            output_r "\tallow-notify\t#{@masters.join(';')}"
          end

          # for allow-transfer
          unless allow_transfers.empty?
            output_r "\tallow-transfer\t#{allow_transfers.join(';')}"
          end
          output_r '</main>'
        end

        def add_master(master, masters)
          return if master.addresses.empty?
          @type = 'slave'
          masters.push(master.addresses)
        end

        def add_notify(notify, notifies)
          return if notify.addresses.empty?
          notifies.push(notify.addresses)
        end

        def add_prefixes(prefixes, allow_transfers)
          prefixes.prefixes.each do |prefix|
            allow_transfers.push("#{prefix.address}/#{prefix.prefix_length}")
          end
        end

        def zones_config(catlog_zone)
          catlog_zone.zones.each_pair do |_hash, zone|
            masters = @masters.clone
            notifies = @notifies.clone
            allow_transfers = []

            zone.masters.each_pair do |_label, master|
              add_master(master, masters)
            end
            zone.notifies.each_pair do |_label, notify|
              add_notify(notify, notifies)
            end
            zone.allow_transfers.each_pair do |_label,prefixes|
              add_prefixes(prefixes, allow_transfers)
            end

            output_r '<zone>'
            output_r "\ttype\t#{@type}"
            output_r "\tdomain\t#{zone.zonename}"
            output_r "\tfile\t#{zonepath(zone)}"
            # for master
            if !masters.empty?
              output_r "\tallow-notify\t#{masters.join(';')}"
              output_r "\tmasters\t#{masters.join(',')}"
              output_r "\ttrue-multimaster\tyes" if masters.count > 1
            end

            # for notify
            unless notifies.empty?
              output_r "\talso-notify\t#{notifies.join(',')}"
              allow_transfers = notifies
            end

            # for allow-transfer
            unless allow_transfers.empty?
              output_r "\tallow-transfer\t#{allow_transfers.join(';')}"
            end
            output_r '</zone>'
          end
        end
      end
    end
  end
end
