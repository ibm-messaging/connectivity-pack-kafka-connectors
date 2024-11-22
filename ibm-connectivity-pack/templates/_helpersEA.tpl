{{/*
Define the name of the Event Automation Helm Chart Prehook Job for validating the license
*/}}
{{- define "ibm-connectivity-pack.eaPreHookJob" -}}
{{- if .Release.Name }}
{{- default  .Release.Name }}-prehook-job
{{- end }}
{{- end }}

{{/*
Define the name of the Event Automation Helm Chart Prehook Job for validating the license
*/}}
{{- define "ibm-connectivity-pack.eaPostHookJob" -}}
{{- if .Release.Name }}
{{- default  .Release.Name }}-posthook-job
{{- end }}
{{- end }}


{{/*
Create the name of the service
*/}}
{{- define "ibm-connectivity-pack.eaPostHookJobSa" -}}
{{- if .Release.Name }}
{{- include "ibm-connectivity-pack.eaPostHookJob" . }}-sa
{{- end }}
{{- end }}


{{/*
Create the name of the service
*/}}
{{- define "ibm-connectivity-pack.eaPostHookJobRole" -}}
{{- if .Release.Name }}
{{- include "ibm-connectivity-pack.eaPostHookJob" . }}-creator
{{- end }}
{{- end }}

{{/*
Create the name of the service
*/}}
{{- define "ibm-connectivity-pack.eaPostHookJobRoleBinding" -}}
{{- if .Release.Name }}
{{- include "ibm-connectivity-pack.eaPostHookJob" . }}-creator-binding
{{- end }}
{{- end }}


# Function for fetching the license
{{- define "ibm-connectivity-pack.fetchLicense" -}}

{{- $licenseListCP4I := list "L-QYVA-B365MB" "L-JVML-UFQVM4" -}}
{{- $licenseListEA := list "L-AUKS-FKVXVL" -}}

{{- $licenseId := .licenseId | quote -}}

{{- $foundCP4ILicense := false }}
{{- $foundEALicense := false }}
{{- $licenseType := "" }}

{{- range $licenseListCP4I }}
  {{- if eq (quote .) $licenseId }}
    {{- $foundCP4ILicense = true }}
    {{- $licenseType = "CP4I" }}
  {{- end }}
{{- end }}

{{- range $licenseListEA }}
  {{- if eq (quote .) $licenseId }}
    {{- $foundEALicense = true }}
    {{- $licenseType = "EA" }}
  {{- end }}
{{- end }}

{{- $licenseType }}

{{- end }}


# Function for validating the license
{{- define "ibm-connectivity-pack.validateLicense" -}}

{{- $licenseListCP4I := list "L-QYVA-B365MB" "L-JVML-UFQVM4" -}}
{{- $licenseListEA := list "L-AUKS-FKVXVL" -}}

{{- $licenseId := .licenseId | quote -}}

{{- $foundCP4ILicense := false }}
{{- $foundEALicense := false }}

{{- range $licenseListCP4I }}
  {{- if eq (quote .) $licenseId }}
    {{- $foundCP4ILicense = true }}
  {{- end }}
{{- end }}

{{- range $licenseListEA }}
  {{- if eq (quote .) $licenseId }}
    {{- $foundEALicense = true }}
  {{- end }}
{{- end }}

{{- if not (or $foundCP4ILicense $foundEALicense )}}
  {{- fail (printf "\nInvalid license: %s.\nValid Event Automation licenses are:\n  %s\nValid Cloud Pak for Integration licenses are:\n  %s" $licenseId $licenseListEA $licenseListCP4I) }}
{{- end }}

{{- end }}
