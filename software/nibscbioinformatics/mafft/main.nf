def MODULE = "mafft"
params.publish_dir = MODULE
params.publish_results = "default"

// ### --> NB: this process has been adapted for local execution into the nanoprofiler pipeline
// the inputs have been customised for this particular use

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

process MAFFT {
    // each module must define a process label to declare a category of
    // resource requirements
    label 'process_high'
    label 'process_long'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
          saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:individualID)
        }

    container "quay.io/biocontainers/mafft:7.471--h516909a_0"

    conda (params.conda ? "${moduleDir}/environment.yml" : null)


  input:
  tuple val(sampleID), val(individualID), val(immunisation), val(boost), path(fasta)
  val options

  output:
  path "${individualID}_${immunisation}_mafft.fasta", emit: fasta
  path "*.tree", emit: tree
  path "*.version.txt", emit: version

  script:
  allFasta = fasta.collect{"${it}"}.join(' ')

  """
  cat ${allFasta} >${individualID}_${immunisation}_collated.fasta

  mafft \
  --thread ${task.cpus} \
  ${options.args} \
  ${individualID}_${immunisation}_collated.fasta \
  > ${individualID}_${immunisation}_mafft.fasta

  mafft --version >mafft.version.txt
  """
}
