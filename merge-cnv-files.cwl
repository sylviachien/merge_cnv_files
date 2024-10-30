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
      - entryname: merge_cnv_files.py
        entry: |-
          import os
          import pandas as pd
          import argparse
          import io
          import logging
          import glob

          def setup_logging():
              ''' To set up logging for the script '''
              logging.basicConfig(level=logging.INFO,
                                  format='%(asctime)s - %(levelname)s - %(message)s',
                                  handlers=[logging.StreamHandler()]) # log to console

          def extract_samplename_and_suffix(filepath):
              ''' 
              To extract the sample name and suffix from the filename
              param filename: the name of the file
              return: the sample name and suffix
              '''
              # Extract the filename from the file path
              filename = os.path.basename(filepath)
              # count  the number of '.' in the filename
              dot_count = filename.count('.')
              # split the filename based on the condition
              if dot_count > 1:
              # use '.' as the separator
                  parts = filename.split('.')
                  sample_name = parts[0]
                  suffix = '.'.join(parts[1:])
              else:
                  # use '_' as the separator
                  parts = filename.split('_')
                  sample_name = parts[0]
                  suffix = '_'.join(parts[1:])
              return sample_name, suffix

          def merge_files_with_sample_column(file_paths):
              ''' To generate a merged file from individual files with an additional sample column '''
              # get suffix from the first file
              sample_name, suffix = extract_samplename_and_suffix(file_paths[0])
              # dynamically create the output file name
              if suffix in ('allelic_states.txt',
                          'cluster_assignments.txt',
                          'cn_summary.txt',
                          'mclusters.txt',
                          'subclonal_cn.txt',
                          'uncorr_cn.seg',
                          'iCN.seg'):
                  output_file = f'merged_SCLUST_{suffix}'
              else:
                  output_file = f'merged_{suffix}'
              logging.info("Start merging %s files...", suffix)
              # create an empty dataframe to store the merged data
              merged_df = pd.DataFrame()
              # flag to ensure header is written only once
              iCN_header = "tumor_sample\tchromosome\tstart\tend\tnumber_of_SNPs\tcorrected_copy_number\n"
              uncorr_header = "tumor_sample\tchromosome\tstart\tend\tnumber_of_SNPs\tuncorrected_copy_number\n"
              # loop through the files
              for file_path in file_paths:
                  filtered_lines = []
                  header_written = False
                  sample_name, suffix = extract_samplename_and_suffix(file_path)
                  # open the file manually to handle special headers (@ and #)
                  try:
                      with open(file_path, 'r') as f:
                          lines = f.readlines()
                      if suffix == 'iCN.seg':
                          filtered_lines.append(iCN_header)
                          header_written = True
                      elif suffix == 'uncorr_cn.seg':
                          filtered_lines.append(uncorr_header)
                          header_written = True
                      for line in lines:
                          if line.startswith('@'):
                              continue
                          if line.startswith(('CONTIG','sample_name')) and not header_written:
                              filtered_lines.append(line)
                              header_written = True
                          elif not line.startswith(('CONTIG','sample_name')):
                              filtered_lines.append(line)
                      # use io.StringIO to read the filtered lines as a dataframe
                      filtered_content = ''.join(filtered_lines)
                      df = pd.read_csv(io.StringIO(filtered_content), sep='\t', engine='python')

                  except Exception as e:
                      print(f"Error reading file {file_path}: {e}")
                      continue
                  # add the sample name as a new column
                  df.insert(0, 'sample', sample_name)
                  # append the data to the merged dataframe
                  merged_df = pd.concat([merged_df, df], ignore_index=True)
              # write the merged data to a new file
              merged_df.to_csv(output_file, sep='\t', index=False)
              logging.info(f"Files successfully merged into %s", output_file)

          def parse_arguments():
              '''
              Parse command-line arguments for the script
              Return: 
              - args: parsed arguments
              '''
              parser = argparse.ArgumentParser(description="Merge different CNV files with sample id column")
              # optional arguments for different types of CNV files
              #parser.add_argument('--gatk_modelfinal_seg', nargs='+', type=str, help="List of GATK modelFinal.seg file paths separated by space")
              #parser.add_argument('--gatk_call_seg', nargs='+', type=str, help="List of GATK called.seg file paths separated by space")
              #parser.add_argument('--controlfreec_cn_pvalue', nargs='+', type=str, help="List of Control-FREEC CNV-loh.p.value file paths separated by space")
              #parser.add_argument('--sclust_cn_summary', nargs='+', type=str, help="List of Sclust cn_summary file paths separated by space")
              #parser.add_argument('--sclust_allelic_states', nargs='+', type=str, help="List of Sclust allelic_states file paths separated by space")
              #parser.add_argument('--sclust_subclonal_cn', nargs='+', type=str, help="List of Sclust subclonal_cn file paths separated by space")
              #parser.add_argument('--sclust_uncorr_cn_seg', nargs='+', type=str, help="List of Sclust uncorr_cn.seg file paths separated by space")
              #parser.add_argument('--sclust_icn_seg', nargs='+', type=str, help="List of Sclust iCN.seg file paths separated by space")
              #parser.add_argument('--sclust_mclusters', nargs='+', type=str, help="List of Sclust mclusters file paths separated by space")
              #parser.add_argument('--sclust_cluster_assignments', nargs='+', type=str, help="List of Sclust cluster_assignments file paths separated by space")
              parser.add_argument('--conseca', nargs='+', type=str, help="List of conseca file paths separated by space")
              return parser.parse_args()

          def main():
              setup_logging()
              args = parse_arguments()
              # check the input file lists by type
              args.gatk_modelfinal_seg = glob.glob('./*.GATK.CNV-loh.modelFinal.seg')
              args.gatk_call_seg = glob.glob('./*.GATK.CNV-loh.called.seg')
              args.controlfreec_cn_pvalue = glob.glob('./*.FREEC.CNV-loh.p.value.txt')
              args.sclust_cn_summary = glob.glob('./*_cn_summary.txt')
              args.sclust_allelic_states = glob.glob('./*_allelic_states.txt')
              args.sclust_subclonal_cn = glob.glob('./*_subclonal_cn.txt')
              args.sclust_uncorr_cn_seg = glob.glob('./*_uncorr_cn.seg')
              args.sclust_icn_seg = glob.glob('./*_iCN.seg')
              args.sclust_mclusters = glob.glob('./*_mclusters.txt')
              args.sclust_cluster_assignments = glob.glob('./*_cluster_assignments.txt')
              args.conseca = glob.glob('./*.CNV-loh.Conseca.tsv')

              # call the function to merge the files
              if args.gatk_modelfinal_seg:
                  merge_files_with_sample_column(args.gatk_modelfinal_seg)
              if args.gatk_call_seg:
                  merge_files_with_sample_column(args.gatk_call_seg)
              if args.controlfreec_cn_pvalue:
                  merge_files_with_sample_column(args.controlfreec_cn_pvalue)
              if args.sclust_cn_summary:
                  merge_files_with_sample_column(args.sclust_cn_summary)
              if args.sclust_allelic_states:
                  merge_files_with_sample_column(args.sclust_allelic_states)
              if args.sclust_subclonal_cn:
                  merge_files_with_sample_column(args.sclust_subclonal_cn)
              if args.sclust_uncorr_cn_seg:
                  merge_files_with_sample_column(args.sclust_uncorr_cn_seg)
              if args.sclust_icn_seg:
                  merge_files_with_sample_column(args.sclust_icn_seg)
              if args.sclust_mclusters:
                  merge_files_with_sample_column(args.sclust_mclusters)
              if args.sclust_cluster_assignments:
                  merge_files_with_sample_column(args.sclust_cluster_assignments)
              if args.conseca:
                  merge_files_with_sample_column(args.conseca)

          if __name__ == '__main__':
              main()

