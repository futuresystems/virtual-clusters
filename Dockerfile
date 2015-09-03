
FROM phusion/baseimage

RUN rm -f /etc/service/sshd/down
ADD key.pub /root/.ssh/authorized_keys
RUN chmod 0600 /root/.ssh/authorized_keys
