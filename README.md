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

hh verify --network bsctestnet 0x15E925C92A4293ffbF7Ced25C0490b335fFFd33d 25000000000 --contract contracts/SoldiersPresaleToken.sol:SoldiersPresaleToken --show-stack-traces

hh verify --network bsctestnet 0x7511f41E9169141DF74F1b83B7B3c9BD32aB2E1b 80000000000 --contract contracts/SoldiersToken.sol:SoldiersToken --show-stack-traces

hh verify --network bsctestnet 0xF28E89150956e40074f64764791f36794B7C0B0D --contract contracts/test/BUSDToken.sol:BUSDToken --show-stack-traces

hh verify --network bsctestnet --constructor-args arguments.js 0xe6295c50FBC714479f689b307ebdf230a7Ee65Aa --contract contracts/Crowdsale.sol:Crowdsale --show-stack-traces