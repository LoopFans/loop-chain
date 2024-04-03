# Testnet Genesis

# Post Genesis Validators
If you are a validator joining the network after the initial genesis launch, follow the [post genesis document here](./POST_GENESIS.md).

## Hardware Requirements
**Minimal**
* 4 GB RAM
* 100 GB SSD
* 3.2 x4 GHz CPU

**Recommended**
* 8 GB RAM
* 100 GB NVME SSD
* 4.2 GHz x6 CPU

**Operating System**
* Linux (x86_64) or Linux (amd64) Recommended Arch Linux

### Dependencies
>Prerequisite: go1.21+, git, gcc, make, jq

**Arch Linux:**
```
pacman -S go git gcc make
```

**Ubuntu Linux:**
```
sudo snap install go --classic
sudo apt-get install git gcc make jq
```

## loopd Installation Steps

```bash
# Clone git repository
git clone https://github.com/LoopFans/loop-chain.git
cd loop-chain
git checkout <version>

make install # go install ./...
# For ledger support `go install -tags ledger ./...`

loopd config set client chain-id loop-1
```

### Generate keys
* `loopd keys add [key_name]`
* `loopd keys add [key_name] --recover` to regenerate keys with your BIP39 mnemonic to add ledger key
* `loopd keys add [key_name] --ledger` to add a ledger key

# Validator setup instructions
## Genesis Tx:
```bash
# Validator variables
KEYNAME='validator' # your keyname
MONIKER='pbcups'
SECURITY_CONTACT="email@domain.com"
WEBSITE="https://domain.com"
MAX_RATE='0.20'        # 20%
COMMISSION_RATE='0.00' # 0%
MAX_CHANGE='0.01'      # 1%
CHAIN_ID='loop-1'
PROJECT_HOME="${HOME}/.loopchain"
KEYNAME_ADDR=$(loopd keys show $KEYNAME -a)

# Remove old files if they exist
loopd tendermint unsafe-reset-all
rm $HOME/.loopchain/config/genesis.json
rm $HOME/.loopchain/config/gentx/*.json

# Give yourself 1POASTAKE for the genesis Tx signed
loopd init "$MONIKER" --chain-id $CHAIN_ID --default-denom poastake
loopd genesis add-genesis-account $KEYNAME_ADDR 1000000poastake --append

# genesis transaction using all above variables
loopd genesis gentx $KEYNAME 1000000poastake \
    --home=$PROJECT_HOME \
    --chain-id=$CHAIN_ID \
    --moniker="$MONIKER" \
     --commission-max-change-rate=$MAX_CHANGE \
    --commission-max-rate=$MAX_RATE \
    --commission-rate=$COMMISSION_RATE \
    --security-contact=$SECURITY_CONTACT \
    --website=$WEBSITE \
    --details=""

# Get that gentx data easily -> your home directory
cat ${PROJECT_HOME}/config/gentx/gentx-*.json

# get your peer
echo $(loopd tendermint show-node-id)@$(curl -s ifconfig.me):26656
```