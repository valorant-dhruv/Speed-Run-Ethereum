pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

//The Vendor smart contract is also inheriting the Ownable.sol smart contract
//This assigns an owner to the vendor smart contract
//Here we are assigning the owner of the vendor to the frontend address
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  //This is the state variable which indicates the price of each token
  //This means that 1 ether is equal to 100 tokens
  uint public constant tokensPerEth = 100;

  using SafeMath for uint256;

 //YourToken is the smart contract where 1000 tokens were minted to the frontend address
  YourToken public yourToken;

  constructor(address tokenAddress) {
    //Here we are creating an instance of the smart contract
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() payable public{
    //This is the function where users can buy tokens in exchange of ethers
    uint ethervalue=msg.value;

    //Now the amount of tokens to return to the user is ethervalue*tokensperEth

    //The check is the value to indicate whether there is an arithmetic overflow or not
    (bool check,uint256 tokenvalue)=SafeMath.tryMul(ethervalue,tokensPerEth);
    if(check==true && tokenvalue==0)
    {
      revert("You need to pass some ethers to buy the tokens");
    }

    if(check==false)
    {
      revert("There is some arithmetic overflow while performing the calculations");
    }

    //Now we need to transfer the amount of tokens to the buyer
    //This is transferring the tokens from the Vendor smart contract to the account address
    yourToken.transfer(msg.sender,tokenvalue);

    emit BuyTokens(msg.sender,ethervalue,tokenvalue);


  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  //It lets the owner withdraw the ethers from the smart contract
  function withdraw() public onlyOwner{
    payable(msg.sender).transfer(address(this).balance);
  }

  // ToDo: create a sellTokens(uint256 _amount) function:
  //First the user has to call the approve function of the yourtoken smart contract approving the Vendor to receive the tokens
  //Then the user calls the sellTokens function
  function sellTokens(uint256 _amount) public{
    //The amount of tokens should now be sent to the smart contract
    require(_amount>0,"The amount of tokens to sell must be greater than xero");
    yourToken.transferFrom(msg.sender,address(this),_amount);

    //Now that the user has sent all the tokens back to the vendor now the user should get some ether back
    (bool check,uint256 tokenvalue)=SafeMath.tryDiv(_amount,tokensPerEth);
    payable(msg.sender).transfer(tokenvalue);
  }

}
