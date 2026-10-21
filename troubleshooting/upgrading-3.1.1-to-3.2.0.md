# Connectors fail with missing required properties after upgrading to 3.2.0

If you upgrade IBM Connectivity Pack from 3.1.1 to 3.2.0, connectors might fail to start because the connector configuration requires the `applicationType` and `applicationVersion` properties. The HDFS source connector also requires the `authType` property.

## Symptoms

After you upgrade Connectivity Pack from 3.1.1 to 3.2.0, the `KafkaConnector` custom resource shows the `NotReady` condition with an error similar to the following example:

```text
io.strimzi.operator.cluster.operator.assembly.ConnectRestException: PUT /connectors/sink-connector-servicenow-basic-insert/config returned 400 (400): Connector configuration is invalid and contains the following 4 error(s):
Missing required configuration "connectivitypack.sink.applicationType" which has no default value.
Invalid value null for configuration connectivitypack.sink.applicationType: entry must be non null
Missing required configuration "connectivitypack.sink.applicationVersion" which has no default value.
Invalid value null for configuration connectivitypack.sink.applicationVersion: entry must be non null
You can also find the above list of errors at the endpoint `/connector-plugins/{connectorType}/config/validate`
```

For source connectors, the error refers to `connectivitypack.source.applicationType` and `connectivitypack.source.applicationVersion`.

For the HDFS source connector, if the `connectivitypack.source.authType` property is also missing, the `KafkaConnector` custom resource shows the `NotReady` condition with an error similar to the following example:

```text
io.strimzi.operator.cluster.operator.assembly.ConnectRestException: PUT /connectors/source-connector-hdfs-basic-kerberos-nonrefmode/config returned 500 (500): Missing required configuration "connectivitypack.source.authType" which has no default value.
```

## Causes

Connectivity Pack 3.2.0 requires the `applicationType` and `applicationVersion` properties in the configuration of the following connectors:

- GitHub source connector
- Google Calendar source connector
- HDFS source connector
- Jira source connector
- ServiceNow source connector
- Google Cloud BigQuery sink connector
- ServiceNow sink connector

Connectivity Pack rejects connector configurations that do not include these properties.

The HDFS source connector also requires the `authType` property in Connectivity Pack 3.2.0 and later. If the property is missing, Connectivity Pack rejects the configuration. Earlier versions did not require this property.

## Resolving the problem

Complete the following steps to update the connector configuration:

1. Add the following properties to each `KafkaConnector` custom resource for the affected connectors.

   For a source connector:

   ```yaml
   connectivitypack.source.applicationType: online
   connectivitypack.source.applicationVersion: v1
   ```

   For a sink connector:

   ```yaml
   connectivitypack.sink.applicationType: online
   connectivitypack.sink.applicationVersion: v1
   ```

   For the HDFS source connector, also add the following property:

   ```yaml
   connectivitypack.source.authType: BASIC_KERBEROS
   ```

   For details about each connector, see the following documentation:

   | **Connector** | **Documentation** |
   | ------------- | ----------------- |
   | GitHub source | [Application types](../systems/source%20systems/github.md#application-types) |
   | Google Calendar source | [Connecting to Google Calendar](../systems/source%20systems/google-calendar.md#connecting-to-google-calendar) |
   | HDFS source | [Connecting to HDFS](../systems/source%20systems/hdfs.md#connecting-to-hdfs) |
   | Jira source | [Connecting to Jira](../systems/source%20systems/jira.md#connecting-to-jira) |
   | ServiceNow source | [Connecting to ServiceNow](../systems/source%20systems/servicenow.md#connecting-to-servicenow) |
   | ServiceNow sink | [Connecting to ServiceNow](../systems/sink%20systems/servicenow.md#connecting-to-servicenow) |
   | Google Cloud BigQuery sink | [Connecting to Google Cloud BigQuery](../systems/sink%20systems/google-cloud-bigquery.md#connecting-to-google-cloud-bigquery) |

1. Apply the updated `KafkaConnector` custom resource.

1. Verify that the connector state in the `KafkaConnector` custom resource is `RUNNING`.
