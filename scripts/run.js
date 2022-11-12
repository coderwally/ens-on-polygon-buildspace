const main = async () => {
    // The first return is the deployer, the second is a random account
    const [owner, randomPerson] = await hre.ethers.getSigners();
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy('love');
    await domainContract.deployed();
    console.log("Contract deployed to: ", domainContract.address);
    console.log("Contract deployed by: ", owner.address);

    const validDomain1 = "domain1";
    const validDomain2 = "second-test-domain";
    const validDomain3 = "third-test-domain";
    const invalidDomain = "invalid-domain-name";
  
    let txn = await domainContract.register(
        validDomain1,
        {value: ethers.utils.parseEther("1.0")
    });
    await txn.wait();

    //const allDomains = await domainContract.getAllRecords();
    //console.log(allDomains);

    const domainAddress = await domainContract.getAddress(validDomain1);
    console.log(`Owner of domain ${validDomain1}: `, domainAddress);

    let txnSetRecord = await domainContract.setRecord(validDomain1, "homepage123", "email123", "twitter123", "github123")
    await txnSetRecord.wait();

    //const domainRecordAfter = await domainContract.getRecord(validDomain1);
    //console.log('Domain record after setting:');
    //console.log(domainRecordAfter);    
  
    // Trying to set a record that doesn't belong to me!
    //txn = await domainContract.connect(randomPerson).setRecord(validDomain1, "hijack", "hijack", "hijack", "hijack");
    //await txn.wait();
  }
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();