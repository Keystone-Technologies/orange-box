package OrangeBox::Plugin::Syslog;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use Sys::Syslog;

sub register {
  my ($self, $app) = @_;

  openlog($app->moniker, 'ndelay', "local0");
  $app->helper(syslog => sub { shift; syslog(@_) });
}

1;
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Syslog - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Syslog');

  # Mojolicious::Lite
  plugin 'Syslog';

=head1 DESCRIPTION

L<Mojolicious::Plugin::Syslog> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::Syslog> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.

=cut
