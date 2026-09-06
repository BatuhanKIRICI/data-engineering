orders = [
    {"order_id": 101, "customer": "Ali", "country": "DE", "amount": 120},
    {"order_id": 102, "customer": "Anna", "country": "DE", "amount": 80},
    {"order_id": 103, "customer": "John", "country": "US", "amount": 200},
    {"order_id": 104, "customer": "Ali", "country": "DE", "amount": 50},
    {"order_id": 105, "customer": "Maria", "country": "DE", "amount": 300},
    {"order_id": 106, "customer": "John", "country": "US", "amount": 100},
]
# --------------------------------------------------------
# for x in range(len(orders)):
#     if orders[x]['country'] == 'DE':
#         print(orders[x])
# --------------------------------------------------------
# for order in orders:
#   if order['country'] == 'DE':
#       print(order)
# --------------------------------------------------------
# total_amount = 0

# for order in orders:
#     total_amount += order['amount']

# print(total_amount)
# --------------------------------------------------------
# total_germany = 0

# for order in orders:
#     if order['country'] == 'DE':
#         total_germany += order['amount']

# print(total_germany)
# --------------------------------------------------------
# totals = {}

# for order in orders:

#     customer = order['customer']
#     amount = order['amount']

#     if customer in totals:
#         totals[customer] += amount
#     else:
#         totals[customer] = amount

# print(totals)
# --------------------------------------------------------
# totals = {}
# max_amount = 0

# for order in orders:
#     customer = order['customer']
#     amount = order['amount']

#     if customer in totals:
#         totals[customer] += amount
#     else:
#         totals[customer] = amount

# max_customer = None
# max_amount = 0

# for customer, amount in totals.items():
#     if amount > max_amount:
#         max_amount = amount
#         max_customer = customer

# print(max_customer, max_amount)
# --------------------------------------------------------
totals = {}
max_amount = 0

for order in orders:
    customer = order['customer']
    amount = order['amount']

    if customer in totals:
        totals[customer] += amount
    else:
        totals[customer] = amount

sorted_totals = sorted(totals.items(), key=lambda x:x[1],reverse=True)

print(sorted_totals)




























