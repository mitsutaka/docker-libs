FROM jenkins/jenkins:2.157
LABEL maintainer="Mitz Amano <mitz@linux.com>"
USER root
RUN apt-get update && apt-get install -y libvirt0 && apt-get clean all
USER jenkins
