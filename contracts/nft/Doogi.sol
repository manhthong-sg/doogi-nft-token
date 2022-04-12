//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Doogi is ERC721, Ownable{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCount;

    string private _baseTokenURI;

    constructor() ERC721("Doogi","DOO") {

    }

    //mint
    function mint(address _to) public onlyOwner returns(uint256){
       _tokenIdCount.increment();
       uint256 _tokenId =_tokenIdCount.current();
       _mint(_to, _tokenId);

       return _tokenId;
    }

    function baseURI() internal view virtual returns (string memory) {
        return _baseTokenURI;
    }

    //update new base uri
    function updateBaseURI(string memory newBaseURI) public returns (string memory) {
        _baseTokenURI=newBaseURI;
        return _baseTokenURI;
    }


}
