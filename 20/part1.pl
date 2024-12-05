#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# part1.pl Advent of Code 2023 Day 20 Part 1
#=============================================================================

use v5.38;
use builtin qw/true false/; no warnings "experimental::builtin";
use feature 'class'; no warnings "experimental::class";
use FindBin qw($Bin); use lib "$FindBin::Bin/../../lib"; use AOC;
AOC::setup;

use List::Util qw/all/;

my %Modules = (
    button      => Button->new(    name => "button" ),
    broadcaster => Broadcast->new( name => "broadcaster" ),
    output      => Output->new(    name => "output" ),
    rx          => Output->new(    name => "rx" ),
);

my $Circuit = Circuit->new();

$logger->info("START");

my $Pushes = shift;

my $pLow = 0;
my $pHigh = 0;

readInput();

for ( 1..$Pushes )
{
    $Modules{button}->push();
    $Circuit->run();
    $logger->debug("After $_, low/high=", $Circuit->getLow,"/", $Circuit->getHigh);
}

$pLow += $Circuit->getLow();
$pHigh = $Circuit->getHigh();

say "$pLow * $pHigh = ", $pLow * $pHigh;


# $logger->debug( $_->show ) for sort values %Modules;

$logger->info("FINISH");

class Module {
use Carp qw/confess/;
    field $_name :param(name);
    field @_from;
    field @_to;

    method in($from) { push @_from, $from }
    method out($to)  { push @_to, $to }

    method inputs() { \@_from }
    method outputs() { \@_to }

    method id() { $_name }
    method low($from) { confess "Pulse low to uninitialized module $_name" }
    method high($from) { confess "Pulse high to uninitialized module $_name" }
}

class FlipFlop :isa(Module) {
    use AOC qw/$logger/;
    field $_on = false;

    method high($fromId) {
        $logger->debug("hi into ".$self->id()." IGNORED");
    }
    method low($fromId) {
        if ($_on)
        {
            $_on = false;
            $Circuit->enqueue( $_, 0, $self->id() ) for $self->outputs->@*;
        }
        else
        {
            $_on = true;
            $Circuit->enqueue( $_, 1, $self->id() ) for $self->outputs->@*;
        }
    }

    method show() {
        "FLIPFLOP ".$self->id()." state=$_on"
    }
}

class Conjunction :isa(Module) {
    use AOC qw/$logger/;
    field %_input;

    method in($from)    # Override
    {
        $_input{$from->id()} = 0;
    }

    method low($fromId)
    {
        use List::Util qw/all/;
        $_input{$fromId} = 0;
        # At least one low, so send high
        $Circuit->enqueue( $_, 1, $self->id() ) for $self->outputs->@*;
    }

    method high($fromId)
    {
        $_input{$fromId} = 1;
        if ( all { $_ } values %_input )
        {
            # If all high, send a low
            $Circuit->enqueue( $_, 0, $self->id() ) for $self->outputs->@*;
        }
        else
        {
            $Circuit->enqueue( $_, 1, $self->id() ) for $self->outputs->@*;
        }
    }


    method show() {
        "CONJUNCTION ".$self->id()
        . " in:[" . join(" ", map { $_ ."= $_input{$_}" } keys %_input) ."]"
        . " -> ", join("->", map { $_->id() } $self->outputs()->@*)
    }
}

class Broadcast :isa(Module) {
    use AOC qw/$logger/;
    method low($fromId)  {
        $Circuit->enqueue( $_, 0, $self->id() ) for $self->outputs->@*;
    }
    method high($fromId) {
        $Circuit->enqueue( $_, 1, $self->id() ) for $self->outputs->@*;
    }

    method show() { "BROADCAST " . join("->", $self->id, map { $_->id } $self->outputs()->@*) }
}

class Button :isa(Module) {
    use AOC qw/$logger/;

    field $_count = 0;
    
    method push() {
        $_count++;
        $logger->debug("BUTTON PUSH $_count");
        $Circuit->enqueue( $_, 0, $self->id() ) for $self->outputs()->@*
    }

    method show() { "BUTTON " . $self->id ."->" . $self->outputs->[0]->id }
}

class Output :isa(Module) {
    use AOC qw/$logger/;
    field $_value = 0;

    method low($fromId) {
        $_value = 0
    }
    method high($fromId) {
        $_value = 1
    }

    method value() { $_value }

    method show() { "OUTPUT $_value" }
}

class Circuit {
    use AOC qw/$logger/;

    field @_q;
    field $_low = 0;
    field $_high = 0;

    method getLow() { $_low }
    method getHigh() { $_high }

    method enqueue($module, $pulse, $fromId)
    {
        if ( $pulse )
        {
            $logger->debug($fromId, " -hi-> ", $module->id());
            $_high++
        }
        else
        {
            $logger->debug($fromId, " -lo-> ", $module->id());
            $_low++
        }
        push @_q, [ $module, $pulse, $fromId ];
        $logger->debug("CIRCUIT ENQ (", $module->id, ", $pulse, $fromId)");
    }

    method dequeue()
    {
        return false if ! defined(my $t = shift @_q);
        my ($module, $pulse, $fromId) = $t->@*;
        $logger->debug("CIRCUIT DEQ (", $module->id, ", $pulse, $fromId)");
        if ( $pulse == 0 )
        {
            $module->low($fromId);
        }
        else
        {
            $module->high($fromId);
        }
        return true;
    }

    method run()
    {
        while ( $self->dequeue() ) { };
    }
}

sub connection($from, $to)
{
    $logger->debug("Connect $from -> $to");
    $Modules{$from}->out( $Modules{$to} );
    $Modules{$to}  ->in(  $Modules{$from} );
}

sub readInput()
{
    # One pass to register all the modules
    chomp(my @connection = <>);
    for ( @connection )
    {
        (my $from) = m/^([%&]?\w+)/a;
        if ( substr($from, 0, 1) eq "%" )
        {
            my $name = substr($from, 1);
            $Modules{$name} = FlipFlop->new( name => $name );
            $logger->debug("CREATE FlipFlop $name");
        }
        elsif ( substr($from, 0, 1) eq "&" )
        {
            my $name = substr($from, 1);
            $Modules{$name} = Conjunction->new( name => $name );
            $logger->debug("CREATE Conjunction $name");
        }
    }

    # Second pass to establish connections
    connection( 'button', 'broadcaster' );
    for ( @connection )
    {
        my ($from, $to) = m/^([%&]?\w*) -> (.*)$/a;
        $from =~ s/^[&%]//;
        my @toList = split(", ", $to);
        connection($from, $_) for @toList;
    }
}
