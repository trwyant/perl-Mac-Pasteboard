use 5.006;

use strict;
use warnings;

$^O eq 'darwin'
    or die "OS unsupported\n";

use Module::Build;
use Config;

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

my @PL_files;
foreach my $if (qw{Pasteboard.xs constant-c.inc constant-h.inc
    constant-xs.inc pbl.c pbl.h ppport.h}) {
    my $of = 'lib/Mac/' . $if;
    push @PL_files, $of;
}

my @ccflags;
if ($ENV{DEVELOPER_DEBUG}) {
    push @ccflags, '-DDEBUG_PBL';
    local $_ = $ENV{DEVELOPER_DEBUG};
    m/\bbacktrace\b/i and push @ccflags, '-DDEBUG_PBL_BACKTRACE';
}

(my $mbv = Module::Build->VERSION) =~ s/_//g;

my %attr = (
    dist_author => 'Tom Wyant (wyant at cpan dot org)',
    dist_abstract => 'Manipulate Mac OS X pasteboards',
    module_name => 'Mac::Pasteboard',
    dist_name => 'Mac-Pasteboard',
    dist_version_from => 'lib/Mac/Pasteboard.pm',
    get_options => {y => {}, n => {}},
    dynamic_config => 1,
    license => 'perl',
    requires => {
	perl => 5.006,
	'Scalar::Util' => 1.01,
    },
    build_requires => {
	'ExtUtils::CBuilder' => 0,
    },
    config => {
	lddlflags => $Config{lddlflags} . ' -framework ApplicationServices',
    },
    PL_files => {
	'MBCopy.PL' => \@PL_files,
    },
    c_source => 'lib/Mac',	# We rely on MBCopy.PL to put them there.
    (@ccflags ?
	(extra_compiler_flags => \@ccflags) :
	()
    ),
);

$mbv >= 0.28 and $attr{meta_merge} = {
    no_index => {
	directory => [qw{inc t}],
    },
};

my $bldr = Module::Build->new (%attr);

my %opt = $bldr->args ();
my @exe_files;
my @clean_files;

if ($opt{n}) {
    $opt{y}
	and die "Please do not assert both -n and -y. It is too confusing.\n";
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
    $bldr->prompt ("Do you want to install pbtool?", 'n') =~ m/^y/i
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

$bldr->add_to_cleanup (@clean_files);
$bldr->script_files (\@exe_files);

$bldr->create_build_script ();
