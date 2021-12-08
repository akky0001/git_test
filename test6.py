import pandas as pd
import glob
import openpyxl

fileList = glob.glob('./testData/member*.csv')
excludeList = ('太','すず','a','p')

print(fileList)

# wb = openpyxl.Workbook()

for filename in fileList:
    df = pd.read_csv(filename, names=('name','birthday','fruits'),header=0)
    df['name']=df['name'].str.lower()
    username=df[~df.name.str.startswith(excludeList)]
    print(username)
    userlist = username['name'].unique().tolist()
    username.to_excel('test.xlsx')

    for user in userlist:
        print(user)