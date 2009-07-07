package CatalystX::ProtoWiki::Controller::Register;

use Moose;
BEGIN {
    extends 'Catalyst::Controller';
}


sub index : Private {
    my ( $self, $c ) = @_;
    my $form = CatalystX::ProtoWiki::Controller::User::RegisterForm->new(
        schema => $c->model( 'DBICSchemamodel' ),
        params => $c->req->params,
    );
    if( $c->req->method eq 'POST' && $form->process() ){
        my $item = $form->item;
        $c->authenticate( { username => $item->username, password => $item->password } );
        CatalystX::ProtoWiki::Controller::User->send_confirmation_email( $item, $c->uri_for( '/', 'user', 'confirm_email' ), 'admin@example.com' );
        $c->res->redirect( $c->uri_for( '/', 'user', 'view', $item->username ) );
    }
    $c->stash( form => $form->render );
    $c->stash( template => 'register.tt' );
}

{
    package CatalystX::ProtoWiki::Controller::User::RegisterForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    with 'HTML::FormHandler::Render::Simple';
    use HTML::FormHandler::Types ('NoSpaces', 'WordChars', 'NotAllDigits' );


    has '+item_class' => ( default => 'User' );

        has_field 'email' => ( type => 'Email', required => 1 );
        has_field 'username' => ( size => 32, required => 1, unique => 1 );
        has_field 'password' => ( type => 'Password', min_length => 5, size => 32, apply => [ NotAllDigits ], required => 1 );
        has_field 'password_' => ( type => 'PasswordConf', size => 32, label => 'Repeate password' );
    
    has_field submit => ( widget => 'submit', value => 'Register' )
}



1;

