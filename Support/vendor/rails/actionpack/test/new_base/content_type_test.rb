require File.join(File.expand_path(File.dirname(__FILE__)), "test_helper")

module ContentType
  class BaseController < ActionController::Base
    def index
      render :text => "Hello world!"
    end

    def set_on_response_obj
      response.content_type = Mime::RSS
      render :text => "Hello world!"
    end

    def set_on_render
      render :text => "Hello world!", :content_type => Mime::RSS
    end
  end

  class ImpliedController < ActionController::Base
    # Template's mime type is used if no content_type is specified

    self.view_paths = [ActionView::FixtureResolver.new(
      "content_type/implied/i_am_html_erb.html.erb"         => "Hello world!",
      "content_type/implied/i_am_xml_erb.xml.erb"          => "<xml>Hello world!</xml>",
      "content_type/implied/i_am_html_builder.html.builder" => "xml.p 'Hello'",
      "content_type/implied/i_am_xml_builder.xml.builder"  => "xml.awesome 'Hello'"
    )]

    def i_am_html_erb()     end
    def i_am_xml_erb()      end
    def i_am_html_builder() end
    def i_am_xml_builder()  end
  end

  class CharsetController < ActionController::Base
    def set_on_response_obj
      response.charset = "utf-16"
      render :text => "Hello world!"
    end

    def set_as_nil_on_response_obj
      response.charset = nil
      render :text => "Hello world!"
    end
  end

  class ExplicitContentTypeTest < SimpleRouteCase
    test "default response is HTML and UTF8" do
      get "/content_type/base"

      assert_body "Hello world!"
      assert_header "Content-Type", "text/html; charset=utf-8"
    end

    test "setting the content type of the response directly on the response object" do
      get "/content_type/base/set_on_response_obj"

      assert_body "Hello world!"
      assert_header "Content-Type", "application/rss+xml; charset=utf-8"
    end

    test "setting the content type of the response as an option to render" do
      get "/content_type/base/set_on_render"

      assert_body "Hello world!"
      assert_header "Content-Type", "application/rss+xml; charset=utf-8"
    end
  end

  class ImpliedContentTypeTest < SimpleRouteCase
    test "sets Content-Type as text/html when rendering *.html.erb" do
      get "/content_type/implied/i_am_html_erb"

      assert_header "Content-Type", "text/html; charset=utf-8"
    end

    test "sets Content-Type as application/xml when rendering *.xml.erb" do
      get "/content_type/implied/i_am_xml_erb"

      assert_header "Content-Type", "application/xml; charset=utf-8"
    end

    test "sets Content-Type as text/html when rendering *.html.builder" do
      get "/content_type/implied/i_am_html_builder"

      assert_header "Content-Type", "text/html; charset=utf-8"
    end

    test "sets Content-Type as application/xml when rendering *.xml.builder" do
      get "/content_type/implied/i_am_xml_builder"

      assert_header "Content-Type", "application/xml; charset=utf-8"
    end
  end

  class ExplicitCharsetTest < SimpleRouteCase
    test "setting the charset of the response directly on the response object" do
      get "/content_type/charset/set_on_response_obj"

      assert_body   "Hello world!"
      assert_header "Content-Type", "text/html; charset=utf-16"
    end

    test "setting the charset of the response as nil directly on the response object" do
      get "/content_type/charset/set_as_nil_on_response_obj"

      assert_body   "Hello world!"
      assert_header "Content-Type", "text/html; charset=utf-8"
    end
  end
end
