
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b4013103          	ld	sp,-1216(sp) # 80008b40 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// they will arrive in machine mode at
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid"
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64 *)CLINT_MTIMECMP(id) = *(uint64 *)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	b5070713          	addi	a4,a4,-1200 # 80008ba0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0"
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0"
    80000062:	00006797          	auipc	a5,0x6
    80000066:	3fe78793          	addi	a5,a5,1022 # 80006460 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus"
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0"
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie"
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0"
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus"
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdb922f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0"
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0"
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	f4078793          	addi	a5,a5,-192 # 80000fec <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0"
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0"
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0"
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie"
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0"
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0"
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0"
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid"
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0"
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
  {
    char c;
    if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	7e4080e7          	jalr	2020(ra) # 8000290e <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	b5650513          	addi	a0,a0,-1194 # 80010ce0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	bb8080e7          	jalr	-1096(ra) # 80000d4a <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	b4648493          	addi	s1,s1,-1210 # 80010ce0 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	bd690913          	addi	s2,s2,-1066 # 80010d78 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if (c == C('D'))
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if (c == '\n')
    800001ae:	4ca9                	li	s9,10
  while (n > 0)
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while (cons.r == cons.w)
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if (killed(myproc()))
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	9ba080e7          	jalr	-1606(ra) # 80001b7a <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	590080e7          	jalr	1424(ra) # 80002758 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	156080e7          	jalr	342(ra) # 8000232c <sleep>
    while (cons.r == cons.w)
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if (c == C('D'))
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	6a6080e7          	jalr	1702(ra) # 800028b8 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if (c == '\n')
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	aba50513          	addi	a0,a0,-1350 # 80010ce0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	bd0080e7          	jalr	-1072(ra) # 80000dfe <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	aa450513          	addi	a0,a0,-1372 # 80010ce0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	bba080e7          	jalr	-1094(ra) # 80000dfe <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if (n < target)
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	b0f72323          	sw	a5,-1274(a4) # 80010d78 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if (c == BACKSPACE)
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	a1450513          	addi	a0,a0,-1516 # 80010ce0 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	a76080e7          	jalr	-1418(ra) # 80000d4a <acquire>

  switch (c)
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  {
  case C('P'): // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	672080e7          	jalr	1650(ra) # 80002964 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	9e650513          	addi	a0,a0,-1562 # 80010ce0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	afc080e7          	jalr	-1284(ra) # 80000dfe <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch (c)
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	9c270713          	addi	a4,a4,-1598 # 80010ce0 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	99878793          	addi	a5,a5,-1640 # 80010ce0 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	a027a783          	lw	a5,-1534(a5) # 80010d78 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	95670713          	addi	a4,a4,-1706 # 80010ce0 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	94648493          	addi	s1,s1,-1722 # 80010ce0 <cons>
    while (cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while (cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if (cons.e != cons.w)
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	90a70713          	addi	a4,a4,-1782 # 80010ce0 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	98f72a23          	sw	a5,-1644(a4) # 80010d80 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	8ce78793          	addi	a5,a5,-1842 # 80010ce0 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	94c7a323          	sw	a2,-1722(a5) # 80010d7c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	93a50513          	addi	a0,a0,-1734 # 80010d78 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	0a2080e7          	jalr	162(ra) # 800024e8 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	88050513          	addi	a0,a0,-1920 # 80010ce0 <cons>
    80000468:	00001097          	auipc	ra,0x1
    8000046c:	852080e7          	jalr	-1966(ra) # 80000cba <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00243797          	auipc	a5,0x243
    8000047c:	c4078793          	addi	a5,a5,-960 # 802430b8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if (sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do
  {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if (sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while (--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while (--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if (sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
  if (locking)
    release(&pr.lock);
}

void panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00011797          	auipc	a5,0x11
    80000550:	8407aa23          	sw	zero,-1964(a5) # 80010da0 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b9a50513          	addi	a0,a0,-1126 # 80008108 <digits+0xc8>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	5ef72023          	sw	a5,1504(a4) # 80008b60 <panicked>
  for (;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	7e4dad83          	lw	s11,2020(s11) # 80010da0 <pr+0x18>
  if (locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if (c != '%')
    800005de:	02500a93          	li	s5,37
    switch (c)
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch (c)
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	78e50513          	addi	a0,a0,1934 # 80010d88 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	748080e7          	jalr	1864(ra) # 80000d4a <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if (c != '%')
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if (c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch (c)
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch (c)
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if ((s = va_arg(ap, char *)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for (; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for (; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for (; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if (locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	63050513          	addi	a0,a0,1584 # 80010d88 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	69e080e7          	jalr	1694(ra) # 80000dfe <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	61448493          	addi	s1,s1,1556 # 80010d88 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	534080e7          	jalr	1332(ra) # 80000cba <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:
extern volatile int panicked; // from printf.c

void uartstart();

void uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	5d450513          	addi	a0,a0,1492 # 80010da8 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	4de080e7          	jalr	1246(ra) # 80000cba <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// alternate version of uartputc() that doesn't
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	506080e7          	jalr	1286(ra) # 80000cfe <push_off>

  if (panicked)
    80000800:	00008797          	auipc	a5,0x8
    80000804:	3607a783          	lw	a5,864(a5) # 80008b60 <panicked>
    for (;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if (panicked)
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for (;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	578080e7          	jalr	1400(ra) # 80000d9e <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void uartstart()
{
  while (1)
  {
    if (uart_tx_w == uart_tx_r)
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	3307b783          	ld	a5,816(a5) # 80008b68 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	33073703          	ld	a4,816(a4) # 80008b70 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
    {
      // transmit buffer is empty.
      return;
    }

    if ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }

    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	546a0a13          	addi	s4,s4,1350 # 80010da8 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	2fe48493          	addi	s1,s1,766 # 80008b68 <uart_tx_r>
    if (uart_tx_w == uart_tx_r)
    80000872:	00008997          	auipc	s3,0x8
    80000876:	2fe98993          	addi	s3,s3,766 # 80008b70 <uart_tx_w>
    if ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)

    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	c54080e7          	jalr	-940(ra) # 800024e8 <wakeup>

    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if (uart_tx_w == uart_tx_r)
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	4d850513          	addi	a0,a0,1240 # 80010da8 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	472080e7          	jalr	1138(ra) # 80000d4a <acquire>
  if (panicked)
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	2807a783          	lw	a5,640(a5) # 80008b60 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	28673703          	ld	a4,646(a4) # 80008b70 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	2767b783          	ld	a5,630(a5) # 80008b68 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	4aa98993          	addi	s3,s3,1194 # 80010da8 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	26248493          	addi	s1,s1,610 # 80008b68 <uart_tx_r>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	26290913          	addi	s2,s2,610 # 80008b70 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	a0e080e7          	jalr	-1522(ra) # 8000232c <sleep>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	47448493          	addi	s1,s1,1140 # 80010da8 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	22e7b423          	sd	a4,552(a5) # 80008b70 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	4a4080e7          	jalr	1188(ra) # 80000dfe <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for (;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if (ReadReg(LSR) & 0x01)
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
  {
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  }
  else
  {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:

// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while (1)
  {
    int c = uartgetc();
    if (c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if (c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	3ee48493          	addi	s1,s1,1006 # 80010da8 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	386080e7          	jalr	902(ra) # 80000d4a <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	428080e7          	jalr	1064(ra) # 80000dfe <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <decrease_pgreference>:
  }
  return (void *)r;
}

int decrease_pgreference(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	1000                	addi	s0,sp,32
    800009f2:	84aa                	mv	s1,a0
  acquire(&page_ref.lock);
    800009f4:	00010517          	auipc	a0,0x10
    800009f8:	40c50513          	addi	a0,a0,1036 # 80010e00 <page_ref>
    800009fc:	00000097          	auipc	ra,0x0
    80000a00:	34e080e7          	jalr	846(ra) # 80000d4a <acquire>
  if (page_ref.count[(uint64)pa >> 12] <= 0)
    80000a04:	00c4d513          	srli	a0,s1,0xc
    80000a08:	00450713          	addi	a4,a0,4
    80000a0c:	070a                	slli	a4,a4,0x2
    80000a0e:	00010797          	auipc	a5,0x10
    80000a12:	3f278793          	addi	a5,a5,1010 # 80010e00 <page_ref>
    80000a16:	97ba                	add	a5,a5,a4
    80000a18:	479c                	lw	a5,8(a5)
    80000a1a:	02f05d63          	blez	a5,80000a54 <decrease_pgreference+0x6c>
  {
    panic("decrease_pgreference");
  }
  page_ref.count[(uint64)pa >> 12]--;
    80000a1e:	37fd                	addiw	a5,a5,-1
    80000a20:	0007869b          	sext.w	a3,a5
    80000a24:	0511                	addi	a0,a0,4
    80000a26:	050a                	slli	a0,a0,0x2
    80000a28:	00010717          	auipc	a4,0x10
    80000a2c:	3d870713          	addi	a4,a4,984 # 80010e00 <page_ref>
    80000a30:	972a                	add	a4,a4,a0
    80000a32:	c71c                	sw	a5,8(a4)
  if (page_ref.count[(uint64)pa >> 12] > 0)
    80000a34:	02d04863          	bgtz	a3,80000a64 <decrease_pgreference+0x7c>
  {
    release(&page_ref.lock);
    return 0;
  }
  release(&page_ref.lock);
    80000a38:	00010517          	auipc	a0,0x10
    80000a3c:	3c850513          	addi	a0,a0,968 # 80010e00 <page_ref>
    80000a40:	00000097          	auipc	ra,0x0
    80000a44:	3be080e7          	jalr	958(ra) # 80000dfe <release>
  return 1;
    80000a48:	4505                	li	a0,1
}
    80000a4a:	60e2                	ld	ra,24(sp)
    80000a4c:	6442                	ld	s0,16(sp)
    80000a4e:	64a2                	ld	s1,8(sp)
    80000a50:	6105                	addi	sp,sp,32
    80000a52:	8082                	ret
    panic("decrease_pgreference");
    80000a54:	00007517          	auipc	a0,0x7
    80000a58:	60c50513          	addi	a0,a0,1548 # 80008060 <digits+0x20>
    80000a5c:	00000097          	auipc	ra,0x0
    80000a60:	ae4080e7          	jalr	-1308(ra) # 80000540 <panic>
    release(&page_ref.lock);
    80000a64:	00010517          	auipc	a0,0x10
    80000a68:	39c50513          	addi	a0,a0,924 # 80010e00 <page_ref>
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	392080e7          	jalr	914(ra) # 80000dfe <release>
    return 0;
    80000a74:	4501                	li	a0,0
    80000a76:	bfd1                	j	80000a4a <decrease_pgreference+0x62>

0000000080000a78 <kfree>:
{
    80000a78:	1101                	addi	sp,sp,-32
    80000a7a:	ec06                	sd	ra,24(sp)
    80000a7c:	e822                	sd	s0,16(sp)
    80000a7e:	e426                	sd	s1,8(sp)
    80000a80:	e04a                	sd	s2,0(sp)
    80000a82:	1000                	addi	s0,sp,32
  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	e79d                	bnez	a5,80000ab6 <kfree+0x3e>
    80000a8a:	84aa                	mv	s1,a0
    80000a8c:	00245797          	auipc	a5,0x245
    80000a90:	b4478793          	addi	a5,a5,-1212 # 802455d0 <end>
    80000a94:	02f56163          	bltu	a0,a5,80000ab6 <kfree+0x3e>
    80000a98:	47c5                	li	a5,17
    80000a9a:	07ee                	slli	a5,a5,0x1b
    80000a9c:	00f57d63          	bgeu	a0,a5,80000ab6 <kfree+0x3e>
  if (!decrease_pgreference(pa))
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	f48080e7          	jalr	-184(ra) # 800009e8 <decrease_pgreference>
    80000aa8:	ed19                	bnez	a0,80000ac6 <kfree+0x4e>
}
    80000aaa:	60e2                	ld	ra,24(sp)
    80000aac:	6442                	ld	s0,16(sp)
    80000aae:	64a2                	ld	s1,8(sp)
    80000ab0:	6902                	ld	s2,0(sp)
    80000ab2:	6105                	addi	sp,sp,32
    80000ab4:	8082                	ret
    panic("kfree");
    80000ab6:	00007517          	auipc	a0,0x7
    80000aba:	5c250513          	addi	a0,a0,1474 # 80008078 <digits+0x38>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	a82080e7          	jalr	-1406(ra) # 80000540 <panic>
  memset(pa, 1, PGSIZE);
    80000ac6:	6605                	lui	a2,0x1
    80000ac8:	4585                	li	a1,1
    80000aca:	8526                	mv	a0,s1
    80000acc:	00000097          	auipc	ra,0x0
    80000ad0:	37a080e7          	jalr	890(ra) # 80000e46 <memset>
  acquire(&kmem.lock);
    80000ad4:	00010917          	auipc	s2,0x10
    80000ad8:	30c90913          	addi	s2,s2,780 # 80010de0 <kmem>
    80000adc:	854a                	mv	a0,s2
    80000ade:	00000097          	auipc	ra,0x0
    80000ae2:	26c080e7          	jalr	620(ra) # 80000d4a <acquire>
  r->next = kmem.freelist;
    80000ae6:	01893783          	ld	a5,24(s2)
    80000aea:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aec:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000af0:	854a                	mv	a0,s2
    80000af2:	00000097          	auipc	ra,0x0
    80000af6:	30c080e7          	jalr	780(ra) # 80000dfe <release>
    80000afa:	bf45                	j	80000aaa <kfree+0x32>

0000000080000afc <increase_pgreference>:

void increase_pgreference(void *pa)
{
    80000afc:	1101                	addi	sp,sp,-32
    80000afe:	ec06                	sd	ra,24(sp)
    80000b00:	e822                	sd	s0,16(sp)
    80000b02:	e426                	sd	s1,8(sp)
    80000b04:	1000                	addi	s0,sp,32
    80000b06:	84aa                	mv	s1,a0
  acquire(&page_ref.lock);
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	2f850513          	addi	a0,a0,760 # 80010e00 <page_ref>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	23a080e7          	jalr	570(ra) # 80000d4a <acquire>
  if (page_ref.count[(uint64)pa >> 12] < 0)
    80000b18:	00c4d793          	srli	a5,s1,0xc
    80000b1c:	00478693          	addi	a3,a5,4
    80000b20:	068a                	slli	a3,a3,0x2
    80000b22:	00010717          	auipc	a4,0x10
    80000b26:	2de70713          	addi	a4,a4,734 # 80010e00 <page_ref>
    80000b2a:	9736                	add	a4,a4,a3
    80000b2c:	4718                	lw	a4,8(a4)
    80000b2e:	02074463          	bltz	a4,80000b56 <increase_pgreference+0x5a>
  {
    panic("increase_pgreference");
  }
  page_ref.count[(uint64)pa >> 12]++;
    80000b32:	00010517          	auipc	a0,0x10
    80000b36:	2ce50513          	addi	a0,a0,718 # 80010e00 <page_ref>
    80000b3a:	0791                	addi	a5,a5,4
    80000b3c:	078a                	slli	a5,a5,0x2
    80000b3e:	97aa                	add	a5,a5,a0
    80000b40:	2705                	addiw	a4,a4,1
    80000b42:	c798                	sw	a4,8(a5)
  release(&page_ref.lock);
    80000b44:	00000097          	auipc	ra,0x0
    80000b48:	2ba080e7          	jalr	698(ra) # 80000dfe <release>
}
    80000b4c:	60e2                	ld	ra,24(sp)
    80000b4e:	6442                	ld	s0,16(sp)
    80000b50:	64a2                	ld	s1,8(sp)
    80000b52:	6105                	addi	sp,sp,32
    80000b54:	8082                	ret
    panic("increase_pgreference");
    80000b56:	00007517          	auipc	a0,0x7
    80000b5a:	52a50513          	addi	a0,a0,1322 # 80008080 <digits+0x40>
    80000b5e:	00000097          	auipc	ra,0x0
    80000b62:	9e2080e7          	jalr	-1566(ra) # 80000540 <panic>

0000000080000b66 <freerange>:
{
    80000b66:	7139                	addi	sp,sp,-64
    80000b68:	fc06                	sd	ra,56(sp)
    80000b6a:	f822                	sd	s0,48(sp)
    80000b6c:	f426                	sd	s1,40(sp)
    80000b6e:	f04a                	sd	s2,32(sp)
    80000b70:	ec4e                	sd	s3,24(sp)
    80000b72:	e852                	sd	s4,16(sp)
    80000b74:	e456                	sd	s5,8(sp)
    80000b76:	0080                	addi	s0,sp,64
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000b78:	6785                	lui	a5,0x1
    80000b7a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b7e:	00e504b3          	add	s1,a0,a4
    80000b82:	777d                	lui	a4,0xfffff
    80000b84:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b86:	94be                	add	s1,s1,a5
    80000b88:	0295e463          	bltu	a1,s1,80000bb0 <freerange+0x4a>
    80000b8c:	89ae                	mv	s3,a1
    80000b8e:	7afd                	lui	s5,0xfffff
    80000b90:	6a05                	lui	s4,0x1
    80000b92:	01548933          	add	s2,s1,s5
    increase_pgreference(p);
    80000b96:	854a                	mv	a0,s2
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	f64080e7          	jalr	-156(ra) # 80000afc <increase_pgreference>
    kfree(p);
    80000ba0:	854a                	mv	a0,s2
    80000ba2:	00000097          	auipc	ra,0x0
    80000ba6:	ed6080e7          	jalr	-298(ra) # 80000a78 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000baa:	94d2                	add	s1,s1,s4
    80000bac:	fe99f3e3          	bgeu	s3,s1,80000b92 <freerange+0x2c>
}
    80000bb0:	70e2                	ld	ra,56(sp)
    80000bb2:	7442                	ld	s0,48(sp)
    80000bb4:	74a2                	ld	s1,40(sp)
    80000bb6:	7902                	ld	s2,32(sp)
    80000bb8:	69e2                	ld	s3,24(sp)
    80000bba:	6a42                	ld	s4,16(sp)
    80000bbc:	6aa2                	ld	s5,8(sp)
    80000bbe:	6121                	addi	sp,sp,64
    80000bc0:	8082                	ret

0000000080000bc2 <kinit>:
{
    80000bc2:	1141                	addi	sp,sp,-16
    80000bc4:	e406                	sd	ra,8(sp)
    80000bc6:	e022                	sd	s0,0(sp)
    80000bc8:	0800                	addi	s0,sp,16
  initlock(&page_ref.lock, "page_ref");
    80000bca:	00007597          	auipc	a1,0x7
    80000bce:	4ce58593          	addi	a1,a1,1230 # 80008098 <digits+0x58>
    80000bd2:	00010517          	auipc	a0,0x10
    80000bd6:	22e50513          	addi	a0,a0,558 # 80010e00 <page_ref>
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	0e0080e7          	jalr	224(ra) # 80000cba <initlock>
  acquire(&page_ref.lock);
    80000be2:	00010517          	auipc	a0,0x10
    80000be6:	21e50513          	addi	a0,a0,542 # 80010e00 <page_ref>
    80000bea:	00000097          	auipc	ra,0x0
    80000bee:	160080e7          	jalr	352(ra) # 80000d4a <acquire>
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000bf2:	00010797          	auipc	a5,0x10
    80000bf6:	22678793          	addi	a5,a5,550 # 80010e18 <page_ref+0x18>
    80000bfa:	00230717          	auipc	a4,0x230
    80000bfe:	21e70713          	addi	a4,a4,542 # 80230e18 <pid_lock>
    page_ref.count[i] = 0;
    80000c02:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000c06:	0791                	addi	a5,a5,4
    80000c08:	fee79de3          	bne	a5,a4,80000c02 <kinit+0x40>
  release(&page_ref.lock);
    80000c0c:	00010517          	auipc	a0,0x10
    80000c10:	1f450513          	addi	a0,a0,500 # 80010e00 <page_ref>
    80000c14:	00000097          	auipc	ra,0x0
    80000c18:	1ea080e7          	jalr	490(ra) # 80000dfe <release>
  initlock(&kmem.lock, "kmem");
    80000c1c:	00007597          	auipc	a1,0x7
    80000c20:	48c58593          	addi	a1,a1,1164 # 800080a8 <digits+0x68>
    80000c24:	00010517          	auipc	a0,0x10
    80000c28:	1bc50513          	addi	a0,a0,444 # 80010de0 <kmem>
    80000c2c:	00000097          	auipc	ra,0x0
    80000c30:	08e080e7          	jalr	142(ra) # 80000cba <initlock>
  freerange(end, (void *)PHYSTOP);
    80000c34:	45c5                	li	a1,17
    80000c36:	05ee                	slli	a1,a1,0x1b
    80000c38:	00245517          	auipc	a0,0x245
    80000c3c:	99850513          	addi	a0,a0,-1640 # 802455d0 <end>
    80000c40:	00000097          	auipc	ra,0x0
    80000c44:	f26080e7          	jalr	-218(ra) # 80000b66 <freerange>
}
    80000c48:	60a2                	ld	ra,8(sp)
    80000c4a:	6402                	ld	s0,0(sp)
    80000c4c:	0141                	addi	sp,sp,16
    80000c4e:	8082                	ret

0000000080000c50 <kalloc>:
{
    80000c50:	1101                	addi	sp,sp,-32
    80000c52:	ec06                	sd	ra,24(sp)
    80000c54:	e822                	sd	s0,16(sp)
    80000c56:	e426                	sd	s1,8(sp)
    80000c58:	1000                	addi	s0,sp,32
  acquire(&kmem.lock);
    80000c5a:	00010497          	auipc	s1,0x10
    80000c5e:	18648493          	addi	s1,s1,390 # 80010de0 <kmem>
    80000c62:	8526                	mv	a0,s1
    80000c64:	00000097          	auipc	ra,0x0
    80000c68:	0e6080e7          	jalr	230(ra) # 80000d4a <acquire>
  r = kmem.freelist;
    80000c6c:	6c84                	ld	s1,24(s1)
  if (r)
    80000c6e:	cc8d                	beqz	s1,80000ca8 <kalloc+0x58>
    kmem.freelist = r->next;
    80000c70:	609c                	ld	a5,0(s1)
    80000c72:	00010517          	auipc	a0,0x10
    80000c76:	16e50513          	addi	a0,a0,366 # 80010de0 <kmem>
    80000c7a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	182080e7          	jalr	386(ra) # 80000dfe <release>
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000c84:	6605                	lui	a2,0x1
    80000c86:	4595                	li	a1,5
    80000c88:	8526                	mv	a0,s1
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	1bc080e7          	jalr	444(ra) # 80000e46 <memset>
    increase_pgreference((void *)r);
    80000c92:	8526                	mv	a0,s1
    80000c94:	00000097          	auipc	ra,0x0
    80000c98:	e68080e7          	jalr	-408(ra) # 80000afc <increase_pgreference>
}
    80000c9c:	8526                	mv	a0,s1
    80000c9e:	60e2                	ld	ra,24(sp)
    80000ca0:	6442                	ld	s0,16(sp)
    80000ca2:	64a2                	ld	s1,8(sp)
    80000ca4:	6105                	addi	sp,sp,32
    80000ca6:	8082                	ret
  release(&kmem.lock);
    80000ca8:	00010517          	auipc	a0,0x10
    80000cac:	13850513          	addi	a0,a0,312 # 80010de0 <kmem>
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	14e080e7          	jalr	334(ra) # 80000dfe <release>
  if (r)
    80000cb8:	b7d5                	j	80000c9c <kalloc+0x4c>

0000000080000cba <initlock>:
#include "riscv.h"
#include "proc.h"
#include "defs.h"

void initlock(struct spinlock *lk, char *name)
{
    80000cba:	1141                	addi	sp,sp,-16
    80000cbc:	e422                	sd	s0,8(sp)
    80000cbe:	0800                	addi	s0,sp,16
  lk->name = name;
    80000cc0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000cc2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000cc6:	00053823          	sd	zero,16(a0)
}
    80000cca:	6422                	ld	s0,8(sp)
    80000ccc:	0141                	addi	sp,sp,16
    80000cce:	8082                	ret

0000000080000cd0 <holding>:
// Check whether this cpu is holding the lock.
// Interrupts must be off.
int holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000cd0:	411c                	lw	a5,0(a0)
    80000cd2:	e399                	bnez	a5,80000cd8 <holding+0x8>
    80000cd4:	4501                	li	a0,0
  return r;
}
    80000cd6:	8082                	ret
{
    80000cd8:	1101                	addi	sp,sp,-32
    80000cda:	ec06                	sd	ra,24(sp)
    80000cdc:	e822                	sd	s0,16(sp)
    80000cde:	e426                	sd	s1,8(sp)
    80000ce0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ce2:	6904                	ld	s1,16(a0)
    80000ce4:	00001097          	auipc	ra,0x1
    80000ce8:	e7a080e7          	jalr	-390(ra) # 80001b5e <mycpu>
    80000cec:	40a48533          	sub	a0,s1,a0
    80000cf0:	00153513          	seqz	a0,a0
}
    80000cf4:	60e2                	ld	ra,24(sp)
    80000cf6:	6442                	ld	s0,16(sp)
    80000cf8:	64a2                	ld	s1,8(sp)
    80000cfa:	6105                	addi	sp,sp,32
    80000cfc:	8082                	ret

0000000080000cfe <push_off>:
// push_off/pop_off are like intr_off()/intr_on() except that they are matched:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void push_off(void)
{
    80000cfe:	1101                	addi	sp,sp,-32
    80000d00:	ec06                	sd	ra,24(sp)
    80000d02:	e822                	sd	s0,16(sp)
    80000d04:	e426                	sd	s1,8(sp)
    80000d06:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80000d08:	100024f3          	csrr	s1,sstatus
    80000d0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d10:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    80000d12:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if (mycpu()->noff == 0)
    80000d16:	00001097          	auipc	ra,0x1
    80000d1a:	e48080e7          	jalr	-440(ra) # 80001b5e <mycpu>
    80000d1e:	5d3c                	lw	a5,120(a0)
    80000d20:	cf89                	beqz	a5,80000d3a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d22:	00001097          	auipc	ra,0x1
    80000d26:	e3c080e7          	jalr	-452(ra) # 80001b5e <mycpu>
    80000d2a:	5d3c                	lw	a5,120(a0)
    80000d2c:	2785                	addiw	a5,a5,1
    80000d2e:	dd3c                	sw	a5,120(a0)
}
    80000d30:	60e2                	ld	ra,24(sp)
    80000d32:	6442                	ld	s0,16(sp)
    80000d34:	64a2                	ld	s1,8(sp)
    80000d36:	6105                	addi	sp,sp,32
    80000d38:	8082                	ret
    mycpu()->intena = old;
    80000d3a:	00001097          	auipc	ra,0x1
    80000d3e:	e24080e7          	jalr	-476(ra) # 80001b5e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d42:	8085                	srli	s1,s1,0x1
    80000d44:	8885                	andi	s1,s1,1
    80000d46:	dd64                	sw	s1,124(a0)
    80000d48:	bfe9                	j	80000d22 <push_off+0x24>

0000000080000d4a <acquire>:
{
    80000d4a:	1101                	addi	sp,sp,-32
    80000d4c:	ec06                	sd	ra,24(sp)
    80000d4e:	e822                	sd	s0,16(sp)
    80000d50:	e426                	sd	s1,8(sp)
    80000d52:	1000                	addi	s0,sp,32
    80000d54:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d56:	00000097          	auipc	ra,0x0
    80000d5a:	fa8080e7          	jalr	-88(ra) # 80000cfe <push_off>
  if (holding(lk))
    80000d5e:	8526                	mv	a0,s1
    80000d60:	00000097          	auipc	ra,0x0
    80000d64:	f70080e7          	jalr	-144(ra) # 80000cd0 <holding>
  while (__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d68:	4705                	li	a4,1
  if (holding(lk))
    80000d6a:	e115                	bnez	a0,80000d8e <acquire+0x44>
  while (__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d6c:	87ba                	mv	a5,a4
    80000d6e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d72:	2781                	sext.w	a5,a5
    80000d74:	ffe5                	bnez	a5,80000d6c <acquire+0x22>
  __sync_synchronize();
    80000d76:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d7a:	00001097          	auipc	ra,0x1
    80000d7e:	de4080e7          	jalr	-540(ra) # 80001b5e <mycpu>
    80000d82:	e888                	sd	a0,16(s1)
}
    80000d84:	60e2                	ld	ra,24(sp)
    80000d86:	6442                	ld	s0,16(sp)
    80000d88:	64a2                	ld	s1,8(sp)
    80000d8a:	6105                	addi	sp,sp,32
    80000d8c:	8082                	ret
    panic("acquire");
    80000d8e:	00007517          	auipc	a0,0x7
    80000d92:	32250513          	addi	a0,a0,802 # 800080b0 <digits+0x70>
    80000d96:	fffff097          	auipc	ra,0xfffff
    80000d9a:	7aa080e7          	jalr	1962(ra) # 80000540 <panic>

0000000080000d9e <pop_off>:

void pop_off(void)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e406                	sd	ra,8(sp)
    80000da2:	e022                	sd	s0,0(sp)
    80000da4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000da6:	00001097          	auipc	ra,0x1
    80000daa:	db8080e7          	jalr	-584(ra) # 80001b5e <mycpu>
  asm volatile("csrr %0, sstatus"
    80000dae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000db2:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000db4:	e78d                	bnez	a5,80000dde <pop_off+0x40>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000db6:	5d3c                	lw	a5,120(a0)
    80000db8:	02f05b63          	blez	a5,80000dee <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000dbc:	37fd                	addiw	a5,a5,-1
    80000dbe:	0007871b          	sext.w	a4,a5
    80000dc2:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000dc4:	eb09                	bnez	a4,80000dd6 <pop_off+0x38>
    80000dc6:	5d7c                	lw	a5,124(a0)
    80000dc8:	c799                	beqz	a5,80000dd6 <pop_off+0x38>
  asm volatile("csrr %0, sstatus"
    80000dca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000dce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80000dd2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000dd6:	60a2                	ld	ra,8(sp)
    80000dd8:	6402                	ld	s0,0(sp)
    80000dda:	0141                	addi	sp,sp,16
    80000ddc:	8082                	ret
    panic("pop_off - interruptible");
    80000dde:	00007517          	auipc	a0,0x7
    80000de2:	2da50513          	addi	a0,a0,730 # 800080b8 <digits+0x78>
    80000de6:	fffff097          	auipc	ra,0xfffff
    80000dea:	75a080e7          	jalr	1882(ra) # 80000540 <panic>
    panic("pop_off");
    80000dee:	00007517          	auipc	a0,0x7
    80000df2:	2e250513          	addi	a0,a0,738 # 800080d0 <digits+0x90>
    80000df6:	fffff097          	auipc	ra,0xfffff
    80000dfa:	74a080e7          	jalr	1866(ra) # 80000540 <panic>

0000000080000dfe <release>:
{
    80000dfe:	1101                	addi	sp,sp,-32
    80000e00:	ec06                	sd	ra,24(sp)
    80000e02:	e822                	sd	s0,16(sp)
    80000e04:	e426                	sd	s1,8(sp)
    80000e06:	1000                	addi	s0,sp,32
    80000e08:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000e0a:	00000097          	auipc	ra,0x0
    80000e0e:	ec6080e7          	jalr	-314(ra) # 80000cd0 <holding>
    80000e12:	c115                	beqz	a0,80000e36 <release+0x38>
  lk->cpu = 0;
    80000e14:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e18:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e1c:	0f50000f          	fence	iorw,ow
    80000e20:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e24:	00000097          	auipc	ra,0x0
    80000e28:	f7a080e7          	jalr	-134(ra) # 80000d9e <pop_off>
}
    80000e2c:	60e2                	ld	ra,24(sp)
    80000e2e:	6442                	ld	s0,16(sp)
    80000e30:	64a2                	ld	s1,8(sp)
    80000e32:	6105                	addi	sp,sp,32
    80000e34:	8082                	ret
    panic("release");
    80000e36:	00007517          	auipc	a0,0x7
    80000e3a:	2a250513          	addi	a0,a0,674 # 800080d8 <digits+0x98>
    80000e3e:	fffff097          	auipc	ra,0xfffff
    80000e42:	702080e7          	jalr	1794(ra) # 80000540 <panic>

0000000080000e46 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000e46:	1141                	addi	sp,sp,-16
    80000e48:	e422                	sd	s0,8(sp)
    80000e4a:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++)
    80000e4c:	ca19                	beqz	a2,80000e62 <memset+0x1c>
    80000e4e:	87aa                	mv	a5,a0
    80000e50:	1602                	slli	a2,a2,0x20
    80000e52:	9201                	srli	a2,a2,0x20
    80000e54:	00a60733          	add	a4,a2,a0
  {
    cdst[i] = c;
    80000e58:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++)
    80000e5c:	0785                	addi	a5,a5,1
    80000e5e:	fee79de3          	bne	a5,a4,80000e58 <memset+0x12>
  }
  return dst;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret

0000000080000e68 <memcmp>:

int memcmp(const void *v1, const void *v2, uint n)
{
    80000e68:	1141                	addi	sp,sp,-16
    80000e6a:	e422                	sd	s0,8(sp)
    80000e6c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0)
    80000e6e:	ca05                	beqz	a2,80000e9e <memcmp+0x36>
    80000e70:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000e74:	1682                	slli	a3,a3,0x20
    80000e76:	9281                	srli	a3,a3,0x20
    80000e78:	0685                	addi	a3,a3,1
    80000e7a:	96aa                	add	a3,a3,a0
  {
    if (*s1 != *s2)
    80000e7c:	00054783          	lbu	a5,0(a0)
    80000e80:	0005c703          	lbu	a4,0(a1)
    80000e84:	00e79863          	bne	a5,a4,80000e94 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e88:	0505                	addi	a0,a0,1
    80000e8a:	0585                	addi	a1,a1,1
  while (n-- > 0)
    80000e8c:	fed518e3          	bne	a0,a3,80000e7c <memcmp+0x14>
  }

  return 0;
    80000e90:	4501                	li	a0,0
    80000e92:	a019                	j	80000e98 <memcmp+0x30>
      return *s1 - *s2;
    80000e94:	40e7853b          	subw	a0,a5,a4
}
    80000e98:	6422                	ld	s0,8(sp)
    80000e9a:	0141                	addi	sp,sp,16
    80000e9c:	8082                	ret
  return 0;
    80000e9e:	4501                	li	a0,0
    80000ea0:	bfe5                	j	80000e98 <memcmp+0x30>

0000000080000ea2 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000ea2:	1141                	addi	sp,sp,-16
    80000ea4:	e422                	sd	s0,8(sp)
    80000ea6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000ea8:	c205                	beqz	a2,80000ec8 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d)
    80000eaa:	02a5e263          	bltu	a1,a0,80000ece <memmove+0x2c>
    d += n;
    while (n-- > 0)
      *--d = *--s;
  }
  else
    while (n-- > 0)
    80000eae:	1602                	slli	a2,a2,0x20
    80000eb0:	9201                	srli	a2,a2,0x20
    80000eb2:	00c587b3          	add	a5,a1,a2
{
    80000eb6:	872a                	mv	a4,a0
      *d++ = *s++;
    80000eb8:	0585                	addi	a1,a1,1
    80000eba:	0705                	addi	a4,a4,1
    80000ebc:	fff5c683          	lbu	a3,-1(a1)
    80000ec0:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000ec4:	fef59ae3          	bne	a1,a5,80000eb8 <memmove+0x16>

  return dst;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	addi	sp,sp,16
    80000ecc:	8082                	ret
  if (s < d && s + n > d)
    80000ece:	02061693          	slli	a3,a2,0x20
    80000ed2:	9281                	srli	a3,a3,0x20
    80000ed4:	00d58733          	add	a4,a1,a3
    80000ed8:	fce57be3          	bgeu	a0,a4,80000eae <memmove+0xc>
    d += n;
    80000edc:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000ede:	fff6079b          	addiw	a5,a2,-1
    80000ee2:	1782                	slli	a5,a5,0x20
    80000ee4:	9381                	srli	a5,a5,0x20
    80000ee6:	fff7c793          	not	a5,a5
    80000eea:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000eec:	177d                	addi	a4,a4,-1
    80000eee:	16fd                	addi	a3,a3,-1
    80000ef0:	00074603          	lbu	a2,0(a4)
    80000ef4:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000ef8:	fee79ae3          	bne	a5,a4,80000eec <memmove+0x4a>
    80000efc:	b7f1                	j	80000ec8 <memmove+0x26>

0000000080000efe <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000efe:	1141                	addi	sp,sp,-16
    80000f00:	e406                	sd	ra,8(sp)
    80000f02:	e022                	sd	s0,0(sp)
    80000f04:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f06:	00000097          	auipc	ra,0x0
    80000f0a:	f9c080e7          	jalr	-100(ra) # 80000ea2 <memmove>
}
    80000f0e:	60a2                	ld	ra,8(sp)
    80000f10:	6402                	ld	s0,0(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <strncmp>:

int strncmp(const char *p, const char *q, uint n)
{
    80000f16:	1141                	addi	sp,sp,-16
    80000f18:	e422                	sd	s0,8(sp)
    80000f1a:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000f1c:	ce11                	beqz	a2,80000f38 <strncmp+0x22>
    80000f1e:	00054783          	lbu	a5,0(a0)
    80000f22:	cf89                	beqz	a5,80000f3c <strncmp+0x26>
    80000f24:	0005c703          	lbu	a4,0(a1)
    80000f28:	00f71a63          	bne	a4,a5,80000f3c <strncmp+0x26>
    n--, p++, q++;
    80000f2c:	367d                	addiw	a2,a2,-1
    80000f2e:	0505                	addi	a0,a0,1
    80000f30:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000f32:	f675                	bnez	a2,80000f1e <strncmp+0x8>
  if (n == 0)
    return 0;
    80000f34:	4501                	li	a0,0
    80000f36:	a809                	j	80000f48 <strncmp+0x32>
    80000f38:	4501                	li	a0,0
    80000f3a:	a039                	j	80000f48 <strncmp+0x32>
  if (n == 0)
    80000f3c:	ca09                	beqz	a2,80000f4e <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f3e:	00054503          	lbu	a0,0(a0)
    80000f42:	0005c783          	lbu	a5,0(a1)
    80000f46:	9d1d                	subw	a0,a0,a5
}
    80000f48:	6422                	ld	s0,8(sp)
    80000f4a:	0141                	addi	sp,sp,16
    80000f4c:	8082                	ret
    return 0;
    80000f4e:	4501                	li	a0,0
    80000f50:	bfe5                	j	80000f48 <strncmp+0x32>

0000000080000f52 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000f52:	1141                	addi	sp,sp,-16
    80000f54:	e422                	sd	s0,8(sp)
    80000f56:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000f58:	872a                	mv	a4,a0
    80000f5a:	8832                	mv	a6,a2
    80000f5c:	367d                	addiw	a2,a2,-1
    80000f5e:	01005963          	blez	a6,80000f70 <strncpy+0x1e>
    80000f62:	0705                	addi	a4,a4,1
    80000f64:	0005c783          	lbu	a5,0(a1)
    80000f68:	fef70fa3          	sb	a5,-1(a4)
    80000f6c:	0585                	addi	a1,a1,1
    80000f6e:	f7f5                	bnez	a5,80000f5a <strncpy+0x8>
    ;
  while (n-- > 0)
    80000f70:	86ba                	mv	a3,a4
    80000f72:	00c05c63          	blez	a2,80000f8a <strncpy+0x38>
    *s++ = 0;
    80000f76:	0685                	addi	a3,a3,1
    80000f78:	fe068fa3          	sb	zero,-1(a3)
  while (n-- > 0)
    80000f7c:	40d707bb          	subw	a5,a4,a3
    80000f80:	37fd                	addiw	a5,a5,-1
    80000f82:	010787bb          	addw	a5,a5,a6
    80000f86:	fef048e3          	bgtz	a5,80000f76 <strncpy+0x24>
  return os;
}
    80000f8a:	6422                	ld	s0,8(sp)
    80000f8c:	0141                	addi	sp,sp,16
    80000f8e:	8082                	ret

0000000080000f90 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000f90:	1141                	addi	sp,sp,-16
    80000f92:	e422                	sd	s0,8(sp)
    80000f94:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000f96:	02c05363          	blez	a2,80000fbc <safestrcpy+0x2c>
    80000f9a:	fff6069b          	addiw	a3,a2,-1
    80000f9e:	1682                	slli	a3,a3,0x20
    80000fa0:	9281                	srli	a3,a3,0x20
    80000fa2:	96ae                	add	a3,a3,a1
    80000fa4:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000fa6:	00d58963          	beq	a1,a3,80000fb8 <safestrcpy+0x28>
    80000faa:	0585                	addi	a1,a1,1
    80000fac:	0785                	addi	a5,a5,1
    80000fae:	fff5c703          	lbu	a4,-1(a1)
    80000fb2:	fee78fa3          	sb	a4,-1(a5)
    80000fb6:	fb65                	bnez	a4,80000fa6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000fb8:	00078023          	sb	zero,0(a5)
  return os;
}
    80000fbc:	6422                	ld	s0,8(sp)
    80000fbe:	0141                	addi	sp,sp,16
    80000fc0:	8082                	ret

0000000080000fc2 <strlen>:

int strlen(const char *s)
{
    80000fc2:	1141                	addi	sp,sp,-16
    80000fc4:	e422                	sd	s0,8(sp)
    80000fc6:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000fc8:	00054783          	lbu	a5,0(a0)
    80000fcc:	cf91                	beqz	a5,80000fe8 <strlen+0x26>
    80000fce:	0505                	addi	a0,a0,1
    80000fd0:	87aa                	mv	a5,a0
    80000fd2:	4685                	li	a3,1
    80000fd4:	9e89                	subw	a3,a3,a0
    80000fd6:	00f6853b          	addw	a0,a3,a5
    80000fda:	0785                	addi	a5,a5,1
    80000fdc:	fff7c703          	lbu	a4,-1(a5)
    80000fe0:	fb7d                	bnez	a4,80000fd6 <strlen+0x14>
    ;
  return n;
}
    80000fe2:	6422                	ld	s0,8(sp)
    80000fe4:	0141                	addi	sp,sp,16
    80000fe6:	8082                	ret
  for (n = 0; s[n]; n++)
    80000fe8:	4501                	li	a0,0
    80000fea:	bfe5                	j	80000fe2 <strlen+0x20>

0000000080000fec <main>:

volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void main()
{
    80000fec:	1141                	addi	sp,sp,-16
    80000fee:	e406                	sd	ra,8(sp)
    80000ff0:	e022                	sd	s0,0(sp)
    80000ff2:	0800                	addi	s0,sp,16
  if (cpuid() == 0)
    80000ff4:	00001097          	auipc	ra,0x1
    80000ff8:	b5a080e7          	jalr	-1190(ra) # 80001b4e <cpuid>
    __sync_synchronize();
    started = 1;
  }
  else
  {
    while (started == 0)
    80000ffc:	00008717          	auipc	a4,0x8
    80001000:	b7c70713          	addi	a4,a4,-1156 # 80008b78 <started>
  if (cpuid() == 0)
    80001004:	c139                	beqz	a0,8000104a <main+0x5e>
    while (started == 0)
    80001006:	431c                	lw	a5,0(a4)
    80001008:	2781                	sext.w	a5,a5
    8000100a:	dff5                	beqz	a5,80001006 <main+0x1a>
      ;
    __sync_synchronize();
    8000100c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001010:	00001097          	auipc	ra,0x1
    80001014:	b3e080e7          	jalr	-1218(ra) # 80001b4e <cpuid>
    80001018:	85aa                	mv	a1,a0
    8000101a:	00007517          	auipc	a0,0x7
    8000101e:	0de50513          	addi	a0,a0,222 # 800080f8 <digits+0xb8>
    80001022:	fffff097          	auipc	ra,0xfffff
    80001026:	568080e7          	jalr	1384(ra) # 8000058a <printf>
    kvminithart();  // turn on paging
    8000102a:	00000097          	auipc	ra,0x0
    8000102e:	0d8080e7          	jalr	216(ra) # 80001102 <kvminithart>
    trapinithart(); // install kernel trap vector
    80001032:	00002097          	auipc	ra,0x2
    80001036:	b02080e7          	jalr	-1278(ra) # 80002b34 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    8000103a:	00005097          	auipc	ra,0x5
    8000103e:	466080e7          	jalr	1126(ra) # 800064a0 <plicinithart>
  }

  scheduler();
    80001042:	00001097          	auipc	ra,0x1
    80001046:	138080e7          	jalr	312(ra) # 8000217a <scheduler>
    consoleinit();
    8000104a:	fffff097          	auipc	ra,0xfffff
    8000104e:	406080e7          	jalr	1030(ra) # 80000450 <consoleinit>
    printfinit();
    80001052:	fffff097          	auipc	ra,0xfffff
    80001056:	718080e7          	jalr	1816(ra) # 8000076a <printfinit>
    printf("\n");
    8000105a:	00007517          	auipc	a0,0x7
    8000105e:	0ae50513          	addi	a0,a0,174 # 80008108 <digits+0xc8>
    80001062:	fffff097          	auipc	ra,0xfffff
    80001066:	528080e7          	jalr	1320(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    8000106a:	00007517          	auipc	a0,0x7
    8000106e:	07650513          	addi	a0,a0,118 # 800080e0 <digits+0xa0>
    80001072:	fffff097          	auipc	ra,0xfffff
    80001076:	518080e7          	jalr	1304(ra) # 8000058a <printf>
    printf("\n");
    8000107a:	00007517          	auipc	a0,0x7
    8000107e:	08e50513          	addi	a0,a0,142 # 80008108 <digits+0xc8>
    80001082:	fffff097          	auipc	ra,0xfffff
    80001086:	508080e7          	jalr	1288(ra) # 8000058a <printf>
    kinit();            // physical page allocator
    8000108a:	00000097          	auipc	ra,0x0
    8000108e:	b38080e7          	jalr	-1224(ra) # 80000bc2 <kinit>
    kvminit();          // create kernel page table
    80001092:	00000097          	auipc	ra,0x0
    80001096:	326080e7          	jalr	806(ra) # 800013b8 <kvminit>
    kvminithart();      // turn on paging
    8000109a:	00000097          	auipc	ra,0x0
    8000109e:	068080e7          	jalr	104(ra) # 80001102 <kvminithart>
    procinit();         // process table
    800010a2:	00001097          	auipc	ra,0x1
    800010a6:	9f8080e7          	jalr	-1544(ra) # 80001a9a <procinit>
    trapinit();         // trap vectors
    800010aa:	00002097          	auipc	ra,0x2
    800010ae:	a62080e7          	jalr	-1438(ra) # 80002b0c <trapinit>
    trapinithart();     // install kernel trap vector
    800010b2:	00002097          	auipc	ra,0x2
    800010b6:	a82080e7          	jalr	-1406(ra) # 80002b34 <trapinithart>
    plicinit();         // set up interrupt controller
    800010ba:	00005097          	auipc	ra,0x5
    800010be:	3d0080e7          	jalr	976(ra) # 8000648a <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    800010c2:	00005097          	auipc	ra,0x5
    800010c6:	3de080e7          	jalr	990(ra) # 800064a0 <plicinithart>
    binit();            // buffer cache
    800010ca:	00002097          	auipc	ra,0x2
    800010ce:	57a080e7          	jalr	1402(ra) # 80003644 <binit>
    iinit();            // inode table
    800010d2:	00003097          	auipc	ra,0x3
    800010d6:	c1a080e7          	jalr	-998(ra) # 80003cec <iinit>
    fileinit();         // file table
    800010da:	00004097          	auipc	ra,0x4
    800010de:	bc0080e7          	jalr	-1088(ra) # 80004c9a <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010e2:	00005097          	auipc	ra,0x5
    800010e6:	79a080e7          	jalr	1946(ra) # 8000687c <virtio_disk_init>
    userinit();         // first user process
    800010ea:	00001097          	auipc	ra,0x1
    800010ee:	dfc080e7          	jalr	-516(ra) # 80001ee6 <userinit>
    __sync_synchronize();
    800010f2:	0ff0000f          	fence
    started = 1;
    800010f6:	4785                	li	a5,1
    800010f8:	00008717          	auipc	a4,0x8
    800010fc:	a8f72023          	sw	a5,-1408(a4) # 80008b78 <started>
    80001100:	b789                	j	80001042 <main+0x56>

0000000080001102 <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    80001102:	1141                	addi	sp,sp,-16
    80001104:	e422                	sd	s0,8(sp)
    80001106:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001108:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000110c:	00008797          	auipc	a5,0x8
    80001110:	a747b783          	ld	a5,-1420(a5) # 80008b80 <kernel_pagetable>
    80001114:	83b1                	srli	a5,a5,0xc
    80001116:	577d                	li	a4,-1
    80001118:	177e                	slli	a4,a4,0x3f
    8000111a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0"
    8000111c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001120:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001124:	6422                	ld	s0,8(sp)
    80001126:	0141                	addi	sp,sp,16
    80001128:	8082                	ret

000000008000112a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000112a:	7139                	addi	sp,sp,-64
    8000112c:	fc06                	sd	ra,56(sp)
    8000112e:	f822                	sd	s0,48(sp)
    80001130:	f426                	sd	s1,40(sp)
    80001132:	f04a                	sd	s2,32(sp)
    80001134:	ec4e                	sd	s3,24(sp)
    80001136:	e852                	sd	s4,16(sp)
    80001138:	e456                	sd	s5,8(sp)
    8000113a:	e05a                	sd	s6,0(sp)
    8000113c:	0080                	addi	s0,sp,64
    8000113e:	84aa                	mv	s1,a0
    80001140:	89ae                	mv	s3,a1
    80001142:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80001144:	57fd                	li	a5,-1
    80001146:	83e9                	srli	a5,a5,0x1a
    80001148:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--)
    8000114a:	4b31                	li	s6,12
  if (va >= MAXVA)
    8000114c:	04b7f263          	bgeu	a5,a1,80001190 <walk+0x66>
    panic("walk");
    80001150:	00007517          	auipc	a0,0x7
    80001154:	fc050513          	addi	a0,a0,-64 # 80008110 <digits+0xd0>
    80001158:	fffff097          	auipc	ra,0xfffff
    8000115c:	3e8080e7          	jalr	1000(ra) # 80000540 <panic>
    {
      pagetable = (pagetable_t)PTE2PA(*pte);
    }
    else
    {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80001160:	060a8663          	beqz	s5,800011cc <walk+0xa2>
    80001164:	00000097          	auipc	ra,0x0
    80001168:	aec080e7          	jalr	-1300(ra) # 80000c50 <kalloc>
    8000116c:	84aa                	mv	s1,a0
    8000116e:	c529                	beqz	a0,800011b8 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001170:	6605                	lui	a2,0x1
    80001172:	4581                	li	a1,0
    80001174:	00000097          	auipc	ra,0x0
    80001178:	cd2080e7          	jalr	-814(ra) # 80000e46 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000117c:	00c4d793          	srli	a5,s1,0xc
    80001180:	07aa                	slli	a5,a5,0xa
    80001182:	0017e793          	ori	a5,a5,1
    80001186:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--)
    8000118a:	3a5d                	addiw	s4,s4,-9 # ff7 <_entry-0x7ffff009>
    8000118c:	036a0063          	beq	s4,s6,800011ac <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001190:	0149d933          	srl	s2,s3,s4
    80001194:	1ff97913          	andi	s2,s2,511
    80001198:	090e                	slli	s2,s2,0x3
    8000119a:	9926                	add	s2,s2,s1
    if (*pte & PTE_V)
    8000119c:	00093483          	ld	s1,0(s2)
    800011a0:	0014f793          	andi	a5,s1,1
    800011a4:	dfd5                	beqz	a5,80001160 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011a6:	80a9                	srli	s1,s1,0xa
    800011a8:	04b2                	slli	s1,s1,0xc
    800011aa:	b7c5                	j	8000118a <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800011ac:	00c9d513          	srli	a0,s3,0xc
    800011b0:	1ff57513          	andi	a0,a0,511
    800011b4:	050e                	slli	a0,a0,0x3
    800011b6:	9526                	add	a0,a0,s1
}
    800011b8:	70e2                	ld	ra,56(sp)
    800011ba:	7442                	ld	s0,48(sp)
    800011bc:	74a2                	ld	s1,40(sp)
    800011be:	7902                	ld	s2,32(sp)
    800011c0:	69e2                	ld	s3,24(sp)
    800011c2:	6a42                	ld	s4,16(sp)
    800011c4:	6aa2                	ld	s5,8(sp)
    800011c6:	6b02                	ld	s6,0(sp)
    800011c8:	6121                	addi	sp,sp,64
    800011ca:	8082                	ret
        return 0;
    800011cc:	4501                	li	a0,0
    800011ce:	b7ed                	j	800011b8 <walk+0x8e>

00000000800011d0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    800011d0:	57fd                	li	a5,-1
    800011d2:	83e9                	srli	a5,a5,0x1a
    800011d4:	00b7f463          	bgeu	a5,a1,800011dc <walkaddr+0xc>
    return 0;
    800011d8:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800011da:	8082                	ret
{
    800011dc:	1141                	addi	sp,sp,-16
    800011de:	e406                	sd	ra,8(sp)
    800011e0:	e022                	sd	s0,0(sp)
    800011e2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011e4:	4601                	li	a2,0
    800011e6:	00000097          	auipc	ra,0x0
    800011ea:	f44080e7          	jalr	-188(ra) # 8000112a <walk>
  if (pte == 0)
    800011ee:	c105                	beqz	a0,8000120e <walkaddr+0x3e>
  if ((*pte & PTE_V) == 0)
    800011f0:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    800011f2:	0117f693          	andi	a3,a5,17
    800011f6:	4745                	li	a4,17
    return 0;
    800011f8:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    800011fa:	00e68663          	beq	a3,a4,80001206 <walkaddr+0x36>
}
    800011fe:	60a2                	ld	ra,8(sp)
    80001200:	6402                	ld	s0,0(sp)
    80001202:	0141                	addi	sp,sp,16
    80001204:	8082                	ret
  pa = PTE2PA(*pte);
    80001206:	83a9                	srli	a5,a5,0xa
    80001208:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000120c:	bfcd                	j	800011fe <walkaddr+0x2e>
    return 0;
    8000120e:	4501                	li	a0,0
    80001210:	b7fd                	j	800011fe <walkaddr+0x2e>

0000000080001212 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001212:	715d                	addi	sp,sp,-80
    80001214:	e486                	sd	ra,72(sp)
    80001216:	e0a2                	sd	s0,64(sp)
    80001218:	fc26                	sd	s1,56(sp)
    8000121a:	f84a                	sd	s2,48(sp)
    8000121c:	f44e                	sd	s3,40(sp)
    8000121e:	f052                	sd	s4,32(sp)
    80001220:	ec56                	sd	s5,24(sp)
    80001222:	e85a                	sd	s6,16(sp)
    80001224:	e45e                	sd	s7,8(sp)
    80001226:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if (size == 0)
    80001228:	c639                	beqz	a2,80001276 <mappages+0x64>
    8000122a:	8aaa                	mv	s5,a0
    8000122c:	8b3a                	mv	s6,a4
    panic("mappages: size");

  a = PGROUNDDOWN(va);
    8000122e:	777d                	lui	a4,0xfffff
    80001230:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001234:	fff58993          	addi	s3,a1,-1
    80001238:	99b2                	add	s3,s3,a2
    8000123a:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000123e:	893e                	mv	s2,a5
    80001240:	40f68a33          	sub	s4,a3,a5
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80001244:	6b85                	lui	s7,0x1
    80001246:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000124a:	4605                	li	a2,1
    8000124c:	85ca                	mv	a1,s2
    8000124e:	8556                	mv	a0,s5
    80001250:	00000097          	auipc	ra,0x0
    80001254:	eda080e7          	jalr	-294(ra) # 8000112a <walk>
    80001258:	cd1d                	beqz	a0,80001296 <mappages+0x84>
    if (*pte & PTE_V)
    8000125a:	611c                	ld	a5,0(a0)
    8000125c:	8b85                	andi	a5,a5,1
    8000125e:	e785                	bnez	a5,80001286 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001260:	80b1                	srli	s1,s1,0xc
    80001262:	04aa                	slli	s1,s1,0xa
    80001264:	0164e4b3          	or	s1,s1,s6
    80001268:	0014e493          	ori	s1,s1,1
    8000126c:	e104                	sd	s1,0(a0)
    if (a == last)
    8000126e:	05390063          	beq	s2,s3,800012ae <mappages+0x9c>
    a += PGSIZE;
    80001272:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001274:	bfc9                	j	80001246 <mappages+0x34>
    panic("mappages: size");
    80001276:	00007517          	auipc	a0,0x7
    8000127a:	ea250513          	addi	a0,a0,-350 # 80008118 <digits+0xd8>
    8000127e:	fffff097          	auipc	ra,0xfffff
    80001282:	2c2080e7          	jalr	706(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001286:	00007517          	auipc	a0,0x7
    8000128a:	ea250513          	addi	a0,a0,-350 # 80008128 <digits+0xe8>
    8000128e:	fffff097          	auipc	ra,0xfffff
    80001292:	2b2080e7          	jalr	690(ra) # 80000540 <panic>
      return -1;
    80001296:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001298:	60a6                	ld	ra,72(sp)
    8000129a:	6406                	ld	s0,64(sp)
    8000129c:	74e2                	ld	s1,56(sp)
    8000129e:	7942                	ld	s2,48(sp)
    800012a0:	79a2                	ld	s3,40(sp)
    800012a2:	7a02                	ld	s4,32(sp)
    800012a4:	6ae2                	ld	s5,24(sp)
    800012a6:	6b42                	ld	s6,16(sp)
    800012a8:	6ba2                	ld	s7,8(sp)
    800012aa:	6161                	addi	sp,sp,80
    800012ac:	8082                	ret
  return 0;
    800012ae:	4501                	li	a0,0
    800012b0:	b7e5                	j	80001298 <mappages+0x86>

00000000800012b2 <kvmmap>:
{
    800012b2:	1141                	addi	sp,sp,-16
    800012b4:	e406                	sd	ra,8(sp)
    800012b6:	e022                	sd	s0,0(sp)
    800012b8:	0800                	addi	s0,sp,16
    800012ba:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    800012bc:	86b2                	mv	a3,a2
    800012be:	863e                	mv	a2,a5
    800012c0:	00000097          	auipc	ra,0x0
    800012c4:	f52080e7          	jalr	-174(ra) # 80001212 <mappages>
    800012c8:	e509                	bnez	a0,800012d2 <kvmmap+0x20>
}
    800012ca:	60a2                	ld	ra,8(sp)
    800012cc:	6402                	ld	s0,0(sp)
    800012ce:	0141                	addi	sp,sp,16
    800012d0:	8082                	ret
    panic("kvmmap");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	e6650513          	addi	a0,a0,-410 # 80008138 <digits+0xf8>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	266080e7          	jalr	614(ra) # 80000540 <panic>

00000000800012e2 <kvmmake>:
{
    800012e2:	1101                	addi	sp,sp,-32
    800012e4:	ec06                	sd	ra,24(sp)
    800012e6:	e822                	sd	s0,16(sp)
    800012e8:	e426                	sd	s1,8(sp)
    800012ea:	e04a                	sd	s2,0(sp)
    800012ec:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    800012ee:	00000097          	auipc	ra,0x0
    800012f2:	962080e7          	jalr	-1694(ra) # 80000c50 <kalloc>
    800012f6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012f8:	6605                	lui	a2,0x1
    800012fa:	4581                	li	a1,0
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	b4a080e7          	jalr	-1206(ra) # 80000e46 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001304:	4719                	li	a4,6
    80001306:	6685                	lui	a3,0x1
    80001308:	10000637          	lui	a2,0x10000
    8000130c:	100005b7          	lui	a1,0x10000
    80001310:	8526                	mv	a0,s1
    80001312:	00000097          	auipc	ra,0x0
    80001316:	fa0080e7          	jalr	-96(ra) # 800012b2 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000131a:	4719                	li	a4,6
    8000131c:	6685                	lui	a3,0x1
    8000131e:	10001637          	lui	a2,0x10001
    80001322:	100015b7          	lui	a1,0x10001
    80001326:	8526                	mv	a0,s1
    80001328:	00000097          	auipc	ra,0x0
    8000132c:	f8a080e7          	jalr	-118(ra) # 800012b2 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001330:	4719                	li	a4,6
    80001332:	004006b7          	lui	a3,0x400
    80001336:	0c000637          	lui	a2,0xc000
    8000133a:	0c0005b7          	lui	a1,0xc000
    8000133e:	8526                	mv	a0,s1
    80001340:	00000097          	auipc	ra,0x0
    80001344:	f72080e7          	jalr	-142(ra) # 800012b2 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    80001348:	00007917          	auipc	s2,0x7
    8000134c:	cb890913          	addi	s2,s2,-840 # 80008000 <etext>
    80001350:	4729                	li	a4,10
    80001352:	80007697          	auipc	a3,0x80007
    80001356:	cae68693          	addi	a3,a3,-850 # 8000 <_entry-0x7fff8000>
    8000135a:	4605                	li	a2,1
    8000135c:	067e                	slli	a2,a2,0x1f
    8000135e:	85b2                	mv	a1,a2
    80001360:	8526                	mv	a0,s1
    80001362:	00000097          	auipc	ra,0x0
    80001366:	f50080e7          	jalr	-176(ra) # 800012b2 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    8000136a:	4719                	li	a4,6
    8000136c:	46c5                	li	a3,17
    8000136e:	06ee                	slli	a3,a3,0x1b
    80001370:	412686b3          	sub	a3,a3,s2
    80001374:	864a                	mv	a2,s2
    80001376:	85ca                	mv	a1,s2
    80001378:	8526                	mv	a0,s1
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	f38080e7          	jalr	-200(ra) # 800012b2 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001382:	4729                	li	a4,10
    80001384:	6685                	lui	a3,0x1
    80001386:	00006617          	auipc	a2,0x6
    8000138a:	c7a60613          	addi	a2,a2,-902 # 80007000 <_trampoline>
    8000138e:	040005b7          	lui	a1,0x4000
    80001392:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001394:	05b2                	slli	a1,a1,0xc
    80001396:	8526                	mv	a0,s1
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	f1a080e7          	jalr	-230(ra) # 800012b2 <kvmmap>
  proc_mapstacks(kpgtbl);
    800013a0:	8526                	mv	a0,s1
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	662080e7          	jalr	1634(ra) # 80001a04 <proc_mapstacks>
}
    800013aa:	8526                	mv	a0,s1
    800013ac:	60e2                	ld	ra,24(sp)
    800013ae:	6442                	ld	s0,16(sp)
    800013b0:	64a2                	ld	s1,8(sp)
    800013b2:	6902                	ld	s2,0(sp)
    800013b4:	6105                	addi	sp,sp,32
    800013b6:	8082                	ret

00000000800013b8 <kvminit>:
{
    800013b8:	1141                	addi	sp,sp,-16
    800013ba:	e406                	sd	ra,8(sp)
    800013bc:	e022                	sd	s0,0(sp)
    800013be:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	f22080e7          	jalr	-222(ra) # 800012e2 <kvmmake>
    800013c8:	00007797          	auipc	a5,0x7
    800013cc:	7aa7bc23          	sd	a0,1976(a5) # 80008b80 <kernel_pagetable>
}
    800013d0:	60a2                	ld	ra,8(sp)
    800013d2:	6402                	ld	s0,0(sp)
    800013d4:	0141                	addi	sp,sp,16
    800013d6:	8082                	ret

00000000800013d8 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013d8:	715d                	addi	sp,sp,-80
    800013da:	e486                	sd	ra,72(sp)
    800013dc:	e0a2                	sd	s0,64(sp)
    800013de:	fc26                	sd	s1,56(sp)
    800013e0:	f84a                	sd	s2,48(sp)
    800013e2:	f44e                	sd	s3,40(sp)
    800013e4:	f052                	sd	s4,32(sp)
    800013e6:	ec56                	sd	s5,24(sp)
    800013e8:	e85a                	sd	s6,16(sp)
    800013ea:	e45e                	sd	s7,8(sp)
    800013ec:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800013ee:	03459793          	slli	a5,a1,0x34
    800013f2:	e795                	bnez	a5,8000141e <uvmunmap+0x46>
    800013f4:	8a2a                	mv	s4,a0
    800013f6:	892e                	mv	s2,a1
    800013f8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    800013fa:	0632                	slli	a2,a2,0xc
    800013fc:	00b609b3          	add	s3,a2,a1
  {
    if ((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if ((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if (PTE_FLAGS(*pte) == PTE_V)
    80001400:	4b85                	li	s7,1
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001402:	6b05                	lui	s6,0x1
    80001404:	0735e263          	bltu	a1,s3,80001468 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
  }
}
    80001408:	60a6                	ld	ra,72(sp)
    8000140a:	6406                	ld	s0,64(sp)
    8000140c:	74e2                	ld	s1,56(sp)
    8000140e:	7942                	ld	s2,48(sp)
    80001410:	79a2                	ld	s3,40(sp)
    80001412:	7a02                	ld	s4,32(sp)
    80001414:	6ae2                	ld	s5,24(sp)
    80001416:	6b42                	ld	s6,16(sp)
    80001418:	6ba2                	ld	s7,8(sp)
    8000141a:	6161                	addi	sp,sp,80
    8000141c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000141e:	00007517          	auipc	a0,0x7
    80001422:	d2250513          	addi	a0,a0,-734 # 80008140 <digits+0x100>
    80001426:	fffff097          	auipc	ra,0xfffff
    8000142a:	11a080e7          	jalr	282(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    8000142e:	00007517          	auipc	a0,0x7
    80001432:	d2a50513          	addi	a0,a0,-726 # 80008158 <digits+0x118>
    80001436:	fffff097          	auipc	ra,0xfffff
    8000143a:	10a080e7          	jalr	266(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    8000143e:	00007517          	auipc	a0,0x7
    80001442:	d2a50513          	addi	a0,a0,-726 # 80008168 <digits+0x128>
    80001446:	fffff097          	auipc	ra,0xfffff
    8000144a:	0fa080e7          	jalr	250(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    8000144e:	00007517          	auipc	a0,0x7
    80001452:	d3250513          	addi	a0,a0,-718 # 80008180 <digits+0x140>
    80001456:	fffff097          	auipc	ra,0xfffff
    8000145a:	0ea080e7          	jalr	234(ra) # 80000540 <panic>
    *pte = 0;
    8000145e:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001462:	995a                	add	s2,s2,s6
    80001464:	fb3972e3          	bgeu	s2,s3,80001408 <uvmunmap+0x30>
    if ((pte = walk(pagetable, a, 0)) == 0)
    80001468:	4601                	li	a2,0
    8000146a:	85ca                	mv	a1,s2
    8000146c:	8552                	mv	a0,s4
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	cbc080e7          	jalr	-836(ra) # 8000112a <walk>
    80001476:	84aa                	mv	s1,a0
    80001478:	d95d                	beqz	a0,8000142e <uvmunmap+0x56>
    if ((*pte & PTE_V) == 0)
    8000147a:	6108                	ld	a0,0(a0)
    8000147c:	00157793          	andi	a5,a0,1
    80001480:	dfdd                	beqz	a5,8000143e <uvmunmap+0x66>
    if (PTE_FLAGS(*pte) == PTE_V)
    80001482:	3ff57793          	andi	a5,a0,1023
    80001486:	fd7784e3          	beq	a5,s7,8000144e <uvmunmap+0x76>
    if (do_free)
    8000148a:	fc0a8ae3          	beqz	s5,8000145e <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000148e:	8129                	srli	a0,a0,0xa
      kfree((void *)pa);
    80001490:	0532                	slli	a0,a0,0xc
    80001492:	fffff097          	auipc	ra,0xfffff
    80001496:	5e6080e7          	jalr	1510(ra) # 80000a78 <kfree>
    8000149a:	b7d1                	j	8000145e <uvmunmap+0x86>

000000008000149c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000149c:	1101                	addi	sp,sp,-32
    8000149e:	ec06                	sd	ra,24(sp)
    800014a0:	e822                	sd	s0,16(sp)
    800014a2:	e426                	sd	s1,8(sp)
    800014a4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    800014a6:	fffff097          	auipc	ra,0xfffff
    800014aa:	7aa080e7          	jalr	1962(ra) # 80000c50 <kalloc>
    800014ae:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800014b0:	c519                	beqz	a0,800014be <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800014b2:	6605                	lui	a2,0x1
    800014b4:	4581                	li	a1,0
    800014b6:	00000097          	auipc	ra,0x0
    800014ba:	990080e7          	jalr	-1648(ra) # 80000e46 <memset>
  return pagetable;
}
    800014be:	8526                	mv	a0,s1
    800014c0:	60e2                	ld	ra,24(sp)
    800014c2:	6442                	ld	s0,16(sp)
    800014c4:	64a2                	ld	s1,8(sp)
    800014c6:	6105                	addi	sp,sp,32
    800014c8:	8082                	ret

00000000800014ca <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800014ca:	7179                	addi	sp,sp,-48
    800014cc:	f406                	sd	ra,40(sp)
    800014ce:	f022                	sd	s0,32(sp)
    800014d0:	ec26                	sd	s1,24(sp)
    800014d2:	e84a                	sd	s2,16(sp)
    800014d4:	e44e                	sd	s3,8(sp)
    800014d6:	e052                	sd	s4,0(sp)
    800014d8:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    800014da:	6785                	lui	a5,0x1
    800014dc:	04f67863          	bgeu	a2,a5,8000152c <uvmfirst+0x62>
    800014e0:	8a2a                	mv	s4,a0
    800014e2:	89ae                	mv	s3,a1
    800014e4:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800014e6:	fffff097          	auipc	ra,0xfffff
    800014ea:	76a080e7          	jalr	1898(ra) # 80000c50 <kalloc>
    800014ee:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014f0:	6605                	lui	a2,0x1
    800014f2:	4581                	li	a1,0
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	952080e7          	jalr	-1710(ra) # 80000e46 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    800014fc:	4779                	li	a4,30
    800014fe:	86ca                	mv	a3,s2
    80001500:	6605                	lui	a2,0x1
    80001502:	4581                	li	a1,0
    80001504:	8552                	mv	a0,s4
    80001506:	00000097          	auipc	ra,0x0
    8000150a:	d0c080e7          	jalr	-756(ra) # 80001212 <mappages>
  memmove(mem, src, sz);
    8000150e:	8626                	mv	a2,s1
    80001510:	85ce                	mv	a1,s3
    80001512:	854a                	mv	a0,s2
    80001514:	00000097          	auipc	ra,0x0
    80001518:	98e080e7          	jalr	-1650(ra) # 80000ea2 <memmove>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret
    panic("uvmfirst: more than a page");
    8000152c:	00007517          	auipc	a0,0x7
    80001530:	c6c50513          	addi	a0,a0,-916 # 80008198 <digits+0x158>
    80001534:	fffff097          	auipc	ra,0xfffff
    80001538:	00c080e7          	jalr	12(ra) # 80000540 <panic>

000000008000153c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000153c:	1101                	addi	sp,sp,-32
    8000153e:	ec06                	sd	ra,24(sp)
    80001540:	e822                	sd	s0,16(sp)
    80001542:	e426                	sd	s1,8(sp)
    80001544:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001546:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001548:	00b67d63          	bgeu	a2,a1,80001562 <uvmdealloc+0x26>
    8000154c:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    8000154e:	6785                	lui	a5,0x1
    80001550:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001552:	00f60733          	add	a4,a2,a5
    80001556:	76fd                	lui	a3,0xfffff
    80001558:	8f75                	and	a4,a4,a3
    8000155a:	97ae                	add	a5,a5,a1
    8000155c:	8ff5                	and	a5,a5,a3
    8000155e:	00f76863          	bltu	a4,a5,8000156e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001562:	8526                	mv	a0,s1
    80001564:	60e2                	ld	ra,24(sp)
    80001566:	6442                	ld	s0,16(sp)
    80001568:	64a2                	ld	s1,8(sp)
    8000156a:	6105                	addi	sp,sp,32
    8000156c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000156e:	8f99                	sub	a5,a5,a4
    80001570:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001572:	4685                	li	a3,1
    80001574:	0007861b          	sext.w	a2,a5
    80001578:	85ba                	mv	a1,a4
    8000157a:	00000097          	auipc	ra,0x0
    8000157e:	e5e080e7          	jalr	-418(ra) # 800013d8 <uvmunmap>
    80001582:	b7c5                	j	80001562 <uvmdealloc+0x26>

0000000080001584 <uvmalloc>:
  if (newsz < oldsz)
    80001584:	0ab66563          	bltu	a2,a1,8000162e <uvmalloc+0xaa>
{
    80001588:	7139                	addi	sp,sp,-64
    8000158a:	fc06                	sd	ra,56(sp)
    8000158c:	f822                	sd	s0,48(sp)
    8000158e:	f426                	sd	s1,40(sp)
    80001590:	f04a                	sd	s2,32(sp)
    80001592:	ec4e                	sd	s3,24(sp)
    80001594:	e852                	sd	s4,16(sp)
    80001596:	e456                	sd	s5,8(sp)
    80001598:	e05a                	sd	s6,0(sp)
    8000159a:	0080                	addi	s0,sp,64
    8000159c:	8aaa                	mv	s5,a0
    8000159e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800015a0:	6785                	lui	a5,0x1
    800015a2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015a4:	95be                	add	a1,a1,a5
    800015a6:	77fd                	lui	a5,0xfffff
    800015a8:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE)
    800015ac:	08c9f363          	bgeu	s3,a2,80001632 <uvmalloc+0xae>
    800015b0:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    800015b2:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	69a080e7          	jalr	1690(ra) # 80000c50 <kalloc>
    800015be:	84aa                	mv	s1,a0
    if (mem == 0)
    800015c0:	c51d                	beqz	a0,800015ee <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    800015c2:	6605                	lui	a2,0x1
    800015c4:	4581                	li	a1,0
    800015c6:	00000097          	auipc	ra,0x0
    800015ca:	880080e7          	jalr	-1920(ra) # 80000e46 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    800015ce:	875a                	mv	a4,s6
    800015d0:	86a6                	mv	a3,s1
    800015d2:	6605                	lui	a2,0x1
    800015d4:	85ca                	mv	a1,s2
    800015d6:	8556                	mv	a0,s5
    800015d8:	00000097          	auipc	ra,0x0
    800015dc:	c3a080e7          	jalr	-966(ra) # 80001212 <mappages>
    800015e0:	e90d                	bnez	a0,80001612 <uvmalloc+0x8e>
  for (a = oldsz; a < newsz; a += PGSIZE)
    800015e2:	6785                	lui	a5,0x1
    800015e4:	993e                	add	s2,s2,a5
    800015e6:	fd4968e3          	bltu	s2,s4,800015b6 <uvmalloc+0x32>
  return newsz;
    800015ea:	8552                	mv	a0,s4
    800015ec:	a809                	j	800015fe <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800015ee:	864e                	mv	a2,s3
    800015f0:	85ca                	mv	a1,s2
    800015f2:	8556                	mv	a0,s5
    800015f4:	00000097          	auipc	ra,0x0
    800015f8:	f48080e7          	jalr	-184(ra) # 8000153c <uvmdealloc>
      return 0;
    800015fc:	4501                	li	a0,0
}
    800015fe:	70e2                	ld	ra,56(sp)
    80001600:	7442                	ld	s0,48(sp)
    80001602:	74a2                	ld	s1,40(sp)
    80001604:	7902                	ld	s2,32(sp)
    80001606:	69e2                	ld	s3,24(sp)
    80001608:	6a42                	ld	s4,16(sp)
    8000160a:	6aa2                	ld	s5,8(sp)
    8000160c:	6b02                	ld	s6,0(sp)
    8000160e:	6121                	addi	sp,sp,64
    80001610:	8082                	ret
      kfree(mem);
    80001612:	8526                	mv	a0,s1
    80001614:	fffff097          	auipc	ra,0xfffff
    80001618:	464080e7          	jalr	1124(ra) # 80000a78 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000161c:	864e                	mv	a2,s3
    8000161e:	85ca                	mv	a1,s2
    80001620:	8556                	mv	a0,s5
    80001622:	00000097          	auipc	ra,0x0
    80001626:	f1a080e7          	jalr	-230(ra) # 8000153c <uvmdealloc>
      return 0;
    8000162a:	4501                	li	a0,0
    8000162c:	bfc9                	j	800015fe <uvmalloc+0x7a>
    return oldsz;
    8000162e:	852e                	mv	a0,a1
}
    80001630:	8082                	ret
  return newsz;
    80001632:	8532                	mv	a0,a2
    80001634:	b7e9                	j	800015fe <uvmalloc+0x7a>

0000000080001636 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    80001636:	7179                	addi	sp,sp,-48
    80001638:	f406                	sd	ra,40(sp)
    8000163a:	f022                	sd	s0,32(sp)
    8000163c:	ec26                	sd	s1,24(sp)
    8000163e:	e84a                	sd	s2,16(sp)
    80001640:	e44e                	sd	s3,8(sp)
    80001642:	e052                	sd	s4,0(sp)
    80001644:	1800                	addi	s0,sp,48
    80001646:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    80001648:	84aa                	mv	s1,a0
    8000164a:	6905                	lui	s2,0x1
    8000164c:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    8000164e:	4985                	li	s3,1
    80001650:	a829                	j	8000166a <freewalk+0x34>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001652:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001654:	00c79513          	slli	a0,a5,0xc
    80001658:	00000097          	auipc	ra,0x0
    8000165c:	fde080e7          	jalr	-34(ra) # 80001636 <freewalk>
      pagetable[i] = 0;
    80001660:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    80001664:	04a1                	addi	s1,s1,8
    80001666:	03248163          	beq	s1,s2,80001688 <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000166a:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    8000166c:	00f7f713          	andi	a4,a5,15
    80001670:	ff3701e3          	beq	a4,s3,80001652 <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    80001674:	8b85                	andi	a5,a5,1
    80001676:	d7fd                	beqz	a5,80001664 <freewalk+0x2e>
    {
      panic("freewalk: leaf");
    80001678:	00007517          	auipc	a0,0x7
    8000167c:	b4050513          	addi	a0,a0,-1216 # 800081b8 <digits+0x178>
    80001680:	fffff097          	auipc	ra,0xfffff
    80001684:	ec0080e7          	jalr	-320(ra) # 80000540 <panic>
    }
  }
  kfree((void *)pagetable);
    80001688:	8552                	mv	a0,s4
    8000168a:	fffff097          	auipc	ra,0xfffff
    8000168e:	3ee080e7          	jalr	1006(ra) # 80000a78 <kfree>
}
    80001692:	70a2                	ld	ra,40(sp)
    80001694:	7402                	ld	s0,32(sp)
    80001696:	64e2                	ld	s1,24(sp)
    80001698:	6942                	ld	s2,16(sp)
    8000169a:	69a2                	ld	s3,8(sp)
    8000169c:	6a02                	ld	s4,0(sp)
    8000169e:	6145                	addi	sp,sp,48
    800016a0:	8082                	ret

00000000800016a2 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016a2:	1101                	addi	sp,sp,-32
    800016a4:	ec06                	sd	ra,24(sp)
    800016a6:	e822                	sd	s0,16(sp)
    800016a8:	e426                	sd	s1,8(sp)
    800016aa:	1000                	addi	s0,sp,32
    800016ac:	84aa                	mv	s1,a0
  if (sz > 0)
    800016ae:	e999                	bnez	a1,800016c4 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    800016b0:	8526                	mv	a0,s1
    800016b2:	00000097          	auipc	ra,0x0
    800016b6:	f84080e7          	jalr	-124(ra) # 80001636 <freewalk>
}
    800016ba:	60e2                	ld	ra,24(sp)
    800016bc:	6442                	ld	s0,16(sp)
    800016be:	64a2                	ld	s1,8(sp)
    800016c0:	6105                	addi	sp,sp,32
    800016c2:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800016c4:	6785                	lui	a5,0x1
    800016c6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800016c8:	95be                	add	a1,a1,a5
    800016ca:	4685                	li	a3,1
    800016cc:	00c5d613          	srli	a2,a1,0xc
    800016d0:	4581                	li	a1,0
    800016d2:	00000097          	auipc	ra,0x0
    800016d6:	d06080e7          	jalr	-762(ra) # 800013d8 <uvmunmap>
    800016da:	bfd9                	j	800016b0 <uvmfree+0xe>

00000000800016dc <uvmcowpy>:

int uvmcowpy(pagetable_t old, pagetable_t new, uint64 sz)
{
    800016dc:	715d                	addi	sp,sp,-80
    800016de:	e486                	sd	ra,72(sp)
    800016e0:	e0a2                	sd	s0,64(sp)
    800016e2:	fc26                	sd	s1,56(sp)
    800016e4:	f84a                	sd	s2,48(sp)
    800016e6:	f44e                	sd	s3,40(sp)
    800016e8:	f052                	sd	s4,32(sp)
    800016ea:	ec56                	sd	s5,24(sp)
    800016ec:	e85a                	sd	s6,16(sp)
    800016ee:	e45e                	sd	s7,8(sp)
    800016f0:	0880                	addi	s0,sp,80
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for (i = 0; i < sz; i += PGSIZE)
    800016f2:	ce5d                	beqz	a2,800017b0 <uvmcowpy+0xd4>
    800016f4:	8aaa                	mv	s5,a0
    800016f6:	8a2e                	mv	s4,a1
    800016f8:	89b2                	mv	s3,a2
    800016fa:	4481                	li	s1,0
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if (flags & PTE_W)
    {
      flags = (flags & (~PTE_W)) | PTE_C;
      *pte = PA2PTE(pa) | flags;
    800016fc:	7b7d                	lui	s6,0xfffff
    800016fe:	002b5b13          	srli	s6,s6,0x2
    80001702:	a0a1                	j	8000174a <uvmcowpy+0x6e>
      panic("uvmcopy: pte should exist");
    80001704:	00007517          	auipc	a0,0x7
    80001708:	ac450513          	addi	a0,a0,-1340 # 800081c8 <digits+0x188>
    8000170c:	fffff097          	auipc	ra,0xfffff
    80001710:	e34080e7          	jalr	-460(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    80001714:	00007517          	auipc	a0,0x7
    80001718:	ad450513          	addi	a0,a0,-1324 # 800081e8 <digits+0x1a8>
    8000171c:	fffff097          	auipc	ra,0xfffff
    80001720:	e24080e7          	jalr	-476(ra) # 80000540 <panic>
    }
    // if ((mem = kalloc()) == 0)
    //   goto err;
    // memmove(mem, (char *)pa, PGSIZE);
    if (mappages(new, i, PGSIZE, (uint64)pa, flags) != 0)
    80001724:	86ca                	mv	a3,s2
    80001726:	6605                	lui	a2,0x1
    80001728:	85a6                	mv	a1,s1
    8000172a:	8552                	mv	a0,s4
    8000172c:	00000097          	auipc	ra,0x0
    80001730:	ae6080e7          	jalr	-1306(ra) # 80001212 <mappages>
    80001734:	8baa                	mv	s7,a0
    80001736:	e539                	bnez	a0,80001784 <uvmcowpy+0xa8>
    {
      // kfree(mem);
      goto err;
    }

    increase_pgreference((void *)pa);
    80001738:	854a                	mv	a0,s2
    8000173a:	fffff097          	auipc	ra,0xfffff
    8000173e:	3c2080e7          	jalr	962(ra) # 80000afc <increase_pgreference>
  for (i = 0; i < sz; i += PGSIZE)
    80001742:	6785                	lui	a5,0x1
    80001744:	94be                	add	s1,s1,a5
    80001746:	0534f963          	bgeu	s1,s3,80001798 <uvmcowpy+0xbc>
    if ((pte = walk(old, i, 0)) == 0)
    8000174a:	4601                	li	a2,0
    8000174c:	85a6                	mv	a1,s1
    8000174e:	8556                	mv	a0,s5
    80001750:	00000097          	auipc	ra,0x0
    80001754:	9da080e7          	jalr	-1574(ra) # 8000112a <walk>
    80001758:	d555                	beqz	a0,80001704 <uvmcowpy+0x28>
    if ((*pte & PTE_V) == 0)
    8000175a:	611c                	ld	a5,0(a0)
    8000175c:	0017f713          	andi	a4,a5,1
    80001760:	db55                	beqz	a4,80001714 <uvmcowpy+0x38>
    pa = PTE2PA(*pte);
    80001762:	00a7d913          	srli	s2,a5,0xa
    80001766:	0932                	slli	s2,s2,0xc
    flags = PTE_FLAGS(*pte);
    80001768:	3ff7f713          	andi	a4,a5,1023
    if (flags & PTE_W)
    8000176c:	0047f693          	andi	a3,a5,4
    80001770:	dad5                	beqz	a3,80001724 <uvmcowpy+0x48>
      flags = (flags & (~PTE_W)) | PTE_C;
    80001772:	efb77693          	andi	a3,a4,-261
    80001776:	1006e713          	ori	a4,a3,256
      *pte = PA2PTE(pa) | flags;
    8000177a:	0167f7b3          	and	a5,a5,s6
    8000177e:	8fd9                	or	a5,a5,a4
    80001780:	e11c                	sd	a5,0(a0)
    80001782:	b74d                	j	80001724 <uvmcowpy+0x48>
    // }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001784:	4685                	li	a3,1
    80001786:	00c4d613          	srli	a2,s1,0xc
    8000178a:	4581                	li	a1,0
    8000178c:	8552                	mv	a0,s4
    8000178e:	00000097          	auipc	ra,0x0
    80001792:	c4a080e7          	jalr	-950(ra) # 800013d8 <uvmunmap>
  return -1;
    80001796:	5bfd                	li	s7,-1
}
    80001798:	855e                	mv	a0,s7
    8000179a:	60a6                	ld	ra,72(sp)
    8000179c:	6406                	ld	s0,64(sp)
    8000179e:	74e2                	ld	s1,56(sp)
    800017a0:	7942                	ld	s2,48(sp)
    800017a2:	79a2                	ld	s3,40(sp)
    800017a4:	7a02                	ld	s4,32(sp)
    800017a6:	6ae2                	ld	s5,24(sp)
    800017a8:	6b42                	ld	s6,16(sp)
    800017aa:	6ba2                	ld	s7,8(sp)
    800017ac:	6161                	addi	sp,sp,80
    800017ae:	8082                	ret
  return 0;
    800017b0:	4b81                	li	s7,0
    800017b2:	b7dd                	j	80001798 <uvmcowpy+0xbc>

00000000800017b4 <uvmcopy>:
// Copies both the page table and the
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    800017b4:	1141                	addi	sp,sp,-16
    800017b6:	e406                	sd	ra,8(sp)
    800017b8:	e022                	sd	s0,0(sp)
    800017ba:	0800                	addi	s0,sp,16

#ifndef NOCOW
  return uvmcowpy(old, new, sz);
    800017bc:	00000097          	auipc	ra,0x0
    800017c0:	f20080e7          	jalr	-224(ra) # 800016dc <uvmcowpy>
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}
    800017c4:	60a2                	ld	ra,8(sp)
    800017c6:	6402                	ld	s0,0(sp)
    800017c8:	0141                	addi	sp,sp,16
    800017ca:	8082                	ret

00000000800017cc <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    800017cc:	1141                	addi	sp,sp,-16
    800017ce:	e406                	sd	ra,8(sp)
    800017d0:	e022                	sd	s0,0(sp)
    800017d2:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800017d4:	4601                	li	a2,0
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	954080e7          	jalr	-1708(ra) # 8000112a <walk>
  if (pte == 0)
    800017de:	c901                	beqz	a0,800017ee <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017e0:	611c                	ld	a5,0(a0)
    800017e2:	9bbd                	andi	a5,a5,-17
    800017e4:	e11c                	sd	a5,0(a0)
}
    800017e6:	60a2                	ld	ra,8(sp)
    800017e8:	6402                	ld	s0,0(sp)
    800017ea:	0141                	addi	sp,sp,16
    800017ec:	8082                	ret
    panic("uvmclear");
    800017ee:	00007517          	auipc	a0,0x7
    800017f2:	a1a50513          	addi	a0,a0,-1510 # 80008208 <digits+0x1c8>
    800017f6:	fffff097          	auipc	ra,0xfffff
    800017fa:	d4a080e7          	jalr	-694(ra) # 80000540 <panic>

00000000800017fe <copyout>:
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    800017fe:	c6c5                	beqz	a3,800018a6 <copyout+0xa8>
{
    80001800:	711d                	addi	sp,sp,-96
    80001802:	ec86                	sd	ra,88(sp)
    80001804:	e8a2                	sd	s0,80(sp)
    80001806:	e4a6                	sd	s1,72(sp)
    80001808:	e0ca                	sd	s2,64(sp)
    8000180a:	fc4e                	sd	s3,56(sp)
    8000180c:	f852                	sd	s4,48(sp)
    8000180e:	f456                	sd	s5,40(sp)
    80001810:	f05a                	sd	s6,32(sp)
    80001812:	ec5e                	sd	s7,24(sp)
    80001814:	e862                	sd	s8,16(sp)
    80001816:	e466                	sd	s9,8(sp)
    80001818:	1080                	addi	s0,sp,96
    8000181a:	8baa                	mv	s7,a0
    8000181c:	8a2e                	mv	s4,a1
    8000181e:	8b32                	mv	s6,a2
    80001820:	8ab6                	mv	s5,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80001822:	7cfd                	lui	s9,0xfffff
    }

    if (pa0 == 0)
      return -1;

    n = PGSIZE - (dstva - va0);
    80001824:	6c05                	lui	s8,0x1
    80001826:	a091                	j	8000186a <copyout+0x6c>
      pgfault(va0, pagetable);
    80001828:	85de                	mv	a1,s7
    8000182a:	854a                	mv	a0,s2
    8000182c:	00001097          	auipc	ra,0x1
    80001830:	5a8080e7          	jalr	1448(ra) # 80002dd4 <pgfault>
      pa0 = walkaddr(pagetable, va0);
    80001834:	85ca                	mv	a1,s2
    80001836:	855e                	mv	a0,s7
    80001838:	00000097          	auipc	ra,0x0
    8000183c:	998080e7          	jalr	-1640(ra) # 800011d0 <walkaddr>
    80001840:	89aa                	mv	s3,a0
    if (pa0 == 0)
    80001842:	e929                	bnez	a0,80001894 <copyout+0x96>
      return -1;
    80001844:	557d                	li	a0,-1
    80001846:	a09d                	j	800018ac <copyout+0xae>
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001848:	412a0533          	sub	a0,s4,s2
    8000184c:	0004861b          	sext.w	a2,s1
    80001850:	85da                	mv	a1,s6
    80001852:	954e                	add	a0,a0,s3
    80001854:	fffff097          	auipc	ra,0xfffff
    80001858:	64e080e7          	jalr	1614(ra) # 80000ea2 <memmove>

    len -= n;
    8000185c:	409a8ab3          	sub	s5,s5,s1
    src += n;
    80001860:	9b26                	add	s6,s6,s1
    dstva = va0 + PGSIZE;
    80001862:	01890a33          	add	s4,s2,s8
  while (len > 0)
    80001866:	020a8e63          	beqz	s5,800018a2 <copyout+0xa4>
    va0 = PGROUNDDOWN(dstva);
    8000186a:	019a7933          	and	s2,s4,s9
    pa0 = walkaddr(pagetable, va0);
    8000186e:	85ca                	mv	a1,s2
    80001870:	855e                	mv	a0,s7
    80001872:	00000097          	auipc	ra,0x0
    80001876:	95e080e7          	jalr	-1698(ra) # 800011d0 <walkaddr>
    8000187a:	89aa                	mv	s3,a0
    if (pa0 == 0)
    8000187c:	c51d                	beqz	a0,800018aa <copyout+0xac>
    if (PTE_FLAGS(*(walk(pagetable, va0, 0))) & PTE_C)
    8000187e:	4601                	li	a2,0
    80001880:	85ca                	mv	a1,s2
    80001882:	855e                	mv	a0,s7
    80001884:	00000097          	auipc	ra,0x0
    80001888:	8a6080e7          	jalr	-1882(ra) # 8000112a <walk>
    8000188c:	611c                	ld	a5,0(a0)
    8000188e:	1007f793          	andi	a5,a5,256
    80001892:	fbd9                	bnez	a5,80001828 <copyout+0x2a>
    n = PGSIZE - (dstva - va0);
    80001894:	414904b3          	sub	s1,s2,s4
    80001898:	94e2                	add	s1,s1,s8
    8000189a:	fa9af7e3          	bgeu	s5,s1,80001848 <copyout+0x4a>
    8000189e:	84d6                	mv	s1,s5
    800018a0:	b765                	j	80001848 <copyout+0x4a>
  }
  return 0;
    800018a2:	4501                	li	a0,0
    800018a4:	a021                	j	800018ac <copyout+0xae>
    800018a6:	4501                	li	a0,0
}
    800018a8:	8082                	ret
      return -1;
    800018aa:	557d                	li	a0,-1
}
    800018ac:	60e6                	ld	ra,88(sp)
    800018ae:	6446                	ld	s0,80(sp)
    800018b0:	64a6                	ld	s1,72(sp)
    800018b2:	6906                	ld	s2,64(sp)
    800018b4:	79e2                	ld	s3,56(sp)
    800018b6:	7a42                	ld	s4,48(sp)
    800018b8:	7aa2                	ld	s5,40(sp)
    800018ba:	7b02                	ld	s6,32(sp)
    800018bc:	6be2                	ld	s7,24(sp)
    800018be:	6c42                	ld	s8,16(sp)
    800018c0:	6ca2                	ld	s9,8(sp)
    800018c2:	6125                	addi	sp,sp,96
    800018c4:	8082                	ret

00000000800018c6 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    800018c6:	caa5                	beqz	a3,80001936 <copyin+0x70>
{
    800018c8:	715d                	addi	sp,sp,-80
    800018ca:	e486                	sd	ra,72(sp)
    800018cc:	e0a2                	sd	s0,64(sp)
    800018ce:	fc26                	sd	s1,56(sp)
    800018d0:	f84a                	sd	s2,48(sp)
    800018d2:	f44e                	sd	s3,40(sp)
    800018d4:	f052                	sd	s4,32(sp)
    800018d6:	ec56                	sd	s5,24(sp)
    800018d8:	e85a                	sd	s6,16(sp)
    800018da:	e45e                	sd	s7,8(sp)
    800018dc:	e062                	sd	s8,0(sp)
    800018de:	0880                	addi	s0,sp,80
    800018e0:	8b2a                	mv	s6,a0
    800018e2:	8a2e                	mv	s4,a1
    800018e4:	8c32                	mv	s8,a2
    800018e6:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    800018e8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018ea:	6a85                	lui	s5,0x1
    800018ec:	a01d                	j	80001912 <copyin+0x4c>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018ee:	018505b3          	add	a1,a0,s8
    800018f2:	0004861b          	sext.w	a2,s1
    800018f6:	412585b3          	sub	a1,a1,s2
    800018fa:	8552                	mv	a0,s4
    800018fc:	fffff097          	auipc	ra,0xfffff
    80001900:	5a6080e7          	jalr	1446(ra) # 80000ea2 <memmove>

    len -= n;
    80001904:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001908:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000190a:	01590c33          	add	s8,s2,s5
  while (len > 0)
    8000190e:	02098263          	beqz	s3,80001932 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001912:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001916:	85ca                	mv	a1,s2
    80001918:	855a                	mv	a0,s6
    8000191a:	00000097          	auipc	ra,0x0
    8000191e:	8b6080e7          	jalr	-1866(ra) # 800011d0 <walkaddr>
    if (pa0 == 0)
    80001922:	cd01                	beqz	a0,8000193a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001924:	418904b3          	sub	s1,s2,s8
    80001928:	94d6                	add	s1,s1,s5
    8000192a:	fc99f2e3          	bgeu	s3,s1,800018ee <copyin+0x28>
    8000192e:	84ce                	mv	s1,s3
    80001930:	bf7d                	j	800018ee <copyin+0x28>
  }
  return 0;
    80001932:	4501                	li	a0,0
    80001934:	a021                	j	8000193c <copyin+0x76>
    80001936:	4501                	li	a0,0
}
    80001938:	8082                	ret
      return -1;
    8000193a:	557d                	li	a0,-1
}
    8000193c:	60a6                	ld	ra,72(sp)
    8000193e:	6406                	ld	s0,64(sp)
    80001940:	74e2                	ld	s1,56(sp)
    80001942:	7942                	ld	s2,48(sp)
    80001944:	79a2                	ld	s3,40(sp)
    80001946:	7a02                	ld	s4,32(sp)
    80001948:	6ae2                	ld	s5,24(sp)
    8000194a:	6b42                	ld	s6,16(sp)
    8000194c:	6ba2                	ld	s7,8(sp)
    8000194e:	6c02                	ld	s8,0(sp)
    80001950:	6161                	addi	sp,sp,80
    80001952:	8082                	ret

0000000080001954 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80001954:	c2dd                	beqz	a3,800019fa <copyinstr+0xa6>
{
    80001956:	715d                	addi	sp,sp,-80
    80001958:	e486                	sd	ra,72(sp)
    8000195a:	e0a2                	sd	s0,64(sp)
    8000195c:	fc26                	sd	s1,56(sp)
    8000195e:	f84a                	sd	s2,48(sp)
    80001960:	f44e                	sd	s3,40(sp)
    80001962:	f052                	sd	s4,32(sp)
    80001964:	ec56                	sd	s5,24(sp)
    80001966:	e85a                	sd	s6,16(sp)
    80001968:	e45e                	sd	s7,8(sp)
    8000196a:	0880                	addi	s0,sp,80
    8000196c:	8a2a                	mv	s4,a0
    8000196e:	8b2e                	mv	s6,a1
    80001970:	8bb2                	mv	s7,a2
    80001972:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80001974:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001976:	6985                	lui	s3,0x1
    80001978:	a02d                	j	800019a2 <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    8000197a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000197e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80001980:	37fd                	addiw	a5,a5,-1
    80001982:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    80001986:	60a6                	ld	ra,72(sp)
    80001988:	6406                	ld	s0,64(sp)
    8000198a:	74e2                	ld	s1,56(sp)
    8000198c:	7942                	ld	s2,48(sp)
    8000198e:	79a2                	ld	s3,40(sp)
    80001990:	7a02                	ld	s4,32(sp)
    80001992:	6ae2                	ld	s5,24(sp)
    80001994:	6b42                	ld	s6,16(sp)
    80001996:	6ba2                	ld	s7,8(sp)
    80001998:	6161                	addi	sp,sp,80
    8000199a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000199c:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    800019a0:	c8a9                	beqz	s1,800019f2 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800019a2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800019a6:	85ca                	mv	a1,s2
    800019a8:	8552                	mv	a0,s4
    800019aa:	00000097          	auipc	ra,0x0
    800019ae:	826080e7          	jalr	-2010(ra) # 800011d0 <walkaddr>
    if (pa0 == 0)
    800019b2:	c131                	beqz	a0,800019f6 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800019b4:	417906b3          	sub	a3,s2,s7
    800019b8:	96ce                	add	a3,a3,s3
    800019ba:	00d4f363          	bgeu	s1,a3,800019c0 <copyinstr+0x6c>
    800019be:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    800019c0:	955e                	add	a0,a0,s7
    800019c2:	41250533          	sub	a0,a0,s2
    while (n > 0)
    800019c6:	daf9                	beqz	a3,8000199c <copyinstr+0x48>
    800019c8:	87da                	mv	a5,s6
      if (*p == '\0')
    800019ca:	41650633          	sub	a2,a0,s6
    800019ce:	fff48593          	addi	a1,s1,-1
    800019d2:	95da                	add	a1,a1,s6
    while (n > 0)
    800019d4:	96da                	add	a3,a3,s6
      if (*p == '\0')
    800019d6:	00f60733          	add	a4,a2,a5
    800019da:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fdb9a30>
    800019de:	df51                	beqz	a4,8000197a <copyinstr+0x26>
        *dst = *p;
    800019e0:	00e78023          	sb	a4,0(a5)
      --max;
    800019e4:	40f584b3          	sub	s1,a1,a5
      dst++;
    800019e8:	0785                	addi	a5,a5,1
    while (n > 0)
    800019ea:	fed796e3          	bne	a5,a3,800019d6 <copyinstr+0x82>
      dst++;
    800019ee:	8b3e                	mv	s6,a5
    800019f0:	b775                	j	8000199c <copyinstr+0x48>
    800019f2:	4781                	li	a5,0
    800019f4:	b771                	j	80001980 <copyinstr+0x2c>
      return -1;
    800019f6:	557d                	li	a0,-1
    800019f8:	b779                	j	80001986 <copyinstr+0x32>
  int got_null = 0;
    800019fa:	4781                	li	a5,0
  if (got_null)
    800019fc:	37fd                	addiw	a5,a5,-1
    800019fe:	0007851b          	sext.w	a0,a5
}
    80001a02:	8082                	ret

0000000080001a04 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001a04:	7139                	addi	sp,sp,-64
    80001a06:	fc06                	sd	ra,56(sp)
    80001a08:	f822                	sd	s0,48(sp)
    80001a0a:	f426                	sd	s1,40(sp)
    80001a0c:	f04a                	sd	s2,32(sp)
    80001a0e:	ec4e                	sd	s3,24(sp)
    80001a10:	e852                	sd	s4,16(sp)
    80001a12:	e456                	sd	s5,8(sp)
    80001a14:	e05a                	sd	s6,0(sp)
    80001a16:	0080                	addi	s0,sp,64
    80001a18:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001a1a:	00230497          	auipc	s1,0x230
    80001a1e:	82e48493          	addi	s1,s1,-2002 # 80231248 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001a22:	8b26                	mv	s6,s1
    80001a24:	00006a97          	auipc	s5,0x6
    80001a28:	5dca8a93          	addi	s5,s5,1500 # 80008000 <etext>
    80001a2c:	04000937          	lui	s2,0x4000
    80001a30:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a32:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a34:	00237a17          	auipc	s4,0x237
    80001a38:	a14a0a13          	addi	s4,s4,-1516 # 80238448 <mlfq>
    char *pa = kalloc();
    80001a3c:	fffff097          	auipc	ra,0xfffff
    80001a40:	214080e7          	jalr	532(ra) # 80000c50 <kalloc>
    80001a44:	862a                	mv	a2,a0
    if (pa == 0)
    80001a46:	c131                	beqz	a0,80001a8a <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001a48:	416485b3          	sub	a1,s1,s6
    80001a4c:	858d                	srai	a1,a1,0x3
    80001a4e:	000ab783          	ld	a5,0(s5)
    80001a52:	02f585b3          	mul	a1,a1,a5
    80001a56:	2585                	addiw	a1,a1,1
    80001a58:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a5c:	4719                	li	a4,6
    80001a5e:	6685                	lui	a3,0x1
    80001a60:	40b905b3          	sub	a1,s2,a1
    80001a64:	854e                	mv	a0,s3
    80001a66:	00000097          	auipc	ra,0x0
    80001a6a:	84c080e7          	jalr	-1972(ra) # 800012b2 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a6e:	1c848493          	addi	s1,s1,456
    80001a72:	fd4495e3          	bne	s1,s4,80001a3c <proc_mapstacks+0x38>
  }
}
    80001a76:	70e2                	ld	ra,56(sp)
    80001a78:	7442                	ld	s0,48(sp)
    80001a7a:	74a2                	ld	s1,40(sp)
    80001a7c:	7902                	ld	s2,32(sp)
    80001a7e:	69e2                	ld	s3,24(sp)
    80001a80:	6a42                	ld	s4,16(sp)
    80001a82:	6aa2                	ld	s5,8(sp)
    80001a84:	6b02                	ld	s6,0(sp)
    80001a86:	6121                	addi	sp,sp,64
    80001a88:	8082                	ret
      panic("kalloc");
    80001a8a:	00006517          	auipc	a0,0x6
    80001a8e:	78e50513          	addi	a0,a0,1934 # 80008218 <digits+0x1d8>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	aae080e7          	jalr	-1362(ra) # 80000540 <panic>

0000000080001a9a <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001a9a:	7139                	addi	sp,sp,-64
    80001a9c:	fc06                	sd	ra,56(sp)
    80001a9e:	f822                	sd	s0,48(sp)
    80001aa0:	f426                	sd	s1,40(sp)
    80001aa2:	f04a                	sd	s2,32(sp)
    80001aa4:	ec4e                	sd	s3,24(sp)
    80001aa6:	e852                	sd	s4,16(sp)
    80001aa8:	e456                	sd	s5,8(sp)
    80001aaa:	e05a                	sd	s6,0(sp)
    80001aac:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001aae:	00006597          	auipc	a1,0x6
    80001ab2:	77258593          	addi	a1,a1,1906 # 80008220 <digits+0x1e0>
    80001ab6:	0022f517          	auipc	a0,0x22f
    80001aba:	36250513          	addi	a0,a0,866 # 80230e18 <pid_lock>
    80001abe:	fffff097          	auipc	ra,0xfffff
    80001ac2:	1fc080e7          	jalr	508(ra) # 80000cba <initlock>
  initlock(&wait_lock, "wait_lock");
    80001ac6:	00006597          	auipc	a1,0x6
    80001aca:	76258593          	addi	a1,a1,1890 # 80008228 <digits+0x1e8>
    80001ace:	0022f517          	auipc	a0,0x22f
    80001ad2:	36250513          	addi	a0,a0,866 # 80230e30 <wait_lock>
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	1e4080e7          	jalr	484(ra) # 80000cba <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ade:	0022f497          	auipc	s1,0x22f
    80001ae2:	76a48493          	addi	s1,s1,1898 # 80231248 <proc>
  {
    initlock(&p->lock, "proc");
    80001ae6:	00006b17          	auipc	s6,0x6
    80001aea:	752b0b13          	addi	s6,s6,1874 # 80008238 <digits+0x1f8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001aee:	8aa6                	mv	s5,s1
    80001af0:	00006a17          	auipc	s4,0x6
    80001af4:	510a0a13          	addi	s4,s4,1296 # 80008000 <etext>
    80001af8:	04000937          	lui	s2,0x4000
    80001afc:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001afe:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001b00:	00237997          	auipc	s3,0x237
    80001b04:	94898993          	addi	s3,s3,-1720 # 80238448 <mlfq>
    initlock(&p->lock, "proc");
    80001b08:	85da                	mv	a1,s6
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	1ae080e7          	jalr	430(ra) # 80000cba <initlock>
    p->state = UNUSED;
    80001b14:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001b18:	415487b3          	sub	a5,s1,s5
    80001b1c:	878d                	srai	a5,a5,0x3
    80001b1e:	000a3703          	ld	a4,0(s4)
    80001b22:	02e787b3          	mul	a5,a5,a4
    80001b26:	2785                	addiw	a5,a5,1
    80001b28:	00d7979b          	slliw	a5,a5,0xd
    80001b2c:	40f907b3          	sub	a5,s2,a5
    80001b30:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001b32:	1c848493          	addi	s1,s1,456
    80001b36:	fd3499e3          	bne	s1,s3,80001b08 <procinit+0x6e>
  }
}
    80001b3a:	70e2                	ld	ra,56(sp)
    80001b3c:	7442                	ld	s0,48(sp)
    80001b3e:	74a2                	ld	s1,40(sp)
    80001b40:	7902                	ld	s2,32(sp)
    80001b42:	69e2                	ld	s3,24(sp)
    80001b44:	6a42                	ld	s4,16(sp)
    80001b46:	6aa2                	ld	s5,8(sp)
    80001b48:	6b02                	ld	s6,0(sp)
    80001b4a:	6121                	addi	sp,sp,64
    80001b4c:	8082                	ret

0000000080001b4e <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001b4e:	1141                	addi	sp,sp,-16
    80001b50:	e422                	sd	s0,8(sp)
    80001b52:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp"
    80001b54:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b56:	2501                	sext.w	a0,a0
    80001b58:	6422                	ld	s0,8(sp)
    80001b5a:	0141                	addi	sp,sp,16
    80001b5c:	8082                	ret

0000000080001b5e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001b5e:	1141                	addi	sp,sp,-16
    80001b60:	e422                	sd	s0,8(sp)
    80001b62:	0800                	addi	s0,sp,16
    80001b64:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b66:	2781                	sext.w	a5,a5
    80001b68:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b6a:	0022f517          	auipc	a0,0x22f
    80001b6e:	2de50513          	addi	a0,a0,734 # 80230e48 <cpus>
    80001b72:	953e                	add	a0,a0,a5
    80001b74:	6422                	ld	s0,8(sp)
    80001b76:	0141                	addi	sp,sp,16
    80001b78:	8082                	ret

0000000080001b7a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001b7a:	1101                	addi	sp,sp,-32
    80001b7c:	ec06                	sd	ra,24(sp)
    80001b7e:	e822                	sd	s0,16(sp)
    80001b80:	e426                	sd	s1,8(sp)
    80001b82:	1000                	addi	s0,sp,32
  push_off();
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	17a080e7          	jalr	378(ra) # 80000cfe <push_off>
    80001b8c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b8e:	2781                	sext.w	a5,a5
    80001b90:	079e                	slli	a5,a5,0x7
    80001b92:	0022f717          	auipc	a4,0x22f
    80001b96:	28670713          	addi	a4,a4,646 # 80230e18 <pid_lock>
    80001b9a:	97ba                	add	a5,a5,a4
    80001b9c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	200080e7          	jalr	512(ra) # 80000d9e <pop_off>
  return p;
}
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	60e2                	ld	ra,24(sp)
    80001baa:	6442                	ld	s0,16(sp)
    80001bac:	64a2                	ld	s1,8(sp)
    80001bae:	6105                	addi	sp,sp,32
    80001bb0:	8082                	ret

0000000080001bb2 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001bb2:	1141                	addi	sp,sp,-16
    80001bb4:	e406                	sd	ra,8(sp)
    80001bb6:	e022                	sd	s0,0(sp)
    80001bb8:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001bba:	00000097          	auipc	ra,0x0
    80001bbe:	fc0080e7          	jalr	-64(ra) # 80001b7a <myproc>
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	23c080e7          	jalr	572(ra) # 80000dfe <release>

  if (first)
    80001bca:	00007797          	auipc	a5,0x7
    80001bce:	e467a783          	lw	a5,-442(a5) # 80008a10 <first.1>
    80001bd2:	eb89                	bnez	a5,80001be4 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001bd4:	00001097          	auipc	ra,0x1
    80001bd8:	f78080e7          	jalr	-136(ra) # 80002b4c <usertrapret>
}
    80001bdc:	60a2                	ld	ra,8(sp)
    80001bde:	6402                	ld	s0,0(sp)
    80001be0:	0141                	addi	sp,sp,16
    80001be2:	8082                	ret
    first = 0;
    80001be4:	00007797          	auipc	a5,0x7
    80001be8:	e207a623          	sw	zero,-468(a5) # 80008a10 <first.1>
    fsinit(ROOTDEV);
    80001bec:	4505                	li	a0,1
    80001bee:	00002097          	auipc	ra,0x2
    80001bf2:	07e080e7          	jalr	126(ra) # 80003c6c <fsinit>
    80001bf6:	bff9                	j	80001bd4 <forkret+0x22>

0000000080001bf8 <allocpid>:
{
    80001bf8:	1101                	addi	sp,sp,-32
    80001bfa:	ec06                	sd	ra,24(sp)
    80001bfc:	e822                	sd	s0,16(sp)
    80001bfe:	e426                	sd	s1,8(sp)
    80001c00:	e04a                	sd	s2,0(sp)
    80001c02:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c04:	0022f917          	auipc	s2,0x22f
    80001c08:	21490913          	addi	s2,s2,532 # 80230e18 <pid_lock>
    80001c0c:	854a                	mv	a0,s2
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	13c080e7          	jalr	316(ra) # 80000d4a <acquire>
  pid = nextpid;
    80001c16:	00007797          	auipc	a5,0x7
    80001c1a:	dfe78793          	addi	a5,a5,-514 # 80008a14 <nextpid>
    80001c1e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c20:	0014871b          	addiw	a4,s1,1
    80001c24:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c26:	854a                	mv	a0,s2
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	1d6080e7          	jalr	470(ra) # 80000dfe <release>
}
    80001c30:	8526                	mv	a0,s1
    80001c32:	60e2                	ld	ra,24(sp)
    80001c34:	6442                	ld	s0,16(sp)
    80001c36:	64a2                	ld	s1,8(sp)
    80001c38:	6902                	ld	s2,0(sp)
    80001c3a:	6105                	addi	sp,sp,32
    80001c3c:	8082                	ret

0000000080001c3e <proc_pagetable>:
{
    80001c3e:	1101                	addi	sp,sp,-32
    80001c40:	ec06                	sd	ra,24(sp)
    80001c42:	e822                	sd	s0,16(sp)
    80001c44:	e426                	sd	s1,8(sp)
    80001c46:	e04a                	sd	s2,0(sp)
    80001c48:	1000                	addi	s0,sp,32
    80001c4a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c4c:	00000097          	auipc	ra,0x0
    80001c50:	850080e7          	jalr	-1968(ra) # 8000149c <uvmcreate>
    80001c54:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001c56:	c121                	beqz	a0,80001c96 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c58:	4729                	li	a4,10
    80001c5a:	00005697          	auipc	a3,0x5
    80001c5e:	3a668693          	addi	a3,a3,934 # 80007000 <_trampoline>
    80001c62:	6605                	lui	a2,0x1
    80001c64:	040005b7          	lui	a1,0x4000
    80001c68:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c6a:	05b2                	slli	a1,a1,0xc
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	5a6080e7          	jalr	1446(ra) # 80001212 <mappages>
    80001c74:	02054863          	bltz	a0,80001ca4 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c78:	4719                	li	a4,6
    80001c7a:	05893683          	ld	a3,88(s2)
    80001c7e:	6605                	lui	a2,0x1
    80001c80:	020005b7          	lui	a1,0x2000
    80001c84:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c86:	05b6                	slli	a1,a1,0xd
    80001c88:	8526                	mv	a0,s1
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	588080e7          	jalr	1416(ra) # 80001212 <mappages>
    80001c92:	02054163          	bltz	a0,80001cb4 <proc_pagetable+0x76>
}
    80001c96:	8526                	mv	a0,s1
    80001c98:	60e2                	ld	ra,24(sp)
    80001c9a:	6442                	ld	s0,16(sp)
    80001c9c:	64a2                	ld	s1,8(sp)
    80001c9e:	6902                	ld	s2,0(sp)
    80001ca0:	6105                	addi	sp,sp,32
    80001ca2:	8082                	ret
    uvmfree(pagetable, 0);
    80001ca4:	4581                	li	a1,0
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	00000097          	auipc	ra,0x0
    80001cac:	9fa080e7          	jalr	-1542(ra) # 800016a2 <uvmfree>
    return 0;
    80001cb0:	4481                	li	s1,0
    80001cb2:	b7d5                	j	80001c96 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cb4:	4681                	li	a3,0
    80001cb6:	4605                	li	a2,1
    80001cb8:	040005b7          	lui	a1,0x4000
    80001cbc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cbe:	05b2                	slli	a1,a1,0xc
    80001cc0:	8526                	mv	a0,s1
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	716080e7          	jalr	1814(ra) # 800013d8 <uvmunmap>
    uvmfree(pagetable, 0);
    80001cca:	4581                	li	a1,0
    80001ccc:	8526                	mv	a0,s1
    80001cce:	00000097          	auipc	ra,0x0
    80001cd2:	9d4080e7          	jalr	-1580(ra) # 800016a2 <uvmfree>
    return 0;
    80001cd6:	4481                	li	s1,0
    80001cd8:	bf7d                	j	80001c96 <proc_pagetable+0x58>

0000000080001cda <proc_freepagetable>:
{
    80001cda:	1101                	addi	sp,sp,-32
    80001cdc:	ec06                	sd	ra,24(sp)
    80001cde:	e822                	sd	s0,16(sp)
    80001ce0:	e426                	sd	s1,8(sp)
    80001ce2:	e04a                	sd	s2,0(sp)
    80001ce4:	1000                	addi	s0,sp,32
    80001ce6:	84aa                	mv	s1,a0
    80001ce8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cea:	4681                	li	a3,0
    80001cec:	4605                	li	a2,1
    80001cee:	040005b7          	lui	a1,0x4000
    80001cf2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cf4:	05b2                	slli	a1,a1,0xc
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	6e2080e7          	jalr	1762(ra) # 800013d8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cfe:	4681                	li	a3,0
    80001d00:	4605                	li	a2,1
    80001d02:	020005b7          	lui	a1,0x2000
    80001d06:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d08:	05b6                	slli	a1,a1,0xd
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	fffff097          	auipc	ra,0xfffff
    80001d10:	6cc080e7          	jalr	1740(ra) # 800013d8 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d14:	85ca                	mv	a1,s2
    80001d16:	8526                	mv	a0,s1
    80001d18:	00000097          	auipc	ra,0x0
    80001d1c:	98a080e7          	jalr	-1654(ra) # 800016a2 <uvmfree>
}
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6902                	ld	s2,0(sp)
    80001d28:	6105                	addi	sp,sp,32
    80001d2a:	8082                	ret

0000000080001d2c <freeproc>:
{
    80001d2c:	1101                	addi	sp,sp,-32
    80001d2e:	ec06                	sd	ra,24(sp)
    80001d30:	e822                	sd	s0,16(sp)
    80001d32:	e426                	sd	s1,8(sp)
    80001d34:	1000                	addi	s0,sp,32
    80001d36:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001d38:	6d28                	ld	a0,88(a0)
    80001d3a:	c509                	beqz	a0,80001d44 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	d3c080e7          	jalr	-708(ra) # 80000a78 <kfree>
  if (p->alarm_trapframe)
    80001d44:	1b84b503          	ld	a0,440(s1)
    80001d48:	c509                	beqz	a0,80001d52 <freeproc+0x26>
    kfree((void *)p->alarm_trapframe);
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	d2e080e7          	jalr	-722(ra) # 80000a78 <kfree>
  p->trapframe = 0;
    80001d52:	0404bc23          	sd	zero,88(s1)
  p->alarm_trapframe = 0;
    80001d56:	1a04bc23          	sd	zero,440(s1)
  if (p->pagetable)
    80001d5a:	68a8                	ld	a0,80(s1)
    80001d5c:	c511                	beqz	a0,80001d68 <freeproc+0x3c>
    proc_freepagetable(p->pagetable, p->sz);
    80001d5e:	64ac                	ld	a1,72(s1)
    80001d60:	00000097          	auipc	ra,0x0
    80001d64:	f7a080e7          	jalr	-134(ra) # 80001cda <proc_freepagetable>
  p->pagetable = 0;
    80001d68:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d6c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d70:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d74:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d78:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d7c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d80:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d84:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d88:	0004ac23          	sw	zero,24(s1)
}
    80001d8c:	60e2                	ld	ra,24(sp)
    80001d8e:	6442                	ld	s0,16(sp)
    80001d90:	64a2                	ld	s1,8(sp)
    80001d92:	6105                	addi	sp,sp,32
    80001d94:	8082                	ret

0000000080001d96 <allocproc>:
{
    80001d96:	1101                	addi	sp,sp,-32
    80001d98:	ec06                	sd	ra,24(sp)
    80001d9a:	e822                	sd	s0,16(sp)
    80001d9c:	e426                	sd	s1,8(sp)
    80001d9e:	e04a                	sd	s2,0(sp)
    80001da0:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001da2:	0022f497          	auipc	s1,0x22f
    80001da6:	4a648493          	addi	s1,s1,1190 # 80231248 <proc>
    80001daa:	00236917          	auipc	s2,0x236
    80001dae:	69e90913          	addi	s2,s2,1694 # 80238448 <mlfq>
    acquire(&p->lock);
    80001db2:	8526                	mv	a0,s1
    80001db4:	fffff097          	auipc	ra,0xfffff
    80001db8:	f96080e7          	jalr	-106(ra) # 80000d4a <acquire>
    if (p->state == UNUSED)
    80001dbc:	4c9c                	lw	a5,24(s1)
    80001dbe:	cf81                	beqz	a5,80001dd6 <allocproc+0x40>
      release(&p->lock);
    80001dc0:	8526                	mv	a0,s1
    80001dc2:	fffff097          	auipc	ra,0xfffff
    80001dc6:	03c080e7          	jalr	60(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001dca:	1c848493          	addi	s1,s1,456
    80001dce:	ff2492e3          	bne	s1,s2,80001db2 <allocproc+0x1c>
  return 0;
    80001dd2:	4481                	li	s1,0
    80001dd4:	a87d                	j	80001e92 <allocproc+0xfc>
  p->pid = allocpid();
    80001dd6:	00000097          	auipc	ra,0x0
    80001dda:	e22080e7          	jalr	-478(ra) # 80001bf8 <allocpid>
    80001dde:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001de0:	4785                	li	a5,1
    80001de2:	cc9c                	sw	a5,24(s1)
  p->tickets = 1;
    80001de4:	16f4ac23          	sw	a5,376(s1)
  p->static_priority = 60;
    80001de8:	03c00713          	li	a4,60
    80001dec:	18e4a023          	sw	a4,384(s1)
  p->number_of_times_scheduled = 0;
    80001df0:	1604ae23          	sw	zero,380(s1)
  p->sleeping_ticks = 0;
    80001df4:	1804a623          	sw	zero,396(s1)
  p->running_ticks = 0;
    80001df8:	1804a823          	sw	zero,400(s1)
  p->sleep_start = 0;
    80001dfc:	1804a223          	sw	zero,388(s1)
  p->reset_niceness = 1;
    80001e00:	18f4a423          	sw	a5,392(s1)
  p->level = 0;
    80001e04:	1804aa23          	sw	zero,404(s1)
  p->change_queue = 1 << p->level;
    80001e08:	18f4ae23          	sw	a5,412(s1)
  p->in_queue = 0;
    80001e0c:	1804ac23          	sw	zero,408(s1)
  p->enter_ticks = ticks;
    80001e10:	00007797          	auipc	a5,0x7
    80001e14:	d887a783          	lw	a5,-632(a5) # 80008b98 <ticks>
    80001e18:	1af4a023          	sw	a5,416(s1)
  p->now_ticks = 0;
    80001e1c:	1a04aa23          	sw	zero,436(s1)
  p->sigalarm_status = 0;
    80001e20:	1c04a023          	sw	zero,448(s1)
  p->interval = 0;
    80001e24:	1a04a823          	sw	zero,432(s1)
  p->handler = -1;
    80001e28:	57fd                	li	a5,-1
    80001e2a:	1af4b423          	sd	a5,424(s1)
  p->alarm_trapframe = NULL;
    80001e2e:	1a04bc23          	sd	zero,440(s1)
  if (forked_process && p->parent)
    80001e32:	00007797          	auipc	a5,0x7
    80001e36:	d567a783          	lw	a5,-682(a5) # 80008b88 <forked_process>
    80001e3a:	e3bd                	bnez	a5,80001ea0 <allocproc+0x10a>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	e14080e7          	jalr	-492(ra) # 80000c50 <kalloc>
    80001e44:	892a                	mv	s2,a0
    80001e46:	eca8                	sd	a0,88(s1)
    80001e48:	c53d                	beqz	a0,80001eb6 <allocproc+0x120>
  p->pagetable = proc_pagetable(p);
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	00000097          	auipc	ra,0x0
    80001e50:	df2080e7          	jalr	-526(ra) # 80001c3e <proc_pagetable>
    80001e54:	892a                	mv	s2,a0
    80001e56:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001e58:	c93d                	beqz	a0,80001ece <allocproc+0x138>
  memset(&p->context, 0, sizeof(p->context));
    80001e5a:	07000613          	li	a2,112
    80001e5e:	4581                	li	a1,0
    80001e60:	06048513          	addi	a0,s1,96
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	fe2080e7          	jalr	-30(ra) # 80000e46 <memset>
  p->context.ra = (uint64)forkret;
    80001e6c:	00000797          	auipc	a5,0x0
    80001e70:	d4678793          	addi	a5,a5,-698 # 80001bb2 <forkret>
    80001e74:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e76:	60bc                	ld	a5,64(s1)
    80001e78:	6705                	lui	a4,0x1
    80001e7a:	97ba                	add	a5,a5,a4
    80001e7c:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001e7e:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001e82:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001e86:	00007797          	auipc	a5,0x7
    80001e8a:	d127a783          	lw	a5,-750(a5) # 80008b98 <ticks>
    80001e8e:	16f4a623          	sw	a5,364(s1)
}
    80001e92:	8526                	mv	a0,s1
    80001e94:	60e2                	ld	ra,24(sp)
    80001e96:	6442                	ld	s0,16(sp)
    80001e98:	64a2                	ld	s1,8(sp)
    80001e9a:	6902                	ld	s2,0(sp)
    80001e9c:	6105                	addi	sp,sp,32
    80001e9e:	8082                	ret
  if (forked_process && p->parent)
    80001ea0:	7c9c                	ld	a5,56(s1)
    80001ea2:	dfc9                	beqz	a5,80001e3c <allocproc+0xa6>
    p->tickets = p->parent->tickets;
    80001ea4:	1787a783          	lw	a5,376(a5)
    80001ea8:	16f4ac23          	sw	a5,376(s1)
    forked_process = 0;
    80001eac:	00007797          	auipc	a5,0x7
    80001eb0:	cc07ae23          	sw	zero,-804(a5) # 80008b88 <forked_process>
    80001eb4:	b761                	j	80001e3c <allocproc+0xa6>
    freeproc(p);
    80001eb6:	8526                	mv	a0,s1
    80001eb8:	00000097          	auipc	ra,0x0
    80001ebc:	e74080e7          	jalr	-396(ra) # 80001d2c <freeproc>
    release(&p->lock);
    80001ec0:	8526                	mv	a0,s1
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	f3c080e7          	jalr	-196(ra) # 80000dfe <release>
    return 0;
    80001eca:	84ca                	mv	s1,s2
    80001ecc:	b7d9                	j	80001e92 <allocproc+0xfc>
    freeproc(p);
    80001ece:	8526                	mv	a0,s1
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	e5c080e7          	jalr	-420(ra) # 80001d2c <freeproc>
    release(&p->lock);
    80001ed8:	8526                	mv	a0,s1
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f24080e7          	jalr	-220(ra) # 80000dfe <release>
    return 0;
    80001ee2:	84ca                	mv	s1,s2
    80001ee4:	b77d                	j	80001e92 <allocproc+0xfc>

0000000080001ee6 <userinit>:
{
    80001ee6:	1101                	addi	sp,sp,-32
    80001ee8:	ec06                	sd	ra,24(sp)
    80001eea:	e822                	sd	s0,16(sp)
    80001eec:	e426                	sd	s1,8(sp)
    80001eee:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ef0:	00000097          	auipc	ra,0x0
    80001ef4:	ea6080e7          	jalr	-346(ra) # 80001d96 <allocproc>
    80001ef8:	84aa                	mv	s1,a0
  initproc = p;
    80001efa:	00007797          	auipc	a5,0x7
    80001efe:	c8a7bb23          	sd	a0,-874(a5) # 80008b90 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f02:	03400613          	li	a2,52
    80001f06:	00007597          	auipc	a1,0x7
    80001f0a:	b1a58593          	addi	a1,a1,-1254 # 80008a20 <initcode>
    80001f0e:	6928                	ld	a0,80(a0)
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	5ba080e7          	jalr	1466(ra) # 800014ca <uvmfirst>
  p->sz = PGSIZE;
    80001f18:	6785                	lui	a5,0x1
    80001f1a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001f1c:	6cb8                	ld	a4,88(s1)
    80001f1e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001f22:	6cb8                	ld	a4,88(s1)
    80001f24:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f26:	4641                	li	a2,16
    80001f28:	00006597          	auipc	a1,0x6
    80001f2c:	31858593          	addi	a1,a1,792 # 80008240 <digits+0x200>
    80001f30:	15848513          	addi	a0,s1,344
    80001f34:	fffff097          	auipc	ra,0xfffff
    80001f38:	05c080e7          	jalr	92(ra) # 80000f90 <safestrcpy>
  p->cwd = namei("/");
    80001f3c:	00006517          	auipc	a0,0x6
    80001f40:	31450513          	addi	a0,a0,788 # 80008250 <digits+0x210>
    80001f44:	00002097          	auipc	ra,0x2
    80001f48:	752080e7          	jalr	1874(ra) # 80004696 <namei>
    80001f4c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f50:	478d                	li	a5,3
    80001f52:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f54:	8526                	mv	a0,s1
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	ea8080e7          	jalr	-344(ra) # 80000dfe <release>
}
    80001f5e:	60e2                	ld	ra,24(sp)
    80001f60:	6442                	ld	s0,16(sp)
    80001f62:	64a2                	ld	s1,8(sp)
    80001f64:	6105                	addi	sp,sp,32
    80001f66:	8082                	ret

0000000080001f68 <growproc>:
{
    80001f68:	1101                	addi	sp,sp,-32
    80001f6a:	ec06                	sd	ra,24(sp)
    80001f6c:	e822                	sd	s0,16(sp)
    80001f6e:	e426                	sd	s1,8(sp)
    80001f70:	e04a                	sd	s2,0(sp)
    80001f72:	1000                	addi	s0,sp,32
    80001f74:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001f76:	00000097          	auipc	ra,0x0
    80001f7a:	c04080e7          	jalr	-1020(ra) # 80001b7a <myproc>
    80001f7e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f80:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001f82:	01204c63          	bgtz	s2,80001f9a <growproc+0x32>
  else if (n < 0)
    80001f86:	02094663          	bltz	s2,80001fb2 <growproc+0x4a>
  p->sz = sz;
    80001f8a:	e4ac                	sd	a1,72(s1)
  return 0;
    80001f8c:	4501                	li	a0,0
}
    80001f8e:	60e2                	ld	ra,24(sp)
    80001f90:	6442                	ld	s0,16(sp)
    80001f92:	64a2                	ld	s1,8(sp)
    80001f94:	6902                	ld	s2,0(sp)
    80001f96:	6105                	addi	sp,sp,32
    80001f98:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f9a:	4691                	li	a3,4
    80001f9c:	00b90633          	add	a2,s2,a1
    80001fa0:	6928                	ld	a0,80(a0)
    80001fa2:	fffff097          	auipc	ra,0xfffff
    80001fa6:	5e2080e7          	jalr	1506(ra) # 80001584 <uvmalloc>
    80001faa:	85aa                	mv	a1,a0
    80001fac:	fd79                	bnez	a0,80001f8a <growproc+0x22>
      return -1;
    80001fae:	557d                	li	a0,-1
    80001fb0:	bff9                	j	80001f8e <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001fb2:	00b90633          	add	a2,s2,a1
    80001fb6:	6928                	ld	a0,80(a0)
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	584080e7          	jalr	1412(ra) # 8000153c <uvmdealloc>
    80001fc0:	85aa                	mv	a1,a0
    80001fc2:	b7e1                	j	80001f8a <growproc+0x22>

0000000080001fc4 <fork>:
{
    80001fc4:	7139                	addi	sp,sp,-64
    80001fc6:	fc06                	sd	ra,56(sp)
    80001fc8:	f822                	sd	s0,48(sp)
    80001fca:	f426                	sd	s1,40(sp)
    80001fcc:	f04a                	sd	s2,32(sp)
    80001fce:	ec4e                	sd	s3,24(sp)
    80001fd0:	e852                	sd	s4,16(sp)
    80001fd2:	e456                	sd	s5,8(sp)
    80001fd4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001fd6:	00000097          	auipc	ra,0x0
    80001fda:	ba4080e7          	jalr	-1116(ra) # 80001b7a <myproc>
    80001fde:	8aaa                	mv	s5,a0
  if (p->pid > 1)
    80001fe0:	5918                	lw	a4,48(a0)
    80001fe2:	4785                	li	a5,1
    80001fe4:	00e7d663          	bge	a5,a4,80001ff0 <fork+0x2c>
    forked_process = 1;
    80001fe8:	00007717          	auipc	a4,0x7
    80001fec:	baf72023          	sw	a5,-1120(a4) # 80008b88 <forked_process>
  if ((np = allocproc()) == 0)
    80001ff0:	00000097          	auipc	ra,0x0
    80001ff4:	da6080e7          	jalr	-602(ra) # 80001d96 <allocproc>
    80001ff8:	89aa                	mv	s3,a0
    80001ffa:	10050f63          	beqz	a0,80002118 <fork+0x154>
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001ffe:	048ab603          	ld	a2,72(s5)
    80002002:	692c                	ld	a1,80(a0)
    80002004:	050ab503          	ld	a0,80(s5)
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	7ac080e7          	jalr	1964(ra) # 800017b4 <uvmcopy>
    80002010:	04054c63          	bltz	a0,80002068 <fork+0xa4>
  np->sz = p->sz;
    80002014:	048ab783          	ld	a5,72(s5)
    80002018:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    8000201c:	058ab683          	ld	a3,88(s5)
    80002020:	87b6                	mv	a5,a3
    80002022:	0589b703          	ld	a4,88(s3)
    80002026:	12068693          	addi	a3,a3,288
    8000202a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000202e:	6788                	ld	a0,8(a5)
    80002030:	6b8c                	ld	a1,16(a5)
    80002032:	6f90                	ld	a2,24(a5)
    80002034:	01073023          	sd	a6,0(a4)
    80002038:	e708                	sd	a0,8(a4)
    8000203a:	eb0c                	sd	a1,16(a4)
    8000203c:	ef10                	sd	a2,24(a4)
    8000203e:	02078793          	addi	a5,a5,32
    80002042:	02070713          	addi	a4,a4,32
    80002046:	fed792e3          	bne	a5,a3,8000202a <fork+0x66>
  np->tmask = p->tmask;
    8000204a:	174aa783          	lw	a5,372(s5)
    8000204e:	16f9aa23          	sw	a5,372(s3)
  np->trapframe->a0 = 0;
    80002052:	0589b783          	ld	a5,88(s3)
    80002056:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    8000205a:	0d0a8493          	addi	s1,s5,208
    8000205e:	0d098913          	addi	s2,s3,208
    80002062:	150a8a13          	addi	s4,s5,336
    80002066:	a00d                	j	80002088 <fork+0xc4>
    freeproc(np);
    80002068:	854e                	mv	a0,s3
    8000206a:	00000097          	auipc	ra,0x0
    8000206e:	cc2080e7          	jalr	-830(ra) # 80001d2c <freeproc>
    release(&np->lock);
    80002072:	854e                	mv	a0,s3
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	d8a080e7          	jalr	-630(ra) # 80000dfe <release>
    return -1;
    8000207c:	597d                	li	s2,-1
    8000207e:	a059                	j	80002104 <fork+0x140>
  for (i = 0; i < NOFILE; i++)
    80002080:	04a1                	addi	s1,s1,8
    80002082:	0921                	addi	s2,s2,8
    80002084:	01448b63          	beq	s1,s4,8000209a <fork+0xd6>
    if (p->ofile[i])
    80002088:	6088                	ld	a0,0(s1)
    8000208a:	d97d                	beqz	a0,80002080 <fork+0xbc>
      np->ofile[i] = filedup(p->ofile[i]);
    8000208c:	00003097          	auipc	ra,0x3
    80002090:	ca0080e7          	jalr	-864(ra) # 80004d2c <filedup>
    80002094:	00a93023          	sd	a0,0(s2)
    80002098:	b7e5                	j	80002080 <fork+0xbc>
  np->cwd = idup(p->cwd);
    8000209a:	150ab503          	ld	a0,336(s5)
    8000209e:	00002097          	auipc	ra,0x2
    800020a2:	e0e080e7          	jalr	-498(ra) # 80003eac <idup>
    800020a6:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020aa:	4641                	li	a2,16
    800020ac:	158a8593          	addi	a1,s5,344
    800020b0:	15898513          	addi	a0,s3,344
    800020b4:	fffff097          	auipc	ra,0xfffff
    800020b8:	edc080e7          	jalr	-292(ra) # 80000f90 <safestrcpy>
  pid = np->pid;
    800020bc:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    800020c0:	854e                	mv	a0,s3
    800020c2:	fffff097          	auipc	ra,0xfffff
    800020c6:	d3c080e7          	jalr	-708(ra) # 80000dfe <release>
  acquire(&wait_lock);
    800020ca:	0022f497          	auipc	s1,0x22f
    800020ce:	d6648493          	addi	s1,s1,-666 # 80230e30 <wait_lock>
    800020d2:	8526                	mv	a0,s1
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	c76080e7          	jalr	-906(ra) # 80000d4a <acquire>
  np->parent = p;
    800020dc:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800020e0:	8526                	mv	a0,s1
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	d1c080e7          	jalr	-740(ra) # 80000dfe <release>
  acquire(&np->lock);
    800020ea:	854e                	mv	a0,s3
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	c5e080e7          	jalr	-930(ra) # 80000d4a <acquire>
  np->state = RUNNABLE;
    800020f4:	478d                	li	a5,3
    800020f6:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800020fa:	854e                	mv	a0,s3
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	d02080e7          	jalr	-766(ra) # 80000dfe <release>
}
    80002104:	854a                	mv	a0,s2
    80002106:	70e2                	ld	ra,56(sp)
    80002108:	7442                	ld	s0,48(sp)
    8000210a:	74a2                	ld	s1,40(sp)
    8000210c:	7902                	ld	s2,32(sp)
    8000210e:	69e2                	ld	s3,24(sp)
    80002110:	6a42                	ld	s4,16(sp)
    80002112:	6aa2                	ld	s5,8(sp)
    80002114:	6121                	addi	sp,sp,64
    80002116:	8082                	ret
    return -1;
    80002118:	597d                	li	s2,-1
    8000211a:	b7ed                	j	80002104 <fork+0x140>

000000008000211c <update_time>:
{
    8000211c:	7179                	addi	sp,sp,-48
    8000211e:	f406                	sd	ra,40(sp)
    80002120:	f022                	sd	s0,32(sp)
    80002122:	ec26                	sd	s1,24(sp)
    80002124:	e84a                	sd	s2,16(sp)
    80002126:	e44e                	sd	s3,8(sp)
    80002128:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    8000212a:	0022f497          	auipc	s1,0x22f
    8000212e:	11e48493          	addi	s1,s1,286 # 80231248 <proc>
    if (p->state == RUNNING)
    80002132:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002134:	00236917          	auipc	s2,0x236
    80002138:	31490913          	addi	s2,s2,788 # 80238448 <mlfq>
    8000213c:	a811                	j	80002150 <update_time+0x34>
    release(&p->lock);
    8000213e:	8526                	mv	a0,s1
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	cbe080e7          	jalr	-834(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002148:	1c848493          	addi	s1,s1,456
    8000214c:	03248063          	beq	s1,s2,8000216c <update_time+0x50>
    acquire(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	bf8080e7          	jalr	-1032(ra) # 80000d4a <acquire>
    if (p->state == RUNNING)
    8000215a:	4c9c                	lw	a5,24(s1)
    8000215c:	ff3791e3          	bne	a5,s3,8000213e <update_time+0x22>
      p->rtime++;
    80002160:	1684a783          	lw	a5,360(s1)
    80002164:	2785                	addiw	a5,a5,1
    80002166:	16f4a423          	sw	a5,360(s1)
    8000216a:	bfd1                	j	8000213e <update_time+0x22>
}
    8000216c:	70a2                	ld	ra,40(sp)
    8000216e:	7402                	ld	s0,32(sp)
    80002170:	64e2                	ld	s1,24(sp)
    80002172:	6942                	ld	s2,16(sp)
    80002174:	69a2                	ld	s3,8(sp)
    80002176:	6145                	addi	sp,sp,48
    80002178:	8082                	ret

000000008000217a <scheduler>:
{
    8000217a:	7139                	addi	sp,sp,-64
    8000217c:	fc06                	sd	ra,56(sp)
    8000217e:	f822                	sd	s0,48(sp)
    80002180:	f426                	sd	s1,40(sp)
    80002182:	f04a                	sd	s2,32(sp)
    80002184:	ec4e                	sd	s3,24(sp)
    80002186:	e852                	sd	s4,16(sp)
    80002188:	e456                	sd	s5,8(sp)
    8000218a:	e05a                	sd	s6,0(sp)
    8000218c:	0080                	addi	s0,sp,64
    8000218e:	8792                	mv	a5,tp
  int id = r_tp();
    80002190:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002192:	00779a93          	slli	s5,a5,0x7
    80002196:	0022f717          	auipc	a4,0x22f
    8000219a:	c8270713          	addi	a4,a4,-894 # 80230e18 <pid_lock>
    8000219e:	9756                	add	a4,a4,s5
    800021a0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800021a4:	0022f717          	auipc	a4,0x22f
    800021a8:	cac70713          	addi	a4,a4,-852 # 80230e50 <cpus+0x8>
    800021ac:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    800021ae:	498d                	li	s3,3
        p->state = RUNNING;
    800021b0:	4b11                	li	s6,4
        c->proc = p;
    800021b2:	079e                	slli	a5,a5,0x7
    800021b4:	0022fa17          	auipc	s4,0x22f
    800021b8:	c64a0a13          	addi	s4,s4,-924 # 80230e18 <pid_lock>
    800021bc:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800021be:	00236917          	auipc	s2,0x236
    800021c2:	28a90913          	addi	s2,s2,650 # 80238448 <mlfq>
  asm volatile("csrr %0, sstatus"
    800021c6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800021ca:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    800021ce:	10079073          	csrw	sstatus,a5
    800021d2:	0022f497          	auipc	s1,0x22f
    800021d6:	07648493          	addi	s1,s1,118 # 80231248 <proc>
    800021da:	a811                	j	800021ee <scheduler+0x74>
      release(&p->lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	c20080e7          	jalr	-992(ra) # 80000dfe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800021e6:	1c848493          	addi	s1,s1,456
    800021ea:	fd248ee3          	beq	s1,s2,800021c6 <scheduler+0x4c>
      acquire(&p->lock);
    800021ee:	8526                	mv	a0,s1
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	b5a080e7          	jalr	-1190(ra) # 80000d4a <acquire>
      if (p->state == RUNNABLE)
    800021f8:	4c9c                	lw	a5,24(s1)
    800021fa:	ff3791e3          	bne	a5,s3,800021dc <scheduler+0x62>
        p->state = RUNNING;
    800021fe:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002202:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002206:	06048593          	addi	a1,s1,96
    8000220a:	8556                	mv	a0,s5
    8000220c:	00001097          	auipc	ra,0x1
    80002210:	896080e7          	jalr	-1898(ra) # 80002aa2 <swtch>
        c->proc = 0;
    80002214:	020a3823          	sd	zero,48(s4)
    80002218:	b7d1                	j	800021dc <scheduler+0x62>

000000008000221a <sched>:
{
    8000221a:	7179                	addi	sp,sp,-48
    8000221c:	f406                	sd	ra,40(sp)
    8000221e:	f022                	sd	s0,32(sp)
    80002220:	ec26                	sd	s1,24(sp)
    80002222:	e84a                	sd	s2,16(sp)
    80002224:	e44e                	sd	s3,8(sp)
    80002226:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002228:	00000097          	auipc	ra,0x0
    8000222c:	952080e7          	jalr	-1710(ra) # 80001b7a <myproc>
    80002230:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	a9e080e7          	jalr	-1378(ra) # 80000cd0 <holding>
    8000223a:	c93d                	beqz	a0,800022b0 <sched+0x96>
  asm volatile("mv %0, tp"
    8000223c:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000223e:	2781                	sext.w	a5,a5
    80002240:	079e                	slli	a5,a5,0x7
    80002242:	0022f717          	auipc	a4,0x22f
    80002246:	bd670713          	addi	a4,a4,-1066 # 80230e18 <pid_lock>
    8000224a:	97ba                	add	a5,a5,a4
    8000224c:	0a87a703          	lw	a4,168(a5)
    80002250:	4785                	li	a5,1
    80002252:	06f71763          	bne	a4,a5,800022c0 <sched+0xa6>
  if (p->state == RUNNING)
    80002256:	4c98                	lw	a4,24(s1)
    80002258:	4791                	li	a5,4
    8000225a:	06f70b63          	beq	a4,a5,800022d0 <sched+0xb6>
  asm volatile("csrr %0, sstatus"
    8000225e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002262:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002264:	efb5                	bnez	a5,800022e0 <sched+0xc6>
  asm volatile("mv %0, tp"
    80002266:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002268:	0022f917          	auipc	s2,0x22f
    8000226c:	bb090913          	addi	s2,s2,-1104 # 80230e18 <pid_lock>
    80002270:	2781                	sext.w	a5,a5
    80002272:	079e                	slli	a5,a5,0x7
    80002274:	97ca                	add	a5,a5,s2
    80002276:	0ac7a983          	lw	s3,172(a5)
    8000227a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000227c:	2781                	sext.w	a5,a5
    8000227e:	079e                	slli	a5,a5,0x7
    80002280:	0022f597          	auipc	a1,0x22f
    80002284:	bd058593          	addi	a1,a1,-1072 # 80230e50 <cpus+0x8>
    80002288:	95be                	add	a1,a1,a5
    8000228a:	06048513          	addi	a0,s1,96
    8000228e:	00001097          	auipc	ra,0x1
    80002292:	814080e7          	jalr	-2028(ra) # 80002aa2 <swtch>
    80002296:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002298:	2781                	sext.w	a5,a5
    8000229a:	079e                	slli	a5,a5,0x7
    8000229c:	993e                	add	s2,s2,a5
    8000229e:	0b392623          	sw	s3,172(s2)
}
    800022a2:	70a2                	ld	ra,40(sp)
    800022a4:	7402                	ld	s0,32(sp)
    800022a6:	64e2                	ld	s1,24(sp)
    800022a8:	6942                	ld	s2,16(sp)
    800022aa:	69a2                	ld	s3,8(sp)
    800022ac:	6145                	addi	sp,sp,48
    800022ae:	8082                	ret
    panic("sched p->lock");
    800022b0:	00006517          	auipc	a0,0x6
    800022b4:	fa850513          	addi	a0,a0,-88 # 80008258 <digits+0x218>
    800022b8:	ffffe097          	auipc	ra,0xffffe
    800022bc:	288080e7          	jalr	648(ra) # 80000540 <panic>
    panic("sched locks");
    800022c0:	00006517          	auipc	a0,0x6
    800022c4:	fa850513          	addi	a0,a0,-88 # 80008268 <digits+0x228>
    800022c8:	ffffe097          	auipc	ra,0xffffe
    800022cc:	278080e7          	jalr	632(ra) # 80000540 <panic>
    panic("sched running");
    800022d0:	00006517          	auipc	a0,0x6
    800022d4:	fa850513          	addi	a0,a0,-88 # 80008278 <digits+0x238>
    800022d8:	ffffe097          	auipc	ra,0xffffe
    800022dc:	268080e7          	jalr	616(ra) # 80000540 <panic>
    panic("sched interruptible");
    800022e0:	00006517          	auipc	a0,0x6
    800022e4:	fa850513          	addi	a0,a0,-88 # 80008288 <digits+0x248>
    800022e8:	ffffe097          	auipc	ra,0xffffe
    800022ec:	258080e7          	jalr	600(ra) # 80000540 <panic>

00000000800022f0 <yield>:
{
    800022f0:	1101                	addi	sp,sp,-32
    800022f2:	ec06                	sd	ra,24(sp)
    800022f4:	e822                	sd	s0,16(sp)
    800022f6:	e426                	sd	s1,8(sp)
    800022f8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022fa:	00000097          	auipc	ra,0x0
    800022fe:	880080e7          	jalr	-1920(ra) # 80001b7a <myproc>
    80002302:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	a46080e7          	jalr	-1466(ra) # 80000d4a <acquire>
  p->state = RUNNABLE;
    8000230c:	478d                	li	a5,3
    8000230e:	cc9c                	sw	a5,24(s1)
  sched();
    80002310:	00000097          	auipc	ra,0x0
    80002314:	f0a080e7          	jalr	-246(ra) # 8000221a <sched>
  release(&p->lock);
    80002318:	8526                	mv	a0,s1
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	ae4080e7          	jalr	-1308(ra) # 80000dfe <release>
}
    80002322:	60e2                	ld	ra,24(sp)
    80002324:	6442                	ld	s0,16(sp)
    80002326:	64a2                	ld	s1,8(sp)
    80002328:	6105                	addi	sp,sp,32
    8000232a:	8082                	ret

000000008000232c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000232c:	7179                	addi	sp,sp,-48
    8000232e:	f406                	sd	ra,40(sp)
    80002330:	f022                	sd	s0,32(sp)
    80002332:	ec26                	sd	s1,24(sp)
    80002334:	e84a                	sd	s2,16(sp)
    80002336:	e44e                	sd	s3,8(sp)
    80002338:	1800                	addi	s0,sp,48
    8000233a:	89aa                	mv	s3,a0
    8000233c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000233e:	00000097          	auipc	ra,0x0
    80002342:	83c080e7          	jalr	-1988(ra) # 80001b7a <myproc>
    80002346:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	a02080e7          	jalr	-1534(ra) # 80000d4a <acquire>
  release(lk);
    80002350:	854a                	mv	a0,s2
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	aac080e7          	jalr	-1364(ra) # 80000dfe <release>

  // Go to sleep.
  p->sleep_start = ticks;
    8000235a:	00007797          	auipc	a5,0x7
    8000235e:	83e7a783          	lw	a5,-1986(a5) # 80008b98 <ticks>
    80002362:	18f4a223          	sw	a5,388(s1)
  p->chan = chan;
    80002366:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000236a:	4789                	li	a5,2
    8000236c:	cc9c                	sw	a5,24(s1)

  sched();
    8000236e:	00000097          	auipc	ra,0x0
    80002372:	eac080e7          	jalr	-340(ra) # 8000221a <sched>

  // Tidy up.
  p->chan = 0;
    80002376:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	a82080e7          	jalr	-1406(ra) # 80000dfe <release>
  acquire(lk);
    80002384:	854a                	mv	a0,s2
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	9c4080e7          	jalr	-1596(ra) # 80000d4a <acquire>
}
    8000238e:	70a2                	ld	ra,40(sp)
    80002390:	7402                	ld	s0,32(sp)
    80002392:	64e2                	ld	s1,24(sp)
    80002394:	6942                	ld	s2,16(sp)
    80002396:	69a2                	ld	s3,8(sp)
    80002398:	6145                	addi	sp,sp,48
    8000239a:	8082                	ret

000000008000239c <waitx>:
{
    8000239c:	711d                	addi	sp,sp,-96
    8000239e:	ec86                	sd	ra,88(sp)
    800023a0:	e8a2                	sd	s0,80(sp)
    800023a2:	e4a6                	sd	s1,72(sp)
    800023a4:	e0ca                	sd	s2,64(sp)
    800023a6:	fc4e                	sd	s3,56(sp)
    800023a8:	f852                	sd	s4,48(sp)
    800023aa:	f456                	sd	s5,40(sp)
    800023ac:	f05a                	sd	s6,32(sp)
    800023ae:	ec5e                	sd	s7,24(sp)
    800023b0:	e862                	sd	s8,16(sp)
    800023b2:	e466                	sd	s9,8(sp)
    800023b4:	e06a                	sd	s10,0(sp)
    800023b6:	1080                	addi	s0,sp,96
    800023b8:	8b2a                	mv	s6,a0
    800023ba:	8bae                	mv	s7,a1
    800023bc:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	7bc080e7          	jalr	1980(ra) # 80001b7a <myproc>
    800023c6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023c8:	0022f517          	auipc	a0,0x22f
    800023cc:	a6850513          	addi	a0,a0,-1432 # 80230e30 <wait_lock>
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	97a080e7          	jalr	-1670(ra) # 80000d4a <acquire>
    havekids = 0;
    800023d8:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    800023da:	4a15                	li	s4,5
        havekids = 1;
    800023dc:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800023de:	00236997          	auipc	s3,0x236
    800023e2:	06a98993          	addi	s3,s3,106 # 80238448 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800023e6:	0022fd17          	auipc	s10,0x22f
    800023ea:	a4ad0d13          	addi	s10,s10,-1462 # 80230e30 <wait_lock>
    havekids = 0;
    800023ee:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800023f0:	0022f497          	auipc	s1,0x22f
    800023f4:	e5848493          	addi	s1,s1,-424 # 80231248 <proc>
    800023f8:	a059                	j	8000247e <waitx+0xe2>
          pid = np->pid;
    800023fa:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800023fe:	1684a783          	lw	a5,360(s1)
    80002402:	00fc2023          	sw	a5,0(s8) # 1000 <_entry-0x7ffff000>
          *wtime = np->etime - np->ctime - np->rtime;
    80002406:	16c4a703          	lw	a4,364(s1)
    8000240a:	9f3d                	addw	a4,a4,a5
    8000240c:	1704a783          	lw	a5,368(s1)
    80002410:	9f99                	subw	a5,a5,a4
    80002412:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7fdb9a30>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002416:	000b0e63          	beqz	s6,80002432 <waitx+0x96>
    8000241a:	4691                	li	a3,4
    8000241c:	02c48613          	addi	a2,s1,44
    80002420:	85da                	mv	a1,s6
    80002422:	05093503          	ld	a0,80(s2)
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	3d8080e7          	jalr	984(ra) # 800017fe <copyout>
    8000242e:	02054563          	bltz	a0,80002458 <waitx+0xbc>
          freeproc(np);
    80002432:	8526                	mv	a0,s1
    80002434:	00000097          	auipc	ra,0x0
    80002438:	8f8080e7          	jalr	-1800(ra) # 80001d2c <freeproc>
          release(&np->lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	9c0080e7          	jalr	-1600(ra) # 80000dfe <release>
          release(&wait_lock);
    80002446:	0022f517          	auipc	a0,0x22f
    8000244a:	9ea50513          	addi	a0,a0,-1558 # 80230e30 <wait_lock>
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	9b0080e7          	jalr	-1616(ra) # 80000dfe <release>
          return pid;
    80002456:	a09d                	j	800024bc <waitx+0x120>
            release(&np->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	9a4080e7          	jalr	-1628(ra) # 80000dfe <release>
            release(&wait_lock);
    80002462:	0022f517          	auipc	a0,0x22f
    80002466:	9ce50513          	addi	a0,a0,-1586 # 80230e30 <wait_lock>
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	994080e7          	jalr	-1644(ra) # 80000dfe <release>
            return -1;
    80002472:	59fd                	li	s3,-1
    80002474:	a0a1                	j	800024bc <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002476:	1c848493          	addi	s1,s1,456
    8000247a:	03348463          	beq	s1,s3,800024a2 <waitx+0x106>
      if (np->parent == p)
    8000247e:	7c9c                	ld	a5,56(s1)
    80002480:	ff279be3          	bne	a5,s2,80002476 <waitx+0xda>
        acquire(&np->lock);
    80002484:	8526                	mv	a0,s1
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	8c4080e7          	jalr	-1852(ra) # 80000d4a <acquire>
        if (np->state == ZOMBIE)
    8000248e:	4c9c                	lw	a5,24(s1)
    80002490:	f74785e3          	beq	a5,s4,800023fa <waitx+0x5e>
        release(&np->lock);
    80002494:	8526                	mv	a0,s1
    80002496:	fffff097          	auipc	ra,0xfffff
    8000249a:	968080e7          	jalr	-1688(ra) # 80000dfe <release>
        havekids = 1;
    8000249e:	8756                	mv	a4,s5
    800024a0:	bfd9                	j	80002476 <waitx+0xda>
    if (!havekids || p->killed)
    800024a2:	c701                	beqz	a4,800024aa <waitx+0x10e>
    800024a4:	02892783          	lw	a5,40(s2)
    800024a8:	cb8d                	beqz	a5,800024da <waitx+0x13e>
      release(&wait_lock);
    800024aa:	0022f517          	auipc	a0,0x22f
    800024ae:	98650513          	addi	a0,a0,-1658 # 80230e30 <wait_lock>
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	94c080e7          	jalr	-1716(ra) # 80000dfe <release>
      return -1;
    800024ba:	59fd                	li	s3,-1
}
    800024bc:	854e                	mv	a0,s3
    800024be:	60e6                	ld	ra,88(sp)
    800024c0:	6446                	ld	s0,80(sp)
    800024c2:	64a6                	ld	s1,72(sp)
    800024c4:	6906                	ld	s2,64(sp)
    800024c6:	79e2                	ld	s3,56(sp)
    800024c8:	7a42                	ld	s4,48(sp)
    800024ca:	7aa2                	ld	s5,40(sp)
    800024cc:	7b02                	ld	s6,32(sp)
    800024ce:	6be2                	ld	s7,24(sp)
    800024d0:	6c42                	ld	s8,16(sp)
    800024d2:	6ca2                	ld	s9,8(sp)
    800024d4:	6d02                	ld	s10,0(sp)
    800024d6:	6125                	addi	sp,sp,96
    800024d8:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024da:	85ea                	mv	a1,s10
    800024dc:	854a                	mv	a0,s2
    800024de:	00000097          	auipc	ra,0x0
    800024e2:	e4e080e7          	jalr	-434(ra) # 8000232c <sleep>
    havekids = 0;
    800024e6:	b721                	j	800023ee <waitx+0x52>

00000000800024e8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800024e8:	7139                	addi	sp,sp,-64
    800024ea:	fc06                	sd	ra,56(sp)
    800024ec:	f822                	sd	s0,48(sp)
    800024ee:	f426                	sd	s1,40(sp)
    800024f0:	f04a                	sd	s2,32(sp)
    800024f2:	ec4e                	sd	s3,24(sp)
    800024f4:	e852                	sd	s4,16(sp)
    800024f6:	e456                	sd	s5,8(sp)
    800024f8:	e05a                	sd	s6,0(sp)
    800024fa:	0080                	addi	s0,sp,64
    800024fc:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800024fe:	0022f497          	auipc	s1,0x22f
    80002502:	d4a48493          	addi	s1,s1,-694 # 80231248 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002506:	4989                	li	s3,2
      {
        p->sleeping_ticks += (ticks - p->sleep_start);
    80002508:	00006b17          	auipc	s6,0x6
    8000250c:	690b0b13          	addi	s6,s6,1680 # 80008b98 <ticks>
        p->state = RUNNABLE;
    80002510:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002512:	00236917          	auipc	s2,0x236
    80002516:	f3690913          	addi	s2,s2,-202 # 80238448 <mlfq>
    8000251a:	a811                	j	8000252e <wakeup+0x46>
      }
      release(&p->lock);
    8000251c:	8526                	mv	a0,s1
    8000251e:	fffff097          	auipc	ra,0xfffff
    80002522:	8e0080e7          	jalr	-1824(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002526:	1c848493          	addi	s1,s1,456
    8000252a:	05248063          	beq	s1,s2,8000256a <wakeup+0x82>
    if (p != myproc())
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	64c080e7          	jalr	1612(ra) # 80001b7a <myproc>
    80002536:	fea488e3          	beq	s1,a0,80002526 <wakeup+0x3e>
      acquire(&p->lock);
    8000253a:	8526                	mv	a0,s1
    8000253c:	fffff097          	auipc	ra,0xfffff
    80002540:	80e080e7          	jalr	-2034(ra) # 80000d4a <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002544:	4c9c                	lw	a5,24(s1)
    80002546:	fd379be3          	bne	a5,s3,8000251c <wakeup+0x34>
    8000254a:	709c                	ld	a5,32(s1)
    8000254c:	fd4798e3          	bne	a5,s4,8000251c <wakeup+0x34>
        p->sleeping_ticks += (ticks - p->sleep_start);
    80002550:	18c4a703          	lw	a4,396(s1)
    80002554:	000b2783          	lw	a5,0(s6)
    80002558:	9fb9                	addw	a5,a5,a4
    8000255a:	1844a703          	lw	a4,388(s1)
    8000255e:	9f99                	subw	a5,a5,a4
    80002560:	18f4a623          	sw	a5,396(s1)
        p->state = RUNNABLE;
    80002564:	0154ac23          	sw	s5,24(s1)
    80002568:	bf55                	j	8000251c <wakeup+0x34>
    }
  }
}
    8000256a:	70e2                	ld	ra,56(sp)
    8000256c:	7442                	ld	s0,48(sp)
    8000256e:	74a2                	ld	s1,40(sp)
    80002570:	7902                	ld	s2,32(sp)
    80002572:	69e2                	ld	s3,24(sp)
    80002574:	6a42                	ld	s4,16(sp)
    80002576:	6aa2                	ld	s5,8(sp)
    80002578:	6b02                	ld	s6,0(sp)
    8000257a:	6121                	addi	sp,sp,64
    8000257c:	8082                	ret

000000008000257e <reparent>:
{
    8000257e:	7179                	addi	sp,sp,-48
    80002580:	f406                	sd	ra,40(sp)
    80002582:	f022                	sd	s0,32(sp)
    80002584:	ec26                	sd	s1,24(sp)
    80002586:	e84a                	sd	s2,16(sp)
    80002588:	e44e                	sd	s3,8(sp)
    8000258a:	e052                	sd	s4,0(sp)
    8000258c:	1800                	addi	s0,sp,48
    8000258e:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002590:	0022f497          	auipc	s1,0x22f
    80002594:	cb848493          	addi	s1,s1,-840 # 80231248 <proc>
      pp->parent = initproc;
    80002598:	00006a17          	auipc	s4,0x6
    8000259c:	5f8a0a13          	addi	s4,s4,1528 # 80008b90 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800025a0:	00236997          	auipc	s3,0x236
    800025a4:	ea898993          	addi	s3,s3,-344 # 80238448 <mlfq>
    800025a8:	a029                	j	800025b2 <reparent+0x34>
    800025aa:	1c848493          	addi	s1,s1,456
    800025ae:	01348d63          	beq	s1,s3,800025c8 <reparent+0x4a>
    if (pp->parent == p)
    800025b2:	7c9c                	ld	a5,56(s1)
    800025b4:	ff279be3          	bne	a5,s2,800025aa <reparent+0x2c>
      pp->parent = initproc;
    800025b8:	000a3503          	ld	a0,0(s4)
    800025bc:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800025be:	00000097          	auipc	ra,0x0
    800025c2:	f2a080e7          	jalr	-214(ra) # 800024e8 <wakeup>
    800025c6:	b7d5                	j	800025aa <reparent+0x2c>
}
    800025c8:	70a2                	ld	ra,40(sp)
    800025ca:	7402                	ld	s0,32(sp)
    800025cc:	64e2                	ld	s1,24(sp)
    800025ce:	6942                	ld	s2,16(sp)
    800025d0:	69a2                	ld	s3,8(sp)
    800025d2:	6a02                	ld	s4,0(sp)
    800025d4:	6145                	addi	sp,sp,48
    800025d6:	8082                	ret

00000000800025d8 <exit>:
{
    800025d8:	7179                	addi	sp,sp,-48
    800025da:	f406                	sd	ra,40(sp)
    800025dc:	f022                	sd	s0,32(sp)
    800025de:	ec26                	sd	s1,24(sp)
    800025e0:	e84a                	sd	s2,16(sp)
    800025e2:	e44e                	sd	s3,8(sp)
    800025e4:	e052                	sd	s4,0(sp)
    800025e6:	1800                	addi	s0,sp,48
    800025e8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025ea:	fffff097          	auipc	ra,0xfffff
    800025ee:	590080e7          	jalr	1424(ra) # 80001b7a <myproc>
    800025f2:	89aa                	mv	s3,a0
  if (p == initproc)
    800025f4:	00006797          	auipc	a5,0x6
    800025f8:	59c7b783          	ld	a5,1436(a5) # 80008b90 <initproc>
    800025fc:	0d050493          	addi	s1,a0,208
    80002600:	15050913          	addi	s2,a0,336
    80002604:	02a79363          	bne	a5,a0,8000262a <exit+0x52>
    panic("init exiting");
    80002608:	00006517          	auipc	a0,0x6
    8000260c:	c9850513          	addi	a0,a0,-872 # 800082a0 <digits+0x260>
    80002610:	ffffe097          	auipc	ra,0xffffe
    80002614:	f30080e7          	jalr	-208(ra) # 80000540 <panic>
      fileclose(f);
    80002618:	00002097          	auipc	ra,0x2
    8000261c:	766080e7          	jalr	1894(ra) # 80004d7e <fileclose>
      p->ofile[fd] = 0;
    80002620:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002624:	04a1                	addi	s1,s1,8
    80002626:	01248563          	beq	s1,s2,80002630 <exit+0x58>
    if (p->ofile[fd])
    8000262a:	6088                	ld	a0,0(s1)
    8000262c:	f575                	bnez	a0,80002618 <exit+0x40>
    8000262e:	bfdd                	j	80002624 <exit+0x4c>
  begin_op();
    80002630:	00002097          	auipc	ra,0x2
    80002634:	286080e7          	jalr	646(ra) # 800048b6 <begin_op>
  iput(p->cwd);
    80002638:	1509b503          	ld	a0,336(s3)
    8000263c:	00002097          	auipc	ra,0x2
    80002640:	a68080e7          	jalr	-1432(ra) # 800040a4 <iput>
  end_op();
    80002644:	00002097          	auipc	ra,0x2
    80002648:	2f0080e7          	jalr	752(ra) # 80004934 <end_op>
  p->cwd = 0;
    8000264c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002650:	0022e497          	auipc	s1,0x22e
    80002654:	7e048493          	addi	s1,s1,2016 # 80230e30 <wait_lock>
    80002658:	8526                	mv	a0,s1
    8000265a:	ffffe097          	auipc	ra,0xffffe
    8000265e:	6f0080e7          	jalr	1776(ra) # 80000d4a <acquire>
  reparent(p);
    80002662:	854e                	mv	a0,s3
    80002664:	00000097          	auipc	ra,0x0
    80002668:	f1a080e7          	jalr	-230(ra) # 8000257e <reparent>
  wakeup(p->parent);
    8000266c:	0389b503          	ld	a0,56(s3)
    80002670:	00000097          	auipc	ra,0x0
    80002674:	e78080e7          	jalr	-392(ra) # 800024e8 <wakeup>
  acquire(&p->lock);
    80002678:	854e                	mv	a0,s3
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	6d0080e7          	jalr	1744(ra) # 80000d4a <acquire>
  p->xstate = status;
    80002682:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002686:	4795                	li	a5,5
    80002688:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000268c:	00006797          	auipc	a5,0x6
    80002690:	50c7a783          	lw	a5,1292(a5) # 80008b98 <ticks>
    80002694:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    80002698:	8526                	mv	a0,s1
    8000269a:	ffffe097          	auipc	ra,0xffffe
    8000269e:	764080e7          	jalr	1892(ra) # 80000dfe <release>
  sched();
    800026a2:	00000097          	auipc	ra,0x0
    800026a6:	b78080e7          	jalr	-1160(ra) # 8000221a <sched>
  panic("zombie exit");
    800026aa:	00006517          	auipc	a0,0x6
    800026ae:	c0650513          	addi	a0,a0,-1018 # 800082b0 <digits+0x270>
    800026b2:	ffffe097          	auipc	ra,0xffffe
    800026b6:	e8e080e7          	jalr	-370(ra) # 80000540 <panic>

00000000800026ba <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800026ba:	7179                	addi	sp,sp,-48
    800026bc:	f406                	sd	ra,40(sp)
    800026be:	f022                	sd	s0,32(sp)
    800026c0:	ec26                	sd	s1,24(sp)
    800026c2:	e84a                	sd	s2,16(sp)
    800026c4:	e44e                	sd	s3,8(sp)
    800026c6:	1800                	addi	s0,sp,48
    800026c8:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800026ca:	0022f497          	auipc	s1,0x22f
    800026ce:	b7e48493          	addi	s1,s1,-1154 # 80231248 <proc>
    800026d2:	00236997          	auipc	s3,0x236
    800026d6:	d7698993          	addi	s3,s3,-650 # 80238448 <mlfq>
  {
    acquire(&p->lock);
    800026da:	8526                	mv	a0,s1
    800026dc:	ffffe097          	auipc	ra,0xffffe
    800026e0:	66e080e7          	jalr	1646(ra) # 80000d4a <acquire>
    if (p->pid == pid)
    800026e4:	589c                	lw	a5,48(s1)
    800026e6:	01278d63          	beq	a5,s2,80002700 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	712080e7          	jalr	1810(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800026f4:	1c848493          	addi	s1,s1,456
    800026f8:	ff3491e3          	bne	s1,s3,800026da <kill+0x20>
  }
  return -1;
    800026fc:	557d                	li	a0,-1
    800026fe:	a829                	j	80002718 <kill+0x5e>
      p->killed = 1;
    80002700:	4785                	li	a5,1
    80002702:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002704:	4c98                	lw	a4,24(s1)
    80002706:	4789                	li	a5,2
    80002708:	00f70f63          	beq	a4,a5,80002726 <kill+0x6c>
      release(&p->lock);
    8000270c:	8526                	mv	a0,s1
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	6f0080e7          	jalr	1776(ra) # 80000dfe <release>
      return 0;
    80002716:	4501                	li	a0,0
}
    80002718:	70a2                	ld	ra,40(sp)
    8000271a:	7402                	ld	s0,32(sp)
    8000271c:	64e2                	ld	s1,24(sp)
    8000271e:	6942                	ld	s2,16(sp)
    80002720:	69a2                	ld	s3,8(sp)
    80002722:	6145                	addi	sp,sp,48
    80002724:	8082                	ret
        p->state = RUNNABLE;
    80002726:	478d                	li	a5,3
    80002728:	cc9c                	sw	a5,24(s1)
    8000272a:	b7cd                	j	8000270c <kill+0x52>

000000008000272c <setkilled>:

void setkilled(struct proc *p)
{
    8000272c:	1101                	addi	sp,sp,-32
    8000272e:	ec06                	sd	ra,24(sp)
    80002730:	e822                	sd	s0,16(sp)
    80002732:	e426                	sd	s1,8(sp)
    80002734:	1000                	addi	s0,sp,32
    80002736:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	612080e7          	jalr	1554(ra) # 80000d4a <acquire>
  p->killed = 1;
    80002740:	4785                	li	a5,1
    80002742:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002744:	8526                	mv	a0,s1
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	6b8080e7          	jalr	1720(ra) # 80000dfe <release>
}
    8000274e:	60e2                	ld	ra,24(sp)
    80002750:	6442                	ld	s0,16(sp)
    80002752:	64a2                	ld	s1,8(sp)
    80002754:	6105                	addi	sp,sp,32
    80002756:	8082                	ret

0000000080002758 <killed>:

int killed(struct proc *p)
{
    80002758:	1101                	addi	sp,sp,-32
    8000275a:	ec06                	sd	ra,24(sp)
    8000275c:	e822                	sd	s0,16(sp)
    8000275e:	e426                	sd	s1,8(sp)
    80002760:	e04a                	sd	s2,0(sp)
    80002762:	1000                	addi	s0,sp,32
    80002764:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	5e4080e7          	jalr	1508(ra) # 80000d4a <acquire>
  k = p->killed;
    8000276e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002772:	8526                	mv	a0,s1
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	68a080e7          	jalr	1674(ra) # 80000dfe <release>
  return k;
}
    8000277c:	854a                	mv	a0,s2
    8000277e:	60e2                	ld	ra,24(sp)
    80002780:	6442                	ld	s0,16(sp)
    80002782:	64a2                	ld	s1,8(sp)
    80002784:	6902                	ld	s2,0(sp)
    80002786:	6105                	addi	sp,sp,32
    80002788:	8082                	ret

000000008000278a <wait>:
{
    8000278a:	715d                	addi	sp,sp,-80
    8000278c:	e486                	sd	ra,72(sp)
    8000278e:	e0a2                	sd	s0,64(sp)
    80002790:	fc26                	sd	s1,56(sp)
    80002792:	f84a                	sd	s2,48(sp)
    80002794:	f44e                	sd	s3,40(sp)
    80002796:	f052                	sd	s4,32(sp)
    80002798:	ec56                	sd	s5,24(sp)
    8000279a:	e85a                	sd	s6,16(sp)
    8000279c:	e45e                	sd	s7,8(sp)
    8000279e:	e062                	sd	s8,0(sp)
    800027a0:	0880                	addi	s0,sp,80
    800027a2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800027a4:	fffff097          	auipc	ra,0xfffff
    800027a8:	3d6080e7          	jalr	982(ra) # 80001b7a <myproc>
    800027ac:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800027ae:	0022e517          	auipc	a0,0x22e
    800027b2:	68250513          	addi	a0,a0,1666 # 80230e30 <wait_lock>
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	594080e7          	jalr	1428(ra) # 80000d4a <acquire>
    havekids = 0;
    800027be:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800027c0:	4a15                	li	s4,5
        havekids = 1;
    800027c2:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027c4:	00236997          	auipc	s3,0x236
    800027c8:	c8498993          	addi	s3,s3,-892 # 80238448 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027cc:	0022ec17          	auipc	s8,0x22e
    800027d0:	664c0c13          	addi	s8,s8,1636 # 80230e30 <wait_lock>
    havekids = 0;
    800027d4:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027d6:	0022f497          	auipc	s1,0x22f
    800027da:	a7248493          	addi	s1,s1,-1422 # 80231248 <proc>
    800027de:	a0bd                	j	8000284c <wait+0xc2>
          pid = pp->pid;
    800027e0:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800027e4:	000b0e63          	beqz	s6,80002800 <wait+0x76>
    800027e8:	4691                	li	a3,4
    800027ea:	02c48613          	addi	a2,s1,44
    800027ee:	85da                	mv	a1,s6
    800027f0:	05093503          	ld	a0,80(s2)
    800027f4:	fffff097          	auipc	ra,0xfffff
    800027f8:	00a080e7          	jalr	10(ra) # 800017fe <copyout>
    800027fc:	02054563          	bltz	a0,80002826 <wait+0x9c>
          freeproc(pp);
    80002800:	8526                	mv	a0,s1
    80002802:	fffff097          	auipc	ra,0xfffff
    80002806:	52a080e7          	jalr	1322(ra) # 80001d2c <freeproc>
          release(&pp->lock);
    8000280a:	8526                	mv	a0,s1
    8000280c:	ffffe097          	auipc	ra,0xffffe
    80002810:	5f2080e7          	jalr	1522(ra) # 80000dfe <release>
          release(&wait_lock);
    80002814:	0022e517          	auipc	a0,0x22e
    80002818:	61c50513          	addi	a0,a0,1564 # 80230e30 <wait_lock>
    8000281c:	ffffe097          	auipc	ra,0xffffe
    80002820:	5e2080e7          	jalr	1506(ra) # 80000dfe <release>
          return pid;
    80002824:	a0b5                	j	80002890 <wait+0x106>
            release(&pp->lock);
    80002826:	8526                	mv	a0,s1
    80002828:	ffffe097          	auipc	ra,0xffffe
    8000282c:	5d6080e7          	jalr	1494(ra) # 80000dfe <release>
            release(&wait_lock);
    80002830:	0022e517          	auipc	a0,0x22e
    80002834:	60050513          	addi	a0,a0,1536 # 80230e30 <wait_lock>
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	5c6080e7          	jalr	1478(ra) # 80000dfe <release>
            return -1;
    80002840:	59fd                	li	s3,-1
    80002842:	a0b9                	j	80002890 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002844:	1c848493          	addi	s1,s1,456
    80002848:	03348463          	beq	s1,s3,80002870 <wait+0xe6>
      if (pp->parent == p)
    8000284c:	7c9c                	ld	a5,56(s1)
    8000284e:	ff279be3          	bne	a5,s2,80002844 <wait+0xba>
        acquire(&pp->lock);
    80002852:	8526                	mv	a0,s1
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	4f6080e7          	jalr	1270(ra) # 80000d4a <acquire>
        if (pp->state == ZOMBIE)
    8000285c:	4c9c                	lw	a5,24(s1)
    8000285e:	f94781e3          	beq	a5,s4,800027e0 <wait+0x56>
        release(&pp->lock);
    80002862:	8526                	mv	a0,s1
    80002864:	ffffe097          	auipc	ra,0xffffe
    80002868:	59a080e7          	jalr	1434(ra) # 80000dfe <release>
        havekids = 1;
    8000286c:	8756                	mv	a4,s5
    8000286e:	bfd9                	j	80002844 <wait+0xba>
    if (!havekids || killed(p))
    80002870:	c719                	beqz	a4,8000287e <wait+0xf4>
    80002872:	854a                	mv	a0,s2
    80002874:	00000097          	auipc	ra,0x0
    80002878:	ee4080e7          	jalr	-284(ra) # 80002758 <killed>
    8000287c:	c51d                	beqz	a0,800028aa <wait+0x120>
      release(&wait_lock);
    8000287e:	0022e517          	auipc	a0,0x22e
    80002882:	5b250513          	addi	a0,a0,1458 # 80230e30 <wait_lock>
    80002886:	ffffe097          	auipc	ra,0xffffe
    8000288a:	578080e7          	jalr	1400(ra) # 80000dfe <release>
      return -1;
    8000288e:	59fd                	li	s3,-1
}
    80002890:	854e                	mv	a0,s3
    80002892:	60a6                	ld	ra,72(sp)
    80002894:	6406                	ld	s0,64(sp)
    80002896:	74e2                	ld	s1,56(sp)
    80002898:	7942                	ld	s2,48(sp)
    8000289a:	79a2                	ld	s3,40(sp)
    8000289c:	7a02                	ld	s4,32(sp)
    8000289e:	6ae2                	ld	s5,24(sp)
    800028a0:	6b42                	ld	s6,16(sp)
    800028a2:	6ba2                	ld	s7,8(sp)
    800028a4:	6c02                	ld	s8,0(sp)
    800028a6:	6161                	addi	sp,sp,80
    800028a8:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800028aa:	85e2                	mv	a1,s8
    800028ac:	854a                	mv	a0,s2
    800028ae:	00000097          	auipc	ra,0x0
    800028b2:	a7e080e7          	jalr	-1410(ra) # 8000232c <sleep>
    havekids = 0;
    800028b6:	bf39                	j	800027d4 <wait+0x4a>

00000000800028b8 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028b8:	7179                	addi	sp,sp,-48
    800028ba:	f406                	sd	ra,40(sp)
    800028bc:	f022                	sd	s0,32(sp)
    800028be:	ec26                	sd	s1,24(sp)
    800028c0:	e84a                	sd	s2,16(sp)
    800028c2:	e44e                	sd	s3,8(sp)
    800028c4:	e052                	sd	s4,0(sp)
    800028c6:	1800                	addi	s0,sp,48
    800028c8:	84aa                	mv	s1,a0
    800028ca:	892e                	mv	s2,a1
    800028cc:	89b2                	mv	s3,a2
    800028ce:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028d0:	fffff097          	auipc	ra,0xfffff
    800028d4:	2aa080e7          	jalr	682(ra) # 80001b7a <myproc>
  if (user_dst)
    800028d8:	c08d                	beqz	s1,800028fa <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800028da:	86d2                	mv	a3,s4
    800028dc:	864e                	mv	a2,s3
    800028de:	85ca                	mv	a1,s2
    800028e0:	6928                	ld	a0,80(a0)
    800028e2:	fffff097          	auipc	ra,0xfffff
    800028e6:	f1c080e7          	jalr	-228(ra) # 800017fe <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028ea:	70a2                	ld	ra,40(sp)
    800028ec:	7402                	ld	s0,32(sp)
    800028ee:	64e2                	ld	s1,24(sp)
    800028f0:	6942                	ld	s2,16(sp)
    800028f2:	69a2                	ld	s3,8(sp)
    800028f4:	6a02                	ld	s4,0(sp)
    800028f6:	6145                	addi	sp,sp,48
    800028f8:	8082                	ret
    memmove((char *)dst, src, len);
    800028fa:	000a061b          	sext.w	a2,s4
    800028fe:	85ce                	mv	a1,s3
    80002900:	854a                	mv	a0,s2
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	5a0080e7          	jalr	1440(ra) # 80000ea2 <memmove>
    return 0;
    8000290a:	8526                	mv	a0,s1
    8000290c:	bff9                	j	800028ea <either_copyout+0x32>

000000008000290e <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000290e:	7179                	addi	sp,sp,-48
    80002910:	f406                	sd	ra,40(sp)
    80002912:	f022                	sd	s0,32(sp)
    80002914:	ec26                	sd	s1,24(sp)
    80002916:	e84a                	sd	s2,16(sp)
    80002918:	e44e                	sd	s3,8(sp)
    8000291a:	e052                	sd	s4,0(sp)
    8000291c:	1800                	addi	s0,sp,48
    8000291e:	892a                	mv	s2,a0
    80002920:	84ae                	mv	s1,a1
    80002922:	89b2                	mv	s3,a2
    80002924:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002926:	fffff097          	auipc	ra,0xfffff
    8000292a:	254080e7          	jalr	596(ra) # 80001b7a <myproc>
  if (user_src)
    8000292e:	c08d                	beqz	s1,80002950 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002930:	86d2                	mv	a3,s4
    80002932:	864e                	mv	a2,s3
    80002934:	85ca                	mv	a1,s2
    80002936:	6928                	ld	a0,80(a0)
    80002938:	fffff097          	auipc	ra,0xfffff
    8000293c:	f8e080e7          	jalr	-114(ra) # 800018c6 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002940:	70a2                	ld	ra,40(sp)
    80002942:	7402                	ld	s0,32(sp)
    80002944:	64e2                	ld	s1,24(sp)
    80002946:	6942                	ld	s2,16(sp)
    80002948:	69a2                	ld	s3,8(sp)
    8000294a:	6a02                	ld	s4,0(sp)
    8000294c:	6145                	addi	sp,sp,48
    8000294e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002950:	000a061b          	sext.w	a2,s4
    80002954:	85ce                	mv	a1,s3
    80002956:	854a                	mv	a0,s2
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	54a080e7          	jalr	1354(ra) # 80000ea2 <memmove>
    return 0;
    80002960:	8526                	mv	a0,s1
    80002962:	bff9                	j	80002940 <either_copyin+0x32>

0000000080002964 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002964:	715d                	addi	sp,sp,-80
    80002966:	e486                	sd	ra,72(sp)
    80002968:	e0a2                	sd	s0,64(sp)
    8000296a:	fc26                	sd	s1,56(sp)
    8000296c:	f84a                	sd	s2,48(sp)
    8000296e:	f44e                	sd	s3,40(sp)
    80002970:	f052                	sd	s4,32(sp)
    80002972:	ec56                	sd	s5,24(sp)
    80002974:	e85a                	sd	s6,16(sp)
    80002976:	e45e                	sd	s7,8(sp)
    80002978:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000297a:	00005517          	auipc	a0,0x5
    8000297e:	78e50513          	addi	a0,a0,1934 # 80008108 <digits+0xc8>
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	c08080e7          	jalr	-1016(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000298a:	0022f497          	auipc	s1,0x22f
    8000298e:	a1648493          	addi	s1,s1,-1514 # 802313a0 <proc+0x158>
    80002992:	00236917          	auipc	s2,0x236
    80002996:	c0e90913          	addi	s2,s2,-1010 # 802385a0 <mlfq+0x158>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000299a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000299c:	00006997          	auipc	s3,0x6
    800029a0:	92498993          	addi	s3,s3,-1756 # 800082c0 <digits+0x280>
    printf("%d %s %s ctime=%d tickets=%d static_prior=%d", p->pid, state, p->name, p->ctime, p->tickets, p->static_priority);
    800029a4:	00006a97          	auipc	s5,0x6
    800029a8:	924a8a93          	addi	s5,s5,-1756 # 800082c8 <digits+0x288>
    printf("\n");
    800029ac:	00005a17          	auipc	s4,0x5
    800029b0:	75ca0a13          	addi	s4,s4,1884 # 80008108 <digits+0xc8>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029b4:	00006b97          	auipc	s7,0x6
    800029b8:	974b8b93          	addi	s7,s7,-1676 # 80008328 <states.0>
    800029bc:	a02d                	j	800029e6 <procdump+0x82>
    printf("%d %s %s ctime=%d tickets=%d static_prior=%d", p->pid, state, p->name, p->ctime, p->tickets, p->static_priority);
    800029be:	0286a803          	lw	a6,40(a3)
    800029c2:	529c                	lw	a5,32(a3)
    800029c4:	4ad8                	lw	a4,20(a3)
    800029c6:	ed86a583          	lw	a1,-296(a3)
    800029ca:	8556                	mv	a0,s5
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	bbe080e7          	jalr	-1090(ra) # 8000058a <printf>
    printf("\n");
    800029d4:	8552                	mv	a0,s4
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	bb4080e7          	jalr	-1100(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800029de:	1c848493          	addi	s1,s1,456
    800029e2:	03248263          	beq	s1,s2,80002a06 <procdump+0xa2>
    if (p->state == UNUSED)
    800029e6:	86a6                	mv	a3,s1
    800029e8:	ec04a783          	lw	a5,-320(s1)
    800029ec:	dbed                	beqz	a5,800029de <procdump+0x7a>
      state = "???";
    800029ee:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029f0:	fcfb67e3          	bltu	s6,a5,800029be <procdump+0x5a>
    800029f4:	02079713          	slli	a4,a5,0x20
    800029f8:	01d75793          	srli	a5,a4,0x1d
    800029fc:	97de                	add	a5,a5,s7
    800029fe:	6390                	ld	a2,0(a5)
    80002a00:	fe5d                	bnez	a2,800029be <procdump+0x5a>
      state = "???";
    80002a02:	864e                	mv	a2,s3
    80002a04:	bf6d                	j	800029be <procdump+0x5a>
  }
}
    80002a06:	60a6                	ld	ra,72(sp)
    80002a08:	6406                	ld	s0,64(sp)
    80002a0a:	74e2                	ld	s1,56(sp)
    80002a0c:	7942                	ld	s2,48(sp)
    80002a0e:	79a2                	ld	s3,40(sp)
    80002a10:	7a02                	ld	s4,32(sp)
    80002a12:	6ae2                	ld	s5,24(sp)
    80002a14:	6b42                	ld	s6,16(sp)
    80002a16:	6ba2                	ld	s7,8(sp)
    80002a18:	6161                	addi	sp,sp,80
    80002a1a:	8082                	ret

0000000080002a1c <setpriority>:
int setpriority(int number, int piid)
{
    80002a1c:	7179                	addi	sp,sp,-48
    80002a1e:	f406                	sd	ra,40(sp)
    80002a20:	f022                	sd	s0,32(sp)
    80002a22:	ec26                	sd	s1,24(sp)
    80002a24:	e84a                	sd	s2,16(sp)
    80002a26:	e44e                	sd	s3,8(sp)
    80002a28:	e052                	sd	s4,0(sp)
    80002a2a:	1800                	addi	s0,sp,48
    80002a2c:	8a2a                	mv	s4,a0
    80002a2e:	892e                	mv	s2,a1
  uint original = 0;
  for (struct proc *p = proc; p < &proc[NPROC]; p++)
    80002a30:	0022f497          	auipc	s1,0x22f
    80002a34:	81848493          	addi	s1,s1,-2024 # 80231248 <proc>
    80002a38:	00236997          	auipc	s3,0x236
    80002a3c:	a1098993          	addi	s3,s3,-1520 # 80238448 <mlfq>
  {
    acquire(&p->lock);
    80002a40:	8526                	mv	a0,s1
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	308080e7          	jalr	776(ra) # 80000d4a <acquire>
    if (p->pid == piid)
    80002a4a:	589c                	lw	a5,48(s1)
    80002a4c:	01278d63          	beq	a5,s2,80002a66 <setpriority+0x4a>
        // printf("%d %d %d\n", p->pid, p->static_priority, original);
        yield();
      }
      break;
    }
    release(&p->lock);
    80002a50:	8526                	mv	a0,s1
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	3ac080e7          	jalr	940(ra) # 80000dfe <release>
  for (struct proc *p = proc; p < &proc[NPROC]; p++)
    80002a5a:	1c848493          	addi	s1,s1,456
    80002a5e:	ff3491e3          	bne	s1,s3,80002a40 <setpriority+0x24>
  uint original = 0;
    80002a62:	4901                	li	s2,0
    80002a64:	a00d                	j	80002a86 <setpriority+0x6a>
      original = p->static_priority;
    80002a66:	1804a903          	lw	s2,384(s1)
      p->static_priority = number;
    80002a6a:	1944a023          	sw	s4,384(s1)
      p->reset_niceness = 1;
    80002a6e:	4785                	li	a5,1
    80002a70:	18f4a423          	sw	a5,392(s1)
      release(&p->lock);
    80002a74:	8526                	mv	a0,s1
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	388080e7          	jalr	904(ra) # 80000dfe <release>
      if (p->static_priority < original)
    80002a7e:	1804a783          	lw	a5,384(s1)
    80002a82:	0127eb63          	bltu	a5,s2,80002a98 <setpriority+0x7c>
  }
  return original;
    80002a86:	854a                	mv	a0,s2
    80002a88:	70a2                	ld	ra,40(sp)
    80002a8a:	7402                	ld	s0,32(sp)
    80002a8c:	64e2                	ld	s1,24(sp)
    80002a8e:	6942                	ld	s2,16(sp)
    80002a90:	69a2                	ld	s3,8(sp)
    80002a92:	6a02                	ld	s4,0(sp)
    80002a94:	6145                	addi	sp,sp,48
    80002a96:	8082                	ret
        yield();
    80002a98:	00000097          	auipc	ra,0x0
    80002a9c:	858080e7          	jalr	-1960(ra) # 800022f0 <yield>
    80002aa0:	b7dd                	j	80002a86 <setpriority+0x6a>

0000000080002aa2 <swtch>:
    80002aa2:	00153023          	sd	ra,0(a0)
    80002aa6:	00253423          	sd	sp,8(a0)
    80002aaa:	e900                	sd	s0,16(a0)
    80002aac:	ed04                	sd	s1,24(a0)
    80002aae:	03253023          	sd	s2,32(a0)
    80002ab2:	03353423          	sd	s3,40(a0)
    80002ab6:	03453823          	sd	s4,48(a0)
    80002aba:	03553c23          	sd	s5,56(a0)
    80002abe:	05653023          	sd	s6,64(a0)
    80002ac2:	05753423          	sd	s7,72(a0)
    80002ac6:	05853823          	sd	s8,80(a0)
    80002aca:	05953c23          	sd	s9,88(a0)
    80002ace:	07a53023          	sd	s10,96(a0)
    80002ad2:	07b53423          	sd	s11,104(a0)
    80002ad6:	0005b083          	ld	ra,0(a1)
    80002ada:	0085b103          	ld	sp,8(a1)
    80002ade:	6980                	ld	s0,16(a1)
    80002ae0:	6d84                	ld	s1,24(a1)
    80002ae2:	0205b903          	ld	s2,32(a1)
    80002ae6:	0285b983          	ld	s3,40(a1)
    80002aea:	0305ba03          	ld	s4,48(a1)
    80002aee:	0385ba83          	ld	s5,56(a1)
    80002af2:	0405bb03          	ld	s6,64(a1)
    80002af6:	0485bb83          	ld	s7,72(a1)
    80002afa:	0505bc03          	ld	s8,80(a1)
    80002afe:	0585bc83          	ld	s9,88(a1)
    80002b02:	0605bd03          	ld	s10,96(a1)
    80002b06:	0685bd83          	ld	s11,104(a1)
    80002b0a:	8082                	ret

0000000080002b0c <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002b0c:	1141                	addi	sp,sp,-16
    80002b0e:	e406                	sd	ra,8(sp)
    80002b10:	e022                	sd	s0,0(sp)
    80002b12:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b14:	00006597          	auipc	a1,0x6
    80002b18:	84458593          	addi	a1,a1,-1980 # 80008358 <states.0+0x30>
    80002b1c:	00236517          	auipc	a0,0x236
    80002b20:	35450513          	addi	a0,a0,852 # 80238e70 <tickslock>
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	196080e7          	jalr	406(ra) # 80000cba <initlock>
}
    80002b2c:	60a2                	ld	ra,8(sp)
    80002b2e:	6402                	ld	s0,0(sp)
    80002b30:	0141                	addi	sp,sp,16
    80002b32:	8082                	ret

0000000080002b34 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002b34:	1141                	addi	sp,sp,-16
    80002b36:	e422                	sd	s0,8(sp)
    80002b38:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0"
    80002b3a:	00004797          	auipc	a5,0x4
    80002b3e:	89678793          	addi	a5,a5,-1898 # 800063d0 <kernelvec>
    80002b42:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b46:	6422                	ld	s0,8(sp)
    80002b48:	0141                	addi	sp,sp,16
    80002b4a:	8082                	ret

0000000080002b4c <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002b4c:	1141                	addi	sp,sp,-16
    80002b4e:	e406                	sd	ra,8(sp)
    80002b50:	e022                	sd	s0,0(sp)
    80002b52:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b54:	fffff097          	auipc	ra,0xfffff
    80002b58:	026080e7          	jalr	38(ra) # 80001b7a <myproc>
  asm volatile("csrr %0, sstatus"
    80002b5c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b60:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    80002b62:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b66:	00004697          	auipc	a3,0x4
    80002b6a:	49a68693          	addi	a3,a3,1178 # 80007000 <_trampoline>
    80002b6e:	00004717          	auipc	a4,0x4
    80002b72:	49270713          	addi	a4,a4,1170 # 80007000 <_trampoline>
    80002b76:	8f15                	sub	a4,a4,a3
    80002b78:	040007b7          	lui	a5,0x4000
    80002b7c:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b7e:	07b2                	slli	a5,a5,0xc
    80002b80:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0"
    80002b82:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b86:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp"
    80002b88:	18002673          	csrr	a2,satp
    80002b8c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b8e:	6d30                	ld	a2,88(a0)
    80002b90:	6138                	ld	a4,64(a0)
    80002b92:	6585                	lui	a1,0x1
    80002b94:	972e                	add	a4,a4,a1
    80002b96:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b98:	6d38                	ld	a4,88(a0)
    80002b9a:	00000617          	auipc	a2,0x0
    80002b9e:	2fa60613          	addi	a2,a2,762 # 80002e94 <usertrap>
    80002ba2:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002ba4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp"
    80002ba6:	8612                	mv	a2,tp
    80002ba8:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus"
    80002baa:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002bae:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002bb2:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0"
    80002bb6:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002bba:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0"
    80002bbc:	6f18                	ld	a4,24(a4)
    80002bbe:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bc2:	6928                	ld	a0,80(a0)
    80002bc4:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002bc6:	00004717          	auipc	a4,0x4
    80002bca:	4d670713          	addi	a4,a4,1238 # 8000709c <userret>
    80002bce:	8f15                	sub	a4,a4,a3
    80002bd0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002bd2:	577d                	li	a4,-1
    80002bd4:	177e                	slli	a4,a4,0x3f
    80002bd6:	8d59                	or	a0,a0,a4
    80002bd8:	9782                	jalr	a5
}
    80002bda:	60a2                	ld	ra,8(sp)
    80002bdc:	6402                	ld	s0,0(sp)
    80002bde:	0141                	addi	sp,sp,16
    80002be0:	8082                	ret

0000000080002be2 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002be2:	1141                	addi	sp,sp,-16
    80002be4:	e406                	sd	ra,8(sp)
    80002be6:	e022                	sd	s0,0(sp)
    80002be8:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    80002bea:	00236517          	auipc	a0,0x236
    80002bee:	28650513          	addi	a0,a0,646 # 80238e70 <tickslock>
    80002bf2:	ffffe097          	auipc	ra,0xffffe
    80002bf6:	158080e7          	jalr	344(ra) # 80000d4a <acquire>
  ticks++;
    80002bfa:	00006717          	auipc	a4,0x6
    80002bfe:	f9e70713          	addi	a4,a4,-98 # 80008b98 <ticks>
    80002c02:	431c                	lw	a5,0(a4)
    80002c04:	2785                	addiw	a5,a5,1
    80002c06:	c31c                	sw	a5,0(a4)
  update_time();
    80002c08:	fffff097          	auipc	ra,0xfffff
    80002c0c:	514080e7          	jalr	1300(ra) # 8000211c <update_time>
  if (myproc() != 0)
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	f6a080e7          	jalr	-150(ra) # 80001b7a <myproc>
    80002c18:	c11d                	beqz	a0,80002c3e <clockintr+0x5c>
  {
    myproc()->running_ticks++;
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	f60080e7          	jalr	-160(ra) # 80001b7a <myproc>
    80002c22:	19052783          	lw	a5,400(a0)
    80002c26:	2785                	addiw	a5,a5,1
    80002c28:	18f52823          	sw	a5,400(a0)
    myproc()->change_queue--;
    80002c2c:	fffff097          	auipc	ra,0xfffff
    80002c30:	f4e080e7          	jalr	-178(ra) # 80001b7a <myproc>
    80002c34:	19c52783          	lw	a5,412(a0)
    80002c38:	37fd                	addiw	a5,a5,-1
    80002c3a:	18f52e23          	sw	a5,412(a0)
  }
  wakeup(&ticks);
    80002c3e:	00006517          	auipc	a0,0x6
    80002c42:	f5a50513          	addi	a0,a0,-166 # 80008b98 <ticks>
    80002c46:	00000097          	auipc	ra,0x0
    80002c4a:	8a2080e7          	jalr	-1886(ra) # 800024e8 <wakeup>
  release(&tickslock);
    80002c4e:	00236517          	auipc	a0,0x236
    80002c52:	22250513          	addi	a0,a0,546 # 80238e70 <tickslock>
    80002c56:	ffffe097          	auipc	ra,0xffffe
    80002c5a:	1a8080e7          	jalr	424(ra) # 80000dfe <release>
}
    80002c5e:	60a2                	ld	ra,8(sp)
    80002c60:	6402                	ld	s0,0(sp)
    80002c62:	0141                	addi	sp,sp,16
    80002c64:	8082                	ret

0000000080002c66 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002c66:	1101                	addi	sp,sp,-32
    80002c68:	ec06                	sd	ra,24(sp)
    80002c6a:	e822                	sd	s0,16(sp)
    80002c6c:	e426                	sd	s1,8(sp)
    80002c6e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause"
    80002c70:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002c74:	00074d63          	bltz	a4,80002c8e <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002c78:	57fd                	li	a5,-1
    80002c7a:	17fe                	slli	a5,a5,0x3f
    80002c7c:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002c7e:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002c80:	06f70363          	beq	a4,a5,80002ce6 <devintr+0x80>
  }
}
    80002c84:	60e2                	ld	ra,24(sp)
    80002c86:	6442                	ld	s0,16(sp)
    80002c88:	64a2                	ld	s1,8(sp)
    80002c8a:	6105                	addi	sp,sp,32
    80002c8c:	8082                	ret
      (scause & 0xff) == 9)
    80002c8e:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002c92:	46a5                	li	a3,9
    80002c94:	fed792e3          	bne	a5,a3,80002c78 <devintr+0x12>
    int irq = plic_claim();
    80002c98:	00004097          	auipc	ra,0x4
    80002c9c:	840080e7          	jalr	-1984(ra) # 800064d8 <plic_claim>
    80002ca0:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002ca2:	47a9                	li	a5,10
    80002ca4:	02f50763          	beq	a0,a5,80002cd2 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002ca8:	4785                	li	a5,1
    80002caa:	02f50963          	beq	a0,a5,80002cdc <devintr+0x76>
    return 1;
    80002cae:	4505                	li	a0,1
    else if (irq)
    80002cb0:	d8f1                	beqz	s1,80002c84 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002cb2:	85a6                	mv	a1,s1
    80002cb4:	00005517          	auipc	a0,0x5
    80002cb8:	6ac50513          	addi	a0,a0,1708 # 80008360 <states.0+0x38>
    80002cbc:	ffffe097          	auipc	ra,0xffffe
    80002cc0:	8ce080e7          	jalr	-1842(ra) # 8000058a <printf>
      plic_complete(irq);
    80002cc4:	8526                	mv	a0,s1
    80002cc6:	00004097          	auipc	ra,0x4
    80002cca:	836080e7          	jalr	-1994(ra) # 800064fc <plic_complete>
    return 1;
    80002cce:	4505                	li	a0,1
    80002cd0:	bf55                	j	80002c84 <devintr+0x1e>
      uartintr();
    80002cd2:	ffffe097          	auipc	ra,0xffffe
    80002cd6:	cc6080e7          	jalr	-826(ra) # 80000998 <uartintr>
    80002cda:	b7ed                	j	80002cc4 <devintr+0x5e>
      virtio_disk_intr();
    80002cdc:	00004097          	auipc	ra,0x4
    80002ce0:	fbc080e7          	jalr	-68(ra) # 80006c98 <virtio_disk_intr>
    80002ce4:	b7c5                	j	80002cc4 <devintr+0x5e>
    if (cpuid() == 0)
    80002ce6:	fffff097          	auipc	ra,0xfffff
    80002cea:	e68080e7          	jalr	-408(ra) # 80001b4e <cpuid>
    80002cee:	c901                	beqz	a0,80002cfe <devintr+0x98>
  asm volatile("csrr %0, sip"
    80002cf0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002cf4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0"
    80002cf6:	14479073          	csrw	sip,a5
    return 2;
    80002cfa:	4509                	li	a0,2
    80002cfc:	b761                	j	80002c84 <devintr+0x1e>
      clockintr();
    80002cfe:	00000097          	auipc	ra,0x0
    80002d02:	ee4080e7          	jalr	-284(ra) # 80002be2 <clockintr>
    80002d06:	b7ed                	j	80002cf0 <devintr+0x8a>

0000000080002d08 <kerneltrap>:
{
    80002d08:	7179                	addi	sp,sp,-48
    80002d0a:	f406                	sd	ra,40(sp)
    80002d0c:	f022                	sd	s0,32(sp)
    80002d0e:	ec26                	sd	s1,24(sp)
    80002d10:	e84a                	sd	s2,16(sp)
    80002d12:	e44e                	sd	s3,8(sp)
    80002d14:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc"
    80002d16:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus"
    80002d1a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause"
    80002d1e:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002d22:	1004f793          	andi	a5,s1,256
    80002d26:	cb85                	beqz	a5,80002d56 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus"
    80002d28:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d2c:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002d2e:	ef85                	bnez	a5,80002d66 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	f36080e7          	jalr	-202(ra) # 80002c66 <devintr>
    80002d38:	cd1d                	beqz	a0,80002d76 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d3a:	4789                	li	a5,2
    80002d3c:	06f50a63          	beq	a0,a5,80002db0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0"
    80002d40:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0"
    80002d44:	10049073          	csrw	sstatus,s1
}
    80002d48:	70a2                	ld	ra,40(sp)
    80002d4a:	7402                	ld	s0,32(sp)
    80002d4c:	64e2                	ld	s1,24(sp)
    80002d4e:	6942                	ld	s2,16(sp)
    80002d50:	69a2                	ld	s3,8(sp)
    80002d52:	6145                	addi	sp,sp,48
    80002d54:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d56:	00005517          	auipc	a0,0x5
    80002d5a:	62a50513          	addi	a0,a0,1578 # 80008380 <states.0+0x58>
    80002d5e:	ffffd097          	auipc	ra,0xffffd
    80002d62:	7e2080e7          	jalr	2018(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d66:	00005517          	auipc	a0,0x5
    80002d6a:	64250513          	addi	a0,a0,1602 # 800083a8 <states.0+0x80>
    80002d6e:	ffffd097          	auipc	ra,0xffffd
    80002d72:	7d2080e7          	jalr	2002(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002d76:	85ce                	mv	a1,s3
    80002d78:	00005517          	auipc	a0,0x5
    80002d7c:	65050513          	addi	a0,a0,1616 # 800083c8 <states.0+0xa0>
    80002d80:	ffffe097          	auipc	ra,0xffffe
    80002d84:	80a080e7          	jalr	-2038(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002d88:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002d8c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d90:	00005517          	auipc	a0,0x5
    80002d94:	64850513          	addi	a0,a0,1608 # 800083d8 <states.0+0xb0>
    80002d98:	ffffd097          	auipc	ra,0xffffd
    80002d9c:	7f2080e7          	jalr	2034(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002da0:	00005517          	auipc	a0,0x5
    80002da4:	65050513          	addi	a0,a0,1616 # 800083f0 <states.0+0xc8>
    80002da8:	ffffd097          	auipc	ra,0xffffd
    80002dac:	798080e7          	jalr	1944(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002db0:	fffff097          	auipc	ra,0xfffff
    80002db4:	dca080e7          	jalr	-566(ra) # 80001b7a <myproc>
    80002db8:	d541                	beqz	a0,80002d40 <kerneltrap+0x38>
    80002dba:	fffff097          	auipc	ra,0xfffff
    80002dbe:	dc0080e7          	jalr	-576(ra) # 80001b7a <myproc>
    80002dc2:	4d18                	lw	a4,24(a0)
    80002dc4:	4791                	li	a5,4
    80002dc6:	f6f71de3          	bne	a4,a5,80002d40 <kerneltrap+0x38>
    yield();
    80002dca:	fffff097          	auipc	ra,0xfffff
    80002dce:	526080e7          	jalr	1318(ra) # 800022f0 <yield>
    80002dd2:	b7bd                	j	80002d40 <kerneltrap+0x38>

0000000080002dd4 <pgfault>:

// -1 means cannot alloc mem
// -2 means the address is invalid
// 0 means ok
int pgfault(uint64 va, pagetable_t pagetable)
{
    80002dd4:	7179                	addi	sp,sp,-48
    80002dd6:	f406                	sd	ra,40(sp)
    80002dd8:	f022                	sd	s0,32(sp)
    80002dda:	ec26                	sd	s1,24(sp)
    80002ddc:	e84a                	sd	s2,16(sp)
    80002dde:	e44e                	sd	s3,8(sp)
    80002de0:	e052                	sd	s4,0(sp)
    80002de2:	1800                	addi	s0,sp,48
    80002de4:	84aa                	mv	s1,a0
    80002de6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002de8:	fffff097          	auipc	ra,0xfffff
    80002dec:	d92080e7          	jalr	-622(ra) # 80001b7a <myproc>
  if (va >= MAXVA || (va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE && va <= PGROUNDDOWN(p->trapframe->sp)))
    80002df0:	57fd                	li	a5,-1
    80002df2:	83e9                	srli	a5,a5,0x1a
    80002df4:	0897e663          	bltu	a5,s1,80002e80 <pgfault+0xac>
    80002df8:	6d38                	ld	a4,88(a0)
    80002dfa:	77fd                	lui	a5,0xfffff
    80002dfc:	7b18                	ld	a4,48(a4)
    80002dfe:	8f7d                	and	a4,a4,a5
    80002e00:	97ba                	add	a5,a5,a4
    80002e02:	00f4e463          	bltu	s1,a5,80002e0a <pgfault+0x36>
    80002e06:	06977f63          	bgeu	a4,s1,80002e84 <pgfault+0xb0>
  {
    return -2;
  }
  va = PGROUNDDOWN(va);
  pte_t *pte = walk(pagetable, va, 0);
    80002e0a:	4601                	li	a2,0
    80002e0c:	75fd                	lui	a1,0xfffff
    80002e0e:	8de5                	and	a1,a1,s1
    80002e10:	854a                	mv	a0,s2
    80002e12:	ffffe097          	auipc	ra,0xffffe
    80002e16:	318080e7          	jalr	792(ra) # 8000112a <walk>
    80002e1a:	84aa                	mv	s1,a0
  if (pte == 0)
    80002e1c:	c535                	beqz	a0,80002e88 <pgfault+0xb4>
    return -1;
  
  uint64 pa = PTE2PA(*pte);
    80002e1e:	611c                	ld	a5,0(a0)
    80002e20:	00a7d913          	srli	s2,a5,0xa
    80002e24:	0932                	slli	s2,s2,0xc
  if (pa == 0)
    80002e26:	06090363          	beqz	s2,80002e8c <pgfault+0xb8>
  {
    return -1;
  }
  uint flags = PTE_FLAGS(*pte);
    80002e2a:	0007871b          	sext.w	a4,a5
  if (flags & PTE_C)
    80002e2e:	1007f793          	andi	a5,a5,256
    //   printf("sometthing is wrong in mappages in trap.\n");
    // }

    return 0;
  }
  return 0;
    80002e32:	4501                	li	a0,0
  if (flags & PTE_C)
    80002e34:	eb89                	bnez	a5,80002e46 <pgfault+0x72>
}
    80002e36:	70a2                	ld	ra,40(sp)
    80002e38:	7402                	ld	s0,32(sp)
    80002e3a:	64e2                	ld	s1,24(sp)
    80002e3c:	6942                	ld	s2,16(sp)
    80002e3e:	69a2                	ld	s3,8(sp)
    80002e40:	6a02                	ld	s4,0(sp)
    80002e42:	6145                	addi	sp,sp,48
    80002e44:	8082                	ret
    flags = (flags | PTE_W) & (~PTE_C);
    80002e46:	2ff77713          	andi	a4,a4,767
    80002e4a:	00476993          	ori	s3,a4,4
    char *mem = kalloc();
    80002e4e:	ffffe097          	auipc	ra,0xffffe
    80002e52:	e02080e7          	jalr	-510(ra) # 80000c50 <kalloc>
    80002e56:	8a2a                	mv	s4,a0
    if (mem == 0)
    80002e58:	cd05                	beqz	a0,80002e90 <pgfault+0xbc>
    memmove(mem, (void *)pa, PGSIZE);
    80002e5a:	6605                	lui	a2,0x1
    80002e5c:	85ca                	mv	a1,s2
    80002e5e:	ffffe097          	auipc	ra,0xffffe
    80002e62:	044080e7          	jalr	68(ra) # 80000ea2 <memmove>
    *pte = PA2PTE(mem) | flags;
    80002e66:	00ca5a13          	srli	s4,s4,0xc
    80002e6a:	0a2a                	slli	s4,s4,0xa
    80002e6c:	0149e733          	or	a4,s3,s4
    80002e70:	e098                	sd	a4,0(s1)
    kfree((void *)pa);
    80002e72:	854a                	mv	a0,s2
    80002e74:	ffffe097          	auipc	ra,0xffffe
    80002e78:	c04080e7          	jalr	-1020(ra) # 80000a78 <kfree>
    return 0;
    80002e7c:	4501                	li	a0,0
    80002e7e:	bf65                	j	80002e36 <pgfault+0x62>
    return -2;
    80002e80:	5579                	li	a0,-2
    80002e82:	bf55                	j	80002e36 <pgfault+0x62>
    80002e84:	5579                	li	a0,-2
    80002e86:	bf45                	j	80002e36 <pgfault+0x62>
    return -1;
    80002e88:	557d                	li	a0,-1
    80002e8a:	b775                	j	80002e36 <pgfault+0x62>
    return -1;
    80002e8c:	557d                	li	a0,-1
    80002e8e:	b765                	j	80002e36 <pgfault+0x62>
      return -1;
    80002e90:	557d                	li	a0,-1
    80002e92:	b755                	j	80002e36 <pgfault+0x62>

0000000080002e94 <usertrap>:
{
    80002e94:	1101                	addi	sp,sp,-32
    80002e96:	ec06                	sd	ra,24(sp)
    80002e98:	e822                	sd	s0,16(sp)
    80002e9a:	e426                	sd	s1,8(sp)
    80002e9c:	e04a                	sd	s2,0(sp)
    80002e9e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80002ea0:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002ea4:	1007f793          	andi	a5,a5,256
    80002ea8:	efad                	bnez	a5,80002f22 <usertrap+0x8e>
  asm volatile("csrw stvec, %0"
    80002eaa:	00003797          	auipc	a5,0x3
    80002eae:	52678793          	addi	a5,a5,1318 # 800063d0 <kernelvec>
    80002eb2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002eb6:	fffff097          	auipc	ra,0xfffff
    80002eba:	cc4080e7          	jalr	-828(ra) # 80001b7a <myproc>
    80002ebe:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ec0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc"
    80002ec2:	14102773          	csrr	a4,sepc
    80002ec6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause"
    80002ec8:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002ecc:	47a1                	li	a5,8
    80002ece:	06f70263          	beq	a4,a5,80002f32 <usertrap+0x9e>
  else if ((which_dev = devintr()) != 0)
    80002ed2:	00000097          	auipc	ra,0x0
    80002ed6:	d94080e7          	jalr	-620(ra) # 80002c66 <devintr>
    80002eda:	892a                	mv	s2,a0
    80002edc:	ed5d                	bnez	a0,80002f9a <usertrap+0x106>
    80002ede:	14202773          	csrr	a4,scause
  else if (r_scause() == 15)
    80002ee2:	47bd                	li	a5,15
    80002ee4:	0af70063          	beq	a4,a5,80002f84 <usertrap+0xf0>
    80002ee8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002eec:	5890                	lw	a2,48(s1)
    80002eee:	00005517          	auipc	a0,0x5
    80002ef2:	53250513          	addi	a0,a0,1330 # 80008420 <states.0+0xf8>
    80002ef6:	ffffd097          	auipc	ra,0xffffd
    80002efa:	694080e7          	jalr	1684(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002efe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002f02:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f06:	00005517          	auipc	a0,0x5
    80002f0a:	54a50513          	addi	a0,a0,1354 # 80008450 <states.0+0x128>
    80002f0e:	ffffd097          	auipc	ra,0xffffd
    80002f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    setkilled(p);
    80002f16:	8526                	mv	a0,s1
    80002f18:	00000097          	auipc	ra,0x0
    80002f1c:	814080e7          	jalr	-2028(ra) # 8000272c <setkilled>
    80002f20:	a825                	j	80002f58 <usertrap+0xc4>
    panic("usertrap: not from user mode");
    80002f22:	00005517          	auipc	a0,0x5
    80002f26:	4de50513          	addi	a0,a0,1246 # 80008400 <states.0+0xd8>
    80002f2a:	ffffd097          	auipc	ra,0xffffd
    80002f2e:	616080e7          	jalr	1558(ra) # 80000540 <panic>
    if (killed(p))
    80002f32:	00000097          	auipc	ra,0x0
    80002f36:	826080e7          	jalr	-2010(ra) # 80002758 <killed>
    80002f3a:	ed1d                	bnez	a0,80002f78 <usertrap+0xe4>
    p->trapframe->epc += 4;
    80002f3c:	6cb8                	ld	a4,88(s1)
    80002f3e:	6f1c                	ld	a5,24(a4)
    80002f40:	0791                	addi	a5,a5,4
    80002f42:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus"
    80002f44:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f48:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002f4c:	10079073          	csrw	sstatus,a5
    syscall();
    80002f50:	00000097          	auipc	ra,0x0
    80002f54:	240080e7          	jalr	576(ra) # 80003190 <syscall>
  if (killed(p))
    80002f58:	8526                	mv	a0,s1
    80002f5a:	fffff097          	auipc	ra,0xfffff
    80002f5e:	7fe080e7          	jalr	2046(ra) # 80002758 <killed>
    80002f62:	e139                	bnez	a0,80002fa8 <usertrap+0x114>
  usertrapret();
    80002f64:	00000097          	auipc	ra,0x0
    80002f68:	be8080e7          	jalr	-1048(ra) # 80002b4c <usertrapret>
}
    80002f6c:	60e2                	ld	ra,24(sp)
    80002f6e:	6442                	ld	s0,16(sp)
    80002f70:	64a2                	ld	s1,8(sp)
    80002f72:	6902                	ld	s2,0(sp)
    80002f74:	6105                	addi	sp,sp,32
    80002f76:	8082                	ret
      exit(-1);
    80002f78:	557d                	li	a0,-1
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	65e080e7          	jalr	1630(ra) # 800025d8 <exit>
    80002f82:	bf6d                	j	80002f3c <usertrap+0xa8>
  asm volatile("csrr %0, stval"
    80002f84:	14302573          	csrr	a0,stval
    int r = pgfault(r_stval(), p->pagetable);
    80002f88:	68ac                	ld	a1,80(s1)
    80002f8a:	00000097          	auipc	ra,0x0
    80002f8e:	e4a080e7          	jalr	-438(ra) # 80002dd4 <pgfault>
    if (r)
    80002f92:	d179                	beqz	a0,80002f58 <usertrap+0xc4>
      p->killed = 1;
    80002f94:	4785                	li	a5,1
    80002f96:	d49c                	sw	a5,40(s1)
    80002f98:	b7c1                	j	80002f58 <usertrap+0xc4>
  if (killed(p))
    80002f9a:	8526                	mv	a0,s1
    80002f9c:	fffff097          	auipc	ra,0xfffff
    80002fa0:	7bc080e7          	jalr	1980(ra) # 80002758 <killed>
    80002fa4:	c901                	beqz	a0,80002fb4 <usertrap+0x120>
    80002fa6:	a011                	j	80002faa <usertrap+0x116>
    80002fa8:	4901                	li	s2,0
    exit(-1);
    80002faa:	557d                	li	a0,-1
    80002fac:	fffff097          	auipc	ra,0xfffff
    80002fb0:	62c080e7          	jalr	1580(ra) # 800025d8 <exit>
  if (which_dev == 2)
    80002fb4:	4789                	li	a5,2
    80002fb6:	faf917e3          	bne	s2,a5,80002f64 <usertrap+0xd0>
    if (p->interval)
    80002fba:	1b04a703          	lw	a4,432(s1)
    80002fbe:	cf19                	beqz	a4,80002fdc <usertrap+0x148>
      p->now_ticks++;
    80002fc0:	1b44a783          	lw	a5,436(s1)
    80002fc4:	2785                	addiw	a5,a5,1
    80002fc6:	0007869b          	sext.w	a3,a5
    80002fca:	1af4aa23          	sw	a5,436(s1)
      if (!p->sigalarm_status && p->interval > 0 && p->now_ticks >= p->interval)
    80002fce:	1c04a783          	lw	a5,448(s1)
    80002fd2:	e789                	bnez	a5,80002fdc <usertrap+0x148>
    80002fd4:	00e05463          	blez	a4,80002fdc <usertrap+0x148>
    80002fd8:	00e6d763          	bge	a3,a4,80002fe6 <usertrap+0x152>
    yield();
    80002fdc:	fffff097          	auipc	ra,0xfffff
    80002fe0:	314080e7          	jalr	788(ra) # 800022f0 <yield>
    80002fe4:	b741                	j	80002f64 <usertrap+0xd0>
        p->now_ticks = 0;
    80002fe6:	1a04aa23          	sw	zero,436(s1)
        p->sigalarm_status = 1;
    80002fea:	4785                	li	a5,1
    80002fec:	1cf4a023          	sw	a5,448(s1)
        p->alarm_trapframe = kalloc();
    80002ff0:	ffffe097          	auipc	ra,0xffffe
    80002ff4:	c60080e7          	jalr	-928(ra) # 80000c50 <kalloc>
    80002ff8:	1aa4bc23          	sd	a0,440(s1)
        memmove(p->alarm_trapframe, p->trapframe, PGSIZE);
    80002ffc:	6605                	lui	a2,0x1
    80002ffe:	6cac                	ld	a1,88(s1)
    80003000:	ffffe097          	auipc	ra,0xffffe
    80003004:	ea2080e7          	jalr	-350(ra) # 80000ea2 <memmove>
        p->trapframe->epc = p->handler;
    80003008:	6cbc                	ld	a5,88(s1)
    8000300a:	1a84b703          	ld	a4,424(s1)
    8000300e:	ef98                	sd	a4,24(a5)
    80003010:	b7f1                	j	80002fdc <usertrap+0x148>

0000000080003012 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003012:	1101                	addi	sp,sp,-32
    80003014:	ec06                	sd	ra,24(sp)
    80003016:	e822                	sd	s0,16(sp)
    80003018:	e426                	sd	s1,8(sp)
    8000301a:	1000                	addi	s0,sp,32
    8000301c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000301e:	fffff097          	auipc	ra,0xfffff
    80003022:	b5c080e7          	jalr	-1188(ra) # 80001b7a <myproc>
  switch (n)
    80003026:	4795                	li	a5,5
    80003028:	0497e163          	bltu	a5,s1,8000306a <argraw+0x58>
    8000302c:	048a                	slli	s1,s1,0x2
    8000302e:	00005717          	auipc	a4,0x5
    80003032:	59270713          	addi	a4,a4,1426 # 800085c0 <states.0+0x298>
    80003036:	94ba                	add	s1,s1,a4
    80003038:	409c                	lw	a5,0(s1)
    8000303a:	97ba                	add	a5,a5,a4
    8000303c:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    8000303e:	6d3c                	ld	a5,88(a0)
    80003040:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003042:	60e2                	ld	ra,24(sp)
    80003044:	6442                	ld	s0,16(sp)
    80003046:	64a2                	ld	s1,8(sp)
    80003048:	6105                	addi	sp,sp,32
    8000304a:	8082                	ret
    return p->trapframe->a1;
    8000304c:	6d3c                	ld	a5,88(a0)
    8000304e:	7fa8                	ld	a0,120(a5)
    80003050:	bfcd                	j	80003042 <argraw+0x30>
    return p->trapframe->a2;
    80003052:	6d3c                	ld	a5,88(a0)
    80003054:	63c8                	ld	a0,128(a5)
    80003056:	b7f5                	j	80003042 <argraw+0x30>
    return p->trapframe->a3;
    80003058:	6d3c                	ld	a5,88(a0)
    8000305a:	67c8                	ld	a0,136(a5)
    8000305c:	b7dd                	j	80003042 <argraw+0x30>
    return p->trapframe->a4;
    8000305e:	6d3c                	ld	a5,88(a0)
    80003060:	6bc8                	ld	a0,144(a5)
    80003062:	b7c5                	j	80003042 <argraw+0x30>
    return p->trapframe->a5;
    80003064:	6d3c                	ld	a5,88(a0)
    80003066:	6fc8                	ld	a0,152(a5)
    80003068:	bfe9                	j	80003042 <argraw+0x30>
  panic("argraw");
    8000306a:	00005517          	auipc	a0,0x5
    8000306e:	40650513          	addi	a0,a0,1030 # 80008470 <states.0+0x148>
    80003072:	ffffd097          	auipc	ra,0xffffd
    80003076:	4ce080e7          	jalr	1230(ra) # 80000540 <panic>

000000008000307a <fetchaddr>:
{
    8000307a:	1101                	addi	sp,sp,-32
    8000307c:	ec06                	sd	ra,24(sp)
    8000307e:	e822                	sd	s0,16(sp)
    80003080:	e426                	sd	s1,8(sp)
    80003082:	e04a                	sd	s2,0(sp)
    80003084:	1000                	addi	s0,sp,32
    80003086:	84aa                	mv	s1,a0
    80003088:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000308a:	fffff097          	auipc	ra,0xfffff
    8000308e:	af0080e7          	jalr	-1296(ra) # 80001b7a <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003092:	653c                	ld	a5,72(a0)
    80003094:	02f4f863          	bgeu	s1,a5,800030c4 <fetchaddr+0x4a>
    80003098:	00848713          	addi	a4,s1,8
    8000309c:	02e7e663          	bltu	a5,a4,800030c8 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030a0:	46a1                	li	a3,8
    800030a2:	8626                	mv	a2,s1
    800030a4:	85ca                	mv	a1,s2
    800030a6:	6928                	ld	a0,80(a0)
    800030a8:	fffff097          	auipc	ra,0xfffff
    800030ac:	81e080e7          	jalr	-2018(ra) # 800018c6 <copyin>
    800030b0:	00a03533          	snez	a0,a0
    800030b4:	40a00533          	neg	a0,a0
}
    800030b8:	60e2                	ld	ra,24(sp)
    800030ba:	6442                	ld	s0,16(sp)
    800030bc:	64a2                	ld	s1,8(sp)
    800030be:	6902                	ld	s2,0(sp)
    800030c0:	6105                	addi	sp,sp,32
    800030c2:	8082                	ret
    return -1;
    800030c4:	557d                	li	a0,-1
    800030c6:	bfcd                	j	800030b8 <fetchaddr+0x3e>
    800030c8:	557d                	li	a0,-1
    800030ca:	b7fd                	j	800030b8 <fetchaddr+0x3e>

00000000800030cc <fetchstr>:
{
    800030cc:	7179                	addi	sp,sp,-48
    800030ce:	f406                	sd	ra,40(sp)
    800030d0:	f022                	sd	s0,32(sp)
    800030d2:	ec26                	sd	s1,24(sp)
    800030d4:	e84a                	sd	s2,16(sp)
    800030d6:	e44e                	sd	s3,8(sp)
    800030d8:	1800                	addi	s0,sp,48
    800030da:	892a                	mv	s2,a0
    800030dc:	84ae                	mv	s1,a1
    800030de:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030e0:	fffff097          	auipc	ra,0xfffff
    800030e4:	a9a080e7          	jalr	-1382(ra) # 80001b7a <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800030e8:	86ce                	mv	a3,s3
    800030ea:	864a                	mv	a2,s2
    800030ec:	85a6                	mv	a1,s1
    800030ee:	6928                	ld	a0,80(a0)
    800030f0:	fffff097          	auipc	ra,0xfffff
    800030f4:	864080e7          	jalr	-1948(ra) # 80001954 <copyinstr>
    800030f8:	00054e63          	bltz	a0,80003114 <fetchstr+0x48>
  return strlen(buf);
    800030fc:	8526                	mv	a0,s1
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	ec4080e7          	jalr	-316(ra) # 80000fc2 <strlen>
}
    80003106:	70a2                	ld	ra,40(sp)
    80003108:	7402                	ld	s0,32(sp)
    8000310a:	64e2                	ld	s1,24(sp)
    8000310c:	6942                	ld	s2,16(sp)
    8000310e:	69a2                	ld	s3,8(sp)
    80003110:	6145                	addi	sp,sp,48
    80003112:	8082                	ret
    return -1;
    80003114:	557d                	li	a0,-1
    80003116:	bfc5                	j	80003106 <fetchstr+0x3a>

0000000080003118 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003118:	1101                	addi	sp,sp,-32
    8000311a:	ec06                	sd	ra,24(sp)
    8000311c:	e822                	sd	s0,16(sp)
    8000311e:	e426                	sd	s1,8(sp)
    80003120:	1000                	addi	s0,sp,32
    80003122:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003124:	00000097          	auipc	ra,0x0
    80003128:	eee080e7          	jalr	-274(ra) # 80003012 <argraw>
    8000312c:	c088                	sw	a0,0(s1)
}
    8000312e:	60e2                	ld	ra,24(sp)
    80003130:	6442                	ld	s0,16(sp)
    80003132:	64a2                	ld	s1,8(sp)
    80003134:	6105                	addi	sp,sp,32
    80003136:	8082                	ret

0000000080003138 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003138:	1101                	addi	sp,sp,-32
    8000313a:	ec06                	sd	ra,24(sp)
    8000313c:	e822                	sd	s0,16(sp)
    8000313e:	e426                	sd	s1,8(sp)
    80003140:	1000                	addi	s0,sp,32
    80003142:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003144:	00000097          	auipc	ra,0x0
    80003148:	ece080e7          	jalr	-306(ra) # 80003012 <argraw>
    8000314c:	e088                	sd	a0,0(s1)
}
    8000314e:	60e2                	ld	ra,24(sp)
    80003150:	6442                	ld	s0,16(sp)
    80003152:	64a2                	ld	s1,8(sp)
    80003154:	6105                	addi	sp,sp,32
    80003156:	8082                	ret

0000000080003158 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80003158:	7179                	addi	sp,sp,-48
    8000315a:	f406                	sd	ra,40(sp)
    8000315c:	f022                	sd	s0,32(sp)
    8000315e:	ec26                	sd	s1,24(sp)
    80003160:	e84a                	sd	s2,16(sp)
    80003162:	1800                	addi	s0,sp,48
    80003164:	84ae                	mv	s1,a1
    80003166:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80003168:	fd840593          	addi	a1,s0,-40
    8000316c:	00000097          	auipc	ra,0x0
    80003170:	fcc080e7          	jalr	-52(ra) # 80003138 <argaddr>
  return fetchstr(addr, buf, max);
    80003174:	864a                	mv	a2,s2
    80003176:	85a6                	mv	a1,s1
    80003178:	fd843503          	ld	a0,-40(s0)
    8000317c:	00000097          	auipc	ra,0x0
    80003180:	f50080e7          	jalr	-176(ra) # 800030cc <fetchstr>
}
    80003184:	70a2                	ld	ra,40(sp)
    80003186:	7402                	ld	s0,32(sp)
    80003188:	64e2                	ld	s1,24(sp)
    8000318a:	6942                	ld	s2,16(sp)
    8000318c:	6145                	addi	sp,sp,48
    8000318e:	8082                	ret

0000000080003190 <syscall>:
    "waitx",
    "setpriority",
};

void syscall(void)
{
    80003190:	7179                	addi	sp,sp,-48
    80003192:	f406                	sd	ra,40(sp)
    80003194:	f022                	sd	s0,32(sp)
    80003196:	ec26                	sd	s1,24(sp)
    80003198:	e84a                	sd	s2,16(sp)
    8000319a:	e44e                	sd	s3,8(sp)
    8000319c:	e052                	sd	s4,0(sp)
    8000319e:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    800031a0:	fffff097          	auipc	ra,0xfffff
    800031a4:	9da080e7          	jalr	-1574(ra) # 80001b7a <myproc>
    800031a8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800031aa:	05853903          	ld	s2,88(a0)
    800031ae:	0a893783          	ld	a5,168(s2)
    800031b2:	0007899b          	sext.w	s3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800031b6:	37fd                	addiw	a5,a5,-1
    800031b8:	4769                	li	a4,26
    800031ba:	06f76e63          	bltu	a4,a5,80003236 <syscall+0xa6>
    800031be:	00399713          	slli	a4,s3,0x3
    800031c2:	00005797          	auipc	a5,0x5
    800031c6:	41678793          	addi	a5,a5,1046 # 800085d8 <syscalls>
    800031ca:	97ba                	add	a5,a5,a4
    800031cc:	639c                	ld	a5,0(a5)
    800031ce:	c7a5                	beqz	a5,80003236 <syscall+0xa6>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0

    int arg0 = p->trapframe->a0;
    800031d0:	07093a03          	ld	s4,112(s2)
    short argcount = (num == SYS_read || num == SYS_write || num == SYS_mknod || SYS_waitx) ? 3
    : ((num == SYS_exec || num == SYS_fstat || num == SYS_open || num == SYS_link || num == SYS_sigalarm || num == SYS_setpriority) ? 2
    : ((num == SYS_wait || num == SYS_pipe || num == SYS_kill || num == SYS_chdir || num == SYS_dup || num == SYS_sbrk || num == SYS_sleep || num == SYS_unlink || num == SYS_mkdir || num == SYS_close || num == SYS_trace || num == SYS_settickets) ? 1
    : 0));

    p->trapframe->a0 = syscalls[num]();
    800031d4:	9782                	jalr	a5
    800031d6:	06a93823          	sd	a0,112(s2)

    if ((p->tmask >> num) & 0x1)
    800031da:	1744a783          	lw	a5,372(s1)
    800031de:	0137d7bb          	srlw	a5,a5,s3
    800031e2:	8b85                	andi	a5,a5,1
    800031e4:	cba5                	beqz	a5,80003254 <syscall+0xc4>
    {
      printf("%d: syscall %s (", p->pid, syscall_name[num]);
    800031e6:	098e                	slli	s3,s3,0x3
    800031e8:	00006797          	auipc	a5,0x6
    800031ec:	87078793          	addi	a5,a5,-1936 # 80008a58 <syscall_name>
    800031f0:	97ce                	add	a5,a5,s3
    800031f2:	6390                	ld	a2,0(a5)
    800031f4:	588c                	lw	a1,48(s1)
    800031f6:	00005517          	auipc	a0,0x5
    800031fa:	28250513          	addi	a0,a0,642 # 80008478 <states.0+0x150>
    800031fe:	ffffd097          	auipc	ra,0xffffd
    80003202:	38c080e7          	jalr	908(ra) # 8000058a <printf>
      if (argcount == 1)
        printf("%d ", arg0);
      else if (argcount == 2)
        printf("%d %d ", arg0, p->trapframe->a1);
      else if (argcount == 3)
        printf("%d %d %d ", arg0, p->trapframe->a1, p->trapframe->a2);
    80003206:	6cbc                	ld	a5,88(s1)
    80003208:	63d4                	ld	a3,128(a5)
    8000320a:	7fb0                	ld	a2,120(a5)
    8000320c:	000a059b          	sext.w	a1,s4
    80003210:	00005517          	auipc	a0,0x5
    80003214:	28050513          	addi	a0,a0,640 # 80008490 <states.0+0x168>
    80003218:	ffffd097          	auipc	ra,0xffffd
    8000321c:	372080e7          	jalr	882(ra) # 8000058a <printf>

      printf(") -> %d\n", p->trapframe->a0);
    80003220:	6cbc                	ld	a5,88(s1)
    80003222:	7bac                	ld	a1,112(a5)
    80003224:	00005517          	auipc	a0,0x5
    80003228:	27c50513          	addi	a0,a0,636 # 800084a0 <states.0+0x178>
    8000322c:	ffffd097          	auipc	ra,0xffffd
    80003230:	35e080e7          	jalr	862(ra) # 8000058a <printf>
    80003234:	a005                	j	80003254 <syscall+0xc4>
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80003236:	86ce                	mv	a3,s3
    80003238:	15848613          	addi	a2,s1,344
    8000323c:	588c                	lw	a1,48(s1)
    8000323e:	00005517          	auipc	a0,0x5
    80003242:	27250513          	addi	a0,a0,626 # 800084b0 <states.0+0x188>
    80003246:	ffffd097          	auipc	ra,0xffffd
    8000324a:	344080e7          	jalr	836(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000324e:	6cbc                	ld	a5,88(s1)
    80003250:	577d                	li	a4,-1
    80003252:	fbb8                	sd	a4,112(a5)
  }
}
    80003254:	70a2                	ld	ra,40(sp)
    80003256:	7402                	ld	s0,32(sp)
    80003258:	64e2                	ld	s1,24(sp)
    8000325a:	6942                	ld	s2,16(sp)
    8000325c:	69a2                	ld	s3,8(sp)
    8000325e:	6a02                	ld	s4,0(sp)
    80003260:	6145                	addi	sp,sp,48
    80003262:	8082                	ret

0000000080003264 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003264:	1101                	addi	sp,sp,-32
    80003266:	ec06                	sd	ra,24(sp)
    80003268:	e822                	sd	s0,16(sp)
    8000326a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000326c:	fec40593          	addi	a1,s0,-20
    80003270:	4501                	li	a0,0
    80003272:	00000097          	auipc	ra,0x0
    80003276:	ea6080e7          	jalr	-346(ra) # 80003118 <argint>
  exit(n);
    8000327a:	fec42503          	lw	a0,-20(s0)
    8000327e:	fffff097          	auipc	ra,0xfffff
    80003282:	35a080e7          	jalr	858(ra) # 800025d8 <exit>
  return 0; // not reached
}
    80003286:	4501                	li	a0,0
    80003288:	60e2                	ld	ra,24(sp)
    8000328a:	6442                	ld	s0,16(sp)
    8000328c:	6105                	addi	sp,sp,32
    8000328e:	8082                	ret

0000000080003290 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003290:	1141                	addi	sp,sp,-16
    80003292:	e406                	sd	ra,8(sp)
    80003294:	e022                	sd	s0,0(sp)
    80003296:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003298:	fffff097          	auipc	ra,0xfffff
    8000329c:	8e2080e7          	jalr	-1822(ra) # 80001b7a <myproc>
}
    800032a0:	5908                	lw	a0,48(a0)
    800032a2:	60a2                	ld	ra,8(sp)
    800032a4:	6402                	ld	s0,0(sp)
    800032a6:	0141                	addi	sp,sp,16
    800032a8:	8082                	ret

00000000800032aa <sys_fork>:

uint64
sys_fork(void)
{
    800032aa:	1141                	addi	sp,sp,-16
    800032ac:	e406                	sd	ra,8(sp)
    800032ae:	e022                	sd	s0,0(sp)
    800032b0:	0800                	addi	s0,sp,16
  return fork();
    800032b2:	fffff097          	auipc	ra,0xfffff
    800032b6:	d12080e7          	jalr	-750(ra) # 80001fc4 <fork>
}
    800032ba:	60a2                	ld	ra,8(sp)
    800032bc:	6402                	ld	s0,0(sp)
    800032be:	0141                	addi	sp,sp,16
    800032c0:	8082                	ret

00000000800032c2 <sys_wait>:

uint64
sys_wait(void)
{
    800032c2:	1101                	addi	sp,sp,-32
    800032c4:	ec06                	sd	ra,24(sp)
    800032c6:	e822                	sd	s0,16(sp)
    800032c8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800032ca:	fe840593          	addi	a1,s0,-24
    800032ce:	4501                	li	a0,0
    800032d0:	00000097          	auipc	ra,0x0
    800032d4:	e68080e7          	jalr	-408(ra) # 80003138 <argaddr>
  return wait(p);
    800032d8:	fe843503          	ld	a0,-24(s0)
    800032dc:	fffff097          	auipc	ra,0xfffff
    800032e0:	4ae080e7          	jalr	1198(ra) # 8000278a <wait>
}
    800032e4:	60e2                	ld	ra,24(sp)
    800032e6:	6442                	ld	s0,16(sp)
    800032e8:	6105                	addi	sp,sp,32
    800032ea:	8082                	ret

00000000800032ec <sys_waitx>:

uint64
sys_waitx(void)
{
    800032ec:	7139                	addi	sp,sp,-64
    800032ee:	fc06                	sd	ra,56(sp)
    800032f0:	f822                	sd	s0,48(sp)
    800032f2:	f426                	sd	s1,40(sp)
    800032f4:	f04a                	sd	s2,32(sp)
    800032f6:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800032f8:	fd840593          	addi	a1,s0,-40
    800032fc:	4501                	li	a0,0
    800032fe:	00000097          	auipc	ra,0x0
    80003302:	e3a080e7          	jalr	-454(ra) # 80003138 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003306:	fd040593          	addi	a1,s0,-48
    8000330a:	4505                	li	a0,1
    8000330c:	00000097          	auipc	ra,0x0
    80003310:	e2c080e7          	jalr	-468(ra) # 80003138 <argaddr>
  argaddr(2, &addr2);
    80003314:	fc840593          	addi	a1,s0,-56
    80003318:	4509                	li	a0,2
    8000331a:	00000097          	auipc	ra,0x0
    8000331e:	e1e080e7          	jalr	-482(ra) # 80003138 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003322:	fc040613          	addi	a2,s0,-64
    80003326:	fc440593          	addi	a1,s0,-60
    8000332a:	fd843503          	ld	a0,-40(s0)
    8000332e:	fffff097          	auipc	ra,0xfffff
    80003332:	06e080e7          	jalr	110(ra) # 8000239c <waitx>
    80003336:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003338:	fffff097          	auipc	ra,0xfffff
    8000333c:	842080e7          	jalr	-1982(ra) # 80001b7a <myproc>
    80003340:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003342:	4691                	li	a3,4
    80003344:	fc440613          	addi	a2,s0,-60
    80003348:	fd043583          	ld	a1,-48(s0)
    8000334c:	6928                	ld	a0,80(a0)
    8000334e:	ffffe097          	auipc	ra,0xffffe
    80003352:	4b0080e7          	jalr	1200(ra) # 800017fe <copyout>
    return -1;
    80003356:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003358:	00054f63          	bltz	a0,80003376 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    8000335c:	4691                	li	a3,4
    8000335e:	fc040613          	addi	a2,s0,-64
    80003362:	fc843583          	ld	a1,-56(s0)
    80003366:	68a8                	ld	a0,80(s1)
    80003368:	ffffe097          	auipc	ra,0xffffe
    8000336c:	496080e7          	jalr	1174(ra) # 800017fe <copyout>
    80003370:	00054a63          	bltz	a0,80003384 <sys_waitx+0x98>
    return -1;
  return ret;
    80003374:	87ca                	mv	a5,s2
}
    80003376:	853e                	mv	a0,a5
    80003378:	70e2                	ld	ra,56(sp)
    8000337a:	7442                	ld	s0,48(sp)
    8000337c:	74a2                	ld	s1,40(sp)
    8000337e:	7902                	ld	s2,32(sp)
    80003380:	6121                	addi	sp,sp,64
    80003382:	8082                	ret
    return -1;
    80003384:	57fd                	li	a5,-1
    80003386:	bfc5                	j	80003376 <sys_waitx+0x8a>

0000000080003388 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003388:	7179                	addi	sp,sp,-48
    8000338a:	f406                	sd	ra,40(sp)
    8000338c:	f022                	sd	s0,32(sp)
    8000338e:	ec26                	sd	s1,24(sp)
    80003390:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003392:	fdc40593          	addi	a1,s0,-36
    80003396:	4501                	li	a0,0
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	d80080e7          	jalr	-640(ra) # 80003118 <argint>
  addr = myproc()->sz;
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	7da080e7          	jalr	2010(ra) # 80001b7a <myproc>
    800033a8:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    800033aa:	fdc42503          	lw	a0,-36(s0)
    800033ae:	fffff097          	auipc	ra,0xfffff
    800033b2:	bba080e7          	jalr	-1094(ra) # 80001f68 <growproc>
    800033b6:	00054863          	bltz	a0,800033c6 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800033ba:	8526                	mv	a0,s1
    800033bc:	70a2                	ld	ra,40(sp)
    800033be:	7402                	ld	s0,32(sp)
    800033c0:	64e2                	ld	s1,24(sp)
    800033c2:	6145                	addi	sp,sp,48
    800033c4:	8082                	ret
    return -1;
    800033c6:	54fd                	li	s1,-1
    800033c8:	bfcd                	j	800033ba <sys_sbrk+0x32>

00000000800033ca <sys_sleep>:

uint64
sys_sleep(void)
{
    800033ca:	7139                	addi	sp,sp,-64
    800033cc:	fc06                	sd	ra,56(sp)
    800033ce:	f822                	sd	s0,48(sp)
    800033d0:	f426                	sd	s1,40(sp)
    800033d2:	f04a                	sd	s2,32(sp)
    800033d4:	ec4e                	sd	s3,24(sp)
    800033d6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800033d8:	fcc40593          	addi	a1,s0,-52
    800033dc:	4501                	li	a0,0
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	d3a080e7          	jalr	-710(ra) # 80003118 <argint>
  acquire(&tickslock);
    800033e6:	00236517          	auipc	a0,0x236
    800033ea:	a8a50513          	addi	a0,a0,-1398 # 80238e70 <tickslock>
    800033ee:	ffffe097          	auipc	ra,0xffffe
    800033f2:	95c080e7          	jalr	-1700(ra) # 80000d4a <acquire>
  ticks0 = ticks;
    800033f6:	00005917          	auipc	s2,0x5
    800033fa:	7a292903          	lw	s2,1954(s2) # 80008b98 <ticks>
  while (ticks - ticks0 < n)
    800033fe:	fcc42783          	lw	a5,-52(s0)
    80003402:	cf9d                	beqz	a5,80003440 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003404:	00236997          	auipc	s3,0x236
    80003408:	a6c98993          	addi	s3,s3,-1428 # 80238e70 <tickslock>
    8000340c:	00005497          	auipc	s1,0x5
    80003410:	78c48493          	addi	s1,s1,1932 # 80008b98 <ticks>
    if (killed(myproc()))
    80003414:	ffffe097          	auipc	ra,0xffffe
    80003418:	766080e7          	jalr	1894(ra) # 80001b7a <myproc>
    8000341c:	fffff097          	auipc	ra,0xfffff
    80003420:	33c080e7          	jalr	828(ra) # 80002758 <killed>
    80003424:	ed15                	bnez	a0,80003460 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003426:	85ce                	mv	a1,s3
    80003428:	8526                	mv	a0,s1
    8000342a:	fffff097          	auipc	ra,0xfffff
    8000342e:	f02080e7          	jalr	-254(ra) # 8000232c <sleep>
  while (ticks - ticks0 < n)
    80003432:	409c                	lw	a5,0(s1)
    80003434:	412787bb          	subw	a5,a5,s2
    80003438:	fcc42703          	lw	a4,-52(s0)
    8000343c:	fce7ece3          	bltu	a5,a4,80003414 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003440:	00236517          	auipc	a0,0x236
    80003444:	a3050513          	addi	a0,a0,-1488 # 80238e70 <tickslock>
    80003448:	ffffe097          	auipc	ra,0xffffe
    8000344c:	9b6080e7          	jalr	-1610(ra) # 80000dfe <release>
  return 0;
    80003450:	4501                	li	a0,0
}
    80003452:	70e2                	ld	ra,56(sp)
    80003454:	7442                	ld	s0,48(sp)
    80003456:	74a2                	ld	s1,40(sp)
    80003458:	7902                	ld	s2,32(sp)
    8000345a:	69e2                	ld	s3,24(sp)
    8000345c:	6121                	addi	sp,sp,64
    8000345e:	8082                	ret
      release(&tickslock);
    80003460:	00236517          	auipc	a0,0x236
    80003464:	a1050513          	addi	a0,a0,-1520 # 80238e70 <tickslock>
    80003468:	ffffe097          	auipc	ra,0xffffe
    8000346c:	996080e7          	jalr	-1642(ra) # 80000dfe <release>
      return -1;
    80003470:	557d                	li	a0,-1
    80003472:	b7c5                	j	80003452 <sys_sleep+0x88>

0000000080003474 <sys_kill>:

uint64
sys_kill(void)
{
    80003474:	1101                	addi	sp,sp,-32
    80003476:	ec06                	sd	ra,24(sp)
    80003478:	e822                	sd	s0,16(sp)
    8000347a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000347c:	fec40593          	addi	a1,s0,-20
    80003480:	4501                	li	a0,0
    80003482:	00000097          	auipc	ra,0x0
    80003486:	c96080e7          	jalr	-874(ra) # 80003118 <argint>
  return kill(pid);
    8000348a:	fec42503          	lw	a0,-20(s0)
    8000348e:	fffff097          	auipc	ra,0xfffff
    80003492:	22c080e7          	jalr	556(ra) # 800026ba <kill>
}
    80003496:	60e2                	ld	ra,24(sp)
    80003498:	6442                	ld	s0,16(sp)
    8000349a:	6105                	addi	sp,sp,32
    8000349c:	8082                	ret

000000008000349e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000349e:	1101                	addi	sp,sp,-32
    800034a0:	ec06                	sd	ra,24(sp)
    800034a2:	e822                	sd	s0,16(sp)
    800034a4:	e426                	sd	s1,8(sp)
    800034a6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800034a8:	00236517          	auipc	a0,0x236
    800034ac:	9c850513          	addi	a0,a0,-1592 # 80238e70 <tickslock>
    800034b0:	ffffe097          	auipc	ra,0xffffe
    800034b4:	89a080e7          	jalr	-1894(ra) # 80000d4a <acquire>
  xticks = ticks;
    800034b8:	00005497          	auipc	s1,0x5
    800034bc:	6e04a483          	lw	s1,1760(s1) # 80008b98 <ticks>
  release(&tickslock);
    800034c0:	00236517          	auipc	a0,0x236
    800034c4:	9b050513          	addi	a0,a0,-1616 # 80238e70 <tickslock>
    800034c8:	ffffe097          	auipc	ra,0xffffe
    800034cc:	936080e7          	jalr	-1738(ra) # 80000dfe <release>
  return xticks;
}
    800034d0:	02049513          	slli	a0,s1,0x20
    800034d4:	9101                	srli	a0,a0,0x20
    800034d6:	60e2                	ld	ra,24(sp)
    800034d8:	6442                	ld	s0,16(sp)
    800034da:	64a2                	ld	s1,8(sp)
    800034dc:	6105                	addi	sp,sp,32
    800034de:	8082                	ret

00000000800034e0 <sys_trace>:

// system trace
uint64 sys_trace(void)
{
    800034e0:	7179                	addi	sp,sp,-48
    800034e2:	f406                	sd	ra,40(sp)
    800034e4:	f022                	sd	s0,32(sp)
    800034e6:	ec26                	sd	s1,24(sp)
    800034e8:	1800                	addi	s0,sp,48
  int tmask;
  argint(0, &tmask);
    800034ea:	fdc40593          	addi	a1,s0,-36
    800034ee:	4501                	li	a0,0
    800034f0:	00000097          	auipc	ra,0x0
    800034f4:	c28080e7          	jalr	-984(ra) # 80003118 <argint>
  myproc()->tmask = tmask;
    800034f8:	fdc42483          	lw	s1,-36(s0)
    800034fc:	ffffe097          	auipc	ra,0xffffe
    80003500:	67e080e7          	jalr	1662(ra) # 80001b7a <myproc>
    80003504:	16952a23          	sw	s1,372(a0)
  return 0;
}
    80003508:	4501                	li	a0,0
    8000350a:	70a2                	ld	ra,40(sp)
    8000350c:	7402                	ld	s0,32(sp)
    8000350e:	64e2                	ld	s1,24(sp)
    80003510:	6145                	addi	sp,sp,48
    80003512:	8082                	ret

0000000080003514 <sys_settickets>:

// system setticket
int sys_settickets(void)
{
    80003514:	7179                	addi	sp,sp,-48
    80003516:	f406                	sd	ra,40(sp)
    80003518:	f022                	sd	s0,32(sp)
    8000351a:	ec26                	sd	s1,24(sp)
    8000351c:	1800                	addi	s0,sp,48
  int number;
  argint(0, &number);
    8000351e:	fdc40593          	addi	a1,s0,-36
    80003522:	4501                	li	a0,0
    80003524:	00000097          	auipc	ra,0x0
    80003528:	bf4080e7          	jalr	-1036(ra) # 80003118 <argint>
  acquire(&(myproc())->lock);
    8000352c:	ffffe097          	auipc	ra,0xffffe
    80003530:	64e080e7          	jalr	1614(ra) # 80001b7a <myproc>
    80003534:	ffffe097          	auipc	ra,0xffffe
    80003538:	816080e7          	jalr	-2026(ra) # 80000d4a <acquire>
  myproc()->tickets = number;
    8000353c:	fdc42483          	lw	s1,-36(s0)
    80003540:	ffffe097          	auipc	ra,0xffffe
    80003544:	63a080e7          	jalr	1594(ra) # 80001b7a <myproc>
    80003548:	16952c23          	sw	s1,376(a0)
  release(&(myproc())->lock);
    8000354c:	ffffe097          	auipc	ra,0xffffe
    80003550:	62e080e7          	jalr	1582(ra) # 80001b7a <myproc>
    80003554:	ffffe097          	auipc	ra,0xffffe
    80003558:	8aa080e7          	jalr	-1878(ra) # 80000dfe <release>
  return 0;
}
    8000355c:	4501                	li	a0,0
    8000355e:	70a2                	ld	ra,40(sp)
    80003560:	7402                	ld	s0,32(sp)
    80003562:	64e2                	ld	s1,24(sp)
    80003564:	6145                	addi	sp,sp,48
    80003566:	8082                	ret

0000000080003568 <sys_sigalarm>:

// sigalarm
uint64 sys_sigalarm(void)
{
    80003568:	1101                	addi	sp,sp,-32
    8000356a:	ec06                	sd	ra,24(sp)
    8000356c:	e822                	sd	s0,16(sp)
    8000356e:	1000                	addi	s0,sp,32
  int interval;
  uint64 fn;
  argint(0, &interval);
    80003570:	fec40593          	addi	a1,s0,-20
    80003574:	4501                	li	a0,0
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	ba2080e7          	jalr	-1118(ra) # 80003118 <argint>
  argaddr(1, &fn);
    8000357e:	fe040593          	addi	a1,s0,-32
    80003582:	4505                	li	a0,1
    80003584:	00000097          	auipc	ra,0x0
    80003588:	bb4080e7          	jalr	-1100(ra) # 80003138 <argaddr>

  struct proc *p = myproc();
    8000358c:	ffffe097          	auipc	ra,0xffffe
    80003590:	5ee080e7          	jalr	1518(ra) # 80001b7a <myproc>

  p->sigalarm_status = 0;
    80003594:	1c052023          	sw	zero,448(a0)
  p->interval = interval;
    80003598:	fec42783          	lw	a5,-20(s0)
    8000359c:	1af52823          	sw	a5,432(a0)
  p->now_ticks = 0;
    800035a0:	1a052a23          	sw	zero,436(a0)
  p->handler = fn;
    800035a4:	fe043783          	ld	a5,-32(s0)
    800035a8:	1af53423          	sd	a5,424(a0)

  return 0;
}
    800035ac:	4501                	li	a0,0
    800035ae:	60e2                	ld	ra,24(sp)
    800035b0:	6442                	ld	s0,16(sp)
    800035b2:	6105                	addi	sp,sp,32
    800035b4:	8082                	ret

00000000800035b6 <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    800035b6:	1101                	addi	sp,sp,-32
    800035b8:	ec06                	sd	ra,24(sp)
    800035ba:	e822                	sd	s0,16(sp)
    800035bc:	e426                	sd	s1,8(sp)
    800035be:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800035c0:	ffffe097          	auipc	ra,0xffffe
    800035c4:	5ba080e7          	jalr	1466(ra) # 80001b7a <myproc>
    800035c8:	84aa                	mv	s1,a0

  // Restore Kernel Values
  memmove(p->trapframe, p->alarm_trapframe, PGSIZE);
    800035ca:	6605                	lui	a2,0x1
    800035cc:	1b853583          	ld	a1,440(a0)
    800035d0:	6d28                	ld	a0,88(a0)
    800035d2:	ffffe097          	auipc	ra,0xffffe
    800035d6:	8d0080e7          	jalr	-1840(ra) # 80000ea2 <memmove>
  kfree(p->alarm_trapframe);
    800035da:	1b84b503          	ld	a0,440(s1)
    800035de:	ffffd097          	auipc	ra,0xffffd
    800035e2:	49a080e7          	jalr	1178(ra) # 80000a78 <kfree>

  p->sigalarm_status = 0;
    800035e6:	1c04a023          	sw	zero,448(s1)
  p->alarm_trapframe = 0;
    800035ea:	1a04bc23          	sd	zero,440(s1)
  p->now_ticks = 0;
    800035ee:	1a04aa23          	sw	zero,436(s1)
  usertrapret();
    800035f2:	fffff097          	auipc	ra,0xfffff
    800035f6:	55a080e7          	jalr	1370(ra) # 80002b4c <usertrapret>
  return 0;
}
    800035fa:	4501                	li	a0,0
    800035fc:	60e2                	ld	ra,24(sp)
    800035fe:	6442                	ld	s0,16(sp)
    80003600:	64a2                	ld	s1,8(sp)
    80003602:	6105                	addi	sp,sp,32
    80003604:	8082                	ret

0000000080003606 <sys_setpriority>:

uint64 sys_setpriority(void)
{
    80003606:	1101                	addi	sp,sp,-32
    80003608:	ec06                	sd	ra,24(sp)
    8000360a:	e822                	sd	s0,16(sp)
    8000360c:	1000                	addi	s0,sp,32
  int number, piid;
  argint(0, &number);
    8000360e:	fec40593          	addi	a1,s0,-20
    80003612:	4501                	li	a0,0
    80003614:	00000097          	auipc	ra,0x0
    80003618:	b04080e7          	jalr	-1276(ra) # 80003118 <argint>
  argint(1, &piid);
    8000361c:	fe840593          	addi	a1,s0,-24
    80003620:	4505                	li	a0,1
    80003622:	00000097          	auipc	ra,0x0
    80003626:	af6080e7          	jalr	-1290(ra) # 80003118 <argint>
  setpriority(number, piid);
    8000362a:	fe842583          	lw	a1,-24(s0)
    8000362e:	fec42503          	lw	a0,-20(s0)
    80003632:	fffff097          	auipc	ra,0xfffff
    80003636:	3ea080e7          	jalr	1002(ra) # 80002a1c <setpriority>
  return 0;
    8000363a:	4501                	li	a0,0
    8000363c:	60e2                	ld	ra,24(sp)
    8000363e:	6442                	ld	s0,16(sp)
    80003640:	6105                	addi	sp,sp,32
    80003642:	8082                	ret

0000000080003644 <binit>:
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void binit(void)
{
    80003644:	7179                	addi	sp,sp,-48
    80003646:	f406                	sd	ra,40(sp)
    80003648:	f022                	sd	s0,32(sp)
    8000364a:	ec26                	sd	s1,24(sp)
    8000364c:	e84a                	sd	s2,16(sp)
    8000364e:	e44e                	sd	s3,8(sp)
    80003650:	e052                	sd	s4,0(sp)
    80003652:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003654:	00005597          	auipc	a1,0x5
    80003658:	06458593          	addi	a1,a1,100 # 800086b8 <syscalls+0xe0>
    8000365c:	00236517          	auipc	a0,0x236
    80003660:	82c50513          	addi	a0,a0,-2004 # 80238e88 <bcache>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	656080e7          	jalr	1622(ra) # 80000cba <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000366c:	0023e797          	auipc	a5,0x23e
    80003670:	81c78793          	addi	a5,a5,-2020 # 80240e88 <bcache+0x8000>
    80003674:	0023e717          	auipc	a4,0x23e
    80003678:	a7c70713          	addi	a4,a4,-1412 # 802410f0 <bcache+0x8268>
    8000367c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003680:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    80003684:	00236497          	auipc	s1,0x236
    80003688:	81c48493          	addi	s1,s1,-2020 # 80238ea0 <bcache+0x18>
  {
    b->next = bcache.head.next;
    8000368c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000368e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003690:	00005a17          	auipc	s4,0x5
    80003694:	030a0a13          	addi	s4,s4,48 # 800086c0 <syscalls+0xe8>
    b->next = bcache.head.next;
    80003698:	2b893783          	ld	a5,696(s2)
    8000369c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000369e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800036a2:	85d2                	mv	a1,s4
    800036a4:	01048513          	addi	a0,s1,16
    800036a8:	00001097          	auipc	ra,0x1
    800036ac:	4c8080e7          	jalr	1224(ra) # 80004b70 <initsleeplock>
    bcache.head.next->prev = b;
    800036b0:	2b893783          	ld	a5,696(s2)
    800036b4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800036b6:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    800036ba:	45848493          	addi	s1,s1,1112
    800036be:	fd349de3          	bne	s1,s3,80003698 <binit+0x54>
  }
}
    800036c2:	70a2                	ld	ra,40(sp)
    800036c4:	7402                	ld	s0,32(sp)
    800036c6:	64e2                	ld	s1,24(sp)
    800036c8:	6942                	ld	s2,16(sp)
    800036ca:	69a2                	ld	s3,8(sp)
    800036cc:	6a02                	ld	s4,0(sp)
    800036ce:	6145                	addi	sp,sp,48
    800036d0:	8082                	ret

00000000800036d2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    800036d2:	7179                	addi	sp,sp,-48
    800036d4:	f406                	sd	ra,40(sp)
    800036d6:	f022                	sd	s0,32(sp)
    800036d8:	ec26                	sd	s1,24(sp)
    800036da:	e84a                	sd	s2,16(sp)
    800036dc:	e44e                	sd	s3,8(sp)
    800036de:	1800                	addi	s0,sp,48
    800036e0:	892a                	mv	s2,a0
    800036e2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800036e4:	00235517          	auipc	a0,0x235
    800036e8:	7a450513          	addi	a0,a0,1956 # 80238e88 <bcache>
    800036ec:	ffffd097          	auipc	ra,0xffffd
    800036f0:	65e080e7          	jalr	1630(ra) # 80000d4a <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next)
    800036f4:	0023e497          	auipc	s1,0x23e
    800036f8:	a4c4b483          	ld	s1,-1460(s1) # 80241140 <bcache+0x82b8>
    800036fc:	0023e797          	auipc	a5,0x23e
    80003700:	9f478793          	addi	a5,a5,-1548 # 802410f0 <bcache+0x8268>
    80003704:	02f48f63          	beq	s1,a5,80003742 <bread+0x70>
    80003708:	873e                	mv	a4,a5
    8000370a:	a021                	j	80003712 <bread+0x40>
    8000370c:	68a4                	ld	s1,80(s1)
    8000370e:	02e48a63          	beq	s1,a4,80003742 <bread+0x70>
    if (b->dev == dev && b->blockno == blockno)
    80003712:	449c                	lw	a5,8(s1)
    80003714:	ff279ce3          	bne	a5,s2,8000370c <bread+0x3a>
    80003718:	44dc                	lw	a5,12(s1)
    8000371a:	ff3799e3          	bne	a5,s3,8000370c <bread+0x3a>
      b->refcnt++;
    8000371e:	40bc                	lw	a5,64(s1)
    80003720:	2785                	addiw	a5,a5,1
    80003722:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003724:	00235517          	auipc	a0,0x235
    80003728:	76450513          	addi	a0,a0,1892 # 80238e88 <bcache>
    8000372c:	ffffd097          	auipc	ra,0xffffd
    80003730:	6d2080e7          	jalr	1746(ra) # 80000dfe <release>
      acquiresleep(&b->lock);
    80003734:	01048513          	addi	a0,s1,16
    80003738:	00001097          	auipc	ra,0x1
    8000373c:	472080e7          	jalr	1138(ra) # 80004baa <acquiresleep>
      return b;
    80003740:	a8b9                	j	8000379e <bread+0xcc>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    80003742:	0023e497          	auipc	s1,0x23e
    80003746:	9f64b483          	ld	s1,-1546(s1) # 80241138 <bcache+0x82b0>
    8000374a:	0023e797          	auipc	a5,0x23e
    8000374e:	9a678793          	addi	a5,a5,-1626 # 802410f0 <bcache+0x8268>
    80003752:	00f48863          	beq	s1,a5,80003762 <bread+0x90>
    80003756:	873e                	mv	a4,a5
    if (b->refcnt == 0)
    80003758:	40bc                	lw	a5,64(s1)
    8000375a:	cf81                	beqz	a5,80003772 <bread+0xa0>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    8000375c:	64a4                	ld	s1,72(s1)
    8000375e:	fee49de3          	bne	s1,a4,80003758 <bread+0x86>
  panic("bget: no buffers");
    80003762:	00005517          	auipc	a0,0x5
    80003766:	f6650513          	addi	a0,a0,-154 # 800086c8 <syscalls+0xf0>
    8000376a:	ffffd097          	auipc	ra,0xffffd
    8000376e:	dd6080e7          	jalr	-554(ra) # 80000540 <panic>
      b->dev = dev;
    80003772:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003776:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000377a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000377e:	4785                	li	a5,1
    80003780:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003782:	00235517          	auipc	a0,0x235
    80003786:	70650513          	addi	a0,a0,1798 # 80238e88 <bcache>
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	674080e7          	jalr	1652(ra) # 80000dfe <release>
      acquiresleep(&b->lock);
    80003792:	01048513          	addi	a0,s1,16
    80003796:	00001097          	auipc	ra,0x1
    8000379a:	414080e7          	jalr	1044(ra) # 80004baa <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid)
    8000379e:	409c                	lw	a5,0(s1)
    800037a0:	cb89                	beqz	a5,800037b2 <bread+0xe0>
  {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800037a2:	8526                	mv	a0,s1
    800037a4:	70a2                	ld	ra,40(sp)
    800037a6:	7402                	ld	s0,32(sp)
    800037a8:	64e2                	ld	s1,24(sp)
    800037aa:	6942                	ld	s2,16(sp)
    800037ac:	69a2                	ld	s3,8(sp)
    800037ae:	6145                	addi	sp,sp,48
    800037b0:	8082                	ret
    virtio_disk_rw(b, 0);
    800037b2:	4581                	li	a1,0
    800037b4:	8526                	mv	a0,s1
    800037b6:	00003097          	auipc	ra,0x3
    800037ba:	2b0080e7          	jalr	688(ra) # 80006a66 <virtio_disk_rw>
    b->valid = 1;
    800037be:	4785                	li	a5,1
    800037c0:	c09c                	sw	a5,0(s1)
  return b;
    800037c2:	b7c5                	j	800037a2 <bread+0xd0>

00000000800037c4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
    800037c4:	1101                	addi	sp,sp,-32
    800037c6:	ec06                	sd	ra,24(sp)
    800037c8:	e822                	sd	s0,16(sp)
    800037ca:	e426                	sd	s1,8(sp)
    800037cc:	1000                	addi	s0,sp,32
    800037ce:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800037d0:	0541                	addi	a0,a0,16
    800037d2:	00001097          	auipc	ra,0x1
    800037d6:	472080e7          	jalr	1138(ra) # 80004c44 <holdingsleep>
    800037da:	cd01                	beqz	a0,800037f2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800037dc:	4585                	li	a1,1
    800037de:	8526                	mv	a0,s1
    800037e0:	00003097          	auipc	ra,0x3
    800037e4:	286080e7          	jalr	646(ra) # 80006a66 <virtio_disk_rw>
}
    800037e8:	60e2                	ld	ra,24(sp)
    800037ea:	6442                	ld	s0,16(sp)
    800037ec:	64a2                	ld	s1,8(sp)
    800037ee:	6105                	addi	sp,sp,32
    800037f0:	8082                	ret
    panic("bwrite");
    800037f2:	00005517          	auipc	a0,0x5
    800037f6:	eee50513          	addi	a0,a0,-274 # 800086e0 <syscalls+0x108>
    800037fa:	ffffd097          	auipc	ra,0xffffd
    800037fe:	d46080e7          	jalr	-698(ra) # 80000540 <panic>

0000000080003802 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)
{
    80003802:	1101                	addi	sp,sp,-32
    80003804:	ec06                	sd	ra,24(sp)
    80003806:	e822                	sd	s0,16(sp)
    80003808:	e426                	sd	s1,8(sp)
    8000380a:	e04a                	sd	s2,0(sp)
    8000380c:	1000                	addi	s0,sp,32
    8000380e:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003810:	01050913          	addi	s2,a0,16
    80003814:	854a                	mv	a0,s2
    80003816:	00001097          	auipc	ra,0x1
    8000381a:	42e080e7          	jalr	1070(ra) # 80004c44 <holdingsleep>
    8000381e:	c92d                	beqz	a0,80003890 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003820:	854a                	mv	a0,s2
    80003822:	00001097          	auipc	ra,0x1
    80003826:	3de080e7          	jalr	990(ra) # 80004c00 <releasesleep>

  acquire(&bcache.lock);
    8000382a:	00235517          	auipc	a0,0x235
    8000382e:	65e50513          	addi	a0,a0,1630 # 80238e88 <bcache>
    80003832:	ffffd097          	auipc	ra,0xffffd
    80003836:	518080e7          	jalr	1304(ra) # 80000d4a <acquire>
  b->refcnt--;
    8000383a:	40bc                	lw	a5,64(s1)
    8000383c:	37fd                	addiw	a5,a5,-1
    8000383e:	0007871b          	sext.w	a4,a5
    80003842:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0)
    80003844:	eb05                	bnez	a4,80003874 <brelse+0x72>
  {
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003846:	68bc                	ld	a5,80(s1)
    80003848:	64b8                	ld	a4,72(s1)
    8000384a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000384c:	64bc                	ld	a5,72(s1)
    8000384e:	68b8                	ld	a4,80(s1)
    80003850:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003852:	0023d797          	auipc	a5,0x23d
    80003856:	63678793          	addi	a5,a5,1590 # 80240e88 <bcache+0x8000>
    8000385a:	2b87b703          	ld	a4,696(a5)
    8000385e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003860:	0023e717          	auipc	a4,0x23e
    80003864:	89070713          	addi	a4,a4,-1904 # 802410f0 <bcache+0x8268>
    80003868:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000386a:	2b87b703          	ld	a4,696(a5)
    8000386e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003870:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80003874:	00235517          	auipc	a0,0x235
    80003878:	61450513          	addi	a0,a0,1556 # 80238e88 <bcache>
    8000387c:	ffffd097          	auipc	ra,0xffffd
    80003880:	582080e7          	jalr	1410(ra) # 80000dfe <release>
}
    80003884:	60e2                	ld	ra,24(sp)
    80003886:	6442                	ld	s0,16(sp)
    80003888:	64a2                	ld	s1,8(sp)
    8000388a:	6902                	ld	s2,0(sp)
    8000388c:	6105                	addi	sp,sp,32
    8000388e:	8082                	ret
    panic("brelse");
    80003890:	00005517          	auipc	a0,0x5
    80003894:	e5850513          	addi	a0,a0,-424 # 800086e8 <syscalls+0x110>
    80003898:	ffffd097          	auipc	ra,0xffffd
    8000389c:	ca8080e7          	jalr	-856(ra) # 80000540 <panic>

00000000800038a0 <bpin>:

void bpin(struct buf *b)
{
    800038a0:	1101                	addi	sp,sp,-32
    800038a2:	ec06                	sd	ra,24(sp)
    800038a4:	e822                	sd	s0,16(sp)
    800038a6:	e426                	sd	s1,8(sp)
    800038a8:	1000                	addi	s0,sp,32
    800038aa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038ac:	00235517          	auipc	a0,0x235
    800038b0:	5dc50513          	addi	a0,a0,1500 # 80238e88 <bcache>
    800038b4:	ffffd097          	auipc	ra,0xffffd
    800038b8:	496080e7          	jalr	1174(ra) # 80000d4a <acquire>
  b->refcnt++;
    800038bc:	40bc                	lw	a5,64(s1)
    800038be:	2785                	addiw	a5,a5,1
    800038c0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038c2:	00235517          	auipc	a0,0x235
    800038c6:	5c650513          	addi	a0,a0,1478 # 80238e88 <bcache>
    800038ca:	ffffd097          	auipc	ra,0xffffd
    800038ce:	534080e7          	jalr	1332(ra) # 80000dfe <release>
}
    800038d2:	60e2                	ld	ra,24(sp)
    800038d4:	6442                	ld	s0,16(sp)
    800038d6:	64a2                	ld	s1,8(sp)
    800038d8:	6105                	addi	sp,sp,32
    800038da:	8082                	ret

00000000800038dc <bunpin>:

void bunpin(struct buf *b)
{
    800038dc:	1101                	addi	sp,sp,-32
    800038de:	ec06                	sd	ra,24(sp)
    800038e0:	e822                	sd	s0,16(sp)
    800038e2:	e426                	sd	s1,8(sp)
    800038e4:	1000                	addi	s0,sp,32
    800038e6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038e8:	00235517          	auipc	a0,0x235
    800038ec:	5a050513          	addi	a0,a0,1440 # 80238e88 <bcache>
    800038f0:	ffffd097          	auipc	ra,0xffffd
    800038f4:	45a080e7          	jalr	1114(ra) # 80000d4a <acquire>
  b->refcnt--;
    800038f8:	40bc                	lw	a5,64(s1)
    800038fa:	37fd                	addiw	a5,a5,-1
    800038fc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038fe:	00235517          	auipc	a0,0x235
    80003902:	58a50513          	addi	a0,a0,1418 # 80238e88 <bcache>
    80003906:	ffffd097          	auipc	ra,0xffffd
    8000390a:	4f8080e7          	jalr	1272(ra) # 80000dfe <release>
}
    8000390e:	60e2                	ld	ra,24(sp)
    80003910:	6442                	ld	s0,16(sp)
    80003912:	64a2                	ld	s1,8(sp)
    80003914:	6105                	addi	sp,sp,32
    80003916:	8082                	ret

0000000080003918 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003918:	1101                	addi	sp,sp,-32
    8000391a:	ec06                	sd	ra,24(sp)
    8000391c:	e822                	sd	s0,16(sp)
    8000391e:	e426                	sd	s1,8(sp)
    80003920:	e04a                	sd	s2,0(sp)
    80003922:	1000                	addi	s0,sp,32
    80003924:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003926:	00d5d59b          	srliw	a1,a1,0xd
    8000392a:	0023e797          	auipc	a5,0x23e
    8000392e:	c3a7a783          	lw	a5,-966(a5) # 80241564 <sb+0x1c>
    80003932:	9dbd                	addw	a1,a1,a5
    80003934:	00000097          	auipc	ra,0x0
    80003938:	d9e080e7          	jalr	-610(ra) # 800036d2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000393c:	0074f713          	andi	a4,s1,7
    80003940:	4785                	li	a5,1
    80003942:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80003946:	14ce                	slli	s1,s1,0x33
    80003948:	90d9                	srli	s1,s1,0x36
    8000394a:	00950733          	add	a4,a0,s1
    8000394e:	05874703          	lbu	a4,88(a4)
    80003952:	00e7f6b3          	and	a3,a5,a4
    80003956:	c69d                	beqz	a3,80003984 <bfree+0x6c>
    80003958:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    8000395a:	94aa                	add	s1,s1,a0
    8000395c:	fff7c793          	not	a5,a5
    80003960:	8f7d                	and	a4,a4,a5
    80003962:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003966:	00001097          	auipc	ra,0x1
    8000396a:	126080e7          	jalr	294(ra) # 80004a8c <log_write>
  brelse(bp);
    8000396e:	854a                	mv	a0,s2
    80003970:	00000097          	auipc	ra,0x0
    80003974:	e92080e7          	jalr	-366(ra) # 80003802 <brelse>
}
    80003978:	60e2                	ld	ra,24(sp)
    8000397a:	6442                	ld	s0,16(sp)
    8000397c:	64a2                	ld	s1,8(sp)
    8000397e:	6902                	ld	s2,0(sp)
    80003980:	6105                	addi	sp,sp,32
    80003982:	8082                	ret
    panic("freeing free block");
    80003984:	00005517          	auipc	a0,0x5
    80003988:	d6c50513          	addi	a0,a0,-660 # 800086f0 <syscalls+0x118>
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	bb4080e7          	jalr	-1100(ra) # 80000540 <panic>

0000000080003994 <balloc>:
{
    80003994:	711d                	addi	sp,sp,-96
    80003996:	ec86                	sd	ra,88(sp)
    80003998:	e8a2                	sd	s0,80(sp)
    8000399a:	e4a6                	sd	s1,72(sp)
    8000399c:	e0ca                	sd	s2,64(sp)
    8000399e:	fc4e                	sd	s3,56(sp)
    800039a0:	f852                	sd	s4,48(sp)
    800039a2:	f456                	sd	s5,40(sp)
    800039a4:	f05a                	sd	s6,32(sp)
    800039a6:	ec5e                	sd	s7,24(sp)
    800039a8:	e862                	sd	s8,16(sp)
    800039aa:	e466                	sd	s9,8(sp)
    800039ac:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB)
    800039ae:	0023e797          	auipc	a5,0x23e
    800039b2:	b9e7a783          	lw	a5,-1122(a5) # 8024154c <sb+0x4>
    800039b6:	cff5                	beqz	a5,80003ab2 <balloc+0x11e>
    800039b8:	8baa                	mv	s7,a0
    800039ba:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800039bc:	0023eb17          	auipc	s6,0x23e
    800039c0:	b8cb0b13          	addi	s6,s6,-1140 # 80241548 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800039c4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800039c6:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800039c8:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB)
    800039ca:	6c89                	lui	s9,0x2
    800039cc:	a061                	j	80003a54 <balloc+0xc0>
        bp->data[bi / 8] |= m; // Mark block in use.
    800039ce:	97ca                	add	a5,a5,s2
    800039d0:	8e55                	or	a2,a2,a3
    800039d2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800039d6:	854a                	mv	a0,s2
    800039d8:	00001097          	auipc	ra,0x1
    800039dc:	0b4080e7          	jalr	180(ra) # 80004a8c <log_write>
        brelse(bp);
    800039e0:	854a                	mv	a0,s2
    800039e2:	00000097          	auipc	ra,0x0
    800039e6:	e20080e7          	jalr	-480(ra) # 80003802 <brelse>
  bp = bread(dev, bno);
    800039ea:	85a6                	mv	a1,s1
    800039ec:	855e                	mv	a0,s7
    800039ee:	00000097          	auipc	ra,0x0
    800039f2:	ce4080e7          	jalr	-796(ra) # 800036d2 <bread>
    800039f6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800039f8:	40000613          	li	a2,1024
    800039fc:	4581                	li	a1,0
    800039fe:	05850513          	addi	a0,a0,88
    80003a02:	ffffd097          	auipc	ra,0xffffd
    80003a06:	444080e7          	jalr	1092(ra) # 80000e46 <memset>
  log_write(bp);
    80003a0a:	854a                	mv	a0,s2
    80003a0c:	00001097          	auipc	ra,0x1
    80003a10:	080080e7          	jalr	128(ra) # 80004a8c <log_write>
  brelse(bp);
    80003a14:	854a                	mv	a0,s2
    80003a16:	00000097          	auipc	ra,0x0
    80003a1a:	dec080e7          	jalr	-532(ra) # 80003802 <brelse>
}
    80003a1e:	8526                	mv	a0,s1
    80003a20:	60e6                	ld	ra,88(sp)
    80003a22:	6446                	ld	s0,80(sp)
    80003a24:	64a6                	ld	s1,72(sp)
    80003a26:	6906                	ld	s2,64(sp)
    80003a28:	79e2                	ld	s3,56(sp)
    80003a2a:	7a42                	ld	s4,48(sp)
    80003a2c:	7aa2                	ld	s5,40(sp)
    80003a2e:	7b02                	ld	s6,32(sp)
    80003a30:	6be2                	ld	s7,24(sp)
    80003a32:	6c42                	ld	s8,16(sp)
    80003a34:	6ca2                	ld	s9,8(sp)
    80003a36:	6125                	addi	sp,sp,96
    80003a38:	8082                	ret
    brelse(bp);
    80003a3a:	854a                	mv	a0,s2
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	dc6080e7          	jalr	-570(ra) # 80003802 <brelse>
  for (b = 0; b < sb.size; b += BPB)
    80003a44:	015c87bb          	addw	a5,s9,s5
    80003a48:	00078a9b          	sext.w	s5,a5
    80003a4c:	004b2703          	lw	a4,4(s6)
    80003a50:	06eaf163          	bgeu	s5,a4,80003ab2 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003a54:	41fad79b          	sraiw	a5,s5,0x1f
    80003a58:	0137d79b          	srliw	a5,a5,0x13
    80003a5c:	015787bb          	addw	a5,a5,s5
    80003a60:	40d7d79b          	sraiw	a5,a5,0xd
    80003a64:	01cb2583          	lw	a1,28(s6)
    80003a68:	9dbd                	addw	a1,a1,a5
    80003a6a:	855e                	mv	a0,s7
    80003a6c:	00000097          	auipc	ra,0x0
    80003a70:	c66080e7          	jalr	-922(ra) # 800036d2 <bread>
    80003a74:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003a76:	004b2503          	lw	a0,4(s6)
    80003a7a:	000a849b          	sext.w	s1,s5
    80003a7e:	8762                	mv	a4,s8
    80003a80:	faa4fde3          	bgeu	s1,a0,80003a3a <balloc+0xa6>
      m = 1 << (bi % 8);
    80003a84:	00777693          	andi	a3,a4,7
    80003a88:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0)
    80003a8c:	41f7579b          	sraiw	a5,a4,0x1f
    80003a90:	01d7d79b          	srliw	a5,a5,0x1d
    80003a94:	9fb9                	addw	a5,a5,a4
    80003a96:	4037d79b          	sraiw	a5,a5,0x3
    80003a9a:	00f90633          	add	a2,s2,a5
    80003a9e:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003aa2:	00c6f5b3          	and	a1,a3,a2
    80003aa6:	d585                	beqz	a1,800039ce <balloc+0x3a>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003aa8:	2705                	addiw	a4,a4,1
    80003aaa:	2485                	addiw	s1,s1,1
    80003aac:	fd471ae3          	bne	a4,s4,80003a80 <balloc+0xec>
    80003ab0:	b769                	j	80003a3a <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003ab2:	00005517          	auipc	a0,0x5
    80003ab6:	c5650513          	addi	a0,a0,-938 # 80008708 <syscalls+0x130>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	ad0080e7          	jalr	-1328(ra) # 8000058a <printf>
  return 0;
    80003ac2:	4481                	li	s1,0
    80003ac4:	bfa9                	j	80003a1e <balloc+0x8a>

0000000080003ac6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003ac6:	7179                	addi	sp,sp,-48
    80003ac8:	f406                	sd	ra,40(sp)
    80003aca:	f022                	sd	s0,32(sp)
    80003acc:	ec26                	sd	s1,24(sp)
    80003ace:	e84a                	sd	s2,16(sp)
    80003ad0:	e44e                	sd	s3,8(sp)
    80003ad2:	e052                	sd	s4,0(sp)
    80003ad4:	1800                	addi	s0,sp,48
    80003ad6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT)
    80003ad8:	47ad                	li	a5,11
    80003ada:	02b7e863          	bltu	a5,a1,80003b0a <bmap+0x44>
  {
    if ((addr = ip->addrs[bn]) == 0)
    80003ade:	02059793          	slli	a5,a1,0x20
    80003ae2:	01e7d593          	srli	a1,a5,0x1e
    80003ae6:	00b504b3          	add	s1,a0,a1
    80003aea:	0504a903          	lw	s2,80(s1)
    80003aee:	06091e63          	bnez	s2,80003b6a <bmap+0xa4>
    {
      addr = balloc(ip->dev);
    80003af2:	4108                	lw	a0,0(a0)
    80003af4:	00000097          	auipc	ra,0x0
    80003af8:	ea0080e7          	jalr	-352(ra) # 80003994 <balloc>
    80003afc:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003b00:	06090563          	beqz	s2,80003b6a <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003b04:	0524a823          	sw	s2,80(s1)
    80003b08:	a08d                	j	80003b6a <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b0a:	ff45849b          	addiw	s1,a1,-12
    80003b0e:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT)
    80003b12:	0ff00793          	li	a5,255
    80003b16:	08e7e563          	bltu	a5,a4,80003ba0 <bmap+0xda>
  {
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0)
    80003b1a:	08052903          	lw	s2,128(a0)
    80003b1e:	00091d63          	bnez	s2,80003b38 <bmap+0x72>
    {
      addr = balloc(ip->dev);
    80003b22:	4108                	lw	a0,0(a0)
    80003b24:	00000097          	auipc	ra,0x0
    80003b28:	e70080e7          	jalr	-400(ra) # 80003994 <balloc>
    80003b2c:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003b30:	02090d63          	beqz	s2,80003b6a <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003b34:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003b38:	85ca                	mv	a1,s2
    80003b3a:	0009a503          	lw	a0,0(s3)
    80003b3e:	00000097          	auipc	ra,0x0
    80003b42:	b94080e7          	jalr	-1132(ra) # 800036d2 <bread>
    80003b46:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003b48:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0)
    80003b4c:	02049713          	slli	a4,s1,0x20
    80003b50:	01e75593          	srli	a1,a4,0x1e
    80003b54:	00b784b3          	add	s1,a5,a1
    80003b58:	0004a903          	lw	s2,0(s1)
    80003b5c:	02090063          	beqz	s2,80003b7c <bmap+0xb6>
      {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003b60:	8552                	mv	a0,s4
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	ca0080e7          	jalr	-864(ra) # 80003802 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003b6a:	854a                	mv	a0,s2
    80003b6c:	70a2                	ld	ra,40(sp)
    80003b6e:	7402                	ld	s0,32(sp)
    80003b70:	64e2                	ld	s1,24(sp)
    80003b72:	6942                	ld	s2,16(sp)
    80003b74:	69a2                	ld	s3,8(sp)
    80003b76:	6a02                	ld	s4,0(sp)
    80003b78:	6145                	addi	sp,sp,48
    80003b7a:	8082                	ret
      addr = balloc(ip->dev);
    80003b7c:	0009a503          	lw	a0,0(s3)
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	e14080e7          	jalr	-492(ra) # 80003994 <balloc>
    80003b88:	0005091b          	sext.w	s2,a0
      if (addr)
    80003b8c:	fc090ae3          	beqz	s2,80003b60 <bmap+0x9a>
        a[bn] = addr;
    80003b90:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003b94:	8552                	mv	a0,s4
    80003b96:	00001097          	auipc	ra,0x1
    80003b9a:	ef6080e7          	jalr	-266(ra) # 80004a8c <log_write>
    80003b9e:	b7c9                	j	80003b60 <bmap+0x9a>
  panic("bmap: out of range");
    80003ba0:	00005517          	auipc	a0,0x5
    80003ba4:	b8050513          	addi	a0,a0,-1152 # 80008720 <syscalls+0x148>
    80003ba8:	ffffd097          	auipc	ra,0xffffd
    80003bac:	998080e7          	jalr	-1640(ra) # 80000540 <panic>

0000000080003bb0 <iget>:
{
    80003bb0:	7179                	addi	sp,sp,-48
    80003bb2:	f406                	sd	ra,40(sp)
    80003bb4:	f022                	sd	s0,32(sp)
    80003bb6:	ec26                	sd	s1,24(sp)
    80003bb8:	e84a                	sd	s2,16(sp)
    80003bba:	e44e                	sd	s3,8(sp)
    80003bbc:	e052                	sd	s4,0(sp)
    80003bbe:	1800                	addi	s0,sp,48
    80003bc0:	89aa                	mv	s3,a0
    80003bc2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003bc4:	0023e517          	auipc	a0,0x23e
    80003bc8:	9a450513          	addi	a0,a0,-1628 # 80241568 <itable>
    80003bcc:	ffffd097          	auipc	ra,0xffffd
    80003bd0:	17e080e7          	jalr	382(ra) # 80000d4a <acquire>
  empty = 0;
    80003bd4:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    80003bd6:	0023e497          	auipc	s1,0x23e
    80003bda:	9aa48493          	addi	s1,s1,-1622 # 80241580 <itable+0x18>
    80003bde:	0023f697          	auipc	a3,0x23f
    80003be2:	43268693          	addi	a3,a3,1074 # 80243010 <log>
    80003be6:	a039                	j	80003bf4 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003be8:	02090b63          	beqz	s2,80003c1e <iget+0x6e>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    80003bec:	08848493          	addi	s1,s1,136
    80003bf0:	02d48a63          	beq	s1,a3,80003c24 <iget+0x74>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum)
    80003bf4:	449c                	lw	a5,8(s1)
    80003bf6:	fef059e3          	blez	a5,80003be8 <iget+0x38>
    80003bfa:	4098                	lw	a4,0(s1)
    80003bfc:	ff3716e3          	bne	a4,s3,80003be8 <iget+0x38>
    80003c00:	40d8                	lw	a4,4(s1)
    80003c02:	ff4713e3          	bne	a4,s4,80003be8 <iget+0x38>
      ip->ref++;
    80003c06:	2785                	addiw	a5,a5,1
    80003c08:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c0a:	0023e517          	auipc	a0,0x23e
    80003c0e:	95e50513          	addi	a0,a0,-1698 # 80241568 <itable>
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	1ec080e7          	jalr	492(ra) # 80000dfe <release>
      return ip;
    80003c1a:	8926                	mv	s2,s1
    80003c1c:	a03d                	j	80003c4a <iget+0x9a>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003c1e:	f7f9                	bnez	a5,80003bec <iget+0x3c>
    80003c20:	8926                	mv	s2,s1
    80003c22:	b7e9                	j	80003bec <iget+0x3c>
  if (empty == 0)
    80003c24:	02090c63          	beqz	s2,80003c5c <iget+0xac>
  ip->dev = dev;
    80003c28:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c2c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003c30:	4785                	li	a5,1
    80003c32:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003c36:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c3a:	0023e517          	auipc	a0,0x23e
    80003c3e:	92e50513          	addi	a0,a0,-1746 # 80241568 <itable>
    80003c42:	ffffd097          	auipc	ra,0xffffd
    80003c46:	1bc080e7          	jalr	444(ra) # 80000dfe <release>
}
    80003c4a:	854a                	mv	a0,s2
    80003c4c:	70a2                	ld	ra,40(sp)
    80003c4e:	7402                	ld	s0,32(sp)
    80003c50:	64e2                	ld	s1,24(sp)
    80003c52:	6942                	ld	s2,16(sp)
    80003c54:	69a2                	ld	s3,8(sp)
    80003c56:	6a02                	ld	s4,0(sp)
    80003c58:	6145                	addi	sp,sp,48
    80003c5a:	8082                	ret
    panic("iget: no inodes");
    80003c5c:	00005517          	auipc	a0,0x5
    80003c60:	adc50513          	addi	a0,a0,-1316 # 80008738 <syscalls+0x160>
    80003c64:	ffffd097          	auipc	ra,0xffffd
    80003c68:	8dc080e7          	jalr	-1828(ra) # 80000540 <panic>

0000000080003c6c <fsinit>:
{
    80003c6c:	7179                	addi	sp,sp,-48
    80003c6e:	f406                	sd	ra,40(sp)
    80003c70:	f022                	sd	s0,32(sp)
    80003c72:	ec26                	sd	s1,24(sp)
    80003c74:	e84a                	sd	s2,16(sp)
    80003c76:	e44e                	sd	s3,8(sp)
    80003c78:	1800                	addi	s0,sp,48
    80003c7a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003c7c:	4585                	li	a1,1
    80003c7e:	00000097          	auipc	ra,0x0
    80003c82:	a54080e7          	jalr	-1452(ra) # 800036d2 <bread>
    80003c86:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003c88:	0023e997          	auipc	s3,0x23e
    80003c8c:	8c098993          	addi	s3,s3,-1856 # 80241548 <sb>
    80003c90:	02000613          	li	a2,32
    80003c94:	05850593          	addi	a1,a0,88
    80003c98:	854e                	mv	a0,s3
    80003c9a:	ffffd097          	auipc	ra,0xffffd
    80003c9e:	208080e7          	jalr	520(ra) # 80000ea2 <memmove>
  brelse(bp);
    80003ca2:	8526                	mv	a0,s1
    80003ca4:	00000097          	auipc	ra,0x0
    80003ca8:	b5e080e7          	jalr	-1186(ra) # 80003802 <brelse>
  if (sb.magic != FSMAGIC)
    80003cac:	0009a703          	lw	a4,0(s3)
    80003cb0:	102037b7          	lui	a5,0x10203
    80003cb4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003cb8:	02f71263          	bne	a4,a5,80003cdc <fsinit+0x70>
  initlog(dev, &sb);
    80003cbc:	0023e597          	auipc	a1,0x23e
    80003cc0:	88c58593          	addi	a1,a1,-1908 # 80241548 <sb>
    80003cc4:	854a                	mv	a0,s2
    80003cc6:	00001097          	auipc	ra,0x1
    80003cca:	b4a080e7          	jalr	-1206(ra) # 80004810 <initlog>
}
    80003cce:	70a2                	ld	ra,40(sp)
    80003cd0:	7402                	ld	s0,32(sp)
    80003cd2:	64e2                	ld	s1,24(sp)
    80003cd4:	6942                	ld	s2,16(sp)
    80003cd6:	69a2                	ld	s3,8(sp)
    80003cd8:	6145                	addi	sp,sp,48
    80003cda:	8082                	ret
    panic("invalid file system");
    80003cdc:	00005517          	auipc	a0,0x5
    80003ce0:	a6c50513          	addi	a0,a0,-1428 # 80008748 <syscalls+0x170>
    80003ce4:	ffffd097          	auipc	ra,0xffffd
    80003ce8:	85c080e7          	jalr	-1956(ra) # 80000540 <panic>

0000000080003cec <iinit>:
{
    80003cec:	7179                	addi	sp,sp,-48
    80003cee:	f406                	sd	ra,40(sp)
    80003cf0:	f022                	sd	s0,32(sp)
    80003cf2:	ec26                	sd	s1,24(sp)
    80003cf4:	e84a                	sd	s2,16(sp)
    80003cf6:	e44e                	sd	s3,8(sp)
    80003cf8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003cfa:	00005597          	auipc	a1,0x5
    80003cfe:	a6658593          	addi	a1,a1,-1434 # 80008760 <syscalls+0x188>
    80003d02:	0023e517          	auipc	a0,0x23e
    80003d06:	86650513          	addi	a0,a0,-1946 # 80241568 <itable>
    80003d0a:	ffffd097          	auipc	ra,0xffffd
    80003d0e:	fb0080e7          	jalr	-80(ra) # 80000cba <initlock>
  for (i = 0; i < NINODE; i++)
    80003d12:	0023e497          	auipc	s1,0x23e
    80003d16:	87e48493          	addi	s1,s1,-1922 # 80241590 <itable+0x28>
    80003d1a:	0023f997          	auipc	s3,0x23f
    80003d1e:	30698993          	addi	s3,s3,774 # 80243020 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d22:	00005917          	auipc	s2,0x5
    80003d26:	a4690913          	addi	s2,s2,-1466 # 80008768 <syscalls+0x190>
    80003d2a:	85ca                	mv	a1,s2
    80003d2c:	8526                	mv	a0,s1
    80003d2e:	00001097          	auipc	ra,0x1
    80003d32:	e42080e7          	jalr	-446(ra) # 80004b70 <initsleeplock>
  for (i = 0; i < NINODE; i++)
    80003d36:	08848493          	addi	s1,s1,136
    80003d3a:	ff3498e3          	bne	s1,s3,80003d2a <iinit+0x3e>
}
    80003d3e:	70a2                	ld	ra,40(sp)
    80003d40:	7402                	ld	s0,32(sp)
    80003d42:	64e2                	ld	s1,24(sp)
    80003d44:	6942                	ld	s2,16(sp)
    80003d46:	69a2                	ld	s3,8(sp)
    80003d48:	6145                	addi	sp,sp,48
    80003d4a:	8082                	ret

0000000080003d4c <ialloc>:
{
    80003d4c:	715d                	addi	sp,sp,-80
    80003d4e:	e486                	sd	ra,72(sp)
    80003d50:	e0a2                	sd	s0,64(sp)
    80003d52:	fc26                	sd	s1,56(sp)
    80003d54:	f84a                	sd	s2,48(sp)
    80003d56:	f44e                	sd	s3,40(sp)
    80003d58:	f052                	sd	s4,32(sp)
    80003d5a:	ec56                	sd	s5,24(sp)
    80003d5c:	e85a                	sd	s6,16(sp)
    80003d5e:	e45e                	sd	s7,8(sp)
    80003d60:	0880                	addi	s0,sp,80
  for (inum = 1; inum < sb.ninodes; inum++)
    80003d62:	0023d717          	auipc	a4,0x23d
    80003d66:	7f272703          	lw	a4,2034(a4) # 80241554 <sb+0xc>
    80003d6a:	4785                	li	a5,1
    80003d6c:	04e7fa63          	bgeu	a5,a4,80003dc0 <ialloc+0x74>
    80003d70:	8aaa                	mv	s5,a0
    80003d72:	8bae                	mv	s7,a1
    80003d74:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d76:	0023da17          	auipc	s4,0x23d
    80003d7a:	7d2a0a13          	addi	s4,s4,2002 # 80241548 <sb>
    80003d7e:	00048b1b          	sext.w	s6,s1
    80003d82:	0044d593          	srli	a1,s1,0x4
    80003d86:	018a2783          	lw	a5,24(s4)
    80003d8a:	9dbd                	addw	a1,a1,a5
    80003d8c:	8556                	mv	a0,s5
    80003d8e:	00000097          	auipc	ra,0x0
    80003d92:	944080e7          	jalr	-1724(ra) # 800036d2 <bread>
    80003d96:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003d98:	05850993          	addi	s3,a0,88
    80003d9c:	00f4f793          	andi	a5,s1,15
    80003da0:	079a                	slli	a5,a5,0x6
    80003da2:	99be                	add	s3,s3,a5
    if (dip->type == 0)
    80003da4:	00099783          	lh	a5,0(s3)
    80003da8:	c3a1                	beqz	a5,80003de8 <ialloc+0x9c>
    brelse(bp);
    80003daa:	00000097          	auipc	ra,0x0
    80003dae:	a58080e7          	jalr	-1448(ra) # 80003802 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++)
    80003db2:	0485                	addi	s1,s1,1
    80003db4:	00ca2703          	lw	a4,12(s4)
    80003db8:	0004879b          	sext.w	a5,s1
    80003dbc:	fce7e1e3          	bltu	a5,a4,80003d7e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003dc0:	00005517          	auipc	a0,0x5
    80003dc4:	9b050513          	addi	a0,a0,-1616 # 80008770 <syscalls+0x198>
    80003dc8:	ffffc097          	auipc	ra,0xffffc
    80003dcc:	7c2080e7          	jalr	1986(ra) # 8000058a <printf>
  return 0;
    80003dd0:	4501                	li	a0,0
}
    80003dd2:	60a6                	ld	ra,72(sp)
    80003dd4:	6406                	ld	s0,64(sp)
    80003dd6:	74e2                	ld	s1,56(sp)
    80003dd8:	7942                	ld	s2,48(sp)
    80003dda:	79a2                	ld	s3,40(sp)
    80003ddc:	7a02                	ld	s4,32(sp)
    80003dde:	6ae2                	ld	s5,24(sp)
    80003de0:	6b42                	ld	s6,16(sp)
    80003de2:	6ba2                	ld	s7,8(sp)
    80003de4:	6161                	addi	sp,sp,80
    80003de6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003de8:	04000613          	li	a2,64
    80003dec:	4581                	li	a1,0
    80003dee:	854e                	mv	a0,s3
    80003df0:	ffffd097          	auipc	ra,0xffffd
    80003df4:	056080e7          	jalr	86(ra) # 80000e46 <memset>
      dip->type = type;
    80003df8:	01799023          	sh	s7,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003dfc:	854a                	mv	a0,s2
    80003dfe:	00001097          	auipc	ra,0x1
    80003e02:	c8e080e7          	jalr	-882(ra) # 80004a8c <log_write>
      brelse(bp);
    80003e06:	854a                	mv	a0,s2
    80003e08:	00000097          	auipc	ra,0x0
    80003e0c:	9fa080e7          	jalr	-1542(ra) # 80003802 <brelse>
      return iget(dev, inum);
    80003e10:	85da                	mv	a1,s6
    80003e12:	8556                	mv	a0,s5
    80003e14:	00000097          	auipc	ra,0x0
    80003e18:	d9c080e7          	jalr	-612(ra) # 80003bb0 <iget>
    80003e1c:	bf5d                	j	80003dd2 <ialloc+0x86>

0000000080003e1e <iupdate>:
{
    80003e1e:	1101                	addi	sp,sp,-32
    80003e20:	ec06                	sd	ra,24(sp)
    80003e22:	e822                	sd	s0,16(sp)
    80003e24:	e426                	sd	s1,8(sp)
    80003e26:	e04a                	sd	s2,0(sp)
    80003e28:	1000                	addi	s0,sp,32
    80003e2a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e2c:	415c                	lw	a5,4(a0)
    80003e2e:	0047d79b          	srliw	a5,a5,0x4
    80003e32:	0023d597          	auipc	a1,0x23d
    80003e36:	72e5a583          	lw	a1,1838(a1) # 80241560 <sb+0x18>
    80003e3a:	9dbd                	addw	a1,a1,a5
    80003e3c:	4108                	lw	a0,0(a0)
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	894080e7          	jalr	-1900(ra) # 800036d2 <bread>
    80003e46:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003e48:	05850793          	addi	a5,a0,88
    80003e4c:	40d8                	lw	a4,4(s1)
    80003e4e:	8b3d                	andi	a4,a4,15
    80003e50:	071a                	slli	a4,a4,0x6
    80003e52:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003e54:	04449703          	lh	a4,68(s1)
    80003e58:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003e5c:	04649703          	lh	a4,70(s1)
    80003e60:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003e64:	04849703          	lh	a4,72(s1)
    80003e68:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003e6c:	04a49703          	lh	a4,74(s1)
    80003e70:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003e74:	44f8                	lw	a4,76(s1)
    80003e76:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e78:	03400613          	li	a2,52
    80003e7c:	05048593          	addi	a1,s1,80
    80003e80:	00c78513          	addi	a0,a5,12
    80003e84:	ffffd097          	auipc	ra,0xffffd
    80003e88:	01e080e7          	jalr	30(ra) # 80000ea2 <memmove>
  log_write(bp);
    80003e8c:	854a                	mv	a0,s2
    80003e8e:	00001097          	auipc	ra,0x1
    80003e92:	bfe080e7          	jalr	-1026(ra) # 80004a8c <log_write>
  brelse(bp);
    80003e96:	854a                	mv	a0,s2
    80003e98:	00000097          	auipc	ra,0x0
    80003e9c:	96a080e7          	jalr	-1686(ra) # 80003802 <brelse>
}
    80003ea0:	60e2                	ld	ra,24(sp)
    80003ea2:	6442                	ld	s0,16(sp)
    80003ea4:	64a2                	ld	s1,8(sp)
    80003ea6:	6902                	ld	s2,0(sp)
    80003ea8:	6105                	addi	sp,sp,32
    80003eaa:	8082                	ret

0000000080003eac <idup>:
{
    80003eac:	1101                	addi	sp,sp,-32
    80003eae:	ec06                	sd	ra,24(sp)
    80003eb0:	e822                	sd	s0,16(sp)
    80003eb2:	e426                	sd	s1,8(sp)
    80003eb4:	1000                	addi	s0,sp,32
    80003eb6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003eb8:	0023d517          	auipc	a0,0x23d
    80003ebc:	6b050513          	addi	a0,a0,1712 # 80241568 <itable>
    80003ec0:	ffffd097          	auipc	ra,0xffffd
    80003ec4:	e8a080e7          	jalr	-374(ra) # 80000d4a <acquire>
  ip->ref++;
    80003ec8:	449c                	lw	a5,8(s1)
    80003eca:	2785                	addiw	a5,a5,1
    80003ecc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ece:	0023d517          	auipc	a0,0x23d
    80003ed2:	69a50513          	addi	a0,a0,1690 # 80241568 <itable>
    80003ed6:	ffffd097          	auipc	ra,0xffffd
    80003eda:	f28080e7          	jalr	-216(ra) # 80000dfe <release>
}
    80003ede:	8526                	mv	a0,s1
    80003ee0:	60e2                	ld	ra,24(sp)
    80003ee2:	6442                	ld	s0,16(sp)
    80003ee4:	64a2                	ld	s1,8(sp)
    80003ee6:	6105                	addi	sp,sp,32
    80003ee8:	8082                	ret

0000000080003eea <ilock>:
{
    80003eea:	1101                	addi	sp,sp,-32
    80003eec:	ec06                	sd	ra,24(sp)
    80003eee:	e822                	sd	s0,16(sp)
    80003ef0:	e426                	sd	s1,8(sp)
    80003ef2:	e04a                	sd	s2,0(sp)
    80003ef4:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003ef6:	c115                	beqz	a0,80003f1a <ilock+0x30>
    80003ef8:	84aa                	mv	s1,a0
    80003efa:	451c                	lw	a5,8(a0)
    80003efc:	00f05f63          	blez	a5,80003f1a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003f00:	0541                	addi	a0,a0,16
    80003f02:	00001097          	auipc	ra,0x1
    80003f06:	ca8080e7          	jalr	-856(ra) # 80004baa <acquiresleep>
  if (ip->valid == 0)
    80003f0a:	40bc                	lw	a5,64(s1)
    80003f0c:	cf99                	beqz	a5,80003f2a <ilock+0x40>
}
    80003f0e:	60e2                	ld	ra,24(sp)
    80003f10:	6442                	ld	s0,16(sp)
    80003f12:	64a2                	ld	s1,8(sp)
    80003f14:	6902                	ld	s2,0(sp)
    80003f16:	6105                	addi	sp,sp,32
    80003f18:	8082                	ret
    panic("ilock");
    80003f1a:	00005517          	auipc	a0,0x5
    80003f1e:	86e50513          	addi	a0,a0,-1938 # 80008788 <syscalls+0x1b0>
    80003f22:	ffffc097          	auipc	ra,0xffffc
    80003f26:	61e080e7          	jalr	1566(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f2a:	40dc                	lw	a5,4(s1)
    80003f2c:	0047d79b          	srliw	a5,a5,0x4
    80003f30:	0023d597          	auipc	a1,0x23d
    80003f34:	6305a583          	lw	a1,1584(a1) # 80241560 <sb+0x18>
    80003f38:	9dbd                	addw	a1,a1,a5
    80003f3a:	4088                	lw	a0,0(s1)
    80003f3c:	fffff097          	auipc	ra,0xfffff
    80003f40:	796080e7          	jalr	1942(ra) # 800036d2 <bread>
    80003f44:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003f46:	05850593          	addi	a1,a0,88
    80003f4a:	40dc                	lw	a5,4(s1)
    80003f4c:	8bbd                	andi	a5,a5,15
    80003f4e:	079a                	slli	a5,a5,0x6
    80003f50:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f52:	00059783          	lh	a5,0(a1)
    80003f56:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f5a:	00259783          	lh	a5,2(a1)
    80003f5e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f62:	00459783          	lh	a5,4(a1)
    80003f66:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f6a:	00659783          	lh	a5,6(a1)
    80003f6e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f72:	459c                	lw	a5,8(a1)
    80003f74:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f76:	03400613          	li	a2,52
    80003f7a:	05b1                	addi	a1,a1,12
    80003f7c:	05048513          	addi	a0,s1,80
    80003f80:	ffffd097          	auipc	ra,0xffffd
    80003f84:	f22080e7          	jalr	-222(ra) # 80000ea2 <memmove>
    brelse(bp);
    80003f88:	854a                	mv	a0,s2
    80003f8a:	00000097          	auipc	ra,0x0
    80003f8e:	878080e7          	jalr	-1928(ra) # 80003802 <brelse>
    ip->valid = 1;
    80003f92:	4785                	li	a5,1
    80003f94:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003f96:	04449783          	lh	a5,68(s1)
    80003f9a:	fbb5                	bnez	a5,80003f0e <ilock+0x24>
      panic("ilock: no type");
    80003f9c:	00004517          	auipc	a0,0x4
    80003fa0:	7f450513          	addi	a0,a0,2036 # 80008790 <syscalls+0x1b8>
    80003fa4:	ffffc097          	auipc	ra,0xffffc
    80003fa8:	59c080e7          	jalr	1436(ra) # 80000540 <panic>

0000000080003fac <iunlock>:
{
    80003fac:	1101                	addi	sp,sp,-32
    80003fae:	ec06                	sd	ra,24(sp)
    80003fb0:	e822                	sd	s0,16(sp)
    80003fb2:	e426                	sd	s1,8(sp)
    80003fb4:	e04a                	sd	s2,0(sp)
    80003fb6:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003fb8:	c905                	beqz	a0,80003fe8 <iunlock+0x3c>
    80003fba:	84aa                	mv	s1,a0
    80003fbc:	01050913          	addi	s2,a0,16
    80003fc0:	854a                	mv	a0,s2
    80003fc2:	00001097          	auipc	ra,0x1
    80003fc6:	c82080e7          	jalr	-894(ra) # 80004c44 <holdingsleep>
    80003fca:	cd19                	beqz	a0,80003fe8 <iunlock+0x3c>
    80003fcc:	449c                	lw	a5,8(s1)
    80003fce:	00f05d63          	blez	a5,80003fe8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003fd2:	854a                	mv	a0,s2
    80003fd4:	00001097          	auipc	ra,0x1
    80003fd8:	c2c080e7          	jalr	-980(ra) # 80004c00 <releasesleep>
}
    80003fdc:	60e2                	ld	ra,24(sp)
    80003fde:	6442                	ld	s0,16(sp)
    80003fe0:	64a2                	ld	s1,8(sp)
    80003fe2:	6902                	ld	s2,0(sp)
    80003fe4:	6105                	addi	sp,sp,32
    80003fe6:	8082                	ret
    panic("iunlock");
    80003fe8:	00004517          	auipc	a0,0x4
    80003fec:	7b850513          	addi	a0,a0,1976 # 800087a0 <syscalls+0x1c8>
    80003ff0:	ffffc097          	auipc	ra,0xffffc
    80003ff4:	550080e7          	jalr	1360(ra) # 80000540 <panic>

0000000080003ff8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void itrunc(struct inode *ip)
{
    80003ff8:	7179                	addi	sp,sp,-48
    80003ffa:	f406                	sd	ra,40(sp)
    80003ffc:	f022                	sd	s0,32(sp)
    80003ffe:	ec26                	sd	s1,24(sp)
    80004000:	e84a                	sd	s2,16(sp)
    80004002:	e44e                	sd	s3,8(sp)
    80004004:	e052                	sd	s4,0(sp)
    80004006:	1800                	addi	s0,sp,48
    80004008:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++)
    8000400a:	05050493          	addi	s1,a0,80
    8000400e:	08050913          	addi	s2,a0,128
    80004012:	a021                	j	8000401a <itrunc+0x22>
    80004014:	0491                	addi	s1,s1,4
    80004016:	01248d63          	beq	s1,s2,80004030 <itrunc+0x38>
  {
    if (ip->addrs[i])
    8000401a:	408c                	lw	a1,0(s1)
    8000401c:	dde5                	beqz	a1,80004014 <itrunc+0x1c>
    {
      bfree(ip->dev, ip->addrs[i]);
    8000401e:	0009a503          	lw	a0,0(s3)
    80004022:	00000097          	auipc	ra,0x0
    80004026:	8f6080e7          	jalr	-1802(ra) # 80003918 <bfree>
      ip->addrs[i] = 0;
    8000402a:	0004a023          	sw	zero,0(s1)
    8000402e:	b7dd                	j	80004014 <itrunc+0x1c>
    }
  }

  if (ip->addrs[NDIRECT])
    80004030:	0809a583          	lw	a1,128(s3)
    80004034:	e185                	bnez	a1,80004054 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004036:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000403a:	854e                	mv	a0,s3
    8000403c:	00000097          	auipc	ra,0x0
    80004040:	de2080e7          	jalr	-542(ra) # 80003e1e <iupdate>
}
    80004044:	70a2                	ld	ra,40(sp)
    80004046:	7402                	ld	s0,32(sp)
    80004048:	64e2                	ld	s1,24(sp)
    8000404a:	6942                	ld	s2,16(sp)
    8000404c:	69a2                	ld	s3,8(sp)
    8000404e:	6a02                	ld	s4,0(sp)
    80004050:	6145                	addi	sp,sp,48
    80004052:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004054:	0009a503          	lw	a0,0(s3)
    80004058:	fffff097          	auipc	ra,0xfffff
    8000405c:	67a080e7          	jalr	1658(ra) # 800036d2 <bread>
    80004060:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++)
    80004062:	05850493          	addi	s1,a0,88
    80004066:	45850913          	addi	s2,a0,1112
    8000406a:	a021                	j	80004072 <itrunc+0x7a>
    8000406c:	0491                	addi	s1,s1,4
    8000406e:	01248b63          	beq	s1,s2,80004084 <itrunc+0x8c>
      if (a[j])
    80004072:	408c                	lw	a1,0(s1)
    80004074:	dde5                	beqz	a1,8000406c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004076:	0009a503          	lw	a0,0(s3)
    8000407a:	00000097          	auipc	ra,0x0
    8000407e:	89e080e7          	jalr	-1890(ra) # 80003918 <bfree>
    80004082:	b7ed                	j	8000406c <itrunc+0x74>
    brelse(bp);
    80004084:	8552                	mv	a0,s4
    80004086:	fffff097          	auipc	ra,0xfffff
    8000408a:	77c080e7          	jalr	1916(ra) # 80003802 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000408e:	0809a583          	lw	a1,128(s3)
    80004092:	0009a503          	lw	a0,0(s3)
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	882080e7          	jalr	-1918(ra) # 80003918 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000409e:	0809a023          	sw	zero,128(s3)
    800040a2:	bf51                	j	80004036 <itrunc+0x3e>

00000000800040a4 <iput>:
{
    800040a4:	1101                	addi	sp,sp,-32
    800040a6:	ec06                	sd	ra,24(sp)
    800040a8:	e822                	sd	s0,16(sp)
    800040aa:	e426                	sd	s1,8(sp)
    800040ac:	e04a                	sd	s2,0(sp)
    800040ae:	1000                	addi	s0,sp,32
    800040b0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800040b2:	0023d517          	auipc	a0,0x23d
    800040b6:	4b650513          	addi	a0,a0,1206 # 80241568 <itable>
    800040ba:	ffffd097          	auipc	ra,0xffffd
    800040be:	c90080e7          	jalr	-880(ra) # 80000d4a <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    800040c2:	4498                	lw	a4,8(s1)
    800040c4:	4785                	li	a5,1
    800040c6:	02f70363          	beq	a4,a5,800040ec <iput+0x48>
  ip->ref--;
    800040ca:	449c                	lw	a5,8(s1)
    800040cc:	37fd                	addiw	a5,a5,-1
    800040ce:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800040d0:	0023d517          	auipc	a0,0x23d
    800040d4:	49850513          	addi	a0,a0,1176 # 80241568 <itable>
    800040d8:	ffffd097          	auipc	ra,0xffffd
    800040dc:	d26080e7          	jalr	-730(ra) # 80000dfe <release>
}
    800040e0:	60e2                	ld	ra,24(sp)
    800040e2:	6442                	ld	s0,16(sp)
    800040e4:	64a2                	ld	s1,8(sp)
    800040e6:	6902                	ld	s2,0(sp)
    800040e8:	6105                	addi	sp,sp,32
    800040ea:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    800040ec:	40bc                	lw	a5,64(s1)
    800040ee:	dff1                	beqz	a5,800040ca <iput+0x26>
    800040f0:	04a49783          	lh	a5,74(s1)
    800040f4:	fbf9                	bnez	a5,800040ca <iput+0x26>
    acquiresleep(&ip->lock);
    800040f6:	01048913          	addi	s2,s1,16
    800040fa:	854a                	mv	a0,s2
    800040fc:	00001097          	auipc	ra,0x1
    80004100:	aae080e7          	jalr	-1362(ra) # 80004baa <acquiresleep>
    release(&itable.lock);
    80004104:	0023d517          	auipc	a0,0x23d
    80004108:	46450513          	addi	a0,a0,1124 # 80241568 <itable>
    8000410c:	ffffd097          	auipc	ra,0xffffd
    80004110:	cf2080e7          	jalr	-782(ra) # 80000dfe <release>
    itrunc(ip);
    80004114:	8526                	mv	a0,s1
    80004116:	00000097          	auipc	ra,0x0
    8000411a:	ee2080e7          	jalr	-286(ra) # 80003ff8 <itrunc>
    ip->type = 0;
    8000411e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004122:	8526                	mv	a0,s1
    80004124:	00000097          	auipc	ra,0x0
    80004128:	cfa080e7          	jalr	-774(ra) # 80003e1e <iupdate>
    ip->valid = 0;
    8000412c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004130:	854a                	mv	a0,s2
    80004132:	00001097          	auipc	ra,0x1
    80004136:	ace080e7          	jalr	-1330(ra) # 80004c00 <releasesleep>
    acquire(&itable.lock);
    8000413a:	0023d517          	auipc	a0,0x23d
    8000413e:	42e50513          	addi	a0,a0,1070 # 80241568 <itable>
    80004142:	ffffd097          	auipc	ra,0xffffd
    80004146:	c08080e7          	jalr	-1016(ra) # 80000d4a <acquire>
    8000414a:	b741                	j	800040ca <iput+0x26>

000000008000414c <iunlockput>:
{
    8000414c:	1101                	addi	sp,sp,-32
    8000414e:	ec06                	sd	ra,24(sp)
    80004150:	e822                	sd	s0,16(sp)
    80004152:	e426                	sd	s1,8(sp)
    80004154:	1000                	addi	s0,sp,32
    80004156:	84aa                	mv	s1,a0
  iunlock(ip);
    80004158:	00000097          	auipc	ra,0x0
    8000415c:	e54080e7          	jalr	-428(ra) # 80003fac <iunlock>
  iput(ip);
    80004160:	8526                	mv	a0,s1
    80004162:	00000097          	auipc	ra,0x0
    80004166:	f42080e7          	jalr	-190(ra) # 800040a4 <iput>
}
    8000416a:	60e2                	ld	ra,24(sp)
    8000416c:	6442                	ld	s0,16(sp)
    8000416e:	64a2                	ld	s1,8(sp)
    80004170:	6105                	addi	sp,sp,32
    80004172:	8082                	ret

0000000080004174 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void stati(struct inode *ip, struct stat *st)
{
    80004174:	1141                	addi	sp,sp,-16
    80004176:	e422                	sd	s0,8(sp)
    80004178:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000417a:	411c                	lw	a5,0(a0)
    8000417c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000417e:	415c                	lw	a5,4(a0)
    80004180:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004182:	04451783          	lh	a5,68(a0)
    80004186:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000418a:	04a51783          	lh	a5,74(a0)
    8000418e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004192:	04c56783          	lwu	a5,76(a0)
    80004196:	e99c                	sd	a5,16(a1)
}
    80004198:	6422                	ld	s0,8(sp)
    8000419a:	0141                	addi	sp,sp,16
    8000419c:	8082                	ret

000000008000419e <readi>:
int readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000419e:	457c                	lw	a5,76(a0)
    800041a0:	0ed7e963          	bltu	a5,a3,80004292 <readi+0xf4>
{
    800041a4:	7159                	addi	sp,sp,-112
    800041a6:	f486                	sd	ra,104(sp)
    800041a8:	f0a2                	sd	s0,96(sp)
    800041aa:	eca6                	sd	s1,88(sp)
    800041ac:	e8ca                	sd	s2,80(sp)
    800041ae:	e4ce                	sd	s3,72(sp)
    800041b0:	e0d2                	sd	s4,64(sp)
    800041b2:	fc56                	sd	s5,56(sp)
    800041b4:	f85a                	sd	s6,48(sp)
    800041b6:	f45e                	sd	s7,40(sp)
    800041b8:	f062                	sd	s8,32(sp)
    800041ba:	ec66                	sd	s9,24(sp)
    800041bc:	e86a                	sd	s10,16(sp)
    800041be:	e46e                	sd	s11,8(sp)
    800041c0:	1880                	addi	s0,sp,112
    800041c2:	8b2a                	mv	s6,a0
    800041c4:	8bae                	mv	s7,a1
    800041c6:	8a32                	mv	s4,a2
    800041c8:	84b6                	mv	s1,a3
    800041ca:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800041cc:	9f35                	addw	a4,a4,a3
    return 0;
    800041ce:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800041d0:	0ad76063          	bltu	a4,a3,80004270 <readi+0xd2>
  if (off + n > ip->size)
    800041d4:	00e7f463          	bgeu	a5,a4,800041dc <readi+0x3e>
    n = ip->size - off;
    800041d8:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    800041dc:	0a0a8963          	beqz	s5,8000428e <readi+0xf0>
    800041e0:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800041e2:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1)
    800041e6:	5c7d                	li	s8,-1
    800041e8:	a82d                	j	80004222 <readi+0x84>
    800041ea:	020d1d93          	slli	s11,s10,0x20
    800041ee:	020ddd93          	srli	s11,s11,0x20
    800041f2:	05890613          	addi	a2,s2,88
    800041f6:	86ee                	mv	a3,s11
    800041f8:	963a                	add	a2,a2,a4
    800041fa:	85d2                	mv	a1,s4
    800041fc:	855e                	mv	a0,s7
    800041fe:	ffffe097          	auipc	ra,0xffffe
    80004202:	6ba080e7          	jalr	1722(ra) # 800028b8 <either_copyout>
    80004206:	05850d63          	beq	a0,s8,80004260 <readi+0xc2>
    {
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000420a:	854a                	mv	a0,s2
    8000420c:	fffff097          	auipc	ra,0xfffff
    80004210:	5f6080e7          	jalr	1526(ra) # 80003802 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80004214:	013d09bb          	addw	s3,s10,s3
    80004218:	009d04bb          	addw	s1,s10,s1
    8000421c:	9a6e                	add	s4,s4,s11
    8000421e:	0559f763          	bgeu	s3,s5,8000426c <readi+0xce>
    uint addr = bmap(ip, off / BSIZE);
    80004222:	00a4d59b          	srliw	a1,s1,0xa
    80004226:	855a                	mv	a0,s6
    80004228:	00000097          	auipc	ra,0x0
    8000422c:	89e080e7          	jalr	-1890(ra) # 80003ac6 <bmap>
    80004230:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80004234:	cd85                	beqz	a1,8000426c <readi+0xce>
    bp = bread(ip->dev, addr);
    80004236:	000b2503          	lw	a0,0(s6)
    8000423a:	fffff097          	auipc	ra,0xfffff
    8000423e:	498080e7          	jalr	1176(ra) # 800036d2 <bread>
    80004242:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80004244:	3ff4f713          	andi	a4,s1,1023
    80004248:	40ec87bb          	subw	a5,s9,a4
    8000424c:	413a86bb          	subw	a3,s5,s3
    80004250:	8d3e                	mv	s10,a5
    80004252:	2781                	sext.w	a5,a5
    80004254:	0006861b          	sext.w	a2,a3
    80004258:	f8f679e3          	bgeu	a2,a5,800041ea <readi+0x4c>
    8000425c:	8d36                	mv	s10,a3
    8000425e:	b771                	j	800041ea <readi+0x4c>
      brelse(bp);
    80004260:	854a                	mv	a0,s2
    80004262:	fffff097          	auipc	ra,0xfffff
    80004266:	5a0080e7          	jalr	1440(ra) # 80003802 <brelse>
      tot = -1;
    8000426a:	59fd                	li	s3,-1
  }
  return tot;
    8000426c:	0009851b          	sext.w	a0,s3
}
    80004270:	70a6                	ld	ra,104(sp)
    80004272:	7406                	ld	s0,96(sp)
    80004274:	64e6                	ld	s1,88(sp)
    80004276:	6946                	ld	s2,80(sp)
    80004278:	69a6                	ld	s3,72(sp)
    8000427a:	6a06                	ld	s4,64(sp)
    8000427c:	7ae2                	ld	s5,56(sp)
    8000427e:	7b42                	ld	s6,48(sp)
    80004280:	7ba2                	ld	s7,40(sp)
    80004282:	7c02                	ld	s8,32(sp)
    80004284:	6ce2                	ld	s9,24(sp)
    80004286:	6d42                	ld	s10,16(sp)
    80004288:	6da2                	ld	s11,8(sp)
    8000428a:	6165                	addi	sp,sp,112
    8000428c:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    8000428e:	89d6                	mv	s3,s5
    80004290:	bff1                	j	8000426c <readi+0xce>
    return 0;
    80004292:	4501                	li	a0,0
}
    80004294:	8082                	ret

0000000080004296 <writei>:
int writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80004296:	457c                	lw	a5,76(a0)
    80004298:	10d7e863          	bltu	a5,a3,800043a8 <writei+0x112>
{
    8000429c:	7159                	addi	sp,sp,-112
    8000429e:	f486                	sd	ra,104(sp)
    800042a0:	f0a2                	sd	s0,96(sp)
    800042a2:	eca6                	sd	s1,88(sp)
    800042a4:	e8ca                	sd	s2,80(sp)
    800042a6:	e4ce                	sd	s3,72(sp)
    800042a8:	e0d2                	sd	s4,64(sp)
    800042aa:	fc56                	sd	s5,56(sp)
    800042ac:	f85a                	sd	s6,48(sp)
    800042ae:	f45e                	sd	s7,40(sp)
    800042b0:	f062                	sd	s8,32(sp)
    800042b2:	ec66                	sd	s9,24(sp)
    800042b4:	e86a                	sd	s10,16(sp)
    800042b6:	e46e                	sd	s11,8(sp)
    800042b8:	1880                	addi	s0,sp,112
    800042ba:	8aaa                	mv	s5,a0
    800042bc:	8bae                	mv	s7,a1
    800042be:	8a32                	mv	s4,a2
    800042c0:	8936                	mv	s2,a3
    800042c2:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800042c4:	00e687bb          	addw	a5,a3,a4
    800042c8:	0ed7e263          	bltu	a5,a3,800043ac <writei+0x116>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800042cc:	00043737          	lui	a4,0x43
    800042d0:	0ef76063          	bltu	a4,a5,800043b0 <writei+0x11a>
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m)
    800042d4:	0c0b0863          	beqz	s6,800043a4 <writei+0x10e>
    800042d8:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800042da:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1)
    800042de:	5c7d                	li	s8,-1
    800042e0:	a091                	j	80004324 <writei+0x8e>
    800042e2:	020d1d93          	slli	s11,s10,0x20
    800042e6:	020ddd93          	srli	s11,s11,0x20
    800042ea:	05848513          	addi	a0,s1,88
    800042ee:	86ee                	mv	a3,s11
    800042f0:	8652                	mv	a2,s4
    800042f2:	85de                	mv	a1,s7
    800042f4:	953a                	add	a0,a0,a4
    800042f6:	ffffe097          	auipc	ra,0xffffe
    800042fa:	618080e7          	jalr	1560(ra) # 8000290e <either_copyin>
    800042fe:	07850263          	beq	a0,s8,80004362 <writei+0xcc>
    {
      brelse(bp);
      break;
    }
    log_write(bp);
    80004302:	8526                	mv	a0,s1
    80004304:	00000097          	auipc	ra,0x0
    80004308:	788080e7          	jalr	1928(ra) # 80004a8c <log_write>
    brelse(bp);
    8000430c:	8526                	mv	a0,s1
    8000430e:	fffff097          	auipc	ra,0xfffff
    80004312:	4f4080e7          	jalr	1268(ra) # 80003802 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80004316:	013d09bb          	addw	s3,s10,s3
    8000431a:	012d093b          	addw	s2,s10,s2
    8000431e:	9a6e                	add	s4,s4,s11
    80004320:	0569f663          	bgeu	s3,s6,8000436c <writei+0xd6>
    uint addr = bmap(ip, off / BSIZE);
    80004324:	00a9559b          	srliw	a1,s2,0xa
    80004328:	8556                	mv	a0,s5
    8000432a:	fffff097          	auipc	ra,0xfffff
    8000432e:	79c080e7          	jalr	1948(ra) # 80003ac6 <bmap>
    80004332:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80004336:	c99d                	beqz	a1,8000436c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004338:	000aa503          	lw	a0,0(s5)
    8000433c:	fffff097          	auipc	ra,0xfffff
    80004340:	396080e7          	jalr	918(ra) # 800036d2 <bread>
    80004344:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80004346:	3ff97713          	andi	a4,s2,1023
    8000434a:	40ec87bb          	subw	a5,s9,a4
    8000434e:	413b06bb          	subw	a3,s6,s3
    80004352:	8d3e                	mv	s10,a5
    80004354:	2781                	sext.w	a5,a5
    80004356:	0006861b          	sext.w	a2,a3
    8000435a:	f8f674e3          	bgeu	a2,a5,800042e2 <writei+0x4c>
    8000435e:	8d36                	mv	s10,a3
    80004360:	b749                	j	800042e2 <writei+0x4c>
      brelse(bp);
    80004362:	8526                	mv	a0,s1
    80004364:	fffff097          	auipc	ra,0xfffff
    80004368:	49e080e7          	jalr	1182(ra) # 80003802 <brelse>
  }

  if (off > ip->size)
    8000436c:	04caa783          	lw	a5,76(s5)
    80004370:	0127f463          	bgeu	a5,s2,80004378 <writei+0xe2>
    ip->size = off;
    80004374:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004378:	8556                	mv	a0,s5
    8000437a:	00000097          	auipc	ra,0x0
    8000437e:	aa4080e7          	jalr	-1372(ra) # 80003e1e <iupdate>

  return tot;
    80004382:	0009851b          	sext.w	a0,s3
}
    80004386:	70a6                	ld	ra,104(sp)
    80004388:	7406                	ld	s0,96(sp)
    8000438a:	64e6                	ld	s1,88(sp)
    8000438c:	6946                	ld	s2,80(sp)
    8000438e:	69a6                	ld	s3,72(sp)
    80004390:	6a06                	ld	s4,64(sp)
    80004392:	7ae2                	ld	s5,56(sp)
    80004394:	7b42                	ld	s6,48(sp)
    80004396:	7ba2                	ld	s7,40(sp)
    80004398:	7c02                	ld	s8,32(sp)
    8000439a:	6ce2                	ld	s9,24(sp)
    8000439c:	6d42                	ld	s10,16(sp)
    8000439e:	6da2                	ld	s11,8(sp)
    800043a0:	6165                	addi	sp,sp,112
    800043a2:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    800043a4:	89da                	mv	s3,s6
    800043a6:	bfc9                	j	80004378 <writei+0xe2>
    return -1;
    800043a8:	557d                	li	a0,-1
}
    800043aa:	8082                	ret
    return -1;
    800043ac:	557d                	li	a0,-1
    800043ae:	bfe1                	j	80004386 <writei+0xf0>
    return -1;
    800043b0:	557d                	li	a0,-1
    800043b2:	bfd1                	j	80004386 <writei+0xf0>

00000000800043b4 <namecmp>:

// Directories

int namecmp(const char *s, const char *t)
{
    800043b4:	1141                	addi	sp,sp,-16
    800043b6:	e406                	sd	ra,8(sp)
    800043b8:	e022                	sd	s0,0(sp)
    800043ba:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800043bc:	4639                	li	a2,14
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	b58080e7          	jalr	-1192(ra) # 80000f16 <strncmp>
}
    800043c6:	60a2                	ld	ra,8(sp)
    800043c8:	6402                	ld	s0,0(sp)
    800043ca:	0141                	addi	sp,sp,16
    800043cc:	8082                	ret

00000000800043ce <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800043ce:	7139                	addi	sp,sp,-64
    800043d0:	fc06                	sd	ra,56(sp)
    800043d2:	f822                	sd	s0,48(sp)
    800043d4:	f426                	sd	s1,40(sp)
    800043d6:	f04a                	sd	s2,32(sp)
    800043d8:	ec4e                	sd	s3,24(sp)
    800043da:	e852                	sd	s4,16(sp)
    800043dc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800043de:	04451703          	lh	a4,68(a0)
    800043e2:	4785                	li	a5,1
    800043e4:	00f71a63          	bne	a4,a5,800043f8 <dirlookup+0x2a>
    800043e8:	892a                	mv	s2,a0
    800043ea:	89ae                	mv	s3,a1
    800043ec:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de))
    800043ee:	457c                	lw	a5,76(a0)
    800043f0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800043f2:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de))
    800043f4:	e79d                	bnez	a5,80004422 <dirlookup+0x54>
    800043f6:	a8a5                	j	8000446e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800043f8:	00004517          	auipc	a0,0x4
    800043fc:	3b050513          	addi	a0,a0,944 # 800087a8 <syscalls+0x1d0>
    80004400:	ffffc097          	auipc	ra,0xffffc
    80004404:	140080e7          	jalr	320(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004408:	00004517          	auipc	a0,0x4
    8000440c:	3b850513          	addi	a0,a0,952 # 800087c0 <syscalls+0x1e8>
    80004410:	ffffc097          	auipc	ra,0xffffc
    80004414:	130080e7          	jalr	304(ra) # 80000540 <panic>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004418:	24c1                	addiw	s1,s1,16
    8000441a:	04c92783          	lw	a5,76(s2)
    8000441e:	04f4f763          	bgeu	s1,a5,8000446c <dirlookup+0x9e>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004422:	4741                	li	a4,16
    80004424:	86a6                	mv	a3,s1
    80004426:	fc040613          	addi	a2,s0,-64
    8000442a:	4581                	li	a1,0
    8000442c:	854a                	mv	a0,s2
    8000442e:	00000097          	auipc	ra,0x0
    80004432:	d70080e7          	jalr	-656(ra) # 8000419e <readi>
    80004436:	47c1                	li	a5,16
    80004438:	fcf518e3          	bne	a0,a5,80004408 <dirlookup+0x3a>
    if (de.inum == 0)
    8000443c:	fc045783          	lhu	a5,-64(s0)
    80004440:	dfe1                	beqz	a5,80004418 <dirlookup+0x4a>
    if (namecmp(name, de.name) == 0)
    80004442:	fc240593          	addi	a1,s0,-62
    80004446:	854e                	mv	a0,s3
    80004448:	00000097          	auipc	ra,0x0
    8000444c:	f6c080e7          	jalr	-148(ra) # 800043b4 <namecmp>
    80004450:	f561                	bnez	a0,80004418 <dirlookup+0x4a>
      if (poff)
    80004452:	000a0463          	beqz	s4,8000445a <dirlookup+0x8c>
        *poff = off;
    80004456:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000445a:	fc045583          	lhu	a1,-64(s0)
    8000445e:	00092503          	lw	a0,0(s2)
    80004462:	fffff097          	auipc	ra,0xfffff
    80004466:	74e080e7          	jalr	1870(ra) # 80003bb0 <iget>
    8000446a:	a011                	j	8000446e <dirlookup+0xa0>
  return 0;
    8000446c:	4501                	li	a0,0
}
    8000446e:	70e2                	ld	ra,56(sp)
    80004470:	7442                	ld	s0,48(sp)
    80004472:	74a2                	ld	s1,40(sp)
    80004474:	7902                	ld	s2,32(sp)
    80004476:	69e2                	ld	s3,24(sp)
    80004478:	6a42                	ld	s4,16(sp)
    8000447a:	6121                	addi	sp,sp,64
    8000447c:	8082                	ret

000000008000447e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    8000447e:	711d                	addi	sp,sp,-96
    80004480:	ec86                	sd	ra,88(sp)
    80004482:	e8a2                	sd	s0,80(sp)
    80004484:	e4a6                	sd	s1,72(sp)
    80004486:	e0ca                	sd	s2,64(sp)
    80004488:	fc4e                	sd	s3,56(sp)
    8000448a:	f852                	sd	s4,48(sp)
    8000448c:	f456                	sd	s5,40(sp)
    8000448e:	f05a                	sd	s6,32(sp)
    80004490:	ec5e                	sd	s7,24(sp)
    80004492:	e862                	sd	s8,16(sp)
    80004494:	e466                	sd	s9,8(sp)
    80004496:	e06a                	sd	s10,0(sp)
    80004498:	1080                	addi	s0,sp,96
    8000449a:	84aa                	mv	s1,a0
    8000449c:	8b2e                	mv	s6,a1
    8000449e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    800044a0:	00054703          	lbu	a4,0(a0)
    800044a4:	02f00793          	li	a5,47
    800044a8:	02f70363          	beq	a4,a5,800044ce <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800044ac:	ffffd097          	auipc	ra,0xffffd
    800044b0:	6ce080e7          	jalr	1742(ra) # 80001b7a <myproc>
    800044b4:	15053503          	ld	a0,336(a0)
    800044b8:	00000097          	auipc	ra,0x0
    800044bc:	9f4080e7          	jalr	-1548(ra) # 80003eac <idup>
    800044c0:	8a2a                	mv	s4,a0
  while (*path == '/')
    800044c2:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    800044c6:	4cb5                	li	s9,13
  len = path - s;
    800044c8:	4b81                	li	s7,0

  while ((path = skipelem(path, name)) != 0)
  {
    ilock(ip);
    if (ip->type != T_DIR)
    800044ca:	4c05                	li	s8,1
    800044cc:	a87d                	j	8000458a <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800044ce:	4585                	li	a1,1
    800044d0:	4505                	li	a0,1
    800044d2:	fffff097          	auipc	ra,0xfffff
    800044d6:	6de080e7          	jalr	1758(ra) # 80003bb0 <iget>
    800044da:	8a2a                	mv	s4,a0
    800044dc:	b7dd                	j	800044c2 <namex+0x44>
    {
      iunlockput(ip);
    800044de:	8552                	mv	a0,s4
    800044e0:	00000097          	auipc	ra,0x0
    800044e4:	c6c080e7          	jalr	-916(ra) # 8000414c <iunlockput>
      return 0;
    800044e8:	4a01                	li	s4,0
  {
    iput(ip);
    return 0;
  }
  return ip;
}
    800044ea:	8552                	mv	a0,s4
    800044ec:	60e6                	ld	ra,88(sp)
    800044ee:	6446                	ld	s0,80(sp)
    800044f0:	64a6                	ld	s1,72(sp)
    800044f2:	6906                	ld	s2,64(sp)
    800044f4:	79e2                	ld	s3,56(sp)
    800044f6:	7a42                	ld	s4,48(sp)
    800044f8:	7aa2                	ld	s5,40(sp)
    800044fa:	7b02                	ld	s6,32(sp)
    800044fc:	6be2                	ld	s7,24(sp)
    800044fe:	6c42                	ld	s8,16(sp)
    80004500:	6ca2                	ld	s9,8(sp)
    80004502:	6d02                	ld	s10,0(sp)
    80004504:	6125                	addi	sp,sp,96
    80004506:	8082                	ret
      iunlock(ip);
    80004508:	8552                	mv	a0,s4
    8000450a:	00000097          	auipc	ra,0x0
    8000450e:	aa2080e7          	jalr	-1374(ra) # 80003fac <iunlock>
      return ip;
    80004512:	bfe1                	j	800044ea <namex+0x6c>
      iunlockput(ip);
    80004514:	8552                	mv	a0,s4
    80004516:	00000097          	auipc	ra,0x0
    8000451a:	c36080e7          	jalr	-970(ra) # 8000414c <iunlockput>
      return 0;
    8000451e:	8a4e                	mv	s4,s3
    80004520:	b7e9                	j	800044ea <namex+0x6c>
  len = path - s;
    80004522:	40998633          	sub	a2,s3,s1
    80004526:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    8000452a:	09acd863          	bge	s9,s10,800045ba <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000452e:	4639                	li	a2,14
    80004530:	85a6                	mv	a1,s1
    80004532:	8556                	mv	a0,s5
    80004534:	ffffd097          	auipc	ra,0xffffd
    80004538:	96e080e7          	jalr	-1682(ra) # 80000ea2 <memmove>
    8000453c:	84ce                	mv	s1,s3
  while (*path == '/')
    8000453e:	0004c783          	lbu	a5,0(s1)
    80004542:	01279763          	bne	a5,s2,80004550 <namex+0xd2>
    path++;
    80004546:	0485                	addi	s1,s1,1
  while (*path == '/')
    80004548:	0004c783          	lbu	a5,0(s1)
    8000454c:	ff278de3          	beq	a5,s2,80004546 <namex+0xc8>
    ilock(ip);
    80004550:	8552                	mv	a0,s4
    80004552:	00000097          	auipc	ra,0x0
    80004556:	998080e7          	jalr	-1640(ra) # 80003eea <ilock>
    if (ip->type != T_DIR)
    8000455a:	044a1783          	lh	a5,68(s4)
    8000455e:	f98790e3          	bne	a5,s8,800044de <namex+0x60>
    if (nameiparent && *path == '\0')
    80004562:	000b0563          	beqz	s6,8000456c <namex+0xee>
    80004566:	0004c783          	lbu	a5,0(s1)
    8000456a:	dfd9                	beqz	a5,80004508 <namex+0x8a>
    if ((next = dirlookup(ip, name, 0)) == 0)
    8000456c:	865e                	mv	a2,s7
    8000456e:	85d6                	mv	a1,s5
    80004570:	8552                	mv	a0,s4
    80004572:	00000097          	auipc	ra,0x0
    80004576:	e5c080e7          	jalr	-420(ra) # 800043ce <dirlookup>
    8000457a:	89aa                	mv	s3,a0
    8000457c:	dd41                	beqz	a0,80004514 <namex+0x96>
    iunlockput(ip);
    8000457e:	8552                	mv	a0,s4
    80004580:	00000097          	auipc	ra,0x0
    80004584:	bcc080e7          	jalr	-1076(ra) # 8000414c <iunlockput>
    ip = next;
    80004588:	8a4e                	mv	s4,s3
  while (*path == '/')
    8000458a:	0004c783          	lbu	a5,0(s1)
    8000458e:	01279763          	bne	a5,s2,8000459c <namex+0x11e>
    path++;
    80004592:	0485                	addi	s1,s1,1
  while (*path == '/')
    80004594:	0004c783          	lbu	a5,0(s1)
    80004598:	ff278de3          	beq	a5,s2,80004592 <namex+0x114>
  if (*path == 0)
    8000459c:	cb9d                	beqz	a5,800045d2 <namex+0x154>
  while (*path != '/' && *path != 0)
    8000459e:	0004c783          	lbu	a5,0(s1)
    800045a2:	89a6                	mv	s3,s1
  len = path - s;
    800045a4:	8d5e                	mv	s10,s7
    800045a6:	865e                	mv	a2,s7
  while (*path != '/' && *path != 0)
    800045a8:	01278963          	beq	a5,s2,800045ba <namex+0x13c>
    800045ac:	dbbd                	beqz	a5,80004522 <namex+0xa4>
    path++;
    800045ae:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    800045b0:	0009c783          	lbu	a5,0(s3)
    800045b4:	ff279ce3          	bne	a5,s2,800045ac <namex+0x12e>
    800045b8:	b7ad                	j	80004522 <namex+0xa4>
    memmove(name, s, len);
    800045ba:	2601                	sext.w	a2,a2
    800045bc:	85a6                	mv	a1,s1
    800045be:	8556                	mv	a0,s5
    800045c0:	ffffd097          	auipc	ra,0xffffd
    800045c4:	8e2080e7          	jalr	-1822(ra) # 80000ea2 <memmove>
    name[len] = 0;
    800045c8:	9d56                	add	s10,s10,s5
    800045ca:	000d0023          	sb	zero,0(s10)
    800045ce:	84ce                	mv	s1,s3
    800045d0:	b7bd                	j	8000453e <namex+0xc0>
  if (nameiparent)
    800045d2:	f00b0ce3          	beqz	s6,800044ea <namex+0x6c>
    iput(ip);
    800045d6:	8552                	mv	a0,s4
    800045d8:	00000097          	auipc	ra,0x0
    800045dc:	acc080e7          	jalr	-1332(ra) # 800040a4 <iput>
    return 0;
    800045e0:	4a01                	li	s4,0
    800045e2:	b721                	j	800044ea <namex+0x6c>

00000000800045e4 <dirlink>:
{
    800045e4:	7139                	addi	sp,sp,-64
    800045e6:	fc06                	sd	ra,56(sp)
    800045e8:	f822                	sd	s0,48(sp)
    800045ea:	f426                	sd	s1,40(sp)
    800045ec:	f04a                	sd	s2,32(sp)
    800045ee:	ec4e                	sd	s3,24(sp)
    800045f0:	e852                	sd	s4,16(sp)
    800045f2:	0080                	addi	s0,sp,64
    800045f4:	892a                	mv	s2,a0
    800045f6:	8a2e                	mv	s4,a1
    800045f8:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0)
    800045fa:	4601                	li	a2,0
    800045fc:	00000097          	auipc	ra,0x0
    80004600:	dd2080e7          	jalr	-558(ra) # 800043ce <dirlookup>
    80004604:	e93d                	bnez	a0,8000467a <dirlink+0x96>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004606:	04c92483          	lw	s1,76(s2)
    8000460a:	c49d                	beqz	s1,80004638 <dirlink+0x54>
    8000460c:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000460e:	4741                	li	a4,16
    80004610:	86a6                	mv	a3,s1
    80004612:	fc040613          	addi	a2,s0,-64
    80004616:	4581                	li	a1,0
    80004618:	854a                	mv	a0,s2
    8000461a:	00000097          	auipc	ra,0x0
    8000461e:	b84080e7          	jalr	-1148(ra) # 8000419e <readi>
    80004622:	47c1                	li	a5,16
    80004624:	06f51163          	bne	a0,a5,80004686 <dirlink+0xa2>
    if (de.inum == 0)
    80004628:	fc045783          	lhu	a5,-64(s0)
    8000462c:	c791                	beqz	a5,80004638 <dirlink+0x54>
  for (off = 0; off < dp->size; off += sizeof(de))
    8000462e:	24c1                	addiw	s1,s1,16
    80004630:	04c92783          	lw	a5,76(s2)
    80004634:	fcf4ede3          	bltu	s1,a5,8000460e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004638:	4639                	li	a2,14
    8000463a:	85d2                	mv	a1,s4
    8000463c:	fc240513          	addi	a0,s0,-62
    80004640:	ffffd097          	auipc	ra,0xffffd
    80004644:	912080e7          	jalr	-1774(ra) # 80000f52 <strncpy>
  de.inum = inum;
    80004648:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000464c:	4741                	li	a4,16
    8000464e:	86a6                	mv	a3,s1
    80004650:	fc040613          	addi	a2,s0,-64
    80004654:	4581                	li	a1,0
    80004656:	854a                	mv	a0,s2
    80004658:	00000097          	auipc	ra,0x0
    8000465c:	c3e080e7          	jalr	-962(ra) # 80004296 <writei>
    80004660:	1541                	addi	a0,a0,-16
    80004662:	00a03533          	snez	a0,a0
    80004666:	40a00533          	neg	a0,a0
}
    8000466a:	70e2                	ld	ra,56(sp)
    8000466c:	7442                	ld	s0,48(sp)
    8000466e:	74a2                	ld	s1,40(sp)
    80004670:	7902                	ld	s2,32(sp)
    80004672:	69e2                	ld	s3,24(sp)
    80004674:	6a42                	ld	s4,16(sp)
    80004676:	6121                	addi	sp,sp,64
    80004678:	8082                	ret
    iput(ip);
    8000467a:	00000097          	auipc	ra,0x0
    8000467e:	a2a080e7          	jalr	-1494(ra) # 800040a4 <iput>
    return -1;
    80004682:	557d                	li	a0,-1
    80004684:	b7dd                	j	8000466a <dirlink+0x86>
      panic("dirlink read");
    80004686:	00004517          	auipc	a0,0x4
    8000468a:	14a50513          	addi	a0,a0,330 # 800087d0 <syscalls+0x1f8>
    8000468e:	ffffc097          	auipc	ra,0xffffc
    80004692:	eb2080e7          	jalr	-334(ra) # 80000540 <panic>

0000000080004696 <namei>:

struct inode *
namei(char *path)
{
    80004696:	1101                	addi	sp,sp,-32
    80004698:	ec06                	sd	ra,24(sp)
    8000469a:	e822                	sd	s0,16(sp)
    8000469c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000469e:	fe040613          	addi	a2,s0,-32
    800046a2:	4581                	li	a1,0
    800046a4:	00000097          	auipc	ra,0x0
    800046a8:	dda080e7          	jalr	-550(ra) # 8000447e <namex>
}
    800046ac:	60e2                	ld	ra,24(sp)
    800046ae:	6442                	ld	s0,16(sp)
    800046b0:	6105                	addi	sp,sp,32
    800046b2:	8082                	ret

00000000800046b4 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    800046b4:	1141                	addi	sp,sp,-16
    800046b6:	e406                	sd	ra,8(sp)
    800046b8:	e022                	sd	s0,0(sp)
    800046ba:	0800                	addi	s0,sp,16
    800046bc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800046be:	4585                	li	a1,1
    800046c0:	00000097          	auipc	ra,0x0
    800046c4:	dbe080e7          	jalr	-578(ra) # 8000447e <namex>
}
    800046c8:	60a2                	ld	ra,8(sp)
    800046ca:	6402                	ld	s0,0(sp)
    800046cc:	0141                	addi	sp,sp,16
    800046ce:	8082                	ret

00000000800046d0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800046d0:	1101                	addi	sp,sp,-32
    800046d2:	ec06                	sd	ra,24(sp)
    800046d4:	e822                	sd	s0,16(sp)
    800046d6:	e426                	sd	s1,8(sp)
    800046d8:	e04a                	sd	s2,0(sp)
    800046da:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800046dc:	0023f917          	auipc	s2,0x23f
    800046e0:	93490913          	addi	s2,s2,-1740 # 80243010 <log>
    800046e4:	01892583          	lw	a1,24(s2)
    800046e8:	02892503          	lw	a0,40(s2)
    800046ec:	fffff097          	auipc	ra,0xfffff
    800046f0:	fe6080e7          	jalr	-26(ra) # 800036d2 <bread>
    800046f4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    800046f6:	02c92683          	lw	a3,44(s2)
    800046fa:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++)
    800046fc:	02d05863          	blez	a3,8000472c <write_head+0x5c>
    80004700:	0023f797          	auipc	a5,0x23f
    80004704:	94078793          	addi	a5,a5,-1728 # 80243040 <log+0x30>
    80004708:	05c50713          	addi	a4,a0,92
    8000470c:	36fd                	addiw	a3,a3,-1
    8000470e:	02069613          	slli	a2,a3,0x20
    80004712:	01e65693          	srli	a3,a2,0x1e
    80004716:	0023f617          	auipc	a2,0x23f
    8000471a:	92e60613          	addi	a2,a2,-1746 # 80243044 <log+0x34>
    8000471e:	96b2                	add	a3,a3,a2
  {
    hb->block[i] = log.lh.block[i];
    80004720:	4390                	lw	a2,0(a5)
    80004722:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    80004724:	0791                	addi	a5,a5,4
    80004726:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004728:	fed79ce3          	bne	a5,a3,80004720 <write_head+0x50>
  }
  bwrite(buf);
    8000472c:	8526                	mv	a0,s1
    8000472e:	fffff097          	auipc	ra,0xfffff
    80004732:	096080e7          	jalr	150(ra) # 800037c4 <bwrite>
  brelse(buf);
    80004736:	8526                	mv	a0,s1
    80004738:	fffff097          	auipc	ra,0xfffff
    8000473c:	0ca080e7          	jalr	202(ra) # 80003802 <brelse>
}
    80004740:	60e2                	ld	ra,24(sp)
    80004742:	6442                	ld	s0,16(sp)
    80004744:	64a2                	ld	s1,8(sp)
    80004746:	6902                	ld	s2,0(sp)
    80004748:	6105                	addi	sp,sp,32
    8000474a:	8082                	ret

000000008000474c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++)
    8000474c:	0023f797          	auipc	a5,0x23f
    80004750:	8f07a783          	lw	a5,-1808(a5) # 8024303c <log+0x2c>
    80004754:	0af05d63          	blez	a5,8000480e <install_trans+0xc2>
{
    80004758:	7139                	addi	sp,sp,-64
    8000475a:	fc06                	sd	ra,56(sp)
    8000475c:	f822                	sd	s0,48(sp)
    8000475e:	f426                	sd	s1,40(sp)
    80004760:	f04a                	sd	s2,32(sp)
    80004762:	ec4e                	sd	s3,24(sp)
    80004764:	e852                	sd	s4,16(sp)
    80004766:	e456                	sd	s5,8(sp)
    80004768:	e05a                	sd	s6,0(sp)
    8000476a:	0080                	addi	s0,sp,64
    8000476c:	8b2a                	mv	s6,a0
    8000476e:	0023fa97          	auipc	s5,0x23f
    80004772:	8d2a8a93          	addi	s5,s5,-1838 # 80243040 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++)
    80004776:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80004778:	0023f997          	auipc	s3,0x23f
    8000477c:	89898993          	addi	s3,s3,-1896 # 80243010 <log>
    80004780:	a00d                	j	800047a2 <install_trans+0x56>
    brelse(lbuf);
    80004782:	854a                	mv	a0,s2
    80004784:	fffff097          	auipc	ra,0xfffff
    80004788:	07e080e7          	jalr	126(ra) # 80003802 <brelse>
    brelse(dbuf);
    8000478c:	8526                	mv	a0,s1
    8000478e:	fffff097          	auipc	ra,0xfffff
    80004792:	074080e7          	jalr	116(ra) # 80003802 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    80004796:	2a05                	addiw	s4,s4,1
    80004798:	0a91                	addi	s5,s5,4
    8000479a:	02c9a783          	lw	a5,44(s3)
    8000479e:	04fa5e63          	bge	s4,a5,800047fa <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    800047a2:	0189a583          	lw	a1,24(s3)
    800047a6:	014585bb          	addw	a1,a1,s4
    800047aa:	2585                	addiw	a1,a1,1
    800047ac:	0289a503          	lw	a0,40(s3)
    800047b0:	fffff097          	auipc	ra,0xfffff
    800047b4:	f22080e7          	jalr	-222(ra) # 800036d2 <bread>
    800047b8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    800047ba:	000aa583          	lw	a1,0(s5)
    800047be:	0289a503          	lw	a0,40(s3)
    800047c2:	fffff097          	auipc	ra,0xfffff
    800047c6:	f10080e7          	jalr	-240(ra) # 800036d2 <bread>
    800047ca:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);                  // copy block to dst
    800047cc:	40000613          	li	a2,1024
    800047d0:	05890593          	addi	a1,s2,88
    800047d4:	05850513          	addi	a0,a0,88
    800047d8:	ffffc097          	auipc	ra,0xffffc
    800047dc:	6ca080e7          	jalr	1738(ra) # 80000ea2 <memmove>
    bwrite(dbuf);                                            // write dst to disk
    800047e0:	8526                	mv	a0,s1
    800047e2:	fffff097          	auipc	ra,0xfffff
    800047e6:	fe2080e7          	jalr	-30(ra) # 800037c4 <bwrite>
    if (recovering == 0)
    800047ea:	f80b1ce3          	bnez	s6,80004782 <install_trans+0x36>
      bunpin(dbuf);
    800047ee:	8526                	mv	a0,s1
    800047f0:	fffff097          	auipc	ra,0xfffff
    800047f4:	0ec080e7          	jalr	236(ra) # 800038dc <bunpin>
    800047f8:	b769                	j	80004782 <install_trans+0x36>
}
    800047fa:	70e2                	ld	ra,56(sp)
    800047fc:	7442                	ld	s0,48(sp)
    800047fe:	74a2                	ld	s1,40(sp)
    80004800:	7902                	ld	s2,32(sp)
    80004802:	69e2                	ld	s3,24(sp)
    80004804:	6a42                	ld	s4,16(sp)
    80004806:	6aa2                	ld	s5,8(sp)
    80004808:	6b02                	ld	s6,0(sp)
    8000480a:	6121                	addi	sp,sp,64
    8000480c:	8082                	ret
    8000480e:	8082                	ret

0000000080004810 <initlog>:
{
    80004810:	7179                	addi	sp,sp,-48
    80004812:	f406                	sd	ra,40(sp)
    80004814:	f022                	sd	s0,32(sp)
    80004816:	ec26                	sd	s1,24(sp)
    80004818:	e84a                	sd	s2,16(sp)
    8000481a:	e44e                	sd	s3,8(sp)
    8000481c:	1800                	addi	s0,sp,48
    8000481e:	892a                	mv	s2,a0
    80004820:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004822:	0023e497          	auipc	s1,0x23e
    80004826:	7ee48493          	addi	s1,s1,2030 # 80243010 <log>
    8000482a:	00004597          	auipc	a1,0x4
    8000482e:	fb658593          	addi	a1,a1,-74 # 800087e0 <syscalls+0x208>
    80004832:	8526                	mv	a0,s1
    80004834:	ffffc097          	auipc	ra,0xffffc
    80004838:	486080e7          	jalr	1158(ra) # 80000cba <initlock>
  log.start = sb->logstart;
    8000483c:	0149a583          	lw	a1,20(s3)
    80004840:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004842:	0109a783          	lw	a5,16(s3)
    80004846:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004848:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000484c:	854a                	mv	a0,s2
    8000484e:	fffff097          	auipc	ra,0xfffff
    80004852:	e84080e7          	jalr	-380(ra) # 800036d2 <bread>
  log.lh.n = lh->n;
    80004856:	4d34                	lw	a3,88(a0)
    80004858:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++)
    8000485a:	02d05663          	blez	a3,80004886 <initlog+0x76>
    8000485e:	05c50793          	addi	a5,a0,92
    80004862:	0023e717          	auipc	a4,0x23e
    80004866:	7de70713          	addi	a4,a4,2014 # 80243040 <log+0x30>
    8000486a:	36fd                	addiw	a3,a3,-1
    8000486c:	02069613          	slli	a2,a3,0x20
    80004870:	01e65693          	srli	a3,a2,0x1e
    80004874:	06050613          	addi	a2,a0,96
    80004878:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000487a:	4390                	lw	a2,0(a5)
    8000487c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    8000487e:	0791                	addi	a5,a5,4
    80004880:	0711                	addi	a4,a4,4
    80004882:	fed79ce3          	bne	a5,a3,8000487a <initlog+0x6a>
  brelse(buf);
    80004886:	fffff097          	auipc	ra,0xfffff
    8000488a:	f7c080e7          	jalr	-132(ra) # 80003802 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000488e:	4505                	li	a0,1
    80004890:	00000097          	auipc	ra,0x0
    80004894:	ebc080e7          	jalr	-324(ra) # 8000474c <install_trans>
  log.lh.n = 0;
    80004898:	0023e797          	auipc	a5,0x23e
    8000489c:	7a07a223          	sw	zero,1956(a5) # 8024303c <log+0x2c>
  write_head(); // clear the log
    800048a0:	00000097          	auipc	ra,0x0
    800048a4:	e30080e7          	jalr	-464(ra) # 800046d0 <write_head>
}
    800048a8:	70a2                	ld	ra,40(sp)
    800048aa:	7402                	ld	s0,32(sp)
    800048ac:	64e2                	ld	s1,24(sp)
    800048ae:	6942                	ld	s2,16(sp)
    800048b0:	69a2                	ld	s3,8(sp)
    800048b2:	6145                	addi	sp,sp,48
    800048b4:	8082                	ret

00000000800048b6 <begin_op>:
}

// called at the start of each FS system call.
void begin_op(void)
{
    800048b6:	1101                	addi	sp,sp,-32
    800048b8:	ec06                	sd	ra,24(sp)
    800048ba:	e822                	sd	s0,16(sp)
    800048bc:	e426                	sd	s1,8(sp)
    800048be:	e04a                	sd	s2,0(sp)
    800048c0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800048c2:	0023e517          	auipc	a0,0x23e
    800048c6:	74e50513          	addi	a0,a0,1870 # 80243010 <log>
    800048ca:	ffffc097          	auipc	ra,0xffffc
    800048ce:	480080e7          	jalr	1152(ra) # 80000d4a <acquire>
  while (1)
  {
    if (log.committing)
    800048d2:	0023e497          	auipc	s1,0x23e
    800048d6:	73e48493          	addi	s1,s1,1854 # 80243010 <log>
    {
      sleep(&log, &log.lock);
    }
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    800048da:	4979                	li	s2,30
    800048dc:	a039                	j	800048ea <begin_op+0x34>
      sleep(&log, &log.lock);
    800048de:	85a6                	mv	a1,s1
    800048e0:	8526                	mv	a0,s1
    800048e2:	ffffe097          	auipc	ra,0xffffe
    800048e6:	a4a080e7          	jalr	-1462(ra) # 8000232c <sleep>
    if (log.committing)
    800048ea:	50dc                	lw	a5,36(s1)
    800048ec:	fbed                	bnez	a5,800048de <begin_op+0x28>
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    800048ee:	5098                	lw	a4,32(s1)
    800048f0:	2705                	addiw	a4,a4,1
    800048f2:	0007069b          	sext.w	a3,a4
    800048f6:	0027179b          	slliw	a5,a4,0x2
    800048fa:	9fb9                	addw	a5,a5,a4
    800048fc:	0017979b          	slliw	a5,a5,0x1
    80004900:	54d8                	lw	a4,44(s1)
    80004902:	9fb9                	addw	a5,a5,a4
    80004904:	00f95963          	bge	s2,a5,80004916 <begin_op+0x60>
    {
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004908:	85a6                	mv	a1,s1
    8000490a:	8526                	mv	a0,s1
    8000490c:	ffffe097          	auipc	ra,0xffffe
    80004910:	a20080e7          	jalr	-1504(ra) # 8000232c <sleep>
    80004914:	bfd9                	j	800048ea <begin_op+0x34>
    }
    else
    {
      log.outstanding += 1;
    80004916:	0023e517          	auipc	a0,0x23e
    8000491a:	6fa50513          	addi	a0,a0,1786 # 80243010 <log>
    8000491e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	4de080e7          	jalr	1246(ra) # 80000dfe <release>
      break;
    }
  }
}
    80004928:	60e2                	ld	ra,24(sp)
    8000492a:	6442                	ld	s0,16(sp)
    8000492c:	64a2                	ld	s1,8(sp)
    8000492e:	6902                	ld	s2,0(sp)
    80004930:	6105                	addi	sp,sp,32
    80004932:	8082                	ret

0000000080004934 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
    80004934:	7139                	addi	sp,sp,-64
    80004936:	fc06                	sd	ra,56(sp)
    80004938:	f822                	sd	s0,48(sp)
    8000493a:	f426                	sd	s1,40(sp)
    8000493c:	f04a                	sd	s2,32(sp)
    8000493e:	ec4e                	sd	s3,24(sp)
    80004940:	e852                	sd	s4,16(sp)
    80004942:	e456                	sd	s5,8(sp)
    80004944:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004946:	0023e497          	auipc	s1,0x23e
    8000494a:	6ca48493          	addi	s1,s1,1738 # 80243010 <log>
    8000494e:	8526                	mv	a0,s1
    80004950:	ffffc097          	auipc	ra,0xffffc
    80004954:	3fa080e7          	jalr	1018(ra) # 80000d4a <acquire>
  log.outstanding -= 1;
    80004958:	509c                	lw	a5,32(s1)
    8000495a:	37fd                	addiw	a5,a5,-1
    8000495c:	0007891b          	sext.w	s2,a5
    80004960:	d09c                	sw	a5,32(s1)
  if (log.committing)
    80004962:	50dc                	lw	a5,36(s1)
    80004964:	e7b9                	bnez	a5,800049b2 <end_op+0x7e>
    panic("log.committing");
  if (log.outstanding == 0)
    80004966:	04091e63          	bnez	s2,800049c2 <end_op+0x8e>
  {
    do_commit = 1;
    log.committing = 1;
    8000496a:	0023e497          	auipc	s1,0x23e
    8000496e:	6a648493          	addi	s1,s1,1702 # 80243010 <log>
    80004972:	4785                	li	a5,1
    80004974:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004976:	8526                	mv	a0,s1
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	486080e7          	jalr	1158(ra) # 80000dfe <release>
}

static void
commit()
{
  if (log.lh.n > 0)
    80004980:	54dc                	lw	a5,44(s1)
    80004982:	06f04763          	bgtz	a5,800049f0 <end_op+0xbc>
    acquire(&log.lock);
    80004986:	0023e497          	auipc	s1,0x23e
    8000498a:	68a48493          	addi	s1,s1,1674 # 80243010 <log>
    8000498e:	8526                	mv	a0,s1
    80004990:	ffffc097          	auipc	ra,0xffffc
    80004994:	3ba080e7          	jalr	954(ra) # 80000d4a <acquire>
    log.committing = 0;
    80004998:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000499c:	8526                	mv	a0,s1
    8000499e:	ffffe097          	auipc	ra,0xffffe
    800049a2:	b4a080e7          	jalr	-1206(ra) # 800024e8 <wakeup>
    release(&log.lock);
    800049a6:	8526                	mv	a0,s1
    800049a8:	ffffc097          	auipc	ra,0xffffc
    800049ac:	456080e7          	jalr	1110(ra) # 80000dfe <release>
}
    800049b0:	a03d                	j	800049de <end_op+0xaa>
    panic("log.committing");
    800049b2:	00004517          	auipc	a0,0x4
    800049b6:	e3650513          	addi	a0,a0,-458 # 800087e8 <syscalls+0x210>
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	b86080e7          	jalr	-1146(ra) # 80000540 <panic>
    wakeup(&log);
    800049c2:	0023e497          	auipc	s1,0x23e
    800049c6:	64e48493          	addi	s1,s1,1614 # 80243010 <log>
    800049ca:	8526                	mv	a0,s1
    800049cc:	ffffe097          	auipc	ra,0xffffe
    800049d0:	b1c080e7          	jalr	-1252(ra) # 800024e8 <wakeup>
  release(&log.lock);
    800049d4:	8526                	mv	a0,s1
    800049d6:	ffffc097          	auipc	ra,0xffffc
    800049da:	428080e7          	jalr	1064(ra) # 80000dfe <release>
}
    800049de:	70e2                	ld	ra,56(sp)
    800049e0:	7442                	ld	s0,48(sp)
    800049e2:	74a2                	ld	s1,40(sp)
    800049e4:	7902                	ld	s2,32(sp)
    800049e6:	69e2                	ld	s3,24(sp)
    800049e8:	6a42                	ld	s4,16(sp)
    800049ea:	6aa2                	ld	s5,8(sp)
    800049ec:	6121                	addi	sp,sp,64
    800049ee:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++)
    800049f0:	0023ea97          	auipc	s5,0x23e
    800049f4:	650a8a93          	addi	s5,s5,1616 # 80243040 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    800049f8:	0023ea17          	auipc	s4,0x23e
    800049fc:	618a0a13          	addi	s4,s4,1560 # 80243010 <log>
    80004a00:	018a2583          	lw	a1,24(s4)
    80004a04:	012585bb          	addw	a1,a1,s2
    80004a08:	2585                	addiw	a1,a1,1
    80004a0a:	028a2503          	lw	a0,40(s4)
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	cc4080e7          	jalr	-828(ra) # 800036d2 <bread>
    80004a16:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004a18:	000aa583          	lw	a1,0(s5)
    80004a1c:	028a2503          	lw	a0,40(s4)
    80004a20:	fffff097          	auipc	ra,0xfffff
    80004a24:	cb2080e7          	jalr	-846(ra) # 800036d2 <bread>
    80004a28:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004a2a:	40000613          	li	a2,1024
    80004a2e:	05850593          	addi	a1,a0,88
    80004a32:	05848513          	addi	a0,s1,88
    80004a36:	ffffc097          	auipc	ra,0xffffc
    80004a3a:	46c080e7          	jalr	1132(ra) # 80000ea2 <memmove>
    bwrite(to); // write the log
    80004a3e:	8526                	mv	a0,s1
    80004a40:	fffff097          	auipc	ra,0xfffff
    80004a44:	d84080e7          	jalr	-636(ra) # 800037c4 <bwrite>
    brelse(from);
    80004a48:	854e                	mv	a0,s3
    80004a4a:	fffff097          	auipc	ra,0xfffff
    80004a4e:	db8080e7          	jalr	-584(ra) # 80003802 <brelse>
    brelse(to);
    80004a52:	8526                	mv	a0,s1
    80004a54:	fffff097          	auipc	ra,0xfffff
    80004a58:	dae080e7          	jalr	-594(ra) # 80003802 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    80004a5c:	2905                	addiw	s2,s2,1
    80004a5e:	0a91                	addi	s5,s5,4
    80004a60:	02ca2783          	lw	a5,44(s4)
    80004a64:	f8f94ee3          	blt	s2,a5,80004a00 <end_op+0xcc>
  {
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80004a68:	00000097          	auipc	ra,0x0
    80004a6c:	c68080e7          	jalr	-920(ra) # 800046d0 <write_head>
    install_trans(0); // Now install writes to home locations
    80004a70:	4501                	li	a0,0
    80004a72:	00000097          	auipc	ra,0x0
    80004a76:	cda080e7          	jalr	-806(ra) # 8000474c <install_trans>
    log.lh.n = 0;
    80004a7a:	0023e797          	auipc	a5,0x23e
    80004a7e:	5c07a123          	sw	zero,1474(a5) # 8024303c <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004a82:	00000097          	auipc	ra,0x0
    80004a86:	c4e080e7          	jalr	-946(ra) # 800046d0 <write_head>
    80004a8a:	bdf5                	j	80004986 <end_op+0x52>

0000000080004a8c <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
    80004a8c:	1101                	addi	sp,sp,-32
    80004a8e:	ec06                	sd	ra,24(sp)
    80004a90:	e822                	sd	s0,16(sp)
    80004a92:	e426                	sd	s1,8(sp)
    80004a94:	e04a                	sd	s2,0(sp)
    80004a96:	1000                	addi	s0,sp,32
    80004a98:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a9a:	0023e917          	auipc	s2,0x23e
    80004a9e:	57690913          	addi	s2,s2,1398 # 80243010 <log>
    80004aa2:	854a                	mv	a0,s2
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	2a6080e7          	jalr	678(ra) # 80000d4a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004aac:	02c92603          	lw	a2,44(s2)
    80004ab0:	47f5                	li	a5,29
    80004ab2:	06c7c563          	blt	a5,a2,80004b1c <log_write+0x90>
    80004ab6:	0023e797          	auipc	a5,0x23e
    80004aba:	5767a783          	lw	a5,1398(a5) # 8024302c <log+0x1c>
    80004abe:	37fd                	addiw	a5,a5,-1
    80004ac0:	04f65e63          	bge	a2,a5,80004b1c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004ac4:	0023e797          	auipc	a5,0x23e
    80004ac8:	56c7a783          	lw	a5,1388(a5) # 80243030 <log+0x20>
    80004acc:	06f05063          	blez	a5,80004b2c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++)
    80004ad0:	4781                	li	a5,0
    80004ad2:	06c05563          	blez	a2,80004b3c <log_write+0xb0>
  {
    if (log.lh.block[i] == b->blockno) // log absorption
    80004ad6:	44cc                	lw	a1,12(s1)
    80004ad8:	0023e717          	auipc	a4,0x23e
    80004adc:	56870713          	addi	a4,a4,1384 # 80243040 <log+0x30>
  for (i = 0; i < log.lh.n; i++)
    80004ae0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004ae2:	4314                	lw	a3,0(a4)
    80004ae4:	04b68c63          	beq	a3,a1,80004b3c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++)
    80004ae8:	2785                	addiw	a5,a5,1
    80004aea:	0711                	addi	a4,a4,4
    80004aec:	fef61be3          	bne	a2,a5,80004ae2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004af0:	0621                	addi	a2,a2,8
    80004af2:	060a                	slli	a2,a2,0x2
    80004af4:	0023e797          	auipc	a5,0x23e
    80004af8:	51c78793          	addi	a5,a5,1308 # 80243010 <log>
    80004afc:	97b2                	add	a5,a5,a2
    80004afe:	44d8                	lw	a4,12(s1)
    80004b00:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n)
  { // Add new block to log?
    bpin(b);
    80004b02:	8526                	mv	a0,s1
    80004b04:	fffff097          	auipc	ra,0xfffff
    80004b08:	d9c080e7          	jalr	-612(ra) # 800038a0 <bpin>
    log.lh.n++;
    80004b0c:	0023e717          	auipc	a4,0x23e
    80004b10:	50470713          	addi	a4,a4,1284 # 80243010 <log>
    80004b14:	575c                	lw	a5,44(a4)
    80004b16:	2785                	addiw	a5,a5,1
    80004b18:	d75c                	sw	a5,44(a4)
    80004b1a:	a82d                	j	80004b54 <log_write+0xc8>
    panic("too big a transaction");
    80004b1c:	00004517          	auipc	a0,0x4
    80004b20:	cdc50513          	addi	a0,a0,-804 # 800087f8 <syscalls+0x220>
    80004b24:	ffffc097          	auipc	ra,0xffffc
    80004b28:	a1c080e7          	jalr	-1508(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004b2c:	00004517          	auipc	a0,0x4
    80004b30:	ce450513          	addi	a0,a0,-796 # 80008810 <syscalls+0x238>
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	a0c080e7          	jalr	-1524(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004b3c:	00878693          	addi	a3,a5,8
    80004b40:	068a                	slli	a3,a3,0x2
    80004b42:	0023e717          	auipc	a4,0x23e
    80004b46:	4ce70713          	addi	a4,a4,1230 # 80243010 <log>
    80004b4a:	9736                	add	a4,a4,a3
    80004b4c:	44d4                	lw	a3,12(s1)
    80004b4e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n)
    80004b50:	faf609e3          	beq	a2,a5,80004b02 <log_write+0x76>
  }
  release(&log.lock);
    80004b54:	0023e517          	auipc	a0,0x23e
    80004b58:	4bc50513          	addi	a0,a0,1212 # 80243010 <log>
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	2a2080e7          	jalr	674(ra) # 80000dfe <release>
}
    80004b64:	60e2                	ld	ra,24(sp)
    80004b66:	6442                	ld	s0,16(sp)
    80004b68:	64a2                	ld	s1,8(sp)
    80004b6a:	6902                	ld	s2,0(sp)
    80004b6c:	6105                	addi	sp,sp,32
    80004b6e:	8082                	ret

0000000080004b70 <initsleeplock>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock *lk, char *name)
{
    80004b70:	1101                	addi	sp,sp,-32
    80004b72:	ec06                	sd	ra,24(sp)
    80004b74:	e822                	sd	s0,16(sp)
    80004b76:	e426                	sd	s1,8(sp)
    80004b78:	e04a                	sd	s2,0(sp)
    80004b7a:	1000                	addi	s0,sp,32
    80004b7c:	84aa                	mv	s1,a0
    80004b7e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b80:	00004597          	auipc	a1,0x4
    80004b84:	cb058593          	addi	a1,a1,-848 # 80008830 <syscalls+0x258>
    80004b88:	0521                	addi	a0,a0,8
    80004b8a:	ffffc097          	auipc	ra,0xffffc
    80004b8e:	130080e7          	jalr	304(ra) # 80000cba <initlock>
  lk->name = name;
    80004b92:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b96:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b9a:	0204a423          	sw	zero,40(s1)
}
    80004b9e:	60e2                	ld	ra,24(sp)
    80004ba0:	6442                	ld	s0,16(sp)
    80004ba2:	64a2                	ld	s1,8(sp)
    80004ba4:	6902                	ld	s2,0(sp)
    80004ba6:	6105                	addi	sp,sp,32
    80004ba8:	8082                	ret

0000000080004baa <acquiresleep>:

void acquiresleep(struct sleeplock *lk)
{
    80004baa:	1101                	addi	sp,sp,-32
    80004bac:	ec06                	sd	ra,24(sp)
    80004bae:	e822                	sd	s0,16(sp)
    80004bb0:	e426                	sd	s1,8(sp)
    80004bb2:	e04a                	sd	s2,0(sp)
    80004bb4:	1000                	addi	s0,sp,32
    80004bb6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bb8:	00850913          	addi	s2,a0,8
    80004bbc:	854a                	mv	a0,s2
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	18c080e7          	jalr	396(ra) # 80000d4a <acquire>
  while (lk->locked)
    80004bc6:	409c                	lw	a5,0(s1)
    80004bc8:	cb89                	beqz	a5,80004bda <acquiresleep+0x30>
  {
    sleep(lk, &lk->lk);
    80004bca:	85ca                	mv	a1,s2
    80004bcc:	8526                	mv	a0,s1
    80004bce:	ffffd097          	auipc	ra,0xffffd
    80004bd2:	75e080e7          	jalr	1886(ra) # 8000232c <sleep>
  while (lk->locked)
    80004bd6:	409c                	lw	a5,0(s1)
    80004bd8:	fbed                	bnez	a5,80004bca <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004bda:	4785                	li	a5,1
    80004bdc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004bde:	ffffd097          	auipc	ra,0xffffd
    80004be2:	f9c080e7          	jalr	-100(ra) # 80001b7a <myproc>
    80004be6:	591c                	lw	a5,48(a0)
    80004be8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004bea:	854a                	mv	a0,s2
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	212080e7          	jalr	530(ra) # 80000dfe <release>
}
    80004bf4:	60e2                	ld	ra,24(sp)
    80004bf6:	6442                	ld	s0,16(sp)
    80004bf8:	64a2                	ld	s1,8(sp)
    80004bfa:	6902                	ld	s2,0(sp)
    80004bfc:	6105                	addi	sp,sp,32
    80004bfe:	8082                	ret

0000000080004c00 <releasesleep>:

void releasesleep(struct sleeplock *lk)
{
    80004c00:	1101                	addi	sp,sp,-32
    80004c02:	ec06                	sd	ra,24(sp)
    80004c04:	e822                	sd	s0,16(sp)
    80004c06:	e426                	sd	s1,8(sp)
    80004c08:	e04a                	sd	s2,0(sp)
    80004c0a:	1000                	addi	s0,sp,32
    80004c0c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c0e:	00850913          	addi	s2,a0,8
    80004c12:	854a                	mv	a0,s2
    80004c14:	ffffc097          	auipc	ra,0xffffc
    80004c18:	136080e7          	jalr	310(ra) # 80000d4a <acquire>
  lk->locked = 0;
    80004c1c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c20:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004c24:	8526                	mv	a0,s1
    80004c26:	ffffe097          	auipc	ra,0xffffe
    80004c2a:	8c2080e7          	jalr	-1854(ra) # 800024e8 <wakeup>
  release(&lk->lk);
    80004c2e:	854a                	mv	a0,s2
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	1ce080e7          	jalr	462(ra) # 80000dfe <release>
}
    80004c38:	60e2                	ld	ra,24(sp)
    80004c3a:	6442                	ld	s0,16(sp)
    80004c3c:	64a2                	ld	s1,8(sp)
    80004c3e:	6902                	ld	s2,0(sp)
    80004c40:	6105                	addi	sp,sp,32
    80004c42:	8082                	ret

0000000080004c44 <holdingsleep>:

int holdingsleep(struct sleeplock *lk)
{
    80004c44:	7179                	addi	sp,sp,-48
    80004c46:	f406                	sd	ra,40(sp)
    80004c48:	f022                	sd	s0,32(sp)
    80004c4a:	ec26                	sd	s1,24(sp)
    80004c4c:	e84a                	sd	s2,16(sp)
    80004c4e:	e44e                	sd	s3,8(sp)
    80004c50:	1800                	addi	s0,sp,48
    80004c52:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004c54:	00850913          	addi	s2,a0,8
    80004c58:	854a                	mv	a0,s2
    80004c5a:	ffffc097          	auipc	ra,0xffffc
    80004c5e:	0f0080e7          	jalr	240(ra) # 80000d4a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c62:	409c                	lw	a5,0(s1)
    80004c64:	ef99                	bnez	a5,80004c82 <holdingsleep+0x3e>
    80004c66:	4481                	li	s1,0
  release(&lk->lk);
    80004c68:	854a                	mv	a0,s2
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	194080e7          	jalr	404(ra) # 80000dfe <release>
  return r;
}
    80004c72:	8526                	mv	a0,s1
    80004c74:	70a2                	ld	ra,40(sp)
    80004c76:	7402                	ld	s0,32(sp)
    80004c78:	64e2                	ld	s1,24(sp)
    80004c7a:	6942                	ld	s2,16(sp)
    80004c7c:	69a2                	ld	s3,8(sp)
    80004c7e:	6145                	addi	sp,sp,48
    80004c80:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c82:	0284a983          	lw	s3,40(s1)
    80004c86:	ffffd097          	auipc	ra,0xffffd
    80004c8a:	ef4080e7          	jalr	-268(ra) # 80001b7a <myproc>
    80004c8e:	5904                	lw	s1,48(a0)
    80004c90:	413484b3          	sub	s1,s1,s3
    80004c94:	0014b493          	seqz	s1,s1
    80004c98:	bfc1                	j	80004c68 <holdingsleep+0x24>

0000000080004c9a <fileinit>:
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void fileinit(void)
{
    80004c9a:	1141                	addi	sp,sp,-16
    80004c9c:	e406                	sd	ra,8(sp)
    80004c9e:	e022                	sd	s0,0(sp)
    80004ca0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ca2:	00004597          	auipc	a1,0x4
    80004ca6:	b9e58593          	addi	a1,a1,-1122 # 80008840 <syscalls+0x268>
    80004caa:	0023e517          	auipc	a0,0x23e
    80004cae:	4ae50513          	addi	a0,a0,1198 # 80243158 <ftable>
    80004cb2:	ffffc097          	auipc	ra,0xffffc
    80004cb6:	008080e7          	jalr	8(ra) # 80000cba <initlock>
}
    80004cba:	60a2                	ld	ra,8(sp)
    80004cbc:	6402                	ld	s0,0(sp)
    80004cbe:	0141                	addi	sp,sp,16
    80004cc0:	8082                	ret

0000000080004cc2 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004cc2:	1101                	addi	sp,sp,-32
    80004cc4:	ec06                	sd	ra,24(sp)
    80004cc6:	e822                	sd	s0,16(sp)
    80004cc8:	e426                	sd	s1,8(sp)
    80004cca:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ccc:	0023e517          	auipc	a0,0x23e
    80004cd0:	48c50513          	addi	a0,a0,1164 # 80243158 <ftable>
    80004cd4:	ffffc097          	auipc	ra,0xffffc
    80004cd8:	076080e7          	jalr	118(ra) # 80000d4a <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004cdc:	0023e497          	auipc	s1,0x23e
    80004ce0:	49448493          	addi	s1,s1,1172 # 80243170 <ftable+0x18>
    80004ce4:	0023f717          	auipc	a4,0x23f
    80004ce8:	42c70713          	addi	a4,a4,1068 # 80244110 <mt>
  {
    if (f->ref == 0)
    80004cec:	40dc                	lw	a5,4(s1)
    80004cee:	cf99                	beqz	a5,80004d0c <filealloc+0x4a>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004cf0:	02848493          	addi	s1,s1,40
    80004cf4:	fee49ce3          	bne	s1,a4,80004cec <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004cf8:	0023e517          	auipc	a0,0x23e
    80004cfc:	46050513          	addi	a0,a0,1120 # 80243158 <ftable>
    80004d00:	ffffc097          	auipc	ra,0xffffc
    80004d04:	0fe080e7          	jalr	254(ra) # 80000dfe <release>
  return 0;
    80004d08:	4481                	li	s1,0
    80004d0a:	a819                	j	80004d20 <filealloc+0x5e>
      f->ref = 1;
    80004d0c:	4785                	li	a5,1
    80004d0e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004d10:	0023e517          	auipc	a0,0x23e
    80004d14:	44850513          	addi	a0,a0,1096 # 80243158 <ftable>
    80004d18:	ffffc097          	auipc	ra,0xffffc
    80004d1c:	0e6080e7          	jalr	230(ra) # 80000dfe <release>
}
    80004d20:	8526                	mv	a0,s1
    80004d22:	60e2                	ld	ra,24(sp)
    80004d24:	6442                	ld	s0,16(sp)
    80004d26:	64a2                	ld	s1,8(sp)
    80004d28:	6105                	addi	sp,sp,32
    80004d2a:	8082                	ret

0000000080004d2c <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004d2c:	1101                	addi	sp,sp,-32
    80004d2e:	ec06                	sd	ra,24(sp)
    80004d30:	e822                	sd	s0,16(sp)
    80004d32:	e426                	sd	s1,8(sp)
    80004d34:	1000                	addi	s0,sp,32
    80004d36:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004d38:	0023e517          	auipc	a0,0x23e
    80004d3c:	42050513          	addi	a0,a0,1056 # 80243158 <ftable>
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	00a080e7          	jalr	10(ra) # 80000d4a <acquire>
  if (f->ref < 1)
    80004d48:	40dc                	lw	a5,4(s1)
    80004d4a:	02f05263          	blez	a5,80004d6e <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d4e:	2785                	addiw	a5,a5,1
    80004d50:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d52:	0023e517          	auipc	a0,0x23e
    80004d56:	40650513          	addi	a0,a0,1030 # 80243158 <ftable>
    80004d5a:	ffffc097          	auipc	ra,0xffffc
    80004d5e:	0a4080e7          	jalr	164(ra) # 80000dfe <release>
  return f;
}
    80004d62:	8526                	mv	a0,s1
    80004d64:	60e2                	ld	ra,24(sp)
    80004d66:	6442                	ld	s0,16(sp)
    80004d68:	64a2                	ld	s1,8(sp)
    80004d6a:	6105                	addi	sp,sp,32
    80004d6c:	8082                	ret
    panic("filedup");
    80004d6e:	00004517          	auipc	a0,0x4
    80004d72:	ada50513          	addi	a0,a0,-1318 # 80008848 <syscalls+0x270>
    80004d76:	ffffb097          	auipc	ra,0xffffb
    80004d7a:	7ca080e7          	jalr	1994(ra) # 80000540 <panic>

0000000080004d7e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    80004d7e:	7139                	addi	sp,sp,-64
    80004d80:	fc06                	sd	ra,56(sp)
    80004d82:	f822                	sd	s0,48(sp)
    80004d84:	f426                	sd	s1,40(sp)
    80004d86:	f04a                	sd	s2,32(sp)
    80004d88:	ec4e                	sd	s3,24(sp)
    80004d8a:	e852                	sd	s4,16(sp)
    80004d8c:	e456                	sd	s5,8(sp)
    80004d8e:	0080                	addi	s0,sp,64
    80004d90:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d92:	0023e517          	auipc	a0,0x23e
    80004d96:	3c650513          	addi	a0,a0,966 # 80243158 <ftable>
    80004d9a:	ffffc097          	auipc	ra,0xffffc
    80004d9e:	fb0080e7          	jalr	-80(ra) # 80000d4a <acquire>
  if (f->ref < 1)
    80004da2:	40dc                	lw	a5,4(s1)
    80004da4:	06f05163          	blez	a5,80004e06 <fileclose+0x88>
    panic("fileclose");
  if (--f->ref > 0)
    80004da8:	37fd                	addiw	a5,a5,-1
    80004daa:	0007871b          	sext.w	a4,a5
    80004dae:	c0dc                	sw	a5,4(s1)
    80004db0:	06e04363          	bgtz	a4,80004e16 <fileclose+0x98>
  {
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004db4:	0004a903          	lw	s2,0(s1)
    80004db8:	0094ca83          	lbu	s5,9(s1)
    80004dbc:	0104ba03          	ld	s4,16(s1)
    80004dc0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004dc4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004dc8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004dcc:	0023e517          	auipc	a0,0x23e
    80004dd0:	38c50513          	addi	a0,a0,908 # 80243158 <ftable>
    80004dd4:	ffffc097          	auipc	ra,0xffffc
    80004dd8:	02a080e7          	jalr	42(ra) # 80000dfe <release>

  if (ff.type == FD_PIPE)
    80004ddc:	4785                	li	a5,1
    80004dde:	04f90d63          	beq	s2,a5,80004e38 <fileclose+0xba>
  {
    pipeclose(ff.pipe, ff.writable);
  }
  else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    80004de2:	3979                	addiw	s2,s2,-2
    80004de4:	4785                	li	a5,1
    80004de6:	0527e063          	bltu	a5,s2,80004e26 <fileclose+0xa8>
  {
    begin_op();
    80004dea:	00000097          	auipc	ra,0x0
    80004dee:	acc080e7          	jalr	-1332(ra) # 800048b6 <begin_op>
    iput(ff.ip);
    80004df2:	854e                	mv	a0,s3
    80004df4:	fffff097          	auipc	ra,0xfffff
    80004df8:	2b0080e7          	jalr	688(ra) # 800040a4 <iput>
    end_op();
    80004dfc:	00000097          	auipc	ra,0x0
    80004e00:	b38080e7          	jalr	-1224(ra) # 80004934 <end_op>
    80004e04:	a00d                	j	80004e26 <fileclose+0xa8>
    panic("fileclose");
    80004e06:	00004517          	auipc	a0,0x4
    80004e0a:	a4a50513          	addi	a0,a0,-1462 # 80008850 <syscalls+0x278>
    80004e0e:	ffffb097          	auipc	ra,0xffffb
    80004e12:	732080e7          	jalr	1842(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004e16:	0023e517          	auipc	a0,0x23e
    80004e1a:	34250513          	addi	a0,a0,834 # 80243158 <ftable>
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	fe0080e7          	jalr	-32(ra) # 80000dfe <release>
  }
}
    80004e26:	70e2                	ld	ra,56(sp)
    80004e28:	7442                	ld	s0,48(sp)
    80004e2a:	74a2                	ld	s1,40(sp)
    80004e2c:	7902                	ld	s2,32(sp)
    80004e2e:	69e2                	ld	s3,24(sp)
    80004e30:	6a42                	ld	s4,16(sp)
    80004e32:	6aa2                	ld	s5,8(sp)
    80004e34:	6121                	addi	sp,sp,64
    80004e36:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004e38:	85d6                	mv	a1,s5
    80004e3a:	8552                	mv	a0,s4
    80004e3c:	00000097          	auipc	ra,0x0
    80004e40:	34c080e7          	jalr	844(ra) # 80005188 <pipeclose>
    80004e44:	b7cd                	j	80004e26 <fileclose+0xa8>

0000000080004e46 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80004e46:	715d                	addi	sp,sp,-80
    80004e48:	e486                	sd	ra,72(sp)
    80004e4a:	e0a2                	sd	s0,64(sp)
    80004e4c:	fc26                	sd	s1,56(sp)
    80004e4e:	f84a                	sd	s2,48(sp)
    80004e50:	f44e                	sd	s3,40(sp)
    80004e52:	0880                	addi	s0,sp,80
    80004e54:	84aa                	mv	s1,a0
    80004e56:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e58:	ffffd097          	auipc	ra,0xffffd
    80004e5c:	d22080e7          	jalr	-734(ra) # 80001b7a <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004e60:	409c                	lw	a5,0(s1)
    80004e62:	37f9                	addiw	a5,a5,-2
    80004e64:	4705                	li	a4,1
    80004e66:	04f76763          	bltu	a4,a5,80004eb4 <filestat+0x6e>
    80004e6a:	892a                	mv	s2,a0
  {
    ilock(f->ip);
    80004e6c:	6c88                	ld	a0,24(s1)
    80004e6e:	fffff097          	auipc	ra,0xfffff
    80004e72:	07c080e7          	jalr	124(ra) # 80003eea <ilock>
    stati(f->ip, &st);
    80004e76:	fb840593          	addi	a1,s0,-72
    80004e7a:	6c88                	ld	a0,24(s1)
    80004e7c:	fffff097          	auipc	ra,0xfffff
    80004e80:	2f8080e7          	jalr	760(ra) # 80004174 <stati>
    iunlock(f->ip);
    80004e84:	6c88                	ld	a0,24(s1)
    80004e86:	fffff097          	auipc	ra,0xfffff
    80004e8a:	126080e7          	jalr	294(ra) # 80003fac <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e8e:	46e1                	li	a3,24
    80004e90:	fb840613          	addi	a2,s0,-72
    80004e94:	85ce                	mv	a1,s3
    80004e96:	05093503          	ld	a0,80(s2)
    80004e9a:	ffffd097          	auipc	ra,0xffffd
    80004e9e:	964080e7          	jalr	-1692(ra) # 800017fe <copyout>
    80004ea2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ea6:	60a6                	ld	ra,72(sp)
    80004ea8:	6406                	ld	s0,64(sp)
    80004eaa:	74e2                	ld	s1,56(sp)
    80004eac:	7942                	ld	s2,48(sp)
    80004eae:	79a2                	ld	s3,40(sp)
    80004eb0:	6161                	addi	sp,sp,80
    80004eb2:	8082                	ret
  return -1;
    80004eb4:	557d                	li	a0,-1
    80004eb6:	bfc5                	j	80004ea6 <filestat+0x60>

0000000080004eb8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    80004eb8:	7179                	addi	sp,sp,-48
    80004eba:	f406                	sd	ra,40(sp)
    80004ebc:	f022                	sd	s0,32(sp)
    80004ebe:	ec26                	sd	s1,24(sp)
    80004ec0:	e84a                	sd	s2,16(sp)
    80004ec2:	e44e                	sd	s3,8(sp)
    80004ec4:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    80004ec6:	00854783          	lbu	a5,8(a0)
    80004eca:	c3d5                	beqz	a5,80004f6e <fileread+0xb6>
    80004ecc:	84aa                	mv	s1,a0
    80004ece:	89ae                	mv	s3,a1
    80004ed0:	8932                	mv	s2,a2
    return -1;

  if (f->type == FD_PIPE)
    80004ed2:	411c                	lw	a5,0(a0)
    80004ed4:	4705                	li	a4,1
    80004ed6:	04e78963          	beq	a5,a4,80004f28 <fileread+0x70>
  {
    r = piperead(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004eda:	470d                	li	a4,3
    80004edc:	04e78d63          	beq	a5,a4,80004f36 <fileread+0x7e>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004ee0:	4709                	li	a4,2
    80004ee2:	06e79e63          	bne	a5,a4,80004f5e <fileread+0xa6>
  {
    ilock(f->ip);
    80004ee6:	6d08                	ld	a0,24(a0)
    80004ee8:	fffff097          	auipc	ra,0xfffff
    80004eec:	002080e7          	jalr	2(ra) # 80003eea <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ef0:	874a                	mv	a4,s2
    80004ef2:	5094                	lw	a3,32(s1)
    80004ef4:	864e                	mv	a2,s3
    80004ef6:	4585                	li	a1,1
    80004ef8:	6c88                	ld	a0,24(s1)
    80004efa:	fffff097          	auipc	ra,0xfffff
    80004efe:	2a4080e7          	jalr	676(ra) # 8000419e <readi>
    80004f02:	892a                	mv	s2,a0
    80004f04:	00a05563          	blez	a0,80004f0e <fileread+0x56>
      f->off += r;
    80004f08:	509c                	lw	a5,32(s1)
    80004f0a:	9fa9                	addw	a5,a5,a0
    80004f0c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004f0e:	6c88                	ld	a0,24(s1)
    80004f10:	fffff097          	auipc	ra,0xfffff
    80004f14:	09c080e7          	jalr	156(ra) # 80003fac <iunlock>
  {
    panic("fileread");
  }

  return r;
}
    80004f18:	854a                	mv	a0,s2
    80004f1a:	70a2                	ld	ra,40(sp)
    80004f1c:	7402                	ld	s0,32(sp)
    80004f1e:	64e2                	ld	s1,24(sp)
    80004f20:	6942                	ld	s2,16(sp)
    80004f22:	69a2                	ld	s3,8(sp)
    80004f24:	6145                	addi	sp,sp,48
    80004f26:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004f28:	6908                	ld	a0,16(a0)
    80004f2a:	00000097          	auipc	ra,0x0
    80004f2e:	3c6080e7          	jalr	966(ra) # 800052f0 <piperead>
    80004f32:	892a                	mv	s2,a0
    80004f34:	b7d5                	j	80004f18 <fileread+0x60>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004f36:	02451783          	lh	a5,36(a0)
    80004f3a:	03079693          	slli	a3,a5,0x30
    80004f3e:	92c1                	srli	a3,a3,0x30
    80004f40:	4725                	li	a4,9
    80004f42:	02d76863          	bltu	a4,a3,80004f72 <fileread+0xba>
    80004f46:	0792                	slli	a5,a5,0x4
    80004f48:	0023e717          	auipc	a4,0x23e
    80004f4c:	17070713          	addi	a4,a4,368 # 802430b8 <devsw>
    80004f50:	97ba                	add	a5,a5,a4
    80004f52:	639c                	ld	a5,0(a5)
    80004f54:	c38d                	beqz	a5,80004f76 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004f56:	4505                	li	a0,1
    80004f58:	9782                	jalr	a5
    80004f5a:	892a                	mv	s2,a0
    80004f5c:	bf75                	j	80004f18 <fileread+0x60>
    panic("fileread");
    80004f5e:	00004517          	auipc	a0,0x4
    80004f62:	90250513          	addi	a0,a0,-1790 # 80008860 <syscalls+0x288>
    80004f66:	ffffb097          	auipc	ra,0xffffb
    80004f6a:	5da080e7          	jalr	1498(ra) # 80000540 <panic>
    return -1;
    80004f6e:	597d                	li	s2,-1
    80004f70:	b765                	j	80004f18 <fileread+0x60>
      return -1;
    80004f72:	597d                	li	s2,-1
    80004f74:	b755                	j	80004f18 <fileread+0x60>
    80004f76:	597d                	li	s2,-1
    80004f78:	b745                	j	80004f18 <fileread+0x60>

0000000080004f7a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    80004f7a:	715d                	addi	sp,sp,-80
    80004f7c:	e486                	sd	ra,72(sp)
    80004f7e:	e0a2                	sd	s0,64(sp)
    80004f80:	fc26                	sd	s1,56(sp)
    80004f82:	f84a                	sd	s2,48(sp)
    80004f84:	f44e                	sd	s3,40(sp)
    80004f86:	f052                	sd	s4,32(sp)
    80004f88:	ec56                	sd	s5,24(sp)
    80004f8a:	e85a                	sd	s6,16(sp)
    80004f8c:	e45e                	sd	s7,8(sp)
    80004f8e:	e062                	sd	s8,0(sp)
    80004f90:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if (f->writable == 0)
    80004f92:	00954783          	lbu	a5,9(a0)
    80004f96:	10078663          	beqz	a5,800050a2 <filewrite+0x128>
    80004f9a:	892a                	mv	s2,a0
    80004f9c:	8b2e                	mv	s6,a1
    80004f9e:	8a32                	mv	s4,a2
    return -1;

  if (f->type == FD_PIPE)
    80004fa0:	411c                	lw	a5,0(a0)
    80004fa2:	4705                	li	a4,1
    80004fa4:	02e78263          	beq	a5,a4,80004fc8 <filewrite+0x4e>
  {
    ret = pipewrite(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004fa8:	470d                	li	a4,3
    80004faa:	02e78663          	beq	a5,a4,80004fd6 <filewrite+0x5c>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004fae:	4709                	li	a4,2
    80004fb0:	0ee79163          	bne	a5,a4,80005092 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n)
    80004fb4:	0ac05d63          	blez	a2,8000506e <filewrite+0xf4>
    int i = 0;
    80004fb8:	4981                	li	s3,0
    80004fba:	6b85                	lui	s7,0x1
    80004fbc:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004fc0:	6c05                	lui	s8,0x1
    80004fc2:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004fc6:	a861                	j	8000505e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004fc8:	6908                	ld	a0,16(a0)
    80004fca:	00000097          	auipc	ra,0x0
    80004fce:	22e080e7          	jalr	558(ra) # 800051f8 <pipewrite>
    80004fd2:	8a2a                	mv	s4,a0
    80004fd4:	a045                	j	80005074 <filewrite+0xfa>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004fd6:	02451783          	lh	a5,36(a0)
    80004fda:	03079693          	slli	a3,a5,0x30
    80004fde:	92c1                	srli	a3,a3,0x30
    80004fe0:	4725                	li	a4,9
    80004fe2:	0cd76263          	bltu	a4,a3,800050a6 <filewrite+0x12c>
    80004fe6:	0792                	slli	a5,a5,0x4
    80004fe8:	0023e717          	auipc	a4,0x23e
    80004fec:	0d070713          	addi	a4,a4,208 # 802430b8 <devsw>
    80004ff0:	97ba                	add	a5,a5,a4
    80004ff2:	679c                	ld	a5,8(a5)
    80004ff4:	cbdd                	beqz	a5,800050aa <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ff6:	4505                	li	a0,1
    80004ff8:	9782                	jalr	a5
    80004ffa:	8a2a                	mv	s4,a0
    80004ffc:	a8a5                	j	80005074 <filewrite+0xfa>
    80004ffe:	00048a9b          	sext.w	s5,s1
    {
      int n1 = n - i;
      if (n1 > max)
        n1 = max;

      begin_op();
    80005002:	00000097          	auipc	ra,0x0
    80005006:	8b4080e7          	jalr	-1868(ra) # 800048b6 <begin_op>
      ilock(f->ip);
    8000500a:	01893503          	ld	a0,24(s2)
    8000500e:	fffff097          	auipc	ra,0xfffff
    80005012:	edc080e7          	jalr	-292(ra) # 80003eea <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005016:	8756                	mv	a4,s5
    80005018:	02092683          	lw	a3,32(s2)
    8000501c:	01698633          	add	a2,s3,s6
    80005020:	4585                	li	a1,1
    80005022:	01893503          	ld	a0,24(s2)
    80005026:	fffff097          	auipc	ra,0xfffff
    8000502a:	270080e7          	jalr	624(ra) # 80004296 <writei>
    8000502e:	84aa                	mv	s1,a0
    80005030:	00a05763          	blez	a0,8000503e <filewrite+0xc4>
        f->off += r;
    80005034:	02092783          	lw	a5,32(s2)
    80005038:	9fa9                	addw	a5,a5,a0
    8000503a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000503e:	01893503          	ld	a0,24(s2)
    80005042:	fffff097          	auipc	ra,0xfffff
    80005046:	f6a080e7          	jalr	-150(ra) # 80003fac <iunlock>
      end_op();
    8000504a:	00000097          	auipc	ra,0x0
    8000504e:	8ea080e7          	jalr	-1814(ra) # 80004934 <end_op>

      if (r != n1)
    80005052:	009a9f63          	bne	s5,s1,80005070 <filewrite+0xf6>
      {
        // error from writei
        break;
      }
      i += r;
    80005056:	013489bb          	addw	s3,s1,s3
    while (i < n)
    8000505a:	0149db63          	bge	s3,s4,80005070 <filewrite+0xf6>
      int n1 = n - i;
    8000505e:	413a04bb          	subw	s1,s4,s3
    80005062:	0004879b          	sext.w	a5,s1
    80005066:	f8fbdce3          	bge	s7,a5,80004ffe <filewrite+0x84>
    8000506a:	84e2                	mv	s1,s8
    8000506c:	bf49                	j	80004ffe <filewrite+0x84>
    int i = 0;
    8000506e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005070:	013a1f63          	bne	s4,s3,8000508e <filewrite+0x114>
  {
    panic("filewrite");
  }

  return ret;
}
    80005074:	8552                	mv	a0,s4
    80005076:	60a6                	ld	ra,72(sp)
    80005078:	6406                	ld	s0,64(sp)
    8000507a:	74e2                	ld	s1,56(sp)
    8000507c:	7942                	ld	s2,48(sp)
    8000507e:	79a2                	ld	s3,40(sp)
    80005080:	7a02                	ld	s4,32(sp)
    80005082:	6ae2                	ld	s5,24(sp)
    80005084:	6b42                	ld	s6,16(sp)
    80005086:	6ba2                	ld	s7,8(sp)
    80005088:	6c02                	ld	s8,0(sp)
    8000508a:	6161                	addi	sp,sp,80
    8000508c:	8082                	ret
    ret = (i == n ? n : -1);
    8000508e:	5a7d                	li	s4,-1
    80005090:	b7d5                	j	80005074 <filewrite+0xfa>
    panic("filewrite");
    80005092:	00003517          	auipc	a0,0x3
    80005096:	7de50513          	addi	a0,a0,2014 # 80008870 <syscalls+0x298>
    8000509a:	ffffb097          	auipc	ra,0xffffb
    8000509e:	4a6080e7          	jalr	1190(ra) # 80000540 <panic>
    return -1;
    800050a2:	5a7d                	li	s4,-1
    800050a4:	bfc1                	j	80005074 <filewrite+0xfa>
      return -1;
    800050a6:	5a7d                	li	s4,-1
    800050a8:	b7f1                	j	80005074 <filewrite+0xfa>
    800050aa:	5a7d                	li	s4,-1
    800050ac:	b7e1                	j	80005074 <filewrite+0xfa>

00000000800050ae <pipealloc>:
  int readopen;  // read fd is still open
  int writeopen; // write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
    800050ae:	7179                	addi	sp,sp,-48
    800050b0:	f406                	sd	ra,40(sp)
    800050b2:	f022                	sd	s0,32(sp)
    800050b4:	ec26                	sd	s1,24(sp)
    800050b6:	e84a                	sd	s2,16(sp)
    800050b8:	e44e                	sd	s3,8(sp)
    800050ba:	e052                	sd	s4,0(sp)
    800050bc:	1800                	addi	s0,sp,48
    800050be:	84aa                	mv	s1,a0
    800050c0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800050c2:	0005b023          	sd	zero,0(a1)
    800050c6:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800050ca:	00000097          	auipc	ra,0x0
    800050ce:	bf8080e7          	jalr	-1032(ra) # 80004cc2 <filealloc>
    800050d2:	e088                	sd	a0,0(s1)
    800050d4:	c551                	beqz	a0,80005160 <pipealloc+0xb2>
    800050d6:	00000097          	auipc	ra,0x0
    800050da:	bec080e7          	jalr	-1044(ra) # 80004cc2 <filealloc>
    800050de:	00aa3023          	sd	a0,0(s4)
    800050e2:	c92d                	beqz	a0,80005154 <pipealloc+0xa6>
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800050e4:	ffffc097          	auipc	ra,0xffffc
    800050e8:	b6c080e7          	jalr	-1172(ra) # 80000c50 <kalloc>
    800050ec:	892a                	mv	s2,a0
    800050ee:	c125                	beqz	a0,8000514e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800050f0:	4985                	li	s3,1
    800050f2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800050f6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800050fa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800050fe:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005102:	00003597          	auipc	a1,0x3
    80005106:	3e658593          	addi	a1,a1,998 # 800084e8 <states.0+0x1c0>
    8000510a:	ffffc097          	auipc	ra,0xffffc
    8000510e:	bb0080e7          	jalr	-1104(ra) # 80000cba <initlock>
  (*f0)->type = FD_PIPE;
    80005112:	609c                	ld	a5,0(s1)
    80005114:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005118:	609c                	ld	a5,0(s1)
    8000511a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000511e:	609c                	ld	a5,0(s1)
    80005120:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005124:	609c                	ld	a5,0(s1)
    80005126:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000512a:	000a3783          	ld	a5,0(s4)
    8000512e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005132:	000a3783          	ld	a5,0(s4)
    80005136:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000513a:	000a3783          	ld	a5,0(s4)
    8000513e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005142:	000a3783          	ld	a5,0(s4)
    80005146:	0127b823          	sd	s2,16(a5)
  return 0;
    8000514a:	4501                	li	a0,0
    8000514c:	a025                	j	80005174 <pipealloc+0xc6>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    8000514e:	6088                	ld	a0,0(s1)
    80005150:	e501                	bnez	a0,80005158 <pipealloc+0xaa>
    80005152:	a039                	j	80005160 <pipealloc+0xb2>
    80005154:	6088                	ld	a0,0(s1)
    80005156:	c51d                	beqz	a0,80005184 <pipealloc+0xd6>
    fileclose(*f0);
    80005158:	00000097          	auipc	ra,0x0
    8000515c:	c26080e7          	jalr	-986(ra) # 80004d7e <fileclose>
  if (*f1)
    80005160:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005164:	557d                	li	a0,-1
  if (*f1)
    80005166:	c799                	beqz	a5,80005174 <pipealloc+0xc6>
    fileclose(*f1);
    80005168:	853e                	mv	a0,a5
    8000516a:	00000097          	auipc	ra,0x0
    8000516e:	c14080e7          	jalr	-1004(ra) # 80004d7e <fileclose>
  return -1;
    80005172:	557d                	li	a0,-1
}
    80005174:	70a2                	ld	ra,40(sp)
    80005176:	7402                	ld	s0,32(sp)
    80005178:	64e2                	ld	s1,24(sp)
    8000517a:	6942                	ld	s2,16(sp)
    8000517c:	69a2                	ld	s3,8(sp)
    8000517e:	6a02                	ld	s4,0(sp)
    80005180:	6145                	addi	sp,sp,48
    80005182:	8082                	ret
  return -1;
    80005184:	557d                	li	a0,-1
    80005186:	b7fd                	j	80005174 <pipealloc+0xc6>

0000000080005188 <pipeclose>:

void pipeclose(struct pipe *pi, int writable)
{
    80005188:	1101                	addi	sp,sp,-32
    8000518a:	ec06                	sd	ra,24(sp)
    8000518c:	e822                	sd	s0,16(sp)
    8000518e:	e426                	sd	s1,8(sp)
    80005190:	e04a                	sd	s2,0(sp)
    80005192:	1000                	addi	s0,sp,32
    80005194:	84aa                	mv	s1,a0
    80005196:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005198:	ffffc097          	auipc	ra,0xffffc
    8000519c:	bb2080e7          	jalr	-1102(ra) # 80000d4a <acquire>
  if (writable)
    800051a0:	02090d63          	beqz	s2,800051da <pipeclose+0x52>
  {
    pi->writeopen = 0;
    800051a4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800051a8:	21848513          	addi	a0,s1,536
    800051ac:	ffffd097          	auipc	ra,0xffffd
    800051b0:	33c080e7          	jalr	828(ra) # 800024e8 <wakeup>
  else
  {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0)
    800051b4:	2204b783          	ld	a5,544(s1)
    800051b8:	eb95                	bnez	a5,800051ec <pipeclose+0x64>
  {
    release(&pi->lock);
    800051ba:	8526                	mv	a0,s1
    800051bc:	ffffc097          	auipc	ra,0xffffc
    800051c0:	c42080e7          	jalr	-958(ra) # 80000dfe <release>
    kfree((char *)pi);
    800051c4:	8526                	mv	a0,s1
    800051c6:	ffffc097          	auipc	ra,0xffffc
    800051ca:	8b2080e7          	jalr	-1870(ra) # 80000a78 <kfree>
  }
  else
    release(&pi->lock);
}
    800051ce:	60e2                	ld	ra,24(sp)
    800051d0:	6442                	ld	s0,16(sp)
    800051d2:	64a2                	ld	s1,8(sp)
    800051d4:	6902                	ld	s2,0(sp)
    800051d6:	6105                	addi	sp,sp,32
    800051d8:	8082                	ret
    pi->readopen = 0;
    800051da:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800051de:	21c48513          	addi	a0,s1,540
    800051e2:	ffffd097          	auipc	ra,0xffffd
    800051e6:	306080e7          	jalr	774(ra) # 800024e8 <wakeup>
    800051ea:	b7e9                	j	800051b4 <pipeclose+0x2c>
    release(&pi->lock);
    800051ec:	8526                	mv	a0,s1
    800051ee:	ffffc097          	auipc	ra,0xffffc
    800051f2:	c10080e7          	jalr	-1008(ra) # 80000dfe <release>
}
    800051f6:	bfe1                	j	800051ce <pipeclose+0x46>

00000000800051f8 <pipewrite>:

int pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800051f8:	711d                	addi	sp,sp,-96
    800051fa:	ec86                	sd	ra,88(sp)
    800051fc:	e8a2                	sd	s0,80(sp)
    800051fe:	e4a6                	sd	s1,72(sp)
    80005200:	e0ca                	sd	s2,64(sp)
    80005202:	fc4e                	sd	s3,56(sp)
    80005204:	f852                	sd	s4,48(sp)
    80005206:	f456                	sd	s5,40(sp)
    80005208:	f05a                	sd	s6,32(sp)
    8000520a:	ec5e                	sd	s7,24(sp)
    8000520c:	e862                	sd	s8,16(sp)
    8000520e:	1080                	addi	s0,sp,96
    80005210:	84aa                	mv	s1,a0
    80005212:	8aae                	mv	s5,a1
    80005214:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005216:	ffffd097          	auipc	ra,0xffffd
    8000521a:	964080e7          	jalr	-1692(ra) # 80001b7a <myproc>
    8000521e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005220:	8526                	mv	a0,s1
    80005222:	ffffc097          	auipc	ra,0xffffc
    80005226:	b28080e7          	jalr	-1240(ra) # 80000d4a <acquire>
  while (i < n)
    8000522a:	0b405663          	blez	s4,800052d6 <pipewrite+0xde>
  int i = 0;
    8000522e:	4901                	li	s2,0
      sleep(&pi->nwrite, &pi->lock);
    }
    else
    {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005230:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005232:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005236:	21c48b93          	addi	s7,s1,540
    8000523a:	a089                	j	8000527c <pipewrite+0x84>
      release(&pi->lock);
    8000523c:	8526                	mv	a0,s1
    8000523e:	ffffc097          	auipc	ra,0xffffc
    80005242:	bc0080e7          	jalr	-1088(ra) # 80000dfe <release>
      return -1;
    80005246:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005248:	854a                	mv	a0,s2
    8000524a:	60e6                	ld	ra,88(sp)
    8000524c:	6446                	ld	s0,80(sp)
    8000524e:	64a6                	ld	s1,72(sp)
    80005250:	6906                	ld	s2,64(sp)
    80005252:	79e2                	ld	s3,56(sp)
    80005254:	7a42                	ld	s4,48(sp)
    80005256:	7aa2                	ld	s5,40(sp)
    80005258:	7b02                	ld	s6,32(sp)
    8000525a:	6be2                	ld	s7,24(sp)
    8000525c:	6c42                	ld	s8,16(sp)
    8000525e:	6125                	addi	sp,sp,96
    80005260:	8082                	ret
      wakeup(&pi->nread);
    80005262:	8562                	mv	a0,s8
    80005264:	ffffd097          	auipc	ra,0xffffd
    80005268:	284080e7          	jalr	644(ra) # 800024e8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000526c:	85a6                	mv	a1,s1
    8000526e:	855e                	mv	a0,s7
    80005270:	ffffd097          	auipc	ra,0xffffd
    80005274:	0bc080e7          	jalr	188(ra) # 8000232c <sleep>
  while (i < n)
    80005278:	07495063          	bge	s2,s4,800052d8 <pipewrite+0xe0>
    if (pi->readopen == 0 || killed(pr))
    8000527c:	2204a783          	lw	a5,544(s1)
    80005280:	dfd5                	beqz	a5,8000523c <pipewrite+0x44>
    80005282:	854e                	mv	a0,s3
    80005284:	ffffd097          	auipc	ra,0xffffd
    80005288:	4d4080e7          	jalr	1236(ra) # 80002758 <killed>
    8000528c:	f945                	bnez	a0,8000523c <pipewrite+0x44>
    if (pi->nwrite == pi->nread + PIPESIZE)
    8000528e:	2184a783          	lw	a5,536(s1)
    80005292:	21c4a703          	lw	a4,540(s1)
    80005296:	2007879b          	addiw	a5,a5,512
    8000529a:	fcf704e3          	beq	a4,a5,80005262 <pipewrite+0x6a>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000529e:	4685                	li	a3,1
    800052a0:	01590633          	add	a2,s2,s5
    800052a4:	faf40593          	addi	a1,s0,-81
    800052a8:	0509b503          	ld	a0,80(s3)
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	61a080e7          	jalr	1562(ra) # 800018c6 <copyin>
    800052b4:	03650263          	beq	a0,s6,800052d8 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800052b8:	21c4a783          	lw	a5,540(s1)
    800052bc:	0017871b          	addiw	a4,a5,1
    800052c0:	20e4ae23          	sw	a4,540(s1)
    800052c4:	1ff7f793          	andi	a5,a5,511
    800052c8:	97a6                	add	a5,a5,s1
    800052ca:	faf44703          	lbu	a4,-81(s0)
    800052ce:	00e78c23          	sb	a4,24(a5)
      i++;
    800052d2:	2905                	addiw	s2,s2,1
    800052d4:	b755                	j	80005278 <pipewrite+0x80>
  int i = 0;
    800052d6:	4901                	li	s2,0
  wakeup(&pi->nread);
    800052d8:	21848513          	addi	a0,s1,536
    800052dc:	ffffd097          	auipc	ra,0xffffd
    800052e0:	20c080e7          	jalr	524(ra) # 800024e8 <wakeup>
  release(&pi->lock);
    800052e4:	8526                	mv	a0,s1
    800052e6:	ffffc097          	auipc	ra,0xffffc
    800052ea:	b18080e7          	jalr	-1256(ra) # 80000dfe <release>
  return i;
    800052ee:	bfa9                	j	80005248 <pipewrite+0x50>

00000000800052f0 <piperead>:

int piperead(struct pipe *pi, uint64 addr, int n)
{
    800052f0:	715d                	addi	sp,sp,-80
    800052f2:	e486                	sd	ra,72(sp)
    800052f4:	e0a2                	sd	s0,64(sp)
    800052f6:	fc26                	sd	s1,56(sp)
    800052f8:	f84a                	sd	s2,48(sp)
    800052fa:	f44e                	sd	s3,40(sp)
    800052fc:	f052                	sd	s4,32(sp)
    800052fe:	ec56                	sd	s5,24(sp)
    80005300:	e85a                	sd	s6,16(sp)
    80005302:	0880                	addi	s0,sp,80
    80005304:	84aa                	mv	s1,a0
    80005306:	892e                	mv	s2,a1
    80005308:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000530a:	ffffd097          	auipc	ra,0xffffd
    8000530e:	870080e7          	jalr	-1936(ra) # 80001b7a <myproc>
    80005312:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005314:	8526                	mv	a0,s1
    80005316:	ffffc097          	auipc	ra,0xffffc
    8000531a:	a34080e7          	jalr	-1484(ra) # 80000d4a <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen)
    8000531e:	2184a703          	lw	a4,536(s1)
    80005322:	21c4a783          	lw	a5,540(s1)
    if (killed(pr))
    {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80005326:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen)
    8000532a:	02f71763          	bne	a4,a5,80005358 <piperead+0x68>
    8000532e:	2244a783          	lw	a5,548(s1)
    80005332:	c39d                	beqz	a5,80005358 <piperead+0x68>
    if (killed(pr))
    80005334:	8552                	mv	a0,s4
    80005336:	ffffd097          	auipc	ra,0xffffd
    8000533a:	422080e7          	jalr	1058(ra) # 80002758 <killed>
    8000533e:	e949                	bnez	a0,800053d0 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80005340:	85a6                	mv	a1,s1
    80005342:	854e                	mv	a0,s3
    80005344:	ffffd097          	auipc	ra,0xffffd
    80005348:	fe8080e7          	jalr	-24(ra) # 8000232c <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen)
    8000534c:	2184a703          	lw	a4,536(s1)
    80005350:	21c4a783          	lw	a5,540(s1)
    80005354:	fcf70de3          	beq	a4,a5,8000532e <piperead+0x3e>
  }
  for (i = 0; i < n; i++)
    80005358:	4981                	li	s3,0
  { // DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000535a:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++)
    8000535c:	05505463          	blez	s5,800053a4 <piperead+0xb4>
    if (pi->nread == pi->nwrite)
    80005360:	2184a783          	lw	a5,536(s1)
    80005364:	21c4a703          	lw	a4,540(s1)
    80005368:	02f70e63          	beq	a4,a5,800053a4 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000536c:	0017871b          	addiw	a4,a5,1
    80005370:	20e4ac23          	sw	a4,536(s1)
    80005374:	1ff7f793          	andi	a5,a5,511
    80005378:	97a6                	add	a5,a5,s1
    8000537a:	0187c783          	lbu	a5,24(a5)
    8000537e:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005382:	4685                	li	a3,1
    80005384:	fbf40613          	addi	a2,s0,-65
    80005388:	85ca                	mv	a1,s2
    8000538a:	050a3503          	ld	a0,80(s4)
    8000538e:	ffffc097          	auipc	ra,0xffffc
    80005392:	470080e7          	jalr	1136(ra) # 800017fe <copyout>
    80005396:	01650763          	beq	a0,s6,800053a4 <piperead+0xb4>
  for (i = 0; i < n; i++)
    8000539a:	2985                	addiw	s3,s3,1
    8000539c:	0905                	addi	s2,s2,1
    8000539e:	fd3a91e3          	bne	s5,s3,80005360 <piperead+0x70>
    800053a2:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite); // DOC: piperead-wakeup
    800053a4:	21c48513          	addi	a0,s1,540
    800053a8:	ffffd097          	auipc	ra,0xffffd
    800053ac:	140080e7          	jalr	320(ra) # 800024e8 <wakeup>
  release(&pi->lock);
    800053b0:	8526                	mv	a0,s1
    800053b2:	ffffc097          	auipc	ra,0xffffc
    800053b6:	a4c080e7          	jalr	-1460(ra) # 80000dfe <release>
  return i;
}
    800053ba:	854e                	mv	a0,s3
    800053bc:	60a6                	ld	ra,72(sp)
    800053be:	6406                	ld	s0,64(sp)
    800053c0:	74e2                	ld	s1,56(sp)
    800053c2:	7942                	ld	s2,48(sp)
    800053c4:	79a2                	ld	s3,40(sp)
    800053c6:	7a02                	ld	s4,32(sp)
    800053c8:	6ae2                	ld	s5,24(sp)
    800053ca:	6b42                	ld	s6,16(sp)
    800053cc:	6161                	addi	sp,sp,80
    800053ce:	8082                	ret
      release(&pi->lock);
    800053d0:	8526                	mv	a0,s1
    800053d2:	ffffc097          	auipc	ra,0xffffc
    800053d6:	a2c080e7          	jalr	-1492(ra) # 80000dfe <release>
      return -1;
    800053da:	59fd                	li	s3,-1
    800053dc:	bff9                	j	800053ba <piperead+0xca>

00000000800053de <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800053de:	1141                	addi	sp,sp,-16
    800053e0:	e422                	sd	s0,8(sp)
    800053e2:	0800                	addi	s0,sp,16
    800053e4:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800053e6:	8905                	andi	a0,a0,1
    800053e8:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    800053ea:	8b89                	andi	a5,a5,2
    800053ec:	c399                	beqz	a5,800053f2 <flags2perm+0x14>
    perm |= PTE_W;
    800053ee:	00456513          	ori	a0,a0,4
  return perm;
}
    800053f2:	6422                	ld	s0,8(sp)
    800053f4:	0141                	addi	sp,sp,16
    800053f6:	8082                	ret

00000000800053f8 <exec>:

int exec(char *path, char **argv)
{
    800053f8:	de010113          	addi	sp,sp,-544
    800053fc:	20113c23          	sd	ra,536(sp)
    80005400:	20813823          	sd	s0,528(sp)
    80005404:	20913423          	sd	s1,520(sp)
    80005408:	21213023          	sd	s2,512(sp)
    8000540c:	ffce                	sd	s3,504(sp)
    8000540e:	fbd2                	sd	s4,496(sp)
    80005410:	f7d6                	sd	s5,488(sp)
    80005412:	f3da                	sd	s6,480(sp)
    80005414:	efde                	sd	s7,472(sp)
    80005416:	ebe2                	sd	s8,464(sp)
    80005418:	e7e6                	sd	s9,456(sp)
    8000541a:	e3ea                	sd	s10,448(sp)
    8000541c:	ff6e                	sd	s11,440(sp)
    8000541e:	1400                	addi	s0,sp,544
    80005420:	892a                	mv	s2,a0
    80005422:	dea43423          	sd	a0,-536(s0)
    80005426:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000542a:	ffffc097          	auipc	ra,0xffffc
    8000542e:	750080e7          	jalr	1872(ra) # 80001b7a <myproc>
    80005432:	84aa                	mv	s1,a0

  begin_op();
    80005434:	fffff097          	auipc	ra,0xfffff
    80005438:	482080e7          	jalr	1154(ra) # 800048b6 <begin_op>

  if ((ip = namei(path)) == 0)
    8000543c:	854a                	mv	a0,s2
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	258080e7          	jalr	600(ra) # 80004696 <namei>
    80005446:	c93d                	beqz	a0,800054bc <exec+0xc4>
    80005448:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	aa0080e7          	jalr	-1376(ra) # 80003eea <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005452:	04000713          	li	a4,64
    80005456:	4681                	li	a3,0
    80005458:	e5040613          	addi	a2,s0,-432
    8000545c:	4581                	li	a1,0
    8000545e:	8556                	mv	a0,s5
    80005460:	fffff097          	auipc	ra,0xfffff
    80005464:	d3e080e7          	jalr	-706(ra) # 8000419e <readi>
    80005468:	04000793          	li	a5,64
    8000546c:	00f51a63          	bne	a0,a5,80005480 <exec+0x88>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    80005470:	e5042703          	lw	a4,-432(s0)
    80005474:	464c47b7          	lui	a5,0x464c4
    80005478:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000547c:	04f70663          	beq	a4,a5,800054c8 <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80005480:	8556                	mv	a0,s5
    80005482:	fffff097          	auipc	ra,0xfffff
    80005486:	cca080e7          	jalr	-822(ra) # 8000414c <iunlockput>
    end_op();
    8000548a:	fffff097          	auipc	ra,0xfffff
    8000548e:	4aa080e7          	jalr	1194(ra) # 80004934 <end_op>
  }
  return -1;
    80005492:	557d                	li	a0,-1
}
    80005494:	21813083          	ld	ra,536(sp)
    80005498:	21013403          	ld	s0,528(sp)
    8000549c:	20813483          	ld	s1,520(sp)
    800054a0:	20013903          	ld	s2,512(sp)
    800054a4:	79fe                	ld	s3,504(sp)
    800054a6:	7a5e                	ld	s4,496(sp)
    800054a8:	7abe                	ld	s5,488(sp)
    800054aa:	7b1e                	ld	s6,480(sp)
    800054ac:	6bfe                	ld	s7,472(sp)
    800054ae:	6c5e                	ld	s8,464(sp)
    800054b0:	6cbe                	ld	s9,456(sp)
    800054b2:	6d1e                	ld	s10,448(sp)
    800054b4:	7dfa                	ld	s11,440(sp)
    800054b6:	22010113          	addi	sp,sp,544
    800054ba:	8082                	ret
    end_op();
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	478080e7          	jalr	1144(ra) # 80004934 <end_op>
    return -1;
    800054c4:	557d                	li	a0,-1
    800054c6:	b7f9                	j	80005494 <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    800054c8:	8526                	mv	a0,s1
    800054ca:	ffffc097          	auipc	ra,0xffffc
    800054ce:	774080e7          	jalr	1908(ra) # 80001c3e <proc_pagetable>
    800054d2:	8b2a                	mv	s6,a0
    800054d4:	d555                	beqz	a0,80005480 <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800054d6:	e7042783          	lw	a5,-400(s0)
    800054da:	e8845703          	lhu	a4,-376(s0)
    800054de:	c735                	beqz	a4,8000554a <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800054e0:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800054e2:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    800054e6:	6a05                	lui	s4,0x1
    800054e8:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800054ec:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for (i = 0; i < sz; i += PGSIZE)
    800054f0:	6d85                	lui	s11,0x1
    800054f2:	7d7d                	lui	s10,0xfffff
    800054f4:	ac3d                	j	80005732 <exec+0x33a>
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    800054f6:	00003517          	auipc	a0,0x3
    800054fa:	38a50513          	addi	a0,a0,906 # 80008880 <syscalls+0x2a8>
    800054fe:	ffffb097          	auipc	ra,0xffffb
    80005502:	042080e7          	jalr	66(ra) # 80000540 <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80005506:	874a                	mv	a4,s2
    80005508:	009c86bb          	addw	a3,s9,s1
    8000550c:	4581                	li	a1,0
    8000550e:	8556                	mv	a0,s5
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	c8e080e7          	jalr	-882(ra) # 8000419e <readi>
    80005518:	2501                	sext.w	a0,a0
    8000551a:	1aa91963          	bne	s2,a0,800056cc <exec+0x2d4>
  for (i = 0; i < sz; i += PGSIZE)
    8000551e:	009d84bb          	addw	s1,s11,s1
    80005522:	013d09bb          	addw	s3,s10,s3
    80005526:	1f74f663          	bgeu	s1,s7,80005712 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    8000552a:	02049593          	slli	a1,s1,0x20
    8000552e:	9181                	srli	a1,a1,0x20
    80005530:	95e2                	add	a1,a1,s8
    80005532:	855a                	mv	a0,s6
    80005534:	ffffc097          	auipc	ra,0xffffc
    80005538:	c9c080e7          	jalr	-868(ra) # 800011d0 <walkaddr>
    8000553c:	862a                	mv	a2,a0
    if (pa == 0)
    8000553e:	dd45                	beqz	a0,800054f6 <exec+0xfe>
      n = PGSIZE;
    80005540:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005542:	fd49f2e3          	bgeu	s3,s4,80005506 <exec+0x10e>
      n = sz - i;
    80005546:	894e                	mv	s2,s3
    80005548:	bf7d                	j	80005506 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000554a:	4901                	li	s2,0
  iunlockput(ip);
    8000554c:	8556                	mv	a0,s5
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	bfe080e7          	jalr	-1026(ra) # 8000414c <iunlockput>
  end_op();
    80005556:	fffff097          	auipc	ra,0xfffff
    8000555a:	3de080e7          	jalr	990(ra) # 80004934 <end_op>
  p = myproc();
    8000555e:	ffffc097          	auipc	ra,0xffffc
    80005562:	61c080e7          	jalr	1564(ra) # 80001b7a <myproc>
    80005566:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005568:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000556c:	6785                	lui	a5,0x1
    8000556e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005570:	97ca                	add	a5,a5,s2
    80005572:	777d                	lui	a4,0xfffff
    80005574:	8ff9                	and	a5,a5,a4
    80005576:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    8000557a:	4691                	li	a3,4
    8000557c:	6609                	lui	a2,0x2
    8000557e:	963e                	add	a2,a2,a5
    80005580:	85be                	mv	a1,a5
    80005582:	855a                	mv	a0,s6
    80005584:	ffffc097          	auipc	ra,0xffffc
    80005588:	000080e7          	jalr	ra # 80001584 <uvmalloc>
    8000558c:	8c2a                	mv	s8,a0
  ip = 0;
    8000558e:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    80005590:	12050e63          	beqz	a0,800056cc <exec+0x2d4>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005594:	75f9                	lui	a1,0xffffe
    80005596:	95aa                	add	a1,a1,a0
    80005598:	855a                	mv	a0,s6
    8000559a:	ffffc097          	auipc	ra,0xffffc
    8000559e:	232080e7          	jalr	562(ra) # 800017cc <uvmclear>
  stackbase = sp - PGSIZE;
    800055a2:	7afd                	lui	s5,0xfffff
    800055a4:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    800055a6:	df043783          	ld	a5,-528(s0)
    800055aa:	6388                	ld	a0,0(a5)
    800055ac:	c925                	beqz	a0,8000561c <exec+0x224>
    800055ae:	e9040993          	addi	s3,s0,-368
    800055b2:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800055b6:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    800055b8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800055ba:	ffffc097          	auipc	ra,0xffffc
    800055be:	a08080e7          	jalr	-1528(ra) # 80000fc2 <strlen>
    800055c2:	0015079b          	addiw	a5,a0,1
    800055c6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800055ca:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    800055ce:	13596663          	bltu	s2,s5,800056fa <exec+0x302>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800055d2:	df043d83          	ld	s11,-528(s0)
    800055d6:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800055da:	8552                	mv	a0,s4
    800055dc:	ffffc097          	auipc	ra,0xffffc
    800055e0:	9e6080e7          	jalr	-1562(ra) # 80000fc2 <strlen>
    800055e4:	0015069b          	addiw	a3,a0,1
    800055e8:	8652                	mv	a2,s4
    800055ea:	85ca                	mv	a1,s2
    800055ec:	855a                	mv	a0,s6
    800055ee:	ffffc097          	auipc	ra,0xffffc
    800055f2:	210080e7          	jalr	528(ra) # 800017fe <copyout>
    800055f6:	10054663          	bltz	a0,80005702 <exec+0x30a>
    ustack[argc] = sp;
    800055fa:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    800055fe:	0485                	addi	s1,s1,1
    80005600:	008d8793          	addi	a5,s11,8
    80005604:	def43823          	sd	a5,-528(s0)
    80005608:	008db503          	ld	a0,8(s11)
    8000560c:	c911                	beqz	a0,80005620 <exec+0x228>
    if (argc >= MAXARG)
    8000560e:	09a1                	addi	s3,s3,8
    80005610:	fb3c95e3          	bne	s9,s3,800055ba <exec+0x1c2>
  sz = sz1;
    80005614:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005618:	4a81                	li	s5,0
    8000561a:	a84d                	j	800056cc <exec+0x2d4>
  sp = sz;
    8000561c:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    8000561e:	4481                	li	s1,0
  ustack[argc] = 0;
    80005620:	00349793          	slli	a5,s1,0x3
    80005624:	f9078793          	addi	a5,a5,-112
    80005628:	97a2                	add	a5,a5,s0
    8000562a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    8000562e:	00148693          	addi	a3,s1,1
    80005632:	068e                	slli	a3,a3,0x3
    80005634:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005638:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    8000563c:	01597663          	bgeu	s2,s5,80005648 <exec+0x250>
  sz = sz1;
    80005640:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005644:	4a81                	li	s5,0
    80005646:	a059                	j	800056cc <exec+0x2d4>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    80005648:	e9040613          	addi	a2,s0,-368
    8000564c:	85ca                	mv	a1,s2
    8000564e:	855a                	mv	a0,s6
    80005650:	ffffc097          	auipc	ra,0xffffc
    80005654:	1ae080e7          	jalr	430(ra) # 800017fe <copyout>
    80005658:	0a054963          	bltz	a0,8000570a <exec+0x312>
  p->trapframe->a1 = sp;
    8000565c:	058bb783          	ld	a5,88(s7)
    80005660:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005664:	de843783          	ld	a5,-536(s0)
    80005668:	0007c703          	lbu	a4,0(a5)
    8000566c:	cf11                	beqz	a4,80005688 <exec+0x290>
    8000566e:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005670:	02f00693          	li	a3,47
    80005674:	a039                	j	80005682 <exec+0x28a>
      last = s + 1;
    80005676:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    8000567a:	0785                	addi	a5,a5,1
    8000567c:	fff7c703          	lbu	a4,-1(a5)
    80005680:	c701                	beqz	a4,80005688 <exec+0x290>
    if (*s == '/')
    80005682:	fed71ce3          	bne	a4,a3,8000567a <exec+0x282>
    80005686:	bfc5                	j	80005676 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005688:	4641                	li	a2,16
    8000568a:	de843583          	ld	a1,-536(s0)
    8000568e:	158b8513          	addi	a0,s7,344
    80005692:	ffffc097          	auipc	ra,0xffffc
    80005696:	8fe080e7          	jalr	-1794(ra) # 80000f90 <safestrcpy>
  oldpagetable = p->pagetable;
    8000569a:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000569e:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800056a2:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    800056a6:	058bb783          	ld	a5,88(s7)
    800056aa:	e6843703          	ld	a4,-408(s0)
    800056ae:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    800056b0:	058bb783          	ld	a5,88(s7)
    800056b4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800056b8:	85ea                	mv	a1,s10
    800056ba:	ffffc097          	auipc	ra,0xffffc
    800056be:	620080e7          	jalr	1568(ra) # 80001cda <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800056c2:	0004851b          	sext.w	a0,s1
    800056c6:	b3f9                	j	80005494 <exec+0x9c>
    800056c8:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800056cc:	df843583          	ld	a1,-520(s0)
    800056d0:	855a                	mv	a0,s6
    800056d2:	ffffc097          	auipc	ra,0xffffc
    800056d6:	608080e7          	jalr	1544(ra) # 80001cda <proc_freepagetable>
  if (ip)
    800056da:	da0a93e3          	bnez	s5,80005480 <exec+0x88>
  return -1;
    800056de:	557d                	li	a0,-1
    800056e0:	bb55                	j	80005494 <exec+0x9c>
    800056e2:	df243c23          	sd	s2,-520(s0)
    800056e6:	b7dd                	j	800056cc <exec+0x2d4>
    800056e8:	df243c23          	sd	s2,-520(s0)
    800056ec:	b7c5                	j	800056cc <exec+0x2d4>
    800056ee:	df243c23          	sd	s2,-520(s0)
    800056f2:	bfe9                	j	800056cc <exec+0x2d4>
    800056f4:	df243c23          	sd	s2,-520(s0)
    800056f8:	bfd1                	j	800056cc <exec+0x2d4>
  sz = sz1;
    800056fa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056fe:	4a81                	li	s5,0
    80005700:	b7f1                	j	800056cc <exec+0x2d4>
  sz = sz1;
    80005702:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005706:	4a81                	li	s5,0
    80005708:	b7d1                	j	800056cc <exec+0x2d4>
  sz = sz1;
    8000570a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000570e:	4a81                	li	s5,0
    80005710:	bf75                	j	800056cc <exec+0x2d4>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005712:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005716:	e0843783          	ld	a5,-504(s0)
    8000571a:	0017869b          	addiw	a3,a5,1
    8000571e:	e0d43423          	sd	a3,-504(s0)
    80005722:	e0043783          	ld	a5,-512(s0)
    80005726:	0387879b          	addiw	a5,a5,56
    8000572a:	e8845703          	lhu	a4,-376(s0)
    8000572e:	e0e6dfe3          	bge	a3,a4,8000554c <exec+0x154>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005732:	2781                	sext.w	a5,a5
    80005734:	e0f43023          	sd	a5,-512(s0)
    80005738:	03800713          	li	a4,56
    8000573c:	86be                	mv	a3,a5
    8000573e:	e1840613          	addi	a2,s0,-488
    80005742:	4581                	li	a1,0
    80005744:	8556                	mv	a0,s5
    80005746:	fffff097          	auipc	ra,0xfffff
    8000574a:	a58080e7          	jalr	-1448(ra) # 8000419e <readi>
    8000574e:	03800793          	li	a5,56
    80005752:	f6f51be3          	bne	a0,a5,800056c8 <exec+0x2d0>
    if (ph.type != ELF_PROG_LOAD)
    80005756:	e1842783          	lw	a5,-488(s0)
    8000575a:	4705                	li	a4,1
    8000575c:	fae79de3          	bne	a5,a4,80005716 <exec+0x31e>
    if (ph.memsz < ph.filesz)
    80005760:	e4043483          	ld	s1,-448(s0)
    80005764:	e3843783          	ld	a5,-456(s0)
    80005768:	f6f4ede3          	bltu	s1,a5,800056e2 <exec+0x2ea>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    8000576c:	e2843783          	ld	a5,-472(s0)
    80005770:	94be                	add	s1,s1,a5
    80005772:	f6f4ebe3          	bltu	s1,a5,800056e8 <exec+0x2f0>
    if (ph.vaddr % PGSIZE != 0)
    80005776:	de043703          	ld	a4,-544(s0)
    8000577a:	8ff9                	and	a5,a5,a4
    8000577c:	fbad                	bnez	a5,800056ee <exec+0x2f6>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000577e:	e1c42503          	lw	a0,-484(s0)
    80005782:	00000097          	auipc	ra,0x0
    80005786:	c5c080e7          	jalr	-932(ra) # 800053de <flags2perm>
    8000578a:	86aa                	mv	a3,a0
    8000578c:	8626                	mv	a2,s1
    8000578e:	85ca                	mv	a1,s2
    80005790:	855a                	mv	a0,s6
    80005792:	ffffc097          	auipc	ra,0xffffc
    80005796:	df2080e7          	jalr	-526(ra) # 80001584 <uvmalloc>
    8000579a:	dea43c23          	sd	a0,-520(s0)
    8000579e:	d939                	beqz	a0,800056f4 <exec+0x2fc>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800057a0:	e2843c03          	ld	s8,-472(s0)
    800057a4:	e2042c83          	lw	s9,-480(s0)
    800057a8:	e3842b83          	lw	s7,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    800057ac:	f60b83e3          	beqz	s7,80005712 <exec+0x31a>
    800057b0:	89de                	mv	s3,s7
    800057b2:	4481                	li	s1,0
    800057b4:	bb9d                	j	8000552a <exec+0x132>

00000000800057b6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800057b6:	7179                	addi	sp,sp,-48
    800057b8:	f406                	sd	ra,40(sp)
    800057ba:	f022                	sd	s0,32(sp)
    800057bc:	ec26                	sd	s1,24(sp)
    800057be:	e84a                	sd	s2,16(sp)
    800057c0:	1800                	addi	s0,sp,48
    800057c2:	892e                	mv	s2,a1
    800057c4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800057c6:	fdc40593          	addi	a1,s0,-36
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	94e080e7          	jalr	-1714(ra) # 80003118 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    800057d2:	fdc42703          	lw	a4,-36(s0)
    800057d6:	47bd                	li	a5,15
    800057d8:	02e7eb63          	bltu	a5,a4,8000580e <argfd+0x58>
    800057dc:	ffffc097          	auipc	ra,0xffffc
    800057e0:	39e080e7          	jalr	926(ra) # 80001b7a <myproc>
    800057e4:	fdc42703          	lw	a4,-36(s0)
    800057e8:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7fdb9a4a>
    800057ec:	078e                	slli	a5,a5,0x3
    800057ee:	953e                	add	a0,a0,a5
    800057f0:	611c                	ld	a5,0(a0)
    800057f2:	c385                	beqz	a5,80005812 <argfd+0x5c>
    return -1;
  if (pfd)
    800057f4:	00090463          	beqz	s2,800057fc <argfd+0x46>
    *pfd = fd;
    800057f8:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    800057fc:	4501                	li	a0,0
  if (pf)
    800057fe:	c091                	beqz	s1,80005802 <argfd+0x4c>
    *pf = f;
    80005800:	e09c                	sd	a5,0(s1)
}
    80005802:	70a2                	ld	ra,40(sp)
    80005804:	7402                	ld	s0,32(sp)
    80005806:	64e2                	ld	s1,24(sp)
    80005808:	6942                	ld	s2,16(sp)
    8000580a:	6145                	addi	sp,sp,48
    8000580c:	8082                	ret
    return -1;
    8000580e:	557d                	li	a0,-1
    80005810:	bfcd                	j	80005802 <argfd+0x4c>
    80005812:	557d                	li	a0,-1
    80005814:	b7fd                	j	80005802 <argfd+0x4c>

0000000080005816 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005816:	1101                	addi	sp,sp,-32
    80005818:	ec06                	sd	ra,24(sp)
    8000581a:	e822                	sd	s0,16(sp)
    8000581c:	e426                	sd	s1,8(sp)
    8000581e:	1000                	addi	s0,sp,32
    80005820:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005822:	ffffc097          	auipc	ra,0xffffc
    80005826:	358080e7          	jalr	856(ra) # 80001b7a <myproc>
    8000582a:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++)
    8000582c:	0d050793          	addi	a5,a0,208
    80005830:	4501                	li	a0,0
    80005832:	46c1                	li	a3,16
  {
    if (p->ofile[fd] == 0)
    80005834:	6398                	ld	a4,0(a5)
    80005836:	cb19                	beqz	a4,8000584c <fdalloc+0x36>
  for (fd = 0; fd < NOFILE; fd++)
    80005838:	2505                	addiw	a0,a0,1
    8000583a:	07a1                	addi	a5,a5,8
    8000583c:	fed51ce3          	bne	a0,a3,80005834 <fdalloc+0x1e>
    {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005840:	557d                	li	a0,-1
}
    80005842:	60e2                	ld	ra,24(sp)
    80005844:	6442                	ld	s0,16(sp)
    80005846:	64a2                	ld	s1,8(sp)
    80005848:	6105                	addi	sp,sp,32
    8000584a:	8082                	ret
      p->ofile[fd] = f;
    8000584c:	01a50793          	addi	a5,a0,26
    80005850:	078e                	slli	a5,a5,0x3
    80005852:	963e                	add	a2,a2,a5
    80005854:	e204                	sd	s1,0(a2)
      return fd;
    80005856:	b7f5                	j	80005842 <fdalloc+0x2c>

0000000080005858 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80005858:	715d                	addi	sp,sp,-80
    8000585a:	e486                	sd	ra,72(sp)
    8000585c:	e0a2                	sd	s0,64(sp)
    8000585e:	fc26                	sd	s1,56(sp)
    80005860:	f84a                	sd	s2,48(sp)
    80005862:	f44e                	sd	s3,40(sp)
    80005864:	f052                	sd	s4,32(sp)
    80005866:	ec56                	sd	s5,24(sp)
    80005868:	e85a                	sd	s6,16(sp)
    8000586a:	0880                	addi	s0,sp,80
    8000586c:	8b2e                	mv	s6,a1
    8000586e:	89b2                	mv	s3,a2
    80005870:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80005872:	fb040593          	addi	a1,s0,-80
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	e3e080e7          	jalr	-450(ra) # 800046b4 <nameiparent>
    8000587e:	84aa                	mv	s1,a0
    80005880:	14050f63          	beqz	a0,800059de <create+0x186>
    return 0;

  ilock(dp);
    80005884:	ffffe097          	auipc	ra,0xffffe
    80005888:	666080e7          	jalr	1638(ra) # 80003eea <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0)
    8000588c:	4601                	li	a2,0
    8000588e:	fb040593          	addi	a1,s0,-80
    80005892:	8526                	mv	a0,s1
    80005894:	fffff097          	auipc	ra,0xfffff
    80005898:	b3a080e7          	jalr	-1222(ra) # 800043ce <dirlookup>
    8000589c:	8aaa                	mv	s5,a0
    8000589e:	c931                	beqz	a0,800058f2 <create+0x9a>
  {
    iunlockput(dp);
    800058a0:	8526                	mv	a0,s1
    800058a2:	fffff097          	auipc	ra,0xfffff
    800058a6:	8aa080e7          	jalr	-1878(ra) # 8000414c <iunlockput>
    ilock(ip);
    800058aa:	8556                	mv	a0,s5
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	63e080e7          	jalr	1598(ra) # 80003eea <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800058b4:	000b059b          	sext.w	a1,s6
    800058b8:	4789                	li	a5,2
    800058ba:	02f59563          	bne	a1,a5,800058e4 <create+0x8c>
    800058be:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fdb9a74>
    800058c2:	37f9                	addiw	a5,a5,-2
    800058c4:	17c2                	slli	a5,a5,0x30
    800058c6:	93c1                	srli	a5,a5,0x30
    800058c8:	4705                	li	a4,1
    800058ca:	00f76d63          	bltu	a4,a5,800058e4 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800058ce:	8556                	mv	a0,s5
    800058d0:	60a6                	ld	ra,72(sp)
    800058d2:	6406                	ld	s0,64(sp)
    800058d4:	74e2                	ld	s1,56(sp)
    800058d6:	7942                	ld	s2,48(sp)
    800058d8:	79a2                	ld	s3,40(sp)
    800058da:	7a02                	ld	s4,32(sp)
    800058dc:	6ae2                	ld	s5,24(sp)
    800058de:	6b42                	ld	s6,16(sp)
    800058e0:	6161                	addi	sp,sp,80
    800058e2:	8082                	ret
    iunlockput(ip);
    800058e4:	8556                	mv	a0,s5
    800058e6:	fffff097          	auipc	ra,0xfffff
    800058ea:	866080e7          	jalr	-1946(ra) # 8000414c <iunlockput>
    return 0;
    800058ee:	4a81                	li	s5,0
    800058f0:	bff9                	j	800058ce <create+0x76>
  if ((ip = ialloc(dp->dev, type)) == 0)
    800058f2:	85da                	mv	a1,s6
    800058f4:	4088                	lw	a0,0(s1)
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	456080e7          	jalr	1110(ra) # 80003d4c <ialloc>
    800058fe:	8a2a                	mv	s4,a0
    80005900:	c539                	beqz	a0,8000594e <create+0xf6>
  ilock(ip);
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	5e8080e7          	jalr	1512(ra) # 80003eea <ilock>
  ip->major = major;
    8000590a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000590e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005912:	4905                	li	s2,1
    80005914:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005918:	8552                	mv	a0,s4
    8000591a:	ffffe097          	auipc	ra,0xffffe
    8000591e:	504080e7          	jalr	1284(ra) # 80003e1e <iupdate>
  if (type == T_DIR)
    80005922:	000b059b          	sext.w	a1,s6
    80005926:	03258b63          	beq	a1,s2,8000595c <create+0x104>
  if (dirlink(dp, name, ip->inum) < 0)
    8000592a:	004a2603          	lw	a2,4(s4)
    8000592e:	fb040593          	addi	a1,s0,-80
    80005932:	8526                	mv	a0,s1
    80005934:	fffff097          	auipc	ra,0xfffff
    80005938:	cb0080e7          	jalr	-848(ra) # 800045e4 <dirlink>
    8000593c:	06054f63          	bltz	a0,800059ba <create+0x162>
  iunlockput(dp);
    80005940:	8526                	mv	a0,s1
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	80a080e7          	jalr	-2038(ra) # 8000414c <iunlockput>
  return ip;
    8000594a:	8ad2                	mv	s5,s4
    8000594c:	b749                	j	800058ce <create+0x76>
    iunlockput(dp);
    8000594e:	8526                	mv	a0,s1
    80005950:	ffffe097          	auipc	ra,0xffffe
    80005954:	7fc080e7          	jalr	2044(ra) # 8000414c <iunlockput>
    return 0;
    80005958:	8ad2                	mv	s5,s4
    8000595a:	bf95                	j	800058ce <create+0x76>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000595c:	004a2603          	lw	a2,4(s4)
    80005960:	00003597          	auipc	a1,0x3
    80005964:	f4058593          	addi	a1,a1,-192 # 800088a0 <syscalls+0x2c8>
    80005968:	8552                	mv	a0,s4
    8000596a:	fffff097          	auipc	ra,0xfffff
    8000596e:	c7a080e7          	jalr	-902(ra) # 800045e4 <dirlink>
    80005972:	04054463          	bltz	a0,800059ba <create+0x162>
    80005976:	40d0                	lw	a2,4(s1)
    80005978:	00003597          	auipc	a1,0x3
    8000597c:	f3058593          	addi	a1,a1,-208 # 800088a8 <syscalls+0x2d0>
    80005980:	8552                	mv	a0,s4
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	c62080e7          	jalr	-926(ra) # 800045e4 <dirlink>
    8000598a:	02054863          	bltz	a0,800059ba <create+0x162>
  if (dirlink(dp, name, ip->inum) < 0)
    8000598e:	004a2603          	lw	a2,4(s4)
    80005992:	fb040593          	addi	a1,s0,-80
    80005996:	8526                	mv	a0,s1
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	c4c080e7          	jalr	-948(ra) # 800045e4 <dirlink>
    800059a0:	00054d63          	bltz	a0,800059ba <create+0x162>
    dp->nlink++; // for ".."
    800059a4:	04a4d783          	lhu	a5,74(s1)
    800059a8:	2785                	addiw	a5,a5,1
    800059aa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059ae:	8526                	mv	a0,s1
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	46e080e7          	jalr	1134(ra) # 80003e1e <iupdate>
    800059b8:	b761                	j	80005940 <create+0xe8>
  ip->nlink = 0;
    800059ba:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800059be:	8552                	mv	a0,s4
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	45e080e7          	jalr	1118(ra) # 80003e1e <iupdate>
  iunlockput(ip);
    800059c8:	8552                	mv	a0,s4
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	782080e7          	jalr	1922(ra) # 8000414c <iunlockput>
  iunlockput(dp);
    800059d2:	8526                	mv	a0,s1
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	778080e7          	jalr	1912(ra) # 8000414c <iunlockput>
  return 0;
    800059dc:	bdcd                	j	800058ce <create+0x76>
    return 0;
    800059de:	8aaa                	mv	s5,a0
    800059e0:	b5fd                	j	800058ce <create+0x76>

00000000800059e2 <sys_dup>:
{
    800059e2:	7179                	addi	sp,sp,-48
    800059e4:	f406                	sd	ra,40(sp)
    800059e6:	f022                	sd	s0,32(sp)
    800059e8:	ec26                	sd	s1,24(sp)
    800059ea:	e84a                	sd	s2,16(sp)
    800059ec:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    800059ee:	fd840613          	addi	a2,s0,-40
    800059f2:	4581                	li	a1,0
    800059f4:	4501                	li	a0,0
    800059f6:	00000097          	auipc	ra,0x0
    800059fa:	dc0080e7          	jalr	-576(ra) # 800057b6 <argfd>
    return -1;
    800059fe:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80005a00:	02054363          	bltz	a0,80005a26 <sys_dup+0x44>
  if ((fd = fdalloc(f)) < 0)
    80005a04:	fd843903          	ld	s2,-40(s0)
    80005a08:	854a                	mv	a0,s2
    80005a0a:	00000097          	auipc	ra,0x0
    80005a0e:	e0c080e7          	jalr	-500(ra) # 80005816 <fdalloc>
    80005a12:	84aa                	mv	s1,a0
    return -1;
    80005a14:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80005a16:	00054863          	bltz	a0,80005a26 <sys_dup+0x44>
  filedup(f);
    80005a1a:	854a                	mv	a0,s2
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	310080e7          	jalr	784(ra) # 80004d2c <filedup>
  return fd;
    80005a24:	87a6                	mv	a5,s1
}
    80005a26:	853e                	mv	a0,a5
    80005a28:	70a2                	ld	ra,40(sp)
    80005a2a:	7402                	ld	s0,32(sp)
    80005a2c:	64e2                	ld	s1,24(sp)
    80005a2e:	6942                	ld	s2,16(sp)
    80005a30:	6145                	addi	sp,sp,48
    80005a32:	8082                	ret

0000000080005a34 <sys_read>:
{
    80005a34:	7179                	addi	sp,sp,-48
    80005a36:	f406                	sd	ra,40(sp)
    80005a38:	f022                	sd	s0,32(sp)
    80005a3a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a3c:	fd840593          	addi	a1,s0,-40
    80005a40:	4505                	li	a0,1
    80005a42:	ffffd097          	auipc	ra,0xffffd
    80005a46:	6f6080e7          	jalr	1782(ra) # 80003138 <argaddr>
  argint(2, &n);
    80005a4a:	fe440593          	addi	a1,s0,-28
    80005a4e:	4509                	li	a0,2
    80005a50:	ffffd097          	auipc	ra,0xffffd
    80005a54:	6c8080e7          	jalr	1736(ra) # 80003118 <argint>
  if (argfd(0, 0, &f) < 0)
    80005a58:	fe840613          	addi	a2,s0,-24
    80005a5c:	4581                	li	a1,0
    80005a5e:	4501                	li	a0,0
    80005a60:	00000097          	auipc	ra,0x0
    80005a64:	d56080e7          	jalr	-682(ra) # 800057b6 <argfd>
    80005a68:	87aa                	mv	a5,a0
    return -1;
    80005a6a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005a6c:	0007cc63          	bltz	a5,80005a84 <sys_read+0x50>
  return fileread(f, p, n);
    80005a70:	fe442603          	lw	a2,-28(s0)
    80005a74:	fd843583          	ld	a1,-40(s0)
    80005a78:	fe843503          	ld	a0,-24(s0)
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	43c080e7          	jalr	1084(ra) # 80004eb8 <fileread>
}
    80005a84:	70a2                	ld	ra,40(sp)
    80005a86:	7402                	ld	s0,32(sp)
    80005a88:	6145                	addi	sp,sp,48
    80005a8a:	8082                	ret

0000000080005a8c <sys_write>:
{
    80005a8c:	7179                	addi	sp,sp,-48
    80005a8e:	f406                	sd	ra,40(sp)
    80005a90:	f022                	sd	s0,32(sp)
    80005a92:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a94:	fd840593          	addi	a1,s0,-40
    80005a98:	4505                	li	a0,1
    80005a9a:	ffffd097          	auipc	ra,0xffffd
    80005a9e:	69e080e7          	jalr	1694(ra) # 80003138 <argaddr>
  argint(2, &n);
    80005aa2:	fe440593          	addi	a1,s0,-28
    80005aa6:	4509                	li	a0,2
    80005aa8:	ffffd097          	auipc	ra,0xffffd
    80005aac:	670080e7          	jalr	1648(ra) # 80003118 <argint>
  if (argfd(0, 0, &f) < 0)
    80005ab0:	fe840613          	addi	a2,s0,-24
    80005ab4:	4581                	li	a1,0
    80005ab6:	4501                	li	a0,0
    80005ab8:	00000097          	auipc	ra,0x0
    80005abc:	cfe080e7          	jalr	-770(ra) # 800057b6 <argfd>
    80005ac0:	87aa                	mv	a5,a0
    return -1;
    80005ac2:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005ac4:	0007cc63          	bltz	a5,80005adc <sys_write+0x50>
  return filewrite(f, p, n);
    80005ac8:	fe442603          	lw	a2,-28(s0)
    80005acc:	fd843583          	ld	a1,-40(s0)
    80005ad0:	fe843503          	ld	a0,-24(s0)
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	4a6080e7          	jalr	1190(ra) # 80004f7a <filewrite>
}
    80005adc:	70a2                	ld	ra,40(sp)
    80005ade:	7402                	ld	s0,32(sp)
    80005ae0:	6145                	addi	sp,sp,48
    80005ae2:	8082                	ret

0000000080005ae4 <sys_close>:
{
    80005ae4:	1101                	addi	sp,sp,-32
    80005ae6:	ec06                	sd	ra,24(sp)
    80005ae8:	e822                	sd	s0,16(sp)
    80005aea:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005aec:	fe040613          	addi	a2,s0,-32
    80005af0:	fec40593          	addi	a1,s0,-20
    80005af4:	4501                	li	a0,0
    80005af6:	00000097          	auipc	ra,0x0
    80005afa:	cc0080e7          	jalr	-832(ra) # 800057b6 <argfd>
    return -1;
    80005afe:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005b00:	02054463          	bltz	a0,80005b28 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005b04:	ffffc097          	auipc	ra,0xffffc
    80005b08:	076080e7          	jalr	118(ra) # 80001b7a <myproc>
    80005b0c:	fec42783          	lw	a5,-20(s0)
    80005b10:	07e9                	addi	a5,a5,26
    80005b12:	078e                	slli	a5,a5,0x3
    80005b14:	953e                	add	a0,a0,a5
    80005b16:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005b1a:	fe043503          	ld	a0,-32(s0)
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	260080e7          	jalr	608(ra) # 80004d7e <fileclose>
  return 0;
    80005b26:	4781                	li	a5,0
}
    80005b28:	853e                	mv	a0,a5
    80005b2a:	60e2                	ld	ra,24(sp)
    80005b2c:	6442                	ld	s0,16(sp)
    80005b2e:	6105                	addi	sp,sp,32
    80005b30:	8082                	ret

0000000080005b32 <sys_fstat>:
{
    80005b32:	1101                	addi	sp,sp,-32
    80005b34:	ec06                	sd	ra,24(sp)
    80005b36:	e822                	sd	s0,16(sp)
    80005b38:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005b3a:	fe040593          	addi	a1,s0,-32
    80005b3e:	4505                	li	a0,1
    80005b40:	ffffd097          	auipc	ra,0xffffd
    80005b44:	5f8080e7          	jalr	1528(ra) # 80003138 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005b48:	fe840613          	addi	a2,s0,-24
    80005b4c:	4581                	li	a1,0
    80005b4e:	4501                	li	a0,0
    80005b50:	00000097          	auipc	ra,0x0
    80005b54:	c66080e7          	jalr	-922(ra) # 800057b6 <argfd>
    80005b58:	87aa                	mv	a5,a0
    return -1;
    80005b5a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005b5c:	0007ca63          	bltz	a5,80005b70 <sys_fstat+0x3e>
  return filestat(f, st);
    80005b60:	fe043583          	ld	a1,-32(s0)
    80005b64:	fe843503          	ld	a0,-24(s0)
    80005b68:	fffff097          	auipc	ra,0xfffff
    80005b6c:	2de080e7          	jalr	734(ra) # 80004e46 <filestat>
}
    80005b70:	60e2                	ld	ra,24(sp)
    80005b72:	6442                	ld	s0,16(sp)
    80005b74:	6105                	addi	sp,sp,32
    80005b76:	8082                	ret

0000000080005b78 <sys_link>:
{
    80005b78:	7169                	addi	sp,sp,-304
    80005b7a:	f606                	sd	ra,296(sp)
    80005b7c:	f222                	sd	s0,288(sp)
    80005b7e:	ee26                	sd	s1,280(sp)
    80005b80:	ea4a                	sd	s2,272(sp)
    80005b82:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b84:	08000613          	li	a2,128
    80005b88:	ed040593          	addi	a1,s0,-304
    80005b8c:	4501                	li	a0,0
    80005b8e:	ffffd097          	auipc	ra,0xffffd
    80005b92:	5ca080e7          	jalr	1482(ra) # 80003158 <argstr>
    return -1;
    80005b96:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b98:	10054e63          	bltz	a0,80005cb4 <sys_link+0x13c>
    80005b9c:	08000613          	li	a2,128
    80005ba0:	f5040593          	addi	a1,s0,-176
    80005ba4:	4505                	li	a0,1
    80005ba6:	ffffd097          	auipc	ra,0xffffd
    80005baa:	5b2080e7          	jalr	1458(ra) # 80003158 <argstr>
    return -1;
    80005bae:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bb0:	10054263          	bltz	a0,80005cb4 <sys_link+0x13c>
  begin_op();
    80005bb4:	fffff097          	auipc	ra,0xfffff
    80005bb8:	d02080e7          	jalr	-766(ra) # 800048b6 <begin_op>
  if ((ip = namei(old)) == 0)
    80005bbc:	ed040513          	addi	a0,s0,-304
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	ad6080e7          	jalr	-1322(ra) # 80004696 <namei>
    80005bc8:	84aa                	mv	s1,a0
    80005bca:	c551                	beqz	a0,80005c56 <sys_link+0xde>
  ilock(ip);
    80005bcc:	ffffe097          	auipc	ra,0xffffe
    80005bd0:	31e080e7          	jalr	798(ra) # 80003eea <ilock>
  if (ip->type == T_DIR)
    80005bd4:	04449703          	lh	a4,68(s1)
    80005bd8:	4785                	li	a5,1
    80005bda:	08f70463          	beq	a4,a5,80005c62 <sys_link+0xea>
  ip->nlink++;
    80005bde:	04a4d783          	lhu	a5,74(s1)
    80005be2:	2785                	addiw	a5,a5,1
    80005be4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005be8:	8526                	mv	a0,s1
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	234080e7          	jalr	564(ra) # 80003e1e <iupdate>
  iunlock(ip);
    80005bf2:	8526                	mv	a0,s1
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	3b8080e7          	jalr	952(ra) # 80003fac <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005bfc:	fd040593          	addi	a1,s0,-48
    80005c00:	f5040513          	addi	a0,s0,-176
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	ab0080e7          	jalr	-1360(ra) # 800046b4 <nameiparent>
    80005c0c:	892a                	mv	s2,a0
    80005c0e:	c935                	beqz	a0,80005c82 <sys_link+0x10a>
  ilock(dp);
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	2da080e7          	jalr	730(ra) # 80003eea <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0)
    80005c18:	00092703          	lw	a4,0(s2)
    80005c1c:	409c                	lw	a5,0(s1)
    80005c1e:	04f71d63          	bne	a4,a5,80005c78 <sys_link+0x100>
    80005c22:	40d0                	lw	a2,4(s1)
    80005c24:	fd040593          	addi	a1,s0,-48
    80005c28:	854a                	mv	a0,s2
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	9ba080e7          	jalr	-1606(ra) # 800045e4 <dirlink>
    80005c32:	04054363          	bltz	a0,80005c78 <sys_link+0x100>
  iunlockput(dp);
    80005c36:	854a                	mv	a0,s2
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	514080e7          	jalr	1300(ra) # 8000414c <iunlockput>
  iput(ip);
    80005c40:	8526                	mv	a0,s1
    80005c42:	ffffe097          	auipc	ra,0xffffe
    80005c46:	462080e7          	jalr	1122(ra) # 800040a4 <iput>
  end_op();
    80005c4a:	fffff097          	auipc	ra,0xfffff
    80005c4e:	cea080e7          	jalr	-790(ra) # 80004934 <end_op>
  return 0;
    80005c52:	4781                	li	a5,0
    80005c54:	a085                	j	80005cb4 <sys_link+0x13c>
    end_op();
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	cde080e7          	jalr	-802(ra) # 80004934 <end_op>
    return -1;
    80005c5e:	57fd                	li	a5,-1
    80005c60:	a891                	j	80005cb4 <sys_link+0x13c>
    iunlockput(ip);
    80005c62:	8526                	mv	a0,s1
    80005c64:	ffffe097          	auipc	ra,0xffffe
    80005c68:	4e8080e7          	jalr	1256(ra) # 8000414c <iunlockput>
    end_op();
    80005c6c:	fffff097          	auipc	ra,0xfffff
    80005c70:	cc8080e7          	jalr	-824(ra) # 80004934 <end_op>
    return -1;
    80005c74:	57fd                	li	a5,-1
    80005c76:	a83d                	j	80005cb4 <sys_link+0x13c>
    iunlockput(dp);
    80005c78:	854a                	mv	a0,s2
    80005c7a:	ffffe097          	auipc	ra,0xffffe
    80005c7e:	4d2080e7          	jalr	1234(ra) # 8000414c <iunlockput>
  ilock(ip);
    80005c82:	8526                	mv	a0,s1
    80005c84:	ffffe097          	auipc	ra,0xffffe
    80005c88:	266080e7          	jalr	614(ra) # 80003eea <ilock>
  ip->nlink--;
    80005c8c:	04a4d783          	lhu	a5,74(s1)
    80005c90:	37fd                	addiw	a5,a5,-1
    80005c92:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c96:	8526                	mv	a0,s1
    80005c98:	ffffe097          	auipc	ra,0xffffe
    80005c9c:	186080e7          	jalr	390(ra) # 80003e1e <iupdate>
  iunlockput(ip);
    80005ca0:	8526                	mv	a0,s1
    80005ca2:	ffffe097          	auipc	ra,0xffffe
    80005ca6:	4aa080e7          	jalr	1194(ra) # 8000414c <iunlockput>
  end_op();
    80005caa:	fffff097          	auipc	ra,0xfffff
    80005cae:	c8a080e7          	jalr	-886(ra) # 80004934 <end_op>
  return -1;
    80005cb2:	57fd                	li	a5,-1
}
    80005cb4:	853e                	mv	a0,a5
    80005cb6:	70b2                	ld	ra,296(sp)
    80005cb8:	7412                	ld	s0,288(sp)
    80005cba:	64f2                	ld	s1,280(sp)
    80005cbc:	6952                	ld	s2,272(sp)
    80005cbe:	6155                	addi	sp,sp,304
    80005cc0:	8082                	ret

0000000080005cc2 <sys_unlink>:
{
    80005cc2:	7151                	addi	sp,sp,-240
    80005cc4:	f586                	sd	ra,232(sp)
    80005cc6:	f1a2                	sd	s0,224(sp)
    80005cc8:	eda6                	sd	s1,216(sp)
    80005cca:	e9ca                	sd	s2,208(sp)
    80005ccc:	e5ce                	sd	s3,200(sp)
    80005cce:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005cd0:	08000613          	li	a2,128
    80005cd4:	f3040593          	addi	a1,s0,-208
    80005cd8:	4501                	li	a0,0
    80005cda:	ffffd097          	auipc	ra,0xffffd
    80005cde:	47e080e7          	jalr	1150(ra) # 80003158 <argstr>
    80005ce2:	18054163          	bltz	a0,80005e64 <sys_unlink+0x1a2>
  begin_op();
    80005ce6:	fffff097          	auipc	ra,0xfffff
    80005cea:	bd0080e7          	jalr	-1072(ra) # 800048b6 <begin_op>
  if ((dp = nameiparent(path, name)) == 0)
    80005cee:	fb040593          	addi	a1,s0,-80
    80005cf2:	f3040513          	addi	a0,s0,-208
    80005cf6:	fffff097          	auipc	ra,0xfffff
    80005cfa:	9be080e7          	jalr	-1602(ra) # 800046b4 <nameiparent>
    80005cfe:	84aa                	mv	s1,a0
    80005d00:	c979                	beqz	a0,80005dd6 <sys_unlink+0x114>
  ilock(dp);
    80005d02:	ffffe097          	auipc	ra,0xffffe
    80005d06:	1e8080e7          	jalr	488(ra) # 80003eea <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005d0a:	00003597          	auipc	a1,0x3
    80005d0e:	b9658593          	addi	a1,a1,-1130 # 800088a0 <syscalls+0x2c8>
    80005d12:	fb040513          	addi	a0,s0,-80
    80005d16:	ffffe097          	auipc	ra,0xffffe
    80005d1a:	69e080e7          	jalr	1694(ra) # 800043b4 <namecmp>
    80005d1e:	14050a63          	beqz	a0,80005e72 <sys_unlink+0x1b0>
    80005d22:	00003597          	auipc	a1,0x3
    80005d26:	b8658593          	addi	a1,a1,-1146 # 800088a8 <syscalls+0x2d0>
    80005d2a:	fb040513          	addi	a0,s0,-80
    80005d2e:	ffffe097          	auipc	ra,0xffffe
    80005d32:	686080e7          	jalr	1670(ra) # 800043b4 <namecmp>
    80005d36:	12050e63          	beqz	a0,80005e72 <sys_unlink+0x1b0>
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005d3a:	f2c40613          	addi	a2,s0,-212
    80005d3e:	fb040593          	addi	a1,s0,-80
    80005d42:	8526                	mv	a0,s1
    80005d44:	ffffe097          	auipc	ra,0xffffe
    80005d48:	68a080e7          	jalr	1674(ra) # 800043ce <dirlookup>
    80005d4c:	892a                	mv	s2,a0
    80005d4e:	12050263          	beqz	a0,80005e72 <sys_unlink+0x1b0>
  ilock(ip);
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	198080e7          	jalr	408(ra) # 80003eea <ilock>
  if (ip->nlink < 1)
    80005d5a:	04a91783          	lh	a5,74(s2)
    80005d5e:	08f05263          	blez	a5,80005de2 <sys_unlink+0x120>
  if (ip->type == T_DIR && !isdirempty(ip))
    80005d62:	04491703          	lh	a4,68(s2)
    80005d66:	4785                	li	a5,1
    80005d68:	08f70563          	beq	a4,a5,80005df2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005d6c:	4641                	li	a2,16
    80005d6e:	4581                	li	a1,0
    80005d70:	fc040513          	addi	a0,s0,-64
    80005d74:	ffffb097          	auipc	ra,0xffffb
    80005d78:	0d2080e7          	jalr	210(ra) # 80000e46 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d7c:	4741                	li	a4,16
    80005d7e:	f2c42683          	lw	a3,-212(s0)
    80005d82:	fc040613          	addi	a2,s0,-64
    80005d86:	4581                	li	a1,0
    80005d88:	8526                	mv	a0,s1
    80005d8a:	ffffe097          	auipc	ra,0xffffe
    80005d8e:	50c080e7          	jalr	1292(ra) # 80004296 <writei>
    80005d92:	47c1                	li	a5,16
    80005d94:	0af51563          	bne	a0,a5,80005e3e <sys_unlink+0x17c>
  if (ip->type == T_DIR)
    80005d98:	04491703          	lh	a4,68(s2)
    80005d9c:	4785                	li	a5,1
    80005d9e:	0af70863          	beq	a4,a5,80005e4e <sys_unlink+0x18c>
  iunlockput(dp);
    80005da2:	8526                	mv	a0,s1
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	3a8080e7          	jalr	936(ra) # 8000414c <iunlockput>
  ip->nlink--;
    80005dac:	04a95783          	lhu	a5,74(s2)
    80005db0:	37fd                	addiw	a5,a5,-1
    80005db2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005db6:	854a                	mv	a0,s2
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	066080e7          	jalr	102(ra) # 80003e1e <iupdate>
  iunlockput(ip);
    80005dc0:	854a                	mv	a0,s2
    80005dc2:	ffffe097          	auipc	ra,0xffffe
    80005dc6:	38a080e7          	jalr	906(ra) # 8000414c <iunlockput>
  end_op();
    80005dca:	fffff097          	auipc	ra,0xfffff
    80005dce:	b6a080e7          	jalr	-1174(ra) # 80004934 <end_op>
  return 0;
    80005dd2:	4501                	li	a0,0
    80005dd4:	a84d                	j	80005e86 <sys_unlink+0x1c4>
    end_op();
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	b5e080e7          	jalr	-1186(ra) # 80004934 <end_op>
    return -1;
    80005dde:	557d                	li	a0,-1
    80005de0:	a05d                	j	80005e86 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005de2:	00003517          	auipc	a0,0x3
    80005de6:	ace50513          	addi	a0,a0,-1330 # 800088b0 <syscalls+0x2d8>
    80005dea:	ffffa097          	auipc	ra,0xffffa
    80005dee:	756080e7          	jalr	1878(ra) # 80000540 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005df2:	04c92703          	lw	a4,76(s2)
    80005df6:	02000793          	li	a5,32
    80005dfa:	f6e7f9e3          	bgeu	a5,a4,80005d6c <sys_unlink+0xaa>
    80005dfe:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e02:	4741                	li	a4,16
    80005e04:	86ce                	mv	a3,s3
    80005e06:	f1840613          	addi	a2,s0,-232
    80005e0a:	4581                	li	a1,0
    80005e0c:	854a                	mv	a0,s2
    80005e0e:	ffffe097          	auipc	ra,0xffffe
    80005e12:	390080e7          	jalr	912(ra) # 8000419e <readi>
    80005e16:	47c1                	li	a5,16
    80005e18:	00f51b63          	bne	a0,a5,80005e2e <sys_unlink+0x16c>
    if (de.inum != 0)
    80005e1c:	f1845783          	lhu	a5,-232(s0)
    80005e20:	e7a1                	bnez	a5,80005e68 <sys_unlink+0x1a6>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005e22:	29c1                	addiw	s3,s3,16
    80005e24:	04c92783          	lw	a5,76(s2)
    80005e28:	fcf9ede3          	bltu	s3,a5,80005e02 <sys_unlink+0x140>
    80005e2c:	b781                	j	80005d6c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005e2e:	00003517          	auipc	a0,0x3
    80005e32:	a9a50513          	addi	a0,a0,-1382 # 800088c8 <syscalls+0x2f0>
    80005e36:	ffffa097          	auipc	ra,0xffffa
    80005e3a:	70a080e7          	jalr	1802(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005e3e:	00003517          	auipc	a0,0x3
    80005e42:	aa250513          	addi	a0,a0,-1374 # 800088e0 <syscalls+0x308>
    80005e46:	ffffa097          	auipc	ra,0xffffa
    80005e4a:	6fa080e7          	jalr	1786(ra) # 80000540 <panic>
    dp->nlink--;
    80005e4e:	04a4d783          	lhu	a5,74(s1)
    80005e52:	37fd                	addiw	a5,a5,-1
    80005e54:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005e58:	8526                	mv	a0,s1
    80005e5a:	ffffe097          	auipc	ra,0xffffe
    80005e5e:	fc4080e7          	jalr	-60(ra) # 80003e1e <iupdate>
    80005e62:	b781                	j	80005da2 <sys_unlink+0xe0>
    return -1;
    80005e64:	557d                	li	a0,-1
    80005e66:	a005                	j	80005e86 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005e68:	854a                	mv	a0,s2
    80005e6a:	ffffe097          	auipc	ra,0xffffe
    80005e6e:	2e2080e7          	jalr	738(ra) # 8000414c <iunlockput>
  iunlockput(dp);
    80005e72:	8526                	mv	a0,s1
    80005e74:	ffffe097          	auipc	ra,0xffffe
    80005e78:	2d8080e7          	jalr	728(ra) # 8000414c <iunlockput>
  end_op();
    80005e7c:	fffff097          	auipc	ra,0xfffff
    80005e80:	ab8080e7          	jalr	-1352(ra) # 80004934 <end_op>
  return -1;
    80005e84:	557d                	li	a0,-1
}
    80005e86:	70ae                	ld	ra,232(sp)
    80005e88:	740e                	ld	s0,224(sp)
    80005e8a:	64ee                	ld	s1,216(sp)
    80005e8c:	694e                	ld	s2,208(sp)
    80005e8e:	69ae                	ld	s3,200(sp)
    80005e90:	616d                	addi	sp,sp,240
    80005e92:	8082                	ret

0000000080005e94 <sys_open>:

uint64
sys_open(void)
{
    80005e94:	7131                	addi	sp,sp,-192
    80005e96:	fd06                	sd	ra,184(sp)
    80005e98:	f922                	sd	s0,176(sp)
    80005e9a:	f526                	sd	s1,168(sp)
    80005e9c:	f14a                	sd	s2,160(sp)
    80005e9e:	ed4e                	sd	s3,152(sp)
    80005ea0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005ea2:	f4c40593          	addi	a1,s0,-180
    80005ea6:	4505                	li	a0,1
    80005ea8:	ffffd097          	auipc	ra,0xffffd
    80005eac:	270080e7          	jalr	624(ra) # 80003118 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005eb0:	08000613          	li	a2,128
    80005eb4:	f5040593          	addi	a1,s0,-176
    80005eb8:	4501                	li	a0,0
    80005eba:	ffffd097          	auipc	ra,0xffffd
    80005ebe:	29e080e7          	jalr	670(ra) # 80003158 <argstr>
    80005ec2:	87aa                	mv	a5,a0
    return -1;
    80005ec4:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005ec6:	0a07c963          	bltz	a5,80005f78 <sys_open+0xe4>

  begin_op();
    80005eca:	fffff097          	auipc	ra,0xfffff
    80005ece:	9ec080e7          	jalr	-1556(ra) # 800048b6 <begin_op>

  if (omode & O_CREATE)
    80005ed2:	f4c42783          	lw	a5,-180(s0)
    80005ed6:	2007f793          	andi	a5,a5,512
    80005eda:	cfc5                	beqz	a5,80005f92 <sys_open+0xfe>
  {
    ip = create(path, T_FILE, 0, 0);
    80005edc:	4681                	li	a3,0
    80005ede:	4601                	li	a2,0
    80005ee0:	4589                	li	a1,2
    80005ee2:	f5040513          	addi	a0,s0,-176
    80005ee6:	00000097          	auipc	ra,0x0
    80005eea:	972080e7          	jalr	-1678(ra) # 80005858 <create>
    80005eee:	84aa                	mv	s1,a0
    if (ip == 0)
    80005ef0:	c959                	beqz	a0,80005f86 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV))
    80005ef2:	04449703          	lh	a4,68(s1)
    80005ef6:	478d                	li	a5,3
    80005ef8:	00f71763          	bne	a4,a5,80005f06 <sys_open+0x72>
    80005efc:	0464d703          	lhu	a4,70(s1)
    80005f00:	47a5                	li	a5,9
    80005f02:	0ce7ed63          	bltu	a5,a4,80005fdc <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0)
    80005f06:	fffff097          	auipc	ra,0xfffff
    80005f0a:	dbc080e7          	jalr	-580(ra) # 80004cc2 <filealloc>
    80005f0e:	89aa                	mv	s3,a0
    80005f10:	10050363          	beqz	a0,80006016 <sys_open+0x182>
    80005f14:	00000097          	auipc	ra,0x0
    80005f18:	902080e7          	jalr	-1790(ra) # 80005816 <fdalloc>
    80005f1c:	892a                	mv	s2,a0
    80005f1e:	0e054763          	bltz	a0,8000600c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE)
    80005f22:	04449703          	lh	a4,68(s1)
    80005f26:	478d                	li	a5,3
    80005f28:	0cf70563          	beq	a4,a5,80005ff2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  }
  else
  {
    f->type = FD_INODE;
    80005f2c:	4789                	li	a5,2
    80005f2e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005f32:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005f36:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005f3a:	f4c42783          	lw	a5,-180(s0)
    80005f3e:	0017c713          	xori	a4,a5,1
    80005f42:	8b05                	andi	a4,a4,1
    80005f44:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f48:	0037f713          	andi	a4,a5,3
    80005f4c:	00e03733          	snez	a4,a4
    80005f50:	00e984a3          	sb	a4,9(s3)

  if ((omode & O_TRUNC) && ip->type == T_FILE)
    80005f54:	4007f793          	andi	a5,a5,1024
    80005f58:	c791                	beqz	a5,80005f64 <sys_open+0xd0>
    80005f5a:	04449703          	lh	a4,68(s1)
    80005f5e:	4789                	li	a5,2
    80005f60:	0af70063          	beq	a4,a5,80006000 <sys_open+0x16c>
  {
    itrunc(ip);
  }

  iunlock(ip);
    80005f64:	8526                	mv	a0,s1
    80005f66:	ffffe097          	auipc	ra,0xffffe
    80005f6a:	046080e7          	jalr	70(ra) # 80003fac <iunlock>
  end_op();
    80005f6e:	fffff097          	auipc	ra,0xfffff
    80005f72:	9c6080e7          	jalr	-1594(ra) # 80004934 <end_op>

  return fd;
    80005f76:	854a                	mv	a0,s2
}
    80005f78:	70ea                	ld	ra,184(sp)
    80005f7a:	744a                	ld	s0,176(sp)
    80005f7c:	74aa                	ld	s1,168(sp)
    80005f7e:	790a                	ld	s2,160(sp)
    80005f80:	69ea                	ld	s3,152(sp)
    80005f82:	6129                	addi	sp,sp,192
    80005f84:	8082                	ret
      end_op();
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	9ae080e7          	jalr	-1618(ra) # 80004934 <end_op>
      return -1;
    80005f8e:	557d                	li	a0,-1
    80005f90:	b7e5                	j	80005f78 <sys_open+0xe4>
    if ((ip = namei(path)) == 0)
    80005f92:	f5040513          	addi	a0,s0,-176
    80005f96:	ffffe097          	auipc	ra,0xffffe
    80005f9a:	700080e7          	jalr	1792(ra) # 80004696 <namei>
    80005f9e:	84aa                	mv	s1,a0
    80005fa0:	c905                	beqz	a0,80005fd0 <sys_open+0x13c>
    ilock(ip);
    80005fa2:	ffffe097          	auipc	ra,0xffffe
    80005fa6:	f48080e7          	jalr	-184(ra) # 80003eea <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY)
    80005faa:	04449703          	lh	a4,68(s1)
    80005fae:	4785                	li	a5,1
    80005fb0:	f4f711e3          	bne	a4,a5,80005ef2 <sys_open+0x5e>
    80005fb4:	f4c42783          	lw	a5,-180(s0)
    80005fb8:	d7b9                	beqz	a5,80005f06 <sys_open+0x72>
      iunlockput(ip);
    80005fba:	8526                	mv	a0,s1
    80005fbc:	ffffe097          	auipc	ra,0xffffe
    80005fc0:	190080e7          	jalr	400(ra) # 8000414c <iunlockput>
      end_op();
    80005fc4:	fffff097          	auipc	ra,0xfffff
    80005fc8:	970080e7          	jalr	-1680(ra) # 80004934 <end_op>
      return -1;
    80005fcc:	557d                	li	a0,-1
    80005fce:	b76d                	j	80005f78 <sys_open+0xe4>
      end_op();
    80005fd0:	fffff097          	auipc	ra,0xfffff
    80005fd4:	964080e7          	jalr	-1692(ra) # 80004934 <end_op>
      return -1;
    80005fd8:	557d                	li	a0,-1
    80005fda:	bf79                	j	80005f78 <sys_open+0xe4>
    iunlockput(ip);
    80005fdc:	8526                	mv	a0,s1
    80005fde:	ffffe097          	auipc	ra,0xffffe
    80005fe2:	16e080e7          	jalr	366(ra) # 8000414c <iunlockput>
    end_op();
    80005fe6:	fffff097          	auipc	ra,0xfffff
    80005fea:	94e080e7          	jalr	-1714(ra) # 80004934 <end_op>
    return -1;
    80005fee:	557d                	li	a0,-1
    80005ff0:	b761                	j	80005f78 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ff2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ff6:	04649783          	lh	a5,70(s1)
    80005ffa:	02f99223          	sh	a5,36(s3)
    80005ffe:	bf25                	j	80005f36 <sys_open+0xa2>
    itrunc(ip);
    80006000:	8526                	mv	a0,s1
    80006002:	ffffe097          	auipc	ra,0xffffe
    80006006:	ff6080e7          	jalr	-10(ra) # 80003ff8 <itrunc>
    8000600a:	bfa9                	j	80005f64 <sys_open+0xd0>
      fileclose(f);
    8000600c:	854e                	mv	a0,s3
    8000600e:	fffff097          	auipc	ra,0xfffff
    80006012:	d70080e7          	jalr	-656(ra) # 80004d7e <fileclose>
    iunlockput(ip);
    80006016:	8526                	mv	a0,s1
    80006018:	ffffe097          	auipc	ra,0xffffe
    8000601c:	134080e7          	jalr	308(ra) # 8000414c <iunlockput>
    end_op();
    80006020:	fffff097          	auipc	ra,0xfffff
    80006024:	914080e7          	jalr	-1772(ra) # 80004934 <end_op>
    return -1;
    80006028:	557d                	li	a0,-1
    8000602a:	b7b9                	j	80005f78 <sys_open+0xe4>

000000008000602c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000602c:	7175                	addi	sp,sp,-144
    8000602e:	e506                	sd	ra,136(sp)
    80006030:	e122                	sd	s0,128(sp)
    80006032:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006034:	fffff097          	auipc	ra,0xfffff
    80006038:	882080e7          	jalr	-1918(ra) # 800048b6 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
    8000603c:	08000613          	li	a2,128
    80006040:	f7040593          	addi	a1,s0,-144
    80006044:	4501                	li	a0,0
    80006046:	ffffd097          	auipc	ra,0xffffd
    8000604a:	112080e7          	jalr	274(ra) # 80003158 <argstr>
    8000604e:	02054963          	bltz	a0,80006080 <sys_mkdir+0x54>
    80006052:	4681                	li	a3,0
    80006054:	4601                	li	a2,0
    80006056:	4585                	li	a1,1
    80006058:	f7040513          	addi	a0,s0,-144
    8000605c:	fffff097          	auipc	ra,0xfffff
    80006060:	7fc080e7          	jalr	2044(ra) # 80005858 <create>
    80006064:	cd11                	beqz	a0,80006080 <sys_mkdir+0x54>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006066:	ffffe097          	auipc	ra,0xffffe
    8000606a:	0e6080e7          	jalr	230(ra) # 8000414c <iunlockput>
  end_op();
    8000606e:	fffff097          	auipc	ra,0xfffff
    80006072:	8c6080e7          	jalr	-1850(ra) # 80004934 <end_op>
  return 0;
    80006076:	4501                	li	a0,0
}
    80006078:	60aa                	ld	ra,136(sp)
    8000607a:	640a                	ld	s0,128(sp)
    8000607c:	6149                	addi	sp,sp,144
    8000607e:	8082                	ret
    end_op();
    80006080:	fffff097          	auipc	ra,0xfffff
    80006084:	8b4080e7          	jalr	-1868(ra) # 80004934 <end_op>
    return -1;
    80006088:	557d                	li	a0,-1
    8000608a:	b7fd                	j	80006078 <sys_mkdir+0x4c>

000000008000608c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000608c:	7135                	addi	sp,sp,-160
    8000608e:	ed06                	sd	ra,152(sp)
    80006090:	e922                	sd	s0,144(sp)
    80006092:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006094:	fffff097          	auipc	ra,0xfffff
    80006098:	822080e7          	jalr	-2014(ra) # 800048b6 <begin_op>
  argint(1, &major);
    8000609c:	f6c40593          	addi	a1,s0,-148
    800060a0:	4505                	li	a0,1
    800060a2:	ffffd097          	auipc	ra,0xffffd
    800060a6:	076080e7          	jalr	118(ra) # 80003118 <argint>
  argint(2, &minor);
    800060aa:	f6840593          	addi	a1,s0,-152
    800060ae:	4509                	li	a0,2
    800060b0:	ffffd097          	auipc	ra,0xffffd
    800060b4:	068080e7          	jalr	104(ra) # 80003118 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800060b8:	08000613          	li	a2,128
    800060bc:	f7040593          	addi	a1,s0,-144
    800060c0:	4501                	li	a0,0
    800060c2:	ffffd097          	auipc	ra,0xffffd
    800060c6:	096080e7          	jalr	150(ra) # 80003158 <argstr>
    800060ca:	02054b63          	bltz	a0,80006100 <sys_mknod+0x74>
      (ip = create(path, T_DEVICE, major, minor)) == 0)
    800060ce:	f6841683          	lh	a3,-152(s0)
    800060d2:	f6c41603          	lh	a2,-148(s0)
    800060d6:	458d                	li	a1,3
    800060d8:	f7040513          	addi	a0,s0,-144
    800060dc:	fffff097          	auipc	ra,0xfffff
    800060e0:	77c080e7          	jalr	1916(ra) # 80005858 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800060e4:	cd11                	beqz	a0,80006100 <sys_mknod+0x74>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060e6:	ffffe097          	auipc	ra,0xffffe
    800060ea:	066080e7          	jalr	102(ra) # 8000414c <iunlockput>
  end_op();
    800060ee:	fffff097          	auipc	ra,0xfffff
    800060f2:	846080e7          	jalr	-1978(ra) # 80004934 <end_op>
  return 0;
    800060f6:	4501                	li	a0,0
}
    800060f8:	60ea                	ld	ra,152(sp)
    800060fa:	644a                	ld	s0,144(sp)
    800060fc:	610d                	addi	sp,sp,160
    800060fe:	8082                	ret
    end_op();
    80006100:	fffff097          	auipc	ra,0xfffff
    80006104:	834080e7          	jalr	-1996(ra) # 80004934 <end_op>
    return -1;
    80006108:	557d                	li	a0,-1
    8000610a:	b7fd                	j	800060f8 <sys_mknod+0x6c>

000000008000610c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000610c:	7135                	addi	sp,sp,-160
    8000610e:	ed06                	sd	ra,152(sp)
    80006110:	e922                	sd	s0,144(sp)
    80006112:	e526                	sd	s1,136(sp)
    80006114:	e14a                	sd	s2,128(sp)
    80006116:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006118:	ffffc097          	auipc	ra,0xffffc
    8000611c:	a62080e7          	jalr	-1438(ra) # 80001b7a <myproc>
    80006120:	892a                	mv	s2,a0

  begin_op();
    80006122:	ffffe097          	auipc	ra,0xffffe
    80006126:	794080e7          	jalr	1940(ra) # 800048b6 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0)
    8000612a:	08000613          	li	a2,128
    8000612e:	f6040593          	addi	a1,s0,-160
    80006132:	4501                	li	a0,0
    80006134:	ffffd097          	auipc	ra,0xffffd
    80006138:	024080e7          	jalr	36(ra) # 80003158 <argstr>
    8000613c:	04054b63          	bltz	a0,80006192 <sys_chdir+0x86>
    80006140:	f6040513          	addi	a0,s0,-160
    80006144:	ffffe097          	auipc	ra,0xffffe
    80006148:	552080e7          	jalr	1362(ra) # 80004696 <namei>
    8000614c:	84aa                	mv	s1,a0
    8000614e:	c131                	beqz	a0,80006192 <sys_chdir+0x86>
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80006150:	ffffe097          	auipc	ra,0xffffe
    80006154:	d9a080e7          	jalr	-614(ra) # 80003eea <ilock>
  if (ip->type != T_DIR)
    80006158:	04449703          	lh	a4,68(s1)
    8000615c:	4785                	li	a5,1
    8000615e:	04f71063          	bne	a4,a5,8000619e <sys_chdir+0x92>
  {
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006162:	8526                	mv	a0,s1
    80006164:	ffffe097          	auipc	ra,0xffffe
    80006168:	e48080e7          	jalr	-440(ra) # 80003fac <iunlock>
  iput(p->cwd);
    8000616c:	15093503          	ld	a0,336(s2)
    80006170:	ffffe097          	auipc	ra,0xffffe
    80006174:	f34080e7          	jalr	-204(ra) # 800040a4 <iput>
  end_op();
    80006178:	ffffe097          	auipc	ra,0xffffe
    8000617c:	7bc080e7          	jalr	1980(ra) # 80004934 <end_op>
  p->cwd = ip;
    80006180:	14993823          	sd	s1,336(s2)
  return 0;
    80006184:	4501                	li	a0,0
}
    80006186:	60ea                	ld	ra,152(sp)
    80006188:	644a                	ld	s0,144(sp)
    8000618a:	64aa                	ld	s1,136(sp)
    8000618c:	690a                	ld	s2,128(sp)
    8000618e:	610d                	addi	sp,sp,160
    80006190:	8082                	ret
    end_op();
    80006192:	ffffe097          	auipc	ra,0xffffe
    80006196:	7a2080e7          	jalr	1954(ra) # 80004934 <end_op>
    return -1;
    8000619a:	557d                	li	a0,-1
    8000619c:	b7ed                	j	80006186 <sys_chdir+0x7a>
    iunlockput(ip);
    8000619e:	8526                	mv	a0,s1
    800061a0:	ffffe097          	auipc	ra,0xffffe
    800061a4:	fac080e7          	jalr	-84(ra) # 8000414c <iunlockput>
    end_op();
    800061a8:	ffffe097          	auipc	ra,0xffffe
    800061ac:	78c080e7          	jalr	1932(ra) # 80004934 <end_op>
    return -1;
    800061b0:	557d                	li	a0,-1
    800061b2:	bfd1                	j	80006186 <sys_chdir+0x7a>

00000000800061b4 <sys_exec>:

uint64
sys_exec(void)
{
    800061b4:	7145                	addi	sp,sp,-464
    800061b6:	e786                	sd	ra,456(sp)
    800061b8:	e3a2                	sd	s0,448(sp)
    800061ba:	ff26                	sd	s1,440(sp)
    800061bc:	fb4a                	sd	s2,432(sp)
    800061be:	f74e                	sd	s3,424(sp)
    800061c0:	f352                	sd	s4,416(sp)
    800061c2:	ef56                	sd	s5,408(sp)
    800061c4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800061c6:	e3840593          	addi	a1,s0,-456
    800061ca:	4505                	li	a0,1
    800061cc:	ffffd097          	auipc	ra,0xffffd
    800061d0:	f6c080e7          	jalr	-148(ra) # 80003138 <argaddr>
  if (argstr(0, path, MAXPATH) < 0)
    800061d4:	08000613          	li	a2,128
    800061d8:	f4040593          	addi	a1,s0,-192
    800061dc:	4501                	li	a0,0
    800061de:	ffffd097          	auipc	ra,0xffffd
    800061e2:	f7a080e7          	jalr	-134(ra) # 80003158 <argstr>
    800061e6:	87aa                	mv	a5,a0
  {
    return -1;
    800061e8:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0)
    800061ea:	0c07c363          	bltz	a5,800062b0 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800061ee:	10000613          	li	a2,256
    800061f2:	4581                	li	a1,0
    800061f4:	e4040513          	addi	a0,s0,-448
    800061f8:	ffffb097          	auipc	ra,0xffffb
    800061fc:	c4e080e7          	jalr	-946(ra) # 80000e46 <memset>
  for (i = 0;; i++)
  {
    if (i >= NELEM(argv))
    80006200:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006204:	89a6                	mv	s3,s1
    80006206:	4901                	li	s2,0
    if (i >= NELEM(argv))
    80006208:	02000a13          	li	s4,32
    8000620c:	00090a9b          	sext.w	s5,s2
    {
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0)
    80006210:	00391513          	slli	a0,s2,0x3
    80006214:	e3040593          	addi	a1,s0,-464
    80006218:	e3843783          	ld	a5,-456(s0)
    8000621c:	953e                	add	a0,a0,a5
    8000621e:	ffffd097          	auipc	ra,0xffffd
    80006222:	e5c080e7          	jalr	-420(ra) # 8000307a <fetchaddr>
    80006226:	02054a63          	bltz	a0,8000625a <sys_exec+0xa6>
    {
      goto bad;
    }
    if (uarg == 0)
    8000622a:	e3043783          	ld	a5,-464(s0)
    8000622e:	c3b9                	beqz	a5,80006274 <sys_exec+0xc0>
    {
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006230:	ffffb097          	auipc	ra,0xffffb
    80006234:	a20080e7          	jalr	-1504(ra) # 80000c50 <kalloc>
    80006238:	85aa                	mv	a1,a0
    8000623a:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000623e:	cd11                	beqz	a0,8000625a <sys_exec+0xa6>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006240:	6605                	lui	a2,0x1
    80006242:	e3043503          	ld	a0,-464(s0)
    80006246:	ffffd097          	auipc	ra,0xffffd
    8000624a:	e86080e7          	jalr	-378(ra) # 800030cc <fetchstr>
    8000624e:	00054663          	bltz	a0,8000625a <sys_exec+0xa6>
    if (i >= NELEM(argv))
    80006252:	0905                	addi	s2,s2,1
    80006254:	09a1                	addi	s3,s3,8
    80006256:	fb491be3          	bne	s2,s4,8000620c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000625a:	f4040913          	addi	s2,s0,-192
    8000625e:	6088                	ld	a0,0(s1)
    80006260:	c539                	beqz	a0,800062ae <sys_exec+0xfa>
    kfree(argv[i]);
    80006262:	ffffb097          	auipc	ra,0xffffb
    80006266:	816080e7          	jalr	-2026(ra) # 80000a78 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000626a:	04a1                	addi	s1,s1,8
    8000626c:	ff2499e3          	bne	s1,s2,8000625e <sys_exec+0xaa>
  return -1;
    80006270:	557d                	li	a0,-1
    80006272:	a83d                	j	800062b0 <sys_exec+0xfc>
      argv[i] = 0;
    80006274:	0a8e                	slli	s5,s5,0x3
    80006276:	fc0a8793          	addi	a5,s5,-64
    8000627a:	00878ab3          	add	s5,a5,s0
    8000627e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006282:	e4040593          	addi	a1,s0,-448
    80006286:	f4040513          	addi	a0,s0,-192
    8000628a:	fffff097          	auipc	ra,0xfffff
    8000628e:	16e080e7          	jalr	366(ra) # 800053f8 <exec>
    80006292:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006294:	f4040993          	addi	s3,s0,-192
    80006298:	6088                	ld	a0,0(s1)
    8000629a:	c901                	beqz	a0,800062aa <sys_exec+0xf6>
    kfree(argv[i]);
    8000629c:	ffffa097          	auipc	ra,0xffffa
    800062a0:	7dc080e7          	jalr	2012(ra) # 80000a78 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062a4:	04a1                	addi	s1,s1,8
    800062a6:	ff3499e3          	bne	s1,s3,80006298 <sys_exec+0xe4>
  return ret;
    800062aa:	854a                	mv	a0,s2
    800062ac:	a011                	j	800062b0 <sys_exec+0xfc>
  return -1;
    800062ae:	557d                	li	a0,-1
}
    800062b0:	60be                	ld	ra,456(sp)
    800062b2:	641e                	ld	s0,448(sp)
    800062b4:	74fa                	ld	s1,440(sp)
    800062b6:	795a                	ld	s2,432(sp)
    800062b8:	79ba                	ld	s3,424(sp)
    800062ba:	7a1a                	ld	s4,416(sp)
    800062bc:	6afa                	ld	s5,408(sp)
    800062be:	6179                	addi	sp,sp,464
    800062c0:	8082                	ret

00000000800062c2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800062c2:	7139                	addi	sp,sp,-64
    800062c4:	fc06                	sd	ra,56(sp)
    800062c6:	f822                	sd	s0,48(sp)
    800062c8:	f426                	sd	s1,40(sp)
    800062ca:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800062cc:	ffffc097          	auipc	ra,0xffffc
    800062d0:	8ae080e7          	jalr	-1874(ra) # 80001b7a <myproc>
    800062d4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800062d6:	fd840593          	addi	a1,s0,-40
    800062da:	4501                	li	a0,0
    800062dc:	ffffd097          	auipc	ra,0xffffd
    800062e0:	e5c080e7          	jalr	-420(ra) # 80003138 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800062e4:	fc840593          	addi	a1,s0,-56
    800062e8:	fd040513          	addi	a0,s0,-48
    800062ec:	fffff097          	auipc	ra,0xfffff
    800062f0:	dc2080e7          	jalr	-574(ra) # 800050ae <pipealloc>
    return -1;
    800062f4:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800062f6:	0c054463          	bltz	a0,800063be <sys_pipe+0xfc>
  fd0 = -1;
    800062fa:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0)
    800062fe:	fd043503          	ld	a0,-48(s0)
    80006302:	fffff097          	auipc	ra,0xfffff
    80006306:	514080e7          	jalr	1300(ra) # 80005816 <fdalloc>
    8000630a:	fca42223          	sw	a0,-60(s0)
    8000630e:	08054b63          	bltz	a0,800063a4 <sys_pipe+0xe2>
    80006312:	fc843503          	ld	a0,-56(s0)
    80006316:	fffff097          	auipc	ra,0xfffff
    8000631a:	500080e7          	jalr	1280(ra) # 80005816 <fdalloc>
    8000631e:	fca42023          	sw	a0,-64(s0)
    80006322:	06054863          	bltz	a0,80006392 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80006326:	4691                	li	a3,4
    80006328:	fc440613          	addi	a2,s0,-60
    8000632c:	fd843583          	ld	a1,-40(s0)
    80006330:	68a8                	ld	a0,80(s1)
    80006332:	ffffb097          	auipc	ra,0xffffb
    80006336:	4cc080e7          	jalr	1228(ra) # 800017fe <copyout>
    8000633a:	02054063          	bltz	a0,8000635a <sys_pipe+0x98>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0)
    8000633e:	4691                	li	a3,4
    80006340:	fc040613          	addi	a2,s0,-64
    80006344:	fd843583          	ld	a1,-40(s0)
    80006348:	0591                	addi	a1,a1,4
    8000634a:	68a8                	ld	a0,80(s1)
    8000634c:	ffffb097          	auipc	ra,0xffffb
    80006350:	4b2080e7          	jalr	1202(ra) # 800017fe <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006354:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80006356:	06055463          	bgez	a0,800063be <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000635a:	fc442783          	lw	a5,-60(s0)
    8000635e:	07e9                	addi	a5,a5,26
    80006360:	078e                	slli	a5,a5,0x3
    80006362:	97a6                	add	a5,a5,s1
    80006364:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006368:	fc042783          	lw	a5,-64(s0)
    8000636c:	07e9                	addi	a5,a5,26
    8000636e:	078e                	slli	a5,a5,0x3
    80006370:	94be                	add	s1,s1,a5
    80006372:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006376:	fd043503          	ld	a0,-48(s0)
    8000637a:	fffff097          	auipc	ra,0xfffff
    8000637e:	a04080e7          	jalr	-1532(ra) # 80004d7e <fileclose>
    fileclose(wf);
    80006382:	fc843503          	ld	a0,-56(s0)
    80006386:	fffff097          	auipc	ra,0xfffff
    8000638a:	9f8080e7          	jalr	-1544(ra) # 80004d7e <fileclose>
    return -1;
    8000638e:	57fd                	li	a5,-1
    80006390:	a03d                	j	800063be <sys_pipe+0xfc>
    if (fd0 >= 0)
    80006392:	fc442783          	lw	a5,-60(s0)
    80006396:	0007c763          	bltz	a5,800063a4 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000639a:	07e9                	addi	a5,a5,26
    8000639c:	078e                	slli	a5,a5,0x3
    8000639e:	97a6                	add	a5,a5,s1
    800063a0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800063a4:	fd043503          	ld	a0,-48(s0)
    800063a8:	fffff097          	auipc	ra,0xfffff
    800063ac:	9d6080e7          	jalr	-1578(ra) # 80004d7e <fileclose>
    fileclose(wf);
    800063b0:	fc843503          	ld	a0,-56(s0)
    800063b4:	fffff097          	auipc	ra,0xfffff
    800063b8:	9ca080e7          	jalr	-1590(ra) # 80004d7e <fileclose>
    return -1;
    800063bc:	57fd                	li	a5,-1
}
    800063be:	853e                	mv	a0,a5
    800063c0:	70e2                	ld	ra,56(sp)
    800063c2:	7442                	ld	s0,48(sp)
    800063c4:	74a2                	ld	s1,40(sp)
    800063c6:	6121                	addi	sp,sp,64
    800063c8:	8082                	ret
    800063ca:	0000                	unimp
    800063cc:	0000                	unimp
	...

00000000800063d0 <kernelvec>:
    800063d0:	7111                	addi	sp,sp,-256
    800063d2:	e006                	sd	ra,0(sp)
    800063d4:	e40a                	sd	sp,8(sp)
    800063d6:	e80e                	sd	gp,16(sp)
    800063d8:	ec12                	sd	tp,24(sp)
    800063da:	f016                	sd	t0,32(sp)
    800063dc:	f41a                	sd	t1,40(sp)
    800063de:	f81e                	sd	t2,48(sp)
    800063e0:	fc22                	sd	s0,56(sp)
    800063e2:	e0a6                	sd	s1,64(sp)
    800063e4:	e4aa                	sd	a0,72(sp)
    800063e6:	e8ae                	sd	a1,80(sp)
    800063e8:	ecb2                	sd	a2,88(sp)
    800063ea:	f0b6                	sd	a3,96(sp)
    800063ec:	f4ba                	sd	a4,104(sp)
    800063ee:	f8be                	sd	a5,112(sp)
    800063f0:	fcc2                	sd	a6,120(sp)
    800063f2:	e146                	sd	a7,128(sp)
    800063f4:	e54a                	sd	s2,136(sp)
    800063f6:	e94e                	sd	s3,144(sp)
    800063f8:	ed52                	sd	s4,152(sp)
    800063fa:	f156                	sd	s5,160(sp)
    800063fc:	f55a                	sd	s6,168(sp)
    800063fe:	f95e                	sd	s7,176(sp)
    80006400:	fd62                	sd	s8,184(sp)
    80006402:	e1e6                	sd	s9,192(sp)
    80006404:	e5ea                	sd	s10,200(sp)
    80006406:	e9ee                	sd	s11,208(sp)
    80006408:	edf2                	sd	t3,216(sp)
    8000640a:	f1f6                	sd	t4,224(sp)
    8000640c:	f5fa                	sd	t5,232(sp)
    8000640e:	f9fe                	sd	t6,240(sp)
    80006410:	8f9fc0ef          	jal	ra,80002d08 <kerneltrap>
    80006414:	6082                	ld	ra,0(sp)
    80006416:	6122                	ld	sp,8(sp)
    80006418:	61c2                	ld	gp,16(sp)
    8000641a:	7282                	ld	t0,32(sp)
    8000641c:	7322                	ld	t1,40(sp)
    8000641e:	73c2                	ld	t2,48(sp)
    80006420:	7462                	ld	s0,56(sp)
    80006422:	6486                	ld	s1,64(sp)
    80006424:	6526                	ld	a0,72(sp)
    80006426:	65c6                	ld	a1,80(sp)
    80006428:	6666                	ld	a2,88(sp)
    8000642a:	7686                	ld	a3,96(sp)
    8000642c:	7726                	ld	a4,104(sp)
    8000642e:	77c6                	ld	a5,112(sp)
    80006430:	7866                	ld	a6,120(sp)
    80006432:	688a                	ld	a7,128(sp)
    80006434:	692a                	ld	s2,136(sp)
    80006436:	69ca                	ld	s3,144(sp)
    80006438:	6a6a                	ld	s4,152(sp)
    8000643a:	7a8a                	ld	s5,160(sp)
    8000643c:	7b2a                	ld	s6,168(sp)
    8000643e:	7bca                	ld	s7,176(sp)
    80006440:	7c6a                	ld	s8,184(sp)
    80006442:	6c8e                	ld	s9,192(sp)
    80006444:	6d2e                	ld	s10,200(sp)
    80006446:	6dce                	ld	s11,208(sp)
    80006448:	6e6e                	ld	t3,216(sp)
    8000644a:	7e8e                	ld	t4,224(sp)
    8000644c:	7f2e                	ld	t5,232(sp)
    8000644e:	7fce                	ld	t6,240(sp)
    80006450:	6111                	addi	sp,sp,256
    80006452:	10200073          	sret
    80006456:	00000013          	nop
    8000645a:	00000013          	nop
    8000645e:	0001                	nop

0000000080006460 <timervec>:
    80006460:	34051573          	csrrw	a0,mscratch,a0
    80006464:	e10c                	sd	a1,0(a0)
    80006466:	e510                	sd	a2,8(a0)
    80006468:	e914                	sd	a3,16(a0)
    8000646a:	6d0c                	ld	a1,24(a0)
    8000646c:	7110                	ld	a2,32(a0)
    8000646e:	6194                	ld	a3,0(a1)
    80006470:	96b2                	add	a3,a3,a2
    80006472:	e194                	sd	a3,0(a1)
    80006474:	4589                	li	a1,2
    80006476:	14459073          	csrw	sip,a1
    8000647a:	6914                	ld	a3,16(a0)
    8000647c:	6510                	ld	a2,8(a0)
    8000647e:	610c                	ld	a1,0(a0)
    80006480:	34051573          	csrrw	a0,mscratch,a0
    80006484:	30200073          	mret
	...

000000008000648a <plicinit>:
//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void)
{
    8000648a:	1141                	addi	sp,sp,-16
    8000648c:	e422                	sd	s0,8(sp)
    8000648e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80006490:	0c0007b7          	lui	a5,0xc000
    80006494:	4705                	li	a4,1
    80006496:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80006498:	c3d8                	sw	a4,4(a5)
}
    8000649a:	6422                	ld	s0,8(sp)
    8000649c:	0141                	addi	sp,sp,16
    8000649e:	8082                	ret

00000000800064a0 <plicinithart>:

void plicinithart(void)
{
    800064a0:	1141                	addi	sp,sp,-16
    800064a2:	e406                	sd	ra,8(sp)
    800064a4:	e022                	sd	s0,0(sp)
    800064a6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064a8:	ffffb097          	auipc	ra,0xffffb
    800064ac:	6a6080e7          	jalr	1702(ra) # 80001b4e <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800064b0:	0085171b          	slliw	a4,a0,0x8
    800064b4:	0c0027b7          	lui	a5,0xc002
    800064b8:	97ba                	add	a5,a5,a4
    800064ba:	40200713          	li	a4,1026
    800064be:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    800064c2:	00d5151b          	slliw	a0,a0,0xd
    800064c6:	0c2017b7          	lui	a5,0xc201
    800064ca:	97aa                	add	a5,a5,a0
    800064cc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800064d0:	60a2                	ld	ra,8(sp)
    800064d2:	6402                	ld	s0,0(sp)
    800064d4:	0141                	addi	sp,sp,16
    800064d6:	8082                	ret

00000000800064d8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void)
{
    800064d8:	1141                	addi	sp,sp,-16
    800064da:	e406                	sd	ra,8(sp)
    800064dc:	e022                	sd	s0,0(sp)
    800064de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064e0:	ffffb097          	auipc	ra,0xffffb
    800064e4:	66e080e7          	jalr	1646(ra) # 80001b4e <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    800064e8:	00d5151b          	slliw	a0,a0,0xd
    800064ec:	0c2017b7          	lui	a5,0xc201
    800064f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800064f2:	43c8                	lw	a0,4(a5)
    800064f4:	60a2                	ld	ra,8(sp)
    800064f6:	6402                	ld	s0,0(sp)
    800064f8:	0141                	addi	sp,sp,16
    800064fa:	8082                	ret

00000000800064fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq)
{
    800064fc:	1101                	addi	sp,sp,-32
    800064fe:	ec06                	sd	ra,24(sp)
    80006500:	e822                	sd	s0,16(sp)
    80006502:	e426                	sd	s1,8(sp)
    80006504:	1000                	addi	s0,sp,32
    80006506:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006508:	ffffb097          	auipc	ra,0xffffb
    8000650c:	646080e7          	jalr	1606(ra) # 80001b4e <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80006510:	00d5151b          	slliw	a0,a0,0xd
    80006514:	0c2017b7          	lui	a5,0xc201
    80006518:	97aa                	add	a5,a5,a0
    8000651a:	c3c4                	sw	s1,4(a5)
}
    8000651c:	60e2                	ld	ra,24(sp)
    8000651e:	6442                	ld	s0,16(sp)
    80006520:	64a2                	ld	s1,8(sp)
    80006522:	6105                	addi	sp,sp,32
    80006524:	8082                	ret

0000000080006526 <sgenrand>:
static unsigned long mt[N]; /* the array for the state vector  */
static int mti = N + 1;     /* mti==N+1 means mt[N] is not initialized */

/* initializing the array with a NONZERO seed */
void sgenrand(unsigned long seed)
{
    80006526:	1141                	addi	sp,sp,-16
    80006528:	e422                	sd	s0,8(sp)
    8000652a:	0800                	addi	s0,sp,16
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0] = seed & 0xffffffff;
    8000652c:	0023e717          	auipc	a4,0x23e
    80006530:	be470713          	addi	a4,a4,-1052 # 80244110 <mt>
    80006534:	1502                	slli	a0,a0,0x20
    80006536:	9101                	srli	a0,a0,0x20
    80006538:	e308                	sd	a0,0(a4)
    for (mti = 1; mti < N; mti++)
    8000653a:	0023f597          	auipc	a1,0x23f
    8000653e:	f4e58593          	addi	a1,a1,-178 # 80245488 <mt+0x1378>
        mt[mti] = (69069 * mt[mti - 1]) & 0xffffffff;
    80006542:	6645                	lui	a2,0x11
    80006544:	dcd60613          	addi	a2,a2,-563 # 10dcd <_entry-0x7ffef233>
    80006548:	56fd                	li	a3,-1
    8000654a:	9281                	srli	a3,a3,0x20
    8000654c:	631c                	ld	a5,0(a4)
    8000654e:	02c787b3          	mul	a5,a5,a2
    80006552:	8ff5                	and	a5,a5,a3
    80006554:	e71c                	sd	a5,8(a4)
    for (mti = 1; mti < N; mti++)
    80006556:	0721                	addi	a4,a4,8
    80006558:	feb71ae3          	bne	a4,a1,8000654c <sgenrand+0x26>
    8000655c:	27000793          	li	a5,624
    80006560:	00002717          	auipc	a4,0x2
    80006564:	4af72c23          	sw	a5,1208(a4) # 80008a18 <mti>
}
    80006568:	6422                	ld	s0,8(sp)
    8000656a:	0141                	addi	sp,sp,16
    8000656c:	8082                	ret

000000008000656e <genrand>:

long /* for integer generation */
genrand()
{
    8000656e:	1141                	addi	sp,sp,-16
    80006570:	e406                	sd	ra,8(sp)
    80006572:	e022                	sd	s0,0(sp)
    80006574:	0800                	addi	s0,sp,16
    unsigned long y;
    static unsigned long mag01[2] = {0x0, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N)
    80006576:	00002797          	auipc	a5,0x2
    8000657a:	4a27a783          	lw	a5,1186(a5) # 80008a18 <mti>
    8000657e:	26f00713          	li	a4,623
    80006582:	0ef75963          	bge	a4,a5,80006674 <genrand+0x106>
    { /* generate N words at one time */
        int kk;

        if (mti == N + 1)   /* if sgenrand() has not been called, */
    80006586:	27100713          	li	a4,625
    8000658a:	12e78e63          	beq	a5,a4,800066c6 <genrand+0x158>
            sgenrand(4357); /* a default initial seed is used   */

        for (kk = 0; kk < N - M; kk++)
    8000658e:	0023e817          	auipc	a6,0x23e
    80006592:	b8280813          	addi	a6,a6,-1150 # 80244110 <mt>
    80006596:	0023ee17          	auipc	t3,0x23e
    8000659a:	292e0e13          	addi	t3,t3,658 # 80244828 <mt+0x718>
{
    8000659e:	8742                	mv	a4,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800065a0:	4885                	li	a7,1
    800065a2:	08fe                	slli	a7,a7,0x1f
    800065a4:	80000537          	lui	a0,0x80000
    800065a8:	fff54513          	not	a0,a0
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    800065ac:	6585                	lui	a1,0x1
    800065ae:	c6858593          	addi	a1,a1,-920 # c68 <_entry-0x7ffff398>
    800065b2:	00002317          	auipc	t1,0x2
    800065b6:	33e30313          	addi	t1,t1,830 # 800088f0 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800065ba:	631c                	ld	a5,0(a4)
    800065bc:	0117f7b3          	and	a5,a5,a7
    800065c0:	6714                	ld	a3,8(a4)
    800065c2:	8ee9                	and	a3,a3,a0
    800065c4:	8fd5                	or	a5,a5,a3
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    800065c6:	00b70633          	add	a2,a4,a1
    800065ca:	0017d693          	srli	a3,a5,0x1
    800065ce:	6210                	ld	a2,0(a2)
    800065d0:	8eb1                	xor	a3,a3,a2
    800065d2:	8b85                	andi	a5,a5,1
    800065d4:	078e                	slli	a5,a5,0x3
    800065d6:	979a                	add	a5,a5,t1
    800065d8:	639c                	ld	a5,0(a5)
    800065da:	8fb5                	xor	a5,a5,a3
    800065dc:	e31c                	sd	a5,0(a4)
        for (kk = 0; kk < N - M; kk++)
    800065de:	0721                	addi	a4,a4,8
    800065e0:	fdc71de3          	bne	a4,t3,800065ba <genrand+0x4c>
        }
        for (; kk < N - 1; kk++)
    800065e4:	6605                	lui	a2,0x1
    800065e6:	c6060613          	addi	a2,a2,-928 # c60 <_entry-0x7ffff3a0>
    800065ea:	9642                	add	a2,a2,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800065ec:	4505                	li	a0,1
    800065ee:	057e                	slli	a0,a0,0x1f
    800065f0:	800005b7          	lui	a1,0x80000
    800065f4:	fff5c593          	not	a1,a1
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    800065f8:	00002897          	auipc	a7,0x2
    800065fc:	2f888893          	addi	a7,a7,760 # 800088f0 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    80006600:	71883783          	ld	a5,1816(a6)
    80006604:	8fe9                	and	a5,a5,a0
    80006606:	72083703          	ld	a4,1824(a6)
    8000660a:	8f6d                	and	a4,a4,a1
    8000660c:	8fd9                	or	a5,a5,a4
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    8000660e:	0017d713          	srli	a4,a5,0x1
    80006612:	00083683          	ld	a3,0(a6)
    80006616:	8f35                	xor	a4,a4,a3
    80006618:	8b85                	andi	a5,a5,1
    8000661a:	078e                	slli	a5,a5,0x3
    8000661c:	97c6                	add	a5,a5,a7
    8000661e:	639c                	ld	a5,0(a5)
    80006620:	8fb9                	xor	a5,a5,a4
    80006622:	70f83c23          	sd	a5,1816(a6)
        for (; kk < N - 1; kk++)
    80006626:	0821                	addi	a6,a6,8
    80006628:	fcc81ce3          	bne	a6,a2,80006600 <genrand+0x92>
        }
        y = (mt[N - 1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
    8000662c:	0023f697          	auipc	a3,0x23f
    80006630:	ae468693          	addi	a3,a3,-1308 # 80245110 <mt+0x1000>
    80006634:	3786b783          	ld	a5,888(a3)
    80006638:	4705                	li	a4,1
    8000663a:	077e                	slli	a4,a4,0x1f
    8000663c:	8ff9                	and	a5,a5,a4
    8000663e:	0023e717          	auipc	a4,0x23e
    80006642:	ad273703          	ld	a4,-1326(a4) # 80244110 <mt>
    80006646:	1706                	slli	a4,a4,0x21
    80006648:	9305                	srli	a4,a4,0x21
    8000664a:	8fd9                	or	a5,a5,a4
        mt[N - 1] = mt[M - 1] ^ (y >> 1) ^ mag01[y & 0x1];
    8000664c:	0017d713          	srli	a4,a5,0x1
    80006650:	c606b603          	ld	a2,-928(a3)
    80006654:	8f31                	xor	a4,a4,a2
    80006656:	8b85                	andi	a5,a5,1
    80006658:	078e                	slli	a5,a5,0x3
    8000665a:	00002617          	auipc	a2,0x2
    8000665e:	29660613          	addi	a2,a2,662 # 800088f0 <mag01.0>
    80006662:	97b2                	add	a5,a5,a2
    80006664:	639c                	ld	a5,0(a5)
    80006666:	8fb9                	xor	a5,a5,a4
    80006668:	36f6bc23          	sd	a5,888(a3)

        mti = 0;
    8000666c:	00002797          	auipc	a5,0x2
    80006670:	3a07a623          	sw	zero,940(a5) # 80008a18 <mti>
    }

    y = mt[mti++];
    80006674:	00002717          	auipc	a4,0x2
    80006678:	3a470713          	addi	a4,a4,932 # 80008a18 <mti>
    8000667c:	431c                	lw	a5,0(a4)
    8000667e:	0017869b          	addiw	a3,a5,1
    80006682:	c314                	sw	a3,0(a4)
    80006684:	078e                	slli	a5,a5,0x3
    80006686:	0023e717          	auipc	a4,0x23e
    8000668a:	a8a70713          	addi	a4,a4,-1398 # 80244110 <mt>
    8000668e:	97ba                	add	a5,a5,a4
    80006690:	639c                	ld	a5,0(a5)
    y ^= TEMPERING_SHIFT_U(y);
    80006692:	00b7d713          	srli	a4,a5,0xb
    80006696:	8f3d                	xor	a4,a4,a5
    y ^= TEMPERING_SHIFT_S(y) & TEMPERING_MASK_B;
    80006698:	013a67b7          	lui	a5,0x13a6
    8000669c:	8ad78793          	addi	a5,a5,-1875 # 13a58ad <_entry-0x7ec5a753>
    800066a0:	8ff9                	and	a5,a5,a4
    800066a2:	079e                	slli	a5,a5,0x7
    800066a4:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_T(y) & TEMPERING_MASK_C;
    800066a6:	00f79713          	slli	a4,a5,0xf
    800066aa:	077e36b7          	lui	a3,0x77e3
    800066ae:	0696                	slli	a3,a3,0x5
    800066b0:	8f75                	and	a4,a4,a3
    800066b2:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_L(y);
    800066b4:	0127d513          	srli	a0,a5,0x12
    800066b8:	8d3d                	xor	a0,a0,a5

    // Strip off uppermost bit because we want a long,
    // not an unsigned long
    return y & RAND_MAX;
    800066ba:	1506                	slli	a0,a0,0x21
}
    800066bc:	9105                	srli	a0,a0,0x21
    800066be:	60a2                	ld	ra,8(sp)
    800066c0:	6402                	ld	s0,0(sp)
    800066c2:	0141                	addi	sp,sp,16
    800066c4:	8082                	ret
            sgenrand(4357); /* a default initial seed is used   */
    800066c6:	6505                	lui	a0,0x1
    800066c8:	10550513          	addi	a0,a0,261 # 1105 <_entry-0x7fffeefb>
    800066cc:	00000097          	auipc	ra,0x0
    800066d0:	e5a080e7          	jalr	-422(ra) # 80006526 <sgenrand>
    800066d4:	bd6d                	j	8000658e <genrand+0x20>

00000000800066d6 <random_at_most>:

// Assumes 0 <= max <= RAND_MAX
// Returns in the half-open interval [0, max]
long random_at_most(long max)
{
    800066d6:	1101                	addi	sp,sp,-32
    800066d8:	ec06                	sd	ra,24(sp)
    800066da:	e822                	sd	s0,16(sp)
    800066dc:	e426                	sd	s1,8(sp)
    800066de:	e04a                	sd	s2,0(sp)
    800066e0:	1000                	addi	s0,sp,32
    unsigned long
        // max <= RAND_MAX < ULONG_MAX, so this is okay.
        num_bins = (unsigned long)max + 1,
    800066e2:	0505                	addi	a0,a0,1
        num_rand = (unsigned long)RAND_MAX + 1,
        bin_size = num_rand / num_bins,
    800066e4:	4785                	li	a5,1
    800066e6:	07fe                	slli	a5,a5,0x1f
    800066e8:	02a7d933          	divu	s2,a5,a0
        defect = num_rand % num_bins;
    800066ec:	02a7f7b3          	remu	a5,a5,a0
    do
    {
        x = genrand();
    }
    // This is carefully written not to overflow
    while (num_rand - defect <= (unsigned long)x);
    800066f0:	4485                	li	s1,1
    800066f2:	04fe                	slli	s1,s1,0x1f
    800066f4:	8c9d                	sub	s1,s1,a5
        x = genrand();
    800066f6:	00000097          	auipc	ra,0x0
    800066fa:	e78080e7          	jalr	-392(ra) # 8000656e <genrand>
    while (num_rand - defect <= (unsigned long)x);
    800066fe:	fe957ce3          	bgeu	a0,s1,800066f6 <random_at_most+0x20>

    // Truncated division is intentional
    return x / bin_size;
    80006702:	03255533          	divu	a0,a0,s2
    80006706:	60e2                	ld	ra,24(sp)
    80006708:	6442                	ld	s0,16(sp)
    8000670a:	64a2                	ld	s1,8(sp)
    8000670c:	6902                	ld	s2,0(sp)
    8000670e:	6105                	addi	sp,sp,32
    80006710:	8082                	ret

0000000080006712 <popfront>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void popfront(deque *a)
{
    80006712:	1141                	addi	sp,sp,-16
    80006714:	e422                	sd	s0,8(sp)
    80006716:	0800                	addi	s0,sp,16
    for (int i = 0; i < a->end - 1; i++)
    80006718:	20052683          	lw	a3,512(a0)
    8000671c:	fff6861b          	addiw	a2,a3,-1 # 77e2fff <_entry-0x7881d001>
    80006720:	0006079b          	sext.w	a5,a2
    80006724:	cf99                	beqz	a5,80006742 <popfront+0x30>
    80006726:	87aa                	mv	a5,a0
    80006728:	36f9                	addiw	a3,a3,-2
    8000672a:	02069713          	slli	a4,a3,0x20
    8000672e:	01d75693          	srli	a3,a4,0x1d
    80006732:	00850713          	addi	a4,a0,8
    80006736:	96ba                	add	a3,a3,a4
    {
        a->n[i] = a->n[i + 1];
    80006738:	6798                	ld	a4,8(a5)
    8000673a:	e398                	sd	a4,0(a5)
    for (int i = 0; i < a->end - 1; i++)
    8000673c:	07a1                	addi	a5,a5,8
    8000673e:	fed79de3          	bne	a5,a3,80006738 <popfront+0x26>
    }
    a->end--;
    80006742:	20c52023          	sw	a2,512(a0)
    return;
}
    80006746:	6422                	ld	s0,8(sp)
    80006748:	0141                	addi	sp,sp,16
    8000674a:	8082                	ret

000000008000674c <pushback>:
void pushback(deque *a, struct proc *x)
{
    if (a->end == NPROC)
    8000674c:	20052783          	lw	a5,512(a0)
    80006750:	04000713          	li	a4,64
    80006754:	00e78c63          	beq	a5,a4,8000676c <pushback+0x20>
    {
        panic("Error!");
        return;
    }
    a->n[a->end] = x;
    80006758:	02079693          	slli	a3,a5,0x20
    8000675c:	01d6d713          	srli	a4,a3,0x1d
    80006760:	972a                	add	a4,a4,a0
    80006762:	e30c                	sd	a1,0(a4)
    a->end++;
    80006764:	2785                	addiw	a5,a5,1
    80006766:	20f52023          	sw	a5,512(a0)
    8000676a:	8082                	ret
{
    8000676c:	1141                	addi	sp,sp,-16
    8000676e:	e406                	sd	ra,8(sp)
    80006770:	e022                	sd	s0,0(sp)
    80006772:	0800                	addi	s0,sp,16
        panic("Error!");
    80006774:	00002517          	auipc	a0,0x2
    80006778:	18c50513          	addi	a0,a0,396 # 80008900 <mag01.0+0x10>
    8000677c:	ffffa097          	auipc	ra,0xffffa
    80006780:	dc4080e7          	jalr	-572(ra) # 80000540 <panic>

0000000080006784 <front>:
    return;
}
struct proc *front(deque *a)
{
    80006784:	1141                	addi	sp,sp,-16
    80006786:	e422                	sd	s0,8(sp)
    80006788:	0800                	addi	s0,sp,16
    if (a->end == 0)
    8000678a:	20052783          	lw	a5,512(a0)
    8000678e:	c789                	beqz	a5,80006798 <front+0x14>
    {
        return 0;
    }
    return a->n[0];
    80006790:	6108                	ld	a0,0(a0)
}
    80006792:	6422                	ld	s0,8(sp)
    80006794:	0141                	addi	sp,sp,16
    80006796:	8082                	ret
        return 0;
    80006798:	4501                	li	a0,0
    8000679a:	bfe5                	j	80006792 <front+0xe>

000000008000679c <size>:
int size(deque *a)
{
    8000679c:	1141                	addi	sp,sp,-16
    8000679e:	e422                	sd	s0,8(sp)
    800067a0:	0800                	addi	s0,sp,16
    return a->end;
}
    800067a2:	20052503          	lw	a0,512(a0)
    800067a6:	6422                	ld	s0,8(sp)
    800067a8:	0141                	addi	sp,sp,16
    800067aa:	8082                	ret

00000000800067ac <delete>:
void delete (deque *a, uint pid)
{
    800067ac:	1141                	addi	sp,sp,-16
    800067ae:	e422                	sd	s0,8(sp)
    800067b0:	0800                	addi	s0,sp,16
    int flag = 0;
    for (int i = 0; i < a->end; i++)
    800067b2:	20052e03          	lw	t3,512(a0)
    800067b6:	020e0c63          	beqz	t3,800067ee <delete+0x42>
    800067ba:	87aa                	mv	a5,a0
    800067bc:	000e031b          	sext.w	t1,t3
    800067c0:	4701                	li	a4,0
    int flag = 0;
    800067c2:	4881                	li	a7,0
    {
        if (pid == a->n[i]->pid)
        {
            flag = 1;
        }
        if (flag == 1 && i != NPROC)
    800067c4:	04000e93          	li	t4,64
    800067c8:	4805                	li	a6,1
    800067ca:	a811                	j	800067de <delete+0x32>
    800067cc:	88c2                	mv	a7,a6
    800067ce:	01d70463          	beq	a4,t4,800067d6 <delete+0x2a>
        {
            a->n[i] = a->n[i + 1];
    800067d2:	6614                	ld	a3,8(a2)
    800067d4:	e214                	sd	a3,0(a2)
    for (int i = 0; i < a->end; i++)
    800067d6:	2705                	addiw	a4,a4,1
    800067d8:	07a1                	addi	a5,a5,8
    800067da:	00670a63          	beq	a4,t1,800067ee <delete+0x42>
        if (pid == a->n[i]->pid)
    800067de:	863e                	mv	a2,a5
    800067e0:	6394                	ld	a3,0(a5)
    800067e2:	5a94                	lw	a3,48(a3)
    800067e4:	feb684e3          	beq	a3,a1,800067cc <delete+0x20>
        if (flag == 1 && i != NPROC)
    800067e8:	ff0897e3          	bne	a7,a6,800067d6 <delete+0x2a>
    800067ec:	b7c5                	j	800067cc <delete+0x20>
        }
    }
    a->end--;
    800067ee:	3e7d                	addiw	t3,t3,-1
    800067f0:	21c52023          	sw	t3,512(a0)
    return;
    800067f4:	6422                	ld	s0,8(sp)
    800067f6:	0141                	addi	sp,sp,16
    800067f8:	8082                	ret

00000000800067fa <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800067fa:	1141                	addi	sp,sp,-16
    800067fc:	e406                	sd	ra,8(sp)
    800067fe:	e022                	sd	s0,0(sp)
    80006800:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80006802:	479d                	li	a5,7
    80006804:	04a7cc63          	blt	a5,a0,8000685c <free_desc+0x62>
    panic("free_desc 1");
  if (disk.free[i])
    80006808:	0023f797          	auipc	a5,0x23f
    8000680c:	c8878793          	addi	a5,a5,-888 # 80245490 <disk>
    80006810:	97aa                	add	a5,a5,a0
    80006812:	0187c783          	lbu	a5,24(a5)
    80006816:	ebb9                	bnez	a5,8000686c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006818:	00451693          	slli	a3,a0,0x4
    8000681c:	0023f797          	auipc	a5,0x23f
    80006820:	c7478793          	addi	a5,a5,-908 # 80245490 <disk>
    80006824:	6398                	ld	a4,0(a5)
    80006826:	9736                	add	a4,a4,a3
    80006828:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000682c:	6398                	ld	a4,0(a5)
    8000682e:	9736                	add	a4,a4,a3
    80006830:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006834:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006838:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000683c:	97aa                	add	a5,a5,a0
    8000683e:	4705                	li	a4,1
    80006840:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006844:	0023f517          	auipc	a0,0x23f
    80006848:	c6450513          	addi	a0,a0,-924 # 802454a8 <disk+0x18>
    8000684c:	ffffc097          	auipc	ra,0xffffc
    80006850:	c9c080e7          	jalr	-868(ra) # 800024e8 <wakeup>
}
    80006854:	60a2                	ld	ra,8(sp)
    80006856:	6402                	ld	s0,0(sp)
    80006858:	0141                	addi	sp,sp,16
    8000685a:	8082                	ret
    panic("free_desc 1");
    8000685c:	00002517          	auipc	a0,0x2
    80006860:	0ac50513          	addi	a0,a0,172 # 80008908 <mag01.0+0x18>
    80006864:	ffffa097          	auipc	ra,0xffffa
    80006868:	cdc080e7          	jalr	-804(ra) # 80000540 <panic>
    panic("free_desc 2");
    8000686c:	00002517          	auipc	a0,0x2
    80006870:	0ac50513          	addi	a0,a0,172 # 80008918 <mag01.0+0x28>
    80006874:	ffffa097          	auipc	ra,0xffffa
    80006878:	ccc080e7          	jalr	-820(ra) # 80000540 <panic>

000000008000687c <virtio_disk_init>:
{
    8000687c:	1101                	addi	sp,sp,-32
    8000687e:	ec06                	sd	ra,24(sp)
    80006880:	e822                	sd	s0,16(sp)
    80006882:	e426                	sd	s1,8(sp)
    80006884:	e04a                	sd	s2,0(sp)
    80006886:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006888:	00002597          	auipc	a1,0x2
    8000688c:	0a058593          	addi	a1,a1,160 # 80008928 <mag01.0+0x38>
    80006890:	0023f517          	auipc	a0,0x23f
    80006894:	d2850513          	addi	a0,a0,-728 # 802455b8 <disk+0x128>
    80006898:	ffffa097          	auipc	ra,0xffffa
    8000689c:	422080e7          	jalr	1058(ra) # 80000cba <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800068a0:	100017b7          	lui	a5,0x10001
    800068a4:	4398                	lw	a4,0(a5)
    800068a6:	2701                	sext.w	a4,a4
    800068a8:	747277b7          	lui	a5,0x74727
    800068ac:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800068b0:	14f71b63          	bne	a4,a5,80006a06 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800068b4:	100017b7          	lui	a5,0x10001
    800068b8:	43dc                	lw	a5,4(a5)
    800068ba:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800068bc:	4709                	li	a4,2
    800068be:	14e79463          	bne	a5,a4,80006a06 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800068c2:	100017b7          	lui	a5,0x10001
    800068c6:	479c                	lw	a5,8(a5)
    800068c8:	2781                	sext.w	a5,a5
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800068ca:	12e79e63          	bne	a5,a4,80006a06 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551)
    800068ce:	100017b7          	lui	a5,0x10001
    800068d2:	47d8                	lw	a4,12(a5)
    800068d4:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800068d6:	554d47b7          	lui	a5,0x554d4
    800068da:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800068de:	12f71463          	bne	a4,a5,80006a06 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800068e2:	100017b7          	lui	a5,0x10001
    800068e6:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800068ea:	4705                	li	a4,1
    800068ec:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800068ee:	470d                	li	a4,3
    800068f0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800068f2:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800068f4:	c7ffe6b7          	lui	a3,0xc7ffe
    800068f8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db918f>
    800068fc:	8f75                	and	a4,a4,a3
    800068fe:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006900:	472d                	li	a4,11
    80006902:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006904:	5bbc                	lw	a5,112(a5)
    80006906:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000690a:	8ba1                	andi	a5,a5,8
    8000690c:	10078563          	beqz	a5,80006a16 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006910:	100017b7          	lui	a5,0x10001
    80006914:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80006918:	43fc                	lw	a5,68(a5)
    8000691a:	2781                	sext.w	a5,a5
    8000691c:	10079563          	bnez	a5,80006a26 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006920:	100017b7          	lui	a5,0x10001
    80006924:	5bdc                	lw	a5,52(a5)
    80006926:	2781                	sext.w	a5,a5
  if (max == 0)
    80006928:	10078763          	beqz	a5,80006a36 <virtio_disk_init+0x1ba>
  if (max < NUM)
    8000692c:	471d                	li	a4,7
    8000692e:	10f77c63          	bgeu	a4,a5,80006a46 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80006932:	ffffa097          	auipc	ra,0xffffa
    80006936:	31e080e7          	jalr	798(ra) # 80000c50 <kalloc>
    8000693a:	0023f497          	auipc	s1,0x23f
    8000693e:	b5648493          	addi	s1,s1,-1194 # 80245490 <disk>
    80006942:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006944:	ffffa097          	auipc	ra,0xffffa
    80006948:	30c080e7          	jalr	780(ra) # 80000c50 <kalloc>
    8000694c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000694e:	ffffa097          	auipc	ra,0xffffa
    80006952:	302080e7          	jalr	770(ra) # 80000c50 <kalloc>
    80006956:	87aa                	mv	a5,a0
    80006958:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    8000695a:	6088                	ld	a0,0(s1)
    8000695c:	cd6d                	beqz	a0,80006a56 <virtio_disk_init+0x1da>
    8000695e:	0023f717          	auipc	a4,0x23f
    80006962:	b3a73703          	ld	a4,-1222(a4) # 80245498 <disk+0x8>
    80006966:	cb65                	beqz	a4,80006a56 <virtio_disk_init+0x1da>
    80006968:	c7fd                	beqz	a5,80006a56 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    8000696a:	6605                	lui	a2,0x1
    8000696c:	4581                	li	a1,0
    8000696e:	ffffa097          	auipc	ra,0xffffa
    80006972:	4d8080e7          	jalr	1240(ra) # 80000e46 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006976:	0023f497          	auipc	s1,0x23f
    8000697a:	b1a48493          	addi	s1,s1,-1254 # 80245490 <disk>
    8000697e:	6605                	lui	a2,0x1
    80006980:	4581                	li	a1,0
    80006982:	6488                	ld	a0,8(s1)
    80006984:	ffffa097          	auipc	ra,0xffffa
    80006988:	4c2080e7          	jalr	1218(ra) # 80000e46 <memset>
  memset(disk.used, 0, PGSIZE);
    8000698c:	6605                	lui	a2,0x1
    8000698e:	4581                	li	a1,0
    80006990:	6888                	ld	a0,16(s1)
    80006992:	ffffa097          	auipc	ra,0xffffa
    80006996:	4b4080e7          	jalr	1204(ra) # 80000e46 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000699a:	100017b7          	lui	a5,0x10001
    8000699e:	4721                	li	a4,8
    800069a0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800069a2:	4098                	lw	a4,0(s1)
    800069a4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800069a8:	40d8                	lw	a4,4(s1)
    800069aa:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800069ae:	6498                	ld	a4,8(s1)
    800069b0:	0007069b          	sext.w	a3,a4
    800069b4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800069b8:	9701                	srai	a4,a4,0x20
    800069ba:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800069be:	6898                	ld	a4,16(s1)
    800069c0:	0007069b          	sext.w	a3,a4
    800069c4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800069c8:	9701                	srai	a4,a4,0x20
    800069ca:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800069ce:	4705                	li	a4,1
    800069d0:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800069d2:	00e48c23          	sb	a4,24(s1)
    800069d6:	00e48ca3          	sb	a4,25(s1)
    800069da:	00e48d23          	sb	a4,26(s1)
    800069de:	00e48da3          	sb	a4,27(s1)
    800069e2:	00e48e23          	sb	a4,28(s1)
    800069e6:	00e48ea3          	sb	a4,29(s1)
    800069ea:	00e48f23          	sb	a4,30(s1)
    800069ee:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800069f2:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800069f6:	0727a823          	sw	s2,112(a5)
}
    800069fa:	60e2                	ld	ra,24(sp)
    800069fc:	6442                	ld	s0,16(sp)
    800069fe:	64a2                	ld	s1,8(sp)
    80006a00:	6902                	ld	s2,0(sp)
    80006a02:	6105                	addi	sp,sp,32
    80006a04:	8082                	ret
    panic("could not find virtio disk");
    80006a06:	00002517          	auipc	a0,0x2
    80006a0a:	f3250513          	addi	a0,a0,-206 # 80008938 <mag01.0+0x48>
    80006a0e:	ffffa097          	auipc	ra,0xffffa
    80006a12:	b32080e7          	jalr	-1230(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006a16:	00002517          	auipc	a0,0x2
    80006a1a:	f4250513          	addi	a0,a0,-190 # 80008958 <mag01.0+0x68>
    80006a1e:	ffffa097          	auipc	ra,0xffffa
    80006a22:	b22080e7          	jalr	-1246(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006a26:	00002517          	auipc	a0,0x2
    80006a2a:	f5250513          	addi	a0,a0,-174 # 80008978 <mag01.0+0x88>
    80006a2e:	ffffa097          	auipc	ra,0xffffa
    80006a32:	b12080e7          	jalr	-1262(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006a36:	00002517          	auipc	a0,0x2
    80006a3a:	f6250513          	addi	a0,a0,-158 # 80008998 <mag01.0+0xa8>
    80006a3e:	ffffa097          	auipc	ra,0xffffa
    80006a42:	b02080e7          	jalr	-1278(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006a46:	00002517          	auipc	a0,0x2
    80006a4a:	f7250513          	addi	a0,a0,-142 # 800089b8 <mag01.0+0xc8>
    80006a4e:	ffffa097          	auipc	ra,0xffffa
    80006a52:	af2080e7          	jalr	-1294(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006a56:	00002517          	auipc	a0,0x2
    80006a5a:	f8250513          	addi	a0,a0,-126 # 800089d8 <mag01.0+0xe8>
    80006a5e:	ffffa097          	auipc	ra,0xffffa
    80006a62:	ae2080e7          	jalr	-1310(ra) # 80000540 <panic>

0000000080006a66 <virtio_disk_rw>:
  }
  return 0;
}

void virtio_disk_rw(struct buf *b, int write)
{
    80006a66:	7119                	addi	sp,sp,-128
    80006a68:	fc86                	sd	ra,120(sp)
    80006a6a:	f8a2                	sd	s0,112(sp)
    80006a6c:	f4a6                	sd	s1,104(sp)
    80006a6e:	f0ca                	sd	s2,96(sp)
    80006a70:	ecce                	sd	s3,88(sp)
    80006a72:	e8d2                	sd	s4,80(sp)
    80006a74:	e4d6                	sd	s5,72(sp)
    80006a76:	e0da                	sd	s6,64(sp)
    80006a78:	fc5e                	sd	s7,56(sp)
    80006a7a:	f862                	sd	s8,48(sp)
    80006a7c:	f466                	sd	s9,40(sp)
    80006a7e:	f06a                	sd	s10,32(sp)
    80006a80:	ec6e                	sd	s11,24(sp)
    80006a82:	0100                	addi	s0,sp,128
    80006a84:	8aaa                	mv	s5,a0
    80006a86:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006a88:	00c52d03          	lw	s10,12(a0)
    80006a8c:	001d1d1b          	slliw	s10,s10,0x1
    80006a90:	1d02                	slli	s10,s10,0x20
    80006a92:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006a96:	0023f517          	auipc	a0,0x23f
    80006a9a:	b2250513          	addi	a0,a0,-1246 # 802455b8 <disk+0x128>
    80006a9e:	ffffa097          	auipc	ra,0xffffa
    80006aa2:	2ac080e7          	jalr	684(ra) # 80000d4a <acquire>
  for (int i = 0; i < 3; i++)
    80006aa6:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++)
    80006aa8:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006aaa:	0023fb97          	auipc	s7,0x23f
    80006aae:	9e6b8b93          	addi	s7,s7,-1562 # 80245490 <disk>
  for (int i = 0; i < 3; i++)
    80006ab2:	4b0d                	li	s6,3
  {
    if (alloc3_desc(idx) == 0)
    {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006ab4:	0023fc97          	auipc	s9,0x23f
    80006ab8:	b04c8c93          	addi	s9,s9,-1276 # 802455b8 <disk+0x128>
    80006abc:	a08d                	j	80006b1e <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006abe:	00fb8733          	add	a4,s7,a5
    80006ac2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006ac6:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0)
    80006ac8:	0207c563          	bltz	a5,80006af2 <virtio_disk_rw+0x8c>
  for (int i = 0; i < 3; i++)
    80006acc:	2905                	addiw	s2,s2,1
    80006ace:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006ad0:	05690c63          	beq	s2,s6,80006b28 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006ad4:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++)
    80006ad6:	0023f717          	auipc	a4,0x23f
    80006ada:	9ba70713          	addi	a4,a4,-1606 # 80245490 <disk>
    80006ade:	87ce                	mv	a5,s3
    if (disk.free[i])
    80006ae0:	01874683          	lbu	a3,24(a4)
    80006ae4:	fee9                	bnez	a3,80006abe <virtio_disk_rw+0x58>
  for (int i = 0; i < NUM; i++)
    80006ae6:	2785                	addiw	a5,a5,1
    80006ae8:	0705                	addi	a4,a4,1
    80006aea:	fe979be3          	bne	a5,s1,80006ae0 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006aee:	57fd                	li	a5,-1
    80006af0:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80006af2:	01205d63          	blez	s2,80006b0c <virtio_disk_rw+0xa6>
    80006af6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006af8:	000a2503          	lw	a0,0(s4)
    80006afc:	00000097          	auipc	ra,0x0
    80006b00:	cfe080e7          	jalr	-770(ra) # 800067fa <free_desc>
      for (int j = 0; j < i; j++)
    80006b04:	2d85                	addiw	s11,s11,1
    80006b06:	0a11                	addi	s4,s4,4
    80006b08:	ff2d98e3          	bne	s11,s2,80006af8 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006b0c:	85e6                	mv	a1,s9
    80006b0e:	0023f517          	auipc	a0,0x23f
    80006b12:	99a50513          	addi	a0,a0,-1638 # 802454a8 <disk+0x18>
    80006b16:	ffffc097          	auipc	ra,0xffffc
    80006b1a:	816080e7          	jalr	-2026(ra) # 8000232c <sleep>
  for (int i = 0; i < 3; i++)
    80006b1e:	f8040a13          	addi	s4,s0,-128
{
    80006b22:	8652                	mv	a2,s4
  for (int i = 0; i < 3; i++)
    80006b24:	894e                	mv	s2,s3
    80006b26:	b77d                	j	80006ad4 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006b28:	f8042503          	lw	a0,-128(s0)
    80006b2c:	00a50713          	addi	a4,a0,10
    80006b30:	0712                	slli	a4,a4,0x4

  if (write)
    80006b32:	0023f797          	auipc	a5,0x23f
    80006b36:	95e78793          	addi	a5,a5,-1698 # 80245490 <disk>
    80006b3a:	00e786b3          	add	a3,a5,a4
    80006b3e:	01803633          	snez	a2,s8
    80006b42:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006b44:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006b48:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80006b4c:	f6070613          	addi	a2,a4,-160
    80006b50:	6394                	ld	a3,0(a5)
    80006b52:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006b54:	00870593          	addi	a1,a4,8
    80006b58:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80006b5a:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006b5c:	0007b803          	ld	a6,0(a5)
    80006b60:	9642                	add	a2,a2,a6
    80006b62:	46c1                	li	a3,16
    80006b64:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006b66:	4585                	li	a1,1
    80006b68:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006b6c:	f8442683          	lw	a3,-124(s0)
    80006b70:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80006b74:	0692                	slli	a3,a3,0x4
    80006b76:	9836                	add	a6,a6,a3
    80006b78:	058a8613          	addi	a2,s5,88
    80006b7c:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006b80:	0007b803          	ld	a6,0(a5)
    80006b84:	96c2                	add	a3,a3,a6
    80006b86:	40000613          	li	a2,1024
    80006b8a:	c690                	sw	a2,8(a3)
  if (write)
    80006b8c:	001c3613          	seqz	a2,s8
    80006b90:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006b94:	00166613          	ori	a2,a2,1
    80006b98:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006b9c:	f8842603          	lw	a2,-120(s0)
    80006ba0:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006ba4:	00250693          	addi	a3,a0,2
    80006ba8:	0692                	slli	a3,a3,0x4
    80006baa:	96be                	add	a3,a3,a5
    80006bac:	58fd                	li	a7,-1
    80006bae:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80006bb2:	0612                	slli	a2,a2,0x4
    80006bb4:	9832                	add	a6,a6,a2
    80006bb6:	f9070713          	addi	a4,a4,-112
    80006bba:	973e                	add	a4,a4,a5
    80006bbc:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006bc0:	6398                	ld	a4,0(a5)
    80006bc2:	9732                	add	a4,a4,a2
    80006bc4:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006bc6:	4609                	li	a2,2
    80006bc8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006bcc:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006bd0:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006bd4:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006bd8:	6794                	ld	a3,8(a5)
    80006bda:	0026d703          	lhu	a4,2(a3)
    80006bde:	8b1d                	andi	a4,a4,7
    80006be0:	0706                	slli	a4,a4,0x1
    80006be2:	96ba                	add	a3,a3,a4
    80006be4:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006be8:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006bec:	6798                	ld	a4,8(a5)
    80006bee:	00275783          	lhu	a5,2(a4)
    80006bf2:	2785                	addiw	a5,a5,1
    80006bf4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006bf8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006bfc:	100017b7          	lui	a5,0x10001
    80006c00:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1)
    80006c04:	004aa783          	lw	a5,4(s5)
  {
    sleep(b, &disk.vdisk_lock);
    80006c08:	0023f917          	auipc	s2,0x23f
    80006c0c:	9b090913          	addi	s2,s2,-1616 # 802455b8 <disk+0x128>
  while (b->disk == 1)
    80006c10:	4485                	li	s1,1
    80006c12:	00b79c63          	bne	a5,a1,80006c2a <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006c16:	85ca                	mv	a1,s2
    80006c18:	8556                	mv	a0,s5
    80006c1a:	ffffb097          	auipc	ra,0xffffb
    80006c1e:	712080e7          	jalr	1810(ra) # 8000232c <sleep>
  while (b->disk == 1)
    80006c22:	004aa783          	lw	a5,4(s5)
    80006c26:	fe9788e3          	beq	a5,s1,80006c16 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006c2a:	f8042903          	lw	s2,-128(s0)
    80006c2e:	00290713          	addi	a4,s2,2
    80006c32:	0712                	slli	a4,a4,0x4
    80006c34:	0023f797          	auipc	a5,0x23f
    80006c38:	85c78793          	addi	a5,a5,-1956 # 80245490 <disk>
    80006c3c:	97ba                	add	a5,a5,a4
    80006c3e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006c42:	0023f997          	auipc	s3,0x23f
    80006c46:	84e98993          	addi	s3,s3,-1970 # 80245490 <disk>
    80006c4a:	00491713          	slli	a4,s2,0x4
    80006c4e:	0009b783          	ld	a5,0(s3)
    80006c52:	97ba                	add	a5,a5,a4
    80006c54:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006c58:	854a                	mv	a0,s2
    80006c5a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006c5e:	00000097          	auipc	ra,0x0
    80006c62:	b9c080e7          	jalr	-1124(ra) # 800067fa <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80006c66:	8885                	andi	s1,s1,1
    80006c68:	f0ed                	bnez	s1,80006c4a <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006c6a:	0023f517          	auipc	a0,0x23f
    80006c6e:	94e50513          	addi	a0,a0,-1714 # 802455b8 <disk+0x128>
    80006c72:	ffffa097          	auipc	ra,0xffffa
    80006c76:	18c080e7          	jalr	396(ra) # 80000dfe <release>
}
    80006c7a:	70e6                	ld	ra,120(sp)
    80006c7c:	7446                	ld	s0,112(sp)
    80006c7e:	74a6                	ld	s1,104(sp)
    80006c80:	7906                	ld	s2,96(sp)
    80006c82:	69e6                	ld	s3,88(sp)
    80006c84:	6a46                	ld	s4,80(sp)
    80006c86:	6aa6                	ld	s5,72(sp)
    80006c88:	6b06                	ld	s6,64(sp)
    80006c8a:	7be2                	ld	s7,56(sp)
    80006c8c:	7c42                	ld	s8,48(sp)
    80006c8e:	7ca2                	ld	s9,40(sp)
    80006c90:	7d02                	ld	s10,32(sp)
    80006c92:	6de2                	ld	s11,24(sp)
    80006c94:	6109                	addi	sp,sp,128
    80006c96:	8082                	ret

0000000080006c98 <virtio_disk_intr>:

void virtio_disk_intr()
{
    80006c98:	1101                	addi	sp,sp,-32
    80006c9a:	ec06                	sd	ra,24(sp)
    80006c9c:	e822                	sd	s0,16(sp)
    80006c9e:	e426                	sd	s1,8(sp)
    80006ca0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006ca2:	0023e497          	auipc	s1,0x23e
    80006ca6:	7ee48493          	addi	s1,s1,2030 # 80245490 <disk>
    80006caa:	0023f517          	auipc	a0,0x23f
    80006cae:	90e50513          	addi	a0,a0,-1778 # 802455b8 <disk+0x128>
    80006cb2:	ffffa097          	auipc	ra,0xffffa
    80006cb6:	098080e7          	jalr	152(ra) # 80000d4a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006cba:	10001737          	lui	a4,0x10001
    80006cbe:	533c                	lw	a5,96(a4)
    80006cc0:	8b8d                	andi	a5,a5,3
    80006cc2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006cc4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx)
    80006cc8:	689c                	ld	a5,16(s1)
    80006cca:	0204d703          	lhu	a4,32(s1)
    80006cce:	0027d783          	lhu	a5,2(a5)
    80006cd2:	04f70863          	beq	a4,a5,80006d22 <virtio_disk_intr+0x8a>
  {
    __sync_synchronize();
    80006cd6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006cda:	6898                	ld	a4,16(s1)
    80006cdc:	0204d783          	lhu	a5,32(s1)
    80006ce0:	8b9d                	andi	a5,a5,7
    80006ce2:	078e                	slli	a5,a5,0x3
    80006ce4:	97ba                	add	a5,a5,a4
    80006ce6:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80006ce8:	00278713          	addi	a4,a5,2
    80006cec:	0712                	slli	a4,a4,0x4
    80006cee:	9726                	add	a4,a4,s1
    80006cf0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006cf4:	e721                	bnez	a4,80006d3c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006cf6:	0789                	addi	a5,a5,2
    80006cf8:	0792                	slli	a5,a5,0x4
    80006cfa:	97a6                	add	a5,a5,s1
    80006cfc:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80006cfe:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006d02:	ffffb097          	auipc	ra,0xffffb
    80006d06:	7e6080e7          	jalr	2022(ra) # 800024e8 <wakeup>

    disk.used_idx += 1;
    80006d0a:	0204d783          	lhu	a5,32(s1)
    80006d0e:	2785                	addiw	a5,a5,1
    80006d10:	17c2                	slli	a5,a5,0x30
    80006d12:	93c1                	srli	a5,a5,0x30
    80006d14:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx)
    80006d18:	6898                	ld	a4,16(s1)
    80006d1a:	00275703          	lhu	a4,2(a4)
    80006d1e:	faf71ce3          	bne	a4,a5,80006cd6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006d22:	0023f517          	auipc	a0,0x23f
    80006d26:	89650513          	addi	a0,a0,-1898 # 802455b8 <disk+0x128>
    80006d2a:	ffffa097          	auipc	ra,0xffffa
    80006d2e:	0d4080e7          	jalr	212(ra) # 80000dfe <release>
}
    80006d32:	60e2                	ld	ra,24(sp)
    80006d34:	6442                	ld	s0,16(sp)
    80006d36:	64a2                	ld	s1,8(sp)
    80006d38:	6105                	addi	sp,sp,32
    80006d3a:	8082                	ret
      panic("virtio_disk_intr status");
    80006d3c:	00002517          	auipc	a0,0x2
    80006d40:	cb450513          	addi	a0,a0,-844 # 800089f0 <mag01.0+0x100>
    80006d44:	ffff9097          	auipc	ra,0xffff9
    80006d48:	7fc080e7          	jalr	2044(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
