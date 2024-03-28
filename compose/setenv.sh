export SAVE_SCANNED_IDENTITIES_AS_PII_FINDINGS=false
export RECURRING_INTERVAL_SEC=60
export BIGID_ENV=${BIGID_ENV:=:release-196.18}
export BIGID_DATE=2024-03-14
export BIGID_VERSION="${BIGID_ENV:1}"
export BIGID_GIT_HASH=88c933e18d0defc1719ee423a89e05d62bf3df21

SCANNER_JAVA_MEMORY_ARG="-Xmx16g"
#SCANNER_SSL_ARGS="-Djavax.net.ssl.trustStoreType=pkcs12 -Djavax.net.ssl.trustStore=/etc/scanner/keystore.p12 -Djavax.net.ssl.trustStorePassword=xxxxxxx"
export SCANNER_JAVA_OPTS="${SCANNER_JAVA_MEMORY_ARG} ${SCANNER_SSL_ARGS}"
# NER proxy enablement, enable IS_PROXY and use the NER_HTTP_PROXY and NER_HTTPS_PROXY env variables
#export NER_HTTP_PROXY=http://username:password@xx.xx.xx.xx:xxxx
#export NER_HTTPS_PROXY=https://username:password@xx.xx.xx.xx:xxxx

# Labeling proxy enablement, use HTTP_PROXY, HTTPS_PROXY env variables
#export HTTP_PROXY=http://<proxy ip>:<proxy port>
#export HTTPS_PROXY=http://<proxy ip>:<proxy port>
# Labeling self-signed certificate usage, use PROXY_SSL_CERTIFICATE, SSL_CERT_FILE env variables
#export PROXY_SSL_CERTIFICATE=<path to the cert to be copied into the container>
#export SSL_CERT_FILE=<path to the cert to be copied into the container>

#Send logs and metrics to BigID with NewRelic.
# to turn on: set TELEMETRY_ENABLED to true, comment out NEW_RELIC_LICENSE_KEY_VALUE. Then re-run the installation script.
export TELEMETRY_ENABLED=false
#export NEW_RELIC_LICENSE_KEY_VALUE=<put NR license here>
#Uncomment and set your company name with alphanumeric characters only!, no spaces or special characters.
#export MONITORING_CUSTOMER_NAME=<put customer name here>
# if New Relic is on, you can enable the New Relic APM feature on by setting NEW_RELIC_APM_ON to true
#export NEW_RELIC_APM_ON=true
#To remove running new-relic container - execute remove-new-relic-container.sh

## Run Spark Scanner
#export SPARK_SCANNER=true

## Enable DYNAMIC_MODIFY_PARSING_THREADS_FF that will let you dynamically modify the number of parsing threads for an already started scan
# export DYNAMIC_MODIFY_PARSING_THREADS_FF=true

## Enable to use scheduler
#export BIGID_SCHEDULER_ENABLED=true

## Run BigID environment with new correlator
#export CORRELATION_RECOVERY_SCHEDULER_FLAG=true

## Enables negative support term functionality
export NEGATIVE_SUPPORT_TERM_FF=true

## Enables classification findings in file names
#export CLASSIFY_FILE_NAMES_ENABLED=true

# Enables superscan prefiltering functionality
# export CLASSIFIER_SUPERSCAN_PREFILTERING_ENABLED=true

# export CLASSIFIER_SUPERSCAN_CACHE_EXPIRATION_PERIOD=4H

# Uncomment and set to true to disable NFS automount
# export DISABLE_NFS_AUTOMOUNT=false
# Uncomment and set to true to set NFS V4 protocol
# export NFS_V4_PROTOCOL=true

# Uncomment and set the location for storing the logs in Orchestrator and Web (default is /src/log - example modify it to /tmp/log for each)
# export BIGID_ENV_VARS=\{\"ORCH_LOGS_PATH\":\"/tmp/log\",\"WEB_LOGS_PATH\":\"/tmp/log\"\}
# export PAYLOAD_ENCRYPTION_KEY=xxxxxxxxxx

