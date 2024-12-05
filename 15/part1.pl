#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 15 Part 1
#=============================================================================
# HASH
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use List::Util qw/sum/;

$logger->info("START");

my $line = <>;
chomp $line;
my @step = split",", $line;

$logger->debug("HASH=", hash("HASH"));

say sum map { hash($_) } @step;

sub hash($s)
{
    my $val = 0;
    for my $h (split //, $s)
    {
        $val = (($val + ord($h)) * 17) %256
    }
    return $val;
}

$logger->info("FINISH");
