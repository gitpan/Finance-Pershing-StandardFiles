package Finance::Pershing::StandardFile;

use Carp ();
use Moose;
use IO::File;
use DateTime;
use MooseX::Types::Path::Class qw/File/;
use Finance::Pershing::StandardFiles::Utils qw/trim parse_date/;

our $VERSION = '0.001000';

our $header = qr/^BOF      PERSHING (.{18}) DATA OF  (\d\d\/\d\d\/\d{4}) TO REMOTE (.{4}) BEGINS HERE  (\d\d\/\d\d\/\d{4}).(\d\d:\d\d:\d\d)\s+A$/;
our $footer = qr/^EOF      PERSHING (.{18}) DATA OF  (\d\d\/\d\d\/\d{4}) TO REMOTE (.{4}) ENDS HERE. TOTAL DETAIL RECORDS: (\d{10})\s+Z$/;

has filename => (is => 'ro', isa => File, required => 1, coerce => 1);
has record_callback => (is => 'ro', isa => 'CodeRef', predicate => 'has_record_callback');

has _file_handle => (is => 'ro', isa => 'IO::File', lazy_build => 1);
has records => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
has file_type => (is => 'rw', isa => 'Str');
has run_date  => (is => 'rw', isa => 'DateTime');
has data_date => (is => 'rw', isa => 'DateTime');
has remote_id => (is => 'rw', isa => 'Str');
has record_count => (is => 'rw', isa => 'Int');

sub is_refresh {
  Carp::confess("Unimplemented subroutine should be overridden by subclasses");
}
sub is_delta {
  Carp::confess("Unimplemented subroutine should be overridden by subclasses");
}

sub error {
  my ($self, $message) = @_;
  my @segments = ($message);
  if( blessed($self) ){
    if($self->_has_file_handle){
      my $file = $self->filename;
      my $line = $self->_file_handle->input_line_number;
      push(@segments, "File: '${file}'", "Line: ${line}");
    }
  }
  local $Carp::CarpLevel = $Carp::CarpLevel + 1;
  Carp::croak(join("; ", @segments));
}

sub next_line {
  if( defined(my $line = shift->_file_handle->getline) ){
    chomp $line;
    return $line;
  }
  return;
}

sub _build__file_handle {
  my $self = shift;
  my $file = $self->filename;
  Carp::croak("file $file is not readable by effective uid/gid")
      unless -r $file;
  if( my $io =  IO::File->new("<${file}") ){
    return $io;
  } else {
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    Carp::croak("Failed to open $file");
  }
}

#we'll be balye to do this lazyly at some point
sub BUILD {
  my $self = shift;
  defined(my $line = $self->next_line) or $self->error("File is empty.");
  $self->_process_header($line);
}

sub _process_header {
  my $self = shift;
  my $line = shift;
  if( $line =~ /$header/){
    my $data_date = $2;
    my $run_date  = $4;
    my $run_time  = $5;
    $self->file_type( trim $1 );
    $self->remote_id( trim $3 );
    $self->data_date( parse_date($data_date) );
    $self->run_date( parse_date($run_date, $run_time) );
  } else {
    $self->error("Expected Header but got: '$line'");
  }
}

sub _process_footer {
  my $self = shift;
  my $line = shift;
  if( $line =~ /$footer/){
    my $target = $4;
    $self->record_count($target);
    my $record_count = $self->_file_handle->input_line_number - 2;
    $self->error("Record count mismatch expected ${target} but got ${record_count}")
      unless $target == $record_count;
    while(defined($line = $self->next_line)){
      $self->error("File has data '${line}' after footer")
        if trim($line) ne ''; #ignore empty lines at the end of the file
    }
    $self->_clear_file_handle; #close the filehandle
    return 1;
  }
  return;
}

__PACKAGE__->meta->make_immutable;

1;

__END__;


=head1 NAME

Finance::Pershing::StandardFile - Base Standard File class

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 filename

Required read-only string that represents the path to the file you wish to read.

=head2 record_callback

=over 4

=item B<has_record_callback> - predicate

=back

Optional read-only code reference that will be called after every logical record is
read. Will be passed two arguments, the current instance of the file
parser (so you can access file properties) and a hashref representing the record
as described above.

You can use this to reduce the memory foot print of your program by keeping only
the current account record in memory. Example:

    my $callback = sub{
        my($instance, $rec) = @_;
        #process data here;
        %$rec = ();
    };
    my $file = Finance::Pershing::StandardFile:XYZ
      ->load( filename => $file, record_callback => $callback);

    #by the time this returns a callback will have been executed for each account
    my $recs = eval { $balance->records };
    defined($recs) && !$@ ? commit() : rollback() and die($@);

The downside of this method is that if the file is currupted, you will have
to catch the exception and rollback changes. Partially transmitted files are NOT that
uncommon! Make sure you have a rollback mechanism.

=head2 records

=over 4

=item B<clear_records> - clearer

=item B<has_records> - predicate

=item B<_build_records> - builder

=back

An array reference containing all of the positions contained in the file.
This read-only attribute builds lazyly the first time it is requested by
actually going through the while file and reading it. If any errors are
encountered while reading the file or the file appears to be truncated an
exception will be thrown.

=head2 File Properties

The following attributes are automatically filled the header is read:

=over 4

=item B<file_type> - String

=item B<file_type> - String
=item B<run_date> - DateTime
=item B<data_date> - DateTime
=item B<remote_id> - String

=back

=item B<record_count> - Integer, number of records in file not including
 header, and trailer records.

=back

=head2 _file_handle

=over 4

=item B<_clear_file_handle> - clearer

=item B<_has_file_handle> - predicate

=item B<_build__file_handle> - builder

=back

This is the IO::File object that holds our filehandle. DO NOT TOUCH THIS. If
you mess with this I can almost guarantee you will break something.

=head1 AUTHOR & LICENSE

Please see L<Finance::Pershing::StandardFiles> for more information.

=cut

