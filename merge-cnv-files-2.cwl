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
      - entryname: "input_manifest.txt"
        entry: |
          ${
            var filePaths = [];
            if (inputs.gatk_called_seg_files) filePaths = filePaths.concat(inputs.gatk_called_seg_files.map(f => f.path));
            if (inputs.gatk_modelFinal_seg_files) filePaths = filePaths.concat(inputs.gatk_modelFinal_seg_files.map(f => f.path));
            if (inputs.controlfreec_pvalue_files) filePaths = filePaths.concat(inputs.controlfreec_pvalue_files.map(f => f.path));
            if (inputs.sclust_iCN_seg_files) filePaths = filePaths.concat(inputs.sclust_iCN_seg_files.map(f => f.path));
            if (inputs.sclust_uncorr_cn_seg_files) filePaths = filePaths.concat(inputs.sclust_uncorr_cn_seg_files.map(f => f.path));
            if (inputs.sclust_cn_summary_files) filePaths = filePaths.concat(inputs.sclust_cn_summary_files.map(f => f.path));
            if (inputs.sclust_allelic_states_files) filePaths = filePaths.concat(inputs.sclust_allelic_states_files.map(f => f.path));
            if (inputs.sclust_sub_clonal_cn_files) filePaths = filePaths.concat(inputs.sclust_sub_clonal_cn_files.map(f => f.path));
            if (inputs.sclust_mclusters_files) filePaths = filePaths.concat(inputs.sclust_mclusters_files.map(f => f.path));
            if (inputs.sclust_cluster_assignment_files) filePaths = filePaths.concat(inputs.sclust_cluster_assignment_files.map(f => f.path));
            if (inputs.conseca_files) filePaths = filePaths.concat(inputs.conseca_files.map(f => f.path));
            return filePaths.join('\n');
          }
      - entryname: merge_cnv_files.py
        entry: |
          # Python script goes here

baseCommand: [python3, merge_cnv_files.py, "--manifest", "input_manifest.txt"]

inputs:
  gatk_called_seg_files:
    label: GATK called seg files
    doc: GATK segmentation files
    type: File[]?

  gatk_modelFinal_seg_files:
    label: GATK modelFinal seg files
    doc: GATK modelFinal segmentation files
    type: File[]?

  controlfreec_pvalue_files:
    label: ControlFREEC p-value files
    doc: ControlFREEC p-value files
    type: File[]?

  sclust_iCN_seg_files:
    label: Sclust iCN seg files
    doc: Sclust iCN segmentation files
    type: File[]?

  sclust_uncorr_cn_seg_files:
    label: Sclust uncorrected CN seg files
    doc: Sclust uncorrected CN segmentation files
    type: File[]?

  sclust_cn_summary_files:
    label: Sclust CN summary files
    doc: Sclust CN summary files
    type: File[]?

  sclust_allelic_states_files:
    label: Sclust allelic states files
    doc: Sclust allelic states files
    type: File[]?

  sclust_sub_clonal_cn_files:
    label: Sclust sub clonal CN files
    doc: Sclust sub clonal CN files
    type: File[]?

  sclust_mclusters_files:
    label: Sclust mclusters files
    doc: Sclust mclusters files
    type: File[]?

  sclust_cluster_assignment_files:
    label: Sclust cluster assignment files
    doc: Sclust cluster assignment files
    type: File[]?

  conseca_files:
    label: Conseca files
    doc: Conseca files
    type: File[]?

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
