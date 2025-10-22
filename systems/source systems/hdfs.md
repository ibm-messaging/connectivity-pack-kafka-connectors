# HDFS

The connector enables streaming data from the Hadoop Distributed File System (HDFS) to Kafka topics. You can use this connector to capture both existing and newly added content from CSV files in a specified HDFS folder and publish them as messages to Kafka topics.

## Pre-requisites

- Ensure you have access to an HDFS instance with the required permissions.
- Ensure Kerberos authentication is configured and you have a valid principal and keytab file.
- Ensure your network allows connections to the HDFS endpoint and Key Distribution Center (KDC) server.

## Connecting to HDFS

The `connectivitypack.source` and related configurations in the `KafkaConnector` custom resource provide the connector with the required information to connect to the HDFS data source.


| **Name**                      | **Value or Description**                                                                                                       |
| ----------------------------- |--------------------------------------------------------------------------------------------------------------------------------|
| `connectivitypack.source`     | `hdfs`                                                                                                                         |
| `connectivitypack.source.endpoint.kdcServer` | Specifies the Kerberos KDC server host name. Required when Kerberos authentication is enabled. For example, `kdc.example.com`. |
| `connectivitypack.source.endpoint.apiUrl` | Specifies the API URL of the HDFS endpoint. For example, `http://<hdfs_host>:<port>`.                                          |


## Supported authentication mechanisms

The HDFS connector supports Kerberos based authentication for secure connections.
You can configure the following parameters in the `KafkaConnector` custom resource to enable Kerberos authentication.

| **Authentication Type** |  **Use Case** | **Required Credentials**  | **KafkaConnector configuration**  |
| ----------------------- | ------------- | --------------------------| --------------------------------- | 
| BASIC_KERBEROS    | Kerberos authentication for HDFS access. | `Principal`: The Kerberos principal used to authenticate with the HDFS service. <br> `keytab`: The keytab file containing encrypted credentials for the Principal.| `connectivitypack.source.credentials.authType: BASIC_KERBEROS` <br> `connectivitypack.source.credentials.principalName: <principal>` <br> `connectivitypack.source.credentials.keytab: <keytab>`|

## Supported file types for the connector

The connector works with the following types of files:

### CSV files

- A CSV file can contain multiple records.
- The CSV file must only be in UTF-8 file encoding standard.
- Each record in a CSV file must end with a line delimiter. The delimiter is configurable, with `\n` (newline) being the default.
- The first line must contain a header with the field or column names. The connector treats this line as the header. Column names can be plain text, enclosed in double quotes, or escaped by using double quotes if they contain quote characters. For example:

  - `"Index","Customer Id","First Name","Last Name"`
  - `Index,"Customer Id",First Name,"Last Name"`
  - `"Index","My ""Customer"" Id", "First Name", "Last Name"`

- The value fields in a CSV can be plain text, enclosed in double quotes, or escaped by using double quotes if they contain quote characters.
- Each CSV file must end with a line delimiter. If the last line does not include a delimiter, the last record will not be sent to the Kafka topic.
- It is recommended to use a CSV file with a .csv extension.

### Reference files

You can provide the CSV files in one of the two methods.

- If your CSV files are in the HDFS base folder, you can directly point to them.
- In some cases, your CSV files might not be directly located in that folder and could be elsewhere in HDFS. To handle such scenarios, the connector provides an alternative mechanism: reference files.

A reference file tells the connector where to find a specific CSV file. Instead of scanning the entire HDFS directory structure, the connector reads these reference files to know which CSV files to process.

- Each reference file corresponds to one CSV file.
- The reference file must contain the full HDFS path to the CSV file on the first line only.

For example. if you have a CSV file located at `/customer/20251008/ct-table1.csv`, you can create a reference file named `customer_20251008_ct-table1.ref`. Inside this reference file, you must include the actual path of the CSV file `/customer/20251008/ct-table1.csv`.

The connector reads this reference file, extracts the path, and then process the CSV file accordingly, emitting its contents to Kafka topics.

## Supported objects, events, and subscription parameters

