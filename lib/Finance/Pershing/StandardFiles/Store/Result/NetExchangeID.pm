package Finance::Pershing::StandardFiles::Store::Result::NetExchangeID;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table('net_exchange_ids');
__PACKAGE__->add_columns(
  id_type => {
    data_type => "ENUM",
    is_nullable => 0,
    extra => { list => [qw/direct hybrid sso/] },
  },
  user_id => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 64
  },
  ibd_num => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 4
  },
  proprietary_id => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 64,
  },
  first_name  => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 32,
  },
  last_name   => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 32,
  },
  created_d   => {
    data_type => "DATE",
    is_nullable => 0,
  },
  last_used_d => {
    data_type => "DATE",
    is_nullable => 0,
  },
  expiry_d    => {
    data_type => "DATE",
    is_nullable => 0,
  },
  status_code  => {
    data_type => "ENUM",
    is_nullable => 0,
    extra => { list => [qw/a e p s/] },
  },
  sso_hybrid_ind => {
    data_type => "ENUM",
    is_nullable => 0,
    extra => { list => [qw/sso hybrid/] },
  }
);

__PACKAGE__->set_primary_key(qw/user_id/);

{
  my $status_descriptions = {
    a => 'Active',
    e => 'Expired',
    p => 'Suspended (Pershing Admin. can un-suspend)',
    s => 'Suspended (IBD can un-suspend)',
  };

  sub status_description {
    return $status_descriptions->{shift->status_code};
  }
}

1;

