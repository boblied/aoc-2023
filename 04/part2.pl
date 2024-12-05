#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part2.pl Advent of Code 2023 Day 04 Part 2
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;

use List::Util qw/sum/;

use Getopt::Long;
my $Verbose = 0;
GetOptions("verbose" => \$Verbose);

# Find numbers that occur more than once
sub countMatch($n)
{
    my %seen;
    $seen{$_}++ for $n->@*;
    return scalar grep { $seen{$_} > 1 } keys %seen;
}

# Make one pass to save number of matches on each card
my @Match;
while (<>)
{
    my @n = m/(\d+)/g; # Extract all the numbers
    my $id = shift @n; # Remove the id number

    $Match[$id] = countMatch(\@n);
}

my @Count = (0) x @Match;   # Array same size as Match
sub countCard($id, $indent) # Recursive
{
    $Count[$id]++;
    say "${indent}[$id] -> $Match[$id], $Count[$id]" if $Verbose;
    return if $Match[$id] == 0;

    for my $next ( $id+1 .. $id + $Match[$id] )
    {
        countCard($next, "  $indent") if exists $Match[$next];
    }
}

countCard($_, "") for 1 .. $#Match;
say sum @Count;
