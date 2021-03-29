#!/bin/bash
https_proxy=
RELEASE="4.6.21"
OCP_ARCH="-x86_64"
OCP_RELEASE="$RELEASE$OCP_ARCH"
LOCAL_REG='vbastion.ocp4.clouddemos.pe:5000'
LOCAL_REPO='ocp/openshift4'
PRODUCT_REPO='openshift-release-dev'
LOCAL_SECRET_JSON="$HOME/.openshift/pull-secret-new.json"
RELEASE_NAME="ocp-release"
OCPURLX="https://api.ocp4.demo.com:6443"
REPOURLX="https://vbastion.ocp4.clouddemos.pe:5000/v2/_catalog"
USERX="admin"
PASSWDX="db2admin#ICP"

echo "probando el repositorio local"
curl -u $USERX:$PASSWDX -k $REPOURLX
echo ""

echo "agregando credenciales y creando nuevo pull secret"
jq '.auths += {"vbastion.ocp4.clouddemos.pe:5000": {"auth": "YWRtaW46ZGIyYWRtaW4jSUNQ","email": "noemail@localhost"}}' < ./pull-secret.json > ~/.openshift/pull-secret-new.json
echo ""

echo "loguearse en Red Hat OpenShift"
oc login $OCPURLX -u $USERX -p $PASSWDX
echo ""

echo "cargando imagenes en el repositorio local"
GODEBUG=x509ignoreCN=0 oc adm release mirror -a ${LOCAL_SECRET_JSON} \
--from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
--to=${LOCAL_REG}/${LOCAL_REPO} \
--to-release-image=${LOCAL_REG}/${LOCAL_REPO}:${OCP_RELEASE} --apply-release-image-signature \
| tee mirror-out.txt
echo ""

##########################################################
# DESCOMENTAR SOLO SI ES DURANTE EL PROCESO DE INSTALACION
##########################################################
#echo "creando installer con registro local"
#GODEBUG=x509ignoreCN=0 oc adm release extract -a ${LOCAL_SECRET_JSON} --command=openshift-install "${LOCAL_REG}/${LOCAL_REPO}:${OCP_RELEASE}"
############################################################################
# DESCOMENTAR SI SE USA UN DISCO O MEDIO EXTERNO CON LAS IMAGENES DESCARGADAS
############################################################################
#oc image mirror -a ${LOCAL_SECRET_JSON} --from-dir=${REMOVABLE_MEDIA_PATH}/mirror "file://openshift/release:${OCP_RELEASE}*" ${LOCAL_REG}/${LOCAL_REPO}
#echo ""

echo "probando el repo"
curl -u $USERX:$PASSWDX -k $REPOURLX
