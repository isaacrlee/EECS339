#!/usr/bin/perl -w

use DBI;
use Geo::Coder::US;

$user="cs339";
$passwd="cs339";


Geo::Coder::US->set_db( "/raid/pdinda/Pol/geocoder.db" );

$dbh = DBI->connect("DBI:Oracle:",$user,$passwd) or die "Can't connect\n";



#
# generation begins with committee master table
#
print "Handling committee_master\n"; 
# clean out the current table
$statement = "delete from cmte_id_to_geo";
$sth = $dbh->prepare($statement) or die "Can't prepare delete on cmte_id_to_geo\n";
$sth->execute() or die "Can't execute delete on cmte_id_to_geo\n";
$sth->finish();
$statement = "select CMTE_ID, CMTE_ST1, CMTE_ST2, CMTE_CITY, CMTE_ST,
CMTE_ZIP from committee_master";
$sth = $dbh->prepare($statement) or die "Can't prepare select from
committee_master\n";
$sth->execute() or die "Can't execute select from committee_master\n";
($recs, $decs) = Handle($sth,"cmte_id_to_geo","CMTE_ID",); 
$sth->finish();
print "$recs records in, $decs geolocs committed\n";

#
# generation continues with candidate master table
#
# clean out the current table
$statement = "delete from cand_id_to_geo";
$sth = $dbh->prepare($statement) or die "Can't prepare delete on cand_id_to_geo\n";
$sth->execute() or die "Can't execute delete on cand_id_to_geo\n";
$sth->finish();
$statement = "select CAND_ID, CAND_ST1, CAND_ST2, CAND_CITY, CAND_ST,
CAND_ZIP from candidate_master";
$sth = $dbh->prepare($statement) or die "Can't prepare select from
candidate_master\n";
$sth->execute() or die "Can't execute select from candidate_master\n";
print "Handling candidate_master\n"; 
($recs, $decs) = Handle($sth,"cand_id_to_geo","CAND_ID"); 
$sth->finish();
print "$recs records in, $decs geolocs committed\n";


#
# generation continues with individual contributions
#
# clean out the current table
$statement = "delete from ind_to_geo";
$sth = $dbh->prepare($statement) or die "Can't prepare delete on ind_to_geo\n";
$sth->execute() or die "Can't execute delete on ind_to_geo\n";
$sth->finish();
$statement = "select SUB_ID, ' ', ' ', CITY, STATE, ZIP_CODE from individual";
$sth = $dbh->prepare($statement) or die "Can't prepare select from indvidual\n";
$sth->execute() or die "Can't execute select from individual\n";
print "Handling individual\n"; 
($recs, $decs) = Handle($sth,"ind_to_geo","SUB_ID"); 
$sth->finish();
print "$recs records in, $decs geolocs committed\n";






sub Handle  {
  my ($sth,$table,$col) = @_;
  my ($recs,$decs);
  my @data;
  my ($id,$st1,$st2,$city,$state,$zip);
  my ($lat, $long);
  my $insert;
  my $insertsth;

  $recs=0;
  $decs=0;

  while ((@data=$sth->fetchrow_array()) ) {
    $recs++;

    ($id,$st1,$st2,$city,$state,$zip)=@data;

    ($lat, $long) = Search($id,$st1,$st2,$city,$state,$zip);

    next if (!defined($lat) || !defined($long));

    $insert = "insert into $table($col,latitude,longitude) values (?,?,?)";

    $insertsth = $dbh->prepare($insert) or die "Can't prepare insert for $table\n";

    $insertsth->execute($id,$lat,$long)  or die "Can't execute insert for $table\n";

    $insertsth->finish();

    $decs++;
  }

  return ($recs,$decs);
}



  

sub Search {
  my ($id,$st1,$st2,$city,$state,$zip) = @_;
  my $try;
  my @matches;
  my $m;
  my $addr;
  my %adx;
 
  $try=0;


  while ($try<7) { 
    
    if ($try==0) { 
      $addr=join(" ",grep {defined($_)} ($st1,$st2,$city,$state,$zip)); 
    }
    if ($try==1) { 
      $addr=join(" ",grep {defined($_)} ($st1,$city,$state,$zip));
    }
    if ($try==2) { 
      $addr=join(" ",grep {defined($_)} ($st2,$city,$state,$zip));
    }
    if ($try==3) { 
      $addr=join(" ",grep {defined($_)} ($city, $state, $zip)); 
    }
    if ($try==4) { 
      $addr=join(" ",grep {defined($_)} ($state, $zip));
    }
    if ($try==5) { 
      $addr=join(" ",grep {defined($_)} ($zip)); 
    }
    if ($try==6) { 
      $addr="10 main street, $city, $state, $zip"; 
    }
    
    print STDERR "Geocoding $id ($try): $addr: ";
    @matches = Geo::Coder::US->geocode_address($addr);
    if ($#matches<0 || !defined($matches[0]->{lat}) || !defined($matches[0]->{long})) { 
      if ($#matches<0) { 
	print STDERR "Can't parse\n";
      } else {
	print STDERR "Can't match\n";
      }
      $try++;
    } else {
      print STDERR $#matches+1, " Matches found:";
      foreach $m (@matches) { 
	print STDERR " (",$m->{lat}, ", ", $m->{long},")";
      }
      print STDERR "\n";
      return ($matches[0]->{lat},$matches[0]->{long});
    }
  }

  # Now try again using our own parse...

  $adx{city} = $city;
  $adx{state} = $state;
  $adx{zip} = substr($zip,0,5);


  print STDERR "Geocoding $id (decoded): city=$city, state=$state, zip=$zip ";
  @matches = Geo::Coder::US->lookup_ranges(\%adx);
  if ($#matches<0 || !defined($matches[0]->{lat}) || !defined($matches[0]->{long})) { 
    if ($#matches<0) { 
      print STDERR "Can't parse\n";
    } else {
      print STDERR "Can't match\n";
    }
  } else {
    print STDERR $#matches+1, " Matches found:";
    foreach $m (@matches) { 
      print STDERR " (",$m->{lat}, ", ", $m->{long},")";
    }
    print STDERR "\n";
    return ($matches[0]->{lat},$matches[0]->{long});
  }
  
  return (undef,undef);
  
}




BEGIN {
  unless ($ENV{BEGIN_BLOCK}) {
    $ENV{ORACLE_BASE}="/raid/oracle11g/app/oracle/product/11.2.0.1.0";
    $ENV{ORACLE_HOME}=$ENV{ORACLE_BASE}."/db_1";
    $ENV{ORACLE_SID}="CS339";
    $ENV{LD_LIBRARY_PATH}=$ENV{ORACLE_HOME}."/lib";
    $ENV{BEGIN_BLOCK} = 1;
    exec 'env',$0,@ARGV;
  }
}
