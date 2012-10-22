use strict;
use warnings;
use Test::More tests => 3;
use Dist::Zilla::Plugin::TwitterBootstrap;
use IO::Capture::Stdout;
use Config::INI::Reader;

my $capture = IO::Capture::Stdout->new;

$capture->start;
my $ret = eval { Dist::Zilla::Plugin::TwitterBootstrap->default_customization };
diag $@ if $@;
$capture->stop;

is $ret, 1, 'ret = 1';

my $ini = join '', $capture->read;
my $cfg = eval { Config::INI::Reader->read_string($ini) };
is $@, '', 'config did not crash Config::INI::Reader->read_string';
isa_ok $cfg, 'HASH', 'cfg isa HASH';