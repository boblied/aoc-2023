#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part2.pl Perl Weekly Challenge Task  
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";

use Getopt::Long;
my $Verbose = 0;

GetOptions("verbose" => \$Verbose);

my %VAL = ( zero => 0, one => 1, two => 2, three => 3, four => 4, 
            five => 5, six => 6, seven => 7, eight => 8, nine => 9 );

$VAL{reverse $_} = $VAL{$_} for keys %VAL;

$VAL{$_} = $_ for 0 .. 9;

my $sum = 0;
while ( <> )
{
    chomp;
    (my $first) = $_ =~ m/([0-9]|one|two|three|four|five|six|seven|eight|nine)/;

    my $r = reverse $_;
    (my $last)  = $r =~ m/([0-9]|eno|owt|eerht|ruof|evif|xis|neves|thgie|enin)/;

    my $n = "$VAL{$first}$VAL{$last}";
    printf("$n < == %5s : $_ : %5s\n", $first, scalar(reverse $last)) if $Verbose;

    $sum += $n;
}
say $sum;
