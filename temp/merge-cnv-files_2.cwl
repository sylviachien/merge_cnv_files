cwlVersion: v1.2
class: CommandLineTool
label: Merge CNV Result Files

hints:
  DockerRequirement:
    dockerPull: bms-images.sbgenomics.com/bristol-myers-squibb/merge_cnv_files:latest

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - writable: false
        entry: $(inputs.gatk_modelfinal_seg)
      - writable: false
        entry: $(inputs.gatk_call_seg)
      - writable: false
        entry: $(inputs.controlfreec_cn_pvalue)
      - writable: false
        entry: $(inputs.sclust_cn_summary)
      - writable: false
        entry: $(inputs.sclust_allelic_states)
      - writable: false
        entry: $(inputs.sclust_subclonal_cn)
      - writable: false
        entry: $(inputs.sclust_uncorr_cn_seg)
      - writable: false
        entry: $(inputs.sclust_icn_seg)
      - writable: false
        entry: $(inputs.sclust_mclusters)
      - writable: false
        entry: $(inputs.sclust_cluster_assignments)
      - writable: false
        entry: $(inputs.conseca)

baseCommand: [python3, merge_cnv_files.py]

inputs:
  gatk_called_seg_files:
    label: GATK called seg files
    doc: GATK segmentation files
    type: File[]?
    #inputBinding:
    #  position: 1
    #  prefix: --gatk_call_seg
  gatk_modelFinal_seg_files:
    label: GATK modelFinal seg files
    doc: GATK modelFinal segmentation files
    type: File[]?
    #inputBinding:
    #  position: 2
    #  prefix: --gatk_modelfinal_seg
  controlfreec_pvalue_files:
    label: ControlFREEC p-value files
    doc: ControlFREEC p-value files
    type: File[]?
    #inputBinding:
    #  position: 3
    #  prefix: --controlfreec_cn_pvalue
  sclust_iCN_seg_files:
    label: Sclust iCN seg files
    doc: Sclust iCN segmentation files
    type: File[]?
    #inputBinding:
    #  position: 4
    #  prefix: --sclust_icn_seg
  sclust_uncorr_cn_seg_files:
    label: Sclust uncorrected CN seg files
    doc: Sclust uncorrected CN segmentation files
    type: File[]?
    #inputBinding:
    #  position: 5
    #  prefix: --sclust_uncorr_cn_seg
  sclust_cn_summary_files:
    label: Sclust CN summary files
    doc: Sclust CN summary files
    type: File[]?
    #inputBinding:
    #  position: 6
    #  prefix: --sclust_cn_summary
  sclust_allelic_states_files:
    label: Sclust allelic states files
    doc: Sclust allelic states files
    type: File[]?
    #inputBinding:
    #  position: 7
    #  prefix: --sclust_allelic_states
  sclust_sub_clonal_cn_files:
    label: Sclust sub clonal CN files
    doc: Sclust sub clonal CN files
    type: File[]?
    #inputBinding:
    #  position: 8
    #  prefix: --sclust_subclonal_cn
  sclust_mclusters_files:
    label: Sclust mclusters files
    doc: Sclust mclusters files
    type: File[]?
    #inputBinding:
    #  position: 9
    #  prefix: --sclust_mclusters
  sclust_cluster_assignment_files:
    label: Sclust cluster assignment files
    doc: Sclust cluster assignment files
    type: File[]?
    #inputBinding:
    #  position: 10
    #  prefix: --sclust_cluster_assignment
  conseca_files:
    label: Conseca files
    doc: Conseca files
    type: File[]?
    #inputBinding:
    #  position: 11
    #  prefix: --conseca

outputs:
  merged_gatk_called_seg:
    type: File?
    outputBinding:
      glob: merged_GATK.CNV-loh.called.seg

  merged_gatk_modelFinal_seg:
    type: File?
    outputBinding:
      glob: merged_GATK.CNV-loh.modelFinal.seg

  merged_controlfreec_pvalue:
    type: File?
    outputBinding:
      glob: merged_FREEC.CNV-loh.p.value.txt

  merged_sclust_iCN_seg:
    type: File?
    outputBinding:
      glob: merged_SCLUST_iCN.seg

  merged_sclust_uncorr_cn_seg:
    type: File?
    outputBinding:
      glob: merged_SCLUST_uncorr_cn.seg

  merged_sclust_cn_summary:
    type: File?
    outputBinding:
      glob: merged_SCLUST_cn_summary.txt
    
  merged_sclust_allelic_states:
    type: File?
    outputBinding:
      glob: merged_SCLUST_allelic_states.txt

  merged_sclust_sub_clonal_cn:
    type: File?
    outputBinding:
      glob: merged_SCLUST_subclonal_cn.txt

  merged_sclust_mclusters:
    type: File?
    outputBinding:
      glob: merged_SCLUST_mclusters.txt

  merged_sclust_cluster_assignment:
    type: File?
    outputBinding:
      glob: merged_SCLUST_cluster_assignments.txt

  merged_conseca_files:
    type: File?
    outputBinding:
      glob: merged_CNV-loh.Conseca.tsv
