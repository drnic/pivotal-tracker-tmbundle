class StoryCommand
  def render_snippet
    default_snippet
  end
  
  def default_snippet
    <<-EOS.gsub(/^    /, '')
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

if $0 == __FILE__
  print StoryCommand.new.render_snippet
end