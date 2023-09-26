
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d013103          	ld	sp,-1840(sp) # 800088d0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	8e070713          	addi	a4,a4,-1824 # 80008930 <timer_scratch>
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
    80000066:	eee78793          	addi	a5,a5,-274 # 80005f50 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd96b7>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0"
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0"
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
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
    8000012e:	446080e7          	jalr	1094(ra) # 80002570 <either_copyin>
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
    8000018e:	8e650513          	addi	a0,a0,-1818 # 80010a70 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8d648493          	addi	s1,s1,-1834 # 80010a70 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	96690913          	addi	s2,s2,-1690 # 80010b08 <cons+0x98>
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
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	1f2080e7          	jalr	498(ra) # 800023ba <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f04080e7          	jalr	-252(ra) # 800020da <sleep>
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
    80000216:	308080e7          	jalr	776(ra) # 8000251a <either_copyout>
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
    8000022a:	84a50513          	addi	a0,a0,-1974 # 80010a70 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	83450513          	addi	a0,a0,-1996 # 80010a70 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
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
    80000276:	88f72b23          	sw	a5,-1898(a4) # 80010b08 <cons+0x98>
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
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	7a450513          	addi	a0,a0,1956 # 80010a70 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

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
    800002f6:	2d4080e7          	jalr	724(ra) # 800025c6 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	77650513          	addi	a0,a0,1910 # 80010a70 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
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
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	75270713          	addi	a4,a4,1874 # 80010a70 <cons>
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
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	72878793          	addi	a5,a5,1832 # 80010a70 <cons>
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
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7927a783          	lw	a5,1938(a5) # 80010b08 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while (cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6e670713          	addi	a4,a4,1766 # 80010a70 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6d648493          	addi	s1,s1,1750 # 80010a70 <cons>
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
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	69a70713          	addi	a4,a4,1690 # 80010a70 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	72f72223          	sw	a5,1828(a4) # 80010b10 <cons+0xa0>
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
    80000412:	00010797          	auipc	a5,0x10
    80000416:	65e78793          	addi	a5,a5,1630 # 80010a70 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6cc7ab23          	sw	a2,1750(a5) # 80010b0c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6ca50513          	addi	a0,a0,1738 # 80010b08 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	d04080e7          	jalr	-764(ra) # 8000214a <wakeup>
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
    80000460:	00010517          	auipc	a0,0x10
    80000464:	61050513          	addi	a0,a0,1552 # 80010a70 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	7b878793          	addi	a5,a5,1976 # 80022c30 <devsw>
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
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	5e07a223          	sw	zero,1508(a5) # 80010b30 <pr+0x18>
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
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	36f72823          	sw	a5,880(a4) # 800088f0 <panicked>
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
    800005c0:	574dad83          	lw	s11,1396(s11) # 80010b30 <pr+0x18>
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
    800005fe:	51e50513          	addi	a0,a0,1310 # 80010b18 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
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
    8000075c:	3c050513          	addi	a0,a0,960 # 80010b18 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
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
    80000778:	3a448493          	addi	s1,s1,932 # 80010b18 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
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
    800007d8:	36450513          	addi	a0,a0,868 # 80010b38 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
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
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if (panicked)
    80000800:	00008797          	auipc	a5,0x8
    80000804:	0f07a783          	lw	a5,240(a5) # 800088f0 <panicked>
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
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
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
    8000083c:	0c07b783          	ld	a5,192(a5) # 800088f8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0c073703          	ld	a4,192(a4) # 80008900 <uart_tx_w>
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
    80000866:	2d6a0a13          	addi	s4,s4,726 # 80010b38 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	08e48493          	addi	s1,s1,142 # 800088f8 <uart_tx_r>
    if (uart_tx_w == uart_tx_r)
    80000872:	00008997          	auipc	s3,0x8
    80000876:	08e98993          	addi	s3,s3,142 # 80008900 <uart_tx_w>
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
    80000898:	8b6080e7          	jalr	-1866(ra) # 8000214a <wakeup>

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
    800008d4:	26850513          	addi	a0,a0,616 # 80010b38 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if (panicked)
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	0107a783          	lw	a5,16(a5) # 800088f0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	01673703          	ld	a4,22(a4) # 80008900 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	0067b783          	ld	a5,6(a5) # 800088f8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	23a98993          	addi	s3,s3,570 # 80010b38 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	ff248493          	addi	s1,s1,-14 # 800088f8 <uart_tx_r>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	ff290913          	addi	s2,s2,-14 # 80008900 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	7bc080e7          	jalr	1980(ra) # 800020da <sleep>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	20448493          	addi	s1,s1,516 # 80010b38 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	fae7bc23          	sd	a4,-72(a5) # 80008900 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
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
    800009be:	17e48493          	addi	s1,s1,382 # 80010b38 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00024797          	auipc	a5,0x24
    80000a00:	74c78793          	addi	a5,a5,1868 # 80025148 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	15490913          	addi	s2,s2,340 # 80010b70 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	0b650513          	addi	a0,a0,182 # 80010b70 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00024517          	auipc	a0,0x24
    80000ad2:	67a50513          	addi	a0,a0,1658 # 80025148 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	08048493          	addi	s1,s1,128 # 80010b70 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if (r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	06850513          	addi	a0,a0,104 # 80010b70 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void *)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	03c50513          	addi	a0,a0,60 # 80010b70 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if (r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "riscv.h"
#include "proc.h"
#include "defs.h"

void initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Check whether this cpu is holding the lock.
// Interrupts must be off.
int holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// push_off/pop_off are like intr_off()/intr_on() except that they are matched:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if (mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if (holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while (__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if (holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while (__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus"
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus"
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++)
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
  {
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++)
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0)
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
  {
    if (*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while (n-- > 0)
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d)
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    d += n;
    while (n-- > 0)
      *--d = *--s;
  }
  else
    while (n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd9eb9>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if (s < d && s + n > d)
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if (n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if (n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while (n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while (n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:

volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if (cpuid() == 0)
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    __sync_synchronize();
    started = 1;
  }
  else
  {
    while (started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a8070713          	addi	a4,a4,-1408 # 80008908 <started>
  if (cpuid() == 0)
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while (started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();  // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	9f6080e7          	jalr	-1546(ra) # 800028b4 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	0ca080e7          	jalr	202(ra) # 80005f90 <plicinithart>
  }

  scheduler();
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	05a080e7          	jalr	90(ra) # 80001f28 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();            // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();          // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();      // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();         // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();         // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	956080e7          	jalr	-1706(ra) # 8000288c <trapinit>
    trapinithart();     // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	976080e7          	jalr	-1674(ra) # 800028b4 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	034080e7          	jalr	52(ra) # 80005f7a <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	042080e7          	jalr	66(ra) # 80005f90 <plicinithart>
    binit();            // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	1e2080e7          	jalr	482(ra) # 80003138 <binit>
    iinit();            // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	882080e7          	jalr	-1918(ra) # 800037e0 <iinit>
    fileinit();         // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	828080e7          	jalr	-2008(ra) # 8000478e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	3fe080e7          	jalr	1022(ra) # 8000636c <virtio_disk_init>
    userinit();         // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d7c080e7          	jalr	-644(ra) # 80001cf2 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	98f72223          	sw	a5,-1660(a4) # 80008908 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9787b783          	ld	a5,-1672(a5) # 80008910 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0"
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--)
    80000fd6:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    {
      pagetable = (pagetable_t)PTE2PA(*pte);
    }
    else
    {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--)
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd9eaf>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if (*pte & PTE_V)
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if (pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if ((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if (size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");

  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if (*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if (a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	6aa7be23          	sd	a0,1724(a5) # 80008910 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
  {
    if ((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if ((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if (PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if ((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if ((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if (PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if (do_free)
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void *)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if (newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE)
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if (mem == 0)
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for (a = oldsz; a < newsz; a += PGSIZE)
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
    {
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void *)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if (sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE)
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE)
    80001586:	4981                	li	s3,0
  {
    if ((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for (i = 0; i < sz; i += PGSIZE)
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
    {
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if (pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    // }

    // if (pa0 == 0)
    //   return -1;

    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while (len > 0)
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if (pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if (pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if (pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while (n > 0)
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if (*p == '\0')
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while (n > 0)
    80001806:	96da                	add	a3,a3,s6
      if (*p == '\0')
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9eb8>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while (n > 0)
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if (got_null)
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	77448493          	addi	s1,s1,1908 # 80010fc0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001864:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001866:	00016a17          	auipc	s4,0x16
    8000186a:	75aa0a13          	addi	s4,s4,1882 # 80017fc0 <mlfq>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if (pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	8599                	srai	a1,a1,0x6
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018a0:	1c048493          	addi	s1,s1,448
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7c080e7          	jalr	-900(ra) # 80000540 <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	2a850513          	addi	a0,a0,680 # 80010b90 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	2a850513          	addi	a0,a0,680 # 80010ba8 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	6b048493          	addi	s1,s1,1712 # 80010fc0 <proc>
  {
    initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001932:	00016997          	auipc	s3,0x16
    80001936:	68e98993          	addi	s3,s3,1678 # 80017fc0 <mlfq>
    initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	8799                	srai	a5,a5,0x6
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001964:	1c048493          	addi	s1,s1,448
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp"
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	22450513          	addi	a0,a0,548 # 80010bc0 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	1cc70713          	addi	a4,a4,460 # 80010b90 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first)
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	e847a783          	lw	a5,-380(a5) # 80008880 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	ec6080e7          	jalr	-314(ra) # 800028cc <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e607a523          	sw	zero,-406(a5) # 80008880 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	d40080e7          	jalr	-704(ra) # 80003760 <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	15a90913          	addi	s2,s2,346 # 80010b90 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e3c78793          	addi	a5,a5,-452 # 80008884 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	05893683          	ld	a3,88(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a54080e7          	jalr	-1452(ra) # 8000152e <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2e080e7          	jalr	-1490(ra) # 8000152e <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e4080e7          	jalr	-1564(ra) # 8000152e <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7a080e7          	jalr	-390(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	3fe48493          	addi	s1,s1,1022 # 80010fc0 <proc>
    80001bca:	00016917          	auipc	s2,0x16
    80001bce:	3f690913          	addi	s2,s2,1014 # 80017fc0 <mlfq>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001bea:	1c048493          	addi	s1,s1,448
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a84d                	j	80001ca6 <allocproc+0xf0>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  p->number_of_times_scheduled = 0;
    80001c04:	1604ac23          	sw	zero,376(s1)
  p->sleeping_ticks = 0;
    80001c08:	1804a223          	sw	zero,388(s1)
  p->running_ticks = 0;
    80001c0c:	1804a423          	sw	zero,392(s1)
  p->sleep_start = 0;
    80001c10:	1604ae23          	sw	zero,380(s1)
  p->reset_niceness = 1;
    80001c14:	18f4a023          	sw	a5,384(s1)
  p->level = 0;
    80001c18:	1804a623          	sw	zero,396(s1)
  p->change_queue = 1 << p->level;
    80001c1c:	18f4aa23          	sw	a5,404(s1)
  p->in_queue = 0;
    80001c20:	1804a823          	sw	zero,400(s1)
  p->enter_ticks = ticks;
    80001c24:	00007797          	auipc	a5,0x7
    80001c28:	d047a783          	lw	a5,-764(a5) # 80008928 <ticks>
    80001c2c:	18f4ac23          	sw	a5,408(s1)
  p->now_ticks = 0;
    80001c30:	1a04a623          	sw	zero,428(s1)
  p->sigalarm_status = 0;
    80001c34:	1a04ac23          	sw	zero,440(s1)
  p->interval = 0;
    80001c38:	1a04a423          	sw	zero,424(s1)
  p->handler = -1;
    80001c3c:	57fd                	li	a5,-1
    80001c3e:	1af4b023          	sd	a5,416(s1)
  p->alarm_trapframe = NULL;
    80001c42:	1a04b823          	sd	zero,432(s1)
  if (forked_process && p->parent)
    80001c46:	00007797          	auipc	a5,0x7
    80001c4a:	cd27a783          	lw	a5,-814(a5) # 80008918 <forked_process>
    80001c4e:	e3bd                	bnez	a5,80001cb4 <allocproc+0xfe>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	e96080e7          	jalr	-362(ra) # 80000ae6 <kalloc>
    80001c58:	892a                	mv	s2,a0
    80001c5a:	eca8                	sd	a0,88(s1)
    80001c5c:	c13d                	beqz	a0,80001cc2 <allocproc+0x10c>
  p->pagetable = proc_pagetable(p);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	e10080e7          	jalr	-496(ra) # 80001a70 <proc_pagetable>
    80001c68:	892a                	mv	s2,a0
    80001c6a:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c6c:	c53d                	beqz	a0,80001cda <allocproc+0x124>
  memset(&p->context, 0, sizeof(p->context));
    80001c6e:	07000613          	li	a2,112
    80001c72:	4581                	li	a1,0
    80001c74:	06048513          	addi	a0,s1,96
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	05a080e7          	jalr	90(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c80:	00000797          	auipc	a5,0x0
    80001c84:	d6478793          	addi	a5,a5,-668 # 800019e4 <forkret>
    80001c88:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c8a:	60bc                	ld	a5,64(s1)
    80001c8c:	6705                	lui	a4,0x1
    80001c8e:	97ba                	add	a5,a5,a4
    80001c90:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c92:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001c96:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001c9a:	00007797          	auipc	a5,0x7
    80001c9e:	c8e7a783          	lw	a5,-882(a5) # 80008928 <ticks>
    80001ca2:	16f4a623          	sw	a5,364(s1)
}
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	60e2                	ld	ra,24(sp)
    80001caa:	6442                	ld	s0,16(sp)
    80001cac:	64a2                	ld	s1,8(sp)
    80001cae:	6902                	ld	s2,0(sp)
    80001cb0:	6105                	addi	sp,sp,32
    80001cb2:	8082                	ret
  if (forked_process && p->parent)
    80001cb4:	7c9c                	ld	a5,56(s1)
    80001cb6:	dfc9                	beqz	a5,80001c50 <allocproc+0x9a>
    forked_process = 0;
    80001cb8:	00007797          	auipc	a5,0x7
    80001cbc:	c607a023          	sw	zero,-928(a5) # 80008918 <forked_process>
    80001cc0:	bf41                	j	80001c50 <allocproc+0x9a>
    freeproc(p);
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	00000097          	auipc	ra,0x0
    80001cc8:	e9a080e7          	jalr	-358(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001ccc:	8526                	mv	a0,s1
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	fbc080e7          	jalr	-68(ra) # 80000c8a <release>
    return 0;
    80001cd6:	84ca                	mv	s1,s2
    80001cd8:	b7f9                	j	80001ca6 <allocproc+0xf0>
    freeproc(p);
    80001cda:	8526                	mv	a0,s1
    80001cdc:	00000097          	auipc	ra,0x0
    80001ce0:	e82080e7          	jalr	-382(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	fa4080e7          	jalr	-92(ra) # 80000c8a <release>
    return 0;
    80001cee:	84ca                	mv	s1,s2
    80001cf0:	bf5d                	j	80001ca6 <allocproc+0xf0>

0000000080001cf2 <userinit>:
{
    80001cf2:	1101                	addi	sp,sp,-32
    80001cf4:	ec06                	sd	ra,24(sp)
    80001cf6:	e822                	sd	s0,16(sp)
    80001cf8:	e426                	sd	s1,8(sp)
    80001cfa:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cfc:	00000097          	auipc	ra,0x0
    80001d00:	eba080e7          	jalr	-326(ra) # 80001bb6 <allocproc>
    80001d04:	84aa                	mv	s1,a0
  initproc = p;
    80001d06:	00007797          	auipc	a5,0x7
    80001d0a:	c0a7bd23          	sd	a0,-998(a5) # 80008920 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d0e:	03400613          	li	a2,52
    80001d12:	00007597          	auipc	a1,0x7
    80001d16:	b7e58593          	addi	a1,a1,-1154 # 80008890 <initcode>
    80001d1a:	6928                	ld	a0,80(a0)
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	63a080e7          	jalr	1594(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d24:	6785                	lui	a5,0x1
    80001d26:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d28:	6cb8                	ld	a4,88(s1)
    80001d2a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d2e:	6cb8                	ld	a4,88(s1)
    80001d30:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d32:	4641                	li	a2,16
    80001d34:	00006597          	auipc	a1,0x6
    80001d38:	4cc58593          	addi	a1,a1,1228 # 80008200 <digits+0x1c0>
    80001d3c:	15848513          	addi	a0,s1,344
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	0dc080e7          	jalr	220(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d48:	00006517          	auipc	a0,0x6
    80001d4c:	4c850513          	addi	a0,a0,1224 # 80008210 <digits+0x1d0>
    80001d50:	00002097          	auipc	ra,0x2
    80001d54:	43a080e7          	jalr	1082(ra) # 8000418a <namei>
    80001d58:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d5c:	478d                	li	a5,3
    80001d5e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d60:	8526                	mv	a0,s1
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	f28080e7          	jalr	-216(ra) # 80000c8a <release>
}
    80001d6a:	60e2                	ld	ra,24(sp)
    80001d6c:	6442                	ld	s0,16(sp)
    80001d6e:	64a2                	ld	s1,8(sp)
    80001d70:	6105                	addi	sp,sp,32
    80001d72:	8082                	ret

0000000080001d74 <growproc>:
{
    80001d74:	1101                	addi	sp,sp,-32
    80001d76:	ec06                	sd	ra,24(sp)
    80001d78:	e822                	sd	s0,16(sp)
    80001d7a:	e426                	sd	s1,8(sp)
    80001d7c:	e04a                	sd	s2,0(sp)
    80001d7e:	1000                	addi	s0,sp,32
    80001d80:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d82:	00000097          	auipc	ra,0x0
    80001d86:	c2a080e7          	jalr	-982(ra) # 800019ac <myproc>
    80001d8a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d8c:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d8e:	01204c63          	bgtz	s2,80001da6 <growproc+0x32>
  else if (n < 0)
    80001d92:	02094663          	bltz	s2,80001dbe <growproc+0x4a>
  p->sz = sz;
    80001d96:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d98:	4501                	li	a0,0
}
    80001d9a:	60e2                	ld	ra,24(sp)
    80001d9c:	6442                	ld	s0,16(sp)
    80001d9e:	64a2                	ld	s1,8(sp)
    80001da0:	6902                	ld	s2,0(sp)
    80001da2:	6105                	addi	sp,sp,32
    80001da4:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001da6:	4691                	li	a3,4
    80001da8:	00b90633          	add	a2,s2,a1
    80001dac:	6928                	ld	a0,80(a0)
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	662080e7          	jalr	1634(ra) # 80001410 <uvmalloc>
    80001db6:	85aa                	mv	a1,a0
    80001db8:	fd79                	bnez	a0,80001d96 <growproc+0x22>
      return -1;
    80001dba:	557d                	li	a0,-1
    80001dbc:	bff9                	j	80001d9a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dbe:	00b90633          	add	a2,s2,a1
    80001dc2:	6928                	ld	a0,80(a0)
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	604080e7          	jalr	1540(ra) # 800013c8 <uvmdealloc>
    80001dcc:	85aa                	mv	a1,a0
    80001dce:	b7e1                	j	80001d96 <growproc+0x22>

0000000080001dd0 <fork>:
{
    80001dd0:	7139                	addi	sp,sp,-64
    80001dd2:	fc06                	sd	ra,56(sp)
    80001dd4:	f822                	sd	s0,48(sp)
    80001dd6:	f426                	sd	s1,40(sp)
    80001dd8:	f04a                	sd	s2,32(sp)
    80001dda:	ec4e                	sd	s3,24(sp)
    80001ddc:	e852                	sd	s4,16(sp)
    80001dde:	e456                	sd	s5,8(sp)
    80001de0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001de2:	00000097          	auipc	ra,0x0
    80001de6:	bca080e7          	jalr	-1078(ra) # 800019ac <myproc>
    80001dea:	8aaa                	mv	s5,a0
  if (p->pid > 1)
    80001dec:	5918                	lw	a4,48(a0)
    80001dee:	4785                	li	a5,1
    80001df0:	00e7d663          	bge	a5,a4,80001dfc <fork+0x2c>
    forked_process = 1;
    80001df4:	00007717          	auipc	a4,0x7
    80001df8:	b2f72223          	sw	a5,-1244(a4) # 80008918 <forked_process>
  if ((np = allocproc()) == 0)
    80001dfc:	00000097          	auipc	ra,0x0
    80001e00:	dba080e7          	jalr	-582(ra) # 80001bb6 <allocproc>
    80001e04:	89aa                	mv	s3,a0
    80001e06:	10050f63          	beqz	a0,80001f24 <fork+0x154>
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e0a:	048ab603          	ld	a2,72(s5)
    80001e0e:	692c                	ld	a1,80(a0)
    80001e10:	050ab503          	ld	a0,80(s5)
    80001e14:	fffff097          	auipc	ra,0xfffff
    80001e18:	754080e7          	jalr	1876(ra) # 80001568 <uvmcopy>
    80001e1c:	04054c63          	bltz	a0,80001e74 <fork+0xa4>
  np->sz = p->sz;
    80001e20:	048ab783          	ld	a5,72(s5)
    80001e24:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e28:	058ab683          	ld	a3,88(s5)
    80001e2c:	87b6                	mv	a5,a3
    80001e2e:	0589b703          	ld	a4,88(s3)
    80001e32:	12068693          	addi	a3,a3,288
    80001e36:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e3a:	6788                	ld	a0,8(a5)
    80001e3c:	6b8c                	ld	a1,16(a5)
    80001e3e:	6f90                	ld	a2,24(a5)
    80001e40:	01073023          	sd	a6,0(a4)
    80001e44:	e708                	sd	a0,8(a4)
    80001e46:	eb0c                	sd	a1,16(a4)
    80001e48:	ef10                	sd	a2,24(a4)
    80001e4a:	02078793          	addi	a5,a5,32
    80001e4e:	02070713          	addi	a4,a4,32
    80001e52:	fed792e3          	bne	a5,a3,80001e36 <fork+0x66>
  np->tmask = p->tmask;
    80001e56:	174aa783          	lw	a5,372(s5)
    80001e5a:	16f9aa23          	sw	a5,372(s3)
  np->trapframe->a0 = 0;
    80001e5e:	0589b783          	ld	a5,88(s3)
    80001e62:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e66:	0d0a8493          	addi	s1,s5,208
    80001e6a:	0d098913          	addi	s2,s3,208
    80001e6e:	150a8a13          	addi	s4,s5,336
    80001e72:	a00d                	j	80001e94 <fork+0xc4>
    freeproc(np);
    80001e74:	854e                	mv	a0,s3
    80001e76:	00000097          	auipc	ra,0x0
    80001e7a:	ce8080e7          	jalr	-792(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e7e:	854e                	mv	a0,s3
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	e0a080e7          	jalr	-502(ra) # 80000c8a <release>
    return -1;
    80001e88:	597d                	li	s2,-1
    80001e8a:	a059                	j	80001f10 <fork+0x140>
  for (i = 0; i < NOFILE; i++)
    80001e8c:	04a1                	addi	s1,s1,8
    80001e8e:	0921                	addi	s2,s2,8
    80001e90:	01448b63          	beq	s1,s4,80001ea6 <fork+0xd6>
    if (p->ofile[i])
    80001e94:	6088                	ld	a0,0(s1)
    80001e96:	d97d                	beqz	a0,80001e8c <fork+0xbc>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e98:	00003097          	auipc	ra,0x3
    80001e9c:	988080e7          	jalr	-1656(ra) # 80004820 <filedup>
    80001ea0:	00a93023          	sd	a0,0(s2)
    80001ea4:	b7e5                	j	80001e8c <fork+0xbc>
  np->cwd = idup(p->cwd);
    80001ea6:	150ab503          	ld	a0,336(s5)
    80001eaa:	00002097          	auipc	ra,0x2
    80001eae:	af6080e7          	jalr	-1290(ra) # 800039a0 <idup>
    80001eb2:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eb6:	4641                	li	a2,16
    80001eb8:	158a8593          	addi	a1,s5,344
    80001ebc:	15898513          	addi	a0,s3,344
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	f5c080e7          	jalr	-164(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001ec8:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ecc:	854e                	mv	a0,s3
    80001ece:	fffff097          	auipc	ra,0xfffff
    80001ed2:	dbc080e7          	jalr	-580(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001ed6:	0000f497          	auipc	s1,0xf
    80001eda:	cd248493          	addi	s1,s1,-814 # 80010ba8 <wait_lock>
    80001ede:	8526                	mv	a0,s1
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	cf6080e7          	jalr	-778(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001ee8:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	d9c080e7          	jalr	-612(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ef6:	854e                	mv	a0,s3
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	cde080e7          	jalr	-802(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001f00:	478d                	li	a5,3
    80001f02:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f06:	854e                	mv	a0,s3
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	d82080e7          	jalr	-638(ra) # 80000c8a <release>
}
    80001f10:	854a                	mv	a0,s2
    80001f12:	70e2                	ld	ra,56(sp)
    80001f14:	7442                	ld	s0,48(sp)
    80001f16:	74a2                	ld	s1,40(sp)
    80001f18:	7902                	ld	s2,32(sp)
    80001f1a:	69e2                	ld	s3,24(sp)
    80001f1c:	6a42                	ld	s4,16(sp)
    80001f1e:	6aa2                	ld	s5,8(sp)
    80001f20:	6121                	addi	sp,sp,64
    80001f22:	8082                	ret
    return -1;
    80001f24:	597d                	li	s2,-1
    80001f26:	b7ed                	j	80001f10 <fork+0x140>

0000000080001f28 <scheduler>:
{
    80001f28:	7139                	addi	sp,sp,-64
    80001f2a:	fc06                	sd	ra,56(sp)
    80001f2c:	f822                	sd	s0,48(sp)
    80001f2e:	f426                	sd	s1,40(sp)
    80001f30:	f04a                	sd	s2,32(sp)
    80001f32:	ec4e                	sd	s3,24(sp)
    80001f34:	e852                	sd	s4,16(sp)
    80001f36:	e456                	sd	s5,8(sp)
    80001f38:	e05a                	sd	s6,0(sp)
    80001f3a:	0080                	addi	s0,sp,64
    80001f3c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f3e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f40:	00779a93          	slli	s5,a5,0x7
    80001f44:	0000f717          	auipc	a4,0xf
    80001f48:	c4c70713          	addi	a4,a4,-948 # 80010b90 <pid_lock>
    80001f4c:	9756                	add	a4,a4,s5
    80001f4e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f52:	0000f717          	auipc	a4,0xf
    80001f56:	c7670713          	addi	a4,a4,-906 # 80010bc8 <cpus+0x8>
    80001f5a:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001f5c:	498d                	li	s3,3
        p->state = RUNNING;
    80001f5e:	4b11                	li	s6,4
        c->proc = p;
    80001f60:	079e                	slli	a5,a5,0x7
    80001f62:	0000fa17          	auipc	s4,0xf
    80001f66:	c2ea0a13          	addi	s4,s4,-978 # 80010b90 <pid_lock>
    80001f6a:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001f6c:	00016917          	auipc	s2,0x16
    80001f70:	05490913          	addi	s2,s2,84 # 80017fc0 <mlfq>
  asm volatile("csrr %0, sstatus"
    80001f74:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f78:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80001f7c:	10079073          	csrw	sstatus,a5
    80001f80:	0000f497          	auipc	s1,0xf
    80001f84:	04048493          	addi	s1,s1,64 # 80010fc0 <proc>
    80001f88:	a811                	j	80001f9c <scheduler+0x74>
      release(&p->lock);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	cfe080e7          	jalr	-770(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f94:	1c048493          	addi	s1,s1,448
    80001f98:	fd248ee3          	beq	s1,s2,80001f74 <scheduler+0x4c>
      acquire(&p->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	c38080e7          	jalr	-968(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80001fa6:	4c9c                	lw	a5,24(s1)
    80001fa8:	ff3791e3          	bne	a5,s3,80001f8a <scheduler+0x62>
        p->state = RUNNING;
    80001fac:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fb0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fb4:	06048593          	addi	a1,s1,96
    80001fb8:	8556                	mv	a0,s5
    80001fba:	00001097          	auipc	ra,0x1
    80001fbe:	868080e7          	jalr	-1944(ra) # 80002822 <swtch>
        c->proc = 0;
    80001fc2:	020a3823          	sd	zero,48(s4)
    80001fc6:	b7d1                	j	80001f8a <scheduler+0x62>

0000000080001fc8 <sched>:
{
    80001fc8:	7179                	addi	sp,sp,-48
    80001fca:	f406                	sd	ra,40(sp)
    80001fcc:	f022                	sd	s0,32(sp)
    80001fce:	ec26                	sd	s1,24(sp)
    80001fd0:	e84a                	sd	s2,16(sp)
    80001fd2:	e44e                	sd	s3,8(sp)
    80001fd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fd6:	00000097          	auipc	ra,0x0
    80001fda:	9d6080e7          	jalr	-1578(ra) # 800019ac <myproc>
    80001fde:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	b7c080e7          	jalr	-1156(ra) # 80000b5c <holding>
    80001fe8:	c93d                	beqz	a0,8000205e <sched+0x96>
  asm volatile("mv %0, tp"
    80001fea:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001fec:	2781                	sext.w	a5,a5
    80001fee:	079e                	slli	a5,a5,0x7
    80001ff0:	0000f717          	auipc	a4,0xf
    80001ff4:	ba070713          	addi	a4,a4,-1120 # 80010b90 <pid_lock>
    80001ff8:	97ba                	add	a5,a5,a4
    80001ffa:	0a87a703          	lw	a4,168(a5)
    80001ffe:	4785                	li	a5,1
    80002000:	06f71763          	bne	a4,a5,8000206e <sched+0xa6>
  if (p->state == RUNNING)
    80002004:	4c98                	lw	a4,24(s1)
    80002006:	4791                	li	a5,4
    80002008:	06f70b63          	beq	a4,a5,8000207e <sched+0xb6>
  asm volatile("csrr %0, sstatus"
    8000200c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002010:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002012:	efb5                	bnez	a5,8000208e <sched+0xc6>
  asm volatile("mv %0, tp"
    80002014:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002016:	0000f917          	auipc	s2,0xf
    8000201a:	b7a90913          	addi	s2,s2,-1158 # 80010b90 <pid_lock>
    8000201e:	2781                	sext.w	a5,a5
    80002020:	079e                	slli	a5,a5,0x7
    80002022:	97ca                	add	a5,a5,s2
    80002024:	0ac7a983          	lw	s3,172(a5)
    80002028:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000202a:	2781                	sext.w	a5,a5
    8000202c:	079e                	slli	a5,a5,0x7
    8000202e:	0000f597          	auipc	a1,0xf
    80002032:	b9a58593          	addi	a1,a1,-1126 # 80010bc8 <cpus+0x8>
    80002036:	95be                	add	a1,a1,a5
    80002038:	06048513          	addi	a0,s1,96
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	7e6080e7          	jalr	2022(ra) # 80002822 <swtch>
    80002044:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002046:	2781                	sext.w	a5,a5
    80002048:	079e                	slli	a5,a5,0x7
    8000204a:	993e                	add	s2,s2,a5
    8000204c:	0b392623          	sw	s3,172(s2)
}
    80002050:	70a2                	ld	ra,40(sp)
    80002052:	7402                	ld	s0,32(sp)
    80002054:	64e2                	ld	s1,24(sp)
    80002056:	6942                	ld	s2,16(sp)
    80002058:	69a2                	ld	s3,8(sp)
    8000205a:	6145                	addi	sp,sp,48
    8000205c:	8082                	ret
    panic("sched p->lock");
    8000205e:	00006517          	auipc	a0,0x6
    80002062:	1ba50513          	addi	a0,a0,442 # 80008218 <digits+0x1d8>
    80002066:	ffffe097          	auipc	ra,0xffffe
    8000206a:	4da080e7          	jalr	1242(ra) # 80000540 <panic>
    panic("sched locks");
    8000206e:	00006517          	auipc	a0,0x6
    80002072:	1ba50513          	addi	a0,a0,442 # 80008228 <digits+0x1e8>
    80002076:	ffffe097          	auipc	ra,0xffffe
    8000207a:	4ca080e7          	jalr	1226(ra) # 80000540 <panic>
    panic("sched running");
    8000207e:	00006517          	auipc	a0,0x6
    80002082:	1ba50513          	addi	a0,a0,442 # 80008238 <digits+0x1f8>
    80002086:	ffffe097          	auipc	ra,0xffffe
    8000208a:	4ba080e7          	jalr	1210(ra) # 80000540 <panic>
    panic("sched interruptible");
    8000208e:	00006517          	auipc	a0,0x6
    80002092:	1ba50513          	addi	a0,a0,442 # 80008248 <digits+0x208>
    80002096:	ffffe097          	auipc	ra,0xffffe
    8000209a:	4aa080e7          	jalr	1194(ra) # 80000540 <panic>

000000008000209e <yield>:
{
    8000209e:	1101                	addi	sp,sp,-32
    800020a0:	ec06                	sd	ra,24(sp)
    800020a2:	e822                	sd	s0,16(sp)
    800020a4:	e426                	sd	s1,8(sp)
    800020a6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020a8:	00000097          	auipc	ra,0x0
    800020ac:	904080e7          	jalr	-1788(ra) # 800019ac <myproc>
    800020b0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	b24080e7          	jalr	-1244(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800020ba:	478d                	li	a5,3
    800020bc:	cc9c                	sw	a5,24(s1)
  sched();
    800020be:	00000097          	auipc	ra,0x0
    800020c2:	f0a080e7          	jalr	-246(ra) # 80001fc8 <sched>
  release(&p->lock);
    800020c6:	8526                	mv	a0,s1
    800020c8:	fffff097          	auipc	ra,0xfffff
    800020cc:	bc2080e7          	jalr	-1086(ra) # 80000c8a <release>
}
    800020d0:	60e2                	ld	ra,24(sp)
    800020d2:	6442                	ld	s0,16(sp)
    800020d4:	64a2                	ld	s1,8(sp)
    800020d6:	6105                	addi	sp,sp,32
    800020d8:	8082                	ret

00000000800020da <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800020da:	7179                	addi	sp,sp,-48
    800020dc:	f406                	sd	ra,40(sp)
    800020de:	f022                	sd	s0,32(sp)
    800020e0:	ec26                	sd	s1,24(sp)
    800020e2:	e84a                	sd	s2,16(sp)
    800020e4:	e44e                	sd	s3,8(sp)
    800020e6:	1800                	addi	s0,sp,48
    800020e8:	89aa                	mv	s3,a0
    800020ea:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020ec:	00000097          	auipc	ra,0x0
    800020f0:	8c0080e7          	jalr	-1856(ra) # 800019ac <myproc>
    800020f4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	ae0080e7          	jalr	-1312(ra) # 80000bd6 <acquire>
  release(lk);
    800020fe:	854a                	mv	a0,s2
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	b8a080e7          	jalr	-1142(ra) # 80000c8a <release>

  // Go to sleep.
  p->sleep_start = ticks;
    80002108:	00007797          	auipc	a5,0x7
    8000210c:	8207a783          	lw	a5,-2016(a5) # 80008928 <ticks>
    80002110:	16f4ae23          	sw	a5,380(s1)
  p->chan = chan;
    80002114:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002118:	4789                	li	a5,2
    8000211a:	cc9c                	sw	a5,24(s1)

  sched();
    8000211c:	00000097          	auipc	ra,0x0
    80002120:	eac080e7          	jalr	-340(ra) # 80001fc8 <sched>

  // Tidy up.
  p->chan = 0;
    80002124:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002128:	8526                	mv	a0,s1
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	b60080e7          	jalr	-1184(ra) # 80000c8a <release>
  acquire(lk);
    80002132:	854a                	mv	a0,s2
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	aa2080e7          	jalr	-1374(ra) # 80000bd6 <acquire>
}
    8000213c:	70a2                	ld	ra,40(sp)
    8000213e:	7402                	ld	s0,32(sp)
    80002140:	64e2                	ld	s1,24(sp)
    80002142:	6942                	ld	s2,16(sp)
    80002144:	69a2                	ld	s3,8(sp)
    80002146:	6145                	addi	sp,sp,48
    80002148:	8082                	ret

000000008000214a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000214a:	7139                	addi	sp,sp,-64
    8000214c:	fc06                	sd	ra,56(sp)
    8000214e:	f822                	sd	s0,48(sp)
    80002150:	f426                	sd	s1,40(sp)
    80002152:	f04a                	sd	s2,32(sp)
    80002154:	ec4e                	sd	s3,24(sp)
    80002156:	e852                	sd	s4,16(sp)
    80002158:	e456                	sd	s5,8(sp)
    8000215a:	e05a                	sd	s6,0(sp)
    8000215c:	0080                	addi	s0,sp,64
    8000215e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002160:	0000f497          	auipc	s1,0xf
    80002164:	e6048493          	addi	s1,s1,-416 # 80010fc0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002168:	4989                	li	s3,2
      {
        p->sleeping_ticks += (ticks - p->sleep_start);
    8000216a:	00006b17          	auipc	s6,0x6
    8000216e:	7beb0b13          	addi	s6,s6,1982 # 80008928 <ticks>
        p->state = RUNNABLE;
    80002172:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002174:	00016917          	auipc	s2,0x16
    80002178:	e4c90913          	addi	s2,s2,-436 # 80017fc0 <mlfq>
    8000217c:	a811                	j	80002190 <wakeup+0x46>
      }
      release(&p->lock);
    8000217e:	8526                	mv	a0,s1
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	b0a080e7          	jalr	-1270(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002188:	1c048493          	addi	s1,s1,448
    8000218c:	05248063          	beq	s1,s2,800021cc <wakeup+0x82>
    if (p != myproc())
    80002190:	00000097          	auipc	ra,0x0
    80002194:	81c080e7          	jalr	-2020(ra) # 800019ac <myproc>
    80002198:	fea488e3          	beq	s1,a0,80002188 <wakeup+0x3e>
      acquire(&p->lock);
    8000219c:	8526                	mv	a0,s1
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	a38080e7          	jalr	-1480(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800021a6:	4c9c                	lw	a5,24(s1)
    800021a8:	fd379be3          	bne	a5,s3,8000217e <wakeup+0x34>
    800021ac:	709c                	ld	a5,32(s1)
    800021ae:	fd4798e3          	bne	a5,s4,8000217e <wakeup+0x34>
        p->sleeping_ticks += (ticks - p->sleep_start);
    800021b2:	1844a703          	lw	a4,388(s1)
    800021b6:	000b2783          	lw	a5,0(s6)
    800021ba:	9fb9                	addw	a5,a5,a4
    800021bc:	17c4a703          	lw	a4,380(s1)
    800021c0:	9f99                	subw	a5,a5,a4
    800021c2:	18f4a223          	sw	a5,388(s1)
        p->state = RUNNABLE;
    800021c6:	0154ac23          	sw	s5,24(s1)
    800021ca:	bf55                	j	8000217e <wakeup+0x34>
    }
  }
}
    800021cc:	70e2                	ld	ra,56(sp)
    800021ce:	7442                	ld	s0,48(sp)
    800021d0:	74a2                	ld	s1,40(sp)
    800021d2:	7902                	ld	s2,32(sp)
    800021d4:	69e2                	ld	s3,24(sp)
    800021d6:	6a42                	ld	s4,16(sp)
    800021d8:	6aa2                	ld	s5,8(sp)
    800021da:	6b02                	ld	s6,0(sp)
    800021dc:	6121                	addi	sp,sp,64
    800021de:	8082                	ret

00000000800021e0 <reparent>:
{
    800021e0:	7179                	addi	sp,sp,-48
    800021e2:	f406                	sd	ra,40(sp)
    800021e4:	f022                	sd	s0,32(sp)
    800021e6:	ec26                	sd	s1,24(sp)
    800021e8:	e84a                	sd	s2,16(sp)
    800021ea:	e44e                	sd	s3,8(sp)
    800021ec:	e052                	sd	s4,0(sp)
    800021ee:	1800                	addi	s0,sp,48
    800021f0:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021f2:	0000f497          	auipc	s1,0xf
    800021f6:	dce48493          	addi	s1,s1,-562 # 80010fc0 <proc>
      pp->parent = initproc;
    800021fa:	00006a17          	auipc	s4,0x6
    800021fe:	726a0a13          	addi	s4,s4,1830 # 80008920 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002202:	00016997          	auipc	s3,0x16
    80002206:	dbe98993          	addi	s3,s3,-578 # 80017fc0 <mlfq>
    8000220a:	a029                	j	80002214 <reparent+0x34>
    8000220c:	1c048493          	addi	s1,s1,448
    80002210:	01348d63          	beq	s1,s3,8000222a <reparent+0x4a>
    if (pp->parent == p)
    80002214:	7c9c                	ld	a5,56(s1)
    80002216:	ff279be3          	bne	a5,s2,8000220c <reparent+0x2c>
      pp->parent = initproc;
    8000221a:	000a3503          	ld	a0,0(s4)
    8000221e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002220:	00000097          	auipc	ra,0x0
    80002224:	f2a080e7          	jalr	-214(ra) # 8000214a <wakeup>
    80002228:	b7d5                	j	8000220c <reparent+0x2c>
}
    8000222a:	70a2                	ld	ra,40(sp)
    8000222c:	7402                	ld	s0,32(sp)
    8000222e:	64e2                	ld	s1,24(sp)
    80002230:	6942                	ld	s2,16(sp)
    80002232:	69a2                	ld	s3,8(sp)
    80002234:	6a02                	ld	s4,0(sp)
    80002236:	6145                	addi	sp,sp,48
    80002238:	8082                	ret

000000008000223a <exit>:
{
    8000223a:	7179                	addi	sp,sp,-48
    8000223c:	f406                	sd	ra,40(sp)
    8000223e:	f022                	sd	s0,32(sp)
    80002240:	ec26                	sd	s1,24(sp)
    80002242:	e84a                	sd	s2,16(sp)
    80002244:	e44e                	sd	s3,8(sp)
    80002246:	e052                	sd	s4,0(sp)
    80002248:	1800                	addi	s0,sp,48
    8000224a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	760080e7          	jalr	1888(ra) # 800019ac <myproc>
    80002254:	89aa                	mv	s3,a0
  if (p == initproc)
    80002256:	00006797          	auipc	a5,0x6
    8000225a:	6ca7b783          	ld	a5,1738(a5) # 80008920 <initproc>
    8000225e:	0d050493          	addi	s1,a0,208
    80002262:	15050913          	addi	s2,a0,336
    80002266:	02a79363          	bne	a5,a0,8000228c <exit+0x52>
    panic("init exiting");
    8000226a:	00006517          	auipc	a0,0x6
    8000226e:	ff650513          	addi	a0,a0,-10 # 80008260 <digits+0x220>
    80002272:	ffffe097          	auipc	ra,0xffffe
    80002276:	2ce080e7          	jalr	718(ra) # 80000540 <panic>
      fileclose(f);
    8000227a:	00002097          	auipc	ra,0x2
    8000227e:	5f8080e7          	jalr	1528(ra) # 80004872 <fileclose>
      p->ofile[fd] = 0;
    80002282:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002286:	04a1                	addi	s1,s1,8
    80002288:	01248563          	beq	s1,s2,80002292 <exit+0x58>
    if (p->ofile[fd])
    8000228c:	6088                	ld	a0,0(s1)
    8000228e:	f575                	bnez	a0,8000227a <exit+0x40>
    80002290:	bfdd                	j	80002286 <exit+0x4c>
  begin_op();
    80002292:	00002097          	auipc	ra,0x2
    80002296:	118080e7          	jalr	280(ra) # 800043aa <begin_op>
  iput(p->cwd);
    8000229a:	1509b503          	ld	a0,336(s3)
    8000229e:	00002097          	auipc	ra,0x2
    800022a2:	8fa080e7          	jalr	-1798(ra) # 80003b98 <iput>
  end_op();
    800022a6:	00002097          	auipc	ra,0x2
    800022aa:	182080e7          	jalr	386(ra) # 80004428 <end_op>
  p->cwd = 0;
    800022ae:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022b2:	0000f497          	auipc	s1,0xf
    800022b6:	8f648493          	addi	s1,s1,-1802 # 80010ba8 <wait_lock>
    800022ba:	8526                	mv	a0,s1
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	91a080e7          	jalr	-1766(ra) # 80000bd6 <acquire>
  reparent(p);
    800022c4:	854e                	mv	a0,s3
    800022c6:	00000097          	auipc	ra,0x0
    800022ca:	f1a080e7          	jalr	-230(ra) # 800021e0 <reparent>
  wakeup(p->parent);
    800022ce:	0389b503          	ld	a0,56(s3)
    800022d2:	00000097          	auipc	ra,0x0
    800022d6:	e78080e7          	jalr	-392(ra) # 8000214a <wakeup>
  acquire(&p->lock);
    800022da:	854e                	mv	a0,s3
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	8fa080e7          	jalr	-1798(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800022e4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022e8:	4795                	li	a5,5
    800022ea:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800022ee:	00006797          	auipc	a5,0x6
    800022f2:	63a7a783          	lw	a5,1594(a5) # 80008928 <ticks>
    800022f6:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    800022fa:	8526                	mv	a0,s1
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	98e080e7          	jalr	-1650(ra) # 80000c8a <release>
  sched();
    80002304:	00000097          	auipc	ra,0x0
    80002308:	cc4080e7          	jalr	-828(ra) # 80001fc8 <sched>
  panic("zombie exit");
    8000230c:	00006517          	auipc	a0,0x6
    80002310:	f6450513          	addi	a0,a0,-156 # 80008270 <digits+0x230>
    80002314:	ffffe097          	auipc	ra,0xffffe
    80002318:	22c080e7          	jalr	556(ra) # 80000540 <panic>

000000008000231c <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000231c:	7179                	addi	sp,sp,-48
    8000231e:	f406                	sd	ra,40(sp)
    80002320:	f022                	sd	s0,32(sp)
    80002322:	ec26                	sd	s1,24(sp)
    80002324:	e84a                	sd	s2,16(sp)
    80002326:	e44e                	sd	s3,8(sp)
    80002328:	1800                	addi	s0,sp,48
    8000232a:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000232c:	0000f497          	auipc	s1,0xf
    80002330:	c9448493          	addi	s1,s1,-876 # 80010fc0 <proc>
    80002334:	00016997          	auipc	s3,0x16
    80002338:	c8c98993          	addi	s3,s3,-884 # 80017fc0 <mlfq>
  {
    acquire(&p->lock);
    8000233c:	8526                	mv	a0,s1
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	898080e7          	jalr	-1896(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    80002346:	589c                	lw	a5,48(s1)
    80002348:	01278d63          	beq	a5,s2,80002362 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000234c:	8526                	mv	a0,s1
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	93c080e7          	jalr	-1732(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002356:	1c048493          	addi	s1,s1,448
    8000235a:	ff3491e3          	bne	s1,s3,8000233c <kill+0x20>
  }
  return -1;
    8000235e:	557d                	li	a0,-1
    80002360:	a829                	j	8000237a <kill+0x5e>
      p->killed = 1;
    80002362:	4785                	li	a5,1
    80002364:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002366:	4c98                	lw	a4,24(s1)
    80002368:	4789                	li	a5,2
    8000236a:	00f70f63          	beq	a4,a5,80002388 <kill+0x6c>
      release(&p->lock);
    8000236e:	8526                	mv	a0,s1
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	91a080e7          	jalr	-1766(ra) # 80000c8a <release>
      return 0;
    80002378:	4501                	li	a0,0
}
    8000237a:	70a2                	ld	ra,40(sp)
    8000237c:	7402                	ld	s0,32(sp)
    8000237e:	64e2                	ld	s1,24(sp)
    80002380:	6942                	ld	s2,16(sp)
    80002382:	69a2                	ld	s3,8(sp)
    80002384:	6145                	addi	sp,sp,48
    80002386:	8082                	ret
        p->state = RUNNABLE;
    80002388:	478d                	li	a5,3
    8000238a:	cc9c                	sw	a5,24(s1)
    8000238c:	b7cd                	j	8000236e <kill+0x52>

000000008000238e <setkilled>:

void setkilled(struct proc *p)
{
    8000238e:	1101                	addi	sp,sp,-32
    80002390:	ec06                	sd	ra,24(sp)
    80002392:	e822                	sd	s0,16(sp)
    80002394:	e426                	sd	s1,8(sp)
    80002396:	1000                	addi	s0,sp,32
    80002398:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	83c080e7          	jalr	-1988(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800023a2:	4785                	li	a5,1
    800023a4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023a6:	8526                	mv	a0,s1
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	8e2080e7          	jalr	-1822(ra) # 80000c8a <release>
}
    800023b0:	60e2                	ld	ra,24(sp)
    800023b2:	6442                	ld	s0,16(sp)
    800023b4:	64a2                	ld	s1,8(sp)
    800023b6:	6105                	addi	sp,sp,32
    800023b8:	8082                	ret

00000000800023ba <killed>:

int killed(struct proc *p)
{
    800023ba:	1101                	addi	sp,sp,-32
    800023bc:	ec06                	sd	ra,24(sp)
    800023be:	e822                	sd	s0,16(sp)
    800023c0:	e426                	sd	s1,8(sp)
    800023c2:	e04a                	sd	s2,0(sp)
    800023c4:	1000                	addi	s0,sp,32
    800023c6:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	80e080e7          	jalr	-2034(ra) # 80000bd6 <acquire>
  k = p->killed;
    800023d0:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023d4:	8526                	mv	a0,s1
    800023d6:	fffff097          	auipc	ra,0xfffff
    800023da:	8b4080e7          	jalr	-1868(ra) # 80000c8a <release>
  return k;
}
    800023de:	854a                	mv	a0,s2
    800023e0:	60e2                	ld	ra,24(sp)
    800023e2:	6442                	ld	s0,16(sp)
    800023e4:	64a2                	ld	s1,8(sp)
    800023e6:	6902                	ld	s2,0(sp)
    800023e8:	6105                	addi	sp,sp,32
    800023ea:	8082                	ret

00000000800023ec <wait>:
{
    800023ec:	715d                	addi	sp,sp,-80
    800023ee:	e486                	sd	ra,72(sp)
    800023f0:	e0a2                	sd	s0,64(sp)
    800023f2:	fc26                	sd	s1,56(sp)
    800023f4:	f84a                	sd	s2,48(sp)
    800023f6:	f44e                	sd	s3,40(sp)
    800023f8:	f052                	sd	s4,32(sp)
    800023fa:	ec56                	sd	s5,24(sp)
    800023fc:	e85a                	sd	s6,16(sp)
    800023fe:	e45e                	sd	s7,8(sp)
    80002400:	e062                	sd	s8,0(sp)
    80002402:	0880                	addi	s0,sp,80
    80002404:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	5a6080e7          	jalr	1446(ra) # 800019ac <myproc>
    8000240e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002410:	0000e517          	auipc	a0,0xe
    80002414:	79850513          	addi	a0,a0,1944 # 80010ba8 <wait_lock>
    80002418:	ffffe097          	auipc	ra,0xffffe
    8000241c:	7be080e7          	jalr	1982(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002420:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002422:	4a15                	li	s4,5
        havekids = 1;
    80002424:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002426:	00016997          	auipc	s3,0x16
    8000242a:	b9a98993          	addi	s3,s3,-1126 # 80017fc0 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000242e:	0000ec17          	auipc	s8,0xe
    80002432:	77ac0c13          	addi	s8,s8,1914 # 80010ba8 <wait_lock>
    havekids = 0;
    80002436:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002438:	0000f497          	auipc	s1,0xf
    8000243c:	b8848493          	addi	s1,s1,-1144 # 80010fc0 <proc>
    80002440:	a0bd                	j	800024ae <wait+0xc2>
          pid = pp->pid;
    80002442:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002446:	000b0e63          	beqz	s6,80002462 <wait+0x76>
    8000244a:	4691                	li	a3,4
    8000244c:	02c48613          	addi	a2,s1,44
    80002450:	85da                	mv	a1,s6
    80002452:	05093503          	ld	a0,80(s2)
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	216080e7          	jalr	534(ra) # 8000166c <copyout>
    8000245e:	02054563          	bltz	a0,80002488 <wait+0x9c>
          freeproc(pp);
    80002462:	8526                	mv	a0,s1
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	6fa080e7          	jalr	1786(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    8000246c:	8526                	mv	a0,s1
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	81c080e7          	jalr	-2020(ra) # 80000c8a <release>
          release(&wait_lock);
    80002476:	0000e517          	auipc	a0,0xe
    8000247a:	73250513          	addi	a0,a0,1842 # 80010ba8 <wait_lock>
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	80c080e7          	jalr	-2036(ra) # 80000c8a <release>
          return pid;
    80002486:	a0b5                	j	800024f2 <wait+0x106>
            release(&pp->lock);
    80002488:	8526                	mv	a0,s1
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	800080e7          	jalr	-2048(ra) # 80000c8a <release>
            release(&wait_lock);
    80002492:	0000e517          	auipc	a0,0xe
    80002496:	71650513          	addi	a0,a0,1814 # 80010ba8 <wait_lock>
    8000249a:	ffffe097          	auipc	ra,0xffffe
    8000249e:	7f0080e7          	jalr	2032(ra) # 80000c8a <release>
            return -1;
    800024a2:	59fd                	li	s3,-1
    800024a4:	a0b9                	j	800024f2 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024a6:	1c048493          	addi	s1,s1,448
    800024aa:	03348463          	beq	s1,s3,800024d2 <wait+0xe6>
      if (pp->parent == p)
    800024ae:	7c9c                	ld	a5,56(s1)
    800024b0:	ff279be3          	bne	a5,s2,800024a6 <wait+0xba>
        acquire(&pp->lock);
    800024b4:	8526                	mv	a0,s1
    800024b6:	ffffe097          	auipc	ra,0xffffe
    800024ba:	720080e7          	jalr	1824(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    800024be:	4c9c                	lw	a5,24(s1)
    800024c0:	f94781e3          	beq	a5,s4,80002442 <wait+0x56>
        release(&pp->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	ffffe097          	auipc	ra,0xffffe
    800024ca:	7c4080e7          	jalr	1988(ra) # 80000c8a <release>
        havekids = 1;
    800024ce:	8756                	mv	a4,s5
    800024d0:	bfd9                	j	800024a6 <wait+0xba>
    if (!havekids || killed(p))
    800024d2:	c719                	beqz	a4,800024e0 <wait+0xf4>
    800024d4:	854a                	mv	a0,s2
    800024d6:	00000097          	auipc	ra,0x0
    800024da:	ee4080e7          	jalr	-284(ra) # 800023ba <killed>
    800024de:	c51d                	beqz	a0,8000250c <wait+0x120>
      release(&wait_lock);
    800024e0:	0000e517          	auipc	a0,0xe
    800024e4:	6c850513          	addi	a0,a0,1736 # 80010ba8 <wait_lock>
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	7a2080e7          	jalr	1954(ra) # 80000c8a <release>
      return -1;
    800024f0:	59fd                	li	s3,-1
}
    800024f2:	854e                	mv	a0,s3
    800024f4:	60a6                	ld	ra,72(sp)
    800024f6:	6406                	ld	s0,64(sp)
    800024f8:	74e2                	ld	s1,56(sp)
    800024fa:	7942                	ld	s2,48(sp)
    800024fc:	79a2                	ld	s3,40(sp)
    800024fe:	7a02                	ld	s4,32(sp)
    80002500:	6ae2                	ld	s5,24(sp)
    80002502:	6b42                	ld	s6,16(sp)
    80002504:	6ba2                	ld	s7,8(sp)
    80002506:	6c02                	ld	s8,0(sp)
    80002508:	6161                	addi	sp,sp,80
    8000250a:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000250c:	85e2                	mv	a1,s8
    8000250e:	854a                	mv	a0,s2
    80002510:	00000097          	auipc	ra,0x0
    80002514:	bca080e7          	jalr	-1078(ra) # 800020da <sleep>
    havekids = 0;
    80002518:	bf39                	j	80002436 <wait+0x4a>

000000008000251a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000251a:	7179                	addi	sp,sp,-48
    8000251c:	f406                	sd	ra,40(sp)
    8000251e:	f022                	sd	s0,32(sp)
    80002520:	ec26                	sd	s1,24(sp)
    80002522:	e84a                	sd	s2,16(sp)
    80002524:	e44e                	sd	s3,8(sp)
    80002526:	e052                	sd	s4,0(sp)
    80002528:	1800                	addi	s0,sp,48
    8000252a:	84aa                	mv	s1,a0
    8000252c:	892e                	mv	s2,a1
    8000252e:	89b2                	mv	s3,a2
    80002530:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	47a080e7          	jalr	1146(ra) # 800019ac <myproc>
  if (user_dst)
    8000253a:	c08d                	beqz	s1,8000255c <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000253c:	86d2                	mv	a3,s4
    8000253e:	864e                	mv	a2,s3
    80002540:	85ca                	mv	a1,s2
    80002542:	6928                	ld	a0,80(a0)
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	128080e7          	jalr	296(ra) # 8000166c <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000254c:	70a2                	ld	ra,40(sp)
    8000254e:	7402                	ld	s0,32(sp)
    80002550:	64e2                	ld	s1,24(sp)
    80002552:	6942                	ld	s2,16(sp)
    80002554:	69a2                	ld	s3,8(sp)
    80002556:	6a02                	ld	s4,0(sp)
    80002558:	6145                	addi	sp,sp,48
    8000255a:	8082                	ret
    memmove((char *)dst, src, len);
    8000255c:	000a061b          	sext.w	a2,s4
    80002560:	85ce                	mv	a1,s3
    80002562:	854a                	mv	a0,s2
    80002564:	ffffe097          	auipc	ra,0xffffe
    80002568:	7ca080e7          	jalr	1994(ra) # 80000d2e <memmove>
    return 0;
    8000256c:	8526                	mv	a0,s1
    8000256e:	bff9                	j	8000254c <either_copyout+0x32>

0000000080002570 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002570:	7179                	addi	sp,sp,-48
    80002572:	f406                	sd	ra,40(sp)
    80002574:	f022                	sd	s0,32(sp)
    80002576:	ec26                	sd	s1,24(sp)
    80002578:	e84a                	sd	s2,16(sp)
    8000257a:	e44e                	sd	s3,8(sp)
    8000257c:	e052                	sd	s4,0(sp)
    8000257e:	1800                	addi	s0,sp,48
    80002580:	892a                	mv	s2,a0
    80002582:	84ae                	mv	s1,a1
    80002584:	89b2                	mv	s3,a2
    80002586:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002588:	fffff097          	auipc	ra,0xfffff
    8000258c:	424080e7          	jalr	1060(ra) # 800019ac <myproc>
  if (user_src)
    80002590:	c08d                	beqz	s1,800025b2 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002592:	86d2                	mv	a3,s4
    80002594:	864e                	mv	a2,s3
    80002596:	85ca                	mv	a1,s2
    80002598:	6928                	ld	a0,80(a0)
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	15e080e7          	jalr	350(ra) # 800016f8 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800025a2:	70a2                	ld	ra,40(sp)
    800025a4:	7402                	ld	s0,32(sp)
    800025a6:	64e2                	ld	s1,24(sp)
    800025a8:	6942                	ld	s2,16(sp)
    800025aa:	69a2                	ld	s3,8(sp)
    800025ac:	6a02                	ld	s4,0(sp)
    800025ae:	6145                	addi	sp,sp,48
    800025b0:	8082                	ret
    memmove(dst, (char *)src, len);
    800025b2:	000a061b          	sext.w	a2,s4
    800025b6:	85ce                	mv	a1,s3
    800025b8:	854a                	mv	a0,s2
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	774080e7          	jalr	1908(ra) # 80000d2e <memmove>
    return 0;
    800025c2:	8526                	mv	a0,s1
    800025c4:	bff9                	j	800025a2 <either_copyin+0x32>

00000000800025c6 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800025c6:	715d                	addi	sp,sp,-80
    800025c8:	e486                	sd	ra,72(sp)
    800025ca:	e0a2                	sd	s0,64(sp)
    800025cc:	fc26                	sd	s1,56(sp)
    800025ce:	f84a                	sd	s2,48(sp)
    800025d0:	f44e                	sd	s3,40(sp)
    800025d2:	f052                	sd	s4,32(sp)
    800025d4:	ec56                	sd	s5,24(sp)
    800025d6:	e85a                	sd	s6,16(sp)
    800025d8:	e45e                	sd	s7,8(sp)
    800025da:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800025dc:	00006517          	auipc	a0,0x6
    800025e0:	aec50513          	addi	a0,a0,-1300 # 800080c8 <digits+0x88>
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	fa6080e7          	jalr	-90(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800025ec:	0000f497          	auipc	s1,0xf
    800025f0:	b2c48493          	addi	s1,s1,-1236 # 80011118 <proc+0x158>
    800025f4:	00016917          	auipc	s2,0x16
    800025f8:	b2490913          	addi	s2,s2,-1244 # 80018118 <mlfq+0x158>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025fc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025fe:	00006997          	auipc	s3,0x6
    80002602:	c8298993          	addi	s3,s3,-894 # 80008280 <digits+0x240>
    printf("%d %s %s ctime=%d", p->pid, state, p->name, p->ctime);
    80002606:	00006a97          	auipc	s5,0x6
    8000260a:	c82a8a93          	addi	s5,s5,-894 # 80008288 <digits+0x248>
    printf("\n");
    8000260e:	00006a17          	auipc	s4,0x6
    80002612:	abaa0a13          	addi	s4,s4,-1350 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002616:	00006b97          	auipc	s7,0x6
    8000261a:	cbab8b93          	addi	s7,s7,-838 # 800082d0 <states.0>
    8000261e:	a015                	j	80002642 <procdump+0x7c>
    printf("%d %s %s ctime=%d", p->pid, state, p->name, p->ctime);
    80002620:	4ad8                	lw	a4,20(a3)
    80002622:	ed86a583          	lw	a1,-296(a3)
    80002626:	8556                	mv	a0,s5
    80002628:	ffffe097          	auipc	ra,0xffffe
    8000262c:	f62080e7          	jalr	-158(ra) # 8000058a <printf>
    printf("\n");
    80002630:	8552                	mv	a0,s4
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	f58080e7          	jalr	-168(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000263a:	1c048493          	addi	s1,s1,448
    8000263e:	03248263          	beq	s1,s2,80002662 <procdump+0x9c>
    if (p->state == UNUSED)
    80002642:	86a6                	mv	a3,s1
    80002644:	ec04a783          	lw	a5,-320(s1)
    80002648:	dbed                	beqz	a5,8000263a <procdump+0x74>
      state = "???";
    8000264a:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000264c:	fcfb6ae3          	bltu	s6,a5,80002620 <procdump+0x5a>
    80002650:	02079713          	slli	a4,a5,0x20
    80002654:	01d75793          	srli	a5,a4,0x1d
    80002658:	97de                	add	a5,a5,s7
    8000265a:	6390                	ld	a2,0(a5)
    8000265c:	f271                	bnez	a2,80002620 <procdump+0x5a>
      state = "???";
    8000265e:	864e                	mv	a2,s3
    80002660:	b7c1                	j	80002620 <procdump+0x5a>
  }
}
    80002662:	60a6                	ld	ra,72(sp)
    80002664:	6406                	ld	s0,64(sp)
    80002666:	74e2                	ld	s1,56(sp)
    80002668:	7942                	ld	s2,48(sp)
    8000266a:	79a2                	ld	s3,40(sp)
    8000266c:	7a02                	ld	s4,32(sp)
    8000266e:	6ae2                	ld	s5,24(sp)
    80002670:	6b42                	ld	s6,16(sp)
    80002672:	6ba2                	ld	s7,8(sp)
    80002674:	6161                	addi	sp,sp,80
    80002676:	8082                	ret

0000000080002678 <waitx>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002678:	711d                	addi	sp,sp,-96
    8000267a:	ec86                	sd	ra,88(sp)
    8000267c:	e8a2                	sd	s0,80(sp)
    8000267e:	e4a6                	sd	s1,72(sp)
    80002680:	e0ca                	sd	s2,64(sp)
    80002682:	fc4e                	sd	s3,56(sp)
    80002684:	f852                	sd	s4,48(sp)
    80002686:	f456                	sd	s5,40(sp)
    80002688:	f05a                	sd	s6,32(sp)
    8000268a:	ec5e                	sd	s7,24(sp)
    8000268c:	e862                	sd	s8,16(sp)
    8000268e:	e466                	sd	s9,8(sp)
    80002690:	e06a                	sd	s10,0(sp)
    80002692:	1080                	addi	s0,sp,96
    80002694:	8b2a                	mv	s6,a0
    80002696:	8bae                	mv	s7,a1
    80002698:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000269a:	fffff097          	auipc	ra,0xfffff
    8000269e:	312080e7          	jalr	786(ra) # 800019ac <myproc>
    800026a2:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800026a4:	0000e517          	auipc	a0,0xe
    800026a8:	50450513          	addi	a0,a0,1284 # 80010ba8 <wait_lock>
    800026ac:	ffffe097          	auipc	ra,0xffffe
    800026b0:	52a080e7          	jalr	1322(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800026b4:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800026b6:	4a15                	li	s4,5
        havekids = 1;
    800026b8:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800026ba:	00016997          	auipc	s3,0x16
    800026be:	90698993          	addi	s3,s3,-1786 # 80017fc0 <mlfq>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800026c2:	0000ed17          	auipc	s10,0xe
    800026c6:	4e6d0d13          	addi	s10,s10,1254 # 80010ba8 <wait_lock>
    havekids = 0;
    800026ca:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800026cc:	0000f497          	auipc	s1,0xf
    800026d0:	8f448493          	addi	s1,s1,-1804 # 80010fc0 <proc>
    800026d4:	a059                	j	8000275a <waitx+0xe2>
          pid = np->pid;
    800026d6:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800026da:	1684a783          	lw	a5,360(s1)
    800026de:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800026e2:	16c4a703          	lw	a4,364(s1)
    800026e6:	9f3d                	addw	a4,a4,a5
    800026e8:	1704a783          	lw	a5,368(s1)
    800026ec:	9f99                	subw	a5,a5,a4
    800026ee:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800026f2:	000b0e63          	beqz	s6,8000270e <waitx+0x96>
    800026f6:	4691                	li	a3,4
    800026f8:	02c48613          	addi	a2,s1,44
    800026fc:	85da                	mv	a1,s6
    800026fe:	05093503          	ld	a0,80(s2)
    80002702:	fffff097          	auipc	ra,0xfffff
    80002706:	f6a080e7          	jalr	-150(ra) # 8000166c <copyout>
    8000270a:	02054563          	bltz	a0,80002734 <waitx+0xbc>
          freeproc(np);
    8000270e:	8526                	mv	a0,s1
    80002710:	fffff097          	auipc	ra,0xfffff
    80002714:	44e080e7          	jalr	1102(ra) # 80001b5e <freeproc>
          release(&np->lock);
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	570080e7          	jalr	1392(ra) # 80000c8a <release>
          release(&wait_lock);
    80002722:	0000e517          	auipc	a0,0xe
    80002726:	48650513          	addi	a0,a0,1158 # 80010ba8 <wait_lock>
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	560080e7          	jalr	1376(ra) # 80000c8a <release>
          return pid;
    80002732:	a09d                	j	80002798 <waitx+0x120>
            release(&np->lock);
    80002734:	8526                	mv	a0,s1
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	554080e7          	jalr	1364(ra) # 80000c8a <release>
            release(&wait_lock);
    8000273e:	0000e517          	auipc	a0,0xe
    80002742:	46a50513          	addi	a0,a0,1130 # 80010ba8 <wait_lock>
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	544080e7          	jalr	1348(ra) # 80000c8a <release>
            return -1;
    8000274e:	59fd                	li	s3,-1
    80002750:	a0a1                	j	80002798 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002752:	1c048493          	addi	s1,s1,448
    80002756:	03348463          	beq	s1,s3,8000277e <waitx+0x106>
      if (np->parent == p)
    8000275a:	7c9c                	ld	a5,56(s1)
    8000275c:	ff279be3          	bne	a5,s2,80002752 <waitx+0xda>
        acquire(&np->lock);
    80002760:	8526                	mv	a0,s1
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	474080e7          	jalr	1140(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    8000276a:	4c9c                	lw	a5,24(s1)
    8000276c:	f74785e3          	beq	a5,s4,800026d6 <waitx+0x5e>
        release(&np->lock);
    80002770:	8526                	mv	a0,s1
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	518080e7          	jalr	1304(ra) # 80000c8a <release>
        havekids = 1;
    8000277a:	8756                	mv	a4,s5
    8000277c:	bfd9                	j	80002752 <waitx+0xda>
    if (!havekids || p->killed)
    8000277e:	c701                	beqz	a4,80002786 <waitx+0x10e>
    80002780:	02892783          	lw	a5,40(s2)
    80002784:	cb8d                	beqz	a5,800027b6 <waitx+0x13e>
      release(&wait_lock);
    80002786:	0000e517          	auipc	a0,0xe
    8000278a:	42250513          	addi	a0,a0,1058 # 80010ba8 <wait_lock>
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	4fc080e7          	jalr	1276(ra) # 80000c8a <release>
      return -1;
    80002796:	59fd                	li	s3,-1
  }
}
    80002798:	854e                	mv	a0,s3
    8000279a:	60e6                	ld	ra,88(sp)
    8000279c:	6446                	ld	s0,80(sp)
    8000279e:	64a6                	ld	s1,72(sp)
    800027a0:	6906                	ld	s2,64(sp)
    800027a2:	79e2                	ld	s3,56(sp)
    800027a4:	7a42                	ld	s4,48(sp)
    800027a6:	7aa2                	ld	s5,40(sp)
    800027a8:	7b02                	ld	s6,32(sp)
    800027aa:	6be2                	ld	s7,24(sp)
    800027ac:	6c42                	ld	s8,16(sp)
    800027ae:	6ca2                	ld	s9,8(sp)
    800027b0:	6d02                	ld	s10,0(sp)
    800027b2:	6125                	addi	sp,sp,96
    800027b4:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027b6:	85ea                	mv	a1,s10
    800027b8:	854a                	mv	a0,s2
    800027ba:	00000097          	auipc	ra,0x0
    800027be:	920080e7          	jalr	-1760(ra) # 800020da <sleep>
    havekids = 0;
    800027c2:	b721                	j	800026ca <waitx+0x52>

00000000800027c4 <update_time>:

void update_time()
{
    800027c4:	7179                	addi	sp,sp,-48
    800027c6:	f406                	sd	ra,40(sp)
    800027c8:	f022                	sd	s0,32(sp)
    800027ca:	ec26                	sd	s1,24(sp)
    800027cc:	e84a                	sd	s2,16(sp)
    800027ce:	e44e                	sd	s3,8(sp)
    800027d0:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    800027d2:	0000e497          	auipc	s1,0xe
    800027d6:	7ee48493          	addi	s1,s1,2030 # 80010fc0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    800027da:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    800027dc:	00015917          	auipc	s2,0x15
    800027e0:	7e490913          	addi	s2,s2,2020 # 80017fc0 <mlfq>
    800027e4:	a811                	j	800027f8 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    800027e6:	8526                	mv	a0,s1
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	4a2080e7          	jalr	1186(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800027f0:	1c048493          	addi	s1,s1,448
    800027f4:	03248063          	beq	s1,s2,80002814 <update_time+0x50>
    acquire(&p->lock);
    800027f8:	8526                	mv	a0,s1
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	3dc080e7          	jalr	988(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    80002802:	4c9c                	lw	a5,24(s1)
    80002804:	ff3791e3          	bne	a5,s3,800027e6 <update_time+0x22>
      p->rtime++;
    80002808:	1684a783          	lw	a5,360(s1)
    8000280c:	2785                	addiw	a5,a5,1
    8000280e:	16f4a423          	sw	a5,360(s1)
    80002812:	bfd1                	j	800027e6 <update_time+0x22>
  }
    80002814:	70a2                	ld	ra,40(sp)
    80002816:	7402                	ld	s0,32(sp)
    80002818:	64e2                	ld	s1,24(sp)
    8000281a:	6942                	ld	s2,16(sp)
    8000281c:	69a2                	ld	s3,8(sp)
    8000281e:	6145                	addi	sp,sp,48
    80002820:	8082                	ret

0000000080002822 <swtch>:
    80002822:	00153023          	sd	ra,0(a0)
    80002826:	00253423          	sd	sp,8(a0)
    8000282a:	e900                	sd	s0,16(a0)
    8000282c:	ed04                	sd	s1,24(a0)
    8000282e:	03253023          	sd	s2,32(a0)
    80002832:	03353423          	sd	s3,40(a0)
    80002836:	03453823          	sd	s4,48(a0)
    8000283a:	03553c23          	sd	s5,56(a0)
    8000283e:	05653023          	sd	s6,64(a0)
    80002842:	05753423          	sd	s7,72(a0)
    80002846:	05853823          	sd	s8,80(a0)
    8000284a:	05953c23          	sd	s9,88(a0)
    8000284e:	07a53023          	sd	s10,96(a0)
    80002852:	07b53423          	sd	s11,104(a0)
    80002856:	0005b083          	ld	ra,0(a1)
    8000285a:	0085b103          	ld	sp,8(a1)
    8000285e:	6980                	ld	s0,16(a1)
    80002860:	6d84                	ld	s1,24(a1)
    80002862:	0205b903          	ld	s2,32(a1)
    80002866:	0285b983          	ld	s3,40(a1)
    8000286a:	0305ba03          	ld	s4,48(a1)
    8000286e:	0385ba83          	ld	s5,56(a1)
    80002872:	0405bb03          	ld	s6,64(a1)
    80002876:	0485bb83          	ld	s7,72(a1)
    8000287a:	0505bc03          	ld	s8,80(a1)
    8000287e:	0585bc83          	ld	s9,88(a1)
    80002882:	0605bd03          	ld	s10,96(a1)
    80002886:	0685bd83          	ld	s11,104(a1)
    8000288a:	8082                	ret

000000008000288c <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000288c:	1141                	addi	sp,sp,-16
    8000288e:	e406                	sd	ra,8(sp)
    80002890:	e022                	sd	s0,0(sp)
    80002892:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002894:	00006597          	auipc	a1,0x6
    80002898:	a6c58593          	addi	a1,a1,-1428 # 80008300 <states.0+0x30>
    8000289c:	00016517          	auipc	a0,0x16
    800028a0:	14c50513          	addi	a0,a0,332 # 800189e8 <tickslock>
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	2a2080e7          	jalr	674(ra) # 80000b46 <initlock>
}
    800028ac:	60a2                	ld	ra,8(sp)
    800028ae:	6402                	ld	s0,0(sp)
    800028b0:	0141                	addi	sp,sp,16
    800028b2:	8082                	ret

00000000800028b4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    800028b4:	1141                	addi	sp,sp,-16
    800028b6:	e422                	sd	s0,8(sp)
    800028b8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0"
    800028ba:	00003797          	auipc	a5,0x3
    800028be:	60678793          	addi	a5,a5,1542 # 80005ec0 <kernelvec>
    800028c2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028c6:	6422                	ld	s0,8(sp)
    800028c8:	0141                	addi	sp,sp,16
    800028ca:	8082                	ret

00000000800028cc <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    800028cc:	1141                	addi	sp,sp,-16
    800028ce:	e406                	sd	ra,8(sp)
    800028d0:	e022                	sd	s0,0(sp)
    800028d2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028d4:	fffff097          	auipc	ra,0xfffff
    800028d8:	0d8080e7          	jalr	216(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus"
    800028dc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028e0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    800028e2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800028e6:	00004697          	auipc	a3,0x4
    800028ea:	71a68693          	addi	a3,a3,1818 # 80007000 <_trampoline>
    800028ee:	00004717          	auipc	a4,0x4
    800028f2:	71270713          	addi	a4,a4,1810 # 80007000 <_trampoline>
    800028f6:	8f15                	sub	a4,a4,a3
    800028f8:	040007b7          	lui	a5,0x4000
    800028fc:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800028fe:	07b2                	slli	a5,a5,0xc
    80002900:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0"
    80002902:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002906:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp"
    80002908:	18002673          	csrr	a2,satp
    8000290c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000290e:	6d30                	ld	a2,88(a0)
    80002910:	6138                	ld	a4,64(a0)
    80002912:	6585                	lui	a1,0x1
    80002914:	972e                	add	a4,a4,a1
    80002916:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002918:	6d38                	ld	a4,88(a0)
    8000291a:	00000617          	auipc	a2,0x0
    8000291e:	13e60613          	addi	a2,a2,318 # 80002a58 <usertrap>
    80002922:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002924:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp"
    80002926:	8612                	mv	a2,tp
    80002928:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus"
    8000292a:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000292e:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002932:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0"
    80002936:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000293a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0"
    8000293c:	6f18                	ld	a4,24(a4)
    8000293e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002942:	6928                	ld	a0,80(a0)
    80002944:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002946:	00004717          	auipc	a4,0x4
    8000294a:	75670713          	addi	a4,a4,1878 # 8000709c <userret>
    8000294e:	8f15                	sub	a4,a4,a3
    80002950:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002952:	577d                	li	a4,-1
    80002954:	177e                	slli	a4,a4,0x3f
    80002956:	8d59                	or	a0,a0,a4
    80002958:	9782                	jalr	a5
}
    8000295a:	60a2                	ld	ra,8(sp)
    8000295c:	6402                	ld	s0,0(sp)
    8000295e:	0141                	addi	sp,sp,16
    80002960:	8082                	ret

0000000080002962 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002962:	1101                	addi	sp,sp,-32
    80002964:	ec06                	sd	ra,24(sp)
    80002966:	e822                	sd	s0,16(sp)
    80002968:	e426                	sd	s1,8(sp)
    8000296a:	e04a                	sd	s2,0(sp)
    8000296c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000296e:	00016917          	auipc	s2,0x16
    80002972:	07a90913          	addi	s2,s2,122 # 800189e8 <tickslock>
    80002976:	854a                	mv	a0,s2
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	25e080e7          	jalr	606(ra) # 80000bd6 <acquire>
  ticks++;
    80002980:	00006497          	auipc	s1,0x6
    80002984:	fa848493          	addi	s1,s1,-88 # 80008928 <ticks>
    80002988:	409c                	lw	a5,0(s1)
    8000298a:	2785                	addiw	a5,a5,1
    8000298c:	c09c                	sw	a5,0(s1)
  update_time();
    8000298e:	00000097          	auipc	ra,0x0
    80002992:	e36080e7          	jalr	-458(ra) # 800027c4 <update_time>
  // if (myproc() != 0)
  // {
  //   myproc()->running_ticks++;
  //   myproc()->change_queue--;
  // }
  wakeup(&ticks);
    80002996:	8526                	mv	a0,s1
    80002998:	fffff097          	auipc	ra,0xfffff
    8000299c:	7b2080e7          	jalr	1970(ra) # 8000214a <wakeup>
  release(&tickslock);
    800029a0:	854a                	mv	a0,s2
    800029a2:	ffffe097          	auipc	ra,0xffffe
    800029a6:	2e8080e7          	jalr	744(ra) # 80000c8a <release>
}
    800029aa:	60e2                	ld	ra,24(sp)
    800029ac:	6442                	ld	s0,16(sp)
    800029ae:	64a2                	ld	s1,8(sp)
    800029b0:	6902                	ld	s2,0(sp)
    800029b2:	6105                	addi	sp,sp,32
    800029b4:	8082                	ret

00000000800029b6 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    800029b6:	1101                	addi	sp,sp,-32
    800029b8:	ec06                	sd	ra,24(sp)
    800029ba:	e822                	sd	s0,16(sp)
    800029bc:	e426                	sd	s1,8(sp)
    800029be:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause"
    800029c0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    800029c4:	00074d63          	bltz	a4,800029de <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    800029c8:	57fd                	li	a5,-1
    800029ca:	17fe                	slli	a5,a5,0x3f
    800029cc:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    800029ce:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    800029d0:	06f70363          	beq	a4,a5,80002a36 <devintr+0x80>
  }
}
    800029d4:	60e2                	ld	ra,24(sp)
    800029d6:	6442                	ld	s0,16(sp)
    800029d8:	64a2                	ld	s1,8(sp)
    800029da:	6105                	addi	sp,sp,32
    800029dc:	8082                	ret
      (scause & 0xff) == 9)
    800029de:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    800029e2:	46a5                	li	a3,9
    800029e4:	fed792e3          	bne	a5,a3,800029c8 <devintr+0x12>
    int irq = plic_claim();
    800029e8:	00003097          	auipc	ra,0x3
    800029ec:	5e0080e7          	jalr	1504(ra) # 80005fc8 <plic_claim>
    800029f0:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    800029f2:	47a9                	li	a5,10
    800029f4:	02f50763          	beq	a0,a5,80002a22 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    800029f8:	4785                	li	a5,1
    800029fa:	02f50963          	beq	a0,a5,80002a2c <devintr+0x76>
    return 1;
    800029fe:	4505                	li	a0,1
    else if (irq)
    80002a00:	d8f1                	beqz	s1,800029d4 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a02:	85a6                	mv	a1,s1
    80002a04:	00006517          	auipc	a0,0x6
    80002a08:	90450513          	addi	a0,a0,-1788 # 80008308 <states.0+0x38>
    80002a0c:	ffffe097          	auipc	ra,0xffffe
    80002a10:	b7e080e7          	jalr	-1154(ra) # 8000058a <printf>
      plic_complete(irq);
    80002a14:	8526                	mv	a0,s1
    80002a16:	00003097          	auipc	ra,0x3
    80002a1a:	5d6080e7          	jalr	1494(ra) # 80005fec <plic_complete>
    return 1;
    80002a1e:	4505                	li	a0,1
    80002a20:	bf55                	j	800029d4 <devintr+0x1e>
      uartintr();
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	f76080e7          	jalr	-138(ra) # 80000998 <uartintr>
    80002a2a:	b7ed                	j	80002a14 <devintr+0x5e>
      virtio_disk_intr();
    80002a2c:	00004097          	auipc	ra,0x4
    80002a30:	d5c080e7          	jalr	-676(ra) # 80006788 <virtio_disk_intr>
    80002a34:	b7c5                	j	80002a14 <devintr+0x5e>
    if (cpuid() == 0)
    80002a36:	fffff097          	auipc	ra,0xfffff
    80002a3a:	f4a080e7          	jalr	-182(ra) # 80001980 <cpuid>
    80002a3e:	c901                	beqz	a0,80002a4e <devintr+0x98>
  asm volatile("csrr %0, sip"
    80002a40:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a44:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0"
    80002a46:	14479073          	csrw	sip,a5
    return 2;
    80002a4a:	4509                	li	a0,2
    80002a4c:	b761                	j	800029d4 <devintr+0x1e>
      clockintr();
    80002a4e:	00000097          	auipc	ra,0x0
    80002a52:	f14080e7          	jalr	-236(ra) # 80002962 <clockintr>
    80002a56:	b7ed                	j	80002a40 <devintr+0x8a>

0000000080002a58 <usertrap>:
{
    80002a58:	1101                	addi	sp,sp,-32
    80002a5a:	ec06                	sd	ra,24(sp)
    80002a5c:	e822                	sd	s0,16(sp)
    80002a5e:	e426                	sd	s1,8(sp)
    80002a60:	e04a                	sd	s2,0(sp)
    80002a62:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80002a64:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002a68:	1007f793          	andi	a5,a5,256
    80002a6c:	e3b1                	bnez	a5,80002ab0 <usertrap+0x58>
  asm volatile("csrw stvec, %0"
    80002a6e:	00003797          	auipc	a5,0x3
    80002a72:	45278793          	addi	a5,a5,1106 # 80005ec0 <kernelvec>
    80002a76:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a7a:	fffff097          	auipc	ra,0xfffff
    80002a7e:	f32080e7          	jalr	-206(ra) # 800019ac <myproc>
    80002a82:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a84:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc"
    80002a86:	14102773          	csrr	a4,sepc
    80002a8a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause"
    80002a8c:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002a90:	47a1                	li	a5,8
    80002a92:	02f70763          	beq	a4,a5,80002ac0 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002a96:	00000097          	auipc	ra,0x0
    80002a9a:	f20080e7          	jalr	-224(ra) # 800029b6 <devintr>
    80002a9e:	892a                	mv	s2,a0
    80002aa0:	c151                	beqz	a0,80002b24 <usertrap+0xcc>
  if (killed(p))
    80002aa2:	8526                	mv	a0,s1
    80002aa4:	00000097          	auipc	ra,0x0
    80002aa8:	916080e7          	jalr	-1770(ra) # 800023ba <killed>
    80002aac:	c929                	beqz	a0,80002afe <usertrap+0xa6>
    80002aae:	a099                	j	80002af4 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002ab0:	00006517          	auipc	a0,0x6
    80002ab4:	87850513          	addi	a0,a0,-1928 # 80008328 <states.0+0x58>
    80002ab8:	ffffe097          	auipc	ra,0xffffe
    80002abc:	a88080e7          	jalr	-1400(ra) # 80000540 <panic>
    if (killed(p))
    80002ac0:	00000097          	auipc	ra,0x0
    80002ac4:	8fa080e7          	jalr	-1798(ra) # 800023ba <killed>
    80002ac8:	e921                	bnez	a0,80002b18 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002aca:	6cb8                	ld	a4,88(s1)
    80002acc:	6f1c                	ld	a5,24(a4)
    80002ace:	0791                	addi	a5,a5,4
    80002ad0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus"
    80002ad2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ad6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002ada:	10079073          	csrw	sstatus,a5
    syscall();
    80002ade:	00000097          	auipc	ra,0x0
    80002ae2:	2d4080e7          	jalr	724(ra) # 80002db2 <syscall>
  if (killed(p))
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	00000097          	auipc	ra,0x0
    80002aec:	8d2080e7          	jalr	-1838(ra) # 800023ba <killed>
    80002af0:	c911                	beqz	a0,80002b04 <usertrap+0xac>
    80002af2:	4901                	li	s2,0
    exit(-1);
    80002af4:	557d                	li	a0,-1
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	744080e7          	jalr	1860(ra) # 8000223a <exit>
  if (which_dev == 2)
    80002afe:	4789                	li	a5,2
    80002b00:	04f90f63          	beq	s2,a5,80002b5e <usertrap+0x106>
  usertrapret();
    80002b04:	00000097          	auipc	ra,0x0
    80002b08:	dc8080e7          	jalr	-568(ra) # 800028cc <usertrapret>
}
    80002b0c:	60e2                	ld	ra,24(sp)
    80002b0e:	6442                	ld	s0,16(sp)
    80002b10:	64a2                	ld	s1,8(sp)
    80002b12:	6902                	ld	s2,0(sp)
    80002b14:	6105                	addi	sp,sp,32
    80002b16:	8082                	ret
      exit(-1);
    80002b18:	557d                	li	a0,-1
    80002b1a:	fffff097          	auipc	ra,0xfffff
    80002b1e:	720080e7          	jalr	1824(ra) # 8000223a <exit>
    80002b22:	b765                	j	80002aca <usertrap+0x72>
  asm volatile("csrr %0, scause"
    80002b24:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b28:	5890                	lw	a2,48(s1)
    80002b2a:	00006517          	auipc	a0,0x6
    80002b2e:	81e50513          	addi	a0,a0,-2018 # 80008348 <states.0+0x78>
    80002b32:	ffffe097          	auipc	ra,0xffffe
    80002b36:	a58080e7          	jalr	-1448(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002b3a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002b3e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b42:	00006517          	auipc	a0,0x6
    80002b46:	83650513          	addi	a0,a0,-1994 # 80008378 <states.0+0xa8>
    80002b4a:	ffffe097          	auipc	ra,0xffffe
    80002b4e:	a40080e7          	jalr	-1472(ra) # 8000058a <printf>
    setkilled(p);
    80002b52:	8526                	mv	a0,s1
    80002b54:	00000097          	auipc	ra,0x0
    80002b58:	83a080e7          	jalr	-1990(ra) # 8000238e <setkilled>
    80002b5c:	b769                	j	80002ae6 <usertrap+0x8e>
    yield();
    80002b5e:	fffff097          	auipc	ra,0xfffff
    80002b62:	540080e7          	jalr	1344(ra) # 8000209e <yield>
    80002b66:	bf79                	j	80002b04 <usertrap+0xac>

0000000080002b68 <kerneltrap>:
{
    80002b68:	7179                	addi	sp,sp,-48
    80002b6a:	f406                	sd	ra,40(sp)
    80002b6c:	f022                	sd	s0,32(sp)
    80002b6e:	ec26                	sd	s1,24(sp)
    80002b70:	e84a                	sd	s2,16(sp)
    80002b72:	e44e                	sd	s3,8(sp)
    80002b74:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc"
    80002b76:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus"
    80002b7a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause"
    80002b7e:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002b82:	1004f793          	andi	a5,s1,256
    80002b86:	cb85                	beqz	a5,80002bb6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus"
    80002b88:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b8c:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002b8e:	ef85                	bnez	a5,80002bc6 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002b90:	00000097          	auipc	ra,0x0
    80002b94:	e26080e7          	jalr	-474(ra) # 800029b6 <devintr>
    80002b98:	cd1d                	beqz	a0,80002bd6 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b9a:	4789                	li	a5,2
    80002b9c:	06f50a63          	beq	a0,a5,80002c10 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0"
    80002ba0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0"
    80002ba4:	10049073          	csrw	sstatus,s1
}
    80002ba8:	70a2                	ld	ra,40(sp)
    80002baa:	7402                	ld	s0,32(sp)
    80002bac:	64e2                	ld	s1,24(sp)
    80002bae:	6942                	ld	s2,16(sp)
    80002bb0:	69a2                	ld	s3,8(sp)
    80002bb2:	6145                	addi	sp,sp,48
    80002bb4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bb6:	00005517          	auipc	a0,0x5
    80002bba:	7e250513          	addi	a0,a0,2018 # 80008398 <states.0+0xc8>
    80002bbe:	ffffe097          	auipc	ra,0xffffe
    80002bc2:	982080e7          	jalr	-1662(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bc6:	00005517          	auipc	a0,0x5
    80002bca:	7fa50513          	addi	a0,a0,2042 # 800083c0 <states.0+0xf0>
    80002bce:	ffffe097          	auipc	ra,0xffffe
    80002bd2:	972080e7          	jalr	-1678(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002bd6:	85ce                	mv	a1,s3
    80002bd8:	00006517          	auipc	a0,0x6
    80002bdc:	80850513          	addi	a0,a0,-2040 # 800083e0 <states.0+0x110>
    80002be0:	ffffe097          	auipc	ra,0xffffe
    80002be4:	9aa080e7          	jalr	-1622(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002be8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002bec:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bf0:	00006517          	auipc	a0,0x6
    80002bf4:	80050513          	addi	a0,a0,-2048 # 800083f0 <states.0+0x120>
    80002bf8:	ffffe097          	auipc	ra,0xffffe
    80002bfc:	992080e7          	jalr	-1646(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002c00:	00006517          	auipc	a0,0x6
    80002c04:	80850513          	addi	a0,a0,-2040 # 80008408 <states.0+0x138>
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	938080e7          	jalr	-1736(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	d9c080e7          	jalr	-612(ra) # 800019ac <myproc>
    80002c18:	d541                	beqz	a0,80002ba0 <kerneltrap+0x38>
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	d92080e7          	jalr	-622(ra) # 800019ac <myproc>
    80002c22:	4d18                	lw	a4,24(a0)
    80002c24:	4791                	li	a5,4
    80002c26:	f6f71de3          	bne	a4,a5,80002ba0 <kerneltrap+0x38>
    yield();
    80002c2a:	fffff097          	auipc	ra,0xfffff
    80002c2e:	474080e7          	jalr	1140(ra) # 8000209e <yield>
    80002c32:	b7bd                	j	80002ba0 <kerneltrap+0x38>

0000000080002c34 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c34:	1101                	addi	sp,sp,-32
    80002c36:	ec06                	sd	ra,24(sp)
    80002c38:	e822                	sd	s0,16(sp)
    80002c3a:	e426                	sd	s1,8(sp)
    80002c3c:	1000                	addi	s0,sp,32
    80002c3e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	d6c080e7          	jalr	-660(ra) # 800019ac <myproc>
  switch (n)
    80002c48:	4795                	li	a5,5
    80002c4a:	0497e163          	bltu	a5,s1,80002c8c <argraw+0x58>
    80002c4e:	048a                	slli	s1,s1,0x2
    80002c50:	00005717          	auipc	a4,0x5
    80002c54:	7f070713          	addi	a4,a4,2032 # 80008440 <states.0+0x170>
    80002c58:	94ba                	add	s1,s1,a4
    80002c5a:	409c                	lw	a5,0(s1)
    80002c5c:	97ba                	add	a5,a5,a4
    80002c5e:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002c60:	6d3c                	ld	a5,88(a0)
    80002c62:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c64:	60e2                	ld	ra,24(sp)
    80002c66:	6442                	ld	s0,16(sp)
    80002c68:	64a2                	ld	s1,8(sp)
    80002c6a:	6105                	addi	sp,sp,32
    80002c6c:	8082                	ret
    return p->trapframe->a1;
    80002c6e:	6d3c                	ld	a5,88(a0)
    80002c70:	7fa8                	ld	a0,120(a5)
    80002c72:	bfcd                	j	80002c64 <argraw+0x30>
    return p->trapframe->a2;
    80002c74:	6d3c                	ld	a5,88(a0)
    80002c76:	63c8                	ld	a0,128(a5)
    80002c78:	b7f5                	j	80002c64 <argraw+0x30>
    return p->trapframe->a3;
    80002c7a:	6d3c                	ld	a5,88(a0)
    80002c7c:	67c8                	ld	a0,136(a5)
    80002c7e:	b7dd                	j	80002c64 <argraw+0x30>
    return p->trapframe->a4;
    80002c80:	6d3c                	ld	a5,88(a0)
    80002c82:	6bc8                	ld	a0,144(a5)
    80002c84:	b7c5                	j	80002c64 <argraw+0x30>
    return p->trapframe->a5;
    80002c86:	6d3c                	ld	a5,88(a0)
    80002c88:	6fc8                	ld	a0,152(a5)
    80002c8a:	bfe9                	j	80002c64 <argraw+0x30>
  panic("argraw");
    80002c8c:	00005517          	auipc	a0,0x5
    80002c90:	78c50513          	addi	a0,a0,1932 # 80008418 <states.0+0x148>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	8ac080e7          	jalr	-1876(ra) # 80000540 <panic>

0000000080002c9c <fetchaddr>:
{
    80002c9c:	1101                	addi	sp,sp,-32
    80002c9e:	ec06                	sd	ra,24(sp)
    80002ca0:	e822                	sd	s0,16(sp)
    80002ca2:	e426                	sd	s1,8(sp)
    80002ca4:	e04a                	sd	s2,0(sp)
    80002ca6:	1000                	addi	s0,sp,32
    80002ca8:	84aa                	mv	s1,a0
    80002caa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cac:	fffff097          	auipc	ra,0xfffff
    80002cb0:	d00080e7          	jalr	-768(ra) # 800019ac <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cb4:	653c                	ld	a5,72(a0)
    80002cb6:	02f4f863          	bgeu	s1,a5,80002ce6 <fetchaddr+0x4a>
    80002cba:	00848713          	addi	a4,s1,8
    80002cbe:	02e7e663          	bltu	a5,a4,80002cea <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cc2:	46a1                	li	a3,8
    80002cc4:	8626                	mv	a2,s1
    80002cc6:	85ca                	mv	a1,s2
    80002cc8:	6928                	ld	a0,80(a0)
    80002cca:	fffff097          	auipc	ra,0xfffff
    80002cce:	a2e080e7          	jalr	-1490(ra) # 800016f8 <copyin>
    80002cd2:	00a03533          	snez	a0,a0
    80002cd6:	40a00533          	neg	a0,a0
}
    80002cda:	60e2                	ld	ra,24(sp)
    80002cdc:	6442                	ld	s0,16(sp)
    80002cde:	64a2                	ld	s1,8(sp)
    80002ce0:	6902                	ld	s2,0(sp)
    80002ce2:	6105                	addi	sp,sp,32
    80002ce4:	8082                	ret
    return -1;
    80002ce6:	557d                	li	a0,-1
    80002ce8:	bfcd                	j	80002cda <fetchaddr+0x3e>
    80002cea:	557d                	li	a0,-1
    80002cec:	b7fd                	j	80002cda <fetchaddr+0x3e>

0000000080002cee <fetchstr>:
{
    80002cee:	7179                	addi	sp,sp,-48
    80002cf0:	f406                	sd	ra,40(sp)
    80002cf2:	f022                	sd	s0,32(sp)
    80002cf4:	ec26                	sd	s1,24(sp)
    80002cf6:	e84a                	sd	s2,16(sp)
    80002cf8:	e44e                	sd	s3,8(sp)
    80002cfa:	1800                	addi	s0,sp,48
    80002cfc:	892a                	mv	s2,a0
    80002cfe:	84ae                	mv	s1,a1
    80002d00:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d02:	fffff097          	auipc	ra,0xfffff
    80002d06:	caa080e7          	jalr	-854(ra) # 800019ac <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d0a:	86ce                	mv	a3,s3
    80002d0c:	864a                	mv	a2,s2
    80002d0e:	85a6                	mv	a1,s1
    80002d10:	6928                	ld	a0,80(a0)
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	a74080e7          	jalr	-1420(ra) # 80001786 <copyinstr>
    80002d1a:	00054e63          	bltz	a0,80002d36 <fetchstr+0x48>
  return strlen(buf);
    80002d1e:	8526                	mv	a0,s1
    80002d20:	ffffe097          	auipc	ra,0xffffe
    80002d24:	12e080e7          	jalr	302(ra) # 80000e4e <strlen>
}
    80002d28:	70a2                	ld	ra,40(sp)
    80002d2a:	7402                	ld	s0,32(sp)
    80002d2c:	64e2                	ld	s1,24(sp)
    80002d2e:	6942                	ld	s2,16(sp)
    80002d30:	69a2                	ld	s3,8(sp)
    80002d32:	6145                	addi	sp,sp,48
    80002d34:	8082                	ret
    return -1;
    80002d36:	557d                	li	a0,-1
    80002d38:	bfc5                	j	80002d28 <fetchstr+0x3a>

0000000080002d3a <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002d3a:	1101                	addi	sp,sp,-32
    80002d3c:	ec06                	sd	ra,24(sp)
    80002d3e:	e822                	sd	s0,16(sp)
    80002d40:	e426                	sd	s1,8(sp)
    80002d42:	1000                	addi	s0,sp,32
    80002d44:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d46:	00000097          	auipc	ra,0x0
    80002d4a:	eee080e7          	jalr	-274(ra) # 80002c34 <argraw>
    80002d4e:	c088                	sw	a0,0(s1)
}
    80002d50:	60e2                	ld	ra,24(sp)
    80002d52:	6442                	ld	s0,16(sp)
    80002d54:	64a2                	ld	s1,8(sp)
    80002d56:	6105                	addi	sp,sp,32
    80002d58:	8082                	ret

0000000080002d5a <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002d5a:	1101                	addi	sp,sp,-32
    80002d5c:	ec06                	sd	ra,24(sp)
    80002d5e:	e822                	sd	s0,16(sp)
    80002d60:	e426                	sd	s1,8(sp)
    80002d62:	1000                	addi	s0,sp,32
    80002d64:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d66:	00000097          	auipc	ra,0x0
    80002d6a:	ece080e7          	jalr	-306(ra) # 80002c34 <argraw>
    80002d6e:	e088                	sd	a0,0(s1)
}
    80002d70:	60e2                	ld	ra,24(sp)
    80002d72:	6442                	ld	s0,16(sp)
    80002d74:	64a2                	ld	s1,8(sp)
    80002d76:	6105                	addi	sp,sp,32
    80002d78:	8082                	ret

0000000080002d7a <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002d7a:	7179                	addi	sp,sp,-48
    80002d7c:	f406                	sd	ra,40(sp)
    80002d7e:	f022                	sd	s0,32(sp)
    80002d80:	ec26                	sd	s1,24(sp)
    80002d82:	e84a                	sd	s2,16(sp)
    80002d84:	1800                	addi	s0,sp,48
    80002d86:	84ae                	mv	s1,a1
    80002d88:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d8a:	fd840593          	addi	a1,s0,-40
    80002d8e:	00000097          	auipc	ra,0x0
    80002d92:	fcc080e7          	jalr	-52(ra) # 80002d5a <argaddr>
  return fetchstr(addr, buf, max);
    80002d96:	864a                	mv	a2,s2
    80002d98:	85a6                	mv	a1,s1
    80002d9a:	fd843503          	ld	a0,-40(s0)
    80002d9e:	00000097          	auipc	ra,0x0
    80002da2:	f50080e7          	jalr	-176(ra) # 80002cee <fetchstr>
}
    80002da6:	70a2                	ld	ra,40(sp)
    80002da8:	7402                	ld	s0,32(sp)
    80002daa:	64e2                	ld	s1,24(sp)
    80002dac:	6942                	ld	s2,16(sp)
    80002dae:	6145                	addi	sp,sp,48
    80002db0:	8082                	ret

0000000080002db2 <syscall>:
    [SYS_sigreturn] sys_sigreturn,
    [SYS_waitx] sys_waitx,
};

void syscall(void)
{
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	e426                	sd	s1,8(sp)
    80002dba:	e04a                	sd	s2,0(sp)
    80002dbc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dbe:	fffff097          	auipc	ra,0xfffff
    80002dc2:	bee080e7          	jalr	-1042(ra) # 800019ac <myproc>
    80002dc6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002dc8:	05853903          	ld	s2,88(a0)
    80002dcc:	0a893783          	ld	a5,168(s2)
    80002dd0:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002dd4:	37fd                	addiw	a5,a5,-1
    80002dd6:	475d                	li	a4,23
    80002dd8:	00f76f63          	bltu	a4,a5,80002df6 <syscall+0x44>
    80002ddc:	00369713          	slli	a4,a3,0x3
    80002de0:	00005797          	auipc	a5,0x5
    80002de4:	67878793          	addi	a5,a5,1656 # 80008458 <syscalls>
    80002de8:	97ba                	add	a5,a5,a4
    80002dea:	639c                	ld	a5,0(a5)
    80002dec:	c789                	beqz	a5,80002df6 <syscall+0x44>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002dee:	9782                	jalr	a5
    80002df0:	06a93823          	sd	a0,112(s2)
    80002df4:	a839                	j	80002e12 <syscall+0x60>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002df6:	15848613          	addi	a2,s1,344
    80002dfa:	588c                	lw	a1,48(s1)
    80002dfc:	00005517          	auipc	a0,0x5
    80002e00:	62450513          	addi	a0,a0,1572 # 80008420 <states.0+0x150>
    80002e04:	ffffd097          	auipc	ra,0xffffd
    80002e08:	786080e7          	jalr	1926(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e0c:	6cbc                	ld	a5,88(s1)
    80002e0e:	577d                	li	a4,-1
    80002e10:	fbb8                	sd	a4,112(a5)
  }
}
    80002e12:	60e2                	ld	ra,24(sp)
    80002e14:	6442                	ld	s0,16(sp)
    80002e16:	64a2                	ld	s1,8(sp)
    80002e18:	6902                	ld	s2,0(sp)
    80002e1a:	6105                	addi	sp,sp,32
    80002e1c:	8082                	ret

0000000080002e1e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e1e:	1101                	addi	sp,sp,-32
    80002e20:	ec06                	sd	ra,24(sp)
    80002e22:	e822                	sd	s0,16(sp)
    80002e24:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e26:	fec40593          	addi	a1,s0,-20
    80002e2a:	4501                	li	a0,0
    80002e2c:	00000097          	auipc	ra,0x0
    80002e30:	f0e080e7          	jalr	-242(ra) # 80002d3a <argint>
  exit(n);
    80002e34:	fec42503          	lw	a0,-20(s0)
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	402080e7          	jalr	1026(ra) # 8000223a <exit>
  return 0; // not reached
}
    80002e40:	4501                	li	a0,0
    80002e42:	60e2                	ld	ra,24(sp)
    80002e44:	6442                	ld	s0,16(sp)
    80002e46:	6105                	addi	sp,sp,32
    80002e48:	8082                	ret

0000000080002e4a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e4a:	1141                	addi	sp,sp,-16
    80002e4c:	e406                	sd	ra,8(sp)
    80002e4e:	e022                	sd	s0,0(sp)
    80002e50:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e52:	fffff097          	auipc	ra,0xfffff
    80002e56:	b5a080e7          	jalr	-1190(ra) # 800019ac <myproc>
}
    80002e5a:	5908                	lw	a0,48(a0)
    80002e5c:	60a2                	ld	ra,8(sp)
    80002e5e:	6402                	ld	s0,0(sp)
    80002e60:	0141                	addi	sp,sp,16
    80002e62:	8082                	ret

0000000080002e64 <sys_fork>:

uint64
sys_fork(void)
{
    80002e64:	1141                	addi	sp,sp,-16
    80002e66:	e406                	sd	ra,8(sp)
    80002e68:	e022                	sd	s0,0(sp)
    80002e6a:	0800                	addi	s0,sp,16
  return fork();
    80002e6c:	fffff097          	auipc	ra,0xfffff
    80002e70:	f64080e7          	jalr	-156(ra) # 80001dd0 <fork>
}
    80002e74:	60a2                	ld	ra,8(sp)
    80002e76:	6402                	ld	s0,0(sp)
    80002e78:	0141                	addi	sp,sp,16
    80002e7a:	8082                	ret

0000000080002e7c <sys_wait>:

uint64
sys_wait(void)
{
    80002e7c:	1101                	addi	sp,sp,-32
    80002e7e:	ec06                	sd	ra,24(sp)
    80002e80:	e822                	sd	s0,16(sp)
    80002e82:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e84:	fe840593          	addi	a1,s0,-24
    80002e88:	4501                	li	a0,0
    80002e8a:	00000097          	auipc	ra,0x0
    80002e8e:	ed0080e7          	jalr	-304(ra) # 80002d5a <argaddr>
  return wait(p);
    80002e92:	fe843503          	ld	a0,-24(s0)
    80002e96:	fffff097          	auipc	ra,0xfffff
    80002e9a:	556080e7          	jalr	1366(ra) # 800023ec <wait>
}
    80002e9e:	60e2                	ld	ra,24(sp)
    80002ea0:	6442                	ld	s0,16(sp)
    80002ea2:	6105                	addi	sp,sp,32
    80002ea4:	8082                	ret

0000000080002ea6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ea6:	7179                	addi	sp,sp,-48
    80002ea8:	f406                	sd	ra,40(sp)
    80002eaa:	f022                	sd	s0,32(sp)
    80002eac:	ec26                	sd	s1,24(sp)
    80002eae:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002eb0:	fdc40593          	addi	a1,s0,-36
    80002eb4:	4501                	li	a0,0
    80002eb6:	00000097          	auipc	ra,0x0
    80002eba:	e84080e7          	jalr	-380(ra) # 80002d3a <argint>
  addr = myproc()->sz;
    80002ebe:	fffff097          	auipc	ra,0xfffff
    80002ec2:	aee080e7          	jalr	-1298(ra) # 800019ac <myproc>
    80002ec6:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002ec8:	fdc42503          	lw	a0,-36(s0)
    80002ecc:	fffff097          	auipc	ra,0xfffff
    80002ed0:	ea8080e7          	jalr	-344(ra) # 80001d74 <growproc>
    80002ed4:	00054863          	bltz	a0,80002ee4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002ed8:	8526                	mv	a0,s1
    80002eda:	70a2                	ld	ra,40(sp)
    80002edc:	7402                	ld	s0,32(sp)
    80002ede:	64e2                	ld	s1,24(sp)
    80002ee0:	6145                	addi	sp,sp,48
    80002ee2:	8082                	ret
    return -1;
    80002ee4:	54fd                	li	s1,-1
    80002ee6:	bfcd                	j	80002ed8 <sys_sbrk+0x32>

0000000080002ee8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ee8:	7139                	addi	sp,sp,-64
    80002eea:	fc06                	sd	ra,56(sp)
    80002eec:	f822                	sd	s0,48(sp)
    80002eee:	f426                	sd	s1,40(sp)
    80002ef0:	f04a                	sd	s2,32(sp)
    80002ef2:	ec4e                	sd	s3,24(sp)
    80002ef4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ef6:	fcc40593          	addi	a1,s0,-52
    80002efa:	4501                	li	a0,0
    80002efc:	00000097          	auipc	ra,0x0
    80002f00:	e3e080e7          	jalr	-450(ra) # 80002d3a <argint>
  acquire(&tickslock);
    80002f04:	00016517          	auipc	a0,0x16
    80002f08:	ae450513          	addi	a0,a0,-1308 # 800189e8 <tickslock>
    80002f0c:	ffffe097          	auipc	ra,0xffffe
    80002f10:	cca080e7          	jalr	-822(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002f14:	00006917          	auipc	s2,0x6
    80002f18:	a1492903          	lw	s2,-1516(s2) # 80008928 <ticks>
  while (ticks - ticks0 < n)
    80002f1c:	fcc42783          	lw	a5,-52(s0)
    80002f20:	cf9d                	beqz	a5,80002f5e <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f22:	00016997          	auipc	s3,0x16
    80002f26:	ac698993          	addi	s3,s3,-1338 # 800189e8 <tickslock>
    80002f2a:	00006497          	auipc	s1,0x6
    80002f2e:	9fe48493          	addi	s1,s1,-1538 # 80008928 <ticks>
    if (killed(myproc()))
    80002f32:	fffff097          	auipc	ra,0xfffff
    80002f36:	a7a080e7          	jalr	-1414(ra) # 800019ac <myproc>
    80002f3a:	fffff097          	auipc	ra,0xfffff
    80002f3e:	480080e7          	jalr	1152(ra) # 800023ba <killed>
    80002f42:	ed15                	bnez	a0,80002f7e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f44:	85ce                	mv	a1,s3
    80002f46:	8526                	mv	a0,s1
    80002f48:	fffff097          	auipc	ra,0xfffff
    80002f4c:	192080e7          	jalr	402(ra) # 800020da <sleep>
  while (ticks - ticks0 < n)
    80002f50:	409c                	lw	a5,0(s1)
    80002f52:	412787bb          	subw	a5,a5,s2
    80002f56:	fcc42703          	lw	a4,-52(s0)
    80002f5a:	fce7ece3          	bltu	a5,a4,80002f32 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002f5e:	00016517          	auipc	a0,0x16
    80002f62:	a8a50513          	addi	a0,a0,-1398 # 800189e8 <tickslock>
    80002f66:	ffffe097          	auipc	ra,0xffffe
    80002f6a:	d24080e7          	jalr	-732(ra) # 80000c8a <release>
  return 0;
    80002f6e:	4501                	li	a0,0
}
    80002f70:	70e2                	ld	ra,56(sp)
    80002f72:	7442                	ld	s0,48(sp)
    80002f74:	74a2                	ld	s1,40(sp)
    80002f76:	7902                	ld	s2,32(sp)
    80002f78:	69e2                	ld	s3,24(sp)
    80002f7a:	6121                	addi	sp,sp,64
    80002f7c:	8082                	ret
      release(&tickslock);
    80002f7e:	00016517          	auipc	a0,0x16
    80002f82:	a6a50513          	addi	a0,a0,-1430 # 800189e8 <tickslock>
    80002f86:	ffffe097          	auipc	ra,0xffffe
    80002f8a:	d04080e7          	jalr	-764(ra) # 80000c8a <release>
      return -1;
    80002f8e:	557d                	li	a0,-1
    80002f90:	b7c5                	j	80002f70 <sys_sleep+0x88>

0000000080002f92 <sys_kill>:

uint64
sys_kill(void)
{
    80002f92:	1101                	addi	sp,sp,-32
    80002f94:	ec06                	sd	ra,24(sp)
    80002f96:	e822                	sd	s0,16(sp)
    80002f98:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f9a:	fec40593          	addi	a1,s0,-20
    80002f9e:	4501                	li	a0,0
    80002fa0:	00000097          	auipc	ra,0x0
    80002fa4:	d9a080e7          	jalr	-614(ra) # 80002d3a <argint>
  return kill(pid);
    80002fa8:	fec42503          	lw	a0,-20(s0)
    80002fac:	fffff097          	auipc	ra,0xfffff
    80002fb0:	370080e7          	jalr	880(ra) # 8000231c <kill>
}
    80002fb4:	60e2                	ld	ra,24(sp)
    80002fb6:	6442                	ld	s0,16(sp)
    80002fb8:	6105                	addi	sp,sp,32
    80002fba:	8082                	ret

0000000080002fbc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fbc:	1101                	addi	sp,sp,-32
    80002fbe:	ec06                	sd	ra,24(sp)
    80002fc0:	e822                	sd	s0,16(sp)
    80002fc2:	e426                	sd	s1,8(sp)
    80002fc4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fc6:	00016517          	auipc	a0,0x16
    80002fca:	a2250513          	addi	a0,a0,-1502 # 800189e8 <tickslock>
    80002fce:	ffffe097          	auipc	ra,0xffffe
    80002fd2:	c08080e7          	jalr	-1016(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002fd6:	00006497          	auipc	s1,0x6
    80002fda:	9524a483          	lw	s1,-1710(s1) # 80008928 <ticks>
  release(&tickslock);
    80002fde:	00016517          	auipc	a0,0x16
    80002fe2:	a0a50513          	addi	a0,a0,-1526 # 800189e8 <tickslock>
    80002fe6:	ffffe097          	auipc	ra,0xffffe
    80002fea:	ca4080e7          	jalr	-860(ra) # 80000c8a <release>
  return xticks;
}
    80002fee:	02049513          	slli	a0,s1,0x20
    80002ff2:	9101                	srli	a0,a0,0x20
    80002ff4:	60e2                	ld	ra,24(sp)
    80002ff6:	6442                	ld	s0,16(sp)
    80002ff8:	64a2                	ld	s1,8(sp)
    80002ffa:	6105                	addi	sp,sp,32
    80002ffc:	8082                	ret

0000000080002ffe <sys_sigalarm>:

// sigalarm
uint64 sys_sigalarm(void)
{
    80002ffe:	1101                	addi	sp,sp,-32
    80003000:	ec06                	sd	ra,24(sp)
    80003002:	e822                	sd	s0,16(sp)
    80003004:	1000                	addi	s0,sp,32
  int interval;
  uint64 fn;
  argint(0, &interval);
    80003006:	fec40593          	addi	a1,s0,-20
    8000300a:	4501                	li	a0,0
    8000300c:	00000097          	auipc	ra,0x0
    80003010:	d2e080e7          	jalr	-722(ra) # 80002d3a <argint>
  argaddr(1, &fn);
    80003014:	fe040593          	addi	a1,s0,-32
    80003018:	4505                	li	a0,1
    8000301a:	00000097          	auipc	ra,0x0
    8000301e:	d40080e7          	jalr	-704(ra) # 80002d5a <argaddr>

  struct proc *p = myproc();
    80003022:	fffff097          	auipc	ra,0xfffff
    80003026:	98a080e7          	jalr	-1654(ra) # 800019ac <myproc>

  p->sigalarm_status = 0;
    8000302a:	1a052c23          	sw	zero,440(a0)
  p->interval = interval;
    8000302e:	fec42783          	lw	a5,-20(s0)
    80003032:	1af52423          	sw	a5,424(a0)
  p->now_ticks = 0;
    80003036:	1a052623          	sw	zero,428(a0)
  p->handler = fn;
    8000303a:	fe043783          	ld	a5,-32(s0)
    8000303e:	1af53023          	sd	a5,416(a0)

  return 0;
}
    80003042:	4501                	li	a0,0
    80003044:	60e2                	ld	ra,24(sp)
    80003046:	6442                	ld	s0,16(sp)
    80003048:	6105                	addi	sp,sp,32
    8000304a:	8082                	ret

000000008000304c <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    8000304c:	1101                	addi	sp,sp,-32
    8000304e:	ec06                	sd	ra,24(sp)
    80003050:	e822                	sd	s0,16(sp)
    80003052:	e426                	sd	s1,8(sp)
    80003054:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003056:	fffff097          	auipc	ra,0xfffff
    8000305a:	956080e7          	jalr	-1706(ra) # 800019ac <myproc>
    8000305e:	84aa                	mv	s1,a0

  // Restore Kernel Values
  memmove(p->trapframe, p->alarm_trapframe, PGSIZE);
    80003060:	6605                	lui	a2,0x1
    80003062:	1b053583          	ld	a1,432(a0)
    80003066:	6d28                	ld	a0,88(a0)
    80003068:	ffffe097          	auipc	ra,0xffffe
    8000306c:	cc6080e7          	jalr	-826(ra) # 80000d2e <memmove>
  kfree(p->alarm_trapframe);
    80003070:	1b04b503          	ld	a0,432(s1)
    80003074:	ffffe097          	auipc	ra,0xffffe
    80003078:	974080e7          	jalr	-1676(ra) # 800009e8 <kfree>

  p->sigalarm_status = 0;
    8000307c:	1a04ac23          	sw	zero,440(s1)
  p->alarm_trapframe = 0;
    80003080:	1a04b823          	sd	zero,432(s1)
  p->now_ticks = 0;
    80003084:	1a04a623          	sw	zero,428(s1)
  usertrapret();
    80003088:	00000097          	auipc	ra,0x0
    8000308c:	844080e7          	jalr	-1980(ra) # 800028cc <usertrapret>
  return 0;
}
    80003090:	4501                	li	a0,0
    80003092:	60e2                	ld	ra,24(sp)
    80003094:	6442                	ld	s0,16(sp)
    80003096:	64a2                	ld	s1,8(sp)
    80003098:	6105                	addi	sp,sp,32
    8000309a:	8082                	ret

000000008000309c <sys_waitx>:

uint64
sys_waitx(void)
{
    8000309c:	7139                	addi	sp,sp,-64
    8000309e:	fc06                	sd	ra,56(sp)
    800030a0:	f822                	sd	s0,48(sp)
    800030a2:	f426                	sd	s1,40(sp)
    800030a4:	f04a                	sd	s2,32(sp)
    800030a6:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800030a8:	fd840593          	addi	a1,s0,-40
    800030ac:	4501                	li	a0,0
    800030ae:	00000097          	auipc	ra,0x0
    800030b2:	cac080e7          	jalr	-852(ra) # 80002d5a <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800030b6:	fd040593          	addi	a1,s0,-48
    800030ba:	4505                	li	a0,1
    800030bc:	00000097          	auipc	ra,0x0
    800030c0:	c9e080e7          	jalr	-866(ra) # 80002d5a <argaddr>
  argaddr(2, &addr2);
    800030c4:	fc840593          	addi	a1,s0,-56
    800030c8:	4509                	li	a0,2
    800030ca:	00000097          	auipc	ra,0x0
    800030ce:	c90080e7          	jalr	-880(ra) # 80002d5a <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800030d2:	fc040613          	addi	a2,s0,-64
    800030d6:	fc440593          	addi	a1,s0,-60
    800030da:	fd843503          	ld	a0,-40(s0)
    800030de:	fffff097          	auipc	ra,0xfffff
    800030e2:	59a080e7          	jalr	1434(ra) # 80002678 <waitx>
    800030e6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800030e8:	fffff097          	auipc	ra,0xfffff
    800030ec:	8c4080e7          	jalr	-1852(ra) # 800019ac <myproc>
    800030f0:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030f2:	4691                	li	a3,4
    800030f4:	fc440613          	addi	a2,s0,-60
    800030f8:	fd043583          	ld	a1,-48(s0)
    800030fc:	6928                	ld	a0,80(a0)
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	56e080e7          	jalr	1390(ra) # 8000166c <copyout>
    return -1;
    80003106:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003108:	00054f63          	bltz	a0,80003126 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    8000310c:	4691                	li	a3,4
    8000310e:	fc040613          	addi	a2,s0,-64
    80003112:	fc843583          	ld	a1,-56(s0)
    80003116:	68a8                	ld	a0,80(s1)
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	554080e7          	jalr	1364(ra) # 8000166c <copyout>
    80003120:	00054a63          	bltz	a0,80003134 <sys_waitx+0x98>
    return -1;
  return ret;
    80003124:	87ca                	mv	a5,s2
    80003126:	853e                	mv	a0,a5
    80003128:	70e2                	ld	ra,56(sp)
    8000312a:	7442                	ld	s0,48(sp)
    8000312c:	74a2                	ld	s1,40(sp)
    8000312e:	7902                	ld	s2,32(sp)
    80003130:	6121                	addi	sp,sp,64
    80003132:	8082                	ret
    return -1;
    80003134:	57fd                	li	a5,-1
    80003136:	bfc5                	j	80003126 <sys_waitx+0x8a>

0000000080003138 <binit>:
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void binit(void)
{
    80003138:	7179                	addi	sp,sp,-48
    8000313a:	f406                	sd	ra,40(sp)
    8000313c:	f022                	sd	s0,32(sp)
    8000313e:	ec26                	sd	s1,24(sp)
    80003140:	e84a                	sd	s2,16(sp)
    80003142:	e44e                	sd	s3,8(sp)
    80003144:	e052                	sd	s4,0(sp)
    80003146:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003148:	00005597          	auipc	a1,0x5
    8000314c:	3d858593          	addi	a1,a1,984 # 80008520 <syscalls+0xc8>
    80003150:	00016517          	auipc	a0,0x16
    80003154:	8b050513          	addi	a0,a0,-1872 # 80018a00 <bcache>
    80003158:	ffffe097          	auipc	ra,0xffffe
    8000315c:	9ee080e7          	jalr	-1554(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003160:	0001e797          	auipc	a5,0x1e
    80003164:	8a078793          	addi	a5,a5,-1888 # 80020a00 <bcache+0x8000>
    80003168:	0001e717          	auipc	a4,0x1e
    8000316c:	b0070713          	addi	a4,a4,-1280 # 80020c68 <bcache+0x8268>
    80003170:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003174:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    80003178:	00016497          	auipc	s1,0x16
    8000317c:	8a048493          	addi	s1,s1,-1888 # 80018a18 <bcache+0x18>
  {
    b->next = bcache.head.next;
    80003180:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003182:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003184:	00005a17          	auipc	s4,0x5
    80003188:	3a4a0a13          	addi	s4,s4,932 # 80008528 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000318c:	2b893783          	ld	a5,696(s2)
    80003190:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003192:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003196:	85d2                	mv	a1,s4
    80003198:	01048513          	addi	a0,s1,16
    8000319c:	00001097          	auipc	ra,0x1
    800031a0:	4c8080e7          	jalr	1224(ra) # 80004664 <initsleeplock>
    bcache.head.next->prev = b;
    800031a4:	2b893783          	ld	a5,696(s2)
    800031a8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031aa:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    800031ae:	45848493          	addi	s1,s1,1112
    800031b2:	fd349de3          	bne	s1,s3,8000318c <binit+0x54>
  }
}
    800031b6:	70a2                	ld	ra,40(sp)
    800031b8:	7402                	ld	s0,32(sp)
    800031ba:	64e2                	ld	s1,24(sp)
    800031bc:	6942                	ld	s2,16(sp)
    800031be:	69a2                	ld	s3,8(sp)
    800031c0:	6a02                	ld	s4,0(sp)
    800031c2:	6145                	addi	sp,sp,48
    800031c4:	8082                	ret

00000000800031c6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    800031c6:	7179                	addi	sp,sp,-48
    800031c8:	f406                	sd	ra,40(sp)
    800031ca:	f022                	sd	s0,32(sp)
    800031cc:	ec26                	sd	s1,24(sp)
    800031ce:	e84a                	sd	s2,16(sp)
    800031d0:	e44e                	sd	s3,8(sp)
    800031d2:	1800                	addi	s0,sp,48
    800031d4:	892a                	mv	s2,a0
    800031d6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031d8:	00016517          	auipc	a0,0x16
    800031dc:	82850513          	addi	a0,a0,-2008 # 80018a00 <bcache>
    800031e0:	ffffe097          	auipc	ra,0xffffe
    800031e4:	9f6080e7          	jalr	-1546(ra) # 80000bd6 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next)
    800031e8:	0001e497          	auipc	s1,0x1e
    800031ec:	ad04b483          	ld	s1,-1328(s1) # 80020cb8 <bcache+0x82b8>
    800031f0:	0001e797          	auipc	a5,0x1e
    800031f4:	a7878793          	addi	a5,a5,-1416 # 80020c68 <bcache+0x8268>
    800031f8:	02f48f63          	beq	s1,a5,80003236 <bread+0x70>
    800031fc:	873e                	mv	a4,a5
    800031fe:	a021                	j	80003206 <bread+0x40>
    80003200:	68a4                	ld	s1,80(s1)
    80003202:	02e48a63          	beq	s1,a4,80003236 <bread+0x70>
    if (b->dev == dev && b->blockno == blockno)
    80003206:	449c                	lw	a5,8(s1)
    80003208:	ff279ce3          	bne	a5,s2,80003200 <bread+0x3a>
    8000320c:	44dc                	lw	a5,12(s1)
    8000320e:	ff3799e3          	bne	a5,s3,80003200 <bread+0x3a>
      b->refcnt++;
    80003212:	40bc                	lw	a5,64(s1)
    80003214:	2785                	addiw	a5,a5,1
    80003216:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003218:	00015517          	auipc	a0,0x15
    8000321c:	7e850513          	addi	a0,a0,2024 # 80018a00 <bcache>
    80003220:	ffffe097          	auipc	ra,0xffffe
    80003224:	a6a080e7          	jalr	-1430(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003228:	01048513          	addi	a0,s1,16
    8000322c:	00001097          	auipc	ra,0x1
    80003230:	472080e7          	jalr	1138(ra) # 8000469e <acquiresleep>
      return b;
    80003234:	a8b9                	j	80003292 <bread+0xcc>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    80003236:	0001e497          	auipc	s1,0x1e
    8000323a:	a7a4b483          	ld	s1,-1414(s1) # 80020cb0 <bcache+0x82b0>
    8000323e:	0001e797          	auipc	a5,0x1e
    80003242:	a2a78793          	addi	a5,a5,-1494 # 80020c68 <bcache+0x8268>
    80003246:	00f48863          	beq	s1,a5,80003256 <bread+0x90>
    8000324a:	873e                	mv	a4,a5
    if (b->refcnt == 0)
    8000324c:	40bc                	lw	a5,64(s1)
    8000324e:	cf81                	beqz	a5,80003266 <bread+0xa0>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    80003250:	64a4                	ld	s1,72(s1)
    80003252:	fee49de3          	bne	s1,a4,8000324c <bread+0x86>
  panic("bget: no buffers");
    80003256:	00005517          	auipc	a0,0x5
    8000325a:	2da50513          	addi	a0,a0,730 # 80008530 <syscalls+0xd8>
    8000325e:	ffffd097          	auipc	ra,0xffffd
    80003262:	2e2080e7          	jalr	738(ra) # 80000540 <panic>
      b->dev = dev;
    80003266:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000326a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000326e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003272:	4785                	li	a5,1
    80003274:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003276:	00015517          	auipc	a0,0x15
    8000327a:	78a50513          	addi	a0,a0,1930 # 80018a00 <bcache>
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	a0c080e7          	jalr	-1524(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003286:	01048513          	addi	a0,s1,16
    8000328a:	00001097          	auipc	ra,0x1
    8000328e:	414080e7          	jalr	1044(ra) # 8000469e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid)
    80003292:	409c                	lw	a5,0(s1)
    80003294:	cb89                	beqz	a5,800032a6 <bread+0xe0>
  {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003296:	8526                	mv	a0,s1
    80003298:	70a2                	ld	ra,40(sp)
    8000329a:	7402                	ld	s0,32(sp)
    8000329c:	64e2                	ld	s1,24(sp)
    8000329e:	6942                	ld	s2,16(sp)
    800032a0:	69a2                	ld	s3,8(sp)
    800032a2:	6145                	addi	sp,sp,48
    800032a4:	8082                	ret
    virtio_disk_rw(b, 0);
    800032a6:	4581                	li	a1,0
    800032a8:	8526                	mv	a0,s1
    800032aa:	00003097          	auipc	ra,0x3
    800032ae:	2ac080e7          	jalr	684(ra) # 80006556 <virtio_disk_rw>
    b->valid = 1;
    800032b2:	4785                	li	a5,1
    800032b4:	c09c                	sw	a5,0(s1)
  return b;
    800032b6:	b7c5                	j	80003296 <bread+0xd0>

00000000800032b8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
    800032b8:	1101                	addi	sp,sp,-32
    800032ba:	ec06                	sd	ra,24(sp)
    800032bc:	e822                	sd	s0,16(sp)
    800032be:	e426                	sd	s1,8(sp)
    800032c0:	1000                	addi	s0,sp,32
    800032c2:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800032c4:	0541                	addi	a0,a0,16
    800032c6:	00001097          	auipc	ra,0x1
    800032ca:	472080e7          	jalr	1138(ra) # 80004738 <holdingsleep>
    800032ce:	cd01                	beqz	a0,800032e6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032d0:	4585                	li	a1,1
    800032d2:	8526                	mv	a0,s1
    800032d4:	00003097          	auipc	ra,0x3
    800032d8:	282080e7          	jalr	642(ra) # 80006556 <virtio_disk_rw>
}
    800032dc:	60e2                	ld	ra,24(sp)
    800032de:	6442                	ld	s0,16(sp)
    800032e0:	64a2                	ld	s1,8(sp)
    800032e2:	6105                	addi	sp,sp,32
    800032e4:	8082                	ret
    panic("bwrite");
    800032e6:	00005517          	auipc	a0,0x5
    800032ea:	26250513          	addi	a0,a0,610 # 80008548 <syscalls+0xf0>
    800032ee:	ffffd097          	auipc	ra,0xffffd
    800032f2:	252080e7          	jalr	594(ra) # 80000540 <panic>

00000000800032f6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)
{
    800032f6:	1101                	addi	sp,sp,-32
    800032f8:	ec06                	sd	ra,24(sp)
    800032fa:	e822                	sd	s0,16(sp)
    800032fc:	e426                	sd	s1,8(sp)
    800032fe:	e04a                	sd	s2,0(sp)
    80003300:	1000                	addi	s0,sp,32
    80003302:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003304:	01050913          	addi	s2,a0,16
    80003308:	854a                	mv	a0,s2
    8000330a:	00001097          	auipc	ra,0x1
    8000330e:	42e080e7          	jalr	1070(ra) # 80004738 <holdingsleep>
    80003312:	c92d                	beqz	a0,80003384 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003314:	854a                	mv	a0,s2
    80003316:	00001097          	auipc	ra,0x1
    8000331a:	3de080e7          	jalr	990(ra) # 800046f4 <releasesleep>

  acquire(&bcache.lock);
    8000331e:	00015517          	auipc	a0,0x15
    80003322:	6e250513          	addi	a0,a0,1762 # 80018a00 <bcache>
    80003326:	ffffe097          	auipc	ra,0xffffe
    8000332a:	8b0080e7          	jalr	-1872(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000332e:	40bc                	lw	a5,64(s1)
    80003330:	37fd                	addiw	a5,a5,-1
    80003332:	0007871b          	sext.w	a4,a5
    80003336:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0)
    80003338:	eb05                	bnez	a4,80003368 <brelse+0x72>
  {
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000333a:	68bc                	ld	a5,80(s1)
    8000333c:	64b8                	ld	a4,72(s1)
    8000333e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003340:	64bc                	ld	a5,72(s1)
    80003342:	68b8                	ld	a4,80(s1)
    80003344:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003346:	0001d797          	auipc	a5,0x1d
    8000334a:	6ba78793          	addi	a5,a5,1722 # 80020a00 <bcache+0x8000>
    8000334e:	2b87b703          	ld	a4,696(a5)
    80003352:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003354:	0001e717          	auipc	a4,0x1e
    80003358:	91470713          	addi	a4,a4,-1772 # 80020c68 <bcache+0x8268>
    8000335c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000335e:	2b87b703          	ld	a4,696(a5)
    80003362:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003364:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80003368:	00015517          	auipc	a0,0x15
    8000336c:	69850513          	addi	a0,a0,1688 # 80018a00 <bcache>
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	91a080e7          	jalr	-1766(ra) # 80000c8a <release>
}
    80003378:	60e2                	ld	ra,24(sp)
    8000337a:	6442                	ld	s0,16(sp)
    8000337c:	64a2                	ld	s1,8(sp)
    8000337e:	6902                	ld	s2,0(sp)
    80003380:	6105                	addi	sp,sp,32
    80003382:	8082                	ret
    panic("brelse");
    80003384:	00005517          	auipc	a0,0x5
    80003388:	1cc50513          	addi	a0,a0,460 # 80008550 <syscalls+0xf8>
    8000338c:	ffffd097          	auipc	ra,0xffffd
    80003390:	1b4080e7          	jalr	436(ra) # 80000540 <panic>

0000000080003394 <bpin>:

void bpin(struct buf *b)
{
    80003394:	1101                	addi	sp,sp,-32
    80003396:	ec06                	sd	ra,24(sp)
    80003398:	e822                	sd	s0,16(sp)
    8000339a:	e426                	sd	s1,8(sp)
    8000339c:	1000                	addi	s0,sp,32
    8000339e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033a0:	00015517          	auipc	a0,0x15
    800033a4:	66050513          	addi	a0,a0,1632 # 80018a00 <bcache>
    800033a8:	ffffe097          	auipc	ra,0xffffe
    800033ac:	82e080e7          	jalr	-2002(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800033b0:	40bc                	lw	a5,64(s1)
    800033b2:	2785                	addiw	a5,a5,1
    800033b4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033b6:	00015517          	auipc	a0,0x15
    800033ba:	64a50513          	addi	a0,a0,1610 # 80018a00 <bcache>
    800033be:	ffffe097          	auipc	ra,0xffffe
    800033c2:	8cc080e7          	jalr	-1844(ra) # 80000c8a <release>
}
    800033c6:	60e2                	ld	ra,24(sp)
    800033c8:	6442                	ld	s0,16(sp)
    800033ca:	64a2                	ld	s1,8(sp)
    800033cc:	6105                	addi	sp,sp,32
    800033ce:	8082                	ret

00000000800033d0 <bunpin>:

void bunpin(struct buf *b)
{
    800033d0:	1101                	addi	sp,sp,-32
    800033d2:	ec06                	sd	ra,24(sp)
    800033d4:	e822                	sd	s0,16(sp)
    800033d6:	e426                	sd	s1,8(sp)
    800033d8:	1000                	addi	s0,sp,32
    800033da:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033dc:	00015517          	auipc	a0,0x15
    800033e0:	62450513          	addi	a0,a0,1572 # 80018a00 <bcache>
    800033e4:	ffffd097          	auipc	ra,0xffffd
    800033e8:	7f2080e7          	jalr	2034(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800033ec:	40bc                	lw	a5,64(s1)
    800033ee:	37fd                	addiw	a5,a5,-1
    800033f0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033f2:	00015517          	auipc	a0,0x15
    800033f6:	60e50513          	addi	a0,a0,1550 # 80018a00 <bcache>
    800033fa:	ffffe097          	auipc	ra,0xffffe
    800033fe:	890080e7          	jalr	-1904(ra) # 80000c8a <release>
}
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6105                	addi	sp,sp,32
    8000340a:	8082                	ret

000000008000340c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000340c:	1101                	addi	sp,sp,-32
    8000340e:	ec06                	sd	ra,24(sp)
    80003410:	e822                	sd	s0,16(sp)
    80003412:	e426                	sd	s1,8(sp)
    80003414:	e04a                	sd	s2,0(sp)
    80003416:	1000                	addi	s0,sp,32
    80003418:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000341a:	00d5d59b          	srliw	a1,a1,0xd
    8000341e:	0001e797          	auipc	a5,0x1e
    80003422:	cbe7a783          	lw	a5,-834(a5) # 800210dc <sb+0x1c>
    80003426:	9dbd                	addw	a1,a1,a5
    80003428:	00000097          	auipc	ra,0x0
    8000342c:	d9e080e7          	jalr	-610(ra) # 800031c6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003430:	0074f713          	andi	a4,s1,7
    80003434:	4785                	li	a5,1
    80003436:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    8000343a:	14ce                	slli	s1,s1,0x33
    8000343c:	90d9                	srli	s1,s1,0x36
    8000343e:	00950733          	add	a4,a0,s1
    80003442:	05874703          	lbu	a4,88(a4)
    80003446:	00e7f6b3          	and	a3,a5,a4
    8000344a:	c69d                	beqz	a3,80003478 <bfree+0x6c>
    8000344c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    8000344e:	94aa                	add	s1,s1,a0
    80003450:	fff7c793          	not	a5,a5
    80003454:	8f7d                	and	a4,a4,a5
    80003456:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000345a:	00001097          	auipc	ra,0x1
    8000345e:	126080e7          	jalr	294(ra) # 80004580 <log_write>
  brelse(bp);
    80003462:	854a                	mv	a0,s2
    80003464:	00000097          	auipc	ra,0x0
    80003468:	e92080e7          	jalr	-366(ra) # 800032f6 <brelse>
}
    8000346c:	60e2                	ld	ra,24(sp)
    8000346e:	6442                	ld	s0,16(sp)
    80003470:	64a2                	ld	s1,8(sp)
    80003472:	6902                	ld	s2,0(sp)
    80003474:	6105                	addi	sp,sp,32
    80003476:	8082                	ret
    panic("freeing free block");
    80003478:	00005517          	auipc	a0,0x5
    8000347c:	0e050513          	addi	a0,a0,224 # 80008558 <syscalls+0x100>
    80003480:	ffffd097          	auipc	ra,0xffffd
    80003484:	0c0080e7          	jalr	192(ra) # 80000540 <panic>

0000000080003488 <balloc>:
{
    80003488:	711d                	addi	sp,sp,-96
    8000348a:	ec86                	sd	ra,88(sp)
    8000348c:	e8a2                	sd	s0,80(sp)
    8000348e:	e4a6                	sd	s1,72(sp)
    80003490:	e0ca                	sd	s2,64(sp)
    80003492:	fc4e                	sd	s3,56(sp)
    80003494:	f852                	sd	s4,48(sp)
    80003496:	f456                	sd	s5,40(sp)
    80003498:	f05a                	sd	s6,32(sp)
    8000349a:	ec5e                	sd	s7,24(sp)
    8000349c:	e862                	sd	s8,16(sp)
    8000349e:	e466                	sd	s9,8(sp)
    800034a0:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB)
    800034a2:	0001e797          	auipc	a5,0x1e
    800034a6:	c227a783          	lw	a5,-990(a5) # 800210c4 <sb+0x4>
    800034aa:	cff5                	beqz	a5,800035a6 <balloc+0x11e>
    800034ac:	8baa                	mv	s7,a0
    800034ae:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034b0:	0001eb17          	auipc	s6,0x1e
    800034b4:	c10b0b13          	addi	s6,s6,-1008 # 800210c0 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800034b8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034ba:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800034bc:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB)
    800034be:	6c89                	lui	s9,0x2
    800034c0:	a061                	j	80003548 <balloc+0xc0>
        bp->data[bi / 8] |= m; // Mark block in use.
    800034c2:	97ca                	add	a5,a5,s2
    800034c4:	8e55                	or	a2,a2,a3
    800034c6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800034ca:	854a                	mv	a0,s2
    800034cc:	00001097          	auipc	ra,0x1
    800034d0:	0b4080e7          	jalr	180(ra) # 80004580 <log_write>
        brelse(bp);
    800034d4:	854a                	mv	a0,s2
    800034d6:	00000097          	auipc	ra,0x0
    800034da:	e20080e7          	jalr	-480(ra) # 800032f6 <brelse>
  bp = bread(dev, bno);
    800034de:	85a6                	mv	a1,s1
    800034e0:	855e                	mv	a0,s7
    800034e2:	00000097          	auipc	ra,0x0
    800034e6:	ce4080e7          	jalr	-796(ra) # 800031c6 <bread>
    800034ea:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034ec:	40000613          	li	a2,1024
    800034f0:	4581                	li	a1,0
    800034f2:	05850513          	addi	a0,a0,88
    800034f6:	ffffd097          	auipc	ra,0xffffd
    800034fa:	7dc080e7          	jalr	2012(ra) # 80000cd2 <memset>
  log_write(bp);
    800034fe:	854a                	mv	a0,s2
    80003500:	00001097          	auipc	ra,0x1
    80003504:	080080e7          	jalr	128(ra) # 80004580 <log_write>
  brelse(bp);
    80003508:	854a                	mv	a0,s2
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	dec080e7          	jalr	-532(ra) # 800032f6 <brelse>
}
    80003512:	8526                	mv	a0,s1
    80003514:	60e6                	ld	ra,88(sp)
    80003516:	6446                	ld	s0,80(sp)
    80003518:	64a6                	ld	s1,72(sp)
    8000351a:	6906                	ld	s2,64(sp)
    8000351c:	79e2                	ld	s3,56(sp)
    8000351e:	7a42                	ld	s4,48(sp)
    80003520:	7aa2                	ld	s5,40(sp)
    80003522:	7b02                	ld	s6,32(sp)
    80003524:	6be2                	ld	s7,24(sp)
    80003526:	6c42                	ld	s8,16(sp)
    80003528:	6ca2                	ld	s9,8(sp)
    8000352a:	6125                	addi	sp,sp,96
    8000352c:	8082                	ret
    brelse(bp);
    8000352e:	854a                	mv	a0,s2
    80003530:	00000097          	auipc	ra,0x0
    80003534:	dc6080e7          	jalr	-570(ra) # 800032f6 <brelse>
  for (b = 0; b < sb.size; b += BPB)
    80003538:	015c87bb          	addw	a5,s9,s5
    8000353c:	00078a9b          	sext.w	s5,a5
    80003540:	004b2703          	lw	a4,4(s6)
    80003544:	06eaf163          	bgeu	s5,a4,800035a6 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003548:	41fad79b          	sraiw	a5,s5,0x1f
    8000354c:	0137d79b          	srliw	a5,a5,0x13
    80003550:	015787bb          	addw	a5,a5,s5
    80003554:	40d7d79b          	sraiw	a5,a5,0xd
    80003558:	01cb2583          	lw	a1,28(s6)
    8000355c:	9dbd                	addw	a1,a1,a5
    8000355e:	855e                	mv	a0,s7
    80003560:	00000097          	auipc	ra,0x0
    80003564:	c66080e7          	jalr	-922(ra) # 800031c6 <bread>
    80003568:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    8000356a:	004b2503          	lw	a0,4(s6)
    8000356e:	000a849b          	sext.w	s1,s5
    80003572:	8762                	mv	a4,s8
    80003574:	faa4fde3          	bgeu	s1,a0,8000352e <balloc+0xa6>
      m = 1 << (bi % 8);
    80003578:	00777693          	andi	a3,a4,7
    8000357c:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0)
    80003580:	41f7579b          	sraiw	a5,a4,0x1f
    80003584:	01d7d79b          	srliw	a5,a5,0x1d
    80003588:	9fb9                	addw	a5,a5,a4
    8000358a:	4037d79b          	sraiw	a5,a5,0x3
    8000358e:	00f90633          	add	a2,s2,a5
    80003592:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003596:	00c6f5b3          	and	a1,a3,a2
    8000359a:	d585                	beqz	a1,800034c2 <balloc+0x3a>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    8000359c:	2705                	addiw	a4,a4,1
    8000359e:	2485                	addiw	s1,s1,1
    800035a0:	fd471ae3          	bne	a4,s4,80003574 <balloc+0xec>
    800035a4:	b769                	j	8000352e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800035a6:	00005517          	auipc	a0,0x5
    800035aa:	fca50513          	addi	a0,a0,-54 # 80008570 <syscalls+0x118>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	fdc080e7          	jalr	-36(ra) # 8000058a <printf>
  return 0;
    800035b6:	4481                	li	s1,0
    800035b8:	bfa9                	j	80003512 <balloc+0x8a>

00000000800035ba <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035ba:	7179                	addi	sp,sp,-48
    800035bc:	f406                	sd	ra,40(sp)
    800035be:	f022                	sd	s0,32(sp)
    800035c0:	ec26                	sd	s1,24(sp)
    800035c2:	e84a                	sd	s2,16(sp)
    800035c4:	e44e                	sd	s3,8(sp)
    800035c6:	e052                	sd	s4,0(sp)
    800035c8:	1800                	addi	s0,sp,48
    800035ca:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT)
    800035cc:	47ad                	li	a5,11
    800035ce:	02b7e863          	bltu	a5,a1,800035fe <bmap+0x44>
  {
    if ((addr = ip->addrs[bn]) == 0)
    800035d2:	02059793          	slli	a5,a1,0x20
    800035d6:	01e7d593          	srli	a1,a5,0x1e
    800035da:	00b504b3          	add	s1,a0,a1
    800035de:	0504a903          	lw	s2,80(s1)
    800035e2:	06091e63          	bnez	s2,8000365e <bmap+0xa4>
    {
      addr = balloc(ip->dev);
    800035e6:	4108                	lw	a0,0(a0)
    800035e8:	00000097          	auipc	ra,0x0
    800035ec:	ea0080e7          	jalr	-352(ra) # 80003488 <balloc>
    800035f0:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    800035f4:	06090563          	beqz	s2,8000365e <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800035f8:	0524a823          	sw	s2,80(s1)
    800035fc:	a08d                	j	8000365e <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035fe:	ff45849b          	addiw	s1,a1,-12
    80003602:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT)
    80003606:	0ff00793          	li	a5,255
    8000360a:	08e7e563          	bltu	a5,a4,80003694 <bmap+0xda>
  {
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0)
    8000360e:	08052903          	lw	s2,128(a0)
    80003612:	00091d63          	bnez	s2,8000362c <bmap+0x72>
    {
      addr = balloc(ip->dev);
    80003616:	4108                	lw	a0,0(a0)
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	e70080e7          	jalr	-400(ra) # 80003488 <balloc>
    80003620:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003624:	02090d63          	beqz	s2,8000365e <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003628:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000362c:	85ca                	mv	a1,s2
    8000362e:	0009a503          	lw	a0,0(s3)
    80003632:	00000097          	auipc	ra,0x0
    80003636:	b94080e7          	jalr	-1132(ra) # 800031c6 <bread>
    8000363a:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    8000363c:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0)
    80003640:	02049713          	slli	a4,s1,0x20
    80003644:	01e75593          	srli	a1,a4,0x1e
    80003648:	00b784b3          	add	s1,a5,a1
    8000364c:	0004a903          	lw	s2,0(s1)
    80003650:	02090063          	beqz	s2,80003670 <bmap+0xb6>
      {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003654:	8552                	mv	a0,s4
    80003656:	00000097          	auipc	ra,0x0
    8000365a:	ca0080e7          	jalr	-864(ra) # 800032f6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000365e:	854a                	mv	a0,s2
    80003660:	70a2                	ld	ra,40(sp)
    80003662:	7402                	ld	s0,32(sp)
    80003664:	64e2                	ld	s1,24(sp)
    80003666:	6942                	ld	s2,16(sp)
    80003668:	69a2                	ld	s3,8(sp)
    8000366a:	6a02                	ld	s4,0(sp)
    8000366c:	6145                	addi	sp,sp,48
    8000366e:	8082                	ret
      addr = balloc(ip->dev);
    80003670:	0009a503          	lw	a0,0(s3)
    80003674:	00000097          	auipc	ra,0x0
    80003678:	e14080e7          	jalr	-492(ra) # 80003488 <balloc>
    8000367c:	0005091b          	sext.w	s2,a0
      if (addr)
    80003680:	fc090ae3          	beqz	s2,80003654 <bmap+0x9a>
        a[bn] = addr;
    80003684:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003688:	8552                	mv	a0,s4
    8000368a:	00001097          	auipc	ra,0x1
    8000368e:	ef6080e7          	jalr	-266(ra) # 80004580 <log_write>
    80003692:	b7c9                	j	80003654 <bmap+0x9a>
  panic("bmap: out of range");
    80003694:	00005517          	auipc	a0,0x5
    80003698:	ef450513          	addi	a0,a0,-268 # 80008588 <syscalls+0x130>
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	ea4080e7          	jalr	-348(ra) # 80000540 <panic>

00000000800036a4 <iget>:
{
    800036a4:	7179                	addi	sp,sp,-48
    800036a6:	f406                	sd	ra,40(sp)
    800036a8:	f022                	sd	s0,32(sp)
    800036aa:	ec26                	sd	s1,24(sp)
    800036ac:	e84a                	sd	s2,16(sp)
    800036ae:	e44e                	sd	s3,8(sp)
    800036b0:	e052                	sd	s4,0(sp)
    800036b2:	1800                	addi	s0,sp,48
    800036b4:	89aa                	mv	s3,a0
    800036b6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036b8:	0001e517          	auipc	a0,0x1e
    800036bc:	a2850513          	addi	a0,a0,-1496 # 800210e0 <itable>
    800036c0:	ffffd097          	auipc	ra,0xffffd
    800036c4:	516080e7          	jalr	1302(ra) # 80000bd6 <acquire>
  empty = 0;
    800036c8:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    800036ca:	0001e497          	auipc	s1,0x1e
    800036ce:	a2e48493          	addi	s1,s1,-1490 # 800210f8 <itable+0x18>
    800036d2:	0001f697          	auipc	a3,0x1f
    800036d6:	4b668693          	addi	a3,a3,1206 # 80022b88 <log>
    800036da:	a039                	j	800036e8 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800036dc:	02090b63          	beqz	s2,80003712 <iget+0x6e>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    800036e0:	08848493          	addi	s1,s1,136
    800036e4:	02d48a63          	beq	s1,a3,80003718 <iget+0x74>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum)
    800036e8:	449c                	lw	a5,8(s1)
    800036ea:	fef059e3          	blez	a5,800036dc <iget+0x38>
    800036ee:	4098                	lw	a4,0(s1)
    800036f0:	ff3716e3          	bne	a4,s3,800036dc <iget+0x38>
    800036f4:	40d8                	lw	a4,4(s1)
    800036f6:	ff4713e3          	bne	a4,s4,800036dc <iget+0x38>
      ip->ref++;
    800036fa:	2785                	addiw	a5,a5,1
    800036fc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036fe:	0001e517          	auipc	a0,0x1e
    80003702:	9e250513          	addi	a0,a0,-1566 # 800210e0 <itable>
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	584080e7          	jalr	1412(ra) # 80000c8a <release>
      return ip;
    8000370e:	8926                	mv	s2,s1
    80003710:	a03d                	j	8000373e <iget+0x9a>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003712:	f7f9                	bnez	a5,800036e0 <iget+0x3c>
    80003714:	8926                	mv	s2,s1
    80003716:	b7e9                	j	800036e0 <iget+0x3c>
  if (empty == 0)
    80003718:	02090c63          	beqz	s2,80003750 <iget+0xac>
  ip->dev = dev;
    8000371c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003720:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003724:	4785                	li	a5,1
    80003726:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000372a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000372e:	0001e517          	auipc	a0,0x1e
    80003732:	9b250513          	addi	a0,a0,-1614 # 800210e0 <itable>
    80003736:	ffffd097          	auipc	ra,0xffffd
    8000373a:	554080e7          	jalr	1364(ra) # 80000c8a <release>
}
    8000373e:	854a                	mv	a0,s2
    80003740:	70a2                	ld	ra,40(sp)
    80003742:	7402                	ld	s0,32(sp)
    80003744:	64e2                	ld	s1,24(sp)
    80003746:	6942                	ld	s2,16(sp)
    80003748:	69a2                	ld	s3,8(sp)
    8000374a:	6a02                	ld	s4,0(sp)
    8000374c:	6145                	addi	sp,sp,48
    8000374e:	8082                	ret
    panic("iget: no inodes");
    80003750:	00005517          	auipc	a0,0x5
    80003754:	e5050513          	addi	a0,a0,-432 # 800085a0 <syscalls+0x148>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	de8080e7          	jalr	-536(ra) # 80000540 <panic>

0000000080003760 <fsinit>:
{
    80003760:	7179                	addi	sp,sp,-48
    80003762:	f406                	sd	ra,40(sp)
    80003764:	f022                	sd	s0,32(sp)
    80003766:	ec26                	sd	s1,24(sp)
    80003768:	e84a                	sd	s2,16(sp)
    8000376a:	e44e                	sd	s3,8(sp)
    8000376c:	1800                	addi	s0,sp,48
    8000376e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003770:	4585                	li	a1,1
    80003772:	00000097          	auipc	ra,0x0
    80003776:	a54080e7          	jalr	-1452(ra) # 800031c6 <bread>
    8000377a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000377c:	0001e997          	auipc	s3,0x1e
    80003780:	94498993          	addi	s3,s3,-1724 # 800210c0 <sb>
    80003784:	02000613          	li	a2,32
    80003788:	05850593          	addi	a1,a0,88
    8000378c:	854e                	mv	a0,s3
    8000378e:	ffffd097          	auipc	ra,0xffffd
    80003792:	5a0080e7          	jalr	1440(ra) # 80000d2e <memmove>
  brelse(bp);
    80003796:	8526                	mv	a0,s1
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	b5e080e7          	jalr	-1186(ra) # 800032f6 <brelse>
  if (sb.magic != FSMAGIC)
    800037a0:	0009a703          	lw	a4,0(s3)
    800037a4:	102037b7          	lui	a5,0x10203
    800037a8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037ac:	02f71263          	bne	a4,a5,800037d0 <fsinit+0x70>
  initlog(dev, &sb);
    800037b0:	0001e597          	auipc	a1,0x1e
    800037b4:	91058593          	addi	a1,a1,-1776 # 800210c0 <sb>
    800037b8:	854a                	mv	a0,s2
    800037ba:	00001097          	auipc	ra,0x1
    800037be:	b4a080e7          	jalr	-1206(ra) # 80004304 <initlog>
}
    800037c2:	70a2                	ld	ra,40(sp)
    800037c4:	7402                	ld	s0,32(sp)
    800037c6:	64e2                	ld	s1,24(sp)
    800037c8:	6942                	ld	s2,16(sp)
    800037ca:	69a2                	ld	s3,8(sp)
    800037cc:	6145                	addi	sp,sp,48
    800037ce:	8082                	ret
    panic("invalid file system");
    800037d0:	00005517          	auipc	a0,0x5
    800037d4:	de050513          	addi	a0,a0,-544 # 800085b0 <syscalls+0x158>
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	d68080e7          	jalr	-664(ra) # 80000540 <panic>

00000000800037e0 <iinit>:
{
    800037e0:	7179                	addi	sp,sp,-48
    800037e2:	f406                	sd	ra,40(sp)
    800037e4:	f022                	sd	s0,32(sp)
    800037e6:	ec26                	sd	s1,24(sp)
    800037e8:	e84a                	sd	s2,16(sp)
    800037ea:	e44e                	sd	s3,8(sp)
    800037ec:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800037ee:	00005597          	auipc	a1,0x5
    800037f2:	dda58593          	addi	a1,a1,-550 # 800085c8 <syscalls+0x170>
    800037f6:	0001e517          	auipc	a0,0x1e
    800037fa:	8ea50513          	addi	a0,a0,-1814 # 800210e0 <itable>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	348080e7          	jalr	840(ra) # 80000b46 <initlock>
  for (i = 0; i < NINODE; i++)
    80003806:	0001e497          	auipc	s1,0x1e
    8000380a:	90248493          	addi	s1,s1,-1790 # 80021108 <itable+0x28>
    8000380e:	0001f997          	auipc	s3,0x1f
    80003812:	38a98993          	addi	s3,s3,906 # 80022b98 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003816:	00005917          	auipc	s2,0x5
    8000381a:	dba90913          	addi	s2,s2,-582 # 800085d0 <syscalls+0x178>
    8000381e:	85ca                	mv	a1,s2
    80003820:	8526                	mv	a0,s1
    80003822:	00001097          	auipc	ra,0x1
    80003826:	e42080e7          	jalr	-446(ra) # 80004664 <initsleeplock>
  for (i = 0; i < NINODE; i++)
    8000382a:	08848493          	addi	s1,s1,136
    8000382e:	ff3498e3          	bne	s1,s3,8000381e <iinit+0x3e>
}
    80003832:	70a2                	ld	ra,40(sp)
    80003834:	7402                	ld	s0,32(sp)
    80003836:	64e2                	ld	s1,24(sp)
    80003838:	6942                	ld	s2,16(sp)
    8000383a:	69a2                	ld	s3,8(sp)
    8000383c:	6145                	addi	sp,sp,48
    8000383e:	8082                	ret

0000000080003840 <ialloc>:
{
    80003840:	715d                	addi	sp,sp,-80
    80003842:	e486                	sd	ra,72(sp)
    80003844:	e0a2                	sd	s0,64(sp)
    80003846:	fc26                	sd	s1,56(sp)
    80003848:	f84a                	sd	s2,48(sp)
    8000384a:	f44e                	sd	s3,40(sp)
    8000384c:	f052                	sd	s4,32(sp)
    8000384e:	ec56                	sd	s5,24(sp)
    80003850:	e85a                	sd	s6,16(sp)
    80003852:	e45e                	sd	s7,8(sp)
    80003854:	0880                	addi	s0,sp,80
  for (inum = 1; inum < sb.ninodes; inum++)
    80003856:	0001e717          	auipc	a4,0x1e
    8000385a:	87672703          	lw	a4,-1930(a4) # 800210cc <sb+0xc>
    8000385e:	4785                	li	a5,1
    80003860:	04e7fa63          	bgeu	a5,a4,800038b4 <ialloc+0x74>
    80003864:	8aaa                	mv	s5,a0
    80003866:	8bae                	mv	s7,a1
    80003868:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000386a:	0001ea17          	auipc	s4,0x1e
    8000386e:	856a0a13          	addi	s4,s4,-1962 # 800210c0 <sb>
    80003872:	00048b1b          	sext.w	s6,s1
    80003876:	0044d593          	srli	a1,s1,0x4
    8000387a:	018a2783          	lw	a5,24(s4)
    8000387e:	9dbd                	addw	a1,a1,a5
    80003880:	8556                	mv	a0,s5
    80003882:	00000097          	auipc	ra,0x0
    80003886:	944080e7          	jalr	-1724(ra) # 800031c6 <bread>
    8000388a:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000388c:	05850993          	addi	s3,a0,88
    80003890:	00f4f793          	andi	a5,s1,15
    80003894:	079a                	slli	a5,a5,0x6
    80003896:	99be                	add	s3,s3,a5
    if (dip->type == 0)
    80003898:	00099783          	lh	a5,0(s3)
    8000389c:	c3a1                	beqz	a5,800038dc <ialloc+0x9c>
    brelse(bp);
    8000389e:	00000097          	auipc	ra,0x0
    800038a2:	a58080e7          	jalr	-1448(ra) # 800032f6 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++)
    800038a6:	0485                	addi	s1,s1,1
    800038a8:	00ca2703          	lw	a4,12(s4)
    800038ac:	0004879b          	sext.w	a5,s1
    800038b0:	fce7e1e3          	bltu	a5,a4,80003872 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800038b4:	00005517          	auipc	a0,0x5
    800038b8:	d2450513          	addi	a0,a0,-732 # 800085d8 <syscalls+0x180>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	cce080e7          	jalr	-818(ra) # 8000058a <printf>
  return 0;
    800038c4:	4501                	li	a0,0
}
    800038c6:	60a6                	ld	ra,72(sp)
    800038c8:	6406                	ld	s0,64(sp)
    800038ca:	74e2                	ld	s1,56(sp)
    800038cc:	7942                	ld	s2,48(sp)
    800038ce:	79a2                	ld	s3,40(sp)
    800038d0:	7a02                	ld	s4,32(sp)
    800038d2:	6ae2                	ld	s5,24(sp)
    800038d4:	6b42                	ld	s6,16(sp)
    800038d6:	6ba2                	ld	s7,8(sp)
    800038d8:	6161                	addi	sp,sp,80
    800038da:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038dc:	04000613          	li	a2,64
    800038e0:	4581                	li	a1,0
    800038e2:	854e                	mv	a0,s3
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	3ee080e7          	jalr	1006(ra) # 80000cd2 <memset>
      dip->type = type;
    800038ec:	01799023          	sh	s7,0(s3)
      log_write(bp); // mark it allocated on the disk
    800038f0:	854a                	mv	a0,s2
    800038f2:	00001097          	auipc	ra,0x1
    800038f6:	c8e080e7          	jalr	-882(ra) # 80004580 <log_write>
      brelse(bp);
    800038fa:	854a                	mv	a0,s2
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	9fa080e7          	jalr	-1542(ra) # 800032f6 <brelse>
      return iget(dev, inum);
    80003904:	85da                	mv	a1,s6
    80003906:	8556                	mv	a0,s5
    80003908:	00000097          	auipc	ra,0x0
    8000390c:	d9c080e7          	jalr	-612(ra) # 800036a4 <iget>
    80003910:	bf5d                	j	800038c6 <ialloc+0x86>

0000000080003912 <iupdate>:
{
    80003912:	1101                	addi	sp,sp,-32
    80003914:	ec06                	sd	ra,24(sp)
    80003916:	e822                	sd	s0,16(sp)
    80003918:	e426                	sd	s1,8(sp)
    8000391a:	e04a                	sd	s2,0(sp)
    8000391c:	1000                	addi	s0,sp,32
    8000391e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003920:	415c                	lw	a5,4(a0)
    80003922:	0047d79b          	srliw	a5,a5,0x4
    80003926:	0001d597          	auipc	a1,0x1d
    8000392a:	7b25a583          	lw	a1,1970(a1) # 800210d8 <sb+0x18>
    8000392e:	9dbd                	addw	a1,a1,a5
    80003930:	4108                	lw	a0,0(a0)
    80003932:	00000097          	auipc	ra,0x0
    80003936:	894080e7          	jalr	-1900(ra) # 800031c6 <bread>
    8000393a:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000393c:	05850793          	addi	a5,a0,88
    80003940:	40d8                	lw	a4,4(s1)
    80003942:	8b3d                	andi	a4,a4,15
    80003944:	071a                	slli	a4,a4,0x6
    80003946:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003948:	04449703          	lh	a4,68(s1)
    8000394c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003950:	04649703          	lh	a4,70(s1)
    80003954:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003958:	04849703          	lh	a4,72(s1)
    8000395c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003960:	04a49703          	lh	a4,74(s1)
    80003964:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003968:	44f8                	lw	a4,76(s1)
    8000396a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000396c:	03400613          	li	a2,52
    80003970:	05048593          	addi	a1,s1,80
    80003974:	00c78513          	addi	a0,a5,12
    80003978:	ffffd097          	auipc	ra,0xffffd
    8000397c:	3b6080e7          	jalr	950(ra) # 80000d2e <memmove>
  log_write(bp);
    80003980:	854a                	mv	a0,s2
    80003982:	00001097          	auipc	ra,0x1
    80003986:	bfe080e7          	jalr	-1026(ra) # 80004580 <log_write>
  brelse(bp);
    8000398a:	854a                	mv	a0,s2
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	96a080e7          	jalr	-1686(ra) # 800032f6 <brelse>
}
    80003994:	60e2                	ld	ra,24(sp)
    80003996:	6442                	ld	s0,16(sp)
    80003998:	64a2                	ld	s1,8(sp)
    8000399a:	6902                	ld	s2,0(sp)
    8000399c:	6105                	addi	sp,sp,32
    8000399e:	8082                	ret

00000000800039a0 <idup>:
{
    800039a0:	1101                	addi	sp,sp,-32
    800039a2:	ec06                	sd	ra,24(sp)
    800039a4:	e822                	sd	s0,16(sp)
    800039a6:	e426                	sd	s1,8(sp)
    800039a8:	1000                	addi	s0,sp,32
    800039aa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039ac:	0001d517          	auipc	a0,0x1d
    800039b0:	73450513          	addi	a0,a0,1844 # 800210e0 <itable>
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	222080e7          	jalr	546(ra) # 80000bd6 <acquire>
  ip->ref++;
    800039bc:	449c                	lw	a5,8(s1)
    800039be:	2785                	addiw	a5,a5,1
    800039c0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039c2:	0001d517          	auipc	a0,0x1d
    800039c6:	71e50513          	addi	a0,a0,1822 # 800210e0 <itable>
    800039ca:	ffffd097          	auipc	ra,0xffffd
    800039ce:	2c0080e7          	jalr	704(ra) # 80000c8a <release>
}
    800039d2:	8526                	mv	a0,s1
    800039d4:	60e2                	ld	ra,24(sp)
    800039d6:	6442                	ld	s0,16(sp)
    800039d8:	64a2                	ld	s1,8(sp)
    800039da:	6105                	addi	sp,sp,32
    800039dc:	8082                	ret

00000000800039de <ilock>:
{
    800039de:	1101                	addi	sp,sp,-32
    800039e0:	ec06                	sd	ra,24(sp)
    800039e2:	e822                	sd	s0,16(sp)
    800039e4:	e426                	sd	s1,8(sp)
    800039e6:	e04a                	sd	s2,0(sp)
    800039e8:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800039ea:	c115                	beqz	a0,80003a0e <ilock+0x30>
    800039ec:	84aa                	mv	s1,a0
    800039ee:	451c                	lw	a5,8(a0)
    800039f0:	00f05f63          	blez	a5,80003a0e <ilock+0x30>
  acquiresleep(&ip->lock);
    800039f4:	0541                	addi	a0,a0,16
    800039f6:	00001097          	auipc	ra,0x1
    800039fa:	ca8080e7          	jalr	-856(ra) # 8000469e <acquiresleep>
  if (ip->valid == 0)
    800039fe:	40bc                	lw	a5,64(s1)
    80003a00:	cf99                	beqz	a5,80003a1e <ilock+0x40>
}
    80003a02:	60e2                	ld	ra,24(sp)
    80003a04:	6442                	ld	s0,16(sp)
    80003a06:	64a2                	ld	s1,8(sp)
    80003a08:	6902                	ld	s2,0(sp)
    80003a0a:	6105                	addi	sp,sp,32
    80003a0c:	8082                	ret
    panic("ilock");
    80003a0e:	00005517          	auipc	a0,0x5
    80003a12:	be250513          	addi	a0,a0,-1054 # 800085f0 <syscalls+0x198>
    80003a16:	ffffd097          	auipc	ra,0xffffd
    80003a1a:	b2a080e7          	jalr	-1238(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a1e:	40dc                	lw	a5,4(s1)
    80003a20:	0047d79b          	srliw	a5,a5,0x4
    80003a24:	0001d597          	auipc	a1,0x1d
    80003a28:	6b45a583          	lw	a1,1716(a1) # 800210d8 <sb+0x18>
    80003a2c:	9dbd                	addw	a1,a1,a5
    80003a2e:	4088                	lw	a0,0(s1)
    80003a30:	fffff097          	auipc	ra,0xfffff
    80003a34:	796080e7          	jalr	1942(ra) # 800031c6 <bread>
    80003a38:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003a3a:	05850593          	addi	a1,a0,88
    80003a3e:	40dc                	lw	a5,4(s1)
    80003a40:	8bbd                	andi	a5,a5,15
    80003a42:	079a                	slli	a5,a5,0x6
    80003a44:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a46:	00059783          	lh	a5,0(a1)
    80003a4a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a4e:	00259783          	lh	a5,2(a1)
    80003a52:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a56:	00459783          	lh	a5,4(a1)
    80003a5a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a5e:	00659783          	lh	a5,6(a1)
    80003a62:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a66:	459c                	lw	a5,8(a1)
    80003a68:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a6a:	03400613          	li	a2,52
    80003a6e:	05b1                	addi	a1,a1,12
    80003a70:	05048513          	addi	a0,s1,80
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	2ba080e7          	jalr	698(ra) # 80000d2e <memmove>
    brelse(bp);
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	00000097          	auipc	ra,0x0
    80003a82:	878080e7          	jalr	-1928(ra) # 800032f6 <brelse>
    ip->valid = 1;
    80003a86:	4785                	li	a5,1
    80003a88:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003a8a:	04449783          	lh	a5,68(s1)
    80003a8e:	fbb5                	bnez	a5,80003a02 <ilock+0x24>
      panic("ilock: no type");
    80003a90:	00005517          	auipc	a0,0x5
    80003a94:	b6850513          	addi	a0,a0,-1176 # 800085f8 <syscalls+0x1a0>
    80003a98:	ffffd097          	auipc	ra,0xffffd
    80003a9c:	aa8080e7          	jalr	-1368(ra) # 80000540 <panic>

0000000080003aa0 <iunlock>:
{
    80003aa0:	1101                	addi	sp,sp,-32
    80003aa2:	ec06                	sd	ra,24(sp)
    80003aa4:	e822                	sd	s0,16(sp)
    80003aa6:	e426                	sd	s1,8(sp)
    80003aa8:	e04a                	sd	s2,0(sp)
    80003aaa:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003aac:	c905                	beqz	a0,80003adc <iunlock+0x3c>
    80003aae:	84aa                	mv	s1,a0
    80003ab0:	01050913          	addi	s2,a0,16
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	00001097          	auipc	ra,0x1
    80003aba:	c82080e7          	jalr	-894(ra) # 80004738 <holdingsleep>
    80003abe:	cd19                	beqz	a0,80003adc <iunlock+0x3c>
    80003ac0:	449c                	lw	a5,8(s1)
    80003ac2:	00f05d63          	blez	a5,80003adc <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ac6:	854a                	mv	a0,s2
    80003ac8:	00001097          	auipc	ra,0x1
    80003acc:	c2c080e7          	jalr	-980(ra) # 800046f4 <releasesleep>
}
    80003ad0:	60e2                	ld	ra,24(sp)
    80003ad2:	6442                	ld	s0,16(sp)
    80003ad4:	64a2                	ld	s1,8(sp)
    80003ad6:	6902                	ld	s2,0(sp)
    80003ad8:	6105                	addi	sp,sp,32
    80003ada:	8082                	ret
    panic("iunlock");
    80003adc:	00005517          	auipc	a0,0x5
    80003ae0:	b2c50513          	addi	a0,a0,-1236 # 80008608 <syscalls+0x1b0>
    80003ae4:	ffffd097          	auipc	ra,0xffffd
    80003ae8:	a5c080e7          	jalr	-1444(ra) # 80000540 <panic>

0000000080003aec <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void itrunc(struct inode *ip)
{
    80003aec:	7179                	addi	sp,sp,-48
    80003aee:	f406                	sd	ra,40(sp)
    80003af0:	f022                	sd	s0,32(sp)
    80003af2:	ec26                	sd	s1,24(sp)
    80003af4:	e84a                	sd	s2,16(sp)
    80003af6:	e44e                	sd	s3,8(sp)
    80003af8:	e052                	sd	s4,0(sp)
    80003afa:	1800                	addi	s0,sp,48
    80003afc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++)
    80003afe:	05050493          	addi	s1,a0,80
    80003b02:	08050913          	addi	s2,a0,128
    80003b06:	a021                	j	80003b0e <itrunc+0x22>
    80003b08:	0491                	addi	s1,s1,4
    80003b0a:	01248d63          	beq	s1,s2,80003b24 <itrunc+0x38>
  {
    if (ip->addrs[i])
    80003b0e:	408c                	lw	a1,0(s1)
    80003b10:	dde5                	beqz	a1,80003b08 <itrunc+0x1c>
    {
      bfree(ip->dev, ip->addrs[i]);
    80003b12:	0009a503          	lw	a0,0(s3)
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	8f6080e7          	jalr	-1802(ra) # 8000340c <bfree>
      ip->addrs[i] = 0;
    80003b1e:	0004a023          	sw	zero,0(s1)
    80003b22:	b7dd                	j	80003b08 <itrunc+0x1c>
    }
  }

  if (ip->addrs[NDIRECT])
    80003b24:	0809a583          	lw	a1,128(s3)
    80003b28:	e185                	bnez	a1,80003b48 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b2a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b2e:	854e                	mv	a0,s3
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	de2080e7          	jalr	-542(ra) # 80003912 <iupdate>
}
    80003b38:	70a2                	ld	ra,40(sp)
    80003b3a:	7402                	ld	s0,32(sp)
    80003b3c:	64e2                	ld	s1,24(sp)
    80003b3e:	6942                	ld	s2,16(sp)
    80003b40:	69a2                	ld	s3,8(sp)
    80003b42:	6a02                	ld	s4,0(sp)
    80003b44:	6145                	addi	sp,sp,48
    80003b46:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b48:	0009a503          	lw	a0,0(s3)
    80003b4c:	fffff097          	auipc	ra,0xfffff
    80003b50:	67a080e7          	jalr	1658(ra) # 800031c6 <bread>
    80003b54:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++)
    80003b56:	05850493          	addi	s1,a0,88
    80003b5a:	45850913          	addi	s2,a0,1112
    80003b5e:	a021                	j	80003b66 <itrunc+0x7a>
    80003b60:	0491                	addi	s1,s1,4
    80003b62:	01248b63          	beq	s1,s2,80003b78 <itrunc+0x8c>
      if (a[j])
    80003b66:	408c                	lw	a1,0(s1)
    80003b68:	dde5                	beqz	a1,80003b60 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b6a:	0009a503          	lw	a0,0(s3)
    80003b6e:	00000097          	auipc	ra,0x0
    80003b72:	89e080e7          	jalr	-1890(ra) # 8000340c <bfree>
    80003b76:	b7ed                	j	80003b60 <itrunc+0x74>
    brelse(bp);
    80003b78:	8552                	mv	a0,s4
    80003b7a:	fffff097          	auipc	ra,0xfffff
    80003b7e:	77c080e7          	jalr	1916(ra) # 800032f6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b82:	0809a583          	lw	a1,128(s3)
    80003b86:	0009a503          	lw	a0,0(s3)
    80003b8a:	00000097          	auipc	ra,0x0
    80003b8e:	882080e7          	jalr	-1918(ra) # 8000340c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b92:	0809a023          	sw	zero,128(s3)
    80003b96:	bf51                	j	80003b2a <itrunc+0x3e>

0000000080003b98 <iput>:
{
    80003b98:	1101                	addi	sp,sp,-32
    80003b9a:	ec06                	sd	ra,24(sp)
    80003b9c:	e822                	sd	s0,16(sp)
    80003b9e:	e426                	sd	s1,8(sp)
    80003ba0:	e04a                	sd	s2,0(sp)
    80003ba2:	1000                	addi	s0,sp,32
    80003ba4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ba6:	0001d517          	auipc	a0,0x1d
    80003baa:	53a50513          	addi	a0,a0,1338 # 800210e0 <itable>
    80003bae:	ffffd097          	auipc	ra,0xffffd
    80003bb2:	028080e7          	jalr	40(ra) # 80000bd6 <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003bb6:	4498                	lw	a4,8(s1)
    80003bb8:	4785                	li	a5,1
    80003bba:	02f70363          	beq	a4,a5,80003be0 <iput+0x48>
  ip->ref--;
    80003bbe:	449c                	lw	a5,8(s1)
    80003bc0:	37fd                	addiw	a5,a5,-1
    80003bc2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bc4:	0001d517          	auipc	a0,0x1d
    80003bc8:	51c50513          	addi	a0,a0,1308 # 800210e0 <itable>
    80003bcc:	ffffd097          	auipc	ra,0xffffd
    80003bd0:	0be080e7          	jalr	190(ra) # 80000c8a <release>
}
    80003bd4:	60e2                	ld	ra,24(sp)
    80003bd6:	6442                	ld	s0,16(sp)
    80003bd8:	64a2                	ld	s1,8(sp)
    80003bda:	6902                	ld	s2,0(sp)
    80003bdc:	6105                	addi	sp,sp,32
    80003bde:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003be0:	40bc                	lw	a5,64(s1)
    80003be2:	dff1                	beqz	a5,80003bbe <iput+0x26>
    80003be4:	04a49783          	lh	a5,74(s1)
    80003be8:	fbf9                	bnez	a5,80003bbe <iput+0x26>
    acquiresleep(&ip->lock);
    80003bea:	01048913          	addi	s2,s1,16
    80003bee:	854a                	mv	a0,s2
    80003bf0:	00001097          	auipc	ra,0x1
    80003bf4:	aae080e7          	jalr	-1362(ra) # 8000469e <acquiresleep>
    release(&itable.lock);
    80003bf8:	0001d517          	auipc	a0,0x1d
    80003bfc:	4e850513          	addi	a0,a0,1256 # 800210e0 <itable>
    80003c00:	ffffd097          	auipc	ra,0xffffd
    80003c04:	08a080e7          	jalr	138(ra) # 80000c8a <release>
    itrunc(ip);
    80003c08:	8526                	mv	a0,s1
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	ee2080e7          	jalr	-286(ra) # 80003aec <itrunc>
    ip->type = 0;
    80003c12:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c16:	8526                	mv	a0,s1
    80003c18:	00000097          	auipc	ra,0x0
    80003c1c:	cfa080e7          	jalr	-774(ra) # 80003912 <iupdate>
    ip->valid = 0;
    80003c20:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c24:	854a                	mv	a0,s2
    80003c26:	00001097          	auipc	ra,0x1
    80003c2a:	ace080e7          	jalr	-1330(ra) # 800046f4 <releasesleep>
    acquire(&itable.lock);
    80003c2e:	0001d517          	auipc	a0,0x1d
    80003c32:	4b250513          	addi	a0,a0,1202 # 800210e0 <itable>
    80003c36:	ffffd097          	auipc	ra,0xffffd
    80003c3a:	fa0080e7          	jalr	-96(ra) # 80000bd6 <acquire>
    80003c3e:	b741                	j	80003bbe <iput+0x26>

0000000080003c40 <iunlockput>:
{
    80003c40:	1101                	addi	sp,sp,-32
    80003c42:	ec06                	sd	ra,24(sp)
    80003c44:	e822                	sd	s0,16(sp)
    80003c46:	e426                	sd	s1,8(sp)
    80003c48:	1000                	addi	s0,sp,32
    80003c4a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c4c:	00000097          	auipc	ra,0x0
    80003c50:	e54080e7          	jalr	-428(ra) # 80003aa0 <iunlock>
  iput(ip);
    80003c54:	8526                	mv	a0,s1
    80003c56:	00000097          	auipc	ra,0x0
    80003c5a:	f42080e7          	jalr	-190(ra) # 80003b98 <iput>
}
    80003c5e:	60e2                	ld	ra,24(sp)
    80003c60:	6442                	ld	s0,16(sp)
    80003c62:	64a2                	ld	s1,8(sp)
    80003c64:	6105                	addi	sp,sp,32
    80003c66:	8082                	ret

0000000080003c68 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void stati(struct inode *ip, struct stat *st)
{
    80003c68:	1141                	addi	sp,sp,-16
    80003c6a:	e422                	sd	s0,8(sp)
    80003c6c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c6e:	411c                	lw	a5,0(a0)
    80003c70:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c72:	415c                	lw	a5,4(a0)
    80003c74:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c76:	04451783          	lh	a5,68(a0)
    80003c7a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c7e:	04a51783          	lh	a5,74(a0)
    80003c82:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c86:	04c56783          	lwu	a5,76(a0)
    80003c8a:	e99c                	sd	a5,16(a1)
}
    80003c8c:	6422                	ld	s0,8(sp)
    80003c8e:	0141                	addi	sp,sp,16
    80003c90:	8082                	ret

0000000080003c92 <readi>:
int readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003c92:	457c                	lw	a5,76(a0)
    80003c94:	0ed7e963          	bltu	a5,a3,80003d86 <readi+0xf4>
{
    80003c98:	7159                	addi	sp,sp,-112
    80003c9a:	f486                	sd	ra,104(sp)
    80003c9c:	f0a2                	sd	s0,96(sp)
    80003c9e:	eca6                	sd	s1,88(sp)
    80003ca0:	e8ca                	sd	s2,80(sp)
    80003ca2:	e4ce                	sd	s3,72(sp)
    80003ca4:	e0d2                	sd	s4,64(sp)
    80003ca6:	fc56                	sd	s5,56(sp)
    80003ca8:	f85a                	sd	s6,48(sp)
    80003caa:	f45e                	sd	s7,40(sp)
    80003cac:	f062                	sd	s8,32(sp)
    80003cae:	ec66                	sd	s9,24(sp)
    80003cb0:	e86a                	sd	s10,16(sp)
    80003cb2:	e46e                	sd	s11,8(sp)
    80003cb4:	1880                	addi	s0,sp,112
    80003cb6:	8b2a                	mv	s6,a0
    80003cb8:	8bae                	mv	s7,a1
    80003cba:	8a32                	mv	s4,a2
    80003cbc:	84b6                	mv	s1,a3
    80003cbe:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003cc0:	9f35                	addw	a4,a4,a3
    return 0;
    80003cc2:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003cc4:	0ad76063          	bltu	a4,a3,80003d64 <readi+0xd2>
  if (off + n > ip->size)
    80003cc8:	00e7f463          	bgeu	a5,a4,80003cd0 <readi+0x3e>
    n = ip->size - off;
    80003ccc:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003cd0:	0a0a8963          	beqz	s5,80003d82 <readi+0xf0>
    80003cd4:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003cd6:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1)
    80003cda:	5c7d                	li	s8,-1
    80003cdc:	a82d                	j	80003d16 <readi+0x84>
    80003cde:	020d1d93          	slli	s11,s10,0x20
    80003ce2:	020ddd93          	srli	s11,s11,0x20
    80003ce6:	05890613          	addi	a2,s2,88
    80003cea:	86ee                	mv	a3,s11
    80003cec:	963a                	add	a2,a2,a4
    80003cee:	85d2                	mv	a1,s4
    80003cf0:	855e                	mv	a0,s7
    80003cf2:	fffff097          	auipc	ra,0xfffff
    80003cf6:	828080e7          	jalr	-2008(ra) # 8000251a <either_copyout>
    80003cfa:	05850d63          	beq	a0,s8,80003d54 <readi+0xc2>
    {
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cfe:	854a                	mv	a0,s2
    80003d00:	fffff097          	auipc	ra,0xfffff
    80003d04:	5f6080e7          	jalr	1526(ra) # 800032f6 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003d08:	013d09bb          	addw	s3,s10,s3
    80003d0c:	009d04bb          	addw	s1,s10,s1
    80003d10:	9a6e                	add	s4,s4,s11
    80003d12:	0559f763          	bgeu	s3,s5,80003d60 <readi+0xce>
    uint addr = bmap(ip, off / BSIZE);
    80003d16:	00a4d59b          	srliw	a1,s1,0xa
    80003d1a:	855a                	mv	a0,s6
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	89e080e7          	jalr	-1890(ra) # 800035ba <bmap>
    80003d24:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003d28:	cd85                	beqz	a1,80003d60 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d2a:	000b2503          	lw	a0,0(s6)
    80003d2e:	fffff097          	auipc	ra,0xfffff
    80003d32:	498080e7          	jalr	1176(ra) # 800031c6 <bread>
    80003d36:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003d38:	3ff4f713          	andi	a4,s1,1023
    80003d3c:	40ec87bb          	subw	a5,s9,a4
    80003d40:	413a86bb          	subw	a3,s5,s3
    80003d44:	8d3e                	mv	s10,a5
    80003d46:	2781                	sext.w	a5,a5
    80003d48:	0006861b          	sext.w	a2,a3
    80003d4c:	f8f679e3          	bgeu	a2,a5,80003cde <readi+0x4c>
    80003d50:	8d36                	mv	s10,a3
    80003d52:	b771                	j	80003cde <readi+0x4c>
      brelse(bp);
    80003d54:	854a                	mv	a0,s2
    80003d56:	fffff097          	auipc	ra,0xfffff
    80003d5a:	5a0080e7          	jalr	1440(ra) # 800032f6 <brelse>
      tot = -1;
    80003d5e:	59fd                	li	s3,-1
  }
  return tot;
    80003d60:	0009851b          	sext.w	a0,s3
}
    80003d64:	70a6                	ld	ra,104(sp)
    80003d66:	7406                	ld	s0,96(sp)
    80003d68:	64e6                	ld	s1,88(sp)
    80003d6a:	6946                	ld	s2,80(sp)
    80003d6c:	69a6                	ld	s3,72(sp)
    80003d6e:	6a06                	ld	s4,64(sp)
    80003d70:	7ae2                	ld	s5,56(sp)
    80003d72:	7b42                	ld	s6,48(sp)
    80003d74:	7ba2                	ld	s7,40(sp)
    80003d76:	7c02                	ld	s8,32(sp)
    80003d78:	6ce2                	ld	s9,24(sp)
    80003d7a:	6d42                	ld	s10,16(sp)
    80003d7c:	6da2                	ld	s11,8(sp)
    80003d7e:	6165                	addi	sp,sp,112
    80003d80:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003d82:	89d6                	mv	s3,s5
    80003d84:	bff1                	j	80003d60 <readi+0xce>
    return 0;
    80003d86:	4501                	li	a0,0
}
    80003d88:	8082                	ret

0000000080003d8a <writei>:
int writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003d8a:	457c                	lw	a5,76(a0)
    80003d8c:	10d7e863          	bltu	a5,a3,80003e9c <writei+0x112>
{
    80003d90:	7159                	addi	sp,sp,-112
    80003d92:	f486                	sd	ra,104(sp)
    80003d94:	f0a2                	sd	s0,96(sp)
    80003d96:	eca6                	sd	s1,88(sp)
    80003d98:	e8ca                	sd	s2,80(sp)
    80003d9a:	e4ce                	sd	s3,72(sp)
    80003d9c:	e0d2                	sd	s4,64(sp)
    80003d9e:	fc56                	sd	s5,56(sp)
    80003da0:	f85a                	sd	s6,48(sp)
    80003da2:	f45e                	sd	s7,40(sp)
    80003da4:	f062                	sd	s8,32(sp)
    80003da6:	ec66                	sd	s9,24(sp)
    80003da8:	e86a                	sd	s10,16(sp)
    80003daa:	e46e                	sd	s11,8(sp)
    80003dac:	1880                	addi	s0,sp,112
    80003dae:	8aaa                	mv	s5,a0
    80003db0:	8bae                	mv	s7,a1
    80003db2:	8a32                	mv	s4,a2
    80003db4:	8936                	mv	s2,a3
    80003db6:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003db8:	00e687bb          	addw	a5,a3,a4
    80003dbc:	0ed7e263          	bltu	a5,a3,80003ea0 <writei+0x116>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003dc0:	00043737          	lui	a4,0x43
    80003dc4:	0ef76063          	bltu	a4,a5,80003ea4 <writei+0x11a>
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003dc8:	0c0b0863          	beqz	s6,80003e98 <writei+0x10e>
    80003dcc:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003dce:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1)
    80003dd2:	5c7d                	li	s8,-1
    80003dd4:	a091                	j	80003e18 <writei+0x8e>
    80003dd6:	020d1d93          	slli	s11,s10,0x20
    80003dda:	020ddd93          	srli	s11,s11,0x20
    80003dde:	05848513          	addi	a0,s1,88
    80003de2:	86ee                	mv	a3,s11
    80003de4:	8652                	mv	a2,s4
    80003de6:	85de                	mv	a1,s7
    80003de8:	953a                	add	a0,a0,a4
    80003dea:	ffffe097          	auipc	ra,0xffffe
    80003dee:	786080e7          	jalr	1926(ra) # 80002570 <either_copyin>
    80003df2:	07850263          	beq	a0,s8,80003e56 <writei+0xcc>
    {
      brelse(bp);
      break;
    }
    log_write(bp);
    80003df6:	8526                	mv	a0,s1
    80003df8:	00000097          	auipc	ra,0x0
    80003dfc:	788080e7          	jalr	1928(ra) # 80004580 <log_write>
    brelse(bp);
    80003e00:	8526                	mv	a0,s1
    80003e02:	fffff097          	auipc	ra,0xfffff
    80003e06:	4f4080e7          	jalr	1268(ra) # 800032f6 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003e0a:	013d09bb          	addw	s3,s10,s3
    80003e0e:	012d093b          	addw	s2,s10,s2
    80003e12:	9a6e                	add	s4,s4,s11
    80003e14:	0569f663          	bgeu	s3,s6,80003e60 <writei+0xd6>
    uint addr = bmap(ip, off / BSIZE);
    80003e18:	00a9559b          	srliw	a1,s2,0xa
    80003e1c:	8556                	mv	a0,s5
    80003e1e:	fffff097          	auipc	ra,0xfffff
    80003e22:	79c080e7          	jalr	1948(ra) # 800035ba <bmap>
    80003e26:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003e2a:	c99d                	beqz	a1,80003e60 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e2c:	000aa503          	lw	a0,0(s5)
    80003e30:	fffff097          	auipc	ra,0xfffff
    80003e34:	396080e7          	jalr	918(ra) # 800031c6 <bread>
    80003e38:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003e3a:	3ff97713          	andi	a4,s2,1023
    80003e3e:	40ec87bb          	subw	a5,s9,a4
    80003e42:	413b06bb          	subw	a3,s6,s3
    80003e46:	8d3e                	mv	s10,a5
    80003e48:	2781                	sext.w	a5,a5
    80003e4a:	0006861b          	sext.w	a2,a3
    80003e4e:	f8f674e3          	bgeu	a2,a5,80003dd6 <writei+0x4c>
    80003e52:	8d36                	mv	s10,a3
    80003e54:	b749                	j	80003dd6 <writei+0x4c>
      brelse(bp);
    80003e56:	8526                	mv	a0,s1
    80003e58:	fffff097          	auipc	ra,0xfffff
    80003e5c:	49e080e7          	jalr	1182(ra) # 800032f6 <brelse>
  }

  if (off > ip->size)
    80003e60:	04caa783          	lw	a5,76(s5)
    80003e64:	0127f463          	bgeu	a5,s2,80003e6c <writei+0xe2>
    ip->size = off;
    80003e68:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e6c:	8556                	mv	a0,s5
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	aa4080e7          	jalr	-1372(ra) # 80003912 <iupdate>

  return tot;
    80003e76:	0009851b          	sext.w	a0,s3
}
    80003e7a:	70a6                	ld	ra,104(sp)
    80003e7c:	7406                	ld	s0,96(sp)
    80003e7e:	64e6                	ld	s1,88(sp)
    80003e80:	6946                	ld	s2,80(sp)
    80003e82:	69a6                	ld	s3,72(sp)
    80003e84:	6a06                	ld	s4,64(sp)
    80003e86:	7ae2                	ld	s5,56(sp)
    80003e88:	7b42                	ld	s6,48(sp)
    80003e8a:	7ba2                	ld	s7,40(sp)
    80003e8c:	7c02                	ld	s8,32(sp)
    80003e8e:	6ce2                	ld	s9,24(sp)
    80003e90:	6d42                	ld	s10,16(sp)
    80003e92:	6da2                	ld	s11,8(sp)
    80003e94:	6165                	addi	sp,sp,112
    80003e96:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003e98:	89da                	mv	s3,s6
    80003e9a:	bfc9                	j	80003e6c <writei+0xe2>
    return -1;
    80003e9c:	557d                	li	a0,-1
}
    80003e9e:	8082                	ret
    return -1;
    80003ea0:	557d                	li	a0,-1
    80003ea2:	bfe1                	j	80003e7a <writei+0xf0>
    return -1;
    80003ea4:	557d                	li	a0,-1
    80003ea6:	bfd1                	j	80003e7a <writei+0xf0>

0000000080003ea8 <namecmp>:

// Directories

int namecmp(const char *s, const char *t)
{
    80003ea8:	1141                	addi	sp,sp,-16
    80003eaa:	e406                	sd	ra,8(sp)
    80003eac:	e022                	sd	s0,0(sp)
    80003eae:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003eb0:	4639                	li	a2,14
    80003eb2:	ffffd097          	auipc	ra,0xffffd
    80003eb6:	ef0080e7          	jalr	-272(ra) # 80000da2 <strncmp>
}
    80003eba:	60a2                	ld	ra,8(sp)
    80003ebc:	6402                	ld	s0,0(sp)
    80003ebe:	0141                	addi	sp,sp,16
    80003ec0:	8082                	ret

0000000080003ec2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ec2:	7139                	addi	sp,sp,-64
    80003ec4:	fc06                	sd	ra,56(sp)
    80003ec6:	f822                	sd	s0,48(sp)
    80003ec8:	f426                	sd	s1,40(sp)
    80003eca:	f04a                	sd	s2,32(sp)
    80003ecc:	ec4e                	sd	s3,24(sp)
    80003ece:	e852                	sd	s4,16(sp)
    80003ed0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003ed2:	04451703          	lh	a4,68(a0)
    80003ed6:	4785                	li	a5,1
    80003ed8:	00f71a63          	bne	a4,a5,80003eec <dirlookup+0x2a>
    80003edc:	892a                	mv	s2,a0
    80003ede:	89ae                	mv	s3,a1
    80003ee0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de))
    80003ee2:	457c                	lw	a5,76(a0)
    80003ee4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ee6:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de))
    80003ee8:	e79d                	bnez	a5,80003f16 <dirlookup+0x54>
    80003eea:	a8a5                	j	80003f62 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003eec:	00004517          	auipc	a0,0x4
    80003ef0:	72450513          	addi	a0,a0,1828 # 80008610 <syscalls+0x1b8>
    80003ef4:	ffffc097          	auipc	ra,0xffffc
    80003ef8:	64c080e7          	jalr	1612(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003efc:	00004517          	auipc	a0,0x4
    80003f00:	72c50513          	addi	a0,a0,1836 # 80008628 <syscalls+0x1d0>
    80003f04:	ffffc097          	auipc	ra,0xffffc
    80003f08:	63c080e7          	jalr	1596(ra) # 80000540 <panic>
  for (off = 0; off < dp->size; off += sizeof(de))
    80003f0c:	24c1                	addiw	s1,s1,16
    80003f0e:	04c92783          	lw	a5,76(s2)
    80003f12:	04f4f763          	bgeu	s1,a5,80003f60 <dirlookup+0x9e>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f16:	4741                	li	a4,16
    80003f18:	86a6                	mv	a3,s1
    80003f1a:	fc040613          	addi	a2,s0,-64
    80003f1e:	4581                	li	a1,0
    80003f20:	854a                	mv	a0,s2
    80003f22:	00000097          	auipc	ra,0x0
    80003f26:	d70080e7          	jalr	-656(ra) # 80003c92 <readi>
    80003f2a:	47c1                	li	a5,16
    80003f2c:	fcf518e3          	bne	a0,a5,80003efc <dirlookup+0x3a>
    if (de.inum == 0)
    80003f30:	fc045783          	lhu	a5,-64(s0)
    80003f34:	dfe1                	beqz	a5,80003f0c <dirlookup+0x4a>
    if (namecmp(name, de.name) == 0)
    80003f36:	fc240593          	addi	a1,s0,-62
    80003f3a:	854e                	mv	a0,s3
    80003f3c:	00000097          	auipc	ra,0x0
    80003f40:	f6c080e7          	jalr	-148(ra) # 80003ea8 <namecmp>
    80003f44:	f561                	bnez	a0,80003f0c <dirlookup+0x4a>
      if (poff)
    80003f46:	000a0463          	beqz	s4,80003f4e <dirlookup+0x8c>
        *poff = off;
    80003f4a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f4e:	fc045583          	lhu	a1,-64(s0)
    80003f52:	00092503          	lw	a0,0(s2)
    80003f56:	fffff097          	auipc	ra,0xfffff
    80003f5a:	74e080e7          	jalr	1870(ra) # 800036a4 <iget>
    80003f5e:	a011                	j	80003f62 <dirlookup+0xa0>
  return 0;
    80003f60:	4501                	li	a0,0
}
    80003f62:	70e2                	ld	ra,56(sp)
    80003f64:	7442                	ld	s0,48(sp)
    80003f66:	74a2                	ld	s1,40(sp)
    80003f68:	7902                	ld	s2,32(sp)
    80003f6a:	69e2                	ld	s3,24(sp)
    80003f6c:	6a42                	ld	s4,16(sp)
    80003f6e:	6121                	addi	sp,sp,64
    80003f70:	8082                	ret

0000000080003f72 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003f72:	711d                	addi	sp,sp,-96
    80003f74:	ec86                	sd	ra,88(sp)
    80003f76:	e8a2                	sd	s0,80(sp)
    80003f78:	e4a6                	sd	s1,72(sp)
    80003f7a:	e0ca                	sd	s2,64(sp)
    80003f7c:	fc4e                	sd	s3,56(sp)
    80003f7e:	f852                	sd	s4,48(sp)
    80003f80:	f456                	sd	s5,40(sp)
    80003f82:	f05a                	sd	s6,32(sp)
    80003f84:	ec5e                	sd	s7,24(sp)
    80003f86:	e862                	sd	s8,16(sp)
    80003f88:	e466                	sd	s9,8(sp)
    80003f8a:	e06a                	sd	s10,0(sp)
    80003f8c:	1080                	addi	s0,sp,96
    80003f8e:	84aa                	mv	s1,a0
    80003f90:	8b2e                	mv	s6,a1
    80003f92:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003f94:	00054703          	lbu	a4,0(a0)
    80003f98:	02f00793          	li	a5,47
    80003f9c:	02f70363          	beq	a4,a5,80003fc2 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003fa0:	ffffe097          	auipc	ra,0xffffe
    80003fa4:	a0c080e7          	jalr	-1524(ra) # 800019ac <myproc>
    80003fa8:	15053503          	ld	a0,336(a0)
    80003fac:	00000097          	auipc	ra,0x0
    80003fb0:	9f4080e7          	jalr	-1548(ra) # 800039a0 <idup>
    80003fb4:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003fb6:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80003fba:	4cb5                	li	s9,13
  len = path - s;
    80003fbc:	4b81                	li	s7,0

  while ((path = skipelem(path, name)) != 0)
  {
    ilock(ip);
    if (ip->type != T_DIR)
    80003fbe:	4c05                	li	s8,1
    80003fc0:	a87d                	j	8000407e <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003fc2:	4585                	li	a1,1
    80003fc4:	4505                	li	a0,1
    80003fc6:	fffff097          	auipc	ra,0xfffff
    80003fca:	6de080e7          	jalr	1758(ra) # 800036a4 <iget>
    80003fce:	8a2a                	mv	s4,a0
    80003fd0:	b7dd                	j	80003fb6 <namex+0x44>
    {
      iunlockput(ip);
    80003fd2:	8552                	mv	a0,s4
    80003fd4:	00000097          	auipc	ra,0x0
    80003fd8:	c6c080e7          	jalr	-916(ra) # 80003c40 <iunlockput>
      return 0;
    80003fdc:	4a01                	li	s4,0
  {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fde:	8552                	mv	a0,s4
    80003fe0:	60e6                	ld	ra,88(sp)
    80003fe2:	6446                	ld	s0,80(sp)
    80003fe4:	64a6                	ld	s1,72(sp)
    80003fe6:	6906                	ld	s2,64(sp)
    80003fe8:	79e2                	ld	s3,56(sp)
    80003fea:	7a42                	ld	s4,48(sp)
    80003fec:	7aa2                	ld	s5,40(sp)
    80003fee:	7b02                	ld	s6,32(sp)
    80003ff0:	6be2                	ld	s7,24(sp)
    80003ff2:	6c42                	ld	s8,16(sp)
    80003ff4:	6ca2                	ld	s9,8(sp)
    80003ff6:	6d02                	ld	s10,0(sp)
    80003ff8:	6125                	addi	sp,sp,96
    80003ffa:	8082                	ret
      iunlock(ip);
    80003ffc:	8552                	mv	a0,s4
    80003ffe:	00000097          	auipc	ra,0x0
    80004002:	aa2080e7          	jalr	-1374(ra) # 80003aa0 <iunlock>
      return ip;
    80004006:	bfe1                	j	80003fde <namex+0x6c>
      iunlockput(ip);
    80004008:	8552                	mv	a0,s4
    8000400a:	00000097          	auipc	ra,0x0
    8000400e:	c36080e7          	jalr	-970(ra) # 80003c40 <iunlockput>
      return 0;
    80004012:	8a4e                	mv	s4,s3
    80004014:	b7e9                	j	80003fde <namex+0x6c>
  len = path - s;
    80004016:	40998633          	sub	a2,s3,s1
    8000401a:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    8000401e:	09acd863          	bge	s9,s10,800040ae <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004022:	4639                	li	a2,14
    80004024:	85a6                	mv	a1,s1
    80004026:	8556                	mv	a0,s5
    80004028:	ffffd097          	auipc	ra,0xffffd
    8000402c:	d06080e7          	jalr	-762(ra) # 80000d2e <memmove>
    80004030:	84ce                	mv	s1,s3
  while (*path == '/')
    80004032:	0004c783          	lbu	a5,0(s1)
    80004036:	01279763          	bne	a5,s2,80004044 <namex+0xd2>
    path++;
    8000403a:	0485                	addi	s1,s1,1
  while (*path == '/')
    8000403c:	0004c783          	lbu	a5,0(s1)
    80004040:	ff278de3          	beq	a5,s2,8000403a <namex+0xc8>
    ilock(ip);
    80004044:	8552                	mv	a0,s4
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	998080e7          	jalr	-1640(ra) # 800039de <ilock>
    if (ip->type != T_DIR)
    8000404e:	044a1783          	lh	a5,68(s4)
    80004052:	f98790e3          	bne	a5,s8,80003fd2 <namex+0x60>
    if (nameiparent && *path == '\0')
    80004056:	000b0563          	beqz	s6,80004060 <namex+0xee>
    8000405a:	0004c783          	lbu	a5,0(s1)
    8000405e:	dfd9                	beqz	a5,80003ffc <namex+0x8a>
    if ((next = dirlookup(ip, name, 0)) == 0)
    80004060:	865e                	mv	a2,s7
    80004062:	85d6                	mv	a1,s5
    80004064:	8552                	mv	a0,s4
    80004066:	00000097          	auipc	ra,0x0
    8000406a:	e5c080e7          	jalr	-420(ra) # 80003ec2 <dirlookup>
    8000406e:	89aa                	mv	s3,a0
    80004070:	dd41                	beqz	a0,80004008 <namex+0x96>
    iunlockput(ip);
    80004072:	8552                	mv	a0,s4
    80004074:	00000097          	auipc	ra,0x0
    80004078:	bcc080e7          	jalr	-1076(ra) # 80003c40 <iunlockput>
    ip = next;
    8000407c:	8a4e                	mv	s4,s3
  while (*path == '/')
    8000407e:	0004c783          	lbu	a5,0(s1)
    80004082:	01279763          	bne	a5,s2,80004090 <namex+0x11e>
    path++;
    80004086:	0485                	addi	s1,s1,1
  while (*path == '/')
    80004088:	0004c783          	lbu	a5,0(s1)
    8000408c:	ff278de3          	beq	a5,s2,80004086 <namex+0x114>
  if (*path == 0)
    80004090:	cb9d                	beqz	a5,800040c6 <namex+0x154>
  while (*path != '/' && *path != 0)
    80004092:	0004c783          	lbu	a5,0(s1)
    80004096:	89a6                	mv	s3,s1
  len = path - s;
    80004098:	8d5e                	mv	s10,s7
    8000409a:	865e                	mv	a2,s7
  while (*path != '/' && *path != 0)
    8000409c:	01278963          	beq	a5,s2,800040ae <namex+0x13c>
    800040a0:	dbbd                	beqz	a5,80004016 <namex+0xa4>
    path++;
    800040a2:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    800040a4:	0009c783          	lbu	a5,0(s3)
    800040a8:	ff279ce3          	bne	a5,s2,800040a0 <namex+0x12e>
    800040ac:	b7ad                	j	80004016 <namex+0xa4>
    memmove(name, s, len);
    800040ae:	2601                	sext.w	a2,a2
    800040b0:	85a6                	mv	a1,s1
    800040b2:	8556                	mv	a0,s5
    800040b4:	ffffd097          	auipc	ra,0xffffd
    800040b8:	c7a080e7          	jalr	-902(ra) # 80000d2e <memmove>
    name[len] = 0;
    800040bc:	9d56                	add	s10,s10,s5
    800040be:	000d0023          	sb	zero,0(s10)
    800040c2:	84ce                	mv	s1,s3
    800040c4:	b7bd                	j	80004032 <namex+0xc0>
  if (nameiparent)
    800040c6:	f00b0ce3          	beqz	s6,80003fde <namex+0x6c>
    iput(ip);
    800040ca:	8552                	mv	a0,s4
    800040cc:	00000097          	auipc	ra,0x0
    800040d0:	acc080e7          	jalr	-1332(ra) # 80003b98 <iput>
    return 0;
    800040d4:	4a01                	li	s4,0
    800040d6:	b721                	j	80003fde <namex+0x6c>

00000000800040d8 <dirlink>:
{
    800040d8:	7139                	addi	sp,sp,-64
    800040da:	fc06                	sd	ra,56(sp)
    800040dc:	f822                	sd	s0,48(sp)
    800040de:	f426                	sd	s1,40(sp)
    800040e0:	f04a                	sd	s2,32(sp)
    800040e2:	ec4e                	sd	s3,24(sp)
    800040e4:	e852                	sd	s4,16(sp)
    800040e6:	0080                	addi	s0,sp,64
    800040e8:	892a                	mv	s2,a0
    800040ea:	8a2e                	mv	s4,a1
    800040ec:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0)
    800040ee:	4601                	li	a2,0
    800040f0:	00000097          	auipc	ra,0x0
    800040f4:	dd2080e7          	jalr	-558(ra) # 80003ec2 <dirlookup>
    800040f8:	e93d                	bnez	a0,8000416e <dirlink+0x96>
  for (off = 0; off < dp->size; off += sizeof(de))
    800040fa:	04c92483          	lw	s1,76(s2)
    800040fe:	c49d                	beqz	s1,8000412c <dirlink+0x54>
    80004100:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004102:	4741                	li	a4,16
    80004104:	86a6                	mv	a3,s1
    80004106:	fc040613          	addi	a2,s0,-64
    8000410a:	4581                	li	a1,0
    8000410c:	854a                	mv	a0,s2
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	b84080e7          	jalr	-1148(ra) # 80003c92 <readi>
    80004116:	47c1                	li	a5,16
    80004118:	06f51163          	bne	a0,a5,8000417a <dirlink+0xa2>
    if (de.inum == 0)
    8000411c:	fc045783          	lhu	a5,-64(s0)
    80004120:	c791                	beqz	a5,8000412c <dirlink+0x54>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004122:	24c1                	addiw	s1,s1,16
    80004124:	04c92783          	lw	a5,76(s2)
    80004128:	fcf4ede3          	bltu	s1,a5,80004102 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000412c:	4639                	li	a2,14
    8000412e:	85d2                	mv	a1,s4
    80004130:	fc240513          	addi	a0,s0,-62
    80004134:	ffffd097          	auipc	ra,0xffffd
    80004138:	caa080e7          	jalr	-854(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000413c:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004140:	4741                	li	a4,16
    80004142:	86a6                	mv	a3,s1
    80004144:	fc040613          	addi	a2,s0,-64
    80004148:	4581                	li	a1,0
    8000414a:	854a                	mv	a0,s2
    8000414c:	00000097          	auipc	ra,0x0
    80004150:	c3e080e7          	jalr	-962(ra) # 80003d8a <writei>
    80004154:	1541                	addi	a0,a0,-16
    80004156:	00a03533          	snez	a0,a0
    8000415a:	40a00533          	neg	a0,a0
}
    8000415e:	70e2                	ld	ra,56(sp)
    80004160:	7442                	ld	s0,48(sp)
    80004162:	74a2                	ld	s1,40(sp)
    80004164:	7902                	ld	s2,32(sp)
    80004166:	69e2                	ld	s3,24(sp)
    80004168:	6a42                	ld	s4,16(sp)
    8000416a:	6121                	addi	sp,sp,64
    8000416c:	8082                	ret
    iput(ip);
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	a2a080e7          	jalr	-1494(ra) # 80003b98 <iput>
    return -1;
    80004176:	557d                	li	a0,-1
    80004178:	b7dd                	j	8000415e <dirlink+0x86>
      panic("dirlink read");
    8000417a:	00004517          	auipc	a0,0x4
    8000417e:	4be50513          	addi	a0,a0,1214 # 80008638 <syscalls+0x1e0>
    80004182:	ffffc097          	auipc	ra,0xffffc
    80004186:	3be080e7          	jalr	958(ra) # 80000540 <panic>

000000008000418a <namei>:

struct inode *
namei(char *path)
{
    8000418a:	1101                	addi	sp,sp,-32
    8000418c:	ec06                	sd	ra,24(sp)
    8000418e:	e822                	sd	s0,16(sp)
    80004190:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004192:	fe040613          	addi	a2,s0,-32
    80004196:	4581                	li	a1,0
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	dda080e7          	jalr	-550(ra) # 80003f72 <namex>
}
    800041a0:	60e2                	ld	ra,24(sp)
    800041a2:	6442                	ld	s0,16(sp)
    800041a4:	6105                	addi	sp,sp,32
    800041a6:	8082                	ret

00000000800041a8 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    800041a8:	1141                	addi	sp,sp,-16
    800041aa:	e406                	sd	ra,8(sp)
    800041ac:	e022                	sd	s0,0(sp)
    800041ae:	0800                	addi	s0,sp,16
    800041b0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041b2:	4585                	li	a1,1
    800041b4:	00000097          	auipc	ra,0x0
    800041b8:	dbe080e7          	jalr	-578(ra) # 80003f72 <namex>
}
    800041bc:	60a2                	ld	ra,8(sp)
    800041be:	6402                	ld	s0,0(sp)
    800041c0:	0141                	addi	sp,sp,16
    800041c2:	8082                	ret

00000000800041c4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041c4:	1101                	addi	sp,sp,-32
    800041c6:	ec06                	sd	ra,24(sp)
    800041c8:	e822                	sd	s0,16(sp)
    800041ca:	e426                	sd	s1,8(sp)
    800041cc:	e04a                	sd	s2,0(sp)
    800041ce:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041d0:	0001f917          	auipc	s2,0x1f
    800041d4:	9b890913          	addi	s2,s2,-1608 # 80022b88 <log>
    800041d8:	01892583          	lw	a1,24(s2)
    800041dc:	02892503          	lw	a0,40(s2)
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	fe6080e7          	jalr	-26(ra) # 800031c6 <bread>
    800041e8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    800041ea:	02c92683          	lw	a3,44(s2)
    800041ee:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++)
    800041f0:	02d05863          	blez	a3,80004220 <write_head+0x5c>
    800041f4:	0001f797          	auipc	a5,0x1f
    800041f8:	9c478793          	addi	a5,a5,-1596 # 80022bb8 <log+0x30>
    800041fc:	05c50713          	addi	a4,a0,92
    80004200:	36fd                	addiw	a3,a3,-1
    80004202:	02069613          	slli	a2,a3,0x20
    80004206:	01e65693          	srli	a3,a2,0x1e
    8000420a:	0001f617          	auipc	a2,0x1f
    8000420e:	9b260613          	addi	a2,a2,-1614 # 80022bbc <log+0x34>
    80004212:	96b2                	add	a3,a3,a2
  {
    hb->block[i] = log.lh.block[i];
    80004214:	4390                	lw	a2,0(a5)
    80004216:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    80004218:	0791                	addi	a5,a5,4
    8000421a:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000421c:	fed79ce3          	bne	a5,a3,80004214 <write_head+0x50>
  }
  bwrite(buf);
    80004220:	8526                	mv	a0,s1
    80004222:	fffff097          	auipc	ra,0xfffff
    80004226:	096080e7          	jalr	150(ra) # 800032b8 <bwrite>
  brelse(buf);
    8000422a:	8526                	mv	a0,s1
    8000422c:	fffff097          	auipc	ra,0xfffff
    80004230:	0ca080e7          	jalr	202(ra) # 800032f6 <brelse>
}
    80004234:	60e2                	ld	ra,24(sp)
    80004236:	6442                	ld	s0,16(sp)
    80004238:	64a2                	ld	s1,8(sp)
    8000423a:	6902                	ld	s2,0(sp)
    8000423c:	6105                	addi	sp,sp,32
    8000423e:	8082                	ret

0000000080004240 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++)
    80004240:	0001f797          	auipc	a5,0x1f
    80004244:	9747a783          	lw	a5,-1676(a5) # 80022bb4 <log+0x2c>
    80004248:	0af05d63          	blez	a5,80004302 <install_trans+0xc2>
{
    8000424c:	7139                	addi	sp,sp,-64
    8000424e:	fc06                	sd	ra,56(sp)
    80004250:	f822                	sd	s0,48(sp)
    80004252:	f426                	sd	s1,40(sp)
    80004254:	f04a                	sd	s2,32(sp)
    80004256:	ec4e                	sd	s3,24(sp)
    80004258:	e852                	sd	s4,16(sp)
    8000425a:	e456                	sd	s5,8(sp)
    8000425c:	e05a                	sd	s6,0(sp)
    8000425e:	0080                	addi	s0,sp,64
    80004260:	8b2a                	mv	s6,a0
    80004262:	0001fa97          	auipc	s5,0x1f
    80004266:	956a8a93          	addi	s5,s5,-1706 # 80022bb8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++)
    8000426a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    8000426c:	0001f997          	auipc	s3,0x1f
    80004270:	91c98993          	addi	s3,s3,-1764 # 80022b88 <log>
    80004274:	a00d                	j	80004296 <install_trans+0x56>
    brelse(lbuf);
    80004276:	854a                	mv	a0,s2
    80004278:	fffff097          	auipc	ra,0xfffff
    8000427c:	07e080e7          	jalr	126(ra) # 800032f6 <brelse>
    brelse(dbuf);
    80004280:	8526                	mv	a0,s1
    80004282:	fffff097          	auipc	ra,0xfffff
    80004286:	074080e7          	jalr	116(ra) # 800032f6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    8000428a:	2a05                	addiw	s4,s4,1
    8000428c:	0a91                	addi	s5,s5,4
    8000428e:	02c9a783          	lw	a5,44(s3)
    80004292:	04fa5e63          	bge	s4,a5,800042ee <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80004296:	0189a583          	lw	a1,24(s3)
    8000429a:	014585bb          	addw	a1,a1,s4
    8000429e:	2585                	addiw	a1,a1,1
    800042a0:	0289a503          	lw	a0,40(s3)
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	f22080e7          	jalr	-222(ra) # 800031c6 <bread>
    800042ac:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    800042ae:	000aa583          	lw	a1,0(s5)
    800042b2:	0289a503          	lw	a0,40(s3)
    800042b6:	fffff097          	auipc	ra,0xfffff
    800042ba:	f10080e7          	jalr	-240(ra) # 800031c6 <bread>
    800042be:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);                  // copy block to dst
    800042c0:	40000613          	li	a2,1024
    800042c4:	05890593          	addi	a1,s2,88
    800042c8:	05850513          	addi	a0,a0,88
    800042cc:	ffffd097          	auipc	ra,0xffffd
    800042d0:	a62080e7          	jalr	-1438(ra) # 80000d2e <memmove>
    bwrite(dbuf);                                            // write dst to disk
    800042d4:	8526                	mv	a0,s1
    800042d6:	fffff097          	auipc	ra,0xfffff
    800042da:	fe2080e7          	jalr	-30(ra) # 800032b8 <bwrite>
    if (recovering == 0)
    800042de:	f80b1ce3          	bnez	s6,80004276 <install_trans+0x36>
      bunpin(dbuf);
    800042e2:	8526                	mv	a0,s1
    800042e4:	fffff097          	auipc	ra,0xfffff
    800042e8:	0ec080e7          	jalr	236(ra) # 800033d0 <bunpin>
    800042ec:	b769                	j	80004276 <install_trans+0x36>
}
    800042ee:	70e2                	ld	ra,56(sp)
    800042f0:	7442                	ld	s0,48(sp)
    800042f2:	74a2                	ld	s1,40(sp)
    800042f4:	7902                	ld	s2,32(sp)
    800042f6:	69e2                	ld	s3,24(sp)
    800042f8:	6a42                	ld	s4,16(sp)
    800042fa:	6aa2                	ld	s5,8(sp)
    800042fc:	6b02                	ld	s6,0(sp)
    800042fe:	6121                	addi	sp,sp,64
    80004300:	8082                	ret
    80004302:	8082                	ret

0000000080004304 <initlog>:
{
    80004304:	7179                	addi	sp,sp,-48
    80004306:	f406                	sd	ra,40(sp)
    80004308:	f022                	sd	s0,32(sp)
    8000430a:	ec26                	sd	s1,24(sp)
    8000430c:	e84a                	sd	s2,16(sp)
    8000430e:	e44e                	sd	s3,8(sp)
    80004310:	1800                	addi	s0,sp,48
    80004312:	892a                	mv	s2,a0
    80004314:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004316:	0001f497          	auipc	s1,0x1f
    8000431a:	87248493          	addi	s1,s1,-1934 # 80022b88 <log>
    8000431e:	00004597          	auipc	a1,0x4
    80004322:	32a58593          	addi	a1,a1,810 # 80008648 <syscalls+0x1f0>
    80004326:	8526                	mv	a0,s1
    80004328:	ffffd097          	auipc	ra,0xffffd
    8000432c:	81e080e7          	jalr	-2018(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004330:	0149a583          	lw	a1,20(s3)
    80004334:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004336:	0109a783          	lw	a5,16(s3)
    8000433a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000433c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004340:	854a                	mv	a0,s2
    80004342:	fffff097          	auipc	ra,0xfffff
    80004346:	e84080e7          	jalr	-380(ra) # 800031c6 <bread>
  log.lh.n = lh->n;
    8000434a:	4d34                	lw	a3,88(a0)
    8000434c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++)
    8000434e:	02d05663          	blez	a3,8000437a <initlog+0x76>
    80004352:	05c50793          	addi	a5,a0,92
    80004356:	0001f717          	auipc	a4,0x1f
    8000435a:	86270713          	addi	a4,a4,-1950 # 80022bb8 <log+0x30>
    8000435e:	36fd                	addiw	a3,a3,-1
    80004360:	02069613          	slli	a2,a3,0x20
    80004364:	01e65693          	srli	a3,a2,0x1e
    80004368:	06050613          	addi	a2,a0,96
    8000436c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000436e:	4390                	lw	a2,0(a5)
    80004370:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    80004372:	0791                	addi	a5,a5,4
    80004374:	0711                	addi	a4,a4,4
    80004376:	fed79ce3          	bne	a5,a3,8000436e <initlog+0x6a>
  brelse(buf);
    8000437a:	fffff097          	auipc	ra,0xfffff
    8000437e:	f7c080e7          	jalr	-132(ra) # 800032f6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004382:	4505                	li	a0,1
    80004384:	00000097          	auipc	ra,0x0
    80004388:	ebc080e7          	jalr	-324(ra) # 80004240 <install_trans>
  log.lh.n = 0;
    8000438c:	0001f797          	auipc	a5,0x1f
    80004390:	8207a423          	sw	zero,-2008(a5) # 80022bb4 <log+0x2c>
  write_head(); // clear the log
    80004394:	00000097          	auipc	ra,0x0
    80004398:	e30080e7          	jalr	-464(ra) # 800041c4 <write_head>
}
    8000439c:	70a2                	ld	ra,40(sp)
    8000439e:	7402                	ld	s0,32(sp)
    800043a0:	64e2                	ld	s1,24(sp)
    800043a2:	6942                	ld	s2,16(sp)
    800043a4:	69a2                	ld	s3,8(sp)
    800043a6:	6145                	addi	sp,sp,48
    800043a8:	8082                	ret

00000000800043aa <begin_op>:
}

// called at the start of each FS system call.
void begin_op(void)
{
    800043aa:	1101                	addi	sp,sp,-32
    800043ac:	ec06                	sd	ra,24(sp)
    800043ae:	e822                	sd	s0,16(sp)
    800043b0:	e426                	sd	s1,8(sp)
    800043b2:	e04a                	sd	s2,0(sp)
    800043b4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043b6:	0001e517          	auipc	a0,0x1e
    800043ba:	7d250513          	addi	a0,a0,2002 # 80022b88 <log>
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	818080e7          	jalr	-2024(ra) # 80000bd6 <acquire>
  while (1)
  {
    if (log.committing)
    800043c6:	0001e497          	auipc	s1,0x1e
    800043ca:	7c248493          	addi	s1,s1,1986 # 80022b88 <log>
    {
      sleep(&log, &log.lock);
    }
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    800043ce:	4979                	li	s2,30
    800043d0:	a039                	j	800043de <begin_op+0x34>
      sleep(&log, &log.lock);
    800043d2:	85a6                	mv	a1,s1
    800043d4:	8526                	mv	a0,s1
    800043d6:	ffffe097          	auipc	ra,0xffffe
    800043da:	d04080e7          	jalr	-764(ra) # 800020da <sleep>
    if (log.committing)
    800043de:	50dc                	lw	a5,36(s1)
    800043e0:	fbed                	bnez	a5,800043d2 <begin_op+0x28>
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    800043e2:	5098                	lw	a4,32(s1)
    800043e4:	2705                	addiw	a4,a4,1
    800043e6:	0007069b          	sext.w	a3,a4
    800043ea:	0027179b          	slliw	a5,a4,0x2
    800043ee:	9fb9                	addw	a5,a5,a4
    800043f0:	0017979b          	slliw	a5,a5,0x1
    800043f4:	54d8                	lw	a4,44(s1)
    800043f6:	9fb9                	addw	a5,a5,a4
    800043f8:	00f95963          	bge	s2,a5,8000440a <begin_op+0x60>
    {
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043fc:	85a6                	mv	a1,s1
    800043fe:	8526                	mv	a0,s1
    80004400:	ffffe097          	auipc	ra,0xffffe
    80004404:	cda080e7          	jalr	-806(ra) # 800020da <sleep>
    80004408:	bfd9                	j	800043de <begin_op+0x34>
    }
    else
    {
      log.outstanding += 1;
    8000440a:	0001e517          	auipc	a0,0x1e
    8000440e:	77e50513          	addi	a0,a0,1918 # 80022b88 <log>
    80004412:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004414:	ffffd097          	auipc	ra,0xffffd
    80004418:	876080e7          	jalr	-1930(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000441c:	60e2                	ld	ra,24(sp)
    8000441e:	6442                	ld	s0,16(sp)
    80004420:	64a2                	ld	s1,8(sp)
    80004422:	6902                	ld	s2,0(sp)
    80004424:	6105                	addi	sp,sp,32
    80004426:	8082                	ret

0000000080004428 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
    80004428:	7139                	addi	sp,sp,-64
    8000442a:	fc06                	sd	ra,56(sp)
    8000442c:	f822                	sd	s0,48(sp)
    8000442e:	f426                	sd	s1,40(sp)
    80004430:	f04a                	sd	s2,32(sp)
    80004432:	ec4e                	sd	s3,24(sp)
    80004434:	e852                	sd	s4,16(sp)
    80004436:	e456                	sd	s5,8(sp)
    80004438:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000443a:	0001e497          	auipc	s1,0x1e
    8000443e:	74e48493          	addi	s1,s1,1870 # 80022b88 <log>
    80004442:	8526                	mv	a0,s1
    80004444:	ffffc097          	auipc	ra,0xffffc
    80004448:	792080e7          	jalr	1938(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000444c:	509c                	lw	a5,32(s1)
    8000444e:	37fd                	addiw	a5,a5,-1
    80004450:	0007891b          	sext.w	s2,a5
    80004454:	d09c                	sw	a5,32(s1)
  if (log.committing)
    80004456:	50dc                	lw	a5,36(s1)
    80004458:	e7b9                	bnez	a5,800044a6 <end_op+0x7e>
    panic("log.committing");
  if (log.outstanding == 0)
    8000445a:	04091e63          	bnez	s2,800044b6 <end_op+0x8e>
  {
    do_commit = 1;
    log.committing = 1;
    8000445e:	0001e497          	auipc	s1,0x1e
    80004462:	72a48493          	addi	s1,s1,1834 # 80022b88 <log>
    80004466:	4785                	li	a5,1
    80004468:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000446a:	8526                	mv	a0,s1
    8000446c:	ffffd097          	auipc	ra,0xffffd
    80004470:	81e080e7          	jalr	-2018(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0)
    80004474:	54dc                	lw	a5,44(s1)
    80004476:	06f04763          	bgtz	a5,800044e4 <end_op+0xbc>
    acquire(&log.lock);
    8000447a:	0001e497          	auipc	s1,0x1e
    8000447e:	70e48493          	addi	s1,s1,1806 # 80022b88 <log>
    80004482:	8526                	mv	a0,s1
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	752080e7          	jalr	1874(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000448c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004490:	8526                	mv	a0,s1
    80004492:	ffffe097          	auipc	ra,0xffffe
    80004496:	cb8080e7          	jalr	-840(ra) # 8000214a <wakeup>
    release(&log.lock);
    8000449a:	8526                	mv	a0,s1
    8000449c:	ffffc097          	auipc	ra,0xffffc
    800044a0:	7ee080e7          	jalr	2030(ra) # 80000c8a <release>
}
    800044a4:	a03d                	j	800044d2 <end_op+0xaa>
    panic("log.committing");
    800044a6:	00004517          	auipc	a0,0x4
    800044aa:	1aa50513          	addi	a0,a0,426 # 80008650 <syscalls+0x1f8>
    800044ae:	ffffc097          	auipc	ra,0xffffc
    800044b2:	092080e7          	jalr	146(ra) # 80000540 <panic>
    wakeup(&log);
    800044b6:	0001e497          	auipc	s1,0x1e
    800044ba:	6d248493          	addi	s1,s1,1746 # 80022b88 <log>
    800044be:	8526                	mv	a0,s1
    800044c0:	ffffe097          	auipc	ra,0xffffe
    800044c4:	c8a080e7          	jalr	-886(ra) # 8000214a <wakeup>
  release(&log.lock);
    800044c8:	8526                	mv	a0,s1
    800044ca:	ffffc097          	auipc	ra,0xffffc
    800044ce:	7c0080e7          	jalr	1984(ra) # 80000c8a <release>
}
    800044d2:	70e2                	ld	ra,56(sp)
    800044d4:	7442                	ld	s0,48(sp)
    800044d6:	74a2                	ld	s1,40(sp)
    800044d8:	7902                	ld	s2,32(sp)
    800044da:	69e2                	ld	s3,24(sp)
    800044dc:	6a42                	ld	s4,16(sp)
    800044de:	6aa2                	ld	s5,8(sp)
    800044e0:	6121                	addi	sp,sp,64
    800044e2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++)
    800044e4:	0001ea97          	auipc	s5,0x1e
    800044e8:	6d4a8a93          	addi	s5,s5,1748 # 80022bb8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    800044ec:	0001ea17          	auipc	s4,0x1e
    800044f0:	69ca0a13          	addi	s4,s4,1692 # 80022b88 <log>
    800044f4:	018a2583          	lw	a1,24(s4)
    800044f8:	012585bb          	addw	a1,a1,s2
    800044fc:	2585                	addiw	a1,a1,1
    800044fe:	028a2503          	lw	a0,40(s4)
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	cc4080e7          	jalr	-828(ra) # 800031c6 <bread>
    8000450a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000450c:	000aa583          	lw	a1,0(s5)
    80004510:	028a2503          	lw	a0,40(s4)
    80004514:	fffff097          	auipc	ra,0xfffff
    80004518:	cb2080e7          	jalr	-846(ra) # 800031c6 <bread>
    8000451c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000451e:	40000613          	li	a2,1024
    80004522:	05850593          	addi	a1,a0,88
    80004526:	05848513          	addi	a0,s1,88
    8000452a:	ffffd097          	auipc	ra,0xffffd
    8000452e:	804080e7          	jalr	-2044(ra) # 80000d2e <memmove>
    bwrite(to); // write the log
    80004532:	8526                	mv	a0,s1
    80004534:	fffff097          	auipc	ra,0xfffff
    80004538:	d84080e7          	jalr	-636(ra) # 800032b8 <bwrite>
    brelse(from);
    8000453c:	854e                	mv	a0,s3
    8000453e:	fffff097          	auipc	ra,0xfffff
    80004542:	db8080e7          	jalr	-584(ra) # 800032f6 <brelse>
    brelse(to);
    80004546:	8526                	mv	a0,s1
    80004548:	fffff097          	auipc	ra,0xfffff
    8000454c:	dae080e7          	jalr	-594(ra) # 800032f6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    80004550:	2905                	addiw	s2,s2,1
    80004552:	0a91                	addi	s5,s5,4
    80004554:	02ca2783          	lw	a5,44(s4)
    80004558:	f8f94ee3          	blt	s2,a5,800044f4 <end_op+0xcc>
  {
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    8000455c:	00000097          	auipc	ra,0x0
    80004560:	c68080e7          	jalr	-920(ra) # 800041c4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004564:	4501                	li	a0,0
    80004566:	00000097          	auipc	ra,0x0
    8000456a:	cda080e7          	jalr	-806(ra) # 80004240 <install_trans>
    log.lh.n = 0;
    8000456e:	0001e797          	auipc	a5,0x1e
    80004572:	6407a323          	sw	zero,1606(a5) # 80022bb4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004576:	00000097          	auipc	ra,0x0
    8000457a:	c4e080e7          	jalr	-946(ra) # 800041c4 <write_head>
    8000457e:	bdf5                	j	8000447a <end_op+0x52>

0000000080004580 <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
    80004580:	1101                	addi	sp,sp,-32
    80004582:	ec06                	sd	ra,24(sp)
    80004584:	e822                	sd	s0,16(sp)
    80004586:	e426                	sd	s1,8(sp)
    80004588:	e04a                	sd	s2,0(sp)
    8000458a:	1000                	addi	s0,sp,32
    8000458c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000458e:	0001e917          	auipc	s2,0x1e
    80004592:	5fa90913          	addi	s2,s2,1530 # 80022b88 <log>
    80004596:	854a                	mv	a0,s2
    80004598:	ffffc097          	auipc	ra,0xffffc
    8000459c:	63e080e7          	jalr	1598(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045a0:	02c92603          	lw	a2,44(s2)
    800045a4:	47f5                	li	a5,29
    800045a6:	06c7c563          	blt	a5,a2,80004610 <log_write+0x90>
    800045aa:	0001e797          	auipc	a5,0x1e
    800045ae:	5fa7a783          	lw	a5,1530(a5) # 80022ba4 <log+0x1c>
    800045b2:	37fd                	addiw	a5,a5,-1
    800045b4:	04f65e63          	bge	a2,a5,80004610 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045b8:	0001e797          	auipc	a5,0x1e
    800045bc:	5f07a783          	lw	a5,1520(a5) # 80022ba8 <log+0x20>
    800045c0:	06f05063          	blez	a5,80004620 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++)
    800045c4:	4781                	li	a5,0
    800045c6:	06c05563          	blez	a2,80004630 <log_write+0xb0>
  {
    if (log.lh.block[i] == b->blockno) // log absorption
    800045ca:	44cc                	lw	a1,12(s1)
    800045cc:	0001e717          	auipc	a4,0x1e
    800045d0:	5ec70713          	addi	a4,a4,1516 # 80022bb8 <log+0x30>
  for (i = 0; i < log.lh.n; i++)
    800045d4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    800045d6:	4314                	lw	a3,0(a4)
    800045d8:	04b68c63          	beq	a3,a1,80004630 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++)
    800045dc:	2785                	addiw	a5,a5,1
    800045de:	0711                	addi	a4,a4,4
    800045e0:	fef61be3          	bne	a2,a5,800045d6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045e4:	0621                	addi	a2,a2,8
    800045e6:	060a                	slli	a2,a2,0x2
    800045e8:	0001e797          	auipc	a5,0x1e
    800045ec:	5a078793          	addi	a5,a5,1440 # 80022b88 <log>
    800045f0:	97b2                	add	a5,a5,a2
    800045f2:	44d8                	lw	a4,12(s1)
    800045f4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n)
  { // Add new block to log?
    bpin(b);
    800045f6:	8526                	mv	a0,s1
    800045f8:	fffff097          	auipc	ra,0xfffff
    800045fc:	d9c080e7          	jalr	-612(ra) # 80003394 <bpin>
    log.lh.n++;
    80004600:	0001e717          	auipc	a4,0x1e
    80004604:	58870713          	addi	a4,a4,1416 # 80022b88 <log>
    80004608:	575c                	lw	a5,44(a4)
    8000460a:	2785                	addiw	a5,a5,1
    8000460c:	d75c                	sw	a5,44(a4)
    8000460e:	a82d                	j	80004648 <log_write+0xc8>
    panic("too big a transaction");
    80004610:	00004517          	auipc	a0,0x4
    80004614:	05050513          	addi	a0,a0,80 # 80008660 <syscalls+0x208>
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	f28080e7          	jalr	-216(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004620:	00004517          	auipc	a0,0x4
    80004624:	05850513          	addi	a0,a0,88 # 80008678 <syscalls+0x220>
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	f18080e7          	jalr	-232(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004630:	00878693          	addi	a3,a5,8
    80004634:	068a                	slli	a3,a3,0x2
    80004636:	0001e717          	auipc	a4,0x1e
    8000463a:	55270713          	addi	a4,a4,1362 # 80022b88 <log>
    8000463e:	9736                	add	a4,a4,a3
    80004640:	44d4                	lw	a3,12(s1)
    80004642:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n)
    80004644:	faf609e3          	beq	a2,a5,800045f6 <log_write+0x76>
  }
  release(&log.lock);
    80004648:	0001e517          	auipc	a0,0x1e
    8000464c:	54050513          	addi	a0,a0,1344 # 80022b88 <log>
    80004650:	ffffc097          	auipc	ra,0xffffc
    80004654:	63a080e7          	jalr	1594(ra) # 80000c8a <release>
}
    80004658:	60e2                	ld	ra,24(sp)
    8000465a:	6442                	ld	s0,16(sp)
    8000465c:	64a2                	ld	s1,8(sp)
    8000465e:	6902                	ld	s2,0(sp)
    80004660:	6105                	addi	sp,sp,32
    80004662:	8082                	ret

0000000080004664 <initsleeplock>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock *lk, char *name)
{
    80004664:	1101                	addi	sp,sp,-32
    80004666:	ec06                	sd	ra,24(sp)
    80004668:	e822                	sd	s0,16(sp)
    8000466a:	e426                	sd	s1,8(sp)
    8000466c:	e04a                	sd	s2,0(sp)
    8000466e:	1000                	addi	s0,sp,32
    80004670:	84aa                	mv	s1,a0
    80004672:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004674:	00004597          	auipc	a1,0x4
    80004678:	02458593          	addi	a1,a1,36 # 80008698 <syscalls+0x240>
    8000467c:	0521                	addi	a0,a0,8
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	4c8080e7          	jalr	1224(ra) # 80000b46 <initlock>
  lk->name = name;
    80004686:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000468a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000468e:	0204a423          	sw	zero,40(s1)
}
    80004692:	60e2                	ld	ra,24(sp)
    80004694:	6442                	ld	s0,16(sp)
    80004696:	64a2                	ld	s1,8(sp)
    80004698:	6902                	ld	s2,0(sp)
    8000469a:	6105                	addi	sp,sp,32
    8000469c:	8082                	ret

000000008000469e <acquiresleep>:

void acquiresleep(struct sleeplock *lk)
{
    8000469e:	1101                	addi	sp,sp,-32
    800046a0:	ec06                	sd	ra,24(sp)
    800046a2:	e822                	sd	s0,16(sp)
    800046a4:	e426                	sd	s1,8(sp)
    800046a6:	e04a                	sd	s2,0(sp)
    800046a8:	1000                	addi	s0,sp,32
    800046aa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046ac:	00850913          	addi	s2,a0,8
    800046b0:	854a                	mv	a0,s2
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	524080e7          	jalr	1316(ra) # 80000bd6 <acquire>
  while (lk->locked)
    800046ba:	409c                	lw	a5,0(s1)
    800046bc:	cb89                	beqz	a5,800046ce <acquiresleep+0x30>
  {
    sleep(lk, &lk->lk);
    800046be:	85ca                	mv	a1,s2
    800046c0:	8526                	mv	a0,s1
    800046c2:	ffffe097          	auipc	ra,0xffffe
    800046c6:	a18080e7          	jalr	-1512(ra) # 800020da <sleep>
  while (lk->locked)
    800046ca:	409c                	lw	a5,0(s1)
    800046cc:	fbed                	bnez	a5,800046be <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046ce:	4785                	li	a5,1
    800046d0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046d2:	ffffd097          	auipc	ra,0xffffd
    800046d6:	2da080e7          	jalr	730(ra) # 800019ac <myproc>
    800046da:	591c                	lw	a5,48(a0)
    800046dc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046de:	854a                	mv	a0,s2
    800046e0:	ffffc097          	auipc	ra,0xffffc
    800046e4:	5aa080e7          	jalr	1450(ra) # 80000c8a <release>
}
    800046e8:	60e2                	ld	ra,24(sp)
    800046ea:	6442                	ld	s0,16(sp)
    800046ec:	64a2                	ld	s1,8(sp)
    800046ee:	6902                	ld	s2,0(sp)
    800046f0:	6105                	addi	sp,sp,32
    800046f2:	8082                	ret

00000000800046f4 <releasesleep>:

void releasesleep(struct sleeplock *lk)
{
    800046f4:	1101                	addi	sp,sp,-32
    800046f6:	ec06                	sd	ra,24(sp)
    800046f8:	e822                	sd	s0,16(sp)
    800046fa:	e426                	sd	s1,8(sp)
    800046fc:	e04a                	sd	s2,0(sp)
    800046fe:	1000                	addi	s0,sp,32
    80004700:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004702:	00850913          	addi	s2,a0,8
    80004706:	854a                	mv	a0,s2
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	4ce080e7          	jalr	1230(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004710:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004714:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004718:	8526                	mv	a0,s1
    8000471a:	ffffe097          	auipc	ra,0xffffe
    8000471e:	a30080e7          	jalr	-1488(ra) # 8000214a <wakeup>
  release(&lk->lk);
    80004722:	854a                	mv	a0,s2
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	566080e7          	jalr	1382(ra) # 80000c8a <release>
}
    8000472c:	60e2                	ld	ra,24(sp)
    8000472e:	6442                	ld	s0,16(sp)
    80004730:	64a2                	ld	s1,8(sp)
    80004732:	6902                	ld	s2,0(sp)
    80004734:	6105                	addi	sp,sp,32
    80004736:	8082                	ret

0000000080004738 <holdingsleep>:

int holdingsleep(struct sleeplock *lk)
{
    80004738:	7179                	addi	sp,sp,-48
    8000473a:	f406                	sd	ra,40(sp)
    8000473c:	f022                	sd	s0,32(sp)
    8000473e:	ec26                	sd	s1,24(sp)
    80004740:	e84a                	sd	s2,16(sp)
    80004742:	e44e                	sd	s3,8(sp)
    80004744:	1800                	addi	s0,sp,48
    80004746:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004748:	00850913          	addi	s2,a0,8
    8000474c:	854a                	mv	a0,s2
    8000474e:	ffffc097          	auipc	ra,0xffffc
    80004752:	488080e7          	jalr	1160(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004756:	409c                	lw	a5,0(s1)
    80004758:	ef99                	bnez	a5,80004776 <holdingsleep+0x3e>
    8000475a:	4481                	li	s1,0
  release(&lk->lk);
    8000475c:	854a                	mv	a0,s2
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
  return r;
}
    80004766:	8526                	mv	a0,s1
    80004768:	70a2                	ld	ra,40(sp)
    8000476a:	7402                	ld	s0,32(sp)
    8000476c:	64e2                	ld	s1,24(sp)
    8000476e:	6942                	ld	s2,16(sp)
    80004770:	69a2                	ld	s3,8(sp)
    80004772:	6145                	addi	sp,sp,48
    80004774:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004776:	0284a983          	lw	s3,40(s1)
    8000477a:	ffffd097          	auipc	ra,0xffffd
    8000477e:	232080e7          	jalr	562(ra) # 800019ac <myproc>
    80004782:	5904                	lw	s1,48(a0)
    80004784:	413484b3          	sub	s1,s1,s3
    80004788:	0014b493          	seqz	s1,s1
    8000478c:	bfc1                	j	8000475c <holdingsleep+0x24>

000000008000478e <fileinit>:
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void fileinit(void)
{
    8000478e:	1141                	addi	sp,sp,-16
    80004790:	e406                	sd	ra,8(sp)
    80004792:	e022                	sd	s0,0(sp)
    80004794:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004796:	00004597          	auipc	a1,0x4
    8000479a:	f1258593          	addi	a1,a1,-238 # 800086a8 <syscalls+0x250>
    8000479e:	0001e517          	auipc	a0,0x1e
    800047a2:	53250513          	addi	a0,a0,1330 # 80022cd0 <ftable>
    800047a6:	ffffc097          	auipc	ra,0xffffc
    800047aa:	3a0080e7          	jalr	928(ra) # 80000b46 <initlock>
}
    800047ae:	60a2                	ld	ra,8(sp)
    800047b0:	6402                	ld	s0,0(sp)
    800047b2:	0141                	addi	sp,sp,16
    800047b4:	8082                	ret

00000000800047b6 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800047b6:	1101                	addi	sp,sp,-32
    800047b8:	ec06                	sd	ra,24(sp)
    800047ba:	e822                	sd	s0,16(sp)
    800047bc:	e426                	sd	s1,8(sp)
    800047be:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047c0:	0001e517          	auipc	a0,0x1e
    800047c4:	51050513          	addi	a0,a0,1296 # 80022cd0 <ftable>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	40e080e7          	jalr	1038(ra) # 80000bd6 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    800047d0:	0001e497          	auipc	s1,0x1e
    800047d4:	51848493          	addi	s1,s1,1304 # 80022ce8 <ftable+0x18>
    800047d8:	0001f717          	auipc	a4,0x1f
    800047dc:	4b070713          	addi	a4,a4,1200 # 80023c88 <mt>
  {
    if (f->ref == 0)
    800047e0:	40dc                	lw	a5,4(s1)
    800047e2:	cf99                	beqz	a5,80004800 <filealloc+0x4a>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    800047e4:	02848493          	addi	s1,s1,40
    800047e8:	fee49ce3          	bne	s1,a4,800047e0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047ec:	0001e517          	auipc	a0,0x1e
    800047f0:	4e450513          	addi	a0,a0,1252 # 80022cd0 <ftable>
    800047f4:	ffffc097          	auipc	ra,0xffffc
    800047f8:	496080e7          	jalr	1174(ra) # 80000c8a <release>
  return 0;
    800047fc:	4481                	li	s1,0
    800047fe:	a819                	j	80004814 <filealloc+0x5e>
      f->ref = 1;
    80004800:	4785                	li	a5,1
    80004802:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004804:	0001e517          	auipc	a0,0x1e
    80004808:	4cc50513          	addi	a0,a0,1228 # 80022cd0 <ftable>
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	47e080e7          	jalr	1150(ra) # 80000c8a <release>
}
    80004814:	8526                	mv	a0,s1
    80004816:	60e2                	ld	ra,24(sp)
    80004818:	6442                	ld	s0,16(sp)
    8000481a:	64a2                	ld	s1,8(sp)
    8000481c:	6105                	addi	sp,sp,32
    8000481e:	8082                	ret

0000000080004820 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004820:	1101                	addi	sp,sp,-32
    80004822:	ec06                	sd	ra,24(sp)
    80004824:	e822                	sd	s0,16(sp)
    80004826:	e426                	sd	s1,8(sp)
    80004828:	1000                	addi	s0,sp,32
    8000482a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000482c:	0001e517          	auipc	a0,0x1e
    80004830:	4a450513          	addi	a0,a0,1188 # 80022cd0 <ftable>
    80004834:	ffffc097          	auipc	ra,0xffffc
    80004838:	3a2080e7          	jalr	930(ra) # 80000bd6 <acquire>
  if (f->ref < 1)
    8000483c:	40dc                	lw	a5,4(s1)
    8000483e:	02f05263          	blez	a5,80004862 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004842:	2785                	addiw	a5,a5,1
    80004844:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004846:	0001e517          	auipc	a0,0x1e
    8000484a:	48a50513          	addi	a0,a0,1162 # 80022cd0 <ftable>
    8000484e:	ffffc097          	auipc	ra,0xffffc
    80004852:	43c080e7          	jalr	1084(ra) # 80000c8a <release>
  return f;
}
    80004856:	8526                	mv	a0,s1
    80004858:	60e2                	ld	ra,24(sp)
    8000485a:	6442                	ld	s0,16(sp)
    8000485c:	64a2                	ld	s1,8(sp)
    8000485e:	6105                	addi	sp,sp,32
    80004860:	8082                	ret
    panic("filedup");
    80004862:	00004517          	auipc	a0,0x4
    80004866:	e4e50513          	addi	a0,a0,-434 # 800086b0 <syscalls+0x258>
    8000486a:	ffffc097          	auipc	ra,0xffffc
    8000486e:	cd6080e7          	jalr	-810(ra) # 80000540 <panic>

0000000080004872 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    80004872:	7139                	addi	sp,sp,-64
    80004874:	fc06                	sd	ra,56(sp)
    80004876:	f822                	sd	s0,48(sp)
    80004878:	f426                	sd	s1,40(sp)
    8000487a:	f04a                	sd	s2,32(sp)
    8000487c:	ec4e                	sd	s3,24(sp)
    8000487e:	e852                	sd	s4,16(sp)
    80004880:	e456                	sd	s5,8(sp)
    80004882:	0080                	addi	s0,sp,64
    80004884:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004886:	0001e517          	auipc	a0,0x1e
    8000488a:	44a50513          	addi	a0,a0,1098 # 80022cd0 <ftable>
    8000488e:	ffffc097          	auipc	ra,0xffffc
    80004892:	348080e7          	jalr	840(ra) # 80000bd6 <acquire>
  if (f->ref < 1)
    80004896:	40dc                	lw	a5,4(s1)
    80004898:	06f05163          	blez	a5,800048fa <fileclose+0x88>
    panic("fileclose");
  if (--f->ref > 0)
    8000489c:	37fd                	addiw	a5,a5,-1
    8000489e:	0007871b          	sext.w	a4,a5
    800048a2:	c0dc                	sw	a5,4(s1)
    800048a4:	06e04363          	bgtz	a4,8000490a <fileclose+0x98>
  {
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048a8:	0004a903          	lw	s2,0(s1)
    800048ac:	0094ca83          	lbu	s5,9(s1)
    800048b0:	0104ba03          	ld	s4,16(s1)
    800048b4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048b8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048bc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048c0:	0001e517          	auipc	a0,0x1e
    800048c4:	41050513          	addi	a0,a0,1040 # 80022cd0 <ftable>
    800048c8:	ffffc097          	auipc	ra,0xffffc
    800048cc:	3c2080e7          	jalr	962(ra) # 80000c8a <release>

  if (ff.type == FD_PIPE)
    800048d0:	4785                	li	a5,1
    800048d2:	04f90d63          	beq	s2,a5,8000492c <fileclose+0xba>
  {
    pipeclose(ff.pipe, ff.writable);
  }
  else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    800048d6:	3979                	addiw	s2,s2,-2
    800048d8:	4785                	li	a5,1
    800048da:	0527e063          	bltu	a5,s2,8000491a <fileclose+0xa8>
  {
    begin_op();
    800048de:	00000097          	auipc	ra,0x0
    800048e2:	acc080e7          	jalr	-1332(ra) # 800043aa <begin_op>
    iput(ff.ip);
    800048e6:	854e                	mv	a0,s3
    800048e8:	fffff097          	auipc	ra,0xfffff
    800048ec:	2b0080e7          	jalr	688(ra) # 80003b98 <iput>
    end_op();
    800048f0:	00000097          	auipc	ra,0x0
    800048f4:	b38080e7          	jalr	-1224(ra) # 80004428 <end_op>
    800048f8:	a00d                	j	8000491a <fileclose+0xa8>
    panic("fileclose");
    800048fa:	00004517          	auipc	a0,0x4
    800048fe:	dbe50513          	addi	a0,a0,-578 # 800086b8 <syscalls+0x260>
    80004902:	ffffc097          	auipc	ra,0xffffc
    80004906:	c3e080e7          	jalr	-962(ra) # 80000540 <panic>
    release(&ftable.lock);
    8000490a:	0001e517          	auipc	a0,0x1e
    8000490e:	3c650513          	addi	a0,a0,966 # 80022cd0 <ftable>
    80004912:	ffffc097          	auipc	ra,0xffffc
    80004916:	378080e7          	jalr	888(ra) # 80000c8a <release>
  }
}
    8000491a:	70e2                	ld	ra,56(sp)
    8000491c:	7442                	ld	s0,48(sp)
    8000491e:	74a2                	ld	s1,40(sp)
    80004920:	7902                	ld	s2,32(sp)
    80004922:	69e2                	ld	s3,24(sp)
    80004924:	6a42                	ld	s4,16(sp)
    80004926:	6aa2                	ld	s5,8(sp)
    80004928:	6121                	addi	sp,sp,64
    8000492a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000492c:	85d6                	mv	a1,s5
    8000492e:	8552                	mv	a0,s4
    80004930:	00000097          	auipc	ra,0x0
    80004934:	34c080e7          	jalr	844(ra) # 80004c7c <pipeclose>
    80004938:	b7cd                	j	8000491a <fileclose+0xa8>

000000008000493a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    8000493a:	715d                	addi	sp,sp,-80
    8000493c:	e486                	sd	ra,72(sp)
    8000493e:	e0a2                	sd	s0,64(sp)
    80004940:	fc26                	sd	s1,56(sp)
    80004942:	f84a                	sd	s2,48(sp)
    80004944:	f44e                	sd	s3,40(sp)
    80004946:	0880                	addi	s0,sp,80
    80004948:	84aa                	mv	s1,a0
    8000494a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000494c:	ffffd097          	auipc	ra,0xffffd
    80004950:	060080e7          	jalr	96(ra) # 800019ac <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004954:	409c                	lw	a5,0(s1)
    80004956:	37f9                	addiw	a5,a5,-2
    80004958:	4705                	li	a4,1
    8000495a:	04f76763          	bltu	a4,a5,800049a8 <filestat+0x6e>
    8000495e:	892a                	mv	s2,a0
  {
    ilock(f->ip);
    80004960:	6c88                	ld	a0,24(s1)
    80004962:	fffff097          	auipc	ra,0xfffff
    80004966:	07c080e7          	jalr	124(ra) # 800039de <ilock>
    stati(f->ip, &st);
    8000496a:	fb840593          	addi	a1,s0,-72
    8000496e:	6c88                	ld	a0,24(s1)
    80004970:	fffff097          	auipc	ra,0xfffff
    80004974:	2f8080e7          	jalr	760(ra) # 80003c68 <stati>
    iunlock(f->ip);
    80004978:	6c88                	ld	a0,24(s1)
    8000497a:	fffff097          	auipc	ra,0xfffff
    8000497e:	126080e7          	jalr	294(ra) # 80003aa0 <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004982:	46e1                	li	a3,24
    80004984:	fb840613          	addi	a2,s0,-72
    80004988:	85ce                	mv	a1,s3
    8000498a:	05093503          	ld	a0,80(s2)
    8000498e:	ffffd097          	auipc	ra,0xffffd
    80004992:	cde080e7          	jalr	-802(ra) # 8000166c <copyout>
    80004996:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000499a:	60a6                	ld	ra,72(sp)
    8000499c:	6406                	ld	s0,64(sp)
    8000499e:	74e2                	ld	s1,56(sp)
    800049a0:	7942                	ld	s2,48(sp)
    800049a2:	79a2                	ld	s3,40(sp)
    800049a4:	6161                	addi	sp,sp,80
    800049a6:	8082                	ret
  return -1;
    800049a8:	557d                	li	a0,-1
    800049aa:	bfc5                	j	8000499a <filestat+0x60>

00000000800049ac <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    800049ac:	7179                	addi	sp,sp,-48
    800049ae:	f406                	sd	ra,40(sp)
    800049b0:	f022                	sd	s0,32(sp)
    800049b2:	ec26                	sd	s1,24(sp)
    800049b4:	e84a                	sd	s2,16(sp)
    800049b6:	e44e                	sd	s3,8(sp)
    800049b8:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    800049ba:	00854783          	lbu	a5,8(a0)
    800049be:	c3d5                	beqz	a5,80004a62 <fileread+0xb6>
    800049c0:	84aa                	mv	s1,a0
    800049c2:	89ae                	mv	s3,a1
    800049c4:	8932                	mv	s2,a2
    return -1;

  if (f->type == FD_PIPE)
    800049c6:	411c                	lw	a5,0(a0)
    800049c8:	4705                	li	a4,1
    800049ca:	04e78963          	beq	a5,a4,80004a1c <fileread+0x70>
  {
    r = piperead(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    800049ce:	470d                	li	a4,3
    800049d0:	04e78d63          	beq	a5,a4,80004a2a <fileread+0x7e>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  }
  else if (f->type == FD_INODE)
    800049d4:	4709                	li	a4,2
    800049d6:	06e79e63          	bne	a5,a4,80004a52 <fileread+0xa6>
  {
    ilock(f->ip);
    800049da:	6d08                	ld	a0,24(a0)
    800049dc:	fffff097          	auipc	ra,0xfffff
    800049e0:	002080e7          	jalr	2(ra) # 800039de <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049e4:	874a                	mv	a4,s2
    800049e6:	5094                	lw	a3,32(s1)
    800049e8:	864e                	mv	a2,s3
    800049ea:	4585                	li	a1,1
    800049ec:	6c88                	ld	a0,24(s1)
    800049ee:	fffff097          	auipc	ra,0xfffff
    800049f2:	2a4080e7          	jalr	676(ra) # 80003c92 <readi>
    800049f6:	892a                	mv	s2,a0
    800049f8:	00a05563          	blez	a0,80004a02 <fileread+0x56>
      f->off += r;
    800049fc:	509c                	lw	a5,32(s1)
    800049fe:	9fa9                	addw	a5,a5,a0
    80004a00:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a02:	6c88                	ld	a0,24(s1)
    80004a04:	fffff097          	auipc	ra,0xfffff
    80004a08:	09c080e7          	jalr	156(ra) # 80003aa0 <iunlock>
  {
    panic("fileread");
  }

  return r;
}
    80004a0c:	854a                	mv	a0,s2
    80004a0e:	70a2                	ld	ra,40(sp)
    80004a10:	7402                	ld	s0,32(sp)
    80004a12:	64e2                	ld	s1,24(sp)
    80004a14:	6942                	ld	s2,16(sp)
    80004a16:	69a2                	ld	s3,8(sp)
    80004a18:	6145                	addi	sp,sp,48
    80004a1a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a1c:	6908                	ld	a0,16(a0)
    80004a1e:	00000097          	auipc	ra,0x0
    80004a22:	3c6080e7          	jalr	966(ra) # 80004de4 <piperead>
    80004a26:	892a                	mv	s2,a0
    80004a28:	b7d5                	j	80004a0c <fileread+0x60>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a2a:	02451783          	lh	a5,36(a0)
    80004a2e:	03079693          	slli	a3,a5,0x30
    80004a32:	92c1                	srli	a3,a3,0x30
    80004a34:	4725                	li	a4,9
    80004a36:	02d76863          	bltu	a4,a3,80004a66 <fileread+0xba>
    80004a3a:	0792                	slli	a5,a5,0x4
    80004a3c:	0001e717          	auipc	a4,0x1e
    80004a40:	1f470713          	addi	a4,a4,500 # 80022c30 <devsw>
    80004a44:	97ba                	add	a5,a5,a4
    80004a46:	639c                	ld	a5,0(a5)
    80004a48:	c38d                	beqz	a5,80004a6a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a4a:	4505                	li	a0,1
    80004a4c:	9782                	jalr	a5
    80004a4e:	892a                	mv	s2,a0
    80004a50:	bf75                	j	80004a0c <fileread+0x60>
    panic("fileread");
    80004a52:	00004517          	auipc	a0,0x4
    80004a56:	c7650513          	addi	a0,a0,-906 # 800086c8 <syscalls+0x270>
    80004a5a:	ffffc097          	auipc	ra,0xffffc
    80004a5e:	ae6080e7          	jalr	-1306(ra) # 80000540 <panic>
    return -1;
    80004a62:	597d                	li	s2,-1
    80004a64:	b765                	j	80004a0c <fileread+0x60>
      return -1;
    80004a66:	597d                	li	s2,-1
    80004a68:	b755                	j	80004a0c <fileread+0x60>
    80004a6a:	597d                	li	s2,-1
    80004a6c:	b745                	j	80004a0c <fileread+0x60>

0000000080004a6e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    80004a6e:	715d                	addi	sp,sp,-80
    80004a70:	e486                	sd	ra,72(sp)
    80004a72:	e0a2                	sd	s0,64(sp)
    80004a74:	fc26                	sd	s1,56(sp)
    80004a76:	f84a                	sd	s2,48(sp)
    80004a78:	f44e                	sd	s3,40(sp)
    80004a7a:	f052                	sd	s4,32(sp)
    80004a7c:	ec56                	sd	s5,24(sp)
    80004a7e:	e85a                	sd	s6,16(sp)
    80004a80:	e45e                	sd	s7,8(sp)
    80004a82:	e062                	sd	s8,0(sp)
    80004a84:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if (f->writable == 0)
    80004a86:	00954783          	lbu	a5,9(a0)
    80004a8a:	10078663          	beqz	a5,80004b96 <filewrite+0x128>
    80004a8e:	892a                	mv	s2,a0
    80004a90:	8b2e                	mv	s6,a1
    80004a92:	8a32                	mv	s4,a2
    return -1;

  if (f->type == FD_PIPE)
    80004a94:	411c                	lw	a5,0(a0)
    80004a96:	4705                	li	a4,1
    80004a98:	02e78263          	beq	a5,a4,80004abc <filewrite+0x4e>
  {
    ret = pipewrite(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004a9c:	470d                	li	a4,3
    80004a9e:	02e78663          	beq	a5,a4,80004aca <filewrite+0x5c>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004aa2:	4709                	li	a4,2
    80004aa4:	0ee79163          	bne	a5,a4,80004b86 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n)
    80004aa8:	0ac05d63          	blez	a2,80004b62 <filewrite+0xf4>
    int i = 0;
    80004aac:	4981                	li	s3,0
    80004aae:	6b85                	lui	s7,0x1
    80004ab0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ab4:	6c05                	lui	s8,0x1
    80004ab6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004aba:	a861                	j	80004b52 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004abc:	6908                	ld	a0,16(a0)
    80004abe:	00000097          	auipc	ra,0x0
    80004ac2:	22e080e7          	jalr	558(ra) # 80004cec <pipewrite>
    80004ac6:	8a2a                	mv	s4,a0
    80004ac8:	a045                	j	80004b68 <filewrite+0xfa>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004aca:	02451783          	lh	a5,36(a0)
    80004ace:	03079693          	slli	a3,a5,0x30
    80004ad2:	92c1                	srli	a3,a3,0x30
    80004ad4:	4725                	li	a4,9
    80004ad6:	0cd76263          	bltu	a4,a3,80004b9a <filewrite+0x12c>
    80004ada:	0792                	slli	a5,a5,0x4
    80004adc:	0001e717          	auipc	a4,0x1e
    80004ae0:	15470713          	addi	a4,a4,340 # 80022c30 <devsw>
    80004ae4:	97ba                	add	a5,a5,a4
    80004ae6:	679c                	ld	a5,8(a5)
    80004ae8:	cbdd                	beqz	a5,80004b9e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004aea:	4505                	li	a0,1
    80004aec:	9782                	jalr	a5
    80004aee:	8a2a                	mv	s4,a0
    80004af0:	a8a5                	j	80004b68 <filewrite+0xfa>
    80004af2:	00048a9b          	sext.w	s5,s1
    {
      int n1 = n - i;
      if (n1 > max)
        n1 = max;

      begin_op();
    80004af6:	00000097          	auipc	ra,0x0
    80004afa:	8b4080e7          	jalr	-1868(ra) # 800043aa <begin_op>
      ilock(f->ip);
    80004afe:	01893503          	ld	a0,24(s2)
    80004b02:	fffff097          	auipc	ra,0xfffff
    80004b06:	edc080e7          	jalr	-292(ra) # 800039de <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b0a:	8756                	mv	a4,s5
    80004b0c:	02092683          	lw	a3,32(s2)
    80004b10:	01698633          	add	a2,s3,s6
    80004b14:	4585                	li	a1,1
    80004b16:	01893503          	ld	a0,24(s2)
    80004b1a:	fffff097          	auipc	ra,0xfffff
    80004b1e:	270080e7          	jalr	624(ra) # 80003d8a <writei>
    80004b22:	84aa                	mv	s1,a0
    80004b24:	00a05763          	blez	a0,80004b32 <filewrite+0xc4>
        f->off += r;
    80004b28:	02092783          	lw	a5,32(s2)
    80004b2c:	9fa9                	addw	a5,a5,a0
    80004b2e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b32:	01893503          	ld	a0,24(s2)
    80004b36:	fffff097          	auipc	ra,0xfffff
    80004b3a:	f6a080e7          	jalr	-150(ra) # 80003aa0 <iunlock>
      end_op();
    80004b3e:	00000097          	auipc	ra,0x0
    80004b42:	8ea080e7          	jalr	-1814(ra) # 80004428 <end_op>

      if (r != n1)
    80004b46:	009a9f63          	bne	s5,s1,80004b64 <filewrite+0xf6>
      {
        // error from writei
        break;
      }
      i += r;
    80004b4a:	013489bb          	addw	s3,s1,s3
    while (i < n)
    80004b4e:	0149db63          	bge	s3,s4,80004b64 <filewrite+0xf6>
      int n1 = n - i;
    80004b52:	413a04bb          	subw	s1,s4,s3
    80004b56:	0004879b          	sext.w	a5,s1
    80004b5a:	f8fbdce3          	bge	s7,a5,80004af2 <filewrite+0x84>
    80004b5e:	84e2                	mv	s1,s8
    80004b60:	bf49                	j	80004af2 <filewrite+0x84>
    int i = 0;
    80004b62:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b64:	013a1f63          	bne	s4,s3,80004b82 <filewrite+0x114>
  {
    panic("filewrite");
  }

  return ret;
}
    80004b68:	8552                	mv	a0,s4
    80004b6a:	60a6                	ld	ra,72(sp)
    80004b6c:	6406                	ld	s0,64(sp)
    80004b6e:	74e2                	ld	s1,56(sp)
    80004b70:	7942                	ld	s2,48(sp)
    80004b72:	79a2                	ld	s3,40(sp)
    80004b74:	7a02                	ld	s4,32(sp)
    80004b76:	6ae2                	ld	s5,24(sp)
    80004b78:	6b42                	ld	s6,16(sp)
    80004b7a:	6ba2                	ld	s7,8(sp)
    80004b7c:	6c02                	ld	s8,0(sp)
    80004b7e:	6161                	addi	sp,sp,80
    80004b80:	8082                	ret
    ret = (i == n ? n : -1);
    80004b82:	5a7d                	li	s4,-1
    80004b84:	b7d5                	j	80004b68 <filewrite+0xfa>
    panic("filewrite");
    80004b86:	00004517          	auipc	a0,0x4
    80004b8a:	b5250513          	addi	a0,a0,-1198 # 800086d8 <syscalls+0x280>
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	9b2080e7          	jalr	-1614(ra) # 80000540 <panic>
    return -1;
    80004b96:	5a7d                	li	s4,-1
    80004b98:	bfc1                	j	80004b68 <filewrite+0xfa>
      return -1;
    80004b9a:	5a7d                	li	s4,-1
    80004b9c:	b7f1                	j	80004b68 <filewrite+0xfa>
    80004b9e:	5a7d                	li	s4,-1
    80004ba0:	b7e1                	j	80004b68 <filewrite+0xfa>

0000000080004ba2 <pipealloc>:
  int readopen;  // read fd is still open
  int writeopen; // write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
    80004ba2:	7179                	addi	sp,sp,-48
    80004ba4:	f406                	sd	ra,40(sp)
    80004ba6:	f022                	sd	s0,32(sp)
    80004ba8:	ec26                	sd	s1,24(sp)
    80004baa:	e84a                	sd	s2,16(sp)
    80004bac:	e44e                	sd	s3,8(sp)
    80004bae:	e052                	sd	s4,0(sp)
    80004bb0:	1800                	addi	s0,sp,48
    80004bb2:	84aa                	mv	s1,a0
    80004bb4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004bb6:	0005b023          	sd	zero,0(a1)
    80004bba:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004bbe:	00000097          	auipc	ra,0x0
    80004bc2:	bf8080e7          	jalr	-1032(ra) # 800047b6 <filealloc>
    80004bc6:	e088                	sd	a0,0(s1)
    80004bc8:	c551                	beqz	a0,80004c54 <pipealloc+0xb2>
    80004bca:	00000097          	auipc	ra,0x0
    80004bce:	bec080e7          	jalr	-1044(ra) # 800047b6 <filealloc>
    80004bd2:	00aa3023          	sd	a0,0(s4)
    80004bd6:	c92d                	beqz	a0,80004c48 <pipealloc+0xa6>
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	f0e080e7          	jalr	-242(ra) # 80000ae6 <kalloc>
    80004be0:	892a                	mv	s2,a0
    80004be2:	c125                	beqz	a0,80004c42 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004be4:	4985                	li	s3,1
    80004be6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004bea:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004bee:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004bf2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004bf6:	00004597          	auipc	a1,0x4
    80004bfa:	af258593          	addi	a1,a1,-1294 # 800086e8 <syscalls+0x290>
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	f48080e7          	jalr	-184(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004c06:	609c                	ld	a5,0(s1)
    80004c08:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c0c:	609c                	ld	a5,0(s1)
    80004c0e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c12:	609c                	ld	a5,0(s1)
    80004c14:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c18:	609c                	ld	a5,0(s1)
    80004c1a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c1e:	000a3783          	ld	a5,0(s4)
    80004c22:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c26:	000a3783          	ld	a5,0(s4)
    80004c2a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c2e:	000a3783          	ld	a5,0(s4)
    80004c32:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c36:	000a3783          	ld	a5,0(s4)
    80004c3a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c3e:	4501                	li	a0,0
    80004c40:	a025                	j	80004c68 <pipealloc+0xc6>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004c42:	6088                	ld	a0,0(s1)
    80004c44:	e501                	bnez	a0,80004c4c <pipealloc+0xaa>
    80004c46:	a039                	j	80004c54 <pipealloc+0xb2>
    80004c48:	6088                	ld	a0,0(s1)
    80004c4a:	c51d                	beqz	a0,80004c78 <pipealloc+0xd6>
    fileclose(*f0);
    80004c4c:	00000097          	auipc	ra,0x0
    80004c50:	c26080e7          	jalr	-986(ra) # 80004872 <fileclose>
  if (*f1)
    80004c54:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c58:	557d                	li	a0,-1
  if (*f1)
    80004c5a:	c799                	beqz	a5,80004c68 <pipealloc+0xc6>
    fileclose(*f1);
    80004c5c:	853e                	mv	a0,a5
    80004c5e:	00000097          	auipc	ra,0x0
    80004c62:	c14080e7          	jalr	-1004(ra) # 80004872 <fileclose>
  return -1;
    80004c66:	557d                	li	a0,-1
}
    80004c68:	70a2                	ld	ra,40(sp)
    80004c6a:	7402                	ld	s0,32(sp)
    80004c6c:	64e2                	ld	s1,24(sp)
    80004c6e:	6942                	ld	s2,16(sp)
    80004c70:	69a2                	ld	s3,8(sp)
    80004c72:	6a02                	ld	s4,0(sp)
    80004c74:	6145                	addi	sp,sp,48
    80004c76:	8082                	ret
  return -1;
    80004c78:	557d                	li	a0,-1
    80004c7a:	b7fd                	j	80004c68 <pipealloc+0xc6>

0000000080004c7c <pipeclose>:

void pipeclose(struct pipe *pi, int writable)
{
    80004c7c:	1101                	addi	sp,sp,-32
    80004c7e:	ec06                	sd	ra,24(sp)
    80004c80:	e822                	sd	s0,16(sp)
    80004c82:	e426                	sd	s1,8(sp)
    80004c84:	e04a                	sd	s2,0(sp)
    80004c86:	1000                	addi	s0,sp,32
    80004c88:	84aa                	mv	s1,a0
    80004c8a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c8c:	ffffc097          	auipc	ra,0xffffc
    80004c90:	f4a080e7          	jalr	-182(ra) # 80000bd6 <acquire>
  if (writable)
    80004c94:	02090d63          	beqz	s2,80004cce <pipeclose+0x52>
  {
    pi->writeopen = 0;
    80004c98:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c9c:	21848513          	addi	a0,s1,536
    80004ca0:	ffffd097          	auipc	ra,0xffffd
    80004ca4:	4aa080e7          	jalr	1194(ra) # 8000214a <wakeup>
  else
  {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0)
    80004ca8:	2204b783          	ld	a5,544(s1)
    80004cac:	eb95                	bnez	a5,80004ce0 <pipeclose+0x64>
  {
    release(&pi->lock);
    80004cae:	8526                	mv	a0,s1
    80004cb0:	ffffc097          	auipc	ra,0xffffc
    80004cb4:	fda080e7          	jalr	-38(ra) # 80000c8a <release>
    kfree((char *)pi);
    80004cb8:	8526                	mv	a0,s1
    80004cba:	ffffc097          	auipc	ra,0xffffc
    80004cbe:	d2e080e7          	jalr	-722(ra) # 800009e8 <kfree>
  }
  else
    release(&pi->lock);
}
    80004cc2:	60e2                	ld	ra,24(sp)
    80004cc4:	6442                	ld	s0,16(sp)
    80004cc6:	64a2                	ld	s1,8(sp)
    80004cc8:	6902                	ld	s2,0(sp)
    80004cca:	6105                	addi	sp,sp,32
    80004ccc:	8082                	ret
    pi->readopen = 0;
    80004cce:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004cd2:	21c48513          	addi	a0,s1,540
    80004cd6:	ffffd097          	auipc	ra,0xffffd
    80004cda:	474080e7          	jalr	1140(ra) # 8000214a <wakeup>
    80004cde:	b7e9                	j	80004ca8 <pipeclose+0x2c>
    release(&pi->lock);
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	ffffc097          	auipc	ra,0xffffc
    80004ce6:	fa8080e7          	jalr	-88(ra) # 80000c8a <release>
}
    80004cea:	bfe1                	j	80004cc2 <pipeclose+0x46>

0000000080004cec <pipewrite>:

int pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cec:	711d                	addi	sp,sp,-96
    80004cee:	ec86                	sd	ra,88(sp)
    80004cf0:	e8a2                	sd	s0,80(sp)
    80004cf2:	e4a6                	sd	s1,72(sp)
    80004cf4:	e0ca                	sd	s2,64(sp)
    80004cf6:	fc4e                	sd	s3,56(sp)
    80004cf8:	f852                	sd	s4,48(sp)
    80004cfa:	f456                	sd	s5,40(sp)
    80004cfc:	f05a                	sd	s6,32(sp)
    80004cfe:	ec5e                	sd	s7,24(sp)
    80004d00:	e862                	sd	s8,16(sp)
    80004d02:	1080                	addi	s0,sp,96
    80004d04:	84aa                	mv	s1,a0
    80004d06:	8aae                	mv	s5,a1
    80004d08:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d0a:	ffffd097          	auipc	ra,0xffffd
    80004d0e:	ca2080e7          	jalr	-862(ra) # 800019ac <myproc>
    80004d12:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d14:	8526                	mv	a0,s1
    80004d16:	ffffc097          	auipc	ra,0xffffc
    80004d1a:	ec0080e7          	jalr	-320(ra) # 80000bd6 <acquire>
  while (i < n)
    80004d1e:	0b405663          	blez	s4,80004dca <pipewrite+0xde>
  int i = 0;
    80004d22:	4901                	li	s2,0
      sleep(&pi->nwrite, &pi->lock);
    }
    else
    {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d24:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d26:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d2a:	21c48b93          	addi	s7,s1,540
    80004d2e:	a089                	j	80004d70 <pipewrite+0x84>
      release(&pi->lock);
    80004d30:	8526                	mv	a0,s1
    80004d32:	ffffc097          	auipc	ra,0xffffc
    80004d36:	f58080e7          	jalr	-168(ra) # 80000c8a <release>
      return -1;
    80004d3a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d3c:	854a                	mv	a0,s2
    80004d3e:	60e6                	ld	ra,88(sp)
    80004d40:	6446                	ld	s0,80(sp)
    80004d42:	64a6                	ld	s1,72(sp)
    80004d44:	6906                	ld	s2,64(sp)
    80004d46:	79e2                	ld	s3,56(sp)
    80004d48:	7a42                	ld	s4,48(sp)
    80004d4a:	7aa2                	ld	s5,40(sp)
    80004d4c:	7b02                	ld	s6,32(sp)
    80004d4e:	6be2                	ld	s7,24(sp)
    80004d50:	6c42                	ld	s8,16(sp)
    80004d52:	6125                	addi	sp,sp,96
    80004d54:	8082                	ret
      wakeup(&pi->nread);
    80004d56:	8562                	mv	a0,s8
    80004d58:	ffffd097          	auipc	ra,0xffffd
    80004d5c:	3f2080e7          	jalr	1010(ra) # 8000214a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d60:	85a6                	mv	a1,s1
    80004d62:	855e                	mv	a0,s7
    80004d64:	ffffd097          	auipc	ra,0xffffd
    80004d68:	376080e7          	jalr	886(ra) # 800020da <sleep>
  while (i < n)
    80004d6c:	07495063          	bge	s2,s4,80004dcc <pipewrite+0xe0>
    if (pi->readopen == 0 || killed(pr))
    80004d70:	2204a783          	lw	a5,544(s1)
    80004d74:	dfd5                	beqz	a5,80004d30 <pipewrite+0x44>
    80004d76:	854e                	mv	a0,s3
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	642080e7          	jalr	1602(ra) # 800023ba <killed>
    80004d80:	f945                	bnez	a0,80004d30 <pipewrite+0x44>
    if (pi->nwrite == pi->nread + PIPESIZE)
    80004d82:	2184a783          	lw	a5,536(s1)
    80004d86:	21c4a703          	lw	a4,540(s1)
    80004d8a:	2007879b          	addiw	a5,a5,512
    80004d8e:	fcf704e3          	beq	a4,a5,80004d56 <pipewrite+0x6a>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d92:	4685                	li	a3,1
    80004d94:	01590633          	add	a2,s2,s5
    80004d98:	faf40593          	addi	a1,s0,-81
    80004d9c:	0509b503          	ld	a0,80(s3)
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	958080e7          	jalr	-1704(ra) # 800016f8 <copyin>
    80004da8:	03650263          	beq	a0,s6,80004dcc <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004dac:	21c4a783          	lw	a5,540(s1)
    80004db0:	0017871b          	addiw	a4,a5,1
    80004db4:	20e4ae23          	sw	a4,540(s1)
    80004db8:	1ff7f793          	andi	a5,a5,511
    80004dbc:	97a6                	add	a5,a5,s1
    80004dbe:	faf44703          	lbu	a4,-81(s0)
    80004dc2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004dc6:	2905                	addiw	s2,s2,1
    80004dc8:	b755                	j	80004d6c <pipewrite+0x80>
  int i = 0;
    80004dca:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004dcc:	21848513          	addi	a0,s1,536
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	37a080e7          	jalr	890(ra) # 8000214a <wakeup>
  release(&pi->lock);
    80004dd8:	8526                	mv	a0,s1
    80004dda:	ffffc097          	auipc	ra,0xffffc
    80004dde:	eb0080e7          	jalr	-336(ra) # 80000c8a <release>
  return i;
    80004de2:	bfa9                	j	80004d3c <pipewrite+0x50>

0000000080004de4 <piperead>:

int piperead(struct pipe *pi, uint64 addr, int n)
{
    80004de4:	715d                	addi	sp,sp,-80
    80004de6:	e486                	sd	ra,72(sp)
    80004de8:	e0a2                	sd	s0,64(sp)
    80004dea:	fc26                	sd	s1,56(sp)
    80004dec:	f84a                	sd	s2,48(sp)
    80004dee:	f44e                	sd	s3,40(sp)
    80004df0:	f052                	sd	s4,32(sp)
    80004df2:	ec56                	sd	s5,24(sp)
    80004df4:	e85a                	sd	s6,16(sp)
    80004df6:	0880                	addi	s0,sp,80
    80004df8:	84aa                	mv	s1,a0
    80004dfa:	892e                	mv	s2,a1
    80004dfc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dfe:	ffffd097          	auipc	ra,0xffffd
    80004e02:	bae080e7          	jalr	-1106(ra) # 800019ac <myproc>
    80004e06:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e08:	8526                	mv	a0,s1
    80004e0a:	ffffc097          	auipc	ra,0xffffc
    80004e0e:	dcc080e7          	jalr	-564(ra) # 80000bd6 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004e12:	2184a703          	lw	a4,536(s1)
    80004e16:	21c4a783          	lw	a5,540(s1)
    if (killed(pr))
    {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004e1a:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004e1e:	02f71763          	bne	a4,a5,80004e4c <piperead+0x68>
    80004e22:	2244a783          	lw	a5,548(s1)
    80004e26:	c39d                	beqz	a5,80004e4c <piperead+0x68>
    if (killed(pr))
    80004e28:	8552                	mv	a0,s4
    80004e2a:	ffffd097          	auipc	ra,0xffffd
    80004e2e:	590080e7          	jalr	1424(ra) # 800023ba <killed>
    80004e32:	e949                	bnez	a0,80004ec4 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004e34:	85a6                	mv	a1,s1
    80004e36:	854e                	mv	a0,s3
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	2a2080e7          	jalr	674(ra) # 800020da <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004e40:	2184a703          	lw	a4,536(s1)
    80004e44:	21c4a783          	lw	a5,540(s1)
    80004e48:	fcf70de3          	beq	a4,a5,80004e22 <piperead+0x3e>
  }
  for (i = 0; i < n; i++)
    80004e4c:	4981                	li	s3,0
  { // DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e4e:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++)
    80004e50:	05505463          	blez	s5,80004e98 <piperead+0xb4>
    if (pi->nread == pi->nwrite)
    80004e54:	2184a783          	lw	a5,536(s1)
    80004e58:	21c4a703          	lw	a4,540(s1)
    80004e5c:	02f70e63          	beq	a4,a5,80004e98 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e60:	0017871b          	addiw	a4,a5,1
    80004e64:	20e4ac23          	sw	a4,536(s1)
    80004e68:	1ff7f793          	andi	a5,a5,511
    80004e6c:	97a6                	add	a5,a5,s1
    80004e6e:	0187c783          	lbu	a5,24(a5)
    80004e72:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e76:	4685                	li	a3,1
    80004e78:	fbf40613          	addi	a2,s0,-65
    80004e7c:	85ca                	mv	a1,s2
    80004e7e:	050a3503          	ld	a0,80(s4)
    80004e82:	ffffc097          	auipc	ra,0xffffc
    80004e86:	7ea080e7          	jalr	2026(ra) # 8000166c <copyout>
    80004e8a:	01650763          	beq	a0,s6,80004e98 <piperead+0xb4>
  for (i = 0; i < n; i++)
    80004e8e:	2985                	addiw	s3,s3,1
    80004e90:	0905                	addi	s2,s2,1
    80004e92:	fd3a91e3          	bne	s5,s3,80004e54 <piperead+0x70>
    80004e96:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite); // DOC: piperead-wakeup
    80004e98:	21c48513          	addi	a0,s1,540
    80004e9c:	ffffd097          	auipc	ra,0xffffd
    80004ea0:	2ae080e7          	jalr	686(ra) # 8000214a <wakeup>
  release(&pi->lock);
    80004ea4:	8526                	mv	a0,s1
    80004ea6:	ffffc097          	auipc	ra,0xffffc
    80004eaa:	de4080e7          	jalr	-540(ra) # 80000c8a <release>
  return i;
}
    80004eae:	854e                	mv	a0,s3
    80004eb0:	60a6                	ld	ra,72(sp)
    80004eb2:	6406                	ld	s0,64(sp)
    80004eb4:	74e2                	ld	s1,56(sp)
    80004eb6:	7942                	ld	s2,48(sp)
    80004eb8:	79a2                	ld	s3,40(sp)
    80004eba:	7a02                	ld	s4,32(sp)
    80004ebc:	6ae2                	ld	s5,24(sp)
    80004ebe:	6b42                	ld	s6,16(sp)
    80004ec0:	6161                	addi	sp,sp,80
    80004ec2:	8082                	ret
      release(&pi->lock);
    80004ec4:	8526                	mv	a0,s1
    80004ec6:	ffffc097          	auipc	ra,0xffffc
    80004eca:	dc4080e7          	jalr	-572(ra) # 80000c8a <release>
      return -1;
    80004ece:	59fd                	li	s3,-1
    80004ed0:	bff9                	j	80004eae <piperead+0xca>

0000000080004ed2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004ed2:	1141                	addi	sp,sp,-16
    80004ed4:	e422                	sd	s0,8(sp)
    80004ed6:	0800                	addi	s0,sp,16
    80004ed8:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004eda:	8905                	andi	a0,a0,1
    80004edc:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80004ede:	8b89                	andi	a5,a5,2
    80004ee0:	c399                	beqz	a5,80004ee6 <flags2perm+0x14>
    perm |= PTE_W;
    80004ee2:	00456513          	ori	a0,a0,4
  return perm;
}
    80004ee6:	6422                	ld	s0,8(sp)
    80004ee8:	0141                	addi	sp,sp,16
    80004eea:	8082                	ret

0000000080004eec <exec>:

int exec(char *path, char **argv)
{
    80004eec:	de010113          	addi	sp,sp,-544
    80004ef0:	20113c23          	sd	ra,536(sp)
    80004ef4:	20813823          	sd	s0,528(sp)
    80004ef8:	20913423          	sd	s1,520(sp)
    80004efc:	21213023          	sd	s2,512(sp)
    80004f00:	ffce                	sd	s3,504(sp)
    80004f02:	fbd2                	sd	s4,496(sp)
    80004f04:	f7d6                	sd	s5,488(sp)
    80004f06:	f3da                	sd	s6,480(sp)
    80004f08:	efde                	sd	s7,472(sp)
    80004f0a:	ebe2                	sd	s8,464(sp)
    80004f0c:	e7e6                	sd	s9,456(sp)
    80004f0e:	e3ea                	sd	s10,448(sp)
    80004f10:	ff6e                	sd	s11,440(sp)
    80004f12:	1400                	addi	s0,sp,544
    80004f14:	892a                	mv	s2,a0
    80004f16:	dea43423          	sd	a0,-536(s0)
    80004f1a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f1e:	ffffd097          	auipc	ra,0xffffd
    80004f22:	a8e080e7          	jalr	-1394(ra) # 800019ac <myproc>
    80004f26:	84aa                	mv	s1,a0

  begin_op();
    80004f28:	fffff097          	auipc	ra,0xfffff
    80004f2c:	482080e7          	jalr	1154(ra) # 800043aa <begin_op>

  if ((ip = namei(path)) == 0)
    80004f30:	854a                	mv	a0,s2
    80004f32:	fffff097          	auipc	ra,0xfffff
    80004f36:	258080e7          	jalr	600(ra) # 8000418a <namei>
    80004f3a:	c93d                	beqz	a0,80004fb0 <exec+0xc4>
    80004f3c:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80004f3e:	fffff097          	auipc	ra,0xfffff
    80004f42:	aa0080e7          	jalr	-1376(ra) # 800039de <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f46:	04000713          	li	a4,64
    80004f4a:	4681                	li	a3,0
    80004f4c:	e5040613          	addi	a2,s0,-432
    80004f50:	4581                	li	a1,0
    80004f52:	8556                	mv	a0,s5
    80004f54:	fffff097          	auipc	ra,0xfffff
    80004f58:	d3e080e7          	jalr	-706(ra) # 80003c92 <readi>
    80004f5c:	04000793          	li	a5,64
    80004f60:	00f51a63          	bne	a0,a5,80004f74 <exec+0x88>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    80004f64:	e5042703          	lw	a4,-432(s0)
    80004f68:	464c47b7          	lui	a5,0x464c4
    80004f6c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f70:	04f70663          	beq	a4,a5,80004fbc <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80004f74:	8556                	mv	a0,s5
    80004f76:	fffff097          	auipc	ra,0xfffff
    80004f7a:	cca080e7          	jalr	-822(ra) # 80003c40 <iunlockput>
    end_op();
    80004f7e:	fffff097          	auipc	ra,0xfffff
    80004f82:	4aa080e7          	jalr	1194(ra) # 80004428 <end_op>
  }
  return -1;
    80004f86:	557d                	li	a0,-1
}
    80004f88:	21813083          	ld	ra,536(sp)
    80004f8c:	21013403          	ld	s0,528(sp)
    80004f90:	20813483          	ld	s1,520(sp)
    80004f94:	20013903          	ld	s2,512(sp)
    80004f98:	79fe                	ld	s3,504(sp)
    80004f9a:	7a5e                	ld	s4,496(sp)
    80004f9c:	7abe                	ld	s5,488(sp)
    80004f9e:	7b1e                	ld	s6,480(sp)
    80004fa0:	6bfe                	ld	s7,472(sp)
    80004fa2:	6c5e                	ld	s8,464(sp)
    80004fa4:	6cbe                	ld	s9,456(sp)
    80004fa6:	6d1e                	ld	s10,448(sp)
    80004fa8:	7dfa                	ld	s11,440(sp)
    80004faa:	22010113          	addi	sp,sp,544
    80004fae:	8082                	ret
    end_op();
    80004fb0:	fffff097          	auipc	ra,0xfffff
    80004fb4:	478080e7          	jalr	1144(ra) # 80004428 <end_op>
    return -1;
    80004fb8:	557d                	li	a0,-1
    80004fba:	b7f9                	j	80004f88 <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	ffffd097          	auipc	ra,0xffffd
    80004fc2:	ab2080e7          	jalr	-1358(ra) # 80001a70 <proc_pagetable>
    80004fc6:	8b2a                	mv	s6,a0
    80004fc8:	d555                	beqz	a0,80004f74 <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80004fca:	e7042783          	lw	a5,-400(s0)
    80004fce:	e8845703          	lhu	a4,-376(s0)
    80004fd2:	c735                	beqz	a4,8000503e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fd4:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80004fd6:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    80004fda:	6a05                	lui	s4,0x1
    80004fdc:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004fe0:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for (i = 0; i < sz; i += PGSIZE)
    80004fe4:	6d85                	lui	s11,0x1
    80004fe6:	7d7d                	lui	s10,0xfffff
    80004fe8:	ac3d                	j	80005226 <exec+0x33a>
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    80004fea:	00003517          	auipc	a0,0x3
    80004fee:	70650513          	addi	a0,a0,1798 # 800086f0 <syscalls+0x298>
    80004ff2:	ffffb097          	auipc	ra,0xffffb
    80004ff6:	54e080e7          	jalr	1358(ra) # 80000540 <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004ffa:	874a                	mv	a4,s2
    80004ffc:	009c86bb          	addw	a3,s9,s1
    80005000:	4581                	li	a1,0
    80005002:	8556                	mv	a0,s5
    80005004:	fffff097          	auipc	ra,0xfffff
    80005008:	c8e080e7          	jalr	-882(ra) # 80003c92 <readi>
    8000500c:	2501                	sext.w	a0,a0
    8000500e:	1aa91963          	bne	s2,a0,800051c0 <exec+0x2d4>
  for (i = 0; i < sz; i += PGSIZE)
    80005012:	009d84bb          	addw	s1,s11,s1
    80005016:	013d09bb          	addw	s3,s10,s3
    8000501a:	1f74f663          	bgeu	s1,s7,80005206 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    8000501e:	02049593          	slli	a1,s1,0x20
    80005022:	9181                	srli	a1,a1,0x20
    80005024:	95e2                	add	a1,a1,s8
    80005026:	855a                	mv	a0,s6
    80005028:	ffffc097          	auipc	ra,0xffffc
    8000502c:	034080e7          	jalr	52(ra) # 8000105c <walkaddr>
    80005030:	862a                	mv	a2,a0
    if (pa == 0)
    80005032:	dd45                	beqz	a0,80004fea <exec+0xfe>
      n = PGSIZE;
    80005034:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005036:	fd49f2e3          	bgeu	s3,s4,80004ffa <exec+0x10e>
      n = sz - i;
    8000503a:	894e                	mv	s2,s3
    8000503c:	bf7d                	j	80004ffa <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000503e:	4901                	li	s2,0
  iunlockput(ip);
    80005040:	8556                	mv	a0,s5
    80005042:	fffff097          	auipc	ra,0xfffff
    80005046:	bfe080e7          	jalr	-1026(ra) # 80003c40 <iunlockput>
  end_op();
    8000504a:	fffff097          	auipc	ra,0xfffff
    8000504e:	3de080e7          	jalr	990(ra) # 80004428 <end_op>
  p = myproc();
    80005052:	ffffd097          	auipc	ra,0xffffd
    80005056:	95a080e7          	jalr	-1702(ra) # 800019ac <myproc>
    8000505a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000505c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005060:	6785                	lui	a5,0x1
    80005062:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005064:	97ca                	add	a5,a5,s2
    80005066:	777d                	lui	a4,0xfffff
    80005068:	8ff9                	and	a5,a5,a4
    8000506a:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    8000506e:	4691                	li	a3,4
    80005070:	6609                	lui	a2,0x2
    80005072:	963e                	add	a2,a2,a5
    80005074:	85be                	mv	a1,a5
    80005076:	855a                	mv	a0,s6
    80005078:	ffffc097          	auipc	ra,0xffffc
    8000507c:	398080e7          	jalr	920(ra) # 80001410 <uvmalloc>
    80005080:	8c2a                	mv	s8,a0
  ip = 0;
    80005082:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    80005084:	12050e63          	beqz	a0,800051c0 <exec+0x2d4>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005088:	75f9                	lui	a1,0xffffe
    8000508a:	95aa                	add	a1,a1,a0
    8000508c:	855a                	mv	a0,s6
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	5ac080e7          	jalr	1452(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80005096:	7afd                	lui	s5,0xfffff
    80005098:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    8000509a:	df043783          	ld	a5,-528(s0)
    8000509e:	6388                	ld	a0,0(a5)
    800050a0:	c925                	beqz	a0,80005110 <exec+0x224>
    800050a2:	e9040993          	addi	s3,s0,-368
    800050a6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800050aa:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    800050ac:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050ae:	ffffc097          	auipc	ra,0xffffc
    800050b2:	da0080e7          	jalr	-608(ra) # 80000e4e <strlen>
    800050b6:	0015079b          	addiw	a5,a0,1
    800050ba:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050be:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    800050c2:	13596663          	bltu	s2,s5,800051ee <exec+0x302>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050c6:	df043d83          	ld	s11,-528(s0)
    800050ca:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800050ce:	8552                	mv	a0,s4
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	d7e080e7          	jalr	-642(ra) # 80000e4e <strlen>
    800050d8:	0015069b          	addiw	a3,a0,1
    800050dc:	8652                	mv	a2,s4
    800050de:	85ca                	mv	a1,s2
    800050e0:	855a                	mv	a0,s6
    800050e2:	ffffc097          	auipc	ra,0xffffc
    800050e6:	58a080e7          	jalr	1418(ra) # 8000166c <copyout>
    800050ea:	10054663          	bltz	a0,800051f6 <exec+0x30a>
    ustack[argc] = sp;
    800050ee:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    800050f2:	0485                	addi	s1,s1,1
    800050f4:	008d8793          	addi	a5,s11,8
    800050f8:	def43823          	sd	a5,-528(s0)
    800050fc:	008db503          	ld	a0,8(s11)
    80005100:	c911                	beqz	a0,80005114 <exec+0x228>
    if (argc >= MAXARG)
    80005102:	09a1                	addi	s3,s3,8
    80005104:	fb3c95e3          	bne	s9,s3,800050ae <exec+0x1c2>
  sz = sz1;
    80005108:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000510c:	4a81                	li	s5,0
    8000510e:	a84d                	j	800051c0 <exec+0x2d4>
  sp = sz;
    80005110:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005112:	4481                	li	s1,0
  ustack[argc] = 0;
    80005114:	00349793          	slli	a5,s1,0x3
    80005118:	f9078793          	addi	a5,a5,-112
    8000511c:	97a2                	add	a5,a5,s0
    8000511e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80005122:	00148693          	addi	a3,s1,1
    80005126:	068e                	slli	a3,a3,0x3
    80005128:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000512c:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    80005130:	01597663          	bgeu	s2,s5,8000513c <exec+0x250>
  sz = sz1;
    80005134:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005138:	4a81                	li	s5,0
    8000513a:	a059                	j	800051c0 <exec+0x2d4>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    8000513c:	e9040613          	addi	a2,s0,-368
    80005140:	85ca                	mv	a1,s2
    80005142:	855a                	mv	a0,s6
    80005144:	ffffc097          	auipc	ra,0xffffc
    80005148:	528080e7          	jalr	1320(ra) # 8000166c <copyout>
    8000514c:	0a054963          	bltz	a0,800051fe <exec+0x312>
  p->trapframe->a1 = sp;
    80005150:	058bb783          	ld	a5,88(s7)
    80005154:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005158:	de843783          	ld	a5,-536(s0)
    8000515c:	0007c703          	lbu	a4,0(a5)
    80005160:	cf11                	beqz	a4,8000517c <exec+0x290>
    80005162:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005164:	02f00693          	li	a3,47
    80005168:	a039                	j	80005176 <exec+0x28a>
      last = s + 1;
    8000516a:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    8000516e:	0785                	addi	a5,a5,1
    80005170:	fff7c703          	lbu	a4,-1(a5)
    80005174:	c701                	beqz	a4,8000517c <exec+0x290>
    if (*s == '/')
    80005176:	fed71ce3          	bne	a4,a3,8000516e <exec+0x282>
    8000517a:	bfc5                	j	8000516a <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000517c:	4641                	li	a2,16
    8000517e:	de843583          	ld	a1,-536(s0)
    80005182:	158b8513          	addi	a0,s7,344
    80005186:	ffffc097          	auipc	ra,0xffffc
    8000518a:	c96080e7          	jalr	-874(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000518e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005192:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005196:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    8000519a:	058bb783          	ld	a5,88(s7)
    8000519e:	e6843703          	ld	a4,-408(s0)
    800051a2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    800051a4:	058bb783          	ld	a5,88(s7)
    800051a8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051ac:	85ea                	mv	a1,s10
    800051ae:	ffffd097          	auipc	ra,0xffffd
    800051b2:	95e080e7          	jalr	-1698(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051b6:	0004851b          	sext.w	a0,s1
    800051ba:	b3f9                	j	80004f88 <exec+0x9c>
    800051bc:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051c0:	df843583          	ld	a1,-520(s0)
    800051c4:	855a                	mv	a0,s6
    800051c6:	ffffd097          	auipc	ra,0xffffd
    800051ca:	946080e7          	jalr	-1722(ra) # 80001b0c <proc_freepagetable>
  if (ip)
    800051ce:	da0a93e3          	bnez	s5,80004f74 <exec+0x88>
  return -1;
    800051d2:	557d                	li	a0,-1
    800051d4:	bb55                	j	80004f88 <exec+0x9c>
    800051d6:	df243c23          	sd	s2,-520(s0)
    800051da:	b7dd                	j	800051c0 <exec+0x2d4>
    800051dc:	df243c23          	sd	s2,-520(s0)
    800051e0:	b7c5                	j	800051c0 <exec+0x2d4>
    800051e2:	df243c23          	sd	s2,-520(s0)
    800051e6:	bfe9                	j	800051c0 <exec+0x2d4>
    800051e8:	df243c23          	sd	s2,-520(s0)
    800051ec:	bfd1                	j	800051c0 <exec+0x2d4>
  sz = sz1;
    800051ee:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051f2:	4a81                	li	s5,0
    800051f4:	b7f1                	j	800051c0 <exec+0x2d4>
  sz = sz1;
    800051f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051fa:	4a81                	li	s5,0
    800051fc:	b7d1                	j	800051c0 <exec+0x2d4>
  sz = sz1;
    800051fe:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005202:	4a81                	li	s5,0
    80005204:	bf75                	j	800051c0 <exec+0x2d4>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005206:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    8000520a:	e0843783          	ld	a5,-504(s0)
    8000520e:	0017869b          	addiw	a3,a5,1
    80005212:	e0d43423          	sd	a3,-504(s0)
    80005216:	e0043783          	ld	a5,-512(s0)
    8000521a:	0387879b          	addiw	a5,a5,56
    8000521e:	e8845703          	lhu	a4,-376(s0)
    80005222:	e0e6dfe3          	bge	a3,a4,80005040 <exec+0x154>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005226:	2781                	sext.w	a5,a5
    80005228:	e0f43023          	sd	a5,-512(s0)
    8000522c:	03800713          	li	a4,56
    80005230:	86be                	mv	a3,a5
    80005232:	e1840613          	addi	a2,s0,-488
    80005236:	4581                	li	a1,0
    80005238:	8556                	mv	a0,s5
    8000523a:	fffff097          	auipc	ra,0xfffff
    8000523e:	a58080e7          	jalr	-1448(ra) # 80003c92 <readi>
    80005242:	03800793          	li	a5,56
    80005246:	f6f51be3          	bne	a0,a5,800051bc <exec+0x2d0>
    if (ph.type != ELF_PROG_LOAD)
    8000524a:	e1842783          	lw	a5,-488(s0)
    8000524e:	4705                	li	a4,1
    80005250:	fae79de3          	bne	a5,a4,8000520a <exec+0x31e>
    if (ph.memsz < ph.filesz)
    80005254:	e4043483          	ld	s1,-448(s0)
    80005258:	e3843783          	ld	a5,-456(s0)
    8000525c:	f6f4ede3          	bltu	s1,a5,800051d6 <exec+0x2ea>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80005260:	e2843783          	ld	a5,-472(s0)
    80005264:	94be                	add	s1,s1,a5
    80005266:	f6f4ebe3          	bltu	s1,a5,800051dc <exec+0x2f0>
    if (ph.vaddr % PGSIZE != 0)
    8000526a:	de043703          	ld	a4,-544(s0)
    8000526e:	8ff9                	and	a5,a5,a4
    80005270:	fbad                	bnez	a5,800051e2 <exec+0x2f6>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005272:	e1c42503          	lw	a0,-484(s0)
    80005276:	00000097          	auipc	ra,0x0
    8000527a:	c5c080e7          	jalr	-932(ra) # 80004ed2 <flags2perm>
    8000527e:	86aa                	mv	a3,a0
    80005280:	8626                	mv	a2,s1
    80005282:	85ca                	mv	a1,s2
    80005284:	855a                	mv	a0,s6
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	18a080e7          	jalr	394(ra) # 80001410 <uvmalloc>
    8000528e:	dea43c23          	sd	a0,-520(s0)
    80005292:	d939                	beqz	a0,800051e8 <exec+0x2fc>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005294:	e2843c03          	ld	s8,-472(s0)
    80005298:	e2042c83          	lw	s9,-480(s0)
    8000529c:	e3842b83          	lw	s7,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    800052a0:	f60b83e3          	beqz	s7,80005206 <exec+0x31a>
    800052a4:	89de                	mv	s3,s7
    800052a6:	4481                	li	s1,0
    800052a8:	bb9d                	j	8000501e <exec+0x132>

00000000800052aa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052aa:	7179                	addi	sp,sp,-48
    800052ac:	f406                	sd	ra,40(sp)
    800052ae:	f022                	sd	s0,32(sp)
    800052b0:	ec26                	sd	s1,24(sp)
    800052b2:	e84a                	sd	s2,16(sp)
    800052b4:	1800                	addi	s0,sp,48
    800052b6:	892e                	mv	s2,a1
    800052b8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800052ba:	fdc40593          	addi	a1,s0,-36
    800052be:	ffffe097          	auipc	ra,0xffffe
    800052c2:	a7c080e7          	jalr	-1412(ra) # 80002d3a <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    800052c6:	fdc42703          	lw	a4,-36(s0)
    800052ca:	47bd                	li	a5,15
    800052cc:	02e7eb63          	bltu	a5,a4,80005302 <argfd+0x58>
    800052d0:	ffffc097          	auipc	ra,0xffffc
    800052d4:	6dc080e7          	jalr	1756(ra) # 800019ac <myproc>
    800052d8:	fdc42703          	lw	a4,-36(s0)
    800052dc:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd9ed2>
    800052e0:	078e                	slli	a5,a5,0x3
    800052e2:	953e                	add	a0,a0,a5
    800052e4:	611c                	ld	a5,0(a0)
    800052e6:	c385                	beqz	a5,80005306 <argfd+0x5c>
    return -1;
  if (pfd)
    800052e8:	00090463          	beqz	s2,800052f0 <argfd+0x46>
    *pfd = fd;
    800052ec:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    800052f0:	4501                	li	a0,0
  if (pf)
    800052f2:	c091                	beqz	s1,800052f6 <argfd+0x4c>
    *pf = f;
    800052f4:	e09c                	sd	a5,0(s1)
}
    800052f6:	70a2                	ld	ra,40(sp)
    800052f8:	7402                	ld	s0,32(sp)
    800052fa:	64e2                	ld	s1,24(sp)
    800052fc:	6942                	ld	s2,16(sp)
    800052fe:	6145                	addi	sp,sp,48
    80005300:	8082                	ret
    return -1;
    80005302:	557d                	li	a0,-1
    80005304:	bfcd                	j	800052f6 <argfd+0x4c>
    80005306:	557d                	li	a0,-1
    80005308:	b7fd                	j	800052f6 <argfd+0x4c>

000000008000530a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000530a:	1101                	addi	sp,sp,-32
    8000530c:	ec06                	sd	ra,24(sp)
    8000530e:	e822                	sd	s0,16(sp)
    80005310:	e426                	sd	s1,8(sp)
    80005312:	1000                	addi	s0,sp,32
    80005314:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005316:	ffffc097          	auipc	ra,0xffffc
    8000531a:	696080e7          	jalr	1686(ra) # 800019ac <myproc>
    8000531e:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++)
    80005320:	0d050793          	addi	a5,a0,208
    80005324:	4501                	li	a0,0
    80005326:	46c1                	li	a3,16
  {
    if (p->ofile[fd] == 0)
    80005328:	6398                	ld	a4,0(a5)
    8000532a:	cb19                	beqz	a4,80005340 <fdalloc+0x36>
  for (fd = 0; fd < NOFILE; fd++)
    8000532c:	2505                	addiw	a0,a0,1
    8000532e:	07a1                	addi	a5,a5,8
    80005330:	fed51ce3          	bne	a0,a3,80005328 <fdalloc+0x1e>
    {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005334:	557d                	li	a0,-1
}
    80005336:	60e2                	ld	ra,24(sp)
    80005338:	6442                	ld	s0,16(sp)
    8000533a:	64a2                	ld	s1,8(sp)
    8000533c:	6105                	addi	sp,sp,32
    8000533e:	8082                	ret
      p->ofile[fd] = f;
    80005340:	01a50793          	addi	a5,a0,26
    80005344:	078e                	slli	a5,a5,0x3
    80005346:	963e                	add	a2,a2,a5
    80005348:	e204                	sd	s1,0(a2)
      return fd;
    8000534a:	b7f5                	j	80005336 <fdalloc+0x2c>

000000008000534c <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    8000534c:	715d                	addi	sp,sp,-80
    8000534e:	e486                	sd	ra,72(sp)
    80005350:	e0a2                	sd	s0,64(sp)
    80005352:	fc26                	sd	s1,56(sp)
    80005354:	f84a                	sd	s2,48(sp)
    80005356:	f44e                	sd	s3,40(sp)
    80005358:	f052                	sd	s4,32(sp)
    8000535a:	ec56                	sd	s5,24(sp)
    8000535c:	e85a                	sd	s6,16(sp)
    8000535e:	0880                	addi	s0,sp,80
    80005360:	8b2e                	mv	s6,a1
    80005362:	89b2                	mv	s3,a2
    80005364:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80005366:	fb040593          	addi	a1,s0,-80
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	e3e080e7          	jalr	-450(ra) # 800041a8 <nameiparent>
    80005372:	84aa                	mv	s1,a0
    80005374:	14050f63          	beqz	a0,800054d2 <create+0x186>
    return 0;

  ilock(dp);
    80005378:	ffffe097          	auipc	ra,0xffffe
    8000537c:	666080e7          	jalr	1638(ra) # 800039de <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0)
    80005380:	4601                	li	a2,0
    80005382:	fb040593          	addi	a1,s0,-80
    80005386:	8526                	mv	a0,s1
    80005388:	fffff097          	auipc	ra,0xfffff
    8000538c:	b3a080e7          	jalr	-1222(ra) # 80003ec2 <dirlookup>
    80005390:	8aaa                	mv	s5,a0
    80005392:	c931                	beqz	a0,800053e6 <create+0x9a>
  {
    iunlockput(dp);
    80005394:	8526                	mv	a0,s1
    80005396:	fffff097          	auipc	ra,0xfffff
    8000539a:	8aa080e7          	jalr	-1878(ra) # 80003c40 <iunlockput>
    ilock(ip);
    8000539e:	8556                	mv	a0,s5
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	63e080e7          	jalr	1598(ra) # 800039de <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053a8:	000b059b          	sext.w	a1,s6
    800053ac:	4789                	li	a5,2
    800053ae:	02f59563          	bne	a1,a5,800053d8 <create+0x8c>
    800053b2:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffd9efc>
    800053b6:	37f9                	addiw	a5,a5,-2
    800053b8:	17c2                	slli	a5,a5,0x30
    800053ba:	93c1                	srli	a5,a5,0x30
    800053bc:	4705                	li	a4,1
    800053be:	00f76d63          	bltu	a4,a5,800053d8 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800053c2:	8556                	mv	a0,s5
    800053c4:	60a6                	ld	ra,72(sp)
    800053c6:	6406                	ld	s0,64(sp)
    800053c8:	74e2                	ld	s1,56(sp)
    800053ca:	7942                	ld	s2,48(sp)
    800053cc:	79a2                	ld	s3,40(sp)
    800053ce:	7a02                	ld	s4,32(sp)
    800053d0:	6ae2                	ld	s5,24(sp)
    800053d2:	6b42                	ld	s6,16(sp)
    800053d4:	6161                	addi	sp,sp,80
    800053d6:	8082                	ret
    iunlockput(ip);
    800053d8:	8556                	mv	a0,s5
    800053da:	fffff097          	auipc	ra,0xfffff
    800053de:	866080e7          	jalr	-1946(ra) # 80003c40 <iunlockput>
    return 0;
    800053e2:	4a81                	li	s5,0
    800053e4:	bff9                	j	800053c2 <create+0x76>
  if ((ip = ialloc(dp->dev, type)) == 0)
    800053e6:	85da                	mv	a1,s6
    800053e8:	4088                	lw	a0,0(s1)
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	456080e7          	jalr	1110(ra) # 80003840 <ialloc>
    800053f2:	8a2a                	mv	s4,a0
    800053f4:	c539                	beqz	a0,80005442 <create+0xf6>
  ilock(ip);
    800053f6:	ffffe097          	auipc	ra,0xffffe
    800053fa:	5e8080e7          	jalr	1512(ra) # 800039de <ilock>
  ip->major = major;
    800053fe:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005402:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005406:	4905                	li	s2,1
    80005408:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000540c:	8552                	mv	a0,s4
    8000540e:	ffffe097          	auipc	ra,0xffffe
    80005412:	504080e7          	jalr	1284(ra) # 80003912 <iupdate>
  if (type == T_DIR)
    80005416:	000b059b          	sext.w	a1,s6
    8000541a:	03258b63          	beq	a1,s2,80005450 <create+0x104>
  if (dirlink(dp, name, ip->inum) < 0)
    8000541e:	004a2603          	lw	a2,4(s4)
    80005422:	fb040593          	addi	a1,s0,-80
    80005426:	8526                	mv	a0,s1
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	cb0080e7          	jalr	-848(ra) # 800040d8 <dirlink>
    80005430:	06054f63          	bltz	a0,800054ae <create+0x162>
  iunlockput(dp);
    80005434:	8526                	mv	a0,s1
    80005436:	fffff097          	auipc	ra,0xfffff
    8000543a:	80a080e7          	jalr	-2038(ra) # 80003c40 <iunlockput>
  return ip;
    8000543e:	8ad2                	mv	s5,s4
    80005440:	b749                	j	800053c2 <create+0x76>
    iunlockput(dp);
    80005442:	8526                	mv	a0,s1
    80005444:	ffffe097          	auipc	ra,0xffffe
    80005448:	7fc080e7          	jalr	2044(ra) # 80003c40 <iunlockput>
    return 0;
    8000544c:	8ad2                	mv	s5,s4
    8000544e:	bf95                	j	800053c2 <create+0x76>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005450:	004a2603          	lw	a2,4(s4)
    80005454:	00003597          	auipc	a1,0x3
    80005458:	2bc58593          	addi	a1,a1,700 # 80008710 <syscalls+0x2b8>
    8000545c:	8552                	mv	a0,s4
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	c7a080e7          	jalr	-902(ra) # 800040d8 <dirlink>
    80005466:	04054463          	bltz	a0,800054ae <create+0x162>
    8000546a:	40d0                	lw	a2,4(s1)
    8000546c:	00003597          	auipc	a1,0x3
    80005470:	2ac58593          	addi	a1,a1,684 # 80008718 <syscalls+0x2c0>
    80005474:	8552                	mv	a0,s4
    80005476:	fffff097          	auipc	ra,0xfffff
    8000547a:	c62080e7          	jalr	-926(ra) # 800040d8 <dirlink>
    8000547e:	02054863          	bltz	a0,800054ae <create+0x162>
  if (dirlink(dp, name, ip->inum) < 0)
    80005482:	004a2603          	lw	a2,4(s4)
    80005486:	fb040593          	addi	a1,s0,-80
    8000548a:	8526                	mv	a0,s1
    8000548c:	fffff097          	auipc	ra,0xfffff
    80005490:	c4c080e7          	jalr	-948(ra) # 800040d8 <dirlink>
    80005494:	00054d63          	bltz	a0,800054ae <create+0x162>
    dp->nlink++; // for ".."
    80005498:	04a4d783          	lhu	a5,74(s1)
    8000549c:	2785                	addiw	a5,a5,1
    8000549e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054a2:	8526                	mv	a0,s1
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	46e080e7          	jalr	1134(ra) # 80003912 <iupdate>
    800054ac:	b761                	j	80005434 <create+0xe8>
  ip->nlink = 0;
    800054ae:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800054b2:	8552                	mv	a0,s4
    800054b4:	ffffe097          	auipc	ra,0xffffe
    800054b8:	45e080e7          	jalr	1118(ra) # 80003912 <iupdate>
  iunlockput(ip);
    800054bc:	8552                	mv	a0,s4
    800054be:	ffffe097          	auipc	ra,0xffffe
    800054c2:	782080e7          	jalr	1922(ra) # 80003c40 <iunlockput>
  iunlockput(dp);
    800054c6:	8526                	mv	a0,s1
    800054c8:	ffffe097          	auipc	ra,0xffffe
    800054cc:	778080e7          	jalr	1912(ra) # 80003c40 <iunlockput>
  return 0;
    800054d0:	bdcd                	j	800053c2 <create+0x76>
    return 0;
    800054d2:	8aaa                	mv	s5,a0
    800054d4:	b5fd                	j	800053c2 <create+0x76>

00000000800054d6 <sys_dup>:
{
    800054d6:	7179                	addi	sp,sp,-48
    800054d8:	f406                	sd	ra,40(sp)
    800054da:	f022                	sd	s0,32(sp)
    800054dc:	ec26                	sd	s1,24(sp)
    800054de:	e84a                	sd	s2,16(sp)
    800054e0:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    800054e2:	fd840613          	addi	a2,s0,-40
    800054e6:	4581                	li	a1,0
    800054e8:	4501                	li	a0,0
    800054ea:	00000097          	auipc	ra,0x0
    800054ee:	dc0080e7          	jalr	-576(ra) # 800052aa <argfd>
    return -1;
    800054f2:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    800054f4:	02054363          	bltz	a0,8000551a <sys_dup+0x44>
  if ((fd = fdalloc(f)) < 0)
    800054f8:	fd843903          	ld	s2,-40(s0)
    800054fc:	854a                	mv	a0,s2
    800054fe:	00000097          	auipc	ra,0x0
    80005502:	e0c080e7          	jalr	-500(ra) # 8000530a <fdalloc>
    80005506:	84aa                	mv	s1,a0
    return -1;
    80005508:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    8000550a:	00054863          	bltz	a0,8000551a <sys_dup+0x44>
  filedup(f);
    8000550e:	854a                	mv	a0,s2
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	310080e7          	jalr	784(ra) # 80004820 <filedup>
  return fd;
    80005518:	87a6                	mv	a5,s1
}
    8000551a:	853e                	mv	a0,a5
    8000551c:	70a2                	ld	ra,40(sp)
    8000551e:	7402                	ld	s0,32(sp)
    80005520:	64e2                	ld	s1,24(sp)
    80005522:	6942                	ld	s2,16(sp)
    80005524:	6145                	addi	sp,sp,48
    80005526:	8082                	ret

0000000080005528 <sys_read>:
{
    80005528:	7179                	addi	sp,sp,-48
    8000552a:	f406                	sd	ra,40(sp)
    8000552c:	f022                	sd	s0,32(sp)
    8000552e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005530:	fd840593          	addi	a1,s0,-40
    80005534:	4505                	li	a0,1
    80005536:	ffffe097          	auipc	ra,0xffffe
    8000553a:	824080e7          	jalr	-2012(ra) # 80002d5a <argaddr>
  argint(2, &n);
    8000553e:	fe440593          	addi	a1,s0,-28
    80005542:	4509                	li	a0,2
    80005544:	ffffd097          	auipc	ra,0xffffd
    80005548:	7f6080e7          	jalr	2038(ra) # 80002d3a <argint>
  if (argfd(0, 0, &f) < 0)
    8000554c:	fe840613          	addi	a2,s0,-24
    80005550:	4581                	li	a1,0
    80005552:	4501                	li	a0,0
    80005554:	00000097          	auipc	ra,0x0
    80005558:	d56080e7          	jalr	-682(ra) # 800052aa <argfd>
    8000555c:	87aa                	mv	a5,a0
    return -1;
    8000555e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005560:	0007cc63          	bltz	a5,80005578 <sys_read+0x50>
  return fileread(f, p, n);
    80005564:	fe442603          	lw	a2,-28(s0)
    80005568:	fd843583          	ld	a1,-40(s0)
    8000556c:	fe843503          	ld	a0,-24(s0)
    80005570:	fffff097          	auipc	ra,0xfffff
    80005574:	43c080e7          	jalr	1084(ra) # 800049ac <fileread>
}
    80005578:	70a2                	ld	ra,40(sp)
    8000557a:	7402                	ld	s0,32(sp)
    8000557c:	6145                	addi	sp,sp,48
    8000557e:	8082                	ret

0000000080005580 <sys_write>:
{
    80005580:	7179                	addi	sp,sp,-48
    80005582:	f406                	sd	ra,40(sp)
    80005584:	f022                	sd	s0,32(sp)
    80005586:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005588:	fd840593          	addi	a1,s0,-40
    8000558c:	4505                	li	a0,1
    8000558e:	ffffd097          	auipc	ra,0xffffd
    80005592:	7cc080e7          	jalr	1996(ra) # 80002d5a <argaddr>
  argint(2, &n);
    80005596:	fe440593          	addi	a1,s0,-28
    8000559a:	4509                	li	a0,2
    8000559c:	ffffd097          	auipc	ra,0xffffd
    800055a0:	79e080e7          	jalr	1950(ra) # 80002d3a <argint>
  if (argfd(0, 0, &f) < 0)
    800055a4:	fe840613          	addi	a2,s0,-24
    800055a8:	4581                	li	a1,0
    800055aa:	4501                	li	a0,0
    800055ac:	00000097          	auipc	ra,0x0
    800055b0:	cfe080e7          	jalr	-770(ra) # 800052aa <argfd>
    800055b4:	87aa                	mv	a5,a0
    return -1;
    800055b6:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800055b8:	0007cc63          	bltz	a5,800055d0 <sys_write+0x50>
  return filewrite(f, p, n);
    800055bc:	fe442603          	lw	a2,-28(s0)
    800055c0:	fd843583          	ld	a1,-40(s0)
    800055c4:	fe843503          	ld	a0,-24(s0)
    800055c8:	fffff097          	auipc	ra,0xfffff
    800055cc:	4a6080e7          	jalr	1190(ra) # 80004a6e <filewrite>
}
    800055d0:	70a2                	ld	ra,40(sp)
    800055d2:	7402                	ld	s0,32(sp)
    800055d4:	6145                	addi	sp,sp,48
    800055d6:	8082                	ret

00000000800055d8 <sys_close>:
{
    800055d8:	1101                	addi	sp,sp,-32
    800055da:	ec06                	sd	ra,24(sp)
    800055dc:	e822                	sd	s0,16(sp)
    800055de:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800055e0:	fe040613          	addi	a2,s0,-32
    800055e4:	fec40593          	addi	a1,s0,-20
    800055e8:	4501                	li	a0,0
    800055ea:	00000097          	auipc	ra,0x0
    800055ee:	cc0080e7          	jalr	-832(ra) # 800052aa <argfd>
    return -1;
    800055f2:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    800055f4:	02054463          	bltz	a0,8000561c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055f8:	ffffc097          	auipc	ra,0xffffc
    800055fc:	3b4080e7          	jalr	948(ra) # 800019ac <myproc>
    80005600:	fec42783          	lw	a5,-20(s0)
    80005604:	07e9                	addi	a5,a5,26
    80005606:	078e                	slli	a5,a5,0x3
    80005608:	953e                	add	a0,a0,a5
    8000560a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000560e:	fe043503          	ld	a0,-32(s0)
    80005612:	fffff097          	auipc	ra,0xfffff
    80005616:	260080e7          	jalr	608(ra) # 80004872 <fileclose>
  return 0;
    8000561a:	4781                	li	a5,0
}
    8000561c:	853e                	mv	a0,a5
    8000561e:	60e2                	ld	ra,24(sp)
    80005620:	6442                	ld	s0,16(sp)
    80005622:	6105                	addi	sp,sp,32
    80005624:	8082                	ret

0000000080005626 <sys_fstat>:
{
    80005626:	1101                	addi	sp,sp,-32
    80005628:	ec06                	sd	ra,24(sp)
    8000562a:	e822                	sd	s0,16(sp)
    8000562c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000562e:	fe040593          	addi	a1,s0,-32
    80005632:	4505                	li	a0,1
    80005634:	ffffd097          	auipc	ra,0xffffd
    80005638:	726080e7          	jalr	1830(ra) # 80002d5a <argaddr>
  if (argfd(0, 0, &f) < 0)
    8000563c:	fe840613          	addi	a2,s0,-24
    80005640:	4581                	li	a1,0
    80005642:	4501                	li	a0,0
    80005644:	00000097          	auipc	ra,0x0
    80005648:	c66080e7          	jalr	-922(ra) # 800052aa <argfd>
    8000564c:	87aa                	mv	a5,a0
    return -1;
    8000564e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005650:	0007ca63          	bltz	a5,80005664 <sys_fstat+0x3e>
  return filestat(f, st);
    80005654:	fe043583          	ld	a1,-32(s0)
    80005658:	fe843503          	ld	a0,-24(s0)
    8000565c:	fffff097          	auipc	ra,0xfffff
    80005660:	2de080e7          	jalr	734(ra) # 8000493a <filestat>
}
    80005664:	60e2                	ld	ra,24(sp)
    80005666:	6442                	ld	s0,16(sp)
    80005668:	6105                	addi	sp,sp,32
    8000566a:	8082                	ret

000000008000566c <sys_link>:
{
    8000566c:	7169                	addi	sp,sp,-304
    8000566e:	f606                	sd	ra,296(sp)
    80005670:	f222                	sd	s0,288(sp)
    80005672:	ee26                	sd	s1,280(sp)
    80005674:	ea4a                	sd	s2,272(sp)
    80005676:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005678:	08000613          	li	a2,128
    8000567c:	ed040593          	addi	a1,s0,-304
    80005680:	4501                	li	a0,0
    80005682:	ffffd097          	auipc	ra,0xffffd
    80005686:	6f8080e7          	jalr	1784(ra) # 80002d7a <argstr>
    return -1;
    8000568a:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000568c:	10054e63          	bltz	a0,800057a8 <sys_link+0x13c>
    80005690:	08000613          	li	a2,128
    80005694:	f5040593          	addi	a1,s0,-176
    80005698:	4505                	li	a0,1
    8000569a:	ffffd097          	auipc	ra,0xffffd
    8000569e:	6e0080e7          	jalr	1760(ra) # 80002d7a <argstr>
    return -1;
    800056a2:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056a4:	10054263          	bltz	a0,800057a8 <sys_link+0x13c>
  begin_op();
    800056a8:	fffff097          	auipc	ra,0xfffff
    800056ac:	d02080e7          	jalr	-766(ra) # 800043aa <begin_op>
  if ((ip = namei(old)) == 0)
    800056b0:	ed040513          	addi	a0,s0,-304
    800056b4:	fffff097          	auipc	ra,0xfffff
    800056b8:	ad6080e7          	jalr	-1322(ra) # 8000418a <namei>
    800056bc:	84aa                	mv	s1,a0
    800056be:	c551                	beqz	a0,8000574a <sys_link+0xde>
  ilock(ip);
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	31e080e7          	jalr	798(ra) # 800039de <ilock>
  if (ip->type == T_DIR)
    800056c8:	04449703          	lh	a4,68(s1)
    800056cc:	4785                	li	a5,1
    800056ce:	08f70463          	beq	a4,a5,80005756 <sys_link+0xea>
  ip->nlink++;
    800056d2:	04a4d783          	lhu	a5,74(s1)
    800056d6:	2785                	addiw	a5,a5,1
    800056d8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056dc:	8526                	mv	a0,s1
    800056de:	ffffe097          	auipc	ra,0xffffe
    800056e2:	234080e7          	jalr	564(ra) # 80003912 <iupdate>
  iunlock(ip);
    800056e6:	8526                	mv	a0,s1
    800056e8:	ffffe097          	auipc	ra,0xffffe
    800056ec:	3b8080e7          	jalr	952(ra) # 80003aa0 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800056f0:	fd040593          	addi	a1,s0,-48
    800056f4:	f5040513          	addi	a0,s0,-176
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	ab0080e7          	jalr	-1360(ra) # 800041a8 <nameiparent>
    80005700:	892a                	mv	s2,a0
    80005702:	c935                	beqz	a0,80005776 <sys_link+0x10a>
  ilock(dp);
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	2da080e7          	jalr	730(ra) # 800039de <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0)
    8000570c:	00092703          	lw	a4,0(s2)
    80005710:	409c                	lw	a5,0(s1)
    80005712:	04f71d63          	bne	a4,a5,8000576c <sys_link+0x100>
    80005716:	40d0                	lw	a2,4(s1)
    80005718:	fd040593          	addi	a1,s0,-48
    8000571c:	854a                	mv	a0,s2
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	9ba080e7          	jalr	-1606(ra) # 800040d8 <dirlink>
    80005726:	04054363          	bltz	a0,8000576c <sys_link+0x100>
  iunlockput(dp);
    8000572a:	854a                	mv	a0,s2
    8000572c:	ffffe097          	auipc	ra,0xffffe
    80005730:	514080e7          	jalr	1300(ra) # 80003c40 <iunlockput>
  iput(ip);
    80005734:	8526                	mv	a0,s1
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	462080e7          	jalr	1122(ra) # 80003b98 <iput>
  end_op();
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	cea080e7          	jalr	-790(ra) # 80004428 <end_op>
  return 0;
    80005746:	4781                	li	a5,0
    80005748:	a085                	j	800057a8 <sys_link+0x13c>
    end_op();
    8000574a:	fffff097          	auipc	ra,0xfffff
    8000574e:	cde080e7          	jalr	-802(ra) # 80004428 <end_op>
    return -1;
    80005752:	57fd                	li	a5,-1
    80005754:	a891                	j	800057a8 <sys_link+0x13c>
    iunlockput(ip);
    80005756:	8526                	mv	a0,s1
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	4e8080e7          	jalr	1256(ra) # 80003c40 <iunlockput>
    end_op();
    80005760:	fffff097          	auipc	ra,0xfffff
    80005764:	cc8080e7          	jalr	-824(ra) # 80004428 <end_op>
    return -1;
    80005768:	57fd                	li	a5,-1
    8000576a:	a83d                	j	800057a8 <sys_link+0x13c>
    iunlockput(dp);
    8000576c:	854a                	mv	a0,s2
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	4d2080e7          	jalr	1234(ra) # 80003c40 <iunlockput>
  ilock(ip);
    80005776:	8526                	mv	a0,s1
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	266080e7          	jalr	614(ra) # 800039de <ilock>
  ip->nlink--;
    80005780:	04a4d783          	lhu	a5,74(s1)
    80005784:	37fd                	addiw	a5,a5,-1
    80005786:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000578a:	8526                	mv	a0,s1
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	186080e7          	jalr	390(ra) # 80003912 <iupdate>
  iunlockput(ip);
    80005794:	8526                	mv	a0,s1
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	4aa080e7          	jalr	1194(ra) # 80003c40 <iunlockput>
  end_op();
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	c8a080e7          	jalr	-886(ra) # 80004428 <end_op>
  return -1;
    800057a6:	57fd                	li	a5,-1
}
    800057a8:	853e                	mv	a0,a5
    800057aa:	70b2                	ld	ra,296(sp)
    800057ac:	7412                	ld	s0,288(sp)
    800057ae:	64f2                	ld	s1,280(sp)
    800057b0:	6952                	ld	s2,272(sp)
    800057b2:	6155                	addi	sp,sp,304
    800057b4:	8082                	ret

00000000800057b6 <sys_unlink>:
{
    800057b6:	7151                	addi	sp,sp,-240
    800057b8:	f586                	sd	ra,232(sp)
    800057ba:	f1a2                	sd	s0,224(sp)
    800057bc:	eda6                	sd	s1,216(sp)
    800057be:	e9ca                	sd	s2,208(sp)
    800057c0:	e5ce                	sd	s3,200(sp)
    800057c2:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800057c4:	08000613          	li	a2,128
    800057c8:	f3040593          	addi	a1,s0,-208
    800057cc:	4501                	li	a0,0
    800057ce:	ffffd097          	auipc	ra,0xffffd
    800057d2:	5ac080e7          	jalr	1452(ra) # 80002d7a <argstr>
    800057d6:	18054163          	bltz	a0,80005958 <sys_unlink+0x1a2>
  begin_op();
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	bd0080e7          	jalr	-1072(ra) # 800043aa <begin_op>
  if ((dp = nameiparent(path, name)) == 0)
    800057e2:	fb040593          	addi	a1,s0,-80
    800057e6:	f3040513          	addi	a0,s0,-208
    800057ea:	fffff097          	auipc	ra,0xfffff
    800057ee:	9be080e7          	jalr	-1602(ra) # 800041a8 <nameiparent>
    800057f2:	84aa                	mv	s1,a0
    800057f4:	c979                	beqz	a0,800058ca <sys_unlink+0x114>
  ilock(dp);
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	1e8080e7          	jalr	488(ra) # 800039de <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057fe:	00003597          	auipc	a1,0x3
    80005802:	f1258593          	addi	a1,a1,-238 # 80008710 <syscalls+0x2b8>
    80005806:	fb040513          	addi	a0,s0,-80
    8000580a:	ffffe097          	auipc	ra,0xffffe
    8000580e:	69e080e7          	jalr	1694(ra) # 80003ea8 <namecmp>
    80005812:	14050a63          	beqz	a0,80005966 <sys_unlink+0x1b0>
    80005816:	00003597          	auipc	a1,0x3
    8000581a:	f0258593          	addi	a1,a1,-254 # 80008718 <syscalls+0x2c0>
    8000581e:	fb040513          	addi	a0,s0,-80
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	686080e7          	jalr	1670(ra) # 80003ea8 <namecmp>
    8000582a:	12050e63          	beqz	a0,80005966 <sys_unlink+0x1b0>
  if ((ip = dirlookup(dp, name, &off)) == 0)
    8000582e:	f2c40613          	addi	a2,s0,-212
    80005832:	fb040593          	addi	a1,s0,-80
    80005836:	8526                	mv	a0,s1
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	68a080e7          	jalr	1674(ra) # 80003ec2 <dirlookup>
    80005840:	892a                	mv	s2,a0
    80005842:	12050263          	beqz	a0,80005966 <sys_unlink+0x1b0>
  ilock(ip);
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	198080e7          	jalr	408(ra) # 800039de <ilock>
  if (ip->nlink < 1)
    8000584e:	04a91783          	lh	a5,74(s2)
    80005852:	08f05263          	blez	a5,800058d6 <sys_unlink+0x120>
  if (ip->type == T_DIR && !isdirempty(ip))
    80005856:	04491703          	lh	a4,68(s2)
    8000585a:	4785                	li	a5,1
    8000585c:	08f70563          	beq	a4,a5,800058e6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005860:	4641                	li	a2,16
    80005862:	4581                	li	a1,0
    80005864:	fc040513          	addi	a0,s0,-64
    80005868:	ffffb097          	auipc	ra,0xffffb
    8000586c:	46a080e7          	jalr	1130(ra) # 80000cd2 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005870:	4741                	li	a4,16
    80005872:	f2c42683          	lw	a3,-212(s0)
    80005876:	fc040613          	addi	a2,s0,-64
    8000587a:	4581                	li	a1,0
    8000587c:	8526                	mv	a0,s1
    8000587e:	ffffe097          	auipc	ra,0xffffe
    80005882:	50c080e7          	jalr	1292(ra) # 80003d8a <writei>
    80005886:	47c1                	li	a5,16
    80005888:	0af51563          	bne	a0,a5,80005932 <sys_unlink+0x17c>
  if (ip->type == T_DIR)
    8000588c:	04491703          	lh	a4,68(s2)
    80005890:	4785                	li	a5,1
    80005892:	0af70863          	beq	a4,a5,80005942 <sys_unlink+0x18c>
  iunlockput(dp);
    80005896:	8526                	mv	a0,s1
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	3a8080e7          	jalr	936(ra) # 80003c40 <iunlockput>
  ip->nlink--;
    800058a0:	04a95783          	lhu	a5,74(s2)
    800058a4:	37fd                	addiw	a5,a5,-1
    800058a6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058aa:	854a                	mv	a0,s2
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	066080e7          	jalr	102(ra) # 80003912 <iupdate>
  iunlockput(ip);
    800058b4:	854a                	mv	a0,s2
    800058b6:	ffffe097          	auipc	ra,0xffffe
    800058ba:	38a080e7          	jalr	906(ra) # 80003c40 <iunlockput>
  end_op();
    800058be:	fffff097          	auipc	ra,0xfffff
    800058c2:	b6a080e7          	jalr	-1174(ra) # 80004428 <end_op>
  return 0;
    800058c6:	4501                	li	a0,0
    800058c8:	a84d                	j	8000597a <sys_unlink+0x1c4>
    end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	b5e080e7          	jalr	-1186(ra) # 80004428 <end_op>
    return -1;
    800058d2:	557d                	li	a0,-1
    800058d4:	a05d                	j	8000597a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800058d6:	00003517          	auipc	a0,0x3
    800058da:	e4a50513          	addi	a0,a0,-438 # 80008720 <syscalls+0x2c8>
    800058de:	ffffb097          	auipc	ra,0xffffb
    800058e2:	c62080e7          	jalr	-926(ra) # 80000540 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    800058e6:	04c92703          	lw	a4,76(s2)
    800058ea:	02000793          	li	a5,32
    800058ee:	f6e7f9e3          	bgeu	a5,a4,80005860 <sys_unlink+0xaa>
    800058f2:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058f6:	4741                	li	a4,16
    800058f8:	86ce                	mv	a3,s3
    800058fa:	f1840613          	addi	a2,s0,-232
    800058fe:	4581                	li	a1,0
    80005900:	854a                	mv	a0,s2
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	390080e7          	jalr	912(ra) # 80003c92 <readi>
    8000590a:	47c1                	li	a5,16
    8000590c:	00f51b63          	bne	a0,a5,80005922 <sys_unlink+0x16c>
    if (de.inum != 0)
    80005910:	f1845783          	lhu	a5,-232(s0)
    80005914:	e7a1                	bnez	a5,8000595c <sys_unlink+0x1a6>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005916:	29c1                	addiw	s3,s3,16
    80005918:	04c92783          	lw	a5,76(s2)
    8000591c:	fcf9ede3          	bltu	s3,a5,800058f6 <sys_unlink+0x140>
    80005920:	b781                	j	80005860 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005922:	00003517          	auipc	a0,0x3
    80005926:	e1650513          	addi	a0,a0,-490 # 80008738 <syscalls+0x2e0>
    8000592a:	ffffb097          	auipc	ra,0xffffb
    8000592e:	c16080e7          	jalr	-1002(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005932:	00003517          	auipc	a0,0x3
    80005936:	e1e50513          	addi	a0,a0,-482 # 80008750 <syscalls+0x2f8>
    8000593a:	ffffb097          	auipc	ra,0xffffb
    8000593e:	c06080e7          	jalr	-1018(ra) # 80000540 <panic>
    dp->nlink--;
    80005942:	04a4d783          	lhu	a5,74(s1)
    80005946:	37fd                	addiw	a5,a5,-1
    80005948:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000594c:	8526                	mv	a0,s1
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	fc4080e7          	jalr	-60(ra) # 80003912 <iupdate>
    80005956:	b781                	j	80005896 <sys_unlink+0xe0>
    return -1;
    80005958:	557d                	li	a0,-1
    8000595a:	a005                	j	8000597a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000595c:	854a                	mv	a0,s2
    8000595e:	ffffe097          	auipc	ra,0xffffe
    80005962:	2e2080e7          	jalr	738(ra) # 80003c40 <iunlockput>
  iunlockput(dp);
    80005966:	8526                	mv	a0,s1
    80005968:	ffffe097          	auipc	ra,0xffffe
    8000596c:	2d8080e7          	jalr	728(ra) # 80003c40 <iunlockput>
  end_op();
    80005970:	fffff097          	auipc	ra,0xfffff
    80005974:	ab8080e7          	jalr	-1352(ra) # 80004428 <end_op>
  return -1;
    80005978:	557d                	li	a0,-1
}
    8000597a:	70ae                	ld	ra,232(sp)
    8000597c:	740e                	ld	s0,224(sp)
    8000597e:	64ee                	ld	s1,216(sp)
    80005980:	694e                	ld	s2,208(sp)
    80005982:	69ae                	ld	s3,200(sp)
    80005984:	616d                	addi	sp,sp,240
    80005986:	8082                	ret

0000000080005988 <sys_open>:

uint64
sys_open(void)
{
    80005988:	7131                	addi	sp,sp,-192
    8000598a:	fd06                	sd	ra,184(sp)
    8000598c:	f922                	sd	s0,176(sp)
    8000598e:	f526                	sd	s1,168(sp)
    80005990:	f14a                	sd	s2,160(sp)
    80005992:	ed4e                	sd	s3,152(sp)
    80005994:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005996:	f4c40593          	addi	a1,s0,-180
    8000599a:	4505                	li	a0,1
    8000599c:	ffffd097          	auipc	ra,0xffffd
    800059a0:	39e080e7          	jalr	926(ra) # 80002d3a <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800059a4:	08000613          	li	a2,128
    800059a8:	f5040593          	addi	a1,s0,-176
    800059ac:	4501                	li	a0,0
    800059ae:	ffffd097          	auipc	ra,0xffffd
    800059b2:	3cc080e7          	jalr	972(ra) # 80002d7a <argstr>
    800059b6:	87aa                	mv	a5,a0
    return -1;
    800059b8:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800059ba:	0a07c963          	bltz	a5,80005a6c <sys_open+0xe4>

  begin_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	9ec080e7          	jalr	-1556(ra) # 800043aa <begin_op>

  if (omode & O_CREATE)
    800059c6:	f4c42783          	lw	a5,-180(s0)
    800059ca:	2007f793          	andi	a5,a5,512
    800059ce:	cfc5                	beqz	a5,80005a86 <sys_open+0xfe>
  {
    ip = create(path, T_FILE, 0, 0);
    800059d0:	4681                	li	a3,0
    800059d2:	4601                	li	a2,0
    800059d4:	4589                	li	a1,2
    800059d6:	f5040513          	addi	a0,s0,-176
    800059da:	00000097          	auipc	ra,0x0
    800059de:	972080e7          	jalr	-1678(ra) # 8000534c <create>
    800059e2:	84aa                	mv	s1,a0
    if (ip == 0)
    800059e4:	c959                	beqz	a0,80005a7a <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV))
    800059e6:	04449703          	lh	a4,68(s1)
    800059ea:	478d                	li	a5,3
    800059ec:	00f71763          	bne	a4,a5,800059fa <sys_open+0x72>
    800059f0:	0464d703          	lhu	a4,70(s1)
    800059f4:	47a5                	li	a5,9
    800059f6:	0ce7ed63          	bltu	a5,a4,80005ad0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0)
    800059fa:	fffff097          	auipc	ra,0xfffff
    800059fe:	dbc080e7          	jalr	-580(ra) # 800047b6 <filealloc>
    80005a02:	89aa                	mv	s3,a0
    80005a04:	10050363          	beqz	a0,80005b0a <sys_open+0x182>
    80005a08:	00000097          	auipc	ra,0x0
    80005a0c:	902080e7          	jalr	-1790(ra) # 8000530a <fdalloc>
    80005a10:	892a                	mv	s2,a0
    80005a12:	0e054763          	bltz	a0,80005b00 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE)
    80005a16:	04449703          	lh	a4,68(s1)
    80005a1a:	478d                	li	a5,3
    80005a1c:	0cf70563          	beq	a4,a5,80005ae6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  }
  else
  {
    f->type = FD_INODE;
    80005a20:	4789                	li	a5,2
    80005a22:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a26:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a2a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a2e:	f4c42783          	lw	a5,-180(s0)
    80005a32:	0017c713          	xori	a4,a5,1
    80005a36:	8b05                	andi	a4,a4,1
    80005a38:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a3c:	0037f713          	andi	a4,a5,3
    80005a40:	00e03733          	snez	a4,a4
    80005a44:	00e984a3          	sb	a4,9(s3)

  if ((omode & O_TRUNC) && ip->type == T_FILE)
    80005a48:	4007f793          	andi	a5,a5,1024
    80005a4c:	c791                	beqz	a5,80005a58 <sys_open+0xd0>
    80005a4e:	04449703          	lh	a4,68(s1)
    80005a52:	4789                	li	a5,2
    80005a54:	0af70063          	beq	a4,a5,80005af4 <sys_open+0x16c>
  {
    itrunc(ip);
  }

  iunlock(ip);
    80005a58:	8526                	mv	a0,s1
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	046080e7          	jalr	70(ra) # 80003aa0 <iunlock>
  end_op();
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	9c6080e7          	jalr	-1594(ra) # 80004428 <end_op>

  return fd;
    80005a6a:	854a                	mv	a0,s2
}
    80005a6c:	70ea                	ld	ra,184(sp)
    80005a6e:	744a                	ld	s0,176(sp)
    80005a70:	74aa                	ld	s1,168(sp)
    80005a72:	790a                	ld	s2,160(sp)
    80005a74:	69ea                	ld	s3,152(sp)
    80005a76:	6129                	addi	sp,sp,192
    80005a78:	8082                	ret
      end_op();
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	9ae080e7          	jalr	-1618(ra) # 80004428 <end_op>
      return -1;
    80005a82:	557d                	li	a0,-1
    80005a84:	b7e5                	j	80005a6c <sys_open+0xe4>
    if ((ip = namei(path)) == 0)
    80005a86:	f5040513          	addi	a0,s0,-176
    80005a8a:	ffffe097          	auipc	ra,0xffffe
    80005a8e:	700080e7          	jalr	1792(ra) # 8000418a <namei>
    80005a92:	84aa                	mv	s1,a0
    80005a94:	c905                	beqz	a0,80005ac4 <sys_open+0x13c>
    ilock(ip);
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	f48080e7          	jalr	-184(ra) # 800039de <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY)
    80005a9e:	04449703          	lh	a4,68(s1)
    80005aa2:	4785                	li	a5,1
    80005aa4:	f4f711e3          	bne	a4,a5,800059e6 <sys_open+0x5e>
    80005aa8:	f4c42783          	lw	a5,-180(s0)
    80005aac:	d7b9                	beqz	a5,800059fa <sys_open+0x72>
      iunlockput(ip);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	190080e7          	jalr	400(ra) # 80003c40 <iunlockput>
      end_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	970080e7          	jalr	-1680(ra) # 80004428 <end_op>
      return -1;
    80005ac0:	557d                	li	a0,-1
    80005ac2:	b76d                	j	80005a6c <sys_open+0xe4>
      end_op();
    80005ac4:	fffff097          	auipc	ra,0xfffff
    80005ac8:	964080e7          	jalr	-1692(ra) # 80004428 <end_op>
      return -1;
    80005acc:	557d                	li	a0,-1
    80005ace:	bf79                	j	80005a6c <sys_open+0xe4>
    iunlockput(ip);
    80005ad0:	8526                	mv	a0,s1
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	16e080e7          	jalr	366(ra) # 80003c40 <iunlockput>
    end_op();
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	94e080e7          	jalr	-1714(ra) # 80004428 <end_op>
    return -1;
    80005ae2:	557d                	li	a0,-1
    80005ae4:	b761                	j	80005a6c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ae6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005aea:	04649783          	lh	a5,70(s1)
    80005aee:	02f99223          	sh	a5,36(s3)
    80005af2:	bf25                	j	80005a2a <sys_open+0xa2>
    itrunc(ip);
    80005af4:	8526                	mv	a0,s1
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	ff6080e7          	jalr	-10(ra) # 80003aec <itrunc>
    80005afe:	bfa9                	j	80005a58 <sys_open+0xd0>
      fileclose(f);
    80005b00:	854e                	mv	a0,s3
    80005b02:	fffff097          	auipc	ra,0xfffff
    80005b06:	d70080e7          	jalr	-656(ra) # 80004872 <fileclose>
    iunlockput(ip);
    80005b0a:	8526                	mv	a0,s1
    80005b0c:	ffffe097          	auipc	ra,0xffffe
    80005b10:	134080e7          	jalr	308(ra) # 80003c40 <iunlockput>
    end_op();
    80005b14:	fffff097          	auipc	ra,0xfffff
    80005b18:	914080e7          	jalr	-1772(ra) # 80004428 <end_op>
    return -1;
    80005b1c:	557d                	li	a0,-1
    80005b1e:	b7b9                	j	80005a6c <sys_open+0xe4>

0000000080005b20 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b20:	7175                	addi	sp,sp,-144
    80005b22:	e506                	sd	ra,136(sp)
    80005b24:	e122                	sd	s0,128(sp)
    80005b26:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b28:	fffff097          	auipc	ra,0xfffff
    80005b2c:	882080e7          	jalr	-1918(ra) # 800043aa <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
    80005b30:	08000613          	li	a2,128
    80005b34:	f7040593          	addi	a1,s0,-144
    80005b38:	4501                	li	a0,0
    80005b3a:	ffffd097          	auipc	ra,0xffffd
    80005b3e:	240080e7          	jalr	576(ra) # 80002d7a <argstr>
    80005b42:	02054963          	bltz	a0,80005b74 <sys_mkdir+0x54>
    80005b46:	4681                	li	a3,0
    80005b48:	4601                	li	a2,0
    80005b4a:	4585                	li	a1,1
    80005b4c:	f7040513          	addi	a0,s0,-144
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	7fc080e7          	jalr	2044(ra) # 8000534c <create>
    80005b58:	cd11                	beqz	a0,80005b74 <sys_mkdir+0x54>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	0e6080e7          	jalr	230(ra) # 80003c40 <iunlockput>
  end_op();
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	8c6080e7          	jalr	-1850(ra) # 80004428 <end_op>
  return 0;
    80005b6a:	4501                	li	a0,0
}
    80005b6c:	60aa                	ld	ra,136(sp)
    80005b6e:	640a                	ld	s0,128(sp)
    80005b70:	6149                	addi	sp,sp,144
    80005b72:	8082                	ret
    end_op();
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	8b4080e7          	jalr	-1868(ra) # 80004428 <end_op>
    return -1;
    80005b7c:	557d                	li	a0,-1
    80005b7e:	b7fd                	j	80005b6c <sys_mkdir+0x4c>

0000000080005b80 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b80:	7135                	addi	sp,sp,-160
    80005b82:	ed06                	sd	ra,152(sp)
    80005b84:	e922                	sd	s0,144(sp)
    80005b86:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b88:	fffff097          	auipc	ra,0xfffff
    80005b8c:	822080e7          	jalr	-2014(ra) # 800043aa <begin_op>
  argint(1, &major);
    80005b90:	f6c40593          	addi	a1,s0,-148
    80005b94:	4505                	li	a0,1
    80005b96:	ffffd097          	auipc	ra,0xffffd
    80005b9a:	1a4080e7          	jalr	420(ra) # 80002d3a <argint>
  argint(2, &minor);
    80005b9e:	f6840593          	addi	a1,s0,-152
    80005ba2:	4509                	li	a0,2
    80005ba4:	ffffd097          	auipc	ra,0xffffd
    80005ba8:	196080e7          	jalr	406(ra) # 80002d3a <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005bac:	08000613          	li	a2,128
    80005bb0:	f7040593          	addi	a1,s0,-144
    80005bb4:	4501                	li	a0,0
    80005bb6:	ffffd097          	auipc	ra,0xffffd
    80005bba:	1c4080e7          	jalr	452(ra) # 80002d7a <argstr>
    80005bbe:	02054b63          	bltz	a0,80005bf4 <sys_mknod+0x74>
      (ip = create(path, T_DEVICE, major, minor)) == 0)
    80005bc2:	f6841683          	lh	a3,-152(s0)
    80005bc6:	f6c41603          	lh	a2,-148(s0)
    80005bca:	458d                	li	a1,3
    80005bcc:	f7040513          	addi	a0,s0,-144
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	77c080e7          	jalr	1916(ra) # 8000534c <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005bd8:	cd11                	beqz	a0,80005bf4 <sys_mknod+0x74>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	066080e7          	jalr	102(ra) # 80003c40 <iunlockput>
  end_op();
    80005be2:	fffff097          	auipc	ra,0xfffff
    80005be6:	846080e7          	jalr	-1978(ra) # 80004428 <end_op>
  return 0;
    80005bea:	4501                	li	a0,0
}
    80005bec:	60ea                	ld	ra,152(sp)
    80005bee:	644a                	ld	s0,144(sp)
    80005bf0:	610d                	addi	sp,sp,160
    80005bf2:	8082                	ret
    end_op();
    80005bf4:	fffff097          	auipc	ra,0xfffff
    80005bf8:	834080e7          	jalr	-1996(ra) # 80004428 <end_op>
    return -1;
    80005bfc:	557d                	li	a0,-1
    80005bfe:	b7fd                	j	80005bec <sys_mknod+0x6c>

0000000080005c00 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c00:	7135                	addi	sp,sp,-160
    80005c02:	ed06                	sd	ra,152(sp)
    80005c04:	e922                	sd	s0,144(sp)
    80005c06:	e526                	sd	s1,136(sp)
    80005c08:	e14a                	sd	s2,128(sp)
    80005c0a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c0c:	ffffc097          	auipc	ra,0xffffc
    80005c10:	da0080e7          	jalr	-608(ra) # 800019ac <myproc>
    80005c14:	892a                	mv	s2,a0

  begin_op();
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	794080e7          	jalr	1940(ra) # 800043aa <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0)
    80005c1e:	08000613          	li	a2,128
    80005c22:	f6040593          	addi	a1,s0,-160
    80005c26:	4501                	li	a0,0
    80005c28:	ffffd097          	auipc	ra,0xffffd
    80005c2c:	152080e7          	jalr	338(ra) # 80002d7a <argstr>
    80005c30:	04054b63          	bltz	a0,80005c86 <sys_chdir+0x86>
    80005c34:	f6040513          	addi	a0,s0,-160
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	552080e7          	jalr	1362(ra) # 8000418a <namei>
    80005c40:	84aa                	mv	s1,a0
    80005c42:	c131                	beqz	a0,80005c86 <sys_chdir+0x86>
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005c44:	ffffe097          	auipc	ra,0xffffe
    80005c48:	d9a080e7          	jalr	-614(ra) # 800039de <ilock>
  if (ip->type != T_DIR)
    80005c4c:	04449703          	lh	a4,68(s1)
    80005c50:	4785                	li	a5,1
    80005c52:	04f71063          	bne	a4,a5,80005c92 <sys_chdir+0x92>
  {
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c56:	8526                	mv	a0,s1
    80005c58:	ffffe097          	auipc	ra,0xffffe
    80005c5c:	e48080e7          	jalr	-440(ra) # 80003aa0 <iunlock>
  iput(p->cwd);
    80005c60:	15093503          	ld	a0,336(s2)
    80005c64:	ffffe097          	auipc	ra,0xffffe
    80005c68:	f34080e7          	jalr	-204(ra) # 80003b98 <iput>
  end_op();
    80005c6c:	ffffe097          	auipc	ra,0xffffe
    80005c70:	7bc080e7          	jalr	1980(ra) # 80004428 <end_op>
  p->cwd = ip;
    80005c74:	14993823          	sd	s1,336(s2)
  return 0;
    80005c78:	4501                	li	a0,0
}
    80005c7a:	60ea                	ld	ra,152(sp)
    80005c7c:	644a                	ld	s0,144(sp)
    80005c7e:	64aa                	ld	s1,136(sp)
    80005c80:	690a                	ld	s2,128(sp)
    80005c82:	610d                	addi	sp,sp,160
    80005c84:	8082                	ret
    end_op();
    80005c86:	ffffe097          	auipc	ra,0xffffe
    80005c8a:	7a2080e7          	jalr	1954(ra) # 80004428 <end_op>
    return -1;
    80005c8e:	557d                	li	a0,-1
    80005c90:	b7ed                	j	80005c7a <sys_chdir+0x7a>
    iunlockput(ip);
    80005c92:	8526                	mv	a0,s1
    80005c94:	ffffe097          	auipc	ra,0xffffe
    80005c98:	fac080e7          	jalr	-84(ra) # 80003c40 <iunlockput>
    end_op();
    80005c9c:	ffffe097          	auipc	ra,0xffffe
    80005ca0:	78c080e7          	jalr	1932(ra) # 80004428 <end_op>
    return -1;
    80005ca4:	557d                	li	a0,-1
    80005ca6:	bfd1                	j	80005c7a <sys_chdir+0x7a>

0000000080005ca8 <sys_exec>:

uint64
sys_exec(void)
{
    80005ca8:	7145                	addi	sp,sp,-464
    80005caa:	e786                	sd	ra,456(sp)
    80005cac:	e3a2                	sd	s0,448(sp)
    80005cae:	ff26                	sd	s1,440(sp)
    80005cb0:	fb4a                	sd	s2,432(sp)
    80005cb2:	f74e                	sd	s3,424(sp)
    80005cb4:	f352                	sd	s4,416(sp)
    80005cb6:	ef56                	sd	s5,408(sp)
    80005cb8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cba:	e3840593          	addi	a1,s0,-456
    80005cbe:	4505                	li	a0,1
    80005cc0:	ffffd097          	auipc	ra,0xffffd
    80005cc4:	09a080e7          	jalr	154(ra) # 80002d5a <argaddr>
  if (argstr(0, path, MAXPATH) < 0)
    80005cc8:	08000613          	li	a2,128
    80005ccc:	f4040593          	addi	a1,s0,-192
    80005cd0:	4501                	li	a0,0
    80005cd2:	ffffd097          	auipc	ra,0xffffd
    80005cd6:	0a8080e7          	jalr	168(ra) # 80002d7a <argstr>
    80005cda:	87aa                	mv	a5,a0
  {
    return -1;
    80005cdc:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0)
    80005cde:	0c07c363          	bltz	a5,80005da4 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005ce2:	10000613          	li	a2,256
    80005ce6:	4581                	li	a1,0
    80005ce8:	e4040513          	addi	a0,s0,-448
    80005cec:	ffffb097          	auipc	ra,0xffffb
    80005cf0:	fe6080e7          	jalr	-26(ra) # 80000cd2 <memset>
  for (i = 0;; i++)
  {
    if (i >= NELEM(argv))
    80005cf4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005cf8:	89a6                	mv	s3,s1
    80005cfa:	4901                	li	s2,0
    if (i >= NELEM(argv))
    80005cfc:	02000a13          	li	s4,32
    80005d00:	00090a9b          	sext.w	s5,s2
    {
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0)
    80005d04:	00391513          	slli	a0,s2,0x3
    80005d08:	e3040593          	addi	a1,s0,-464
    80005d0c:	e3843783          	ld	a5,-456(s0)
    80005d10:	953e                	add	a0,a0,a5
    80005d12:	ffffd097          	auipc	ra,0xffffd
    80005d16:	f8a080e7          	jalr	-118(ra) # 80002c9c <fetchaddr>
    80005d1a:	02054a63          	bltz	a0,80005d4e <sys_exec+0xa6>
    {
      goto bad;
    }
    if (uarg == 0)
    80005d1e:	e3043783          	ld	a5,-464(s0)
    80005d22:	c3b9                	beqz	a5,80005d68 <sys_exec+0xc0>
    {
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d24:	ffffb097          	auipc	ra,0xffffb
    80005d28:	dc2080e7          	jalr	-574(ra) # 80000ae6 <kalloc>
    80005d2c:	85aa                	mv	a1,a0
    80005d2e:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005d32:	cd11                	beqz	a0,80005d4e <sys_exec+0xa6>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d34:	6605                	lui	a2,0x1
    80005d36:	e3043503          	ld	a0,-464(s0)
    80005d3a:	ffffd097          	auipc	ra,0xffffd
    80005d3e:	fb4080e7          	jalr	-76(ra) # 80002cee <fetchstr>
    80005d42:	00054663          	bltz	a0,80005d4e <sys_exec+0xa6>
    if (i >= NELEM(argv))
    80005d46:	0905                	addi	s2,s2,1
    80005d48:	09a1                	addi	s3,s3,8
    80005d4a:	fb491be3          	bne	s2,s4,80005d00 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d4e:	f4040913          	addi	s2,s0,-192
    80005d52:	6088                	ld	a0,0(s1)
    80005d54:	c539                	beqz	a0,80005da2 <sys_exec+0xfa>
    kfree(argv[i]);
    80005d56:	ffffb097          	auipc	ra,0xffffb
    80005d5a:	c92080e7          	jalr	-878(ra) # 800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d5e:	04a1                	addi	s1,s1,8
    80005d60:	ff2499e3          	bne	s1,s2,80005d52 <sys_exec+0xaa>
  return -1;
    80005d64:	557d                	li	a0,-1
    80005d66:	a83d                	j	80005da4 <sys_exec+0xfc>
      argv[i] = 0;
    80005d68:	0a8e                	slli	s5,s5,0x3
    80005d6a:	fc0a8793          	addi	a5,s5,-64
    80005d6e:	00878ab3          	add	s5,a5,s0
    80005d72:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d76:	e4040593          	addi	a1,s0,-448
    80005d7a:	f4040513          	addi	a0,s0,-192
    80005d7e:	fffff097          	auipc	ra,0xfffff
    80005d82:	16e080e7          	jalr	366(ra) # 80004eec <exec>
    80005d86:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d88:	f4040993          	addi	s3,s0,-192
    80005d8c:	6088                	ld	a0,0(s1)
    80005d8e:	c901                	beqz	a0,80005d9e <sys_exec+0xf6>
    kfree(argv[i]);
    80005d90:	ffffb097          	auipc	ra,0xffffb
    80005d94:	c58080e7          	jalr	-936(ra) # 800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d98:	04a1                	addi	s1,s1,8
    80005d9a:	ff3499e3          	bne	s1,s3,80005d8c <sys_exec+0xe4>
  return ret;
    80005d9e:	854a                	mv	a0,s2
    80005da0:	a011                	j	80005da4 <sys_exec+0xfc>
  return -1;
    80005da2:	557d                	li	a0,-1
}
    80005da4:	60be                	ld	ra,456(sp)
    80005da6:	641e                	ld	s0,448(sp)
    80005da8:	74fa                	ld	s1,440(sp)
    80005daa:	795a                	ld	s2,432(sp)
    80005dac:	79ba                	ld	s3,424(sp)
    80005dae:	7a1a                	ld	s4,416(sp)
    80005db0:	6afa                	ld	s5,408(sp)
    80005db2:	6179                	addi	sp,sp,464
    80005db4:	8082                	ret

0000000080005db6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005db6:	7139                	addi	sp,sp,-64
    80005db8:	fc06                	sd	ra,56(sp)
    80005dba:	f822                	sd	s0,48(sp)
    80005dbc:	f426                	sd	s1,40(sp)
    80005dbe:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dc0:	ffffc097          	auipc	ra,0xffffc
    80005dc4:	bec080e7          	jalr	-1044(ra) # 800019ac <myproc>
    80005dc8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005dca:	fd840593          	addi	a1,s0,-40
    80005dce:	4501                	li	a0,0
    80005dd0:	ffffd097          	auipc	ra,0xffffd
    80005dd4:	f8a080e7          	jalr	-118(ra) # 80002d5a <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005dd8:	fc840593          	addi	a1,s0,-56
    80005ddc:	fd040513          	addi	a0,s0,-48
    80005de0:	fffff097          	auipc	ra,0xfffff
    80005de4:	dc2080e7          	jalr	-574(ra) # 80004ba2 <pipealloc>
    return -1;
    80005de8:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005dea:	0c054463          	bltz	a0,80005eb2 <sys_pipe+0xfc>
  fd0 = -1;
    80005dee:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0)
    80005df2:	fd043503          	ld	a0,-48(s0)
    80005df6:	fffff097          	auipc	ra,0xfffff
    80005dfa:	514080e7          	jalr	1300(ra) # 8000530a <fdalloc>
    80005dfe:	fca42223          	sw	a0,-60(s0)
    80005e02:	08054b63          	bltz	a0,80005e98 <sys_pipe+0xe2>
    80005e06:	fc843503          	ld	a0,-56(s0)
    80005e0a:	fffff097          	auipc	ra,0xfffff
    80005e0e:	500080e7          	jalr	1280(ra) # 8000530a <fdalloc>
    80005e12:	fca42023          	sw	a0,-64(s0)
    80005e16:	06054863          	bltz	a0,80005e86 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005e1a:	4691                	li	a3,4
    80005e1c:	fc440613          	addi	a2,s0,-60
    80005e20:	fd843583          	ld	a1,-40(s0)
    80005e24:	68a8                	ld	a0,80(s1)
    80005e26:	ffffc097          	auipc	ra,0xffffc
    80005e2a:	846080e7          	jalr	-1978(ra) # 8000166c <copyout>
    80005e2e:	02054063          	bltz	a0,80005e4e <sys_pipe+0x98>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0)
    80005e32:	4691                	li	a3,4
    80005e34:	fc040613          	addi	a2,s0,-64
    80005e38:	fd843583          	ld	a1,-40(s0)
    80005e3c:	0591                	addi	a1,a1,4
    80005e3e:	68a8                	ld	a0,80(s1)
    80005e40:	ffffc097          	auipc	ra,0xffffc
    80005e44:	82c080e7          	jalr	-2004(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e48:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005e4a:	06055463          	bgez	a0,80005eb2 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005e4e:	fc442783          	lw	a5,-60(s0)
    80005e52:	07e9                	addi	a5,a5,26
    80005e54:	078e                	slli	a5,a5,0x3
    80005e56:	97a6                	add	a5,a5,s1
    80005e58:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e5c:	fc042783          	lw	a5,-64(s0)
    80005e60:	07e9                	addi	a5,a5,26
    80005e62:	078e                	slli	a5,a5,0x3
    80005e64:	94be                	add	s1,s1,a5
    80005e66:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e6a:	fd043503          	ld	a0,-48(s0)
    80005e6e:	fffff097          	auipc	ra,0xfffff
    80005e72:	a04080e7          	jalr	-1532(ra) # 80004872 <fileclose>
    fileclose(wf);
    80005e76:	fc843503          	ld	a0,-56(s0)
    80005e7a:	fffff097          	auipc	ra,0xfffff
    80005e7e:	9f8080e7          	jalr	-1544(ra) # 80004872 <fileclose>
    return -1;
    80005e82:	57fd                	li	a5,-1
    80005e84:	a03d                	j	80005eb2 <sys_pipe+0xfc>
    if (fd0 >= 0)
    80005e86:	fc442783          	lw	a5,-60(s0)
    80005e8a:	0007c763          	bltz	a5,80005e98 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005e8e:	07e9                	addi	a5,a5,26
    80005e90:	078e                	slli	a5,a5,0x3
    80005e92:	97a6                	add	a5,a5,s1
    80005e94:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e98:	fd043503          	ld	a0,-48(s0)
    80005e9c:	fffff097          	auipc	ra,0xfffff
    80005ea0:	9d6080e7          	jalr	-1578(ra) # 80004872 <fileclose>
    fileclose(wf);
    80005ea4:	fc843503          	ld	a0,-56(s0)
    80005ea8:	fffff097          	auipc	ra,0xfffff
    80005eac:	9ca080e7          	jalr	-1590(ra) # 80004872 <fileclose>
    return -1;
    80005eb0:	57fd                	li	a5,-1
}
    80005eb2:	853e                	mv	a0,a5
    80005eb4:	70e2                	ld	ra,56(sp)
    80005eb6:	7442                	ld	s0,48(sp)
    80005eb8:	74a2                	ld	s1,40(sp)
    80005eba:	6121                	addi	sp,sp,64
    80005ebc:	8082                	ret
	...

0000000080005ec0 <kernelvec>:
    80005ec0:	7111                	addi	sp,sp,-256
    80005ec2:	e006                	sd	ra,0(sp)
    80005ec4:	e40a                	sd	sp,8(sp)
    80005ec6:	e80e                	sd	gp,16(sp)
    80005ec8:	ec12                	sd	tp,24(sp)
    80005eca:	f016                	sd	t0,32(sp)
    80005ecc:	f41a                	sd	t1,40(sp)
    80005ece:	f81e                	sd	t2,48(sp)
    80005ed0:	fc22                	sd	s0,56(sp)
    80005ed2:	e0a6                	sd	s1,64(sp)
    80005ed4:	e4aa                	sd	a0,72(sp)
    80005ed6:	e8ae                	sd	a1,80(sp)
    80005ed8:	ecb2                	sd	a2,88(sp)
    80005eda:	f0b6                	sd	a3,96(sp)
    80005edc:	f4ba                	sd	a4,104(sp)
    80005ede:	f8be                	sd	a5,112(sp)
    80005ee0:	fcc2                	sd	a6,120(sp)
    80005ee2:	e146                	sd	a7,128(sp)
    80005ee4:	e54a                	sd	s2,136(sp)
    80005ee6:	e94e                	sd	s3,144(sp)
    80005ee8:	ed52                	sd	s4,152(sp)
    80005eea:	f156                	sd	s5,160(sp)
    80005eec:	f55a                	sd	s6,168(sp)
    80005eee:	f95e                	sd	s7,176(sp)
    80005ef0:	fd62                	sd	s8,184(sp)
    80005ef2:	e1e6                	sd	s9,192(sp)
    80005ef4:	e5ea                	sd	s10,200(sp)
    80005ef6:	e9ee                	sd	s11,208(sp)
    80005ef8:	edf2                	sd	t3,216(sp)
    80005efa:	f1f6                	sd	t4,224(sp)
    80005efc:	f5fa                	sd	t5,232(sp)
    80005efe:	f9fe                	sd	t6,240(sp)
    80005f00:	c69fc0ef          	jal	ra,80002b68 <kerneltrap>
    80005f04:	6082                	ld	ra,0(sp)
    80005f06:	6122                	ld	sp,8(sp)
    80005f08:	61c2                	ld	gp,16(sp)
    80005f0a:	7282                	ld	t0,32(sp)
    80005f0c:	7322                	ld	t1,40(sp)
    80005f0e:	73c2                	ld	t2,48(sp)
    80005f10:	7462                	ld	s0,56(sp)
    80005f12:	6486                	ld	s1,64(sp)
    80005f14:	6526                	ld	a0,72(sp)
    80005f16:	65c6                	ld	a1,80(sp)
    80005f18:	6666                	ld	a2,88(sp)
    80005f1a:	7686                	ld	a3,96(sp)
    80005f1c:	7726                	ld	a4,104(sp)
    80005f1e:	77c6                	ld	a5,112(sp)
    80005f20:	7866                	ld	a6,120(sp)
    80005f22:	688a                	ld	a7,128(sp)
    80005f24:	692a                	ld	s2,136(sp)
    80005f26:	69ca                	ld	s3,144(sp)
    80005f28:	6a6a                	ld	s4,152(sp)
    80005f2a:	7a8a                	ld	s5,160(sp)
    80005f2c:	7b2a                	ld	s6,168(sp)
    80005f2e:	7bca                	ld	s7,176(sp)
    80005f30:	7c6a                	ld	s8,184(sp)
    80005f32:	6c8e                	ld	s9,192(sp)
    80005f34:	6d2e                	ld	s10,200(sp)
    80005f36:	6dce                	ld	s11,208(sp)
    80005f38:	6e6e                	ld	t3,216(sp)
    80005f3a:	7e8e                	ld	t4,224(sp)
    80005f3c:	7f2e                	ld	t5,232(sp)
    80005f3e:	7fce                	ld	t6,240(sp)
    80005f40:	6111                	addi	sp,sp,256
    80005f42:	10200073          	sret
    80005f46:	00000013          	nop
    80005f4a:	00000013          	nop
    80005f4e:	0001                	nop

0000000080005f50 <timervec>:
    80005f50:	34051573          	csrrw	a0,mscratch,a0
    80005f54:	e10c                	sd	a1,0(a0)
    80005f56:	e510                	sd	a2,8(a0)
    80005f58:	e914                	sd	a3,16(a0)
    80005f5a:	6d0c                	ld	a1,24(a0)
    80005f5c:	7110                	ld	a2,32(a0)
    80005f5e:	6194                	ld	a3,0(a1)
    80005f60:	96b2                	add	a3,a3,a2
    80005f62:	e194                	sd	a3,0(a1)
    80005f64:	4589                	li	a1,2
    80005f66:	14459073          	csrw	sip,a1
    80005f6a:	6914                	ld	a3,16(a0)
    80005f6c:	6510                	ld	a2,8(a0)
    80005f6e:	610c                	ld	a1,0(a0)
    80005f70:	34051573          	csrrw	a0,mscratch,a0
    80005f74:	30200073          	mret
	...

0000000080005f7a <plicinit>:
//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void)
{
    80005f7a:	1141                	addi	sp,sp,-16
    80005f7c:	e422                	sd	s0,8(sp)
    80005f7e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005f80:	0c0007b7          	lui	a5,0xc000
    80005f84:	4705                	li	a4,1
    80005f86:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80005f88:	c3d8                	sw	a4,4(a5)
}
    80005f8a:	6422                	ld	s0,8(sp)
    80005f8c:	0141                	addi	sp,sp,16
    80005f8e:	8082                	ret

0000000080005f90 <plicinithart>:

void plicinithart(void)
{
    80005f90:	1141                	addi	sp,sp,-16
    80005f92:	e406                	sd	ra,8(sp)
    80005f94:	e022                	sd	s0,0(sp)
    80005f96:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f98:	ffffc097          	auipc	ra,0xffffc
    80005f9c:	9e8080e7          	jalr	-1560(ra) # 80001980 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fa0:	0085171b          	slliw	a4,a0,0x8
    80005fa4:	0c0027b7          	lui	a5,0xc002
    80005fa8:	97ba                	add	a5,a5,a4
    80005faa:	40200713          	li	a4,1026
    80005fae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005fb2:	00d5151b          	slliw	a0,a0,0xd
    80005fb6:	0c2017b7          	lui	a5,0xc201
    80005fba:	97aa                	add	a5,a5,a0
    80005fbc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005fc0:	60a2                	ld	ra,8(sp)
    80005fc2:	6402                	ld	s0,0(sp)
    80005fc4:	0141                	addi	sp,sp,16
    80005fc6:	8082                	ret

0000000080005fc8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void)
{
    80005fc8:	1141                	addi	sp,sp,-16
    80005fca:	e406                	sd	ra,8(sp)
    80005fcc:	e022                	sd	s0,0(sp)
    80005fce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fd0:	ffffc097          	auipc	ra,0xffffc
    80005fd4:	9b0080e7          	jalr	-1616(ra) # 80001980 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005fd8:	00d5151b          	slliw	a0,a0,0xd
    80005fdc:	0c2017b7          	lui	a5,0xc201
    80005fe0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005fe2:	43c8                	lw	a0,4(a5)
    80005fe4:	60a2                	ld	ra,8(sp)
    80005fe6:	6402                	ld	s0,0(sp)
    80005fe8:	0141                	addi	sp,sp,16
    80005fea:	8082                	ret

0000000080005fec <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq)
{
    80005fec:	1101                	addi	sp,sp,-32
    80005fee:	ec06                	sd	ra,24(sp)
    80005ff0:	e822                	sd	s0,16(sp)
    80005ff2:	e426                	sd	s1,8(sp)
    80005ff4:	1000                	addi	s0,sp,32
    80005ff6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ff8:	ffffc097          	auipc	ra,0xffffc
    80005ffc:	988080e7          	jalr	-1656(ra) # 80001980 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80006000:	00d5151b          	slliw	a0,a0,0xd
    80006004:	0c2017b7          	lui	a5,0xc201
    80006008:	97aa                	add	a5,a5,a0
    8000600a:	c3c4                	sw	s1,4(a5)
}
    8000600c:	60e2                	ld	ra,24(sp)
    8000600e:	6442                	ld	s0,16(sp)
    80006010:	64a2                	ld	s1,8(sp)
    80006012:	6105                	addi	sp,sp,32
    80006014:	8082                	ret

0000000080006016 <sgenrand>:
static unsigned long mt[N]; /* the array for the state vector  */
static int mti = N + 1;     /* mti==N+1 means mt[N] is not initialized */

/* initializing the array with a NONZERO seed */
void sgenrand(unsigned long seed)
{
    80006016:	1141                	addi	sp,sp,-16
    80006018:	e422                	sd	s0,8(sp)
    8000601a:	0800                	addi	s0,sp,16
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0] = seed & 0xffffffff;
    8000601c:	0001e717          	auipc	a4,0x1e
    80006020:	c6c70713          	addi	a4,a4,-916 # 80023c88 <mt>
    80006024:	1502                	slli	a0,a0,0x20
    80006026:	9101                	srli	a0,a0,0x20
    80006028:	e308                	sd	a0,0(a4)
    for (mti = 1; mti < N; mti++)
    8000602a:	0001f597          	auipc	a1,0x1f
    8000602e:	fd658593          	addi	a1,a1,-42 # 80025000 <mt+0x1378>
        mt[mti] = (69069 * mt[mti - 1]) & 0xffffffff;
    80006032:	6645                	lui	a2,0x11
    80006034:	dcd60613          	addi	a2,a2,-563 # 10dcd <_entry-0x7ffef233>
    80006038:	56fd                	li	a3,-1
    8000603a:	9281                	srli	a3,a3,0x20
    8000603c:	631c                	ld	a5,0(a4)
    8000603e:	02c787b3          	mul	a5,a5,a2
    80006042:	8ff5                	and	a5,a5,a3
    80006044:	e71c                	sd	a5,8(a4)
    for (mti = 1; mti < N; mti++)
    80006046:	0721                	addi	a4,a4,8
    80006048:	feb71ae3          	bne	a4,a1,8000603c <sgenrand+0x26>
    8000604c:	27000793          	li	a5,624
    80006050:	00003717          	auipc	a4,0x3
    80006054:	82f72c23          	sw	a5,-1992(a4) # 80008888 <mti>
}
    80006058:	6422                	ld	s0,8(sp)
    8000605a:	0141                	addi	sp,sp,16
    8000605c:	8082                	ret

000000008000605e <genrand>:

long /* for integer generation */
genrand()
{
    8000605e:	1141                	addi	sp,sp,-16
    80006060:	e406                	sd	ra,8(sp)
    80006062:	e022                	sd	s0,0(sp)
    80006064:	0800                	addi	s0,sp,16
    unsigned long y;
    static unsigned long mag01[2] = {0x0, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N)
    80006066:	00003797          	auipc	a5,0x3
    8000606a:	8227a783          	lw	a5,-2014(a5) # 80008888 <mti>
    8000606e:	26f00713          	li	a4,623
    80006072:	0ef75963          	bge	a4,a5,80006164 <genrand+0x106>
    { /* generate N words at one time */
        int kk;

        if (mti == N + 1)   /* if sgenrand() has not been called, */
    80006076:	27100713          	li	a4,625
    8000607a:	12e78e63          	beq	a5,a4,800061b6 <genrand+0x158>
            sgenrand(4357); /* a default initial seed is used   */

        for (kk = 0; kk < N - M; kk++)
    8000607e:	0001e817          	auipc	a6,0x1e
    80006082:	c0a80813          	addi	a6,a6,-1014 # 80023c88 <mt>
    80006086:	0001ee17          	auipc	t3,0x1e
    8000608a:	31ae0e13          	addi	t3,t3,794 # 800243a0 <mt+0x718>
{
    8000608e:	8742                	mv	a4,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    80006090:	4885                	li	a7,1
    80006092:	08fe                	slli	a7,a7,0x1f
    80006094:	80000537          	lui	a0,0x80000
    80006098:	fff54513          	not	a0,a0
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    8000609c:	6585                	lui	a1,0x1
    8000609e:	c6858593          	addi	a1,a1,-920 # c68 <_entry-0x7ffff398>
    800060a2:	00002317          	auipc	t1,0x2
    800060a6:	6be30313          	addi	t1,t1,1726 # 80008760 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800060aa:	631c                	ld	a5,0(a4)
    800060ac:	0117f7b3          	and	a5,a5,a7
    800060b0:	6714                	ld	a3,8(a4)
    800060b2:	8ee9                	and	a3,a3,a0
    800060b4:	8fd5                	or	a5,a5,a3
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    800060b6:	00b70633          	add	a2,a4,a1
    800060ba:	0017d693          	srli	a3,a5,0x1
    800060be:	6210                	ld	a2,0(a2)
    800060c0:	8eb1                	xor	a3,a3,a2
    800060c2:	8b85                	andi	a5,a5,1
    800060c4:	078e                	slli	a5,a5,0x3
    800060c6:	979a                	add	a5,a5,t1
    800060c8:	639c                	ld	a5,0(a5)
    800060ca:	8fb5                	xor	a5,a5,a3
    800060cc:	e31c                	sd	a5,0(a4)
        for (kk = 0; kk < N - M; kk++)
    800060ce:	0721                	addi	a4,a4,8
    800060d0:	fdc71de3          	bne	a4,t3,800060aa <genrand+0x4c>
        }
        for (; kk < N - 1; kk++)
    800060d4:	6605                	lui	a2,0x1
    800060d6:	c6060613          	addi	a2,a2,-928 # c60 <_entry-0x7ffff3a0>
    800060da:	9642                	add	a2,a2,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800060dc:	4505                	li	a0,1
    800060de:	057e                	slli	a0,a0,0x1f
    800060e0:	800005b7          	lui	a1,0x80000
    800060e4:	fff5c593          	not	a1,a1
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    800060e8:	00002897          	auipc	a7,0x2
    800060ec:	67888893          	addi	a7,a7,1656 # 80008760 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800060f0:	71883783          	ld	a5,1816(a6)
    800060f4:	8fe9                	and	a5,a5,a0
    800060f6:	72083703          	ld	a4,1824(a6)
    800060fa:	8f6d                	and	a4,a4,a1
    800060fc:	8fd9                	or	a5,a5,a4
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    800060fe:	0017d713          	srli	a4,a5,0x1
    80006102:	00083683          	ld	a3,0(a6)
    80006106:	8f35                	xor	a4,a4,a3
    80006108:	8b85                	andi	a5,a5,1
    8000610a:	078e                	slli	a5,a5,0x3
    8000610c:	97c6                	add	a5,a5,a7
    8000610e:	639c                	ld	a5,0(a5)
    80006110:	8fb9                	xor	a5,a5,a4
    80006112:	70f83c23          	sd	a5,1816(a6)
        for (; kk < N - 1; kk++)
    80006116:	0821                	addi	a6,a6,8
    80006118:	fcc81ce3          	bne	a6,a2,800060f0 <genrand+0x92>
        }
        y = (mt[N - 1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
    8000611c:	0001f697          	auipc	a3,0x1f
    80006120:	b6c68693          	addi	a3,a3,-1172 # 80024c88 <mt+0x1000>
    80006124:	3786b783          	ld	a5,888(a3)
    80006128:	4705                	li	a4,1
    8000612a:	077e                	slli	a4,a4,0x1f
    8000612c:	8ff9                	and	a5,a5,a4
    8000612e:	0001e717          	auipc	a4,0x1e
    80006132:	b5a73703          	ld	a4,-1190(a4) # 80023c88 <mt>
    80006136:	1706                	slli	a4,a4,0x21
    80006138:	9305                	srli	a4,a4,0x21
    8000613a:	8fd9                	or	a5,a5,a4
        mt[N - 1] = mt[M - 1] ^ (y >> 1) ^ mag01[y & 0x1];
    8000613c:	0017d713          	srli	a4,a5,0x1
    80006140:	c606b603          	ld	a2,-928(a3)
    80006144:	8f31                	xor	a4,a4,a2
    80006146:	8b85                	andi	a5,a5,1
    80006148:	078e                	slli	a5,a5,0x3
    8000614a:	00002617          	auipc	a2,0x2
    8000614e:	61660613          	addi	a2,a2,1558 # 80008760 <mag01.0>
    80006152:	97b2                	add	a5,a5,a2
    80006154:	639c                	ld	a5,0(a5)
    80006156:	8fb9                	xor	a5,a5,a4
    80006158:	36f6bc23          	sd	a5,888(a3)

        mti = 0;
    8000615c:	00002797          	auipc	a5,0x2
    80006160:	7207a623          	sw	zero,1836(a5) # 80008888 <mti>
    }

    y = mt[mti++];
    80006164:	00002717          	auipc	a4,0x2
    80006168:	72470713          	addi	a4,a4,1828 # 80008888 <mti>
    8000616c:	431c                	lw	a5,0(a4)
    8000616e:	0017869b          	addiw	a3,a5,1
    80006172:	c314                	sw	a3,0(a4)
    80006174:	078e                	slli	a5,a5,0x3
    80006176:	0001e717          	auipc	a4,0x1e
    8000617a:	b1270713          	addi	a4,a4,-1262 # 80023c88 <mt>
    8000617e:	97ba                	add	a5,a5,a4
    80006180:	639c                	ld	a5,0(a5)
    y ^= TEMPERING_SHIFT_U(y);
    80006182:	00b7d713          	srli	a4,a5,0xb
    80006186:	8f3d                	xor	a4,a4,a5
    y ^= TEMPERING_SHIFT_S(y) & TEMPERING_MASK_B;
    80006188:	013a67b7          	lui	a5,0x13a6
    8000618c:	8ad78793          	addi	a5,a5,-1875 # 13a58ad <_entry-0x7ec5a753>
    80006190:	8ff9                	and	a5,a5,a4
    80006192:	079e                	slli	a5,a5,0x7
    80006194:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_T(y) & TEMPERING_MASK_C;
    80006196:	00f79713          	slli	a4,a5,0xf
    8000619a:	077e36b7          	lui	a3,0x77e3
    8000619e:	0696                	slli	a3,a3,0x5
    800061a0:	8f75                	and	a4,a4,a3
    800061a2:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_L(y);
    800061a4:	0127d513          	srli	a0,a5,0x12
    800061a8:	8d3d                	xor	a0,a0,a5

    // Strip off uppermost bit because we want a long,
    // not an unsigned long
    return y & RAND_MAX;
    800061aa:	1506                	slli	a0,a0,0x21
}
    800061ac:	9105                	srli	a0,a0,0x21
    800061ae:	60a2                	ld	ra,8(sp)
    800061b0:	6402                	ld	s0,0(sp)
    800061b2:	0141                	addi	sp,sp,16
    800061b4:	8082                	ret
            sgenrand(4357); /* a default initial seed is used   */
    800061b6:	6505                	lui	a0,0x1
    800061b8:	10550513          	addi	a0,a0,261 # 1105 <_entry-0x7fffeefb>
    800061bc:	00000097          	auipc	ra,0x0
    800061c0:	e5a080e7          	jalr	-422(ra) # 80006016 <sgenrand>
    800061c4:	bd6d                	j	8000607e <genrand+0x20>

00000000800061c6 <random_at_most>:

// Assumes 0 <= max <= RAND_MAX
// Returns in the half-open interval [0, max]
long random_at_most(long max)
{
    800061c6:	1101                	addi	sp,sp,-32
    800061c8:	ec06                	sd	ra,24(sp)
    800061ca:	e822                	sd	s0,16(sp)
    800061cc:	e426                	sd	s1,8(sp)
    800061ce:	e04a                	sd	s2,0(sp)
    800061d0:	1000                	addi	s0,sp,32
    unsigned long
        // max <= RAND_MAX < ULONG_MAX, so this is okay.
        num_bins = (unsigned long)max + 1,
    800061d2:	0505                	addi	a0,a0,1
        num_rand = (unsigned long)RAND_MAX + 1,
        bin_size = num_rand / num_bins,
    800061d4:	4785                	li	a5,1
    800061d6:	07fe                	slli	a5,a5,0x1f
    800061d8:	02a7d933          	divu	s2,a5,a0
        defect = num_rand % num_bins;
    800061dc:	02a7f7b3          	remu	a5,a5,a0
    do
    {
        x = genrand();
    }
    // This is carefully written not to overflow
    while (num_rand - defect <= (unsigned long)x);
    800061e0:	4485                	li	s1,1
    800061e2:	04fe                	slli	s1,s1,0x1f
    800061e4:	8c9d                	sub	s1,s1,a5
        x = genrand();
    800061e6:	00000097          	auipc	ra,0x0
    800061ea:	e78080e7          	jalr	-392(ra) # 8000605e <genrand>
    while (num_rand - defect <= (unsigned long)x);
    800061ee:	fe957ce3          	bgeu	a0,s1,800061e6 <random_at_most+0x20>

    // Truncated division is intentional
    return x / bin_size;
    800061f2:	03255533          	divu	a0,a0,s2
    800061f6:	60e2                	ld	ra,24(sp)
    800061f8:	6442                	ld	s0,16(sp)
    800061fa:	64a2                	ld	s1,8(sp)
    800061fc:	6902                	ld	s2,0(sp)
    800061fe:	6105                	addi	sp,sp,32
    80006200:	8082                	ret

0000000080006202 <popfront>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void popfront(deque *a)
{
    80006202:	1141                	addi	sp,sp,-16
    80006204:	e422                	sd	s0,8(sp)
    80006206:	0800                	addi	s0,sp,16
    for (int i = 0; i < a->end - 1; i++)
    80006208:	20052683          	lw	a3,512(a0)
    8000620c:	fff6861b          	addiw	a2,a3,-1 # 77e2fff <_entry-0x7881d001>
    80006210:	0006079b          	sext.w	a5,a2
    80006214:	cf99                	beqz	a5,80006232 <popfront+0x30>
    80006216:	87aa                	mv	a5,a0
    80006218:	36f9                	addiw	a3,a3,-2
    8000621a:	02069713          	slli	a4,a3,0x20
    8000621e:	01d75693          	srli	a3,a4,0x1d
    80006222:	00850713          	addi	a4,a0,8
    80006226:	96ba                	add	a3,a3,a4
    {
        a->n[i] = a->n[i + 1];
    80006228:	6798                	ld	a4,8(a5)
    8000622a:	e398                	sd	a4,0(a5)
    for (int i = 0; i < a->end - 1; i++)
    8000622c:	07a1                	addi	a5,a5,8
    8000622e:	fed79de3          	bne	a5,a3,80006228 <popfront+0x26>
    }
    a->end--;
    80006232:	20c52023          	sw	a2,512(a0)
    return;
}
    80006236:	6422                	ld	s0,8(sp)
    80006238:	0141                	addi	sp,sp,16
    8000623a:	8082                	ret

000000008000623c <pushback>:
void pushback(deque *a, struct proc *x)
{
    if (a->end == NPROC)
    8000623c:	20052783          	lw	a5,512(a0)
    80006240:	04000713          	li	a4,64
    80006244:	00e78c63          	beq	a5,a4,8000625c <pushback+0x20>
    {
        panic("Error!");
        return;
    }
    a->n[a->end] = x;
    80006248:	02079693          	slli	a3,a5,0x20
    8000624c:	01d6d713          	srli	a4,a3,0x1d
    80006250:	972a                	add	a4,a4,a0
    80006252:	e30c                	sd	a1,0(a4)
    a->end++;
    80006254:	2785                	addiw	a5,a5,1
    80006256:	20f52023          	sw	a5,512(a0)
    8000625a:	8082                	ret
{
    8000625c:	1141                	addi	sp,sp,-16
    8000625e:	e406                	sd	ra,8(sp)
    80006260:	e022                	sd	s0,0(sp)
    80006262:	0800                	addi	s0,sp,16
        panic("Error!");
    80006264:	00002517          	auipc	a0,0x2
    80006268:	50c50513          	addi	a0,a0,1292 # 80008770 <mag01.0+0x10>
    8000626c:	ffffa097          	auipc	ra,0xffffa
    80006270:	2d4080e7          	jalr	724(ra) # 80000540 <panic>

0000000080006274 <front>:
    return;
}
struct proc *front(deque *a)
{
    80006274:	1141                	addi	sp,sp,-16
    80006276:	e422                	sd	s0,8(sp)
    80006278:	0800                	addi	s0,sp,16
    if (a->end == 0)
    8000627a:	20052783          	lw	a5,512(a0)
    8000627e:	c789                	beqz	a5,80006288 <front+0x14>
    {
        return 0;
    }
    return a->n[0];
    80006280:	6108                	ld	a0,0(a0)
}
    80006282:	6422                	ld	s0,8(sp)
    80006284:	0141                	addi	sp,sp,16
    80006286:	8082                	ret
        return 0;
    80006288:	4501                	li	a0,0
    8000628a:	bfe5                	j	80006282 <front+0xe>

000000008000628c <size>:
int size(deque *a)
{
    8000628c:	1141                	addi	sp,sp,-16
    8000628e:	e422                	sd	s0,8(sp)
    80006290:	0800                	addi	s0,sp,16
    return a->end;
}
    80006292:	20052503          	lw	a0,512(a0)
    80006296:	6422                	ld	s0,8(sp)
    80006298:	0141                	addi	sp,sp,16
    8000629a:	8082                	ret

000000008000629c <delete>:
void delete (deque *a, uint pid)
{
    8000629c:	1141                	addi	sp,sp,-16
    8000629e:	e422                	sd	s0,8(sp)
    800062a0:	0800                	addi	s0,sp,16
    int flag = 0;
    for (int i = 0; i < a->end; i++)
    800062a2:	20052e03          	lw	t3,512(a0)
    800062a6:	020e0c63          	beqz	t3,800062de <delete+0x42>
    800062aa:	87aa                	mv	a5,a0
    800062ac:	000e031b          	sext.w	t1,t3
    800062b0:	4701                	li	a4,0
    int flag = 0;
    800062b2:	4881                	li	a7,0
    {
        if (pid == a->n[i]->pid)
        {
            flag = 1;
        }
        if (flag == 1 && i != NPROC)
    800062b4:	04000e93          	li	t4,64
    800062b8:	4805                	li	a6,1
    800062ba:	a811                	j	800062ce <delete+0x32>
    800062bc:	88c2                	mv	a7,a6
    800062be:	01d70463          	beq	a4,t4,800062c6 <delete+0x2a>
        {
            a->n[i] = a->n[i + 1];
    800062c2:	6614                	ld	a3,8(a2)
    800062c4:	e214                	sd	a3,0(a2)
    for (int i = 0; i < a->end; i++)
    800062c6:	2705                	addiw	a4,a4,1
    800062c8:	07a1                	addi	a5,a5,8
    800062ca:	00670a63          	beq	a4,t1,800062de <delete+0x42>
        if (pid == a->n[i]->pid)
    800062ce:	863e                	mv	a2,a5
    800062d0:	6394                	ld	a3,0(a5)
    800062d2:	5a94                	lw	a3,48(a3)
    800062d4:	feb684e3          	beq	a3,a1,800062bc <delete+0x20>
        if (flag == 1 && i != NPROC)
    800062d8:	ff0897e3          	bne	a7,a6,800062c6 <delete+0x2a>
    800062dc:	b7c5                	j	800062bc <delete+0x20>
        }
    }
    a->end--;
    800062de:	3e7d                	addiw	t3,t3,-1
    800062e0:	21c52023          	sw	t3,512(a0)
    return;
    800062e4:	6422                	ld	s0,8(sp)
    800062e6:	0141                	addi	sp,sp,16
    800062e8:	8082                	ret

00000000800062ea <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062ea:	1141                	addi	sp,sp,-16
    800062ec:	e406                	sd	ra,8(sp)
    800062ee:	e022                	sd	s0,0(sp)
    800062f0:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800062f2:	479d                	li	a5,7
    800062f4:	04a7cc63          	blt	a5,a0,8000634c <free_desc+0x62>
    panic("free_desc 1");
  if (disk.free[i])
    800062f8:	0001f797          	auipc	a5,0x1f
    800062fc:	d1078793          	addi	a5,a5,-752 # 80025008 <disk>
    80006300:	97aa                	add	a5,a5,a0
    80006302:	0187c783          	lbu	a5,24(a5)
    80006306:	ebb9                	bnez	a5,8000635c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006308:	00451693          	slli	a3,a0,0x4
    8000630c:	0001f797          	auipc	a5,0x1f
    80006310:	cfc78793          	addi	a5,a5,-772 # 80025008 <disk>
    80006314:	6398                	ld	a4,0(a5)
    80006316:	9736                	add	a4,a4,a3
    80006318:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000631c:	6398                	ld	a4,0(a5)
    8000631e:	9736                	add	a4,a4,a3
    80006320:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006324:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006328:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000632c:	97aa                	add	a5,a5,a0
    8000632e:	4705                	li	a4,1
    80006330:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006334:	0001f517          	auipc	a0,0x1f
    80006338:	cec50513          	addi	a0,a0,-788 # 80025020 <disk+0x18>
    8000633c:	ffffc097          	auipc	ra,0xffffc
    80006340:	e0e080e7          	jalr	-498(ra) # 8000214a <wakeup>
}
    80006344:	60a2                	ld	ra,8(sp)
    80006346:	6402                	ld	s0,0(sp)
    80006348:	0141                	addi	sp,sp,16
    8000634a:	8082                	ret
    panic("free_desc 1");
    8000634c:	00002517          	auipc	a0,0x2
    80006350:	42c50513          	addi	a0,a0,1068 # 80008778 <mag01.0+0x18>
    80006354:	ffffa097          	auipc	ra,0xffffa
    80006358:	1ec080e7          	jalr	492(ra) # 80000540 <panic>
    panic("free_desc 2");
    8000635c:	00002517          	auipc	a0,0x2
    80006360:	42c50513          	addi	a0,a0,1068 # 80008788 <mag01.0+0x28>
    80006364:	ffffa097          	auipc	ra,0xffffa
    80006368:	1dc080e7          	jalr	476(ra) # 80000540 <panic>

000000008000636c <virtio_disk_init>:
{
    8000636c:	1101                	addi	sp,sp,-32
    8000636e:	ec06                	sd	ra,24(sp)
    80006370:	e822                	sd	s0,16(sp)
    80006372:	e426                	sd	s1,8(sp)
    80006374:	e04a                	sd	s2,0(sp)
    80006376:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006378:	00002597          	auipc	a1,0x2
    8000637c:	42058593          	addi	a1,a1,1056 # 80008798 <mag01.0+0x38>
    80006380:	0001f517          	auipc	a0,0x1f
    80006384:	db050513          	addi	a0,a0,-592 # 80025130 <disk+0x128>
    80006388:	ffffa097          	auipc	ra,0xffffa
    8000638c:	7be080e7          	jalr	1982(ra) # 80000b46 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006390:	100017b7          	lui	a5,0x10001
    80006394:	4398                	lw	a4,0(a5)
    80006396:	2701                	sext.w	a4,a4
    80006398:	747277b7          	lui	a5,0x74727
    8000639c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063a0:	14f71b63          	bne	a4,a5,800064f6 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063a4:	100017b7          	lui	a5,0x10001
    800063a8:	43dc                	lw	a5,4(a5)
    800063aa:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063ac:	4709                	li	a4,2
    800063ae:	14e79463          	bne	a5,a4,800064f6 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063b2:	100017b7          	lui	a5,0x10001
    800063b6:	479c                	lw	a5,8(a5)
    800063b8:	2781                	sext.w	a5,a5
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063ba:	12e79e63          	bne	a5,a4,800064f6 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551)
    800063be:	100017b7          	lui	a5,0x10001
    800063c2:	47d8                	lw	a4,12(a5)
    800063c4:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063c6:	554d47b7          	lui	a5,0x554d4
    800063ca:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063ce:	12f71463          	bne	a4,a5,800064f6 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063d2:	100017b7          	lui	a5,0x10001
    800063d6:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063da:	4705                	li	a4,1
    800063dc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063de:	470d                	li	a4,3
    800063e0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063e2:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063e4:	c7ffe6b7          	lui	a3,0xc7ffe
    800063e8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9617>
    800063ec:	8f75                	and	a4,a4,a3
    800063ee:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063f0:	472d                	li	a4,11
    800063f2:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800063f4:	5bbc                	lw	a5,112(a5)
    800063f6:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800063fa:	8ba1                	andi	a5,a5,8
    800063fc:	10078563          	beqz	a5,80006506 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006400:	100017b7          	lui	a5,0x10001
    80006404:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80006408:	43fc                	lw	a5,68(a5)
    8000640a:	2781                	sext.w	a5,a5
    8000640c:	10079563          	bnez	a5,80006516 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006410:	100017b7          	lui	a5,0x10001
    80006414:	5bdc                	lw	a5,52(a5)
    80006416:	2781                	sext.w	a5,a5
  if (max == 0)
    80006418:	10078763          	beqz	a5,80006526 <virtio_disk_init+0x1ba>
  if (max < NUM)
    8000641c:	471d                	li	a4,7
    8000641e:	10f77c63          	bgeu	a4,a5,80006536 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80006422:	ffffa097          	auipc	ra,0xffffa
    80006426:	6c4080e7          	jalr	1732(ra) # 80000ae6 <kalloc>
    8000642a:	0001f497          	auipc	s1,0x1f
    8000642e:	bde48493          	addi	s1,s1,-1058 # 80025008 <disk>
    80006432:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006434:	ffffa097          	auipc	ra,0xffffa
    80006438:	6b2080e7          	jalr	1714(ra) # 80000ae6 <kalloc>
    8000643c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000643e:	ffffa097          	auipc	ra,0xffffa
    80006442:	6a8080e7          	jalr	1704(ra) # 80000ae6 <kalloc>
    80006446:	87aa                	mv	a5,a0
    80006448:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    8000644a:	6088                	ld	a0,0(s1)
    8000644c:	cd6d                	beqz	a0,80006546 <virtio_disk_init+0x1da>
    8000644e:	0001f717          	auipc	a4,0x1f
    80006452:	bc273703          	ld	a4,-1086(a4) # 80025010 <disk+0x8>
    80006456:	cb65                	beqz	a4,80006546 <virtio_disk_init+0x1da>
    80006458:	c7fd                	beqz	a5,80006546 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    8000645a:	6605                	lui	a2,0x1
    8000645c:	4581                	li	a1,0
    8000645e:	ffffb097          	auipc	ra,0xffffb
    80006462:	874080e7          	jalr	-1932(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006466:	0001f497          	auipc	s1,0x1f
    8000646a:	ba248493          	addi	s1,s1,-1118 # 80025008 <disk>
    8000646e:	6605                	lui	a2,0x1
    80006470:	4581                	li	a1,0
    80006472:	6488                	ld	a0,8(s1)
    80006474:	ffffb097          	auipc	ra,0xffffb
    80006478:	85e080e7          	jalr	-1954(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000647c:	6605                	lui	a2,0x1
    8000647e:	4581                	li	a1,0
    80006480:	6888                	ld	a0,16(s1)
    80006482:	ffffb097          	auipc	ra,0xffffb
    80006486:	850080e7          	jalr	-1968(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000648a:	100017b7          	lui	a5,0x10001
    8000648e:	4721                	li	a4,8
    80006490:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006492:	4098                	lw	a4,0(s1)
    80006494:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006498:	40d8                	lw	a4,4(s1)
    8000649a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000649e:	6498                	ld	a4,8(s1)
    800064a0:	0007069b          	sext.w	a3,a4
    800064a4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800064a8:	9701                	srai	a4,a4,0x20
    800064aa:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800064ae:	6898                	ld	a4,16(s1)
    800064b0:	0007069b          	sext.w	a3,a4
    800064b4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800064b8:	9701                	srai	a4,a4,0x20
    800064ba:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800064be:	4705                	li	a4,1
    800064c0:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800064c2:	00e48c23          	sb	a4,24(s1)
    800064c6:	00e48ca3          	sb	a4,25(s1)
    800064ca:	00e48d23          	sb	a4,26(s1)
    800064ce:	00e48da3          	sb	a4,27(s1)
    800064d2:	00e48e23          	sb	a4,28(s1)
    800064d6:	00e48ea3          	sb	a4,29(s1)
    800064da:	00e48f23          	sb	a4,30(s1)
    800064de:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800064e2:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800064e6:	0727a823          	sw	s2,112(a5)
}
    800064ea:	60e2                	ld	ra,24(sp)
    800064ec:	6442                	ld	s0,16(sp)
    800064ee:	64a2                	ld	s1,8(sp)
    800064f0:	6902                	ld	s2,0(sp)
    800064f2:	6105                	addi	sp,sp,32
    800064f4:	8082                	ret
    panic("could not find virtio disk");
    800064f6:	00002517          	auipc	a0,0x2
    800064fa:	2b250513          	addi	a0,a0,690 # 800087a8 <mag01.0+0x48>
    800064fe:	ffffa097          	auipc	ra,0xffffa
    80006502:	042080e7          	jalr	66(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006506:	00002517          	auipc	a0,0x2
    8000650a:	2c250513          	addi	a0,a0,706 # 800087c8 <mag01.0+0x68>
    8000650e:	ffffa097          	auipc	ra,0xffffa
    80006512:	032080e7          	jalr	50(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006516:	00002517          	auipc	a0,0x2
    8000651a:	2d250513          	addi	a0,a0,722 # 800087e8 <mag01.0+0x88>
    8000651e:	ffffa097          	auipc	ra,0xffffa
    80006522:	022080e7          	jalr	34(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006526:	00002517          	auipc	a0,0x2
    8000652a:	2e250513          	addi	a0,a0,738 # 80008808 <mag01.0+0xa8>
    8000652e:	ffffa097          	auipc	ra,0xffffa
    80006532:	012080e7          	jalr	18(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006536:	00002517          	auipc	a0,0x2
    8000653a:	2f250513          	addi	a0,a0,754 # 80008828 <mag01.0+0xc8>
    8000653e:	ffffa097          	auipc	ra,0xffffa
    80006542:	002080e7          	jalr	2(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006546:	00002517          	auipc	a0,0x2
    8000654a:	30250513          	addi	a0,a0,770 # 80008848 <mag01.0+0xe8>
    8000654e:	ffffa097          	auipc	ra,0xffffa
    80006552:	ff2080e7          	jalr	-14(ra) # 80000540 <panic>

0000000080006556 <virtio_disk_rw>:
  }
  return 0;
}

void virtio_disk_rw(struct buf *b, int write)
{
    80006556:	7119                	addi	sp,sp,-128
    80006558:	fc86                	sd	ra,120(sp)
    8000655a:	f8a2                	sd	s0,112(sp)
    8000655c:	f4a6                	sd	s1,104(sp)
    8000655e:	f0ca                	sd	s2,96(sp)
    80006560:	ecce                	sd	s3,88(sp)
    80006562:	e8d2                	sd	s4,80(sp)
    80006564:	e4d6                	sd	s5,72(sp)
    80006566:	e0da                	sd	s6,64(sp)
    80006568:	fc5e                	sd	s7,56(sp)
    8000656a:	f862                	sd	s8,48(sp)
    8000656c:	f466                	sd	s9,40(sp)
    8000656e:	f06a                	sd	s10,32(sp)
    80006570:	ec6e                	sd	s11,24(sp)
    80006572:	0100                	addi	s0,sp,128
    80006574:	8aaa                	mv	s5,a0
    80006576:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006578:	00c52d03          	lw	s10,12(a0)
    8000657c:	001d1d1b          	slliw	s10,s10,0x1
    80006580:	1d02                	slli	s10,s10,0x20
    80006582:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006586:	0001f517          	auipc	a0,0x1f
    8000658a:	baa50513          	addi	a0,a0,-1110 # 80025130 <disk+0x128>
    8000658e:	ffffa097          	auipc	ra,0xffffa
    80006592:	648080e7          	jalr	1608(ra) # 80000bd6 <acquire>
  for (int i = 0; i < 3; i++)
    80006596:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++)
    80006598:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000659a:	0001fb97          	auipc	s7,0x1f
    8000659e:	a6eb8b93          	addi	s7,s7,-1426 # 80025008 <disk>
  for (int i = 0; i < 3; i++)
    800065a2:	4b0d                	li	s6,3
  {
    if (alloc3_desc(idx) == 0)
    {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065a4:	0001fc97          	auipc	s9,0x1f
    800065a8:	b8cc8c93          	addi	s9,s9,-1140 # 80025130 <disk+0x128>
    800065ac:	a08d                	j	8000660e <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800065ae:	00fb8733          	add	a4,s7,a5
    800065b2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800065b6:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0)
    800065b8:	0207c563          	bltz	a5,800065e2 <virtio_disk_rw+0x8c>
  for (int i = 0; i < 3; i++)
    800065bc:	2905                	addiw	s2,s2,1
    800065be:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800065c0:	05690c63          	beq	s2,s6,80006618 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800065c4:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++)
    800065c6:	0001f717          	auipc	a4,0x1f
    800065ca:	a4270713          	addi	a4,a4,-1470 # 80025008 <disk>
    800065ce:	87ce                	mv	a5,s3
    if (disk.free[i])
    800065d0:	01874683          	lbu	a3,24(a4)
    800065d4:	fee9                	bnez	a3,800065ae <virtio_disk_rw+0x58>
  for (int i = 0; i < NUM; i++)
    800065d6:	2785                	addiw	a5,a5,1
    800065d8:	0705                	addi	a4,a4,1
    800065da:	fe979be3          	bne	a5,s1,800065d0 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800065de:	57fd                	li	a5,-1
    800065e0:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    800065e2:	01205d63          	blez	s2,800065fc <virtio_disk_rw+0xa6>
    800065e6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800065e8:	000a2503          	lw	a0,0(s4)
    800065ec:	00000097          	auipc	ra,0x0
    800065f0:	cfe080e7          	jalr	-770(ra) # 800062ea <free_desc>
      for (int j = 0; j < i; j++)
    800065f4:	2d85                	addiw	s11,s11,1
    800065f6:	0a11                	addi	s4,s4,4
    800065f8:	ff2d98e3          	bne	s11,s2,800065e8 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065fc:	85e6                	mv	a1,s9
    800065fe:	0001f517          	auipc	a0,0x1f
    80006602:	a2250513          	addi	a0,a0,-1502 # 80025020 <disk+0x18>
    80006606:	ffffc097          	auipc	ra,0xffffc
    8000660a:	ad4080e7          	jalr	-1324(ra) # 800020da <sleep>
  for (int i = 0; i < 3; i++)
    8000660e:	f8040a13          	addi	s4,s0,-128
{
    80006612:	8652                	mv	a2,s4
  for (int i = 0; i < 3; i++)
    80006614:	894e                	mv	s2,s3
    80006616:	b77d                	j	800065c4 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006618:	f8042503          	lw	a0,-128(s0)
    8000661c:	00a50713          	addi	a4,a0,10
    80006620:	0712                	slli	a4,a4,0x4

  if (write)
    80006622:	0001f797          	auipc	a5,0x1f
    80006626:	9e678793          	addi	a5,a5,-1562 # 80025008 <disk>
    8000662a:	00e786b3          	add	a3,a5,a4
    8000662e:	01803633          	snez	a2,s8
    80006632:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006634:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006638:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64)buf0;
    8000663c:	f6070613          	addi	a2,a4,-160
    80006640:	6394                	ld	a3,0(a5)
    80006642:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006644:	00870593          	addi	a1,a4,8
    80006648:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    8000664a:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000664c:	0007b803          	ld	a6,0(a5)
    80006650:	9642                	add	a2,a2,a6
    80006652:	46c1                	li	a3,16
    80006654:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006656:	4585                	li	a1,1
    80006658:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    8000665c:	f8442683          	lw	a3,-124(s0)
    80006660:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80006664:	0692                	slli	a3,a3,0x4
    80006666:	9836                	add	a6,a6,a3
    80006668:	058a8613          	addi	a2,s5,88
    8000666c:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006670:	0007b803          	ld	a6,0(a5)
    80006674:	96c2                	add	a3,a3,a6
    80006676:	40000613          	li	a2,1024
    8000667a:	c690                	sw	a2,8(a3)
  if (write)
    8000667c:	001c3613          	seqz	a2,s8
    80006680:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006684:	00166613          	ori	a2,a2,1
    80006688:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000668c:	f8842603          	lw	a2,-120(s0)
    80006690:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006694:	00250693          	addi	a3,a0,2
    80006698:	0692                	slli	a3,a3,0x4
    8000669a:	96be                	add	a3,a3,a5
    8000669c:	58fd                	li	a7,-1
    8000669e:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    800066a2:	0612                	slli	a2,a2,0x4
    800066a4:	9832                	add	a6,a6,a2
    800066a6:	f9070713          	addi	a4,a4,-112
    800066aa:	973e                	add	a4,a4,a5
    800066ac:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800066b0:	6398                	ld	a4,0(a5)
    800066b2:	9732                	add	a4,a4,a2
    800066b4:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066b6:	4609                	li	a2,2
    800066b8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800066bc:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066c0:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800066c4:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066c8:	6794                	ld	a3,8(a5)
    800066ca:	0026d703          	lhu	a4,2(a3)
    800066ce:	8b1d                	andi	a4,a4,7
    800066d0:	0706                	slli	a4,a4,0x1
    800066d2:	96ba                	add	a3,a3,a4
    800066d4:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800066d8:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800066dc:	6798                	ld	a4,8(a5)
    800066de:	00275783          	lhu	a5,2(a4)
    800066e2:	2785                	addiw	a5,a5,1
    800066e4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800066e8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066ec:	100017b7          	lui	a5,0x10001
    800066f0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1)
    800066f4:	004aa783          	lw	a5,4(s5)
  {
    sleep(b, &disk.vdisk_lock);
    800066f8:	0001f917          	auipc	s2,0x1f
    800066fc:	a3890913          	addi	s2,s2,-1480 # 80025130 <disk+0x128>
  while (b->disk == 1)
    80006700:	4485                	li	s1,1
    80006702:	00b79c63          	bne	a5,a1,8000671a <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006706:	85ca                	mv	a1,s2
    80006708:	8556                	mv	a0,s5
    8000670a:	ffffc097          	auipc	ra,0xffffc
    8000670e:	9d0080e7          	jalr	-1584(ra) # 800020da <sleep>
  while (b->disk == 1)
    80006712:	004aa783          	lw	a5,4(s5)
    80006716:	fe9788e3          	beq	a5,s1,80006706 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000671a:	f8042903          	lw	s2,-128(s0)
    8000671e:	00290713          	addi	a4,s2,2
    80006722:	0712                	slli	a4,a4,0x4
    80006724:	0001f797          	auipc	a5,0x1f
    80006728:	8e478793          	addi	a5,a5,-1820 # 80025008 <disk>
    8000672c:	97ba                	add	a5,a5,a4
    8000672e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006732:	0001f997          	auipc	s3,0x1f
    80006736:	8d698993          	addi	s3,s3,-1834 # 80025008 <disk>
    8000673a:	00491713          	slli	a4,s2,0x4
    8000673e:	0009b783          	ld	a5,0(s3)
    80006742:	97ba                	add	a5,a5,a4
    80006744:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006748:	854a                	mv	a0,s2
    8000674a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000674e:	00000097          	auipc	ra,0x0
    80006752:	b9c080e7          	jalr	-1124(ra) # 800062ea <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80006756:	8885                	andi	s1,s1,1
    80006758:	f0ed                	bnez	s1,8000673a <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000675a:	0001f517          	auipc	a0,0x1f
    8000675e:	9d650513          	addi	a0,a0,-1578 # 80025130 <disk+0x128>
    80006762:	ffffa097          	auipc	ra,0xffffa
    80006766:	528080e7          	jalr	1320(ra) # 80000c8a <release>
}
    8000676a:	70e6                	ld	ra,120(sp)
    8000676c:	7446                	ld	s0,112(sp)
    8000676e:	74a6                	ld	s1,104(sp)
    80006770:	7906                	ld	s2,96(sp)
    80006772:	69e6                	ld	s3,88(sp)
    80006774:	6a46                	ld	s4,80(sp)
    80006776:	6aa6                	ld	s5,72(sp)
    80006778:	6b06                	ld	s6,64(sp)
    8000677a:	7be2                	ld	s7,56(sp)
    8000677c:	7c42                	ld	s8,48(sp)
    8000677e:	7ca2                	ld	s9,40(sp)
    80006780:	7d02                	ld	s10,32(sp)
    80006782:	6de2                	ld	s11,24(sp)
    80006784:	6109                	addi	sp,sp,128
    80006786:	8082                	ret

0000000080006788 <virtio_disk_intr>:

void virtio_disk_intr()
{
    80006788:	1101                	addi	sp,sp,-32
    8000678a:	ec06                	sd	ra,24(sp)
    8000678c:	e822                	sd	s0,16(sp)
    8000678e:	e426                	sd	s1,8(sp)
    80006790:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006792:	0001f497          	auipc	s1,0x1f
    80006796:	87648493          	addi	s1,s1,-1930 # 80025008 <disk>
    8000679a:	0001f517          	auipc	a0,0x1f
    8000679e:	99650513          	addi	a0,a0,-1642 # 80025130 <disk+0x128>
    800067a2:	ffffa097          	auipc	ra,0xffffa
    800067a6:	434080e7          	jalr	1076(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067aa:	10001737          	lui	a4,0x10001
    800067ae:	533c                	lw	a5,96(a4)
    800067b0:	8b8d                	andi	a5,a5,3
    800067b2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800067b4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx)
    800067b8:	689c                	ld	a5,16(s1)
    800067ba:	0204d703          	lhu	a4,32(s1)
    800067be:	0027d783          	lhu	a5,2(a5)
    800067c2:	04f70863          	beq	a4,a5,80006812 <virtio_disk_intr+0x8a>
  {
    __sync_synchronize();
    800067c6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067ca:	6898                	ld	a4,16(s1)
    800067cc:	0204d783          	lhu	a5,32(s1)
    800067d0:	8b9d                	andi	a5,a5,7
    800067d2:	078e                	slli	a5,a5,0x3
    800067d4:	97ba                	add	a5,a5,a4
    800067d6:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    800067d8:	00278713          	addi	a4,a5,2
    800067dc:	0712                	slli	a4,a4,0x4
    800067de:	9726                	add	a4,a4,s1
    800067e0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800067e4:	e721                	bnez	a4,8000682c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800067e6:	0789                	addi	a5,a5,2
    800067e8:	0792                	slli	a5,a5,0x4
    800067ea:	97a6                	add	a5,a5,s1
    800067ec:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    800067ee:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067f2:	ffffc097          	auipc	ra,0xffffc
    800067f6:	958080e7          	jalr	-1704(ra) # 8000214a <wakeup>

    disk.used_idx += 1;
    800067fa:	0204d783          	lhu	a5,32(s1)
    800067fe:	2785                	addiw	a5,a5,1
    80006800:	17c2                	slli	a5,a5,0x30
    80006802:	93c1                	srli	a5,a5,0x30
    80006804:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx)
    80006808:	6898                	ld	a4,16(s1)
    8000680a:	00275703          	lhu	a4,2(a4)
    8000680e:	faf71ce3          	bne	a4,a5,800067c6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006812:	0001f517          	auipc	a0,0x1f
    80006816:	91e50513          	addi	a0,a0,-1762 # 80025130 <disk+0x128>
    8000681a:	ffffa097          	auipc	ra,0xffffa
    8000681e:	470080e7          	jalr	1136(ra) # 80000c8a <release>
}
    80006822:	60e2                	ld	ra,24(sp)
    80006824:	6442                	ld	s0,16(sp)
    80006826:	64a2                	ld	s1,8(sp)
    80006828:	6105                	addi	sp,sp,32
    8000682a:	8082                	ret
      panic("virtio_disk_intr status");
    8000682c:	00002517          	auipc	a0,0x2
    80006830:	03450513          	addi	a0,a0,52 # 80008860 <mag01.0+0x100>
    80006834:	ffffa097          	auipc	ra,0xffffa
    80006838:	d0c080e7          	jalr	-756(ra) # 80000540 <panic>
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
