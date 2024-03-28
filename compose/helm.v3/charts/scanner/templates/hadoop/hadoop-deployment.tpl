{{- define "hadoop.yaml" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.global.bigid.scanner.hadoop.fullnameOverride | default "bigid-scanner-with-hadoop" | quote }}
  namespace: {{ .Release.Namespace | quote }}
  labels:
    app: {{ .Values.global.bigid.scanner.hadoop.fullnameOverride | default "bigid-scanner-with-hadoop" | quote }}
    {{- with .Values.global.additionalLabels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- with .Values.global.bigid.scanner.additionalLabels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    {{ include "global.skipCheckovAnnotations" . | nindent 4 }}
    {{- with .Values.global.commonAnnotations }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  replicas: {{ .Values.global.bigid.scanner.hadoop.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.global.bigid.scanner.hadoop.fullnameOverride | default "bigid-scanner-with-hadoop" | quote }}
    {{- with .Values.global.podLabels }}
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- if .Values.global.bigid.scanner.updateStrategy }}
  strategy: {{- toYaml .Values.global.bigid.scanner.updateStrategy | nindent 4 }}
  {{- end }}
  template:
    metadata:
      {{- with .Values.global.podAnnotations }}
      annotations: {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        app: {{ .Values.global.bigid.scanner.hadoop.fullnameOverride | default "bigid-scanner-with-hadoop" | quote }}
      {{- with .Values.global.podLabels }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if and (.Values.global.apm.enabled) (eq .Values.global.apm.type "datadog") }}
        tags.datadoghq.com/bigid-scanner.env: {{ .Release.Namespace }}
        tags.datadoghq.com/bigid-scanner.service: bigid-scanner
        tags.datadoghq.com/service: "bigid-scanner"
        tags.datadoghq.com/version: "{{ .Values.global.image.tag | trunc 63 }}"
      {{- end }}
    spec:
      {{- if .Values.global.bigid.scanner.serviceAccount.create }}
      serviceAccountName: {{ .Values.global.bigid.scanner.hadoop.fullnameOverride | default "bigid-hadoop-scanner" | quote }}
      automountServiceAccountToken: false
      {{- end }}
      volumes:
      {{- with .Values.global.bigid.scanner.extraVolumes }}
        {{- toYaml . | nindent 6 }}
      {{- end }}
      {{- with .Values.global.extraVolumes }}
        {{- toYaml . | nindent 6 }}
      {{- end }}
      {{- if .Values.global.bigid.scanner.scannerKeyTab }}
      - name: bigid-scanner-keytab
        secret:
          defaultMode: 420
          secretName: {{ .Values.global.bigid.scanner.hadoop.fullnameOverride | default "hadoop-secrets" | quote }}
      {{- end }}
      {{- if or .Values.global.bigid.scanner.krb5ConfFile .Values.global.bigid.scanner.krb5Conf }}
      - configMap:
          defaultMode: 420
          items:
            - key: krb5.conf
              path: krb5.conf
          name: "{{ .Release.Name }}-{{ .Values.global.bigid.scanner.hadoop.fullnameOverride | default "hadoop-config" }}"
        name: bigid-scanner-data
      {{- end }}
      {{- if .Values.global.bigid.scanner.scannerDb2LicenseFile }}
      - configMap:
          defaultMode: 420
          items:
            - key: db2jcc_license_cisuz.jar
              path: db2jcc_license_cisuz.jar
          name: hadoop-db2license
        name: bigid-scanner-db2license
      {{- end }}
      affinity:
      {{- if .Values.global.scannerAffinity }}
        {{ tpl .Values.global.scannerAffinity . | nindent 8 | trim }}
      {{- else }}
        {{- toYaml .Values.global.affinity | nindent 8 }}
      {{- end }}
      {{- with .Values.global.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
      {{- with .Values.global.bigid.scanner.sidecars }}
        {{- toYaml . | nindent 6 }}
      {{- end }}
      - image: "{{ .Values.global.image.repository }}/{{.Values.global.bigid.scanner.hadoop.image.repository }}{{ template "bigid.scannerArmRepository" . }}:{{ .Values.global.image.tag }}"
        {{- if .Values.global.bigid.containerSecurityContext.enabled }}
        securityContext: {{- omit .Values.global.bigid.containerSecurityContext "enabled" | toYaml | nindent 10 }}
        {{- end }}
        imagePullPolicy: {{ .Values.global.image.pullPolicy }}
        name: bigid-scanner-with-hadoop
        envFrom:
        - configMapRef:
            name: apm-configuration
        {{- if .Values.global.extraEnvVarsCM }}
        - configMapRef:
            name: {{ .Values.global.extraEnvVarsCM }}
        {{- end }}
        {{- if .Values.global.extraEnvVarsSecret }}
        - secretRef:
            name: {{ .Values.global.extraEnvVarsSecret }}
        {{- end }}
        env:
        {{- with .Values.global.extraEnvVars }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- if .Values.global.bigid.scanner.remote.enabled }}
        - name: IS_REMOTE_SCANNER
          value: "true"
        {{- end }}
        - name: BIGID_GIT_HASH
          {{- if .Values.global.bigid.scanner.remote.enabled }}
          value: {{ include "bigid.githash" . | quote }}
          {{- else }}
          valueFrom:
            configMapKeyRef:
              name: global-configuration
              key: BIGID_GIT_HASH
          {{- end }}
        - name: BIGID_DATE
          value: {{ now | date "2006-01-02" | quote }}
        - name: BIGID_VERSION
        {{- if and (eq .Values.global.bigid.installationType "kots") .Values.global.bigid.scanner.remote.enabled }}
          value: "{{ .Values.global.image.tag }}_KOTS"
        {{- else }}
          value: {{ .Values.global.image.tag | quote }}
        {{- end }}
        {{- if and (.Values.global.apm.enabled) (eq .Values.global.apm.type "datadog") }}
        - name: DD_AGENT_HOST
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: status.hostIP
        - name: DD_ENV
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.labels['tags.datadoghq.com/bigid-scanner.env']
        - name: DD_SERVICE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.labels['tags.datadoghq.com/bigid-scanner.service']
        {{- end }}
        - name: LABELER_ENABLED
          value: "{{ .Values.global.bigid.labeler.create }}"
        - name: SCANNER_JAVA_OPTS
          value: {{ printf "$(SCANNER_JAVA_APM_OPTS) %s" (include "java.calcScannerHeapSize" .Values.global.bigid.scanner) | quote }}
        - name: NFS_V4_PROTOCOL
          value: "{{ .Values.global.bigid.scanner.nfsV4.enabled }}"
        - name: CLASSIFICATION_SNIPPET_ENABLED
          value: {{ .Values.global.bigid.snippetPersister.create | quote }}
        - name: SNIPPET_CLIENT_TIMEOUT_MS
          value: "180000"
        - name: CLASSIFICATION_SNIPPET_SERVER_HOSTNAME
          value: "bigid-snippet-persister:9990"
        - name: CLASSIFICATION_SNIPPET_PROTOCOL
          value: "http"
        - name: IS_SCANNER_BLOCKED_BY_CONFIG_SERVICE
          value: "{{ .Values.global.bigid.scanner.isScannerBlockedByConfigService }}"
        - name: ORCH_CLIENT_MAX_CONNECTION_PER_ROUTE
          value: "{{ .Values.global.bigid.scanner.orchClientMaxConnectionPerRoute }}"
        - name: ORCH_CLIENT_MAX_CONNECTION_TOTAL
          value: "{{ .Values.global.bigid.scanner.orchClientMaxConnectionTotal }}"
        - name: INTERNAL_METADATA_PROCESSING_THREADS
          value: "{{ .Values.global.bigid.scanner.internalMetadataProcessingThreads }}"
        - name: THREAD_POOL_SIZE
          value: "{{ .Values.global.bigid.scanner.threadPoolSize }}"
        - name: SCANNER_THREADS
          value: "{{ .Values.global.bigid.scanner.threadSize }}"
        - name: TEST_CONNECTION_SYNC_THREADS
          value: "{{ .Values.global.bigid.scanner.testConnection.threadSize }}"
        - name: TEST_CONNECTION_SYNC_THREADS_MAX
          value: "{{ .Values.global.bigid.scanner.testConnection.threadMaxSize }}"
        - name: TEST_CONNECTION_EXECUTOR_QUEUE_SIZE
          value: "{{ .Values.global.bigid.scanner.testConnection.queueSize }}"
        - name: SCANNER_MAX_THREADS
          value: "{{ .Values.global.bigid.scanner.threadMaxSize }}"
        - name: ORCH_ASYNCH
          value: "true"
        - name: BIGID_ORCH_HOST
          value: "bigid-orch"
        - name: BIGID_ORCH_PORT
          value: "{{ .Values.global.bigid.orchestrator.port }}"
        - name: BIGID_ORCH_PROTOCOL
          value: http
        - name: DATA_PREVIEW_DISABLED
          value: {{ .Values.global.bigid.scanner.dataPreviewDisabled | quote }}
        - name: DISCOVERY_ENGINE_ALGORITHM
          value: "{{ .Values.global.bigid.scanner.discoveryEngineAlgorithm }}"
        - name: BIGID_UI_API
          value: "/api/v1/"
        {{- if (not .Values.global.bigid.scanner.remote.enabled) }}
        - name: BIGID_UI_PORT
          value: "{{ .Values.global.bigid.web.port }}"
        - name: BIGID_UI_PROTOCOL_EXT
          value: "http"
        - name: BIGID_UI_HOST_EXT
          value: "bigid-web"
        {{- else }}
        - name: BIGID_UI_PORT
          value: "443"
        - name: BIGID_UI_PROTOCOL_EXT
          value: "https"
        - name: BIGID_UI_HOST_EXT
          value: "{{ .Values.global.ingress.bigidHost }}"
        {{- if .Values.global.bigid.scanner.auth.enabled }}
        - name: BIGID_USER
          value: "{{ .Values.global.bigid.scanner.auth.username }}"
        - name: BIGID_PASSWORD
          value: "{{ .Values.global.bigid.scanner.auth.password }}"
        {{- end }}
        {{- end }}
        {{- if .Values.global.bigid.scanner.remote.enabled }}
        - name: BIGID_REFRESH_TOKEN
          value: {{ .Values.global.bigid.scanner.refreshToken }}
        - name: SCANNER_HOST_NAME
          value: {{ .Values.global.bigid.scanner.hostName }}
        {{- end }}
        - name: SCANNER_GROUP_NAME
          value: {{ .Values.global.bigid.scanner.hadoop.groupName }}
        - name: SET_SAP_SECUDIR
          value: "{{ .Values.global.bigid.scanner.set_sap_secudir }}"
        - name: USE_OJDBC7
          value: "{{ .Values.global.bigid.scanner.use_ojdbc7 }}"
        - name: USE_DB2_JCC3
          value: "{{ .Values.global.bigid.scanner.use_db2_jcc3 }}"
        - name: USE_SAS
          value: "{{ .Values.global.bigid.scanner.use_sas }}"
        - name: PROXY_SSL_CERTIFICATE
          value: ""
        {{- if .Values.global.bigid.scanner.remoteScannerVaultCustomHeaderName }}
         {{- if .Values.global.bigid.scanner.remoteScannerVaultCustomHeaderValue }}
        - name: REMOTE_SCANNER_VAULT_CUSTOM_HEADER_NAME
          value: "{{ .Values.global.bigid.scanner.remoteScannerVaultCustomHeaderName }}"
        - name: REMOTE_SCANNER_VAULT_CUSTOM_HEADER_VALUE
          value: "{{ .Values.global.bigid.scanner.remoteScannerVaultCustomHeaderValue }}"
          {{- end }}
          {{- end }}
        - name: BIGID_HTTP_CLIENT_INFINITE_RETRIES
          value: "true"
        - name: ENCRYPT_PAYLOAD
          value: {{ .Values.global.bigid.scanner.encryptPayload | quote }}
        - name: PAYLOAD_ENCRYPTION_KEY
          valueFrom:
            secretKeyRef:
              name: payload-enc-key
              key: payloadEncKey
              optional: true
        readinessProbe:
          httpGet:
            path: /actuator/readiness
            port: 9999
          initialDelaySeconds: 60
          periodSeconds: 10
          failureThreshold: 5
          successThreshold: 1
          timeoutSeconds: 3
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 9999
          initialDelaySeconds: 60
          periodSeconds: 10
          failureThreshold: 5
          successThreshold: 1
          timeoutSeconds: 3
        resources:
          {{- toYaml .Values.global.bigid.scanner.resources | nindent 10 }}
        volumeMounts:
        {{- with .Values.global.bigid.scanner.extraVolumeMounts }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.global.extraVolumeMounts }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- if or .Values.global.bigid.scanner.krb5ConfFile .Values.global.bigid.scanner.krb5Conf }}
        - name: bigid-scanner-data
          mountPath: /etc/scanner/krb5.conf
          subPath: krb5.conf
          readOnly: false
        {{- end }}
        {{- if .Values.global.bigid.scanner.scannerKeyTab }}
        - name: bigid-scanner-keytab
          mountPath: /etc/scanner/hdfs.keytab
          subPath: hdfs.keytab
        {{- end }}
        {{- if .Values.global.bigid.scanner.scannerDb2LicenseFile }}
        - name: bigid-scanner-db2license
          mountPath: /usr/local/shared-libs/db2jcc_license_cisuz.jar
          subPath: db2jcc_license_cisuz.jar
          readOnly: false
        {{- end }}
      imagePullSecrets:
      {{- range .Values.global.imagePullSecrets }}
        - name: {{ . }}
      {{- end }}
      {{- if .Values.global.bigid.podSecurityContext.enabled }}
      securityContext: {{- omit .Values.global.bigid.podSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      restartPolicy: Always
      nodeSelector:
      {{- $scannerAffinity := fromYaml .Values.global.scannerAffinity }}
      {{- if (and (not $scannerAffinity.nodeAffinity) (not (hasKey .Values.global.affinity "nodeAffinity")))}}
      {{- if .Values.global.bigid.scanner.nodeSelector }}
        {{- toYaml .Values.global.bigid.scanner.nodeSelector | nindent 8 }}
      {{- else }}
        {{- toYaml .Values.global.nodeSelector | nindent 8 }}
      {{- end }}
      {{- end }}
{{- end }}
