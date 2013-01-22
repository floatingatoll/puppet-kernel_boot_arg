# TODO: verify that present and absent work as expected
# TODO: add debian support somehow

define kernel_boot_arg ($ensure = 'present', $value = '') {
    $exec_title = "${kernel}_${title}"

    case $::osfamily {
        'RedHat': {
            $kernel = 'ALL'

            $title_value = $value ? {
                ''      => $title,
                default => "${title}=${value}",
            }

            case $ensure {
                'present': {
                    exec {
                        $exec_title:
                            command => "grubby --update-kernel ${kernel} --args '${title_value}'",
                            onlyif  => "grubby --info ${kernel} | grep args= | grep -v '[\" ]${title_value}[\" ]'";
                    }
                }
                'absent': {
                    exec {
                        $exec_title:
                            command => "grubby --update-kernel ${kernel} --remove-args '${title_value}'",
                            onlyif  => "grubby --info ${kernel} | grep args= | grep '[\" ]${title_value}[\" ]'";
                    }
                }
            }
        }
        default: {
            fail("unsupported ::osfamily ${::osfamily}")
        }
    }
}
