#! /bin/bash
#
set -x verbose # for debuging 

#
#  variables for app setup
#

project=n1new				# not ruby reserved word test etc..
website=www.$project.com    # not used yet

vagrantbox=preciseamd64 # assume box is already added with vagrant box add
myip=192.168.1.102      # for fixing ubuntu 12.04 net accessibility problem
memorysize=640          # for virtual box

sshport=2226            # free ports not used for other vm
httpport=4446           # will be redirected on vm from 22/80 retrospectively

github_username=robert-aleksic # username  on github where repository will be created

echo "===   Creating project folder"
mkdir $project && cd $project

echo "===   Virtual machine"
vmname=$project'-vm'
mkdir vm && cd vm
cp ../../Vagrantfile.t            Vagrantfile
sed -i s/vagrantbox/$vagrantbox/g Vagrantfile 
sed -i s/vmname/$vmname/g         Vagrantfile 
sed -i s/myip/$myip/g             Vagrantfile 
sed -i s/memorysize/$memorysize/g Vagrantfile
sed -i s/sshport/$sshport/g       Vagrantfile
sed -i s/httpport/$httpport/g     Vagrantfile
vagrant up
cp ../../sshconfig.t .
sed -i s/vmname/$vmname/g sshconfig.t
sed -i s/sshport/$sshport/g sshconfig.t
cat sshconfig.t >>~/.ssh/config
rm sshconfig.t
cd ..

echo "===   Create rails app"
echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
rails new rails_app -T --skip-bundle >/dev/null
cd rails_app
cp ../../Gemfile   .
cp ../../Capfile   .
cp ../../deploy.rb.t tmp
sed -i s/testapp/$project/g                 tmp/deploy.rb.t
sed -i s/vmname/$vmname/g                   tmp/deploy.rb.t
sed -i s/github_username/$github_username/g tmp/deploy.rb.t
mv tmp/deploy.rb.t config/deploy.rb
cp ../../nginx.conf      tmp
cp ../../nginx.init      tmp
cp ../../nginx.logrotate tmp
cp ../../new.sh          tmp
sed -i s#db/prod#/var/www/shared/prod# app/config/database.yml
bundle install

echo "===   Initial commit to git"
git init >/dev/null
git add .
git commit -m 'before initial deployment' >/dev/null
echo "===   Create github repository and do initial push"
curl -u $github_username https://api.github.com/user/repos -d ''{"\""name"\"":"\""$project"\""}'' >/dev/null
git remote add origin git@github.com:$github_username/$project.git
git push -u origin master
cd ..
