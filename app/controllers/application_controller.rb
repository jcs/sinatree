class ApplicationController < App
  set :default_builder, "GroupedFieldFormBuilder"

  use Rack::Csrf, :raise => true
end
