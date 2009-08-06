require File.dirname(__FILE__) + "/spec_helper"
require 'story_command'

describe Story do
  describe "can be slurped into Pivotal Tracker" do
    it "should upload to PT new stories to PT" do
      #     @matz  = { :id => 1, :name => "Matz" }.to_xml(:root => "person")
      #     ActiveResource::HttpMock.respond_to do |mock|
      #       mock.post   "/people.xml",   {}, @matz, 201, "Location" => "/people/1.xml"
      #       mock.get    "/people/1.xml", {}, @matz
      #       mock.put    "/people/1.xml", {}, nil, 204
      #       mock.delete "/people/1.xml", {}, nil, 200
      #     end
      "http://www.pivotaltracker.com/services/v2/projects/#{@@defaults['project_id']}"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post   "/people.xml",   {}, @matz, 201, "Location" => "/people/1.xml"
      end
      document <<-EOS.gsub(/^      /, '')
      name
        This is a story
      description
        Some description
      labels
        comma,separated,labels
      ===============
      
      EOS
      Story.slurp_and_save(document)
    end
    it "should update with PT any existing stories by their name" do
      pending
    end
  end
end