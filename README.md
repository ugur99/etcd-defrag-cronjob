# etcd defragmantation cronjob

This is a simple cronjob checks whether the [etcdDatabaseHighFragmentationRatio](https://github.com/etcd-io/etcd/blob/6d27a42b7d6191da43d27930282de5b9e54ead7c/contrib/mixin/mixin.libsonnet#L242-L253) alert is active for the cluster or not; if it is active, then it runs `etcdctl defrag` command for each etcd instances starting from the ones that are not leader.

### Some Notes 
* Version of `etcdctl` is `3.5.3`
* `Prometheus service` and its namespace should be set as an environment variable on the [cronjob.yml](k8s-templates/cronjob.yml).
* A `secret` object in which the `etcd client certs` and `CA` should exist.
* An `endpoint` object consisting of `etcd endpoints`. 

### References and Useful Discussions

* https://github.com/etcd-io/etcd/discussions/14975
* https://etcd.io/docs/v3.5/op-guide/maintenance/#defragmentation
* https://www.gojek.io/blog/a-few-notes-on-etcd-maintenance 
* https://coderise.io/etcd-on-kubernetes-with-high-availability-maintenance-part-3/ 
* https://kubernetes.slack.com/archives/C3HD8ARJ5/p1661525680896279 