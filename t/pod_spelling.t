use strict;
use warnings;

BEGIN {
    eval "use Test::Spelling";
    $@ and do {
	print "1..0 # skip Test::Spelling not available.\n";
	exit;
    };
}

add_stopwords (<DATA>);

all_pod_files_spelling_ok ();
__DATA__
CFStringRef
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
darwin
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
