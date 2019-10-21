module OrigenDocHelpers
  class DependenciesDropdownGenerator
    class << self
      def run(options={}, &block)
        to_html
      end
      
      def to_html(options={})
        unless options[:skip_dependencies_page]
          unless @generated
            puts @generated
            @generated = true
            OrigenDocHelpers::DependenciesPageGenerator.run(options[:dependencies_page_options] || {})
          end
        end
        
        html = []
        title = options[:title] || 'Dependencies'
        dependencies_url = options[:dependencies_url] || 'dependencies'
        html << "<li class=\"dropdown\">"
        html << "<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\">#{title}<b class=\"caret\"></b></a>"
        html << "<ul class=\"dropdown-menu\">"
        html << "<li><a href=\"#{Origen.generator.compiler.path(dependencies_url)}\">Dependencies</a></li>"
        html << '<li class="divider"></li>'
        OrigenDocHelpers::DependenciesPageGenerator.headings.each do |heading, opts|
          contents = opts[:method].call
          max_height = opts[:max_height] || '75vh'
          html << '<li class="dropdown-submenu">'
          html << "<a class=\"test\" tabindex=\"-1\" href=\"\"><span class=\"glyphicon glyphicon-menu-right\" style=\"float:right;\"></span> <span style=\"display: inline-block;margin-right: 20px;\">#{heading}</span> </a>"
          html << "<ul class=\"dropdown-menu\" style=\"max-height:#{max_height}; overflow-y:auto\">"
          contents.each do |c|
            if c.class.ancestors.include?(Origen::Application)
              html << "<li><a href=\"#{c.config.web_domain}\">#{c.name}</a></li>"
            else
              html << "<li><a href=\"#{c.homepage}\">#{c.name}</a></li>"
            end
          end
          html << '</ul>'
          html << '</li>'
        end
        html << "</ul>"
        html << "</li>"

        html << <<-EOT
<script>
$(document).ready(function(){
  $('head').append('<style>.dropdown-submenu{position:relative;}</style>')
  $('head').append('<style>.dropdown-submenu>.dropdown-menu{top:-75%;left:100%}</style>')
  $('head').append('<style>.dropdown-submenu:hover>.dropdown-menu{display:block;}</style>')
  $('head').append('<style>.dropdown-submenu>a{display:inline-block}</style>')
});
</script>
  EOT

        html.join("\n")
      end
    end
  end
end
