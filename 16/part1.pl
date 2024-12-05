#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 16 Part 1
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;
use AOC::Grid;

$logger->info("START");

my %MirrorTurn = (
    "/"  => { '^' => '>', 'v' => '<', '<' => 'v', '>' => '^' },
    "\\" => { '^' => '<', 'v' => '>', '<' => '^', '>' => 'v' },
);

my %SplitterTurn = (
    "|" => { '^' => '^', 'v' => 'v', '<' => '^', '>' => 'v' },
    "-" => { '^' => '>', 'v' => '<', '<' => '<', '>' => '>'  },
);

my %Opposite = ( '^' => 'v', 'v' => '^', '<' => '>', '>' => '<' );

my @BeamStack = ( [ 0, 0, ">" ] ); # [ row, col, direction ]

my $Layout = AOC::Grid::loadGrid(); $logger->debug("Layout :", $Layout->show());
my $Cave   = AOC::Grid::makeGrid($Layout->height, $Layout->width, ".");
$logger->debug("Cave: ", $Cave->show());

shine();
$logger->debug("After shine, Layout:", $Layout->show());
$logger->debug("After shine, Cave", $Cave->show());

say count();

sub shine()
{
  BEAM:
    while ( my $beam = shift @BeamStack )
    {
        $logger->debug("----- NEW BEAM $beam->@*");
        my $isMoving = true;
        while ( $isMoving )
        {
            my ($row, $col, $dir) = $beam->@*;
            my $tile = $Layout->get($row, $col);
            if ( $tile eq "." )
            {
                @{$beam} = space($beam->@*);
            }
            elsif ( $tile eq "/" || $tile eq "\\" )
            {
                @{$beam} = mirror($beam->@*, $tile);
            }
            elsif ( $tile eq "|" || $tile eq "-" )
            {
                @{$beam} = splitter($beam->@*, $tile);
            }
            next BEAM if isFinished($beam->@*);
        }
    }
}

sub count()
{
    use List::Util qw/sum0/;
    my $g = $Cave->grid();
    sum0 map { scalar grep /[^.]/, $_->@* } $g->@*;
}

sub isFinished($row, $col, $dir)
{
    ( ! $Layout->isInbounds($row, $col) )
      || $dir eq $Cave->get($row, $col)
}

sub space($row, $col, $dir)
{
    $logger->debug("SPACE at ($row,$col) $dir");
    # Mark the tile as energized
    $Cave->set($row, $col, $dir);
    return move($row, $col, $dir);
}

sub mirror($row, $col, $dir, $angle)
{
    $logger->debug("MIRROR $angle at ($row,$col) $dir");
    $Cave->set($row, $col, $angle); # Energized
    my $turn = $MirrorTurn{$angle}{$dir};
    return move($row, $col, $turn);
}

sub splitter($row, $col, $dir, $prism)
{
    $logger->debug("SPLITTER $prism at ($row,$col) $dir");
    $Cave->set($row, $col, $prism); # Energized

    my $turn = $SplitterTurn{$prism}{$dir};
    my @next = move($row, $col, $turn);
    if ( $turn ne $dir )
    {
        my @newbeam = move($row, $col, $Opposite{$turn});
        push @BeamStack, [ @newbeam ] if $Layout->isInbounds(@newbeam[0,1]);
    }
    return @next;
}

sub move($row, $col, $dir)
{
    if    ( $dir eq "^" ) { $row-- }
    elsif ( $dir eq "v" ) { $row++ }
    elsif ( $dir eq ">" ) { $col++ }
    elsif ( $dir eq "<" ) { $col-- }
    return ($row, $col, $dir);
}

$logger->info("FINISH");
