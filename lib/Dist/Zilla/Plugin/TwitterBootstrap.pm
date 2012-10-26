package Dist::Zilla::Plugin::TwitterBootstrap;

use strict;
use warnings;
use v5.10;
use Moose;
use WebService::TwitterBootstrap::Download::Custom;
use Template;
use Template::Provider::FromDATA;
use Moose::Util::TypeConstraints qw( enum );
use List::MoreUtils qw( uniq any );
use Text::Glob qw( match_glob );
use Path::Class qw( file );

with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::Plugin';

# ABSTRACT: Include a customized Twitter Bootstrap in your distribution
# VERSION

=head1 SYNOPSIS

 [TwitterBootstrap]
 js_include  = *
 css_include = *
 img_include = *

=head1 DESCRIPTION

Plugin which downloads a custom Twitter Bootstrap using 
L<WebService::TwitterBootstrap::Download::Custom> from the Twitter 
Bootstrap website and includes it in your distribution.

=head1 ATTRIBUTES

=head2 js_include

Which jQuery plugins to include.  This attribute is considered before
C<js_exclude>.  You can use C<*> to include all available plugins.

=cut

has js_include => (
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] },  
);

=head2 js_exclude

Which jQuery plugins to exclude.  This attribute will remove any plugin
that would otherwise have been included with juts the C<js_include> attribute.
For example, to include all plugins, EXCEPT for Transitions:

 [TwitterBootstrap]
 js_include = *
 js_exclude = bootstrap-transition.js

=cut

has js_exclude => (
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] },
);

=head2 css_include

Which CSS components to include.  This attribute is considered before
C<css_exclude>.  You can use C<*> to include all available components.

=cut

has css_include => (
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] },  
);

=head2 css_exclude

Which CSS components to exclude.  This attribute will remove any components
that would otherwise have been included with just the C<css_include> attribute.

=cut

has css_exclude => (
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] },  
);

=head2 img_include

Which images to include.  This attribute is considered before C<img_exclude>.
You can use C<*> to include all available images.

=cut

has img_include => (
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] },  
);

=head2 img_exclude

Which images to exclude.  This attribute will remove any images that would
otherwise have been included with just the C<img_include> attribute.

=cut

has img_exclude => (
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] },  
);

=head2 vars

Which variables to override.  For example to set @linkColor to red:

 [TwitterBootstrap]
 vars = @linkColor = #f00

=cut

has vars => (
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] }, 
);

=head2 dir

Which directory to put your custom Twitter Bootstrap into.  
Defaults to public under the same location of your main 
module, so if your module is Foo::Bar (lib/Foo/Bar.pm), 
then the default dir will be lib/Foo/Bar/public.

=cut

has dir => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  default => sub {
    my $self = shift;
    my $main_module = file( $self->zilla->main_module->name );
    (my $base = $main_module->basename) =~ s/\.pm//;
    my $dir = $main_module->dir->subdir($base, 'public')->stringify;
    $self->log("using default dir $dir");
    $dir;
  },
);

=head2 location

Where to put your custom Twitter Bootstrap.  Choices are:

=over 4

=item build

This puts your custom Twitter Bootstrap in the directory 
where the dist is currently being built, where it will be 
incorporated into the dist.

=item root

This puts your custom Twitter Bootstrap in the root directory 
(The same directory that contains F<dist.ini>).  It will also 
be included in the built distribution.

=back

=cut

has location => (
  is      => 'ro',
  isa     => enum([qw(build root)]),
  default => 'build',
);

=head2 cache

Whether and where to cache custom bootstraps.  This value is
passed directly into the same attribute of 
L<WebService::TwitterBootstrap::Download::Custom>, so see that
modules documentation for details, but briefly here are the 
values you can specify:

=over 4

=item * 0 (zero)

Turn off caching

=item * 1 (one)

Turn on caching, using the default caching location.

=item * directory path

Use the given path as the cache directory.

=back

=cut

