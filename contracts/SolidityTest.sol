//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@1001-digital/erc721-extensions/contracts/LinearlyAssigned.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract SolidityTest is Ownable, ERC721, LinearlyAssigned {
    uint256 public constant PRICE = 1 ether / 10;
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant MAX_PER_TX = 5;

    modifier onlyUnderLimitPerTx(uint256 amount) {
        require(amount <= MAX_PER_TX, "can't mint more than limit per tx");
        _;
    }

    constructor() ERC721("Test", "TST") LinearlyAssigned(MAX_SUPPLY, 1) {
    }

    function claim() external {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success);
    }

    function mint(uint256 amount)
        external
        payable
        ensureAvailabilityFor(amount)
        onlyUnderLimitPerTx(amount)
    {
        require(PRICE * amount == msg.value, "insufficient fund");
        for (uint256 index = 0; index < amount; index++) {
            _safeMint(msg.sender, nextToken());
        }
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return super.ownerOf(tokenId);
    }
}
