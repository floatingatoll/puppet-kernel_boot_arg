# TODO: move parameters into hiera

class kernel_boot_arg::update_grub ($path, $grub_file, $config_file) {
    exec {
        'kernel_boot_arg_update-grub':
            command   => "update-grub",
            onlyif    => "[ ( ! -e ${debian_grub_file} ) -o ( ${debian_grub_file} -ot ${debian_config_file} ) ]",
            path      => $path;
    }
}
