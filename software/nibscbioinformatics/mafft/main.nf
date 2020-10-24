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
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
          saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.sampleID)
        }

    container "quay.io/biocontainers/mafft:7.471--h516909a_0"

    conda (params.conda ? "${moduleDir}/environment.yml" : null)


  input:
  tuple val(sampleID), val(immunisation), val(boost), path(fasta)
  val options

  output:
  path("${sampleID}_${immunisation}_mafft.fasta"), emit: fasta
  path("*.tree"), emit: tree
  path "*.version.txt", emit: version

  script:
  allFasta = fasta.collect{"${it}"}.join(' ')

  """
  cat ${allFasta} >${sampleID}_${immunisation}_collated.fasta

  mafft \
  ${options.args} \
  ${sampleID}_${immunisation}_collated.fasta \
  > ${sampleID}_${immunisation}_mafft.fasta

  mafft --version >mafft.version.txt
  """
}
