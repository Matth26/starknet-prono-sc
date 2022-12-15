from starknet_py.contract import Contract
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.networks import TESTNET2
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.models import StarknetChainId
from decouple import config

from starknet_py.cairo.felt import encode_shortstring, decode_shortstring

import asyncio

LOCALHOST_ACCOUNT_ADDRESS = int(config('LOCALHOST_ACCOUNT_ADDRESS'), 16)
LOCALHOST_PRIVATE_KEY = int(config('LOCALHOST_PRIVATE_KEY'), 16)
LOCALHOST_PUBLIC_KEY = int(config('LOCALHOST_PUBLIC_KEY'), 16)

async def set_match_date_by_id(contract, id, date):
  # All exposed functions are available at contract.functions.
  # Here we invoke a function, creating a new transaction.
  invocation = await contract.functions["set_match_date_by_id"].invoke(id, date, max_fee=int(1e16))

  # Invocation returns InvokeResult object. It exposes a helper for waiting until transaction is accepted.
  await invocation.wait_for_acceptance()

async def set_match_teams_by_id(contract, id, home_team, away_team):
  invocation = await contract.functions["set_match_teams_by_id"].invoke(id, home_team, away_team, max_fee=int(1e16))
  await invocation.wait_for_acceptance()

async def set_match_result_by_id(contract, id, home_team, away_team):
  invocation = await contract.functions["set_match_result_by_id"].invoke(id, home_team, away_team, max_fee=int(1e16))
  await invocation.wait_for_acceptance()

async def set_match_data_by_id(contract, id, date, home_team, away_team, score_ht, score_at):
  invocation = await contract.functions["set_match_data_by_id"].invoke(id, date, home_team, away_team, score_ht, score_at, max_fee=int(1e16))
  await invocation.wait_for_acceptance()

async def set_match_bet_by_id(contract, id, home_team, away_team):
  invocation = await contract.functions["set_match_bet_by_id"].invoke(id, home_team, away_team, max_fee=int(1e16))
  await invocation.wait_for_acceptance()

async def get_users_len(contract):
  result = await contract.functions["get_users_len"].call()
  print(result.len)

async def get_user_bet_by_id(contract, user_address, id):
  result = await contract.functions["get_user_bet_by_id"].call(user_address, id)
  print(result)

async def get_user_points_by_id(contract, user_address, id):
  result = await contract.functions["get_user_points_by_id"].call(user_address, id)
  print(result.points)

async def get_user_points(contract, user_address):
  result = await contract.functions["get_user_points"].call(user_address)
  print(result.points)


async def main():
  network_client = GatewayClient("http://localhost:5050")

  # new AccountClient using transaction version=1 (has __validate__ function)
  account_client = AccountClient(
    client=network_client,
    address=LOCALHOST_ACCOUNT_ADDRESS,
    key_pair=KeyPair(private_key=LOCALHOST_PRIVATE_KEY, public_key=LOCALHOST_PUBLIC_KEY),
    chain=StarknetChainId.TESTNET,
    supported_tx_version=1,
)

  file = open("./artifacts/prono.json", "r")
  compiled_contract = file.read()
  file.close()

  # To declare through Contract class you have to compile a contract and pass it to the Contract.declare
  declare_result = await Contract.declare(
      account=account_client, compiled_contract=compiled_contract, max_fee=int(1e16)
  )
  # Wait until deployment transaction is accepted
  await declare_result.wait_for_acceptance()

  # After contract is declared it can be deployed
  deploy_result = await declare_result.deploy(constructor_args=[LOCALHOST_ACCOUNT_ADDRESS], max_fee=int(1e16))
  await deploy_result.wait_for_acceptance()

