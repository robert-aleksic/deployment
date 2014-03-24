Vagrant::Config.run do |config|

  config.vm.box  = "vagrantbox"
  config.vm.customize ["modifyvm", :id, "--name", "vmname", "--memory", "memorysize"]
  config.vm.host_name = "vmname"

  config.vm.forward_port 22, sshport
  config.vm.forward_port 80, httpport

  # config.vm.network :hostonly, "33.33.33.33"
  # config.vm.share_folder "puppet", "/etc/puppet", "../puppet"

  # ubuntu 12.04 workaround
  config.vm.customize ["modifyvm", :id, "--natbindip1", "myip"]

end
