source(output(
		VendorID as long,
		lpep_pickup_datetime as timestamp,
		lpep_dropoff_datetime as timestamp,
		store_and_fwd_flag as string,
		RatecodeID as double,
		PULocationID as long,
		DOLocationID as long,
		passenger_count as double,
		trip_distance as double,
		fare_amount as double,
		extra as double,
		mta_tax as double,
		tip_amount as double,
		tolls_amount as double,
		ehail_fee as integer,
		improvement_surcharge as double,
		total_amount as double,
		payment_type as double,
		trip_type as double,
		congestion_surcharge as double
	),
	allowSchemaDrift: true,
	validateSchema: false,
	ignoreNoFilesFound: false,
	format: 'parquet') ~> LandingSourceGreenTripdata
LandingSourceGreenTripdata select(mapColumn(
		VendorID,
		lpep_pickup_datetime,
		lpep_dropoff_datetime,
		tip_amount,
		total_amount
	),
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true) ~> dropSomeColumns
dropSomeColumns derive(year = year(lpep_pickup_datetime),
		month = month(lpep_pickup_datetime),
		dayofWeek = dayOfWeek(lpep_pickup_datetime),
		timeofDay = toString(lpep_pickup_datetime, 'HH:mm:ss')) ~> deriveFromIpeppickupdatetime
deriveFromIpeppickupdatetime derive(duration_minutes = (lpep_dropoff_datetime - lpep_pickup_datetime)/60000) ~> getDuration
getDuration split(VendorID == 1,
	disjoint: false) ~> splitOnVendor@(CreativeMobileTechnolog, VeriFone)
splitOnVendor@CreativeMobileTechnolog sort(asc(dayofWeek, true),
	asc(timeofDay, true),
	asc(duration_minutes, true)) ~> sortTime
splitOnVendor@VeriFone sort(asc(dayofWeek, true),
	asc(dayofWeek, true),
	asc(timeofDay, true),
	asc(duration_minutes, true)) ~> sortTimeWeriFone
sortTime sink(allowSchemaDrift: true,
	validateSchema: false,
	format: 'parquet',
	umask: 0022,
	preCommands: [],
	postCommands: [],
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true) ~> sinkToVendor1
sortTimeWeriFone sink(allowSchemaDrift: true,
	validateSchema: false,
	format: 'parquet',
	umask: 0022,
	preCommands: [],
	postCommands: [],
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true) ~> sinkToVendor2