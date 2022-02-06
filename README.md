# See also Front repo
https://github.com/MaxBethglobal/MaxBeth-Front

# Betting smart contract

# Deployment
In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
npx hardhat run --network polygonMumbai scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network polygonMumbai --constructor-args .\scripts\arguments.js DEPLOYED_CONTRACT_ADDRESS
```
