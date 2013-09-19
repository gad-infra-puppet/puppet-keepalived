class keepalived(
  $email,
  $smtp_server = '127.0.0.1',
  $ensure_runing = true,
) {

  package {
    "keepalived":
      ensure => installed;
  }

  if $ensure_runing {
    service {
      "keepalived":
        ensure     => running,
        require    => Package["keepalived"],
        hasrestart => true,
        status     => 'pgrep keepalived',
        subscribe  => File["/etc/keepalived/concat/top"];
    }
  } else {
    service {
      "keepalived":
        require    => Package["keepalived"],
        hasrestart => true,
        status     => 'pgrep keepalived',
        subscribe  => File["/etc/keepalived/concat/top"];
    }   
  }


  file {
    '/etc/keepalived/concat':
      ensure  => directory,
      require => Package['keepalived'];
  }

  file {
    '/etc/keepalived/keepalived.conf':
      ensure  => present,
      source  => '/etc/keepalived/concat.out',
      require => Exec['concat_keepalived.conf'];

    '/etc/keepalived/concat.out':
      notify => Exec['concat_keepalived.conf'];
  }

  exec {
    'concat_keepalived.conf':
      command     => '/bin/cat /etc/keepalived/concat/* > /etc/keepalived/concat.out',
      refreshonly => true,
      notify      => Service['keepalived'];
  }

  concat {
    '/etc/keepalived/concat/top':
      warn    => true,
      require => Package['keepalived'],
      notify  => Exec['concat_keepalived.conf'];
  }

  concat::fragment {
    'keepalived.global_defs':
      content => template("keepalived/global_defs.erb"),
      order   => 01,
      target  => '/etc/keepalived/concat/top';
  }

}
