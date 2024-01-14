// This is a simple book storage contract
// where users store list of books they bookmarekd to read.
// users can also delete them after acheving their goal of reading them.

// similar to Todo

// the legacy map used in this contract mimicks array
// using the LIFO pattern (last in, first out)

#[starknet::interface]
trait IStorage<TContractState> {
    fn store(ref self: TContractState, book_name: felt252);
    fn delete(ref self:TContractState, book_id: u32);
    fn check_book_by_id(self: @TContractState, book_id: u32) -> felt252;
    fn check_bookmarked(self: @TContractState) -> Array<felt252>;
}

#[starknet::contract]
mod Storage {
    use core::array::ArrayTrait;
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
    }

    #[derive(Drop, starknet::Event)]
    struct DeletedBook {
        caller: ContractAddress,
        book_id: u32,
    }

    // Contract storage
    #[storage]
    struct Storage {
        // bookmark books to read
        store_book: LegacyMap::<(ContractAddress, u32), felt252>,
        // get the length of the stored book
        store_length: LegacyMap::<ContractAddress, u32>,
    }

    #[abi(embed_v0)]
    impl Storage of super::IStorage<ContractState> {
        fn store(ref self:ContractState, book_name: felt252) {
            let caller = get_caller_address();
            // push the book into storage
            self.push(caller, book_name);

            // emit the event
            self.emit(Event::StoredBook( StoredBook {
                caller,
                book_name
            }))
        }

        fn delete(ref self: ContractState, book_id:u32) {
            // cache data
            let caller = get_caller_address();
            let length = self.store_length.read(caller);

            if ( book_id < length && book_id != length) {
                let last_item = self.store_book.read((caller, length - 1));
                let id_item = self.store_book.read((caller, book_id));

                // swap the id item to remove with the last item
                // before poping the last item out
                // since we are using the last in, first out model
                self.store_book.write((caller, length - 1), id_item);
                self.store_book.write((caller, book_id), last_item);

                self.pop(caller);
            } else if (book_id < length && book_id == length) {
                self.pop(caller);
            } else {
                assert(false,'Book id does not exit');
            }
        }

        fn check_book_by_id(self: @ContractState, book_id: u32) -> felt252 {
            let caller = get_caller_address();
            let book_name = self.store_book.read((caller, book_id));

            book_name
        }

        fn check_bookmarked(self: @ContractState) -> Array<felt252> {
            let caller = get_caller_address();
            let get_length = self.store_length.read(caller);

            let mut bookmarked_item = ArrayTrait::<felt252>::new();
            let mut i:u32 = 0;

            loop {
                if (i == get_length) {
                    break;
                }

                let item = self.store_book.read((caller, i));
                bookmarked_item.append(item);

                i += 1;
            };

            bookmarked_item
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn pop(ref self: ContractState, address: ContractAddress) {
            // cache storage data
            let mut length = self.store_length.read(address);
            length -= 1;

            self.store_book.write((address, length), '');
            self.store_length.write(address, length);
        }

        fn push(ref self: ContractState, address:ContractAddress, input: felt252) {
            // cache storage data
            let mut length = self.store_length.read(address);

            self.store_book.write((address, length), input);
            length += 1;
            self.store_length.write(address, length);

        }
    }
}
