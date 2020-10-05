params.publish_results = "default"

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

/// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided as a string i.e. "options.args"
//               where "options" is a Groovy Map that MUST be provided in the "input:" section of the process.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.


process CUTADAPT {

    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
          saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.sampleID)
        }


    container "quay.io/biocontainers/cutadapt:2.10--py37hf01694f_1"

    conda (params.conda ? "${moduleDir}/environment.yml" : null)


  input:
  // --> meta is a Groovy MAP containing any number of information (metadata) per sample
  // or analysis unit, corresponding to each of "reads"
  // it is accessible via meta.name where ".name" is the name of the metadata
  // these MUST be described in the meta.yml when the metatada are expected by the process
  tuple val(meta), path(reads)

  // configuration parameters are accessible via
  // params.modules['modulename'].name
  // where "name" is the name of parameter, and defined in nextflow.config
  val options

  output:
  tuple val(meta), path("*_trimmed.fastq.gz"), emit: reads
  tuple val(meta), path("*_trim.*"), emit: logs
  path "*.version.txt", emit: version

  script:
  def cutopts  = initOptions(options)

  if (params.single_end) {
    """
    cutadapt \
    -j ${task.cpus} \
    -a file:${options.adapterfile3} \
    -g file:${options.adapterfile5} \
    -o ${sampleprefix}_R1_trimmed.fastq.gz \
    ${reads[0]} \
    ${cutopts.args} \
    > ${meta.sampleID}.trim.out \
    2> ${meta.sampleID}.trim.err

    cutadapt --version >cutadapt.version.txt
    """
  } else {
    """
    cutadapt \
    -j ${task.cpus} \
    -a file:${options.adapterfile3} \
    -A file:${options.adapterfile3} \
    -g file:${options.adapterfile5} \
    -G file:${options.adapterfile5} \
    -o ${meta.sampleID}_R1_trimmed.fastq.gz \
    -p ${meta.sampleID}_R2_trimmed.fastq.gz \
    ${reads[0]} ${reads[1]} \
    ${cutopts.args2} \
    > ${meta.sampleID}_trim.out \
    2> ${meta.sampleID}_trim.err

    cutadapt --version >cutadapt.version.txt
    """
  }



}
