#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 13 Part 1
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use List::Util qw/all/;

$logger->info("START");

exit(!runTest()) if $AOC::DoTest;

my $Hcount = 0;
my $Vcount = 0;

local $/ = ""; # Paragraph mode
while (<>)
{
    chomp;

    my @pattern = split "\n";

    my $horiz = findReflection(\@pattern);
    $logger->debug("In $., H = $horiz");

    # Only look other direction if necessary.
    if ( $horiz <= 0 )
    {
        $logger->debug("Transpose $. to find V reflection");
        my $t = transpose(\@pattern);
        my $vert = findReflection($t);
        $logger->debug("In $., V = $vert");
        $Vcount += $vert;
    }
    else
    {
        $Hcount += $horiz;
    }
}

say $Vcount + (100*$Hcount);

sub transpose($m)
{
    my @t;
    my $width = length($m->[0]);

    for (my $c = 0 ; $c < $width ; $c++ )
    {
        push @t, join "", map { substr($_, $c, 1) } $m->@*;
    }
    return \@t;
}

sub findReflection($pattern)
{
    my $above = -1; my $below = scalar(@$pattern);
    my $axis = -1;
    my $isPerfect = 0; # Reflection must reach edge of pattern
    for (my $r = 0 ; $r < $pattern->$#* ; $r++)
    {
        if ( $pattern->[$r] eq $pattern->[$r+1] )
        {
            $axis = $r;
            ($above, $below) = extendHrange($pattern, $r);
            $logger->debug("In $. Found pair at $r from $above to $below");
            $isPerfect = ( $above == 0 || $below == $pattern->$#* );
            last if $isPerfect;
        }
    }
    return ( $isPerfect ? $axis+1 : -1 );
}


sub extendHrange($pattern, $start)
{
    my $above = $start - 1;
    my $below = $start + 2;

    while ( $above >= 0 && $below <= $pattern->$#*
        && $pattern->[$above] eq $pattern->[$below] )
    {
        $above--;
        $below++;
    }
    return ($above+1, $below-1);
}

$logger->info("FINISH");

##############################
sub runTest()
{
    use Test2::V0;
    no warnings "experimental::builtin";

    is( transpose( [ "ab", "de", "gh" ] ),
                   [ "adg", "beh" ], "transpose");

    done_testing();
}
