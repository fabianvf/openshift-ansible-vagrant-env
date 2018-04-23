#!/bin/bash
set -ex

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

git clone git@github.com:openshift/openshift-ansible ${TMPDIR}/openshift-ansible
pushd ${TMPDIR}/openshift-ansible
git checkout release-3.7
popd

cat <<-EOF > install-37.yml
---
- hosts: all
  gather_facts: false
  tasks:
    - name: wait for host to come up
      wait_for_connection:
- import_playbook: ${TMPDIR}/openshift-ansible/playbooks/byo/config.yml
EOF

export PLAYBOOK='install-37.yml'
export IMAGE_TAG='v3.7.0'
vagrant up --no-parallel --provision

pushd ${TMPDIR}/openshift-ansible
git checkout release-3.9
popd

cat <<-EOF > upgrade-39.yml
---
- hosts: all
  gather_facts: false
  tasks:
    - name: wait for host to come up
      wait_for_connection:
- import_playbook: ${TMPDIR}/openshift-ansible/playbooks/prerequisites.yml
- import_playbook: ${TMPDIR}/openshift-ansible/playbooks/byo/openshift-cluster/upgrades/v3_9/upgrade.yml
EOF

export PLAYBOOK='upgrade-39.yml'
export IMAGE_TAG='v3.9.0'
vagrant provision --provision-with ansible

rm -f install-37.yml
rm -f upgrade-39.yml
