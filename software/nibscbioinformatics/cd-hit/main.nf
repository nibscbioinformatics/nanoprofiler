def MODULE = "cd-hit"
params.publish_dir = MODULE
params.publish_results = "default"

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

process CDHIT {
    // each module must define a process label to declare a category of
    // resource requirements
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
          saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.sampleID)
        }

    container "biocontainers/cd-hit:v4.6.8-2-deb_cv1"

    conda (params.conda ? "${moduleDir}/environment.yml" : null)


  input:
  // --> meta is a Groovy MAP containing any number of information (metadata) per sample
  // or analysis unit, corresponding to each of "reads"
  // it is accessible via meta.name where ".name" is the name of the metadata
  // these MUST be described in the meta.yml when the metatada are expected by the process
  tuple val(meta), path(reads)

  val options

  output:
  tuple val(meta), path("*.clusters"), emit: clusterseq
  tuple val(meta), path("*.clstr"), emit: clusters
  path "*.version.txt", emit: version

  script:
  """
  cd-hit \
  -i ${reads} \
  -o ${meta.sampleID}.aa.clusters \
  ${options.args} \
  -T ${task.cpus} \
  -M ${task.memory.toMega()}

  cd-hit -h | head -n1 | cut -d" " -f4,5,6,7,8,9 >cd-hit.version.txt
  """
}
