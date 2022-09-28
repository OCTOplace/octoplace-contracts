const SwapNFT = artifacts.require("SwapNFT");
const SwapData = artifacts.require("SwapData");
const NFTContractListing = artifacts.require("NFTContractListing");

contract("SwapNFT", (accounts) => {
    it("Should deploy successfully", async () => {
        const swapNft = await SwapNFT.deployed();
        const swapData= await SwapData.deployed();
        const result1 = await swapData.grantRole(web3.utils.fromAscii("DATA_WRITER"), swapNft.address, {from: accounts[0]});
        const result2 = await swapData.grantRole(web3.utils.fromAscii("DATA_READER"), swapNft.address, {from: accounts[0]});
        
        assert(swapNft.address != "");
        assert(await swapData.hasRole(web3.utils.fromAscii("DATA_WRITER"),swapNft.address), true);
        assert(await swapData.hasRole(web3.utils.fromAscii("DATA_READER"),swapNft.address), true);
    }) 
    it("Should add a listing", async () => {
        const swapNft = await SwapNFT.deployed();
        const listNftContract = await NFTContractListing.deployed();
        console.log("NFT contract", listNftContract.address)
        await listNftContract.setApprovalForAll(swapNft.address, true, {from: accounts[0]})
        const result = swapNft.createListing(1, listNftContract.address, {from:accounts[0]})
        console.log(result.logs[0]);
    })
})