package CatalystX::ProtoWiki::Controller::PageList;

use Moose;
BEGIN {
    extends 'Catalyst::Example::Controller::InstantCRUD';
}

sub build_source_name { 'Page' };

sub index : Private {
    my ( $self, $c ) = @_;
    $self->list( $c );
    $c->stash( template => 'list.tt' );
}

1;

