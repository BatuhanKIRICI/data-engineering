import requests
import pandas as pd

url = 'https://jsonplaceholder.typicode.com/users'

response = requests.get(url)

# print(response.status_code)

data = response.json()

df = pd.DataFrame(data)

# print(df.columns)

df['city'] = df['address'].apply(lambda x : x['city'])

# print(df['city'])

df['company_name'] = df['company'].apply(lambda x : x['name'])

# print(df['company_name'])

clean_df = df[['id','name','email','city','company_name']]

# print(clean_df)

clean_df.to_csv('users_clean.csv', index=False)




