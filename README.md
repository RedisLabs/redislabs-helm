# Redis Labs helm repository

## Redis Enterprise Chart

 To install the chart just run: 
 ```bash
helm install --namespace redis -n 'redis-enterprise' ./redis-enterprise
```
To install the chart with an override file:
 ```bash
helm install --namespace redis -n 'redis-enterprise' ./redis-enterprise -f ./redis-enterprise/values.yaml -f ./override-values.yaml
```

### GKE quickstart

```bash
password=$(gcloud container clusters describe YOUR_SETUP_NAME --zone us-central1-a | grep password | cut -d":" -f 2 | tr -d " ")
kubectl --username=admin --password=$password apply -f rbac_tiller.yaml
helm init --service-account tiller
helm install --namespace redis -n 'prod' ./redis-enterprise
```

### Generate static files
To generate static yaml files from the chart file you can run the following command (note the output dir should exists before running this):
```bash
helm template --namespace redis -n 'prod' ./redis-enterprise -f ./redis-enterprise/values.yaml -f ./override.yaml --output-dir /tmp/helm_out
```
> override files are not mandatory, its only needed if one would like to override the defaults values.

### Configuration options

* redisImage.repository: redis-enterprise docker repository. default: redislabs/redis.
* redisImage.tag: redis-enterprise version, for example: 5.0.2-15.
* numberofpods: number of desired redis-enterprise nodes. should be a odd number.
* redisResources: an object that describes the amount of resources you would like to allocate for redis-enterprise nodes. for example (2 CPUs and 4GB RAM memory):
```yaml
redisResources:
   limits:
    cpu: 2
    memory: 4096Mi
   requests:
    cpu: 2
    memory: 4096Mi
```
* redisControllerConfiguration
  * redisControllerConfiguration.bdbServiceType: comma separated list of service types to create for each bdb. 
    Possible values: cluster_ip, headless. default: "cluster_ip,headless".  
  * redisControllerConfiguration.serviceNaming: comma separated list of naming convention for bdb service.
    Possible values: redis-port (service will appear as redis-16784), bdb_name. default: "bdb_name".
* serviceAccount:
  * serviceAccount.create: whether to create or not a service account for redis-enterprise
  * serviceAccount.name: a specific name for the service account that will be used.
* adminUsername: a username to be used inside redis-enterprise, default: demo@redislabs.com
* adminPassword: if not set the chart will generate a random password
* license: redis-enterprise license.
* nodeSelector: specify a label selector to be used for nodes deployment.
```yaml
nodeSelector:
  cloud.google.com/gke-nodepool: redis-pool
```
* persistentVolume: if `persistentVolume.enabled` set to `true` the chart will use persistent disks.
  * persistentVolume.size: set the size of the disk, should be set to be 5X of the size of the node RAM.
  * persistentVolume.storageClass: optional, set the storageClass of the persistent disk
example:
```yaml
persistentVolume:
  enabled: true
  size: 20Gi  # This needs to be *5 the size of redis memory resources
  storageClass: ssd-disk
```

* externalUIServiceAnnotations: This should be used for annotating the UI service for redis-enterprise. for example:
```yaml
externalUIServiceAnnotations:
  service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
```

* openShiftDeployemnt: set to `true` to enable openshift SCC resource creation. default: `false`.

* imagePullSecrets: Allows the user to fetch the images using a Dockerhub specific user, example:
```yaml
imagePullSecrets:
- name: regsecret
```
