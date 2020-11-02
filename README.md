# ![nibscbioinformatics/nanoprofiler](docs/images/nibscbioinformatics-nanoprofiler_logo.png)

**Analysis and reporing repertoire of nanobodies**.

[![GitHub Actions CI Status](https://github.com/nibscbioinformatics/nanoprofiler/workflows/nf-core%20CI/badge.svg)](https://github.com/nibscbioinformatics/nanoprofiler/actions)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A519.10.0-brightgreen.svg)](https://www.nextflow.io/)

[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg)](http://bioconda.github.io/)
![Biopython Container](https://github.com/nibscbioinformatics/nanoprofiler/workflows/Build%20Biopython/badge.svg)

## Introduction

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It comes with docker containers making installation trivial and results highly reproducible.

## Quick Start

i. Install [`nextflow`](https://nf-co.re/usage/installation)

ii. Install either [`Docker`](https://docs.docker.com/engine/installation/) or [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) for full pipeline reproducibility (please only use [`Conda`](https://conda.io/miniconda.html) as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))

iii. Download the pipeline and test it on a minimal dataset with a single command

```bash
nextflow run nibscbioinformatics/nanoprofiler -profile test,<docker/singularity/conda/institute>
```

> Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.

iv. Start running your own analysis!

To run the pipeline within NIBSC infrastructure, use the following command

```bash
nextflow run nibscbioinformatics/nanoprofiler \
[-r dev] \
-profile nibsc \
[-c additional_settings.config] \
--input samples.tsv \
--adapterfile adapters.fa \
--single_end false
```

See [usage docs](docs/usage.md) for all of the available options when running the pipeline.

## Documentation

The nibscbioinformatics/nanoprofiler pipeline comes with documentation about the pipeline, found in the `docs/` directory:

1. [Installation](https://nf-co.re/usage/installation)
2. Pipeline configuration
    * [Local installation](https://nf-co.re/usage/local_installation)
    * [Adding your own system config](https://nf-co.re/usage/adding_own_config)
    * [Reference genomes](https://nf-co.re/usage/reference_genomes)
3. [Running the pipeline](docs/usage.md)
4. [Output and how to interpret the results](docs/output.md)
5. [Troubleshooting](https://nf-co.re/usage/troubleshooting)

The pipeline is inspired to the work published by Deschaght et al. in 2017 (doi: 10.3389/fimmu.2017.00420), and performs a repertoire diversity analysis of nanobodies generated in immunised alpacas, and further selected by subsequent boosts.
We cluster the nanobodies sequences using CD-HIT, and we extract and analyse their CDR3.
Finally, we produce a minimal report and a table of cluster representative sequences and CDR3 by sample, immunisation and boost for further follow-up.

## Credits

nibscbioinformatics/nanoprofiler was originally written by Francesco Lescai, with in-house scripts contributed by Thomas Bleazard. Scientific review and contribution, thanks to Elliot MacLeod.

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on [Slack](https://nfcore.slack.com/channels/nanoprofiler) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citation

If you use  nibscbioinformatics/nanoprofiler for your analysis, please cite it using the following doi: [10.5281/zenodo.4195774](https://doi.org/10.5281/zenodo.4195774)

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).  
> ReadCube: [Full Access Link](https://rdcu.be/b1GjZ)

## Disclaimer

This first release of the pipeline comes with minimal documentation and reporting. We are working hard to improve this, for a next release.