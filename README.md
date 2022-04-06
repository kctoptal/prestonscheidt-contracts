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

hh verify --network bsctestnet 0x662271307571Ad1Ab6C9C5537f1629e680558868 55000000000 --contract contracts/SoldiersPresaleToken.sol:SoldiersPresaleToken --show-stack-traces

hh verify --network bsctestnet 0x36d102b4CDe103C389731CcA62b063e61f1960E7 80000000000 --contract contracts/SoldiersToken.sol:SoldiersToken --show-stack-traces

hh verify --network bsctestnet 0xF28E89150956e40074f64764791f36794B7C0B0D --contract contracts/test/BUSDToken.sol:BUSDToken --show-stack-traces

hh verify --network bsctestnet --constructor-args arguments.js 0xcF1225860c6CE1a8Dfa4da6Ea5a09e37F97C1f40 --contract contracts/Crowdsale.sol:Crowdsale --show-stack-traces

hh verify --network bsctestnet --constructor-args argumentsStake.js 0x9D927bC38f0EFc4A008A25f8Fbc3814189449d62 --contract contracts/Stake.sol:Stake --show-stack-traces