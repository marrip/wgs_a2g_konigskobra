import pandas as pd
from snakemake.utils import validate
from snakemake.utils import min_version


min_version("6.5.3")

### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")


### Read and validate samples file

samples = pd.read_table(config["samples"], dtype=str).set_index("sample", drop=False)
validate(samples, schema="../schemas/samples.schema.yaml")

### Read and validate units file

units = pd.read_table(config["units"], dtype=str).set_index(
    ["sample", "unit", "run", "lane"], drop=False
)
validate(units, schema="../schemas/units.schema.yaml")

### Set wildcard constraints


wildcard_constraints:
    sample="|".join(samples.index),


### Import modules


module wgs_std_viper:
    snakefile: "https://github.com/marrip/wgs_std_viper/raw/%s/workflow/Snakefile" % config["modules"]["wgs_std_viper"]
    config: config

use rule * from wgs_std_viper as wgs_std_*

if config["mutect2"]["pon"] == "" or config["cnvkit"]["pon"] == "":
    module wgs_somatic_pon:
        snakefile: "https://github.com/marrip/wgs_somatic_pon/raw/%s/workflow/Snakefile" % config["modules"]["wgs_somatic_pon"]
        config: config
    
    use rule * from wgs_somatic_pon as wgs_somatic_pon_*

module wgs_somatic_snp_viper:
    snakefile: "https://github.com/marrip/wgs_somatic_snp_viper/raw/%s/workflow/Snakefile" % config["modules"]["wgs_somatic_snp_viper"]
    config: config

use rule * from wgs_somatic_snp_viper as wgs_somatic_snp_*

module wgs_somatic_cnv_sv_viper:
    snakefile: "https://github.com/marrip/wgs_somatic_cnv_sv_viper/raw/%s/workflow/Snakefile" % config["modules"]["wgs_somatic_cnv_sv_viper"]
    config: config

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
    files = {
        "collect_multiple_metrics": [
            "alignment_summary_metrics",
            "base_distribution_by_cycle_metrics",
            "base_distribution_by_cycle.pdf",
            "insert_size_metrics",
            "insert_size_histogram.pdf",
            "quality_by_cycle_metrics",
            "quality_by_cycle.pdf",
            "quality_distribution_metrics",
            "quality_distribution.pdf",
        ],
        "collect_alignment_summary_metrics": [
            "alignment_summary_metrics",
            "base_distribution_by_cycle_metrics",
            "base_distribution_by_cycle.pdf",
            "gc_bias.detail_metrics",
            "gc_bias.summary_metrics",
            "gc_bias.pdf",
            "insert_size_metrics",
            "insert_size_histogram.pdf",
            "quality_by_cycle_metrics",
            "quality_by_cycle.pdf",
            "quality_distribution_metrics",
            "quality_distribution.pdf",
        ],
        "collect_wgs_metrics": ["txt",],
        "gather_bam_files": ["bam",],
        "mosdepth": [
            "mosdepth.global.dist.txt",
            "mosdepth.region.dist.txt",
            "mosdepth.summary.txt",
            "regions.bed.gz",
            "regions.bed.gz.csi",
        ],
        "samtools_stats": ["txt",],
    }
    for row in units.loc[samples.index, ["sample", "unit", "run", "lane"]].iterrows():
        output_list.append(
            "analysis_output/%s/fastqc/%s_%s_%s_%s"
            % (row[1]["sample"], row[1]["sample"], row[1]["unit"], row[1]["run"], row[1]["lane"])
        )
    for row in units.loc[(samples.index), ["sample", "unit"]].drop_duplicates().iterrows():
        for key in files.keys():
            output_list = output_list + expand(
                "analysis_output/{sample}/{tool}/{sample}_{unit}.{ext}",
                sample=row[1]["sample"],
                tool=key,
                unit=row[1]["unit"],
                ext=files[key],
            )
    return output_list
