// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staker {

  //This is creating a state variable for the external smart contract
  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      
      //Now we are creating an instance of the exampleExternalContract so that we can call the functions of this smart contract
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  //This is the mapping to track the individual balances
  mapping(address=>uint256) public balances;

  //This is the constant state variable which determines the threshold value
  uint256 public constant thresold=1 ether;

  //This is the event that is emitted whenever a fund is collected
  event Stake(address,uint256);

  using SafeMath for uint256;

  modifier checkdeadline{
    unchecked {
      bool checked=block.timestamp>=deadline;
      // console.log(checked);
       require(checked,"The deadline is not yet over");
    }
    _;
   
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() payable public{
    unchecked {
      bool isbalance=msg.value>0;
      // console.log(isbalance);
      require(isbalance,"You need to send some amount of ethers");
    }
    

    //Also the staking is only allowed within the deadline period
    unchecked {
      bool checking=block.timestamp>=deadline;
      require(!checking,"The staking period is now over");
   
    //Now that the user has sent the ethers we update the balances mapping
    balances[msg.sender]+=msg.value;

    //Finally we emit the event
    emit Stake(msg.sender,msg.value);
    }
  }

  //This is the state variable to determine whether the withdraw functionality is open or not
  bool public openForWithdraw=false;

  //This is the modifier that will check whether the Examplesmart contract has completed or not
  modifier notcompleted{
    unchecked{
    bool value=exampleExternalContract.completed();
    require(!value,"The example smart contract has been completed now you cannot send funds");
    }
    _;
  }

  //Now we are setting a deadline that within this deadline only the users are allowed to stake
  //The deadline is once the smart contract transaction has been included in the block + 30 seconds
    uint256 public deadline = block.timestamp + 30 seconds;
  

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public notcompleted checkdeadline{

    //Now if the contract has accumulated enough funds after the deadline we can call the function of the exampleExternalContract
    unchecked {
      bool checking=address(this).balance>=thresold;
      // console.log(checking);
      if(checking)
    {
      exampleExternalContract.complete{value: address(this).balance}();
    }
    else{
      openForWithdraw=true;
    }
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public notcompleted{
    unchecked {
    require(openForWithdraw,"The smart contract is not yet open for withdrawal");
    payable(msg.sender).transfer(balances[msg.sender]);

    //Once the ethers have been withdrawn back change the balance back
    balances[msg.sender]=0;
    }
  }

   function getCurrentTime() internal view returns(uint256){
        return block.timestamp;
    }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256)
  {
    unchecked {
      bool checking =(block.timestamp)>=deadline;
      if(checking)
      {
        return 0;
      }
      else{
          // uint256 ans=block.timestamp-deadline;
          uint256 time=getCurrentTime();
          (bool ans2,uint256 ans)=SafeMath.trySub(time,deadline);
          return deadline;
          
      }
    }
    
  }


  // Add the `receive()` special function that receives eth and calls stake()
  //This is kind of a fallback function
  receive() external payable{
    stake();
  }

}
