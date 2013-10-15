# Dist::Zilla::Plugin::TwitterBootstrap

Include a customized Twitter Bootstrap in your distribution

# SYNOPSIS

    [TwitterBootstrap]
    js_include  = *
    css_include = *
    img_include = *

# DESCRIPTION

Plugin which downloads a custom Twitter Bootstrap using 
[WebService::TwitterBootstrap::Download::Custom](http://search.cpan.org/perldoc?WebService::TwitterBootstrap::Download::Custom) from the Twitter 
Bootstrap website and includes it in your distribution.

# ATTRIBUTES

## js\_include

Which jQuery plugins to include.  This attribute is considered before
`js_exclude`.  You can use `*` to include all available plugins.

## js\_exclude

Which jQuery plugins to exclude.  This attribute will remove any plugin
that would otherwise have been included with juts the `js_include` attribute.
For example, to include all plugins, EXCEPT for Transitions:

    [TwitterBootstrap]
    js_include = *
    js_exclude = bootstrap-transition.js

## css\_include

Which CSS components to include.  This attribute is considered before
`css_exclude`.  You can use `*` to include all available components.

## css\_exclude

Which CSS components to exclude.  This attribute will remove any components
that would otherwise have been included with just the `css_include` attribute.

## img\_include

Which images to include.  This attribute is considered before `img_exclude`.
You can use `*` to include all available images.

## img\_exclude

Which images to exclude.  This attribute will remove any images that would
otherwise have been included with just the `img_include` attribute.

## vars

Which variables to override.  For example to set @linkColor to red:

    [TwitterBootstrap]
    vars = @linkColor = #f00

## dir

Which directory to put your custom Twitter Bootstrap into.  
Defaults to public under the same location of your main 
module, so if your module is Foo::Bar (lib/Foo/Bar.pm), 
then the default dir will be lib/Foo/Bar/public.

## location

Where to put your custom Twitter Bootstrap.  Choices are:

- build

    This puts your custom Twitter Bootstrap in the directory 
    where the dist is currently being built, where it will be 
    incorporated into the dist.

- root

    This puts your custom Twitter Bootstrap in the root directory 
    (The same directory that contains `dist.ini`).  It will also 
    be included in the built distribution.

## cache

Whether and where to cache custom bootstraps.  This value is
passed directly into the same attribute of 
[WebService::TwitterBootstrap::Download::Custom](http://search.cpan.org/perldoc?WebService::TwitterBootstrap::Download::Custom), so see that
modules documentation for details, but briefly here are the 
values you can specify:

- 0 (zero)

    Turn off caching

- 1 (one)

    Turn on caching, using the default caching location.

- directory path

    Use the given path as the cache directory.

# INSTANCE METHODS

## $plugin->gather\_files

This method downloads the appropriate files from the Internet (or
retrieves them from the cache) and places them in the location 
specified by the configuration.

# CLASS METHODS

## Dist::Zilla::Plugin::TwitterBootstrap->default\_customization

Prints to standard out the default customization as found on the Twitter
Bootstrap website.  You can use this by appending it to your `dist.ini`.

    % perl -MDist::Zilla::Plugin::TwitterBootstrap \
      -E 'Dist::Zilla::Plugin::TwitterBootstrap->default_customization' \
      > dist.ini

## Dist::Zilla::Plugin::TwitterBootstrap->mvp\_multivalue\_args

Returns list of attributes that can be specified multiple times.  Can
also be called as an instance method.

# CAVEATS

If you bundle Twitter Bootstrap into your distribution, you should update the copyright
section to include a notice that bundled copy of Twitter Bootstrap is copyright
Twitter and is licensed under the Apache 2.0 License.

This module does not bundle Twitter Bootstrap itself, but it can be used to include a
bundled copy of Twitter Bootstrap into your Perl distribution.

# SEE ALSO

[WebService::TwitterBootstrap::Download::Custom](http://search.cpan.org/perldoc?WebService::TwitterBootstrap::Download::Custom)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
