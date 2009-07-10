use strict;
use warnings;

package CatalystX::ProtoWiki::Controller::User;

use base "Catalyst::Controller";
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Path::Class;

sub resultset { 
    my ( $self, $c ) = @_;
    return $c->model('DBICSchemamodel')->resultset( 'User' );
}

sub get_operation {
    my ( $self, $c ) = @_;
    my $args = $c->req->args;
    return $args->[0] if $self->is_external( $args->[0] );
    return 'list' if !defined $args->[0];
    my $operation = $args->[ 1 ] || 'view';
    return $operation;
}

sub get_id {
    my ( $self, $c ) = @_;
    my $args = $c->req->args;
    return $args->[0] if ! $self->is_external( $args->[0] );
    return;
}


sub is_external {
    my( $self, $operation ) = @_;
    my %ops = map { $_ => 1 } qw( edit delete view confirm_email edit_info edit_password list register );
    return $ops{ $operation } if $operation;
    return;
}


sub default : Path {
    my ( $self, $c ) = @_;
    $c->stash( additional_template_paths => [ dir( $c->config->{root}, 'user' ) . '' ] );
    my $operation = $self->get_operation( $c );
    my $id = $self->get_id( $c );
    if( defined $id ){
        my $item = $self->resultset( $c )->search( { username => $id } )->first;
        if( !$item){
            $c->response->status(404);
            $c->response->body("404 Not Found");
            $c->detach;
        }
        $c->stash( item => $item );
    }
    warn 'operation: ' . $operation;
    $c->stash( template => $operation . '.tt' );
    $self->$operation( $c );
}

sub register {
    my ( $self, $c ) = @_;
    my $form = CatalystX::ProtoWiki::Controller::User::RegisterForm->new(
        schema => $c->model( 'DBICSchemamodel' ),
        params => $c->req->params,
    );
    if( $c->req->method eq 'POST' && $form->process() ){
        my $item = $form->item;
        $c->authenticate( { username => $item->username, password => $item->password } );
        $self->send_confirmation_email( $item, $c->uri_for( $item->username, 'confirm_email', $item->email_conf_code ), 'admin@example.com' );
        $c->res->redirect( $c->uri_for( $item->username, 'view' ) );
    }
    $c->stash( form => $form->render );
}

sub view { }

sub check_auth {
    my( $self, $c, ) = @_;
    my $username = $c->stash->{item}->username;
    if( !$c->user 
        || ( $c->user->username ne $username && !$c->check_user_roles('admin') ) 
    ){
        $c->detach( '/auth/unauthorized' );
    }
}

sub send_confirmation_email {
    my ( $self, $user, $conf_url, $our_email ) = @_;
    my $email = Email::Simple->create( 
        header => [
        To      => $user->email,
        From    => $our_email,
        Subject => "Registration",
        ],
        body => "Hi there!  Someone has registered your email address at our site.  Please go to $conf_url to confirm your email address.",
    );
    sendmail($email);
}

sub confirm_email : Local {
    my ( $self, $c, ) = @_;
    my $user = $c->stash->{item};
    my $args = $c->req->args;
    warn Dumper( $args ); use Data::Dumper;
    if( $args->[2] eq $user->email_conf_code ){
        $user->update( { email_confirmed => 1 } );
        $c->stash( confirmed => 1 );
    } 
}

sub edit_info {
    my ( $self, $c, ) = @_;
    $self->check_auth( $c, );
    my $form = CatalystX::ProtoWiki::Controller::User::InfoUpdateForm->new(
        params => $c->req->params,
        item => $c->stash->{item},
    );
    if( $c->req->method eq 'POST' && $form->process() ){
        $c->res->redirect( $c->uri_for( $form->item->username, 'view' ) );
    }
    else{
        $c->stash( form => $form->render );
        $c->stash( template => 'edit.tt' );
    }
}

