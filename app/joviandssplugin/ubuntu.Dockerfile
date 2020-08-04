FROM ubuntu:18.04
LABEL maintainers="Andrei Perepiolkin, Burak Serdar"
LABEL description="JovianDSS CSI Plugin"

COPY ./_output/jdss-csi-plugin /jdss-csi-plugin
RUN mkdir /host
ADD iscsiadm /sbin
RUN chmod 777 /sbin/iscsiadm
ENTRYPOINT ["/jdss-csi-plugin"]
