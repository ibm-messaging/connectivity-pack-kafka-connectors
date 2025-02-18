# Connectivity Pack Kafka connectors

By using the IBM Connectivity Pack, Connectivity Pack Kafka connectors enable data streaming between external systems and Kafka.

## Contents

- [Prerequisites](#prerequisites)
- [Installing the IBM Connectivity Pack](#installing-the-ibm-connectivity-pack)
- [Starting Kafka Connect](#starting-kafka-connect)
- [Running the connectors](#running-the-connectors)
- [License](#license)

## Prerequisites

To run Connectivity Pack Kafka connectors, ensure you have:

- IBM Event Streams installed, and you have the bootstrap address, an image pull secret called [`ibm-entitlement-key`](https://ibm.github.io/event-automation/es/installing/installing/#creating-an-image-pull-secret), certificates, and credentials required to access Kafka.
- The external system (for example, Salesforce) configured according to the [system-specific guidance](./systems/), with the required URLs and credentials to access the system.

  For information about the supported systems, see the [systems](./systems/) folder.

- Either enabled [auto-creation of Kafka topics](https://ibm.github.io/event-automation/es/connecting/setting-up-connectors/#enabling-topic-creation-for-connectors) or pre-created all the required Kafka topics in the format that must be specified in the `connectivitypack.topic.name.format` section of the [`KafkaConnector` custom resource](#running-the-connectors).


## Installing the IBM Connectivity Pack

The Connectivity Pack acts as an interface between Kafka Connect connectors and external systems you want to connect to. It can be deployed on OpenShift and other Kubernetes platforms by using the Connectivity Pack Helm chart.

To install the Connectivity Pack, run the following command:

```bash
helm install <RELEASE-NAME> <CONNECTIVITY-PACK-HELM-CHART-URL> --set license.licenseId=<LICENSE-ID>,license.accept=true -n <NAMESPACE>
```

Where:

- `<RELEASE-NAME>` is the release name of your choice. For example, `ibm-connectivity-pack`
- `<CONNECTIVITY-PACK-HELM-CHART-URL>` is the URL of the latest version of the Connectivity Pack Helm chart. For example: `https://github.com/ibm-messaging/connectivity-pack-kafka-connectors/releases/download/1.0.1/ibm-connectivity-pack-1.0.1.tgz`
- `license.licenseId=<LICENSE-ID>` is the license identifier (ID) for the program that you purchased. For more information, see [licensing reference](https://ibm.github.io/event-automation/support/licensing/).
- `license.accept` determines whether the license is accepted (default is `false` if not specified).
- `<NAMESPACE>` is the namespace where you want to install the Connectivity Pack. This must be in the same namespace where an Event Streams instance is deployed.

You can override the default configuration parameters by using the `--set` flag or by using a custom YAML file. For example, to set the `replicaCount` as `3`, you can use `--set replicaCount=3`.

For more information about installing the Connectivity Pack, including a complete list of configuration parameters supported by the Helm chart, see [installing the Connectivity Pack](./ibm-connectivity-pack/README.md#configuring).

After installation, you can upgrade the Connectivity Pack to the latest version. For more information, see [upgrading the Connectivity Pack](./ibm-connectivity-pack/README.md#upgrading).

## Starting Kafka Connect

Configure the Kafka Connect runtime and include the configuration, certificates, and connectors for the Connectivity Pack by following these instructions.

**Note:** For more information, see [setting up connectors](https://ibm.github.io/event-automation/es/connecting/setting-up-connectors/).

1. Create a `KafkaConnect` custom resource to define the Kafka Connect runtime. An example custom resource is available in the [`examples`](/examples/kafka-connect.yaml) folder. You can edit the example custom resource file to meet on your requirements and to configure the following settings.

    - To use the pre-built connector JAR file, set the URL of the [latest release asset](https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/eventstreams/connectors/connectivitypack/) as the value for `spec.build.plugins[].artifacts[].url` as shown in the following example:

        ```yaml
        plugins:
          - name: connectivitypack-source-connector
            artifacts:
            - type: jar
              url: https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/eventstreams/connectors/connectivitypack/<VERSION>/connectivity-pack-source-connector-<VERSION>-jar-with-dependencies.jar
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

    - The following section explains the environment variables that are used in the Kafka Connect configuration:

        - **`CONNECTIVITYPACK_SERVICE_URL`**: The URL of the Connectivity Pack that the Kafka connector uses to connect. For example:

          ```yaml
          CONNECTIVITYPACK_SERVICE_URL: <connectivity-service-url>
          ```

          You can set this URL by using a `configMapKeyRef` that points to the ConfigMap of the Connectivity Pack or directly set it to the correct endpoint. Ensure that the URL is accessible from the Kafka Connect container.
        
        - **`CONNECTIVITYPACK_CERTS_PATH`**: The file path to the directory containing the certificates required for secure communication. This includes the client certificate, private key, and any intermediate certificates that are required for secure communication between the connector and the Connectivity Pack. For example:

          ```yaml
          CONNECTIVITYPACK_CERTS_PATH: /mnt/connectivitypack/certificates
          ```

          By default, this is set to `/mnt/connectivitypack/certificates`. You can optionally specify this environment variable if your certificates are mounted at a different path.
          
        - **`CONNECTIVITYPACK_PKCS12_PASSWORD`**: The password that is used to access the PKCS12 certificate store. This environment variable is required for secure communication between the connector and the Connectivity Pack only if the PKCS12 file is password-protected. If the PKCS12 file does not have a password, you can set this as an empty string or skip configuring this environment variable. For example:

            ```yaml
            template:
              connectContainer:
                env:
                  CONNECTIVITYPACK_PKCS12_PASSWORD: <your-pkcs12-password>
            ```
            


1. Apply the configured `KafkaConnect` custom resource by using the `kubectl apply` command to start the Kafka Connect runtime.

1. When Kafka Connect is successfully created, verify that the connector is available for use by checking the `status.connectorPlugins` section in the `KafkaConnect` custom resource. For the Connectivity Pack source connector to work, the following plug-in must be present:

   ```yaml
   status:
     connectorPlugins:
       - class: com.ibm.eventstreams.connect.connectivitypacksource.ConnectivityPackSourceConnector
         type: source
         version: <version>
   ```


## Running the Connectors

Configure your connector with information about your external system by following these instructions.

**Note:** For more information, see [setting up connectors](https://ibm.github.io/event-automation/es/connecting/setting-up-connectors/#set-up-a-kafka-connector).

1. Create a `KafkaConnector` custom resource to define your connector configuration. An example custom resource is available in the [`examples`](/examples/kafka-connector-source.yaml) folder. You can edit the custom resource file based on your requirements.

1. Specify `com.ibm.eventstreams.connect.connectivitypacksource.ConnectivityPackSourceConnector` as the connector class name.

1. Configure the connector properties such as the external system you want to connect to, objects, authentication, and data mapping in the `config` section as described in the [source connector documentation](./connectors/source-connector.md#configuration). You can find the supported values for your source system in the [system-specific guidance](./systems/salesforce.md#). The following is an example of a connector configuration for Salesforce:

   ```yaml
   config:
     # Which source system to connect to, for example, salesforce
     connectivitypack.source: salesforce

     # URL to access the source system,  for example, `https://<your-instance-name>.salesforce.com`
     connectivitypack.source.url: <URL-of-the-data-source-instance>>

     # Credentials to access the source system using BASIC_OAUTH authentication.
     connectivitypack.source.credentials.authType: BASIC_OAUTH
     connectivitypack.source.credentials.accessTokenBasicOauth: <access-token>
     connectivitypack.source.credentials.refreshTokenBasicOauth: <refresh-token>
     connectivitypack.source.credentials.clientSecret: <client-secret>
     connectivitypack.source.credentials.clientIdentity: <client-identity>

     # Objects and event-types to read from the datasource
     connectivitypack.source.objects: '<object1>,<object2>,[<object3>]'
     connectivitypack.source.<object1>.events: 'CREATED'
     connectivitypack.source.<object2>.events: 'CREATED,UPDATED'

     # Optional, sets the format for Kafka topic names created by the connector.
     # You can use placeholders like '${object}' and '${eventType}', which the connector will replace automatically.
     # Including '${object}' or '${eventType}' in the format is optional. For example, '${object}-topic-name' is a valid format.
     # By default, the format is '${object}-${eventType}', but it's shown here for clarity.
     connectivitypack.topic.name.format: '${object}-${eventType}'

     # Specifies the converter class used to deserialize the message value.
     # Change this to a different converter (for example, AvroConverter) if needed.
     value.converter: org.apache.kafka.connect.json.JsonConverter

     # Controls whether the schema is included in the message.
     # Set this to false to disable schema support, or to true to enable schema inclusion (for example, for Avro).
     value.converter.schemas.enable: false
   ```

1. Apply the configured `KafkaConnector` custom resource by using the `kubectl apply` command to start the connector.
1. Verify that the connector is running by checking the `status` section in the `KafkaConnector` custom resource:

   ```yaml
   Status:
    Conditions:
       Last Transition Time: 2024-07-13T07:56:40.943007974Z
       Status:               True
       Type:                 Ready
    Connector Status:
       Connector:
         State:      RUNNING
   ```


## License

Copyright IBM Corp. 2024

IBM Connectivity Pack is licensed under the [IBM Event Automation license and IBM Cloud Pak for Integration license](https://ibm.biz/ea-license), while the Helm chart and documentation are licensed under the [Apache License, Version 2.0](./ibm-connectivity-pack/license.md).

