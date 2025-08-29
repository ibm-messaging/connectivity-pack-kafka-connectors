# ServiceNow

The ServiceNow connector uses the ServiceNow API to stream object events to Kafka topics. You can use this connector to track updates from ServiceNow objects such as assets, attachments, comments, departments, incidents, problems, system users, tickets, and more.

## Pre-requisites

To use the ServiceNow connector, ensure that you have the required credentials and API access to your ServiceNow instance.

## Connecting to ServiceNow

The `connectivitypack.source` and `connectivitypack.source.endpoint.url` configurations in the `KafkaConnector` custom resource specify the source system and its endpoint.

| **Name** | **Value or Description** |
| -------- | -------------------------|
| `connectivitypack.source` | `servicenow` |
| `connectivitypack.source.endpoint.url` | Specifies the base URL of your ServiceNow instance. For example: `https://<instance>.service-now.com`.|

## Supported authentication mechanisms

You can configure the following authentication types in the `KafkaConnector` custom resource:

| **Authentication type** | **Application type** | **Use case** | **Required credentials** | **KafkaConnector configuration** |
|-------------------------|----------------------|--------------|---------------------------|----------------------------------|
| Basic Authentication    | ServiceNow           | Supported with username and password authentication. | Username and password: Credentials of the ServiceNow user with the required roles and access. | `connectivitypack.source.authType: BASIC`<br>`connectivitypack.source.credentials.username: <username>`<br>`connectivitypack.source.credentials.password: <password>` |
| OAuth2 Password         | ServiceNow           | Use when your ServiceNow instance is configured for OAuth2-based access. | - Username and password<br> - Client ID and client secret<br> - Endpoint URL | `connectivitypack.source.authType: OAUTH2_PASSWORD`<br>`connectivitypack.source.credentials.username: <username>`<br>`connectivitypack.source.credentials.password: <password>`<br>`connectivitypack.source.credentials.clientId: <clientId>`<br>`connectivitypack.source.credentials.clientSecret: <clientSecret>`<br>`connectivitypack.source.endpoint.url: https://<your-instance>.service-now.com` |

## Supported objects and events

You can specify ServiceNow objects and associated events in the `connectivitypack.source.objects` and `connectivitypack.source.<object>.events` sections of the `KafkaConnector` custom resource.

| **Objects**   | **Events**  | **Description** | **KafkaConnector configuration** |
|---------------------|--------------------|----------------|--------------------------|
| `incident`          | `CREATED`, `UPDATED`| Captures creation and updates of incident records.     | `connectivitypack.source.objects: incident`<br>`connectivitypack.source.incident.events: CREATED, UPDATED`       |
| `alm_asset`         | `CREATED`, `UPDATED`| Captures creation and updates of asset records.| `connectivitypack.source.objects: alm_asset`<br>`connectivitypack.source.alm_asset.events: CREATED, UPDATED`|
| `cmn_department`    | `CREATED`, `UPDATED`| Captures creation and updates of department records. | `connectivitypack.source.objects: cmn_department`<br> `connectivitypack.source.cmn_department.events: CREATED, UPDATED`|
| `sys_attachment`    | `CREATED` | Captures creation of attachment records. | `connectivitypack.source.objects: sys_attachment`<br>`connectivitypack.source.sys_attachment.events: CREATED`|
| `sys_journal_field` | `CREATED` | Captures creation of comment records. | `connectivitypack.source.objects: sys_journal_field`<br>`connectivitypack.source.sys_journal_field.events: CREATED`  |
| `problem`           | `CREATED`, `UPDATED`| Captures creation and updates of problem records.| `connectivitypack.source.objects: problem`<br>`connectivitypack.source.problem.events: CREATED, UPDATED`     |
| `sys_user`          | `CREATED`, `UPDATED`| Captures creation and updates of user records.| `connectivitypack.source.objects: sys_user`<br> `connectivitypack.source.sys_user.events: CREATED, UPDATED`  |
| `ticket`           | `CREATED`, `UPDATED`| Captures creation and updates of ticket records.| `connectivitypack.source.objects: ticket`<br>`connectivitypack.source.ticket.events: CREATED, UPDATED`     |

