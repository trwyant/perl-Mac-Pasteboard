use 5.006000;

use strict;
use warnings;

$^O eq 'darwin'
    or die "OS unsupported\n";

use lib qw{ inc };

use Config;
use ExtUtils::MakeMaker;
use Getopt::Std;
use Mac::Pasteboard::Meta;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my %opt;
getopts ('ny', \%opt) or die <<eod;
The only legal options are
  -n = answer all questions 'no'.
  -y = answer all questions 'yes'.
You may not assert both of these at once - it is too confusing.
eod

my @exe_files;
my @clean_files;

if ($opt{n}) {
    print <<eod;
Because you have asserted -n, the pbtool script will not be installed.
eod
} elsif ($opt{y}) {
    print <<eod;
Because you have asserted -y, the pbtool script will be installed.
eod
    push @exe_files, 'pbtool';
} else {
    print <<eod;

The pbtool script is a front-end for Mac::Pasteboard, for ad-hoc
manipulation of Mac OS X pasteboards.

eod
    prompt ("Do you want to install pbtool?", 'n') =~ m/^y/i
	and push @exe_files, 'pbtool';
}

if ($^O eq 'MSWin32') {
    @exe_files = map {"bin/$_"} @exe_files;
    foreach (@exe_files) {`pl2bat $_`}
    @clean_files = @exe_files = grep {-e $_} map {"$_.bat"} @exe_files;
} elsif ($^O eq 'VMS') {
    foreach my $fni (map {"[.bin]$_"} @exe_files) {
	my $fno = "$fni.com";
	local $/ = undef;
	open (my $fhi, '<', $fni)
	    or die "Error - Unable to open $fni: $!\n";
	open (my $fho, '>', $fno)
	    or die "Error - Unable to open $fno: $!\n";
	print $fho "$Config{startperl}\n";
	print $fho scalar <$fhi>;
	close $fhi;
	close $fho;
    }
    @clean_files = @exe_files = map {"[.bin]$_.com"} @exe_files;
} else {
    @exe_files = map {"bin/$_"} @exe_files;
}

push @clean_files, 'pbl';	# Just in case we built it.

(my $mmv = ExtUtils::MakeMaker->VERSION) =~ s/_//g;

my $meta = Mac::Pasteboard::Meta->new();

my @ccflags = $meta->ccflags();

my %attr = (
    NAME              => 'Mac::Pasteboard',
    VERSION_FROM      => 'lib/Mac/Pasteboard.pm', # finds $VERSION
    PREREQ_PM         => $meta->requires(),
    ABSTRACT_FROM  => 'lib/Mac/Pasteboard.pm', # retrieve abstract from module
    AUTHOR         => 'Tom Wyant (wyant at cpan dot org)',
    LIBS              => [''], # e.g., '-lm'
    LDDLFLAGS	=> $Config{lddlflags} . ' -framework ApplicationServices',
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
    OBJECT            => '$(O_FILES)', # link all the C files too
    PL_FILES	=> {},	# Prevent old MakeMaker from running Build.PL
    EXE_FILES	=> \@exe_files,
    clean	=> {FILES => join ' ', @clean_files},	# Clean up executables.
    (@ccflags ? (CCFLAGS => join ' ', @ccflags) : ()),
);

$mmv >= 6.31 and $attr{LICENSE} = 'perl';

$mmv >= 6.4501 and $attr{META_ADD} = {
    no_index => {
	directory => [ qw{ inc t xt } ],
    },
};

$mmv >= 6.4501 and $attr{META_MERGE} = {
    resources => {
	bugtracker => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Mac-Pasteboard',
	license => 'http://dev.perl.org/licenses/',
    },
};

$mmv >= 6.4701 and $attr{MIN_PERL_VERSION} = $meta->requires_perl();

$mmv >= 6.5501
    and $attr{BUILD_REQUIRES} = $meta->build_requires()
    or $mmv >= 6.4501
    and $attr{META_MERGE}{build_requires} = $meta->build_requires();

WriteMakefile(%attr);

=begin comment

sub MY::postamble {
    <<'eod';

pbl : pbl.c
	$(CC) -o pbl -DTEST $(PBL_FLAGS) pbl.c -framework ApplicationServices
eod
}

=end comment

=cut
