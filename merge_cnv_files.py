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
              # Known suffixes to check against
              known_suffixes = [
                "GATK.CNV-loh.modelFinal.seg",
                "GATK.CNV-loh.called.seg",
                "FREEC.CNV-loh.p.value.txt",
                "cn_summary.txt",
                "allelic_states.txt",
                "subclonal_cn.txt",
                "uncorr_cn.seg",
                "iCN.seg",
                "mclusters.txt",
                "cluster_assignments.txt",
                "CNV-loh.Conseca.tsv"
              ]
              # Check if the filename ends with any known suffix
              for suffix in known_suffixes:
                  if filename.endswith(suffix):
                      # Extract sample name by removing the suffix from the end
                      sample_name = filename[: -len(suffix)].rstrip('.').rstrip('_')
                      return sample_name, suffix
              # if no known suffx is found, return none
              return None, None

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
    return parser.parse_args()

def main():
    setup_logging()
    args = parse_arguments()
    # check the input file lists by type
    args.gatk_modelfinal_seg = glob.glob('*.GATK.CNV-loh.modelFinal.seg')
    args.gatk_call_seg = glob.glob('*.GATK.CNV-loh.called.seg')
    args.controlfreec_cn_pvalue = glob.glob('*.FREEC.CNV-loh.p.value.txt')
    args.sclust_cn_summary = glob.glob('*_cn_summary.txt')
    args.sclust_allelic_states = glob.glob('*_allelic_states.txt')
    args.sclust_subclonal_cn = glob.glob('*_subclonal_cn.txt')
    args.sclust_uncorr_cn_seg = glob.glob('*_uncorr_cn.seg')
    args.sclust_icn_seg = glob.glob('*_iCN.seg')
    args.sclust_mclusters = glob.glob('*_mclusters.txt')
    args.sclust_cluster_assignments = glob.glob('*_cluster_assignments.txt')
    args.conseca = glob.glob('*.CNV-loh.Conseca.tsv')

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
    if not args.gatk_modelfinal_seg and not args.gatk_call_seg and not args.controlfreec_cn_pvalue and not args.sclust_cn_summary and not args.sclust_allelic_states and not args.sclust_subclonal_cn and not args.sclust_uncorr_cn_seg and not args.sclust_icn_seg and not args.sclust_mclusters and not args.sclust_cluster_assignments and not args.conseca:
        logging.error("No files provided for merging. Please provide files to merge.")
    else:
        logging.info("All files successfully merged.")

if __name__ == '__main__':
    main()

