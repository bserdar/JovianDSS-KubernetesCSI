FROM ubuntu:16.04
LABEL maintainers="Andrei Perepiolkin, Burak Serdar"
LABEL description="JovianDSS CSI Plugin"

RUN mkdir /host
COPY ./_output/jdss-csi-plugin /jdss-csi-plugin
ADD iscsiadm /sbin
RUN chmod 777 /sbin/iscsiadm
ENTRYPOINT ["/jdss-csi-plugin"]
