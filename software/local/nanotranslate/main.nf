          def MODULE = "nanotranslate"
params.publish_dir = MODULE
params.publish_results = "default"

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

process NANOTRANSLATE {
    // each module must define a process label to declare a category of
    // resource requirements
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        // TODO nf-core: If a meta map of sample information is NOT provided in "input:" section
        //               change "publish_id:meta.id" to initialise an empty string e.g. "publish_id:''".
        saveAs: { filename ->
          saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.sampleID)
        }


    container "ghcr.io/nibscbioinformatics/biopython:v1.78"

    conda (params.conda ? "${moduleDir}/environment.yml" : null)


  input:
  // --> meta is a Groovy MAP containing any number of information (metadata) per sample
  // or analysis unit, corresponding to each of "reads"
  // it is accessible via meta.name where ".name" is the name of the metadata
  // these MUST be described in the meta.yml when the metatada are expected by the process
  tuple val(meta), path(mergedfq)
  val options

  output:
  tuple val(meta), path("*.fasta"), emit: fasta
  tuple val(meta), path("*.log"), emit: log

  script:
  """
  gzip -cd ${mergedfq} >sequences.fastq
  python ${moduleDir}/translate.py \
  sequences.fastq \
  ${meta.sampleID}_AA_translated.fasta \
  >${meta.sampleID}_AA_translated.log
  """
}
