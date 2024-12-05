#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part2.pl Advent of Code Day 08 Part 2
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use builtin qw/trim true false/; no warnings "experimental::builtin";

use List::Util qw/all/;

use Getopt::Long;
my $Verbose = 0;
my $DoTest = 0;
GetOptions("verbose" => \$Verbose, "test" => \$DoTest);
exit(!runTest()) if $DoTest;

my @Step;
{ @Step = split "", trim(my $s = <>); } # First line, directions

my %Graph;
while (<>)
{
    chomp;
    next if $_ eq "";
    my ($node, $left, $right) = m/([A-Z]+)/g;
    $Graph{$node} = { L => $left, R => $right };
}

my @Start = grep /A\Z/, keys %Graph;
my @Node = @Start;

say "Start: @Start" if $Verbose;

sub allZ($nodes) { ($nodes->$#* + 1 ) == grep /Z\Z/, $nodes->@* }

my @ZLOC;
$ZLOC[$_] = [] for 0 .. $#Start;
sub showZLOC($str)
{
    say $str;
    for my $z ( @ZLOC )
    {
        printf(("[ " . ("%12d" x scalar($z->@*)) . "]\n"), $z->@*);
    }
}

# Each start point will eventually reach a Z, and the input is
# rigged so that it cycles through them.  Once we've found the
# cycle for each start point, we can determine where they will
# eventually line up by finding the least common multiple.
my @CYCLE = ( (0) x scalar(@Start) );

my $step = 0;
my $count = 0;
STEP: while ( ! allZ(\@Node) )
{
    my $dir = $Step[$step++];
    $step = 0 if $step == scalar(@Step);
    $count++; print STDERR "." if ($count % 1000000) == 0;

    @Node = map { $_->{$dir} } @Graph{@Node}; # Ain't that cute?

    if ( grep /Z/, "@Node" )
    {
        for ( 0 .. $#Node )
        {
            if ( substr($Node[$_], -1, 1) eq 'Z' )
            {
                push @{$ZLOC[$_]}, $count;

                if ( $ZLOC[$_]->$#* == 1 ) # Second time we saw a Z
                {
                    if ( $ZLOC[$_][1] - $ZLOC[$_][0] == $ZLOC[$_][0] )
                    {
                        say "Found cycle for $_ at $ZLOC[$_][0]";
                        $CYCLE[$_] = $ZLOC[$_][0];
                        last STEP if all {$_ > 0 } @CYCLE;
                    }
                }
            }
        }
        # showZLOC("Found Z at $count: @Node")
    }
}
say "@Node" if $Verbose;
say "CYCLE: @CYCLE";
use Math::Utils qw/lcm/;
say lcm(@CYCLE);
# CYCLE: 13939 19199 18673 12361 11309 16043
# 8906539031197

########################################
sub runTest
{
    use Test2::V0;
    no warnings "experimental::builtin";
    is( allZ([ qw(ABC) ]),         false, "Not Z, single");
    is( allZ([ qw(ABZ) ]),         true,  "Is Z, single");
    is( allZ([ qw(ABC DEF GHI) ]), false, "Not Z, none of 3");
    is( allZ([ qw(ABC DEZ GHI) ]), false, "Not Z, 1 of 3");
    is( allZ([ qw(ABZ DEZ GHZ) ]), true,  "Is Z, 1 of 3");
    done_testing;
}
