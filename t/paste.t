package main;

use strict;
use warnings;

use Mac::Pasteboard qw{:all};
use Test::More 0.88;

sub mytest (@);

{
    Mac::Pasteboard->set( fatal => 0 );
    Mac::Pasteboard->new();
    if (Mac::Pasteboard->get( 'status' ) == coreFoundationUnknownErr()) {
	plan skip_all => 'No access to desktop (maybe running as cron job?)';
	exit;
    }
    Mac::Pasteboard->set( fatal => 1 );
}

my $pbopt;
foreach my $args (
    [], ['general', undef, undef, kPasteboardClipboard],
    ['find', 'pbcopy_find', 'pbpaste_find', kPasteboardFind]
) {
    ($pbopt, my $putter, my $getter, my @args) = @$args;
    $pbopt = $pbopt ? "-pbopt $pbopt" : '';
    my $putsub = __PACKAGE__->can ($putter ||= 'pbcopy');
    my $getsub = __PACKAGE__->can ($getter ||= 'pbpaste');

    my $where = $args[0] || 'the default pasteboard';

    my $pb = Mac::Pasteboard->new(@args);

    $pb->clear();
    my $data = '    She set out one day';
    $pb->copy ($data);
    mytest scalar $pb->paste(), $data,
	"Retrieve data placed on $where with copy.";

    $data = '    In a relative way';
    $putsub->($data);
    mytest scalar $pb->paste(), $data,
	"Retrieve data placed on $where with $putter.";

    $data = 'And returned the previous night.';
    $pb->clear();
    $pb->copy ($data);
    mytest scalar $getsub->(), $data, "Retrieve data from $where with $getter.";
}

done_testing;

sub mytest (@) {
    my $got = shift;
    my $want = shift;
    my ($ext_got, $ext_want);
    ($got, $ext_got) = groom ($got);
    ($want, $ext_want) = groom ($want);
    my $ref = ref $want;
    if ($ref eq 'Regexp') {
	@_ = ( $got, $want, "@_" );
	goto &like;
    } elsif (defined $want) {
	@_ = ( $got, $want, "@_" );
	goto &is;
    } else {
	@_ = ( ! defined $got, "@_" );
	goto &ok;
    }
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
