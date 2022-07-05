#!/usr/bin/env ruby
require_relative 'base_cli'
require_relative 'config'
require 'fileutils'

class AppsCLI < BaseCLI
  desc "create app_name", "Create a new docco app"
  def create(app_name)
    git_dir = get_app_git_dir(app_name)
    if File.exists?(git_dir)
        puts "App already exists."
        exit 1
    end

    puts "Creating app \"#{app_name}\" … "
    FileUtils.mkdir_p(git_dir)

    puts "Initialize git repo ..."
    `git config --global init.defaultBranch main`
    `git init --bare --shared=true #{git_dir}`

    `GIT_DIR="#{git_dir}" git config receive.denyNonFastForwards false` # allow force push for branch

    # create empty config
    `touch #{git_dir}/#{ConfigCLI::CONFIG_FILE_NAME}`

    post_receive_file = File.join(git_dir,"hooks/post-receive")
    # install post receive hook
    File.write(post_receive_file, <<~SCRIPT
      #!/bin/bash
      cd #{ENV["DOCCO_HOME_DIR"]} && ./apps update "#{app_name}"
    SCRIPT
    )

    FileUtils.chmod("+x", post_receive_file)

    puts "You can now push your changes to ssh://docco@<IP>:<PORT>/git/#{app_name}"
  end

  desc "destroy APP", "Destroys an app"
  def destroy(app_name)
    git_dir = get_app_git_dir(app_name)

    unless File.exists?(git_dir)
        puts "No app #{app_name}"
        exit 1
    end

    app_dir = get_app_dir(app_name)

    if File.exists?(app_dir)
        if File.exists?(File.join(app_dir, "docker-compose.yml"))
            puts "Running docker-compose down"
            `cd #{app_dir} && sudo docker-compose down --env-file #{git_dir}/#{ConfigCLI::CONFIG_FILE_NAME} -v --remove-orphans`
        end
        puts "Removing directory"
        FileUtils.rm_rf(app_dir)
    end

    puts "Removing git dir …"
    FileUtils.rm_rf(git_dir)

    puts "App \"#{app_name}\" successfully destroyed!"
  end

  desc "update app_name", "Updates a docco app"
  def update(app_name)
    puts "Updating app \"#{app_name}\""

    app_dir = get_app_dir(app_name)
    git_dir = get_app_git_dir(app_name)

    unless File.exists?(app_dir)
      `git clone #{git_dir} #{app_dir} -b main`
    end

    unless File.exists?(app_dir)
      puts "Cloning failed …"
      exit 1
    end

    `GIT_DIR="#{app_dir}/.git" git pull origin main`

    puts "Starting app"
    `cd #{app_dir} && sudo docker-compose --env-file #{git_dir}/#{ConfigCLI::CONFIG_FILE_NAME} up -d`
  end

  desc "list", "List all apps"
  def list
    Dir.glob(File.join(ENV["DOCCO_GIT_DIR"], '*')).each {|f|
        if File.directory? f
            puts File.basename(f)
        end
    }
  end
end
