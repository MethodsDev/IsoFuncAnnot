version 1.0

workflow call_iupred2a_anno {
    input {
        #Required 
        File AAfasta
        #Optional
        String? mode
        String? outfname
        String docker   = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/iupred2a_anno:latest"
        Int cpu         = 1
        Int memory_gb   = 16
    }

    call iupred2a {
        input:
            AAfasta     = AAfasta,
            mode        = mode,
            outfname    = outfname,
            docker      = docker,
            cpu         = cpu,
            memory_gb   = memory_gb
    }
    output {
        File iupredOut = iupred2a.iupredOut
            }
}

task iupred2a {
    meta {
        description: "Given a AA FASTA file, runs DeepTMHMM to generate annotation"
    }
    # ------------------------------------------------
    input {
        #Required 
        File AAfasta
        String outfname = "iupred2a_out.txt"
        String mode = "long"

        String docker
        Int cpu
        Int diskSizeGB = 16
        Int memory_gb
    }

    command <<<
        set -euxo pipefail

        echo "checking tool path"
        python /iupred2a/iupred2a.py -h

        echo "checking path and dependecies for multi-fatsta util"
        python /IsoFuncAnnot/iupred2_funcAnno/iupred_fasta_split.py -h
	
        python /IsoFuncAnnot/iupred2_funcAnno/iupred_fasta_split.py -i ~{AAfasta} -o ~{outfname} -m ~{mode}

	echo "All done!"
        >>>

    # ------------------------------------------------
    # Outputs:
    output {
        File iupredOut = "~{outfname}"
        File errlogs   = "./logfile.txt"

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
