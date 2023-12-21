import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
  import { expect } from "chai";
  import { ethers } from "hardhat";
  
  describe("Token Exchange", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployBefore() {
      // Set the price we are expecting to get from the DAPI
      // For ease I'm making ETH work 1000 USD, you can change this price but will reflect the amount of tokens you recieve
      const price = ethers.parseEther("1000");
      // We get the current time from Hardhat Network
      const timestamp = await time.latest();
  
      // Contracts are deployed using the first signer/account by default
      const [owner, otherAccount] = await ethers.getSigners();
  
      //Deploy our mock Oracle contract, so when we call it we get a value back
      const MockDapi = await ethers.getContractFactory("MockDapiProxy");
      const mockDapi = await MockDapi.deploy();
      await mockDapi.waitForDeployment();
  
      //Set our mock values for the dAPI to return
      //We can't call oracles on local node, so we are making our own
      await mockDapi.setDapiValues(price, timestamp);
  
      const TokenEx = await ethers.getContractFactory("PriceFeed");
      const tokenEx = await TokenEx.deploy();
  
      await tokenEx.waitForDeployment();
  
      //Set our mock Proxy address that will return static values
      await tokenEx.setProxyAddress(mockDapi.getAddress());
  
      return { tokenEx, owner, otherAccount, mockDapi, timestamp };
    }
  
    describe("Deployment", function () {
      it("Should set the right owner", async function () {
        const { tokenEx, owner } = await loadFixture(deployBefore);
        expect(await tokenEx.owner()).to.equal(owner.address);
      });
    });
  
    describe("Set Price Feed", function () {
      it("Only we can set the price feed and read", async function () {
        const { tokenEx, owner, otherAccount, mockDapi, timestamp } = await loadFixture(deployBefore);
        await expect(tokenEx.connect(otherAccount).setProxyAddress('0x13d1Ed8c24911d88e6155cE32A66908399C97924')).to.be.revertedWith('Ownable: caller is not the owner');
        await tokenEx.setProxyAddress(mockDapi.getAddress());

        let [price, time] = await tokenEx.readDataFeed();
        //verify our mock values are set
        console.log("Price: ", price.toString());
        console.log("Time: ", time.toString());
        expect(price).to.equal(ethers.parseEther("1000"));
        expect(time).to.equal(await timestamp);
      });
    });
    
  });
  