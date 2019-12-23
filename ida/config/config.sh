IDA_ENVIRONMENT="TEST"
DEBUG="true"
FLUSH_REPLICATED_FILES_BEFORE_TESTS="false"

IDA_MIGRATION="false"
PRE_MIGRATION="false"
SHARE_PROJECT_AFTER_TS=0

HTTPD_USER="apache"

NC_ADMIN_USER="admin"
NC_ADMIN_PASS="test"
PROJECT_USER_PASS="test"
TEST_USER_PASS="test"
BATCH_ACTION_TOKEN="test"

RABBIT_HOST="rabbitmq-ida.csc.local"
RABBIT_PORT=5672
RABBIT_WEB_API_PORT=15672
RABBIT_VHOST="ida-vhost"
RABBIT_ADMIN_USER="ida-admin"
RABBIT_ADMIN_PASS="changeme"
RABBIT_WORKER_USER="ida-worker"
RABBIT_WORKER_PASS="changeme"
RABBIT_WORKER_LOG_FILE="/mnt/storage_vol01/log/agents.log"
RABBIT_HEARTBEAT=0
RABBIT_MONITOR_USER="ida-monitor"
RABBIT_MONITOR_PASS="changeme"
RABBIT_MONITORING_DIR="/mnt/storage_vol01/log/rabbitmq_monitoring"

METAX_AVAILABLE=1
METAX_FILE_STORAGE_ID="urn:nbn:fi:att:file-storage-ida"
METAX_FILE_STORAGE_ID=1
METAX_API_USER="metax-user"
METAX_API_ROOT_URL="https://metax.csc.local/rest/v1"
METAX_API_RPC_URL="https://metax.csc.local/rpc/v1"
METAX_API_PASS="changeme"

ROOT="/var/ida"
OCC="$ROOT/nextcloud/occ"
LOG="/mnt/storage_vol01/log/ida.log"

IDA_API_ROOT_URL="https://ida.csc.local/apps/ida/api"
URL_BASE_SHARE='https://ida.csc.local/ocs/v1.php/apps/files_sharing/api/v1/shares'
URL_BASE_FILE='https://ida.csc.local/remote.php/webdav'
URL_BASE_GROUP='https://ida.csc.local/ocs/v1.php/cloud/groups'
URL_BASE_IDA="https://ida.csc.local/apps/ida"

LDAP_HOST_URL=""
LDAP_BIND_USER=""
LDAP_PASSWORD=""
LDAP_SEARCH_BASE=""

# multiple local storage volumes
STORAGE_CANDIDATES=("/mnt/storage_vol01/ida" "/mnt/storage_vol02/ida")
STORAGE_OC_DATA_ROOT="/mnt/storage_vol01/ida"

DATA_REPLICATION_ROOT="/mnt/storage_vol02/ida_replication"
TRASH_DATA_ROOT="/mnt/storage_vol02/ida_trash"
QUARANTINE_PERIOD="0"

#EMAIL_SENDER="firstname.lastname@csc.fi"
#EMAIL_RECIPIENTS="firstname.lastname@csc.fi"
