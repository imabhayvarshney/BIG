{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.global.imageCredentials.registry (printf "%s:%s" .Values.global.imageCredentials.username .Values.global.imageCredentials.password | b64enc) | b64enc }}
{{- end }}

{{- define "mongodb.javaSSLTrustStore" -}}
{{- printf "-Djavax.net.ssl.trustStore=/etc/ssl/bigid/truststore.jks" }}
{{- end -}}

{{- define "mongodb.javaSSLKeyStore" -}}
{{- printf "-Djavax.net.ssl.keyStore=/etc/ssl/bigid/client.jks" }}
{{- end -}}

{{- define "mongodb.javaX509CaCert" -}}
{{- printf "-DcaCertPath=/etc/ssl/bigid/ca.cert" }}
{{- end -}}

{{- define "mongodb.javaX509ClientKey" -}}
{{- printf "-DclientKeyPath=/etc/ssl/bigid/client.pkcs12" }}
{{- end -}}

{{- define "redis.sentinel.port" -}}
{{- printf "26379" }}
{{- end -}}

{{- define "redis.replicas.host.prefix" -}}
{{- printf "bigid-cache-node-" }}
{{- end -}}

{{- define "redis.replicas.host.suffix" -}}
{{- printf ".bigid-cache-headless" }}
{{- end -}}

{{/*
Get the password key to be retrieved from Redis&reg; secret.
*/}}
{{- define "bigid.secretKey" -}}
{{- if .Values.global.existingSecretKeyName -}}
{{- printf "%s" .Values.global.existingSecretKeyName -}}
{{- else -}}
{{- printf "secret-key" -}}
{{- end -}}
{{- end -}}

{{/*
Get the password key to be retrieved from Redis&reg; secret.
*/}}
{{- define "bigid.armRepository" -}}
{{- if ( hasKey .Values.global.bigid "archType") }}
{{- if eq .Values.global.bigid.archType  "arm64" }}
{{- printf "/arm64" -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Configure max-old-space-size for node based service, based on pod memory limit
*/}}
{{- define "nodeJs.maxOldSpaceSize" -}}
    {{- $value := int (regexReplaceAll "([0-9]+).*" .resources.limits.memory "${1}") }}
    {{- $unit := regexReplaceAll "[0-9]+(.*)" .resources.limits.memory "${1}" }}
    {{- $res := 0 }}
    {{- if contains "max-old-space-size" .nodeOptions }}
        {{- printf .nodeOptions }}
    {{- else }}
    {{- if eq $unit "Mi" }}
        {{- $res = (mul $value .nodeMaxOldSpaceSizePercent) }}
    {{- else if eq $unit "Gi" }}
        {{- $res = (mul $value 1024 .nodeMaxOldSpaceSizePercent) }}
    {{- else }}
        {{- $res = (mul $value .nodeMaxOldSpaceSizePercent) }}
    {{- end }}
    {{- (print "--max-old-space-size=" (div $res 100)) }}
    {{- end }}
{{- end }}


{{/*
Init containers image function.
*/}}
{{- define "initContainer.image" -}}
{{- if .Values.global.initContainers.image.registry -}}
{{- printf "%s/%s:%s" .Values.global.initContainers.image.registry .Values.global.initContainers.image.repository .Values.global.initContainers.image.tag -}}
{{- else -}}
{{- printf "%s/%s%s:%s" .Values.global.image.repository .Values.global.initContainers.image.repository (include "bigid.armRepository" .) .Values.global.initContainers.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Configure Xmx for Java based service, based on pod memory limit
*/}}
{{- define "java.calcHeapSize" -}}
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


{{/*
Override BigIDme agent imageTag
*/}}
{{- define "bigidme-agent.imageTag" -}}
{{- if hasKey .Values.global.bigid.bigidme "image" -}}
    {{- printf "%s" .Values.global.bigid.bigidme.image.tag -}}
{{- else -}}
    {{- printf "%s" .Values.global.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Define HTTPS or HTTP protocol based on UI service Port
*/}}
{{- define "bigid-ui-protocol" -}}
{{- if eq (.Values.global.bigid.ui.service.port | toString) "80" }}
    {{- printf "%s" "http" -}}
{{- else -}}
    {{- printf "%s" "https" -}}
{{- end -}}
{{- end -}}

{{- define "trunc" -}}
{{- $input := index . 1 -}}
{{- $length := index . 0 -}}
{{- $output := "" -}}
{{- range seq 0 (sub $length 1) -}}
  {{- $output = print $output (substr $input . 1) -}}
{{- end -}}
{{- $output -}}
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
