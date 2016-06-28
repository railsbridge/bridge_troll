def wait_for_condition
  Timeout::timeout(5) do
    while true
      return if yield
      sleep 0.1
    end
  end
end