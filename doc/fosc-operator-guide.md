# FOSC Oracle's Guide

An FOSC Oracle is a service provider of the oracle service to be consumed by the caller.

## Pre-requisite

-   [Whitelist](./developer-guide-whitelist.md) contract deployed 
-   [SeniToken](./developer-guide-senitoken.md) contract deployed

## Clone

```
    $ git clone https://github.com/SentinelChain/farmtrek-fosc-smartcontract 
    $ npm install
    $ mkdir flats
    $ npm run flatten
```
## Compile

1.  Launch http://remix.ethereum.org
2.  Open File: FOSCFlattened.sol
3.  Compile:
    - COMPILER: 0.6.12
    - EVM: byzantium
    - CONTRACT: FOSCFlattened.sol

## Deploy with Remix:
1. Shutdown Metamask chrome extension
2. Startup Nifty chrome extension
3. Go to Remix, select Deploy and Run Transcation:
   - ENVIRONMENT: Injected Web3
    Note: The network name under ENVIRONMENT should show Custom(7777) network otherwise something is wrong.
    - CONTRACT: FOSC - browser/FOSCFlattened.sol
    - DEPLOY:
        - _NEWORACLE: {Wallet address of oracle service with permission to update call status.}
        - _CALLVALUE: {Amount of SENI required to pay for this service. SENI is denominated with 18 0's. ie. 10 SENI = 10000000000000000000}
        - _TOKEN: {SENI token address. ie. For Orion, 0xC3E7623133c4E5f73e5068FbB85E492b74667C6a}
4. Note down the contract address from Remix.

## Register the Contract address with FOSC Listener

1. This step will create a MultiChain stream to receive API response from Farmtrek corresponding to the FOSC smart contract on Sentinel Chain. This step needs to run only once after the FOSC contract is deployed.
2. Go to FOSC Listener Api Portal: http://imda-demo.farmtrekadmin.com/index.html
3. Provide the FOSC contract address.
4. Take note of the stream name. This name will be used for querying MultiChain for oracle response.

Method: Get  
Endpoint: /Livestock/api/livestock/sentinelchain/stream?address={address}  
Input:  
- {address} is the address of the FOSC contract on Sentinel Chain. The address must be a valid 42 characters hexadecimal string preceded by "0x" representing an Ethereum address.  
Output:  
- The output is a string representing the Base64 stream name to receive response from MultiChain.  

For example,  
```
Input:  
/Livestock/api/livestock/sentinelchain/stream?address={0x90eada17f8cdcc4de6f48abc50c6bbfadda8de18}  
Output:  
kOraF/jNzE3m9Iq8UMa7+t2o3hg=  
```

## Whitelist the FOSC Contract address

1. Load up the whitelist contract (https://github.com/SentinelChain/orion-testnet/tree/master/contracts/shared)
2. FOSC contract address must be added to whitelist for it to receive SENI. 
3. The whitelist can only be performed by the whitelist operator.
