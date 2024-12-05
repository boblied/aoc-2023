#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part2.pl Advent of Code 2023 Day 11 Part 2 
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use List::Util qw/all/;

$logger->info("START");

my $Expansion = ($ARGV[0] // 2); ; shift;

my @Map;
my ($Height, $Width) = (0,0);

while (<>)
{
    chomp;
    push @Map, [ split '' ];
}
$Height = $#Map;
$Width  = $Map[0]->$#*;
$logger->debug("Map as read $Height x $Width", showGrid(\@Map));

# Find original galaxy positions
my @Galaxy;
for my $row ( 0 .. $Height )
{
    for my $col ( 0 .. $Width )
    {
        push @Galaxy, [ $row, $col] if $Map[$row][$col] eq '#';
    }
}
$logger->debug("Galaxies: ", scalar(@Galaxy), " at ");
$logger->debug( "[$_] at ($Galaxy[$_]->@*)") for 0 .. $#Galaxy;

my @Shifted;
$Shifted[$_] = [ $Galaxy[$_]->@* ] for 0 .. $#Galaxy;

# Find blank rows.  Every time we find a blank row, every galaxy below
# that one shifts down by the expansion factor.
for my $row ( 0 .. $Height )
{
    if ( all { $_ eq '.' } $Map[$row]->@* )
    {
        for my $g ( 0 .. $#Galaxy )
        {
            if ( $Galaxy[$g][0] > $row )
            {
                $Shifted[$g][0] += $Expansion - 1;
                $logger->debug("Galaxy $g moved from ($Galaxy[$g]->@*) to $Shifted[$g]->@*");
            }
        }
    }
}

# Find blank columns. Shift galaxies right 
for my $col ( 0 .. $Width )
{
    if ( all { $_ eq '.' } map { $Map[$_][$col] } 0 .. $Height )
    {
        for my $g ( 0 .. $#Galaxy )
        {
            if ( $Galaxy[$g][1] > $col )
            {
                $Shifted[$g][1] += $Expansion - 1;
                $logger->debug("Galaxy $g moved from ($Galaxy[$g]->@*) to $Shifted[$g]->@*");
            }
        }
    }
}

# Calculate shifted distances for all pairs
my $Total = 0;
for my $g1 ( 0 .. $#Shifted - 1 )
{
    for my $g2 ( $g1+1 .. $#Shifted )
    {
        my $d = dist($Shifted[$g1], $Shifted[$g2]);
        $Total += $d;
        $logger->debug("Pair $g1:$g2",
                       " [$Shifted[$g1]->@* --> $Shifted[$g2]->@*]",
                       " distance=$d",
                        );
    }
}
say $Total;

sub dist($p1, $p2)
{
    return abs($p1->[0] - $p2->[0]) + abs($p1->[1] - $p2->[1]);
}

$logger->info("FINISH");
