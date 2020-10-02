def MODULE = "template"
params.publish_dir = MODULE
params.publish_results = "default"

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

// TODO nf-core: All of these TODO statements can be deleted after the relevant changes have been made.
// TODO nf-core: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/software
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join

// TODO nf-core: The key words "MUST", "MUST NOT", "SHOULD", etc. are to be interpreted as described in RFC 2119 (https://tools.ietf.org/html/rfc2119).
// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided as a string i.e. "options.args"
//               where "options" is a Groovy Map that MUST be provided in the "input:" section of the process.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. bwa mem | samtools view -B -T ref.fasta to output BAM instead of SAM.
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, "fake files" MAY be used to work around this issue.

// TODO nf-core: Process name MUST be all uppercase,
//               "SOFTWARE" and (ideally) "TOOL" MUST be all one word separated by an "_".



process FASTQC {
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
    container "quay.io/biocontainers/fastqc:0.11.9--0" // TODO -> change with appropriate biocontainer
    // alternatively, now we can choose "nibscbioinformatics/modules:software-version" which is built
    // automatically from the containers definitions

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

  // TODO nf-core: List additional required input channels/values here
  val options

  output:
  tuple val(meta), path("*.html"), emit: html
  tuple val(meta), path("*.zip"), emit: zip
  path "*.version.txt", emit: version

  script:
  // elegant solution as implemented by nf-core
  // all credits to original authors :)
  if (params.single_end) {
      """
      [ ! -f  ${meta.sampleID}.fastq.gz ] && ln -s $reads ${meta.sampleID}.fastq.gz
      fastqc ${params.modules['fastqc'].args} --threads $task.cpus ${meta.sampleID}.fastq.gz
      fastqc --version | sed -n "s/.*\\(v.*\$\\)/\\1/p" > fastqc.version.txt
      """
  } else {
      """
      [ ! -f  ${meta.sampleID}_1.fastq.gz ] && ln -s ${reads[0]} ${meta.sampleID}_1.fastq.gz
      [ ! -f  ${meta.sampleID}_2.fastq.gz ] && ln -s ${reads[1]} ${meta.sampleID}_2.fastq.gz
      fastqc ${params.modules['fastqc'].args} --threads $task.cpus ${meta.sampleID}_1.fastq.gz ${meta.sampleID}_2.fastq.gz
      fastqc --version | sed -n "s/.*\\(v.*\$\\)/\\1/p" > fastqc.version.txt
      """
  }
}
