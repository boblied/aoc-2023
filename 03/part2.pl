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
use Data::Dumper; $Data::Dumper::Sortkeys = 1;

use Getopt::Long;
my $Verbose = 0;

GetOptions("verbose" => \$Verbose);

my @schematic = <>;
chomp(@schematic);
my $rowlen = length($schematic[0]);

use constant GEAR => "*";
my %Gear;

for my $r ( 0 .. $#schematic )
{
    my $row = $schematic[$r];
    print "$row $r: " if $Verbose;

    while ( $row =~ m/([0-9]+)/g )
    {
        my $n = $1;
        my $end = (pos $row) - 1;
        my $beg = $end - length($n) + 1;
        print " $n at pos ($beg,$end) " if $Verbose;

        if    ( $beg > 0 && substr($row, $beg-1, 1) eq GEAR )
        {
            say "Found gear at ", $beg-1, " for $n" if $Verbose;
            push @{$Gear{$r}{$beg-1}}, $n;
        }
        elsif ( $end < $rowlen-1 && substr($row, $end+1, 1) eq GEAR )
        {
            say "Found gear at ", $end+1, " for $n" if $Verbose;
            push @{$Gear{$r}{$end+1}}, $n;
        }
        else
        {
            my $left = max(0, $beg-1);
            my $right = min($rowlen-1, $end+1);
            my $len = $right - $left + 1;
            if ( $r > 0  )
            {
                my $above = substr($schematic[$r-1], $left, $len);
                if ( (my $g = index($above, GEAR)) >= 0 )
                {
                    say "Found gear above for $n in $above at ", $left+$g if $Verbose;
                    push @{$Gear{$r-1}{$left + $g}}, $n;
                }
            }
            if ( $r < $#schematic )
            {
                my $below = substr($schematic[$r+1], $left, $len);
                if ( (my $g = index($below, GEAR)) >= 0 )
                {
                    say "Found gear below for $n in $below at ", $left+$g if $Verbose;
                    push @{$Gear{$r+1}{$left + $g}}, $n;
                }
            }
        }
    }
    print "\n" if $Verbose;
}
say Dumper(\%Gear) if $Verbose;

my $sum = 0;
for my $r ( keys %Gear )
{
    for my $c ( keys %{$Gear{$r}} )
    {
        my $list = $Gear{$r}{$c};
        if ( $list->$#* == 1 )
        {
            my $ratio = $list->[0] * $list->[1];
            $sum += $ratio;
            say "Gear at ($r,$c) has ratio $ratio, sum=$sum" if $Verbose;
        }
    }
}
say $sum;
