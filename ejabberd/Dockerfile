FROM ubuntu:14.04
MAINTAINER "Mitz Amano <mitz@linux.com>"

ENV EJABBERD_VER 15.11

USER root
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y wget
RUN echo "deb http://packages.erlang-solutions.com/ubuntu trusty contrib" >> /etc/apt/sources.list && \
    wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && \
    apt-key add erlang_solutions.asc && \
    rm -f erlang_solutions.asc

RUN apt-get update && \
    apt-get install -y build-essential git autoconf esl-erlang=1:17.5.3 libssl-dev libmysqlclient-dev libyaml-dev libexpat1-dev mysql-client libyaml-0-2

#RUN wget https://www.process-one.net/downloads/ejabberd/$EJABBERD_VER/ejabberd_$EJABBERD_VER-0_amd64.deb && \
#    dpkg -i ejabberd_$EJABBERD_VER-0_amd64.deb && rm -f ejabberd_$EJABBERD_VER-0_amd64.deb && \
#	apt-get install -f -y
RUN git clone https://github.com/processone/ejabberd.git ~/ejabberd && \
    cd ~/ejabberd && git checkout -b $EJABBERD_VER tags/$EJABBERD_VER && \
    ./autogen.sh && ./configure --enable-mysql && make && make install

RUN apt-get purge -y build-essential git autoconf wget libssl-dev libmysqlclient-dev libyaml-dev libexpat1-dev && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf ~/ejabberd

#RUN ln -s /opt/ejabberd-$EJABBERD_VER /opt/ejabberd
COPY conf/ejabberd.yml.tmpl /etc/ejabberd/
#COPY conf/messagedb.sql /etc/ejabberd/
COPY entrypoint.sh /sbin
RUN chown root.root /sbin/entrypoint.sh && chmod 700 /sbin/entrypoint.sh

EXPOSE 4560/tcp 5222/tcp 5269/tcp 5280/tcp

ENTRYPOINT ["entrypoint.sh"]
