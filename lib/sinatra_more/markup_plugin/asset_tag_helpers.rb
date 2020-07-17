#
# sinatra_more
# Copyright (c) 2009 Nathan Esquenazi
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

module SinatraMore
  module AssetTagHelpers

    # Creates a div to display the flash of given type if it exists
    # flash_tag(:notice, :class => 'flash', :id => 'flash-notice')
    def flash_tag(kind, options={})
      flash_text = flash[kind]
      return '' if flash_text.blank?
      options.reverse_merge!(:class => 'flash')
      content_tag(:div, flash_text, options)
    end

    # Creates a link element with given name, url and options
    # link_to 'click me', '/dashboard', :class => 'linky'
    # link_to('/dashboard', :class => 'blocky') do ... end
    # parameters: name, url='javascript:void(0)', options={}, &block
    def link_to(*args, &block)
      if block_given?
        url, options = (args[0] || 'javascript:void(0);'), (args[1] || {})
        options.reverse_merge!(:href => url)
        link_content = capture_html(&block)
        result_link = content_tag(:a, link_content, options)
        block_is_template?(block) ? concat_content(result_link) : result_link
      else
        name, url, options = args.first, (args[1] || 'javascript:void(0);'), (args[2] || {})
        options.reverse_merge!(:href => url)
        content_tag(:a, name, options)
      end
    end

    # Creates a mail link element with given name and caption
    # mail_to "me@demo.com"             => <a href="mailto:me@demo.com">me@demo.com</a>
    # mail_to "me@demo.com", "My Email" => <a href="mailto:me@demo.com">My Email</a>
    def mail_to(email, caption=nil, mail_options={})
      html_options = mail_options.slice!(:cc, :bcc, :subject, :body)
      mail_query = Rack::Utils.build_query(mail_options).gsub(/\+/, '%20').gsub('%40', '@')
      mail_href = "mailto:#{email}"; mail_href << "?#{mail_query}" if mail_query.present?
      link_to (caption || email), mail_href, html_options
    end

    # Creates a meta element with the content and given options
    # meta_tag "weblog,news", :name => "keywords"                         => <meta name="keywords" content="weblog,news">
    # meta_tag "text/html; charset=UTF-8", :http-equiv => "Content-Type"  => <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    def meta_tag(content, options={})
      options.reverse_merge!("content" => content)
      tag(:meta, options)
    end

    # Creates an image element with given url and options
    # image_tag('icons/avatar.png')
    def image_tag(url, options={})
      options.reverse_merge!(:src => image_path(url))
      tag(:img, options)
    end

    # Returns a stylesheet link tag for the sources specified as arguments
    # stylesheet_link_tag 'style', 'application', 'layout'
    def stylesheet_link_tag(*sources)
      options = sources.extract_options!.symbolize_keys
      sources.collect { |sheet| stylesheet_tag(sheet, options) }.join("\n")
    end

    # javascript_include_tag 'application', 'special'
    def javascript_include_tag(*sources)
      options = sources.extract_options!.symbolize_keys
      sources.collect { |script| javascript_tag(script, options) }.join("\n")
    end

    # Returns the path to the image, either relative or absolute
    def image_path(src)
      src.gsub!(/\s/, '')
      src =~ %r{^\s*(/|http)} ? src : File.join('/images', src)
    end

    protected

    # stylesheet_tag('style', :media => 'screen')
    def stylesheet_tag(source, options={})
      options = options.dup.reverse_merge!(:href => stylesheet_path(source), :media => 'screen', :rel => 'stylesheet', :type => 'text/css')
      tag(:link, options)
    end

    # javascript_tag 'application', :src => '/javascripts/base/application.js'
    def javascript_tag(source, options={})
      options = options.dup.reverse_merge!(:src => javascript_path(source), :type => 'text/javascript', :content => "")
      tag(:script, options)
    end

    def javascript_path(source)
      return source if source =~ /^http/
      result_path = "/javascripts/#{source.gsub(/.js$/, '')}"
      result_path << ".js" unless source =~ /\.js\w{2,4}$/
      stamp = File.exist?(result_path) ? File.mtime(result_path) : Time.now.to_i
      "#{result_path}?#{stamp}"
    end

    def stylesheet_path(source)
      return source if source =~ /^http/
      result_path = "/stylesheets/#{source.gsub(/.css$/, '')}"
      result_path << ".css" unless source =~ /\.css\w{2,4}$/
      stamp = File.exist?(result_path) ? File.mtime(result_path) : Time.now.to_i
      "#{result_path}?#{stamp}"
    end
  end
end
