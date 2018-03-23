#!/bin/bash

BIN=$1

mkdir -p ${BIN}

curl -s http://packages.seqan.de/mason2/mason2-2.0.5-Linux-x86_64.tar.xz | tar -Jx -C ${BIN} --strip-components 2
curl -s http://packages.seqan.de/rabema/rabema-1.2.9-Linux-x86_64.tar.xz | tar -Jx -C ${BIN} --strip-components 2
curl -s http://packages.seqan.de/sak/sak-0.4.4-Linux-x86_64.tar.xz | tar -Jx -C ${BIN} --strip-components 2

curl -s http://packages.seqan.de/yara/yara-0.9.9-Linux-x86_64_sse4.tar.xz | tar -Jx -C ${BIN} --strip-components 2
curl -s http://packages.seqan.de/razers3/razers3-3.5.7-Linux-x86_64_sse4.tar.xz | tar -Jx -C ${BIN} --strip-components 2
