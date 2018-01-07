#!/bin/bash

apt-get -y update
apt-get -y dist-upgrade
apt-get -y install software-properties-common
apt-add-repository ppa:ansible/ansible

apt-get -y update
apt-get -y install ansible python-pip
pip install jmespath  # needed for Ansible json_query


echo 'ubuntu ALL=NOPASSWD:ALL' > /etc/sudoers.d/ubuntu