package OrangeBox::Plugin::CloudMailIn::Model::Events;
use Mojo::Base 'OrangeBox::Model::Events';

sub get_body {
  my ($self, $id) = @_;
  return $self->pg->db->query('select incoming->\'html\' as data from events where id = ?', $id)->expand->hash->{data};
}

1;
