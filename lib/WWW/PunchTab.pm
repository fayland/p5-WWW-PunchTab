package WWW::PunchTab;

use strict;
use warnings;
use LWP::UserAgent;
use MIME::Base64;
use JSON;
use Digest::SHA;
use Carp;
use vars qw/$errstr/;
sub errstr { $errstr }

sub new {
    my $class = shift;
    my %args = @_ % 2 ? %{$_[0]} : @_;

    $args{client_id}  or croak "client_id is required";
    $args{access_key} or croak "access_key is required";
    $args{secret_key} or croak "secret_key is required";
    $args{domain}     or croak "domain is required";
    $args{domain} = 'http://' . $args{domain} unless $args{domain} =~ '^https?\://';

    $args{ua} = LWP::UserAgent->new;

    bless \%args, $class;
}

sub sso_auth {
    my $self = shift;
    my %user = @_ % 2 ? %{$_[0]} : @_;

    my $auth_request = encode_base64(encode_json(\%user));
    my $timestamp = time();
    my $signature = Digest::SHA::hmac_sha1_hex("$auth_request $timestamp", $self->{secret_key});

    $self->{ua}->default_header('Referer', $self->{domain});
    my $resp = $self->{ua}->post('https://api.punchtab.com/v1/auth/sso', [
        client_id => $self->{client_id},
        key       => $self->{access_key},
        auth_request => $auth_request,
        timestamp    => $timestamp,
        signature    => $signature,
    ]);
    unless ($resp->is_success) {
        $errstr = $resp->status_line;
        return;
    }
    my $data = decode_json($resp->decoded_content);
    if ($data->{error}) {
        $errstr = $data->{error}->{description};
        return;
    }
    $self->{__access_token} = $data->{authResponse}->{accessToken};
    return $data->{authResponse}->{accessToken};
}

sub create_activity {
    my ($self, $action, $points) = @_;
    # visit, tweet, like, plusone, comment, invite, reply, apply, share, purchase, addtotimeline, search, download, view, checkin, subscribe, and follow
    my $access_token = $self->{__access_token};
    my $resp = $self->{ua}->post("https://api.punchtab.com/v1/activity/$action?access_token=$access_token", [
        $points ? ('points' => $points) : ()
    ]);
    unless ($resp->is_success) {
        $errstr = $resp->status_line;
        return;
    }
    my $data = decode_json($resp->decoded_content);
    if (ref $data eq 'HASH' and $data->{error}) {
        $errstr = $data->{error}->{description};
        return;
    }
    return $data;
}

1;