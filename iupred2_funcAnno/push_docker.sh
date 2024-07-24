gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/iupred2a_anno:latest
docker push us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/iupred2a_anno:latest
