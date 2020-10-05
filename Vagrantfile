# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "debian/jessie64"
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/debian/jessie64.box"
  config.vm.network "forwarded_port", guest: 443, host: 8443
    
  # Provision
  config.vm.provision :"shell", :path => "bootstrap.sh"
  config.hostmanager.aliases = %w(www.example.com www.test.com)
  # Port forwarding
  config.vm.network "forwarded_port", guest: 80, host: 443
end