// module metaschool::metaschool{
//     public struct Person has key{
//         id : UID,
//     }

//     fun init(ctx : &mut TxContext){
//         let id : UID = object::new(ctx);
//         let person:Person= Person{
//             id : id,
//         };
//     }
// }


module metaschool::metaschool2{
    use std::string::{Self,String};
    use std::debug;

    public struct Person has key, store{
        id : UID,
        name : String,
        // remarks : String
    }

    public struct HelloWorld has key, store{
        id : UID,
        text : String
    }

    fun init(ctx : &mut TxContext){}

    public fun main(name : String, age : u8, ctx : &mut TxContext) : Person{
        let remark : String = if(age < 18){
            string::utf8(b"minor")
        }else{
            string::utf8(b"adult")
        };

        Person{
            id : object::new(ctx),
            name : name,
            // remarks : string::utf8(b"minor")
        }

        // debug::print(&remark);
    }

    public fun use_contract(age : u8){
        assert!(age > 18, 0);
        
    }

    public entry fun mint(ctx : &mut TxContext){
        let object : HelloWorld = HelloWorld{
            id : object::new(ctx),
            text : string::utf8(b"hello world!"),
        };

        let sender : address = tx_context::sender(ctx);

        transfer::public_transfer(object, sender);
    }

}