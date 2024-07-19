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
        String memory   = 16
    }

    call pfam {
        input:
            ntfasta             = ntfasta,
            outfname            = outfname,
            cpc2Args            = cpc2Args,
            docker              = docker,
            cpu                 = cpu,
            memory              = memory
    }
    output {
        File cpc2Out = cpc2.cpc2AnnoTxt
    }
}

task pfam {
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
        String memory
    }

    command <<<
        set -euxo pipefail
        echo "check for cpc2 installation"
        python ./CPC2_standalone-1.0.1/bin/CPC2.py -h

        python ./CPC2_standalone-1.0.1/bin/CPC2.py ~{cpc2Args} -i ~{ntfasta}  -o ~{outfname}
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
        memory      : memory
        disks       : "local-disk ~{diskSizeGB} SSD"

    }
}
