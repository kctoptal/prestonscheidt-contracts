# Preston Scheidt Crypto platform contracts project

This is hardhat project with automated test framework. This project contains following folders -
1. contracts - Contains SOLDIERS Token platform contracts
2. contracts/test - Contains mock contracts required for automated tests
3. scripts - Contains deployment scripts into any network
4. test - Contains automated test scripts

Most used Commands
------------------
**Compile** - yarn compile <br/>
**Deploy** - yarn deploy network <br/>
**Automated Test run** - yarn test <br/>
**Console** - yarn console <br/>

//

hh verify --network bsctestnet --constructor-args argumentsPreSoldiers.js 0x1d378dD142e3BeBB3b2A7B2D73DEcD03DBBFF2fd --contract contracts/SoldiersPresaleToken.sol:SoldiersPresaleToken --show-stack-traces

hh verify --network bsctestnet --constructor-args argumentsSoldiers.js 0x5a4a8255784B20B45eCE1497f4f22C79e47e9c0f --contract contracts/SoldiersToken.sol:SoldiersToken --show-stack-traces

hh verify --network bsctestnet 0xF28E89150956e40074f64764791f36794B7C0B0D --contract contracts/test/BUSDToken.sol:BUSDToken --show-stack-traces


hh verify --network bsctestnet 0xC1aF50fef7D753d39A0Cd71cAF13581803615Bc9 80000000000 --contract contracts/BarracksToken.sol:BarracksToken --show-stack-traces

hh verify --network bsctestnet 0x5b57BD318d5bD8e08017a8734c052DE73b1cC3bf --contract contracts/Staking.sol:Staking --show-stack-traces