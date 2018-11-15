class ApplicationController < App
  use Rack::Csrf, :raise => true
end
