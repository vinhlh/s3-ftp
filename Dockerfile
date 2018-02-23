FROM ubuntu:16.04

MAINTAINER Vinh Le <vinh.le@zalora.com>

ENV SECRETS_BUCKET_NAME oms-services.secrets
ENV APP_NAME s3-ftp
ENV S3FS_VERSION 1.83
ENV FTP_USER awesome

RUN apt-get update

# Install aws cli
RUN apt-get -y install python-pip
RUN pip install awscli

# Step s3fs
RUN apt-get install -y curl tar
RUN apt-get install -y automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config

RUN curl -L https://github.com/s3fs-fuse/s3fs-fuse/archive/v${S3FS_VERSION}.tar.gz | tar zxv -C /usr/src
RUN cd /usr/src/s3fs-fuse-${S3FS_VERSION} && ./autogen.sh && ./configure --prefix=/usr && make && make install

# Setup vsftpd
RUN apt-get install -y vsftpd
RUN mkdir /etc/vsftpd

COPY vsftpd.conf /etc/
COPY vsftpd.virtual /etc/pam.d/

RUN apt-get install -y db-util vim
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY secrets-entrypoint.sh /secrets-entrypoint.sh
RUN chmod +x /secrets-entrypoint.sh
RUN useradd --home /home/vsftpd --gid nogroup --uid 1000 -m --shell /bin/false vsftpd

RUN mkdir -p "/home/vsftpd/$FTP_USER" /var/run/vsftpd/empty /etc/vsftpd/user_conf
RUN chown -R 755 "/home/vsftpd/$FTP_USER"
RUN chown -R vsftpd:nogroup /home/vsftpd

# For fixing https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=754762;msg=9
COPY init.d/vsftpd /etc/init.d/
RUN chmod +x /etc/init.d/vsftpd

EXPOSE 21
EXPOSE 40000-40400

ENTRYPOINT ["/secrets-entrypoint.sh"]
CMD ["vsftpd"]
