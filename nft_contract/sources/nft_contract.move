module nft_contract::nft{
    // use sui::transfer;
    // use sui::tx_context;
    use std::string::String;

    public struct NFT has key, store{
        id : UID,
        name : String,
        description : String,
        url : String
    }

    public entry fun mint(name:String, description: String, image_url : String, ctx: &mut TxContext){
        let nft : NFT = NFT{
            id : object::new(ctx),
            name : name,
            description : description,
            url: image_url
        };

        let sender : address = tx_context::sender(ctx);

        transfer::public_transfer(nft, sender); 
    }

    public fun transfer_nft(nft : NFT, recipient : address){
        transfer::public_transfer(nft, recipient);
    }
}