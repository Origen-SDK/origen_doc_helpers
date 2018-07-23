module OrigenDocHelpers
  # Provides an API to programatically construct an index hash as used
  # by the Searchable Documents helper -
  # http://origen-sdk.org/doc_helpers/helpers/searchable/intro/#The_Document_Index
  class GuideIndex
    def initialize
      @index = {}
      @section_keys = {}
    end

    def section(id, options = {})
      @current_section_id = id
      @section_keys[id] = options[:heading] || id.to_s
      unless @index[section_key]
        if options[:after]
          insert_after(:@index, section_key, section_key(options[:after]), {})
        elsif options[:before]
          insert_before(:@index, section_key, section_key(options[:before]), {})
        else
          @index[section_key] = {}
        end
      end
      @current_section = @index[section_key]
      yield self
      @current_section = nil
      self
    end

    def topic(id, options = {})
      unless @current_section
        fail 'topic can only be called from within a section block!'
      end
      @current_topic_id = id
      value = options[:heading] || id.to_s
      if options[:after]
        insert_after(:@current_section, topic_key, topic_key(options[:after]), value)
      elsif options[:before]
        insert_before(:@current_section, topic_key, topic_key(options[:before]), value)
      else
        @current_section[topic_key] = value
      end
      # Update the parent reference, required if before or after was used to create a new
      # @current_section hash
      @index[section_key] = @current_section
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
      "#{@current_section_id}_#{id || @current_topic_id}".to_sym
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
