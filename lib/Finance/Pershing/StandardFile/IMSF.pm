package Finance::Pershing::StandardFile::IMSF;

use Moose;
use Finance::Pershing::StandardFiles::Utils qw/trim parse_date/;

extends 'Finance::Pershing::StandardFile';

our $VERSION = '0.001000';

our $detail_a = qr/^SP([ABC])(\d{8})(.{8})(.{64})(.{4})(.{32})(.{32})(\d{8})(\d{8})([SEAP])(\d{3})([SH ])?\s+X$/;

sub is_refresh {
  0;
}
sub is_delta {
  1;
}

sub _build_records {
  my $self = shift;
  my @records;
  defined(my $line = $self->next_line) or
    $self->error("File ended prematurely on HEADER");

  while ( $line =~ /$detail_a/ ){
    my $rec =
      {
       record_id => $1,
       pershing_user_id => $3,
       proprietary_user_id => trim $4,
       ibd_num => trim $5,
       first_name => trim $6,
       last_name => trim $7,
       created_d => parse_date($8),
       last_used_d => parse_date($9),
       status_ind => $10,
       ($12 ne ' ' ? (sso_hybrid_ind => $12) : ()),
      };
    my $tmp = trim($11);
    if($tmp && $tmp > 0){
      my $expiry = $self->data_date->clone;
      $expiry->add(days => $tmp);
      $rec->{days_to_expiry} = $tmp;
      $rec->{expiry_d} = $expiry;
    }
    push(@records, $rec);
    defined($line = $self->next_line) or
      $self->error("File ended prematurely on DETAIL A");
  }
  if ( $self->_process_footer($line) ) {
    return \@records;
  } else {
    $self->error("Got '$line' where DETAIL/FOOTER record was expected");
  }
  $self->error("Recieved no FOOTER record. File possibly truncated");
}

__PACKAGE__->meta->make_immutable;

1;

__END__;

=head1 NAME

Finance::Pershing::StandardFile::IMSF - ID Management File

=head1 SYNOPSIS

=head1 METHODS

=head2 _build_records

=over 4

=item record_id

=item pershing_user_id

=item proprietary_user_id

=item ibd_num

=item first_name

=item last_name

=item created_d

=item last_used_d

=item status_ind

=item days_to_expiry

=item sso_hybrid_ind

=back

=head1 AUTHOR & LICENSE

Please see L<Finance::Pershing::StandardFile> for more information.

=cut
