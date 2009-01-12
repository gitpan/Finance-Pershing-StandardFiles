package Finance::Pershing::StandardFiles::Store::ResultSet::SecurityProfile;

use strict;
use warnings;
use base 'Finance::Pershing::StandardFiles::Store::ResultSet';

sub delete{ shift->delete_all(@_) }

sub update{ shift->update_all(@_) }

sub coerce {
  my $self = shift;
  my $data = shift;
  delete $data->{days_to_expiry};
  return $self->next::method($data);
}

sub coerce_and_create {
  my $self = shift;
  my $data = shift;
  my $roles = delete $data->{asds_roles};
  my $restrictions = delete $data->{ip_restrictions};
  my $ts_profiles = delete $data->{top_secret_profiles};
  my $item = $self->next::method($data);
  $item->asds_roles->create($_) foreach @$roles;
  $item->ip_restrictions->create($_) foreach @$restrictions;
  $item->top_secret_profiles->create($_) foreach @$ts_profiles;
  return $item;
}

sub coerce_and_update_or_create {
  my $self = shift;
  my $data = shift;
  my $roles = delete $data->{asds_roles};
  my $restrictions = delete $data->{ip_restrictions};
  my $ts_profiles = delete $data->{top_secret_profiles};
  my $item = $self->next::method($data);

  $item->asds_roles->delete;
  $item->asds_roles->create($_) foreach @$roles;
  $item->ip_restrictions->delete;
  $item->ip_restrictions->create($_) foreach @$restrictions;
  $item->top_secret_profiles->delete;
  $item->top_secret_profiles->create($_) foreach @$ts_profiles;

  return $item;
}

our %coerce_map =(
  pershing_user_id => 'user_id',
  proprietary_user_id => 'proprietary_id',
);

1;
