#!/usr/local/bin/perl

use strict;
use warnings;

my %const;

my %source = (
    c => {
	name => 'constant-c.inc',
	preamble => '',
    },
    h => {
	name => 'constant-h.inc',
	preamble => '',
    },
    xs => {
	name => 'constant-xs.inc',
	preamble => '',
    },
);

my %type = (
    char => {
	c => sub {<<eod},

static char * cstring_$_[0] = NULL;
char * pbl_$_[0] () {
    if (cstring_$_[0] == NULL && $_[0] != NULL)
        cstring_$_[0] = pblx_get_cstring ($_[0]);
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
    PPCODE:
	{
	    char * text;
	    text = pbl_$_[0] ();
	    EXTEND (SP, 3);
	    if (text == NULL) {
		PUSHs (sv_2mortal (newSV (0)));
	    } else {
		PUSHs (sv_2mortal (newSVpv (text, 0)));
	    }
	}
eod
    },
    long => {
	c => sub {<<eod},

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
	RETVAL = pbl_$_[0] ();
    OUTPUT:
	RETVAL
eod
    },
    ulong => {
	c => sub {<<eod},

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
	RETVAL = pbl_$_[0] ();
    OUTPUT:
	RETVAL
eod
    },
);
foreach (<DATA>) {
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
}


__DATA__
char	kPasteboardClipboard
char	kPasteboardFind
char	kPasteboardUniqueName
long	badPasteboardSyncErr
long	badPasteboardIndexErr
long	badPasteboardItemErr
long	badPasteboardFlavorErr
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
