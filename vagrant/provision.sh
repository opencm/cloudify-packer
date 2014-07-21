echo bootstrapping...

# update
echo updating apt cache
sudo apt-get -y update &&

# install prereqs
echo installing prerequisites
sudo apt-get install -y curl python-dev vim git

# install pip
curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python

# go home
cd ~

# virtualenv
echo installing virtualenv
sudo pip install virtualenv==1.11.4 &&
echo creating cloudify virtualenv
virtualenv cloudify &&
source cloudify/bin/activate &&

# install cli
echo installing cli
pip install https://github.com/cloudify-cosmo/cloudify-rest-client/archive/develop.zip
pip install https://github.com/cloudify-cosmo/cloudify-dsl-parser/archive/develop.zip
pip install https://github.com/cloudify-cosmo/cloudify-cli/archive/develop.zip &&

# add cfy bash completion
activate_cfy_bash_completion

# init simple provider
cd ~
mkdir -p simple &&
cd simple &&
cfy init simple_provider &&

USERNAME=$(id -u -n)

# copy the ssh key only when bootstrapping with vagrant. otherwise, implemented in packer
# copy vagrant ssh key
echo copying ssh key
mkdir -p /home/${USERNAME}/.ssh/
cp /vagrant/insecure_private_key /home/${USERNAME}/.ssh/cloudify_private_key

# sudo iptables -L
# sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT

# configure yaml provider params
sed -i "s|Enter-Public-IP-Here|127.0.0.1|g" cloudify-config.yaml
sed -i "s|Enter-Private-IP-Here|127.0.0.1|g" cloudify-config.yaml
sed -i "s|Enter-SSH-Key-Path-Here|/home/${USERNAME}/.ssh/cloudify_private_key|g" cloudify-config.yaml
sed -i "s|Enter-SSH-Username-Here|${USERNAME}|g" cloudify-config.yaml

# configure yaml packages
# sed -i "s|{{ components_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-components_amd64.deb|g" cloudify-config.yaml
# sed -i "s|{{ core_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-core_amd64.deb|g" cloudify-config.yaml
# sed -i "s|{{ ui_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ui_amd64.deb|g" cloudify-config.yaml
# sed -i "s|{{ ubuntu_agent_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ubuntu-agent_amd64.deb|g" cloudify-config.yaml
# sed -i "s|{{ windows_agent_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-windows-agent_amd64.deb|g" cloudify-config.yaml

sed -i "s|{{ components_package_url }}|${COMPONENTS_PACKAGE_URL}|g" cloudify-config.yaml
sed -i "s|{{ core_package_url }}|${CORE_PACKAGE_URL}|g" cloudify-config.yaml
sed -i "s|{{ ui_package_url }}|${UI_PACKAGE_URL}|g" cloudify-config.yaml
sed -i "s|{{ ubuntu_agent_url }}|${UBUNTU_AGENT_URL}|g" cloudify-config.yaml
sed -i "s|{{ centos_agent_url }}|${CENTOS_AGENT_URL}|g" cloudify-config.yaml
sed -i "s|{{ windows_agent_url }}|${WINDOWS_AGENT_URL}|g" cloudify-config.yaml

# configure user for agents
sed -i "s|#user: (no default - optional parameter)|user: ${USERNAME}|g" cloudify-config.yaml

# remove hashes to override config defaults
sed -i "s|^# ||g" cloudify-config.yaml

# bootstrap the manager locally
cfy bootstrap -v &&

# create blueprints dir
mkdir -p ~/simple/blueprints

# source virtualenv on login
echo "source /home/${USERNAME}/cloudify/bin/activate" >> /home/${USERNAME}/.bashrc

# set shell login base dir
echo "cd ~/simple" >> /home/${USERNAME}/.bashrc

echo bootstrap done.