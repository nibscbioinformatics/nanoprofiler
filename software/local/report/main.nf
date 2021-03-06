def MODULE = "report"
params.publish_dir = MODULE
params.publish_results = "default"

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'


process REPORT {

  // each module must define a process label to declare a category of
    // resource requirements
    label 'process_high'
    label 'reporting'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
          saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:'')
        }
    
    container "ghcr.io/nibscbioinformatics/nibscreporting:v1.00" 

    // conda for the moment cannot work because not all R packages can be installed
    // with conda recipes
    conda (params.conda ? "${moduleDir}/environment.yml" : null)

    // expects to receive a collect of files-only
    // to simplify passing files as a path, and bring all sym links into
    // the reporting folder
    // READCDHIT.out.summaryonly.collect()
    // GETCDR3.out.histonly.collect()
    // GETCDR3.out.tsvonly.collect()
    // GETCDR3.out.metaonly.collect() 

    input:
    path(clustersummaries)
    path(cdr3histograms)
    path(cdr3tables)
    val(metadata)
    val options

    output:
    path "*.RData", emit: rdata
    path "*.html", emit: report
    path "cdr3_boost_overview_table.tsv", emit: results


    script:
    
    // write this on a file R can read
    def sampleData = new File("${workDir}/sampledata.tsv")
    sampleData.append("ID\tindividual\timmunisation\tboost\n")

    // now need to map them in order to gather the files
    metadata.each() { map -> 
        sampleData.append("${map.sampleID}\t${map.individualID}\t${map.immunisation}\t${map.boost}\n")
    }
    clusterList = clustersummaries.join(",")
    histoList = cdr3histograms.join(",")
    tableList = cdr3tables.join(",")

    """
    ln -s $moduleDir/nibsc_report.css .
    ln -s ${workDir}/sampledata.tsv .

    Rscript -e "workdir<-getwd()
        rmarkdown::render('$moduleDir/analysis_report.Rmd',
        params = list(
        clusterList = \\\"$clusterList\\\",
        histoList = \\\"$histoList\\\",
        tableList = \\\"$tableList\\\",
        sampleData = \\\"sampledata.tsv\\\",
        sizeThreshold = \\\"${params.cluster_size_threshold}\\\",
        loopFile = \\\"$moduleDir/loop_tree.Rmd\\\",
        calcTree = \\\"${params.calculate_tree}\\\"
        ),
        knit_root_dir=workdir,
        intermediates_dir=workdir,
        output_dir=workdir)"
    """



}
