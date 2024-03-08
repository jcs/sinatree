module Sinatra
  module HTMLEscapeHelper
    def h(text)
      Rack::Utils.escape_html(text).to_s.gsub("&#x2F;", "/")
    end
  end

  class Base
    helpers Sinatra::HTMLEscapeHelper
  end
end
