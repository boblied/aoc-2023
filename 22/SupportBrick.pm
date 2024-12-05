# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# SupportBrick.pm
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# Description:
#=============================================================================

use v5.38;
use feature 'class'; no warnings "experimental::class";

class SupportBrick
{
    field $_line :param(line);

    field @_supports;
    field @_supportedBy;

    field $_above = 0;  # Count of bricks laying directly on top of us
    field $_below = 0;  # Count of bricks we are supporting

    field $_chain = 0;  # Chain reaction count if brick is removed

    method supports($brick) { push @_supports, $brick }
    method supportedBy($brick) { push @_supportedBy, $brick }

    method getAbove() { \@_supports }
    method getBelow() { \@_supportedBy }

    method line()  { $_line }

    method above() { scalar @_supports }
    method below() { scalar @_supportedBy }

    method chain($n) { $_chain += $n }
    method chainCount() { $_chain }

    method show() {  "^(".$self->above().") " . "v(".$self->below().") "
                   . "C($_chain) " . $_line->show()
    }

    method showX() {
          join(' | ', map { $_->show() } @_supports)
        . "\n----------------\n"
        . $self->show()
        . "\n----------------\n"
        . join(' | ', map { $_->show() } @_supportedBy)
        ;
    }
}
