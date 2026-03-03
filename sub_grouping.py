
# Code to select subjects for discovery and replication groups with matched age and sex

import pandas as pd
from sklearn.utils import shuffle


df = pd.read_excel('Filtered_HCP_Subjects_Info.xlsx')
males = df[df['Gender'] == 'M']
females = df[df['Gender'] == 'F']

# Step 3: Stratified age-wise split per gender
def stratified_split(group):
    g1, g2 = [], []
    for age in group['Age_in_Yrs'].unique():
        subset = group[group['Age_in_Yrs'] == age]
        subset = shuffle(subset, random_state=42)  
        n = len(subset)
        split = n // 2
        g1.append(subset.iloc[:split])
        g2.append(subset.iloc[split:])
    return pd.concat(g1), pd.concat(g2)

male_g1, male_g2 = stratified_split(males)
female_g1, female_g2 = stratified_split(females)

group1 = pd.concat([male_g1, female_g1]).reset_index(drop=True)
group2 = pd.concat([male_g2, female_g2]).reset_index(drop=True)

diff_m = len(group1[group1['Gender'] == 'M']) - len(group2[group2['Gender'] == 'M']) #diff = 3 in my case
diff_f = len(group1[group1['Gender'] == 'F']) - len(group2[group2['Gender'] == 'F'])

def move_subjects(source, target, gender, n):
    moved = source[source['Gender'] == gender].sample(n, random_state=42)
    source = source.drop(moved.index)
    target = pd.concat([target, moved])
    return source.reset_index(drop=True), target.reset_index(drop=True)

group1, group2 = move_subjects(group1, group2, 'M', diff_m)
group1, group2 = move_subjects(group1, group2, 'F', diff_m)

print("Group 1 - Total:", len(group1), "| Males:", sum(group1['Gender'] == 'M'), "| Females:", sum(group1['Gender'] == 'F'))
print("Group 2 - Total:", len(group2), "| Males:", sum(group2['Gender'] == 'M'), "| Females:", sum(group2['Gender'] == 'F'))

group1.to_excel('Final_Group1_Subjects_Info.xlsx', index=False)#Discovery
group2.to_excel('Final_Group2_Subjects_Info.xlsx', index=False)#Replication
