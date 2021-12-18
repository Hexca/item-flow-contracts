import path from "path";
import { emulator, init, getAccountAddress, shallPass, shallResolve, shallRevert, shallThrow  } from "flow-js-testing";


import { getItemAdminAddress, getItemNonAdminAddress } from "./src/common";
import {
  deployItems,
  createArtist,
  getArtistMetadata,
  createPiece,
  getPieceMetadata,
  mintItemAdmin,
  mintItemNonAdmin,
  getItem,
  batchMintItems,
  getTotalSupply,
  setupItemsOnAccount,
  transferItem,
  getCollectionIds,
} from "./src/items";

// Increase timeout if your tests failing due to timeout
jest.setTimeout(50000);

describe("basic-test", ()=>{
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, "../"); 
    // You can specify different port to parallelize execution of describe blocks
    const port = 8080; 
    // Setting logging flag to true will pipe emulator output to console
    const logging = false;
    
    await init(basePath, { port });
    return emulator.start(port, logging);
  });
  
  // Stop emulator, so it could be restarted
  afterEach(async () => {
    return emulator.stop();
  });

  it("shall deploy Items contract", async () => {
    await deployItems();
  });

  it("shall create artist", async () => {
    await deployItems();

    await shallPass(createArtist({"name":"artist1","description":"artist1 description"}));

    const id = 1;
    await shallResolve(async () => {
      const metadata = await getArtistMetadata(id);
      expect(metadata["name"]).toBe("artist1");
    });
  });

  it("shall create piece", async () => {
    await deployItems();

    await shallPass(createArtist({"name":"artist1","description":"artist1 description"}));

    const artistID = 1;
    await shallPass(createPiece(artistID, {"name":"piece1","description":"piece1 description"}));

    const pieceID = 1;
    await shallResolve(async () => {
      const data = await getPieceMetadata(pieceID);
      expect(data.pieceID).toBe(pieceID);
      expect(data.metadata["name"]).toBe("piece1");
    });
  });
  
  it("shall be able to mint an Item", async () => {
    // Setup
    await deployItems();
    await shallPass(createArtist({"name":"artist1","description":"artist1 description"}));

    const artistID = 1;
    await shallPass(createPiece(artistID, {"name":"piece1","description":"piece1 description"}));

    const pieceID = 1;

    const address = await getItemAdminAddress();
    await shallPass(mintItemAdmin(pieceID, address));

    const itemID = 1;
    await shallResolve(async () => {
      const data = await getItem(address, itemID);
      expect(data.id).toBe(itemID);
      expect(data.data.artistID).toBe(artistID);
      expect(data.data.pieceID).toBe(pieceID);
    });
  });

  it("shall not able to mint an Item, if non-admin", async () => {
    // Setup
    await deployItems();
    await shallPass(createArtist({"name":"artist1","description":"artist1 description"}));

    const artistID = 1;
    await shallPass(createPiece(artistID, {"name":"piece1","description":"piece1 description"}));

    const pieceID = 1;

    const address = await getItemAdminAddress();
    await shallRevert(mintItemNonAdmin(pieceID, address));

    const itemID = 1;
    await shallRevert(async () => {
      const data = await getItem(address, itemID);
      expect(data.id).toBe(itemID);
      expect(data.data.artistID).toBe(artistID);
      expect(data.data.pieceID).toBe(pieceID);
    });
  });
    
  it("shall be able to batch mint Items", async () => {
    // Setup
    await deployItems();
    await shallPass(createArtist({"name":"artist1","description":"artist1 description"}));

    const artistID = 1;
    await shallPass(createPiece(artistID, {"name":"piece1","description":"piece1 description"}));

    const pieceID = 1;
    const quantity = 10;
    const address = await getItemAdminAddress();
    await shallPass(batchMintItems(pieceID, quantity, address));
    
    // const itemID = 1;
    await shallResolve(async () => {
      const pieceData = await getPieceMetadata(pieceID);
      expect(pieceData.numberMinted).toBe(quantity);

      const count = await getTotalSupply();
      expect(count).toBe(quantity);
    });
  });

  it("shall be able to transfer minted Items from admin", async () => {
    // Setup and mint to admin
    await deployItems();
    await shallPass(createArtist({"name":"artist1","description":"artist1 description"}));

    const artistID = 1;
    await shallPass(createPiece(artistID, {"name":"piece1","description":"piece1 description"}));

    const pieceID = 1;

    const adminAddress = await getItemAdminAddress();
    await shallPass(mintItemAdmin(pieceID, adminAddress));

    const itemID = 1;
    await shallResolve(async () => {
      const data = await getItem(adminAddress, itemID);
      expect(data.id).toBe(itemID);
      expect(data.data.artistID).toBe(artistID);
      expect(data.data.pieceID).toBe(pieceID);
    });

    // set up second account
    const nonAdminAddress = await getItemNonAdminAddress("");
    await setupItemsOnAccount(nonAdminAddress);

    // transfer to second account
    await transferItem(adminAddress, nonAdminAddress, itemID)

    // admin no long owns item
    await shallRevert(async () => {
      await getItem(adminAddress, itemID);
    });

    // receiver owns the item
    await shallResolve(async () => {
      const data = await getItem(nonAdminAddress, itemID);
      expect(data.id).toBe(itemID);
      expect(data.data.artistID).toBe(artistID);
      expect(data.data.pieceID).toBe(pieceID);
    });
  });

  it("shall be able to transfer minted between non-admin accounts", async () => {
    // Setup and mint to admin
    await deployItems();
    await shallPass(createArtist({"name":"artist1","description":"artist1 description"}));

    const artistID = 1;
    await shallPass(createPiece(artistID, {"name":"piece1","description":"piece1 description"}));

    const pieceID = 1;

    const adminAddress = await getItemAdminAddress();
    await shallPass(mintItemAdmin(pieceID, adminAddress));

    const itemID = 1;
    await shallResolve(async () => {
      const data = await getItem(adminAddress, itemID);
      expect(data.id).toBe(itemID);
      expect(data.data.artistID).toBe(artistID);
      expect(data.data.pieceID).toBe(pieceID);
    });

    // set up non-admin accounts
    const nonAdminAddress0 = await getItemNonAdminAddress("0");
    await setupItemsOnAccount(nonAdminAddress0);
    const nonAdminAddress1 = await getItemNonAdminAddress("1");
    await setupItemsOnAccount(nonAdminAddress1);

    // transfer Item from admin to first account, then from first account to second
    await transferItem(adminAddress, nonAdminAddress0, itemID)
    await transferItem(nonAdminAddress0, nonAdminAddress1, itemID)

    // admin no long owns item
    await shallRevert(async () => {
      await getItem(adminAddress, itemID);
    });

    // first account doesn't own item
    await shallRevert(async () => {
      await getItem(nonAdminAddress0, itemID);
    });

    // second account doesn't own item
    await shallResolve(async () => {
      const data = await getItem(nonAdminAddress1, itemID);
      expect(data.id).toBe(itemID);
      expect(data.data.artistID).toBe(artistID);
      expect(data.data.pieceID).toBe(pieceID);
    });
  });

  it("shall be able to get collection IDs", async () => {
    // Setup
    await deployItems();
    await shallPass(createArtist({"name":"artist1","description":"artist1 description"}));

    const artistID = 1;
    await shallPass(createPiece(artistID, {"name":"piece1","description":"piece1 description"}));

    const pieceID = 1;
    const quantity = 10;
    const address = await getItemAdminAddress();

    await shallPass(batchMintItems(pieceID, quantity, address));
    await shallResolve(async () => {
      let collectionIds = await getCollectionIds(address);
      expect(collectionIds.length).toBe(quantity);
    });
  });
})
