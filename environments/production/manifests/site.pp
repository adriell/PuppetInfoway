node 'infoway.puppet.lan'{
  class {'::ntp':
      servers => ['ntp.pop-pi.rnp.br','ntp.pop-pe.rnp.br','ntp.pop-ba.rnp.br']
    }

    class {'java':
      distribution          => 'jdk',
      java_alternative_path => '/opt/java'

    }
    class { 'zabbix::agent':
        server => '10.0.0.10',
    }

    package{'epel-release':
      ensure => present,
    }
    package{ [ 'screen',
        'wget',
        'unzip',
        'tcpdump',
        'htop',
        'nmap', ]:
        ensure  => installed,
        require => Package['epel-release']
    }

      $ds_resource_name = hiera('tomcat::data_source::ds_resource_name')
      $ds_max_wait = hiera('tomcat::data_source::ds_max_wait')
      $ds_username = hiera('tomcat::data_source::ds_username')
      $ds_password = hiera('tomcat::data_source::ds_password')
      $ds_driver_class_name = hiera('tomcat::data_source::ds_driver_class_name')
      $ds_driver = hiera('tomcat::data_source::ds_driver')
      $ds_dbms = hiera('tomcat::data_source::ds_dbms')
      $ds_host = hiera('tomcat::data_source::ds_host')
      $ds_port = hiera('tomcat::data_source::ds_port')
      $ds_service = hiera('tomcat::data_source::ds_service')
      $ds_url = "${ds_driver}:${ds_dbms}:thin:@${ds_host}:${ds_port}/${ds_service}"
      
      
      $http_port = hiera('tomcat::params::http_port')
      $https_port = hiera('tomcat::params::https_port')
      $ajp_port = hiera('tomcat::params::ajp_port')
      $shutdown_port = hiera('tomcat::params::shutdown_port')
      $http_connection_timeout = hiera('tomcat::params::http_connection_timeout')
      $https_max_threads = hiera('tomcat::params::https_max_threads')           
      $https_keystore_pwd = hiera('tomcat::params::https_keystore_pwd')
      
      $tomcat_roles = hiera('tomcat::roles::list')
      # Set Users
      $tomcat_users = hiera('tomcat::users::list')
      # Set Mapping users-roles
      $tomcat_map = hiera('tomcat::users::map')
      
      tomcat::setup { "tomcat":
         family => "7",
         update_version => "64",
         extension      => ".tar.gz",
         source_mode    => "web",
         installdir     => "/opt/",
         #tmpdir         => "/tmp/",
         install_mode   => "custom",
         data_source    => "yes",
         driver_db      => "yes",
         ssl            => "no",
         users          => "yes",
         access_log     => "yes",
         as_service     => "yes",
         direct_start => "yes"

      }
      tomcat::deploy { "deploy":
          war_name             => "quantum-1.0.2.war",
          war_versioned        => "yes",
          deploy_path          => "/home/quantum/web",
          context              => "/quantum",
          symbolic_link        => "yes",
          #external_conf        => "yes",
          #external_dir        => "report/",
          #external_conf_path  => "/conf/",
          family               => "7",
          update_version       => "55",
          installdir           => "/home/app",
          tmpdir               => "/tmp/",
          hot_deploy           => "yes",
          as_service           => "yes",
          direct_restart       => "no",
          require              => Tomcat::Setup["tomcat"]
          }
}
