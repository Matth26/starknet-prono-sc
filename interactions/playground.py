from starknet_py.contract import Contract
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.networks import TESTNET
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.models import StarknetChainId

import asyncio
import json

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
  """deployment_result = await Contract.deploy(
      client=account_client_testnet, compilation_source=['./contracts/prono.cairo']
  )
  # Wait until deployment transaction is accepted
  await deployment_result.wait_for_acceptance()

  # Get deployed contract
  contract = deployment_result.deployed_contract
  print(hex(contract.address))"""
  # Create contract from contract's address - Contract will download contract's ABI to know its interface.
  contract = await Contract.from_address("0x2acfe81d1877eb07bd237c00244f7fa245adc9953c6ad4756746f0e8f95571f", account_client_testnet)

  # All exposed functions are available at contract.functions.
  # Here we invoke a function, creating a new transaction.
  invocation = await contract.functions["set_match_teams_by_id"].invoke(2, 77457074840421, 19543163872046692, max_fee=int(1e16))

  # Invocation returns InvokeResult object. It exposes a helper for waiting until transaction is accepted.
  await invocation.wait_for_acceptance()

  # Calling contract's function doesn't create a new transaction, you get the function's result.
  (home_team, away_team) = await contract.functions["get_match_oponents_by_id"].call(2)
  print(home_team)
  print(away_team)

asyncio.run(main())