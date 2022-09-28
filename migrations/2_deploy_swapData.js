const SwapData = artifacts.require("SwapData");
const SwapNFT = artifacts.require("SwapNFT");
const NFTContractListing = artifacts.require("NFTContractListing");
module.exports = function (deployer, network,accounts) {
    deployer.deploy(SwapData, accounts[0], accounts[0], accounts[0]).then(()=>{
       
             deployer.deploy(SwapNFT,accounts[0],SwapData.address);
        
    })
    deployer.deploy(NFTContractListing);
}