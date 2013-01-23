# TODO: add debian support somehow

define kernel_boot_arg ($ensure = 'present', $value = '') {
    $exec_title = "${kernel}_${title}"

    case $::osfamily {
        'RedHat': {
            $kernel = 'ALL'

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
                            path    => "/usr/sbin:/sbin:/usr/bin:/bin";
                    }
                }
                'absent': {
                    if ($value != '') {
                        fail("ensure ${ensure} may not be used with value parameter")
                    }

                    exec {
                        $exec_title:
                            command => "grubby --update-kernel ${kernel} --remove-args '${title}'",
                            onlyif  => "grubby --info ${kernel} | grep args= | grep '[\" ]${title}[=\" ]'",
                            path    => "/usr/sbin:/sbin:/usr/bin:/bin";
                    }
                }
            }
        }
        default: {
            fail("unsupported ::osfamily ${::osfamily}")
        }
    }
}
