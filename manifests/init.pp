define kernel_boot_arg ($ensure = 'present', $value = '') {
    if ($ensure != 'present' and $value != '') {
        fail("ensure ${ensure} may not be used with value parameter")
    }

    $exec_title = "kernel_bootarg_${title}"
    $exec_path = '/usr/sbin:/sbin:/usr/bin:/bin'

    $boot_arg_path = '/usr/local/bin'

    $title_value = $value ? {
        ''      => $title,
        default => "${title}=${value}",
    }

    case $::osfamily {
        'RedHat': {
            $redhat_kernel = 'ALL'

            case $ensure {
                'present': {
                    exec {
                        $exec_title:
                            command => "grubby --update-kernel ${redhat_kernel} --args '${title_value}'",
                            onlyif  => "grubby --info ${redhat_kernel} | grep args= | grep -v '[\" ]${title_value}[\" ]'",
                            path    => $exec_path;
                    }
                }
                'absent': {
                    exec {
                        $exec_title:
                            command => "grubby --update-kernel ${redhat_kernel} --remove-args '${title}'",
                            onlyif  => "grubby --info ${redhat_kernel} | grep args= | grep '[\" ]${title}[=\" ]'",
                            path    => $exec_path;
                    }
                }
                default: {
                    fail("unsupported ensure ${ensure}")
                }
            }
        }
        'Debian': {
            $debian_config_var = 'GRUB_CMDLINE_LINUX_DEFAULT'
            $debian_config_file = '/etc/sysconfig/grub'
            $debian_grub_file = '/boot/grub/grub.cfg'

            # TODO: move parameters into hiera
            class {
                'kernel_boot_arg::scripts':
                    path => $boot_arg_path;
                'kernel_boot_arg::update_grub':
                    path        => $boot_arg_path,
                    grub_file   => $debian_grub_file,
                    config_file => $debian_config_file;
            }

            # We need the scripts to run the Exec below.
            Class['kernel_boot_arg::scripts'] -> Exec[$exec_title]

            # We need the Exec to run before the update_grub recipe checks the file timestamps.
            Exec[$exec_title] -> Class['kernel_boot_arg::update_grub']

            case $ensure {
                'present': {
                    exec {
                        $exec_title:
                            command => "${boot_arg_path}/kernel_boot_arg_modify.sh ${debian_config_var} ADD ${title_value} ${debian_config_file}",
                            unless  => "${boot_arg_path}/kernel_boot_arg.pl ${debian_config_var} PRESENT ${title_value}",
                            path    => $exec_path;
                    }
                }
                'absent': {
                    exec {
                        $exec_title:
                            command => "${boot_arg_path}/kernel_boot_arg_modify.sh ${debian_config_var} REMOVE ${title} ${debian_config_file}",
                            unless  => "${boot_arg_path}/kernel_boot_arg.pl ${debian_config_var} ABSENT ${title}",
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
