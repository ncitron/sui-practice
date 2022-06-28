module practice::share_bug {
    use sui::transfer;
    use sui::id::VersionedID;
    use sui::tx_context::{Self, TxContext};

    struct Thing has key {
        id: VersionedID
    }

    public entry fun create(ctx: &mut TxContext) {
        let thing = Thing { id: tx_context::new_id(ctx) };
        transfer::share_object(thing);
    }

    #[test]
    fun bug_example() {
        use sui::test_scenario;

        let user = @0x123;
        let scenario = &mut test_scenario::begin(&user);

        create(test_scenario::ctx(scenario));

        let thing_wrapper = test_scenario::take_shared<Thing>(scenario); 
        let thing = test_scenario::borrow_mut(&mut thing_wrapper);

        assert!(1 == 0, 0);

        test_scenario::return_shared(scenario, thing_wrapper);
    }
}
