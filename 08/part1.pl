#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl Advent of Code Day 08 Part 1
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use builtin qw/trim true false/; no warnings "experimental::builtin";

use Getopt::Long;
my $Verbose = 0;
GetOptions("verbose" => \$Verbose);

my @Step;
{ @Step = split "", trim(my $s = <>); }    # First line, directions
my %Graph;

while (<>)
{
    chomp;
    next if $_ eq "";
    my ($node, $left, $right) = m/([A-Z]+)/g;
    $Graph{$node} = { L => $left, R => $right };
}

my $node = 'AAA';
my $end  = 'ZZZ';

my $step = 0;
my $count = 0;
while ( $node ne $end )
{
    my $dir = $Step[$step++];
    $step = 0 if $step == scalar(@Step);

    print "At $node -> $dir " if $Verbose;
    $node = $Graph{$node}{$dir};

    $count++;
    say "$node, count=$count if $Verbose";
}
say $count;
