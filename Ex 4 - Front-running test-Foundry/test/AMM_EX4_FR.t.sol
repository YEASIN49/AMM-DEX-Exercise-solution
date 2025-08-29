// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BaddToken.sol";
import "../src/AMMPool.sol";

contract AMM_EX4_FR is Test {
    BaddToken tokenX;
    BaddToken tokenY;
    AMMPool pool;

    address alice = address(0xA1);
    address bob   = address(0xB1);
    address poolAddr;

    function setUp() public {
        tokenX = new BaddToken("X", 30);
        tokenY = new BaddToken("Y", 40);

        // matchig initial value of alice
        tokenX.transfer(alice, 1);       

        pool = new AMMPool(address(tokenX), address(tokenY));
        poolAddr = address(pool);

        // matchig initial value of pool
        tokenY.transfer(poolAddr, 2);   

        // first row of test the front running test case
        assertEq(tokenX.balanceOf(alice), 1);
        assertEq(tokenX.balanceOf(bob), 0);
        assertEq(tokenX.balanceOf(poolAddr), 0);
        assertEq(tokenX.allowance(alice, poolAddr), 0);
        assertEq(tokenY.balanceOf(alice), 0);
        assertEq(tokenY.balanceOf(bob), 0);
        assertEq(tokenY.balanceOf(poolAddr), 2);
    }

    function testFrontRunScenario() public {
        vm.prank(alice);

        // representing the second row  
        tokenX.approve(poolAddr, 1);

        assertEq(tokenX.balanceOf(alice), 1);
        assertEq(tokenX.balanceOf(bob), 0);
        assertEq(tokenX.balanceOf(poolAddr), 0);
        assertEq(tokenX.allowance(alice, poolAddr), 1);
        assertEq(tokenY.balanceOf(alice), 0);
        assertEq(tokenY.balanceOf(bob), 0);
        assertEq(tokenY.balanceOf(poolAddr), 2);

        vm.prank(bob);

        // Bob, try to front-run but here revert should trigger as Bob has no allowance
        vm.expectRevert(); 
        pool.swapXY(1);

        // Now, Alice swaps lately after Bob. Should be successfull.
        // Though the code has vulnerabilities of underflow, and overflow,
        //  i am using 8.0+ solc version, which prevents this by defaule
        vm.prank(alice);
        pool.swapXY(1);

        // Check state after Alice swap - THis is the 4th row
        assertEq(tokenX.balanceOf(alice), 0);        
        assertEq(tokenX.balanceOf(bob), 0);          
        assertEq(tokenX.balanceOf(poolAddr), 1);     
        assertEq(tokenX.allowance(alice, poolAddr), 0); 
        assertEq(tokenY.balanceOf(alice), 2);        
        assertEq(tokenY.balanceOf(bob), 0);          
        assertEq(tokenY.balanceOf(poolAddr), 0);     
    }
}