package CatalystX::ProtoWiki::Model::DBICSchemamodel;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'CatalystX::ProtoWiki::DBSchema',
    connect_info => [
        'dbi:SQLite:wiki.db',
        '',
        '',
        
    ],
);

=head1 NAME

CatalystX::ProtoWiki::Model::DBICSchemamodel - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<CatalystX::ProtoWiki>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<CatalystX::ProtoWiki::DBSchema>

=head1 AUTHOR

Zbyszek,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
