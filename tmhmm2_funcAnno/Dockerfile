FROM ubuntu:20.04
RUN apt-get update && apt-get install -y perl
COPY tmhmm-2.0c.Linux.tar.gz /opt/
WORKDIR /opt
RUN tar xzf tmhmm-2.0c.Linux.tar.gz
# Adjust shebangs if needed
RUN sed -i "1s|.*|#!/usr/bin/perl|" tmhmm-2.0c/bin/tmhmm \
    && sed -i "1s|.*|#!/usr/bin/perl|" tmhmm-2.0c/bin/tmhmmformat.pl
ENV PATH="/opt/tmhmm-2.0c/bin:$PATH"
