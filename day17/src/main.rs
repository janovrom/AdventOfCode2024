fn verify(mut a: i64) -> bool {
    let expected = vec![2, 4, 1, 5, 7, 5, 0, 3, 4, 1, 1, 6, 5, 5, 3, 0];
    let mut idx = 0;
    while a != 0 {
        let mut b = (a % 8) as i32;
        b ^= 5;
        let c = (a >> b) as i32;
        a >>= 3;
        b ^= c;
        b ^= 6;
        let output = b % 8;
        if output != expected[idx] {
            return false;
        }
        idx += 1;
    }
    true
}

fn main() {
    let start = 8_i64.pow(15);
    let end = 8_i64.pow(16);
    let diff = end - start;
    let mut last_percentage = 0;
    for i in start..end {
        let a = i;
        let progress = i - start;
        if (progress * 100) / diff != last_percentage {
            last_percentage = (progress * 100) / diff;
            print!("\r{} out of {}/{}%", progress, diff, progress / diff);
        }
        if verify(a) {
            println!("\nfor {} we got correct result", i);
            // Set-Clipboard equivalent in Rust is not straightforward, so skipping it
            break;
        }
    }
}
