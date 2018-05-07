{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "redis-enterprise.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "redis-enterprise.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "redis-enterprise.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
In the event that we create both a headless service and a traditional one,
ensure that the latter gets a unique name.
*/}}
{{- define "redis-enterprise.serviceName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-svc-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a random string if the supplied key does not exist
*/}}
{{- define "redis-enterprise.defaultRandomPassword" -}}
{{- if . -}}
{{- . | b64enc | quote -}}
{{- else -}}
{{- randAlphaNum 10 | b64enc | quote -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "redis-enterprise.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "redis-enterprise.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "redis-enterprise.statefulsetName" -}}
{{- if .Values.statefulsetNameOverride -}}
    {{ .Values.statefulsetNameOverride }}
{{- else -}}
{{/*
Workaround for 5.0.2, the statefulset name should not contain extra '-'
*/}}
{{- if contains "5.0.2" .Values.redisImage.tag -}}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{ printf "%scluster" .Release.Name | replace "-" "" }}
{{- else -}}
    {{ template "redis-enterprise.fullname" . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define the cluster FQDN
*/}}
{{- define "redis-enterprise.clusterDNS" -}}
{{ template "redis-enterprise.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end -}}
