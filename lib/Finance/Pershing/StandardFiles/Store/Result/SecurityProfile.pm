package Finance::Pershing::StandardFiles::Store::Result::SecurityProfile;

use strict;
use warnings;

use aliased 'Finance::Pershing::StandardFiles::Store::Result::ASDSRole';
use aliased 'Finance::Pershing::StandardFiles::Store::Result::IPRestriction';
use aliased 'Finance::Pershing::StandardFiles::Store::Result::TopSecretProfile';

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table('security_profiles');
__PACKAGE__->add_columns(
  user_id => {
    data_type => "CHAR",
    is_nullable => 0,
    size => 8,
  },
  ibd_num => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 4,
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
  ssn_trailing4 => {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 4,
  },
  created_d   => {
    data_type => "DATE",
    is_nullable => 1,
  },
  last_used_d => {
    data_type => "DATETIME",
    is_nullable => 1,
  },
  expiry_d    => {
    data_type => "DATE",
    is_nullable => 1,
  },
);

__PACKAGE__->set_primary_key(qw/user_id/);

__PACKAGE__->has_many(
  asds_roles => ASDSRole,
  { 'foreign.user_id' => 'self.user_id' },
);

__PACKAGE__->has_many(
  top_secret_profiles => TopSecretProfile,
  { 'foreign.user_id' => 'self.user_id' },
);

__PACKAGE__->has_many(
  ip_restrictions => IPRestriction,
  { 'foreign.user_id' => 'self.user_id' },
);

1;

__END__;
