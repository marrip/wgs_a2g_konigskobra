include: "rules/common.smk"


rule all:
    input:
        expand("analysis_output/{sample}/wgs_std_viper.ok", sample=samples.index),
        expand("analysis_output/{sample}/wgs_somatic_snp_viper.ok", sample=samples.index),
        expand("analysis_output/{sample}/wgs_somatic_cnv_sv_viper.ok", sample=samples.index),
