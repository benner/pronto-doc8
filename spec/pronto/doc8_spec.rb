# frozen_string_literal: true

require 'spec_helper'

module Pronto
  # rubocop:disable Metrics/BlockLength
  describe Doc8 do
    let(:doc8) { Doc8.new(patches) }
    let(:patches) { [] }
    describe '#executable' do
      subject(:executable) { doc8.executable }

      it 'is `doc8` by default' do
        expect(executable).to eql('doc8')
      end
    end

    describe 'parsing' do
      it 'filtering .rst files' do
        files = %w[
          test.py
          test.rst
        ]

        exp = doc8.filter_rst_files(files)
        expect(exp).to eq(%w[test.rst])
      end

      it 'parses a linter output to a map' do
        # rubocop:disable Layout/LineLength
        executable_output = [
          'main.rst:58: D001 Line too long',
          'index.rst:174: D005 No newline at end of file',
        ].join("\n")
        act = doc8.parse_output(executable_output)
        exp = [
          {
            file_path: 'main.rst',
            line_number: 58,
            column_number: 0,
            message: 'doc8: D001 Line too long',
            level: 'warning'

          },
          {
            file_path: 'index.rst',
            line_number: 174,
            column_number: 0,
            message: 'doc8: D005 No newline at end of file',
            level: 'warning'
          }
        ]
        # rubocop:enable Layout/LineLength
        expect(act).to eq(exp)
      end
    end

    describe '#run' do
      around(:example) do |example|
        create_repository
        Dir.chdir(repository_dir) do
          example.run
        end
        delete_repository
      end

      let(:patches) { Pronto::Git::Repository.new(repository_dir).diff('master') }

      context 'patches are nil' do
        let(:patches) { nil }

        it 'returns an empty array' do
          expect(doc8.run).to eql([])
        end
      end

      context 'no patches' do
        let(:patches) { [] }

        it 'returns an empty array' do
          expect(doc8.run).to eql([])
        end
      end

      context 'with patch data' do
        before(:each) do
          function_use = <<-PASTFILE
          // nothing
          PASTFILE

          add_to_index('test.rst', function_use)
          create_commit
        end

        context 'with error in changed file' do
          before(:each) do
            create_branch('staging', checkout: true)

            updated_function_def = <<-NEWFILE
            ####
            title
            NEWFILE

            add_to_index('bad.rst', updated_function_def)

            create_commit
            ENV['PRONTO_DOC8_OPTS'] = ''
          end

          it 'returns correct error message' do
            run_output = doc8.run
            expect(run_output.count).to eql(1)
            expect(run_output[0].msg).to eql('doc8: D000 Unexpected section title or transition.')
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
