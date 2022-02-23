import { getAccountAddress } from "flow-js-testing";
import { deployContractByName, executeScript, sendTransaction } from "flow-js-testing";

const UFIX64_PRECISION = 8;

// UFix64 values shall be always passed as strings
export const toUFix64 = (value) => value.toFixed(UFIX64_PRECISION);

export const getAdminAddress = async () => getAccountAddress("ItemAdmin");

export const sendTransactionWithErrorRaised = async (...props) => {
    const [resp, err] = await sendTransaction(...props);
    if (err) {
        throw err;
    }
    return resp;
}

export const executeScriptWithErrorRaised = async (...props) => {
    const [resp, err] = await executeScript(...props);
    if (err) {
        throw err;
    }
    return resp;
}

export const deployContractByNameWithErrorRaised = async (...props) => {
    const [resp, err] = await deployContractByName(...props);
    if (err) {
        throw err;
    }
    return resp;
}

export const extractMintedItemIDFromTx = (tx) => {
    const events = tx.events;
    for (let i = 0; i < events.length; i += 1) {
        if (events[i].type.endsWith(".Minted")) {
            return events[i].data.id;
        }
    }

    throw new Error(`No Minted event in transaction: {JSON.stringify(tx)}`);
}
