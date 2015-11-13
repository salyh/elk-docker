$script = <<SCRIPT
cd /vagrant
echo Build
docker build -t codecentric/elk2 .
echo Run
docker run -d --restart always -p 5601:5601 -p 9200:9200 -p 9300:9300 -p 5000:5000 -i --name elk2 codecentric/elk2
SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "williamyeh/ubuntu-trusty64-docker"
  config.vm.provision "shell", inline: $script
  config.vm.network "forwarded_port", guest: 5601, host: 5601
  config.vm.network "forwarded_port", guest: 9200, host: 9200
  config.vm.network "forwarded_port", guest: 9300, host: 9300
  config.vm.network "forwarded_port", guest: 5000, host: 5000

  config.vm.provider "virtualbox" do |v|
          v.memory = 2048
          v.cpus = 2
  end

end
