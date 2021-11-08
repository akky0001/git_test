import pandas as pd

df = pd.read_csv("filepath",skiprows=2,usecols=[0,18], parse_dates=[0])
print(df)
CPU = ["Timestamp","CPU_Usage"]
df2 = df.copy()
df2.columns = CPU
# df3 = df2.copy()
# print(df3)
df3 = df2.groupby(pd.Grouper(key='Timestamp', freq='300s')).mean()
df4 = df3.rename(columns={'CPU_Usage':'CPU_Usage(avg)'})
# df3['CPU_Usage(avg)'] = df2.groupby(pd.Grouper(key='Timestamp', freq='60s')).mean()
df4['CPU_Usage(max)'] = df2.groupby(pd.Grouper(key='Timestamp', freq='300s')).max()

df4.to_csv("filepath")
