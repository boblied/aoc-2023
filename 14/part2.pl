#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 14 Part 1
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;

use List::Util qw/max/;
use AOC::StringArray;

AOC::setup();

$logger->info("START");

exit( ! runTest() ) if $DoTest;

my $Grid;
my $Height;
my $Width;

my $CycleCount = 0;

$Grid = readInput();
# $logger->info("Grid: $Height x $Width ", showAofS($Grid));


my $period;
my %cache;
for my $cycle ( 0 .. 1200 )
{
    $CycleCount++;
    $Grid = spinCycle($Grid);
    my $load = loadVal($Grid);
    if ( exists $cache{$load} &&
         $cache{$load}[1] eq join("/", $Grid->@*) )
    {
        $logger->info("At cycle $CycleCount, found load $load in cache at $cache{$load}[0]");
        say "Period=", $period = $CycleCount - $cache{$load}[0];
        last;
    }
    else
    {
        $cache{$load} = [ $CycleCount, join("/", $Grid->@*) ];
    }
}

my $Limit = 1_000_000_000;

my $skip = int( ($Limit - $CycleCount) / $period);
my $remain = $Limit - $CycleCount - ($skip * $period);
say "period=$period transient=$CycleCount skip=", $skip*$period, "($skip) remain=$remain";

$Grid = spinCycle($Grid) for ( 1 .. $remain );
say "Final load: ", loadVal($Grid);

exit(0);



sub rollTableNorth($grid)
{
    rollNorth($grid, $_) for ( 0 .. $Width )
}
sub rollTableSouth($grid)
{
    rollSouth($grid, $_) for ( 0 .. $Width )
}
sub rollTableWest($grid)
{
    rollWest($grid, $_) for ( 0 .. $Height )
}
sub rollTableEast($grid)
{
    rollEast($grid, $_) for ( 0 .. $Height )
}

sub spinCycle($grid)
{
    rollTableNorth($grid);
$logger->debug("SPIN after N", showAofS($grid));
    rollTableWest($grid);
$logger->debug("SPIN after W", showAofS($grid));
    rollTableSouth($grid);
$logger->debug("SPIN after S", showAofS($grid));
    rollTableEast($grid);
$logger->debug("SPIN after E", showAofS($grid));

    return $grid;
}

sub loadVal($grid)
{
    # Count boulders in each row
    my $answer = 0;
    for my $row ( 0 .. $Height )
    {
        my $n = $grid->[$row] =~ tr/O//;

        my $val = $n * ($Height - $row + 1);
        $answer += $val;
        $logger->debug("Row $row n=$n val=$val");
    }
    return $answer;
}

sub readInput()
{
    my @map;
    while (<>)
    {
        chomp;
        push @map, $_;
    }
    # Assume square
    $Height = $#map;
    $Width  = length($map[0]) - 1;
    return \@map;
}

sub rollLine($s)
{
    use English;
    my $t = $s;
    while ( $s =~ /([^#]+)/g )
    {
        #$logger->debug("Run is [$1], [$LAST_MATCH_START[1] to $LAST_MATCH_END[1]] ends at ", pos $s);
        (my $rock   = $1) =~ tr/.//d;
        (my $ground = $1) =~ tr/O//d;
        my $len = $LAST_MATCH_END[1] - $LAST_MATCH_START[1];
        substr($t, $LAST_MATCH_START[1], $len, "$rock$ground");
    }
    # $logger->debug("rollLine: [$s] => [$t]");
    return $t;
}

sub rollNorth($grid, $column)
{
    my $cstr = join("", getColAofS($grid, $column));
    my @rolled = split(//, rollLine($cstr));
    for my $row ( 0 .. $grid->$#* )
    {
        substr($grid->[$row], $column, 1) = $rolled[$row];
    }
    return $grid;
}

sub rollSouth($grid, $column)
{
    my $cstr = join("", getColAofS($grid, $column));
    my @rolled = reverse split(//, rollLine(scalar(reverse $cstr)));
    for my $row ( 0 .. $grid->$#* )
    {
        substr($grid->[$row], $column, 1) = $rolled[$row];
    }
    return $grid;
}

sub rollWest($grid, $row)
{
    $grid->[$row] = rollLine($grid->[$row]);
    return $grid;
}

sub rollEast($grid, $row)
{
    $grid->[$row] = reverse rollLine(scalar(reverse $grid->[$row]));
    return $grid;
}

$logger->info("FINISH");

sub runTest()
{
    use Test2::V0;
    is (rollLine("OO.O.O..##"), "OOOO....##", "roll");
    is (rollLine("...OO....O"), "OOO.......", "roll");

    my @g = ( "O.O.O.",".O.O.O" );
    is( rollNorth(\@g, 1), ["OOO.O.","...O.O"], "rollNorth");

    @g = ( "O.O.O.",".O.O.O" );
    is( rollSouth(\@g, 2), ["O...O.",".OOO.O"], "rollSouth");

    @g = ( "O.O.O.",".O.O.O" );
    is( rollWest(\@g, 0), ["OOO...",".O.O.O"], "rollWest");

    @g = ( "O.O.O.",".O.O.O" );
    is( rollEast(\@g, 0), ["...OOO",".O.O.O"], "rollEast");

    done_testing();
}
