# Open-E JovianDSS Kubernetes CSI plugin

[![Build Status](https://travis-ci.org/bserdar/JovianDSS-KubernetesCSI.svg?branch=master)](https://travis-ci.org/bserdar/JovianDSS-KubernetesCSI)
[![Go Report Card](https://goreportcard.com/badge/github.com/bserdar/JovianDSS-KubernetesCSI)](https://goreportcard.com/report/github.com/bserdar/JovianDSS-KubernetesCSI)

## Background

This fork of the plugin corrects the containerization of the original
JovianDSS CSI plugin and includes some code cleanup. The plugin uses
iscsiadm to stage a volume before mounting it. The original plugin
installed iscsiadm into the container and called that. This resulted
in effects of iscsciadm visible only in the plugin container, not on
the host. This corrects that. More background can be found in [this
article](https://www.docker.com/blog/road-to-containing-iscsi/). This
form implemented the 3rd option:

> Install open-iscsi on the host, run iscsid on the host. Run the container bind mounted with host root filesystem (docker run -v /:/host <container> <entrypoint>). 

> Create a chroot environment for iscsiadm with root set to host root
> filesystem and PATH set to appropriate host bin directories. Add
> this to a script named “iscsiadm”. Add this file to the container
> image and grant the right permissions. This ensures that every
> invocation of iscsiadm by the container calls the above chroot
> script. NetApp Trident uses this solution to containerize their
> Docker Volume Plugin.

The containers are built to expect host root to be mounted under /host
directory. For Kubernetes deployment, make sure to mount host root to
/host for the node plugins.

## Deployment


### Configuring

Plugin has 2 config files. Controller and node configs. Controller is responsible for a management of particular volumes on JovianDSS storage. When nodes responsibility is limited to connecting particular volume to particular host. Configuration file examples can be found in 'deploy/cfg/' folder.

 - **llevel** the logging level of the plugin

 - **plugins** specify the services that should be run in the plugin.
    Possible values: *IDENTITY_SERVICE*, *CONTROLLER_SERVICE*, *NODE_SERVICE*
    + **IDENTITY_SERVICE** - starts identity service, expected to run on each physical node with plugin
    + **CONTROLLER_SERVICE** - starts controller service, cluster should have only one instance of this service in running at a time
    + **NODE_SERVICE** - starts node service, this service is responsible for attaching physical volumes stored on JovianDSS
        This service should be running on every physical host that is expected to have containers with such feature.
 - **controller** - describes properties of controller service
    + **name** - name of JovianDSS storage, not used at the moment
    + **addr** - ip address of JovianDSS storage
    + **port** - port of JovianDSS storage, the port that is asigned to REST interface
    + **user** - user to execute REST requests
    + **pass** - password for the user specified above
    + **prot** - protocol that is gona be used for sending REST
    + **pool** - name of the pool created on JovianDSS
    + **tries** - number of attempts to send REST request if network related failure occured
    + **iddletimeout** - time maintain iddle session
 - **node** - describes properties of node service
    + **id** - prefix for a node name
    + **addr** - ip address of JovianDSS storage
    + **port** - port of JovianDSS storage, the port that is asigned to iSCSI volume sharing    


Add config files as secrets:

``` bash
kubectl create secret generic jdss-controller-cfg --from-file=./deploy/cfg/controller.yaml

kubectl create secret generic jdss-node-cfg --from-file=./deploy/cfg/node.yaml
```
Node config do not provides nothing but storage address and request to create proper services.

### Deploy plugin

Make sure that you have iscsi\_tcp module installed on the machines running node plugin.

If you change confing names from the previous step. Dont forget to modify  *joviandss-csi-controller.yaml* and *joviandss-csi-node.yaml* accordingly.
To deploy plugins to a cluster:

``` bash
kubectl apply -f ./deploy/joviandss/joviandss-csi-controller.yaml

kubectl apply -f ./deploy/joviandss/joviandss-csi-node.yaml 

kubectl apply -f ./deploy/joviandss/joviandss-csi-sc.yaml
```

If everything is OK, you should see something like:

```bash
[kub@kub-master /]$ kubectl get csidrivers

NAME                       CREATED AT
com.open-e.joviandss.csi   2019-06-07T22:52:01Z
```
and 

```bash
[kub@kub-master /]$ kubectl get pods

NAME                         READY   STATUS    RESTARTS   AGE
joviandss-csi-controller-0   3/3     Running   0          10d
joviandss-csi-node-q55k5     2/2     Running   0          10d
joviandss-csi-node-w2cp8     2/2     Running   0          10d
```


### Deploy application

In order to deploy application with automatic storage allocation run: 
``` bash
kubectl apply -f ./deploy/examples/nginx-pvc.yaml

kubectl apply -f ./deploy/examples/nginx.yaml
```

In order to deploy application with pre provisioned volume administrator first have to create volume.
It can be done with the help of [csc](https://github.com/rexray/gocsi/tree/master/csc) tool.
Once you obtain Id of the volume you can create persistent volume placing proper name of the volume into the file.
```bash
kubectl apply -f ./deploy/examples/nginx-pv.yaml
```



