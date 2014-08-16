#!/bin/sh
set -x
virsh_secret=$1
openstack_ip=$2

openstack-config --set /etc/nova/nova.conf DEFAULT cinder_endpoint_template "http://${openstack_ip}:8776/v1/%(project_id)s"


chkconfig tgt on
chkconfig cinder-volume on

service tgt restart
service cinder-volume restart
service libvirt-bin restart
service nova-compute restart

