package CatalystX::ProtoWiki::Controller::Page;

use Moose;
BEGIN {
        extends 'Catalyst::Controller';
}
use Path::Class;

sub auto : Local {
    my ( $self, $c ) = @_;
    $c->stash( additional_template_paths => [ dir( $c->config->{root}, 'page' ) . '' ] );
}

sub find_by_title {
    my( $self, $c, $title ) = @_;

    return $c->model('DBICSchemamodel')->resultset( 'Page' )->search( { title => $title } )->first;

}
sub default : Private {
    my ( $self, $c, $page, $title, $operation ) = @_;
    if( !length( $title ) ){
        $title = 'Home';
    }
    my $page = $self->find_by_title( $c, $title );
    if( !$page || $operation eq 'edit' ){
        my $params = $c->req->params;
        if( ! $page ){
            $c->detach( '/auth/unauthorized' ) if !$c->user;
            $params->{title} = $title;
            $params->{creator} = $c->user->id;
        }
        my @page = ();
        @page = ( item => $page ) if $page;
        my $form = CatalystX::ProtoWiki::Controller::Page::PageForm->new( 
            params => $params,
            schema => $c->model('DBICSchemamodel' ),
            @page
        );
        if( $c->req->method eq 'POST' && $form->process() ){
            $c->res->redirect( $c->uri_for( '/page', $title ) );
        }
        $form->field( 'submit' )->value( 'Update' ) if $page;
        $form->field( 'submit' )->value( 'Create' ) if !$page;
        warn $form->field( 'body' )->value;
        warn $form->field( 'title' )->value;
        $c->stash( page_form => $form );
        $c->stash( template => 'edit.tt' );
    }
    elsif( $operation eq 'delete' ){
        $self->delete( $c, $page );
    }
    else{
        $c->stash( template => 'view.tt' );
    }

    $c->stash( page => $page, title => $title );
}


sub delete {
    my ( $self, $c, $page ) = @_;
    if ( $c->req->method eq 'POST' ) {
        $page->delete;
        $c->res->redirect( $c->uri_for( '/pagelist' ) );
    }
    else {
        my $action_uri = '/' . $c->req->path;
        $c->stash->{delete_widget} = <<END;
<form action="$action_uri" id="widget" method="post">
<fieldset class="widget_fieldset">
<input class="submit" id="widget_ok" name="ok" type="submit" value="Delete ?" />
</fieldset>
</form>
END
        $c->stash( template => 'delete.tt' );
    }
}


{
    package CatalystX::ProtoWiki::Controller::Page::PageForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    with 'HTML::FormHandler::Render::Simple';


    has '+item_class' => ( default => 'Page' );

        has_field 'title' => ( widget => 'no_render' );
        has_field 'creator' => ( widget => 'no_render' );
        has_field 'body' => ( type => 'TextArea', cols => 100, rows => 30, required => 1 );
    
    has_field submit => ( widget => 'submit' )
}




1;

