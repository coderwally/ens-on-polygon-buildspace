//import { BigNumber} from 'ethers';

const BigNumber = require('ethers');

const main = async () => {
    // The first return is the deployer, the second is a random account
    const [owner, randomPerson] = await hre.ethers.getSigners();
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy('test');
    await domainContract.deployed();
    console.log("Contract deployed to: ", domainContract.address);
    console.log("Contract deployed by: ", owner.address);

    const validDomain1 = "metal";
  
    let txn = await domainContract.register(
        validDomain1,
        {value: ethers.utils.parseEther("0.1")
    });
    const txReceipt = await txn.wait();

    const registeredEvents = txReceipt.events.filter((el) => {return el.event == "DomainRegistered"});
    const mintedTokenId = registeredEvents[0].args["_tokenId"].toNumber();

    //const metadata = await domainContract.getJsonMetadata(validDomain1, "www", "email");

    txn = await domainContract.setRecord(validDomain1, "www2", "email2");
    const txRecord = await txn.wait();

    const uri = await domainContract.tokenURI(mintedTokenId);
    console.log(uri);
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