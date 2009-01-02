use 5.006000;

use strict;
use warnings;

$^O eq 'darwin'
    or die "OS unsupported\n";

use Config;
use ExtUtils::MakeMaker;
use Getopt::Std;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my @ld;
{
    no warnings qw{uninitialized};
    my $osvers = +sprintf '%d.%03d', split '\.', `sw_vers -productVersion`;
    use warnings qw{uninitialized};
    $? and die "OS unsupported -- sw_vers failed with exit code $?\n";
    $osvers >= 10.003
	or die "OS unsupported -- we need at least Mac OS X 10.3 (Panther)\n";
##    $osvers >= 10.003
##	and push @ld, '-DPANTHER';
    $osvers >= 10.004
	and push @ld, '-DTIGER';
##    $osvers >= 10.005
##	and push @ld, '-DLEOPARD';
}

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
my @ccflags;
if ($ENV{DEVELOPER_DEBUG}) {
    push @ccflags, '-DDEBUG_PBL';
    local $_ = $ENV{DEVELOPER_DEBUG};
    m/\bbacktrace\b/i and push @ccflags, '-DDEBUG_PBL_BACKTRACE';
}

my %attr = (
    NAME              => 'Mac::Pasteboard',
    VERSION_FROM      => 'lib/Mac/Pasteboard.pm', # finds $VERSION
    PREREQ_PM         => {
###	perl	=> 5.006,	# Module::Build 3.0 does not like this.
	'Scalar::Util'	=> 1.01,	# Not in Perl 5.6. Want dualvar.
    }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM  => 'lib/Mac/Pasteboard.pm', # retrieve abstract from module
    AUTHOR         => 'Tom Wyant (wyant at cpan dot org)',
    LIBS              => [''], # e.g., '-lm'
    LDDLFLAGS	=> $Config{lddlflags} . ' -framework ApplicationServices',
    DEFINE            => join (' ', @ld), # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
    OBJECT            => '$(O_FILES)', # link all the C files too
    PL_FILES	=> {},	# Prevent old MakeMaker from running Build.PL
    EXE_FILES	=> \@exe_files,
    clean	=> {FILES => join ' ', @clean_files},	# Clean up executables.
    (@ccflags ? (CCFLAGS => join ' ', @ccflags) : ()),
);

$mmv >= 6.31 and $attr{LICENSE} = 'perl';

$mmv >= 6.4501 and $attr{META_MERGE} = {
    build_requires => {
####	'Test::More' => 0.40,
    },
    resources => {
	license => 'http://dev.perl.org/licenses/',
    },
};

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
