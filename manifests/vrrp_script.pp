define keepalived::vrrp_script(
  $script_command,
  $interval = 2,
  $weight = 2,
) {

  concat::fragment {
    "keepalived.vrrp_script_${name}":
      content => template("keepalived/vrrp_script.erb"),
      target  => '/etc/keepalived/concat/top',
      order   => 03;
  }

}
