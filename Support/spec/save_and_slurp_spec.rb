require File.dirname(__FILE__) + "/spec_helper"
require 'save_and_slurp_command'
require "active_resource/http_mock"

describe Story do
  describe "can be slurped into Pivotal Tracker" do
    it "should upload to PT new stories to PT" do
      current_document = <<-EOS.gsub(/^      /, '')
      name
        This is a story
      description
        Some description
      labels
        comma,separated,labels
      ===============

      EOS
      @story = Story.slurp(current_document).first
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/services/v2/projects/123456/stories.xml", {"X-TrackerToken"=>nil}, @story.to_xml, 201,
          "Location" => "/services/v2/projects/123456/stories/789.xml"
        # mock.get    "/people/1.xml", {}, @matz
        # mock.put    "/people/1.xml", {}, nil, 204
        # mock.delete "/people/1.xml", {}, nil, 200
      end
      command = SaveAndSlurpCommand.new("some_file.stories", current_document)
      command.save
      command.tooltip_output.should == "1 created. 0 updated."
    end
    
    it "should update with PT any existing stories by their name" do
      pending
    end
    
    def create_story
      current_document = <<-EOS.gsub(/^      /, '')
      name
        This is a story
      description
        Some description
      labels
        comma,separated,labels
      ===============

      EOS
      Story.slurp(current_document).first
    end
  end
end