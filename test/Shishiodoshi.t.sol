// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import "forge-std/Test.sol";
import "../src/ShishiodoshiGame.sol";
import "../src/ShishiodoshiToken.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract ShishiodoshiTest is StdCheats, Test {
    using stdStorage for StdStorage;

    Shishiodoshi sh;
    ShishiodoshiToken shtoken;

    address player1;
    address player2;
    address player3;
    address player4;
    address player5;

    function setUp() public virtual {
        shtoken = new ShishiodoshiToken();
        sh = new Shishiodoshi(address(shtoken));

        sh.addSupportedToken(address(shtoken));
        string memory mnemonic = vm.envString("MNEMONIC");

        (player1,) = deriveRememberKey(mnemonic, 0);
        (player2,) = deriveRememberKey(mnemonic, 1);
        (player3,) = deriveRememberKey(mnemonic, 2);
        (player4,) = deriveRememberKey(mnemonic, 3);
        (player5,) = deriveRememberKey(mnemonic, 4);

        shtoken.mint(player1, 1000e18);
        shtoken.mint(player2, 1000e18);
        shtoken.mint(player3, 1000e18);
        shtoken.mint(player4, 1000e18);
        shtoken.mint(player5, 1000e18);

        vm.prank(player1);
        shtoken.approve(
            address(sh),
            115_792_089_237_316_195_423_570_985_008_687_907_853_269_984_665_640_564_039_457_584_007_913_129_639_935
        );

        vm.prank(player2);
        shtoken.approve(
            address(sh),
            115_792_089_237_316_195_423_570_985_008_687_907_853_269_984_665_640_564_039_457_584_007_913_129_639_935
        );

        vm.prank(player3);
        shtoken.approve(
            address(sh),
            115_792_089_237_316_195_423_570_985_008_687_907_853_269_984_665_640_564_039_457_584_007_913_129_639_935
        );

        vm.prank(player4);
        shtoken.approve(
            address(sh),
            115_792_089_237_316_195_423_570_985_008_687_907_853_269_984_665_640_564_039_457_584_007_913_129_639_935
        );

        vm.prank(player5);
        shtoken.approve(
            address(sh),
            115_792_089_237_316_195_423_570_985_008_687_907_853_269_984_665_640_564_039_457_584_007_913_129_639_935
        );
    }

    function printAddresses() public {
        console2.log("========Balances=========");
        console2.log("player1", address(player1));
        console2.log("player2", address(player2));
        console2.log("player3", address(player3));
        console2.log("player4", address(player4));
        console2.log("player5", address(player5));
        console2.log("==========================");
    }

    function printBalances() public {
        console2.log("========Balances=========");
        console2.log("player1", shtoken.balanceOf(player1), address(player1));
        console2.log("player2", shtoken.balanceOf(player2), address(player2));
        console2.log("player3", shtoken.balanceOf(player3), address(player3));
        console2.log("player4", shtoken.balanceOf(player4), address(player4));
        console2.log("player5", shtoken.balanceOf(player5), address(player5));
        console2.log("==========================");
    }

    function printGameOrder(uint256 _gameID) public {
        console2.log(sh.getPlayerOrder(player1, _gameID));
        console2.log(sh.getPlayerOrder(player2, _gameID));
        console2.log(sh.getPlayerOrder(player3, _gameID));
        console2.log(sh.getPlayerOrder(player4, _gameID));
        console2.log(sh.getPlayerOrder(player5, _gameID));
    }

    function printTurn(uint256 _gameID) public {
        address player = sh.getCurrentPlayer(_gameID);
        if (player == player1) {
            console2.log("Current Turn: player1");
        } else if (player == player2) {
            console2.log("Current Turn: player2");
        } else if (player == player3) {
            console2.log("Current Turn: player3");
        } else if (player == player4) {
            console2.log("Current Turn: player4");
        } else if (player == player5) {
            console2.log("Current Turn: player5");
        } else {
            console2.log("Current Turn: out of bounds");
        }
    }

    function testPlay() external {
        // create game
        uint256 currentGameID = sh.newGame(address(shtoken), 1e18, 5, 20);
        uint256 nextGameID = sh.nextGameID();
        require(currentGameID + 1 == nextGameID, "Create Game Failed");

        // init game
        uint16 testTippingAmount = 10;
        bytes32 randomHash = 0xf8db53975f5fdc816635f807cba40ec54168f27c782cc6e7e7ab8905aeddc90b;

        bytes memory tippingAmountBytes = new bytes(32);
        assembly {
            mstore(add(tippingAmountBytes, 32), testTippingAmount)
        }

        bytes memory winningRaw = new bytes(32);
        winningRaw[0] = tippingAmountBytes[30];
        winningRaw[1] = tippingAmountBytes[31];

        for (uint256 i = 0; i < 30; i++) {
            winningRaw[i + 2] = randomHash[i];
        }
        bytes32 winningHash = sha256(winningRaw);

        sh.initGame(currentGameID, winningHash);

        printAddresses();
        printBalances();

        // join game
        vm.prank(player1);
        sh.joinGame(currentGameID);
        console2.log("Player 1 Joined");

        vm.prank(player2);
        sh.joinGame(currentGameID);
        console2.log("Player 2 Joined");

        vm.prank(player3);
        sh.joinGame(currentGameID);
        console2.log("Player 3 Joined");

        vm.prank(player4);
        sh.joinGame(currentGameID);
        console2.log("Player 4 Joined");

        vm.prank(player2);
        sh.leaveGame(currentGameID);
        console2.log("Player 2 Left");

        vm.prank(player2);
        sh.joinGame(currentGameID);
        console2.log("Player 2 Joined");

        vm.prank(player5);
        sh.joinGame(currentGameID);
        console2.log("Player 5 Joined");

        printBalances();
        printGameOrder(currentGameID);

        printTurn(currentGameID);
        vm.prank(sh.getCurrentPlayer(currentGameID));
        sh.bidGame(currentGameID, 8);

        printTurn(currentGameID);
        vm.prank(sh.getCurrentPlayer(currentGameID));
        sh.bidGame(currentGameID, 8);

        printTurn(currentGameID);
        vm.prank(sh.getCurrentPlayer(currentGameID));
        sh.bidGame(currentGameID, 8);

        sh.endGame(currentGameID, testTippingAmount, randomHash);

        printBalances();
    }
}
