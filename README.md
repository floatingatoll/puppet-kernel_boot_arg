puppet-kernel_boot_arg
======================

Puppet module to set kernel boot args.

Usage:

    kernel_boot_arg {
        'audit':
            value => '1';
        'unwanted':
            ensure => absent;
    }

Fedora/RHEL users:
- grubby is used to set the parameter on 'ALL' kernels, including the rescue ones.

Debian/Ubuntu users:
- update-grub will be run whenever /etc/default/grub is older than /boot/grub/grub.cfg.

General notes:
- ensure => absent accepts only a parameter name, refusing to proceed if a value is provided.
