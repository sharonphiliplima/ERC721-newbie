// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 1000;

        //Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
        //just transfer() sets the "from" as whoever's calling

        assertEq(ourToken.balanceOf(alice), transferAmount);

        //This is to ensure that the correct amount of tokens was
        // deducted from Bob's balance after the transfer.
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransfers() public {
        uint256 transferAmount = 100;

        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
    }

    function testTransferWithInsufficientBalance() public {
        vm.expectRevert();
        uint256 transferAmount = 10;
        vm.prank(alice);
        ourToken.transfer(bob, transferAmount);

        vm.prank(alice);
        uint256 aliceCurrentBalance = ourToken.balanceOf(alice);
        console.log(aliceCurrentBalance);
    }
}
