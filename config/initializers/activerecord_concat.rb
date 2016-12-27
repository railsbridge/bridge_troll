# https://gist.github.com/eric1234/5622690
module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def concat(*args)
        args * " || "
      end
    end

    class PostgreSQLAdapter < AbstractAdapter
      def concat(*args)
        "CONCAT(#{args * ', '})"
      end
    end
  end
end