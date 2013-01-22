# TODO: verify that present and absent work as expected
# TODO: fix the greps for arg=arg=arg= issues
# TODO: add debian support somehow

class kernel_boot_arg ($ensure = 'present', $value = '') {
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
                            unless  => "grubby --info ${kernel} | grep args= | grep '${title_value}'";
                    }
                }
                'absent': {
                    exec {
                        $exec_title:
                            command => "grubby --update-kernel ${kernel} --remove-args '${title}'",
                            unless  => "grubby --info ${kernel} | grep args= | grep -v '${title}='";
                    }
                }
            }
        }
        default: {
            fail("unsupported ::osfamily ${::osfamily}")
        }
    }
}
