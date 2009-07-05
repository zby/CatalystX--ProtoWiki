use strict;
use warnings;

package CatalystX::ProtoWiki;

use Catalyst::Runtime '5.70';


use Catalyst qw/
	-Debug
	ConfigLoader
	Static::Simple
    Unicode

               Authentication
               Authorization::Roles
               Session
               Session::State::Cookie
               Session::Store::FastMmap /;
#	Session
#	Session::Store::FastMmap
#	Session::State::Cookie
#	Authentication
#	Authentication::Store::DBIC
#	Authentication::Credential::Password
#	Auth::Utils

our $VERSION = '0.01';

__PACKAGE__->config( name => 'CatalystX::ProtoWiki' );


# Start the application
__PACKAGE__->setup;

#
# IMPORTANT: Please look into CatalystX::ProtoWiki::Controller::Root for more
#

=head1 NAME

CatalystX::ProtoWiki - Catalyst based application

=head1 SYNOPSIS

    script/catalystx_protowiki_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 SEE ALSO

L<CatalystX::ProtoWiki::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Zbyszek,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
