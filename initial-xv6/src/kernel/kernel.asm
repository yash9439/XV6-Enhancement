
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	8c070713          	addi	a4,a4,-1856 # 80008910 <timer_scratch>
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
    80000066:	ede78793          	addi	a5,a5,-290 # 80005f40 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb057>
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
    8000012e:	3e8080e7          	jalr	1000(ra) # 80002512 <either_copyin>
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
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
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
    800001cc:	194080e7          	jalr	404(ra) # 8000235c <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	ed2080e7          	jalr	-302(ra) # 800020a8 <sleep>
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
    80000216:	2aa080e7          	jalr	682(ra) # 800024bc <either_copyout>
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
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
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
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
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
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
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
    800002f6:	276080e7          	jalr	630(ra) # 80002568 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
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
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
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
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
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
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while (cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
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
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
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
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
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
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	cc6080e7          	jalr	-826(ra) # 8000210c <wakeup>
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
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	19878793          	addi	a5,a5,408 # 80022610 <devsw>
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
    80000550:	5c07a223          	sw	zero,1476(a5) # 80010b10 <pr+0x18>
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
    80000584:	34f72823          	sw	a5,848(a4) # 800088d0 <panicked>
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
    800005c0:	554dad83          	lw	s11,1364(s11) # 80010b10 <pr+0x18>
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
    800005fe:	4fe50513          	addi	a0,a0,1278 # 80010af8 <pr>
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
    8000075c:	3a050513          	addi	a0,a0,928 # 80010af8 <pr>
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
    80000778:	38448493          	addi	s1,s1,900 # 80010af8 <pr>
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
    800007d8:	34450513          	addi	a0,a0,836 # 80010b18 <uart_tx_lock>
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
    80000804:	0d07a783          	lw	a5,208(a5) # 800088d0 <panicked>
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
    8000083c:	0a07b783          	ld	a5,160(a5) # 800088d8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0a073703          	ld	a4,160(a4) # 800088e0 <uart_tx_w>
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
    80000866:	2b6a0a13          	addi	s4,s4,694 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	06e48493          	addi	s1,s1,110 # 800088d8 <uart_tx_r>
    if (uart_tx_w == uart_tx_r)
    80000872:	00008997          	auipc	s3,0x8
    80000876:	06e98993          	addi	s3,s3,110 # 800088e0 <uart_tx_w>
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
    80000898:	878080e7          	jalr	-1928(ra) # 8000210c <wakeup>

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
    800008d4:	24850513          	addi	a0,a0,584 # 80010b18 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if (panicked)
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	ff07a783          	lw	a5,-16(a5) # 800088d0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	ff673703          	ld	a4,-10(a4) # 800088e0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	fe67b783          	ld	a5,-26(a5) # 800088d8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	21a98993          	addi	s3,s3,538 # 80010b18 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	fd248493          	addi	s1,s1,-46 # 800088d8 <uart_tx_r>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	fd290913          	addi	s2,s2,-46 # 800088e0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	78a080e7          	jalr	1930(ra) # 800020a8 <sleep>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	1e448493          	addi	s1,s1,484 # 80010b18 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	f8e7bc23          	sd	a4,-104(a5) # 800088e0 <uart_tx_w>
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
    800009be:	15e48493          	addi	s1,s1,350 # 80010b18 <uart_tx_lock>
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
    800009fc:	00023797          	auipc	a5,0x23
    80000a00:	dac78793          	addi	a5,a5,-596 # 800237a8 <end>
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
    80000a20:	13490913          	addi	s2,s2,308 # 80010b50 <kmem>
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
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	cda50513          	addi	a0,a0,-806 # 800237a8 <end>
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
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
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
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
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
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
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
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb859>
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
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
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
    80000ec2:	996080e7          	jalr	-1642(ra) # 80002854 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	0ba080e7          	jalr	186(ra) # 80005f80 <plicinithart>
  }

  scheduler();
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	028080e7          	jalr	40(ra) # 80001ef6 <scheduler>
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
    80000f3a:	8f6080e7          	jalr	-1802(ra) # 8000282c <trapinit>
    trapinithart();     // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	916080e7          	jalr	-1770(ra) # 80002854 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	024080e7          	jalr	36(ra) # 80005f6a <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	032080e7          	jalr	50(ra) # 80005f80 <plicinithart>
    binit();            // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	1d0080e7          	jalr	464(ra) # 80003126 <binit>
    iinit();            // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	870080e7          	jalr	-1936(ra) # 800037ce <iinit>
    fileinit();         // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	816080e7          	jalr	-2026(ra) # 8000477c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	202080e7          	jalr	514(ra) # 80006170 <virtio_disk_init>
    userinit();         // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d62080e7          	jalr	-670(ra) # 80001cd8 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72223          	sw	a5,-1692(a4) # 800088e8 <started>
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
    80000f9c:	9587b783          	ld	a5,-1704(a5) # 800088f0 <kernel_pagetable>
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
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb84f>
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
    80001258:	68a7be23          	sd	a0,1692(a5) # 800088f0 <kernel_pagetable>
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
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdb858>
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
    80001850:	75448493          	addi	s1,s1,1876 # 80010fa0 <proc>
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
    8000186a:	13aa0a13          	addi	s4,s4,314 # 800179a0 <mlfq>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if (pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	858d                	srai	a1,a1,0x3
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
    800018a0:	1a848493          	addi	s1,s1,424
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
    800018ec:	28850513          	addi	a0,a0,648 # 80010b70 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	28850513          	addi	a0,a0,648 # 80010b88 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	69048493          	addi	s1,s1,1680 # 80010fa0 <proc>
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
    80001936:	06e98993          	addi	s3,s3,110 # 800179a0 <mlfq>
    initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	878d                	srai	a5,a5,0x3
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001964:	1a848493          	addi	s1,s1,424
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
    800019a0:	20450513          	addi	a0,a0,516 # 80010ba0 <cpus>
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
    800019c8:	1ac70713          	addi	a4,a4,428 # 80010b70 <pid_lock>
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
    80001a00:	e647a783          	lw	a5,-412(a5) # 80008860 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	e66080e7          	jalr	-410(ra) # 8000286c <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e407a523          	sw	zero,-438(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	d2e080e7          	jalr	-722(ra) # 8000374e <fsinit>
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
    80001a3a:	13a90913          	addi	s2,s2,314 # 80010b70 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e1c78793          	addi	a5,a5,-484 # 80008864 <nextpid>
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
    80001b76:	1984b503          	ld	a0,408(s1)
    80001b7a:	c509                	beqz	a0,80001b84 <freeproc+0x26>
    kfree((void *)p->alarm_trapframe);
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	e6c080e7          	jalr	-404(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b84:	0404bc23          	sd	zero,88(s1)
  p->alarm_trapframe = 0;
    80001b88:	1804bc23          	sd	zero,408(s1)
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
    80001bd8:	3cc48493          	addi	s1,s1,972 # 80010fa0 <proc>
    80001bdc:	00016917          	auipc	s2,0x16
    80001be0:	dc490913          	addi	s2,s2,-572 # 800179a0 <mlfq>
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
    80001bfc:	1a848493          	addi	s1,s1,424
    80001c00:	ff2492e3          	bne	s1,s2,80001be4 <allocproc+0x1c>
  return 0;
    80001c04:	4481                	li	s1,0
    80001c06:	a851                	j	80001c9a <allocproc+0xd2>
  p->pid = allocpid();
    80001c08:	00000097          	auipc	ra,0x0
    80001c0c:	e22080e7          	jalr	-478(ra) # 80001a2a <allocpid>
    80001c10:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c12:	4785                	li	a5,1
    80001c14:	cc9c                	sw	a5,24(s1)
  p->level = 0;
    80001c16:	1604aa23          	sw	zero,372(s1)
  p->change_queue = 1 << p->level;
    80001c1a:	16f4ae23          	sw	a5,380(s1)
  p->in_queue = 0;
    80001c1e:	1604ac23          	sw	zero,376(s1)
  p->enter_ticks = ticks;
    80001c22:	00007797          	auipc	a5,0x7
    80001c26:	cde7a783          	lw	a5,-802(a5) # 80008900 <ticks>
    80001c2a:	18f4a023          	sw	a5,384(s1)
  p->now_ticks = 0;
    80001c2e:	1804aa23          	sw	zero,404(s1)
  p->sigalarm_status = 0;
    80001c32:	1a04a023          	sw	zero,416(s1)
  p->interval = 0;
    80001c36:	1804a823          	sw	zero,400(s1)
  p->handler = -1;
    80001c3a:	57fd                	li	a5,-1
    80001c3c:	18f4b423          	sd	a5,392(s1)
  p->alarm_trapframe = NULL;
    80001c40:	1804bc23          	sd	zero,408(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c44:	fffff097          	auipc	ra,0xfffff
    80001c48:	ea2080e7          	jalr	-350(ra) # 80000ae6 <kalloc>
    80001c4c:	892a                	mv	s2,a0
    80001c4e:	eca8                	sd	a0,88(s1)
    80001c50:	cd21                	beqz	a0,80001ca8 <allocproc+0xe0>
  p->pagetable = proc_pagetable(p);
    80001c52:	8526                	mv	a0,s1
    80001c54:	00000097          	auipc	ra,0x0
    80001c58:	e1c080e7          	jalr	-484(ra) # 80001a70 <proc_pagetable>
    80001c5c:	892a                	mv	s2,a0
    80001c5e:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c60:	c125                	beqz	a0,80001cc0 <allocproc+0xf8>
  memset(&p->context, 0, sizeof(p->context));
    80001c62:	07000613          	li	a2,112
    80001c66:	4581                	li	a1,0
    80001c68:	06048513          	addi	a0,s1,96
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	066080e7          	jalr	102(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c74:	00000797          	auipc	a5,0x0
    80001c78:	d7078793          	addi	a5,a5,-656 # 800019e4 <forkret>
    80001c7c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c7e:	60bc                	ld	a5,64(s1)
    80001c80:	6705                	lui	a4,0x1
    80001c82:	97ba                	add	a5,a5,a4
    80001c84:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c86:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001c8a:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001c8e:	00007797          	auipc	a5,0x7
    80001c92:	c727a783          	lw	a5,-910(a5) # 80008900 <ticks>
    80001c96:	16f4a623          	sw	a5,364(s1)
}
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	60e2                	ld	ra,24(sp)
    80001c9e:	6442                	ld	s0,16(sp)
    80001ca0:	64a2                	ld	s1,8(sp)
    80001ca2:	6902                	ld	s2,0(sp)
    80001ca4:	6105                	addi	sp,sp,32
    80001ca6:	8082                	ret
    freeproc(p);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	eb4080e7          	jalr	-332(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	fffff097          	auipc	ra,0xfffff
    80001cb8:	fd6080e7          	jalr	-42(ra) # 80000c8a <release>
    return 0;
    80001cbc:	84ca                	mv	s1,s2
    80001cbe:	bff1                	j	80001c9a <allocproc+0xd2>
    freeproc(p);
    80001cc0:	8526                	mv	a0,s1
    80001cc2:	00000097          	auipc	ra,0x0
    80001cc6:	e9c080e7          	jalr	-356(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	fbe080e7          	jalr	-66(ra) # 80000c8a <release>
    return 0;
    80001cd4:	84ca                	mv	s1,s2
    80001cd6:	b7d1                	j	80001c9a <allocproc+0xd2>

0000000080001cd8 <userinit>:
{
    80001cd8:	1101                	addi	sp,sp,-32
    80001cda:	ec06                	sd	ra,24(sp)
    80001cdc:	e822                	sd	s0,16(sp)
    80001cde:	e426                	sd	s1,8(sp)
    80001ce0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ce2:	00000097          	auipc	ra,0x0
    80001ce6:	ee6080e7          	jalr	-282(ra) # 80001bc8 <allocproc>
    80001cea:	84aa                	mv	s1,a0
  initproc = p;
    80001cec:	00007797          	auipc	a5,0x7
    80001cf0:	c0a7b623          	sd	a0,-1012(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cf4:	03400613          	li	a2,52
    80001cf8:	00007597          	auipc	a1,0x7
    80001cfc:	b7858593          	addi	a1,a1,-1160 # 80008870 <initcode>
    80001d00:	6928                	ld	a0,80(a0)
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	654080e7          	jalr	1620(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d0a:	6785                	lui	a5,0x1
    80001d0c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d0e:	6cb8                	ld	a4,88(s1)
    80001d10:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d14:	6cb8                	ld	a4,88(s1)
    80001d16:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d18:	4641                	li	a2,16
    80001d1a:	00006597          	auipc	a1,0x6
    80001d1e:	4e658593          	addi	a1,a1,1254 # 80008200 <digits+0x1c0>
    80001d22:	15848513          	addi	a0,s1,344
    80001d26:	fffff097          	auipc	ra,0xfffff
    80001d2a:	0f6080e7          	jalr	246(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d2e:	00006517          	auipc	a0,0x6
    80001d32:	4e250513          	addi	a0,a0,1250 # 80008210 <digits+0x1d0>
    80001d36:	00002097          	auipc	ra,0x2
    80001d3a:	442080e7          	jalr	1090(ra) # 80004178 <namei>
    80001d3e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d42:	478d                	li	a5,3
    80001d44:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d46:	8526                	mv	a0,s1
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	f42080e7          	jalr	-190(ra) # 80000c8a <release>
}
    80001d50:	60e2                	ld	ra,24(sp)
    80001d52:	6442                	ld	s0,16(sp)
    80001d54:	64a2                	ld	s1,8(sp)
    80001d56:	6105                	addi	sp,sp,32
    80001d58:	8082                	ret

0000000080001d5a <growproc>:
{
    80001d5a:	1101                	addi	sp,sp,-32
    80001d5c:	ec06                	sd	ra,24(sp)
    80001d5e:	e822                	sd	s0,16(sp)
    80001d60:	e426                	sd	s1,8(sp)
    80001d62:	e04a                	sd	s2,0(sp)
    80001d64:	1000                	addi	s0,sp,32
    80001d66:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d68:	00000097          	auipc	ra,0x0
    80001d6c:	c44080e7          	jalr	-956(ra) # 800019ac <myproc>
    80001d70:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d72:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d74:	01204c63          	bgtz	s2,80001d8c <growproc+0x32>
  else if (n < 0)
    80001d78:	02094663          	bltz	s2,80001da4 <growproc+0x4a>
  p->sz = sz;
    80001d7c:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d7e:	4501                	li	a0,0
}
    80001d80:	60e2                	ld	ra,24(sp)
    80001d82:	6442                	ld	s0,16(sp)
    80001d84:	64a2                	ld	s1,8(sp)
    80001d86:	6902                	ld	s2,0(sp)
    80001d88:	6105                	addi	sp,sp,32
    80001d8a:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001d8c:	4691                	li	a3,4
    80001d8e:	00b90633          	add	a2,s2,a1
    80001d92:	6928                	ld	a0,80(a0)
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	67c080e7          	jalr	1660(ra) # 80001410 <uvmalloc>
    80001d9c:	85aa                	mv	a1,a0
    80001d9e:	fd79                	bnez	a0,80001d7c <growproc+0x22>
      return -1;
    80001da0:	557d                	li	a0,-1
    80001da2:	bff9                	j	80001d80 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001da4:	00b90633          	add	a2,s2,a1
    80001da8:	6928                	ld	a0,80(a0)
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	61e080e7          	jalr	1566(ra) # 800013c8 <uvmdealloc>
    80001db2:	85aa                	mv	a1,a0
    80001db4:	b7e1                	j	80001d7c <growproc+0x22>

0000000080001db6 <fork>:
{
    80001db6:	7139                	addi	sp,sp,-64
    80001db8:	fc06                	sd	ra,56(sp)
    80001dba:	f822                	sd	s0,48(sp)
    80001dbc:	f426                	sd	s1,40(sp)
    80001dbe:	f04a                	sd	s2,32(sp)
    80001dc0:	ec4e                	sd	s3,24(sp)
    80001dc2:	e852                	sd	s4,16(sp)
    80001dc4:	e456                	sd	s5,8(sp)
    80001dc6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dc8:	00000097          	auipc	ra,0x0
    80001dcc:	be4080e7          	jalr	-1052(ra) # 800019ac <myproc>
    80001dd0:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001dd2:	00000097          	auipc	ra,0x0
    80001dd6:	df6080e7          	jalr	-522(ra) # 80001bc8 <allocproc>
    80001dda:	10050c63          	beqz	a0,80001ef2 <fork+0x13c>
    80001dde:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001de0:	048ab603          	ld	a2,72(s5)
    80001de4:	692c                	ld	a1,80(a0)
    80001de6:	050ab503          	ld	a0,80(s5)
    80001dea:	fffff097          	auipc	ra,0xfffff
    80001dee:	77e080e7          	jalr	1918(ra) # 80001568 <uvmcopy>
    80001df2:	04054863          	bltz	a0,80001e42 <fork+0x8c>
  np->sz = p->sz;
    80001df6:	048ab783          	ld	a5,72(s5)
    80001dfa:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dfe:	058ab683          	ld	a3,88(s5)
    80001e02:	87b6                	mv	a5,a3
    80001e04:	058a3703          	ld	a4,88(s4)
    80001e08:	12068693          	addi	a3,a3,288
    80001e0c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e10:	6788                	ld	a0,8(a5)
    80001e12:	6b8c                	ld	a1,16(a5)
    80001e14:	6f90                	ld	a2,24(a5)
    80001e16:	01073023          	sd	a6,0(a4)
    80001e1a:	e708                	sd	a0,8(a4)
    80001e1c:	eb0c                	sd	a1,16(a4)
    80001e1e:	ef10                	sd	a2,24(a4)
    80001e20:	02078793          	addi	a5,a5,32
    80001e24:	02070713          	addi	a4,a4,32
    80001e28:	fed792e3          	bne	a5,a3,80001e0c <fork+0x56>
  np->trapframe->a0 = 0;
    80001e2c:	058a3783          	ld	a5,88(s4)
    80001e30:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e34:	0d0a8493          	addi	s1,s5,208
    80001e38:	0d0a0913          	addi	s2,s4,208
    80001e3c:	150a8993          	addi	s3,s5,336
    80001e40:	a00d                	j	80001e62 <fork+0xac>
    freeproc(np);
    80001e42:	8552                	mv	a0,s4
    80001e44:	00000097          	auipc	ra,0x0
    80001e48:	d1a080e7          	jalr	-742(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e4c:	8552                	mv	a0,s4
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	e3c080e7          	jalr	-452(ra) # 80000c8a <release>
    return -1;
    80001e56:	597d                	li	s2,-1
    80001e58:	a059                	j	80001ede <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80001e5a:	04a1                	addi	s1,s1,8
    80001e5c:	0921                	addi	s2,s2,8
    80001e5e:	01348b63          	beq	s1,s3,80001e74 <fork+0xbe>
    if (p->ofile[i])
    80001e62:	6088                	ld	a0,0(s1)
    80001e64:	d97d                	beqz	a0,80001e5a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e66:	00003097          	auipc	ra,0x3
    80001e6a:	9a8080e7          	jalr	-1624(ra) # 8000480e <filedup>
    80001e6e:	00a93023          	sd	a0,0(s2)
    80001e72:	b7e5                	j	80001e5a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e74:	150ab503          	ld	a0,336(s5)
    80001e78:	00002097          	auipc	ra,0x2
    80001e7c:	b16080e7          	jalr	-1258(ra) # 8000398e <idup>
    80001e80:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e84:	4641                	li	a2,16
    80001e86:	158a8593          	addi	a1,s5,344
    80001e8a:	158a0513          	addi	a0,s4,344
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	f8e080e7          	jalr	-114(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e96:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e9a:	8552                	mv	a0,s4
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	dee080e7          	jalr	-530(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001ea4:	0000f497          	auipc	s1,0xf
    80001ea8:	ce448493          	addi	s1,s1,-796 # 80010b88 <wait_lock>
    80001eac:	8526                	mv	a0,s1
    80001eae:	fffff097          	auipc	ra,0xfffff
    80001eb2:	d28080e7          	jalr	-728(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001eb6:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001eba:	8526                	mv	a0,s1
    80001ebc:	fffff097          	auipc	ra,0xfffff
    80001ec0:	dce080e7          	jalr	-562(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ec4:	8552                	mv	a0,s4
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	d10080e7          	jalr	-752(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001ece:	478d                	li	a5,3
    80001ed0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001ed4:	8552                	mv	a0,s4
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	db4080e7          	jalr	-588(ra) # 80000c8a <release>
}
    80001ede:	854a                	mv	a0,s2
    80001ee0:	70e2                	ld	ra,56(sp)
    80001ee2:	7442                	ld	s0,48(sp)
    80001ee4:	74a2                	ld	s1,40(sp)
    80001ee6:	7902                	ld	s2,32(sp)
    80001ee8:	69e2                	ld	s3,24(sp)
    80001eea:	6a42                	ld	s4,16(sp)
    80001eec:	6aa2                	ld	s5,8(sp)
    80001eee:	6121                	addi	sp,sp,64
    80001ef0:	8082                	ret
    return -1;
    80001ef2:	597d                	li	s2,-1
    80001ef4:	b7ed                	j	80001ede <fork+0x128>

0000000080001ef6 <scheduler>:
{
    80001ef6:	7139                	addi	sp,sp,-64
    80001ef8:	fc06                	sd	ra,56(sp)
    80001efa:	f822                	sd	s0,48(sp)
    80001efc:	f426                	sd	s1,40(sp)
    80001efe:	f04a                	sd	s2,32(sp)
    80001f00:	ec4e                	sd	s3,24(sp)
    80001f02:	e852                	sd	s4,16(sp)
    80001f04:	e456                	sd	s5,8(sp)
    80001f06:	e05a                	sd	s6,0(sp)
    80001f08:	0080                	addi	s0,sp,64
    80001f0a:	8792                	mv	a5,tp
  int id = r_tp();
    80001f0c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f0e:	00779a93          	slli	s5,a5,0x7
    80001f12:	0000f717          	auipc	a4,0xf
    80001f16:	c5e70713          	addi	a4,a4,-930 # 80010b70 <pid_lock>
    80001f1a:	9756                	add	a4,a4,s5
    80001f1c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f20:	0000f717          	auipc	a4,0xf
    80001f24:	c8870713          	addi	a4,a4,-888 # 80010ba8 <cpus+0x8>
    80001f28:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001f2a:	498d                	li	s3,3
        p->state = RUNNING;
    80001f2c:	4b11                	li	s6,4
        c->proc = p;
    80001f2e:	079e                	slli	a5,a5,0x7
    80001f30:	0000fa17          	auipc	s4,0xf
    80001f34:	c40a0a13          	addi	s4,s4,-960 # 80010b70 <pid_lock>
    80001f38:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001f3a:	00016917          	auipc	s2,0x16
    80001f3e:	a6690913          	addi	s2,s2,-1434 # 800179a0 <mlfq>
  asm volatile("csrr %0, sstatus"
    80001f42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80001f4a:	10079073          	csrw	sstatus,a5
    80001f4e:	0000f497          	auipc	s1,0xf
    80001f52:	05248493          	addi	s1,s1,82 # 80010fa0 <proc>
    80001f56:	a811                	j	80001f6a <scheduler+0x74>
      release(&p->lock);
    80001f58:	8526                	mv	a0,s1
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	d30080e7          	jalr	-720(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f62:	1a848493          	addi	s1,s1,424
    80001f66:	fd248ee3          	beq	s1,s2,80001f42 <scheduler+0x4c>
      acquire(&p->lock);
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	c6a080e7          	jalr	-918(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80001f74:	4c9c                	lw	a5,24(s1)
    80001f76:	ff3791e3          	bne	a5,s3,80001f58 <scheduler+0x62>
        p->state = RUNNING;
    80001f7a:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f7e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f82:	06048593          	addi	a1,s1,96
    80001f86:	8556                	mv	a0,s5
    80001f88:	00001097          	auipc	ra,0x1
    80001f8c:	83a080e7          	jalr	-1990(ra) # 800027c2 <swtch>
        c->proc = 0;
    80001f90:	020a3823          	sd	zero,48(s4)
    80001f94:	b7d1                	j	80001f58 <scheduler+0x62>

0000000080001f96 <sched>:
{
    80001f96:	7179                	addi	sp,sp,-48
    80001f98:	f406                	sd	ra,40(sp)
    80001f9a:	f022                	sd	s0,32(sp)
    80001f9c:	ec26                	sd	s1,24(sp)
    80001f9e:	e84a                	sd	s2,16(sp)
    80001fa0:	e44e                	sd	s3,8(sp)
    80001fa2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fa4:	00000097          	auipc	ra,0x0
    80001fa8:	a08080e7          	jalr	-1528(ra) # 800019ac <myproc>
    80001fac:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	bae080e7          	jalr	-1106(ra) # 80000b5c <holding>
    80001fb6:	c93d                	beqz	a0,8000202c <sched+0x96>
  asm volatile("mv %0, tp"
    80001fb8:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001fba:	2781                	sext.w	a5,a5
    80001fbc:	079e                	slli	a5,a5,0x7
    80001fbe:	0000f717          	auipc	a4,0xf
    80001fc2:	bb270713          	addi	a4,a4,-1102 # 80010b70 <pid_lock>
    80001fc6:	97ba                	add	a5,a5,a4
    80001fc8:	0a87a703          	lw	a4,168(a5)
    80001fcc:	4785                	li	a5,1
    80001fce:	06f71763          	bne	a4,a5,8000203c <sched+0xa6>
  if (p->state == RUNNING)
    80001fd2:	4c98                	lw	a4,24(s1)
    80001fd4:	4791                	li	a5,4
    80001fd6:	06f70b63          	beq	a4,a5,8000204c <sched+0xb6>
  asm volatile("csrr %0, sstatus"
    80001fda:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fde:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001fe0:	efb5                	bnez	a5,8000205c <sched+0xc6>
  asm volatile("mv %0, tp"
    80001fe2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fe4:	0000f917          	auipc	s2,0xf
    80001fe8:	b8c90913          	addi	s2,s2,-1140 # 80010b70 <pid_lock>
    80001fec:	2781                	sext.w	a5,a5
    80001fee:	079e                	slli	a5,a5,0x7
    80001ff0:	97ca                	add	a5,a5,s2
    80001ff2:	0ac7a983          	lw	s3,172(a5)
    80001ff6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ff8:	2781                	sext.w	a5,a5
    80001ffa:	079e                	slli	a5,a5,0x7
    80001ffc:	0000f597          	auipc	a1,0xf
    80002000:	bac58593          	addi	a1,a1,-1108 # 80010ba8 <cpus+0x8>
    80002004:	95be                	add	a1,a1,a5
    80002006:	06048513          	addi	a0,s1,96
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	7b8080e7          	jalr	1976(ra) # 800027c2 <swtch>
    80002012:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002014:	2781                	sext.w	a5,a5
    80002016:	079e                	slli	a5,a5,0x7
    80002018:	993e                	add	s2,s2,a5
    8000201a:	0b392623          	sw	s3,172(s2)
}
    8000201e:	70a2                	ld	ra,40(sp)
    80002020:	7402                	ld	s0,32(sp)
    80002022:	64e2                	ld	s1,24(sp)
    80002024:	6942                	ld	s2,16(sp)
    80002026:	69a2                	ld	s3,8(sp)
    80002028:	6145                	addi	sp,sp,48
    8000202a:	8082                	ret
    panic("sched p->lock");
    8000202c:	00006517          	auipc	a0,0x6
    80002030:	1ec50513          	addi	a0,a0,492 # 80008218 <digits+0x1d8>
    80002034:	ffffe097          	auipc	ra,0xffffe
    80002038:	50c080e7          	jalr	1292(ra) # 80000540 <panic>
    panic("sched locks");
    8000203c:	00006517          	auipc	a0,0x6
    80002040:	1ec50513          	addi	a0,a0,492 # 80008228 <digits+0x1e8>
    80002044:	ffffe097          	auipc	ra,0xffffe
    80002048:	4fc080e7          	jalr	1276(ra) # 80000540 <panic>
    panic("sched running");
    8000204c:	00006517          	auipc	a0,0x6
    80002050:	1ec50513          	addi	a0,a0,492 # 80008238 <digits+0x1f8>
    80002054:	ffffe097          	auipc	ra,0xffffe
    80002058:	4ec080e7          	jalr	1260(ra) # 80000540 <panic>
    panic("sched interruptible");
    8000205c:	00006517          	auipc	a0,0x6
    80002060:	1ec50513          	addi	a0,a0,492 # 80008248 <digits+0x208>
    80002064:	ffffe097          	auipc	ra,0xffffe
    80002068:	4dc080e7          	jalr	1244(ra) # 80000540 <panic>

000000008000206c <yield>:
{
    8000206c:	1101                	addi	sp,sp,-32
    8000206e:	ec06                	sd	ra,24(sp)
    80002070:	e822                	sd	s0,16(sp)
    80002072:	e426                	sd	s1,8(sp)
    80002074:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002076:	00000097          	auipc	ra,0x0
    8000207a:	936080e7          	jalr	-1738(ra) # 800019ac <myproc>
    8000207e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	b56080e7          	jalr	-1194(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002088:	478d                	li	a5,3
    8000208a:	cc9c                	sw	a5,24(s1)
  sched();
    8000208c:	00000097          	auipc	ra,0x0
    80002090:	f0a080e7          	jalr	-246(ra) # 80001f96 <sched>
  release(&p->lock);
    80002094:	8526                	mv	a0,s1
    80002096:	fffff097          	auipc	ra,0xfffff
    8000209a:	bf4080e7          	jalr	-1036(ra) # 80000c8a <release>
}
    8000209e:	60e2                	ld	ra,24(sp)
    800020a0:	6442                	ld	s0,16(sp)
    800020a2:	64a2                	ld	s1,8(sp)
    800020a4:	6105                	addi	sp,sp,32
    800020a6:	8082                	ret

00000000800020a8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800020a8:	7179                	addi	sp,sp,-48
    800020aa:	f406                	sd	ra,40(sp)
    800020ac:	f022                	sd	s0,32(sp)
    800020ae:	ec26                	sd	s1,24(sp)
    800020b0:	e84a                	sd	s2,16(sp)
    800020b2:	e44e                	sd	s3,8(sp)
    800020b4:	1800                	addi	s0,sp,48
    800020b6:	89aa                	mv	s3,a0
    800020b8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	8f2080e7          	jalr	-1806(ra) # 800019ac <myproc>
    800020c2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	b12080e7          	jalr	-1262(ra) # 80000bd6 <acquire>
  release(lk);
    800020cc:	854a                	mv	a0,s2
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	bbc080e7          	jalr	-1092(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800020d6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020da:	4789                	li	a5,2
    800020dc:	cc9c                	sw	a5,24(s1)

  sched();
    800020de:	00000097          	auipc	ra,0x0
    800020e2:	eb8080e7          	jalr	-328(ra) # 80001f96 <sched>

  // Tidy up.
  p->chan = 0;
    800020e6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	b9e080e7          	jalr	-1122(ra) # 80000c8a <release>
  acquire(lk);
    800020f4:	854a                	mv	a0,s2
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	ae0080e7          	jalr	-1312(ra) # 80000bd6 <acquire>
}
    800020fe:	70a2                	ld	ra,40(sp)
    80002100:	7402                	ld	s0,32(sp)
    80002102:	64e2                	ld	s1,24(sp)
    80002104:	6942                	ld	s2,16(sp)
    80002106:	69a2                	ld	s3,8(sp)
    80002108:	6145                	addi	sp,sp,48
    8000210a:	8082                	ret

000000008000210c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000210c:	7139                	addi	sp,sp,-64
    8000210e:	fc06                	sd	ra,56(sp)
    80002110:	f822                	sd	s0,48(sp)
    80002112:	f426                	sd	s1,40(sp)
    80002114:	f04a                	sd	s2,32(sp)
    80002116:	ec4e                	sd	s3,24(sp)
    80002118:	e852                	sd	s4,16(sp)
    8000211a:	e456                	sd	s5,8(sp)
    8000211c:	0080                	addi	s0,sp,64
    8000211e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002120:	0000f497          	auipc	s1,0xf
    80002124:	e8048493          	addi	s1,s1,-384 # 80010fa0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002128:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    8000212a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000212c:	00016917          	auipc	s2,0x16
    80002130:	87490913          	addi	s2,s2,-1932 # 800179a0 <mlfq>
    80002134:	a811                	j	80002148 <wakeup+0x3c>
      }
      release(&p->lock);
    80002136:	8526                	mv	a0,s1
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	b52080e7          	jalr	-1198(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002140:	1a848493          	addi	s1,s1,424
    80002144:	03248663          	beq	s1,s2,80002170 <wakeup+0x64>
    if (p != myproc())
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	864080e7          	jalr	-1948(ra) # 800019ac <myproc>
    80002150:	fea488e3          	beq	s1,a0,80002140 <wakeup+0x34>
      acquire(&p->lock);
    80002154:	8526                	mv	a0,s1
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	a80080e7          	jalr	-1408(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000215e:	4c9c                	lw	a5,24(s1)
    80002160:	fd379be3          	bne	a5,s3,80002136 <wakeup+0x2a>
    80002164:	709c                	ld	a5,32(s1)
    80002166:	fd4798e3          	bne	a5,s4,80002136 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000216a:	0154ac23          	sw	s5,24(s1)
    8000216e:	b7e1                	j	80002136 <wakeup+0x2a>
    }
  }
}
    80002170:	70e2                	ld	ra,56(sp)
    80002172:	7442                	ld	s0,48(sp)
    80002174:	74a2                	ld	s1,40(sp)
    80002176:	7902                	ld	s2,32(sp)
    80002178:	69e2                	ld	s3,24(sp)
    8000217a:	6a42                	ld	s4,16(sp)
    8000217c:	6aa2                	ld	s5,8(sp)
    8000217e:	6121                	addi	sp,sp,64
    80002180:	8082                	ret

0000000080002182 <reparent>:
{
    80002182:	7179                	addi	sp,sp,-48
    80002184:	f406                	sd	ra,40(sp)
    80002186:	f022                	sd	s0,32(sp)
    80002188:	ec26                	sd	s1,24(sp)
    8000218a:	e84a                	sd	s2,16(sp)
    8000218c:	e44e                	sd	s3,8(sp)
    8000218e:	e052                	sd	s4,0(sp)
    80002190:	1800                	addi	s0,sp,48
    80002192:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002194:	0000f497          	auipc	s1,0xf
    80002198:	e0c48493          	addi	s1,s1,-500 # 80010fa0 <proc>
      pp->parent = initproc;
    8000219c:	00006a17          	auipc	s4,0x6
    800021a0:	75ca0a13          	addi	s4,s4,1884 # 800088f8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021a4:	00015997          	auipc	s3,0x15
    800021a8:	7fc98993          	addi	s3,s3,2044 # 800179a0 <mlfq>
    800021ac:	a029                	j	800021b6 <reparent+0x34>
    800021ae:	1a848493          	addi	s1,s1,424
    800021b2:	01348d63          	beq	s1,s3,800021cc <reparent+0x4a>
    if (pp->parent == p)
    800021b6:	7c9c                	ld	a5,56(s1)
    800021b8:	ff279be3          	bne	a5,s2,800021ae <reparent+0x2c>
      pp->parent = initproc;
    800021bc:	000a3503          	ld	a0,0(s4)
    800021c0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021c2:	00000097          	auipc	ra,0x0
    800021c6:	f4a080e7          	jalr	-182(ra) # 8000210c <wakeup>
    800021ca:	b7d5                	j	800021ae <reparent+0x2c>
}
    800021cc:	70a2                	ld	ra,40(sp)
    800021ce:	7402                	ld	s0,32(sp)
    800021d0:	64e2                	ld	s1,24(sp)
    800021d2:	6942                	ld	s2,16(sp)
    800021d4:	69a2                	ld	s3,8(sp)
    800021d6:	6a02                	ld	s4,0(sp)
    800021d8:	6145                	addi	sp,sp,48
    800021da:	8082                	ret

00000000800021dc <exit>:
{
    800021dc:	7179                	addi	sp,sp,-48
    800021de:	f406                	sd	ra,40(sp)
    800021e0:	f022                	sd	s0,32(sp)
    800021e2:	ec26                	sd	s1,24(sp)
    800021e4:	e84a                	sd	s2,16(sp)
    800021e6:	e44e                	sd	s3,8(sp)
    800021e8:	e052                	sd	s4,0(sp)
    800021ea:	1800                	addi	s0,sp,48
    800021ec:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	7be080e7          	jalr	1982(ra) # 800019ac <myproc>
    800021f6:	89aa                	mv	s3,a0
  if (p == initproc)
    800021f8:	00006797          	auipc	a5,0x6
    800021fc:	7007b783          	ld	a5,1792(a5) # 800088f8 <initproc>
    80002200:	0d050493          	addi	s1,a0,208
    80002204:	15050913          	addi	s2,a0,336
    80002208:	02a79363          	bne	a5,a0,8000222e <exit+0x52>
    panic("init exiting");
    8000220c:	00006517          	auipc	a0,0x6
    80002210:	05450513          	addi	a0,a0,84 # 80008260 <digits+0x220>
    80002214:	ffffe097          	auipc	ra,0xffffe
    80002218:	32c080e7          	jalr	812(ra) # 80000540 <panic>
      fileclose(f);
    8000221c:	00002097          	auipc	ra,0x2
    80002220:	644080e7          	jalr	1604(ra) # 80004860 <fileclose>
      p->ofile[fd] = 0;
    80002224:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002228:	04a1                	addi	s1,s1,8
    8000222a:	01248563          	beq	s1,s2,80002234 <exit+0x58>
    if (p->ofile[fd])
    8000222e:	6088                	ld	a0,0(s1)
    80002230:	f575                	bnez	a0,8000221c <exit+0x40>
    80002232:	bfdd                	j	80002228 <exit+0x4c>
  begin_op();
    80002234:	00002097          	auipc	ra,0x2
    80002238:	164080e7          	jalr	356(ra) # 80004398 <begin_op>
  iput(p->cwd);
    8000223c:	1509b503          	ld	a0,336(s3)
    80002240:	00002097          	auipc	ra,0x2
    80002244:	946080e7          	jalr	-1722(ra) # 80003b86 <iput>
  end_op();
    80002248:	00002097          	auipc	ra,0x2
    8000224c:	1ce080e7          	jalr	462(ra) # 80004416 <end_op>
  p->cwd = 0;
    80002250:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002254:	0000f497          	auipc	s1,0xf
    80002258:	93448493          	addi	s1,s1,-1740 # 80010b88 <wait_lock>
    8000225c:	8526                	mv	a0,s1
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	978080e7          	jalr	-1672(ra) # 80000bd6 <acquire>
  reparent(p);
    80002266:	854e                	mv	a0,s3
    80002268:	00000097          	auipc	ra,0x0
    8000226c:	f1a080e7          	jalr	-230(ra) # 80002182 <reparent>
  wakeup(p->parent);
    80002270:	0389b503          	ld	a0,56(s3)
    80002274:	00000097          	auipc	ra,0x0
    80002278:	e98080e7          	jalr	-360(ra) # 8000210c <wakeup>
  acquire(&p->lock);
    8000227c:	854e                	mv	a0,s3
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	958080e7          	jalr	-1704(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002286:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000228a:	4795                	li	a5,5
    8000228c:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002290:	00006797          	auipc	a5,0x6
    80002294:	6707a783          	lw	a5,1648(a5) # 80008900 <ticks>
    80002298:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000229c:	8526                	mv	a0,s1
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	9ec080e7          	jalr	-1556(ra) # 80000c8a <release>
  sched();
    800022a6:	00000097          	auipc	ra,0x0
    800022aa:	cf0080e7          	jalr	-784(ra) # 80001f96 <sched>
  panic("zombie exit");
    800022ae:	00006517          	auipc	a0,0x6
    800022b2:	fc250513          	addi	a0,a0,-62 # 80008270 <digits+0x230>
    800022b6:	ffffe097          	auipc	ra,0xffffe
    800022ba:	28a080e7          	jalr	650(ra) # 80000540 <panic>

00000000800022be <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800022be:	7179                	addi	sp,sp,-48
    800022c0:	f406                	sd	ra,40(sp)
    800022c2:	f022                	sd	s0,32(sp)
    800022c4:	ec26                	sd	s1,24(sp)
    800022c6:	e84a                	sd	s2,16(sp)
    800022c8:	e44e                	sd	s3,8(sp)
    800022ca:	1800                	addi	s0,sp,48
    800022cc:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800022ce:	0000f497          	auipc	s1,0xf
    800022d2:	cd248493          	addi	s1,s1,-814 # 80010fa0 <proc>
    800022d6:	00015997          	auipc	s3,0x15
    800022da:	6ca98993          	addi	s3,s3,1738 # 800179a0 <mlfq>
  {
    acquire(&p->lock);
    800022de:	8526                	mv	a0,s1
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	8f6080e7          	jalr	-1802(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    800022e8:	589c                	lw	a5,48(s1)
    800022ea:	01278d63          	beq	a5,s2,80002304 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022ee:	8526                	mv	a0,s1
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	99a080e7          	jalr	-1638(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800022f8:	1a848493          	addi	s1,s1,424
    800022fc:	ff3491e3          	bne	s1,s3,800022de <kill+0x20>
  }
  return -1;
    80002300:	557d                	li	a0,-1
    80002302:	a829                	j	8000231c <kill+0x5e>
      p->killed = 1;
    80002304:	4785                	li	a5,1
    80002306:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002308:	4c98                	lw	a4,24(s1)
    8000230a:	4789                	li	a5,2
    8000230c:	00f70f63          	beq	a4,a5,8000232a <kill+0x6c>
      release(&p->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	978080e7          	jalr	-1672(ra) # 80000c8a <release>
      return 0;
    8000231a:	4501                	li	a0,0
}
    8000231c:	70a2                	ld	ra,40(sp)
    8000231e:	7402                	ld	s0,32(sp)
    80002320:	64e2                	ld	s1,24(sp)
    80002322:	6942                	ld	s2,16(sp)
    80002324:	69a2                	ld	s3,8(sp)
    80002326:	6145                	addi	sp,sp,48
    80002328:	8082                	ret
        p->state = RUNNABLE;
    8000232a:	478d                	li	a5,3
    8000232c:	cc9c                	sw	a5,24(s1)
    8000232e:	b7cd                	j	80002310 <kill+0x52>

0000000080002330 <setkilled>:

void setkilled(struct proc *p)
{
    80002330:	1101                	addi	sp,sp,-32
    80002332:	ec06                	sd	ra,24(sp)
    80002334:	e822                	sd	s0,16(sp)
    80002336:	e426                	sd	s1,8(sp)
    80002338:	1000                	addi	s0,sp,32
    8000233a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	89a080e7          	jalr	-1894(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002344:	4785                	li	a5,1
    80002346:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002348:	8526                	mv	a0,s1
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	940080e7          	jalr	-1728(ra) # 80000c8a <release>
}
    80002352:	60e2                	ld	ra,24(sp)
    80002354:	6442                	ld	s0,16(sp)
    80002356:	64a2                	ld	s1,8(sp)
    80002358:	6105                	addi	sp,sp,32
    8000235a:	8082                	ret

000000008000235c <killed>:

int killed(struct proc *p)
{
    8000235c:	1101                	addi	sp,sp,-32
    8000235e:	ec06                	sd	ra,24(sp)
    80002360:	e822                	sd	s0,16(sp)
    80002362:	e426                	sd	s1,8(sp)
    80002364:	e04a                	sd	s2,0(sp)
    80002366:	1000                	addi	s0,sp,32
    80002368:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	86c080e7          	jalr	-1940(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002372:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002376:	8526                	mv	a0,s1
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	912080e7          	jalr	-1774(ra) # 80000c8a <release>
  return k;
}
    80002380:	854a                	mv	a0,s2
    80002382:	60e2                	ld	ra,24(sp)
    80002384:	6442                	ld	s0,16(sp)
    80002386:	64a2                	ld	s1,8(sp)
    80002388:	6902                	ld	s2,0(sp)
    8000238a:	6105                	addi	sp,sp,32
    8000238c:	8082                	ret

000000008000238e <wait>:
{
    8000238e:	715d                	addi	sp,sp,-80
    80002390:	e486                	sd	ra,72(sp)
    80002392:	e0a2                	sd	s0,64(sp)
    80002394:	fc26                	sd	s1,56(sp)
    80002396:	f84a                	sd	s2,48(sp)
    80002398:	f44e                	sd	s3,40(sp)
    8000239a:	f052                	sd	s4,32(sp)
    8000239c:	ec56                	sd	s5,24(sp)
    8000239e:	e85a                	sd	s6,16(sp)
    800023a0:	e45e                	sd	s7,8(sp)
    800023a2:	e062                	sd	s8,0(sp)
    800023a4:	0880                	addi	s0,sp,80
    800023a6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	604080e7          	jalr	1540(ra) # 800019ac <myproc>
    800023b0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023b2:	0000e517          	auipc	a0,0xe
    800023b6:	7d650513          	addi	a0,a0,2006 # 80010b88 <wait_lock>
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	81c080e7          	jalr	-2020(ra) # 80000bd6 <acquire>
    havekids = 0;
    800023c2:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800023c4:	4a15                	li	s4,5
        havekids = 1;
    800023c6:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023c8:	00015997          	auipc	s3,0x15
    800023cc:	5d898993          	addi	s3,s3,1496 # 800179a0 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800023d0:	0000ec17          	auipc	s8,0xe
    800023d4:	7b8c0c13          	addi	s8,s8,1976 # 80010b88 <wait_lock>
    havekids = 0;
    800023d8:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023da:	0000f497          	auipc	s1,0xf
    800023de:	bc648493          	addi	s1,s1,-1082 # 80010fa0 <proc>
    800023e2:	a0bd                	j	80002450 <wait+0xc2>
          pid = pp->pid;
    800023e4:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023e8:	000b0e63          	beqz	s6,80002404 <wait+0x76>
    800023ec:	4691                	li	a3,4
    800023ee:	02c48613          	addi	a2,s1,44
    800023f2:	85da                	mv	a1,s6
    800023f4:	05093503          	ld	a0,80(s2)
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	274080e7          	jalr	628(ra) # 8000166c <copyout>
    80002400:	02054563          	bltz	a0,8000242a <wait+0x9c>
          freeproc(pp);
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	758080e7          	jalr	1880(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	87a080e7          	jalr	-1926(ra) # 80000c8a <release>
          release(&wait_lock);
    80002418:	0000e517          	auipc	a0,0xe
    8000241c:	77050513          	addi	a0,a0,1904 # 80010b88 <wait_lock>
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	86a080e7          	jalr	-1942(ra) # 80000c8a <release>
          return pid;
    80002428:	a0b5                	j	80002494 <wait+0x106>
            release(&pp->lock);
    8000242a:	8526                	mv	a0,s1
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	85e080e7          	jalr	-1954(ra) # 80000c8a <release>
            release(&wait_lock);
    80002434:	0000e517          	auipc	a0,0xe
    80002438:	75450513          	addi	a0,a0,1876 # 80010b88 <wait_lock>
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	84e080e7          	jalr	-1970(ra) # 80000c8a <release>
            return -1;
    80002444:	59fd                	li	s3,-1
    80002446:	a0b9                	j	80002494 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002448:	1a848493          	addi	s1,s1,424
    8000244c:	03348463          	beq	s1,s3,80002474 <wait+0xe6>
      if (pp->parent == p)
    80002450:	7c9c                	ld	a5,56(s1)
    80002452:	ff279be3          	bne	a5,s2,80002448 <wait+0xba>
        acquire(&pp->lock);
    80002456:	8526                	mv	a0,s1
    80002458:	ffffe097          	auipc	ra,0xffffe
    8000245c:	77e080e7          	jalr	1918(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    80002460:	4c9c                	lw	a5,24(s1)
    80002462:	f94781e3          	beq	a5,s4,800023e4 <wait+0x56>
        release(&pp->lock);
    80002466:	8526                	mv	a0,s1
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	822080e7          	jalr	-2014(ra) # 80000c8a <release>
        havekids = 1;
    80002470:	8756                	mv	a4,s5
    80002472:	bfd9                	j	80002448 <wait+0xba>
    if (!havekids || killed(p))
    80002474:	c719                	beqz	a4,80002482 <wait+0xf4>
    80002476:	854a                	mv	a0,s2
    80002478:	00000097          	auipc	ra,0x0
    8000247c:	ee4080e7          	jalr	-284(ra) # 8000235c <killed>
    80002480:	c51d                	beqz	a0,800024ae <wait+0x120>
      release(&wait_lock);
    80002482:	0000e517          	auipc	a0,0xe
    80002486:	70650513          	addi	a0,a0,1798 # 80010b88 <wait_lock>
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	800080e7          	jalr	-2048(ra) # 80000c8a <release>
      return -1;
    80002492:	59fd                	li	s3,-1
}
    80002494:	854e                	mv	a0,s3
    80002496:	60a6                	ld	ra,72(sp)
    80002498:	6406                	ld	s0,64(sp)
    8000249a:	74e2                	ld	s1,56(sp)
    8000249c:	7942                	ld	s2,48(sp)
    8000249e:	79a2                	ld	s3,40(sp)
    800024a0:	7a02                	ld	s4,32(sp)
    800024a2:	6ae2                	ld	s5,24(sp)
    800024a4:	6b42                	ld	s6,16(sp)
    800024a6:	6ba2                	ld	s7,8(sp)
    800024a8:	6c02                	ld	s8,0(sp)
    800024aa:	6161                	addi	sp,sp,80
    800024ac:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024ae:	85e2                	mv	a1,s8
    800024b0:	854a                	mv	a0,s2
    800024b2:	00000097          	auipc	ra,0x0
    800024b6:	bf6080e7          	jalr	-1034(ra) # 800020a8 <sleep>
    havekids = 0;
    800024ba:	bf39                	j	800023d8 <wait+0x4a>

00000000800024bc <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024bc:	7179                	addi	sp,sp,-48
    800024be:	f406                	sd	ra,40(sp)
    800024c0:	f022                	sd	s0,32(sp)
    800024c2:	ec26                	sd	s1,24(sp)
    800024c4:	e84a                	sd	s2,16(sp)
    800024c6:	e44e                	sd	s3,8(sp)
    800024c8:	e052                	sd	s4,0(sp)
    800024ca:	1800                	addi	s0,sp,48
    800024cc:	84aa                	mv	s1,a0
    800024ce:	892e                	mv	s2,a1
    800024d0:	89b2                	mv	s3,a2
    800024d2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	4d8080e7          	jalr	1240(ra) # 800019ac <myproc>
  if (user_dst)
    800024dc:	c08d                	beqz	s1,800024fe <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800024de:	86d2                	mv	a3,s4
    800024e0:	864e                	mv	a2,s3
    800024e2:	85ca                	mv	a1,s2
    800024e4:	6928                	ld	a0,80(a0)
    800024e6:	fffff097          	auipc	ra,0xfffff
    800024ea:	186080e7          	jalr	390(ra) # 8000166c <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024ee:	70a2                	ld	ra,40(sp)
    800024f0:	7402                	ld	s0,32(sp)
    800024f2:	64e2                	ld	s1,24(sp)
    800024f4:	6942                	ld	s2,16(sp)
    800024f6:	69a2                	ld	s3,8(sp)
    800024f8:	6a02                	ld	s4,0(sp)
    800024fa:	6145                	addi	sp,sp,48
    800024fc:	8082                	ret
    memmove((char *)dst, src, len);
    800024fe:	000a061b          	sext.w	a2,s4
    80002502:	85ce                	mv	a1,s3
    80002504:	854a                	mv	a0,s2
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	828080e7          	jalr	-2008(ra) # 80000d2e <memmove>
    return 0;
    8000250e:	8526                	mv	a0,s1
    80002510:	bff9                	j	800024ee <either_copyout+0x32>

0000000080002512 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002512:	7179                	addi	sp,sp,-48
    80002514:	f406                	sd	ra,40(sp)
    80002516:	f022                	sd	s0,32(sp)
    80002518:	ec26                	sd	s1,24(sp)
    8000251a:	e84a                	sd	s2,16(sp)
    8000251c:	e44e                	sd	s3,8(sp)
    8000251e:	e052                	sd	s4,0(sp)
    80002520:	1800                	addi	s0,sp,48
    80002522:	892a                	mv	s2,a0
    80002524:	84ae                	mv	s1,a1
    80002526:	89b2                	mv	s3,a2
    80002528:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000252a:	fffff097          	auipc	ra,0xfffff
    8000252e:	482080e7          	jalr	1154(ra) # 800019ac <myproc>
  if (user_src)
    80002532:	c08d                	beqz	s1,80002554 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002534:	86d2                	mv	a3,s4
    80002536:	864e                	mv	a2,s3
    80002538:	85ca                	mv	a1,s2
    8000253a:	6928                	ld	a0,80(a0)
    8000253c:	fffff097          	auipc	ra,0xfffff
    80002540:	1bc080e7          	jalr	444(ra) # 800016f8 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002544:	70a2                	ld	ra,40(sp)
    80002546:	7402                	ld	s0,32(sp)
    80002548:	64e2                	ld	s1,24(sp)
    8000254a:	6942                	ld	s2,16(sp)
    8000254c:	69a2                	ld	s3,8(sp)
    8000254e:	6a02                	ld	s4,0(sp)
    80002550:	6145                	addi	sp,sp,48
    80002552:	8082                	ret
    memmove(dst, (char *)src, len);
    80002554:	000a061b          	sext.w	a2,s4
    80002558:	85ce                	mv	a1,s3
    8000255a:	854a                	mv	a0,s2
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	7d2080e7          	jalr	2002(ra) # 80000d2e <memmove>
    return 0;
    80002564:	8526                	mv	a0,s1
    80002566:	bff9                	j	80002544 <either_copyin+0x32>

0000000080002568 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002568:	715d                	addi	sp,sp,-80
    8000256a:	e486                	sd	ra,72(sp)
    8000256c:	e0a2                	sd	s0,64(sp)
    8000256e:	fc26                	sd	s1,56(sp)
    80002570:	f84a                	sd	s2,48(sp)
    80002572:	f44e                	sd	s3,40(sp)
    80002574:	f052                	sd	s4,32(sp)
    80002576:	ec56                	sd	s5,24(sp)
    80002578:	e85a                	sd	s6,16(sp)
    8000257a:	e45e                	sd	s7,8(sp)
    8000257c:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000257e:	00006517          	auipc	a0,0x6
    80002582:	b4a50513          	addi	a0,a0,-1206 # 800080c8 <digits+0x88>
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	004080e7          	jalr	4(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000258e:	0000f497          	auipc	s1,0xf
    80002592:	b6a48493          	addi	s1,s1,-1174 # 800110f8 <proc+0x158>
    80002596:	00015917          	auipc	s2,0x15
    8000259a:	56290913          	addi	s2,s2,1378 # 80017af8 <mlfq+0x158>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000259e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025a0:	00006997          	auipc	s3,0x6
    800025a4:	ce098993          	addi	s3,s3,-800 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025a8:	00006a97          	auipc	s5,0x6
    800025ac:	ce0a8a93          	addi	s5,s5,-800 # 80008288 <digits+0x248>
    printf("\n");
    800025b0:	00006a17          	auipc	s4,0x6
    800025b4:	b18a0a13          	addi	s4,s4,-1256 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025b8:	00006b97          	auipc	s7,0x6
    800025bc:	d10b8b93          	addi	s7,s7,-752 # 800082c8 <states.0>
    800025c0:	a00d                	j	800025e2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025c2:	ed86a583          	lw	a1,-296(a3)
    800025c6:	8556                	mv	a0,s5
    800025c8:	ffffe097          	auipc	ra,0xffffe
    800025cc:	fc2080e7          	jalr	-62(ra) # 8000058a <printf>
    printf("\n");
    800025d0:	8552                	mv	a0,s4
    800025d2:	ffffe097          	auipc	ra,0xffffe
    800025d6:	fb8080e7          	jalr	-72(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800025da:	1a848493          	addi	s1,s1,424
    800025de:	03248263          	beq	s1,s2,80002602 <procdump+0x9a>
    if (p->state == UNUSED)
    800025e2:	86a6                	mv	a3,s1
    800025e4:	ec04a783          	lw	a5,-320(s1)
    800025e8:	dbed                	beqz	a5,800025da <procdump+0x72>
      state = "???";
    800025ea:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ec:	fcfb6be3          	bltu	s6,a5,800025c2 <procdump+0x5a>
    800025f0:	02079713          	slli	a4,a5,0x20
    800025f4:	01d75793          	srli	a5,a4,0x1d
    800025f8:	97de                	add	a5,a5,s7
    800025fa:	6390                	ld	a2,0(a5)
    800025fc:	f279                	bnez	a2,800025c2 <procdump+0x5a>
      state = "???";
    800025fe:	864e                	mv	a2,s3
    80002600:	b7c9                	j	800025c2 <procdump+0x5a>
  }
}
    80002602:	60a6                	ld	ra,72(sp)
    80002604:	6406                	ld	s0,64(sp)
    80002606:	74e2                	ld	s1,56(sp)
    80002608:	7942                	ld	s2,48(sp)
    8000260a:	79a2                	ld	s3,40(sp)
    8000260c:	7a02                	ld	s4,32(sp)
    8000260e:	6ae2                	ld	s5,24(sp)
    80002610:	6b42                	ld	s6,16(sp)
    80002612:	6ba2                	ld	s7,8(sp)
    80002614:	6161                	addi	sp,sp,80
    80002616:	8082                	ret

0000000080002618 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002618:	711d                	addi	sp,sp,-96
    8000261a:	ec86                	sd	ra,88(sp)
    8000261c:	e8a2                	sd	s0,80(sp)
    8000261e:	e4a6                	sd	s1,72(sp)
    80002620:	e0ca                	sd	s2,64(sp)
    80002622:	fc4e                	sd	s3,56(sp)
    80002624:	f852                	sd	s4,48(sp)
    80002626:	f456                	sd	s5,40(sp)
    80002628:	f05a                	sd	s6,32(sp)
    8000262a:	ec5e                	sd	s7,24(sp)
    8000262c:	e862                	sd	s8,16(sp)
    8000262e:	e466                	sd	s9,8(sp)
    80002630:	e06a                	sd	s10,0(sp)
    80002632:	1080                	addi	s0,sp,96
    80002634:	8b2a                	mv	s6,a0
    80002636:	8bae                	mv	s7,a1
    80002638:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000263a:	fffff097          	auipc	ra,0xfffff
    8000263e:	372080e7          	jalr	882(ra) # 800019ac <myproc>
    80002642:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002644:	0000e517          	auipc	a0,0xe
    80002648:	54450513          	addi	a0,a0,1348 # 80010b88 <wait_lock>
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	58a080e7          	jalr	1418(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002654:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002656:	4a15                	li	s4,5
        havekids = 1;
    80002658:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    8000265a:	00015997          	auipc	s3,0x15
    8000265e:	34698993          	addi	s3,s3,838 # 800179a0 <mlfq>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002662:	0000ed17          	auipc	s10,0xe
    80002666:	526d0d13          	addi	s10,s10,1318 # 80010b88 <wait_lock>
    havekids = 0;
    8000266a:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    8000266c:	0000f497          	auipc	s1,0xf
    80002670:	93448493          	addi	s1,s1,-1740 # 80010fa0 <proc>
    80002674:	a059                	j	800026fa <waitx+0xe2>
          pid = np->pid;
    80002676:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000267a:	1684a783          	lw	a5,360(s1)
    8000267e:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002682:	16c4a703          	lw	a4,364(s1)
    80002686:	9f3d                	addw	a4,a4,a5
    80002688:	1704a783          	lw	a5,368(s1)
    8000268c:	9f99                	subw	a5,a5,a4
    8000268e:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002692:	000b0e63          	beqz	s6,800026ae <waitx+0x96>
    80002696:	4691                	li	a3,4
    80002698:	02c48613          	addi	a2,s1,44
    8000269c:	85da                	mv	a1,s6
    8000269e:	05093503          	ld	a0,80(s2)
    800026a2:	fffff097          	auipc	ra,0xfffff
    800026a6:	fca080e7          	jalr	-54(ra) # 8000166c <copyout>
    800026aa:	02054563          	bltz	a0,800026d4 <waitx+0xbc>
          freeproc(np);
    800026ae:	8526                	mv	a0,s1
    800026b0:	fffff097          	auipc	ra,0xfffff
    800026b4:	4ae080e7          	jalr	1198(ra) # 80001b5e <freeproc>
          release(&np->lock);
    800026b8:	8526                	mv	a0,s1
    800026ba:	ffffe097          	auipc	ra,0xffffe
    800026be:	5d0080e7          	jalr	1488(ra) # 80000c8a <release>
          release(&wait_lock);
    800026c2:	0000e517          	auipc	a0,0xe
    800026c6:	4c650513          	addi	a0,a0,1222 # 80010b88 <wait_lock>
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	5c0080e7          	jalr	1472(ra) # 80000c8a <release>
          return pid;
    800026d2:	a09d                	j	80002738 <waitx+0x120>
            release(&np->lock);
    800026d4:	8526                	mv	a0,s1
    800026d6:	ffffe097          	auipc	ra,0xffffe
    800026da:	5b4080e7          	jalr	1460(ra) # 80000c8a <release>
            release(&wait_lock);
    800026de:	0000e517          	auipc	a0,0xe
    800026e2:	4aa50513          	addi	a0,a0,1194 # 80010b88 <wait_lock>
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	5a4080e7          	jalr	1444(ra) # 80000c8a <release>
            return -1;
    800026ee:	59fd                	li	s3,-1
    800026f0:	a0a1                	j	80002738 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    800026f2:	1a848493          	addi	s1,s1,424
    800026f6:	03348463          	beq	s1,s3,8000271e <waitx+0x106>
      if (np->parent == p)
    800026fa:	7c9c                	ld	a5,56(s1)
    800026fc:	ff279be3          	bne	a5,s2,800026f2 <waitx+0xda>
        acquire(&np->lock);
    80002700:	8526                	mv	a0,s1
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	4d4080e7          	jalr	1236(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    8000270a:	4c9c                	lw	a5,24(s1)
    8000270c:	f74785e3          	beq	a5,s4,80002676 <waitx+0x5e>
        release(&np->lock);
    80002710:	8526                	mv	a0,s1
    80002712:	ffffe097          	auipc	ra,0xffffe
    80002716:	578080e7          	jalr	1400(ra) # 80000c8a <release>
        havekids = 1;
    8000271a:	8756                	mv	a4,s5
    8000271c:	bfd9                	j	800026f2 <waitx+0xda>
    if (!havekids || p->killed)
    8000271e:	c701                	beqz	a4,80002726 <waitx+0x10e>
    80002720:	02892783          	lw	a5,40(s2)
    80002724:	cb8d                	beqz	a5,80002756 <waitx+0x13e>
      release(&wait_lock);
    80002726:	0000e517          	auipc	a0,0xe
    8000272a:	46250513          	addi	a0,a0,1122 # 80010b88 <wait_lock>
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	55c080e7          	jalr	1372(ra) # 80000c8a <release>
      return -1;
    80002736:	59fd                	li	s3,-1
  }
}
    80002738:	854e                	mv	a0,s3
    8000273a:	60e6                	ld	ra,88(sp)
    8000273c:	6446                	ld	s0,80(sp)
    8000273e:	64a6                	ld	s1,72(sp)
    80002740:	6906                	ld	s2,64(sp)
    80002742:	79e2                	ld	s3,56(sp)
    80002744:	7a42                	ld	s4,48(sp)
    80002746:	7aa2                	ld	s5,40(sp)
    80002748:	7b02                	ld	s6,32(sp)
    8000274a:	6be2                	ld	s7,24(sp)
    8000274c:	6c42                	ld	s8,16(sp)
    8000274e:	6ca2                	ld	s9,8(sp)
    80002750:	6d02                	ld	s10,0(sp)
    80002752:	6125                	addi	sp,sp,96
    80002754:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002756:	85ea                	mv	a1,s10
    80002758:	854a                	mv	a0,s2
    8000275a:	00000097          	auipc	ra,0x0
    8000275e:	94e080e7          	jalr	-1714(ra) # 800020a8 <sleep>
    havekids = 0;
    80002762:	b721                	j	8000266a <waitx+0x52>

0000000080002764 <update_time>:

void update_time()
{
    80002764:	7179                	addi	sp,sp,-48
    80002766:	f406                	sd	ra,40(sp)
    80002768:	f022                	sd	s0,32(sp)
    8000276a:	ec26                	sd	s1,24(sp)
    8000276c:	e84a                	sd	s2,16(sp)
    8000276e:	e44e                	sd	s3,8(sp)
    80002770:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002772:	0000f497          	auipc	s1,0xf
    80002776:	82e48493          	addi	s1,s1,-2002 # 80010fa0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    8000277a:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    8000277c:	00015917          	auipc	s2,0x15
    80002780:	22490913          	addi	s2,s2,548 # 800179a0 <mlfq>
    80002784:	a811                	j	80002798 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    80002786:	8526                	mv	a0,s1
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	502080e7          	jalr	1282(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002790:	1a848493          	addi	s1,s1,424
    80002794:	03248063          	beq	s1,s2,800027b4 <update_time+0x50>
    acquire(&p->lock);
    80002798:	8526                	mv	a0,s1
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	43c080e7          	jalr	1084(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    800027a2:	4c9c                	lw	a5,24(s1)
    800027a4:	ff3791e3          	bne	a5,s3,80002786 <update_time+0x22>
      p->rtime++;
    800027a8:	1684a783          	lw	a5,360(s1)
    800027ac:	2785                	addiw	a5,a5,1
    800027ae:	16f4a423          	sw	a5,360(s1)
    800027b2:	bfd1                	j	80002786 <update_time+0x22>
  }
    800027b4:	70a2                	ld	ra,40(sp)
    800027b6:	7402                	ld	s0,32(sp)
    800027b8:	64e2                	ld	s1,24(sp)
    800027ba:	6942                	ld	s2,16(sp)
    800027bc:	69a2                	ld	s3,8(sp)
    800027be:	6145                	addi	sp,sp,48
    800027c0:	8082                	ret

00000000800027c2 <swtch>:
    800027c2:	00153023          	sd	ra,0(a0)
    800027c6:	00253423          	sd	sp,8(a0)
    800027ca:	e900                	sd	s0,16(a0)
    800027cc:	ed04                	sd	s1,24(a0)
    800027ce:	03253023          	sd	s2,32(a0)
    800027d2:	03353423          	sd	s3,40(a0)
    800027d6:	03453823          	sd	s4,48(a0)
    800027da:	03553c23          	sd	s5,56(a0)
    800027de:	05653023          	sd	s6,64(a0)
    800027e2:	05753423          	sd	s7,72(a0)
    800027e6:	05853823          	sd	s8,80(a0)
    800027ea:	05953c23          	sd	s9,88(a0)
    800027ee:	07a53023          	sd	s10,96(a0)
    800027f2:	07b53423          	sd	s11,104(a0)
    800027f6:	0005b083          	ld	ra,0(a1)
    800027fa:	0085b103          	ld	sp,8(a1)
    800027fe:	6980                	ld	s0,16(a1)
    80002800:	6d84                	ld	s1,24(a1)
    80002802:	0205b903          	ld	s2,32(a1)
    80002806:	0285b983          	ld	s3,40(a1)
    8000280a:	0305ba03          	ld	s4,48(a1)
    8000280e:	0385ba83          	ld	s5,56(a1)
    80002812:	0405bb03          	ld	s6,64(a1)
    80002816:	0485bb83          	ld	s7,72(a1)
    8000281a:	0505bc03          	ld	s8,80(a1)
    8000281e:	0585bc83          	ld	s9,88(a1)
    80002822:	0605bd03          	ld	s10,96(a1)
    80002826:	0685bd83          	ld	s11,104(a1)
    8000282a:	8082                	ret

000000008000282c <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000282c:	1141                	addi	sp,sp,-16
    8000282e:	e406                	sd	ra,8(sp)
    80002830:	e022                	sd	s0,0(sp)
    80002832:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002834:	00006597          	auipc	a1,0x6
    80002838:	ac458593          	addi	a1,a1,-1340 # 800082f8 <states.0+0x30>
    8000283c:	00016517          	auipc	a0,0x16
    80002840:	b8c50513          	addi	a0,a0,-1140 # 800183c8 <tickslock>
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	302080e7          	jalr	770(ra) # 80000b46 <initlock>
}
    8000284c:	60a2                	ld	ra,8(sp)
    8000284e:	6402                	ld	s0,0(sp)
    80002850:	0141                	addi	sp,sp,16
    80002852:	8082                	ret

0000000080002854 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002854:	1141                	addi	sp,sp,-16
    80002856:	e422                	sd	s0,8(sp)
    80002858:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0"
    8000285a:	00003797          	auipc	a5,0x3
    8000285e:	65678793          	addi	a5,a5,1622 # 80005eb0 <kernelvec>
    80002862:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002866:	6422                	ld	s0,8(sp)
    80002868:	0141                	addi	sp,sp,16
    8000286a:	8082                	ret

000000008000286c <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    8000286c:	1141                	addi	sp,sp,-16
    8000286e:	e406                	sd	ra,8(sp)
    80002870:	e022                	sd	s0,0(sp)
    80002872:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002874:	fffff097          	auipc	ra,0xfffff
    80002878:	138080e7          	jalr	312(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus"
    8000287c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002880:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    80002882:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002886:	00004697          	auipc	a3,0x4
    8000288a:	77a68693          	addi	a3,a3,1914 # 80007000 <_trampoline>
    8000288e:	00004717          	auipc	a4,0x4
    80002892:	77270713          	addi	a4,a4,1906 # 80007000 <_trampoline>
    80002896:	8f15                	sub	a4,a4,a3
    80002898:	040007b7          	lui	a5,0x4000
    8000289c:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000289e:	07b2                	slli	a5,a5,0xc
    800028a0:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0"
    800028a2:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028a6:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp"
    800028a8:	18002673          	csrr	a2,satp
    800028ac:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028ae:	6d30                	ld	a2,88(a0)
    800028b0:	6138                	ld	a4,64(a0)
    800028b2:	6585                	lui	a1,0x1
    800028b4:	972e                	add	a4,a4,a1
    800028b6:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028b8:	6d38                	ld	a4,88(a0)
    800028ba:	00000617          	auipc	a2,0x0
    800028be:	13e60613          	addi	a2,a2,318 # 800029f8 <usertrap>
    800028c2:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800028c4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp"
    800028c6:	8612                	mv	a2,tp
    800028c8:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus"
    800028ca:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028ce:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028d2:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0"
    800028d6:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028da:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0"
    800028dc:	6f18                	ld	a4,24(a4)
    800028de:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028e2:	6928                	ld	a0,80(a0)
    800028e4:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028e6:	00004717          	auipc	a4,0x4
    800028ea:	7b670713          	addi	a4,a4,1974 # 8000709c <userret>
    800028ee:	8f15                	sub	a4,a4,a3
    800028f0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800028f2:	577d                	li	a4,-1
    800028f4:	177e                	slli	a4,a4,0x3f
    800028f6:	8d59                	or	a0,a0,a4
    800028f8:	9782                	jalr	a5
}
    800028fa:	60a2                	ld	ra,8(sp)
    800028fc:	6402                	ld	s0,0(sp)
    800028fe:	0141                	addi	sp,sp,16
    80002900:	8082                	ret

0000000080002902 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002902:	1101                	addi	sp,sp,-32
    80002904:	ec06                	sd	ra,24(sp)
    80002906:	e822                	sd	s0,16(sp)
    80002908:	e426                	sd	s1,8(sp)
    8000290a:	e04a                	sd	s2,0(sp)
    8000290c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000290e:	00016917          	auipc	s2,0x16
    80002912:	aba90913          	addi	s2,s2,-1350 # 800183c8 <tickslock>
    80002916:	854a                	mv	a0,s2
    80002918:	ffffe097          	auipc	ra,0xffffe
    8000291c:	2be080e7          	jalr	702(ra) # 80000bd6 <acquire>
  ticks++;
    80002920:	00006497          	auipc	s1,0x6
    80002924:	fe048493          	addi	s1,s1,-32 # 80008900 <ticks>
    80002928:	409c                	lw	a5,0(s1)
    8000292a:	2785                	addiw	a5,a5,1
    8000292c:	c09c                	sw	a5,0(s1)
  update_time();
    8000292e:	00000097          	auipc	ra,0x0
    80002932:	e36080e7          	jalr	-458(ra) # 80002764 <update_time>
  // if (myproc() != 0)
  // {
  //   myproc()->change_queue--;
  // }
  wakeup(&ticks);
    80002936:	8526                	mv	a0,s1
    80002938:	fffff097          	auipc	ra,0xfffff
    8000293c:	7d4080e7          	jalr	2004(ra) # 8000210c <wakeup>
  release(&tickslock);
    80002940:	854a                	mv	a0,s2
    80002942:	ffffe097          	auipc	ra,0xffffe
    80002946:	348080e7          	jalr	840(ra) # 80000c8a <release>
}
    8000294a:	60e2                	ld	ra,24(sp)
    8000294c:	6442                	ld	s0,16(sp)
    8000294e:	64a2                	ld	s1,8(sp)
    80002950:	6902                	ld	s2,0(sp)
    80002952:	6105                	addi	sp,sp,32
    80002954:	8082                	ret

0000000080002956 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002956:	1101                	addi	sp,sp,-32
    80002958:	ec06                	sd	ra,24(sp)
    8000295a:	e822                	sd	s0,16(sp)
    8000295c:	e426                	sd	s1,8(sp)
    8000295e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause"
    80002960:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002964:	00074d63          	bltz	a4,8000297e <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002968:	57fd                	li	a5,-1
    8000296a:	17fe                	slli	a5,a5,0x3f
    8000296c:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    8000296e:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002970:	06f70363          	beq	a4,a5,800029d6 <devintr+0x80>
  }
}
    80002974:	60e2                	ld	ra,24(sp)
    80002976:	6442                	ld	s0,16(sp)
    80002978:	64a2                	ld	s1,8(sp)
    8000297a:	6105                	addi	sp,sp,32
    8000297c:	8082                	ret
      (scause & 0xff) == 9)
    8000297e:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002982:	46a5                	li	a3,9
    80002984:	fed792e3          	bne	a5,a3,80002968 <devintr+0x12>
    int irq = plic_claim();
    80002988:	00003097          	auipc	ra,0x3
    8000298c:	630080e7          	jalr	1584(ra) # 80005fb8 <plic_claim>
    80002990:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002992:	47a9                	li	a5,10
    80002994:	02f50763          	beq	a0,a5,800029c2 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002998:	4785                	li	a5,1
    8000299a:	02f50963          	beq	a0,a5,800029cc <devintr+0x76>
    return 1;
    8000299e:	4505                	li	a0,1
    else if (irq)
    800029a0:	d8f1                	beqz	s1,80002974 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800029a2:	85a6                	mv	a1,s1
    800029a4:	00006517          	auipc	a0,0x6
    800029a8:	95c50513          	addi	a0,a0,-1700 # 80008300 <states.0+0x38>
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	bde080e7          	jalr	-1058(ra) # 8000058a <printf>
      plic_complete(irq);
    800029b4:	8526                	mv	a0,s1
    800029b6:	00003097          	auipc	ra,0x3
    800029ba:	626080e7          	jalr	1574(ra) # 80005fdc <plic_complete>
    return 1;
    800029be:	4505                	li	a0,1
    800029c0:	bf55                	j	80002974 <devintr+0x1e>
      uartintr();
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	fd6080e7          	jalr	-42(ra) # 80000998 <uartintr>
    800029ca:	b7ed                	j	800029b4 <devintr+0x5e>
      virtio_disk_intr();
    800029cc:	00004097          	auipc	ra,0x4
    800029d0:	bc0080e7          	jalr	-1088(ra) # 8000658c <virtio_disk_intr>
    800029d4:	b7c5                	j	800029b4 <devintr+0x5e>
    if (cpuid() == 0)
    800029d6:	fffff097          	auipc	ra,0xfffff
    800029da:	faa080e7          	jalr	-86(ra) # 80001980 <cpuid>
    800029de:	c901                	beqz	a0,800029ee <devintr+0x98>
  asm volatile("csrr %0, sip"
    800029e0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029e4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0"
    800029e6:	14479073          	csrw	sip,a5
    return 2;
    800029ea:	4509                	li	a0,2
    800029ec:	b761                	j	80002974 <devintr+0x1e>
      clockintr();
    800029ee:	00000097          	auipc	ra,0x0
    800029f2:	f14080e7          	jalr	-236(ra) # 80002902 <clockintr>
    800029f6:	b7ed                	j	800029e0 <devintr+0x8a>

00000000800029f8 <usertrap>:
{
    800029f8:	1101                	addi	sp,sp,-32
    800029fa:	ec06                	sd	ra,24(sp)
    800029fc:	e822                	sd	s0,16(sp)
    800029fe:	e426                	sd	s1,8(sp)
    80002a00:	e04a                	sd	s2,0(sp)
    80002a02:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80002a04:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002a08:	1007f793          	andi	a5,a5,256
    80002a0c:	e3b1                	bnez	a5,80002a50 <usertrap+0x58>
  asm volatile("csrw stvec, %0"
    80002a0e:	00003797          	auipc	a5,0x3
    80002a12:	4a278793          	addi	a5,a5,1186 # 80005eb0 <kernelvec>
    80002a16:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a1a:	fffff097          	auipc	ra,0xfffff
    80002a1e:	f92080e7          	jalr	-110(ra) # 800019ac <myproc>
    80002a22:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a24:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc"
    80002a26:	14102773          	csrr	a4,sepc
    80002a2a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause"
    80002a2c:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002a30:	47a1                	li	a5,8
    80002a32:	02f70763          	beq	a4,a5,80002a60 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002a36:	00000097          	auipc	ra,0x0
    80002a3a:	f20080e7          	jalr	-224(ra) # 80002956 <devintr>
    80002a3e:	892a                	mv	s2,a0
    80002a40:	c92d                	beqz	a0,80002ab2 <usertrap+0xba>
  if (killed(p))
    80002a42:	8526                	mv	a0,s1
    80002a44:	00000097          	auipc	ra,0x0
    80002a48:	918080e7          	jalr	-1768(ra) # 8000235c <killed>
    80002a4c:	c555                	beqz	a0,80002af8 <usertrap+0x100>
    80002a4e:	a045                	j	80002aee <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002a50:	00006517          	auipc	a0,0x6
    80002a54:	8d050513          	addi	a0,a0,-1840 # 80008320 <states.0+0x58>
    80002a58:	ffffe097          	auipc	ra,0xffffe
    80002a5c:	ae8080e7          	jalr	-1304(ra) # 80000540 <panic>
    if (killed(p))
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	8fc080e7          	jalr	-1796(ra) # 8000235c <killed>
    80002a68:	ed1d                	bnez	a0,80002aa6 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002a6a:	6cb8                	ld	a4,88(s1)
    80002a6c:	6f1c                	ld	a5,24(a4)
    80002a6e:	0791                	addi	a5,a5,4
    80002a70:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus"
    80002a72:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a76:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002a7a:	10079073          	csrw	sstatus,a5
    syscall();
    80002a7e:	00000097          	auipc	ra,0x0
    80002a82:	322080e7          	jalr	802(ra) # 80002da0 <syscall>
  if (killed(p))
    80002a86:	8526                	mv	a0,s1
    80002a88:	00000097          	auipc	ra,0x0
    80002a8c:	8d4080e7          	jalr	-1836(ra) # 8000235c <killed>
    80002a90:	ed31                	bnez	a0,80002aec <usertrap+0xf4>
  usertrapret();
    80002a92:	00000097          	auipc	ra,0x0
    80002a96:	dda080e7          	jalr	-550(ra) # 8000286c <usertrapret>
}
    80002a9a:	60e2                	ld	ra,24(sp)
    80002a9c:	6442                	ld	s0,16(sp)
    80002a9e:	64a2                	ld	s1,8(sp)
    80002aa0:	6902                	ld	s2,0(sp)
    80002aa2:	6105                	addi	sp,sp,32
    80002aa4:	8082                	ret
      exit(-1);
    80002aa6:	557d                	li	a0,-1
    80002aa8:	fffff097          	auipc	ra,0xfffff
    80002aac:	734080e7          	jalr	1844(ra) # 800021dc <exit>
    80002ab0:	bf6d                	j	80002a6a <usertrap+0x72>
  asm volatile("csrr %0, scause"
    80002ab2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ab6:	5890                	lw	a2,48(s1)
    80002ab8:	00006517          	auipc	a0,0x6
    80002abc:	88850513          	addi	a0,a0,-1912 # 80008340 <states.0+0x78>
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	aca080e7          	jalr	-1334(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002ac8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002acc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ad0:	00006517          	auipc	a0,0x6
    80002ad4:	8a050513          	addi	a0,a0,-1888 # 80008370 <states.0+0xa8>
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	ab2080e7          	jalr	-1358(ra) # 8000058a <printf>
    setkilled(p);
    80002ae0:	8526                	mv	a0,s1
    80002ae2:	00000097          	auipc	ra,0x0
    80002ae6:	84e080e7          	jalr	-1970(ra) # 80002330 <setkilled>
    80002aea:	bf71                	j	80002a86 <usertrap+0x8e>
  if (killed(p))
    80002aec:	4901                	li	s2,0
    exit(-1);
    80002aee:	557d                	li	a0,-1
    80002af0:	fffff097          	auipc	ra,0xfffff
    80002af4:	6ec080e7          	jalr	1772(ra) # 800021dc <exit>
  if (which_dev == 2)
    80002af8:	4789                	li	a5,2
    80002afa:	f8f91ce3          	bne	s2,a5,80002a92 <usertrap+0x9a>
    if (p->interval)
    80002afe:	1904a703          	lw	a4,400(s1)
    80002b02:	cf19                	beqz	a4,80002b20 <usertrap+0x128>
      p->now_ticks++;
    80002b04:	1944a783          	lw	a5,404(s1)
    80002b08:	2785                	addiw	a5,a5,1
    80002b0a:	0007869b          	sext.w	a3,a5
    80002b0e:	18f4aa23          	sw	a5,404(s1)
      if (!p->sigalarm_status && p->interval > 0 && p->now_ticks >= p->interval)
    80002b12:	1a04a783          	lw	a5,416(s1)
    80002b16:	e789                	bnez	a5,80002b20 <usertrap+0x128>
    80002b18:	00e05463          	blez	a4,80002b20 <usertrap+0x128>
    80002b1c:	00e6d763          	bge	a3,a4,80002b2a <usertrap+0x132>
    yield();
    80002b20:	fffff097          	auipc	ra,0xfffff
    80002b24:	54c080e7          	jalr	1356(ra) # 8000206c <yield>
    80002b28:	b7ad                	j	80002a92 <usertrap+0x9a>
        p->now_ticks = 0;
    80002b2a:	1804aa23          	sw	zero,404(s1)
        p->sigalarm_status = 1;
    80002b2e:	4785                	li	a5,1
    80002b30:	1af4a023          	sw	a5,416(s1)
        p->alarm_trapframe = kalloc();
    80002b34:	ffffe097          	auipc	ra,0xffffe
    80002b38:	fb2080e7          	jalr	-78(ra) # 80000ae6 <kalloc>
    80002b3c:	18a4bc23          	sd	a0,408(s1)
        memmove(p->alarm_trapframe, p->trapframe, PGSIZE);
    80002b40:	6605                	lui	a2,0x1
    80002b42:	6cac                	ld	a1,88(s1)
    80002b44:	ffffe097          	auipc	ra,0xffffe
    80002b48:	1ea080e7          	jalr	490(ra) # 80000d2e <memmove>
        p->trapframe->epc = p->handler;
    80002b4c:	6cbc                	ld	a5,88(s1)
    80002b4e:	1884b703          	ld	a4,392(s1)
    80002b52:	ef98                	sd	a4,24(a5)
    80002b54:	b7f1                	j	80002b20 <usertrap+0x128>

0000000080002b56 <kerneltrap>:
{
    80002b56:	7179                	addi	sp,sp,-48
    80002b58:	f406                	sd	ra,40(sp)
    80002b5a:	f022                	sd	s0,32(sp)
    80002b5c:	ec26                	sd	s1,24(sp)
    80002b5e:	e84a                	sd	s2,16(sp)
    80002b60:	e44e                	sd	s3,8(sp)
    80002b62:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc"
    80002b64:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus"
    80002b68:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause"
    80002b6c:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002b70:	1004f793          	andi	a5,s1,256
    80002b74:	cb85                	beqz	a5,80002ba4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus"
    80002b76:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b7a:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002b7c:	ef85                	bnez	a5,80002bb4 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002b7e:	00000097          	auipc	ra,0x0
    80002b82:	dd8080e7          	jalr	-552(ra) # 80002956 <devintr>
    80002b86:	cd1d                	beqz	a0,80002bc4 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b88:	4789                	li	a5,2
    80002b8a:	06f50a63          	beq	a0,a5,80002bfe <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0"
    80002b8e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0"
    80002b92:	10049073          	csrw	sstatus,s1
}
    80002b96:	70a2                	ld	ra,40(sp)
    80002b98:	7402                	ld	s0,32(sp)
    80002b9a:	64e2                	ld	s1,24(sp)
    80002b9c:	6942                	ld	s2,16(sp)
    80002b9e:	69a2                	ld	s3,8(sp)
    80002ba0:	6145                	addi	sp,sp,48
    80002ba2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ba4:	00005517          	auipc	a0,0x5
    80002ba8:	7ec50513          	addi	a0,a0,2028 # 80008390 <states.0+0xc8>
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	994080e7          	jalr	-1644(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bb4:	00006517          	auipc	a0,0x6
    80002bb8:	80450513          	addi	a0,a0,-2044 # 800083b8 <states.0+0xf0>
    80002bbc:	ffffe097          	auipc	ra,0xffffe
    80002bc0:	984080e7          	jalr	-1660(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002bc4:	85ce                	mv	a1,s3
    80002bc6:	00006517          	auipc	a0,0x6
    80002bca:	81250513          	addi	a0,a0,-2030 # 800083d8 <states.0+0x110>
    80002bce:	ffffe097          	auipc	ra,0xffffe
    80002bd2:	9bc080e7          	jalr	-1604(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002bd6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002bda:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bde:	00006517          	auipc	a0,0x6
    80002be2:	80a50513          	addi	a0,a0,-2038 # 800083e8 <states.0+0x120>
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	9a4080e7          	jalr	-1628(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002bee:	00006517          	auipc	a0,0x6
    80002bf2:	81250513          	addi	a0,a0,-2030 # 80008400 <states.0+0x138>
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	94a080e7          	jalr	-1718(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bfe:	fffff097          	auipc	ra,0xfffff
    80002c02:	dae080e7          	jalr	-594(ra) # 800019ac <myproc>
    80002c06:	d541                	beqz	a0,80002b8e <kerneltrap+0x38>
    80002c08:	fffff097          	auipc	ra,0xfffff
    80002c0c:	da4080e7          	jalr	-604(ra) # 800019ac <myproc>
    80002c10:	4d18                	lw	a4,24(a0)
    80002c12:	4791                	li	a5,4
    80002c14:	f6f71de3          	bne	a4,a5,80002b8e <kerneltrap+0x38>
    yield();
    80002c18:	fffff097          	auipc	ra,0xfffff
    80002c1c:	454080e7          	jalr	1108(ra) # 8000206c <yield>
    80002c20:	b7bd                	j	80002b8e <kerneltrap+0x38>

0000000080002c22 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c22:	1101                	addi	sp,sp,-32
    80002c24:	ec06                	sd	ra,24(sp)
    80002c26:	e822                	sd	s0,16(sp)
    80002c28:	e426                	sd	s1,8(sp)
    80002c2a:	1000                	addi	s0,sp,32
    80002c2c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	d7e080e7          	jalr	-642(ra) # 800019ac <myproc>
  switch (n)
    80002c36:	4795                	li	a5,5
    80002c38:	0497e163          	bltu	a5,s1,80002c7a <argraw+0x58>
    80002c3c:	048a                	slli	s1,s1,0x2
    80002c3e:	00005717          	auipc	a4,0x5
    80002c42:	7fa70713          	addi	a4,a4,2042 # 80008438 <states.0+0x170>
    80002c46:	94ba                	add	s1,s1,a4
    80002c48:	409c                	lw	a5,0(s1)
    80002c4a:	97ba                	add	a5,a5,a4
    80002c4c:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002c4e:	6d3c                	ld	a5,88(a0)
    80002c50:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c52:	60e2                	ld	ra,24(sp)
    80002c54:	6442                	ld	s0,16(sp)
    80002c56:	64a2                	ld	s1,8(sp)
    80002c58:	6105                	addi	sp,sp,32
    80002c5a:	8082                	ret
    return p->trapframe->a1;
    80002c5c:	6d3c                	ld	a5,88(a0)
    80002c5e:	7fa8                	ld	a0,120(a5)
    80002c60:	bfcd                	j	80002c52 <argraw+0x30>
    return p->trapframe->a2;
    80002c62:	6d3c                	ld	a5,88(a0)
    80002c64:	63c8                	ld	a0,128(a5)
    80002c66:	b7f5                	j	80002c52 <argraw+0x30>
    return p->trapframe->a3;
    80002c68:	6d3c                	ld	a5,88(a0)
    80002c6a:	67c8                	ld	a0,136(a5)
    80002c6c:	b7dd                	j	80002c52 <argraw+0x30>
    return p->trapframe->a4;
    80002c6e:	6d3c                	ld	a5,88(a0)
    80002c70:	6bc8                	ld	a0,144(a5)
    80002c72:	b7c5                	j	80002c52 <argraw+0x30>
    return p->trapframe->a5;
    80002c74:	6d3c                	ld	a5,88(a0)
    80002c76:	6fc8                	ld	a0,152(a5)
    80002c78:	bfe9                	j	80002c52 <argraw+0x30>
  panic("argraw");
    80002c7a:	00005517          	auipc	a0,0x5
    80002c7e:	79650513          	addi	a0,a0,1942 # 80008410 <states.0+0x148>
    80002c82:	ffffe097          	auipc	ra,0xffffe
    80002c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080002c8a <fetchaddr>:
{
    80002c8a:	1101                	addi	sp,sp,-32
    80002c8c:	ec06                	sd	ra,24(sp)
    80002c8e:	e822                	sd	s0,16(sp)
    80002c90:	e426                	sd	s1,8(sp)
    80002c92:	e04a                	sd	s2,0(sp)
    80002c94:	1000                	addi	s0,sp,32
    80002c96:	84aa                	mv	s1,a0
    80002c98:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	d12080e7          	jalr	-750(ra) # 800019ac <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ca2:	653c                	ld	a5,72(a0)
    80002ca4:	02f4f863          	bgeu	s1,a5,80002cd4 <fetchaddr+0x4a>
    80002ca8:	00848713          	addi	a4,s1,8
    80002cac:	02e7e663          	bltu	a5,a4,80002cd8 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cb0:	46a1                	li	a3,8
    80002cb2:	8626                	mv	a2,s1
    80002cb4:	85ca                	mv	a1,s2
    80002cb6:	6928                	ld	a0,80(a0)
    80002cb8:	fffff097          	auipc	ra,0xfffff
    80002cbc:	a40080e7          	jalr	-1472(ra) # 800016f8 <copyin>
    80002cc0:	00a03533          	snez	a0,a0
    80002cc4:	40a00533          	neg	a0,a0
}
    80002cc8:	60e2                	ld	ra,24(sp)
    80002cca:	6442                	ld	s0,16(sp)
    80002ccc:	64a2                	ld	s1,8(sp)
    80002cce:	6902                	ld	s2,0(sp)
    80002cd0:	6105                	addi	sp,sp,32
    80002cd2:	8082                	ret
    return -1;
    80002cd4:	557d                	li	a0,-1
    80002cd6:	bfcd                	j	80002cc8 <fetchaddr+0x3e>
    80002cd8:	557d                	li	a0,-1
    80002cda:	b7fd                	j	80002cc8 <fetchaddr+0x3e>

0000000080002cdc <fetchstr>:
{
    80002cdc:	7179                	addi	sp,sp,-48
    80002cde:	f406                	sd	ra,40(sp)
    80002ce0:	f022                	sd	s0,32(sp)
    80002ce2:	ec26                	sd	s1,24(sp)
    80002ce4:	e84a                	sd	s2,16(sp)
    80002ce6:	e44e                	sd	s3,8(sp)
    80002ce8:	1800                	addi	s0,sp,48
    80002cea:	892a                	mv	s2,a0
    80002cec:	84ae                	mv	s1,a1
    80002cee:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cf0:	fffff097          	auipc	ra,0xfffff
    80002cf4:	cbc080e7          	jalr	-836(ra) # 800019ac <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cf8:	86ce                	mv	a3,s3
    80002cfa:	864a                	mv	a2,s2
    80002cfc:	85a6                	mv	a1,s1
    80002cfe:	6928                	ld	a0,80(a0)
    80002d00:	fffff097          	auipc	ra,0xfffff
    80002d04:	a86080e7          	jalr	-1402(ra) # 80001786 <copyinstr>
    80002d08:	00054e63          	bltz	a0,80002d24 <fetchstr+0x48>
  return strlen(buf);
    80002d0c:	8526                	mv	a0,s1
    80002d0e:	ffffe097          	auipc	ra,0xffffe
    80002d12:	140080e7          	jalr	320(ra) # 80000e4e <strlen>
}
    80002d16:	70a2                	ld	ra,40(sp)
    80002d18:	7402                	ld	s0,32(sp)
    80002d1a:	64e2                	ld	s1,24(sp)
    80002d1c:	6942                	ld	s2,16(sp)
    80002d1e:	69a2                	ld	s3,8(sp)
    80002d20:	6145                	addi	sp,sp,48
    80002d22:	8082                	ret
    return -1;
    80002d24:	557d                	li	a0,-1
    80002d26:	bfc5                	j	80002d16 <fetchstr+0x3a>

0000000080002d28 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002d28:	1101                	addi	sp,sp,-32
    80002d2a:	ec06                	sd	ra,24(sp)
    80002d2c:	e822                	sd	s0,16(sp)
    80002d2e:	e426                	sd	s1,8(sp)
    80002d30:	1000                	addi	s0,sp,32
    80002d32:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d34:	00000097          	auipc	ra,0x0
    80002d38:	eee080e7          	jalr	-274(ra) # 80002c22 <argraw>
    80002d3c:	c088                	sw	a0,0(s1)
}
    80002d3e:	60e2                	ld	ra,24(sp)
    80002d40:	6442                	ld	s0,16(sp)
    80002d42:	64a2                	ld	s1,8(sp)
    80002d44:	6105                	addi	sp,sp,32
    80002d46:	8082                	ret

0000000080002d48 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002d48:	1101                	addi	sp,sp,-32
    80002d4a:	ec06                	sd	ra,24(sp)
    80002d4c:	e822                	sd	s0,16(sp)
    80002d4e:	e426                	sd	s1,8(sp)
    80002d50:	1000                	addi	s0,sp,32
    80002d52:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d54:	00000097          	auipc	ra,0x0
    80002d58:	ece080e7          	jalr	-306(ra) # 80002c22 <argraw>
    80002d5c:	e088                	sd	a0,0(s1)
}
    80002d5e:	60e2                	ld	ra,24(sp)
    80002d60:	6442                	ld	s0,16(sp)
    80002d62:	64a2                	ld	s1,8(sp)
    80002d64:	6105                	addi	sp,sp,32
    80002d66:	8082                	ret

0000000080002d68 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002d68:	7179                	addi	sp,sp,-48
    80002d6a:	f406                	sd	ra,40(sp)
    80002d6c:	f022                	sd	s0,32(sp)
    80002d6e:	ec26                	sd	s1,24(sp)
    80002d70:	e84a                	sd	s2,16(sp)
    80002d72:	1800                	addi	s0,sp,48
    80002d74:	84ae                	mv	s1,a1
    80002d76:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d78:	fd840593          	addi	a1,s0,-40
    80002d7c:	00000097          	auipc	ra,0x0
    80002d80:	fcc080e7          	jalr	-52(ra) # 80002d48 <argaddr>
  return fetchstr(addr, buf, max);
    80002d84:	864a                	mv	a2,s2
    80002d86:	85a6                	mv	a1,s1
    80002d88:	fd843503          	ld	a0,-40(s0)
    80002d8c:	00000097          	auipc	ra,0x0
    80002d90:	f50080e7          	jalr	-176(ra) # 80002cdc <fetchstr>
}
    80002d94:	70a2                	ld	ra,40(sp)
    80002d96:	7402                	ld	s0,32(sp)
    80002d98:	64e2                	ld	s1,24(sp)
    80002d9a:	6942                	ld	s2,16(sp)
    80002d9c:	6145                	addi	sp,sp,48
    80002d9e:	8082                	ret

0000000080002da0 <syscall>:
    [SYS_sigreturn] sys_sigreturn,
    [SYS_waitx] sys_waitx,
};

void syscall(void)
{
    80002da0:	1101                	addi	sp,sp,-32
    80002da2:	ec06                	sd	ra,24(sp)
    80002da4:	e822                	sd	s0,16(sp)
    80002da6:	e426                	sd	s1,8(sp)
    80002da8:	e04a                	sd	s2,0(sp)
    80002daa:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dac:	fffff097          	auipc	ra,0xfffff
    80002db0:	c00080e7          	jalr	-1024(ra) # 800019ac <myproc>
    80002db4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002db6:	05853903          	ld	s2,88(a0)
    80002dba:	0a893783          	ld	a5,168(s2)
    80002dbe:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002dc2:	37fd                	addiw	a5,a5,-1
    80002dc4:	475d                	li	a4,23
    80002dc6:	00f76f63          	bltu	a4,a5,80002de4 <syscall+0x44>
    80002dca:	00369713          	slli	a4,a3,0x3
    80002dce:	00005797          	auipc	a5,0x5
    80002dd2:	68278793          	addi	a5,a5,1666 # 80008450 <syscalls>
    80002dd6:	97ba                	add	a5,a5,a4
    80002dd8:	639c                	ld	a5,0(a5)
    80002dda:	c789                	beqz	a5,80002de4 <syscall+0x44>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ddc:	9782                	jalr	a5
    80002dde:	06a93823          	sd	a0,112(s2)
    80002de2:	a839                	j	80002e00 <syscall+0x60>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002de4:	15848613          	addi	a2,s1,344
    80002de8:	588c                	lw	a1,48(s1)
    80002dea:	00005517          	auipc	a0,0x5
    80002dee:	62e50513          	addi	a0,a0,1582 # 80008418 <states.0+0x150>
    80002df2:	ffffd097          	auipc	ra,0xffffd
    80002df6:	798080e7          	jalr	1944(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dfa:	6cbc                	ld	a5,88(s1)
    80002dfc:	577d                	li	a4,-1
    80002dfe:	fbb8                	sd	a4,112(a5)
  }
}
    80002e00:	60e2                	ld	ra,24(sp)
    80002e02:	6442                	ld	s0,16(sp)
    80002e04:	64a2                	ld	s1,8(sp)
    80002e06:	6902                	ld	s2,0(sp)
    80002e08:	6105                	addi	sp,sp,32
    80002e0a:	8082                	ret

0000000080002e0c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e0c:	1101                	addi	sp,sp,-32
    80002e0e:	ec06                	sd	ra,24(sp)
    80002e10:	e822                	sd	s0,16(sp)
    80002e12:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e14:	fec40593          	addi	a1,s0,-20
    80002e18:	4501                	li	a0,0
    80002e1a:	00000097          	auipc	ra,0x0
    80002e1e:	f0e080e7          	jalr	-242(ra) # 80002d28 <argint>
  exit(n);
    80002e22:	fec42503          	lw	a0,-20(s0)
    80002e26:	fffff097          	auipc	ra,0xfffff
    80002e2a:	3b6080e7          	jalr	950(ra) # 800021dc <exit>
  return 0; // not reached
}
    80002e2e:	4501                	li	a0,0
    80002e30:	60e2                	ld	ra,24(sp)
    80002e32:	6442                	ld	s0,16(sp)
    80002e34:	6105                	addi	sp,sp,32
    80002e36:	8082                	ret

0000000080002e38 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e38:	1141                	addi	sp,sp,-16
    80002e3a:	e406                	sd	ra,8(sp)
    80002e3c:	e022                	sd	s0,0(sp)
    80002e3e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e40:	fffff097          	auipc	ra,0xfffff
    80002e44:	b6c080e7          	jalr	-1172(ra) # 800019ac <myproc>
}
    80002e48:	5908                	lw	a0,48(a0)
    80002e4a:	60a2                	ld	ra,8(sp)
    80002e4c:	6402                	ld	s0,0(sp)
    80002e4e:	0141                	addi	sp,sp,16
    80002e50:	8082                	ret

0000000080002e52 <sys_fork>:

uint64
sys_fork(void)
{
    80002e52:	1141                	addi	sp,sp,-16
    80002e54:	e406                	sd	ra,8(sp)
    80002e56:	e022                	sd	s0,0(sp)
    80002e58:	0800                	addi	s0,sp,16
  return fork();
    80002e5a:	fffff097          	auipc	ra,0xfffff
    80002e5e:	f5c080e7          	jalr	-164(ra) # 80001db6 <fork>
}
    80002e62:	60a2                	ld	ra,8(sp)
    80002e64:	6402                	ld	s0,0(sp)
    80002e66:	0141                	addi	sp,sp,16
    80002e68:	8082                	ret

0000000080002e6a <sys_wait>:

uint64
sys_wait(void)
{
    80002e6a:	1101                	addi	sp,sp,-32
    80002e6c:	ec06                	sd	ra,24(sp)
    80002e6e:	e822                	sd	s0,16(sp)
    80002e70:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e72:	fe840593          	addi	a1,s0,-24
    80002e76:	4501                	li	a0,0
    80002e78:	00000097          	auipc	ra,0x0
    80002e7c:	ed0080e7          	jalr	-304(ra) # 80002d48 <argaddr>
  return wait(p);
    80002e80:	fe843503          	ld	a0,-24(s0)
    80002e84:	fffff097          	auipc	ra,0xfffff
    80002e88:	50a080e7          	jalr	1290(ra) # 8000238e <wait>
}
    80002e8c:	60e2                	ld	ra,24(sp)
    80002e8e:	6442                	ld	s0,16(sp)
    80002e90:	6105                	addi	sp,sp,32
    80002e92:	8082                	ret

0000000080002e94 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e94:	7179                	addi	sp,sp,-48
    80002e96:	f406                	sd	ra,40(sp)
    80002e98:	f022                	sd	s0,32(sp)
    80002e9a:	ec26                	sd	s1,24(sp)
    80002e9c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002e9e:	fdc40593          	addi	a1,s0,-36
    80002ea2:	4501                	li	a0,0
    80002ea4:	00000097          	auipc	ra,0x0
    80002ea8:	e84080e7          	jalr	-380(ra) # 80002d28 <argint>
  addr = myproc()->sz;
    80002eac:	fffff097          	auipc	ra,0xfffff
    80002eb0:	b00080e7          	jalr	-1280(ra) # 800019ac <myproc>
    80002eb4:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002eb6:	fdc42503          	lw	a0,-36(s0)
    80002eba:	fffff097          	auipc	ra,0xfffff
    80002ebe:	ea0080e7          	jalr	-352(ra) # 80001d5a <growproc>
    80002ec2:	00054863          	bltz	a0,80002ed2 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002ec6:	8526                	mv	a0,s1
    80002ec8:	70a2                	ld	ra,40(sp)
    80002eca:	7402                	ld	s0,32(sp)
    80002ecc:	64e2                	ld	s1,24(sp)
    80002ece:	6145                	addi	sp,sp,48
    80002ed0:	8082                	ret
    return -1;
    80002ed2:	54fd                	li	s1,-1
    80002ed4:	bfcd                	j	80002ec6 <sys_sbrk+0x32>

0000000080002ed6 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ed6:	7139                	addi	sp,sp,-64
    80002ed8:	fc06                	sd	ra,56(sp)
    80002eda:	f822                	sd	s0,48(sp)
    80002edc:	f426                	sd	s1,40(sp)
    80002ede:	f04a                	sd	s2,32(sp)
    80002ee0:	ec4e                	sd	s3,24(sp)
    80002ee2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ee4:	fcc40593          	addi	a1,s0,-52
    80002ee8:	4501                	li	a0,0
    80002eea:	00000097          	auipc	ra,0x0
    80002eee:	e3e080e7          	jalr	-450(ra) # 80002d28 <argint>
  acquire(&tickslock);
    80002ef2:	00015517          	auipc	a0,0x15
    80002ef6:	4d650513          	addi	a0,a0,1238 # 800183c8 <tickslock>
    80002efa:	ffffe097          	auipc	ra,0xffffe
    80002efe:	cdc080e7          	jalr	-804(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002f02:	00006917          	auipc	s2,0x6
    80002f06:	9fe92903          	lw	s2,-1538(s2) # 80008900 <ticks>
  while (ticks - ticks0 < n)
    80002f0a:	fcc42783          	lw	a5,-52(s0)
    80002f0e:	cf9d                	beqz	a5,80002f4c <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f10:	00015997          	auipc	s3,0x15
    80002f14:	4b898993          	addi	s3,s3,1208 # 800183c8 <tickslock>
    80002f18:	00006497          	auipc	s1,0x6
    80002f1c:	9e848493          	addi	s1,s1,-1560 # 80008900 <ticks>
    if (killed(myproc()))
    80002f20:	fffff097          	auipc	ra,0xfffff
    80002f24:	a8c080e7          	jalr	-1396(ra) # 800019ac <myproc>
    80002f28:	fffff097          	auipc	ra,0xfffff
    80002f2c:	434080e7          	jalr	1076(ra) # 8000235c <killed>
    80002f30:	ed15                	bnez	a0,80002f6c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f32:	85ce                	mv	a1,s3
    80002f34:	8526                	mv	a0,s1
    80002f36:	fffff097          	auipc	ra,0xfffff
    80002f3a:	172080e7          	jalr	370(ra) # 800020a8 <sleep>
  while (ticks - ticks0 < n)
    80002f3e:	409c                	lw	a5,0(s1)
    80002f40:	412787bb          	subw	a5,a5,s2
    80002f44:	fcc42703          	lw	a4,-52(s0)
    80002f48:	fce7ece3          	bltu	a5,a4,80002f20 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002f4c:	00015517          	auipc	a0,0x15
    80002f50:	47c50513          	addi	a0,a0,1148 # 800183c8 <tickslock>
    80002f54:	ffffe097          	auipc	ra,0xffffe
    80002f58:	d36080e7          	jalr	-714(ra) # 80000c8a <release>
  return 0;
    80002f5c:	4501                	li	a0,0
}
    80002f5e:	70e2                	ld	ra,56(sp)
    80002f60:	7442                	ld	s0,48(sp)
    80002f62:	74a2                	ld	s1,40(sp)
    80002f64:	7902                	ld	s2,32(sp)
    80002f66:	69e2                	ld	s3,24(sp)
    80002f68:	6121                	addi	sp,sp,64
    80002f6a:	8082                	ret
      release(&tickslock);
    80002f6c:	00015517          	auipc	a0,0x15
    80002f70:	45c50513          	addi	a0,a0,1116 # 800183c8 <tickslock>
    80002f74:	ffffe097          	auipc	ra,0xffffe
    80002f78:	d16080e7          	jalr	-746(ra) # 80000c8a <release>
      return -1;
    80002f7c:	557d                	li	a0,-1
    80002f7e:	b7c5                	j	80002f5e <sys_sleep+0x88>

0000000080002f80 <sys_kill>:

uint64
sys_kill(void)
{
    80002f80:	1101                	addi	sp,sp,-32
    80002f82:	ec06                	sd	ra,24(sp)
    80002f84:	e822                	sd	s0,16(sp)
    80002f86:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f88:	fec40593          	addi	a1,s0,-20
    80002f8c:	4501                	li	a0,0
    80002f8e:	00000097          	auipc	ra,0x0
    80002f92:	d9a080e7          	jalr	-614(ra) # 80002d28 <argint>
  return kill(pid);
    80002f96:	fec42503          	lw	a0,-20(s0)
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	324080e7          	jalr	804(ra) # 800022be <kill>
}
    80002fa2:	60e2                	ld	ra,24(sp)
    80002fa4:	6442                	ld	s0,16(sp)
    80002fa6:	6105                	addi	sp,sp,32
    80002fa8:	8082                	ret

0000000080002faa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002faa:	1101                	addi	sp,sp,-32
    80002fac:	ec06                	sd	ra,24(sp)
    80002fae:	e822                	sd	s0,16(sp)
    80002fb0:	e426                	sd	s1,8(sp)
    80002fb2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fb4:	00015517          	auipc	a0,0x15
    80002fb8:	41450513          	addi	a0,a0,1044 # 800183c8 <tickslock>
    80002fbc:	ffffe097          	auipc	ra,0xffffe
    80002fc0:	c1a080e7          	jalr	-998(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002fc4:	00006497          	auipc	s1,0x6
    80002fc8:	93c4a483          	lw	s1,-1732(s1) # 80008900 <ticks>
  release(&tickslock);
    80002fcc:	00015517          	auipc	a0,0x15
    80002fd0:	3fc50513          	addi	a0,a0,1020 # 800183c8 <tickslock>
    80002fd4:	ffffe097          	auipc	ra,0xffffe
    80002fd8:	cb6080e7          	jalr	-842(ra) # 80000c8a <release>
  return xticks;
}
    80002fdc:	02049513          	slli	a0,s1,0x20
    80002fe0:	9101                	srli	a0,a0,0x20
    80002fe2:	60e2                	ld	ra,24(sp)
    80002fe4:	6442                	ld	s0,16(sp)
    80002fe6:	64a2                	ld	s1,8(sp)
    80002fe8:	6105                	addi	sp,sp,32
    80002fea:	8082                	ret

0000000080002fec <sys_sigalarm>:

// sigalarm
uint64 sys_sigalarm(void)
{
    80002fec:	1101                	addi	sp,sp,-32
    80002fee:	ec06                	sd	ra,24(sp)
    80002ff0:	e822                	sd	s0,16(sp)
    80002ff2:	1000                	addi	s0,sp,32
  int interval;
  uint64 fn;
  argint(0, &interval);
    80002ff4:	fec40593          	addi	a1,s0,-20
    80002ff8:	4501                	li	a0,0
    80002ffa:	00000097          	auipc	ra,0x0
    80002ffe:	d2e080e7          	jalr	-722(ra) # 80002d28 <argint>
  argaddr(1, &fn);
    80003002:	fe040593          	addi	a1,s0,-32
    80003006:	4505                	li	a0,1
    80003008:	00000097          	auipc	ra,0x0
    8000300c:	d40080e7          	jalr	-704(ra) # 80002d48 <argaddr>

  struct proc *p = myproc();
    80003010:	fffff097          	auipc	ra,0xfffff
    80003014:	99c080e7          	jalr	-1636(ra) # 800019ac <myproc>

  p->sigalarm_status = 0;
    80003018:	1a052023          	sw	zero,416(a0)
  p->interval = interval;
    8000301c:	fec42783          	lw	a5,-20(s0)
    80003020:	18f52823          	sw	a5,400(a0)
  p->now_ticks = 0;
    80003024:	18052a23          	sw	zero,404(a0)
  p->handler = fn;
    80003028:	fe043783          	ld	a5,-32(s0)
    8000302c:	18f53423          	sd	a5,392(a0)

  return 0;
}
    80003030:	4501                	li	a0,0
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	6105                	addi	sp,sp,32
    80003038:	8082                	ret

000000008000303a <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    8000303a:	1101                	addi	sp,sp,-32
    8000303c:	ec06                	sd	ra,24(sp)
    8000303e:	e822                	sd	s0,16(sp)
    80003040:	e426                	sd	s1,8(sp)
    80003042:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003044:	fffff097          	auipc	ra,0xfffff
    80003048:	968080e7          	jalr	-1688(ra) # 800019ac <myproc>
    8000304c:	84aa                	mv	s1,a0

  // Restore Kernel Values
  memmove(p->trapframe, p->alarm_trapframe, PGSIZE);
    8000304e:	6605                	lui	a2,0x1
    80003050:	19853583          	ld	a1,408(a0)
    80003054:	6d28                	ld	a0,88(a0)
    80003056:	ffffe097          	auipc	ra,0xffffe
    8000305a:	cd8080e7          	jalr	-808(ra) # 80000d2e <memmove>
  kfree(p->alarm_trapframe);
    8000305e:	1984b503          	ld	a0,408(s1)
    80003062:	ffffe097          	auipc	ra,0xffffe
    80003066:	986080e7          	jalr	-1658(ra) # 800009e8 <kfree>

  p->sigalarm_status = 0;
    8000306a:	1a04a023          	sw	zero,416(s1)
  p->alarm_trapframe = 0;
    8000306e:	1804bc23          	sd	zero,408(s1)
  p->now_ticks = 0;
    80003072:	1804aa23          	sw	zero,404(s1)
  usertrapret();
    80003076:	fffff097          	auipc	ra,0xfffff
    8000307a:	7f6080e7          	jalr	2038(ra) # 8000286c <usertrapret>
  return 0;
}
    8000307e:	4501                	li	a0,0
    80003080:	60e2                	ld	ra,24(sp)
    80003082:	6442                	ld	s0,16(sp)
    80003084:	64a2                	ld	s1,8(sp)
    80003086:	6105                	addi	sp,sp,32
    80003088:	8082                	ret

000000008000308a <sys_waitx>:

uint64
sys_waitx(void)
{
    8000308a:	7139                	addi	sp,sp,-64
    8000308c:	fc06                	sd	ra,56(sp)
    8000308e:	f822                	sd	s0,48(sp)
    80003090:	f426                	sd	s1,40(sp)
    80003092:	f04a                	sd	s2,32(sp)
    80003094:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003096:	fd840593          	addi	a1,s0,-40
    8000309a:	4501                	li	a0,0
    8000309c:	00000097          	auipc	ra,0x0
    800030a0:	cac080e7          	jalr	-852(ra) # 80002d48 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800030a4:	fd040593          	addi	a1,s0,-48
    800030a8:	4505                	li	a0,1
    800030aa:	00000097          	auipc	ra,0x0
    800030ae:	c9e080e7          	jalr	-866(ra) # 80002d48 <argaddr>
  argaddr(2, &addr2);
    800030b2:	fc840593          	addi	a1,s0,-56
    800030b6:	4509                	li	a0,2
    800030b8:	00000097          	auipc	ra,0x0
    800030bc:	c90080e7          	jalr	-880(ra) # 80002d48 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800030c0:	fc040613          	addi	a2,s0,-64
    800030c4:	fc440593          	addi	a1,s0,-60
    800030c8:	fd843503          	ld	a0,-40(s0)
    800030cc:	fffff097          	auipc	ra,0xfffff
    800030d0:	54c080e7          	jalr	1356(ra) # 80002618 <waitx>
    800030d4:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800030d6:	fffff097          	auipc	ra,0xfffff
    800030da:	8d6080e7          	jalr	-1834(ra) # 800019ac <myproc>
    800030de:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030e0:	4691                	li	a3,4
    800030e2:	fc440613          	addi	a2,s0,-60
    800030e6:	fd043583          	ld	a1,-48(s0)
    800030ea:	6928                	ld	a0,80(a0)
    800030ec:	ffffe097          	auipc	ra,0xffffe
    800030f0:	580080e7          	jalr	1408(ra) # 8000166c <copyout>
    return -1;
    800030f4:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030f6:	00054f63          	bltz	a0,80003114 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800030fa:	4691                	li	a3,4
    800030fc:	fc040613          	addi	a2,s0,-64
    80003100:	fc843583          	ld	a1,-56(s0)
    80003104:	68a8                	ld	a0,80(s1)
    80003106:	ffffe097          	auipc	ra,0xffffe
    8000310a:	566080e7          	jalr	1382(ra) # 8000166c <copyout>
    8000310e:	00054a63          	bltz	a0,80003122 <sys_waitx+0x98>
    return -1;
  return ret;
    80003112:	87ca                	mv	a5,s2
    80003114:	853e                	mv	a0,a5
    80003116:	70e2                	ld	ra,56(sp)
    80003118:	7442                	ld	s0,48(sp)
    8000311a:	74a2                	ld	s1,40(sp)
    8000311c:	7902                	ld	s2,32(sp)
    8000311e:	6121                	addi	sp,sp,64
    80003120:	8082                	ret
    return -1;
    80003122:	57fd                	li	a5,-1
    80003124:	bfc5                	j	80003114 <sys_waitx+0x8a>

0000000080003126 <binit>:
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void binit(void)
{
    80003126:	7179                	addi	sp,sp,-48
    80003128:	f406                	sd	ra,40(sp)
    8000312a:	f022                	sd	s0,32(sp)
    8000312c:	ec26                	sd	s1,24(sp)
    8000312e:	e84a                	sd	s2,16(sp)
    80003130:	e44e                	sd	s3,8(sp)
    80003132:	e052                	sd	s4,0(sp)
    80003134:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003136:	00005597          	auipc	a1,0x5
    8000313a:	3e258593          	addi	a1,a1,994 # 80008518 <syscalls+0xc8>
    8000313e:	00015517          	auipc	a0,0x15
    80003142:	2a250513          	addi	a0,a0,674 # 800183e0 <bcache>
    80003146:	ffffe097          	auipc	ra,0xffffe
    8000314a:	a00080e7          	jalr	-1536(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000314e:	0001d797          	auipc	a5,0x1d
    80003152:	29278793          	addi	a5,a5,658 # 800203e0 <bcache+0x8000>
    80003156:	0001d717          	auipc	a4,0x1d
    8000315a:	4f270713          	addi	a4,a4,1266 # 80020648 <bcache+0x8268>
    8000315e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003162:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    80003166:	00015497          	auipc	s1,0x15
    8000316a:	29248493          	addi	s1,s1,658 # 800183f8 <bcache+0x18>
  {
    b->next = bcache.head.next;
    8000316e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003170:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003172:	00005a17          	auipc	s4,0x5
    80003176:	3aea0a13          	addi	s4,s4,942 # 80008520 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000317a:	2b893783          	ld	a5,696(s2)
    8000317e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003180:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003184:	85d2                	mv	a1,s4
    80003186:	01048513          	addi	a0,s1,16
    8000318a:	00001097          	auipc	ra,0x1
    8000318e:	4c8080e7          	jalr	1224(ra) # 80004652 <initsleeplock>
    bcache.head.next->prev = b;
    80003192:	2b893783          	ld	a5,696(s2)
    80003196:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003198:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    8000319c:	45848493          	addi	s1,s1,1112
    800031a0:	fd349de3          	bne	s1,s3,8000317a <binit+0x54>
  }
}
    800031a4:	70a2                	ld	ra,40(sp)
    800031a6:	7402                	ld	s0,32(sp)
    800031a8:	64e2                	ld	s1,24(sp)
    800031aa:	6942                	ld	s2,16(sp)
    800031ac:	69a2                	ld	s3,8(sp)
    800031ae:	6a02                	ld	s4,0(sp)
    800031b0:	6145                	addi	sp,sp,48
    800031b2:	8082                	ret

00000000800031b4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    800031b4:	7179                	addi	sp,sp,-48
    800031b6:	f406                	sd	ra,40(sp)
    800031b8:	f022                	sd	s0,32(sp)
    800031ba:	ec26                	sd	s1,24(sp)
    800031bc:	e84a                	sd	s2,16(sp)
    800031be:	e44e                	sd	s3,8(sp)
    800031c0:	1800                	addi	s0,sp,48
    800031c2:	892a                	mv	s2,a0
    800031c4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031c6:	00015517          	auipc	a0,0x15
    800031ca:	21a50513          	addi	a0,a0,538 # 800183e0 <bcache>
    800031ce:	ffffe097          	auipc	ra,0xffffe
    800031d2:	a08080e7          	jalr	-1528(ra) # 80000bd6 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next)
    800031d6:	0001d497          	auipc	s1,0x1d
    800031da:	4c24b483          	ld	s1,1218(s1) # 80020698 <bcache+0x82b8>
    800031de:	0001d797          	auipc	a5,0x1d
    800031e2:	46a78793          	addi	a5,a5,1130 # 80020648 <bcache+0x8268>
    800031e6:	02f48f63          	beq	s1,a5,80003224 <bread+0x70>
    800031ea:	873e                	mv	a4,a5
    800031ec:	a021                	j	800031f4 <bread+0x40>
    800031ee:	68a4                	ld	s1,80(s1)
    800031f0:	02e48a63          	beq	s1,a4,80003224 <bread+0x70>
    if (b->dev == dev && b->blockno == blockno)
    800031f4:	449c                	lw	a5,8(s1)
    800031f6:	ff279ce3          	bne	a5,s2,800031ee <bread+0x3a>
    800031fa:	44dc                	lw	a5,12(s1)
    800031fc:	ff3799e3          	bne	a5,s3,800031ee <bread+0x3a>
      b->refcnt++;
    80003200:	40bc                	lw	a5,64(s1)
    80003202:	2785                	addiw	a5,a5,1
    80003204:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003206:	00015517          	auipc	a0,0x15
    8000320a:	1da50513          	addi	a0,a0,474 # 800183e0 <bcache>
    8000320e:	ffffe097          	auipc	ra,0xffffe
    80003212:	a7c080e7          	jalr	-1412(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003216:	01048513          	addi	a0,s1,16
    8000321a:	00001097          	auipc	ra,0x1
    8000321e:	472080e7          	jalr	1138(ra) # 8000468c <acquiresleep>
      return b;
    80003222:	a8b9                	j	80003280 <bread+0xcc>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    80003224:	0001d497          	auipc	s1,0x1d
    80003228:	46c4b483          	ld	s1,1132(s1) # 80020690 <bcache+0x82b0>
    8000322c:	0001d797          	auipc	a5,0x1d
    80003230:	41c78793          	addi	a5,a5,1052 # 80020648 <bcache+0x8268>
    80003234:	00f48863          	beq	s1,a5,80003244 <bread+0x90>
    80003238:	873e                	mv	a4,a5
    if (b->refcnt == 0)
    8000323a:	40bc                	lw	a5,64(s1)
    8000323c:	cf81                	beqz	a5,80003254 <bread+0xa0>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    8000323e:	64a4                	ld	s1,72(s1)
    80003240:	fee49de3          	bne	s1,a4,8000323a <bread+0x86>
  panic("bget: no buffers");
    80003244:	00005517          	auipc	a0,0x5
    80003248:	2e450513          	addi	a0,a0,740 # 80008528 <syscalls+0xd8>
    8000324c:	ffffd097          	auipc	ra,0xffffd
    80003250:	2f4080e7          	jalr	756(ra) # 80000540 <panic>
      b->dev = dev;
    80003254:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003258:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000325c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003260:	4785                	li	a5,1
    80003262:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003264:	00015517          	auipc	a0,0x15
    80003268:	17c50513          	addi	a0,a0,380 # 800183e0 <bcache>
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	a1e080e7          	jalr	-1506(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003274:	01048513          	addi	a0,s1,16
    80003278:	00001097          	auipc	ra,0x1
    8000327c:	414080e7          	jalr	1044(ra) # 8000468c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid)
    80003280:	409c                	lw	a5,0(s1)
    80003282:	cb89                	beqz	a5,80003294 <bread+0xe0>
  {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003284:	8526                	mv	a0,s1
    80003286:	70a2                	ld	ra,40(sp)
    80003288:	7402                	ld	s0,32(sp)
    8000328a:	64e2                	ld	s1,24(sp)
    8000328c:	6942                	ld	s2,16(sp)
    8000328e:	69a2                	ld	s3,8(sp)
    80003290:	6145                	addi	sp,sp,48
    80003292:	8082                	ret
    virtio_disk_rw(b, 0);
    80003294:	4581                	li	a1,0
    80003296:	8526                	mv	a0,s1
    80003298:	00003097          	auipc	ra,0x3
    8000329c:	0c2080e7          	jalr	194(ra) # 8000635a <virtio_disk_rw>
    b->valid = 1;
    800032a0:	4785                	li	a5,1
    800032a2:	c09c                	sw	a5,0(s1)
  return b;
    800032a4:	b7c5                	j	80003284 <bread+0xd0>

00000000800032a6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
    800032a6:	1101                	addi	sp,sp,-32
    800032a8:	ec06                	sd	ra,24(sp)
    800032aa:	e822                	sd	s0,16(sp)
    800032ac:	e426                	sd	s1,8(sp)
    800032ae:	1000                	addi	s0,sp,32
    800032b0:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800032b2:	0541                	addi	a0,a0,16
    800032b4:	00001097          	auipc	ra,0x1
    800032b8:	472080e7          	jalr	1138(ra) # 80004726 <holdingsleep>
    800032bc:	cd01                	beqz	a0,800032d4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032be:	4585                	li	a1,1
    800032c0:	8526                	mv	a0,s1
    800032c2:	00003097          	auipc	ra,0x3
    800032c6:	098080e7          	jalr	152(ra) # 8000635a <virtio_disk_rw>
}
    800032ca:	60e2                	ld	ra,24(sp)
    800032cc:	6442                	ld	s0,16(sp)
    800032ce:	64a2                	ld	s1,8(sp)
    800032d0:	6105                	addi	sp,sp,32
    800032d2:	8082                	ret
    panic("bwrite");
    800032d4:	00005517          	auipc	a0,0x5
    800032d8:	26c50513          	addi	a0,a0,620 # 80008540 <syscalls+0xf0>
    800032dc:	ffffd097          	auipc	ra,0xffffd
    800032e0:	264080e7          	jalr	612(ra) # 80000540 <panic>

00000000800032e4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)
{
    800032e4:	1101                	addi	sp,sp,-32
    800032e6:	ec06                	sd	ra,24(sp)
    800032e8:	e822                	sd	s0,16(sp)
    800032ea:	e426                	sd	s1,8(sp)
    800032ec:	e04a                	sd	s2,0(sp)
    800032ee:	1000                	addi	s0,sp,32
    800032f0:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800032f2:	01050913          	addi	s2,a0,16
    800032f6:	854a                	mv	a0,s2
    800032f8:	00001097          	auipc	ra,0x1
    800032fc:	42e080e7          	jalr	1070(ra) # 80004726 <holdingsleep>
    80003300:	c92d                	beqz	a0,80003372 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003302:	854a                	mv	a0,s2
    80003304:	00001097          	auipc	ra,0x1
    80003308:	3de080e7          	jalr	990(ra) # 800046e2 <releasesleep>

  acquire(&bcache.lock);
    8000330c:	00015517          	auipc	a0,0x15
    80003310:	0d450513          	addi	a0,a0,212 # 800183e0 <bcache>
    80003314:	ffffe097          	auipc	ra,0xffffe
    80003318:	8c2080e7          	jalr	-1854(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000331c:	40bc                	lw	a5,64(s1)
    8000331e:	37fd                	addiw	a5,a5,-1
    80003320:	0007871b          	sext.w	a4,a5
    80003324:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0)
    80003326:	eb05                	bnez	a4,80003356 <brelse+0x72>
  {
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003328:	68bc                	ld	a5,80(s1)
    8000332a:	64b8                	ld	a4,72(s1)
    8000332c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000332e:	64bc                	ld	a5,72(s1)
    80003330:	68b8                	ld	a4,80(s1)
    80003332:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003334:	0001d797          	auipc	a5,0x1d
    80003338:	0ac78793          	addi	a5,a5,172 # 800203e0 <bcache+0x8000>
    8000333c:	2b87b703          	ld	a4,696(a5)
    80003340:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003342:	0001d717          	auipc	a4,0x1d
    80003346:	30670713          	addi	a4,a4,774 # 80020648 <bcache+0x8268>
    8000334a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000334c:	2b87b703          	ld	a4,696(a5)
    80003350:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003352:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80003356:	00015517          	auipc	a0,0x15
    8000335a:	08a50513          	addi	a0,a0,138 # 800183e0 <bcache>
    8000335e:	ffffe097          	auipc	ra,0xffffe
    80003362:	92c080e7          	jalr	-1748(ra) # 80000c8a <release>
}
    80003366:	60e2                	ld	ra,24(sp)
    80003368:	6442                	ld	s0,16(sp)
    8000336a:	64a2                	ld	s1,8(sp)
    8000336c:	6902                	ld	s2,0(sp)
    8000336e:	6105                	addi	sp,sp,32
    80003370:	8082                	ret
    panic("brelse");
    80003372:	00005517          	auipc	a0,0x5
    80003376:	1d650513          	addi	a0,a0,470 # 80008548 <syscalls+0xf8>
    8000337a:	ffffd097          	auipc	ra,0xffffd
    8000337e:	1c6080e7          	jalr	454(ra) # 80000540 <panic>

0000000080003382 <bpin>:

void bpin(struct buf *b)
{
    80003382:	1101                	addi	sp,sp,-32
    80003384:	ec06                	sd	ra,24(sp)
    80003386:	e822                	sd	s0,16(sp)
    80003388:	e426                	sd	s1,8(sp)
    8000338a:	1000                	addi	s0,sp,32
    8000338c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000338e:	00015517          	auipc	a0,0x15
    80003392:	05250513          	addi	a0,a0,82 # 800183e0 <bcache>
    80003396:	ffffe097          	auipc	ra,0xffffe
    8000339a:	840080e7          	jalr	-1984(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000339e:	40bc                	lw	a5,64(s1)
    800033a0:	2785                	addiw	a5,a5,1
    800033a2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033a4:	00015517          	auipc	a0,0x15
    800033a8:	03c50513          	addi	a0,a0,60 # 800183e0 <bcache>
    800033ac:	ffffe097          	auipc	ra,0xffffe
    800033b0:	8de080e7          	jalr	-1826(ra) # 80000c8a <release>
}
    800033b4:	60e2                	ld	ra,24(sp)
    800033b6:	6442                	ld	s0,16(sp)
    800033b8:	64a2                	ld	s1,8(sp)
    800033ba:	6105                	addi	sp,sp,32
    800033bc:	8082                	ret

00000000800033be <bunpin>:

void bunpin(struct buf *b)
{
    800033be:	1101                	addi	sp,sp,-32
    800033c0:	ec06                	sd	ra,24(sp)
    800033c2:	e822                	sd	s0,16(sp)
    800033c4:	e426                	sd	s1,8(sp)
    800033c6:	1000                	addi	s0,sp,32
    800033c8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033ca:	00015517          	auipc	a0,0x15
    800033ce:	01650513          	addi	a0,a0,22 # 800183e0 <bcache>
    800033d2:	ffffe097          	auipc	ra,0xffffe
    800033d6:	804080e7          	jalr	-2044(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800033da:	40bc                	lw	a5,64(s1)
    800033dc:	37fd                	addiw	a5,a5,-1
    800033de:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033e0:	00015517          	auipc	a0,0x15
    800033e4:	00050513          	mv	a0,a0
    800033e8:	ffffe097          	auipc	ra,0xffffe
    800033ec:	8a2080e7          	jalr	-1886(ra) # 80000c8a <release>
}
    800033f0:	60e2                	ld	ra,24(sp)
    800033f2:	6442                	ld	s0,16(sp)
    800033f4:	64a2                	ld	s1,8(sp)
    800033f6:	6105                	addi	sp,sp,32
    800033f8:	8082                	ret

00000000800033fa <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033fa:	1101                	addi	sp,sp,-32
    800033fc:	ec06                	sd	ra,24(sp)
    800033fe:	e822                	sd	s0,16(sp)
    80003400:	e426                	sd	s1,8(sp)
    80003402:	e04a                	sd	s2,0(sp)
    80003404:	1000                	addi	s0,sp,32
    80003406:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003408:	00d5d59b          	srliw	a1,a1,0xd
    8000340c:	0001d797          	auipc	a5,0x1d
    80003410:	6b07a783          	lw	a5,1712(a5) # 80020abc <sb+0x1c>
    80003414:	9dbd                	addw	a1,a1,a5
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	d9e080e7          	jalr	-610(ra) # 800031b4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000341e:	0074f713          	andi	a4,s1,7
    80003422:	4785                	li	a5,1
    80003424:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80003428:	14ce                	slli	s1,s1,0x33
    8000342a:	90d9                	srli	s1,s1,0x36
    8000342c:	00950733          	add	a4,a0,s1
    80003430:	05874703          	lbu	a4,88(a4)
    80003434:	00e7f6b3          	and	a3,a5,a4
    80003438:	c69d                	beqz	a3,80003466 <bfree+0x6c>
    8000343a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    8000343c:	94aa                	add	s1,s1,a0
    8000343e:	fff7c793          	not	a5,a5
    80003442:	8f7d                	and	a4,a4,a5
    80003444:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003448:	00001097          	auipc	ra,0x1
    8000344c:	126080e7          	jalr	294(ra) # 8000456e <log_write>
  brelse(bp);
    80003450:	854a                	mv	a0,s2
    80003452:	00000097          	auipc	ra,0x0
    80003456:	e92080e7          	jalr	-366(ra) # 800032e4 <brelse>
}
    8000345a:	60e2                	ld	ra,24(sp)
    8000345c:	6442                	ld	s0,16(sp)
    8000345e:	64a2                	ld	s1,8(sp)
    80003460:	6902                	ld	s2,0(sp)
    80003462:	6105                	addi	sp,sp,32
    80003464:	8082                	ret
    panic("freeing free block");
    80003466:	00005517          	auipc	a0,0x5
    8000346a:	0ea50513          	addi	a0,a0,234 # 80008550 <syscalls+0x100>
    8000346e:	ffffd097          	auipc	ra,0xffffd
    80003472:	0d2080e7          	jalr	210(ra) # 80000540 <panic>

0000000080003476 <balloc>:
{
    80003476:	711d                	addi	sp,sp,-96
    80003478:	ec86                	sd	ra,88(sp)
    8000347a:	e8a2                	sd	s0,80(sp)
    8000347c:	e4a6                	sd	s1,72(sp)
    8000347e:	e0ca                	sd	s2,64(sp)
    80003480:	fc4e                	sd	s3,56(sp)
    80003482:	f852                	sd	s4,48(sp)
    80003484:	f456                	sd	s5,40(sp)
    80003486:	f05a                	sd	s6,32(sp)
    80003488:	ec5e                	sd	s7,24(sp)
    8000348a:	e862                	sd	s8,16(sp)
    8000348c:	e466                	sd	s9,8(sp)
    8000348e:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB)
    80003490:	0001d797          	auipc	a5,0x1d
    80003494:	6147a783          	lw	a5,1556(a5) # 80020aa4 <sb+0x4>
    80003498:	cff5                	beqz	a5,80003594 <balloc+0x11e>
    8000349a:	8baa                	mv	s7,a0
    8000349c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000349e:	0001db17          	auipc	s6,0x1d
    800034a2:	602b0b13          	addi	s6,s6,1538 # 80020aa0 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800034a6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034a8:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800034aa:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB)
    800034ac:	6c89                	lui	s9,0x2
    800034ae:	a061                	j	80003536 <balloc+0xc0>
        bp->data[bi / 8] |= m; // Mark block in use.
    800034b0:	97ca                	add	a5,a5,s2
    800034b2:	8e55                	or	a2,a2,a3
    800034b4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800034b8:	854a                	mv	a0,s2
    800034ba:	00001097          	auipc	ra,0x1
    800034be:	0b4080e7          	jalr	180(ra) # 8000456e <log_write>
        brelse(bp);
    800034c2:	854a                	mv	a0,s2
    800034c4:	00000097          	auipc	ra,0x0
    800034c8:	e20080e7          	jalr	-480(ra) # 800032e4 <brelse>
  bp = bread(dev, bno);
    800034cc:	85a6                	mv	a1,s1
    800034ce:	855e                	mv	a0,s7
    800034d0:	00000097          	auipc	ra,0x0
    800034d4:	ce4080e7          	jalr	-796(ra) # 800031b4 <bread>
    800034d8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034da:	40000613          	li	a2,1024
    800034de:	4581                	li	a1,0
    800034e0:	05850513          	addi	a0,a0,88
    800034e4:	ffffd097          	auipc	ra,0xffffd
    800034e8:	7ee080e7          	jalr	2030(ra) # 80000cd2 <memset>
  log_write(bp);
    800034ec:	854a                	mv	a0,s2
    800034ee:	00001097          	auipc	ra,0x1
    800034f2:	080080e7          	jalr	128(ra) # 8000456e <log_write>
  brelse(bp);
    800034f6:	854a                	mv	a0,s2
    800034f8:	00000097          	auipc	ra,0x0
    800034fc:	dec080e7          	jalr	-532(ra) # 800032e4 <brelse>
}
    80003500:	8526                	mv	a0,s1
    80003502:	60e6                	ld	ra,88(sp)
    80003504:	6446                	ld	s0,80(sp)
    80003506:	64a6                	ld	s1,72(sp)
    80003508:	6906                	ld	s2,64(sp)
    8000350a:	79e2                	ld	s3,56(sp)
    8000350c:	7a42                	ld	s4,48(sp)
    8000350e:	7aa2                	ld	s5,40(sp)
    80003510:	7b02                	ld	s6,32(sp)
    80003512:	6be2                	ld	s7,24(sp)
    80003514:	6c42                	ld	s8,16(sp)
    80003516:	6ca2                	ld	s9,8(sp)
    80003518:	6125                	addi	sp,sp,96
    8000351a:	8082                	ret
    brelse(bp);
    8000351c:	854a                	mv	a0,s2
    8000351e:	00000097          	auipc	ra,0x0
    80003522:	dc6080e7          	jalr	-570(ra) # 800032e4 <brelse>
  for (b = 0; b < sb.size; b += BPB)
    80003526:	015c87bb          	addw	a5,s9,s5
    8000352a:	00078a9b          	sext.w	s5,a5
    8000352e:	004b2703          	lw	a4,4(s6)
    80003532:	06eaf163          	bgeu	s5,a4,80003594 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003536:	41fad79b          	sraiw	a5,s5,0x1f
    8000353a:	0137d79b          	srliw	a5,a5,0x13
    8000353e:	015787bb          	addw	a5,a5,s5
    80003542:	40d7d79b          	sraiw	a5,a5,0xd
    80003546:	01cb2583          	lw	a1,28(s6)
    8000354a:	9dbd                	addw	a1,a1,a5
    8000354c:	855e                	mv	a0,s7
    8000354e:	00000097          	auipc	ra,0x0
    80003552:	c66080e7          	jalr	-922(ra) # 800031b4 <bread>
    80003556:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003558:	004b2503          	lw	a0,4(s6)
    8000355c:	000a849b          	sext.w	s1,s5
    80003560:	8762                	mv	a4,s8
    80003562:	faa4fde3          	bgeu	s1,a0,8000351c <balloc+0xa6>
      m = 1 << (bi % 8);
    80003566:	00777693          	andi	a3,a4,7
    8000356a:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0)
    8000356e:	41f7579b          	sraiw	a5,a4,0x1f
    80003572:	01d7d79b          	srliw	a5,a5,0x1d
    80003576:	9fb9                	addw	a5,a5,a4
    80003578:	4037d79b          	sraiw	a5,a5,0x3
    8000357c:	00f90633          	add	a2,s2,a5
    80003580:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003584:	00c6f5b3          	and	a1,a3,a2
    80003588:	d585                	beqz	a1,800034b0 <balloc+0x3a>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    8000358a:	2705                	addiw	a4,a4,1
    8000358c:	2485                	addiw	s1,s1,1
    8000358e:	fd471ae3          	bne	a4,s4,80003562 <balloc+0xec>
    80003592:	b769                	j	8000351c <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003594:	00005517          	auipc	a0,0x5
    80003598:	fd450513          	addi	a0,a0,-44 # 80008568 <syscalls+0x118>
    8000359c:	ffffd097          	auipc	ra,0xffffd
    800035a0:	fee080e7          	jalr	-18(ra) # 8000058a <printf>
  return 0;
    800035a4:	4481                	li	s1,0
    800035a6:	bfa9                	j	80003500 <balloc+0x8a>

00000000800035a8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035a8:	7179                	addi	sp,sp,-48
    800035aa:	f406                	sd	ra,40(sp)
    800035ac:	f022                	sd	s0,32(sp)
    800035ae:	ec26                	sd	s1,24(sp)
    800035b0:	e84a                	sd	s2,16(sp)
    800035b2:	e44e                	sd	s3,8(sp)
    800035b4:	e052                	sd	s4,0(sp)
    800035b6:	1800                	addi	s0,sp,48
    800035b8:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT)
    800035ba:	47ad                	li	a5,11
    800035bc:	02b7e863          	bltu	a5,a1,800035ec <bmap+0x44>
  {
    if ((addr = ip->addrs[bn]) == 0)
    800035c0:	02059793          	slli	a5,a1,0x20
    800035c4:	01e7d593          	srli	a1,a5,0x1e
    800035c8:	00b504b3          	add	s1,a0,a1
    800035cc:	0504a903          	lw	s2,80(s1)
    800035d0:	06091e63          	bnez	s2,8000364c <bmap+0xa4>
    {
      addr = balloc(ip->dev);
    800035d4:	4108                	lw	a0,0(a0)
    800035d6:	00000097          	auipc	ra,0x0
    800035da:	ea0080e7          	jalr	-352(ra) # 80003476 <balloc>
    800035de:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    800035e2:	06090563          	beqz	s2,8000364c <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800035e6:	0524a823          	sw	s2,80(s1)
    800035ea:	a08d                	j	8000364c <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035ec:	ff45849b          	addiw	s1,a1,-12
    800035f0:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT)
    800035f4:	0ff00793          	li	a5,255
    800035f8:	08e7e563          	bltu	a5,a4,80003682 <bmap+0xda>
  {
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0)
    800035fc:	08052903          	lw	s2,128(a0)
    80003600:	00091d63          	bnez	s2,8000361a <bmap+0x72>
    {
      addr = balloc(ip->dev);
    80003604:	4108                	lw	a0,0(a0)
    80003606:	00000097          	auipc	ra,0x0
    8000360a:	e70080e7          	jalr	-400(ra) # 80003476 <balloc>
    8000360e:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003612:	02090d63          	beqz	s2,8000364c <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003616:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000361a:	85ca                	mv	a1,s2
    8000361c:	0009a503          	lw	a0,0(s3)
    80003620:	00000097          	auipc	ra,0x0
    80003624:	b94080e7          	jalr	-1132(ra) # 800031b4 <bread>
    80003628:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    8000362a:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0)
    8000362e:	02049713          	slli	a4,s1,0x20
    80003632:	01e75593          	srli	a1,a4,0x1e
    80003636:	00b784b3          	add	s1,a5,a1
    8000363a:	0004a903          	lw	s2,0(s1)
    8000363e:	02090063          	beqz	s2,8000365e <bmap+0xb6>
      {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003642:	8552                	mv	a0,s4
    80003644:	00000097          	auipc	ra,0x0
    80003648:	ca0080e7          	jalr	-864(ra) # 800032e4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000364c:	854a                	mv	a0,s2
    8000364e:	70a2                	ld	ra,40(sp)
    80003650:	7402                	ld	s0,32(sp)
    80003652:	64e2                	ld	s1,24(sp)
    80003654:	6942                	ld	s2,16(sp)
    80003656:	69a2                	ld	s3,8(sp)
    80003658:	6a02                	ld	s4,0(sp)
    8000365a:	6145                	addi	sp,sp,48
    8000365c:	8082                	ret
      addr = balloc(ip->dev);
    8000365e:	0009a503          	lw	a0,0(s3)
    80003662:	00000097          	auipc	ra,0x0
    80003666:	e14080e7          	jalr	-492(ra) # 80003476 <balloc>
    8000366a:	0005091b          	sext.w	s2,a0
      if (addr)
    8000366e:	fc090ae3          	beqz	s2,80003642 <bmap+0x9a>
        a[bn] = addr;
    80003672:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003676:	8552                	mv	a0,s4
    80003678:	00001097          	auipc	ra,0x1
    8000367c:	ef6080e7          	jalr	-266(ra) # 8000456e <log_write>
    80003680:	b7c9                	j	80003642 <bmap+0x9a>
  panic("bmap: out of range");
    80003682:	00005517          	auipc	a0,0x5
    80003686:	efe50513          	addi	a0,a0,-258 # 80008580 <syscalls+0x130>
    8000368a:	ffffd097          	auipc	ra,0xffffd
    8000368e:	eb6080e7          	jalr	-330(ra) # 80000540 <panic>

0000000080003692 <iget>:
{
    80003692:	7179                	addi	sp,sp,-48
    80003694:	f406                	sd	ra,40(sp)
    80003696:	f022                	sd	s0,32(sp)
    80003698:	ec26                	sd	s1,24(sp)
    8000369a:	e84a                	sd	s2,16(sp)
    8000369c:	e44e                	sd	s3,8(sp)
    8000369e:	e052                	sd	s4,0(sp)
    800036a0:	1800                	addi	s0,sp,48
    800036a2:	89aa                	mv	s3,a0
    800036a4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036a6:	0001d517          	auipc	a0,0x1d
    800036aa:	41a50513          	addi	a0,a0,1050 # 80020ac0 <itable>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	528080e7          	jalr	1320(ra) # 80000bd6 <acquire>
  empty = 0;
    800036b6:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    800036b8:	0001d497          	auipc	s1,0x1d
    800036bc:	42048493          	addi	s1,s1,1056 # 80020ad8 <itable+0x18>
    800036c0:	0001f697          	auipc	a3,0x1f
    800036c4:	ea868693          	addi	a3,a3,-344 # 80022568 <log>
    800036c8:	a039                	j	800036d6 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800036ca:	02090b63          	beqz	s2,80003700 <iget+0x6e>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    800036ce:	08848493          	addi	s1,s1,136
    800036d2:	02d48a63          	beq	s1,a3,80003706 <iget+0x74>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum)
    800036d6:	449c                	lw	a5,8(s1)
    800036d8:	fef059e3          	blez	a5,800036ca <iget+0x38>
    800036dc:	4098                	lw	a4,0(s1)
    800036de:	ff3716e3          	bne	a4,s3,800036ca <iget+0x38>
    800036e2:	40d8                	lw	a4,4(s1)
    800036e4:	ff4713e3          	bne	a4,s4,800036ca <iget+0x38>
      ip->ref++;
    800036e8:	2785                	addiw	a5,a5,1
    800036ea:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036ec:	0001d517          	auipc	a0,0x1d
    800036f0:	3d450513          	addi	a0,a0,980 # 80020ac0 <itable>
    800036f4:	ffffd097          	auipc	ra,0xffffd
    800036f8:	596080e7          	jalr	1430(ra) # 80000c8a <release>
      return ip;
    800036fc:	8926                	mv	s2,s1
    800036fe:	a03d                	j	8000372c <iget+0x9a>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003700:	f7f9                	bnez	a5,800036ce <iget+0x3c>
    80003702:	8926                	mv	s2,s1
    80003704:	b7e9                	j	800036ce <iget+0x3c>
  if (empty == 0)
    80003706:	02090c63          	beqz	s2,8000373e <iget+0xac>
  ip->dev = dev;
    8000370a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000370e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003712:	4785                	li	a5,1
    80003714:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003718:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000371c:	0001d517          	auipc	a0,0x1d
    80003720:	3a450513          	addi	a0,a0,932 # 80020ac0 <itable>
    80003724:	ffffd097          	auipc	ra,0xffffd
    80003728:	566080e7          	jalr	1382(ra) # 80000c8a <release>
}
    8000372c:	854a                	mv	a0,s2
    8000372e:	70a2                	ld	ra,40(sp)
    80003730:	7402                	ld	s0,32(sp)
    80003732:	64e2                	ld	s1,24(sp)
    80003734:	6942                	ld	s2,16(sp)
    80003736:	69a2                	ld	s3,8(sp)
    80003738:	6a02                	ld	s4,0(sp)
    8000373a:	6145                	addi	sp,sp,48
    8000373c:	8082                	ret
    panic("iget: no inodes");
    8000373e:	00005517          	auipc	a0,0x5
    80003742:	e5a50513          	addi	a0,a0,-422 # 80008598 <syscalls+0x148>
    80003746:	ffffd097          	auipc	ra,0xffffd
    8000374a:	dfa080e7          	jalr	-518(ra) # 80000540 <panic>

000000008000374e <fsinit>:
{
    8000374e:	7179                	addi	sp,sp,-48
    80003750:	f406                	sd	ra,40(sp)
    80003752:	f022                	sd	s0,32(sp)
    80003754:	ec26                	sd	s1,24(sp)
    80003756:	e84a                	sd	s2,16(sp)
    80003758:	e44e                	sd	s3,8(sp)
    8000375a:	1800                	addi	s0,sp,48
    8000375c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000375e:	4585                	li	a1,1
    80003760:	00000097          	auipc	ra,0x0
    80003764:	a54080e7          	jalr	-1452(ra) # 800031b4 <bread>
    80003768:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000376a:	0001d997          	auipc	s3,0x1d
    8000376e:	33698993          	addi	s3,s3,822 # 80020aa0 <sb>
    80003772:	02000613          	li	a2,32
    80003776:	05850593          	addi	a1,a0,88
    8000377a:	854e                	mv	a0,s3
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	5b2080e7          	jalr	1458(ra) # 80000d2e <memmove>
  brelse(bp);
    80003784:	8526                	mv	a0,s1
    80003786:	00000097          	auipc	ra,0x0
    8000378a:	b5e080e7          	jalr	-1186(ra) # 800032e4 <brelse>
  if (sb.magic != FSMAGIC)
    8000378e:	0009a703          	lw	a4,0(s3)
    80003792:	102037b7          	lui	a5,0x10203
    80003796:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000379a:	02f71263          	bne	a4,a5,800037be <fsinit+0x70>
  initlog(dev, &sb);
    8000379e:	0001d597          	auipc	a1,0x1d
    800037a2:	30258593          	addi	a1,a1,770 # 80020aa0 <sb>
    800037a6:	854a                	mv	a0,s2
    800037a8:	00001097          	auipc	ra,0x1
    800037ac:	b4a080e7          	jalr	-1206(ra) # 800042f2 <initlog>
}
    800037b0:	70a2                	ld	ra,40(sp)
    800037b2:	7402                	ld	s0,32(sp)
    800037b4:	64e2                	ld	s1,24(sp)
    800037b6:	6942                	ld	s2,16(sp)
    800037b8:	69a2                	ld	s3,8(sp)
    800037ba:	6145                	addi	sp,sp,48
    800037bc:	8082                	ret
    panic("invalid file system");
    800037be:	00005517          	auipc	a0,0x5
    800037c2:	dea50513          	addi	a0,a0,-534 # 800085a8 <syscalls+0x158>
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	d7a080e7          	jalr	-646(ra) # 80000540 <panic>

00000000800037ce <iinit>:
{
    800037ce:	7179                	addi	sp,sp,-48
    800037d0:	f406                	sd	ra,40(sp)
    800037d2:	f022                	sd	s0,32(sp)
    800037d4:	ec26                	sd	s1,24(sp)
    800037d6:	e84a                	sd	s2,16(sp)
    800037d8:	e44e                	sd	s3,8(sp)
    800037da:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800037dc:	00005597          	auipc	a1,0x5
    800037e0:	de458593          	addi	a1,a1,-540 # 800085c0 <syscalls+0x170>
    800037e4:	0001d517          	auipc	a0,0x1d
    800037e8:	2dc50513          	addi	a0,a0,732 # 80020ac0 <itable>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	35a080e7          	jalr	858(ra) # 80000b46 <initlock>
  for (i = 0; i < NINODE; i++)
    800037f4:	0001d497          	auipc	s1,0x1d
    800037f8:	2f448493          	addi	s1,s1,756 # 80020ae8 <itable+0x28>
    800037fc:	0001f997          	auipc	s3,0x1f
    80003800:	d7c98993          	addi	s3,s3,-644 # 80022578 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003804:	00005917          	auipc	s2,0x5
    80003808:	dc490913          	addi	s2,s2,-572 # 800085c8 <syscalls+0x178>
    8000380c:	85ca                	mv	a1,s2
    8000380e:	8526                	mv	a0,s1
    80003810:	00001097          	auipc	ra,0x1
    80003814:	e42080e7          	jalr	-446(ra) # 80004652 <initsleeplock>
  for (i = 0; i < NINODE; i++)
    80003818:	08848493          	addi	s1,s1,136
    8000381c:	ff3498e3          	bne	s1,s3,8000380c <iinit+0x3e>
}
    80003820:	70a2                	ld	ra,40(sp)
    80003822:	7402                	ld	s0,32(sp)
    80003824:	64e2                	ld	s1,24(sp)
    80003826:	6942                	ld	s2,16(sp)
    80003828:	69a2                	ld	s3,8(sp)
    8000382a:	6145                	addi	sp,sp,48
    8000382c:	8082                	ret

000000008000382e <ialloc>:
{
    8000382e:	715d                	addi	sp,sp,-80
    80003830:	e486                	sd	ra,72(sp)
    80003832:	e0a2                	sd	s0,64(sp)
    80003834:	fc26                	sd	s1,56(sp)
    80003836:	f84a                	sd	s2,48(sp)
    80003838:	f44e                	sd	s3,40(sp)
    8000383a:	f052                	sd	s4,32(sp)
    8000383c:	ec56                	sd	s5,24(sp)
    8000383e:	e85a                	sd	s6,16(sp)
    80003840:	e45e                	sd	s7,8(sp)
    80003842:	0880                	addi	s0,sp,80
  for (inum = 1; inum < sb.ninodes; inum++)
    80003844:	0001d717          	auipc	a4,0x1d
    80003848:	26872703          	lw	a4,616(a4) # 80020aac <sb+0xc>
    8000384c:	4785                	li	a5,1
    8000384e:	04e7fa63          	bgeu	a5,a4,800038a2 <ialloc+0x74>
    80003852:	8aaa                	mv	s5,a0
    80003854:	8bae                	mv	s7,a1
    80003856:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003858:	0001da17          	auipc	s4,0x1d
    8000385c:	248a0a13          	addi	s4,s4,584 # 80020aa0 <sb>
    80003860:	00048b1b          	sext.w	s6,s1
    80003864:	0044d593          	srli	a1,s1,0x4
    80003868:	018a2783          	lw	a5,24(s4)
    8000386c:	9dbd                	addw	a1,a1,a5
    8000386e:	8556                	mv	a0,s5
    80003870:	00000097          	auipc	ra,0x0
    80003874:	944080e7          	jalr	-1724(ra) # 800031b4 <bread>
    80003878:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000387a:	05850993          	addi	s3,a0,88
    8000387e:	00f4f793          	andi	a5,s1,15
    80003882:	079a                	slli	a5,a5,0x6
    80003884:	99be                	add	s3,s3,a5
    if (dip->type == 0)
    80003886:	00099783          	lh	a5,0(s3)
    8000388a:	c3a1                	beqz	a5,800038ca <ialloc+0x9c>
    brelse(bp);
    8000388c:	00000097          	auipc	ra,0x0
    80003890:	a58080e7          	jalr	-1448(ra) # 800032e4 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++)
    80003894:	0485                	addi	s1,s1,1
    80003896:	00ca2703          	lw	a4,12(s4)
    8000389a:	0004879b          	sext.w	a5,s1
    8000389e:	fce7e1e3          	bltu	a5,a4,80003860 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800038a2:	00005517          	auipc	a0,0x5
    800038a6:	d2e50513          	addi	a0,a0,-722 # 800085d0 <syscalls+0x180>
    800038aa:	ffffd097          	auipc	ra,0xffffd
    800038ae:	ce0080e7          	jalr	-800(ra) # 8000058a <printf>
  return 0;
    800038b2:	4501                	li	a0,0
}
    800038b4:	60a6                	ld	ra,72(sp)
    800038b6:	6406                	ld	s0,64(sp)
    800038b8:	74e2                	ld	s1,56(sp)
    800038ba:	7942                	ld	s2,48(sp)
    800038bc:	79a2                	ld	s3,40(sp)
    800038be:	7a02                	ld	s4,32(sp)
    800038c0:	6ae2                	ld	s5,24(sp)
    800038c2:	6b42                	ld	s6,16(sp)
    800038c4:	6ba2                	ld	s7,8(sp)
    800038c6:	6161                	addi	sp,sp,80
    800038c8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038ca:	04000613          	li	a2,64
    800038ce:	4581                	li	a1,0
    800038d0:	854e                	mv	a0,s3
    800038d2:	ffffd097          	auipc	ra,0xffffd
    800038d6:	400080e7          	jalr	1024(ra) # 80000cd2 <memset>
      dip->type = type;
    800038da:	01799023          	sh	s7,0(s3)
      log_write(bp); // mark it allocated on the disk
    800038de:	854a                	mv	a0,s2
    800038e0:	00001097          	auipc	ra,0x1
    800038e4:	c8e080e7          	jalr	-882(ra) # 8000456e <log_write>
      brelse(bp);
    800038e8:	854a                	mv	a0,s2
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	9fa080e7          	jalr	-1542(ra) # 800032e4 <brelse>
      return iget(dev, inum);
    800038f2:	85da                	mv	a1,s6
    800038f4:	8556                	mv	a0,s5
    800038f6:	00000097          	auipc	ra,0x0
    800038fa:	d9c080e7          	jalr	-612(ra) # 80003692 <iget>
    800038fe:	bf5d                	j	800038b4 <ialloc+0x86>

0000000080003900 <iupdate>:
{
    80003900:	1101                	addi	sp,sp,-32
    80003902:	ec06                	sd	ra,24(sp)
    80003904:	e822                	sd	s0,16(sp)
    80003906:	e426                	sd	s1,8(sp)
    80003908:	e04a                	sd	s2,0(sp)
    8000390a:	1000                	addi	s0,sp,32
    8000390c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000390e:	415c                	lw	a5,4(a0)
    80003910:	0047d79b          	srliw	a5,a5,0x4
    80003914:	0001d597          	auipc	a1,0x1d
    80003918:	1a45a583          	lw	a1,420(a1) # 80020ab8 <sb+0x18>
    8000391c:	9dbd                	addw	a1,a1,a5
    8000391e:	4108                	lw	a0,0(a0)
    80003920:	00000097          	auipc	ra,0x0
    80003924:	894080e7          	jalr	-1900(ra) # 800031b4 <bread>
    80003928:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000392a:	05850793          	addi	a5,a0,88
    8000392e:	40d8                	lw	a4,4(s1)
    80003930:	8b3d                	andi	a4,a4,15
    80003932:	071a                	slli	a4,a4,0x6
    80003934:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003936:	04449703          	lh	a4,68(s1)
    8000393a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000393e:	04649703          	lh	a4,70(s1)
    80003942:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003946:	04849703          	lh	a4,72(s1)
    8000394a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000394e:	04a49703          	lh	a4,74(s1)
    80003952:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003956:	44f8                	lw	a4,76(s1)
    80003958:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000395a:	03400613          	li	a2,52
    8000395e:	05048593          	addi	a1,s1,80
    80003962:	00c78513          	addi	a0,a5,12
    80003966:	ffffd097          	auipc	ra,0xffffd
    8000396a:	3c8080e7          	jalr	968(ra) # 80000d2e <memmove>
  log_write(bp);
    8000396e:	854a                	mv	a0,s2
    80003970:	00001097          	auipc	ra,0x1
    80003974:	bfe080e7          	jalr	-1026(ra) # 8000456e <log_write>
  brelse(bp);
    80003978:	854a                	mv	a0,s2
    8000397a:	00000097          	auipc	ra,0x0
    8000397e:	96a080e7          	jalr	-1686(ra) # 800032e4 <brelse>
}
    80003982:	60e2                	ld	ra,24(sp)
    80003984:	6442                	ld	s0,16(sp)
    80003986:	64a2                	ld	s1,8(sp)
    80003988:	6902                	ld	s2,0(sp)
    8000398a:	6105                	addi	sp,sp,32
    8000398c:	8082                	ret

000000008000398e <idup>:
{
    8000398e:	1101                	addi	sp,sp,-32
    80003990:	ec06                	sd	ra,24(sp)
    80003992:	e822                	sd	s0,16(sp)
    80003994:	e426                	sd	s1,8(sp)
    80003996:	1000                	addi	s0,sp,32
    80003998:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000399a:	0001d517          	auipc	a0,0x1d
    8000399e:	12650513          	addi	a0,a0,294 # 80020ac0 <itable>
    800039a2:	ffffd097          	auipc	ra,0xffffd
    800039a6:	234080e7          	jalr	564(ra) # 80000bd6 <acquire>
  ip->ref++;
    800039aa:	449c                	lw	a5,8(s1)
    800039ac:	2785                	addiw	a5,a5,1
    800039ae:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039b0:	0001d517          	auipc	a0,0x1d
    800039b4:	11050513          	addi	a0,a0,272 # 80020ac0 <itable>
    800039b8:	ffffd097          	auipc	ra,0xffffd
    800039bc:	2d2080e7          	jalr	722(ra) # 80000c8a <release>
}
    800039c0:	8526                	mv	a0,s1
    800039c2:	60e2                	ld	ra,24(sp)
    800039c4:	6442                	ld	s0,16(sp)
    800039c6:	64a2                	ld	s1,8(sp)
    800039c8:	6105                	addi	sp,sp,32
    800039ca:	8082                	ret

00000000800039cc <ilock>:
{
    800039cc:	1101                	addi	sp,sp,-32
    800039ce:	ec06                	sd	ra,24(sp)
    800039d0:	e822                	sd	s0,16(sp)
    800039d2:	e426                	sd	s1,8(sp)
    800039d4:	e04a                	sd	s2,0(sp)
    800039d6:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800039d8:	c115                	beqz	a0,800039fc <ilock+0x30>
    800039da:	84aa                	mv	s1,a0
    800039dc:	451c                	lw	a5,8(a0)
    800039de:	00f05f63          	blez	a5,800039fc <ilock+0x30>
  acquiresleep(&ip->lock);
    800039e2:	0541                	addi	a0,a0,16
    800039e4:	00001097          	auipc	ra,0x1
    800039e8:	ca8080e7          	jalr	-856(ra) # 8000468c <acquiresleep>
  if (ip->valid == 0)
    800039ec:	40bc                	lw	a5,64(s1)
    800039ee:	cf99                	beqz	a5,80003a0c <ilock+0x40>
}
    800039f0:	60e2                	ld	ra,24(sp)
    800039f2:	6442                	ld	s0,16(sp)
    800039f4:	64a2                	ld	s1,8(sp)
    800039f6:	6902                	ld	s2,0(sp)
    800039f8:	6105                	addi	sp,sp,32
    800039fa:	8082                	ret
    panic("ilock");
    800039fc:	00005517          	auipc	a0,0x5
    80003a00:	bec50513          	addi	a0,a0,-1044 # 800085e8 <syscalls+0x198>
    80003a04:	ffffd097          	auipc	ra,0xffffd
    80003a08:	b3c080e7          	jalr	-1220(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a0c:	40dc                	lw	a5,4(s1)
    80003a0e:	0047d79b          	srliw	a5,a5,0x4
    80003a12:	0001d597          	auipc	a1,0x1d
    80003a16:	0a65a583          	lw	a1,166(a1) # 80020ab8 <sb+0x18>
    80003a1a:	9dbd                	addw	a1,a1,a5
    80003a1c:	4088                	lw	a0,0(s1)
    80003a1e:	fffff097          	auipc	ra,0xfffff
    80003a22:	796080e7          	jalr	1942(ra) # 800031b4 <bread>
    80003a26:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003a28:	05850593          	addi	a1,a0,88
    80003a2c:	40dc                	lw	a5,4(s1)
    80003a2e:	8bbd                	andi	a5,a5,15
    80003a30:	079a                	slli	a5,a5,0x6
    80003a32:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a34:	00059783          	lh	a5,0(a1)
    80003a38:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a3c:	00259783          	lh	a5,2(a1)
    80003a40:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a44:	00459783          	lh	a5,4(a1)
    80003a48:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a4c:	00659783          	lh	a5,6(a1)
    80003a50:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a54:	459c                	lw	a5,8(a1)
    80003a56:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a58:	03400613          	li	a2,52
    80003a5c:	05b1                	addi	a1,a1,12
    80003a5e:	05048513          	addi	a0,s1,80
    80003a62:	ffffd097          	auipc	ra,0xffffd
    80003a66:	2cc080e7          	jalr	716(ra) # 80000d2e <memmove>
    brelse(bp);
    80003a6a:	854a                	mv	a0,s2
    80003a6c:	00000097          	auipc	ra,0x0
    80003a70:	878080e7          	jalr	-1928(ra) # 800032e4 <brelse>
    ip->valid = 1;
    80003a74:	4785                	li	a5,1
    80003a76:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003a78:	04449783          	lh	a5,68(s1)
    80003a7c:	fbb5                	bnez	a5,800039f0 <ilock+0x24>
      panic("ilock: no type");
    80003a7e:	00005517          	auipc	a0,0x5
    80003a82:	b7250513          	addi	a0,a0,-1166 # 800085f0 <syscalls+0x1a0>
    80003a86:	ffffd097          	auipc	ra,0xffffd
    80003a8a:	aba080e7          	jalr	-1350(ra) # 80000540 <panic>

0000000080003a8e <iunlock>:
{
    80003a8e:	1101                	addi	sp,sp,-32
    80003a90:	ec06                	sd	ra,24(sp)
    80003a92:	e822                	sd	s0,16(sp)
    80003a94:	e426                	sd	s1,8(sp)
    80003a96:	e04a                	sd	s2,0(sp)
    80003a98:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a9a:	c905                	beqz	a0,80003aca <iunlock+0x3c>
    80003a9c:	84aa                	mv	s1,a0
    80003a9e:	01050913          	addi	s2,a0,16
    80003aa2:	854a                	mv	a0,s2
    80003aa4:	00001097          	auipc	ra,0x1
    80003aa8:	c82080e7          	jalr	-894(ra) # 80004726 <holdingsleep>
    80003aac:	cd19                	beqz	a0,80003aca <iunlock+0x3c>
    80003aae:	449c                	lw	a5,8(s1)
    80003ab0:	00f05d63          	blez	a5,80003aca <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	00001097          	auipc	ra,0x1
    80003aba:	c2c080e7          	jalr	-980(ra) # 800046e2 <releasesleep>
}
    80003abe:	60e2                	ld	ra,24(sp)
    80003ac0:	6442                	ld	s0,16(sp)
    80003ac2:	64a2                	ld	s1,8(sp)
    80003ac4:	6902                	ld	s2,0(sp)
    80003ac6:	6105                	addi	sp,sp,32
    80003ac8:	8082                	ret
    panic("iunlock");
    80003aca:	00005517          	auipc	a0,0x5
    80003ace:	b3650513          	addi	a0,a0,-1226 # 80008600 <syscalls+0x1b0>
    80003ad2:	ffffd097          	auipc	ra,0xffffd
    80003ad6:	a6e080e7          	jalr	-1426(ra) # 80000540 <panic>

0000000080003ada <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void itrunc(struct inode *ip)
{
    80003ada:	7179                	addi	sp,sp,-48
    80003adc:	f406                	sd	ra,40(sp)
    80003ade:	f022                	sd	s0,32(sp)
    80003ae0:	ec26                	sd	s1,24(sp)
    80003ae2:	e84a                	sd	s2,16(sp)
    80003ae4:	e44e                	sd	s3,8(sp)
    80003ae6:	e052                	sd	s4,0(sp)
    80003ae8:	1800                	addi	s0,sp,48
    80003aea:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++)
    80003aec:	05050493          	addi	s1,a0,80
    80003af0:	08050913          	addi	s2,a0,128
    80003af4:	a021                	j	80003afc <itrunc+0x22>
    80003af6:	0491                	addi	s1,s1,4
    80003af8:	01248d63          	beq	s1,s2,80003b12 <itrunc+0x38>
  {
    if (ip->addrs[i])
    80003afc:	408c                	lw	a1,0(s1)
    80003afe:	dde5                	beqz	a1,80003af6 <itrunc+0x1c>
    {
      bfree(ip->dev, ip->addrs[i]);
    80003b00:	0009a503          	lw	a0,0(s3)
    80003b04:	00000097          	auipc	ra,0x0
    80003b08:	8f6080e7          	jalr	-1802(ra) # 800033fa <bfree>
      ip->addrs[i] = 0;
    80003b0c:	0004a023          	sw	zero,0(s1)
    80003b10:	b7dd                	j	80003af6 <itrunc+0x1c>
    }
  }

  if (ip->addrs[NDIRECT])
    80003b12:	0809a583          	lw	a1,128(s3)
    80003b16:	e185                	bnez	a1,80003b36 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b18:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b1c:	854e                	mv	a0,s3
    80003b1e:	00000097          	auipc	ra,0x0
    80003b22:	de2080e7          	jalr	-542(ra) # 80003900 <iupdate>
}
    80003b26:	70a2                	ld	ra,40(sp)
    80003b28:	7402                	ld	s0,32(sp)
    80003b2a:	64e2                	ld	s1,24(sp)
    80003b2c:	6942                	ld	s2,16(sp)
    80003b2e:	69a2                	ld	s3,8(sp)
    80003b30:	6a02                	ld	s4,0(sp)
    80003b32:	6145                	addi	sp,sp,48
    80003b34:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b36:	0009a503          	lw	a0,0(s3)
    80003b3a:	fffff097          	auipc	ra,0xfffff
    80003b3e:	67a080e7          	jalr	1658(ra) # 800031b4 <bread>
    80003b42:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++)
    80003b44:	05850493          	addi	s1,a0,88
    80003b48:	45850913          	addi	s2,a0,1112
    80003b4c:	a021                	j	80003b54 <itrunc+0x7a>
    80003b4e:	0491                	addi	s1,s1,4
    80003b50:	01248b63          	beq	s1,s2,80003b66 <itrunc+0x8c>
      if (a[j])
    80003b54:	408c                	lw	a1,0(s1)
    80003b56:	dde5                	beqz	a1,80003b4e <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b58:	0009a503          	lw	a0,0(s3)
    80003b5c:	00000097          	auipc	ra,0x0
    80003b60:	89e080e7          	jalr	-1890(ra) # 800033fa <bfree>
    80003b64:	b7ed                	j	80003b4e <itrunc+0x74>
    brelse(bp);
    80003b66:	8552                	mv	a0,s4
    80003b68:	fffff097          	auipc	ra,0xfffff
    80003b6c:	77c080e7          	jalr	1916(ra) # 800032e4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b70:	0809a583          	lw	a1,128(s3)
    80003b74:	0009a503          	lw	a0,0(s3)
    80003b78:	00000097          	auipc	ra,0x0
    80003b7c:	882080e7          	jalr	-1918(ra) # 800033fa <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b80:	0809a023          	sw	zero,128(s3)
    80003b84:	bf51                	j	80003b18 <itrunc+0x3e>

0000000080003b86 <iput>:
{
    80003b86:	1101                	addi	sp,sp,-32
    80003b88:	ec06                	sd	ra,24(sp)
    80003b8a:	e822                	sd	s0,16(sp)
    80003b8c:	e426                	sd	s1,8(sp)
    80003b8e:	e04a                	sd	s2,0(sp)
    80003b90:	1000                	addi	s0,sp,32
    80003b92:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b94:	0001d517          	auipc	a0,0x1d
    80003b98:	f2c50513          	addi	a0,a0,-212 # 80020ac0 <itable>
    80003b9c:	ffffd097          	auipc	ra,0xffffd
    80003ba0:	03a080e7          	jalr	58(ra) # 80000bd6 <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003ba4:	4498                	lw	a4,8(s1)
    80003ba6:	4785                	li	a5,1
    80003ba8:	02f70363          	beq	a4,a5,80003bce <iput+0x48>
  ip->ref--;
    80003bac:	449c                	lw	a5,8(s1)
    80003bae:	37fd                	addiw	a5,a5,-1
    80003bb0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bb2:	0001d517          	auipc	a0,0x1d
    80003bb6:	f0e50513          	addi	a0,a0,-242 # 80020ac0 <itable>
    80003bba:	ffffd097          	auipc	ra,0xffffd
    80003bbe:	0d0080e7          	jalr	208(ra) # 80000c8a <release>
}
    80003bc2:	60e2                	ld	ra,24(sp)
    80003bc4:	6442                	ld	s0,16(sp)
    80003bc6:	64a2                	ld	s1,8(sp)
    80003bc8:	6902                	ld	s2,0(sp)
    80003bca:	6105                	addi	sp,sp,32
    80003bcc:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003bce:	40bc                	lw	a5,64(s1)
    80003bd0:	dff1                	beqz	a5,80003bac <iput+0x26>
    80003bd2:	04a49783          	lh	a5,74(s1)
    80003bd6:	fbf9                	bnez	a5,80003bac <iput+0x26>
    acquiresleep(&ip->lock);
    80003bd8:	01048913          	addi	s2,s1,16
    80003bdc:	854a                	mv	a0,s2
    80003bde:	00001097          	auipc	ra,0x1
    80003be2:	aae080e7          	jalr	-1362(ra) # 8000468c <acquiresleep>
    release(&itable.lock);
    80003be6:	0001d517          	auipc	a0,0x1d
    80003bea:	eda50513          	addi	a0,a0,-294 # 80020ac0 <itable>
    80003bee:	ffffd097          	auipc	ra,0xffffd
    80003bf2:	09c080e7          	jalr	156(ra) # 80000c8a <release>
    itrunc(ip);
    80003bf6:	8526                	mv	a0,s1
    80003bf8:	00000097          	auipc	ra,0x0
    80003bfc:	ee2080e7          	jalr	-286(ra) # 80003ada <itrunc>
    ip->type = 0;
    80003c00:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c04:	8526                	mv	a0,s1
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	cfa080e7          	jalr	-774(ra) # 80003900 <iupdate>
    ip->valid = 0;
    80003c0e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c12:	854a                	mv	a0,s2
    80003c14:	00001097          	auipc	ra,0x1
    80003c18:	ace080e7          	jalr	-1330(ra) # 800046e2 <releasesleep>
    acquire(&itable.lock);
    80003c1c:	0001d517          	auipc	a0,0x1d
    80003c20:	ea450513          	addi	a0,a0,-348 # 80020ac0 <itable>
    80003c24:	ffffd097          	auipc	ra,0xffffd
    80003c28:	fb2080e7          	jalr	-78(ra) # 80000bd6 <acquire>
    80003c2c:	b741                	j	80003bac <iput+0x26>

0000000080003c2e <iunlockput>:
{
    80003c2e:	1101                	addi	sp,sp,-32
    80003c30:	ec06                	sd	ra,24(sp)
    80003c32:	e822                	sd	s0,16(sp)
    80003c34:	e426                	sd	s1,8(sp)
    80003c36:	1000                	addi	s0,sp,32
    80003c38:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	e54080e7          	jalr	-428(ra) # 80003a8e <iunlock>
  iput(ip);
    80003c42:	8526                	mv	a0,s1
    80003c44:	00000097          	auipc	ra,0x0
    80003c48:	f42080e7          	jalr	-190(ra) # 80003b86 <iput>
}
    80003c4c:	60e2                	ld	ra,24(sp)
    80003c4e:	6442                	ld	s0,16(sp)
    80003c50:	64a2                	ld	s1,8(sp)
    80003c52:	6105                	addi	sp,sp,32
    80003c54:	8082                	ret

0000000080003c56 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void stati(struct inode *ip, struct stat *st)
{
    80003c56:	1141                	addi	sp,sp,-16
    80003c58:	e422                	sd	s0,8(sp)
    80003c5a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c5c:	411c                	lw	a5,0(a0)
    80003c5e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c60:	415c                	lw	a5,4(a0)
    80003c62:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c64:	04451783          	lh	a5,68(a0)
    80003c68:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c6c:	04a51783          	lh	a5,74(a0)
    80003c70:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c74:	04c56783          	lwu	a5,76(a0)
    80003c78:	e99c                	sd	a5,16(a1)
}
    80003c7a:	6422                	ld	s0,8(sp)
    80003c7c:	0141                	addi	sp,sp,16
    80003c7e:	8082                	ret

0000000080003c80 <readi>:
int readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003c80:	457c                	lw	a5,76(a0)
    80003c82:	0ed7e963          	bltu	a5,a3,80003d74 <readi+0xf4>
{
    80003c86:	7159                	addi	sp,sp,-112
    80003c88:	f486                	sd	ra,104(sp)
    80003c8a:	f0a2                	sd	s0,96(sp)
    80003c8c:	eca6                	sd	s1,88(sp)
    80003c8e:	e8ca                	sd	s2,80(sp)
    80003c90:	e4ce                	sd	s3,72(sp)
    80003c92:	e0d2                	sd	s4,64(sp)
    80003c94:	fc56                	sd	s5,56(sp)
    80003c96:	f85a                	sd	s6,48(sp)
    80003c98:	f45e                	sd	s7,40(sp)
    80003c9a:	f062                	sd	s8,32(sp)
    80003c9c:	ec66                	sd	s9,24(sp)
    80003c9e:	e86a                	sd	s10,16(sp)
    80003ca0:	e46e                	sd	s11,8(sp)
    80003ca2:	1880                	addi	s0,sp,112
    80003ca4:	8b2a                	mv	s6,a0
    80003ca6:	8bae                	mv	s7,a1
    80003ca8:	8a32                	mv	s4,a2
    80003caa:	84b6                	mv	s1,a3
    80003cac:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003cae:	9f35                	addw	a4,a4,a3
    return 0;
    80003cb0:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003cb2:	0ad76063          	bltu	a4,a3,80003d52 <readi+0xd2>
  if (off + n > ip->size)
    80003cb6:	00e7f463          	bgeu	a5,a4,80003cbe <readi+0x3e>
    n = ip->size - off;
    80003cba:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003cbe:	0a0a8963          	beqz	s5,80003d70 <readi+0xf0>
    80003cc2:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003cc4:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1)
    80003cc8:	5c7d                	li	s8,-1
    80003cca:	a82d                	j	80003d04 <readi+0x84>
    80003ccc:	020d1d93          	slli	s11,s10,0x20
    80003cd0:	020ddd93          	srli	s11,s11,0x20
    80003cd4:	05890613          	addi	a2,s2,88
    80003cd8:	86ee                	mv	a3,s11
    80003cda:	963a                	add	a2,a2,a4
    80003cdc:	85d2                	mv	a1,s4
    80003cde:	855e                	mv	a0,s7
    80003ce0:	ffffe097          	auipc	ra,0xffffe
    80003ce4:	7dc080e7          	jalr	2012(ra) # 800024bc <either_copyout>
    80003ce8:	05850d63          	beq	a0,s8,80003d42 <readi+0xc2>
    {
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cec:	854a                	mv	a0,s2
    80003cee:	fffff097          	auipc	ra,0xfffff
    80003cf2:	5f6080e7          	jalr	1526(ra) # 800032e4 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003cf6:	013d09bb          	addw	s3,s10,s3
    80003cfa:	009d04bb          	addw	s1,s10,s1
    80003cfe:	9a6e                	add	s4,s4,s11
    80003d00:	0559f763          	bgeu	s3,s5,80003d4e <readi+0xce>
    uint addr = bmap(ip, off / BSIZE);
    80003d04:	00a4d59b          	srliw	a1,s1,0xa
    80003d08:	855a                	mv	a0,s6
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	89e080e7          	jalr	-1890(ra) # 800035a8 <bmap>
    80003d12:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003d16:	cd85                	beqz	a1,80003d4e <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d18:	000b2503          	lw	a0,0(s6)
    80003d1c:	fffff097          	auipc	ra,0xfffff
    80003d20:	498080e7          	jalr	1176(ra) # 800031b4 <bread>
    80003d24:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003d26:	3ff4f713          	andi	a4,s1,1023
    80003d2a:	40ec87bb          	subw	a5,s9,a4
    80003d2e:	413a86bb          	subw	a3,s5,s3
    80003d32:	8d3e                	mv	s10,a5
    80003d34:	2781                	sext.w	a5,a5
    80003d36:	0006861b          	sext.w	a2,a3
    80003d3a:	f8f679e3          	bgeu	a2,a5,80003ccc <readi+0x4c>
    80003d3e:	8d36                	mv	s10,a3
    80003d40:	b771                	j	80003ccc <readi+0x4c>
      brelse(bp);
    80003d42:	854a                	mv	a0,s2
    80003d44:	fffff097          	auipc	ra,0xfffff
    80003d48:	5a0080e7          	jalr	1440(ra) # 800032e4 <brelse>
      tot = -1;
    80003d4c:	59fd                	li	s3,-1
  }
  return tot;
    80003d4e:	0009851b          	sext.w	a0,s3
}
    80003d52:	70a6                	ld	ra,104(sp)
    80003d54:	7406                	ld	s0,96(sp)
    80003d56:	64e6                	ld	s1,88(sp)
    80003d58:	6946                	ld	s2,80(sp)
    80003d5a:	69a6                	ld	s3,72(sp)
    80003d5c:	6a06                	ld	s4,64(sp)
    80003d5e:	7ae2                	ld	s5,56(sp)
    80003d60:	7b42                	ld	s6,48(sp)
    80003d62:	7ba2                	ld	s7,40(sp)
    80003d64:	7c02                	ld	s8,32(sp)
    80003d66:	6ce2                	ld	s9,24(sp)
    80003d68:	6d42                	ld	s10,16(sp)
    80003d6a:	6da2                	ld	s11,8(sp)
    80003d6c:	6165                	addi	sp,sp,112
    80003d6e:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003d70:	89d6                	mv	s3,s5
    80003d72:	bff1                	j	80003d4e <readi+0xce>
    return 0;
    80003d74:	4501                	li	a0,0
}
    80003d76:	8082                	ret

0000000080003d78 <writei>:
int writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003d78:	457c                	lw	a5,76(a0)
    80003d7a:	10d7e863          	bltu	a5,a3,80003e8a <writei+0x112>
{
    80003d7e:	7159                	addi	sp,sp,-112
    80003d80:	f486                	sd	ra,104(sp)
    80003d82:	f0a2                	sd	s0,96(sp)
    80003d84:	eca6                	sd	s1,88(sp)
    80003d86:	e8ca                	sd	s2,80(sp)
    80003d88:	e4ce                	sd	s3,72(sp)
    80003d8a:	e0d2                	sd	s4,64(sp)
    80003d8c:	fc56                	sd	s5,56(sp)
    80003d8e:	f85a                	sd	s6,48(sp)
    80003d90:	f45e                	sd	s7,40(sp)
    80003d92:	f062                	sd	s8,32(sp)
    80003d94:	ec66                	sd	s9,24(sp)
    80003d96:	e86a                	sd	s10,16(sp)
    80003d98:	e46e                	sd	s11,8(sp)
    80003d9a:	1880                	addi	s0,sp,112
    80003d9c:	8aaa                	mv	s5,a0
    80003d9e:	8bae                	mv	s7,a1
    80003da0:	8a32                	mv	s4,a2
    80003da2:	8936                	mv	s2,a3
    80003da4:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003da6:	00e687bb          	addw	a5,a3,a4
    80003daa:	0ed7e263          	bltu	a5,a3,80003e8e <writei+0x116>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003dae:	00043737          	lui	a4,0x43
    80003db2:	0ef76063          	bltu	a4,a5,80003e92 <writei+0x11a>
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003db6:	0c0b0863          	beqz	s6,80003e86 <writei+0x10e>
    80003dba:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003dbc:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1)
    80003dc0:	5c7d                	li	s8,-1
    80003dc2:	a091                	j	80003e06 <writei+0x8e>
    80003dc4:	020d1d93          	slli	s11,s10,0x20
    80003dc8:	020ddd93          	srli	s11,s11,0x20
    80003dcc:	05848513          	addi	a0,s1,88
    80003dd0:	86ee                	mv	a3,s11
    80003dd2:	8652                	mv	a2,s4
    80003dd4:	85de                	mv	a1,s7
    80003dd6:	953a                	add	a0,a0,a4
    80003dd8:	ffffe097          	auipc	ra,0xffffe
    80003ddc:	73a080e7          	jalr	1850(ra) # 80002512 <either_copyin>
    80003de0:	07850263          	beq	a0,s8,80003e44 <writei+0xcc>
    {
      brelse(bp);
      break;
    }
    log_write(bp);
    80003de4:	8526                	mv	a0,s1
    80003de6:	00000097          	auipc	ra,0x0
    80003dea:	788080e7          	jalr	1928(ra) # 8000456e <log_write>
    brelse(bp);
    80003dee:	8526                	mv	a0,s1
    80003df0:	fffff097          	auipc	ra,0xfffff
    80003df4:	4f4080e7          	jalr	1268(ra) # 800032e4 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003df8:	013d09bb          	addw	s3,s10,s3
    80003dfc:	012d093b          	addw	s2,s10,s2
    80003e00:	9a6e                	add	s4,s4,s11
    80003e02:	0569f663          	bgeu	s3,s6,80003e4e <writei+0xd6>
    uint addr = bmap(ip, off / BSIZE);
    80003e06:	00a9559b          	srliw	a1,s2,0xa
    80003e0a:	8556                	mv	a0,s5
    80003e0c:	fffff097          	auipc	ra,0xfffff
    80003e10:	79c080e7          	jalr	1948(ra) # 800035a8 <bmap>
    80003e14:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003e18:	c99d                	beqz	a1,80003e4e <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e1a:	000aa503          	lw	a0,0(s5)
    80003e1e:	fffff097          	auipc	ra,0xfffff
    80003e22:	396080e7          	jalr	918(ra) # 800031b4 <bread>
    80003e26:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003e28:	3ff97713          	andi	a4,s2,1023
    80003e2c:	40ec87bb          	subw	a5,s9,a4
    80003e30:	413b06bb          	subw	a3,s6,s3
    80003e34:	8d3e                	mv	s10,a5
    80003e36:	2781                	sext.w	a5,a5
    80003e38:	0006861b          	sext.w	a2,a3
    80003e3c:	f8f674e3          	bgeu	a2,a5,80003dc4 <writei+0x4c>
    80003e40:	8d36                	mv	s10,a3
    80003e42:	b749                	j	80003dc4 <writei+0x4c>
      brelse(bp);
    80003e44:	8526                	mv	a0,s1
    80003e46:	fffff097          	auipc	ra,0xfffff
    80003e4a:	49e080e7          	jalr	1182(ra) # 800032e4 <brelse>
  }

  if (off > ip->size)
    80003e4e:	04caa783          	lw	a5,76(s5)
    80003e52:	0127f463          	bgeu	a5,s2,80003e5a <writei+0xe2>
    ip->size = off;
    80003e56:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e5a:	8556                	mv	a0,s5
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	aa4080e7          	jalr	-1372(ra) # 80003900 <iupdate>

  return tot;
    80003e64:	0009851b          	sext.w	a0,s3
}
    80003e68:	70a6                	ld	ra,104(sp)
    80003e6a:	7406                	ld	s0,96(sp)
    80003e6c:	64e6                	ld	s1,88(sp)
    80003e6e:	6946                	ld	s2,80(sp)
    80003e70:	69a6                	ld	s3,72(sp)
    80003e72:	6a06                	ld	s4,64(sp)
    80003e74:	7ae2                	ld	s5,56(sp)
    80003e76:	7b42                	ld	s6,48(sp)
    80003e78:	7ba2                	ld	s7,40(sp)
    80003e7a:	7c02                	ld	s8,32(sp)
    80003e7c:	6ce2                	ld	s9,24(sp)
    80003e7e:	6d42                	ld	s10,16(sp)
    80003e80:	6da2                	ld	s11,8(sp)
    80003e82:	6165                	addi	sp,sp,112
    80003e84:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003e86:	89da                	mv	s3,s6
    80003e88:	bfc9                	j	80003e5a <writei+0xe2>
    return -1;
    80003e8a:	557d                	li	a0,-1
}
    80003e8c:	8082                	ret
    return -1;
    80003e8e:	557d                	li	a0,-1
    80003e90:	bfe1                	j	80003e68 <writei+0xf0>
    return -1;
    80003e92:	557d                	li	a0,-1
    80003e94:	bfd1                	j	80003e68 <writei+0xf0>

0000000080003e96 <namecmp>:

// Directories

int namecmp(const char *s, const char *t)
{
    80003e96:	1141                	addi	sp,sp,-16
    80003e98:	e406                	sd	ra,8(sp)
    80003e9a:	e022                	sd	s0,0(sp)
    80003e9c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e9e:	4639                	li	a2,14
    80003ea0:	ffffd097          	auipc	ra,0xffffd
    80003ea4:	f02080e7          	jalr	-254(ra) # 80000da2 <strncmp>
}
    80003ea8:	60a2                	ld	ra,8(sp)
    80003eaa:	6402                	ld	s0,0(sp)
    80003eac:	0141                	addi	sp,sp,16
    80003eae:	8082                	ret

0000000080003eb0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003eb0:	7139                	addi	sp,sp,-64
    80003eb2:	fc06                	sd	ra,56(sp)
    80003eb4:	f822                	sd	s0,48(sp)
    80003eb6:	f426                	sd	s1,40(sp)
    80003eb8:	f04a                	sd	s2,32(sp)
    80003eba:	ec4e                	sd	s3,24(sp)
    80003ebc:	e852                	sd	s4,16(sp)
    80003ebe:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003ec0:	04451703          	lh	a4,68(a0)
    80003ec4:	4785                	li	a5,1
    80003ec6:	00f71a63          	bne	a4,a5,80003eda <dirlookup+0x2a>
    80003eca:	892a                	mv	s2,a0
    80003ecc:	89ae                	mv	s3,a1
    80003ece:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de))
    80003ed0:	457c                	lw	a5,76(a0)
    80003ed2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ed4:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de))
    80003ed6:	e79d                	bnez	a5,80003f04 <dirlookup+0x54>
    80003ed8:	a8a5                	j	80003f50 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003eda:	00004517          	auipc	a0,0x4
    80003ede:	72e50513          	addi	a0,a0,1838 # 80008608 <syscalls+0x1b8>
    80003ee2:	ffffc097          	auipc	ra,0xffffc
    80003ee6:	65e080e7          	jalr	1630(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003eea:	00004517          	auipc	a0,0x4
    80003eee:	73650513          	addi	a0,a0,1846 # 80008620 <syscalls+0x1d0>
    80003ef2:	ffffc097          	auipc	ra,0xffffc
    80003ef6:	64e080e7          	jalr	1614(ra) # 80000540 <panic>
  for (off = 0; off < dp->size; off += sizeof(de))
    80003efa:	24c1                	addiw	s1,s1,16
    80003efc:	04c92783          	lw	a5,76(s2)
    80003f00:	04f4f763          	bgeu	s1,a5,80003f4e <dirlookup+0x9e>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f04:	4741                	li	a4,16
    80003f06:	86a6                	mv	a3,s1
    80003f08:	fc040613          	addi	a2,s0,-64
    80003f0c:	4581                	li	a1,0
    80003f0e:	854a                	mv	a0,s2
    80003f10:	00000097          	auipc	ra,0x0
    80003f14:	d70080e7          	jalr	-656(ra) # 80003c80 <readi>
    80003f18:	47c1                	li	a5,16
    80003f1a:	fcf518e3          	bne	a0,a5,80003eea <dirlookup+0x3a>
    if (de.inum == 0)
    80003f1e:	fc045783          	lhu	a5,-64(s0)
    80003f22:	dfe1                	beqz	a5,80003efa <dirlookup+0x4a>
    if (namecmp(name, de.name) == 0)
    80003f24:	fc240593          	addi	a1,s0,-62
    80003f28:	854e                	mv	a0,s3
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	f6c080e7          	jalr	-148(ra) # 80003e96 <namecmp>
    80003f32:	f561                	bnez	a0,80003efa <dirlookup+0x4a>
      if (poff)
    80003f34:	000a0463          	beqz	s4,80003f3c <dirlookup+0x8c>
        *poff = off;
    80003f38:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f3c:	fc045583          	lhu	a1,-64(s0)
    80003f40:	00092503          	lw	a0,0(s2)
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	74e080e7          	jalr	1870(ra) # 80003692 <iget>
    80003f4c:	a011                	j	80003f50 <dirlookup+0xa0>
  return 0;
    80003f4e:	4501                	li	a0,0
}
    80003f50:	70e2                	ld	ra,56(sp)
    80003f52:	7442                	ld	s0,48(sp)
    80003f54:	74a2                	ld	s1,40(sp)
    80003f56:	7902                	ld	s2,32(sp)
    80003f58:	69e2                	ld	s3,24(sp)
    80003f5a:	6a42                	ld	s4,16(sp)
    80003f5c:	6121                	addi	sp,sp,64
    80003f5e:	8082                	ret

0000000080003f60 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003f60:	711d                	addi	sp,sp,-96
    80003f62:	ec86                	sd	ra,88(sp)
    80003f64:	e8a2                	sd	s0,80(sp)
    80003f66:	e4a6                	sd	s1,72(sp)
    80003f68:	e0ca                	sd	s2,64(sp)
    80003f6a:	fc4e                	sd	s3,56(sp)
    80003f6c:	f852                	sd	s4,48(sp)
    80003f6e:	f456                	sd	s5,40(sp)
    80003f70:	f05a                	sd	s6,32(sp)
    80003f72:	ec5e                	sd	s7,24(sp)
    80003f74:	e862                	sd	s8,16(sp)
    80003f76:	e466                	sd	s9,8(sp)
    80003f78:	e06a                	sd	s10,0(sp)
    80003f7a:	1080                	addi	s0,sp,96
    80003f7c:	84aa                	mv	s1,a0
    80003f7e:	8b2e                	mv	s6,a1
    80003f80:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003f82:	00054703          	lbu	a4,0(a0)
    80003f86:	02f00793          	li	a5,47
    80003f8a:	02f70363          	beq	a4,a5,80003fb0 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f8e:	ffffe097          	auipc	ra,0xffffe
    80003f92:	a1e080e7          	jalr	-1506(ra) # 800019ac <myproc>
    80003f96:	15053503          	ld	a0,336(a0)
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	9f4080e7          	jalr	-1548(ra) # 8000398e <idup>
    80003fa2:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003fa4:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80003fa8:	4cb5                	li	s9,13
  len = path - s;
    80003faa:	4b81                	li	s7,0

  while ((path = skipelem(path, name)) != 0)
  {
    ilock(ip);
    if (ip->type != T_DIR)
    80003fac:	4c05                	li	s8,1
    80003fae:	a87d                	j	8000406c <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003fb0:	4585                	li	a1,1
    80003fb2:	4505                	li	a0,1
    80003fb4:	fffff097          	auipc	ra,0xfffff
    80003fb8:	6de080e7          	jalr	1758(ra) # 80003692 <iget>
    80003fbc:	8a2a                	mv	s4,a0
    80003fbe:	b7dd                	j	80003fa4 <namex+0x44>
    {
      iunlockput(ip);
    80003fc0:	8552                	mv	a0,s4
    80003fc2:	00000097          	auipc	ra,0x0
    80003fc6:	c6c080e7          	jalr	-916(ra) # 80003c2e <iunlockput>
      return 0;
    80003fca:	4a01                	li	s4,0
  {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fcc:	8552                	mv	a0,s4
    80003fce:	60e6                	ld	ra,88(sp)
    80003fd0:	6446                	ld	s0,80(sp)
    80003fd2:	64a6                	ld	s1,72(sp)
    80003fd4:	6906                	ld	s2,64(sp)
    80003fd6:	79e2                	ld	s3,56(sp)
    80003fd8:	7a42                	ld	s4,48(sp)
    80003fda:	7aa2                	ld	s5,40(sp)
    80003fdc:	7b02                	ld	s6,32(sp)
    80003fde:	6be2                	ld	s7,24(sp)
    80003fe0:	6c42                	ld	s8,16(sp)
    80003fe2:	6ca2                	ld	s9,8(sp)
    80003fe4:	6d02                	ld	s10,0(sp)
    80003fe6:	6125                	addi	sp,sp,96
    80003fe8:	8082                	ret
      iunlock(ip);
    80003fea:	8552                	mv	a0,s4
    80003fec:	00000097          	auipc	ra,0x0
    80003ff0:	aa2080e7          	jalr	-1374(ra) # 80003a8e <iunlock>
      return ip;
    80003ff4:	bfe1                	j	80003fcc <namex+0x6c>
      iunlockput(ip);
    80003ff6:	8552                	mv	a0,s4
    80003ff8:	00000097          	auipc	ra,0x0
    80003ffc:	c36080e7          	jalr	-970(ra) # 80003c2e <iunlockput>
      return 0;
    80004000:	8a4e                	mv	s4,s3
    80004002:	b7e9                	j	80003fcc <namex+0x6c>
  len = path - s;
    80004004:	40998633          	sub	a2,s3,s1
    80004008:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    8000400c:	09acd863          	bge	s9,s10,8000409c <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004010:	4639                	li	a2,14
    80004012:	85a6                	mv	a1,s1
    80004014:	8556                	mv	a0,s5
    80004016:	ffffd097          	auipc	ra,0xffffd
    8000401a:	d18080e7          	jalr	-744(ra) # 80000d2e <memmove>
    8000401e:	84ce                	mv	s1,s3
  while (*path == '/')
    80004020:	0004c783          	lbu	a5,0(s1)
    80004024:	01279763          	bne	a5,s2,80004032 <namex+0xd2>
    path++;
    80004028:	0485                	addi	s1,s1,1
  while (*path == '/')
    8000402a:	0004c783          	lbu	a5,0(s1)
    8000402e:	ff278de3          	beq	a5,s2,80004028 <namex+0xc8>
    ilock(ip);
    80004032:	8552                	mv	a0,s4
    80004034:	00000097          	auipc	ra,0x0
    80004038:	998080e7          	jalr	-1640(ra) # 800039cc <ilock>
    if (ip->type != T_DIR)
    8000403c:	044a1783          	lh	a5,68(s4)
    80004040:	f98790e3          	bne	a5,s8,80003fc0 <namex+0x60>
    if (nameiparent && *path == '\0')
    80004044:	000b0563          	beqz	s6,8000404e <namex+0xee>
    80004048:	0004c783          	lbu	a5,0(s1)
    8000404c:	dfd9                	beqz	a5,80003fea <namex+0x8a>
    if ((next = dirlookup(ip, name, 0)) == 0)
    8000404e:	865e                	mv	a2,s7
    80004050:	85d6                	mv	a1,s5
    80004052:	8552                	mv	a0,s4
    80004054:	00000097          	auipc	ra,0x0
    80004058:	e5c080e7          	jalr	-420(ra) # 80003eb0 <dirlookup>
    8000405c:	89aa                	mv	s3,a0
    8000405e:	dd41                	beqz	a0,80003ff6 <namex+0x96>
    iunlockput(ip);
    80004060:	8552                	mv	a0,s4
    80004062:	00000097          	auipc	ra,0x0
    80004066:	bcc080e7          	jalr	-1076(ra) # 80003c2e <iunlockput>
    ip = next;
    8000406a:	8a4e                	mv	s4,s3
  while (*path == '/')
    8000406c:	0004c783          	lbu	a5,0(s1)
    80004070:	01279763          	bne	a5,s2,8000407e <namex+0x11e>
    path++;
    80004074:	0485                	addi	s1,s1,1
  while (*path == '/')
    80004076:	0004c783          	lbu	a5,0(s1)
    8000407a:	ff278de3          	beq	a5,s2,80004074 <namex+0x114>
  if (*path == 0)
    8000407e:	cb9d                	beqz	a5,800040b4 <namex+0x154>
  while (*path != '/' && *path != 0)
    80004080:	0004c783          	lbu	a5,0(s1)
    80004084:	89a6                	mv	s3,s1
  len = path - s;
    80004086:	8d5e                	mv	s10,s7
    80004088:	865e                	mv	a2,s7
  while (*path != '/' && *path != 0)
    8000408a:	01278963          	beq	a5,s2,8000409c <namex+0x13c>
    8000408e:	dbbd                	beqz	a5,80004004 <namex+0xa4>
    path++;
    80004090:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80004092:	0009c783          	lbu	a5,0(s3)
    80004096:	ff279ce3          	bne	a5,s2,8000408e <namex+0x12e>
    8000409a:	b7ad                	j	80004004 <namex+0xa4>
    memmove(name, s, len);
    8000409c:	2601                	sext.w	a2,a2
    8000409e:	85a6                	mv	a1,s1
    800040a0:	8556                	mv	a0,s5
    800040a2:	ffffd097          	auipc	ra,0xffffd
    800040a6:	c8c080e7          	jalr	-884(ra) # 80000d2e <memmove>
    name[len] = 0;
    800040aa:	9d56                	add	s10,s10,s5
    800040ac:	000d0023          	sb	zero,0(s10)
    800040b0:	84ce                	mv	s1,s3
    800040b2:	b7bd                	j	80004020 <namex+0xc0>
  if (nameiparent)
    800040b4:	f00b0ce3          	beqz	s6,80003fcc <namex+0x6c>
    iput(ip);
    800040b8:	8552                	mv	a0,s4
    800040ba:	00000097          	auipc	ra,0x0
    800040be:	acc080e7          	jalr	-1332(ra) # 80003b86 <iput>
    return 0;
    800040c2:	4a01                	li	s4,0
    800040c4:	b721                	j	80003fcc <namex+0x6c>

00000000800040c6 <dirlink>:
{
    800040c6:	7139                	addi	sp,sp,-64
    800040c8:	fc06                	sd	ra,56(sp)
    800040ca:	f822                	sd	s0,48(sp)
    800040cc:	f426                	sd	s1,40(sp)
    800040ce:	f04a                	sd	s2,32(sp)
    800040d0:	ec4e                	sd	s3,24(sp)
    800040d2:	e852                	sd	s4,16(sp)
    800040d4:	0080                	addi	s0,sp,64
    800040d6:	892a                	mv	s2,a0
    800040d8:	8a2e                	mv	s4,a1
    800040da:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0)
    800040dc:	4601                	li	a2,0
    800040de:	00000097          	auipc	ra,0x0
    800040e2:	dd2080e7          	jalr	-558(ra) # 80003eb0 <dirlookup>
    800040e6:	e93d                	bnez	a0,8000415c <dirlink+0x96>
  for (off = 0; off < dp->size; off += sizeof(de))
    800040e8:	04c92483          	lw	s1,76(s2)
    800040ec:	c49d                	beqz	s1,8000411a <dirlink+0x54>
    800040ee:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040f0:	4741                	li	a4,16
    800040f2:	86a6                	mv	a3,s1
    800040f4:	fc040613          	addi	a2,s0,-64
    800040f8:	4581                	li	a1,0
    800040fa:	854a                	mv	a0,s2
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	b84080e7          	jalr	-1148(ra) # 80003c80 <readi>
    80004104:	47c1                	li	a5,16
    80004106:	06f51163          	bne	a0,a5,80004168 <dirlink+0xa2>
    if (de.inum == 0)
    8000410a:	fc045783          	lhu	a5,-64(s0)
    8000410e:	c791                	beqz	a5,8000411a <dirlink+0x54>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004110:	24c1                	addiw	s1,s1,16
    80004112:	04c92783          	lw	a5,76(s2)
    80004116:	fcf4ede3          	bltu	s1,a5,800040f0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000411a:	4639                	li	a2,14
    8000411c:	85d2                	mv	a1,s4
    8000411e:	fc240513          	addi	a0,s0,-62
    80004122:	ffffd097          	auipc	ra,0xffffd
    80004126:	cbc080e7          	jalr	-836(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000412a:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000412e:	4741                	li	a4,16
    80004130:	86a6                	mv	a3,s1
    80004132:	fc040613          	addi	a2,s0,-64
    80004136:	4581                	li	a1,0
    80004138:	854a                	mv	a0,s2
    8000413a:	00000097          	auipc	ra,0x0
    8000413e:	c3e080e7          	jalr	-962(ra) # 80003d78 <writei>
    80004142:	1541                	addi	a0,a0,-16
    80004144:	00a03533          	snez	a0,a0
    80004148:	40a00533          	neg	a0,a0
}
    8000414c:	70e2                	ld	ra,56(sp)
    8000414e:	7442                	ld	s0,48(sp)
    80004150:	74a2                	ld	s1,40(sp)
    80004152:	7902                	ld	s2,32(sp)
    80004154:	69e2                	ld	s3,24(sp)
    80004156:	6a42                	ld	s4,16(sp)
    80004158:	6121                	addi	sp,sp,64
    8000415a:	8082                	ret
    iput(ip);
    8000415c:	00000097          	auipc	ra,0x0
    80004160:	a2a080e7          	jalr	-1494(ra) # 80003b86 <iput>
    return -1;
    80004164:	557d                	li	a0,-1
    80004166:	b7dd                	j	8000414c <dirlink+0x86>
      panic("dirlink read");
    80004168:	00004517          	auipc	a0,0x4
    8000416c:	4c850513          	addi	a0,a0,1224 # 80008630 <syscalls+0x1e0>
    80004170:	ffffc097          	auipc	ra,0xffffc
    80004174:	3d0080e7          	jalr	976(ra) # 80000540 <panic>

0000000080004178 <namei>:

struct inode *
namei(char *path)
{
    80004178:	1101                	addi	sp,sp,-32
    8000417a:	ec06                	sd	ra,24(sp)
    8000417c:	e822                	sd	s0,16(sp)
    8000417e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004180:	fe040613          	addi	a2,s0,-32
    80004184:	4581                	li	a1,0
    80004186:	00000097          	auipc	ra,0x0
    8000418a:	dda080e7          	jalr	-550(ra) # 80003f60 <namex>
}
    8000418e:	60e2                	ld	ra,24(sp)
    80004190:	6442                	ld	s0,16(sp)
    80004192:	6105                	addi	sp,sp,32
    80004194:	8082                	ret

0000000080004196 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80004196:	1141                	addi	sp,sp,-16
    80004198:	e406                	sd	ra,8(sp)
    8000419a:	e022                	sd	s0,0(sp)
    8000419c:	0800                	addi	s0,sp,16
    8000419e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041a0:	4585                	li	a1,1
    800041a2:	00000097          	auipc	ra,0x0
    800041a6:	dbe080e7          	jalr	-578(ra) # 80003f60 <namex>
}
    800041aa:	60a2                	ld	ra,8(sp)
    800041ac:	6402                	ld	s0,0(sp)
    800041ae:	0141                	addi	sp,sp,16
    800041b0:	8082                	ret

00000000800041b2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041b2:	1101                	addi	sp,sp,-32
    800041b4:	ec06                	sd	ra,24(sp)
    800041b6:	e822                	sd	s0,16(sp)
    800041b8:	e426                	sd	s1,8(sp)
    800041ba:	e04a                	sd	s2,0(sp)
    800041bc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041be:	0001e917          	auipc	s2,0x1e
    800041c2:	3aa90913          	addi	s2,s2,938 # 80022568 <log>
    800041c6:	01892583          	lw	a1,24(s2)
    800041ca:	02892503          	lw	a0,40(s2)
    800041ce:	fffff097          	auipc	ra,0xfffff
    800041d2:	fe6080e7          	jalr	-26(ra) # 800031b4 <bread>
    800041d6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    800041d8:	02c92683          	lw	a3,44(s2)
    800041dc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++)
    800041de:	02d05863          	blez	a3,8000420e <write_head+0x5c>
    800041e2:	0001e797          	auipc	a5,0x1e
    800041e6:	3b678793          	addi	a5,a5,950 # 80022598 <log+0x30>
    800041ea:	05c50713          	addi	a4,a0,92
    800041ee:	36fd                	addiw	a3,a3,-1
    800041f0:	02069613          	slli	a2,a3,0x20
    800041f4:	01e65693          	srli	a3,a2,0x1e
    800041f8:	0001e617          	auipc	a2,0x1e
    800041fc:	3a460613          	addi	a2,a2,932 # 8002259c <log+0x34>
    80004200:	96b2                	add	a3,a3,a2
  {
    hb->block[i] = log.lh.block[i];
    80004202:	4390                	lw	a2,0(a5)
    80004204:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    80004206:	0791                	addi	a5,a5,4
    80004208:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000420a:	fed79ce3          	bne	a5,a3,80004202 <write_head+0x50>
  }
  bwrite(buf);
    8000420e:	8526                	mv	a0,s1
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	096080e7          	jalr	150(ra) # 800032a6 <bwrite>
  brelse(buf);
    80004218:	8526                	mv	a0,s1
    8000421a:	fffff097          	auipc	ra,0xfffff
    8000421e:	0ca080e7          	jalr	202(ra) # 800032e4 <brelse>
}
    80004222:	60e2                	ld	ra,24(sp)
    80004224:	6442                	ld	s0,16(sp)
    80004226:	64a2                	ld	s1,8(sp)
    80004228:	6902                	ld	s2,0(sp)
    8000422a:	6105                	addi	sp,sp,32
    8000422c:	8082                	ret

000000008000422e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++)
    8000422e:	0001e797          	auipc	a5,0x1e
    80004232:	3667a783          	lw	a5,870(a5) # 80022594 <log+0x2c>
    80004236:	0af05d63          	blez	a5,800042f0 <install_trans+0xc2>
{
    8000423a:	7139                	addi	sp,sp,-64
    8000423c:	fc06                	sd	ra,56(sp)
    8000423e:	f822                	sd	s0,48(sp)
    80004240:	f426                	sd	s1,40(sp)
    80004242:	f04a                	sd	s2,32(sp)
    80004244:	ec4e                	sd	s3,24(sp)
    80004246:	e852                	sd	s4,16(sp)
    80004248:	e456                	sd	s5,8(sp)
    8000424a:	e05a                	sd	s6,0(sp)
    8000424c:	0080                	addi	s0,sp,64
    8000424e:	8b2a                	mv	s6,a0
    80004250:	0001ea97          	auipc	s5,0x1e
    80004254:	348a8a93          	addi	s5,s5,840 # 80022598 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++)
    80004258:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    8000425a:	0001e997          	auipc	s3,0x1e
    8000425e:	30e98993          	addi	s3,s3,782 # 80022568 <log>
    80004262:	a00d                	j	80004284 <install_trans+0x56>
    brelse(lbuf);
    80004264:	854a                	mv	a0,s2
    80004266:	fffff097          	auipc	ra,0xfffff
    8000426a:	07e080e7          	jalr	126(ra) # 800032e4 <brelse>
    brelse(dbuf);
    8000426e:	8526                	mv	a0,s1
    80004270:	fffff097          	auipc	ra,0xfffff
    80004274:	074080e7          	jalr	116(ra) # 800032e4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    80004278:	2a05                	addiw	s4,s4,1
    8000427a:	0a91                	addi	s5,s5,4
    8000427c:	02c9a783          	lw	a5,44(s3)
    80004280:	04fa5e63          	bge	s4,a5,800042dc <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80004284:	0189a583          	lw	a1,24(s3)
    80004288:	014585bb          	addw	a1,a1,s4
    8000428c:	2585                	addiw	a1,a1,1
    8000428e:	0289a503          	lw	a0,40(s3)
    80004292:	fffff097          	auipc	ra,0xfffff
    80004296:	f22080e7          	jalr	-222(ra) # 800031b4 <bread>
    8000429a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    8000429c:	000aa583          	lw	a1,0(s5)
    800042a0:	0289a503          	lw	a0,40(s3)
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	f10080e7          	jalr	-240(ra) # 800031b4 <bread>
    800042ac:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);                  // copy block to dst
    800042ae:	40000613          	li	a2,1024
    800042b2:	05890593          	addi	a1,s2,88
    800042b6:	05850513          	addi	a0,a0,88
    800042ba:	ffffd097          	auipc	ra,0xffffd
    800042be:	a74080e7          	jalr	-1420(ra) # 80000d2e <memmove>
    bwrite(dbuf);                                            // write dst to disk
    800042c2:	8526                	mv	a0,s1
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	fe2080e7          	jalr	-30(ra) # 800032a6 <bwrite>
    if (recovering == 0)
    800042cc:	f80b1ce3          	bnez	s6,80004264 <install_trans+0x36>
      bunpin(dbuf);
    800042d0:	8526                	mv	a0,s1
    800042d2:	fffff097          	auipc	ra,0xfffff
    800042d6:	0ec080e7          	jalr	236(ra) # 800033be <bunpin>
    800042da:	b769                	j	80004264 <install_trans+0x36>
}
    800042dc:	70e2                	ld	ra,56(sp)
    800042de:	7442                	ld	s0,48(sp)
    800042e0:	74a2                	ld	s1,40(sp)
    800042e2:	7902                	ld	s2,32(sp)
    800042e4:	69e2                	ld	s3,24(sp)
    800042e6:	6a42                	ld	s4,16(sp)
    800042e8:	6aa2                	ld	s5,8(sp)
    800042ea:	6b02                	ld	s6,0(sp)
    800042ec:	6121                	addi	sp,sp,64
    800042ee:	8082                	ret
    800042f0:	8082                	ret

00000000800042f2 <initlog>:
{
    800042f2:	7179                	addi	sp,sp,-48
    800042f4:	f406                	sd	ra,40(sp)
    800042f6:	f022                	sd	s0,32(sp)
    800042f8:	ec26                	sd	s1,24(sp)
    800042fa:	e84a                	sd	s2,16(sp)
    800042fc:	e44e                	sd	s3,8(sp)
    800042fe:	1800                	addi	s0,sp,48
    80004300:	892a                	mv	s2,a0
    80004302:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004304:	0001e497          	auipc	s1,0x1e
    80004308:	26448493          	addi	s1,s1,612 # 80022568 <log>
    8000430c:	00004597          	auipc	a1,0x4
    80004310:	33458593          	addi	a1,a1,820 # 80008640 <syscalls+0x1f0>
    80004314:	8526                	mv	a0,s1
    80004316:	ffffd097          	auipc	ra,0xffffd
    8000431a:	830080e7          	jalr	-2000(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000431e:	0149a583          	lw	a1,20(s3)
    80004322:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004324:	0109a783          	lw	a5,16(s3)
    80004328:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000432a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000432e:	854a                	mv	a0,s2
    80004330:	fffff097          	auipc	ra,0xfffff
    80004334:	e84080e7          	jalr	-380(ra) # 800031b4 <bread>
  log.lh.n = lh->n;
    80004338:	4d34                	lw	a3,88(a0)
    8000433a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++)
    8000433c:	02d05663          	blez	a3,80004368 <initlog+0x76>
    80004340:	05c50793          	addi	a5,a0,92
    80004344:	0001e717          	auipc	a4,0x1e
    80004348:	25470713          	addi	a4,a4,596 # 80022598 <log+0x30>
    8000434c:	36fd                	addiw	a3,a3,-1
    8000434e:	02069613          	slli	a2,a3,0x20
    80004352:	01e65693          	srli	a3,a2,0x1e
    80004356:	06050613          	addi	a2,a0,96
    8000435a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000435c:	4390                	lw	a2,0(a5)
    8000435e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    80004360:	0791                	addi	a5,a5,4
    80004362:	0711                	addi	a4,a4,4
    80004364:	fed79ce3          	bne	a5,a3,8000435c <initlog+0x6a>
  brelse(buf);
    80004368:	fffff097          	auipc	ra,0xfffff
    8000436c:	f7c080e7          	jalr	-132(ra) # 800032e4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004370:	4505                	li	a0,1
    80004372:	00000097          	auipc	ra,0x0
    80004376:	ebc080e7          	jalr	-324(ra) # 8000422e <install_trans>
  log.lh.n = 0;
    8000437a:	0001e797          	auipc	a5,0x1e
    8000437e:	2007ad23          	sw	zero,538(a5) # 80022594 <log+0x2c>
  write_head(); // clear the log
    80004382:	00000097          	auipc	ra,0x0
    80004386:	e30080e7          	jalr	-464(ra) # 800041b2 <write_head>
}
    8000438a:	70a2                	ld	ra,40(sp)
    8000438c:	7402                	ld	s0,32(sp)
    8000438e:	64e2                	ld	s1,24(sp)
    80004390:	6942                	ld	s2,16(sp)
    80004392:	69a2                	ld	s3,8(sp)
    80004394:	6145                	addi	sp,sp,48
    80004396:	8082                	ret

0000000080004398 <begin_op>:
}

// called at the start of each FS system call.
void begin_op(void)
{
    80004398:	1101                	addi	sp,sp,-32
    8000439a:	ec06                	sd	ra,24(sp)
    8000439c:	e822                	sd	s0,16(sp)
    8000439e:	e426                	sd	s1,8(sp)
    800043a0:	e04a                	sd	s2,0(sp)
    800043a2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043a4:	0001e517          	auipc	a0,0x1e
    800043a8:	1c450513          	addi	a0,a0,452 # 80022568 <log>
    800043ac:	ffffd097          	auipc	ra,0xffffd
    800043b0:	82a080e7          	jalr	-2006(ra) # 80000bd6 <acquire>
  while (1)
  {
    if (log.committing)
    800043b4:	0001e497          	auipc	s1,0x1e
    800043b8:	1b448493          	addi	s1,s1,436 # 80022568 <log>
    {
      sleep(&log, &log.lock);
    }
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    800043bc:	4979                	li	s2,30
    800043be:	a039                	j	800043cc <begin_op+0x34>
      sleep(&log, &log.lock);
    800043c0:	85a6                	mv	a1,s1
    800043c2:	8526                	mv	a0,s1
    800043c4:	ffffe097          	auipc	ra,0xffffe
    800043c8:	ce4080e7          	jalr	-796(ra) # 800020a8 <sleep>
    if (log.committing)
    800043cc:	50dc                	lw	a5,36(s1)
    800043ce:	fbed                	bnez	a5,800043c0 <begin_op+0x28>
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    800043d0:	5098                	lw	a4,32(s1)
    800043d2:	2705                	addiw	a4,a4,1
    800043d4:	0007069b          	sext.w	a3,a4
    800043d8:	0027179b          	slliw	a5,a4,0x2
    800043dc:	9fb9                	addw	a5,a5,a4
    800043de:	0017979b          	slliw	a5,a5,0x1
    800043e2:	54d8                	lw	a4,44(s1)
    800043e4:	9fb9                	addw	a5,a5,a4
    800043e6:	00f95963          	bge	s2,a5,800043f8 <begin_op+0x60>
    {
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043ea:	85a6                	mv	a1,s1
    800043ec:	8526                	mv	a0,s1
    800043ee:	ffffe097          	auipc	ra,0xffffe
    800043f2:	cba080e7          	jalr	-838(ra) # 800020a8 <sleep>
    800043f6:	bfd9                	j	800043cc <begin_op+0x34>
    }
    else
    {
      log.outstanding += 1;
    800043f8:	0001e517          	auipc	a0,0x1e
    800043fc:	17050513          	addi	a0,a0,368 # 80022568 <log>
    80004400:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004402:	ffffd097          	auipc	ra,0xffffd
    80004406:	888080e7          	jalr	-1912(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000440a:	60e2                	ld	ra,24(sp)
    8000440c:	6442                	ld	s0,16(sp)
    8000440e:	64a2                	ld	s1,8(sp)
    80004410:	6902                	ld	s2,0(sp)
    80004412:	6105                	addi	sp,sp,32
    80004414:	8082                	ret

0000000080004416 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
    80004416:	7139                	addi	sp,sp,-64
    80004418:	fc06                	sd	ra,56(sp)
    8000441a:	f822                	sd	s0,48(sp)
    8000441c:	f426                	sd	s1,40(sp)
    8000441e:	f04a                	sd	s2,32(sp)
    80004420:	ec4e                	sd	s3,24(sp)
    80004422:	e852                	sd	s4,16(sp)
    80004424:	e456                	sd	s5,8(sp)
    80004426:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004428:	0001e497          	auipc	s1,0x1e
    8000442c:	14048493          	addi	s1,s1,320 # 80022568 <log>
    80004430:	8526                	mv	a0,s1
    80004432:	ffffc097          	auipc	ra,0xffffc
    80004436:	7a4080e7          	jalr	1956(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000443a:	509c                	lw	a5,32(s1)
    8000443c:	37fd                	addiw	a5,a5,-1
    8000443e:	0007891b          	sext.w	s2,a5
    80004442:	d09c                	sw	a5,32(s1)
  if (log.committing)
    80004444:	50dc                	lw	a5,36(s1)
    80004446:	e7b9                	bnez	a5,80004494 <end_op+0x7e>
    panic("log.committing");
  if (log.outstanding == 0)
    80004448:	04091e63          	bnez	s2,800044a4 <end_op+0x8e>
  {
    do_commit = 1;
    log.committing = 1;
    8000444c:	0001e497          	auipc	s1,0x1e
    80004450:	11c48493          	addi	s1,s1,284 # 80022568 <log>
    80004454:	4785                	li	a5,1
    80004456:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004458:	8526                	mv	a0,s1
    8000445a:	ffffd097          	auipc	ra,0xffffd
    8000445e:	830080e7          	jalr	-2000(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0)
    80004462:	54dc                	lw	a5,44(s1)
    80004464:	06f04763          	bgtz	a5,800044d2 <end_op+0xbc>
    acquire(&log.lock);
    80004468:	0001e497          	auipc	s1,0x1e
    8000446c:	10048493          	addi	s1,s1,256 # 80022568 <log>
    80004470:	8526                	mv	a0,s1
    80004472:	ffffc097          	auipc	ra,0xffffc
    80004476:	764080e7          	jalr	1892(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000447a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000447e:	8526                	mv	a0,s1
    80004480:	ffffe097          	auipc	ra,0xffffe
    80004484:	c8c080e7          	jalr	-884(ra) # 8000210c <wakeup>
    release(&log.lock);
    80004488:	8526                	mv	a0,s1
    8000448a:	ffffd097          	auipc	ra,0xffffd
    8000448e:	800080e7          	jalr	-2048(ra) # 80000c8a <release>
}
    80004492:	a03d                	j	800044c0 <end_op+0xaa>
    panic("log.committing");
    80004494:	00004517          	auipc	a0,0x4
    80004498:	1b450513          	addi	a0,a0,436 # 80008648 <syscalls+0x1f8>
    8000449c:	ffffc097          	auipc	ra,0xffffc
    800044a0:	0a4080e7          	jalr	164(ra) # 80000540 <panic>
    wakeup(&log);
    800044a4:	0001e497          	auipc	s1,0x1e
    800044a8:	0c448493          	addi	s1,s1,196 # 80022568 <log>
    800044ac:	8526                	mv	a0,s1
    800044ae:	ffffe097          	auipc	ra,0xffffe
    800044b2:	c5e080e7          	jalr	-930(ra) # 8000210c <wakeup>
  release(&log.lock);
    800044b6:	8526                	mv	a0,s1
    800044b8:	ffffc097          	auipc	ra,0xffffc
    800044bc:	7d2080e7          	jalr	2002(ra) # 80000c8a <release>
}
    800044c0:	70e2                	ld	ra,56(sp)
    800044c2:	7442                	ld	s0,48(sp)
    800044c4:	74a2                	ld	s1,40(sp)
    800044c6:	7902                	ld	s2,32(sp)
    800044c8:	69e2                	ld	s3,24(sp)
    800044ca:	6a42                	ld	s4,16(sp)
    800044cc:	6aa2                	ld	s5,8(sp)
    800044ce:	6121                	addi	sp,sp,64
    800044d0:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++)
    800044d2:	0001ea97          	auipc	s5,0x1e
    800044d6:	0c6a8a93          	addi	s5,s5,198 # 80022598 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    800044da:	0001ea17          	auipc	s4,0x1e
    800044de:	08ea0a13          	addi	s4,s4,142 # 80022568 <log>
    800044e2:	018a2583          	lw	a1,24(s4)
    800044e6:	012585bb          	addw	a1,a1,s2
    800044ea:	2585                	addiw	a1,a1,1
    800044ec:	028a2503          	lw	a0,40(s4)
    800044f0:	fffff097          	auipc	ra,0xfffff
    800044f4:	cc4080e7          	jalr	-828(ra) # 800031b4 <bread>
    800044f8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044fa:	000aa583          	lw	a1,0(s5)
    800044fe:	028a2503          	lw	a0,40(s4)
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	cb2080e7          	jalr	-846(ra) # 800031b4 <bread>
    8000450a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000450c:	40000613          	li	a2,1024
    80004510:	05850593          	addi	a1,a0,88
    80004514:	05848513          	addi	a0,s1,88
    80004518:	ffffd097          	auipc	ra,0xffffd
    8000451c:	816080e7          	jalr	-2026(ra) # 80000d2e <memmove>
    bwrite(to); // write the log
    80004520:	8526                	mv	a0,s1
    80004522:	fffff097          	auipc	ra,0xfffff
    80004526:	d84080e7          	jalr	-636(ra) # 800032a6 <bwrite>
    brelse(from);
    8000452a:	854e                	mv	a0,s3
    8000452c:	fffff097          	auipc	ra,0xfffff
    80004530:	db8080e7          	jalr	-584(ra) # 800032e4 <brelse>
    brelse(to);
    80004534:	8526                	mv	a0,s1
    80004536:	fffff097          	auipc	ra,0xfffff
    8000453a:	dae080e7          	jalr	-594(ra) # 800032e4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    8000453e:	2905                	addiw	s2,s2,1
    80004540:	0a91                	addi	s5,s5,4
    80004542:	02ca2783          	lw	a5,44(s4)
    80004546:	f8f94ee3          	blt	s2,a5,800044e2 <end_op+0xcc>
  {
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    8000454a:	00000097          	auipc	ra,0x0
    8000454e:	c68080e7          	jalr	-920(ra) # 800041b2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004552:	4501                	li	a0,0
    80004554:	00000097          	auipc	ra,0x0
    80004558:	cda080e7          	jalr	-806(ra) # 8000422e <install_trans>
    log.lh.n = 0;
    8000455c:	0001e797          	auipc	a5,0x1e
    80004560:	0207ac23          	sw	zero,56(a5) # 80022594 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004564:	00000097          	auipc	ra,0x0
    80004568:	c4e080e7          	jalr	-946(ra) # 800041b2 <write_head>
    8000456c:	bdf5                	j	80004468 <end_op+0x52>

000000008000456e <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
    8000456e:	1101                	addi	sp,sp,-32
    80004570:	ec06                	sd	ra,24(sp)
    80004572:	e822                	sd	s0,16(sp)
    80004574:	e426                	sd	s1,8(sp)
    80004576:	e04a                	sd	s2,0(sp)
    80004578:	1000                	addi	s0,sp,32
    8000457a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000457c:	0001e917          	auipc	s2,0x1e
    80004580:	fec90913          	addi	s2,s2,-20 # 80022568 <log>
    80004584:	854a                	mv	a0,s2
    80004586:	ffffc097          	auipc	ra,0xffffc
    8000458a:	650080e7          	jalr	1616(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000458e:	02c92603          	lw	a2,44(s2)
    80004592:	47f5                	li	a5,29
    80004594:	06c7c563          	blt	a5,a2,800045fe <log_write+0x90>
    80004598:	0001e797          	auipc	a5,0x1e
    8000459c:	fec7a783          	lw	a5,-20(a5) # 80022584 <log+0x1c>
    800045a0:	37fd                	addiw	a5,a5,-1
    800045a2:	04f65e63          	bge	a2,a5,800045fe <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045a6:	0001e797          	auipc	a5,0x1e
    800045aa:	fe27a783          	lw	a5,-30(a5) # 80022588 <log+0x20>
    800045ae:	06f05063          	blez	a5,8000460e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++)
    800045b2:	4781                	li	a5,0
    800045b4:	06c05563          	blez	a2,8000461e <log_write+0xb0>
  {
    if (log.lh.block[i] == b->blockno) // log absorption
    800045b8:	44cc                	lw	a1,12(s1)
    800045ba:	0001e717          	auipc	a4,0x1e
    800045be:	fde70713          	addi	a4,a4,-34 # 80022598 <log+0x30>
  for (i = 0; i < log.lh.n; i++)
    800045c2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    800045c4:	4314                	lw	a3,0(a4)
    800045c6:	04b68c63          	beq	a3,a1,8000461e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++)
    800045ca:	2785                	addiw	a5,a5,1
    800045cc:	0711                	addi	a4,a4,4
    800045ce:	fef61be3          	bne	a2,a5,800045c4 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045d2:	0621                	addi	a2,a2,8
    800045d4:	060a                	slli	a2,a2,0x2
    800045d6:	0001e797          	auipc	a5,0x1e
    800045da:	f9278793          	addi	a5,a5,-110 # 80022568 <log>
    800045de:	97b2                	add	a5,a5,a2
    800045e0:	44d8                	lw	a4,12(s1)
    800045e2:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n)
  { // Add new block to log?
    bpin(b);
    800045e4:	8526                	mv	a0,s1
    800045e6:	fffff097          	auipc	ra,0xfffff
    800045ea:	d9c080e7          	jalr	-612(ra) # 80003382 <bpin>
    log.lh.n++;
    800045ee:	0001e717          	auipc	a4,0x1e
    800045f2:	f7a70713          	addi	a4,a4,-134 # 80022568 <log>
    800045f6:	575c                	lw	a5,44(a4)
    800045f8:	2785                	addiw	a5,a5,1
    800045fa:	d75c                	sw	a5,44(a4)
    800045fc:	a82d                	j	80004636 <log_write+0xc8>
    panic("too big a transaction");
    800045fe:	00004517          	auipc	a0,0x4
    80004602:	05a50513          	addi	a0,a0,90 # 80008658 <syscalls+0x208>
    80004606:	ffffc097          	auipc	ra,0xffffc
    8000460a:	f3a080e7          	jalr	-198(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    8000460e:	00004517          	auipc	a0,0x4
    80004612:	06250513          	addi	a0,a0,98 # 80008670 <syscalls+0x220>
    80004616:	ffffc097          	auipc	ra,0xffffc
    8000461a:	f2a080e7          	jalr	-214(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    8000461e:	00878693          	addi	a3,a5,8
    80004622:	068a                	slli	a3,a3,0x2
    80004624:	0001e717          	auipc	a4,0x1e
    80004628:	f4470713          	addi	a4,a4,-188 # 80022568 <log>
    8000462c:	9736                	add	a4,a4,a3
    8000462e:	44d4                	lw	a3,12(s1)
    80004630:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n)
    80004632:	faf609e3          	beq	a2,a5,800045e4 <log_write+0x76>
  }
  release(&log.lock);
    80004636:	0001e517          	auipc	a0,0x1e
    8000463a:	f3250513          	addi	a0,a0,-206 # 80022568 <log>
    8000463e:	ffffc097          	auipc	ra,0xffffc
    80004642:	64c080e7          	jalr	1612(ra) # 80000c8a <release>
}
    80004646:	60e2                	ld	ra,24(sp)
    80004648:	6442                	ld	s0,16(sp)
    8000464a:	64a2                	ld	s1,8(sp)
    8000464c:	6902                	ld	s2,0(sp)
    8000464e:	6105                	addi	sp,sp,32
    80004650:	8082                	ret

0000000080004652 <initsleeplock>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock *lk, char *name)
{
    80004652:	1101                	addi	sp,sp,-32
    80004654:	ec06                	sd	ra,24(sp)
    80004656:	e822                	sd	s0,16(sp)
    80004658:	e426                	sd	s1,8(sp)
    8000465a:	e04a                	sd	s2,0(sp)
    8000465c:	1000                	addi	s0,sp,32
    8000465e:	84aa                	mv	s1,a0
    80004660:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004662:	00004597          	auipc	a1,0x4
    80004666:	02e58593          	addi	a1,a1,46 # 80008690 <syscalls+0x240>
    8000466a:	0521                	addi	a0,a0,8
    8000466c:	ffffc097          	auipc	ra,0xffffc
    80004670:	4da080e7          	jalr	1242(ra) # 80000b46 <initlock>
  lk->name = name;
    80004674:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004678:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000467c:	0204a423          	sw	zero,40(s1)
}
    80004680:	60e2                	ld	ra,24(sp)
    80004682:	6442                	ld	s0,16(sp)
    80004684:	64a2                	ld	s1,8(sp)
    80004686:	6902                	ld	s2,0(sp)
    80004688:	6105                	addi	sp,sp,32
    8000468a:	8082                	ret

000000008000468c <acquiresleep>:

void acquiresleep(struct sleeplock *lk)
{
    8000468c:	1101                	addi	sp,sp,-32
    8000468e:	ec06                	sd	ra,24(sp)
    80004690:	e822                	sd	s0,16(sp)
    80004692:	e426                	sd	s1,8(sp)
    80004694:	e04a                	sd	s2,0(sp)
    80004696:	1000                	addi	s0,sp,32
    80004698:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000469a:	00850913          	addi	s2,a0,8
    8000469e:	854a                	mv	a0,s2
    800046a0:	ffffc097          	auipc	ra,0xffffc
    800046a4:	536080e7          	jalr	1334(ra) # 80000bd6 <acquire>
  while (lk->locked)
    800046a8:	409c                	lw	a5,0(s1)
    800046aa:	cb89                	beqz	a5,800046bc <acquiresleep+0x30>
  {
    sleep(lk, &lk->lk);
    800046ac:	85ca                	mv	a1,s2
    800046ae:	8526                	mv	a0,s1
    800046b0:	ffffe097          	auipc	ra,0xffffe
    800046b4:	9f8080e7          	jalr	-1544(ra) # 800020a8 <sleep>
  while (lk->locked)
    800046b8:	409c                	lw	a5,0(s1)
    800046ba:	fbed                	bnez	a5,800046ac <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046bc:	4785                	li	a5,1
    800046be:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046c0:	ffffd097          	auipc	ra,0xffffd
    800046c4:	2ec080e7          	jalr	748(ra) # 800019ac <myproc>
    800046c8:	591c                	lw	a5,48(a0)
    800046ca:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046cc:	854a                	mv	a0,s2
    800046ce:	ffffc097          	auipc	ra,0xffffc
    800046d2:	5bc080e7          	jalr	1468(ra) # 80000c8a <release>
}
    800046d6:	60e2                	ld	ra,24(sp)
    800046d8:	6442                	ld	s0,16(sp)
    800046da:	64a2                	ld	s1,8(sp)
    800046dc:	6902                	ld	s2,0(sp)
    800046de:	6105                	addi	sp,sp,32
    800046e0:	8082                	ret

00000000800046e2 <releasesleep>:

void releasesleep(struct sleeplock *lk)
{
    800046e2:	1101                	addi	sp,sp,-32
    800046e4:	ec06                	sd	ra,24(sp)
    800046e6:	e822                	sd	s0,16(sp)
    800046e8:	e426                	sd	s1,8(sp)
    800046ea:	e04a                	sd	s2,0(sp)
    800046ec:	1000                	addi	s0,sp,32
    800046ee:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046f0:	00850913          	addi	s2,a0,8
    800046f4:	854a                	mv	a0,s2
    800046f6:	ffffc097          	auipc	ra,0xffffc
    800046fa:	4e0080e7          	jalr	1248(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800046fe:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004702:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004706:	8526                	mv	a0,s1
    80004708:	ffffe097          	auipc	ra,0xffffe
    8000470c:	a04080e7          	jalr	-1532(ra) # 8000210c <wakeup>
  release(&lk->lk);
    80004710:	854a                	mv	a0,s2
    80004712:	ffffc097          	auipc	ra,0xffffc
    80004716:	578080e7          	jalr	1400(ra) # 80000c8a <release>
}
    8000471a:	60e2                	ld	ra,24(sp)
    8000471c:	6442                	ld	s0,16(sp)
    8000471e:	64a2                	ld	s1,8(sp)
    80004720:	6902                	ld	s2,0(sp)
    80004722:	6105                	addi	sp,sp,32
    80004724:	8082                	ret

0000000080004726 <holdingsleep>:

int holdingsleep(struct sleeplock *lk)
{
    80004726:	7179                	addi	sp,sp,-48
    80004728:	f406                	sd	ra,40(sp)
    8000472a:	f022                	sd	s0,32(sp)
    8000472c:	ec26                	sd	s1,24(sp)
    8000472e:	e84a                	sd	s2,16(sp)
    80004730:	e44e                	sd	s3,8(sp)
    80004732:	1800                	addi	s0,sp,48
    80004734:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004736:	00850913          	addi	s2,a0,8
    8000473a:	854a                	mv	a0,s2
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	49a080e7          	jalr	1178(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004744:	409c                	lw	a5,0(s1)
    80004746:	ef99                	bnez	a5,80004764 <holdingsleep+0x3e>
    80004748:	4481                	li	s1,0
  release(&lk->lk);
    8000474a:	854a                	mv	a0,s2
    8000474c:	ffffc097          	auipc	ra,0xffffc
    80004750:	53e080e7          	jalr	1342(ra) # 80000c8a <release>
  return r;
}
    80004754:	8526                	mv	a0,s1
    80004756:	70a2                	ld	ra,40(sp)
    80004758:	7402                	ld	s0,32(sp)
    8000475a:	64e2                	ld	s1,24(sp)
    8000475c:	6942                	ld	s2,16(sp)
    8000475e:	69a2                	ld	s3,8(sp)
    80004760:	6145                	addi	sp,sp,48
    80004762:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004764:	0284a983          	lw	s3,40(s1)
    80004768:	ffffd097          	auipc	ra,0xffffd
    8000476c:	244080e7          	jalr	580(ra) # 800019ac <myproc>
    80004770:	5904                	lw	s1,48(a0)
    80004772:	413484b3          	sub	s1,s1,s3
    80004776:	0014b493          	seqz	s1,s1
    8000477a:	bfc1                	j	8000474a <holdingsleep+0x24>

000000008000477c <fileinit>:
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void fileinit(void)
{
    8000477c:	1141                	addi	sp,sp,-16
    8000477e:	e406                	sd	ra,8(sp)
    80004780:	e022                	sd	s0,0(sp)
    80004782:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004784:	00004597          	auipc	a1,0x4
    80004788:	f1c58593          	addi	a1,a1,-228 # 800086a0 <syscalls+0x250>
    8000478c:	0001e517          	auipc	a0,0x1e
    80004790:	f2450513          	addi	a0,a0,-220 # 800226b0 <ftable>
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	3b2080e7          	jalr	946(ra) # 80000b46 <initlock>
}
    8000479c:	60a2                	ld	ra,8(sp)
    8000479e:	6402                	ld	s0,0(sp)
    800047a0:	0141                	addi	sp,sp,16
    800047a2:	8082                	ret

00000000800047a4 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800047a4:	1101                	addi	sp,sp,-32
    800047a6:	ec06                	sd	ra,24(sp)
    800047a8:	e822                	sd	s0,16(sp)
    800047aa:	e426                	sd	s1,8(sp)
    800047ac:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047ae:	0001e517          	auipc	a0,0x1e
    800047b2:	f0250513          	addi	a0,a0,-254 # 800226b0 <ftable>
    800047b6:	ffffc097          	auipc	ra,0xffffc
    800047ba:	420080e7          	jalr	1056(ra) # 80000bd6 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    800047be:	0001e497          	auipc	s1,0x1e
    800047c2:	f0a48493          	addi	s1,s1,-246 # 800226c8 <ftable+0x18>
    800047c6:	0001f717          	auipc	a4,0x1f
    800047ca:	ea270713          	addi	a4,a4,-350 # 80023668 <disk>
  {
    if (f->ref == 0)
    800047ce:	40dc                	lw	a5,4(s1)
    800047d0:	cf99                	beqz	a5,800047ee <filealloc+0x4a>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    800047d2:	02848493          	addi	s1,s1,40
    800047d6:	fee49ce3          	bne	s1,a4,800047ce <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047da:	0001e517          	auipc	a0,0x1e
    800047de:	ed650513          	addi	a0,a0,-298 # 800226b0 <ftable>
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	4a8080e7          	jalr	1192(ra) # 80000c8a <release>
  return 0;
    800047ea:	4481                	li	s1,0
    800047ec:	a819                	j	80004802 <filealloc+0x5e>
      f->ref = 1;
    800047ee:	4785                	li	a5,1
    800047f0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047f2:	0001e517          	auipc	a0,0x1e
    800047f6:	ebe50513          	addi	a0,a0,-322 # 800226b0 <ftable>
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	490080e7          	jalr	1168(ra) # 80000c8a <release>
}
    80004802:	8526                	mv	a0,s1
    80004804:	60e2                	ld	ra,24(sp)
    80004806:	6442                	ld	s0,16(sp)
    80004808:	64a2                	ld	s1,8(sp)
    8000480a:	6105                	addi	sp,sp,32
    8000480c:	8082                	ret

000000008000480e <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000480e:	1101                	addi	sp,sp,-32
    80004810:	ec06                	sd	ra,24(sp)
    80004812:	e822                	sd	s0,16(sp)
    80004814:	e426                	sd	s1,8(sp)
    80004816:	1000                	addi	s0,sp,32
    80004818:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000481a:	0001e517          	auipc	a0,0x1e
    8000481e:	e9650513          	addi	a0,a0,-362 # 800226b0 <ftable>
    80004822:	ffffc097          	auipc	ra,0xffffc
    80004826:	3b4080e7          	jalr	948(ra) # 80000bd6 <acquire>
  if (f->ref < 1)
    8000482a:	40dc                	lw	a5,4(s1)
    8000482c:	02f05263          	blez	a5,80004850 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004830:	2785                	addiw	a5,a5,1
    80004832:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004834:	0001e517          	auipc	a0,0x1e
    80004838:	e7c50513          	addi	a0,a0,-388 # 800226b0 <ftable>
    8000483c:	ffffc097          	auipc	ra,0xffffc
    80004840:	44e080e7          	jalr	1102(ra) # 80000c8a <release>
  return f;
}
    80004844:	8526                	mv	a0,s1
    80004846:	60e2                	ld	ra,24(sp)
    80004848:	6442                	ld	s0,16(sp)
    8000484a:	64a2                	ld	s1,8(sp)
    8000484c:	6105                	addi	sp,sp,32
    8000484e:	8082                	ret
    panic("filedup");
    80004850:	00004517          	auipc	a0,0x4
    80004854:	e5850513          	addi	a0,a0,-424 # 800086a8 <syscalls+0x258>
    80004858:	ffffc097          	auipc	ra,0xffffc
    8000485c:	ce8080e7          	jalr	-792(ra) # 80000540 <panic>

0000000080004860 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    80004860:	7139                	addi	sp,sp,-64
    80004862:	fc06                	sd	ra,56(sp)
    80004864:	f822                	sd	s0,48(sp)
    80004866:	f426                	sd	s1,40(sp)
    80004868:	f04a                	sd	s2,32(sp)
    8000486a:	ec4e                	sd	s3,24(sp)
    8000486c:	e852                	sd	s4,16(sp)
    8000486e:	e456                	sd	s5,8(sp)
    80004870:	0080                	addi	s0,sp,64
    80004872:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004874:	0001e517          	auipc	a0,0x1e
    80004878:	e3c50513          	addi	a0,a0,-452 # 800226b0 <ftable>
    8000487c:	ffffc097          	auipc	ra,0xffffc
    80004880:	35a080e7          	jalr	858(ra) # 80000bd6 <acquire>
  if (f->ref < 1)
    80004884:	40dc                	lw	a5,4(s1)
    80004886:	06f05163          	blez	a5,800048e8 <fileclose+0x88>
    panic("fileclose");
  if (--f->ref > 0)
    8000488a:	37fd                	addiw	a5,a5,-1
    8000488c:	0007871b          	sext.w	a4,a5
    80004890:	c0dc                	sw	a5,4(s1)
    80004892:	06e04363          	bgtz	a4,800048f8 <fileclose+0x98>
  {
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004896:	0004a903          	lw	s2,0(s1)
    8000489a:	0094ca83          	lbu	s5,9(s1)
    8000489e:	0104ba03          	ld	s4,16(s1)
    800048a2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048a6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048aa:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048ae:	0001e517          	auipc	a0,0x1e
    800048b2:	e0250513          	addi	a0,a0,-510 # 800226b0 <ftable>
    800048b6:	ffffc097          	auipc	ra,0xffffc
    800048ba:	3d4080e7          	jalr	980(ra) # 80000c8a <release>

  if (ff.type == FD_PIPE)
    800048be:	4785                	li	a5,1
    800048c0:	04f90d63          	beq	s2,a5,8000491a <fileclose+0xba>
  {
    pipeclose(ff.pipe, ff.writable);
  }
  else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    800048c4:	3979                	addiw	s2,s2,-2
    800048c6:	4785                	li	a5,1
    800048c8:	0527e063          	bltu	a5,s2,80004908 <fileclose+0xa8>
  {
    begin_op();
    800048cc:	00000097          	auipc	ra,0x0
    800048d0:	acc080e7          	jalr	-1332(ra) # 80004398 <begin_op>
    iput(ff.ip);
    800048d4:	854e                	mv	a0,s3
    800048d6:	fffff097          	auipc	ra,0xfffff
    800048da:	2b0080e7          	jalr	688(ra) # 80003b86 <iput>
    end_op();
    800048de:	00000097          	auipc	ra,0x0
    800048e2:	b38080e7          	jalr	-1224(ra) # 80004416 <end_op>
    800048e6:	a00d                	j	80004908 <fileclose+0xa8>
    panic("fileclose");
    800048e8:	00004517          	auipc	a0,0x4
    800048ec:	dc850513          	addi	a0,a0,-568 # 800086b0 <syscalls+0x260>
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	c50080e7          	jalr	-944(ra) # 80000540 <panic>
    release(&ftable.lock);
    800048f8:	0001e517          	auipc	a0,0x1e
    800048fc:	db850513          	addi	a0,a0,-584 # 800226b0 <ftable>
    80004900:	ffffc097          	auipc	ra,0xffffc
    80004904:	38a080e7          	jalr	906(ra) # 80000c8a <release>
  }
}
    80004908:	70e2                	ld	ra,56(sp)
    8000490a:	7442                	ld	s0,48(sp)
    8000490c:	74a2                	ld	s1,40(sp)
    8000490e:	7902                	ld	s2,32(sp)
    80004910:	69e2                	ld	s3,24(sp)
    80004912:	6a42                	ld	s4,16(sp)
    80004914:	6aa2                	ld	s5,8(sp)
    80004916:	6121                	addi	sp,sp,64
    80004918:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000491a:	85d6                	mv	a1,s5
    8000491c:	8552                	mv	a0,s4
    8000491e:	00000097          	auipc	ra,0x0
    80004922:	34c080e7          	jalr	844(ra) # 80004c6a <pipeclose>
    80004926:	b7cd                	j	80004908 <fileclose+0xa8>

0000000080004928 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80004928:	715d                	addi	sp,sp,-80
    8000492a:	e486                	sd	ra,72(sp)
    8000492c:	e0a2                	sd	s0,64(sp)
    8000492e:	fc26                	sd	s1,56(sp)
    80004930:	f84a                	sd	s2,48(sp)
    80004932:	f44e                	sd	s3,40(sp)
    80004934:	0880                	addi	s0,sp,80
    80004936:	84aa                	mv	s1,a0
    80004938:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000493a:	ffffd097          	auipc	ra,0xffffd
    8000493e:	072080e7          	jalr	114(ra) # 800019ac <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004942:	409c                	lw	a5,0(s1)
    80004944:	37f9                	addiw	a5,a5,-2
    80004946:	4705                	li	a4,1
    80004948:	04f76763          	bltu	a4,a5,80004996 <filestat+0x6e>
    8000494c:	892a                	mv	s2,a0
  {
    ilock(f->ip);
    8000494e:	6c88                	ld	a0,24(s1)
    80004950:	fffff097          	auipc	ra,0xfffff
    80004954:	07c080e7          	jalr	124(ra) # 800039cc <ilock>
    stati(f->ip, &st);
    80004958:	fb840593          	addi	a1,s0,-72
    8000495c:	6c88                	ld	a0,24(s1)
    8000495e:	fffff097          	auipc	ra,0xfffff
    80004962:	2f8080e7          	jalr	760(ra) # 80003c56 <stati>
    iunlock(f->ip);
    80004966:	6c88                	ld	a0,24(s1)
    80004968:	fffff097          	auipc	ra,0xfffff
    8000496c:	126080e7          	jalr	294(ra) # 80003a8e <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004970:	46e1                	li	a3,24
    80004972:	fb840613          	addi	a2,s0,-72
    80004976:	85ce                	mv	a1,s3
    80004978:	05093503          	ld	a0,80(s2)
    8000497c:	ffffd097          	auipc	ra,0xffffd
    80004980:	cf0080e7          	jalr	-784(ra) # 8000166c <copyout>
    80004984:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004988:	60a6                	ld	ra,72(sp)
    8000498a:	6406                	ld	s0,64(sp)
    8000498c:	74e2                	ld	s1,56(sp)
    8000498e:	7942                	ld	s2,48(sp)
    80004990:	79a2                	ld	s3,40(sp)
    80004992:	6161                	addi	sp,sp,80
    80004994:	8082                	ret
  return -1;
    80004996:	557d                	li	a0,-1
    80004998:	bfc5                	j	80004988 <filestat+0x60>

000000008000499a <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    8000499a:	7179                	addi	sp,sp,-48
    8000499c:	f406                	sd	ra,40(sp)
    8000499e:	f022                	sd	s0,32(sp)
    800049a0:	ec26                	sd	s1,24(sp)
    800049a2:	e84a                	sd	s2,16(sp)
    800049a4:	e44e                	sd	s3,8(sp)
    800049a6:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    800049a8:	00854783          	lbu	a5,8(a0)
    800049ac:	c3d5                	beqz	a5,80004a50 <fileread+0xb6>
    800049ae:	84aa                	mv	s1,a0
    800049b0:	89ae                	mv	s3,a1
    800049b2:	8932                	mv	s2,a2
    return -1;

  if (f->type == FD_PIPE)
    800049b4:	411c                	lw	a5,0(a0)
    800049b6:	4705                	li	a4,1
    800049b8:	04e78963          	beq	a5,a4,80004a0a <fileread+0x70>
  {
    r = piperead(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    800049bc:	470d                	li	a4,3
    800049be:	04e78d63          	beq	a5,a4,80004a18 <fileread+0x7e>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  }
  else if (f->type == FD_INODE)
    800049c2:	4709                	li	a4,2
    800049c4:	06e79e63          	bne	a5,a4,80004a40 <fileread+0xa6>
  {
    ilock(f->ip);
    800049c8:	6d08                	ld	a0,24(a0)
    800049ca:	fffff097          	auipc	ra,0xfffff
    800049ce:	002080e7          	jalr	2(ra) # 800039cc <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049d2:	874a                	mv	a4,s2
    800049d4:	5094                	lw	a3,32(s1)
    800049d6:	864e                	mv	a2,s3
    800049d8:	4585                	li	a1,1
    800049da:	6c88                	ld	a0,24(s1)
    800049dc:	fffff097          	auipc	ra,0xfffff
    800049e0:	2a4080e7          	jalr	676(ra) # 80003c80 <readi>
    800049e4:	892a                	mv	s2,a0
    800049e6:	00a05563          	blez	a0,800049f0 <fileread+0x56>
      f->off += r;
    800049ea:	509c                	lw	a5,32(s1)
    800049ec:	9fa9                	addw	a5,a5,a0
    800049ee:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049f0:	6c88                	ld	a0,24(s1)
    800049f2:	fffff097          	auipc	ra,0xfffff
    800049f6:	09c080e7          	jalr	156(ra) # 80003a8e <iunlock>
  {
    panic("fileread");
  }

  return r;
}
    800049fa:	854a                	mv	a0,s2
    800049fc:	70a2                	ld	ra,40(sp)
    800049fe:	7402                	ld	s0,32(sp)
    80004a00:	64e2                	ld	s1,24(sp)
    80004a02:	6942                	ld	s2,16(sp)
    80004a04:	69a2                	ld	s3,8(sp)
    80004a06:	6145                	addi	sp,sp,48
    80004a08:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a0a:	6908                	ld	a0,16(a0)
    80004a0c:	00000097          	auipc	ra,0x0
    80004a10:	3c6080e7          	jalr	966(ra) # 80004dd2 <piperead>
    80004a14:	892a                	mv	s2,a0
    80004a16:	b7d5                	j	800049fa <fileread+0x60>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a18:	02451783          	lh	a5,36(a0)
    80004a1c:	03079693          	slli	a3,a5,0x30
    80004a20:	92c1                	srli	a3,a3,0x30
    80004a22:	4725                	li	a4,9
    80004a24:	02d76863          	bltu	a4,a3,80004a54 <fileread+0xba>
    80004a28:	0792                	slli	a5,a5,0x4
    80004a2a:	0001e717          	auipc	a4,0x1e
    80004a2e:	be670713          	addi	a4,a4,-1050 # 80022610 <devsw>
    80004a32:	97ba                	add	a5,a5,a4
    80004a34:	639c                	ld	a5,0(a5)
    80004a36:	c38d                	beqz	a5,80004a58 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a38:	4505                	li	a0,1
    80004a3a:	9782                	jalr	a5
    80004a3c:	892a                	mv	s2,a0
    80004a3e:	bf75                	j	800049fa <fileread+0x60>
    panic("fileread");
    80004a40:	00004517          	auipc	a0,0x4
    80004a44:	c8050513          	addi	a0,a0,-896 # 800086c0 <syscalls+0x270>
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	af8080e7          	jalr	-1288(ra) # 80000540 <panic>
    return -1;
    80004a50:	597d                	li	s2,-1
    80004a52:	b765                	j	800049fa <fileread+0x60>
      return -1;
    80004a54:	597d                	li	s2,-1
    80004a56:	b755                	j	800049fa <fileread+0x60>
    80004a58:	597d                	li	s2,-1
    80004a5a:	b745                	j	800049fa <fileread+0x60>

0000000080004a5c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    80004a5c:	715d                	addi	sp,sp,-80
    80004a5e:	e486                	sd	ra,72(sp)
    80004a60:	e0a2                	sd	s0,64(sp)
    80004a62:	fc26                	sd	s1,56(sp)
    80004a64:	f84a                	sd	s2,48(sp)
    80004a66:	f44e                	sd	s3,40(sp)
    80004a68:	f052                	sd	s4,32(sp)
    80004a6a:	ec56                	sd	s5,24(sp)
    80004a6c:	e85a                	sd	s6,16(sp)
    80004a6e:	e45e                	sd	s7,8(sp)
    80004a70:	e062                	sd	s8,0(sp)
    80004a72:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if (f->writable == 0)
    80004a74:	00954783          	lbu	a5,9(a0)
    80004a78:	10078663          	beqz	a5,80004b84 <filewrite+0x128>
    80004a7c:	892a                	mv	s2,a0
    80004a7e:	8b2e                	mv	s6,a1
    80004a80:	8a32                	mv	s4,a2
    return -1;

  if (f->type == FD_PIPE)
    80004a82:	411c                	lw	a5,0(a0)
    80004a84:	4705                	li	a4,1
    80004a86:	02e78263          	beq	a5,a4,80004aaa <filewrite+0x4e>
  {
    ret = pipewrite(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004a8a:	470d                	li	a4,3
    80004a8c:	02e78663          	beq	a5,a4,80004ab8 <filewrite+0x5c>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004a90:	4709                	li	a4,2
    80004a92:	0ee79163          	bne	a5,a4,80004b74 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n)
    80004a96:	0ac05d63          	blez	a2,80004b50 <filewrite+0xf4>
    int i = 0;
    80004a9a:	4981                	li	s3,0
    80004a9c:	6b85                	lui	s7,0x1
    80004a9e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004aa2:	6c05                	lui	s8,0x1
    80004aa4:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004aa8:	a861                	j	80004b40 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004aaa:	6908                	ld	a0,16(a0)
    80004aac:	00000097          	auipc	ra,0x0
    80004ab0:	22e080e7          	jalr	558(ra) # 80004cda <pipewrite>
    80004ab4:	8a2a                	mv	s4,a0
    80004ab6:	a045                	j	80004b56 <filewrite+0xfa>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ab8:	02451783          	lh	a5,36(a0)
    80004abc:	03079693          	slli	a3,a5,0x30
    80004ac0:	92c1                	srli	a3,a3,0x30
    80004ac2:	4725                	li	a4,9
    80004ac4:	0cd76263          	bltu	a4,a3,80004b88 <filewrite+0x12c>
    80004ac8:	0792                	slli	a5,a5,0x4
    80004aca:	0001e717          	auipc	a4,0x1e
    80004ace:	b4670713          	addi	a4,a4,-1210 # 80022610 <devsw>
    80004ad2:	97ba                	add	a5,a5,a4
    80004ad4:	679c                	ld	a5,8(a5)
    80004ad6:	cbdd                	beqz	a5,80004b8c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ad8:	4505                	li	a0,1
    80004ada:	9782                	jalr	a5
    80004adc:	8a2a                	mv	s4,a0
    80004ade:	a8a5                	j	80004b56 <filewrite+0xfa>
    80004ae0:	00048a9b          	sext.w	s5,s1
    {
      int n1 = n - i;
      if (n1 > max)
        n1 = max;

      begin_op();
    80004ae4:	00000097          	auipc	ra,0x0
    80004ae8:	8b4080e7          	jalr	-1868(ra) # 80004398 <begin_op>
      ilock(f->ip);
    80004aec:	01893503          	ld	a0,24(s2)
    80004af0:	fffff097          	auipc	ra,0xfffff
    80004af4:	edc080e7          	jalr	-292(ra) # 800039cc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004af8:	8756                	mv	a4,s5
    80004afa:	02092683          	lw	a3,32(s2)
    80004afe:	01698633          	add	a2,s3,s6
    80004b02:	4585                	li	a1,1
    80004b04:	01893503          	ld	a0,24(s2)
    80004b08:	fffff097          	auipc	ra,0xfffff
    80004b0c:	270080e7          	jalr	624(ra) # 80003d78 <writei>
    80004b10:	84aa                	mv	s1,a0
    80004b12:	00a05763          	blez	a0,80004b20 <filewrite+0xc4>
        f->off += r;
    80004b16:	02092783          	lw	a5,32(s2)
    80004b1a:	9fa9                	addw	a5,a5,a0
    80004b1c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b20:	01893503          	ld	a0,24(s2)
    80004b24:	fffff097          	auipc	ra,0xfffff
    80004b28:	f6a080e7          	jalr	-150(ra) # 80003a8e <iunlock>
      end_op();
    80004b2c:	00000097          	auipc	ra,0x0
    80004b30:	8ea080e7          	jalr	-1814(ra) # 80004416 <end_op>

      if (r != n1)
    80004b34:	009a9f63          	bne	s5,s1,80004b52 <filewrite+0xf6>
      {
        // error from writei
        break;
      }
      i += r;
    80004b38:	013489bb          	addw	s3,s1,s3
    while (i < n)
    80004b3c:	0149db63          	bge	s3,s4,80004b52 <filewrite+0xf6>
      int n1 = n - i;
    80004b40:	413a04bb          	subw	s1,s4,s3
    80004b44:	0004879b          	sext.w	a5,s1
    80004b48:	f8fbdce3          	bge	s7,a5,80004ae0 <filewrite+0x84>
    80004b4c:	84e2                	mv	s1,s8
    80004b4e:	bf49                	j	80004ae0 <filewrite+0x84>
    int i = 0;
    80004b50:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b52:	013a1f63          	bne	s4,s3,80004b70 <filewrite+0x114>
  {
    panic("filewrite");
  }

  return ret;
}
    80004b56:	8552                	mv	a0,s4
    80004b58:	60a6                	ld	ra,72(sp)
    80004b5a:	6406                	ld	s0,64(sp)
    80004b5c:	74e2                	ld	s1,56(sp)
    80004b5e:	7942                	ld	s2,48(sp)
    80004b60:	79a2                	ld	s3,40(sp)
    80004b62:	7a02                	ld	s4,32(sp)
    80004b64:	6ae2                	ld	s5,24(sp)
    80004b66:	6b42                	ld	s6,16(sp)
    80004b68:	6ba2                	ld	s7,8(sp)
    80004b6a:	6c02                	ld	s8,0(sp)
    80004b6c:	6161                	addi	sp,sp,80
    80004b6e:	8082                	ret
    ret = (i == n ? n : -1);
    80004b70:	5a7d                	li	s4,-1
    80004b72:	b7d5                	j	80004b56 <filewrite+0xfa>
    panic("filewrite");
    80004b74:	00004517          	auipc	a0,0x4
    80004b78:	b5c50513          	addi	a0,a0,-1188 # 800086d0 <syscalls+0x280>
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	9c4080e7          	jalr	-1596(ra) # 80000540 <panic>
    return -1;
    80004b84:	5a7d                	li	s4,-1
    80004b86:	bfc1                	j	80004b56 <filewrite+0xfa>
      return -1;
    80004b88:	5a7d                	li	s4,-1
    80004b8a:	b7f1                	j	80004b56 <filewrite+0xfa>
    80004b8c:	5a7d                	li	s4,-1
    80004b8e:	b7e1                	j	80004b56 <filewrite+0xfa>

0000000080004b90 <pipealloc>:
  int readopen;  // read fd is still open
  int writeopen; // write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
    80004b90:	7179                	addi	sp,sp,-48
    80004b92:	f406                	sd	ra,40(sp)
    80004b94:	f022                	sd	s0,32(sp)
    80004b96:	ec26                	sd	s1,24(sp)
    80004b98:	e84a                	sd	s2,16(sp)
    80004b9a:	e44e                	sd	s3,8(sp)
    80004b9c:	e052                	sd	s4,0(sp)
    80004b9e:	1800                	addi	s0,sp,48
    80004ba0:	84aa                	mv	s1,a0
    80004ba2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ba4:	0005b023          	sd	zero,0(a1)
    80004ba8:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004bac:	00000097          	auipc	ra,0x0
    80004bb0:	bf8080e7          	jalr	-1032(ra) # 800047a4 <filealloc>
    80004bb4:	e088                	sd	a0,0(s1)
    80004bb6:	c551                	beqz	a0,80004c42 <pipealloc+0xb2>
    80004bb8:	00000097          	auipc	ra,0x0
    80004bbc:	bec080e7          	jalr	-1044(ra) # 800047a4 <filealloc>
    80004bc0:	00aa3023          	sd	a0,0(s4)
    80004bc4:	c92d                	beqz	a0,80004c36 <pipealloc+0xa6>
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004bc6:	ffffc097          	auipc	ra,0xffffc
    80004bca:	f20080e7          	jalr	-224(ra) # 80000ae6 <kalloc>
    80004bce:	892a                	mv	s2,a0
    80004bd0:	c125                	beqz	a0,80004c30 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004bd2:	4985                	li	s3,1
    80004bd4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004bd8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004bdc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004be0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004be4:	00004597          	auipc	a1,0x4
    80004be8:	afc58593          	addi	a1,a1,-1284 # 800086e0 <syscalls+0x290>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	f5a080e7          	jalr	-166(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004bf4:	609c                	ld	a5,0(s1)
    80004bf6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bfa:	609c                	ld	a5,0(s1)
    80004bfc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c00:	609c                	ld	a5,0(s1)
    80004c02:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c06:	609c                	ld	a5,0(s1)
    80004c08:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c0c:	000a3783          	ld	a5,0(s4)
    80004c10:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c14:	000a3783          	ld	a5,0(s4)
    80004c18:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c1c:	000a3783          	ld	a5,0(s4)
    80004c20:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c24:	000a3783          	ld	a5,0(s4)
    80004c28:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c2c:	4501                	li	a0,0
    80004c2e:	a025                	j	80004c56 <pipealloc+0xc6>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004c30:	6088                	ld	a0,0(s1)
    80004c32:	e501                	bnez	a0,80004c3a <pipealloc+0xaa>
    80004c34:	a039                	j	80004c42 <pipealloc+0xb2>
    80004c36:	6088                	ld	a0,0(s1)
    80004c38:	c51d                	beqz	a0,80004c66 <pipealloc+0xd6>
    fileclose(*f0);
    80004c3a:	00000097          	auipc	ra,0x0
    80004c3e:	c26080e7          	jalr	-986(ra) # 80004860 <fileclose>
  if (*f1)
    80004c42:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c46:	557d                	li	a0,-1
  if (*f1)
    80004c48:	c799                	beqz	a5,80004c56 <pipealloc+0xc6>
    fileclose(*f1);
    80004c4a:	853e                	mv	a0,a5
    80004c4c:	00000097          	auipc	ra,0x0
    80004c50:	c14080e7          	jalr	-1004(ra) # 80004860 <fileclose>
  return -1;
    80004c54:	557d                	li	a0,-1
}
    80004c56:	70a2                	ld	ra,40(sp)
    80004c58:	7402                	ld	s0,32(sp)
    80004c5a:	64e2                	ld	s1,24(sp)
    80004c5c:	6942                	ld	s2,16(sp)
    80004c5e:	69a2                	ld	s3,8(sp)
    80004c60:	6a02                	ld	s4,0(sp)
    80004c62:	6145                	addi	sp,sp,48
    80004c64:	8082                	ret
  return -1;
    80004c66:	557d                	li	a0,-1
    80004c68:	b7fd                	j	80004c56 <pipealloc+0xc6>

0000000080004c6a <pipeclose>:

void pipeclose(struct pipe *pi, int writable)
{
    80004c6a:	1101                	addi	sp,sp,-32
    80004c6c:	ec06                	sd	ra,24(sp)
    80004c6e:	e822                	sd	s0,16(sp)
    80004c70:	e426                	sd	s1,8(sp)
    80004c72:	e04a                	sd	s2,0(sp)
    80004c74:	1000                	addi	s0,sp,32
    80004c76:	84aa                	mv	s1,a0
    80004c78:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	f5c080e7          	jalr	-164(ra) # 80000bd6 <acquire>
  if (writable)
    80004c82:	02090d63          	beqz	s2,80004cbc <pipeclose+0x52>
  {
    pi->writeopen = 0;
    80004c86:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c8a:	21848513          	addi	a0,s1,536
    80004c8e:	ffffd097          	auipc	ra,0xffffd
    80004c92:	47e080e7          	jalr	1150(ra) # 8000210c <wakeup>
  else
  {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0)
    80004c96:	2204b783          	ld	a5,544(s1)
    80004c9a:	eb95                	bnez	a5,80004cce <pipeclose+0x64>
  {
    release(&pi->lock);
    80004c9c:	8526                	mv	a0,s1
    80004c9e:	ffffc097          	auipc	ra,0xffffc
    80004ca2:	fec080e7          	jalr	-20(ra) # 80000c8a <release>
    kfree((char *)pi);
    80004ca6:	8526                	mv	a0,s1
    80004ca8:	ffffc097          	auipc	ra,0xffffc
    80004cac:	d40080e7          	jalr	-704(ra) # 800009e8 <kfree>
  }
  else
    release(&pi->lock);
}
    80004cb0:	60e2                	ld	ra,24(sp)
    80004cb2:	6442                	ld	s0,16(sp)
    80004cb4:	64a2                	ld	s1,8(sp)
    80004cb6:	6902                	ld	s2,0(sp)
    80004cb8:	6105                	addi	sp,sp,32
    80004cba:	8082                	ret
    pi->readopen = 0;
    80004cbc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004cc0:	21c48513          	addi	a0,s1,540
    80004cc4:	ffffd097          	auipc	ra,0xffffd
    80004cc8:	448080e7          	jalr	1096(ra) # 8000210c <wakeup>
    80004ccc:	b7e9                	j	80004c96 <pipeclose+0x2c>
    release(&pi->lock);
    80004cce:	8526                	mv	a0,s1
    80004cd0:	ffffc097          	auipc	ra,0xffffc
    80004cd4:	fba080e7          	jalr	-70(ra) # 80000c8a <release>
}
    80004cd8:	bfe1                	j	80004cb0 <pipeclose+0x46>

0000000080004cda <pipewrite>:

int pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cda:	711d                	addi	sp,sp,-96
    80004cdc:	ec86                	sd	ra,88(sp)
    80004cde:	e8a2                	sd	s0,80(sp)
    80004ce0:	e4a6                	sd	s1,72(sp)
    80004ce2:	e0ca                	sd	s2,64(sp)
    80004ce4:	fc4e                	sd	s3,56(sp)
    80004ce6:	f852                	sd	s4,48(sp)
    80004ce8:	f456                	sd	s5,40(sp)
    80004cea:	f05a                	sd	s6,32(sp)
    80004cec:	ec5e                	sd	s7,24(sp)
    80004cee:	e862                	sd	s8,16(sp)
    80004cf0:	1080                	addi	s0,sp,96
    80004cf2:	84aa                	mv	s1,a0
    80004cf4:	8aae                	mv	s5,a1
    80004cf6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004cf8:	ffffd097          	auipc	ra,0xffffd
    80004cfc:	cb4080e7          	jalr	-844(ra) # 800019ac <myproc>
    80004d00:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d02:	8526                	mv	a0,s1
    80004d04:	ffffc097          	auipc	ra,0xffffc
    80004d08:	ed2080e7          	jalr	-302(ra) # 80000bd6 <acquire>
  while (i < n)
    80004d0c:	0b405663          	blez	s4,80004db8 <pipewrite+0xde>
  int i = 0;
    80004d10:	4901                	li	s2,0
      sleep(&pi->nwrite, &pi->lock);
    }
    else
    {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d12:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d14:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d18:	21c48b93          	addi	s7,s1,540
    80004d1c:	a089                	j	80004d5e <pipewrite+0x84>
      release(&pi->lock);
    80004d1e:	8526                	mv	a0,s1
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	f6a080e7          	jalr	-150(ra) # 80000c8a <release>
      return -1;
    80004d28:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d2a:	854a                	mv	a0,s2
    80004d2c:	60e6                	ld	ra,88(sp)
    80004d2e:	6446                	ld	s0,80(sp)
    80004d30:	64a6                	ld	s1,72(sp)
    80004d32:	6906                	ld	s2,64(sp)
    80004d34:	79e2                	ld	s3,56(sp)
    80004d36:	7a42                	ld	s4,48(sp)
    80004d38:	7aa2                	ld	s5,40(sp)
    80004d3a:	7b02                	ld	s6,32(sp)
    80004d3c:	6be2                	ld	s7,24(sp)
    80004d3e:	6c42                	ld	s8,16(sp)
    80004d40:	6125                	addi	sp,sp,96
    80004d42:	8082                	ret
      wakeup(&pi->nread);
    80004d44:	8562                	mv	a0,s8
    80004d46:	ffffd097          	auipc	ra,0xffffd
    80004d4a:	3c6080e7          	jalr	966(ra) # 8000210c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d4e:	85a6                	mv	a1,s1
    80004d50:	855e                	mv	a0,s7
    80004d52:	ffffd097          	auipc	ra,0xffffd
    80004d56:	356080e7          	jalr	854(ra) # 800020a8 <sleep>
  while (i < n)
    80004d5a:	07495063          	bge	s2,s4,80004dba <pipewrite+0xe0>
    if (pi->readopen == 0 || killed(pr))
    80004d5e:	2204a783          	lw	a5,544(s1)
    80004d62:	dfd5                	beqz	a5,80004d1e <pipewrite+0x44>
    80004d64:	854e                	mv	a0,s3
    80004d66:	ffffd097          	auipc	ra,0xffffd
    80004d6a:	5f6080e7          	jalr	1526(ra) # 8000235c <killed>
    80004d6e:	f945                	bnez	a0,80004d1e <pipewrite+0x44>
    if (pi->nwrite == pi->nread + PIPESIZE)
    80004d70:	2184a783          	lw	a5,536(s1)
    80004d74:	21c4a703          	lw	a4,540(s1)
    80004d78:	2007879b          	addiw	a5,a5,512
    80004d7c:	fcf704e3          	beq	a4,a5,80004d44 <pipewrite+0x6a>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d80:	4685                	li	a3,1
    80004d82:	01590633          	add	a2,s2,s5
    80004d86:	faf40593          	addi	a1,s0,-81
    80004d8a:	0509b503          	ld	a0,80(s3)
    80004d8e:	ffffd097          	auipc	ra,0xffffd
    80004d92:	96a080e7          	jalr	-1686(ra) # 800016f8 <copyin>
    80004d96:	03650263          	beq	a0,s6,80004dba <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d9a:	21c4a783          	lw	a5,540(s1)
    80004d9e:	0017871b          	addiw	a4,a5,1
    80004da2:	20e4ae23          	sw	a4,540(s1)
    80004da6:	1ff7f793          	andi	a5,a5,511
    80004daa:	97a6                	add	a5,a5,s1
    80004dac:	faf44703          	lbu	a4,-81(s0)
    80004db0:	00e78c23          	sb	a4,24(a5)
      i++;
    80004db4:	2905                	addiw	s2,s2,1
    80004db6:	b755                	j	80004d5a <pipewrite+0x80>
  int i = 0;
    80004db8:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004dba:	21848513          	addi	a0,s1,536
    80004dbe:	ffffd097          	auipc	ra,0xffffd
    80004dc2:	34e080e7          	jalr	846(ra) # 8000210c <wakeup>
  release(&pi->lock);
    80004dc6:	8526                	mv	a0,s1
    80004dc8:	ffffc097          	auipc	ra,0xffffc
    80004dcc:	ec2080e7          	jalr	-318(ra) # 80000c8a <release>
  return i;
    80004dd0:	bfa9                	j	80004d2a <pipewrite+0x50>

0000000080004dd2 <piperead>:

int piperead(struct pipe *pi, uint64 addr, int n)
{
    80004dd2:	715d                	addi	sp,sp,-80
    80004dd4:	e486                	sd	ra,72(sp)
    80004dd6:	e0a2                	sd	s0,64(sp)
    80004dd8:	fc26                	sd	s1,56(sp)
    80004dda:	f84a                	sd	s2,48(sp)
    80004ddc:	f44e                	sd	s3,40(sp)
    80004dde:	f052                	sd	s4,32(sp)
    80004de0:	ec56                	sd	s5,24(sp)
    80004de2:	e85a                	sd	s6,16(sp)
    80004de4:	0880                	addi	s0,sp,80
    80004de6:	84aa                	mv	s1,a0
    80004de8:	892e                	mv	s2,a1
    80004dea:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dec:	ffffd097          	auipc	ra,0xffffd
    80004df0:	bc0080e7          	jalr	-1088(ra) # 800019ac <myproc>
    80004df4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004df6:	8526                	mv	a0,s1
    80004df8:	ffffc097          	auipc	ra,0xffffc
    80004dfc:	dde080e7          	jalr	-546(ra) # 80000bd6 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004e00:	2184a703          	lw	a4,536(s1)
    80004e04:	21c4a783          	lw	a5,540(s1)
    if (killed(pr))
    {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004e08:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004e0c:	02f71763          	bne	a4,a5,80004e3a <piperead+0x68>
    80004e10:	2244a783          	lw	a5,548(s1)
    80004e14:	c39d                	beqz	a5,80004e3a <piperead+0x68>
    if (killed(pr))
    80004e16:	8552                	mv	a0,s4
    80004e18:	ffffd097          	auipc	ra,0xffffd
    80004e1c:	544080e7          	jalr	1348(ra) # 8000235c <killed>
    80004e20:	e949                	bnez	a0,80004eb2 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004e22:	85a6                	mv	a1,s1
    80004e24:	854e                	mv	a0,s3
    80004e26:	ffffd097          	auipc	ra,0xffffd
    80004e2a:	282080e7          	jalr	642(ra) # 800020a8 <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004e2e:	2184a703          	lw	a4,536(s1)
    80004e32:	21c4a783          	lw	a5,540(s1)
    80004e36:	fcf70de3          	beq	a4,a5,80004e10 <piperead+0x3e>
  }
  for (i = 0; i < n; i++)
    80004e3a:	4981                	li	s3,0
  { // DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e3c:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++)
    80004e3e:	05505463          	blez	s5,80004e86 <piperead+0xb4>
    if (pi->nread == pi->nwrite)
    80004e42:	2184a783          	lw	a5,536(s1)
    80004e46:	21c4a703          	lw	a4,540(s1)
    80004e4a:	02f70e63          	beq	a4,a5,80004e86 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e4e:	0017871b          	addiw	a4,a5,1
    80004e52:	20e4ac23          	sw	a4,536(s1)
    80004e56:	1ff7f793          	andi	a5,a5,511
    80004e5a:	97a6                	add	a5,a5,s1
    80004e5c:	0187c783          	lbu	a5,24(a5)
    80004e60:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e64:	4685                	li	a3,1
    80004e66:	fbf40613          	addi	a2,s0,-65
    80004e6a:	85ca                	mv	a1,s2
    80004e6c:	050a3503          	ld	a0,80(s4)
    80004e70:	ffffc097          	auipc	ra,0xffffc
    80004e74:	7fc080e7          	jalr	2044(ra) # 8000166c <copyout>
    80004e78:	01650763          	beq	a0,s6,80004e86 <piperead+0xb4>
  for (i = 0; i < n; i++)
    80004e7c:	2985                	addiw	s3,s3,1
    80004e7e:	0905                	addi	s2,s2,1
    80004e80:	fd3a91e3          	bne	s5,s3,80004e42 <piperead+0x70>
    80004e84:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite); // DOC: piperead-wakeup
    80004e86:	21c48513          	addi	a0,s1,540
    80004e8a:	ffffd097          	auipc	ra,0xffffd
    80004e8e:	282080e7          	jalr	642(ra) # 8000210c <wakeup>
  release(&pi->lock);
    80004e92:	8526                	mv	a0,s1
    80004e94:	ffffc097          	auipc	ra,0xffffc
    80004e98:	df6080e7          	jalr	-522(ra) # 80000c8a <release>
  return i;
}
    80004e9c:	854e                	mv	a0,s3
    80004e9e:	60a6                	ld	ra,72(sp)
    80004ea0:	6406                	ld	s0,64(sp)
    80004ea2:	74e2                	ld	s1,56(sp)
    80004ea4:	7942                	ld	s2,48(sp)
    80004ea6:	79a2                	ld	s3,40(sp)
    80004ea8:	7a02                	ld	s4,32(sp)
    80004eaa:	6ae2                	ld	s5,24(sp)
    80004eac:	6b42                	ld	s6,16(sp)
    80004eae:	6161                	addi	sp,sp,80
    80004eb0:	8082                	ret
      release(&pi->lock);
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	ffffc097          	auipc	ra,0xffffc
    80004eb8:	dd6080e7          	jalr	-554(ra) # 80000c8a <release>
      return -1;
    80004ebc:	59fd                	li	s3,-1
    80004ebe:	bff9                	j	80004e9c <piperead+0xca>

0000000080004ec0 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004ec0:	1141                	addi	sp,sp,-16
    80004ec2:	e422                	sd	s0,8(sp)
    80004ec4:	0800                	addi	s0,sp,16
    80004ec6:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004ec8:	8905                	andi	a0,a0,1
    80004eca:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80004ecc:	8b89                	andi	a5,a5,2
    80004ece:	c399                	beqz	a5,80004ed4 <flags2perm+0x14>
    perm |= PTE_W;
    80004ed0:	00456513          	ori	a0,a0,4
  return perm;
}
    80004ed4:	6422                	ld	s0,8(sp)
    80004ed6:	0141                	addi	sp,sp,16
    80004ed8:	8082                	ret

0000000080004eda <exec>:

int exec(char *path, char **argv)
{
    80004eda:	de010113          	addi	sp,sp,-544
    80004ede:	20113c23          	sd	ra,536(sp)
    80004ee2:	20813823          	sd	s0,528(sp)
    80004ee6:	20913423          	sd	s1,520(sp)
    80004eea:	21213023          	sd	s2,512(sp)
    80004eee:	ffce                	sd	s3,504(sp)
    80004ef0:	fbd2                	sd	s4,496(sp)
    80004ef2:	f7d6                	sd	s5,488(sp)
    80004ef4:	f3da                	sd	s6,480(sp)
    80004ef6:	efde                	sd	s7,472(sp)
    80004ef8:	ebe2                	sd	s8,464(sp)
    80004efa:	e7e6                	sd	s9,456(sp)
    80004efc:	e3ea                	sd	s10,448(sp)
    80004efe:	ff6e                	sd	s11,440(sp)
    80004f00:	1400                	addi	s0,sp,544
    80004f02:	892a                	mv	s2,a0
    80004f04:	dea43423          	sd	a0,-536(s0)
    80004f08:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f0c:	ffffd097          	auipc	ra,0xffffd
    80004f10:	aa0080e7          	jalr	-1376(ra) # 800019ac <myproc>
    80004f14:	84aa                	mv	s1,a0

  begin_op();
    80004f16:	fffff097          	auipc	ra,0xfffff
    80004f1a:	482080e7          	jalr	1154(ra) # 80004398 <begin_op>

  if ((ip = namei(path)) == 0)
    80004f1e:	854a                	mv	a0,s2
    80004f20:	fffff097          	auipc	ra,0xfffff
    80004f24:	258080e7          	jalr	600(ra) # 80004178 <namei>
    80004f28:	c93d                	beqz	a0,80004f9e <exec+0xc4>
    80004f2a:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80004f2c:	fffff097          	auipc	ra,0xfffff
    80004f30:	aa0080e7          	jalr	-1376(ra) # 800039cc <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f34:	04000713          	li	a4,64
    80004f38:	4681                	li	a3,0
    80004f3a:	e5040613          	addi	a2,s0,-432
    80004f3e:	4581                	li	a1,0
    80004f40:	8556                	mv	a0,s5
    80004f42:	fffff097          	auipc	ra,0xfffff
    80004f46:	d3e080e7          	jalr	-706(ra) # 80003c80 <readi>
    80004f4a:	04000793          	li	a5,64
    80004f4e:	00f51a63          	bne	a0,a5,80004f62 <exec+0x88>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    80004f52:	e5042703          	lw	a4,-432(s0)
    80004f56:	464c47b7          	lui	a5,0x464c4
    80004f5a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f5e:	04f70663          	beq	a4,a5,80004faa <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80004f62:	8556                	mv	a0,s5
    80004f64:	fffff097          	auipc	ra,0xfffff
    80004f68:	cca080e7          	jalr	-822(ra) # 80003c2e <iunlockput>
    end_op();
    80004f6c:	fffff097          	auipc	ra,0xfffff
    80004f70:	4aa080e7          	jalr	1194(ra) # 80004416 <end_op>
  }
  return -1;
    80004f74:	557d                	li	a0,-1
}
    80004f76:	21813083          	ld	ra,536(sp)
    80004f7a:	21013403          	ld	s0,528(sp)
    80004f7e:	20813483          	ld	s1,520(sp)
    80004f82:	20013903          	ld	s2,512(sp)
    80004f86:	79fe                	ld	s3,504(sp)
    80004f88:	7a5e                	ld	s4,496(sp)
    80004f8a:	7abe                	ld	s5,488(sp)
    80004f8c:	7b1e                	ld	s6,480(sp)
    80004f8e:	6bfe                	ld	s7,472(sp)
    80004f90:	6c5e                	ld	s8,464(sp)
    80004f92:	6cbe                	ld	s9,456(sp)
    80004f94:	6d1e                	ld	s10,448(sp)
    80004f96:	7dfa                	ld	s11,440(sp)
    80004f98:	22010113          	addi	sp,sp,544
    80004f9c:	8082                	ret
    end_op();
    80004f9e:	fffff097          	auipc	ra,0xfffff
    80004fa2:	478080e7          	jalr	1144(ra) # 80004416 <end_op>
    return -1;
    80004fa6:	557d                	li	a0,-1
    80004fa8:	b7f9                	j	80004f76 <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    80004faa:	8526                	mv	a0,s1
    80004fac:	ffffd097          	auipc	ra,0xffffd
    80004fb0:	ac4080e7          	jalr	-1340(ra) # 80001a70 <proc_pagetable>
    80004fb4:	8b2a                	mv	s6,a0
    80004fb6:	d555                	beqz	a0,80004f62 <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80004fb8:	e7042783          	lw	a5,-400(s0)
    80004fbc:	e8845703          	lhu	a4,-376(s0)
    80004fc0:	c735                	beqz	a4,8000502c <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fc2:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80004fc4:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    80004fc8:	6a05                	lui	s4,0x1
    80004fca:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004fce:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for (i = 0; i < sz; i += PGSIZE)
    80004fd2:	6d85                	lui	s11,0x1
    80004fd4:	7d7d                	lui	s10,0xfffff
    80004fd6:	ac3d                	j	80005214 <exec+0x33a>
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    80004fd8:	00003517          	auipc	a0,0x3
    80004fdc:	71050513          	addi	a0,a0,1808 # 800086e8 <syscalls+0x298>
    80004fe0:	ffffb097          	auipc	ra,0xffffb
    80004fe4:	560080e7          	jalr	1376(ra) # 80000540 <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004fe8:	874a                	mv	a4,s2
    80004fea:	009c86bb          	addw	a3,s9,s1
    80004fee:	4581                	li	a1,0
    80004ff0:	8556                	mv	a0,s5
    80004ff2:	fffff097          	auipc	ra,0xfffff
    80004ff6:	c8e080e7          	jalr	-882(ra) # 80003c80 <readi>
    80004ffa:	2501                	sext.w	a0,a0
    80004ffc:	1aa91963          	bne	s2,a0,800051ae <exec+0x2d4>
  for (i = 0; i < sz; i += PGSIZE)
    80005000:	009d84bb          	addw	s1,s11,s1
    80005004:	013d09bb          	addw	s3,s10,s3
    80005008:	1f74f663          	bgeu	s1,s7,800051f4 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    8000500c:	02049593          	slli	a1,s1,0x20
    80005010:	9181                	srli	a1,a1,0x20
    80005012:	95e2                	add	a1,a1,s8
    80005014:	855a                	mv	a0,s6
    80005016:	ffffc097          	auipc	ra,0xffffc
    8000501a:	046080e7          	jalr	70(ra) # 8000105c <walkaddr>
    8000501e:	862a                	mv	a2,a0
    if (pa == 0)
    80005020:	dd45                	beqz	a0,80004fd8 <exec+0xfe>
      n = PGSIZE;
    80005022:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005024:	fd49f2e3          	bgeu	s3,s4,80004fe8 <exec+0x10e>
      n = sz - i;
    80005028:	894e                	mv	s2,s3
    8000502a:	bf7d                	j	80004fe8 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000502c:	4901                	li	s2,0
  iunlockput(ip);
    8000502e:	8556                	mv	a0,s5
    80005030:	fffff097          	auipc	ra,0xfffff
    80005034:	bfe080e7          	jalr	-1026(ra) # 80003c2e <iunlockput>
  end_op();
    80005038:	fffff097          	auipc	ra,0xfffff
    8000503c:	3de080e7          	jalr	990(ra) # 80004416 <end_op>
  p = myproc();
    80005040:	ffffd097          	auipc	ra,0xffffd
    80005044:	96c080e7          	jalr	-1684(ra) # 800019ac <myproc>
    80005048:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000504a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000504e:	6785                	lui	a5,0x1
    80005050:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005052:	97ca                	add	a5,a5,s2
    80005054:	777d                	lui	a4,0xfffff
    80005056:	8ff9                	and	a5,a5,a4
    80005058:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    8000505c:	4691                	li	a3,4
    8000505e:	6609                	lui	a2,0x2
    80005060:	963e                	add	a2,a2,a5
    80005062:	85be                	mv	a1,a5
    80005064:	855a                	mv	a0,s6
    80005066:	ffffc097          	auipc	ra,0xffffc
    8000506a:	3aa080e7          	jalr	938(ra) # 80001410 <uvmalloc>
    8000506e:	8c2a                	mv	s8,a0
  ip = 0;
    80005070:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    80005072:	12050e63          	beqz	a0,800051ae <exec+0x2d4>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005076:	75f9                	lui	a1,0xffffe
    80005078:	95aa                	add	a1,a1,a0
    8000507a:	855a                	mv	a0,s6
    8000507c:	ffffc097          	auipc	ra,0xffffc
    80005080:	5be080e7          	jalr	1470(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80005084:	7afd                	lui	s5,0xfffff
    80005086:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    80005088:	df043783          	ld	a5,-528(s0)
    8000508c:	6388                	ld	a0,0(a5)
    8000508e:	c925                	beqz	a0,800050fe <exec+0x224>
    80005090:	e9040993          	addi	s3,s0,-368
    80005094:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005098:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    8000509a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000509c:	ffffc097          	auipc	ra,0xffffc
    800050a0:	db2080e7          	jalr	-590(ra) # 80000e4e <strlen>
    800050a4:	0015079b          	addiw	a5,a0,1
    800050a8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050ac:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    800050b0:	13596663          	bltu	s2,s5,800051dc <exec+0x302>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050b4:	df043d83          	ld	s11,-528(s0)
    800050b8:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800050bc:	8552                	mv	a0,s4
    800050be:	ffffc097          	auipc	ra,0xffffc
    800050c2:	d90080e7          	jalr	-624(ra) # 80000e4e <strlen>
    800050c6:	0015069b          	addiw	a3,a0,1
    800050ca:	8652                	mv	a2,s4
    800050cc:	85ca                	mv	a1,s2
    800050ce:	855a                	mv	a0,s6
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	59c080e7          	jalr	1436(ra) # 8000166c <copyout>
    800050d8:	10054663          	bltz	a0,800051e4 <exec+0x30a>
    ustack[argc] = sp;
    800050dc:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    800050e0:	0485                	addi	s1,s1,1
    800050e2:	008d8793          	addi	a5,s11,8
    800050e6:	def43823          	sd	a5,-528(s0)
    800050ea:	008db503          	ld	a0,8(s11)
    800050ee:	c911                	beqz	a0,80005102 <exec+0x228>
    if (argc >= MAXARG)
    800050f0:	09a1                	addi	s3,s3,8
    800050f2:	fb3c95e3          	bne	s9,s3,8000509c <exec+0x1c2>
  sz = sz1;
    800050f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050fa:	4a81                	li	s5,0
    800050fc:	a84d                	j	800051ae <exec+0x2d4>
  sp = sz;
    800050fe:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005100:	4481                	li	s1,0
  ustack[argc] = 0;
    80005102:	00349793          	slli	a5,s1,0x3
    80005106:	f9078793          	addi	a5,a5,-112
    8000510a:	97a2                	add	a5,a5,s0
    8000510c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80005110:	00148693          	addi	a3,s1,1
    80005114:	068e                	slli	a3,a3,0x3
    80005116:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000511a:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    8000511e:	01597663          	bgeu	s2,s5,8000512a <exec+0x250>
  sz = sz1;
    80005122:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005126:	4a81                	li	s5,0
    80005128:	a059                	j	800051ae <exec+0x2d4>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    8000512a:	e9040613          	addi	a2,s0,-368
    8000512e:	85ca                	mv	a1,s2
    80005130:	855a                	mv	a0,s6
    80005132:	ffffc097          	auipc	ra,0xffffc
    80005136:	53a080e7          	jalr	1338(ra) # 8000166c <copyout>
    8000513a:	0a054963          	bltz	a0,800051ec <exec+0x312>
  p->trapframe->a1 = sp;
    8000513e:	058bb783          	ld	a5,88(s7)
    80005142:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005146:	de843783          	ld	a5,-536(s0)
    8000514a:	0007c703          	lbu	a4,0(a5)
    8000514e:	cf11                	beqz	a4,8000516a <exec+0x290>
    80005150:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005152:	02f00693          	li	a3,47
    80005156:	a039                	j	80005164 <exec+0x28a>
      last = s + 1;
    80005158:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    8000515c:	0785                	addi	a5,a5,1
    8000515e:	fff7c703          	lbu	a4,-1(a5)
    80005162:	c701                	beqz	a4,8000516a <exec+0x290>
    if (*s == '/')
    80005164:	fed71ce3          	bne	a4,a3,8000515c <exec+0x282>
    80005168:	bfc5                	j	80005158 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000516a:	4641                	li	a2,16
    8000516c:	de843583          	ld	a1,-536(s0)
    80005170:	158b8513          	addi	a0,s7,344
    80005174:	ffffc097          	auipc	ra,0xffffc
    80005178:	ca8080e7          	jalr	-856(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000517c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005180:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005184:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    80005188:	058bb783          	ld	a5,88(s7)
    8000518c:	e6843703          	ld	a4,-408(s0)
    80005190:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005192:	058bb783          	ld	a5,88(s7)
    80005196:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000519a:	85ea                	mv	a1,s10
    8000519c:	ffffd097          	auipc	ra,0xffffd
    800051a0:	970080e7          	jalr	-1680(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051a4:	0004851b          	sext.w	a0,s1
    800051a8:	b3f9                	j	80004f76 <exec+0x9c>
    800051aa:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051ae:	df843583          	ld	a1,-520(s0)
    800051b2:	855a                	mv	a0,s6
    800051b4:	ffffd097          	auipc	ra,0xffffd
    800051b8:	958080e7          	jalr	-1704(ra) # 80001b0c <proc_freepagetable>
  if (ip)
    800051bc:	da0a93e3          	bnez	s5,80004f62 <exec+0x88>
  return -1;
    800051c0:	557d                	li	a0,-1
    800051c2:	bb55                	j	80004f76 <exec+0x9c>
    800051c4:	df243c23          	sd	s2,-520(s0)
    800051c8:	b7dd                	j	800051ae <exec+0x2d4>
    800051ca:	df243c23          	sd	s2,-520(s0)
    800051ce:	b7c5                	j	800051ae <exec+0x2d4>
    800051d0:	df243c23          	sd	s2,-520(s0)
    800051d4:	bfe9                	j	800051ae <exec+0x2d4>
    800051d6:	df243c23          	sd	s2,-520(s0)
    800051da:	bfd1                	j	800051ae <exec+0x2d4>
  sz = sz1;
    800051dc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051e0:	4a81                	li	s5,0
    800051e2:	b7f1                	j	800051ae <exec+0x2d4>
  sz = sz1;
    800051e4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051e8:	4a81                	li	s5,0
    800051ea:	b7d1                	j	800051ae <exec+0x2d4>
  sz = sz1;
    800051ec:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051f0:	4a81                	li	s5,0
    800051f2:	bf75                	j	800051ae <exec+0x2d4>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051f4:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800051f8:	e0843783          	ld	a5,-504(s0)
    800051fc:	0017869b          	addiw	a3,a5,1
    80005200:	e0d43423          	sd	a3,-504(s0)
    80005204:	e0043783          	ld	a5,-512(s0)
    80005208:	0387879b          	addiw	a5,a5,56
    8000520c:	e8845703          	lhu	a4,-376(s0)
    80005210:	e0e6dfe3          	bge	a3,a4,8000502e <exec+0x154>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005214:	2781                	sext.w	a5,a5
    80005216:	e0f43023          	sd	a5,-512(s0)
    8000521a:	03800713          	li	a4,56
    8000521e:	86be                	mv	a3,a5
    80005220:	e1840613          	addi	a2,s0,-488
    80005224:	4581                	li	a1,0
    80005226:	8556                	mv	a0,s5
    80005228:	fffff097          	auipc	ra,0xfffff
    8000522c:	a58080e7          	jalr	-1448(ra) # 80003c80 <readi>
    80005230:	03800793          	li	a5,56
    80005234:	f6f51be3          	bne	a0,a5,800051aa <exec+0x2d0>
    if (ph.type != ELF_PROG_LOAD)
    80005238:	e1842783          	lw	a5,-488(s0)
    8000523c:	4705                	li	a4,1
    8000523e:	fae79de3          	bne	a5,a4,800051f8 <exec+0x31e>
    if (ph.memsz < ph.filesz)
    80005242:	e4043483          	ld	s1,-448(s0)
    80005246:	e3843783          	ld	a5,-456(s0)
    8000524a:	f6f4ede3          	bltu	s1,a5,800051c4 <exec+0x2ea>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    8000524e:	e2843783          	ld	a5,-472(s0)
    80005252:	94be                	add	s1,s1,a5
    80005254:	f6f4ebe3          	bltu	s1,a5,800051ca <exec+0x2f0>
    if (ph.vaddr % PGSIZE != 0)
    80005258:	de043703          	ld	a4,-544(s0)
    8000525c:	8ff9                	and	a5,a5,a4
    8000525e:	fbad                	bnez	a5,800051d0 <exec+0x2f6>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005260:	e1c42503          	lw	a0,-484(s0)
    80005264:	00000097          	auipc	ra,0x0
    80005268:	c5c080e7          	jalr	-932(ra) # 80004ec0 <flags2perm>
    8000526c:	86aa                	mv	a3,a0
    8000526e:	8626                	mv	a2,s1
    80005270:	85ca                	mv	a1,s2
    80005272:	855a                	mv	a0,s6
    80005274:	ffffc097          	auipc	ra,0xffffc
    80005278:	19c080e7          	jalr	412(ra) # 80001410 <uvmalloc>
    8000527c:	dea43c23          	sd	a0,-520(s0)
    80005280:	d939                	beqz	a0,800051d6 <exec+0x2fc>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005282:	e2843c03          	ld	s8,-472(s0)
    80005286:	e2042c83          	lw	s9,-480(s0)
    8000528a:	e3842b83          	lw	s7,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    8000528e:	f60b83e3          	beqz	s7,800051f4 <exec+0x31a>
    80005292:	89de                	mv	s3,s7
    80005294:	4481                	li	s1,0
    80005296:	bb9d                	j	8000500c <exec+0x132>

0000000080005298 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005298:	7179                	addi	sp,sp,-48
    8000529a:	f406                	sd	ra,40(sp)
    8000529c:	f022                	sd	s0,32(sp)
    8000529e:	ec26                	sd	s1,24(sp)
    800052a0:	e84a                	sd	s2,16(sp)
    800052a2:	1800                	addi	s0,sp,48
    800052a4:	892e                	mv	s2,a1
    800052a6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800052a8:	fdc40593          	addi	a1,s0,-36
    800052ac:	ffffe097          	auipc	ra,0xffffe
    800052b0:	a7c080e7          	jalr	-1412(ra) # 80002d28 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    800052b4:	fdc42703          	lw	a4,-36(s0)
    800052b8:	47bd                	li	a5,15
    800052ba:	02e7eb63          	bltu	a5,a4,800052f0 <argfd+0x58>
    800052be:	ffffc097          	auipc	ra,0xffffc
    800052c2:	6ee080e7          	jalr	1774(ra) # 800019ac <myproc>
    800052c6:	fdc42703          	lw	a4,-36(s0)
    800052ca:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdb872>
    800052ce:	078e                	slli	a5,a5,0x3
    800052d0:	953e                	add	a0,a0,a5
    800052d2:	611c                	ld	a5,0(a0)
    800052d4:	c385                	beqz	a5,800052f4 <argfd+0x5c>
    return -1;
  if (pfd)
    800052d6:	00090463          	beqz	s2,800052de <argfd+0x46>
    *pfd = fd;
    800052da:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    800052de:	4501                	li	a0,0
  if (pf)
    800052e0:	c091                	beqz	s1,800052e4 <argfd+0x4c>
    *pf = f;
    800052e2:	e09c                	sd	a5,0(s1)
}
    800052e4:	70a2                	ld	ra,40(sp)
    800052e6:	7402                	ld	s0,32(sp)
    800052e8:	64e2                	ld	s1,24(sp)
    800052ea:	6942                	ld	s2,16(sp)
    800052ec:	6145                	addi	sp,sp,48
    800052ee:	8082                	ret
    return -1;
    800052f0:	557d                	li	a0,-1
    800052f2:	bfcd                	j	800052e4 <argfd+0x4c>
    800052f4:	557d                	li	a0,-1
    800052f6:	b7fd                	j	800052e4 <argfd+0x4c>

00000000800052f8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052f8:	1101                	addi	sp,sp,-32
    800052fa:	ec06                	sd	ra,24(sp)
    800052fc:	e822                	sd	s0,16(sp)
    800052fe:	e426                	sd	s1,8(sp)
    80005300:	1000                	addi	s0,sp,32
    80005302:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005304:	ffffc097          	auipc	ra,0xffffc
    80005308:	6a8080e7          	jalr	1704(ra) # 800019ac <myproc>
    8000530c:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++)
    8000530e:	0d050793          	addi	a5,a0,208
    80005312:	4501                	li	a0,0
    80005314:	46c1                	li	a3,16
  {
    if (p->ofile[fd] == 0)
    80005316:	6398                	ld	a4,0(a5)
    80005318:	cb19                	beqz	a4,8000532e <fdalloc+0x36>
  for (fd = 0; fd < NOFILE; fd++)
    8000531a:	2505                	addiw	a0,a0,1
    8000531c:	07a1                	addi	a5,a5,8
    8000531e:	fed51ce3          	bne	a0,a3,80005316 <fdalloc+0x1e>
    {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005322:	557d                	li	a0,-1
}
    80005324:	60e2                	ld	ra,24(sp)
    80005326:	6442                	ld	s0,16(sp)
    80005328:	64a2                	ld	s1,8(sp)
    8000532a:	6105                	addi	sp,sp,32
    8000532c:	8082                	ret
      p->ofile[fd] = f;
    8000532e:	01a50793          	addi	a5,a0,26
    80005332:	078e                	slli	a5,a5,0x3
    80005334:	963e                	add	a2,a2,a5
    80005336:	e204                	sd	s1,0(a2)
      return fd;
    80005338:	b7f5                	j	80005324 <fdalloc+0x2c>

000000008000533a <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    8000533a:	715d                	addi	sp,sp,-80
    8000533c:	e486                	sd	ra,72(sp)
    8000533e:	e0a2                	sd	s0,64(sp)
    80005340:	fc26                	sd	s1,56(sp)
    80005342:	f84a                	sd	s2,48(sp)
    80005344:	f44e                	sd	s3,40(sp)
    80005346:	f052                	sd	s4,32(sp)
    80005348:	ec56                	sd	s5,24(sp)
    8000534a:	e85a                	sd	s6,16(sp)
    8000534c:	0880                	addi	s0,sp,80
    8000534e:	8b2e                	mv	s6,a1
    80005350:	89b2                	mv	s3,a2
    80005352:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80005354:	fb040593          	addi	a1,s0,-80
    80005358:	fffff097          	auipc	ra,0xfffff
    8000535c:	e3e080e7          	jalr	-450(ra) # 80004196 <nameiparent>
    80005360:	84aa                	mv	s1,a0
    80005362:	14050f63          	beqz	a0,800054c0 <create+0x186>
    return 0;

  ilock(dp);
    80005366:	ffffe097          	auipc	ra,0xffffe
    8000536a:	666080e7          	jalr	1638(ra) # 800039cc <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0)
    8000536e:	4601                	li	a2,0
    80005370:	fb040593          	addi	a1,s0,-80
    80005374:	8526                	mv	a0,s1
    80005376:	fffff097          	auipc	ra,0xfffff
    8000537a:	b3a080e7          	jalr	-1222(ra) # 80003eb0 <dirlookup>
    8000537e:	8aaa                	mv	s5,a0
    80005380:	c931                	beqz	a0,800053d4 <create+0x9a>
  {
    iunlockput(dp);
    80005382:	8526                	mv	a0,s1
    80005384:	fffff097          	auipc	ra,0xfffff
    80005388:	8aa080e7          	jalr	-1878(ra) # 80003c2e <iunlockput>
    ilock(ip);
    8000538c:	8556                	mv	a0,s5
    8000538e:	ffffe097          	auipc	ra,0xffffe
    80005392:	63e080e7          	jalr	1598(ra) # 800039cc <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005396:	000b059b          	sext.w	a1,s6
    8000539a:	4789                	li	a5,2
    8000539c:	02f59563          	bne	a1,a5,800053c6 <create+0x8c>
    800053a0:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdb89c>
    800053a4:	37f9                	addiw	a5,a5,-2
    800053a6:	17c2                	slli	a5,a5,0x30
    800053a8:	93c1                	srli	a5,a5,0x30
    800053aa:	4705                	li	a4,1
    800053ac:	00f76d63          	bltu	a4,a5,800053c6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800053b0:	8556                	mv	a0,s5
    800053b2:	60a6                	ld	ra,72(sp)
    800053b4:	6406                	ld	s0,64(sp)
    800053b6:	74e2                	ld	s1,56(sp)
    800053b8:	7942                	ld	s2,48(sp)
    800053ba:	79a2                	ld	s3,40(sp)
    800053bc:	7a02                	ld	s4,32(sp)
    800053be:	6ae2                	ld	s5,24(sp)
    800053c0:	6b42                	ld	s6,16(sp)
    800053c2:	6161                	addi	sp,sp,80
    800053c4:	8082                	ret
    iunlockput(ip);
    800053c6:	8556                	mv	a0,s5
    800053c8:	fffff097          	auipc	ra,0xfffff
    800053cc:	866080e7          	jalr	-1946(ra) # 80003c2e <iunlockput>
    return 0;
    800053d0:	4a81                	li	s5,0
    800053d2:	bff9                	j	800053b0 <create+0x76>
  if ((ip = ialloc(dp->dev, type)) == 0)
    800053d4:	85da                	mv	a1,s6
    800053d6:	4088                	lw	a0,0(s1)
    800053d8:	ffffe097          	auipc	ra,0xffffe
    800053dc:	456080e7          	jalr	1110(ra) # 8000382e <ialloc>
    800053e0:	8a2a                	mv	s4,a0
    800053e2:	c539                	beqz	a0,80005430 <create+0xf6>
  ilock(ip);
    800053e4:	ffffe097          	auipc	ra,0xffffe
    800053e8:	5e8080e7          	jalr	1512(ra) # 800039cc <ilock>
  ip->major = major;
    800053ec:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053f0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053f4:	4905                	li	s2,1
    800053f6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053fa:	8552                	mv	a0,s4
    800053fc:	ffffe097          	auipc	ra,0xffffe
    80005400:	504080e7          	jalr	1284(ra) # 80003900 <iupdate>
  if (type == T_DIR)
    80005404:	000b059b          	sext.w	a1,s6
    80005408:	03258b63          	beq	a1,s2,8000543e <create+0x104>
  if (dirlink(dp, name, ip->inum) < 0)
    8000540c:	004a2603          	lw	a2,4(s4)
    80005410:	fb040593          	addi	a1,s0,-80
    80005414:	8526                	mv	a0,s1
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	cb0080e7          	jalr	-848(ra) # 800040c6 <dirlink>
    8000541e:	06054f63          	bltz	a0,8000549c <create+0x162>
  iunlockput(dp);
    80005422:	8526                	mv	a0,s1
    80005424:	fffff097          	auipc	ra,0xfffff
    80005428:	80a080e7          	jalr	-2038(ra) # 80003c2e <iunlockput>
  return ip;
    8000542c:	8ad2                	mv	s5,s4
    8000542e:	b749                	j	800053b0 <create+0x76>
    iunlockput(dp);
    80005430:	8526                	mv	a0,s1
    80005432:	ffffe097          	auipc	ra,0xffffe
    80005436:	7fc080e7          	jalr	2044(ra) # 80003c2e <iunlockput>
    return 0;
    8000543a:	8ad2                	mv	s5,s4
    8000543c:	bf95                	j	800053b0 <create+0x76>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000543e:	004a2603          	lw	a2,4(s4)
    80005442:	00003597          	auipc	a1,0x3
    80005446:	2c658593          	addi	a1,a1,710 # 80008708 <syscalls+0x2b8>
    8000544a:	8552                	mv	a0,s4
    8000544c:	fffff097          	auipc	ra,0xfffff
    80005450:	c7a080e7          	jalr	-902(ra) # 800040c6 <dirlink>
    80005454:	04054463          	bltz	a0,8000549c <create+0x162>
    80005458:	40d0                	lw	a2,4(s1)
    8000545a:	00003597          	auipc	a1,0x3
    8000545e:	2b658593          	addi	a1,a1,694 # 80008710 <syscalls+0x2c0>
    80005462:	8552                	mv	a0,s4
    80005464:	fffff097          	auipc	ra,0xfffff
    80005468:	c62080e7          	jalr	-926(ra) # 800040c6 <dirlink>
    8000546c:	02054863          	bltz	a0,8000549c <create+0x162>
  if (dirlink(dp, name, ip->inum) < 0)
    80005470:	004a2603          	lw	a2,4(s4)
    80005474:	fb040593          	addi	a1,s0,-80
    80005478:	8526                	mv	a0,s1
    8000547a:	fffff097          	auipc	ra,0xfffff
    8000547e:	c4c080e7          	jalr	-948(ra) # 800040c6 <dirlink>
    80005482:	00054d63          	bltz	a0,8000549c <create+0x162>
    dp->nlink++; // for ".."
    80005486:	04a4d783          	lhu	a5,74(s1)
    8000548a:	2785                	addiw	a5,a5,1
    8000548c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005490:	8526                	mv	a0,s1
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	46e080e7          	jalr	1134(ra) # 80003900 <iupdate>
    8000549a:	b761                	j	80005422 <create+0xe8>
  ip->nlink = 0;
    8000549c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800054a0:	8552                	mv	a0,s4
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	45e080e7          	jalr	1118(ra) # 80003900 <iupdate>
  iunlockput(ip);
    800054aa:	8552                	mv	a0,s4
    800054ac:	ffffe097          	auipc	ra,0xffffe
    800054b0:	782080e7          	jalr	1922(ra) # 80003c2e <iunlockput>
  iunlockput(dp);
    800054b4:	8526                	mv	a0,s1
    800054b6:	ffffe097          	auipc	ra,0xffffe
    800054ba:	778080e7          	jalr	1912(ra) # 80003c2e <iunlockput>
  return 0;
    800054be:	bdcd                	j	800053b0 <create+0x76>
    return 0;
    800054c0:	8aaa                	mv	s5,a0
    800054c2:	b5fd                	j	800053b0 <create+0x76>

00000000800054c4 <sys_dup>:
{
    800054c4:	7179                	addi	sp,sp,-48
    800054c6:	f406                	sd	ra,40(sp)
    800054c8:	f022                	sd	s0,32(sp)
    800054ca:	ec26                	sd	s1,24(sp)
    800054cc:	e84a                	sd	s2,16(sp)
    800054ce:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    800054d0:	fd840613          	addi	a2,s0,-40
    800054d4:	4581                	li	a1,0
    800054d6:	4501                	li	a0,0
    800054d8:	00000097          	auipc	ra,0x0
    800054dc:	dc0080e7          	jalr	-576(ra) # 80005298 <argfd>
    return -1;
    800054e0:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    800054e2:	02054363          	bltz	a0,80005508 <sys_dup+0x44>
  if ((fd = fdalloc(f)) < 0)
    800054e6:	fd843903          	ld	s2,-40(s0)
    800054ea:	854a                	mv	a0,s2
    800054ec:	00000097          	auipc	ra,0x0
    800054f0:	e0c080e7          	jalr	-500(ra) # 800052f8 <fdalloc>
    800054f4:	84aa                	mv	s1,a0
    return -1;
    800054f6:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    800054f8:	00054863          	bltz	a0,80005508 <sys_dup+0x44>
  filedup(f);
    800054fc:	854a                	mv	a0,s2
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	310080e7          	jalr	784(ra) # 8000480e <filedup>
  return fd;
    80005506:	87a6                	mv	a5,s1
}
    80005508:	853e                	mv	a0,a5
    8000550a:	70a2                	ld	ra,40(sp)
    8000550c:	7402                	ld	s0,32(sp)
    8000550e:	64e2                	ld	s1,24(sp)
    80005510:	6942                	ld	s2,16(sp)
    80005512:	6145                	addi	sp,sp,48
    80005514:	8082                	ret

0000000080005516 <sys_read>:
{
    80005516:	7179                	addi	sp,sp,-48
    80005518:	f406                	sd	ra,40(sp)
    8000551a:	f022                	sd	s0,32(sp)
    8000551c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000551e:	fd840593          	addi	a1,s0,-40
    80005522:	4505                	li	a0,1
    80005524:	ffffe097          	auipc	ra,0xffffe
    80005528:	824080e7          	jalr	-2012(ra) # 80002d48 <argaddr>
  argint(2, &n);
    8000552c:	fe440593          	addi	a1,s0,-28
    80005530:	4509                	li	a0,2
    80005532:	ffffd097          	auipc	ra,0xffffd
    80005536:	7f6080e7          	jalr	2038(ra) # 80002d28 <argint>
  if (argfd(0, 0, &f) < 0)
    8000553a:	fe840613          	addi	a2,s0,-24
    8000553e:	4581                	li	a1,0
    80005540:	4501                	li	a0,0
    80005542:	00000097          	auipc	ra,0x0
    80005546:	d56080e7          	jalr	-682(ra) # 80005298 <argfd>
    8000554a:	87aa                	mv	a5,a0
    return -1;
    8000554c:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000554e:	0007cc63          	bltz	a5,80005566 <sys_read+0x50>
  return fileread(f, p, n);
    80005552:	fe442603          	lw	a2,-28(s0)
    80005556:	fd843583          	ld	a1,-40(s0)
    8000555a:	fe843503          	ld	a0,-24(s0)
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	43c080e7          	jalr	1084(ra) # 8000499a <fileread>
}
    80005566:	70a2                	ld	ra,40(sp)
    80005568:	7402                	ld	s0,32(sp)
    8000556a:	6145                	addi	sp,sp,48
    8000556c:	8082                	ret

000000008000556e <sys_write>:
{
    8000556e:	7179                	addi	sp,sp,-48
    80005570:	f406                	sd	ra,40(sp)
    80005572:	f022                	sd	s0,32(sp)
    80005574:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005576:	fd840593          	addi	a1,s0,-40
    8000557a:	4505                	li	a0,1
    8000557c:	ffffd097          	auipc	ra,0xffffd
    80005580:	7cc080e7          	jalr	1996(ra) # 80002d48 <argaddr>
  argint(2, &n);
    80005584:	fe440593          	addi	a1,s0,-28
    80005588:	4509                	li	a0,2
    8000558a:	ffffd097          	auipc	ra,0xffffd
    8000558e:	79e080e7          	jalr	1950(ra) # 80002d28 <argint>
  if (argfd(0, 0, &f) < 0)
    80005592:	fe840613          	addi	a2,s0,-24
    80005596:	4581                	li	a1,0
    80005598:	4501                	li	a0,0
    8000559a:	00000097          	auipc	ra,0x0
    8000559e:	cfe080e7          	jalr	-770(ra) # 80005298 <argfd>
    800055a2:	87aa                	mv	a5,a0
    return -1;
    800055a4:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800055a6:	0007cc63          	bltz	a5,800055be <sys_write+0x50>
  return filewrite(f, p, n);
    800055aa:	fe442603          	lw	a2,-28(s0)
    800055ae:	fd843583          	ld	a1,-40(s0)
    800055b2:	fe843503          	ld	a0,-24(s0)
    800055b6:	fffff097          	auipc	ra,0xfffff
    800055ba:	4a6080e7          	jalr	1190(ra) # 80004a5c <filewrite>
}
    800055be:	70a2                	ld	ra,40(sp)
    800055c0:	7402                	ld	s0,32(sp)
    800055c2:	6145                	addi	sp,sp,48
    800055c4:	8082                	ret

00000000800055c6 <sys_close>:
{
    800055c6:	1101                	addi	sp,sp,-32
    800055c8:	ec06                	sd	ra,24(sp)
    800055ca:	e822                	sd	s0,16(sp)
    800055cc:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800055ce:	fe040613          	addi	a2,s0,-32
    800055d2:	fec40593          	addi	a1,s0,-20
    800055d6:	4501                	li	a0,0
    800055d8:	00000097          	auipc	ra,0x0
    800055dc:	cc0080e7          	jalr	-832(ra) # 80005298 <argfd>
    return -1;
    800055e0:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    800055e2:	02054463          	bltz	a0,8000560a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055e6:	ffffc097          	auipc	ra,0xffffc
    800055ea:	3c6080e7          	jalr	966(ra) # 800019ac <myproc>
    800055ee:	fec42783          	lw	a5,-20(s0)
    800055f2:	07e9                	addi	a5,a5,26
    800055f4:	078e                	slli	a5,a5,0x3
    800055f6:	953e                	add	a0,a0,a5
    800055f8:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800055fc:	fe043503          	ld	a0,-32(s0)
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	260080e7          	jalr	608(ra) # 80004860 <fileclose>
  return 0;
    80005608:	4781                	li	a5,0
}
    8000560a:	853e                	mv	a0,a5
    8000560c:	60e2                	ld	ra,24(sp)
    8000560e:	6442                	ld	s0,16(sp)
    80005610:	6105                	addi	sp,sp,32
    80005612:	8082                	ret

0000000080005614 <sys_fstat>:
{
    80005614:	1101                	addi	sp,sp,-32
    80005616:	ec06                	sd	ra,24(sp)
    80005618:	e822                	sd	s0,16(sp)
    8000561a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000561c:	fe040593          	addi	a1,s0,-32
    80005620:	4505                	li	a0,1
    80005622:	ffffd097          	auipc	ra,0xffffd
    80005626:	726080e7          	jalr	1830(ra) # 80002d48 <argaddr>
  if (argfd(0, 0, &f) < 0)
    8000562a:	fe840613          	addi	a2,s0,-24
    8000562e:	4581                	li	a1,0
    80005630:	4501                	li	a0,0
    80005632:	00000097          	auipc	ra,0x0
    80005636:	c66080e7          	jalr	-922(ra) # 80005298 <argfd>
    8000563a:	87aa                	mv	a5,a0
    return -1;
    8000563c:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000563e:	0007ca63          	bltz	a5,80005652 <sys_fstat+0x3e>
  return filestat(f, st);
    80005642:	fe043583          	ld	a1,-32(s0)
    80005646:	fe843503          	ld	a0,-24(s0)
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	2de080e7          	jalr	734(ra) # 80004928 <filestat>
}
    80005652:	60e2                	ld	ra,24(sp)
    80005654:	6442                	ld	s0,16(sp)
    80005656:	6105                	addi	sp,sp,32
    80005658:	8082                	ret

000000008000565a <sys_link>:
{
    8000565a:	7169                	addi	sp,sp,-304
    8000565c:	f606                	sd	ra,296(sp)
    8000565e:	f222                	sd	s0,288(sp)
    80005660:	ee26                	sd	s1,280(sp)
    80005662:	ea4a                	sd	s2,272(sp)
    80005664:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005666:	08000613          	li	a2,128
    8000566a:	ed040593          	addi	a1,s0,-304
    8000566e:	4501                	li	a0,0
    80005670:	ffffd097          	auipc	ra,0xffffd
    80005674:	6f8080e7          	jalr	1784(ra) # 80002d68 <argstr>
    return -1;
    80005678:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000567a:	10054e63          	bltz	a0,80005796 <sys_link+0x13c>
    8000567e:	08000613          	li	a2,128
    80005682:	f5040593          	addi	a1,s0,-176
    80005686:	4505                	li	a0,1
    80005688:	ffffd097          	auipc	ra,0xffffd
    8000568c:	6e0080e7          	jalr	1760(ra) # 80002d68 <argstr>
    return -1;
    80005690:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005692:	10054263          	bltz	a0,80005796 <sys_link+0x13c>
  begin_op();
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	d02080e7          	jalr	-766(ra) # 80004398 <begin_op>
  if ((ip = namei(old)) == 0)
    8000569e:	ed040513          	addi	a0,s0,-304
    800056a2:	fffff097          	auipc	ra,0xfffff
    800056a6:	ad6080e7          	jalr	-1322(ra) # 80004178 <namei>
    800056aa:	84aa                	mv	s1,a0
    800056ac:	c551                	beqz	a0,80005738 <sys_link+0xde>
  ilock(ip);
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	31e080e7          	jalr	798(ra) # 800039cc <ilock>
  if (ip->type == T_DIR)
    800056b6:	04449703          	lh	a4,68(s1)
    800056ba:	4785                	li	a5,1
    800056bc:	08f70463          	beq	a4,a5,80005744 <sys_link+0xea>
  ip->nlink++;
    800056c0:	04a4d783          	lhu	a5,74(s1)
    800056c4:	2785                	addiw	a5,a5,1
    800056c6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056ca:	8526                	mv	a0,s1
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	234080e7          	jalr	564(ra) # 80003900 <iupdate>
  iunlock(ip);
    800056d4:	8526                	mv	a0,s1
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	3b8080e7          	jalr	952(ra) # 80003a8e <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800056de:	fd040593          	addi	a1,s0,-48
    800056e2:	f5040513          	addi	a0,s0,-176
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	ab0080e7          	jalr	-1360(ra) # 80004196 <nameiparent>
    800056ee:	892a                	mv	s2,a0
    800056f0:	c935                	beqz	a0,80005764 <sys_link+0x10a>
  ilock(dp);
    800056f2:	ffffe097          	auipc	ra,0xffffe
    800056f6:	2da080e7          	jalr	730(ra) # 800039cc <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0)
    800056fa:	00092703          	lw	a4,0(s2)
    800056fe:	409c                	lw	a5,0(s1)
    80005700:	04f71d63          	bne	a4,a5,8000575a <sys_link+0x100>
    80005704:	40d0                	lw	a2,4(s1)
    80005706:	fd040593          	addi	a1,s0,-48
    8000570a:	854a                	mv	a0,s2
    8000570c:	fffff097          	auipc	ra,0xfffff
    80005710:	9ba080e7          	jalr	-1606(ra) # 800040c6 <dirlink>
    80005714:	04054363          	bltz	a0,8000575a <sys_link+0x100>
  iunlockput(dp);
    80005718:	854a                	mv	a0,s2
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	514080e7          	jalr	1300(ra) # 80003c2e <iunlockput>
  iput(ip);
    80005722:	8526                	mv	a0,s1
    80005724:	ffffe097          	auipc	ra,0xffffe
    80005728:	462080e7          	jalr	1122(ra) # 80003b86 <iput>
  end_op();
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	cea080e7          	jalr	-790(ra) # 80004416 <end_op>
  return 0;
    80005734:	4781                	li	a5,0
    80005736:	a085                	j	80005796 <sys_link+0x13c>
    end_op();
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	cde080e7          	jalr	-802(ra) # 80004416 <end_op>
    return -1;
    80005740:	57fd                	li	a5,-1
    80005742:	a891                	j	80005796 <sys_link+0x13c>
    iunlockput(ip);
    80005744:	8526                	mv	a0,s1
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	4e8080e7          	jalr	1256(ra) # 80003c2e <iunlockput>
    end_op();
    8000574e:	fffff097          	auipc	ra,0xfffff
    80005752:	cc8080e7          	jalr	-824(ra) # 80004416 <end_op>
    return -1;
    80005756:	57fd                	li	a5,-1
    80005758:	a83d                	j	80005796 <sys_link+0x13c>
    iunlockput(dp);
    8000575a:	854a                	mv	a0,s2
    8000575c:	ffffe097          	auipc	ra,0xffffe
    80005760:	4d2080e7          	jalr	1234(ra) # 80003c2e <iunlockput>
  ilock(ip);
    80005764:	8526                	mv	a0,s1
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	266080e7          	jalr	614(ra) # 800039cc <ilock>
  ip->nlink--;
    8000576e:	04a4d783          	lhu	a5,74(s1)
    80005772:	37fd                	addiw	a5,a5,-1
    80005774:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005778:	8526                	mv	a0,s1
    8000577a:	ffffe097          	auipc	ra,0xffffe
    8000577e:	186080e7          	jalr	390(ra) # 80003900 <iupdate>
  iunlockput(ip);
    80005782:	8526                	mv	a0,s1
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	4aa080e7          	jalr	1194(ra) # 80003c2e <iunlockput>
  end_op();
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	c8a080e7          	jalr	-886(ra) # 80004416 <end_op>
  return -1;
    80005794:	57fd                	li	a5,-1
}
    80005796:	853e                	mv	a0,a5
    80005798:	70b2                	ld	ra,296(sp)
    8000579a:	7412                	ld	s0,288(sp)
    8000579c:	64f2                	ld	s1,280(sp)
    8000579e:	6952                	ld	s2,272(sp)
    800057a0:	6155                	addi	sp,sp,304
    800057a2:	8082                	ret

00000000800057a4 <sys_unlink>:
{
    800057a4:	7151                	addi	sp,sp,-240
    800057a6:	f586                	sd	ra,232(sp)
    800057a8:	f1a2                	sd	s0,224(sp)
    800057aa:	eda6                	sd	s1,216(sp)
    800057ac:	e9ca                	sd	s2,208(sp)
    800057ae:	e5ce                	sd	s3,200(sp)
    800057b0:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800057b2:	08000613          	li	a2,128
    800057b6:	f3040593          	addi	a1,s0,-208
    800057ba:	4501                	li	a0,0
    800057bc:	ffffd097          	auipc	ra,0xffffd
    800057c0:	5ac080e7          	jalr	1452(ra) # 80002d68 <argstr>
    800057c4:	18054163          	bltz	a0,80005946 <sys_unlink+0x1a2>
  begin_op();
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	bd0080e7          	jalr	-1072(ra) # 80004398 <begin_op>
  if ((dp = nameiparent(path, name)) == 0)
    800057d0:	fb040593          	addi	a1,s0,-80
    800057d4:	f3040513          	addi	a0,s0,-208
    800057d8:	fffff097          	auipc	ra,0xfffff
    800057dc:	9be080e7          	jalr	-1602(ra) # 80004196 <nameiparent>
    800057e0:	84aa                	mv	s1,a0
    800057e2:	c979                	beqz	a0,800058b8 <sys_unlink+0x114>
  ilock(dp);
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	1e8080e7          	jalr	488(ra) # 800039cc <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057ec:	00003597          	auipc	a1,0x3
    800057f0:	f1c58593          	addi	a1,a1,-228 # 80008708 <syscalls+0x2b8>
    800057f4:	fb040513          	addi	a0,s0,-80
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	69e080e7          	jalr	1694(ra) # 80003e96 <namecmp>
    80005800:	14050a63          	beqz	a0,80005954 <sys_unlink+0x1b0>
    80005804:	00003597          	auipc	a1,0x3
    80005808:	f0c58593          	addi	a1,a1,-244 # 80008710 <syscalls+0x2c0>
    8000580c:	fb040513          	addi	a0,s0,-80
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	686080e7          	jalr	1670(ra) # 80003e96 <namecmp>
    80005818:	12050e63          	beqz	a0,80005954 <sys_unlink+0x1b0>
  if ((ip = dirlookup(dp, name, &off)) == 0)
    8000581c:	f2c40613          	addi	a2,s0,-212
    80005820:	fb040593          	addi	a1,s0,-80
    80005824:	8526                	mv	a0,s1
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	68a080e7          	jalr	1674(ra) # 80003eb0 <dirlookup>
    8000582e:	892a                	mv	s2,a0
    80005830:	12050263          	beqz	a0,80005954 <sys_unlink+0x1b0>
  ilock(ip);
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	198080e7          	jalr	408(ra) # 800039cc <ilock>
  if (ip->nlink < 1)
    8000583c:	04a91783          	lh	a5,74(s2)
    80005840:	08f05263          	blez	a5,800058c4 <sys_unlink+0x120>
  if (ip->type == T_DIR && !isdirempty(ip))
    80005844:	04491703          	lh	a4,68(s2)
    80005848:	4785                	li	a5,1
    8000584a:	08f70563          	beq	a4,a5,800058d4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000584e:	4641                	li	a2,16
    80005850:	4581                	li	a1,0
    80005852:	fc040513          	addi	a0,s0,-64
    80005856:	ffffb097          	auipc	ra,0xffffb
    8000585a:	47c080e7          	jalr	1148(ra) # 80000cd2 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000585e:	4741                	li	a4,16
    80005860:	f2c42683          	lw	a3,-212(s0)
    80005864:	fc040613          	addi	a2,s0,-64
    80005868:	4581                	li	a1,0
    8000586a:	8526                	mv	a0,s1
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	50c080e7          	jalr	1292(ra) # 80003d78 <writei>
    80005874:	47c1                	li	a5,16
    80005876:	0af51563          	bne	a0,a5,80005920 <sys_unlink+0x17c>
  if (ip->type == T_DIR)
    8000587a:	04491703          	lh	a4,68(s2)
    8000587e:	4785                	li	a5,1
    80005880:	0af70863          	beq	a4,a5,80005930 <sys_unlink+0x18c>
  iunlockput(dp);
    80005884:	8526                	mv	a0,s1
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	3a8080e7          	jalr	936(ra) # 80003c2e <iunlockput>
  ip->nlink--;
    8000588e:	04a95783          	lhu	a5,74(s2)
    80005892:	37fd                	addiw	a5,a5,-1
    80005894:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005898:	854a                	mv	a0,s2
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	066080e7          	jalr	102(ra) # 80003900 <iupdate>
  iunlockput(ip);
    800058a2:	854a                	mv	a0,s2
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	38a080e7          	jalr	906(ra) # 80003c2e <iunlockput>
  end_op();
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	b6a080e7          	jalr	-1174(ra) # 80004416 <end_op>
  return 0;
    800058b4:	4501                	li	a0,0
    800058b6:	a84d                	j	80005968 <sys_unlink+0x1c4>
    end_op();
    800058b8:	fffff097          	auipc	ra,0xfffff
    800058bc:	b5e080e7          	jalr	-1186(ra) # 80004416 <end_op>
    return -1;
    800058c0:	557d                	li	a0,-1
    800058c2:	a05d                	j	80005968 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800058c4:	00003517          	auipc	a0,0x3
    800058c8:	e5450513          	addi	a0,a0,-428 # 80008718 <syscalls+0x2c8>
    800058cc:	ffffb097          	auipc	ra,0xffffb
    800058d0:	c74080e7          	jalr	-908(ra) # 80000540 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    800058d4:	04c92703          	lw	a4,76(s2)
    800058d8:	02000793          	li	a5,32
    800058dc:	f6e7f9e3          	bgeu	a5,a4,8000584e <sys_unlink+0xaa>
    800058e0:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058e4:	4741                	li	a4,16
    800058e6:	86ce                	mv	a3,s3
    800058e8:	f1840613          	addi	a2,s0,-232
    800058ec:	4581                	li	a1,0
    800058ee:	854a                	mv	a0,s2
    800058f0:	ffffe097          	auipc	ra,0xffffe
    800058f4:	390080e7          	jalr	912(ra) # 80003c80 <readi>
    800058f8:	47c1                	li	a5,16
    800058fa:	00f51b63          	bne	a0,a5,80005910 <sys_unlink+0x16c>
    if (de.inum != 0)
    800058fe:	f1845783          	lhu	a5,-232(s0)
    80005902:	e7a1                	bnez	a5,8000594a <sys_unlink+0x1a6>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005904:	29c1                	addiw	s3,s3,16
    80005906:	04c92783          	lw	a5,76(s2)
    8000590a:	fcf9ede3          	bltu	s3,a5,800058e4 <sys_unlink+0x140>
    8000590e:	b781                	j	8000584e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005910:	00003517          	auipc	a0,0x3
    80005914:	e2050513          	addi	a0,a0,-480 # 80008730 <syscalls+0x2e0>
    80005918:	ffffb097          	auipc	ra,0xffffb
    8000591c:	c28080e7          	jalr	-984(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005920:	00003517          	auipc	a0,0x3
    80005924:	e2850513          	addi	a0,a0,-472 # 80008748 <syscalls+0x2f8>
    80005928:	ffffb097          	auipc	ra,0xffffb
    8000592c:	c18080e7          	jalr	-1000(ra) # 80000540 <panic>
    dp->nlink--;
    80005930:	04a4d783          	lhu	a5,74(s1)
    80005934:	37fd                	addiw	a5,a5,-1
    80005936:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000593a:	8526                	mv	a0,s1
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	fc4080e7          	jalr	-60(ra) # 80003900 <iupdate>
    80005944:	b781                	j	80005884 <sys_unlink+0xe0>
    return -1;
    80005946:	557d                	li	a0,-1
    80005948:	a005                	j	80005968 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000594a:	854a                	mv	a0,s2
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	2e2080e7          	jalr	738(ra) # 80003c2e <iunlockput>
  iunlockput(dp);
    80005954:	8526                	mv	a0,s1
    80005956:	ffffe097          	auipc	ra,0xffffe
    8000595a:	2d8080e7          	jalr	728(ra) # 80003c2e <iunlockput>
  end_op();
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	ab8080e7          	jalr	-1352(ra) # 80004416 <end_op>
  return -1;
    80005966:	557d                	li	a0,-1
}
    80005968:	70ae                	ld	ra,232(sp)
    8000596a:	740e                	ld	s0,224(sp)
    8000596c:	64ee                	ld	s1,216(sp)
    8000596e:	694e                	ld	s2,208(sp)
    80005970:	69ae                	ld	s3,200(sp)
    80005972:	616d                	addi	sp,sp,240
    80005974:	8082                	ret

0000000080005976 <sys_open>:

uint64
sys_open(void)
{
    80005976:	7131                	addi	sp,sp,-192
    80005978:	fd06                	sd	ra,184(sp)
    8000597a:	f922                	sd	s0,176(sp)
    8000597c:	f526                	sd	s1,168(sp)
    8000597e:	f14a                	sd	s2,160(sp)
    80005980:	ed4e                	sd	s3,152(sp)
    80005982:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005984:	f4c40593          	addi	a1,s0,-180
    80005988:	4505                	li	a0,1
    8000598a:	ffffd097          	auipc	ra,0xffffd
    8000598e:	39e080e7          	jalr	926(ra) # 80002d28 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005992:	08000613          	li	a2,128
    80005996:	f5040593          	addi	a1,s0,-176
    8000599a:	4501                	li	a0,0
    8000599c:	ffffd097          	auipc	ra,0xffffd
    800059a0:	3cc080e7          	jalr	972(ra) # 80002d68 <argstr>
    800059a4:	87aa                	mv	a5,a0
    return -1;
    800059a6:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800059a8:	0a07c963          	bltz	a5,80005a5a <sys_open+0xe4>

  begin_op();
    800059ac:	fffff097          	auipc	ra,0xfffff
    800059b0:	9ec080e7          	jalr	-1556(ra) # 80004398 <begin_op>

  if (omode & O_CREATE)
    800059b4:	f4c42783          	lw	a5,-180(s0)
    800059b8:	2007f793          	andi	a5,a5,512
    800059bc:	cfc5                	beqz	a5,80005a74 <sys_open+0xfe>
  {
    ip = create(path, T_FILE, 0, 0);
    800059be:	4681                	li	a3,0
    800059c0:	4601                	li	a2,0
    800059c2:	4589                	li	a1,2
    800059c4:	f5040513          	addi	a0,s0,-176
    800059c8:	00000097          	auipc	ra,0x0
    800059cc:	972080e7          	jalr	-1678(ra) # 8000533a <create>
    800059d0:	84aa                	mv	s1,a0
    if (ip == 0)
    800059d2:	c959                	beqz	a0,80005a68 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV))
    800059d4:	04449703          	lh	a4,68(s1)
    800059d8:	478d                	li	a5,3
    800059da:	00f71763          	bne	a4,a5,800059e8 <sys_open+0x72>
    800059de:	0464d703          	lhu	a4,70(s1)
    800059e2:	47a5                	li	a5,9
    800059e4:	0ce7ed63          	bltu	a5,a4,80005abe <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0)
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	dbc080e7          	jalr	-580(ra) # 800047a4 <filealloc>
    800059f0:	89aa                	mv	s3,a0
    800059f2:	10050363          	beqz	a0,80005af8 <sys_open+0x182>
    800059f6:	00000097          	auipc	ra,0x0
    800059fa:	902080e7          	jalr	-1790(ra) # 800052f8 <fdalloc>
    800059fe:	892a                	mv	s2,a0
    80005a00:	0e054763          	bltz	a0,80005aee <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE)
    80005a04:	04449703          	lh	a4,68(s1)
    80005a08:	478d                	li	a5,3
    80005a0a:	0cf70563          	beq	a4,a5,80005ad4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  }
  else
  {
    f->type = FD_INODE;
    80005a0e:	4789                	li	a5,2
    80005a10:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a14:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a18:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a1c:	f4c42783          	lw	a5,-180(s0)
    80005a20:	0017c713          	xori	a4,a5,1
    80005a24:	8b05                	andi	a4,a4,1
    80005a26:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a2a:	0037f713          	andi	a4,a5,3
    80005a2e:	00e03733          	snez	a4,a4
    80005a32:	00e984a3          	sb	a4,9(s3)

  if ((omode & O_TRUNC) && ip->type == T_FILE)
    80005a36:	4007f793          	andi	a5,a5,1024
    80005a3a:	c791                	beqz	a5,80005a46 <sys_open+0xd0>
    80005a3c:	04449703          	lh	a4,68(s1)
    80005a40:	4789                	li	a5,2
    80005a42:	0af70063          	beq	a4,a5,80005ae2 <sys_open+0x16c>
  {
    itrunc(ip);
  }

  iunlock(ip);
    80005a46:	8526                	mv	a0,s1
    80005a48:	ffffe097          	auipc	ra,0xffffe
    80005a4c:	046080e7          	jalr	70(ra) # 80003a8e <iunlock>
  end_op();
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	9c6080e7          	jalr	-1594(ra) # 80004416 <end_op>

  return fd;
    80005a58:	854a                	mv	a0,s2
}
    80005a5a:	70ea                	ld	ra,184(sp)
    80005a5c:	744a                	ld	s0,176(sp)
    80005a5e:	74aa                	ld	s1,168(sp)
    80005a60:	790a                	ld	s2,160(sp)
    80005a62:	69ea                	ld	s3,152(sp)
    80005a64:	6129                	addi	sp,sp,192
    80005a66:	8082                	ret
      end_op();
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	9ae080e7          	jalr	-1618(ra) # 80004416 <end_op>
      return -1;
    80005a70:	557d                	li	a0,-1
    80005a72:	b7e5                	j	80005a5a <sys_open+0xe4>
    if ((ip = namei(path)) == 0)
    80005a74:	f5040513          	addi	a0,s0,-176
    80005a78:	ffffe097          	auipc	ra,0xffffe
    80005a7c:	700080e7          	jalr	1792(ra) # 80004178 <namei>
    80005a80:	84aa                	mv	s1,a0
    80005a82:	c905                	beqz	a0,80005ab2 <sys_open+0x13c>
    ilock(ip);
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	f48080e7          	jalr	-184(ra) # 800039cc <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY)
    80005a8c:	04449703          	lh	a4,68(s1)
    80005a90:	4785                	li	a5,1
    80005a92:	f4f711e3          	bne	a4,a5,800059d4 <sys_open+0x5e>
    80005a96:	f4c42783          	lw	a5,-180(s0)
    80005a9a:	d7b9                	beqz	a5,800059e8 <sys_open+0x72>
      iunlockput(ip);
    80005a9c:	8526                	mv	a0,s1
    80005a9e:	ffffe097          	auipc	ra,0xffffe
    80005aa2:	190080e7          	jalr	400(ra) # 80003c2e <iunlockput>
      end_op();
    80005aa6:	fffff097          	auipc	ra,0xfffff
    80005aaa:	970080e7          	jalr	-1680(ra) # 80004416 <end_op>
      return -1;
    80005aae:	557d                	li	a0,-1
    80005ab0:	b76d                	j	80005a5a <sys_open+0xe4>
      end_op();
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	964080e7          	jalr	-1692(ra) # 80004416 <end_op>
      return -1;
    80005aba:	557d                	li	a0,-1
    80005abc:	bf79                	j	80005a5a <sys_open+0xe4>
    iunlockput(ip);
    80005abe:	8526                	mv	a0,s1
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	16e080e7          	jalr	366(ra) # 80003c2e <iunlockput>
    end_op();
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	94e080e7          	jalr	-1714(ra) # 80004416 <end_op>
    return -1;
    80005ad0:	557d                	li	a0,-1
    80005ad2:	b761                	j	80005a5a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ad4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ad8:	04649783          	lh	a5,70(s1)
    80005adc:	02f99223          	sh	a5,36(s3)
    80005ae0:	bf25                	j	80005a18 <sys_open+0xa2>
    itrunc(ip);
    80005ae2:	8526                	mv	a0,s1
    80005ae4:	ffffe097          	auipc	ra,0xffffe
    80005ae8:	ff6080e7          	jalr	-10(ra) # 80003ada <itrunc>
    80005aec:	bfa9                	j	80005a46 <sys_open+0xd0>
      fileclose(f);
    80005aee:	854e                	mv	a0,s3
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	d70080e7          	jalr	-656(ra) # 80004860 <fileclose>
    iunlockput(ip);
    80005af8:	8526                	mv	a0,s1
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	134080e7          	jalr	308(ra) # 80003c2e <iunlockput>
    end_op();
    80005b02:	fffff097          	auipc	ra,0xfffff
    80005b06:	914080e7          	jalr	-1772(ra) # 80004416 <end_op>
    return -1;
    80005b0a:	557d                	li	a0,-1
    80005b0c:	b7b9                	j	80005a5a <sys_open+0xe4>

0000000080005b0e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b0e:	7175                	addi	sp,sp,-144
    80005b10:	e506                	sd	ra,136(sp)
    80005b12:	e122                	sd	s0,128(sp)
    80005b14:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	882080e7          	jalr	-1918(ra) # 80004398 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
    80005b1e:	08000613          	li	a2,128
    80005b22:	f7040593          	addi	a1,s0,-144
    80005b26:	4501                	li	a0,0
    80005b28:	ffffd097          	auipc	ra,0xffffd
    80005b2c:	240080e7          	jalr	576(ra) # 80002d68 <argstr>
    80005b30:	02054963          	bltz	a0,80005b62 <sys_mkdir+0x54>
    80005b34:	4681                	li	a3,0
    80005b36:	4601                	li	a2,0
    80005b38:	4585                	li	a1,1
    80005b3a:	f7040513          	addi	a0,s0,-144
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	7fc080e7          	jalr	2044(ra) # 8000533a <create>
    80005b46:	cd11                	beqz	a0,80005b62 <sys_mkdir+0x54>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	0e6080e7          	jalr	230(ra) # 80003c2e <iunlockput>
  end_op();
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	8c6080e7          	jalr	-1850(ra) # 80004416 <end_op>
  return 0;
    80005b58:	4501                	li	a0,0
}
    80005b5a:	60aa                	ld	ra,136(sp)
    80005b5c:	640a                	ld	s0,128(sp)
    80005b5e:	6149                	addi	sp,sp,144
    80005b60:	8082                	ret
    end_op();
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	8b4080e7          	jalr	-1868(ra) # 80004416 <end_op>
    return -1;
    80005b6a:	557d                	li	a0,-1
    80005b6c:	b7fd                	j	80005b5a <sys_mkdir+0x4c>

0000000080005b6e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b6e:	7135                	addi	sp,sp,-160
    80005b70:	ed06                	sd	ra,152(sp)
    80005b72:	e922                	sd	s0,144(sp)
    80005b74:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b76:	fffff097          	auipc	ra,0xfffff
    80005b7a:	822080e7          	jalr	-2014(ra) # 80004398 <begin_op>
  argint(1, &major);
    80005b7e:	f6c40593          	addi	a1,s0,-148
    80005b82:	4505                	li	a0,1
    80005b84:	ffffd097          	auipc	ra,0xffffd
    80005b88:	1a4080e7          	jalr	420(ra) # 80002d28 <argint>
  argint(2, &minor);
    80005b8c:	f6840593          	addi	a1,s0,-152
    80005b90:	4509                	li	a0,2
    80005b92:	ffffd097          	auipc	ra,0xffffd
    80005b96:	196080e7          	jalr	406(ra) # 80002d28 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005b9a:	08000613          	li	a2,128
    80005b9e:	f7040593          	addi	a1,s0,-144
    80005ba2:	4501                	li	a0,0
    80005ba4:	ffffd097          	auipc	ra,0xffffd
    80005ba8:	1c4080e7          	jalr	452(ra) # 80002d68 <argstr>
    80005bac:	02054b63          	bltz	a0,80005be2 <sys_mknod+0x74>
      (ip = create(path, T_DEVICE, major, minor)) == 0)
    80005bb0:	f6841683          	lh	a3,-152(s0)
    80005bb4:	f6c41603          	lh	a2,-148(s0)
    80005bb8:	458d                	li	a1,3
    80005bba:	f7040513          	addi	a0,s0,-144
    80005bbe:	fffff097          	auipc	ra,0xfffff
    80005bc2:	77c080e7          	jalr	1916(ra) # 8000533a <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005bc6:	cd11                	beqz	a0,80005be2 <sys_mknod+0x74>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bc8:	ffffe097          	auipc	ra,0xffffe
    80005bcc:	066080e7          	jalr	102(ra) # 80003c2e <iunlockput>
  end_op();
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	846080e7          	jalr	-1978(ra) # 80004416 <end_op>
  return 0;
    80005bd8:	4501                	li	a0,0
}
    80005bda:	60ea                	ld	ra,152(sp)
    80005bdc:	644a                	ld	s0,144(sp)
    80005bde:	610d                	addi	sp,sp,160
    80005be0:	8082                	ret
    end_op();
    80005be2:	fffff097          	auipc	ra,0xfffff
    80005be6:	834080e7          	jalr	-1996(ra) # 80004416 <end_op>
    return -1;
    80005bea:	557d                	li	a0,-1
    80005bec:	b7fd                	j	80005bda <sys_mknod+0x6c>

0000000080005bee <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bee:	7135                	addi	sp,sp,-160
    80005bf0:	ed06                	sd	ra,152(sp)
    80005bf2:	e922                	sd	s0,144(sp)
    80005bf4:	e526                	sd	s1,136(sp)
    80005bf6:	e14a                	sd	s2,128(sp)
    80005bf8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bfa:	ffffc097          	auipc	ra,0xffffc
    80005bfe:	db2080e7          	jalr	-590(ra) # 800019ac <myproc>
    80005c02:	892a                	mv	s2,a0

  begin_op();
    80005c04:	ffffe097          	auipc	ra,0xffffe
    80005c08:	794080e7          	jalr	1940(ra) # 80004398 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0)
    80005c0c:	08000613          	li	a2,128
    80005c10:	f6040593          	addi	a1,s0,-160
    80005c14:	4501                	li	a0,0
    80005c16:	ffffd097          	auipc	ra,0xffffd
    80005c1a:	152080e7          	jalr	338(ra) # 80002d68 <argstr>
    80005c1e:	04054b63          	bltz	a0,80005c74 <sys_chdir+0x86>
    80005c22:	f6040513          	addi	a0,s0,-160
    80005c26:	ffffe097          	auipc	ra,0xffffe
    80005c2a:	552080e7          	jalr	1362(ra) # 80004178 <namei>
    80005c2e:	84aa                	mv	s1,a0
    80005c30:	c131                	beqz	a0,80005c74 <sys_chdir+0x86>
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005c32:	ffffe097          	auipc	ra,0xffffe
    80005c36:	d9a080e7          	jalr	-614(ra) # 800039cc <ilock>
  if (ip->type != T_DIR)
    80005c3a:	04449703          	lh	a4,68(s1)
    80005c3e:	4785                	li	a5,1
    80005c40:	04f71063          	bne	a4,a5,80005c80 <sys_chdir+0x92>
  {
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	e48080e7          	jalr	-440(ra) # 80003a8e <iunlock>
  iput(p->cwd);
    80005c4e:	15093503          	ld	a0,336(s2)
    80005c52:	ffffe097          	auipc	ra,0xffffe
    80005c56:	f34080e7          	jalr	-204(ra) # 80003b86 <iput>
  end_op();
    80005c5a:	ffffe097          	auipc	ra,0xffffe
    80005c5e:	7bc080e7          	jalr	1980(ra) # 80004416 <end_op>
  p->cwd = ip;
    80005c62:	14993823          	sd	s1,336(s2)
  return 0;
    80005c66:	4501                	li	a0,0
}
    80005c68:	60ea                	ld	ra,152(sp)
    80005c6a:	644a                	ld	s0,144(sp)
    80005c6c:	64aa                	ld	s1,136(sp)
    80005c6e:	690a                	ld	s2,128(sp)
    80005c70:	610d                	addi	sp,sp,160
    80005c72:	8082                	ret
    end_op();
    80005c74:	ffffe097          	auipc	ra,0xffffe
    80005c78:	7a2080e7          	jalr	1954(ra) # 80004416 <end_op>
    return -1;
    80005c7c:	557d                	li	a0,-1
    80005c7e:	b7ed                	j	80005c68 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c80:	8526                	mv	a0,s1
    80005c82:	ffffe097          	auipc	ra,0xffffe
    80005c86:	fac080e7          	jalr	-84(ra) # 80003c2e <iunlockput>
    end_op();
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	78c080e7          	jalr	1932(ra) # 80004416 <end_op>
    return -1;
    80005c92:	557d                	li	a0,-1
    80005c94:	bfd1                	j	80005c68 <sys_chdir+0x7a>

0000000080005c96 <sys_exec>:

uint64
sys_exec(void)
{
    80005c96:	7145                	addi	sp,sp,-464
    80005c98:	e786                	sd	ra,456(sp)
    80005c9a:	e3a2                	sd	s0,448(sp)
    80005c9c:	ff26                	sd	s1,440(sp)
    80005c9e:	fb4a                	sd	s2,432(sp)
    80005ca0:	f74e                	sd	s3,424(sp)
    80005ca2:	f352                	sd	s4,416(sp)
    80005ca4:	ef56                	sd	s5,408(sp)
    80005ca6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ca8:	e3840593          	addi	a1,s0,-456
    80005cac:	4505                	li	a0,1
    80005cae:	ffffd097          	auipc	ra,0xffffd
    80005cb2:	09a080e7          	jalr	154(ra) # 80002d48 <argaddr>
  if (argstr(0, path, MAXPATH) < 0)
    80005cb6:	08000613          	li	a2,128
    80005cba:	f4040593          	addi	a1,s0,-192
    80005cbe:	4501                	li	a0,0
    80005cc0:	ffffd097          	auipc	ra,0xffffd
    80005cc4:	0a8080e7          	jalr	168(ra) # 80002d68 <argstr>
    80005cc8:	87aa                	mv	a5,a0
  {
    return -1;
    80005cca:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0)
    80005ccc:	0c07c363          	bltz	a5,80005d92 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005cd0:	10000613          	li	a2,256
    80005cd4:	4581                	li	a1,0
    80005cd6:	e4040513          	addi	a0,s0,-448
    80005cda:	ffffb097          	auipc	ra,0xffffb
    80005cde:	ff8080e7          	jalr	-8(ra) # 80000cd2 <memset>
  for (i = 0;; i++)
  {
    if (i >= NELEM(argv))
    80005ce2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ce6:	89a6                	mv	s3,s1
    80005ce8:	4901                	li	s2,0
    if (i >= NELEM(argv))
    80005cea:	02000a13          	li	s4,32
    80005cee:	00090a9b          	sext.w	s5,s2
    {
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0)
    80005cf2:	00391513          	slli	a0,s2,0x3
    80005cf6:	e3040593          	addi	a1,s0,-464
    80005cfa:	e3843783          	ld	a5,-456(s0)
    80005cfe:	953e                	add	a0,a0,a5
    80005d00:	ffffd097          	auipc	ra,0xffffd
    80005d04:	f8a080e7          	jalr	-118(ra) # 80002c8a <fetchaddr>
    80005d08:	02054a63          	bltz	a0,80005d3c <sys_exec+0xa6>
    {
      goto bad;
    }
    if (uarg == 0)
    80005d0c:	e3043783          	ld	a5,-464(s0)
    80005d10:	c3b9                	beqz	a5,80005d56 <sys_exec+0xc0>
    {
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d12:	ffffb097          	auipc	ra,0xffffb
    80005d16:	dd4080e7          	jalr	-556(ra) # 80000ae6 <kalloc>
    80005d1a:	85aa                	mv	a1,a0
    80005d1c:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005d20:	cd11                	beqz	a0,80005d3c <sys_exec+0xa6>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d22:	6605                	lui	a2,0x1
    80005d24:	e3043503          	ld	a0,-464(s0)
    80005d28:	ffffd097          	auipc	ra,0xffffd
    80005d2c:	fb4080e7          	jalr	-76(ra) # 80002cdc <fetchstr>
    80005d30:	00054663          	bltz	a0,80005d3c <sys_exec+0xa6>
    if (i >= NELEM(argv))
    80005d34:	0905                	addi	s2,s2,1
    80005d36:	09a1                	addi	s3,s3,8
    80005d38:	fb491be3          	bne	s2,s4,80005cee <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d3c:	f4040913          	addi	s2,s0,-192
    80005d40:	6088                	ld	a0,0(s1)
    80005d42:	c539                	beqz	a0,80005d90 <sys_exec+0xfa>
    kfree(argv[i]);
    80005d44:	ffffb097          	auipc	ra,0xffffb
    80005d48:	ca4080e7          	jalr	-860(ra) # 800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d4c:	04a1                	addi	s1,s1,8
    80005d4e:	ff2499e3          	bne	s1,s2,80005d40 <sys_exec+0xaa>
  return -1;
    80005d52:	557d                	li	a0,-1
    80005d54:	a83d                	j	80005d92 <sys_exec+0xfc>
      argv[i] = 0;
    80005d56:	0a8e                	slli	s5,s5,0x3
    80005d58:	fc0a8793          	addi	a5,s5,-64
    80005d5c:	00878ab3          	add	s5,a5,s0
    80005d60:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d64:	e4040593          	addi	a1,s0,-448
    80005d68:	f4040513          	addi	a0,s0,-192
    80005d6c:	fffff097          	auipc	ra,0xfffff
    80005d70:	16e080e7          	jalr	366(ra) # 80004eda <exec>
    80005d74:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d76:	f4040993          	addi	s3,s0,-192
    80005d7a:	6088                	ld	a0,0(s1)
    80005d7c:	c901                	beqz	a0,80005d8c <sys_exec+0xf6>
    kfree(argv[i]);
    80005d7e:	ffffb097          	auipc	ra,0xffffb
    80005d82:	c6a080e7          	jalr	-918(ra) # 800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d86:	04a1                	addi	s1,s1,8
    80005d88:	ff3499e3          	bne	s1,s3,80005d7a <sys_exec+0xe4>
  return ret;
    80005d8c:	854a                	mv	a0,s2
    80005d8e:	a011                	j	80005d92 <sys_exec+0xfc>
  return -1;
    80005d90:	557d                	li	a0,-1
}
    80005d92:	60be                	ld	ra,456(sp)
    80005d94:	641e                	ld	s0,448(sp)
    80005d96:	74fa                	ld	s1,440(sp)
    80005d98:	795a                	ld	s2,432(sp)
    80005d9a:	79ba                	ld	s3,424(sp)
    80005d9c:	7a1a                	ld	s4,416(sp)
    80005d9e:	6afa                	ld	s5,408(sp)
    80005da0:	6179                	addi	sp,sp,464
    80005da2:	8082                	ret

0000000080005da4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005da4:	7139                	addi	sp,sp,-64
    80005da6:	fc06                	sd	ra,56(sp)
    80005da8:	f822                	sd	s0,48(sp)
    80005daa:	f426                	sd	s1,40(sp)
    80005dac:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dae:	ffffc097          	auipc	ra,0xffffc
    80005db2:	bfe080e7          	jalr	-1026(ra) # 800019ac <myproc>
    80005db6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005db8:	fd840593          	addi	a1,s0,-40
    80005dbc:	4501                	li	a0,0
    80005dbe:	ffffd097          	auipc	ra,0xffffd
    80005dc2:	f8a080e7          	jalr	-118(ra) # 80002d48 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005dc6:	fc840593          	addi	a1,s0,-56
    80005dca:	fd040513          	addi	a0,s0,-48
    80005dce:	fffff097          	auipc	ra,0xfffff
    80005dd2:	dc2080e7          	jalr	-574(ra) # 80004b90 <pipealloc>
    return -1;
    80005dd6:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005dd8:	0c054463          	bltz	a0,80005ea0 <sys_pipe+0xfc>
  fd0 = -1;
    80005ddc:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0)
    80005de0:	fd043503          	ld	a0,-48(s0)
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	514080e7          	jalr	1300(ra) # 800052f8 <fdalloc>
    80005dec:	fca42223          	sw	a0,-60(s0)
    80005df0:	08054b63          	bltz	a0,80005e86 <sys_pipe+0xe2>
    80005df4:	fc843503          	ld	a0,-56(s0)
    80005df8:	fffff097          	auipc	ra,0xfffff
    80005dfc:	500080e7          	jalr	1280(ra) # 800052f8 <fdalloc>
    80005e00:	fca42023          	sw	a0,-64(s0)
    80005e04:	06054863          	bltz	a0,80005e74 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005e08:	4691                	li	a3,4
    80005e0a:	fc440613          	addi	a2,s0,-60
    80005e0e:	fd843583          	ld	a1,-40(s0)
    80005e12:	68a8                	ld	a0,80(s1)
    80005e14:	ffffc097          	auipc	ra,0xffffc
    80005e18:	858080e7          	jalr	-1960(ra) # 8000166c <copyout>
    80005e1c:	02054063          	bltz	a0,80005e3c <sys_pipe+0x98>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0)
    80005e20:	4691                	li	a3,4
    80005e22:	fc040613          	addi	a2,s0,-64
    80005e26:	fd843583          	ld	a1,-40(s0)
    80005e2a:	0591                	addi	a1,a1,4
    80005e2c:	68a8                	ld	a0,80(s1)
    80005e2e:	ffffc097          	auipc	ra,0xffffc
    80005e32:	83e080e7          	jalr	-1986(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e36:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005e38:	06055463          	bgez	a0,80005ea0 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005e3c:	fc442783          	lw	a5,-60(s0)
    80005e40:	07e9                	addi	a5,a5,26
    80005e42:	078e                	slli	a5,a5,0x3
    80005e44:	97a6                	add	a5,a5,s1
    80005e46:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e4a:	fc042783          	lw	a5,-64(s0)
    80005e4e:	07e9                	addi	a5,a5,26
    80005e50:	078e                	slli	a5,a5,0x3
    80005e52:	94be                	add	s1,s1,a5
    80005e54:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e58:	fd043503          	ld	a0,-48(s0)
    80005e5c:	fffff097          	auipc	ra,0xfffff
    80005e60:	a04080e7          	jalr	-1532(ra) # 80004860 <fileclose>
    fileclose(wf);
    80005e64:	fc843503          	ld	a0,-56(s0)
    80005e68:	fffff097          	auipc	ra,0xfffff
    80005e6c:	9f8080e7          	jalr	-1544(ra) # 80004860 <fileclose>
    return -1;
    80005e70:	57fd                	li	a5,-1
    80005e72:	a03d                	j	80005ea0 <sys_pipe+0xfc>
    if (fd0 >= 0)
    80005e74:	fc442783          	lw	a5,-60(s0)
    80005e78:	0007c763          	bltz	a5,80005e86 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005e7c:	07e9                	addi	a5,a5,26
    80005e7e:	078e                	slli	a5,a5,0x3
    80005e80:	97a6                	add	a5,a5,s1
    80005e82:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e86:	fd043503          	ld	a0,-48(s0)
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	9d6080e7          	jalr	-1578(ra) # 80004860 <fileclose>
    fileclose(wf);
    80005e92:	fc843503          	ld	a0,-56(s0)
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	9ca080e7          	jalr	-1590(ra) # 80004860 <fileclose>
    return -1;
    80005e9e:	57fd                	li	a5,-1
}
    80005ea0:	853e                	mv	a0,a5
    80005ea2:	70e2                	ld	ra,56(sp)
    80005ea4:	7442                	ld	s0,48(sp)
    80005ea6:	74a2                	ld	s1,40(sp)
    80005ea8:	6121                	addi	sp,sp,64
    80005eaa:	8082                	ret
    80005eac:	0000                	unimp
	...

0000000080005eb0 <kernelvec>:
    80005eb0:	7111                	addi	sp,sp,-256
    80005eb2:	e006                	sd	ra,0(sp)
    80005eb4:	e40a                	sd	sp,8(sp)
    80005eb6:	e80e                	sd	gp,16(sp)
    80005eb8:	ec12                	sd	tp,24(sp)
    80005eba:	f016                	sd	t0,32(sp)
    80005ebc:	f41a                	sd	t1,40(sp)
    80005ebe:	f81e                	sd	t2,48(sp)
    80005ec0:	fc22                	sd	s0,56(sp)
    80005ec2:	e0a6                	sd	s1,64(sp)
    80005ec4:	e4aa                	sd	a0,72(sp)
    80005ec6:	e8ae                	sd	a1,80(sp)
    80005ec8:	ecb2                	sd	a2,88(sp)
    80005eca:	f0b6                	sd	a3,96(sp)
    80005ecc:	f4ba                	sd	a4,104(sp)
    80005ece:	f8be                	sd	a5,112(sp)
    80005ed0:	fcc2                	sd	a6,120(sp)
    80005ed2:	e146                	sd	a7,128(sp)
    80005ed4:	e54a                	sd	s2,136(sp)
    80005ed6:	e94e                	sd	s3,144(sp)
    80005ed8:	ed52                	sd	s4,152(sp)
    80005eda:	f156                	sd	s5,160(sp)
    80005edc:	f55a                	sd	s6,168(sp)
    80005ede:	f95e                	sd	s7,176(sp)
    80005ee0:	fd62                	sd	s8,184(sp)
    80005ee2:	e1e6                	sd	s9,192(sp)
    80005ee4:	e5ea                	sd	s10,200(sp)
    80005ee6:	e9ee                	sd	s11,208(sp)
    80005ee8:	edf2                	sd	t3,216(sp)
    80005eea:	f1f6                	sd	t4,224(sp)
    80005eec:	f5fa                	sd	t5,232(sp)
    80005eee:	f9fe                	sd	t6,240(sp)
    80005ef0:	c67fc0ef          	jal	ra,80002b56 <kerneltrap>
    80005ef4:	6082                	ld	ra,0(sp)
    80005ef6:	6122                	ld	sp,8(sp)
    80005ef8:	61c2                	ld	gp,16(sp)
    80005efa:	7282                	ld	t0,32(sp)
    80005efc:	7322                	ld	t1,40(sp)
    80005efe:	73c2                	ld	t2,48(sp)
    80005f00:	7462                	ld	s0,56(sp)
    80005f02:	6486                	ld	s1,64(sp)
    80005f04:	6526                	ld	a0,72(sp)
    80005f06:	65c6                	ld	a1,80(sp)
    80005f08:	6666                	ld	a2,88(sp)
    80005f0a:	7686                	ld	a3,96(sp)
    80005f0c:	7726                	ld	a4,104(sp)
    80005f0e:	77c6                	ld	a5,112(sp)
    80005f10:	7866                	ld	a6,120(sp)
    80005f12:	688a                	ld	a7,128(sp)
    80005f14:	692a                	ld	s2,136(sp)
    80005f16:	69ca                	ld	s3,144(sp)
    80005f18:	6a6a                	ld	s4,152(sp)
    80005f1a:	7a8a                	ld	s5,160(sp)
    80005f1c:	7b2a                	ld	s6,168(sp)
    80005f1e:	7bca                	ld	s7,176(sp)
    80005f20:	7c6a                	ld	s8,184(sp)
    80005f22:	6c8e                	ld	s9,192(sp)
    80005f24:	6d2e                	ld	s10,200(sp)
    80005f26:	6dce                	ld	s11,208(sp)
    80005f28:	6e6e                	ld	t3,216(sp)
    80005f2a:	7e8e                	ld	t4,224(sp)
    80005f2c:	7f2e                	ld	t5,232(sp)
    80005f2e:	7fce                	ld	t6,240(sp)
    80005f30:	6111                	addi	sp,sp,256
    80005f32:	10200073          	sret
    80005f36:	00000013          	nop
    80005f3a:	00000013          	nop
    80005f3e:	0001                	nop

0000000080005f40 <timervec>:
    80005f40:	34051573          	csrrw	a0,mscratch,a0
    80005f44:	e10c                	sd	a1,0(a0)
    80005f46:	e510                	sd	a2,8(a0)
    80005f48:	e914                	sd	a3,16(a0)
    80005f4a:	6d0c                	ld	a1,24(a0)
    80005f4c:	7110                	ld	a2,32(a0)
    80005f4e:	6194                	ld	a3,0(a1)
    80005f50:	96b2                	add	a3,a3,a2
    80005f52:	e194                	sd	a3,0(a1)
    80005f54:	4589                	li	a1,2
    80005f56:	14459073          	csrw	sip,a1
    80005f5a:	6914                	ld	a3,16(a0)
    80005f5c:	6510                	ld	a2,8(a0)
    80005f5e:	610c                	ld	a1,0(a0)
    80005f60:	34051573          	csrrw	a0,mscratch,a0
    80005f64:	30200073          	mret
	...

0000000080005f6a <plicinit>:
//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void)
{
    80005f6a:	1141                	addi	sp,sp,-16
    80005f6c:	e422                	sd	s0,8(sp)
    80005f6e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005f70:	0c0007b7          	lui	a5,0xc000
    80005f74:	4705                	li	a4,1
    80005f76:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80005f78:	c3d8                	sw	a4,4(a5)
}
    80005f7a:	6422                	ld	s0,8(sp)
    80005f7c:	0141                	addi	sp,sp,16
    80005f7e:	8082                	ret

0000000080005f80 <plicinithart>:

void plicinithart(void)
{
    80005f80:	1141                	addi	sp,sp,-16
    80005f82:	e406                	sd	ra,8(sp)
    80005f84:	e022                	sd	s0,0(sp)
    80005f86:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f88:	ffffc097          	auipc	ra,0xffffc
    80005f8c:	9f8080e7          	jalr	-1544(ra) # 80001980 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f90:	0085171b          	slliw	a4,a0,0x8
    80005f94:	0c0027b7          	lui	a5,0xc002
    80005f98:	97ba                	add	a5,a5,a4
    80005f9a:	40200713          	li	a4,1026
    80005f9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005fa2:	00d5151b          	slliw	a0,a0,0xd
    80005fa6:	0c2017b7          	lui	a5,0xc201
    80005faa:	97aa                	add	a5,a5,a0
    80005fac:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005fb0:	60a2                	ld	ra,8(sp)
    80005fb2:	6402                	ld	s0,0(sp)
    80005fb4:	0141                	addi	sp,sp,16
    80005fb6:	8082                	ret

0000000080005fb8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void)
{
    80005fb8:	1141                	addi	sp,sp,-16
    80005fba:	e406                	sd	ra,8(sp)
    80005fbc:	e022                	sd	s0,0(sp)
    80005fbe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fc0:	ffffc097          	auipc	ra,0xffffc
    80005fc4:	9c0080e7          	jalr	-1600(ra) # 80001980 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005fc8:	00d5151b          	slliw	a0,a0,0xd
    80005fcc:	0c2017b7          	lui	a5,0xc201
    80005fd0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005fd2:	43c8                	lw	a0,4(a5)
    80005fd4:	60a2                	ld	ra,8(sp)
    80005fd6:	6402                	ld	s0,0(sp)
    80005fd8:	0141                	addi	sp,sp,16
    80005fda:	8082                	ret

0000000080005fdc <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq)
{
    80005fdc:	1101                	addi	sp,sp,-32
    80005fde:	ec06                	sd	ra,24(sp)
    80005fe0:	e822                	sd	s0,16(sp)
    80005fe2:	e426                	sd	s1,8(sp)
    80005fe4:	1000                	addi	s0,sp,32
    80005fe6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fe8:	ffffc097          	auipc	ra,0xffffc
    80005fec:	998080e7          	jalr	-1640(ra) # 80001980 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80005ff0:	00d5151b          	slliw	a0,a0,0xd
    80005ff4:	0c2017b7          	lui	a5,0xc201
    80005ff8:	97aa                	add	a5,a5,a0
    80005ffa:	c3c4                	sw	s1,4(a5)
}
    80005ffc:	60e2                	ld	ra,24(sp)
    80005ffe:	6442                	ld	s0,16(sp)
    80006000:	64a2                	ld	s1,8(sp)
    80006002:	6105                	addi	sp,sp,32
    80006004:	8082                	ret

0000000080006006 <popfront>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void popfront(deque *a)
{
    80006006:	1141                	addi	sp,sp,-16
    80006008:	e422                	sd	s0,8(sp)
    8000600a:	0800                	addi	s0,sp,16
    for (int i = 0; i < a->end - 1; i++)
    8000600c:	20052683          	lw	a3,512(a0)
    80006010:	fff6861b          	addiw	a2,a3,-1
    80006014:	0006079b          	sext.w	a5,a2
    80006018:	cf99                	beqz	a5,80006036 <popfront+0x30>
    8000601a:	87aa                	mv	a5,a0
    8000601c:	36f9                	addiw	a3,a3,-2
    8000601e:	02069713          	slli	a4,a3,0x20
    80006022:	01d75693          	srli	a3,a4,0x1d
    80006026:	00850713          	addi	a4,a0,8
    8000602a:	96ba                	add	a3,a3,a4
    {
        a->n[i] = a->n[i + 1];
    8000602c:	6798                	ld	a4,8(a5)
    8000602e:	e398                	sd	a4,0(a5)
    for (int i = 0; i < a->end - 1; i++)
    80006030:	07a1                	addi	a5,a5,8 # c201008 <_entry-0x73dfeff8>
    80006032:	fed79de3          	bne	a5,a3,8000602c <popfront+0x26>
    }
    a->end--;
    80006036:	20c52023          	sw	a2,512(a0)
    return;
}
    8000603a:	6422                	ld	s0,8(sp)
    8000603c:	0141                	addi	sp,sp,16
    8000603e:	8082                	ret

0000000080006040 <pushback>:
void pushback(deque *a, struct proc *x)
{
    if (a->end == NPROC)
    80006040:	20052783          	lw	a5,512(a0)
    80006044:	04000713          	li	a4,64
    80006048:	00e78c63          	beq	a5,a4,80006060 <pushback+0x20>
    {
        panic("Error!");
        return;
    }
    a->n[a->end] = x;
    8000604c:	02079693          	slli	a3,a5,0x20
    80006050:	01d6d713          	srli	a4,a3,0x1d
    80006054:	972a                	add	a4,a4,a0
    80006056:	e30c                	sd	a1,0(a4)
    a->end++;
    80006058:	2785                	addiw	a5,a5,1
    8000605a:	20f52023          	sw	a5,512(a0)
    8000605e:	8082                	ret
{
    80006060:	1141                	addi	sp,sp,-16
    80006062:	e406                	sd	ra,8(sp)
    80006064:	e022                	sd	s0,0(sp)
    80006066:	0800                	addi	s0,sp,16
        panic("Error!");
    80006068:	00002517          	auipc	a0,0x2
    8000606c:	6f050513          	addi	a0,a0,1776 # 80008758 <syscalls+0x308>
    80006070:	ffffa097          	auipc	ra,0xffffa
    80006074:	4d0080e7          	jalr	1232(ra) # 80000540 <panic>

0000000080006078 <front>:
    return;
}
struct proc *front(deque *a)
{
    80006078:	1141                	addi	sp,sp,-16
    8000607a:	e422                	sd	s0,8(sp)
    8000607c:	0800                	addi	s0,sp,16
    if (a->end == 0)
    8000607e:	20052783          	lw	a5,512(a0)
    80006082:	c789                	beqz	a5,8000608c <front+0x14>
    {
        return 0;
    }
    return a->n[0];
    80006084:	6108                	ld	a0,0(a0)
}
    80006086:	6422                	ld	s0,8(sp)
    80006088:	0141                	addi	sp,sp,16
    8000608a:	8082                	ret
        return 0;
    8000608c:	4501                	li	a0,0
    8000608e:	bfe5                	j	80006086 <front+0xe>

0000000080006090 <size>:
int size(deque *a)
{
    80006090:	1141                	addi	sp,sp,-16
    80006092:	e422                	sd	s0,8(sp)
    80006094:	0800                	addi	s0,sp,16
    return a->end;
}
    80006096:	20052503          	lw	a0,512(a0)
    8000609a:	6422                	ld	s0,8(sp)
    8000609c:	0141                	addi	sp,sp,16
    8000609e:	8082                	ret

00000000800060a0 <delete>:
void delete (deque *a, uint pid)
{
    800060a0:	1141                	addi	sp,sp,-16
    800060a2:	e422                	sd	s0,8(sp)
    800060a4:	0800                	addi	s0,sp,16
    int flag = 0;
    for (int i = 0; i < a->end; i++)
    800060a6:	20052e03          	lw	t3,512(a0)
    800060aa:	020e0c63          	beqz	t3,800060e2 <delete+0x42>
    800060ae:	87aa                	mv	a5,a0
    800060b0:	000e031b          	sext.w	t1,t3
    800060b4:	4701                	li	a4,0
    int flag = 0;
    800060b6:	4881                	li	a7,0
    {
        if (pid == a->n[i]->pid)
        {
            flag = 1;
        }
        if (flag == 1 && i != NPROC)
    800060b8:	04000e93          	li	t4,64
    800060bc:	4805                	li	a6,1
    800060be:	a811                	j	800060d2 <delete+0x32>
    800060c0:	88c2                	mv	a7,a6
    800060c2:	01d70463          	beq	a4,t4,800060ca <delete+0x2a>
        {
            a->n[i] = a->n[i + 1];
    800060c6:	6614                	ld	a3,8(a2)
    800060c8:	e214                	sd	a3,0(a2)
    for (int i = 0; i < a->end; i++)
    800060ca:	2705                	addiw	a4,a4,1
    800060cc:	07a1                	addi	a5,a5,8
    800060ce:	00670a63          	beq	a4,t1,800060e2 <delete+0x42>
        if (pid == a->n[i]->pid)
    800060d2:	863e                	mv	a2,a5
    800060d4:	6394                	ld	a3,0(a5)
    800060d6:	5a94                	lw	a3,48(a3)
    800060d8:	feb684e3          	beq	a3,a1,800060c0 <delete+0x20>
        if (flag == 1 && i != NPROC)
    800060dc:	ff0897e3          	bne	a7,a6,800060ca <delete+0x2a>
    800060e0:	b7c5                	j	800060c0 <delete+0x20>
        }
    }
    a->end--;
    800060e2:	3e7d                	addiw	t3,t3,-1
    800060e4:	21c52023          	sw	t3,512(a0)
    return;
    800060e8:	6422                	ld	s0,8(sp)
    800060ea:	0141                	addi	sp,sp,16
    800060ec:	8082                	ret

00000000800060ee <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060ee:	1141                	addi	sp,sp,-16
    800060f0:	e406                	sd	ra,8(sp)
    800060f2:	e022                	sd	s0,0(sp)
    800060f4:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800060f6:	479d                	li	a5,7
    800060f8:	04a7cc63          	blt	a5,a0,80006150 <free_desc+0x62>
    panic("free_desc 1");
  if (disk.free[i])
    800060fc:	0001d797          	auipc	a5,0x1d
    80006100:	56c78793          	addi	a5,a5,1388 # 80023668 <disk>
    80006104:	97aa                	add	a5,a5,a0
    80006106:	0187c783          	lbu	a5,24(a5)
    8000610a:	ebb9                	bnez	a5,80006160 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000610c:	00451693          	slli	a3,a0,0x4
    80006110:	0001d797          	auipc	a5,0x1d
    80006114:	55878793          	addi	a5,a5,1368 # 80023668 <disk>
    80006118:	6398                	ld	a4,0(a5)
    8000611a:	9736                	add	a4,a4,a3
    8000611c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006120:	6398                	ld	a4,0(a5)
    80006122:	9736                	add	a4,a4,a3
    80006124:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006128:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000612c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006130:	97aa                	add	a5,a5,a0
    80006132:	4705                	li	a4,1
    80006134:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006138:	0001d517          	auipc	a0,0x1d
    8000613c:	54850513          	addi	a0,a0,1352 # 80023680 <disk+0x18>
    80006140:	ffffc097          	auipc	ra,0xffffc
    80006144:	fcc080e7          	jalr	-52(ra) # 8000210c <wakeup>
}
    80006148:	60a2                	ld	ra,8(sp)
    8000614a:	6402                	ld	s0,0(sp)
    8000614c:	0141                	addi	sp,sp,16
    8000614e:	8082                	ret
    panic("free_desc 1");
    80006150:	00002517          	auipc	a0,0x2
    80006154:	61050513          	addi	a0,a0,1552 # 80008760 <syscalls+0x310>
    80006158:	ffffa097          	auipc	ra,0xffffa
    8000615c:	3e8080e7          	jalr	1000(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006160:	00002517          	auipc	a0,0x2
    80006164:	61050513          	addi	a0,a0,1552 # 80008770 <syscalls+0x320>
    80006168:	ffffa097          	auipc	ra,0xffffa
    8000616c:	3d8080e7          	jalr	984(ra) # 80000540 <panic>

0000000080006170 <virtio_disk_init>:
{
    80006170:	1101                	addi	sp,sp,-32
    80006172:	ec06                	sd	ra,24(sp)
    80006174:	e822                	sd	s0,16(sp)
    80006176:	e426                	sd	s1,8(sp)
    80006178:	e04a                	sd	s2,0(sp)
    8000617a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000617c:	00002597          	auipc	a1,0x2
    80006180:	60458593          	addi	a1,a1,1540 # 80008780 <syscalls+0x330>
    80006184:	0001d517          	auipc	a0,0x1d
    80006188:	60c50513          	addi	a0,a0,1548 # 80023790 <disk+0x128>
    8000618c:	ffffb097          	auipc	ra,0xffffb
    80006190:	9ba080e7          	jalr	-1606(ra) # 80000b46 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006194:	100017b7          	lui	a5,0x10001
    80006198:	4398                	lw	a4,0(a5)
    8000619a:	2701                	sext.w	a4,a4
    8000619c:	747277b7          	lui	a5,0x74727
    800061a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061a4:	14f71b63          	bne	a4,a5,800062fa <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061a8:	100017b7          	lui	a5,0x10001
    800061ac:	43dc                	lw	a5,4(a5)
    800061ae:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061b0:	4709                	li	a4,2
    800061b2:	14e79463          	bne	a5,a4,800062fa <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061b6:	100017b7          	lui	a5,0x10001
    800061ba:	479c                	lw	a5,8(a5)
    800061bc:	2781                	sext.w	a5,a5
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061be:	12e79e63          	bne	a5,a4,800062fa <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551)
    800061c2:	100017b7          	lui	a5,0x10001
    800061c6:	47d8                	lw	a4,12(a5)
    800061c8:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061ca:	554d47b7          	lui	a5,0x554d4
    800061ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061d2:	12f71463          	bne	a4,a5,800062fa <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d6:	100017b7          	lui	a5,0x10001
    800061da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061de:	4705                	li	a4,1
    800061e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e2:	470d                	li	a4,3
    800061e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061e6:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061e8:	c7ffe6b7          	lui	a3,0xc7ffe
    800061ec:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdafb7>
    800061f0:	8f75                	and	a4,a4,a3
    800061f2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061f4:	472d                	li	a4,11
    800061f6:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800061f8:	5bbc                	lw	a5,112(a5)
    800061fa:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800061fe:	8ba1                	andi	a5,a5,8
    80006200:	10078563          	beqz	a5,8000630a <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006204:	100017b7          	lui	a5,0x10001
    80006208:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    8000620c:	43fc                	lw	a5,68(a5)
    8000620e:	2781                	sext.w	a5,a5
    80006210:	10079563          	bnez	a5,8000631a <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006214:	100017b7          	lui	a5,0x10001
    80006218:	5bdc                	lw	a5,52(a5)
    8000621a:	2781                	sext.w	a5,a5
  if (max == 0)
    8000621c:	10078763          	beqz	a5,8000632a <virtio_disk_init+0x1ba>
  if (max < NUM)
    80006220:	471d                	li	a4,7
    80006222:	10f77c63          	bgeu	a4,a5,8000633a <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80006226:	ffffb097          	auipc	ra,0xffffb
    8000622a:	8c0080e7          	jalr	-1856(ra) # 80000ae6 <kalloc>
    8000622e:	0001d497          	auipc	s1,0x1d
    80006232:	43a48493          	addi	s1,s1,1082 # 80023668 <disk>
    80006236:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006238:	ffffb097          	auipc	ra,0xffffb
    8000623c:	8ae080e7          	jalr	-1874(ra) # 80000ae6 <kalloc>
    80006240:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80006242:	ffffb097          	auipc	ra,0xffffb
    80006246:	8a4080e7          	jalr	-1884(ra) # 80000ae6 <kalloc>
    8000624a:	87aa                	mv	a5,a0
    8000624c:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    8000624e:	6088                	ld	a0,0(s1)
    80006250:	cd6d                	beqz	a0,8000634a <virtio_disk_init+0x1da>
    80006252:	0001d717          	auipc	a4,0x1d
    80006256:	41e73703          	ld	a4,1054(a4) # 80023670 <disk+0x8>
    8000625a:	cb65                	beqz	a4,8000634a <virtio_disk_init+0x1da>
    8000625c:	c7fd                	beqz	a5,8000634a <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    8000625e:	6605                	lui	a2,0x1
    80006260:	4581                	li	a1,0
    80006262:	ffffb097          	auipc	ra,0xffffb
    80006266:	a70080e7          	jalr	-1424(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000626a:	0001d497          	auipc	s1,0x1d
    8000626e:	3fe48493          	addi	s1,s1,1022 # 80023668 <disk>
    80006272:	6605                	lui	a2,0x1
    80006274:	4581                	li	a1,0
    80006276:	6488                	ld	a0,8(s1)
    80006278:	ffffb097          	auipc	ra,0xffffb
    8000627c:	a5a080e7          	jalr	-1446(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80006280:	6605                	lui	a2,0x1
    80006282:	4581                	li	a1,0
    80006284:	6888                	ld	a0,16(s1)
    80006286:	ffffb097          	auipc	ra,0xffffb
    8000628a:	a4c080e7          	jalr	-1460(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000628e:	100017b7          	lui	a5,0x10001
    80006292:	4721                	li	a4,8
    80006294:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006296:	4098                	lw	a4,0(s1)
    80006298:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000629c:	40d8                	lw	a4,4(s1)
    8000629e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800062a2:	6498                	ld	a4,8(s1)
    800062a4:	0007069b          	sext.w	a3,a4
    800062a8:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800062ac:	9701                	srai	a4,a4,0x20
    800062ae:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800062b2:	6898                	ld	a4,16(s1)
    800062b4:	0007069b          	sext.w	a3,a4
    800062b8:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800062bc:	9701                	srai	a4,a4,0x20
    800062be:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800062c2:	4705                	li	a4,1
    800062c4:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800062c6:	00e48c23          	sb	a4,24(s1)
    800062ca:	00e48ca3          	sb	a4,25(s1)
    800062ce:	00e48d23          	sb	a4,26(s1)
    800062d2:	00e48da3          	sb	a4,27(s1)
    800062d6:	00e48e23          	sb	a4,28(s1)
    800062da:	00e48ea3          	sb	a4,29(s1)
    800062de:	00e48f23          	sb	a4,30(s1)
    800062e2:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800062e6:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800062ea:	0727a823          	sw	s2,112(a5)
}
    800062ee:	60e2                	ld	ra,24(sp)
    800062f0:	6442                	ld	s0,16(sp)
    800062f2:	64a2                	ld	s1,8(sp)
    800062f4:	6902                	ld	s2,0(sp)
    800062f6:	6105                	addi	sp,sp,32
    800062f8:	8082                	ret
    panic("could not find virtio disk");
    800062fa:	00002517          	auipc	a0,0x2
    800062fe:	49650513          	addi	a0,a0,1174 # 80008790 <syscalls+0x340>
    80006302:	ffffa097          	auipc	ra,0xffffa
    80006306:	23e080e7          	jalr	574(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000630a:	00002517          	auipc	a0,0x2
    8000630e:	4a650513          	addi	a0,a0,1190 # 800087b0 <syscalls+0x360>
    80006312:	ffffa097          	auipc	ra,0xffffa
    80006316:	22e080e7          	jalr	558(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    8000631a:	00002517          	auipc	a0,0x2
    8000631e:	4b650513          	addi	a0,a0,1206 # 800087d0 <syscalls+0x380>
    80006322:	ffffa097          	auipc	ra,0xffffa
    80006326:	21e080e7          	jalr	542(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    8000632a:	00002517          	auipc	a0,0x2
    8000632e:	4c650513          	addi	a0,a0,1222 # 800087f0 <syscalls+0x3a0>
    80006332:	ffffa097          	auipc	ra,0xffffa
    80006336:	20e080e7          	jalr	526(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    8000633a:	00002517          	auipc	a0,0x2
    8000633e:	4d650513          	addi	a0,a0,1238 # 80008810 <syscalls+0x3c0>
    80006342:	ffffa097          	auipc	ra,0xffffa
    80006346:	1fe080e7          	jalr	510(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    8000634a:	00002517          	auipc	a0,0x2
    8000634e:	4e650513          	addi	a0,a0,1254 # 80008830 <syscalls+0x3e0>
    80006352:	ffffa097          	auipc	ra,0xffffa
    80006356:	1ee080e7          	jalr	494(ra) # 80000540 <panic>

000000008000635a <virtio_disk_rw>:
  }
  return 0;
}

void virtio_disk_rw(struct buf *b, int write)
{
    8000635a:	7119                	addi	sp,sp,-128
    8000635c:	fc86                	sd	ra,120(sp)
    8000635e:	f8a2                	sd	s0,112(sp)
    80006360:	f4a6                	sd	s1,104(sp)
    80006362:	f0ca                	sd	s2,96(sp)
    80006364:	ecce                	sd	s3,88(sp)
    80006366:	e8d2                	sd	s4,80(sp)
    80006368:	e4d6                	sd	s5,72(sp)
    8000636a:	e0da                	sd	s6,64(sp)
    8000636c:	fc5e                	sd	s7,56(sp)
    8000636e:	f862                	sd	s8,48(sp)
    80006370:	f466                	sd	s9,40(sp)
    80006372:	f06a                	sd	s10,32(sp)
    80006374:	ec6e                	sd	s11,24(sp)
    80006376:	0100                	addi	s0,sp,128
    80006378:	8aaa                	mv	s5,a0
    8000637a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000637c:	00c52d03          	lw	s10,12(a0)
    80006380:	001d1d1b          	slliw	s10,s10,0x1
    80006384:	1d02                	slli	s10,s10,0x20
    80006386:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000638a:	0001d517          	auipc	a0,0x1d
    8000638e:	40650513          	addi	a0,a0,1030 # 80023790 <disk+0x128>
    80006392:	ffffb097          	auipc	ra,0xffffb
    80006396:	844080e7          	jalr	-1980(ra) # 80000bd6 <acquire>
  for (int i = 0; i < 3; i++)
    8000639a:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++)
    8000639c:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000639e:	0001db97          	auipc	s7,0x1d
    800063a2:	2cab8b93          	addi	s7,s7,714 # 80023668 <disk>
  for (int i = 0; i < 3; i++)
    800063a6:	4b0d                	li	s6,3
  {
    if (alloc3_desc(idx) == 0)
    {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063a8:	0001dc97          	auipc	s9,0x1d
    800063ac:	3e8c8c93          	addi	s9,s9,1000 # 80023790 <disk+0x128>
    800063b0:	a08d                	j	80006412 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800063b2:	00fb8733          	add	a4,s7,a5
    800063b6:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800063ba:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0)
    800063bc:	0207c563          	bltz	a5,800063e6 <virtio_disk_rw+0x8c>
  for (int i = 0; i < 3; i++)
    800063c0:	2905                	addiw	s2,s2,1
    800063c2:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800063c4:	05690c63          	beq	s2,s6,8000641c <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800063c8:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++)
    800063ca:	0001d717          	auipc	a4,0x1d
    800063ce:	29e70713          	addi	a4,a4,670 # 80023668 <disk>
    800063d2:	87ce                	mv	a5,s3
    if (disk.free[i])
    800063d4:	01874683          	lbu	a3,24(a4)
    800063d8:	fee9                	bnez	a3,800063b2 <virtio_disk_rw+0x58>
  for (int i = 0; i < NUM; i++)
    800063da:	2785                	addiw	a5,a5,1
    800063dc:	0705                	addi	a4,a4,1
    800063de:	fe979be3          	bne	a5,s1,800063d4 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800063e2:	57fd                	li	a5,-1
    800063e4:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    800063e6:	01205d63          	blez	s2,80006400 <virtio_disk_rw+0xa6>
    800063ea:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800063ec:	000a2503          	lw	a0,0(s4)
    800063f0:	00000097          	auipc	ra,0x0
    800063f4:	cfe080e7          	jalr	-770(ra) # 800060ee <free_desc>
      for (int j = 0; j < i; j++)
    800063f8:	2d85                	addiw	s11,s11,1
    800063fa:	0a11                	addi	s4,s4,4
    800063fc:	ff2d98e3          	bne	s11,s2,800063ec <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006400:	85e6                	mv	a1,s9
    80006402:	0001d517          	auipc	a0,0x1d
    80006406:	27e50513          	addi	a0,a0,638 # 80023680 <disk+0x18>
    8000640a:	ffffc097          	auipc	ra,0xffffc
    8000640e:	c9e080e7          	jalr	-866(ra) # 800020a8 <sleep>
  for (int i = 0; i < 3; i++)
    80006412:	f8040a13          	addi	s4,s0,-128
{
    80006416:	8652                	mv	a2,s4
  for (int i = 0; i < 3; i++)
    80006418:	894e                	mv	s2,s3
    8000641a:	b77d                	j	800063c8 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000641c:	f8042503          	lw	a0,-128(s0)
    80006420:	00a50713          	addi	a4,a0,10
    80006424:	0712                	slli	a4,a4,0x4

  if (write)
    80006426:	0001d797          	auipc	a5,0x1d
    8000642a:	24278793          	addi	a5,a5,578 # 80023668 <disk>
    8000642e:	00e786b3          	add	a3,a5,a4
    80006432:	01803633          	snez	a2,s8
    80006436:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006438:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    8000643c:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80006440:	f6070613          	addi	a2,a4,-160
    80006444:	6394                	ld	a3,0(a5)
    80006446:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006448:	00870593          	addi	a1,a4,8
    8000644c:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    8000644e:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006450:	0007b803          	ld	a6,0(a5)
    80006454:	9642                	add	a2,a2,a6
    80006456:	46c1                	li	a3,16
    80006458:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000645a:	4585                	li	a1,1
    8000645c:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006460:	f8442683          	lw	a3,-124(s0)
    80006464:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80006468:	0692                	slli	a3,a3,0x4
    8000646a:	9836                	add	a6,a6,a3
    8000646c:	058a8613          	addi	a2,s5,88
    80006470:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006474:	0007b803          	ld	a6,0(a5)
    80006478:	96c2                	add	a3,a3,a6
    8000647a:	40000613          	li	a2,1024
    8000647e:	c690                	sw	a2,8(a3)
  if (write)
    80006480:	001c3613          	seqz	a2,s8
    80006484:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006488:	00166613          	ori	a2,a2,1
    8000648c:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006490:	f8842603          	lw	a2,-120(s0)
    80006494:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006498:	00250693          	addi	a3,a0,2
    8000649c:	0692                	slli	a3,a3,0x4
    8000649e:	96be                	add	a3,a3,a5
    800064a0:	58fd                	li	a7,-1
    800064a2:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    800064a6:	0612                	slli	a2,a2,0x4
    800064a8:	9832                	add	a6,a6,a2
    800064aa:	f9070713          	addi	a4,a4,-112
    800064ae:	973e                	add	a4,a4,a5
    800064b0:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800064b4:	6398                	ld	a4,0(a5)
    800064b6:	9732                	add	a4,a4,a2
    800064b8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800064ba:	4609                	li	a2,2
    800064bc:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800064c0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800064c4:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800064c8:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800064cc:	6794                	ld	a3,8(a5)
    800064ce:	0026d703          	lhu	a4,2(a3)
    800064d2:	8b1d                	andi	a4,a4,7
    800064d4:	0706                	slli	a4,a4,0x1
    800064d6:	96ba                	add	a3,a3,a4
    800064d8:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800064dc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800064e0:	6798                	ld	a4,8(a5)
    800064e2:	00275783          	lhu	a5,2(a4)
    800064e6:	2785                	addiw	a5,a5,1
    800064e8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800064ec:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800064f0:	100017b7          	lui	a5,0x10001
    800064f4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1)
    800064f8:	004aa783          	lw	a5,4(s5)
  {
    sleep(b, &disk.vdisk_lock);
    800064fc:	0001d917          	auipc	s2,0x1d
    80006500:	29490913          	addi	s2,s2,660 # 80023790 <disk+0x128>
  while (b->disk == 1)
    80006504:	4485                	li	s1,1
    80006506:	00b79c63          	bne	a5,a1,8000651e <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000650a:	85ca                	mv	a1,s2
    8000650c:	8556                	mv	a0,s5
    8000650e:	ffffc097          	auipc	ra,0xffffc
    80006512:	b9a080e7          	jalr	-1126(ra) # 800020a8 <sleep>
  while (b->disk == 1)
    80006516:	004aa783          	lw	a5,4(s5)
    8000651a:	fe9788e3          	beq	a5,s1,8000650a <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000651e:	f8042903          	lw	s2,-128(s0)
    80006522:	00290713          	addi	a4,s2,2
    80006526:	0712                	slli	a4,a4,0x4
    80006528:	0001d797          	auipc	a5,0x1d
    8000652c:	14078793          	addi	a5,a5,320 # 80023668 <disk>
    80006530:	97ba                	add	a5,a5,a4
    80006532:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006536:	0001d997          	auipc	s3,0x1d
    8000653a:	13298993          	addi	s3,s3,306 # 80023668 <disk>
    8000653e:	00491713          	slli	a4,s2,0x4
    80006542:	0009b783          	ld	a5,0(s3)
    80006546:	97ba                	add	a5,a5,a4
    80006548:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000654c:	854a                	mv	a0,s2
    8000654e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006552:	00000097          	auipc	ra,0x0
    80006556:	b9c080e7          	jalr	-1124(ra) # 800060ee <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    8000655a:	8885                	andi	s1,s1,1
    8000655c:	f0ed                	bnez	s1,8000653e <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000655e:	0001d517          	auipc	a0,0x1d
    80006562:	23250513          	addi	a0,a0,562 # 80023790 <disk+0x128>
    80006566:	ffffa097          	auipc	ra,0xffffa
    8000656a:	724080e7          	jalr	1828(ra) # 80000c8a <release>
}
    8000656e:	70e6                	ld	ra,120(sp)
    80006570:	7446                	ld	s0,112(sp)
    80006572:	74a6                	ld	s1,104(sp)
    80006574:	7906                	ld	s2,96(sp)
    80006576:	69e6                	ld	s3,88(sp)
    80006578:	6a46                	ld	s4,80(sp)
    8000657a:	6aa6                	ld	s5,72(sp)
    8000657c:	6b06                	ld	s6,64(sp)
    8000657e:	7be2                	ld	s7,56(sp)
    80006580:	7c42                	ld	s8,48(sp)
    80006582:	7ca2                	ld	s9,40(sp)
    80006584:	7d02                	ld	s10,32(sp)
    80006586:	6de2                	ld	s11,24(sp)
    80006588:	6109                	addi	sp,sp,128
    8000658a:	8082                	ret

000000008000658c <virtio_disk_intr>:

void virtio_disk_intr()
{
    8000658c:	1101                	addi	sp,sp,-32
    8000658e:	ec06                	sd	ra,24(sp)
    80006590:	e822                	sd	s0,16(sp)
    80006592:	e426                	sd	s1,8(sp)
    80006594:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006596:	0001d497          	auipc	s1,0x1d
    8000659a:	0d248493          	addi	s1,s1,210 # 80023668 <disk>
    8000659e:	0001d517          	auipc	a0,0x1d
    800065a2:	1f250513          	addi	a0,a0,498 # 80023790 <disk+0x128>
    800065a6:	ffffa097          	auipc	ra,0xffffa
    800065aa:	630080e7          	jalr	1584(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800065ae:	10001737          	lui	a4,0x10001
    800065b2:	533c                	lw	a5,96(a4)
    800065b4:	8b8d                	andi	a5,a5,3
    800065b6:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800065b8:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx)
    800065bc:	689c                	ld	a5,16(s1)
    800065be:	0204d703          	lhu	a4,32(s1)
    800065c2:	0027d783          	lhu	a5,2(a5)
    800065c6:	04f70863          	beq	a4,a5,80006616 <virtio_disk_intr+0x8a>
  {
    __sync_synchronize();
    800065ca:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065ce:	6898                	ld	a4,16(s1)
    800065d0:	0204d783          	lhu	a5,32(s1)
    800065d4:	8b9d                	andi	a5,a5,7
    800065d6:	078e                	slli	a5,a5,0x3
    800065d8:	97ba                	add	a5,a5,a4
    800065da:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    800065dc:	00278713          	addi	a4,a5,2
    800065e0:	0712                	slli	a4,a4,0x4
    800065e2:	9726                	add	a4,a4,s1
    800065e4:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800065e8:	e721                	bnez	a4,80006630 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065ea:	0789                	addi	a5,a5,2
    800065ec:	0792                	slli	a5,a5,0x4
    800065ee:	97a6                	add	a5,a5,s1
    800065f0:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    800065f2:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065f6:	ffffc097          	auipc	ra,0xffffc
    800065fa:	b16080e7          	jalr	-1258(ra) # 8000210c <wakeup>

    disk.used_idx += 1;
    800065fe:	0204d783          	lhu	a5,32(s1)
    80006602:	2785                	addiw	a5,a5,1
    80006604:	17c2                	slli	a5,a5,0x30
    80006606:	93c1                	srli	a5,a5,0x30
    80006608:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx)
    8000660c:	6898                	ld	a4,16(s1)
    8000660e:	00275703          	lhu	a4,2(a4)
    80006612:	faf71ce3          	bne	a4,a5,800065ca <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006616:	0001d517          	auipc	a0,0x1d
    8000661a:	17a50513          	addi	a0,a0,378 # 80023790 <disk+0x128>
    8000661e:	ffffa097          	auipc	ra,0xffffa
    80006622:	66c080e7          	jalr	1644(ra) # 80000c8a <release>
}
    80006626:	60e2                	ld	ra,24(sp)
    80006628:	6442                	ld	s0,16(sp)
    8000662a:	64a2                	ld	s1,8(sp)
    8000662c:	6105                	addi	sp,sp,32
    8000662e:	8082                	ret
      panic("virtio_disk_intr status");
    80006630:	00002517          	auipc	a0,0x2
    80006634:	21850513          	addi	a0,a0,536 # 80008848 <syscalls+0x3f8>
    80006638:	ffffa097          	auipc	ra,0xffffa
    8000663c:	f08080e7          	jalr	-248(ra) # 80000540 <panic>
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
