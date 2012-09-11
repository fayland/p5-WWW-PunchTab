#!/usr/bin/perl

use strict;
use warnings;
use lib "lib";
use WWW::PunchTab;
use Data::Dumper;

my $pt = WWW::PunchTab->new(
    domain     => 'www.fayland.org',
    access_key => 'hello',
    client_id  => '123',
    secret_key => 'key',
);

$pt->sso_auth(
    {'id' => '2', 'first_name' => 'Fayland', 'last_name' => 'Lam', 'email' => 'fayland@gmail.com', 'avatar_link' => 'http://fayland.org/images/camel/kiss.jpg'}
) or die $pt->errstr;

my $x = $pt->create_activity('view', 200) or die $pt->errstr; # view with 200 points
print Dumper(\$x);

1;