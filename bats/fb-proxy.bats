#!/usr/bin/env bats
# vim: ft=sh:sw=2:et

set -o pipefail

load os_helper
load foreman_helper

setup() {
  tSetOSVersion
  tPackageExists foreman-cli || tPackageInstall foreman-cli
  PROXY_INFO=$(hammer --output json proxy list --search "feature = \"Pulp Node\"")
  PROXY_ID=$(echo $PROXY_INFO | ruby -e "require 'json'; puts JSON.load(ARGF.read).first['Id']")
  PROXY_HOSTNAME=$(echo $PROXY_INFO | ruby -e "require 'json'; puts JSON.load(ARGF.read).first['Name']")
}

@test "proxy is registered" {
  hammer proxy info --id $PROXY_ID
}

@test "enable lifecycle environment for proxy" {
  hammer capsule content add-lifecycle-environment --id=$PROXY_ID --environment="Library" --organization="Default Organization"
}

@test "sync proxy" {
  hammer capsule content synchronize --id=$PROXY_ID
}

@test "content is available from proxy" {
  wget http://$PROXY_HOSTNAME/pulp/repos/Default_Organization/Library/Test_CV/custom/Test_Product/Zoo/walrus-0.71-1.noarch.rpm -P /tmp
  tFileExists /tmp/walrus-0.71-1.noarch.rpm && tNonZeroFile /tmp/walrus-0.71-1.noarch.rpm
}