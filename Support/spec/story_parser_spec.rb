require File.dirname(__FILE__) + "/spec_helper"
require 'story_parser'

describe StoryParser do
  describe "initial story in saved file" do
    it "should return default story snippet" do
      snippet = StoryParser.new("some_story.stories").render_snippet
      snippet.should == <<-EOS.gsub(/^      /, '')
      name
      	${1:Some story}
      description
      	In order to ${10:...}
      	As a ${11:role}
      	I want ${12:${1/.*-\s(.*)$/to \\l$1/}}

      	Acceptance:
      	* ${20:do the thing
      	* don't forget the other thing}
      labels
      	${30:some_story}
      ===============
      EOS
    end
  end
  
  describe "initial story in unnamed file" do
    it "should return default story snippet" do
      snippet = StoryParser.new(nil).render_snippet
      snippet.should == <<-EOS.gsub(/^      /, '')
      name
      	${1:Name of story}
      description
      	In order to ${10:...}
      	As a ${11:role}
      	I want ${12:${1/.*-\s(.*)$/to \\l$1/}}

      	Acceptance:
      	* ${20:do the thing
      	* don't forget the other thing}
      labels
      	${30:comma,separated,labels}
      ===============
      EOS
    end
  end
  
  describe "next story in file" do
    before(:each) do
      @current_document = <<-EOS.gsub(/^      /, '')
      name
        Admin - Stories - First story
      description
        In order to achieve a goal
        As a specific person
        I want feature

        Acceptance:
        * do the thing
        * don't forget the other thing
      labels
        thingy
      ===============
      
      EOS
    end
    it "should return intelligent story snippet" do
      snippet = StoryParser.new("some_story.stories", @current_document).render_snippet
      # should default from previous story the fields:
      # * ${2:to achieve a goal}
      # * ${3:specific person}
      # * ${20:thingy}
      snippet.should == <<-EOS.gsub(/^      /, '')
      name
      	${1:Admin - ${2:Stories - ${3:First story}}}
      description
      	In order to ${10:achieve a goal}
      	As a ${11:specific person}
      	I want ${12:${1/.*-\s(.*)$/to \\l$1/}}

      	Acceptance:
      	* ${20:do the thing
      	* don't forget the other thing}
      labels
      	${30:thingy}
      ===============
      EOS
    end
  end
end