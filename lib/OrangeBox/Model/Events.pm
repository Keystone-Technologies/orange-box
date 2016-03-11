package OrangeBox::Model::Events;
use Mojo::Base -base;

has 'pg';

sub add {
  my ($self, $event) = @_;
  my $sql = 'insert into events (log, incoming) values (?, ?) returning id';
  return $self->pg->db->query($sql, $event->{log}, $event->{incoming})->hash->{id};
}

sub all { shift->pg->db->query('select * from events')->expand->hashes->to_array }

sub tail { shift->pg->db->query('select id,log from events order by id desc limit ?', shift)->hashes->reverse->to_array }

sub find {
  my ($self, $id) = @_;
  return $self->pg->db->query('select * from events where id = ?', $id)->expand->hash;
}

sub remove { shift->pg->db->query('delete from events where id = ?', shift) }

1;