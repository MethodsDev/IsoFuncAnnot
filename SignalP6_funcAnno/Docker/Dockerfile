FROM condaforge/mambaforge:latest
LABEL authors="akhorgad"

RUN apt-get update

#install dependencies
RUN apt-get install build-essential -y
RUN apt-get install -y curl

# install gsutil
RUN curl https://sdk.cloud.google.com | bash
ENV PATH=/root/google-cloud-sdk/bin:$PATH

# copy downloaded version of SignalP
RUN gsutil -m cp gs://mdl-vignettes/functional_annotations/signalp-6.0h.fast.tar.gz .

#install SignalP
RUN gzip -dc signalp-6.0h.fast.tar.gz | tar xf -

RUN pip install numpy==1.26.4
RUN pip install ./signalp6_fast/signalp-6-package

RUN cp  /signalp6_fast/signalp-6-package/models/distilled_model_signalp6.pt /opt/conda/lib/python3.10/site-packages/signalp/model_weights/
