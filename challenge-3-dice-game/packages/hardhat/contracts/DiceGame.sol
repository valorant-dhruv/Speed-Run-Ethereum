pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

contract DiceGame {

    uint256 public nonce = 0;
    uint256 public prize = 0;

    event Roll(address indexed player, uint256 roll);
    event Winner(address winner, uint256 amount);

    
    constructor() payable {
        resetPrize();
    }
    
    //Hence the prize is 1/10th the balance of this smart contract
    function resetPrize() private {
        prize = ((address(this).balance * 10) / 100);
    }

    function rollTheDice() public payable {
        require(msg.value >= 0.002 ether, "Failed to send enough value");

        //This is the logic for generating the random numbers

        //The blockhash is a special variable which returns the hash of the given block
        //Here let's say the smart contract is a part of the block 1000
        //The we obtain the hash value of the previous block that is block 999
        bytes32 prevHash = blockhash(block.number - 1);

        //Now we again find the hash using the previous hash the balance of this smart contract and the nonce
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(this), nonce));
        uint256 roll = uint256(hash) % 16;

        console.log('\t',"   Dice Game Roll:",roll);

        nonce++;
        
        //This means that 40% of the msg.value goes as the price and the rest 
        prize += ((msg.value * 40) / 100);

        emit Roll(msg.sender, roll);

        if (roll > 2 ) {
            return;
        }

        uint256 amount = prize;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");

        resetPrize();
        emit Winner(msg.sender, amount);
    }

    receive() external payable {  }
}
