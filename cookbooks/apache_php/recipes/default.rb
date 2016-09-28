#
# Cookbook Name:: apache_php
# Recipe:: default
#
#My Name is harish Sarva And I made this changes on purpose.
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'selinux::permissive'
include_recipe 'apache_php::firewall'

include_recipe 'apache_php::web_user'

include_recipe 'apache_php::web'

include_recipe 'apache_php::database'

