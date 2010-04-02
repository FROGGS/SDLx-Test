use strict;
use warnings;
use Test::Most;
use SDL;
use SDL::Video;
use SDL::Rect;
use SDL::Surface;

plan tests => 6;

use_ok( 'SDLx::Test' );

my @done = qw/
compare_surfaces
/;
can_ok( 'SDLx::Test', @done );

my $surface1 = SDL::Video::load_BMP('test/data/red_24bpp.bmp');
my $surface2 = SDL::Video::load_BMP('test/data/red_8bpp.bmp');
my ($good, $r, $g, $b, $a) = @{ SDLx::Test::compare_surfaces($surface1, $surface2) };
ok( $r > 90 && $g > 90 && $b > 90, "[compare_surfaces] colors matching: " . sprintf("R=%6.2f%% G=%6.2f%% B=%6.2f%%", $r, $g, $b) );

$surface1 = SDL::Video::load_BMP('test/data/green_24bpp.bmp');
$surface2 = SDL::Video::load_BMP('test/data/green_8bpp.bmp');
($good, $r, $g, $b, $a) = @{ SDLx::Test::compare_surfaces($surface1, $surface2) };
ok( $r > 90 && $g > 90 && $b > 90, "[compare_surfaces] colors matching: " . sprintf("R=%6.2f%% G=%6.2f%% B=%6.2f%%", $r, $g, $b) );

$surface1 = SDL::Video::load_BMP('test/data/blue_24bpp.bmp');
$surface2 = SDL::Video::load_BMP('test/data/blue_8bpp.bmp');
($good, $r, $g, $b, $a) = @{ SDLx::Test::compare_surfaces($surface1, $surface2) };
ok( $r > 90 && $g > 90 && $b > 90, "[compare_surfaces] colors matching: " . sprintf("R=%6.2f%% G=%6.2f%% B=%6.2f%%", $r, $g, $b) );

$surface1 = SDL::Video::load_BMP('test/data/picture_24bpp.bmp');
$surface2 = SDL::Video::load_BMP('test/data/picture_8bpp.bmp');
($good, $r, $g, $b, $a) = @{ SDLx::Test::compare_surfaces($surface1, $surface2) };
ok( $r > 90 && $g > 90 && $b > 90, "[compare_surfaces] colors matching: " . sprintf("R=%6.2f%% G=%6.2f%% B=%6.2f%%", $r, $g, $b) );
