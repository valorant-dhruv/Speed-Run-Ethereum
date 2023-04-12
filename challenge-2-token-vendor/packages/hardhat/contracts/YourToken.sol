pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

//This is the ERC20 smar contract
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// learn more: https://docs.openzeppelin.com/contracts/4.x/erc20

//Here we are inheriting the ERC20 smart contract
contract YourToken is ERC20 {

    address private frontend=0xc7B309CC45c11A30C46114791085F0C205b441DF;
    constructor() ERC20("Gold", "GLD") {
        //_mint( ~~~YOUR FRONTEND ADDRESS HERE~~~~ , 1000 * 10 ** 18);

        //Now inside the constructor we are going to mint some tokens to the frontend address
        //_mint is the internal function of the ERC20 smart contract
        //We are minting 1000 tokens
        //As one token can be divided into 10^18 decimals hence the 1000 tokens are written in this way
        _mint(msg.sender,1000*10**18);
    }
}
