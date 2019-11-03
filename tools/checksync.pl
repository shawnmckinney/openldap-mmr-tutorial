#!/usr/bin/perl
#check-sync.pl
# Improved version of verify-sync.sh; Gives delta time of replica CSN values, and allows easier comparison

use Net::LDAP;
use Time::Local qw(timegm);

my $DEBUG  = 0;
my $TSONLY = 0;

my $ldapver  = 3;
my $ldapbase = "dc=example,dc=com";
my $ldapport = 389;

my %servers = (
	DEV => {
		hosts    => [ "", "" ],
		user     => "cn=manager,dc=example,dc=com",
		password => ""
	},
	TEST => {
		hosts    => [ "", "" ],
		user     => "cn=manager,dc=example,dc=com",
		password => ""
	},
	QC => {
		hosts    => [ "", "" ],
		user     => "cn=manager,dc=example,dc=com",
		password => ""
	},
	PROD => {
		hosts    => [ "", "" ],
		user     => "cn=manager,dc=example,dc=com",
		password => ""
	},
);

# Main Logic
my %contextHash;    # our hash hashs of rids=>hosts=>ts
my $env = $ARGV[0];
if ( defined $ARGV[1] ) { $TSONLY = $ARGV[1]; }

print "Replication Checker -- ContextCSN values:\n";

# Loop through all hosts in environment, and query for contextCSNs attributes.
for $host ( @{ $servers{$env}{'hosts'} } ) {
	my $searchstr = "";
	my @attribs   = ('contextCSN');
	my $ldap      = Net::LDAP->new( $host, port => $ldapport ) or die "$@\n";
	$ldap->bind(
		$servers{$env}{'user'},
		password => $servers{$env}{'password'},
		version  => $ldapver
	) or die "$@\n";
	my $search = $ldap->search(
		base   => $ldapbase,
		scope  => 'base',
		filter => '(objectClass=*)',
		attrs  => ['contextCSN'],
	);
	my $entry = $search->entry(0);

	# Looping through each ContextCSN entry on one host
	foreach ( $entry->get_value('contextCSN') ) {
		my @csn = &parse_csn($_);
		print "DEBUG: $host ContextCSN: $_\n" if $DEBUG;

# unchecked scenario here: if we have >1 RID's with unique timestamps. should be impossible though
#
# CONTINUE HERE 6/29 -- THIS IS NOT FUNCTIONAL
		$contextHash{ $csn[1] }{$host} = $csn[0];
		print "DEBUG: Added contextHash{$csn[1]} = { $host => $csn[0] }\n"
		  if $DEBUG;
	}
	$ldap->unbind;
	$ldap->disconnect;
}

# print out our table of timestamps
printf "|%4s", "RID";
my $hostcount = 0;
foreach $host ( @{ $servers{$env}{'hosts'} } ) {
	if (   $host eq "tparheansp003"
		|| $host eq "tpaqwam01"
		|| $host eq "tpatwam01" )
	{
		printf "|%16s", "Oldsmar Master";
	}
	elsif ( $host eq "cvgrheansp013" || $host eq "cvgqwam01" ) {
		printf "|%16s", "CBTS Master";
	}
	else { printf "|%16s", $host; }
	$hostcount++;
}

my $OutOfSync = 0;    # Begin with OutOfSync false
for $rid ( sort keys %contextHash ) {
	printf "|\n|%4s", $rid;
	$hostcount = 0;
	my $masterts;     # Only one masterTS per RID, so reset each loop.
	foreach $host ( @{ $servers{$env}{'hosts'} } ) {

# If local RID, or TimeStamps Only - Print TS alone, no deltas and iterate to next host in loop
		if ( $rid eq "000" || $TSONLY ) {
			printf "|%16s", $contextHash{$rid}{$host};
			$hostcount++;
			next;
		}
		if ( $hostcount == 0 ) {

			# Treat first server as our "origin" or master, and print TS
			$masterts = $contextHash{$rid}{$host};
			printf "|%16s", $contextHash{$rid}{$host};
		}

		# Not origin or local RID? Perform delta time
		else {
			my $localts = $contextHash{$rid}{$host};
			my ( $year1, $month1, $day1, $hour1, $min1, $sec1 ) = ( $masterts =~ m/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/ );
			my ( $year2, $month2, $day2, $hour2, $min2, $sec2 ) = ( $localts =~ m/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/ );
			my $t1 = timegm( $sec1, $min1, $hour1, $day1, $month1, $year1 );
			my $t2 = timegm( $sec2, $min2, $hour2, $day2, $month2, $year2 );
			printf "|%15ss", $t1 - $t2;
			if ( ( $masterts - $localts ) != 0 ) {
				$OutOfSync = 1;
			}    # If we ever detect out of sync, flag it as true
		}
		$hostcount++;
	}
}
print "|\n";
if ($OutOfSync) {
	die "Replication Out Of Sync! Review ContextCSNs for more details.\n";
}

###################################
# End main logic, nothing but subs below this line!   #

sub parse_csn {
	my ($csn) = @_;
	my ( $utime, $mtime, $count, $sid, $mod ) =
	  ( $csn =~ m/(\d{14})\.?(\d{6})?Z#(\w{6})#(\d{2,3})#(\w{6})/g );
	print "DEBUG: Parse $csn into $utime - $count - $sid - $mod\n" if $DEBUG;
	return ( $utime, $sid );
}

