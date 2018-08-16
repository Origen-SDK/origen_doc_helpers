module OrigenDocHelpers
  # Provides an API to programatically construct an index hash as used
  # by the Searchable Documents helper -
  # http://origen-sdk.org/doc_helpers/helpers/searchable/intro/#The_Document_Index
  class GuideIndex
    def initialize
      @index = {}
      @section_keys = {}
      @pending_sections = []
      @pending_pages = []
    end

    # Force any pending sections and pages into the index, these will be added
    # at the end since their :after/:before reference is not valid
    def force_pending
      @force_pending = true
      @pending_sections.each do |id, opts, blk|
        section(id, opts, &blk)
      end
      @pending_pages.each do |section_id, id, opts|
        @current_section_id = section_id
        @current_section = @index[section_key]
        page(id, opts)
      end

      @force_pending = nil
      self
    end

    def section(id, options = {}, &block)
      @current_section_id = id
      if options[:heading]
        # This is to handle the corner case where an id reference was originally supplied
        # without the heading, then a later reference added the heading
        if @section_keys[id]
          if @section_keys[id] != options[:heading]
            change_key(:@index, @section_keys[id], options[:heading])
            @section_keys[id] = options[:heading]
          end
        else
          @section_keys[id] = options[:heading]
        end
      else
        @section_keys[id] ||= id
      end
      @section_keys[id] ||= @section_keys[id].to_s if @section_keys[id]
      section_pending = false
      unless @index[section_key]
        if options[:after] && !@force_pending
          if has_key?(:@index, section_key(options[:after]))
            insert_after(:@index, section_key, section_key(options[:after]), {})
          else
            @pending_sections << [id, options.dup, block] unless @no_pending
            section_pending = true
          end
        elsif options[:before] && !@force_pending
          if has_key?(:@index, section_key(options[:before]))
            insert_before(:@index, section_key, section_key(options[:before]), {})
          else
            @pending_sections << [id, options.dup, block] unless @no_pending
            section_pending = true
          end
        else
          @index[section_key] = {}
        end
      end
      @current_section = @index[section_key]
      yield self unless section_pending
      @current_section = nil

      # See if any pending sections can now be inserted
      unless @no_pending || @force_pending
        @pending_sections.each do |id, opts, blk|
          @no_pending = true
          section(id, opts, &blk)
          @no_pending = false
        end
      end
      self
    end

    def page(id, options = {})
      unless @current_section
        fail 'page can only be called from within a section block!'
      end
      @current_topic_id = id
      value = options[:heading] || id
      value = value.to_s if value
      page_pending = false
      if options[:after] && !@force_pending
        if has_key?(:@current_section, topic_key(options[:after]))
          insert_after(:@current_section, topic_key, topic_key(options[:after]), value)
        else
          @pending_pages << [@current_section_id, id, options.dup] unless @no_page_pending
          page_pending = true
        end
      elsif options[:before] && !@force_pending
        if has_key?(:@current_section, topic_key(options[:before]))
          insert_before(:@current_section, topic_key, topic_key(options[:before]), value)
        else
          @pending_pages << [@current_section_id, id, options.dup] unless @no_page_pending
          page_pending = true
        end
      else
        @current_section[topic_key] = value
      end
      # Update the parent reference, required if before or after was used to create a new
      # @current_section hash
      @index[section_key] = @current_section unless page_pending

      # See if any pending pages can now be inserted
      unless @no_page_pending || @force_pending
        @pending_pages.each do |section_id, id, opts|
          @no_page_pending = true
          page(id, opts)
          @no_page_pending = false
        end
      end

      self
    end

    def to_h
      @index
    end

    private

    def section_key(id = nil)
      @section_keys[id || @current_section_id]
    end

    def topic_key(id = nil)
      if @current_section_id
        "#{@current_section_id}_#{id || @current_topic_id}".to_sym
      else
        "#{id || @current_topic_id}".to_sym
      end
    end

    def has_key?(var, id)
      instance_variable_get(var).key?(id)
    end

    def change_key(var, existing, new)
      h = {}
      instance_variable_get(var).each do |key, val|
        if key == existing
          h[new] = val
        else
          h[key] = val
        end
      end
      instance_variable_set(var, h)
    end

    def insert_after(var, id, after, value)
      new = {}
      instance_variable_get(var).each do |key, val|
        new[key] = val
        if key == after
          new[id] = value
        end
      end
      instance_variable_set(var, new)
    end

    def insert_before(var, id, before, value)
      new = {}
      instance_variable_get(var).each do |key, val|
        if key == before
          new[id] = value
        end
        new[key] = val
      end
      instance_variable_set(var, new)
    end
  end
end
