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

require 'pp'
module Dns
  module CatlogZone
    # The Setting class is basic config class
    class Setting
      def initialize(name)
        @attributes = { 'name' => name, 'software' => 'nsd',
                        'source' => 'file', 'output' => 'stdout',
                        'zonename' => 'catlog.example', 'zonepath' => '%s',
                        'output_path' => 'catlog.conf', 'port' => 53 }
      end

      def method_missing(method_name, *params)
        name = method_name.to_s
        if (md = name.to_s.match(/([a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9])=$/))
          @attributes[md[1]] = params[0]
        elsif name.to_s =~ /([a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9])$/
          @attributes[name]
        else
          raise ValidateError
        end
      end

      def validate
        Source.create(self).validate
        Provider.create(self).validate
        Output.create(self).validate
      end
    end

    # The Config class is aggregative config class
    class Config
      attr_reader :settings
      class << self
        def read(filename = 'CatlogZone')
          raise ConfigNotFound unless File.exist?(filename)
          config = Config.new
          config_str = ''
          File.open(filename) do |file|
            config_str = file.read
          end
          config.instance_eval config_str, filename
          config
        end
      end
      def initialize
        @settings = []
      end

      def setting(name)
        setting = Setting.new(name)
        yield(setting)
        @settings.push(setting)
      end

      def validate
        @settings.each(&:validate)
      end
    end
  end
end
