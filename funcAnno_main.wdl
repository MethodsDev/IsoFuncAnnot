version 1.0

import "pfam_funcAnno/wdl/pfam_anno.wdl" as pfam
import "cpc2_funcAnno/wdl/cpc2_anno.wdl" as cpc2
import "DeepTMHMM_funcAnno/wdl/DeepTMHMM_anno.wdl" as tmhmm
import "iupred2_funcAnno/wdl/iupred2_anno.wdl" as iupred

workflow funcAnno_main {
  input {
    File? inputAAfasta
    File? inputNTfasta
    Int cpu = 2
    Int memory_gb = 32
  }

  if (defined(inputAAfasta)) {
    File inputAAfastaDefined = select_first([inputAAfasta])
    call pfam.pfam { 
      input:
        AAfasta     = inputAAfastaDefined
        cpu         = cpu
        memory_gb   = memory_gb
      }
    call tmhmm.tmhmm {
      input:
        AAfasta     = inputAAfastaDefined
        cpu         = cpu
        memory_gb   = memory_gb
    }
    call iupred.iupred2a {
      input:
        AAfasta     = inputAAfastaDefined
        cpu         = cpu
        memory_gb   = memory_gb
    }
  }
  if (defined(inputNTfasta)) {
    File inputNTfastaDefined = select_first([inputNTfasta])
    call cpc2.cpc2 {
      input:
        ntfasta     = inputNTfastaDefined
        cpu         = cpu
        memory_gb   = memory_gb
    }
  }
}
