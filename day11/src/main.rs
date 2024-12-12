use rayon::prelude::*;

fn get_length(x: i64) -> u32 {
    let mut length = 0;
    let mut temp = x;
    while temp > 0 {
        temp /= 10;
        length += 1;
    }
    return length;
}

fn main() {
    // This time it's small enough to be inlined
    // But replace with real input, this is just the redacted test data
    // let input = [125, 17];
    let input: [i64; 8] = [28591, 78, 0, 3159881, 4254, 524155, 598, 1];

    let total_blinks = 75;
    let total_sum: i32 = input.par_iter().map(|&stone| {
        let mut sum = 0;
        // While saying queue, it's used as a stack because of the insane allocations
        let mut queue = std::collections::VecDeque::new();
        queue.push_back((stone, 0));
        while !queue.is_empty() {
            let (current_stone, current_blinks) = queue.pop_back().unwrap();
            if current_blinks == total_blinks {
                sum += 1;
                continue;
            }

            let next_blinks = current_blinks + 1;

            if current_stone == 0 {
                queue.push_back((1, next_blinks));
                continue;
            }

            let length = get_length(current_stone);
            if length % 2 == 0 {
                let half = length / 2;
                let pow = 10_i64.pow(half);
                let left = current_stone / pow;
                let right = current_stone % pow;
                queue.push_back((left, next_blinks));
                queue.push_back((right, next_blinks));
                continue;
            }

            queue.push_back((current_stone * 2024, next_blinks));
        }

        sum
    }).sum();

    println!("{}", total_sum);
}
