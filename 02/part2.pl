#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use builtin qw/trim/; no warnings "experimental::builtin";

use List::Util qw/max/;

use Getopt::Long;
my $Verbose = 0;
GetOptions("verbose" => \$Verbose);


sub power($red, $green, $blue) { $red * $green * $blue }

my $score = 0;
while (<>)
{
    chomp;
    my %min = ( red => 0, green => 0, blue => 0 );

    (my $id) = m/^Game (\d+):/;
    s/^Game \d+: //;

    my @draw = map { trim $_ } split ";";
    for my $d ( @draw )
    {
        my @cube = map { [ split " ", $_ ] } split(", ", $d);
        for my $c ( @cube )
        {
            my ($count, $color) = $c->@*;
            $min{$color}  = max($min{$color}, $count);
        }
    }
    $score += power( @min{qw(red green blue)} );
}
say $score;
