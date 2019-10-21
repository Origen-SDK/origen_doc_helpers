module OrigenDocHelpers
  class DependenciesPageGenerator
    class << self
      def run(options={})
        generate_content(options)
      end

      def generate_content(options={})
        def to_html(content, spacing_adjust=0)
          @spacing += (@spacing_width * spacing_adjust)
          @html << (' ' * @spacing) + content
        end
        
        @html = []
        @spacing = options[:initial_spacing] || 0
        @spacing_width = options[:spacing_width] || 2
        @tmp_output = Origen.app.root.join('tmp/origen_doc_helpers/dependencies.md.erb')
        @output = "#{Origen.root}/web/content/#{options[:path]}/dependencies.md"
    	  panel_name = options.delete(:title) || "Dependencies"
    	  collapse_id = options[:collapse_id] || Random.rand(1..2**16) 
    	  
    	to_html("% render \"#{Origen.root.join('templates/web/layouts/_basic.html.erb')}\" do")
    	to_html('<h1>Dependencies</h1>')
    	to_html('<hr>')
    	  to_html('<div class="panel-group" id="origen_doc_helpers_dependency_page_generator">')
    	    to_html('<div class="panel panel-default">', 1)
    	      to_html('<div class="panel-heading">', 1)
    	        to_html('<h4 class="panel-title">', 1)
    	          to_html('<a data-toggle="collapse" href="#collapse_' + "#{collapse_id}" + '">' + panel_name + '</a>', 1)
    	        to_html('</h4>', -1)
    	      to_html('</div>', -1)
    	      to_html('<div id="collapse_' + "#{collapse_id}" + '" class="panel-collapse collapse">')
    	        to_html('<ul class="list-group">', 1)
              order.each do |heading|
                to_html('<li class="list-group-item">', 1)
                  to_html('<div class="panel panel-default">', 1)
                    to_html('<div class="panel-heading">', 1)
                      to_html('<h4 class="panel-title">', 1)
                        to_html("<a data-toggle=\"collapse\" href=\"#collapse_#{collapse_id}_#{heading.object_id}\">#{heading}</a>", 1)
                      to_html('</h4>', -1)
                      to_html("<p>#{headings[heading][:description]}</p>", 1)
                    to_html('</div>', -1)
                    to_html("<div id=\"collapse_#{collapse_id}_#{heading.object_id}\" class=\"panel-collapse collapse\">")
                      to_html("<div class='panel-body'>", 1)
                      contents = headings[heading][:method].call
                      to_html('<ul class="list-group">')
                        contents_for(heading, update_seen: true, unseen_only: true).each do |c|
                          to_html('<li class="list-group-item">', 1)
                            to_html('<div class="panel panel-default">', 1)
                              to_html('<div class="panel-heading">', 1)
                                to_html('<h4 class="panel-title">' + "#{c.name} (#{c.version})" + '</h4>', 1)
                              to_html('</div>', -1)
                              to_html("<div class='panel-body'>", 1)
                                if c.class.ancestors.include?(Origen::Application)
                                  to_html("<p>Summary: #{Gem.loaded_specs[c.name.to_s].summary}</p>")
                                  to_html("<p><a href='#{c.config.web_domain}'>Homepage: #{c.config.web_domain}</a></p>")
                                  to_html("<p>RC URL: #{c.config.rc_url}</p>")
                                else
                                  to_html("<p>Summary: #{c.summary}</p>")
                                  to_html("<p><a href='#{c.homepage}'>Homepage: #{c.homepage}</a></p>")
                                end
                              to_html('</div>', -1)
                            to_html('</div>', -1)
                          to_html('</li>', -1)
                        end
                      to_html("</ul>", -1)
                      to_html('</div>', -1)
                    to_html('</div>', -1)
                  to_html('</div>', -1)
                to_html('</li>', -1)
                #to_html('', -1)
              end
    	        to_html('</ul>', -1)
    	      to_html('</div>', -1)
    	    to_html('</div>', -1)
    	  to_html('</div>', -1)
    	  @html << '% end'
    	#to_html('% end', -1)
    	  
    	  unless Dir.exist?(@tmp_output.dirname)
    	    FileUtils.mkdir_p(@tmp_output.dirname)
    	  end
        File.open(@tmp_output, 'w') { |f| f.puts(@html.join("\n")) }

        out = Origen.compile(@tmp_output, heading: panel_name)
        File.open(@output, 'w') { |f| f.puts(out) }

        # Collect all the dependencies
        
        # First, see if the user passed in any custom headings. Display these first.
        
        # Display all pattern libraries, defined here as containing a 'shared' hash
        # in the config/application.rb with either a 'patterns' or 'lists' heading.
        # In the event of any customized lists, add a checkbox to hide previously
        # shown plugins.
        
        # Next display all Origen plugins, with a pre-checked checkbox to hide
        # previously shown plugins.
        # Origen plugins are defined as inheriting from Origen::Application
        
        # Display the Origen Core, by itself.
        
        # Finally, display a collapsed list of all dependencies, with a
        # pre-checked checkbox to hide those previously seen.
      end
      
      def headings(options = {})
        @headings ||= {
          'Pattern Libraries' => {
            method: lambda do
              Origen.app.plugins.select { |pl| pl.config.shared && (pl.config.shared[:patterns] || pl.config.shared[:lists]) }
            end,
            description: 'Plugins containing shared patterns, flows, and/or lists.'
          },
          'Origen Plugins' => {
            method: lambda { Origen.app.plugins },
            description: 'Dependencies which are registered as Origen plugins within the application.',
          },
          'Origen' => { 
            method: lambda { [Gem.loaded_specs['origen']] },
            description: 'Origen Core',
          },
        }.merge(options[:headings] || {})
      end
      
      def gems
        @gems ||= Gem.loaded_specs.keys.map(&:to_sym)
      end
      
      def seen_gems        
        @seen_gems ||= gems.map { |g| [g, false] }.to_h
      end
            
      def order(options = {})
        headings.keys
        #@order ||= headings.keys.reject { |h| DEFAULT_HEADING.include?(h) } + DEFAULT_HEADINGS.keys
      end
      
      def contents_for(header, update_seen: false, unseen_only: false)
        contents = headings[header][:method].call
        if unseen_only
          contents = contents.reject { |c| seen_gems[c.name] }
        end
        if update_seen
          contents.each do |g|
            if g.respond_to?(:name)
              seen_gems[g.name] = true
            else
              Origen.log.error "Error when processing contents for #{heading}: Block returned object #{g.name} which does not respond to :name"
            end
          end
        end
        contents
      end

    end
  end
end
