# Takes a default genesis and creates a new modified genesis file.
#
# sh network/loop-1/from_scratch.sh
#

CHAIN_ID=loop-1

make install

export HOME_DIR=$(eval echo "${HOME_DIR:-"~/.loopchain"}")

rm -rf $HOME_DIR && echo "Removed $HOME_DIR"

loopd init moniker --chain-id=$CHAIN_ID --default-denom=upoa --home $HOME_DIR

update_genesis () {
    cat $HOME_DIR/config/genesis.json | jq "$1" > $HOME_DIR/config/tmp_genesis.json && mv $HOME_DIR/config/tmp_genesis.json $HOME_DIR/config/genesis.json
}

update_genesis '.app_version="1.0.0"'

update_genesis '.consensus["params"]["block"]["max_gas"]="-1"'
update_genesis '.consensus["params"]["abci"]["vote_extensions_enable_height"]="1"'

# auth
update_genesis '.app_state["auth"]["params"]["max_memo_characters"]="512"'

update_genesis '.app_state["bank"]["denom_metadata"]=[
        {
            "base": "upoa",
            "denom_units": [
            {
                "aliases": [],
                "denom": "upoa",
                "exponent": 0
            },
            {
                "aliases": [],
                "denom": "POA",
                "exponent": 6
            }
            ],
            "description": "Denom metadata for POA Power (upoa)",
            "display": "POA",
            "name": "POA",
            "symbol": "POA"
        }
]'

update_genesis '.app_state["crisis"]["constant_fee"]={"denom": "token","amount": "1000000000"}'

update_genesis '.app_state["distribution"]["params"]["community_tax"]="0.000000000000000000"'

update_genesis '.app_state["gov"]["params"]["min_deposit"]=[{"denom":"token","amount":"100000000"}]'
update_genesis '.app_state["gov"]["params"]["max_deposit_period"]="259200s"'
update_genesis '.app_state["gov"]["params"]["voting_period"]="259200s"'
update_genesis '.app_state["gov"]["params"]["expedited_min_deposit"]=[{"denom":"token","amount":"1000000000"}]'
update_genesis '.app_state["gov"]["params"]["min_deposit_ratio"]="0.100000000000000000"' # 10%

update_genesis '.app_state["mint"]["minter"]["inflation"]="0.000000000000000000"'
update_genesis '.app_state["mint"]["minter"]["annual_provisions"]="0.000000000000000000"'
update_genesis '.app_state["mint"]["params"]["mint_denom"]="token"'
update_genesis '.app_state["mint"]["params"]["inflation_rate_change"]="0.000000000000000000"'
update_genesis '.app_state["mint"]["params"]["inflation_max"]="0.000000000000000000"'
update_genesis '.app_state["mint"]["params"]["inflation_min"]="0.000000000000000000"'
update_genesis '.app_state["mint"]["params"]["blocks_per_year"]="12623040"' # 3s blocks (( 6s blocks = 6311520 per year ))

update_genesis '.app_state["slashing"]["params"]["signed_blocks_window"]="30000"'
update_genesis '.app_state["slashing"]["params"]["min_signed_per_window"]="0.010000000000000000"'
update_genesis '.app_state["slashing"]["params"]["downtime_jail_duration"]="60s"'
update_genesis '.app_state["slashing"]["params"]["slash_fraction_double_sign"]="1.000000000000000000"'
update_genesis '.app_state["slashing"]["params"]["slash_fraction_downtime"]="0.000000000000000000"'

update_genesis '.app_state["staking"]["params"]["bond_denom"]="upoa"'

update_genesis '.app_state["tokenfactory"]["params"]["denom_creation_fee"]=[]'
update_genesis '.app_state["tokenfactory"]["params"]["denom_creation_gas_consume"]="250000"'

update_genesis '.app_state["wasm"]["params"]["code_upload_access"]["permission"]="AnyOfAddresses"'
update_genesis '.app_state["wasm"]["params"]["instantiate_default_permission"]="AnyOfAddresses"'
update_genesis '.app_state["wasm"]["params"]["code_upload_access"]["addresses"]=["loop1v4ngsp3xemjhdle8hz3vvlecv6ej4reeys6m3t","loop1j0dzk6apfpkh5ug7ykkgx34wnps2jszhxu029q"]'


# gov, addrFromTom
update_genesis '.app_state["poa"]["params"]["admins"]=["loop10d07y265gmmuvt4z0w9aw880jnsr700j4m0ya0", "loop1v4ngsp3xemjhdle8hz3vvlecv6ej4reeys6m3t"]'

# add genesis accounts
loopd genesis add-genesis-account loop1v4ngsp3xemjhdle8hz3vvlecv6ej4reeys6m3t 5000000000000token --append # tom / authority
loopd genesis add-genesis-account loop1j0dzk6apfpkh5ug7ykkgx34wnps2jszhxu029q 5000000000000token --append # shared cosmwasm addr

# TODO: not tested yet
# iterate through the gentx directory, print the files
# https://github.com/strangelove-ventures/bech32cli
for filename in gentx/*.json; do
    addr=`cat $filename | jq -r .body.messages[0].validator_address | xargs -I {} bech32 transform {} loop`
    raw_coin=`cat $filename | jq -r .body.messages[0].value` # { "denom": "upoa", "amount": "1000000" }
    coin=$(echo $raw_coin | jq -r '.amount + .denom') # make coin = 1000000upoa
    loopd genesis add-genesis-account $addr $coin,10000000token --append # also gives 10 TOKENS (not sure if this is desired)
done
loopd genesis collect-gentxs --gentx-dir network/loop-1/gentx --home $HOME/.loopchain


cp ~/.loopchain/config/genesis.json ./network/$CHAIN_ID/genesis.json