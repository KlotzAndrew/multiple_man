namespace :multiple_man do
  desc 'Run multiple man listeners'
  task worker: :environment do
    MultipleMan::Runner.new(mode: :general).run
  end

  desc 'Run multiple man producer'
  task producer: :environment do
    MultipleMan::Runner.new(mode: :produce).run_producer
  end

  desc 'Run a seeding listener'
  task seed: :environment do
    MultipleMan::Runner.new(mode: :seed).run
  end
end
