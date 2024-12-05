#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part2.pl Advent of Code 2023 Day 05 Part 2
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use Data::Dumper; $Data::Dumper::Sortkeys = 1; $Data::Dumper::Indent = 0;
use List::Util qw/max min/;

use Getopt::Long;
my $Verbose = 0;
GetOptions("verbose" => \$Verbose);

$/ = "";
# Divide into start,length pairs
my @Seed = (my $s = <>) =~ m/(\d+)/g;
@Seed = map { [ $Seed[$_], $Seed[$_+1] ] } map { $_*2 } 0 .. ($#Seed/2);
my @src = @Seed;

my @Dest;
while (<> )
{
    my @in = split "\n";
    shift @in; # Drop map label
    my @map = ();
    for ( @in )
    {
        push @map, [ split " ", $_ ]
    }
    # Sort map by input segment
    @map = sort { $a->[1] <=> $b->[1] } @map;
    say  "\n========= NEW map: ", Dumper(\@map) if $Verbose;

    @Dest = ();
    for my $s ( @src )
    {
        my $to = remap($s, \@map);
        if ( $Verbose ) { say "remap: [$s->@*] --> [$_->@*]" for $to->@*; }
        push @Dest, $to->@*;
    }
    @src = @Dest;
}
say "Done mapping" if $Verbose;

# Sort final destination by range start, take smallest
my @ordered = sort { $a->[0] <=> $b->[0] } @Dest;
say $ordered[0][0];

sub showRange($r, $sym = "X")
{
    if ( ! defined $r->[0] || ! defined $r->[1]
        || $r->[0] < 0 || $r->[0] + $r->[1] > 100 )
    {
        die "r out of range [$r->@*]";
    }
    my $s = " " x 101;
    substr($s, $r->[0], $r->[1], $sym x $r->[1]);
    return scalar(sprintf("[%2d]", $r->[0]) . $s . sprintf("[%2d]", $r->[1]));
}


# src is a [beg,length] pair
sub remap($src, $map)
{
    my @dest;  # Returns rray of [beg,length] pairs

    my ($sBeg, $sEnd) = ( $src->[0], $src->[0] + $src->[1] - 1);
    say "remap: [$sBeg, $sEnd]" if $Verbose;

    # Map pieces are in order by input segment
    for ( $map->@* )
    {
        if ( $Verbose )
        {
            say ('-' x 106);
            say "src: ", showRange($src);
            say "map: ", showRange( [$_->[1], $_->[2]], "I" );
            say "map: ", showRange( [$_->[0], $_->[2]], "O" );
        }
        my ($outBeg, $inBeg, $len) = $_->@*;
        my $inEnd  = $inBeg  + $len - 1;
        my $outEnd = $outBeg + $len - 1;

        next if $sBeg > $inEnd; # All s are after the map segment
        next if $inBeg > $sEnd; # All s are before the map segment

        # From sBeg to $inBeg-1 maps to itself
        if ( $sBeg < $inBeg )
        {
            my $n = $inBeg - $sBeg;
            push @dest, [ $sBeg, $n ];
            say "out: ", showRange([$sBeg, $n]) if $Verbose;
            $sBeg += $n;
        }
        if ( $sBeg > $inBeg )
        {
            my $delta = $sBeg - $inBeg;
            $inBeg += $delta;
            $outBeg += $delta;
        }
        my $end = min($sEnd, $inEnd);
        my $width = $end - $sBeg + 1;
        push @dest, [ $outBeg, $width ];
        say "out: ", showRange([$outBeg, $width]) if $Verbose;
        $sBeg = $end + 1;
    }
    # Whatever's left maps to itself
    my $n = $sEnd - $sBeg + 1;
    if ( $n > 0 )
    {
        push @dest, [ $sBeg, $n ];
        say "out: ", showRange([$sBeg, $n]) if $Verbose;
    }
    return \@dest;
}
