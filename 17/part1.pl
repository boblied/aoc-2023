#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 17 Part 1
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use List::Util qw/min/;

use AOC::Grid;
use lib ".";
use Crucible;

$logger->info("START");

my $Map = AOC::Grid::loadGrid();
my @Goal = ($Map->height, $Map->width);

my $MinLoss = my $MaxLoss = ($Map->height+1) * ($Map->width+1) * 10;

$logger->info( "Map: (@Goal), min=$MinLoss", $Map->show );

my $heatLoss = findPath($Map);
#say $MinLoss;
say $heatLoss;

sub findPath($map)
{
    return astar($map, [0,0], \@Goal);
    #return navigate($map, \@Goal, 1, 3);
}

$logger->info("FINISH");

use List::PriorityQueue;

sub h($grid, $row, $col)
{
    my $dist = (abs($Goal[0] - $row) + abs($Goal[1] - $col));
}

sub str(@n) { local $"=","; qq(@n) }

sub reconstruct($g, $at, $hist)
{
    my @path = ( $at );
    while ( $hist->{$at} )
    {
        unshift @path, $hist->{$at};
        $at = $hist->{$at};
    }
    return join(" -> ", @path);
}

sub navigate($g, $goal, $minval = 1, $maxval = 3)
{
    my $q = List::PriorityQueue->new();
    $q->insert( str(0,0,0), 0); # Vertical
    $q->insert( str(0,0,1), 0); # Horizontal
    my %seen;
    my %costAt;
    $costAt{0}{0}{0} = 0;
    $costAt{0}{0}{1} = 0;

    my ($cost, $row, $col, $dir);
    while ( defined(my $top = $q->pop()) )
    {
        ($row, $col, $dir) = split(",", $top);

        last if ( $row eq $goal->[0] && $col == $goal->[1] );

        next if ( $seen{$row}{$col}{$dir} );
        $seen{$row}{$col}{$dir} = true;

        my $originalCost = $costAt{$row}{$col}{$dir};
        for my $s ( -1, 1 )
        {
            $cost = $originalCost;
            my ($r, $c) = ($row, $col);
            for my $i ( 1 .. $maxval )
            {
                if ( $dir == 1 )    # Horizontal
                {
                    $c = $col + $i * $s;
                }
                else
                {
                    $r = $row + $i * $s;
                }
                last if ( ! $g->isInbounds($r, $c) );

                $cost += $g->get($r, $c);
                $costAt{$r}{$c}{1-$dir} = $cost;
                $logger->debug("At ($r,$c,$dir) cost=$cost");
                next if $seen{$r}{$c}{1-$dir};

                if ( $i >= $minval )
                {
                    $q->insert( str($r, $c, $dir), $cost );
                }
            }
        }
        $logger->debug("($row,$col} yields cost=$cost");
    }
    return $cost;
}
sub astar($g, $start, $goal)
{
    my $frontier = List::PriorityQueue->new();
    my %cameFrom;
    my %lossSoFar;

    # Entry in priority queue is [ row, col, direction, count ]
    $frontier->insert( [ @$start, '.', 1 ], 0 );
   
    # Location as a value that can be a hash key
    $cameFrom{ str(@$start) } = undef;
    $lossSoFar{ str(@$start) } = 0; # $g->get(@$start);

    while ( defined(my $current = $frontier->pop()) )
    {
        my ($row, $col, $lastDir, $moveCnt) = $current->@*;
        my $curStr = str($row, $col);
        if ( $row eq $goal->[0] && $col == $goal->[1] )
        {
            my $totalLoss = $lossSoFar{ $curStr } + $g->get($row, $col);
            $MinLoss = $totalLoss if $totalLoss < $MinLoss;
            $logger->debug("Reached [@$goal], loss=$totalLoss Min=$MinLoss");
            $logger->debug("PATH: ", reconstruct($g, $curStr, \%cameFrom));
            next;
        }

        for my $dir ( '>', 'v', '^', '<' )
        {
            next if ( $lastDir ne '.' && $dir eq $lastDir && $moveCnt == 3 );

            my $mvCnt = ( $dir eq $lastDir ? $moveCnt+1 : 1 );

            my $next;
            if    ( $dir eq 'v' ) { $next = $g->south($row, $col); }
            elsif ( $dir eq '>' ) { $next = $g->east($row, $col); }
            elsif ( $dir eq '^' ) { $next = $g->north($row, $col); }
            elsif ( $dir eq '<' ) { $next = $g->west($row, $col); }
            next if ! defined $next;
            my $nxtstr = str(@$next);

            my $newLoss = $lossSoFar{$curStr} + $g->get(@$next);
            if ( $newLoss > $MinLoss )
            {
                $logger->debug("BAIL ($curStr) $dir $mvCnt ($nxtstr), $newLoss > $MinLoss");
                next;
            }
            if ( ( ! exists $lossSoFar{$nxtstr} )
                || $newLoss < $lossSoFar{$nxtstr} )
            {
                $lossSoFar{$nxtstr} = $newLoss;
                my $priority = $newLoss + h($g, @$next);
                $frontier->update( [ $next->[0], $next->[1], $dir, $mvCnt ], $priority);
                $logger->debug("MOVE ($curStr) $dir $mvCnt ($nxtstr), newloss=$newLoss priority=$priority");
                $cameFrom{$nxtstr} = $curStr;
            }
            else
            {
                $logger->debug("DROP ($curStr) $dir $mvCnt ($nxtstr), newloss=$newLoss");
            }
        }
    }
    return $MinLoss;
}
