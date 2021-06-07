module OrigenDocHelpers
  class ModelPageGenerator
    class << self
      attr_accessor :layout_options
      attr_accessor :layout
      attr_reader :pages
      attr_accessor :target_as_id

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
        unless options[:model]
          fail 'The following options are required: :model'
        end
        p = new(options)
        pages[options[:group]] ||= []
        pages[options[:group]] << p
        p.run
      end

      def write_index
        f = "#{Origen.root}/web/content/models.md"
        Origen.log.info "Building models index page: #{f}"
        t = Origen.compile index_page_template,
                           layout:         layout,
                           layout_options: layout_options,
                           no_group_pages: pages.delete(nil),
                           pages:          pages

        File.write(f, t)
      end

      def index_page_template
        if File.exist?("#{Origen.root}/app/")
          @index_page_template ||= "#{Origen.root!}/app/templates/model_index.md.erb"
        else
          @index_page_template ||= "#{Origen.root!}/templates/model_index.md.erb"
        end
      end
    end

    attr_reader :model

    def initialize(options)
      options = { search_box: true }.merge(options)
      @options = options
      @model = options[:model]
      @search_box = options[:search_box]
    end

    def run
      create_page(@model, top: true, breadcrumbs: [['Top', output_path]], path: output_path, origen_path: '')
    end

    def create_page(model, options = {})
      base = "#{Origen.root}/web/content/#{options[:path]}"
      output_file =  base + '.md'
      json_file =  base + '_data.json'

      Origen.log.info "Building model page: #{output_file}"
      t = Origen.compile model_page_template,
                         layout:         self.class.layout,
                         layout_options: self.class.layout_options,
                         heading:        heading,
                         search_id:      search_id,
                         model:          model,
                         breadcrumbs:    options[:breadcrumbs],
                         path:           options[:path],
                         origen_path:    options[:origen_path],
                         search_box:     @search_box

      write_out(output_file, t)
      if @search_box
        Origen.log.info "Building JSON page: #{json_file}"
        File.open(json_file, 'w') do |f|
          f.puts model.to_json
        end
      end

      model.sub_blocks.each do |name, block|
        path = options[:path] + "/#{name}"
        if options[:origen_path].empty?
          origen_path = name.to_s
        else
          origen_path = options[:origen_path] + ".#{name}"
        end
        create_page block,
                    breadcrumbs: options[:breadcrumbs] + [[name, path]],
                    path:        path,
                    origen_path: origen_path
      end
    end

    def write_out(file, content)
      d = Pathname.new(file).dirname.to_s
      FileUtils.mkdir_p(d) unless File.exist?(d)

      yaml = ''
      # Remove any frontmatter inherited from the caller's layout, this is being done via disk for
      # large files due to previous issues with sub'ing on large files that contain many registers
      File.open(file, 'w') do |f|
        frontmatter_done = false
        frontmatter_open = false
        content.each_line do |line|
          if frontmatter_done
            f.puts line
          elsif frontmatter_open
            if line =~ /^\s*---\s*$/
              frontmatter_done = true
            else
              yaml += line
            end
          else
            if line =~ /^\s*---\s*$/
              frontmatter_open = true
            elsif !line.strip.empty?
              frontmatter_done = true
            end
          end
        end
      end

      # Write out an attribute file containing the search ID to pass it to nanoc
      yaml += "search_id: model_#{id}"
      File.write(file.sub(/\.[^\.]*$/, '.yaml'), yaml)
    end

    # Returns a Pathname to a uniquely named temporary file
    def temporary_file
      # Ensure this is unique so that is doesn't clash with parallel compile processes
      Pathname.new "#{Origen.root}/tmp/model_#{id}_compiler_#{Process.pid}_#{Time.now.to_f}"
    end

    def search_id
      "model_#{id}"
    end

    def id
      if :target_as_id
        @id ||= "#{Origen.target.name.downcase}" # _#{model.class.to_s.symbolize.to_s.gsub('::', '_')}"
      else
        @id ||= model.class.to_s.symbolize.to_s.gsub('::', '_')
      end
    end

    def heading
      if :target_as_id
        @id.upcase
        # Origen.target.name.to_s.upcase
      else
        model.class.to_s
      end
    end

    def output_path
      "models/#{id}"
    end

    def model_page_template
      if File.exist?("#{Origen.root}/app/")
        @model_page_template ||= "#{Origen.root!}/app/templates/model_page.md.erb"
      else
        @model_page_template ||= "#{Origen.root!}/templates/model_page.md.erb"
      end
    end
  end
end
