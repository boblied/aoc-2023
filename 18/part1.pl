#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
#  
# part1.pl Advent of Code 2023 Day 18 Part 1
#=============================================================================
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;
use AOC::Grid qw/makeGrid/;

$logger->info("START");

my ($MaxLeft, $MaxRight, $MaxUp, $MaxDown) = (0,0,0,0);
my $horizontal = 0;
my $vertical = 0;

my @Step;
while (<>)
{
    my ($dir, $n, $rgb) = split " ";
    push @Step, [ $dir, $n, $rgb ];
    if ( $dir eq "L" )
    {
        $horizontal -= $n;
        $MaxLeft = $horizontal if $horizontal < $MaxLeft;
    }
    elsif ( $dir eq "R" )
    {
        $horizontal += $n;
        $MaxRight = $horizontal if $horizontal > $MaxRight;
    }
    elsif ( $dir eq "U" )
    {
        $vertical += $n;
        $MaxUp = $vertical if $vertical > $MaxUp;
    }
    elsif ( $dir eq "D" )
    {
        $vertical -= $n;
        $MaxDown = $vertical if $vertical < $MaxDown
    }
}
my $Height = $MaxUp - $MaxDown;
my $Width  = $MaxRight - $MaxLeft;

my $StartRow = $Height + $MaxDown;
my $StartCol = $Width - $MaxRight;

$logger->info("VERTICAL: $MaxUp $MaxDown ", $MaxUp - $MaxDown);
$logger->info("HORIZONTAL: $MaxLeft $MaxRight ", $MaxRight - $MaxLeft);
$logger->info("START: $StartRow, $StartCol");

my $Grid = AOC::Grid::makeGrid($Height, $Width, ".");
$Grid->set($StartRow, $StartCol, '#');

my $r = $StartRow;
my $c = $StartCol;
my $Border = 0;
my $y = 0;
my $sum = 0;
for ( @Step )
{
    my ($dir, $n, $rgb) = $_->@*;
    $Border += $n;

    if    ( $dir eq "U" )
    {
        $Grid->set($r-$_, $c, "^") for 1 .. $n;
        $r -= $n;
    }
    elsif ( $dir eq "D" )
    {
        $Grid->set($r+$_, $c, "v") for 1 .. $n;
        $r += $n;
    }
    elsif ( $dir eq "L" )
    {
        $Grid->set($r, $c-$_, "<") for 1 .. $n;
        $c -= $n;
    }
    elsif ( $dir eq "R" )
    {
        $Grid->set($r, $c+$_, ">") for 1 .. $n;
        $c += $n;
    }
    else
    {
        die "Unexpected direction $dir";
    }
}
$logger->info("After walk, we are at ($r, $c)");

use constant { IN => 1, OUT => 2 };
my $where = OUT;
my $trench = 0;

my %Cross = (
    "." => { "." => 0, "^" => 0, "v" => 0, ">" => 0, "<" => 0 },
    "^" => { "." => 1, "^" => 1, "v" => 1, "0" => 0, "<" => 1 },
    "v" => { "." => 1, "^" => 1, "v" => 1, ">" => 0, "<" => 0 },
    "<" => { "." => 1, "^" => 0, "v" => 0, ">" => 1, "<" => 0 },
    ">" => { "." => 1, "^" => 0, "v" => 0, ">" => 0, "<" => 1 },
);

for my $row ( 0 .. $Height )
{
    $where = OUT;
    my $cross = 0;
    if ( $Grid->get($row, 0) ne "." )
    {
        $trench++;
    }
    # Count pairs, count trenches at y, and count path crossings to
    # determine inside or outside the loop.
    for my $row ( 0 .. $Height )
    {
        for ( my $i = 0, my $j = 1 ; $j <= $Width; $i++, $j++ )
        {
            my ($x, $y) = ( $Grid->get($row, $i), $Grid->get($row, $j) );
            my $isCross = $Cross{$x}{$y};
        }
    }

    $logger->debug("TRENCH in row $row: $trench");
}

$logger->info("FINISH");
