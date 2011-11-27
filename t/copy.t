package main;

use strict;
use warnings;

use Mac::Pasteboard qw{:all};
use Test::More 0.88;

sub mytest (@);	## no critic (ProhibitSubroutinePrototypes)

`pbpaste -help 2>&1`;
if ($?) {
    plan skip_all => 'Pbpaste program not found';
    exit;
}

{
    Mac::Pasteboard->set (fatal => 0);
    Mac::Pasteboard->new ();
    if (Mac::Pasteboard->get ('status') == coreFoundationUnknownErr ()) {
	plan skip_all => 'No access to desktop (maybe running as cron job?)';
	exit;
    }
    Mac::Pasteboard->set (fatal => 1);
}

my $pbopt;
foreach my $args (
    [],
    ['general', undef, kPasteboardClipboard],
    ['find', 'pbcopy_find', kPasteboardFind],
) {
    ($pbopt, my $putter, my @args) = @$args;
    $pbopt = $pbopt ? "-pboard $pbopt" : '';
    my $putsub = __PACKAGE__->can ($putter ||= 'pbcopy');

    my $where = $args[0] || 'the default pasteboard';

    my $pb = Mac::Pasteboard->new( @args );
    $pb->clear;
    mytest '', "Initial clear should leave $where clear.";

    my $data = 'There was a young lady named Bright';
    $pb->copy ($data);
    mytest $data, "Place text data on $where.";

    $data = {map {$_->{flavor} => $_} $pb->flavors()};
    ok $data->{'com.apple.traditional-mac-plain-text'},
    "Flavor com.apple.traditional-mac-plain-text should be present on $where";

    $pb->clear;
    mytest '', "Clear $where again.";

    $data = 'Who could travel much faster than light.';
    $putsub->($data);
    mytest $data, "Use $putter to put data on $where.";

    $pb->clear;
    mytest '', "Clear data placed on $where by pbcopy.";

##	The following test is bypassed because pbpaste actually finds
##	the data. I am not sure how this can be, since PasteboardPeeker
##	does not, but it leaves me with no way to test.
##
##    $pb->copy ("Able was I, ere I saw Elba", undef,
##	kPasteboardFlavorSenderOnly);
##    mytest '', "Should fail to find sender-only data on $where.";

}

done_testing;


sub mytest (@) {	## no critic (ProhibitSubroutinePrototypes, RequireArgUnpacking)
    my $got = `pbpaste $pbopt`;
    my $expect = shift;
    chomp $got;
    chomp $expect;
    @_ = ( $got, $expect, "@_" );
    goto &is;
}

1;

# ex: set textwidth=72 :
