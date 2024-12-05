#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 23 Part 1 A Long Walk
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";

use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use AOC::Grid;

$logger->info("START");

my $Map = AOC::Grid::loadGrid();

my @Start = (0, 1);
my @Goal  = ( $Map->height, $Map->width );

my $Node = findNode($Map);
$Node->{$Start[0]}{$Start[1]} = [@Start];
$Node->{$Goal[0] }{$Goal[1]}  = [@Goal];

my $nodeCount = 0; $nodeCount += $_ for map { scalar keys %{$Node->{$_}} } keys %$Node;
$logger->info("Found $nodeCount nodes");

my $Graph = findEdge($Map, $Node);


$logger->debug("Map: @Goal ", $Map->show()) if $Map->width() < 30;

$logger->info("FINISH");

sub findEdge($map, $nodeList)
{
    no warnings "experimental::for_list";
    my %seen;
    for my $nr ( %$nodeList )
    {
        for my $nc ( keys %{$nodeList->{$nr}} )
        {
            my $isHead = false;
            for my ($tile, $loc) ( $map->aroundNESW($nr,$nc) )
            {
                $logger->debug("Looking at node ($nr,$nc), (@$loc)=$tile");
                next if $tile eq '#';
                next if $seen{$loc->[0]}{$loc->[1]};
                $isHead = ( $tile eq '^' && ( $loc->[0] > $nr ) )
                       || ( $tile eq 'v' && ( $loc->[0] < $nr ) )
                       || ( $tile eq '<' && ( $loc->[1] < $nc ) )
                       || ( $tile eq '>' && ( $loc->[1] < $nc ) )
                       ;
                my $tail = follow($map, @$loc, $nodeList, \%seen);
            }
            $seen{$nr}{$nc} = true;
        }
    }
}

sub follow($map, $row, $col, $nodeList, $seen)
{
    
}

sub findNode($map)
{
    my %nodeList;
    for my $r ( 0 .. $map->height() )
    {
        for my $c ( 0 .. $map->width() )
        {
            my $tile = $map->get($r,$c);
            next unless $tile eq '.';
            my %around = $map->aroundNESW($r,$c);
            my $branches = grep /[v<>^]/, keys %around;
            if ( $branches > 1 )
            {
                $logger->debug("Found NODE at $r,$c");
                $nodeList{$r}{$c} = [$r, $c];
            }
        }
    }
    return \%nodeList;
}
