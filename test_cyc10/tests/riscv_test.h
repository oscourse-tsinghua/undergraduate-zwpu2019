#ifndef _ENV_PICORV32_TEST_H
#define _ENV_PICORV32_TEST_H

#ifndef TEST_FUNC_NAME
#  define TEST_FUNC_NAME mytest
#  define TEST_FUNC_TXT "mytest"
#  define TEST_FUNC_RET mytest_ret
#endif

#define RVTEST_RV32U
#define TESTNUM x28

#define RVTEST_CODE_BEGIN		\
	.text;				\
	.global TEST_FUNC_NAME;		\
	.global TEST_FUNC_RET;		\
TEST_FUNC_NAME:				\
	li	a0, 0xffff;		\
.delay_pr:				\
	addi	a0,a0,-1;		\
	bne	a0,zero,.delay_pr;	\
	lui	a0,%hi(.test_name);	\
	addi	a0,a0,%lo(.test_name);	\
	lui	a2,0x02000;		\
	addi	a2,a2,0x4;		\
.prname_next:				\
	lb	a1,0(a0);		\
	beq	a1,zero,.prname_done;	\
	jal ra, trdy;			\
	sw	a1,0(a2);		\
	addi	a0,a0,1;		\
	jal	zero,.prname_next;	\
.test_name:				\
	.ascii TEST_FUNC_TXT;		\
	.byte 0x00;			\
	.balign 4, 0;			\
.prname_done:				\
	addi	a1,zero,'.';		\
	jal ra, trdy;			\
	sw	a1,0(a2);		\
	jal ra, trdy;			\
	sw	a1,0(a2);

#define RVTEST_PASS			\
	li	a0, 0xfff;		\
.delay_pass:				\
	addi	a0,a0,-1;		\
	bne	a0,zero,.delay_pass;	\
	lui	a0,0x02000;		\
	addi    a0,a0,0x4;		\
	jal ra, trdy;			\
	addi	a1,zero,'O';		\
	sw	a1,0(a0);		\
	jal ra, trdy;			\
	addi	a1,zero,'K';		\
	sw	a1,0(a0);		\
	jal ra, trdy;			\
	addi	a1,zero,'\r';		\
	sw	a1,0(a0);		\
	jal ra, trdy;			\
	addi	a1,zero,'\n';		\
	sw	a1,0(a0);		\
	jal	zero,TEST_FUNC_RET;

#define RVTEST_FAIL			\
	li	a0, 0xffff;		\
.delay_fail:				\
	addi	a0,a0,-1;		\
	bne	a0,zero,.delay_fail;	\
	lui	a0,0x02000;		\
	addi    a0,a0,0x4;		\
	addi	a1,zero,'E';		\
	addi	a2,zero,'R';		\
	addi	a3,zero,'O';		\
	addi	a4,zero,'\n';		\
	jal ra, trdy;			\
	sw	a1,0(a0);		\
	jal ra, trdy;			\
	sw	a2,0(a0);		\
	jal ra, trdy;			\
	sw	a2,0(a0);		\
	jal ra, trdy;			\
	sw	a3,0(a0);		\
	jal ra, trdy;			\
	sw	a2,0(a0);		\
	jal ra, trdy;			\
	sw	a4,0(a0);		\
	jal ra, trdy;			\
	addi 	a4,zero,'\r';		\
	sw	a4,0(a0);		\
	jal	zero,TEST_FUNC_RET;	

#define RVTEST_CODE_END
#define RVTEST_DATA_BEGIN .balign 4;
#define RVTEST_DATA_END

#endif
