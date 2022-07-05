#!/usr/bin/env ruby
require_relative 'base_cli'
require 'fileutils'

class ConfigCLI < BaseCLI
  CONFIG_FILE_NAME = '.env.compose'

  desc "show APP", "Show config for app"
  def show(app_name)
    config_file_path = get_config_file(app_name)
    puts File.read(config_file_path)
  end

  desc "set APP VAR1=123", "Set config variables for app"
  def set(app_name, *args)
    config_file_path = get_config_file(app_name)
    existing_vars = Dotenv.parse(config_file_path)
    args.each do |value_set|
      key, value = value_set.split(/=/)
      existing_vars[key] = value
    end
    content = existing_vars.keys.map do |key|
      "#{key}=#{existing_vars[key]}"
    end.join("\n")
    File.write(config_file_path, content)
  end

  desc "unset APP VAR1 VAR2", "Unsets config vars for app"
  def unset(app_name, *args)
    config_file_path = get_config_file(app_name)
    existing_vars = Dotenv.parse(config_file_path)
    content = existing_vars.keys.map do |key|
      "#{key}=#{existing_vars[key]}" unless args.include?(key)
    end.join("\n")
    File.write(config_file_path, content)
  end

  private

  def get_config_file(app_name)
    config_path = File.join(get_app_git_dir(app_name), CONFIG_FILE_NAME)
    FileUtils.touch(config_path) unless File.exists?(config_path)
    config_path
  end

end
