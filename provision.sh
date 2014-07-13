echo bootstrapping...

# update
echo updating apt cache
sudo apt-get -y update &&

# install prereqs
echo installing prerequisites
sudo apt-get install -y python-setuptools python-dev vim
sudo apt-get purge pip
sudo easy_install -U pip
sudo wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | sudo python

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
# pip install https://github.com/cloudify-cosmo/cloudify-cli/archive/master.zip
pip install https://github.com/cloudify-cosmo/cloudify-rest-client/archive/develop.zip
pip install https://github.com/cloudify-cosmo/cloudify-dsl-parser/archive/develop.zip
pip install https://github.com/cloudify-cosmo/cloudify-cli/archive/feature/CFY-919-bootstrap-existing-vm.zip &&

# add cfy bash completion
activate_cfy_bash_completion

# init simple provider
cd ~
mkdir -p simple &&
cd simple &&
cfy init simple_provider &&

# copy vagrant ssh key
echo copying ssh key
mkdir -p ~/.vagrant.d/
cp /vagrant/insecure_private_key ~/.vagrant.d/

# configuring config yaml
sed -i 's|Enter-Public-IP-Here|localhost|g' cloudify-config.yaml
sed -i 's|Enter-Public-IP-Here|localhost|g' cloudify-config.yaml
sed -i 's|Enter-SSH-Key-Path-Here|/home/vagrant/.vagrant.d/insecure_private_key|g' cloudify-config.yaml
sed -i 's|Enter-SSH-Username-Here|vagrant|g' cloudify-config.yaml

sed -i 's|{{ components_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-components_amd64.deb|g' cloudify-config.yaml
sed -i 's|{{ core_package_url }}/http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-core_amd64.deb|g' cloudify-config.yaml
sed -i 's|{{ ui_package_url }}/http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ui_amd64.deb|g' cloudify-config.yaml
sed -i 's|{{ ubuntu_agent_url }}/http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ubuntu-agent_amd64.deb|g' cloudify-config.yaml
sed -i 's|{{ windows_agent_url }}/http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-windows-agent_amd64.deb|g' cloudify-config.yaml

# bootstrap the manager locally
cfy bootstrap -v &&

# deploy tutorial nodecellar blueprint
cd ~
echo deploying nodecellar blueprint
wget https://github.com/cloudify-cosmo/cloudify-nodecellar-cloudstack/archive/master.tar.gz
mkdir -p ~/cloudify/blueprints
tar -C ~/cloudify/blueprints -xzvf master.tar.gz
rm master.tar.gz

echo 'source ~/cloudify/bin/activate' > ~/.bashrc

# now all we have to do is create a box from the vagrant machine
# this is OUTSIDE the scope of the vagrant provisioning script
# vagrant box create

echo bootstrap done.
