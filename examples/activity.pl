#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use WWW::PunchTab;
use Data::Dumper;

my $pt = WWW::PunchTab->new(
    domain     => 'fayland.org',
    access_key => 'f4f8290698320a98b1044615e722af79',
    client_id  => '1104891876',
    secret_key => 'ed73f70966dd10b7788b8f7953ec1d07',
);

$pt->sso_auth(
    {'id' => '2', 'first_name' => 'Fayland', 'last_name' => 'Lam', 'email' => 'fayland@gmail.com', 'avatar_link' => 'http://fayland.org/images/camel/kiss.jpg'}
) or die $pt->errstr;

my $x = $pt->create_activity('view', 200) or die $pt->errstr; # view with 200 points
print Dumper(\$x);

1;