## new correlator Java SSL settings
# JAVA_SSL_KEY_STORE="-Djavax.net.ssl.keyStore=/etc/ssl/bigid/client.jks"
# JAVA_SSL_KEY_STORE_PASSWORD="-Djavax.net.ssl.keyStorePassword=xxxxxx"
# JAVA_SSL_TRUST_STORE="-Djavax.net.ssl.trustStore=/etc/ssl/bigid/truststore.jks"
# JAVA_SSL_TRUST_STORE_PASSWORD="-Djavax.net.ssl.trustStorePassword=xxxxxx"
export NEW_CORR_JVM_SSL_OPTS="${JAVA_SSL_KEY_STORE} ${JAVA_SSL_KEY_STORE_PASSWORD} ${JAVA_SSL_TRUST_STORE} ${JAVA_SSL_TRUST_STORE_PASSWORD}"
export CONFIG_SERVICE_JVM_SSL_OPTS="${NEW_CORR_JVM_SSL_OPTS}"

## New correlator default RAM size in jvm opts (uncomment line and set to desired value if override is needed)
## !!! Pls note that the xmx settings is now fixed at 6gb, and cache size limit (BIGID_CORR_CACHE_SIZE) is passed as a separate param and not as java opts
## in case bigid-all  set:
#export BIGID_CORR_CACHE_SIZE=6
## in case bigid-ext  set:
#export BIGID_CORR_CACHE_SIZE=10
## in case bigid-new-correlation (standalone)  set:
#export BIGID_CORR_CACHE_SIZE=16
#export NEW_CORR_JVM_OPTS=${NEW_CORR_JVM_OPTS:="-server -Xmx6g"}
#export CONFIG_SERVICE_JVM_OPTS=${CONFIG_SERVICE_JVM_OPTS:="-server -Xmx6g"}

## Run BigID with NER enabled
#export NER_CLASSIFIER_ENABLED_FEATURE_FLAG=true
#export NER_EXTRACT_ENTITIES_LANGUAGE_SPECIFIC=false
#export STRUCTURED_NER_LEVEL=1
#export NER_MODEL="en_bigid_ner_model_0.3.0"
#export NER_LOG_LEVEL="INFO"

## Run split scan enabled
#export SCAN_PARTS_ENABLED=true

## BigID Scanner Required Parameters (for remote scanner):
# export BIGID_USER=<change to BigID user>
# export BIGID_PASSWORD=<change to BigID password>
# export BIGID_REFRESH_TOKEN=<set a refresh token>
# export BIGID_UI_HOST_EXT=<url of main BigID server>
export BIGID_UI_API=/api/v1/
## BigID Scanner Optional Parameters:
# export HADOOP_DIST=hdp-2.6.0.2.2.0.20-9
# export SCANNER_HOST_NAME=BigID Scanner 1
# export SCANNER_GROUP_NAME=scanner1
# export TZ=<time zone>
# export BIG_ID_REPORT_LANGUAGE=kor
# export ENTITY_LEVEL_TAGGING_SUPPORTED
##To set environment variable SECUDIR=/etc/scanner/sap in Scanner:
#export SET_SAP_SECUDIR=true
## By default the oracle connector uses OJDBC version 8. in order to set it to run with version 7 uncomment
#export USE_OJDBC7=true
## By default the db2 connector uses IBM JCC JDBC 4 Driver. in order to set it to run with JCC JDBC 3 uncomment
#export USE_DB2_JCC3=true
## By default the SAS connector dependencies aren't compiled in the scanner.
#export USE_SAS=true
#export ENCRYPT_PAYLOAD=true
#export PAYLOAD_ENCRYPTION_KEY=xxxxxxxx

# Scanner privileged mode(allows scanner to mount files, for the use of nfs connector)
# export ENABLE_PRIVILEGED_SCANNER=false

# Scanner NerChunkCalculator (length of text that need to be sent to the ner,and percentage difference allowance )
# export REQUIRED_NER_TEXT_SIZE=100000
# export DELTA_NER_TEXT_PERCENT=5
# Scanner structuredClusteringManager (cache is kept on scanner before flushing to NER)
# export STRUCTURED_CLUSTERING_MAX_CACHE_SIZE=100
# Scanner structuredClusteringManager (cell's value is chopped to the following length before sent to NER)
# export STRUCTURED_CLUSTERING_MAX_TEXT_LENGTH=100
# Scanner run with bloom filter discovery engine (default value: AHO_CORASICK)
# export DISCOVERY_ENGINE_ALGORITHM=BLOOM_FILTER
# export DATA_PREVIEW_DISABLED=true

