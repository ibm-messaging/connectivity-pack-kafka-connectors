# Google Calendar connector

The Google Calendar connector uses Google Calendar API to stream Google Calendar events updates to Kafka Topics. You can use this connector to monitor events from Google Calendar.

## Pre-requisites

- Ensure you have a Google Cloud account with required permissions to access and manage Google Calendar events.
- Verify that your network allows connections to Google Calendar API endpoints.

## Connecting to Google Calendar

The `connectivitypack.source` and `connectivitypack.source.resource.id` configurations in the `KafkaConnector` custom resource provide the connector with the required information to connect to the Google Calendar data source.

| Name  | Value or Description |
|-------|--------------------|
| `connectivitypack.source` |  `googlecalendar`  |
| `connectivitypack.source.resource.id` | Specifies the ID of the calendar being polled.|

## Supported authentication mechanisms

The following authentication mechanisms are supported for Google Calendar in the `KafkaConnector` custom resource:

| Authentication Type | Use Case| Required Credentials                                                                                                                                                                                                         | KafkaConnector configuration                                                                                                                                                                                                                                               |
|---------------------|---------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| BASIC_OAUTH         | Provide credentials to authenticate and access the system. | `clientId`: Specifies the client ID for authentication. <br> `clientSecret`: Specifies the client secret for authentication. <br> `accessToken`: Specifies the access token to authenticate API calls. <br> `refreshToken`: Specifies the refresh token used to regenerate the access token. | `connectivitypack.source.authType: BASIC_OAUTH` <br> `connectivitypack.source.credentials.clientId` <br> `connectivitypack.source.credentials.clientSecret` <br> `connectivitypack.source.credentials.accessToken` <br> `connectivitypack.source.credentials.refreshToken` |



## Supported objects, events, and subscription parameters

This section describes the objects, associated events, and subscription parameters that you can configure in the `KafkaConnector` custom resource.

### Google Calendar events

Google Calendar events are triggered when calendar events are created, updated, or both. The following table lists the objects and associated events that you can specify in the `connectivitypack.source.objects` and `connectivitypack.source.<object>.events` sections of the `KafkaConnector` custom resource.

| Objects | Events | Description | KafkaConnector configuration|
|---------|--------|-------------|-----------------------------|
| Calendar events | CREATEDORUPDATED_POLLER | Event creation, updation, or both  | `connectivitypack.source.objects: events` <br> `connectivitypack.source.events.events: <CREATEDORUPDATED_POLLER>` |

### Subscription parameters

Subscription parameters configure how the Google Calendar connector polls for events, ensuring timely and reliable event retrieval. This can be given for each object-event combination.

| Parameter | Description                                                                                                                                                                                                 | KafkaConnector configuration |
|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| `timeZone`         | The time zone used for subscription of event processing. Default value is UTC. For the complete list of supported time zone values, see [supported time zone values](../connectors/supported-timezones.md). | `connectivitypack.source.events.<event>.subscription.timeZone` |
| `pollingInterval`  | The time interval at which the connector polls for events. Default value is 5 minutes. The permissible values are 1, 5, 10, 15, 30 and 60.                                                                  | `connectivitypack.source.events.<event>.subscription.pollingInterval`

### Topic

Optional: The following parameter is used to configure the Kafka topic name.

| **KafkaConnector configuration** | **Description**                                                                                                                                                                                                                                        |
|----------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|  `connectivitypack.topic.name.format` | Specifies the format of the Kafka topic name generated for the event. The default value is `${object}-${eventType}`. You can give any format consisting of `${object}` and `${eventType}`. For example, `googlecalendar-Issue-CREATEDORUPDATED_POLLER` |

#### Heartbeat topic

Optional: The heartbeat topic verifies that the connector is active and operational. It contains only tombstone records — entries with no payload, consisting only timestamp. If heartbeat topic is specified, then Single Message Transformations (SMTs) to filter out tombstone records are not required. The following parameter is used to configure the name of the heartbeat topic.

|           **KafkaConnector configuration**            |                                                                                                                                                                                                                                                                                                                                                                       **Description**                                                                                                                                                                                                                                                                                                                                                                       |
|:----------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|        `connectivitypack.source.heartbeat.topic`         | You can use the placeholder `${topic}` to dynamically insert the name of the actual topic to which the connector sends events. This placeholder is optional. If you specify a heartbeat topic name using `${topic}`, it will be replaced with the actual topic name. For example, if the topic is `googlecalendar-Issue-CREATED_POLLER` and the heartbeat topic is configured as `heartbeat-${topic}`, the resulting heartbeat topic will be `heartbeat-googlecalendar-Issue-CREATED_POLLER`. If you do not include `${topic}`, the specified heartbeat topic name will be used as-is. If no heartbeat topic is explicitly configured, the default heartbeat topic will be the same as the event topic, for example, `googlecalendar-Issue-CREATED_POLLER`. |

## Example configuration

The following is an example of a connector configuration for Google Calendar:

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
  class: com.ibm.eventstreams.connect.connectivitypack.source.ConnectivityPackSourceConnector

  config:
    # Which data source to connect to.
    connectivitypack.source: googlecalendar

    # Credentials to access the data source using BASIC_OAUTH authentication.
    connectivitypack.source.authType: BASIC_OAUTH
    connectivitypack.source.credentials.clientId: <client id>
    connectivitypack.source.credentials.clientSecret: <client secret>
    connectivitypack.source.credentials.accessToken: <access token>
    connectivitypack.source.credentials.refreshToken: <refresh token>

    # Calendar Id
    connectivitypack.source.resource.id: <calendar Id>
    
    # Objects that support poller events
    connectivitypack.source.objects: events
    
    # Specifies the events (for example, CREATEDORUPDATED_POLLER) to capture for the events object.
    connectivitypack.source.events.events: CREATEDORUPDATED_POLLER
    
    # Subscription params for events-CREATEDORUPDATED_POLLER combination
    connectivitypack.source.events.CREATEDORUPDATED_POLLER.subscription.timeZone: UTC
    connectivitypack.source.events.CREATEDORUPDATED_POLLER.subscription.pollingInterval: 1

    # Optional, sets the format for Kafka topic names created by the connector.
    # You can use placeholders such as '${object}' and '${eventType}', which the connector will replace automatically.
    # Including '${object}' or '${eventType}' in the format is optional. For example, '${object}-topic-name' is a valid format.
    # By default, the format is '${object}-${eventType}', but it's shown here for clarity.
    connectivitypack.topic.name.format: '${object}-${eventType}'


    # Specifies the converter class used to deserialize the message value.
    # Change this to a different converter (for example, AvroConverter) as applicable.
    value.converter: org.apache.kafka.connect.json.JsonConverter

    # Controls whether the schema is included in the message.
    # Set this to false to disable schema support, or to true to enable schema inclusion (for example, for Avro).
    value.converter.schemas.enable: false
    # Optional, set the topic for producing the heartbeat events.
    connectivitypack.source.heartbeat.topic: heartbeat-${topic}
  # `tasksMax` must be equal to the number of object-eventType combinations
  # In this example it is 1
  tasksMax: 1    

```
