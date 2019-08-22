class kernel_boot_arg::grubby {
    package {
        'grubby':
            ensure => latest;
    }
}