# nerThreadPoolTaskExecutor
# export NER_THREAD_POOL_TASK_EXECUTOR_CORE_POOL_SIZE=0
# export NER_THREAD_POOL_TASK_EXECUTOR_MAX_POOL_SIZE=10
# export NER_THREAD_POOL_TASK_EXECUTOR_QUEUE_CAPACITY=100
# Scan API
# export SCAN_API_ENABLED=true

# set ignite cluster url, example:
# export IGNITE_CLUSTER_URL=http://10.2.0.25:8080

# OpenLegacy Image Version-
export OL_ENV=${OL_ENV:=:latest}

# set external MongoDb connection string
# 1. config external MongoDB
# export BIGID_MONGO_HOST_EXT="<mongo-host-ip>"
# export BIGID_MONGO_PORT_EXT="<mongo-host-port>"
# export BIGID_MONGO_USER_EXT="<mongo-user>"
# export BIGID_MONGO_PASSWORD_EXT="<mongo-pass>"
# export BIGID_MONGO_AUTH_SOURCE_EXT="<mongo-auth-source>"

# 2. config MongoDb connection string
# export MONGO_EXTERNAL_FULL_URL="mongodb://$BIGID_MONGO_USER_EXT:$BIGID_MONGO_PASSWORD_EXT@$BIGID_MONGO_HOST_EXT:$BIGID_MONGO_PORT_EXT/bigid-server?authSource=$BIGID_MONGO_AUTH_SOURCE_EXT"
# export MONGO_EXTERNAL_FULL_URL="mongodb://<ldap-user>:<ldap-pass>@<mongo-host-ip>:27017/bigid-server?authSource=\$external&authMechanism=PLAIN"   //LDAP (PLAIN)

# 3. optional - enable mongo telemetry (NewRelic)
# export BIGID_MONGO_MONITOR_USER="<mongo-monitor-user>"
# export BIGID_MONGO_MONITOR_PASSWORD="<mongo-monitor-password>"
# export BIGID_MONGO_MONITOR_USE_SSL=false

# Java config client
# export BIGID_CONFIG_BASE_URL=bigid-config
# export IS_SCANNER_BLOCKED_BY_CONFIG_SERVICE=true

# To use labeler with proxy, add certificate file path to PROXY_SSL_CERTIFICATE
# PROXY_SSL_CERTIFICATE=<certificate_file_path>

# To use the ds credentials feature in an external app, update the field APPLICATION_CREDENTIALS_KEY
# Remember to add this same variable in the external application as well, in order to decrypt the credentials
# APPLICATION_CREDENTIALS_KEY=<application_credentials_key>



#reporting-etl
#export GOOGLE_APPLICATION_CREDENTIALS=

###
# bigid-elasticsearch settings

# export ELASTIC_ADMIN_PWD="Bigid111!"
# export BIGID_ELASTICSEARCH_PWD="Bigid111!"
export ES_JAVA_OPTS="-Dlog4j2.formatMsgNoLookups=true -Xms3g -Xmx3g"
# export BIGID_ELASTICSEARCH_QUERIES_CACHE_SIZE=30%
# export BIGID_ELASTICSEARCH_FIELDDATA_CACHE_SIZE=40%
export ES_CERTS_DIR="/usr/share/elasticsearch/config/certificates"
export ES_LOCAL_CRT_PATH="./elasticsearch/ssl/"
# export BIGID_ELASTICSEARCH_EXTERNAL_FULL_URL=<url of ES if external mode>

###
# bigid-metadata-search settings

