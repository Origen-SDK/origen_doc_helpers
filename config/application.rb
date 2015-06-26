require "origen"
class OrigenDocHelpersApplication < Origen::Application

  config.name     = "Origen Documentation Helpers"
  config.initials = "OrigenDocHelpers"
  config.rc_url   = "git@github.com:Origen-SDK/origen_doc_helpers"
  config.release_externally = true
  # To enable deployment of your documentation to a web server (via the 'origen web'
  # command) fill in these attributes.
  config.web_directory = "git@github.com:Origen-SDK/Origen-SDK.github.io.git/doc_helpers"
  config.web_domain = "http://origen-sdk.org/doc_helpers"

  config.semantically_version = true

  config.lint_test = {
    # Require the lint tests to pass before allowing a release to proceed
    :run_on_tag => true,
    # Auto correct violations where possible whenever 'origen lint' is run
    :auto_correct => true, 
    # Limit the testing for large legacy applications
    #:level => :easy,
    # Run on these directories/files by default
    #:files => ["lib", "config/application.rb"],
  }

  # To automatically deploy your documentation after every tag use this code
  def after_release_email(tag, note, type, selector, options)
    command = "origen web compile --remote"
    Dir.chdir Origen.root do
      system command
    end
  end

end
