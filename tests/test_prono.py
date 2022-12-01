"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet

def felt_to_str(felt):
    length = (felt.bit_length() + 7) // 8
    return felt.to_bytes(length, byteorder="big").decode("utf-8")

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "contract.cairo")


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_set_match_teams_by_id():
    """Test test_set_match_teams_by_id method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    await contract.set_match_teams_by_id(id=1, home_team=77457074840421, away_team=19543163872046692).execute()

    execution_info = await contract.get_match_oponents_by_id(id=1).call()
    assert execution_info.result == (77457074840421,19543163872046692)

    execution_info = await contract.get_match_oponents_by_id(id=0).call()
    assert execution_info.result == (0,0)