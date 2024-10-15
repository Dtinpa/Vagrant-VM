package { 'php':
	ensure => 'installed',
}

package { 'mysql-server':
	ensure =>'installed',
}

package { 'Scrapy':
    ensure   => 'installed',
    provider => 'pip',
}

service { 'mysql':
	ensure => true,
    enable => true,
	require => Package['mysql-server']
}

service { 'php-mysql':
	ensure => true,
    enable => true,
	require => Package['mysql']
}

file { '/var/www':
   ensure => 'link',
   target => '/vagrant',
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
    	"/tmp/vagrant-puppet/modules-39ccf0531f3d6d7e6da45f867a7abc6f/apache/000-default.conf"
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
    	"/tmp/vagrant-puppet/modules-39ccf0531f3d6d7e6da45f867a7abc6f/apache/apache2.conf"
  	],
	require => File["/etc/apache2/sites-available/000-default.conf"],
}