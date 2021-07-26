import git
import os
import pandas as pd
from pathlib import Path
from snakemake.utils import validate
from snakemake.utils import min_version


min_version("6.5.3")


### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_table(config["samples"]).set_index("sample", drop=False)

validate(samples, schema="../schemas/samples.schema.yaml")


### Functions


def get_snakefile(workflow, tags):
    return "https://github.com/marrip/%s/raw/%s/Snakefile" % (workflow, tags[workflow])


### Import subworkflows


module wgs_std_viper:
    snakefile: get_snakefile("wgs_std_viper", config["workflows"])
    config: config

use rule * from wgs_std_viper as wgs_std_*

module wgs_somatic_snp_viper:
    snakefile: get_snakefile("wgs_somatic_snp_viper", config["workflows"])
    config: config

use rule * from wgs_somatic_snp_viper as wgs_somatic_snp_*

module wgs_somatic_cnv_sv_viper:
    snakefile: get_snakefile("wgs_somatic_cnv_sv_viper", config["workflows"])
    config: config

use rule * from wgs_somatic_cnv_sv_viper as wgs_somatic_cnv_sv_*
