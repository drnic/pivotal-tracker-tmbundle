require File.dirname(__FILE__) + '/spec_helper'
require 'story'


describe Story do

  it ".parse should return a reference to the story" do
    story = Story.new
    story.parse([""]).should == story
  end

  describe "that has values for all attributes" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/fixtures/full_story.txt")
      @story = Story.new.parse(story_lines)
    end

    it "parses the name correctly" do
      @story.name.should == 'Profit'
    end

    it "parses the description correctly" do
      @story.description.should == <<-EOS.gsub(/^      /, '')
      In order to become wealthy
      As a stakeholder
      I want the complex things to happen quickly and cheaply
      
      Acceptance:
      * do the thing
      * don't forget the other thing
      * remember something else
      EOS
    end

    it "parses the label correctly" do
      @story.labels.should == "money,power,fame"
    end

    it "parses the biz_value correctly" do
      @story.biz_value.should == "become wealthy"
    end

    it "parses the role correctly" do
      @story.role.should == "stakeholder"
    end

    it "parses the feature correctly" do
      @story.feature.should == "the complex things to happen quickly and cheaply"
    end
  end

  describe "with only some values" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/fixtures/name_only.txt")
      @story = Story.new.parse(story_lines)
    end

    it "should use the default value for the description" do
      @story.description.should == "In order to \nAs a \nI want \n\nAcceptance:\n* "
    end

    it "should use the default value for the labels" do
      @story.labels.should == "slurper"
    end
  end

  describe "with emtpy attributes" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/fixtures/empty_attributes.txt")
      @story = Story.new.parse(story_lines)
    end

    it "should set the description to a blank string" do
      @story.description.should == ""
    end
  end
  
  describe "story_defaults" do
    describe "when already available" do
      before(:each) do
        FileUtils.chdir File.dirname(__FILE__) + "/fixtures" do
          Story.reset_defaults
          @defaults = Story.story_defaults
        end
      end
      it "should load and populate" do
        @defaults.should_not be_nil
      end

      it "should have project_id" do
        @defaults["project_id"].should == 1234
      end

      it "should have token" do
        Story.headers['X-TrackerToken'].should == "975ff69df5eead"
      end

      it "could have default requested_by" do
        @defaults["requested_by"].should == "Dr Nic"
      end

      it "could have default labels" do
        @defaults["labels"].should == "slurper_default"
      end

      it "could have default name" do
        @defaults["name"].should == "Untitled"
      end

      it "could have default description" do
        @defaults["description"].should == "In order to \nAs a \nI want \n\nAcceptance:\n* "
      end
    
      it "should have site url" do
        Story.site.to_s.should == "http://www.pivotaltracker.com/services/v2/projects/1234"
      end

      it "should inform that story_defaults.yml is available" do
        Story.has_story_defaults?.should be_true
      end
    end
    describe "unavailable" do
      before(:each) do
        Story.reset_defaults
        Story.story_defaults
      end
      it "should inform that no story_defaults.yml is available" do
        Story.has_story_defaults?.should be_false
      end

      # TODO - move this to the slurper command
      it "should create a story_defaults.yml in the project" do
        # ask "Should I create a story_defaults.yml in /path/to/story_defaults.yml?"
        # then do nothing
      end
    end
  end
end
