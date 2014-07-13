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
pip install https://github.com/cloudify-cosmo/cloudify-rest-client/archive/develop.zip
pip install https://github.com/cloudify-cosmo/cloudify-dsl-parser/archive/develop.zip
# pip install https://github.com/cloudify-cosmo/cloudify-cli/archive/feature/CFY-919-bootstrap-existing-vm.zip &&
pip install https://github.com/cloudify-cosmo/cloudify-cli/archive/feature/CFY-923-fix-distro-ident-bug.zip &&

# add cfy bash completion
activate_cfy_bash_completion

# init simple provider
cd ~
mkdir -p simple &&
cd simple &&
cfy init simple_provider &&

USERNAME=$(id -u -n)

# FOR VAGRANT USAGE ONLY
[ -z "$VAGRANT_BOOTSTRAP" ] && VAGRANT_BOOTSTRAP="True"
if env | grep -q ^VAGRANT_BOOTSTRAP=
then
# copy vagrant ssh key
    echo copying ssh key
    mkdir -p /home/${USERNAME}/.ssh/
    cp /vagrant/insecure_private_key /home/${USERNAME}/.ssh/
fi

# sudo iptables -L
# sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT

# configuring config yaml
sed -i "s|Enter-Public-IP-Here|127.0.0.1|g" cloudify-config.yaml
sed -i "s|Enter-Private-IP-Here|127.0.0.1|g" cloudify-config.yaml
sed -i "s|Enter-SSH-Key-Path-Here|/home/${USERNAME}/.ssh/insecure_private_key|g" cloudify-config.yaml
sed -i "s|Enter-SSH-Username-Here|${USERNAME}|g" cloudify-config.yaml

# sed -i "s|{{ components_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-components_amd64.deb|g" cloudify-config.yaml
# sed -i "s|{{ core_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-core_amd64.deb|g" cloudify-config.yaml
# sed -i "s|{{ ui_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ui_amd64.deb|g" cloudify-config.yaml
# sed -i "s|{{ ubuntu_agent_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ubuntu-agent_amd64.deb|g" cloudify-config.yaml
# sed -i "s|{{ windows_agent_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-windows-agent_amd64.deb|g" cloudify-config.yaml

sed -i "s|{{ components_package_url }}|${COMPONENTS_PACKAGE_URL}|g" cloudify-config.yaml
sed -i "s|{{ core_package_url }}|${CORE_PACKAGE_URL}|g" cloudify-config.yaml
sed -i "s|{{ ui_package_url }}|${UI_PACKAGE_URL}|g" cloudify-config.yaml
sed -i "s|{{ ubuntu_agent_url }}|${UBUNTU_AGENT_URL}|g" cloudify-config.yaml
sed -i "s|{{ windows_agent_url }}|${WINDOWS_AGENT_URL}|g" cloudify-config.yaml

# remove hashes to apply configuration
sed -i "s|^# ||g" cloudify-config.yaml

# bootstrap the manager locally
cfy bootstrap -v &&

deploy tutorial nodecellar blueprint
cd ~
echo deploying nodecellar blueprint
wget https://github.com/cloudify-cosmo/cloudify-nodecellar-cloudstack/archive/master.tar.gz
mkdir -p ~/cloudify/blueprints
tar -C ~/cloudify/blueprints -xzvf master.tar.gz
rm master.tar.gz

echo "source /home/${USERNAME}/cloudify/bin/activate" >> /home/${USERNAME}/.bashrc

# now all we have to do is create a box from the vagrant machine
# this is OUTSIDE the scope of the vagrant provisioning script
# vagrant box create

echo bootstrap done.
