import json
import requests
import pandas as pd

data = '''
{
    "order_id": 101,
    "customer": "Ali",
    "country": "DE",
    "amount": 120
}
'''

order = json.loads(data)

response = requests.get("https://jsonplaceholder.typicode.com/users")

data = response.json()

df = pd.DataFrame(data)

# print(order)
# print(order["customer"])
# print(order["amount"])

# print(response.status_code)
# print(response.json())

# print(data[0])
# print(type(data))

# print(df)
# print(df.columns)

df['city'] = df['address'].apply(lambda x : x['city'])

df['company_name'] = df['company'].apply(lambda x : x['name'])

# print(df['company_name'])

clean_df = df[["id", "name", "email", "city", "company_name"]]

print(clean_df)


