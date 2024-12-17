# Connectivity Pack source connector

Connectivity Pack source connector enables streaming data from external data sources, such as Salesforce, into Kafka topics. These [Kafka Connect](http://kafka.apache.org/documentation.html#connect) connectors use [IBM Connectivity Pack](../ibm-connectivity-pack/README.md) to interact with external data sources.

## How it works

The connector is designed to work with multiple data sources. For each data source, a corresponding set of Kafka topics is created, allowing seamless integration and data flow between the source systems and Kafka.

The connector establishes a WebSocket connection to the data source through the Connectivity Pack instance. The Connectivity Pack acts as a bridge between the connector and the source system, handling the complexities of communication. It incorporates an internal mechanism to continuously monitor and retrieve new events from the data source, ensuring real-time data synchronization.

## Task distribution

Distribution of tasks in Connectivity Pack source connector is done in a specific way as described in this section. It depends on an `object - event-type` combination, which is defined while setting up your `KafkaConnector` custom resource.

These combinations are used to define the topics in Kafka where messages related to the object and the event type are published. Each combination results in a unique topic. This automatic creation of a unique topic ensures that the events are categorized and processed correctly based on the object and the event-type. The connector also uses these combinations to distribute the workload across tasks.

- **Object:** Represents a data entity or record in the source system, such as `Account`, `Order_Event__e`, or `CaseChangeEvent`.
- **Event-type:** Specifies the type of action or state change related to the object, such as `CREATED`, `UPDATED`, or `DELETED`.

For example, if the object is `Order_Event__e` and the event type is `CREATED`, the combination `Order_Event__e-CREATED` represents events triggered when a new `Order_Event__e` record is created in the source system.

**Note:** If the value of `spec.tasksMax` is less than the number of `object - event-type` combinations, the connector will fail with the following error:

```shell
The connector `<name-of-connector>` has generated `<actual-number-of-tasks>` tasks, which is greater than `<value-given-in-tasksMax>`, the maximum number of tasks it is configured to create.
```

## Configuration


The following configuration options are supported and must be configured in the `config` section of the `KafkaConnector` custom resource.

**Note:** See the [application-specific guidance](../applications/) for supported values of your source such as [Salesforce](../applications/salesforce.md).

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
 
| Property | Type | Description | Valid values |
| --- | --- | --- | --- |
| `connectivitypack.source.objects` | `string` or comma-separated list | Specifies the objects in the source system that the connector will interact with. You can provide either a single object, or a comma-separated list of objects. | Values depend on your source system, for example in Salesforce. Valid values are `Account`, `Contact`, or `Opportunity`  |
| `connectivitypack.source.<object>.events` | `string` or comma-separated list | Specifies the events for each object that the connector listens to. Each object specified in `connectivitypack.source.objects` must have corresponding events. `<object>` must be replaced with one of the specified objects. | Events supported by each object on your source system, for example in Salesforce. Valid events are `CREATED`, `UPDATED`, or `DELETED`. |
| `connectivitypack.topic.name.format` | `string` | Optional: Defines the format for Kafka topic names. This format must include `${object}` and `${eventType}`. One topic will be created for each `object-eventType` combination. | Default: `${object}-${eventType}` |
| `connectivitypack.auto.correct.invalid.topic` | `boolean` | Optional: Automatically converts invalid topic names to valid Kafka topic names by replacing unsupported characters. For example, the topic name `*topicname` will be converted to `-topicname` by replacing `*` with `-`. | `true` or `false` |
