# frozen_string_literal: true

def assert_no_rows_present
  rows = {}
  total = 0
  ActiveRecord::Base.send(:subclasses).each do |sc|
    next if sc.name == 'ActiveRecord::SchemaMigration'

    rows[sc.name] = sc.all.size
    total += sc.all.size
  end
  if total > 0
    puts 'Leaked the following rows: '
    rows.each do |klass, count|
      next unless count > 0

      puts "#{klass}: #{count}"
    end
    expect(total).to eq(0)
  end
end
