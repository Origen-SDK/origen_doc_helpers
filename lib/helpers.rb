module Origen
  class Generator
    class Compiler
      module DocHelpers
        # Helpers to create Yammer widgets
        module Yammer
          def yammer_comments(options = {})
            options = {
              prompt: 'Comment on this page'
            }.merge(options)

            options[:group_id] ||= Origen.app.config.yammer_group

            <<END
<div style="position: relative">
  <hr>
  <h4>Comments</h4>

  <div id="embedded-follow" style="position:absolute; top: 18px; left: 100px;"></div>
  <div id="embedded-feed" style="height:800px;width:600px;"></div>
</div>

<script type="text/javascript" src="https://c64.assets-yammer.com/assets/platform_embed.js"></script>

<script>
  yam.connect.actionButton({
   container: "#embedded-follow",
   network: "freescale.com",
   action: "follow"
  });
</script>

<script>
  yam.connect.embedFeed({
    container: "#embedded-feed",
    feedType: "open-graph",
    config: {
      header: false,
      footer: false,
      defaultGroupId: '#{options[:group_id]}',
      promptText: '#{options[:prompt]}'
    },
    objectProperties: {
      type: 'page',
      url: '#{current_latest_url}'
    }
  });
</script>
END
          end
        end
        include Yammer

        module Disqus
          def disqus_comments(options = {})
            options = {
              disqus_shortname: Origen.app.config.disqus_shortname || 'origen-sdk'
            }.merge(options)

            # Created this other channel in error, don't use it
            if options[:disqus_shortname].to_s == 'origensdk'
              options[:disqus_shortname] = 'origen-sdk'
            end

            <<END
<div style="position: relative">
  <hr>
  <h4>Comments</h4>
</div>
<div id="disqus_thread"></div>
<script type="text/javascript">
    /* * * CONFIGURATION VARIABLES * * */
    var disqus_shortname = '#{options[:disqus_shortname]}';
    var disqus_title;
    var disqus_url = 'http://' + window.location.hostname + window.location.pathname;

    disqus_title = $("h1").text();
    if (disqus_title.length == 0) {
      disqus_title = $("h2").text();
    }
    if (disqus_title.length == 0) {
      disqus_title = $("h3").text();
    }
    if (disqus_title.length == 0) {
      disqus_title = $("title").text();
    } else {
      disqus_title = disqus_title + ' (' + $("title").text() + ')';
    }

    /* * * DON'T EDIT BELOW THIS LINE * * */
    (function() {
        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
        dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript" rel="nofollow">comments powered by Disqus.</a></noscript>
END
          end
        end
        include Disqus

        # Helpers for the register diagrams
        module RegisterHelpers
          # Returns true if some portion of the given bits falls
          # within the given range
          def _bit_in_range?(bits, max, min)
            upper = bits.position + bits.size - 1
            lower = bits.position
            !((lower > max) || (upper < min))
          end

          # Returns the number of bits from the given bits that
          # fall within the given range
          def _num_bits_in_range(bits, max, min)
            upper = bits.position + bits.size - 1
            lower = bits.position
            [upper, max].min - [lower, min].max + 1
          end

          # Returns true if the given number is is the
          # given range
          def _index_in_range?(i, max, min)
            !((i > max) || (i < min))
          end

          def _bit_rw(bits)
            str = ''
            if bits.readable?
              str += 'readable'
            else
              str += 'not-readable'
            end
            if bits.writable?
              str += ' writable'
            else
              str += ' not-writable'
            end
            str.strip
          end

          def _max_bit_in_range(bits, max, _min)
            upper = bits.position + bits.size - 1
            [upper, max].min - bits.position
          end

          def _min_bit_in_range(bits, _max, min)
            lower = bits.position
            [lower, min].max - bits.position
          end
        end
        include RegisterHelpers

        # Helpers for the test flow documentation
        module TestFlowHelpers
          def _test_to_local_link(test)
            name = _test_name(test)
            number = _test_number(test)
            "<a href='##{name}_#{number}'>#{name}</a>"
          end

          def _test_name(test)
            test[:flow][:name] || test[:instance].first[:name]
          end

          def _test_number(test)
            flow = test[:flow]
            flow[:number] || flow[:test_number] || flow[:tnum]
          end

          def _bin_number(test)
            flow = test[:flow]
            flow[:bin] || flow[:hard_bin] || flow[:hardbin] || flow[:soft_bin] || flow[:softbin]
          end

          def _sbin_number(test)
            flow = test[:flow]
            flow[:soft_bin] || flow[:softbin]
          end

          def _start_accordion(heading, _options = {})
            @_accordion_index ||= 0
            @_accordion_index += 1
            <<-END
<div class="panel panel-default">
<a href="#_" class="expandcollapse btn btn-xs pull-right btn-default" state="0"><i class='fa fa-plus'></i></a>
<div class="panel-heading clickable" style="background:whitesmoke" data-toggle="collapse" data-parent="#blah2" href="#collapseAccordion#{@_accordion_index}">
<a class="no-underline">
#{heading}
</a>
</div>
<div id="collapseAccordion#{@_accordion_index}" class="panel-collapse collapse">
<div class="panel-body" markdown="1">

            END
          end

          def _stop_accordion
            <<-END

</div>
</div>
</div>
            END
          end

          def _start_test_flow_table
            if @_test_flow_table_open
              ''
            else
              @_test_flow_table_open = true
              <<-END
<table class="table table-condensed table-bordered flow-table">

<thead>
<tr>
<th class="col1">Test</th>
<th class="col2">Number</th>
<th class="col3">HBin</th>
<th class="col3">SBin</th>
<th class="col5">Attributes</th>
<th class="col6">Description</th>
</tr>
</thead>

<tbody>
              END
            end
          end

          def _stop_test_flow_table
            if @_test_flow_table_open
              @_test_flow_table_open = false
              <<-END

</tbody>
</table>
              END
            else
              ''
            end
          end
        end
        include TestFlowHelpers

        # Helpers for the searchable doc layout
        module SearchableHelpers
          def _doc_root_dir(options)
            f = options[:root]
            @_doc_root_dirs ||= {}
            return @_doc_root_dirs[f] if @_doc_root_dirs[f]
            unless File.exist?(f)
              f = Pathname.new("#{Origen.root}/templates/web/#{f}")
              unless f.exist?
                fail "#{options[:root]} does not exist!"
              end
            end
            f = Pathname.new(f) if f.is_a?(String)
            @_doc_root_dirs[options[:root]] = f
          end

          def _resolve_tab(options)
            tab = tab.to_s.downcase
            active = false
            if options[:tab]
              options[:tab]
            else
              rel = options[:top_level_file].relative_path_from(_doc_root_dir(options)).sub_ext('').sub_ext('').to_s
              rel.gsub(/(\/|\\)/, '_').downcase.to_sym
            end
          end

          def _root_path(options)
            root = Pathname.new("#{Origen.root}/templates/web")
            _doc_root_dir(options).relative_path_from(root)
          end
        end
        include SearchableHelpers
      end
      include DocHelpers
    end
  end
end