has cache => (
  is       => 'ro',
  isa      => 'Str',
  default  => '0',
);

=head1 INSTANCE METHODS

=head2 $plugin-E<gt>gather_files

This method downloads the appropriate files from the Internet (or
retrieves them from the cache) and places them in the location 
specified by the configuration.

=cut

sub _zip
{
  my($self) = @_;
  my $dl = WebService::TwitterBootstrap::Download::Custom
    ->new( cache => $self->cache )->fetch_defaults;
  
  @{ $dl->js } = grep { my $item = $_; ! any { $item eq $_ } @{ $self->js_exclude} } 
                 map { match_glob($_, @{ $dl->js } ) } @{ $self->js_include };
  
  @{ $dl->css } = grep { my $item = $_; ! any { $item eq $_ } @{ $self->css_exclude} } 
                 map { match_glob($_, @{ $dl->css } ) } @{ $self->css_include };

  @{ $dl->img } = grep { my $item = $_; ! any { $item eq $_ } @{ $self->img_exclude} } 
                 map { match_glob($_, @{ $dl->img } ) } @{ $self->img_include };
  
  %{ $dl->vars }   = ();
  
  foreach my $var (@{ $self->vars })
  {
    if($var =~ /^(.*?)=(.*)$/)
    {
      my $name = $1;
      my $value = $2;
      for($name,$value) {
        s/^\s+//;
        s/\s+$//;
      }
      $dl->vars->{$name} = $value;
    }
  }
  
  $dl->download;
}

sub gather_files
{
  my($self, $arg) = @_;
  
  my $zip = $self->_zip;
  
  foreach my $member_name (@{ $zip->member_names })
  {
    $self->log("adding " . $member_name . " to " . $self->dir );
    if($self->location eq 'build')
    {
      $self->add_file(
        Dist::Zilla::File::InMemory->new(
          content => $zip->member_content($member_name),
          name    => Path::Class::Dir->new( $self->dir )->file( $member_name )->stringify,
        ),
      );
    }
    else
    {
      my $file = $self->zilla->root->file( $self->dir, $member_name );
      $file->parent->mkpath(0, 0755);
      $file->spew( $zip->member_content($member_name) );
    }
  }
  
  return;
}

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
  state $tt2;
  unless(defined $tt2)
  {
    $tt2 = Template->new(
      LOAD_TEMPLATES => [ Template::Provider::FromDATA->new( { CLASSES => __PACKAGE__ }) ],
    );
  }
  $tt2->process('dist_ini', {
    dl => WebService::TwitterBootstrap::Download::Custom->new->fetch_defaults,
  });
  1;
}

=head2 Dist::Zilla::Plugin::TwitterBootstrap->mvp_multivalue_args

Returns list of attributes that can be specified multiple times.  Can
also be called as an instance method.

=cut

my @mvp = map { ( $_.'_include', $_.'_exclude' ) } qw( js css img );
push @mvp, 'vars';
sub mvp_multivalue_args { @mvp }

__PACKAGE__->meta->make_immutable;

1;

=head1 CAVEATS

If you bundle Twitter Bootstrap into your distribution, you should update the copyright
section to include a notice that bundled copy of Twitter Bootstrap is copyright
Twitter and is licensed under the Apache 2.0 License.

This module does not bundle Twitter Bootstrap itself, but it can be used to include a
bundled copy of Twitter Bootstrap into your Perl distribution.

=head1 SEE ALSO

L<WebService::TwitterBootstrap::Download::Custom>

=cut

__DATA__

__dist_ini__
[TwitterBootstrap]

[% FOR js IN dl.js -%]
js_include = [% js %]
[% END -%]

[% FOR css IN dl.css -%]
css_include = [% css %]
[% END -%]

[% FOR img IN dl.img -%]
img_include = [% img %]
[% END -%]

;; uncomment and change to alter from default values
[% FOR pair IN dl.vars -%]
; var = [% pair.key %] = [% pair.value %]
[% END -%]
