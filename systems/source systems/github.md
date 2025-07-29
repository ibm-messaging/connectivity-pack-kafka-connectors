# GitHub

The GitHub connector uses GitHub API to stream GitHub issue events to Kafka Topics. You can use this connector to track issues in GitHub repositories.

## Pre-requisites

- Ensure you have a GitHub account with the required permissions, either on GitHub Cloud or GitHub Enterprise Server.
- Generate access token from your GitHub account with the required permissions to access the API endpoints.
- Ensure your network allows connections to GitHub API endpoints.

## Connecting to GitHub

The `connectivitypack.source` and `connectivitypack.source.url` configurations in the `KafkaConnector` custom resource provide the connector with the required information to connect to the GitHub data source.

| **Name**                      | **Value or Description**                                                                                                                                                                                        |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `connectivitypack.source`     | `github`                                                                                                                                                                                                        |
| `connectivitypack.source.url` | Specifies the URL of the source system. For example, for GitHub, the base URL of your instance is `https://github.com/` for GitHub Cloud or `https://github.<yourenterprise>.com` for GitHub Enterprise Server. |

## Application types

The following application types are available in GitHub:

- online (GitHub Cloud)
- onprem (GitHub Enterprise Server)

By default, the application type is set to online.
The `connectivitypack.source.applicationType` configuration specifies the application type.

| **Name**                                  | **Value or Description**                                                                |
| ----------------------------------------- | --------------------------------------------------------------------------------------- |
| `connectivitypack.source.applicationType` | `online` for Github Cloud or `onprem` for Gihub Enterprise Server. Default is `online`. |

## Supported authentication mechanisms

Depending on the authentication flow in GitHub, you can configure the following authentication mechanisms for GitHub in the `KafkaConnector` custom resource.

| **Authentication Type** | **Application Type**                      | **Use Case**                                                    | **Required Credentials**                                                                                                                    | **KafkaConnector configuration**                                                                                 |
| ----------------------- | ----------------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Basic authentication    | GitHub Cloud and GitHub Enterprise Server | Supported for basic authentication with personal access tokens. | Private Key: The personal access token to access the GitHub API. Generate the personal access token from your GitHub account settings page. | `connectivitypack.source.authType: BASIC` `connectivitypack.source.credentials.privateKey: <privateKey>`         |
| OAuth Authentication    | GitHub Cloud and GitHub Enterprise Server | Supported when using OAuth for authentication.                  | Access Key: The access token generated from the system client ID, tenant ID, client secret, scope, grant type, username, and password.      | `connectivitypack.source.authType: BASIC_OAUTH` `connectivitypack.source.credentials.accessKeyId: <accessKeyId>` |

## Supported objects, events, and subscription parameters

This section describes the objects, associated events, and subscription parameters that you can configure in the `KafkaConnector` custom resource.

### GitHub Issue events

GitHub Issue events are triggered when issues are created or updated in a repository of an organization. These events are specific to the Github organization and repository. The following table lists the objects and associated events that you can specify in the `connectivitypack.source.objects` and `connectivitypack.source.<object>.events` sections of the `KafkaConnector` custom resource.

| **Object** | **Parent Resources**     | **Events**                                              | **Description**                                                                                                            | **KafkaConnector configuration**                                                                                                                                                                                                                                                                |
| ---------- | ------------------------ | ------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Issue      | Organization, Repository | CREATED_POLLER, UPDATED_POLLER, CREATEDORUPDATED_POLLER | GitHub issues that belong to a repository within an organization. Events are triggered when issues are created or updated. | `connectivitypack.source.objects: Issue` <br> `connectivitypack.source.resource.OwnerName: <organization name>` <br> `connectivitypack.source.resource.RepoName: <repository name>` <br>  `connectivitypack.source.Issue.events: <CREATED_POLLER>, <UPDATED_POLLER>, <CREATEDORUPDATED_POLLER>` |

### Subscription parameters

Subscription parameters configure how the GitHub connector polls for events, ensuring timely and reliable event retrieval. This can be given for each object-event combination.

|   **Parameter**   |                                                                                                 **Description**                                                                                                 |                   **KafkaConnector configuration**                   |
| :---------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------: |
|    `timeZone`     | The time zone used for subscription of event processing. The default value is UTC. For the complete list of supported time zone values, see [supported time zone values](../connectors/supported-timezones.md). |    `connectivitypack.source.Issue.<event>.subscription.timezone`     |
| `pollingInterval` |                                 The time interval at which the connector polls for events. The default value is 5 minutes. The permissible values are 1, 5, 10, 15, 30 and 60.                                  | `connectivitypack.source.Issue.<event>.subscription.pollingInterval` |

### Topic

Optional: The following parameter is used to configure the Kafka topic name.

|   **KafkaConnector configuration**   |                                                                                                            **Description**                                                                                                            |
| :----------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| `connectivitypack.topic.name.format` | Specifies the format of the Kafka topic name generated for the event. The default value is `${object}-${eventType}`. You can give any format consisting of `${object}` and `${eventType}`. For example, `github-Issue-CREATED_POLLER` |

#### Heartbeat topic

Optional: The heartbeat topic verifies that the connector is active and operational. It contains only tombstone records — entries with no payload, consisting only timestamp. If heartbeat topic is specified, then Single Message Transformations (SMTs) to filter out tombstone records are not required. The following parameter is used to configure the name of the heartbeat topic.

|     **KafkaConnector configuration**      |                                                                                                                                                                                                                                                                                                                                                           **Description**                                                                                                                                                                                                                                                                                                                                                           |
| :---------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| `connectivitypack.source.heartbeat.topic` | You can use the placeholder `${topic}` to dynamically insert the name of the actual topic to which the connector sends events. This placeholder is optional. If you specify a heartbeat topic name using `${topic}`, it will be replaced with the actual topic name. For example, if the topic is `github-Issue-CREATED_POLLER` and the heartbeat topic is configured as `heartbeat-${topic}`, the resulting heartbeat topic will be `heartbeat-github-Issue-CREATED_POLLER`. If you do not include `${topic}`, the specified heartbeat topic name will be used as-is. If no heartbeat topic is explicitly configured, the default heartbeat topic will be the same as the event topic, for example, `github-Issue-CREATED_POLLER`. |

## Example configuration

The following is an example of a connector configuration for GitHub:

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
    connectivitypack.source: github
    connectivitypack.source.url: https://github.com
    connectivitypack.source.applicationType: online

    # Credentials to access the data source using BASIC authentication.
    connectivitypack.source.authType: BASIC
    connectivitypack.source.credentials.privateKey: <privateKey>

    # Organization and Repository
    connectivitypack.source.resource.OwnerName: org1
    connectivitypack.source.resource.RepoName: repo1

    # Objects that support poller events
    connectivitypack.source.objects: Issue
    # Specifies the events (for example, CREATED_POLLER, UPDATED_POLLER) to capture for the Issue object.
    connectivitypack.source.Issue.events: CREATED_POLLER
    # Subscription params for the Issue-CREATED_POLLER combination
    connectivitypack.source.Issue.CREATED_POLLER.subscription.timezone: UTC
    connectivitypack.source.Issue.CREATED_POLLER.subscription.pollingInterval: 1

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