# export JDK_MDSEARCH_JAVA_OPTIONS=-server -Xms4g -Xmx4g
# export MDSEARCH_MIN_REINDEX_PERIOD_MINUTES=60
# export MDSEARCH_INDEXING_TIMEOUT_MINUTES=10
# export MDSEARCH_CATALOG_UPLOADER_THREADS=50
# export MDSEARCH_UPLOADER_BULK_SIZE=400
# export MDSEARCH_CATALOG_CRON_SCHEDULE="0 0 2 * * *"
# export MDSEARCH_DEFAULT_CRON_SCHEDULE="0 0 2 * * *"
# export BIGID_ELASTICSEARCH_USE_SSL=true
# export BIGID_ELASTICSEARCH_SSL_CERT_PATH=/etc/ssl/bigid/es.crt

#Remote Scanner Remote Vault Custom Header pair (Header Name and Header Value
#export REMOTE_SCANNER_VAULT_CUSTOM_HEADER_NAME=
#export REMOTE_SCANNER_VAULT_CUSTOM_HEADER_VALUE=

# to use manual versioning for classifiers
# export DISABLE_AUTO_UPGRADE_OF_CLASSIFIERS=true

# To use classifications tester set the following env variable to true
# export CLASSIFIER_TESTER_ENABLED=false

# to use enable scalable health check
# export SCALABLE_HEALTH_CHECK_ENABLED=true

# to use enable bigid scheduler
# export BIGID_SCHEDULER_ENABLED=true

# Auto register applications on startup
export APPS_TO_AUTO_REGISTER="{ \"AWS Auto-Discovery App\": \"http://autodiscovery-aws:8080/api\" , \"Azure Auto-Discovery App\": \"http://autodiscovery-azure:8080/api\", \"GCP Auto-Discovery App\": \"http://autodiscovery-gcp:8080/api\", \"Classifier Helper\": \"http://classifier-helper:8080\" }"
export SHOULD_AUTO_REGISTER_APPLICATIONS=true
export HOTSPOTS_ENABLED=false

#To change the retry mechanism from infinite retries to get the token to 150 retries.
# export BIGID_HTTP_CLIENT_INFINITE_RETRIES=false

#To enable FIPS mode, set the following env variable to true (please note that fips mode works only for remote scanner - i.e, set IS_REMOTE_SCANNER=true)
# export IS_FIPS_MODE=true

#To enable process-manager API usage change the variable to true
export STATE_MANAGEMENT_API_ENABLED=false

# To enable feedback loop feature, change the variable to true
export FEEDBACK_LOOP_FF=true
export RISK_ASSESSMENT_ENABLED=true
#To enable to ability to make friendly names or policies
#export USE_DISPLAY_NAME_FOR_POLICY_FF=true

#To enable new certificates management view
#export ENABLE_NEW_CERTIFICATES_MANAGEMENT_VIEW_FF=true
export ENABLE_NEW_UX_NAVIGATION=true

#To enable scan templates guide tours
#export SHOW_GUIDED_TOUR_SCAN_TEMPLATES=false
#export SHOW_GUIDED_TOUR_CLASSIFICATION_STEP=false
#export SHOW_GUIDED_TOUR_SAVED_SCANS=false
#export SHOW_DIALOG_GUIDE_CONVERT_SCAN_PROFILE=false

#To enable auto retry for failed scans
export AUTO_RETRY_SCAN_PARTS_FF=true

#To enable bigid scan scheduler
#export BIGID_SCAN_SCHEDULER_ENABLED=true

#To enable bigid dynamic modify of scan window
#export DYNAMIC_MODIFY_SCAN_WINDOW=false

export ENVIRONMENT_FF="prod"


#To enable Connectivity Experience feature this ff should be true:
#export CONNECTIVITY_EXPERIENCE_ENABLED=true
#To enable DS Collaboration feature this ff should be true (currently for UI experience, must be enabled along with CONNECTIVITY_EXPERIENCE_ENABLED):
#export DS_COLLABORATION_ENABLED=true
# To enable the onboarding layout (data sources view) this ff should be true:
# export - DS_ONBOARDING_LAYOUT_ENABLED=true
#To enable New Tab Experience For Connectivity feature this ff should be true (currently as a sub feaeture must be enabled along with CONNECTIVITY_EXPERIENCE_ENABLED):
#export NEW_CONNECTION_TAB_ENABLED=true
#To enable Suggested Actions feature this ff should be true:
#export SUGGESTED_ACTIONS_ENABLED=true

