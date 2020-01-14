FROM nixos/nix
LABEL maintainer="Nathan Perry <np@nathanperry.dev>"

ADD run.sh /run.sh

VOLUME ["/target"]
ENTRYPOINT [ "/run.sh" ]
