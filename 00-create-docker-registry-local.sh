#!/bin/bash
export https_proxy=
PATHCONF="/root/ocp4x/mirror-registry"
PATHCERTS="/opt/registry"
KEYNAMEX="domain.key"
CERTNAMEX="domain.crt"
ORG1="IBM"
OU1="Cloud"
DNS1="vbastion.ocp4.clouddemos.pe"
DNS2="vbastion.ocp4.clouddemos.pe"
IP1="150.238.44.132"
USERX="admin"
PASSWDX="db2admin#ICP"

yum -y install podman httpd httpd-tools

rm -fr $PATHCERTS/certs/*
rm -fr $PATHCERTS/data/*
rm -fr $PATHCERTS/auth/*
mkdir -p $PATHCERTS/{auth,certs,data}

echo "creando archivo domain.conf..."
cat <<EOF > $PATHCONF/domain.conf
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = PE
ST = Lima
L = Lima
O = ${ORG1}
OU = ${OU1}
CN = ${DNS1}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1=${DNS1}
DNS.2=${DNS2}
IP.1 = ${IP1}

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF
echo ""


echo "creando certificados autofirmados..."
cd $PATHCERTS/certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout $KEYNAMEX -x509 -days 10000 -out $CERTNAMEX -config $PATHCONF/domain.conf
echo ""

echo "crear usuario en el repositorio..."
htpasswd -bBc $PATHCERTS/auth/htpasswd $USERX $PASSWDX

echo "creando el registro local..."
podman run --name local-registry -p 5000:5000 -d -v $PATHCERTS/data:/var/lib/registry:z -v $PATHCERTS/auth:/auth:z -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" -e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -v /opt/registry/certs:/certs:z -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/$CERTNAMEX -e REGISTRY_HTTP_TLS_KEY=/certs/$KEYNAMEX docker.io/library/registry:2
echo ""

echo "cargando el certificado en el sistema bastion..."
rm -f /etc/pki/ca-trust/source/anchors/$CERTNAMEX
cp /opt/registry/certs/domain.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
echo ""

echo "finalizado el proceso de creación del repositorio local..."
