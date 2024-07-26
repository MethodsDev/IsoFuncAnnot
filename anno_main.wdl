version 1.0

import "pfam_funcAnno/wdl/pfam_anno.wdl" as pfam
import "cpc2_funcAnno/wdl/cpc2_anno.wdl" as cpc2
import "DeepTMHMM_funcAnno/wdl/DeepTMHMM_anno.wdl" as tmhmm
import "iupred2_funcAnno/wdl/iupred2_anno.wdl" as iupred
import "SignalP6_funcAnno/wdl/signalp_anno.wdl" as signalp

workflow anno_main {
  input {
    File? inputAAfasta
    File? inputNTfasta
    Int cpu = 2
    Int memory_gb = 32
    String dockerPfam       = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/pfam_anno:latest"
    String dockerTmhmm      = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/deeptmhmm_anno:latest"
    String dockerCpc2       = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/cpc2_anno:latest"
    String dockerIuPred     = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/iupred2a_anno:latest"
    String dockerSignalP    = "us-east4-docker.pkg.dev/methods-dev-lab/func-annotations/signalp6_anno:latest"
  }

  if (defined(inputAAfasta)) {
    call pfam.pfam { 
      input:
        AAfasta     = inputAAfasta,
        docker      = dockerPfam, 
        cpu         = cpu,
        memory_gb   = memory_gb
      }
    call tmhmm.tmhmm {
      input:
        AAfasta     = inputAAfasta,
        docker      = dockerTmhmm, 
        cpu         = cpu,
        memory_gb   = memory_gb
    }
    call iupred.iupred2a {
      input:
        AAfasta     = inputAAfasta,
        docker      = dockerIuPred, 
        cpu         = cpu,
        memory_gb   = memory_gb
    }
    call signalp.signalp6 {
      input:
        AAfasta     = inputAAfasta,
        docker      = dockerSignalP,
        cpu         = cpu,
        memory_gb   = memory_gb
    }
  }
  if (defined(inputNTfasta)) {
    File inputNTfastaDefined = select_first([inputNTfasta])
    call cpc2.cpc2 {
      input:
        ntfasta     = inputNTfastaDefined,
        docker      = dockerCpc2, 
        cpu         = cpu,
        memory_gb   = memory_gb
    }
  }
}
