#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part2.pl Advent of Code 2023 Day 07 Part 2
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

# Note: J is weakest, must be < 2
my %CardVal = ( A => 14, K => 13, Q => 12, J => 1, T => 10 );
$CardVal{$_} = $_ for 2 .. 9;

use constant {
    T_5K => 50, # 5 of a kind
    T_4K => 40, # 4 of a kind
    T_FH => 32, # full house
    T_3K => 30, # 3 of a kind
    T_2P => 20, # 2 pair
    T_1P => 10, # 1 pair
    T_HC =>  1, # high card
    T_NA =>  0, # none
};

my %JokerUpgrade = (
#         0     1     2     3     4     5    Number of J
# ----   ----  ----  ----  ----  ----  ----  -----------
T_5K , [ T_5K, T_NA, T_NA, T_NA, T_NA, T_5K ],
T_4K , [ T_4K, T_5K, T_NA, T_NA, T_5K, T_NA ],
T_FH , [ T_FH, T_NA, T_5K, T_5K, T_NA, T_NA ],
T_3K , [ T_3K, T_4K, T_NA, T_4K, T_NA, T_NA ],
T_2P , [ T_2P, T_FH, T_4K, T_NA, T_NA, T_NA ],
T_1P , [ T_1P, T_3K, T_3K, T_NA, T_NA, T_NA ],
T_HC , [ T_HC, T_1P, T_NA, T_NA, T_NA, T_NA ],
);

sub hand2type($strHand)
{
    my $jCount = $strHand =~ tr/J//;

    my %freq; $freq{$_}++ for split "", $strHand;
    my @f = sort { $b <=> $a } values %freq;
    my $type;
    if    ( $f[0] == 5 ) { $type = T_5K }
    elsif ( $f[0] == 4 ) { $type = T_4K }
    elsif ( $f[0] == 3 ) { $type = ( $f[1] == 2 ? T_FH : T_3K ) }
    elsif ( $f[0] == 2 ) { $type = ( $f[1] == 2 ? T_2P : T_1P ) }
    else                 { $type = T_HC }

    my $withJoker = $JokerUpgrade{$type}[$jCount];
    say "$type => $withJoker : $strHand" if $Verbose;

    return $withJoker;
}

my @Hand;
sub makeHand($strHand, $bid)
{
    my @valHand = map { $CardVal{$_} } split "", $strHand;
    my $type = hand2type($strHand);
    # say "[ $type, @valHand, $bid ]" if $Verbose;
    return [ $type, @valHand, $bid ];
}

while (<>)
{
    my ($hand, $bid) = split " ";
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

printf( ("%5d" x 7)."\n", $Ranked[$_]->@*) for 0 .. $#Ranked;

use List::Util qw/sum/;
say sum map { ($_+1) * $Ranked[$_][6] } 0 .. $#Ranked;
