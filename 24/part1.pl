#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2024, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2024 Day 24 Part 1
#
# https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use feature 'class'; no warnings "experimental::class";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use List::Util qw/max min/;

$logger->info("START");

my $BoxMin = ( shift // 7 );
my $BoxMax = ( shift // 27 );

my @Lines;

readInput();
$logger->info($_->show) for @Lines;

say countIntersect(\@Lines);

class Line
{
    field $x  : param = 0;
    field $y  : param = 0;
    field $z  : param = 0;
    field $dx : param = 0;
    field $dy : param = 0;
    field $dz : param = 0;
    field $m;
    field $b;

    method m() { $m }
    method b() { $b }

    ADJUST {
        $m = $dy / $dx;
        $b = ($y*$dx - $x*$dy)/$dx;
    }

    method inBox($min=$BoxMin, $max=$BoxMax)
    {
        my $left, $top, $right, $bottom;
        # At the left side, where x = Min
        my $ymin = $m * $min + $b;
        if ( $min <= $ymin <= $max )
        {
            $left = Point->new(x => $min, y => $ymin);
        }
        # At the right, where x = Max
        my $ymax = $m * $max + $b;
        if ( $min <= $ymax <= $max )
        {
            $right = Point->new(x => $max, y => $ymax);
        }
        # At the bottom, where y = Min
        my $xmin = ($min - $b)/$m;
        if ( $min <= $xmin <= $max )
        {
            $bottom = Point->new(x => $xmin, y => $min);
        }
        # At the top, where y = max
        my $xmax = ($max - $b)/$m;
        if ( $min <= $xmax <= $max )
        {
            $top = Point->new(x => $xmax, y => $max);
        }
    }

    method intersect($l2, $min=$BoxMin, $max=$BoxMax)
    {
        return false if ( $self->m == $l2->m);
 
        my $xi = ($l2->b - $self->b) / ( $self->m - $l2->m);
        my $yi = $m * $xi + $b;
        $AOC::logger->debug("X: at ($xi,$yi) for", $self->show," ",$l2->show);

        return ($min <= $xi <= $max) && ($min <= $yi <= $max);
    }

    method show() { "($x,$y,$z) d($dx,$dy,$dz): y = $m * x + $b" }
}

class Point
{
    field $x : param = 0;
    field $y : param = 0;
    field $z : param = 0;
    
    method x() { $x }
    method y() { $y }
    method z() { $z }
}

sub readInput()
{
    while (<>)
    {
        chomp;
        my ($x,$y,$z, $dx,$dy,$dz) = m/(-?\d+)/ga;
        my $line = Line->new(x=>$x,y=>$y,z=>$z,dx=>$dx,dy=>$dy,dz=>$dz);
        push @Lines, $line;
    }
}

sub countIntersect($lines)
{
    my $count = 0;
    for ( my $eqA = 0; $eqA < $lines->$#* ; $eqA++ )
    {
        for ( my $eqB = $eqA+1 ; $eqB <= $lines->$#* ; $eqB++ )
        {
            if ( $lines->[$eqA]->intersect($lines->[$eqB] ) )
            {
                $count++;
            }
        }
    }
    return $count;
}

# See https://www.geeksforgeeks.org/orientation-3-ordered-points/ 
# To find orientation of ordered triplet of points (p, q, r). 
# The function returns following values 
# 0 --> p, q and r are collinear 
# 1 --> Clockwise 
# 2 --> Counterclockwise 
sub orientation($p, $q, $r) 
{ 
    my $val = ($q->y - $p->y) * ($r->x - $q->x) - 
              ($q->x - $p->x) * ($r->y - $q->y); 
  
    return 0 if $val == 0; # collinear
  
    return ($val > 0) ? 1 : 2; # clock or counterclock wise 
} 

# Given three collinear points p, q, r, the function checks if 
# point q lies on line segment 'pr' 
sub onSegment($p, $q, $r) 
{ 
    return ( $q->x <= max($p->x, $r->x) && $q->x >= min($p->x, $r->x) && 
             $q->y <= max($p->y, $r->y) && $q->y >= min($p->y, $r->y) ) 
} 

# The main function that returns true if line segment 'p1q1' 
# and 'p2q2' intersect. 
sub doIntersect($p1, $q1, $p2, $q2) 
{ 
    # Find the four orientations needed for general and 
    # special cases 
    my $o1 = orientation($p1, $q1, $p2); 
    my $o2 = orientation($p1, $q1, $q2); 
    my $o3 = orientation($p2, $q2, $p1); 
    my $o4 = orientation($p2, $q2, $q1); 
  
    # General case 
    return true if ( $o1 != $o2 && $o3 != $o4 );
  
    # Special Cases 
    # p1, q1 and p2 are collinear and p2 lies on segment p1q1 
    return true if ( $o1 == 0 && onSegment($p1, $p2, $q1) );
  
    # p1, q1 and q2 are collinear and q2 lies on segment p1q1 
    return true if ( $o2 == 0 && onSegment($p1, $q2, $q1) );
  
    # p2, q2 and p1 are collinear and p1 lies on segment p2q2 
    return true if ( $o3 == 0 && onSegment($p2, $p1, $q2) );
  
    # p2, q2 and q1 are collinear and q1 lies on segment p2q2 
    return true if ( $o4 == 0 && onSegment($p2, $q1, $q2) );
  
    return false; # Doesn't fall in any of the above cases 
} 
