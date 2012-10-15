# = Class: gerrit
#
# This is the main gerrit class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*gerrit_version*]
#   Version of gerrit to install
#
# [*gerrit_group*]
#   Name of group gerrit runs under
#
# [*gerrit_gid*]
#   GroupId of gerrit_group
#
# [*gerrit_user*]
#   Name of user gerrit runs under
#
# [*gerrit_uid*]
#   UserId of gerrit_user
#
# [*gerrit_home*]
#   Home-Dir of gerrit user
#
# == Author
#   Robert Einsle <robert@einsle.de>
#
class gerrit (
    $gerrit_version       = params_lookup('gerrit_version'),
    $gerrit_group         = params_lookup('gerrit_group'),
    $gerrit_gid           = params_lookup('gerrit_gid'),
    $gerrit_user          = params_lookup('gerrit_user'),
    $gerrit_home          = params_lookup('gerrit_home'),
    $gerrit_uid           = params_lookup('gerrit_uid'),
    $gerrit_database_type = params_lookup('gerrit_database_type')
    ) inherits gerrit::params {

    # Install required packages
    package { [ 
                "wget",
                "openjdk-6-jdk",
              ]:
        ensure => installed,
    }

    # Crate Group for gerrit
    group { $gerrit_group:
        gid        => "$gerrit_gid", 
        ensure     => "present",
    }

    # Create User for gerrit-home
    user { $gerrit_user:
        comment    => "User for gerrit instance",
        home       => "$gerrit_home",
        shell      => "/bin/false",
        uid        => "$gerrit_uid",
        gid        => "$gerrit_gid",
        ensure     => "present",
        managehome => true,
        require    => Group["$gerrit_group"]
    }

    # Funktion für Download eines Files per URL
    exec { "download_gerrit":
        command => "wget -q '$uri' -O $name",
        creates => ${gerrit_home}/gerrit-${gerrit_version}.war,
        timeout => $timeout,
        require => Package["wget"],
    }

    # download gerrit
    download {
        "${gerrit_home}/gerrit-${gerrit_version}.war":
            uri => "http://gerrit.googlecode.com/files/gerrit-${gerrit_version}.war",
    }

    # Initialisation of gerrit site
    exec {
        "init_gerrit":
            command => "java -jar $gerrit_home/gerrit-$gerrit_version.war init -d $gerrit_home/review_site --batch --no-auto-start",
            creates => "$gerrit_home/review_site",
            require => [
                            Package["openjdk-6-jdk"],
                            Exec["download_gerrit"],
                        ],
    }

}
