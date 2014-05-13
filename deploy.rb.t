# encoding: utf-8

require 'bundler/capistrano'

srv = 'vmname'

set :application, 'rails-app'

set :scm, :git 
set :repository, 'git@github.com:github_username/testapp.git'

server srv, :web, :app, :db, :primary => true

set :deploy_to, '/var/www'
set :use_sudo, false

set :deploy_via, :copy
set :copy_strategy, :export

set :default_environment, {
  'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  'DEBIAN_FRONTEND' => 'readline'
}
ruby_dep = #%w(build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libcurl4-openssl-dev 
           #   curl git-core python-software-properties libsqlite3-dev libmysql++-dev)
           %w(build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev
              git-core curl zlib1g-dev )

namespace :install do
 
  task :common do

#    ['sudo debconf-set-selections <<EOF',
#     'tzdata tzdata/Areas select Europe',
#     'tzdata tzdata/Areas seen true',
#     'tzdata tzdata/Zones/Europe select Podgorica',
#     'tzdata tzdata/Zones/Europe seen true',
#     'EOF'].each {|s| run 'echo "'+s+'" >>x.sh'}
#    run 'sudo dpkg-reconfigure -fnoninteractive tzdata'

#   sudo dpkg-reconfigure --frontend=readline debconf

#   sudo dpkg-reconfigure debconf
    run 'sudo apt-get update'
    run 'sudo apt-get install ntp -y'
#    run 'sudo ntpdate ntp.ubuntu.com'
    run 'sudo apt-get install mc -y'
    run 'sudo apt-get install htop -y'
    run 'sudo apt-get install zip -y'
    run 'sudo apt-get install imagemagick libmagickwand-dev -y'
    run 'sudo apt-get -y install '+ruby_dep.join(' ')
  end
 
  task :ruby do
    run 'echo "gem: --no-ri --no-rdoc" >> ~/.gemrc'
    run 'mkdir ~/src && cd ~/src && wget -q -nc http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.1.tar.gz'
    run 'cd ~/src && tar -zxf ruby-2.1.1.tar.gz'
    run 'cd ~/src/ruby-2.1.1 && ./configure --with-readline-dir=/usr/lib/x86_64-linux-gnu/libreadline.so && make && sudo make install'
    run 'cd ~ && rm -rf src'
    run 'sudo gem install bundler'
  end
 
  task :passenger do

    run 'sudo gem install passenger'
    run 'sudo passenger-install-nginx-module --auto --prefix=/opt/nginx --auto-download'

    run 'cd ~'
    upload 'tmp/nginx.init', 'nginx.init'
    run 'sudo chown root:root nginx.init'
    run 'sudo mv nginx.init /etc/init/nginx.conf'

    upload 'tmp/nginx.logrotate', 'nginx'
    run 'sudo chown root:root nginx'
    run 'sudo mv nginx /etc/logrotate.d'

    run 'sudo mv /opt/nginx/conf/nginx.conf /opt/nginx/conf/nginx.conf.bak'
    upload 'tmp/nginx.conf', 'nginx.conf'
    run 'sudo chown root:root nginx.conf'
    run 'sudo mv nginx.conf /opt/nginx/conf/nginx.conf'

    run 'sudo mkdir /var/www'
    run 'sudo chown $(whoami):$(whoami) /var/www'
    
    # for carrierwave
    run 'mkdir /var/www/shared'
    run 'mkdir /var/www/shared/uploads'
    run 'mkdir /var/www/shared/backups'

    # for backup
    system "scp -r tmp/backup.sh #{srv}:/var/www/shared/backup.sh"

  end

  task :all do
     common
     ruby
     passenger
  end

end

namespace :nginx do
  
  task :start do 
    run 'sudo service nginx start' 
  end
  task :stop do 
    run 'sudo service nginx stop' 
  end
  task :restart do 
    run 'sudo service nginx restart' 
  end
  task :status do 
    run 'sudo service nginx status' 
  end
    
end


namespace :deploy do
  
  task :start do ; end
  task :stop  do ; end

  desc 'restart the application'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  # desc "Copy the database.yml file into the latest release"
  # task :copy_in_database_yml do
  #   run "cp #{shared_path}/config/database.yml #{latest_release}/config/"
  # end

  task :copy_secrets_yaml do
    #upload "config/application.yml", "#{latest_release}/config/application.yml"
    system "scp config/secrets.yml #{srv}:#{latest_release}/config/secrets.yml"
  end

  task :link_carierwave_uploads do
    run "rm -rf #{latest_release}/public/uploads"
    run "ln -s #{shared_path}/uploads #{latest_release}/public/uploads"
  end

  task :link_backups do
    run "rm -rf #{latest_release}/backups"
    run "ln -s #{shared_path}/backups #{latest_release}/backups"
  end

end

namespace :data do
  task :pull do
    #deploy:stop
    download "/var/www/shared/production.sqlite3", "db/development.sqlite3"
    #copy carriereave uploads"
    system "rm -rf public/uploads"
    system "scp -r #{srv}:/var/www/shared/uploads public/uploads"
    #deploy:start
  end
  task :push do
    #deploy:stop
    upload "db/development.sqlite3", "/var/www/shared/production.sqlite3"
    #copy carriereave uploads"
    run    "rm -rf /var/www/shared/uploads"
    system "scp -r public/uploads #{srv}:/var/www/shared/uploads"
    #deploy:start
  end
end

namespace :site do
  task :refresh do
    system "curl https://www.n1angel.com/home >/dev/null"
  end
end

after "deploy:cold", "nginx:start"
after "deploy:setup", "deploy:cold"

after "deploy", "site:refresh"

before "deploy:restart", "deploy:migrate"
before "deploy:assets:precompile", "deploy:copy_secrets_yaml"
before "deploy:assets:precompile", "deploy:link_carierwave_uploads"
before "deploy:assets:precompile", "deploy:link_backups"
# before "deploy:assets:precompile", "deploy:remove_deploy"

set :keep_releases, 1
after "deploy:update", "deploy:cleanup" 

# before "deploy:assets:precompile", "deploy:copy_in_database_yml"
