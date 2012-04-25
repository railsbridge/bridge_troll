namespace :annotate do
  desc "Generate model annotation"
  task :generate do
    `annotate --position before --show-migration --show-indexes --exclude tests --exclude fixtures`
  end
end