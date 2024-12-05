#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl Advent of Code 2023 Day 09 Part 1
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.38;
use builtin qw/trim true false/; no warnings "experimental::builtin";
use List::Util qw/all/;

use Log::Log4perl qw(:easy);

use Getopt::Long;
my $DoTest  = 0;
my $DoDebug = 0;

my $logger = Log::Log4perl->get_logger();
Log::Log4perl->easy_init($WARN);
my %DBLEVEL = ( 1 => $INFO, 2 => $DEBUG, 3 => $TRACE,
                i => $INFO, d => $DEBUG, t => $TRACE, );

GetOptions("test" => \$DoTest, "debug:s" => \$DoDebug);
$logger->level($DBLEVEL{$DoDebug}) if $DoDebug;
exit(!runTest()) if $DoTest;

sub runTest
{
    use Test2::V0;
    is(0, 1, "FAIL");
    done_testing;
}

$logger->info("START");

my $Sum = 0;
while ( <> )
{
    #### PART 2 adds the reverse.  Part 1 works without the reverse.
    my @seq = reverse split " ";
    INFO "@seq";
    $Sum += extrapolate(\@seq);
}
say $Sum;

sub extrapolate($seq)
{
    my @diffStack = ( $seq );
    while ( ! ($seq->[0] == $seq->[-1] && all { $_ == $seq->[0] } $seq->@* ) )
    {
        DEBUG "seq: [ $seq->@* ]";
        push @diffStack, [ map { $seq->[$_] - $seq->[$_-1] } 1 .. ($seq->$#*) ];
        $seq = $diffStack[-1];
    }
    my $d = $diffStack[-1][-1];
    DEBUG "const row, d=$d";
    $seq = pop @diffStack;

    my $extrapolation;
    while ( $seq = pop @diffStack )
    {
        $extrapolation = $seq->[-1] + $d;
        push @$seq, $extrapolation;
        DEBUG "POP: d=$d seq is now $seq->@*";
        $d = $extrapolation;
    }

    DEBUG "extrapolate returns $extrapolation";
    return $extrapolation;
}
