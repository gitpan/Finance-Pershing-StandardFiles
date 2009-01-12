package Finance::Pershing::StandardFiles::Store::ResultSet;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Carp;
use Scalar::Util 'blessed';

sub coerce {
  my ($self, $data) = @_;

  my $class = blessed($self) || $self;
  my $coerced = { %$data };
  my %coerce_map = do { no strict 'refs'; %{"${class}::coerce_map"} };
  while (my($orig, $target) = each %coerce_map){
    next unless exists $coerced->{$orig};
    if(ref($target) eq 'ARRAY' ){
      my $val = delete $coerced->{$orig};
      $coerced->{$_} = $val for @$target;
    } elsif(!ref $target){
      $coerced->{$target} = delete $coerced->{$orig};
    }
  }
  return $coerced;
}

sub coerce_and_create {
  my $self = shift;
  my $data = shift;
  $self->create($self->coerce($data), @_);
}

sub coerce_and_update_or_create{
  my $self = shift;
  my $data = shift;
  $self->update_or_create($self->coerce($data), @_);
}

1
