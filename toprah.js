#!/usr/bin/env node

// import modules
const _ = require( "lodash" );
const exec = require( "child_process" ).exec;
const fs = require( "fs" );
const printf = require( "printf" );

// constant
const PAGESIZE = 4096;			// Page Size 4K (Set according to your environment)

// Code Table ( <= setCodes() )
let code_lockmode = {};			// Describes the type of lock being held using one or more of the following coded values:
let code_op_flags = {};			// Describes the current status of the partition using a combination of the following hexadecimal values:
let code_op_mode = {};			// Describes the current status of the partition lock mode using a combination of the following hexadecimal values:
// Note the output of the command ( <= setCodes() )
let onstat_g_opn = {};
let onstat_g_rah = {};
let onstat_g_ses = {};

// from .unl file ( <= _getSysTabNames() )
let systabnames = {};			// partnum information (key: partnum, value: { dbname, tablename })

// List of partnums with read ahead information ( <= getRah() )
let rahList = [];

// inspect arguments
let interval = process.argv[ 2 ] ? ( parseInt( process.argv[ 2 ] ) || 10 ) : 10;			// Interval to get read ahead information (sec)
let topCount = process.argv[ 3 ] ? ( parseInt( process.argv[ 3 ] ) || 30 ) : 30;			// # of Read Ahead Top Tables
let sortBy = process.argv[ 4 ] !== "b" ? "diskReads" : "bufferReads";						// Sort by (b: bufferReads, others: diskReads)

console.log( "-------------------------------------------------------------------------------------------------------------------" );
console.log( "   READ AHEAD Top Table List\n" );
console.log( "   Usage : toprah.js [ check interval (sec) ] [ number of tables ] [ sort by d(diskReads) | b(bufferReads) ]" );
console.log( "   Unit of data size : Byte" );
console.log( "-------------------------------------------------------------------------------------------------------------------" );

// Let's get it~!!
_main().then().catch();



/* ---------------------------------------------------------------
 * Functions
 * --------------------------------------------------------------- */
// main
async function _main() {
	try {
		// Define Code Tables
		setCodes();

		// Create partnum information object by reading systabnames.unl
		await _getSysTabNames();		// => systabnames

	} catch( err ) {
		console.log( err );
	}

	// get list of partnums with read ahead information
	getRah();

	// Timer
	let timer = function( left ) {
		setTimeout( () => {
			// make newline for counter display
			if ( left === interval ) {
				console.log( "" );
			}

			// Move up one line
			process.stdout.write( `\u001b[1A` );

			// Get information at the end of the counter
			if ( --left < 1 ) {
				console.log( `   Countdown : ${left} / ${interval}    ` );
				// Finally get list of partnums with read ahead information
				getRah( true );

			// Remaining time display
			} else {
				console.log( `   Countdown : ${left} / ${interval}    ` );
				timer( left );
			}
		}, 1000 );
	};
	timer( interval );
}


