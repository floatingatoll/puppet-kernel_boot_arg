#!/usr/bin/perl

use strict;

my($variable, $command, $key_value) = @ARGV;

sub usage ($) {
    die "$_[0]\n\nUsage: $0 CONFIG_VARIABLE <ADD|REMOVE|PRESENT|ABSENT> key_name[=key_value] < /etc/default/input > /tmp/output\n";
}

# sanity check the inputs
if ($variable !~ /^[A-Za-z0-9_]+$/) {
    usage "invalid variable";
}
if ($command !~ /^(ADD|REMOVE|PRESENT|ABSENT)$/) {
    usage "invalid command";
}
if ($key_value =~ /[" ]/ || not defined $key_value) {
    usage "invalid key/value";
}
if ($command =~ /REMOVE|ABSENT/ && $key_value =~ /=/) {
    usage "can't ${command} a key when a value is specified";
}

my($key, $value) = split(/=/, $key_value, 2);

# This is set to 1 only if all VARIABLE= lines contain the correct key_value.
my $checked = 0;

LINE: while (<STDIN>) {
    unless (/^${variable}=/) {
        print $_ unless $command =~ /PRESENT|ABSENT/;
        next LINE;
    }
    die "invalid line found" unless s/^${variable}="\s*(?=\S)// && s/(?<=\S)\s*"$// && ! /"/;
    # We found a line with the config variable, so reset $checked.
    $checked = 0;
    my(@args) = split(/\s+/, $_);
    my $found = 0;
    for my $arg (0..$#args) {
        # does this argument's key match the new value's key?
        if ($args[$arg] =~ /^${key}(=|$)/) {
            # it does match.
            if ($command eq 'ADD' && $found == 0) {
                # this is the first time it matched, so replace the value.
                $args[$arg] = $key_value;
            } elsif ($command eq 'REMOVE') {
                # it does match, but remove it.
                $args[$arg] = '';
            } elsif ($command eq 'ABSENT') {
                die "absent failed";
            } elsif ($command eq 'PRESENT') {
                # does it match?
                if ($args[$arg] eq $key_value) {
                    # it does, so continue.
                    $checked = 1;
                } else {
                    # it doesn't, so skip the rest of the file.
                    $checked = 0;
                    last LINE;
                }
            }
            # we set the new value in the arguments list.
            $found = 1;
        }
    }
    # if we didn't set the new value above, append it here if necessary.
    if ($command eq 'ADD' && $found == 0) {
        push @args, $key_value;
    }
    # emit the final result
    printf "${variable}=\"%s\"\n", join(" ", grep { length($_) > 0 } @args) unless $command =~ /PRESENT|ABSENT/;
}

if ($command eq 'PRESENT') {
    # if no matches were found, abort.
    if ($checked == 1) {
        warn "present okay";
    } else {
        die "present failed";
    }
} elsif ($command eq 'ABSENT') {
    warn "absent okay";
}

# completed successfully.
exit 0;
