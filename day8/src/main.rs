use std::{
    collections::{hash_map, hash_set},
    env, fs,
};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <file-name> <solution-id>", args[0]);
        std::process::exit(1);
    }

    let file_name = &args[1];
    let solution_id = &args[2];
    let data = fs::read_to_string(file_name).expect("Unable to read file");

    let lines: Vec<&str> = data.lines().collect();
    let maxx: i32 = lines.len() as i32;
    let maxy: i32 = lines[0].len() as i32;

    let mut nodes = hash_map::HashMap::new();

    let mut i = 0;
    for line in lines {
        let mut j = 0;
        for c in line.chars() {
            if c == '.' {
                j += 1;
                continue;
            }

            nodes.entry(c).or_insert_with(Vec::new).push((i, j));

            j += 1;
        }

        i += 1;
    }

    let mut antinodes = hash_set::HashSet::new();
    for k in nodes.keys() {
        let antennas = &nodes[k];
        for a1 in antennas {
            for a2 in antennas {
                if a1 == a2 {
                    if solution_id == "2" {
                        antinodes.insert(*a1);
                    }
                    continue;
                }

                let dx = a1.0 - a2.0;
                let dy = a1.1 - a2.1;

                if solution_id == "1" {
                    let mut x: i32 = a1.0;
                    let mut y: i32 = a1.1;
                    x += dx;
                    y += dy;

                    if x < 0 || x >= maxx || y < 0 || y >= maxy {
                        continue;
                    }

                    antinodes.insert((x, y));
                } else {
                    let mut x: i32 = a1.0;
                    let mut y: i32 = a1.1;

                    loop {
                        x += dx;
                        y += dy;
                        
                        if x < 0 || x >= maxx || y < 0 || y >= maxy {
                            break;
                        }
                        
                        antinodes.insert((x, y));
                    }
                }
            }
        }
    }

    eprintln!("Antinodes: {}", antinodes.len());
}
