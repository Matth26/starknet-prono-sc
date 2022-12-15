# Interactions

First create a .env file with your testnet2 account:

```
TESTNET2_ACCOUNT_ADDRESS=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
TESTNET2_PRIVATE_KEY=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
TESTNET2_PUBLIC_KEY=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
```

`python3.9 interactions/set_opponent_names_testnet2.py --contract_address 0x07127eb28010fea8ad50f948a43199802ee6028b5ba28f3d90c5abcc6cf48d74 --match_id 6 --home_team aaaaaa --away_team bbbbbb`