{{- define "scanner.yaml" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.global.bigid.scanner.fullnameOverride | default "bigid-scanner" | quote }}
  namespace: {{ .Release.Namespace | quote }}
  labels:
    app: {{ .Values.global.bigid.scanner.fullnameOverride | default "bigid-scanner" | quote }}
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
  replicas: {{ .Values.global.bigid.scanner.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.global.bigid.scanner.fullnameOverride | default "bigid-scanner" | quote }}
    {{- with .Values.global.podLabels }}
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- if .Values.global.bigid.scanner.updateStrategy }}
  strategy: {{- toYaml .Values.global.bigid.scanner.updateStrategy | nindent 4 }}
  {{- end }}
  template:
    metadata:
      annotations:
      {{- with .Values.global.podAnnotations }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.global.bigid.scanner.podAnnotations }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        app: {{ .Values.global.bigid.scanner.fullnameOverride | default "bigid-scanner" | quote }}
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
      serviceAccountName: {{ .Values.global.bigid.scanner.fullnameOverride | default "bigid-scanner" | quote }}
      {{- end }}
      automountServiceAccountToken: true
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
      initContainers:
      {{- if and .Values.global.bigid.ner.create (not .Values.global.bigid.scanner.remote.enabled) }}
      # {{- if .Values.global.bigid.ner.persistence.enabled }}
      # - name: init-volume-permissions
      #   image: {{ .Values.global.image.repository }}/busybox:musl
      #   imagePullPolicy: {{ .Values.global.image.pullPolicy }}
      #   command: ['sh', '-c', "chmod 0777 /ner_env/ner_models && chown -R 1000:1000 /ner_env/ner_models"]
      #   securityContext:
      #     runAsUser: 0
      #     runAsGroup: 0
      #   volumeMounts:
      #   - name: ner-data
      #     mountPath: /ner_env/ner_models/
      # {{- end }}
      {{- if .Values.global.bigid.scanner.isScannerBlockedByConfigService }}
      - name: init-config-service
        {{- if .Values.global.bigid.scanner.initContainer.image.repository }}
        image: "{{ .Values.global.image.repository }}/{{ .Values.global.bigid.scanner.initContainer.image.repository }}:{{ .Values.global.initContainers.image.tag }}"
        {{- else }}
        image: {{ template "scannerInitContainer.image" . }}
        {{- end }}
        imagePullPolicy: {{ .Values.global.image.pullPolicy }}
        command: ['sh', '-c', "until wget -q --spider http://bigid-config-service:{{ .Values.global.bigid.configService.port }}/actuator/health; do echo waiting for bigid-config-service; sleep 3; done"]
        resources:
          {{- toYaml .Values.global.initContainers.resources | nindent 10 }}
        {{- if .Values.global.initContainers.containerSecurityContext.enabled }}
        securityContext: {{- omit .Values.global.initContainers.containerSecurityContext "enabled" | toYaml | nindent 10 }}
        {{- end }}
      {{- end }}
      {{- end }}
      containers:
      {{- with .Values.global.bigid.scanner.sidecars }}
        {{- toYaml . | nindent 6 }}
      {{- end }}
      {{- if .Values.global.bigid.ner.create }}
      - image: "{{ .Values.global.image.repository }}/{{.Values.global.bigid.ner.image.repository}}{{ template "bigid.scannerNerLabelerArmRepository" . }}:{{ .Values.global.image.tag }}"
        {{- if .Values.global.bigid.containerSecurityContext.enabled }}
        securityContext: {{- omit .Values.global.bigid.containerSecurityContext "enabled" | toYaml | nindent 10 }}
        {{- end }}
        imagePullPolicy: {{ .Values.global.image.pullPolicy }}
        name: bigid-ner
        ports:
        - containerPort: {{ .Values.global.bigid.ner.port }}
        env:
        {{- if .Values.global.bigid.scanner.remote.enabled }}
        - name: IS_REMOTE_SCANNER
          value: "true"
        {{- end }}
        {{- if .Values.global.bigid.ner.isNerProxy }}
        - name: HTTP_PROXY
          value: "{{ .Values.global.bigid.ner.httpProxy }}"
        - name: HTTPS_PROXY
          value: "{{ .Values.global.bigid.ner.httpsProxy }}"
        - name: NO_PROXY
          value: "0.0.0.0"
        {{- end }}
        - name: STRUCTURED_NER_LEVEL
          value: "1"
        - name: IS_FIPS_MODE
          value: "{{ .Values.global.bigid.scanner.fipsMode.enabled }}"
        {{- if and (not .Values.global.bigid.scanner.remote.enabled ) (.Values.global.bigid.scanner.fipsMode.enabled) }}
        - name: SECRET_SALT
          valueFrom:
            secretKeyRef:
              name: secret-key
              key: secretSalt
        {{- end }}
        - name: PYTHONUNBUFFERED
          value: "1"
        - name: ENV_FOR_DYNACONF
          value: "{{ .Values.global.bigid.ner.envForDynaconf }}"
        - name: NER_LOG_LEVEL
          value: "{{ .Values.global.bigid.ner.nerLogLevel }}"
        {{- if .Values.global.bigid.ner.disableAutoUpgradeClassifiers }}
        - name: DISABLE_AUTO_UPGRADE_OF_CLASSIFIERS
          value: {{ .Values.global.bigid.ner.disableAutoUpgradeClassifiers | quote }}
        {{- end }}
        {{- if .Values.global.bigid.ner.nerModel  }}
        - name: NER_MODEL
          value: {{ .Values.global.bigid.ner.nerModel | quote }}
        {{- end }}
        - name: BIGID_UI_API
          value: "/api/v1/"
        {{- if (not .Values.global.bigid.scanner.remote.enabled) }}
        - name: BIGID_UI_PORT_EXT
          value: "{{ .Values.global.bigid.scanner.uiPortInternal }}"
        - name: BIGID_UI_PROTOCOL_EXT
          value: "{{ .Values.global.bigid.scanner.uiProtocolInternal }}"
        - name: BIGID_UI_HOST_EXT
          value: "{{ .Values.global.bigid.scanner.uiHostInternal }}"
        - name: SCANNER_GROUP_NAME
          value: {{ .Values.global.bigid.scanner.groupName }}
        - name: DELETION_SCAN_THREADS
          value: {{ .Values.global.bigid.scanner.deletionScanThreads | quote }}
        {{- else }}
        {{- if .Values.global.bigid.scanner.auth.enabled }}
        - name: BIGID_USER
          value: "{{ .Values.global.bigid.scanner.auth.username }}"
        - name: BIGID_PASSWORD
          value: "{{ .Values.global.bigid.scanner.auth.password }}"
        {{- end }}
        - name: BIGID_UI_PORT_EXT
          value: "443"
        - name: BIGID_UI_PROTOCOL_EXT
          value: "https"
        - name: BIGID_UI_HOST_EXT
          value: "{{ .Values.global.ingress.bigidHost }}"
        {{- end }}
        {{- if and (.Values.global.bigid.scanner.remote.enabled) (.Values.global.bigid.scanner.refreshToken) }}
        - name: BIGID_REFRESH_TOKEN
          value: {{ .Values.global.bigid.scanner.refreshToken }}
        {{- end }}
        - name: ENCRYPT_PAYLOAD
          value: {{ .Values.global.bigid.scanner.encryptPayload | quote }}
        - name: PAYLOAD_ENCRYPTION_KEY
          valueFrom:
            secretKeyRef:
              name: payload-enc-key
              key: payloadEncKey
              optional: true
        resources:
          {{- toYaml .Values.global.bigid.ner.resources | nindent 10 }}
        {{- if .Values.global.bigid.ner.readinessProbe.enabled }}
        readinessProbe:
          httpGet:
            path: /api/v1/health-check
            port: {{ .Values.global.bigid.ner.port }}
          initialDelaySeconds: 60
          failureThreshold: 5
          periodSeconds: 10
          timeoutSeconds: 30
        {{- end }}
        {{- if .Values.global.bigid.ner.livenessProbe.enabled }}
        livenessProbe:
          httpGet:
            path: /api/v1/health-check
            port: {{ .Values.global.bigid.ner.port }}
          initialDelaySeconds: 120
          failureThreshold: 5
          periodSeconds: 10
          timeoutSeconds: 30
        {{- end }}
        volumeMounts:
        {{- with .Values.global.bigid.scanner.extraVolumeMounts }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.global.extraVolumeMounts }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
        - name: ner-data
          mountPath: /ner_env/ner_models/
      {{ end }}
      {{- if .Values.global.bigid.labeler.create }}
      - image: "{{ .Values.global.image.repository }}/{{.Values.global.bigid.labeler.image.repository}}{{ template "bigid.scannerNerLabelerArmRepository" . }}:{{ .Values.global.image.tag }}"
        {{- if .Values.global.bigid.containerSecurityContext.enabled }}
        securityContext: {{- omit .Values.global.bigid.containerSecurityContext "enabled" | toYaml | nindent 10 }}
        {{- end }}
      {{- else if .Values.global.bigid.scanner.fipsMode.enabled }}
      - image: "{{ .Values.global.image.repository }}/{{.Values.global.bigid.scanner.ubi.image.repository}}{{ template "bigid.scannerArmRepository" . }}:{{ .Values.global.image.tag }}"
      {{- else }}
      - image: "{{ .Values.global.image.repository }}/{{.Values.global.bigid.scanner.image.repository}}{{ template "bigid.scannerArmRepository" . }}:{{ .Values.global.image.tag }}"
        {{- if and .Values.global.bigid.containerSecurityContext.enabled .Values.global.bigid.scanner.nfsV4.privileged }}
        securityContext:
          privileged: {{ .Values.global.bigid.scanner.nfsV4.privileged }}
        {{- else if .Values.global.bigid.containerSecurityContext.enabled }}
        securityContext: {{- omit .Values.global.bigid.containerSecurityContext "enabled" | toYaml | nindent 10 }}
        {{- end }}
      {{- end }}
        imagePullPolicy: {{ .Values.global.image.pullPolicy }}
        name: bigid-scanner
        ports:
        - containerPort: 9999
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
        - name: IS_FIPS_MODE
          value: "{{ .Values.global.bigid.scanner.fipsMode.enabled }}"
        - name: FIPS_CERTIFICATE_PATH
          value: "{{ .Values.global.bigid.scanner.fipsCertPath }}"
        {{- if and (not .Values.global.bigid.scanner.remote.enabled ) (.Values.global.bigid.scanner.fipsMode.enabled) }}
        - name: SECRET_SALT
          valueFrom:
            secretKeyRef:
              name: secret-key
              key: secretSalt
        {{- end }}
        {{- with .Values.global.extraEnvVars }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.global.bigid.scanner.extraEnvVars }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- if .Values.global.bigid.scanner.remote.enabled }}
        - name: IS_REMOTE_SCANNER
          value: "true"
        {{- end }}
        {{- if .Values.global.bigid.labeler.create }}
        - name: MIP_LABELING_RETAIN_MODIFICATION_DATE
          value: "{{ .Values.global.bigid.labeler.retainModificationDate }}"
        {{- if .Values.global.bigid.labeler.httpProxy }}
        - name: HTTP_PROXY
          value: "{{ .Values.global.bigid.labeler.httpProxy }}"
        - name: http_proxy
          value: "{{ .Values.global.bigid.labeler.httpProxy }}"
        {{- end }}
        {{- if .Values.global.bigid.labeler.httpsProxy }}
        - name: HTTPS_PROXY
          value: "{{ .Values.global.bigid.labeler.httpsProxy }}"
        - name: https_proxy
          value: "{{ .Values.global.bigid.labeler.httpsProxy }}"
        {{- end }}
        {{- if .Values.global.bigid.labeler.enableLabelerCustomCert }}
        - name: PROXY_SSL_CERTIFICATE
          value: "/labeler_env/certs/labeler-custom-cert.cert"
        - name: SSL_CERT_FILE
          value: "/labeler_env/certs/labeler-custom-cert.cert"
        {{- end }}
        {{- end }}
        - name: CLASSIFICATION_SNIPPET_ENABLED
          value: {{ .Values.global.bigid.snippetPersister.create | quote }}
        - name: API_CALLS_LRU_SIZE
          value: {{ .Values.global.bigid.scanner.apiCallsLRUSize | quote }}
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
          value: "{{ printf "%d-%02d-01" now.Year now.Month }}"
        - name: BIGID_VERSION
        {{- if and (eq .Values.global.bigid.installationType "kots") .Values.global.bigid.scanner.remote.enabled }}
          value: "{{ .Values.global.image.tag }}_KOTS"
        {{- else }}
          value: {{ .Values.global.image.tag | quote }}
        {{- end }}
        - name: TZ
          value: {{ .Values.global.timeZone | quote }}
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
        - name: MULTI_TENANT_MODE_ENABLED
          value: "{{ .Values.global.bigid.multiTenantMode.enabled }}"
        - name: SCANNER_JAVA_OPTS
          value: {{ printf "$(SCANNER_JAVA_APM_OPTS) %s" (include "java.calcScannerHeapSize" .Values.global.bigid.scanner) | quote }}
        - name: NFS_V4_PROTOCOL
          value: "{{ .Values.global.bigid.scanner.nfsV4.enabled }}"
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
        - name: EXPANSIBLE_THREAD_POOL
          value: "{{ .Values.global.bigid.scanner.expansibleThreadPool }}"
        - name: CLASSIFIER_SUPERSCAN_CACHE_EXPIRATION_PERIOD
          value: "{{ .Values.global.bigid.scanner.classifierSuperscanPrefiltering.cacheExpirationPeriod }}"
        - name: ORCH_ASYNCH
          value: "true"
        - name: BIGID_ORCH_HOST
          value: "bigid-orch"
        - name: BIGID_ORCH_PORT
          value: "{{ .Values.global.bigid.orchestrator.port }}"
        - name: BIGID_ORCH_PROTOCOL
          value: http
        - name: SNIPPET_CLIENT_TIMEOUT_MS
          value: "180000"
        - name: CLASSIFICATION_SNIPPET_SERVER_HOSTNAME
          value: "bigid-snippet-persister:9990"
        - name: CLASSIFICATION_SNIPPET_PROTOCOL
          value: "http"
        - name: SNIPPET_API_BATCH_SIZE
          value: "{{ .Values.global.bigid.scanner.snippets.batchSize }}"
        {{- if or (.Values.global.bigid.ner.create) (.Values.global.bigid.clustering.create) }}
        - name: CLUSTERING_ENABLED
          value: "true"
        {{- end }}
        {{- if .Values.global.bigid.ner.create }}
        - name: NER_CLASSIFIER_ENABLED_FEATURE_FLAG
          value: "true"
        - name: BIGID_NER_PROTOCOL
          value: "http"
        - name: BIGID_NER_HOST
          value: "localhost"
        - name: BIGID_NER_PORT
          value: "{{ .Values.global.bigid.ner.port }}"
        {{- else}}
        - name: NER_CLASSIFIER_ENABLED_FEATURE_FLAG
          value: "false"
        {{- end }}
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
        - name: SCANNER_GROUP_NAME
          value: {{ .Values.global.bigid.scanner.groupName }}
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
        - name: SCANNER_GROUP_NAME
          value: {{ .Values.global.bigid.scanner.groupName }}
        - name: SCANNER_HOST_NAME
          value: {{ .Values.global.bigid.scanner.hostName }}
        {{- end }}
        - name: SET_SAP_SECUDIR
          value: "{{ .Values.global.bigid.scanner.set_sap_secudir }}"
        - name: USE_OJDBC7
          value: "{{ .Values.global.bigid.scanner.use_ojdbc7 }}"
        - name: USE_DB2_JCC3
          value: "{{ .Values.global.bigid.scanner.use_db2_jcc3 }}"
        {{- if and (.Values.global.bigid.scanner.remoteScannerVaultCustomHeaderName ) (.Values.global.bigid.scanner.remoteScannerVaultCustomHeaderValue) }}
        - name: USE_SAS
          value: "{{ .Values.global.bigid.scanner.use_sas }}"
        - name: REMOTE_SCANNER_VAULT_CUSTOM_HEADER_NAME
          value: "{{ .Values.global.bigid.scanner.remoteScannerVaultCustomHeaderName }}"
        - name: REMOTE_SCANNER_VAULT_CUSTOM_HEADER_VALUE
          value: "{{ .Values.global.bigid.scanner.remoteScannerVaultCustomHeaderValue }}"
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
          initialDelaySeconds: 120
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
        {{- if and (.Values.global.bigid.scanner.remote.enabled ) (.Values.global.bigid.scanner.fipsMode.enabled) }}
        - name: bigid-fips-cert
          mountPath: {{ .Values.global.bigid.scanner.fipsCertDir }}
          readOnly: true
        {{- end }}
        {{- if .Values.global.bigid.labeler.enableLabelerCustomCert }}
        - name: labeler-custom-cert
          mountPath: /labeler_env/certs/
          readOnly: true
        {{- end }}
      imagePullSecrets:
      {{- range .Values.global.imagePullSecrets }}
        - name: {{ . }}
      {{- end }}
      {{- if .Values.global.bigid.podSecurityContext.enabled }}
      securityContext: {{- omit .Values.global.bigid.podSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      restartPolicy: Always
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
          secretName: {{ .Values.global.bigid.scanner.fullnameOverride | default "scanner-secrets" | quote }}
      {{- end }}
      {{- if .Values.global.bigid.labeler.enableLabelerCustomCert }}
      - name: labeler-custom-cert
        secret:
          secretName: labeler-secret
      {{- end }}
      {{- if .Values.global.bigid.ner.create }}
      - name: ner-data
        {{- if .Values.global.bigid.ner.persistence.enabled }}
        {{- if eq .Values.global.bigid.ner.persistence.type ("PersistentVolumeClaim") }}
        persistentVolumeClaim:
          claimName: bigid-ner-pv-claim
        {{- else if eq .Values.global.bigid.ner.persistence.type ("hostPath") }}
        hostPath:
          path: {{ .Values.global.bigid.ner.persistence.hostPath | quote }}
          type: DirectoryOrCreate
        {{- else }}
        emptyDir: {}
        {{- end }}
        {{- end }}
      {{- end }}
      {{- if or .Values.global.bigid.scanner.krb5ConfFile .Values.global.bigid.scanner.krb5Conf }}
      - configMap:
          defaultMode: 420
          items:
            - key: krb5.conf
              path: krb5.conf
          name: "{{ .Release.Name }}-{{ .Values.global.bigid.scanner.fullnameOverride | default "scanner-config" }}"
        name: bigid-scanner-data
      {{- end }}
      {{- if .Values.global.bigid.scanner.scannerDb2LicenseFile }}
      - configMap:
          defaultMode: 420
          items:
            - key: db2jcc_license_cisuz.jar
              path: db2jcc_license_cisuz.jar
          name: scanner-db2license
        name: bigid-scanner-db2license
      {{- end }}
      {{- if and (.Values.global.bigid.scanner.remote.enabled ) (.Values.global.bigid.scanner.fipsMode.enabled) }}
      - name: bigid-fips-cert
        secret:
          defaultMode: 420
          secretName: bigid-fips-cert
          items:
          - key: ca.cert
            path: ca.cert
      {{- end }}
      nodeSelector:
      {{- $scannerAffinity := fromYaml .Values.global.scannerAffinity }}
      {{- if (and (not $scannerAffinity.nodeAffinity) (not (hasKey .Values.global.affinity "nodeAffinity")))}}
      {{- if and (.Values.global.bigid.labeler.create) (.Values.global.bigid.labeler.nodeSelector) }}
        {{- toYaml .Values.global.bigid.labeler.nodeSelector | nindent 8 }}
      {{- else if .Values.global.bigid.scanner.nodeSelector }}
        {{- toYaml .Values.global.bigid.scanner.nodeSelector | nindent 8 }}
      {{- else }}
        {{- toYaml .Values.global.nodeSelector | nindent 8 }}
      {{- end }}
      {{- end }}
{{- end }}
