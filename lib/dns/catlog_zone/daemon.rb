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
require 'optparse'
require "socket"

require 'pp'

module Dns
  module CatlogZone
    class Daemon
      class Data
        def initialize(setting)
          @setting  = setting
          @source   = Dns::CatlogZone::Source.create(setting)
          @output   = Dns::CatlogZone::Output.create(setting)
          @provider = Dns::CatlogZone::Provider.create(setting)
          @serial   = 0
          @refresh_time = 0
        end
        def refresh
          update = false
          @zone_data = @source.get
          @zone_data.each do |rr|
            if rr.type == Dnsruby::Types::SOA
              @refresh_time = Time.now.to_i = rr.refresh
              update = true if @serial > rr.serial
              @serial = rr.serial
              break
            end
          end
          if update
            catlog_zone = Dns::CatlogZone::CatlogZone.new(@setting.zonename, @zone_data)
            provider = Dns::CatlogZone::Provider.create(@setting)
            provider.make(catlog_zone)
            @output.output(provider.write)
            provider.reconfig
          end
        end
      end
      class << self
        def process_alive(pid)
          Process.getpgid(pid)
          return true
        rescue
          return false
        end

        def start
          config = { 'config' => 'CatlogZone',
                     'pidfile' => '/var/run/catz.pid',
                     'port' => 5300,
                     'listen' => '127.0.0.1'
          }
          opts = OptionParser.new
          opts.on('-c','--config CONFIG') {|s| config['config'] = s }
          opts.on('-i','--pidfile PIDFILE') {|s| config['pidfile'] = s }
          opts.on('-p','--port PORT') {|p| config['port'] = p.to_i }
          opts.on('-l','--listen IP') {|s| config['listen'] = s }
          opts.parse!(ARGV)
          begin
            daemon = Dns::CatlogZone::Daemon.new(config)
            daemon.run
          rescue
            daemon.stop
          end
        end
      end
      def initialize(config)
        @config = config
        @catlog_zones = Hash.new
      end

      def run
        if File.exist?(@config['pidfile'])
          pid = File.read(@config['pidfile']).chomp!.to_i
          if process_alive(pid)
            puts "already running daemon pid #{pid}"
            exit 0
          end
        end
        begin
          File.open(@config['pidfile'], 'w') do |pidfile|
            pidfile.puts($PROCESS_ID)
          end
        rescue
          STDERR.puts "[ERROR] pidfile #{@config['pidfile']} is not writable"
          exit 1
        end
        zone_init
        runloop
      end
      def zone_init
        data = []
        catz_config = loadConfig
        catz_config.settings.each_with_index do |setting,i|
          data[i] = Data.new(setting)
        end
        @data = data
      end
      def runloop
        loop do
          @data.each do |data|
            data.refresh
          end
          sleep 10
        end
      end

      def stop
        File.unlink(@config['p']) if File.exist?(@config['pidfile'])
      end

      def reload
        @config = Dns::CatlogZone::Config.read
      end

      def status
      end

      def log(message, priority = Syslog::LOG_WARNING)
        Syslog.open('catzd')
        Syslog.log(priority, message)
        Syslog.close
      end

      private
      def loadConfig
        catz_config = Dns::CatlogZone::Config.read(@config['config'])
        catz_config.settings.each do |setting|
          raise '[ERROR] source type is only axfr.' if setting.source != 'axfr'
          setting.validate
        end
        catz_config
      end
    end
  end
end
