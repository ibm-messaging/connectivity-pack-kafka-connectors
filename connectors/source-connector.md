# Connectivity Pack source connector

The Connectivity Pack source connector enables streaming data from external data sources, such as Salesforce, into Kafka topics. These [Kafka Connect](http://kafka.apache.org/documentation.html#connect) connectors use the [IBM Connectivity Pack](../ibm-connectivity-pack/README.md) to enable the data flow between the source system and Kafka.

The connector can be configured to stream the required data by specifying the source system, and a list of objects and associated events that are to be streamed.

The connector uses a Connectivity Pack instance as a bridge that retrieves events from the data source and sends them to the connector for publishing to Kafka topics.

## Configuration

The following configuration options are supported and must be configured in the `config` section of the `KafkaConnector` custom resource.

**Note:** See the [application-specific guidance](../applications/) for supported values of your source system, such as [Salesforce](../applications/salesforce.md).

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
| `connectivitypack.source.credentials.clientIdentity` | `string`  | The client identity of the application to which the source system is connected to. Required for both `OAUTH2_PASSWORD` and `BASIC_OAUTH`. | The client identity of the application to which the source system is connected to. |
| `connectivitypack.source.credentials.clientSecret` | `string`  | The client secret of the source application's connected app. Required for both `OAUTH2_PASSWORD` and `BASIC_OAUTH`. | The client secret of the source application's connected app. |
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
