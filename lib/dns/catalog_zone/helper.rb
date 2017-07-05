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

require 'camelizable'
require 'digest/sha1'

# add camelizable
class String
  include Camelizable
end

module Dns
  # CatalogZone module
  module CatalogZone
    class << self
      def root_path
        File.expand_path('../../../../', __FILE__)
      end

      # %s zone name
      # %h zone hash
      # %S(1) first character %S(2) second character %S(3) third character
      # %L(1) top label %L(2) second label
      # %H(1) zone name hash 1 character
      # %H(2) zone name hash 2 character
      def convert_path(format, zonename)
        mhash = Digest::SHA1.hexdigest(zonename.canonical)
        path = format.clone
        path.gsub!(/%S\(1\)/, zonename.to_s[0])
        path.gsub!(/%S\(2\)/, zonename.to_s[1])
        path.gsub!(/%S\(3\)/, zonename.to_s[2])
        path.gsub!(/%L\(1\)/, zonename.labels[zonename.labels.size - 1].to_s)
        path.gsub!(/%L\(2\)/, zonename.labels[zonename.labels.size - 2].to_s)
        path.gsub!(/%H\(1\)/, mhash[0])
        path.gsub!(/%H\(2\)/, mhash[1])
        path.gsub!(/%s/, zonename.to_s)
        path.gsub!(/%h/, mhash)
        path
      end
    end
    def host_rr?(rr)
      rr.type == Dnsruby::Types.A || rr.type == Dnsruby::Types.AAAA
    end

    def txt_rr?(rr)
      rr.type == Dnsruby::Types.TXT
    end

    def ptr_rr?(rr)
      rr.type == Dnsruby::Types.PTR
    end

    def apl_rr?(rr)
      rr.type == Dnsruby::Types.APL
    end
  end
end

module Dns
  module CatalogZone
    # ZoneHelper module
    module ZoneHelper
      def add_masters(rr, label)
        @masters[label] = Dns::CatalogZone::Master.new unless @masters[label]
        @masters[label].parse_master(rr)
      end

      def add_notifies(rr, label)
        @notifies[label] = Dns::CatalogZone::Master.new unless @notifies[label]
        @notifies[label].parse_master(rr)
      end

      def add_allow_transfers(rr, label)
        @allow_transfers[label] = Dns::CatalogZone::Prefixes.new unless @allow_transfers[label]
        @allow_transfers[label].parse_apl(rr)
      end
    end
  end
end
