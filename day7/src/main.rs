use std::fs;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let filename = &args[1];

    let data = fs::read_to_string(filename).expect("Unable to read file");
    let mut sum = 0;
    for line in data.lines() {
        let number_strings = line.split(": ").collect::<Vec<&str>>();
        let total: i64 = number_strings[0].parse().unwrap();
        let lengths: Vec<usize> = number_strings[1].split(" ").map(|x|x.len()).collect();
        let numbers: Vec<i64> = number_strings[1].split(" ").map(|x| x.parse::<i64>().unwrap()).collect();
        
        let max = 3_i32.pow((numbers.len() - 1) as u32);

        for i in 0..max {
            let mut bytes = i;
            let mut solution = numbers[0];
            
            for j in 1..numbers.len() {
                let digit = bytes % 3;
                bytes /= 3;
                match digit {
                    0 => solution += numbers[j],
                    1 => solution *= numbers[j],
                    2 => solution = solution * 10_i64.pow(lengths[j] as u32) + numbers[j],
                    _ => panic!("Invalid digit"),
                }
            }

            if solution == total {
                sum += solution;
                break;
            }
        }
    }
    
    println!("{}", sum);
}