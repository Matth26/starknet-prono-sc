# Frontend part

Here is the react repo for the frontend part:
https://github.com/Matth26/starknet-prono-front

# Interactions

First create a .env file with your accounts:

```
TESTNET_ACCOUNT_ADDRESS=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
TESTNET_PRIVATE_KEY=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
TESTNET_PUBLIC_KEY=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef

TESTNET2_ACCOUNT_ADDRESS=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
TESTNET2_PRIVATE_KEY=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
TESTNET2_PUBLIC_KEY=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef

LOCALHOST_ACCOUNT_ADDRESS=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
LOCALHOST_PRIVATE_KEY=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
LOCALHOST_PUBLIC_KEY=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
```

## Deploy and setup
`python3.9 interactions/deploy_and_set_match_data_localhost.py`
or 
`python3.9 interactions/deploy_and_set_match_data_testnet2.py`

## Set team names
`python3.9 interactions/set_opponent_names_testnet2.py --contract_address 0x07127eb28010fea8ad50f948a43199802ee6028b5ba28f3d90c5abcc6cf48d74 --match_id 6 --home_team aaaaaa --away_team bbbbbb`

`python3.9 interactions/set_match_result_testnet2.py --contract_address 0x07127eb28010fea8ad50f948a43199802ee6028b5ba28f3d90c5abcc6cf48d74 --match_id 6 --home_team 0 --away_team 3`