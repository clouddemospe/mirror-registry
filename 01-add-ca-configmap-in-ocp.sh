#!/bin/bash
OCPURL="https://api.ocp4.clouddemos.pe:6443"
USERX="admin"
PASSX="db2admin#ICP"
REPO="vbastion.ocp4.clouddemos.pe"
REPOPORT="5000"

echo "Loguearse en Red Hat OpenShift como usuario administrador..."
oc login $OCPURL -u $USERX -p $PASSX 

echo "Recuperar el certificado autofirmado desde el repositorio local..."
openssl s_client -connect $REPO:$REPOPORT -showcerts </dev/null 2>/dev/null |openssl x509 -outform PEM > ca.crt

echo "Crear un ConfigMap con el certificado autofirmado en Red Hat OpenShift..."
oc create configmap registry-cas -n openshift-config --from-file=$REPO..$REPOPORT=/etc/docker/certs.d/$REPO\:$REPOPORT/ca.crt

echo "Actualizar el cluster con la información de la nueva entidad certificadora..."
oc patch image.config.openshift.io/cluster --patch '{"spec":{"additionalTrustedCA":{"name":"registry-cas"}}}’ --type=merge
