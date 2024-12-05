#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl Advent of Code 2023 Day 07 Part 1
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use Data::Dumper; $Data::Dumper::Sortkeys=1; $Data::Dumper::Indent=0;

use Getopt::Long;
my $Verbose = 0;
my $DoTest  = 0;

GetOptions("test" => \$DoTest, "verbose" => \$Verbose);
exit(!runTest()) if $DoTest;

sub runTest
{
    # use Test2::V0;
    # is(0, 1, "FAIL");
    # done_testing;
}

my %CardVal = ( A => 14, K => 13, Q => 12, J => 11, T => 10 );
$CardVal{$_} = $_ for 2 .. 9;

use constant {
    T_5_OF_A_KIND => 50,
    T_4_OF_A_KIND => 40,
    T_FULL_HOUSE  => 32,
    T_3_OF_A_KIND => 30,
    T_TWO_PAIR    => 20,
    T_ONE_PAIR    => 10,
    T_HIGH_CARD   =>  1,
};

sub hand2type($h)
{
    my %freq; $freq{$_}++ for $h->@*;
    my @f = sort { $b <=> $a } values %freq;
    my $type;
    if    ( $f[0] == 5 ) { $type = T_5_OF_A_KIND }
    elsif ( $f[0] == 4 ) { $type = T_4_OF_A_KIND }
    elsif ( $f[0] == 3 ) { $type = ( $f[1] == 2 ? T_FULL_HOUSE : T_3_OF_A_KIND ) }
    elsif ( $f[0] == 2 ) { $type = ( $f[1] == 2 ? T_TWO_PAIR   : T_ONE_PAIR ) }
    else                 { $type = T_HIGH_CARD }
    return $type;
}

my @Hand;
sub makeHand($h, $bid)
{
    my @c = map { $CardVal{$_} } split "", $h;

    my $type = hand2type(\@c);
    return [ $type, @c, $bid ];
}

while (<>)
{
    my ($hand, $bid) = split " ";
    say "$hand, $bid" if $Verbose;
    push @Hand, makeHand($hand, $bid);
}
# say Dumper \@Hand;

my @Ranked = sort {
          $a->[0] <=> $b->[0]
       || $a->[1] <=> $b->[1]
       || $a->[2] <=> $b->[2]
       || $a->[3] <=> $b->[3]
       || $a->[4] <=> $b->[4]
       || $a->[5] <=> $b->[5] } @Hand;

   # say "Ranked ", Dumper(\@Ranked);

use List::Util qw/sum/;
say sum map { ($_+1) * $Ranked[$_][6] } 0 .. $#Ranked;
