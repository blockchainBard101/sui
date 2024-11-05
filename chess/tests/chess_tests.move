#[test_only]
module chess::chess_tests {
    use chess::chess;
    use sui::clock;
    use std::debug;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_chess() {
        let mut ctx = tx_context::dummy();
        let player1 = b"Geo".to_string();
        let player2 = b"rge".to_string();
        let mut clock = clock::create_for_testing(&mut ctx);
        clock.set_for_testing(50);
        chess::start_new_game(player1, player2, &clock, &mut ctx);
        debug::print(&clock.timestamp_ms());
        clock.destroy_for_testing();
    }

    #[test, expected_failure(abort_code = ::chess::chess_tests::ENotImplemented)]
    fun test_chess_fail() {
        abort ENotImplemented
    }
}