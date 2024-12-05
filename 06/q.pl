#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================

use v5.38;
use builtin qw/floor ceil/; no warnings "experimental::builtin";

my ($a, $b, $c) = @ARGV;

sub qf($a, $b, $c)
{
    my $disc = sqrt($b*$b - 4*$a*$c);
    my $lower = ceil((-$b - $disc) / 2);
    my $upper = floor((-$b + $disc) / 2);

    # Need >, not >=, so check end points
    $lower++ if ( (-$b - $lower) * $lower == $c );
    $upper-- if ( (-$b - $upper) * $upper == $c );

    # my @range = grep { (-$b-$_)*$_ != $c } ceil($lower) .. floor($upper);
    # return scalar(@range);
    return $upper - $lower + 1;
}

use List::Util qw/product/;
my @answer = ( qf(1,-7,9), qf(1, -15, 40), qf(1, -30, 200) );
say "Part 1 example: ", (product @answer), " from (@answer)";

   @answer = ( qf(1, -41, 244),
               qf(1, -66, 1047),
               qf(1, -72, 1228),
               qf(1, -66, 1040) );
say "Part 1 input ", (product @answer), " from (@answer)";

say "Part 2: ", qf(1, -41667266, 244104712281040);
