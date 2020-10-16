def MODULE = "report"
params.publish_dir = MODULE
params.publish_results = "default"

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'


process REPORT {

  // each module must define a process label to declare a category of
    // resource requirements
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
          saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.sampleID)
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
    path(metadata)
    val options

    output:
    path "*.RData", emit: rdata
    path "*.html", emit: report
    path "cdr3_boost_overview_table.tsv", emit: results


    script:
    
    // write this on a file R can read
    sampleData = file("sampledata.tsv")
    sampleData.append("ID\timmunisation\tboost\n")

    // now need to map them in order to gather the files
    metadata.each() { map -> 
        sampleData.append("${map.sampleID}\t${map.immunisation}\t${map.boost}\n")
    }
    clusterList = clustersummaries.join(",")
    histoList = cdr3histograms.join(",")
    tableList = cdr3tables.join(",")

    """
    ln -s $moduleDir/nibsc_report.css .

    Rscript -e "workdir<-getwd()
        rmarkdown::render('$moduleDir/analysis_report.Rmd',
        params = list(
        clusterList = \\\"$clusterList\\\",
        histoList = \\\"$histoList\\\",
        tableList = \\\"$tableList\\\",
        sampleData = \\\"sampledata.tsv\\\"
        ),
        knit_root_dir=workdir,
        output_dir=workdir)"
    """



}
