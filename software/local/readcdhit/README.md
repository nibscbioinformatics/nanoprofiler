# GET CDR3 sequences

## Add Software information

Run in-house python script to collect the CDR3 sequences only
  from the full amino acid sequence, using the context of the CDR3 which
  begins with amino acids which commence after a YYC and terminates with
  the amino acids which precede a WGQ. We also compute the length distribution of
  these CDR3 sequences.
  Note that this approach is not robust to amino acid sequences which do not follow
  this pattern, or contain the motifs in other positions.

## Add information about the process

It is important to describe the script in the process, and in particular expected inputs and outputs, using the information structured in the YAML file.
