# Caller's Guide to querying FarmTrek Livestock Info via Sentinel Chain

The caller is a consumer of the oracle service.

## Step 1: Run FOSC contract using SENI Contract

1.  Load SeniToken contract (https://github.com/SentinelChain/orion-testnet/tree/master/contracts/token) from 0xC3E7623133c4E5f73e5068FbB85E492b74667C6a (on Orion Testnet)
2.  Make sure there are sufficient SENI in your balance to pay for the call.
3.  Run TransferAndCall:
    _to: 0x3dc7401f2d56d6355a332313ef67b1e6848b1874 (FOSC Contract Address on Orion Testnet)
    _value:10000000000000000000 (default 10 SENI)
    _data: {hexadecimal string representing the 16 character serial number of livestock tag}

## Step 2: Listen for NewApiCall event
1.  Extract the CallId from the event corresponding to the TransferAndCall transaction.
Note: This CallId is unique and will be used to redeem for the response.

## Step 3: Listen for LogCallFinished event
1.  Filter events containing the CallId that you need.
2.  Extract the MultiChain transaction id ("txid") and the rsa encrypted aes key ("secret")

NOTE:
The following step is made between the FOSC listener service (oracle) and the FOSC responder service (Provider). 
It does not involve the caller. 

Method: Put  
Endpoint: /Livestock/api/livestock/sentinelchain/fosc  
Input:  
{  
  "serialNo": {16 char serial number},  
  "contractAddress": {address of oracle smart contract on Sentinel Chain},  
  "callerId": {unique id per caller},  
  "rsaKey": {rsa public key},  
  "nonce": {unique id per session}  
}  
Output: 
{
 "txid": hexadecimal string representing the transaction Id for the result published on MultiChain,
 "secret": base64 rsa encrypted secret. The secret is used to AES decrypt the payload from multichain.
}

Example:
```
Input:  
{
  "serialNo": "0000000000000263",
  "contractAddress": "0x90eada17f8cdcc4de6f48abc50c6bbfadda8de18",
  "callerId": "0x574366e84f74f2e913aD9A6782CE6Ac8022e16EB",
  "rsaKey": "-----BEGIN PUBLIC KEY-----\n\rMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDpHWzmlAg9mvoBScq7t2YPVM5q\n\raYwi/MoCHDxtkSogWXfRvJ0MItG2DpyZVVxr+IvMs934JMLDvzKUZuBny+2qG/bF\n\ryyyDhKDpG6l9IadzonMwLTg7VdYqnJjcTC+SgcxqQJAl3Lnu+PyGuU/CJb6WptHV\n\rabXtwjLooZCjle+cawIDAQAB\n\r-----END PUBLIC KEY-----",
  "nonce": "2"
}

Output:
{
  "txid":"25e4f77ff77535b6ce1cb36b49597e9f18199d462d736933e2fc69dea61a9c90",  "secret":"0bE0c4SgDP1t+iEOJD3VBzgs1gUExNjnWDUPB6lX4cNJ7VQV+jJCkFxjSBT8noPc8dHNiwCy2QrLg1FwIjo5ihOvTy5+djTUR95bA/AYaJ6YuX6LRSDAeMqdRbzA6biOtrFsvopfMwG6zf+Nim5578xNTsYwrU94QR44tsEccJc="
}
```
**NOTE**
The rsakey is created when caller sign up for the oracle's service in the beginning.
If rsakey is not provided then the result will be published in the clear on Multichain

## Step 4: Get the result from MultiChain
1. Login to the multichain node
2. In order to read from a multichain stream, you need to subscribe to it once to the streamName once.
   Use the command subscribe {streamName} from multichain-cli
3. Retrieve the streamitem using the command:
   getstreamitem {streamName} {txid} where streamName is the name receied from step 1 and txied is the output received from step 2.

**NOTE: **

This is only for illlustration sake and not how the real world behaves. The response will not be stored entirely on the blockchain, even in its encrypted state.

Example:  
```
multichain-cli> subscribe \"kOraF/jNzE3m9Iq8UMa7+t2o3hg==\"
multichain-cli> getstreamitem \"kOraF/jNzE3m9Iq8UMa7+t2o3hg==\" 25e4f77ff77535b6ce1cb36b49597e9f18199d462d736933e2fc69dea61a9c90

Output:
{
  "Keys": [
    "0x574366e84f74f2e913aD9A6782CE6Ac8022e16EB"
  ],
  "Data": {
    "callerId": "0x574366e84f74f2e913aD9A6782CE6Ac8022e16EB",
    "nonce": "2",
    "payload": "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"
  },
  "Publisher": "1FLrFFMqzqQ3XappUNmEGjSToVnLwdFAwfyPEq"
}

```


## Step 5: Decode the payload

1. Decrypt the secret received from step 2 using the RSA private key.
2. Use the decrypted secret to AES decrypt the payload.
The decoded response should be in the form.  
``` 
{
  "Id": "02d75f41-8b83-447a-80c7-b05e15917bcb",
  "EncryptionId": null,
  "IsActive": false,
  "CreatedAt": "0001-01-01T00:00:00",
  "UpdatedAt": "0001-01-01T00:00:00",
  "Name": "pabna 198",
  "SerialNumber": "0000000000000263",
  "Sex": "M",
  "MonthOfBirth": 9,
  "YearOfBirth": 2019,
  "Length": 181.0,
  "Height": 121.0,
  "Weight": 290.0,
  "ChestGirth": 74.0,
  "LengthUom": "cm",
  "WeightUom": "Kg",
  "DeathReason": "",
  "DeathDate": "0001-01-01T00:01:00",
  "LivestockCategory": {
    "Category": "Cattle",
    "IsActive": true,
    "CreatedAt": "2020-02-07T18:18:24",
    "UpdatedAt": "2020-02-07T18:18:24",
    "Id": "1e11d367-0867-4fbf-9afa-f9ee624b50b9"
  },
  "LivestockType": {
    "Type": "Draught",
    "IsActive": true,
    "CreatedAt": "2020-02-07T18:18:24",
    "UpdatedAt": "2020-02-07T18:18:24",
    "Id": "5cfea6b7-8d6a-4bfd-8f6c-e4cd4a38dc33"
  },
  "LivestockBreed": {
    "Breed": "CrossBreed",
    "IsActive": true,
    "CreatedAt": "2020-02-07T18:18:24",
    "UpdatedAt": "2020-02-07T18:18:24",
    "Id": "d829c8b9-8c3a-401c-8153-a83037b78ad9"
  },
  "LivestockLiveStatus": {
    "Status": "Live",
    "IsActive": true,
    "CreatedAt": "2020-02-07T18:18:24",
    "UpdatedAt": "2020-02-07T18:18:24",
    "Id": "357765ef-ef5b-4012-a4d1-fa0d3bbc0384"
  },
  "LivestockProfile": {
    "Id": "c2e5e95c-2fd2-429d-b713-17d9148c04fc",
    "LivestockOwnerProfileId": "955a7b92-d639-4b28-9fc8-e9fcdb61a56a",
    "MotherLivestockWalletAddress": "",
    "FatherLivestockWalletAddress": "1U5DSdbitjBRJsqR56qXWkx5oesSxxytky5PTH",
    "IsActive": true,
    "CreatedAt": "2020-12-22T07:15:01",
    "UpdatedAt": "2020-12-22T07:22:01",
    "WalletAddressId": "cc326ab4-eef5-49a6-92ae-e54600d654db"
  }
}
```
**NOTE** : The payload is retrieved from multichain for demo purpose only. In actual implementation,  data will not be stored on the blockchain.

**NOTE**: The RSA public/private key pair used in the example is generated using openssl.  
```
openssl genrsa -out rsa.private 1024  
openssl rsa -in rsa.private -out rsa.public -pubout -outform  
```
The above commands will generate 2 files.  
rsa.public  
```
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDpHWzmlAg9mvoBScq7t2YPVM5q
aYwi/MoCHDxtkSogWXfRvJ0MItG2DpyZVVxr+IvMs934JMLDvzKUZuBny+2qG/bF
yyyDhKDpG6l9IadzonMwLTg7VdYqnJjcTC+SgcxqQJAl3Lnu+PyGuU/CJb6WptHV
abXtwjLooZCjle+cawIDAQAB
-----END PUBLIC KEY-----
```
rsa.private  
```
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDpHWzmlAg9mvoBScq7t2YPVM5qaYwi/MoCHDxtkSogWXfRvJ0M
ItG2DpyZVVxr+IvMs934JMLDvzKUZuBny+2qG/bFyyyDhKDpG6l9IadzonMwLTg7
VdYqnJjcTC+SgcxqQJAl3Lnu+PyGuU/CJb6WptHVabXtwjLooZCjle+cawIDAQAB
AoGBALNDEoR536BoNcqZ0VHrJYuyno0MH1ykYj+fMQTctbVst4xM68PyXqwOrnPn
RYwt9Gt1AcOZmUBoHmAqgHSxSE+pOMuM1sUzieu3GI5gwHFVZ5zGqjzc4WLVEfvD
PcrPWxd2E4bGdmUFt53i9GMKVvEpTr3ztLqiVOigclixyJ3xAkEA9lJ/RBEJaImx
b0nyYbpVkZlsCmsv88UPhd/JZtYa+Cql9aN+xFI/u8fn6Uwfe0bnS9dKOfB2PvAb
Uyf+UGmQ2QJBAPJGFucUuIg9xAoprgv4QwVr8qoOo/75+sO3j5hzXi8rKZxhzP6q
XORb4hRmfvUMGvEEbrfGp1zm0IJ+7euaDOMCQDJJBygbHkOUEH/6pZuj0YImwvKh
jSmDqjaXR+NRhDHzauvpk6B6df5cwhBTdP3SrLdD3ShU2Z7hn4JrYLSDyIkCQQDB
PXhtDlD1klZ4SLBjKbzDaUufqpfR+y+xxgrJ7VM1SjchXby1b8sx9bvIy8v9xo8C
qKdq/A9oAU5Ul8tLfY9DAkBRKo/KamVx6ZsfyYSBfX/qVg8UWX2QFY/2WXnIo5D7
wUMQlf56RyikGy4VO3X3/1JBV6g5MmMVA8K1mjMC+jRx
-----END RSA PRIVATE KEY-----
```
