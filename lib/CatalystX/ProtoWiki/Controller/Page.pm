package CatalystX::ProtoWiki::Controller::Page;

use Moose;
BEGIN {
        extends 'Catalyst::Controller';
}
use Path::Class;

has operation => ( is => 'ro', lazy_build => 1, );
sub _build_operation {
    my $self = shift;
    my $args = $self->ctx->req->args;
    warn 'operation: ' . $args->[ 2 ];
    return $args->[ 2 ];
}

has title => ( is => 'ro', lazy_build => 1 );
sub _build_title {
    my $self = shift;
    my $args = $self->ctx->req->args;
    warn 'args: ' . Dumper( $args ); use Data::Dumper;
    return $args->[ 1 ] || 'Home';
}

has page => ( is => 'ro',  lazy_build => 1, );
sub _build_page {
    my $self = shift;
    return $self->ctx->model('DBICSchemamodel')->resultset( 'Page' )->search( { title => $self->title } )->first;
}

has ctx => ( is => 'rw', );

sub auto : Local {
    my ( $self, $c ) = @_;
    $c->stash( additional_template_paths => [ dir( $c->config->{root}, 'page' ) . '' ] );
    $self->clear_title;
    $self->clear_page;
    $self->clear_operation;
    $self->ctx( $c );
}


sub is_external {
    my( $self, $operation ) = @_;
    my %ops = ( edit => 1, delete => 1 );
    return $ops{ $operation } if $operation;
    return;
}

sub default : Private {
    my ( $self ) = @_;
    my $operation = $self->operation;
    $operation = 'edit' if !$self->page;
    if( $self->is_external( $operation ) ){
        $self->$operation;
    }
    else{
        $self->ctx->stash( template => 'view.tt' );
    }
    $self->ctx->stash( page => $self->page, title => $self->title );
}

sub edit {
    my $self = shift;
    my $c = $self->ctx;
    my $params = $c->req->params;
    my $page = $self->page;
    if( ! $page ){
        $c->detach( '/auth/unauthorized' ) if !$c->user;
        $params->{title} = $self->title;
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
        $c->res->redirect( $c->uri_for( '/page', $self->title ) );
    }
    $form->field( 'submit' )->value( 'Update' ) if $page;
    $form->field( 'submit' )->value( 'Create' ) if !$page;
    warn $form->field( 'body' )->value;
    warn $form->field( 'title' )->value;
    $c->stash( page_form => $form );
    $c->stash( template => 'edit.tt' );
}

sub delete {
    my $self = shift;
    my $c = $self->ctx;
    my $page = $self->page;
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

