FROM debian:stable-slim
RUN DEBIAN_FRONTEND=noninteractiv apt-get update
RUN DEBIAN_FRONTEND=noninteractiv apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractiv apt-get install ca-certificates apt-transport-https -y
RUN DEBIAN_FRONTEND=noninteractiv apt-get install -y --no-install-recommends wget lsb-release gnupg
RUN DEBIAN_FRONTEND=noninteractiv wget -q -O - https://packages.norbert-ruehl.de/conf/apt.gpg.key | apt-key add -
RUN DEBIAN_FRONTEND=noninteractiv apt-key fingerprint A455A434
RUN DEBIAN_FRONTEND=noninteractiv sh -c 'echo deb https://packages.norbert-ruehl.de/debian $(lsb_release -cs) main gcc-10 > /etc/apt/sources.list.d/packages.norbert-ruehl.de.list'
RUN DEBIAN_FRONTEND=noninteractiv apt-get update
RUN DEBIAN_FRONTEND=noninteractiv apt-get install -y --no-install-recommends cmake gcc-10
RUN DEBIAN_FRONTEND=noninteractiv apt-get clean