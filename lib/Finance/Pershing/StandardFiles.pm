package Finance::Pershing::StandardFiles;

use strict;
use warnings;

our $VERSION = "0.002000";

1;

__END__;

=head1 NAME

Finance::Pershing::StandardFiles - Tools for Interfacing With Pershing Standard Files

=head1 DESCRIPTION

C<Finance::Pershing::StandardFiles> is a set of tools designed for interacting
with Pershing's Standard File service. The Standard File service allows
correspondents to recieve certain data selections from Pershing directly for
personal use. It is the goal of this project to eventually have a parser for
every file type Pershing offers as well as a selection of utilities helpful in
dealing with these files.

=head1 COMPONENTS

This package is composed of two major and one minor component. The major
components are L<Finance::Pershing::StandardFiles::Store> and the
L<Finance::Pershing::StandardFile> modules, which you will primarily interact
with through  L<Finance::DST::FAN::Mail::Utils>. In the future there may be a
component to aid in decrypting and managing file-system of the recieved files.
Until that is ready, bridging the parsers and the storage layer is left as an
 (admitedly easy) exercise to the reader.

=head2 L<Utils|Finance::Pershing::StandardFiles::Utils>

The recommended way to read incoming files is through the C<read_file>
function provided by this library.

=head2 L<File parsers|Finance::Pershing::StandardFile>

The classes read and parse the contents of the files, providing file-level data
as object attributes, while record-level data is held as a list of records.
All file parsers should implement predicates indicating whether data is a
complete refresh or a delta. Currently the following file types are supported:

=over 4

=item L<Base File Parser Class|Finance::Pershing::StandardFile> - Implements
the basic methods shared by all file parsers and reads header and footer
records.

=item L<ID Management|Finance::Pershing::StandardFile::IMSF> -
Parser for the IMSF file used to track NetExchange IDs.

=item L<Security Profiles|Finance::Pershing::StandardFile::SPAT> -
Parser for the SPAT file used to track Top Secret Profiles and ASDS roles and
permissions

=back

=head1 AUTHOR

Guillermo Roditi (groditi) E<lt>groditi@cpan.orgE<gt>

=head1 COMMERCIAL SUPPORT AND FEATURE / ENHANCEMENT REQUESTS

This software is developed as free software and is distributed free of charge,
but if you or your organization would like to contribute to the further
development, maintenance and QA of this project we ask that you sponsor the
development of one ore more of these areas. Please contact groditi@cantella.com
for more information.

Commercial support and sponsored development are available for this project
through Cantella & Co., Inc. If you or your organization would like to use this
package and need help customising it or new functionality added please
contact groditi@cantella.com or jlanstein@cantella.com for rates.

=head1 BUGS AND CONTRIBUTIONS

Google Code Project Page - L<http://code.google.com/p/finance-pershing-standardfile/>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Cantella & Co., Inc. ( http://www.cantella.com/ )

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself

=cut

