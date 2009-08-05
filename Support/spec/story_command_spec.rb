require File.dirname(__FILE__) + "/spec_helper"
require 'story_command'

describe StoryCommand do
  describe "initial story in file" do
    it "should return default story snippet" do
      snippet = StoryCommand.new.render_snippet
      snippet.should == <<-EOS.gsub(/^      /, '')
      name
      	${1:Name of story}
      description
      	In order to ${2:...}
      	As a ${3:role}
      	I want ${4:feature}

      	Acceptance:
      	* ${10:do the thing
      	* don't forget the other thing}
      labels
      	${20:comma,separated,labels}
      ===============
      EOS
    end
  end
  
  describe "next story in file" do
    before(:each) do
      @current_document = <<-EOS.gsub(/^      /, '')
      name
        First story
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
      snippet = StoryCommand.new(@current_document).render_snippet
      # should default from previous story the fields:
      # * ${2:to achieve a goal}
      # * ${3:specific person}
      # * ${20:thingy}
      snippet.should == <<-EOS.gsub(/^      /, '')
      name
      	${1:Name of story}
      description
      	In order to ${2:achieve a goal}
      	As a ${3:specific person}
      	I want ${4:feature}

      	Acceptance:
      	* ${10:do the thing
      	* don't forget the other thing}
      labels
      	${20:thingy}
      ===============
      EOS
    end
  end
end