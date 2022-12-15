from starknet_py.contract import Contract
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.networks import TESTNET2
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.models import StarknetChainId
from decouple import config

from starknet_py.cairo.felt import encode_shortstring, decode_shortstring

import asyncio

TESTNET2_ACCOUNT_ADDRESS = int(config('TESTNET2_ACCOUNT_ADDRESS'), 16)
TESTNET2_PRIVATE_KEY = int(config('TESTNET2_PRIVATE_KEY'), 16)
TESTNET2_PUBLIC_KEY = int(config('TESTNET2_PUBLIC_KEY'), 16)

async def set_match_date_by_id(contract, id, date):
  # All exposed functions are available at contract.functions.
  # Here we invoke a function, creating a new transaction.
  invocation = await contract.functions["set_match_date_by_id"].invoke(id, date, max_fee=int(1e16))

  # Invocation returns InvokeResult object. It exposes a helper for waiting until transaction is accepted.
  await invocation.wait_for_acceptance()

async def set_match_teams_by_id(contract, id, home_team, away_team):
  # All exposed functions are available at contract.functions.
  # Here we invoke a function, creating a new transaction.
  invocation = await contract.functions["set_match_teams_by_id"].invoke(id, home_team, away_team, max_fee=int(1e16))

  # Invocation returns InvokeResult object. It exposes a helper for waiting until transaction is accepted.
  await invocation.wait_for_acceptance()

async def set_match_result_by_id(contract, id, home_team, away_team):
  # All exposed functions are available at contract.functions.
  # Here we invoke a function, creating a new transaction.
  invocation = await contract.functions["set_match_result_by_id"].invoke(id, home_team, away_team, max_fee=int(1e16))

  # Invocation returns InvokeResult object. It exposes a helper for waiting until transaction is accepted.
  await invocation.wait_for_acceptance()

async def set_match_data_by_id(contract, id, date, home_team, away_team, score_ht, score_at):
  # All exposed functions are available at contract.functions.
  # Here we invoke a function, creating a new transaction.
  invocation = await contract.functions["set_match_data_by_id"].invoke(id, date, home_team, away_team, score_ht, score_at, max_fee=int(1e16))

  # Invocation returns InvokeResult object. It exposes a helper for waiting until transaction is accepted.
  await invocation.wait_for_acceptance()

async def main():
  network_client = GatewayClient(TESTNET2)

  # new AccountClient using transaction version=1 (has __validate__ function)
  account_client = AccountClient(
    client=network_client,
    address=TESTNET2_ACCOUNT_ADDRESS,
    key_pair=KeyPair(private_key=TESTNET2_PRIVATE_KEY, public_key=TESTNET2_PUBLIC_KEY),
    chain=StarknetChainId.TESTNET2,
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
  deploy_result = await declare_result.deploy(constructor_args=[TESTNET2_ACCOUNT_ADDRESS], max_fee=int(1e16))
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

  
  #await set_match_date_by_id(contract, 0, 1670079600) # 2022-12-03 15:00:00Z
  #await set_match_teams_by_id(contract, 0, encode_shortstring("Pays-Bas"), encode_shortstring("Etats-Unis"))
  #await set_match_result_by_id(contract, 0, 3, 1)
  await set_match_data_by_id(contract, 0, 1670079600, encode_shortstring("Netherlands"), encode_shortstring("USA"), 3, 1) 

  #await set_match_date_by_id(contract, 1, 1670094000) # 2022-12-03 19:00:00Z
  #await set_match_teams_by_id(contract, 1, encode_shortstring("Argentine"), encode_shortstring("Australie"))
  await set_match_data_by_id(contract, 1, 1670094000, encode_shortstring("Argentina"), encode_shortstring("Australia"), 2, 1)

  #await set_match_date_by_id(contract, 2, 1670166000) # 2022-12-04 15:00:00Z
  """await set_match_data_by_id(contract, 2, 1670166000, encode_shortstring("Japan"), encode_shortstring("Croatia"), 1, 1)

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
  await set_match_data_by_id(contract, 9, 1670612400, encode_shortstring("Croatia"), encode_shortstring("Brazil"), 1, 1)
  #await set_match_date_by_id(contract, 10, 1670684400) # 2022-12-10 15:00:00Z
  await set_match_data_by_id(contract, 10, 1670684400, encode_shortstring("England"), encode_shortstring("France"), 1, 2)
  #await set_match_date_by_id(contract, 11, 1670698800) # 2022-12-10 19:00:00Z
  await set_match_data_by_id(contract, 11, 1670698800, encode_shortstring("Morocco"), encode_shortstring("Portugal"), 1, 0)

  #await set_match_date_by_id(contract, 12, 1670958000) # 2022-12-13 19:00:00Z
  await set_match_data_by_id(contract, 12, 1670958000, encode_shortstring("Argentina"), encode_shortstring("Croatia"), 3, 0)
  #await set_match_date_by_id(contract, 13, 1671044400) # 2022-12-14 19:00:00Z
  await set_match_data_by_id(contract, 13, 1671044400, encode_shortstring("France"), encode_shortstring("Morocco"), 2, 0)

  await set_match_date_by_id(contract, 14, 1671289200) # 2022-12-17 15:00:00Z

  await set_match_date_by_id(contract, 15, 1671375600) # 2022-12-18 15:00:00Z"""

asyncio.run(main())

