package Finance::Pershing::StandardFile::SPAT;

use Moose;
use Finance::Pershing::StandardFiles::Utils qw/trim parse_date/;

extends 'Finance::Pershing::StandardFile';

our $VERSION = '0.002000';

our $detail = qr/^SP[ABC]\d{6}(\w{8})(.{4})(.{32})(.{32})(\d{4}|\s{4}).{660}X$/;
our $detail_a = qr/^SPA\d{6}(\w{8})(.{4})(.{32})(.{32})(\d{4}|\s{4})(\d{8})(.{640})(\d{8}|\s{8})(\d{4}|\s{4})X$/;
our $detail_b = qr/^SPB\d{6}(\w{8})(.{4})(.{32})(.{32})(\d{4}|\s{4})(\d{8})(.{644})(\d{6}|\s{6})(\d{2}|\s{2})X$/;
our $detail_c = qr/^SPC\d{6}(\w{8})(.{4})(.{32})(.{32})(\d{4}|\s{4})(.{612}).{48}X$/;

sub is_refresh {
  0;
}
sub is_delta {
  1;
}

sub _build_records {
  my $self = shift;
  my %records;

  while( defined(my $line = $self->next_line) ){
    if ( $line =~ /$detail/ ){
      my $rec = $records{$1} ||= {};
      $rec->{pershing_user_id} ||= $1;
      $rec->{ibd_num}    ||= $2;
      $rec->{first_name} ||= trim $3;
      $rec->{last_name}  ||= trim $4;
      if( !exists($rec->{ssn_trailing4}) and (my $ssn = trim $5)){
        $rec->{ssn_trailing4} = $5;
      }
    }

    if ( $line =~ /$detail_a/ ){
      my $rec = $records{$1};
      my $profile_str = $7;
      if( !exists($rec->{created_d}) and (my $date = parse_date($6))) {
        $rec->{created_d} = $date;
      }
      if( !exists($rec->{last_used_d}) and (my $date = parse_date($8,$9))){
        $rec->{last_used_d} = $date;
      }
      my $profiles = $rec->{top_secret_profiles} ||= [];
      my @curr_profiles = map { {code => trim($_)} }
        grep {/\w+/} unpack("(a8)*", $profile_str);
      push(@$profiles, @curr_profiles);
    } elsif ( $line =~ /$detail_b/ ){
      my $rec = $records{$1};
      if( !exists($rec->{created_d}) and (my $date = parse_date($6))) {
        $rec->{created_d} = $date;
      }
      my $asds_str = $7;

      #yeah, it will break in 82 years. whatever
      if( !exists($rec->{expiry_d}) and (my $date = parse_date("20${8}"))){
        $rec->{expiry_d} = $date
      }
      if( !exists($rec->{days_to_expiry}) and (my $days_to = trim $9)) {
        $rec->{days_to_expiry} = trim $9;
      }
      my $roles = $rec->{asds_roles} ||= [];
      for my $role_entry ( unpack("(a92)*", $asds_str) ){
        next unless $role_entry =~ /\w/;
        my %role;
        @role{qw/code description/} = map { trim($_) } unpack("a12a80", $role_entry);
        push(@$roles, \%role);
      }
    } elsif ( $line =~ /$detail_c/ ){
      my $rec = $records{$1};
      my $entitlement_str = $6;
      my $restrictions = $rec->{ip_restrictions} ||= [];
      for my $entitlement_entry ( unpack("(a68)*", $entitlement_str) ){
        next unless $entitlement_entry =~ /\w/;
        my %entitlement;
        @entitlement{qw/type reason role bp_id ip_num/} =
          map { trim($_) } unpack("a25a15a8a16a4", $entitlement_entry);
        push(@$restrictions, \%entitlement);
      }
    } elsif ( $self->_process_footer($line) ) {
      return [ values %records ];
    } else {
      $self->error("Unknown record type '${line}'");
    }
  }
  $self->error("Recieved no FOOTER record. File possibly truncated");
}

__PACKAGE__->meta->make_immutable;

1;

__END__;

=head1 NAME

Finance::Pershing::StandardFile::SPAT - Security Profiles from ASDS and Top
Secret

=head1 SYNOPSIS

=head1 METHODS

=head2 _build_records

=over 4

=item pershing_user_id

=item ibd_num

=item first_name

=item last_name

=item ssn_trailing4

=item created_d

=item last_used_d

=item expiry_d

=item days_to_expiry

=item top_secret_profiles - ArrayRef of C<\%profile>

    code

=item asds_roles - ArrayRef of: C<\%role>

    code
    description

=item restrictions - ArrayRef of: C<\%restrictions>

    type
    reason
    role
    bp_id
    ip_num

=back

=head1 AUTHOR & LICENSE

Please see L<Finance::Pershing::StandardFile> for more information.

=cut
