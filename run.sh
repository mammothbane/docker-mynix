#!/bin/bash

# create target nix location
mkdir -p ${NIX_NEW_HOME}/{overlays,store,var}

# make sure we have the latest nix. In particular we want overlays (in nix 1.11.8+)
nix-channel --update && nix-env -u -j `nproc`

mkdir -p ${HOME}/.config/nixpkgs/
ln -s ${NIX_NEW_HOME}/overlays ${HOME}/.config/nixpkgs/overlays

# create overlay for custom paths
cat > ${HOME}/.config/nixpkgs/overlays/01-nix-path.nix <<EOF
self: super:
{
    nix = super.nix.override {
        storeDir = "${NIX_NEW_HOME}/store";
        stateDir = "${NIX_NEW_HOME}/var";
    };
}
EOF

# create a nix version that targets the custom location
nix-env -i nix nss-cacert -j `nproc`

# create a nix version that also *lives* in the custom location
nix-env -i nix nss-cacert -j `nproc`

# find the user-environment that just got created
USER_ENV=`find ${NIX_NEW_HOME}/store/ -name "*-user-environment"`

ln -s ${USER_ENV} ${NIX_NEW_HOME}/var/nix/profiles/default-1-link
ln -s ${NIX_NEW_HOME}/var/nix/profiles/default-1-link ${NIX_NEW_HOME}/var/nix/profiles/default

# package the whole thing
tar -czf /target/mynix.tgz --owner=${NIX_NEW_UID:-0} --group=${NIX_NEW_GID:-0} ${NIX_NEW_HOME}
