module calculator::calculator{

    public struct Answer has key, store{
        id : UID,
        add : u64,
        subtract : u64,
        divide : u64,
        multiply : u64
    }

    fun add(a: u64, b: u64): u64 {
        a + b
    }

    fun subtract(a: u64, b: u64): u64 {
        a - b
    }

    fun divide(a: u64, b: u64): u64 {
        a / b
    }

    fun multiply(a: u64, b: u64): u64 {
        a * b
    }

    public entry fun calculate(a: u64, b: u64, ctx : &mut TxContext){
        let object : Answer = Answer{
            id : object::new(ctx), 
            add : add(a, b), 
            subtract : subtract(a, b), 
            divide : divide(a, b), 
            multiply : multiply(a, b) 
        };
        let sender : address = tx_context::sender(ctx);
        transfer::transfer(object, sender);
    }
}