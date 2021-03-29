#!/bin/bash
LOCAL_REG='vbastion.ocp4.clouddemos.pe:5000'
LOCAL_REPO='ocp/openshift4'
SHA256_SUM="@sha256:6ae80e777c206b7314732aff542be105db892bf0e114a6757cb9e34662b8f891"

GODEBUG=x509ignoreCN=0 oc adm upgrade --allow-explicit-upgrade --to-image ${LOCAL_REG}/${LOCAL_REPO}$SHA256_SUM
