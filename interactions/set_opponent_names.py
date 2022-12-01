from starknet_py.contract import Contract
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.networks import TESTNET
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.models import StarknetChainId

import argparse
import asyncio

MAX_LEN_FELT = 31
def str_to_felt(text):
    if len(text) > MAX_LEN_FELT:
        raise Exception("Text length too long to convert to felt.")

    return int.from_bytes(text.encode(), "big")

async def main(contract_address, id, home_team, away_team):
  local_network_client = GatewayClient("http://localhost:5050")

  # new AccountClient using transaction version=1 (has __validate__ function)
  account_client_testnet = AccountClient(
    client=local_network_client,
    address="0x79e5dd61375d697da5cd29d25e2413ea75f88f9ffe3135640ce94086a00343d",
    key_pair=KeyPair(private_key=0x730eef721dfd8be60c1d02c677ff2816, public_key=0x2153f16098a8a543bbe70505e281013a65492e94fed95003fc9ff45f920c927),
    chain=StarknetChainId.TESTNET,
    supported_tx_version=1,
)

  # Create contract from contract's address - Contract will download contract's ABI to know its interface.
  contract = await Contract.from_address(contract_address, account_client_testnet)

  # All exposed functions are available at contract.functions.
  # Here we invoke a function, creating a new transaction.
  invocation = await contract.functions["set_match_teams_by_id"].invoke(id, home_team, away_team, max_fee=int(1e16))

  # Invocation returns InvokeResult object. It exposes a helper for waiting until transaction is accepted.
  await invocation.wait_for_acceptance()

  # Calling contract's function doesn't create a new transaction, you get the function's result.
  (home_team, away_team) = await contract.functions["get_match_oponents_by_id"].call(id)
  print(home_team)
  print(away_team)

if __name__ == '__main__':
  parser = parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
  parser.add_argument("--contract_address", help="0x...", required=True)
  parser.add_argument("--match_id", help="0-15", type=int, required=True)
  parser.add_argument("--home_team", help="France", required=True)
  parser.add_argument("--away_team", help="England", required=True)
    
  args = parser.parse_args()

  asyncio.run(main(args.contract_address, args.match_id, str_to_felt(args.home_team), str_to_felt(args.away_team)))
  

