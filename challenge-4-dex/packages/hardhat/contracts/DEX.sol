// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";


/**
 * @title DEX Template
 * @author stevepham.eth and m00npapi.eth
 * @notice Empty DEX.sol that just outlines what features could be part of the challenge (up to you!)
 * @dev We want to create an automatic market where our contract will hold reserves of both ETH and 🎈 Balloons. These reserves will provide liquidity that allows anyone to swap between the assets.
 * NOTE: functions outlined here are what work with the front end of this branch/repo. Also return variable names that may need to be specified exactly may be referenced (if you are confused, see solutions folder in this repo and/or cross reference with front-end code).
 */
contract DEX {
    /* ========== GLOBAL VARIABLES ========== */

   //These are the two global variables
   uint256 public totalLiquidity;
   mapping(address=>uint256) public liquidity;


    using SafeMath for uint256; //outlines use of SafeMath for uint256 variables
    IERC20 token; //instantiates the imported contract

    /* ========== EVENTS ========== */

    /**
     * @notice Emitted when ethToToken() swap transacted
     */
    event EthToTokenSwap(address sender,string message,uint256 inputvalue,uint256 tokenoutput);

    /**
     * @notice Emitted when tokenToEth() swap transacted
     */
    event TokenToEthSwap(address sender,string message,uint256 ethOutput,uint256 tokenInput);

    /**
     * @notice Emitted when liquidity provided to DEX and mints LPTs.
     */
    event LiquidityProvided(address sender,uint256 liquidityMinted, uint256 value,uint256 tokenDeposit);

    /**
     * @notice Emitted when liquidity removed from DEX and decreases LPT count within DEX.
     */
    event LiquidityRemoved(address sender,uint256 amount,uint256 ethWithdrawn,uint256 tokenAmount);

    /* ========== CONSTRUCTOR ========== */

    constructor(address token_addr) public {
        token = IERC20(token_addr); //specifies the token address that will hook into the interface and be used through the variable 'token'
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @notice initializes amount of tokens that will be transferred to the DEX itself from the erc20 contract mintee (and only them based on how Balloons.sol is written). Loads contract up with both ETH and Balloons.
     * @param tokens amount to be transferred to DEX
     * @return totalLiquidity is the number of LPTs minting as a result of deposits made to DEX contract
     * NOTE: since ratio is 1:1, this is fine to initialize the totalLiquidity (wrt to balloons) as equal to eth balance of contract.
     */
  
    //For now the DEX smart contract has no ethers and balloons 
    //So the init function is called for the first time by a provider who provides both ethers and balloons
    function init(uint256 tokens) public payable returns (uint256) {

        //The msg.sender is sending some amount of ethers and the balloons initally to the smart contract
        require(totalLiquidity==0,"Some liquidity has already been assigned and hence the init function won't work");
        
        //Now totalLiquidity is equal to the amount of ethers sent to the contract
        //The liquidity indicates the ethers that the user has sent
        totalLiquidity=address(this).balance;
        liquidity[msg.sender]=totalLiquidity;

        //Now we need to compare the values of the amount of tokens with the totalLiquidity

        //The is the additional part that is not written in the speedrunethereum


        //Now we are transferring the required amount of tokens to this smart contract
         require(token.transferFrom(msg.sender, address(this), tokens), "DEX: init - transfer did not transact");
        return totalLiquidity;
    }

    //Now that the smart contract has some amount of ethers and some amount of balloon tokens in the ratio 1:1
    //This means that 1 balloon token is equal to 1 ether for now
    
    //The formula for the automated market maker is x*y=k
    //The value of x is the amount of ethers in the DEX smart contract
    //The value of y is the amount of balloon tokens in the DEX smart contract

    /**
     * @notice returns yOutput, or yDelta for xInput (or xDelta)
     * @dev Follow along with the [original tutorial](https://medium.com/@austin_48503/%EF%B8%8F-minimum-viable-exchange-d84f30bd0c90) Price section for an understanding of the DEX's pricing model and for a price function to add to your contract. You may need to update the Solidity syntax (e.g. use + instead of .add, * instead of .mul, etc). Deploy when you are done.
     */
     //This is the price function 
     //We have the value of x as an input and we already know the x reserves and the y reserves in the smart contract
     //If x is the ethers then yOutput would be balloon tokens
     //If x is the balloon tokens then yOutput would be ethers
    function price(
        uint256 xInput,
        uint256 xReserves,
        uint256 yReserves
    ) public view returns (uint256 yOutput) {

        //Firstly we need to determine what is the input
        //However there is no need to determine as of now
        //Inside the price function we are just predicting the price

        //The value of the xy=k
        //The value of k should remain constant

        //Hence initially it was (xReserves)(yReserves)=k
        //Now when some amount of xInput is added then it becomes (xReserves+xInput)(yReserves-yOutput)=k

        //Hence comparing these two equations and simplifying them we get the final formula as:
        //yOutput=(yReserves* xInput)/(xReserves + xInput)

        //This is the require function to make sure that xInput is greater than zero
        require(xInput>0,"The input amount must be greater than zero");

        //Now after removing the transaction fees which is 0.003 % if we remove the 0.003 from the xInput
        //Effectively the input left is x-0.003 % of x which is equal to 997x/1000
        //We now make a variable xInputwithfee as 997x 

        //We are also taking some amount of fees as the transaction fees
        uint256 xInputwithfee=xInput.mul(997);

        //We are using the safeMath library to perform this task 
         (bool flag,uint256 numerator)=SafeMath.tryMul(xInputwithfee,yReserves);
         if(!flag)
         {
             revert("Some calculation error has occured either overflow or underflow");
         }
         //Now we have got the result of the numerator

         //The denominator calculation
         (bool flag2,uint denominator)=SafeMath.tryAdd((xReserves.mul(1000)),xInputwithfee);
          if(!flag2)
         {
             revert("Some calculation error has occured either overflow or underflow");
         }

         //Finally we divide the numerator and the denominator
         (bool flag3,uint finalans)=SafeMath.tryDiv(numerator,denominator);
         if(!flag3)
         {
             revert("Some calculation error has occured either overflow or underflow");
         }

        //Hence this is the final result that we have calculated using the maths
         return finalans;
    }

    /**
     * @notice returns liquidity for a user. Note this is not needed typically due to the `liquidity()` mapping variable being public and having a getter as a result. This is left though as it is used within the front end code (App.jsx).
     * if you are using a mapping liquidity, then you can use `return liquidity[lp]` to get the liquidity for a user.
     *
     */
    function getLiquidity(address lp) public view returns (uint256) {
        //As we already have a mapping which maps particular addresses to its liquidity
        return liquidity[lp];
    }

    /**
     * @notice sends Ether to DEX in exchange for $BAL
     */
     //This is the function in which the DEX receives the ethers and the user receives the tokens
    function ethToToken() public payable returns (uint256 tokenOutput) {

        //Now for calculating the value of tokenOutput using the price function
        //We need to xReserves, yReserves. The xInput is the amount of ethers that the user has sent
        //According to me the xReserves which is the amount of ethers is the totalLiquidity
        //It can also be address(this).balance-msg.value
        //The yReserves is the amount of balloon tokens that the smart contract has
        require(msg.value>0,"You need to enter some amount of ethers to exchange it for tokens");
        uint256 yReserves=token.balanceOf(address(this));
        uint256 xReserves=address(this).balance-msg.value;
        uint256 xInput=msg.value;

        //Now we find the value of the yOutput
        uint256 tokenOutput=price(xInput,xReserves,yReserves);

        //As we have got the amount of tokens to send the user we now transfer the tokens
        bool success=token.transfer(msg.sender,tokenOutput);
        if(!success)
        {
            revert("The transfer of tokens to the user has failed!");
        }

         emit EthToTokenSwap(msg.sender, "Eth to Balloons", msg.value, tokenOutput);

        //This means that the smart contract has received the ethers and the user has received the tokens
        return tokenOutput;
    }

    /**
     * @notice sends $BAL tokens to DEX in exchange for Ether
     */
     //This is the function that accepts tokens as an input and as an exchange gives out ethers as an output
    function tokenToEth(uint256 tokenInput) public returns (uint256 ethOutput) {

        require(tokenInput>0,"The tokens to swap for ethers must be greater than zero");

        //Again we need to first find the values of xReserves,yReserves and xInput
        //In this case the xInput is the tokenInput only
        uint256 xInput=tokenInput;

        //Now for the value of xReserves which is the amount of balloon tokens that the smart contract has
        uint256 xReserves=token.balanceOf(address(this));

        //Now the value of yReserves is the amount of ethers that the smart contract has
        uint256 yReserves=address(this).balance;

        //Now we calculate the amount of ethers to send back to the user
        uint256 ethOutput=price(xInput,xReserves,yReserves);

        //Now we transfer the amount of tokens from the msg.sender to this smart contract
        //Normally before the transfer we also approve the smart contract to spend this much amount of tokens
        // bool success=token.approve(address(this),tokenInput){from:msg.sender};

        // if(!sucesss)
        // {
        //     revert("The approval to transfer the tokens has failed!");
        // }

        //Now we transfer the tokens
        require(token.transferFrom(msg.sender,address(this),tokenInput),"The transfer of tokens has failed");

        //Now we send the amount of ethers to the msg.sender
        payable(msg.sender).transfer(ethOutput);

        emit TokenToEthSwap(msg.sender, "Balloons to Eth", ethOutput, tokenInput);

        return ethOutput;       
    }

    /**
     * @notice allows deposits of $BAL and $ETH to liquidity pool
     * NOTE: parameter is the msg.value sent with this function call. That amount is used to determine the amount of $BAL needed as well and taken from the depositor.
     * NOTE: user has to make sure to give DEX approval to spend their tokens on their behalf by calling approve function prior to this function call.
     * NOTE: Equal parts of both assets will be removed from the user's wallet with respect to the price outlined by the AMM.
     */
    // function deposit() public payable returns (uint256 tokensDeposited) {

    // }

    // /**
    //  * @notice allows withdrawal of $BAL and $ETH from liquidity pool
    //  * NOTE: with this current code, the msg caller could end up getting very little back if the liquidity is super low in the pool. I guess they could see that with the UI.
    //  */
    // function withdraw(uint256 amount) public returns (uint256 eth_amount, uint256 token_amount) {}

    //This is the deposit function for the LPs to deposit both the ethers and the balloon tokens
    function deposit() public payable returns (uint256 tokensDeposited) {

        require(msg.value>0,"The amount of ethers must be greater than zero");

        //Now we need to calculate the amount of balloon tokens based on the ethers
        //For that also we need tokenReserve and the ethReserve of the smart contract
        uint256 tokenReserve=token.balanceOf(address(this));
        uint256 ethReserve=address(this).balance.sub(msg.value);

        //Now there is this formula: TokensIn=(Ether In * Tokens Reserve)/Ethers Reserve
         (bool flag,uint256 numerator)=SafeMath.tryMul(msg.value,tokenReserve);
         if(!flag)
         {
             revert("Some calculation error has occured either overflow or underflow");
         }

        (bool flag3,uint finalans)=SafeMath.tryDiv(numerator,ethReserve);
         if(!flag3)
         {
             revert("Some calculation error has occured either overflow or underflow");
         }

        //We are adding 1 wei to the calculation
         uint256 tokenDeposit=finalans.add(1);

        //Now we mint the LP tokens
        //For the LP tokens the formula is:LP tokens to send to user=(Total supply of LP tokens * Ethers sent by user)/ethReserve
        uint256 liquidityMinted = msg.value.mul(totalLiquidity) / ethReserve;
        liquidity[msg.sender] = liquidity[msg.sender].add(liquidityMinted);
        totalLiquidity = totalLiquidity.add(liquidityMinted);

         //The finalans is the amount of balloon tokens to transfer from msg.sender to the smart contract
         //Before transferring we need to check whether the msg.sender has sufficient tokens or not

         require(token.balanceOf(msg.sender)>=finalans,"Insufficient balance of balloon tokens");
         require(token.transferFrom(msg.sender,address(this),finalans),"The transfer of balloon tokens failed");

         emit LiquidityProvided(msg.sender, liquidityMinted, msg.value, finalans);

         return tokenDeposit;

    }

    //This is the function to withdraw the ethers and the tokens
    //We need to somehow get the values of eth_amount and token_amount using LPTs
    //For calculating such values we have two formulaes available with us
    //eth_amount= (total ethers in smart contract * amount)/totalLiquidity
    //token_amount=(total tokens in smart contract * amount)/totalLiquidity
    function withdraw(uint256 amount) public returns (uint256 eth_amount, uint256 token_amount) {
        //The amount indicates the amount of LPTs
        require(amount<=liquidity[msg.sender],"You don't have sufficient liquidity to initiate the transfer");

        uint256 ethWithdrawn =(address(this).balance.mul(amount))/totalLiquidity;
        uint256 tokenAmount=(token.balanceOf(address(this)).mul(amount))/totalLiquidity;

        //Now that we have the amount of tokens and the amount of ethers
        //We reduce the values inside the totalLiquidity and the liquidity of msg.sender
        totalLiquidity-=amount;
        liquidity[msg.sender]-=amount;

        (bool sent, ) = payable(msg.sender).call{ value: ethWithdrawn }("");
        require(sent, "withdraw(): revert in transferring eth to you!");
        require(token.transfer(msg.sender, tokenAmount));
        emit LiquidityRemoved(msg.sender, amount, ethWithdrawn, tokenAmount);
        return (ethWithdrawn, tokenAmount);

    }

}
