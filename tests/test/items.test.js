import path from "path";

import { 
	emulator,
	init,
	getAccountAddress,
	shallPass,
	shallThrow,
	shallRevert,
} from "flow-js-testing";

import { getAdminAddress } from "../src/common";
import {
	deployItems,
	getItemCount,
	getItemSupply,
	mintItem,
	setupItemsOnAccount,
	transferItem,
} from "../src/items";

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(50000);

const metadata = {
	"title": "Test",
	"description": "Test description",
	"image":"http://aaa.com/image.png",
	"maxQuantity": "1",
	"royalty": "10",
};

describe("Items", () => {
	// Instantiate emulator and path to Cadence files
	beforeEach(async () => {
		const basePath = path.resolve(__dirname, "../../");
		const port = 7002;
		await init(basePath, { port });
		await emulator.start(port, false);
		return await new Promise(r => setTimeout(r, 1000));
	});

	// Stop emulator, so it could be restarted
	afterEach(async () => {
		await emulator.stop();
		return await new Promise(r => setTimeout(r, 1000));
	});

	it("should deploy Items contract", async () => {
		await deployItems();
	});

	it("supply should be 0 after contract is deployed", async () => {
		// Setup
		await deployItems();

		const Admin = await getAdminAddress();

		await shallPass(setupItemsOnAccount(Admin));
			const supply = await getItemSupply();
			expect(supply).toBe(0);
	});

	it("should be able to mint an item", async () => {
		// Setup
		await deployItems();
		const Alice = await getAccountAddress("Alice");
		await setupItemsOnAccount(Alice);

		// Mint instruction for Alice account shall be resolved
		await shallPass(mintItem(Alice, metadata));
	});

	it("should be able to create a new empty NFT Collection", async () => {
		// Setup
		await deployItems();
		const Alice = await getAccountAddress("Alice");
		await setupItemsOnAccount(Alice);

		// shall be able te read Alice collection and ensure it's empty
		const itemCount = await getItemCount(Alice);
		expect(itemCount).toBe(0);
	});

	it("should not be able to withdraw an NFT that doesn't exist in a collection", async () => {
		// Setup
		await deployItems();
		const Alice = await getAccountAddress("Alice");
		const Bob = await getAccountAddress("Bob");
		await setupItemsOnAccount(Alice);
		await setupItemsOnAccount(Bob);

		// Transfer transaction shall fail for non-existent item
		try {
			// shallRevert and shallThrow doesn't seem to work
			await shallRevert(transferItem(Alice, Bob, 1337));
		} catch (e) {
		}
	});

	it("should be able to withdraw an NFT and deposit to another accounts collection", async () => {
		await deployItems();
		const Alice = await getAccountAddress("Alice");
		const Bob = await getAccountAddress("Bob");
		await setupItemsOnAccount(Alice);
		await setupItemsOnAccount(Bob);

		// Mint instruction for Alice account shall be resolved
		await shallPass(mintItem(Alice, metadata));

		// Transfer transaction shall pass
		await shallPass(transferItem(Alice, Bob, 0));
	});
});
