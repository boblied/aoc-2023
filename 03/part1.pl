#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl Advent of Code 2023 Day 03 Part 1
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";

use List::Util qw/max min/;

use Getopt::Long;
my $Verbose = 0;

GetOptions("verbose" => \$Verbose);

my @schematic = <>;
chomp(@schematic);
my $rowlen = length($schematic[0]);

my $symbolRE = qr/[^.0-9]/;

my $sum = 0;
for my $r ( 0 .. $#schematic )
{
    my $row = $schematic[$r];
    print "$row $r: " if $Verbose;

    while ( $row =~ m/([0-9]+)/g )
    {
        my $nearSymbol = false;
        my $n = $1;
        my $end = (pos $row) - 1;
        my $beg = $end - length($n) + 1;
        print " $n at pos ($beg,$end) " if $Verbose;

        if    ( $beg > 0 && substr($row, $beg-1, 1) =~ m/$symbolRE/ )
        {
            say "Found symbol at $beg-1 for $n" if $Verbose;
            $nearSymbol = true;
        }
        elsif ( $end < $rowlen-1 && substr($row, $end+1, 1) =~ m/$symbolRE/ )
        {
            say "Found symbol at $end+1 for $n" if $Verbose;
            $nearSymbol = true;
        }
        else
        {
            my $left = max(0, $beg-1);
            my $right = min($rowlen-1, $end+1);
            my $len = $right - $left + 1;
            if ( $r > 0  )
            {
                my $above = substr($schematic[$r-1], $left, $len);
                if ( $above =~ m/$symbolRE/ )
                {
                    say "Found symbol above for $n in $above" if $Verbose;
                    $nearSymbol = true;
                }
            }
            if ( ! $nearSymbol && $r < $#schematic )
            {
                my $below = substr($schematic[$r+1], $left, $len);
                if ( $below =~ m/$symbolRE/ )
                {
                    say "Found symbol below for $n $below" if $Verbose;
                    $nearSymbol = true;
                }
            }
        }
        $sum += $n if $nearSymbol;
    }
    print "\n" if $Verbose;
}
say $sum;
