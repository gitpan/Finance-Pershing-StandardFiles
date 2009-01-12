package Finance::Pershing::StandardFiles::Utils;

use strict;
use warnings;
use IO::File;
use Class::MOP;
use DateTime;
use Carp ();

use Sub::Exporter -setup =>
  { exports => [ qw(
                     trim
                     parse_date
                     read_file
                     file_info_from_header
                     get_file_info
                  )
               ],
  };

our $VERSION = '0.001000';

our %class_code_to_name =
  (
   SPAT => 'SECURITY PROFILES',
   IMSF => 'USERID TRACKING',
   ACCT  => 'CUSTOMER ACCT INFO',
  );

our %type_name_to_class = ( map { $class_code_to_name{$_} => $_ }
                           keys %class_code_to_name );

sub trim($) {
  my $x = shift;
  $x =~ s/^\s+//;
  $x =~ s/\s+$//;
  return $x;
}

sub parse_date($;$) {
  my $date = shift;
  Carp::croak("If passed, time must be defined") if (@_ && !defined($_[0]));
  $date = trim $date;

  my %args;
  if( length($date) == 8 && 0+$date != 0 ){
    @args{qw/year month day/} = unpack("a4a2a2",$date);
  } elsif( length($date) == 10 ){ #guess mm/dd/yyyy
    $date =~ s/\D//g; #get rid of separators
    @args{qw/month day year/} = unpack("a2a2a4",$date);
  }

  return unless exists $args{year};
  if (@_ ) {
    my $time = shift;
    $time =~ s/\D//g; #get rid of separators, always hh:mm:ss?
    if(length($time) == 6) {
      @args{qw/hour minute second/} = unpack("a2a2a2",$time);
    } elsif(length($time) == 4) {
      @args{qw/hour minute/} = unpack("a2a2",$time);
    }
  }
  return DateTime->new(%args);
}

sub file_info_from_header{
  my $line = shift;
  my $type = trim(substr($line,18,18));
  my $data_date = parse_date(substr($line,46,10));
  my $remote_id = substr($line,67,4);
  my $run_date = parse_date(substr($line,85,10), substr($line,96,8));

  my $file_class;
  if (exists $type_name_to_class{$type}) {
    $file_class = $type_name_to_class{$type};
  } else {
    Carp::croak "File type '${type}' not supported.",
  }

  return +{
           file_type  => $type,
           file_class => $file_class,
           run_date => $run_date,
           data_date => $run_date,
           remote_id => $remote_id,
          };
}

sub get_file_info {
  my $file = shift;
  if(my $io = IO::File->new("<${file}")){
    defined(my $line = $io->getline) or Carp::croak("File '${file}' is empty.");
    undef $io;
    return file_info_from_header($line);
  } else {
    Carp::croak("Failed to open '${file}'");
  }
}

sub read_file($@) {
  my $file = shift;
  my $info = get_file_info($file);
  my $class = join('::', 'Finance::Pershing::StandardFile', $info->{file_class});
  Class::MOP::load_class($class);
  return $class->new(filename => $file, @_);
}

1;

__END__;

=head1 NAME

Finance::Pershing::StandardFiles::Utils - Utilities for interacting with 
Pershing Standard Files

=head1 SYNOPSIS

    use Finance::Pershing::StandardFiles::Utils qw/parse_date trim read_file/;

    #eliminate leading and trailing whitespace;
    my $trimmed = trim "    XYZ    "; # $trimmed is now "XYZ"

    #inflate a DST date into a datetime object
    my $dt = parse_date "20081231";
    my $dt = parse_date "20081231", "235959";

    #make reading files easier
    read_file $filename;
    read_file($filename, record_callback => sub{ ... });

=head1 EXPORTABLE SUBROUTINES

=head2 trim $string

Simple trim function to delete leading and trailing whitespace from a string.

=head2 parse_date $date, $time

Inflate a date in YYYYMMDD and time in HHMMSS format to a DateTime object. The
time argument is optional.

=head2 read_file $filename, @parser_args

Will determine the file type based on the header record and instantiate and
return the correct Finance::Pershing::StandardFile::* object for the filename
provided.

=head2 file_info_from_header $header_record

Will return a hashref containing the following keys

=over 4

=item B<remote_id> 

=item B<run_date> - L<DateTime> object of the file's run date and time

=item B<data_date> - L<DateTime> object of the file's data date

=item B<file_class> - The type of file contained. The value matches the class
name of the apropriate parser class. (ACCT, SPAT, IMSF)

=item B<file_type> - The natural-language code used internally by Pershing

=back

=head2 get_file_info $filename

Attempt to open the file, extract the header record and return the results of
C<file_info_from_header>.

=head1 AUTHOR & LICENSE

Please see L<Finance::Pershing::StandardFile> for more information.

=cut

