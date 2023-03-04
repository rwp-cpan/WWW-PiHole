# ABSTRACT: Perl interface to Pi-hole

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

=method enable()

Enable Pi-Hole

Returns the status ('enabled')

=cut

  method disable ( ) {
    $uri -> query_param( auth => $auth );
    $uri -> query_param( disable => undef );
    $self -> _status( $uri );
  }

=method disable()

Disable Pi-Hole

Returns the status ('disabled')

=cut

  method status ( ) {
    $uri -> query_param( status => undef );
    $self -> _status( $uri );
  }

=method status()

Get Pi-Hole status

Returns 'enabled' or 'disabled'    

=cut

  method add ( $domain , $list = 'black' ) {
    $uri -> query_param( auth => $auth );
    $uri -> query_param( list => $list );
    $uri -> query_param( add => $domain );
    $self -> _list( $uri );
  }

=method add

Add domain to the blacklist (by default)

C<$list> can be one of: C<black>, C<regex_black>, C<white>, C<regex_white>

URL: http://pi.hole/admin/groups-domains.php

=cut

  method remove ( $domain , $list = 'black' ) {
    $uri -> query_param( auth => $auth );
    $uri -> query_param( list => $list );
    $uri -> query_param( sub => $domain );
    $self -> _list( $uri );
  }

=method remove($domain [, $list])

Add domain to the blacklist (by default)

C<$list> can be one of: C<black>, C<regex_black>, C<white>, C<regex_white>

AdminLTE API Function: C<sub>

URL: http://pi.hole/admin/groups-domains.php

=cut

  method recent ( ) {
    $uri -> query_param( recentBlocked => undef );
    $http -> get( $uri ) -> {content}; # domain name
  }

=method recent()

Get the most recently blocked domain name

AdminLTE API Function: C<recentBlocked>

=cut


  method add_dns ( $domain , $ip ) {

    $uri -> query_param( auth => $auth );
    $uri -> query_param( customdns => undef );
    $uri -> query_param( action => 'add' );
    $uri -> query_param( domain => $domain );
    $uri -> query_param( ip => $ip );

    $http -> get( $uri ) -> {content}; # domain name

    # https://github.com/pi-hole/AdminLTE/blob/b29a423b9553654f113bcdc8a82296eb6e4613d7/scripts/pi-hole/php/func.php#L223

  }

=method add_dns($domain, $ip)

Add DNS A record mapping domain name to an IP address

=cut

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

=method add_cname($domain, $target)

Add DNS CNAME record effectively redirecting one domain to another

AdminLTE API Functions: C<customcname>, C<addCustomCNAMEEntry>

See the L<https://github.com/pi-hole/AdminLTE/blob/master/scripts/pi-hole/php/func.php|func.php> script

URL: http://localhost/admin/cname_records.php

=cut


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
