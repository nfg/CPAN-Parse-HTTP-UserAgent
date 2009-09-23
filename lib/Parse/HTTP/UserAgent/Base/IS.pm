package Parse::HTTP::UserAgent::Base::IS;
use strict;
use warnings;
use vars qw( $VERSION );
use Parse::HTTP::UserAgent::Constants qw(:all);
use constant OPERA_FAKER_EXTRA_SIZE => 4;

$VERSION = '0.10';

sub _is_opera_pre {
    my($self, $moz) = @_;
    return index( $moz, 'Opera') != MINUS_ONE;
}

sub _is_opera_post {
    my($self, $extra) = @_;
    return $extra && $extra->[0] eq 'Opera';
}

sub _is_opera_ff { # opera faking as firefox
    my($self, $extra) = @_;
    return $extra && @{$extra} == OPERA_FAKER_EXTRA_SIZE && $extra->[2] eq 'Opera';
}

sub _is_safari {
    my($self, $extra, $others) = @_;
    my $str = $self->[UA_STRING];
    # epiphany?
    return                index( $str         , 'Chrome'       ) != MINUS_ONE ? 0 # faker
          :    $extra  && index( $extra->[0]  , 'AppleWebKit'  ) != MINUS_ONE ? 1
          : @{$others} && index( $others->[MINUS_ONE], 'Safari') != MINUS_ONE ? 1
          :                                                                     0
          ;
}

sub _is_chrome {
    my($self, $extra, $others) = @_;
    my $chx = $others->[1] || return;
    my($chrome, $safari) = split RE_WHITESPACE, $chx;
    return if ! ( $chrome && $safari);

    return              index( $chrome    , 'Chrome'     ) != MINUS_ONE &&
                        index( $safari    , 'Safari'     ) != MINUS_ONE &&
           ( $extra  && index( $extra->[0], 'AppleWebKit') != MINUS_ONE);
}

sub _is_ff {
    my($self, $extra) = @_;
    return if ! $extra || ! $extra->[1];
    my $moz_with_name = $extra->[1] eq 'Mozilla' && $extra->[2];
    return $moz_with_name
        ? $extra->[2] =~ RE_FIREFOX_NAMES && do { $extra->[1] = $extra->[2] }
        : $extra->[1] =~ RE_FIREFOX_NAMES
    ;
}

sub _is_gecko {
    return index(shift->[UA_STRING], 'Gecko/') != MINUS_ONE;
}

sub _is_generic { #TODO: this is actually a parser
    my($self, @args) = @_;
    return 1 if $self->_generic_name_version( @args ) ||
                $self->_generic_compatible(   @args ) ||
                $self->_generic_moz_thing(    @args );
    return;
}

sub _is_netscape {
    my($self, $moz, $thing, $extra, $compatible, @others) = @_;

    my $rv = index($moz, 'Mozilla/') != MINUS_ONE &&
             $moz ne 'Mozilla/4.0'         &&
             ! $compatible                 &&
             ! $extra                      &&
             ! @others                     &&
             $thing->[MINUS_ONE] ne 'Sun'  && # hotjava
             index($thing->[0], 'http://') == MINUS_ONE # robot
             ;
    return $rv;
}

sub _is_docomo {
    my($self, $moz) = @_;
    return index(lc $moz, 'docomo') != MINUS_ONE;
}

sub _is_strength {
    my $self = shift;
    my $s    = shift || return;
       $s    = $self->trim( $s );
    return $s if $s eq 'U' || $s eq 'I' || $s eq 'N';
    return;
}

sub _is_generic_bogus_ie {
    my($self, $extra) = @_;
    return $extra
        && $extra->[0]
        && index( $extra->[0], 'compatible' ) != MINUS_ONE
        && $extra->[1]
        && $extra->[1] eq 'MSIE';
}

1;

__END__

=pod

=head1 NAME

Parse::HTTP::UserAgent::Base::IS - Base class

=head1 DESCRIPTION

Internal module.

=head1 SEE ALSO

L<Parse::HTTP::UserAgent>.

=cut
