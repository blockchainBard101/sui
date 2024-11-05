#[test_only]
module learn::learn_test{
    use learn::practice;
    use learn::basic_calculator;
    use learn::helper_functions;
    use learn::practice_structs;
    use std::debug;
    const ERROR : u64 = 0; 

    #[test]
    fun test_data_types(){
        let (num, _my_num, _contract_changed, _my_address) = practice::data_types(8, true);
        debug::print(&num);
        assert!(num != 7, ERROR);
    }

    #[test]
    fun test_basic_calculator(){
        let a : u64 = 6;
        let b : u64 = 3;

        let result : u256 = basic_calculator::calculate(a as u256, b as u256, b"-");
        debug::print(&result);
    }

    #[test]
    fun test_helper_functions(){
        let x : u64 = 10;

        let is_prime : bool = helper_functions::is_prime(x as u256);

        assert!(is_prime, ERROR);
    }

    #[test]
    fun test_check_struct(){
        let b : bool = practice_structs::check_struct();
        debug::print(&b);
    }
}
