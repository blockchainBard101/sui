module chess::chess{
    use std::string::String;
    use sui::clock::Clock;
    use std::debug;

    public struct Player has store {
        name: String,
        player_address: address,
        score: u64
    }

    public struct Game has key, store {
        id: UID,
        black: address,
        white: address,
        board: vector<vector<u8>>,  // 8x8 grid
        turn: u8,  
        num_black_moves: u64,
        num_white_moves: u64,
        black_game_score: u64,
        white_game_score : u64,
        winner: String,
        start_time : u64,
        end_time : u64,
        is_active: bool,
    }

    public struct Tournament has key, store {
        id: UID,
        name : String,
        leaderboard: Leaderboard,
        draws : vector<vector<address>>,
        is_active: bool,
    }

    public struct Leaderboard has store{
        players: vector<Player>,
    }

    public entry fun create_tournament(name: String, ctx: &mut TxContext) {
        let leaderboard : Leaderboard = Leaderboard {
            players: vector::empty<Player>(),
        };

        let tournament : Tournament = Tournament{
            id : object::new(ctx),
            name,
            leaderboard,
            draws: vector::empty<vector<address>>(),
            is_active: false,
        };
        let sender : address = tx_context::sender(ctx);
        transfer::transfer(tournament, sender);
        
    }

    public entry fun start_tournament(tournament : &mut Tournament) {
        let num_players : u64 = vector::length(&tournament.leaderboard.players);
        assert!(num_players == 8);
        tournament.draws = pair_players(&tournament.leaderboard.players);
        tournament.is_active = true;
    }

    fun pair_players(players: &vector<Player>): vector<vector<address>> {
        let num_players = vector::length(players);
        let mut pairs = vector::empty<vector<address>>();

        let mut i = 0;
        while (i < num_players) {
            let player1 = vector::borrow(players, i).player_address;

            let mut j = i + 1;
            while (j < num_players) {
                let player2 = vector::borrow(players, j).player_address;

                // Form a pair between player1 and player2
                let match_pair = vector[player1, player2];
                vector::push_back(&mut pairs, match_pair);

                j = j + 1;
            };
            i = i + 1;
        };
        return pairs
    }

    fun is_player_exists(players: &vector<Player>, player_address : address): bool {
        let num_players : u64 = vector::length(players);
        let mut player_exists = false;
        let mut i = 0;
        while(i < num_players) {
            let player = vector::borrow(players, i);
            if (player.player_address == player_address) {
                player_exists = true;
                break
            };
            i = i + 1;
        };
        return player_exists
    }

    public entry fun add_player(tournament: &mut Tournament, name: String, player_address : address) {
        // Check if the player already exists
        let exists_player = is_player_exists(&tournament.leaderboard.players, player_address);
        let num_players = vector::length(&tournament.leaderboard.players);
        if (!exists_player && num_players <= 8) {
            // Create a new player with 0 score
            let new_player = Player {
                name,
                player_address : player_address,
                score: 0,
            };
            // Add the player to the leaderboard object
            vector::push_back(&mut tournament.leaderboard.players, new_player);
        }
    }

    fun init_board(): vector<vector<u8>> {
        let board : vector<vector<u8>> = vector[b"r", b"n", b"b", b"q", b"k", b"b", b"n", b"r",  // Row 1
                                                b"p", b"p", b"p", b"p", b"p", b"p", b"p", b"p",  // Row 2
                                                b"", b"", b"", b"", b"", b"", b"", b"",  // Empty Row 3
                                                b"", b"", b"", b"", b"", b"", b"", b"",  // Empty Row 4
                                                b"", b"", b"", b"", b"", b"", b"", b"",  // Empty Row 5
                                                b"", b"", b"", b"", b"", b"", b"", b"",  // Empty Row 6
                                                b"P", b"P", b"P", b"P", b"P", b"P", b"P", b"P",  // Row 7
                                                b"R", b"N", b"B", b"Q", b"K", b"B", b"N", b"R"]; // Row 8
        return board
    }

    public entry fun start_new_game(tournament : &Tournament, player1: address, player2: address, clock: &Clock, ctx: &mut TxContext) {
        assert!(tournament.is_active);
        let board : vector<vector<u8>> = init_board();
        
        let game  : Game = Game {
            id: object::new(ctx),
            black : player2,
            white : player1,
            board,
            turn: 1,  // white starts first
            num_black_moves: 0,
            num_white_moves: 0,
            black_game_score: 0,
            white_game_score : 0,
            winner: b"".to_string(),
            start_time : clock.timestamp_ms(),
            end_time : clock.timestamp_ms() + 1800000, // 30 minutes
            is_active: true,
        };
        debug::print(&game);
        transfer::transfer(game, tx_context::sender(ctx));
    }

    fun get_player_index( players: &vector<Player>, player_address: address): u64 {
        let num_players = vector::length(players);
        let mut i  = 0;
        let mut index = 0;
        while(i < num_players) {
            let player = vector::borrow(players, i);
            if (player.player_address == player_address) {
                index = i;
                break
            };
            i = i + 1;
        };
        return index
    }

    fun check_time_limit(tournament : &mut Tournament, game: &mut Game, clock: &Clock): bool {
        if (clock.timestamp_ms() >= game.end_time) {
            game.is_active = false; // End the game

            if (game.black_game_score > game.white_game_score) {
                game.winner = b"black".to_string();
                let black_player_idx = get_player_index(&tournament.leaderboard.players, game.black);
                let black_player = vector::borrow_mut(&mut tournament.leaderboard.players, black_player_idx);
                black_player.score = black_player.score + 3;
            } else if (game.black_game_score < game.white_game_score) {
                game.winner = b"white".to_string();
                let white_player_idx = get_player_index(&tournament.leaderboard.players, game.white);
                let white_player = vector::borrow_mut(&mut tournament.leaderboard.players, white_player_idx);
                white_player.score = white_player.score + 3;
            } else {
                game.winner = b"Draw".to_string();
                let black_player_idx = get_player_index(&tournament.leaderboard.players, game.black);
                let black_player = vector::borrow_mut(&mut tournament.leaderboard.players, black_player_idx);
                black_player.score = black_player.score + 1;
            };
            if (game.winner == b"Draw".to_string()) {
                let white_player_idx = get_player_index(&tournament.leaderboard.players, game.white);
                let white_player = vector::borrow_mut(&mut tournament.leaderboard.players, white_player_idx);
                white_player.score = white_player.score + 1;
            };
            return true // Game ended
        };
        return false // Game is still active
    }

    fun update_game_score(game: &mut Game, end_pos : u64) {
        let piece = vector::borrow(&game.board, end_pos);
        if (piece == b"P") {
            game.black_game_score = game.black_game_score + 1;
        } else if (piece == b"p") {
            game.white_game_score = game.white_game_score + 1;
        } else if (piece == b"N") {
            game.black_game_score = game.black_game_score + 3;
        } else if (piece == b"n"){
            game.white_game_score = game.white_game_score + 3;
        } else if (piece == b"R"){
            game.black_game_score = game.black_game_score + 5;
        } else if (piece == b"r"){
            game.white_game_score = game.white_game_score + 5;
        } else if (piece == b"B"){
            game.black_game_score = game.black_game_score + 3;
        } else if (piece == b"b"){
            game.white_game_score = game.white_game_score + 3;
        } else if (piece == b"Q"){
            game.black_game_score = game.black_game_score + 9;
        } else if (piece == b"q"){
            game.white_game_score = game.white_game_score + 9;
        }
        
    }
    
    fun replace_piece(board: &mut vector<vector<u8>>, piece: vector<u8>, pos: u64) {
        vector::remove(board, pos);
        vector::insert(board, piece, pos);
    }
    fun update_board(tournament: &mut Tournament, game: &mut Game, start_pos: u64, end_pos: u64, clock: &Clock) {
        let time_expired = check_time_limit(tournament,game, clock);
        if (time_expired) {
            return
        };

        if (vector::borrow(&game.board, end_pos) != b"") {
            update_game_score(game, end_pos);
            replace_piece(&mut game.board, b"", end_pos);
        };

        vector::swap(&mut game.board, start_pos, end_pos);
        if (game.turn == 1) {
            game.num_white_moves = game.num_white_moves +1;
        } else {
            game.num_black_moves = game.num_black_moves + 1;
        };
        game.turn = if (game.turn == 1) { 2 } else { 1 };
    }

    //MOVES
    //PAWN MOVES

    fun validate_pawn_move(start_pos: u64, end_pos: u64, board: &vector<vector<u8>>, is_white: bool): bool {
        if (is_white) {
            // White pawn moves one square forward if the target is empty
            return (end_pos == start_pos - 8) && (vector::borrow(board, end_pos) == b"")
        } else {
            // Black pawn moves one square forward if the target is empty
            return (end_pos == start_pos + 8) && (vector::borrow(board, end_pos) == b"")
        }
    }

    fun validate_pawn_first_move(start_pos: u64, end_pos: u64, board: &vector<vector<u8>>, is_white: bool): bool {
        if (is_white && start_pos >= 48 && start_pos <= 55) {
            // White pawn moves two squares forward from the starting position
            return (end_pos == start_pos - 16) && 
                (vector::borrow(board, start_pos - 8) == b"") && 
                (vector::borrow(board, end_pos) == b"")
        } else if (!is_white && start_pos >= 8 && start_pos <= 15) {
            // Black pawn moves two squares forward from the starting position
            return (end_pos == start_pos + 16) && 
                (vector::borrow(board, start_pos + 8) == b"") && 
                (vector::borrow(board, end_pos) == b"")
        };
        return false
    }

    fun validate_pawn_capture(start_pos: u64, end_pos: u64, board: &vector<vector<u8>>, is_white: bool): bool {
        let target_piece = vector::borrow(board, end_pos);
        
        // Ensure target position is not empty and contains an opposing piece
        if (target_piece == b"") {
            return false
        };
        
        if (is_white) {
            // White pawn captures diagonally to the left or right
            return (end_pos == start_pos - 9 || end_pos == start_pos - 7)
        } else {
            // Black pawn captures diagonally to the left or right
            return (end_pos == start_pos + 9 || end_pos == start_pos + 7)
        }
    }

    public entry fun promote_pawn(game : &mut Game, pos: u64, piece : vector<u8>, is_white: bool){
        // Replace the pawn with the chosen promotion piece
        if (is_white && pos < 8) {  // White pawn on the 8th rank
            replace_piece(&mut game.board, piece, pos);
        } else if (!is_white && pos >= 56) {  // Black pawn on the 1st rank
            replace_piece(&mut game.board, piece, pos);
        };
    }

    public entry fun validate_pawn_move_combined(tournament: &mut Tournament, start_pos: u64, end_pos: u64, game : &mut Game, is_white: bool, clock: &Clock): bool {
        assert!(game.is_active);
        let board = &game.board;
        if (validate_pawn_move(start_pos, end_pos, board, is_white)) {
            update_board(tournament,game, start_pos, end_pos, clock);
            return true
        };
        if (validate_pawn_first_move(start_pos, end_pos, board, is_white)) {
            update_board(tournament,game, start_pos, end_pos, clock);
            return true
        };
        if (validate_pawn_capture(start_pos, end_pos, board, is_white)) {
            update_board(tournament,game, start_pos, end_pos, clock);
            return true 
        };
        return false
    }

    // Function to check if the game is over
    public entry fun is_game_over(game: &Game): bool {
        return !game.is_active
    }
}