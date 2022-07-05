require 'bundler/setup'
require 'dotenv'
require 'thor'

Dotenv.load("#{File.dirname(__FILE__)}/../docco.env")

class BaseCLI < Thor
  class_option :verbose, :type => :boolean, :aliases => "-v"

  def self.exit_on_failure?
    false
  end

  protected

  def get_app_git_dir(app_name)
    File.join(ENV["DOCCO_GIT_DIR"], app_name)
  end

  def get_app_dir(app_name)
    File.join(ENV["DOCCO_APPS_DIR"], app_name)
  end
end
