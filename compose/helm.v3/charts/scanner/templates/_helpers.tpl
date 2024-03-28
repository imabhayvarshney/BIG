{{/*
Configure imagePullSecret
*/}}
{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.global.imageCredentials.registry (printf "%s:%s" .Values.global.imageCredentials.username .Values.global.imageCredentials.password | b64enc) | b64enc }}
{{- end }}

{{/*
Configure Xmx for Java based service, based on pod memory limit
*/}}
{{- define "java.calcScannerHeapSize" -}}
    {{- $value := int (regexReplaceAll "([0-9]+).*" .resources.limits.memory "${1}") }}
    {{- $unit := regexReplaceAll "[0-9]+(.*)" .resources.limits.memory "${1}" }}
    {{- $res := 0 }}
    {{- if contains "Xmx" .JavaOpts }}
        {{- printf "%s" .JavaOpts }}
    {{- else }}
        {{- if eq $unit "Mi" }}
            {{- $res = (mul $value .heapSizePercent) }}
        {{- else if eq $unit "Gi" }}
            {{- $res = (mul $value 1024 .heapSizePercent) }}
        {{- else }}
            {{- $res = (mul $value .heapSizePercent) }}
        {{- end }}
        {{- printf "%s -server -Xmx%dm" $.JavaOpts (div $res 100) }}
    {{- end }}
{{- end }}

{{/*
Get the password key to be retrieved from Redis&reg; secret.
*/}}
{{- define "bigid.scannerArmRepository" -}}
{{- if ( hasKey .Values.global.bigid "archType") }}
{{- if eq .Values.global.bigid.archType "arm64" }}
{{- printf "/arm64" -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bigid.scannerNerLabelerArmRepository" -}}
{{- if ( hasKey .Values.global.bigid "archType") }}
{{- if and (eq .Values.global.bigid.archType "arm64") (not .Values.global.bigid.labeler.create) }}
{{- printf "/arm64" -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Init containers image function.
*/}}
{{- define "scannerInitContainer.image" -}}
{{- if .Values.global.initContainers.image.registry -}}
{{- printf "%s/%s:%s" .Values.global.initContainers.image.registry .Values.global.initContainers.image.repository .Values.global.initContainers.image.tag -}}
{{- else if .Values.global.bigid.labeler.create -}}
{{- printf "%s/%s:%s" .Values.global.image.repository .Values.global.initContainers.image.repository .Values.global.initContainers.image.tag -}}
{{- else -}}
{{- printf "%s/%s%s:%s" .Values.global.image.repository .Values.global.initContainers.image.repository (include "bigid.scannerArmRepository" .) .Values.global.initContainers.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Calculate BigID deployment hash
*/}}
{{- define "bigid.githash" -}}
{{- $digest := .Chart.Annotations.digest -}}
{{- if eq (len $digest) 40 -}}
{{- $digest -}}
{{- else -}}
{{- randAlphaNum 36 | lower -}}
{{- end -}}
{{- end -}}

{{- define "global.skipCheckovAnnotations" }}
{{- $skipCheckovAnnotations := list
    "CKV_K8S_43=Image should use digest"
    "CKV_K8S_31=Ensure that the seccomp profile is set to docker/default or runtime/default"
    "CKV_K8S_40=Containers should run as a high UID to avoid host conflict"
    "CKV_K8S_22=Use read-only filesystem for containers where possible"
    "CKV_K8S_35=Prefer using secrets as files over secrets as environment variables"
}}
{{- range $index, $value := $skipCheckovAnnotations }}
  checkov.io/skip{{ add $index 1 }}: {{ $value | quote }}
{{- end }}
{{- end }}
