#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"

#echo "before you start - please make sure setenv.sh has values for NEW_RELIC_LICENSE_KEY_VALUE, MONITORING_CUSTOMER_NAME, APPEND_TO_JSON_LOGS"
echo "before you start - please make sure setenv.sh has values for NEW_RELIC_LICENSE_KEY_VALUE, MONITORING_CUSTOMER_NAME and TELEMETRY_ENABLED"

read -p "Are you done updating setenv.sh [Y/y]? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    source setenv.sh
    echo "...continue with the installation. "
else
    echo 're-run the script to finish the setup'
    exit 0
fi

echo ''
echo ''
echo "******************************************"
echo '** New Relic Installation - PLEASE READ **'
echo "******************************************"
echo "follow the instructions for your Linux distro at"
echo "(replace YOUR_LICENSE_KEY with $NEW_RELIC_LICENSE_KEY_VALUE):"

echo "1. Add Infrastructure monitoring (as privileged user):"
echo "https://docs.newrelic.com/docs/infrastructure/new-relic-infrastructure/installation/install-infrastructure-linux#install-privileged"

echo "2. Make sure you are user is a member of the 'docker' user group:"
echo 'https://docs.newrelic.com/docs/infrastructure/new-relic-infrastructure/data-instrumentation/docker-instrumentation-infrastructure'

echo "******************************************"
echo ''
echo ''


read -p "Are you done installing new relic agent [Y/y]? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo 'editing /etc/newrelic-infra.yml...'
    sudo -E bash -c 'echo "license_key: ${NEW_RELIC_LICENSE_KEY_VALUE}" > /etc/newrelic-infra.yml'
    sudo -E bash -c 'echo "custom_attributes:" >> /etc/newrelic-infra.yml'
    sudo -E bash -c 'echo "  monitoringCustomerName: ${MONITORING_CUSTOMER_NAME}" >> /etc/newrelic-infra.yml'

    #adding nri-agent to docker group, and restart new relic infra agent service
    sudo usermod -aG docker nri-agent && sudo systemctl restart newrelic-infra.service

    echo ''
    echo '********************************************************************************************************'
    echo '** Please restart according to system topology with ./run-bigid-all.sh, ./run-bigid-ext-mongo.sh etc. **'
    echo '********************************************************************************************************'
    echo ''

    echo 'Withing few minutes you should start getting monitoring data on New Relic (https://www.newrelic.com)'

    exit
fi

echo 're-run the script to finish the setup'
exit
