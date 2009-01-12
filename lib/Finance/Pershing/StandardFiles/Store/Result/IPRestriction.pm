package Finance::Pershing::StandardFiles::Store::Result::IPRestriction;

use strict;
use warnings;

use aliased 'Finance::Pershing::StandardFiles::Store::Result::SecurityProfile';

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('ip_restrictions');
__PACKAGE__->add_columns(
  id => {
    data_type => "INT",
    size      => 10 ,
    default_value => undef,
    is_nullable   => 0,
    is_auto_increment => 1,
    extra => { unsigned => 1 },
  },
  user_id => {
    data_type => "CHAR",
    is_nullable => 0,
    size => 8,
    is_foreign_key => 1,
  },
  ip_num  => {
    data_type => "VARCHAR",
    is_nullable => 1,
    size => 4
  },
  bp_id   => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 16
  },
  reason  => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 15
  },
  type => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 25
  },
  role => {
    data_type => "CHAR",
    is_nullable => 0,
    size => 8
  },
);

__PACKAGE__->set_primary_key(qw/id/);

__PACKAGE__->belongs_to(
  security_profile => SecurityProfile,
  { 'foreign.user_id' => 'self.user_id' }
);

1;

__END__;
