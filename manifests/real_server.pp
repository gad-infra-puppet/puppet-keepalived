define keepalived::real_server(
  $virtual_server_name,
  $virtual_server_ip,
  $virtual_server_port,
  $ip,
  $port,
  $weight = 10,
  $check_type,
  $inhibit_on_failure = false,

  $delay_before_retry = 3,
  $nb_get_retry = 3,
  $connect_timeout = 3,
  $bindto = false,

  $url_path = '/',
  $url_digest = false,
  $url_status_code = '200',

  $connect_port = false,

  $misc_cmd = false,
  $helo_name = "loadbalancer.healthcheck.local"
) {

  validate_bool($inhibit_on_failure)
  validate_re($check_type, ['HTTP', 'SSL', 'TCP', 'SMTP', 'MISC'])

  concat::fragment {
    "keepalived.virtual_server.${virtual_server_ip}.${virtual_server_port}.real_server.${ip}":
      content => template("keepalived/real_server.erb"),
      target  => "/etc/keepalived/concat/virtual_server.${virtual_server_ip}:${virtual_server_port}",
      order   => 50;
  }

  $octet_id = values_at(split($virtual_server_ip, '[.]'), 3)
  $service_name = "ipvs_real_server_${octet_id}"
  file { "/etc/init.d/${service_name}" :
    ensure  => present,
    content => template('keepalived/debian/ipvs_real_server.init.erb'),
  }

  service { $service_name :
    enable => true,
    ensure => false,
    require => File["/etc/init.d/${service_name}"],
  }

}
