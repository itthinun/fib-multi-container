#!/usr/bin/env bash
set -x

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt -y install docker-ce pass
echo 'DOCKER_OPTS="--experimental"' | sudo tee /etc/default/docker
sudo service docker restart

wget https://github.com/docker/docker-credential-helpers/releases/download/v0.6.3/docker-credential-pass-v0.6.3-amd64.tar.gz
tar -xzf docker-credential-pass-v0.6.3-amd64.tar.gz
sudo mv docker-credential-pass /usr/local/bin/
chmod 777 /usr/local/bin/docker-credential-pass
mkdir -p /home/travis/.docker
echo '{ "credsStore": "pass" }' | tee /home/travis/.docker/config.json
gpg --batch --gen-key <<-EOF
%echo generating a standard key
Key-Type: DSA
Key-Length: 1024
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: Travis CI
Name-Email: travis@osism.io
Expire-Date: 0
%commit
%echo done
EOF
key=$(gpg --no-auto-check-trustdb --list-secret-keys | grep ^sec | cut -d/ -f2 | cut -d" " -f1)
pass init $key

docker-credential-pass list
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_ID" --password-stdin