# This code comes from Hashrocket's story slurper
# Les told me I can use it here.

# ruby19 needs latest patches for use_ssl? 
# but let's use all its awesomeness anyway
$:.unshift(File.dirname(__FILE__) + "/../vendor/rails/activeresource/lib")
$:.unshift(File.dirname(__FILE__) + "/../vendor/rails/activesupport/lib")
begin
  require 'activeresource'
  require "active_support/core_ext/string/inflections"
  require "active_support/core_ext/hash/conversions"
rescue LoadError => e
  raise "You need to pull down Support/vendor/rails"
end

class Story < ActiveResource::Base

  # TODO - pop up a dialog to collect project PT details + store in story_defaults.yml file
  @@defaults = {"token" => "some_token"} #YAML.load_file('story_defaults.yml')
  self.site = "http://www.pivotaltracker.com/services/v2/projects/123456"
  headers['X-TrackerToken'] = @@defaults.delete("token")
  attr_accessor :story_lines

  def self.slurp(document)
    story_lines = []
    stories = []
    document.split(/\n/).each do |line|
      if line[0,2] != "=="
        story_lines << line
      else
        stories << Story.new.parse(story_lines)
        story_lines.clear
      end
    end
    stories
  end

  def initialize(attributes = {})
    @attributes     = {}
    @prefix_options = {}
    load(@@defaults.merge(attributes))
  end

  def parse(story_lines)
    @story_lines = story_lines
    @attributes["name"] = find_name
    if @attributes["description"] = find_description
      @attributes["biz_value"] = find_biz_value
      @attributes["role"] = find_role
      @attributes["feature"] = find_feature
      @attributes["description"].gsub!("\n\n", "\n")
    else
      @attributes["description"] = "In order to \nAs a \nI want \n\nAcceptance:\n* "
      @attributes["biz_value"] = "..."
      @attributes["role"] = "role"
      @attributes["feature"] = "feature"
    end
    @attributes["labels"] = find_labels || "slurper"
    self
  end
  
  # "name"                  => "${1:name}"
  # "name1 - name2"         => "${1:name1 - ${2:name2}"
  # "name1 - name2 - name3" => "${1:name1 - ${2:name2 - ${3:name3}}"
  def name_snippet
    name_bits = name.split(/ - /)
    count = name_bits.size
    name_bits.reverse.inject("") do |bits, name_chunk|
      if bits.blank? 
        bits = "${#{count}:#{name_chunk}}"
      else
        bits = "${#{count}:#{name_chunk} - #{bits}}"
      end
      count -= 1
      bits
    end
  end
  
  private

  def find_name
    @story_lines.each_with_index do |line, i|
      return @story_lines[i+1].strip if start_of_attribute?(line, 'name')
    end
  end

  def find_description
    @story_lines.each_with_index do |line, i|
      if start_of_attribute?(line, 'description')
        desc = Array.new
        while((next_line = @story_lines[i+=1]) && starts_with_whitespace?(next_line)) do
          desc << next_line.gsub("\t", "")
        end
        return desc.join("\n")
      end
    end
    nil
  end

  def find_labels
    @story_lines.each_with_index do |line, i|
      return @story_lines[i+1].strip if start_of_attribute?(line, 'labels') && @story_lines[i+1]
    end
    nil
  end
  
  def find_biz_value
    if match = @attributes["description"].match(/In order to (.*)$/)
      match[1]
    else
      "..."
    end
  end
  
  def find_role
    if match = @attributes["description"].match(/As an? (.*)$/)
      match[1]
    else
      "role"
    end
  end
  
  def find_feature
    if match = @attributes["description"].match(/I want (.*)$/)
      match[1]
    else
      "feature"
    end
  end

  def starts_with_whitespace?(line)
    line[0,1] =~ /\s/
  end

  def start_of_attribute?(line, attribute)
    line[0,attribute.size] == attribute
  end

end