This section describes the objects, associated events, and subscription parameters that you can configure in the `KafkaConnector` custom resource.

### UnstructuredRecord events

The HDFS connector monitors a specified folder for CSV or reference files and streams the data to Kafka topics. For more information about reference files and how to use them, see [reference files](#reference-files).

The following table describes the supported object and event for HDFS.

|**Objects**  | **Events** |                                                                                                                                                                                    **Description**                                                                                                                                                                                    |                                           **KafkaConnector configuration**                                            
|:------------:|:-------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------------------:|
|UnstructuredRecord| CREATED| Fetches data present in both new and existing CSV files located in `folderName` or from the CSV files given in the reference files located in the same `folderName` , processing the data record by record.<br/> All CSV files in a given HDFS folder are not required to have the same schema or header. However, all  records within an individual CSV file must follow a consistent schema and header. | `connectivitypack.source.objects: UnstructuredRecord` <br> `connectivitypack.source.UnstructuredRecord.events: CREATED` |

**Note:**
- The connector processes records present in both new and existing CSV files located in the monitored HDFS folder, or from the CSV files given in the reference files located in the same folder.
- If a CSV file has already been processed by the connector and you add new records, append the new records after the last processed record in the file. The connector processes only records that are after the previously processed data. Modifying a file that has already been processed can cause duplicate messages to be produced to the Kafka topic.
- The connector will not process updates to records in a CSV file after the file has been processed.

### Subscription parameters

Subscription parameters define how the HDFS connector monitors a folder and processes both existing and new files within it.

|                                              **Parameter**                                              | **Required or Optional** |                                                                                                                                                                                                   **Description**                                                                                                                                                                                                    |                                                  **KafkaConnector configuration**                                                 |
|:-------------------------------------------------------------------------------------------------------:|:---------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------------------------------:|
|                                              `folderName`                                               |       Required        |                                                                      The HDFS base folder path(flattened, non-recursive) from which files are discovered and processed. Only files in the specified folder are considered. Subfolders are ignored.                                                                                                                                                                   |                                                   `connectivitypack.source.UnstructuredRecord.CREATED.subscription.folderName: /hdfs`        |
|                                              `filePattern`                                              |       Optional        |                                                                                                                    A regular expression (regex) used to filter files to be processed. For example, `.*.csv$`, `^sales_*.csv$`. The default value is `.*`, which includes all files in the folder.                                                                                                                    |  `connectivitypack.source.UnstructuredRecord.CREATED.subscription.filePattern: .*`   |
|                                             `lineDelimiter`                                             |       Optional        |                                                                                                                      The character used to separates lines in the file. Ensure that the last record in the file ends with the line delimiter. The default value is `\\n`.                                                                                                                       |                                              `connectivitypack.source.UnstructuredRecord.CREATED.subscription.lineDelimiter: \\n`                                              |
| `mode` <br/> (omit this parameter if the CSV files to be processed are in the `folderName`)   |       Optional        |                                                                                       Defines how the connector processes files. If set to `reference`, the connector processes reference files, where each reference file contains the path to the actual CSV file. If not set, the connector processes CSV files directly.                                                                                        |                                                            `connectivitypack.source.UnstructuredRecord.CREATED.subscription.mode: reference`                                                             |

### Archival policy

The HDFS connector can archive processed files based on the following configuration:

| **Parameter** | **Required or Optional** |                                                                                                                                                                                                                                   **Description**                                                                                                                                                                                                                                   |                                                                                                   **KafkaConnector configuration**                                                                                                   |
|:-------------:|:----------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| `archiveDir`  | Optional              | Path to the folder where the connector moves processed files. <br> On success, file is moved with `success_` prefix. <br> On failure, file is moved with the `failure_` prefix. <br> Configuring `archiveDir` option ensures that once a file is processed, it is moved to the archive directory. This prevents the connector from repeatedly scanning previously processed files or reference files in case of next polling cycle or after restart, thus improving performance. <br> If this parameter is not specified, files remain in the folder and are not archived.    |                     `connectivitypack.source.UnstructuredRecord.CREATED.subscription.archiveDir: /archive`<br> For example, if `<file name>.csv` is successfully processed by the connector, it is moved to `/archive/success_<file name>.csv`                   |

**Note:**

- After processing, in the `reference` mode, only the reference files are archived. If the connector processes CSV files directly, the CSV files are archived.
- A file is treated as failed only if all records in the file cannot be processed by the connector.
- If a file is partially processed (that is, some records are not processed successfully), the file is still treated as a success and archived with the `success_` prefix.
- Details of any failed records within a file are logged as warnings in Connectivity Pack `event-connectors` logs.

## Schema

You can provide a JSON schema for the records fetched from files, provided that all the files have the same schema. If the data type in the schema does not match the actual data in the files, the connector throws a Connect exception. In such cases, you must manually restart the connector.

| **Parameter** | **Required or Optional** |                                                                                                                                                               **Description**                                                                                                                                                                |                                                                                                                                                                                                                                   **KafkaConnector configuration**                                                                                                                                                                                                                                    |
|:-------------:|:----------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|   `schema`    | Optional              | The JSON schema of all the files that the connector reads. <br> **Note:** This is applicable only if all the files have same schema. JSON schema must be of `Draft 3` version. Only simple data types which are `string`, `number`, and `boolean` are supported.  Other features and subsections of `Draft 3` JSON Schema are not supported. All properties will be treated as optional, irregardless of any use of `required` in the schema. | `connectivitypack.source.schema: <JSON schema>`<br/> JSON schema example: <br>  `'{"type":"object","properties":{"Index":{"type":"string"},"Customer Id":{"type":"number"},"Last Name":{"type":"string"},"Company":{"type":"string"},"City":{"type":"string"},"Country":{"type":"string"},"Phone 1":{"type":"string"},"Phone 2":{"type":"string"},"Email":{"type":"string","format":"email"},"Subscription Date":{"type":"string","format":"date"},"Website":{"type":"string","format":"uri"}}}'` |

**Note**: If you do not provide a schema, the connector automatically derives the schema from the CSV file header and infers the data type of each field as `string`. This happens when different files to be read by the connector have different schema.

## Topic

You can configure how the connector sends HDFS records to Kafka topics:

- Specify the name of the Kafka topic: You can explicitly specify a single topic name for all records fetched by the connector by using the `connectivitypack.topic.name.format` parameter.

  |           **KafkaConnector configuration**            |                      **Description**                      |
    |:----------------------------------:|:---------------------------------------------------------:|
  |        `connectivitypack.topic.name.format`         | Specifies the Kafka topic name. For example, `customer` |

- Default behavior: If no topic name is configured, the connector automatically uses the file name (without extension) as the topic name. If a file has no extension but its name contains a period (.), the text after the last period will be treated as the file extension.

  For example, if the file names are `customer.csv` and `employee.csv`, then the topic names will be `customer` and `employee` respectively. In this case, the data from each file is sent to its corresponding topic.

**Note:** If the connector is configured to use `reference` mode for fetching data (`connectivitypack.source.UnstructuredRecord.CREATED.subscription.mode: reference`), the topic name will be the name of the reference file without extension.


### Topic regex routing

You can use Single Message Transformation (SMT) to dynamically derive Kafka topic names in a specific pattern by using regular expressions.

#### Use case

Consider the following scenario:

- The connector is configured to use `reference` mode.
- The reference files processed by the connector are named `customer_20251008_ct-table1.ref` and `employee_20251008_emp-table1.ref`.
- The `connectivitypack.topic.name.format` parameter is not set.
- You want the records from the CSV files (`customer_20251008_ct-table1.ref` and `employee_20251008_emp-table1.ref`) to be published to topics that follow a specific naming pattern derived from the reference file names.

In such cases, for example, you can configure the connector with the following transformation:

```yaml
transforms: route
transforms.route.type: org.apache.kafka.connect.transforms.RegexRouter
transforms.route.regex: '^([^-]+)_\d{8}_([^-]+)$' # Regex to match the topic names to be replaced
transforms.route.replacement: $1_$2 # How to derive the new topic names
```

The `transforms.route.regex` property uses a regular expression to match the topic names that need replacements or changes. The following table explains the regex patterns:


|           **Part**                 |                      **Description**                                    |
|:----------------------------------:|:-----------------------------------------------------------------------:|
|        `^`                         | Marks the start of the string. This ensures that the match begins at the beginning of the topic name.  |
|        `([^-]+)`                   | First capturing group. Matches one or more characters that are not a hyphen (-). For example, for the file names `customer_20251008_ct-table1` and `employee_20251008_emp-table1`, this captures `customer` and `employee` respectively. <br>|
|        `_`                         | Matches a literal underscore (_) character.  |
|        `\d{8}`                     | Matches exactly 8 digits. |
|        `_`                         | Matches another literal underscore (_) character. |
|        `([^-]+)`                   |Second capturing group. Matches one or more characters that are not a hyphen (-). For example, in `customer_20251008_ct-table1` and `employee_20251008_emp-table1`, it captures `ct-table1` and `emp-table1` respectively. <br> |
|        `$`                         | Marks the end of the string. This ensures that the pattern goes to the end. |


The `transforms.route.replacement` property defines how the new topic name is constructed by using the captured values. $1 refers to the first capturing group and $2 refers to the second capturing group.

For example, for the file name `customer_20251008_ct-table1.ref`, the resulting topic name would be `customer_ct-table1`.

## Configurations for performance optimization

A few configurations that can improve the throughput of the connector are available in the IBM Connectivity Pack `<helm-release-name>` deployment custom resource. The deployment is named `<helm-release-name>-deployment`. There are two containers available which are `action-connectors` and `event-connectors`.

When processing large files, you can improve throughput by increasing the `CHUNK_SIZE` (in bytes) and configuring a suitable `CHUNK_DELAY_IN_SEC` between chunk reads.
However, note that using a larger chunk size consumes more memory and CPU resources. So while this optimization increases throughput, it also requires additional system resources, and you might need to increase the default resource limits for the `event-connectors` container.

The following environment variables can be added in `event-connectors` to enhance the performance when large files need to be processed by the connector.

|    **Environment variable name**     |                                                                                                     **Description**                                                                                                      |
|:------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|             `CHUNK_SIZE`             | Defines the size of each chunk to be processed from a large file. The default value is `1048576 `(1 MB). To use a custom value, add this variable as an environment variable in `event-connectors`.   |
|    `CHUNK_DELAY_IN_SEC`              |         Specifies the delay (in seconds) before processing the next chunk. The default value is `5` (5 seconds). To use a custom value, add this variable as an environment variable in `event-connectors`.        |
|    `pollingInterval`              | Determines how often (in milliseconds) the connector checks the configured folder for new files. Polling begins only after the current processing queue is empty. The default value is `300000` (5 minutes). |

For example:

```yaml
name: event-connectors
env:
  - name: CHUNK_SIZE
    value: 10485760 # (10 MB)
  - name: CHUNK_DELAY_IN_SEC
    value: 10 # In seconds
  - name: pollingInterval
    value: '600000' # In milliseconds (10 minutes)
```

## Example configuration

The following are different examples of connector configurations for HDFS:

### Normal mode
In this mode, place CSV files directly inside the folder that the connector monitors. The connector reads and processes the files from this location.

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaConnector
metadata:
  name: <CONNECTOR_NAME>
  namespace: <NAMESPACE>
  labels:
    eventstreams.ibm.com/cluster: <KAFKA_CONNECT>
    backup.eventstreams.ibm.com/component: kafkaconnector
spec:
  tasksMax: 1
  autoRestart:
    enabled: true
    maxRestarts: 5
  class: com.ibm.eventstreams.connect.connectivitypack.source.ConnectivityPackSourceConnector
  config:
    connectivitypack.source: hdfs
    # Authentication params
    connectivitypack.source.credentials.authType: BASIC_KERBEROS
    connectivitypack.source.credentials.principalName: '${file:/mnt/hdfs-credential:hdfs-basic-kerberos-principalName}'
    connectivitypack.source.credentials.keytab: '${file:/mnt/hdfs-credential:hdfs-basic-kerberos-keytab}'
    # Server and endpoint Url
    connectivitypack.source.endpoint.kdcServer: kdc.example.com
    connectivitypack.source.endpoint.apiUrl: 'http://<hdfs_host>:<port>'
    # Subscription Params
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.folderName: /EventAutomation_DoNotDelete
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.filePattern: .* # optional, default is .* 
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.lineDelimiter: \\n # optional, default is \\n.
    # Object and event type
    connectivitypack.source.objects: UnstructuredRecord
    connectivitypack.source.UnstructuredRecord.events: CREATED
    
    # Topic names must be file names without extension in this case.

```
### Reference mode
In this mode, place reference files inside the monitored folder. These reference files contain paths to the actual CSV files that the connector must process.

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaConnector
metadata:
  labels:
    backup.eventstreams.ibm.com/component: kafkaconnector
    eventstreams.ibm.com/cluster: connectivity-pack-kc
  name: hdfs-source
  namespace: deploy-es-scram-nocs
spec:
  autoRestart:
    enabled: true
    maxRestarts: 5
  class: com.ibm.eventstreams.connect.connectivitypack.source.ConnectivityPackSourceConnector
  config:
    connectivitypack.source: hdfs
    # Authentication params
    connectivitypack.source.credentials.authType: BASIC_KERBEROS
    connectivitypack.source.credentials.principalName: hdfs_user@example.com
    connectivitypack.source.credentials.keytab: '${file:/mnt/hdfs-credential:hdfs-basic-kerberos-keytab}'
    # Server and endpoint Url
    connectivitypack.source.endpoint.kdcServer: kdc.example.com
    connectivitypack.source.endpoint.apiUrl: 'http://<hdfs_host>:<port>'
    # Subscription Params
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.folderName: /hdfs/dataRef
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.filePattern: .*
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.lineDelimiter: \\n
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.mode: reference # indicates reference mode
    # Object and event type
    connectivitypack.source.objects: UnstructuredRecord
    connectivitypack.source.UnstructuredRecord.events: CREATED
    # Topic regex routing
    transforms: route
    transforms.route.type: org.apache.kafka.connect.transforms.RegexRouter
    transforms.route.regex: '^([^-]+)_\d{8}_([^-]+)$' 
    transforms.route.replacement: $1_$2
  state: running
  tasksMax: 1
```
### Schema-based mode
Use this mode when all the files you want the connector to process have the same schema.

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaConnector
metadata:
  name: <CONNECTOR_NAME>
  namespace: <NAMESPACE>
  labels:
    eventstreams.ibm.com/cluster: <KAFKA_CONNECT>
    backup.eventstreams.ibm.com/component: kafkaconnector
spec:
  tasksMax: 1
  autoRestart:
    enabled: true
    maxRestarts: 5
  class: com.ibm.eventstreams.connect.connectivitypack.source.ConnectivityPackSourceConnector
  config:
    connectivitypack.source: hdfs
    # Authentication params
    connectivitypack.source.credentials.authType: BASIC_KERBEROS
    connectivitypack.source.credentials.principalName: '${file:/mnt/hdfs-credential:hdfs-basic-kerberos-principalName}'
    connectivitypack.source.credentials.keytab: '${file:/mnt/hdfs-credential:hdfs-basic-kerberos-keytab}'
    # Server and endpoint Url
    connectivitypack.source.endpoint.kdcServer: kdc.example.com
    connectivitypack.source.endpoint.apiUrl: 'http://<hdfs_host>:<port>'
    # Schema
    connectivitypack.source.schema: '${file:/mnt/schema:hdfs.schema}'
    # Subscription Params
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.folderName: /EventAutomation_DoNotDelete
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.filePattern: .* # optional, default is .* 
    connectivitypack.source.UnstructuredRecord.CREATED.subscription.lineDelimiter: \\n # optional, default is \\n.
    # Object and event type
    connectivitypack.source.objects: UnstructuredRecord
    connectivitypack.source.UnstructuredRecord.events: CREATED
    # Topic
    connectivitypack.topic.name.format: Customer # All the records must be posted to this topic

```
