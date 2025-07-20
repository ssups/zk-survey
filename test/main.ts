import { Noir } from "@noir-lang/noir_js";
import { UltraHonkBackend, Fr, BarretenbergSync } from "@aztec/bb.js";
import { IncrementalMerkleTree } from "merkletreejs";
import circuit from "../circuit/target/circuit.json";

async function main() {
  const noir = new Noir(circuit as any);
  const honk = new UltraHonkBackend(circuit.bytecode, { threads: 3 });
  const hash = await getPoseidonHasher();

  const mt = new IncrementalMerkleTree(hash, {
    depth: 10,
    zeroValue: hash([new Fr(0n)]),
    arity: 2,
  });

  const secret = new Fr(BigInt(1));
  const uuid = hash([new Fr(BigInt("0xdddddd"))]);
  const surveyId = new Fr(BigInt(1));
  const nulifier = hash([secret, uuid, surveyId]);
  const leafNode = hash([secret, uuid]);

  mt.insert(leafNode);

  const index = mt.indexOf(leafNode);
  const { root, siblings: path } = mt.getProof(index);

  const { witness } = await noir.execute({
    secret: secret.toString(),
    uuid: uuid.toString(),
    merkle_index: index,
    merkle_proof: path.map((sibling: Fr) => sibling.toString()),
    survey_id: surveyId.toString(),
    nulifier: nulifier.toString(),
    merkle_root: root.toString(),
  });

  const proofData = await honk.generateProof(witness);
  const isValid = await honk.verifyProof(proofData);
  console.log({ isValid });
  process.exit(0);
}

async function getPoseidonHasher() {
  const bbsync = await BarretenbergSync.initSingleton();
  return (values: Fr[]) => {
    return bbsync.poseidon2Hash(values);
  };
}

main().catch((err) => {
  console.error("Error in main:", err);
  process.exit(1);
});
