import os
import pandas as pd
import argparse
import io
import logging

def setup_logging():
    ''' Set up logging for the script '''
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s',
                        handlers=[logging.StreamHandler()]) # log to console

def extract_samplename_and_suffix(filepath):
    ''' Extract the sample name and suffix from the filename 
    param filename: the name of the file
    return: the sample name and suffix
    '''
    # Extract the filename from the file path
    filename = os.path.basename(filepath)
    # Count the number of '.' in the filename
    dot_count = filename.count('.')
    # Split the filename based on the condition
    if dot_count > 1:
        # Use '.' as the separator
        parts = filename.split('.')
        sample_name = parts[0]
        suffix = '.'.join(parts[1:])
    else:
        # Use '_' as the separator
        parts = filename.split('_')
        sample_name = parts[0]
        suffix = '_'.join(parts[1:])
    return sample_name, suffix


def merge_files_with_sample_column(file_paths, suffix):
    ''' Generate a merged file from individual files with an additional sample column 
    param file_paths: list of file paths to merge
    param suffix: the suffix of the files to be merged
    ''' 
    # Define the output file name based on the suffix
    if suffix in ('allelic_states.txt','cluster_assignments.txt','cn_summary.txt','mclusters.txt','subclonal_cn.txt','uncorr_cn.seg','iCN.seg'):
        output_file = f'merged_SCLUST_{suffix}'
    else:
        output_file = f'merged_{suffix}'
    # Log the start of the merging process
    logging.info(f"Start merging {suffix} files...")
    # Create an empty DataFrame to store the merged data
    merged_df = pd.DataFrame()
    iCN_header = "tumor_sample\tchromosome\tstart\tend\tnumber_of_SNPs\tcorrected_copy_number\n"
    uncorr_header = "tumor_sample\tchromosome\tstart\tend\tnumber_of_SNPs\tuncorrected_copy_number\n"
    for file_path in file_paths:
        filtered_lines = []
        header_written = False
        sample_name, _ = extract_samplename_and_suffix(file_path)
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
            filtered_content = ''.join(filtered_lines)
            df = pd.read_csv(io.StringIO(filtered_content), sep='\t', engine='python')
        except Exception as e:
            logging.error(f"Error processing file {file_path}: {e}")
            continue
        # Add the sample column to the DataFrame
        df.insert(0, 'sample', sample_name)
        # Append the DataFrame to the merged DataFrame
        merged_df = pd.concat([merged_df, df], ignore_index=True)
    # Write the merged DataFrame to a file
    merged_df.to_csv(output_file, sep='\t', index=False)
    logging.info(f"Files successfully merged into {output_file}")


def collect_files_by_suffix(directory, suffix):
    ''' Collect files with a specific suffix from a directory 
    param directory: the directory to search for files
    param suffix: the suffix of the files to collect
    return: a list of file paths with the specified suffix
    '''
    return [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith(suffix)]


def parse_arguments():
    ''' Parse command line arguments 
    return: the parsed arguments
    '''
    parser = argparse.ArgumentParser(description='Merge CNV files with a sample column')
    parser.add_argument('--input_directory', type=str, required=True, help='Directory containing CNV files for merging')
    return parser.parse_args()


def main():
    ''' Main function to merge CNV files with a sample column '''
    setup_logging()
    args = parse_arguments()

    # Define suffixes and merge each type separately
    suffixes = [
        'allelic_states.txt',
        'cluster_assignments.txt',
        'cn_summary.txt',
        'mclusters.txt',
        'subclonal_cn.txt',
        'uncorr_cn.seg',
        'iCN.seg',
        'GATK.CNV-loh.modelFinal.seg',
        'GATK.CNV-loh.called.seg',
        'FREEC.CNV-loh.p.value.txt',
        'CNV-loh.Conseca.tsv',
    ]
    for suffix in suffixes:
        file_paths = collect_files_by_suffix(args.input_directory, suffix)
        if file_paths:
            merge_files_with_sample_column(file_paths, suffix)
        else:
            logging.info(f"No files found with suffix {suffix} in directory {args.input_directory}.")


if __name__ == '__main__':
    main()
