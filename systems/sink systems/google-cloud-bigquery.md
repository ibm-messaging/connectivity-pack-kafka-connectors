# Google Cloud BigQuery

The Google Cloud BigQuery sink connector sends data from Kafka topics to Google BigQuery tables by inserting, updating, or upserting records.

## Pre-requisites

- Ensure that you have a Google Cloud account and that the `BigQuery` API is enabled through the Google Cloud Console.
- Create a service account with the required roles. For more information, see [supported authentication mechanisms](#supported-authentication-mechanisms).
- Ensure that the project, dataset, and table the sink connector writes data to exist in Google BigQuery. Create them if they do not already exist.
- Ensure that your network allows connections to the Google Cloud BigQuery API endpoints.

## Connecting to Google Cloud BigQuery

The `connectivitypack.sink` and the associated `BigQuery` resource configurations in the `KafkaConnector` custom resource provide the required information to connect to Google BigQuery.

| Name                        | Value or Description |
|-----------------------------|----------------------|
| `connectivitypack.sink`     | googlebigquery       |


## Supported authentication mechanisms

You can configure the following authentication mechanism for Google Cloud BigQuery in the `KafkaConnector` custom resource:

| Authentication Type  | System Type  | Use Case | Required Credentials                                                                                                                                                                                                                                                                                                                             | `KafkaConnector` configuration                                                                                                                                                                                                                                                                                            |
|----------------------|------------- |----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Basic authentication | Google Cloud BigQuery   | Supported for basic authentication. | - `clientEmail`: The email Id of the service account associated with the Google Cloud BigQuery project.  <br> - `datasetId`: The Id of the data set from which you want to load tables dynamically. <br> - `projectId`: The Id of your Google Cloud BigQuery project.  <br>  - `privateKey`: A key used to establish the identity of the service account. | `connectivitypack.sink.authType: BASIC` <br> `connectivitypack.sink.credentials.clientEmail: <clientEmail>` <br> `connectivitypack.sink.credentials.datasetId: <datasetId>` <br> `connectivitypack.sink.credentials.projectId: <projectId>` <br> `connectivitypack.sink.credentials.privateKey: <privateKey>` |


To obtain the required credentials for connecting to Google Cloud BigQuery, complete the following steps:

1. Log in to the [Google Cloud Console](https://console.cloud.google.com/).
2. Select an existing project or click **NEW PROJECT** to create a new one.
3. Enter a project name and select the location (organization), then click **Create**.
4. On the **Getting Started** tile, click **Explore and enable APIs**, then click **+ ENABLE APIS AND SERVICES**.
5. Search for and select **BigQuery API**, then click **Manage**.
6. Click **CREDENTIALS**, then go to **Credentials in APIs & Services**.
7. Click **CREATE CREDENTIALS**, select **Service account**, and follow the on-screen instructions to create a service account.
8. Grant the following roles to the service account:
    - BigQuery Data Editor
    - BigQuery Data Owner
    - BigQuery Metadata Viewer
    - BigQuery Job User
    - Owner
    - Viewer
9. After the service account is created, click on the service account name, then go to **KEYS** > **Add key** > **Create new key**.
10. Select **JSON** as the key type, then click **CREATE**.
11. Save the generated JSON file, which contains the `clientEmail`, `projectId`,  and `privateKey` values.


## Supported objects and actions

This section describes the objects and actions that you can configure in the `KafkaConnector` custom resource.

Google Cloud BigQuery supports the following actions when processing data from Kafka topics:

| Objects | Action | Description | `KafkaConnector` configuration                                                                                                                                                                        |
|---------|--------|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| BigQuery table   | UPSERT      | Updates or inserts records into the specified BigQuery table based on `connectivitypack.sink.object.key` | `connectivitypack.sink.object: <object>` <br> `connectivitypack.sink.action: <UPSERT>` <br> `connectivitypack.sink.object.key: <One or more fields that uniquely identifies the record>`              |
|  &nbsp;  | UPDATE      | Updates records into the specified BigQuery table based on `connectivitypack.sink.object.key` | `connectivitypack.sink.object: <object>` <br> `connectivitypack.sink.action: <UPDATE>` <br> `connectivitypack.sink.object.key: <One or more fields that uniquely identifies the record>` |
|  &nbsp; | INSERT      | Inserts new records into the specified BigQuery table. | `connectivitypack.sink.object: <object>` <br> `connectivitypack.sink.action: <INSERT>`                                                                                                                |

## Single Message Transformations (SMTs)

The incoming data from Kafka topic for numeric data types must undergo the following transformations to get them inserted or updated into the Google Cloud BigQuery tables. 

| Kafka Connect schema types                         | SMTs                                                                                                                                                                | Google Cloud BigQuery data types            | 
|----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------|
| BYTES, INT8, INT16, INT32, INT64, FLOAT32, FLOAT64 | `transforms:CastFields` <br> `transforms.CastFields.type: org.apache.kafka.connect.transforms.Cast$Value` <br> `transforms.CastFields.spec: '<field-name>:string'` | INTEGER, FLOAT, NUMERIC, BIGNUMERIC, BYTES |

**Note:** The `BYTES` value must be in **Base64-encoded** format.

## Date formats
 
The following table lists the expected input formats for Google Cloud BigQuery `DATE` types. The Kafka Connect schema type must be `STRING`. Strings in ISO format are easily cast to DATE in Google Cloud BigQuery.

| Google Cloud BigQuery data types | Required format                                           | Examples                                                                                                                    | 
|---------------------------------|-----------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|
| DATE                            | `YYYY-MM-DD`                                              | `2025-04-28`. No time or timezone.                                                                                         |
| TIME                            | `HH:MM:SS` or `HH:MM:SS[.FFFFFF]`                         | `14:23:55` or `14:23:55.123456` with fractional seconds. Only the time of day, no date or timezone.                        |
| DATETIME                        | `YYYY-MM-DDTHH:MM:SS` or `YYYY-MM-DDTHH:MM:SS[.FFFFFF]`   | `2025-04-28T14:23:55` or `2025-04-28T14:23:55.123456` with fractional seconds. Date and time, but no timezone.             |
| TIMESTAMP                       | `YYYY-MM-DDTHH:MM:SSZ` or `YYYY-MM-DDTHH:MM:SS[.FFFFFF]Z` | `2025-04-28T14:23:55Z` or `2025-04-28T14:23:55.123456Z` with fractional seconds. Date, time and UTC timezone (with "**Z**" as suffix). |

## Example configuration

The following is an example of a connector configuration for Google Cloud BigQuery:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaConnector
metadata:
   labels:
      # The eventstreams.ibm.com/cluster label identifies the Kafka Connect instance
      # in which to create this connector. That KafkaConnect instance
      # must have the eventstreams.ibm.com/use-connector-resources annotation
      # set to true.
      eventstreams.ibm.com/cluster: cp-connect-cluster
   name: <name>
   namespace: <namespace>
spec:
   # Connector class name
   class: com.ibm.eventstreams.connect.connectivitypack.sink.ConnectivityPackSinkConnector

   config:
      # Which sink system to connect to
      connectivitypack.sink: googlebigquery

      # Credentials to access the sink system using BASIC authentication.
      connectivitypack.sink.authType: BASIC
      connectivitypack.sink.credentials.clientEmail: <client email>
      connectivitypack.sink.credentials.datasetId: <dataset Id>
      connectivitypack.sink.credentials.projectId: <project Id>
      connectivitypack.sink.credentials.privateKey: <private key>

      # Object and action (Supports only one object-action)
      connectivitypack.sink.object: <table name>
      connectivitypack.sink.action: <UPSERT>
      topics: <topic from which messages are consumed>

      # For UPSERT or UPDATE action
      connectivitypack.sink.object.key: <One or more fields that uniquely identifies the record>

      # Single Message Transformations (SMTs)
      transforms: 'RenameFields,FilterFields,CastFields'
      transforms.FilterFields.type: org.apache.kafka.connect.transforms.ReplaceField$Value
      transforms.RenameFields.type: org.apache.kafka.connect.transforms.ReplaceField$Value
      # Mapping of <filed name in Kafka topic record : column name in Google BigQuery Table>
      transforms.RenameFields.renames: 'first_name__c:first_name,last_name__c:last_name,date_of_birth__c:date_of_birth,gender__c:gender,email__c:email,Salary__c:salary'
      # List of fields to be excluded from upserting to the table
      transforms.FilterFields.exclude: 'Id,OwnerId,IsDeleted,CreatedDate,Name,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp'
      transforms.CastFields.type: org.apache.kafka.connect.transforms.Cast$Value
      # Casting required for numeric data types.
      transforms.CastFields.spec: 'salary:string'

   tasksMax: 1
```
