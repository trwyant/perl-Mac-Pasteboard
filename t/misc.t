package main;

use strict;
use warnings;

use Mac::Pasteboard qw{:all};
use Test;

{
    Mac::Pasteboard->set (fatal => 0);
    Mac::Pasteboard->new ();
    if (Mac::Pasteboard->get ('status') == coreFoundationUnknownErr ()) {
	print "1..0 # skip No access to desktop (maybe running as cron job?)\n";
	exit;
    }
    Mac::Pasteboard->set (fatal => 1);
}

plan (tests => 6);
my $test = 0;

{
    my $text = 'Deck us all with Boston Charlie';
    my $orig = Mac::Pasteboard->new (kPasteboardUniqueName);

    heading('Instantiate unique-named pasteboard');
    ok ($orig);
    $orig->clear ();
    $orig->copy ($text);

    heading('Data round-trip');
    my $rslt = $orig->paste ();
    ok ($rslt eq $text);

    heading('Clone pasteboard object');
    my $clone = $orig->clone ();
    ok ($clone);

    heading('Clone should be different object');
    ok ($clone ne $orig);

    heading("Original text should be accessible through clone");
    $rslt = $clone->paste ();
    ok ($rslt eq $text);

    heading('Should still be accessible after original blown away');
    $orig = undef;	# Garbage collect.
    $rslt = $clone->paste ();
    ok ($rslt eq $text);
}

sub heading {
    $test++;
    print <<eod;
#
# Test $test - @_
eod
    return;
}

1;
