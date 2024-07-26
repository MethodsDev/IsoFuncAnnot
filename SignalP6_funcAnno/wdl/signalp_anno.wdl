version 1.0

workflow call_signalp_anno {
    input {
        #Required 
        File AAfasta
        #Optional
        String docker   = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/signalp6_anno:latest"
        Int cpu         = 1
        Int memory_gb   = 16
    }

    call signalp6 {
        input:
            AAfasta     = AAfasta,
            docker      = docker,
            cpu         = cpu,
            memory_gb   = memory_gb
    }
    output {
        File signalPOut = signalp6.signalpOut
            }
}

task signalp6 {
    meta {
        description: "Given a AA FASTA file, runs SignalP-6.0h Fast mode to generate annotation"
    }
    # ------------------------------------------------
    input {
        #Required 
        File AAfasta

        String docker
        Int cpu
        Int diskSizeGB = 32
        Int memory_gb
    }

    command <<<
        set -euxo pipefail
        
        echo "checking tool path"
        which signalp6
        
        echo "display signalp6 options"
        signalp6 -h

        signalp6 -ff ~{AAfasta} -od ./signalp_out
        echo "All done!"
        >>>

    # ------------------------------------------------
    # Outputs:
    output {
        File signalpOut =  "./signalp_out/prediction_results.txt"

    }
    # ------------------------------------------------
    # Runtime settings:
    runtime {
        cpu         : cpu
        docker      : docker
        memory      : memory_gb + "GB"
        disks       : "local-disk ~{diskSizeGB} SSD"

    }
}
