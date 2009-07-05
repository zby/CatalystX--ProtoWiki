package CatalystX::ProtoWiki::Controller::Auth;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    $c->detach('get_login');
}

sub get_login : Local {
    my ($self, $c) = @_;
    $c->stash->{destination} = $c->req->path;
    $c->stash->{template} = 'auth/login.tt';
}

sub logout : Local {
    my ( $self, $c ) = @_;
    $c->logout;
    $c->stash->{template} = 'auth/logout.tt';
}

sub login : Local {
    my ( $self, $c ) = @_;
    my $user = $c->req->params->{user};
    my $password = $c->req->params->{password};
    $c->flash->{destination} = $c->req->params->{destination} || $c->req->path;
    $c->stash->{remember} = $c->req->params->{remember};
    if ( $user && $password ) {
        if ( $c->authenticate( { username => $user,
                                 password => $password } ) ) {
            $c->{session}{expires} = 999999999999 if $c->req->params->{remember};
            $c->res->redirect( '/' . $c->flash->{destination});
        }
        else {
            # login incorrect
            $c->stash->{message} = 'Invalid user and/or password';
        }
    }
    elsif( $c->req->method eq 'POST' ) {
        # invalid form input
        $c->stash->{message} = 'invalid form input';
    }
    $c->stash->{template} =  'auth/login.tt';
}

sub unauthorized : Private {
    my ($self, $c) = @_;
    $c->stash->{template}= 'auth/unauth.tt';
}

1;

=pod

=head1 NAME

CatalystX::ProtoWiki::Controller::Auth

=head2 SUMMARY

This is a controller to provide simple authentication provided by
Catalyst::Helper::AuthDBIC. The database schema provided by the Helper
will also provide autheorization facilities.  As an example, If you
wanted to use this controller to provide application wide requirement
for login you would put something like the following in
MyApp::Controller::Root:

 sub auto : Private {
      my ( $self, $c) = @_;
      if ( !$c->user && $c->req->path !~ /^auth.*?login/) {
          $c->forward('CatalystX::ProtoWiki::Controller::Auth');
          return 0;
      }
      return 1;
 }

=cut

