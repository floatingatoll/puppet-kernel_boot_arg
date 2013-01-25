class kernel_boot_arg::update_grub ($grub_file = hiera('kernel_boot_arg_debian_grub_file'), $config_file = hiera('kernel_boot_arg_debian_config_file')) {
    exec {
        'kernel_boot_arg_update-grub':
            command   => "update-grub",
            onlyif    => "[ ! -e ${grub_file} ] || [ ${grub_file} -ot ${config_file} ]",
            path      => '/usr/sbin:/sbin:/usr/bin:/bin';
    }
}
