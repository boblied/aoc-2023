#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl Perl Weekly Challenge Task  
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

my @Start;
my @Map;
my ($Height, $Width) = (0, 0);

$logger->info("START");

while (<>)
{
    chomp;
    push @Map, [ split "" ];
    if ( (my $c = index($_, "S")) >= 0 )
    {
        @Start = ( $.-1, $c );
    }
}
$Height = $#Map;
$Width  = $Map[0]->$#*;

$logger->info("Start=(@Start), Map: $Height x $Width");
$logger->debug("Graph: ", showGrid(\@Map));
use constant { D_N => 0, D_E => 1, D_S => 2, D_W => 3 };

my %Turn = (
# Heading   : NORTH   EAST  SOUTH   WEST
    #         -----  -----  -----  -----
    7   =>  [  "W",   "S",   "X",   "X"  ],
    F   =>  [  "E",   "X",   "X",   "S"  ],
    J   =>  [  "X",   "N",   "W",   "X"  ],
    L   =>  [  "X",   "X",   "E",   "N"  ],
    '-' =>  [  "X",   "E",   "X",   "W"  ],
    '|' =>  [  "N",   "X",   "S",   "X"  ],
    '.' =>  [  "X",   "X",   "X",   "X"  ],
    '^' =>  [  "@",   "@",   "@",   "@"  ],
    'v' =>  [  "@",   "@",   "@",   "@"  ],
    '>' =>  [  "@",   "@",   "@",   "@"  ],
    '<' =>  [  "@",   "@",   "@",   "@"  ],
);

# Find the two possible directions out of S
my ($sr, $sc) = @Start;
my @StartDir;
if ( $sr > 0 )
{
    my $tile = $Map[$sr-1][$sc];
    push @StartDir, "N" if $Turn{$tile}->[D_N] ne "X";
}
if ( $sr < ($Height) )
{
    my $tile = $Map[$sr+1][$sc];
    push @StartDir, "S" if $Turn{$tile}->[D_S] ne "X";
}
if ( $sc < ($Width) )
{
    my $tile = $Map[$sr][$sc+1];
    push @StartDir, "E" if $Turn{$tile}->[D_E] ne "X";
}
if ( $sc > 0 )
{
    my $tile = $Map[$sr][$sc-1];
    push @StartDir, "W" if $Turn{$tile}->[D_W] ne "X";
}
$logger->info("Start directions: @StartDir");

sub marker($d) { $d =~ tr/NESW/^>v</; return $d }
sub isMarker($t) { index("^>v<", $t) >= 0 }

sub move($r, $c, $dir)
{
    my @next = ($r, $c, $dir, '?');
    die "can't move N from ($r, $c)" if $dir eq "N" && $r == 0;
    die "can't move E from ($r, $c)" if $dir eq "E" && $c == $Width;
    die "can't move S from ($r, $c)" if $dir eq "S" && $r == $Height;
    die "can't move W from ($r, $c)" if $dir eq "W" && $c == 0;

    # We've been here before, so we reached a loop
    if ( isMarker($Map[$r][$c]) )
    {
        $logger->info("Found loop at ($r, $c)", showGrid(\@Map));
        return @next = ($r, $c, "@", $Map[$r][$c]);
    }

    # Mark that we've been here
    $Map[$r][$c] = marker($dir);

    if ( $dir eq "N" )
    {
        my $tile = $Map[$r-1][$c];
        @next = ( $r-1, $c, $Turn{ $tile }->[D_N], $tile );
    }
    elsif ( $dir eq "S" )
    {
        my $tile = $Map[$r+1][$c];
        @next = ( $r+1, $c, $Turn{ $tile }->[D_S], $tile );
    }
    elsif ( $dir eq "E" )
    {
        my $tile = $Map[$r][$c+1];
        @next = ( $r, $c+1, $Turn{ $tile }->[D_E], $tile );
    }
    elsif ( $dir eq "W" )
    {
        my $tile = $Map[$r][$c-1];
        @next = ( $r, $c-1, $Turn{ $tile }->[D_W], $tile );
    }
    return @next;
}

my $tile = $Map[$Start[0]][$Start[1]];
my $dir = $StartDir[0];
my ($r, $c) = @Start;
my $length = 0;
while ( $dir ne "@" && $dir ne "X" )
{
    ($r, $c, $dir, $tile) = move($r, $c, $dir);
    $length++;
    $logger->debug("Move: at [$r,$c] ($tile), heading $dir, length $length");
    last if $tile eq "@";
}
$logger->debug("Path:", showGrid(\@Map));
say $length;

$logger->info("FINISH");
