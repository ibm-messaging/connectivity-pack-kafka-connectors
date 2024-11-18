{{/*
Define the name of the Event Automation Helm Chart Prehook Job for validating the license
*/}}
{{- define "ibm-connectivity-pack.eaPreHookJob" -}}
{{- if .Release.Name }}
{{- default  .Release.Name }}-prehook-job
{{- end }}
{{- end }}



# Function for validating the license
{{- define "ibm-connectivity-pack.validateLicense" -}}

#List of valid licenses supported by Event Automation and Cloud Pak for Integration
{{- $licenseListCP4I := list "L-QYVA-B365MB" "L-JVML-UFQVM4" -}}
{{- $licenseListEA := list "L-AUKS-FKVXVL" -}}


{{- $licenseId := .licenseId | quote -}}

#Validating if the license is supported
{{- $foundCP4ILicense := false }}
{{- range $licenseListCP4I }}
  {{- if eq (quote .) $licenseId }}
    {{- $foundCP4ILicense = true }}
  {{- end }}
{{- end }}

{{- $foundEALicense := false }}
{{- range $licenseListEA }}
  {{- if eq (quote .) $licenseId }}
    {{- $foundEALicense = true }}
  {{- end }}
{{- end }}

{{/*
licenseId: The license provided by the customer during the Helm installation.
licenseListEA: The list of licenses supported by Event Automation.
licenseListCP4I: The list of licenses supported by Cloud Pak for Integration.
*/}}
{{- if not (or $foundCP4ILicense $foundEALicense )}}
  {{- fail (printf "\nInvalid license: %s.\nValid Event Automation licenses are:\n  %s\nValid Cloud Pak for Integration licenses are:\n  %s" $licenseId $licenseListEA $licenseListCP4I) }}
{{- end }}
{{- end }}