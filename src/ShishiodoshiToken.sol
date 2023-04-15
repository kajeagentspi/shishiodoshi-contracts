// SPDX-License-Identifier: MIT

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.10;

contract ShishiodoshiToken is ERC20 {
    constructor() ERC20("Shishiodoshi", "SSO") { }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
