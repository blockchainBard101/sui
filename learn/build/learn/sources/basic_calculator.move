module learn::practice{
    public fun data_types(num : u64, change_values : bool) : (u64, u64, bool, address){
        let mut my_num : u64 = 2;
        let mut values_changed : bool = false;
        let mut my_address : address = @0x3; 

        if(change_values){
            my_num = my_num + num;
            values_changed = change_values;
            my_address = @0x7;
            (num, my_num, values_changed, my_address)
        }
        else{
            (num, my_num, values_changed, my_address)
        }
    }
}

module learn::helper_functions{
    public fun is_odd(x : u256) : bool{
        if(x % 2 == 1){
            true
        } else{false}
    }

    public fun is_even(x : u256) : bool{
        if(x % 2 == 0){
            true
        } else{false}
    }

    public fun is_prime(x : u256) : bool{
        let mut i: u256 = 2;
        let mut is_prime : bool = true;
        while(i <= 5){
            if(x % i  == 0){
                is_prime = false;
                break
            };
            i = i +1;
        };
        return is_prime
    }
}

module learn::basic_calculator{
    public fun sum(a : u256, b : u256) : u256{
        a + b
    }

    public fun subtract(a : u256, b : u256) : u256{
        assert!(a > b, 0);
        a - b
    }

    public fun divide(a : u256, b : u256) : u256{
        a / b
    }

    public fun multiply(a : u256, b : u256) : u256{
        a * b
    }

    public fun modulus(a : u256, b : u256) : u256{
        a % b
    }

    public fun calculate(num1 : u256, num2 : u256, operator : vector<u8>) : u256{
        if(operator == b"-"){
            subtract(num1, num2)
        }else if (operator == b"+"){
            sum(num1, num2)
        }else if (operator == b"*"){
            divide(num1, num2)
        }else if (operator == b"/"){
            multiply(num1, num2)
        }else if (operator == b"%"){
            modulus(num1, num2)
        }else{
            0
        }
    }
}

module learn::practice_structs{
    public struct MyStruct has drop, copy{
        x : u64,
        y : bool
    }

    public fun check_struct() : bool{
        let stru = MyStruct{x: 7, y: false };
        let MyStruct{x, y } = stru;

        stru.y
    }
}