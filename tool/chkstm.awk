BEGIN {	
}
{
	cmd = "onstat -g ses | grep "$2" | nawk -F ' ' '{ if ( $4 == "$2" ) print $0; }'";
	cmd | getline sesline;
	close( cmd );
	split( sesline, sid );
	# Session ID´Â sid[ 1 ]
	
	cmd = "onstat -g stm "sid[ 1 ];
	stm_start = 0;
	heapsz = 0;
	while ( cmd | getline stminfo ) {
		split( stminfo, stm );
		if ( stm[ 1 ] == "session" ) {
			print stminfo;
			stm_start = 1;
		} else if ( stm[ 1 ] == "" ) {
		} else if ( stm_start ) {
			printf( "%15s  %12s  %s %s %s %s %s %s\n", stm[ 1 ], stm[ 2 ], stm[ 3 ], stm[ 4 ], stm[ 5 ], stm[ 6 ], stm[ 7 ], stm[ 8 ] );
			heapsz += stm[ 2 ];
		}
	}
	print "                 ------------";
	printf( "%29s\n", heapsz );
	print "===============================================================================";
	close( cmd );
}
END {
	print "End"
}
