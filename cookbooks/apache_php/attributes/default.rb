default['firewall']['allow_ssh'] = true
default['firewall']['firewalld']['permanent'] = true
default['apache_php']['open_ports'] = 80

default['apache_php']['user'] = 'web_admin'
default['apache_php']['group'] = 'web_admin'

default['apache_php']['document_root'] = '/var/www/customers/public_html'

default['apache_php']['secret_file'] = '/etc/chef/encrypted_data_bag_secret'

default['apache_php']['database']['dbname'] = 'harish_db'
default['apache_php']['database']['host'] = '127.0.0.1'
default['apache_php']['database']['root_username'] = 'root'
default['apache_php']['database']['admin_username'] = 'db_admin'
default['apache_php']['database']['create_tables_script'] ='/tmp/create-tables.sql'