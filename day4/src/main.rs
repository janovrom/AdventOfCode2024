use std::{env, io};

const DIRECTIONS: [(i32, i32); 8] = [
    (1, 0),  // Right
    (-1, 0), // Left
    (0, 1),  // Down
    (0, -1), // Up
    (1, 1),  // Down-Right
    (1, -1), // Down-Left
    (-1, 1), // Up-Right
    (-1, -1) // Up-Left
];

fn map_dir_to_string(grid: &Vec<Vec<char>>, dx: i32, dy: i32, x: i32, y: i32) -> String {
    let mut result = String::new();
    for i in 0..4 {
        result.push(grid[(x + i*dx) as usize][(y + i*dy) as usize]);
    }
    return result;
}

fn evaluate_xmas(grid: &Vec<Vec<char>>, x: i32, y: i32) -> i32 {
    let mut sum = 0;
    
    for &(dx, dy) in DIRECTIONS.iter() {
        if map_dir_to_string(grid, dx, dy, x, y) == "XMAS" {
            sum += 1;
        }
    }

    return sum;
}

fn solution1(grid: &Vec<Vec<char>>) {
    let mut sum = 0;
    for i in 3..grid.len()-3 {
        for j in 3..grid[0].len() -3{
            if grid[i][j] == 'X' {
                sum += evaluate_xmas(grid, i as i32, j as i32);
            }
        }
    }

    println!("Sum: {}", sum);
}

fn map_cross_to_string(grid: &Vec<Vec<char>>, x: i32, y: i32) -> String {
    let mut result = String::new();
    result.push(grid[(x - 1) as usize][(y - 1) as usize]);
    result.push(grid[(x - 1) as usize][(y + 1) as usize]);
    result.push(grid[(x + 1) as usize][(y - 1) as usize]);
    result.push(grid[(x + 1) as usize][(y + 1) as usize]);
    return result;
}

// ms|mm|sm|ss
// ms|ss|sm|mm
// msms|mmss|smsm|ssmm
fn evaluate_mas(grid: &Vec<Vec<char>>, x: i32, y: i32) -> i32 {
    let cross = map_cross_to_string(grid, x, y);
    
    if cross == "MSMS" || cross == "MMSS" || cross == "SMSM" || cross == "SSMM" {
        return 1;
    }

    return 0;
}

fn solution2(grid: &Vec<Vec<char>>) {
    let mut sum = 0;
    for i in 3..grid.len()-3 {
        for j in 3..grid[0].len() -3{
            if grid[i][j] == 'A' {
                sum += evaluate_mas(grid, i as i32, j as i32);
            }
        }
    }

    println!("Sum: {}", sum);
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <file-path> <solution-id>", args[0]);
        return Ok(());
    }

    let path = &args[1];
    let solution_id = &args[2];
    let lines: Vec<Vec<char>> = std::fs::read_to_string(path)?
        .lines()
        .map(|line| line.chars().collect())
        .collect();

    let padded_rows = lines.len() + 6;
    let padded_cols = lines[0].len() + 6;
    let mut grid = vec![vec!['.'; padded_cols]; padded_rows];
    
    for (i, row) in lines.iter().enumerate() {
        for (j, &cell) in row.iter().enumerate() {
            grid[i + 3][j + 3] = cell;
        }
    }

    if solution_id == "1" {
        solution1(&grid);
    } else if solution_id == "2" {
        solution2(&grid);
    }

    Ok(())
}
