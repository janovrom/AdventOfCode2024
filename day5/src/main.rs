use std::{collections::HashSet, env, fmt, io, num::ParseIntError};

#[derive(Debug)]
enum SolveError {
    Parse(ParseIntError),
    Io(io::Error),
    UnknownSolutionId,
}

impl From<ParseIntError> for SolveError {
    fn from(e: ParseIntError) -> Self {
        SolveError::Parse(e)
    }
}

impl From<io::Error> for SolveError {
    fn from(e: io::Error) -> Self {
        SolveError::Io(e)
    }
}

impl fmt::Display for SolveError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            SolveError::Parse(e) => write!(f, "Parse error: {}", e),
            SolveError::Io(e) => write!(f, "IO error: {}", e),
            SolveError::UnknownSolutionId => write!(f, "Unknown solution id"),
        }
    }
}

fn solve(solution_id: &str, data: &str) -> Result<i32, SolveError> {
    match solution_id {
        "1" => solve1(data).map_err(SolveError::from),
        "2" => solve2(data).map_err(SolveError::from),
        _ => {
            return Err(SolveError::UnknownSolutionId);
        }
    }
}

fn sort_updates(edges: &HashSet<String>, updates: &mut Vec<String>) -> bool {
    let len = updates.len();
    let mut i = 0;
    while i < len {
        let mut swapped = false;
        for j in i + 1..len {
            let a = &updates[i];
            let b = &updates[j];

            // We can be in correct order, but shouldn't be in reverse
            let v = format!("{}|{}", b, a);

            if edges.contains(&v) {
                // Nevermind, it is the end of the world.
                updates.swap(i, j);
                swapped = true;
                break;
            }
        }

        if swapped {
            i = 0;
        } else {
            i += 1;
        }
    }

    return true;
}

fn solve2(data: &str) -> Result<i32, ParseIntError> {
    let mut is_rule = true;
    let mut edges = HashSet::<String>::new();
    let mut sum = 0;
    for line in data.lines() {
        if line.is_empty() {
            is_rule = false;
            continue;
        }

        if is_rule {
            edges.insert(line.to_string());
        } else {
            let mut updates: Vec<String> = line.split(",").map(|s| s.to_string()).collect();
            if !evaluate_updates(&edges, &updates) {
                sort_updates(&edges, &mut updates);
                sum += updates[updates.len() / 2].parse::<i32>()?;
            }
        }
    }

    Ok(sum)
}

fn evaluate_updates(edges: &HashSet<String>, updates: &Vec<String>) -> bool {
    let len = updates.len();
    for i in 0..len {
        for j in i + 1..len {
            let a = &updates[i];
            let b = &updates[j];

            let u = format!("{}|{}", a, b);

            if !edges.contains(&u) {
                // This might not be the end of the world.
                // It just can't contain the reverse.
                let v = format!("{}|{}", b, a);
                if edges.contains(&v) {
                    // Nevermind, it is the end of the world.
                    return false;
                }
            }
        }
    }

    return true;
}

fn solve1(data: &str) -> Result<i32, ParseIntError> {
    let mut is_rule = true;
    let mut edges = HashSet::<String>::new();
    let mut sum = 0;
    for line in data.lines() {
        if line.is_empty() {
            is_rule = false;
            continue;
        }

        if is_rule {
            edges.insert(line.to_string());
        } else {
            let updates: Vec<String> = line.split(",").map(|s| s.to_string()).collect();
            if evaluate_updates(&edges, &updates) {
                sum += updates[updates.len() / 2].parse::<i32>()?;
            }
        }
    }

    Ok(sum)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 3 {
        eprintln!("Usage: {} <input-file> <solution-id>", args[0]);
        return;
    }

    let input_file = &args[1];
    let solution_id = &args[2];
    let data = std::fs::read_to_string(input_file);

    match data
        .map_err(SolveError::from)
        .and_then(|data| solve(solution_id, &data))
    {
        Ok(sum) => {
            println!("Result: {}", sum);
        }
        Err(e) => {
            eprintln!("Error: {}", e);
        }
    }
}
