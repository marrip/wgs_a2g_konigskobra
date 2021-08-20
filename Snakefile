include: "rules/common.smk"


rule all:
    input:
        unpack(compile_output_list),
