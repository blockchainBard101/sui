import "dotenv/config"

import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { fromB64 } from "@mysten/sui/utils";
import { SuiClient, getFullnodeUrl } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";

import path, { dirname } from "path";
import { execSync } from "child_process";
import { fileURLToPath } from "url";

const Private_key = process.env.PRIVATE_KE;

if (!Private_key) {
    throw new Error("Please set your private key in a .env file");
}

const rpcUrl = getFullnodeUrl("devnet");
const keypair = Ed25519Keypair.fromSecretKey(fromB64(Private_key).slice(1));
console.log(keypair);
// const client = new SuiClient({ url: rpcUrl });

// // console.log(keypair.toSuiAddress())

// const path_to_contract = path.join(dirname(fileURLToPath(import.meta.url)), "../../nft_contract");

// console.log("Building...");
// const { dependencies, modules } = JSON.parse(execSync(
//     `sui move build --skip-fetch-latest-git-deps --dump-bytecode-as-base64 --path ${path_to_contract}`,
//     { encoding: "utf-8" }
// ));

// console.log("Deploying...");
// console.log(`Deploying from ${keypair.toSuiAddress()}`);

// const deploy_trx = new Transaction();
// const [upgrade_cap] = deploy_trx.publish({
//     modules, dependencies
// })
// deploy_trx.transferObjects([upgrade_cap], keypair.toSuiAddress());

// const { objectChanges, balanceChanges } = await client.signAndExecuteTransaction({
//     signer : keypair,
//     transaction: deploy_trx,
//     options: {
//         showBalanceChanges: true,
//         showEvents: true,
//         showInput: false,
//         showEffects: true,
//         showObjectChanges: true,
//         showRawInput: false,
//     }
// })

// console.log(objectChanges, balanceChanges)