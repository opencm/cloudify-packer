PACKER_FILE=cloudify-packer.json
cp ${PACKER_FILE}{,.bak}
sed -i "s|{{ components_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-components_amd64.deb|g" ${PACKER_FILE}
sed -i "s|{{ core_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-core_amd64.deb|g" ${PACKER_FILE}
sed -i "s|{{ ui_package_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ui_amd64.deb|g" ${PACKER_FILE}
sed -i "s|{{ ubuntu_agent_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ubuntu-agent_amd64.deb|g" ${PACKER_FILE}
sed -i "s|{{ windows_agent_url }}|http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-windows-agent_amd64.deb|g" ${PACKER_FILE}
sed -i "s|{{ release }}|nightly|g" ${PACKER_FILE}
packer build -only=virtualbox-ovf -force ${PACKER_FILE}
mv ${PACKER_FILE}{.bak,}