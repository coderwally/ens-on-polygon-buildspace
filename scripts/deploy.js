const main = async () => {
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy("love");
    await domainContract.deployed();
  
    console.log("Contract deployed to:", domainContract.address);

    const DOMAIN_TO_DEPLOY = "peace";
  
    // CHANGE THIS DOMAIN TO SOMETHING ELSE! I don't want to see OpenSea full of bananas lol
    let txn = await domainContract.register(DOMAIN_TO_DEPLOY,  {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();
    console.log(`Minted domain ${DOMAIN_TO_DEPLOY}.love`);
  
    txn = await domainContract.setRecord(DOMAIN_TO_DEPLOY, "peace-love.test", "peace@peace-love.test", "@peace_love", "@peacelove");
    await txn.wait();
    console.log(`Set record for ${DOMAIN_TO_DEPLOY}.love`);
  
    const address = await domainContract.getAddress(DOMAIN_TO_DEPLOY);
    console.log(`Owner of domain ${DOMAIN_TO_DEPLOY}: `, address);
  
    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
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