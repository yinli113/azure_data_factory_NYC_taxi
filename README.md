# Building an ADF Pipeline for Machine Learning: NYC Taxi Fare Prediction
## To enhance service quality and minimize instances of fare disputes or no-charge scenarios, taxi companies are interested in identifying potential factors that may contribute to these issues. The factors under consideration are:
### 1.	Time-Related Factors:
- 	Travel Time: The duration of the taxi trip.
- 	Day of Week: The specific day on which the trip occurs.
- 	Time of Day: The time during the day when the trip takes place.
- 	Month: The month in which the trip occurs.
- 	Year: The year in which the trip takes place.
### 2.	Non-Time-Related Factors:
- 	Additional factors that are not related to time but may influence fare disputes.
#### To analyze these factors and build a predictive model for NYC taxi fare prediction, I will use Azure Data Factory (ADF) to create a data pipeline. This pipeline will:
- 	Transform the Data: Process and prepare the raw data by applying necessary transformations to extract and compute the relevant factors.
- 	Load the Data: Store the transformed data into an Azure SQL Database, making it ready for further analysis and machine learning model training.
#### This approach will enable taxi companies to better understand the underlying causes of fare disputes and improve their overall service quality through predictive analytics

## Steps to build pipeline :
### Step 1: building pipeline 
##### 1)	Green_tripdata_pipeline
I have multiple Parquet files stored in Azure Blob Storage that need to be ingested into Azure Data Lake Storage Gen2. To efficiently load these files, you can use Azure Data Factory (ADF) with the following activities: Get Metadata, ForEach, and Copy.
To set up the pipeline in Azure Data Factory (ADF) for loading multiple Parquet files into the data lake, follow these steps:
Step 1: Retrieve File Metadata
1.	Get Metadata Activity:
o	Use the Get Metadata activity to fetch the list of Parquet files available in the Azure Blob Storage container.
o	Configure the Field list property to include Child Items to retrieve all files within the specified folder.
Step 2: Iterate Over Files
2.	ForEach Activity:
o	Add a ForEach activity to loop through the list of files obtained from the Get Metadata activity.
o	Within the ForEach activity, reference each file’s name dynamically (e.g., green_tripdata_2023_01.parquet, green_tripdata_2023_02.parquet, etc.).
Step 3: Copy Files to Data Lake
3.	Copy Activity:
o	Inside the ForEach activity, add a Copy activity to transfer each Parquet file from the Azure Blob Storage container to the Azure Data Lake Storage Gen2.
o	In the Source settings of the Copy activity, dynamically set the file path using the file name obtained from the ForEach activity.
o	Configure the Destination settings to specify where in the data lake each file should be stored (e.g., organize files by year and month in a structured folder format).
Summary of Pipeline Steps:
•	Get Metadata Activity: Retrieves the list of Parquet files from Azure Blob Storage.
•	ForEach Activity: Iterates over each file in the list.
•	Copy Activity: Copies each Parquet file from Blob Storage to the Data Lake.
This approach is both efficient and scalable, making it well-suited for handling large volumes of files. Additionally, ensure that the pipeline is configured to manage potential issues, such as missing files or errors during the copy process.

#### 2)	All_raw_data_files
By uploading the JSON file (all_raw_files.json) from Blob Storage to data lake, I use the following steps in Azure Data Factory (ADF):
all_raw_files.json:
[
    {
        "sourceFileName":"rate_code.json",
        "sinkFileName":"rate_code.csv"
    },
    {
        "sourceFileName":"payment_type.json",
        "sinkFileName":"payment_type.csv"
    },

    {
        "sourceFileName":"taxi_zone.csv",
        "sinkFileName":"taxi_zone.csv"
    },
    {
        "sourceFileName":"trip_type.tsv",
        "sinkFileName":"trip_type.csv"
    },
    {
        "sourceFileName":"vendor.csv",
        "sinkFileName":"vendor.csv"
    }
]


1.	Upload all_raw_files.json to Blob Storage: Store the JSON file in a Blob Storage container.
2.	Use a Lookup Activity:
o	The Lookup Activity will read the content of the all_raw_files.json file.
o	Ensure that the Lookup Activity is configured to output all rows (by setting the First Row Only property to false).
3.	Configure a ForEach Activity:
o	Connect the output of the Lookup Activity to the ForEach Activity.
o	Inside the ForEach Activity, iterate over each item in the JSON array (i.e., each file mapping).
4.	Use a Copy Activity within the ForEach loop:
o	Configure the source of the Copy Activity to read the file specified by the sourceFileName field.
o	Set the sink of the Copy Activity to the target location in your Data Lake, using the sinkFileName field to define the output file name.
This approach allows  dynamically loading the specified files from Blob Storage into Data Lake using the Copy Activity within a loop. 

________________________________________
Step 2: Data Transformation
Once the files are ingested, you can perform data transformation using ADF with the following steps:
1.	Add Data Source:
o	Start by adding the ingested Parquet files as the data source.
2.	Select Transformation:
o	For this pipeline, focus on time-related factors by selecting the following columns: VendorID, Ipep_pickup_datetime, Ipep_dropoff_datetime, tip_amount, and total_amount.
3.	Derived Column Transformation:
o	Generate new columns using the existing Ipep_dropoff_datetime column:
	Year: Extract the year from Ipep_dropoff_datetime.
	Month: Extract the month from Ipep_dropoff_datetime.
	Day of Week: Extract the day of the week from Ipep_dropoff_datetime.
	Time of Day: Extract the time of day from Ipep_dropoff_datetime.
4.	Derived Column and Aggregate Transformation:
o	Create a new column called duration_minutes, calculated as (Ipep_dropoff_datetime - Ipep_pickup_datetime) / 60000.
5.	Conditional Split Transformation:
o	Split the dataset into two subsets based on the VendorID value:
	Dataset 1: VendorID = 1
	Dataset 2: VendorID = 2
6.	Sorting Transformation:
o	Sort the data by dayOfWeek, timeOfDay, and duration_minutes columns.
7.	Sink Transformation:
o	Load the transformed data into an Azure SQL Database as the final destination.
