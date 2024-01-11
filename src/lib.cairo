// This is a simple book storage contract
// where users store list of books they bookmarekd to read.
// users can also delete them after acheving their goal of reading them.

// similar to Todo

#[starknet::interface]
trait IStorage<TContractState> {
    fn store(ref self: TContractState, book_name: felt252);
    fn delete(ref self:TContractState, book_id: u256);
    fn check_book_by_id(self: @TContractState, book_id: u256) -> felt252;
}

#[starknet::contract]
mod Storage {
    use core::starknet::event::EventEmitter;
    use starknet::{ContractAddress, get_caller_address};

    // contract event
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StoredBook: StoredBook,
        DeletedBook: DeletedBook,
    }

    #[derive(Drop, starknet::Event)]
    struct StoredBook {
        caller: ContractAddress,
        book_name: felt252,
        book_id: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct DeletedBook {
        caller: ContractAddress,
        book_id: u256,
    }

    // Contract storage
    #[storage]
    struct Storage {
        store_book: LegacyMap::<(ContractAddress, u256), felt252>,
        uid: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        // initiate storage
        self.uid.write(1);
    }

    #[abi(embed_v0)]
    impl Storage of super::IStorage<ContractState> {
        fn store(ref self: ContractState, book_name: felt252) {
            let caller = get_caller_address();
            let mut _uid = self.uid.read();
            self.store_book.write((caller, _uid), book_name);
            // update storage uid
            let updated_uid = _uid + 1;
            self.uid.write(updated_uid);
            // emit store data
            self.emit(Event::StoredBook(StoredBook {
                caller,
                book_name,
                book_id: _uid,
            }));
        }

        fn delete(ref self: ContractState, book_id: u256) {
            // when user achieved their target they definitely want to remove
            // the book from the list of bookmarked books
            let caller = get_caller_address();
            self.store_book.write((caller, book_id), '');

            self.emit(Event::DeletedBook(DeletedBook {
                caller,
                book_id,
            }))

        }

        fn check_book_by_id(self: @ContractState, book_id: u256) -> felt252 {
            let caller = get_caller_address();
            let book_name = self.store_book.read((caller, book_id));

            book_name
        }
    }
}
