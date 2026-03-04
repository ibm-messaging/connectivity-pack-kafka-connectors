# ServiceNow

The ServiceNow sink connector uses the ServiceNow API to write data from Kafka topics into ServiceNow tables. You can use this connector to create, update, upsert, or delete records in ServiceNow objects such as incidents, problems, assets, departments, tickets, system users, and more.


## Pre-requisites

To use the ServiceNow connector, ensure that you have the required credentials and API access to your ServiceNow instance.

## Connecting to ServiceNow

The `connectivitypack.sink` and the associated ServiceNow resource configurations in the `KafkaConnector` custom resource provide the required information to connect to ServiceNow.

| Name                      | Value or Description                                                                 |
|---------------------------|--------------------------------------------------------------------------------------|
| `connectivitypack.sink`   | `servicenow`                                                                         |
| `connectivitypack.sink.url` | Base URL of your ServiceNow instance. For example: `https://<instance>.service-now.com`. |

## Supported authentication mechanisms

You can configure the following authentication mechanisms for ServiceNow in the `KafkaConnector` custom resource:

| Authentication Type  | System Type | Use Case  | Required Credentials  | `KafkaConnector` configuration  |
|----------------------|-------------|-----------|-----------------------|---------------------------------|
| Basic authentication | ServiceNow  | Supported for username-password access. | - `username`: The ServiceNow username.<br> - `password`: The ServiceNow password.                                         | `connectivitypack.sink.authType: BASIC`<br>`connectivitypack.sink.credentials.username: <username>`<br>`connectivitypack.sink.credentials.password: <password>`                         |
| BASIC_OAUTH  | ServiceNow  | Supported for OAuth authentication. | - `clientId`: The OAuth client ID.<br> - `clientSecret`: The OAuth client secret.<br> - `username`<br> - `password`      | `connectivitypack.sink.authType: OAUTH_PASSWORD`<br>`connectivitypack.sink.credentials.clientId: <clientId>`<br>`connectivitypack.sink.credentials.clientSecret: <clientSecret>`<br>`connectivitypack.sink.credentials.username: <username>`<br>`connectivitypack.sink.credentials.password: <password>` |


## Supported objects and actions

The ServiceNow sink connector supports the following objects and their actions when processing data from Kafka topics:

