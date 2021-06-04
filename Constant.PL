#!/usr/local/bin/perl

use strict;
use warnings;

my %const;

my %source = (
    c => {
	name => 'constant-c.inc',
	postamble => '',
	preamble => '',
    },
    h => {
	name => 'constant-h.inc',
	postamble => '',
	preamble => '',
    },
    xs => {
	name => 'constant-xs.inc',
	postamble	=> <<'EOD',

# ex: set filetype=xs :
EOD
	preamble => <<'EOD',
#ifdef USE_PBL_BACKEND
#define PBL_LONG(x) pbl_##x ()
#define PBL_SV(sv,x) sv = newSVpv( pbl_##x(), 0 )
#else	/* ifdef USE_PBL_BACKEND */
#define PBL_LONG(x) x
#define PBL_SV(sv,x) CF_TO_SV( sv, x )
#endif	/* ifdef USE_PBL_BACKEND */

EOD
    },
);

my %type = (
    char => {
	c => sub {<<eod},

#undef ROUTINE
#define ROUTINE "pbl_$_[0]"
static char * cstring_$_[0] = NULL;
char * pbl_$_[0] () {
    if (cstring_$_[0] == NULL && $_[0] != NULL) {
        cstring_$_[0] = pblx_get_cstring ($_[0]);
	LOG_TEXT ("String cached for life of program");
    }
    return cstring_$_[0];
}

eod
	h => sub {<<eod},

/*
 * pbl_$_[0] returns the value of $_[1].
 * You must NOT free this reference after use.
 */

char * pbl_$_[0] ();
eod
	xs => sub {<<eod},

SV *
$_[0] ()
    CODE:
	SV *sv;
	PBL_SV( sv, $_[0] );
	RETVAL = sv;
    OUTPUT:
	RETVAL
eod
    },
    long => {
	c => sub {<<eod},

#undef ROUTINE
#define ROUTINE "pbl_$_[0]"
long pbl_$_[0] () {
    return $_[0];
}
eod
	h => sub {<<eod},

/*
 * pbl_$_[0] returns the value of $_[1].
 */

long pbl_$_[0] ();
eod
	xs => sub {<<eod},

long
$_[0] ()
    CODE:
	RETVAL = PBL_LONG( $_[0] );
    OUTPUT:
	RETVAL
eod
    },
    ulong => {
	c => sub {<<eod},

#undef ROUTINE
#define ROUTINE "pbl_$_[0]"
unsigned long pbl_$_[0] () {
    return $_[0];
}
eod
	h => sub {<<eod},

/*
 * pbl_$_[0] returns the value of $_[1].
 */

unsigned long pbl_$_[0] ();
eod
	xs => sub {<<eod},

unsigned long
$_[0] ()
    CODE:
	RETVAL = PBL_LONG( $_[0] );
    OUTPUT:
	RETVAL
eod
    },
);
while (<DATA>) {
    chomp;
    s/^\s+//;
    $_ or next;
    substr ($_, 0, 1) eq '#' and next;
    s/\s+$//;
    my ($type, $name, $remark) = split '\s+', $_, 3;
    my $code = $type{$type}
	or die "Data type '$type' is unknown";
    $const{$name} = {
	code => $code,
	remark => $remark || $name,
    };
}

foreach my $sfx (qw{h c xs}) {
    $source{$sfx}
	or die "File type '$sfx' is unknown";
    my $fn = $source{$sfx}{name} || 'constant' . $sfx;
    open (my $fh, '>', $fn)
	or die "Unable to open $fn: $!";
    $source{$sfx}{preamble} and print $fh $source{$sfx}{preamble};
    foreach my $name (sort keys %const) {
	my $data = $const{$name};
	print $fh $data->{code}{$sfx}->($name, $data->{remark});
    }
    $source{$sfx}{postamble} and print $fh $source{$sfx}{postamble};
    close $fh;
}

__DATA__
char	kPasteboardClipboard
char	kPasteboardFind
char	kPasteboardUniqueName
long	badPasteboardSyncErr
long	badPasteboardIndexErr
long	badPasteboardItemErr
long	badPasteboardFlavorErr
long	coreFoundationUnknownErr
long	duplicatePasteboardFlavorErr
long	notPasteboardOwnerErr
long	noPasteboardPromiseKeeperErr
ulong	kPasteboardModified
ulong	kPasteboardClientIsOwner
ulong	kPasteboardFlavorNoFlags
ulong	kPasteboardFlavorSenderOnly
ulong	kPasteboardFlavorSenderTranslated
ulong	kPasteboardFlavorNotSaved
ulong	kPasteboardFlavorRequestOnly
ulong	kPasteboardFlavorSystemTranslated
ulong	kPasteboardFlavorPromised
