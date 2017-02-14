#!/usr/bin/perl -w

use Geo::Coder::US;

$#ARGV>=0 or die "Not enough args\n";

$addr = join(" ", @ARGV);

Geo::Coder::US->set_db( "/raid/pdinda/Pol/geocoder.db" ) or die "Don't have db\n";

@matches = Geo::Coder::US->geocode($addr);

print "Addr: ",$addr,"\n";
foreach $m (@matches) {
  print "Lat:  ",$m->{lat},"\nLong: ",$m->{long},"\n";
}


