
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC20 - Sample Token", function(){
    let[account1, account2, account3]=[];
    let token;
    let amount=100;
    let totalSupply=1000000;

    //test
    beforeEach(async ()=>{
        //create account from ether network
        [account1, account2, account3]=await ethers.getSigners();
        const Token= await ethers.getContractFactory("SampleToken");
        token=await Token.deploy();
        await token.deployed();
        
    })

    describe("common", ()=>{
        it("total supply must return right value", async ()=>{
            expect(await token.totalSupply()).to.equal(totalSupply)
        })
        it("balances account1 must return right value", async ()=>{
            expect(await token.balanceOf(account1.address)).to.equal(totalSupply)
            
        })
        it("balances account1 must return right value", async ()=>{
            expect(await token.balanceOf(account2.address)).to.equal(0)
            
        })
        it("allowance of account1 to account2 must return right value", async ()=>{
            expect(await token.allowance(account1.address, account2.address)).to.equal(0)
            
        })
    })
    describe("transfer", ()=>{
        it("transfer should revert if amount  exceeds balance", async ()=>{

            // check xem chuyen qua so balance ko thi expect se revert
             await expect(token.connect(account1).transfer(account2.address, totalSupply+1)).to.be.revertedWith("Not enough balance");
            
        })
        it("transfer should work correctly", async ()=>{
            let transferTx=await token.transfer(account2.address, amount);

            //check balance cua vi gui va vi nhan xem value dung ko
            expect(await token.balanceOf(account1.address)).to.equal(totalSupply-amount)
            expect(await token.balanceOf(account2.address)).to.equal(amount)

            //check event emit co thuc hien duoc khong
            await expect(transferTx).to.emit(token, "Transfer")
            .withArgs(account1.address, account2.address, amount )
        })
        
    })
    describe("transferFrom", ()=>{
        it("transfer from should revert if amount  exceeds balance", async ()=>{

            //dung o account2 transfer amount tu account1 sang account3, TH qua balance
           await  expect(token.connect(account2).transferFrom(account1.address, account3.address, totalSupply+1)).to.be.revertedWith("Not enough balance");
            
        })
            //TH du account1 du balance nhung so du allowance khong du
        it("transfer from should revert if amount  exceeds allowance amount", async ()=>{
            await expect(token.connect(account2).transferFrom(account1.address, account3.address, amount)).to.be.revertedWith("1");
    
        })

            //TH du allowance
        it("transfer from succesfully", async ()=>{
            await token.connect(account1).approve(account2.address, amount);
            let transferTx= token.connect(account2).transferFrom(account1.address, account3.address, amount-1)

            //check event emit co thuc hien duoc khong
            await expect(transferTx).to.emit(token, "Transfer")
            .withArgs(account1.address, account3.address, amount-1 )
        })

        
    })
    describe("approve", ()=>{
        it("approve successfully", async ()=>{
            let approveTx=await token.connect(account1).approve(account2.address, amount);
            expect(await token.allowance(account1.address, account2.address)).to.equal(amount)
            //check event emit co thuc hien duoc khong
            await expect(approveTx).to.emit(token, "Approval")
            .withArgs(account1.address, account2.address, amount)
        })
    })
    // describe("allowance", ()=>{

    // })
})