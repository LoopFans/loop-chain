export LOOPD_NODE=http://127.0.0.1:26657
USER1_FLAGS="--from=user1 --chain-id=local-1 --node=$LOOPD_NODE --gas=auto --gas-adjustment=1.5 --gas-prices=0upoa --yes --keyring-backend=test"
USER2_FLAGS="--from=user2 --chain-id=local-1 --node=$LOOPD_NODE --gas=auto --gas-adjustment=1.5 --gas-prices=0upoa --yes --keyring-backend=test"

loopd tx wasm store ./interchaintest/contracts/cw_template.wasm --instantiate-anyof-addresses=loop1hj5fveer5cjtn4wd6wstzugjfdxzl0xpf4wn8l $USER1_FLAGS

loopd q wasm codes

# INIT FROM THAT ABOVE ADDRESS
loopd tx wasm instantiate 1 '{"count":0}' --label=cwtemplate $USER1_FLAGS --no-admin

# NOT AUTHORIZED CHECKS
loopd tx wasm store ./interchaintest/contracts/cw_template.wasm $USER2_FLAGS
loopd tx wasm instantiate 1 '{"count":0}' --label=cwtemplate $USER2_FLAGS --no-admin