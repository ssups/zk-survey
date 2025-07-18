use poseidon::poseidon2::Poseidon2;
use trees::merkle::{Calculator, MembershipProver, MerkleTree, MT_Creator};

// for 1024 leaf nodes merkle tree
fn main(
    secret: Field,
    merkle_index: Field,
    survey_id: pub Field,
    nulifier: pub Field,
    merkle_root: pub Field,
    merkle_proof: pub [Field; 10],
) {
    let correct_nulifier = Poseidon2::hash([secret, survey_id], 2);
    assert_eq(nulifier, correct_nulifier, f"Invalid nulifier: {nulifier} != {correct_nulifier}");

    let leaf_node = Poseidon2::hash([secret], 1);
    let mut mt = MerkleTree::new(hasher);
    mt.root = merkle_root;
    mt.membership(leaf_node, merkle_index, merkle_proof)
}

fn hasher(leaves: [Field; 2]) -> Field {
    Poseidon2::hash(leaves, 2)
}

#[test]
fn test_main() {
    let secret: Field = 1;
    println(f"secret: {secret}");
    let survey_id: Field = 1;
    println(f"survey_id: {survey_id}");
    let nulifier = Poseidon2::hash([secret, survey_id], 2);
    println(f"nulifier: {nulifier}");
    let leaf_node = Poseidon2::hash([secret], 1);
    let path = make_path_with_zero_node(leaf_node);
    let merkle_root = MerkleTree::new(hasher).calculate_root(leaf_node, 0, path);

    main(secret, 0, survey_id, nulifier, merkle_root, path);
}

fn make_path_with_zero_node(leaf_node: Field) -> [Field; 10] {
    let mut paths = [0; 10];

    let mut node = leaf_node;
    for i in 0..10 {
        paths[i] = Poseidon2::hash([node, 0], 2);
        node = paths[i];
    }
    paths
}
