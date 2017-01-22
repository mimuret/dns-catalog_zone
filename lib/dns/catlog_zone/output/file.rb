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

module Dns
  module CatlogZone
    module Output
      class File < Base
        def initialize(setting)
          @setting = setting
        end

        def output(str)
          File.open(@setting.output_path, 'w') do |file|
            file.print(str)
          end
        end

        def validate
          raise Dns::CatlogZone::ValidateError,
                'source type file is output_path' unless @setting.output_path
          realpath = ::File.expand_path(@setting.output_path)
          realdirpath = ::File.dirname(realpath)

          raise Dns::CatlogZone::CantOutput,
                'output_path is not writable' unless ::File.writable?(realpath) || \
                                                     ::File.writable?(realdirpath)
          true
        end
      end
    end
  end
end
