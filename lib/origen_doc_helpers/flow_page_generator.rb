module OrigenDocHelpers
  class FlowPageGenerator
    class << self
      attr_accessor :layout_options
      attr_accessor :layout
      attr_reader :pages

      def run(options)
        @pages = {}
        unless options[:layout]
          fail 'You must pass a :layout option providing an absolute path to the layout file to be used'
        end
        unless File.exist?(options[:layout].to_s)
          fail "This layout file does not exist: #{options[:layout]}"
        end
        self.layout = options.delete(:layout)
        self.layout_options = options
        yield self
        write_index unless @pages.size == 0
        @pages = nil
      end

      def page(options)
        if !options[:name] || !(options[:flow] || options[:flows]) ||
           !options[:target]
          fail 'The following options are required: :name, :flow(s), :target'
        end
        p = new(options)
        pages[options[:group]] ||= []
        pages[options[:group]] << p
        p.run
      end

      def write_index
        f = "#{Origen.root}/web/content/flows.md"
        Origen.log.info "Building flow index page: #{f}"
        t = Origen.compile index_page_template,
                           layout:         layout,
                           layout_options: layout_options,
                           no_group_pages: pages.delete(nil),
                           pages:          pages

        File.write(f, t)
      end

      def index_page_template # index page template is in doc helpers, which isn't using app/ dir
        @index_page_template ||= "#{Origen.root!}/templates/flow_index.md.erb"
      end
    end

    def initialize(options)
      @options = options
    end

    def run
      Origen.log.info "Building flow page: #{output_file}"
      t = Origen.compile flow_page_template,
                         layout:         self.class.layout,
                         layout_options: self.class.layout_options,
                         flow_template:  flow_template,
                         heading:        heading,
                         target:         @options[:target],
                         flows:          [@options[:flows] || @options[:flow]].flatten,
                         context:        @options[:context] || {}
      File.write(output_file, t)
    end

    def name
      @options[:name]
    end

    def heading
      if @options[:group]
        @options[:group] + ': ' + @options[:name]
      else
        @options[:name]
      end
    end

    def output_file
      f = @options[:name].to_s.symbolize
      "#{output_dir}/#{f}.md"
    end

    def output_path
      p = 'flows'
      if @options[:group]
        p += ('/' + @options[:group].to_s.symbolize.to_s)
      end
      p + '/' + @options[:name].to_s.symbolize.to_s
    end

    def output_dir
      d = "#{Origen.root}/web/content/flows"
      if @options[:group]
        d += ('/' + @options[:group].to_s.symbolize.to_s)
      end
      FileUtils.mkdir_p(d) unless File.exist?(d)
      d
    end

    def flow_page_template # flow page template is in doc helpers, which isn't using app/ dir
      @flow_page_template ||= "#{Origen.root!}/templates/flow_page.md.erb"
    end

    def flow_template # flow template is in doc helpers, which isn't using app/ dir
      @flow_template ||= "#{Origen.root!}/templates/shared/test/_flow.md.erb"
    end
  end
end
