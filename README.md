# Connectivity pack Kafka connectors

The Connectivity Pack for Kafka connectors enable streaming data from external data sources, such as Salesforce, into Kafka topics. These [Kafka Connect](http://kafka.apache.org/documentation.html#connect) connectors use the IBM Connectivity Pack to interact with external data sources.

## Contents

- [Prerequisites](#prerequisites)
- [Installing IBM Connectivity Pack](#installing-ibm-connectivity-pack)
- [Starting Kafka Connect](#starting-kafka-connect)
- [Running the Connectors](#running-the-connectors)
- [Uninstalling IBM Connectivity Pack](#uninstalling-ibm-connectivity-pack)
- [License](#license)

## Prerequisites

To run Connectivity Pack Kafka connectors, ensure you have:

- IBM Event Streams installed, and you have the bootstrap address, certificates, and credentials required to access Kafka.
- The external application (for example, Salesforce) configured according to the [application-specific documentation](./applications/salesforce.md), with the required URLs and credentials to access the application.

## Installing IBM Connectivity Pack

IBM Connectivity Pack acts as an interface between Kafka Connect connectors and external systems you wish to connect to. It can be deployed on OpenShift and other Kubernetes platforms by using the IBM Connectivity Pack Helm chart.

To install the IBM Connectivity Pack by using the Helm chart, run the following command:

```bash
helm install <RELEASE-NAME> ibm-connectivity-pack-<CONNECTIVITY-PACK-HELM-CHART-VERSION>.tgz --set license.licenseId=<LICENSE-ID>,license.accept=true
```

Where:

- `<RELEASE-NAME>` is the release name of your choice. for example, `ibm-connectivity-pack`
- `<CONNECTIVITY-PACK-HELM-CHART-VERSION>` is the latest version of the Connectivity Pack Helm chart.
- `license.licenseId=<LICENSE-ID>` is the license identifier (ID) for the program that you purchased. For more information, see [licensing reference](https://ibm.github.io/event-automation/support/licensing/).
- `license.accept` determines whether the license is accepted (default is `false` if not specified).

You can override the default configuration parameters by using the `--set` flag or by using a custom YAML file. For example, to set the `replicaCount` as `3`, you can use `--set replicaCount=3`.

For a complete list of configuration parameters supported by the Helm chart, see [configuring](./ibm-connectivity-pack/README.md#configuring).

## Starting Kafka Connect

Start Kafka Connect runtime and include the configuration, certificates, and connectors for the Connectivity Pack by following these instructions:

1. Create a `KafkaConnect` custom resource to [define Kafka Connect runtime configuration](https://ibm.github.io/event-automation/es/connecting/setting-up-connectors/#starting-kafka-connect).

    - To use the pre-built connector JAR file, set the URL of the latest GitHub release asset as the value for `spec.build.plugins[].artifacts[].url` as shown in the following example:

        ```yaml
        plugins:
          - name: connectivitypack-source-connector
            artifacts:
            - type: jar
              url: https://github.com/ibm-messaging/connectivity-pack-kafka-connectors/releases/download/<VERSION>/connectivity-pack-source-connector-<VERSION>-jar-with-dependencies.jar
        ```

        Where `<VERSION>` is the version of the Connectivity Pack connector JAR file.

    - To use the installed Connectivity Pack with `<RELEASE-NAME>`, update the `spec.template` section with the following configuration and certificates:

      - If you are using Event Streams version 11.5.2 and later, use the following configuration:

        ```yaml
        template:
          connectContainer:
            env:
              - name: CONNECTIVITYPACK_SERVICE_URL
                valueFrom:
                  configMapKeyRef:
                    key: CONNECTIVITYPACK_SERVICE_URL
                    name: <RELEASE-NAME>-config
            volumeMounts:
              - mountPath: /mnt/connectivitypack/certificates
                name: connectivitypack-certs
          pod:
            volumes:
              - name: connectivitypack-certs
                secret:
                  secretName: <RELEASE-NAME>-client-certificate
        ```

      - If you are using earlier versions of Event Streams than 11.5.2, use the following `externalConfiguration`:

        ```yaml
        externalConfiguration:
          env:
            - name: CONNECTIVITYPACK_SERVICE_URL
              valueFrom:
                configMapKeyRef:
                  key: CONNECTIVITYPACK_SERVICE_URL
                  name: <RELEASE-NAME>-config
          volumes:
            - name: connectivitypack-certs
              secret:
                secretName: <RELEASE-NAME>-client-certificate
        ```

        Where `<RELEASE-NAME>` is the Helm release name for your Connectivity Pack installation.

    - The following section explains the environment variables that are used in the Kafka connector configuration:

        - **`CONNECTIVITYPACK_PKCS12_PASSWORD`**: The password that is used to access the PKCS12 certificate store. This environment variable is required for secure communication between the connector and the Connectivity Pack only if the PKCS12 file is password-protected. If the PKCS12 file does not have a password, this can be set as an empty string or skip configuring this environment variable. For example:

            ```yaml
            template:
              connectContainer:
                env:
                  CONNECTIVITYPACK_PKCS12_PASSWORD: <your-pkcs12-password>
            ```

        - **`CONNECTIVITYPACK_CERTS_PATH`**: The file path to the directory containing the certificates required for secure communication. This includes the client certificate, private key, and any intermediate certificates that are needed for secure communication between the connector and the Connectivity Pack. For example:

          ```yaml
          CONNECTIVITYPACK_CERTS_PATH: /mnt/connectivitypack/certificates
          ```

          The path must be mounted correctly within the container to ensure the connector has access to the required certificates. By default, the `CONNECTIVITYPACK_CERTS_PATH` is set to `/mnt/connectivitypack/certificates`. You must update this value to match the location where your certificates are mounted.

        - **`CONNECTIVITYPACK_SERVICE_URL`**: The URL of the Connectivity Pack that the Kafka connector uses to connect. For example:

          ```yaml
          CONNECTIVITYPACK_SERVICE_URL: <connectivity-service-url>
          ```

          You can set this URL by using a `configMapKeyRef` that points to the ConfigMap of the Connectivity Pack or directly set it to the correct endpoint. Ensure that the URL is accessible from the Kafka Connect container.

1. Apply the configured `KafkaConnect` custom resource to start the Kafka Connect runtime and verify that the connector is available for use.

## Running the Connectors

1. Create a `KafkaConnector` custom resource to [define your connector configuration](https://ibm.github.io/event-automation/es/connecting/setting-up-connectors/).

    - Specify `com.ibm.eventstreams.connect.connectivitypacksource.ConnectivityPackSourceConnector` as the connector class name.

    - Configure the connector properties according to the [connector documentation](./connectors/source-connector.md#configuration) and refer to the [application-specific guidance](./applications/salesforce.md#) for a list of permitted values that can be assigned to each property. The following is an example of a connector configuration for Salesforce:

        ```yaml
        apiVersion: eventstreams.ibm.com/v1beta2
        kind: KafkaConnector
        metadata:
          labels:
            # The eventstreams.ibm.com/cluster label identifies the KafkaConnect instance
            # in which to create this connector. That KafkaConnect instance
            # must have the eventstreams.ibm.com/use-connector-resources annotation
            # set to true.
            eventstreams.ibm.com/cluster: cp-connect-cluster
          name: <name>
          namespace: <namespace>
        spec:

          # `tasksMax` should be equal to the number of object-eventType combinations
          # In this example it is 3 (object1 - CREATED, object2 - CREATED, object2 - UPDATED)
          tasksMax: 3

          # Connector class name
          class: com.ibm.eventstreams.connect.connectivitypacksource.ConnectivityPackSourceConnector

          config:
            # Which data source to connect to eg. salesforce
            connectivitypack.source: salesforce

            # URL to access the data source
            connectivitypack.source.url: <URL of the data source instance eg. salesforce login url - `https://login.salesforce.com`>

            # Credentials to access the data source using OAUTH2_PASSWORD authentication.
            connectivitypack.source.credentials.authType: OAUTH2_PASSWORD
            connectivitypack.source.credentials.username: <username>
            connectivitypack.source.credentials.password: <password>
            connectivitypack.source.credentials.clientSecret: <client-secret>
            connectivitypack.source.credentials.clientIdentity: <client-identity>

            # Objects and event-types to read from the datasource
            connectivitypack.source.objects: '<object1>,<object2>,[<object3>]'
            connectivitypack.source.<object1>.events: 'CREATED'
            connectivitypack.source.<object2>.events: 'CREATED,UPDATED'

            # Optional, Specifies the format for Kafka topic names generated by the connector.
            # Placeholders like '${object}' and '${eventType}' will be replaced dynamically
            # based on the connector configuration. Ensure the format resolves to valid Kafka topic names.
            # '${object}.${eventType}' is the default format, but its specified here for clarity.
            connectivitypack.topic.name.format: '${object}.${eventType}'

            # Specifies the converter class used to deserialize the message value.
            # Change this to a different converter (e.g., AvroConverter) if needed.
            value.converter: org.apache.kafka.connect.json.JsonConverter

            # Controls whether the schema is included in the message.
            # Set this to false to disable schema support, or to true to enable schema inclusion (e.g., for Avro).
            value.converter.schemas.enable: false

            # Specifies the converter class used to deserialize the message key.
            # You can change this to another converter if necessary.
            key.converter: org.apache.kafka.connect.json.JsonConverter
        ```

    - Pre-create all Kafka topics as specified by `connectivitypack.topic.name.format` format.

1. Apply the configured `KafkaConnector` custom resource to start the connector and verify that it is running.

## Uninstalling IBM Connectivity Pack

To uninstall the IBM Connectivity Pack by using the Helm chart, run the following command:

```bash
helm uninstall <RELEASE-NAME>
```

Where `<RELEASE-NAME>` is the release name of your Connectivity Pack installation.

## License

Copyright IBM Corp. 2024

IBM Connectivity Pack is available under the IBM Event Automation license and IBM Cloud Pak for Integration license. For more information, see [licensing information](https://ibm.biz/ea-license).
