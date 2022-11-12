// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { StringUtils } from "./libraries/StringUtils.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "hardhat/console.sol";

contract Domains is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct DomainRecord {
        string name;
        address addr;
        string website;
        string email;
        string twitter;
        string github;
    }

    string public tld;

    DomainRecord[] private domains;

    mapping(string => uint) private domainRecordIndexes;

    uint constant PRICE_LENGTH_3 = 5 * 10**17; // 5 MATIC = 5 000 000 000 000 000 000 (18 decimals). We're going with 0.5 Matic cause the faucets don't give a lot
    uint constant PRICE_LENGTH_4 = 3 * 10**17; // To charge smaller amounts, reduce the decimals. This is 0.3
    uint constant PRICE_LENGTH_OTHER = 1 * 10**17;    

    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.863 42.949c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-10.081 6.032-6.85 3.934-10.081 6.032c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616c-.384-.665-.594-1.418-.608-2.187v-9.31c-.013-.775.185-1.538.572-2.208a4.25 4.25 0 0 1 1.625-1.595l7.884-4.59c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v6.032l6.85-4.065v-6.032c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595L41.456 24.59c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595c-.387.67-.585 1.434-.572 2.208v17.441c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l10.081-5.901 6.85-4.065 10.081-5.901c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v9.311c.013.775-.185 1.538-.572 2.208a4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616c-.385-.665-.594-1.418-.608-2.187v-6.032l-6.85 4.065v6.032c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l14.864-8.655c.657-.394 1.204-.95 1.589-1.616s.594-1.418.609-2.187V55.538c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = '</text></svg>';    

    constructor(string memory _tld) payable ERC721("Love Name Service", "LOVE") {
        tld = _tld;
        console.log("%s name service deployed", _tld);
    }

    // This function will give us the price of a domain based on length
    function price(string calldata name) public pure returns(uint) {
        uint len = StringUtils.strlen(name);
        require(len > 0, "Invalid length");
        if (len == 3) {
            return PRICE_LENGTH_3;
        } else if (len == 4) {
            return PRICE_LENGTH_4;
        } else {
            return PRICE_LENGTH_OTHER;
        }
    }    

    function domainIsRegistered(string memory name) public view returns (bool) {
        for (uint256 i = 0; i < domains.length; i++) {
            if (keccak256(bytes(domains[i].name)) == keccak256(bytes(name))) {
                return true;
            }
        }
        return false;    
    }

    function register(string calldata nameToRegister) public payable {
        require(!domainIsRegistered(nameToRegister), "Domain already registered");

        uint256 _price = price(nameToRegister);
        require(msg.value >= _price, "Not enough MATIC paid");        

        // Combine the name passed into the function with the TLD
        string memory _name = string(abi.encodePacked(nameToRegister, ".", tld));

        // Create the SVG (image) for the NFT with the name
        string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
        uint256 newRecordId = _tokenIds.current();
        uint256 length = StringUtils.strlen(nameToRegister);
        string memory strLen = Strings.toString(length);

        console.log("Registering %s.%s on the contract with tokenID %s", nameToRegister, tld, newRecordId);

        // Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
        string memory json = Base64.encode(
        abi.encodePacked(
            '{"name": "',
            _name,
            '", "description": "A domain on the Love Name Service", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '","length":"',
            strLen,
            '"}'
        ));

        string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

        console.log("\n--------------------------------------------------------");
        console.log("Final tokenURI", finalTokenUri);
        console.log("--------------------------------------------------------\n");

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);

        //Add domain record and save the index where it's stored in the array
        domains.push(DomainRecord({name: nameToRegister, addr: msg.sender, website: "", email: "", twitter: "", github: "" }));
        domainRecordIndexes[nameToRegister] = domains.length - 1;

        _tokenIds.increment();

    }

    function getAddress(string calldata name) public view returns (address) {
        require(domainIsRegistered(name), "Unknown domain");
        return domains[domainRecordIndexes[name]].addr;
    }

    function setRecord(string calldata name, string calldata _website, string calldata _email, string calldata _twitter, string calldata _github) public {
        require(domainIsRegistered(name), "Unknown domain");

        // Check that the owner is the transaction sender
        DomainRecord memory record = domains[domainRecordIndexes[name]];
        require(msg.sender == domains[domainRecordIndexes[name]].addr, "Sender is not the owner of the domain");

        record.website = _website;
        record.email = _email;
        record.twitter = _twitter;
        record.github = _github;

        domains[domainRecordIndexes[name]] = record;
    }

    function getRecord(string calldata name) public view returns(DomainRecord memory) {
        require(domainIsRegistered(name), "Unknown domain");        
        return domains[domainRecordIndexes[name]];
    }

    function getAllRecords() public view returns(DomainRecord[] memory) {
        return domains;
    }
}