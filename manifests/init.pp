# TODO: verify this works with non-value parameters eg. noacpi, quiet
# TODO: verify that present and absent work as expected
# TODO: fix the greps for arg=arg=arg= issues
# TODO: add debian support somehow

class kernel_boot_arg ($ensure = 'present', $value = undef) {
    $exec_title = "${kernel}_${title}"

    case $::osfamily {
        'RedHat': {
            $kernel = 'ALL'

            case $ensure {
                'present': {
                    exec {
                        $exec_title:
                            command => "grubby --update-kernel ${kernel} --args '${title}=${value}'",
                            unless  => "grubby --info ${kernel} | grep args= | grep '${title}=${value}'";
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
