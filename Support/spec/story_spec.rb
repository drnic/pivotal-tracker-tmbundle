require File.dirname(__FILE__) + '/spec_helper'
require 'story'


describe Story do

  it ".parse should return a reference to the story" do
    story = Story.new
    story.parse([""]).should == story
  end

  context "that has values for all attributes" do
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

  context "with only some values" do
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

  context "with emtpy attributes" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/fixtures/empty_attributes.txt")
      @story = Story.new.parse(story_lines)
    end

    it "should set the description to a blank string" do
      @story.description.should == ""
    end
  end
end
