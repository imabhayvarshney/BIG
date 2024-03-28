{{/*
Expand the name of the chart.
*/}}
{{- define "external-apps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "external-apps.fullname" -}}
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
{{- define "external-apps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "external-apps.labels" -}}
helm.sh/chart: {{ include "external-apps.chart" . }}
helm.sh/name: {{ .Chart.Name }}
{{ include "external-apps.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "external-apps.selectorLabels" -}}
app.kubernetes.io/name: {{ include "external-apps.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "external-apps.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "external-apps.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "external-apps.initContainer.waitForJwtJob" -}}
- name: wait-for-jwt
  image: "{{ .Values.global.image.repository }}/k8s-wait-for:{{ .Values.global.bigidInitWaitForTag }}"
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  env:
  - name: WAIT_TIME
    value: "10"
  args:
  - "job"
  - "generate-jwt"
{{- end -}}
