
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
    80000066:	f4e78793          	addi	a5,a5,-178 # 80005fb0 <timervec>
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
    8000012e:	458080e7          	jalr	1112(ra) # 80002582 <either_copyin>
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
    800001cc:	204080e7          	jalr	516(ra) # 800023cc <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f16080e7          	jalr	-234(ra) # 800020ec <sleep>
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
    80000216:	31a080e7          	jalr	794(ra) # 8000252c <either_copyout>
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
    800002f6:	2e6080e7          	jalr	742(ra) # 800025d8 <procdump>
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
    8000044a:	d16080e7          	jalr	-746(ra) # 8000215c <wakeup>
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
    80000898:	8c8080e7          	jalr	-1848(ra) # 8000215c <wakeup>

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
    80000922:	7ce080e7          	jalr	1998(ra) # 800020ec <sleep>
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
    80000ec2:	a08080e7          	jalr	-1528(ra) # 800028c6 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	12a080e7          	jalr	298(ra) # 80005ff0 <plicinithart>
  }

  scheduler();
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	06c080e7          	jalr	108(ra) # 80001f3a <scheduler>
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
    80000f3a:	968080e7          	jalr	-1688(ra) # 8000289e <trapinit>
    trapinithart();     // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	988080e7          	jalr	-1656(ra) # 800028c6 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	094080e7          	jalr	148(ra) # 80005fda <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	0a2080e7          	jalr	162(ra) # 80005ff0 <plicinithart>
    binit();            // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	242080e7          	jalr	578(ra) # 80003198 <binit>
    iinit();            // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	8e2080e7          	jalr	-1822(ra) # 80003840 <iinit>
    fileinit();         // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	888080e7          	jalr	-1912(ra) # 800047ee <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	45e080e7          	jalr	1118(ra) # 800063cc <virtio_disk_init>
    userinit();         // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d8e080e7          	jalr	-626(ra) # 80001d04 <userinit>
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
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
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
    80001a0a:	ed8080e7          	jalr	-296(ra) # 800028de <usertrapret>
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
    80001a24:	da0080e7          	jalr	-608(ra) # 800037c0 <fsinit>
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
  if (p->alarm_trapframe)
    80001b76:	1b04b503          	ld	a0,432(s1)
    80001b7a:	c509                	beqz	a0,80001b84 <freeproc+0x26>
    kfree((void *)p->alarm_trapframe);
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	e6c080e7          	jalr	-404(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b84:	0404bc23          	sd	zero,88(s1)
  p->alarm_trapframe = 0;
    80001b88:	1a04b823          	sd	zero,432(s1)
  if (p->pagetable)
    80001b8c:	68a8                	ld	a0,80(s1)
    80001b8e:	c511                	beqz	a0,80001b9a <freeproc+0x3c>
    proc_freepagetable(p->pagetable, p->sz);
    80001b90:	64ac                	ld	a1,72(s1)
    80001b92:	00000097          	auipc	ra,0x0
    80001b96:	f7a080e7          	jalr	-134(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b9a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b9e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ba2:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ba6:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001baa:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bae:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bb2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bb6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bba:	0004ac23          	sw	zero,24(s1)
}
    80001bbe:	60e2                	ld	ra,24(sp)
    80001bc0:	6442                	ld	s0,16(sp)
    80001bc2:	64a2                	ld	s1,8(sp)
    80001bc4:	6105                	addi	sp,sp,32
    80001bc6:	8082                	ret

0000000080001bc8 <allocproc>:
{
    80001bc8:	1101                	addi	sp,sp,-32
    80001bca:	ec06                	sd	ra,24(sp)
    80001bcc:	e822                	sd	s0,16(sp)
    80001bce:	e426                	sd	s1,8(sp)
    80001bd0:	e04a                	sd	s2,0(sp)
    80001bd2:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bd4:	0000f497          	auipc	s1,0xf
    80001bd8:	3ec48493          	addi	s1,s1,1004 # 80010fc0 <proc>
    80001bdc:	00016917          	auipc	s2,0x16
    80001be0:	3e490913          	addi	s2,s2,996 # 80017fc0 <mlfq>
    acquire(&p->lock);
    80001be4:	8526                	mv	a0,s1
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	ff0080e7          	jalr	-16(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001bee:	4c9c                	lw	a5,24(s1)
    80001bf0:	cf81                	beqz	a5,80001c08 <allocproc+0x40>
      release(&p->lock);
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	096080e7          	jalr	150(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001bfc:	1c048493          	addi	s1,s1,448
    80001c00:	ff2492e3          	bne	s1,s2,80001be4 <allocproc+0x1c>
  return 0;
    80001c04:	4481                	li	s1,0
    80001c06:	a84d                	j	80001cb8 <allocproc+0xf0>
  p->pid = allocpid();
    80001c08:	00000097          	auipc	ra,0x0
    80001c0c:	e22080e7          	jalr	-478(ra) # 80001a2a <allocpid>
    80001c10:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c12:	4785                	li	a5,1
    80001c14:	cc9c                	sw	a5,24(s1)
  p->number_of_times_scheduled = 0;
    80001c16:	1604ac23          	sw	zero,376(s1)
  p->sleeping_ticks = 0;
    80001c1a:	1804a223          	sw	zero,388(s1)
  p->running_ticks = 0;
    80001c1e:	1804a423          	sw	zero,392(s1)
  p->sleep_start = 0;
    80001c22:	1604ae23          	sw	zero,380(s1)
  p->reset_niceness = 1;
    80001c26:	18f4a023          	sw	a5,384(s1)
  p->level = 0;
    80001c2a:	1804a623          	sw	zero,396(s1)
  p->change_queue = 1 << p->level;
    80001c2e:	18f4aa23          	sw	a5,404(s1)
  p->in_queue = 0;
    80001c32:	1804a823          	sw	zero,400(s1)
  p->enter_ticks = ticks;
    80001c36:	00007797          	auipc	a5,0x7
    80001c3a:	cf27a783          	lw	a5,-782(a5) # 80008928 <ticks>
    80001c3e:	18f4ac23          	sw	a5,408(s1)
  p->now_ticks = 0;
    80001c42:	1a04a623          	sw	zero,428(s1)
  p->sigalarm_status = 0;
    80001c46:	1a04ac23          	sw	zero,440(s1)
  p->interval = 0;
    80001c4a:	1a04a423          	sw	zero,424(s1)
  p->handler = -1;
    80001c4e:	57fd                	li	a5,-1
    80001c50:	1af4b023          	sd	a5,416(s1)
  p->alarm_trapframe = NULL;
    80001c54:	1a04b823          	sd	zero,432(s1)
  if (forked_process && p->parent)
    80001c58:	00007797          	auipc	a5,0x7
    80001c5c:	cc07a783          	lw	a5,-832(a5) # 80008918 <forked_process>
    80001c60:	e3bd                	bnez	a5,80001cc6 <allocproc+0xfe>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	e84080e7          	jalr	-380(ra) # 80000ae6 <kalloc>
    80001c6a:	892a                	mv	s2,a0
    80001c6c:	eca8                	sd	a0,88(s1)
    80001c6e:	c13d                	beqz	a0,80001cd4 <allocproc+0x10c>
  p->pagetable = proc_pagetable(p);
    80001c70:	8526                	mv	a0,s1
    80001c72:	00000097          	auipc	ra,0x0
    80001c76:	dfe080e7          	jalr	-514(ra) # 80001a70 <proc_pagetable>
    80001c7a:	892a                	mv	s2,a0
    80001c7c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c7e:	c53d                	beqz	a0,80001cec <allocproc+0x124>
  memset(&p->context, 0, sizeof(p->context));
    80001c80:	07000613          	li	a2,112
    80001c84:	4581                	li	a1,0
    80001c86:	06048513          	addi	a0,s1,96
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	048080e7          	jalr	72(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c92:	00000797          	auipc	a5,0x0
    80001c96:	d5278793          	addi	a5,a5,-686 # 800019e4 <forkret>
    80001c9a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c9c:	60bc                	ld	a5,64(s1)
    80001c9e:	6705                	lui	a4,0x1
    80001ca0:	97ba                	add	a5,a5,a4
    80001ca2:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001ca4:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001ca8:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001cac:	00007797          	auipc	a5,0x7
    80001cb0:	c7c7a783          	lw	a5,-900(a5) # 80008928 <ticks>
    80001cb4:	16f4a623          	sw	a5,364(s1)
}
    80001cb8:	8526                	mv	a0,s1
    80001cba:	60e2                	ld	ra,24(sp)
    80001cbc:	6442                	ld	s0,16(sp)
    80001cbe:	64a2                	ld	s1,8(sp)
    80001cc0:	6902                	ld	s2,0(sp)
    80001cc2:	6105                	addi	sp,sp,32
    80001cc4:	8082                	ret
  if (forked_process && p->parent)
    80001cc6:	7c9c                	ld	a5,56(s1)
    80001cc8:	dfc9                	beqz	a5,80001c62 <allocproc+0x9a>
    forked_process = 0;
    80001cca:	00007797          	auipc	a5,0x7
    80001cce:	c407a723          	sw	zero,-946(a5) # 80008918 <forked_process>
    80001cd2:	bf41                	j	80001c62 <allocproc+0x9a>
    freeproc(p);
    80001cd4:	8526                	mv	a0,s1
    80001cd6:	00000097          	auipc	ra,0x0
    80001cda:	e88080e7          	jalr	-376(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001cde:	8526                	mv	a0,s1
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	faa080e7          	jalr	-86(ra) # 80000c8a <release>
    return 0;
    80001ce8:	84ca                	mv	s1,s2
    80001cea:	b7f9                	j	80001cb8 <allocproc+0xf0>
    freeproc(p);
    80001cec:	8526                	mv	a0,s1
    80001cee:	00000097          	auipc	ra,0x0
    80001cf2:	e70080e7          	jalr	-400(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	f92080e7          	jalr	-110(ra) # 80000c8a <release>
    return 0;
    80001d00:	84ca                	mv	s1,s2
    80001d02:	bf5d                	j	80001cb8 <allocproc+0xf0>

0000000080001d04 <userinit>:
{
    80001d04:	1101                	addi	sp,sp,-32
    80001d06:	ec06                	sd	ra,24(sp)
    80001d08:	e822                	sd	s0,16(sp)
    80001d0a:	e426                	sd	s1,8(sp)
    80001d0c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d0e:	00000097          	auipc	ra,0x0
    80001d12:	eba080e7          	jalr	-326(ra) # 80001bc8 <allocproc>
    80001d16:	84aa                	mv	s1,a0
  initproc = p;
    80001d18:	00007797          	auipc	a5,0x7
    80001d1c:	c0a7b423          	sd	a0,-1016(a5) # 80008920 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d20:	03400613          	li	a2,52
    80001d24:	00007597          	auipc	a1,0x7
    80001d28:	b6c58593          	addi	a1,a1,-1172 # 80008890 <initcode>
    80001d2c:	6928                	ld	a0,80(a0)
    80001d2e:	fffff097          	auipc	ra,0xfffff
    80001d32:	628080e7          	jalr	1576(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d36:	6785                	lui	a5,0x1
    80001d38:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d3a:	6cb8                	ld	a4,88(s1)
    80001d3c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d40:	6cb8                	ld	a4,88(s1)
    80001d42:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d44:	4641                	li	a2,16
    80001d46:	00006597          	auipc	a1,0x6
    80001d4a:	4ba58593          	addi	a1,a1,1210 # 80008200 <digits+0x1c0>
    80001d4e:	15848513          	addi	a0,s1,344
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	0ca080e7          	jalr	202(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d5a:	00006517          	auipc	a0,0x6
    80001d5e:	4b650513          	addi	a0,a0,1206 # 80008210 <digits+0x1d0>
    80001d62:	00002097          	auipc	ra,0x2
    80001d66:	488080e7          	jalr	1160(ra) # 800041ea <namei>
    80001d6a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d6e:	478d                	li	a5,3
    80001d70:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d72:	8526                	mv	a0,s1
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	f16080e7          	jalr	-234(ra) # 80000c8a <release>
}
    80001d7c:	60e2                	ld	ra,24(sp)
    80001d7e:	6442                	ld	s0,16(sp)
    80001d80:	64a2                	ld	s1,8(sp)
    80001d82:	6105                	addi	sp,sp,32
    80001d84:	8082                	ret

0000000080001d86 <growproc>:
{
    80001d86:	1101                	addi	sp,sp,-32
    80001d88:	ec06                	sd	ra,24(sp)
    80001d8a:	e822                	sd	s0,16(sp)
    80001d8c:	e426                	sd	s1,8(sp)
    80001d8e:	e04a                	sd	s2,0(sp)
    80001d90:	1000                	addi	s0,sp,32
    80001d92:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d94:	00000097          	auipc	ra,0x0
    80001d98:	c18080e7          	jalr	-1000(ra) # 800019ac <myproc>
    80001d9c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d9e:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001da0:	01204c63          	bgtz	s2,80001db8 <growproc+0x32>
  else if (n < 0)
    80001da4:	02094663          	bltz	s2,80001dd0 <growproc+0x4a>
  p->sz = sz;
    80001da8:	e4ac                	sd	a1,72(s1)
  return 0;
    80001daa:	4501                	li	a0,0
}
    80001dac:	60e2                	ld	ra,24(sp)
    80001dae:	6442                	ld	s0,16(sp)
    80001db0:	64a2                	ld	s1,8(sp)
    80001db2:	6902                	ld	s2,0(sp)
    80001db4:	6105                	addi	sp,sp,32
    80001db6:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001db8:	4691                	li	a3,4
    80001dba:	00b90633          	add	a2,s2,a1
    80001dbe:	6928                	ld	a0,80(a0)
    80001dc0:	fffff097          	auipc	ra,0xfffff
    80001dc4:	650080e7          	jalr	1616(ra) # 80001410 <uvmalloc>
    80001dc8:	85aa                	mv	a1,a0
    80001dca:	fd79                	bnez	a0,80001da8 <growproc+0x22>
      return -1;
    80001dcc:	557d                	li	a0,-1
    80001dce:	bff9                	j	80001dac <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dd0:	00b90633          	add	a2,s2,a1
    80001dd4:	6928                	ld	a0,80(a0)
    80001dd6:	fffff097          	auipc	ra,0xfffff
    80001dda:	5f2080e7          	jalr	1522(ra) # 800013c8 <uvmdealloc>
    80001dde:	85aa                	mv	a1,a0
    80001de0:	b7e1                	j	80001da8 <growproc+0x22>

0000000080001de2 <fork>:
{
    80001de2:	7139                	addi	sp,sp,-64
    80001de4:	fc06                	sd	ra,56(sp)
    80001de6:	f822                	sd	s0,48(sp)
    80001de8:	f426                	sd	s1,40(sp)
    80001dea:	f04a                	sd	s2,32(sp)
    80001dec:	ec4e                	sd	s3,24(sp)
    80001dee:	e852                	sd	s4,16(sp)
    80001df0:	e456                	sd	s5,8(sp)
    80001df2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001df4:	00000097          	auipc	ra,0x0
    80001df8:	bb8080e7          	jalr	-1096(ra) # 800019ac <myproc>
    80001dfc:	8aaa                	mv	s5,a0
  if (p->pid > 1)
    80001dfe:	5918                	lw	a4,48(a0)
    80001e00:	4785                	li	a5,1
    80001e02:	00e7d663          	bge	a5,a4,80001e0e <fork+0x2c>
    forked_process = 1;
    80001e06:	00007717          	auipc	a4,0x7
    80001e0a:	b0f72923          	sw	a5,-1262(a4) # 80008918 <forked_process>
  if ((np = allocproc()) == 0)
    80001e0e:	00000097          	auipc	ra,0x0
    80001e12:	dba080e7          	jalr	-582(ra) # 80001bc8 <allocproc>
    80001e16:	89aa                	mv	s3,a0
    80001e18:	10050f63          	beqz	a0,80001f36 <fork+0x154>
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e1c:	048ab603          	ld	a2,72(s5)
    80001e20:	692c                	ld	a1,80(a0)
    80001e22:	050ab503          	ld	a0,80(s5)
    80001e26:	fffff097          	auipc	ra,0xfffff
    80001e2a:	742080e7          	jalr	1858(ra) # 80001568 <uvmcopy>
    80001e2e:	04054c63          	bltz	a0,80001e86 <fork+0xa4>
  np->sz = p->sz;
    80001e32:	048ab783          	ld	a5,72(s5)
    80001e36:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e3a:	058ab683          	ld	a3,88(s5)
    80001e3e:	87b6                	mv	a5,a3
    80001e40:	0589b703          	ld	a4,88(s3)
    80001e44:	12068693          	addi	a3,a3,288
    80001e48:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e4c:	6788                	ld	a0,8(a5)
    80001e4e:	6b8c                	ld	a1,16(a5)
    80001e50:	6f90                	ld	a2,24(a5)
    80001e52:	01073023          	sd	a6,0(a4)
    80001e56:	e708                	sd	a0,8(a4)
    80001e58:	eb0c                	sd	a1,16(a4)
    80001e5a:	ef10                	sd	a2,24(a4)
    80001e5c:	02078793          	addi	a5,a5,32
    80001e60:	02070713          	addi	a4,a4,32
    80001e64:	fed792e3          	bne	a5,a3,80001e48 <fork+0x66>
  np->tmask = p->tmask;
    80001e68:	174aa783          	lw	a5,372(s5)
    80001e6c:	16f9aa23          	sw	a5,372(s3)
  np->trapframe->a0 = 0;
    80001e70:	0589b783          	ld	a5,88(s3)
    80001e74:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e78:	0d0a8493          	addi	s1,s5,208
    80001e7c:	0d098913          	addi	s2,s3,208
    80001e80:	150a8a13          	addi	s4,s5,336
    80001e84:	a00d                	j	80001ea6 <fork+0xc4>
    freeproc(np);
    80001e86:	854e                	mv	a0,s3
    80001e88:	00000097          	auipc	ra,0x0
    80001e8c:	cd6080e7          	jalr	-810(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e90:	854e                	mv	a0,s3
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	df8080e7          	jalr	-520(ra) # 80000c8a <release>
    return -1;
    80001e9a:	597d                	li	s2,-1
    80001e9c:	a059                	j	80001f22 <fork+0x140>
  for (i = 0; i < NOFILE; i++)
    80001e9e:	04a1                	addi	s1,s1,8
    80001ea0:	0921                	addi	s2,s2,8
    80001ea2:	01448b63          	beq	s1,s4,80001eb8 <fork+0xd6>
    if (p->ofile[i])
    80001ea6:	6088                	ld	a0,0(s1)
    80001ea8:	d97d                	beqz	a0,80001e9e <fork+0xbc>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eaa:	00003097          	auipc	ra,0x3
    80001eae:	9d6080e7          	jalr	-1578(ra) # 80004880 <filedup>
    80001eb2:	00a93023          	sd	a0,0(s2)
    80001eb6:	b7e5                	j	80001e9e <fork+0xbc>
  np->cwd = idup(p->cwd);
    80001eb8:	150ab503          	ld	a0,336(s5)
    80001ebc:	00002097          	auipc	ra,0x2
    80001ec0:	b44080e7          	jalr	-1212(ra) # 80003a00 <idup>
    80001ec4:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ec8:	4641                	li	a2,16
    80001eca:	158a8593          	addi	a1,s5,344
    80001ece:	15898513          	addi	a0,s3,344
    80001ed2:	fffff097          	auipc	ra,0xfffff
    80001ed6:	f4a080e7          	jalr	-182(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001eda:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ede:	854e                	mv	a0,s3
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	daa080e7          	jalr	-598(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001ee8:	0000f497          	auipc	s1,0xf
    80001eec:	cc048493          	addi	s1,s1,-832 # 80010ba8 <wait_lock>
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	fffff097          	auipc	ra,0xfffff
    80001ef6:	ce4080e7          	jalr	-796(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001efa:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001efe:	8526                	mv	a0,s1
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	d8a080e7          	jalr	-630(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001f08:	854e                	mv	a0,s3
    80001f0a:	fffff097          	auipc	ra,0xfffff
    80001f0e:	ccc080e7          	jalr	-820(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001f12:	478d                	li	a5,3
    80001f14:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f18:	854e                	mv	a0,s3
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	d70080e7          	jalr	-656(ra) # 80000c8a <release>
}
    80001f22:	854a                	mv	a0,s2
    80001f24:	70e2                	ld	ra,56(sp)
    80001f26:	7442                	ld	s0,48(sp)
    80001f28:	74a2                	ld	s1,40(sp)
    80001f2a:	7902                	ld	s2,32(sp)
    80001f2c:	69e2                	ld	s3,24(sp)
    80001f2e:	6a42                	ld	s4,16(sp)
    80001f30:	6aa2                	ld	s5,8(sp)
    80001f32:	6121                	addi	sp,sp,64
    80001f34:	8082                	ret
    return -1;
    80001f36:	597d                	li	s2,-1
    80001f38:	b7ed                	j	80001f22 <fork+0x140>

0000000080001f3a <scheduler>:
{
    80001f3a:	7139                	addi	sp,sp,-64
    80001f3c:	fc06                	sd	ra,56(sp)
    80001f3e:	f822                	sd	s0,48(sp)
    80001f40:	f426                	sd	s1,40(sp)
    80001f42:	f04a                	sd	s2,32(sp)
    80001f44:	ec4e                	sd	s3,24(sp)
    80001f46:	e852                	sd	s4,16(sp)
    80001f48:	e456                	sd	s5,8(sp)
    80001f4a:	e05a                	sd	s6,0(sp)
    80001f4c:	0080                	addi	s0,sp,64
    80001f4e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f50:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f52:	00779a93          	slli	s5,a5,0x7
    80001f56:	0000f717          	auipc	a4,0xf
    80001f5a:	c3a70713          	addi	a4,a4,-966 # 80010b90 <pid_lock>
    80001f5e:	9756                	add	a4,a4,s5
    80001f60:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f64:	0000f717          	auipc	a4,0xf
    80001f68:	c6470713          	addi	a4,a4,-924 # 80010bc8 <cpus+0x8>
    80001f6c:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001f6e:	498d                	li	s3,3
        p->state = RUNNING;
    80001f70:	4b11                	li	s6,4
        c->proc = p;
    80001f72:	079e                	slli	a5,a5,0x7
    80001f74:	0000fa17          	auipc	s4,0xf
    80001f78:	c1ca0a13          	addi	s4,s4,-996 # 80010b90 <pid_lock>
    80001f7c:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001f7e:	00016917          	auipc	s2,0x16
    80001f82:	04290913          	addi	s2,s2,66 # 80017fc0 <mlfq>
  asm volatile("csrr %0, sstatus"
    80001f86:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f8a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80001f8e:	10079073          	csrw	sstatus,a5
    80001f92:	0000f497          	auipc	s1,0xf
    80001f96:	02e48493          	addi	s1,s1,46 # 80010fc0 <proc>
    80001f9a:	a811                	j	80001fae <scheduler+0x74>
      release(&p->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	cec080e7          	jalr	-788(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001fa6:	1c048493          	addi	s1,s1,448
    80001faa:	fd248ee3          	beq	s1,s2,80001f86 <scheduler+0x4c>
      acquire(&p->lock);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	c26080e7          	jalr	-986(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80001fb8:	4c9c                	lw	a5,24(s1)
    80001fba:	ff3791e3          	bne	a5,s3,80001f9c <scheduler+0x62>
        p->state = RUNNING;
    80001fbe:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fc2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fc6:	06048593          	addi	a1,s1,96
    80001fca:	8556                	mv	a0,s5
    80001fcc:	00001097          	auipc	ra,0x1
    80001fd0:	868080e7          	jalr	-1944(ra) # 80002834 <swtch>
        c->proc = 0;
    80001fd4:	020a3823          	sd	zero,48(s4)
    80001fd8:	b7d1                	j	80001f9c <scheduler+0x62>

0000000080001fda <sched>:
{
    80001fda:	7179                	addi	sp,sp,-48
    80001fdc:	f406                	sd	ra,40(sp)
    80001fde:	f022                	sd	s0,32(sp)
    80001fe0:	ec26                	sd	s1,24(sp)
    80001fe2:	e84a                	sd	s2,16(sp)
    80001fe4:	e44e                	sd	s3,8(sp)
    80001fe6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fe8:	00000097          	auipc	ra,0x0
    80001fec:	9c4080e7          	jalr	-1596(ra) # 800019ac <myproc>
    80001ff0:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	b6a080e7          	jalr	-1174(ra) # 80000b5c <holding>
    80001ffa:	c93d                	beqz	a0,80002070 <sched+0x96>
  asm volatile("mv %0, tp"
    80001ffc:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001ffe:	2781                	sext.w	a5,a5
    80002000:	079e                	slli	a5,a5,0x7
    80002002:	0000f717          	auipc	a4,0xf
    80002006:	b8e70713          	addi	a4,a4,-1138 # 80010b90 <pid_lock>
    8000200a:	97ba                	add	a5,a5,a4
    8000200c:	0a87a703          	lw	a4,168(a5)
    80002010:	4785                	li	a5,1
    80002012:	06f71763          	bne	a4,a5,80002080 <sched+0xa6>
  if (p->state == RUNNING)
    80002016:	4c98                	lw	a4,24(s1)
    80002018:	4791                	li	a5,4
    8000201a:	06f70b63          	beq	a4,a5,80002090 <sched+0xb6>
  asm volatile("csrr %0, sstatus"
    8000201e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002022:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002024:	efb5                	bnez	a5,800020a0 <sched+0xc6>
  asm volatile("mv %0, tp"
    80002026:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002028:	0000f917          	auipc	s2,0xf
    8000202c:	b6890913          	addi	s2,s2,-1176 # 80010b90 <pid_lock>
    80002030:	2781                	sext.w	a5,a5
    80002032:	079e                	slli	a5,a5,0x7
    80002034:	97ca                	add	a5,a5,s2
    80002036:	0ac7a983          	lw	s3,172(a5)
    8000203a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000203c:	2781                	sext.w	a5,a5
    8000203e:	079e                	slli	a5,a5,0x7
    80002040:	0000f597          	auipc	a1,0xf
    80002044:	b8858593          	addi	a1,a1,-1144 # 80010bc8 <cpus+0x8>
    80002048:	95be                	add	a1,a1,a5
    8000204a:	06048513          	addi	a0,s1,96
    8000204e:	00000097          	auipc	ra,0x0
    80002052:	7e6080e7          	jalr	2022(ra) # 80002834 <swtch>
    80002056:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002058:	2781                	sext.w	a5,a5
    8000205a:	079e                	slli	a5,a5,0x7
    8000205c:	993e                	add	s2,s2,a5
    8000205e:	0b392623          	sw	s3,172(s2)
}
    80002062:	70a2                	ld	ra,40(sp)
    80002064:	7402                	ld	s0,32(sp)
    80002066:	64e2                	ld	s1,24(sp)
    80002068:	6942                	ld	s2,16(sp)
    8000206a:	69a2                	ld	s3,8(sp)
    8000206c:	6145                	addi	sp,sp,48
    8000206e:	8082                	ret
    panic("sched p->lock");
    80002070:	00006517          	auipc	a0,0x6
    80002074:	1a850513          	addi	a0,a0,424 # 80008218 <digits+0x1d8>
    80002078:	ffffe097          	auipc	ra,0xffffe
    8000207c:	4c8080e7          	jalr	1224(ra) # 80000540 <panic>
    panic("sched locks");
    80002080:	00006517          	auipc	a0,0x6
    80002084:	1a850513          	addi	a0,a0,424 # 80008228 <digits+0x1e8>
    80002088:	ffffe097          	auipc	ra,0xffffe
    8000208c:	4b8080e7          	jalr	1208(ra) # 80000540 <panic>
    panic("sched running");
    80002090:	00006517          	auipc	a0,0x6
    80002094:	1a850513          	addi	a0,a0,424 # 80008238 <digits+0x1f8>
    80002098:	ffffe097          	auipc	ra,0xffffe
    8000209c:	4a8080e7          	jalr	1192(ra) # 80000540 <panic>
    panic("sched interruptible");
    800020a0:	00006517          	auipc	a0,0x6
    800020a4:	1a850513          	addi	a0,a0,424 # 80008248 <digits+0x208>
    800020a8:	ffffe097          	auipc	ra,0xffffe
    800020ac:	498080e7          	jalr	1176(ra) # 80000540 <panic>

00000000800020b0 <yield>:
{
    800020b0:	1101                	addi	sp,sp,-32
    800020b2:	ec06                	sd	ra,24(sp)
    800020b4:	e822                	sd	s0,16(sp)
    800020b6:	e426                	sd	s1,8(sp)
    800020b8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	8f2080e7          	jalr	-1806(ra) # 800019ac <myproc>
    800020c2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	b12080e7          	jalr	-1262(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800020cc:	478d                	li	a5,3
    800020ce:	cc9c                	sw	a5,24(s1)
  sched();
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	f0a080e7          	jalr	-246(ra) # 80001fda <sched>
  release(&p->lock);
    800020d8:	8526                	mv	a0,s1
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	bb0080e7          	jalr	-1104(ra) # 80000c8a <release>
}
    800020e2:	60e2                	ld	ra,24(sp)
    800020e4:	6442                	ld	s0,16(sp)
    800020e6:	64a2                	ld	s1,8(sp)
    800020e8:	6105                	addi	sp,sp,32
    800020ea:	8082                	ret

00000000800020ec <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800020ec:	7179                	addi	sp,sp,-48
    800020ee:	f406                	sd	ra,40(sp)
    800020f0:	f022                	sd	s0,32(sp)
    800020f2:	ec26                	sd	s1,24(sp)
    800020f4:	e84a                	sd	s2,16(sp)
    800020f6:	e44e                	sd	s3,8(sp)
    800020f8:	1800                	addi	s0,sp,48
    800020fa:	89aa                	mv	s3,a0
    800020fc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	8ae080e7          	jalr	-1874(ra) # 800019ac <myproc>
    80002106:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	ace080e7          	jalr	-1330(ra) # 80000bd6 <acquire>
  release(lk);
    80002110:	854a                	mv	a0,s2
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	b78080e7          	jalr	-1160(ra) # 80000c8a <release>

  // Go to sleep.
  p->sleep_start = ticks;
    8000211a:	00007797          	auipc	a5,0x7
    8000211e:	80e7a783          	lw	a5,-2034(a5) # 80008928 <ticks>
    80002122:	16f4ae23          	sw	a5,380(s1)
  p->chan = chan;
    80002126:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000212a:	4789                	li	a5,2
    8000212c:	cc9c                	sw	a5,24(s1)

  sched();
    8000212e:	00000097          	auipc	ra,0x0
    80002132:	eac080e7          	jalr	-340(ra) # 80001fda <sched>

  // Tidy up.
  p->chan = 0;
    80002136:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000213a:	8526                	mv	a0,s1
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	b4e080e7          	jalr	-1202(ra) # 80000c8a <release>
  acquire(lk);
    80002144:	854a                	mv	a0,s2
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	a90080e7          	jalr	-1392(ra) # 80000bd6 <acquire>
}
    8000214e:	70a2                	ld	ra,40(sp)
    80002150:	7402                	ld	s0,32(sp)
    80002152:	64e2                	ld	s1,24(sp)
    80002154:	6942                	ld	s2,16(sp)
    80002156:	69a2                	ld	s3,8(sp)
    80002158:	6145                	addi	sp,sp,48
    8000215a:	8082                	ret

000000008000215c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000215c:	7139                	addi	sp,sp,-64
    8000215e:	fc06                	sd	ra,56(sp)
    80002160:	f822                	sd	s0,48(sp)
    80002162:	f426                	sd	s1,40(sp)
    80002164:	f04a                	sd	s2,32(sp)
    80002166:	ec4e                	sd	s3,24(sp)
    80002168:	e852                	sd	s4,16(sp)
    8000216a:	e456                	sd	s5,8(sp)
    8000216c:	e05a                	sd	s6,0(sp)
    8000216e:	0080                	addi	s0,sp,64
    80002170:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002172:	0000f497          	auipc	s1,0xf
    80002176:	e4e48493          	addi	s1,s1,-434 # 80010fc0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    8000217a:	4989                	li	s3,2
      {
        p->sleeping_ticks += (ticks - p->sleep_start);
    8000217c:	00006b17          	auipc	s6,0x6
    80002180:	7acb0b13          	addi	s6,s6,1964 # 80008928 <ticks>
        p->state = RUNNABLE;
    80002184:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002186:	00016917          	auipc	s2,0x16
    8000218a:	e3a90913          	addi	s2,s2,-454 # 80017fc0 <mlfq>
    8000218e:	a811                	j	800021a2 <wakeup+0x46>
      }
      release(&p->lock);
    80002190:	8526                	mv	a0,s1
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	af8080e7          	jalr	-1288(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000219a:	1c048493          	addi	s1,s1,448
    8000219e:	05248063          	beq	s1,s2,800021de <wakeup+0x82>
    if (p != myproc())
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	80a080e7          	jalr	-2038(ra) # 800019ac <myproc>
    800021aa:	fea488e3          	beq	s1,a0,8000219a <wakeup+0x3e>
      acquire(&p->lock);
    800021ae:	8526                	mv	a0,s1
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	a26080e7          	jalr	-1498(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800021b8:	4c9c                	lw	a5,24(s1)
    800021ba:	fd379be3          	bne	a5,s3,80002190 <wakeup+0x34>
    800021be:	709c                	ld	a5,32(s1)
    800021c0:	fd4798e3          	bne	a5,s4,80002190 <wakeup+0x34>
        p->sleeping_ticks += (ticks - p->sleep_start);
    800021c4:	1844a703          	lw	a4,388(s1)
    800021c8:	000b2783          	lw	a5,0(s6)
    800021cc:	9fb9                	addw	a5,a5,a4
    800021ce:	17c4a703          	lw	a4,380(s1)
    800021d2:	9f99                	subw	a5,a5,a4
    800021d4:	18f4a223          	sw	a5,388(s1)
        p->state = RUNNABLE;
    800021d8:	0154ac23          	sw	s5,24(s1)
    800021dc:	bf55                	j	80002190 <wakeup+0x34>
    }
  }
}
    800021de:	70e2                	ld	ra,56(sp)
    800021e0:	7442                	ld	s0,48(sp)
    800021e2:	74a2                	ld	s1,40(sp)
    800021e4:	7902                	ld	s2,32(sp)
    800021e6:	69e2                	ld	s3,24(sp)
    800021e8:	6a42                	ld	s4,16(sp)
    800021ea:	6aa2                	ld	s5,8(sp)
    800021ec:	6b02                	ld	s6,0(sp)
    800021ee:	6121                	addi	sp,sp,64
    800021f0:	8082                	ret

00000000800021f2 <reparent>:
{
    800021f2:	7179                	addi	sp,sp,-48
    800021f4:	f406                	sd	ra,40(sp)
    800021f6:	f022                	sd	s0,32(sp)
    800021f8:	ec26                	sd	s1,24(sp)
    800021fa:	e84a                	sd	s2,16(sp)
    800021fc:	e44e                	sd	s3,8(sp)
    800021fe:	e052                	sd	s4,0(sp)
    80002200:	1800                	addi	s0,sp,48
    80002202:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002204:	0000f497          	auipc	s1,0xf
    80002208:	dbc48493          	addi	s1,s1,-580 # 80010fc0 <proc>
      pp->parent = initproc;
    8000220c:	00006a17          	auipc	s4,0x6
    80002210:	714a0a13          	addi	s4,s4,1812 # 80008920 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002214:	00016997          	auipc	s3,0x16
    80002218:	dac98993          	addi	s3,s3,-596 # 80017fc0 <mlfq>
    8000221c:	a029                	j	80002226 <reparent+0x34>
    8000221e:	1c048493          	addi	s1,s1,448
    80002222:	01348d63          	beq	s1,s3,8000223c <reparent+0x4a>
    if (pp->parent == p)
    80002226:	7c9c                	ld	a5,56(s1)
    80002228:	ff279be3          	bne	a5,s2,8000221e <reparent+0x2c>
      pp->parent = initproc;
    8000222c:	000a3503          	ld	a0,0(s4)
    80002230:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002232:	00000097          	auipc	ra,0x0
    80002236:	f2a080e7          	jalr	-214(ra) # 8000215c <wakeup>
    8000223a:	b7d5                	j	8000221e <reparent+0x2c>
}
    8000223c:	70a2                	ld	ra,40(sp)
    8000223e:	7402                	ld	s0,32(sp)
    80002240:	64e2                	ld	s1,24(sp)
    80002242:	6942                	ld	s2,16(sp)
    80002244:	69a2                	ld	s3,8(sp)
    80002246:	6a02                	ld	s4,0(sp)
    80002248:	6145                	addi	sp,sp,48
    8000224a:	8082                	ret

000000008000224c <exit>:
{
    8000224c:	7179                	addi	sp,sp,-48
    8000224e:	f406                	sd	ra,40(sp)
    80002250:	f022                	sd	s0,32(sp)
    80002252:	ec26                	sd	s1,24(sp)
    80002254:	e84a                	sd	s2,16(sp)
    80002256:	e44e                	sd	s3,8(sp)
    80002258:	e052                	sd	s4,0(sp)
    8000225a:	1800                	addi	s0,sp,48
    8000225c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	74e080e7          	jalr	1870(ra) # 800019ac <myproc>
    80002266:	89aa                	mv	s3,a0
  if (p == initproc)
    80002268:	00006797          	auipc	a5,0x6
    8000226c:	6b87b783          	ld	a5,1720(a5) # 80008920 <initproc>
    80002270:	0d050493          	addi	s1,a0,208
    80002274:	15050913          	addi	s2,a0,336
    80002278:	02a79363          	bne	a5,a0,8000229e <exit+0x52>
    panic("init exiting");
    8000227c:	00006517          	auipc	a0,0x6
    80002280:	fe450513          	addi	a0,a0,-28 # 80008260 <digits+0x220>
    80002284:	ffffe097          	auipc	ra,0xffffe
    80002288:	2bc080e7          	jalr	700(ra) # 80000540 <panic>
      fileclose(f);
    8000228c:	00002097          	auipc	ra,0x2
    80002290:	646080e7          	jalr	1606(ra) # 800048d2 <fileclose>
      p->ofile[fd] = 0;
    80002294:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002298:	04a1                	addi	s1,s1,8
    8000229a:	01248563          	beq	s1,s2,800022a4 <exit+0x58>
    if (p->ofile[fd])
    8000229e:	6088                	ld	a0,0(s1)
    800022a0:	f575                	bnez	a0,8000228c <exit+0x40>
    800022a2:	bfdd                	j	80002298 <exit+0x4c>
  begin_op();
    800022a4:	00002097          	auipc	ra,0x2
    800022a8:	166080e7          	jalr	358(ra) # 8000440a <begin_op>
  iput(p->cwd);
    800022ac:	1509b503          	ld	a0,336(s3)
    800022b0:	00002097          	auipc	ra,0x2
    800022b4:	948080e7          	jalr	-1720(ra) # 80003bf8 <iput>
  end_op();
    800022b8:	00002097          	auipc	ra,0x2
    800022bc:	1d0080e7          	jalr	464(ra) # 80004488 <end_op>
  p->cwd = 0;
    800022c0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022c4:	0000f497          	auipc	s1,0xf
    800022c8:	8e448493          	addi	s1,s1,-1820 # 80010ba8 <wait_lock>
    800022cc:	8526                	mv	a0,s1
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	908080e7          	jalr	-1784(ra) # 80000bd6 <acquire>
  reparent(p);
    800022d6:	854e                	mv	a0,s3
    800022d8:	00000097          	auipc	ra,0x0
    800022dc:	f1a080e7          	jalr	-230(ra) # 800021f2 <reparent>
  wakeup(p->parent);
    800022e0:	0389b503          	ld	a0,56(s3)
    800022e4:	00000097          	auipc	ra,0x0
    800022e8:	e78080e7          	jalr	-392(ra) # 8000215c <wakeup>
  acquire(&p->lock);
    800022ec:	854e                	mv	a0,s3
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	8e8080e7          	jalr	-1816(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800022f6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022fa:	4795                	li	a5,5
    800022fc:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002300:	00006797          	auipc	a5,0x6
    80002304:	6287a783          	lw	a5,1576(a5) # 80008928 <ticks>
    80002308:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000230c:	8526                	mv	a0,s1
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	97c080e7          	jalr	-1668(ra) # 80000c8a <release>
  sched();
    80002316:	00000097          	auipc	ra,0x0
    8000231a:	cc4080e7          	jalr	-828(ra) # 80001fda <sched>
  panic("zombie exit");
    8000231e:	00006517          	auipc	a0,0x6
    80002322:	f5250513          	addi	a0,a0,-174 # 80008270 <digits+0x230>
    80002326:	ffffe097          	auipc	ra,0xffffe
    8000232a:	21a080e7          	jalr	538(ra) # 80000540 <panic>

000000008000232e <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000232e:	7179                	addi	sp,sp,-48
    80002330:	f406                	sd	ra,40(sp)
    80002332:	f022                	sd	s0,32(sp)
    80002334:	ec26                	sd	s1,24(sp)
    80002336:	e84a                	sd	s2,16(sp)
    80002338:	e44e                	sd	s3,8(sp)
    8000233a:	1800                	addi	s0,sp,48
    8000233c:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000233e:	0000f497          	auipc	s1,0xf
    80002342:	c8248493          	addi	s1,s1,-894 # 80010fc0 <proc>
    80002346:	00016997          	auipc	s3,0x16
    8000234a:	c7a98993          	addi	s3,s3,-902 # 80017fc0 <mlfq>
  {
    acquire(&p->lock);
    8000234e:	8526                	mv	a0,s1
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	886080e7          	jalr	-1914(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    80002358:	589c                	lw	a5,48(s1)
    8000235a:	01278d63          	beq	a5,s2,80002374 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000235e:	8526                	mv	a0,s1
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002368:	1c048493          	addi	s1,s1,448
    8000236c:	ff3491e3          	bne	s1,s3,8000234e <kill+0x20>
  }
  return -1;
    80002370:	557d                	li	a0,-1
    80002372:	a829                	j	8000238c <kill+0x5e>
      p->killed = 1;
    80002374:	4785                	li	a5,1
    80002376:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002378:	4c98                	lw	a4,24(s1)
    8000237a:	4789                	li	a5,2
    8000237c:	00f70f63          	beq	a4,a5,8000239a <kill+0x6c>
      release(&p->lock);
    80002380:	8526                	mv	a0,s1
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	908080e7          	jalr	-1784(ra) # 80000c8a <release>
      return 0;
    8000238a:	4501                	li	a0,0
}
    8000238c:	70a2                	ld	ra,40(sp)
    8000238e:	7402                	ld	s0,32(sp)
    80002390:	64e2                	ld	s1,24(sp)
    80002392:	6942                	ld	s2,16(sp)
    80002394:	69a2                	ld	s3,8(sp)
    80002396:	6145                	addi	sp,sp,48
    80002398:	8082                	ret
        p->state = RUNNABLE;
    8000239a:	478d                	li	a5,3
    8000239c:	cc9c                	sw	a5,24(s1)
    8000239e:	b7cd                	j	80002380 <kill+0x52>

00000000800023a0 <setkilled>:

void setkilled(struct proc *p)
{
    800023a0:	1101                	addi	sp,sp,-32
    800023a2:	ec06                	sd	ra,24(sp)
    800023a4:	e822                	sd	s0,16(sp)
    800023a6:	e426                	sd	s1,8(sp)
    800023a8:	1000                	addi	s0,sp,32
    800023aa:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	82a080e7          	jalr	-2006(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800023b4:	4785                	li	a5,1
    800023b6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023b8:	8526                	mv	a0,s1
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	8d0080e7          	jalr	-1840(ra) # 80000c8a <release>
}
    800023c2:	60e2                	ld	ra,24(sp)
    800023c4:	6442                	ld	s0,16(sp)
    800023c6:	64a2                	ld	s1,8(sp)
    800023c8:	6105                	addi	sp,sp,32
    800023ca:	8082                	ret

00000000800023cc <killed>:

int killed(struct proc *p)
{
    800023cc:	1101                	addi	sp,sp,-32
    800023ce:	ec06                	sd	ra,24(sp)
    800023d0:	e822                	sd	s0,16(sp)
    800023d2:	e426                	sd	s1,8(sp)
    800023d4:	e04a                	sd	s2,0(sp)
    800023d6:	1000                	addi	s0,sp,32
    800023d8:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023da:	ffffe097          	auipc	ra,0xffffe
    800023de:	7fc080e7          	jalr	2044(ra) # 80000bd6 <acquire>
  k = p->killed;
    800023e2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023e6:	8526                	mv	a0,s1
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	8a2080e7          	jalr	-1886(ra) # 80000c8a <release>
  return k;
}
    800023f0:	854a                	mv	a0,s2
    800023f2:	60e2                	ld	ra,24(sp)
    800023f4:	6442                	ld	s0,16(sp)
    800023f6:	64a2                	ld	s1,8(sp)
    800023f8:	6902                	ld	s2,0(sp)
    800023fa:	6105                	addi	sp,sp,32
    800023fc:	8082                	ret

00000000800023fe <wait>:
{
    800023fe:	715d                	addi	sp,sp,-80
    80002400:	e486                	sd	ra,72(sp)
    80002402:	e0a2                	sd	s0,64(sp)
    80002404:	fc26                	sd	s1,56(sp)
    80002406:	f84a                	sd	s2,48(sp)
    80002408:	f44e                	sd	s3,40(sp)
    8000240a:	f052                	sd	s4,32(sp)
    8000240c:	ec56                	sd	s5,24(sp)
    8000240e:	e85a                	sd	s6,16(sp)
    80002410:	e45e                	sd	s7,8(sp)
    80002412:	e062                	sd	s8,0(sp)
    80002414:	0880                	addi	s0,sp,80
    80002416:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	594080e7          	jalr	1428(ra) # 800019ac <myproc>
    80002420:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002422:	0000e517          	auipc	a0,0xe
    80002426:	78650513          	addi	a0,a0,1926 # 80010ba8 <wait_lock>
    8000242a:	ffffe097          	auipc	ra,0xffffe
    8000242e:	7ac080e7          	jalr	1964(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002432:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002434:	4a15                	li	s4,5
        havekids = 1;
    80002436:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002438:	00016997          	auipc	s3,0x16
    8000243c:	b8898993          	addi	s3,s3,-1144 # 80017fc0 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002440:	0000ec17          	auipc	s8,0xe
    80002444:	768c0c13          	addi	s8,s8,1896 # 80010ba8 <wait_lock>
    havekids = 0;
    80002448:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000244a:	0000f497          	auipc	s1,0xf
    8000244e:	b7648493          	addi	s1,s1,-1162 # 80010fc0 <proc>
    80002452:	a0bd                	j	800024c0 <wait+0xc2>
          pid = pp->pid;
    80002454:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002458:	000b0e63          	beqz	s6,80002474 <wait+0x76>
    8000245c:	4691                	li	a3,4
    8000245e:	02c48613          	addi	a2,s1,44
    80002462:	85da                	mv	a1,s6
    80002464:	05093503          	ld	a0,80(s2)
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	204080e7          	jalr	516(ra) # 8000166c <copyout>
    80002470:	02054563          	bltz	a0,8000249a <wait+0x9c>
          freeproc(pp);
    80002474:	8526                	mv	a0,s1
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	6e8080e7          	jalr	1768(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    8000247e:	8526                	mv	a0,s1
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	80a080e7          	jalr	-2038(ra) # 80000c8a <release>
          release(&wait_lock);
    80002488:	0000e517          	auipc	a0,0xe
    8000248c:	72050513          	addi	a0,a0,1824 # 80010ba8 <wait_lock>
    80002490:	ffffe097          	auipc	ra,0xffffe
    80002494:	7fa080e7          	jalr	2042(ra) # 80000c8a <release>
          return pid;
    80002498:	a0b5                	j	80002504 <wait+0x106>
            release(&pp->lock);
    8000249a:	8526                	mv	a0,s1
    8000249c:	ffffe097          	auipc	ra,0xffffe
    800024a0:	7ee080e7          	jalr	2030(ra) # 80000c8a <release>
            release(&wait_lock);
    800024a4:	0000e517          	auipc	a0,0xe
    800024a8:	70450513          	addi	a0,a0,1796 # 80010ba8 <wait_lock>
    800024ac:	ffffe097          	auipc	ra,0xffffe
    800024b0:	7de080e7          	jalr	2014(ra) # 80000c8a <release>
            return -1;
    800024b4:	59fd                	li	s3,-1
    800024b6:	a0b9                	j	80002504 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024b8:	1c048493          	addi	s1,s1,448
    800024bc:	03348463          	beq	s1,s3,800024e4 <wait+0xe6>
      if (pp->parent == p)
    800024c0:	7c9c                	ld	a5,56(s1)
    800024c2:	ff279be3          	bne	a5,s2,800024b8 <wait+0xba>
        acquire(&pp->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	70e080e7          	jalr	1806(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    800024d0:	4c9c                	lw	a5,24(s1)
    800024d2:	f94781e3          	beq	a5,s4,80002454 <wait+0x56>
        release(&pp->lock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	ffffe097          	auipc	ra,0xffffe
    800024dc:	7b2080e7          	jalr	1970(ra) # 80000c8a <release>
        havekids = 1;
    800024e0:	8756                	mv	a4,s5
    800024e2:	bfd9                	j	800024b8 <wait+0xba>
    if (!havekids || killed(p))
    800024e4:	c719                	beqz	a4,800024f2 <wait+0xf4>
    800024e6:	854a                	mv	a0,s2
    800024e8:	00000097          	auipc	ra,0x0
    800024ec:	ee4080e7          	jalr	-284(ra) # 800023cc <killed>
    800024f0:	c51d                	beqz	a0,8000251e <wait+0x120>
      release(&wait_lock);
    800024f2:	0000e517          	auipc	a0,0xe
    800024f6:	6b650513          	addi	a0,a0,1718 # 80010ba8 <wait_lock>
    800024fa:	ffffe097          	auipc	ra,0xffffe
    800024fe:	790080e7          	jalr	1936(ra) # 80000c8a <release>
      return -1;
    80002502:	59fd                	li	s3,-1
}
    80002504:	854e                	mv	a0,s3
    80002506:	60a6                	ld	ra,72(sp)
    80002508:	6406                	ld	s0,64(sp)
    8000250a:	74e2                	ld	s1,56(sp)
    8000250c:	7942                	ld	s2,48(sp)
    8000250e:	79a2                	ld	s3,40(sp)
    80002510:	7a02                	ld	s4,32(sp)
    80002512:	6ae2                	ld	s5,24(sp)
    80002514:	6b42                	ld	s6,16(sp)
    80002516:	6ba2                	ld	s7,8(sp)
    80002518:	6c02                	ld	s8,0(sp)
    8000251a:	6161                	addi	sp,sp,80
    8000251c:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000251e:	85e2                	mv	a1,s8
    80002520:	854a                	mv	a0,s2
    80002522:	00000097          	auipc	ra,0x0
    80002526:	bca080e7          	jalr	-1078(ra) # 800020ec <sleep>
    havekids = 0;
    8000252a:	bf39                	j	80002448 <wait+0x4a>

000000008000252c <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000252c:	7179                	addi	sp,sp,-48
    8000252e:	f406                	sd	ra,40(sp)
    80002530:	f022                	sd	s0,32(sp)
    80002532:	ec26                	sd	s1,24(sp)
    80002534:	e84a                	sd	s2,16(sp)
    80002536:	e44e                	sd	s3,8(sp)
    80002538:	e052                	sd	s4,0(sp)
    8000253a:	1800                	addi	s0,sp,48
    8000253c:	84aa                	mv	s1,a0
    8000253e:	892e                	mv	s2,a1
    80002540:	89b2                	mv	s3,a2
    80002542:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	468080e7          	jalr	1128(ra) # 800019ac <myproc>
  if (user_dst)
    8000254c:	c08d                	beqz	s1,8000256e <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000254e:	86d2                	mv	a3,s4
    80002550:	864e                	mv	a2,s3
    80002552:	85ca                	mv	a1,s2
    80002554:	6928                	ld	a0,80(a0)
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	116080e7          	jalr	278(ra) # 8000166c <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000255e:	70a2                	ld	ra,40(sp)
    80002560:	7402                	ld	s0,32(sp)
    80002562:	64e2                	ld	s1,24(sp)
    80002564:	6942                	ld	s2,16(sp)
    80002566:	69a2                	ld	s3,8(sp)
    80002568:	6a02                	ld	s4,0(sp)
    8000256a:	6145                	addi	sp,sp,48
    8000256c:	8082                	ret
    memmove((char *)dst, src, len);
    8000256e:	000a061b          	sext.w	a2,s4
    80002572:	85ce                	mv	a1,s3
    80002574:	854a                	mv	a0,s2
    80002576:	ffffe097          	auipc	ra,0xffffe
    8000257a:	7b8080e7          	jalr	1976(ra) # 80000d2e <memmove>
    return 0;
    8000257e:	8526                	mv	a0,s1
    80002580:	bff9                	j	8000255e <either_copyout+0x32>

0000000080002582 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002582:	7179                	addi	sp,sp,-48
    80002584:	f406                	sd	ra,40(sp)
    80002586:	f022                	sd	s0,32(sp)
    80002588:	ec26                	sd	s1,24(sp)
    8000258a:	e84a                	sd	s2,16(sp)
    8000258c:	e44e                	sd	s3,8(sp)
    8000258e:	e052                	sd	s4,0(sp)
    80002590:	1800                	addi	s0,sp,48
    80002592:	892a                	mv	s2,a0
    80002594:	84ae                	mv	s1,a1
    80002596:	89b2                	mv	s3,a2
    80002598:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	412080e7          	jalr	1042(ra) # 800019ac <myproc>
  if (user_src)
    800025a2:	c08d                	beqz	s1,800025c4 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800025a4:	86d2                	mv	a3,s4
    800025a6:	864e                	mv	a2,s3
    800025a8:	85ca                	mv	a1,s2
    800025aa:	6928                	ld	a0,80(a0)
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	14c080e7          	jalr	332(ra) # 800016f8 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800025b4:	70a2                	ld	ra,40(sp)
    800025b6:	7402                	ld	s0,32(sp)
    800025b8:	64e2                	ld	s1,24(sp)
    800025ba:	6942                	ld	s2,16(sp)
    800025bc:	69a2                	ld	s3,8(sp)
    800025be:	6a02                	ld	s4,0(sp)
    800025c0:	6145                	addi	sp,sp,48
    800025c2:	8082                	ret
    memmove(dst, (char *)src, len);
    800025c4:	000a061b          	sext.w	a2,s4
    800025c8:	85ce                	mv	a1,s3
    800025ca:	854a                	mv	a0,s2
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	762080e7          	jalr	1890(ra) # 80000d2e <memmove>
    return 0;
    800025d4:	8526                	mv	a0,s1
    800025d6:	bff9                	j	800025b4 <either_copyin+0x32>

00000000800025d8 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800025d8:	715d                	addi	sp,sp,-80
    800025da:	e486                	sd	ra,72(sp)
    800025dc:	e0a2                	sd	s0,64(sp)
    800025de:	fc26                	sd	s1,56(sp)
    800025e0:	f84a                	sd	s2,48(sp)
    800025e2:	f44e                	sd	s3,40(sp)
    800025e4:	f052                	sd	s4,32(sp)
    800025e6:	ec56                	sd	s5,24(sp)
    800025e8:	e85a                	sd	s6,16(sp)
    800025ea:	e45e                	sd	s7,8(sp)
    800025ec:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800025ee:	00006517          	auipc	a0,0x6
    800025f2:	ada50513          	addi	a0,a0,-1318 # 800080c8 <digits+0x88>
    800025f6:	ffffe097          	auipc	ra,0xffffe
    800025fa:	f94080e7          	jalr	-108(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800025fe:	0000f497          	auipc	s1,0xf
    80002602:	b1a48493          	addi	s1,s1,-1254 # 80011118 <proc+0x158>
    80002606:	00016917          	auipc	s2,0x16
    8000260a:	b1290913          	addi	s2,s2,-1262 # 80018118 <mlfq+0x158>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000260e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002610:	00006997          	auipc	s3,0x6
    80002614:	c7098993          	addi	s3,s3,-912 # 80008280 <digits+0x240>
    printf("%d %s %s ctime=%d", p->pid, state, p->name, p->ctime);
    80002618:	00006a97          	auipc	s5,0x6
    8000261c:	c70a8a93          	addi	s5,s5,-912 # 80008288 <digits+0x248>
    printf("\n");
    80002620:	00006a17          	auipc	s4,0x6
    80002624:	aa8a0a13          	addi	s4,s4,-1368 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002628:	00006b97          	auipc	s7,0x6
    8000262c:	ca8b8b93          	addi	s7,s7,-856 # 800082d0 <states.0>
    80002630:	a015                	j	80002654 <procdump+0x7c>
    printf("%d %s %s ctime=%d", p->pid, state, p->name, p->ctime);
    80002632:	4ad8                	lw	a4,20(a3)
    80002634:	ed86a583          	lw	a1,-296(a3)
    80002638:	8556                	mv	a0,s5
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	f50080e7          	jalr	-176(ra) # 8000058a <printf>
    printf("\n");
    80002642:	8552                	mv	a0,s4
    80002644:	ffffe097          	auipc	ra,0xffffe
    80002648:	f46080e7          	jalr	-186(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000264c:	1c048493          	addi	s1,s1,448
    80002650:	03248263          	beq	s1,s2,80002674 <procdump+0x9c>
    if (p->state == UNUSED)
    80002654:	86a6                	mv	a3,s1
    80002656:	ec04a783          	lw	a5,-320(s1)
    8000265a:	dbed                	beqz	a5,8000264c <procdump+0x74>
      state = "???";
    8000265c:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000265e:	fcfb6ae3          	bltu	s6,a5,80002632 <procdump+0x5a>
    80002662:	02079713          	slli	a4,a5,0x20
    80002666:	01d75793          	srli	a5,a4,0x1d
    8000266a:	97de                	add	a5,a5,s7
    8000266c:	6390                	ld	a2,0(a5)
    8000266e:	f271                	bnez	a2,80002632 <procdump+0x5a>
      state = "???";
    80002670:	864e                	mv	a2,s3
    80002672:	b7c1                	j	80002632 <procdump+0x5a>
  }
}
    80002674:	60a6                	ld	ra,72(sp)
    80002676:	6406                	ld	s0,64(sp)
    80002678:	74e2                	ld	s1,56(sp)
    8000267a:	7942                	ld	s2,48(sp)
    8000267c:	79a2                	ld	s3,40(sp)
    8000267e:	7a02                	ld	s4,32(sp)
    80002680:	6ae2                	ld	s5,24(sp)
    80002682:	6b42                	ld	s6,16(sp)
    80002684:	6ba2                	ld	s7,8(sp)
    80002686:	6161                	addi	sp,sp,80
    80002688:	8082                	ret

000000008000268a <waitx>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    8000268a:	711d                	addi	sp,sp,-96
    8000268c:	ec86                	sd	ra,88(sp)
    8000268e:	e8a2                	sd	s0,80(sp)
    80002690:	e4a6                	sd	s1,72(sp)
    80002692:	e0ca                	sd	s2,64(sp)
    80002694:	fc4e                	sd	s3,56(sp)
    80002696:	f852                	sd	s4,48(sp)
    80002698:	f456                	sd	s5,40(sp)
    8000269a:	f05a                	sd	s6,32(sp)
    8000269c:	ec5e                	sd	s7,24(sp)
    8000269e:	e862                	sd	s8,16(sp)
    800026a0:	e466                	sd	s9,8(sp)
    800026a2:	e06a                	sd	s10,0(sp)
    800026a4:	1080                	addi	s0,sp,96
    800026a6:	8b2a                	mv	s6,a0
    800026a8:	8bae                	mv	s7,a1
    800026aa:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800026ac:	fffff097          	auipc	ra,0xfffff
    800026b0:	300080e7          	jalr	768(ra) # 800019ac <myproc>
    800026b4:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800026b6:	0000e517          	auipc	a0,0xe
    800026ba:	4f250513          	addi	a0,a0,1266 # 80010ba8 <wait_lock>
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	518080e7          	jalr	1304(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800026c6:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800026c8:	4a15                	li	s4,5
        havekids = 1;
    800026ca:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800026cc:	00016997          	auipc	s3,0x16
    800026d0:	8f498993          	addi	s3,s3,-1804 # 80017fc0 <mlfq>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800026d4:	0000ed17          	auipc	s10,0xe
    800026d8:	4d4d0d13          	addi	s10,s10,1236 # 80010ba8 <wait_lock>
    havekids = 0;
    800026dc:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800026de:	0000f497          	auipc	s1,0xf
    800026e2:	8e248493          	addi	s1,s1,-1822 # 80010fc0 <proc>
    800026e6:	a059                	j	8000276c <waitx+0xe2>
          pid = np->pid;
    800026e8:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800026ec:	1684a783          	lw	a5,360(s1)
    800026f0:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800026f4:	16c4a703          	lw	a4,364(s1)
    800026f8:	9f3d                	addw	a4,a4,a5
    800026fa:	1704a783          	lw	a5,368(s1)
    800026fe:	9f99                	subw	a5,a5,a4
    80002700:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002704:	000b0e63          	beqz	s6,80002720 <waitx+0x96>
    80002708:	4691                	li	a3,4
    8000270a:	02c48613          	addi	a2,s1,44
    8000270e:	85da                	mv	a1,s6
    80002710:	05093503          	ld	a0,80(s2)
    80002714:	fffff097          	auipc	ra,0xfffff
    80002718:	f58080e7          	jalr	-168(ra) # 8000166c <copyout>
    8000271c:	02054563          	bltz	a0,80002746 <waitx+0xbc>
          freeproc(np);
    80002720:	8526                	mv	a0,s1
    80002722:	fffff097          	auipc	ra,0xfffff
    80002726:	43c080e7          	jalr	1084(ra) # 80001b5e <freeproc>
          release(&np->lock);
    8000272a:	8526                	mv	a0,s1
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	55e080e7          	jalr	1374(ra) # 80000c8a <release>
          release(&wait_lock);
    80002734:	0000e517          	auipc	a0,0xe
    80002738:	47450513          	addi	a0,a0,1140 # 80010ba8 <wait_lock>
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	54e080e7          	jalr	1358(ra) # 80000c8a <release>
          return pid;
    80002744:	a09d                	j	800027aa <waitx+0x120>
            release(&np->lock);
    80002746:	8526                	mv	a0,s1
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	542080e7          	jalr	1346(ra) # 80000c8a <release>
            release(&wait_lock);
    80002750:	0000e517          	auipc	a0,0xe
    80002754:	45850513          	addi	a0,a0,1112 # 80010ba8 <wait_lock>
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	532080e7          	jalr	1330(ra) # 80000c8a <release>
            return -1;
    80002760:	59fd                	li	s3,-1
    80002762:	a0a1                	j	800027aa <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002764:	1c048493          	addi	s1,s1,448
    80002768:	03348463          	beq	s1,s3,80002790 <waitx+0x106>
      if (np->parent == p)
    8000276c:	7c9c                	ld	a5,56(s1)
    8000276e:	ff279be3          	bne	a5,s2,80002764 <waitx+0xda>
        acquire(&np->lock);
    80002772:	8526                	mv	a0,s1
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	462080e7          	jalr	1122(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    8000277c:	4c9c                	lw	a5,24(s1)
    8000277e:	f74785e3          	beq	a5,s4,800026e8 <waitx+0x5e>
        release(&np->lock);
    80002782:	8526                	mv	a0,s1
    80002784:	ffffe097          	auipc	ra,0xffffe
    80002788:	506080e7          	jalr	1286(ra) # 80000c8a <release>
        havekids = 1;
    8000278c:	8756                	mv	a4,s5
    8000278e:	bfd9                	j	80002764 <waitx+0xda>
    if (!havekids || p->killed)
    80002790:	c701                	beqz	a4,80002798 <waitx+0x10e>
    80002792:	02892783          	lw	a5,40(s2)
    80002796:	cb8d                	beqz	a5,800027c8 <waitx+0x13e>
      release(&wait_lock);
    80002798:	0000e517          	auipc	a0,0xe
    8000279c:	41050513          	addi	a0,a0,1040 # 80010ba8 <wait_lock>
    800027a0:	ffffe097          	auipc	ra,0xffffe
    800027a4:	4ea080e7          	jalr	1258(ra) # 80000c8a <release>
      return -1;
    800027a8:	59fd                	li	s3,-1
  }
}
    800027aa:	854e                	mv	a0,s3
    800027ac:	60e6                	ld	ra,88(sp)
    800027ae:	6446                	ld	s0,80(sp)
    800027b0:	64a6                	ld	s1,72(sp)
    800027b2:	6906                	ld	s2,64(sp)
    800027b4:	79e2                	ld	s3,56(sp)
    800027b6:	7a42                	ld	s4,48(sp)
    800027b8:	7aa2                	ld	s5,40(sp)
    800027ba:	7b02                	ld	s6,32(sp)
    800027bc:	6be2                	ld	s7,24(sp)
    800027be:	6c42                	ld	s8,16(sp)
    800027c0:	6ca2                	ld	s9,8(sp)
    800027c2:	6d02                	ld	s10,0(sp)
    800027c4:	6125                	addi	sp,sp,96
    800027c6:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027c8:	85ea                	mv	a1,s10
    800027ca:	854a                	mv	a0,s2
    800027cc:	00000097          	auipc	ra,0x0
    800027d0:	920080e7          	jalr	-1760(ra) # 800020ec <sleep>
    havekids = 0;
    800027d4:	b721                	j	800026dc <waitx+0x52>

00000000800027d6 <update_time>:

void update_time()
{
    800027d6:	7179                	addi	sp,sp,-48
    800027d8:	f406                	sd	ra,40(sp)
    800027da:	f022                	sd	s0,32(sp)
    800027dc:	ec26                	sd	s1,24(sp)
    800027de:	e84a                	sd	s2,16(sp)
    800027e0:	e44e                	sd	s3,8(sp)
    800027e2:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    800027e4:	0000e497          	auipc	s1,0xe
    800027e8:	7dc48493          	addi	s1,s1,2012 # 80010fc0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    800027ec:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    800027ee:	00015917          	auipc	s2,0x15
    800027f2:	7d290913          	addi	s2,s2,2002 # 80017fc0 <mlfq>
    800027f6:	a811                	j	8000280a <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    800027f8:	8526                	mv	a0,s1
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	490080e7          	jalr	1168(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002802:	1c048493          	addi	s1,s1,448
    80002806:	03248063          	beq	s1,s2,80002826 <update_time+0x50>
    acquire(&p->lock);
    8000280a:	8526                	mv	a0,s1
    8000280c:	ffffe097          	auipc	ra,0xffffe
    80002810:	3ca080e7          	jalr	970(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    80002814:	4c9c                	lw	a5,24(s1)
    80002816:	ff3791e3          	bne	a5,s3,800027f8 <update_time+0x22>
      p->rtime++;
    8000281a:	1684a783          	lw	a5,360(s1)
    8000281e:	2785                	addiw	a5,a5,1
    80002820:	16f4a423          	sw	a5,360(s1)
    80002824:	bfd1                	j	800027f8 <update_time+0x22>
  }
    80002826:	70a2                	ld	ra,40(sp)
    80002828:	7402                	ld	s0,32(sp)
    8000282a:	64e2                	ld	s1,24(sp)
    8000282c:	6942                	ld	s2,16(sp)
    8000282e:	69a2                	ld	s3,8(sp)
    80002830:	6145                	addi	sp,sp,48
    80002832:	8082                	ret

0000000080002834 <swtch>:
    80002834:	00153023          	sd	ra,0(a0)
    80002838:	00253423          	sd	sp,8(a0)
    8000283c:	e900                	sd	s0,16(a0)
    8000283e:	ed04                	sd	s1,24(a0)
    80002840:	03253023          	sd	s2,32(a0)
    80002844:	03353423          	sd	s3,40(a0)
    80002848:	03453823          	sd	s4,48(a0)
    8000284c:	03553c23          	sd	s5,56(a0)
    80002850:	05653023          	sd	s6,64(a0)
    80002854:	05753423          	sd	s7,72(a0)
    80002858:	05853823          	sd	s8,80(a0)
    8000285c:	05953c23          	sd	s9,88(a0)
    80002860:	07a53023          	sd	s10,96(a0)
    80002864:	07b53423          	sd	s11,104(a0)
    80002868:	0005b083          	ld	ra,0(a1)
    8000286c:	0085b103          	ld	sp,8(a1)
    80002870:	6980                	ld	s0,16(a1)
    80002872:	6d84                	ld	s1,24(a1)
    80002874:	0205b903          	ld	s2,32(a1)
    80002878:	0285b983          	ld	s3,40(a1)
    8000287c:	0305ba03          	ld	s4,48(a1)
    80002880:	0385ba83          	ld	s5,56(a1)
    80002884:	0405bb03          	ld	s6,64(a1)
    80002888:	0485bb83          	ld	s7,72(a1)
    8000288c:	0505bc03          	ld	s8,80(a1)
    80002890:	0585bc83          	ld	s9,88(a1)
    80002894:	0605bd03          	ld	s10,96(a1)
    80002898:	0685bd83          	ld	s11,104(a1)
    8000289c:	8082                	ret

000000008000289e <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000289e:	1141                	addi	sp,sp,-16
    800028a0:	e406                	sd	ra,8(sp)
    800028a2:	e022                	sd	s0,0(sp)
    800028a4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028a6:	00006597          	auipc	a1,0x6
    800028aa:	a5a58593          	addi	a1,a1,-1446 # 80008300 <states.0+0x30>
    800028ae:	00016517          	auipc	a0,0x16
    800028b2:	13a50513          	addi	a0,a0,314 # 800189e8 <tickslock>
    800028b6:	ffffe097          	auipc	ra,0xffffe
    800028ba:	290080e7          	jalr	656(ra) # 80000b46 <initlock>
}
    800028be:	60a2                	ld	ra,8(sp)
    800028c0:	6402                	ld	s0,0(sp)
    800028c2:	0141                	addi	sp,sp,16
    800028c4:	8082                	ret

00000000800028c6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    800028c6:	1141                	addi	sp,sp,-16
    800028c8:	e422                	sd	s0,8(sp)
    800028ca:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0"
    800028cc:	00003797          	auipc	a5,0x3
    800028d0:	65478793          	addi	a5,a5,1620 # 80005f20 <kernelvec>
    800028d4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028d8:	6422                	ld	s0,8(sp)
    800028da:	0141                	addi	sp,sp,16
    800028dc:	8082                	ret

00000000800028de <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    800028de:	1141                	addi	sp,sp,-16
    800028e0:	e406                	sd	ra,8(sp)
    800028e2:	e022                	sd	s0,0(sp)
    800028e4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028e6:	fffff097          	auipc	ra,0xfffff
    800028ea:	0c6080e7          	jalr	198(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus"
    800028ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    800028f4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800028f8:	00004697          	auipc	a3,0x4
    800028fc:	70868693          	addi	a3,a3,1800 # 80007000 <_trampoline>
    80002900:	00004717          	auipc	a4,0x4
    80002904:	70070713          	addi	a4,a4,1792 # 80007000 <_trampoline>
    80002908:	8f15                	sub	a4,a4,a3
    8000290a:	040007b7          	lui	a5,0x4000
    8000290e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002910:	07b2                	slli	a5,a5,0xc
    80002912:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0"
    80002914:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002918:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp"
    8000291a:	18002673          	csrr	a2,satp
    8000291e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002920:	6d30                	ld	a2,88(a0)
    80002922:	6138                	ld	a4,64(a0)
    80002924:	6585                	lui	a1,0x1
    80002926:	972e                	add	a4,a4,a1
    80002928:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000292a:	6d38                	ld	a4,88(a0)
    8000292c:	00000617          	auipc	a2,0x0
    80002930:	13e60613          	addi	a2,a2,318 # 80002a6a <usertrap>
    80002934:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002936:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp"
    80002938:	8612                	mv	a2,tp
    8000293a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus"
    8000293c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002940:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002944:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0"
    80002948:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000294c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0"
    8000294e:	6f18                	ld	a4,24(a4)
    80002950:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002954:	6928                	ld	a0,80(a0)
    80002956:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002958:	00004717          	auipc	a4,0x4
    8000295c:	74470713          	addi	a4,a4,1860 # 8000709c <userret>
    80002960:	8f15                	sub	a4,a4,a3
    80002962:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002964:	577d                	li	a4,-1
    80002966:	177e                	slli	a4,a4,0x3f
    80002968:	8d59                	or	a0,a0,a4
    8000296a:	9782                	jalr	a5
}
    8000296c:	60a2                	ld	ra,8(sp)
    8000296e:	6402                	ld	s0,0(sp)
    80002970:	0141                	addi	sp,sp,16
    80002972:	8082                	ret

0000000080002974 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002974:	1101                	addi	sp,sp,-32
    80002976:	ec06                	sd	ra,24(sp)
    80002978:	e822                	sd	s0,16(sp)
    8000297a:	e426                	sd	s1,8(sp)
    8000297c:	e04a                	sd	s2,0(sp)
    8000297e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002980:	00016917          	auipc	s2,0x16
    80002984:	06890913          	addi	s2,s2,104 # 800189e8 <tickslock>
    80002988:	854a                	mv	a0,s2
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	24c080e7          	jalr	588(ra) # 80000bd6 <acquire>
  ticks++;
    80002992:	00006497          	auipc	s1,0x6
    80002996:	f9648493          	addi	s1,s1,-106 # 80008928 <ticks>
    8000299a:	409c                	lw	a5,0(s1)
    8000299c:	2785                	addiw	a5,a5,1
    8000299e:	c09c                	sw	a5,0(s1)
  update_time();
    800029a0:	00000097          	auipc	ra,0x0
    800029a4:	e36080e7          	jalr	-458(ra) # 800027d6 <update_time>
  // if (myproc() != 0)
  // {
  //   myproc()->running_ticks++;
  //   myproc()->change_queue--;
  // }
  wakeup(&ticks);
    800029a8:	8526                	mv	a0,s1
    800029aa:	fffff097          	auipc	ra,0xfffff
    800029ae:	7b2080e7          	jalr	1970(ra) # 8000215c <wakeup>
  release(&tickslock);
    800029b2:	854a                	mv	a0,s2
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	2d6080e7          	jalr	726(ra) # 80000c8a <release>
}
    800029bc:	60e2                	ld	ra,24(sp)
    800029be:	6442                	ld	s0,16(sp)
    800029c0:	64a2                	ld	s1,8(sp)
    800029c2:	6902                	ld	s2,0(sp)
    800029c4:	6105                	addi	sp,sp,32
    800029c6:	8082                	ret

00000000800029c8 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    800029c8:	1101                	addi	sp,sp,-32
    800029ca:	ec06                	sd	ra,24(sp)
    800029cc:	e822                	sd	s0,16(sp)
    800029ce:	e426                	sd	s1,8(sp)
    800029d0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause"
    800029d2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    800029d6:	00074d63          	bltz	a4,800029f0 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    800029da:	57fd                	li	a5,-1
    800029dc:	17fe                	slli	a5,a5,0x3f
    800029de:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    800029e0:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    800029e2:	06f70363          	beq	a4,a5,80002a48 <devintr+0x80>
  }
}
    800029e6:	60e2                	ld	ra,24(sp)
    800029e8:	6442                	ld	s0,16(sp)
    800029ea:	64a2                	ld	s1,8(sp)
    800029ec:	6105                	addi	sp,sp,32
    800029ee:	8082                	ret
      (scause & 0xff) == 9)
    800029f0:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    800029f4:	46a5                	li	a3,9
    800029f6:	fed792e3          	bne	a5,a3,800029da <devintr+0x12>
    int irq = plic_claim();
    800029fa:	00003097          	auipc	ra,0x3
    800029fe:	62e080e7          	jalr	1582(ra) # 80006028 <plic_claim>
    80002a02:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002a04:	47a9                	li	a5,10
    80002a06:	02f50763          	beq	a0,a5,80002a34 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002a0a:	4785                	li	a5,1
    80002a0c:	02f50963          	beq	a0,a5,80002a3e <devintr+0x76>
    return 1;
    80002a10:	4505                	li	a0,1
    else if (irq)
    80002a12:	d8f1                	beqz	s1,800029e6 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a14:	85a6                	mv	a1,s1
    80002a16:	00006517          	auipc	a0,0x6
    80002a1a:	8f250513          	addi	a0,a0,-1806 # 80008308 <states.0+0x38>
    80002a1e:	ffffe097          	auipc	ra,0xffffe
    80002a22:	b6c080e7          	jalr	-1172(ra) # 8000058a <printf>
      plic_complete(irq);
    80002a26:	8526                	mv	a0,s1
    80002a28:	00003097          	auipc	ra,0x3
    80002a2c:	624080e7          	jalr	1572(ra) # 8000604c <plic_complete>
    return 1;
    80002a30:	4505                	li	a0,1
    80002a32:	bf55                	j	800029e6 <devintr+0x1e>
      uartintr();
    80002a34:	ffffe097          	auipc	ra,0xffffe
    80002a38:	f64080e7          	jalr	-156(ra) # 80000998 <uartintr>
    80002a3c:	b7ed                	j	80002a26 <devintr+0x5e>
      virtio_disk_intr();
    80002a3e:	00004097          	auipc	ra,0x4
    80002a42:	daa080e7          	jalr	-598(ra) # 800067e8 <virtio_disk_intr>
    80002a46:	b7c5                	j	80002a26 <devintr+0x5e>
    if (cpuid() == 0)
    80002a48:	fffff097          	auipc	ra,0xfffff
    80002a4c:	f38080e7          	jalr	-200(ra) # 80001980 <cpuid>
    80002a50:	c901                	beqz	a0,80002a60 <devintr+0x98>
  asm volatile("csrr %0, sip"
    80002a52:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a56:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0"
    80002a58:	14479073          	csrw	sip,a5
    return 2;
    80002a5c:	4509                	li	a0,2
    80002a5e:	b761                	j	800029e6 <devintr+0x1e>
      clockintr();
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	f14080e7          	jalr	-236(ra) # 80002974 <clockintr>
    80002a68:	b7ed                	j	80002a52 <devintr+0x8a>

0000000080002a6a <usertrap>:
{
    80002a6a:	1101                	addi	sp,sp,-32
    80002a6c:	ec06                	sd	ra,24(sp)
    80002a6e:	e822                	sd	s0,16(sp)
    80002a70:	e426                	sd	s1,8(sp)
    80002a72:	e04a                	sd	s2,0(sp)
    80002a74:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80002a76:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002a7a:	1007f793          	andi	a5,a5,256
    80002a7e:	e3b1                	bnez	a5,80002ac2 <usertrap+0x58>
  asm volatile("csrw stvec, %0"
    80002a80:	00003797          	auipc	a5,0x3
    80002a84:	4a078793          	addi	a5,a5,1184 # 80005f20 <kernelvec>
    80002a88:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a8c:	fffff097          	auipc	ra,0xfffff
    80002a90:	f20080e7          	jalr	-224(ra) # 800019ac <myproc>
    80002a94:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a96:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc"
    80002a98:	14102773          	csrr	a4,sepc
    80002a9c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause"
    80002a9e:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002aa2:	47a1                	li	a5,8
    80002aa4:	02f70763          	beq	a4,a5,80002ad2 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002aa8:	00000097          	auipc	ra,0x0
    80002aac:	f20080e7          	jalr	-224(ra) # 800029c8 <devintr>
    80002ab0:	892a                	mv	s2,a0
    80002ab2:	c92d                	beqz	a0,80002b24 <usertrap+0xba>
  if (killed(p))
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	00000097          	auipc	ra,0x0
    80002aba:	916080e7          	jalr	-1770(ra) # 800023cc <killed>
    80002abe:	c555                	beqz	a0,80002b6a <usertrap+0x100>
    80002ac0:	a045                	j	80002b60 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002ac2:	00006517          	auipc	a0,0x6
    80002ac6:	86650513          	addi	a0,a0,-1946 # 80008328 <states.0+0x58>
    80002aca:	ffffe097          	auipc	ra,0xffffe
    80002ace:	a76080e7          	jalr	-1418(ra) # 80000540 <panic>
    if (killed(p))
    80002ad2:	00000097          	auipc	ra,0x0
    80002ad6:	8fa080e7          	jalr	-1798(ra) # 800023cc <killed>
    80002ada:	ed1d                	bnez	a0,80002b18 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002adc:	6cb8                	ld	a4,88(s1)
    80002ade:	6f1c                	ld	a5,24(a4)
    80002ae0:	0791                	addi	a5,a5,4
    80002ae2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus"
    80002ae4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ae8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002aec:	10079073          	csrw	sstatus,a5
    syscall();
    80002af0:	00000097          	auipc	ra,0x0
    80002af4:	322080e7          	jalr	802(ra) # 80002e12 <syscall>
  if (killed(p))
    80002af8:	8526                	mv	a0,s1
    80002afa:	00000097          	auipc	ra,0x0
    80002afe:	8d2080e7          	jalr	-1838(ra) # 800023cc <killed>
    80002b02:	ed31                	bnez	a0,80002b5e <usertrap+0xf4>
  usertrapret();
    80002b04:	00000097          	auipc	ra,0x0
    80002b08:	dda080e7          	jalr	-550(ra) # 800028de <usertrapret>
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
    80002b1e:	732080e7          	jalr	1842(ra) # 8000224c <exit>
    80002b22:	bf6d                	j	80002adc <usertrap+0x72>
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
    80002b58:	84c080e7          	jalr	-1972(ra) # 800023a0 <setkilled>
    80002b5c:	bf71                	j	80002af8 <usertrap+0x8e>
  if (killed(p))
    80002b5e:	4901                	li	s2,0
    exit(-1);
    80002b60:	557d                	li	a0,-1
    80002b62:	fffff097          	auipc	ra,0xfffff
    80002b66:	6ea080e7          	jalr	1770(ra) # 8000224c <exit>
  if (which_dev == 2)
    80002b6a:	4789                	li	a5,2
    80002b6c:	f8f91ce3          	bne	s2,a5,80002b04 <usertrap+0x9a>
    if (p->interval)
    80002b70:	1a84a703          	lw	a4,424(s1)
    80002b74:	cf19                	beqz	a4,80002b92 <usertrap+0x128>
      p->now_ticks++;
    80002b76:	1ac4a783          	lw	a5,428(s1)
    80002b7a:	2785                	addiw	a5,a5,1
    80002b7c:	0007869b          	sext.w	a3,a5
    80002b80:	1af4a623          	sw	a5,428(s1)
      if (!p->sigalarm_status && p->interval > 0 && p->now_ticks >= p->interval)
    80002b84:	1b84a783          	lw	a5,440(s1)
    80002b88:	e789                	bnez	a5,80002b92 <usertrap+0x128>
    80002b8a:	00e05463          	blez	a4,80002b92 <usertrap+0x128>
    80002b8e:	00e6d763          	bge	a3,a4,80002b9c <usertrap+0x132>
    yield();
    80002b92:	fffff097          	auipc	ra,0xfffff
    80002b96:	51e080e7          	jalr	1310(ra) # 800020b0 <yield>
    80002b9a:	b7ad                	j	80002b04 <usertrap+0x9a>
        p->now_ticks = 0;
    80002b9c:	1a04a623          	sw	zero,428(s1)
        p->sigalarm_status = 1;
    80002ba0:	4785                	li	a5,1
    80002ba2:	1af4ac23          	sw	a5,440(s1)
        p->alarm_trapframe = kalloc();
    80002ba6:	ffffe097          	auipc	ra,0xffffe
    80002baa:	f40080e7          	jalr	-192(ra) # 80000ae6 <kalloc>
    80002bae:	1aa4b823          	sd	a0,432(s1)
        memmove(p->alarm_trapframe, p->trapframe, PGSIZE);
    80002bb2:	6605                	lui	a2,0x1
    80002bb4:	6cac                	ld	a1,88(s1)
    80002bb6:	ffffe097          	auipc	ra,0xffffe
    80002bba:	178080e7          	jalr	376(ra) # 80000d2e <memmove>
        p->trapframe->epc = p->handler;
    80002bbe:	6cbc                	ld	a5,88(s1)
    80002bc0:	1a04b703          	ld	a4,416(s1)
    80002bc4:	ef98                	sd	a4,24(a5)
    80002bc6:	b7f1                	j	80002b92 <usertrap+0x128>

0000000080002bc8 <kerneltrap>:
{
    80002bc8:	7179                	addi	sp,sp,-48
    80002bca:	f406                	sd	ra,40(sp)
    80002bcc:	f022                	sd	s0,32(sp)
    80002bce:	ec26                	sd	s1,24(sp)
    80002bd0:	e84a                	sd	s2,16(sp)
    80002bd2:	e44e                	sd	s3,8(sp)
    80002bd4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc"
    80002bd6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus"
    80002bda:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause"
    80002bde:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002be2:	1004f793          	andi	a5,s1,256
    80002be6:	cb85                	beqz	a5,80002c16 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus"
    80002be8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bec:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002bee:	ef85                	bnez	a5,80002c26 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002bf0:	00000097          	auipc	ra,0x0
    80002bf4:	dd8080e7          	jalr	-552(ra) # 800029c8 <devintr>
    80002bf8:	cd1d                	beqz	a0,80002c36 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bfa:	4789                	li	a5,2
    80002bfc:	06f50a63          	beq	a0,a5,80002c70 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0"
    80002c00:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0"
    80002c04:	10049073          	csrw	sstatus,s1
}
    80002c08:	70a2                	ld	ra,40(sp)
    80002c0a:	7402                	ld	s0,32(sp)
    80002c0c:	64e2                	ld	s1,24(sp)
    80002c0e:	6942                	ld	s2,16(sp)
    80002c10:	69a2                	ld	s3,8(sp)
    80002c12:	6145                	addi	sp,sp,48
    80002c14:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c16:	00005517          	auipc	a0,0x5
    80002c1a:	78250513          	addi	a0,a0,1922 # 80008398 <states.0+0xc8>
    80002c1e:	ffffe097          	auipc	ra,0xffffe
    80002c22:	922080e7          	jalr	-1758(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c26:	00005517          	auipc	a0,0x5
    80002c2a:	79a50513          	addi	a0,a0,1946 # 800083c0 <states.0+0xf0>
    80002c2e:	ffffe097          	auipc	ra,0xffffe
    80002c32:	912080e7          	jalr	-1774(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002c36:	85ce                	mv	a1,s3
    80002c38:	00005517          	auipc	a0,0x5
    80002c3c:	7a850513          	addi	a0,a0,1960 # 800083e0 <states.0+0x110>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	94a080e7          	jalr	-1718(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002c48:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002c4c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c50:	00005517          	auipc	a0,0x5
    80002c54:	7a050513          	addi	a0,a0,1952 # 800083f0 <states.0+0x120>
    80002c58:	ffffe097          	auipc	ra,0xffffe
    80002c5c:	932080e7          	jalr	-1742(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002c60:	00005517          	auipc	a0,0x5
    80002c64:	7a850513          	addi	a0,a0,1960 # 80008408 <states.0+0x138>
    80002c68:	ffffe097          	auipc	ra,0xffffe
    80002c6c:	8d8080e7          	jalr	-1832(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	d3c080e7          	jalr	-708(ra) # 800019ac <myproc>
    80002c78:	d541                	beqz	a0,80002c00 <kerneltrap+0x38>
    80002c7a:	fffff097          	auipc	ra,0xfffff
    80002c7e:	d32080e7          	jalr	-718(ra) # 800019ac <myproc>
    80002c82:	4d18                	lw	a4,24(a0)
    80002c84:	4791                	li	a5,4
    80002c86:	f6f71de3          	bne	a4,a5,80002c00 <kerneltrap+0x38>
    yield();
    80002c8a:	fffff097          	auipc	ra,0xfffff
    80002c8e:	426080e7          	jalr	1062(ra) # 800020b0 <yield>
    80002c92:	b7bd                	j	80002c00 <kerneltrap+0x38>

0000000080002c94 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c94:	1101                	addi	sp,sp,-32
    80002c96:	ec06                	sd	ra,24(sp)
    80002c98:	e822                	sd	s0,16(sp)
    80002c9a:	e426                	sd	s1,8(sp)
    80002c9c:	1000                	addi	s0,sp,32
    80002c9e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ca0:	fffff097          	auipc	ra,0xfffff
    80002ca4:	d0c080e7          	jalr	-756(ra) # 800019ac <myproc>
  switch (n)
    80002ca8:	4795                	li	a5,5
    80002caa:	0497e163          	bltu	a5,s1,80002cec <argraw+0x58>
    80002cae:	048a                	slli	s1,s1,0x2
    80002cb0:	00005717          	auipc	a4,0x5
    80002cb4:	79070713          	addi	a4,a4,1936 # 80008440 <states.0+0x170>
    80002cb8:	94ba                	add	s1,s1,a4
    80002cba:	409c                	lw	a5,0(s1)
    80002cbc:	97ba                	add	a5,a5,a4
    80002cbe:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002cc0:	6d3c                	ld	a5,88(a0)
    80002cc2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cc4:	60e2                	ld	ra,24(sp)
    80002cc6:	6442                	ld	s0,16(sp)
    80002cc8:	64a2                	ld	s1,8(sp)
    80002cca:	6105                	addi	sp,sp,32
    80002ccc:	8082                	ret
    return p->trapframe->a1;
    80002cce:	6d3c                	ld	a5,88(a0)
    80002cd0:	7fa8                	ld	a0,120(a5)
    80002cd2:	bfcd                	j	80002cc4 <argraw+0x30>
    return p->trapframe->a2;
    80002cd4:	6d3c                	ld	a5,88(a0)
    80002cd6:	63c8                	ld	a0,128(a5)
    80002cd8:	b7f5                	j	80002cc4 <argraw+0x30>
    return p->trapframe->a3;
    80002cda:	6d3c                	ld	a5,88(a0)
    80002cdc:	67c8                	ld	a0,136(a5)
    80002cde:	b7dd                	j	80002cc4 <argraw+0x30>
    return p->trapframe->a4;
    80002ce0:	6d3c                	ld	a5,88(a0)
    80002ce2:	6bc8                	ld	a0,144(a5)
    80002ce4:	b7c5                	j	80002cc4 <argraw+0x30>
    return p->trapframe->a5;
    80002ce6:	6d3c                	ld	a5,88(a0)
    80002ce8:	6fc8                	ld	a0,152(a5)
    80002cea:	bfe9                	j	80002cc4 <argraw+0x30>
  panic("argraw");
    80002cec:	00005517          	auipc	a0,0x5
    80002cf0:	72c50513          	addi	a0,a0,1836 # 80008418 <states.0+0x148>
    80002cf4:	ffffe097          	auipc	ra,0xffffe
    80002cf8:	84c080e7          	jalr	-1972(ra) # 80000540 <panic>

0000000080002cfc <fetchaddr>:
{
    80002cfc:	1101                	addi	sp,sp,-32
    80002cfe:	ec06                	sd	ra,24(sp)
    80002d00:	e822                	sd	s0,16(sp)
    80002d02:	e426                	sd	s1,8(sp)
    80002d04:	e04a                	sd	s2,0(sp)
    80002d06:	1000                	addi	s0,sp,32
    80002d08:	84aa                	mv	s1,a0
    80002d0a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d0c:	fffff097          	auipc	ra,0xfffff
    80002d10:	ca0080e7          	jalr	-864(ra) # 800019ac <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d14:	653c                	ld	a5,72(a0)
    80002d16:	02f4f863          	bgeu	s1,a5,80002d46 <fetchaddr+0x4a>
    80002d1a:	00848713          	addi	a4,s1,8
    80002d1e:	02e7e663          	bltu	a5,a4,80002d4a <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d22:	46a1                	li	a3,8
    80002d24:	8626                	mv	a2,s1
    80002d26:	85ca                	mv	a1,s2
    80002d28:	6928                	ld	a0,80(a0)
    80002d2a:	fffff097          	auipc	ra,0xfffff
    80002d2e:	9ce080e7          	jalr	-1586(ra) # 800016f8 <copyin>
    80002d32:	00a03533          	snez	a0,a0
    80002d36:	40a00533          	neg	a0,a0
}
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	64a2                	ld	s1,8(sp)
    80002d40:	6902                	ld	s2,0(sp)
    80002d42:	6105                	addi	sp,sp,32
    80002d44:	8082                	ret
    return -1;
    80002d46:	557d                	li	a0,-1
    80002d48:	bfcd                	j	80002d3a <fetchaddr+0x3e>
    80002d4a:	557d                	li	a0,-1
    80002d4c:	b7fd                	j	80002d3a <fetchaddr+0x3e>

0000000080002d4e <fetchstr>:
{
    80002d4e:	7179                	addi	sp,sp,-48
    80002d50:	f406                	sd	ra,40(sp)
    80002d52:	f022                	sd	s0,32(sp)
    80002d54:	ec26                	sd	s1,24(sp)
    80002d56:	e84a                	sd	s2,16(sp)
    80002d58:	e44e                	sd	s3,8(sp)
    80002d5a:	1800                	addi	s0,sp,48
    80002d5c:	892a                	mv	s2,a0
    80002d5e:	84ae                	mv	s1,a1
    80002d60:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	c4a080e7          	jalr	-950(ra) # 800019ac <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d6a:	86ce                	mv	a3,s3
    80002d6c:	864a                	mv	a2,s2
    80002d6e:	85a6                	mv	a1,s1
    80002d70:	6928                	ld	a0,80(a0)
    80002d72:	fffff097          	auipc	ra,0xfffff
    80002d76:	a14080e7          	jalr	-1516(ra) # 80001786 <copyinstr>
    80002d7a:	00054e63          	bltz	a0,80002d96 <fetchstr+0x48>
  return strlen(buf);
    80002d7e:	8526                	mv	a0,s1
    80002d80:	ffffe097          	auipc	ra,0xffffe
    80002d84:	0ce080e7          	jalr	206(ra) # 80000e4e <strlen>
}
    80002d88:	70a2                	ld	ra,40(sp)
    80002d8a:	7402                	ld	s0,32(sp)
    80002d8c:	64e2                	ld	s1,24(sp)
    80002d8e:	6942                	ld	s2,16(sp)
    80002d90:	69a2                	ld	s3,8(sp)
    80002d92:	6145                	addi	sp,sp,48
    80002d94:	8082                	ret
    return -1;
    80002d96:	557d                	li	a0,-1
    80002d98:	bfc5                	j	80002d88 <fetchstr+0x3a>

0000000080002d9a <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	e426                	sd	s1,8(sp)
    80002da2:	1000                	addi	s0,sp,32
    80002da4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002da6:	00000097          	auipc	ra,0x0
    80002daa:	eee080e7          	jalr	-274(ra) # 80002c94 <argraw>
    80002dae:	c088                	sw	a0,0(s1)
}
    80002db0:	60e2                	ld	ra,24(sp)
    80002db2:	6442                	ld	s0,16(sp)
    80002db4:	64a2                	ld	s1,8(sp)
    80002db6:	6105                	addi	sp,sp,32
    80002db8:	8082                	ret

0000000080002dba <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002dba:	1101                	addi	sp,sp,-32
    80002dbc:	ec06                	sd	ra,24(sp)
    80002dbe:	e822                	sd	s0,16(sp)
    80002dc0:	e426                	sd	s1,8(sp)
    80002dc2:	1000                	addi	s0,sp,32
    80002dc4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dc6:	00000097          	auipc	ra,0x0
    80002dca:	ece080e7          	jalr	-306(ra) # 80002c94 <argraw>
    80002dce:	e088                	sd	a0,0(s1)
}
    80002dd0:	60e2                	ld	ra,24(sp)
    80002dd2:	6442                	ld	s0,16(sp)
    80002dd4:	64a2                	ld	s1,8(sp)
    80002dd6:	6105                	addi	sp,sp,32
    80002dd8:	8082                	ret

0000000080002dda <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002dda:	7179                	addi	sp,sp,-48
    80002ddc:	f406                	sd	ra,40(sp)
    80002dde:	f022                	sd	s0,32(sp)
    80002de0:	ec26                	sd	s1,24(sp)
    80002de2:	e84a                	sd	s2,16(sp)
    80002de4:	1800                	addi	s0,sp,48
    80002de6:	84ae                	mv	s1,a1
    80002de8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002dea:	fd840593          	addi	a1,s0,-40
    80002dee:	00000097          	auipc	ra,0x0
    80002df2:	fcc080e7          	jalr	-52(ra) # 80002dba <argaddr>
  return fetchstr(addr, buf, max);
    80002df6:	864a                	mv	a2,s2
    80002df8:	85a6                	mv	a1,s1
    80002dfa:	fd843503          	ld	a0,-40(s0)
    80002dfe:	00000097          	auipc	ra,0x0
    80002e02:	f50080e7          	jalr	-176(ra) # 80002d4e <fetchstr>
}
    80002e06:	70a2                	ld	ra,40(sp)
    80002e08:	7402                	ld	s0,32(sp)
    80002e0a:	64e2                	ld	s1,24(sp)
    80002e0c:	6942                	ld	s2,16(sp)
    80002e0e:	6145                	addi	sp,sp,48
    80002e10:	8082                	ret

0000000080002e12 <syscall>:
    [SYS_sigreturn] sys_sigreturn,
    [SYS_waitx] sys_waitx,
};

void syscall(void)
{
    80002e12:	1101                	addi	sp,sp,-32
    80002e14:	ec06                	sd	ra,24(sp)
    80002e16:	e822                	sd	s0,16(sp)
    80002e18:	e426                	sd	s1,8(sp)
    80002e1a:	e04a                	sd	s2,0(sp)
    80002e1c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e1e:	fffff097          	auipc	ra,0xfffff
    80002e22:	b8e080e7          	jalr	-1138(ra) # 800019ac <myproc>
    80002e26:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e28:	05853903          	ld	s2,88(a0)
    80002e2c:	0a893783          	ld	a5,168(s2)
    80002e30:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002e34:	37fd                	addiw	a5,a5,-1
    80002e36:	475d                	li	a4,23
    80002e38:	00f76f63          	bltu	a4,a5,80002e56 <syscall+0x44>
    80002e3c:	00369713          	slli	a4,a3,0x3
    80002e40:	00005797          	auipc	a5,0x5
    80002e44:	61878793          	addi	a5,a5,1560 # 80008458 <syscalls>
    80002e48:	97ba                	add	a5,a5,a4
    80002e4a:	639c                	ld	a5,0(a5)
    80002e4c:	c789                	beqz	a5,80002e56 <syscall+0x44>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e4e:	9782                	jalr	a5
    80002e50:	06a93823          	sd	a0,112(s2)
    80002e54:	a839                	j	80002e72 <syscall+0x60>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002e56:	15848613          	addi	a2,s1,344
    80002e5a:	588c                	lw	a1,48(s1)
    80002e5c:	00005517          	auipc	a0,0x5
    80002e60:	5c450513          	addi	a0,a0,1476 # 80008420 <states.0+0x150>
    80002e64:	ffffd097          	auipc	ra,0xffffd
    80002e68:	726080e7          	jalr	1830(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e6c:	6cbc                	ld	a5,88(s1)
    80002e6e:	577d                	li	a4,-1
    80002e70:	fbb8                	sd	a4,112(a5)
  }
}
    80002e72:	60e2                	ld	ra,24(sp)
    80002e74:	6442                	ld	s0,16(sp)
    80002e76:	64a2                	ld	s1,8(sp)
    80002e78:	6902                	ld	s2,0(sp)
    80002e7a:	6105                	addi	sp,sp,32
    80002e7c:	8082                	ret

0000000080002e7e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e7e:	1101                	addi	sp,sp,-32
    80002e80:	ec06                	sd	ra,24(sp)
    80002e82:	e822                	sd	s0,16(sp)
    80002e84:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e86:	fec40593          	addi	a1,s0,-20
    80002e8a:	4501                	li	a0,0
    80002e8c:	00000097          	auipc	ra,0x0
    80002e90:	f0e080e7          	jalr	-242(ra) # 80002d9a <argint>
  exit(n);
    80002e94:	fec42503          	lw	a0,-20(s0)
    80002e98:	fffff097          	auipc	ra,0xfffff
    80002e9c:	3b4080e7          	jalr	948(ra) # 8000224c <exit>
  return 0; // not reached
}
    80002ea0:	4501                	li	a0,0
    80002ea2:	60e2                	ld	ra,24(sp)
    80002ea4:	6442                	ld	s0,16(sp)
    80002ea6:	6105                	addi	sp,sp,32
    80002ea8:	8082                	ret

0000000080002eaa <sys_getpid>:

uint64
sys_getpid(void)
{
    80002eaa:	1141                	addi	sp,sp,-16
    80002eac:	e406                	sd	ra,8(sp)
    80002eae:	e022                	sd	s0,0(sp)
    80002eb0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002eb2:	fffff097          	auipc	ra,0xfffff
    80002eb6:	afa080e7          	jalr	-1286(ra) # 800019ac <myproc>
}
    80002eba:	5908                	lw	a0,48(a0)
    80002ebc:	60a2                	ld	ra,8(sp)
    80002ebe:	6402                	ld	s0,0(sp)
    80002ec0:	0141                	addi	sp,sp,16
    80002ec2:	8082                	ret

0000000080002ec4 <sys_fork>:

uint64
sys_fork(void)
{
    80002ec4:	1141                	addi	sp,sp,-16
    80002ec6:	e406                	sd	ra,8(sp)
    80002ec8:	e022                	sd	s0,0(sp)
    80002eca:	0800                	addi	s0,sp,16
  return fork();
    80002ecc:	fffff097          	auipc	ra,0xfffff
    80002ed0:	f16080e7          	jalr	-234(ra) # 80001de2 <fork>
}
    80002ed4:	60a2                	ld	ra,8(sp)
    80002ed6:	6402                	ld	s0,0(sp)
    80002ed8:	0141                	addi	sp,sp,16
    80002eda:	8082                	ret

0000000080002edc <sys_wait>:

uint64
sys_wait(void)
{
    80002edc:	1101                	addi	sp,sp,-32
    80002ede:	ec06                	sd	ra,24(sp)
    80002ee0:	e822                	sd	s0,16(sp)
    80002ee2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ee4:	fe840593          	addi	a1,s0,-24
    80002ee8:	4501                	li	a0,0
    80002eea:	00000097          	auipc	ra,0x0
    80002eee:	ed0080e7          	jalr	-304(ra) # 80002dba <argaddr>
  return wait(p);
    80002ef2:	fe843503          	ld	a0,-24(s0)
    80002ef6:	fffff097          	auipc	ra,0xfffff
    80002efa:	508080e7          	jalr	1288(ra) # 800023fe <wait>
}
    80002efe:	60e2                	ld	ra,24(sp)
    80002f00:	6442                	ld	s0,16(sp)
    80002f02:	6105                	addi	sp,sp,32
    80002f04:	8082                	ret

0000000080002f06 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f06:	7179                	addi	sp,sp,-48
    80002f08:	f406                	sd	ra,40(sp)
    80002f0a:	f022                	sd	s0,32(sp)
    80002f0c:	ec26                	sd	s1,24(sp)
    80002f0e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f10:	fdc40593          	addi	a1,s0,-36
    80002f14:	4501                	li	a0,0
    80002f16:	00000097          	auipc	ra,0x0
    80002f1a:	e84080e7          	jalr	-380(ra) # 80002d9a <argint>
  addr = myproc()->sz;
    80002f1e:	fffff097          	auipc	ra,0xfffff
    80002f22:	a8e080e7          	jalr	-1394(ra) # 800019ac <myproc>
    80002f26:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002f28:	fdc42503          	lw	a0,-36(s0)
    80002f2c:	fffff097          	auipc	ra,0xfffff
    80002f30:	e5a080e7          	jalr	-422(ra) # 80001d86 <growproc>
    80002f34:	00054863          	bltz	a0,80002f44 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f38:	8526                	mv	a0,s1
    80002f3a:	70a2                	ld	ra,40(sp)
    80002f3c:	7402                	ld	s0,32(sp)
    80002f3e:	64e2                	ld	s1,24(sp)
    80002f40:	6145                	addi	sp,sp,48
    80002f42:	8082                	ret
    return -1;
    80002f44:	54fd                	li	s1,-1
    80002f46:	bfcd                	j	80002f38 <sys_sbrk+0x32>

0000000080002f48 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f48:	7139                	addi	sp,sp,-64
    80002f4a:	fc06                	sd	ra,56(sp)
    80002f4c:	f822                	sd	s0,48(sp)
    80002f4e:	f426                	sd	s1,40(sp)
    80002f50:	f04a                	sd	s2,32(sp)
    80002f52:	ec4e                	sd	s3,24(sp)
    80002f54:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f56:	fcc40593          	addi	a1,s0,-52
    80002f5a:	4501                	li	a0,0
    80002f5c:	00000097          	auipc	ra,0x0
    80002f60:	e3e080e7          	jalr	-450(ra) # 80002d9a <argint>
  acquire(&tickslock);
    80002f64:	00016517          	auipc	a0,0x16
    80002f68:	a8450513          	addi	a0,a0,-1404 # 800189e8 <tickslock>
    80002f6c:	ffffe097          	auipc	ra,0xffffe
    80002f70:	c6a080e7          	jalr	-918(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002f74:	00006917          	auipc	s2,0x6
    80002f78:	9b492903          	lw	s2,-1612(s2) # 80008928 <ticks>
  while (ticks - ticks0 < n)
    80002f7c:	fcc42783          	lw	a5,-52(s0)
    80002f80:	cf9d                	beqz	a5,80002fbe <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f82:	00016997          	auipc	s3,0x16
    80002f86:	a6698993          	addi	s3,s3,-1434 # 800189e8 <tickslock>
    80002f8a:	00006497          	auipc	s1,0x6
    80002f8e:	99e48493          	addi	s1,s1,-1634 # 80008928 <ticks>
    if (killed(myproc()))
    80002f92:	fffff097          	auipc	ra,0xfffff
    80002f96:	a1a080e7          	jalr	-1510(ra) # 800019ac <myproc>
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	432080e7          	jalr	1074(ra) # 800023cc <killed>
    80002fa2:	ed15                	bnez	a0,80002fde <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002fa4:	85ce                	mv	a1,s3
    80002fa6:	8526                	mv	a0,s1
    80002fa8:	fffff097          	auipc	ra,0xfffff
    80002fac:	144080e7          	jalr	324(ra) # 800020ec <sleep>
  while (ticks - ticks0 < n)
    80002fb0:	409c                	lw	a5,0(s1)
    80002fb2:	412787bb          	subw	a5,a5,s2
    80002fb6:	fcc42703          	lw	a4,-52(s0)
    80002fba:	fce7ece3          	bltu	a5,a4,80002f92 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002fbe:	00016517          	auipc	a0,0x16
    80002fc2:	a2a50513          	addi	a0,a0,-1494 # 800189e8 <tickslock>
    80002fc6:	ffffe097          	auipc	ra,0xffffe
    80002fca:	cc4080e7          	jalr	-828(ra) # 80000c8a <release>
  return 0;
    80002fce:	4501                	li	a0,0
}
    80002fd0:	70e2                	ld	ra,56(sp)
    80002fd2:	7442                	ld	s0,48(sp)
    80002fd4:	74a2                	ld	s1,40(sp)
    80002fd6:	7902                	ld	s2,32(sp)
    80002fd8:	69e2                	ld	s3,24(sp)
    80002fda:	6121                	addi	sp,sp,64
    80002fdc:	8082                	ret
      release(&tickslock);
    80002fde:	00016517          	auipc	a0,0x16
    80002fe2:	a0a50513          	addi	a0,a0,-1526 # 800189e8 <tickslock>
    80002fe6:	ffffe097          	auipc	ra,0xffffe
    80002fea:	ca4080e7          	jalr	-860(ra) # 80000c8a <release>
      return -1;
    80002fee:	557d                	li	a0,-1
    80002ff0:	b7c5                	j	80002fd0 <sys_sleep+0x88>

0000000080002ff2 <sys_kill>:

uint64
sys_kill(void)
{
    80002ff2:	1101                	addi	sp,sp,-32
    80002ff4:	ec06                	sd	ra,24(sp)
    80002ff6:	e822                	sd	s0,16(sp)
    80002ff8:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ffa:	fec40593          	addi	a1,s0,-20
    80002ffe:	4501                	li	a0,0
    80003000:	00000097          	auipc	ra,0x0
    80003004:	d9a080e7          	jalr	-614(ra) # 80002d9a <argint>
  return kill(pid);
    80003008:	fec42503          	lw	a0,-20(s0)
    8000300c:	fffff097          	auipc	ra,0xfffff
    80003010:	322080e7          	jalr	802(ra) # 8000232e <kill>
}
    80003014:	60e2                	ld	ra,24(sp)
    80003016:	6442                	ld	s0,16(sp)
    80003018:	6105                	addi	sp,sp,32
    8000301a:	8082                	ret

000000008000301c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000301c:	1101                	addi	sp,sp,-32
    8000301e:	ec06                	sd	ra,24(sp)
    80003020:	e822                	sd	s0,16(sp)
    80003022:	e426                	sd	s1,8(sp)
    80003024:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003026:	00016517          	auipc	a0,0x16
    8000302a:	9c250513          	addi	a0,a0,-1598 # 800189e8 <tickslock>
    8000302e:	ffffe097          	auipc	ra,0xffffe
    80003032:	ba8080e7          	jalr	-1112(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003036:	00006497          	auipc	s1,0x6
    8000303a:	8f24a483          	lw	s1,-1806(s1) # 80008928 <ticks>
  release(&tickslock);
    8000303e:	00016517          	auipc	a0,0x16
    80003042:	9aa50513          	addi	a0,a0,-1622 # 800189e8 <tickslock>
    80003046:	ffffe097          	auipc	ra,0xffffe
    8000304a:	c44080e7          	jalr	-956(ra) # 80000c8a <release>
  return xticks;
}
    8000304e:	02049513          	slli	a0,s1,0x20
    80003052:	9101                	srli	a0,a0,0x20
    80003054:	60e2                	ld	ra,24(sp)
    80003056:	6442                	ld	s0,16(sp)
    80003058:	64a2                	ld	s1,8(sp)
    8000305a:	6105                	addi	sp,sp,32
    8000305c:	8082                	ret

000000008000305e <sys_sigalarm>:

// sigalarm
uint64 sys_sigalarm(void)
{
    8000305e:	1101                	addi	sp,sp,-32
    80003060:	ec06                	sd	ra,24(sp)
    80003062:	e822                	sd	s0,16(sp)
    80003064:	1000                	addi	s0,sp,32
  int interval;
  uint64 fn;
  argint(0, &interval);
    80003066:	fec40593          	addi	a1,s0,-20
    8000306a:	4501                	li	a0,0
    8000306c:	00000097          	auipc	ra,0x0
    80003070:	d2e080e7          	jalr	-722(ra) # 80002d9a <argint>
  argaddr(1, &fn);
    80003074:	fe040593          	addi	a1,s0,-32
    80003078:	4505                	li	a0,1
    8000307a:	00000097          	auipc	ra,0x0
    8000307e:	d40080e7          	jalr	-704(ra) # 80002dba <argaddr>

  struct proc *p = myproc();
    80003082:	fffff097          	auipc	ra,0xfffff
    80003086:	92a080e7          	jalr	-1750(ra) # 800019ac <myproc>

  p->sigalarm_status = 0;
    8000308a:	1a052c23          	sw	zero,440(a0)
  p->interval = interval;
    8000308e:	fec42783          	lw	a5,-20(s0)
    80003092:	1af52423          	sw	a5,424(a0)
  p->now_ticks = 0;
    80003096:	1a052623          	sw	zero,428(a0)
  p->handler = fn;
    8000309a:	fe043783          	ld	a5,-32(s0)
    8000309e:	1af53023          	sd	a5,416(a0)

  return 0;
}
    800030a2:	4501                	li	a0,0
    800030a4:	60e2                	ld	ra,24(sp)
    800030a6:	6442                	ld	s0,16(sp)
    800030a8:	6105                	addi	sp,sp,32
    800030aa:	8082                	ret

00000000800030ac <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    800030ac:	1101                	addi	sp,sp,-32
    800030ae:	ec06                	sd	ra,24(sp)
    800030b0:	e822                	sd	s0,16(sp)
    800030b2:	e426                	sd	s1,8(sp)
    800030b4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800030b6:	fffff097          	auipc	ra,0xfffff
    800030ba:	8f6080e7          	jalr	-1802(ra) # 800019ac <myproc>
    800030be:	84aa                	mv	s1,a0

  // Restore Kernel Values
  memmove(p->trapframe, p->alarm_trapframe, PGSIZE);
    800030c0:	6605                	lui	a2,0x1
    800030c2:	1b053583          	ld	a1,432(a0)
    800030c6:	6d28                	ld	a0,88(a0)
    800030c8:	ffffe097          	auipc	ra,0xffffe
    800030cc:	c66080e7          	jalr	-922(ra) # 80000d2e <memmove>
  kfree(p->alarm_trapframe);
    800030d0:	1b04b503          	ld	a0,432(s1)
    800030d4:	ffffe097          	auipc	ra,0xffffe
    800030d8:	914080e7          	jalr	-1772(ra) # 800009e8 <kfree>

  p->sigalarm_status = 0;
    800030dc:	1a04ac23          	sw	zero,440(s1)
  p->alarm_trapframe = 0;
    800030e0:	1a04b823          	sd	zero,432(s1)
  p->now_ticks = 0;
    800030e4:	1a04a623          	sw	zero,428(s1)
  usertrapret();
    800030e8:	fffff097          	auipc	ra,0xfffff
    800030ec:	7f6080e7          	jalr	2038(ra) # 800028de <usertrapret>
  return 0;
}
    800030f0:	4501                	li	a0,0
    800030f2:	60e2                	ld	ra,24(sp)
    800030f4:	6442                	ld	s0,16(sp)
    800030f6:	64a2                	ld	s1,8(sp)
    800030f8:	6105                	addi	sp,sp,32
    800030fa:	8082                	ret

00000000800030fc <sys_waitx>:

uint64
sys_waitx(void)
{
    800030fc:	7139                	addi	sp,sp,-64
    800030fe:	fc06                	sd	ra,56(sp)
    80003100:	f822                	sd	s0,48(sp)
    80003102:	f426                	sd	s1,40(sp)
    80003104:	f04a                	sd	s2,32(sp)
    80003106:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003108:	fd840593          	addi	a1,s0,-40
    8000310c:	4501                	li	a0,0
    8000310e:	00000097          	auipc	ra,0x0
    80003112:	cac080e7          	jalr	-852(ra) # 80002dba <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003116:	fd040593          	addi	a1,s0,-48
    8000311a:	4505                	li	a0,1
    8000311c:	00000097          	auipc	ra,0x0
    80003120:	c9e080e7          	jalr	-866(ra) # 80002dba <argaddr>
  argaddr(2, &addr2);
    80003124:	fc840593          	addi	a1,s0,-56
    80003128:	4509                	li	a0,2
    8000312a:	00000097          	auipc	ra,0x0
    8000312e:	c90080e7          	jalr	-880(ra) # 80002dba <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003132:	fc040613          	addi	a2,s0,-64
    80003136:	fc440593          	addi	a1,s0,-60
    8000313a:	fd843503          	ld	a0,-40(s0)
    8000313e:	fffff097          	auipc	ra,0xfffff
    80003142:	54c080e7          	jalr	1356(ra) # 8000268a <waitx>
    80003146:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003148:	fffff097          	auipc	ra,0xfffff
    8000314c:	864080e7          	jalr	-1948(ra) # 800019ac <myproc>
    80003150:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003152:	4691                	li	a3,4
    80003154:	fc440613          	addi	a2,s0,-60
    80003158:	fd043583          	ld	a1,-48(s0)
    8000315c:	6928                	ld	a0,80(a0)
    8000315e:	ffffe097          	auipc	ra,0xffffe
    80003162:	50e080e7          	jalr	1294(ra) # 8000166c <copyout>
    return -1;
    80003166:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003168:	00054f63          	bltz	a0,80003186 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    8000316c:	4691                	li	a3,4
    8000316e:	fc040613          	addi	a2,s0,-64
    80003172:	fc843583          	ld	a1,-56(s0)
    80003176:	68a8                	ld	a0,80(s1)
    80003178:	ffffe097          	auipc	ra,0xffffe
    8000317c:	4f4080e7          	jalr	1268(ra) # 8000166c <copyout>
    80003180:	00054a63          	bltz	a0,80003194 <sys_waitx+0x98>
    return -1;
  return ret;
    80003184:	87ca                	mv	a5,s2
    80003186:	853e                	mv	a0,a5
    80003188:	70e2                	ld	ra,56(sp)
    8000318a:	7442                	ld	s0,48(sp)
    8000318c:	74a2                	ld	s1,40(sp)
    8000318e:	7902                	ld	s2,32(sp)
    80003190:	6121                	addi	sp,sp,64
    80003192:	8082                	ret
    return -1;
    80003194:	57fd                	li	a5,-1
    80003196:	bfc5                	j	80003186 <sys_waitx+0x8a>

0000000080003198 <binit>:
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void binit(void)
{
    80003198:	7179                	addi	sp,sp,-48
    8000319a:	f406                	sd	ra,40(sp)
    8000319c:	f022                	sd	s0,32(sp)
    8000319e:	ec26                	sd	s1,24(sp)
    800031a0:	e84a                	sd	s2,16(sp)
    800031a2:	e44e                	sd	s3,8(sp)
    800031a4:	e052                	sd	s4,0(sp)
    800031a6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800031a8:	00005597          	auipc	a1,0x5
    800031ac:	37858593          	addi	a1,a1,888 # 80008520 <syscalls+0xc8>
    800031b0:	00016517          	auipc	a0,0x16
    800031b4:	85050513          	addi	a0,a0,-1968 # 80018a00 <bcache>
    800031b8:	ffffe097          	auipc	ra,0xffffe
    800031bc:	98e080e7          	jalr	-1650(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800031c0:	0001e797          	auipc	a5,0x1e
    800031c4:	84078793          	addi	a5,a5,-1984 # 80020a00 <bcache+0x8000>
    800031c8:	0001e717          	auipc	a4,0x1e
    800031cc:	aa070713          	addi	a4,a4,-1376 # 80020c68 <bcache+0x8268>
    800031d0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800031d4:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    800031d8:	00016497          	auipc	s1,0x16
    800031dc:	84048493          	addi	s1,s1,-1984 # 80018a18 <bcache+0x18>
  {
    b->next = bcache.head.next;
    800031e0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800031e2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800031e4:	00005a17          	auipc	s4,0x5
    800031e8:	344a0a13          	addi	s4,s4,836 # 80008528 <syscalls+0xd0>
    b->next = bcache.head.next;
    800031ec:	2b893783          	ld	a5,696(s2)
    800031f0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800031f2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800031f6:	85d2                	mv	a1,s4
    800031f8:	01048513          	addi	a0,s1,16
    800031fc:	00001097          	auipc	ra,0x1
    80003200:	4c8080e7          	jalr	1224(ra) # 800046c4 <initsleeplock>
    bcache.head.next->prev = b;
    80003204:	2b893783          	ld	a5,696(s2)
    80003208:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000320a:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    8000320e:	45848493          	addi	s1,s1,1112
    80003212:	fd349de3          	bne	s1,s3,800031ec <binit+0x54>
  }
}
    80003216:	70a2                	ld	ra,40(sp)
    80003218:	7402                	ld	s0,32(sp)
    8000321a:	64e2                	ld	s1,24(sp)
    8000321c:	6942                	ld	s2,16(sp)
    8000321e:	69a2                	ld	s3,8(sp)
    80003220:	6a02                	ld	s4,0(sp)
    80003222:	6145                	addi	sp,sp,48
    80003224:	8082                	ret

0000000080003226 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80003226:	7179                	addi	sp,sp,-48
    80003228:	f406                	sd	ra,40(sp)
    8000322a:	f022                	sd	s0,32(sp)
    8000322c:	ec26                	sd	s1,24(sp)
    8000322e:	e84a                	sd	s2,16(sp)
    80003230:	e44e                	sd	s3,8(sp)
    80003232:	1800                	addi	s0,sp,48
    80003234:	892a                	mv	s2,a0
    80003236:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003238:	00015517          	auipc	a0,0x15
    8000323c:	7c850513          	addi	a0,a0,1992 # 80018a00 <bcache>
    80003240:	ffffe097          	auipc	ra,0xffffe
    80003244:	996080e7          	jalr	-1642(ra) # 80000bd6 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next)
    80003248:	0001e497          	auipc	s1,0x1e
    8000324c:	a704b483          	ld	s1,-1424(s1) # 80020cb8 <bcache+0x82b8>
    80003250:	0001e797          	auipc	a5,0x1e
    80003254:	a1878793          	addi	a5,a5,-1512 # 80020c68 <bcache+0x8268>
    80003258:	02f48f63          	beq	s1,a5,80003296 <bread+0x70>
    8000325c:	873e                	mv	a4,a5
    8000325e:	a021                	j	80003266 <bread+0x40>
    80003260:	68a4                	ld	s1,80(s1)
    80003262:	02e48a63          	beq	s1,a4,80003296 <bread+0x70>
    if (b->dev == dev && b->blockno == blockno)
    80003266:	449c                	lw	a5,8(s1)
    80003268:	ff279ce3          	bne	a5,s2,80003260 <bread+0x3a>
    8000326c:	44dc                	lw	a5,12(s1)
    8000326e:	ff3799e3          	bne	a5,s3,80003260 <bread+0x3a>
      b->refcnt++;
    80003272:	40bc                	lw	a5,64(s1)
    80003274:	2785                	addiw	a5,a5,1
    80003276:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003278:	00015517          	auipc	a0,0x15
    8000327c:	78850513          	addi	a0,a0,1928 # 80018a00 <bcache>
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	a0a080e7          	jalr	-1526(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003288:	01048513          	addi	a0,s1,16
    8000328c:	00001097          	auipc	ra,0x1
    80003290:	472080e7          	jalr	1138(ra) # 800046fe <acquiresleep>
      return b;
    80003294:	a8b9                	j	800032f2 <bread+0xcc>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    80003296:	0001e497          	auipc	s1,0x1e
    8000329a:	a1a4b483          	ld	s1,-1510(s1) # 80020cb0 <bcache+0x82b0>
    8000329e:	0001e797          	auipc	a5,0x1e
    800032a2:	9ca78793          	addi	a5,a5,-1590 # 80020c68 <bcache+0x8268>
    800032a6:	00f48863          	beq	s1,a5,800032b6 <bread+0x90>
    800032aa:	873e                	mv	a4,a5
    if (b->refcnt == 0)
    800032ac:	40bc                	lw	a5,64(s1)
    800032ae:	cf81                	beqz	a5,800032c6 <bread+0xa0>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    800032b0:	64a4                	ld	s1,72(s1)
    800032b2:	fee49de3          	bne	s1,a4,800032ac <bread+0x86>
  panic("bget: no buffers");
    800032b6:	00005517          	auipc	a0,0x5
    800032ba:	27a50513          	addi	a0,a0,634 # 80008530 <syscalls+0xd8>
    800032be:	ffffd097          	auipc	ra,0xffffd
    800032c2:	282080e7          	jalr	642(ra) # 80000540 <panic>
      b->dev = dev;
    800032c6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800032ca:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800032ce:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800032d2:	4785                	li	a5,1
    800032d4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032d6:	00015517          	auipc	a0,0x15
    800032da:	72a50513          	addi	a0,a0,1834 # 80018a00 <bcache>
    800032de:	ffffe097          	auipc	ra,0xffffe
    800032e2:	9ac080e7          	jalr	-1620(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800032e6:	01048513          	addi	a0,s1,16
    800032ea:	00001097          	auipc	ra,0x1
    800032ee:	414080e7          	jalr	1044(ra) # 800046fe <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid)
    800032f2:	409c                	lw	a5,0(s1)
    800032f4:	cb89                	beqz	a5,80003306 <bread+0xe0>
  {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800032f6:	8526                	mv	a0,s1
    800032f8:	70a2                	ld	ra,40(sp)
    800032fa:	7402                	ld	s0,32(sp)
    800032fc:	64e2                	ld	s1,24(sp)
    800032fe:	6942                	ld	s2,16(sp)
    80003300:	69a2                	ld	s3,8(sp)
    80003302:	6145                	addi	sp,sp,48
    80003304:	8082                	ret
    virtio_disk_rw(b, 0);
    80003306:	4581                	li	a1,0
    80003308:	8526                	mv	a0,s1
    8000330a:	00003097          	auipc	ra,0x3
    8000330e:	2ac080e7          	jalr	684(ra) # 800065b6 <virtio_disk_rw>
    b->valid = 1;
    80003312:	4785                	li	a5,1
    80003314:	c09c                	sw	a5,0(s1)
  return b;
    80003316:	b7c5                	j	800032f6 <bread+0xd0>

0000000080003318 <bwrite>:

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
    80003318:	1101                	addi	sp,sp,-32
    8000331a:	ec06                	sd	ra,24(sp)
    8000331c:	e822                	sd	s0,16(sp)
    8000331e:	e426                	sd	s1,8(sp)
    80003320:	1000                	addi	s0,sp,32
    80003322:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003324:	0541                	addi	a0,a0,16
    80003326:	00001097          	auipc	ra,0x1
    8000332a:	472080e7          	jalr	1138(ra) # 80004798 <holdingsleep>
    8000332e:	cd01                	beqz	a0,80003346 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003330:	4585                	li	a1,1
    80003332:	8526                	mv	a0,s1
    80003334:	00003097          	auipc	ra,0x3
    80003338:	282080e7          	jalr	642(ra) # 800065b6 <virtio_disk_rw>
}
    8000333c:	60e2                	ld	ra,24(sp)
    8000333e:	6442                	ld	s0,16(sp)
    80003340:	64a2                	ld	s1,8(sp)
    80003342:	6105                	addi	sp,sp,32
    80003344:	8082                	ret
    panic("bwrite");
    80003346:	00005517          	auipc	a0,0x5
    8000334a:	20250513          	addi	a0,a0,514 # 80008548 <syscalls+0xf0>
    8000334e:	ffffd097          	auipc	ra,0xffffd
    80003352:	1f2080e7          	jalr	498(ra) # 80000540 <panic>

0000000080003356 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)
{
    80003356:	1101                	addi	sp,sp,-32
    80003358:	ec06                	sd	ra,24(sp)
    8000335a:	e822                	sd	s0,16(sp)
    8000335c:	e426                	sd	s1,8(sp)
    8000335e:	e04a                	sd	s2,0(sp)
    80003360:	1000                	addi	s0,sp,32
    80003362:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003364:	01050913          	addi	s2,a0,16
    80003368:	854a                	mv	a0,s2
    8000336a:	00001097          	auipc	ra,0x1
    8000336e:	42e080e7          	jalr	1070(ra) # 80004798 <holdingsleep>
    80003372:	c92d                	beqz	a0,800033e4 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003374:	854a                	mv	a0,s2
    80003376:	00001097          	auipc	ra,0x1
    8000337a:	3de080e7          	jalr	990(ra) # 80004754 <releasesleep>

  acquire(&bcache.lock);
    8000337e:	00015517          	auipc	a0,0x15
    80003382:	68250513          	addi	a0,a0,1666 # 80018a00 <bcache>
    80003386:	ffffe097          	auipc	ra,0xffffe
    8000338a:	850080e7          	jalr	-1968(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000338e:	40bc                	lw	a5,64(s1)
    80003390:	37fd                	addiw	a5,a5,-1
    80003392:	0007871b          	sext.w	a4,a5
    80003396:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0)
    80003398:	eb05                	bnez	a4,800033c8 <brelse+0x72>
  {
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000339a:	68bc                	ld	a5,80(s1)
    8000339c:	64b8                	ld	a4,72(s1)
    8000339e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800033a0:	64bc                	ld	a5,72(s1)
    800033a2:	68b8                	ld	a4,80(s1)
    800033a4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800033a6:	0001d797          	auipc	a5,0x1d
    800033aa:	65a78793          	addi	a5,a5,1626 # 80020a00 <bcache+0x8000>
    800033ae:	2b87b703          	ld	a4,696(a5)
    800033b2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800033b4:	0001e717          	auipc	a4,0x1e
    800033b8:	8b470713          	addi	a4,a4,-1868 # 80020c68 <bcache+0x8268>
    800033bc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800033be:	2b87b703          	ld	a4,696(a5)
    800033c2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800033c4:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    800033c8:	00015517          	auipc	a0,0x15
    800033cc:	63850513          	addi	a0,a0,1592 # 80018a00 <bcache>
    800033d0:	ffffe097          	auipc	ra,0xffffe
    800033d4:	8ba080e7          	jalr	-1862(ra) # 80000c8a <release>
}
    800033d8:	60e2                	ld	ra,24(sp)
    800033da:	6442                	ld	s0,16(sp)
    800033dc:	64a2                	ld	s1,8(sp)
    800033de:	6902                	ld	s2,0(sp)
    800033e0:	6105                	addi	sp,sp,32
    800033e2:	8082                	ret
    panic("brelse");
    800033e4:	00005517          	auipc	a0,0x5
    800033e8:	16c50513          	addi	a0,a0,364 # 80008550 <syscalls+0xf8>
    800033ec:	ffffd097          	auipc	ra,0xffffd
    800033f0:	154080e7          	jalr	340(ra) # 80000540 <panic>

00000000800033f4 <bpin>:

void bpin(struct buf *b)
{
    800033f4:	1101                	addi	sp,sp,-32
    800033f6:	ec06                	sd	ra,24(sp)
    800033f8:	e822                	sd	s0,16(sp)
    800033fa:	e426                	sd	s1,8(sp)
    800033fc:	1000                	addi	s0,sp,32
    800033fe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003400:	00015517          	auipc	a0,0x15
    80003404:	60050513          	addi	a0,a0,1536 # 80018a00 <bcache>
    80003408:	ffffd097          	auipc	ra,0xffffd
    8000340c:	7ce080e7          	jalr	1998(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003410:	40bc                	lw	a5,64(s1)
    80003412:	2785                	addiw	a5,a5,1
    80003414:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003416:	00015517          	auipc	a0,0x15
    8000341a:	5ea50513          	addi	a0,a0,1514 # 80018a00 <bcache>
    8000341e:	ffffe097          	auipc	ra,0xffffe
    80003422:	86c080e7          	jalr	-1940(ra) # 80000c8a <release>
}
    80003426:	60e2                	ld	ra,24(sp)
    80003428:	6442                	ld	s0,16(sp)
    8000342a:	64a2                	ld	s1,8(sp)
    8000342c:	6105                	addi	sp,sp,32
    8000342e:	8082                	ret

0000000080003430 <bunpin>:

void bunpin(struct buf *b)
{
    80003430:	1101                	addi	sp,sp,-32
    80003432:	ec06                	sd	ra,24(sp)
    80003434:	e822                	sd	s0,16(sp)
    80003436:	e426                	sd	s1,8(sp)
    80003438:	1000                	addi	s0,sp,32
    8000343a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000343c:	00015517          	auipc	a0,0x15
    80003440:	5c450513          	addi	a0,a0,1476 # 80018a00 <bcache>
    80003444:	ffffd097          	auipc	ra,0xffffd
    80003448:	792080e7          	jalr	1938(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000344c:	40bc                	lw	a5,64(s1)
    8000344e:	37fd                	addiw	a5,a5,-1
    80003450:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003452:	00015517          	auipc	a0,0x15
    80003456:	5ae50513          	addi	a0,a0,1454 # 80018a00 <bcache>
    8000345a:	ffffe097          	auipc	ra,0xffffe
    8000345e:	830080e7          	jalr	-2000(ra) # 80000c8a <release>
}
    80003462:	60e2                	ld	ra,24(sp)
    80003464:	6442                	ld	s0,16(sp)
    80003466:	64a2                	ld	s1,8(sp)
    80003468:	6105                	addi	sp,sp,32
    8000346a:	8082                	ret

000000008000346c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000346c:	1101                	addi	sp,sp,-32
    8000346e:	ec06                	sd	ra,24(sp)
    80003470:	e822                	sd	s0,16(sp)
    80003472:	e426                	sd	s1,8(sp)
    80003474:	e04a                	sd	s2,0(sp)
    80003476:	1000                	addi	s0,sp,32
    80003478:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000347a:	00d5d59b          	srliw	a1,a1,0xd
    8000347e:	0001e797          	auipc	a5,0x1e
    80003482:	c5e7a783          	lw	a5,-930(a5) # 800210dc <sb+0x1c>
    80003486:	9dbd                	addw	a1,a1,a5
    80003488:	00000097          	auipc	ra,0x0
    8000348c:	d9e080e7          	jalr	-610(ra) # 80003226 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003490:	0074f713          	andi	a4,s1,7
    80003494:	4785                	li	a5,1
    80003496:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    8000349a:	14ce                	slli	s1,s1,0x33
    8000349c:	90d9                	srli	s1,s1,0x36
    8000349e:	00950733          	add	a4,a0,s1
    800034a2:	05874703          	lbu	a4,88(a4)
    800034a6:	00e7f6b3          	and	a3,a5,a4
    800034aa:	c69d                	beqz	a3,800034d8 <bfree+0x6c>
    800034ac:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    800034ae:	94aa                	add	s1,s1,a0
    800034b0:	fff7c793          	not	a5,a5
    800034b4:	8f7d                	and	a4,a4,a5
    800034b6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800034ba:	00001097          	auipc	ra,0x1
    800034be:	126080e7          	jalr	294(ra) # 800045e0 <log_write>
  brelse(bp);
    800034c2:	854a                	mv	a0,s2
    800034c4:	00000097          	auipc	ra,0x0
    800034c8:	e92080e7          	jalr	-366(ra) # 80003356 <brelse>
}
    800034cc:	60e2                	ld	ra,24(sp)
    800034ce:	6442                	ld	s0,16(sp)
    800034d0:	64a2                	ld	s1,8(sp)
    800034d2:	6902                	ld	s2,0(sp)
    800034d4:	6105                	addi	sp,sp,32
    800034d6:	8082                	ret
    panic("freeing free block");
    800034d8:	00005517          	auipc	a0,0x5
    800034dc:	08050513          	addi	a0,a0,128 # 80008558 <syscalls+0x100>
    800034e0:	ffffd097          	auipc	ra,0xffffd
    800034e4:	060080e7          	jalr	96(ra) # 80000540 <panic>

00000000800034e8 <balloc>:
{
    800034e8:	711d                	addi	sp,sp,-96
    800034ea:	ec86                	sd	ra,88(sp)
    800034ec:	e8a2                	sd	s0,80(sp)
    800034ee:	e4a6                	sd	s1,72(sp)
    800034f0:	e0ca                	sd	s2,64(sp)
    800034f2:	fc4e                	sd	s3,56(sp)
    800034f4:	f852                	sd	s4,48(sp)
    800034f6:	f456                	sd	s5,40(sp)
    800034f8:	f05a                	sd	s6,32(sp)
    800034fa:	ec5e                	sd	s7,24(sp)
    800034fc:	e862                	sd	s8,16(sp)
    800034fe:	e466                	sd	s9,8(sp)
    80003500:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB)
    80003502:	0001e797          	auipc	a5,0x1e
    80003506:	bc27a783          	lw	a5,-1086(a5) # 800210c4 <sb+0x4>
    8000350a:	cff5                	beqz	a5,80003606 <balloc+0x11e>
    8000350c:	8baa                	mv	s7,a0
    8000350e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003510:	0001eb17          	auipc	s6,0x1e
    80003514:	bb0b0b13          	addi	s6,s6,-1104 # 800210c0 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003518:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000351a:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    8000351c:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB)
    8000351e:	6c89                	lui	s9,0x2
    80003520:	a061                	j	800035a8 <balloc+0xc0>
        bp->data[bi / 8] |= m; // Mark block in use.
    80003522:	97ca                	add	a5,a5,s2
    80003524:	8e55                	or	a2,a2,a3
    80003526:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000352a:	854a                	mv	a0,s2
    8000352c:	00001097          	auipc	ra,0x1
    80003530:	0b4080e7          	jalr	180(ra) # 800045e0 <log_write>
        brelse(bp);
    80003534:	854a                	mv	a0,s2
    80003536:	00000097          	auipc	ra,0x0
    8000353a:	e20080e7          	jalr	-480(ra) # 80003356 <brelse>
  bp = bread(dev, bno);
    8000353e:	85a6                	mv	a1,s1
    80003540:	855e                	mv	a0,s7
    80003542:	00000097          	auipc	ra,0x0
    80003546:	ce4080e7          	jalr	-796(ra) # 80003226 <bread>
    8000354a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000354c:	40000613          	li	a2,1024
    80003550:	4581                	li	a1,0
    80003552:	05850513          	addi	a0,a0,88
    80003556:	ffffd097          	auipc	ra,0xffffd
    8000355a:	77c080e7          	jalr	1916(ra) # 80000cd2 <memset>
  log_write(bp);
    8000355e:	854a                	mv	a0,s2
    80003560:	00001097          	auipc	ra,0x1
    80003564:	080080e7          	jalr	128(ra) # 800045e0 <log_write>
  brelse(bp);
    80003568:	854a                	mv	a0,s2
    8000356a:	00000097          	auipc	ra,0x0
    8000356e:	dec080e7          	jalr	-532(ra) # 80003356 <brelse>
}
    80003572:	8526                	mv	a0,s1
    80003574:	60e6                	ld	ra,88(sp)
    80003576:	6446                	ld	s0,80(sp)
    80003578:	64a6                	ld	s1,72(sp)
    8000357a:	6906                	ld	s2,64(sp)
    8000357c:	79e2                	ld	s3,56(sp)
    8000357e:	7a42                	ld	s4,48(sp)
    80003580:	7aa2                	ld	s5,40(sp)
    80003582:	7b02                	ld	s6,32(sp)
    80003584:	6be2                	ld	s7,24(sp)
    80003586:	6c42                	ld	s8,16(sp)
    80003588:	6ca2                	ld	s9,8(sp)
    8000358a:	6125                	addi	sp,sp,96
    8000358c:	8082                	ret
    brelse(bp);
    8000358e:	854a                	mv	a0,s2
    80003590:	00000097          	auipc	ra,0x0
    80003594:	dc6080e7          	jalr	-570(ra) # 80003356 <brelse>
  for (b = 0; b < sb.size; b += BPB)
    80003598:	015c87bb          	addw	a5,s9,s5
    8000359c:	00078a9b          	sext.w	s5,a5
    800035a0:	004b2703          	lw	a4,4(s6)
    800035a4:	06eaf163          	bgeu	s5,a4,80003606 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800035a8:	41fad79b          	sraiw	a5,s5,0x1f
    800035ac:	0137d79b          	srliw	a5,a5,0x13
    800035b0:	015787bb          	addw	a5,a5,s5
    800035b4:	40d7d79b          	sraiw	a5,a5,0xd
    800035b8:	01cb2583          	lw	a1,28(s6)
    800035bc:	9dbd                	addw	a1,a1,a5
    800035be:	855e                	mv	a0,s7
    800035c0:	00000097          	auipc	ra,0x0
    800035c4:	c66080e7          	jalr	-922(ra) # 80003226 <bread>
    800035c8:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800035ca:	004b2503          	lw	a0,4(s6)
    800035ce:	000a849b          	sext.w	s1,s5
    800035d2:	8762                	mv	a4,s8
    800035d4:	faa4fde3          	bgeu	s1,a0,8000358e <balloc+0xa6>
      m = 1 << (bi % 8);
    800035d8:	00777693          	andi	a3,a4,7
    800035dc:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0)
    800035e0:	41f7579b          	sraiw	a5,a4,0x1f
    800035e4:	01d7d79b          	srliw	a5,a5,0x1d
    800035e8:	9fb9                	addw	a5,a5,a4
    800035ea:	4037d79b          	sraiw	a5,a5,0x3
    800035ee:	00f90633          	add	a2,s2,a5
    800035f2:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800035f6:	00c6f5b3          	and	a1,a3,a2
    800035fa:	d585                	beqz	a1,80003522 <balloc+0x3a>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800035fc:	2705                	addiw	a4,a4,1
    800035fe:	2485                	addiw	s1,s1,1
    80003600:	fd471ae3          	bne	a4,s4,800035d4 <balloc+0xec>
    80003604:	b769                	j	8000358e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003606:	00005517          	auipc	a0,0x5
    8000360a:	f6a50513          	addi	a0,a0,-150 # 80008570 <syscalls+0x118>
    8000360e:	ffffd097          	auipc	ra,0xffffd
    80003612:	f7c080e7          	jalr	-132(ra) # 8000058a <printf>
  return 0;
    80003616:	4481                	li	s1,0
    80003618:	bfa9                	j	80003572 <balloc+0x8a>

000000008000361a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000361a:	7179                	addi	sp,sp,-48
    8000361c:	f406                	sd	ra,40(sp)
    8000361e:	f022                	sd	s0,32(sp)
    80003620:	ec26                	sd	s1,24(sp)
    80003622:	e84a                	sd	s2,16(sp)
    80003624:	e44e                	sd	s3,8(sp)
    80003626:	e052                	sd	s4,0(sp)
    80003628:	1800                	addi	s0,sp,48
    8000362a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT)
    8000362c:	47ad                	li	a5,11
    8000362e:	02b7e863          	bltu	a5,a1,8000365e <bmap+0x44>
  {
    if ((addr = ip->addrs[bn]) == 0)
    80003632:	02059793          	slli	a5,a1,0x20
    80003636:	01e7d593          	srli	a1,a5,0x1e
    8000363a:	00b504b3          	add	s1,a0,a1
    8000363e:	0504a903          	lw	s2,80(s1)
    80003642:	06091e63          	bnez	s2,800036be <bmap+0xa4>
    {
      addr = balloc(ip->dev);
    80003646:	4108                	lw	a0,0(a0)
    80003648:	00000097          	auipc	ra,0x0
    8000364c:	ea0080e7          	jalr	-352(ra) # 800034e8 <balloc>
    80003650:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003654:	06090563          	beqz	s2,800036be <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003658:	0524a823          	sw	s2,80(s1)
    8000365c:	a08d                	j	800036be <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000365e:	ff45849b          	addiw	s1,a1,-12
    80003662:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT)
    80003666:	0ff00793          	li	a5,255
    8000366a:	08e7e563          	bltu	a5,a4,800036f4 <bmap+0xda>
  {
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0)
    8000366e:	08052903          	lw	s2,128(a0)
    80003672:	00091d63          	bnez	s2,8000368c <bmap+0x72>
    {
      addr = balloc(ip->dev);
    80003676:	4108                	lw	a0,0(a0)
    80003678:	00000097          	auipc	ra,0x0
    8000367c:	e70080e7          	jalr	-400(ra) # 800034e8 <balloc>
    80003680:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003684:	02090d63          	beqz	s2,800036be <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003688:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000368c:	85ca                	mv	a1,s2
    8000368e:	0009a503          	lw	a0,0(s3)
    80003692:	00000097          	auipc	ra,0x0
    80003696:	b94080e7          	jalr	-1132(ra) # 80003226 <bread>
    8000369a:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    8000369c:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0)
    800036a0:	02049713          	slli	a4,s1,0x20
    800036a4:	01e75593          	srli	a1,a4,0x1e
    800036a8:	00b784b3          	add	s1,a5,a1
    800036ac:	0004a903          	lw	s2,0(s1)
    800036b0:	02090063          	beqz	s2,800036d0 <bmap+0xb6>
      {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800036b4:	8552                	mv	a0,s4
    800036b6:	00000097          	auipc	ra,0x0
    800036ba:	ca0080e7          	jalr	-864(ra) # 80003356 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800036be:	854a                	mv	a0,s2
    800036c0:	70a2                	ld	ra,40(sp)
    800036c2:	7402                	ld	s0,32(sp)
    800036c4:	64e2                	ld	s1,24(sp)
    800036c6:	6942                	ld	s2,16(sp)
    800036c8:	69a2                	ld	s3,8(sp)
    800036ca:	6a02                	ld	s4,0(sp)
    800036cc:	6145                	addi	sp,sp,48
    800036ce:	8082                	ret
      addr = balloc(ip->dev);
    800036d0:	0009a503          	lw	a0,0(s3)
    800036d4:	00000097          	auipc	ra,0x0
    800036d8:	e14080e7          	jalr	-492(ra) # 800034e8 <balloc>
    800036dc:	0005091b          	sext.w	s2,a0
      if (addr)
    800036e0:	fc090ae3          	beqz	s2,800036b4 <bmap+0x9a>
        a[bn] = addr;
    800036e4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800036e8:	8552                	mv	a0,s4
    800036ea:	00001097          	auipc	ra,0x1
    800036ee:	ef6080e7          	jalr	-266(ra) # 800045e0 <log_write>
    800036f2:	b7c9                	j	800036b4 <bmap+0x9a>
  panic("bmap: out of range");
    800036f4:	00005517          	auipc	a0,0x5
    800036f8:	e9450513          	addi	a0,a0,-364 # 80008588 <syscalls+0x130>
    800036fc:	ffffd097          	auipc	ra,0xffffd
    80003700:	e44080e7          	jalr	-444(ra) # 80000540 <panic>

0000000080003704 <iget>:
{
    80003704:	7179                	addi	sp,sp,-48
    80003706:	f406                	sd	ra,40(sp)
    80003708:	f022                	sd	s0,32(sp)
    8000370a:	ec26                	sd	s1,24(sp)
    8000370c:	e84a                	sd	s2,16(sp)
    8000370e:	e44e                	sd	s3,8(sp)
    80003710:	e052                	sd	s4,0(sp)
    80003712:	1800                	addi	s0,sp,48
    80003714:	89aa                	mv	s3,a0
    80003716:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003718:	0001e517          	auipc	a0,0x1e
    8000371c:	9c850513          	addi	a0,a0,-1592 # 800210e0 <itable>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	4b6080e7          	jalr	1206(ra) # 80000bd6 <acquire>
  empty = 0;
    80003728:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    8000372a:	0001e497          	auipc	s1,0x1e
    8000372e:	9ce48493          	addi	s1,s1,-1586 # 800210f8 <itable+0x18>
    80003732:	0001f697          	auipc	a3,0x1f
    80003736:	45668693          	addi	a3,a3,1110 # 80022b88 <log>
    8000373a:	a039                	j	80003748 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000373c:	02090b63          	beqz	s2,80003772 <iget+0x6e>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    80003740:	08848493          	addi	s1,s1,136
    80003744:	02d48a63          	beq	s1,a3,80003778 <iget+0x74>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum)
    80003748:	449c                	lw	a5,8(s1)
    8000374a:	fef059e3          	blez	a5,8000373c <iget+0x38>
    8000374e:	4098                	lw	a4,0(s1)
    80003750:	ff3716e3          	bne	a4,s3,8000373c <iget+0x38>
    80003754:	40d8                	lw	a4,4(s1)
    80003756:	ff4713e3          	bne	a4,s4,8000373c <iget+0x38>
      ip->ref++;
    8000375a:	2785                	addiw	a5,a5,1
    8000375c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000375e:	0001e517          	auipc	a0,0x1e
    80003762:	98250513          	addi	a0,a0,-1662 # 800210e0 <itable>
    80003766:	ffffd097          	auipc	ra,0xffffd
    8000376a:	524080e7          	jalr	1316(ra) # 80000c8a <release>
      return ip;
    8000376e:	8926                	mv	s2,s1
    80003770:	a03d                	j	8000379e <iget+0x9a>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003772:	f7f9                	bnez	a5,80003740 <iget+0x3c>
    80003774:	8926                	mv	s2,s1
    80003776:	b7e9                	j	80003740 <iget+0x3c>
  if (empty == 0)
    80003778:	02090c63          	beqz	s2,800037b0 <iget+0xac>
  ip->dev = dev;
    8000377c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003780:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003784:	4785                	li	a5,1
    80003786:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000378a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000378e:	0001e517          	auipc	a0,0x1e
    80003792:	95250513          	addi	a0,a0,-1710 # 800210e0 <itable>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	4f4080e7          	jalr	1268(ra) # 80000c8a <release>
}
    8000379e:	854a                	mv	a0,s2
    800037a0:	70a2                	ld	ra,40(sp)
    800037a2:	7402                	ld	s0,32(sp)
    800037a4:	64e2                	ld	s1,24(sp)
    800037a6:	6942                	ld	s2,16(sp)
    800037a8:	69a2                	ld	s3,8(sp)
    800037aa:	6a02                	ld	s4,0(sp)
    800037ac:	6145                	addi	sp,sp,48
    800037ae:	8082                	ret
    panic("iget: no inodes");
    800037b0:	00005517          	auipc	a0,0x5
    800037b4:	df050513          	addi	a0,a0,-528 # 800085a0 <syscalls+0x148>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	d88080e7          	jalr	-632(ra) # 80000540 <panic>

00000000800037c0 <fsinit>:
{
    800037c0:	7179                	addi	sp,sp,-48
    800037c2:	f406                	sd	ra,40(sp)
    800037c4:	f022                	sd	s0,32(sp)
    800037c6:	ec26                	sd	s1,24(sp)
    800037c8:	e84a                	sd	s2,16(sp)
    800037ca:	e44e                	sd	s3,8(sp)
    800037cc:	1800                	addi	s0,sp,48
    800037ce:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800037d0:	4585                	li	a1,1
    800037d2:	00000097          	auipc	ra,0x0
    800037d6:	a54080e7          	jalr	-1452(ra) # 80003226 <bread>
    800037da:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037dc:	0001e997          	auipc	s3,0x1e
    800037e0:	8e498993          	addi	s3,s3,-1820 # 800210c0 <sb>
    800037e4:	02000613          	li	a2,32
    800037e8:	05850593          	addi	a1,a0,88
    800037ec:	854e                	mv	a0,s3
    800037ee:	ffffd097          	auipc	ra,0xffffd
    800037f2:	540080e7          	jalr	1344(ra) # 80000d2e <memmove>
  brelse(bp);
    800037f6:	8526                	mv	a0,s1
    800037f8:	00000097          	auipc	ra,0x0
    800037fc:	b5e080e7          	jalr	-1186(ra) # 80003356 <brelse>
  if (sb.magic != FSMAGIC)
    80003800:	0009a703          	lw	a4,0(s3)
    80003804:	102037b7          	lui	a5,0x10203
    80003808:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000380c:	02f71263          	bne	a4,a5,80003830 <fsinit+0x70>
  initlog(dev, &sb);
    80003810:	0001e597          	auipc	a1,0x1e
    80003814:	8b058593          	addi	a1,a1,-1872 # 800210c0 <sb>
    80003818:	854a                	mv	a0,s2
    8000381a:	00001097          	auipc	ra,0x1
    8000381e:	b4a080e7          	jalr	-1206(ra) # 80004364 <initlog>
}
    80003822:	70a2                	ld	ra,40(sp)
    80003824:	7402                	ld	s0,32(sp)
    80003826:	64e2                	ld	s1,24(sp)
    80003828:	6942                	ld	s2,16(sp)
    8000382a:	69a2                	ld	s3,8(sp)
    8000382c:	6145                	addi	sp,sp,48
    8000382e:	8082                	ret
    panic("invalid file system");
    80003830:	00005517          	auipc	a0,0x5
    80003834:	d8050513          	addi	a0,a0,-640 # 800085b0 <syscalls+0x158>
    80003838:	ffffd097          	auipc	ra,0xffffd
    8000383c:	d08080e7          	jalr	-760(ra) # 80000540 <panic>

0000000080003840 <iinit>:
{
    80003840:	7179                	addi	sp,sp,-48
    80003842:	f406                	sd	ra,40(sp)
    80003844:	f022                	sd	s0,32(sp)
    80003846:	ec26                	sd	s1,24(sp)
    80003848:	e84a                	sd	s2,16(sp)
    8000384a:	e44e                	sd	s3,8(sp)
    8000384c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000384e:	00005597          	auipc	a1,0x5
    80003852:	d7a58593          	addi	a1,a1,-646 # 800085c8 <syscalls+0x170>
    80003856:	0001e517          	auipc	a0,0x1e
    8000385a:	88a50513          	addi	a0,a0,-1910 # 800210e0 <itable>
    8000385e:	ffffd097          	auipc	ra,0xffffd
    80003862:	2e8080e7          	jalr	744(ra) # 80000b46 <initlock>
  for (i = 0; i < NINODE; i++)
    80003866:	0001e497          	auipc	s1,0x1e
    8000386a:	8a248493          	addi	s1,s1,-1886 # 80021108 <itable+0x28>
    8000386e:	0001f997          	auipc	s3,0x1f
    80003872:	32a98993          	addi	s3,s3,810 # 80022b98 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003876:	00005917          	auipc	s2,0x5
    8000387a:	d5a90913          	addi	s2,s2,-678 # 800085d0 <syscalls+0x178>
    8000387e:	85ca                	mv	a1,s2
    80003880:	8526                	mv	a0,s1
    80003882:	00001097          	auipc	ra,0x1
    80003886:	e42080e7          	jalr	-446(ra) # 800046c4 <initsleeplock>
  for (i = 0; i < NINODE; i++)
    8000388a:	08848493          	addi	s1,s1,136
    8000388e:	ff3498e3          	bne	s1,s3,8000387e <iinit+0x3e>
}
    80003892:	70a2                	ld	ra,40(sp)
    80003894:	7402                	ld	s0,32(sp)
    80003896:	64e2                	ld	s1,24(sp)
    80003898:	6942                	ld	s2,16(sp)
    8000389a:	69a2                	ld	s3,8(sp)
    8000389c:	6145                	addi	sp,sp,48
    8000389e:	8082                	ret

00000000800038a0 <ialloc>:
{
    800038a0:	715d                	addi	sp,sp,-80
    800038a2:	e486                	sd	ra,72(sp)
    800038a4:	e0a2                	sd	s0,64(sp)
    800038a6:	fc26                	sd	s1,56(sp)
    800038a8:	f84a                	sd	s2,48(sp)
    800038aa:	f44e                	sd	s3,40(sp)
    800038ac:	f052                	sd	s4,32(sp)
    800038ae:	ec56                	sd	s5,24(sp)
    800038b0:	e85a                	sd	s6,16(sp)
    800038b2:	e45e                	sd	s7,8(sp)
    800038b4:	0880                	addi	s0,sp,80
  for (inum = 1; inum < sb.ninodes; inum++)
    800038b6:	0001e717          	auipc	a4,0x1e
    800038ba:	81672703          	lw	a4,-2026(a4) # 800210cc <sb+0xc>
    800038be:	4785                	li	a5,1
    800038c0:	04e7fa63          	bgeu	a5,a4,80003914 <ialloc+0x74>
    800038c4:	8aaa                	mv	s5,a0
    800038c6:	8bae                	mv	s7,a1
    800038c8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800038ca:	0001da17          	auipc	s4,0x1d
    800038ce:	7f6a0a13          	addi	s4,s4,2038 # 800210c0 <sb>
    800038d2:	00048b1b          	sext.w	s6,s1
    800038d6:	0044d593          	srli	a1,s1,0x4
    800038da:	018a2783          	lw	a5,24(s4)
    800038de:	9dbd                	addw	a1,a1,a5
    800038e0:	8556                	mv	a0,s5
    800038e2:	00000097          	auipc	ra,0x0
    800038e6:	944080e7          	jalr	-1724(ra) # 80003226 <bread>
    800038ea:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800038ec:	05850993          	addi	s3,a0,88
    800038f0:	00f4f793          	andi	a5,s1,15
    800038f4:	079a                	slli	a5,a5,0x6
    800038f6:	99be                	add	s3,s3,a5
    if (dip->type == 0)
    800038f8:	00099783          	lh	a5,0(s3)
    800038fc:	c3a1                	beqz	a5,8000393c <ialloc+0x9c>
    brelse(bp);
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	a58080e7          	jalr	-1448(ra) # 80003356 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++)
    80003906:	0485                	addi	s1,s1,1
    80003908:	00ca2703          	lw	a4,12(s4)
    8000390c:	0004879b          	sext.w	a5,s1
    80003910:	fce7e1e3          	bltu	a5,a4,800038d2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003914:	00005517          	auipc	a0,0x5
    80003918:	cc450513          	addi	a0,a0,-828 # 800085d8 <syscalls+0x180>
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	c6e080e7          	jalr	-914(ra) # 8000058a <printf>
  return 0;
    80003924:	4501                	li	a0,0
}
    80003926:	60a6                	ld	ra,72(sp)
    80003928:	6406                	ld	s0,64(sp)
    8000392a:	74e2                	ld	s1,56(sp)
    8000392c:	7942                	ld	s2,48(sp)
    8000392e:	79a2                	ld	s3,40(sp)
    80003930:	7a02                	ld	s4,32(sp)
    80003932:	6ae2                	ld	s5,24(sp)
    80003934:	6b42                	ld	s6,16(sp)
    80003936:	6ba2                	ld	s7,8(sp)
    80003938:	6161                	addi	sp,sp,80
    8000393a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000393c:	04000613          	li	a2,64
    80003940:	4581                	li	a1,0
    80003942:	854e                	mv	a0,s3
    80003944:	ffffd097          	auipc	ra,0xffffd
    80003948:	38e080e7          	jalr	910(ra) # 80000cd2 <memset>
      dip->type = type;
    8000394c:	01799023          	sh	s7,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003950:	854a                	mv	a0,s2
    80003952:	00001097          	auipc	ra,0x1
    80003956:	c8e080e7          	jalr	-882(ra) # 800045e0 <log_write>
      brelse(bp);
    8000395a:	854a                	mv	a0,s2
    8000395c:	00000097          	auipc	ra,0x0
    80003960:	9fa080e7          	jalr	-1542(ra) # 80003356 <brelse>
      return iget(dev, inum);
    80003964:	85da                	mv	a1,s6
    80003966:	8556                	mv	a0,s5
    80003968:	00000097          	auipc	ra,0x0
    8000396c:	d9c080e7          	jalr	-612(ra) # 80003704 <iget>
    80003970:	bf5d                	j	80003926 <ialloc+0x86>

0000000080003972 <iupdate>:
{
    80003972:	1101                	addi	sp,sp,-32
    80003974:	ec06                	sd	ra,24(sp)
    80003976:	e822                	sd	s0,16(sp)
    80003978:	e426                	sd	s1,8(sp)
    8000397a:	e04a                	sd	s2,0(sp)
    8000397c:	1000                	addi	s0,sp,32
    8000397e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003980:	415c                	lw	a5,4(a0)
    80003982:	0047d79b          	srliw	a5,a5,0x4
    80003986:	0001d597          	auipc	a1,0x1d
    8000398a:	7525a583          	lw	a1,1874(a1) # 800210d8 <sb+0x18>
    8000398e:	9dbd                	addw	a1,a1,a5
    80003990:	4108                	lw	a0,0(a0)
    80003992:	00000097          	auipc	ra,0x0
    80003996:	894080e7          	jalr	-1900(ra) # 80003226 <bread>
    8000399a:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000399c:	05850793          	addi	a5,a0,88
    800039a0:	40d8                	lw	a4,4(s1)
    800039a2:	8b3d                	andi	a4,a4,15
    800039a4:	071a                	slli	a4,a4,0x6
    800039a6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800039a8:	04449703          	lh	a4,68(s1)
    800039ac:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800039b0:	04649703          	lh	a4,70(s1)
    800039b4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800039b8:	04849703          	lh	a4,72(s1)
    800039bc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800039c0:	04a49703          	lh	a4,74(s1)
    800039c4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800039c8:	44f8                	lw	a4,76(s1)
    800039ca:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800039cc:	03400613          	li	a2,52
    800039d0:	05048593          	addi	a1,s1,80
    800039d4:	00c78513          	addi	a0,a5,12
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	356080e7          	jalr	854(ra) # 80000d2e <memmove>
  log_write(bp);
    800039e0:	854a                	mv	a0,s2
    800039e2:	00001097          	auipc	ra,0x1
    800039e6:	bfe080e7          	jalr	-1026(ra) # 800045e0 <log_write>
  brelse(bp);
    800039ea:	854a                	mv	a0,s2
    800039ec:	00000097          	auipc	ra,0x0
    800039f0:	96a080e7          	jalr	-1686(ra) # 80003356 <brelse>
}
    800039f4:	60e2                	ld	ra,24(sp)
    800039f6:	6442                	ld	s0,16(sp)
    800039f8:	64a2                	ld	s1,8(sp)
    800039fa:	6902                	ld	s2,0(sp)
    800039fc:	6105                	addi	sp,sp,32
    800039fe:	8082                	ret

0000000080003a00 <idup>:
{
    80003a00:	1101                	addi	sp,sp,-32
    80003a02:	ec06                	sd	ra,24(sp)
    80003a04:	e822                	sd	s0,16(sp)
    80003a06:	e426                	sd	s1,8(sp)
    80003a08:	1000                	addi	s0,sp,32
    80003a0a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a0c:	0001d517          	auipc	a0,0x1d
    80003a10:	6d450513          	addi	a0,a0,1748 # 800210e0 <itable>
    80003a14:	ffffd097          	auipc	ra,0xffffd
    80003a18:	1c2080e7          	jalr	450(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003a1c:	449c                	lw	a5,8(s1)
    80003a1e:	2785                	addiw	a5,a5,1
    80003a20:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a22:	0001d517          	auipc	a0,0x1d
    80003a26:	6be50513          	addi	a0,a0,1726 # 800210e0 <itable>
    80003a2a:	ffffd097          	auipc	ra,0xffffd
    80003a2e:	260080e7          	jalr	608(ra) # 80000c8a <release>
}
    80003a32:	8526                	mv	a0,s1
    80003a34:	60e2                	ld	ra,24(sp)
    80003a36:	6442                	ld	s0,16(sp)
    80003a38:	64a2                	ld	s1,8(sp)
    80003a3a:	6105                	addi	sp,sp,32
    80003a3c:	8082                	ret

0000000080003a3e <ilock>:
{
    80003a3e:	1101                	addi	sp,sp,-32
    80003a40:	ec06                	sd	ra,24(sp)
    80003a42:	e822                	sd	s0,16(sp)
    80003a44:	e426                	sd	s1,8(sp)
    80003a46:	e04a                	sd	s2,0(sp)
    80003a48:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003a4a:	c115                	beqz	a0,80003a6e <ilock+0x30>
    80003a4c:	84aa                	mv	s1,a0
    80003a4e:	451c                	lw	a5,8(a0)
    80003a50:	00f05f63          	blez	a5,80003a6e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a54:	0541                	addi	a0,a0,16
    80003a56:	00001097          	auipc	ra,0x1
    80003a5a:	ca8080e7          	jalr	-856(ra) # 800046fe <acquiresleep>
  if (ip->valid == 0)
    80003a5e:	40bc                	lw	a5,64(s1)
    80003a60:	cf99                	beqz	a5,80003a7e <ilock+0x40>
}
    80003a62:	60e2                	ld	ra,24(sp)
    80003a64:	6442                	ld	s0,16(sp)
    80003a66:	64a2                	ld	s1,8(sp)
    80003a68:	6902                	ld	s2,0(sp)
    80003a6a:	6105                	addi	sp,sp,32
    80003a6c:	8082                	ret
    panic("ilock");
    80003a6e:	00005517          	auipc	a0,0x5
    80003a72:	b8250513          	addi	a0,a0,-1150 # 800085f0 <syscalls+0x198>
    80003a76:	ffffd097          	auipc	ra,0xffffd
    80003a7a:	aca080e7          	jalr	-1334(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a7e:	40dc                	lw	a5,4(s1)
    80003a80:	0047d79b          	srliw	a5,a5,0x4
    80003a84:	0001d597          	auipc	a1,0x1d
    80003a88:	6545a583          	lw	a1,1620(a1) # 800210d8 <sb+0x18>
    80003a8c:	9dbd                	addw	a1,a1,a5
    80003a8e:	4088                	lw	a0,0(s1)
    80003a90:	fffff097          	auipc	ra,0xfffff
    80003a94:	796080e7          	jalr	1942(ra) # 80003226 <bread>
    80003a98:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003a9a:	05850593          	addi	a1,a0,88
    80003a9e:	40dc                	lw	a5,4(s1)
    80003aa0:	8bbd                	andi	a5,a5,15
    80003aa2:	079a                	slli	a5,a5,0x6
    80003aa4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003aa6:	00059783          	lh	a5,0(a1)
    80003aaa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003aae:	00259783          	lh	a5,2(a1)
    80003ab2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ab6:	00459783          	lh	a5,4(a1)
    80003aba:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003abe:	00659783          	lh	a5,6(a1)
    80003ac2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003ac6:	459c                	lw	a5,8(a1)
    80003ac8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003aca:	03400613          	li	a2,52
    80003ace:	05b1                	addi	a1,a1,12
    80003ad0:	05048513          	addi	a0,s1,80
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	25a080e7          	jalr	602(ra) # 80000d2e <memmove>
    brelse(bp);
    80003adc:	854a                	mv	a0,s2
    80003ade:	00000097          	auipc	ra,0x0
    80003ae2:	878080e7          	jalr	-1928(ra) # 80003356 <brelse>
    ip->valid = 1;
    80003ae6:	4785                	li	a5,1
    80003ae8:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003aea:	04449783          	lh	a5,68(s1)
    80003aee:	fbb5                	bnez	a5,80003a62 <ilock+0x24>
      panic("ilock: no type");
    80003af0:	00005517          	auipc	a0,0x5
    80003af4:	b0850513          	addi	a0,a0,-1272 # 800085f8 <syscalls+0x1a0>
    80003af8:	ffffd097          	auipc	ra,0xffffd
    80003afc:	a48080e7          	jalr	-1464(ra) # 80000540 <panic>

0000000080003b00 <iunlock>:
{
    80003b00:	1101                	addi	sp,sp,-32
    80003b02:	ec06                	sd	ra,24(sp)
    80003b04:	e822                	sd	s0,16(sp)
    80003b06:	e426                	sd	s1,8(sp)
    80003b08:	e04a                	sd	s2,0(sp)
    80003b0a:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b0c:	c905                	beqz	a0,80003b3c <iunlock+0x3c>
    80003b0e:	84aa                	mv	s1,a0
    80003b10:	01050913          	addi	s2,a0,16
    80003b14:	854a                	mv	a0,s2
    80003b16:	00001097          	auipc	ra,0x1
    80003b1a:	c82080e7          	jalr	-894(ra) # 80004798 <holdingsleep>
    80003b1e:	cd19                	beqz	a0,80003b3c <iunlock+0x3c>
    80003b20:	449c                	lw	a5,8(s1)
    80003b22:	00f05d63          	blez	a5,80003b3c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b26:	854a                	mv	a0,s2
    80003b28:	00001097          	auipc	ra,0x1
    80003b2c:	c2c080e7          	jalr	-980(ra) # 80004754 <releasesleep>
}
    80003b30:	60e2                	ld	ra,24(sp)
    80003b32:	6442                	ld	s0,16(sp)
    80003b34:	64a2                	ld	s1,8(sp)
    80003b36:	6902                	ld	s2,0(sp)
    80003b38:	6105                	addi	sp,sp,32
    80003b3a:	8082                	ret
    panic("iunlock");
    80003b3c:	00005517          	auipc	a0,0x5
    80003b40:	acc50513          	addi	a0,a0,-1332 # 80008608 <syscalls+0x1b0>
    80003b44:	ffffd097          	auipc	ra,0xffffd
    80003b48:	9fc080e7          	jalr	-1540(ra) # 80000540 <panic>

0000000080003b4c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void itrunc(struct inode *ip)
{
    80003b4c:	7179                	addi	sp,sp,-48
    80003b4e:	f406                	sd	ra,40(sp)
    80003b50:	f022                	sd	s0,32(sp)
    80003b52:	ec26                	sd	s1,24(sp)
    80003b54:	e84a                	sd	s2,16(sp)
    80003b56:	e44e                	sd	s3,8(sp)
    80003b58:	e052                	sd	s4,0(sp)
    80003b5a:	1800                	addi	s0,sp,48
    80003b5c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++)
    80003b5e:	05050493          	addi	s1,a0,80
    80003b62:	08050913          	addi	s2,a0,128
    80003b66:	a021                	j	80003b6e <itrunc+0x22>
    80003b68:	0491                	addi	s1,s1,4
    80003b6a:	01248d63          	beq	s1,s2,80003b84 <itrunc+0x38>
  {
    if (ip->addrs[i])
    80003b6e:	408c                	lw	a1,0(s1)
    80003b70:	dde5                	beqz	a1,80003b68 <itrunc+0x1c>
    {
      bfree(ip->dev, ip->addrs[i]);
    80003b72:	0009a503          	lw	a0,0(s3)
    80003b76:	00000097          	auipc	ra,0x0
    80003b7a:	8f6080e7          	jalr	-1802(ra) # 8000346c <bfree>
      ip->addrs[i] = 0;
    80003b7e:	0004a023          	sw	zero,0(s1)
    80003b82:	b7dd                	j	80003b68 <itrunc+0x1c>
    }
  }

  if (ip->addrs[NDIRECT])
    80003b84:	0809a583          	lw	a1,128(s3)
    80003b88:	e185                	bnez	a1,80003ba8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b8a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b8e:	854e                	mv	a0,s3
    80003b90:	00000097          	auipc	ra,0x0
    80003b94:	de2080e7          	jalr	-542(ra) # 80003972 <iupdate>
}
    80003b98:	70a2                	ld	ra,40(sp)
    80003b9a:	7402                	ld	s0,32(sp)
    80003b9c:	64e2                	ld	s1,24(sp)
    80003b9e:	6942                	ld	s2,16(sp)
    80003ba0:	69a2                	ld	s3,8(sp)
    80003ba2:	6a02                	ld	s4,0(sp)
    80003ba4:	6145                	addi	sp,sp,48
    80003ba6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ba8:	0009a503          	lw	a0,0(s3)
    80003bac:	fffff097          	auipc	ra,0xfffff
    80003bb0:	67a080e7          	jalr	1658(ra) # 80003226 <bread>
    80003bb4:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++)
    80003bb6:	05850493          	addi	s1,a0,88
    80003bba:	45850913          	addi	s2,a0,1112
    80003bbe:	a021                	j	80003bc6 <itrunc+0x7a>
    80003bc0:	0491                	addi	s1,s1,4
    80003bc2:	01248b63          	beq	s1,s2,80003bd8 <itrunc+0x8c>
      if (a[j])
    80003bc6:	408c                	lw	a1,0(s1)
    80003bc8:	dde5                	beqz	a1,80003bc0 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003bca:	0009a503          	lw	a0,0(s3)
    80003bce:	00000097          	auipc	ra,0x0
    80003bd2:	89e080e7          	jalr	-1890(ra) # 8000346c <bfree>
    80003bd6:	b7ed                	j	80003bc0 <itrunc+0x74>
    brelse(bp);
    80003bd8:	8552                	mv	a0,s4
    80003bda:	fffff097          	auipc	ra,0xfffff
    80003bde:	77c080e7          	jalr	1916(ra) # 80003356 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003be2:	0809a583          	lw	a1,128(s3)
    80003be6:	0009a503          	lw	a0,0(s3)
    80003bea:	00000097          	auipc	ra,0x0
    80003bee:	882080e7          	jalr	-1918(ra) # 8000346c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003bf2:	0809a023          	sw	zero,128(s3)
    80003bf6:	bf51                	j	80003b8a <itrunc+0x3e>

0000000080003bf8 <iput>:
{
    80003bf8:	1101                	addi	sp,sp,-32
    80003bfa:	ec06                	sd	ra,24(sp)
    80003bfc:	e822                	sd	s0,16(sp)
    80003bfe:	e426                	sd	s1,8(sp)
    80003c00:	e04a                	sd	s2,0(sp)
    80003c02:	1000                	addi	s0,sp,32
    80003c04:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c06:	0001d517          	auipc	a0,0x1d
    80003c0a:	4da50513          	addi	a0,a0,1242 # 800210e0 <itable>
    80003c0e:	ffffd097          	auipc	ra,0xffffd
    80003c12:	fc8080e7          	jalr	-56(ra) # 80000bd6 <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003c16:	4498                	lw	a4,8(s1)
    80003c18:	4785                	li	a5,1
    80003c1a:	02f70363          	beq	a4,a5,80003c40 <iput+0x48>
  ip->ref--;
    80003c1e:	449c                	lw	a5,8(s1)
    80003c20:	37fd                	addiw	a5,a5,-1
    80003c22:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c24:	0001d517          	auipc	a0,0x1d
    80003c28:	4bc50513          	addi	a0,a0,1212 # 800210e0 <itable>
    80003c2c:	ffffd097          	auipc	ra,0xffffd
    80003c30:	05e080e7          	jalr	94(ra) # 80000c8a <release>
}
    80003c34:	60e2                	ld	ra,24(sp)
    80003c36:	6442                	ld	s0,16(sp)
    80003c38:	64a2                	ld	s1,8(sp)
    80003c3a:	6902                	ld	s2,0(sp)
    80003c3c:	6105                	addi	sp,sp,32
    80003c3e:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003c40:	40bc                	lw	a5,64(s1)
    80003c42:	dff1                	beqz	a5,80003c1e <iput+0x26>
    80003c44:	04a49783          	lh	a5,74(s1)
    80003c48:	fbf9                	bnez	a5,80003c1e <iput+0x26>
    acquiresleep(&ip->lock);
    80003c4a:	01048913          	addi	s2,s1,16
    80003c4e:	854a                	mv	a0,s2
    80003c50:	00001097          	auipc	ra,0x1
    80003c54:	aae080e7          	jalr	-1362(ra) # 800046fe <acquiresleep>
    release(&itable.lock);
    80003c58:	0001d517          	auipc	a0,0x1d
    80003c5c:	48850513          	addi	a0,a0,1160 # 800210e0 <itable>
    80003c60:	ffffd097          	auipc	ra,0xffffd
    80003c64:	02a080e7          	jalr	42(ra) # 80000c8a <release>
    itrunc(ip);
    80003c68:	8526                	mv	a0,s1
    80003c6a:	00000097          	auipc	ra,0x0
    80003c6e:	ee2080e7          	jalr	-286(ra) # 80003b4c <itrunc>
    ip->type = 0;
    80003c72:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c76:	8526                	mv	a0,s1
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	cfa080e7          	jalr	-774(ra) # 80003972 <iupdate>
    ip->valid = 0;
    80003c80:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c84:	854a                	mv	a0,s2
    80003c86:	00001097          	auipc	ra,0x1
    80003c8a:	ace080e7          	jalr	-1330(ra) # 80004754 <releasesleep>
    acquire(&itable.lock);
    80003c8e:	0001d517          	auipc	a0,0x1d
    80003c92:	45250513          	addi	a0,a0,1106 # 800210e0 <itable>
    80003c96:	ffffd097          	auipc	ra,0xffffd
    80003c9a:	f40080e7          	jalr	-192(ra) # 80000bd6 <acquire>
    80003c9e:	b741                	j	80003c1e <iput+0x26>

0000000080003ca0 <iunlockput>:
{
    80003ca0:	1101                	addi	sp,sp,-32
    80003ca2:	ec06                	sd	ra,24(sp)
    80003ca4:	e822                	sd	s0,16(sp)
    80003ca6:	e426                	sd	s1,8(sp)
    80003ca8:	1000                	addi	s0,sp,32
    80003caa:	84aa                	mv	s1,a0
  iunlock(ip);
    80003cac:	00000097          	auipc	ra,0x0
    80003cb0:	e54080e7          	jalr	-428(ra) # 80003b00 <iunlock>
  iput(ip);
    80003cb4:	8526                	mv	a0,s1
    80003cb6:	00000097          	auipc	ra,0x0
    80003cba:	f42080e7          	jalr	-190(ra) # 80003bf8 <iput>
}
    80003cbe:	60e2                	ld	ra,24(sp)
    80003cc0:	6442                	ld	s0,16(sp)
    80003cc2:	64a2                	ld	s1,8(sp)
    80003cc4:	6105                	addi	sp,sp,32
    80003cc6:	8082                	ret

0000000080003cc8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void stati(struct inode *ip, struct stat *st)
{
    80003cc8:	1141                	addi	sp,sp,-16
    80003cca:	e422                	sd	s0,8(sp)
    80003ccc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003cce:	411c                	lw	a5,0(a0)
    80003cd0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003cd2:	415c                	lw	a5,4(a0)
    80003cd4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003cd6:	04451783          	lh	a5,68(a0)
    80003cda:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003cde:	04a51783          	lh	a5,74(a0)
    80003ce2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ce6:	04c56783          	lwu	a5,76(a0)
    80003cea:	e99c                	sd	a5,16(a1)
}
    80003cec:	6422                	ld	s0,8(sp)
    80003cee:	0141                	addi	sp,sp,16
    80003cf0:	8082                	ret

0000000080003cf2 <readi>:
int readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003cf2:	457c                	lw	a5,76(a0)
    80003cf4:	0ed7e963          	bltu	a5,a3,80003de6 <readi+0xf4>
{
    80003cf8:	7159                	addi	sp,sp,-112
    80003cfa:	f486                	sd	ra,104(sp)
    80003cfc:	f0a2                	sd	s0,96(sp)
    80003cfe:	eca6                	sd	s1,88(sp)
    80003d00:	e8ca                	sd	s2,80(sp)
    80003d02:	e4ce                	sd	s3,72(sp)
    80003d04:	e0d2                	sd	s4,64(sp)
    80003d06:	fc56                	sd	s5,56(sp)
    80003d08:	f85a                	sd	s6,48(sp)
    80003d0a:	f45e                	sd	s7,40(sp)
    80003d0c:	f062                	sd	s8,32(sp)
    80003d0e:	ec66                	sd	s9,24(sp)
    80003d10:	e86a                	sd	s10,16(sp)
    80003d12:	e46e                	sd	s11,8(sp)
    80003d14:	1880                	addi	s0,sp,112
    80003d16:	8b2a                	mv	s6,a0
    80003d18:	8bae                	mv	s7,a1
    80003d1a:	8a32                	mv	s4,a2
    80003d1c:	84b6                	mv	s1,a3
    80003d1e:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003d20:	9f35                	addw	a4,a4,a3
    return 0;
    80003d22:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003d24:	0ad76063          	bltu	a4,a3,80003dc4 <readi+0xd2>
  if (off + n > ip->size)
    80003d28:	00e7f463          	bgeu	a5,a4,80003d30 <readi+0x3e>
    n = ip->size - off;
    80003d2c:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003d30:	0a0a8963          	beqz	s5,80003de2 <readi+0xf0>
    80003d34:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003d36:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1)
    80003d3a:	5c7d                	li	s8,-1
    80003d3c:	a82d                	j	80003d76 <readi+0x84>
    80003d3e:	020d1d93          	slli	s11,s10,0x20
    80003d42:	020ddd93          	srli	s11,s11,0x20
    80003d46:	05890613          	addi	a2,s2,88
    80003d4a:	86ee                	mv	a3,s11
    80003d4c:	963a                	add	a2,a2,a4
    80003d4e:	85d2                	mv	a1,s4
    80003d50:	855e                	mv	a0,s7
    80003d52:	ffffe097          	auipc	ra,0xffffe
    80003d56:	7da080e7          	jalr	2010(ra) # 8000252c <either_copyout>
    80003d5a:	05850d63          	beq	a0,s8,80003db4 <readi+0xc2>
    {
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d5e:	854a                	mv	a0,s2
    80003d60:	fffff097          	auipc	ra,0xfffff
    80003d64:	5f6080e7          	jalr	1526(ra) # 80003356 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003d68:	013d09bb          	addw	s3,s10,s3
    80003d6c:	009d04bb          	addw	s1,s10,s1
    80003d70:	9a6e                	add	s4,s4,s11
    80003d72:	0559f763          	bgeu	s3,s5,80003dc0 <readi+0xce>
    uint addr = bmap(ip, off / BSIZE);
    80003d76:	00a4d59b          	srliw	a1,s1,0xa
    80003d7a:	855a                	mv	a0,s6
    80003d7c:	00000097          	auipc	ra,0x0
    80003d80:	89e080e7          	jalr	-1890(ra) # 8000361a <bmap>
    80003d84:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003d88:	cd85                	beqz	a1,80003dc0 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d8a:	000b2503          	lw	a0,0(s6)
    80003d8e:	fffff097          	auipc	ra,0xfffff
    80003d92:	498080e7          	jalr	1176(ra) # 80003226 <bread>
    80003d96:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003d98:	3ff4f713          	andi	a4,s1,1023
    80003d9c:	40ec87bb          	subw	a5,s9,a4
    80003da0:	413a86bb          	subw	a3,s5,s3
    80003da4:	8d3e                	mv	s10,a5
    80003da6:	2781                	sext.w	a5,a5
    80003da8:	0006861b          	sext.w	a2,a3
    80003dac:	f8f679e3          	bgeu	a2,a5,80003d3e <readi+0x4c>
    80003db0:	8d36                	mv	s10,a3
    80003db2:	b771                	j	80003d3e <readi+0x4c>
      brelse(bp);
    80003db4:	854a                	mv	a0,s2
    80003db6:	fffff097          	auipc	ra,0xfffff
    80003dba:	5a0080e7          	jalr	1440(ra) # 80003356 <brelse>
      tot = -1;
    80003dbe:	59fd                	li	s3,-1
  }
  return tot;
    80003dc0:	0009851b          	sext.w	a0,s3
}
    80003dc4:	70a6                	ld	ra,104(sp)
    80003dc6:	7406                	ld	s0,96(sp)
    80003dc8:	64e6                	ld	s1,88(sp)
    80003dca:	6946                	ld	s2,80(sp)
    80003dcc:	69a6                	ld	s3,72(sp)
    80003dce:	6a06                	ld	s4,64(sp)
    80003dd0:	7ae2                	ld	s5,56(sp)
    80003dd2:	7b42                	ld	s6,48(sp)
    80003dd4:	7ba2                	ld	s7,40(sp)
    80003dd6:	7c02                	ld	s8,32(sp)
    80003dd8:	6ce2                	ld	s9,24(sp)
    80003dda:	6d42                	ld	s10,16(sp)
    80003ddc:	6da2                	ld	s11,8(sp)
    80003dde:	6165                	addi	sp,sp,112
    80003de0:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003de2:	89d6                	mv	s3,s5
    80003de4:	bff1                	j	80003dc0 <readi+0xce>
    return 0;
    80003de6:	4501                	li	a0,0
}
    80003de8:	8082                	ret

0000000080003dea <writei>:
int writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003dea:	457c                	lw	a5,76(a0)
    80003dec:	10d7e863          	bltu	a5,a3,80003efc <writei+0x112>
{
    80003df0:	7159                	addi	sp,sp,-112
    80003df2:	f486                	sd	ra,104(sp)
    80003df4:	f0a2                	sd	s0,96(sp)
    80003df6:	eca6                	sd	s1,88(sp)
    80003df8:	e8ca                	sd	s2,80(sp)
    80003dfa:	e4ce                	sd	s3,72(sp)
    80003dfc:	e0d2                	sd	s4,64(sp)
    80003dfe:	fc56                	sd	s5,56(sp)
    80003e00:	f85a                	sd	s6,48(sp)
    80003e02:	f45e                	sd	s7,40(sp)
    80003e04:	f062                	sd	s8,32(sp)
    80003e06:	ec66                	sd	s9,24(sp)
    80003e08:	e86a                	sd	s10,16(sp)
    80003e0a:	e46e                	sd	s11,8(sp)
    80003e0c:	1880                	addi	s0,sp,112
    80003e0e:	8aaa                	mv	s5,a0
    80003e10:	8bae                	mv	s7,a1
    80003e12:	8a32                	mv	s4,a2
    80003e14:	8936                	mv	s2,a3
    80003e16:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003e18:	00e687bb          	addw	a5,a3,a4
    80003e1c:	0ed7e263          	bltu	a5,a3,80003f00 <writei+0x116>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003e20:	00043737          	lui	a4,0x43
    80003e24:	0ef76063          	bltu	a4,a5,80003f04 <writei+0x11a>
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003e28:	0c0b0863          	beqz	s6,80003ef8 <writei+0x10e>
    80003e2c:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003e2e:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1)
    80003e32:	5c7d                	li	s8,-1
    80003e34:	a091                	j	80003e78 <writei+0x8e>
    80003e36:	020d1d93          	slli	s11,s10,0x20
    80003e3a:	020ddd93          	srli	s11,s11,0x20
    80003e3e:	05848513          	addi	a0,s1,88
    80003e42:	86ee                	mv	a3,s11
    80003e44:	8652                	mv	a2,s4
    80003e46:	85de                	mv	a1,s7
    80003e48:	953a                	add	a0,a0,a4
    80003e4a:	ffffe097          	auipc	ra,0xffffe
    80003e4e:	738080e7          	jalr	1848(ra) # 80002582 <either_copyin>
    80003e52:	07850263          	beq	a0,s8,80003eb6 <writei+0xcc>
    {
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e56:	8526                	mv	a0,s1
    80003e58:	00000097          	auipc	ra,0x0
    80003e5c:	788080e7          	jalr	1928(ra) # 800045e0 <log_write>
    brelse(bp);
    80003e60:	8526                	mv	a0,s1
    80003e62:	fffff097          	auipc	ra,0xfffff
    80003e66:	4f4080e7          	jalr	1268(ra) # 80003356 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003e6a:	013d09bb          	addw	s3,s10,s3
    80003e6e:	012d093b          	addw	s2,s10,s2
    80003e72:	9a6e                	add	s4,s4,s11
    80003e74:	0569f663          	bgeu	s3,s6,80003ec0 <writei+0xd6>
    uint addr = bmap(ip, off / BSIZE);
    80003e78:	00a9559b          	srliw	a1,s2,0xa
    80003e7c:	8556                	mv	a0,s5
    80003e7e:	fffff097          	auipc	ra,0xfffff
    80003e82:	79c080e7          	jalr	1948(ra) # 8000361a <bmap>
    80003e86:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003e8a:	c99d                	beqz	a1,80003ec0 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e8c:	000aa503          	lw	a0,0(s5)
    80003e90:	fffff097          	auipc	ra,0xfffff
    80003e94:	396080e7          	jalr	918(ra) # 80003226 <bread>
    80003e98:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003e9a:	3ff97713          	andi	a4,s2,1023
    80003e9e:	40ec87bb          	subw	a5,s9,a4
    80003ea2:	413b06bb          	subw	a3,s6,s3
    80003ea6:	8d3e                	mv	s10,a5
    80003ea8:	2781                	sext.w	a5,a5
    80003eaa:	0006861b          	sext.w	a2,a3
    80003eae:	f8f674e3          	bgeu	a2,a5,80003e36 <writei+0x4c>
    80003eb2:	8d36                	mv	s10,a3
    80003eb4:	b749                	j	80003e36 <writei+0x4c>
      brelse(bp);
    80003eb6:	8526                	mv	a0,s1
    80003eb8:	fffff097          	auipc	ra,0xfffff
    80003ebc:	49e080e7          	jalr	1182(ra) # 80003356 <brelse>
  }

  if (off > ip->size)
    80003ec0:	04caa783          	lw	a5,76(s5)
    80003ec4:	0127f463          	bgeu	a5,s2,80003ecc <writei+0xe2>
    ip->size = off;
    80003ec8:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ecc:	8556                	mv	a0,s5
    80003ece:	00000097          	auipc	ra,0x0
    80003ed2:	aa4080e7          	jalr	-1372(ra) # 80003972 <iupdate>

  return tot;
    80003ed6:	0009851b          	sext.w	a0,s3
}
    80003eda:	70a6                	ld	ra,104(sp)
    80003edc:	7406                	ld	s0,96(sp)
    80003ede:	64e6                	ld	s1,88(sp)
    80003ee0:	6946                	ld	s2,80(sp)
    80003ee2:	69a6                	ld	s3,72(sp)
    80003ee4:	6a06                	ld	s4,64(sp)
    80003ee6:	7ae2                	ld	s5,56(sp)
    80003ee8:	7b42                	ld	s6,48(sp)
    80003eea:	7ba2                	ld	s7,40(sp)
    80003eec:	7c02                	ld	s8,32(sp)
    80003eee:	6ce2                	ld	s9,24(sp)
    80003ef0:	6d42                	ld	s10,16(sp)
    80003ef2:	6da2                	ld	s11,8(sp)
    80003ef4:	6165                	addi	sp,sp,112
    80003ef6:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003ef8:	89da                	mv	s3,s6
    80003efa:	bfc9                	j	80003ecc <writei+0xe2>
    return -1;
    80003efc:	557d                	li	a0,-1
}
    80003efe:	8082                	ret
    return -1;
    80003f00:	557d                	li	a0,-1
    80003f02:	bfe1                	j	80003eda <writei+0xf0>
    return -1;
    80003f04:	557d                	li	a0,-1
    80003f06:	bfd1                	j	80003eda <writei+0xf0>

0000000080003f08 <namecmp>:

// Directories

int namecmp(const char *s, const char *t)
{
    80003f08:	1141                	addi	sp,sp,-16
    80003f0a:	e406                	sd	ra,8(sp)
    80003f0c:	e022                	sd	s0,0(sp)
    80003f0e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f10:	4639                	li	a2,14
    80003f12:	ffffd097          	auipc	ra,0xffffd
    80003f16:	e90080e7          	jalr	-368(ra) # 80000da2 <strncmp>
}
    80003f1a:	60a2                	ld	ra,8(sp)
    80003f1c:	6402                	ld	s0,0(sp)
    80003f1e:	0141                	addi	sp,sp,16
    80003f20:	8082                	ret

0000000080003f22 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f22:	7139                	addi	sp,sp,-64
    80003f24:	fc06                	sd	ra,56(sp)
    80003f26:	f822                	sd	s0,48(sp)
    80003f28:	f426                	sd	s1,40(sp)
    80003f2a:	f04a                	sd	s2,32(sp)
    80003f2c:	ec4e                	sd	s3,24(sp)
    80003f2e:	e852                	sd	s4,16(sp)
    80003f30:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003f32:	04451703          	lh	a4,68(a0)
    80003f36:	4785                	li	a5,1
    80003f38:	00f71a63          	bne	a4,a5,80003f4c <dirlookup+0x2a>
    80003f3c:	892a                	mv	s2,a0
    80003f3e:	89ae                	mv	s3,a1
    80003f40:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de))
    80003f42:	457c                	lw	a5,76(a0)
    80003f44:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f46:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de))
    80003f48:	e79d                	bnez	a5,80003f76 <dirlookup+0x54>
    80003f4a:	a8a5                	j	80003fc2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f4c:	00004517          	auipc	a0,0x4
    80003f50:	6c450513          	addi	a0,a0,1732 # 80008610 <syscalls+0x1b8>
    80003f54:	ffffc097          	auipc	ra,0xffffc
    80003f58:	5ec080e7          	jalr	1516(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003f5c:	00004517          	auipc	a0,0x4
    80003f60:	6cc50513          	addi	a0,a0,1740 # 80008628 <syscalls+0x1d0>
    80003f64:	ffffc097          	auipc	ra,0xffffc
    80003f68:	5dc080e7          	jalr	1500(ra) # 80000540 <panic>
  for (off = 0; off < dp->size; off += sizeof(de))
    80003f6c:	24c1                	addiw	s1,s1,16
    80003f6e:	04c92783          	lw	a5,76(s2)
    80003f72:	04f4f763          	bgeu	s1,a5,80003fc0 <dirlookup+0x9e>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f76:	4741                	li	a4,16
    80003f78:	86a6                	mv	a3,s1
    80003f7a:	fc040613          	addi	a2,s0,-64
    80003f7e:	4581                	li	a1,0
    80003f80:	854a                	mv	a0,s2
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	d70080e7          	jalr	-656(ra) # 80003cf2 <readi>
    80003f8a:	47c1                	li	a5,16
    80003f8c:	fcf518e3          	bne	a0,a5,80003f5c <dirlookup+0x3a>
    if (de.inum == 0)
    80003f90:	fc045783          	lhu	a5,-64(s0)
    80003f94:	dfe1                	beqz	a5,80003f6c <dirlookup+0x4a>
    if (namecmp(name, de.name) == 0)
    80003f96:	fc240593          	addi	a1,s0,-62
    80003f9a:	854e                	mv	a0,s3
    80003f9c:	00000097          	auipc	ra,0x0
    80003fa0:	f6c080e7          	jalr	-148(ra) # 80003f08 <namecmp>
    80003fa4:	f561                	bnez	a0,80003f6c <dirlookup+0x4a>
      if (poff)
    80003fa6:	000a0463          	beqz	s4,80003fae <dirlookup+0x8c>
        *poff = off;
    80003faa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003fae:	fc045583          	lhu	a1,-64(s0)
    80003fb2:	00092503          	lw	a0,0(s2)
    80003fb6:	fffff097          	auipc	ra,0xfffff
    80003fba:	74e080e7          	jalr	1870(ra) # 80003704 <iget>
    80003fbe:	a011                	j	80003fc2 <dirlookup+0xa0>
  return 0;
    80003fc0:	4501                	li	a0,0
}
    80003fc2:	70e2                	ld	ra,56(sp)
    80003fc4:	7442                	ld	s0,48(sp)
    80003fc6:	74a2                	ld	s1,40(sp)
    80003fc8:	7902                	ld	s2,32(sp)
    80003fca:	69e2                	ld	s3,24(sp)
    80003fcc:	6a42                	ld	s4,16(sp)
    80003fce:	6121                	addi	sp,sp,64
    80003fd0:	8082                	ret

0000000080003fd2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003fd2:	711d                	addi	sp,sp,-96
    80003fd4:	ec86                	sd	ra,88(sp)
    80003fd6:	e8a2                	sd	s0,80(sp)
    80003fd8:	e4a6                	sd	s1,72(sp)
    80003fda:	e0ca                	sd	s2,64(sp)
    80003fdc:	fc4e                	sd	s3,56(sp)
    80003fde:	f852                	sd	s4,48(sp)
    80003fe0:	f456                	sd	s5,40(sp)
    80003fe2:	f05a                	sd	s6,32(sp)
    80003fe4:	ec5e                	sd	s7,24(sp)
    80003fe6:	e862                	sd	s8,16(sp)
    80003fe8:	e466                	sd	s9,8(sp)
    80003fea:	e06a                	sd	s10,0(sp)
    80003fec:	1080                	addi	s0,sp,96
    80003fee:	84aa                	mv	s1,a0
    80003ff0:	8b2e                	mv	s6,a1
    80003ff2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003ff4:	00054703          	lbu	a4,0(a0)
    80003ff8:	02f00793          	li	a5,47
    80003ffc:	02f70363          	beq	a4,a5,80004022 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004000:	ffffe097          	auipc	ra,0xffffe
    80004004:	9ac080e7          	jalr	-1620(ra) # 800019ac <myproc>
    80004008:	15053503          	ld	a0,336(a0)
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	9f4080e7          	jalr	-1548(ra) # 80003a00 <idup>
    80004014:	8a2a                	mv	s4,a0
  while (*path == '/')
    80004016:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    8000401a:	4cb5                	li	s9,13
  len = path - s;
    8000401c:	4b81                	li	s7,0

  while ((path = skipelem(path, name)) != 0)
  {
    ilock(ip);
    if (ip->type != T_DIR)
    8000401e:	4c05                	li	s8,1
    80004020:	a87d                	j	800040de <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004022:	4585                	li	a1,1
    80004024:	4505                	li	a0,1
    80004026:	fffff097          	auipc	ra,0xfffff
    8000402a:	6de080e7          	jalr	1758(ra) # 80003704 <iget>
    8000402e:	8a2a                	mv	s4,a0
    80004030:	b7dd                	j	80004016 <namex+0x44>
    {
      iunlockput(ip);
    80004032:	8552                	mv	a0,s4
    80004034:	00000097          	auipc	ra,0x0
    80004038:	c6c080e7          	jalr	-916(ra) # 80003ca0 <iunlockput>
      return 0;
    8000403c:	4a01                	li	s4,0
  {
    iput(ip);
    return 0;
  }
  return ip;
}
    8000403e:	8552                	mv	a0,s4
    80004040:	60e6                	ld	ra,88(sp)
    80004042:	6446                	ld	s0,80(sp)
    80004044:	64a6                	ld	s1,72(sp)
    80004046:	6906                	ld	s2,64(sp)
    80004048:	79e2                	ld	s3,56(sp)
    8000404a:	7a42                	ld	s4,48(sp)
    8000404c:	7aa2                	ld	s5,40(sp)
    8000404e:	7b02                	ld	s6,32(sp)
    80004050:	6be2                	ld	s7,24(sp)
    80004052:	6c42                	ld	s8,16(sp)
    80004054:	6ca2                	ld	s9,8(sp)
    80004056:	6d02                	ld	s10,0(sp)
    80004058:	6125                	addi	sp,sp,96
    8000405a:	8082                	ret
      iunlock(ip);
    8000405c:	8552                	mv	a0,s4
    8000405e:	00000097          	auipc	ra,0x0
    80004062:	aa2080e7          	jalr	-1374(ra) # 80003b00 <iunlock>
      return ip;
    80004066:	bfe1                	j	8000403e <namex+0x6c>
      iunlockput(ip);
    80004068:	8552                	mv	a0,s4
    8000406a:	00000097          	auipc	ra,0x0
    8000406e:	c36080e7          	jalr	-970(ra) # 80003ca0 <iunlockput>
      return 0;
    80004072:	8a4e                	mv	s4,s3
    80004074:	b7e9                	j	8000403e <namex+0x6c>
  len = path - s;
    80004076:	40998633          	sub	a2,s3,s1
    8000407a:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    8000407e:	09acd863          	bge	s9,s10,8000410e <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004082:	4639                	li	a2,14
    80004084:	85a6                	mv	a1,s1
    80004086:	8556                	mv	a0,s5
    80004088:	ffffd097          	auipc	ra,0xffffd
    8000408c:	ca6080e7          	jalr	-858(ra) # 80000d2e <memmove>
    80004090:	84ce                	mv	s1,s3
  while (*path == '/')
    80004092:	0004c783          	lbu	a5,0(s1)
    80004096:	01279763          	bne	a5,s2,800040a4 <namex+0xd2>
    path++;
    8000409a:	0485                	addi	s1,s1,1
  while (*path == '/')
    8000409c:	0004c783          	lbu	a5,0(s1)
    800040a0:	ff278de3          	beq	a5,s2,8000409a <namex+0xc8>
    ilock(ip);
    800040a4:	8552                	mv	a0,s4
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	998080e7          	jalr	-1640(ra) # 80003a3e <ilock>
    if (ip->type != T_DIR)
    800040ae:	044a1783          	lh	a5,68(s4)
    800040b2:	f98790e3          	bne	a5,s8,80004032 <namex+0x60>
    if (nameiparent && *path == '\0')
    800040b6:	000b0563          	beqz	s6,800040c0 <namex+0xee>
    800040ba:	0004c783          	lbu	a5,0(s1)
    800040be:	dfd9                	beqz	a5,8000405c <namex+0x8a>
    if ((next = dirlookup(ip, name, 0)) == 0)
    800040c0:	865e                	mv	a2,s7
    800040c2:	85d6                	mv	a1,s5
    800040c4:	8552                	mv	a0,s4
    800040c6:	00000097          	auipc	ra,0x0
    800040ca:	e5c080e7          	jalr	-420(ra) # 80003f22 <dirlookup>
    800040ce:	89aa                	mv	s3,a0
    800040d0:	dd41                	beqz	a0,80004068 <namex+0x96>
    iunlockput(ip);
    800040d2:	8552                	mv	a0,s4
    800040d4:	00000097          	auipc	ra,0x0
    800040d8:	bcc080e7          	jalr	-1076(ra) # 80003ca0 <iunlockput>
    ip = next;
    800040dc:	8a4e                	mv	s4,s3
  while (*path == '/')
    800040de:	0004c783          	lbu	a5,0(s1)
    800040e2:	01279763          	bne	a5,s2,800040f0 <namex+0x11e>
    path++;
    800040e6:	0485                	addi	s1,s1,1
  while (*path == '/')
    800040e8:	0004c783          	lbu	a5,0(s1)
    800040ec:	ff278de3          	beq	a5,s2,800040e6 <namex+0x114>
  if (*path == 0)
    800040f0:	cb9d                	beqz	a5,80004126 <namex+0x154>
  while (*path != '/' && *path != 0)
    800040f2:	0004c783          	lbu	a5,0(s1)
    800040f6:	89a6                	mv	s3,s1
  len = path - s;
    800040f8:	8d5e                	mv	s10,s7
    800040fa:	865e                	mv	a2,s7
  while (*path != '/' && *path != 0)
    800040fc:	01278963          	beq	a5,s2,8000410e <namex+0x13c>
    80004100:	dbbd                	beqz	a5,80004076 <namex+0xa4>
    path++;
    80004102:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80004104:	0009c783          	lbu	a5,0(s3)
    80004108:	ff279ce3          	bne	a5,s2,80004100 <namex+0x12e>
    8000410c:	b7ad                	j	80004076 <namex+0xa4>
    memmove(name, s, len);
    8000410e:	2601                	sext.w	a2,a2
    80004110:	85a6                	mv	a1,s1
    80004112:	8556                	mv	a0,s5
    80004114:	ffffd097          	auipc	ra,0xffffd
    80004118:	c1a080e7          	jalr	-998(ra) # 80000d2e <memmove>
    name[len] = 0;
    8000411c:	9d56                	add	s10,s10,s5
    8000411e:	000d0023          	sb	zero,0(s10)
    80004122:	84ce                	mv	s1,s3
    80004124:	b7bd                	j	80004092 <namex+0xc0>
  if (nameiparent)
    80004126:	f00b0ce3          	beqz	s6,8000403e <namex+0x6c>
    iput(ip);
    8000412a:	8552                	mv	a0,s4
    8000412c:	00000097          	auipc	ra,0x0
    80004130:	acc080e7          	jalr	-1332(ra) # 80003bf8 <iput>
    return 0;
    80004134:	4a01                	li	s4,0
    80004136:	b721                	j	8000403e <namex+0x6c>

0000000080004138 <dirlink>:
{
    80004138:	7139                	addi	sp,sp,-64
    8000413a:	fc06                	sd	ra,56(sp)
    8000413c:	f822                	sd	s0,48(sp)
    8000413e:	f426                	sd	s1,40(sp)
    80004140:	f04a                	sd	s2,32(sp)
    80004142:	ec4e                	sd	s3,24(sp)
    80004144:	e852                	sd	s4,16(sp)
    80004146:	0080                	addi	s0,sp,64
    80004148:	892a                	mv	s2,a0
    8000414a:	8a2e                	mv	s4,a1
    8000414c:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0)
    8000414e:	4601                	li	a2,0
    80004150:	00000097          	auipc	ra,0x0
    80004154:	dd2080e7          	jalr	-558(ra) # 80003f22 <dirlookup>
    80004158:	e93d                	bnez	a0,800041ce <dirlink+0x96>
  for (off = 0; off < dp->size; off += sizeof(de))
    8000415a:	04c92483          	lw	s1,76(s2)
    8000415e:	c49d                	beqz	s1,8000418c <dirlink+0x54>
    80004160:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004162:	4741                	li	a4,16
    80004164:	86a6                	mv	a3,s1
    80004166:	fc040613          	addi	a2,s0,-64
    8000416a:	4581                	li	a1,0
    8000416c:	854a                	mv	a0,s2
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	b84080e7          	jalr	-1148(ra) # 80003cf2 <readi>
    80004176:	47c1                	li	a5,16
    80004178:	06f51163          	bne	a0,a5,800041da <dirlink+0xa2>
    if (de.inum == 0)
    8000417c:	fc045783          	lhu	a5,-64(s0)
    80004180:	c791                	beqz	a5,8000418c <dirlink+0x54>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004182:	24c1                	addiw	s1,s1,16
    80004184:	04c92783          	lw	a5,76(s2)
    80004188:	fcf4ede3          	bltu	s1,a5,80004162 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000418c:	4639                	li	a2,14
    8000418e:	85d2                	mv	a1,s4
    80004190:	fc240513          	addi	a0,s0,-62
    80004194:	ffffd097          	auipc	ra,0xffffd
    80004198:	c4a080e7          	jalr	-950(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000419c:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041a0:	4741                	li	a4,16
    800041a2:	86a6                	mv	a3,s1
    800041a4:	fc040613          	addi	a2,s0,-64
    800041a8:	4581                	li	a1,0
    800041aa:	854a                	mv	a0,s2
    800041ac:	00000097          	auipc	ra,0x0
    800041b0:	c3e080e7          	jalr	-962(ra) # 80003dea <writei>
    800041b4:	1541                	addi	a0,a0,-16
    800041b6:	00a03533          	snez	a0,a0
    800041ba:	40a00533          	neg	a0,a0
}
    800041be:	70e2                	ld	ra,56(sp)
    800041c0:	7442                	ld	s0,48(sp)
    800041c2:	74a2                	ld	s1,40(sp)
    800041c4:	7902                	ld	s2,32(sp)
    800041c6:	69e2                	ld	s3,24(sp)
    800041c8:	6a42                	ld	s4,16(sp)
    800041ca:	6121                	addi	sp,sp,64
    800041cc:	8082                	ret
    iput(ip);
    800041ce:	00000097          	auipc	ra,0x0
    800041d2:	a2a080e7          	jalr	-1494(ra) # 80003bf8 <iput>
    return -1;
    800041d6:	557d                	li	a0,-1
    800041d8:	b7dd                	j	800041be <dirlink+0x86>
      panic("dirlink read");
    800041da:	00004517          	auipc	a0,0x4
    800041de:	45e50513          	addi	a0,a0,1118 # 80008638 <syscalls+0x1e0>
    800041e2:	ffffc097          	auipc	ra,0xffffc
    800041e6:	35e080e7          	jalr	862(ra) # 80000540 <panic>

00000000800041ea <namei>:

struct inode *
namei(char *path)
{
    800041ea:	1101                	addi	sp,sp,-32
    800041ec:	ec06                	sd	ra,24(sp)
    800041ee:	e822                	sd	s0,16(sp)
    800041f0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041f2:	fe040613          	addi	a2,s0,-32
    800041f6:	4581                	li	a1,0
    800041f8:	00000097          	auipc	ra,0x0
    800041fc:	dda080e7          	jalr	-550(ra) # 80003fd2 <namex>
}
    80004200:	60e2                	ld	ra,24(sp)
    80004202:	6442                	ld	s0,16(sp)
    80004204:	6105                	addi	sp,sp,32
    80004206:	8082                	ret

0000000080004208 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80004208:	1141                	addi	sp,sp,-16
    8000420a:	e406                	sd	ra,8(sp)
    8000420c:	e022                	sd	s0,0(sp)
    8000420e:	0800                	addi	s0,sp,16
    80004210:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004212:	4585                	li	a1,1
    80004214:	00000097          	auipc	ra,0x0
    80004218:	dbe080e7          	jalr	-578(ra) # 80003fd2 <namex>
}
    8000421c:	60a2                	ld	ra,8(sp)
    8000421e:	6402                	ld	s0,0(sp)
    80004220:	0141                	addi	sp,sp,16
    80004222:	8082                	ret

0000000080004224 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004224:	1101                	addi	sp,sp,-32
    80004226:	ec06                	sd	ra,24(sp)
    80004228:	e822                	sd	s0,16(sp)
    8000422a:	e426                	sd	s1,8(sp)
    8000422c:	e04a                	sd	s2,0(sp)
    8000422e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004230:	0001f917          	auipc	s2,0x1f
    80004234:	95890913          	addi	s2,s2,-1704 # 80022b88 <log>
    80004238:	01892583          	lw	a1,24(s2)
    8000423c:	02892503          	lw	a0,40(s2)
    80004240:	fffff097          	auipc	ra,0xfffff
    80004244:	fe6080e7          	jalr	-26(ra) # 80003226 <bread>
    80004248:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    8000424a:	02c92683          	lw	a3,44(s2)
    8000424e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++)
    80004250:	02d05863          	blez	a3,80004280 <write_head+0x5c>
    80004254:	0001f797          	auipc	a5,0x1f
    80004258:	96478793          	addi	a5,a5,-1692 # 80022bb8 <log+0x30>
    8000425c:	05c50713          	addi	a4,a0,92
    80004260:	36fd                	addiw	a3,a3,-1
    80004262:	02069613          	slli	a2,a3,0x20
    80004266:	01e65693          	srli	a3,a2,0x1e
    8000426a:	0001f617          	auipc	a2,0x1f
    8000426e:	95260613          	addi	a2,a2,-1710 # 80022bbc <log+0x34>
    80004272:	96b2                	add	a3,a3,a2
  {
    hb->block[i] = log.lh.block[i];
    80004274:	4390                	lw	a2,0(a5)
    80004276:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    80004278:	0791                	addi	a5,a5,4
    8000427a:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000427c:	fed79ce3          	bne	a5,a3,80004274 <write_head+0x50>
  }
  bwrite(buf);
    80004280:	8526                	mv	a0,s1
    80004282:	fffff097          	auipc	ra,0xfffff
    80004286:	096080e7          	jalr	150(ra) # 80003318 <bwrite>
  brelse(buf);
    8000428a:	8526                	mv	a0,s1
    8000428c:	fffff097          	auipc	ra,0xfffff
    80004290:	0ca080e7          	jalr	202(ra) # 80003356 <brelse>
}
    80004294:	60e2                	ld	ra,24(sp)
    80004296:	6442                	ld	s0,16(sp)
    80004298:	64a2                	ld	s1,8(sp)
    8000429a:	6902                	ld	s2,0(sp)
    8000429c:	6105                	addi	sp,sp,32
    8000429e:	8082                	ret

00000000800042a0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++)
    800042a0:	0001f797          	auipc	a5,0x1f
    800042a4:	9147a783          	lw	a5,-1772(a5) # 80022bb4 <log+0x2c>
    800042a8:	0af05d63          	blez	a5,80004362 <install_trans+0xc2>
{
    800042ac:	7139                	addi	sp,sp,-64
    800042ae:	fc06                	sd	ra,56(sp)
    800042b0:	f822                	sd	s0,48(sp)
    800042b2:	f426                	sd	s1,40(sp)
    800042b4:	f04a                	sd	s2,32(sp)
    800042b6:	ec4e                	sd	s3,24(sp)
    800042b8:	e852                	sd	s4,16(sp)
    800042ba:	e456                	sd	s5,8(sp)
    800042bc:	e05a                	sd	s6,0(sp)
    800042be:	0080                	addi	s0,sp,64
    800042c0:	8b2a                	mv	s6,a0
    800042c2:	0001fa97          	auipc	s5,0x1f
    800042c6:	8f6a8a93          	addi	s5,s5,-1802 # 80022bb8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++)
    800042ca:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    800042cc:	0001f997          	auipc	s3,0x1f
    800042d0:	8bc98993          	addi	s3,s3,-1860 # 80022b88 <log>
    800042d4:	a00d                	j	800042f6 <install_trans+0x56>
    brelse(lbuf);
    800042d6:	854a                	mv	a0,s2
    800042d8:	fffff097          	auipc	ra,0xfffff
    800042dc:	07e080e7          	jalr	126(ra) # 80003356 <brelse>
    brelse(dbuf);
    800042e0:	8526                	mv	a0,s1
    800042e2:	fffff097          	auipc	ra,0xfffff
    800042e6:	074080e7          	jalr	116(ra) # 80003356 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    800042ea:	2a05                	addiw	s4,s4,1
    800042ec:	0a91                	addi	s5,s5,4
    800042ee:	02c9a783          	lw	a5,44(s3)
    800042f2:	04fa5e63          	bge	s4,a5,8000434e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    800042f6:	0189a583          	lw	a1,24(s3)
    800042fa:	014585bb          	addw	a1,a1,s4
    800042fe:	2585                	addiw	a1,a1,1
    80004300:	0289a503          	lw	a0,40(s3)
    80004304:	fffff097          	auipc	ra,0xfffff
    80004308:	f22080e7          	jalr	-222(ra) # 80003226 <bread>
    8000430c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    8000430e:	000aa583          	lw	a1,0(s5)
    80004312:	0289a503          	lw	a0,40(s3)
    80004316:	fffff097          	auipc	ra,0xfffff
    8000431a:	f10080e7          	jalr	-240(ra) # 80003226 <bread>
    8000431e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);                  // copy block to dst
    80004320:	40000613          	li	a2,1024
    80004324:	05890593          	addi	a1,s2,88
    80004328:	05850513          	addi	a0,a0,88
    8000432c:	ffffd097          	auipc	ra,0xffffd
    80004330:	a02080e7          	jalr	-1534(ra) # 80000d2e <memmove>
    bwrite(dbuf);                                            // write dst to disk
    80004334:	8526                	mv	a0,s1
    80004336:	fffff097          	auipc	ra,0xfffff
    8000433a:	fe2080e7          	jalr	-30(ra) # 80003318 <bwrite>
    if (recovering == 0)
    8000433e:	f80b1ce3          	bnez	s6,800042d6 <install_trans+0x36>
      bunpin(dbuf);
    80004342:	8526                	mv	a0,s1
    80004344:	fffff097          	auipc	ra,0xfffff
    80004348:	0ec080e7          	jalr	236(ra) # 80003430 <bunpin>
    8000434c:	b769                	j	800042d6 <install_trans+0x36>
}
    8000434e:	70e2                	ld	ra,56(sp)
    80004350:	7442                	ld	s0,48(sp)
    80004352:	74a2                	ld	s1,40(sp)
    80004354:	7902                	ld	s2,32(sp)
    80004356:	69e2                	ld	s3,24(sp)
    80004358:	6a42                	ld	s4,16(sp)
    8000435a:	6aa2                	ld	s5,8(sp)
    8000435c:	6b02                	ld	s6,0(sp)
    8000435e:	6121                	addi	sp,sp,64
    80004360:	8082                	ret
    80004362:	8082                	ret

0000000080004364 <initlog>:
{
    80004364:	7179                	addi	sp,sp,-48
    80004366:	f406                	sd	ra,40(sp)
    80004368:	f022                	sd	s0,32(sp)
    8000436a:	ec26                	sd	s1,24(sp)
    8000436c:	e84a                	sd	s2,16(sp)
    8000436e:	e44e                	sd	s3,8(sp)
    80004370:	1800                	addi	s0,sp,48
    80004372:	892a                	mv	s2,a0
    80004374:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004376:	0001f497          	auipc	s1,0x1f
    8000437a:	81248493          	addi	s1,s1,-2030 # 80022b88 <log>
    8000437e:	00004597          	auipc	a1,0x4
    80004382:	2ca58593          	addi	a1,a1,714 # 80008648 <syscalls+0x1f0>
    80004386:	8526                	mv	a0,s1
    80004388:	ffffc097          	auipc	ra,0xffffc
    8000438c:	7be080e7          	jalr	1982(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004390:	0149a583          	lw	a1,20(s3)
    80004394:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004396:	0109a783          	lw	a5,16(s3)
    8000439a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000439c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800043a0:	854a                	mv	a0,s2
    800043a2:	fffff097          	auipc	ra,0xfffff
    800043a6:	e84080e7          	jalr	-380(ra) # 80003226 <bread>
  log.lh.n = lh->n;
    800043aa:	4d34                	lw	a3,88(a0)
    800043ac:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++)
    800043ae:	02d05663          	blez	a3,800043da <initlog+0x76>
    800043b2:	05c50793          	addi	a5,a0,92
    800043b6:	0001f717          	auipc	a4,0x1f
    800043ba:	80270713          	addi	a4,a4,-2046 # 80022bb8 <log+0x30>
    800043be:	36fd                	addiw	a3,a3,-1
    800043c0:	02069613          	slli	a2,a3,0x20
    800043c4:	01e65693          	srli	a3,a2,0x1e
    800043c8:	06050613          	addi	a2,a0,96
    800043cc:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800043ce:	4390                	lw	a2,0(a5)
    800043d0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    800043d2:	0791                	addi	a5,a5,4
    800043d4:	0711                	addi	a4,a4,4
    800043d6:	fed79ce3          	bne	a5,a3,800043ce <initlog+0x6a>
  brelse(buf);
    800043da:	fffff097          	auipc	ra,0xfffff
    800043de:	f7c080e7          	jalr	-132(ra) # 80003356 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800043e2:	4505                	li	a0,1
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	ebc080e7          	jalr	-324(ra) # 800042a0 <install_trans>
  log.lh.n = 0;
    800043ec:	0001e797          	auipc	a5,0x1e
    800043f0:	7c07a423          	sw	zero,1992(a5) # 80022bb4 <log+0x2c>
  write_head(); // clear the log
    800043f4:	00000097          	auipc	ra,0x0
    800043f8:	e30080e7          	jalr	-464(ra) # 80004224 <write_head>
}
    800043fc:	70a2                	ld	ra,40(sp)
    800043fe:	7402                	ld	s0,32(sp)
    80004400:	64e2                	ld	s1,24(sp)
    80004402:	6942                	ld	s2,16(sp)
    80004404:	69a2                	ld	s3,8(sp)
    80004406:	6145                	addi	sp,sp,48
    80004408:	8082                	ret

000000008000440a <begin_op>:
}

// called at the start of each FS system call.
void begin_op(void)
{
    8000440a:	1101                	addi	sp,sp,-32
    8000440c:	ec06                	sd	ra,24(sp)
    8000440e:	e822                	sd	s0,16(sp)
    80004410:	e426                	sd	s1,8(sp)
    80004412:	e04a                	sd	s2,0(sp)
    80004414:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004416:	0001e517          	auipc	a0,0x1e
    8000441a:	77250513          	addi	a0,a0,1906 # 80022b88 <log>
    8000441e:	ffffc097          	auipc	ra,0xffffc
    80004422:	7b8080e7          	jalr	1976(ra) # 80000bd6 <acquire>
  while (1)
  {
    if (log.committing)
    80004426:	0001e497          	auipc	s1,0x1e
    8000442a:	76248493          	addi	s1,s1,1890 # 80022b88 <log>
    {
      sleep(&log, &log.lock);
    }
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    8000442e:	4979                	li	s2,30
    80004430:	a039                	j	8000443e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004432:	85a6                	mv	a1,s1
    80004434:	8526                	mv	a0,s1
    80004436:	ffffe097          	auipc	ra,0xffffe
    8000443a:	cb6080e7          	jalr	-842(ra) # 800020ec <sleep>
    if (log.committing)
    8000443e:	50dc                	lw	a5,36(s1)
    80004440:	fbed                	bnez	a5,80004432 <begin_op+0x28>
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    80004442:	5098                	lw	a4,32(s1)
    80004444:	2705                	addiw	a4,a4,1
    80004446:	0007069b          	sext.w	a3,a4
    8000444a:	0027179b          	slliw	a5,a4,0x2
    8000444e:	9fb9                	addw	a5,a5,a4
    80004450:	0017979b          	slliw	a5,a5,0x1
    80004454:	54d8                	lw	a4,44(s1)
    80004456:	9fb9                	addw	a5,a5,a4
    80004458:	00f95963          	bge	s2,a5,8000446a <begin_op+0x60>
    {
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000445c:	85a6                	mv	a1,s1
    8000445e:	8526                	mv	a0,s1
    80004460:	ffffe097          	auipc	ra,0xffffe
    80004464:	c8c080e7          	jalr	-884(ra) # 800020ec <sleep>
    80004468:	bfd9                	j	8000443e <begin_op+0x34>
    }
    else
    {
      log.outstanding += 1;
    8000446a:	0001e517          	auipc	a0,0x1e
    8000446e:	71e50513          	addi	a0,a0,1822 # 80022b88 <log>
    80004472:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004474:	ffffd097          	auipc	ra,0xffffd
    80004478:	816080e7          	jalr	-2026(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000447c:	60e2                	ld	ra,24(sp)
    8000447e:	6442                	ld	s0,16(sp)
    80004480:	64a2                	ld	s1,8(sp)
    80004482:	6902                	ld	s2,0(sp)
    80004484:	6105                	addi	sp,sp,32
    80004486:	8082                	ret

0000000080004488 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
    80004488:	7139                	addi	sp,sp,-64
    8000448a:	fc06                	sd	ra,56(sp)
    8000448c:	f822                	sd	s0,48(sp)
    8000448e:	f426                	sd	s1,40(sp)
    80004490:	f04a                	sd	s2,32(sp)
    80004492:	ec4e                	sd	s3,24(sp)
    80004494:	e852                	sd	s4,16(sp)
    80004496:	e456                	sd	s5,8(sp)
    80004498:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000449a:	0001e497          	auipc	s1,0x1e
    8000449e:	6ee48493          	addi	s1,s1,1774 # 80022b88 <log>
    800044a2:	8526                	mv	a0,s1
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	732080e7          	jalr	1842(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800044ac:	509c                	lw	a5,32(s1)
    800044ae:	37fd                	addiw	a5,a5,-1
    800044b0:	0007891b          	sext.w	s2,a5
    800044b4:	d09c                	sw	a5,32(s1)
  if (log.committing)
    800044b6:	50dc                	lw	a5,36(s1)
    800044b8:	e7b9                	bnez	a5,80004506 <end_op+0x7e>
    panic("log.committing");
  if (log.outstanding == 0)
    800044ba:	04091e63          	bnez	s2,80004516 <end_op+0x8e>
  {
    do_commit = 1;
    log.committing = 1;
    800044be:	0001e497          	auipc	s1,0x1e
    800044c2:	6ca48493          	addi	s1,s1,1738 # 80022b88 <log>
    800044c6:	4785                	li	a5,1
    800044c8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800044ca:	8526                	mv	a0,s1
    800044cc:	ffffc097          	auipc	ra,0xffffc
    800044d0:	7be080e7          	jalr	1982(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0)
    800044d4:	54dc                	lw	a5,44(s1)
    800044d6:	06f04763          	bgtz	a5,80004544 <end_op+0xbc>
    acquire(&log.lock);
    800044da:	0001e497          	auipc	s1,0x1e
    800044de:	6ae48493          	addi	s1,s1,1710 # 80022b88 <log>
    800044e2:	8526                	mv	a0,s1
    800044e4:	ffffc097          	auipc	ra,0xffffc
    800044e8:	6f2080e7          	jalr	1778(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800044ec:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800044f0:	8526                	mv	a0,s1
    800044f2:	ffffe097          	auipc	ra,0xffffe
    800044f6:	c6a080e7          	jalr	-918(ra) # 8000215c <wakeup>
    release(&log.lock);
    800044fa:	8526                	mv	a0,s1
    800044fc:	ffffc097          	auipc	ra,0xffffc
    80004500:	78e080e7          	jalr	1934(ra) # 80000c8a <release>
}
    80004504:	a03d                	j	80004532 <end_op+0xaa>
    panic("log.committing");
    80004506:	00004517          	auipc	a0,0x4
    8000450a:	14a50513          	addi	a0,a0,330 # 80008650 <syscalls+0x1f8>
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	032080e7          	jalr	50(ra) # 80000540 <panic>
    wakeup(&log);
    80004516:	0001e497          	auipc	s1,0x1e
    8000451a:	67248493          	addi	s1,s1,1650 # 80022b88 <log>
    8000451e:	8526                	mv	a0,s1
    80004520:	ffffe097          	auipc	ra,0xffffe
    80004524:	c3c080e7          	jalr	-964(ra) # 8000215c <wakeup>
  release(&log.lock);
    80004528:	8526                	mv	a0,s1
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	760080e7          	jalr	1888(ra) # 80000c8a <release>
}
    80004532:	70e2                	ld	ra,56(sp)
    80004534:	7442                	ld	s0,48(sp)
    80004536:	74a2                	ld	s1,40(sp)
    80004538:	7902                	ld	s2,32(sp)
    8000453a:	69e2                	ld	s3,24(sp)
    8000453c:	6a42                	ld	s4,16(sp)
    8000453e:	6aa2                	ld	s5,8(sp)
    80004540:	6121                	addi	sp,sp,64
    80004542:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++)
    80004544:	0001ea97          	auipc	s5,0x1e
    80004548:	674a8a93          	addi	s5,s5,1652 # 80022bb8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    8000454c:	0001ea17          	auipc	s4,0x1e
    80004550:	63ca0a13          	addi	s4,s4,1596 # 80022b88 <log>
    80004554:	018a2583          	lw	a1,24(s4)
    80004558:	012585bb          	addw	a1,a1,s2
    8000455c:	2585                	addiw	a1,a1,1
    8000455e:	028a2503          	lw	a0,40(s4)
    80004562:	fffff097          	auipc	ra,0xfffff
    80004566:	cc4080e7          	jalr	-828(ra) # 80003226 <bread>
    8000456a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000456c:	000aa583          	lw	a1,0(s5)
    80004570:	028a2503          	lw	a0,40(s4)
    80004574:	fffff097          	auipc	ra,0xfffff
    80004578:	cb2080e7          	jalr	-846(ra) # 80003226 <bread>
    8000457c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000457e:	40000613          	li	a2,1024
    80004582:	05850593          	addi	a1,a0,88
    80004586:	05848513          	addi	a0,s1,88
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	7a4080e7          	jalr	1956(ra) # 80000d2e <memmove>
    bwrite(to); // write the log
    80004592:	8526                	mv	a0,s1
    80004594:	fffff097          	auipc	ra,0xfffff
    80004598:	d84080e7          	jalr	-636(ra) # 80003318 <bwrite>
    brelse(from);
    8000459c:	854e                	mv	a0,s3
    8000459e:	fffff097          	auipc	ra,0xfffff
    800045a2:	db8080e7          	jalr	-584(ra) # 80003356 <brelse>
    brelse(to);
    800045a6:	8526                	mv	a0,s1
    800045a8:	fffff097          	auipc	ra,0xfffff
    800045ac:	dae080e7          	jalr	-594(ra) # 80003356 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    800045b0:	2905                	addiw	s2,s2,1
    800045b2:	0a91                	addi	s5,s5,4
    800045b4:	02ca2783          	lw	a5,44(s4)
    800045b8:	f8f94ee3          	blt	s2,a5,80004554 <end_op+0xcc>
  {
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    800045bc:	00000097          	auipc	ra,0x0
    800045c0:	c68080e7          	jalr	-920(ra) # 80004224 <write_head>
    install_trans(0); // Now install writes to home locations
    800045c4:	4501                	li	a0,0
    800045c6:	00000097          	auipc	ra,0x0
    800045ca:	cda080e7          	jalr	-806(ra) # 800042a0 <install_trans>
    log.lh.n = 0;
    800045ce:	0001e797          	auipc	a5,0x1e
    800045d2:	5e07a323          	sw	zero,1510(a5) # 80022bb4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    800045d6:	00000097          	auipc	ra,0x0
    800045da:	c4e080e7          	jalr	-946(ra) # 80004224 <write_head>
    800045de:	bdf5                	j	800044da <end_op+0x52>

00000000800045e0 <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
    800045e0:	1101                	addi	sp,sp,-32
    800045e2:	ec06                	sd	ra,24(sp)
    800045e4:	e822                	sd	s0,16(sp)
    800045e6:	e426                	sd	s1,8(sp)
    800045e8:	e04a                	sd	s2,0(sp)
    800045ea:	1000                	addi	s0,sp,32
    800045ec:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800045ee:	0001e917          	auipc	s2,0x1e
    800045f2:	59a90913          	addi	s2,s2,1434 # 80022b88 <log>
    800045f6:	854a                	mv	a0,s2
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	5de080e7          	jalr	1502(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004600:	02c92603          	lw	a2,44(s2)
    80004604:	47f5                	li	a5,29
    80004606:	06c7c563          	blt	a5,a2,80004670 <log_write+0x90>
    8000460a:	0001e797          	auipc	a5,0x1e
    8000460e:	59a7a783          	lw	a5,1434(a5) # 80022ba4 <log+0x1c>
    80004612:	37fd                	addiw	a5,a5,-1
    80004614:	04f65e63          	bge	a2,a5,80004670 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004618:	0001e797          	auipc	a5,0x1e
    8000461c:	5907a783          	lw	a5,1424(a5) # 80022ba8 <log+0x20>
    80004620:	06f05063          	blez	a5,80004680 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++)
    80004624:	4781                	li	a5,0
    80004626:	06c05563          	blez	a2,80004690 <log_write+0xb0>
  {
    if (log.lh.block[i] == b->blockno) // log absorption
    8000462a:	44cc                	lw	a1,12(s1)
    8000462c:	0001e717          	auipc	a4,0x1e
    80004630:	58c70713          	addi	a4,a4,1420 # 80022bb8 <log+0x30>
  for (i = 0; i < log.lh.n; i++)
    80004634:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004636:	4314                	lw	a3,0(a4)
    80004638:	04b68c63          	beq	a3,a1,80004690 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++)
    8000463c:	2785                	addiw	a5,a5,1
    8000463e:	0711                	addi	a4,a4,4
    80004640:	fef61be3          	bne	a2,a5,80004636 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004644:	0621                	addi	a2,a2,8
    80004646:	060a                	slli	a2,a2,0x2
    80004648:	0001e797          	auipc	a5,0x1e
    8000464c:	54078793          	addi	a5,a5,1344 # 80022b88 <log>
    80004650:	97b2                	add	a5,a5,a2
    80004652:	44d8                	lw	a4,12(s1)
    80004654:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n)
  { // Add new block to log?
    bpin(b);
    80004656:	8526                	mv	a0,s1
    80004658:	fffff097          	auipc	ra,0xfffff
    8000465c:	d9c080e7          	jalr	-612(ra) # 800033f4 <bpin>
    log.lh.n++;
    80004660:	0001e717          	auipc	a4,0x1e
    80004664:	52870713          	addi	a4,a4,1320 # 80022b88 <log>
    80004668:	575c                	lw	a5,44(a4)
    8000466a:	2785                	addiw	a5,a5,1
    8000466c:	d75c                	sw	a5,44(a4)
    8000466e:	a82d                	j	800046a8 <log_write+0xc8>
    panic("too big a transaction");
    80004670:	00004517          	auipc	a0,0x4
    80004674:	ff050513          	addi	a0,a0,-16 # 80008660 <syscalls+0x208>
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	ec8080e7          	jalr	-312(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004680:	00004517          	auipc	a0,0x4
    80004684:	ff850513          	addi	a0,a0,-8 # 80008678 <syscalls+0x220>
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	eb8080e7          	jalr	-328(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004690:	00878693          	addi	a3,a5,8
    80004694:	068a                	slli	a3,a3,0x2
    80004696:	0001e717          	auipc	a4,0x1e
    8000469a:	4f270713          	addi	a4,a4,1266 # 80022b88 <log>
    8000469e:	9736                	add	a4,a4,a3
    800046a0:	44d4                	lw	a3,12(s1)
    800046a2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n)
    800046a4:	faf609e3          	beq	a2,a5,80004656 <log_write+0x76>
  }
  release(&log.lock);
    800046a8:	0001e517          	auipc	a0,0x1e
    800046ac:	4e050513          	addi	a0,a0,1248 # 80022b88 <log>
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	5da080e7          	jalr	1498(ra) # 80000c8a <release>
}
    800046b8:	60e2                	ld	ra,24(sp)
    800046ba:	6442                	ld	s0,16(sp)
    800046bc:	64a2                	ld	s1,8(sp)
    800046be:	6902                	ld	s2,0(sp)
    800046c0:	6105                	addi	sp,sp,32
    800046c2:	8082                	ret

00000000800046c4 <initsleeplock>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock *lk, char *name)
{
    800046c4:	1101                	addi	sp,sp,-32
    800046c6:	ec06                	sd	ra,24(sp)
    800046c8:	e822                	sd	s0,16(sp)
    800046ca:	e426                	sd	s1,8(sp)
    800046cc:	e04a                	sd	s2,0(sp)
    800046ce:	1000                	addi	s0,sp,32
    800046d0:	84aa                	mv	s1,a0
    800046d2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800046d4:	00004597          	auipc	a1,0x4
    800046d8:	fc458593          	addi	a1,a1,-60 # 80008698 <syscalls+0x240>
    800046dc:	0521                	addi	a0,a0,8
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	468080e7          	jalr	1128(ra) # 80000b46 <initlock>
  lk->name = name;
    800046e6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800046ea:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046ee:	0204a423          	sw	zero,40(s1)
}
    800046f2:	60e2                	ld	ra,24(sp)
    800046f4:	6442                	ld	s0,16(sp)
    800046f6:	64a2                	ld	s1,8(sp)
    800046f8:	6902                	ld	s2,0(sp)
    800046fa:	6105                	addi	sp,sp,32
    800046fc:	8082                	ret

00000000800046fe <acquiresleep>:

void acquiresleep(struct sleeplock *lk)
{
    800046fe:	1101                	addi	sp,sp,-32
    80004700:	ec06                	sd	ra,24(sp)
    80004702:	e822                	sd	s0,16(sp)
    80004704:	e426                	sd	s1,8(sp)
    80004706:	e04a                	sd	s2,0(sp)
    80004708:	1000                	addi	s0,sp,32
    8000470a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000470c:	00850913          	addi	s2,a0,8
    80004710:	854a                	mv	a0,s2
    80004712:	ffffc097          	auipc	ra,0xffffc
    80004716:	4c4080e7          	jalr	1220(ra) # 80000bd6 <acquire>
  while (lk->locked)
    8000471a:	409c                	lw	a5,0(s1)
    8000471c:	cb89                	beqz	a5,8000472e <acquiresleep+0x30>
  {
    sleep(lk, &lk->lk);
    8000471e:	85ca                	mv	a1,s2
    80004720:	8526                	mv	a0,s1
    80004722:	ffffe097          	auipc	ra,0xffffe
    80004726:	9ca080e7          	jalr	-1590(ra) # 800020ec <sleep>
  while (lk->locked)
    8000472a:	409c                	lw	a5,0(s1)
    8000472c:	fbed                	bnez	a5,8000471e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000472e:	4785                	li	a5,1
    80004730:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004732:	ffffd097          	auipc	ra,0xffffd
    80004736:	27a080e7          	jalr	634(ra) # 800019ac <myproc>
    8000473a:	591c                	lw	a5,48(a0)
    8000473c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000473e:	854a                	mv	a0,s2
    80004740:	ffffc097          	auipc	ra,0xffffc
    80004744:	54a080e7          	jalr	1354(ra) # 80000c8a <release>
}
    80004748:	60e2                	ld	ra,24(sp)
    8000474a:	6442                	ld	s0,16(sp)
    8000474c:	64a2                	ld	s1,8(sp)
    8000474e:	6902                	ld	s2,0(sp)
    80004750:	6105                	addi	sp,sp,32
    80004752:	8082                	ret

0000000080004754 <releasesleep>:

void releasesleep(struct sleeplock *lk)
{
    80004754:	1101                	addi	sp,sp,-32
    80004756:	ec06                	sd	ra,24(sp)
    80004758:	e822                	sd	s0,16(sp)
    8000475a:	e426                	sd	s1,8(sp)
    8000475c:	e04a                	sd	s2,0(sp)
    8000475e:	1000                	addi	s0,sp,32
    80004760:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004762:	00850913          	addi	s2,a0,8
    80004766:	854a                	mv	a0,s2
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	46e080e7          	jalr	1134(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004770:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004774:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004778:	8526                	mv	a0,s1
    8000477a:	ffffe097          	auipc	ra,0xffffe
    8000477e:	9e2080e7          	jalr	-1566(ra) # 8000215c <wakeup>
  release(&lk->lk);
    80004782:	854a                	mv	a0,s2
    80004784:	ffffc097          	auipc	ra,0xffffc
    80004788:	506080e7          	jalr	1286(ra) # 80000c8a <release>
}
    8000478c:	60e2                	ld	ra,24(sp)
    8000478e:	6442                	ld	s0,16(sp)
    80004790:	64a2                	ld	s1,8(sp)
    80004792:	6902                	ld	s2,0(sp)
    80004794:	6105                	addi	sp,sp,32
    80004796:	8082                	ret

0000000080004798 <holdingsleep>:

int holdingsleep(struct sleeplock *lk)
{
    80004798:	7179                	addi	sp,sp,-48
    8000479a:	f406                	sd	ra,40(sp)
    8000479c:	f022                	sd	s0,32(sp)
    8000479e:	ec26                	sd	s1,24(sp)
    800047a0:	e84a                	sd	s2,16(sp)
    800047a2:	e44e                	sd	s3,8(sp)
    800047a4:	1800                	addi	s0,sp,48
    800047a6:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800047a8:	00850913          	addi	s2,a0,8
    800047ac:	854a                	mv	a0,s2
    800047ae:	ffffc097          	auipc	ra,0xffffc
    800047b2:	428080e7          	jalr	1064(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800047b6:	409c                	lw	a5,0(s1)
    800047b8:	ef99                	bnez	a5,800047d6 <holdingsleep+0x3e>
    800047ba:	4481                	li	s1,0
  release(&lk->lk);
    800047bc:	854a                	mv	a0,s2
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	4cc080e7          	jalr	1228(ra) # 80000c8a <release>
  return r;
}
    800047c6:	8526                	mv	a0,s1
    800047c8:	70a2                	ld	ra,40(sp)
    800047ca:	7402                	ld	s0,32(sp)
    800047cc:	64e2                	ld	s1,24(sp)
    800047ce:	6942                	ld	s2,16(sp)
    800047d0:	69a2                	ld	s3,8(sp)
    800047d2:	6145                	addi	sp,sp,48
    800047d4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800047d6:	0284a983          	lw	s3,40(s1)
    800047da:	ffffd097          	auipc	ra,0xffffd
    800047de:	1d2080e7          	jalr	466(ra) # 800019ac <myproc>
    800047e2:	5904                	lw	s1,48(a0)
    800047e4:	413484b3          	sub	s1,s1,s3
    800047e8:	0014b493          	seqz	s1,s1
    800047ec:	bfc1                	j	800047bc <holdingsleep+0x24>

00000000800047ee <fileinit>:
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void fileinit(void)
{
    800047ee:	1141                	addi	sp,sp,-16
    800047f0:	e406                	sd	ra,8(sp)
    800047f2:	e022                	sd	s0,0(sp)
    800047f4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047f6:	00004597          	auipc	a1,0x4
    800047fa:	eb258593          	addi	a1,a1,-334 # 800086a8 <syscalls+0x250>
    800047fe:	0001e517          	auipc	a0,0x1e
    80004802:	4d250513          	addi	a0,a0,1234 # 80022cd0 <ftable>
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	340080e7          	jalr	832(ra) # 80000b46 <initlock>
}
    8000480e:	60a2                	ld	ra,8(sp)
    80004810:	6402                	ld	s0,0(sp)
    80004812:	0141                	addi	sp,sp,16
    80004814:	8082                	ret

0000000080004816 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004816:	1101                	addi	sp,sp,-32
    80004818:	ec06                	sd	ra,24(sp)
    8000481a:	e822                	sd	s0,16(sp)
    8000481c:	e426                	sd	s1,8(sp)
    8000481e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004820:	0001e517          	auipc	a0,0x1e
    80004824:	4b050513          	addi	a0,a0,1200 # 80022cd0 <ftable>
    80004828:	ffffc097          	auipc	ra,0xffffc
    8000482c:	3ae080e7          	jalr	942(ra) # 80000bd6 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004830:	0001e497          	auipc	s1,0x1e
    80004834:	4b848493          	addi	s1,s1,1208 # 80022ce8 <ftable+0x18>
    80004838:	0001f717          	auipc	a4,0x1f
    8000483c:	45070713          	addi	a4,a4,1104 # 80023c88 <mt>
  {
    if (f->ref == 0)
    80004840:	40dc                	lw	a5,4(s1)
    80004842:	cf99                	beqz	a5,80004860 <filealloc+0x4a>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004844:	02848493          	addi	s1,s1,40
    80004848:	fee49ce3          	bne	s1,a4,80004840 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000484c:	0001e517          	auipc	a0,0x1e
    80004850:	48450513          	addi	a0,a0,1156 # 80022cd0 <ftable>
    80004854:	ffffc097          	auipc	ra,0xffffc
    80004858:	436080e7          	jalr	1078(ra) # 80000c8a <release>
  return 0;
    8000485c:	4481                	li	s1,0
    8000485e:	a819                	j	80004874 <filealloc+0x5e>
      f->ref = 1;
    80004860:	4785                	li	a5,1
    80004862:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004864:	0001e517          	auipc	a0,0x1e
    80004868:	46c50513          	addi	a0,a0,1132 # 80022cd0 <ftable>
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	41e080e7          	jalr	1054(ra) # 80000c8a <release>
}
    80004874:	8526                	mv	a0,s1
    80004876:	60e2                	ld	ra,24(sp)
    80004878:	6442                	ld	s0,16(sp)
    8000487a:	64a2                	ld	s1,8(sp)
    8000487c:	6105                	addi	sp,sp,32
    8000487e:	8082                	ret

0000000080004880 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004880:	1101                	addi	sp,sp,-32
    80004882:	ec06                	sd	ra,24(sp)
    80004884:	e822                	sd	s0,16(sp)
    80004886:	e426                	sd	s1,8(sp)
    80004888:	1000                	addi	s0,sp,32
    8000488a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000488c:	0001e517          	auipc	a0,0x1e
    80004890:	44450513          	addi	a0,a0,1092 # 80022cd0 <ftable>
    80004894:	ffffc097          	auipc	ra,0xffffc
    80004898:	342080e7          	jalr	834(ra) # 80000bd6 <acquire>
  if (f->ref < 1)
    8000489c:	40dc                	lw	a5,4(s1)
    8000489e:	02f05263          	blez	a5,800048c2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800048a2:	2785                	addiw	a5,a5,1
    800048a4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800048a6:	0001e517          	auipc	a0,0x1e
    800048aa:	42a50513          	addi	a0,a0,1066 # 80022cd0 <ftable>
    800048ae:	ffffc097          	auipc	ra,0xffffc
    800048b2:	3dc080e7          	jalr	988(ra) # 80000c8a <release>
  return f;
}
    800048b6:	8526                	mv	a0,s1
    800048b8:	60e2                	ld	ra,24(sp)
    800048ba:	6442                	ld	s0,16(sp)
    800048bc:	64a2                	ld	s1,8(sp)
    800048be:	6105                	addi	sp,sp,32
    800048c0:	8082                	ret
    panic("filedup");
    800048c2:	00004517          	auipc	a0,0x4
    800048c6:	dee50513          	addi	a0,a0,-530 # 800086b0 <syscalls+0x258>
    800048ca:	ffffc097          	auipc	ra,0xffffc
    800048ce:	c76080e7          	jalr	-906(ra) # 80000540 <panic>

00000000800048d2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    800048d2:	7139                	addi	sp,sp,-64
    800048d4:	fc06                	sd	ra,56(sp)
    800048d6:	f822                	sd	s0,48(sp)
    800048d8:	f426                	sd	s1,40(sp)
    800048da:	f04a                	sd	s2,32(sp)
    800048dc:	ec4e                	sd	s3,24(sp)
    800048de:	e852                	sd	s4,16(sp)
    800048e0:	e456                	sd	s5,8(sp)
    800048e2:	0080                	addi	s0,sp,64
    800048e4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800048e6:	0001e517          	auipc	a0,0x1e
    800048ea:	3ea50513          	addi	a0,a0,1002 # 80022cd0 <ftable>
    800048ee:	ffffc097          	auipc	ra,0xffffc
    800048f2:	2e8080e7          	jalr	744(ra) # 80000bd6 <acquire>
  if (f->ref < 1)
    800048f6:	40dc                	lw	a5,4(s1)
    800048f8:	06f05163          	blez	a5,8000495a <fileclose+0x88>
    panic("fileclose");
  if (--f->ref > 0)
    800048fc:	37fd                	addiw	a5,a5,-1
    800048fe:	0007871b          	sext.w	a4,a5
    80004902:	c0dc                	sw	a5,4(s1)
    80004904:	06e04363          	bgtz	a4,8000496a <fileclose+0x98>
  {
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004908:	0004a903          	lw	s2,0(s1)
    8000490c:	0094ca83          	lbu	s5,9(s1)
    80004910:	0104ba03          	ld	s4,16(s1)
    80004914:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004918:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000491c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004920:	0001e517          	auipc	a0,0x1e
    80004924:	3b050513          	addi	a0,a0,944 # 80022cd0 <ftable>
    80004928:	ffffc097          	auipc	ra,0xffffc
    8000492c:	362080e7          	jalr	866(ra) # 80000c8a <release>

  if (ff.type == FD_PIPE)
    80004930:	4785                	li	a5,1
    80004932:	04f90d63          	beq	s2,a5,8000498c <fileclose+0xba>
  {
    pipeclose(ff.pipe, ff.writable);
  }
  else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    80004936:	3979                	addiw	s2,s2,-2
    80004938:	4785                	li	a5,1
    8000493a:	0527e063          	bltu	a5,s2,8000497a <fileclose+0xa8>
  {
    begin_op();
    8000493e:	00000097          	auipc	ra,0x0
    80004942:	acc080e7          	jalr	-1332(ra) # 8000440a <begin_op>
    iput(ff.ip);
    80004946:	854e                	mv	a0,s3
    80004948:	fffff097          	auipc	ra,0xfffff
    8000494c:	2b0080e7          	jalr	688(ra) # 80003bf8 <iput>
    end_op();
    80004950:	00000097          	auipc	ra,0x0
    80004954:	b38080e7          	jalr	-1224(ra) # 80004488 <end_op>
    80004958:	a00d                	j	8000497a <fileclose+0xa8>
    panic("fileclose");
    8000495a:	00004517          	auipc	a0,0x4
    8000495e:	d5e50513          	addi	a0,a0,-674 # 800086b8 <syscalls+0x260>
    80004962:	ffffc097          	auipc	ra,0xffffc
    80004966:	bde080e7          	jalr	-1058(ra) # 80000540 <panic>
    release(&ftable.lock);
    8000496a:	0001e517          	auipc	a0,0x1e
    8000496e:	36650513          	addi	a0,a0,870 # 80022cd0 <ftable>
    80004972:	ffffc097          	auipc	ra,0xffffc
    80004976:	318080e7          	jalr	792(ra) # 80000c8a <release>
  }
}
    8000497a:	70e2                	ld	ra,56(sp)
    8000497c:	7442                	ld	s0,48(sp)
    8000497e:	74a2                	ld	s1,40(sp)
    80004980:	7902                	ld	s2,32(sp)
    80004982:	69e2                	ld	s3,24(sp)
    80004984:	6a42                	ld	s4,16(sp)
    80004986:	6aa2                	ld	s5,8(sp)
    80004988:	6121                	addi	sp,sp,64
    8000498a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000498c:	85d6                	mv	a1,s5
    8000498e:	8552                	mv	a0,s4
    80004990:	00000097          	auipc	ra,0x0
    80004994:	34c080e7          	jalr	844(ra) # 80004cdc <pipeclose>
    80004998:	b7cd                	j	8000497a <fileclose+0xa8>

000000008000499a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    8000499a:	715d                	addi	sp,sp,-80
    8000499c:	e486                	sd	ra,72(sp)
    8000499e:	e0a2                	sd	s0,64(sp)
    800049a0:	fc26                	sd	s1,56(sp)
    800049a2:	f84a                	sd	s2,48(sp)
    800049a4:	f44e                	sd	s3,40(sp)
    800049a6:	0880                	addi	s0,sp,80
    800049a8:	84aa                	mv	s1,a0
    800049aa:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800049ac:	ffffd097          	auipc	ra,0xffffd
    800049b0:	000080e7          	jalr	ra # 800019ac <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE)
    800049b4:	409c                	lw	a5,0(s1)
    800049b6:	37f9                	addiw	a5,a5,-2
    800049b8:	4705                	li	a4,1
    800049ba:	04f76763          	bltu	a4,a5,80004a08 <filestat+0x6e>
    800049be:	892a                	mv	s2,a0
  {
    ilock(f->ip);
    800049c0:	6c88                	ld	a0,24(s1)
    800049c2:	fffff097          	auipc	ra,0xfffff
    800049c6:	07c080e7          	jalr	124(ra) # 80003a3e <ilock>
    stati(f->ip, &st);
    800049ca:	fb840593          	addi	a1,s0,-72
    800049ce:	6c88                	ld	a0,24(s1)
    800049d0:	fffff097          	auipc	ra,0xfffff
    800049d4:	2f8080e7          	jalr	760(ra) # 80003cc8 <stati>
    iunlock(f->ip);
    800049d8:	6c88                	ld	a0,24(s1)
    800049da:	fffff097          	auipc	ra,0xfffff
    800049de:	126080e7          	jalr	294(ra) # 80003b00 <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800049e2:	46e1                	li	a3,24
    800049e4:	fb840613          	addi	a2,s0,-72
    800049e8:	85ce                	mv	a1,s3
    800049ea:	05093503          	ld	a0,80(s2)
    800049ee:	ffffd097          	auipc	ra,0xffffd
    800049f2:	c7e080e7          	jalr	-898(ra) # 8000166c <copyout>
    800049f6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800049fa:	60a6                	ld	ra,72(sp)
    800049fc:	6406                	ld	s0,64(sp)
    800049fe:	74e2                	ld	s1,56(sp)
    80004a00:	7942                	ld	s2,48(sp)
    80004a02:	79a2                	ld	s3,40(sp)
    80004a04:	6161                	addi	sp,sp,80
    80004a06:	8082                	ret
  return -1;
    80004a08:	557d                	li	a0,-1
    80004a0a:	bfc5                	j	800049fa <filestat+0x60>

0000000080004a0c <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    80004a0c:	7179                	addi	sp,sp,-48
    80004a0e:	f406                	sd	ra,40(sp)
    80004a10:	f022                	sd	s0,32(sp)
    80004a12:	ec26                	sd	s1,24(sp)
    80004a14:	e84a                	sd	s2,16(sp)
    80004a16:	e44e                	sd	s3,8(sp)
    80004a18:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    80004a1a:	00854783          	lbu	a5,8(a0)
    80004a1e:	c3d5                	beqz	a5,80004ac2 <fileread+0xb6>
    80004a20:	84aa                	mv	s1,a0
    80004a22:	89ae                	mv	s3,a1
    80004a24:	8932                	mv	s2,a2
    return -1;

  if (f->type == FD_PIPE)
    80004a26:	411c                	lw	a5,0(a0)
    80004a28:	4705                	li	a4,1
    80004a2a:	04e78963          	beq	a5,a4,80004a7c <fileread+0x70>
  {
    r = piperead(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004a2e:	470d                	li	a4,3
    80004a30:	04e78d63          	beq	a5,a4,80004a8a <fileread+0x7e>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004a34:	4709                	li	a4,2
    80004a36:	06e79e63          	bne	a5,a4,80004ab2 <fileread+0xa6>
  {
    ilock(f->ip);
    80004a3a:	6d08                	ld	a0,24(a0)
    80004a3c:	fffff097          	auipc	ra,0xfffff
    80004a40:	002080e7          	jalr	2(ra) # 80003a3e <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a44:	874a                	mv	a4,s2
    80004a46:	5094                	lw	a3,32(s1)
    80004a48:	864e                	mv	a2,s3
    80004a4a:	4585                	li	a1,1
    80004a4c:	6c88                	ld	a0,24(s1)
    80004a4e:	fffff097          	auipc	ra,0xfffff
    80004a52:	2a4080e7          	jalr	676(ra) # 80003cf2 <readi>
    80004a56:	892a                	mv	s2,a0
    80004a58:	00a05563          	blez	a0,80004a62 <fileread+0x56>
      f->off += r;
    80004a5c:	509c                	lw	a5,32(s1)
    80004a5e:	9fa9                	addw	a5,a5,a0
    80004a60:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a62:	6c88                	ld	a0,24(s1)
    80004a64:	fffff097          	auipc	ra,0xfffff
    80004a68:	09c080e7          	jalr	156(ra) # 80003b00 <iunlock>
  {
    panic("fileread");
  }

  return r;
}
    80004a6c:	854a                	mv	a0,s2
    80004a6e:	70a2                	ld	ra,40(sp)
    80004a70:	7402                	ld	s0,32(sp)
    80004a72:	64e2                	ld	s1,24(sp)
    80004a74:	6942                	ld	s2,16(sp)
    80004a76:	69a2                	ld	s3,8(sp)
    80004a78:	6145                	addi	sp,sp,48
    80004a7a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a7c:	6908                	ld	a0,16(a0)
    80004a7e:	00000097          	auipc	ra,0x0
    80004a82:	3c6080e7          	jalr	966(ra) # 80004e44 <piperead>
    80004a86:	892a                	mv	s2,a0
    80004a88:	b7d5                	j	80004a6c <fileread+0x60>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a8a:	02451783          	lh	a5,36(a0)
    80004a8e:	03079693          	slli	a3,a5,0x30
    80004a92:	92c1                	srli	a3,a3,0x30
    80004a94:	4725                	li	a4,9
    80004a96:	02d76863          	bltu	a4,a3,80004ac6 <fileread+0xba>
    80004a9a:	0792                	slli	a5,a5,0x4
    80004a9c:	0001e717          	auipc	a4,0x1e
    80004aa0:	19470713          	addi	a4,a4,404 # 80022c30 <devsw>
    80004aa4:	97ba                	add	a5,a5,a4
    80004aa6:	639c                	ld	a5,0(a5)
    80004aa8:	c38d                	beqz	a5,80004aca <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004aaa:	4505                	li	a0,1
    80004aac:	9782                	jalr	a5
    80004aae:	892a                	mv	s2,a0
    80004ab0:	bf75                	j	80004a6c <fileread+0x60>
    panic("fileread");
    80004ab2:	00004517          	auipc	a0,0x4
    80004ab6:	c1650513          	addi	a0,a0,-1002 # 800086c8 <syscalls+0x270>
    80004aba:	ffffc097          	auipc	ra,0xffffc
    80004abe:	a86080e7          	jalr	-1402(ra) # 80000540 <panic>
    return -1;
    80004ac2:	597d                	li	s2,-1
    80004ac4:	b765                	j	80004a6c <fileread+0x60>
      return -1;
    80004ac6:	597d                	li	s2,-1
    80004ac8:	b755                	j	80004a6c <fileread+0x60>
    80004aca:	597d                	li	s2,-1
    80004acc:	b745                	j	80004a6c <fileread+0x60>

0000000080004ace <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    80004ace:	715d                	addi	sp,sp,-80
    80004ad0:	e486                	sd	ra,72(sp)
    80004ad2:	e0a2                	sd	s0,64(sp)
    80004ad4:	fc26                	sd	s1,56(sp)
    80004ad6:	f84a                	sd	s2,48(sp)
    80004ad8:	f44e                	sd	s3,40(sp)
    80004ada:	f052                	sd	s4,32(sp)
    80004adc:	ec56                	sd	s5,24(sp)
    80004ade:	e85a                	sd	s6,16(sp)
    80004ae0:	e45e                	sd	s7,8(sp)
    80004ae2:	e062                	sd	s8,0(sp)
    80004ae4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if (f->writable == 0)
    80004ae6:	00954783          	lbu	a5,9(a0)
    80004aea:	10078663          	beqz	a5,80004bf6 <filewrite+0x128>
    80004aee:	892a                	mv	s2,a0
    80004af0:	8b2e                	mv	s6,a1
    80004af2:	8a32                	mv	s4,a2
    return -1;

  if (f->type == FD_PIPE)
    80004af4:	411c                	lw	a5,0(a0)
    80004af6:	4705                	li	a4,1
    80004af8:	02e78263          	beq	a5,a4,80004b1c <filewrite+0x4e>
  {
    ret = pipewrite(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004afc:	470d                	li	a4,3
    80004afe:	02e78663          	beq	a5,a4,80004b2a <filewrite+0x5c>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004b02:	4709                	li	a4,2
    80004b04:	0ee79163          	bne	a5,a4,80004be6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n)
    80004b08:	0ac05d63          	blez	a2,80004bc2 <filewrite+0xf4>
    int i = 0;
    80004b0c:	4981                	li	s3,0
    80004b0e:	6b85                	lui	s7,0x1
    80004b10:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004b14:	6c05                	lui	s8,0x1
    80004b16:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004b1a:	a861                	j	80004bb2 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004b1c:	6908                	ld	a0,16(a0)
    80004b1e:	00000097          	auipc	ra,0x0
    80004b22:	22e080e7          	jalr	558(ra) # 80004d4c <pipewrite>
    80004b26:	8a2a                	mv	s4,a0
    80004b28:	a045                	j	80004bc8 <filewrite+0xfa>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b2a:	02451783          	lh	a5,36(a0)
    80004b2e:	03079693          	slli	a3,a5,0x30
    80004b32:	92c1                	srli	a3,a3,0x30
    80004b34:	4725                	li	a4,9
    80004b36:	0cd76263          	bltu	a4,a3,80004bfa <filewrite+0x12c>
    80004b3a:	0792                	slli	a5,a5,0x4
    80004b3c:	0001e717          	auipc	a4,0x1e
    80004b40:	0f470713          	addi	a4,a4,244 # 80022c30 <devsw>
    80004b44:	97ba                	add	a5,a5,a4
    80004b46:	679c                	ld	a5,8(a5)
    80004b48:	cbdd                	beqz	a5,80004bfe <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004b4a:	4505                	li	a0,1
    80004b4c:	9782                	jalr	a5
    80004b4e:	8a2a                	mv	s4,a0
    80004b50:	a8a5                	j	80004bc8 <filewrite+0xfa>
    80004b52:	00048a9b          	sext.w	s5,s1
    {
      int n1 = n - i;
      if (n1 > max)
        n1 = max;

      begin_op();
    80004b56:	00000097          	auipc	ra,0x0
    80004b5a:	8b4080e7          	jalr	-1868(ra) # 8000440a <begin_op>
      ilock(f->ip);
    80004b5e:	01893503          	ld	a0,24(s2)
    80004b62:	fffff097          	auipc	ra,0xfffff
    80004b66:	edc080e7          	jalr	-292(ra) # 80003a3e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b6a:	8756                	mv	a4,s5
    80004b6c:	02092683          	lw	a3,32(s2)
    80004b70:	01698633          	add	a2,s3,s6
    80004b74:	4585                	li	a1,1
    80004b76:	01893503          	ld	a0,24(s2)
    80004b7a:	fffff097          	auipc	ra,0xfffff
    80004b7e:	270080e7          	jalr	624(ra) # 80003dea <writei>
    80004b82:	84aa                	mv	s1,a0
    80004b84:	00a05763          	blez	a0,80004b92 <filewrite+0xc4>
        f->off += r;
    80004b88:	02092783          	lw	a5,32(s2)
    80004b8c:	9fa9                	addw	a5,a5,a0
    80004b8e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b92:	01893503          	ld	a0,24(s2)
    80004b96:	fffff097          	auipc	ra,0xfffff
    80004b9a:	f6a080e7          	jalr	-150(ra) # 80003b00 <iunlock>
      end_op();
    80004b9e:	00000097          	auipc	ra,0x0
    80004ba2:	8ea080e7          	jalr	-1814(ra) # 80004488 <end_op>

      if (r != n1)
    80004ba6:	009a9f63          	bne	s5,s1,80004bc4 <filewrite+0xf6>
      {
        // error from writei
        break;
      }
      i += r;
    80004baa:	013489bb          	addw	s3,s1,s3
    while (i < n)
    80004bae:	0149db63          	bge	s3,s4,80004bc4 <filewrite+0xf6>
      int n1 = n - i;
    80004bb2:	413a04bb          	subw	s1,s4,s3
    80004bb6:	0004879b          	sext.w	a5,s1
    80004bba:	f8fbdce3          	bge	s7,a5,80004b52 <filewrite+0x84>
    80004bbe:	84e2                	mv	s1,s8
    80004bc0:	bf49                	j	80004b52 <filewrite+0x84>
    int i = 0;
    80004bc2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004bc4:	013a1f63          	bne	s4,s3,80004be2 <filewrite+0x114>
  {
    panic("filewrite");
  }

  return ret;
}
    80004bc8:	8552                	mv	a0,s4
    80004bca:	60a6                	ld	ra,72(sp)
    80004bcc:	6406                	ld	s0,64(sp)
    80004bce:	74e2                	ld	s1,56(sp)
    80004bd0:	7942                	ld	s2,48(sp)
    80004bd2:	79a2                	ld	s3,40(sp)
    80004bd4:	7a02                	ld	s4,32(sp)
    80004bd6:	6ae2                	ld	s5,24(sp)
    80004bd8:	6b42                	ld	s6,16(sp)
    80004bda:	6ba2                	ld	s7,8(sp)
    80004bdc:	6c02                	ld	s8,0(sp)
    80004bde:	6161                	addi	sp,sp,80
    80004be0:	8082                	ret
    ret = (i == n ? n : -1);
    80004be2:	5a7d                	li	s4,-1
    80004be4:	b7d5                	j	80004bc8 <filewrite+0xfa>
    panic("filewrite");
    80004be6:	00004517          	auipc	a0,0x4
    80004bea:	af250513          	addi	a0,a0,-1294 # 800086d8 <syscalls+0x280>
    80004bee:	ffffc097          	auipc	ra,0xffffc
    80004bf2:	952080e7          	jalr	-1710(ra) # 80000540 <panic>
    return -1;
    80004bf6:	5a7d                	li	s4,-1
    80004bf8:	bfc1                	j	80004bc8 <filewrite+0xfa>
      return -1;
    80004bfa:	5a7d                	li	s4,-1
    80004bfc:	b7f1                	j	80004bc8 <filewrite+0xfa>
    80004bfe:	5a7d                	li	s4,-1
    80004c00:	b7e1                	j	80004bc8 <filewrite+0xfa>

0000000080004c02 <pipealloc>:
  int readopen;  // read fd is still open
  int writeopen; // write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
    80004c02:	7179                	addi	sp,sp,-48
    80004c04:	f406                	sd	ra,40(sp)
    80004c06:	f022                	sd	s0,32(sp)
    80004c08:	ec26                	sd	s1,24(sp)
    80004c0a:	e84a                	sd	s2,16(sp)
    80004c0c:	e44e                	sd	s3,8(sp)
    80004c0e:	e052                	sd	s4,0(sp)
    80004c10:	1800                	addi	s0,sp,48
    80004c12:	84aa                	mv	s1,a0
    80004c14:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c16:	0005b023          	sd	zero,0(a1)
    80004c1a:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c1e:	00000097          	auipc	ra,0x0
    80004c22:	bf8080e7          	jalr	-1032(ra) # 80004816 <filealloc>
    80004c26:	e088                	sd	a0,0(s1)
    80004c28:	c551                	beqz	a0,80004cb4 <pipealloc+0xb2>
    80004c2a:	00000097          	auipc	ra,0x0
    80004c2e:	bec080e7          	jalr	-1044(ra) # 80004816 <filealloc>
    80004c32:	00aa3023          	sd	a0,0(s4)
    80004c36:	c92d                	beqz	a0,80004ca8 <pipealloc+0xa6>
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004c38:	ffffc097          	auipc	ra,0xffffc
    80004c3c:	eae080e7          	jalr	-338(ra) # 80000ae6 <kalloc>
    80004c40:	892a                	mv	s2,a0
    80004c42:	c125                	beqz	a0,80004ca2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c44:	4985                	li	s3,1
    80004c46:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c4a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c4e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c52:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c56:	00004597          	auipc	a1,0x4
    80004c5a:	a9258593          	addi	a1,a1,-1390 # 800086e8 <syscalls+0x290>
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	ee8080e7          	jalr	-280(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004c66:	609c                	ld	a5,0(s1)
    80004c68:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c6c:	609c                	ld	a5,0(s1)
    80004c6e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c72:	609c                	ld	a5,0(s1)
    80004c74:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c78:	609c                	ld	a5,0(s1)
    80004c7a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c7e:	000a3783          	ld	a5,0(s4)
    80004c82:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c86:	000a3783          	ld	a5,0(s4)
    80004c8a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c8e:	000a3783          	ld	a5,0(s4)
    80004c92:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c96:	000a3783          	ld	a5,0(s4)
    80004c9a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c9e:	4501                	li	a0,0
    80004ca0:	a025                	j	80004cc8 <pipealloc+0xc6>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004ca2:	6088                	ld	a0,0(s1)
    80004ca4:	e501                	bnez	a0,80004cac <pipealloc+0xaa>
    80004ca6:	a039                	j	80004cb4 <pipealloc+0xb2>
    80004ca8:	6088                	ld	a0,0(s1)
    80004caa:	c51d                	beqz	a0,80004cd8 <pipealloc+0xd6>
    fileclose(*f0);
    80004cac:	00000097          	auipc	ra,0x0
    80004cb0:	c26080e7          	jalr	-986(ra) # 800048d2 <fileclose>
  if (*f1)
    80004cb4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004cb8:	557d                	li	a0,-1
  if (*f1)
    80004cba:	c799                	beqz	a5,80004cc8 <pipealloc+0xc6>
    fileclose(*f1);
    80004cbc:	853e                	mv	a0,a5
    80004cbe:	00000097          	auipc	ra,0x0
    80004cc2:	c14080e7          	jalr	-1004(ra) # 800048d2 <fileclose>
  return -1;
    80004cc6:	557d                	li	a0,-1
}
    80004cc8:	70a2                	ld	ra,40(sp)
    80004cca:	7402                	ld	s0,32(sp)
    80004ccc:	64e2                	ld	s1,24(sp)
    80004cce:	6942                	ld	s2,16(sp)
    80004cd0:	69a2                	ld	s3,8(sp)
    80004cd2:	6a02                	ld	s4,0(sp)
    80004cd4:	6145                	addi	sp,sp,48
    80004cd6:	8082                	ret
  return -1;
    80004cd8:	557d                	li	a0,-1
    80004cda:	b7fd                	j	80004cc8 <pipealloc+0xc6>

0000000080004cdc <pipeclose>:

void pipeclose(struct pipe *pi, int writable)
{
    80004cdc:	1101                	addi	sp,sp,-32
    80004cde:	ec06                	sd	ra,24(sp)
    80004ce0:	e822                	sd	s0,16(sp)
    80004ce2:	e426                	sd	s1,8(sp)
    80004ce4:	e04a                	sd	s2,0(sp)
    80004ce6:	1000                	addi	s0,sp,32
    80004ce8:	84aa                	mv	s1,a0
    80004cea:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004cec:	ffffc097          	auipc	ra,0xffffc
    80004cf0:	eea080e7          	jalr	-278(ra) # 80000bd6 <acquire>
  if (writable)
    80004cf4:	02090d63          	beqz	s2,80004d2e <pipeclose+0x52>
  {
    pi->writeopen = 0;
    80004cf8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004cfc:	21848513          	addi	a0,s1,536
    80004d00:	ffffd097          	auipc	ra,0xffffd
    80004d04:	45c080e7          	jalr	1116(ra) # 8000215c <wakeup>
  else
  {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0)
    80004d08:	2204b783          	ld	a5,544(s1)
    80004d0c:	eb95                	bnez	a5,80004d40 <pipeclose+0x64>
  {
    release(&pi->lock);
    80004d0e:	8526                	mv	a0,s1
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	f7a080e7          	jalr	-134(ra) # 80000c8a <release>
    kfree((char *)pi);
    80004d18:	8526                	mv	a0,s1
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	cce080e7          	jalr	-818(ra) # 800009e8 <kfree>
  }
  else
    release(&pi->lock);
}
    80004d22:	60e2                	ld	ra,24(sp)
    80004d24:	6442                	ld	s0,16(sp)
    80004d26:	64a2                	ld	s1,8(sp)
    80004d28:	6902                	ld	s2,0(sp)
    80004d2a:	6105                	addi	sp,sp,32
    80004d2c:	8082                	ret
    pi->readopen = 0;
    80004d2e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d32:	21c48513          	addi	a0,s1,540
    80004d36:	ffffd097          	auipc	ra,0xffffd
    80004d3a:	426080e7          	jalr	1062(ra) # 8000215c <wakeup>
    80004d3e:	b7e9                	j	80004d08 <pipeclose+0x2c>
    release(&pi->lock);
    80004d40:	8526                	mv	a0,s1
    80004d42:	ffffc097          	auipc	ra,0xffffc
    80004d46:	f48080e7          	jalr	-184(ra) # 80000c8a <release>
}
    80004d4a:	bfe1                	j	80004d22 <pipeclose+0x46>

0000000080004d4c <pipewrite>:

int pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d4c:	711d                	addi	sp,sp,-96
    80004d4e:	ec86                	sd	ra,88(sp)
    80004d50:	e8a2                	sd	s0,80(sp)
    80004d52:	e4a6                	sd	s1,72(sp)
    80004d54:	e0ca                	sd	s2,64(sp)
    80004d56:	fc4e                	sd	s3,56(sp)
    80004d58:	f852                	sd	s4,48(sp)
    80004d5a:	f456                	sd	s5,40(sp)
    80004d5c:	f05a                	sd	s6,32(sp)
    80004d5e:	ec5e                	sd	s7,24(sp)
    80004d60:	e862                	sd	s8,16(sp)
    80004d62:	1080                	addi	s0,sp,96
    80004d64:	84aa                	mv	s1,a0
    80004d66:	8aae                	mv	s5,a1
    80004d68:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d6a:	ffffd097          	auipc	ra,0xffffd
    80004d6e:	c42080e7          	jalr	-958(ra) # 800019ac <myproc>
    80004d72:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d74:	8526                	mv	a0,s1
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	e60080e7          	jalr	-416(ra) # 80000bd6 <acquire>
  while (i < n)
    80004d7e:	0b405663          	blez	s4,80004e2a <pipewrite+0xde>
  int i = 0;
    80004d82:	4901                	li	s2,0
      sleep(&pi->nwrite, &pi->lock);
    }
    else
    {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d84:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d86:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d8a:	21c48b93          	addi	s7,s1,540
    80004d8e:	a089                	j	80004dd0 <pipewrite+0x84>
      release(&pi->lock);
    80004d90:	8526                	mv	a0,s1
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	ef8080e7          	jalr	-264(ra) # 80000c8a <release>
      return -1;
    80004d9a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d9c:	854a                	mv	a0,s2
    80004d9e:	60e6                	ld	ra,88(sp)
    80004da0:	6446                	ld	s0,80(sp)
    80004da2:	64a6                	ld	s1,72(sp)
    80004da4:	6906                	ld	s2,64(sp)
    80004da6:	79e2                	ld	s3,56(sp)
    80004da8:	7a42                	ld	s4,48(sp)
    80004daa:	7aa2                	ld	s5,40(sp)
    80004dac:	7b02                	ld	s6,32(sp)
    80004dae:	6be2                	ld	s7,24(sp)
    80004db0:	6c42                	ld	s8,16(sp)
    80004db2:	6125                	addi	sp,sp,96
    80004db4:	8082                	ret
      wakeup(&pi->nread);
    80004db6:	8562                	mv	a0,s8
    80004db8:	ffffd097          	auipc	ra,0xffffd
    80004dbc:	3a4080e7          	jalr	932(ra) # 8000215c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004dc0:	85a6                	mv	a1,s1
    80004dc2:	855e                	mv	a0,s7
    80004dc4:	ffffd097          	auipc	ra,0xffffd
    80004dc8:	328080e7          	jalr	808(ra) # 800020ec <sleep>
  while (i < n)
    80004dcc:	07495063          	bge	s2,s4,80004e2c <pipewrite+0xe0>
    if (pi->readopen == 0 || killed(pr))
    80004dd0:	2204a783          	lw	a5,544(s1)
    80004dd4:	dfd5                	beqz	a5,80004d90 <pipewrite+0x44>
    80004dd6:	854e                	mv	a0,s3
    80004dd8:	ffffd097          	auipc	ra,0xffffd
    80004ddc:	5f4080e7          	jalr	1524(ra) # 800023cc <killed>
    80004de0:	f945                	bnez	a0,80004d90 <pipewrite+0x44>
    if (pi->nwrite == pi->nread + PIPESIZE)
    80004de2:	2184a783          	lw	a5,536(s1)
    80004de6:	21c4a703          	lw	a4,540(s1)
    80004dea:	2007879b          	addiw	a5,a5,512
    80004dee:	fcf704e3          	beq	a4,a5,80004db6 <pipewrite+0x6a>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004df2:	4685                	li	a3,1
    80004df4:	01590633          	add	a2,s2,s5
    80004df8:	faf40593          	addi	a1,s0,-81
    80004dfc:	0509b503          	ld	a0,80(s3)
    80004e00:	ffffd097          	auipc	ra,0xffffd
    80004e04:	8f8080e7          	jalr	-1800(ra) # 800016f8 <copyin>
    80004e08:	03650263          	beq	a0,s6,80004e2c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e0c:	21c4a783          	lw	a5,540(s1)
    80004e10:	0017871b          	addiw	a4,a5,1
    80004e14:	20e4ae23          	sw	a4,540(s1)
    80004e18:	1ff7f793          	andi	a5,a5,511
    80004e1c:	97a6                	add	a5,a5,s1
    80004e1e:	faf44703          	lbu	a4,-81(s0)
    80004e22:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e26:	2905                	addiw	s2,s2,1
    80004e28:	b755                	j	80004dcc <pipewrite+0x80>
  int i = 0;
    80004e2a:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004e2c:	21848513          	addi	a0,s1,536
    80004e30:	ffffd097          	auipc	ra,0xffffd
    80004e34:	32c080e7          	jalr	812(ra) # 8000215c <wakeup>
  release(&pi->lock);
    80004e38:	8526                	mv	a0,s1
    80004e3a:	ffffc097          	auipc	ra,0xffffc
    80004e3e:	e50080e7          	jalr	-432(ra) # 80000c8a <release>
  return i;
    80004e42:	bfa9                	j	80004d9c <pipewrite+0x50>

0000000080004e44 <piperead>:

int piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e44:	715d                	addi	sp,sp,-80
    80004e46:	e486                	sd	ra,72(sp)
    80004e48:	e0a2                	sd	s0,64(sp)
    80004e4a:	fc26                	sd	s1,56(sp)
    80004e4c:	f84a                	sd	s2,48(sp)
    80004e4e:	f44e                	sd	s3,40(sp)
    80004e50:	f052                	sd	s4,32(sp)
    80004e52:	ec56                	sd	s5,24(sp)
    80004e54:	e85a                	sd	s6,16(sp)
    80004e56:	0880                	addi	s0,sp,80
    80004e58:	84aa                	mv	s1,a0
    80004e5a:	892e                	mv	s2,a1
    80004e5c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e5e:	ffffd097          	auipc	ra,0xffffd
    80004e62:	b4e080e7          	jalr	-1202(ra) # 800019ac <myproc>
    80004e66:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e68:	8526                	mv	a0,s1
    80004e6a:	ffffc097          	auipc	ra,0xffffc
    80004e6e:	d6c080e7          	jalr	-660(ra) # 80000bd6 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004e72:	2184a703          	lw	a4,536(s1)
    80004e76:	21c4a783          	lw	a5,540(s1)
    if (killed(pr))
    {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004e7a:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004e7e:	02f71763          	bne	a4,a5,80004eac <piperead+0x68>
    80004e82:	2244a783          	lw	a5,548(s1)
    80004e86:	c39d                	beqz	a5,80004eac <piperead+0x68>
    if (killed(pr))
    80004e88:	8552                	mv	a0,s4
    80004e8a:	ffffd097          	auipc	ra,0xffffd
    80004e8e:	542080e7          	jalr	1346(ra) # 800023cc <killed>
    80004e92:	e949                	bnez	a0,80004f24 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004e94:	85a6                	mv	a1,s1
    80004e96:	854e                	mv	a0,s3
    80004e98:	ffffd097          	auipc	ra,0xffffd
    80004e9c:	254080e7          	jalr	596(ra) # 800020ec <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004ea0:	2184a703          	lw	a4,536(s1)
    80004ea4:	21c4a783          	lw	a5,540(s1)
    80004ea8:	fcf70de3          	beq	a4,a5,80004e82 <piperead+0x3e>
  }
  for (i = 0; i < n; i++)
    80004eac:	4981                	li	s3,0
  { // DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004eae:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++)
    80004eb0:	05505463          	blez	s5,80004ef8 <piperead+0xb4>
    if (pi->nread == pi->nwrite)
    80004eb4:	2184a783          	lw	a5,536(s1)
    80004eb8:	21c4a703          	lw	a4,540(s1)
    80004ebc:	02f70e63          	beq	a4,a5,80004ef8 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ec0:	0017871b          	addiw	a4,a5,1
    80004ec4:	20e4ac23          	sw	a4,536(s1)
    80004ec8:	1ff7f793          	andi	a5,a5,511
    80004ecc:	97a6                	add	a5,a5,s1
    80004ece:	0187c783          	lbu	a5,24(a5)
    80004ed2:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ed6:	4685                	li	a3,1
    80004ed8:	fbf40613          	addi	a2,s0,-65
    80004edc:	85ca                	mv	a1,s2
    80004ede:	050a3503          	ld	a0,80(s4)
    80004ee2:	ffffc097          	auipc	ra,0xffffc
    80004ee6:	78a080e7          	jalr	1930(ra) # 8000166c <copyout>
    80004eea:	01650763          	beq	a0,s6,80004ef8 <piperead+0xb4>
  for (i = 0; i < n; i++)
    80004eee:	2985                	addiw	s3,s3,1
    80004ef0:	0905                	addi	s2,s2,1
    80004ef2:	fd3a91e3          	bne	s5,s3,80004eb4 <piperead+0x70>
    80004ef6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite); // DOC: piperead-wakeup
    80004ef8:	21c48513          	addi	a0,s1,540
    80004efc:	ffffd097          	auipc	ra,0xffffd
    80004f00:	260080e7          	jalr	608(ra) # 8000215c <wakeup>
  release(&pi->lock);
    80004f04:	8526                	mv	a0,s1
    80004f06:	ffffc097          	auipc	ra,0xffffc
    80004f0a:	d84080e7          	jalr	-636(ra) # 80000c8a <release>
  return i;
}
    80004f0e:	854e                	mv	a0,s3
    80004f10:	60a6                	ld	ra,72(sp)
    80004f12:	6406                	ld	s0,64(sp)
    80004f14:	74e2                	ld	s1,56(sp)
    80004f16:	7942                	ld	s2,48(sp)
    80004f18:	79a2                	ld	s3,40(sp)
    80004f1a:	7a02                	ld	s4,32(sp)
    80004f1c:	6ae2                	ld	s5,24(sp)
    80004f1e:	6b42                	ld	s6,16(sp)
    80004f20:	6161                	addi	sp,sp,80
    80004f22:	8082                	ret
      release(&pi->lock);
    80004f24:	8526                	mv	a0,s1
    80004f26:	ffffc097          	auipc	ra,0xffffc
    80004f2a:	d64080e7          	jalr	-668(ra) # 80000c8a <release>
      return -1;
    80004f2e:	59fd                	li	s3,-1
    80004f30:	bff9                	j	80004f0e <piperead+0xca>

0000000080004f32 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004f32:	1141                	addi	sp,sp,-16
    80004f34:	e422                	sd	s0,8(sp)
    80004f36:	0800                	addi	s0,sp,16
    80004f38:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004f3a:	8905                	andi	a0,a0,1
    80004f3c:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80004f3e:	8b89                	andi	a5,a5,2
    80004f40:	c399                	beqz	a5,80004f46 <flags2perm+0x14>
    perm |= PTE_W;
    80004f42:	00456513          	ori	a0,a0,4
  return perm;
}
    80004f46:	6422                	ld	s0,8(sp)
    80004f48:	0141                	addi	sp,sp,16
    80004f4a:	8082                	ret

0000000080004f4c <exec>:

int exec(char *path, char **argv)
{
    80004f4c:	de010113          	addi	sp,sp,-544
    80004f50:	20113c23          	sd	ra,536(sp)
    80004f54:	20813823          	sd	s0,528(sp)
    80004f58:	20913423          	sd	s1,520(sp)
    80004f5c:	21213023          	sd	s2,512(sp)
    80004f60:	ffce                	sd	s3,504(sp)
    80004f62:	fbd2                	sd	s4,496(sp)
    80004f64:	f7d6                	sd	s5,488(sp)
    80004f66:	f3da                	sd	s6,480(sp)
    80004f68:	efde                	sd	s7,472(sp)
    80004f6a:	ebe2                	sd	s8,464(sp)
    80004f6c:	e7e6                	sd	s9,456(sp)
    80004f6e:	e3ea                	sd	s10,448(sp)
    80004f70:	ff6e                	sd	s11,440(sp)
    80004f72:	1400                	addi	s0,sp,544
    80004f74:	892a                	mv	s2,a0
    80004f76:	dea43423          	sd	a0,-536(s0)
    80004f7a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f7e:	ffffd097          	auipc	ra,0xffffd
    80004f82:	a2e080e7          	jalr	-1490(ra) # 800019ac <myproc>
    80004f86:	84aa                	mv	s1,a0

  begin_op();
    80004f88:	fffff097          	auipc	ra,0xfffff
    80004f8c:	482080e7          	jalr	1154(ra) # 8000440a <begin_op>

  if ((ip = namei(path)) == 0)
    80004f90:	854a                	mv	a0,s2
    80004f92:	fffff097          	auipc	ra,0xfffff
    80004f96:	258080e7          	jalr	600(ra) # 800041ea <namei>
    80004f9a:	c93d                	beqz	a0,80005010 <exec+0xc4>
    80004f9c:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80004f9e:	fffff097          	auipc	ra,0xfffff
    80004fa2:	aa0080e7          	jalr	-1376(ra) # 80003a3e <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004fa6:	04000713          	li	a4,64
    80004faa:	4681                	li	a3,0
    80004fac:	e5040613          	addi	a2,s0,-432
    80004fb0:	4581                	li	a1,0
    80004fb2:	8556                	mv	a0,s5
    80004fb4:	fffff097          	auipc	ra,0xfffff
    80004fb8:	d3e080e7          	jalr	-706(ra) # 80003cf2 <readi>
    80004fbc:	04000793          	li	a5,64
    80004fc0:	00f51a63          	bne	a0,a5,80004fd4 <exec+0x88>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    80004fc4:	e5042703          	lw	a4,-432(s0)
    80004fc8:	464c47b7          	lui	a5,0x464c4
    80004fcc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004fd0:	04f70663          	beq	a4,a5,8000501c <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80004fd4:	8556                	mv	a0,s5
    80004fd6:	fffff097          	auipc	ra,0xfffff
    80004fda:	cca080e7          	jalr	-822(ra) # 80003ca0 <iunlockput>
    end_op();
    80004fde:	fffff097          	auipc	ra,0xfffff
    80004fe2:	4aa080e7          	jalr	1194(ra) # 80004488 <end_op>
  }
  return -1;
    80004fe6:	557d                	li	a0,-1
}
    80004fe8:	21813083          	ld	ra,536(sp)
    80004fec:	21013403          	ld	s0,528(sp)
    80004ff0:	20813483          	ld	s1,520(sp)
    80004ff4:	20013903          	ld	s2,512(sp)
    80004ff8:	79fe                	ld	s3,504(sp)
    80004ffa:	7a5e                	ld	s4,496(sp)
    80004ffc:	7abe                	ld	s5,488(sp)
    80004ffe:	7b1e                	ld	s6,480(sp)
    80005000:	6bfe                	ld	s7,472(sp)
    80005002:	6c5e                	ld	s8,464(sp)
    80005004:	6cbe                	ld	s9,456(sp)
    80005006:	6d1e                	ld	s10,448(sp)
    80005008:	7dfa                	ld	s11,440(sp)
    8000500a:	22010113          	addi	sp,sp,544
    8000500e:	8082                	ret
    end_op();
    80005010:	fffff097          	auipc	ra,0xfffff
    80005014:	478080e7          	jalr	1144(ra) # 80004488 <end_op>
    return -1;
    80005018:	557d                	li	a0,-1
    8000501a:	b7f9                	j	80004fe8 <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    8000501c:	8526                	mv	a0,s1
    8000501e:	ffffd097          	auipc	ra,0xffffd
    80005022:	a52080e7          	jalr	-1454(ra) # 80001a70 <proc_pagetable>
    80005026:	8b2a                	mv	s6,a0
    80005028:	d555                	beqz	a0,80004fd4 <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    8000502a:	e7042783          	lw	a5,-400(s0)
    8000502e:	e8845703          	lhu	a4,-376(s0)
    80005032:	c735                	beqz	a4,8000509e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005034:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005036:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    8000503a:	6a05                	lui	s4,0x1
    8000503c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005040:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for (i = 0; i < sz; i += PGSIZE)
    80005044:	6d85                	lui	s11,0x1
    80005046:	7d7d                	lui	s10,0xfffff
    80005048:	ac3d                	j	80005286 <exec+0x33a>
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    8000504a:	00003517          	auipc	a0,0x3
    8000504e:	6a650513          	addi	a0,a0,1702 # 800086f0 <syscalls+0x298>
    80005052:	ffffb097          	auipc	ra,0xffffb
    80005056:	4ee080e7          	jalr	1262(ra) # 80000540 <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    8000505a:	874a                	mv	a4,s2
    8000505c:	009c86bb          	addw	a3,s9,s1
    80005060:	4581                	li	a1,0
    80005062:	8556                	mv	a0,s5
    80005064:	fffff097          	auipc	ra,0xfffff
    80005068:	c8e080e7          	jalr	-882(ra) # 80003cf2 <readi>
    8000506c:	2501                	sext.w	a0,a0
    8000506e:	1aa91963          	bne	s2,a0,80005220 <exec+0x2d4>
  for (i = 0; i < sz; i += PGSIZE)
    80005072:	009d84bb          	addw	s1,s11,s1
    80005076:	013d09bb          	addw	s3,s10,s3
    8000507a:	1f74f663          	bgeu	s1,s7,80005266 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    8000507e:	02049593          	slli	a1,s1,0x20
    80005082:	9181                	srli	a1,a1,0x20
    80005084:	95e2                	add	a1,a1,s8
    80005086:	855a                	mv	a0,s6
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	fd4080e7          	jalr	-44(ra) # 8000105c <walkaddr>
    80005090:	862a                	mv	a2,a0
    if (pa == 0)
    80005092:	dd45                	beqz	a0,8000504a <exec+0xfe>
      n = PGSIZE;
    80005094:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005096:	fd49f2e3          	bgeu	s3,s4,8000505a <exec+0x10e>
      n = sz - i;
    8000509a:	894e                	mv	s2,s3
    8000509c:	bf7d                	j	8000505a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000509e:	4901                	li	s2,0
  iunlockput(ip);
    800050a0:	8556                	mv	a0,s5
    800050a2:	fffff097          	auipc	ra,0xfffff
    800050a6:	bfe080e7          	jalr	-1026(ra) # 80003ca0 <iunlockput>
  end_op();
    800050aa:	fffff097          	auipc	ra,0xfffff
    800050ae:	3de080e7          	jalr	990(ra) # 80004488 <end_op>
  p = myproc();
    800050b2:	ffffd097          	auipc	ra,0xffffd
    800050b6:	8fa080e7          	jalr	-1798(ra) # 800019ac <myproc>
    800050ba:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800050bc:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800050c0:	6785                	lui	a5,0x1
    800050c2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800050c4:	97ca                	add	a5,a5,s2
    800050c6:	777d                	lui	a4,0xfffff
    800050c8:	8ff9                	and	a5,a5,a4
    800050ca:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    800050ce:	4691                	li	a3,4
    800050d0:	6609                	lui	a2,0x2
    800050d2:	963e                	add	a2,a2,a5
    800050d4:	85be                	mv	a1,a5
    800050d6:	855a                	mv	a0,s6
    800050d8:	ffffc097          	auipc	ra,0xffffc
    800050dc:	338080e7          	jalr	824(ra) # 80001410 <uvmalloc>
    800050e0:	8c2a                	mv	s8,a0
  ip = 0;
    800050e2:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    800050e4:	12050e63          	beqz	a0,80005220 <exec+0x2d4>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    800050e8:	75f9                	lui	a1,0xffffe
    800050ea:	95aa                	add	a1,a1,a0
    800050ec:	855a                	mv	a0,s6
    800050ee:	ffffc097          	auipc	ra,0xffffc
    800050f2:	54c080e7          	jalr	1356(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    800050f6:	7afd                	lui	s5,0xfffff
    800050f8:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    800050fa:	df043783          	ld	a5,-528(s0)
    800050fe:	6388                	ld	a0,0(a5)
    80005100:	c925                	beqz	a0,80005170 <exec+0x224>
    80005102:	e9040993          	addi	s3,s0,-368
    80005106:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000510a:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    8000510c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000510e:	ffffc097          	auipc	ra,0xffffc
    80005112:	d40080e7          	jalr	-704(ra) # 80000e4e <strlen>
    80005116:	0015079b          	addiw	a5,a0,1
    8000511a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000511e:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    80005122:	13596663          	bltu	s2,s5,8000524e <exec+0x302>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005126:	df043d83          	ld	s11,-528(s0)
    8000512a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000512e:	8552                	mv	a0,s4
    80005130:	ffffc097          	auipc	ra,0xffffc
    80005134:	d1e080e7          	jalr	-738(ra) # 80000e4e <strlen>
    80005138:	0015069b          	addiw	a3,a0,1
    8000513c:	8652                	mv	a2,s4
    8000513e:	85ca                	mv	a1,s2
    80005140:	855a                	mv	a0,s6
    80005142:	ffffc097          	auipc	ra,0xffffc
    80005146:	52a080e7          	jalr	1322(ra) # 8000166c <copyout>
    8000514a:	10054663          	bltz	a0,80005256 <exec+0x30a>
    ustack[argc] = sp;
    8000514e:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    80005152:	0485                	addi	s1,s1,1
    80005154:	008d8793          	addi	a5,s11,8
    80005158:	def43823          	sd	a5,-528(s0)
    8000515c:	008db503          	ld	a0,8(s11)
    80005160:	c911                	beqz	a0,80005174 <exec+0x228>
    if (argc >= MAXARG)
    80005162:	09a1                	addi	s3,s3,8
    80005164:	fb3c95e3          	bne	s9,s3,8000510e <exec+0x1c2>
  sz = sz1;
    80005168:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000516c:	4a81                	li	s5,0
    8000516e:	a84d                	j	80005220 <exec+0x2d4>
  sp = sz;
    80005170:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005172:	4481                	li	s1,0
  ustack[argc] = 0;
    80005174:	00349793          	slli	a5,s1,0x3
    80005178:	f9078793          	addi	a5,a5,-112
    8000517c:	97a2                	add	a5,a5,s0
    8000517e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80005182:	00148693          	addi	a3,s1,1
    80005186:	068e                	slli	a3,a3,0x3
    80005188:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000518c:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    80005190:	01597663          	bgeu	s2,s5,8000519c <exec+0x250>
  sz = sz1;
    80005194:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005198:	4a81                	li	s5,0
    8000519a:	a059                	j	80005220 <exec+0x2d4>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    8000519c:	e9040613          	addi	a2,s0,-368
    800051a0:	85ca                	mv	a1,s2
    800051a2:	855a                	mv	a0,s6
    800051a4:	ffffc097          	auipc	ra,0xffffc
    800051a8:	4c8080e7          	jalr	1224(ra) # 8000166c <copyout>
    800051ac:	0a054963          	bltz	a0,8000525e <exec+0x312>
  p->trapframe->a1 = sp;
    800051b0:	058bb783          	ld	a5,88(s7)
    800051b4:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    800051b8:	de843783          	ld	a5,-536(s0)
    800051bc:	0007c703          	lbu	a4,0(a5)
    800051c0:	cf11                	beqz	a4,800051dc <exec+0x290>
    800051c2:	0785                	addi	a5,a5,1
    if (*s == '/')
    800051c4:	02f00693          	li	a3,47
    800051c8:	a039                	j	800051d6 <exec+0x28a>
      last = s + 1;
    800051ca:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    800051ce:	0785                	addi	a5,a5,1
    800051d0:	fff7c703          	lbu	a4,-1(a5)
    800051d4:	c701                	beqz	a4,800051dc <exec+0x290>
    if (*s == '/')
    800051d6:	fed71ce3          	bne	a4,a3,800051ce <exec+0x282>
    800051da:	bfc5                	j	800051ca <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800051dc:	4641                	li	a2,16
    800051de:	de843583          	ld	a1,-536(s0)
    800051e2:	158b8513          	addi	a0,s7,344
    800051e6:	ffffc097          	auipc	ra,0xffffc
    800051ea:	c36080e7          	jalr	-970(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800051ee:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800051f2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800051f6:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    800051fa:	058bb783          	ld	a5,88(s7)
    800051fe:	e6843703          	ld	a4,-408(s0)
    80005202:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005204:	058bb783          	ld	a5,88(s7)
    80005208:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000520c:	85ea                	mv	a1,s10
    8000520e:	ffffd097          	auipc	ra,0xffffd
    80005212:	8fe080e7          	jalr	-1794(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005216:	0004851b          	sext.w	a0,s1
    8000521a:	b3f9                	j	80004fe8 <exec+0x9c>
    8000521c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005220:	df843583          	ld	a1,-520(s0)
    80005224:	855a                	mv	a0,s6
    80005226:	ffffd097          	auipc	ra,0xffffd
    8000522a:	8e6080e7          	jalr	-1818(ra) # 80001b0c <proc_freepagetable>
  if (ip)
    8000522e:	da0a93e3          	bnez	s5,80004fd4 <exec+0x88>
  return -1;
    80005232:	557d                	li	a0,-1
    80005234:	bb55                	j	80004fe8 <exec+0x9c>
    80005236:	df243c23          	sd	s2,-520(s0)
    8000523a:	b7dd                	j	80005220 <exec+0x2d4>
    8000523c:	df243c23          	sd	s2,-520(s0)
    80005240:	b7c5                	j	80005220 <exec+0x2d4>
    80005242:	df243c23          	sd	s2,-520(s0)
    80005246:	bfe9                	j	80005220 <exec+0x2d4>
    80005248:	df243c23          	sd	s2,-520(s0)
    8000524c:	bfd1                	j	80005220 <exec+0x2d4>
  sz = sz1;
    8000524e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005252:	4a81                	li	s5,0
    80005254:	b7f1                	j	80005220 <exec+0x2d4>
  sz = sz1;
    80005256:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000525a:	4a81                	li	s5,0
    8000525c:	b7d1                	j	80005220 <exec+0x2d4>
  sz = sz1;
    8000525e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005262:	4a81                	li	s5,0
    80005264:	bf75                	j	80005220 <exec+0x2d4>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005266:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    8000526a:	e0843783          	ld	a5,-504(s0)
    8000526e:	0017869b          	addiw	a3,a5,1
    80005272:	e0d43423          	sd	a3,-504(s0)
    80005276:	e0043783          	ld	a5,-512(s0)
    8000527a:	0387879b          	addiw	a5,a5,56
    8000527e:	e8845703          	lhu	a4,-376(s0)
    80005282:	e0e6dfe3          	bge	a3,a4,800050a0 <exec+0x154>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005286:	2781                	sext.w	a5,a5
    80005288:	e0f43023          	sd	a5,-512(s0)
    8000528c:	03800713          	li	a4,56
    80005290:	86be                	mv	a3,a5
    80005292:	e1840613          	addi	a2,s0,-488
    80005296:	4581                	li	a1,0
    80005298:	8556                	mv	a0,s5
    8000529a:	fffff097          	auipc	ra,0xfffff
    8000529e:	a58080e7          	jalr	-1448(ra) # 80003cf2 <readi>
    800052a2:	03800793          	li	a5,56
    800052a6:	f6f51be3          	bne	a0,a5,8000521c <exec+0x2d0>
    if (ph.type != ELF_PROG_LOAD)
    800052aa:	e1842783          	lw	a5,-488(s0)
    800052ae:	4705                	li	a4,1
    800052b0:	fae79de3          	bne	a5,a4,8000526a <exec+0x31e>
    if (ph.memsz < ph.filesz)
    800052b4:	e4043483          	ld	s1,-448(s0)
    800052b8:	e3843783          	ld	a5,-456(s0)
    800052bc:	f6f4ede3          	bltu	s1,a5,80005236 <exec+0x2ea>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    800052c0:	e2843783          	ld	a5,-472(s0)
    800052c4:	94be                	add	s1,s1,a5
    800052c6:	f6f4ebe3          	bltu	s1,a5,8000523c <exec+0x2f0>
    if (ph.vaddr % PGSIZE != 0)
    800052ca:	de043703          	ld	a4,-544(s0)
    800052ce:	8ff9                	and	a5,a5,a4
    800052d0:	fbad                	bnez	a5,80005242 <exec+0x2f6>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800052d2:	e1c42503          	lw	a0,-484(s0)
    800052d6:	00000097          	auipc	ra,0x0
    800052da:	c5c080e7          	jalr	-932(ra) # 80004f32 <flags2perm>
    800052de:	86aa                	mv	a3,a0
    800052e0:	8626                	mv	a2,s1
    800052e2:	85ca                	mv	a1,s2
    800052e4:	855a                	mv	a0,s6
    800052e6:	ffffc097          	auipc	ra,0xffffc
    800052ea:	12a080e7          	jalr	298(ra) # 80001410 <uvmalloc>
    800052ee:	dea43c23          	sd	a0,-520(s0)
    800052f2:	d939                	beqz	a0,80005248 <exec+0x2fc>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052f4:	e2843c03          	ld	s8,-472(s0)
    800052f8:	e2042c83          	lw	s9,-480(s0)
    800052fc:	e3842b83          	lw	s7,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    80005300:	f60b83e3          	beqz	s7,80005266 <exec+0x31a>
    80005304:	89de                	mv	s3,s7
    80005306:	4481                	li	s1,0
    80005308:	bb9d                	j	8000507e <exec+0x132>

000000008000530a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000530a:	7179                	addi	sp,sp,-48
    8000530c:	f406                	sd	ra,40(sp)
    8000530e:	f022                	sd	s0,32(sp)
    80005310:	ec26                	sd	s1,24(sp)
    80005312:	e84a                	sd	s2,16(sp)
    80005314:	1800                	addi	s0,sp,48
    80005316:	892e                	mv	s2,a1
    80005318:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000531a:	fdc40593          	addi	a1,s0,-36
    8000531e:	ffffe097          	auipc	ra,0xffffe
    80005322:	a7c080e7          	jalr	-1412(ra) # 80002d9a <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80005326:	fdc42703          	lw	a4,-36(s0)
    8000532a:	47bd                	li	a5,15
    8000532c:	02e7eb63          	bltu	a5,a4,80005362 <argfd+0x58>
    80005330:	ffffc097          	auipc	ra,0xffffc
    80005334:	67c080e7          	jalr	1660(ra) # 800019ac <myproc>
    80005338:	fdc42703          	lw	a4,-36(s0)
    8000533c:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd9ed2>
    80005340:	078e                	slli	a5,a5,0x3
    80005342:	953e                	add	a0,a0,a5
    80005344:	611c                	ld	a5,0(a0)
    80005346:	c385                	beqz	a5,80005366 <argfd+0x5c>
    return -1;
  if (pfd)
    80005348:	00090463          	beqz	s2,80005350 <argfd+0x46>
    *pfd = fd;
    8000534c:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80005350:	4501                	li	a0,0
  if (pf)
    80005352:	c091                	beqz	s1,80005356 <argfd+0x4c>
    *pf = f;
    80005354:	e09c                	sd	a5,0(s1)
}
    80005356:	70a2                	ld	ra,40(sp)
    80005358:	7402                	ld	s0,32(sp)
    8000535a:	64e2                	ld	s1,24(sp)
    8000535c:	6942                	ld	s2,16(sp)
    8000535e:	6145                	addi	sp,sp,48
    80005360:	8082                	ret
    return -1;
    80005362:	557d                	li	a0,-1
    80005364:	bfcd                	j	80005356 <argfd+0x4c>
    80005366:	557d                	li	a0,-1
    80005368:	b7fd                	j	80005356 <argfd+0x4c>

000000008000536a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000536a:	1101                	addi	sp,sp,-32
    8000536c:	ec06                	sd	ra,24(sp)
    8000536e:	e822                	sd	s0,16(sp)
    80005370:	e426                	sd	s1,8(sp)
    80005372:	1000                	addi	s0,sp,32
    80005374:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005376:	ffffc097          	auipc	ra,0xffffc
    8000537a:	636080e7          	jalr	1590(ra) # 800019ac <myproc>
    8000537e:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++)
    80005380:	0d050793          	addi	a5,a0,208
    80005384:	4501                	li	a0,0
    80005386:	46c1                	li	a3,16
  {
    if (p->ofile[fd] == 0)
    80005388:	6398                	ld	a4,0(a5)
    8000538a:	cb19                	beqz	a4,800053a0 <fdalloc+0x36>
  for (fd = 0; fd < NOFILE; fd++)
    8000538c:	2505                	addiw	a0,a0,1
    8000538e:	07a1                	addi	a5,a5,8
    80005390:	fed51ce3          	bne	a0,a3,80005388 <fdalloc+0x1e>
    {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005394:	557d                	li	a0,-1
}
    80005396:	60e2                	ld	ra,24(sp)
    80005398:	6442                	ld	s0,16(sp)
    8000539a:	64a2                	ld	s1,8(sp)
    8000539c:	6105                	addi	sp,sp,32
    8000539e:	8082                	ret
      p->ofile[fd] = f;
    800053a0:	01a50793          	addi	a5,a0,26
    800053a4:	078e                	slli	a5,a5,0x3
    800053a6:	963e                	add	a2,a2,a5
    800053a8:	e204                	sd	s1,0(a2)
      return fd;
    800053aa:	b7f5                	j	80005396 <fdalloc+0x2c>

00000000800053ac <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    800053ac:	715d                	addi	sp,sp,-80
    800053ae:	e486                	sd	ra,72(sp)
    800053b0:	e0a2                	sd	s0,64(sp)
    800053b2:	fc26                	sd	s1,56(sp)
    800053b4:	f84a                	sd	s2,48(sp)
    800053b6:	f44e                	sd	s3,40(sp)
    800053b8:	f052                	sd	s4,32(sp)
    800053ba:	ec56                	sd	s5,24(sp)
    800053bc:	e85a                	sd	s6,16(sp)
    800053be:	0880                	addi	s0,sp,80
    800053c0:	8b2e                	mv	s6,a1
    800053c2:	89b2                	mv	s3,a2
    800053c4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    800053c6:	fb040593          	addi	a1,s0,-80
    800053ca:	fffff097          	auipc	ra,0xfffff
    800053ce:	e3e080e7          	jalr	-450(ra) # 80004208 <nameiparent>
    800053d2:	84aa                	mv	s1,a0
    800053d4:	14050f63          	beqz	a0,80005532 <create+0x186>
    return 0;

  ilock(dp);
    800053d8:	ffffe097          	auipc	ra,0xffffe
    800053dc:	666080e7          	jalr	1638(ra) # 80003a3e <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0)
    800053e0:	4601                	li	a2,0
    800053e2:	fb040593          	addi	a1,s0,-80
    800053e6:	8526                	mv	a0,s1
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	b3a080e7          	jalr	-1222(ra) # 80003f22 <dirlookup>
    800053f0:	8aaa                	mv	s5,a0
    800053f2:	c931                	beqz	a0,80005446 <create+0x9a>
  {
    iunlockput(dp);
    800053f4:	8526                	mv	a0,s1
    800053f6:	fffff097          	auipc	ra,0xfffff
    800053fa:	8aa080e7          	jalr	-1878(ra) # 80003ca0 <iunlockput>
    ilock(ip);
    800053fe:	8556                	mv	a0,s5
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	63e080e7          	jalr	1598(ra) # 80003a3e <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005408:	000b059b          	sext.w	a1,s6
    8000540c:	4789                	li	a5,2
    8000540e:	02f59563          	bne	a1,a5,80005438 <create+0x8c>
    80005412:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffd9efc>
    80005416:	37f9                	addiw	a5,a5,-2
    80005418:	17c2                	slli	a5,a5,0x30
    8000541a:	93c1                	srli	a5,a5,0x30
    8000541c:	4705                	li	a4,1
    8000541e:	00f76d63          	bltu	a4,a5,80005438 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005422:	8556                	mv	a0,s5
    80005424:	60a6                	ld	ra,72(sp)
    80005426:	6406                	ld	s0,64(sp)
    80005428:	74e2                	ld	s1,56(sp)
    8000542a:	7942                	ld	s2,48(sp)
    8000542c:	79a2                	ld	s3,40(sp)
    8000542e:	7a02                	ld	s4,32(sp)
    80005430:	6ae2                	ld	s5,24(sp)
    80005432:	6b42                	ld	s6,16(sp)
    80005434:	6161                	addi	sp,sp,80
    80005436:	8082                	ret
    iunlockput(ip);
    80005438:	8556                	mv	a0,s5
    8000543a:	fffff097          	auipc	ra,0xfffff
    8000543e:	866080e7          	jalr	-1946(ra) # 80003ca0 <iunlockput>
    return 0;
    80005442:	4a81                	li	s5,0
    80005444:	bff9                	j	80005422 <create+0x76>
  if ((ip = ialloc(dp->dev, type)) == 0)
    80005446:	85da                	mv	a1,s6
    80005448:	4088                	lw	a0,0(s1)
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	456080e7          	jalr	1110(ra) # 800038a0 <ialloc>
    80005452:	8a2a                	mv	s4,a0
    80005454:	c539                	beqz	a0,800054a2 <create+0xf6>
  ilock(ip);
    80005456:	ffffe097          	auipc	ra,0xffffe
    8000545a:	5e8080e7          	jalr	1512(ra) # 80003a3e <ilock>
  ip->major = major;
    8000545e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005462:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005466:	4905                	li	s2,1
    80005468:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000546c:	8552                	mv	a0,s4
    8000546e:	ffffe097          	auipc	ra,0xffffe
    80005472:	504080e7          	jalr	1284(ra) # 80003972 <iupdate>
  if (type == T_DIR)
    80005476:	000b059b          	sext.w	a1,s6
    8000547a:	03258b63          	beq	a1,s2,800054b0 <create+0x104>
  if (dirlink(dp, name, ip->inum) < 0)
    8000547e:	004a2603          	lw	a2,4(s4)
    80005482:	fb040593          	addi	a1,s0,-80
    80005486:	8526                	mv	a0,s1
    80005488:	fffff097          	auipc	ra,0xfffff
    8000548c:	cb0080e7          	jalr	-848(ra) # 80004138 <dirlink>
    80005490:	06054f63          	bltz	a0,8000550e <create+0x162>
  iunlockput(dp);
    80005494:	8526                	mv	a0,s1
    80005496:	fffff097          	auipc	ra,0xfffff
    8000549a:	80a080e7          	jalr	-2038(ra) # 80003ca0 <iunlockput>
  return ip;
    8000549e:	8ad2                	mv	s5,s4
    800054a0:	b749                	j	80005422 <create+0x76>
    iunlockput(dp);
    800054a2:	8526                	mv	a0,s1
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	7fc080e7          	jalr	2044(ra) # 80003ca0 <iunlockput>
    return 0;
    800054ac:	8ad2                	mv	s5,s4
    800054ae:	bf95                	j	80005422 <create+0x76>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054b0:	004a2603          	lw	a2,4(s4)
    800054b4:	00003597          	auipc	a1,0x3
    800054b8:	25c58593          	addi	a1,a1,604 # 80008710 <syscalls+0x2b8>
    800054bc:	8552                	mv	a0,s4
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	c7a080e7          	jalr	-902(ra) # 80004138 <dirlink>
    800054c6:	04054463          	bltz	a0,8000550e <create+0x162>
    800054ca:	40d0                	lw	a2,4(s1)
    800054cc:	00003597          	auipc	a1,0x3
    800054d0:	24c58593          	addi	a1,a1,588 # 80008718 <syscalls+0x2c0>
    800054d4:	8552                	mv	a0,s4
    800054d6:	fffff097          	auipc	ra,0xfffff
    800054da:	c62080e7          	jalr	-926(ra) # 80004138 <dirlink>
    800054de:	02054863          	bltz	a0,8000550e <create+0x162>
  if (dirlink(dp, name, ip->inum) < 0)
    800054e2:	004a2603          	lw	a2,4(s4)
    800054e6:	fb040593          	addi	a1,s0,-80
    800054ea:	8526                	mv	a0,s1
    800054ec:	fffff097          	auipc	ra,0xfffff
    800054f0:	c4c080e7          	jalr	-948(ra) # 80004138 <dirlink>
    800054f4:	00054d63          	bltz	a0,8000550e <create+0x162>
    dp->nlink++; // for ".."
    800054f8:	04a4d783          	lhu	a5,74(s1)
    800054fc:	2785                	addiw	a5,a5,1
    800054fe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005502:	8526                	mv	a0,s1
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	46e080e7          	jalr	1134(ra) # 80003972 <iupdate>
    8000550c:	b761                	j	80005494 <create+0xe8>
  ip->nlink = 0;
    8000550e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005512:	8552                	mv	a0,s4
    80005514:	ffffe097          	auipc	ra,0xffffe
    80005518:	45e080e7          	jalr	1118(ra) # 80003972 <iupdate>
  iunlockput(ip);
    8000551c:	8552                	mv	a0,s4
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	782080e7          	jalr	1922(ra) # 80003ca0 <iunlockput>
  iunlockput(dp);
    80005526:	8526                	mv	a0,s1
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	778080e7          	jalr	1912(ra) # 80003ca0 <iunlockput>
  return 0;
    80005530:	bdcd                	j	80005422 <create+0x76>
    return 0;
    80005532:	8aaa                	mv	s5,a0
    80005534:	b5fd                	j	80005422 <create+0x76>

0000000080005536 <sys_dup>:
{
    80005536:	7179                	addi	sp,sp,-48
    80005538:	f406                	sd	ra,40(sp)
    8000553a:	f022                	sd	s0,32(sp)
    8000553c:	ec26                	sd	s1,24(sp)
    8000553e:	e84a                	sd	s2,16(sp)
    80005540:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80005542:	fd840613          	addi	a2,s0,-40
    80005546:	4581                	li	a1,0
    80005548:	4501                	li	a0,0
    8000554a:	00000097          	auipc	ra,0x0
    8000554e:	dc0080e7          	jalr	-576(ra) # 8000530a <argfd>
    return -1;
    80005552:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80005554:	02054363          	bltz	a0,8000557a <sys_dup+0x44>
  if ((fd = fdalloc(f)) < 0)
    80005558:	fd843903          	ld	s2,-40(s0)
    8000555c:	854a                	mv	a0,s2
    8000555e:	00000097          	auipc	ra,0x0
    80005562:	e0c080e7          	jalr	-500(ra) # 8000536a <fdalloc>
    80005566:	84aa                	mv	s1,a0
    return -1;
    80005568:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    8000556a:	00054863          	bltz	a0,8000557a <sys_dup+0x44>
  filedup(f);
    8000556e:	854a                	mv	a0,s2
    80005570:	fffff097          	auipc	ra,0xfffff
    80005574:	310080e7          	jalr	784(ra) # 80004880 <filedup>
  return fd;
    80005578:	87a6                	mv	a5,s1
}
    8000557a:	853e                	mv	a0,a5
    8000557c:	70a2                	ld	ra,40(sp)
    8000557e:	7402                	ld	s0,32(sp)
    80005580:	64e2                	ld	s1,24(sp)
    80005582:	6942                	ld	s2,16(sp)
    80005584:	6145                	addi	sp,sp,48
    80005586:	8082                	ret

0000000080005588 <sys_read>:
{
    80005588:	7179                	addi	sp,sp,-48
    8000558a:	f406                	sd	ra,40(sp)
    8000558c:	f022                	sd	s0,32(sp)
    8000558e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005590:	fd840593          	addi	a1,s0,-40
    80005594:	4505                	li	a0,1
    80005596:	ffffe097          	auipc	ra,0xffffe
    8000559a:	824080e7          	jalr	-2012(ra) # 80002dba <argaddr>
  argint(2, &n);
    8000559e:	fe440593          	addi	a1,s0,-28
    800055a2:	4509                	li	a0,2
    800055a4:	ffffd097          	auipc	ra,0xffffd
    800055a8:	7f6080e7          	jalr	2038(ra) # 80002d9a <argint>
  if (argfd(0, 0, &f) < 0)
    800055ac:	fe840613          	addi	a2,s0,-24
    800055b0:	4581                	li	a1,0
    800055b2:	4501                	li	a0,0
    800055b4:	00000097          	auipc	ra,0x0
    800055b8:	d56080e7          	jalr	-682(ra) # 8000530a <argfd>
    800055bc:	87aa                	mv	a5,a0
    return -1;
    800055be:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800055c0:	0007cc63          	bltz	a5,800055d8 <sys_read+0x50>
  return fileread(f, p, n);
    800055c4:	fe442603          	lw	a2,-28(s0)
    800055c8:	fd843583          	ld	a1,-40(s0)
    800055cc:	fe843503          	ld	a0,-24(s0)
    800055d0:	fffff097          	auipc	ra,0xfffff
    800055d4:	43c080e7          	jalr	1084(ra) # 80004a0c <fileread>
}
    800055d8:	70a2                	ld	ra,40(sp)
    800055da:	7402                	ld	s0,32(sp)
    800055dc:	6145                	addi	sp,sp,48
    800055de:	8082                	ret

00000000800055e0 <sys_write>:
{
    800055e0:	7179                	addi	sp,sp,-48
    800055e2:	f406                	sd	ra,40(sp)
    800055e4:	f022                	sd	s0,32(sp)
    800055e6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800055e8:	fd840593          	addi	a1,s0,-40
    800055ec:	4505                	li	a0,1
    800055ee:	ffffd097          	auipc	ra,0xffffd
    800055f2:	7cc080e7          	jalr	1996(ra) # 80002dba <argaddr>
  argint(2, &n);
    800055f6:	fe440593          	addi	a1,s0,-28
    800055fa:	4509                	li	a0,2
    800055fc:	ffffd097          	auipc	ra,0xffffd
    80005600:	79e080e7          	jalr	1950(ra) # 80002d9a <argint>
  if (argfd(0, 0, &f) < 0)
    80005604:	fe840613          	addi	a2,s0,-24
    80005608:	4581                	li	a1,0
    8000560a:	4501                	li	a0,0
    8000560c:	00000097          	auipc	ra,0x0
    80005610:	cfe080e7          	jalr	-770(ra) # 8000530a <argfd>
    80005614:	87aa                	mv	a5,a0
    return -1;
    80005616:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005618:	0007cc63          	bltz	a5,80005630 <sys_write+0x50>
  return filewrite(f, p, n);
    8000561c:	fe442603          	lw	a2,-28(s0)
    80005620:	fd843583          	ld	a1,-40(s0)
    80005624:	fe843503          	ld	a0,-24(s0)
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	4a6080e7          	jalr	1190(ra) # 80004ace <filewrite>
}
    80005630:	70a2                	ld	ra,40(sp)
    80005632:	7402                	ld	s0,32(sp)
    80005634:	6145                	addi	sp,sp,48
    80005636:	8082                	ret

0000000080005638 <sys_close>:
{
    80005638:	1101                	addi	sp,sp,-32
    8000563a:	ec06                	sd	ra,24(sp)
    8000563c:	e822                	sd	s0,16(sp)
    8000563e:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005640:	fe040613          	addi	a2,s0,-32
    80005644:	fec40593          	addi	a1,s0,-20
    80005648:	4501                	li	a0,0
    8000564a:	00000097          	auipc	ra,0x0
    8000564e:	cc0080e7          	jalr	-832(ra) # 8000530a <argfd>
    return -1;
    80005652:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005654:	02054463          	bltz	a0,8000567c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005658:	ffffc097          	auipc	ra,0xffffc
    8000565c:	354080e7          	jalr	852(ra) # 800019ac <myproc>
    80005660:	fec42783          	lw	a5,-20(s0)
    80005664:	07e9                	addi	a5,a5,26
    80005666:	078e                	slli	a5,a5,0x3
    80005668:	953e                	add	a0,a0,a5
    8000566a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000566e:	fe043503          	ld	a0,-32(s0)
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	260080e7          	jalr	608(ra) # 800048d2 <fileclose>
  return 0;
    8000567a:	4781                	li	a5,0
}
    8000567c:	853e                	mv	a0,a5
    8000567e:	60e2                	ld	ra,24(sp)
    80005680:	6442                	ld	s0,16(sp)
    80005682:	6105                	addi	sp,sp,32
    80005684:	8082                	ret

0000000080005686 <sys_fstat>:
{
    80005686:	1101                	addi	sp,sp,-32
    80005688:	ec06                	sd	ra,24(sp)
    8000568a:	e822                	sd	s0,16(sp)
    8000568c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000568e:	fe040593          	addi	a1,s0,-32
    80005692:	4505                	li	a0,1
    80005694:	ffffd097          	auipc	ra,0xffffd
    80005698:	726080e7          	jalr	1830(ra) # 80002dba <argaddr>
  if (argfd(0, 0, &f) < 0)
    8000569c:	fe840613          	addi	a2,s0,-24
    800056a0:	4581                	li	a1,0
    800056a2:	4501                	li	a0,0
    800056a4:	00000097          	auipc	ra,0x0
    800056a8:	c66080e7          	jalr	-922(ra) # 8000530a <argfd>
    800056ac:	87aa                	mv	a5,a0
    return -1;
    800056ae:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800056b0:	0007ca63          	bltz	a5,800056c4 <sys_fstat+0x3e>
  return filestat(f, st);
    800056b4:	fe043583          	ld	a1,-32(s0)
    800056b8:	fe843503          	ld	a0,-24(s0)
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	2de080e7          	jalr	734(ra) # 8000499a <filestat>
}
    800056c4:	60e2                	ld	ra,24(sp)
    800056c6:	6442                	ld	s0,16(sp)
    800056c8:	6105                	addi	sp,sp,32
    800056ca:	8082                	ret

00000000800056cc <sys_link>:
{
    800056cc:	7169                	addi	sp,sp,-304
    800056ce:	f606                	sd	ra,296(sp)
    800056d0:	f222                	sd	s0,288(sp)
    800056d2:	ee26                	sd	s1,280(sp)
    800056d4:	ea4a                	sd	s2,272(sp)
    800056d6:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056d8:	08000613          	li	a2,128
    800056dc:	ed040593          	addi	a1,s0,-304
    800056e0:	4501                	li	a0,0
    800056e2:	ffffd097          	auipc	ra,0xffffd
    800056e6:	6f8080e7          	jalr	1784(ra) # 80002dda <argstr>
    return -1;
    800056ea:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056ec:	10054e63          	bltz	a0,80005808 <sys_link+0x13c>
    800056f0:	08000613          	li	a2,128
    800056f4:	f5040593          	addi	a1,s0,-176
    800056f8:	4505                	li	a0,1
    800056fa:	ffffd097          	auipc	ra,0xffffd
    800056fe:	6e0080e7          	jalr	1760(ra) # 80002dda <argstr>
    return -1;
    80005702:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005704:	10054263          	bltz	a0,80005808 <sys_link+0x13c>
  begin_op();
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	d02080e7          	jalr	-766(ra) # 8000440a <begin_op>
  if ((ip = namei(old)) == 0)
    80005710:	ed040513          	addi	a0,s0,-304
    80005714:	fffff097          	auipc	ra,0xfffff
    80005718:	ad6080e7          	jalr	-1322(ra) # 800041ea <namei>
    8000571c:	84aa                	mv	s1,a0
    8000571e:	c551                	beqz	a0,800057aa <sys_link+0xde>
  ilock(ip);
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	31e080e7          	jalr	798(ra) # 80003a3e <ilock>
  if (ip->type == T_DIR)
    80005728:	04449703          	lh	a4,68(s1)
    8000572c:	4785                	li	a5,1
    8000572e:	08f70463          	beq	a4,a5,800057b6 <sys_link+0xea>
  ip->nlink++;
    80005732:	04a4d783          	lhu	a5,74(s1)
    80005736:	2785                	addiw	a5,a5,1
    80005738:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000573c:	8526                	mv	a0,s1
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	234080e7          	jalr	564(ra) # 80003972 <iupdate>
  iunlock(ip);
    80005746:	8526                	mv	a0,s1
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	3b8080e7          	jalr	952(ra) # 80003b00 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005750:	fd040593          	addi	a1,s0,-48
    80005754:	f5040513          	addi	a0,s0,-176
    80005758:	fffff097          	auipc	ra,0xfffff
    8000575c:	ab0080e7          	jalr	-1360(ra) # 80004208 <nameiparent>
    80005760:	892a                	mv	s2,a0
    80005762:	c935                	beqz	a0,800057d6 <sys_link+0x10a>
  ilock(dp);
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	2da080e7          	jalr	730(ra) # 80003a3e <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0)
    8000576c:	00092703          	lw	a4,0(s2)
    80005770:	409c                	lw	a5,0(s1)
    80005772:	04f71d63          	bne	a4,a5,800057cc <sys_link+0x100>
    80005776:	40d0                	lw	a2,4(s1)
    80005778:	fd040593          	addi	a1,s0,-48
    8000577c:	854a                	mv	a0,s2
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	9ba080e7          	jalr	-1606(ra) # 80004138 <dirlink>
    80005786:	04054363          	bltz	a0,800057cc <sys_link+0x100>
  iunlockput(dp);
    8000578a:	854a                	mv	a0,s2
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	514080e7          	jalr	1300(ra) # 80003ca0 <iunlockput>
  iput(ip);
    80005794:	8526                	mv	a0,s1
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	462080e7          	jalr	1122(ra) # 80003bf8 <iput>
  end_op();
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	cea080e7          	jalr	-790(ra) # 80004488 <end_op>
  return 0;
    800057a6:	4781                	li	a5,0
    800057a8:	a085                	j	80005808 <sys_link+0x13c>
    end_op();
    800057aa:	fffff097          	auipc	ra,0xfffff
    800057ae:	cde080e7          	jalr	-802(ra) # 80004488 <end_op>
    return -1;
    800057b2:	57fd                	li	a5,-1
    800057b4:	a891                	j	80005808 <sys_link+0x13c>
    iunlockput(ip);
    800057b6:	8526                	mv	a0,s1
    800057b8:	ffffe097          	auipc	ra,0xffffe
    800057bc:	4e8080e7          	jalr	1256(ra) # 80003ca0 <iunlockput>
    end_op();
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	cc8080e7          	jalr	-824(ra) # 80004488 <end_op>
    return -1;
    800057c8:	57fd                	li	a5,-1
    800057ca:	a83d                	j	80005808 <sys_link+0x13c>
    iunlockput(dp);
    800057cc:	854a                	mv	a0,s2
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	4d2080e7          	jalr	1234(ra) # 80003ca0 <iunlockput>
  ilock(ip);
    800057d6:	8526                	mv	a0,s1
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	266080e7          	jalr	614(ra) # 80003a3e <ilock>
  ip->nlink--;
    800057e0:	04a4d783          	lhu	a5,74(s1)
    800057e4:	37fd                	addiw	a5,a5,-1
    800057e6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057ea:	8526                	mv	a0,s1
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	186080e7          	jalr	390(ra) # 80003972 <iupdate>
  iunlockput(ip);
    800057f4:	8526                	mv	a0,s1
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	4aa080e7          	jalr	1194(ra) # 80003ca0 <iunlockput>
  end_op();
    800057fe:	fffff097          	auipc	ra,0xfffff
    80005802:	c8a080e7          	jalr	-886(ra) # 80004488 <end_op>
  return -1;
    80005806:	57fd                	li	a5,-1
}
    80005808:	853e                	mv	a0,a5
    8000580a:	70b2                	ld	ra,296(sp)
    8000580c:	7412                	ld	s0,288(sp)
    8000580e:	64f2                	ld	s1,280(sp)
    80005810:	6952                	ld	s2,272(sp)
    80005812:	6155                	addi	sp,sp,304
    80005814:	8082                	ret

0000000080005816 <sys_unlink>:
{
    80005816:	7151                	addi	sp,sp,-240
    80005818:	f586                	sd	ra,232(sp)
    8000581a:	f1a2                	sd	s0,224(sp)
    8000581c:	eda6                	sd	s1,216(sp)
    8000581e:	e9ca                	sd	s2,208(sp)
    80005820:	e5ce                	sd	s3,200(sp)
    80005822:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005824:	08000613          	li	a2,128
    80005828:	f3040593          	addi	a1,s0,-208
    8000582c:	4501                	li	a0,0
    8000582e:	ffffd097          	auipc	ra,0xffffd
    80005832:	5ac080e7          	jalr	1452(ra) # 80002dda <argstr>
    80005836:	18054163          	bltz	a0,800059b8 <sys_unlink+0x1a2>
  begin_op();
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	bd0080e7          	jalr	-1072(ra) # 8000440a <begin_op>
  if ((dp = nameiparent(path, name)) == 0)
    80005842:	fb040593          	addi	a1,s0,-80
    80005846:	f3040513          	addi	a0,s0,-208
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	9be080e7          	jalr	-1602(ra) # 80004208 <nameiparent>
    80005852:	84aa                	mv	s1,a0
    80005854:	c979                	beqz	a0,8000592a <sys_unlink+0x114>
  ilock(dp);
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	1e8080e7          	jalr	488(ra) # 80003a3e <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000585e:	00003597          	auipc	a1,0x3
    80005862:	eb258593          	addi	a1,a1,-334 # 80008710 <syscalls+0x2b8>
    80005866:	fb040513          	addi	a0,s0,-80
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	69e080e7          	jalr	1694(ra) # 80003f08 <namecmp>
    80005872:	14050a63          	beqz	a0,800059c6 <sys_unlink+0x1b0>
    80005876:	00003597          	auipc	a1,0x3
    8000587a:	ea258593          	addi	a1,a1,-350 # 80008718 <syscalls+0x2c0>
    8000587e:	fb040513          	addi	a0,s0,-80
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	686080e7          	jalr	1670(ra) # 80003f08 <namecmp>
    8000588a:	12050e63          	beqz	a0,800059c6 <sys_unlink+0x1b0>
  if ((ip = dirlookup(dp, name, &off)) == 0)
    8000588e:	f2c40613          	addi	a2,s0,-212
    80005892:	fb040593          	addi	a1,s0,-80
    80005896:	8526                	mv	a0,s1
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	68a080e7          	jalr	1674(ra) # 80003f22 <dirlookup>
    800058a0:	892a                	mv	s2,a0
    800058a2:	12050263          	beqz	a0,800059c6 <sys_unlink+0x1b0>
  ilock(ip);
    800058a6:	ffffe097          	auipc	ra,0xffffe
    800058aa:	198080e7          	jalr	408(ra) # 80003a3e <ilock>
  if (ip->nlink < 1)
    800058ae:	04a91783          	lh	a5,74(s2)
    800058b2:	08f05263          	blez	a5,80005936 <sys_unlink+0x120>
  if (ip->type == T_DIR && !isdirempty(ip))
    800058b6:	04491703          	lh	a4,68(s2)
    800058ba:	4785                	li	a5,1
    800058bc:	08f70563          	beq	a4,a5,80005946 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800058c0:	4641                	li	a2,16
    800058c2:	4581                	li	a1,0
    800058c4:	fc040513          	addi	a0,s0,-64
    800058c8:	ffffb097          	auipc	ra,0xffffb
    800058cc:	40a080e7          	jalr	1034(ra) # 80000cd2 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058d0:	4741                	li	a4,16
    800058d2:	f2c42683          	lw	a3,-212(s0)
    800058d6:	fc040613          	addi	a2,s0,-64
    800058da:	4581                	li	a1,0
    800058dc:	8526                	mv	a0,s1
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	50c080e7          	jalr	1292(ra) # 80003dea <writei>
    800058e6:	47c1                	li	a5,16
    800058e8:	0af51563          	bne	a0,a5,80005992 <sys_unlink+0x17c>
  if (ip->type == T_DIR)
    800058ec:	04491703          	lh	a4,68(s2)
    800058f0:	4785                	li	a5,1
    800058f2:	0af70863          	beq	a4,a5,800059a2 <sys_unlink+0x18c>
  iunlockput(dp);
    800058f6:	8526                	mv	a0,s1
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	3a8080e7          	jalr	936(ra) # 80003ca0 <iunlockput>
  ip->nlink--;
    80005900:	04a95783          	lhu	a5,74(s2)
    80005904:	37fd                	addiw	a5,a5,-1
    80005906:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000590a:	854a                	mv	a0,s2
    8000590c:	ffffe097          	auipc	ra,0xffffe
    80005910:	066080e7          	jalr	102(ra) # 80003972 <iupdate>
  iunlockput(ip);
    80005914:	854a                	mv	a0,s2
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	38a080e7          	jalr	906(ra) # 80003ca0 <iunlockput>
  end_op();
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	b6a080e7          	jalr	-1174(ra) # 80004488 <end_op>
  return 0;
    80005926:	4501                	li	a0,0
    80005928:	a84d                	j	800059da <sys_unlink+0x1c4>
    end_op();
    8000592a:	fffff097          	auipc	ra,0xfffff
    8000592e:	b5e080e7          	jalr	-1186(ra) # 80004488 <end_op>
    return -1;
    80005932:	557d                	li	a0,-1
    80005934:	a05d                	j	800059da <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005936:	00003517          	auipc	a0,0x3
    8000593a:	dea50513          	addi	a0,a0,-534 # 80008720 <syscalls+0x2c8>
    8000593e:	ffffb097          	auipc	ra,0xffffb
    80005942:	c02080e7          	jalr	-1022(ra) # 80000540 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005946:	04c92703          	lw	a4,76(s2)
    8000594a:	02000793          	li	a5,32
    8000594e:	f6e7f9e3          	bgeu	a5,a4,800058c0 <sys_unlink+0xaa>
    80005952:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005956:	4741                	li	a4,16
    80005958:	86ce                	mv	a3,s3
    8000595a:	f1840613          	addi	a2,s0,-232
    8000595e:	4581                	li	a1,0
    80005960:	854a                	mv	a0,s2
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	390080e7          	jalr	912(ra) # 80003cf2 <readi>
    8000596a:	47c1                	li	a5,16
    8000596c:	00f51b63          	bne	a0,a5,80005982 <sys_unlink+0x16c>
    if (de.inum != 0)
    80005970:	f1845783          	lhu	a5,-232(s0)
    80005974:	e7a1                	bnez	a5,800059bc <sys_unlink+0x1a6>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005976:	29c1                	addiw	s3,s3,16
    80005978:	04c92783          	lw	a5,76(s2)
    8000597c:	fcf9ede3          	bltu	s3,a5,80005956 <sys_unlink+0x140>
    80005980:	b781                	j	800058c0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005982:	00003517          	auipc	a0,0x3
    80005986:	db650513          	addi	a0,a0,-586 # 80008738 <syscalls+0x2e0>
    8000598a:	ffffb097          	auipc	ra,0xffffb
    8000598e:	bb6080e7          	jalr	-1098(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005992:	00003517          	auipc	a0,0x3
    80005996:	dbe50513          	addi	a0,a0,-578 # 80008750 <syscalls+0x2f8>
    8000599a:	ffffb097          	auipc	ra,0xffffb
    8000599e:	ba6080e7          	jalr	-1114(ra) # 80000540 <panic>
    dp->nlink--;
    800059a2:	04a4d783          	lhu	a5,74(s1)
    800059a6:	37fd                	addiw	a5,a5,-1
    800059a8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059ac:	8526                	mv	a0,s1
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	fc4080e7          	jalr	-60(ra) # 80003972 <iupdate>
    800059b6:	b781                	j	800058f6 <sys_unlink+0xe0>
    return -1;
    800059b8:	557d                	li	a0,-1
    800059ba:	a005                	j	800059da <sys_unlink+0x1c4>
    iunlockput(ip);
    800059bc:	854a                	mv	a0,s2
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	2e2080e7          	jalr	738(ra) # 80003ca0 <iunlockput>
  iunlockput(dp);
    800059c6:	8526                	mv	a0,s1
    800059c8:	ffffe097          	auipc	ra,0xffffe
    800059cc:	2d8080e7          	jalr	728(ra) # 80003ca0 <iunlockput>
  end_op();
    800059d0:	fffff097          	auipc	ra,0xfffff
    800059d4:	ab8080e7          	jalr	-1352(ra) # 80004488 <end_op>
  return -1;
    800059d8:	557d                	li	a0,-1
}
    800059da:	70ae                	ld	ra,232(sp)
    800059dc:	740e                	ld	s0,224(sp)
    800059de:	64ee                	ld	s1,216(sp)
    800059e0:	694e                	ld	s2,208(sp)
    800059e2:	69ae                	ld	s3,200(sp)
    800059e4:	616d                	addi	sp,sp,240
    800059e6:	8082                	ret

00000000800059e8 <sys_open>:

uint64
sys_open(void)
{
    800059e8:	7131                	addi	sp,sp,-192
    800059ea:	fd06                	sd	ra,184(sp)
    800059ec:	f922                	sd	s0,176(sp)
    800059ee:	f526                	sd	s1,168(sp)
    800059f0:	f14a                	sd	s2,160(sp)
    800059f2:	ed4e                	sd	s3,152(sp)
    800059f4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800059f6:	f4c40593          	addi	a1,s0,-180
    800059fa:	4505                	li	a0,1
    800059fc:	ffffd097          	auipc	ra,0xffffd
    80005a00:	39e080e7          	jalr	926(ra) # 80002d9a <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005a04:	08000613          	li	a2,128
    80005a08:	f5040593          	addi	a1,s0,-176
    80005a0c:	4501                	li	a0,0
    80005a0e:	ffffd097          	auipc	ra,0xffffd
    80005a12:	3cc080e7          	jalr	972(ra) # 80002dda <argstr>
    80005a16:	87aa                	mv	a5,a0
    return -1;
    80005a18:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005a1a:	0a07c963          	bltz	a5,80005acc <sys_open+0xe4>

  begin_op();
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	9ec080e7          	jalr	-1556(ra) # 8000440a <begin_op>

  if (omode & O_CREATE)
    80005a26:	f4c42783          	lw	a5,-180(s0)
    80005a2a:	2007f793          	andi	a5,a5,512
    80005a2e:	cfc5                	beqz	a5,80005ae6 <sys_open+0xfe>
  {
    ip = create(path, T_FILE, 0, 0);
    80005a30:	4681                	li	a3,0
    80005a32:	4601                	li	a2,0
    80005a34:	4589                	li	a1,2
    80005a36:	f5040513          	addi	a0,s0,-176
    80005a3a:	00000097          	auipc	ra,0x0
    80005a3e:	972080e7          	jalr	-1678(ra) # 800053ac <create>
    80005a42:	84aa                	mv	s1,a0
    if (ip == 0)
    80005a44:	c959                	beqz	a0,80005ada <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV))
    80005a46:	04449703          	lh	a4,68(s1)
    80005a4a:	478d                	li	a5,3
    80005a4c:	00f71763          	bne	a4,a5,80005a5a <sys_open+0x72>
    80005a50:	0464d703          	lhu	a4,70(s1)
    80005a54:	47a5                	li	a5,9
    80005a56:	0ce7ed63          	bltu	a5,a4,80005b30 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0)
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	dbc080e7          	jalr	-580(ra) # 80004816 <filealloc>
    80005a62:	89aa                	mv	s3,a0
    80005a64:	10050363          	beqz	a0,80005b6a <sys_open+0x182>
    80005a68:	00000097          	auipc	ra,0x0
    80005a6c:	902080e7          	jalr	-1790(ra) # 8000536a <fdalloc>
    80005a70:	892a                	mv	s2,a0
    80005a72:	0e054763          	bltz	a0,80005b60 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE)
    80005a76:	04449703          	lh	a4,68(s1)
    80005a7a:	478d                	li	a5,3
    80005a7c:	0cf70563          	beq	a4,a5,80005b46 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  }
  else
  {
    f->type = FD_INODE;
    80005a80:	4789                	li	a5,2
    80005a82:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a86:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a8a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a8e:	f4c42783          	lw	a5,-180(s0)
    80005a92:	0017c713          	xori	a4,a5,1
    80005a96:	8b05                	andi	a4,a4,1
    80005a98:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a9c:	0037f713          	andi	a4,a5,3
    80005aa0:	00e03733          	snez	a4,a4
    80005aa4:	00e984a3          	sb	a4,9(s3)

  if ((omode & O_TRUNC) && ip->type == T_FILE)
    80005aa8:	4007f793          	andi	a5,a5,1024
    80005aac:	c791                	beqz	a5,80005ab8 <sys_open+0xd0>
    80005aae:	04449703          	lh	a4,68(s1)
    80005ab2:	4789                	li	a5,2
    80005ab4:	0af70063          	beq	a4,a5,80005b54 <sys_open+0x16c>
  {
    itrunc(ip);
  }

  iunlock(ip);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	046080e7          	jalr	70(ra) # 80003b00 <iunlock>
  end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	9c6080e7          	jalr	-1594(ra) # 80004488 <end_op>

  return fd;
    80005aca:	854a                	mv	a0,s2
}
    80005acc:	70ea                	ld	ra,184(sp)
    80005ace:	744a                	ld	s0,176(sp)
    80005ad0:	74aa                	ld	s1,168(sp)
    80005ad2:	790a                	ld	s2,160(sp)
    80005ad4:	69ea                	ld	s3,152(sp)
    80005ad6:	6129                	addi	sp,sp,192
    80005ad8:	8082                	ret
      end_op();
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	9ae080e7          	jalr	-1618(ra) # 80004488 <end_op>
      return -1;
    80005ae2:	557d                	li	a0,-1
    80005ae4:	b7e5                	j	80005acc <sys_open+0xe4>
    if ((ip = namei(path)) == 0)
    80005ae6:	f5040513          	addi	a0,s0,-176
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	700080e7          	jalr	1792(ra) # 800041ea <namei>
    80005af2:	84aa                	mv	s1,a0
    80005af4:	c905                	beqz	a0,80005b24 <sys_open+0x13c>
    ilock(ip);
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	f48080e7          	jalr	-184(ra) # 80003a3e <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY)
    80005afe:	04449703          	lh	a4,68(s1)
    80005b02:	4785                	li	a5,1
    80005b04:	f4f711e3          	bne	a4,a5,80005a46 <sys_open+0x5e>
    80005b08:	f4c42783          	lw	a5,-180(s0)
    80005b0c:	d7b9                	beqz	a5,80005a5a <sys_open+0x72>
      iunlockput(ip);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	190080e7          	jalr	400(ra) # 80003ca0 <iunlockput>
      end_op();
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	970080e7          	jalr	-1680(ra) # 80004488 <end_op>
      return -1;
    80005b20:	557d                	li	a0,-1
    80005b22:	b76d                	j	80005acc <sys_open+0xe4>
      end_op();
    80005b24:	fffff097          	auipc	ra,0xfffff
    80005b28:	964080e7          	jalr	-1692(ra) # 80004488 <end_op>
      return -1;
    80005b2c:	557d                	li	a0,-1
    80005b2e:	bf79                	j	80005acc <sys_open+0xe4>
    iunlockput(ip);
    80005b30:	8526                	mv	a0,s1
    80005b32:	ffffe097          	auipc	ra,0xffffe
    80005b36:	16e080e7          	jalr	366(ra) # 80003ca0 <iunlockput>
    end_op();
    80005b3a:	fffff097          	auipc	ra,0xfffff
    80005b3e:	94e080e7          	jalr	-1714(ra) # 80004488 <end_op>
    return -1;
    80005b42:	557d                	li	a0,-1
    80005b44:	b761                	j	80005acc <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b46:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b4a:	04649783          	lh	a5,70(s1)
    80005b4e:	02f99223          	sh	a5,36(s3)
    80005b52:	bf25                	j	80005a8a <sys_open+0xa2>
    itrunc(ip);
    80005b54:	8526                	mv	a0,s1
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	ff6080e7          	jalr	-10(ra) # 80003b4c <itrunc>
    80005b5e:	bfa9                	j	80005ab8 <sys_open+0xd0>
      fileclose(f);
    80005b60:	854e                	mv	a0,s3
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	d70080e7          	jalr	-656(ra) # 800048d2 <fileclose>
    iunlockput(ip);
    80005b6a:	8526                	mv	a0,s1
    80005b6c:	ffffe097          	auipc	ra,0xffffe
    80005b70:	134080e7          	jalr	308(ra) # 80003ca0 <iunlockput>
    end_op();
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	914080e7          	jalr	-1772(ra) # 80004488 <end_op>
    return -1;
    80005b7c:	557d                	li	a0,-1
    80005b7e:	b7b9                	j	80005acc <sys_open+0xe4>

0000000080005b80 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b80:	7175                	addi	sp,sp,-144
    80005b82:	e506                	sd	ra,136(sp)
    80005b84:	e122                	sd	s0,128(sp)
    80005b86:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b88:	fffff097          	auipc	ra,0xfffff
    80005b8c:	882080e7          	jalr	-1918(ra) # 8000440a <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
    80005b90:	08000613          	li	a2,128
    80005b94:	f7040593          	addi	a1,s0,-144
    80005b98:	4501                	li	a0,0
    80005b9a:	ffffd097          	auipc	ra,0xffffd
    80005b9e:	240080e7          	jalr	576(ra) # 80002dda <argstr>
    80005ba2:	02054963          	bltz	a0,80005bd4 <sys_mkdir+0x54>
    80005ba6:	4681                	li	a3,0
    80005ba8:	4601                	li	a2,0
    80005baa:	4585                	li	a1,1
    80005bac:	f7040513          	addi	a0,s0,-144
    80005bb0:	fffff097          	auipc	ra,0xfffff
    80005bb4:	7fc080e7          	jalr	2044(ra) # 800053ac <create>
    80005bb8:	cd11                	beqz	a0,80005bd4 <sys_mkdir+0x54>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	0e6080e7          	jalr	230(ra) # 80003ca0 <iunlockput>
  end_op();
    80005bc2:	fffff097          	auipc	ra,0xfffff
    80005bc6:	8c6080e7          	jalr	-1850(ra) # 80004488 <end_op>
  return 0;
    80005bca:	4501                	li	a0,0
}
    80005bcc:	60aa                	ld	ra,136(sp)
    80005bce:	640a                	ld	s0,128(sp)
    80005bd0:	6149                	addi	sp,sp,144
    80005bd2:	8082                	ret
    end_op();
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	8b4080e7          	jalr	-1868(ra) # 80004488 <end_op>
    return -1;
    80005bdc:	557d                	li	a0,-1
    80005bde:	b7fd                	j	80005bcc <sys_mkdir+0x4c>

0000000080005be0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005be0:	7135                	addi	sp,sp,-160
    80005be2:	ed06                	sd	ra,152(sp)
    80005be4:	e922                	sd	s0,144(sp)
    80005be6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005be8:	fffff097          	auipc	ra,0xfffff
    80005bec:	822080e7          	jalr	-2014(ra) # 8000440a <begin_op>
  argint(1, &major);
    80005bf0:	f6c40593          	addi	a1,s0,-148
    80005bf4:	4505                	li	a0,1
    80005bf6:	ffffd097          	auipc	ra,0xffffd
    80005bfa:	1a4080e7          	jalr	420(ra) # 80002d9a <argint>
  argint(2, &minor);
    80005bfe:	f6840593          	addi	a1,s0,-152
    80005c02:	4509                	li	a0,2
    80005c04:	ffffd097          	auipc	ra,0xffffd
    80005c08:	196080e7          	jalr	406(ra) # 80002d9a <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005c0c:	08000613          	li	a2,128
    80005c10:	f7040593          	addi	a1,s0,-144
    80005c14:	4501                	li	a0,0
    80005c16:	ffffd097          	auipc	ra,0xffffd
    80005c1a:	1c4080e7          	jalr	452(ra) # 80002dda <argstr>
    80005c1e:	02054b63          	bltz	a0,80005c54 <sys_mknod+0x74>
      (ip = create(path, T_DEVICE, major, minor)) == 0)
    80005c22:	f6841683          	lh	a3,-152(s0)
    80005c26:	f6c41603          	lh	a2,-148(s0)
    80005c2a:	458d                	li	a1,3
    80005c2c:	f7040513          	addi	a0,s0,-144
    80005c30:	fffff097          	auipc	ra,0xfffff
    80005c34:	77c080e7          	jalr	1916(ra) # 800053ac <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005c38:	cd11                	beqz	a0,80005c54 <sys_mknod+0x74>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	066080e7          	jalr	102(ra) # 80003ca0 <iunlockput>
  end_op();
    80005c42:	fffff097          	auipc	ra,0xfffff
    80005c46:	846080e7          	jalr	-1978(ra) # 80004488 <end_op>
  return 0;
    80005c4a:	4501                	li	a0,0
}
    80005c4c:	60ea                	ld	ra,152(sp)
    80005c4e:	644a                	ld	s0,144(sp)
    80005c50:	610d                	addi	sp,sp,160
    80005c52:	8082                	ret
    end_op();
    80005c54:	fffff097          	auipc	ra,0xfffff
    80005c58:	834080e7          	jalr	-1996(ra) # 80004488 <end_op>
    return -1;
    80005c5c:	557d                	li	a0,-1
    80005c5e:	b7fd                	j	80005c4c <sys_mknod+0x6c>

0000000080005c60 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c60:	7135                	addi	sp,sp,-160
    80005c62:	ed06                	sd	ra,152(sp)
    80005c64:	e922                	sd	s0,144(sp)
    80005c66:	e526                	sd	s1,136(sp)
    80005c68:	e14a                	sd	s2,128(sp)
    80005c6a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c6c:	ffffc097          	auipc	ra,0xffffc
    80005c70:	d40080e7          	jalr	-704(ra) # 800019ac <myproc>
    80005c74:	892a                	mv	s2,a0

  begin_op();
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	794080e7          	jalr	1940(ra) # 8000440a <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0)
    80005c7e:	08000613          	li	a2,128
    80005c82:	f6040593          	addi	a1,s0,-160
    80005c86:	4501                	li	a0,0
    80005c88:	ffffd097          	auipc	ra,0xffffd
    80005c8c:	152080e7          	jalr	338(ra) # 80002dda <argstr>
    80005c90:	04054b63          	bltz	a0,80005ce6 <sys_chdir+0x86>
    80005c94:	f6040513          	addi	a0,s0,-160
    80005c98:	ffffe097          	auipc	ra,0xffffe
    80005c9c:	552080e7          	jalr	1362(ra) # 800041ea <namei>
    80005ca0:	84aa                	mv	s1,a0
    80005ca2:	c131                	beqz	a0,80005ce6 <sys_chdir+0x86>
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	d9a080e7          	jalr	-614(ra) # 80003a3e <ilock>
  if (ip->type != T_DIR)
    80005cac:	04449703          	lh	a4,68(s1)
    80005cb0:	4785                	li	a5,1
    80005cb2:	04f71063          	bne	a4,a5,80005cf2 <sys_chdir+0x92>
  {
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005cb6:	8526                	mv	a0,s1
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	e48080e7          	jalr	-440(ra) # 80003b00 <iunlock>
  iput(p->cwd);
    80005cc0:	15093503          	ld	a0,336(s2)
    80005cc4:	ffffe097          	auipc	ra,0xffffe
    80005cc8:	f34080e7          	jalr	-204(ra) # 80003bf8 <iput>
  end_op();
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	7bc080e7          	jalr	1980(ra) # 80004488 <end_op>
  p->cwd = ip;
    80005cd4:	14993823          	sd	s1,336(s2)
  return 0;
    80005cd8:	4501                	li	a0,0
}
    80005cda:	60ea                	ld	ra,152(sp)
    80005cdc:	644a                	ld	s0,144(sp)
    80005cde:	64aa                	ld	s1,136(sp)
    80005ce0:	690a                	ld	s2,128(sp)
    80005ce2:	610d                	addi	sp,sp,160
    80005ce4:	8082                	ret
    end_op();
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	7a2080e7          	jalr	1954(ra) # 80004488 <end_op>
    return -1;
    80005cee:	557d                	li	a0,-1
    80005cf0:	b7ed                	j	80005cda <sys_chdir+0x7a>
    iunlockput(ip);
    80005cf2:	8526                	mv	a0,s1
    80005cf4:	ffffe097          	auipc	ra,0xffffe
    80005cf8:	fac080e7          	jalr	-84(ra) # 80003ca0 <iunlockput>
    end_op();
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	78c080e7          	jalr	1932(ra) # 80004488 <end_op>
    return -1;
    80005d04:	557d                	li	a0,-1
    80005d06:	bfd1                	j	80005cda <sys_chdir+0x7a>

0000000080005d08 <sys_exec>:

uint64
sys_exec(void)
{
    80005d08:	7145                	addi	sp,sp,-464
    80005d0a:	e786                	sd	ra,456(sp)
    80005d0c:	e3a2                	sd	s0,448(sp)
    80005d0e:	ff26                	sd	s1,440(sp)
    80005d10:	fb4a                	sd	s2,432(sp)
    80005d12:	f74e                	sd	s3,424(sp)
    80005d14:	f352                	sd	s4,416(sp)
    80005d16:	ef56                	sd	s5,408(sp)
    80005d18:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005d1a:	e3840593          	addi	a1,s0,-456
    80005d1e:	4505                	li	a0,1
    80005d20:	ffffd097          	auipc	ra,0xffffd
    80005d24:	09a080e7          	jalr	154(ra) # 80002dba <argaddr>
  if (argstr(0, path, MAXPATH) < 0)
    80005d28:	08000613          	li	a2,128
    80005d2c:	f4040593          	addi	a1,s0,-192
    80005d30:	4501                	li	a0,0
    80005d32:	ffffd097          	auipc	ra,0xffffd
    80005d36:	0a8080e7          	jalr	168(ra) # 80002dda <argstr>
    80005d3a:	87aa                	mv	a5,a0
  {
    return -1;
    80005d3c:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0)
    80005d3e:	0c07c363          	bltz	a5,80005e04 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005d42:	10000613          	li	a2,256
    80005d46:	4581                	li	a1,0
    80005d48:	e4040513          	addi	a0,s0,-448
    80005d4c:	ffffb097          	auipc	ra,0xffffb
    80005d50:	f86080e7          	jalr	-122(ra) # 80000cd2 <memset>
  for (i = 0;; i++)
  {
    if (i >= NELEM(argv))
    80005d54:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d58:	89a6                	mv	s3,s1
    80005d5a:	4901                	li	s2,0
    if (i >= NELEM(argv))
    80005d5c:	02000a13          	li	s4,32
    80005d60:	00090a9b          	sext.w	s5,s2
    {
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0)
    80005d64:	00391513          	slli	a0,s2,0x3
    80005d68:	e3040593          	addi	a1,s0,-464
    80005d6c:	e3843783          	ld	a5,-456(s0)
    80005d70:	953e                	add	a0,a0,a5
    80005d72:	ffffd097          	auipc	ra,0xffffd
    80005d76:	f8a080e7          	jalr	-118(ra) # 80002cfc <fetchaddr>
    80005d7a:	02054a63          	bltz	a0,80005dae <sys_exec+0xa6>
    {
      goto bad;
    }
    if (uarg == 0)
    80005d7e:	e3043783          	ld	a5,-464(s0)
    80005d82:	c3b9                	beqz	a5,80005dc8 <sys_exec+0xc0>
    {
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d84:	ffffb097          	auipc	ra,0xffffb
    80005d88:	d62080e7          	jalr	-670(ra) # 80000ae6 <kalloc>
    80005d8c:	85aa                	mv	a1,a0
    80005d8e:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005d92:	cd11                	beqz	a0,80005dae <sys_exec+0xa6>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d94:	6605                	lui	a2,0x1
    80005d96:	e3043503          	ld	a0,-464(s0)
    80005d9a:	ffffd097          	auipc	ra,0xffffd
    80005d9e:	fb4080e7          	jalr	-76(ra) # 80002d4e <fetchstr>
    80005da2:	00054663          	bltz	a0,80005dae <sys_exec+0xa6>
    if (i >= NELEM(argv))
    80005da6:	0905                	addi	s2,s2,1
    80005da8:	09a1                	addi	s3,s3,8
    80005daa:	fb491be3          	bne	s2,s4,80005d60 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dae:	f4040913          	addi	s2,s0,-192
    80005db2:	6088                	ld	a0,0(s1)
    80005db4:	c539                	beqz	a0,80005e02 <sys_exec+0xfa>
    kfree(argv[i]);
    80005db6:	ffffb097          	auipc	ra,0xffffb
    80005dba:	c32080e7          	jalr	-974(ra) # 800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dbe:	04a1                	addi	s1,s1,8
    80005dc0:	ff2499e3          	bne	s1,s2,80005db2 <sys_exec+0xaa>
  return -1;
    80005dc4:	557d                	li	a0,-1
    80005dc6:	a83d                	j	80005e04 <sys_exec+0xfc>
      argv[i] = 0;
    80005dc8:	0a8e                	slli	s5,s5,0x3
    80005dca:	fc0a8793          	addi	a5,s5,-64
    80005dce:	00878ab3          	add	s5,a5,s0
    80005dd2:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005dd6:	e4040593          	addi	a1,s0,-448
    80005dda:	f4040513          	addi	a0,s0,-192
    80005dde:	fffff097          	auipc	ra,0xfffff
    80005de2:	16e080e7          	jalr	366(ra) # 80004f4c <exec>
    80005de6:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005de8:	f4040993          	addi	s3,s0,-192
    80005dec:	6088                	ld	a0,0(s1)
    80005dee:	c901                	beqz	a0,80005dfe <sys_exec+0xf6>
    kfree(argv[i]);
    80005df0:	ffffb097          	auipc	ra,0xffffb
    80005df4:	bf8080e7          	jalr	-1032(ra) # 800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005df8:	04a1                	addi	s1,s1,8
    80005dfa:	ff3499e3          	bne	s1,s3,80005dec <sys_exec+0xe4>
  return ret;
    80005dfe:	854a                	mv	a0,s2
    80005e00:	a011                	j	80005e04 <sys_exec+0xfc>
  return -1;
    80005e02:	557d                	li	a0,-1
}
    80005e04:	60be                	ld	ra,456(sp)
    80005e06:	641e                	ld	s0,448(sp)
    80005e08:	74fa                	ld	s1,440(sp)
    80005e0a:	795a                	ld	s2,432(sp)
    80005e0c:	79ba                	ld	s3,424(sp)
    80005e0e:	7a1a                	ld	s4,416(sp)
    80005e10:	6afa                	ld	s5,408(sp)
    80005e12:	6179                	addi	sp,sp,464
    80005e14:	8082                	ret

0000000080005e16 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e16:	7139                	addi	sp,sp,-64
    80005e18:	fc06                	sd	ra,56(sp)
    80005e1a:	f822                	sd	s0,48(sp)
    80005e1c:	f426                	sd	s1,40(sp)
    80005e1e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e20:	ffffc097          	auipc	ra,0xffffc
    80005e24:	b8c080e7          	jalr	-1140(ra) # 800019ac <myproc>
    80005e28:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005e2a:	fd840593          	addi	a1,s0,-40
    80005e2e:	4501                	li	a0,0
    80005e30:	ffffd097          	auipc	ra,0xffffd
    80005e34:	f8a080e7          	jalr	-118(ra) # 80002dba <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005e38:	fc840593          	addi	a1,s0,-56
    80005e3c:	fd040513          	addi	a0,s0,-48
    80005e40:	fffff097          	auipc	ra,0xfffff
    80005e44:	dc2080e7          	jalr	-574(ra) # 80004c02 <pipealloc>
    return -1;
    80005e48:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005e4a:	0c054463          	bltz	a0,80005f12 <sys_pipe+0xfc>
  fd0 = -1;
    80005e4e:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0)
    80005e52:	fd043503          	ld	a0,-48(s0)
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	514080e7          	jalr	1300(ra) # 8000536a <fdalloc>
    80005e5e:	fca42223          	sw	a0,-60(s0)
    80005e62:	08054b63          	bltz	a0,80005ef8 <sys_pipe+0xe2>
    80005e66:	fc843503          	ld	a0,-56(s0)
    80005e6a:	fffff097          	auipc	ra,0xfffff
    80005e6e:	500080e7          	jalr	1280(ra) # 8000536a <fdalloc>
    80005e72:	fca42023          	sw	a0,-64(s0)
    80005e76:	06054863          	bltz	a0,80005ee6 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005e7a:	4691                	li	a3,4
    80005e7c:	fc440613          	addi	a2,s0,-60
    80005e80:	fd843583          	ld	a1,-40(s0)
    80005e84:	68a8                	ld	a0,80(s1)
    80005e86:	ffffb097          	auipc	ra,0xffffb
    80005e8a:	7e6080e7          	jalr	2022(ra) # 8000166c <copyout>
    80005e8e:	02054063          	bltz	a0,80005eae <sys_pipe+0x98>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0)
    80005e92:	4691                	li	a3,4
    80005e94:	fc040613          	addi	a2,s0,-64
    80005e98:	fd843583          	ld	a1,-40(s0)
    80005e9c:	0591                	addi	a1,a1,4
    80005e9e:	68a8                	ld	a0,80(s1)
    80005ea0:	ffffb097          	auipc	ra,0xffffb
    80005ea4:	7cc080e7          	jalr	1996(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ea8:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005eaa:	06055463          	bgez	a0,80005f12 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005eae:	fc442783          	lw	a5,-60(s0)
    80005eb2:	07e9                	addi	a5,a5,26
    80005eb4:	078e                	slli	a5,a5,0x3
    80005eb6:	97a6                	add	a5,a5,s1
    80005eb8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ebc:	fc042783          	lw	a5,-64(s0)
    80005ec0:	07e9                	addi	a5,a5,26
    80005ec2:	078e                	slli	a5,a5,0x3
    80005ec4:	94be                	add	s1,s1,a5
    80005ec6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005eca:	fd043503          	ld	a0,-48(s0)
    80005ece:	fffff097          	auipc	ra,0xfffff
    80005ed2:	a04080e7          	jalr	-1532(ra) # 800048d2 <fileclose>
    fileclose(wf);
    80005ed6:	fc843503          	ld	a0,-56(s0)
    80005eda:	fffff097          	auipc	ra,0xfffff
    80005ede:	9f8080e7          	jalr	-1544(ra) # 800048d2 <fileclose>
    return -1;
    80005ee2:	57fd                	li	a5,-1
    80005ee4:	a03d                	j	80005f12 <sys_pipe+0xfc>
    if (fd0 >= 0)
    80005ee6:	fc442783          	lw	a5,-60(s0)
    80005eea:	0007c763          	bltz	a5,80005ef8 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005eee:	07e9                	addi	a5,a5,26
    80005ef0:	078e                	slli	a5,a5,0x3
    80005ef2:	97a6                	add	a5,a5,s1
    80005ef4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ef8:	fd043503          	ld	a0,-48(s0)
    80005efc:	fffff097          	auipc	ra,0xfffff
    80005f00:	9d6080e7          	jalr	-1578(ra) # 800048d2 <fileclose>
    fileclose(wf);
    80005f04:	fc843503          	ld	a0,-56(s0)
    80005f08:	fffff097          	auipc	ra,0xfffff
    80005f0c:	9ca080e7          	jalr	-1590(ra) # 800048d2 <fileclose>
    return -1;
    80005f10:	57fd                	li	a5,-1
}
    80005f12:	853e                	mv	a0,a5
    80005f14:	70e2                	ld	ra,56(sp)
    80005f16:	7442                	ld	s0,48(sp)
    80005f18:	74a2                	ld	s1,40(sp)
    80005f1a:	6121                	addi	sp,sp,64
    80005f1c:	8082                	ret
	...

0000000080005f20 <kernelvec>:
    80005f20:	7111                	addi	sp,sp,-256
    80005f22:	e006                	sd	ra,0(sp)
    80005f24:	e40a                	sd	sp,8(sp)
    80005f26:	e80e                	sd	gp,16(sp)
    80005f28:	ec12                	sd	tp,24(sp)
    80005f2a:	f016                	sd	t0,32(sp)
    80005f2c:	f41a                	sd	t1,40(sp)
    80005f2e:	f81e                	sd	t2,48(sp)
    80005f30:	fc22                	sd	s0,56(sp)
    80005f32:	e0a6                	sd	s1,64(sp)
    80005f34:	e4aa                	sd	a0,72(sp)
    80005f36:	e8ae                	sd	a1,80(sp)
    80005f38:	ecb2                	sd	a2,88(sp)
    80005f3a:	f0b6                	sd	a3,96(sp)
    80005f3c:	f4ba                	sd	a4,104(sp)
    80005f3e:	f8be                	sd	a5,112(sp)
    80005f40:	fcc2                	sd	a6,120(sp)
    80005f42:	e146                	sd	a7,128(sp)
    80005f44:	e54a                	sd	s2,136(sp)
    80005f46:	e94e                	sd	s3,144(sp)
    80005f48:	ed52                	sd	s4,152(sp)
    80005f4a:	f156                	sd	s5,160(sp)
    80005f4c:	f55a                	sd	s6,168(sp)
    80005f4e:	f95e                	sd	s7,176(sp)
    80005f50:	fd62                	sd	s8,184(sp)
    80005f52:	e1e6                	sd	s9,192(sp)
    80005f54:	e5ea                	sd	s10,200(sp)
    80005f56:	e9ee                	sd	s11,208(sp)
    80005f58:	edf2                	sd	t3,216(sp)
    80005f5a:	f1f6                	sd	t4,224(sp)
    80005f5c:	f5fa                	sd	t5,232(sp)
    80005f5e:	f9fe                	sd	t6,240(sp)
    80005f60:	c69fc0ef          	jal	ra,80002bc8 <kerneltrap>
    80005f64:	6082                	ld	ra,0(sp)
    80005f66:	6122                	ld	sp,8(sp)
    80005f68:	61c2                	ld	gp,16(sp)
    80005f6a:	7282                	ld	t0,32(sp)
    80005f6c:	7322                	ld	t1,40(sp)
    80005f6e:	73c2                	ld	t2,48(sp)
    80005f70:	7462                	ld	s0,56(sp)
    80005f72:	6486                	ld	s1,64(sp)
    80005f74:	6526                	ld	a0,72(sp)
    80005f76:	65c6                	ld	a1,80(sp)
    80005f78:	6666                	ld	a2,88(sp)
    80005f7a:	7686                	ld	a3,96(sp)
    80005f7c:	7726                	ld	a4,104(sp)
    80005f7e:	77c6                	ld	a5,112(sp)
    80005f80:	7866                	ld	a6,120(sp)
    80005f82:	688a                	ld	a7,128(sp)
    80005f84:	692a                	ld	s2,136(sp)
    80005f86:	69ca                	ld	s3,144(sp)
    80005f88:	6a6a                	ld	s4,152(sp)
    80005f8a:	7a8a                	ld	s5,160(sp)
    80005f8c:	7b2a                	ld	s6,168(sp)
    80005f8e:	7bca                	ld	s7,176(sp)
    80005f90:	7c6a                	ld	s8,184(sp)
    80005f92:	6c8e                	ld	s9,192(sp)
    80005f94:	6d2e                	ld	s10,200(sp)
    80005f96:	6dce                	ld	s11,208(sp)
    80005f98:	6e6e                	ld	t3,216(sp)
    80005f9a:	7e8e                	ld	t4,224(sp)
    80005f9c:	7f2e                	ld	t5,232(sp)
    80005f9e:	7fce                	ld	t6,240(sp)
    80005fa0:	6111                	addi	sp,sp,256
    80005fa2:	10200073          	sret
    80005fa6:	00000013          	nop
    80005faa:	00000013          	nop
    80005fae:	0001                	nop

0000000080005fb0 <timervec>:
    80005fb0:	34051573          	csrrw	a0,mscratch,a0
    80005fb4:	e10c                	sd	a1,0(a0)
    80005fb6:	e510                	sd	a2,8(a0)
    80005fb8:	e914                	sd	a3,16(a0)
    80005fba:	6d0c                	ld	a1,24(a0)
    80005fbc:	7110                	ld	a2,32(a0)
    80005fbe:	6194                	ld	a3,0(a1)
    80005fc0:	96b2                	add	a3,a3,a2
    80005fc2:	e194                	sd	a3,0(a1)
    80005fc4:	4589                	li	a1,2
    80005fc6:	14459073          	csrw	sip,a1
    80005fca:	6914                	ld	a3,16(a0)
    80005fcc:	6510                	ld	a2,8(a0)
    80005fce:	610c                	ld	a1,0(a0)
    80005fd0:	34051573          	csrrw	a0,mscratch,a0
    80005fd4:	30200073          	mret
	...

0000000080005fda <plicinit>:
//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void)
{
    80005fda:	1141                	addi	sp,sp,-16
    80005fdc:	e422                	sd	s0,8(sp)
    80005fde:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005fe0:	0c0007b7          	lui	a5,0xc000
    80005fe4:	4705                	li	a4,1
    80005fe6:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80005fe8:	c3d8                	sw	a4,4(a5)
}
    80005fea:	6422                	ld	s0,8(sp)
    80005fec:	0141                	addi	sp,sp,16
    80005fee:	8082                	ret

0000000080005ff0 <plicinithart>:

void plicinithart(void)
{
    80005ff0:	1141                	addi	sp,sp,-16
    80005ff2:	e406                	sd	ra,8(sp)
    80005ff4:	e022                	sd	s0,0(sp)
    80005ff6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ff8:	ffffc097          	auipc	ra,0xffffc
    80005ffc:	988080e7          	jalr	-1656(ra) # 80001980 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006000:	0085171b          	slliw	a4,a0,0x8
    80006004:	0c0027b7          	lui	a5,0xc002
    80006008:	97ba                	add	a5,a5,a4
    8000600a:	40200713          	li	a4,1026
    8000600e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80006012:	00d5151b          	slliw	a0,a0,0xd
    80006016:	0c2017b7          	lui	a5,0xc201
    8000601a:	97aa                	add	a5,a5,a0
    8000601c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006020:	60a2                	ld	ra,8(sp)
    80006022:	6402                	ld	s0,0(sp)
    80006024:	0141                	addi	sp,sp,16
    80006026:	8082                	ret

0000000080006028 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void)
{
    80006028:	1141                	addi	sp,sp,-16
    8000602a:	e406                	sd	ra,8(sp)
    8000602c:	e022                	sd	s0,0(sp)
    8000602e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006030:	ffffc097          	auipc	ra,0xffffc
    80006034:	950080e7          	jalr	-1712(ra) # 80001980 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80006038:	00d5151b          	slliw	a0,a0,0xd
    8000603c:	0c2017b7          	lui	a5,0xc201
    80006040:	97aa                	add	a5,a5,a0
  return irq;
}
    80006042:	43c8                	lw	a0,4(a5)
    80006044:	60a2                	ld	ra,8(sp)
    80006046:	6402                	ld	s0,0(sp)
    80006048:	0141                	addi	sp,sp,16
    8000604a:	8082                	ret

000000008000604c <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq)
{
    8000604c:	1101                	addi	sp,sp,-32
    8000604e:	ec06                	sd	ra,24(sp)
    80006050:	e822                	sd	s0,16(sp)
    80006052:	e426                	sd	s1,8(sp)
    80006054:	1000                	addi	s0,sp,32
    80006056:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	928080e7          	jalr	-1752(ra) # 80001980 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80006060:	00d5151b          	slliw	a0,a0,0xd
    80006064:	0c2017b7          	lui	a5,0xc201
    80006068:	97aa                	add	a5,a5,a0
    8000606a:	c3c4                	sw	s1,4(a5)
}
    8000606c:	60e2                	ld	ra,24(sp)
    8000606e:	6442                	ld	s0,16(sp)
    80006070:	64a2                	ld	s1,8(sp)
    80006072:	6105                	addi	sp,sp,32
    80006074:	8082                	ret

0000000080006076 <sgenrand>:
static unsigned long mt[N]; /* the array for the state vector  */
static int mti = N + 1;     /* mti==N+1 means mt[N] is not initialized */

/* initializing the array with a NONZERO seed */
void sgenrand(unsigned long seed)
{
    80006076:	1141                	addi	sp,sp,-16
    80006078:	e422                	sd	s0,8(sp)
    8000607a:	0800                	addi	s0,sp,16
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0] = seed & 0xffffffff;
    8000607c:	0001e717          	auipc	a4,0x1e
    80006080:	c0c70713          	addi	a4,a4,-1012 # 80023c88 <mt>
    80006084:	1502                	slli	a0,a0,0x20
    80006086:	9101                	srli	a0,a0,0x20
    80006088:	e308                	sd	a0,0(a4)
    for (mti = 1; mti < N; mti++)
    8000608a:	0001f597          	auipc	a1,0x1f
    8000608e:	f7658593          	addi	a1,a1,-138 # 80025000 <mt+0x1378>
        mt[mti] = (69069 * mt[mti - 1]) & 0xffffffff;
    80006092:	6645                	lui	a2,0x11
    80006094:	dcd60613          	addi	a2,a2,-563 # 10dcd <_entry-0x7ffef233>
    80006098:	56fd                	li	a3,-1
    8000609a:	9281                	srli	a3,a3,0x20
    8000609c:	631c                	ld	a5,0(a4)
    8000609e:	02c787b3          	mul	a5,a5,a2
    800060a2:	8ff5                	and	a5,a5,a3
    800060a4:	e71c                	sd	a5,8(a4)
    for (mti = 1; mti < N; mti++)
    800060a6:	0721                	addi	a4,a4,8
    800060a8:	feb71ae3          	bne	a4,a1,8000609c <sgenrand+0x26>
    800060ac:	27000793          	li	a5,624
    800060b0:	00002717          	auipc	a4,0x2
    800060b4:	7cf72c23          	sw	a5,2008(a4) # 80008888 <mti>
}
    800060b8:	6422                	ld	s0,8(sp)
    800060ba:	0141                	addi	sp,sp,16
    800060bc:	8082                	ret

00000000800060be <genrand>:

long /* for integer generation */
genrand()
{
    800060be:	1141                	addi	sp,sp,-16
    800060c0:	e406                	sd	ra,8(sp)
    800060c2:	e022                	sd	s0,0(sp)
    800060c4:	0800                	addi	s0,sp,16
    unsigned long y;
    static unsigned long mag01[2] = {0x0, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N)
    800060c6:	00002797          	auipc	a5,0x2
    800060ca:	7c27a783          	lw	a5,1986(a5) # 80008888 <mti>
    800060ce:	26f00713          	li	a4,623
    800060d2:	0ef75963          	bge	a4,a5,800061c4 <genrand+0x106>
    { /* generate N words at one time */
        int kk;

        if (mti == N + 1)   /* if sgenrand() has not been called, */
    800060d6:	27100713          	li	a4,625
    800060da:	12e78e63          	beq	a5,a4,80006216 <genrand+0x158>
            sgenrand(4357); /* a default initial seed is used   */

        for (kk = 0; kk < N - M; kk++)
    800060de:	0001e817          	auipc	a6,0x1e
    800060e2:	baa80813          	addi	a6,a6,-1110 # 80023c88 <mt>
    800060e6:	0001ee17          	auipc	t3,0x1e
    800060ea:	2bae0e13          	addi	t3,t3,698 # 800243a0 <mt+0x718>
{
    800060ee:	8742                	mv	a4,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800060f0:	4885                	li	a7,1
    800060f2:	08fe                	slli	a7,a7,0x1f
    800060f4:	80000537          	lui	a0,0x80000
    800060f8:	fff54513          	not	a0,a0
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    800060fc:	6585                	lui	a1,0x1
    800060fe:	c6858593          	addi	a1,a1,-920 # c68 <_entry-0x7ffff398>
    80006102:	00002317          	auipc	t1,0x2
    80006106:	65e30313          	addi	t1,t1,1630 # 80008760 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    8000610a:	631c                	ld	a5,0(a4)
    8000610c:	0117f7b3          	and	a5,a5,a7
    80006110:	6714                	ld	a3,8(a4)
    80006112:	8ee9                	and	a3,a3,a0
    80006114:	8fd5                	or	a5,a5,a3
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    80006116:	00b70633          	add	a2,a4,a1
    8000611a:	0017d693          	srli	a3,a5,0x1
    8000611e:	6210                	ld	a2,0(a2)
    80006120:	8eb1                	xor	a3,a3,a2
    80006122:	8b85                	andi	a5,a5,1
    80006124:	078e                	slli	a5,a5,0x3
    80006126:	979a                	add	a5,a5,t1
    80006128:	639c                	ld	a5,0(a5)
    8000612a:	8fb5                	xor	a5,a5,a3
    8000612c:	e31c                	sd	a5,0(a4)
        for (kk = 0; kk < N - M; kk++)
    8000612e:	0721                	addi	a4,a4,8
    80006130:	fdc71de3          	bne	a4,t3,8000610a <genrand+0x4c>
        }
        for (; kk < N - 1; kk++)
    80006134:	6605                	lui	a2,0x1
    80006136:	c6060613          	addi	a2,a2,-928 # c60 <_entry-0x7ffff3a0>
    8000613a:	9642                	add	a2,a2,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    8000613c:	4505                	li	a0,1
    8000613e:	057e                	slli	a0,a0,0x1f
    80006140:	800005b7          	lui	a1,0x80000
    80006144:	fff5c593          	not	a1,a1
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    80006148:	00002897          	auipc	a7,0x2
    8000614c:	61888893          	addi	a7,a7,1560 # 80008760 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    80006150:	71883783          	ld	a5,1816(a6)
    80006154:	8fe9                	and	a5,a5,a0
    80006156:	72083703          	ld	a4,1824(a6)
    8000615a:	8f6d                	and	a4,a4,a1
    8000615c:	8fd9                	or	a5,a5,a4
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    8000615e:	0017d713          	srli	a4,a5,0x1
    80006162:	00083683          	ld	a3,0(a6)
    80006166:	8f35                	xor	a4,a4,a3
    80006168:	8b85                	andi	a5,a5,1
    8000616a:	078e                	slli	a5,a5,0x3
    8000616c:	97c6                	add	a5,a5,a7
    8000616e:	639c                	ld	a5,0(a5)
    80006170:	8fb9                	xor	a5,a5,a4
    80006172:	70f83c23          	sd	a5,1816(a6)
        for (; kk < N - 1; kk++)
    80006176:	0821                	addi	a6,a6,8
    80006178:	fcc81ce3          	bne	a6,a2,80006150 <genrand+0x92>
        }
        y = (mt[N - 1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
    8000617c:	0001f697          	auipc	a3,0x1f
    80006180:	b0c68693          	addi	a3,a3,-1268 # 80024c88 <mt+0x1000>
    80006184:	3786b783          	ld	a5,888(a3)
    80006188:	4705                	li	a4,1
    8000618a:	077e                	slli	a4,a4,0x1f
    8000618c:	8ff9                	and	a5,a5,a4
    8000618e:	0001e717          	auipc	a4,0x1e
    80006192:	afa73703          	ld	a4,-1286(a4) # 80023c88 <mt>
    80006196:	1706                	slli	a4,a4,0x21
    80006198:	9305                	srli	a4,a4,0x21
    8000619a:	8fd9                	or	a5,a5,a4
        mt[N - 1] = mt[M - 1] ^ (y >> 1) ^ mag01[y & 0x1];
    8000619c:	0017d713          	srli	a4,a5,0x1
    800061a0:	c606b603          	ld	a2,-928(a3)
    800061a4:	8f31                	xor	a4,a4,a2
    800061a6:	8b85                	andi	a5,a5,1
    800061a8:	078e                	slli	a5,a5,0x3
    800061aa:	00002617          	auipc	a2,0x2
    800061ae:	5b660613          	addi	a2,a2,1462 # 80008760 <mag01.0>
    800061b2:	97b2                	add	a5,a5,a2
    800061b4:	639c                	ld	a5,0(a5)
    800061b6:	8fb9                	xor	a5,a5,a4
    800061b8:	36f6bc23          	sd	a5,888(a3)

        mti = 0;
    800061bc:	00002797          	auipc	a5,0x2
    800061c0:	6c07a623          	sw	zero,1740(a5) # 80008888 <mti>
    }

    y = mt[mti++];
    800061c4:	00002717          	auipc	a4,0x2
    800061c8:	6c470713          	addi	a4,a4,1732 # 80008888 <mti>
    800061cc:	431c                	lw	a5,0(a4)
    800061ce:	0017869b          	addiw	a3,a5,1
    800061d2:	c314                	sw	a3,0(a4)
    800061d4:	078e                	slli	a5,a5,0x3
    800061d6:	0001e717          	auipc	a4,0x1e
    800061da:	ab270713          	addi	a4,a4,-1358 # 80023c88 <mt>
    800061de:	97ba                	add	a5,a5,a4
    800061e0:	639c                	ld	a5,0(a5)
    y ^= TEMPERING_SHIFT_U(y);
    800061e2:	00b7d713          	srli	a4,a5,0xb
    800061e6:	8f3d                	xor	a4,a4,a5
    y ^= TEMPERING_SHIFT_S(y) & TEMPERING_MASK_B;
    800061e8:	013a67b7          	lui	a5,0x13a6
    800061ec:	8ad78793          	addi	a5,a5,-1875 # 13a58ad <_entry-0x7ec5a753>
    800061f0:	8ff9                	and	a5,a5,a4
    800061f2:	079e                	slli	a5,a5,0x7
    800061f4:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_T(y) & TEMPERING_MASK_C;
    800061f6:	00f79713          	slli	a4,a5,0xf
    800061fa:	077e36b7          	lui	a3,0x77e3
    800061fe:	0696                	slli	a3,a3,0x5
    80006200:	8f75                	and	a4,a4,a3
    80006202:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_L(y);
    80006204:	0127d513          	srli	a0,a5,0x12
    80006208:	8d3d                	xor	a0,a0,a5

    // Strip off uppermost bit because we want a long,
    // not an unsigned long
    return y & RAND_MAX;
    8000620a:	1506                	slli	a0,a0,0x21
}
    8000620c:	9105                	srli	a0,a0,0x21
    8000620e:	60a2                	ld	ra,8(sp)
    80006210:	6402                	ld	s0,0(sp)
    80006212:	0141                	addi	sp,sp,16
    80006214:	8082                	ret
            sgenrand(4357); /* a default initial seed is used   */
    80006216:	6505                	lui	a0,0x1
    80006218:	10550513          	addi	a0,a0,261 # 1105 <_entry-0x7fffeefb>
    8000621c:	00000097          	auipc	ra,0x0
    80006220:	e5a080e7          	jalr	-422(ra) # 80006076 <sgenrand>
    80006224:	bd6d                	j	800060de <genrand+0x20>

0000000080006226 <random_at_most>:

// Assumes 0 <= max <= RAND_MAX
// Returns in the half-open interval [0, max]
long random_at_most(long max)
{
    80006226:	1101                	addi	sp,sp,-32
    80006228:	ec06                	sd	ra,24(sp)
    8000622a:	e822                	sd	s0,16(sp)
    8000622c:	e426                	sd	s1,8(sp)
    8000622e:	e04a                	sd	s2,0(sp)
    80006230:	1000                	addi	s0,sp,32
    unsigned long
        // max <= RAND_MAX < ULONG_MAX, so this is okay.
        num_bins = (unsigned long)max + 1,
    80006232:	0505                	addi	a0,a0,1
        num_rand = (unsigned long)RAND_MAX + 1,
        bin_size = num_rand / num_bins,
    80006234:	4785                	li	a5,1
    80006236:	07fe                	slli	a5,a5,0x1f
    80006238:	02a7d933          	divu	s2,a5,a0
        defect = num_rand % num_bins;
    8000623c:	02a7f7b3          	remu	a5,a5,a0
    do
    {
        x = genrand();
    }
    // This is carefully written not to overflow
    while (num_rand - defect <= (unsigned long)x);
    80006240:	4485                	li	s1,1
    80006242:	04fe                	slli	s1,s1,0x1f
    80006244:	8c9d                	sub	s1,s1,a5
        x = genrand();
    80006246:	00000097          	auipc	ra,0x0
    8000624a:	e78080e7          	jalr	-392(ra) # 800060be <genrand>
    while (num_rand - defect <= (unsigned long)x);
    8000624e:	fe957ce3          	bgeu	a0,s1,80006246 <random_at_most+0x20>

    // Truncated division is intentional
    return x / bin_size;
    80006252:	03255533          	divu	a0,a0,s2
    80006256:	60e2                	ld	ra,24(sp)
    80006258:	6442                	ld	s0,16(sp)
    8000625a:	64a2                	ld	s1,8(sp)
    8000625c:	6902                	ld	s2,0(sp)
    8000625e:	6105                	addi	sp,sp,32
    80006260:	8082                	ret

0000000080006262 <popfront>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void popfront(deque *a)
{
    80006262:	1141                	addi	sp,sp,-16
    80006264:	e422                	sd	s0,8(sp)
    80006266:	0800                	addi	s0,sp,16
    for (int i = 0; i < a->end - 1; i++)
    80006268:	20052683          	lw	a3,512(a0)
    8000626c:	fff6861b          	addiw	a2,a3,-1 # 77e2fff <_entry-0x7881d001>
    80006270:	0006079b          	sext.w	a5,a2
    80006274:	cf99                	beqz	a5,80006292 <popfront+0x30>
    80006276:	87aa                	mv	a5,a0
    80006278:	36f9                	addiw	a3,a3,-2
    8000627a:	02069713          	slli	a4,a3,0x20
    8000627e:	01d75693          	srli	a3,a4,0x1d
    80006282:	00850713          	addi	a4,a0,8
    80006286:	96ba                	add	a3,a3,a4
    {
        a->n[i] = a->n[i + 1];
    80006288:	6798                	ld	a4,8(a5)
    8000628a:	e398                	sd	a4,0(a5)
    for (int i = 0; i < a->end - 1; i++)
    8000628c:	07a1                	addi	a5,a5,8
    8000628e:	fed79de3          	bne	a5,a3,80006288 <popfront+0x26>
    }
    a->end--;
    80006292:	20c52023          	sw	a2,512(a0)
    return;
}
    80006296:	6422                	ld	s0,8(sp)
    80006298:	0141                	addi	sp,sp,16
    8000629a:	8082                	ret

000000008000629c <pushback>:
void pushback(deque *a, struct proc *x)
{
    if (a->end == NPROC)
    8000629c:	20052783          	lw	a5,512(a0)
    800062a0:	04000713          	li	a4,64
    800062a4:	00e78c63          	beq	a5,a4,800062bc <pushback+0x20>
    {
        panic("Error!");
        return;
    }
    a->n[a->end] = x;
    800062a8:	02079693          	slli	a3,a5,0x20
    800062ac:	01d6d713          	srli	a4,a3,0x1d
    800062b0:	972a                	add	a4,a4,a0
    800062b2:	e30c                	sd	a1,0(a4)
    a->end++;
    800062b4:	2785                	addiw	a5,a5,1
    800062b6:	20f52023          	sw	a5,512(a0)
    800062ba:	8082                	ret
{
    800062bc:	1141                	addi	sp,sp,-16
    800062be:	e406                	sd	ra,8(sp)
    800062c0:	e022                	sd	s0,0(sp)
    800062c2:	0800                	addi	s0,sp,16
        panic("Error!");
    800062c4:	00002517          	auipc	a0,0x2
    800062c8:	4ac50513          	addi	a0,a0,1196 # 80008770 <mag01.0+0x10>
    800062cc:	ffffa097          	auipc	ra,0xffffa
    800062d0:	274080e7          	jalr	628(ra) # 80000540 <panic>

00000000800062d4 <front>:
    return;
}
struct proc *front(deque *a)
{
    800062d4:	1141                	addi	sp,sp,-16
    800062d6:	e422                	sd	s0,8(sp)
    800062d8:	0800                	addi	s0,sp,16
    if (a->end == 0)
    800062da:	20052783          	lw	a5,512(a0)
    800062de:	c789                	beqz	a5,800062e8 <front+0x14>
    {
        return 0;
    }
    return a->n[0];
    800062e0:	6108                	ld	a0,0(a0)
}
    800062e2:	6422                	ld	s0,8(sp)
    800062e4:	0141                	addi	sp,sp,16
    800062e6:	8082                	ret
        return 0;
    800062e8:	4501                	li	a0,0
    800062ea:	bfe5                	j	800062e2 <front+0xe>

00000000800062ec <size>:
int size(deque *a)
{
    800062ec:	1141                	addi	sp,sp,-16
    800062ee:	e422                	sd	s0,8(sp)
    800062f0:	0800                	addi	s0,sp,16
    return a->end;
}
    800062f2:	20052503          	lw	a0,512(a0)
    800062f6:	6422                	ld	s0,8(sp)
    800062f8:	0141                	addi	sp,sp,16
    800062fa:	8082                	ret

00000000800062fc <delete>:
void delete (deque *a, uint pid)
{
    800062fc:	1141                	addi	sp,sp,-16
    800062fe:	e422                	sd	s0,8(sp)
    80006300:	0800                	addi	s0,sp,16
    int flag = 0;
    for (int i = 0; i < a->end; i++)
    80006302:	20052e03          	lw	t3,512(a0)
    80006306:	020e0c63          	beqz	t3,8000633e <delete+0x42>
    8000630a:	87aa                	mv	a5,a0
    8000630c:	000e031b          	sext.w	t1,t3
    80006310:	4701                	li	a4,0
    int flag = 0;
    80006312:	4881                	li	a7,0
    {
        if (pid == a->n[i]->pid)
        {
            flag = 1;
        }
        if (flag == 1 && i != NPROC)
    80006314:	04000e93          	li	t4,64
    80006318:	4805                	li	a6,1
    8000631a:	a811                	j	8000632e <delete+0x32>
    8000631c:	88c2                	mv	a7,a6
    8000631e:	01d70463          	beq	a4,t4,80006326 <delete+0x2a>
        {
            a->n[i] = a->n[i + 1];
    80006322:	6614                	ld	a3,8(a2)
    80006324:	e214                	sd	a3,0(a2)
    for (int i = 0; i < a->end; i++)
    80006326:	2705                	addiw	a4,a4,1
    80006328:	07a1                	addi	a5,a5,8
    8000632a:	00670a63          	beq	a4,t1,8000633e <delete+0x42>
        if (pid == a->n[i]->pid)
    8000632e:	863e                	mv	a2,a5
    80006330:	6394                	ld	a3,0(a5)
    80006332:	5a94                	lw	a3,48(a3)
    80006334:	feb684e3          	beq	a3,a1,8000631c <delete+0x20>
        if (flag == 1 && i != NPROC)
    80006338:	ff0897e3          	bne	a7,a6,80006326 <delete+0x2a>
    8000633c:	b7c5                	j	8000631c <delete+0x20>
        }
    }
    a->end--;
    8000633e:	3e7d                	addiw	t3,t3,-1
    80006340:	21c52023          	sw	t3,512(a0)
    return;
    80006344:	6422                	ld	s0,8(sp)
    80006346:	0141                	addi	sp,sp,16
    80006348:	8082                	ret

000000008000634a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000634a:	1141                	addi	sp,sp,-16
    8000634c:	e406                	sd	ra,8(sp)
    8000634e:	e022                	sd	s0,0(sp)
    80006350:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80006352:	479d                	li	a5,7
    80006354:	04a7cc63          	blt	a5,a0,800063ac <free_desc+0x62>
    panic("free_desc 1");
  if (disk.free[i])
    80006358:	0001f797          	auipc	a5,0x1f
    8000635c:	cb078793          	addi	a5,a5,-848 # 80025008 <disk>
    80006360:	97aa                	add	a5,a5,a0
    80006362:	0187c783          	lbu	a5,24(a5)
    80006366:	ebb9                	bnez	a5,800063bc <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006368:	00451693          	slli	a3,a0,0x4
    8000636c:	0001f797          	auipc	a5,0x1f
    80006370:	c9c78793          	addi	a5,a5,-868 # 80025008 <disk>
    80006374:	6398                	ld	a4,0(a5)
    80006376:	9736                	add	a4,a4,a3
    80006378:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000637c:	6398                	ld	a4,0(a5)
    8000637e:	9736                	add	a4,a4,a3
    80006380:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006384:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006388:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000638c:	97aa                	add	a5,a5,a0
    8000638e:	4705                	li	a4,1
    80006390:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006394:	0001f517          	auipc	a0,0x1f
    80006398:	c8c50513          	addi	a0,a0,-884 # 80025020 <disk+0x18>
    8000639c:	ffffc097          	auipc	ra,0xffffc
    800063a0:	dc0080e7          	jalr	-576(ra) # 8000215c <wakeup>
}
    800063a4:	60a2                	ld	ra,8(sp)
    800063a6:	6402                	ld	s0,0(sp)
    800063a8:	0141                	addi	sp,sp,16
    800063aa:	8082                	ret
    panic("free_desc 1");
    800063ac:	00002517          	auipc	a0,0x2
    800063b0:	3cc50513          	addi	a0,a0,972 # 80008778 <mag01.0+0x18>
    800063b4:	ffffa097          	auipc	ra,0xffffa
    800063b8:	18c080e7          	jalr	396(ra) # 80000540 <panic>
    panic("free_desc 2");
    800063bc:	00002517          	auipc	a0,0x2
    800063c0:	3cc50513          	addi	a0,a0,972 # 80008788 <mag01.0+0x28>
    800063c4:	ffffa097          	auipc	ra,0xffffa
    800063c8:	17c080e7          	jalr	380(ra) # 80000540 <panic>

00000000800063cc <virtio_disk_init>:
{
    800063cc:	1101                	addi	sp,sp,-32
    800063ce:	ec06                	sd	ra,24(sp)
    800063d0:	e822                	sd	s0,16(sp)
    800063d2:	e426                	sd	s1,8(sp)
    800063d4:	e04a                	sd	s2,0(sp)
    800063d6:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063d8:	00002597          	auipc	a1,0x2
    800063dc:	3c058593          	addi	a1,a1,960 # 80008798 <mag01.0+0x38>
    800063e0:	0001f517          	auipc	a0,0x1f
    800063e4:	d5050513          	addi	a0,a0,-688 # 80025130 <disk+0x128>
    800063e8:	ffffa097          	auipc	ra,0xffffa
    800063ec:	75e080e7          	jalr	1886(ra) # 80000b46 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063f0:	100017b7          	lui	a5,0x10001
    800063f4:	4398                	lw	a4,0(a5)
    800063f6:	2701                	sext.w	a4,a4
    800063f8:	747277b7          	lui	a5,0x74727
    800063fc:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006400:	14f71b63          	bne	a4,a5,80006556 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006404:	100017b7          	lui	a5,0x10001
    80006408:	43dc                	lw	a5,4(a5)
    8000640a:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000640c:	4709                	li	a4,2
    8000640e:	14e79463          	bne	a5,a4,80006556 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006412:	100017b7          	lui	a5,0x10001
    80006416:	479c                	lw	a5,8(a5)
    80006418:	2781                	sext.w	a5,a5
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000641a:	12e79e63          	bne	a5,a4,80006556 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551)
    8000641e:	100017b7          	lui	a5,0x10001
    80006422:	47d8                	lw	a4,12(a5)
    80006424:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006426:	554d47b7          	lui	a5,0x554d4
    8000642a:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000642e:	12f71463          	bne	a4,a5,80006556 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006432:	100017b7          	lui	a5,0x10001
    80006436:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000643a:	4705                	li	a4,1
    8000643c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000643e:	470d                	li	a4,3
    80006440:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006442:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006444:	c7ffe6b7          	lui	a3,0xc7ffe
    80006448:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9617>
    8000644c:	8f75                	and	a4,a4,a3
    8000644e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006450:	472d                	li	a4,11
    80006452:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006454:	5bbc                	lw	a5,112(a5)
    80006456:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000645a:	8ba1                	andi	a5,a5,8
    8000645c:	10078563          	beqz	a5,80006566 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006460:	100017b7          	lui	a5,0x10001
    80006464:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80006468:	43fc                	lw	a5,68(a5)
    8000646a:	2781                	sext.w	a5,a5
    8000646c:	10079563          	bnez	a5,80006576 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006470:	100017b7          	lui	a5,0x10001
    80006474:	5bdc                	lw	a5,52(a5)
    80006476:	2781                	sext.w	a5,a5
  if (max == 0)
    80006478:	10078763          	beqz	a5,80006586 <virtio_disk_init+0x1ba>
  if (max < NUM)
    8000647c:	471d                	li	a4,7
    8000647e:	10f77c63          	bgeu	a4,a5,80006596 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80006482:	ffffa097          	auipc	ra,0xffffa
    80006486:	664080e7          	jalr	1636(ra) # 80000ae6 <kalloc>
    8000648a:	0001f497          	auipc	s1,0x1f
    8000648e:	b7e48493          	addi	s1,s1,-1154 # 80025008 <disk>
    80006492:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006494:	ffffa097          	auipc	ra,0xffffa
    80006498:	652080e7          	jalr	1618(ra) # 80000ae6 <kalloc>
    8000649c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000649e:	ffffa097          	auipc	ra,0xffffa
    800064a2:	648080e7          	jalr	1608(ra) # 80000ae6 <kalloc>
    800064a6:	87aa                	mv	a5,a0
    800064a8:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800064aa:	6088                	ld	a0,0(s1)
    800064ac:	cd6d                	beqz	a0,800065a6 <virtio_disk_init+0x1da>
    800064ae:	0001f717          	auipc	a4,0x1f
    800064b2:	b6273703          	ld	a4,-1182(a4) # 80025010 <disk+0x8>
    800064b6:	cb65                	beqz	a4,800065a6 <virtio_disk_init+0x1da>
    800064b8:	c7fd                	beqz	a5,800065a6 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800064ba:	6605                	lui	a2,0x1
    800064bc:	4581                	li	a1,0
    800064be:	ffffb097          	auipc	ra,0xffffb
    800064c2:	814080e7          	jalr	-2028(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800064c6:	0001f497          	auipc	s1,0x1f
    800064ca:	b4248493          	addi	s1,s1,-1214 # 80025008 <disk>
    800064ce:	6605                	lui	a2,0x1
    800064d0:	4581                	li	a1,0
    800064d2:	6488                	ld	a0,8(s1)
    800064d4:	ffffa097          	auipc	ra,0xffffa
    800064d8:	7fe080e7          	jalr	2046(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800064dc:	6605                	lui	a2,0x1
    800064de:	4581                	li	a1,0
    800064e0:	6888                	ld	a0,16(s1)
    800064e2:	ffffa097          	auipc	ra,0xffffa
    800064e6:	7f0080e7          	jalr	2032(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800064ea:	100017b7          	lui	a5,0x10001
    800064ee:	4721                	li	a4,8
    800064f0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800064f2:	4098                	lw	a4,0(s1)
    800064f4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800064f8:	40d8                	lw	a4,4(s1)
    800064fa:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800064fe:	6498                	ld	a4,8(s1)
    80006500:	0007069b          	sext.w	a3,a4
    80006504:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006508:	9701                	srai	a4,a4,0x20
    8000650a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000650e:	6898                	ld	a4,16(s1)
    80006510:	0007069b          	sext.w	a3,a4
    80006514:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006518:	9701                	srai	a4,a4,0x20
    8000651a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000651e:	4705                	li	a4,1
    80006520:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006522:	00e48c23          	sb	a4,24(s1)
    80006526:	00e48ca3          	sb	a4,25(s1)
    8000652a:	00e48d23          	sb	a4,26(s1)
    8000652e:	00e48da3          	sb	a4,27(s1)
    80006532:	00e48e23          	sb	a4,28(s1)
    80006536:	00e48ea3          	sb	a4,29(s1)
    8000653a:	00e48f23          	sb	a4,30(s1)
    8000653e:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006542:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006546:	0727a823          	sw	s2,112(a5)
}
    8000654a:	60e2                	ld	ra,24(sp)
    8000654c:	6442                	ld	s0,16(sp)
    8000654e:	64a2                	ld	s1,8(sp)
    80006550:	6902                	ld	s2,0(sp)
    80006552:	6105                	addi	sp,sp,32
    80006554:	8082                	ret
    panic("could not find virtio disk");
    80006556:	00002517          	auipc	a0,0x2
    8000655a:	25250513          	addi	a0,a0,594 # 800087a8 <mag01.0+0x48>
    8000655e:	ffffa097          	auipc	ra,0xffffa
    80006562:	fe2080e7          	jalr	-30(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006566:	00002517          	auipc	a0,0x2
    8000656a:	26250513          	addi	a0,a0,610 # 800087c8 <mag01.0+0x68>
    8000656e:	ffffa097          	auipc	ra,0xffffa
    80006572:	fd2080e7          	jalr	-46(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006576:	00002517          	auipc	a0,0x2
    8000657a:	27250513          	addi	a0,a0,626 # 800087e8 <mag01.0+0x88>
    8000657e:	ffffa097          	auipc	ra,0xffffa
    80006582:	fc2080e7          	jalr	-62(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006586:	00002517          	auipc	a0,0x2
    8000658a:	28250513          	addi	a0,a0,642 # 80008808 <mag01.0+0xa8>
    8000658e:	ffffa097          	auipc	ra,0xffffa
    80006592:	fb2080e7          	jalr	-78(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006596:	00002517          	auipc	a0,0x2
    8000659a:	29250513          	addi	a0,a0,658 # 80008828 <mag01.0+0xc8>
    8000659e:	ffffa097          	auipc	ra,0xffffa
    800065a2:	fa2080e7          	jalr	-94(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800065a6:	00002517          	auipc	a0,0x2
    800065aa:	2a250513          	addi	a0,a0,674 # 80008848 <mag01.0+0xe8>
    800065ae:	ffffa097          	auipc	ra,0xffffa
    800065b2:	f92080e7          	jalr	-110(ra) # 80000540 <panic>

00000000800065b6 <virtio_disk_rw>:
  }
  return 0;
}

void virtio_disk_rw(struct buf *b, int write)
{
    800065b6:	7119                	addi	sp,sp,-128
    800065b8:	fc86                	sd	ra,120(sp)
    800065ba:	f8a2                	sd	s0,112(sp)
    800065bc:	f4a6                	sd	s1,104(sp)
    800065be:	f0ca                	sd	s2,96(sp)
    800065c0:	ecce                	sd	s3,88(sp)
    800065c2:	e8d2                	sd	s4,80(sp)
    800065c4:	e4d6                	sd	s5,72(sp)
    800065c6:	e0da                	sd	s6,64(sp)
    800065c8:	fc5e                	sd	s7,56(sp)
    800065ca:	f862                	sd	s8,48(sp)
    800065cc:	f466                	sd	s9,40(sp)
    800065ce:	f06a                	sd	s10,32(sp)
    800065d0:	ec6e                	sd	s11,24(sp)
    800065d2:	0100                	addi	s0,sp,128
    800065d4:	8aaa                	mv	s5,a0
    800065d6:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065d8:	00c52d03          	lw	s10,12(a0)
    800065dc:	001d1d1b          	slliw	s10,s10,0x1
    800065e0:	1d02                	slli	s10,s10,0x20
    800065e2:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800065e6:	0001f517          	auipc	a0,0x1f
    800065ea:	b4a50513          	addi	a0,a0,-1206 # 80025130 <disk+0x128>
    800065ee:	ffffa097          	auipc	ra,0xffffa
    800065f2:	5e8080e7          	jalr	1512(ra) # 80000bd6 <acquire>
  for (int i = 0; i < 3; i++)
    800065f6:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++)
    800065f8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800065fa:	0001fb97          	auipc	s7,0x1f
    800065fe:	a0eb8b93          	addi	s7,s7,-1522 # 80025008 <disk>
  for (int i = 0; i < 3; i++)
    80006602:	4b0d                	li	s6,3
  {
    if (alloc3_desc(idx) == 0)
    {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006604:	0001fc97          	auipc	s9,0x1f
    80006608:	b2cc8c93          	addi	s9,s9,-1236 # 80025130 <disk+0x128>
    8000660c:	a08d                	j	8000666e <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000660e:	00fb8733          	add	a4,s7,a5
    80006612:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006616:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0)
    80006618:	0207c563          	bltz	a5,80006642 <virtio_disk_rw+0x8c>
  for (int i = 0; i < 3; i++)
    8000661c:	2905                	addiw	s2,s2,1
    8000661e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006620:	05690c63          	beq	s2,s6,80006678 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006624:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++)
    80006626:	0001f717          	auipc	a4,0x1f
    8000662a:	9e270713          	addi	a4,a4,-1566 # 80025008 <disk>
    8000662e:	87ce                	mv	a5,s3
    if (disk.free[i])
    80006630:	01874683          	lbu	a3,24(a4)
    80006634:	fee9                	bnez	a3,8000660e <virtio_disk_rw+0x58>
  for (int i = 0; i < NUM; i++)
    80006636:	2785                	addiw	a5,a5,1
    80006638:	0705                	addi	a4,a4,1
    8000663a:	fe979be3          	bne	a5,s1,80006630 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000663e:	57fd                	li	a5,-1
    80006640:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80006642:	01205d63          	blez	s2,8000665c <virtio_disk_rw+0xa6>
    80006646:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006648:	000a2503          	lw	a0,0(s4)
    8000664c:	00000097          	auipc	ra,0x0
    80006650:	cfe080e7          	jalr	-770(ra) # 8000634a <free_desc>
      for (int j = 0; j < i; j++)
    80006654:	2d85                	addiw	s11,s11,1
    80006656:	0a11                	addi	s4,s4,4
    80006658:	ff2d98e3          	bne	s11,s2,80006648 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000665c:	85e6                	mv	a1,s9
    8000665e:	0001f517          	auipc	a0,0x1f
    80006662:	9c250513          	addi	a0,a0,-1598 # 80025020 <disk+0x18>
    80006666:	ffffc097          	auipc	ra,0xffffc
    8000666a:	a86080e7          	jalr	-1402(ra) # 800020ec <sleep>
  for (int i = 0; i < 3; i++)
    8000666e:	f8040a13          	addi	s4,s0,-128
{
    80006672:	8652                	mv	a2,s4
  for (int i = 0; i < 3; i++)
    80006674:	894e                	mv	s2,s3
    80006676:	b77d                	j	80006624 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006678:	f8042503          	lw	a0,-128(s0)
    8000667c:	00a50713          	addi	a4,a0,10
    80006680:	0712                	slli	a4,a4,0x4

  if (write)
    80006682:	0001f797          	auipc	a5,0x1f
    80006686:	98678793          	addi	a5,a5,-1658 # 80025008 <disk>
    8000668a:	00e786b3          	add	a3,a5,a4
    8000668e:	01803633          	snez	a2,s8
    80006692:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006694:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006698:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64)buf0;
    8000669c:	f6070613          	addi	a2,a4,-160
    800066a0:	6394                	ld	a3,0(a5)
    800066a2:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066a4:	00870593          	addi	a1,a4,8
    800066a8:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    800066aa:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066ac:	0007b803          	ld	a6,0(a5)
    800066b0:	9642                	add	a2,a2,a6
    800066b2:	46c1                	li	a3,16
    800066b4:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066b6:	4585                	li	a1,1
    800066b8:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800066bc:	f8442683          	lw	a3,-124(s0)
    800066c0:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64)b->data;
    800066c4:	0692                	slli	a3,a3,0x4
    800066c6:	9836                	add	a6,a6,a3
    800066c8:	058a8613          	addi	a2,s5,88
    800066cc:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800066d0:	0007b803          	ld	a6,0(a5)
    800066d4:	96c2                	add	a3,a3,a6
    800066d6:	40000613          	li	a2,1024
    800066da:	c690                	sw	a2,8(a3)
  if (write)
    800066dc:	001c3613          	seqz	a2,s8
    800066e0:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800066e4:	00166613          	ori	a2,a2,1
    800066e8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800066ec:	f8842603          	lw	a2,-120(s0)
    800066f0:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066f4:	00250693          	addi	a3,a0,2
    800066f8:	0692                	slli	a3,a3,0x4
    800066fa:	96be                	add	a3,a3,a5
    800066fc:	58fd                	li	a7,-1
    800066fe:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80006702:	0612                	slli	a2,a2,0x4
    80006704:	9832                	add	a6,a6,a2
    80006706:	f9070713          	addi	a4,a4,-112
    8000670a:	973e                	add	a4,a4,a5
    8000670c:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006710:	6398                	ld	a4,0(a5)
    80006712:	9732                	add	a4,a4,a2
    80006714:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006716:	4609                	li	a2,2
    80006718:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    8000671c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006720:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006724:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006728:	6794                	ld	a3,8(a5)
    8000672a:	0026d703          	lhu	a4,2(a3)
    8000672e:	8b1d                	andi	a4,a4,7
    80006730:	0706                	slli	a4,a4,0x1
    80006732:	96ba                	add	a3,a3,a4
    80006734:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006738:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000673c:	6798                	ld	a4,8(a5)
    8000673e:	00275783          	lhu	a5,2(a4)
    80006742:	2785                	addiw	a5,a5,1
    80006744:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006748:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000674c:	100017b7          	lui	a5,0x10001
    80006750:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1)
    80006754:	004aa783          	lw	a5,4(s5)
  {
    sleep(b, &disk.vdisk_lock);
    80006758:	0001f917          	auipc	s2,0x1f
    8000675c:	9d890913          	addi	s2,s2,-1576 # 80025130 <disk+0x128>
  while (b->disk == 1)
    80006760:	4485                	li	s1,1
    80006762:	00b79c63          	bne	a5,a1,8000677a <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006766:	85ca                	mv	a1,s2
    80006768:	8556                	mv	a0,s5
    8000676a:	ffffc097          	auipc	ra,0xffffc
    8000676e:	982080e7          	jalr	-1662(ra) # 800020ec <sleep>
  while (b->disk == 1)
    80006772:	004aa783          	lw	a5,4(s5)
    80006776:	fe9788e3          	beq	a5,s1,80006766 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000677a:	f8042903          	lw	s2,-128(s0)
    8000677e:	00290713          	addi	a4,s2,2
    80006782:	0712                	slli	a4,a4,0x4
    80006784:	0001f797          	auipc	a5,0x1f
    80006788:	88478793          	addi	a5,a5,-1916 # 80025008 <disk>
    8000678c:	97ba                	add	a5,a5,a4
    8000678e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006792:	0001f997          	auipc	s3,0x1f
    80006796:	87698993          	addi	s3,s3,-1930 # 80025008 <disk>
    8000679a:	00491713          	slli	a4,s2,0x4
    8000679e:	0009b783          	ld	a5,0(s3)
    800067a2:	97ba                	add	a5,a5,a4
    800067a4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800067a8:	854a                	mv	a0,s2
    800067aa:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800067ae:	00000097          	auipc	ra,0x0
    800067b2:	b9c080e7          	jalr	-1124(ra) # 8000634a <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    800067b6:	8885                	andi	s1,s1,1
    800067b8:	f0ed                	bnez	s1,8000679a <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800067ba:	0001f517          	auipc	a0,0x1f
    800067be:	97650513          	addi	a0,a0,-1674 # 80025130 <disk+0x128>
    800067c2:	ffffa097          	auipc	ra,0xffffa
    800067c6:	4c8080e7          	jalr	1224(ra) # 80000c8a <release>
}
    800067ca:	70e6                	ld	ra,120(sp)
    800067cc:	7446                	ld	s0,112(sp)
    800067ce:	74a6                	ld	s1,104(sp)
    800067d0:	7906                	ld	s2,96(sp)
    800067d2:	69e6                	ld	s3,88(sp)
    800067d4:	6a46                	ld	s4,80(sp)
    800067d6:	6aa6                	ld	s5,72(sp)
    800067d8:	6b06                	ld	s6,64(sp)
    800067da:	7be2                	ld	s7,56(sp)
    800067dc:	7c42                	ld	s8,48(sp)
    800067de:	7ca2                	ld	s9,40(sp)
    800067e0:	7d02                	ld	s10,32(sp)
    800067e2:	6de2                	ld	s11,24(sp)
    800067e4:	6109                	addi	sp,sp,128
    800067e6:	8082                	ret

00000000800067e8 <virtio_disk_intr>:

void virtio_disk_intr()
{
    800067e8:	1101                	addi	sp,sp,-32
    800067ea:	ec06                	sd	ra,24(sp)
    800067ec:	e822                	sd	s0,16(sp)
    800067ee:	e426                	sd	s1,8(sp)
    800067f0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067f2:	0001f497          	auipc	s1,0x1f
    800067f6:	81648493          	addi	s1,s1,-2026 # 80025008 <disk>
    800067fa:	0001f517          	auipc	a0,0x1f
    800067fe:	93650513          	addi	a0,a0,-1738 # 80025130 <disk+0x128>
    80006802:	ffffa097          	auipc	ra,0xffffa
    80006806:	3d4080e7          	jalr	980(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000680a:	10001737          	lui	a4,0x10001
    8000680e:	533c                	lw	a5,96(a4)
    80006810:	8b8d                	andi	a5,a5,3
    80006812:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006814:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx)
    80006818:	689c                	ld	a5,16(s1)
    8000681a:	0204d703          	lhu	a4,32(s1)
    8000681e:	0027d783          	lhu	a5,2(a5)
    80006822:	04f70863          	beq	a4,a5,80006872 <virtio_disk_intr+0x8a>
  {
    __sync_synchronize();
    80006826:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000682a:	6898                	ld	a4,16(s1)
    8000682c:	0204d783          	lhu	a5,32(s1)
    80006830:	8b9d                	andi	a5,a5,7
    80006832:	078e                	slli	a5,a5,0x3
    80006834:	97ba                	add	a5,a5,a4
    80006836:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80006838:	00278713          	addi	a4,a5,2
    8000683c:	0712                	slli	a4,a4,0x4
    8000683e:	9726                	add	a4,a4,s1
    80006840:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006844:	e721                	bnez	a4,8000688c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006846:	0789                	addi	a5,a5,2
    80006848:	0792                	slli	a5,a5,0x4
    8000684a:	97a6                	add	a5,a5,s1
    8000684c:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    8000684e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006852:	ffffc097          	auipc	ra,0xffffc
    80006856:	90a080e7          	jalr	-1782(ra) # 8000215c <wakeup>

    disk.used_idx += 1;
    8000685a:	0204d783          	lhu	a5,32(s1)
    8000685e:	2785                	addiw	a5,a5,1
    80006860:	17c2                	slli	a5,a5,0x30
    80006862:	93c1                	srli	a5,a5,0x30
    80006864:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx)
    80006868:	6898                	ld	a4,16(s1)
    8000686a:	00275703          	lhu	a4,2(a4)
    8000686e:	faf71ce3          	bne	a4,a5,80006826 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006872:	0001f517          	auipc	a0,0x1f
    80006876:	8be50513          	addi	a0,a0,-1858 # 80025130 <disk+0x128>
    8000687a:	ffffa097          	auipc	ra,0xffffa
    8000687e:	410080e7          	jalr	1040(ra) # 80000c8a <release>
}
    80006882:	60e2                	ld	ra,24(sp)
    80006884:	6442                	ld	s0,16(sp)
    80006886:	64a2                	ld	s1,8(sp)
    80006888:	6105                	addi	sp,sp,32
    8000688a:	8082                	ret
      panic("virtio_disk_intr status");
    8000688c:	00002517          	auipc	a0,0x2
    80006890:	fd450513          	addi	a0,a0,-44 # 80008860 <mag01.0+0x100>
    80006894:	ffffa097          	auipc	ra,0xffffa
    80006898:	cac080e7          	jalr	-852(ra) # 80000540 <panic>
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
