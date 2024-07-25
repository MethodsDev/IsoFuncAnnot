workflow funcAnno_main {
  input {
    File? inputAAfasta
    File? inputNTfasta
  }


if (defined(inputAAfastaDefined)) {
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
if (defined(inputNTfastaDefined)) {
  File inputNTfastaDefined = select_first([inputNTfasta])
  call cpc2.cpc2 {
   input:
       ntfasta = inputNTfastaDefined
  }
}
}
