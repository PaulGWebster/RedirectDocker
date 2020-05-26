#!/usr/bin/env perl

use warnings;
use strict;
use feature 'say';

say 'Looking for nginx vhost mappings under NGINX_VHOST_<POOLNAME>';

my $template = do {
    local $/;
    open(my $fh,'<','/etc/nginx/conf.d/vhost.template') or die $!;
    my $file = <$fh>;
    close($fh);
    $file
};

foreach my $env_var (keys %ENV) {
    my $key;
    my $val;
    if ($env_var =~ m/^NGINX_VHOST_(.*)$/) {
        $key = $1;
        $val = $ENV{$env_var};
    }
    else {
        next;
    }

    my ($domain,$httphost,$httpport,$httpshost,$httpsport) = 
        split(/:/,$val);

    if (!$key || !$val || !$httpsport || $val =~ m/ / || $key eq 'default') {
        say "Ignoring: NGINX_VHOST_$val (invalid definition)";
        say "Example format, NGINX_VHOST_TESTSITE=www.example.com:web:8080:web:8080";
        say 'Syntax: DOMAIN:TARGET_HTTP_HOST:TARGET_HTTP_PORT:TARGET_HTTPS_HOST';
        say 'default cannot be used as a NAME';
        next;
    }

    write_vhost($key,$domain,$httphost,$httpport,$httpshost,$httpsport);
}

sub write_vhost {
    my ($poolname,$domain,$httphost,$httpport,$httpshost,$httpsport) = @_;

    my $base = "$template";

    $base =~ s/__SERVERNAME__/$domain/g;
    $base =~ s/__POOLNAME__/$poolname/g;
    $base =~ s/__HTTPHOST__/\Q$httphost\E/g;
    $base =~ s/__HTTPSHOST__/$httpshost/g;
    $base =~ s/__HTTPPORT__/\Q$httpport\E/g;
    $base =~ s/__HTTPSPORT__/$httpsport/g;

    my $path = join('','/etc/nginx/conf.d/',$domain,'.conf');
    open(my $fh,'>',$path);
    print $fh $base;
    close($fh);

    say "Generated:\n$base";
}

exit;