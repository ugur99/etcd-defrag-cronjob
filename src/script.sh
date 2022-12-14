#!/bin/bash
export ETCDCTL_API=3;

APISERVER=https://kubernetes.default
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
ETCDCTL_CACERT=/etc/secret-volume/ca.pem
ETCDCTL_CERT=/etc/secret-volume/etcd-client.pem
ETCDCTL_KEY=/etc/secret-volume/etcd-client-key.pem


if [[ $(curl -s $PROMETHEUSSVC.$PROMETHEUSNS:9090/api/v1/alerts |  jq  '.data.alerts[] | select(.labels.alertname == "etcdDatabaseHighFragmentationRatio")') ]]; then
    echo "Active Alerts Exist" >> /proc/1/fd/1
    echo "Starting Defrag from the etcd nodes" >> /proc/1/fd/1
    for i in $(curl -s --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/kube-system/endpoints/etcd  | jq  '.subsets[].addresses[].ip' | cut -d'"' -f 2);do 
    # Check if i is not the leader then run etcdctl defrag command
      if [ $(etcdctl --endpoints=https://$i:2379 endpoint status --key=$ETCDCTL_KEY --cert=$ETCDCTL_CERT --cacert=$ETCDCTL_CACERT  |awk '{print $6}'| cut -f 1 -d  ",") == "false" ]; then
        # Its not a leader, letd defrag it!
        etcdctl --endpoints=https://$i:2379 defrag --key=$ETCDCTL_KEY --cert=$ETCDCTL_CERT --cacert=$ETCDCTL_CACERT >> /proc/1/fd/1
        sleep 10
      else
        # Its a leader, lets skip it for a now.
        :
      fi
    done

    for i in $(curl -s --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/kube-system/endpoints/etcd  | jq  '.subsets[].addresses[].ip' | cut -d'"' -f 2);do
    # Check if i is leader then run etcdctl defrag command
    echo "Starting Defrag from the etcd leader node" >> /proc/1/fd/1
      if [ $(etcdctl --endpoints=https://$i:2379  endpoint status --key=$ETCDCTL_KEY --cert=$ETCDCTL_CERT --cacert=$ETCDCTL_CACERT  |awk '{print $6}'| cut -f 1 -d  ",") = "true" ]; then
       # Its a leader, lets defrag it!
       etcdctl --endpoints=https://$i:2379  defrag --key=$ETCDCTL_KEY --cert=$ETCDCTL_CERT --cacert=$ETCDCTL_CACERT >> /proc/1/fd/1
      else
      :
      fi
    done

else
    echo "No Active Alerts" >> /proc/1/fd/1
fi