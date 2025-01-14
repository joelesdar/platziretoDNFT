// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract ethereumHistory is ERC721, ERC721URIStorage, KeeperCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;
 
   // Metadata information for each stage of the NFT on IPFS.
    string[] IpfsUri = [
        "https://gateway.pinata.cloud/ipfs/QmQxhBmh6AxR34GDBXHuSRPLvVXXeR27CTcStVMYyB8G4W",
        "https://gateway.pinata.cloud/ipfs/QmQRUE5czXDdqTvuMgosSEBYpo8VFD1SNXZTdmMr4XFpu2",
        "https://gateway.pinata.cloud/ipfs/QmaLvfW4Lafi78dun5DMKXd2Nro6LPWzqHXnoj71cw9KPM",
        "https://gateway.pinata.cloud/ipfs/QmRdsnSzwxbAwTDu5eu2SuPr8PVm6dVPtDqJi3G2AzXaFZ",
        "https://gateway.pinata.cloud/ipfs/QmYWEjTT1YjuhykDHmy3ynzzPRhfRfxAAjdc2nvx57Cdox"
    ]; 

    uint256 lastTimeStamp;
    uint256 interval;

    constructor(uint _interval) ERC721("Ethereum History", "ETHIS") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        uint256 tokenId = tokenIdCounter.current() - 1;
        bool done;
        if (developmentStage(tokenId) >= 4) {
            done = true;
        }
        upkeepNeeded = !done && ((block.timestamp - lastTimeStamp) > interval);        
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;            
            uint256 tokenId = tokenIdCounter.current() - 1;
            growDevelopment(tokenId);
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }

    function safeMint(address to) public {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function growDevelopment(uint256 _tokenId) public {
        if(developmentStage(_tokenId) >= 4){return;}
        // Get the current stage of the development and add 1
        uint256 newVal = developmentStage(_tokenId) + 1;
        // store the new URI
        string memory newUri = IpfsUri[newVal];
        // Update the URI
        _setTokenURI(_tokenId, newUri);
    }

    // determine the stage of the development growth
    function developmentStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        // Ethereum White Paper
        if (compareStrings(_uri, IpfsUri[0])) {
            return 0;
        }
        // Frontier
        if (
            compareStrings(_uri, IpfsUri[1]) 
        ) {
            return 1;
        }
        // Homestead
        if (
            compareStrings(_uri, IpfsUri[2]) 
        ) {
            return 2;
        }
        // Metropolis
        if (
            compareStrings(_uri, IpfsUri[3]) 
        ) {
            return 3;
        }
        // Serenity
        return 4;
    }

    // helper function to compare strings
    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    // The following functions is an override required by Solidity.
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    // The following functions is an override required by Solidity.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}