/// Module: my_first_coin
module my_first_coin::my_first_coin {
    use sui::coin::{Self, TreasuryCap};
    use sui::url::{Self, Url};

    public struct MY_FIRST_COIN has drop {}

    fun init(witness: MY_FIRST_COIN, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(
            witness, 
            6, 
            b"MFC", 
            b"MY_FIRST_COIN", 
            b"This is my fist coin", 
            option::some<Url>(url::new_unsafe_from_bytes(b"https://i.ibb.co/FbCDjKD/coollogo-com-175902109.png")), 
            ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, ctx.sender())
    }

    public fun mint(
        treasury_cap: &mut TreasuryCap<MY_FIRST_COIN>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
    ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }
}