## Topic

Optional: The following parameter is used to configure the Kafka topic name.

| **KafkaConnector configuration** | **Description** |
|----------------------------------|-----------------|
| `connectivitypack.topic.name.format`| Specifies the format of the Kafka topic. The default value is `${object}-${eventType}`. You can give any format consisting of `${object}` and `${eventType}`. For example, `servicenow-incident.CREATED`|

## Heartbeat topic

Optional: The heartbeat topic verifies that the connector is active and operational. It contains only tombstone records: entries that do not have any payload, consisting only of a timestamp. If a heartbeat topic is specified, then Single Message Transformations (SMTs) to filter out tombstone records are not required. The following parameter is used to configure the name of the heartbeat topic.

| **KafkaConnector configuration**   | **Description**   |
|------------------------------------|--------------------|
| `connectivitypack.source.heartbeat.topic`     | You can use the placeholder `${topic}` to dynamically insert the actual event topic name. This placeholder is optional. For example, if the topic is `servicenow-incident.CREATED` and the heartbeat topic is configured as `heartbeat-${topic}`, the resulting heartbeat topic will be `heartbeat-servicenow-incident.CREATED`. If you do not include `${topic}`, the exact value specified will be used as the topic name. If no heartbeat topic is explicitly configured, the default will be the same as the event topic, for example, `servicenow-incident.CREATED`.|

## Example configuration

The following is an example of a connector configuration for ServiceNow:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaConnector
metadata:
  name: <connector_name>
  namespace: <namespace>
  labels:
    eventstreams.ibm.com/cluster: <kafka_connect>
    backup.eventstreams.ibm.com/component: kafkaconnector
spec:
  tasksMax: 14
  autoRestart:
    enabled: true
    maxRestarts: 5
  class: com.ibm.eventstreams.connect.connectivitypack.source.ConnectivityPackSourceConnector
  config:
    connectivitypack.source: servicenow
    connectivitypack.source.endpoint.url: https://<your-instance>.service-now.com/
    # Credentials to access the data source
    connectivitypack.source.authType: BASIC
    connectivitypack.source.credentials.username: ${file:/mnt/servicenow-credential:servicenow-basic-username}
    connectivitypack.source.credentials.password: ${file:/mnt/servicenow-credential:servicenow-basic-password}
    # Objects that support events
    connectivitypack.source.objects: incident,alm_asset,cmn_department,sys_attachment,sys_journal_field,problem,sys_user,ticket
    # Specifies the events (for example, CREATED, UPDATED) to capture for the object.
    # The connector will process only events of the specified type for these objects
    connectivitypack.source.incident.events: CREATED,UPDATED
    connectivitypack.source.alm_asset.events: CREATED,UPDATED
    connectivitypack.source.cmn_department.events: CREATED,UPDATED
    connectivitypack.source.sys_attachment.events: CREATED
    connectivitypack.source.sys_journal_field.events: CREATED
    connectivitypack.source.problem.events: CREATED,UPDATED
    connectivitypack.source.sys_user.events: CREATED,UPDATED
    connectivitypack.source.ticket.events: CREATED,UPDATED
    connectivitypack.topic.name.format: '${object}-${eventType}'
    # To remove schema from topic
    value.converter: org.apache.kafka.connect.json.JsonConverter
    value.converter.schemas.enable: false
    # To filter out tombstone records from topic
    connectivitypack.source.heartbeat.topic: 'heartbeat-${topic}'
```

**Note:** ServiceNow personal developer instances go into hibernation and are subsequently reclaimed after a certain period of developer inactivity. If your flows include one or more ServiceNow events, and you have not accessed your ServiceNow instance in a while, the connection between connector and ServiceNow might be lost because the instance is hibernating or has been reclaimed. If you see a related message in your connector status or logs, you can re-establish the connection in one of the following ways:

   - If your instance is in hibernation, either extend your instance, or log in to the ServiceNow console and generate some developer activity.
   - If your instance has been reclaimed, you will need to use another instance and reconnect the connector to that instance.