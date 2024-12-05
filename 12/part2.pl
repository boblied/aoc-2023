#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part2.pl Advent of Code 2023 Day 12 Part 2
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use Data::Dumper; $Data::Dumper::Sortkeys=1; $Data::Dumper::Indent=0;
use List::Util qw/all sum0/;
use Memoize;

$logger->info("START");

my $ComboCount = 0;

Memoize::memoize("waysToFit");
Memoize::memoize("dot");
Memoize::memoize("pound");
while (<>)
{
    chomp;
    my ($rep, @groups) = split /[ ,]/;

    $rep = unfoldReport($rep);
    @groups = unfoldGroups(@groups)->@*;

    $logger->info("----- PROGRESS $. --------- $ComboCount")
        if ( $. % 100 == 0 );

    Memoize::flush_cache("waysToFit");
    Memoize::flush_cache("dot");
    Memoize::flush_cache("pound");
    $ComboCount += waysToFit($rep, @groups);
}
say $ComboCount;

$logger->info("FINISH");

sub unfoldReport($rep)
{
    return join("?", $rep, $rep, $rep, $rep, $rep);
}

sub unfoldGroups(@groups)
{
    return [ @groups, @groups, @groups, @groups, @groups ]
}

sub waysToFit($rep, @groups)
{
    if ( ! @groups )
    {
        # Out of groups is okay if we don't have a # to satisfy
        $logger->debug("Out of groups, rep=$rep");
        return ( index($rep, '#') < 0 ? 1 : 0 );
    }

    if ( length($rep) == 0 )
    {
        # Out of space, but still groups left
        $logger->debug("rep is empty, g=(@groups)");
        return 0;
    }

    # If there's not enough space to accomodate the groups, we can stop
    my $need = @groups - 1 + sum0(@groups);
    $logger->debug("WTF rep='$rep' g=(@groups), need=$need, len=", length($rep));

    if ( length($rep) < $need )
    {
        $logger->debug("not enough space in rep '$rep', g=(@groups)");
        return  0;
    }

    my $nextChar = substr($rep, 0, 1);

    my $out = 0;
    if ( $nextChar eq "." )
    {
        $out = dot($rep, @groups);
    }
    elsif ( $nextChar eq "#" )
    {
        # Handle group and possibly recurse
        $out = pound($rep, @groups);
    }
    elsif ( $nextChar eq "?" )
    {
        # ? can be either . or #, go both ways
        $out = dot($rep, @groups) + pound($rep, @groups);
    }
    else
    {
        die "Unexpected char in [$rep]"
    }
    return $out;
}

sub dot($rep, @groups)
{
    # Can't place a group here, move on
    $logger->debug("DOT at '$rep' g=(@groups)");
    return waysToFit( substr($rep, 1), @groups);
}

sub pound($rep, @groups)
{
    $logger->debug("POUND at '$rep' g=(@groups)");
    # Next g characters must be # or ?
    my $g = shift @groups;
    if ( substr($rep, 0, $g) =~ /^[?#]+$/ )
    {
        # Check for placement of last group at end of report
        if ( length($rep) == $g )
        {
            $logger->debug("Last group at end");
            return ( @groups == 0 ? 1 : 0 );
        }

        # Next char after group must be a spacer
        my $next = substr($rep, $g, 1);
        if ( $next eq "." || $next eq "?" )
        {
            $logger->debug("Space after group OK");
            # Skip over group and space, repeat
            return waysToFit( substr($rep, $g+1), @groups);
        }
        else
        {
            $logger->debug("No space after group 'rep' (@groups)");
            return 0;
        }
    }
    else
    {
        $logger->debug("Can't place group of g at '$rep'");
        return 0;
    }
}
