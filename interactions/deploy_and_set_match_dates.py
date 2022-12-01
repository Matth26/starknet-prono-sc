from starknet_py.contract import Contract
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.networks import TESTNET
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.models import StarknetChainId

import asyncio
import json

async def set_match_date_by_id(contract, id, date):
  # All exposed functions are available at contract.functions.
  # Here we invoke a function, creating a new transaction.
  invocation = await contract.functions["set_match_date_by_id"].invoke(id, date, max_fee=int(1e16))

  # Invocation returns InvokeResult object. It exposes a helper for waiting until transaction is accepted.
  await invocation.wait_for_acceptance()

async def main():
  local_network_client = GatewayClient("http://localhost:5050")

  # new AccountClient using transaction version=1 (has __validate__ function)
  account_client_testnet = AccountClient(
    client=local_network_client,
    address="0x79e5dd61375d697da5cd29d25e2413ea75f88f9ffe3135640ce94086a00343d",
    key_pair=KeyPair(private_key=0x730eef721dfd8be60c1d02c677ff2816, public_key=0x2153f16098a8a543bbe70505e281013a65492e94fed95003fc9ff45f920c927),
    chain=StarknetChainId.TESTNET,
    supported_tx_version=1,
)

  # Deploy an example contract which implements a simple k-v store. Deploy transaction is not being signed.
  deployment_result = await Contract.deploy(
      client=account_client_testnet, compilation_source=['./contracts/prono.cairo']
  )
  # Wait until deployment transaction is accepted
  await deployment_result.wait_for_acceptance()

  # Get deployed contract
  contract = deployment_result.deployed_contract
  print(hex(contract.address))

  await set_match_date_by_id(contract, 0, 1670079600) # 2022-12-03 15:00:00Z
  await set_match_date_by_id(contract, 1, 1670094000) # 2022-12-03 19:00:00Z
  await set_match_date_by_id(contract, 2, 1670166000) # 2022-12-04 15:00:00Z
  await set_match_date_by_id(contract, 3, 1670180400) # 2022-12-04 19:00:00Z
  await set_match_date_by_id(contract, 4, 1670252400) # 2022-12-05 15:00:00Z
  await set_match_date_by_id(contract, 5, 1670266800) # 2022-12-05 19:00:00Z
  await set_match_date_by_id(contract, 6, 1670338800) # 2022-12-06 19:00:00Z
  await set_match_date_by_id(contract, 7, 1670353200) # 2022-12-06 19:00:00Z

  await set_match_date_by_id(contract, 8, 1670598000) # 2022-12-09 15:00:00Z
  await set_match_date_by_id(contract, 9, 1670612400) # 2022-12-09 19:00:00Z
  await set_match_date_by_id(contract, 10, 1670684400) # 2022-12-10 15:00:00Z
  await set_match_date_by_id(contract, 11, 1670698800) # 2022-12-10 19:00:00Z

  await set_match_date_by_id(contract, 12, 1670958000) # 2022-12-13 19:00:00Z
  await set_match_date_by_id(contract, 13, 1671044400) # 2022-12-14 19:00:00Z

  await set_match_date_by_id(contract, 14, 1671289200) # 2022-12-17 15:00:00Z

  await set_match_date_by_id(contract, 15, 1671375600) # 2022-12-18 15:00:00Z

  # Calling contract's function doesn't create a new transaction, you get the function's result.
  (result) = await contract.functions["get_match_date_by_id"].call(0)
  print(result.date)

asyncio.run(main())

