FROM ubuntu:18.04

LABEL maintainer="Julio Gutierrez"
ARG NORDVPN_VERSION=3.9.5-1

HEALTHCHECK --start-period=30s --interval=30s \
	CMD if test "$( curl -m 25 -s https://api.nordvpn.com/v1/helpers/ips/insights | jq -r '.["protected"]' )" != "true" ; then exit 1; fi

RUN apt-get update -y && \
    apt-get install -y curl jq iputils-ping && \
    curl https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb --output /tmp/nordrepo.deb && \
    apt-get install -y /tmp/nordrepo.deb && \
    apt-get update -y && \
    apt-get install -y nordvpn${NORDVPN_VERSION:+=$NORDVPN_VERSION} && \
    apt-get remove -y nordvpn-release && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf \
		/tmp/* \
		/var/cache/apt/archives/* \
		/var/lib/apt/lists/* \
		/var/tmp/* && \
    echo '#!/bin/bash\nservice nordvpn start\nsleep 1\nnordvpn countries' > /usr/bin/countries && \
    echo '#!/bin/bash\nservice nordvpn start\nsleep 1\nnordvpn cities $1' > /usr/bin/cities && \
    echo '#!/bin/bash\nservice nordvpn start\nsleep 1\nnordvpn groups' > /usr/bin/n_groups && \
    chmod +x /usr/bin/countries && \
    chmod +x /usr/bin/cities && \
    chmod +x /usr/bin/n_groups

CMD /usr/bin/start_vpn.sh
COPY start_vpn.sh /usr/bin
