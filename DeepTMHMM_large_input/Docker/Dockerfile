# Extend the existing DeepTMHMM annotation Docker image
FROM us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/deeptmhmm_anno:latest

# Install additional dependencies for FASTA processing
RUN pip install biopython

# Verify installations
RUN python3 -c "import Bio; print('BioPython version:', Bio.__version__)"

# Set working directory
WORKDIR /app

# Default command
CMD ["/bin/bash"]
