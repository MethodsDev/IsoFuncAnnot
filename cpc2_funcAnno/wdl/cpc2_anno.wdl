version 1.0

workflow call_cpc2_anno {
    input {
        #Required 
        File ntfasta

        #Optional
        String? outfname
        String? cpc2Args
        String docker   = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/cpc2_anno:latest"
        Int cpu         = 1
        Int memory_gb   = 16
    }

    call cpc2 {
        input:
            ntfasta             = ntfasta,
            outfname            = outfname,
            cpc2Args            = cpc2Args,
            docker              = docker,
            cpu                 = cpu,
            memory_gb           = memory_gb
    }
    output {
        File cpc2Out = cpc2.cpc2AnnoTxt
    }
}

task cpc2 {
    meta {
        description: "Given a nucleotide FASTA file, generates cpc2 v1.0.1 annotations.txt"
    }
    # ------------------------------------------------
    input {
        #Required 
        File ntfasta

        String outfname = "cpc2output.txt"
        String cpc2Args = "--ORF"

        String docker
        Int cpu
        Int diskSizeGB = 16
        String memory_gb
    }

    command <<<
        set -euxo pipefail
        echo "check for cpc2 installation"
        python /CPC2_standalone-1.0.1/bin/CPC2.py -h

        python /CPC2_standalone-1.0.1/bin/CPC2.py ~{cpc2Args} -i ~{ntfasta}  -o ./~{outfname}
        echo "All done!"
        >>>

    # ------------------------------------------------
    # Outputs:
    output {
        File cpc2AnnoTxt = "~{outfname}"

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
