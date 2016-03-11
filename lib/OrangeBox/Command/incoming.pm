package OrangeBox::Command::incoming;
use Mojo::Base 'Mojolicious::Command';

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => 'Issue incoming data (for testing)';
has usage => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;

  GetOptionsFromArray \@args,
    't|to=s'      => \my $to,
    'f|from=s'    => \my $from,
    's|subject=s' => \my $subject;

  die "TODO" unless $to && $from && $subject;

  say $self->app->do_store_and_forward({
    to => $to,
    from => $from,
    subject => $subject,
    data => join '', <STDIN>
  });
}

1;
