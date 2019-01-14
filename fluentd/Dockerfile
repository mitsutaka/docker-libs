FROM fluent/fluentd:v1.3.2
LABEL maintainer="Mitz Amano <mitsutaka.amano@gmail.com>"
RUN ["fluent-gem", "install", "fluent-plugin-elasticsearch"]
COPY fluentd/fluent.conf /fluentd/etc/fluent.conf
