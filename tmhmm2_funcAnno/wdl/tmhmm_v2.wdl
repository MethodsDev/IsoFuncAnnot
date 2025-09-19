version 1.0

workflow tmhmm_workflow {
  input {
    File input_AAfasta
  }

  call run_tmhmm {
    input:
      AAfasta = input_AAfasta
  }

  output {
    File tmhmm_output = run_tmhmm.result
  }
}

task run_tmhmm {
  input {
    File AAfasta
  }
  
  command <<<
    tmhmm --short < ~{AAfasta} > tmhmm_v2_output.txt
  >>>
  
  runtime {
    docker: "us-central1-docker.pkg.dev/methods-dev-lab/mdl-tmhmmv2/tmhmm:2.0"
    memory: "4G"
    cpu: 1
  }
  
  output {
    File result = "tmhmm_v2_output.txt"
  }
}
