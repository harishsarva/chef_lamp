#
# Cookbook Name:: apache_php
# Recipe:: web_user
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

group node['apache_php']['group']

user node['apache_php']['user'] do
  group node['apache_php']['group']
  system true
  shell '/bin/bash'
end
