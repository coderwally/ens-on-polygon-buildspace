// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { StringUtils } from "./libraries/StringUtils.sol";
import "hardhat/console.sol";

contract Domains {
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

    constructor(string memory _tld) payable {
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

    function register(string calldata nameToRegister) public {
        require(!domainIsRegistered(nameToRegister), "Domain already registered");

        //Add domain record and save the index where it's stored in the array
        domains.push(DomainRecord({name: nameToRegister, addr: msg.sender, website: "", email: "", twitter: "", github: "" }));
        domainRecordIndexes[nameToRegister] = domains.length - 1;
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