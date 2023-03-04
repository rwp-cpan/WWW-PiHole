use v5.37.9;
use experimental qw( class builtin try );

package WWW::PiHole;

class WWW::PiHole {

  use URI;
  use HTTP::Tiny;
  use JSON::PP;

  # @formatter:off

  field $auth :param = undef;

  # @formatter:on

  my $uri = URI -> new( 'http://pi.hole/admin/api.php' );
  my $http = HTTP::Tiny -> new;
  my $json = JSON::PP -> new;

  method _status ( $uri ) {
    $json -> decode( $http -> get( $uri ) -> {content} ) -> {status};
  }

  method _list ( $uri ) {
    my $hash = $json -> decode( $http -> get( $uri ) -> {content} );
    if ( $hash -> {success} ) { # JSON::PP::Boolean
      $hash -> {message};       # {"success":true,"message":null}
    }
  }

  method enable ( ) {
    $uri -> query_param( auth => $auth );
    $uri -> query_param( enable => undef );
    $self -> _status( $uri );
  }

  method disable ( ) {
    $uri -> query_param( auth => $auth );
    $uri -> query_param( disable => undef );
    $self -> _status( $uri );
  }

  method status ( ) {
    $uri -> query_param( status => undef );
    $self -> _status( $uri );
  }

  method add ( $domain , $list = 'black' ) {
    $uri -> query_param( auth => $auth );
    $uri -> query_param( list => $list );
    $uri -> query_param( add => $domain );
    $self -> _list( $uri );
  }

  # supported lists: black, regex_black, white, regex_white
  # URL: http://pi.hole/admin/groups-domains.php

  method remove ( $domain , $list = 'black' ) {
    $uri -> query_param( auth => $auth );
    $uri -> query_param( list => $list );
    $uri -> query_param( sub => $domain );
    $self -> _list( $uri );
  }

  method recent ( ) {
    $uri -> query_param( recentBlocked => undef );
    $http -> get( $uri ) -> {content}; # domain name
  }

  method add_dns ( $domain , $ip ) {

    $uri -> query_param( auth => $auth );
    $uri -> query_param( customdns => undef );
    $uri -> query_param( action => 'add' );
    $uri -> query_param( domain => $domain );
    $uri -> query_param( ip => $ip );

    $http -> get( $uri ) -> {content}; # domain name

    # https://github.com/pi-hole/AdminLTE/blob/b29a423b9553654f113bcdc8a82296eb6e4613d7/scripts/pi-hole/php/func.php#L223

  }

  method remove_dns ( $domain , $ip ) {

    # Command: pihole -a removecustomdns

    $uri -> query_param( auth => $auth );
    $uri -> query_param( customdns => undef );
    $uri -> query_param( action => 'delete' );
    $uri -> query_param( domain => $domain );
    $uri -> query_param( ip => $ip );

    $http -> get( $uri ) -> {content}; # domain name

  }

  method add_cname ( $domain , $target ) {

    $uri -> query_param( auth => $auth );
    $uri -> query_param( customcname => undef );
    $uri -> query_param( action => 'add' );
    $uri -> query_param( domain => $domain );
    $uri -> query_param( target => $target );

    $http -> get( $uri ) -> {content}; # domain name

  }

  method remove_cname ( $domain , $target ) {

    $uri -> query_param( auth => $auth );
    $uri -> query_param( customcname => undef );
    $uri -> query_param( action => 'delete' );
    $uri -> query_param( domain => $domain );
    $uri -> query_param( target => $target );

    $http -> get( $uri ) -> {content}; # domain name

  }

}

# https://github.com/pi-hole/AdminLTE/blob/master/api.php
