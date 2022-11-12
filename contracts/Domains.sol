// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

    //List of all domains
    DomainRecord[] private domains;

    mapping(string => uint) private domainRecordIndexes;

    constructor() {
        console.log("Whippletree Domain Service - 2022");
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