pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//This is the basic smart contract which mints 1000 Balloon tokens to the address that deployed the smart contract
contract Balloons is ERC20 {
    constructor() ERC20("Balloons", "BAL") {
        ///We write 1000 ethers because 1000 ethers in value is same as 1000 * 10^18 and we need to mint these much 
        //amount of tokens
        _mint(msg.sender, 1000 ether); // mints 1000 balloons!
    }
}
