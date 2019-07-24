begin
  require 'origen_testers/atp'
rescue LoadError
  require 'atp'
end
require 'kramdown'
module OrigenDocHelpers
  class HtmlFlowFormatter < (defined?(OrigenTesters::ATP) ? OrigenTesters::ATP::Formatter : ATP::Formatter)
    include Origen::Generator::Compiler::DocHelpers::TestFlowHelpers

    attr_reader :html

    def format(node, options = {})
      @html = ''
      process(node)
      html
    end

    def on_flow(node)
      @flow ||= 0
      @flow += 1
      html << "<div class=\"panel-group\" id=\"test_flow_#{@flow}\">"
      html << _start_accordion(node.to_a[0].value)
      if node.description && !node.description.empty?
        html << to_html(node.description.join("\n"))
        html << '<hr>'
      end
      process_all(node)
      html << _stop_accordion
      html << '</div>'
    end

    def on_group(node)
      html << "<div class=\"row test-overview\">"
      html << "  <div class=\"header\">"
      html << "    <span class=\"pull-right\"><a class=\"top-link\" href=\"#\">back to top</a></span>"
      html << "    <h4 class=\"no-anchor\">#{node.to_a[0].value}</h4>"
      html << '  </div>'

      html << "<div class=\"col-md-12\" style=\"margin-bottom: 15px;\">"
      html << "  <div class=\"col-md-4\">"
      @within_test = true
      @object = ''
      on_fail = node.find(:on_fail)
      on_pass = node.find(:on_pass)
      process(on_fail) if on_fail
      process(on_pass) if on_pass
      html << @object
      @within_test = false
      html << '  </div>'
      html << "  <div class=\"col-md-8 description-pane\">"
      html << to_html(node.description.join("\n")) if node.description
      html << '  </div>'
      html << '  </div>'

      @group ||= 0
      @group += 1
      html << "<div class=\"col-md-12 panel-group\" id=\"test_group_#{@group}\">"
      html << _start_accordion('Tests')
      process_all(node.children - [on_fail, on_pass])
      html << _stop_accordion
      html << '</div>'

      html << '</div>'
    end

    def on_flow_flag(node)
      @flow_flag ||= 0
      @flow_flag += 1
      flags = [node.to_a[0]].flatten
      flags = flags.map do |flag|
        "<span class=\"label label-info\">#{flag}</span>"
      end
      if node.to_a[1]
        text = "<span class=\"connector\">IF</span>" + flags.join("<span class=\"connector\">OR</span>")
      else
        text = "<span class=\"connector\">UNLESS</span>" + flags.join("<span class=\"connector\">OR</span>")
      end
      html << "<div class=\"row test-overview\">"
      html << "<div class=\"panel-group col-md-12\" id=\"flow_flag_#{@flow_flag}\">"
      html << _start_accordion(text, panel: :warning)
      process_all(node)
      html << _stop_accordion
      html << '</div>'
      html << '</div>'
    end

    def on_run_flag(node)
      @run_flag ||= 0
      @run_flag += 1
      flags = [node.to_a[0]].flatten
      flags = flags.map do |flag|
        if flag =~ /FAILED/
          "<span class=\"label label-danger\">#{flag}</span>"
        elsif flag =~ /PASSED/
          "<span class=\"label label-success\">#{flag}</span>"
        else
          "<span class=\"label label-info\">#{flag}</span>"
        end
      end
      text = "<span class=\"connector\">IF</span>" + flags.join("<span class=\"connector\">OR</span>")
      html << "<div class=\"row test-overview\">"
      html << "<div class=\"panel-group col-md-12\" id=\"run_flag_#{@run_flag}\">"
      html << _start_accordion(text, panel: :info)
      process_all(node)
      html << _stop_accordion
      html << '</div>'
      html << '</div>'
    end

    def on_set_result(node)
      unless @within_continue
        type, *nodes = *node
        bin = node.find(:bin).try(:value)
        sbin = node.find(:softbin).try(:value)
        unless @within_test
          html << "<div class=\"row\">"
          html << "  <div class=\"col-md-4\">"
          if type == 'fail'
            html << "    <h4 class=\"no-anchor\">Set Result - FAIL</h4>"
          else
            html << "    <h4 class=\"no-anchor\">Set Result - PASS</h4>"
          end
        end
        if type == 'fail'
          html << "<span class=\"label label-danger\">Bin #{bin}</span>" if bin
          html << "<span class=\"label label-danger\">Softbin #{sbin}</span>" if sbin
        else
          html << "<span class=\"label label-success\">Bin #{bin}</span>" if bin
          html << "<span class=\"label label-success\">Softbin #{sbin}</span>" if sbin
        end
        unless @within_test
          html << '  </div>'
          html << "  <div class=\"col-md-8 description-pane\">"
          html << '  </div>'
          html << '</div>'
          html << '<hr>'
        end
      end
    end

    def on_set_run_flag(node)
      if @within_on_fail
        html << "<span class=\"label label-danger\">#{node.value}</span>"
      else
        html << "<span class=\"label label-success\">#{node.value}</span>"
      end
    end

    def on_on_fail(node)
      @within_continue = !!node.find(:continue)
      @within_on_fail = true
      process_all(node.children)
      @within_continue = false
      @within_on_fail = false
    end

    def on_continue(node)
      if @within_on_fail
        html << "<span class=\"label label-danger\">Continue</span>"
      end
    end

    def on_test(node)
      id = node.find(:id).value
      html << "<div class=\"row test-overview\" id=\"flow_#{@flow}_test_#{id}\">"
      html << "  <a class=\"anchor\" name=\"flow_#{@flow}_test_#{id}\"></a>"
      html << "  <div class=\"header\">"
      if n = node.find(:name)
        name = n.value
      else
        name = node.find(:object).value['Test']
      end
      number = node.find(:number).try(:value)
      html << "    <span class=\"pull-right\"><a class=\"list-link\" href=\"#\" data-testid=\"list_#{@flow}_test_#{id}\">view in datalog</a><span> | </span><a class=\"top-link\" href=\"#\">back to top</a></span>"
      html << "    <h4 class=\"no-anchor\">#{name}<span class=\"test-number\">#{number ? ' - ' + number.to_s : ''}</span></h4>"
      html << '  </div>'
      html << "  <div class=\"col-md-4\">"
      @within_test = true
      @object = ''
      process_all(node.children)
      html << @object
      @within_test = false
      html << '  </div>'
      html << "  <div class=\"col-md-8 description-pane\">"
      html << to_html(node.description.join("\n")) if node.description
      html << '  </div>'
      html << '</div>'
    end

    def on_object(node)
      t = node.to_a.first
      @object << "<hr><div class=\"test-attributes\">"
      if t.is_a?(String)
        @object << "<strong>Test: </strong><span>#{t}</span>"
      elsif t.is_a?(Hash)
        t.each do |key, value|
          @object << "<strong>#{key}: </strong><span>#{value}</span><br>"
        end
      end
      @object << '</div>'
    end

    # Convert the given markdown string to HTML
    def to_html(string, _options = {})
      # Escape any " that are not already escaped
      string.gsub!(/([^\\])"/, '\1\"')
      # Escape any ' that are not already escaped
      string.gsub!(/([^\\])'/, %q(\1\\\'))
      html = Kramdown::Document.new(string, input: :kramdown).to_html
    end
  end
end
