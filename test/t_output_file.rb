require 'helper'

module Dns
  module CatlogZone
    class TestOutputFile < Minitest::Test
      def test_source_file
        setting = Setting.new('example')
        setting.output = 'file'
        setting.output_path = nil
        file = Output.create(setting)
        assert_instance_of Dns::CatlogZone::Output::File,
                           file,
                           'create output file'

        assert_raises ValidateError, 'not provide output_path ' do
          file.validate
        end
        setting.output_path = 'hogehogehoge/hogehogehoge/hogehogehoge'
        assert_raises CantOutput, 'not writable output_path ' do
          file.validate
        end
        setting.output_path = 'test.conf'
        assert file.validate, 'validate success'
      end
    end
    def teardown
      # FileUtils.rm_r 'test.conf'
    end
  end
end
