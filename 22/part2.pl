#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part2.pl Advent of Code 2023 Day 22 Part 2 Chain Reaction
#=============================================================================
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin"; use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;
use AOC::Grid qw/makeGrid/;

use List::Util qw/max sum0/;
use List::MoreUtils qw/all/;
use Heap::Binary;
use Brick;
use SupportBrick;
use Geometry;

use Data::Printer;

$logger->info("START");

my ($MaxX, $MaxY, $MaxZ) = (0,0,0);

my $Snapshot = readInput();

$logger->info("MAX: x=$MaxX y=$MaxY z=$MaxZ");

my $Pile = drop($Snapshot);

buildSupportNetwork($Pile);

my $count = chains($Pile);
say $count;

$logger->info("FINISH");

sub chains($pile)
{
    my $count = 0;

    ... # TODO account for entire stack dropping at the bottom

    # From the top down, try removing each brick and cache the
    # count of falls triggered from that.
    for my $layer ( reverse 1 .. $pile->$#* )
    {
        for my $brick ( $pile->[$layer]->@* )
        {
            # Find bricks that this brick supports, that only have 1 support
            my @wouldFall = grep { $_->below() == 1 } $brick->getAbove()->@*;
            my $chain = scalar(@wouldFall) + sum0 map { $_->chainCount() } @wouldFall;
            $brick->chain($chain);
            $logger->debug("CHAIIN: ", $brick->show);
            $count += $chain;
        }
    }

    return $count;
}

sub buildSupportNetwork($pile)
{
    my $count = 0;

    # For each brick, count the bricks touching it above and below
    for my $layer ( 1 .. $pile->$#* )
    {
        for my $brick ( $pile->[$layer]->@* )
        {
            for my $below ( $pile->[$layer-1]->@* )
            {
                if ( $brick->line->isOverlap($below->line) )
                {
                    $brick->supportedBy($below);
                    $below->supports($brick);
                }
            }
            # For vertical bricks, check layer above top
            next if $brick->line->p1z == $brick->line->p2z;

            for my $above ( $pile->[1 + $brick->line->p2z]->@* )
            {
                if ( $brick->line->isOverlap($above->line) )
                {
                    $above->supportedBy($brick);
                    $brick->supports($above);
                }
            }
        }
    }
}

sub drop($snap)
{
    my @pile;

    # The ground is a virtual brick that covers the entire surface
    @pile[0] = [ SupportBrick->new(
            line => Line->new( p1 => Point->new(x=>0,     y=>0,     z=>0),
                               p2 => Point->new(x=>$MaxX, y=>$MaxY, z=>0) ) ) ];

    my $surface = makeGrid($MaxX, $MaxY, 0);
    $logger->info("Begin drop");
    # Heap will yield bottom-most bricks first
    while ( my $brick = $snap->extract_top() )
    {
        # Extract from Heap::Elem, weird interface
        my $line = $brick->[0]{line};

        my $bottom = $line->p1z();

        # Find the highest point under the brick
        my @xrange = $line->xrange();
        my @yrange = $line->yrange();

        my @shadow;
        for my $x ( $xrange[0] .. $xrange[1] )
        {
            for my $y ( $yrange[0] .. $yrange[1] )
            {
                push @shadow, $surface->get($x, $y);
            }
        }
        my $highest = max @shadow;

        # Drop the brick to the highest possible point.
        my $dist = $bottom - $highest - 1;
        $logger->debug("DROP before: ", $line->show());
        $line->drop($dist);

        # Update the surface to show where the brick landed.
        my $top  = $highest + $line->height();
        for my $x ( $xrange[0] .. $xrange[1] )
        {
            for my $y ( $yrange[0] .. $yrange[1] )
            {
                $surface->set($x, $y, $top);
            }
        }
        $logger->debug("DROP after : ", $line->show(), $surface->show());

        # Organize the bricks by the layers in which they lie
        push @{$pile[$line->p1z()]}, SupportBrick->new(line=>$line);
    }
    $logger->info("Finish drop, pile contains ", scalar(@pile), " layers");
    $logger->debug("Surface is: ", $surface->show());
    return \@pile;
}

sub readInput()
{
    my $snap = Heap::Binary->new();
    while (<> )
    {
        chomp;
        my ($x1,$y1,$z1,$x2,$y2,$z2) = m/(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/a;
        my $p1 = Point->new(x=>$x1,y=>$y1,z=>$z1);
        my $p2 = Point->new(x=>$x2,y=>$y2,z=>$z2);
        my $line = Line->new(p1=>$p1, p2=>$p2);
        $logger->debug("Line $.: ", $line->show() );

        my $brick = Brick->new(line=>$line);
        $snap->add($brick, $line->p1z() );

        $MaxX = max($MaxX, $x1, $x2);
        $MaxY = max($MaxY, $y1, $y2);
        $MaxZ = max($MaxZ, $z1, $z2);
    }

    return $snap;
}
