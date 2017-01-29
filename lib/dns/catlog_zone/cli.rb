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

require 'dns/catlog_zone'
require 'thor'

# The Cli class is used to catz cli application
module Dns
  module CatlogZone
    class Cli < Thor
      desc 'init', 'initializes a new environment by creating a CatlogZone'
      def init(_zonename = 'catlog.example', _type = 'file')
        unless File.exist? 'CatlogZone'
          FileUtils.cp Dns::CatlogZone.root_path + '/share/CatlogZone', 'CatlogZone'
        end
      end
      desc 'list', 'list setting'
      def list
        read_config
        puts "name\tsource\tsoftware\tzonename\n"
        @config.settings.each do |setting|
          puts "#{setting.name}\t#{setting.source}\t" \
               "#{setting.software}\t\t#{setting.zonename}\n"
        end
      end
      desc 'checkconf [setting]', 'check config'
      def checkconf(name = nil)
        read_config(name)
        @config.settings.each do |setting|
          next unless name == setting.name || name.nil?
          setting.validate(name)
        end
      end
      desc 'make [setting]', 'make config file'
      def make(name = nil)
        read_config(name)
        @config.settings.each do |setting|
          next unless name == setting.name || name.nil?
          setting.validate(name)
          catlog_zone = make_CatlogZone(setting)
          provider = make_config(setting, catlog_zone)
          output(setting, provider)
        end
      end

      private

      def read_config(name)
        @config = Dns::CatlogZone::Config.read
      end

      def make_CatlogZone(setting)
        source = Dns::CatlogZone::Source.create(setting)
        Dns::CatlogZone::CatlogZone.new(setting.zonename, source.get)
      end

      def make_config(setting, catlog_zone)
        provider = Dns::CatlogZone::Provider.create(setting)
        provider.make(catlog_zone)
        provider
      end

      def output(setting, provider)
        output = Dns::CatlogZone::Output.create(setting)
        output.output(provider.write)
      end
    end
  end
end
