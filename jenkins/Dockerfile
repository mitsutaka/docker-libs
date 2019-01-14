FROM jenkins/jenkins:2.157
LABEL maintainer="Mitz Amano <mitsutaka.amano@gmail.com>"
USER root
RUN apt-get update && apt-get install -y libvirt0 && apt-get clean all
USER jenkins
