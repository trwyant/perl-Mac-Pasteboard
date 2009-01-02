package main;

use strict;
use warnings;

use Mac::Pasteboard qw{:all};
use Test;

my $rslt = `pbcopy -help 2>&1`;
if ($?) {
    print "1..0 # skip Pbcopy program not found.\n";
    exit;
}

Mac::Pasteboard->set (fatal => 0);
my $pb = Mac::Pasteboard->new ();
if (Mac::Pasteboard->get ('status') == coreFoundationUnknownErr) {
    print "1..0 # skip No access to desktop (maybe running as cron job?)\n";
    exit;
}
$pb or die Mac::Pasteboard->get ('status');

plan (tests => 2);

my $test = 0;

{
    my $pid = open (my $fh, '|-', 'pbcopy')
	or die "Unable to open pipe to pbcopy: $!\n";
    print $fh <<eod;
The Bustard's a genial fowl,
With minimal reason to growl.
    He escapes what would be
    Illegitimacy
By means of a fortunate vowel.
eod
    close $fh;
}

mytest (kPasteboardModified, "Modify the pasteboard after we attached to it");

$pb->clear ();
mytest (kPasteboardClientIsOwner, "Clear the pasteboard, which makes us owner");

sub mytest {
    my $got = $pb->synch ();
    my $expect = shift;
    print <<eod;
#
# Test $test - @_
#      Got: @{[sprintf '%#x (%s)', $got,
       scalar Mac::Pasteboard->synch_flag_names ($got)]}
#   Expect: @{[sprintf '%#x (%s)', $expect,
       scalar Mac::Pasteboard->synch_flag_names ($expect)]}
eod
    ok ($expect == $got);
    return;
}

1;
