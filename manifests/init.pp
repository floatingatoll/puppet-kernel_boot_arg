define kernel_boot_arg (Enum['present', 'absent'] $ensure = 'present',
                        String $value = ''
) {
    if ($ensure != 'present' and $value != '') {
        fail("ensure ${ensure} may not be used with value parameter")
    }

    $exec_title = "kernel_bootarg_${title}"
    $exec_path = '/usr/sbin:/sbin:/usr/bin:/bin'

    $title_value = $value ? {
        ''      => $title,
        default => "${title}=${value}",
    }

    case $::osfamily {
        'RedHat': {
            $redhat_kernel = 'ALL'

            # RHEL6 ships a buggy grubby that doesn't update all kernels, fixed in 7.0.15-3.el6.
            if $::operatingsystemrelease =~ /^6/ {
                include kernel_boot_arg::grubby
            }

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
            include kernel_boot_arg::scripts
            include kernel_boot_arg::update_grub

            $boot_arg_path = lookup('kernel_boot_arg_path')
            $debian_config_var = lookup('kernel_boot_arg_debian_config_var')
            $debian_config_file = lookup('kernel_boot_arg_debian_config_file')

            # We need the scripts to run the Exec below.
            Class['kernel_boot_arg::scripts'] -> Exec[$exec_title]

            # We need the Exec to run before the update_grub recipe checks the file timestamps.
            Exec[$exec_title] -> Class['kernel_boot_arg::update_grub']

            case $ensure {
                'present': {
                    exec {
                        $exec_title:
                            command => "${boot_arg_path}/kernel_boot_arg_modify.sh ${boot_arg_path}/kernel_boot_arg.pl ${debian_config_var} ADD ${title_value} ${debian_config_file}",
                            unless  => "${boot_arg_path}/kernel_boot_arg.pl ${debian_config_var} PRESENT ${title_value} < ${debian_config_file}",
                            path    => $exec_path;
                    }
                }
                'absent': {
                    exec {
                        $exec_title:
                            command => "${boot_arg_path}/kernel_boot_arg_modify.sh ${boot_arg_path}/kernel_boot_arg.pl ${debian_config_var} REMOVE ${title} ${debian_config_file}",
                            unless  => "${boot_arg_path}/kernel_boot_arg.pl ${debian_config_var} ABSENT ${title} < ${debian_config_file}",
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