## To enable snippets flow on scanner
#export CLASSIFICATION_SNIPPET_ENABLED=true
#export SNIPPET_CLIENT_TIMEOUT_MS=180000
## specify the address of snippet persister and the port used for communication
#export CLASSIFICATION_SNIPPET_SERVER_HOSTNAME="bigid-snippet-persister:443"
## specify communication protocol used when scanner is sending snippets via REST
#export CLASSIFICATION_SNIPPET_PROTOCOL=https
## specify snippet batch size for each request to the persister (default is 500)
#export SNIPPET_API_BATCH_SIZE=200

## To enable snippets flow on persister (used by snippet-aggregator as well)
#export DATABASE_ENDPOINT=<url of postgres DB server>
#export POSTGRES_DB=<name of postgres DB>
#export POSTGRES_SCHEMA=<name of postgres schema>

## To support AWS secret manager authentication to postgres DB
#export DB_AUTH_METHOD=AWS_SECRET_MANAGER
#export AWS_POSTGRES_SECRET_ID=<change to secrete id>
## used role if the account managing the EC2 does not hold permission to access AWS secret manager
#export POSTGRES_ROLE_ARN=<change to role>

## To support username password authentication to postgres DB
#export DB_AUTH_METHOD=USERNAME_PASSWORD
#export POSTGRES_USERNAME=<change to DB user>
#export POSTGRES_PASSWORD=<change to DB password>

##  snippet-persister optional parameters
#export HIKARI_MAX_LIFETIME=90000
#export HIKARI_CONNECTION_TIMEOUT=30000
#export HIKARI_MAX_POOL_SIZE=10

## snippet-aggregator related parameters
#export SNIPPET_APP_VERSION=${SNIPPET_APP_VERSION:=:1.0.0}
#export THREAD_POOL_SIZE=5 # set the number of requests the application can process in parallel

# set if you want to specify
#SNIPPET_PERSISTER_JVM_SSL_OPTS="-Djavax.net.ssl.trustStoreType=pkcs12 -Djavax.net.ssl.trustStore=/etc/scanner/keystore.p12 -Djavax.net.ssl.trustStorePassword=xxxxxxx"
#SNIPPET_PERSISTER_JVM_OPTS="-Xmx4g"

#to enable scan jobs move to orch2 use
# export SCAN_JOBS_IN_MEMORY_ENABLED=true

## Enable migration to add scan page state which adds new filed in parent scan for their current state
#export MIGRATE_TO_SCAN_PAGE_STATE=false

## Enable to use the new state in parentScans, for better performance in scan page.
#export USE_SCAN_PAGE_STATE=false

## Enable to use the new scan insight
#export SHOW_NEW_SCAN_INSIGHT=false

## Enable to use the scan template
#export ENABLE_SCAN_TEMPLATE=false

## Enable to use correlation set.
#export CORRELATION_SETS_INFRASTRUCTURE_ENABLED=true

#To enable legacy ACL
#export DISABLE_LEGACY_ACL_FF=true

# Enables scanner core thread pool to be expansible up to SCANNER_MAX_THREADS
#export EXPANSIBLE_THREAD_POOL=true

## Enable pipe '/scan-parts/:scan_part_id' to orch2
#export PIPE_SCAN_PARTS_TO_ORCH2=true

## enable immediate SSE sending for ML service
#export ENABLE_SSE_ON_ML=false

# enable backpressure for metadata bulk
#export USE_BACKPRESSURE_BULK_UPDATES= false

# enable metadata bulking
#export METADATA_UPDATE_BY_BULK_ENABLED = true
#export METADATA_UPDATE_BY_BULK_SIZE = 40

# disable usage of wide classifiers
#export DISABLE_WIDE_CLASSIFIERS = true

# Override node options configuration for node services
# export NODE_OPTIONS=''

# disable enable release stuck parts in cache
# export ENABLE_RELEASE_STUCK_PARTS_IN_CACHE= false

#enable new DSAR integration with Data catalog columns (Default: true)
#export DSAR_USE_CATALOG_COLUMNS_ENABLED_FF = true

# enable scan window scheduler
#export SCAN_WINDOW_SCHEDULER_ENABLED = true
