FROM fluent/fluentd
MAINTAINER mitz@linux.com
RUN ["fluent-gem", "install", "fluent-plugin-elasticsearch"]
COPY fluentd/fluent.conf /fluentd/etc/fluent.conf
