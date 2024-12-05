#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl Advent of Code 2023 Day 05 Part 1
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;

use Getopt::Long;
my $Verbose = 0;
GetOptions("verbose" => \$Verbose);

$/ = ""; # Paragraph mode
my @Seed = (my $s = <>) =~ m/(\d+)/g;

my @src = @Seed;
my @dst;

while ( <> )
{
    my @in = split "\n";
    say join(",", @in) if $Verbose;
    shift @in; # Drop map label
    my @map = ();
    for ( @in )
    {
        push @map, [ split " ", $_ ]
    }

    @dst = ();
    for my $s ( @src )
    {
        push @dst, remap($s, \@map);
    }
    @src = @dst;
}
say "Done mapping, dst=(@dst)" if $Verbose;
# Find index of minimum value of $dst
use List::Util qw/min/;
say min @dst;

sub remap($src, $map)
{
    my $dest = $src;
    for my $r ( $map->@* )
    {
        my ($d, $s, $len) = $r->@*;
        if ( $src >= $s && $src < ($s + $len) )
        {
            $dest = $d + ($src - $s);
            last;
        }
    }
    say "remap: $src -> $dest" if $Verbose;
    return $dest;
}
