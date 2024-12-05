#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 19 Part 2
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use List::Util qw/sum/;
use Data::Dumper; $Data::Dumper::Sortkeys=1; $Data::Dumper::Indent=0;

my @Task;

use constant    { X => 0, M => 1, A => 2, S => 3 };
my %Category  = ( x => 0, m => 1, a => 2, s => 3 );

my %Range = ( x => [ [1,4000] ],
              m => [ [1,4000] ],
              a => [ [1,4000] ],
              s => [ [1,4000] ]
);

$logger->info("START");

readInput();
$logger->debug("IN queue: ", Dumper(\@WorkStack));

sub findRange();

say $TotalRating;

$logger->info("FINISH");

sub readInput()
{
    while (<>)
    {
        chomp;
        if ( my @flow = m/^(\w+)\{([^}]+)}/a )
        {
            push @Task, parseWork($flow[1]);
        }
    }
}

sub parseWork($w)
{
    my @list;
    for ( split ',', $w )
    {
        if ( m/(\w)([<>])(\d+):(\w+)/a )
        {
            push @list, { next => $4, cmp => $2, cat => $Category{$1}, val => $3 };
        }
        elsif ( m/(\w+)/a )
        {
            push @list, { next => $1, cmp => "=", cat => -1, val => -1 }
        }
    }
    return \@list;
}

sub findRange()
{
}

sub rngGT($rngList, $val)
{
    my @keep;
    for my $rng ( $rngList->@* )
    {
        next if $rng->[1] <= $val;
        if ( $val >= $rng->[0] && $val <= $rng->[1] )
        {
            $rng->[0] = $val + 1;
            next if $rng->[0] > $rng->[1];
        }
        push @keep, $rng;
    }
    return \@keep;

}
sub rngLT($rngList, $val)
{
    my @keep = grep { $val < $_->[1] } $rngList;
}
