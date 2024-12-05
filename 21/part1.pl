#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 21 Part 1
#=============================================================================
#  
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;
use AOC::Grid;

use List::Util qw/sum0/;
use List::MoreUtils qw/arrayify/;

my $StepGoal = shift;;

$logger->info("START");

my $Grid = AOC::Grid::loadGrid();
$logger->info("Grid ", $Grid->height()," X ",$Grid->width(), $Grid->show);

my @Start;
FindStart:
for my $r ( 0 .. $Grid->height() )
{
    for my $c ( 0 .. $Grid->width() )
    {
        if ( $Grid->get($r, $c) eq "S" )
        {
            @Start = ($r, $c);
            last FindStart;
        }
    }
}
$logger->info("Start at (@Start)");

my $Count = walk($Grid, $StepGoal, @Start);

say $Count;


$logger->info("FINISH");

my @at;
sub walk($g, $stepGoal, @loc)
{
    push @at, [ @loc ];


    my $count = 0;
    for ( 1 .. $stepGoal )
    {
        $count = step($g, \@at);
        $logger->debug("Step $_: count=$count", $g->show());
    }
    return $count;
}

sub step($g, $at)
{
    my @next;
    my $count = 0;
    # Step off all the places where we were last time
    $g->set(@$_, ".") for $at->@*;

    while ( defined(my $loc = shift @$at) )
    {
        $count++;
        for ( grep { $g->get(@$_) eq "." } $g->neighborNESW(@$loc) )
        {
            $g->set(@$_, "O");
            push @next, $_;
        }
    }
    @$at = @next;
    return scalar(@next);
}
