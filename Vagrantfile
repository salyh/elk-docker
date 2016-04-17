$script = <<SCRIPT
docker rm -f elk2 > /dev/null 2>&1
docker rm -f elk2n2 > /dev/null 2>&1

cd /vagrant
echo "Build Node 1"
docker build -t codecentric/elk2 .
echo "Run Node 1"
docker run -d --net=host --restart always -p 127.0.0.1:5601:5601 -p 127.0.0.1:9200:9200 -p 127.0.0.1:9300:9300 -p 127.0.0.1:5000:5000 -i --name elk2  codecentric/elk2

echo "Build Node 2"
docker build -f Dockerfile2ndNode -t codecentric/elk2n2 .
echo "Run Node 2"
docker run -d --net=host --restart always  -p 127.0.0.1:9201:9200 -p 127.0.0.1:9301:9300 -i --name elk2n2  codecentric/elk2n2
SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "williamyeh/ubuntu-trusty64-docker"
  config.vm.provision "shell", inline: $script
  config.vm.network "forwarded_port", guest: 5601, host: 5601
  config.vm.network "forwarded_port", guest: 9200, host: 9200
  config.vm.network "forwarded_port", guest: 9201, host: 9201
  config.vm.network "forwarded_port", guest: 9301, host: 9301
  config.vm.network "forwarded_port", guest: 9300, host: 9300
  config.vm.network "forwarded_port", guest: 5000, host: 5000

  config.vm.provider "virtualbox" do |v|
          v.memory = 2048
          v.cpus = 2
  end
end
