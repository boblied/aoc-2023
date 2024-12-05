#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
#  
#=============================================================================

use v5.38;
use builtin qw/trim/; no warnings "experimental::builtin";

say "strict graph {";

while (<>)
{
    my ($from, $to) = split ":";

    say qq($from -- $_ [label="\\E"; tooltip="{from}-{to}" ];) for split(" ", $to)

}

say "}";
