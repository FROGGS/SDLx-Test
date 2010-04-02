#! perl -w

use strict;
use warnings;
use Carp;

use lib 'inc';
use Alien::SDL;

### we need the platform-specific module
my %platforms =(
	MSWin32      => 'Windows',
	MacOS        => 'MacOS',
	darwin       => 'Darwin',
	cygwin       => 'Unix',
	freebsd      => 'Unix',
	gnukfreebsd  => 'Unix',
	linux        => 'Unix',
	netbsd       => 'Unix',
	openbsd      => 'Unix',
	solaris      => 'Unix',
);
my $package = 'My::Builder::' . ($platforms{$^O} || 'Unix');
print "Gonna use '$package' class ...\n";
eval "require $package" or croak "Require '$package' failed: $@\n";

### subsystems to build
#    <subsystem>
#        <file> = hash of the following 2 values:
#	     <from> = location of source file
#            <to>   = location of build file to get name right
#        <libraries> = list reqiured libraries, names the same as keys to hash %libraries
my %subsystems =
(
	Video => {
		file      => {
			from  => 'src/Test.xs',
			to    => 'lib/SDLx/Test.xs',
		},
		libraries => [qw( SDL )],
	},
);

### external libraries
#    <library name> = symbolic library name
#        <define> = value that will be used as -D<value> option when compiling XS code
#        <header> = header related to the library that will be used for avalability detection,
#                   could be a sigle value or an array of values                  
#        <lib>    = value that will be used as -l<value> option when linking XS code
my %libraries = (
	SDL         => {
		define => 'HAVE_SDL', 
		header => 'SDL.h',
		lib    => 'SDL',
	},
);

### mangle the compilable files into a format Module::Build can understand
my %xs = map { $subsystems{$_}{file}{from} => $subsystems{$_}{file}{to} } keys %subsystems;

### standard Module::Build stuff
my $build = $package->new(
	module_name          => 'SDLx::Test',
	dist_name            => 'SDLx::Test', 
	license		     => 'lgpl',
	dist_version_from    => 'lib/SDLx/Test.pm',
	configure_requires	      =>
	{
		'YAML'	=> '0.68',
		'ExtUtils::CBuilder' => '0.260301',
		'Alien::SDL' => '0.9.1',
		'File::Find' => '2.07'
	},
	build_requires =>
	{
		'Test::Simple' => '0.88',
		'IO::CaptureOutput' => '0',
		'Test::Most' => '0.21',
		'Alien::SDL' => '0.9.1',
	},
	build_recommends     =>
	{
		'Pod::ToDemo'  => '0.20'		
	},
	c_source	     => 'src',
	xs_files             => \%xs,
	meta_add	     =>	     
	{
	},
	#create_readme => 1, ### make sense only if there is some POD doc in the file specified by dist_version_from
	meta_merge => {
		resources  => {
			bugtracker => 'http://sdlperl.ath.cx/projects/SDLPerl/report/1',
			repository => 'http://github.com/kthakore/SDL_perl'
		}
	},
	dist_abstract => 'Hardcore test functions for SDL',
	dist_author	     => 'Tobias Leich <froggs@cpan.org>',
);

### Alien::SDL quick check
warn "###WARNING### Alien::SDL seems to be broken" unless Alien::SDL->config('prefix');

### see which subsystems can be built -- do we have headers for them?
print "Gonna autodetect available libraries ...\n";
my $build_systems = $build->find_subsystems(\%subsystems, \%libraries);
my $lib_translate = $build->translate_table(\%subsystems, \%libraries);

### save info about available subsystems for future SDL::ConfigData
print "Gonna write config_data ...\n";
$build->config_data('SDL_cfg', $build_systems);
$build->config_data('SDL_lib_translate', $lib_translate);
$build->config_data('subsystems', \%subsystems);
$build->config_data('libraries', \%libraries);

### something that was originally special to MacOS/Darwin
# somebody MacOS/Darwin friendly should review whether it is still necessary
$build->special_build_settings();

### get some info into M::B notes
print "Gonna save some info to 'notes' ...\n";
$build->notes('subsystems', \%subsystems);
$build->notes('libraries', \%libraries);
$build->notes('build_systems', $build_systems);
$build->notes('sdl_cflags', Alien::SDL->config('cflags'));
$build->notes('sdl_libs', Alien::SDL->config('libs'));
$build->set_file_flags();   # creates notes('file_flags')

# now we're ready to go!
$build->create_build_script();
