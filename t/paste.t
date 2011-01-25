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

plan (tests => 9);

my $test = 0;

my $pbopt;
foreach my $args (
    [], ['general', undef, undef, kPasteboardClipboard],
    ['find', 'pbcopy_find', 'pbpaste_find', kPasteboardFind]
) {
    ($pbopt, my $putter, my $getter, my @args) = @$args;
    $pbopt = $pbopt ? "-pbopt $pbopt" : '';
    my $putsub = __PACKAGE__->can ($putter ||= 'pbcopy');
    my $getsub = __PACKAGE__->can ($getter ||= 'pbpaste');

    print <<eod;
#
#	Test with pasteboard name @{[@args ? "'$args[0]'" : 'defaulted']}
eod

    my $pb = Mac::Pasteboard->new (@args);

    $pb->clear ();
    my $data = '    She set out one day';
    $pb->copy ($data);
    mytest(scalar $pb->paste (), $data, 'Retrieve data placed with copy.');

    $data = '    In a relative way';
    $putsub->($data);
    mytest(scalar $pb->paste (), $data, "Retrieve data placed with $putter.");

    $data = 'And returned the previous night.';
    $pb->clear ();
    $pb->copy ($data);
    mytest(scalar $getsub->(), $data, "Retrieve data with $getter.");
}

sub mytest {
    $test++;
    my $got = shift;
    my $want = shift;
    my ($ext_got, $ext_want);
    ($got, $ext_got) = groom ($got);
    ($want, $ext_want) = groom ($want);
    print <<eod;
#
# Test $test - @_
#      Got: $ext_got
#   Expect: $ext_want
eod
    my $ref = ref $want;
    if ($ref eq 'Regexp') {
	ok ($got =~ $want);
    } elsif (defined $want) {
	ok ($got eq $want);
    } else {
	ok (!defined $got);
    }
    return;
}

sub groom {
    my $data = shift;
    if (!defined $data) {
	return ($data, 'undef');
    } elsif (!ref $data) {
	chomp $data;
	return ($data, "'$data'");
    } else {
	return ($data, $data);
    }
}

1;
