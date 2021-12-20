import { deployContractByName, executeScript, mintFlow, sendTransaction } from "flow-js-testing";

import {
	getItemsAdminAddress,
	getItemsNonAdminAddress,
} from "./common";

// Items types
export const typeID1 = 1000;

/*
 * Deploys NonFungibleToken and Items contracts to Admin.
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const deployItems = async () => {
	const Admin = await getItemsAdminAddress();
	await mintFlow(Admin, "10.0");

	await deployContractByName({ to: Admin, name: "NonFungibleToken" });

	const addressMap = { NonFungibleToken: Admin };
	return deployContractByName({ to: Admin, name: "Items", addressMap });
};

/*
 * Setups Items collection on account and exposes public capability.
 * @param {string} account - account address
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const setupItemsOnAccount = async (account) => {
	const name = "admin/setup_account";
	const signers = [account];

	return sendTransaction({ name, signers });
};


/*
 * Returns Items totalSupply.
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64} - number of NFT minted so far
 * */
export const getTotalSupply = async () => {
	const name = "collections/get_totalSupply";

	return executeScript({ name });
};

export const createArtist = async (metadata) => {

	const Admin = await getItemsAdminAddress();
	const name = "admin/create_artist";
	const args = [metadata];
	const signers = [Admin];

	return sendTransaction({ name, args, signers });
};

export const getArtistMetadata = async (id) => {

	const Admin = await getItemsAdminAddress();

	const name = "artists/get_artist_metadata";
	const args = [id];
	const signers = [Admin];

	return executeScript({ name, args, signers });
};

export const createPiece = async (artistID, metadata) => {

	const Admin = await getItemsAdminAddress();
	const name = "admin/create_piece";
	const args = [artistID, metadata];
	const signers = [Admin];

	return sendTransaction({ name, args, signers });
};

export const getPieceMetadata = async (id) => {

	const Admin = await getItemsAdminAddress();

	const name = "pieces/get_piece_data";
	const args = [id];
	const signers = [Admin];

	return executeScript({ name, args, signers });
};

export const mintItemsAdmin = async (pieceID, recipient) => {
	const Admin = await getItemsAdminAddress();

	const name = "admin/mint_item";
	const args = [pieceID, recipient];
	const signers = [Admin];

	return sendTransaction({ name, args, signers });
};

export const mintItemsNonAdmin = async (pieceID, recipient) => {
	const nonAdmin = await getItemsNonAdminAddress();

	const name = "admin/mint_item";
	const args = [pieceID, recipient];
	const signers = [nonAdmin];

	return sendTransaction({ name, args, signers });
};

export const batchMintItems = async (pieceID, quantity, recipient) => {
	const Admin = await getItemsAdminAddress();

	const name = "admin/batch_mint_item";
	const args = [pieceID, quantity, recipient];
	const signers = [Admin];

	return sendTransaction({ name, args, signers });
};

export const transferItems = async (sender, recipient, itemId) => {
	const name = "admin/transfer_item";
	const args = [recipient, itemId];
	const signers = [sender];

	return sendTransaction({ name, args, signers });
};

export const getItems = async (account, itemID) => {
	const name = "collections/get_item";
	const args = [account, itemID];

	return executeScript({ name, args });
};

export const getCollectionIds = async (account) => {
	const name = "collections/get_collection_ids";
	const args = [account];

	return executeScript({ name, args });
}
