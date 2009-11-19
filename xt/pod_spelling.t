package main;

use strict;
use warnings;

BEGIN {
    eval {
	require Test::Spelling;
	Test::Spelling->import();
	1;
    } or do {
	print "1..0 # skip Test::Spelling not available.\n";
	exit;
    };
}

add_stopwords (<DATA>);

all_pod_files_spelling_ok ();

1;
__DATA__
CFStringRef
Pbtool
Peeker
UTIs
Wyant
XS
YAML
badPasteboardFlavorErr
badPasteboardIndexErr
badPasteboardItemErr
badPasteboardSyncErr
callback
com
coreFoundationUnknownErr
defaultFlavor
dualvar
duplicatePasteboardFlavorErr
jpeg
kPasteboardClientIsOwner
kPasteboardClipboard
kPasteboardFind
kPasteboardFlavorNoFlags
kPasteboardFlavorNotSaved
kPasteboardFlavorPromised
kPasteboardFlavorRequestOnly
kPasteboardFlavorSenderOnly
kPasteboardFlavorSenderTranslated
kPasteboardFlavorSystemTranslated
kPasteboardModified
kPasteboardUniqueName
mac
macerror
noPasteboardPromiseKeeperErr
nobinary
noecho
noid
notPasteboardOwnerErr
pasteboards
pbcopy
pbpaste
pbtool
programmatically
readonly
ssh
subflavor
synch
