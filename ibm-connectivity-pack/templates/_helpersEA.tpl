{{/*
Define the name of the Event Automation Helm Chart Prehook Job for validating the license
*/}}
{{- define "ibm-connectivity-pack.eaPreHookJob" -}}
{{- if .Release.Name }}
{{- default  .Release.Name }}-ea-prehook-job
{{- end }}
{{- end }}

{{/*
Define the name of the Event Automation Helm Chart Prehook Job for validating the license
*/}}
{{- define "ibm-connectivity-pack.eaPostHookJob" -}}
{{- if .Release.Name }}
{{- default  .Release.Name }}-ea-posthook-job
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

{{- $licenseListCP4I := list "L-QYVA-B365MB" "L-JVML-UFQVM4" "L-JVUW-LSTB9R" "L-MQQP-KBWMYE" "L-CYPF-CRPF3H" -}}
{{- $licenseListEA := list "L-AUKS-FKVXVL" "L-CYBH-K48BZQ" -}}
{{- $licenseListIWHI := list "L-SBZZ-CNR329" -}}

{{- $licenseId := .licenseId | quote -}}

{{- $foundCP4ILicense := false }}
{{- $foundEALicense := false }}
{{- $foundIWHILicense := false }}
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

{{- range $licenseListIWHI }}
  {{- if eq (quote .) $licenseId }}
    {{- $foundIWHILicense = true }}
    {{- $licenseType = "IWHI" }}
  {{- end }}
{{- end }}

{{- $licenseType }}

{{- end }}


# Function for validating the license
{{- define "ibm-connectivity-pack.validateLicense" -}}

{{- $licenseListCP4I := list "L-QYVA-B365MB" "L-JVML-UFQVM4" "L-JVUW-LSTB9R" "L-MQQP-KBWMYE" "L-CYPF-CRPF3H" -}}
{{- $licenseListEA := list "L-AUKS-FKVXVL" "L-CYBH-K48BZQ" -}}
{{- $licenseListIWHI := list "L-SBZZ-CNR329" -}}

{{- $licenseId := .licenseId | quote -}}

{{- $foundCP4ILicense := false }}
{{- $foundEALicense := false }}
{{- $foundIWHILicense := false }}

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

{{- range $licenseListIWHI }}
  {{- if eq (quote .) $licenseId }}
    {{- $foundIWHILicense = true }}
  {{- end }}
{{- end }}

{{- if not (or $foundCP4ILicense $foundEALicense $foundIWHILicense)}}
  {{- fail (printf "\nYou have provided an invalid license: %s.\nTo continue the installation, set 'license.licenseId' and provide a valid value from https://ibm.biz/ea-license.\nValid Event Automation licenses are:\n  %s\nValid Cloud Pak for Integration licenses are:\n  %s\nValid webMethods Hybrid Integration  licenses are:\n  %s" $licenseId $licenseListEA $licenseListCP4I $licenseListIWHI) }}
{{- end }}

{{- end }}
