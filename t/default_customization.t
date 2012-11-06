use strict;
use warnings;
use File::HomeDir::Test;
use Test::More tests => 3;
use Dist::Zilla::Plugin::TwitterBootstrap;
use IO::Capture::Stdout;
use Config::INI::Reader;

eval q{
  *orig = \&Mojo::UserAgent::get;
  no warnings 'redefine';
  sub Mojo::UserAgent::get {
    return bless {}, 'FakeTX';
  }
};
die $@ if $@;

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

package FakeTX;

my $res;

sub success
{
  unless(defined $res)
  {
    $res = Mojo::Message::Response->new;
    local $/;
    $res->parse(<DATA>);
  }
  return $res;
}

__DATA__
HTTP/1.1 200 OK
Connection: keep-alive
Cache-Control: max-age=86400
Last-Modified: Wed, 05 Sep 2012 03:46:48 GMT
Accept-Ranges: bytes
Date: Fri, 19 Oct 2012 21:37:31 GMT
Content-Length: 26685
Content-Type: text/html
Server: nginx
Expires: Sat, 20 Oct 2012 21:37:31 GMT

<!DOCTYPE html>
<html lang="en">
  <head>
    <title>whatever</title>
  </head>
  <body>
    <section id="variables"></section>
  </body>
</html>
