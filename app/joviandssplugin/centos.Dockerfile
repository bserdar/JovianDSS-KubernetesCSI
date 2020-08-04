FROM centos:latest
LABEL maintainers="Andrei Perapiolkin, Burak Serdar"
LABEL description="JovianDSS CSI Plugin"

RUN yum -y install ca-certificates util-linux iproute
RUN mkdir -p /var/lib/kubelet/plugins_registry/joviandss-csi-driver/
COPY ./_output/jdss-csi-plugin /jdss-csi-plugin
RUN mkdir /host
ADD iscsiadm /sbin
RUN chmod 777 /sbin/iscsiadm
ENTRYPOINT ["/jdss-csi-plugin"]
