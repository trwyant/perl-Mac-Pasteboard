use strict;
use warnings;

use Test;

BEGIN { plan tests => 2 };

my $skip;
eval {
    require Mac::Pasteboard;
};
$skip = $@;
ok(!$@); # If we made it this far, we're ok.
$skip and warn "Failed to load Mac::Pasteboard:\n$skip";

my $pb = eval {Mac::Pasteboard->new()};
skip ($skip, $pb);
$pb or warn "Failed to instantiate Mac::Pasteboard:\n$@";
