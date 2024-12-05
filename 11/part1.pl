#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 11 Part 1
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

$logger->info("START");

use List::Util qw/all sum/;

my @Map;
my ($Height, $Width) = (0,0);
while (<>)
{
    chomp;
    push @Map, [ split('', $_) ]; $Height++;
    if ( ! m/[^.]/ )
    {
        push @Map, [ split('', $_) ];
        $logger->debug("Inserted blank row at $Height");
    }
}
$Height = $#Map;
$Width = $Map[0]->$#*;
$logger->debug("Map as read $Height x $Width", showGrid(\@Map));

# Find any columns that are blank, splice in an extra column
for ( my $col = 0 ; $col <= $Map[0]->$#* ; $col++ )
{
    if ( all { $_ eq '.' } map { $Map[$_][$col] } 0 .. $Height )
    {
        $logger->debug("Inserted blank column at $col");
        splice(@{$Map[$_]}, $col, 0, ".") for 0 .. $Height;
        $col++;
    }
}
$Width = $Map[0]->$#*;
$logger->debug("Map after expansion $Height x $Width", showGrid(\@Map));

# Find galaxy locations
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

# Every pair of galaxies
my $Total = 0;
for my $g1 ( 0 .. $#Galaxy - 1 )
{
    for my $g2 ( $g1+1 .. $#Galaxy )
    {
        my $d = dist($Galaxy[$g1], $Galaxy[$g2]);
        $Total += $d;
        $logger->debug("Pair $g1:$g2",
                       " [$Galaxy[$g1]->@* --> $Galaxy[$g2]->@*]",
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
