package Dist::Zilla::Plugin::TwitterBootstrap;

use strict;
use warnings;
use v5.10;
use Moose;
use WebService::TwitterBootstrap::Download::Custom;
use Template;
use Template::Provider::FromDATA;

# ABSTRACT: Include a customized Twitter Bootstrap in your distribution
# VERSION

=head1 CLASS METHODS

=head2 Dist::Zilla::Plugin::TwitterBootstrap->default_customization

Prints to standard out the default customization as found on the Twitter
Bootstrap website.  You can use this by appending it to your C<dist.ini>.

 % perl -MDist::Zilla::Plugin::TwitterBootstrap \
   -E 'Dist::Zilla::Plugin::TwitterBootstrap->default_customization' \
   > dist.ini

=cut

sub default_customization
{
  my $tt2 = Template->new(
    LOAD_TEMPLATES => [ Template::Provider::FromDATA->new( { CLASSES => __PACKAGE__ }) ],
  );
  $tt2->process('dist_ini', {
    dl => WebService::TwitterBootstrap::Download::Custom->new->fetch_defaults,
  });
  1;
}

__PACKAGE__->meta->make_immutable;

1;

__DATA__

__dist_ini__
[TwitterBootstrap]

[% FOR js IN dl.js -%]
js = [% js %]
[% END -%]

[% FOR css IN dl.css -%]
css = [% css %]
[% END -%]

[% FOR img IN dl.img -%]
img = [% img %]
[% END -%]

;; uncomment and change to alter from default values
[% FOR pair IN dl.vars -%]
; [% pair.key %] = [% pair.value %]
[% END -%]