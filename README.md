# openshift-ansible-vagrant-env
My personal vagrant environment for testing the openshift ansible installer.
Runs the installer against either fedora-atomic 27 or fedora 27.

You will need `ansible >= 2.4`, `vagrant >= 1.8`, and `vagrant-hostmanager` to be installed,
and will need a local copy of [openshift-ansible](https://github.com/openshift/openshift-ansible).

You can specify an atomic install with the `ATOMIC` environment variable:
```bash
ATOMIC=true vagrant up
```

You can also specify the location of your openshift-ansible directory with
the `OPENSHIFT_ANSIBLE_DIR` environent variable:
```bash
OPENSHIFT_ANSIBLE_DIR=/code/openshift-ansible vagrant up
```

If you don't specify `OPENSHIFT_ANSIBLE_DIR`, it will look in the following
directories, in order:

- ./openshift-ansible
- ../openshift-ansible
- ~/openshift-ansible
- /usr/share/ansible/openshift-ansible
