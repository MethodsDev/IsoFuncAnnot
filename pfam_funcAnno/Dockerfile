FROM condaforge/mambaforge:latest
LABEL authors="akhorgad"

RUN apt-get update --allow-releaseinfo-change
RUN apt-get update -m

#install pfam_scan
RUN conda install bioconda::pfam_scan

#install pfam data files
RUN wget --quiet http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.dat.gz
RUN wget --quiet http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz
RUN wget --quiet https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/active_site.dat.gz

RUN mkdir -p pfamdb
RUN gunzip -c Pfam-A.hmm.dat.gz > pfamdb/Pfam-A.hmm.dat
RUN gunzip -c Pfam-A.hmm.gz > pfamdb/Pfam-A.hmm
RUN gunzip -c active_site.dat.gz > pfamdb/active_site.dat
RUN hmmpress pfamdb/Pfam-A.hmm

RUN rm Pfam-A.hmm.gz Pfam-A.hmm.dat.gz active_site.dat.gz
