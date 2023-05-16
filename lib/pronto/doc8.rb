# frozen_string_literal: true

require 'pronto'
require 'shellwords'
require 'open3'

module Pronto
  # Main class for extracting doc8 complains
  class Doc8 < Runner
    RST_FILE_EXTENSIONS = %w[rst].freeze

    def initialize(patches, commit = nil)
      super(patches, commit)
    end

    def executable
      'doc8'
    end

    def files
      return [] if @patches.nil?

      @files ||= @patches
                 .select { |patch| patch.additions.positive? }
                 .map(&:new_file_full_path)
                 .map(&:to_s)
                 .compact
    end

    def patch_line_for_offence(path, lineno)
      patch_node = @patches.find do |patch|
        patch.new_file_full_path.to_s == path
      end

      return if patch_node.nil?

      patch_node.added_lines.find do |patch_line|
        patch_line.new_lineno == lineno
      end
    end

    def run
      if files.any?
        messages(run_doc8)
      else
        []
      end
    end

    def run_doc8 # rubocop:disable Metrics/MethodLength
      Dir.chdir(git_repo_path) do
        rst_files = filter_rst_files(files)
        files_to_lint = rst_files.join(' ')
        extra = ENV.fetch('PRONTO_DOC8_OPTS', nil)
        if files_to_lint.empty?
          []
        else
          cmd = "#{executable} #{extra} #{files_to_lint}"
          stdout, _stderr, _status = Open3.capture3(cmd)

          parse_output stdout
        end
      end
    end

    def rst?(file)
      RST_FILE_EXTENSIONS.select { |extension| file.end_with? ".#{extension}" }.any?
    end

    def filter_rst_files(all_files)
      all_files.select { |file| rst? file.to_s }
               .map { |file| file.to_s.shellescape }
    end

    def parse_output(executable_output)
      lines = executable_output.split("\n")
      lines.
        select{|line| line =~ /: D\d\d\d\s/ }.
        map { |line| parse_output_line(line) }
    end

    def parse_output_line(line)
      splits = line.strip.split(':')
      message = splits[2..].join(':').strip
      message = "doc8: #{message}"
      {
        file_path: splits[0],
        line_number: splits[1].to_i,
        column_number: 0,
        message:,
        level: violation_level(message)
      }
    end

    def violation_level(message)
        'warning'
    end

    def messages(complains)
      complains.map do |msg|
        patch_line = patch_line_for_offence(msg[:file_path],
                                            msg[:line_number])
        next if patch_line.nil?

        description = msg[:message]
        path = patch_line.patch.delta.new_file[:path]
        Message.new(path, patch_line, msg[:level].to_sym,
                    description, nil, self.class)
      end.compact
    end

    def git_repo_path
      @git_repo_path ||= Rugged::Repository.discover(File.expand_path(Dir.pwd))
                                           .workdir
    end
  end
end
