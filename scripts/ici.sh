#!/bin/env bash
rpm --import http://packages.icinga.org/icinga.key 
rpm -i https://packages.icinga.com/epel/7/release/noarch/icinga-rpm-release-7-2.el7.centos.noarch.rpm
yum install icinga2 nagios-plugins-all -y
systemctl start icinga2.service
systemctl enable icinga2.service
