use std::collections::HashMap;
use std::fs;

fn evolve(number: u32) -> u32 {
    let mut number = number;
    let v0 = number << 6;
    number ^= v0;
    number %= 16777216;

    let v1 = number >> 5;
    number ^= v1;
    number %= 16777216;

    let v2 = number << 11;
    number ^= v2;
    number %= 16777216;

    number
}

fn add_hashed(x: i64, y: i64) -> i64 {
    let modulus = 1_000_000_000_000;
    let sliding_window = (x * 1000 + (y + 10)) % modulus;
    sliding_window
}

fn reverse_hash(hash: i64) -> (i64, i64, i64, i64) {
    let mut hash = hash;
    let w = hash % 1000 - 10;
    hash /= 1000;
    let z = hash % 1000 - 10;
    hash /= 1000;
    let y = hash % 1000 - 10;
    hash /= 1000;
    let x = hash % 1000 - 10;

    (x, y, z, w)
}

fn get_occurrences(number: u32, iterations: usize) -> HashMap<i64, u32> {
    let mut occurrences = HashMap::new();
    let mut result = number;
    let mut previous = number % 10;
    let mut sliding_window: i64 = 0;

    for i in 0..iterations {
        result = evolve(result);
        let change = (result % 10) as i64 - previous as i64;
        sliding_window = add_hashed(sliding_window, change);

        if i >= 3 {
            if !occurrences.contains_key(&sliding_window) {
                occurrences.insert(sliding_window, result % 10);
            }
        }

        previous = result % 10;
    }

    occurrences
}

fn load_data(file_path: &str) -> (Vec<u32>, usize) {
    let data = fs::read_to_string(file_path).expect("Unable to read file");
    let secret_numbers = data.lines().map(|line| line.parse::<u32>().unwrap()).collect();
    (secret_numbers, 2000)
}

fn main() {
    let (secret_numbers, iterations) = load_data("data.txt");

    let mut most_bananalicious = HashMap::new();
    for &secret_number in &secret_numbers {
        let occurrences = get_occurrences(secret_number, iterations);
        for (&key, &value) in &occurrences {
            *most_bananalicious.entry(key).or_insert(0) += value;
        }
    }

    let best_occurrence = most_bananalicious.iter().max_by_key(|&(_, &val)| val).unwrap();
    let (x, y, z, w) = reverse_hash(*best_occurrence.0);

    println!("{},{},{},{}", x, y, z, w);
    println!("{}", best_occurrence.1);
}
