module practice::exchange {
    use sui::id::VersionedID;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::balance::{Self, Balance};

    struct Pool<phantom A, phantom B> has key {
        id: VersionedID,
        reserve_a: Balance<A>,
        reserve_b: Balance<B>,
    }

    public entry fun create<A, B>(a: Coin<A>, b: Coin<B>, ctx: &mut TxContext) {
        let id = tx_context::new_id(ctx);
        let reserve_a = coin::into_balance(a);
        let reserve_b = coin::into_balance(b);
        transfer::share_object(Pool { id, reserve_a, reserve_b });
    }

    public entry fun swap_a<A, B>(pool: &mut Pool<A, B>, a: Coin<A>, min_out: u64, ctx: &mut TxContext) {
        let input_amount = coin::value(&a);

        let reserve_amount_a = balance::value(&pool.reserve_a);
        let reserve_amount_b = balance::value(&pool.reserve_b);
        
        let k = reserve_amount_a * reserve_amount_b;
        let output_amount = reserve_amount_b - (k / (reserve_amount_a + input_amount));
        assert!(output_amount >= min_out, 0);

        let output_coin = coin::withdraw(&mut pool.reserve_b, output_amount, ctx);
        transfer::transfer(output_coin, tx_context::sender(ctx));
        coin::deposit(&mut pool.reserve_a, a);
    }

    public entry fun swap_b<A, B>(pool: &mut Pool<A, B>, b: Coin<B>, min_out: u64, ctx: &mut TxContext) {
        let input_amount = coin::value(&b);

        let reserve_amount_a = balance::value(&pool.reserve_a);
        let reserve_amount_b = balance::value(&pool.reserve_b);
        
        let k = reserve_amount_a * reserve_amount_b;
        let output_amount = reserve_amount_a - (k / (reserve_amount_b + input_amount));
        assert!(output_amount >= min_out, 0);

        let output_coin = coin::withdraw(&mut pool.reserve_a, output_amount, ctx);
        transfer::transfer(output_coin, tx_context::sender(ctx));
        coin::deposit(&mut pool.reserve_b, b);
    }


    struct TEST_TOKEN_A has drop {} 
    struct TEST_TOKEN_B has drop {}

    fun init(ctx: &mut TxContext) {
        let treasury_cap_a = coin::create_currency<TEST_TOKEN_A>(TEST_TOKEN_A{}, ctx);
        let treasury_cap_b = coin::create_currency<TEST_TOKEN_B>(TEST_TOKEN_B{}, ctx);
        transfer::transfer(treasury_cap_a, tx_context::sender(ctx));
        transfer::transfer(treasury_cap_b, tx_context::sender(ctx));
    }

    public entry fun mint_a(cap: &mut TreasuryCap<TEST_TOKEN_A>, amount: u64, ctx: &mut TxContext) {
        let coins = coin::mint<TEST_TOKEN_A>(amount, cap, ctx);
        transfer::transfer(coins, tx_context::sender(ctx));
    }

    public entry fun mint_b(cap: &mut TreasuryCap<TEST_TOKEN_B>, amount: u64, ctx: &mut TxContext) {
        let coins = coin::mint<TEST_TOKEN_B>(amount, cap, ctx);
        transfer::transfer(coins, tx_context::sender(ctx));
    }
}
