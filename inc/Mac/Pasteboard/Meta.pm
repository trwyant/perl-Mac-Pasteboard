package Mac::Pasteboard::Meta;

use 5.006;

use strict;
use warnings;

use Carp;
use POSIX qw{ uname };

sub new {
    my ( $class ) = @_;
    ref $class and $class = ref $class;
    my $self = {
	distribution => $ENV{MAKING_MODULE_DISTRIBUTION},
    };
    bless $self, $class;
    return $self;
}

sub build_requires {
    my ( $self, @extra ) = @_;
    return +{
	'Test::More'	=> 0.96,	# Because of subtest().
	@extra,
    };
}

sub ccflags {
    my @ccflags;
    my ( $darwin_version ) = split qr{ [.] }smx, ( uname() )[2];
    $darwin_version >= 8
	and push @ccflags, '-DTIGER';
    -f '/usr/include/MacTypes.h'
	and push @ccflags, '-DUSE_MACTYPES';
    if ( my $debug = $ENV{DEVELOPER_DEBUG} ) {
	push @ccflags, '-DDEBUG_PBL';
	$debug =~ m/ \b backtrace \b /smxi
	    and push @ccflags, '-DDEBUG_PBL_BACKTRACE';
    }
    return @ccflags;
}

sub distribution {
    my ( $self ) = @_;
    return $self->{distribution};
}

sub requires {
    my ( $self, @extra ) = @_;
##  if ( ! $self->distribution() ) {
##  }
    return {
	'Carp'		=> 0,
	'Encode'	=> 0,
	'Scalar::Util'	=> 1.01,
	'strict'	=> 0,
	'warnings'	=> 0,
	@extra,
    };
}

sub requires_perl {
    return 5.006;
}

sub want_pbtool {
    my ( undef, $opt, $bldr ) = @_;	# Invocant not used

    print <<"EOD";

<<<< NOTICE >>>>\a\a\a

In the first production release after October 1 2014, the pbtool script
will be installed by default, and the prompt for whether or not to
install it will be removed. If you do not want it installed, run this
script with the -n option. The -y option will remain for compatability.

EOD

    if ( $opt->{n} ) {
	$opt->{y}
	    and die "Please do not assert both -n and -y. It is too confusing.\n";
	print <<'EOD';
Because you have asserted -n, the pbtool script will not be installed.
EOD
	return;

    } elsif ( $opt->{y} ) {
	print <<'EOD';
Because you have asserted -y, the pbtool script will be installed.
EOD
	return 1;

    } else {
	print <<"EOD";

The pbtool script is a front-end for Mac::Pasteboard, for ad-hoc
manipulation of Mac OS X pasteboards.

EOD

	my $rslt = _prompt( $bldr,
	    'Do you want to install pbtool?',
	    'n',
	);

	return $rslt =~ m/ \A y /smxi;
    }

}

sub _prompt {
    my ( $bldr, @args ) = @_;

    ref $bldr
	and $bldr->can( 'prompt' )
	and return $bldr->prompt( @args );

    defined $bldr
	or $bldr = 'main';
    my $code = $bldr->can( 'prompt' )
	or die "Programming error - No prompt routine available";
    return $code->( @args );
}


1;

__END__

=head1 NAME

PPIx::Regexp::Meta - Information needed to build PPIx::Regexp

=head1 SYNOPSIS

 use lib qw{ inc };
 use PPIx::Regexp::Meta;
 my $meta = PPIx::Regexp::Meta->new();
 use YAML;
 print "Required modules:\n", Dump(
     $meta->requires() );

=head1 DETAILS

This module centralizes information needed to build C<PPIx::Regexp>. It
is private to the C<PPIx::Regexp> package, and may be changed or
retracted without notice.

=head1 METHODS

This class supports the following public methods:

=head2 new

 my $meta = PPIx::Meta->new();

This method instantiates the class.

=head2 build_requires

 use YAML;
 print Dump( $meta->build_requires() );

This method computes and returns a reference to a hash describing the
modules required to build the C<PPIx::Regexp> package, suitable for
use in a F<Build.PL> C<build_requires> key, or a F<Makefile.PL>
C<< {META_MERGE}->{build_requires} >> or C<BUILD_REQUIRES> key.

=head2 ccflags

 my @ccflags = $meta->ccflags();
 print "cc flags - @ccflags\n";

This method computes and returns the flags to be passed to the C
compiler.

=head2 distribution

 if ( $meta->distribution() ) {
     print "Making distribution\n";
 } else {
     print "Not making distribution\n";
 }

This method returns the value of the environment variable
C<MAKING_MODULE_DISTRIBUTION> at the time the object was instantiated.

=head2 requires

 use YAML;
 print Dump( $meta->requires() );

This method computes and returns a reference to a hash describing
the modules required to run the C<PPIx::Regexp>
package, suitable for use in a F<Build.PL> C<requires> key, or a
F<Makefile.PL> C<PREREQ_PM> key. Any additional arguments will be
appended to the generated hash. In addition, unless
L<distribution()|/distribution> is true, configuration-specific modules
may be added.

=head2 requires_perl

 print 'This package requires Perl ', $meta->requires_perl(), "\n";

This method returns the version of Perl required by the package.

=head1 ATTRIBUTES

This class has no public attributes.


=head1 ENVIRONMENT

=head2 MAKING_MODULE_DISTRIBUTION

This environment variable should be set to a true value if you are
making a distribution. This ensures that no configuration-specific
information makes it into F<META.yml>.


=head1 SUPPORT

Support is by the author. Please file bug reports at
L<http://rt.cpan.org>, or in electronic mail to the author.

=head1 AUTHOR

Thomas R. Wyant, III F<wyant at cpan dot org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010-2015 by Thomas R. Wyant, III

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl 5.10.0. For more details, see the full text
of the licenses in the directory LICENSES.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

# ex: set textwidth=72 :
