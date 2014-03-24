This is set of utilities to simplify deployment and deployment testing of rails applications (deployment testing in local virtual machine). Deployment platform is **ubuntu server 12.04 + ruby 1.9.3 + nginx + passenger** and it is automatically build in vm and can be build on deployment server (bare metal and ec2).

Projects are organised under base folder for all projects. This repository should be put in that folder. All projects are inside individual **_project_** folders. 

There are two folders inside the project folder:
* **vm** folder for virtual machine and 
* **rails_app** for application. 

Capistrano tasks are already setup for rails_app. Also, _.ssh/config_ is setup for vm so that one can easily ssh to **_project_-vm**. 

You can of course just copy your existing app in **rails_app** folder, but take care to have _config/deploy.rb_ intact or at least reasonably included to have capistrano install and deployment tasks.

Generic vm can be build out of local vm with _vagrant package_ and used as starting point for deployment and testing vm's. I still do not want to include anything on it yet, so that cap installs can be used on bare metal or ec2 instances.

_This is still 0.x release. Use it at your own risk. Always keep backup of your app and data - git and github are your friends when it comes to code... It is supplied as-is. I assume no responsibility for it's usage. Here comes other legal blah blahs. You have my permission to copy, change and generally do whatever you like with this code..._

USAGE
=====

Preconditions
-------------
* ruby/rails installed
* VirtualBox/vagrant installed and some precise like box added

Setup project folder and plain vm
---------------------------------
* from base folder, edit variables at the beginning of **./new.sh** and run it
* ssh to vm **ssh _project_-vm**, run **sudo dpkg-reconfigure debconf** and select _noninteractive_ and _high_

Setup vm and do first deployment
--------------------------------
from _rails_app_ folder:

    cap install:common
    cap install:ruby
    cap install:passenger

    or cap install:all

    cap deploy:setup

Setup production server (bare metal or vm)
------------------------------------------
For production server add server in **./ssh/config** and change server name in _server_ directive in **deploy.rb**. Afterwards run _cap install_'s and _cap deploy_'s ...

During development
------------------
Develop, commit, push and run _cap deploy_'s iteratively

Side effects
============
* vm added to _./ssh/config_ to simplify ssh and capfile 
* new github repository created (you can make it private if you wish)
* new virtual mashine **_project_-vm** created and running

Caveats
=======
* Tested on _ubuntu 12.04 server_, should work at other ubuntu servers for deployment
* Still does not do anything with databases

Issues
======
* you should ssh to vm **ssh _project_-vm** before install:common, run **sudo dpkg-reconfigure debconf**, set it to noninteractive/high to avoid _unable to initialize frontend ..._ . I hope that i'll sort that out soon. Anyhow you can rerun install:common multiple times if you forget it

To do
=====
* introduce config file for various app/vm/deployment hosts
* security, optimisation of nginx/passenger - still don't know enough to do it
* switch to ruby from bash
* do something about database management

Comments are welcome ... 
