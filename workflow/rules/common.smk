from git_modules import git_module
import pandas as pd
from snakemake.utils import validate
from snakemake.utils import min_version


min_version("6.0.0")

### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")


### Read and validate samples file

samples = pd.read_table(config["samples"], dtype=str).set_index("sample", drop=False)
validate(samples, schema="../schemas/samples.schema.yaml")

### Read and validate units file

units = (
    pd.read_table(config["units"], dtype=str)
    .sort_values(["sample", "unit"], ascending=False)
    .set_index(["sample", "unit", "run", "lane"], drop=False)
)
validate(units, schema="../schemas/units.schema.yaml")

### Set wildcard constraints


wildcard_constraints:
    sample="|".join(samples.index),


### Import modules


snk_file = git_module(config["modules"]["wgs_std_viper"])


module wgs_std_viper:
    snakefile:
        snk_file
    config:
        config


use rule * from wgs_std_viper as wgs_std_*


if config["mutect2"]["pon"] == "" or config["cnvkit"]["pon"] == "":

    snk_file = git_module(config["modules"]["wgs_somatic_pon"])

    module wgs_somatic_pon:
        snakefile:
            snk_file
        config:
            config

    use rule * from wgs_somatic_pon as wgs_somatic_pon_*


snk_file = git_module(config["modules"]["wgs_somatic_snp_viper"])


module wgs_somatic_snp_viper:
    snakefile:
        snk_file
    config:
        config


use rule * from wgs_somatic_snp_viper as wgs_somatic_snp_*


snk_file = git_module(config["modules"]["wgs_somatic_cnv_sv_viper"])


module wgs_somatic_cnv_sv_viper:
    snakefile:
        snk_file
    config:
        config


use rule * from wgs_somatic_cnv_sv_viper as wgs_somatic_cnv_sv_*


### Functions


def compile_output_list(wildcards):
    output_list = []
    files = {
        "cnvkit": ["vcf"],
        "cnvnator": [
            "pon.vcf",
        ],
        "manta": [
            "pon.vcf",
        ],
        "mutect2": [
            "filtered.vcf",
            "filtered.vcf.stats",
        ],
        "multiqc": [
            "html",
        ],
        "tiddit": [
            "pon.vcf",
        ],
        "vardict": [
            "vcf",
        ],
    }
    for key in files.keys():
        output_list = output_list + expand(
            "analysis_output/{sample}/{tool}/{sample}.{ext}",
            sample=samples.index,
            tool=key,
            ext=files[key],
        )
    return output_list
