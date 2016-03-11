package OrangeBox::Plugin::CloudMailIn;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use OrangeBox::Plugin::CloudMailIn::Model::Events;

sub register {
  my ($self, $app) = @_;

  die "TODO" unless $app->config->{relay}->{default};
  die "TODO" unless $app->config->{relay}->{domain};

  $app->helper('model.events' => sub {
    state $events = OrangeBox::Plugin::CloudMailIn::Model::Events->new(pg => shift->pg)
  });

  $app->helper(do_store_and_forward => sub {
    my ($c, $forward) = @_;

    my $store = $c->req ? $c->req->json : {};
    $forward = {map { $_ => $c->param('to') } qw(to from subject data)} if $c->param('to');

    if ( $forward ) {
      $store->{envelope}->{to} = $forward->{'X-Original-To'} = $forward->{to};
      $store->{headers}->{From} = $forward->{from};
      $store->{headers}->{Subject} = $forward->{subject};
      $store->{html} = $forward->{data};
    }

    $forward->{to} ||= $store->{envelope}->{to};
    $forward->{from} ||= $store->{headers}->{From};
    $forward->{subject} ||= $store->{headers}->{Subject};
    $forward->{data} ||= $store->{html};
    $forward->{'X-Original-To'} = $forward->{to};

    my $secret = $app->secrets->[0];
    $forward->{to} =~ s/^($secret.*)\@.+$/$1/ or return undef;
    my @relay = split /\+/, $forward->{to};
    $relay[1] ||= $app->config->{relay}->{default} if $app->mode ne 'production';
    $forward->{to} = join('+', @relay[1,0,2..$#relay]).'@'.$app->config->{relay}->{domain};

    return $c->minion->enqueue('store_and_forward', [$store, $forward]);
  });
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
