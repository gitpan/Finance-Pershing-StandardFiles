#! /usr/bin/perl -w

use strict;
use warnings;
use FindBin '$Bin';
use lib $Bin.'/../lib';

use Finance::Pershing::StandardFiles::Store;

my ($dsn, $user, $password) = @ARGV;

my $schema = Finance::Pershing::StandardFiles::Store->connect(
  $dsn, $user, $password,
  { quote_char => '`', name_sep => '.' },
);

$schema->deploy({
  quote_table_names  => 1,
  quote_field_names  => 1,
});
