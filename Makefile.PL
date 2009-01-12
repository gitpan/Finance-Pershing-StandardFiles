#! /usr/bin/perl -w

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'Finance-Pershing-StandardFiles';
abstract "Tools to interface with Pershing's standard files";
all_from 'lib/Finance/Pershing/StandardFiles.pm';

# Specific dependencies
requires 'Moose' => '0.28';
requires 'DateTime';
requires 'IO::File';
requires 'Path::Class';
requires 'Class::MOP';
requires 'Sub::Exporter';
requires 'DBIx::Class' => '0.08000';

WriteAll;


