#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part2.pl Advent of Code 2023 Day 10 Part 2
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

    'q' =>  [  "@",   "@",   "@",   "@"  ],
    'f' =>  [  "@",   "@",   "@",   "@"  ],
    'j' =>  [  "@",   "@",   "@",   "@"  ],
    'b' =>  [  "@",   "@",   "@",   "@"  ],
    ':' =>  [  "@",   "@",   "@",   "@"  ],
    '_' =>  [  "@",   "@",   "@",   "@"  ],
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

# Replace the start symbol with the kind of pipe it is
my %Pipe = ( N => { E => "L", W => "J", "S" => "|" },
             S => { E => "F", W => "7", "N" => "|" },
             E => { N => "L", W => "-", "S" => "F" },
             W => { N => "J", E => "-", "S" => "7" },
        );

my $p = $Pipe{$StartDir[0]}{$StartDir[1]};
$Map[$Start[0]][$Start[1]] = $p;
$logger->info("Start directions: @StartDir ($p)");

sub marker($t) { $t =~ tr/S7FLJ|-/sqfbj:_/; return $t }
sub isMarker($t) { index("qfbj:_", $t) >= 0 }

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
    $Map[$r][$c] = marker( $Map[$r][$c] );

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
my $PathLength = 0;
while ( $dir ne "@" && $dir ne "X" )
{
    ($r, $c, $dir, $tile) = move($r, $c, $dir);
    $PathLength++;
    $logger->debug("Move: at [$r,$c] ($tile), heading $dir, PathLength $PathLength");
    last if $tile eq "@";
}
$logger->debug("Path:", showGrid(\@Map));
$logger->info("PathLength=$PathLength, max=", $PathLength/2);

# For each row, count the number of times we pass through the path.
# We start outside, every path crossing moves us inside
# We have to take account of path tiles that are next to each other,
# to know if we're on a horizontal segment

my %isConnected = (
    fj => "elbow", bq => "elbow",
 #  bj => "uturn", fq => "uturn",
    _q => "cont",  _j => "cont", __ => "cont", b_ => "cont", f_ => "cont"
);

use constant { INSIDE => "I", OUTSIDE => "O", ONPATH => "P" };
my %TileCount = ( IN => 0, OUT =>  0, PATH => 0 );
for my $row ( 0 .. $Height )
{
    my $region = "OUT";
    my $crossCount = 0;
    my $c = 0;
    my $prev = '.';
    for ( my $c = 0 ; $c <= $Width ; $c++ )
    {
        my $next = $Map[$row][$c];

        if ( ! isMarker($next) )
        {
            $TileCount{$region}++;
            next;
        }

        if ( $next eq ':' )
        {
            $crossCount++;
            $region = ( $crossCount % 2  ? "IN" : "OUT" );
        }
        elsif ( $next eq 'f' || $next eq 'b' )
        {
            # Follow the line until we get to a turn
            ++$TileCount{PATH};
            ++$TileCount{PATH} while $Map[$row][++$c] eq '_';
            my $turn = $Map[$row][$c];

            if ( ($next eq 'f' && $turn eq 'q') || ($next eq 'b' && $turn eq 'j') )
            {
                # We have a U-turn, doesn't count as a crossing
                # still in same region
            }
            elsif ( ($next eq 'f' && $turn eq 'j') || ($next eq 'b' && $turn eq 'q') )
            {
                # We have an elbow, counts as a crossing
                $crossCount++;
                $region = ( $crossCount % 2  ? "IN" : "OUT" );
            }
            else { die "Unexpected line ending ($next,$turn) in row $row at $c" }

            $next = $turn;  # We skipped ahead.
        }
        else { die "Unexpected path marker $next" }

        $prev = $next;
    }
    $logger->info( "Row $row: IN=$TileCount{IN}, OUT=$TileCount{OUT}, PATH=$TileCount{PATH}" );
}
say "DONE IN=$TileCount{IN}, OUT=$TileCount{OUT}, PATH=$TileCount{PATH}";

$logger->info("FINISH");
