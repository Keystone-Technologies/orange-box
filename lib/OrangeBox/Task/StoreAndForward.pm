package OrangeBox::Task::StoreAndForward;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::UserAgent;

has ua => sub { Mojo::UserAgent->new };

sub register {
  my ($self, $app, $conf) = @_;

  $app->minion->add_task(store_and_forward => sub {
    my ($job, $store, $forward) = @_;

    # TODO: verify that $store and $forward have what's necessary

    my $log = sprintf "%s (mail %s) | %s | %s => %s | %s",
                $job->id,
                ($app->config->{relay}->{disable} ? 'disabled' : 'enabled'),
                $forward->{from},
                $forward->{'X-Original-To'},
                $forward->{to},
                $forward->{subject};

    my $id = $job->app->model->events->add({  # Database     # Store
      log => $log,
      incoming => Mojo::JSON::encode_json $store,
    });
    #warn "$log\n";                            # stderr
    $job->app->app->log->info($log);          # App log
    $job->app->syslog("info", $log);          # Syslog
    $self->ua->post(                          # Loggly
      "http://logs-01.loggly.com/inputs/4c762b87-c50c-4dbb-9df6-3ad91d865ad7/tag/orangebox,$forward->{to}/" => json => $store
    );
    $job->app->pg->pubsub->notify(            # Webbrowser
      events => qq(<a href="/incoming/$id/view">$log</a>), # TODO: pass JSON instead
    );

    $job->app->mail(test => $app->config->{relay}->{disable}, %$forward);                   # Forward

    $job->finish($log);

    $job->app->pg->pubsub->notify(            # Webbrowser
      events => sprintf('%s | %s | %s', $job->id, $job->info->{state}, $job->info->{result}), # TODO: pass JSON instead
    );

  });
}

1;
