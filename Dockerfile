ARG BUILDER_IMAGE="debian"
ARG RUNNER_IMAGE="i386/ubuntu"

FROM ${BUILDER_IMAGE} as builder

RUN apt update && apt -y install unzip wget nano nfs-common

WORKDIR /dfsv

# previously install.sh
ARG BASE="/dfsv/servers/base"
run mkdir ./{maps,data} -p ${BASE}/baseq3 temp

RUN wget http://212.24.100.183/downloads/dfsv.tar.gz && \
    tar -xvzf dfsv.tar.gz && \
    mv dfsv/*dat ${BASE}/ && \
    mv dfsv/baseq3/* ${BASE}/baseq3 && \
    rm dfsv.tar.gz && \
    rm -rf dfsv/

RUN wget http://212.24.100.183/downloads/oDFe.ded && \
    mv oDFe.ded ${BASE}/

RUN wget --no-check-certificate $(wget --spider -r --no-parent --no-check-certificate https://q3defrag.org/files/defrag/ 2>&1 | grep -E "\-\-2" | grep "defrag_" | grep -v "beta" | cut -d' ' -f4 | sort | tail -n1) && \
    unzip -o defrag*.zip && \
    mkdir ${BASE}/defrag/ && \
    mv defrag/zz-* ${BASE}/defrag/ && \
    rm -f defrag*.zip

RUN wget http://212.24.100.183/downloads/rs.tar.gz && \
    tar -xvzf rs.tar.gz && \
    mv defrag/modules ${BASE}/defrag/ && \
    mv defrag/qagame* ${BASE}/defrag/qagamei386.so && \
    rm rs.tar.gz

COPY ./dlmap.sh .

# get default maps
RUN ./dlmap.sh st1 && \
    ./dlmap.sh amt-freestyle6 && \
    ./dlmap.sh ojdf-sa

FROM ${RUNNER_IMAGE} as runner

# launch.sh
RUN dpkg --add-architecture i386

RUN apt-get update && \
    apt-get install -y wget mysql-common:i386 libicu60:i386 unionfs-fuse

RUN wget http://security.ubuntu.com/ubuntu/pool/main/m/mysql-5.7/libmysqlclient20_5.7.21-1ubuntu1_i386.deb && \
    dpkg -i libmysqlclient20_5.7.21-1ubuntu1_i386.deb && \
    rm libmysqlclient20_5.7.21-1ubuntu1_i386.deb

RUN wget http://security.ubuntu.com/ubuntu/pool/main/libx/libxml2/libxml2_2.9.4+dfsg1-6.1ubuntu1.6_i386.deb && \
    dpkg -i libxml2_2.9.4+dfsg1-6.1ubuntu1.6_i386.deb && \
    rm libxml2_2.9.4+dfsg1-6.1ubuntu1.6_i386.deb

RUN apt-get install -y

RUN apt-get install -y --fix-missing

RUN apt-get install -y nfs-common

COPY --from=builder /dfsv /dfsv


RUN mkdir -p /dfsv/servers/base/defrag/dfsv
RUN mkdir -p /dfsv/nfs/maps

WORKDIR /dfsv

COPY . .

ENTRYPOINT ./start.sh
