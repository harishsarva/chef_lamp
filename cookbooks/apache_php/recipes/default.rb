#
# Cookbook Name:: apache_php
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'selinux::permissive'
include_recipe 'apache_php::firewall'

include_recipe 'apache_php::web_user'

include_recipe 'apache_php::web'

include_recipe 'apache_php::database'

