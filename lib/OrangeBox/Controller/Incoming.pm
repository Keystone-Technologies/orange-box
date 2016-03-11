package OrangeBox::Controller::Incoming;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub view {
  my $self = shift;
  $self->stash(id => $self->param('id'));
  $self->render(text => $self->model->events->get_body($self->stash->{id}));
}

sub store_and_forward {
  my $self = shift;

  $self->render(json => {err => 'ok', job => $self->do_store_and_forward});
}

1;
