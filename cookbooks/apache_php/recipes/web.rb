#
# Cookbook Name:: apache_php
# Recipe:: web
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Install Apache and start the service.
httpd_service 'customers' do
  mpm 'prefork'
  action [:create, :start]
end

# Add the site configuration.
httpd_config 'customers' do
  instance 'customers'
  source 'customers.conf.erb'
  notifies :restart, 'httpd_service[customers]'
end

# Create the document root directory.
directory node['apache_php']['document_root'] do
  recursive true
end

# Load the secrets file and the encrypted data bag item that holds the root password.
password_secret = Chef::EncryptedDataBagItem.load_secret(node['apache_php']['secret_file'])
password_data_bag_item = Chef::EncryptedDataBagItem.load('database_passwords', 'mysql_customers', password_secret)

# Write the home page.
template "#{node['apache_php']['document_root']}/index.php" do
  source 'index.php.erb'
  mode '0644'
  owner node['apache_php']['user']
  group node['apache_php']['group']
   variables(
    :database_password => password_data_bag_item['admin_password']
  )
end

# Install the mod_php Apache module.
httpd_module 'php' do
  instance 'customers'
end

# Install php-mysql.
package 'php-mysql' do
  action :install
  notifies :restart, 'httpd_service[customers]'
end


