class FailureFileParser
  def initialize(filename)
    @filename = filename
  end

  def failures_from_persistence_file
    File.readlines(@filename)[2..-1].map do |l|
      l.split('|').map(&:strip)
    end.select do |file_ref|
      file_ref[1] == 'failed'
    end.map do |file_ref|
      example_name = file_ref[0]
      {
        example_id: example_name
      }
    end
  end
end