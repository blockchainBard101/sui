module age_calculator::age_calculator{
    public struct Date_Age has copy, drop{
        year : u256,
        month : u256,
        days : u256
    }

    public fun get_current_date(year : u256, month : u256, date : u256) : Date_Age{
        Date_Age{
            year : year,
            month : month,
            days : date
        }
    }

    public fun calculate_age(_birth_year : u256, _birth_month : u256, _birth_date : u256, current_date : Date_Age) : Date_Age{
        Date_Age{
            year : current_date.year - _birth_year,
            month : current_date.month - _birth_month,
            days : current_date.days - _birth_date
        }
    }
} 
