import pandas as pd

# df = pd.read_csv('orders.csv')

# germany_orders = df[df['country']=='DE']

# total_amount = df['amount'].sum()

# total_amount_germany = df[df['country']=='DE']['amount'].sum()

# total_by_person = df.groupby(['customer'])['amount'].sum()

# total_by_person_sorted = total_by_person.sort_values(ascending=False)

# print(germany_orders)
# print(total_amount)
# print(total_amount_germany)
# print(total_by_person)
# print(total_by_person_sorted)

# --------------------------------------------------------------------------------
df = pd.read_csv('orders_dirty.csv')

# print(df)
# print(df.info())

# print(df.isnull().sum())

df['customer'] = df['customer'].fillna('Unknown')

# print(df.duplicated(['order_id','customer','country','amount']))

df = df.drop_duplicates(['customer','country','amount'])

print(df)

















