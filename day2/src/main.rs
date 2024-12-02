use std::fs::File;
use std::io::{self, BufRead};
use std::env;

fn is_safe(levels: &[i32]) -> bool {
    let mut differences: Vec<i32> = Vec::new();
    for i in 0..levels.len() - 1 {
        let diff = levels[i] - levels[i + 1];
        differences.push(diff);
    }

    if differences[0] == 0 {
        return false;
    }

    let is_increasing = differences[0] > 0;
    let min = if is_increasing { 1 } else { -3 };
    let max = if is_increasing { 3 } else { -1 };

    for i in 0..differences.len() {
        if differences[i] < min || differences[i] > max || differences[i] == 0 {
            return false;
        }
    }
    
    true
}

fn solution1(levels: &[i32]) -> bool {
    return is_safe(levels);
}

fn solution2(levels: &[i32]) -> bool {
    let mut is_safe_flag = false;
    for i in -1..levels.len() as isize {
        let new_levels: Vec<i32> = if i == -1 {
            levels[0..levels.len()].to_vec()
        } else if i == levels.len() as isize - 1 {
            levels[0..levels.len() - 1].to_vec()
        } else if i == 0 {
            levels[1..levels.len()].to_vec()
        } else {
            let mut new_levels = levels[0..i as usize].to_vec();
            new_levels.extend_from_slice(&levels[(i as usize + 1)..levels.len()]);
            new_levels
        };

        if is_safe(&new_levels) {
            is_safe_flag = true;
            break;
        }
    }
    return is_safe_flag;
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
 
    let mut safe_counter = 0;
    for line in buffered.lines() {
        let line = line?;
        let parts: Vec<&str> = line.split_whitespace().collect();

        let mut levels = Vec::new();
        for part in parts {
            if let Ok(level) = part.parse::<i32>() {
                levels.push(level);
            }
        }
        
        let result = if args[2] == "1" { solution1(&levels) } else { solution2(&levels)};

        if result {
            safe_counter += 1;
        }
    }

    println!("{}", safe_counter);

    Ok(())
}
