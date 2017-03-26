require 'yaml'
require_relative 'db/config'

namespace 'slides' do
  desc 'create a new slide at location'
  task :new, [:slide_name, :slide_num] do |_t, args|
    re = /(\d{1,2})_([\S]+)/
    name = args[:slide_name]
    num = args[:slide_num].to_i
    Dir['./content/*.yml'].each do |file_name|
      match = file_name.match(re)
      if match[1].to_i >= num
        content = YAML.load(File.read(file_name))
        content['position'] = content['position'].to_i + 1
        File.delete(file_name)
        File.write(
          "./content/#{content['position']}_#{match[2]}",
          content.to_yaml
        )
      end
      new_slide = { 'name' => name, 'position' => num }
      File.write("./content/#{num}_#{name}.yml", new_slide.to_yaml)
    end
  end
end

namespace 'db' do
  require 'sequel'
  Sequel.extension :migration
  DB = Sequel.connect(Database.url(ENV['HACK_ENV'] || 'dev'))

  desc 'Run migrations'
  task :migrate, [:version] do |_t, args|
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(DB, 'db/migrations', target: args[:version].to_i)
    else
      puts 'Migrating to latest'
      Sequel::Migrator.run(DB, 'db/migrations')
    end
  end

  desc 'Prints current schema version'
  task :version do
    version = if DB.tables.include?(:schema_info)
                DB[:schema_info].first[:version]
              end || 0

    puts "Schema Version: #{version}"
  end

  desc 'Perform rollback to specified target or full rollback as default'
  task :rollback, :target do |_t, args|
    args.with_defaults(target: 0)

    Sequel::Migrator.run(DB, 'db/migrations', target: args[:target].to_i)
    Rake::Task['db:version'].execute
  end

  desc 'Perform migration reset (full rollback and migration)'
  task :reset do
    Sequel::Migrator.run(DB, 'db/migrations', target: 0)
    Sequel::Migrator.run(DB, 'db/migrations')
    Rake::Task['db:version'].execute
  end
end

def mode(arg)
  mode = arg
  mode = 'dev' if mode.nil? || mode.strip.empty?
  mode.to_sym
end
