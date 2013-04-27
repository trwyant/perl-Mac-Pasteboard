package main;

use strict;
use warnings;

use Mac::Pasteboard qw{:all};
use Test::More 0.88;

use lib qw{ inc };

use Mac::Pasteboard::Test;

sub mytest (@);	## no critic (ProhibitSubroutinePrototypes)

check_testable;

foreach my $args (
    [],
    [ undef, undef, kPasteboardClipboard ],
    [ 'pbcopy_find', 'pbpaste_find', kPasteboardFind ],
) {
    ( my $putter, my $getter, my $name, my @args ) = @$args;
    my $putsub = __PACKAGE__->can ($putter ||= 'pbcopy');
    my $getsub = __PACKAGE__->can ($getter ||= 'pbpaste');

    my $where = $name || 'the default pasteboard';

    my $pb = defined $name ?
	Mac::Pasteboard->new( $name ) :
	Mac::Pasteboard->new();
    @args
	and $pb->set( @args );
    my $flavor = $pb->get( 'default_flavor' );

    $pb->clear();
    my $data = '    She set out one day';
    $pb->copy ($data);
    mytest scalar $pb->paste(), $data,
	"Retrieve $flavor data from $where with copy.";

    $data = '    In a relative way';
    flavorize( $putter, $pb->get( 'default_flavor' ) );
    $putsub->($data);
    mytest scalar $pb->paste(), $data,
	"Retrieve $flavor data from $where with $putter.";

    $data = 'And returned the previous night.';
    $pb->clear();
    $pb->copy ($data);
    flavorize( $getter, $pb->get( 'default_flavor' ) );
    mytest scalar $getsub->(), $data,
	"Retrieve $flavor data from $where with $getter.";
}

done_testing;

sub mytest (@) {	## no critic (ProhibitSubroutinePrototypes, RequireArgUnpacking)
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

sub flavorize {
    my ( $target, $flavor ) = @_;
    ( my $sub = $target ) =~
	s/ \A pb ( copy | paste ) (?= \z | _ ) /pbflavor/smx;
    my $code = __PACKAGE__->can( $sub )
	or die "Unable to find $sub()";
    $code->( $flavor );
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
