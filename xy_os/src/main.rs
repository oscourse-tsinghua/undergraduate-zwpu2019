#![no_std]
#![no_main]
#![feature(global_asm)]
#![feature(asm)]

use core::panic::PanicInfo;
use bbl::sbi;

#[macro_use]
pub mod io;

global_asm!(include_str!("boot/entry.asm"));

static HELLO: &[u8] = b"Hello World!\n";

#[no_mangle]
pub extern "C" fn rust_main(){
    
    for &c in HELLO {
        sbi::console_putchar(c as u8 as usize);
    }

    io::puts("6666\n");

    let a = "Hello";
    let b = "World!\n";

    print!("{} {}", a, b);
    println!("{}", a);
    println!();

    panic!("End of main");
}


#[panic_handler]
fn panic(info: &PanicInfo) -> !{
    loop{}
}

#[no_mangle]
fn abort() {

}
