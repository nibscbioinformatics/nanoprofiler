def MODULE = "flash"
params.publish_dir = MODULE
params.publish_results = "default"

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'


process FLASH {
    // each module must define a process label to declare a category of
    // resource requirements
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
          saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.sampleID)
        }

    //container "ghcr.io/nibscbioinformatics/flash:1.2.11"
    container "quay.io/biocontainers/flash:1.2.11--hed695b0_5"

    conda (params.conda ? "${moduleDir}/environment.yml" : null)


  input:
  tuple val(meta), path(reads)
  val options

  output:
  tuple val(meta), path("${meta.sampleID}.extendedFrags.fastq.gz"), emit: reads
  path "*.version.txt", emit: version

  script:
  // flash is meant to merge reads, so this should only be used
  // when paired-end sequencing has bene done
  def flashopts  = initOptions(options)
  """
  flash \
  -t ${task.cpus} \
  --quiet \
  -o ${meta.sampleID} \
  -z ${flashopts.args} \
  ${reads[0]} ${reads[1]}

  flash -v | head -n 1 | cut -d" " -f 2 >flash.version.txt
  """


}
