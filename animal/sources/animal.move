module animal::animal{
    use std::string::String;
    public struct Anime has key, store{
        id : UID,
        name : String,
        no_of_legs : u8,
        favorite_food : String
    }

    fun main(name : String, no_of_legs : u8, favorite_food : String, ctx : &mut TxContext) : Anime{
        Anime{
            id : object::new(ctx),
            name : name,
            no_of_legs : no_of_legs,
            favorite_food : favorite_food
        }
    }

    public entry fun update(name : String, no_of_legs : u8, favorite_food : String, ctx : &mut TxContext){
        let object : Anime = main(name, no_of_legs, favorite_food, ctx);
        let sender : address = tx_context::sender(ctx);
        transfer::transfer(object, sender);
    }
}