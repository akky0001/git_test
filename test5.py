import pandas as pd
import glob
import re
import os

filelist = glob.glob('.\\accesslog*.csv')
for inputfile in filelist:
    fr = open(inputfile, 'r')
    basename = os.path.splitext(os.path.basename(inputfile))[0]
    fw = open(basename + '_format.csv','w')
    for line in fr:
        fline = re.sub(r'^\'(\S+) (\S+) (\S+) db=(\S+) user=(\S+) pid=(\S+) userid=(\S+) xid=(\S+) (\S+)\' (\S+) (.*$)',
                       r'\1\t\2\t\3\t\4\t\5\t\6\t\7\t\8\t\9\t\10\t\11', line)
        fw.write(fline)
    
    fr.close()
    fw.close()