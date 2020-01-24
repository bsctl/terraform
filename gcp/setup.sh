#!/bin/bash
#
# Copyright 2019 - Adriano Pezzuto
# https://github.com/kalise
#

echo "Setup the GCP env for Kubernetes"

NUM=3
REGION=europe-west1
ZONE=europe-west1-c
NETWORK=kubernetes
SUBNET=kubernetes
IMAGE=kubernetes
MACHINE_TYPE=n1-standard-2
LB_ADDRESS=10.10.10.100
SCOPES=cloud-platform
TAG=kubernetes

echo "Creating instances"
for i in $(seq -w 1 $NUM); do
   NAME=$TAG$(printf "%02.f" $i)
   ADDRESS=10.10.10.11$(expr $i)
   gcloud compute instances create $NAME \
       --async \
       --boot-disk-auto-delete \
       --boot-disk-type=pd-standard \
       --can-ip-forward \
       --image=$IMAGE \
       --machine-type=$MACHINE_TYPE \
       --restart-on-failure \
       --network-interface=network=$NETWORK,subnet=$SUBNET,private-network-ip=$ADDRESS \
       --tags=$TAG \
       --zone=$ZONE \
       --scopes=$SCOPES \
       --metadata startup-script='sudo yum update -y'
done


echo "Creating a health-check for masters"
gcloud compute health-checks create https masters-healthz \
    --port=6443 \
    --request-path=/healthz \
    --healthy-threshold=3 \
    --unhealthy-threshold=3 \
    --check-interval=10

echo "Creating the Internal Load Balancer for control plane"
gcloud compute backend-services create kubernetes-masters \
    --load-balancing-scheme=internal \
    --protocol=tcp \
    --region=$REGION \
    --health-checks=masters-healthz \
    --session-affinity=none \
    --timeout=30

echo "Creating backends for LooadBalancer"
for i in $(seq -w 1 $NUM); do
  NAME=$TAG$(printf "%02.f" $i)
  gcloud compute instance-groups unmanaged create masters-$NAME
  gcloud compute instance-groups unmanaged add-instances masters-$NAME \
    --zone=$ZONE \
    --instances=$NAME 
  gcloud compute backend-services add-backend kubernetes-masters \
    --region=$REGION \
    --instance-group=masters-$NAME \
    --instance-group-zone=$ZONE
done

gcloud compute forwarding-rules create kubernetes-masters \
    --region=$REGION \
    --load-balancing-scheme=internal \
    --network=$NETWORK \
    --subnet=$SUBNET \
    --address=$LB_ADDRESS \
    --ip-protocol=TCP \
    --ports=all \
    --backend-service=kubernetes-masters \
    --backend-service-region=europe-west1 \
    --service-label=kubernetes

echo "Setup completed"