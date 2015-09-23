module OrigenDocHelpers
  class DocInterface
    include OrigenTesters::Doc::Generator

    def initialize(_options = {})
    end

    def log(_msg)
    end

    def instance_name(name, options = {})
      name = pattern_name(name)
      if options[:vdd] || options[:vdd] != :nom
        name += "_#{options[:vdd]}"
      end
      name
    end

    def pattern_name(name, _options = {})
      name.to_s
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
        test = add_test name, options
        add_flow_entry(test, options)
      end
    end

    def para(name, options = {})
      options = {
        vdd:  [:min, :max],
        type: :parametric
      }.merge(options)
      vdd_loop(options) do |options|
        test = add_test name, options
        add_flow_entry(test, options)
      end
    end

    def add_pattern(name, options = {})
      options[:pattern] = pattern_name(name, options)
      options
    end

    def add_test(name, options)
      options = {
      }.merge(options)
      # Delete any keys that we don't want to assign to the instance, this keeps
      # the attributes efficient, flow control keys will be screened by Origen
      [:bin, :tnum, :tname, :continue
      ].each { |k| options.delete(k) }
      tests.add(instance_name(name, options), add_pattern(name, options))
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