// Define Code Tables
function setCodes() {
	// Describes the type of lock being held using one or more of the following coded values:
	code_lockmode = {
		"0"			: "No locks",
		"1"			: "Byte lock",
		"2"			: "Intent shared",
		"3"			: "Shared",
		"4"			: "Shared lock by RR",
		"5"			: "Update",
		"6"			: "Update lock by RR",
		"7"			: "Intent exclusive",
		"8"			: "Shared, intent exclusive",
		"9"			: "Exclusive",
		"10"			: "Exclusive lock by RR",
		"11"			: "Inserter's RR test"
	};


	// Describes the current status of the partition using a combination of the following hexadecimal values:
	code_op_flags = {
		"0x0001"		: "Open struct in use",
		"0x0002"		: "Current position exists",
		"0x0004"		: "Current record has been read",
		"0x0008"		: "Duplicate created or read",
		"0x0010"		: "Set when rsstart is called with mode != ISLAST",
		"0x0020"		: "Shared blob info",
		"0x0040"		: "Partition opened for rollback",
		"0x0080"		: "Stop key has been set",
		"0x0100"		: "No index related read aheads",
		"0x0200"		: "isstart called for current stop key",
		"0x0400"		: "openp pseudo-closed",
		"0x0800"		: "real partition opened for SMI",
		"0x1000"		: "Read ahead of parent node is done",
		"0x2000"		: "UDR keys loaded : free in opfree",
		"0x4000"		: "Open is for a pseudo table"
	};


	// Describes the current status of the partition lock mode using a combination of the following hexadecimal values:
	code_op_mode = {
		"0x00000"	: "Open for input only",
		"0x00001"	: "Open for output only",
		"0x00002"	: "Open for input and output",
		"0x00004"	: "Open for transaction proc",
		"0x00008"	: "No logical logging",
		"0x00010"	: "Open if not already opened for alter",
		"0x00020"	: "Open all fragments data and index",
		"0x00040"	: "Don't allocate op_blob struct",
		"0x00080"	: "Open for alter",
		"0x00100"	: "Open all data fragments",
		"0x00200"	: "Automatic record lock",
		"0x00400"	: "Manual record lock",
		"0x00800"	: "Exclusive ISAM file lock",
		"0x01000"	: "Ignore dataskip - data can't be ignored",
		"0x02000"	: "Dropping partition - delay file open",
		"0x04000"	: "Don't drop blobspace blobs when table dropped",
		"0x08000"	: "Open table at datahi",
		"0x10000"	: "Open table for DDL operations",
		"0x20000"	: "(Only B1)",
		"0x40000"	: "Don't assert fail if partnum doesn't exist",
		"0x80000"	: "Include fragments of subtables",
		"0x10000"	: "Table created under supertable",
		"0x20000"	: "Allow sbspace to call rspnbuild",
		"0x40000"	: "Blob in use by CDR"
	};


	// 이 아래는 참고용 -------------------------------------------------------------------------------
	// onstat -g opn
	onstat_g_opn = {
		"tid"						: "The thread ID currently accessing the partition resource (table/index).	Dec	(see also : onstat -g ath)",
		"rstcb"					: "The in-memory address of the rsam thread control block for this thread.	Hex",
		"isfd"					: "ISAM file descriptor associated with the open partition.	Dec",
		"op_mode"				: "Describes the current status of the partition lock mode using a combination of the following hexadecimal values: Hex",
		"op_flags"				: "Describes the current status of the partition using a combination of the following hexadecimal values: Hex",
		"partnum"				: "Partition number for the open resource (table/index).	Hex",
		"ucount"					: "The number of user threads currently accessing this partition.	Dec",
		"ocount"					: "The number of times this partition was opened.	Dec",
		"lockmode"				: "Describes the type of lock being held using one or more of the following coded values: Dec"
	};


	// onstat -g rah
	onstat_g_rah = {
		"# threads"				: "Number of read-ahead threads",
		"# Requests"			: "Number of read-ahead requests",
		"# Continued"			: "Number of times a read-ahead request continued to occur",
		"# Memory Failures"	: "Number of failed requests because of insufficient memory",
		"Q Depth"				: "Depth of request queue",
		"Last Thread Add"		: "Date and time when the last read-ahead thread was added",
		"Partnum"				: "Partition number",
		"Buffer reads"			: "Number of bufferpool and disk pages that were read",
		"Disk Reads"			: "Number of pages that were read from disk",
		"Hit Ratio"				: "Cache hit ratio for the partition",
		"# Reqs"					: "Number of data page read ahead requests.",
		"Eff"						: "Efficiency of the read-ahead requests. This is the ratio been the number of pages requested by read-ahead operations to the number of pages that were already cached and for which a read-ahead operations was not needed. Values are between 0 and 100. A higher number means that read ahead is beneficial."
	};


	// onstat -g ses
	onstat_g_ses = {
		"Output Description"	: {
			"session id"			: "The session ID.	Dec	(see also : onstat -u)",
			"user"					: "The username who started this session.	Str",
			"tty"						: "The tty associated with the front-end for this session.	Str",
			"pid"						: "The process ID associated with the front-end for this session.	Dec",
			"hostname"				: "The hostname from which this session has connected.	Str",
			"#RSAM threads"		: "The number of RSAM threads allocated for this session.	Dec",
			"total memory"			: "The amount of memory allocated for this session.	Dec",
			"used memory"			: "The amount of memory actually used by this session.	Dec"
		},

		"Thread Status"		: {
			"Heading"				: "Description	Format	See Also",
			"tid"						: "The thread ID	Dec",
			"name"					: "The name of the thread	Str",
			"rstcb"					: "The in-memory address of the RSAM thread control block	Hex",
			"flags"					: {
				"desc"					: "Describes the status of the thread using the following coded values: 	Str	(see also : onstat -u)",
				"Position_1"			: {
					"B"						: "Waiting on a buffer",
					"C"						: "Waiting on a checkpoint",
					"G"						: "Waiting on write of the Logical Log buffer",
					"L"						: "Waiting on a lock",
					"S"						: "Waiting on a mutex",
					"T"						: "Waiting on a transaction",
					"X"						: "Waiting on a transaction cleanup",
					"Y"						: "Waiting on a condition"
				},
				"Position_2"			: "An asterisk means the thread had an I/O problem during a transaction",
				"Position_3"			: {
					"A"						: "DBSpace backup thread",
					"B"						: "Begin work",
					"C"						: "Commiting/committed",
					"H"						: "Heuristic aborting/aborted",
					"P"						: "Preparing/prepared",
					"R"						: "Aborting/aborted",
					"X"						: "XA prepare"
				},
				"Position_4"			: {
					"P"						: "Primary thread for a session"
				},
				"Position_5"			: {
					"R"						: "Reading (RSAM Call)",
					"X"						: "Critical Write"
				},
				"Position_6"			: {
					"R"						: "Recovery thread"
				},
				"Position_7"			: {
					"B"						: "BTree clean thread",
					"C"						: "Terminated user thread waiting for    cleanup",
					"D"						: "Daemon thread",
					"F"						: "Page cleaner thread (flusher)",
					"M"						: "On-Monitor thread"
				}
			},
			"curstk"					: "The current stack size	Bytes",
			"status"					: "The current status of the thread	Str	(see also : onstat -g con)"
		},

		"Memory Pool Status"	: {
			"name"					: "The name of the pool.	Str	(see also : onstat -g mem)",
			"class"					: "The shared memory segment type in which the pool has been created (R, V, or M).	Str	(see also : onstat -g seg)",
			"addr"					: "The in-memory address of the pool.	Hex",
			"totalsize"				: "The total size of the pool in bytes.	Dec",
			"freesize"				: "The number of bytes of free memory within this pool.	Bytes",
			"#allocfrag"			: "The number of allocated fragments within this pool.	Dec",
			"#freefrag"				: "The number of free fragments within this pool.	Dec"
		},

		"Memory Pool Breakdown": {
			"name"					: "The name of the pool.	Str	(see also : onstat -g mem)",
			"free"					: "The number of bytes available	Dec",
			"used"					: "The number of bytes used	Dec"
		},

		"sqscb Info Section"	: {
			"scb"						: "The session control block. This is the address of the main session structure in shared memory	Dec",
			"sqscb"					: "SQL level control block of the session	Dec",
			"optofc"					: "The current value of the OPTOFC environment variable or ONCONFIG configuration file setting	Int",
			"pdqpriority"			: "The current value of the PDQPRIORITY environment variable or ONCONFIG configuration file setting	Int",
			"optcompind"			: "The current value of the OPTCOMPIND environment variable or ONCONFIG configuration file setting	Int",
			"directives"			: "The current value of the DIRECTIVES environment variable or ONCONFIG configuration file setting	Int"
		}
	};
}


