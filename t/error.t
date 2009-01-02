package main;

use strict;
use warnings;

use Mac::Pasteboard qw{coreFoundationUnknownErr};
use Test;

Mac::Pasteboard->set (fatal => 0);
my $pb = Mac::Pasteboard->new ();
if (Mac::Pasteboard->get ('status') == coreFoundationUnknownErr) {
    print "1..0 # skip No access to desktop (maybe running as cron job?)\n";
    exit;
}
$pb or die Mac::Pasteboard->get ('status');

plan (tests => 3);

my $test = 0;

$pb->clear ();
my $data = eval {$pb->paste ()};
if ($@) {
    $ENV{DEVELOPER_DEBUG} and warn $@;
    $data = $pb->get ('status');
}
mytest($data, -25133, 'Retrieve from cleared pasteboard.');

$pb->set (missing_ok => 1);
$data = eval {$pb->paste ()};
if ($@) {
    $ENV{DEVELOPER_DEBUG} and warn $@;
    $data = $pb->get ('status');
}
$@ and $data = $pb->get ('status');
mytest($data, undef,
    'Retrieve from cleared pasteboard, if missing_ok is true.');

$pb->copy ('original data');
$data = eval {$pb->copy ('different data')};
if ($@) {
    $ENV{DEVELOPER_DEBUG} and warn $@;
    $data = $pb->get ('status');
}
mytest($data, -25134, 'Duplicate copy.');

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
    if (defined $want) {
	ok ($got == $want);
    } else {
	ok (!defined $got);
    }
    return;
}

sub groom {
    my $data = shift;
    if (!defined $data) {
	return ($data, 'undef');
##    } elsif (!ref $data) {
##	chomp $data;
##	$data =~ s/\s+.*//;
##	return ($data, $data =~ m/^[+\-]?\d+$/ ? $data : "'$data'");
##    } else {
##	return ($data, $data);
##    }

    } else {
	return ($data + 0, $data + 0);
    }
}

1;
