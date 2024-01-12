use snforge_std::{ declare, ContractClassTrait };
use starknet::ContractAddress;
use storage::{ IStorageDispatcher, IStorageDispatcherTrait };


fn deploy_contract(name: felt252) -> ContractAddress {
    let storage_contract = declare(name);
    let contract_deployed = storage_contract.deploy(@ArrayTrait::new()).unwrap();

    contract_deployed
}

#[test]
fn test_store() {
    let contract_address = deploy_contract('Storage');

    let storage = IStorageDispatcher { contract_address };

    // we want to bookmark the story book akhila and the bee

    let _name = 'Akhila and the bee';
    storage.store(_name);

    let check_book = storage.check_book_by_id(1);

    assert(check_book == _name, 'Invalid');
}

#[test]
fn test_delete() {
    let contract_address = deploy_contract('Storage');
    let storage = IStorageDispatcher { contract_address };

    // we want to create and delete a bookmarked novel
    // and check if it has removed

    let _name = 'The killer';

    // store the novel
    storage.store(_name);
    let check_book = storage.check_book_by_id(1);

    assert(check_book == _name, 'Invalid');

    // delete the stored novel
    storage.delete(1);
    // check the storage after deleting
    let check_book = storage.check_book_by_id(1);

    assert(check_book == '', 'Book not deleted from storage');
}
