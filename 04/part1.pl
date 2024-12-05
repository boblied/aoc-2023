#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl Advent of Code 2023 Day 04 Part 1
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";

use List::Util qw/uniqint/;

use Getopt::Long;
my $Verbose = 0;

GetOptions("verbose" => \$Verbose);

sub check($win, $pick)
{
    my %seen;
    $seen{$_}++ for $win->@*, $pick->@*;
    return scalar( grep { $seen{$_} > 1 } keys %seen );
}

my $score = 0;
while (<>)
{
    chomp;
    my @part = split /[:|]/;

    my @win  = split(" ", $part[1]);
    my @pick = split(" ", $part[2]);

    my $win = check(\@win, \@pick);
    next if $win == 0;

    $score += 2 ** ($win-1);
    say "$part[0] win=$win score=$score " if $Verbose;
}
say $score;