sub edit_password {
    my ( $self, $c, ) = @_;
    $self->check_auth( $c, );
    my $form = CatalystX::ProtoWiki::Controller::User::PasswordUpdateForm->new(
        params => $c->req->params,
        item => $c->stash->{item},
    );
    if( $c->req->method eq 'POST' ){
        if( ! $c->authenticate( { 
                    username => $c->stash->{item}->username,
                    password => $c->req->params->{old_password} 
                }
            )
        ){
            $form->field( 'old_password' )->add_error( 'Wrong password' );
        }
        elsif( $form->process() ){
            $c->res->redirect( $c->uri_for( $c->stash->{item}->username, 'view' ) );
        }
    }
    $c->stash( form => $form->render );
    $c->stash( template => 'edit.tt' );
}

sub get_resultset {
    my ( $self, $c ) = @_;
    my $params = $c->request->params;
    my $order  = $params->{'order'};
    $order .= ' DESC' if $params->{'o2'};
    my $maxrows = $c->config->{InstantCRUD}{maxrows} || 10;
    my $page = $params->{'page'} || 1;
    return $self->resultset($c)->search(
        {},
        {
            page     => $page,
            order_by => $order,
            rows     => $maxrows,
        }
    );
}

sub create_col_link {
    my ( $self, $c, $source ) = @_;
    my $origparams = $c->request->params;
    return sub {
        my ( $column, $label ) = @_;
        my $addr;
        no warnings 'uninitialized';
        if ( $origparams->{'order'} eq $column && !$origparams->{'o2'} ) {
            $addr = $c->request->uri_with({ page => 1, order =>  $column, o2 => 'desc' });
        }else{
            $addr = $c->request->uri_with({ page => 1, order =>  $column, o2 => undef });
        }
        my $result = qq{<a href="$addr">$label</a>};
        if ( $origparams->{'order'} && $column eq $origparams->{'order'} ) {
            $result .= $origparams->{'o2'} ? "&darr;" : "&uarr;";
        }
        return $result;
    };
}

sub list {
    my ( $self, $c ) = @_;
    my $result = $self->get_resultset($c);
    $c->stash->{pager}     = $result->pager;
    my $source  = $result->result_source;
    ($c->stash->{pri}) = $source->primary_columns;
    $c->stash->{order_by_column_link} = $self->create_col_link($c, $source);
    $c->stash->{result} = $result;
}


{
    package CatalystX::ProtoWiki::Controller::User::InfoUpdateForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    with 'HTML::FormHandler::Render::Simple';

    has '+item_class' => ( default => 'User' );

    has_field 'email' => ( type => 'Email', required => 1 );
    
    has_field submit => ( type => 'Submit', value => 'Update' )
}

{
    package CatalystX::ProtoWiki::Controller::User::PasswordUpdateForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    with 'HTML::FormHandler::Render::Simple';
    use HTML::FormHandler::Types ('NoSpaces', 'WordChars', 'NotAllDigits' );


    has '+item_class' => ( default => 'User' );

        has_field 'old_password' => ( type => 'Password', required => 1, minlength => 5 );
        has_field 'password' => ( type => 'Password', minlength => 5, size => 32, apply => [ NotAllDigits ], required => 1 );
        has_field 'password_' => ( type => 'PasswordConf', size => 32, );
    
    has_field submit => ( type => 'Submit', value => 'change password' )
}

{
    package CatalystX::ProtoWiki::Controller::User::RegisterForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    with 'HTML::FormHandler::Render::Simple';
    use HTML::FormHandler::Types ('NoSpaces', 'WordChars', 'NotAllDigits' );


    has '+item_class' => ( default => 'User' );

        has_field 'email' => ( type => 'Email', required => 1 );
        has_field 'username' => ( size => 32, required => 1, unique => 1,
            apply => [ 
            { 
                check => sub { !CatalystX::ProtoWiki::Controller::User->is_external( shift ) },
                message => 'This is a reserverd name and cannot be used as username' 
            } 
            ],
        );
        has_field 'password' => ( type => 'Password', min_length => 5, size => 32, apply => [ NotAllDigits ], required => 1 );
        has_field 'password_' => ( type => 'PasswordConf', size => 32, label => 'Repeate password' );

    has_field submit => ( type => 'Submit', value => 'Register' )
}


1;

