# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Crucible.pm
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package Crucible;

use v5.38;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw();

sub new
{
    my $class = shift;
    $class = ref($class) || $class;
    my $self = {
        _row  => ($_[0] // 0),
        _col  => ($_[1] // 0),
        _dir  => ($_[2] // " "),
        _len  => 0,
        @_,
    };
    bless $self, $class;
    return $self;
}

sub r($self)    { $self->{_row} }
sub c($self)    { $self->{_col} }
sub len($self)  { $self->{_len} }
sub dir($self)  { $self->{_dir} }

sub setr($self,    $r) { $self->{_row}  = $r; return $self; }
sub setc($self,    $c) { $self->{_col}  = $c; return $self; }
sub setlen($self,  $l) { $self->{_len}  = $l; return $self; }
sub setdir($self,  $d) { $self->{_dir}  = $d; return $self; }

sub move($self, $r, $c, $dir)
{
    $self->{_row} = $r;
    $self->{_col} = $c;
    if ( $self->{_len} == 0 )
    {
        $self->{_len} = 2;
    }
    else
    {
        $self->{_len} = ( $dir eq $self->{_dir} ? $self->{_len} + 1 : 1 );
    }
    $self->{_dir} = $dir;
    return $self;
}

sub canMove($self, $dir)
{
    return ( $self->{_dir} ne $dir ) || $self->{_len} < 3;
}

sub show($self)
{
    "(" . $self->r .",".$self->c.") ".$self->dir." ".$self->len
}

sub clone($self)
{
    return Crucible->new( %{$self} );
}

1;
