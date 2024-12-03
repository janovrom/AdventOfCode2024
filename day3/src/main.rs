use regex::Regex;
use std::{
    env,
    fs::File,
    io::{self, Read},
};

fn solution1(haystack: &str) {
    let regex = Regex::new(r"mul\([0-9]{1,3},[0-9]{1,3}\)").unwrap();
    let mut sum = 0;
    for cap in regex.captures_iter(haystack) {
        let numbers_only = &cap[0].replace("mul(", "").replace(")", "");
        let operands: Vec<&str> = numbers_only.split(",").collect();
        let operand1 = operands[0].parse::<i32>().unwrap();
        let operand2 = operands[1].parse::<i32>().unwrap();

        sum += operand1 * operand2;
    }

    println!("Sum: {}", sum);
}

fn solution2(haystack: &str) {
    let regex = Regex::new(r"mul\([0-9]{1,3},[0-9]{1,3}\)|do\(\)|don't\(\)").unwrap();
    let mut sum = 0;
    let mut mul = 1;
    for cap in regex.captures_iter(haystack) {
        if &cap[0] == "do()" {
            mul = 1;
            continue;
        } else if &cap[0] == "don't()" {
            mul = 0;
            continue;
        }

        let numbers_only = &cap[0].replace("mul(", "").replace(")", "");
        let operands: Vec<&str> = numbers_only.split(",").collect();
        let operand1 = operands[0].parse::<i32>().unwrap();
        let operand2 = operands[1].parse::<i32>().unwrap();

        sum += mul * operand1 * operand2;
    }

    println!("Sum: {}", sum);
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <file_path> <solution-id>", args[0]);
        return Ok(());
    }

    let path = &args[1];
    let input = File::open(path)?;
    let mut buffered = io::BufReader::new(input);
    let mut input_memory: String = String::new();
    let _ = buffered.read_to_string(&mut input_memory);

    let haystack = input_memory.clone();
    if &args[1] == "1" {
        solution1(&haystack);
    } else {
        solution2(&haystack);
    }
    
    Ok(())
}
