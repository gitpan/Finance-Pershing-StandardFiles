package Finance::Pershing::StandardFiles::Store::Result::TopSecretProfile;

use strict;
use warnings;

use aliased 'Finance::Pershing::StandardFiles::Store::Result::SecurityProfile';

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('top_secret_profiles');
__PACKAGE__->add_columns(
  user_id => {
    data_type => "CHAR",
    is_nullable => 0,
    size => 8,
    is_foreign_key => 1,
  },
  code => {
    data_type => "CHAR",
    is_nullable => 0,
    size => 8
  },
);

__PACKAGE__->set_primary_key(qw/user_id code/);

__PACKAGE__->belongs_to(
  security_profile => SecurityProfile,
  { 'foreign.user_id' => 'self.user_id' }
);

1;

__END__;
