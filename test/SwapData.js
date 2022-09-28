const SwapData = artifacts.require("SwapData");

contract('SwapData', (accounts) => {
    it("Should deploy contract successfully", async () => {
        const swapData = await SwapData.deployed();
        assert(swapData.address != "");
    })

    it("account 0 should have admin Role", async () => {
        const swapData = await SwapData.deployed();
        assert(await swapData.hasRole('0x00',accounts[0]), true);
    })

    it("account 1 should not have admin Role", async () => {
        const swapData = await SwapData.deployed();
       const status = await swapData.hasRole('0x00',accounts[1])
        assert(status == false);
    })

    it("account 1 should be granted admin role by account 0", async () => {
        const swapData = await SwapData.deployed();
        await swapData.grantRole('0x00',accounts[1], {from: accounts[0]});
        assert(await swapData.hasRole('0x00',accounts[1]), true);
    })

    it("account 1 should be revoked admin role by account 0", async () => {
        const swapData = await SwapData.deployed();
       const result =  await swapData.revokeRole('0x00',accounts[1], {from: accounts[0]});
       assert(result.logs[0].event=="RoleRevoked")
       assert(result.logs[0].args[0]=='0x0000000000000000000000000000000000000000000000000000000000000000')
       assert(result.logs[0].args[1]==accounts[1])
       assert(result.logs[0].args[2]==accounts[0])
        assert(await swapData.hasRole('0x00',accounts[1])==false);
    })

    it("account 1 should be granted DATA_WRITER role by account 0", async () => {
        const swapData = await SwapData.deployed();

        await swapData.grantRole(web3.utils.fromAscii("DATA_WRITER"),accounts[1], {from: accounts[0]});
        assert(await swapData.hasRole(web3.utils.fromAscii("DATA_WRITER"),accounts[1]), true);
    })

    it("account 1 should be revoked DATA_WRITER role by account 0", async () => {
        const swapData = await SwapData.deployed();
       const result =  await swapData.revokeRole(web3.utils.fromAscii("DATA_WRITER"),accounts[1], {from: accounts[0]});
       assert(result.logs[0].event=="RoleRevoked", "Invalid Event")
       assert(result.logs[0].args[1]==accounts[1])
       assert(result.logs[0].args[2]==accounts[0])
        assert(await swapData.hasRole(web3.utils.fromAscii("DATA_WRITER"),accounts[1])==false);
    })

    it("account 1 should be granted DATA_READER role by account 0", async () => {
        const swapData = await SwapData.deployed();

        await swapData.grantRole(web3.utils.fromAscii("DATA_READER"),accounts[1], {from: accounts[0]});
        assert(await swapData.hasRole(web3.utils.fromAscii("DATA_READER"),accounts[1]), true);
    })

    it("account 1 should be revoked DATA_READER role by account 0", async () => {
        const swapData = await SwapData.deployed();
       const result =  await swapData.revokeRole(web3.utils.fromAscii("DATA_READER"),accounts[1], {from: accounts[0]});
       assert(result.logs[0].event=="RoleRevoked", "Invalid Event")
       assert(result.logs[0].args[1]==accounts[1])
       assert(result.logs[0].args[2]==accounts[0])
        assert(await swapData.hasRole(web3.utils.fromAscii("DATA_READER"),accounts[1])==false);
    })

    it("should add a listing to cotract", async () => {
        const swapData = await SwapData.deployed();
        await swapData.grantRole(web3.utils.fromAscii("DATA_WRITER"),accounts[1], {from: accounts[0]});
        const listing = [
            1,
            accounts[2],
            999,
            accounts[1],
            5000,
            false,
            false,
            web3.utils.toWei("1")
        ]
       const result =  await swapData.addListing(listing, {from: accounts[0]});
       const event = result.logs[0];
       assert(event.event == "SwapListingAdded", "Invalid event raised");
       assert(event.args[0].listingId == 1, "Invalid Id")
       assert(event.args[0].tokenAddress == accounts[2], "Invalid tokenAddress");
       assert(event.args[0].tokenId == 999, "Invalid token id")
       assert(event.args[0].tokenOwner == accounts[1], "Invalid token owner")
       assert(event.args[0].transactionChargeBips == 5000, "Invalid charge bips")
       assert(event.args[0].isCompleted == false, "Invalid completion state")
       assert(event.args[0].isCancelled == false, "Invalid cancel state")
       assert(event.args[0].transactionCharge == web3.utils.toWei("1"), "Invalid txCharge")
    })

    it("should read a listing from cotract", async () => {
        const swapData = await SwapData.deployed();
        await swapData.grantRole(web3.utils.fromAscii("DATA_READER"),accounts[1], {from: accounts[0]});
        
       const result =  await swapData.readListingById(1);
       assert(result.listingId == 1, "Invalid Id")
       assert(result.tokenAddress == accounts[2], "Invalid tokenAddress");
       assert(result.tokenId == 999, "Invalid token id")
       assert(result.tokenOwner == accounts[1], "Invalid token owner")
       assert(result.transactionChargeBips == 5000, "Invalid charge bips")
       assert(result.isCompleted == false, "Invalid completion state")
       assert(result.isCancelled == false, "Invalid cancel state")
       assert(result.transactionCharge == web3.utils.toWei("1"), "Invalid txCharge")
    })

    it("should update a listing in contract", async () => {
        const swapData = await SwapData.deployed();
        await swapData.grantRole(web3.utils.fromAscii("DATA_WRITER"),accounts[1], {from: accounts[0]});
        const listing = [
            1,
            accounts[2],
            699,
            accounts[1],
            5000,
            false,
            false,
            web3.utils.toWei("1")
        ]
       await swapData.updateListing(listing, {from: accounts[0]});
       const result =  await swapData.readListingById(1);
       assert(result.listingId == 1, "Invalid Id")
       assert(result.tokenAddress == accounts[2], "Invalid tokenAddress");
       assert(result.tokenId == 699, "Invalid token id")
       assert(result.tokenOwner == accounts[1], "Invalid token owner")
       assert(result.transactionChargeBips == 5000, "Invalid charge bips")
       assert(result.isCompleted == false, "Invalid completion state")
       assert(result.isCancelled == false, "Invalid cancel state")
       assert(result.transactionCharge == web3.utils.toWei("1"), "Invalid txCharge")
    })

    it("should read all listing in cotract", async () => {
        const swapData = await SwapData.deployed();
        await swapData.grantRole(web3.utils.fromAscii("DATA_WRITER"),accounts[1], {from: accounts[0]});
        const listing = [
            2,
            accounts[2],
            699,
            accounts[1],
            5000,
            false,
            false,
            web3.utils.toWei("1")
        ]
       await swapData.addListing(listing, {from: accounts[0]});
       const result =  await swapData.readAllListings();
       assert(result.length == 2, "Invalid Results")
       
    })

    it("should remove a listing in contract", async () => {
        const swapData = await SwapData.deployed();
        await swapData.grantRole(web3.utils.fromAscii("DATA_WRITER"),accounts[1], {from: accounts[0]});
       await swapData.removeListingById(1);
       const result =  await swapData.readListingById(1);
       assert(result.isCancelled == true, "Invalid cancel state")
    })

    it("should add an offer to contract", async () => {
        const swapData = await SwapData.deployed();
        await swapData.grantRole(web3.utils.fromAscii("DATA_WRITER"),accounts[1], {from: accounts[0]});
        const offer = [
            1,
            accounts[3],
            998,
            accounts[4],
            accounts[2],
            999,
            accounts[1],
            5000,
            false,
            false,
            web3.utils.toWei("1")
        ]
       const result =  await swapData.addOffer(offer, {from: accounts[0]});
       const event = result.logs[0];
       assert(event.event == "SwapOfferAdded", "Invalid event raised");
       })
})