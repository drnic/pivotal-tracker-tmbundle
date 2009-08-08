require File.dirname(__FILE__) + "/spec_helper"
require 'save_and_slurp_command'
require "active_resource/http_mock"

describe Story do
  describe "can be slurped into Pivotal Tracker" do
    before(:each) do
      Story.reset_defaults
      @command = SaveAndSlurpCommand.new("full_story.txt", 
        File.dirname(__FILE__) + "/fixtures", 
        File.read(File.dirname(__FILE__) + "/fixtures/full_story.txt"))

      @story = @command.stories.first
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/services/v2/projects/1234/stories.xml", {"X-TrackerToken" => "975ff69df5eead"}, 
          @story.to_xml, 201, "Location" => "/services/v2/projects/1234/stories/789.xml"
      end
      @command.save
    end
    
    it "should create stories" do
      @command.results[:created].should == 1
    end
    
    it "should not update any stories" do
      @command.results[:updated].should be_nil
    end
    
    it "should not have any errors" do
      @command.results[:errors].should be_nil
    end
    
    it "should show interesting tooltip" do
      current_document = <<-EOS.gsub(/^      /, '')
      name
        This is a story
      description
        Some description
      labels
        comma,separated,labels
      ===============

      name
        This is another story
      description
        Some description
      labels
        comma,separated,labels
      ===============

      EOS
      @story = Story.slurp(current_document).first
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/services/v2/projects/1234/stories.xml", {"X-TrackerToken" => "975ff69df5eead"}, 
          @story.to_xml, 201, "Location" => "/services/v2/projects/1234/stories/789.xml"
        # mock.get    "/people/1.xml", {}, @matz
        # mock.put    "/people/1.xml", {}, nil, 204
        # mock.delete "/people/1.xml", {}, nil, 200
      end
      command = SaveAndSlurpCommand.new("some_file.stories", File.dirname(__FILE__) + "/fixtures", 
        current_document)
      command.save
      command.tooltip_output.should == "2 created. 0 updated."
    end
  end
end