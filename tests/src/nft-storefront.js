import { 
	sendTransactionWithErrorRaised, 
	executeScriptWithErrorRaised, 
	deployContractByNameWithErrorRaised 
} from "./common"
import { getAdminAddress } from "./common";
import { deployItems, setupItemsOnAccount } from "./items";

/*
 * Deploys Items and NFTStorefront contracts to Admin.
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const deployNFTStorefront = async () => {
	const Admin = await getAdminAddress();

	await deployItems();

	const addressMap = {
		NonFungibleToken: Admin,
		Items: Admin,
	};

	return deployContractByNameWithErrorRaised({ to: Admin, name: "NFTStorefront", addressMap });
};

/*
 * Sets up NFTStorefront.Storefront on account and exposes public capability.
 * @param {string} account - account address
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const setupStorefrontOnAccount = async (account) => {
	// Account shall be able to store Items
	await setupItemsOnAccount(account);

	const name = "nftStorefront/setup_account";
	const signers = [account];

	return sendTransactionWithErrorRaised({ name, signers });
};

/*
 * Lists item with id equal to **item** id for sale with specified **price**.
 * @param {string} seller - seller account address
 * @param {UInt64} itemId - id of item to sell
 * @param {UFix64} price - price
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const createListing = async (seller, itemId, price) => {
	const name = "nftStorefront/create_listing";
	const args = [itemId, price];
	const signers = [seller];

	return sendTransactionWithErrorRaised({ name, args, signers });
};

/*
 * Buys item with id equal to **item** id for **price** from **seller**.
 * @param {string} buyer - buyer account address
 * @param {UInt64} resourceId - resource uuid of item to sell
 * @param {string} seller - seller account address
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const purchaseListing = async (buyer, resourceId, seller) => {
	const name = "nftStorefront/purchase_listing";
	const args = [resourceId, seller];
	const signers = [buyer];

	return sendTransactionWithErrorRaised({ name, args, signers });
};

/*
 * Removes item with id equal to **item** from sale.
 * @param {string} owner - owner address
 * @param {UInt64} itemId - id of item to remove
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const removeListing = async (owner, itemId) => {
	const name = "nftStorefront/remove_listing";
	const signers = [owner];
	const args = [itemId];

	return sendTransactionWithErrorRaised({ name, args, signers });
};

/*
 * Returns the number of items for sale in a given account's storefront.
 * @param {string} account - account address
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64}
 * */
export const getListingCount = async (account) => {
	const name = "nftStorefront/get_listings_length";
	const args = [account];

	return executeScriptWithErrorRaised({ name, args });
};
