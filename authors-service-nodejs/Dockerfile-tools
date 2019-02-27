FROM node:8-stretch


ENV PORT 3000
ENV NODE_HEAPDUMP_OPTIONS nosignal

EXPOSE 3000
EXPOSE 9229

WORKDIR "/app"

# Bundle app source
COPY . /app
COPY run-dev /bin
COPY run-debug /bin
RUN chmod 777 /bin/run-dev /bin/run-debug
RUN apt-get update
RUN apt-get install bc

CMD ["/bin/bash"]


ARG bx_dev_user=root
ARG bx_dev_userid=1000
RUN BX_DEV_USER=$bx_dev_user
RUN BX_DEV_USERID=$bx_dev_userid
RUN if [ "$bx_dev_user" != root ]; then useradd -ms /bin/bash -u $bx_dev_userid $bx_dev_user; fi