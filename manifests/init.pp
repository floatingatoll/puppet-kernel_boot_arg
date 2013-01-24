# TODO: add debian support somehow

define kernel_boot_arg ($ensure = 'present', $value = '') {
    if ($ensure != 'present' and $value != '') {
        fail("ensure ${ensure} may not be used with value parameter")
    }

    $kernel = 'ALL'

    $exec_title = "${kernel}_${title}"
    $exec_path = '/usr/sbin:/sbin:/usr/bin:/bin'

    $boot_arg_path = '/usr/local/bin'

    $title_value = $value ? {
        ''      => $title,
        default => "${title}=${value}",
    }

    case $::osfamily {
        'RedHat': {
            case $ensure {
                'present': {
                    exec {
                        $exec_title:
                            command => "grubby --update-kernel ${kernel} --args '${title_value}'",
                            onlyif  => "grubby --info ${kernel} | grep args= | grep -v '[\" ]${title_value}[\" ]'",
                            path    => $exec_path;
                    }
                }
                'absent': {
                    exec {
                        $exec_title:
                            command => "grubby --update-kernel ${kernel} --remove-args '${title}'",
                            onlyif  => "grubby --info ${kernel} | grep args= | grep '[\" ]${title}[=\" ]'",
                            path    => $exec_path;
                    }
                }
                default: {
                    fail("unsupported ensure ${ensure}")
                }
            }
        }
        'Debian': {
            fail("unimplemented ::osfamily ${::osfamily}")

            $debian_config_var = 'GRUB_CMDLINE_LINUX_DEFAULT'
            $debian_config_file = '/etc/sysconfig/grub'

            file {
                "${boot_arg_path}/boot_arg.pl":
                    ensure => present,
                    before => Exec[$exec_title],
                    owner  => root,
                    group  => root,
                    mode   => '0755',
                    source => 'puppet:///modules/kernel/boot_arg.pl';
            }

            case $ensure {
                'present': {
                    exec {
                        $exec_title:
                            command => "${boot_arg_path}/boot_arg.pl ${debian_config_var} ADD ${title_value} < ${debian_config_file} > ...", # TODO
                            unless  => "${boot_arg_path}/boot_arg.pl ${debian_config_var} PRESENT ${title_value}",
                            path    => $exec_path;
                    }
                }
                'absent': {
                    exec {
                        $exec_title:
                            command => "${boot_arg_path}/boot_arg.pl ${debian_config_var} REMOVE ${title} < ${debian_config_file} > ...", # TODO
                            unless  => "${boot_arg_path}/boot_arg.pl ${debian_config_var} ABSENT ${title}",
                            path    => $exec_path;
                    }
                }
                default: {
                    fail("unsupported ensure ${ensure}")
                }
            }
        }
        default: {
            fail("unsupported ::osfamily ${::osfamily}")
        }
    }
}
