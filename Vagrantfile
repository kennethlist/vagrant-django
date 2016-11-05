Vagrant.configure(2) do |config|
  config.vm.box = "trusty-server-cloudimg-i386-vagrant-disk1"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"
  config.vm.synced_folder ".", "/home/vagrant/site"
  config.vm.synced_folder "virtualenvs", "/home/vagrant/.virtualenvs/"
  config.vm.provision "shell", path: "vagrant_setup.sh"
  # config.vm.network :public_network
  config.vm.network :forwarded_port, guest: 8000, host: 8000
  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :forwarded_port, guest: 80, host: 8081
  config.vm.network :forwarded_port, guest: 3306, host: 3306
  config.vm.network :forwarded_port, guest: 8025, host: 8025
  # config.vm.network "private_network", ip: "192.168.3.4"
end