// Create partnum information object by reading systabnames.unl
async function _getSysTabNames() {
	return new Promise( ( resolve, reject ) => {
		try {
			fs.readFile( "./systabnames.unl", "utf8", ( err, data ) => {
				if ( err ) throw err;

				_.each( data.split( "\n" ), line => {
					let part = line.split( "|" );
					systabnames[ part[ 0 ] ] = {							// key: partnumInt
						dbname		: part[ 1 ],
						tablename	: part[ 3 ]
					};
				});

				console.log( "   systabnames.unl loaded." );
				resolve();
			});

		} catch( err ) {
			reject( err );
		}
	});
}


// get list of partnums with read ahead information(onstat -g rah)
function getRah( final=false ) {
	exec( `onstat -g rah`, { maxBuffer: 10 * 1024 * 1024 /* 10M */ }, ( err, stdout, stderr ) => {
		// stderr of cmd
		if ( !!stderr ) {
			console.log( "---------- stderr ----------" );
			console.log( stderr );

		// stdout of cmd
		} else if ( !err ) {
			try {
				let day = new Date();
				let time = day.getTime();
				let isData = false;											// Header lines = false, Data lines = true
				let rah = {														// output of onstat -g rah
					time	: time,
					data	: {}
				};
				rahList.push( rah );
				let stdoutArr = stdout.split( "\n" );					// stdout lines {array}

				console.log( `   getting rah at ${time} = ${day}` );

				_.each( stdoutArr, ( line, index ) => {
					// Data 처리
					if ( isData && !line.match( /^$/ ) ) {				// Data lines (Includes removal of blank lines that appear at the end of data)
						let cols = line.split( /\s+/ );
						rah.data[ parseInt( cols[ 0 ] ) ] = {			// key: Partnum(Hex to Integer)
							partnum		: cols[ 0 ],						// partnum Hex
							bufferReads	: parseInt( cols[ 1 ] ),
							diskReads	: parseInt( cols[ 2 ] )
						};

					// Information is displayed from the next line.
					} else if ( line.match( /Partnum/ ) ) {
						isData = true;
					}
				});

				// get tables with high read ahead
				if ( final ) {
					getTopRah();
				}

			} catch( e ) {
				console.log( "---------- ERROR when processing stdout ----------" );
				console.log( e );
			}

		// error of exec
		} else {
			console.log( "---------- exec ERROR ----------" );
			console.log( err );
		}
	});
}


