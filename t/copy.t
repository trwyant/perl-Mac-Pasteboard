package main;

use strict;
use warnings;

use Mac::Pasteboard qw{:all};
use Test;

`pbpaste -help 2>&1`;
if ($?) {
    print "1..0 # skip Pbpaste program not found.\n";
    exit;
}

{
    Mac::Pasteboard->set (fatal => 0);
    Mac::Pasteboard->new ();
    if (Mac::Pasteboard->get ('status') == coreFoundationUnknownErr ()) {
	print "1..0 # skip No access to desktop (maybe running as cron job?)\n";
	exit;
    }
    Mac::Pasteboard->set (fatal => 1);
}

my $test = 0;

plan (tests => 18);

my $pbopt;
foreach my $args (
    [],
    ['general', undef, kPasteboardClipboard],
    ['find', 'pbcopy_find', kPasteboardFind],
) {
    ($pbopt, my $putter, my @args) = @$args;
    $pbopt = $pbopt ? "-pboard $pbopt" : '';
    my $putsub = __PACKAGE__->can ($putter ||= 'pbcopy');

    print <<eod;
#
#	Test with pasteboard name @{[@args ? "'$args[0]'" : 'defaulted']}
eod

    my $pb = Mac::Pasteboard->new (@args);
    $pb->clear;
    mytest('', 'Initial clear should leave the pasteboard clear.');

    my $data = 'There was a young lady named Bright';
    $pb->copy ($data);
    mytest($data, 'Place text data on the pasteboard.');

    $data = {map {$_->{flavor} => $_} $pb->flavors()};
    $test++;
    print <<eod;
#
# $test - Flavor com.apple.traditional-mac-plain-text should be there
eod
    ok($data->{'com.apple.traditional-mac-plain-text'});

    $pb->clear;
    mytest('', 'Clear the pasteboard again.');

    $data = 'Who could travel much faster than light.';
    $putsub->($data);
    mytest($data, "Use $putter to put data on the pasteboard.");

    $pb->clear;
    mytest('', 'Clear data placed by pbcopy.');

##	The following test is bypassed because pbpaste actually finds
##	the data. I am not sure how this can be, since PasteboardPeeker
##	does not, but it leaves me with no way to test.
##
##    $pb->copy ("Able was I, ere I saw Elba", undef,
##	kPasteboardFlavorSenderOnly);
##    mytest('', 'Should fail to find sender-only data.');

}


sub mytest {
    $test++;
    my $got = `pbpaste $pbopt`;
    my $expect = shift;
    chomp $got;
    chomp $expect;
    print <<eod;
#
# Test $test - @_
#      Got: '$got'
#   Expect: '$expect'
eod
    ok ($got eq $expect);
    return;
}

1;
