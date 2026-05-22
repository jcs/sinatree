#
# Copyright (c) 2017-2018 joshua stein <jcs@jcs.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

# rake db:create_migration NAME=...
require "active_record"

namespace :db do
  task :load_config do
    require "./lib/app.rb"
  end
end

load "active_record/railties/databases.rake"

ActiveRecord::Tasks::DatabaseTasks.tap do |config|
  config.root = Rake.application.original_dir
  config.env = ENV["APP_ENV"] || ENV["RACK_ENV"] || "development"
  config.db_dir = "db"
  config.migrations_paths = ["db/migrate"]
  config.database_configuration = ActiveRecord::Base.configurations
end

Rake::Task["db:load_config"].clear
Rake::Task.define_task("db:environment")
if Rake::Task.task_defined?("db:test:deprecated")
  Rake::Task["db:test:deprecated"].clear
end

require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.pattern = "spec/*_spec.rb"
end

task :default => [ :test ]
