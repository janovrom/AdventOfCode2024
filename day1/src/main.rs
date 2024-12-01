use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{self, BufRead};

fn solution1(left: &mut [i32], right: &mut [i32]) {
    left.sort();
    right.sort();

    let mut sum: i32 = 0;
    for i in 0..left.len() {
        let diff: i32 = (left[i] - right[i]).abs();
        sum += diff;
    }

    println!("{}", sum);
}

fn solution2(left: &[i32], right: &[i32]) {
    let mut counter: HashMap<i32, i32> = HashMap::new();
    for &x in right {
        *counter.entry(x).or_insert(0) += 1;
    }

    let mut sum = 0;
    for x in left {
        let similarity = x * counter.get(x).unwrap_or(&0);
        sum += similarity;
    }

    println!("{}", sum);
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <file_path>", args[0]);
        return Ok(());
    }

    let path = &args[1];
    let input = File::open(path)?;
    let buffered = io::BufReader::new(input);

    let mut left = Vec::new();
    let mut right = Vec::new();

    for line in buffered.lines() {
        let line = line?;
        let parts: Vec<&str> = line.split_whitespace().collect();
        if parts.len() == 2 {
            if let (Ok(a), Ok(b)) = (parts[0].parse::<i32>(), parts[1].parse::<i32>()) {
                left.push(a);
                right.push(b);
            }
        }
    }

    if left.len() == right.len() {
        if args[2] == "1" {
            solution1(&mut left, &mut right);
        } else if args[2] == "2" {
            solution2(&mut left, &mut right);
        } else {
            eprintln!("Invalid solution number.");
        }
    } else {
        eprintln!("The number of elements in left and right arrays do not match.");
    }

    Ok(())
}
