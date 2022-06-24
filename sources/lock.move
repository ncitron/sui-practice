module practice::lock {
    use sui::id::{Self, VersionedID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    struct Gold has key, store {
        id: VersionedID,
        amount: u64,
    }

    struct Lock has key {
        id: VersionedID,
        gold: Gold,
    }

    struct Key has key {
        id: VersionedID
    }

    public entry fun create_lock(amount: u64, ctx: &mut TxContext) {
        let id = tx_context::new_id(ctx);
        let gold = Gold { id, amount };
        let id = tx_context::new_id(ctx);
        let lock = Lock { id, gold };
        transfer::transfer(lock, tx_context::sender(ctx));
    }

    public entry fun create_key(ctx: &mut TxContext) {
        let id = tx_context::new_id(ctx);
        let key = Key { id };
        transfer::transfer(key, tx_context::sender(ctx));
    }

    public entry fun unlock(lock: Lock, key: Key, ctx: &mut TxContext) {
        let Lock { id, gold } = lock;
        id::delete(id);

        let Key { id } = key;
        id::delete(id);

        transfer::transfer(gold, tx_context::sender(ctx));
    }

    #[test]
    fun test_unlock() {
        use sui::test_scenario;

        let user = @0x1234;
        let scenario = &mut test_scenario::begin(&user);

        create_key(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, &user);
        let key = test_scenario::take_owned<Key>(scenario);
        
        test_scenario::next_tx(scenario, &user);
        create_lock(50, test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, &user);
        let lock = test_scenario::take_owned<Lock>(scenario);
        
        test_scenario::next_tx(scenario, &user);
        unlock(lock, key, test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, &user);
        assert!(test_scenario::can_take_owned<Gold>(scenario), 0);
    }
}
