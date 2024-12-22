use std::collections::{HashMap, HashSet};
use std::fs;

fn parse_data(data: Vec<String>, depth: usize) -> (Vec<String>, usize) {
    (data, depth)
}

fn load_data() -> (Vec<String>, usize) {
    let data = fs::read_to_string("data.txt").expect("Unable to read file");
    let data: Vec<String> = data.lines().map(|line| line.to_string()).collect();
    parse_data(data, 3)
}

fn load_data_part2() -> (Vec<String>, usize) {
    let data = fs::read_to_string("data.txt").expect("Unable to read file");
    let data: Vec<String> = data.lines().map(|line| line.to_string()).collect();
    parse_data(data, 26)
}

fn index_of(data: &[Vec<char>], value: char) -> (usize, usize) {
    for (i, row) in data.iter().enumerate() {
        for (j, &cell) in row.iter().enumerate() {
            if cell == value {
                return (i, j);
            }
        }
    }
    panic!("Value {} not found", value);
}

fn flood_fill(x: isize, y: isize, data: &[Vec<char>], steps: usize, visited: &mut Vec<Vec<isize>>) {
    if x < 0 || x >= data.len() as isize || y < 0 || y >= data[0].len() as isize {
        return;
    }

    let (x, y) = (x as usize, y as usize);

    if data[x][y] == 'X' || visited[x][y] <= steps as isize {
        return;
    }

    visited[x][y] = steps as isize;

    let steps = steps + 1;
    flood_fill(x as isize - 1, y as isize, data, steps, visited);
    flood_fill(x as isize + 1, y as isize, data, steps, visited);
    flood_fill(x as isize, y as isize - 1, data, steps, visited);
    flood_fill(x as isize, y as isize + 1, data, steps, visited);
}

fn get_all_shortest_paths(
    x: isize,
    y: isize,
    data: &[Vec<char>],
    steps: usize,
    visited: &[Vec<isize>],
    path: String,
    path_set: &mut HashSet<String>,
) {
    if x < 0 || x >= data.len() as isize || y < 0 || y >= data[0].len() as isize {
        return;
    }

    let (x, y) = (x as usize, y as usize);

    if data[x][y] == 'X' || visited[x][y] != steps as isize {
        return;
    }

    if visited[x][y] == 0 {
        let path = reverse_movement(&path);
        path_set.insert(path);
        return;
    }

    let steps = steps - 1;
    get_all_shortest_paths(x as isize - 1, y as isize, data, steps, visited, format!("{}^", path), path_set);
    get_all_shortest_paths(x as isize + 1, y as isize, data, steps, visited, format!("{}v", path), path_set);
    get_all_shortest_paths(x as isize, y as isize - 1, data, steps, visited, format!("{}<", path), path_set);
    get_all_shortest_paths(x as isize, y as isize + 1, data, steps, visited, format!("{}>", path), path_set);
}

fn reverse_movement(value: &str) -> String {
    value.chars().rev().map(|c| match c {
        '^' => 'v',
        'v' => '^',
        '<' => '>',
        '>' => '<',
        _ => c,
    }).collect()
}

fn flood_fill_keyboard() -> HashMap<String, HashSet<String>> {
    let keyboard = vec![
        vec!['7', '8', '9'],
        vec!['4', '5', '6'],
        vec!['1', '2', '3'],
        vec!['X', '0', 'A'],
    ];

    let letters = vec!['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A'];
    let mut lookup = HashMap::new();

    for &l0 in &letters {
        for &l1 in &letters {
            if l0 == l1 {
                continue;
            }

            let (x0, y0) = index_of(&keyboard, l0);
            let (x1, y1) = index_of(&keyboard, l1);

            let mut visited = vec![
                vec![100; 3],
                vec![100; 3],
                vec![100; 3],
                vec![-1, 100, 100],
            ];

            flood_fill(x0 as isize, y0 as isize, &keyboard, 0, &mut visited);

            let steps = visited[x1][y1] as usize;
            let mut path_set = HashSet::new();
            get_all_shortest_paths(x1 as isize, y1 as isize, &keyboard, steps, &visited, String::new(), &mut path_set);
            lookup.insert(format!("{}{}", l0, l1), path_set);
        }
    }

    lookup
}

fn flood_fill_movement_keyboard() -> HashMap<String, HashSet<String>> {
    let keyboard = vec![
        vec!['X', '^', 'A'],
        vec!['<', 'v', '>'],
    ];

    let letters = vec!['A', 'v', '^', '<', '>'];
    let mut lookup = HashMap::new();

    for &l0 in &letters {
        for &l1 in &letters {
            let (x0, y0) = index_of(&keyboard, l0);
            let (x1, y1) = index_of(&keyboard, l1);

            let mut visited = vec![
                vec![-1, 100, 100],
                vec![100, 100, 100],
            ];

            flood_fill(x0 as isize, y0 as isize, &keyboard, 0, &mut visited);

            let steps = visited[x1][y1] as usize;
            let mut path_set = HashSet::new();
            get_all_shortest_paths(x1 as isize, y1 as isize, &keyboard, steps, &visited, String::new(), &mut path_set);
            if path_set.is_empty() {
                panic!("No path found for {} {}", l0, l1);
            }
            lookup.insert(format!("{}{}", l0, l1), path_set);
        }
    }

    lookup
}

fn shortest_movement(
    code: &str,
    code_lookup: &HashMap<String, HashSet<String>>,
    movement_lookup: &HashMap<String, HashSet<String>>,
    depth: usize,
    visited: &mut HashMap<String, u64>,
    search_depth: usize,
) -> u64 {
    if depth == search_depth {
        return code.len() as u64;
    }

    let cache_key = format!("{},{}", code, depth);
    if let Some(result) = visited.get(&cache_key) {
        return *result;
    }

    let mut current = 'A';
    let mut result = 0;
    for c in code.chars() {
        let key = format!("{}{}", current, c);
        if let Some(paths) = code_lookup.get(&key) {
            let mut movement = u64::MAX;
            for path in paths {
                let path = format!("{}A", path);
                let shortest_path = shortest_movement(&path, movement_lookup, movement_lookup, depth + 1, visited, search_depth);
                if shortest_path < movement {
                    movement = shortest_path;
                }
            }
            result += movement;
        } else {
            panic!("Invalid key {}", key);
        }
        current = c;
    }

    visited.insert(cache_key, result);
    result
}

fn main() {
    let (data, search_depth) = load_data_part2();
    let code_lookup = flood_fill_keyboard();
    let movement_lookup = flood_fill_movement_keyboard();

    let mut sum = 0;
    let mut visited = HashMap::new();
    for code in data {
        let shortest = shortest_movement(&code, &code_lookup, &movement_lookup, 0, &mut visited, search_depth);
        println!("Code: {} Length: {}", code, shortest);
        sum += shortest * code[0..3].parse::<u64>().unwrap();
    }

    println!("{}", sum);
}
