#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 19 10:47:59 2024

@author: akhorgad
"""

import argparse
import tempfile
import subprocess
from Bio import SeqIO



def iupred_for_multifasta(infile, outfile, mode):
    with open(outfile, "w") as outfh, open("./logfile.txt", "w") as errfh:
        for seq_record in SeqIO.parse(infile, "fasta"):
            try :
                print('processing fasta id: %s' % seq_record.id )
                in_seq = ">"+seq_record.id+"\n"+str(seq_record.seq)+"\n"
                in_tmp_file = tempfile.NamedTemporaryFile(mode = 'w')
                with in_tmp_file as in_tmp_h:
                    in_tmp_h.write(in_seq)
                    in_tmp_h.seek(0, 0)
                    out_tmp_file = tempfile.NamedTemporaryFile(mode = 'w')           
                    proc = subprocess.run(\
                        ['python',
                         '/Users/akhorgad/functionalAnno/iupred2a/iupred2a.py',\
                         '-a', in_tmp_file.name, mode] , stdout=out_tmp_file,stderr=subprocess.PIPE, shell=False)
                        
                with open(out_tmp_file.name) as out_tmp_h:
                    pred_text=out_tmp_h.readlines()
                    pred_text.insert(6, str('>'+seq_record.id+'\n'))
                    outfh.writelines(pred_text)
                
                for err in proc.stderr:
                    errfh.write(err)
                    
            except subprocess.CalledProcessError as e:
                print(f"Command failed with return code {e.returncode}")
    outfh.close()
    errfh.close()
    print('Error logs written to file ./logfile.txt')
    return


def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('-h', '--help', action='help',
               help='To run this script please provide two arguments')
    parser.add_argument('-i','--input_multi_fasta', required=True, help="path to input multifast file.")
    parser.add_argument('-o', '--out_filepath', required=True, help="path to output prediction file.")
    parser.add_argument('-m','--mode', required=True, help="path to 012.indv file")
    args = parser.parse_args()
    
    iupred_for_multifasta(args.input_multi_fasta, args.out_filepath, args.mode)

if __name__ == "__main__":
    main()


