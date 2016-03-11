package OrangeBox::Task::StoreAndForward;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app, $conf) = @_;

  $app->minion->add_task(store_and_forward => sub {
    my ($job, $store, $forward) = @_;

    # TODO: verify that $store and $forward have what's necessary

    my $log = sprintf "%s | %s | %s => %s | %s", $job->id, $forward->{from}, $forward->{'X-Original-To'}, $forward->{to}, $forward->{subject};

    my $id = $job->app->model->events->add({  # Database     # Store
      log => $log,
      incoming => Mojo::JSON::encode_json $store,
    });
    #warn "$log\n";                            # stderr
    $job->app->app->log->info($log);          # App log
    $job->app->syslog("info", $log);          # Syslog
    $job->app->pg->pubsub->notify(            # Webbrowser
      events => qq(<a href="/incoming/$id/view">$log</a>), # TODO: pass JSON instead
    );

    $job->app->mail(test => $app->config->{relay}->{disable}, %$forward);                   # Forward

    $job->finish($log);
  });
}

1;
