const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Loyal NFT test ", () => {
    let owner;
    let add1;
    let add2;
    let reciever;
    let loyalnft
    let erc20
    before(async () => { 
        [owner, add1, add2, reciever] = await ethers.getSigners();

        let erc20factory = await ethers.getContractFactory("ERC20t");
        erc20 = await erc20factory.deploy();

        let loyalnftFactory = await ethers.getContractFactory("LoyalNFT");
        loyalnft  = await loyalnftFactory.deploy("ip1",erc20.address);
        //; 
        await erc20.connect(add1).mint(10000);
        await erc20.connect(add2).mint(10000);
        // Change state buy/sell
        await loyalnft.connect(owner).toggleSaleState();

    });
    describe("check user buy nft", () => {
        before( async() => {  
            let tx =  await erc20.connect(add1).approve(loyalnft.address,1000)
            tx = await loyalnft.connect(add1).buynft()
            await tx.wait();
        });
        it("Check nft balance eq to 1", async () => {
            expect(await loyalnft.connect(add1).balanceOf(add1.address)).to.equal(1);
        })
        it("Check balance of contract is equal to 1000" , async () => { 
            expect(await erc20.connect(add1).balanceOf(loyalnft.address)).to.equal(1000);
        });
    });
    describe("price will change after 2 nft selled", () => {
        before ( async () => {
            tx =  await erc20.connect(add1).approve(loyalnft.address,1200)
            tx = await loyalnft.connect(add1).buynft()
            await tx.wait()
            tx =  await erc20.connect(add2).approve(loyalnft.address,1200)
            tx = await loyalnft.connect(add2).buynft()
            await tx.wait()
        })
        it("Check price must be equal 1440", async() => {
            expect(await loyalnft.connect(add2).currentPrice()).to.equal(1440)
        })
        
    })
    describe("owner withdraw", () => {
        before (async () => {
            
        })



    })



});