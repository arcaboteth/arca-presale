// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/ArcaPresale.sol";

contract ArcaPresaleTest is Test {
    ArcaPresale presale;
    address owner = address(this);
    address alice = address(0xA11CE);
    address bob = address(0xB0B);
    address charlie = address(0xC);

    uint256 constant SOFT_CAP = 5 ether;
    uint256 constant HARD_CAP = 12.5 ether;
    uint256 constant MIN = 0.01 ether;
    uint256 constant MAX = 1 ether;
    uint256 constant DURATION = 48 hours;
    uint256 constant BONUS_BPS = 1000; // 10%

    function setUp() public {
        presale = new ArcaPresale(SOFT_CAP, HARD_CAP, MIN, MAX, DURATION, BONUS_BPS);
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(charlie, 10 ether);
    }

    function testBasicDeposit() public {
        vm.prank(alice);
        presale.deposit{value: 0.5 ether}();

        assertEq(presale.contributions(alice), 0.5 ether);
        assertEq(presale.totalRaised(), 0.5 ether);
        assertEq(presale.getContributorCount(), 1);
    }

    function testEarlyBirdBeforeSoftCap() public {
        // Before soft cap: should get 10% bonus
        vm.prank(alice);
        presale.deposit{value: 1 ether}();

        (uint256 actual, uint256 effective) = presale.getContribution(alice);
        assertEq(actual, 1 ether);
        assertEq(effective, 1.1 ether); // 10% bonus
        assertTrue(presale.isEarlyBirdActive());
    }

    function testNoEarlyBirdAfterSoftCap() public {
        // Fill to soft cap with 5 contributors at 1 ETH each
        for (uint160 i = 1; i <= 5; i++) {
            address contributor = address(i);
            vm.deal(contributor, 10 ether);
            vm.prank(contributor);
            presale.deposit{value: 1 ether}();
        }

        assertEq(presale.totalRaised(), 5 ether);
        assertFalse(presale.isEarlyBirdActive()); // Soft cap reached

        // Next deposit should NOT get early bird bonus
        vm.prank(alice);
        presale.deposit{value: 1 ether}();

        (uint256 actual, uint256 effective) = presale.getContribution(alice);
        assertEq(actual, 1 ether);
        assertEq(effective, 1 ether); // No bonus!
    }

    function testEarlyBirdOnSoftCapBoundary() public {
        // Fill to 4.5 ETH (just under soft cap)
        for (uint160 i = 1; i <= 4; i++) {
            address contributor = address(i);
            vm.deal(contributor, 10 ether);
            vm.prank(contributor);
            presale.deposit{value: 1 ether}();
        }

        // Deposit that crosses soft cap boundary — still gets bonus
        // because totalRaised BEFORE this deposit was < softCap
        address crosser = address(5);
        vm.deal(crosser, 10 ether);
        vm.prank(crosser);
        presale.deposit{value: 1 ether}();

        (, uint256 effective) = presale.getContribution(crosser);
        assertEq(effective, 1.1 ether); // Gets bonus — was before soft cap
    }

    function testMinContribution() public {
        vm.prank(alice);
        vm.expectRevert(ArcaPresale.BelowMinimum.selector);
        presale.deposit{value: 0.005 ether}();
    }

    function testMaxContribution() public {
        vm.prank(alice);
        vm.expectRevert(ArcaPresale.AboveMaximum.selector);
        presale.deposit{value: 1.5 ether}();
    }

    function testMaxContributionCumulative() public {
        vm.startPrank(alice);
        presale.deposit{value: 0.8 ether}();

        vm.expectRevert(ArcaPresale.AboveMaximum.selector);
        presale.deposit{value: 0.3 ether}();
        vm.stopPrank();
    }

    function testMultipleContributors() public {
        vm.prank(alice);
        presale.deposit{value: 1 ether}();

        vm.prank(bob);
        presale.deposit{value: 0.5 ether}();

        assertEq(presale.totalRaised(), 1.5 ether);
        assertEq(presale.getContributorCount(), 2);
    }

    function testPresaleExpired() public {
        vm.warp(block.timestamp + 49 hours);

        vm.prank(alice);
        vm.expectRevert(ArcaPresale.PresaleNotActive.selector);
        presale.deposit{value: 0.5 ether}();
    }

    function testHardCapEnforced() public {
        // Fill up to near hard cap with 13 contributors at 0.96 ETH each = 12.48
        for (uint160 i = 1; i <= 13; i++) {
            address contributor = address(i);
            vm.deal(contributor, 10 ether);
            vm.prank(contributor);
            presale.deposit{value: 0.96 ether}();
        }

        // 13 * 0.96 = 12.48 ETH, hard cap is 12.5
        vm.deal(address(14), 10 ether);
        vm.prank(address(14));
        presale.deposit{value: 0.02 ether}();

        assertEq(presale.totalRaised(), 12.5 ether);
    }

    function testRefundWhenSoftCapNotMet() public {
        vm.prank(alice);
        presale.deposit{value: 0.5 ether}();

        vm.warp(block.timestamp + 49 hours);

        uint256 balBefore = alice.balance;
        vm.prank(alice);
        presale.refund();

        assertEq(alice.balance, balBefore + 0.5 ether);
        assertEq(presale.contributions(alice), 0);
    }

    function testNoRefundWhenSoftCapMet() public {
        for (uint160 i = 1; i <= 6; i++) {
            address contributor = address(i);
            vm.deal(contributor, 10 ether);
            vm.prank(contributor);
            presale.deposit{value: 1 ether}();
        }

        vm.warp(block.timestamp + 49 hours);

        vm.prank(address(1));
        vm.expectRevert(ArcaPresale.RefundNotAvailable.selector);
        presale.refund();
    }

    function testSafetyRefundAfter7Days() public {
        for (uint160 i = 1; i <= 6; i++) {
            address contributor = address(i);
            vm.deal(contributor, 10 ether);
            vm.prank(contributor);
            presale.deposit{value: 1 ether}();
        }

        vm.warp(block.timestamp + 48 hours + 7 days + 1);

        uint256 balBefore = address(1).balance;
        vm.prank(address(1));
        presale.refund();
        assertEq(address(1).balance, balBefore + 1 ether);
    }

    function testFinalize() public {
        for (uint160 i = 1; i <= 6; i++) {
            address contributor = address(i);
            vm.deal(contributor, 10 ether);
            vm.prank(contributor);
            presale.deposit{value: 1 ether}();
        }

        vm.warp(block.timestamp + 49 hours);

        uint256 ownerBalBefore = owner.balance;
        presale.finalize();

        assertEq(presale.finalized(), true);
        assertEq(owner.balance, ownerBalBefore + 6 ether);
    }

    function testCannotFinalizeBeforeSoftCap() public {
        vm.prank(alice);
        presale.deposit{value: 0.5 ether}();

        vm.warp(block.timestamp + 49 hours);

        vm.expectRevert(ArcaPresale.SoftCapNotMet.selector);
        presale.finalize();
    }

    function testGetPresaleInfo() public {
        vm.prank(alice);
        presale.deposit{value: 1 ether}();

        (
            uint256 raised,
            uint256 sc,
            uint256 hc,
            uint256 count,
            uint256 remaining,
            bool active,
            bool earlyBird,
            bool fin
        ) = presale.getPresaleInfo();

        assertEq(raised, 1 ether);
        assertEq(sc, SOFT_CAP);
        assertEq(hc, HARD_CAP);
        assertEq(count, 1);
        assertGt(remaining, 0);
        assertTrue(active);
        assertTrue(earlyBird); // Still under soft cap
        assertFalse(fin);
    }

    function testDirectTransfer() public {
        vm.prank(alice);
        (bool success,) = address(presale).call{value: 0.5 ether}("");
        assertTrue(success);
        assertEq(presale.contributions(alice), 0.5 ether);
    }

    receive() external payable {}
}
