# frozen_string_literal: true

class FailureFileParser
  def initialize(filename)
    @filename = filename
  end

  def failures_from_persistence_file
    File
      .readlines(@filename)[2..]
      .map { |l| l.split('|').map(&:strip) }
      .select { |file_ref| file_ref[1] == 'failed' }
      .map { |file_ref| { example_id: file_ref[0] } }
  end
end
