
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC20 - Sample Token", function(){
    let[account1, account2, account3]=[];
    let token;
    let uri='sampleuri.com/';
    let address0="0x0000000000000000000000000000000000000000";
    //begin test
    beforeEach(async ()=>{
        [account1, account2, account3]= await ethers.getSigners();
        const Doogi = await ethers.getContractFactory("Doogi");
        doogi= await Doogi.deploy();
        await doogi.deployed();
    })

    describe("mint", function(){
        it("Should be reverted if mint to zero address", async function(){
            await expect(doogi.mint(address0)).to.be.revertedWith("ERC721: mint to the zero address");
        })
        it("Should mint token correctly", async function(){
            //check account1 mint 
            const mintTx=await doogi.mint(account1.address);
            await expect(mintTx).to.be.emit(doogi, "Transfer").withArgs(address0, account1.address, 1)
            expect(await doogi.balanceOf(account1.address)).to.be.equal(1);
            expect(await doogi.ownerOf(1)).to.be.equal(account1.address);
            
            
            const mintTx1=await doogi.mint(account1.address);
            await expect(mintTx1).to.be.emit(doogi, "Transfer").withArgs(address0, account1.address, 2)
            expect(await doogi.balanceOf(account1.address)).to.be.equal(2);
            expect(await doogi.ownerOf(2)).to.be.equal(account1.address);
        })
    })
    describe("update base URI", function(){
        it("Should update base token uri correctly", async function(){
            await doogi.mint(account1.address);                                                                                                                                                                
            await doogi.updateBaseURI(uri)
            console.log(uri);
            expect(await doogi.tokenURI(1)).to.be.equal(uri+"1");
        })
    })
})