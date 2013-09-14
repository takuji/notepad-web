require 'bundler/capistrano'

set :stages, %w(production staging)
set :default_stage, "production"
require 'capistrano/ext/multistage'

set :application, "notepad"
set :repository,  "."
set :local_repository, "."
set :deploy_via, :copy

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, 'app'
set :deploy_to, "/home/app/apps/#{application}"
set :use_sudo, false
set :keep_releases, 5
set :application_port, 3001

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

namespace :deploy do
  desc "Start unicorn"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec unicorn_rails -c config/unicorn.rb -E #{rails_env} -D -l0.0.0.0:#{application_port}"
    #run "cd #{current_path} && RAILS_ENV=#{rails_env} script/delayed_job start"
  end

  desc "Stop unicorn"
  task :stop, :roles => :app, :except => {:no_release => true} do
    run "kill -s QUIT `cat #{shared_path}/pids/unicorn.pid`"
    #run "cd #{current_path} && RAILS_ENV=#{rails_env} script/delayed_job stop"
  end

  desc "Restart unicorn"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{shared_path}/pids/unicorn.pid`"
    #run "kill -s QUIT `cat #{shared_path}/pids/unicorn.pid.oldbin`"
    #run "cd #{current_path} && RAILS_ENV=#{rails_env} script/delayed_job stop"
    #run "cd #{current_path} && RAILS_ENV=#{rails_env} script/delayed_job start"
  end

  desc "Restart unicorn"
  task :restart2, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end

  desc "Update, migrate, and restart"
  task :umr do
    transaction do
      update_code
      migrate
      stop
      start
    end
  end

  desc "Make the symlink to public/uploads directory"
  task :symlink_uploads do
     run "mkdir -p #{shared_path}/uploads"
     run "ln -nfs #{shared_path}/uploads  #{release_path}/public/uploads"
  end
end

after 'deploy:update_code', 'deploy:symlink_uploads'

namespace :es do
  desc 'Update elasticsearch index'
  task :update_index do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake tire:import:all"
  end
end