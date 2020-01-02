# frozen_string_literal: true

def wait_for_condition
  Timeout.timeout(5) do
    loop do
      return if yield

      sleep 0.1
    end
  end
end
