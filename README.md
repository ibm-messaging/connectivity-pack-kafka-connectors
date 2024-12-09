# Connectivity pack Kafka connectors

The Connectivity Pack for Kafka connectors enable streaming data from external data sources, such as Salesforce, into Kafka topics. These [Kafka Connect](http://kafka.apache.org/documentation.html#connect) connectors use the `ibm-connectivity-pack` to interact with external data sources, ensuring at-least-once delivery.

## Contents

- [Prerequisites](#prerequisites)
- [Installing IBM connectivity pack](#installing-ibm-connectivity-pack)
- [Starting Kafka Connect](#starting-kafka-connect)
- [Running the Connectors](#running-the-connectors)
- [Uninstalling IBM connectivity pack](#uninstalling-ibm-connectivity-pack)
- [License](#License)

## Prerequisites
To run Connectivity Pack Kafka connectors, ensure you have:

- IBM Event Streams installed, and you have the bootstrap address, certificates, and credentials required to access Kafka.
- The external application (for example, Salesforce) configured according to the [application-specific documentation](./applications/salesforce.md), with the required URLs and credentials to access the application.

## Installing IBM Connectivity Pack

IBM connectivity pack acts as an interface between Kafka Connect connectors and external systems you wish to connect to. It can be deployed on OpenShift and other Kubernetes platforms using the `ibm-connectivity-pack` Helm chart. 

To install the connectivity pack by using the Helm chart, run the following command:

```bash
helm install <my-release> ibm-connectivity-pack-1.0.0.tgz --set license.licenseId=<license-id>,license.accept=true
```

where:

- `my-release` is the release name of your choice.
- `license.licenseId` is the license identifier (ID) for the program that you purchased. For more information, see [licensing reference](https://ibm.github.io/event-automation/support/licensing/).
- `license.accept` determines whether the license is accepted (default is `false` if not specified).



You can override the default configuration parameters by using the `--set` flag or by using a custom YAML file. For example, to set the `replicaCount` as `3`, you can use `--set replicaCount=3`.

For a complete list of configuration parameters supported by the helm chart, see [Configuring](./ibm-connectivity-pack/README.md#configuring).

## Starting Kafka Connect

Start Kafka Connect runtime and include the configuration, certificates, and connectors for the connectivity pack by following these instructions:

1. Create a `KafkaConnect` custom resource to [define Kafka Connect runtime configuration](https://ibm.github.io/event-automation/es/connecting/setting-up-connectors/#starting-kafka-connect).

    - To use the pre-built connector JAR file, set the URL of the latest GitHub release asset as the value for `spec.build.plugins[].artefacts[].url` as shown in the following example: 
    
        ```yaml
        plugins:
          - name: connectivitypack-source-connector
            artifacts:
            - type: jar
              url: https://github.com/ibm-messaging/connectivity-pack-kafka-connectors/releases/download/<version>/connectivity-pack-source-connector-<version>-jar-with-dependencies.jar
        ```
    - To use the installed connectivity pack with <release-name>, update the `spec.template` section with the following configuration and certificates:

        ```yaml
        template:
          connectContainer:
            env:
              - name: CONNECTIVITYPACK_SERVICE_URL
                valueFrom:
                  configMapKeyRef:
                    key: CONNECTIVITYPACK_SERVICE_URL
                    name: <release-name>-config
            volumeMounts:
              - mountPath: /mnt/kafka/certificates/connectivitypack-certs
                name: connectivitypack-certs
          pod:
            volumes:
              - name: connectivitypack-certs
                secret:
                  secretName: <release-name>-client-certificate 
        ```
        where <release-name> is the Helm release name for your connectivity pack installation.

1. Apply the configured `KafkaConnect` custom resource to start the Kafka Connect runtime and verify that the connector is available for use.

## Running the Connectors

1. Create a `KafkaConnector` custom resource to [define your connector configuration](https://ibm.github.io/event-automation/es/connecting/setting-up-connectors/).

    - Specify `com.ibm.eventstreams.connect.connectivitypacksource.ConnectivityPackSourceConnector` as the connector class name.

    - Configure the connector properties according to the [connector documentation](./connectors/source-connector.md#configuration) and refer to the [application-specific guidance](./applications/salesforce.md#) for a list of permitted values that can be assigned to each property. The following is an example of a connector configuration for Salesforce:

        ```yaml
        config:
          # which application to connect to
          connectivitypack.source: salesforce

          # url to access the application
          connectivitypack.source.url: <salesforce-url>

          # credentials to access the application
          connectivitypack.source.credentials.authType: <auth-type>>
          connectivitypack.source.credentials.username: <username>
          connectivitypack.source.credentials.password: <pasword>
          connectivitypack.source.credentials.clientSecret: <client-secret>
          connectivitypack.source.credentials.clientIdentity: <client-identity>

          # objects and event-types to read from the datasource
          connectivitypack.source.objects: '<object1>[,<object2>]'
          connectivitypack.source.$object.events: `CREATED`
        
          # Should be equal to the number of object-eventType combinations
          tasks.max: 1

          # optional topic name format
          connectivitypack.topic.name.format: '${object}.${eventType}'  
        
          # standard kafka connector properties
          value.converter.schemas.enable: false
          value.converter: org.apache.kafka.connect.json.JsonConverter
          key.converter: org.apache.kafka.connect.json.JsonConverter
        ```

    - Pre-create all Kafka topics as specified by `connectivitypack.topic.name.format` format.
    
1. Apply the configured `KafkaConnector` custom resource to start the connector and verify that it is running.

## Uninstalling IBM Connectivity Pack 

To uninstall the connectivity pack by using the Helm chart, run the following command:

```bash
helm uninstall <my-release>
```
where:
- `my-release` is the release name of your installation.

## License

Copyright IBM Corp. 2024

The `connectivity-pack kafka connectors` are available under the IBM Event Automation license and IBM Cloud Pak for Integration license. For more information, see [licensing information](https://ibm.biz/ea-license).
