version 1.0

workflow call_tmhmm_anno_chunked {
    input {
        # Required 
        File AAfasta
        
        # Optional chunking parameter
        Int sequences_per_chunk = 100
        
        # Optional runtime parameters
        String docker = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/deeptmhmm_anno:latest"
        Int cpu = 1
        Int memory_gb = 16
        Int split_memory_gb = 4
        Int merge_memory_gb = 8
    }

    # Step 1: Split the large FASTA file into smaller chunks
    call split_fasta {
        input:
            input_fasta = AAfasta,
            sequences_per_chunk = sequences_per_chunk,
            docker = docker,
            memory_gb = split_memory_gb
    }
    
    # Step 2: Process each chunk in parallel using scatter
    scatter (chunk_file in split_fasta.fasta_chunks) {
        call tmhmm_chunk {
            input:
                AAfasta = chunk_file,
                docker = docker,
                cpu = cpu,
                memory_gb = memory_gb
        }
    }
    
    # Step 3: Merge all the results back together
    call merge_tmhmm_results {
        input:
            tmhmm_results = tmhmm_chunk.tmhmmTMR,
            docker = docker,
            memory_gb = merge_memory_gb
    }
    
    output {
        File tmhmmOut = merge_tmhmm_results.merged_tmhmm
        Array[File] chunk_results = tmhmm_chunk.tmhmmTMR
        Int total_chunks = length(tmhmm_chunk.tmhmmTMR)
    }
}

task split_fasta {
    meta {
        description: "Split a large FASTA file into smaller chunks for parallel processing"
    }
    
    input {
        File input_fasta
        Int sequences_per_chunk
        String docker
        Int memory_gb
        Int diskSizeGB = 32
    }
    
    command <<<
        set -euxo pipefail
        
        # Create output directory
        mkdir -p chunks
        
        # Split FASTA file into chunks
        python3 << 'EOF'
import os
from Bio import SeqIO
import math

def split_fasta(input_file, sequences_per_chunk):
    """Split FASTA file into chunks"""
    sequences = list(SeqIO.parse(input_file, "fasta"))
    total_sequences = len(sequences)
    
    if total_sequences == 0:
        raise ValueError("No sequences found in input file")
    
    num_chunks = math.ceil(total_sequences / sequences_per_chunk)
    
    print(f"Total sequences: {total_sequences}")
    print(f"Sequences per chunk: {sequences_per_chunk}")
    print(f"Number of chunks: {num_chunks}")
    
    chunk_files = []
    
    for i in range(num_chunks):
        start_idx = i * sequences_per_chunk
        end_idx = min((i + 1) * sequences_per_chunk, total_sequences)
        
        chunk_filename = f"chunks/chunk_{i+1:04d}.fasta"
        chunk_sequences = sequences[start_idx:end_idx]
        
        with open(chunk_filename, "w") as chunk_file:
            SeqIO.write(chunk_sequences, chunk_file, "fasta")
        
        chunk_files.append(chunk_filename)
        print(f"Created {chunk_filename} with {len(chunk_sequences)} sequences")
    
    # Write list of chunk files
    with open("chunk_list.txt", "w") as f:
        for chunk_file in chunk_files:
            f.write(f"{chunk_file}\n")
    
    return chunk_files

# Split the FASTA file
split_fasta("~{input_fasta}", ~{sequences_per_chunk})
EOF
        
        echo "FASTA splitting completed!"
        ls -la chunks/
    >>>
    
    output {
        Array[File] fasta_chunks = glob("chunks/*.fasta")
        File chunk_list = "chunk_list.txt"
    }
    
    runtime {
        cpu: 2
        docker: docker
        memory: memory_gb + "GB"
        disks: "local-disk ~{diskSizeGB} SSD"
    }
}

task tmhmm_chunk {
    meta {
        description: "Run DeepTMHMM on a single chunk of sequences"
    }
    
    input {
        File AAfasta
        String docker
        Int cpu
        Int memory_gb
        Int diskSizeGB = 16
    }
    
    command <<<
        set -euxo pipefail
        
        # Get the chunk filename for naming output
        chunk_name=$(basename ~{AAfasta} .fasta)
        
        echo "Processing chunk: ${chunk_name}"
        echo "Input file size: $(wc -c < ~{AAfasta}) bytes"
        echo "Number of sequences: $(grep -c '^>' ~{AAfasta})"
        
        # Run DeepTMHMM on the chunk
        biolib run DTU/DeepTMHMM --fasta ~{AAfasta}
        
        # Rename output file to include chunk identifier
        if [ -f "./biolib_results/TMRs.gff3" ]; then
            mv "./biolib_results/TMRs.gff3" "./TMRs_${chunk_name}.gff3"
            echo "Successfully processed chunk ${chunk_name}"
        else
            echo "Error: Expected output file not found for chunk ${chunk_name}"
            exit 1
        fi
    >>>
    
    output {
        File tmhmmTMR = glob("TMRs_*.gff3")[0]
    }
    
    runtime {
        cpu: cpu
        docker: docker
        memory: memory_gb + "GB"
        disks: "local-disk ~{diskSizeGB} SSD"
    }
}

task merge_tmhmm_results {
    meta {
        description: "Merge DeepTMHMM results from multiple chunks into a single file"
    }
    
    input {
        Array[File] tmhmm_results
        String docker
        Int memory_gb
        Int diskSizeGB = 32
    }
    
    command <<<
        set -euxo pipefail
        
        echo "Merging ~{length(tmhmm_results)} result files..."
        
        # Create merged output file
        output_file="merged_TMRs.gff3"
        
        # Initialize with GFF3 header if present in first file
        first_file="~{tmhmm_results[0]}"
        if [ -f "$first_file" ]; then
            # Copy header lines (starting with #) from first file
            grep '^#' "$first_file" > "$output_file" || true
        fi
        
        # Merge all result files (skip header lines for subsequent files)
        for result_file in ~{sep=' ' tmhmm_results}; do
            if [ -f "$result_file" ]; then
                echo "Processing: $result_file"
                # Add non-header lines
                grep -v '^#' "$result_file" >> "$output_file" || true
            else
                echo "Warning: File $result_file not found"
            fi
        done
        
        echo "Merge completed!"
        echo "Total lines in merged file: $(wc -l < $output_file)"
        
        # Validate the merged file
        if [ ! -s "$output_file" ]; then
            echo "Error: Merged file is empty"
            exit 1
        fi
    >>>
    
    output {
        File merged_tmhmm = "merged_TMRs.gff3"
    }
    
    runtime {
        cpu: 2
        docker: docker
        memory: memory_gb + "GB"
        disks: "local-disk ~{diskSizeGB} SSD"
    }
}
