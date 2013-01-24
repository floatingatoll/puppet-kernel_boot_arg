# TODO: add debian support somehow

define kernel_boot_arg ($ensure = 'present', $value = '') {
    if ($ensure != 'present' and $value != '') {
        fail("ensure ${ensure} may not be used with value parameter")
    }

    $kernel = 'ALL'
    $exec_title = "${kernel}_${title}"
    $exec_path = '/usr/sbin:/sbin:/usr/bin:/bin'

    case $::osfamily {
        'RedHat': {
            case $ensure {
                'present': {
                    $title_value = $value ? {
                        ''      => $title,
                        default => "${title}=${value}",
                    }

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
            }
        }
        default: {
            fail("unsupported ::osfamily ${::osfamily}")
        }
    }
}
