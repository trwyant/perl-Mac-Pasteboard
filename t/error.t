package main;

use strict;
use warnings;

use Mac::Pasteboard qw{coreFoundationUnknownErr};
use Test::More 0.88;

sub mytest (@);	## no critic (ProhibitSubroutinePrototypes)

Mac::Pasteboard->set (fatal => 0);
my $pb = Mac::Pasteboard->new ();
if (Mac::Pasteboard->get ('status') == coreFoundationUnknownErr) {
    plan skip_all => 'No access to desktop (maybe running as cron job?)';
    exit;
}
$pb or die Mac::Pasteboard->get ('status');

$pb->clear ();
my $data;
eval {
    $data = $pb->paste();
    1;
} or do {
    $ENV{DEVELOPER_DEBUG} and warn $@;
    $data = $pb->get ('status');
};

mytest $data, -25133, 'Retrieve from cleared pasteboard.';

$pb->set (missing_ok => 1);
eval {
    $data = $pb->paste();
    1;
} or do {
    $ENV{DEVELOPER_DEBUG} and warn $@;
    $data = $pb->get ('status');
};
mytest $data, undef,
    'Retrieve from cleared pasteboard, if missing_ok is true.';

$pb->copy ('original data');
eval {
    $data = $pb->copy ('different data');
    1;
} or do {
    $ENV{DEVELOPER_DEBUG} and warn $@;
    $data = $pb->get ('status');
};
mytest $data, -25134, 'Duplicate copy.';

done_testing;

sub mytest (@) {	## no critic (ProhibitSubroutinePrototypes, RequireArgUnpacking)
    my $got = shift;
    my $want = shift;
    my ($ext_got, $ext_want);
    ($got, $ext_got) = groom ($got);
    ($want, $ext_want) = groom ($want);
    @_ = ( ( defined $want ? $want == $got : ! defined $got ), "@_" );
    goto &ok;
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
