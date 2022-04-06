import { mintFlow } from "flow-js-testing";
import { 
	sendTransactionWithErrorRaised, 
	executeScriptWithErrorRaised, 
	deployContractByNameWithErrorRaised 
} from "./common"
import { getAdminAddress } from "./common";

/*
 * Deploys NonFungibleToken and Items contracts to Admin.
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const deployItems = async () => {
	const Admin = await getAdminAddress();
	await mintFlow(Admin, "10.0");

	await deployContractByNameWithErrorRaised({ to: Admin, name: "NonFungibleToken" });
	await deployContractByNameWithErrorRaised({ to: Admin, name: "MetadataViews" });

	const addressMap = { 
		NonFungibleToken: Admin,
		MetadataViews: Admin,
	};
	
	return deployContractByNameWithErrorRaised({ to: Admin, name: "Items", addressMap });
};

/*
 * Setups Items collection on account and exposes public capability.
 * @param {string} account - account address
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const setupItemsOnAccount = async (account) => {
	const name = "items/setup_account";
	const signers = [account];

	return sendTransactionWithErrorRaised({ name, signers });
};

/*
 * Returns Items supply.
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64} - number of NFT minted so far
 * */
export const getItemSupply = async () => {
	const name = "../scripts/items/get_items_supply";

	return executeScriptWithErrorRaised({ name });
};

/*
 * Mints Item of a specific **itemType** and sends it to **recipient**.
 * @param {UInt64} itemType - type of NFT to mint
 * @param {string} recipient - recipient account address
 * @throws Will throw an error if execution will be halted
 * @returns {Promise<*>}
 * */
export const mintItem = async (recipient, metadata, royalties) => {
	const Admin = await getAdminAddress();

	const name = "items/mint_item";
	const args = [recipient, metadata, royalties];
	const signers = [Admin];

	return sendTransactionWithErrorRaised({ name, args, signers });
};

/*
 * Transfers Item NFT with id equal **itemId** from **sender** account to **recipient**.
 * @param {string} sender - sender address
 * @param {string} recipient - recipient address
 * @param {UInt64} itemId - id of the item to transfer
 * @throws Will throw an error if execution will be halted
 * @returns {Promise<*>}
 * */
export const transferItem = async (sender, recipient, itemId) => {
	const name = "items/transfer_item";
	const args = [recipient, itemId];
	const signers = [sender];

	return sendTransactionWithErrorRaised({ name, args, signers });
};

/*
 * Modify an Item's metadata with id equal **itemId** from **sender** account
 * @param {string} sender - sender address
 * @param {UInt64} itemId - id of the item to transfer
 * @throws Will throw an error if execution will be halted
 * @returns {Promise<*>}
 * */
export const modifyItemMetadata = async (sender, itemId) => {
	const name = "items/modify_item_metadata";
	const args = [itemId];
	const signers = [sender];

	return sendTransactionWithErrorRaised({ name, args, signers });
};

/*
 * Returns the Item NFT with the provided **id** from an account collection.
 * @param {string} account - account address
 * @param {UInt64} itemID - NFT id
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64}
 * */
export const getItem = async (account, itemID) => {
	const name = "../scripts/items/get_item";
	const args = [account, itemID];

	return executeScriptWithErrorRaised({ name, args });
};

/*
 * Returns the number of  Items in an account's collection.
 * @param {string} account - account address
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64}
 * */
export const getItemCount = async (account) => {
	const name = "../scripts/items/get_collection_length";
	const args = [account];

	return executeScriptWithErrorRaised({ name, args });
};

/*
 * Returns Item metadata.
 * @throws Will throw an error if execution will be halted
 * @returns {String:String} - metadata for that item
 * */
export const getItemMetadata = async (account, itemId) => {
	const name = "../scripts/items/get_item_metadata";
	const args = [account, itemId]

	return executeScriptWithErrorRaised({ name, args});
};


export const getItemRoyalties = async (account, itemId) => {
	const name = "../scripts/items/get_item_royalties";
	const args = [account, itemId]

	return executeScriptWithErrorRaised({ name, args});
};
