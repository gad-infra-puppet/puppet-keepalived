define keepalived::ipvs_real_server($virtual_server_ip, $health_check_file=false) {
  $octet_id = values_at(split($virtual_server_ip, '[.]'), 3)
  $service_name = "ipvs_real_server_${octet_id}"

  file { "/etc/init.d/${service_name}" :
    ensure  => present,
    mode    => '0755',
    content => template('keepalived/debian/ipvs_real_server.init.erb'),
  }

  service { $service_name :
    enable => true,
    ensure => false,
    require => File["/etc/init.d/${service_name}"],
  }
}
