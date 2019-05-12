#![no_std]
#![no_main]
#![feature(global_asm)]
#![feature(asm)]

extern crate fixedvec;
extern crate xmas_elf;

use core::panic::PanicInfo;
use bbl::sbi;

#[macro_use]
pub mod io;
pub mod elf;
global_asm!(include_str!("boot/entry.asm"));

static HELLO: &[u8] = b"Hello World!\n";

#[no_mangle]
pub extern "C" fn rust_main(){
    for &c in HELLO {
        sbi::console_putchar(c as u8 as usize);
    }
    elf::elf_interpreter();
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> !{
    loop{}
}

#[no_mangle]
fn abort() {

}
