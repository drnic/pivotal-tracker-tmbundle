require "erb"
require "ostruct"
require "story"

class StoryParser
  attr_reader :document, :stories
  
  def initialize(file_path, document = "")
    if file_path && @file_name = File.basename(file_path)
      @default_label      = @file_name.split(".").first
      @default_story_name = @default_label.humanize
    else
      @default_label      = 'comma,separated,labels'
      @default_story_name = 'Name of story'
    end
    @document = document
  end
  
  def render_snippet
    story = if contains_stories?
      fields_from_last_story
    else
      default_fields
    end

    ERB.new(snippet_erb_template, nil, '-').result(story.instance_eval { binding })
  end
  
  def contains_stories?
    # last_story_in_document
    document.match(/^==*/)
  end
  
  def last_story
    stories.last
  end
  
  def stories
    @stories ||= Story.slurp(document)
  end
  
  # The extracted field values from the last_story_in_document
  # See +default_fields+ for a sample of the output
  def fields_from_last_story
    last_story
  end
  
  def default_fields
    OpenStruct.new({ :name_snippet => "${1:#{@default_story_name}}", :labels => @default_label, :biz_value => '...', :role => 'role' })
  end
  
  def snippet_erb_template
    <<-EOS.gsub(/^    /, '')
    name
    	<%= name_snippet %>
    description
    	In order to ${10:<%= biz_value %>}
    	As a ${11:<%= role %>}
    	I want ${12:${1/.*-\s(.*)$/to \\l$1/}}

    	Acceptance:
    	* ${20:do the thing
    	* don't forget the other thing}
    labels
    	${30:<%= labels %>}
    ===============
    EOS
  end
end

if $0 == __FILE__
  print StoryParser.new(ENV['TM_FILENAME'], STDIN.read).render_snippet
end
