version 1.0

workflow call_tmhmm_anno {
    input {
        #Required 
        File AAfasta

        #Optional
        String docker   = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/deeptmhmm_anno:latest"
        Int cpu         = 1
        Int memory_gb   = 16
    }

    call tmhmm {
        input:
            AAfasta             = AAfasta,
            docker              = docker,
            cpu                 = cpu,
            memory_gb           = memory_gb
    }
    output {
        File tmhmmOut = tmhmm.tmhmmTMR
    }
}

task tmhmm {
    meta {
        description: "Given a AA FASTA file, runs DeepTMHMM to generate annotation"
    }
    # ------------------------------------------------
    input {
        #Required 
        File AAfasta

        String docker
        Int cpu
        Int diskSizeGB = 16
        String memory_gb
    }
    command <<<
	set -euxo pipefail
	biolib run DTU/DeepTMHMM --fasta ~{AAfasta}
	echo "All done!"

	>>>

    # ------------------------------------------------
    # Outputs:
    output {
        File tmhmmTMR = "./biolib_results/TMRs.gff3"

    }
    # ------------------------------------------------
    # Runtime settings:
    runtime {
        cpu         : cpu
        docker      : docker
        memory	    : memory_gb + "GB"
        disks       : "local-disk ~{diskSizeGB} SSD"

    }
}
