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
      class Knot < Base
        # Dns::CatlogZone::Provider::Knot::Attribute
        class Attribute
          def initialize(hash)
            @output = ''
            hash.each do |key, value|
              public_send("#{key}=", value) if respond_to?("#{key}=")
            end
          end

          def output_r(msg = nil)
            @output += "#{msg}\n" if msg
          end
        end
        # Dns::CatlogZone::Provider::Knot::Template
        class Template < Attribute
          attr_accessor :id, :storage, :masters, :acls
          def initialize(hash)
            super(hash)
            @masters = []
            @acls = []
            @notifies = []
          end

          def add_acl(label)
            @acls.push(label)
          end

          def add_master(label)
            @masters.push(label)
          end

          def add_notify(label)
            @notifies.push(label)
          end

          def print
            output_r "    - id: #{@id}"
            output_r "      master: [#{@masters.join(', ')}]" unless @masters.empty?
            output_r "      notify: [#{@notifies.join(', ')}]" unless @notifies.empty?
            output_r "      acl: [#{@acls.join(', ')}]" unless @acls.empty?

            @output
          end
        end
        # Dns::CatlogZone::Provider::Knot::Acl
        class Acl < Attribute
          attr_accessor :id, :address, :action, :key
          def initialize(hash)
            super(hash)
            @addresses = []
          end

          def add_address(address)
            @addresses.push(address)
          end

          def print
            output_r "    - id: #{@id}"
            output_r "      address: [ #{@addresses.join(', ')} ]" unless @addresses.empty?
            output_r "      tsig: #{@key}" if @key
            output_r "      action: #{@action}"

            @output
          end
        end
        # Dns::CatlogZone::Provider::Knot::Remote
        class Remote < Attribute
          def initialize(hash)
            super(hash)
            @addresses = []
          end

          def add_address(address)
            @addresses.push(address)
          end
          attr_accessor :id, :address, :key
          def print
            output_r "    - id: #{@id}"
            output_r "      address: [ #{@addresses.join(', ')} ]" unless @addresses.empty?
            output_r "      tsig: #{@key}" if @key

            @output
          end
        end
        # Dns::CatlogZone::Provider::Knot::Zone
        class Zone < Template
          attr_accessor :domain, :template, :storage, :file
          def print
            output_r "    - domain: #{@domain.to_s + '.'}"
            output_r '      type: slave' unless @masters.empty?
            output_r '      type: master' unless @notifies.empty?
            output_r '      type: master' unless @notifies.empty?
            output_r "      storage: #{storage}"
            output_r "      file: #{file}"
            output_r "      master: [#{@masters.join(', ')}]" unless @masters.empty?
            output_r "      notify: [#{@notifies.join(', ')}]" unless @notifies.empty?
            output_r "      acl: [#{@acls.join(', ')}]" unless @acls.empty?
            output_r "      template: #{template}"

            @output
          end

          def template
            @template || 'catlog-zone'
          end
        end
        def initialize(setting)
          @setting = setting
          @output = ''
          @templates = []
          @acls = []
          @remotes = []
          @zones = []
        end

        def make(catlog_zone)
          global_config(catlog_zone)
          zones_config(catlog_zone)
          make_output
        end

        def make_output
          output_r 'acl:'
          @acls.each do |acl|
            output_r acl.print
          end
          output_r 'remote:'
          @remotes.each do |remote|
            output_r remote.print
          end
          output_r 'template:'
          @templates.each do |template|
            output_r template.print
          end
          output_r 'zone:'
          @zones.each do |zone|
            output_r zone.print
          end
        end

        private

        def add_template(template)
          @templates.push(template)
        end

        def add_remote(remote)
          @remotes.push(remote)
        end

        def add_acl(acl)
          @acls.push(acl)
        end

        def add_zone(zone)
          @zones.push(zone)
        end

        def mkl(prefix, label)
          label = "#{prefix}-#{label}"
          label.tr!('.', '-')
          label.gsub!(/-$/, 'global')

          label
        end

        def global_config(catlog_zone)
          template = Template.new(id: 'catlog-zone')

          add_template(template)
          catlog_zone.masters.each_pair do |label, master|
            output_master(master, template, label)
          end
          catlog_zone.notifies.each_pair do |label, notify|
            output_notify(notify, template, label)
          end
          catlog_zone.allow_transfers.each_pair do |_label, prefixes|
            output_prefixes(prefixes, template, 'allow-transfer')
          end
        end

        def output_master(master, template, label)
          return if master.addresses.empty?

          # for request axfr
          remote = Remote.new(id: mkl('master', label), tsig: master.tsig)
          # for allow notify
          acl = Acl.new(id: mkl('notify', label), action: 'notify', key: master.tsig)
          master.addresses.each do |addr|
            remote.add_address(addr)
            acl.add_address(addr)
          end
          template.add_acl(mkl('notify', label))
          template.add_master(mkl('master', label))
          add_acl(acl)
          add_remote(remote)
        end

        def output_notify(notify, template, label)
          return if notify.addresses.empty?
          # for send notify
          remote = Remote.new(id: mkl('notify', label), tsig: notify.tsig)
          # for allow transfer
          acl = Acl.new(id: mkl('transfer', label), action: 'transfer', key: notify.tsig)
          notify.addresses.each do |addr|
            remote.add_address(addr)
            acl.add_address(addr)
          end
          template.add_notify(mkl('notify', label))
          template.add_acl(mkl('transfer', label))
          add_acl(acl)
          add_remote(remote)
        end

        def output_prefixes(prefixes, template, label)
          acl = Acl.new(id: mkl('acl', label), action: 'transfer')
          require 'pp'

          prefixes.prefixes.each do |prefix|
            acl.add_address("#{prefix.address}/#{prefix.prefix_length}")
          end
          add_acl(acl)
          template.add_acl(mkl('acl', label))
        end

        def zones_config(catlog_zone)
          catlog_zone.zones.each_pair do |_hash, zone|
            zone_path = zonepath(zone)
            storage = ::File.dirname(zone_path)
            file = ::File.basename(zone_path)

            kzone = Zone.new(domain: zone.zonename,
                             storage: storage,
                             file: file)

            add_zone(kzone)
            zone.masters.each_pair do |label, master|
              output_master(master, kzone, "#{zone.zonename}-#{label}")
            end
            zone.notifies.each_pair do |label, notify|
              output_notify(notify, kzone, "#{zone.zonename}-#{label}")
            end
            zone.allow_transfers.each_pair do |label, prefixes|
              output_prefixes(prefixes, kzone, "#{zone.zonename}-#{label}")
            end
          end
        end
      end
    end
  end
end
