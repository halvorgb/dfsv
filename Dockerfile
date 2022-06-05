FROM alpine

# vim and bash for when executing into the container
# gcompat is required to run oDFe.ded.x64 on alpine
RUN apk add --update --no-cache \
    vim \
    unzip \
    bash \
    gcompat

# something like this for NFS, will probably us a fly.io volume instead of doing this
# RUN apk add --update --no-cache nfs-utils openrc
# RUN rc-update add nfsmount
# RUN rc-service nfsmount start

# NFS_SERVER=nfs-server.hiroom2.com
# NFS_DIR=/srv/nfsshare
# sudo mount -t nfs ${NFS_SERVER}:${NFS_DIR} /mnt

WORKDIR /dfsv

ARG BASE="/dfsv/servers/base"

RUN mkdir -p \
    ${BASE}/baseq3 \
    ${BASE}/defrag/dfsv

RUN wget http://212.24.100.183/downloads/dfsv.tar.gz && \
    tar -xvzf dfsv.tar.gz && \
    mv dfsv/*dat ${BASE}/ && \
    mv dfsv/baseq3/* ${BASE}/baseq3 && \
    rm dfsv.tar.gz && \
    rm -rf dfsv/


RUN wget https://github.com/JBustos22/oDFe/releases/download/latest/oDFe-linux-x86_64.zip && \
    unzip -d odfe oDFe-linux-x86_64.zip && \
    mv odfe/oDFe.ded.x64 ${BASE}/ && \
    chmod +x /dfsv/servers/base/oDFe.ded.x64 && \
    rm oDFe-linux-x86_64.zip && \
    rm -rf odfe/

# need newer version of wget for these recursive shennanigans
RUN apk add --update --no-cache wget
RUN wget --no-check-certificate $(wget --spider -r --no-parent --no-check-certificate https://q3defrag.org/files/defrag/ 2>&1 | grep -E "\-\-2" | grep "defrag_" | grep -v "beta" | cut -d' ' -f4 | sort | tail -n1) && \
    unzip -o defrag*.zip && \
    mv defrag/zz-* ${BASE}/defrag/ && \
    rm -f defrag*.zip && \
    rm -rf defrag/ && \
    rm -rf q3defrag.org/

COPY cfgs cfgs
COPY dlmap.sh start.sh .

COPY defaultmaps/* ${BASE}/baseq3
# get default maps
# RUN ./dlmap.sh st1 && \
#    ./dlmap.sh amt-freestyle6 && \
#    ./dlmap.sh ojdf-sa

ENTRYPOINT ./start.sh
