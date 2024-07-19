version 1.0

workflow call_pfam_anno {
    input {
        #Required 
        File AAfasta

        #Optional
        String? outfname
        String? pfamArgs
        String docker   = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/pfam_anno:latest"
        Int cpu         = 4
        String memory   = "40G"
    }

    call pfam {
        input:
            AAfasta             = AAfasta,
            outfname            = outfname,
            pfamArgs            = pfamArgs,
            docker              = docker,
            cpu                 = cpu,
            memory              = memory
    }
    output {
        File pfamOut = pfam.pfamAnnoTxt
    }
}

task pfam {
    meta {
        description: "Given a amino acid FASTA file, generates pfam annotations.txt"
    }
    # ------------------------------------------------
    input {
        #Required 
        File AAfasta

        String outfname = "Pfam_out.txt"
        String pfamArgs = "-as -e_seq 10.0 -e_dom 10.0"

        String docker
        Int cpu
        Int diskSizeGB = 16
        String memory
    }

    command <<<
        set -euxo pipefail
        echo "check for pfam installation"
        pfam_scan.pl -h

        echo "checking .dat files at path"
        ls -lh /pfamdb

        pfam_scan.pl -dir /pfamdb -fasta ~{AAfasta} -cpu ~{cpu} ~{pfamArgs} > ~{outfname}
        echo "All done!"
        >>>

    # ------------------------------------------------
    # Outputs:
    output {
        File pfamAnnoTxt = "~{outfname}"

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
