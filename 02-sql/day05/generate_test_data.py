import random
from datetime import date, timedelta

rows = []

start_date = date(2025, 1, 1)

for order_id in range(1, 100001):
    customer_id = random.randint(1, 1000)
    amount = round(random.uniform(10, 2000), 2)
    order_date = start_date + timedelta(days=random.randint(0, 364))

    rows.append(
        (order_id, customer_id, amount, order_date)
    )

with open("test_orders.csv", "w") as f:
    f.write("order_id,customer_id,amount,order_date\n")

    for row in rows:
        f.write(f"{row[0]},{row[1]},{row[2]},{row[3]}\n")

print(f"{len(rows)} rows generated.")