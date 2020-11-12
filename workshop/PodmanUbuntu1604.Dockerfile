# *************************************
#   DOESN'T WORK
#   See this entry: https://github.com/containers/podman/issues/8275
# *************************************
FROM ubuntu:16.04

RUN apt-get update -qq \
    && apt-get install apt-utils -qq -y \
    && apt-get install -qq -y software-properties-common uidmap \
    && add-apt-repository -y ppa:projectatomic/ppa \
    && apt-get update -qq \
    && apt-get -qq -y install podman \
    && apt-get update -qq \
    && apt-get -qq -y install nano  

# RUN adduser --disabled-login --gecos user user
# USER user

# ENTRYPOINT ["podman", "--storage-driver=vfs"]
# CMD ["info"]

# To keep it running
# CMD tail -f /dev/null

# docker run --rm --privileged "tsuedbroecker/cns-workshop-tools:v5" run --rm "docker.io/library/tsuedbroecker/cns-workshop-tools:v5"