baseCommand: 
- python3 
- merge_cnv_files.py

inputs:
  gatk_called_seg_files:
    label: GATK called seg files
    doc: GATK segmentation files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --gatk_call_seg
  gatk_modelFinal_seg_files:
    label: GATK modelFinal seg files
    doc: GATK modelFinal segmentation files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --gatk_modelfinal_seg
  controlfreec_pvalue_files:
    label: ControlFREEC p-value files
    doc: ControlFREEC p-value files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --controlfreec_cn_pvalue
  sclust_iCN_seg_files:
    label: Sclust iCN seg files
    doc: Sclust iCN segmentation files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --sclust_icn_seg
  sclust_uncorr_cn_seg_files:
    label: Sclust uncorrected CN seg files
    doc: Sclust uncorrected CN segmentation files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --sclust_uncorr_cn_seg
  sclust_cn_summary_files:
    label: Sclust CN summary files
    doc: Sclust CN summary files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --sclust_cn_summary
  sclust_allelic_states_files:
    label: Sclust allelic states files
    doc: Sclust allelic states files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --sclust_allelic_states
  sclust_sub_clonal_cn_files:
    label: Sclust sub clonal CN files
    doc: Sclust sub clonal CN files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --sclust_subclonal_cn
  sclust_mclusters_files:
    label: Sclust mclusters files
    doc: Sclust mclusters files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --sclust_mclusters
  sclust_cluster_assignment_files:
    label: Sclust cluster assignment files
    doc: Sclust cluster assignment files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --sclust_cluster_assignment
  conseca_files:
    label: Conseca files
    doc: Conseca files
    type: File[]?
    inputBinding:
      position: 0
      prefix: --conseca

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



          