package SDLx::Test;
use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
require DynaLoader;
our @ISA = qw(Exporter DynaLoader);

use SDL::Internal::Loader;
internal_load_dlls(__PACKAGE__);

bootstrap SDLx::Test;

our $VERSION = '0';
$VERSION = eval $VERSION;

#print "$VERSION" if (defined($ARGV[0]));# && ($ARGV[0] eq '--SDLx::Test'));

1;
