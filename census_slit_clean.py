import sqlite3
import pandas as pd
import numpy as np
import openpyxl

dbname = "Slit_Cleaning"
conn = sqlite3.connect(dbname + '.sqlite')
df = pd.read_excel("everything_intersect.xlsx")
#df.to_sql("slit_cleaning_test_2", conn)

df_read = pd.read_sql('SELECT * FROM slit_cleaning_test_2', conn)
df_query = pd.DataFrame(df_read)

new_cols = ['OHSA_Points', 'Crash_Points', 'NAME_2010', 'SAME_20_10', 'Total_Pop', 'Hisp', 'White', 'Black',
            'Native', 'Asian', 'Pacific', 'Other', 'Two_Plus', 'Car', 'Transit', 'Bike', 'Walk', 'WFH', 'Total Commuters',
            'GEOID10']

df_combined = pd.DataFrame(columns=df_query.columns)
#print(df_combined)
#print(df_query)

hold_list = []
data_list = []

duplicate_count = 0
holds_pushed = 0
not_duplicate = 0
is_last = False

for i in range(0, 4715):
    if df_query.iloc[i]["GEOID_20"] == df_query.iloc[i+1]["GEOID_20"]:
        is_last = False
        duplicate_count += 1
        row_as_list = df_query.loc[i, :].values.flatten().tolist()
        #print(row_as_list[9])
        hold_list.append(row_as_list)
    else:
        row_as_list = df_query.loc[i, :].values.flatten().tolist()
        #print(hold_list)
        #print(len(hold_list))
        if len(hold_list) > 0:
            if is_last:
                is_last = True
                # Find biggest area and push that one
                biggest_area = 0
                biggest_tract = []
                for hold in hold_list:
                    if hold[9] > biggest_area:
                        biggest_area = hold[9]
                        biggest_tract = hold
                #print(biggest_area)
                data_list.append(biggest_tract)
                holds_pushed += 1
                hold_list.clear()
        else:
            not_duplicate += 1
            data_list.append(row_as_list)

print("Duplicates Pushed:", holds_pushed, "Not Duplicates:", not_duplicate)
print(len(data_list))
# Target is 3,753

for data in data_list:
    #print(data)
    df_combined.loc[len(df_combined)] = data

#print(df_combined)

#df_combined.to_excel("duplicate_clean_test.xlsx")


