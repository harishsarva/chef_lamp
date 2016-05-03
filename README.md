# chef_lamp
Hosting a web page 
Apache_PHP tree
.
└───apache_php
    ├───.kitchen
    │   ├───kitchen-vagrant
    │   │   └───kitchen-apache_php-default-centos-72
    │   │       └───.vagrant
    │   │           └───machines
    │   │               └───default
    │   │                   └───virtualbox
    │   └───logs
    ├───attributes
    |    |_default.rb
    ├───files
    │   └───default
    |    |__create-tables.sql
    ├───recipes
    |    |__database.rb
    |    |__default.rb
    |    |__firewall.rb
    |    |__web.rb
    |    |__web_user.rb
    ├───spec
    │   └───unit
    │       └───recipes
    ├───templates
    │   └───default
    |     |__customers.conf.erb
    |     |__index.php.erb
    └───test
        └───integration
            ├───default
            │   └───serverspec
            └───helpers
                └───serverspec
                
                
.kitchen.yml for testing in kitchen:      
  ---
driver:
  name: vagrant
  network:
    - ["private_network", {ip: "192.168.33.45"}]

provisioner:
  name: chef_zero

platforms:
  - name: centos-7.2
    driver:
      customize:
        memory: 256


Attributes: default.rb
default['firewall']['allow_ssh'] = true > To allow ssh for the port default 22
default['firewall']['firewalld']['permanent'] = true  > allow firewall rules permanant 
default['apache_php']['open_ports'] = 80> opened port number 80 for httpd
 
default['apache_php']['user'] = 'web_admin' > named User name as Web_Admin
default['apache_php']['group'] = 'web_admin'> named gruop name as Web_Admin

default['apache_php']['document_root'] = '/var/www/customers/public_html'> To make a path for directory

default['apache_php']['secret_file'] = '/etc/chef/encrypted_data_bag_secret'> To genearate the encrypted passwords for the users 

default['apache_php']['database']['dbname'] = 'harish_db'> To create the database name as harish_db
default['apache_php']['database']['host'] = '127.0.0.1'> default to Host 
default['apache_php']['database']['root_username'] = 'root'> database user for creating db users. Defaults to "root"
default['apache_php']['database']['admin_username'] = 'db_admin'> to create the Admin User
default['apache_php']['database']['create_tables_script'] ='/tmp/create-tables.sql'> create table for the data base to enter the Users

Files: Default:Create-tables.sql
PS C:\Users\harish sarva\chef\cookbooks\apache_php\files\default> more .\create-tables.sql
CREATE TABLE customers(
  id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(30),
  lastname VARCHAR(30),
  email VARCHAR(30),
  zipcode INT(10),
  timecreated TIMESTAMP
);

INSERT INTO customers (firstname, lastname, email,zipcode,timecreated ) VALUES ('har', 'Sh', 'har.sh@example.com',23456,NOW());
In this i have created table for custumer with First and last name char sizes are 30. Zip code for 10, And email for 30 characters.

Insert Into: its used for insert the customer details


Recipes:

    Directory: C:\Users\harish sarva\chef\cookbooks\apache_php\recipes


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        4/24/2016   6:43 PM           2357 database.rb
-a----        4/24/2016   6:58 PM            311 default.rb
-a----        4/24/2016   4:40 PM            260 firewall.rb
-a----        4/24/2016   9:31 PM           1328 web.rb
-a----        4/24/2016   5:05 PM            266 web_user.rb
Database.rb

# Cookbook Name:: apache_php
# Recipe:: database
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

mysql2_chef_gem 'default' do
  action :install
end

# Configure the MySQL client.
mysql_client 'default' do
  action :create
end

# Load the secrets file and the encrypted data bag item that holds the root password.
password_secret = Chef::EncryptedDataBagItem.load_secret(node['apache_php']['secret_file'])
password_data_bag_item = Chef::EncryptedDataBagItem.load('database_passwords', 'mysql_customers', password_secret)

# Configure the MySQL service.
mysql_service 'default' do
  initial_root_password password_data_bag_item['root_password']
  action [:create, :start]
end

# Create the database instance.
mysql_database node['apache_php']['database']['dbname'] do
  connection(
    :host => node['apache_php']['database']['host'],
    :username => node['apache_php']['database']['root_username'],
    :password => password_data_bag_item['root_password']
  )
  action :create
end
database.rb --> configuring MySQL client and database and installing dependencies.
                creating database, adding user, executing pre written scripts(/files/default/create-tables.sql)
In this database.rb> Install Mysql and create the action foir services. start for the action
generate the passwords and users Data_bag_item
install mysql and make connection with php

Default.rb:

include_recipe 'selinux::permissive'
include_recipe 'apache_php::firewall'

include_recipe 'apache_php::web_user'

include_recipe 'apache_php::web'

include_recipe 'apache_php::database'
>>> make selinux policy permissive  and create a firewall Apache_php
create Web and Web_user for the Apache_php
and include a data base for the apache_php

Firewall.rb

include_recipe 'firewall::default'

