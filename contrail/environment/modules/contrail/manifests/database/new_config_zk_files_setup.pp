class contrail::database::new_config_zk_files_setup (
  $contrail_logoutput = $::contrail::params::contrail_logoutput,
  $database_index = 1
) {
  # set high session timeout to survive glance led disk activity
  $zk_cfg = { 'zk_cfg' =>
                { 'maxSessionTimeout' => "120000",
                  'autopurge.purgeInterval' => "3",
                },
  }
  contrail::lib::augeas_conf_set { 'zk_cfg_keys':
           config_file => '/etc/zookeeper/conf/zoo.cfg',
           settings_hash => $zk_cfg['zk_cfg'],
           lens_to_use => 'properties.lns',
  } ->
  file {'/etc/zookeeper/conf/log4j.properties':
             ensure => present,
  } ->
  contrail::lib::augeas_conf_set { 'log4j.appender.ROLLINGFILE.MaxBackupIndex':
          config_file => '/etc/zookeeper/conf/log4j.properties',
          settings_hash => { 'log4j.appender.ROLLINGFILE.MaxBackupIndex' => "11",},
          lens_to_use => 'properties.lns',
  } ->
  file {'/etc/zookeeper/conf/myid':
      ensure => present,
      mode    => '0755',
      content => "${database_index}",
  }

  case $::operatingsystem {
          'Ubuntu': {
              Contrail::Lib::Augeas_conf_set['log4j.appender.ROLLINGFILE.MaxBackupIndex'] ->
              file {'/etc/zookeeper/conf/environment':
                   ensure => present,
              } ->
              file_line { 'Add ZOO_LOG4J_PROP to Zookeeper env':
                   path => '/etc/zookeeper/conf/environment',
                   line => "ZOO_LOG4J_PROP=\"INFO,CONSOLE,ROLLINGFILE\"",
                   match   => "ZOO_LOG4J_PROP=.*$",
              } ->
              File['/etc/zookeeper/conf/myid']
          }
          'Centos', 'Fedora' : {
              Contrail::Lib::Augeas_conf_set['log4j.appender.ROLLINGFILE.MaxBackupIndex'] ->
              file {'/etc/zookeeper/zookeeper-env.sh':
                  ensure => present,
              } ->
              file_line { 'Add ZOO_LOG4J_PROP to Zookeeper env':
                path => '/etc/zookeeper/zookeeper-env.sh',
                line => 'export ZOO_LOG4J_PROP=\"INFO,CONSOLE,ROLLINGFILE\"',
              } ->
              File['/etc/zookeeper/conf/myid']
          }
  }
}
