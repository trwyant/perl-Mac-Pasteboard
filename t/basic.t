package main;

use strict;
use warnings;

use Test;

BEGIN { plan tests => 11 };

my $skip;
my $test = 0;

heading ('Load Mac::Pasteboard');
eval {
    require Mac::Pasteboard;
};
$skip = $@;
ok(!$@); # If we made it this far, we're ok.
$skip and warn "Failed to load Mac::Pasteboard:\n$skip";

heading ('Instantiate Mac::Pasteboard');
my $pb = eval {Mac::Pasteboard->new()};
skip ($skip, $pb);
$pb or warn "Failed to instantiate Mac::Pasteboard:\n$@";

foreach (
    [0 => 'kPasteboardFlavorNoFlags'],
    [1 => 'kPasteboardFlavorSenderOnly'],
    [2 => 'kPasteboardFlaverSenderTranslated'],
    [3 => 'kPasteboardFlaverSenderOnly,kPasteboardFlavorSenderTranslated'],
    [4 => 'kPasteboardFlavorNotSaved'],
    [8 => 'kPasteboardFlavorRequestOnly'],
    [256 => 'kPasteboardFlavorSystemTranslated'],
    [512 => 'kPasteboardFlavorPromised'],
) {
    heading ('flavor_flag_names(0) => kPasteboardFlavorNoFlags');
    my $data = eval{Mac::Pasteboard->flavor_flag_names(0)} || '';
    skip ($skip, $data eq 'kPasteboardFlavorNoFlags');
}

heading("Flavor tags for com.apple.traditional-mac-plain-text");
my $data = eval{Mac::Pasteboard->flavor_tags(
	'com.apple.traditional-mac-plain-text')} || {};
skip($skip, $data->{os} eq 'TEXT');

sub heading {
    $test++;
    print <<eod;
#
# Test $test - @_
eod
    return;
}

1;
