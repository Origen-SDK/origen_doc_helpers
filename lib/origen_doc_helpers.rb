require 'origen'
require_relative '../config/application.rb'

module OrigenDocHelpers
  autoload :PDF, 'origen_doc_helpers/pdf'
  autoload :HtmlFlowFormatter, 'origen_doc_helpers/html_flow_formatter'
  autoload :ListFlowFormatter, 'origen_doc_helpers/list_flow_formatter'
  autoload :FlowPageGenerator, 'origen_doc_helpers/flow_page_generator'
  autoload :ModelPageGenerator, 'origen_doc_helpers/model_page_generator'
  autoload :GuideIndex, 'origen_doc_helpers/guide_index'
  autoload :DependenciesPageGenerator, 'origen_doc_helpers/generators/dependency_page_generator'
  autoload :DependenciesDropdownGenerator, 'origen_doc_helpers/generators/dependency_dropdown_generator'
end

require 'origen_doc_helpers/helpers'

module OrigenDocHelpers
  def self.generate_flow_docs(options = {}, &block)
    FlowPageGenerator.run(options, &block)
  end

  def self.generate_model_docs(options = {}, &block)
    ModelPageGenerator.run(options, &block)
  end

  def self.generate_dependencies_doc(options = {}, &block)
    DependencyPageGenerator.run(options, &block)
  end

  def self.generate_dependencies_dropdown(options = {})
    DependenciesDropdownGenerator.run(options)
  end
  
  def self.generate_dependencies_navbar(options = {})
    DependenciesDropdownGenerator.run(options)
  end
end
