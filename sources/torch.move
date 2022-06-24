module practice::torch {
    use sui::transfer;
    use sui::id::VersionedID;
    use sui::tx_context::{Self, TxContext};

    struct Torch has key {
        id: VersionedID,
        value: u64
    }

    public entry fun create(value: u64, ctx: &mut TxContext) {
        let id = tx_context::new_id(ctx);
        let torch = Torch { id, value };
        let sender = tx_context::sender(ctx);
        transfer::transfer(torch, sender);
    }

    public fun value(self: &Torch): u64 {
        self.value
    }

    #[test]
    fun test_create() {
        use sui::test_scenario;

        let user = @0x1234;
        let scenario = &mut test_scenario::begin(&user);
        
        create(47, test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, &user);
        let h = test_scenario::take_owned<Torch>(scenario);
        let v = value(&h);

        assert!(v == 47, 0);

        test_scenario::return_owned(scenario, h)
    }

}

