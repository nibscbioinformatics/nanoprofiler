def MODULE = "rename"
params.publish_dir = MODULE
params.publish_results = "default"

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'


process RENAME {
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


    //container "docker.pkg.github.com/nibscbioinformatics/$MODULE"
    // need to use biocontainers because of problem with github registry
    // requesting o-auth
    container "ghcr.io/nibscbioinformatics/biopython:v1.78" // TODO -> change with appropriate biocontainer
    // alternatively, now we can choose "nibscbioinformatics/modules:software-version" which is built
    // automatically from the containers definitions

    conda (params.conda ? "${baseDir}/containers/biopython/environment.yml" : null)


  input:
  tuple val(meta), path(reads)

  // configuration parameters are accessible via
  // params.modules['modulename'].name
  // where "name" is the name of parameter, and defined in nextflow.config
  val options

  output:
  tuple val(meta), path("*.fastq.gz"), emit: renamed

  script:
  if (params.single_end) {
      """
      python ${moduleDir}/makeshortheaders.py reads[0] ${meta.sampleID}_renamed.fastq.gz
      """
  } else {
      """
      python ${moduleDir}/makeshortheaders.py reads[0] ${meta.sampleID}_R1_renamed.fastq.gz
      python ${moduleDir}/makeshortheaders.py reads[1] ${meta.sampleID}_R2_renamed.fastq.gz
      """
  }
}
