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

# add camelizable
class String
  include Camelizable
end

module Dns
  # CatlogZone module
  module CatlogZone
    class << self
      def root_path
        File.expand_path('../../../../', __FILE__)
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
  module CatlogZone
    # ZoneHelper module
    module ZoneHelper
      def add_masters(rr, label)
        @masters[label] = Dns::CatlogZone::Master.new unless @masters[label]
        @masters[label].parse_master(rr)
      end

      def add_notifies(rr, label)
        @notifies[label] = Dns::CatlogZone::Master.new unless @notifies[label]
        @notifies[label].parse_master(rr)
      end

      def add_allow_transfers(rr, label)
        @allow_transfers[label] = Dns::CatlogZone::Prefixes.new unless @allow_transfers[label]
        @allow_transfers[label].parse_apl(rr)
      end
    end
  end
end
