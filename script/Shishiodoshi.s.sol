// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { Shishiodoshi } from "../src/ShishiodoshiGame.sol";
import { ShishiodoshiToken } from "../src/ShishiodoshiToken.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
// forge flatten src/ShishiodoshiGame.sol > game.sol
// forge flatten src/ShishiodoshiToken.sol > token.sol
contract DeployShishiodoshi is Script {
    address internal deployer;
    Shishiodoshi internal sh;
    ShishiodoshiToken internal shtoken;

    function setUp() public virtual {
        string memory mnemonic = vm.envString("MNEMONIC");
        (deployer,) = deriveRememberKey(mnemonic, 0);
    }

    function run() public {
        vm.startBroadcast(deployer);
        shtoken = new ShishiodoshiToken();
        sh = new Shishiodoshi(address(shtoken));
        vm.stopBroadcast();
    }
}