ports = node.default['apache_php']['open_ports']
firewall_rule "open ports #{ports}" do
  port ports
end
>>> open ports for the Apache_php and for all ssh and httpd like port22 and port80
and apply firewall rules those ports

Web.rb


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
    >> install apache and start services  "customers" to make action 
    This Multi-Processing Module (MPM) implements a non-threaded, pre-forking web server and it allows incoming requests
    o avoid threading for compatibility with non-thread-safe libraries. It is also the best MPM for isolating each request, so that a problem with a single request will not affect any other.
    The source file index.php.erb
    mode 0644 change permission for the source
    and to make Owner mode and Group mode
    
    Web_user.rb
    
    group node['apache_php']['group']

user node['apache_php']['user'] do
  group node['apache_php']['group']
  system true
  shell '/bin/bash'
end

To make apache_php user user node
group node.
when system is true it gets executed shell '/bin/bash' content of the file and it goes to end after all

 Directory: C:\Users\harish sarva\chef\cookbooks\apache_php\templates
 
 Defaults:
 
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        4/24/2016   5:22 PM            714 customers.conf.erb
-a----        4/24/2016   9:13 PM           3422 index.php.erb
<VirtualHost *:80>
  ServerName <%= node['hostname'] %>
  ServerAdmin 'ops@example.com'

  DocumentRoot <%= node['apache_php']['document_root'] %>
  <Directory "/">
          Options FollowSymLinks
          AllowOverride None
  </Directory>
  <Directory <%= node['apache_php']['document_root'] %> >
          Options Indexes FollowSymLinks MultiViews
          AllowOverride None
          Require all granted
  </Directory>

  ErrorLog /var/log/httpd/error.log

  LogLevel warn

  CustomLog /var/log/httpd/access.log combined
  ServerSignature Off

  AddType application/x-httpd-php .php
  AddType application/x-httpd-php-source .phps
  DirectoryIndex index.php index.html
</VirtualHost>
for the virtual host make port number 80 for the httpd service
server name: hostname: 192.168.33.45
and create mails for the different users. It gets override when exceeds more than it limits
For the error log files path would be
/var/log/httpd/error.log file
 it gets any terminated when unauthorized userd trying to access. and the server would be signature off
 we added differnt type of applications httpd_php and source and index.html
 
 Index.php.erb
 <?php

  if(isset($_POST['on'])) {



    $servername = "<%= node['apache_php']['database']['host'] %>";
$username = "<%= node['apache_php']['database']['admin_username'] %>";
    $password = "<%= @database_password %>";
    $dbname = "<%= node['apache_php']['database']['dbname'] %>";

    // Create connection
     $conn = new mysqli($servername, $username, $password, $dbname);
     $queries = "select * from customers";
     $result = mysqli_query($conn, $queries);
     while($row = mysqli_fetch_array($result))
     {
     echo "<table><tr><th>ID</th><th>firstname</th><th>lastname</th><th>mail</th><th>zipcode</th><th>timecreated</th></tr>";
     // output data of each row
     while($row = $result->fetch_assoc()) {
      echo "<tr><td>" . $row["id"]. "</td><td>" . $row["firstname"]. "</td><td> " . $row["lastname"]. "</td><td>" . $row["email"]. "</td><td> " . $row["zipcode"]. "</td><td> " . $row["timecreated"]. "</td></tr>" ;
     }
     echo "</table>";
     }


    }



  if(isset($_POST['firstname'], $_POST['lastname'], $_POST['email'], $_POST['zipcode'])) {
        //...use variables to store GET array values
                $fname = $_POST['firstname'];
                $lname= $_POST['lastname'];
                                $email= $_POST['email'];
                                $zipcode=$_POST['zipcode'];
                                
                                
    
it uses service for apache and display context on the web page when try hit the host name:192.168.33.45/index.php
First name:
Last Name:
Email Address:
Zip code:
Time Created
It would ask these follwing details when you are trying to enter the users into the database and it will show first in first out

 C:\Users\harish sarva\chef\cookbooks\apache_php> more .\.kitchen.yml
 
 driver:
  name: vagrant
  network:
    - ["private_network", {ip: "192.168.33.45"}]

provisioner:
  name: chef_zero

platforms:
  - name: centos-7.2
    driver:
      customize:
        memory: 256

suites:
  - name: default
    data_bags_path: "../../data_bags"
    run_list:
      - recipe[apache_php::default]
    provisioner:
      encrypted_data_bag_secret_key_path: "../../.chef/encrypted_data_bag_secret"
    attributes:
      apache_php:
        secret_file: '/tmp/kitchen/encrypted_data_bag_secret'
        
        It creted the test kitchen with version of centos 7.2
        the memory would be 256 for the test
        in this first we have to test cookbook in the test kitchen  then only we can send to the chef server and applying to the differnt nodes 
         encrypted_data_bag_secret_key_path: "../../.chef/encrypted_data_bag_secret"
         it keeps the passwords for the users and run list would be 
         recipe[apache_php::default]
        


