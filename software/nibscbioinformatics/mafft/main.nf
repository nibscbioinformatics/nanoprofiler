def MODULE = "mafft"
params.publish_dir = MODULE
params.publish_results = "default"

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
  // --> meta is a Groovy MAP containing any number of information (metadata) per sample
  // or analysis unit, corresponding to each of "reads"
  // it is accessible via meta.name where ".name" is the name of the metadata
  // these MUST be described in the meta.yml when the metatada are expected by the process
  tuple val(meta), path(fasta)

  val options

  output:
  tuple val(meta), path("${meta.sampleID}_mafft.fasta"), emit: fasta
  tuple val(meta), path("*.tree"), emit: tree
  path "*.version.txt", emit: version

  script:
  """
  mafft \
  ${options.args} \
  ${fasta} \
  > ${meta.sampleID}_mafft.fasta

  mafft --version >mafft.version.txt
  """
}
