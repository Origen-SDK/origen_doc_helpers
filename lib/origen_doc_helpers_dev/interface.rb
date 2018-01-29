module LinkDemo
  module TestProgram
    class Interface
      include OrigenTesters::ProgramGenerators

      def instance_name(name, options = {})
        name = pattern_name(name)
        if options[:vdd] || options[:vdd] != :nom
          name += "_#{options[:vdd]}"
        end
        name
      end

      def pattern_name(name, options = {})
        options[:pattern] || name.to_s
      end

      def vdd_loop(options)
        [options[:vdd]].flatten.each do |vdd|
          yield options.merge(vdd: vdd)
        end
      end

      def func(name, options = {})
        options = {
          vdd:  [:min, :max],
          type: :functional
        }.merge(options)
        vdd_loop(options) do |options|
          test = test_instances.functional(instance_name(name, options), options)
          test.pattern = pattern_name(name, options)
          apply_levels(test, options)
          add_flow_entry(test, options)
        end
      end

      def para(name, options = {})
        options = {
          vdd:  [:min, :max],
          type: :parametric
        }.merge(options)
        unless options[:cz]
          vdd_loop(options) do |options|
            test = test_instances.ppmu(instance_name(name, options), options)
            test.pattern = pattern_name(name, options)
            test.lo_limit = options[:lo]
            test.hi_limit = options[:hi]
            test.force_cond = options[:force] || 0
            apply_levels(test, options)
            add_flow_entry(test, options)
          end
        end
      end

      def apply_levels(test, options)
        test.dc_category = 'spec'
        test.dc_selector = options[:vdd] || :nom
      end

      def add_flow_entry(test, options)
        options = {
          number:   options[:bin] * 1000,
          soft_bin: options[:bin]
        }.merge(options)
        flow.test test, options
      end
    end
  end
end
