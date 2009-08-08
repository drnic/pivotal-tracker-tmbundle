require "story_parser"

class SaveAndSlurpCommand
  attr_reader :story_parser
  
  def initialize(file_path, project_path, document)
    Story.story_defaults(project_path)
    @story_parser = StoryParser.new(file_path, document)
  end
  
  def save
    @results = {}
    stories.each do |story|
      # story - see if it already exists by name
      if story.save
        # TODO - :created vs :updated
        @results[:created] ||= 0
        @results[:created] += 1
      else
        @results[:errors] ||= 0
        @results[:errors] += 1
      end
    end
  end
  
  def stories
    story_parser.stories
  end
  
  def tooltip_output
    output = "#{@results[:created] || 0} created. #{@results[:updated] || 0} updated."
    output += " #{@results[:errors]}  errors." if @results[:errors]
    output
  end
end

if __FILE__ == $PROGRAM_NAME
  command = SaveAndSlurpCommand.new(ENV['TM_FILENAME'], ENV['TM_PROJECT_DIRECTORY'], STDIN.read)
  command.save
  print command.tooltip_output
end