## Introduction

This chart bootstraps BigID deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.22+ with Beta APIs enabled with a minimum available resources of 8 cores /vCPU's and 32GB RAM, for each scanner/correlator an extra of 4 cores /vCPU’s and 16 GB is needed
- MongoDB Server Version 4.4
- Kubernetes ingress controller, In order for the Ingress resource to work, the cluster must have an ingress controller running. [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
- Docker registry secret to pull docker images, fill imageCredentials.username imageCredentials.password in the values.yaml file.
  Alternatively if you already ran docker login, you can comment out imageCredentials block that credential into Kubernetes:
    - ```$ kubectl create secret generic registrypullsecret --from-file=.dockerconfigjson=/home/user/.docker/config.json
--type=kubernetes.io/dockerconfigjson```
For more information: [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)

## Installing the Chart

To install the chart with the release name `bigid`:

```$ helm install --name bigid . -f values.yaml```

## Production notes
To create the TLS Secret
```$ kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE} -n ${NAMESPACE}```

For more info [TLS Secrets](https://kubernetes.github.io/ingress-nginx/user-guide/tls/)

## Upgrding the chart

```$ helm upgrade bigid . -f values.yaml```

## Uninstalling the Chart

```$ helm delete --name bigid```

## Rollback the Chart

```$ helm rollback bigid 0```


## Parameters

Key | Value
--- | -----
global.tolerations | []
global.authKey |
global.secretKey |
global.existingSecretKeyName |
global.secretSalt |
global.payloadEncKey |
global.extraEnvVars | []
global.extraEnvVarsCM |
global.extraEnvVarsSecret |
global.extraVolumes | []
global.extraVolumeMounts | []
global.imageRegistry |
global.image.repository | bigid
global.image.tag | release
global.image.pullPolicy | IfNotPresent
global.imageCredentials.enabled | true
global.imageCredentials.registry | https://index.docker.io/v1/
global.imageCredentials.username |
global.imageCredentials.password |
global.imagePullSecrets | ['registrypullsecret']
global.ingress.class |
global.ingress.bigidHost | bigid.example.com
global.ingress.rabbitmqHost |
global.apm.enabled | false
global.apm.type | datadog
global.apm.customerName |
global.apm.key |
global.bigidInitWaitForTag | release-1
global.fips.enabled | false
global.timeZone | UTC
global.initContainers.image.registry |
global.initContainers.image.repository | alpine
global.initContainers.image.tag | edge
global.initContainers.resources.requests.memory | 256Mi
global.initContainers.resources.requests.cpu | 50m
global.initContainers.resources.limits.memory | 512Mi
global.initContainers.resources.limits.cpu | 250m
global.initContainers.containerSecurityContext.enabled | true
global.initContainers.containerSecurityContext.runAsNonRoot | true
global.initContainers.containerSecurityContext.runAsUser | 1001
global.initContainers.containerSecurityContext.runAsGroup | 1001
global.bigid.containerSecurityContext.enabled | true
global.bigid.containerSecurityContext.runAsUser | 1001
global.bigid.containerSecurityContext.runAsGroup | 1001
global.bigid.podSecurityContext.enabled | false
global.bigid.podSecurityContext.runAsUser | 1001
global.bigid.podSecurityContext.runAsGroup | 1001
global.bigid.dynamicModifyScanWindowFF.enabled | true
global.bigid.connectivityExperienceEnabled | true
global.bigid.newConnectionTabEnabled | false
global.bigid.dsCollaborationEnabled | false
global.bigid.dsOnboardingLayoutEnabled | false
global.bigid.classifierTester.enabled | true
global.bigid.useSaas.enabled | false
global.bigid.multiTenantMode.enabled | false
global.bigid.multiTenantMode.tenantDomainRegex | (http[s]?://)?(.*bigid[.]cloud)
global.bigid.multiTenantMode.generateAndUseMongoCreds | false
global.bigid.useDisplayNameForPolicyFF | false
global.bigid.enableUnifiedVaults | false
global.bigid.bigchatFFEnabled | false
global.bigid.saasEnv |
global.bigid.useScanPageStateFF | true
global.bigid.enableScanTemplateFF | true
global.bigid.scanJobsInMemoryEnabled | true
global.bigid.disableLegacyAclFF | true
global.bigid.sensitivityClassificationV2Enabled | true
global.bigid.aciDashboardUiV2Enabled | true
global.bigid.newScanInsightForLabelingEnabled | true
global.bigid.smbV2AciEnabled | false
global.bigid.companyName |
global.bigid.logConfiguration.jsonLogs.enabled | false
global.bigid.logConfiguration.amountOfLogsFile | 5
global.bigid.scalableHealthCheck.enabled | true
global.bigid.generateToken.enabled | false
global.bigid.dataLakeClient.enabled | false
global.bigid.dataLakeClient.dlStreamName |
global.bigid.dataLakeClient.dlRegionName |
global.bigid.riskAssessment.enabled | true
global.bigid.feedbackLoop.enabled | true
global.bigid.ddMetrics.ddApiKey |
global.bigid.ddMetrics.ddURI |
global.bigid.ddMetrics.dataDogEnabled | false
global.bigid.backpressure.enabled | false
global.bigid.backpressure.dryRunEnabled | false
global.bigid.backpressure.queuesConfiguration | [{"queue": "pii.findings.durable.queue","threshold": 10000}, {"queue": "correlator.correlation.queue","threshold": 10000}, {"queue": "correlator.classification.queue","threshold": 150000}, {"queue": "classification.findings.durable.queue","threshold": 10000}, {"queue": "catalog.object.scanned.queue","threshold": 150000}, {"queue": "catalog.object.scanned.bulk.queue","threshold": 2250}, {"queue": "catalog.source.piisummary.queue","threshold": 150000}, {"queue": "enrichment.findings.queue","threshold": 10000}, {"queue": "catalog.object.scan.completed.queue","threshold": 300000}]
global.bigid.backpressure.reportQueuesMetricsCronExp | */30 * * * * *
global.bigid.backpressure.excessiveLoadDetectionWindowInMin | 5
global.bigid.backpressure.systemOverloadDetectionCronExp | */40 * * * * *
global.bigid.backpressure.allowedConcurrentScannerJobs | 0
global.bigid.backpressure.recoveryThresholdPercentage | 40
global.bigid.backpressure.statusTtlSec | 120
global.bigid.actionableInsights.enabled | false
global.bigid.scanner.replicaCount | 1
global.bigid.scanner.fipsMode.enabled | false
global.bigid.scanner.fullnameOverride |
global.bigid.scanner.remote.enabled | false
global.bigid.scanner.hadoop.create | false
global.bigid.scanner.hadoop.fullnameOverride |
global.bigid.scanner.hadoop.groupName | SCANNER_WITH_HADOOP_GROUP
global.bigid.scanner.discoveryEngineAlgorithm | AHO_CORASICK
global.bigid.scanner.refreshToken |
global.bigid.scanner.encryptPayload | false
global.bigid.scanner.groupName | default
global.bigid.scanner.deletionScanThreads | 10
global.bigid.scanner.JavaOpts |
global.bigid.scanner.heapSizePercent | 85
global.bigid.scanner.extraEnvVars | []
global.bigid.scanner.threadPoolSize | 5
global.bigid.scanner.threadSize | 5
global.bigid.scanner.threadMaxSize | 50
global.bigid.scanner.expansibleThreadPool | false
global.bigid.scanner.orchClientMaxConnectionPerRoute | 24
global.bigid.scanner.orchClientMaxConnectionTotal | 34
global.bigid.scanner.internalMetadataProcessingThreads | 21
global.bigid.scanner.metadataBulk.enabled | false
global.bigid.scanner.isScannerBlockedByConfigService | false
global.bigid.scanner.dataPreviewDisabled | false
global.bigid.scanner.remoteScannerVaultCustomHeaderName |
global.bigid.scanner.remoteScannerVaultCustomHeaderValue |
global.bigid.scanner.scannerUser | bigid-scanner
global.bigid.scanner.testConnection.threadSize | 2
global.bigid.scanner.testConnection.threadMaxSize | 5
global.bigid.scanner.testConnection.queueSize | 10
global.bigid.scanner.resources.requests.memory | 14Gi
global.bigid.scanner.resources.requests.cpu | 7
global.bigid.scanner.resources.limits.memory | 14Gi
global.bigid.scanner.resources.limits.cpu | 7
global.bigid.scanner.set_sap_secudir | false
global.bigid.scanner.use_ojdbc7 | false
global.bigid.scanner.use_db2_jcc3 | false
global.bigid.scanner.use_sas | false
global.bigid.scanner.serviceAccount.create | false
global.bigid.scanner.extraVolumes | []
global.bigid.scanner.extraVolumeMounts | []
global.bigid.scanner.sidecars | []
global.bigid.scanner.nfsV4.enabled | false
global.bigid.scaler.create | false
global.bigid.scaler.replicaCount | 1
global.bigid.scaler.fullnameOverride |
global.bigid.scaler.resources.requests.memory | 256Mi
global.bigid.scaler.resources.requests.cpu | 200m
global.bigid.scaler.resources.limits.memory | 2Gi
global.bigid.scaler.resources.limits.cpu | 1000m
global.bigid.scaler.image.tag |
global.bigid.scaler.scannerController.enabled | false
global.bigid.scaler.scannerName | bigid-scanner
global.bigid.scaler.scannerGroup | default
global.bigid.scaler.queueScanPartsThreshold | 30
global.bigid.scaler.cpuThreshold | 80
global.bigid.scaler.cpuScaleDownThreshold | 20
global.bigid.scaler.queueThreshold | 15
global.bigid.scaler.minPods | 1
global.bigid.scaler.maxPods | 3
global.bigid.scaler.threadsActivityHistogramLength | 10
global.bigid.scaler.partsSizeQueueHistogramLength | 10
global.bigid.scaler.queueHistogramLength | 10
global.bigid.scaler.lockTTLMinutes | 15
global.bigid.scaler.scalingCoolDownMinutes | 15
global.bigid.scaler.candidateGraceMinutes | 5
global.bigid.correlator.replicaCount | 1
global.bigid.correlator.serviceAccount.create | true
global.bigid.correlator.port | 7082
global.bigid.correlator.consumerThreadNumber | 2
global.bigid.correlator.maxConnectionsPerRoute | 5
global.bigid.correlator.maxTotalConnections | 10
global.bigid.correlator.terminationGracePeriodSeconds | 300
global.bigid.correlator.ignite.enabled | false
global.bigid.correlator.ignite.clusterName | ignite
global.bigid.correlator.ignite.namespace | gridgain
global.bigid.correlator.ignite.cacheMode | PARTITIONED
global.bigid.correlator.ignite.backups | 3
global.bigid.correlator.numbersLengthThreshold | 9
global.bigid.correlator.autoscaling.enabled | false
global.bigid.correlator.autoscaling.minReplicas | 1
global.bigid.correlator.autoscaling.maxReplicas | 3
global.bigid.correlator.autoscaling.averageValue | 250
global.bigid.correlator.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.correlator.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.correlator.autoscaling.scaleDownPolicy.value | 10
global.bigid.correlator.JavaOpts |
global.bigid.correlator.heapSizePercent | 85
global.bigid.correlator.resources.requests.memory | 14Gi
global.bigid.correlator.resources.requests.cpu | 3
global.bigid.correlator.resources.limits.memory | 14Gi
global.bigid.correlator.resources.limits.cpu | 3
global.bigid.ner.create | false
global.bigid.ner.port | 8080
global.bigid.ner.resources.requests.memory | 3Gi
global.bigid.ner.resources.requests.cpu | 2
global.bigid.ner.resources.limits.memory | 7Gi
global.bigid.ner.resources.limits.cpu | 4
global.bigid.ner.disableAutoUpgradeClassifiers |
global.bigid.ner.envForDynaconf | prod
global.bigid.ner.nerModel |
global.bigid.ner.nerLogLevel | INFO
global.bigid.ner.isNerProxy | false
global.bigid.ner.httpProxy |
global.bigid.ner.httpsProxy |
global.bigid.ner.persistence.enabled | false
global.bigid.ner.persistence.type | PersistentVolumeClaim
global.bigid.ner.persistence.hostPath | /opt/bigid/ner
global.bigid.ner.persistence.storageClass | standard
global.bigid.ner.persistence.accessModes | ['ReadWriteMany']
global.bigid.ner.persistence.storage | 8Gi
global.bigid.labeler.create | false
global.bigid.labeler.httpProxy |
global.bigid.labeler.httpsProxy |
global.bigid.labeler.enableLabelerCustomCert | false
global.bigid.web.replicaCount | 1
global.bigid.web.port | 3000
global.bigid.web.serviceAccount.create | true
global.bigid.web.livenessProbe.enabled | true
global.bigid.web.readinessProbe.enabled | true
global.bigid.web.nodeOptions |
global.bigid.web.logLevel | info
global.bigid.web.nodeMaxOldSpaceSizePercent | 85
global.bigid.web.resources.requests.memory | 500Mi
global.bigid.web.resources.requests.cpu | 250m
global.bigid.web.resources.limits.memory | 2Gi
global.bigid.web.resources.limits.cpu | 1
global.bigid.web.domain |
global.bigid.web.maxUsers |
global.bigid.web.okta_app_id |
global.bigid.web.apiToken |
global.bigid.web.auth0Domain |
global.bigid.web.auth0CloudHostDomain |
global.bigid.web.auth0CustomDomain |
global.bigid.web.auth0CloudTestMode |
global.bigid.web.auth0DBConnectionName |
global.bigid.web.auth0CloudClientSecret |
global.bigid.web.auth0CloudClientId |
global.bigid.web.auth0TenantLambdaClientId |
global.bigid.web.Auth0TokenClaimsNamespace | https://bigid.cloud/claims
global.bigid.web.Auth0AppNameAttrInTokenClaims | appName
global.bigid.web.auth0RedirectProtocol | https://
global.bigid.web.bigidUiPortExt | 443
global.bigid.web.idpType |
global.bigid.web.isSmallId | false
global.bigid.web.enableCloudMerger | false
global.bigid.web.cloudPortalApiUrl | https://portal-api-staging.bigid.cloud
global.bigid.web.fmsdEnabled | false
global.bigid.web.enabledCustomerIdp | true
global.bigid.web.mtCorrelation.enabled | false
global.bigid.web.auditLogPersistency | false
global.bigid.web.printAuditToStdout | false
global.bigid.web.useAuditObjectApi | false
global.bigid.web.writeAuditLogsToMq | false
global.bigid.web.enableNewUxNavigation | true
global.bigid.web.enableNewCertificatesManagementView | true
global.bigid.web.enableCatalogHistory | false
global.bigid.web.pipeToOrch2Conditionally | true
global.bigid.web.webPvcStorageClassName | standard
global.bigid.web.webPvcStorageSizeGb | 1Gi
global.bigid.web.licenseKey |
global.bigid.web.legacyAdminRoles | false
global.bigid.web.pipeScanPartsToOrch2FF | false
global.bigid.web.showNavigationGuidedTour | true
global.bigid.web.autoscaling.enabled | false
global.bigid.web.autoscaling.minReplicas | 1
global.bigid.web.autoscaling.maxReplicas | 5
global.bigid.web.autoscaling.targetCPUUtilizationPercentage | 85
global.bigid.web.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.web.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.web.autoscaling.scaleDownPolicy.value | 10
global.bigid.ui.dynamicModifyParsingThreadsFF | true
global.bigid.ui.negativeSupportTermFF | true
global.bigid.ui.replicaCount | 1
global.bigid.ui.serviceAccount.create | true
global.bigid.ui.resources.requests.memory | 256Mi
global.bigid.ui.resources.requests.cpu | 250m
global.bigid.ui.resources.limits.memory | 2Gi
global.bigid.ui.resources.limits.cpu | 2500m
global.bigid.ui.service.type | ClusterIP
global.bigid.ui.service.port | 80
global.bigid.ui.service.nodePort | 30846
global.bigid.ui.tls.certFile |
global.bigid.ui.tls.keyFile |
global.bigid.ui.tls.dhParam |
global.bigid.ui.autoscaling.enabled | false
global.bigid.ui.autoscaling.minReplicas | 1
global.bigid.ui.autoscaling.maxReplicas | 5
global.bigid.ui.autoscaling.targetCPUUtilizationPercentage | 85
global.bigid.ui.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.ui.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.ui.autoscaling.scaleDownPolicy.value | 10
global.bigid.clustering.create | false
global.bigid.clustering.celeryControlDisabled | false
global.bigid.clustering.serviceAccount.create | true
global.bigid.clustering.image.repository | bigid-ml
global.bigid.clustering.worker.replicaCount | 1
global.bigid.clustering.worker.resources.requests.memory | 500Mi
global.bigid.clustering.worker.resources.requests.cpu | 500m
global.bigid.clustering.worker.resources.limits.memory | 6Gi
global.bigid.clustering.worker.resources.limits.cpu | 3
global.bigid.clustering.scheduler.replicaCount | 1
global.bigid.clustering.scheduler.resources.requests.memory | 500Mi
global.bigid.clustering.scheduler.resources.requests.cpu | 250m
global.bigid.clustering.scheduler.resources.limits.memory | 2Gi
global.bigid.clustering.scheduler.resources.limits.cpu | 1
global.bigid.clustering.gateway.replicaCount | 1
global.bigid.clustering.gateway.port | 3300
global.bigid.clustering.gateway.resources.requests.memory | 500Mi
global.bigid.clustering.gateway.resources.requests.cpu | 500m
global.bigid.clustering.gateway.resources.limits.memory | 5Gi
global.bigid.clustering.gateway.resources.limits.cpu | 2
global.bigid.clustering.hotspots.create | false
global.bigid.clustering.hotspots.replicaCount | 1
global.bigid.clustering.hotspots.resources.requests.memory | 500Mi
global.bigid.clustering.hotspots.resources.requests.cpu | 500m
global.bigid.clustering.hotspots.resources.limits.memory | 6Gi
global.bigid.clustering.hotspots.resources.limits.cpu | 3
global.bigid.confluent.create | false
global.bigid.confluent.replicaCount | 1
global.bigid.confluent.serviceAccount.create | true
global.bigid.confluent.containerSecurityContext.enabled | false
global.bigid.confluent.podSecurityContext.enabled | false
global.bigid.confluent.resources.requests.memory | 3Gi
global.bigid.confluent.resources.requests.cpu | 1
global.bigid.confluent.resources.limits.memory | 16Gi
global.bigid.confluent.resources.limits.cpu | 4
global.bigid.bigidme.create | false
global.bigid.bigidme.replicaCount | 1
global.bigid.bigidme.serviceAccount.create | true
global.bigid.bigidme.port | 3500
global.bigid.bigidme.JavaOpts |
global.bigid.bigidme.heapSizePercent | 85
global.bigid.bigidme.clientSecret |
global.bigid.bigidme.clientId |
global.bigid.bigidme.refreshToken |
global.bigid.bigidme.resources.requests.memory | 3Gi
global.bigid.bigidme.resources.requests.cpu | 1
global.bigid.bigidme.resources.limits.memory | 3Gi
global.bigid.bigidme.resources.limits.cpu | 1
global.bigid.aci.create | false
global.bigid.aci.replicaCount | 1
global.bigid.aci.serviceAccount.create | true
global.bigid.aci.port | 4001
global.bigid.aci.nodeOptions |
global.bigid.aci.nodeMaxOldSpaceSizePercent | 85
global.bigid.aci.resources.requests.memory | 1Gi
global.bigid.aci.resources.requests.cpu | 1
global.bigid.aci.resources.limits.memory | 6Gi
global.bigid.aci.resources.limits.cpu | 1
global.bigid.aci.autoscaling.enabled | false
global.bigid.aci.autoscaling.minReplicas | 1
global.bigid.aci.autoscaling.maxReplicas | 8
global.bigid.aci.autoscaling.averageValue | 2000
global.bigid.aci.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.aci.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.aci.autoscaling.scaleDownPolicy.value | 10
global.bigid.aci.prefetchCountSensitivityClassificationStructured | 10
global.bigid.aci.prefetchCountSensitivityClassificationUnstructured | 100
global.bigid.aci.prefetchCountRouteCatalogDiffsToSCQueue | 300
global.bigid.aci.aciDashboardGenerationEnabled | true
global.bigid.aci.coaDirectAccessPoliciesEnabled | false
global.bigid.actionCenter.create | true
global.bigid.actionCenter.replicaCount | 1
global.bigid.actionCenter.serviceAccount.create | true
global.bigid.actionCenter.port | 3556
global.bigid.actionCenter.nodeOptions |
global.bigid.actionCenter.logLevel | info
global.bigid.actionCenter.nodeMaxOldSpaceSizePercent | 85
global.bigid.actionCenter.resources.requests.memory | 1Gi
global.bigid.actionCenter.resources.requests.cpu | 1
global.bigid.actionCenter.resources.limits.memory | 6Gi
global.bigid.actionCenter.resources.limits.cpu | 1200m
global.bigid.reportingEtl.create | false
global.bigid.reportingEtl.replicaCount | 1
global.bigid.reportingEtl.serviceAccount.create | true
global.bigid.reportingEtl.port | 3557
global.bigid.reportingEtl.nodeOptions |
global.bigid.reportingEtl.logLevel | info
global.bigid.reportingEtl.nodeMaxOldSpaceSizePercent | 85
global.bigid.reportingEtl.resources.requests.memory | 1Gi
global.bigid.reportingEtl.resources.requests.cpu | 1
global.bigid.reportingEtl.resources.limits.memory | 6Gi
global.bigid.reportingEtl.resources.limits.cpu | 1200m
global.bigid.reportingEtl.clientId |
global.bigid.reportingEtl.clientSecret |
global.bigid.reportingEtl.disDeploymentMode |
global.bigid.reportingEtl.disLookerProdUrl | https://bigid.cloud.looker.com/login
global.bigid.reportingEtl.disLookerDevUrl | https://bigidtest.cloud.looker.com/login
global.bigid.reportingEtl.autoscaling.enabled | false
global.bigid.reportingEtl.autoscaling.minReplicas | 1
global.bigid.reportingEtl.autoscaling.maxReplicas | 4
global.bigid.reportingEtl.autoscaling.targetCPUUtilizationPercentage | 80
global.bigid.reportingEtl.autoscaling.targetMemoryUtilizationPercentage | 80
global.bigid.reportingEtl.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.reportingEtl.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.reportingEtl.autoscaling.scaleDownPolicy.value | 10
global.bigid.collaboration.create | false
global.bigid.collaboration.replicaCount | 1
global.bigid.collaboration.serviceAccount.create | true
global.bigid.collaboration.resources.requests.memory | 256Mi
global.bigid.collaboration.resources.requests.cpu | 50m
global.bigid.collaboration.resources.limits.memory | 6Gi
global.bigid.collaboration.resources.limits.cpu | 1
global.bigid.tenantService.create | false
global.bigid.tenantService.port | 3558
global.bigid.tenantService.replicaCount | 1
global.bigid.tenantService.fullnameOverride | bigid-tenant-service
global.bigid.tenantService.nodeOptions |
global.bigid.tenantService.nodeMaxOldSpaceSizePercent | 85
global.bigid.tenantService.resources.requests.memory | 1Gi
global.bigid.tenantService.resources.requests.cpu | 1
global.bigid.tenantService.resources.limits.memory | 6Gi
global.bigid.tenantService.resources.limits.cpu | 1200m
global.bigid.tenantService.generateAndStoreSecretsInSecretsManager.enabled | false
global.bigid.tenantService.awsSecretsManager.region | us-east-1
global.bigid.tenantService.generateAndUseElasticSearchCreds.enabled | false
global.bigid.tenantService.shouldPublishMigrationRequestToPortal.enabled | false
global.bigid.tenantService.atlasApiSecretName |
global.bigid.tenantService.mongodb.adminTenantId | 00000000
global.bigid.tenantService.mongodb.bigidDbName | bigid-server
global.bigid.reports.replicaCount | 1
global.bigid.reports.serviceAccount.create | true
global.bigid.reports.port | 3005
global.bigid.reports.nodeOptions |
global.bigid.reports.nodeMaxOldSpaceSizePercent | 85
global.bigid.reports.resources.requests.memory | 1Gi
global.bigid.reports.resources.requests.cpu | 1
global.bigid.reports.resources.limits.memory | 6Gi
global.bigid.reports.resources.limits.cpu | 1200m
global.bigid.reports.logLevel | info
global.bigid.orchestrator.replicaCount | 1
global.bigid.orchestrator.serviceAccount.create | true
global.bigid.orchestrator.port | 3001
global.bigid.orchestrator.nodeOptions |
global.bigid.orchestrator.nodeMaxOldSpaceSizePercent | 85
global.bigid.orchestrator.scanPartsStartupExecutorEnabled | false
global.bigid.orchestrator.objectProfilingBiEvents | false
global.bigid.orchestrator.correlationRecoverySchedulerFlag | false
global.bigid.orchestrator.autoRetryScanPartsFF | true
global.bigid.orchestrator.classificationNewFlow | true
global.bigid.orchestrator.bigIDScanSchedulerEnabled | true
global.bigid.orchestrator.environmentFF | prod
global.bigid.orchestrator.dynamicModifyParsingThreadsFF | true
global.bigid.orchestrator.applicationsCredentialsKey |
global.bigid.orchestrator.hyperScanAutoFallbackEnabled | true
global.bigid.orchestrator.correlationSetsInfrastructureEnabled | false
global.bigid.orchestrator.terminationGracePeriodSeconds | 120
global.bigid.orchestrator.appTerminationGracePeriodSeconds | 115
global.bigid.orchestrator.enableSseOnMlFF | true
global.bigid.orchestrator.scalableDeletion.enabled | false
global.bigid.orchestrator.scalablePiiFindingsDeletion.enabled | false
global.bigid.orchestrator.newCredentialsFlow.enabled | false
global.bigid.orchestrator.classifierSuperscanPrefiltering.enabled | false
global.bigid.orchestrator.cacheFindingsFilterTTLSec | 604800
global.bigid.orchestrator.logLevel | trace
global.bigid.orchestrator.resources.requests.memory | 1Gi
global.bigid.orchestrator.resources.requests.cpu | 1
global.bigid.orchestrator.resources.limits.memory | 6Gi
global.bigid.orchestrator.resources.limits.cpu | 1200m
global.bigid.orchestrator2.replicaCount | 1
global.bigid.orchestrator2.serviceAccount.create | true
global.bigid.orchestrator2.consumer.create | false
global.bigid.orchestrator2.consumer.autoscaling.enabled | false
global.bigid.orchestrator2.consumer.autoscaling.minReplicas | 1
global.bigid.orchestrator2.consumer.autoscaling.maxReplicas | 5
global.bigid.orchestrator2.consumer.autoscaling.averageValue | 250
global.bigid.orchestrator2.consumer.autoscaling.completedQueueThreshold | 250
global.bigid.orchestrator2.consumer.autoscaling.targetCPUUtilizationPercentage | 75
global.bigid.orchestrator2.consumer.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.orchestrator2.consumer.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.orchestrator2.consumer.autoscaling.scaleDownPolicy.value | 10
global.bigid.orchestrator2.port | 3003
global.bigid.orchestrator2.nodeOptions |
global.bigid.orchestrator2.nodeMaxOldSpaceSizePercent | 85
global.bigid.orchestrator2.prefetchCount | 40
global.bigid.orchestrator2.autoRetryScanPartsFF | true
global.bigid.orchestrator2.classificationNewFlow | true
global.bigid.orchestrator2.environmentFF | prod
global.bigid.orchestrator2.dynamicModifyParsingThreadsFF | true
global.bigid.orchestrator2.correlationSetsInfrastructureEnabled | false
global.bigid.orchestrator2.confidenceLevelCalculationV2FF | false
global.bigid.orchestrator2.enableSseOnMlFF | true
global.bigid.orchestrator2.llmEnginePortalAppUrl | https://portal-bigchat-staging.bigid.cloud
global.bigid.orchestrator2.logLevel | trace
global.bigid.orchestrator2.resources.requests.memory | 1Gi
global.bigid.orchestrator2.resources.requests.cpu | 1
global.bigid.orchestrator2.resources.limits.memory | 6Gi
global.bigid.orchestrator2.resources.limits.cpu | 1200m
global.bigid.orchestrator2.autoscaling.enabled | false
global.bigid.orchestrator2.autoscaling.minReplicas | 1
global.bigid.orchestrator2.autoscaling.maxReplicas | 5
global.bigid.orchestrator2.autoscaling.averageValue | 250
global.bigid.orchestrator2.autoscaling.completedQueueThreshold | 250
global.bigid.orchestrator2.autoscaling.targetCPUUtilizationPercentage | 75
global.bigid.orchestrator2.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.orchestrator2.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.orchestrator2.autoscaling.scaleDownPolicy.value | 10
global.bigid.orchestrator2.scalableDeletion.scheduleInterval | 10000
global.bigid.orchestrator2.scalableDeletion.jobTTL | 60000
global.bigid.orchestrator2.scalableDeletion.maxDeletionWorkers | 10
global.bigid.orchestrator2.scalableDeletion.chunkSize | 1000
global.bigid.orchestrator2.scalableDeletion.updatedAtFieldUpdatesIntervalMS | 5000
global.bigid.orchestrator2.deleteClassificationFindings.enabled | false
global.bigid.orchestrator2.deleteClassificationFindings.deletionPeriodDays | 60
global.bigid.orchestrator2.deleteClassificationFindings.scheduleInterval | 1440
global.bigid.configService.replicaCount | 1
global.bigid.configService.serviceAccount.create | true
global.bigid.configService.port | 3004
global.bigid.configService.JavaOpts |
global.bigid.configService.heapSizePercent | 85
global.bigid.configService.resources.requests.memory | 1Gi
global.bigid.configService.resources.requests.cpu | 1
global.bigid.configService.resources.limits.memory | 6Gi
global.bigid.configService.resources.limits.cpu | 2
global.bigid.configService.logLevel | info
global.bigid.configService.booleanMap | false
global.bigid.configService.skipClusteringConf | false
global.bigid.configService.useRedisCache | false
global.bigid.configService.multiTenantConfigEnabled | false
global.bigid.configService.loginLimitEnabled | true
global.bigid.processManager.create | false
global.bigid.processManager.serviceAccount.create | true
global.bigid.processManager.autoscaling.enabled | false
global.bigid.processManager.autoscaling.minReplicas | 1
global.bigid.processManager.autoscaling.maxReplicas | 5
global.bigid.processManager.autoscaling.targetCPUUtilizationPercentage | 75
global.bigid.processManager.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.processManager.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.processManager.autoscaling.scaleDownPolicy.value | 10
global.bigid.snippetPersister.create | false
global.bigid.snippetPersister.serviceAccount.create | true
global.bigid.snippetPersister.port | 9990
global.bigid.snippetPersister.JavaOpts |
global.bigid.snippetPersister.heapSizePercent | 85
global.bigid.snippetPersister.postgres.enabled | true
global.bigid.snippetPersister.postgres.endpoint |
global.bigid.snippetPersister.postgres.db | postgres
global.bigid.snippetPersister.postgres.schema | public
global.bigid.snippetPersister.postgres.username |
global.bigid.snippetPersister.postgres.password |
global.bigid.snippetPersister.postgres.authentication | AWS_SECRET_MANAGER
global.bigid.snippetPersister.postgres.arnRole |
global.bigid.snippetPersister.postgres.awsSecretId |
global.bigid.snippetPersister.postgres.existingAuthSecret.enabled | false
global.bigid.snippetPersister.snowflake.enabled | false
global.bigid.snippetPersister.snowflake.username |
global.bigid.snippetPersister.snowflake.token |
global.bigid.snippetPersister.snowflake.account |
global.bigid.snippetPersister.snowflake.database |
global.bigid.snippetPersister.snowflake.schema |
global.bigid.snippetPersister.snowflake.region |
global.bigid.snippetPersister.snowflake.oauthSecret |
global.bigid.snippetPersister.snowflake.arnRole |
global.bigid.snippetPersister.resources.requests.memory | 512Mi
global.bigid.snippetPersister.resources.requests.cpu | 250m
global.bigid.snippetPersister.resources.limits.memory | 3Gi
global.bigid.snippetPersister.resources.limits.cpu | 1500m
global.bigid.snippetPersister.logLevel | info
global.bigid.snippetPersister.enableSimulator | false
global.bigid.metadataSearch.create | false
global.bigid.metadataSearch.replicaCount | 1
global.bigid.metadataSearch.serviceAccount.create | true
global.bigid.metadataSearch.ssl | false
global.bigid.metadataSearch.port | 8082
global.bigid.metadataSearch.elasticsearchSsl.create | false
global.bigid.metadataSearch.JavaOpts |
global.bigid.metadataSearch.heapSizePercent | 85
global.bigid.metadataSearch.resources.requests.memory | 1Gi
global.bigid.metadataSearch.resources.requests.cpu | 1
global.bigid.metadataSearch.resources.limits.memory | 6Gi
global.bigid.metadataSearch.resources.limits.cpu | 2
global.bigid.metadataSearch.logLevel | info
global.bigid.metadataSearch.catalogUploaderThreads | 10
global.bigid.metadataSearch.uploaderBulkSize | 400
global.bigid.catalogProcessor.create | false
global.bigid.catalogProcessor.replicaCount | 1
global.bigid.catalogProcessor.serviceAccount.create | true
global.bigid.catalogProcessor.JavaOpts |
global.bigid.catalogProcessor.heapSizePercent | 85
global.bigid.catalogProcessor.resources.requests.memory | 500Mi
global.bigid.catalogProcessor.resources.requests.cpu | 250m
global.bigid.catalogProcessor.resources.limits.memory | 2Gi
global.bigid.catalogProcessor.resources.limits.cpu | 1
global.bigid.catalogProcessor.port | 8099
global.bigid.catalogProcessor.updateStrategy.type | RollingUpdate
global.bigid.catalogProcessor.updateStrategy.rollingUpdate.maxSurge | 1
global.bigid.catalogProcessor.updateStrategy.rollingUpdate.maxUnavailable | 0
global.bigid.lineage.create | false
global.bigid.lineage.livenessProbe.enabled | true
global.bigid.lineage.readinessProbe.enabled | true
global.bigid.lineage.serviceAccount.create | true
global.bigid.lineage.replicaCount | 1
global.bigid.lineage.ssl | false
global.bigid.lineage.port | 7070
global.bigid.lineage.JavaOpts |
global.bigid.lineage.heapSizePercent | 85
global.bigid.lineage.nodeOptions |
global.bigid.lineage.nodeMaxOldSpaceSizePercent | 85
global.bigid.lineage.resources.requests.memory | 1Gi
global.bigid.lineage.resources.requests.cpu | 1
global.bigid.lineage.resources.limits.memory | 6Gi
global.bigid.lineage.resources.limits.cpu | 2
global.bigid.lineage.logLevel | info
global.bigid.dataCatalog.port | 3555
global.bigid.dataCatalog.replicaCount | 1
global.bigid.dataCatalog.serviceAccount.create | true
global.bigid.dataCatalog.nodeOptions |
global.bigid.dataCatalog.nodeMaxOldSpaceSizePercent | 85
global.bigid.dataCatalog.logLevel | info
global.bigid.dataCatalog.resources.requests.memory | 1Gi
global.bigid.dataCatalog.resources.requests.cpu | 1
global.bigid.dataCatalog.resources.limits.memory | 6Gi
global.bigid.dataCatalog.resources.limits.cpu | 1200m
global.bigid.dataCatalog.autoscaling.enabled | false
global.bigid.dataCatalog.autoscaling.minReplicas | 1
global.bigid.dataCatalog.autoscaling.maxReplicas | 5
global.bigid.dataCatalog.autoscaling.averageValue | 250
global.bigid.dataCatalog.autoscaling.targetCPUUtilizationPercentage | 75
global.bigid.dataCatalog.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.dataCatalog.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.dataCatalog.autoscaling.scaleDownPolicy.value | 10
global.bigid.dataCatalogConsumer.create | true
global.bigid.dataCatalogConsumer.serviceAccount.create | true
global.bigid.dataCatalogConsumer.replicaCount | 1
global.bigid.dataCatalogConsumer.port | 3554
global.bigid.dataCatalogConsumer.nodeOptions |
global.bigid.dataCatalogConsumer.logLevel | info
global.bigid.dataCatalogConsumer.nodeMaxOldSpaceSizePercent | 85
global.bigid.dataCatalogConsumer.prefetchCount | 40
global.bigid.dataCatalogConsumer.terminationGracePeriodSeconds | 120
global.bigid.dataCatalogConsumer.appTerminationGracePeriodSeconds | 115
global.bigid.dataCatalogConsumer.graceComplete.enabled | false
global.bigid.dataCatalogConsumer.graceComplete.countThreshold | 50
global.bigid.dataCatalogConsumer.graceComplete.pctThreshold | 0.99
global.bigid.dataCatalogConsumer.resources.requests.memory | 1Gi
global.bigid.dataCatalogConsumer.resources.requests.cpu | 750m
global.bigid.dataCatalogConsumer.resources.limits.memory | 4Gi
global.bigid.dataCatalogConsumer.resources.limits.cpu | 1200m
global.bigid.dataCatalogConsumer.autoscaling.enabled | false
global.bigid.dataCatalogConsumer.autoscaling.minReplicas | 1
global.bigid.dataCatalogConsumer.autoscaling.maxReplicas | 5
global.bigid.dataCatalogConsumer.autoscaling.averageValue | 250
global.bigid.dataCatalogConsumer.autoscaling.scaleDownPolicy.stabilizationWindowSeconds | 900
global.bigid.dataCatalogConsumer.autoscaling.scaleDownPolicy.periodSeconds | 300
global.bigid.dataCatalogConsumer.autoscaling.scaleDownPolicy.value | 10
global.corrAffinity | podAntiAffinity:
global.scannerAffinity | podAntiAffinity:
rabbitmq.enabled | true
rabbitmq.fullnameOverride | bigid-mq
rabbitmq.replicaCount | 1
rabbitmq.auth.username | bigid
rabbitmq.auth.password | password
rabbitmq.persistence.enabled | false
rabbitmq.persistence.storageClass |
rabbitmq.persistence.accessMode | ReadWriteOnce
rabbitmq.persistence.size | 8Gi
rabbitmq.image.repository | bitnami/rabbitmq
rabbitmq.image.tag | 3.12.12
rabbitmq.exporter.image.repository | rabbitmq-exporter
rabbitmq.exporter.image.tag | 1.0.0-RC19
rabbitmq.exporter.additionalLabels.app | bigid-mq-exporter
rabbitmq.exporter.podLabels.app | bigid-mq-exporter
rabbitmq.exporter.podAnnotations.prometheus.io/scrape | true
rabbitmq.exporter.podAnnotations.prometheus.io/port | 9419
rabbitmq.statefulsetLabels.app | bigid-mq
rabbitmq.podSecurityContext.enabled | true
rabbitmq.podSecurityContext.fsGroup | 1001
rabbitmq.podSecurityContext.runAsUser | 1001
rabbitmq.serviceAccount.create | true
rabbitmq.serviceAccount.name |
rabbitmq.metrics.enabled | false
rabbitmq.metrics.serviceMonitor.enabled | false
rabbitmq.metrics.serviceMonitor.namespace | monitoring
rabbitmq.resources.limits.cpu | 3000m
rabbitmq.resources.limits.memory | 7Gi
rabbitmq.resources.requests.cpu | 500m
rabbitmq.resources.requests.memory | 500Mi
rabbitmq.ingress.enabled | false
rabbitmq.ingress.path | /
rabbitmq.ingress.pathType | ImplementationSpecific
rabbitmq.ingress.hostname | None
rabbitmq.ingress.ingressClassName |
rabbitmq.memoryHighWatermark.enabled | true
rabbitmq.memoryHighWatermark.type | relative
rabbitmq.memoryHighWatermark.value | 0.85
rabbitmq.externalRabbitmq.enabled | false
rabbitmq.externalRabbitmq.hostname |
rabbitmq.externalRabbitmq.port |
rabbitmq.externalRabbitmq.auth.username |
rabbitmq.externalRabbitmq.auth.password |
mongodb.externalMongo.enabled | false
mongodb.externalMongo.port | 27017
mongodb.externalMongo.auth.username | bigid
mongodb.externalMongo.auth.password | password
mongodb.externalMongo.uriPrefix | mongodb
mongodb.externalMongo.uri | bigid-server?authSource=admin&replicaSet=bigid-replica-set
mongodb.externalMongo.externalIP |
mongodb.externalMongo.existingAuthSecret.enabled | false
mongodb.externalMongo.existingKrbSecret | false
mongodb.externalMongo.existingSslSecrets.enabled | false
mongodb.enabled | false
mongodb.architecture | replicaset
mongodb.fullnameOverride | bigid-mongodb
mongodb.commonLabels.app | bigid-mongodb
mongodb.replicaCount | 1
mongodb.persistence.enabled | false
mongodb.hidden.persistence.enabled | false
mongodb.arbiter.enabled | false
mongodb.metrics.enabled | false
mongodb.metrics.serviceMonitor.enabled | false
mongodb.metrics.serviceMonitor.namespace | monitoring
mongodb.service.ports.mongodb | 27017
mongodb.livenessProbe.enabled | true
mongodb.readinessProbe.enabled | true
mongodb.image.registry | docker.io
mongodb.image.repository | bitnami/mongodb
mongodb.image.tag | 5.0-debian-11
mongodb.auth.rootUser | bigid
mongodb.auth.rootPassword | password
mongodb.tls.enabled | false
mongodb.tls.autoGenerated | false
mongodb.tls.existingSecret | bigid-mongodb-ca
mongodb.replicaSetName | bigid-replica-set
redis.enabled | true
redis.fullnameOverride | bigid-cache
redis.serviceAccount.create | true
redis.commonLabels.app | bigid-cache
redis.architecture | standalone
redis.replica.replicaCount | 3
redis.replica.persistence.enabled | false
redis.replica.podSecurityContext.enabled | true
redis.replica.podSecurityContext.fsGroup | 1001
redis.replica.containerSecurityContext.enabled | true
redis.replica.containerSecurityContext.runAsUser | 1001
redis.replica.resources.requests.memory | 512Mi
redis.replica.resources.requests.cpu | 250m
redis.replica.resources.limits.memory | 2Gi
redis.replica.resources.limits.cpu | 4
redis.master.count | 1
redis.master.persistence.enabled | false
redis.master.livenessProbe.initialDelaySeconds | 45
redis.master.livenessProbe.timeoutSeconds | 20
redis.master.resources.requests.memory | 512Mi
redis.master.resources.requests.cpu | 250m
redis.master.resources.limits.memory | 2Gi
redis.master.resources.limits.cpu | 4
redis.master.containerSecurityContext.enabled | true
redis.master.containerSecurityContext.runAsUser | 1001
redis.master.podSecurityContext.enabled | true
redis.master.podSecurityContext.fsGroup | 1001
redis.image.repository | bitnami/redis
redis.image.tag | 7.2.4
redis.auth.enabled | true
redis.auth.password | password
redis.metrics.enabled | false
redis.metrics.serviceMonitor.enabled | false
redis.metrics.serviceMonitor.namespace | monitoring
redis.sentinel.enabled | false
redis.sentinel.masterSet | bigid-master
redis.sentinel.livenessProbe.initialDelaySeconds | 45
redis.sentinel.livenessProbe.timeoutSeconds | 60
redis.externalRedis.enabled | false
redis.externalRedis.hostname |
redis.externalRedis.port |
redis.externalRedis.password |
elasticsearch.enabled | false
elasticsearch.fullUrl | https://bigid-elasticsearch:9200
elasticsearch.tenantId | mdsearch
elasticsearch.port.transport | 9300
elasticsearch.port.http | 9200
elasticsearch.security.enabled | true
elasticsearch.security.user | elastic
elasticsearch.security.elasticPassword | password
elasticsearch.security.tls.restEncryption | true
elasticsearch.image.repository | bitnami/elasticsearch
elasticsearch.image.tag | 7.17.18
elasticsearch.sysctlImage.enabled | true
elasticsearch.sysctlImage.registry | docker.io
elasticsearch.sysctlImage.repository | bitnami/os-shell
elasticsearch.sysctlImage.tag | 11-debian-11
elasticsearch.data.replicaCount | 2
elasticsearch.data.fullnameOverride | bigid-elasticsearch-data
elasticsearch.data.servicenameOverride | bigid-elasticsearch-data
elasticsearch.data.resources.limits.cpu | 4
elasticsearch.data.resources.limits.memory | 24Gi
elasticsearch.data.resources.requests.cpu | 1
elasticsearch.data.resources.requests.memory | 8Gi
elasticsearch.data.persistence.enabled | false
elasticsearch.data.persistence.storageClass |
elasticsearch.data.persistence.size | 50Gi
elasticsearch.data.podSecurityContext.enabled | true
elasticsearch.data.podSecurityContext.fsGroup | 1001
elasticsearch.data.containerSecurityContext.enabled | true
elasticsearch.data.containerSecurityContext.runAsUser | 1001
elasticsearch.data.containerSecurityContext.runAsNonRoot | true
elasticsearch.master.masterOnly | true
elasticsearch.master.replicaCount | 1
elasticsearch.master.resources.limits.cpu | 4
elasticsearch.master.resources.limits.memory | 16Gi
elasticsearch.master.resources.requests.cpu | 1
elasticsearch.master.resources.requests.memory | 4Gi
elasticsearch.master.fullnameOverride | bigid-elasticsearch
elasticsearch.master.servicenameOverride | bigid-elasticsearch
elasticsearch.master.podSecurityContext.enabled | true
elasticsearch.master.podSecurityContext.fsGroup | 1001
elasticsearch.master.containerSecurityContext.enabled | true
elasticsearch.master.containerSecurityContext.runAsUser | 1001
elasticsearch.master.containerSecurityContext.runAsNonRoot | true
elasticsearch.master.persistence.enabled | false
elasticsearch.master.persistence.storageClass |
external-apps.ropa.enabled | false
external-apps.ropa.replicaCount | 1
external-apps.ropa.serviceAccount.create | true
external-apps.pia.enabled | false
external-apps.pia.replicaCount | 1
external-apps.pia.serviceAccount.create | true
external-apps.risk-tagger.enabled | false
external-apps.risk-tagger.replicaCount | 1
external-apps.risk-tagger.serviceAccount.create | true
external-apps.classifier-helper.enabled | false
external-apps.classifier-helper.replicaCount | 1
external-apps.classifier-helper.serviceAccount.create | true
external-apps.aws-discovery.enabled | false
external-apps.aws-discovery.serviceAccount.create | true
external-apps.aws-discovery.replicaCount | 1
external-apps.azure-discovery.enabled | false
external-apps.azure-discovery.replicaCount | 1
external-apps.azure-discovery.serviceAccount.create | true
external-apps.gcp-discovery.enabled | false
external-apps.gcp-discovery.replicaCount | 1
external-apps.gcp-discovery.serviceAccount.create | true
external-apps.remediation.enabled | false
external-apps.remediation.replicaCount | 1
external-apps.remediation.serviceAccount.create | true
external-apps.retention.enabled | false
external-apps.retention.replicaCount | 1
external-apps.retention.serviceAccount.create | true
external-apps.actions.enabled | false
external-apps.actions.replicaCount | 1
external-apps.actions.serviceAccount.create | true
external-apps.alation.enabled | false
external-apps.alation.replicaCount | 1
external-apps.alation.serviceAccount.create | true
external-apps.collibra.enabled | false
external-apps.collibra.replicaCount | 1
external-apps.collibra.serviceAccount.create | true
external-apps.jira.enabled | false
external-apps.jira.image.tag | 1.8.0.171
