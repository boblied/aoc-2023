#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use builtin qw/true false trim/; no warnings "experimental::builtin";

use List::Util qw/all/;

use Getopt::Long;
my $Verbose = 0;
GetOptions("verbose" => \$Verbose);

my %MAX = ( red => 12, green => 13, blue => 14 );

my $score = 0;
while (<>)
{
    chomp;

    (my $id) = m/^Game (\d+):/;
    s/^Game \d+: //;

    my @draw = map { trim $_ } split ";";
    my $isValid = true;
    for my $d ( @draw )
    {
        my @cube = map { [ split " ", $_ ] } split(", ", $d);
        $isValid &&= all { $_->[0] <= $MAX{$_->[1]} } @cube;
    }
    $score += $id if $isValid;
}
say $score;