// get tables with high read ahead
function getTopRah() {
	if ( rahList.length < 2 ) {
		console.log( "[ERROR] Failure to obtain Rah information" );
		return false;
	}

	let unsortedResult = [];												// Store increments of Rah information only included in both checks
	let index = rahList.length - 1;
	let prev = rahList[ index - 1 ].data;								// The Rah information right before

	// Loop with information just before : Store increments of Rah information only included in both checks
	_.each( rahList[ index ].data, ( reads, partnumInt ) => {
		// If included in the previous information
		if ( _.has( prev, partnumInt ) ) {
			unsortedResult.push({
				partnum		: reads.partnum,
				partnumInt	: partnumInt,
				dbname		: _.at( systabnames, `${partnumInt}.dbname` )[ 0 ] || "",
				tablename	: _.at( systabnames, `${partnumInt}.tablename` )[ 0 ] || "",
				bufferReads	: reads.bufferReads - prev[ partnumInt ].bufferReads,		// BufferReads during the interval
				diskReads	: reads.diskReads - prev[ partnumInt ].diskReads			// diskReads during the interval
			});
		}
	});

	// Sort Read Ahead informiation
	let sortedResult = _.reverse( _.sortBy( unsortedResult, [ sortBy, "dbname", "tablename" ] ) );

	// Result output
	let result = printf(
		"-------------------------------------------------------------------------------------------------------------------\n"+
		"%10s    %10s    %15s    %15s   %16s   %s\n"+
		"-------------------------------------------------------------------------------------------------------------------\n",
		"partnumHex", "partnumInt", "diskReads", "bufferReads", "DBName", "TableName" );
	for ( let i = 0; i < ( topCount > sortedResult.length ? sortedResult.length : topCount ); i++ ) {
		result += printf(
			"%10s    %10d    %15s    %15s   %16s   %s\n",
			sortedResult[ i ].partnum,
			sortedResult[ i ].partnumInt,
			commify( sortedResult[ i ].diskReads * PAGESIZE ),
			commify( sortedResult[ i ].bufferReads * PAGESIZE ),
			sortedResult[ i ].dbname,
			sortedResult[ i ].tablename );
	}
	result += "-------------------------------------------------------------------------------------------------------------------\n";
	console.log( result );
}




/* ---------------------------------------------------------------
 * Utility
 * --------------------------------------------------------------- */
// Comma a number in thousands
// param num {number} number
// return {string} Comma number in thousands / false (When input is wrong)
function commify( num ) {
	// Allowed input (considered as)
	if ( typeof num === "string" || typeof num === "number" ) {
		let reg = /(^[+-]?\d+)(\d{3})/;
		num += "";

		while ( reg.test( num ) ) {
			num = num.replace( reg, "$1" + "," + "$2" );
		}

		return num;

	// When input is wrong
	} else {
		return false;
	}
}