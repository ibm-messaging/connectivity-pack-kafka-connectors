# Connectivity Pack source connector

The Connectivity Pack source connector enables streaming data from source systems, such as Salesforce, into Kafka topics. These [Kafka Connect](http://kafka.apache.org/documentation.html#connect) connectors use the [IBM Connectivity Pack](../ibm-connectivity-pack/README.md) to enable the data flow between the source system and Kafka.

The connector can be configured to stream the required data by specifying the source system, and a list of objects and associated events that are to be streamed.

The connector uses a Connectivity Pack instance as a bridge that retrieves events from the source system and sends them to the connector for publishing to Kafka topics.

## Configuration

The following configuration options are supported and must be configured in the `config` section of the `KafkaConnector` custom resource.

**Note:** See the [system-specific guidance](../systems/) for supported values of your source system, such as [Salesforce](../systems/salesforce.md).

### Source information

| Property | Type  | Description | Valid values |
| --- | --- | --- | --- |
| `connectivitypack.source` | `string` | Specifies the source system from which data is retrieved. | A valid source, for example, `salesforce` |
| `connectivitypack.source.url` | `string` | The base URL of the source system. | A valid source URL in the format `https://.salesforce.com` |

### Authentication

| Property | Type | Description | Valid values |
| --- | --- | --- | --- |
| `connectivitypack.source.credentials.authType` | `string` | Specifies the authentication type for the source system. | Supported types, for example, `OAUTH2_PASSWORD` or `BASIC_OAUTH` |
| `connectivitypack.source.credentials.username` | `string` | The username associated with the source system's credentials. Required for `OAUTH2_PASSWORD`. | The username used for authentication. |
| `connectivitypack.source.credentials.password` | `string` | The password associated with the source system's credentials. Required for `OAUTH2_PASSWORD`. | The password used for authentication. |
| `connectivitypack.source.credentials.clientIdentity` | `string`  | The client identity of the system to which the source system is connected to. Required for both `OAUTH2_PASSWORD` and `BASIC_OAUTH`. | The client identity of the system to which the source system is connected to. |
| `connectivitypack.source.credentials.clientSecret` | `string`  | The client secret of the source system. Required for both `OAUTH2_PASSWORD` and `BASIC_OAUTH`. | The client secret of the source system's connected app. |
| `connectivitypack.source.credentials.accessTokenBasicOauth` | `string` | The OAuth access token used for authentication. Required for `BASIC_OAUTH`. |  A valid access token that complies with the source system's requirements. |
| `connectivitypack.source.credentials.refreshTokenBasicOauth` | `string` | The refresh token used to renew the OAuth access token. Required for `BASIC_OAUTH`. | A valid refresh token that complies with the source system's requirements.  |

### Data mapping

| Property                                      | Type                             | Description                                                                                                                                                                                                                                                                                                                                                                 | Valid values                                                                                                                                  |
| --------------------------------------------- | -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `connectivitypack.source.objects`             | `string` or comma-separated list | Specifies the objects in the source system that the connector will interact with. You can provide either a single object, or a comma-separated list of objects.                                                                                                                                                                                                             | Values depend on your source system. In Salesforce, valid values are any of the `Platform Event` or `Change Data Capture` supporting objects. |
| `connectivitypack.source.<object>.events`     | `string` or comma-separated list | Specifies the events for each object that the connector listens to. Each object specified in `connectivitypack.source.objects` must have corresponding events. `<object>` must be replaced with one of the specified objects.                                                                                                                                               | Events supported by each object on your source system. In Salesforce, valid events are `CREATED`, `UPDATED`, or `DELETED`.                    |
| `connectivitypack.topic.name.format`          | `string`                         | Sets the format for Kafka topic names created by the connector. You can use placeholders such as `${object}` and `${eventType}`, which the connector will replace automatically. Including `${object}` or `${eventType}` in the format is optional. For example, `${object}-topic-name` is a valid format. A topic will be created for each `object-eventType` combination. | Default: `${object}-${eventType}`                                                                                                             |
| `connectivitypack.auto.correct.invalid.topic` | `boolean`                        | Optional: Automatically converts invalid topic names to valid Kafka topic names by replacing unsupported characters. For example, the topic name `*topicname` will be converted to `-topicname` by replacing `*` with `-`.                                                                                                                                                  | `true` or `false`                                                                                                                             |

## Task distribution

The distribution of tasks in the Connectivity Pack source connector depends on the objects and the associated events in the source system that are sent to Kafka. Each `object - event` combination is handled by a separate connector task that publishes messages to a distinct Kafka topic.

- **Object:** Represents a data entity or record in the source system, such as `Account`, `Order_Event__e`, or `CaseChangeEvent`.
- **Event:** Specifies the type of action or state change related to the object, such as `CREATED`, `UPDATED`, or `DELETED`.

For example, if the object is an `Order_Event__e` record, and the related event is a `CREATED` action, the events triggered when a new `Order_Event__e` record is created in the source system will be handled by a connector task, and such events will be published to the `Order_Event__e-CREATED` topic.

**Note:** If the value of `spec.tasksMax` is configured to be less than the number of `object - event` combinations, the connector will fail with the following error:

```shell
The connector `<name-of-connector>` has generated `<actual-number-of-tasks>` tasks, which is greater than `<value-given-in-tasksMax>`, the maximum number of tasks it is configured to create.
```

## Single Message Transformations (SMTs)

The Salesforce connector can be configured with [transformations](https://kafka.apache.org/documentation.html#connect_transforms) to manipulate Kafka record keys, values, and headers. With these Single Message Transformations (SMTs) you can extract, cast, or modify fields for better control over your streaming data.

To set the Kafka record key from a subset of fields in the source record, see the following example:

1. Consider a record with the following structure:


   ```json
   {
   "CreatedDate": "2024-12-11T11:00:32.299Z",
   "CreatedById": "005dM000009CeUMQA0",
   "OrderStatus__c": "B\\M*3G0\"q!",
   "CustomerEmail__c": "usernmae@hotmail.com",
   "OrderTotal__c": 626.48,
   "OrderDate__c": "2024-02-18T16:05:06.506Z",
   "OrderId__c": "d76306e1-2ff8-4f8d-8bb0-ac91a1caf25b",
   "schema": "cKLHIOLKGudADKzibwggwA",
   "event": {
      "replayId": "40270513",
      "EventUuid": "db784749-8d7d-403e-9885-dfddb016391f"
   }
   }
   ```


1. To configure the `replayId` from the `event` object as the Kafka record key, you can define a series of transformations as follows:

   ```shell
   transforms: 'createEvent,extractEvent,extractReplayId'

   # First Transform: Convert the entire 'event' object to the key
   transforms.createEvent.type: org.apache.kafka.connect.transforms.ValueToKey
   transforms.createEvent.fields: event
   # Result: Sets the entire 'event' object as the record's key.

   # Second Transform: Extract the 'event' object from the key
   transforms.extractEvent.type: org.apache.kafka.connect.transforms.ExtractField$Key
   transforms.extractEvent.field: event
   # Result: Promotes the 'event' object from the key to the value/payload.

   # Third Transform: Extract 'replayId' from the key
   transforms.extractReplayId.type: org.apache.kafka.connect.transforms.ExtractField$Key
   transforms.extractReplayId.field: replayId
   # Result: Extracts the 'replayId' field from the key.
   ```


1. After applying the SMTs, the Kafka record key is set to `"40270513"`, extracted from the `replayId` field in the `event` object.

   You can further modify or cast this key if required. For example, you can use an additional transformation to cast the key from a string into a number.
