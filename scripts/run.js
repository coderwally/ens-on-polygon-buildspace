const main = async () => {
    // The first return is the deployer, the second is a random account
    const [owner, superCoder, randomPerson] = await hre.ethers.getSigners();
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy('love');
    await domainContract.deployed();
    console.log("Contract deployed to: ", domainContract.address);
    console.log("Contract deployed by: ", owner.address);

    const validDomain1 = "domain1";
    const veryLongDomainName = "second-test-domain-with-a-long-name";
    const validDomain3 = "third-test-domain";
    const invalidDomain = "invalid-domain-name";
  
    let txn = await domainContract.register(
        validDomain1,
        {value: ethers.utils.parseEther("10.05")
    });
    await txn.wait();

    try {
    txn = await domainContract.register(
      validDomain1,
      {value: ethers.utils.parseEther("10.05")
    });
    await txn.wait();    
    } catch(error) {
      console.log(error);
    }

    try {
      txn = await domainContract.register(
        veryLongDomainName,
        {value: ethers.utils.parseEther("1.05")
      });
      await txn.wait();    
      } catch(error) {
        console.log(error);
      }    


    txn = await domainContract.connect(superCoder).setRecord(validDomain1, "homepage123");
    await txn.wait();

    //const allDomains = await domainContract.getAllRecords();
    //console.log(allDomains);

    const domainAddress = await domainContract.getAddress(validDomain1);
    console.log(`Owner of domain ${validDomain1}: `, domainAddress);

    let txnSetRecord = await domainContract.setRecord(validDomain1, "homepage123")
    await txnSetRecord.wait();

    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));


    try {
      txn = await domainContract.connect(superCoder).withdraw();
      await txn.wait();
    } catch(error){
      console.log("Could not rob contract");
    }

    let ownerBalance = await hre.ethers.provider.getBalance(owner.address);
    console.log("Balance of owner before withdrawal:", hre.ethers.utils.formatEther(ownerBalance));

    txn = await domainContract.connect(owner).withdraw();
    await txn.wait();    
  
    const contractBalance = await hre.ethers.provider.getBalance(domainContract.address);
    ownerBalance = await hre.ethers.provider.getBalance(owner.address);
  
    console.log("Contract balance after withdrawal:", hre.ethers.utils.formatEther(contractBalance));
    console.log("Balance of owner after withdrawal:", hre.ethers.utils.formatEther(ownerBalance));
  
    const isValid = await domainContract.valid('hello');
    console.log(`Is valid: ${isValid}`);

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