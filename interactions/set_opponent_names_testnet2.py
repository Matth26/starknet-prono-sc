from starknet_py.contract import Contract
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.networks import TESTNET2
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.models import StarknetChainId
from decouple import config

import argparse
import asyncio

TESTNET2_ACCOUNT_ADDRESS = int(config('TESTNET2_ACCOUNT_ADDRESS'), 16)
TESTNET2_PRIVATE_KEY = int(config('TESTNET2_PRIVATE_KEY'), 16)
TESTNET2_PUBLIC_KEY = int(config('TESTNET2_PUBLIC_KEY'), 16)

MAX_LEN_FELT = 31
def str_to_felt(text):
  if len(text) > MAX_LEN_FELT:
    raise Exception("Text length too long to convert to felt.")

  return int.from_bytes(text.encode(), "big")

def felt_to_str(felt):
  length = (felt.bit_length() + 7) // 8
  return felt.to_bytes(length, byteorder="big").decode("utf-8")

async def main(contract_address, id, home_team, away_team):
  network_client = GatewayClient(TESTNET2) #GatewayClient("http://localhost:5050")

  # new AccountClient using transaction version=1 (has __validate__ function)
  account_client = AccountClient(
    client=network_client,
    address=TESTNET2_ACCOUNT_ADDRESS,
    key_pair=KeyPair(private_key=TESTNET2_PRIVATE_KEY, public_key=TESTNET2_PUBLIC_KEY),
    chain=StarknetChainId.TESTNET2,
    supported_tx_version=1,
)

  # Create contract from contract's address - Contract will download contract's ABI to know its interface.
  contract = await Contract.from_address(contract_address, account_client)

  # All exposed functions are available at contract.functions.
  # Here we invoke a function, creating a new transaction.
  invocation = await contract.functions["set_match_teams_by_id"].invoke(id, home_team, away_team, max_fee=int(1e16))

  # Invocation returns InvokeResult object. It exposes a helper for waiting until transaction is accepted.
  await invocation.wait_for_acceptance()

  # Calling contract's function doesn't create a new transaction, you get the function's result.
  (home_team, away_team) = await contract.functions["get_match_oponents_by_id"].call(id)
  print(felt_to_str(home_team))
  print(felt_to_str(away_team))

if __name__ == '__main__':
  parser = parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
  parser.add_argument("--contract_address", help="0x...", required=True)
  parser.add_argument("--match_id", help="0-15", type=int, required=True)
  parser.add_argument("--home_team", help="France", required=True)
  parser.add_argument("--away_team", help="England", required=True)
    
  args = parser.parse_args()

  asyncio.run(main(args.contract_address, args.match_id, str_to_felt(args.home_team), str_to_felt(args.away_team)))
  

