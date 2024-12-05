# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Brick.pm
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package Brick;

use v5.38;

use parent 'Heap::Elem';
use lib '.'; use Geometry;

sub new
{
    my $class = shift;
    return $class->SUPER::new(@_);
}

sub cmp
{
    my $self = shift;
    my $other = shift;

    return $self->[0]{line}->p1z() <=> $other->[0]{line}->p2z();
}

1;
