rule panel_filter_vcf:
    input:
        vcf="analysis_output/{sample}/{tool}/{sample}.vcf",
        bed=lambda wildcards: config[wildcards.tool][wildcards.diagnosis],
    output:
        "analysis_output/{sample}/{tool}/{sample}.panel.{diagnosis}.vcf",
    log:
        "analysis_output/{sample}/{tool}/panel_filter_vcf_{sample}_{diagnosis}.log",
    container:
        config["tools"]["common"]
    message:
        "{rule}: Filter {wildcards.sample} vcf using {input.bed}"
    shell:
        """
        (bedtools intersect \
        -header \
        -a {input.vcf} -b {input.bed} > {output}) &> {log}
        """
