# using the module path instead of the absolute path would end up storing your secret in git, which is what you are trying to avoid
$password = file("/vagrant/configs/.secret")
$dbpass = file("/vagrant/configs/.dbpass")
$env = file("/vagrant/configs/environment")
$envvars = file("/vagrant/configs/envvars")

file { '/etc/environment':
    ensure => file,
    content => "$env",
}

file { '/etc/apache2/envvars':
    ensure => file,
    content => "$envvars",
}

user { 'root':
    ensure => present,
    password => "$password"
}

package { 'php':
	ensure => 'installed',
}

package { 'mysql-server':
	ensure =>'installed',
    require => User['root']
}

package { 'Scrapy':
    ensure   => 'installed',
    provider => 'pip',
}

package { 'pyopenssl':
    ensure   => 'latest',
    provider => 'pip',
}

package { 'bs4':
    ensure   => 'latest',
    provider => 'pip',
}

package { 'scrapy_proxies':
    ensure   => 'latest',
    provider => 'pip',
    require => Package["Scrapy"],
}

package { 'scrapy_fake_useragent':
    ensure   => 'latest',
    provider => 'pip',
    require => Package["Scrapy"],
}

service { 'mysql':
	ensure => true,
    enable => true,
	require => Package['mysql-server']
}

package { 'php-mysql':
	ensure => installed,
	require => Service['mysql'],
    notify  => Service['apache2'],
}

exec { 'create-database':
  creates => '/opt/dbinstalledquirkcreation',
  command => "/usr/bin/sudo /usr/bin/mysql -u root -p$dbpass < /vagrant/GenerateStand/backups/initialize.sql",
  require => Service['mysql']
}

exec { 'insert-database':
  creates => '/opt/dbinstalledquirkcreation',
  command => "/usr/bin/sudo /usr/bin/mysql -u root -p$dbpass quirkcreation < /vagrant/GenerateStand/backups/quirkcreation.sql",
  require => Exec['create-database']
}

exec { 'create-oauth-tables':
  creates => '/opt/dbinstalledquirkcreation',
  command => "/usr/bin/sudo /usr/bin/mysql -u root -p$dbpass quirkcreation < /vagrant/GenerateStand/backups/oauth.sql",
  require => Exec['create-database']
}

exec {'composer':
    cwd => '/vagrant/GenerateStand',
    command => "/usr/bin/wget https://raw.githubusercontent.com/composer/getcomposer.org/fe96bbefbdb83fa3ca6504c8edea4018528a5e66/web/installer -O - -q | /usr/bin/php -- --quiet",
    unless => "/usr/bin/test -f composer.phar",
    require => [ Package['php'], File['/var/www'] ]
}

file { '/var/www':
   ensure => 'link',
   target => '/vagrant/GenerateStand',
   force => true,
}

service { 'apache2':
    ensure  => 'running',
    enable  => true,
}

file { '/etc/apache2/sites-available':
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant',
    mode   => '0750',
}

file { '/etc/apache2/sites-available/000-default.conf':
    notify  => Service['apache2'],
	ensure => file,
  	owner  => 'vagrant',
	group  => 'vagrant',
    mode   => '0750',
  	source => [
    	"/vagrant/configs/000-default.conf"
  	],
	require => File["/etc/apache2/sites-available"],
}

file { '/etc/apache2/apache2.conf':
    notify  => Service['apache2'],
	ensure => file,
  	owner  => 'vagrant',
	group  => 'vagrant',
    mode   => '0750',
  	source => [
    	"/vagrant/configs/apache2.conf"
  	],
	require => File["/etc/apache2/sites-available/000-default.conf"],
}