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

//hh verify --network bsctestnet 0x4cb85020a66Cfb50C6888e3Ee651789cBe847e47 80000000000 --contract contracts/SoldiersToken.sol:SoldiersToken --show-stack-traces

hh verify --network bsctestnet 0x82a9752804dFd1F33c1B06B3EB2321B3eCBA1cA4 55000000000 --contract contracts/SoldiersPresaleToken.sol:SoldiersPresaleToken --show-stack-traces

hh verify --network bsctestnet --constructor-args arguments.js 0x4cb85020a66Cfb50C6888e3Ee651789cBe847e47 --contract contracts/SoldiersToken.sol:SoldiersToken --show-stack-traces