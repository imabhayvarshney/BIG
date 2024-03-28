{{/*
Expand the name of the chart.
*/}}
{{- define "ignite.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ignite.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ignite.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ignite.labels" -}}
helm.sh/chart: {{ include "ignite.chart" . }}
{{ include "ignite.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ignite.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ignite.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "ignite.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ignite.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ignite.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Configure Xmx for Java based service, based on pod memory limit
*/}}
{{- define "ignite.calcMaxSize" -}}
    {{- $value := int (regexReplaceAll "([0-9]+).*" .Values.resources.limits.memory "${1}") }}
    {{- $unit := regexReplaceAll "[0-9]+(.*)" .Values.resources.limits.memory "${1}" }}
    {{- $res := 0 }}
    {{- if eq $unit "Mi" }}
        {{- (print ($value) "L * 1024 * 1024" ) }}
    {{- else if eq $unit "Gi" }}
        {{- (print ($value) "L * 1024 * 1024 * 1024" ) }}
    {{- end }}
{{- end }}