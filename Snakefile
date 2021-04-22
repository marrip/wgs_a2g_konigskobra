include: "rules/common.smk"


rule all:
    input:
        wgs_std_viper(
            expand("analysis_output/{sample}/wgs_std_viper.ok", sample=samples.index)
        ),
        wgs_somatic_cnv_sv_viper(
            expand("analysis_output/{sample}/wgs_somatic_cnv_sv_viper.ok", sample=samples.index)
        ),
