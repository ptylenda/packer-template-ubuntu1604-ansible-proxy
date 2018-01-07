#!/bin/bash

purge-old-kernels
apt-get -y remove --purge ansible
apt-add-repository --remove ppa:ansible/ansible
apt-get -y autoremove --purge
apt-get -y clean

pip uninstall -y jmespath  # needed for Ansible json_query

rm -rf /tmp/*
rm -f /home/vagrant/*.sh

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

sync