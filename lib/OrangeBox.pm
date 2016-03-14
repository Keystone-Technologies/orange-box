package OrangeBox;
use Mojo::Base 'Mojolicious';

use Mojo::Pg;
use Mojo::Util qw(camelize);

# $ mojo get -v -H "Host: orangebox.dev.kit.cm" -H "content-type: application/json" -M POST -c  '{"headers":{"Subject":"Subject"},"html":"HTML","envelope":{"to5823e5cc58a+sadams+test1@cloudmailin.net","from":"qaz@qaz.com"}}' http://127.0.0.1:3000/incoming

# This method will run once at server start
sub startup {
  my $self = shift;

  push @{$self->commands->namespaces}, 'OrangeBox::Command';
  push @{$self->plugins->namespaces}, 'OrangeBox::Plugin';

  $self->plugin('Config' => {
    relay => {
      disable => '1',
    },
  });
  $self->plugin('Minion' => {Pg => $self->config->{pg}});
  $self->plugin('Syslog');
  $self->plugin('Mail' => $self->config->{mail});
  $self->plugin($self->config->{incoming}) or die "TODO";

  $self->secrets($self->config->{secrets});

  $self->helper(pg => sub { state $pg = Mojo::Pg->new(shift->config('pg')) });
  $self->helper(add_task => sub { shift; $self->plugin(join '::', __PACKAGE__, 'Task', camelize shift) });

  $self->add_task('store_and_forward');

  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/events.sql');
  $self->pg->migrations->name('events')->from_file($path)->migrate;

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('events#index');
  $r->websocket('/watch')->to('events#watch');

  # Normal route to controller
  $r->get('/incoming/:id/view')->to('incoming#view')->name('view_incoming');
  $r->get('/incoming/test/#to')->to('incoming#store_and_forward');
  $r->post('/incoming')->to('incoming#store_and_forward');
}

1;
