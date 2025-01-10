# Installing the IBM Connectivity Pack

The Connectivity Pack acts as an interface between Kafka Connect connectors and external systems you want to connect to. It can be deployed on OpenShift and other Kubernetes platforms by using the Connectivity Pack Helm chart.

## Prerequisites

- OpenShift 4.12 or later
- Kubernetes version 1.25 or later
- Helm CLI 3.0 or later

## Installing

To install the Connectivity Pack, run the following command:

```bash
helm install <RELEASE-NAME> <CONNECTIVITY-PACK-HELM-CHART-URL> --set license.licenseId=<LICENSE-ID>,license.accept=true -n <NAMESPACE>
```

Where:

- `<RELEASE-NAME>` is the release name of your choice. For example, `ibm-connectivity-pack`
- `<CONNECTIVITY-PACK-HELM-CHART-URL>` is the URL of the latest version of the Connectivity Pack Helm chart. For example: `https://github.com/ibm-messaging/connectivity-pack-kafka-connectors/releases/download/1.0.0/ibm-connectivity-pack-1.0.0.tgz`
- `license.licenseId=<LICENSE-ID>` is the license identifier (ID) for the program that you purchased. For more information, see [licensing reference](https://ibm.github.io/event-automation/support/licensing/).
- `license.accept` determines whether the license is accepted (default is `false` if not specified).
- `<NAMESPACE>` is the namespace where the Connectivity Pack is deployed.

You can override the default configuration parameters by using the `--set` flag or by using a custom YAML file. For example, to set the `replicaCount` as `3`, you can use `--set replicaCount=3`.

For a complete list of configuration parameters supported by the helm chart, see [Configuring](#configuring).

## Uninstalling

To uninstall the Connectivity Pack by using the Helm chart, run the following command:

```bash
helm uninstall <RELEASE-NAME> -n <NAMESPACE>
```

Where:

- `<RELEASE-NAME>` is the release name of your Connectivity Pack installation.
- `<NAMESPACE>` is the namespace where the Connectivity Pack is deployed.

## Configuring

You can configure your installation by adding configurable parameters through the `--set` flag in your `helm install` command or by using a custom YAML file.

The following table lists the configurable parameters of the Connectivity Pack Helm chart and their default values:

| Parameter                              | Description                                                                                                                                                                                                             | Default                                                                                      |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| license.accept                         | Indicates acceptance of license terms                                                                                                                                                                                   | false                                                                                        |
| license.licenseId                      | license identifier (ID) for the program that you purchased as per [licensing reference](https://ibm.github.io/event-automation/support/licensing/)                                                                      |
| replicaCount                           | Number of replicas of the pod                                                                                                                                                                                           | 1                                                                                            |
| bunyan                                 | Log configuration for the system                                                                                                                                                                                   | See [Logging](#logging) and the sample [values.yaml](values.yaml) file for more information. |
| annotations                            | Override with product specific annotations                                                                                                                                                                              | See [values.yaml](values.yaml) for more information.                                         |
| environmentVariables                   | Yaml object of environment variables to be added in action and event services                                                                                                                                           |
| image.registry                         | Image registry URL                                                                                                                                                                                                      | cp.icr.io                                                                                    |
| image.path                             | Image namespace or the path under image registry before image name and digest                                                                                                                                           | cp/ibm-eventstreams                                                                          |
| image.imagePullSecretName              | Kubernetes image pull secret if it already exists in the namespace, if not add the following image pull details to create new secret                                                                                    | ibm-entitlement-key                                                                          |
| image.imagePullEmail                   | Image pull secret email ID                                                                                                                                                                                              | dummyEmail                                                                                   |
| image.imagePullUsername                | Image pull username                                                                                                                                                                                                     | iamapikey                                                                                    |
| image.imagePullPassword                | Image pull password                                                                                                                                                                                                     | dummyPassword                                                                                |
| certificate.MTLSenable                 | Enable mTLS else fallback to TLS                                                                                                                                                                                        | true                                                                                         |
| certificate.generate                   | Generate new certificates for mTLS/TLS, this should be used for certificate rotation. However, if `certificate.serverSecretName` and `certificate.clientSecretName` are already specified, this option will be ignored. | true                                                                                         |
| certificate.clientSecretName           | Already existing mTLS client certificate Kubernetes secret name, if left empty new certificate will be generated on helm install                                                                                        |
| certificate.clientCertPropertyName     | Property name in secret which holds mTLS client certificate                                                                                                                                                             | 'tls.crt'                                                                                    |
| certificate.clientCertKeyPropertyName  | Property name in secret which holds mTLS client certificate key                                                                                                                                                         | 'tls.key'                                                                                    |
| certificate.clientCertPKCSPropertyName | Property name in secret which holds PKCS12 client certificate                                                                                                                                                           | 'pkcs.p12'                                                                                   |
| certificate.pkcsPassword               | PKCS12 file password                                                                                                                                                                                                    |
| certificate.serverSecretName           | Already existing mTLS/TLS server certificate Kubernetes secret name. If left empty, a new certificate will be generated during Connectivity Pack installation.                                                          |
| certificate.serverCertPropertyName     | Property name in secret which holds mTLS/TLS server certificate                                                                                                                                                         | 'tls.crt'                                                                                    |
| certificate.serverCertKeyPropertyName  | Property name in secret which holds mTLS/TLS server certificate key                                                                                                                                                     | 'tls.key'                                                                                    |
| certificate.caCertPropertyName         | Property name in secret which holds certificate authority certificate                                                                                                                                                   | 'ca.crt'                                                                                     |
| route.enable                           | Enable OpenShift Route for external access update domain and make `certificate.generate` to true so that certificate has the domain entry, _Enable only for OpenShift cluster_                                          | false                                                                                        |
| route.domain                           | Domain or subdomain of cluster                                                                                                                                                                                          | 'example.com'                                                                                |
| basicAuth.enable                       | Enable basic authentication for service                                                                                                                                                                                 | false                                                                                        |
| basicAuth.username                     | Basic auth username                                                                                                                                                                                                     | csuser                                                                                       |
| preHook.image                          | Prehook job image name                                                                                                                                                                                                  | connectivity-pack-prehook                                                                    |
| preHook.digest                         | Prehook job image digest                                                                                                                                                                                                | sha256:a401875a35737d377e7a18753ba26a52999d8c060589256e32263008c5f19747                      |
| proxy.image                            | Proxy service container image name                                                                                                                                                                                      | connectivity-pack-proxy                                                                      |
| proxy.digest                           | Proxy service container image digest                                                                                                                                                                                    | sha256:8ee2b1fe96f00fb90bd25df122097f3653ba7b83eb6808a5a3971e21548a5fe4                      |
| action.image                           | Action service container image name                                                                                                                                                                                     | action-connectors                                                                            |
| action.digest                          | Action service container image digest                                                                                                                                                                                   |
| action.resources                       | Action service container resources Check Kubernetes deployment resources for more details                                                                                                                               | See [values.yaml](values.yaml)                                                               |
| event.enable                           | Enable event container                                                                                                                                                                                                  | true                                                                                         |
| event.image                            | Event service container image name                                                                                                                                                                                      | event-connectors                                                                             |
| event.digest                           | Event service container image digest                                                                                                                                                                                    |
| event.resources                        | Event service container resources Check Kubernetes deployment resources for more details                                                                                                                                | See [values.yaml](values.yaml)                                                               |
| javaservice.enable                     | Enable java-service container                                                                                                                                                                                           | false                                                                                        |
| javaservice.image                      | java-service container image name                                                                                                                                                                                       | connector-service-java                                                                       |
| javaservice.digest                     | java-service container image digest                                                                                                                                                                                     |
| javaservice.resources                  | java-service container resources Check Kubernetes deployment resources for more details                                                                                                                                 | See [values.yaml](values.yaml)                                                               |
| autoScaling.enable                     | Enable auto-scaling                                                                                                                                                                                                     | false                                                                                        |
| autoScaling.minReplicas                | Minimum replicas for auto-scaling                                                                                                                                                                                       | 1                                                                                            |
| autoScaling.maxReplicas                | Maximum replicas for auto-scaling                                                                                                                                                                                       | 5                                                                                            |
| autoScaling.cpuUtilization             | Target CPU utilization percentage for auto-scaling                                                                                                                                                                      | 70                                                                                           |
| autoScaling.memoryUtilization          | Target memory utilization percentage for auto-scaling                                                                                                                                                                   | 70                                                                                           |

### Configuring your mTLS

The Helm chart supports both mTLS and TLS through `certificate.MTLSenable`:

**mTLS Enabled:** Certificates are generated and stored in a Kubernetes secret. To regenerate certificates, set `certificate.generate` to `true`.

**mTLS disabled:** If not enabled, the service defaults to TLS.

### OpenShift Route

To enable an OpenShift Route for external access, set `route.enable` to `true`. This exposes your system outside the cluster through an OpenShift route.

### Basic authentication

Basic authentication can be enabled for services by setting `basicAuth.enable` to `true`.

### Auto-Scaling

The chart supports horizontal pod auto-scaling based on CPU and memory utilization. Add and modify the following snippet in the `values.yaml` file:

```yaml
autoScaling:
  enable: true
  minReplicas: 1
  maxReplicas: 5
  cpuUtilization: 70
  memoryUtilization: 70
```

### Logging

You can configure detailed logging by using the `bunyan` configuration in the `values.yaml` file. This supports various logging levels such as `info`, `debug`, and `trace`, and output formats.

```js
  {
      "loglevel": 'trace'|'debug'|'info'|'warn'|'error'|'fatal', //  default logging level of all streams (string)
      "logsrc": true|false, // include the source filename and line-number (boolean)
      "logstdout": {
        "loglevel": 'trace'|'debug'|'info'|'warn'|'error'|'fatal'
      },
      "logstdouttext": {
        "ignoredlogsources": ["shoutyFile.js", "somedir/loudClass.js"] // ignore logs from files with a path matching any of these regexes (array of RegExp strings).  This will set 'logsrc' to true"
      },
      "logstdoutlogdna": {},
      "logfile": {
        "loglevel": 'trace'|'debug'|'info'|'warn'|'error'|'fatal',
        "filename": "mydir/myfile.log", // The path and name of a file to write logs to (string)
        "rotate": true|false, // if true turns on bunyan 'rotating-file' log file rotation, (boolean - defaults to false)
        "rotatecount": 3, // number of files for rotation if active, (number - defaults to 10)
        "rotateperiod": "12h", // log rotation period for rotation if active, time duration eg '1d' or '6h', (string defaults to '1d'
      },
      "logstdoutdashboard" : {
        "logformat": "basic"|"json" // optional, default=basic
      },
      logstdoutwo: {},
      "logdna": {
        "url": 'https://logs.eu-de.logging.cloud.ibm.com/logs/ingest', // ingestion URL for the logDNA instance (string - found on the logDNA dashboard, under '?' (bottom left) > 'REST API' > The value MUST end with /ingest, trim off all the query parameters
        "key": "abc123def456ghi789abc123def456gh", // ingestion key for the logDNA instance (string - found on the logDNA dashboard, under 'settings' > 'ORGANIZATION' > ' API Keys'
        "flushlimit": 1000000, // maximum log buffer size (in bytes) allowed before which the buffer is automatically flushed (default=5000000)
        "flushinterval": 100 //  duration (in ms) to wait from the last flush before the next automated log buffer flush, when flushlimit isn't exceeded (default=250)"
      }
    }
```


