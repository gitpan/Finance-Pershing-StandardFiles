package Finance::Pershing::StandardFiles::Store::ResultSet::NetExchangeID;

use strict;
use warnings;
use base 'Finance::Pershing::StandardFiles::Store::ResultSet';

sub coerce {
  my $self = shift;
  my $data = shift;
  $data->{status_code} = lc(delete $data->{status_ind});
  if(my $type = delete $data->{record_id}){
    if($type eq 'A'){
      $data->{id_type} = 'sso';
    } elsif($type eq 'B') {
      $data->{id_type} = 'hybrid';
    } elsif($type eq 'C') {
      $data->{id_type} = 'direct';
    } else {
      die "Unrecognized id_type ${type}";
    }
  }
  if(my $sso_hybrid = delete $data->{sso_hybrid_ind}){
    if($sso_hybrid eq 'S'){
      $data->{sso_hybrid_ind} = 'sso';
    } elsif($sso_hybrid eq 'H') {
      $data->{sso_hybrid_ind} = 'hybrid';
    } else {
      die "Unrecognized sso_hybrid_ind ${sso_hybrid}";
    }
  }
  delete $data->{days_to_expiry};
  return $self->next::method($data);
}

our %coerce_map =(
  pershing_user_id => 'user_id',
  proprietary_user_id => 'proprietary_id',
);

1;

__END__;
