use snforge_std::{ declare, ContractClassTrait };
use starknet::ContractAddress;
use storage::{ IStorageDispatcher, IStorageDispatcherTrait };


fn deploy_contract() -> IStorageDispatcher {
    let storage_contract = declare('Storage');
    let contract_address = storage_contract.deploy(@ArrayTrait::new()).unwrap();
    let storage = IStorageDispatcher { contract_address };

    storage
}

#[test]
fn test_store() {
    let storage = deploy_contract();

    let _name = 'Akhila and the bee';
    storage.store(_name);

    let check_book = storage.check_book_by_id(0);
    assert(check_book == _name, 'Invalid');
}

#[test]
fn test_delete() {
    let storage = deploy_contract();
    // test that create and delete a bookmarked novel
    // and check if it has been removed in the storage
    // by checking the item

    let _name = 'The Killer';

    storage.store(_name);
    let check_book = storage.check_book_by_id(0);

    assert(check_book == _name, 'Invalid');

    // delete the stored novel
    storage.delete(0);
    // check the storage after deleting
    let check_book = storage.check_book_by_id(0);
    assert(check_book == '', 'Book not deleted from storage');
}

#[test]
fn test_check_bookmarked() {
    let storage = deploy_contract();

    storage.store('Akhila');
    storage.store('The Killer');
    storage.store('Metropolina');

    let bookmarked = array!['Akhila', 'The Killer', 'Metropolina'];

    let check_bookmarked = storage.check_bookmarked();
    let check_bookmarked_len = check_bookmarked.len();

    assert(check_bookmarked == bookmarked, 'Bookmarked not equal');
}
