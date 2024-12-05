#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part2.pl Advent of Code 2023 Day 15 Part 2
#=============================================================================
# HASHMAP
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use Data::Dumper; $Data::Dumper::Sortkeys=1; $Data::Dumper::Indent=0;

use List::Util qw/sum/;
use List::MoreUtils qw/first_index/;

my @Box; $#Box = 256;

$logger->info("START");

my $manual = <>;
chomp $manual;
my @step = split",", $manual;
for ( @step )
{
    if ( index($_, "=") >= 0 )
    {
        my ($label, $f) = split("=", $_);
        my $b = hash($label);
        my $where = first_index { $_->[0] eq $label } $Box[$b]->@*;
        if ( $where < 0 )
        {
            push @{$Box[$b]}, [$label, $f];
        }
        else
        {
            splice(@{$Box[$b]}, $where, 1, [$label, $f]);
        }

        $logger->debug("$_:\t[$b]=[ ", (map { "[$_->@*]"} $Box[$b]->@*), " ]" );
    }
    else # Assume must be -
    {
        my $label = substr($_, 0, length($_)-1);
        my $b = hash($label);
        my $where = first_index { $_->[0] eq $label } $Box[$b]->@*;
        splice(@{$Box[$b]}, $where, 1) if $where >= 0;
        $logger->debug("$_:\t[$b]=[ ", (map { "[$_->@*]"} $Box[$b]->@*), " ]" );
    }
}

my $focalPower = 0;
for my $b ( 0 .. $#Box )
{
    my $boxPower = 0;
    for my $lens ( 0 .. $Box[$b]->$#* )
    {
        $boxPower += ($b+1) * ($lens+1) * $Box[$b][$lens][1];
    }
    $focalPower += $boxPower;
}
say $focalPower;


$logger->info("FINISH");

sub hash($s)
{
    my $val = 0;
    for my $h (split //, $s)
    {
        $val = (($val + ord($h)) * 17) %256
    }
    return $val;
}
