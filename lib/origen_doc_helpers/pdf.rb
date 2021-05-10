module OrigenDocHelpers
  class PDF
    include Origen::Callbacks

    attr_reader :filename, :index, :root, :title

    WKHTMLTOPDF = '/run/pkg/wkhtmltopdf-/0.12.1/bin/wkhtmltopdf'

    # This is called by the searchable doc layout template
    def self.register(options)
      if options[:pdf_title] && enabled?
        @doc_pdfs ||= {}
        name = options[:pdf_title].to_s.symbolize
        @doc_pdfs[name] ||= new(options)
        @doc_pdfs[name].filename
      end
    end

    def self.enabled?
      Origen.running_on_linux? && File.exist?(WKHTMLTOPDF)
    end

    def initialize(options)
      @title = options[:pdf_title]
      @index = options[:index]
      @root = Pathname.new(options[:root])
      if @root.absolute?
        if File.exist?("#{Origen.root}/app/")
          @root = @root.relative_path_from(Pathname.new("#{Origen.root}/app/templates/web"))
        else
          @root = @root.relative_path_from(Pathname.new("#{Origen.root}/templates/web"))
        end
      end
      require 'nokogiri'
    end

    # This is a callback handler to have the PDF creation invoked prior
    # to deploying a pre-built website
    def before_deploy_site
      create
    end

    def filename
      "#{title.to_s.symbolize}-#{version}.pdf"
    end

    def create
      puts ''
      puts "Generating PDF: #{filename}..."
      puts ''
      create_topic_pages
      generate_pdf
      delete_topic_pages
    end

    def version
      Origen.app.name == :origen ? Origen.version : Origen.app.version
    end

    def generate_pdf
      cmd =  "#{WKHTMLTOPDF} --print-media-type "
      cmd += "--footer-line --footer-font-size 8 --footer-left 'Freescale Internal Use Only' --footer-right [page] "
      cmd += "--header-left '#{title} (#{version})' --header-line --header-font-size 8 "
      index.each do |topic, pages|
        dir = "#{Origen.root}/web/output/#{root}"
        if topic
          topic_dir = pages.keys.first.to_s.split('_').first
          file = "#{dir}/#{topic_dir}/topic_page.html"
          cmd += "#{file} "
        else
          pages.each do |page_path, _page_heading|
            file = "#{dir}/#{page_path}/index.html"
            cmd += "#{file} "
          end
        end
      end
      cmd += "#{pdf_output_dir}/#{filename}"
      system cmd
    end

    def pdf_output_dir
      @pdf_output_dir ||= begin
        dir = "#{Origen.root}/web/output/doc_helpers/pdfs"
        FileUtils.mkdir_p(dir) unless File.exist?(dir)
        dir
      end
    end

    def create_topic_pages
      topic_dirs do |topic, pages, topic_dir|
        topic_page = "#{topic_dir}/topic_page.html"
        page_str = "<h1>#{topic}</h1>\n"
        pages.each do |page_path, _page_heading|
          page_file = page_path.to_s.split('_').last
          page_file = "#{topic_dir}/#{page_file}/index.html"
          doc = Nokogiri::HTML(File.read(page_file))
          page_str += doc.xpath('//article').to_html
          page_str += "\n"
        end
        File.open(topic_page, 'w') do |file|
          file.puts topic_wrapper_string.sub('SUB_TOPIC_CONTENT_HERE', page_str)
        end
      end
    end

    def delete_topic_pages
      topic_dirs do |_topic, _pages, topic_dir|
        FileUtils.rm_f("#{topic_dir}/topic_page.html")
      end
    end

    def topic_dirs
      index.each do |topic, pages|
        if topic
          topic_dir = pages.keys.first.to_s.split('_').first
          topic_dir = "#{Origen.root}/web/output/#{root}/#{topic_dir}"
          yield topic, pages, topic_dir
        end
      end
    end

    def topic_wrapper_string
      if File.exist?("#{Origen.root}/app/")
        @topic_wrapper_string ||= File.read("#{Origen.root!}/app/templates/pdf/topic_wrapper.html")
      else
        @topic_wrapper_string ||= File.read("#{Origen.root!}/templates/pdf/topic_wrapper.html")
      end
    end
  end
end
