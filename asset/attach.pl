#!/usr/bin/env perl

use warnings;
use strict;
use feature 'say';

use POE qw(Wheel::FollowTail);

POE::Session->create(
    inline_states => {
        _start => sub {
            my ($kernel,$heap) = @_[KERNEL,HEAP];

            $heap->{error_log} = POE::Wheel::FollowTail->new(
                Filename    => "/var/log/nginx/error.log",
                InputEvent  => "got_log_line_error",
                ResetEvent  => "got_log_rollover_error",
            );
            $heap->{access_log} = POE::Wheel::FollowTail->new(
                Filename    => "/var/log/nginx/access.log",
                InputEvent  => "got_log_line_access",
                ResetEvent  => "got_log_rollover_access",
            );
        },
        got_log_line_error => sub {
            my ($kernel,$heap,$line) = @_[KERNEL,HEAP,ARG0];
            chomp($line);
            say STDERR "error.log: $line";
        },
        got_log_rollover_error => sub {
            my ($kernel,$heap,$line) = @_[KERNEL,HEAP,ARG0];
            say STDERR "error.log: Logfile roll-over";
        },
        got_log_line_access => sub {
            my ($kernel,$heap,$line) = @_[KERNEL,HEAP,ARG0];
            chomp($line);
            say STDERR "access.log: $line";
        },
        got_log_rollover_access => sub {
            my ($kernel,$heap,$line) = @_[KERNEL,HEAP,ARG0];
            say STDERR "access.log: Logfile roll-over";
        },
    }
);
 
POE::Kernel->run();
exit;