| Object             | Action | Description                                          | KafkaConnector configuration                                                                                                       |
|---------------------|--------|------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| incident        | CREATE | Creates a new incident record in ServiceNow.         | `connectivitypack.sink.object: incident`<br>`connectivitypack.sink.action: CREATE`                                               |
|                     | UPSERT | Creates or updates an incident record by key.        | `connectivitypack.sink.object: incident`<br>`connectivitypack.sink.action: UPSERT`<br>`connectivitypack.sink.object.key: sys_id ` |
|                     | UPDATE | Updates an existing incident record.                | `connectivitypack.sink.object: incident`<br>`connectivitypack.sink.action: UPDATE`<br>`connectivitypack.sink.object.key: sys_id` |
|                     | DELETE | Deletes an incident record.                         | `connectivitypack.sink.object: incident`<br>`connectivitypack.sink.action: DELETE`<br>`connectivitypack.sink.object.key: sys_id` |
| alm_asset        | CREATE | Creates a new asset record in ServiceNow.            | `connectivitypack.sink.object: alm_asset`<br>`connectivitypack.sink.action: CREATE`                                              |
|                     | UPSERT | Creates or updates an asset record by key.          | `connectivitypack.sink.object: alm_asset`<br>`connectivitypack.sink.action: UPSERT`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | UPDATE | Updates an existing asset record.                   | `connectivitypack.sink.object: alm_asset`<br>`connectivitypack.sink.action: UPDATE`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | DELETE | Deletes an asset record.                            | `connectivitypack.sink.object: alm_asset`<br>`connectivitypack.sink.action: DELETE`<br>`connectivitypack.sink.object.key: sys_id`|
| cmn_department   | CREATE | Creates a new department record.                    | `connectivitypack.sink.object: cmn_department`<br>`connectivitypack.sink.action: CREATE`                                         |
|                     | UPSERT | Creates or updates a department record by key.      | `connectivitypack.sink.object: cmn_department`<br>`connectivitypack.sink.action: UPSERT`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | UPDATE | Updates an existing department record.              | `connectivitypack.sink.object: cmn_department`<br>`connectivitypack.sink.action: UPDATE`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | DELETE | Deletes a department record.                        | `connectivitypack.sink.object: cmn_department`<br>`connectivitypack.sink.action: DELETE`<br>`connectivitypack.sink.object.key: sys_id`|
| sys_user         | CREATE | Creates a new user record.                          | `connectivitypack.sink.object: sys_user`<br>`connectivitypack.sink.action: CREATE`  |
|                     | UPSERT | Creates or updates a user record by key.            | `connectivitypack.sink.object: sys_user`<br>`connectivitypack.sink.action: UPSERT`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | UPDATE | Updates an existing user record.                    | `connectivitypack.sink.object: sys_user`<br>`connectivitypack.sink.action: UPDATE`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | DELETE | Deletes a user record.                              | `connectivitypack.sink.object: sys_user`<br>`connectivitypack.sink.action: DELETE`<br>`connectivitypack.sink.object.key: sys_id`|
| ticket           | CREATE | Creates a new ticket record.                        | `connectivitypack.sink.object: ticket`<br>`connectivitypack.sink.action: CREATE`                                               |
|                     | UPSERT | Creates or updates a ticket record by key.          | `connectivitypack.sink.object: ticket`<br>`connectivitypack.sink.action: UPSERT`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | UPDATE | Updates an existing ticket record.                  | `connectivitypack.sink.object: ticket`<br>`connectivitypack.sink.action: UPDATE`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | DELETE | Deletes a ticket record.                            | `connectivitypack.sink.object: ticket`<br>`connectivitypack.sink.action: DELETE`<br>`connectivitypack.sink.object.key: sys_id`|
| problem          | CREATE | Creates a new problem record.                       | `connectivitypack.sink.object: problem`<br>`connectivitypack.sink.action: CREATE`                                             |
|                     | UPSERT | Creates or updates a problem record by key.         | `connectivitypack.sink.object: problem`<br>`connectivitypack.sink.action: UPSERT`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | UPDATE | Updates an existing problem record.                 | `connectivitypack.sink.object: problem`<br>`connectivitypack.sink.action: UPDATE`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | DELETE | Deletes a problem record.                           | `connectivitypack.sink.object: problem`<br>`connectivitypack.sink.action: DELETE`<br>`connectivitypack.sink.object.key: sys_id`|
| kb_knowledge     | CREATE | Creates a new knowledge record.                     | `connectivitypack.sink.object: kb_knowledge`<br>`connectivitypack.sink.action: CREATE`                                       |
|                     | UPSERT | Creates or updates a knowledge record by key.       | `connectivitypack.sink.object: kb_knowledge`<br>`connectivitypack.sink.action: UPSERT`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | UPDATE | Updates an existing knowledge record.               | `connectivitypack.sink.object: kb_knowledge`<br>`connectivitypack.sink.action: UPDATE`<br>`connectivitypack.sink.object.key: sys_id`|
|                     | DELETE | Deletes a knowledge record.                         | `connectivitypack.sink.object: kb_knowledge`<br>`connectivitypack.sink.action: DELETE`<br>`connectivitypack.sink.object.key: sys_id`|
| sys_journal_field    | CREATE | Creates a new comment record.                       | `connectivitypack.sink.object: sys_journal_field`<br>`connectivitypack.sink.action: CREATE`<br>`connectivitypack.sink.resource.parentType: <parent_table>`<br>`connectivitypack.sink.resource.CommentOwnerId: <sys_id of parentType>` <br> **Note:** Parent type value must be `ticket` or `incident`.|
|                          | UPSERT | Creates or updates a comment record by key.         | `connectivitypack.sink.object: sys_journal_field`<br>`connectivitypack.sink.action: UPSERT`<br>`connectivitypack.sink.object.key: sys_id`<br>`connectivitypack.sink.resource.parentType: <parent_table>`<br>`connectivitypack.sink.resource.CommentOwnerId: <sys_id of parentType>` <br> **Note:** Parent type value must be `ticket` or `incident`. |
|                          | UPDATE | Updates an existing comment record.                | `connectivitypack.sink.object: sys_journal_field`<br>`connectivitypack.sink.action: UPDATE`<br>`connectivitypack.sink.object.key: sys_id`<br>`connectivitypack.sink.resource.parentType: <parent_table>`<br>`connectivitypack.sink.resource.CommentOwnerId: <sys_id of parentType>` <br> **Note:** Parent type value must be `ticket` or `incident`. |
|                          | DELETE | Deletes a comment record.                          | `connectivitypack.sink.object: sys_journal_field`<br>`connectivitypack.sink.action: DELETE`<br>`connectivitypack.sink.object.key: sys_id`  |  
| sys_attachment     | CREATE | Creates a new attachment record.                 | `connectivitypack.sink.object: sys_attachment`<br>`connectivitypack.sink.action: CREATE`<br>`connectivitypack.sink.resource.parentType: <parent_table_name>`<br>`connectivitypack.sink.resource.AttachmentOwnerId: <sys_id of parentType>` <br> **Note:** Parent type value must be `ticket`, `incident`, `problem`, `alm_asset`, `cmn_department`, or `sys_user`. |
|                       | DELETE | Deletes an attachment record.                   | `connectivitypack.sink.object: sys_attachment`<br>`connectivitypack.sink.action: DELETE`<br>`connectivitypack.sink.object.key: sys_id`                          |


## Example configuration

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
  class: com.ibm.eventstreams.connect.connectivitypack.sink.ConnectivityPackSinkConnector
  config:
    # Which sink system to connect to
    connectivitypack.sink: servicenow

    # Type of authentication to use for the sink system
    connectivitypack.sink.authType: BASIC 

    # Credentials to access the sink system using BASIC authentication.
    connectivitypack.sink.credentials.username: <username>
    connectivitypack.sink.credentials.password: <password> 

    # Endpoint URL of the sink system
    connectivitypack.sink.endpoint.url: <endpoint URL of servicenow instance>

    # Object
    connectivitypack.sink.object: sys_journal_field

    # Action to perform on the object (create, upsert, update, delete)
    connectivitypack.sink.action: create
    
    # For CREATE, UPDATE, UPSERT operation on sys_journal_field
    connectivitypack.sink.resource.parentType: incident
    connectivitypack.sink.resource.CommentOwnerId: <sys_id of incident record>

    # For UPSERT, UPDATE, DELETE action (Not required for CREATE)
    connectivitypack.sink.object.key: sys_id

    topics: <topic from which messages are consumed>

    value.converter: org.apache.kafka.connect.json.JsonConverter
    value.converter.schemas.enable: false
  tasksMax: 1
```
