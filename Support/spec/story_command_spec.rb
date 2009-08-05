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
    
  end
end