version 1.0
import "pfam_funcAnno/wdl/pfam_anno.wdl" as pfam
import "cpc2_funcAnno/wdl/cpc2_anno.wdl" as cpc2
import "DeepTMHMM_funcAnno/wdl/DeepTMHMM_anno.wdl" as tmhmm
import "iupred2_funcAnno/wdl/iupred2_anno.wdl" as iupred

workflow funcAnno_main {
  input {
    File? inputAAfasta
    File? inputNTfasta
  }

  if (defined(inputAAfasta)) {
    File inputAAfastaDefined = select_first([inputAAfasta])
    call pfam.pfam { 
      input:
        AAfasta = inputAAfastaDefined
      }
    call tmhmm.tmhmm {
      input:
        AAfasta = inputAAfastaDefined
    }
    call iupred.iupred2a {
      input:
        AAfasta = inputAAfastaDefined
    }
  }
  if (defined(inputNTfasta)) {
    File inputNTfastaDefined = select_first([inputNTfasta])
    call cpc2.cpc2 {
      input:
        ntfasta = inputNTfastaDefined
    }
  }
}
