package OrangeBox::Controller::Events;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;
  #$self->render('index');
}

sub watch {
  my $self = shift;

  $self->inactivity_timeout(3600);

  # Forward messages from the browser to PostgreSQL
  $self->on(message => sub { shift->pg->pubsub->notify(events => shift) });

  # Forward messages from PostgreSQL to the browser
  my $cb = $self->pg->pubsub->listen(events => sub { $self->send(pop) });
  $self->on(finish => sub { shift->pg->pubsub->unlisten(events => $cb) });
}

1;
