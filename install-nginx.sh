#! /bin/bash
#sudo yum update -y
#sudo yum install epel-release -y
#sudo yum install nginx -y
#sudo systemctl enable nginx
#sudo systemctl start nginx


custom_data = <<EOF
                  #! /bin/bash
                  sudo apt-get remove docker docker-engine docker.io
                  sudo apt-get update
                  sudo apt-get install -y \
                  apt-transport-https \
                  ca-certificates \
                  curl \
                  software-properties-common
                  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                  sudo apt-key fingerprint 0EBFCD88
                  sudo add-apt-repository \
                  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                  $(lsb_release -cs) \
                  stable"
                  sudo apt-get update
                  sudo apt-get install docker-ce -y
                  sudo usermod -a -G docker $USER
                  sudo systemctl enable docker
                  sudo systemctl restart docker
                  sudo docker run --name docker-nginx -p 8080:8080 nginx:latest
              EOF