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
        black: Player,
        white: Player,
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

    public entry fun start_new_game(player1_name: String, player2_name: String, clock: &Clock, ctx: &mut TxContext) {
        let player1: Player = Player {
            name: player1_name, 
            player_address: tx_context::sender(ctx), 
            score: 0 
        };
        let player2 : Player = Player { 
            name: player2_name, 
            player_address: tx_context::sender(ctx), 
            score: 0 
        };

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

    fun check_time_limit(game: &mut Game, clock: &Clock): bool {
        if (clock.timestamp_ms() >= game.end_time) {
            game.is_active = false; // End the game
            if (game.black_game_score > game.white_game_score) {
                game.winner = game.black.name;
                game.black.score = game.black.score + 3;
            } else if (game.black_game_score < game.white_game_score) {
                game.winner = game.white.name;
                game.white.score = game.white.score + 3;
            } else {
                game.winner = b"Draw".to_string();
                game.black.score = game.black.score + 1;
                game.white.score = game.white.score + 1;
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
    fun update_board(game: &mut Game, start_pos: u64, end_pos: u64, clock: &Clock) {
        let time_expired = check_time_limit(game, clock);
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

    public entry fun validate_pawn_move_combined(start_pos: u64, end_pos: u64, game : &mut Game, is_white: bool, clock: &Clock): bool {
        assert!(game.is_active);
        let board = &game.board;
        if (validate_pawn_move(start_pos, end_pos, board, is_white)) {
            update_board(game, start_pos, end_pos, clock);
            return true
        };
        if (validate_pawn_first_move(start_pos, end_pos, board, is_white)) {
            update_board(game, start_pos, end_pos, clock);
            return true
        };
        if (validate_pawn_capture(start_pos, end_pos, board, is_white)) {
            update_board(game, start_pos, end_pos, clock);
            return true
        };
        return false
    }

    // Function to check if the game is over
    public entry fun is_game_over(game: &Game): bool {
        return !game.is_active
    }
}