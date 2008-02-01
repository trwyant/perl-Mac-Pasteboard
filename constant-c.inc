
long pbl_badPasteboardFlavorErr () {
    return badPasteboardFlavorErr;
}

long pbl_badPasteboardIndexErr () {
    return badPasteboardIndexErr;
}

long pbl_badPasteboardItemErr () {
    return badPasteboardItemErr;
}

long pbl_badPasteboardSyncErr () {
    return badPasteboardSyncErr;
}

long pbl_duplicatePasteboardFlavorErr () {
    return duplicatePasteboardFlavorErr;
}

unsigned long pbl_kPasteboardClientIsOwner () {
    return kPasteboardClientIsOwner;
}

static char * cstring_kPasteboardClipboard = NULL;
char * pbl_kPasteboardClipboard () {
    if (cstring_kPasteboardClipboard == NULL && kPasteboardClipboard != NULL)
        cstring_kPasteboardClipboard = pblx_get_cstring (kPasteboardClipboard);
    return cstring_kPasteboardClipboard;
}


static char * cstring_kPasteboardFind = NULL;
char * pbl_kPasteboardFind () {
    if (cstring_kPasteboardFind == NULL && kPasteboardFind != NULL)
        cstring_kPasteboardFind = pblx_get_cstring (kPasteboardFind);
    return cstring_kPasteboardFind;
}


unsigned long pbl_kPasteboardFlavorNoFlags () {
    return kPasteboardFlavorNoFlags;
}

unsigned long pbl_kPasteboardFlavorNotSaved () {
    return kPasteboardFlavorNotSaved;
}

unsigned long pbl_kPasteboardFlavorPromised () {
    return kPasteboardFlavorPromised;
}

unsigned long pbl_kPasteboardFlavorRequestOnly () {
    return kPasteboardFlavorRequestOnly;
}

unsigned long pbl_kPasteboardFlavorSenderOnly () {
    return kPasteboardFlavorSenderOnly;
}

unsigned long pbl_kPasteboardFlavorSenderTranslated () {
    return kPasteboardFlavorSenderTranslated;
}

unsigned long pbl_kPasteboardFlavorSystemTranslated () {
    return kPasteboardFlavorSystemTranslated;
}

unsigned long pbl_kPasteboardModified () {
    return kPasteboardModified;
}

static char * cstring_kPasteboardUniqueName = NULL;
char * pbl_kPasteboardUniqueName () {
    if (cstring_kPasteboardUniqueName == NULL && kPasteboardUniqueName != NULL)
        cstring_kPasteboardUniqueName = pblx_get_cstring (kPasteboardUniqueName);
    return cstring_kPasteboardUniqueName;
}


long pbl_noPasteboardPromiseKeeperErr () {
    return noPasteboardPromiseKeeperErr;
}

long pbl_notPasteboardOwnerErr () {
    return notPasteboardOwnerErr;
}
