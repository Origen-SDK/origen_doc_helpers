begin
  require 'origen_testers/atp'
rescue LoadError
  require 'atp'
end
module OrigenDocHelpers
  class ListFlowFormatter < (defined?(OrigenTesters::ATP) ? OrigenTesters::ATP::Formatter : ATP::Formatter)
    attr_reader :html

    def format(node, options = {})
      @html = ''
      process(node)
      html
    end

    def open_table
      str = ''
      # str << "<table class=\"table table-striped\">"
      str << "<table class=\"table table-hover\">"
      str << '<thead><tr>'
      str << '<th>Number</th>'
      str << '<th>Result</th>'
      str << '<th>Test</th>'
      str << '<th>Pattern</th>'
      str << '<th>Bin</th>'
      str << '<th>Softbin</th>'
      str << '</tr></thead>'
      str
    end

    def close_table
      '</table>'
    end

    def on_flow(node)
      @flow ||= 0
      @flow += 1
      process_all(node)
    end

    def on_log(node)
      html << "<tr><td colspan=\"6\"><strong>LOG: </strong> #{node.value}</td></tr>"
    end

    def on_render(node)
      html << "<tr><td colspan=\"6\"><strong>RENDER: </strong> An expicitly rendered flow snippet occurs here</td></tr>"
    end

    def on_test(node)
      id = node.find(:id).value
      html << "<tr id=\"list_#{@flow}_test_#{id}\" class=\"list-test-line clickable\" data-testid=\"flow_#{@flow}_test_#{id}\">"
      html << "<td>#{node.find(:number).try(:value)}</td>"
      if node.find(:failed)
        html << '<td>FAIL</td>'
      else
        html << '<td>PASS</td>'
      end
      if n = node.find(:name)
        name = n.value
      else
        name = node.find(:object).value['Test']
      end
      html << "<td>#{name}</td>"
      html << "<td>#{node.find(:object).value['Pattern']}</td>"

      if (f1 = node.find(:on_fail)) && (r1 = f1.find(:set_result)) && (b1 = r1.find(:bin))
        html << "<td>B#{b1.value}</td>"
      else
        html << '<td></td>'
      end

      if (f2 = node.find(:on_fail)) && (r2 = f2.find(:set_result)) && (b2 = r2.find(:softbin))
        html << "<td>S#{b2.value}</td>"
      else
        html << '<td></td>'
      end

      html << '</tr>'
    end

    def on_set_result(node)
      html << '<tr>'
      html << '<td></td>'
      if node.to_a[0] == 'pass'
        html << '<td>PASS</td>'
      else
        html << '<td>FAIL</td>'
      end
      html << '<td></td>'
      html << '<td></td>'
      html << "<td>#{node.find(:bin).try(:value)}</td>"
      html << "<td>#{node.find(:softbin).try(:value)}</td>"
      html << '</tr>'
    end
  end
end
