require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'pnq.cc'
set :user, 'qhwa'
set :deploy_to, '/home/webapp/xiaotuhe'
set :repository, 'https://github.com/qhwa/xiaotuhe-server.git'
set :branch, 'master'

set :unicorn_config,  "#{deploy_to}/shared/config/unicorn.rb"
set :unicorn_pid,     "#{deploy_to}/tmp/pids/unicorn.pid"

set :shared_paths, ['config/database.yml', 'log', 'config/unicorn.rb', 'config/initializers/secret_token.rb']

task :environment do
  invoke :'rvm:use[ruby-2.1.1-p247@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/tmp/pids"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue! %[touch "#{deploy_to}/shared/config/unicorn.rb"]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml' and 'shared/config/unicorn.rb'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
  end
end

task :start => :environment do
  queue "unicorn_rails --daemonize --env #{rails_env} --config-file #{unicorn_config}"
end

task :stop => :environment do
  queue "kill -QUIT `cat #{unicorn_pid}`"
end

task :restart => :environment do
  invoke :stop
  invoke :start
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
