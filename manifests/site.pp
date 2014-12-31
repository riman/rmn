class update_start {
  notify {"Starting configuration update":}
}

class vars{
  notice("We're in ${::osfamily} system")
  case $::osfamily {
    "windows": {
      $binaries_repository_path = "g:\\WORK\\ArtefactsRepository"
      $sublime2 = "Sublime Text 2.0.2"
      notice("binaries_repository_path = ${binaries_repository_path}")
      notice("sublime2 = ${sublime2}")
    }
    default: {
      notice("We're in friendly ${::osfamily} system")
    }
  }
}

node 'Weee-PC' {
  include vars
  package { $vars::sublime2:
    ensure => 'installed',
    source => "${vars::binaries_repository_path}\\Sublime\\Sublime Text 2.0.2 x64 Setup.exe",
    install_options => ['/VERYSILENT', '/NORESTART', '/TASKS="contextentry"'],
  }
}

node 'rmn000767' {
  include update_start
  package {'mc' : 
    ensure            => present,
    allow_virtual     => false,
  }
  package {'vim-enhanced' :
    ensure            => present,
    allow_virtual     => false,
  }
  package {'ant' :
    ensure            => present,
    allow_virtual     => false,
  }
  package {'gcc' :
    ensure            => present,
    allow_virtual     => false,
  }
  user {'kanna':
    ensure => present,
  }


  # Installing Maven repository
  $central = {
    id => "central",
    url => "http://repo.maven.apache.org/maven2",
    mirrorof => "external:*",      # if you want to use the repo as a mirror, see maven::settings below
  }
  # Install Maven
  class {"maven::maven":
    version => "3.2.2",
    repo => {
      #url => "http://repo.maven.apache.org/maven2",
      #username => "",
      #password => "",
    }, 
    require => User['maven'],
  } ->
  # Setup a .mavenrc file for the specified user
  maven::environment { 'maven-env' : 
      user => 'root',
      # anything to add to MAVEN_OPTS in ~/.mavenrc
      maven_opts => '-Xmx1384m',       # anything to add to MAVEN_OPTS in ~/.mavenrc
      maven_path_additions => "",      # anything to add to the PATH in ~/.mavenrc
   } ->
   # Create a settings.xml with the repo credentials
  maven::settings { 'maven-user-settings' :
    mirrors => [$central], # mirrors entry in settings.xml, uses id, url, mirrorof from the hash passed
    servers => [$central], # servers entry in settings.xml, uses id, username, password from the hash passed
    user    => 'maven',
  }
   # defaults for all maven{} declarations
  Maven {
    user  => "maven", # you can make puppet run Maven as a specific user instead of root, useful to share Maven settings and local repository
    group => "maven", # you can make puppet run Maven as a specific group
    repos => "http://repo.maven.apache.org/maven2"
  }
  user {'maven':
    ensure => present,
    gid => ["maven"],
    password => 'maven_secret_password',
  }
  group {'maven':
    ensure => present,
  }
  file {'/home/maven':
    ensure => directory,
    owner => 'maven',
    group => 'maven',
    require => User['maven']
  }
}

