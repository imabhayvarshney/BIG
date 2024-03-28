{{- define "deploymentSpec-tpl" -}}
serviceAccount: bigid-orch2
automountServiceAccountToken: false
initContainers:
- name: init-config-service
  image: {{ template "initContainer.image" . }}
  imagePullPolicy: {{ .Values.global.image.pullPolicy }}
  command: ['sh', '-c', "until wget -q --spider http://bigid-config-service:{{ .Values.global.bigid.configService.port }}/actuator/health; do echo waiting for bigid-config-service; sleep 3; done"]
  resources:
    {{- toYaml .Values.global.initContainers.resources | nindent 4 }}
  {{- if .Values.global.initContainers.containerSecurityContext.enabled }}
  securityContext: {{- omit .Values.global.initContainers.containerSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
- name: init-redis
  image: {{ template "initContainer.image" . }}
  imagePullPolicy: {{ .Values.global.image.pullPolicy }}
  command: ['sh', '-c', "until nc -zv -w1 $(BIGID_REDIS_HOST) $(BIGID_REDIS_PORT); do echo waiting for bigid-cache; sleep 3; done"]
  resources:
    {{- toYaml .Values.global.initContainers.resources | nindent 4 }}
  envFrom:
  - configMapRef:
      name: global-configuration
  {{- if .Values.global.initContainers.containerSecurityContext.enabled }}
  securityContext: {{- omit .Values.global.initContainers.containerSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
{{- if .Values.global.bigid.tenantService.create }}
- name: init-tenant-service
  image: {{ template "initContainer.image" . }}
  imagePullPolicy: {{ .Values.global.image.pullPolicy }}
  command: [ 'sh', '-c', "until wget -q --spider http://bigid-tenant-service:{{ .Values.global.bigid.tenantService.port }}/api/v1/tenant-service/health; do echo waiting for bigid-tenant-service; sleep 3; done" ]
  resources:
    {{- toYaml .Values.global.initContainers.resources | nindent 4 }}
  {{- if .Values.global.initContainers.containerSecurityContext.enabled }}
  securityContext: {{- omit .Values.global.initContainers.containerSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
{{- end }}
containers:
- name: bigid-orch2
  image: "{{ .Values.global.image.repository }}/{{.Values.global.bigid.orchestrator.image.repository }}{{ template "bigid.armRepository" . }}:{{ .Values.global.image.tag }}"
  {{- if .Values.global.bigid.containerSecurityContext.enabled }}
  securityContext: {{- omit .Values.global.bigid.containerSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  imagePullPolicy: {{ .Values.global.image.pullPolicy }}
  readinessProbe:
    httpGet:
      path: /health/liveness
      port: {{ .Values.global.bigid.orchestrator2.port }}
    initialDelaySeconds: 10
    periodSeconds: 10
  livenessProbe:
    httpGet:
      path: /health/liveness
      port: {{ .Values.global.bigid.orchestrator2.port }}
    initialDelaySeconds: 60
    periodSeconds: 10
    timeoutSeconds: 10
    successThreshold: 1
    failureThreshold: 8
  ports:
  - containerPort: {{ .Values.global.bigid.orchestrator2.port }}
  envFrom:
  - secretRef:
      name: mongodb-base-configuration
  - configMapRef:
      name: mongodb-node-configuration
  - configMapRef:
      name: global-configuration
  - configMapRef:
      name: apm-configuration
  env:
  {{- with .Values.global.extraEnvVars }}
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.global.bigid.orchestrator2.extraEnvVars }}
    {{- toYaml . | nindent 2 }}
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
        fieldPath: metadata.labels['tags.datadoghq.com/bigid-orch2.env']
  - name: DD_SERVICE
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.labels['tags.datadoghq.com/bigid-orch2.service']
{{- end }}
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ template "bigid.secretKey" . }}
        key: secretKey
  - name: SECRET_SALT
    valueFrom:
      secretKeyRef:
        name: secret-key
        key: secretSalt
  - name: PORT
    value: {{ .Values.global.bigid.orchestrator2.port | quote }}
  - name: BIGID_MQ_USER
    valueFrom:
      secretKeyRef:
        name: bigid-auth-secret
        key: rabbitmq-user
  - name: BIGID_MQ_PWD
    valueFrom:
      secretKeyRef:
        name: bigid-auth-secret
        key: rabbitmq-pass
  - name: BIGID_MQ_PROTOCOL
    value: "amqps://"
  - name: IS_FIPS_MODE
    value: {{ .Values.global.fips.enabled | quote }}
  - name: USE_SAAS
    value: {{ .Values.global.bigid.useSaas.enabled | quote }}
  - name: COMPANY_NAME
    value: {{ .Values.global.bigid.companyName | quote }}
  - name: PREFETCH_COUNT
    value: {{ .Values.global.bigid.orchestrator2.prefetchCount | quote }}
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: bigid-auth-secret
        key: redis-pass
  - name: APPLICATION_CREDENTIALS_KEY
    valueFrom:
      secretKeyRef:
        name: secret-key
        key: appsCredsKey
  - name: DL_STREAM_NAME
    value: {{ .Values.global.bigid.dataLakeClient.dlStreamName | quote }}
  - name: ENABLE_DATALAKE_CLIENT
    value: {{ .Values.global.bigid.dataLakeClient.enabled | quote }}
  - name: SAAS_ENV
    value: {{ .Values.global.bigid.saasEnv | quote }}
  - name: NER_CLASSIFIER_ENABLED_FEATURE_FLAG
    value: {{ .Values.global.bigid.ner.create | quote }}
  - name: CLUSTERING_ENABLED
    value: {{ .Values.global.bigid.clustering.create | quote }}
  - name: CORRELATION_RECOVERY_SCHEDULER_FLAG
    value: {{ .Values.global.bigid.orchestrator.correlationRecoverySchedulerFlag | quote }}
  - name: ACI_ENABLED
    value: {{ .Values.global.bigid.aci.create | quote }}
  - name: ENABLE_LINEAGE
    value: {{ .Values.global.bigid.lineage.create | quote }}
  - name: ENABLE_REPORTING_ETL
    value: {{ .Values.global.bigid.reportingEtl.create | quote }}
  - name: ENABLE_TENANT_SERVICE
    value: {{ .Values.global.bigid.tenantService.create | quote }}
  - name: VENDORS_DIRECTORY_ENABLED_FF
    value: {{ .Values.global.bigid.vendorsDirectoryEnabledFF | quote }}
  - name: MULTI_TENANT_MODE_ENABLED
    value: {{ .Values.global.bigid.multiTenantMode.enabled | quote }}
  - name: CLASSIFIER_SUPERSCAN_PREFILTERING_ENABLED
    value: {{ .Values.global.bigid.orchestrator.classifierSuperscanPrefiltering.enabled | quote }}
  - name: SHOULD_GENERATE_AND_STORE_MONGO_CREDS_FF
    value: {{ .Values.global.bigid.multiTenantMode.generateAndUseMongoCreds | quote }}
  - name: LABELER_ENABLED
    value: {{ .Values.global.bigid.labeler.create | quote }}
  - name: ENABLE_OBJECT_PROFILING_BI_EVENT
    value: {{ .Values.global.bigid.orchestrator.objectProfilingBiEvents | quote }}
  - name: JSON_LOGS_CREATION
    value: {{ .Values.global.bigid.logConfiguration.jsonLogs.enabled | quote }}
  - name: SYSTEM_BACKPRESSURE_QUEUES_CONFIGURATION
    value: {{ .Values.global.bigid.backpressure.queuesConfiguration | quote }}
  - name: SYSTEM_BACKPRESSURE_IS_ENABLED
    value: {{ .Values.global.bigid.backpressure.enabled | quote }}
  - name: SYSTEM_BACKPRESSURE_IS_DRY_RUN_ENABLED
    value: {{ .Values.global.bigid.backpressure.dryRunEnabled | quote }}
  - name: SYSTEM_BACKPRESSURE_REPORT_QUEUES_METRICS_CRON_EXP
    value: {{ .Values.global.bigid.backpressure.reportQueuesMetricsCronExp | quote }}
  - name: SYSTEM_BACKPRESSURE_EXCESSIVE_LOAD_DETECTION_WINDOW_IN_MIN
    value: {{ .Values.global.bigid.backpressure.excessiveLoadDetectionWindowInMin | quote }}
  - name: SYSTEM_BACKPRESSURE_SYSTEM_OVERLOAD_DETECTION_CRON_EXP
    value: {{ .Values.global.bigid.backpressure.systemOverloadDetectionCronExp | quote }}
  - name: SYSTEM_BACKPRESSURE_ALLOWED_CONCURRENT_SCANNER_JOBS
    value: {{ .Values.global.bigid.backpressure.allowedConcurrentScannerJobs | quote }}
  - name: SYSTEM_BACKPRESSURE_RECOVERY_THRESHOLD_PERCENTAGE
    value: {{ .Values.global.bigid.backpressure.recoveryThresholdPercentage | quote }}
  - name: SYSTEM_BACKPRESSURE_STATUS_TTL_SEC
    value: {{ .Values.global.bigid.backpressure.statusTtlSec | quote }}
  - name: AMOUNT_OF_LOGS_FILE
    value: {{ .Values.global.bigid.logConfiguration.amountOfLogsFile | quote }}
  - name: SCALABLE_HEALTH_CHECK_ENABLED
    value: {{ .Values.global.bigid.scalableHealthCheck.enabled | quote }}
  - name: BIGID_SCHEDULER_ENABLED
    value: {{ .Values.global.bigid.bigidScheduler.enabled | quote }}
  - name: BIGID_SCHEDULER_METRICS_ENABLED
    value: {{ .Values.global.bigid.bigidScheduler.metricsEnabled | quote }}
  - name: REPORT_BIGID_SCHEDULER_JOBS_COUNT_METRICS_CRON_EXP
    value: {{ .Values.global.bigid.bigidScheduler.jobsCountMetricsCronExp | quote }}
  - name: REPORT_BIGID_SCHEDULER_JOBS_TRIGGERED_COUNT_METRICS_CRON_EXP
    value: {{ .Values.global.bigid.bigidScheduler.jobsTriggeredCountMetricsCronExp | quote }}
  - name: BIGID_SCHEDULER_JOB_TRIGGER_LOG_ENABLED
    value: {{ .Values.global.bigid.bigidScheduler.logJobTriggeredEnabled | quote }}
  - name: BIGID_SCHEDULER_JOB_MODIFY_LOCK_TTL_MS
    value: {{ .Values.global.bigid.bigidScheduler.jobModifylockTtlMs | quote }}
  - name: RISK_ASSESSMENT_ENABLED
    value: {{ .Values.global.bigid.riskAssessment.enabled | quote }}
  - name: SAVE_SCANNER_LOGS_IN_DB_ENABLED
    value: {{ .Values.global.bigid.saveScannerLogsInDbEnabled | quote }}
  - name: DS_COLLABORATION_ENABLED
    value: {{ .Values.global.bigid.dsCollaborationEnabled | quote }}
  - name: SUGGESTED_ACTIONS_ENABLED
    value: {{ .Values.global.bigid.suggestedActionsEnabled | quote }}
  - name: DATADOG_ENABLED
    value: {{ .Values.global.bigid.ddMetrics.dataDogEnabled | quote }}
  - name: DD-API-KEY
    value: {{ .Values.global.bigid.ddMetrics.ddApiKey | quote }}
  - name: DD-URI
    value: {{ .Values.global.bigid.ddMetrics.ddURI | quote }}
  - name: "K8S_NAMESPACE"
    value: {{ .Release.Namespace | quote }}
  - name: IS_ORCH2
    value: "true"
  - name: CONCURRENT_CORRELATION
    value: "true"
  - name: CONNECTIVITY_EXPERIENCE_ENABLED
    value: {{ .Values.global.bigid.connectivityExperienceEnabled | quote }}
  - name: DS_ONBOARDING_LAYOUT_ENABLED
    value: {{ .Values.global.bigid.dsOnboardingLayoutEnabled | quote }}
  - name: HOTSPOTS_ENABLED
    value: {{ .Values.global.bigid.clustering.hotspots.create | quote }}
  - name: TPA_MULTIPLE_DEPLOYMENTS_ENABLED
    value: {{ .Values.global.bigid.orchestrator.tpaMultipleDeployment.enabled | quote }}
  - name: PAYLOAD_ENCRYPTION_KEY
    valueFrom:
      secretKeyRef:
        name: payload-enc-key
        key: payloadEncKey
  - name: NODE_OPTIONS
    value: {{ printf "$(NODE_APM_OPTS) %s" (include "nodeJs.maxOldSpaceSize" .Values.global.bigid.orchestrator2) | quote }}
  - name: CLASSIFIER_TESTER_ENABLED
    value: {{ .Values.global.bigid.classifierTester.enabled | quote }}
  - name: BIGCHAT_FF_ENABLED
    value: {{ .Values.global.bigid.bigchatFFEnabled | quote }}
  - name: CLOUD_PORTAL_API_URL
    value: {{ .Values.global.bigid.web.cloudPortalApiUrl | quote }}
  - name: AUTH0_CUSTOM_DOMAIN
    value: {{ .Values.global.bigid.web.auth0CustomDomain | quote }}
  - name: AUTH0_DOMAIN
    value: {{ .Values.global.bigid.web.auth0Domain | quote }}
  - name: AUTH0_CLOUD_CLIENT_SECRET
    value: {{ .Values.global.bigid.web.auth0CloudClientSecret | quote }}
  - name: AUTH0_CLOUD_CLIENT_ID
    value: {{ .Values.global.bigid.web.auth0CloudClientId | quote }}
  - name: LLM_ENGINE_PORTAL_APP_URL
    value: {{ .Values.global.bigid.orchestrator2.llmEnginePortalAppUrl | quote }}
  {{- if .Values.global.bigid.processManager.create }}
  - name: STATE_MANAGEMENT_API_ENABLED
    value: {{ default "false" .Values.global.bigid.processManager.create | quote }}
  {{- end }}
  {{- if .Values.global.bigid.metadataSearch.create }}
  - name: METADATA_SEARCH_ENABLED
    value: "true"
  {{- end }}
  - name: AUTO_RETRY_SCAN_PARTS_FF
    value: {{ .Values.global.bigid.orchestrator2.autoRetryScanPartsFF | quote }}
  - name: CLASSIFICATION_NEW_FLOW_ENABLED
    value: {{ .Values.global.bigid.orchestrator2.classificationNewFlow | quote }}
  - name: SCAN_JOBS_IN_MEMORY_ENABLED
    value: {{ .Values.global.bigid.scanJobsInMemoryEnabled | quote }}
  - name: CORRELATION_SETS_INFRASTRUCTURE_ENABLED
    value: {{ .Values.global.bigid.orchestrator2.correlationSetsInfrastructureEnabled | quote }}
  - name: ENVIRONMENT_FF
    value: {{ .Values.global.bigid.orchestrator2.environmentFF | quote }}
  - name: DYNAMIC_MODIFY_PARSING_THREADS_FF
    value: {{ .Values.global.bigid.orchestrator2.dynamicModifyParsingThreadsFF | quote }}
  - name: USE_DISPLAY_NAME_FOR_POLICY_FF
    value: {{ .Values.global.bigid.useDisplayNameForPolicyFF | quote }}
  - name: TERMINATION_GRACE_PERIOD_SECONDS
    value: {{ .Values.global.bigid.orchestrator.appTerminationGracePeriodSeconds | quote }}
  - name: LOG_LEVEL
    value: {{ .Values.global.bigid.orchestrator2.logLevel | quote }}
  - name: MULTI_TENANT_CONFIG_ENABLED
    value: {{ .Values.global.bigid.configService.multiTenantConfigEnabled | quote }}
  - name: CYBERARK_MULTIPLY_PROVIDERS_FF
    value: {{ .Values.global.bigid.cyberarkMultiplyProviders | quote }}
  - name: ACTIONABLE_INSIGHTS_ENABLED
    value: {{ .Values.global.bigid.actionableInsights.enabled | quote }}
  - name: CONFIDENCE_LEVEL_CALCULATION_V2_FF
    value: {{ .Values.global.bigid.orchestrator2.confidenceLevelCalculationV2FF | quote }}
  - name: ENABLED_SCALABLE_DELETION
    value: {{ .Values.global.bigid.orchestrator.scalableDeletion.enabled | quote }}
  - name: HARD_STOP_DELETION_WORKERS
    value: {{ .Values.global.bigid.orchestrator.scalableDeletion.hardStopWorkers | quote }}
  - name: SCALABLE_PII_FINDINGS_DELETION_ENABLED
    value: {{ .Values.global.bigid.orchestrator.scalablePiiFindingsDeletion.enabled | quote }}
  - name: DELETIONS_SCHEDULE_INTERVAL
    value: {{ .Values.global.bigid.orchestrator2.scalableDeletion.scheduleInterval | quote }}
  - name: SCALABLE_DELETION_JOB_TTL
    value: {{ .Values.global.bigid.orchestrator2.scalableDeletion.jobTTL | quote }}
  - name: MAX_DELETION_WORKERS
    value: {{ .Values.global.bigid.orchestrator2.scalableDeletion.maxDeletionWorkers | quote }}
  - name: SCALABLE_DELETION_CHUNK_SIZE
    value: {{ .Values.global.bigid.orchestrator2.scalableDeletion.chunkSize | quote }}
  - name: UPDATED_AT_FIELD_UPDATES_INTERVAL_MS
    value: {{ .Values.global.bigid.orchestrator2.scalableDeletion.updatedAtFieldUpdatesIntervalMS | quote }}
  - name: CLASSIFICATION_FINDINGS_DELETION_ENABLED
    value: {{ .Values.global.bigid.orchestrator2.deleteClassificationFindings.enabled | quote }}
  - name: CLASSIFICATION_FINDINGS_DELETION_PERIOD_DAYS
    value: {{ .Values.global.bigid.orchestrator2.deleteClassificationFindings.deletionPeriodDays | quote }}
  - name: CLASSIFICATION_FINDINGS_DELETION_SCHEDULE_INTERVAL
    value: {{ .Values.global.bigid.orchestrator2.deleteClassificationFindings.scheduleInterval | quote }}
  - name: METADATA_UPDATE_BY_BULK_ENABLED
    value: {{ .Values.global.bigid.orchestrator2.metadataUpdateBulkEnabled | quote }}
  - name: METADATA_UPDATE_BY_BULK_SIZE
    value: {{ .Values.global.bigid.orchestrator2.metadataUpdateBulkSize | quote }}
  - name: STRUCTURED_CLASSIFICATION_SAMPLING_ENABLED
    value: {{ .Values.global.bigid.orchestrator2.structuredClassificationSamplingEnabled | quote }}
  - name : USE_BACKPRESSURE_BULK_UPDATES
    value: {{ .Values.global.bigid.orchestrator2.metadataUpdateBackpressure | quote }}
  - name: DYNAMIC_MODIFY_SCAN_WINDOW
    value: {{ .Values.global.bigid.dynamicModifyScanWindowFF.enabled | quote }}
  - name: ENABLE_SCAN_TEMPLATE
    value: {{ .Values.global.bigid.enableScanTemplateFF | quote }}
  - name: USE_SCAN_PAGE_STATE
    value: {{ .Values.global.bigid.useScanPageStateFF | quote }}
  - name: ENABLE_SSE_ON_ML
    value: {{ .Values.global.bigid.orchestrator2.enableSseOnMlFF | quote }}
  - name: CACHE_FINDINGS_FILTER_TTL_SEC
    value: {{ .Values.global.bigid.orchestrator.cacheFindingsFilterTTLSec | quote }}
  - name: MQ_DSPM_PREFETCH_COUNT
    value: {{ .Values.global.bigid.orchestrator2.mqDSPMPrefetchCount | quote }}
  - name: DISABLE_SERVICES_LOGS
    value: {{ .Values.global.bigid.shouldDisableLogs | quote }}
  - name: DISABLE_WIDE_CLASSIFIERS
    value: {{ .Values.global.bigid.orchestrator2.disableWideClassifiers | quote }}
  - name: DSAR_USE_CATALOG_COLUMNS_ENABLED_FF
    value: {{ .Values.global.bigid.dsarUseCatalogColumnsEnabled | quote }}
  - name: SIGNING_SERVICE_ENABLED
    value: {{ .Values.global.bigid.orchestrator2.signingServiceEnabled | quote }}
  - name: ENABLE_RELEASE_STUCK_PARTS_IN_CACHE
    value: {{ .Values.global.bigid.orchestrator.enableReleaseStuckPartsInCacheFF | quote }}
  - name: REDIS_QUEUED_SCAN_PARTS_MAX_IDLE_TIME_MINUTES
    value: {{ .Values.global.bigid.orchestrator.redisQueuedScanPartsMaxIdleTimeMinutesFF | quote }}
  - name: SCAN_WINDOW_SCHEDULER_ENABLED
    value: {{ .Values.global.bigid.orchestrator.scanWindowSchedulerEnabledFF | quote }}
  resources:
    {{- toYaml .Values.global.bigid.orchestrator2.resources | nindent 4 }}
  volumeMounts:
  - name: bigid-mongodb-ca
    mountPath: /etc/ssl/bigid
    readOnly: true
  - name: mongo-kerberos-orch2-secrets
    mountPath: /etc/kerberos
    readOnly: true
  {{- with .Values.global.extraVolumeMounts }}
    {{- toYaml . | nindent 2 }}
  {{- end }}
volumes:
- name: bigid-mongodb-ca
  secret:
    secretName: bigid-mongodb-ca
    defaultMode: 420
- name: mongo-kerberos-orch2-secrets
  secret:
    secretName: mongo-kerberos-secrets
    defaultMode: 420
{{ with .Values.global.extraVolumes }}
  {{- toYaml . }}
{{ end }}
restartPolicy: Always
terminationGracePeriodSeconds: {{ .Values.global.bigid.orchestrator.terminationGracePeriodSeconds }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- if .Values.global.bigid.podSecurityContext.enabled }}
securityContext: {{- omit .Values.global.bigid.podSecurityContext "enabled" | toYaml | nindent 2 }}
{{- end }}
{{- with .Values.global.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 8 }}
{{- end }}
{{- with .Values.global.affinity }}
affinity:
  {{- toYaml . | nindent 8 }}
{{- end }}
{{- with .Values.global.tolerations }}
tolerations:
  {{- toYaml . | nindent 8 }}
{{- end }}
{{- end }}
