use v5.38;
use feature 'class'; no warnings "experimental::class";


class Point
{
    field $_x : param(x) //= 0;
    field $_y : param(y) //= 0;
    field $_z : param(z) //= 0;

    method x() { $_x };
    method y() { $_y };
    method z() { $_z };

    method drop($dist) { $_z -= $dist }

    method show() { "($_x,$_y,$_z)" }
}

class Line
{
    use List::Util qw/min max/;

    field $_p1 : param(p1);
    field $_p2 : param(p2);

    # Put the point with smallest z first
    ADJUST {
        if ( $_p2->z < $_p1->z )
        {
            ($_p1, $_p2) = ($_p2, $_p1);
        }
    }

    method p1z() { $_p1->z() }
    method p2z() { $_p2->z() }

    method height() { $_p2->z - $_p1->z + 1 }

    method xrange { my @r = ( min($_p1->x, $_p2->x), max($_p1->x, $_p2->x) ); }
    method yrange { my @r = ( min($_p1->y, $_p2->y), max($_p1->y, $_p2->y) ); }

    method isOverlap($other) {
        my @x1 = $self->xrange();  my @y1 = $self->yrange();
        my @x2 = $other->xrange(); my @y2 = $other->yrange();

        ($x1[0] <= $x2[1] && $x2[0] <= $x1[1]) &&
        ($y1[0] <= $y2[1] && $y2[0] <= $y1[1])
    }

    method drop($dist) { $_p1->drop($dist); $_p2->drop($dist) }

    method show() { $_p1->show() . " -- " . $_p2->show() }

    # Assume parallel to an axis, so only one dimension changes
    method length() {
        use List::Util qw/max/;
        1 + max abs($_p1->x - $_p2->x), abs($_p1->y - $_p2->y), abs($_p1->z - $_p2->z) ;
    }

    sub _seq($m, $n)
    {
        if ( $m > $n ) { ($m, $n) = ($n, $m) };
        return ($m .. $n)
    }
}

1;