# You can pass more arguments to the `deploy` method. Check `API` section to learn more

  # To interact with just deployed contract get its instance from the deploy_result
  contract = deploy_result.deployed_contract
  print(hex(contract.address))

  """
  result = await asyncio.gather(
    set_match_date_by_id(contract, 0, 1670079600),  # 2022-12-03 15:00:00Z
    set_match_teams_by_id(contract, 0, encode_shortstring("Pays-Bas"), encode_shortstring("Etats-Unis")),
  
    set_match_date_by_id(contract, 1, 1670094000), # 2022-12-03 19:00:00Z
    set_match_teams_by_id(contract, 1, encode_shortstring("Argentine"), encode_shortstring("Australie"))
  )
  """

  
  """#await set_match_date_by_id(contract, 0, 1670079600) # 2022-12-03 15:00:00Z
  #await set_match_teams_by_id(contract, 0, encode_shortstring("Pays-Bas"), encode_shortstring("Etats-Unis"))
  #await set_match_result_by_id(contract, 0, 3, 1)
  await set_match_data_by_id(contract, 0, 1670079600, encode_shortstring("Netherlands"), encode_shortstring("USA"), 3, 1) 

  #await set_match_date_by_id(contract, 1, 1670094000) # 2022-12-03 19:00:00Z
  #await set_match_teams_by_id(contract, 1, encode_shortstring("Argentine"), encode_shortstring("Australie"))
  await set_match_data_by_id(contract, 1, 1670094000, encode_shortstring("Argentina"), encode_shortstring("Australia"), 2, 1)

  #await set_match_date_by_id(contract, 2, 1670166000) # 2022-12-04 15:00:00Z
  await set_match_data_by_id(contract, 2, 1670166000, encode_shortstring("Japan"), encode_shortstring("Croatia"), 1, 1)

  #await set_match_date_by_id(contract, 3, 1670180400) # 2022-12-04 19:00:00Z
  await set_match_data_by_id(contract, 3, 1670180400, encode_shortstring("Brazil"), encode_shortstring("South Korea"), 4, 1)
  #await set_match_date_by_id(contract, 4, 1670252400) # 2022-12-05 15:00:00Z
  await set_match_data_by_id(contract, 4, 1670252400, encode_shortstring("England"), encode_shortstring("Senegal"), 3, 0)
  #await set_match_date_by_id(contract, 5, 1670266800) # 2022-12-05 19:00:00Z
  await set_match_data_by_id(contract, 5, 1670266800, encode_shortstring("France"), encode_shortstring("Poland"), 3, 1)
  #await set_match_date_by_id(contract, 6, 1670338800) # 2022-12-06 19:00:00Z
  await set_match_data_by_id(contract, 6, 1670338800, encode_shortstring("Morocco"), encode_shortstring("Spain"), 0, 0)
  #await set_match_date_by_id(contract, 7, 1670353200) # 2022-12-06 19:00:00Z
  await set_match_data_by_id(contract, 7, 1670353200, encode_shortstring("Portugal"), encode_shortstring("Switzerland"), 6, 1)

  #await set_match_date_by_id(contract, 8, 1670598000) # 2022-12-09 15:00:00Z
  await set_match_data_by_id(contract, 8, 1670598000, encode_shortstring("Netherlands"), encode_shortstring("Argentina"), 2, 2)
  #await set_match_date_by_id(contract, 9, 1670612400) # 2022-12-09 19:00:00Z
  await set_match_data_by_id(contract, 9, 1670612400, encode_shortstring("Croatia"), encode_shortstring("Brazil"), 1, 1)"""
  #await set_match_date_by_id(contract, 10, 1670684400) # 2022-12-10 15:00:00Z
  await set_match_data_by_id(contract, 10, 1670684400, encode_shortstring("England"), encode_shortstring("France"), 1, 2)
  #await set_match_date_by_id(contract, 11, 1670698800) # 2022-12-10 19:00:00Z
  await set_match_data_by_id(contract, 11, 1670698800, encode_shortstring("Morocco"), encode_shortstring("Portugal"), 1, 0)

  #await set_match_date_by_id(contract, 12, 1670958000) # 2022-12-13 19:00:00Z
  await set_match_data_by_id(contract, 12, 1670958000, encode_shortstring("Argentina"), encode_shortstring("Croatia"), 3, 0)
  #await set_match_date_by_id(contract, 13, 1671044400) # 2022-12-14 19:00:00Z
  await set_match_data_by_id(contract, 13, 1671044400, encode_shortstring("France"), encode_shortstring("Morocco"), 2, 0)

  await set_match_date_by_id(contract, 14, 1671289200) # 2022-12-17 15:00:00Z

  await set_match_date_by_id(contract, 15, 1671375600) # 2022-12-18 15:00:00Z

  #await get_users_len(contract)

  await set_match_bet_by_id(contract, 10, 1, 2)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 10)
  print("should be 3")
  await set_match_bet_by_id(contract, 11, 2, 1)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 11)
  print("should be 2")
  await set_match_bet_by_id(contract, 12, 1, 0)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 12)
  print("should be 1")
  await set_match_bet_by_id(contract, 13, 0, 2)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 13)
  print("should be 0")

  print(" ")
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 0)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 1)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 2)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 3)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 4)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 5)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 6)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 7)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 8)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 9)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 10)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 11)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 12)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 13)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 14)
  await get_user_points_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 15)
  print(" ")


  #await get_users_len(contract)

  await get_user_points(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d);

  await get_user_bet_by_id(contract, 0x27caf40c6fb8fb5e134a9687b9485d02f33642fd5dd6200f1eadab02822291d, 15)

asyncio.run(main())

