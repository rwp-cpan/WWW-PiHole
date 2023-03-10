# ABSTRACT: Perl interface to Pi-hole

use v5.37.9;
use experimental qw( class );

package WWW::PiHole;

class WWW::PiHole {

  use URI;
  use HTTP::Tiny;
  use JSON::PP;
  use Syntax::Operator::In;
  use Term::ANSIColor;

  # @formatter:off

  field $auth :param = undef;

  # @formatter:on

  my $uri = URI -> new( 'http://pi.hole/admin/api.php' );
  my $http = HTTP::Tiny -> new;
  my $json = JSON::PP -> new;

  method _content ( ) {
    $http -> get( $uri ) -> {content};
  }

  method _content_json ( ) {
    $json -> decode( $self -> _content ); # 'content' is HTTP response body
  }

  method _status ( $uri ) {
    $self -> _content_json -> {status};
  }

  method _list ( $uri ) {
    my $json_body = $self -> _content_json;
    if ( $json_body -> {success} ) { # JSON::PP::Boolean
      $json_body -> {message};       # {"success":true,"message":null}
    }
  }

  method version ( $mode = 'current' ) {
    # Modes: 'update', 'current', 'latest', 'branch'

    # @formatter:off

    die colored ['bright_red', 'bold'], 'Bad mode'
      unless $mode in : eq ( 'update' , 'current' , 'latest' , 'branch' );

    # @formatter:on

    $uri -> query_param( versions => undef );

    my $hash = $self -> _content_json;

    sprintf "Core: %s, Web: %s, FTL: %s\n" ,
      $hash -> {join '_' , 'core' , $mode} ,
      $hash -> {join '_' , 'core' , $mode} ,
      $hash -> {join '_' , 'core' , $mode} ,
  }

=method version([$mode])

Get the version string for Pi-hole components

=cut

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

=method add($domain [, $list])

Add a domain to the blacklist (by default)

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

Remove a domain from the blacklist (by default)

C<$list> can be one of: C<black>, C<regex_black>, C<white>, C<regex_white>

AdminLTE API Function: C<sub>

URL: http://pi.hole/admin/groups-domains.php

=cut

  method recent ( ) {
    $uri -> query_param( recentBlocked => undef );
    $self -> content; # domain name
  }

=method recent()

Get the most recently blocked domain name

AdminLTE API: C<recentBlocked>

=cut

  method add_dns ( $domain , $ip ) {

    $uri -> query_param( auth => $auth );
    $uri -> query_param( customdns => undef );
    $uri -> query_param( action => 'add' );
    $uri -> query_param( domain => $domain );
    $uri -> query_param( ip => $ip );

    $self -> _content; # domain name

  }

=method add_dns($domain, $ip)

Add DNS A record mapping domain name to an IP address

AdminLTE API: C<customdns>
AdminLTE Function: C<addCustomDNSEntry>

=cut

  method remove_dns ( $domain , $ip ) {

    # Command: pihole -a removecustomdns

    $uri -> query_param( auth => $auth );
    $uri -> query_param( customdns => undef );
    $uri -> query_param( action => 'delete' );
    $uri -> query_param( domain => $domain );
    $uri -> query_param( ip => $ip );

    $self -> _content; # domain name

  }

=method remove_dns($domain, $ip)

Remove a custom DNS A record

ie. IP to domain name association

AdminLTE API: C<customdns>
AdminLTE Function: C<deleteCustomDNSEntry>

=cut


  method get_dns ( ) {
    $uri -> query_param( auth => $auth );
    $uri -> query_param( customdns => undef );
    $uri -> query_param( action => 'get' );

    $self -> _content_json -> {data};
  }

=method get_dns()

Get DNS records as an array of two-element arrays (IP and domain)

AdminLTE API: C<customdns>
AdminLTE Function: C<echoCustomDNSEntries>

=cut


  method add_cname ( $domain , $target ) {

    $uri -> query_param( auth => $auth );
    $uri -> query_param( customcname => undef );
    $uri -> query_param( action => 'add' );
    $uri -> query_param( domain => $domain );
    $uri -> query_param( target => $target );

    $self -> _content; # domain name

  }

=method add_cname($domain, $target)

Add DNS CNAME record effectively redirecting one domain to another

AdminLTE API: C<customcname>

AdminLTE Function: C<addCustomCNAMEEntry>

See the L<func.php|https://github.com/pi-hole/AdminLTE/blob/master/scripts/pi-hole/php/func.php> script

URL: http://localhost/admin/cname_records.php

=cut

  method remove_cname ( $domain , $target ) {

    $uri -> query_param( auth => $auth );
    $uri -> query_param( customcname => undef );
    $uri -> query_param( action => 'delete' );
    $uri -> query_param( domain => $domain );
    $uri -> query_param( target => $target );

    $self -> _content; # domain name

  }


=method remove_cname($domain, $target)

Remove DNS CNAME record

=cut

  method get_cname ( ) {
    $uri -> query_param( auth => $auth );
    $uri -> query_param( customcname => undef );
    $uri -> query_param( action => 'get' );

    $self -> _content_json -> {data};
  }

=method get_cname()

Get CNAME records as an array of two-element arrays (domain and target)

AdminLTE API: C<customcname>
AdminLTE Function: C<echoCustomDNSEntries>

=cut

}

# https://github.com/pi-hole/AdminLTE/blob/master/api.php
# https://github.com/pi-hole/AdminLTE/blob/master/scripts/pi-hole/php/func.php
