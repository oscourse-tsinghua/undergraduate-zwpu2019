use core::mem::transmute;
use core::slice;
//use core::ptr;
use xmas_elf::{
    header,
    ElfFile,
};


#[no_mangle]
pub extern "C" fn elf_interpreter() {

    let _elf_payload_start = 0x9000;
    let _elf_payload_end = 0xad64;

    let kernel_size = _elf_payload_end as usize - _elf_payload_start as usize;
    let kernel = unsafe { slice::from_raw_parts(_elf_payload_start as *const u8, kernel_size) };
    let kernel_elf = ElfFile::new(kernel).unwrap();
    header::sanity_check(&kernel_elf).unwrap();

    for program_header in kernel_elf.program_iter() {
	    println!("{:?}", program_header);
    }

    let entry = kernel_elf.header.pt2.entry_point() as u32;
    let kernel_main: extern "C" fn( ) = unsafe { transmute(entry) };

    println!("kernel_main: {:#?}", kernel_main);
//   copy_kernel(_elf_payload_start as usize, &segments);
    kernel_main( );
}

//const KERNEL_OFFSET: u32 = 0x80000000;

//dnn't need to copy
// pub fn copy_kernel(kernel_start: usize, segments: &FixedVec<ProgramHeader32>) {
//     // reverse program headers to avoid overlapping in memory copying
//     let mut space = alloc_stack!([ProgramHeader32; 32]);
//     let mut rev_segments = FixedVec::new(&mut space);
//     for i in (0..segments.len()).rev() {
//         rev_segments.push(segments[i]).unwrap();
//     }

//     for segment in &rev_segments {
//         if segment.get_type() != Ok(Type::Load) {
//             continue;
//         }
//         let virt_addr = segment.virtual_addr;
//         let offset = segment.offset;
//         let file_size = segment.file_size;
//         let mem_size = segment.mem_size;

//         unsafe {
//             let src = (kernel_start as u32 + offset) as *const u8;
//             let dst = virt_addr.wrapping_sub(KERNEL_OFFSET) as *mut u8;
//             ptr::copy(src, dst, file_size as usize);
//             ptr::write_bytes(dst.offset(file_size as isize), 0, (mem_size - file_size) as usize);
//         }
//     }

// }
