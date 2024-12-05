#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 19 Part 1
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use List::Util qw/sum/;
use Data::Dumper; $Data::Dumper::Sortkeys=1; $Data::Dumper::Indent=0;

my %Task;
my @WorkStack;

my $TotalRating = 0;

use constant    { X => 0, M => 1, A => 2, S => 3 };
my %Category  = ( x => 0, m => 1, a => 2, s => 3 );

$logger->info("START");

readInput();
$logger->debug("IN queue: ", Dumper(\@WorkStack));

doWorkTask();

say $TotalRating;

$logger->info("FINISH");

sub readInput()
{
    while (<>)
    {
        chomp;
        if ( my @flow = m/^(\w+)\{([^}]+)}/a )
        {
            $Task{$flow[0]} = parseWork($flow[1]);
        }
        elsif ( my @rating = m/^\{x=([\d]+),m=([\d]+),a=([\d]+),s=([\d]+)}/a )
        {
            push @WorkStack, [ "in", [ @rating ] ];
        }
    }
}

sub parseWork($w)
{
    my @list;
    for ( split ',', $w )
    {
        if ( m/(\w)([<>])(\d+):(\w+)/a )
        {
            push @list, { next => $4, cmp => $2, cat => $Category{$1}, val => $3 };
        }
        elsif ( m/(\w+)/a )
        {
            push @list, { next => $1, cmp => "=", cat => -1, val => -1 }
        }
    }
    return \@list;
}

sub doWorkTask()
{
    while ( defined(my $flow = shift @WorkStack) )
    {
        my $rating = $flow->[1];
        $logger->debug("Processing $flow->[0] with [@$rating]");
        {
            my $next = doTask($Task{$flow->[0]}, $rating);
            if ( $next eq "A" )
            {
                $TotalRating += sum $rating->@*;
                $logger->info("ACCEPT [@$rating], Total=$TotalRating");
            }
            elsif ( $next eq "R" )
            {
                $logger->info("REJECT [@$rating]");
            }
            else
            {
                push @WorkStack, [ $next, $rating ];
            }
        }
    }
}

sub doTask($taskList, $rating)
{
    for my $check ( $taskList->@* )
    {
        if ( $check->{cmp} eq "=" )
        {
            return $check->{next};
        }
        elsif ( $check->{cmp} eq "<" )
        {
            return $check->{next} if $rating->[$check->{cat}] < $check->{val};
        }
        elsif ( $check->{cmp} eq ">" )
        {
            return $check->{next} if $rating->[$check->{cat}] > $check->{val};
        }
        else
        {
            die "invalid op in taskList"
        }
    }
}
