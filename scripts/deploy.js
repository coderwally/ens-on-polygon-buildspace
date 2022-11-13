const main = async () => {
    const FIRST_DOMAIN_TO_MINT = "launch";
    const TLD = "love";
  
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy(TLD);
    await domainContract.deployed();
  
    console.log("Contract deployed to:", domainContract.address);
  
    // CHANGE THIS DOMAIN TO SOMETHING ELSE! I don't want to see OpenSea full of bananas lol
    let txn = await domainContract.register(FIRST_DOMAIN_TO_MINT,  {value: hre.ethers.utils.parseEther('0.05')});
    await txn.wait();
    console.log(`Minted domain ${FIRST_DOMAIN_TO_MINT}.${TLD}`);
  
    txn = await domainContract.setRecord(FIRST_DOMAIN_TO_MINT, "launch", "launch");
    await txn.wait();
    console.log(`Set record for ${FIRST_DOMAIN_TO_MINT}.${TLD}`);
  
    const address = await domainContract.getAddress(FIRST_DOMAIN_TO_MINT);
    console.log(`Owner of domain ${FIRST_DOMAIN_TO_MINT}.${TLD}: `, address);
  
    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));

    const allRecords = await domainContract.getAllRecords();
    console.log(allRecords);
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