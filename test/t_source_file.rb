require 'helper'

module Dns
  module CatlogZone
    class TestSourceFile < Minitest::Test
      def test_source_file
        setting = Setting.new('example')
        setting.source = 'file'
        setting.zonefile = 'TEMP'
        setting.output_path = nil
        file = Source.create(setting)
        assert_instance_of Dns::CatlogZone::Source::File,
                           file,
                           'create source file'
        assert_raises ValidateError, 'source file not found ' do
          file.validate
        end
        setting.zonefile = 'test/zonefiles/catlog.zone'

        assert file.validate, 'validate success'
      end
    end
    def teardown
      # FileUtils.rm_r 'test.conf'
    end
  end
end
