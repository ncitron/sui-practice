import { Ed25519Keypair, JsonRpcProvider, RawSigner } from "@mysten/sui.js";

run()

async function run(): Promise<void> {
  const rawKey = ""
  const secretKey = Buffer.from(rawKey, "base64");
  const keypair = Ed25519Keypair.fromSecretKey(secretKey);

  const provider = new JsonRpcProvider("https://gateway.devnet.sui.io:443");
  const signer = new RawSigner(
    keypair,
    provider
  );
  
  let addr = await signer.getAddress();
  console.log(addr);

  let t = await provider.getTotalTransactionNumber();
  console.log(t);

  for (let i = 0; i < 1000; i++) {
    let tx = await signer.executeMoveCall({
      packageObjectId: "0x2",
      module: "devnet_nft",
      function: "mint",
      typeArguments: [],
      arguments: [
        "My NFT",
        "Just an NFT",
        "https://i.imgur.com/C4iPxwN.jpeg"
      ],
      gasBudget: 10000,
    });
    console.log(i);
  }
}
