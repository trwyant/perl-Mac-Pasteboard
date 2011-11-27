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
badPasteboardFlavorErr
badPasteboardIndexErr
badPasteboardItemErr
badPasteboardSyncErr
callback
CFStringRef
com
coreFoundationUnknownErr
defaultFlavor
dualvar
duplicatePasteboardFlavorErr
executables
hoc
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
merchantability
noPasteboardPromiseKeeperErr
nobinary
noecho
noid
notPasteboardOwnerErr
pasteboards
pbcopy
pbpaste
pbtool
Peeker
programmatically
readonly
ssh
subflavor
synch
UTIs
Wyant
XS
YAML
