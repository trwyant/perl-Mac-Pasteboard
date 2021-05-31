package main;

use 5.006002;

use strict;
use warnings;

use Mac::Pasteboard;
use Test::More 0.88;	# Because of done_testing();

# NOTE this is an author test because the user tests need to be forced
# to run in the same process so I can control the order despite
# someone's desire to test in parallel.

# NOTE that the stuff in the following block involving $taint_canary
# only exists because Perl 5.6.2 does not have ${^TAINT}.

{
    open my $fh, '<', $0
	or plan skip_all => 'Can not determine whether taint mode is on';
    my $taint_canary = <$fh>;
    close $fh;

    eval {
	require Scalar::Util;
	Scalar::Util->import( 'tainted' );
	1;
    } or plan skip_all => 'Scalar::Util tainted() not available';

    tainted( $taint_canary )
	or exec { $^X } $^X, qw{ -Mblib -T }, $0;
}

my $pb = Mac::Pasteboard->new();

$pb->clear();
$pb->copy( 'Able was I ere I saw Elba' );

note <<'EOD';

Test paste()
EOD

my ( $data, $flags ) = $pb->paste();
ok tainted( $data ), 'data are tainted';
ok ! tainted( $flags ), 'flags are not tainted';

my %do_not_invert = map { $_ => 1 } qw{ data };

note <<'EOD';

Test paste_all()
EOD

foreach my $datum ( $pb->paste_all() ) {
    note '';
    foreach my $key ( sort keys %{ $datum } ) {
	my $taint_check = tainted( $datum->{$key} );
	my $name;
	if ( $do_not_invert{$key} ) {
	    $name = "{$key} is tainted";
	} else {
	    $taint_check = ! $taint_check;
	    $name = "{$key} is not tainted";
	}
	ok $taint_check, $name;
    }
}

done_testing;

1;

# ex: set textwidth=72 :
