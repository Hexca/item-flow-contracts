import path from "path";

import { 
	emulator,
	init,
	getAccountAddress,
	shallPass,
	mintFlow,
} from "flow-js-testing";

import {
	toUFix64,
	extractMintedItemIDFromTx,
} from "../src/common";

import { 
	getItemCount,
	mintItem,
	getItem,
} from "../src/items-with-org";
import {
	deployNFTStorefront,
	createListing,
	purchaseListing,
	removeListing,
	setupStorefrontOnAccount,
	getListingCount,
	getFlowBalance,
} from "../src/nft-storefront-with-org";

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(500000);

const metadata = {
	"title": "Test",
	"description": "Test description",
	"image":"http://aaa.com/image.png",
	"maxQuantity": "1",
	"royalty": "10",
};



describe("NFT With Org Storefront", () => {
	beforeEach(async () => {
		const basePath = path.resolve(__dirname, "../../");
		const port = 7003;
		await init(basePath, { port });
		await emulator.start(port, false);
		return await new Promise(r => setTimeout(r, 1000));
	});

	// Stop emulator, so it could be restarted
	afterEach(async () => {
		await emulator.stop();
		return await new Promise(r => setTimeout(r, 1000));
	});

	it("should deploy NFTStorefront contract", async () => {
		await shallPass(deployNFTStorefront());
	});

	it("should be able to create an empty Storefront", async () => {
		// Setup
		await deployNFTStorefront();
		const Alice = await getAccountAddress("Alice");

		await shallPass(setupStorefrontOnAccount(Alice));
	});

	it("should be able to create a listing", async () => {
		// Setup
		await deployNFTStorefront();
		const Alice = await getAccountAddress("Alice");
		await setupStorefrontOnAccount(Alice);


		// Mint Item for Alice's account
		await shallPass(mintItem(Alice, metadata));

		const itemID = 0;

		await shallPass(createListing(Alice, itemID, toUFix64(1.11), {}));
	});

	it("should be able to accept a listing", async () => {
		// Setup
		await deployNFTStorefront();

		// Setup seller account
		const Alice = await getAccountAddress("Alice");
		await setupStorefrontOnAccount(Alice);

		await mintItem(Alice, metadata);

		const itemId = 0;

		// Setup buyer account
		const Bob = await getAccountAddress("Bob");
		await setupStorefrontOnAccount(Bob);

		await shallPass(mintFlow(Bob, toUFix64(100)));

		// Bob shall be able to buy from Alice
		const sellItemTransactionResult = await shallPass(createListing(Alice, itemId, toUFix64(1.11), {}));

		const listingAvailableEvent = sellItemTransactionResult.events[0];
		const listingResourceID = listingAvailableEvent.data.listingResourceID;

		await shallPass(purchaseListing(Bob, listingResourceID, Alice));

		const itemCount = await getItemCount(Bob);
		expect(itemCount).toBe(1);

		const listingCount = await getListingCount(Alice);
		expect(listingCount).toBe(0);
	});

	it("should be able to remove a listing", async () => {
		// Deploy contracts
		await shallPass(deployNFTStorefront());

		// Setup Alice account
		const Alice = await getAccountAddress("Alice");
		await shallPass(setupStorefrontOnAccount(Alice));

		// Mint instruction shall pass
		const mintTx = await shallPass(mintItem(Alice, metadata, {}));
		const itemId = extractMintedItemIDFromTx(mintTx);

		await getItem(Alice, itemId);

		// Listing item for sale shall pass
		const sellItemTransactionResult = await shallPass(createListing(Alice, itemId, toUFix64(1.11), {}));

		const listingAvailableEvent = sellItemTransactionResult.events[0];
		const listingResourceID = listingAvailableEvent.data.listingResourceID;

		// Alice shall be able to remove item from sale
		await shallPass(removeListing(Alice, listingResourceID));

		const listingCount = await getListingCount(Alice);
		expect(listingCount).toBe(0);
	});

	it("should be able to create a listing with roylaties", async () => {
		// Setup
		await deployNFTStorefront();
		const Alice = await getAccountAddress("Alice");
		await setupStorefrontOnAccount(Alice);

		const Charlie = await getAccountAddress("Charlie");
		await setupStorefrontOnAccount(Charlie);

		const entries = new Map([
			[Charlie, 0.1]
		]);
		
		const obj = Object.fromEntries(entries);
		

		// Mint Item for Alice's account
		await shallPass(mintItem(Alice, metadata, obj));

		const itemID = 0;

		await shallPass(createListing(Alice, itemID, toUFix64(1.11), obj));
	});

	it("should be able to accept a listing with roylaties", async () => {
		// Setup
		await deployNFTStorefront();

		// Setup seller account
		const Alice = await getAccountAddress("Alice");
		await setupStorefrontOnAccount(Alice);
		
		const Charlie = await getAccountAddress("Charlie");
		await setupStorefrontOnAccount(Charlie);

		const entries = new Map([
			[Charlie, 0.1]
		]);
		
		await mintItem(Alice, metadata);

		const itemId = 0;

		// Setup buyer account
		const Bob = await getAccountAddress("Bob");
		await setupStorefrontOnAccount(Bob);

		await shallPass(mintFlow(Bob, toUFix64(100)));

		const obj = Object.fromEntries(entries);

		// Bob shall be able to buy from Alice
		const sellItemTransactionResult = await shallPass(createListing(Alice, itemId, toUFix64(1), obj));

		const listingAvailableEvent = sellItemTransactionResult.events[0];
		const listingResourceID = listingAvailableEvent.data.listingResourceID;

		await shallPass(purchaseListing(Bob, listingResourceID, Alice));

		const itemCount = await getItemCount(Bob);
		expect(itemCount).toBe(1);

		const listingCount = await getListingCount(Alice);
		expect(listingCount).toBe(0);

		const aliceBalance = await getFlowBalance(Alice);
		expect(aliceBalance).toBe("0.90100000"); // why there is a 0.1% difference?

		const charlieBalance = await getFlowBalance(Charlie);
		expect(charlieBalance).toBe("0.10100000"); // why there is a 0.1% difference?
	});
});
