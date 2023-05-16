// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

/// @dev This is a contract used to add ERC2981 support to ERC721 and 1155
/// @dev This implementation has the same royalties for each and every tokens
contract NFTexample is ERC721 {
    constructor () ERC721("NFT Example", "NEFT"){
        for(uint8 i = 0; i < 10 ; i++){
            _safeMint(i+1, msg.sender)
        }
    }
}
