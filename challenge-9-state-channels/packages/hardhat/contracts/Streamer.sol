// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

//The contract Streamer is Ownable meaning that the ownership of the smart contract will be transferred to the frontend address
contract Streamer is Ownable {
    event Opened(address, uint256);
    event Challenged(address);
    event Withdrawn(address, uint256);
    event Closed(address);

    mapping(address => uint256) public balances;
    mapping(address => uint256) public canCloseAt;

    //The Rubes that are seeking wisdom will call this function
    //Once the function is called the balances mapping will be updated
    function fundChannel() public payable {
        /*
        Checkpoint 3: fund a channel

        complete this function so that it:
        - reverts if msg.sender already has a running channel (ie, if balances[msg.sender] != 0)
        - updates the balances mapping with the eth received in the function call
        - emits an Opened event
        */
        require(balances[msg.sender]==0,"The state channel for this account address is already running!");
        require(msg.value>0,"The user needs to send some amount of eth as stake");

        //Now we update the balance
        balances[msg.sender]=msg.value;
        
        emit Opened(msg.sender,msg.value);
    }

    function timeLeft(address channel) public view returns (uint256) {
        require(canCloseAt[channel] != 0, "channel is not closing");
        return canCloseAt[channel] - block.timestamp;
    }

    //The input Voucher is a struct
    function withdrawEarnings(Voucher calldata voucher) public onlyOwner {
        // like the off-chain code, signatures are applied to the hash of the data
        // instead of the raw data itself
        bytes32 hashed = keccak256(abi.encode(voucher.updatedBalance));

        // The prefix string here is part of a convention used in ethereum for signing
        // and verification of off-chain messages. The trailing 32 refers to the 32 byte
        // length of the attached hash message.
        //
        // There are seemingly extra steps here compared to what was done in the off-chain
        // `reimburseService` and `processVoucher`. Note that those ethers signing and verification
        // functions do the same under the hood.
        //
        // again, see https://blog.ricmoo.com/verifying-messages-in-solidity-50a94f82b2ca

        bytes memory prefixed = abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            hashed
        );

        bytes32 prefixedHashed = keccak256(prefixed);

        //We first destruct the values of r s and v
        Signature memory temp=voucher.sig;

        //Now that we have the temp signature we destruct the values of r,s and v
        address signer = ecrecover(prefixedHashed, temp.v, temp.r, temp.s);

        require(signer!=address(0),"Invalid signer addresss");

        //Now we see whether the signer has a running channel or not
        require(balances[signer]!=0,"There is no running channel for the signer");

        //Now we have got the address of the signer we need to require that the address has a running channel
        require(balances[signer]>voucher.updatedBalance,"the funds are not enough");

        uint256 remainingamount=balances[signer]-voucher.updatedBalance;
        balances[signer]=voucher.updatedBalance;

        //Now we get the owner of the smart contract which is the GURU here
        address owner=owner();

        //Now we pay the owner with the remaining amount
        payable(owner).transfer(remainingamount);

        emit Withdrawn(owner,remainingamount);


        /*
        Checkpoint 5: Recover earnings

        The service provider would like to cash out their hard earned ether.
            - use ecrecover on prefixedHashed and the supplied signature
            - require that the recovered signer has a running channel with balances[signer] > v.updatedBalance
            - calculate the payment when reducing balances[signer] to v.updatedBalance
            - adjust the channel balance, and pay the contract owner. (Get the owner address withthe `owner()` function)
            - emit the Withdrawn event
        */
    }

    /*
    Checkpoint 6a: Challenge the channel

    create a public challengeChannel() function that:
    - checks that msg.sender has an open channel
    - updates canCloseAt[msg.sender] to some future time
    - emits a Challenged event
    */

    //This is the function for closing the channel
    function challengeChannel() public{

        //Checks whether the msg.sender has an open channel or not
        require(balances[msg.sender]!=0,"There is no open channel for this account address");
        canCloseAt[msg.sender]=block.timestamp+30 seconds;

        emit Challenged(msg.sender);
    }

    /*
    Checkpoint 6b: Close the channel

    create a public defundChannel() function that:
    - checks that msg.sender has a closing channel
    - checks that the current time is later than the closing time
    - sends the channel's remaining funds to msg.sender, and sets the balance to 0
    - emits the Closed event
    */
    function defundChannel() public{

        //Checks whether the msg.sender has a closing channel
        require(canCloseAt[msg.sender]!=0,"The channel is not closing");
        require(block.timestamp>canCloseAt[msg.sender],"There is still some time left for the channel to close");
        payable(msg.sender).transfer(balances[msg.sender]);
        balances[msg.sender]=0;

        emit Closed(msg.sender);

    }

    //The Voucher is a struct that has two parameters the updatedBalance and the Signature struct
    struct Voucher {
        uint256 updatedBalance;
        Signature sig;
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    //The Signature is a struct that has three things the r ,s and v

}
