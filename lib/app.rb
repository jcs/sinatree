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

Encoding.default_internal = Encoding.default_external = Encoding::UTF_8

APP_ROOT = File.realpath(File.dirname(__FILE__) + "/../")

require "sqlite3"
require "active_record"

require "sinatra/base"
require "sinatra/namespace"
require "cgi"

require "sinatra/activerecord"
require "sinatra/namespace"

class Sinatra::Base
  register Sinatra::Namespace
  register Sinatra::ActiveRecordExtension

  set :root, File.realpath(__dir__ + "/../")

  def self.cur_controller
    raise
  rescue => e
    e.backtrace.each do |z|
      if m = z.match(/app\/controllers\/(.+?)_controller\.rb:/)
        return m[1]
      end
    end

    nil
  end

  # app/views/(controller)/
  set :views, Proc.new { App.root + "/app/views/#{cur_controller}/" }

  # app/views/layouts/(controller).erb or app/views/layouts/application.erb
  set :erb, :layout => Proc.new {
    @@layouts ||= {}
    cc = cur_controller

    if File.exists?(f = App.root + "/app/views/layouts/#{cc}.erb")
      @@layouts[cc] ||= File.read(f)
    else
      @@layouts["application"] ||= File.read(App.root +
        "/app/views/layouts/application.erb")
    end
  }

  configure do
    enable :logging

    # allow erb views to be named view.html.erb
    Tilt.register Tilt::ERBTemplate, "html.erb"
  end

  singleton_class.send(:alias_method, :env, :environment)
end

class App < Sinatra::Base
end

if ENV["APP_ENV"]
  App.env = ENV["APP_ENV"]
end

# bring in models
require "#{App.root}/lib/db.rb"
require "#{App.root}/lib/db_model.rb"
Dir.glob("#{App.root}/app/models/*.rb").each{|f| require f }

# and helpers
require "#{App.root}/lib/helpers.rb"
Dir.glob("#{App.root}/app/helpers/*.rb").each do |f|
  mc = Module.constants
  require f
  (Module.constants - mc).each do |m|
    App.helpers Kernel.const_get(m.to_s)
  end
end

# and controllers
(
  [ "#{App.root}/app/controllers/application_controller.rb" ] +
  Dir.glob("#{App.root}/app/controllers/*.rb")
).uniq.each do |f|
  mc = Module.constants
  require f
  (Module.constants - mc).each do |m|
    App.use Kernel.const_get(m.to_s)

    # each controller auto-loads its helper
    if Kernel.const_defined?(c = m.to_s.gsub(/Controller$/, "Helper"))
      Kernel.const_get(m.to_s).send(:helpers, Kernel.const_get(c))
    end
  end
end

# and extras
Dir.glob("#{App.root}/app/extras/*.rb").each{|f| require f }

Db.connect(environment: App.env.to_s)
