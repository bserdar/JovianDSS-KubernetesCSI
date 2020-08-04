FROM centos:latest
LABEL maintainers="Andrei Perapiolkin, Burak Serdar"
LABEL description="JovianDSS CSI Plugin"

RUN yum -y install ca-certificates util-linux iproute
COPY ./_output/jdss-csi-plugin /jdss-csi-plugin
COPY ./_output/jdss-csi-plugin /jdss-csi-plugin
RUN mkdir /host
ADD iscsiadm /sbin
RUN chmod 777 /sbin/iscsiadm
ENTRYPOINT ["/jdss-csi-plugin"]
