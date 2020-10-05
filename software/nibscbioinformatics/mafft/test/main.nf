#!/usr/bin/env nextflow

nextflow.preview.dsl = 2
params.outdir = "test_output"
params.publish_dir_mode = "copy"
params.single_end = true
params.conda = false

params.cdhit_seq_identity = 0.9

include { MAFFT } from '../main.nf' params(params)


workflow {
  input = file("${baseDir}/data/test_samples.tsv")
  inputSample = Channel.empty()
  inputSample = readInputFile(input, params.single_end)

  // fake options - should be a groovy map but ok for testing now
  def Map options = [:]
  options.args = "--retree 0 --treeout --localpair --reorder"
  options.args2 = ''

  MAFFT(inputSample, options)

  // ## IMPORTANT this is a test workflow
  // so a test should always been implemented to check
  // the output corresponds to what expected

  MAFFT.out.tree.map { map, tree ->

    assert tree.exists()
    assert tree.getExtension() == "tree"

  }

}





// ############## WARNING !!! #########################
// the part below is going to be transferred to a module soon
// ############## UTILITIES AND SAMPLE LOADING ######################

// ### preliminary check functions

def checkExtension(file, extension) {
    file.toString().toLowerCase().endsWith(extension.toLowerCase())
}

def checkFile(filePath, extension) {
  // first let's check if has the correct extension
  if (!checkExtension(filePath, extension)) exit 1, "File: ${filePath} has the wrong extension. See --help for more information"
  // then we check if the file exists
  if (!file(filePath).exists()) exit 1, "Missing file in TSV file: ${filePath}, see --help for more information"
  // if none of the above has thrown an error, return the file
  return(file(filePath))
}

// the function expects a tab delimited sample sheet, with a header in the first line
// the header will name the variables and therefore there are a few mandatory names
// sampleID to indicate the sample name or unique identifier
// read1 to indicate read_1.fastq.gz, i.e. R1 read or forward read
// read2 to indicate read_2.fastq.gz, i.e. R2 read or reverse read
// any other column should fulfill the requirements of modules imported in main
// the function also expects a boolean for single or paired end reads from params

def readInputFile(tsvFile, single_end) {
    Channel.from(tsvFile)
        .splitCsv(header:true, sep: '\t')
        .map { row ->
            def meta = [:]
            def reads = []
            def sampleinfo = []
            meta.sampleID = row.sampleID
            if (single_end) {
              reads = checkFile(row.read1, "fasta")
            } else {
              reads = [ checkFile(row.read1, "fasta"), checkFile(row.read2, "fasta") ]
            }
            sampleinfo = [ meta, reads ]
            return sampleinfo
        }
}
