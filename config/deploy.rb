require 'bundler/capistrano'
require 'rvm/capistrano'
require 'visionbundles'

# RVM Settings
set :rvm_ruby_string, '2.1.0'
set :rvm_type, :user
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# Recipes Included
include_recipes :secret, :nginx, :puma, :db, :dev, :fast_assets

# Nginx
set :nginx_upstream_via_sock_file, false
set :nginx_app_servers, ['127.0.0.1:9290'] # upstream will point to app server.

# Puma
set :puma_bind_for, :tcp
set :puma_bind_to, '127.0.0.1'
set :puma_bind_port, '9290'
set :puma_thread_min, 32
set :puma_thread_max, 32
set :puma_workers, 3

# Capistrano Base Setting
set :application, 'x'
set :user, 'rails'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :rails_env, :production

# Git Settings
set :scm, :git
set :repository, "https://github.com/afunction/#{application}.git" # your git source, and make sure your server have premission to access your git server
set :branch, :master # the branch you want to deploy

# Extra settings
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after 'deploy', 'deploy:cleanup' # keep only the last 5 releases

namespace :images do
  desc "setup the shared path image folder"
  task :setup, roles: :web do
    mkdir "#{shared_path}/shared_images/"
  end
  after 'deploy:setup', 'images:setup'

  desc "setup the symlinks for image folder"
  task :symlinks, roles: :web do
    run "ln -nfs #{shared_path}/shared_images #{release_path}/public/shared_images"
  end
  after "deploy:finalize_update", "images:symlinks"
end

load_config_from "./preconfig/config", :production
