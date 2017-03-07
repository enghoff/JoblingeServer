# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'joblinge'
ask(:git_https_username, 'joblingedeployer', echo: false)
ask(:git_https_password, nil, echo: false)
git_https_username = fetch(:git_https_username)
git_https_password = fetch(:git_https_password)
set :repo_url, "https://#{git_https_username}:#{git_https_password}@ranj.git.beanstalkapp.com/877_joblinge_backend.git"

#after "deploy:restart", "resque:restart"
#after "deploy:restart", "resque:scheduler:restart"


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/deployer/joblinge'
# on staging we had
# set :deploy_to, '/home/deployer/jobslinge-production'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
