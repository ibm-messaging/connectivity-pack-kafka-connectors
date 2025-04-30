# Connectivity Pack sink connector

The Connectivity Pack sink connector reads messages from Kafka topics and writes them to sink systems, such as Google BigQuery. These [Kafka Connect](http://kafka.apache.org/documentation.html#connect) connectors use the [IBM Connectivity Pack](../ibm-connectivity-pack/README.md) to enable the data flow between the Kafka and the sink system.

The connector can be configured to perform `INSERT`, `UPDATE`, or `UPSERT` operations by specifying the sink system, an object and the associated action that is to be performed.

The connector uses a Connectivity Pack instance as a bridge that consumes messages from the Kafka topics and sends them to the sink system for further actions.

## Configuration

The following configuration options are supported in all the available sink connectors and must be configured in the `config` section of the `KafkaConnector` custom resource.

### Sink system

| Property                | Type      | Description                                                   | Valid values    |
|-------------------------| --------- |---------------------------------------------------------------|-----------------|
| `connectivitypack.sink` | `string`  | Specifies the sink system to which the connector communicates with. | A valid sink system, for example, `googlebigquery` |


### Data mapping

| Property                                      | Type        | Description                                                                                                                                                                                                                | Valid values                                                                                                                   |
|-----------------------------------------------|-------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| `connectivitypack.sink.object`                | `string`    | Specifies the object in the sink system that the connector will interact with.                                                                                                                                             | Values depend on your sink system. For example, in Google BigQuery, valid values can be any of the Google BigQuery table names.             |
| `connectivitypack.sink.action`                | `string`    | Specifies the action to be performed on the object.                                                                                                                                                         | Actions supported by the object in your sink system. For example, in Google BigQuery, supported actions are `INSERT`, `UPDATE` and `UPSERT`. |
| `topics`                                      | `string`    | A single topic name or a comma-separated list of exact topic names the connector must subscribe to.                                                                                                                      |                                                                                                                                | 

## Single Message Transformations (SMTs)

Connectors can be configured with [transformations](https://kafka.apache.org/documentation.html#connect_transforms) to manipulate Kafka record keys, values, and headers. With these Single Message Transformations (SMTs), you can extract, cast, or modify fields for better control over your streaming data.

The following is an example of a Google BigQuery sink connector configured to filter unwanted fields and rename field names from the messages in the topic:

1. Consider a record with the following structure:

   ```json
   {
   "CreatedDate": "2024-12-11T11:00:32.299Z",
   "CreatedById": "005dM000009CeUMQA0",
   "OrderStatus__c": "B\\M*3G0\"q!",
   "CustomerEmail__c": "usernmae@hotmail.com",
   "OrderTotal__c": 626.48,
   "OrderDate__c": "2024-02-18T16:05:06.506Z",
   "OrderId__c": "d76306e1-2ff8-4f8d-8bb0-ac91a1caf25b"
   }
   ```


2. To filter unwanted fields and rename fields, you can define a series of transformations as follows:

   ```shell
   transforms: 'FilterFields,RenameFields'

   # Transform: Filter unwanted fields
   transforms.FilterFields.type: org.apache.kafka.connect.transforms.ReplaceField$Value
   transforms.FilterFields.exclude: 'CreatedDate,CreatedById'
   # Result: Filters 'CreatedDate' and 'CreatedById' fields from message.

   # Transform: Rename the following fields according to the mapping given
   transforms.RenameFields.type: org.apache.kafka.connect.transforms.ReplaceField$Value
   transforms.RenameFields.renames: 'OrderId__c:order_id,OrderDate__c:order_date,OrderStatus__c:order_status,OrderTotal__c:order_total,CustomerEmail__c:customer_email'
   # Result: The fields will be renamed according to the mapping given before performing actions in the google bigquery tables
   ```
