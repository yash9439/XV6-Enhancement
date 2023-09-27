
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8c013103          	ld	sp,-1856(sp) # 800088c0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	8d070713          	addi	a4,a4,-1840 # 80008920 <timer_scratch>
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
    80000066:	01e78793          	addi	a5,a5,30 # 80006080 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb24f>
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
    8000012e:	508080e7          	jalr	1288(ra) # 80002632 <either_copyin>
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
    8000018e:	8d650513          	addi	a0,a0,-1834 # 80010a60 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8c648493          	addi	s1,s1,-1850 # 80010a60 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	95690913          	addi	s2,s2,-1706 # 80010af8 <cons+0x98>
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
    800001cc:	2b4080e7          	jalr	692(ra) # 8000247c <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	ff2080e7          	jalr	-14(ra) # 800021c8 <sleep>
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
    80000216:	3ca080e7          	jalr	970(ra) # 800025dc <either_copyout>
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
    8000022a:	83a50513          	addi	a0,a0,-1990 # 80010a60 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	82450513          	addi	a0,a0,-2012 # 80010a60 <cons>
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
    80000276:	88f72323          	sw	a5,-1914(a4) # 80010af8 <cons+0x98>
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
    800002d0:	79450513          	addi	a0,a0,1940 # 80010a60 <cons>
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
    800002f6:	396080e7          	jalr	918(ra) # 80002688 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	76650513          	addi	a0,a0,1894 # 80010a60 <cons>
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
    80000322:	74270713          	addi	a4,a4,1858 # 80010a60 <cons>
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
    8000034c:	71878793          	addi	a5,a5,1816 # 80010a60 <cons>
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
    8000037a:	7827a783          	lw	a5,1922(a5) # 80010af8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while (cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6d670713          	addi	a4,a4,1750 # 80010a60 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6c648493          	addi	s1,s1,1734 # 80010a60 <cons>
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
    800003da:	68a70713          	addi	a4,a4,1674 # 80010a60 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72a23          	sw	a5,1812(a4) # 80010b00 <cons+0xa0>
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
    80000416:	64e78793          	addi	a5,a5,1614 # 80010a60 <cons>
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
    8000043a:	6cc7a323          	sw	a2,1734(a5) # 80010afc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6ba50513          	addi	a0,a0,1722 # 80010af8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	de6080e7          	jalr	-538(ra) # 8000222c <wakeup>
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
    80000464:	60050513          	addi	a0,a0,1536 # 80010a60 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	fa078793          	addi	a5,a5,-96 # 80022418 <devsw>
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
    80000550:	5c07aa23          	sw	zero,1492(a5) # 80010b20 <pr+0x18>
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
    80000584:	36f72023          	sw	a5,864(a4) # 800088e0 <panicked>
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
    800005c0:	564dad83          	lw	s11,1380(s11) # 80010b20 <pr+0x18>
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
    800005fe:	50e50513          	addi	a0,a0,1294 # 80010b08 <pr>
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
    8000075c:	3b050513          	addi	a0,a0,944 # 80010b08 <pr>
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
    80000778:	39448493          	addi	s1,s1,916 # 80010b08 <pr>
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
    800007d8:	35450513          	addi	a0,a0,852 # 80010b28 <uart_tx_lock>
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
    80000804:	0e07a783          	lw	a5,224(a5) # 800088e0 <panicked>
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
    8000083c:	0b07b783          	ld	a5,176(a5) # 800088e8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0b073703          	ld	a4,176(a4) # 800088f0 <uart_tx_w>
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
    80000866:	2c6a0a13          	addi	s4,s4,710 # 80010b28 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	07e48493          	addi	s1,s1,126 # 800088e8 <uart_tx_r>
    if (uart_tx_w == uart_tx_r)
    80000872:	00008997          	auipc	s3,0x8
    80000876:	07e98993          	addi	s3,s3,126 # 800088f0 <uart_tx_w>
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
    80000898:	998080e7          	jalr	-1640(ra) # 8000222c <wakeup>

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
    800008d4:	25850513          	addi	a0,a0,600 # 80010b28 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if (panicked)
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	0007a783          	lw	a5,0(a5) # 800088e0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	00673703          	ld	a4,6(a4) # 800088f0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	ff67b783          	ld	a5,-10(a5) # 800088e8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	22a98993          	addi	s3,s3,554 # 80010b28 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	fe248493          	addi	s1,s1,-30 # 800088e8 <uart_tx_r>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	fe290913          	addi	s2,s2,-30 # 800088f0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	8aa080e7          	jalr	-1878(ra) # 800021c8 <sleep>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	1f448493          	addi	s1,s1,500 # 80010b28 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	fae7b423          	sd	a4,-88(a5) # 800088f0 <uart_tx_w>
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
    800009be:	16e48493          	addi	s1,s1,366 # 80010b28 <uart_tx_lock>
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
    80000a00:	bb478793          	addi	a5,a5,-1100 # 800235b0 <end>
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
    80000a20:	14490913          	addi	s2,s2,324 # 80010b60 <kmem>
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
    80000abe:	0a650513          	addi	a0,a0,166 # 80010b60 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	ae250513          	addi	a0,a0,-1310 # 800235b0 <end>
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
    80000af4:	07048493          	addi	s1,s1,112 # 80010b60 <kmem>
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
    80000b0c:	05850513          	addi	a0,a0,88 # 80010b60 <kmem>
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
    80000b38:	02c50513          	addi	a0,a0,44 # 80010b60 <kmem>
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
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdba51>
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
    80000e8c:	a7070713          	addi	a4,a4,-1424 # 800088f8 <started>
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
    80000ec2:	ab6080e7          	jalr	-1354(ra) # 80002974 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	1fa080e7          	jalr	506(ra) # 800060c0 <plicinithart>
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
    80000f3a:	a16080e7          	jalr	-1514(ra) # 8000294c <trapinit>
    trapinithart();     // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a36080e7          	jalr	-1482(ra) # 80002974 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	164080e7          	jalr	356(ra) # 800060aa <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	172080e7          	jalr	370(ra) # 800060c0 <plicinithart>
    binit();            // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	30e080e7          	jalr	782(ra) # 80003264 <binit>
    iinit();            // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	9ae080e7          	jalr	-1618(ra) # 8000390c <iinit>
    fileinit();         // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	954080e7          	jalr	-1708(ra) # 800048ba <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	340080e7          	jalr	832(ra) # 800062ae <virtio_disk_init>
    userinit();         // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d62080e7          	jalr	-670(ra) # 80001cd8 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72a23          	sw	a5,-1676(a4) # 800088f8 <started>
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
    80000f9c:	9687b783          	ld	a5,-1688(a5) # 80008900 <kernel_pagetable>
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
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdba47>
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
    80001258:	6aa7b623          	sd	a0,1708(a5) # 80008900 <kernel_pagetable>
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
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdba50>
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
    80001850:	76448493          	addi	s1,s1,1892 # 80010fb0 <proc>
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
    8000186a:	14aa0a13          	addi	s4,s4,330 # 800179b0 <mlfq>
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
    800018ec:	29850513          	addi	a0,a0,664 # 80010b80 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	29850513          	addi	a0,a0,664 # 80010b98 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	6a048493          	addi	s1,s1,1696 # 80010fb0 <proc>
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
    80001936:	07e98993          	addi	s3,s3,126 # 800179b0 <mlfq>
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
    800019a0:	21450513          	addi	a0,a0,532 # 80010bb0 <cpus>
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
    800019c8:	1bc70713          	addi	a4,a4,444 # 80010b80 <pid_lock>
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
    80001a00:	e747a783          	lw	a5,-396(a5) # 80008870 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	f86080e7          	jalr	-122(ra) # 8000298c <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e407ad23          	sw	zero,-422(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	e6c080e7          	jalr	-404(ra) # 8000388c <fsinit>
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
    80001a3a:	14a90913          	addi	s2,s2,330 # 80010b80 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e2c78793          	addi	a5,a5,-468 # 80008874 <nextpid>
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
    80001bd8:	3dc48493          	addi	s1,s1,988 # 80010fb0 <proc>
    80001bdc:	00016917          	auipc	s2,0x16
    80001be0:	dd490913          	addi	s2,s2,-556 # 800179b0 <mlfq>
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
  p->change_queue = TICK1;
    80001c1a:	16f4ae23          	sw	a5,380(s1)
  p->in_queue = 0;
    80001c1e:	1604ac23          	sw	zero,376(s1)
  p->enter_ticks = ticks;
    80001c22:	00007797          	auipc	a5,0x7
    80001c26:	cee7a783          	lw	a5,-786(a5) # 80008910 <ticks>
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
    80001c92:	c827a783          	lw	a5,-894(a5) # 80008910 <ticks>
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
    80001cf0:	c0a7be23          	sd	a0,-996(a5) # 80008908 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cf4:	03400613          	li	a2,52
    80001cf8:	00007597          	auipc	a1,0x7
    80001cfc:	b8858593          	addi	a1,a1,-1144 # 80008880 <initcode>
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
    80001d3a:	580080e7          	jalr	1408(ra) # 800042b6 <namei>
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
    80001e6a:	ae6080e7          	jalr	-1306(ra) # 8000494c <filedup>
    80001e6e:	00a93023          	sd	a0,0(s2)
    80001e72:	b7e5                	j	80001e5a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e74:	150ab503          	ld	a0,336(s5)
    80001e78:	00002097          	auipc	ra,0x2
    80001e7c:	c54080e7          	jalr	-940(ra) # 80003acc <idup>
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
    80001ea8:	cf448493          	addi	s1,s1,-780 # 80010b98 <wait_lock>
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
    80001ef6:	711d                	addi	sp,sp,-96
    80001ef8:	ec86                	sd	ra,88(sp)
    80001efa:	e8a2                	sd	s0,80(sp)
    80001efc:	e4a6                	sd	s1,72(sp)
    80001efe:	e0ca                	sd	s2,64(sp)
    80001f00:	fc4e                	sd	s3,56(sp)
    80001f02:	f852                	sd	s4,48(sp)
    80001f04:	f456                	sd	s5,40(sp)
    80001f06:	f05a                	sd	s6,32(sp)
    80001f08:	ec5e                	sd	s7,24(sp)
    80001f0a:	e862                	sd	s8,16(sp)
    80001f0c:	e466                	sd	s9,8(sp)
    80001f0e:	e06a                	sd	s10,0(sp)
    80001f10:	1080                	addi	s0,sp,96
    80001f12:	8792                	mv	a5,tp
  int id = r_tp();
    80001f14:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f16:	00779693          	slli	a3,a5,0x7
    80001f1a:	0000f717          	auipc	a4,0xf
    80001f1e:	c6670713          	addi	a4,a4,-922 # 80010b80 <pid_lock>
    80001f22:	9736                	add	a4,a4,a3
    80001f24:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &p->context);
    80001f28:	0000f717          	auipc	a4,0xf
    80001f2c:	c9070713          	addi	a4,a4,-880 # 80010bb8 <cpus+0x8>
    80001f30:	00e68d33          	add	s10,a3,a4
      if (p->state == RUNNABLE && ticks - p->enter_ticks >= AGETICK)
    80001f34:	00007a17          	auipc	s4,0x7
    80001f38:	9dca0a13          	addi	s4,s4,-1572 # 80008910 <ticks>
        pushback(&mlfq[p->level], p);
    80001f3c:	00016a97          	auipc	s5,0x16
    80001f40:	a74a8a93          	addi	s5,s5,-1420 # 800179b0 <mlfq>
      c->proc = p;
    80001f44:	0000fc97          	auipc	s9,0xf
    80001f48:	c3cc8c93          	addi	s9,s9,-964 # 80010b80 <pid_lock>
    80001f4c:	9cb6                	add	s9,s9,a3
    80001f4e:	a225                	j	80002076 <scheduler+0x180>
          delete (&mlfq[p->level], p->pid);
    80001f50:	1744e783          	lwu	a5,372(s1)
    80001f54:	00679513          	slli	a0,a5,0x6
    80001f58:	953e                	add	a0,a0,a5
    80001f5a:	050e                	slli	a0,a0,0x3
    80001f5c:	588c                	lw	a1,48(s1)
    80001f5e:	9556                	add	a0,a0,s5
    80001f60:	00004097          	auipc	ra,0x4
    80001f64:	27e080e7          	jalr	638(ra) # 800061de <delete>
          p->in_queue = 0;
    80001f68:	1604ac23          	sw	zero,376(s1)
    80001f6c:	a825                	j	80001fa4 <scheduler+0xae>
        p->enter_ticks = ticks;
    80001f6e:	000a2783          	lw	a5,0(s4)
    80001f72:	18f4a023          	sw	a5,384(s1)
      if (p->state == RUNNABLE && !p->in_queue)
    80001f76:	4c9c                	lw	a5,24(s1)
    80001f78:	01279563          	bne	a5,s2,80001f82 <scheduler+0x8c>
    80001f7c:	1784a783          	lw	a5,376(s1)
    80001f80:	cb8d                	beqz	a5,80001fb2 <scheduler+0xbc>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f82:	1a848493          	addi	s1,s1,424
    80001f86:	05348563          	beq	s1,s3,80001fd0 <scheduler+0xda>
      if (p->state == RUNNABLE && ticks - p->enter_ticks >= AGETICK)
    80001f8a:	4c9c                	lw	a5,24(s1)
    80001f8c:	ff279be3          	bne	a5,s2,80001f82 <scheduler+0x8c>
    80001f90:	000a2783          	lw	a5,0(s4)
    80001f94:	1804a703          	lw	a4,384(s1)
    80001f98:	9f99                	subw	a5,a5,a4
    80001f9a:	fefb71e3          	bgeu	s6,a5,80001f7c <scheduler+0x86>
        if (p->in_queue)
    80001f9e:	1784a783          	lw	a5,376(s1)
    80001fa2:	f7dd                	bnez	a5,80001f50 <scheduler+0x5a>
        if (p->level)
    80001fa4:	1744a783          	lw	a5,372(s1)
    80001fa8:	d3f9                	beqz	a5,80001f6e <scheduler+0x78>
          p->level--;
    80001faa:	37fd                	addiw	a5,a5,-1
    80001fac:	16f4aa23          	sw	a5,372(s1)
    80001fb0:	bf7d                	j	80001f6e <scheduler+0x78>
        pushback(&mlfq[p->level], p);
    80001fb2:	1744e783          	lwu	a5,372(s1)
    80001fb6:	00679513          	slli	a0,a5,0x6
    80001fba:	953e                	add	a0,a0,a5
    80001fbc:	050e                	slli	a0,a0,0x3
    80001fbe:	85a6                	mv	a1,s1
    80001fc0:	9556                	add	a0,a0,s5
    80001fc2:	00004097          	auipc	ra,0x4
    80001fc6:	1bc080e7          	jalr	444(ra) # 8000617e <pushback>
        p->in_queue = 1;
    80001fca:	1774ac23          	sw	s7,376(s1)
    80001fce:	bf55                	j	80001f82 <scheduler+0x8c>
    80001fd0:	00016b97          	auipc	s7,0x16
    80001fd4:	9e0b8b93          	addi	s7,s7,-1568 # 800179b0 <mlfq>
      while (size(&mlfq[level]))
    80001fd8:	8b5e                	mv	s6,s7
    80001fda:	855a                	mv	a0,s6
    80001fdc:	00004097          	auipc	ra,0x4
    80001fe0:	1f2080e7          	jalr	498(ra) # 800061ce <size>
    80001fe4:	c15d                	beqz	a0,8000208a <scheduler+0x194>
        p = front(&mlfq[level]);
    80001fe6:	855a                	mv	a0,s6
    80001fe8:	00004097          	auipc	ra,0x4
    80001fec:	1ce080e7          	jalr	462(ra) # 800061b6 <front>
    80001ff0:	84aa                	mv	s1,a0
        popfront(&mlfq[p->level]);
    80001ff2:	17456783          	lwu	a5,372(a0)
    80001ff6:	00679513          	slli	a0,a5,0x6
    80001ffa:	953e                	add	a0,a0,a5
    80001ffc:	050e                	slli	a0,a0,0x3
    80001ffe:	9556                	add	a0,a0,s5
    80002000:	00004097          	auipc	ra,0x4
    80002004:	146080e7          	jalr	326(ra) # 80006146 <popfront>
        p->in_queue = 0;
    80002008:	1604ac23          	sw	zero,376(s1)
        if (p->state == RUNNABLE)
    8000200c:	4c9c                	lw	a5,24(s1)
    8000200e:	fd2796e3          	bne	a5,s2,80001fda <scheduler+0xe4>
          p->enter_ticks = ticks;
    80002012:	000a2783          	lw	a5,0(s4)
    80002016:	18f4a023          	sw	a5,384(s1)
      acquire(&p->lock);
    8000201a:	8926                	mv	s2,s1
    8000201c:	8526                	mv	a0,s1
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	bb8080e7          	jalr	-1096(ra) # 80000bd6 <acquire>
      if(p->level == 0) {
    80002026:	1744a703          	lw	a4,372(s1)
    8000202a:	4785                	li	a5,1
    8000202c:	cf09                	beqz	a4,80002046 <scheduler+0x150>
      else if(p->level == 1) {
    8000202e:	4685                	li	a3,1
    80002030:	478d                	li	a5,3
    80002032:	00d70a63          	beq	a4,a3,80002046 <scheduler+0x150>
      else if(p->level == 2) {
    80002036:	4689                	li	a3,2
    80002038:	47a5                	li	a5,9
    8000203a:	00d70663          	beq	a4,a3,80002046 <scheduler+0x150>
      else if(p->level == 3) {
    8000203e:	468d                	li	a3,3
    80002040:	47fd                	li	a5,31
    80002042:	06d70863          	beq	a4,a3,800020b2 <scheduler+0x1bc>
        p->change_queue = TICK1;
    80002046:	16f4ae23          	sw	a5,380(s1)
      p->state = RUNNING;
    8000204a:	4791                	li	a5,4
    8000204c:	cc9c                	sw	a5,24(s1)
      p->enter_ticks = ticks;
    8000204e:	000a2783          	lw	a5,0(s4)
    80002052:	18f4a023          	sw	a5,384(s1)
      c->proc = p;
    80002056:	029cb823          	sd	s1,48(s9)
      swtch(&c->context, &p->context);
    8000205a:	06048593          	addi	a1,s1,96
    8000205e:	856a                	mv	a0,s10
    80002060:	00001097          	auipc	ra,0x1
    80002064:	882080e7          	jalr	-1918(ra) # 800028e2 <swtch>
      c->proc = 0;
    80002068:	020cb823          	sd	zero,48(s9)
      release(&p->lock);
    8000206c:	854a                	mv	a0,s2
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	c1c080e7          	jalr	-996(ra) # 80000c8a <release>
      if (p->state == RUNNABLE && ticks - p->enter_ticks >= AGETICK)
    80002076:	490d                	li	s2,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002078:	00016997          	auipc	s3,0x16
    8000207c:	93898993          	addi	s3,s3,-1736 # 800179b0 <mlfq>
    80002080:	00016c17          	auipc	s8,0x16
    80002084:	150c0c13          	addi	s8,s8,336 # 800181d0 <tickslock>
    80002088:	a801                	j	80002098 <scheduler+0x1a2>
    for (int level = 0; level < NMLFQ; level++)
    8000208a:	208b8b93          	addi	s7,s7,520
    8000208e:	f58b95e3          	bne	s7,s8,80001fd8 <scheduler+0xe2>
    if (p->state == RUNNABLE)
    80002092:	4c9c                	lw	a5,24(s1)
    80002094:	f92783e3          	beq	a5,s2,8000201a <scheduler+0x124>
  asm volatile("csrr %0, sstatus"
    80002098:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000209c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    800020a0:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800020a4:	0000f497          	auipc	s1,0xf
    800020a8:	f0c48493          	addi	s1,s1,-244 # 80010fb0 <proc>
      if (p->state == RUNNABLE && ticks - p->enter_ticks >= AGETICK)
    800020ac:	4b75                	li	s6,29
        p->in_queue = 1;
    800020ae:	4b85                	li	s7,1
    800020b0:	bde9                	j	80001f8a <scheduler+0x94>
      else if(p->level == 3) {
    800020b2:	47bd                	li	a5,15
    800020b4:	bf49                	j	80002046 <scheduler+0x150>

00000000800020b6 <sched>:
{
    800020b6:	7179                	addi	sp,sp,-48
    800020b8:	f406                	sd	ra,40(sp)
    800020ba:	f022                	sd	s0,32(sp)
    800020bc:	ec26                	sd	s1,24(sp)
    800020be:	e84a                	sd	s2,16(sp)
    800020c0:	e44e                	sd	s3,8(sp)
    800020c2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020c4:	00000097          	auipc	ra,0x0
    800020c8:	8e8080e7          	jalr	-1816(ra) # 800019ac <myproc>
    800020cc:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	a8e080e7          	jalr	-1394(ra) # 80000b5c <holding>
    800020d6:	c93d                	beqz	a0,8000214c <sched+0x96>
  asm volatile("mv %0, tp"
    800020d8:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800020da:	2781                	sext.w	a5,a5
    800020dc:	079e                	slli	a5,a5,0x7
    800020de:	0000f717          	auipc	a4,0xf
    800020e2:	aa270713          	addi	a4,a4,-1374 # 80010b80 <pid_lock>
    800020e6:	97ba                	add	a5,a5,a4
    800020e8:	0a87a703          	lw	a4,168(a5)
    800020ec:	4785                	li	a5,1
    800020ee:	06f71763          	bne	a4,a5,8000215c <sched+0xa6>
  if (p->state == RUNNING)
    800020f2:	4c98                	lw	a4,24(s1)
    800020f4:	4791                	li	a5,4
    800020f6:	06f70b63          	beq	a4,a5,8000216c <sched+0xb6>
  asm volatile("csrr %0, sstatus"
    800020fa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020fe:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002100:	efb5                	bnez	a5,8000217c <sched+0xc6>
  asm volatile("mv %0, tp"
    80002102:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002104:	0000f917          	auipc	s2,0xf
    80002108:	a7c90913          	addi	s2,s2,-1412 # 80010b80 <pid_lock>
    8000210c:	2781                	sext.w	a5,a5
    8000210e:	079e                	slli	a5,a5,0x7
    80002110:	97ca                	add	a5,a5,s2
    80002112:	0ac7a983          	lw	s3,172(a5)
    80002116:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002118:	2781                	sext.w	a5,a5
    8000211a:	079e                	slli	a5,a5,0x7
    8000211c:	0000f597          	auipc	a1,0xf
    80002120:	a9c58593          	addi	a1,a1,-1380 # 80010bb8 <cpus+0x8>
    80002124:	95be                	add	a1,a1,a5
    80002126:	06048513          	addi	a0,s1,96
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	7b8080e7          	jalr	1976(ra) # 800028e2 <swtch>
    80002132:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002134:	2781                	sext.w	a5,a5
    80002136:	079e                	slli	a5,a5,0x7
    80002138:	993e                	add	s2,s2,a5
    8000213a:	0b392623          	sw	s3,172(s2)
}
    8000213e:	70a2                	ld	ra,40(sp)
    80002140:	7402                	ld	s0,32(sp)
    80002142:	64e2                	ld	s1,24(sp)
    80002144:	6942                	ld	s2,16(sp)
    80002146:	69a2                	ld	s3,8(sp)
    80002148:	6145                	addi	sp,sp,48
    8000214a:	8082                	ret
    panic("sched p->lock");
    8000214c:	00006517          	auipc	a0,0x6
    80002150:	0cc50513          	addi	a0,a0,204 # 80008218 <digits+0x1d8>
    80002154:	ffffe097          	auipc	ra,0xffffe
    80002158:	3ec080e7          	jalr	1004(ra) # 80000540 <panic>
    panic("sched locks");
    8000215c:	00006517          	auipc	a0,0x6
    80002160:	0cc50513          	addi	a0,a0,204 # 80008228 <digits+0x1e8>
    80002164:	ffffe097          	auipc	ra,0xffffe
    80002168:	3dc080e7          	jalr	988(ra) # 80000540 <panic>
    panic("sched running");
    8000216c:	00006517          	auipc	a0,0x6
    80002170:	0cc50513          	addi	a0,a0,204 # 80008238 <digits+0x1f8>
    80002174:	ffffe097          	auipc	ra,0xffffe
    80002178:	3cc080e7          	jalr	972(ra) # 80000540 <panic>
    panic("sched interruptible");
    8000217c:	00006517          	auipc	a0,0x6
    80002180:	0cc50513          	addi	a0,a0,204 # 80008248 <digits+0x208>
    80002184:	ffffe097          	auipc	ra,0xffffe
    80002188:	3bc080e7          	jalr	956(ra) # 80000540 <panic>

000000008000218c <yield>:
{
    8000218c:	1101                	addi	sp,sp,-32
    8000218e:	ec06                	sd	ra,24(sp)
    80002190:	e822                	sd	s0,16(sp)
    80002192:	e426                	sd	s1,8(sp)
    80002194:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002196:	00000097          	auipc	ra,0x0
    8000219a:	816080e7          	jalr	-2026(ra) # 800019ac <myproc>
    8000219e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	a36080e7          	jalr	-1482(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800021a8:	478d                	li	a5,3
    800021aa:	cc9c                	sw	a5,24(s1)
  sched();
    800021ac:	00000097          	auipc	ra,0x0
    800021b0:	f0a080e7          	jalr	-246(ra) # 800020b6 <sched>
  release(&p->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	ad4080e7          	jalr	-1324(ra) # 80000c8a <release>
}
    800021be:	60e2                	ld	ra,24(sp)
    800021c0:	6442                	ld	s0,16(sp)
    800021c2:	64a2                	ld	s1,8(sp)
    800021c4:	6105                	addi	sp,sp,32
    800021c6:	8082                	ret

00000000800021c8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800021c8:	7179                	addi	sp,sp,-48
    800021ca:	f406                	sd	ra,40(sp)
    800021cc:	f022                	sd	s0,32(sp)
    800021ce:	ec26                	sd	s1,24(sp)
    800021d0:	e84a                	sd	s2,16(sp)
    800021d2:	e44e                	sd	s3,8(sp)
    800021d4:	1800                	addi	s0,sp,48
    800021d6:	89aa                	mv	s3,a0
    800021d8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	7d2080e7          	jalr	2002(ra) # 800019ac <myproc>
    800021e2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	9f2080e7          	jalr	-1550(ra) # 80000bd6 <acquire>
  release(lk);
    800021ec:	854a                	mv	a0,s2
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	a9c080e7          	jalr	-1380(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800021f6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021fa:	4789                	li	a5,2
    800021fc:	cc9c                	sw	a5,24(s1)

  sched();
    800021fe:	00000097          	auipc	ra,0x0
    80002202:	eb8080e7          	jalr	-328(ra) # 800020b6 <sched>

  // Tidy up.
  p->chan = 0;
    80002206:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000220a:	8526                	mv	a0,s1
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	a7e080e7          	jalr	-1410(ra) # 80000c8a <release>
  acquire(lk);
    80002214:	854a                	mv	a0,s2
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	9c0080e7          	jalr	-1600(ra) # 80000bd6 <acquire>
}
    8000221e:	70a2                	ld	ra,40(sp)
    80002220:	7402                	ld	s0,32(sp)
    80002222:	64e2                	ld	s1,24(sp)
    80002224:	6942                	ld	s2,16(sp)
    80002226:	69a2                	ld	s3,8(sp)
    80002228:	6145                	addi	sp,sp,48
    8000222a:	8082                	ret

000000008000222c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000222c:	7139                	addi	sp,sp,-64
    8000222e:	fc06                	sd	ra,56(sp)
    80002230:	f822                	sd	s0,48(sp)
    80002232:	f426                	sd	s1,40(sp)
    80002234:	f04a                	sd	s2,32(sp)
    80002236:	ec4e                	sd	s3,24(sp)
    80002238:	e852                	sd	s4,16(sp)
    8000223a:	e456                	sd	s5,8(sp)
    8000223c:	0080                	addi	s0,sp,64
    8000223e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002240:	0000f497          	auipc	s1,0xf
    80002244:	d7048493          	addi	s1,s1,-656 # 80010fb0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002248:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    8000224a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000224c:	00015917          	auipc	s2,0x15
    80002250:	76490913          	addi	s2,s2,1892 # 800179b0 <mlfq>
    80002254:	a811                	j	80002268 <wakeup+0x3c>
      }
      release(&p->lock);
    80002256:	8526                	mv	a0,s1
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	a32080e7          	jalr	-1486(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002260:	1a848493          	addi	s1,s1,424
    80002264:	03248663          	beq	s1,s2,80002290 <wakeup+0x64>
    if (p != myproc())
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	744080e7          	jalr	1860(ra) # 800019ac <myproc>
    80002270:	fea488e3          	beq	s1,a0,80002260 <wakeup+0x34>
      acquire(&p->lock);
    80002274:	8526                	mv	a0,s1
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	960080e7          	jalr	-1696(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000227e:	4c9c                	lw	a5,24(s1)
    80002280:	fd379be3          	bne	a5,s3,80002256 <wakeup+0x2a>
    80002284:	709c                	ld	a5,32(s1)
    80002286:	fd4798e3          	bne	a5,s4,80002256 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000228a:	0154ac23          	sw	s5,24(s1)
    8000228e:	b7e1                	j	80002256 <wakeup+0x2a>
    }
  }
}
    80002290:	70e2                	ld	ra,56(sp)
    80002292:	7442                	ld	s0,48(sp)
    80002294:	74a2                	ld	s1,40(sp)
    80002296:	7902                	ld	s2,32(sp)
    80002298:	69e2                	ld	s3,24(sp)
    8000229a:	6a42                	ld	s4,16(sp)
    8000229c:	6aa2                	ld	s5,8(sp)
    8000229e:	6121                	addi	sp,sp,64
    800022a0:	8082                	ret

00000000800022a2 <reparent>:
{
    800022a2:	7179                	addi	sp,sp,-48
    800022a4:	f406                	sd	ra,40(sp)
    800022a6:	f022                	sd	s0,32(sp)
    800022a8:	ec26                	sd	s1,24(sp)
    800022aa:	e84a                	sd	s2,16(sp)
    800022ac:	e44e                	sd	s3,8(sp)
    800022ae:	e052                	sd	s4,0(sp)
    800022b0:	1800                	addi	s0,sp,48
    800022b2:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800022b4:	0000f497          	auipc	s1,0xf
    800022b8:	cfc48493          	addi	s1,s1,-772 # 80010fb0 <proc>
      pp->parent = initproc;
    800022bc:	00006a17          	auipc	s4,0x6
    800022c0:	64ca0a13          	addi	s4,s4,1612 # 80008908 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800022c4:	00015997          	auipc	s3,0x15
    800022c8:	6ec98993          	addi	s3,s3,1772 # 800179b0 <mlfq>
    800022cc:	a029                	j	800022d6 <reparent+0x34>
    800022ce:	1a848493          	addi	s1,s1,424
    800022d2:	01348d63          	beq	s1,s3,800022ec <reparent+0x4a>
    if (pp->parent == p)
    800022d6:	7c9c                	ld	a5,56(s1)
    800022d8:	ff279be3          	bne	a5,s2,800022ce <reparent+0x2c>
      pp->parent = initproc;
    800022dc:	000a3503          	ld	a0,0(s4)
    800022e0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022e2:	00000097          	auipc	ra,0x0
    800022e6:	f4a080e7          	jalr	-182(ra) # 8000222c <wakeup>
    800022ea:	b7d5                	j	800022ce <reparent+0x2c>
}
    800022ec:	70a2                	ld	ra,40(sp)
    800022ee:	7402                	ld	s0,32(sp)
    800022f0:	64e2                	ld	s1,24(sp)
    800022f2:	6942                	ld	s2,16(sp)
    800022f4:	69a2                	ld	s3,8(sp)
    800022f6:	6a02                	ld	s4,0(sp)
    800022f8:	6145                	addi	sp,sp,48
    800022fa:	8082                	ret

00000000800022fc <exit>:
{
    800022fc:	7179                	addi	sp,sp,-48
    800022fe:	f406                	sd	ra,40(sp)
    80002300:	f022                	sd	s0,32(sp)
    80002302:	ec26                	sd	s1,24(sp)
    80002304:	e84a                	sd	s2,16(sp)
    80002306:	e44e                	sd	s3,8(sp)
    80002308:	e052                	sd	s4,0(sp)
    8000230a:	1800                	addi	s0,sp,48
    8000230c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	69e080e7          	jalr	1694(ra) # 800019ac <myproc>
    80002316:	89aa                	mv	s3,a0
  if (p == initproc)
    80002318:	00006797          	auipc	a5,0x6
    8000231c:	5f07b783          	ld	a5,1520(a5) # 80008908 <initproc>
    80002320:	0d050493          	addi	s1,a0,208
    80002324:	15050913          	addi	s2,a0,336
    80002328:	02a79363          	bne	a5,a0,8000234e <exit+0x52>
    panic("init exiting");
    8000232c:	00006517          	auipc	a0,0x6
    80002330:	f3450513          	addi	a0,a0,-204 # 80008260 <digits+0x220>
    80002334:	ffffe097          	auipc	ra,0xffffe
    80002338:	20c080e7          	jalr	524(ra) # 80000540 <panic>
      fileclose(f);
    8000233c:	00002097          	auipc	ra,0x2
    80002340:	662080e7          	jalr	1634(ra) # 8000499e <fileclose>
      p->ofile[fd] = 0;
    80002344:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002348:	04a1                	addi	s1,s1,8
    8000234a:	01248563          	beq	s1,s2,80002354 <exit+0x58>
    if (p->ofile[fd])
    8000234e:	6088                	ld	a0,0(s1)
    80002350:	f575                	bnez	a0,8000233c <exit+0x40>
    80002352:	bfdd                	j	80002348 <exit+0x4c>
  begin_op();
    80002354:	00002097          	auipc	ra,0x2
    80002358:	182080e7          	jalr	386(ra) # 800044d6 <begin_op>
  iput(p->cwd);
    8000235c:	1509b503          	ld	a0,336(s3)
    80002360:	00002097          	auipc	ra,0x2
    80002364:	964080e7          	jalr	-1692(ra) # 80003cc4 <iput>
  end_op();
    80002368:	00002097          	auipc	ra,0x2
    8000236c:	1ec080e7          	jalr	492(ra) # 80004554 <end_op>
  p->cwd = 0;
    80002370:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002374:	0000f497          	auipc	s1,0xf
    80002378:	82448493          	addi	s1,s1,-2012 # 80010b98 <wait_lock>
    8000237c:	8526                	mv	a0,s1
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	858080e7          	jalr	-1960(ra) # 80000bd6 <acquire>
  reparent(p);
    80002386:	854e                	mv	a0,s3
    80002388:	00000097          	auipc	ra,0x0
    8000238c:	f1a080e7          	jalr	-230(ra) # 800022a2 <reparent>
  wakeup(p->parent);
    80002390:	0389b503          	ld	a0,56(s3)
    80002394:	00000097          	auipc	ra,0x0
    80002398:	e98080e7          	jalr	-360(ra) # 8000222c <wakeup>
  acquire(&p->lock);
    8000239c:	854e                	mv	a0,s3
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	838080e7          	jalr	-1992(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800023a6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023aa:	4795                	li	a5,5
    800023ac:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800023b0:	00006797          	auipc	a5,0x6
    800023b4:	5607a783          	lw	a5,1376(a5) # 80008910 <ticks>
    800023b8:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	8cc080e7          	jalr	-1844(ra) # 80000c8a <release>
  sched();
    800023c6:	00000097          	auipc	ra,0x0
    800023ca:	cf0080e7          	jalr	-784(ra) # 800020b6 <sched>
  panic("zombie exit");
    800023ce:	00006517          	auipc	a0,0x6
    800023d2:	ea250513          	addi	a0,a0,-350 # 80008270 <digits+0x230>
    800023d6:	ffffe097          	auipc	ra,0xffffe
    800023da:	16a080e7          	jalr	362(ra) # 80000540 <panic>

00000000800023de <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800023de:	7179                	addi	sp,sp,-48
    800023e0:	f406                	sd	ra,40(sp)
    800023e2:	f022                	sd	s0,32(sp)
    800023e4:	ec26                	sd	s1,24(sp)
    800023e6:	e84a                	sd	s2,16(sp)
    800023e8:	e44e                	sd	s3,8(sp)
    800023ea:	1800                	addi	s0,sp,48
    800023ec:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023ee:	0000f497          	auipc	s1,0xf
    800023f2:	bc248493          	addi	s1,s1,-1086 # 80010fb0 <proc>
    800023f6:	00015997          	auipc	s3,0x15
    800023fa:	5ba98993          	addi	s3,s3,1466 # 800179b0 <mlfq>
  {
    acquire(&p->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7d6080e7          	jalr	2006(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    80002408:	589c                	lw	a5,48(s1)
    8000240a:	01278d63          	beq	a5,s2,80002424 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	87a080e7          	jalr	-1926(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002418:	1a848493          	addi	s1,s1,424
    8000241c:	ff3491e3          	bne	s1,s3,800023fe <kill+0x20>
  }
  return -1;
    80002420:	557d                	li	a0,-1
    80002422:	a829                	j	8000243c <kill+0x5e>
      p->killed = 1;
    80002424:	4785                	li	a5,1
    80002426:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002428:	4c98                	lw	a4,24(s1)
    8000242a:	4789                	li	a5,2
    8000242c:	00f70f63          	beq	a4,a5,8000244a <kill+0x6c>
      release(&p->lock);
    80002430:	8526                	mv	a0,s1
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
      return 0;
    8000243a:	4501                	li	a0,0
}
    8000243c:	70a2                	ld	ra,40(sp)
    8000243e:	7402                	ld	s0,32(sp)
    80002440:	64e2                	ld	s1,24(sp)
    80002442:	6942                	ld	s2,16(sp)
    80002444:	69a2                	ld	s3,8(sp)
    80002446:	6145                	addi	sp,sp,48
    80002448:	8082                	ret
        p->state = RUNNABLE;
    8000244a:	478d                	li	a5,3
    8000244c:	cc9c                	sw	a5,24(s1)
    8000244e:	b7cd                	j	80002430 <kill+0x52>

0000000080002450 <setkilled>:

void setkilled(struct proc *p)
{
    80002450:	1101                	addi	sp,sp,-32
    80002452:	ec06                	sd	ra,24(sp)
    80002454:	e822                	sd	s0,16(sp)
    80002456:	e426                	sd	s1,8(sp)
    80002458:	1000                	addi	s0,sp,32
    8000245a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000245c:	ffffe097          	auipc	ra,0xffffe
    80002460:	77a080e7          	jalr	1914(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002464:	4785                	li	a5,1
    80002466:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	820080e7          	jalr	-2016(ra) # 80000c8a <release>
}
    80002472:	60e2                	ld	ra,24(sp)
    80002474:	6442                	ld	s0,16(sp)
    80002476:	64a2                	ld	s1,8(sp)
    80002478:	6105                	addi	sp,sp,32
    8000247a:	8082                	ret

000000008000247c <killed>:

int killed(struct proc *p)
{
    8000247c:	1101                	addi	sp,sp,-32
    8000247e:	ec06                	sd	ra,24(sp)
    80002480:	e822                	sd	s0,16(sp)
    80002482:	e426                	sd	s1,8(sp)
    80002484:	e04a                	sd	s2,0(sp)
    80002486:	1000                	addi	s0,sp,32
    80002488:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000248a:	ffffe097          	auipc	ra,0xffffe
    8000248e:	74c080e7          	jalr	1868(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002492:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002496:	8526                	mv	a0,s1
    80002498:	ffffe097          	auipc	ra,0xffffe
    8000249c:	7f2080e7          	jalr	2034(ra) # 80000c8a <release>
  return k;
}
    800024a0:	854a                	mv	a0,s2
    800024a2:	60e2                	ld	ra,24(sp)
    800024a4:	6442                	ld	s0,16(sp)
    800024a6:	64a2                	ld	s1,8(sp)
    800024a8:	6902                	ld	s2,0(sp)
    800024aa:	6105                	addi	sp,sp,32
    800024ac:	8082                	ret

00000000800024ae <wait>:
{
    800024ae:	715d                	addi	sp,sp,-80
    800024b0:	e486                	sd	ra,72(sp)
    800024b2:	e0a2                	sd	s0,64(sp)
    800024b4:	fc26                	sd	s1,56(sp)
    800024b6:	f84a                	sd	s2,48(sp)
    800024b8:	f44e                	sd	s3,40(sp)
    800024ba:	f052                	sd	s4,32(sp)
    800024bc:	ec56                	sd	s5,24(sp)
    800024be:	e85a                	sd	s6,16(sp)
    800024c0:	e45e                	sd	s7,8(sp)
    800024c2:	e062                	sd	s8,0(sp)
    800024c4:	0880                	addi	s0,sp,80
    800024c6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	4e4080e7          	jalr	1252(ra) # 800019ac <myproc>
    800024d0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024d2:	0000e517          	auipc	a0,0xe
    800024d6:	6c650513          	addi	a0,a0,1734 # 80010b98 <wait_lock>
    800024da:	ffffe097          	auipc	ra,0xffffe
    800024de:	6fc080e7          	jalr	1788(ra) # 80000bd6 <acquire>
    havekids = 0;
    800024e2:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800024e4:	4a15                	li	s4,5
        havekids = 1;
    800024e6:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024e8:	00015997          	auipc	s3,0x15
    800024ec:	4c898993          	addi	s3,s3,1224 # 800179b0 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024f0:	0000ec17          	auipc	s8,0xe
    800024f4:	6a8c0c13          	addi	s8,s8,1704 # 80010b98 <wait_lock>
    havekids = 0;
    800024f8:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024fa:	0000f497          	auipc	s1,0xf
    800024fe:	ab648493          	addi	s1,s1,-1354 # 80010fb0 <proc>
    80002502:	a0bd                	j	80002570 <wait+0xc2>
          pid = pp->pid;
    80002504:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002508:	000b0e63          	beqz	s6,80002524 <wait+0x76>
    8000250c:	4691                	li	a3,4
    8000250e:	02c48613          	addi	a2,s1,44
    80002512:	85da                	mv	a1,s6
    80002514:	05093503          	ld	a0,80(s2)
    80002518:	fffff097          	auipc	ra,0xfffff
    8000251c:	154080e7          	jalr	340(ra) # 8000166c <copyout>
    80002520:	02054563          	bltz	a0,8000254a <wait+0x9c>
          freeproc(pp);
    80002524:	8526                	mv	a0,s1
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	638080e7          	jalr	1592(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    8000252e:	8526                	mv	a0,s1
    80002530:	ffffe097          	auipc	ra,0xffffe
    80002534:	75a080e7          	jalr	1882(ra) # 80000c8a <release>
          release(&wait_lock);
    80002538:	0000e517          	auipc	a0,0xe
    8000253c:	66050513          	addi	a0,a0,1632 # 80010b98 <wait_lock>
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	74a080e7          	jalr	1866(ra) # 80000c8a <release>
          return pid;
    80002548:	a0b5                	j	800025b4 <wait+0x106>
            release(&pp->lock);
    8000254a:	8526                	mv	a0,s1
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	73e080e7          	jalr	1854(ra) # 80000c8a <release>
            release(&wait_lock);
    80002554:	0000e517          	auipc	a0,0xe
    80002558:	64450513          	addi	a0,a0,1604 # 80010b98 <wait_lock>
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	72e080e7          	jalr	1838(ra) # 80000c8a <release>
            return -1;
    80002564:	59fd                	li	s3,-1
    80002566:	a0b9                	j	800025b4 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002568:	1a848493          	addi	s1,s1,424
    8000256c:	03348463          	beq	s1,s3,80002594 <wait+0xe6>
      if (pp->parent == p)
    80002570:	7c9c                	ld	a5,56(s1)
    80002572:	ff279be3          	bne	a5,s2,80002568 <wait+0xba>
        acquire(&pp->lock);
    80002576:	8526                	mv	a0,s1
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	65e080e7          	jalr	1630(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    80002580:	4c9c                	lw	a5,24(s1)
    80002582:	f94781e3          	beq	a5,s4,80002504 <wait+0x56>
        release(&pp->lock);
    80002586:	8526                	mv	a0,s1
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	702080e7          	jalr	1794(ra) # 80000c8a <release>
        havekids = 1;
    80002590:	8756                	mv	a4,s5
    80002592:	bfd9                	j	80002568 <wait+0xba>
    if (!havekids || killed(p))
    80002594:	c719                	beqz	a4,800025a2 <wait+0xf4>
    80002596:	854a                	mv	a0,s2
    80002598:	00000097          	auipc	ra,0x0
    8000259c:	ee4080e7          	jalr	-284(ra) # 8000247c <killed>
    800025a0:	c51d                	beqz	a0,800025ce <wait+0x120>
      release(&wait_lock);
    800025a2:	0000e517          	auipc	a0,0xe
    800025a6:	5f650513          	addi	a0,a0,1526 # 80010b98 <wait_lock>
    800025aa:	ffffe097          	auipc	ra,0xffffe
    800025ae:	6e0080e7          	jalr	1760(ra) # 80000c8a <release>
      return -1;
    800025b2:	59fd                	li	s3,-1
}
    800025b4:	854e                	mv	a0,s3
    800025b6:	60a6                	ld	ra,72(sp)
    800025b8:	6406                	ld	s0,64(sp)
    800025ba:	74e2                	ld	s1,56(sp)
    800025bc:	7942                	ld	s2,48(sp)
    800025be:	79a2                	ld	s3,40(sp)
    800025c0:	7a02                	ld	s4,32(sp)
    800025c2:	6ae2                	ld	s5,24(sp)
    800025c4:	6b42                	ld	s6,16(sp)
    800025c6:	6ba2                	ld	s7,8(sp)
    800025c8:	6c02                	ld	s8,0(sp)
    800025ca:	6161                	addi	sp,sp,80
    800025cc:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800025ce:	85e2                	mv	a1,s8
    800025d0:	854a                	mv	a0,s2
    800025d2:	00000097          	auipc	ra,0x0
    800025d6:	bf6080e7          	jalr	-1034(ra) # 800021c8 <sleep>
    havekids = 0;
    800025da:	bf39                	j	800024f8 <wait+0x4a>

00000000800025dc <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025dc:	7179                	addi	sp,sp,-48
    800025de:	f406                	sd	ra,40(sp)
    800025e0:	f022                	sd	s0,32(sp)
    800025e2:	ec26                	sd	s1,24(sp)
    800025e4:	e84a                	sd	s2,16(sp)
    800025e6:	e44e                	sd	s3,8(sp)
    800025e8:	e052                	sd	s4,0(sp)
    800025ea:	1800                	addi	s0,sp,48
    800025ec:	84aa                	mv	s1,a0
    800025ee:	892e                	mv	s2,a1
    800025f0:	89b2                	mv	s3,a2
    800025f2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	3b8080e7          	jalr	952(ra) # 800019ac <myproc>
  if (user_dst)
    800025fc:	c08d                	beqz	s1,8000261e <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800025fe:	86d2                	mv	a3,s4
    80002600:	864e                	mv	a2,s3
    80002602:	85ca                	mv	a1,s2
    80002604:	6928                	ld	a0,80(a0)
    80002606:	fffff097          	auipc	ra,0xfffff
    8000260a:	066080e7          	jalr	102(ra) # 8000166c <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000260e:	70a2                	ld	ra,40(sp)
    80002610:	7402                	ld	s0,32(sp)
    80002612:	64e2                	ld	s1,24(sp)
    80002614:	6942                	ld	s2,16(sp)
    80002616:	69a2                	ld	s3,8(sp)
    80002618:	6a02                	ld	s4,0(sp)
    8000261a:	6145                	addi	sp,sp,48
    8000261c:	8082                	ret
    memmove((char *)dst, src, len);
    8000261e:	000a061b          	sext.w	a2,s4
    80002622:	85ce                	mv	a1,s3
    80002624:	854a                	mv	a0,s2
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	708080e7          	jalr	1800(ra) # 80000d2e <memmove>
    return 0;
    8000262e:	8526                	mv	a0,s1
    80002630:	bff9                	j	8000260e <either_copyout+0x32>

0000000080002632 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002632:	7179                	addi	sp,sp,-48
    80002634:	f406                	sd	ra,40(sp)
    80002636:	f022                	sd	s0,32(sp)
    80002638:	ec26                	sd	s1,24(sp)
    8000263a:	e84a                	sd	s2,16(sp)
    8000263c:	e44e                	sd	s3,8(sp)
    8000263e:	e052                	sd	s4,0(sp)
    80002640:	1800                	addi	s0,sp,48
    80002642:	892a                	mv	s2,a0
    80002644:	84ae                	mv	s1,a1
    80002646:	89b2                	mv	s3,a2
    80002648:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000264a:	fffff097          	auipc	ra,0xfffff
    8000264e:	362080e7          	jalr	866(ra) # 800019ac <myproc>
  if (user_src)
    80002652:	c08d                	beqz	s1,80002674 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002654:	86d2                	mv	a3,s4
    80002656:	864e                	mv	a2,s3
    80002658:	85ca                	mv	a1,s2
    8000265a:	6928                	ld	a0,80(a0)
    8000265c:	fffff097          	auipc	ra,0xfffff
    80002660:	09c080e7          	jalr	156(ra) # 800016f8 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002664:	70a2                	ld	ra,40(sp)
    80002666:	7402                	ld	s0,32(sp)
    80002668:	64e2                	ld	s1,24(sp)
    8000266a:	6942                	ld	s2,16(sp)
    8000266c:	69a2                	ld	s3,8(sp)
    8000266e:	6a02                	ld	s4,0(sp)
    80002670:	6145                	addi	sp,sp,48
    80002672:	8082                	ret
    memmove(dst, (char *)src, len);
    80002674:	000a061b          	sext.w	a2,s4
    80002678:	85ce                	mv	a1,s3
    8000267a:	854a                	mv	a0,s2
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	6b2080e7          	jalr	1714(ra) # 80000d2e <memmove>
    return 0;
    80002684:	8526                	mv	a0,s1
    80002686:	bff9                	j	80002664 <either_copyin+0x32>

0000000080002688 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002688:	715d                	addi	sp,sp,-80
    8000268a:	e486                	sd	ra,72(sp)
    8000268c:	e0a2                	sd	s0,64(sp)
    8000268e:	fc26                	sd	s1,56(sp)
    80002690:	f84a                	sd	s2,48(sp)
    80002692:	f44e                	sd	s3,40(sp)
    80002694:	f052                	sd	s4,32(sp)
    80002696:	ec56                	sd	s5,24(sp)
    80002698:	e85a                	sd	s6,16(sp)
    8000269a:	e45e                	sd	s7,8(sp)
    8000269c:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000269e:	00006517          	auipc	a0,0x6
    800026a2:	a2a50513          	addi	a0,a0,-1494 # 800080c8 <digits+0x88>
    800026a6:	ffffe097          	auipc	ra,0xffffe
    800026aa:	ee4080e7          	jalr	-284(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026ae:	0000f497          	auipc	s1,0xf
    800026b2:	a5a48493          	addi	s1,s1,-1446 # 80011108 <proc+0x158>
    800026b6:	00015917          	auipc	s2,0x15
    800026ba:	45290913          	addi	s2,s2,1106 # 80017b08 <mlfq+0x158>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026be:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800026c0:	00006997          	auipc	s3,0x6
    800026c4:	bc098993          	addi	s3,s3,-1088 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800026c8:	00006a97          	auipc	s5,0x6
    800026cc:	bc0a8a93          	addi	s5,s5,-1088 # 80008288 <digits+0x248>
    printf("\n");
    800026d0:	00006a17          	auipc	s4,0x6
    800026d4:	9f8a0a13          	addi	s4,s4,-1544 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026d8:	00006b97          	auipc	s7,0x6
    800026dc:	bf0b8b93          	addi	s7,s7,-1040 # 800082c8 <states.0>
    800026e0:	a00d                	j	80002702 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026e2:	ed86a583          	lw	a1,-296(a3)
    800026e6:	8556                	mv	a0,s5
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	ea2080e7          	jalr	-350(ra) # 8000058a <printf>
    printf("\n");
    800026f0:	8552                	mv	a0,s4
    800026f2:	ffffe097          	auipc	ra,0xffffe
    800026f6:	e98080e7          	jalr	-360(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026fa:	1a848493          	addi	s1,s1,424
    800026fe:	03248263          	beq	s1,s2,80002722 <procdump+0x9a>
    if (p->state == UNUSED)
    80002702:	86a6                	mv	a3,s1
    80002704:	ec04a783          	lw	a5,-320(s1)
    80002708:	dbed                	beqz	a5,800026fa <procdump+0x72>
      state = "???";
    8000270a:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000270c:	fcfb6be3          	bltu	s6,a5,800026e2 <procdump+0x5a>
    80002710:	02079713          	slli	a4,a5,0x20
    80002714:	01d75793          	srli	a5,a4,0x1d
    80002718:	97de                	add	a5,a5,s7
    8000271a:	6390                	ld	a2,0(a5)
    8000271c:	f279                	bnez	a2,800026e2 <procdump+0x5a>
      state = "???";
    8000271e:	864e                	mv	a2,s3
    80002720:	b7c9                	j	800026e2 <procdump+0x5a>
  }
}
    80002722:	60a6                	ld	ra,72(sp)
    80002724:	6406                	ld	s0,64(sp)
    80002726:	74e2                	ld	s1,56(sp)
    80002728:	7942                	ld	s2,48(sp)
    8000272a:	79a2                	ld	s3,40(sp)
    8000272c:	7a02                	ld	s4,32(sp)
    8000272e:	6ae2                	ld	s5,24(sp)
    80002730:	6b42                	ld	s6,16(sp)
    80002732:	6ba2                	ld	s7,8(sp)
    80002734:	6161                	addi	sp,sp,80
    80002736:	8082                	ret

0000000080002738 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002738:	711d                	addi	sp,sp,-96
    8000273a:	ec86                	sd	ra,88(sp)
    8000273c:	e8a2                	sd	s0,80(sp)
    8000273e:	e4a6                	sd	s1,72(sp)
    80002740:	e0ca                	sd	s2,64(sp)
    80002742:	fc4e                	sd	s3,56(sp)
    80002744:	f852                	sd	s4,48(sp)
    80002746:	f456                	sd	s5,40(sp)
    80002748:	f05a                	sd	s6,32(sp)
    8000274a:	ec5e                	sd	s7,24(sp)
    8000274c:	e862                	sd	s8,16(sp)
    8000274e:	e466                	sd	s9,8(sp)
    80002750:	e06a                	sd	s10,0(sp)
    80002752:	1080                	addi	s0,sp,96
    80002754:	8b2a                	mv	s6,a0
    80002756:	8bae                	mv	s7,a1
    80002758:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000275a:	fffff097          	auipc	ra,0xfffff
    8000275e:	252080e7          	jalr	594(ra) # 800019ac <myproc>
    80002762:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002764:	0000e517          	auipc	a0,0xe
    80002768:	43450513          	addi	a0,a0,1076 # 80010b98 <wait_lock>
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	46a080e7          	jalr	1130(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002774:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002776:	4a15                	li	s4,5
        havekids = 1;
    80002778:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    8000277a:	00015997          	auipc	s3,0x15
    8000277e:	23698993          	addi	s3,s3,566 # 800179b0 <mlfq>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002782:	0000ed17          	auipc	s10,0xe
    80002786:	416d0d13          	addi	s10,s10,1046 # 80010b98 <wait_lock>
    havekids = 0;
    8000278a:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    8000278c:	0000f497          	auipc	s1,0xf
    80002790:	82448493          	addi	s1,s1,-2012 # 80010fb0 <proc>
    80002794:	a059                	j	8000281a <waitx+0xe2>
          pid = np->pid;
    80002796:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000279a:	1684a783          	lw	a5,360(s1)
    8000279e:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800027a2:	16c4a703          	lw	a4,364(s1)
    800027a6:	9f3d                	addw	a4,a4,a5
    800027a8:	1704a783          	lw	a5,368(s1)
    800027ac:	9f99                	subw	a5,a5,a4
    800027ae:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800027b2:	000b0e63          	beqz	s6,800027ce <waitx+0x96>
    800027b6:	4691                	li	a3,4
    800027b8:	02c48613          	addi	a2,s1,44
    800027bc:	85da                	mv	a1,s6
    800027be:	05093503          	ld	a0,80(s2)
    800027c2:	fffff097          	auipc	ra,0xfffff
    800027c6:	eaa080e7          	jalr	-342(ra) # 8000166c <copyout>
    800027ca:	02054563          	bltz	a0,800027f4 <waitx+0xbc>
          freeproc(np);
    800027ce:	8526                	mv	a0,s1
    800027d0:	fffff097          	auipc	ra,0xfffff
    800027d4:	38e080e7          	jalr	910(ra) # 80001b5e <freeproc>
          release(&np->lock);
    800027d8:	8526                	mv	a0,s1
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	4b0080e7          	jalr	1200(ra) # 80000c8a <release>
          release(&wait_lock);
    800027e2:	0000e517          	auipc	a0,0xe
    800027e6:	3b650513          	addi	a0,a0,950 # 80010b98 <wait_lock>
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	4a0080e7          	jalr	1184(ra) # 80000c8a <release>
          return pid;
    800027f2:	a09d                	j	80002858 <waitx+0x120>
            release(&np->lock);
    800027f4:	8526                	mv	a0,s1
    800027f6:	ffffe097          	auipc	ra,0xffffe
    800027fa:	494080e7          	jalr	1172(ra) # 80000c8a <release>
            release(&wait_lock);
    800027fe:	0000e517          	auipc	a0,0xe
    80002802:	39a50513          	addi	a0,a0,922 # 80010b98 <wait_lock>
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	484080e7          	jalr	1156(ra) # 80000c8a <release>
            return -1;
    8000280e:	59fd                	li	s3,-1
    80002810:	a0a1                	j	80002858 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002812:	1a848493          	addi	s1,s1,424
    80002816:	03348463          	beq	s1,s3,8000283e <waitx+0x106>
      if (np->parent == p)
    8000281a:	7c9c                	ld	a5,56(s1)
    8000281c:	ff279be3          	bne	a5,s2,80002812 <waitx+0xda>
        acquire(&np->lock);
    80002820:	8526                	mv	a0,s1
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	3b4080e7          	jalr	948(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    8000282a:	4c9c                	lw	a5,24(s1)
    8000282c:	f74785e3          	beq	a5,s4,80002796 <waitx+0x5e>
        release(&np->lock);
    80002830:	8526                	mv	a0,s1
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	458080e7          	jalr	1112(ra) # 80000c8a <release>
        havekids = 1;
    8000283a:	8756                	mv	a4,s5
    8000283c:	bfd9                	j	80002812 <waitx+0xda>
    if (!havekids || p->killed)
    8000283e:	c701                	beqz	a4,80002846 <waitx+0x10e>
    80002840:	02892783          	lw	a5,40(s2)
    80002844:	cb8d                	beqz	a5,80002876 <waitx+0x13e>
      release(&wait_lock);
    80002846:	0000e517          	auipc	a0,0xe
    8000284a:	35250513          	addi	a0,a0,850 # 80010b98 <wait_lock>
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	43c080e7          	jalr	1084(ra) # 80000c8a <release>
      return -1;
    80002856:	59fd                	li	s3,-1
  }
}
    80002858:	854e                	mv	a0,s3
    8000285a:	60e6                	ld	ra,88(sp)
    8000285c:	6446                	ld	s0,80(sp)
    8000285e:	64a6                	ld	s1,72(sp)
    80002860:	6906                	ld	s2,64(sp)
    80002862:	79e2                	ld	s3,56(sp)
    80002864:	7a42                	ld	s4,48(sp)
    80002866:	7aa2                	ld	s5,40(sp)
    80002868:	7b02                	ld	s6,32(sp)
    8000286a:	6be2                	ld	s7,24(sp)
    8000286c:	6c42                	ld	s8,16(sp)
    8000286e:	6ca2                	ld	s9,8(sp)
    80002870:	6d02                	ld	s10,0(sp)
    80002872:	6125                	addi	sp,sp,96
    80002874:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002876:	85ea                	mv	a1,s10
    80002878:	854a                	mv	a0,s2
    8000287a:	00000097          	auipc	ra,0x0
    8000287e:	94e080e7          	jalr	-1714(ra) # 800021c8 <sleep>
    havekids = 0;
    80002882:	b721                	j	8000278a <waitx+0x52>

0000000080002884 <update_time>:

void update_time()
{
    80002884:	7179                	addi	sp,sp,-48
    80002886:	f406                	sd	ra,40(sp)
    80002888:	f022                	sd	s0,32(sp)
    8000288a:	ec26                	sd	s1,24(sp)
    8000288c:	e84a                	sd	s2,16(sp)
    8000288e:	e44e                	sd	s3,8(sp)
    80002890:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002892:	0000e497          	auipc	s1,0xe
    80002896:	71e48493          	addi	s1,s1,1822 # 80010fb0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    8000289a:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    8000289c:	00015917          	auipc	s2,0x15
    800028a0:	11490913          	addi	s2,s2,276 # 800179b0 <mlfq>
    800028a4:	a811                	j	800028b8 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    800028a6:	8526                	mv	a0,s1
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	3e2080e7          	jalr	994(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800028b0:	1a848493          	addi	s1,s1,424
    800028b4:	03248063          	beq	s1,s2,800028d4 <update_time+0x50>
    acquire(&p->lock);
    800028b8:	8526                	mv	a0,s1
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	31c080e7          	jalr	796(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    800028c2:	4c9c                	lw	a5,24(s1)
    800028c4:	ff3791e3          	bne	a5,s3,800028a6 <update_time+0x22>
      p->rtime++;
    800028c8:	1684a783          	lw	a5,360(s1)
    800028cc:	2785                	addiw	a5,a5,1
    800028ce:	16f4a423          	sw	a5,360(s1)
    800028d2:	bfd1                	j	800028a6 <update_time+0x22>
  }
    800028d4:	70a2                	ld	ra,40(sp)
    800028d6:	7402                	ld	s0,32(sp)
    800028d8:	64e2                	ld	s1,24(sp)
    800028da:	6942                	ld	s2,16(sp)
    800028dc:	69a2                	ld	s3,8(sp)
    800028de:	6145                	addi	sp,sp,48
    800028e0:	8082                	ret

00000000800028e2 <swtch>:
    800028e2:	00153023          	sd	ra,0(a0)
    800028e6:	00253423          	sd	sp,8(a0)
    800028ea:	e900                	sd	s0,16(a0)
    800028ec:	ed04                	sd	s1,24(a0)
    800028ee:	03253023          	sd	s2,32(a0)
    800028f2:	03353423          	sd	s3,40(a0)
    800028f6:	03453823          	sd	s4,48(a0)
    800028fa:	03553c23          	sd	s5,56(a0)
    800028fe:	05653023          	sd	s6,64(a0)
    80002902:	05753423          	sd	s7,72(a0)
    80002906:	05853823          	sd	s8,80(a0)
    8000290a:	05953c23          	sd	s9,88(a0)
    8000290e:	07a53023          	sd	s10,96(a0)
    80002912:	07b53423          	sd	s11,104(a0)
    80002916:	0005b083          	ld	ra,0(a1)
    8000291a:	0085b103          	ld	sp,8(a1)
    8000291e:	6980                	ld	s0,16(a1)
    80002920:	6d84                	ld	s1,24(a1)
    80002922:	0205b903          	ld	s2,32(a1)
    80002926:	0285b983          	ld	s3,40(a1)
    8000292a:	0305ba03          	ld	s4,48(a1)
    8000292e:	0385ba83          	ld	s5,56(a1)
    80002932:	0405bb03          	ld	s6,64(a1)
    80002936:	0485bb83          	ld	s7,72(a1)
    8000293a:	0505bc03          	ld	s8,80(a1)
    8000293e:	0585bc83          	ld	s9,88(a1)
    80002942:	0605bd03          	ld	s10,96(a1)
    80002946:	0685bd83          	ld	s11,104(a1)
    8000294a:	8082                	ret

000000008000294c <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000294c:	1141                	addi	sp,sp,-16
    8000294e:	e406                	sd	ra,8(sp)
    80002950:	e022                	sd	s0,0(sp)
    80002952:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002954:	00006597          	auipc	a1,0x6
    80002958:	9a458593          	addi	a1,a1,-1628 # 800082f8 <states.0+0x30>
    8000295c:	00016517          	auipc	a0,0x16
    80002960:	87450513          	addi	a0,a0,-1932 # 800181d0 <tickslock>
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	1e2080e7          	jalr	482(ra) # 80000b46 <initlock>
}
    8000296c:	60a2                	ld	ra,8(sp)
    8000296e:	6402                	ld	s0,0(sp)
    80002970:	0141                	addi	sp,sp,16
    80002972:	8082                	ret

0000000080002974 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002974:	1141                	addi	sp,sp,-16
    80002976:	e422                	sd	s0,8(sp)
    80002978:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0"
    8000297a:	00003797          	auipc	a5,0x3
    8000297e:	67678793          	addi	a5,a5,1654 # 80005ff0 <kernelvec>
    80002982:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002986:	6422                	ld	s0,8(sp)
    80002988:	0141                	addi	sp,sp,16
    8000298a:	8082                	ret

000000008000298c <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    8000298c:	1141                	addi	sp,sp,-16
    8000298e:	e406                	sd	ra,8(sp)
    80002990:	e022                	sd	s0,0(sp)
    80002992:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002994:	fffff097          	auipc	ra,0xfffff
    80002998:	018080e7          	jalr	24(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus"
    8000299c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029a0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    800029a2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029a6:	00004697          	auipc	a3,0x4
    800029aa:	65a68693          	addi	a3,a3,1626 # 80007000 <_trampoline>
    800029ae:	00004717          	auipc	a4,0x4
    800029b2:	65270713          	addi	a4,a4,1618 # 80007000 <_trampoline>
    800029b6:	8f15                	sub	a4,a4,a3
    800029b8:	040007b7          	lui	a5,0x4000
    800029bc:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800029be:	07b2                	slli	a5,a5,0xc
    800029c0:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0"
    800029c2:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029c6:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp"
    800029c8:	18002673          	csrr	a2,satp
    800029cc:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029ce:	6d30                	ld	a2,88(a0)
    800029d0:	6138                	ld	a4,64(a0)
    800029d2:	6585                	lui	a1,0x1
    800029d4:	972e                	add	a4,a4,a1
    800029d6:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029d8:	6d38                	ld	a4,88(a0)
    800029da:	00000617          	auipc	a2,0x0
    800029de:	13e60613          	addi	a2,a2,318 # 80002b18 <usertrap>
    800029e2:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800029e4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp"
    800029e6:	8612                	mv	a2,tp
    800029e8:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus"
    800029ea:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029ee:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029f2:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0"
    800029f6:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029fa:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0"
    800029fc:	6f18                	ld	a4,24(a4)
    800029fe:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a02:	6928                	ld	a0,80(a0)
    80002a04:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a06:	00004717          	auipc	a4,0x4
    80002a0a:	69670713          	addi	a4,a4,1686 # 8000709c <userret>
    80002a0e:	8f15                	sub	a4,a4,a3
    80002a10:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002a12:	577d                	li	a4,-1
    80002a14:	177e                	slli	a4,a4,0x3f
    80002a16:	8d59                	or	a0,a0,a4
    80002a18:	9782                	jalr	a5
}
    80002a1a:	60a2                	ld	ra,8(sp)
    80002a1c:	6402                	ld	s0,0(sp)
    80002a1e:	0141                	addi	sp,sp,16
    80002a20:	8082                	ret

0000000080002a22 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002a22:	1101                	addi	sp,sp,-32
    80002a24:	ec06                	sd	ra,24(sp)
    80002a26:	e822                	sd	s0,16(sp)
    80002a28:	e426                	sd	s1,8(sp)
    80002a2a:	e04a                	sd	s2,0(sp)
    80002a2c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a2e:	00015917          	auipc	s2,0x15
    80002a32:	7a290913          	addi	s2,s2,1954 # 800181d0 <tickslock>
    80002a36:	854a                	mv	a0,s2
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	19e080e7          	jalr	414(ra) # 80000bd6 <acquire>
  ticks++;
    80002a40:	00006497          	auipc	s1,0x6
    80002a44:	ed048493          	addi	s1,s1,-304 # 80008910 <ticks>
    80002a48:	409c                	lw	a5,0(s1)
    80002a4a:	2785                	addiw	a5,a5,1
    80002a4c:	c09c                	sw	a5,0(s1)
  update_time();
    80002a4e:	00000097          	auipc	ra,0x0
    80002a52:	e36080e7          	jalr	-458(ra) # 80002884 <update_time>
  // if (myproc() != 0)
  // {
  //   myproc()->change_queue--;
  // }
  wakeup(&ticks);
    80002a56:	8526                	mv	a0,s1
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	7d4080e7          	jalr	2004(ra) # 8000222c <wakeup>
  release(&tickslock);
    80002a60:	854a                	mv	a0,s2
    80002a62:	ffffe097          	auipc	ra,0xffffe
    80002a66:	228080e7          	jalr	552(ra) # 80000c8a <release>
}
    80002a6a:	60e2                	ld	ra,24(sp)
    80002a6c:	6442                	ld	s0,16(sp)
    80002a6e:	64a2                	ld	s1,8(sp)
    80002a70:	6902                	ld	s2,0(sp)
    80002a72:	6105                	addi	sp,sp,32
    80002a74:	8082                	ret

0000000080002a76 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002a76:	1101                	addi	sp,sp,-32
    80002a78:	ec06                	sd	ra,24(sp)
    80002a7a:	e822                	sd	s0,16(sp)
    80002a7c:	e426                	sd	s1,8(sp)
    80002a7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause"
    80002a80:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002a84:	00074d63          	bltz	a4,80002a9e <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002a88:	57fd                	li	a5,-1
    80002a8a:	17fe                	slli	a5,a5,0x3f
    80002a8c:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002a8e:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002a90:	06f70363          	beq	a4,a5,80002af6 <devintr+0x80>
  }
}
    80002a94:	60e2                	ld	ra,24(sp)
    80002a96:	6442                	ld	s0,16(sp)
    80002a98:	64a2                	ld	s1,8(sp)
    80002a9a:	6105                	addi	sp,sp,32
    80002a9c:	8082                	ret
      (scause & 0xff) == 9)
    80002a9e:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002aa2:	46a5                	li	a3,9
    80002aa4:	fed792e3          	bne	a5,a3,80002a88 <devintr+0x12>
    int irq = plic_claim();
    80002aa8:	00003097          	auipc	ra,0x3
    80002aac:	650080e7          	jalr	1616(ra) # 800060f8 <plic_claim>
    80002ab0:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002ab2:	47a9                	li	a5,10
    80002ab4:	02f50763          	beq	a0,a5,80002ae2 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002ab8:	4785                	li	a5,1
    80002aba:	02f50963          	beq	a0,a5,80002aec <devintr+0x76>
    return 1;
    80002abe:	4505                	li	a0,1
    else if (irq)
    80002ac0:	d8f1                	beqz	s1,80002a94 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ac2:	85a6                	mv	a1,s1
    80002ac4:	00006517          	auipc	a0,0x6
    80002ac8:	83c50513          	addi	a0,a0,-1988 # 80008300 <states.0+0x38>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	abe080e7          	jalr	-1346(ra) # 8000058a <printf>
      plic_complete(irq);
    80002ad4:	8526                	mv	a0,s1
    80002ad6:	00003097          	auipc	ra,0x3
    80002ada:	646080e7          	jalr	1606(ra) # 8000611c <plic_complete>
    return 1;
    80002ade:	4505                	li	a0,1
    80002ae0:	bf55                	j	80002a94 <devintr+0x1e>
      uartintr();
    80002ae2:	ffffe097          	auipc	ra,0xffffe
    80002ae6:	eb6080e7          	jalr	-330(ra) # 80000998 <uartintr>
    80002aea:	b7ed                	j	80002ad4 <devintr+0x5e>
      virtio_disk_intr();
    80002aec:	00004097          	auipc	ra,0x4
    80002af0:	bde080e7          	jalr	-1058(ra) # 800066ca <virtio_disk_intr>
    80002af4:	b7c5                	j	80002ad4 <devintr+0x5e>
    if (cpuid() == 0)
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	e8a080e7          	jalr	-374(ra) # 80001980 <cpuid>
    80002afe:	c901                	beqz	a0,80002b0e <devintr+0x98>
  asm volatile("csrr %0, sip"
    80002b00:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b04:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0"
    80002b06:	14479073          	csrw	sip,a5
    return 2;
    80002b0a:	4509                	li	a0,2
    80002b0c:	b761                	j	80002a94 <devintr+0x1e>
      clockintr();
    80002b0e:	00000097          	auipc	ra,0x0
    80002b12:	f14080e7          	jalr	-236(ra) # 80002a22 <clockintr>
    80002b16:	b7ed                	j	80002b00 <devintr+0x8a>

0000000080002b18 <usertrap>:
{
    80002b18:	1101                	addi	sp,sp,-32
    80002b1a:	ec06                	sd	ra,24(sp)
    80002b1c:	e822                	sd	s0,16(sp)
    80002b1e:	e426                	sd	s1,8(sp)
    80002b20:	e04a                	sd	s2,0(sp)
    80002b22:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80002b24:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002b28:	1007f793          	andi	a5,a5,256
    80002b2c:	e3b1                	bnez	a5,80002b70 <usertrap+0x58>
  asm volatile("csrw stvec, %0"
    80002b2e:	00003797          	auipc	a5,0x3
    80002b32:	4c278793          	addi	a5,a5,1218 # 80005ff0 <kernelvec>
    80002b36:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b3a:	fffff097          	auipc	ra,0xfffff
    80002b3e:	e72080e7          	jalr	-398(ra) # 800019ac <myproc>
    80002b42:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b44:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc"
    80002b46:	14102773          	csrr	a4,sepc
    80002b4a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause"
    80002b4c:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002b50:	47a1                	li	a5,8
    80002b52:	02f70763          	beq	a4,a5,80002b80 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	f20080e7          	jalr	-224(ra) # 80002a76 <devintr>
    80002b5e:	892a                	mv	s2,a0
    80002b60:	c92d                	beqz	a0,80002bd2 <usertrap+0xba>
  if (killed(p))
    80002b62:	8526                	mv	a0,s1
    80002b64:	00000097          	auipc	ra,0x0
    80002b68:	918080e7          	jalr	-1768(ra) # 8000247c <killed>
    80002b6c:	c555                	beqz	a0,80002c18 <usertrap+0x100>
    80002b6e:	a045                	j	80002c0e <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002b70:	00005517          	auipc	a0,0x5
    80002b74:	7b050513          	addi	a0,a0,1968 # 80008320 <states.0+0x58>
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	9c8080e7          	jalr	-1592(ra) # 80000540 <panic>
    if (killed(p))
    80002b80:	00000097          	auipc	ra,0x0
    80002b84:	8fc080e7          	jalr	-1796(ra) # 8000247c <killed>
    80002b88:	ed1d                	bnez	a0,80002bc6 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002b8a:	6cb8                	ld	a4,88(s1)
    80002b8c:	6f1c                	ld	a5,24(a4)
    80002b8e:	0791                	addi	a5,a5,4
    80002b90:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus"
    80002b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002b9a:	10079073          	csrw	sstatus,a5
    syscall();
    80002b9e:	00000097          	auipc	ra,0x0
    80002ba2:	340080e7          	jalr	832(ra) # 80002ede <syscall>
  if (killed(p))
    80002ba6:	8526                	mv	a0,s1
    80002ba8:	00000097          	auipc	ra,0x0
    80002bac:	8d4080e7          	jalr	-1836(ra) # 8000247c <killed>
    80002bb0:	ed31                	bnez	a0,80002c0c <usertrap+0xf4>
  usertrapret();
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	dda080e7          	jalr	-550(ra) # 8000298c <usertrapret>
}
    80002bba:	60e2                	ld	ra,24(sp)
    80002bbc:	6442                	ld	s0,16(sp)
    80002bbe:	64a2                	ld	s1,8(sp)
    80002bc0:	6902                	ld	s2,0(sp)
    80002bc2:	6105                	addi	sp,sp,32
    80002bc4:	8082                	ret
      exit(-1);
    80002bc6:	557d                	li	a0,-1
    80002bc8:	fffff097          	auipc	ra,0xfffff
    80002bcc:	734080e7          	jalr	1844(ra) # 800022fc <exit>
    80002bd0:	bf6d                	j	80002b8a <usertrap+0x72>
  asm volatile("csrr %0, scause"
    80002bd2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bd6:	5890                	lw	a2,48(s1)
    80002bd8:	00005517          	auipc	a0,0x5
    80002bdc:	76850513          	addi	a0,a0,1896 # 80008340 <states.0+0x78>
    80002be0:	ffffe097          	auipc	ra,0xffffe
    80002be4:	9aa080e7          	jalr	-1622(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002be8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002bec:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bf0:	00005517          	auipc	a0,0x5
    80002bf4:	78050513          	addi	a0,a0,1920 # 80008370 <states.0+0xa8>
    80002bf8:	ffffe097          	auipc	ra,0xffffe
    80002bfc:	992080e7          	jalr	-1646(ra) # 8000058a <printf>
    setkilled(p);
    80002c00:	8526                	mv	a0,s1
    80002c02:	00000097          	auipc	ra,0x0
    80002c06:	84e080e7          	jalr	-1970(ra) # 80002450 <setkilled>
    80002c0a:	bf71                	j	80002ba6 <usertrap+0x8e>
  if (killed(p))
    80002c0c:	4901                	li	s2,0
    exit(-1);
    80002c0e:	557d                	li	a0,-1
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	6ec080e7          	jalr	1772(ra) # 800022fc <exit>
  if (which_dev == 2)
    80002c18:	4789                	li	a5,2
    80002c1a:	f8f91ce3          	bne	s2,a5,80002bb2 <usertrap+0x9a>
    if (p->interval)
    80002c1e:	1904a703          	lw	a4,400(s1)
    80002c22:	cf19                	beqz	a4,80002c40 <usertrap+0x128>
      p->now_ticks++;
    80002c24:	1944a783          	lw	a5,404(s1)
    80002c28:	2785                	addiw	a5,a5,1
    80002c2a:	0007869b          	sext.w	a3,a5
    80002c2e:	18f4aa23          	sw	a5,404(s1)
      if (!p->sigalarm_status && p->interval > 0 && p->now_ticks >= p->interval)
    80002c32:	1a04a783          	lw	a5,416(s1)
    80002c36:	e789                	bnez	a5,80002c40 <usertrap+0x128>
    80002c38:	00e05463          	blez	a4,80002c40 <usertrap+0x128>
    80002c3c:	02e6d663          	bge	a3,a4,80002c68 <usertrap+0x150>
    struct proc *p = myproc();
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	d6c080e7          	jalr	-660(ra) # 800019ac <myproc>
    if (p->change_queue <= 0)
    80002c48:	17c52783          	lw	a5,380(a0)
    80002c4c:	f3bd                	bnez	a5,80002bb2 <usertrap+0x9a>
      if (p->level + 1 != NMLFQ)
    80002c4e:	17452783          	lw	a5,372(a0)
    80002c52:	470d                	li	a4,3
    80002c54:	00e78563          	beq	a5,a4,80002c5e <usertrap+0x146>
        p->level++;
    80002c58:	2785                	addiw	a5,a5,1
    80002c5a:	16f52a23          	sw	a5,372(a0)
      yield();
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	52e080e7          	jalr	1326(ra) # 8000218c <yield>
    80002c66:	b7b1                	j	80002bb2 <usertrap+0x9a>
        p->now_ticks = 0;
    80002c68:	1804aa23          	sw	zero,404(s1)
        p->sigalarm_status = 1;
    80002c6c:	4785                	li	a5,1
    80002c6e:	1af4a023          	sw	a5,416(s1)
        p->alarm_trapframe = kalloc();
    80002c72:	ffffe097          	auipc	ra,0xffffe
    80002c76:	e74080e7          	jalr	-396(ra) # 80000ae6 <kalloc>
    80002c7a:	18a4bc23          	sd	a0,408(s1)
        memmove(p->alarm_trapframe, p->trapframe, PGSIZE);
    80002c7e:	6605                	lui	a2,0x1
    80002c80:	6cac                	ld	a1,88(s1)
    80002c82:	ffffe097          	auipc	ra,0xffffe
    80002c86:	0ac080e7          	jalr	172(ra) # 80000d2e <memmove>
        p->trapframe->epc = p->handler;
    80002c8a:	6cbc                	ld	a5,88(s1)
    80002c8c:	1884b703          	ld	a4,392(s1)
    80002c90:	ef98                	sd	a4,24(a5)
    80002c92:	b77d                	j	80002c40 <usertrap+0x128>

0000000080002c94 <kerneltrap>:
{
    80002c94:	7179                	addi	sp,sp,-48
    80002c96:	f406                	sd	ra,40(sp)
    80002c98:	f022                	sd	s0,32(sp)
    80002c9a:	ec26                	sd	s1,24(sp)
    80002c9c:	e84a                	sd	s2,16(sp)
    80002c9e:	e44e                	sd	s3,8(sp)
    80002ca0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc"
    80002ca2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus"
    80002ca6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause"
    80002caa:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002cae:	1004f793          	andi	a5,s1,256
    80002cb2:	cb85                	beqz	a5,80002ce2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus"
    80002cb4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cb8:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002cba:	ef85                	bnez	a5,80002cf2 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002cbc:	00000097          	auipc	ra,0x0
    80002cc0:	dba080e7          	jalr	-582(ra) # 80002a76 <devintr>
    80002cc4:	cd1d                	beqz	a0,80002d02 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cc6:	4789                	li	a5,2
    80002cc8:	06f50a63          	beq	a0,a5,80002d3c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0"
    80002ccc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0"
    80002cd0:	10049073          	csrw	sstatus,s1
}
    80002cd4:	70a2                	ld	ra,40(sp)
    80002cd6:	7402                	ld	s0,32(sp)
    80002cd8:	64e2                	ld	s1,24(sp)
    80002cda:	6942                	ld	s2,16(sp)
    80002cdc:	69a2                	ld	s3,8(sp)
    80002cde:	6145                	addi	sp,sp,48
    80002ce0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ce2:	00005517          	auipc	a0,0x5
    80002ce6:	6ae50513          	addi	a0,a0,1710 # 80008390 <states.0+0xc8>
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	856080e7          	jalr	-1962(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002cf2:	00005517          	auipc	a0,0x5
    80002cf6:	6c650513          	addi	a0,a0,1734 # 800083b8 <states.0+0xf0>
    80002cfa:	ffffe097          	auipc	ra,0xffffe
    80002cfe:	846080e7          	jalr	-1978(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002d02:	85ce                	mv	a1,s3
    80002d04:	00005517          	auipc	a0,0x5
    80002d08:	6d450513          	addi	a0,a0,1748 # 800083d8 <states.0+0x110>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	87e080e7          	jalr	-1922(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002d14:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002d18:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d1c:	00005517          	auipc	a0,0x5
    80002d20:	6cc50513          	addi	a0,a0,1740 # 800083e8 <states.0+0x120>
    80002d24:	ffffe097          	auipc	ra,0xffffe
    80002d28:	866080e7          	jalr	-1946(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002d2c:	00005517          	auipc	a0,0x5
    80002d30:	6d450513          	addi	a0,a0,1748 # 80008400 <states.0+0x138>
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	80c080e7          	jalr	-2036(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	c70080e7          	jalr	-912(ra) # 800019ac <myproc>
    80002d44:	d541                	beqz	a0,80002ccc <kerneltrap+0x38>
    80002d46:	fffff097          	auipc	ra,0xfffff
    80002d4a:	c66080e7          	jalr	-922(ra) # 800019ac <myproc>
    80002d4e:	4d18                	lw	a4,24(a0)
    80002d50:	4791                	li	a5,4
    80002d52:	f6f71de3          	bne	a4,a5,80002ccc <kerneltrap+0x38>
    yield();
    80002d56:	fffff097          	auipc	ra,0xfffff
    80002d5a:	436080e7          	jalr	1078(ra) # 8000218c <yield>
    80002d5e:	b7bd                	j	80002ccc <kerneltrap+0x38>

0000000080002d60 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d60:	1101                	addi	sp,sp,-32
    80002d62:	ec06                	sd	ra,24(sp)
    80002d64:	e822                	sd	s0,16(sp)
    80002d66:	e426                	sd	s1,8(sp)
    80002d68:	1000                	addi	s0,sp,32
    80002d6a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d6c:	fffff097          	auipc	ra,0xfffff
    80002d70:	c40080e7          	jalr	-960(ra) # 800019ac <myproc>
  switch (n)
    80002d74:	4795                	li	a5,5
    80002d76:	0497e163          	bltu	a5,s1,80002db8 <argraw+0x58>
    80002d7a:	048a                	slli	s1,s1,0x2
    80002d7c:	00005717          	auipc	a4,0x5
    80002d80:	6bc70713          	addi	a4,a4,1724 # 80008438 <states.0+0x170>
    80002d84:	94ba                	add	s1,s1,a4
    80002d86:	409c                	lw	a5,0(s1)
    80002d88:	97ba                	add	a5,a5,a4
    80002d8a:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002d8c:	6d3c                	ld	a5,88(a0)
    80002d8e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d90:	60e2                	ld	ra,24(sp)
    80002d92:	6442                	ld	s0,16(sp)
    80002d94:	64a2                	ld	s1,8(sp)
    80002d96:	6105                	addi	sp,sp,32
    80002d98:	8082                	ret
    return p->trapframe->a1;
    80002d9a:	6d3c                	ld	a5,88(a0)
    80002d9c:	7fa8                	ld	a0,120(a5)
    80002d9e:	bfcd                	j	80002d90 <argraw+0x30>
    return p->trapframe->a2;
    80002da0:	6d3c                	ld	a5,88(a0)
    80002da2:	63c8                	ld	a0,128(a5)
    80002da4:	b7f5                	j	80002d90 <argraw+0x30>
    return p->trapframe->a3;
    80002da6:	6d3c                	ld	a5,88(a0)
    80002da8:	67c8                	ld	a0,136(a5)
    80002daa:	b7dd                	j	80002d90 <argraw+0x30>
    return p->trapframe->a4;
    80002dac:	6d3c                	ld	a5,88(a0)
    80002dae:	6bc8                	ld	a0,144(a5)
    80002db0:	b7c5                	j	80002d90 <argraw+0x30>
    return p->trapframe->a5;
    80002db2:	6d3c                	ld	a5,88(a0)
    80002db4:	6fc8                	ld	a0,152(a5)
    80002db6:	bfe9                	j	80002d90 <argraw+0x30>
  panic("argraw");
    80002db8:	00005517          	auipc	a0,0x5
    80002dbc:	65850513          	addi	a0,a0,1624 # 80008410 <states.0+0x148>
    80002dc0:	ffffd097          	auipc	ra,0xffffd
    80002dc4:	780080e7          	jalr	1920(ra) # 80000540 <panic>

0000000080002dc8 <fetchaddr>:
{
    80002dc8:	1101                	addi	sp,sp,-32
    80002dca:	ec06                	sd	ra,24(sp)
    80002dcc:	e822                	sd	s0,16(sp)
    80002dce:	e426                	sd	s1,8(sp)
    80002dd0:	e04a                	sd	s2,0(sp)
    80002dd2:	1000                	addi	s0,sp,32
    80002dd4:	84aa                	mv	s1,a0
    80002dd6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	bd4080e7          	jalr	-1068(ra) # 800019ac <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002de0:	653c                	ld	a5,72(a0)
    80002de2:	02f4f863          	bgeu	s1,a5,80002e12 <fetchaddr+0x4a>
    80002de6:	00848713          	addi	a4,s1,8
    80002dea:	02e7e663          	bltu	a5,a4,80002e16 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002dee:	46a1                	li	a3,8
    80002df0:	8626                	mv	a2,s1
    80002df2:	85ca                	mv	a1,s2
    80002df4:	6928                	ld	a0,80(a0)
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	902080e7          	jalr	-1790(ra) # 800016f8 <copyin>
    80002dfe:	00a03533          	snez	a0,a0
    80002e02:	40a00533          	neg	a0,a0
}
    80002e06:	60e2                	ld	ra,24(sp)
    80002e08:	6442                	ld	s0,16(sp)
    80002e0a:	64a2                	ld	s1,8(sp)
    80002e0c:	6902                	ld	s2,0(sp)
    80002e0e:	6105                	addi	sp,sp,32
    80002e10:	8082                	ret
    return -1;
    80002e12:	557d                	li	a0,-1
    80002e14:	bfcd                	j	80002e06 <fetchaddr+0x3e>
    80002e16:	557d                	li	a0,-1
    80002e18:	b7fd                	j	80002e06 <fetchaddr+0x3e>

0000000080002e1a <fetchstr>:
{
    80002e1a:	7179                	addi	sp,sp,-48
    80002e1c:	f406                	sd	ra,40(sp)
    80002e1e:	f022                	sd	s0,32(sp)
    80002e20:	ec26                	sd	s1,24(sp)
    80002e22:	e84a                	sd	s2,16(sp)
    80002e24:	e44e                	sd	s3,8(sp)
    80002e26:	1800                	addi	s0,sp,48
    80002e28:	892a                	mv	s2,a0
    80002e2a:	84ae                	mv	s1,a1
    80002e2c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e2e:	fffff097          	auipc	ra,0xfffff
    80002e32:	b7e080e7          	jalr	-1154(ra) # 800019ac <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e36:	86ce                	mv	a3,s3
    80002e38:	864a                	mv	a2,s2
    80002e3a:	85a6                	mv	a1,s1
    80002e3c:	6928                	ld	a0,80(a0)
    80002e3e:	fffff097          	auipc	ra,0xfffff
    80002e42:	948080e7          	jalr	-1720(ra) # 80001786 <copyinstr>
    80002e46:	00054e63          	bltz	a0,80002e62 <fetchstr+0x48>
  return strlen(buf);
    80002e4a:	8526                	mv	a0,s1
    80002e4c:	ffffe097          	auipc	ra,0xffffe
    80002e50:	002080e7          	jalr	2(ra) # 80000e4e <strlen>
}
    80002e54:	70a2                	ld	ra,40(sp)
    80002e56:	7402                	ld	s0,32(sp)
    80002e58:	64e2                	ld	s1,24(sp)
    80002e5a:	6942                	ld	s2,16(sp)
    80002e5c:	69a2                	ld	s3,8(sp)
    80002e5e:	6145                	addi	sp,sp,48
    80002e60:	8082                	ret
    return -1;
    80002e62:	557d                	li	a0,-1
    80002e64:	bfc5                	j	80002e54 <fetchstr+0x3a>

0000000080002e66 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002e66:	1101                	addi	sp,sp,-32
    80002e68:	ec06                	sd	ra,24(sp)
    80002e6a:	e822                	sd	s0,16(sp)
    80002e6c:	e426                	sd	s1,8(sp)
    80002e6e:	1000                	addi	s0,sp,32
    80002e70:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e72:	00000097          	auipc	ra,0x0
    80002e76:	eee080e7          	jalr	-274(ra) # 80002d60 <argraw>
    80002e7a:	c088                	sw	a0,0(s1)
}
    80002e7c:	60e2                	ld	ra,24(sp)
    80002e7e:	6442                	ld	s0,16(sp)
    80002e80:	64a2                	ld	s1,8(sp)
    80002e82:	6105                	addi	sp,sp,32
    80002e84:	8082                	ret

0000000080002e86 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002e86:	1101                	addi	sp,sp,-32
    80002e88:	ec06                	sd	ra,24(sp)
    80002e8a:	e822                	sd	s0,16(sp)
    80002e8c:	e426                	sd	s1,8(sp)
    80002e8e:	1000                	addi	s0,sp,32
    80002e90:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e92:	00000097          	auipc	ra,0x0
    80002e96:	ece080e7          	jalr	-306(ra) # 80002d60 <argraw>
    80002e9a:	e088                	sd	a0,0(s1)
}
    80002e9c:	60e2                	ld	ra,24(sp)
    80002e9e:	6442                	ld	s0,16(sp)
    80002ea0:	64a2                	ld	s1,8(sp)
    80002ea2:	6105                	addi	sp,sp,32
    80002ea4:	8082                	ret

0000000080002ea6 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002ea6:	7179                	addi	sp,sp,-48
    80002ea8:	f406                	sd	ra,40(sp)
    80002eaa:	f022                	sd	s0,32(sp)
    80002eac:	ec26                	sd	s1,24(sp)
    80002eae:	e84a                	sd	s2,16(sp)
    80002eb0:	1800                	addi	s0,sp,48
    80002eb2:	84ae                	mv	s1,a1
    80002eb4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002eb6:	fd840593          	addi	a1,s0,-40
    80002eba:	00000097          	auipc	ra,0x0
    80002ebe:	fcc080e7          	jalr	-52(ra) # 80002e86 <argaddr>
  return fetchstr(addr, buf, max);
    80002ec2:	864a                	mv	a2,s2
    80002ec4:	85a6                	mv	a1,s1
    80002ec6:	fd843503          	ld	a0,-40(s0)
    80002eca:	00000097          	auipc	ra,0x0
    80002ece:	f50080e7          	jalr	-176(ra) # 80002e1a <fetchstr>
}
    80002ed2:	70a2                	ld	ra,40(sp)
    80002ed4:	7402                	ld	s0,32(sp)
    80002ed6:	64e2                	ld	s1,24(sp)
    80002ed8:	6942                	ld	s2,16(sp)
    80002eda:	6145                	addi	sp,sp,48
    80002edc:	8082                	ret

0000000080002ede <syscall>:
    [SYS_sigreturn] sys_sigreturn,
    [SYS_waitx] sys_waitx,
};

void syscall(void)
{
    80002ede:	1101                	addi	sp,sp,-32
    80002ee0:	ec06                	sd	ra,24(sp)
    80002ee2:	e822                	sd	s0,16(sp)
    80002ee4:	e426                	sd	s1,8(sp)
    80002ee6:	e04a                	sd	s2,0(sp)
    80002ee8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	ac2080e7          	jalr	-1342(ra) # 800019ac <myproc>
    80002ef2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ef4:	05853903          	ld	s2,88(a0)
    80002ef8:	0a893783          	ld	a5,168(s2)
    80002efc:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002f00:	37fd                	addiw	a5,a5,-1
    80002f02:	475d                	li	a4,23
    80002f04:	00f76f63          	bltu	a4,a5,80002f22 <syscall+0x44>
    80002f08:	00369713          	slli	a4,a3,0x3
    80002f0c:	00005797          	auipc	a5,0x5
    80002f10:	54478793          	addi	a5,a5,1348 # 80008450 <syscalls>
    80002f14:	97ba                	add	a5,a5,a4
    80002f16:	639c                	ld	a5,0(a5)
    80002f18:	c789                	beqz	a5,80002f22 <syscall+0x44>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002f1a:	9782                	jalr	a5
    80002f1c:	06a93823          	sd	a0,112(s2)
    80002f20:	a839                	j	80002f3e <syscall+0x60>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002f22:	15848613          	addi	a2,s1,344
    80002f26:	588c                	lw	a1,48(s1)
    80002f28:	00005517          	auipc	a0,0x5
    80002f2c:	4f050513          	addi	a0,a0,1264 # 80008418 <states.0+0x150>
    80002f30:	ffffd097          	auipc	ra,0xffffd
    80002f34:	65a080e7          	jalr	1626(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f38:	6cbc                	ld	a5,88(s1)
    80002f3a:	577d                	li	a4,-1
    80002f3c:	fbb8                	sd	a4,112(a5)
  }
}
    80002f3e:	60e2                	ld	ra,24(sp)
    80002f40:	6442                	ld	s0,16(sp)
    80002f42:	64a2                	ld	s1,8(sp)
    80002f44:	6902                	ld	s2,0(sp)
    80002f46:	6105                	addi	sp,sp,32
    80002f48:	8082                	ret

0000000080002f4a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f4a:	1101                	addi	sp,sp,-32
    80002f4c:	ec06                	sd	ra,24(sp)
    80002f4e:	e822                	sd	s0,16(sp)
    80002f50:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f52:	fec40593          	addi	a1,s0,-20
    80002f56:	4501                	li	a0,0
    80002f58:	00000097          	auipc	ra,0x0
    80002f5c:	f0e080e7          	jalr	-242(ra) # 80002e66 <argint>
  exit(n);
    80002f60:	fec42503          	lw	a0,-20(s0)
    80002f64:	fffff097          	auipc	ra,0xfffff
    80002f68:	398080e7          	jalr	920(ra) # 800022fc <exit>
  return 0; // not reached
}
    80002f6c:	4501                	li	a0,0
    80002f6e:	60e2                	ld	ra,24(sp)
    80002f70:	6442                	ld	s0,16(sp)
    80002f72:	6105                	addi	sp,sp,32
    80002f74:	8082                	ret

0000000080002f76 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f76:	1141                	addi	sp,sp,-16
    80002f78:	e406                	sd	ra,8(sp)
    80002f7a:	e022                	sd	s0,0(sp)
    80002f7c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f7e:	fffff097          	auipc	ra,0xfffff
    80002f82:	a2e080e7          	jalr	-1490(ra) # 800019ac <myproc>
}
    80002f86:	5908                	lw	a0,48(a0)
    80002f88:	60a2                	ld	ra,8(sp)
    80002f8a:	6402                	ld	s0,0(sp)
    80002f8c:	0141                	addi	sp,sp,16
    80002f8e:	8082                	ret

0000000080002f90 <sys_fork>:

uint64
sys_fork(void)
{
    80002f90:	1141                	addi	sp,sp,-16
    80002f92:	e406                	sd	ra,8(sp)
    80002f94:	e022                	sd	s0,0(sp)
    80002f96:	0800                	addi	s0,sp,16
  return fork();
    80002f98:	fffff097          	auipc	ra,0xfffff
    80002f9c:	e1e080e7          	jalr	-482(ra) # 80001db6 <fork>
}
    80002fa0:	60a2                	ld	ra,8(sp)
    80002fa2:	6402                	ld	s0,0(sp)
    80002fa4:	0141                	addi	sp,sp,16
    80002fa6:	8082                	ret

0000000080002fa8 <sys_wait>:

uint64
sys_wait(void)
{
    80002fa8:	1101                	addi	sp,sp,-32
    80002faa:	ec06                	sd	ra,24(sp)
    80002fac:	e822                	sd	s0,16(sp)
    80002fae:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002fb0:	fe840593          	addi	a1,s0,-24
    80002fb4:	4501                	li	a0,0
    80002fb6:	00000097          	auipc	ra,0x0
    80002fba:	ed0080e7          	jalr	-304(ra) # 80002e86 <argaddr>
  return wait(p);
    80002fbe:	fe843503          	ld	a0,-24(s0)
    80002fc2:	fffff097          	auipc	ra,0xfffff
    80002fc6:	4ec080e7          	jalr	1260(ra) # 800024ae <wait>
}
    80002fca:	60e2                	ld	ra,24(sp)
    80002fcc:	6442                	ld	s0,16(sp)
    80002fce:	6105                	addi	sp,sp,32
    80002fd0:	8082                	ret

0000000080002fd2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fd2:	7179                	addi	sp,sp,-48
    80002fd4:	f406                	sd	ra,40(sp)
    80002fd6:	f022                	sd	s0,32(sp)
    80002fd8:	ec26                	sd	s1,24(sp)
    80002fda:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002fdc:	fdc40593          	addi	a1,s0,-36
    80002fe0:	4501                	li	a0,0
    80002fe2:	00000097          	auipc	ra,0x0
    80002fe6:	e84080e7          	jalr	-380(ra) # 80002e66 <argint>
  addr = myproc()->sz;
    80002fea:	fffff097          	auipc	ra,0xfffff
    80002fee:	9c2080e7          	jalr	-1598(ra) # 800019ac <myproc>
    80002ff2:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002ff4:	fdc42503          	lw	a0,-36(s0)
    80002ff8:	fffff097          	auipc	ra,0xfffff
    80002ffc:	d62080e7          	jalr	-670(ra) # 80001d5a <growproc>
    80003000:	00054863          	bltz	a0,80003010 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003004:	8526                	mv	a0,s1
    80003006:	70a2                	ld	ra,40(sp)
    80003008:	7402                	ld	s0,32(sp)
    8000300a:	64e2                	ld	s1,24(sp)
    8000300c:	6145                	addi	sp,sp,48
    8000300e:	8082                	ret
    return -1;
    80003010:	54fd                	li	s1,-1
    80003012:	bfcd                	j	80003004 <sys_sbrk+0x32>

0000000080003014 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003014:	7139                	addi	sp,sp,-64
    80003016:	fc06                	sd	ra,56(sp)
    80003018:	f822                	sd	s0,48(sp)
    8000301a:	f426                	sd	s1,40(sp)
    8000301c:	f04a                	sd	s2,32(sp)
    8000301e:	ec4e                	sd	s3,24(sp)
    80003020:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003022:	fcc40593          	addi	a1,s0,-52
    80003026:	4501                	li	a0,0
    80003028:	00000097          	auipc	ra,0x0
    8000302c:	e3e080e7          	jalr	-450(ra) # 80002e66 <argint>
  acquire(&tickslock);
    80003030:	00015517          	auipc	a0,0x15
    80003034:	1a050513          	addi	a0,a0,416 # 800181d0 <tickslock>
    80003038:	ffffe097          	auipc	ra,0xffffe
    8000303c:	b9e080e7          	jalr	-1122(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003040:	00006917          	auipc	s2,0x6
    80003044:	8d092903          	lw	s2,-1840(s2) # 80008910 <ticks>
  while (ticks - ticks0 < n)
    80003048:	fcc42783          	lw	a5,-52(s0)
    8000304c:	cf9d                	beqz	a5,8000308a <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000304e:	00015997          	auipc	s3,0x15
    80003052:	18298993          	addi	s3,s3,386 # 800181d0 <tickslock>
    80003056:	00006497          	auipc	s1,0x6
    8000305a:	8ba48493          	addi	s1,s1,-1862 # 80008910 <ticks>
    if (killed(myproc()))
    8000305e:	fffff097          	auipc	ra,0xfffff
    80003062:	94e080e7          	jalr	-1714(ra) # 800019ac <myproc>
    80003066:	fffff097          	auipc	ra,0xfffff
    8000306a:	416080e7          	jalr	1046(ra) # 8000247c <killed>
    8000306e:	ed15                	bnez	a0,800030aa <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003070:	85ce                	mv	a1,s3
    80003072:	8526                	mv	a0,s1
    80003074:	fffff097          	auipc	ra,0xfffff
    80003078:	154080e7          	jalr	340(ra) # 800021c8 <sleep>
  while (ticks - ticks0 < n)
    8000307c:	409c                	lw	a5,0(s1)
    8000307e:	412787bb          	subw	a5,a5,s2
    80003082:	fcc42703          	lw	a4,-52(s0)
    80003086:	fce7ece3          	bltu	a5,a4,8000305e <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000308a:	00015517          	auipc	a0,0x15
    8000308e:	14650513          	addi	a0,a0,326 # 800181d0 <tickslock>
    80003092:	ffffe097          	auipc	ra,0xffffe
    80003096:	bf8080e7          	jalr	-1032(ra) # 80000c8a <release>
  return 0;
    8000309a:	4501                	li	a0,0
}
    8000309c:	70e2                	ld	ra,56(sp)
    8000309e:	7442                	ld	s0,48(sp)
    800030a0:	74a2                	ld	s1,40(sp)
    800030a2:	7902                	ld	s2,32(sp)
    800030a4:	69e2                	ld	s3,24(sp)
    800030a6:	6121                	addi	sp,sp,64
    800030a8:	8082                	ret
      release(&tickslock);
    800030aa:	00015517          	auipc	a0,0x15
    800030ae:	12650513          	addi	a0,a0,294 # 800181d0 <tickslock>
    800030b2:	ffffe097          	auipc	ra,0xffffe
    800030b6:	bd8080e7          	jalr	-1064(ra) # 80000c8a <release>
      return -1;
    800030ba:	557d                	li	a0,-1
    800030bc:	b7c5                	j	8000309c <sys_sleep+0x88>

00000000800030be <sys_kill>:

uint64
sys_kill(void)
{
    800030be:	1101                	addi	sp,sp,-32
    800030c0:	ec06                	sd	ra,24(sp)
    800030c2:	e822                	sd	s0,16(sp)
    800030c4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800030c6:	fec40593          	addi	a1,s0,-20
    800030ca:	4501                	li	a0,0
    800030cc:	00000097          	auipc	ra,0x0
    800030d0:	d9a080e7          	jalr	-614(ra) # 80002e66 <argint>
  return kill(pid);
    800030d4:	fec42503          	lw	a0,-20(s0)
    800030d8:	fffff097          	auipc	ra,0xfffff
    800030dc:	306080e7          	jalr	774(ra) # 800023de <kill>
}
    800030e0:	60e2                	ld	ra,24(sp)
    800030e2:	6442                	ld	s0,16(sp)
    800030e4:	6105                	addi	sp,sp,32
    800030e6:	8082                	ret

00000000800030e8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030e8:	1101                	addi	sp,sp,-32
    800030ea:	ec06                	sd	ra,24(sp)
    800030ec:	e822                	sd	s0,16(sp)
    800030ee:	e426                	sd	s1,8(sp)
    800030f0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030f2:	00015517          	auipc	a0,0x15
    800030f6:	0de50513          	addi	a0,a0,222 # 800181d0 <tickslock>
    800030fa:	ffffe097          	auipc	ra,0xffffe
    800030fe:	adc080e7          	jalr	-1316(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003102:	00006497          	auipc	s1,0x6
    80003106:	80e4a483          	lw	s1,-2034(s1) # 80008910 <ticks>
  release(&tickslock);
    8000310a:	00015517          	auipc	a0,0x15
    8000310e:	0c650513          	addi	a0,a0,198 # 800181d0 <tickslock>
    80003112:	ffffe097          	auipc	ra,0xffffe
    80003116:	b78080e7          	jalr	-1160(ra) # 80000c8a <release>
  return xticks;
}
    8000311a:	02049513          	slli	a0,s1,0x20
    8000311e:	9101                	srli	a0,a0,0x20
    80003120:	60e2                	ld	ra,24(sp)
    80003122:	6442                	ld	s0,16(sp)
    80003124:	64a2                	ld	s1,8(sp)
    80003126:	6105                	addi	sp,sp,32
    80003128:	8082                	ret

000000008000312a <sys_sigalarm>:

// sigalarm
uint64 sys_sigalarm(void)
{
    8000312a:	1101                	addi	sp,sp,-32
    8000312c:	ec06                	sd	ra,24(sp)
    8000312e:	e822                	sd	s0,16(sp)
    80003130:	1000                	addi	s0,sp,32
  int interval;
  uint64 fn;
  argint(0, &interval);
    80003132:	fec40593          	addi	a1,s0,-20
    80003136:	4501                	li	a0,0
    80003138:	00000097          	auipc	ra,0x0
    8000313c:	d2e080e7          	jalr	-722(ra) # 80002e66 <argint>
  argaddr(1, &fn);
    80003140:	fe040593          	addi	a1,s0,-32
    80003144:	4505                	li	a0,1
    80003146:	00000097          	auipc	ra,0x0
    8000314a:	d40080e7          	jalr	-704(ra) # 80002e86 <argaddr>

  struct proc *p = myproc();
    8000314e:	fffff097          	auipc	ra,0xfffff
    80003152:	85e080e7          	jalr	-1954(ra) # 800019ac <myproc>

  p->sigalarm_status = 0;
    80003156:	1a052023          	sw	zero,416(a0)
  p->interval = interval;
    8000315a:	fec42783          	lw	a5,-20(s0)
    8000315e:	18f52823          	sw	a5,400(a0)
  p->now_ticks = 0;
    80003162:	18052a23          	sw	zero,404(a0)
  p->handler = fn;
    80003166:	fe043783          	ld	a5,-32(s0)
    8000316a:	18f53423          	sd	a5,392(a0)

  return 0;
}
    8000316e:	4501                	li	a0,0
    80003170:	60e2                	ld	ra,24(sp)
    80003172:	6442                	ld	s0,16(sp)
    80003174:	6105                	addi	sp,sp,32
    80003176:	8082                	ret

0000000080003178 <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    80003178:	1101                	addi	sp,sp,-32
    8000317a:	ec06                	sd	ra,24(sp)
    8000317c:	e822                	sd	s0,16(sp)
    8000317e:	e426                	sd	s1,8(sp)
    80003180:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003182:	fffff097          	auipc	ra,0xfffff
    80003186:	82a080e7          	jalr	-2006(ra) # 800019ac <myproc>
    8000318a:	84aa                	mv	s1,a0

  // Restore Kernel Values
  memmove(p->trapframe, p->alarm_trapframe, PGSIZE);
    8000318c:	6605                	lui	a2,0x1
    8000318e:	19853583          	ld	a1,408(a0)
    80003192:	6d28                	ld	a0,88(a0)
    80003194:	ffffe097          	auipc	ra,0xffffe
    80003198:	b9a080e7          	jalr	-1126(ra) # 80000d2e <memmove>
  kfree(p->alarm_trapframe);
    8000319c:	1984b503          	ld	a0,408(s1)
    800031a0:	ffffe097          	auipc	ra,0xffffe
    800031a4:	848080e7          	jalr	-1976(ra) # 800009e8 <kfree>

  p->sigalarm_status = 0;
    800031a8:	1a04a023          	sw	zero,416(s1)
  p->alarm_trapframe = 0;
    800031ac:	1804bc23          	sd	zero,408(s1)
  p->now_ticks = 0;
    800031b0:	1804aa23          	sw	zero,404(s1)
  usertrapret();
    800031b4:	fffff097          	auipc	ra,0xfffff
    800031b8:	7d8080e7          	jalr	2008(ra) # 8000298c <usertrapret>
  return 0;
}
    800031bc:	4501                	li	a0,0
    800031be:	60e2                	ld	ra,24(sp)
    800031c0:	6442                	ld	s0,16(sp)
    800031c2:	64a2                	ld	s1,8(sp)
    800031c4:	6105                	addi	sp,sp,32
    800031c6:	8082                	ret

00000000800031c8 <sys_waitx>:

uint64
sys_waitx(void)
{
    800031c8:	7139                	addi	sp,sp,-64
    800031ca:	fc06                	sd	ra,56(sp)
    800031cc:	f822                	sd	s0,48(sp)
    800031ce:	f426                	sd	s1,40(sp)
    800031d0:	f04a                	sd	s2,32(sp)
    800031d2:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800031d4:	fd840593          	addi	a1,s0,-40
    800031d8:	4501                	li	a0,0
    800031da:	00000097          	auipc	ra,0x0
    800031de:	cac080e7          	jalr	-852(ra) # 80002e86 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800031e2:	fd040593          	addi	a1,s0,-48
    800031e6:	4505                	li	a0,1
    800031e8:	00000097          	auipc	ra,0x0
    800031ec:	c9e080e7          	jalr	-866(ra) # 80002e86 <argaddr>
  argaddr(2, &addr2);
    800031f0:	fc840593          	addi	a1,s0,-56
    800031f4:	4509                	li	a0,2
    800031f6:	00000097          	auipc	ra,0x0
    800031fa:	c90080e7          	jalr	-880(ra) # 80002e86 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800031fe:	fc040613          	addi	a2,s0,-64
    80003202:	fc440593          	addi	a1,s0,-60
    80003206:	fd843503          	ld	a0,-40(s0)
    8000320a:	fffff097          	auipc	ra,0xfffff
    8000320e:	52e080e7          	jalr	1326(ra) # 80002738 <waitx>
    80003212:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003214:	ffffe097          	auipc	ra,0xffffe
    80003218:	798080e7          	jalr	1944(ra) # 800019ac <myproc>
    8000321c:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000321e:	4691                	li	a3,4
    80003220:	fc440613          	addi	a2,s0,-60
    80003224:	fd043583          	ld	a1,-48(s0)
    80003228:	6928                	ld	a0,80(a0)
    8000322a:	ffffe097          	auipc	ra,0xffffe
    8000322e:	442080e7          	jalr	1090(ra) # 8000166c <copyout>
    return -1;
    80003232:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003234:	00054f63          	bltz	a0,80003252 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003238:	4691                	li	a3,4
    8000323a:	fc040613          	addi	a2,s0,-64
    8000323e:	fc843583          	ld	a1,-56(s0)
    80003242:	68a8                	ld	a0,80(s1)
    80003244:	ffffe097          	auipc	ra,0xffffe
    80003248:	428080e7          	jalr	1064(ra) # 8000166c <copyout>
    8000324c:	00054a63          	bltz	a0,80003260 <sys_waitx+0x98>
    return -1;
  return ret;
    80003250:	87ca                	mv	a5,s2
    80003252:	853e                	mv	a0,a5
    80003254:	70e2                	ld	ra,56(sp)
    80003256:	7442                	ld	s0,48(sp)
    80003258:	74a2                	ld	s1,40(sp)
    8000325a:	7902                	ld	s2,32(sp)
    8000325c:	6121                	addi	sp,sp,64
    8000325e:	8082                	ret
    return -1;
    80003260:	57fd                	li	a5,-1
    80003262:	bfc5                	j	80003252 <sys_waitx+0x8a>

0000000080003264 <binit>:
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void binit(void)
{
    80003264:	7179                	addi	sp,sp,-48
    80003266:	f406                	sd	ra,40(sp)
    80003268:	f022                	sd	s0,32(sp)
    8000326a:	ec26                	sd	s1,24(sp)
    8000326c:	e84a                	sd	s2,16(sp)
    8000326e:	e44e                	sd	s3,8(sp)
    80003270:	e052                	sd	s4,0(sp)
    80003272:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003274:	00005597          	auipc	a1,0x5
    80003278:	2a458593          	addi	a1,a1,676 # 80008518 <syscalls+0xc8>
    8000327c:	00015517          	auipc	a0,0x15
    80003280:	f6c50513          	addi	a0,a0,-148 # 800181e8 <bcache>
    80003284:	ffffe097          	auipc	ra,0xffffe
    80003288:	8c2080e7          	jalr	-1854(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000328c:	0001d797          	auipc	a5,0x1d
    80003290:	f5c78793          	addi	a5,a5,-164 # 800201e8 <bcache+0x8000>
    80003294:	0001d717          	auipc	a4,0x1d
    80003298:	1bc70713          	addi	a4,a4,444 # 80020450 <bcache+0x8268>
    8000329c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800032a0:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    800032a4:	00015497          	auipc	s1,0x15
    800032a8:	f5c48493          	addi	s1,s1,-164 # 80018200 <bcache+0x18>
  {
    b->next = bcache.head.next;
    800032ac:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800032ae:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800032b0:	00005a17          	auipc	s4,0x5
    800032b4:	270a0a13          	addi	s4,s4,624 # 80008520 <syscalls+0xd0>
    b->next = bcache.head.next;
    800032b8:	2b893783          	ld	a5,696(s2)
    800032bc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800032be:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800032c2:	85d2                	mv	a1,s4
    800032c4:	01048513          	addi	a0,s1,16
    800032c8:	00001097          	auipc	ra,0x1
    800032cc:	4c8080e7          	jalr	1224(ra) # 80004790 <initsleeplock>
    bcache.head.next->prev = b;
    800032d0:	2b893783          	ld	a5,696(s2)
    800032d4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032d6:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    800032da:	45848493          	addi	s1,s1,1112
    800032de:	fd349de3          	bne	s1,s3,800032b8 <binit+0x54>
  }
}
    800032e2:	70a2                	ld	ra,40(sp)
    800032e4:	7402                	ld	s0,32(sp)
    800032e6:	64e2                	ld	s1,24(sp)
    800032e8:	6942                	ld	s2,16(sp)
    800032ea:	69a2                	ld	s3,8(sp)
    800032ec:	6a02                	ld	s4,0(sp)
    800032ee:	6145                	addi	sp,sp,48
    800032f0:	8082                	ret

00000000800032f2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    800032f2:	7179                	addi	sp,sp,-48
    800032f4:	f406                	sd	ra,40(sp)
    800032f6:	f022                	sd	s0,32(sp)
    800032f8:	ec26                	sd	s1,24(sp)
    800032fa:	e84a                	sd	s2,16(sp)
    800032fc:	e44e                	sd	s3,8(sp)
    800032fe:	1800                	addi	s0,sp,48
    80003300:	892a                	mv	s2,a0
    80003302:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003304:	00015517          	auipc	a0,0x15
    80003308:	ee450513          	addi	a0,a0,-284 # 800181e8 <bcache>
    8000330c:	ffffe097          	auipc	ra,0xffffe
    80003310:	8ca080e7          	jalr	-1846(ra) # 80000bd6 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next)
    80003314:	0001d497          	auipc	s1,0x1d
    80003318:	18c4b483          	ld	s1,396(s1) # 800204a0 <bcache+0x82b8>
    8000331c:	0001d797          	auipc	a5,0x1d
    80003320:	13478793          	addi	a5,a5,308 # 80020450 <bcache+0x8268>
    80003324:	02f48f63          	beq	s1,a5,80003362 <bread+0x70>
    80003328:	873e                	mv	a4,a5
    8000332a:	a021                	j	80003332 <bread+0x40>
    8000332c:	68a4                	ld	s1,80(s1)
    8000332e:	02e48a63          	beq	s1,a4,80003362 <bread+0x70>
    if (b->dev == dev && b->blockno == blockno)
    80003332:	449c                	lw	a5,8(s1)
    80003334:	ff279ce3          	bne	a5,s2,8000332c <bread+0x3a>
    80003338:	44dc                	lw	a5,12(s1)
    8000333a:	ff3799e3          	bne	a5,s3,8000332c <bread+0x3a>
      b->refcnt++;
    8000333e:	40bc                	lw	a5,64(s1)
    80003340:	2785                	addiw	a5,a5,1
    80003342:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003344:	00015517          	auipc	a0,0x15
    80003348:	ea450513          	addi	a0,a0,-348 # 800181e8 <bcache>
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	93e080e7          	jalr	-1730(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003354:	01048513          	addi	a0,s1,16
    80003358:	00001097          	auipc	ra,0x1
    8000335c:	472080e7          	jalr	1138(ra) # 800047ca <acquiresleep>
      return b;
    80003360:	a8b9                	j	800033be <bread+0xcc>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    80003362:	0001d497          	auipc	s1,0x1d
    80003366:	1364b483          	ld	s1,310(s1) # 80020498 <bcache+0x82b0>
    8000336a:	0001d797          	auipc	a5,0x1d
    8000336e:	0e678793          	addi	a5,a5,230 # 80020450 <bcache+0x8268>
    80003372:	00f48863          	beq	s1,a5,80003382 <bread+0x90>
    80003376:	873e                	mv	a4,a5
    if (b->refcnt == 0)
    80003378:	40bc                	lw	a5,64(s1)
    8000337a:	cf81                	beqz	a5,80003392 <bread+0xa0>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    8000337c:	64a4                	ld	s1,72(s1)
    8000337e:	fee49de3          	bne	s1,a4,80003378 <bread+0x86>
  panic("bget: no buffers");
    80003382:	00005517          	auipc	a0,0x5
    80003386:	1a650513          	addi	a0,a0,422 # 80008528 <syscalls+0xd8>
    8000338a:	ffffd097          	auipc	ra,0xffffd
    8000338e:	1b6080e7          	jalr	438(ra) # 80000540 <panic>
      b->dev = dev;
    80003392:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003396:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000339a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000339e:	4785                	li	a5,1
    800033a0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033a2:	00015517          	auipc	a0,0x15
    800033a6:	e4650513          	addi	a0,a0,-442 # 800181e8 <bcache>
    800033aa:	ffffe097          	auipc	ra,0xffffe
    800033ae:	8e0080e7          	jalr	-1824(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800033b2:	01048513          	addi	a0,s1,16
    800033b6:	00001097          	auipc	ra,0x1
    800033ba:	414080e7          	jalr	1044(ra) # 800047ca <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid)
    800033be:	409c                	lw	a5,0(s1)
    800033c0:	cb89                	beqz	a5,800033d2 <bread+0xe0>
  {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800033c2:	8526                	mv	a0,s1
    800033c4:	70a2                	ld	ra,40(sp)
    800033c6:	7402                	ld	s0,32(sp)
    800033c8:	64e2                	ld	s1,24(sp)
    800033ca:	6942                	ld	s2,16(sp)
    800033cc:	69a2                	ld	s3,8(sp)
    800033ce:	6145                	addi	sp,sp,48
    800033d0:	8082                	ret
    virtio_disk_rw(b, 0);
    800033d2:	4581                	li	a1,0
    800033d4:	8526                	mv	a0,s1
    800033d6:	00003097          	auipc	ra,0x3
    800033da:	0c2080e7          	jalr	194(ra) # 80006498 <virtio_disk_rw>
    b->valid = 1;
    800033de:	4785                	li	a5,1
    800033e0:	c09c                	sw	a5,0(s1)
  return b;
    800033e2:	b7c5                	j	800033c2 <bread+0xd0>

00000000800033e4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
    800033e4:	1101                	addi	sp,sp,-32
    800033e6:	ec06                	sd	ra,24(sp)
    800033e8:	e822                	sd	s0,16(sp)
    800033ea:	e426                	sd	s1,8(sp)
    800033ec:	1000                	addi	s0,sp,32
    800033ee:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800033f0:	0541                	addi	a0,a0,16
    800033f2:	00001097          	auipc	ra,0x1
    800033f6:	472080e7          	jalr	1138(ra) # 80004864 <holdingsleep>
    800033fa:	cd01                	beqz	a0,80003412 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033fc:	4585                	li	a1,1
    800033fe:	8526                	mv	a0,s1
    80003400:	00003097          	auipc	ra,0x3
    80003404:	098080e7          	jalr	152(ra) # 80006498 <virtio_disk_rw>
}
    80003408:	60e2                	ld	ra,24(sp)
    8000340a:	6442                	ld	s0,16(sp)
    8000340c:	64a2                	ld	s1,8(sp)
    8000340e:	6105                	addi	sp,sp,32
    80003410:	8082                	ret
    panic("bwrite");
    80003412:	00005517          	auipc	a0,0x5
    80003416:	12e50513          	addi	a0,a0,302 # 80008540 <syscalls+0xf0>
    8000341a:	ffffd097          	auipc	ra,0xffffd
    8000341e:	126080e7          	jalr	294(ra) # 80000540 <panic>

0000000080003422 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)
{
    80003422:	1101                	addi	sp,sp,-32
    80003424:	ec06                	sd	ra,24(sp)
    80003426:	e822                	sd	s0,16(sp)
    80003428:	e426                	sd	s1,8(sp)
    8000342a:	e04a                	sd	s2,0(sp)
    8000342c:	1000                	addi	s0,sp,32
    8000342e:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003430:	01050913          	addi	s2,a0,16
    80003434:	854a                	mv	a0,s2
    80003436:	00001097          	auipc	ra,0x1
    8000343a:	42e080e7          	jalr	1070(ra) # 80004864 <holdingsleep>
    8000343e:	c92d                	beqz	a0,800034b0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003440:	854a                	mv	a0,s2
    80003442:	00001097          	auipc	ra,0x1
    80003446:	3de080e7          	jalr	990(ra) # 80004820 <releasesleep>

  acquire(&bcache.lock);
    8000344a:	00015517          	auipc	a0,0x15
    8000344e:	d9e50513          	addi	a0,a0,-610 # 800181e8 <bcache>
    80003452:	ffffd097          	auipc	ra,0xffffd
    80003456:	784080e7          	jalr	1924(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000345a:	40bc                	lw	a5,64(s1)
    8000345c:	37fd                	addiw	a5,a5,-1
    8000345e:	0007871b          	sext.w	a4,a5
    80003462:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0)
    80003464:	eb05                	bnez	a4,80003494 <brelse+0x72>
  {
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003466:	68bc                	ld	a5,80(s1)
    80003468:	64b8                	ld	a4,72(s1)
    8000346a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000346c:	64bc                	ld	a5,72(s1)
    8000346e:	68b8                	ld	a4,80(s1)
    80003470:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003472:	0001d797          	auipc	a5,0x1d
    80003476:	d7678793          	addi	a5,a5,-650 # 800201e8 <bcache+0x8000>
    8000347a:	2b87b703          	ld	a4,696(a5)
    8000347e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003480:	0001d717          	auipc	a4,0x1d
    80003484:	fd070713          	addi	a4,a4,-48 # 80020450 <bcache+0x8268>
    80003488:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000348a:	2b87b703          	ld	a4,696(a5)
    8000348e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003490:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80003494:	00015517          	auipc	a0,0x15
    80003498:	d5450513          	addi	a0,a0,-684 # 800181e8 <bcache>
    8000349c:	ffffd097          	auipc	ra,0xffffd
    800034a0:	7ee080e7          	jalr	2030(ra) # 80000c8a <release>
}
    800034a4:	60e2                	ld	ra,24(sp)
    800034a6:	6442                	ld	s0,16(sp)
    800034a8:	64a2                	ld	s1,8(sp)
    800034aa:	6902                	ld	s2,0(sp)
    800034ac:	6105                	addi	sp,sp,32
    800034ae:	8082                	ret
    panic("brelse");
    800034b0:	00005517          	auipc	a0,0x5
    800034b4:	09850513          	addi	a0,a0,152 # 80008548 <syscalls+0xf8>
    800034b8:	ffffd097          	auipc	ra,0xffffd
    800034bc:	088080e7          	jalr	136(ra) # 80000540 <panic>

00000000800034c0 <bpin>:

void bpin(struct buf *b)
{
    800034c0:	1101                	addi	sp,sp,-32
    800034c2:	ec06                	sd	ra,24(sp)
    800034c4:	e822                	sd	s0,16(sp)
    800034c6:	e426                	sd	s1,8(sp)
    800034c8:	1000                	addi	s0,sp,32
    800034ca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034cc:	00015517          	auipc	a0,0x15
    800034d0:	d1c50513          	addi	a0,a0,-740 # 800181e8 <bcache>
    800034d4:	ffffd097          	auipc	ra,0xffffd
    800034d8:	702080e7          	jalr	1794(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800034dc:	40bc                	lw	a5,64(s1)
    800034de:	2785                	addiw	a5,a5,1
    800034e0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034e2:	00015517          	auipc	a0,0x15
    800034e6:	d0650513          	addi	a0,a0,-762 # 800181e8 <bcache>
    800034ea:	ffffd097          	auipc	ra,0xffffd
    800034ee:	7a0080e7          	jalr	1952(ra) # 80000c8a <release>
}
    800034f2:	60e2                	ld	ra,24(sp)
    800034f4:	6442                	ld	s0,16(sp)
    800034f6:	64a2                	ld	s1,8(sp)
    800034f8:	6105                	addi	sp,sp,32
    800034fa:	8082                	ret

00000000800034fc <bunpin>:

void bunpin(struct buf *b)
{
    800034fc:	1101                	addi	sp,sp,-32
    800034fe:	ec06                	sd	ra,24(sp)
    80003500:	e822                	sd	s0,16(sp)
    80003502:	e426                	sd	s1,8(sp)
    80003504:	1000                	addi	s0,sp,32
    80003506:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003508:	00015517          	auipc	a0,0x15
    8000350c:	ce050513          	addi	a0,a0,-800 # 800181e8 <bcache>
    80003510:	ffffd097          	auipc	ra,0xffffd
    80003514:	6c6080e7          	jalr	1734(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003518:	40bc                	lw	a5,64(s1)
    8000351a:	37fd                	addiw	a5,a5,-1
    8000351c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000351e:	00015517          	auipc	a0,0x15
    80003522:	cca50513          	addi	a0,a0,-822 # 800181e8 <bcache>
    80003526:	ffffd097          	auipc	ra,0xffffd
    8000352a:	764080e7          	jalr	1892(ra) # 80000c8a <release>
}
    8000352e:	60e2                	ld	ra,24(sp)
    80003530:	6442                	ld	s0,16(sp)
    80003532:	64a2                	ld	s1,8(sp)
    80003534:	6105                	addi	sp,sp,32
    80003536:	8082                	ret

0000000080003538 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003538:	1101                	addi	sp,sp,-32
    8000353a:	ec06                	sd	ra,24(sp)
    8000353c:	e822                	sd	s0,16(sp)
    8000353e:	e426                	sd	s1,8(sp)
    80003540:	e04a                	sd	s2,0(sp)
    80003542:	1000                	addi	s0,sp,32
    80003544:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003546:	00d5d59b          	srliw	a1,a1,0xd
    8000354a:	0001d797          	auipc	a5,0x1d
    8000354e:	37a7a783          	lw	a5,890(a5) # 800208c4 <sb+0x1c>
    80003552:	9dbd                	addw	a1,a1,a5
    80003554:	00000097          	auipc	ra,0x0
    80003558:	d9e080e7          	jalr	-610(ra) # 800032f2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000355c:	0074f713          	andi	a4,s1,7
    80003560:	4785                	li	a5,1
    80003562:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80003566:	14ce                	slli	s1,s1,0x33
    80003568:	90d9                	srli	s1,s1,0x36
    8000356a:	00950733          	add	a4,a0,s1
    8000356e:	05874703          	lbu	a4,88(a4)
    80003572:	00e7f6b3          	and	a3,a5,a4
    80003576:	c69d                	beqz	a3,800035a4 <bfree+0x6c>
    80003578:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    8000357a:	94aa                	add	s1,s1,a0
    8000357c:	fff7c793          	not	a5,a5
    80003580:	8f7d                	and	a4,a4,a5
    80003582:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003586:	00001097          	auipc	ra,0x1
    8000358a:	126080e7          	jalr	294(ra) # 800046ac <log_write>
  brelse(bp);
    8000358e:	854a                	mv	a0,s2
    80003590:	00000097          	auipc	ra,0x0
    80003594:	e92080e7          	jalr	-366(ra) # 80003422 <brelse>
}
    80003598:	60e2                	ld	ra,24(sp)
    8000359a:	6442                	ld	s0,16(sp)
    8000359c:	64a2                	ld	s1,8(sp)
    8000359e:	6902                	ld	s2,0(sp)
    800035a0:	6105                	addi	sp,sp,32
    800035a2:	8082                	ret
    panic("freeing free block");
    800035a4:	00005517          	auipc	a0,0x5
    800035a8:	fac50513          	addi	a0,a0,-84 # 80008550 <syscalls+0x100>
    800035ac:	ffffd097          	auipc	ra,0xffffd
    800035b0:	f94080e7          	jalr	-108(ra) # 80000540 <panic>

00000000800035b4 <balloc>:
{
    800035b4:	711d                	addi	sp,sp,-96
    800035b6:	ec86                	sd	ra,88(sp)
    800035b8:	e8a2                	sd	s0,80(sp)
    800035ba:	e4a6                	sd	s1,72(sp)
    800035bc:	e0ca                	sd	s2,64(sp)
    800035be:	fc4e                	sd	s3,56(sp)
    800035c0:	f852                	sd	s4,48(sp)
    800035c2:	f456                	sd	s5,40(sp)
    800035c4:	f05a                	sd	s6,32(sp)
    800035c6:	ec5e                	sd	s7,24(sp)
    800035c8:	e862                	sd	s8,16(sp)
    800035ca:	e466                	sd	s9,8(sp)
    800035cc:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB)
    800035ce:	0001d797          	auipc	a5,0x1d
    800035d2:	2de7a783          	lw	a5,734(a5) # 800208ac <sb+0x4>
    800035d6:	cff5                	beqz	a5,800036d2 <balloc+0x11e>
    800035d8:	8baa                	mv	s7,a0
    800035da:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035dc:	0001db17          	auipc	s6,0x1d
    800035e0:	2ccb0b13          	addi	s6,s6,716 # 800208a8 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800035e4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035e6:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800035e8:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB)
    800035ea:	6c89                	lui	s9,0x2
    800035ec:	a061                	j	80003674 <balloc+0xc0>
        bp->data[bi / 8] |= m; // Mark block in use.
    800035ee:	97ca                	add	a5,a5,s2
    800035f0:	8e55                	or	a2,a2,a3
    800035f2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800035f6:	854a                	mv	a0,s2
    800035f8:	00001097          	auipc	ra,0x1
    800035fc:	0b4080e7          	jalr	180(ra) # 800046ac <log_write>
        brelse(bp);
    80003600:	854a                	mv	a0,s2
    80003602:	00000097          	auipc	ra,0x0
    80003606:	e20080e7          	jalr	-480(ra) # 80003422 <brelse>
  bp = bread(dev, bno);
    8000360a:	85a6                	mv	a1,s1
    8000360c:	855e                	mv	a0,s7
    8000360e:	00000097          	auipc	ra,0x0
    80003612:	ce4080e7          	jalr	-796(ra) # 800032f2 <bread>
    80003616:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003618:	40000613          	li	a2,1024
    8000361c:	4581                	li	a1,0
    8000361e:	05850513          	addi	a0,a0,88
    80003622:	ffffd097          	auipc	ra,0xffffd
    80003626:	6b0080e7          	jalr	1712(ra) # 80000cd2 <memset>
  log_write(bp);
    8000362a:	854a                	mv	a0,s2
    8000362c:	00001097          	auipc	ra,0x1
    80003630:	080080e7          	jalr	128(ra) # 800046ac <log_write>
  brelse(bp);
    80003634:	854a                	mv	a0,s2
    80003636:	00000097          	auipc	ra,0x0
    8000363a:	dec080e7          	jalr	-532(ra) # 80003422 <brelse>
}
    8000363e:	8526                	mv	a0,s1
    80003640:	60e6                	ld	ra,88(sp)
    80003642:	6446                	ld	s0,80(sp)
    80003644:	64a6                	ld	s1,72(sp)
    80003646:	6906                	ld	s2,64(sp)
    80003648:	79e2                	ld	s3,56(sp)
    8000364a:	7a42                	ld	s4,48(sp)
    8000364c:	7aa2                	ld	s5,40(sp)
    8000364e:	7b02                	ld	s6,32(sp)
    80003650:	6be2                	ld	s7,24(sp)
    80003652:	6c42                	ld	s8,16(sp)
    80003654:	6ca2                	ld	s9,8(sp)
    80003656:	6125                	addi	sp,sp,96
    80003658:	8082                	ret
    brelse(bp);
    8000365a:	854a                	mv	a0,s2
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	dc6080e7          	jalr	-570(ra) # 80003422 <brelse>
  for (b = 0; b < sb.size; b += BPB)
    80003664:	015c87bb          	addw	a5,s9,s5
    80003668:	00078a9b          	sext.w	s5,a5
    8000366c:	004b2703          	lw	a4,4(s6)
    80003670:	06eaf163          	bgeu	s5,a4,800036d2 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003674:	41fad79b          	sraiw	a5,s5,0x1f
    80003678:	0137d79b          	srliw	a5,a5,0x13
    8000367c:	015787bb          	addw	a5,a5,s5
    80003680:	40d7d79b          	sraiw	a5,a5,0xd
    80003684:	01cb2583          	lw	a1,28(s6)
    80003688:	9dbd                	addw	a1,a1,a5
    8000368a:	855e                	mv	a0,s7
    8000368c:	00000097          	auipc	ra,0x0
    80003690:	c66080e7          	jalr	-922(ra) # 800032f2 <bread>
    80003694:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003696:	004b2503          	lw	a0,4(s6)
    8000369a:	000a849b          	sext.w	s1,s5
    8000369e:	8762                	mv	a4,s8
    800036a0:	faa4fde3          	bgeu	s1,a0,8000365a <balloc+0xa6>
      m = 1 << (bi % 8);
    800036a4:	00777693          	andi	a3,a4,7
    800036a8:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0)
    800036ac:	41f7579b          	sraiw	a5,a4,0x1f
    800036b0:	01d7d79b          	srliw	a5,a5,0x1d
    800036b4:	9fb9                	addw	a5,a5,a4
    800036b6:	4037d79b          	sraiw	a5,a5,0x3
    800036ba:	00f90633          	add	a2,s2,a5
    800036be:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800036c2:	00c6f5b3          	and	a1,a3,a2
    800036c6:	d585                	beqz	a1,800035ee <balloc+0x3a>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800036c8:	2705                	addiw	a4,a4,1
    800036ca:	2485                	addiw	s1,s1,1
    800036cc:	fd471ae3          	bne	a4,s4,800036a0 <balloc+0xec>
    800036d0:	b769                	j	8000365a <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800036d2:	00005517          	auipc	a0,0x5
    800036d6:	e9650513          	addi	a0,a0,-362 # 80008568 <syscalls+0x118>
    800036da:	ffffd097          	auipc	ra,0xffffd
    800036de:	eb0080e7          	jalr	-336(ra) # 8000058a <printf>
  return 0;
    800036e2:	4481                	li	s1,0
    800036e4:	bfa9                	j	8000363e <balloc+0x8a>

00000000800036e6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800036e6:	7179                	addi	sp,sp,-48
    800036e8:	f406                	sd	ra,40(sp)
    800036ea:	f022                	sd	s0,32(sp)
    800036ec:	ec26                	sd	s1,24(sp)
    800036ee:	e84a                	sd	s2,16(sp)
    800036f0:	e44e                	sd	s3,8(sp)
    800036f2:	e052                	sd	s4,0(sp)
    800036f4:	1800                	addi	s0,sp,48
    800036f6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT)
    800036f8:	47ad                	li	a5,11
    800036fa:	02b7e863          	bltu	a5,a1,8000372a <bmap+0x44>
  {
    if ((addr = ip->addrs[bn]) == 0)
    800036fe:	02059793          	slli	a5,a1,0x20
    80003702:	01e7d593          	srli	a1,a5,0x1e
    80003706:	00b504b3          	add	s1,a0,a1
    8000370a:	0504a903          	lw	s2,80(s1)
    8000370e:	06091e63          	bnez	s2,8000378a <bmap+0xa4>
    {
      addr = balloc(ip->dev);
    80003712:	4108                	lw	a0,0(a0)
    80003714:	00000097          	auipc	ra,0x0
    80003718:	ea0080e7          	jalr	-352(ra) # 800035b4 <balloc>
    8000371c:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003720:	06090563          	beqz	s2,8000378a <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003724:	0524a823          	sw	s2,80(s1)
    80003728:	a08d                	j	8000378a <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000372a:	ff45849b          	addiw	s1,a1,-12
    8000372e:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT)
    80003732:	0ff00793          	li	a5,255
    80003736:	08e7e563          	bltu	a5,a4,800037c0 <bmap+0xda>
  {
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0)
    8000373a:	08052903          	lw	s2,128(a0)
    8000373e:	00091d63          	bnez	s2,80003758 <bmap+0x72>
    {
      addr = balloc(ip->dev);
    80003742:	4108                	lw	a0,0(a0)
    80003744:	00000097          	auipc	ra,0x0
    80003748:	e70080e7          	jalr	-400(ra) # 800035b4 <balloc>
    8000374c:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003750:	02090d63          	beqz	s2,8000378a <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003754:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003758:	85ca                	mv	a1,s2
    8000375a:	0009a503          	lw	a0,0(s3)
    8000375e:	00000097          	auipc	ra,0x0
    80003762:	b94080e7          	jalr	-1132(ra) # 800032f2 <bread>
    80003766:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003768:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0)
    8000376c:	02049713          	slli	a4,s1,0x20
    80003770:	01e75593          	srli	a1,a4,0x1e
    80003774:	00b784b3          	add	s1,a5,a1
    80003778:	0004a903          	lw	s2,0(s1)
    8000377c:	02090063          	beqz	s2,8000379c <bmap+0xb6>
      {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003780:	8552                	mv	a0,s4
    80003782:	00000097          	auipc	ra,0x0
    80003786:	ca0080e7          	jalr	-864(ra) # 80003422 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000378a:	854a                	mv	a0,s2
    8000378c:	70a2                	ld	ra,40(sp)
    8000378e:	7402                	ld	s0,32(sp)
    80003790:	64e2                	ld	s1,24(sp)
    80003792:	6942                	ld	s2,16(sp)
    80003794:	69a2                	ld	s3,8(sp)
    80003796:	6a02                	ld	s4,0(sp)
    80003798:	6145                	addi	sp,sp,48
    8000379a:	8082                	ret
      addr = balloc(ip->dev);
    8000379c:	0009a503          	lw	a0,0(s3)
    800037a0:	00000097          	auipc	ra,0x0
    800037a4:	e14080e7          	jalr	-492(ra) # 800035b4 <balloc>
    800037a8:	0005091b          	sext.w	s2,a0
      if (addr)
    800037ac:	fc090ae3          	beqz	s2,80003780 <bmap+0x9a>
        a[bn] = addr;
    800037b0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800037b4:	8552                	mv	a0,s4
    800037b6:	00001097          	auipc	ra,0x1
    800037ba:	ef6080e7          	jalr	-266(ra) # 800046ac <log_write>
    800037be:	b7c9                	j	80003780 <bmap+0x9a>
  panic("bmap: out of range");
    800037c0:	00005517          	auipc	a0,0x5
    800037c4:	dc050513          	addi	a0,a0,-576 # 80008580 <syscalls+0x130>
    800037c8:	ffffd097          	auipc	ra,0xffffd
    800037cc:	d78080e7          	jalr	-648(ra) # 80000540 <panic>

00000000800037d0 <iget>:
{
    800037d0:	7179                	addi	sp,sp,-48
    800037d2:	f406                	sd	ra,40(sp)
    800037d4:	f022                	sd	s0,32(sp)
    800037d6:	ec26                	sd	s1,24(sp)
    800037d8:	e84a                	sd	s2,16(sp)
    800037da:	e44e                	sd	s3,8(sp)
    800037dc:	e052                	sd	s4,0(sp)
    800037de:	1800                	addi	s0,sp,48
    800037e0:	89aa                	mv	s3,a0
    800037e2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800037e4:	0001d517          	auipc	a0,0x1d
    800037e8:	0e450513          	addi	a0,a0,228 # 800208c8 <itable>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	3ea080e7          	jalr	1002(ra) # 80000bd6 <acquire>
  empty = 0;
    800037f4:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    800037f6:	0001d497          	auipc	s1,0x1d
    800037fa:	0ea48493          	addi	s1,s1,234 # 800208e0 <itable+0x18>
    800037fe:	0001f697          	auipc	a3,0x1f
    80003802:	b7268693          	addi	a3,a3,-1166 # 80022370 <log>
    80003806:	a039                	j	80003814 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003808:	02090b63          	beqz	s2,8000383e <iget+0x6e>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    8000380c:	08848493          	addi	s1,s1,136
    80003810:	02d48a63          	beq	s1,a3,80003844 <iget+0x74>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum)
    80003814:	449c                	lw	a5,8(s1)
    80003816:	fef059e3          	blez	a5,80003808 <iget+0x38>
    8000381a:	4098                	lw	a4,0(s1)
    8000381c:	ff3716e3          	bne	a4,s3,80003808 <iget+0x38>
    80003820:	40d8                	lw	a4,4(s1)
    80003822:	ff4713e3          	bne	a4,s4,80003808 <iget+0x38>
      ip->ref++;
    80003826:	2785                	addiw	a5,a5,1
    80003828:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000382a:	0001d517          	auipc	a0,0x1d
    8000382e:	09e50513          	addi	a0,a0,158 # 800208c8 <itable>
    80003832:	ffffd097          	auipc	ra,0xffffd
    80003836:	458080e7          	jalr	1112(ra) # 80000c8a <release>
      return ip;
    8000383a:	8926                	mv	s2,s1
    8000383c:	a03d                	j	8000386a <iget+0x9a>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000383e:	f7f9                	bnez	a5,8000380c <iget+0x3c>
    80003840:	8926                	mv	s2,s1
    80003842:	b7e9                	j	8000380c <iget+0x3c>
  if (empty == 0)
    80003844:	02090c63          	beqz	s2,8000387c <iget+0xac>
  ip->dev = dev;
    80003848:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000384c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003850:	4785                	li	a5,1
    80003852:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003856:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000385a:	0001d517          	auipc	a0,0x1d
    8000385e:	06e50513          	addi	a0,a0,110 # 800208c8 <itable>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	428080e7          	jalr	1064(ra) # 80000c8a <release>
}
    8000386a:	854a                	mv	a0,s2
    8000386c:	70a2                	ld	ra,40(sp)
    8000386e:	7402                	ld	s0,32(sp)
    80003870:	64e2                	ld	s1,24(sp)
    80003872:	6942                	ld	s2,16(sp)
    80003874:	69a2                	ld	s3,8(sp)
    80003876:	6a02                	ld	s4,0(sp)
    80003878:	6145                	addi	sp,sp,48
    8000387a:	8082                	ret
    panic("iget: no inodes");
    8000387c:	00005517          	auipc	a0,0x5
    80003880:	d1c50513          	addi	a0,a0,-740 # 80008598 <syscalls+0x148>
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	cbc080e7          	jalr	-836(ra) # 80000540 <panic>

000000008000388c <fsinit>:
{
    8000388c:	7179                	addi	sp,sp,-48
    8000388e:	f406                	sd	ra,40(sp)
    80003890:	f022                	sd	s0,32(sp)
    80003892:	ec26                	sd	s1,24(sp)
    80003894:	e84a                	sd	s2,16(sp)
    80003896:	e44e                	sd	s3,8(sp)
    80003898:	1800                	addi	s0,sp,48
    8000389a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000389c:	4585                	li	a1,1
    8000389e:	00000097          	auipc	ra,0x0
    800038a2:	a54080e7          	jalr	-1452(ra) # 800032f2 <bread>
    800038a6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800038a8:	0001d997          	auipc	s3,0x1d
    800038ac:	00098993          	mv	s3,s3
    800038b0:	02000613          	li	a2,32
    800038b4:	05850593          	addi	a1,a0,88
    800038b8:	854e                	mv	a0,s3
    800038ba:	ffffd097          	auipc	ra,0xffffd
    800038be:	474080e7          	jalr	1140(ra) # 80000d2e <memmove>
  brelse(bp);
    800038c2:	8526                	mv	a0,s1
    800038c4:	00000097          	auipc	ra,0x0
    800038c8:	b5e080e7          	jalr	-1186(ra) # 80003422 <brelse>
  if (sb.magic != FSMAGIC)
    800038cc:	0009a703          	lw	a4,0(s3) # 800208a8 <sb>
    800038d0:	102037b7          	lui	a5,0x10203
    800038d4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038d8:	02f71263          	bne	a4,a5,800038fc <fsinit+0x70>
  initlog(dev, &sb);
    800038dc:	0001d597          	auipc	a1,0x1d
    800038e0:	fcc58593          	addi	a1,a1,-52 # 800208a8 <sb>
    800038e4:	854a                	mv	a0,s2
    800038e6:	00001097          	auipc	ra,0x1
    800038ea:	b4a080e7          	jalr	-1206(ra) # 80004430 <initlog>
}
    800038ee:	70a2                	ld	ra,40(sp)
    800038f0:	7402                	ld	s0,32(sp)
    800038f2:	64e2                	ld	s1,24(sp)
    800038f4:	6942                	ld	s2,16(sp)
    800038f6:	69a2                	ld	s3,8(sp)
    800038f8:	6145                	addi	sp,sp,48
    800038fa:	8082                	ret
    panic("invalid file system");
    800038fc:	00005517          	auipc	a0,0x5
    80003900:	cac50513          	addi	a0,a0,-852 # 800085a8 <syscalls+0x158>
    80003904:	ffffd097          	auipc	ra,0xffffd
    80003908:	c3c080e7          	jalr	-964(ra) # 80000540 <panic>

000000008000390c <iinit>:
{
    8000390c:	7179                	addi	sp,sp,-48
    8000390e:	f406                	sd	ra,40(sp)
    80003910:	f022                	sd	s0,32(sp)
    80003912:	ec26                	sd	s1,24(sp)
    80003914:	e84a                	sd	s2,16(sp)
    80003916:	e44e                	sd	s3,8(sp)
    80003918:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000391a:	00005597          	auipc	a1,0x5
    8000391e:	ca658593          	addi	a1,a1,-858 # 800085c0 <syscalls+0x170>
    80003922:	0001d517          	auipc	a0,0x1d
    80003926:	fa650513          	addi	a0,a0,-90 # 800208c8 <itable>
    8000392a:	ffffd097          	auipc	ra,0xffffd
    8000392e:	21c080e7          	jalr	540(ra) # 80000b46 <initlock>
  for (i = 0; i < NINODE; i++)
    80003932:	0001d497          	auipc	s1,0x1d
    80003936:	fbe48493          	addi	s1,s1,-66 # 800208f0 <itable+0x28>
    8000393a:	0001f997          	auipc	s3,0x1f
    8000393e:	a4698993          	addi	s3,s3,-1466 # 80022380 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003942:	00005917          	auipc	s2,0x5
    80003946:	c8690913          	addi	s2,s2,-890 # 800085c8 <syscalls+0x178>
    8000394a:	85ca                	mv	a1,s2
    8000394c:	8526                	mv	a0,s1
    8000394e:	00001097          	auipc	ra,0x1
    80003952:	e42080e7          	jalr	-446(ra) # 80004790 <initsleeplock>
  for (i = 0; i < NINODE; i++)
    80003956:	08848493          	addi	s1,s1,136
    8000395a:	ff3498e3          	bne	s1,s3,8000394a <iinit+0x3e>
}
    8000395e:	70a2                	ld	ra,40(sp)
    80003960:	7402                	ld	s0,32(sp)
    80003962:	64e2                	ld	s1,24(sp)
    80003964:	6942                	ld	s2,16(sp)
    80003966:	69a2                	ld	s3,8(sp)
    80003968:	6145                	addi	sp,sp,48
    8000396a:	8082                	ret

000000008000396c <ialloc>:
{
    8000396c:	715d                	addi	sp,sp,-80
    8000396e:	e486                	sd	ra,72(sp)
    80003970:	e0a2                	sd	s0,64(sp)
    80003972:	fc26                	sd	s1,56(sp)
    80003974:	f84a                	sd	s2,48(sp)
    80003976:	f44e                	sd	s3,40(sp)
    80003978:	f052                	sd	s4,32(sp)
    8000397a:	ec56                	sd	s5,24(sp)
    8000397c:	e85a                	sd	s6,16(sp)
    8000397e:	e45e                	sd	s7,8(sp)
    80003980:	0880                	addi	s0,sp,80
  for (inum = 1; inum < sb.ninodes; inum++)
    80003982:	0001d717          	auipc	a4,0x1d
    80003986:	f3272703          	lw	a4,-206(a4) # 800208b4 <sb+0xc>
    8000398a:	4785                	li	a5,1
    8000398c:	04e7fa63          	bgeu	a5,a4,800039e0 <ialloc+0x74>
    80003990:	8aaa                	mv	s5,a0
    80003992:	8bae                	mv	s7,a1
    80003994:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003996:	0001da17          	auipc	s4,0x1d
    8000399a:	f12a0a13          	addi	s4,s4,-238 # 800208a8 <sb>
    8000399e:	00048b1b          	sext.w	s6,s1
    800039a2:	0044d593          	srli	a1,s1,0x4
    800039a6:	018a2783          	lw	a5,24(s4)
    800039aa:	9dbd                	addw	a1,a1,a5
    800039ac:	8556                	mv	a0,s5
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	944080e7          	jalr	-1724(ra) # 800032f2 <bread>
    800039b6:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800039b8:	05850993          	addi	s3,a0,88
    800039bc:	00f4f793          	andi	a5,s1,15
    800039c0:	079a                	slli	a5,a5,0x6
    800039c2:	99be                	add	s3,s3,a5
    if (dip->type == 0)
    800039c4:	00099783          	lh	a5,0(s3)
    800039c8:	c3a1                	beqz	a5,80003a08 <ialloc+0x9c>
    brelse(bp);
    800039ca:	00000097          	auipc	ra,0x0
    800039ce:	a58080e7          	jalr	-1448(ra) # 80003422 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++)
    800039d2:	0485                	addi	s1,s1,1
    800039d4:	00ca2703          	lw	a4,12(s4)
    800039d8:	0004879b          	sext.w	a5,s1
    800039dc:	fce7e1e3          	bltu	a5,a4,8000399e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800039e0:	00005517          	auipc	a0,0x5
    800039e4:	bf050513          	addi	a0,a0,-1040 # 800085d0 <syscalls+0x180>
    800039e8:	ffffd097          	auipc	ra,0xffffd
    800039ec:	ba2080e7          	jalr	-1118(ra) # 8000058a <printf>
  return 0;
    800039f0:	4501                	li	a0,0
}
    800039f2:	60a6                	ld	ra,72(sp)
    800039f4:	6406                	ld	s0,64(sp)
    800039f6:	74e2                	ld	s1,56(sp)
    800039f8:	7942                	ld	s2,48(sp)
    800039fa:	79a2                	ld	s3,40(sp)
    800039fc:	7a02                	ld	s4,32(sp)
    800039fe:	6ae2                	ld	s5,24(sp)
    80003a00:	6b42                	ld	s6,16(sp)
    80003a02:	6ba2                	ld	s7,8(sp)
    80003a04:	6161                	addi	sp,sp,80
    80003a06:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a08:	04000613          	li	a2,64
    80003a0c:	4581                	li	a1,0
    80003a0e:	854e                	mv	a0,s3
    80003a10:	ffffd097          	auipc	ra,0xffffd
    80003a14:	2c2080e7          	jalr	706(ra) # 80000cd2 <memset>
      dip->type = type;
    80003a18:	01799023          	sh	s7,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003a1c:	854a                	mv	a0,s2
    80003a1e:	00001097          	auipc	ra,0x1
    80003a22:	c8e080e7          	jalr	-882(ra) # 800046ac <log_write>
      brelse(bp);
    80003a26:	854a                	mv	a0,s2
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	9fa080e7          	jalr	-1542(ra) # 80003422 <brelse>
      return iget(dev, inum);
    80003a30:	85da                	mv	a1,s6
    80003a32:	8556                	mv	a0,s5
    80003a34:	00000097          	auipc	ra,0x0
    80003a38:	d9c080e7          	jalr	-612(ra) # 800037d0 <iget>
    80003a3c:	bf5d                	j	800039f2 <ialloc+0x86>

0000000080003a3e <iupdate>:
{
    80003a3e:	1101                	addi	sp,sp,-32
    80003a40:	ec06                	sd	ra,24(sp)
    80003a42:	e822                	sd	s0,16(sp)
    80003a44:	e426                	sd	s1,8(sp)
    80003a46:	e04a                	sd	s2,0(sp)
    80003a48:	1000                	addi	s0,sp,32
    80003a4a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a4c:	415c                	lw	a5,4(a0)
    80003a4e:	0047d79b          	srliw	a5,a5,0x4
    80003a52:	0001d597          	auipc	a1,0x1d
    80003a56:	e6e5a583          	lw	a1,-402(a1) # 800208c0 <sb+0x18>
    80003a5a:	9dbd                	addw	a1,a1,a5
    80003a5c:	4108                	lw	a0,0(a0)
    80003a5e:	00000097          	auipc	ra,0x0
    80003a62:	894080e7          	jalr	-1900(ra) # 800032f2 <bread>
    80003a66:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003a68:	05850793          	addi	a5,a0,88
    80003a6c:	40d8                	lw	a4,4(s1)
    80003a6e:	8b3d                	andi	a4,a4,15
    80003a70:	071a                	slli	a4,a4,0x6
    80003a72:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003a74:	04449703          	lh	a4,68(s1)
    80003a78:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003a7c:	04649703          	lh	a4,70(s1)
    80003a80:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003a84:	04849703          	lh	a4,72(s1)
    80003a88:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003a8c:	04a49703          	lh	a4,74(s1)
    80003a90:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003a94:	44f8                	lw	a4,76(s1)
    80003a96:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a98:	03400613          	li	a2,52
    80003a9c:	05048593          	addi	a1,s1,80
    80003aa0:	00c78513          	addi	a0,a5,12
    80003aa4:	ffffd097          	auipc	ra,0xffffd
    80003aa8:	28a080e7          	jalr	650(ra) # 80000d2e <memmove>
  log_write(bp);
    80003aac:	854a                	mv	a0,s2
    80003aae:	00001097          	auipc	ra,0x1
    80003ab2:	bfe080e7          	jalr	-1026(ra) # 800046ac <log_write>
  brelse(bp);
    80003ab6:	854a                	mv	a0,s2
    80003ab8:	00000097          	auipc	ra,0x0
    80003abc:	96a080e7          	jalr	-1686(ra) # 80003422 <brelse>
}
    80003ac0:	60e2                	ld	ra,24(sp)
    80003ac2:	6442                	ld	s0,16(sp)
    80003ac4:	64a2                	ld	s1,8(sp)
    80003ac6:	6902                	ld	s2,0(sp)
    80003ac8:	6105                	addi	sp,sp,32
    80003aca:	8082                	ret

0000000080003acc <idup>:
{
    80003acc:	1101                	addi	sp,sp,-32
    80003ace:	ec06                	sd	ra,24(sp)
    80003ad0:	e822                	sd	s0,16(sp)
    80003ad2:	e426                	sd	s1,8(sp)
    80003ad4:	1000                	addi	s0,sp,32
    80003ad6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ad8:	0001d517          	auipc	a0,0x1d
    80003adc:	df050513          	addi	a0,a0,-528 # 800208c8 <itable>
    80003ae0:	ffffd097          	auipc	ra,0xffffd
    80003ae4:	0f6080e7          	jalr	246(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003ae8:	449c                	lw	a5,8(s1)
    80003aea:	2785                	addiw	a5,a5,1
    80003aec:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003aee:	0001d517          	auipc	a0,0x1d
    80003af2:	dda50513          	addi	a0,a0,-550 # 800208c8 <itable>
    80003af6:	ffffd097          	auipc	ra,0xffffd
    80003afa:	194080e7          	jalr	404(ra) # 80000c8a <release>
}
    80003afe:	8526                	mv	a0,s1
    80003b00:	60e2                	ld	ra,24(sp)
    80003b02:	6442                	ld	s0,16(sp)
    80003b04:	64a2                	ld	s1,8(sp)
    80003b06:	6105                	addi	sp,sp,32
    80003b08:	8082                	ret

0000000080003b0a <ilock>:
{
    80003b0a:	1101                	addi	sp,sp,-32
    80003b0c:	ec06                	sd	ra,24(sp)
    80003b0e:	e822                	sd	s0,16(sp)
    80003b10:	e426                	sd	s1,8(sp)
    80003b12:	e04a                	sd	s2,0(sp)
    80003b14:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003b16:	c115                	beqz	a0,80003b3a <ilock+0x30>
    80003b18:	84aa                	mv	s1,a0
    80003b1a:	451c                	lw	a5,8(a0)
    80003b1c:	00f05f63          	blez	a5,80003b3a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b20:	0541                	addi	a0,a0,16
    80003b22:	00001097          	auipc	ra,0x1
    80003b26:	ca8080e7          	jalr	-856(ra) # 800047ca <acquiresleep>
  if (ip->valid == 0)
    80003b2a:	40bc                	lw	a5,64(s1)
    80003b2c:	cf99                	beqz	a5,80003b4a <ilock+0x40>
}
    80003b2e:	60e2                	ld	ra,24(sp)
    80003b30:	6442                	ld	s0,16(sp)
    80003b32:	64a2                	ld	s1,8(sp)
    80003b34:	6902                	ld	s2,0(sp)
    80003b36:	6105                	addi	sp,sp,32
    80003b38:	8082                	ret
    panic("ilock");
    80003b3a:	00005517          	auipc	a0,0x5
    80003b3e:	aae50513          	addi	a0,a0,-1362 # 800085e8 <syscalls+0x198>
    80003b42:	ffffd097          	auipc	ra,0xffffd
    80003b46:	9fe080e7          	jalr	-1538(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b4a:	40dc                	lw	a5,4(s1)
    80003b4c:	0047d79b          	srliw	a5,a5,0x4
    80003b50:	0001d597          	auipc	a1,0x1d
    80003b54:	d705a583          	lw	a1,-656(a1) # 800208c0 <sb+0x18>
    80003b58:	9dbd                	addw	a1,a1,a5
    80003b5a:	4088                	lw	a0,0(s1)
    80003b5c:	fffff097          	auipc	ra,0xfffff
    80003b60:	796080e7          	jalr	1942(ra) # 800032f2 <bread>
    80003b64:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003b66:	05850593          	addi	a1,a0,88
    80003b6a:	40dc                	lw	a5,4(s1)
    80003b6c:	8bbd                	andi	a5,a5,15
    80003b6e:	079a                	slli	a5,a5,0x6
    80003b70:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b72:	00059783          	lh	a5,0(a1)
    80003b76:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b7a:	00259783          	lh	a5,2(a1)
    80003b7e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b82:	00459783          	lh	a5,4(a1)
    80003b86:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b8a:	00659783          	lh	a5,6(a1)
    80003b8e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b92:	459c                	lw	a5,8(a1)
    80003b94:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b96:	03400613          	li	a2,52
    80003b9a:	05b1                	addi	a1,a1,12
    80003b9c:	05048513          	addi	a0,s1,80
    80003ba0:	ffffd097          	auipc	ra,0xffffd
    80003ba4:	18e080e7          	jalr	398(ra) # 80000d2e <memmove>
    brelse(bp);
    80003ba8:	854a                	mv	a0,s2
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	878080e7          	jalr	-1928(ra) # 80003422 <brelse>
    ip->valid = 1;
    80003bb2:	4785                	li	a5,1
    80003bb4:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003bb6:	04449783          	lh	a5,68(s1)
    80003bba:	fbb5                	bnez	a5,80003b2e <ilock+0x24>
      panic("ilock: no type");
    80003bbc:	00005517          	auipc	a0,0x5
    80003bc0:	a3450513          	addi	a0,a0,-1484 # 800085f0 <syscalls+0x1a0>
    80003bc4:	ffffd097          	auipc	ra,0xffffd
    80003bc8:	97c080e7          	jalr	-1668(ra) # 80000540 <panic>

0000000080003bcc <iunlock>:
{
    80003bcc:	1101                	addi	sp,sp,-32
    80003bce:	ec06                	sd	ra,24(sp)
    80003bd0:	e822                	sd	s0,16(sp)
    80003bd2:	e426                	sd	s1,8(sp)
    80003bd4:	e04a                	sd	s2,0(sp)
    80003bd6:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003bd8:	c905                	beqz	a0,80003c08 <iunlock+0x3c>
    80003bda:	84aa                	mv	s1,a0
    80003bdc:	01050913          	addi	s2,a0,16
    80003be0:	854a                	mv	a0,s2
    80003be2:	00001097          	auipc	ra,0x1
    80003be6:	c82080e7          	jalr	-894(ra) # 80004864 <holdingsleep>
    80003bea:	cd19                	beqz	a0,80003c08 <iunlock+0x3c>
    80003bec:	449c                	lw	a5,8(s1)
    80003bee:	00f05d63          	blez	a5,80003c08 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003bf2:	854a                	mv	a0,s2
    80003bf4:	00001097          	auipc	ra,0x1
    80003bf8:	c2c080e7          	jalr	-980(ra) # 80004820 <releasesleep>
}
    80003bfc:	60e2                	ld	ra,24(sp)
    80003bfe:	6442                	ld	s0,16(sp)
    80003c00:	64a2                	ld	s1,8(sp)
    80003c02:	6902                	ld	s2,0(sp)
    80003c04:	6105                	addi	sp,sp,32
    80003c06:	8082                	ret
    panic("iunlock");
    80003c08:	00005517          	auipc	a0,0x5
    80003c0c:	9f850513          	addi	a0,a0,-1544 # 80008600 <syscalls+0x1b0>
    80003c10:	ffffd097          	auipc	ra,0xffffd
    80003c14:	930080e7          	jalr	-1744(ra) # 80000540 <panic>

0000000080003c18 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void itrunc(struct inode *ip)
{
    80003c18:	7179                	addi	sp,sp,-48
    80003c1a:	f406                	sd	ra,40(sp)
    80003c1c:	f022                	sd	s0,32(sp)
    80003c1e:	ec26                	sd	s1,24(sp)
    80003c20:	e84a                	sd	s2,16(sp)
    80003c22:	e44e                	sd	s3,8(sp)
    80003c24:	e052                	sd	s4,0(sp)
    80003c26:	1800                	addi	s0,sp,48
    80003c28:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++)
    80003c2a:	05050493          	addi	s1,a0,80
    80003c2e:	08050913          	addi	s2,a0,128
    80003c32:	a021                	j	80003c3a <itrunc+0x22>
    80003c34:	0491                	addi	s1,s1,4
    80003c36:	01248d63          	beq	s1,s2,80003c50 <itrunc+0x38>
  {
    if (ip->addrs[i])
    80003c3a:	408c                	lw	a1,0(s1)
    80003c3c:	dde5                	beqz	a1,80003c34 <itrunc+0x1c>
    {
      bfree(ip->dev, ip->addrs[i]);
    80003c3e:	0009a503          	lw	a0,0(s3)
    80003c42:	00000097          	auipc	ra,0x0
    80003c46:	8f6080e7          	jalr	-1802(ra) # 80003538 <bfree>
      ip->addrs[i] = 0;
    80003c4a:	0004a023          	sw	zero,0(s1)
    80003c4e:	b7dd                	j	80003c34 <itrunc+0x1c>
    }
  }

  if (ip->addrs[NDIRECT])
    80003c50:	0809a583          	lw	a1,128(s3)
    80003c54:	e185                	bnez	a1,80003c74 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c56:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c5a:	854e                	mv	a0,s3
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	de2080e7          	jalr	-542(ra) # 80003a3e <iupdate>
}
    80003c64:	70a2                	ld	ra,40(sp)
    80003c66:	7402                	ld	s0,32(sp)
    80003c68:	64e2                	ld	s1,24(sp)
    80003c6a:	6942                	ld	s2,16(sp)
    80003c6c:	69a2                	ld	s3,8(sp)
    80003c6e:	6a02                	ld	s4,0(sp)
    80003c70:	6145                	addi	sp,sp,48
    80003c72:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c74:	0009a503          	lw	a0,0(s3)
    80003c78:	fffff097          	auipc	ra,0xfffff
    80003c7c:	67a080e7          	jalr	1658(ra) # 800032f2 <bread>
    80003c80:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++)
    80003c82:	05850493          	addi	s1,a0,88
    80003c86:	45850913          	addi	s2,a0,1112
    80003c8a:	a021                	j	80003c92 <itrunc+0x7a>
    80003c8c:	0491                	addi	s1,s1,4
    80003c8e:	01248b63          	beq	s1,s2,80003ca4 <itrunc+0x8c>
      if (a[j])
    80003c92:	408c                	lw	a1,0(s1)
    80003c94:	dde5                	beqz	a1,80003c8c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c96:	0009a503          	lw	a0,0(s3)
    80003c9a:	00000097          	auipc	ra,0x0
    80003c9e:	89e080e7          	jalr	-1890(ra) # 80003538 <bfree>
    80003ca2:	b7ed                	j	80003c8c <itrunc+0x74>
    brelse(bp);
    80003ca4:	8552                	mv	a0,s4
    80003ca6:	fffff097          	auipc	ra,0xfffff
    80003caa:	77c080e7          	jalr	1916(ra) # 80003422 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003cae:	0809a583          	lw	a1,128(s3)
    80003cb2:	0009a503          	lw	a0,0(s3)
    80003cb6:	00000097          	auipc	ra,0x0
    80003cba:	882080e7          	jalr	-1918(ra) # 80003538 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003cbe:	0809a023          	sw	zero,128(s3)
    80003cc2:	bf51                	j	80003c56 <itrunc+0x3e>

0000000080003cc4 <iput>:
{
    80003cc4:	1101                	addi	sp,sp,-32
    80003cc6:	ec06                	sd	ra,24(sp)
    80003cc8:	e822                	sd	s0,16(sp)
    80003cca:	e426                	sd	s1,8(sp)
    80003ccc:	e04a                	sd	s2,0(sp)
    80003cce:	1000                	addi	s0,sp,32
    80003cd0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cd2:	0001d517          	auipc	a0,0x1d
    80003cd6:	bf650513          	addi	a0,a0,-1034 # 800208c8 <itable>
    80003cda:	ffffd097          	auipc	ra,0xffffd
    80003cde:	efc080e7          	jalr	-260(ra) # 80000bd6 <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003ce2:	4498                	lw	a4,8(s1)
    80003ce4:	4785                	li	a5,1
    80003ce6:	02f70363          	beq	a4,a5,80003d0c <iput+0x48>
  ip->ref--;
    80003cea:	449c                	lw	a5,8(s1)
    80003cec:	37fd                	addiw	a5,a5,-1
    80003cee:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cf0:	0001d517          	auipc	a0,0x1d
    80003cf4:	bd850513          	addi	a0,a0,-1064 # 800208c8 <itable>
    80003cf8:	ffffd097          	auipc	ra,0xffffd
    80003cfc:	f92080e7          	jalr	-110(ra) # 80000c8a <release>
}
    80003d00:	60e2                	ld	ra,24(sp)
    80003d02:	6442                	ld	s0,16(sp)
    80003d04:	64a2                	ld	s1,8(sp)
    80003d06:	6902                	ld	s2,0(sp)
    80003d08:	6105                	addi	sp,sp,32
    80003d0a:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003d0c:	40bc                	lw	a5,64(s1)
    80003d0e:	dff1                	beqz	a5,80003cea <iput+0x26>
    80003d10:	04a49783          	lh	a5,74(s1)
    80003d14:	fbf9                	bnez	a5,80003cea <iput+0x26>
    acquiresleep(&ip->lock);
    80003d16:	01048913          	addi	s2,s1,16
    80003d1a:	854a                	mv	a0,s2
    80003d1c:	00001097          	auipc	ra,0x1
    80003d20:	aae080e7          	jalr	-1362(ra) # 800047ca <acquiresleep>
    release(&itable.lock);
    80003d24:	0001d517          	auipc	a0,0x1d
    80003d28:	ba450513          	addi	a0,a0,-1116 # 800208c8 <itable>
    80003d2c:	ffffd097          	auipc	ra,0xffffd
    80003d30:	f5e080e7          	jalr	-162(ra) # 80000c8a <release>
    itrunc(ip);
    80003d34:	8526                	mv	a0,s1
    80003d36:	00000097          	auipc	ra,0x0
    80003d3a:	ee2080e7          	jalr	-286(ra) # 80003c18 <itrunc>
    ip->type = 0;
    80003d3e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d42:	8526                	mv	a0,s1
    80003d44:	00000097          	auipc	ra,0x0
    80003d48:	cfa080e7          	jalr	-774(ra) # 80003a3e <iupdate>
    ip->valid = 0;
    80003d4c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d50:	854a                	mv	a0,s2
    80003d52:	00001097          	auipc	ra,0x1
    80003d56:	ace080e7          	jalr	-1330(ra) # 80004820 <releasesleep>
    acquire(&itable.lock);
    80003d5a:	0001d517          	auipc	a0,0x1d
    80003d5e:	b6e50513          	addi	a0,a0,-1170 # 800208c8 <itable>
    80003d62:	ffffd097          	auipc	ra,0xffffd
    80003d66:	e74080e7          	jalr	-396(ra) # 80000bd6 <acquire>
    80003d6a:	b741                	j	80003cea <iput+0x26>

0000000080003d6c <iunlockput>:
{
    80003d6c:	1101                	addi	sp,sp,-32
    80003d6e:	ec06                	sd	ra,24(sp)
    80003d70:	e822                	sd	s0,16(sp)
    80003d72:	e426                	sd	s1,8(sp)
    80003d74:	1000                	addi	s0,sp,32
    80003d76:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d78:	00000097          	auipc	ra,0x0
    80003d7c:	e54080e7          	jalr	-428(ra) # 80003bcc <iunlock>
  iput(ip);
    80003d80:	8526                	mv	a0,s1
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	f42080e7          	jalr	-190(ra) # 80003cc4 <iput>
}
    80003d8a:	60e2                	ld	ra,24(sp)
    80003d8c:	6442                	ld	s0,16(sp)
    80003d8e:	64a2                	ld	s1,8(sp)
    80003d90:	6105                	addi	sp,sp,32
    80003d92:	8082                	ret

0000000080003d94 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void stati(struct inode *ip, struct stat *st)
{
    80003d94:	1141                	addi	sp,sp,-16
    80003d96:	e422                	sd	s0,8(sp)
    80003d98:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d9a:	411c                	lw	a5,0(a0)
    80003d9c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d9e:	415c                	lw	a5,4(a0)
    80003da0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003da2:	04451783          	lh	a5,68(a0)
    80003da6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003daa:	04a51783          	lh	a5,74(a0)
    80003dae:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003db2:	04c56783          	lwu	a5,76(a0)
    80003db6:	e99c                	sd	a5,16(a1)
}
    80003db8:	6422                	ld	s0,8(sp)
    80003dba:	0141                	addi	sp,sp,16
    80003dbc:	8082                	ret

0000000080003dbe <readi>:
int readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003dbe:	457c                	lw	a5,76(a0)
    80003dc0:	0ed7e963          	bltu	a5,a3,80003eb2 <readi+0xf4>
{
    80003dc4:	7159                	addi	sp,sp,-112
    80003dc6:	f486                	sd	ra,104(sp)
    80003dc8:	f0a2                	sd	s0,96(sp)
    80003dca:	eca6                	sd	s1,88(sp)
    80003dcc:	e8ca                	sd	s2,80(sp)
    80003dce:	e4ce                	sd	s3,72(sp)
    80003dd0:	e0d2                	sd	s4,64(sp)
    80003dd2:	fc56                	sd	s5,56(sp)
    80003dd4:	f85a                	sd	s6,48(sp)
    80003dd6:	f45e                	sd	s7,40(sp)
    80003dd8:	f062                	sd	s8,32(sp)
    80003dda:	ec66                	sd	s9,24(sp)
    80003ddc:	e86a                	sd	s10,16(sp)
    80003dde:	e46e                	sd	s11,8(sp)
    80003de0:	1880                	addi	s0,sp,112
    80003de2:	8b2a                	mv	s6,a0
    80003de4:	8bae                	mv	s7,a1
    80003de6:	8a32                	mv	s4,a2
    80003de8:	84b6                	mv	s1,a3
    80003dea:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003dec:	9f35                	addw	a4,a4,a3
    return 0;
    80003dee:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003df0:	0ad76063          	bltu	a4,a3,80003e90 <readi+0xd2>
  if (off + n > ip->size)
    80003df4:	00e7f463          	bgeu	a5,a4,80003dfc <readi+0x3e>
    n = ip->size - off;
    80003df8:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003dfc:	0a0a8963          	beqz	s5,80003eae <readi+0xf0>
    80003e00:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003e02:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1)
    80003e06:	5c7d                	li	s8,-1
    80003e08:	a82d                	j	80003e42 <readi+0x84>
    80003e0a:	020d1d93          	slli	s11,s10,0x20
    80003e0e:	020ddd93          	srli	s11,s11,0x20
    80003e12:	05890613          	addi	a2,s2,88
    80003e16:	86ee                	mv	a3,s11
    80003e18:	963a                	add	a2,a2,a4
    80003e1a:	85d2                	mv	a1,s4
    80003e1c:	855e                	mv	a0,s7
    80003e1e:	ffffe097          	auipc	ra,0xffffe
    80003e22:	7be080e7          	jalr	1982(ra) # 800025dc <either_copyout>
    80003e26:	05850d63          	beq	a0,s8,80003e80 <readi+0xc2>
    {
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e2a:	854a                	mv	a0,s2
    80003e2c:	fffff097          	auipc	ra,0xfffff
    80003e30:	5f6080e7          	jalr	1526(ra) # 80003422 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003e34:	013d09bb          	addw	s3,s10,s3
    80003e38:	009d04bb          	addw	s1,s10,s1
    80003e3c:	9a6e                	add	s4,s4,s11
    80003e3e:	0559f763          	bgeu	s3,s5,80003e8c <readi+0xce>
    uint addr = bmap(ip, off / BSIZE);
    80003e42:	00a4d59b          	srliw	a1,s1,0xa
    80003e46:	855a                	mv	a0,s6
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	89e080e7          	jalr	-1890(ra) # 800036e6 <bmap>
    80003e50:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003e54:	cd85                	beqz	a1,80003e8c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003e56:	000b2503          	lw	a0,0(s6)
    80003e5a:	fffff097          	auipc	ra,0xfffff
    80003e5e:	498080e7          	jalr	1176(ra) # 800032f2 <bread>
    80003e62:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003e64:	3ff4f713          	andi	a4,s1,1023
    80003e68:	40ec87bb          	subw	a5,s9,a4
    80003e6c:	413a86bb          	subw	a3,s5,s3
    80003e70:	8d3e                	mv	s10,a5
    80003e72:	2781                	sext.w	a5,a5
    80003e74:	0006861b          	sext.w	a2,a3
    80003e78:	f8f679e3          	bgeu	a2,a5,80003e0a <readi+0x4c>
    80003e7c:	8d36                	mv	s10,a3
    80003e7e:	b771                	j	80003e0a <readi+0x4c>
      brelse(bp);
    80003e80:	854a                	mv	a0,s2
    80003e82:	fffff097          	auipc	ra,0xfffff
    80003e86:	5a0080e7          	jalr	1440(ra) # 80003422 <brelse>
      tot = -1;
    80003e8a:	59fd                	li	s3,-1
  }
  return tot;
    80003e8c:	0009851b          	sext.w	a0,s3
}
    80003e90:	70a6                	ld	ra,104(sp)
    80003e92:	7406                	ld	s0,96(sp)
    80003e94:	64e6                	ld	s1,88(sp)
    80003e96:	6946                	ld	s2,80(sp)
    80003e98:	69a6                	ld	s3,72(sp)
    80003e9a:	6a06                	ld	s4,64(sp)
    80003e9c:	7ae2                	ld	s5,56(sp)
    80003e9e:	7b42                	ld	s6,48(sp)
    80003ea0:	7ba2                	ld	s7,40(sp)
    80003ea2:	7c02                	ld	s8,32(sp)
    80003ea4:	6ce2                	ld	s9,24(sp)
    80003ea6:	6d42                	ld	s10,16(sp)
    80003ea8:	6da2                	ld	s11,8(sp)
    80003eaa:	6165                	addi	sp,sp,112
    80003eac:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003eae:	89d6                	mv	s3,s5
    80003eb0:	bff1                	j	80003e8c <readi+0xce>
    return 0;
    80003eb2:	4501                	li	a0,0
}
    80003eb4:	8082                	ret

0000000080003eb6 <writei>:
int writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003eb6:	457c                	lw	a5,76(a0)
    80003eb8:	10d7e863          	bltu	a5,a3,80003fc8 <writei+0x112>
{
    80003ebc:	7159                	addi	sp,sp,-112
    80003ebe:	f486                	sd	ra,104(sp)
    80003ec0:	f0a2                	sd	s0,96(sp)
    80003ec2:	eca6                	sd	s1,88(sp)
    80003ec4:	e8ca                	sd	s2,80(sp)
    80003ec6:	e4ce                	sd	s3,72(sp)
    80003ec8:	e0d2                	sd	s4,64(sp)
    80003eca:	fc56                	sd	s5,56(sp)
    80003ecc:	f85a                	sd	s6,48(sp)
    80003ece:	f45e                	sd	s7,40(sp)
    80003ed0:	f062                	sd	s8,32(sp)
    80003ed2:	ec66                	sd	s9,24(sp)
    80003ed4:	e86a                	sd	s10,16(sp)
    80003ed6:	e46e                	sd	s11,8(sp)
    80003ed8:	1880                	addi	s0,sp,112
    80003eda:	8aaa                	mv	s5,a0
    80003edc:	8bae                	mv	s7,a1
    80003ede:	8a32                	mv	s4,a2
    80003ee0:	8936                	mv	s2,a3
    80003ee2:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003ee4:	00e687bb          	addw	a5,a3,a4
    80003ee8:	0ed7e263          	bltu	a5,a3,80003fcc <writei+0x116>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003eec:	00043737          	lui	a4,0x43
    80003ef0:	0ef76063          	bltu	a4,a5,80003fd0 <writei+0x11a>
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003ef4:	0c0b0863          	beqz	s6,80003fc4 <writei+0x10e>
    80003ef8:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003efa:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1)
    80003efe:	5c7d                	li	s8,-1
    80003f00:	a091                	j	80003f44 <writei+0x8e>
    80003f02:	020d1d93          	slli	s11,s10,0x20
    80003f06:	020ddd93          	srli	s11,s11,0x20
    80003f0a:	05848513          	addi	a0,s1,88
    80003f0e:	86ee                	mv	a3,s11
    80003f10:	8652                	mv	a2,s4
    80003f12:	85de                	mv	a1,s7
    80003f14:	953a                	add	a0,a0,a4
    80003f16:	ffffe097          	auipc	ra,0xffffe
    80003f1a:	71c080e7          	jalr	1820(ra) # 80002632 <either_copyin>
    80003f1e:	07850263          	beq	a0,s8,80003f82 <writei+0xcc>
    {
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f22:	8526                	mv	a0,s1
    80003f24:	00000097          	auipc	ra,0x0
    80003f28:	788080e7          	jalr	1928(ra) # 800046ac <log_write>
    brelse(bp);
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	fffff097          	auipc	ra,0xfffff
    80003f32:	4f4080e7          	jalr	1268(ra) # 80003422 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003f36:	013d09bb          	addw	s3,s10,s3
    80003f3a:	012d093b          	addw	s2,s10,s2
    80003f3e:	9a6e                	add	s4,s4,s11
    80003f40:	0569f663          	bgeu	s3,s6,80003f8c <writei+0xd6>
    uint addr = bmap(ip, off / BSIZE);
    80003f44:	00a9559b          	srliw	a1,s2,0xa
    80003f48:	8556                	mv	a0,s5
    80003f4a:	fffff097          	auipc	ra,0xfffff
    80003f4e:	79c080e7          	jalr	1948(ra) # 800036e6 <bmap>
    80003f52:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003f56:	c99d                	beqz	a1,80003f8c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003f58:	000aa503          	lw	a0,0(s5)
    80003f5c:	fffff097          	auipc	ra,0xfffff
    80003f60:	396080e7          	jalr	918(ra) # 800032f2 <bread>
    80003f64:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003f66:	3ff97713          	andi	a4,s2,1023
    80003f6a:	40ec87bb          	subw	a5,s9,a4
    80003f6e:	413b06bb          	subw	a3,s6,s3
    80003f72:	8d3e                	mv	s10,a5
    80003f74:	2781                	sext.w	a5,a5
    80003f76:	0006861b          	sext.w	a2,a3
    80003f7a:	f8f674e3          	bgeu	a2,a5,80003f02 <writei+0x4c>
    80003f7e:	8d36                	mv	s10,a3
    80003f80:	b749                	j	80003f02 <writei+0x4c>
      brelse(bp);
    80003f82:	8526                	mv	a0,s1
    80003f84:	fffff097          	auipc	ra,0xfffff
    80003f88:	49e080e7          	jalr	1182(ra) # 80003422 <brelse>
  }

  if (off > ip->size)
    80003f8c:	04caa783          	lw	a5,76(s5)
    80003f90:	0127f463          	bgeu	a5,s2,80003f98 <writei+0xe2>
    ip->size = off;
    80003f94:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f98:	8556                	mv	a0,s5
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	aa4080e7          	jalr	-1372(ra) # 80003a3e <iupdate>

  return tot;
    80003fa2:	0009851b          	sext.w	a0,s3
}
    80003fa6:	70a6                	ld	ra,104(sp)
    80003fa8:	7406                	ld	s0,96(sp)
    80003faa:	64e6                	ld	s1,88(sp)
    80003fac:	6946                	ld	s2,80(sp)
    80003fae:	69a6                	ld	s3,72(sp)
    80003fb0:	6a06                	ld	s4,64(sp)
    80003fb2:	7ae2                	ld	s5,56(sp)
    80003fb4:	7b42                	ld	s6,48(sp)
    80003fb6:	7ba2                	ld	s7,40(sp)
    80003fb8:	7c02                	ld	s8,32(sp)
    80003fba:	6ce2                	ld	s9,24(sp)
    80003fbc:	6d42                	ld	s10,16(sp)
    80003fbe:	6da2                	ld	s11,8(sp)
    80003fc0:	6165                	addi	sp,sp,112
    80003fc2:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003fc4:	89da                	mv	s3,s6
    80003fc6:	bfc9                	j	80003f98 <writei+0xe2>
    return -1;
    80003fc8:	557d                	li	a0,-1
}
    80003fca:	8082                	ret
    return -1;
    80003fcc:	557d                	li	a0,-1
    80003fce:	bfe1                	j	80003fa6 <writei+0xf0>
    return -1;
    80003fd0:	557d                	li	a0,-1
    80003fd2:	bfd1                	j	80003fa6 <writei+0xf0>

0000000080003fd4 <namecmp>:

// Directories

int namecmp(const char *s, const char *t)
{
    80003fd4:	1141                	addi	sp,sp,-16
    80003fd6:	e406                	sd	ra,8(sp)
    80003fd8:	e022                	sd	s0,0(sp)
    80003fda:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003fdc:	4639                	li	a2,14
    80003fde:	ffffd097          	auipc	ra,0xffffd
    80003fe2:	dc4080e7          	jalr	-572(ra) # 80000da2 <strncmp>
}
    80003fe6:	60a2                	ld	ra,8(sp)
    80003fe8:	6402                	ld	s0,0(sp)
    80003fea:	0141                	addi	sp,sp,16
    80003fec:	8082                	ret

0000000080003fee <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003fee:	7139                	addi	sp,sp,-64
    80003ff0:	fc06                	sd	ra,56(sp)
    80003ff2:	f822                	sd	s0,48(sp)
    80003ff4:	f426                	sd	s1,40(sp)
    80003ff6:	f04a                	sd	s2,32(sp)
    80003ff8:	ec4e                	sd	s3,24(sp)
    80003ffa:	e852                	sd	s4,16(sp)
    80003ffc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003ffe:	04451703          	lh	a4,68(a0)
    80004002:	4785                	li	a5,1
    80004004:	00f71a63          	bne	a4,a5,80004018 <dirlookup+0x2a>
    80004008:	892a                	mv	s2,a0
    8000400a:	89ae                	mv	s3,a1
    8000400c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de))
    8000400e:	457c                	lw	a5,76(a0)
    80004010:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004012:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de))
    80004014:	e79d                	bnez	a5,80004042 <dirlookup+0x54>
    80004016:	a8a5                	j	8000408e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004018:	00004517          	auipc	a0,0x4
    8000401c:	5f050513          	addi	a0,a0,1520 # 80008608 <syscalls+0x1b8>
    80004020:	ffffc097          	auipc	ra,0xffffc
    80004024:	520080e7          	jalr	1312(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004028:	00004517          	auipc	a0,0x4
    8000402c:	5f850513          	addi	a0,a0,1528 # 80008620 <syscalls+0x1d0>
    80004030:	ffffc097          	auipc	ra,0xffffc
    80004034:	510080e7          	jalr	1296(ra) # 80000540 <panic>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004038:	24c1                	addiw	s1,s1,16
    8000403a:	04c92783          	lw	a5,76(s2)
    8000403e:	04f4f763          	bgeu	s1,a5,8000408c <dirlookup+0x9e>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004042:	4741                	li	a4,16
    80004044:	86a6                	mv	a3,s1
    80004046:	fc040613          	addi	a2,s0,-64
    8000404a:	4581                	li	a1,0
    8000404c:	854a                	mv	a0,s2
    8000404e:	00000097          	auipc	ra,0x0
    80004052:	d70080e7          	jalr	-656(ra) # 80003dbe <readi>
    80004056:	47c1                	li	a5,16
    80004058:	fcf518e3          	bne	a0,a5,80004028 <dirlookup+0x3a>
    if (de.inum == 0)
    8000405c:	fc045783          	lhu	a5,-64(s0)
    80004060:	dfe1                	beqz	a5,80004038 <dirlookup+0x4a>
    if (namecmp(name, de.name) == 0)
    80004062:	fc240593          	addi	a1,s0,-62
    80004066:	854e                	mv	a0,s3
    80004068:	00000097          	auipc	ra,0x0
    8000406c:	f6c080e7          	jalr	-148(ra) # 80003fd4 <namecmp>
    80004070:	f561                	bnez	a0,80004038 <dirlookup+0x4a>
      if (poff)
    80004072:	000a0463          	beqz	s4,8000407a <dirlookup+0x8c>
        *poff = off;
    80004076:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000407a:	fc045583          	lhu	a1,-64(s0)
    8000407e:	00092503          	lw	a0,0(s2)
    80004082:	fffff097          	auipc	ra,0xfffff
    80004086:	74e080e7          	jalr	1870(ra) # 800037d0 <iget>
    8000408a:	a011                	j	8000408e <dirlookup+0xa0>
  return 0;
    8000408c:	4501                	li	a0,0
}
    8000408e:	70e2                	ld	ra,56(sp)
    80004090:	7442                	ld	s0,48(sp)
    80004092:	74a2                	ld	s1,40(sp)
    80004094:	7902                	ld	s2,32(sp)
    80004096:	69e2                	ld	s3,24(sp)
    80004098:	6a42                	ld	s4,16(sp)
    8000409a:	6121                	addi	sp,sp,64
    8000409c:	8082                	ret

000000008000409e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    8000409e:	711d                	addi	sp,sp,-96
    800040a0:	ec86                	sd	ra,88(sp)
    800040a2:	e8a2                	sd	s0,80(sp)
    800040a4:	e4a6                	sd	s1,72(sp)
    800040a6:	e0ca                	sd	s2,64(sp)
    800040a8:	fc4e                	sd	s3,56(sp)
    800040aa:	f852                	sd	s4,48(sp)
    800040ac:	f456                	sd	s5,40(sp)
    800040ae:	f05a                	sd	s6,32(sp)
    800040b0:	ec5e                	sd	s7,24(sp)
    800040b2:	e862                	sd	s8,16(sp)
    800040b4:	e466                	sd	s9,8(sp)
    800040b6:	e06a                	sd	s10,0(sp)
    800040b8:	1080                	addi	s0,sp,96
    800040ba:	84aa                	mv	s1,a0
    800040bc:	8b2e                	mv	s6,a1
    800040be:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    800040c0:	00054703          	lbu	a4,0(a0)
    800040c4:	02f00793          	li	a5,47
    800040c8:	02f70363          	beq	a4,a5,800040ee <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040cc:	ffffe097          	auipc	ra,0xffffe
    800040d0:	8e0080e7          	jalr	-1824(ra) # 800019ac <myproc>
    800040d4:	15053503          	ld	a0,336(a0)
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	9f4080e7          	jalr	-1548(ra) # 80003acc <idup>
    800040e0:	8a2a                	mv	s4,a0
  while (*path == '/')
    800040e2:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    800040e6:	4cb5                	li	s9,13
  len = path - s;
    800040e8:	4b81                	li	s7,0

  while ((path = skipelem(path, name)) != 0)
  {
    ilock(ip);
    if (ip->type != T_DIR)
    800040ea:	4c05                	li	s8,1
    800040ec:	a87d                	j	800041aa <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800040ee:	4585                	li	a1,1
    800040f0:	4505                	li	a0,1
    800040f2:	fffff097          	auipc	ra,0xfffff
    800040f6:	6de080e7          	jalr	1758(ra) # 800037d0 <iget>
    800040fa:	8a2a                	mv	s4,a0
    800040fc:	b7dd                	j	800040e2 <namex+0x44>
    {
      iunlockput(ip);
    800040fe:	8552                	mv	a0,s4
    80004100:	00000097          	auipc	ra,0x0
    80004104:	c6c080e7          	jalr	-916(ra) # 80003d6c <iunlockput>
      return 0;
    80004108:	4a01                	li	s4,0
  {
    iput(ip);
    return 0;
  }
  return ip;
}
    8000410a:	8552                	mv	a0,s4
    8000410c:	60e6                	ld	ra,88(sp)
    8000410e:	6446                	ld	s0,80(sp)
    80004110:	64a6                	ld	s1,72(sp)
    80004112:	6906                	ld	s2,64(sp)
    80004114:	79e2                	ld	s3,56(sp)
    80004116:	7a42                	ld	s4,48(sp)
    80004118:	7aa2                	ld	s5,40(sp)
    8000411a:	7b02                	ld	s6,32(sp)
    8000411c:	6be2                	ld	s7,24(sp)
    8000411e:	6c42                	ld	s8,16(sp)
    80004120:	6ca2                	ld	s9,8(sp)
    80004122:	6d02                	ld	s10,0(sp)
    80004124:	6125                	addi	sp,sp,96
    80004126:	8082                	ret
      iunlock(ip);
    80004128:	8552                	mv	a0,s4
    8000412a:	00000097          	auipc	ra,0x0
    8000412e:	aa2080e7          	jalr	-1374(ra) # 80003bcc <iunlock>
      return ip;
    80004132:	bfe1                	j	8000410a <namex+0x6c>
      iunlockput(ip);
    80004134:	8552                	mv	a0,s4
    80004136:	00000097          	auipc	ra,0x0
    8000413a:	c36080e7          	jalr	-970(ra) # 80003d6c <iunlockput>
      return 0;
    8000413e:	8a4e                	mv	s4,s3
    80004140:	b7e9                	j	8000410a <namex+0x6c>
  len = path - s;
    80004142:	40998633          	sub	a2,s3,s1
    80004146:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    8000414a:	09acd863          	bge	s9,s10,800041da <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000414e:	4639                	li	a2,14
    80004150:	85a6                	mv	a1,s1
    80004152:	8556                	mv	a0,s5
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	bda080e7          	jalr	-1062(ra) # 80000d2e <memmove>
    8000415c:	84ce                	mv	s1,s3
  while (*path == '/')
    8000415e:	0004c783          	lbu	a5,0(s1)
    80004162:	01279763          	bne	a5,s2,80004170 <namex+0xd2>
    path++;
    80004166:	0485                	addi	s1,s1,1
  while (*path == '/')
    80004168:	0004c783          	lbu	a5,0(s1)
    8000416c:	ff278de3          	beq	a5,s2,80004166 <namex+0xc8>
    ilock(ip);
    80004170:	8552                	mv	a0,s4
    80004172:	00000097          	auipc	ra,0x0
    80004176:	998080e7          	jalr	-1640(ra) # 80003b0a <ilock>
    if (ip->type != T_DIR)
    8000417a:	044a1783          	lh	a5,68(s4)
    8000417e:	f98790e3          	bne	a5,s8,800040fe <namex+0x60>
    if (nameiparent && *path == '\0')
    80004182:	000b0563          	beqz	s6,8000418c <namex+0xee>
    80004186:	0004c783          	lbu	a5,0(s1)
    8000418a:	dfd9                	beqz	a5,80004128 <namex+0x8a>
    if ((next = dirlookup(ip, name, 0)) == 0)
    8000418c:	865e                	mv	a2,s7
    8000418e:	85d6                	mv	a1,s5
    80004190:	8552                	mv	a0,s4
    80004192:	00000097          	auipc	ra,0x0
    80004196:	e5c080e7          	jalr	-420(ra) # 80003fee <dirlookup>
    8000419a:	89aa                	mv	s3,a0
    8000419c:	dd41                	beqz	a0,80004134 <namex+0x96>
    iunlockput(ip);
    8000419e:	8552                	mv	a0,s4
    800041a0:	00000097          	auipc	ra,0x0
    800041a4:	bcc080e7          	jalr	-1076(ra) # 80003d6c <iunlockput>
    ip = next;
    800041a8:	8a4e                	mv	s4,s3
  while (*path == '/')
    800041aa:	0004c783          	lbu	a5,0(s1)
    800041ae:	01279763          	bne	a5,s2,800041bc <namex+0x11e>
    path++;
    800041b2:	0485                	addi	s1,s1,1
  while (*path == '/')
    800041b4:	0004c783          	lbu	a5,0(s1)
    800041b8:	ff278de3          	beq	a5,s2,800041b2 <namex+0x114>
  if (*path == 0)
    800041bc:	cb9d                	beqz	a5,800041f2 <namex+0x154>
  while (*path != '/' && *path != 0)
    800041be:	0004c783          	lbu	a5,0(s1)
    800041c2:	89a6                	mv	s3,s1
  len = path - s;
    800041c4:	8d5e                	mv	s10,s7
    800041c6:	865e                	mv	a2,s7
  while (*path != '/' && *path != 0)
    800041c8:	01278963          	beq	a5,s2,800041da <namex+0x13c>
    800041cc:	dbbd                	beqz	a5,80004142 <namex+0xa4>
    path++;
    800041ce:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    800041d0:	0009c783          	lbu	a5,0(s3)
    800041d4:	ff279ce3          	bne	a5,s2,800041cc <namex+0x12e>
    800041d8:	b7ad                	j	80004142 <namex+0xa4>
    memmove(name, s, len);
    800041da:	2601                	sext.w	a2,a2
    800041dc:	85a6                	mv	a1,s1
    800041de:	8556                	mv	a0,s5
    800041e0:	ffffd097          	auipc	ra,0xffffd
    800041e4:	b4e080e7          	jalr	-1202(ra) # 80000d2e <memmove>
    name[len] = 0;
    800041e8:	9d56                	add	s10,s10,s5
    800041ea:	000d0023          	sb	zero,0(s10)
    800041ee:	84ce                	mv	s1,s3
    800041f0:	b7bd                	j	8000415e <namex+0xc0>
  if (nameiparent)
    800041f2:	f00b0ce3          	beqz	s6,8000410a <namex+0x6c>
    iput(ip);
    800041f6:	8552                	mv	a0,s4
    800041f8:	00000097          	auipc	ra,0x0
    800041fc:	acc080e7          	jalr	-1332(ra) # 80003cc4 <iput>
    return 0;
    80004200:	4a01                	li	s4,0
    80004202:	b721                	j	8000410a <namex+0x6c>

0000000080004204 <dirlink>:
{
    80004204:	7139                	addi	sp,sp,-64
    80004206:	fc06                	sd	ra,56(sp)
    80004208:	f822                	sd	s0,48(sp)
    8000420a:	f426                	sd	s1,40(sp)
    8000420c:	f04a                	sd	s2,32(sp)
    8000420e:	ec4e                	sd	s3,24(sp)
    80004210:	e852                	sd	s4,16(sp)
    80004212:	0080                	addi	s0,sp,64
    80004214:	892a                	mv	s2,a0
    80004216:	8a2e                	mv	s4,a1
    80004218:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0)
    8000421a:	4601                	li	a2,0
    8000421c:	00000097          	auipc	ra,0x0
    80004220:	dd2080e7          	jalr	-558(ra) # 80003fee <dirlookup>
    80004224:	e93d                	bnez	a0,8000429a <dirlink+0x96>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004226:	04c92483          	lw	s1,76(s2)
    8000422a:	c49d                	beqz	s1,80004258 <dirlink+0x54>
    8000422c:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000422e:	4741                	li	a4,16
    80004230:	86a6                	mv	a3,s1
    80004232:	fc040613          	addi	a2,s0,-64
    80004236:	4581                	li	a1,0
    80004238:	854a                	mv	a0,s2
    8000423a:	00000097          	auipc	ra,0x0
    8000423e:	b84080e7          	jalr	-1148(ra) # 80003dbe <readi>
    80004242:	47c1                	li	a5,16
    80004244:	06f51163          	bne	a0,a5,800042a6 <dirlink+0xa2>
    if (de.inum == 0)
    80004248:	fc045783          	lhu	a5,-64(s0)
    8000424c:	c791                	beqz	a5,80004258 <dirlink+0x54>
  for (off = 0; off < dp->size; off += sizeof(de))
    8000424e:	24c1                	addiw	s1,s1,16
    80004250:	04c92783          	lw	a5,76(s2)
    80004254:	fcf4ede3          	bltu	s1,a5,8000422e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004258:	4639                	li	a2,14
    8000425a:	85d2                	mv	a1,s4
    8000425c:	fc240513          	addi	a0,s0,-62
    80004260:	ffffd097          	auipc	ra,0xffffd
    80004264:	b7e080e7          	jalr	-1154(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004268:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000426c:	4741                	li	a4,16
    8000426e:	86a6                	mv	a3,s1
    80004270:	fc040613          	addi	a2,s0,-64
    80004274:	4581                	li	a1,0
    80004276:	854a                	mv	a0,s2
    80004278:	00000097          	auipc	ra,0x0
    8000427c:	c3e080e7          	jalr	-962(ra) # 80003eb6 <writei>
    80004280:	1541                	addi	a0,a0,-16
    80004282:	00a03533          	snez	a0,a0
    80004286:	40a00533          	neg	a0,a0
}
    8000428a:	70e2                	ld	ra,56(sp)
    8000428c:	7442                	ld	s0,48(sp)
    8000428e:	74a2                	ld	s1,40(sp)
    80004290:	7902                	ld	s2,32(sp)
    80004292:	69e2                	ld	s3,24(sp)
    80004294:	6a42                	ld	s4,16(sp)
    80004296:	6121                	addi	sp,sp,64
    80004298:	8082                	ret
    iput(ip);
    8000429a:	00000097          	auipc	ra,0x0
    8000429e:	a2a080e7          	jalr	-1494(ra) # 80003cc4 <iput>
    return -1;
    800042a2:	557d                	li	a0,-1
    800042a4:	b7dd                	j	8000428a <dirlink+0x86>
      panic("dirlink read");
    800042a6:	00004517          	auipc	a0,0x4
    800042aa:	38a50513          	addi	a0,a0,906 # 80008630 <syscalls+0x1e0>
    800042ae:	ffffc097          	auipc	ra,0xffffc
    800042b2:	292080e7          	jalr	658(ra) # 80000540 <panic>

00000000800042b6 <namei>:

struct inode *
namei(char *path)
{
    800042b6:	1101                	addi	sp,sp,-32
    800042b8:	ec06                	sd	ra,24(sp)
    800042ba:	e822                	sd	s0,16(sp)
    800042bc:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042be:	fe040613          	addi	a2,s0,-32
    800042c2:	4581                	li	a1,0
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	dda080e7          	jalr	-550(ra) # 8000409e <namex>
}
    800042cc:	60e2                	ld	ra,24(sp)
    800042ce:	6442                	ld	s0,16(sp)
    800042d0:	6105                	addi	sp,sp,32
    800042d2:	8082                	ret

00000000800042d4 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    800042d4:	1141                	addi	sp,sp,-16
    800042d6:	e406                	sd	ra,8(sp)
    800042d8:	e022                	sd	s0,0(sp)
    800042da:	0800                	addi	s0,sp,16
    800042dc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042de:	4585                	li	a1,1
    800042e0:	00000097          	auipc	ra,0x0
    800042e4:	dbe080e7          	jalr	-578(ra) # 8000409e <namex>
}
    800042e8:	60a2                	ld	ra,8(sp)
    800042ea:	6402                	ld	s0,0(sp)
    800042ec:	0141                	addi	sp,sp,16
    800042ee:	8082                	ret

00000000800042f0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042f0:	1101                	addi	sp,sp,-32
    800042f2:	ec06                	sd	ra,24(sp)
    800042f4:	e822                	sd	s0,16(sp)
    800042f6:	e426                	sd	s1,8(sp)
    800042f8:	e04a                	sd	s2,0(sp)
    800042fa:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042fc:	0001e917          	auipc	s2,0x1e
    80004300:	07490913          	addi	s2,s2,116 # 80022370 <log>
    80004304:	01892583          	lw	a1,24(s2)
    80004308:	02892503          	lw	a0,40(s2)
    8000430c:	fffff097          	auipc	ra,0xfffff
    80004310:	fe6080e7          	jalr	-26(ra) # 800032f2 <bread>
    80004314:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80004316:	02c92683          	lw	a3,44(s2)
    8000431a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++)
    8000431c:	02d05863          	blez	a3,8000434c <write_head+0x5c>
    80004320:	0001e797          	auipc	a5,0x1e
    80004324:	08078793          	addi	a5,a5,128 # 800223a0 <log+0x30>
    80004328:	05c50713          	addi	a4,a0,92
    8000432c:	36fd                	addiw	a3,a3,-1
    8000432e:	02069613          	slli	a2,a3,0x20
    80004332:	01e65693          	srli	a3,a2,0x1e
    80004336:	0001e617          	auipc	a2,0x1e
    8000433a:	06e60613          	addi	a2,a2,110 # 800223a4 <log+0x34>
    8000433e:	96b2                	add	a3,a3,a2
  {
    hb->block[i] = log.lh.block[i];
    80004340:	4390                	lw	a2,0(a5)
    80004342:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    80004344:	0791                	addi	a5,a5,4
    80004346:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004348:	fed79ce3          	bne	a5,a3,80004340 <write_head+0x50>
  }
  bwrite(buf);
    8000434c:	8526                	mv	a0,s1
    8000434e:	fffff097          	auipc	ra,0xfffff
    80004352:	096080e7          	jalr	150(ra) # 800033e4 <bwrite>
  brelse(buf);
    80004356:	8526                	mv	a0,s1
    80004358:	fffff097          	auipc	ra,0xfffff
    8000435c:	0ca080e7          	jalr	202(ra) # 80003422 <brelse>
}
    80004360:	60e2                	ld	ra,24(sp)
    80004362:	6442                	ld	s0,16(sp)
    80004364:	64a2                	ld	s1,8(sp)
    80004366:	6902                	ld	s2,0(sp)
    80004368:	6105                	addi	sp,sp,32
    8000436a:	8082                	ret

000000008000436c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++)
    8000436c:	0001e797          	auipc	a5,0x1e
    80004370:	0307a783          	lw	a5,48(a5) # 8002239c <log+0x2c>
    80004374:	0af05d63          	blez	a5,8000442e <install_trans+0xc2>
{
    80004378:	7139                	addi	sp,sp,-64
    8000437a:	fc06                	sd	ra,56(sp)
    8000437c:	f822                	sd	s0,48(sp)
    8000437e:	f426                	sd	s1,40(sp)
    80004380:	f04a                	sd	s2,32(sp)
    80004382:	ec4e                	sd	s3,24(sp)
    80004384:	e852                	sd	s4,16(sp)
    80004386:	e456                	sd	s5,8(sp)
    80004388:	e05a                	sd	s6,0(sp)
    8000438a:	0080                	addi	s0,sp,64
    8000438c:	8b2a                	mv	s6,a0
    8000438e:	0001ea97          	auipc	s5,0x1e
    80004392:	012a8a93          	addi	s5,s5,18 # 800223a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++)
    80004396:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80004398:	0001e997          	auipc	s3,0x1e
    8000439c:	fd898993          	addi	s3,s3,-40 # 80022370 <log>
    800043a0:	a00d                	j	800043c2 <install_trans+0x56>
    brelse(lbuf);
    800043a2:	854a                	mv	a0,s2
    800043a4:	fffff097          	auipc	ra,0xfffff
    800043a8:	07e080e7          	jalr	126(ra) # 80003422 <brelse>
    brelse(dbuf);
    800043ac:	8526                	mv	a0,s1
    800043ae:	fffff097          	auipc	ra,0xfffff
    800043b2:	074080e7          	jalr	116(ra) # 80003422 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    800043b6:	2a05                	addiw	s4,s4,1
    800043b8:	0a91                	addi	s5,s5,4
    800043ba:	02c9a783          	lw	a5,44(s3)
    800043be:	04fa5e63          	bge	s4,a5,8000441a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    800043c2:	0189a583          	lw	a1,24(s3)
    800043c6:	014585bb          	addw	a1,a1,s4
    800043ca:	2585                	addiw	a1,a1,1
    800043cc:	0289a503          	lw	a0,40(s3)
    800043d0:	fffff097          	auipc	ra,0xfffff
    800043d4:	f22080e7          	jalr	-222(ra) # 800032f2 <bread>
    800043d8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    800043da:	000aa583          	lw	a1,0(s5)
    800043de:	0289a503          	lw	a0,40(s3)
    800043e2:	fffff097          	auipc	ra,0xfffff
    800043e6:	f10080e7          	jalr	-240(ra) # 800032f2 <bread>
    800043ea:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);                  // copy block to dst
    800043ec:	40000613          	li	a2,1024
    800043f0:	05890593          	addi	a1,s2,88
    800043f4:	05850513          	addi	a0,a0,88
    800043f8:	ffffd097          	auipc	ra,0xffffd
    800043fc:	936080e7          	jalr	-1738(ra) # 80000d2e <memmove>
    bwrite(dbuf);                                            // write dst to disk
    80004400:	8526                	mv	a0,s1
    80004402:	fffff097          	auipc	ra,0xfffff
    80004406:	fe2080e7          	jalr	-30(ra) # 800033e4 <bwrite>
    if (recovering == 0)
    8000440a:	f80b1ce3          	bnez	s6,800043a2 <install_trans+0x36>
      bunpin(dbuf);
    8000440e:	8526                	mv	a0,s1
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	0ec080e7          	jalr	236(ra) # 800034fc <bunpin>
    80004418:	b769                	j	800043a2 <install_trans+0x36>
}
    8000441a:	70e2                	ld	ra,56(sp)
    8000441c:	7442                	ld	s0,48(sp)
    8000441e:	74a2                	ld	s1,40(sp)
    80004420:	7902                	ld	s2,32(sp)
    80004422:	69e2                	ld	s3,24(sp)
    80004424:	6a42                	ld	s4,16(sp)
    80004426:	6aa2                	ld	s5,8(sp)
    80004428:	6b02                	ld	s6,0(sp)
    8000442a:	6121                	addi	sp,sp,64
    8000442c:	8082                	ret
    8000442e:	8082                	ret

0000000080004430 <initlog>:
{
    80004430:	7179                	addi	sp,sp,-48
    80004432:	f406                	sd	ra,40(sp)
    80004434:	f022                	sd	s0,32(sp)
    80004436:	ec26                	sd	s1,24(sp)
    80004438:	e84a                	sd	s2,16(sp)
    8000443a:	e44e                	sd	s3,8(sp)
    8000443c:	1800                	addi	s0,sp,48
    8000443e:	892a                	mv	s2,a0
    80004440:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004442:	0001e497          	auipc	s1,0x1e
    80004446:	f2e48493          	addi	s1,s1,-210 # 80022370 <log>
    8000444a:	00004597          	auipc	a1,0x4
    8000444e:	1f658593          	addi	a1,a1,502 # 80008640 <syscalls+0x1f0>
    80004452:	8526                	mv	a0,s1
    80004454:	ffffc097          	auipc	ra,0xffffc
    80004458:	6f2080e7          	jalr	1778(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000445c:	0149a583          	lw	a1,20(s3)
    80004460:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004462:	0109a783          	lw	a5,16(s3)
    80004466:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004468:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000446c:	854a                	mv	a0,s2
    8000446e:	fffff097          	auipc	ra,0xfffff
    80004472:	e84080e7          	jalr	-380(ra) # 800032f2 <bread>
  log.lh.n = lh->n;
    80004476:	4d34                	lw	a3,88(a0)
    80004478:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++)
    8000447a:	02d05663          	blez	a3,800044a6 <initlog+0x76>
    8000447e:	05c50793          	addi	a5,a0,92
    80004482:	0001e717          	auipc	a4,0x1e
    80004486:	f1e70713          	addi	a4,a4,-226 # 800223a0 <log+0x30>
    8000448a:	36fd                	addiw	a3,a3,-1
    8000448c:	02069613          	slli	a2,a3,0x20
    80004490:	01e65693          	srli	a3,a2,0x1e
    80004494:	06050613          	addi	a2,a0,96
    80004498:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000449a:	4390                	lw	a2,0(a5)
    8000449c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    8000449e:	0791                	addi	a5,a5,4
    800044a0:	0711                	addi	a4,a4,4
    800044a2:	fed79ce3          	bne	a5,a3,8000449a <initlog+0x6a>
  brelse(buf);
    800044a6:	fffff097          	auipc	ra,0xfffff
    800044aa:	f7c080e7          	jalr	-132(ra) # 80003422 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800044ae:	4505                	li	a0,1
    800044b0:	00000097          	auipc	ra,0x0
    800044b4:	ebc080e7          	jalr	-324(ra) # 8000436c <install_trans>
  log.lh.n = 0;
    800044b8:	0001e797          	auipc	a5,0x1e
    800044bc:	ee07a223          	sw	zero,-284(a5) # 8002239c <log+0x2c>
  write_head(); // clear the log
    800044c0:	00000097          	auipc	ra,0x0
    800044c4:	e30080e7          	jalr	-464(ra) # 800042f0 <write_head>
}
    800044c8:	70a2                	ld	ra,40(sp)
    800044ca:	7402                	ld	s0,32(sp)
    800044cc:	64e2                	ld	s1,24(sp)
    800044ce:	6942                	ld	s2,16(sp)
    800044d0:	69a2                	ld	s3,8(sp)
    800044d2:	6145                	addi	sp,sp,48
    800044d4:	8082                	ret

00000000800044d6 <begin_op>:
}

// called at the start of each FS system call.
void begin_op(void)
{
    800044d6:	1101                	addi	sp,sp,-32
    800044d8:	ec06                	sd	ra,24(sp)
    800044da:	e822                	sd	s0,16(sp)
    800044dc:	e426                	sd	s1,8(sp)
    800044de:	e04a                	sd	s2,0(sp)
    800044e0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044e2:	0001e517          	auipc	a0,0x1e
    800044e6:	e8e50513          	addi	a0,a0,-370 # 80022370 <log>
    800044ea:	ffffc097          	auipc	ra,0xffffc
    800044ee:	6ec080e7          	jalr	1772(ra) # 80000bd6 <acquire>
  while (1)
  {
    if (log.committing)
    800044f2:	0001e497          	auipc	s1,0x1e
    800044f6:	e7e48493          	addi	s1,s1,-386 # 80022370 <log>
    {
      sleep(&log, &log.lock);
    }
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    800044fa:	4979                	li	s2,30
    800044fc:	a039                	j	8000450a <begin_op+0x34>
      sleep(&log, &log.lock);
    800044fe:	85a6                	mv	a1,s1
    80004500:	8526                	mv	a0,s1
    80004502:	ffffe097          	auipc	ra,0xffffe
    80004506:	cc6080e7          	jalr	-826(ra) # 800021c8 <sleep>
    if (log.committing)
    8000450a:	50dc                	lw	a5,36(s1)
    8000450c:	fbed                	bnez	a5,800044fe <begin_op+0x28>
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    8000450e:	5098                	lw	a4,32(s1)
    80004510:	2705                	addiw	a4,a4,1
    80004512:	0007069b          	sext.w	a3,a4
    80004516:	0027179b          	slliw	a5,a4,0x2
    8000451a:	9fb9                	addw	a5,a5,a4
    8000451c:	0017979b          	slliw	a5,a5,0x1
    80004520:	54d8                	lw	a4,44(s1)
    80004522:	9fb9                	addw	a5,a5,a4
    80004524:	00f95963          	bge	s2,a5,80004536 <begin_op+0x60>
    {
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004528:	85a6                	mv	a1,s1
    8000452a:	8526                	mv	a0,s1
    8000452c:	ffffe097          	auipc	ra,0xffffe
    80004530:	c9c080e7          	jalr	-868(ra) # 800021c8 <sleep>
    80004534:	bfd9                	j	8000450a <begin_op+0x34>
    }
    else
    {
      log.outstanding += 1;
    80004536:	0001e517          	auipc	a0,0x1e
    8000453a:	e3a50513          	addi	a0,a0,-454 # 80022370 <log>
    8000453e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004540:	ffffc097          	auipc	ra,0xffffc
    80004544:	74a080e7          	jalr	1866(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004548:	60e2                	ld	ra,24(sp)
    8000454a:	6442                	ld	s0,16(sp)
    8000454c:	64a2                	ld	s1,8(sp)
    8000454e:	6902                	ld	s2,0(sp)
    80004550:	6105                	addi	sp,sp,32
    80004552:	8082                	ret

0000000080004554 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
    80004554:	7139                	addi	sp,sp,-64
    80004556:	fc06                	sd	ra,56(sp)
    80004558:	f822                	sd	s0,48(sp)
    8000455a:	f426                	sd	s1,40(sp)
    8000455c:	f04a                	sd	s2,32(sp)
    8000455e:	ec4e                	sd	s3,24(sp)
    80004560:	e852                	sd	s4,16(sp)
    80004562:	e456                	sd	s5,8(sp)
    80004564:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004566:	0001e497          	auipc	s1,0x1e
    8000456a:	e0a48493          	addi	s1,s1,-502 # 80022370 <log>
    8000456e:	8526                	mv	a0,s1
    80004570:	ffffc097          	auipc	ra,0xffffc
    80004574:	666080e7          	jalr	1638(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004578:	509c                	lw	a5,32(s1)
    8000457a:	37fd                	addiw	a5,a5,-1
    8000457c:	0007891b          	sext.w	s2,a5
    80004580:	d09c                	sw	a5,32(s1)
  if (log.committing)
    80004582:	50dc                	lw	a5,36(s1)
    80004584:	e7b9                	bnez	a5,800045d2 <end_op+0x7e>
    panic("log.committing");
  if (log.outstanding == 0)
    80004586:	04091e63          	bnez	s2,800045e2 <end_op+0x8e>
  {
    do_commit = 1;
    log.committing = 1;
    8000458a:	0001e497          	auipc	s1,0x1e
    8000458e:	de648493          	addi	s1,s1,-538 # 80022370 <log>
    80004592:	4785                	li	a5,1
    80004594:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004596:	8526                	mv	a0,s1
    80004598:	ffffc097          	auipc	ra,0xffffc
    8000459c:	6f2080e7          	jalr	1778(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0)
    800045a0:	54dc                	lw	a5,44(s1)
    800045a2:	06f04763          	bgtz	a5,80004610 <end_op+0xbc>
    acquire(&log.lock);
    800045a6:	0001e497          	auipc	s1,0x1e
    800045aa:	dca48493          	addi	s1,s1,-566 # 80022370 <log>
    800045ae:	8526                	mv	a0,s1
    800045b0:	ffffc097          	auipc	ra,0xffffc
    800045b4:	626080e7          	jalr	1574(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800045b8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800045bc:	8526                	mv	a0,s1
    800045be:	ffffe097          	auipc	ra,0xffffe
    800045c2:	c6e080e7          	jalr	-914(ra) # 8000222c <wakeup>
    release(&log.lock);
    800045c6:	8526                	mv	a0,s1
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	6c2080e7          	jalr	1730(ra) # 80000c8a <release>
}
    800045d0:	a03d                	j	800045fe <end_op+0xaa>
    panic("log.committing");
    800045d2:	00004517          	auipc	a0,0x4
    800045d6:	07650513          	addi	a0,a0,118 # 80008648 <syscalls+0x1f8>
    800045da:	ffffc097          	auipc	ra,0xffffc
    800045de:	f66080e7          	jalr	-154(ra) # 80000540 <panic>
    wakeup(&log);
    800045e2:	0001e497          	auipc	s1,0x1e
    800045e6:	d8e48493          	addi	s1,s1,-626 # 80022370 <log>
    800045ea:	8526                	mv	a0,s1
    800045ec:	ffffe097          	auipc	ra,0xffffe
    800045f0:	c40080e7          	jalr	-960(ra) # 8000222c <wakeup>
  release(&log.lock);
    800045f4:	8526                	mv	a0,s1
    800045f6:	ffffc097          	auipc	ra,0xffffc
    800045fa:	694080e7          	jalr	1684(ra) # 80000c8a <release>
}
    800045fe:	70e2                	ld	ra,56(sp)
    80004600:	7442                	ld	s0,48(sp)
    80004602:	74a2                	ld	s1,40(sp)
    80004604:	7902                	ld	s2,32(sp)
    80004606:	69e2                	ld	s3,24(sp)
    80004608:	6a42                	ld	s4,16(sp)
    8000460a:	6aa2                	ld	s5,8(sp)
    8000460c:	6121                	addi	sp,sp,64
    8000460e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++)
    80004610:	0001ea97          	auipc	s5,0x1e
    80004614:	d90a8a93          	addi	s5,s5,-624 # 800223a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80004618:	0001ea17          	auipc	s4,0x1e
    8000461c:	d58a0a13          	addi	s4,s4,-680 # 80022370 <log>
    80004620:	018a2583          	lw	a1,24(s4)
    80004624:	012585bb          	addw	a1,a1,s2
    80004628:	2585                	addiw	a1,a1,1
    8000462a:	028a2503          	lw	a0,40(s4)
    8000462e:	fffff097          	auipc	ra,0xfffff
    80004632:	cc4080e7          	jalr	-828(ra) # 800032f2 <bread>
    80004636:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004638:	000aa583          	lw	a1,0(s5)
    8000463c:	028a2503          	lw	a0,40(s4)
    80004640:	fffff097          	auipc	ra,0xfffff
    80004644:	cb2080e7          	jalr	-846(ra) # 800032f2 <bread>
    80004648:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000464a:	40000613          	li	a2,1024
    8000464e:	05850593          	addi	a1,a0,88
    80004652:	05848513          	addi	a0,s1,88
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	6d8080e7          	jalr	1752(ra) # 80000d2e <memmove>
    bwrite(to); // write the log
    8000465e:	8526                	mv	a0,s1
    80004660:	fffff097          	auipc	ra,0xfffff
    80004664:	d84080e7          	jalr	-636(ra) # 800033e4 <bwrite>
    brelse(from);
    80004668:	854e                	mv	a0,s3
    8000466a:	fffff097          	auipc	ra,0xfffff
    8000466e:	db8080e7          	jalr	-584(ra) # 80003422 <brelse>
    brelse(to);
    80004672:	8526                	mv	a0,s1
    80004674:	fffff097          	auipc	ra,0xfffff
    80004678:	dae080e7          	jalr	-594(ra) # 80003422 <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    8000467c:	2905                	addiw	s2,s2,1
    8000467e:	0a91                	addi	s5,s5,4
    80004680:	02ca2783          	lw	a5,44(s4)
    80004684:	f8f94ee3          	blt	s2,a5,80004620 <end_op+0xcc>
  {
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80004688:	00000097          	auipc	ra,0x0
    8000468c:	c68080e7          	jalr	-920(ra) # 800042f0 <write_head>
    install_trans(0); // Now install writes to home locations
    80004690:	4501                	li	a0,0
    80004692:	00000097          	auipc	ra,0x0
    80004696:	cda080e7          	jalr	-806(ra) # 8000436c <install_trans>
    log.lh.n = 0;
    8000469a:	0001e797          	auipc	a5,0x1e
    8000469e:	d007a123          	sw	zero,-766(a5) # 8002239c <log+0x2c>
    write_head(); // Erase the transaction from the log
    800046a2:	00000097          	auipc	ra,0x0
    800046a6:	c4e080e7          	jalr	-946(ra) # 800042f0 <write_head>
    800046aa:	bdf5                	j	800045a6 <end_op+0x52>

00000000800046ac <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
    800046ac:	1101                	addi	sp,sp,-32
    800046ae:	ec06                	sd	ra,24(sp)
    800046b0:	e822                	sd	s0,16(sp)
    800046b2:	e426                	sd	s1,8(sp)
    800046b4:	e04a                	sd	s2,0(sp)
    800046b6:	1000                	addi	s0,sp,32
    800046b8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800046ba:	0001e917          	auipc	s2,0x1e
    800046be:	cb690913          	addi	s2,s2,-842 # 80022370 <log>
    800046c2:	854a                	mv	a0,s2
    800046c4:	ffffc097          	auipc	ra,0xffffc
    800046c8:	512080e7          	jalr	1298(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800046cc:	02c92603          	lw	a2,44(s2)
    800046d0:	47f5                	li	a5,29
    800046d2:	06c7c563          	blt	a5,a2,8000473c <log_write+0x90>
    800046d6:	0001e797          	auipc	a5,0x1e
    800046da:	cb67a783          	lw	a5,-842(a5) # 8002238c <log+0x1c>
    800046de:	37fd                	addiw	a5,a5,-1
    800046e0:	04f65e63          	bge	a2,a5,8000473c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046e4:	0001e797          	auipc	a5,0x1e
    800046e8:	cac7a783          	lw	a5,-852(a5) # 80022390 <log+0x20>
    800046ec:	06f05063          	blez	a5,8000474c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++)
    800046f0:	4781                	li	a5,0
    800046f2:	06c05563          	blez	a2,8000475c <log_write+0xb0>
  {
    if (log.lh.block[i] == b->blockno) // log absorption
    800046f6:	44cc                	lw	a1,12(s1)
    800046f8:	0001e717          	auipc	a4,0x1e
    800046fc:	ca870713          	addi	a4,a4,-856 # 800223a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++)
    80004700:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004702:	4314                	lw	a3,0(a4)
    80004704:	04b68c63          	beq	a3,a1,8000475c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++)
    80004708:	2785                	addiw	a5,a5,1
    8000470a:	0711                	addi	a4,a4,4
    8000470c:	fef61be3          	bne	a2,a5,80004702 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004710:	0621                	addi	a2,a2,8
    80004712:	060a                	slli	a2,a2,0x2
    80004714:	0001e797          	auipc	a5,0x1e
    80004718:	c5c78793          	addi	a5,a5,-932 # 80022370 <log>
    8000471c:	97b2                	add	a5,a5,a2
    8000471e:	44d8                	lw	a4,12(s1)
    80004720:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n)
  { // Add new block to log?
    bpin(b);
    80004722:	8526                	mv	a0,s1
    80004724:	fffff097          	auipc	ra,0xfffff
    80004728:	d9c080e7          	jalr	-612(ra) # 800034c0 <bpin>
    log.lh.n++;
    8000472c:	0001e717          	auipc	a4,0x1e
    80004730:	c4470713          	addi	a4,a4,-956 # 80022370 <log>
    80004734:	575c                	lw	a5,44(a4)
    80004736:	2785                	addiw	a5,a5,1
    80004738:	d75c                	sw	a5,44(a4)
    8000473a:	a82d                	j	80004774 <log_write+0xc8>
    panic("too big a transaction");
    8000473c:	00004517          	auipc	a0,0x4
    80004740:	f1c50513          	addi	a0,a0,-228 # 80008658 <syscalls+0x208>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	dfc080e7          	jalr	-516(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    8000474c:	00004517          	auipc	a0,0x4
    80004750:	f2450513          	addi	a0,a0,-220 # 80008670 <syscalls+0x220>
    80004754:	ffffc097          	auipc	ra,0xffffc
    80004758:	dec080e7          	jalr	-532(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    8000475c:	00878693          	addi	a3,a5,8
    80004760:	068a                	slli	a3,a3,0x2
    80004762:	0001e717          	auipc	a4,0x1e
    80004766:	c0e70713          	addi	a4,a4,-1010 # 80022370 <log>
    8000476a:	9736                	add	a4,a4,a3
    8000476c:	44d4                	lw	a3,12(s1)
    8000476e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n)
    80004770:	faf609e3          	beq	a2,a5,80004722 <log_write+0x76>
  }
  release(&log.lock);
    80004774:	0001e517          	auipc	a0,0x1e
    80004778:	bfc50513          	addi	a0,a0,-1028 # 80022370 <log>
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	50e080e7          	jalr	1294(ra) # 80000c8a <release>
}
    80004784:	60e2                	ld	ra,24(sp)
    80004786:	6442                	ld	s0,16(sp)
    80004788:	64a2                	ld	s1,8(sp)
    8000478a:	6902                	ld	s2,0(sp)
    8000478c:	6105                	addi	sp,sp,32
    8000478e:	8082                	ret

0000000080004790 <initsleeplock>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock *lk, char *name)
{
    80004790:	1101                	addi	sp,sp,-32
    80004792:	ec06                	sd	ra,24(sp)
    80004794:	e822                	sd	s0,16(sp)
    80004796:	e426                	sd	s1,8(sp)
    80004798:	e04a                	sd	s2,0(sp)
    8000479a:	1000                	addi	s0,sp,32
    8000479c:	84aa                	mv	s1,a0
    8000479e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800047a0:	00004597          	auipc	a1,0x4
    800047a4:	ef058593          	addi	a1,a1,-272 # 80008690 <syscalls+0x240>
    800047a8:	0521                	addi	a0,a0,8
    800047aa:	ffffc097          	auipc	ra,0xffffc
    800047ae:	39c080e7          	jalr	924(ra) # 80000b46 <initlock>
  lk->name = name;
    800047b2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800047b6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047ba:	0204a423          	sw	zero,40(s1)
}
    800047be:	60e2                	ld	ra,24(sp)
    800047c0:	6442                	ld	s0,16(sp)
    800047c2:	64a2                	ld	s1,8(sp)
    800047c4:	6902                	ld	s2,0(sp)
    800047c6:	6105                	addi	sp,sp,32
    800047c8:	8082                	ret

00000000800047ca <acquiresleep>:

void acquiresleep(struct sleeplock *lk)
{
    800047ca:	1101                	addi	sp,sp,-32
    800047cc:	ec06                	sd	ra,24(sp)
    800047ce:	e822                	sd	s0,16(sp)
    800047d0:	e426                	sd	s1,8(sp)
    800047d2:	e04a                	sd	s2,0(sp)
    800047d4:	1000                	addi	s0,sp,32
    800047d6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047d8:	00850913          	addi	s2,a0,8
    800047dc:	854a                	mv	a0,s2
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	3f8080e7          	jalr	1016(ra) # 80000bd6 <acquire>
  while (lk->locked)
    800047e6:	409c                	lw	a5,0(s1)
    800047e8:	cb89                	beqz	a5,800047fa <acquiresleep+0x30>
  {
    sleep(lk, &lk->lk);
    800047ea:	85ca                	mv	a1,s2
    800047ec:	8526                	mv	a0,s1
    800047ee:	ffffe097          	auipc	ra,0xffffe
    800047f2:	9da080e7          	jalr	-1574(ra) # 800021c8 <sleep>
  while (lk->locked)
    800047f6:	409c                	lw	a5,0(s1)
    800047f8:	fbed                	bnez	a5,800047ea <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047fa:	4785                	li	a5,1
    800047fc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047fe:	ffffd097          	auipc	ra,0xffffd
    80004802:	1ae080e7          	jalr	430(ra) # 800019ac <myproc>
    80004806:	591c                	lw	a5,48(a0)
    80004808:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000480a:	854a                	mv	a0,s2
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	47e080e7          	jalr	1150(ra) # 80000c8a <release>
}
    80004814:	60e2                	ld	ra,24(sp)
    80004816:	6442                	ld	s0,16(sp)
    80004818:	64a2                	ld	s1,8(sp)
    8000481a:	6902                	ld	s2,0(sp)
    8000481c:	6105                	addi	sp,sp,32
    8000481e:	8082                	ret

0000000080004820 <releasesleep>:

void releasesleep(struct sleeplock *lk)
{
    80004820:	1101                	addi	sp,sp,-32
    80004822:	ec06                	sd	ra,24(sp)
    80004824:	e822                	sd	s0,16(sp)
    80004826:	e426                	sd	s1,8(sp)
    80004828:	e04a                	sd	s2,0(sp)
    8000482a:	1000                	addi	s0,sp,32
    8000482c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000482e:	00850913          	addi	s2,a0,8
    80004832:	854a                	mv	a0,s2
    80004834:	ffffc097          	auipc	ra,0xffffc
    80004838:	3a2080e7          	jalr	930(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000483c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004840:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004844:	8526                	mv	a0,s1
    80004846:	ffffe097          	auipc	ra,0xffffe
    8000484a:	9e6080e7          	jalr	-1562(ra) # 8000222c <wakeup>
  release(&lk->lk);
    8000484e:	854a                	mv	a0,s2
    80004850:	ffffc097          	auipc	ra,0xffffc
    80004854:	43a080e7          	jalr	1082(ra) # 80000c8a <release>
}
    80004858:	60e2                	ld	ra,24(sp)
    8000485a:	6442                	ld	s0,16(sp)
    8000485c:	64a2                	ld	s1,8(sp)
    8000485e:	6902                	ld	s2,0(sp)
    80004860:	6105                	addi	sp,sp,32
    80004862:	8082                	ret

0000000080004864 <holdingsleep>:

int holdingsleep(struct sleeplock *lk)
{
    80004864:	7179                	addi	sp,sp,-48
    80004866:	f406                	sd	ra,40(sp)
    80004868:	f022                	sd	s0,32(sp)
    8000486a:	ec26                	sd	s1,24(sp)
    8000486c:	e84a                	sd	s2,16(sp)
    8000486e:	e44e                	sd	s3,8(sp)
    80004870:	1800                	addi	s0,sp,48
    80004872:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004874:	00850913          	addi	s2,a0,8
    80004878:	854a                	mv	a0,s2
    8000487a:	ffffc097          	auipc	ra,0xffffc
    8000487e:	35c080e7          	jalr	860(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004882:	409c                	lw	a5,0(s1)
    80004884:	ef99                	bnez	a5,800048a2 <holdingsleep+0x3e>
    80004886:	4481                	li	s1,0
  release(&lk->lk);
    80004888:	854a                	mv	a0,s2
    8000488a:	ffffc097          	auipc	ra,0xffffc
    8000488e:	400080e7          	jalr	1024(ra) # 80000c8a <release>
  return r;
}
    80004892:	8526                	mv	a0,s1
    80004894:	70a2                	ld	ra,40(sp)
    80004896:	7402                	ld	s0,32(sp)
    80004898:	64e2                	ld	s1,24(sp)
    8000489a:	6942                	ld	s2,16(sp)
    8000489c:	69a2                	ld	s3,8(sp)
    8000489e:	6145                	addi	sp,sp,48
    800048a0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800048a2:	0284a983          	lw	s3,40(s1)
    800048a6:	ffffd097          	auipc	ra,0xffffd
    800048aa:	106080e7          	jalr	262(ra) # 800019ac <myproc>
    800048ae:	5904                	lw	s1,48(a0)
    800048b0:	413484b3          	sub	s1,s1,s3
    800048b4:	0014b493          	seqz	s1,s1
    800048b8:	bfc1                	j	80004888 <holdingsleep+0x24>

00000000800048ba <fileinit>:
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void fileinit(void)
{
    800048ba:	1141                	addi	sp,sp,-16
    800048bc:	e406                	sd	ra,8(sp)
    800048be:	e022                	sd	s0,0(sp)
    800048c0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048c2:	00004597          	auipc	a1,0x4
    800048c6:	dde58593          	addi	a1,a1,-546 # 800086a0 <syscalls+0x250>
    800048ca:	0001e517          	auipc	a0,0x1e
    800048ce:	bee50513          	addi	a0,a0,-1042 # 800224b8 <ftable>
    800048d2:	ffffc097          	auipc	ra,0xffffc
    800048d6:	274080e7          	jalr	628(ra) # 80000b46 <initlock>
}
    800048da:	60a2                	ld	ra,8(sp)
    800048dc:	6402                	ld	s0,0(sp)
    800048de:	0141                	addi	sp,sp,16
    800048e0:	8082                	ret

00000000800048e2 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800048e2:	1101                	addi	sp,sp,-32
    800048e4:	ec06                	sd	ra,24(sp)
    800048e6:	e822                	sd	s0,16(sp)
    800048e8:	e426                	sd	s1,8(sp)
    800048ea:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048ec:	0001e517          	auipc	a0,0x1e
    800048f0:	bcc50513          	addi	a0,a0,-1076 # 800224b8 <ftable>
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	2e2080e7          	jalr	738(ra) # 80000bd6 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    800048fc:	0001e497          	auipc	s1,0x1e
    80004900:	bd448493          	addi	s1,s1,-1068 # 800224d0 <ftable+0x18>
    80004904:	0001f717          	auipc	a4,0x1f
    80004908:	b6c70713          	addi	a4,a4,-1172 # 80023470 <disk>
  {
    if (f->ref == 0)
    8000490c:	40dc                	lw	a5,4(s1)
    8000490e:	cf99                	beqz	a5,8000492c <filealloc+0x4a>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004910:	02848493          	addi	s1,s1,40
    80004914:	fee49ce3          	bne	s1,a4,8000490c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004918:	0001e517          	auipc	a0,0x1e
    8000491c:	ba050513          	addi	a0,a0,-1120 # 800224b8 <ftable>
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	36a080e7          	jalr	874(ra) # 80000c8a <release>
  return 0;
    80004928:	4481                	li	s1,0
    8000492a:	a819                	j	80004940 <filealloc+0x5e>
      f->ref = 1;
    8000492c:	4785                	li	a5,1
    8000492e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004930:	0001e517          	auipc	a0,0x1e
    80004934:	b8850513          	addi	a0,a0,-1144 # 800224b8 <ftable>
    80004938:	ffffc097          	auipc	ra,0xffffc
    8000493c:	352080e7          	jalr	850(ra) # 80000c8a <release>
}
    80004940:	8526                	mv	a0,s1
    80004942:	60e2                	ld	ra,24(sp)
    80004944:	6442                	ld	s0,16(sp)
    80004946:	64a2                	ld	s1,8(sp)
    80004948:	6105                	addi	sp,sp,32
    8000494a:	8082                	ret

000000008000494c <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000494c:	1101                	addi	sp,sp,-32
    8000494e:	ec06                	sd	ra,24(sp)
    80004950:	e822                	sd	s0,16(sp)
    80004952:	e426                	sd	s1,8(sp)
    80004954:	1000                	addi	s0,sp,32
    80004956:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004958:	0001e517          	auipc	a0,0x1e
    8000495c:	b6050513          	addi	a0,a0,-1184 # 800224b8 <ftable>
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	276080e7          	jalr	630(ra) # 80000bd6 <acquire>
  if (f->ref < 1)
    80004968:	40dc                	lw	a5,4(s1)
    8000496a:	02f05263          	blez	a5,8000498e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000496e:	2785                	addiw	a5,a5,1
    80004970:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004972:	0001e517          	auipc	a0,0x1e
    80004976:	b4650513          	addi	a0,a0,-1210 # 800224b8 <ftable>
    8000497a:	ffffc097          	auipc	ra,0xffffc
    8000497e:	310080e7          	jalr	784(ra) # 80000c8a <release>
  return f;
}
    80004982:	8526                	mv	a0,s1
    80004984:	60e2                	ld	ra,24(sp)
    80004986:	6442                	ld	s0,16(sp)
    80004988:	64a2                	ld	s1,8(sp)
    8000498a:	6105                	addi	sp,sp,32
    8000498c:	8082                	ret
    panic("filedup");
    8000498e:	00004517          	auipc	a0,0x4
    80004992:	d1a50513          	addi	a0,a0,-742 # 800086a8 <syscalls+0x258>
    80004996:	ffffc097          	auipc	ra,0xffffc
    8000499a:	baa080e7          	jalr	-1110(ra) # 80000540 <panic>

000000008000499e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    8000499e:	7139                	addi	sp,sp,-64
    800049a0:	fc06                	sd	ra,56(sp)
    800049a2:	f822                	sd	s0,48(sp)
    800049a4:	f426                	sd	s1,40(sp)
    800049a6:	f04a                	sd	s2,32(sp)
    800049a8:	ec4e                	sd	s3,24(sp)
    800049aa:	e852                	sd	s4,16(sp)
    800049ac:	e456                	sd	s5,8(sp)
    800049ae:	0080                	addi	s0,sp,64
    800049b0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800049b2:	0001e517          	auipc	a0,0x1e
    800049b6:	b0650513          	addi	a0,a0,-1274 # 800224b8 <ftable>
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	21c080e7          	jalr	540(ra) # 80000bd6 <acquire>
  if (f->ref < 1)
    800049c2:	40dc                	lw	a5,4(s1)
    800049c4:	06f05163          	blez	a5,80004a26 <fileclose+0x88>
    panic("fileclose");
  if (--f->ref > 0)
    800049c8:	37fd                	addiw	a5,a5,-1
    800049ca:	0007871b          	sext.w	a4,a5
    800049ce:	c0dc                	sw	a5,4(s1)
    800049d0:	06e04363          	bgtz	a4,80004a36 <fileclose+0x98>
  {
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049d4:	0004a903          	lw	s2,0(s1)
    800049d8:	0094ca83          	lbu	s5,9(s1)
    800049dc:	0104ba03          	ld	s4,16(s1)
    800049e0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049e4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049e8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049ec:	0001e517          	auipc	a0,0x1e
    800049f0:	acc50513          	addi	a0,a0,-1332 # 800224b8 <ftable>
    800049f4:	ffffc097          	auipc	ra,0xffffc
    800049f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (ff.type == FD_PIPE)
    800049fc:	4785                	li	a5,1
    800049fe:	04f90d63          	beq	s2,a5,80004a58 <fileclose+0xba>
  {
    pipeclose(ff.pipe, ff.writable);
  }
  else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    80004a02:	3979                	addiw	s2,s2,-2
    80004a04:	4785                	li	a5,1
    80004a06:	0527e063          	bltu	a5,s2,80004a46 <fileclose+0xa8>
  {
    begin_op();
    80004a0a:	00000097          	auipc	ra,0x0
    80004a0e:	acc080e7          	jalr	-1332(ra) # 800044d6 <begin_op>
    iput(ff.ip);
    80004a12:	854e                	mv	a0,s3
    80004a14:	fffff097          	auipc	ra,0xfffff
    80004a18:	2b0080e7          	jalr	688(ra) # 80003cc4 <iput>
    end_op();
    80004a1c:	00000097          	auipc	ra,0x0
    80004a20:	b38080e7          	jalr	-1224(ra) # 80004554 <end_op>
    80004a24:	a00d                	j	80004a46 <fileclose+0xa8>
    panic("fileclose");
    80004a26:	00004517          	auipc	a0,0x4
    80004a2a:	c8a50513          	addi	a0,a0,-886 # 800086b0 <syscalls+0x260>
    80004a2e:	ffffc097          	auipc	ra,0xffffc
    80004a32:	b12080e7          	jalr	-1262(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004a36:	0001e517          	auipc	a0,0x1e
    80004a3a:	a8250513          	addi	a0,a0,-1406 # 800224b8 <ftable>
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	24c080e7          	jalr	588(ra) # 80000c8a <release>
  }
}
    80004a46:	70e2                	ld	ra,56(sp)
    80004a48:	7442                	ld	s0,48(sp)
    80004a4a:	74a2                	ld	s1,40(sp)
    80004a4c:	7902                	ld	s2,32(sp)
    80004a4e:	69e2                	ld	s3,24(sp)
    80004a50:	6a42                	ld	s4,16(sp)
    80004a52:	6aa2                	ld	s5,8(sp)
    80004a54:	6121                	addi	sp,sp,64
    80004a56:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a58:	85d6                	mv	a1,s5
    80004a5a:	8552                	mv	a0,s4
    80004a5c:	00000097          	auipc	ra,0x0
    80004a60:	34c080e7          	jalr	844(ra) # 80004da8 <pipeclose>
    80004a64:	b7cd                	j	80004a46 <fileclose+0xa8>

0000000080004a66 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80004a66:	715d                	addi	sp,sp,-80
    80004a68:	e486                	sd	ra,72(sp)
    80004a6a:	e0a2                	sd	s0,64(sp)
    80004a6c:	fc26                	sd	s1,56(sp)
    80004a6e:	f84a                	sd	s2,48(sp)
    80004a70:	f44e                	sd	s3,40(sp)
    80004a72:	0880                	addi	s0,sp,80
    80004a74:	84aa                	mv	s1,a0
    80004a76:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a78:	ffffd097          	auipc	ra,0xffffd
    80004a7c:	f34080e7          	jalr	-204(ra) # 800019ac <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004a80:	409c                	lw	a5,0(s1)
    80004a82:	37f9                	addiw	a5,a5,-2
    80004a84:	4705                	li	a4,1
    80004a86:	04f76763          	bltu	a4,a5,80004ad4 <filestat+0x6e>
    80004a8a:	892a                	mv	s2,a0
  {
    ilock(f->ip);
    80004a8c:	6c88                	ld	a0,24(s1)
    80004a8e:	fffff097          	auipc	ra,0xfffff
    80004a92:	07c080e7          	jalr	124(ra) # 80003b0a <ilock>
    stati(f->ip, &st);
    80004a96:	fb840593          	addi	a1,s0,-72
    80004a9a:	6c88                	ld	a0,24(s1)
    80004a9c:	fffff097          	auipc	ra,0xfffff
    80004aa0:	2f8080e7          	jalr	760(ra) # 80003d94 <stati>
    iunlock(f->ip);
    80004aa4:	6c88                	ld	a0,24(s1)
    80004aa6:	fffff097          	auipc	ra,0xfffff
    80004aaa:	126080e7          	jalr	294(ra) # 80003bcc <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004aae:	46e1                	li	a3,24
    80004ab0:	fb840613          	addi	a2,s0,-72
    80004ab4:	85ce                	mv	a1,s3
    80004ab6:	05093503          	ld	a0,80(s2)
    80004aba:	ffffd097          	auipc	ra,0xffffd
    80004abe:	bb2080e7          	jalr	-1102(ra) # 8000166c <copyout>
    80004ac2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ac6:	60a6                	ld	ra,72(sp)
    80004ac8:	6406                	ld	s0,64(sp)
    80004aca:	74e2                	ld	s1,56(sp)
    80004acc:	7942                	ld	s2,48(sp)
    80004ace:	79a2                	ld	s3,40(sp)
    80004ad0:	6161                	addi	sp,sp,80
    80004ad2:	8082                	ret
  return -1;
    80004ad4:	557d                	li	a0,-1
    80004ad6:	bfc5                	j	80004ac6 <filestat+0x60>

0000000080004ad8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    80004ad8:	7179                	addi	sp,sp,-48
    80004ada:	f406                	sd	ra,40(sp)
    80004adc:	f022                	sd	s0,32(sp)
    80004ade:	ec26                	sd	s1,24(sp)
    80004ae0:	e84a                	sd	s2,16(sp)
    80004ae2:	e44e                	sd	s3,8(sp)
    80004ae4:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    80004ae6:	00854783          	lbu	a5,8(a0)
    80004aea:	c3d5                	beqz	a5,80004b8e <fileread+0xb6>
    80004aec:	84aa                	mv	s1,a0
    80004aee:	89ae                	mv	s3,a1
    80004af0:	8932                	mv	s2,a2
    return -1;

  if (f->type == FD_PIPE)
    80004af2:	411c                	lw	a5,0(a0)
    80004af4:	4705                	li	a4,1
    80004af6:	04e78963          	beq	a5,a4,80004b48 <fileread+0x70>
  {
    r = piperead(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004afa:	470d                	li	a4,3
    80004afc:	04e78d63          	beq	a5,a4,80004b56 <fileread+0x7e>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004b00:	4709                	li	a4,2
    80004b02:	06e79e63          	bne	a5,a4,80004b7e <fileread+0xa6>
  {
    ilock(f->ip);
    80004b06:	6d08                	ld	a0,24(a0)
    80004b08:	fffff097          	auipc	ra,0xfffff
    80004b0c:	002080e7          	jalr	2(ra) # 80003b0a <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b10:	874a                	mv	a4,s2
    80004b12:	5094                	lw	a3,32(s1)
    80004b14:	864e                	mv	a2,s3
    80004b16:	4585                	li	a1,1
    80004b18:	6c88                	ld	a0,24(s1)
    80004b1a:	fffff097          	auipc	ra,0xfffff
    80004b1e:	2a4080e7          	jalr	676(ra) # 80003dbe <readi>
    80004b22:	892a                	mv	s2,a0
    80004b24:	00a05563          	blez	a0,80004b2e <fileread+0x56>
      f->off += r;
    80004b28:	509c                	lw	a5,32(s1)
    80004b2a:	9fa9                	addw	a5,a5,a0
    80004b2c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b2e:	6c88                	ld	a0,24(s1)
    80004b30:	fffff097          	auipc	ra,0xfffff
    80004b34:	09c080e7          	jalr	156(ra) # 80003bcc <iunlock>
  {
    panic("fileread");
  }

  return r;
}
    80004b38:	854a                	mv	a0,s2
    80004b3a:	70a2                	ld	ra,40(sp)
    80004b3c:	7402                	ld	s0,32(sp)
    80004b3e:	64e2                	ld	s1,24(sp)
    80004b40:	6942                	ld	s2,16(sp)
    80004b42:	69a2                	ld	s3,8(sp)
    80004b44:	6145                	addi	sp,sp,48
    80004b46:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b48:	6908                	ld	a0,16(a0)
    80004b4a:	00000097          	auipc	ra,0x0
    80004b4e:	3c6080e7          	jalr	966(ra) # 80004f10 <piperead>
    80004b52:	892a                	mv	s2,a0
    80004b54:	b7d5                	j	80004b38 <fileread+0x60>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b56:	02451783          	lh	a5,36(a0)
    80004b5a:	03079693          	slli	a3,a5,0x30
    80004b5e:	92c1                	srli	a3,a3,0x30
    80004b60:	4725                	li	a4,9
    80004b62:	02d76863          	bltu	a4,a3,80004b92 <fileread+0xba>
    80004b66:	0792                	slli	a5,a5,0x4
    80004b68:	0001e717          	auipc	a4,0x1e
    80004b6c:	8b070713          	addi	a4,a4,-1872 # 80022418 <devsw>
    80004b70:	97ba                	add	a5,a5,a4
    80004b72:	639c                	ld	a5,0(a5)
    80004b74:	c38d                	beqz	a5,80004b96 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b76:	4505                	li	a0,1
    80004b78:	9782                	jalr	a5
    80004b7a:	892a                	mv	s2,a0
    80004b7c:	bf75                	j	80004b38 <fileread+0x60>
    panic("fileread");
    80004b7e:	00004517          	auipc	a0,0x4
    80004b82:	b4250513          	addi	a0,a0,-1214 # 800086c0 <syscalls+0x270>
    80004b86:	ffffc097          	auipc	ra,0xffffc
    80004b8a:	9ba080e7          	jalr	-1606(ra) # 80000540 <panic>
    return -1;
    80004b8e:	597d                	li	s2,-1
    80004b90:	b765                	j	80004b38 <fileread+0x60>
      return -1;
    80004b92:	597d                	li	s2,-1
    80004b94:	b755                	j	80004b38 <fileread+0x60>
    80004b96:	597d                	li	s2,-1
    80004b98:	b745                	j	80004b38 <fileread+0x60>

0000000080004b9a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    80004b9a:	715d                	addi	sp,sp,-80
    80004b9c:	e486                	sd	ra,72(sp)
    80004b9e:	e0a2                	sd	s0,64(sp)
    80004ba0:	fc26                	sd	s1,56(sp)
    80004ba2:	f84a                	sd	s2,48(sp)
    80004ba4:	f44e                	sd	s3,40(sp)
    80004ba6:	f052                	sd	s4,32(sp)
    80004ba8:	ec56                	sd	s5,24(sp)
    80004baa:	e85a                	sd	s6,16(sp)
    80004bac:	e45e                	sd	s7,8(sp)
    80004bae:	e062                	sd	s8,0(sp)
    80004bb0:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if (f->writable == 0)
    80004bb2:	00954783          	lbu	a5,9(a0)
    80004bb6:	10078663          	beqz	a5,80004cc2 <filewrite+0x128>
    80004bba:	892a                	mv	s2,a0
    80004bbc:	8b2e                	mv	s6,a1
    80004bbe:	8a32                	mv	s4,a2
    return -1;

  if (f->type == FD_PIPE)
    80004bc0:	411c                	lw	a5,0(a0)
    80004bc2:	4705                	li	a4,1
    80004bc4:	02e78263          	beq	a5,a4,80004be8 <filewrite+0x4e>
  {
    ret = pipewrite(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004bc8:	470d                	li	a4,3
    80004bca:	02e78663          	beq	a5,a4,80004bf6 <filewrite+0x5c>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004bce:	4709                	li	a4,2
    80004bd0:	0ee79163          	bne	a5,a4,80004cb2 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n)
    80004bd4:	0ac05d63          	blez	a2,80004c8e <filewrite+0xf4>
    int i = 0;
    80004bd8:	4981                	li	s3,0
    80004bda:	6b85                	lui	s7,0x1
    80004bdc:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004be0:	6c05                	lui	s8,0x1
    80004be2:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004be6:	a861                	j	80004c7e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004be8:	6908                	ld	a0,16(a0)
    80004bea:	00000097          	auipc	ra,0x0
    80004bee:	22e080e7          	jalr	558(ra) # 80004e18 <pipewrite>
    80004bf2:	8a2a                	mv	s4,a0
    80004bf4:	a045                	j	80004c94 <filewrite+0xfa>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bf6:	02451783          	lh	a5,36(a0)
    80004bfa:	03079693          	slli	a3,a5,0x30
    80004bfe:	92c1                	srli	a3,a3,0x30
    80004c00:	4725                	li	a4,9
    80004c02:	0cd76263          	bltu	a4,a3,80004cc6 <filewrite+0x12c>
    80004c06:	0792                	slli	a5,a5,0x4
    80004c08:	0001e717          	auipc	a4,0x1e
    80004c0c:	81070713          	addi	a4,a4,-2032 # 80022418 <devsw>
    80004c10:	97ba                	add	a5,a5,a4
    80004c12:	679c                	ld	a5,8(a5)
    80004c14:	cbdd                	beqz	a5,80004cca <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c16:	4505                	li	a0,1
    80004c18:	9782                	jalr	a5
    80004c1a:	8a2a                	mv	s4,a0
    80004c1c:	a8a5                	j	80004c94 <filewrite+0xfa>
    80004c1e:	00048a9b          	sext.w	s5,s1
    {
      int n1 = n - i;
      if (n1 > max)
        n1 = max;

      begin_op();
    80004c22:	00000097          	auipc	ra,0x0
    80004c26:	8b4080e7          	jalr	-1868(ra) # 800044d6 <begin_op>
      ilock(f->ip);
    80004c2a:	01893503          	ld	a0,24(s2)
    80004c2e:	fffff097          	auipc	ra,0xfffff
    80004c32:	edc080e7          	jalr	-292(ra) # 80003b0a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c36:	8756                	mv	a4,s5
    80004c38:	02092683          	lw	a3,32(s2)
    80004c3c:	01698633          	add	a2,s3,s6
    80004c40:	4585                	li	a1,1
    80004c42:	01893503          	ld	a0,24(s2)
    80004c46:	fffff097          	auipc	ra,0xfffff
    80004c4a:	270080e7          	jalr	624(ra) # 80003eb6 <writei>
    80004c4e:	84aa                	mv	s1,a0
    80004c50:	00a05763          	blez	a0,80004c5e <filewrite+0xc4>
        f->off += r;
    80004c54:	02092783          	lw	a5,32(s2)
    80004c58:	9fa9                	addw	a5,a5,a0
    80004c5a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c5e:	01893503          	ld	a0,24(s2)
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	f6a080e7          	jalr	-150(ra) # 80003bcc <iunlock>
      end_op();
    80004c6a:	00000097          	auipc	ra,0x0
    80004c6e:	8ea080e7          	jalr	-1814(ra) # 80004554 <end_op>

      if (r != n1)
    80004c72:	009a9f63          	bne	s5,s1,80004c90 <filewrite+0xf6>
      {
        // error from writei
        break;
      }
      i += r;
    80004c76:	013489bb          	addw	s3,s1,s3
    while (i < n)
    80004c7a:	0149db63          	bge	s3,s4,80004c90 <filewrite+0xf6>
      int n1 = n - i;
    80004c7e:	413a04bb          	subw	s1,s4,s3
    80004c82:	0004879b          	sext.w	a5,s1
    80004c86:	f8fbdce3          	bge	s7,a5,80004c1e <filewrite+0x84>
    80004c8a:	84e2                	mv	s1,s8
    80004c8c:	bf49                	j	80004c1e <filewrite+0x84>
    int i = 0;
    80004c8e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c90:	013a1f63          	bne	s4,s3,80004cae <filewrite+0x114>
  {
    panic("filewrite");
  }

  return ret;
}
    80004c94:	8552                	mv	a0,s4
    80004c96:	60a6                	ld	ra,72(sp)
    80004c98:	6406                	ld	s0,64(sp)
    80004c9a:	74e2                	ld	s1,56(sp)
    80004c9c:	7942                	ld	s2,48(sp)
    80004c9e:	79a2                	ld	s3,40(sp)
    80004ca0:	7a02                	ld	s4,32(sp)
    80004ca2:	6ae2                	ld	s5,24(sp)
    80004ca4:	6b42                	ld	s6,16(sp)
    80004ca6:	6ba2                	ld	s7,8(sp)
    80004ca8:	6c02                	ld	s8,0(sp)
    80004caa:	6161                	addi	sp,sp,80
    80004cac:	8082                	ret
    ret = (i == n ? n : -1);
    80004cae:	5a7d                	li	s4,-1
    80004cb0:	b7d5                	j	80004c94 <filewrite+0xfa>
    panic("filewrite");
    80004cb2:	00004517          	auipc	a0,0x4
    80004cb6:	a1e50513          	addi	a0,a0,-1506 # 800086d0 <syscalls+0x280>
    80004cba:	ffffc097          	auipc	ra,0xffffc
    80004cbe:	886080e7          	jalr	-1914(ra) # 80000540 <panic>
    return -1;
    80004cc2:	5a7d                	li	s4,-1
    80004cc4:	bfc1                	j	80004c94 <filewrite+0xfa>
      return -1;
    80004cc6:	5a7d                	li	s4,-1
    80004cc8:	b7f1                	j	80004c94 <filewrite+0xfa>
    80004cca:	5a7d                	li	s4,-1
    80004ccc:	b7e1                	j	80004c94 <filewrite+0xfa>

0000000080004cce <pipealloc>:
  int readopen;  // read fd is still open
  int writeopen; // write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
    80004cce:	7179                	addi	sp,sp,-48
    80004cd0:	f406                	sd	ra,40(sp)
    80004cd2:	f022                	sd	s0,32(sp)
    80004cd4:	ec26                	sd	s1,24(sp)
    80004cd6:	e84a                	sd	s2,16(sp)
    80004cd8:	e44e                	sd	s3,8(sp)
    80004cda:	e052                	sd	s4,0(sp)
    80004cdc:	1800                	addi	s0,sp,48
    80004cde:	84aa                	mv	s1,a0
    80004ce0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ce2:	0005b023          	sd	zero,0(a1)
    80004ce6:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004cea:	00000097          	auipc	ra,0x0
    80004cee:	bf8080e7          	jalr	-1032(ra) # 800048e2 <filealloc>
    80004cf2:	e088                	sd	a0,0(s1)
    80004cf4:	c551                	beqz	a0,80004d80 <pipealloc+0xb2>
    80004cf6:	00000097          	auipc	ra,0x0
    80004cfa:	bec080e7          	jalr	-1044(ra) # 800048e2 <filealloc>
    80004cfe:	00aa3023          	sd	a0,0(s4)
    80004d02:	c92d                	beqz	a0,80004d74 <pipealloc+0xa6>
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004d04:	ffffc097          	auipc	ra,0xffffc
    80004d08:	de2080e7          	jalr	-542(ra) # 80000ae6 <kalloc>
    80004d0c:	892a                	mv	s2,a0
    80004d0e:	c125                	beqz	a0,80004d6e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d10:	4985                	li	s3,1
    80004d12:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d16:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d1a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d1e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d22:	00004597          	auipc	a1,0x4
    80004d26:	9be58593          	addi	a1,a1,-1602 # 800086e0 <syscalls+0x290>
    80004d2a:	ffffc097          	auipc	ra,0xffffc
    80004d2e:	e1c080e7          	jalr	-484(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004d32:	609c                	ld	a5,0(s1)
    80004d34:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d38:	609c                	ld	a5,0(s1)
    80004d3a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d3e:	609c                	ld	a5,0(s1)
    80004d40:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d44:	609c                	ld	a5,0(s1)
    80004d46:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d4a:	000a3783          	ld	a5,0(s4)
    80004d4e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d52:	000a3783          	ld	a5,0(s4)
    80004d56:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d5a:	000a3783          	ld	a5,0(s4)
    80004d5e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d62:	000a3783          	ld	a5,0(s4)
    80004d66:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d6a:	4501                	li	a0,0
    80004d6c:	a025                	j	80004d94 <pipealloc+0xc6>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004d6e:	6088                	ld	a0,0(s1)
    80004d70:	e501                	bnez	a0,80004d78 <pipealloc+0xaa>
    80004d72:	a039                	j	80004d80 <pipealloc+0xb2>
    80004d74:	6088                	ld	a0,0(s1)
    80004d76:	c51d                	beqz	a0,80004da4 <pipealloc+0xd6>
    fileclose(*f0);
    80004d78:	00000097          	auipc	ra,0x0
    80004d7c:	c26080e7          	jalr	-986(ra) # 8000499e <fileclose>
  if (*f1)
    80004d80:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d84:	557d                	li	a0,-1
  if (*f1)
    80004d86:	c799                	beqz	a5,80004d94 <pipealloc+0xc6>
    fileclose(*f1);
    80004d88:	853e                	mv	a0,a5
    80004d8a:	00000097          	auipc	ra,0x0
    80004d8e:	c14080e7          	jalr	-1004(ra) # 8000499e <fileclose>
  return -1;
    80004d92:	557d                	li	a0,-1
}
    80004d94:	70a2                	ld	ra,40(sp)
    80004d96:	7402                	ld	s0,32(sp)
    80004d98:	64e2                	ld	s1,24(sp)
    80004d9a:	6942                	ld	s2,16(sp)
    80004d9c:	69a2                	ld	s3,8(sp)
    80004d9e:	6a02                	ld	s4,0(sp)
    80004da0:	6145                	addi	sp,sp,48
    80004da2:	8082                	ret
  return -1;
    80004da4:	557d                	li	a0,-1
    80004da6:	b7fd                	j	80004d94 <pipealloc+0xc6>

0000000080004da8 <pipeclose>:

void pipeclose(struct pipe *pi, int writable)
{
    80004da8:	1101                	addi	sp,sp,-32
    80004daa:	ec06                	sd	ra,24(sp)
    80004dac:	e822                	sd	s0,16(sp)
    80004dae:	e426                	sd	s1,8(sp)
    80004db0:	e04a                	sd	s2,0(sp)
    80004db2:	1000                	addi	s0,sp,32
    80004db4:	84aa                	mv	s1,a0
    80004db6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004db8:	ffffc097          	auipc	ra,0xffffc
    80004dbc:	e1e080e7          	jalr	-482(ra) # 80000bd6 <acquire>
  if (writable)
    80004dc0:	02090d63          	beqz	s2,80004dfa <pipeclose+0x52>
  {
    pi->writeopen = 0;
    80004dc4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004dc8:	21848513          	addi	a0,s1,536
    80004dcc:	ffffd097          	auipc	ra,0xffffd
    80004dd0:	460080e7          	jalr	1120(ra) # 8000222c <wakeup>
  else
  {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0)
    80004dd4:	2204b783          	ld	a5,544(s1)
    80004dd8:	eb95                	bnez	a5,80004e0c <pipeclose+0x64>
  {
    release(&pi->lock);
    80004dda:	8526                	mv	a0,s1
    80004ddc:	ffffc097          	auipc	ra,0xffffc
    80004de0:	eae080e7          	jalr	-338(ra) # 80000c8a <release>
    kfree((char *)pi);
    80004de4:	8526                	mv	a0,s1
    80004de6:	ffffc097          	auipc	ra,0xffffc
    80004dea:	c02080e7          	jalr	-1022(ra) # 800009e8 <kfree>
  }
  else
    release(&pi->lock);
}
    80004dee:	60e2                	ld	ra,24(sp)
    80004df0:	6442                	ld	s0,16(sp)
    80004df2:	64a2                	ld	s1,8(sp)
    80004df4:	6902                	ld	s2,0(sp)
    80004df6:	6105                	addi	sp,sp,32
    80004df8:	8082                	ret
    pi->readopen = 0;
    80004dfa:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004dfe:	21c48513          	addi	a0,s1,540
    80004e02:	ffffd097          	auipc	ra,0xffffd
    80004e06:	42a080e7          	jalr	1066(ra) # 8000222c <wakeup>
    80004e0a:	b7e9                	j	80004dd4 <pipeclose+0x2c>
    release(&pi->lock);
    80004e0c:	8526                	mv	a0,s1
    80004e0e:	ffffc097          	auipc	ra,0xffffc
    80004e12:	e7c080e7          	jalr	-388(ra) # 80000c8a <release>
}
    80004e16:	bfe1                	j	80004dee <pipeclose+0x46>

0000000080004e18 <pipewrite>:

int pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e18:	711d                	addi	sp,sp,-96
    80004e1a:	ec86                	sd	ra,88(sp)
    80004e1c:	e8a2                	sd	s0,80(sp)
    80004e1e:	e4a6                	sd	s1,72(sp)
    80004e20:	e0ca                	sd	s2,64(sp)
    80004e22:	fc4e                	sd	s3,56(sp)
    80004e24:	f852                	sd	s4,48(sp)
    80004e26:	f456                	sd	s5,40(sp)
    80004e28:	f05a                	sd	s6,32(sp)
    80004e2a:	ec5e                	sd	s7,24(sp)
    80004e2c:	e862                	sd	s8,16(sp)
    80004e2e:	1080                	addi	s0,sp,96
    80004e30:	84aa                	mv	s1,a0
    80004e32:	8aae                	mv	s5,a1
    80004e34:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e36:	ffffd097          	auipc	ra,0xffffd
    80004e3a:	b76080e7          	jalr	-1162(ra) # 800019ac <myproc>
    80004e3e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e40:	8526                	mv	a0,s1
    80004e42:	ffffc097          	auipc	ra,0xffffc
    80004e46:	d94080e7          	jalr	-620(ra) # 80000bd6 <acquire>
  while (i < n)
    80004e4a:	0b405663          	blez	s4,80004ef6 <pipewrite+0xde>
  int i = 0;
    80004e4e:	4901                	li	s2,0
      sleep(&pi->nwrite, &pi->lock);
    }
    else
    {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e50:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e52:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e56:	21c48b93          	addi	s7,s1,540
    80004e5a:	a089                	j	80004e9c <pipewrite+0x84>
      release(&pi->lock);
    80004e5c:	8526                	mv	a0,s1
    80004e5e:	ffffc097          	auipc	ra,0xffffc
    80004e62:	e2c080e7          	jalr	-468(ra) # 80000c8a <release>
      return -1;
    80004e66:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e68:	854a                	mv	a0,s2
    80004e6a:	60e6                	ld	ra,88(sp)
    80004e6c:	6446                	ld	s0,80(sp)
    80004e6e:	64a6                	ld	s1,72(sp)
    80004e70:	6906                	ld	s2,64(sp)
    80004e72:	79e2                	ld	s3,56(sp)
    80004e74:	7a42                	ld	s4,48(sp)
    80004e76:	7aa2                	ld	s5,40(sp)
    80004e78:	7b02                	ld	s6,32(sp)
    80004e7a:	6be2                	ld	s7,24(sp)
    80004e7c:	6c42                	ld	s8,16(sp)
    80004e7e:	6125                	addi	sp,sp,96
    80004e80:	8082                	ret
      wakeup(&pi->nread);
    80004e82:	8562                	mv	a0,s8
    80004e84:	ffffd097          	auipc	ra,0xffffd
    80004e88:	3a8080e7          	jalr	936(ra) # 8000222c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e8c:	85a6                	mv	a1,s1
    80004e8e:	855e                	mv	a0,s7
    80004e90:	ffffd097          	auipc	ra,0xffffd
    80004e94:	338080e7          	jalr	824(ra) # 800021c8 <sleep>
  while (i < n)
    80004e98:	07495063          	bge	s2,s4,80004ef8 <pipewrite+0xe0>
    if (pi->readopen == 0 || killed(pr))
    80004e9c:	2204a783          	lw	a5,544(s1)
    80004ea0:	dfd5                	beqz	a5,80004e5c <pipewrite+0x44>
    80004ea2:	854e                	mv	a0,s3
    80004ea4:	ffffd097          	auipc	ra,0xffffd
    80004ea8:	5d8080e7          	jalr	1496(ra) # 8000247c <killed>
    80004eac:	f945                	bnez	a0,80004e5c <pipewrite+0x44>
    if (pi->nwrite == pi->nread + PIPESIZE)
    80004eae:	2184a783          	lw	a5,536(s1)
    80004eb2:	21c4a703          	lw	a4,540(s1)
    80004eb6:	2007879b          	addiw	a5,a5,512
    80004eba:	fcf704e3          	beq	a4,a5,80004e82 <pipewrite+0x6a>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ebe:	4685                	li	a3,1
    80004ec0:	01590633          	add	a2,s2,s5
    80004ec4:	faf40593          	addi	a1,s0,-81
    80004ec8:	0509b503          	ld	a0,80(s3)
    80004ecc:	ffffd097          	auipc	ra,0xffffd
    80004ed0:	82c080e7          	jalr	-2004(ra) # 800016f8 <copyin>
    80004ed4:	03650263          	beq	a0,s6,80004ef8 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ed8:	21c4a783          	lw	a5,540(s1)
    80004edc:	0017871b          	addiw	a4,a5,1
    80004ee0:	20e4ae23          	sw	a4,540(s1)
    80004ee4:	1ff7f793          	andi	a5,a5,511
    80004ee8:	97a6                	add	a5,a5,s1
    80004eea:	faf44703          	lbu	a4,-81(s0)
    80004eee:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ef2:	2905                	addiw	s2,s2,1
    80004ef4:	b755                	j	80004e98 <pipewrite+0x80>
  int i = 0;
    80004ef6:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ef8:	21848513          	addi	a0,s1,536
    80004efc:	ffffd097          	auipc	ra,0xffffd
    80004f00:	330080e7          	jalr	816(ra) # 8000222c <wakeup>
  release(&pi->lock);
    80004f04:	8526                	mv	a0,s1
    80004f06:	ffffc097          	auipc	ra,0xffffc
    80004f0a:	d84080e7          	jalr	-636(ra) # 80000c8a <release>
  return i;
    80004f0e:	bfa9                	j	80004e68 <pipewrite+0x50>

0000000080004f10 <piperead>:

int piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f10:	715d                	addi	sp,sp,-80
    80004f12:	e486                	sd	ra,72(sp)
    80004f14:	e0a2                	sd	s0,64(sp)
    80004f16:	fc26                	sd	s1,56(sp)
    80004f18:	f84a                	sd	s2,48(sp)
    80004f1a:	f44e                	sd	s3,40(sp)
    80004f1c:	f052                	sd	s4,32(sp)
    80004f1e:	ec56                	sd	s5,24(sp)
    80004f20:	e85a                	sd	s6,16(sp)
    80004f22:	0880                	addi	s0,sp,80
    80004f24:	84aa                	mv	s1,a0
    80004f26:	892e                	mv	s2,a1
    80004f28:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f2a:	ffffd097          	auipc	ra,0xffffd
    80004f2e:	a82080e7          	jalr	-1406(ra) # 800019ac <myproc>
    80004f32:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f34:	8526                	mv	a0,s1
    80004f36:	ffffc097          	auipc	ra,0xffffc
    80004f3a:	ca0080e7          	jalr	-864(ra) # 80000bd6 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004f3e:	2184a703          	lw	a4,536(s1)
    80004f42:	21c4a783          	lw	a5,540(s1)
    if (killed(pr))
    {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004f46:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004f4a:	02f71763          	bne	a4,a5,80004f78 <piperead+0x68>
    80004f4e:	2244a783          	lw	a5,548(s1)
    80004f52:	c39d                	beqz	a5,80004f78 <piperead+0x68>
    if (killed(pr))
    80004f54:	8552                	mv	a0,s4
    80004f56:	ffffd097          	auipc	ra,0xffffd
    80004f5a:	526080e7          	jalr	1318(ra) # 8000247c <killed>
    80004f5e:	e949                	bnez	a0,80004ff0 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004f60:	85a6                	mv	a1,s1
    80004f62:	854e                	mv	a0,s3
    80004f64:	ffffd097          	auipc	ra,0xffffd
    80004f68:	264080e7          	jalr	612(ra) # 800021c8 <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004f6c:	2184a703          	lw	a4,536(s1)
    80004f70:	21c4a783          	lw	a5,540(s1)
    80004f74:	fcf70de3          	beq	a4,a5,80004f4e <piperead+0x3e>
  }
  for (i = 0; i < n; i++)
    80004f78:	4981                	li	s3,0
  { // DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f7a:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++)
    80004f7c:	05505463          	blez	s5,80004fc4 <piperead+0xb4>
    if (pi->nread == pi->nwrite)
    80004f80:	2184a783          	lw	a5,536(s1)
    80004f84:	21c4a703          	lw	a4,540(s1)
    80004f88:	02f70e63          	beq	a4,a5,80004fc4 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f8c:	0017871b          	addiw	a4,a5,1
    80004f90:	20e4ac23          	sw	a4,536(s1)
    80004f94:	1ff7f793          	andi	a5,a5,511
    80004f98:	97a6                	add	a5,a5,s1
    80004f9a:	0187c783          	lbu	a5,24(a5)
    80004f9e:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fa2:	4685                	li	a3,1
    80004fa4:	fbf40613          	addi	a2,s0,-65
    80004fa8:	85ca                	mv	a1,s2
    80004faa:	050a3503          	ld	a0,80(s4)
    80004fae:	ffffc097          	auipc	ra,0xffffc
    80004fb2:	6be080e7          	jalr	1726(ra) # 8000166c <copyout>
    80004fb6:	01650763          	beq	a0,s6,80004fc4 <piperead+0xb4>
  for (i = 0; i < n; i++)
    80004fba:	2985                	addiw	s3,s3,1
    80004fbc:	0905                	addi	s2,s2,1
    80004fbe:	fd3a91e3          	bne	s5,s3,80004f80 <piperead+0x70>
    80004fc2:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite); // DOC: piperead-wakeup
    80004fc4:	21c48513          	addi	a0,s1,540
    80004fc8:	ffffd097          	auipc	ra,0xffffd
    80004fcc:	264080e7          	jalr	612(ra) # 8000222c <wakeup>
  release(&pi->lock);
    80004fd0:	8526                	mv	a0,s1
    80004fd2:	ffffc097          	auipc	ra,0xffffc
    80004fd6:	cb8080e7          	jalr	-840(ra) # 80000c8a <release>
  return i;
}
    80004fda:	854e                	mv	a0,s3
    80004fdc:	60a6                	ld	ra,72(sp)
    80004fde:	6406                	ld	s0,64(sp)
    80004fe0:	74e2                	ld	s1,56(sp)
    80004fe2:	7942                	ld	s2,48(sp)
    80004fe4:	79a2                	ld	s3,40(sp)
    80004fe6:	7a02                	ld	s4,32(sp)
    80004fe8:	6ae2                	ld	s5,24(sp)
    80004fea:	6b42                	ld	s6,16(sp)
    80004fec:	6161                	addi	sp,sp,80
    80004fee:	8082                	ret
      release(&pi->lock);
    80004ff0:	8526                	mv	a0,s1
    80004ff2:	ffffc097          	auipc	ra,0xffffc
    80004ff6:	c98080e7          	jalr	-872(ra) # 80000c8a <release>
      return -1;
    80004ffa:	59fd                	li	s3,-1
    80004ffc:	bff9                	j	80004fda <piperead+0xca>

0000000080004ffe <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004ffe:	1141                	addi	sp,sp,-16
    80005000:	e422                	sd	s0,8(sp)
    80005002:	0800                	addi	s0,sp,16
    80005004:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80005006:	8905                	andi	a0,a0,1
    80005008:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    8000500a:	8b89                	andi	a5,a5,2
    8000500c:	c399                	beqz	a5,80005012 <flags2perm+0x14>
    perm |= PTE_W;
    8000500e:	00456513          	ori	a0,a0,4
  return perm;
}
    80005012:	6422                	ld	s0,8(sp)
    80005014:	0141                	addi	sp,sp,16
    80005016:	8082                	ret

0000000080005018 <exec>:

int exec(char *path, char **argv)
{
    80005018:	de010113          	addi	sp,sp,-544
    8000501c:	20113c23          	sd	ra,536(sp)
    80005020:	20813823          	sd	s0,528(sp)
    80005024:	20913423          	sd	s1,520(sp)
    80005028:	21213023          	sd	s2,512(sp)
    8000502c:	ffce                	sd	s3,504(sp)
    8000502e:	fbd2                	sd	s4,496(sp)
    80005030:	f7d6                	sd	s5,488(sp)
    80005032:	f3da                	sd	s6,480(sp)
    80005034:	efde                	sd	s7,472(sp)
    80005036:	ebe2                	sd	s8,464(sp)
    80005038:	e7e6                	sd	s9,456(sp)
    8000503a:	e3ea                	sd	s10,448(sp)
    8000503c:	ff6e                	sd	s11,440(sp)
    8000503e:	1400                	addi	s0,sp,544
    80005040:	892a                	mv	s2,a0
    80005042:	dea43423          	sd	a0,-536(s0)
    80005046:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000504a:	ffffd097          	auipc	ra,0xffffd
    8000504e:	962080e7          	jalr	-1694(ra) # 800019ac <myproc>
    80005052:	84aa                	mv	s1,a0

  begin_op();
    80005054:	fffff097          	auipc	ra,0xfffff
    80005058:	482080e7          	jalr	1154(ra) # 800044d6 <begin_op>

  if ((ip = namei(path)) == 0)
    8000505c:	854a                	mv	a0,s2
    8000505e:	fffff097          	auipc	ra,0xfffff
    80005062:	258080e7          	jalr	600(ra) # 800042b6 <namei>
    80005066:	c93d                	beqz	a0,800050dc <exec+0xc4>
    80005068:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    8000506a:	fffff097          	auipc	ra,0xfffff
    8000506e:	aa0080e7          	jalr	-1376(ra) # 80003b0a <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005072:	04000713          	li	a4,64
    80005076:	4681                	li	a3,0
    80005078:	e5040613          	addi	a2,s0,-432
    8000507c:	4581                	li	a1,0
    8000507e:	8556                	mv	a0,s5
    80005080:	fffff097          	auipc	ra,0xfffff
    80005084:	d3e080e7          	jalr	-706(ra) # 80003dbe <readi>
    80005088:	04000793          	li	a5,64
    8000508c:	00f51a63          	bne	a0,a5,800050a0 <exec+0x88>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    80005090:	e5042703          	lw	a4,-432(s0)
    80005094:	464c47b7          	lui	a5,0x464c4
    80005098:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000509c:	04f70663          	beq	a4,a5,800050e8 <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    800050a0:	8556                	mv	a0,s5
    800050a2:	fffff097          	auipc	ra,0xfffff
    800050a6:	cca080e7          	jalr	-822(ra) # 80003d6c <iunlockput>
    end_op();
    800050aa:	fffff097          	auipc	ra,0xfffff
    800050ae:	4aa080e7          	jalr	1194(ra) # 80004554 <end_op>
  }
  return -1;
    800050b2:	557d                	li	a0,-1
}
    800050b4:	21813083          	ld	ra,536(sp)
    800050b8:	21013403          	ld	s0,528(sp)
    800050bc:	20813483          	ld	s1,520(sp)
    800050c0:	20013903          	ld	s2,512(sp)
    800050c4:	79fe                	ld	s3,504(sp)
    800050c6:	7a5e                	ld	s4,496(sp)
    800050c8:	7abe                	ld	s5,488(sp)
    800050ca:	7b1e                	ld	s6,480(sp)
    800050cc:	6bfe                	ld	s7,472(sp)
    800050ce:	6c5e                	ld	s8,464(sp)
    800050d0:	6cbe                	ld	s9,456(sp)
    800050d2:	6d1e                	ld	s10,448(sp)
    800050d4:	7dfa                	ld	s11,440(sp)
    800050d6:	22010113          	addi	sp,sp,544
    800050da:	8082                	ret
    end_op();
    800050dc:	fffff097          	auipc	ra,0xfffff
    800050e0:	478080e7          	jalr	1144(ra) # 80004554 <end_op>
    return -1;
    800050e4:	557d                	li	a0,-1
    800050e6:	b7f9                	j	800050b4 <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    800050e8:	8526                	mv	a0,s1
    800050ea:	ffffd097          	auipc	ra,0xffffd
    800050ee:	986080e7          	jalr	-1658(ra) # 80001a70 <proc_pagetable>
    800050f2:	8b2a                	mv	s6,a0
    800050f4:	d555                	beqz	a0,800050a0 <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800050f6:	e7042783          	lw	a5,-400(s0)
    800050fa:	e8845703          	lhu	a4,-376(s0)
    800050fe:	c735                	beqz	a4,8000516a <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005100:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005102:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    80005106:	6a05                	lui	s4,0x1
    80005108:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000510c:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for (i = 0; i < sz; i += PGSIZE)
    80005110:	6d85                	lui	s11,0x1
    80005112:	7d7d                	lui	s10,0xfffff
    80005114:	ac3d                	j	80005352 <exec+0x33a>
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    80005116:	00003517          	auipc	a0,0x3
    8000511a:	5d250513          	addi	a0,a0,1490 # 800086e8 <syscalls+0x298>
    8000511e:	ffffb097          	auipc	ra,0xffffb
    80005122:	422080e7          	jalr	1058(ra) # 80000540 <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80005126:	874a                	mv	a4,s2
    80005128:	009c86bb          	addw	a3,s9,s1
    8000512c:	4581                	li	a1,0
    8000512e:	8556                	mv	a0,s5
    80005130:	fffff097          	auipc	ra,0xfffff
    80005134:	c8e080e7          	jalr	-882(ra) # 80003dbe <readi>
    80005138:	2501                	sext.w	a0,a0
    8000513a:	1aa91963          	bne	s2,a0,800052ec <exec+0x2d4>
  for (i = 0; i < sz; i += PGSIZE)
    8000513e:	009d84bb          	addw	s1,s11,s1
    80005142:	013d09bb          	addw	s3,s10,s3
    80005146:	1f74f663          	bgeu	s1,s7,80005332 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    8000514a:	02049593          	slli	a1,s1,0x20
    8000514e:	9181                	srli	a1,a1,0x20
    80005150:	95e2                	add	a1,a1,s8
    80005152:	855a                	mv	a0,s6
    80005154:	ffffc097          	auipc	ra,0xffffc
    80005158:	f08080e7          	jalr	-248(ra) # 8000105c <walkaddr>
    8000515c:	862a                	mv	a2,a0
    if (pa == 0)
    8000515e:	dd45                	beqz	a0,80005116 <exec+0xfe>
      n = PGSIZE;
    80005160:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005162:	fd49f2e3          	bgeu	s3,s4,80005126 <exec+0x10e>
      n = sz - i;
    80005166:	894e                	mv	s2,s3
    80005168:	bf7d                	j	80005126 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000516a:	4901                	li	s2,0
  iunlockput(ip);
    8000516c:	8556                	mv	a0,s5
    8000516e:	fffff097          	auipc	ra,0xfffff
    80005172:	bfe080e7          	jalr	-1026(ra) # 80003d6c <iunlockput>
  end_op();
    80005176:	fffff097          	auipc	ra,0xfffff
    8000517a:	3de080e7          	jalr	990(ra) # 80004554 <end_op>
  p = myproc();
    8000517e:	ffffd097          	auipc	ra,0xffffd
    80005182:	82e080e7          	jalr	-2002(ra) # 800019ac <myproc>
    80005186:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005188:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000518c:	6785                	lui	a5,0x1
    8000518e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005190:	97ca                	add	a5,a5,s2
    80005192:	777d                	lui	a4,0xfffff
    80005194:	8ff9                	and	a5,a5,a4
    80005196:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    8000519a:	4691                	li	a3,4
    8000519c:	6609                	lui	a2,0x2
    8000519e:	963e                	add	a2,a2,a5
    800051a0:	85be                	mv	a1,a5
    800051a2:	855a                	mv	a0,s6
    800051a4:	ffffc097          	auipc	ra,0xffffc
    800051a8:	26c080e7          	jalr	620(ra) # 80001410 <uvmalloc>
    800051ac:	8c2a                	mv	s8,a0
  ip = 0;
    800051ae:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    800051b0:	12050e63          	beqz	a0,800052ec <exec+0x2d4>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    800051b4:	75f9                	lui	a1,0xffffe
    800051b6:	95aa                	add	a1,a1,a0
    800051b8:	855a                	mv	a0,s6
    800051ba:	ffffc097          	auipc	ra,0xffffc
    800051be:	480080e7          	jalr	1152(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    800051c2:	7afd                	lui	s5,0xfffff
    800051c4:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    800051c6:	df043783          	ld	a5,-528(s0)
    800051ca:	6388                	ld	a0,0(a5)
    800051cc:	c925                	beqz	a0,8000523c <exec+0x224>
    800051ce:	e9040993          	addi	s3,s0,-368
    800051d2:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800051d6:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    800051d8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800051da:	ffffc097          	auipc	ra,0xffffc
    800051de:	c74080e7          	jalr	-908(ra) # 80000e4e <strlen>
    800051e2:	0015079b          	addiw	a5,a0,1
    800051e6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051ea:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    800051ee:	13596663          	bltu	s2,s5,8000531a <exec+0x302>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051f2:	df043d83          	ld	s11,-528(s0)
    800051f6:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800051fa:	8552                	mv	a0,s4
    800051fc:	ffffc097          	auipc	ra,0xffffc
    80005200:	c52080e7          	jalr	-942(ra) # 80000e4e <strlen>
    80005204:	0015069b          	addiw	a3,a0,1
    80005208:	8652                	mv	a2,s4
    8000520a:	85ca                	mv	a1,s2
    8000520c:	855a                	mv	a0,s6
    8000520e:	ffffc097          	auipc	ra,0xffffc
    80005212:	45e080e7          	jalr	1118(ra) # 8000166c <copyout>
    80005216:	10054663          	bltz	a0,80005322 <exec+0x30a>
    ustack[argc] = sp;
    8000521a:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    8000521e:	0485                	addi	s1,s1,1
    80005220:	008d8793          	addi	a5,s11,8
    80005224:	def43823          	sd	a5,-528(s0)
    80005228:	008db503          	ld	a0,8(s11)
    8000522c:	c911                	beqz	a0,80005240 <exec+0x228>
    if (argc >= MAXARG)
    8000522e:	09a1                	addi	s3,s3,8
    80005230:	fb3c95e3          	bne	s9,s3,800051da <exec+0x1c2>
  sz = sz1;
    80005234:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005238:	4a81                	li	s5,0
    8000523a:	a84d                	j	800052ec <exec+0x2d4>
  sp = sz;
    8000523c:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    8000523e:	4481                	li	s1,0
  ustack[argc] = 0;
    80005240:	00349793          	slli	a5,s1,0x3
    80005244:	f9078793          	addi	a5,a5,-112
    80005248:	97a2                	add	a5,a5,s0
    8000524a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    8000524e:	00148693          	addi	a3,s1,1
    80005252:	068e                	slli	a3,a3,0x3
    80005254:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005258:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    8000525c:	01597663          	bgeu	s2,s5,80005268 <exec+0x250>
  sz = sz1;
    80005260:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005264:	4a81                	li	s5,0
    80005266:	a059                	j	800052ec <exec+0x2d4>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    80005268:	e9040613          	addi	a2,s0,-368
    8000526c:	85ca                	mv	a1,s2
    8000526e:	855a                	mv	a0,s6
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	3fc080e7          	jalr	1020(ra) # 8000166c <copyout>
    80005278:	0a054963          	bltz	a0,8000532a <exec+0x312>
  p->trapframe->a1 = sp;
    8000527c:	058bb783          	ld	a5,88(s7)
    80005280:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005284:	de843783          	ld	a5,-536(s0)
    80005288:	0007c703          	lbu	a4,0(a5)
    8000528c:	cf11                	beqz	a4,800052a8 <exec+0x290>
    8000528e:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005290:	02f00693          	li	a3,47
    80005294:	a039                	j	800052a2 <exec+0x28a>
      last = s + 1;
    80005296:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    8000529a:	0785                	addi	a5,a5,1
    8000529c:	fff7c703          	lbu	a4,-1(a5)
    800052a0:	c701                	beqz	a4,800052a8 <exec+0x290>
    if (*s == '/')
    800052a2:	fed71ce3          	bne	a4,a3,8000529a <exec+0x282>
    800052a6:	bfc5                	j	80005296 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800052a8:	4641                	li	a2,16
    800052aa:	de843583          	ld	a1,-536(s0)
    800052ae:	158b8513          	addi	a0,s7,344
    800052b2:	ffffc097          	auipc	ra,0xffffc
    800052b6:	b6a080e7          	jalr	-1174(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800052ba:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800052be:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800052c2:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    800052c6:	058bb783          	ld	a5,88(s7)
    800052ca:	e6843703          	ld	a4,-408(s0)
    800052ce:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    800052d0:	058bb783          	ld	a5,88(s7)
    800052d4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052d8:	85ea                	mv	a1,s10
    800052da:	ffffd097          	auipc	ra,0xffffd
    800052de:	832080e7          	jalr	-1998(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052e2:	0004851b          	sext.w	a0,s1
    800052e6:	b3f9                	j	800050b4 <exec+0x9c>
    800052e8:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800052ec:	df843583          	ld	a1,-520(s0)
    800052f0:	855a                	mv	a0,s6
    800052f2:	ffffd097          	auipc	ra,0xffffd
    800052f6:	81a080e7          	jalr	-2022(ra) # 80001b0c <proc_freepagetable>
  if (ip)
    800052fa:	da0a93e3          	bnez	s5,800050a0 <exec+0x88>
  return -1;
    800052fe:	557d                	li	a0,-1
    80005300:	bb55                	j	800050b4 <exec+0x9c>
    80005302:	df243c23          	sd	s2,-520(s0)
    80005306:	b7dd                	j	800052ec <exec+0x2d4>
    80005308:	df243c23          	sd	s2,-520(s0)
    8000530c:	b7c5                	j	800052ec <exec+0x2d4>
    8000530e:	df243c23          	sd	s2,-520(s0)
    80005312:	bfe9                	j	800052ec <exec+0x2d4>
    80005314:	df243c23          	sd	s2,-520(s0)
    80005318:	bfd1                	j	800052ec <exec+0x2d4>
  sz = sz1;
    8000531a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000531e:	4a81                	li	s5,0
    80005320:	b7f1                	j	800052ec <exec+0x2d4>
  sz = sz1;
    80005322:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005326:	4a81                	li	s5,0
    80005328:	b7d1                	j	800052ec <exec+0x2d4>
  sz = sz1;
    8000532a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000532e:	4a81                	li	s5,0
    80005330:	bf75                	j	800052ec <exec+0x2d4>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005332:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005336:	e0843783          	ld	a5,-504(s0)
    8000533a:	0017869b          	addiw	a3,a5,1
    8000533e:	e0d43423          	sd	a3,-504(s0)
    80005342:	e0043783          	ld	a5,-512(s0)
    80005346:	0387879b          	addiw	a5,a5,56
    8000534a:	e8845703          	lhu	a4,-376(s0)
    8000534e:	e0e6dfe3          	bge	a3,a4,8000516c <exec+0x154>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005352:	2781                	sext.w	a5,a5
    80005354:	e0f43023          	sd	a5,-512(s0)
    80005358:	03800713          	li	a4,56
    8000535c:	86be                	mv	a3,a5
    8000535e:	e1840613          	addi	a2,s0,-488
    80005362:	4581                	li	a1,0
    80005364:	8556                	mv	a0,s5
    80005366:	fffff097          	auipc	ra,0xfffff
    8000536a:	a58080e7          	jalr	-1448(ra) # 80003dbe <readi>
    8000536e:	03800793          	li	a5,56
    80005372:	f6f51be3          	bne	a0,a5,800052e8 <exec+0x2d0>
    if (ph.type != ELF_PROG_LOAD)
    80005376:	e1842783          	lw	a5,-488(s0)
    8000537a:	4705                	li	a4,1
    8000537c:	fae79de3          	bne	a5,a4,80005336 <exec+0x31e>
    if (ph.memsz < ph.filesz)
    80005380:	e4043483          	ld	s1,-448(s0)
    80005384:	e3843783          	ld	a5,-456(s0)
    80005388:	f6f4ede3          	bltu	s1,a5,80005302 <exec+0x2ea>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    8000538c:	e2843783          	ld	a5,-472(s0)
    80005390:	94be                	add	s1,s1,a5
    80005392:	f6f4ebe3          	bltu	s1,a5,80005308 <exec+0x2f0>
    if (ph.vaddr % PGSIZE != 0)
    80005396:	de043703          	ld	a4,-544(s0)
    8000539a:	8ff9                	and	a5,a5,a4
    8000539c:	fbad                	bnez	a5,8000530e <exec+0x2f6>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000539e:	e1c42503          	lw	a0,-484(s0)
    800053a2:	00000097          	auipc	ra,0x0
    800053a6:	c5c080e7          	jalr	-932(ra) # 80004ffe <flags2perm>
    800053aa:	86aa                	mv	a3,a0
    800053ac:	8626                	mv	a2,s1
    800053ae:	85ca                	mv	a1,s2
    800053b0:	855a                	mv	a0,s6
    800053b2:	ffffc097          	auipc	ra,0xffffc
    800053b6:	05e080e7          	jalr	94(ra) # 80001410 <uvmalloc>
    800053ba:	dea43c23          	sd	a0,-520(s0)
    800053be:	d939                	beqz	a0,80005314 <exec+0x2fc>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053c0:	e2843c03          	ld	s8,-472(s0)
    800053c4:	e2042c83          	lw	s9,-480(s0)
    800053c8:	e3842b83          	lw	s7,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    800053cc:	f60b83e3          	beqz	s7,80005332 <exec+0x31a>
    800053d0:	89de                	mv	s3,s7
    800053d2:	4481                	li	s1,0
    800053d4:	bb9d                	j	8000514a <exec+0x132>

00000000800053d6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800053d6:	7179                	addi	sp,sp,-48
    800053d8:	f406                	sd	ra,40(sp)
    800053da:	f022                	sd	s0,32(sp)
    800053dc:	ec26                	sd	s1,24(sp)
    800053de:	e84a                	sd	s2,16(sp)
    800053e0:	1800                	addi	s0,sp,48
    800053e2:	892e                	mv	s2,a1
    800053e4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800053e6:	fdc40593          	addi	a1,s0,-36
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	a7c080e7          	jalr	-1412(ra) # 80002e66 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    800053f2:	fdc42703          	lw	a4,-36(s0)
    800053f6:	47bd                	li	a5,15
    800053f8:	02e7eb63          	bltu	a5,a4,8000542e <argfd+0x58>
    800053fc:	ffffc097          	auipc	ra,0xffffc
    80005400:	5b0080e7          	jalr	1456(ra) # 800019ac <myproc>
    80005404:	fdc42703          	lw	a4,-36(s0)
    80005408:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdba6a>
    8000540c:	078e                	slli	a5,a5,0x3
    8000540e:	953e                	add	a0,a0,a5
    80005410:	611c                	ld	a5,0(a0)
    80005412:	c385                	beqz	a5,80005432 <argfd+0x5c>
    return -1;
  if (pfd)
    80005414:	00090463          	beqz	s2,8000541c <argfd+0x46>
    *pfd = fd;
    80005418:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    8000541c:	4501                	li	a0,0
  if (pf)
    8000541e:	c091                	beqz	s1,80005422 <argfd+0x4c>
    *pf = f;
    80005420:	e09c                	sd	a5,0(s1)
}
    80005422:	70a2                	ld	ra,40(sp)
    80005424:	7402                	ld	s0,32(sp)
    80005426:	64e2                	ld	s1,24(sp)
    80005428:	6942                	ld	s2,16(sp)
    8000542a:	6145                	addi	sp,sp,48
    8000542c:	8082                	ret
    return -1;
    8000542e:	557d                	li	a0,-1
    80005430:	bfcd                	j	80005422 <argfd+0x4c>
    80005432:	557d                	li	a0,-1
    80005434:	b7fd                	j	80005422 <argfd+0x4c>

0000000080005436 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005436:	1101                	addi	sp,sp,-32
    80005438:	ec06                	sd	ra,24(sp)
    8000543a:	e822                	sd	s0,16(sp)
    8000543c:	e426                	sd	s1,8(sp)
    8000543e:	1000                	addi	s0,sp,32
    80005440:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005442:	ffffc097          	auipc	ra,0xffffc
    80005446:	56a080e7          	jalr	1386(ra) # 800019ac <myproc>
    8000544a:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++)
    8000544c:	0d050793          	addi	a5,a0,208
    80005450:	4501                	li	a0,0
    80005452:	46c1                	li	a3,16
  {
    if (p->ofile[fd] == 0)
    80005454:	6398                	ld	a4,0(a5)
    80005456:	cb19                	beqz	a4,8000546c <fdalloc+0x36>
  for (fd = 0; fd < NOFILE; fd++)
    80005458:	2505                	addiw	a0,a0,1
    8000545a:	07a1                	addi	a5,a5,8
    8000545c:	fed51ce3          	bne	a0,a3,80005454 <fdalloc+0x1e>
    {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005460:	557d                	li	a0,-1
}
    80005462:	60e2                	ld	ra,24(sp)
    80005464:	6442                	ld	s0,16(sp)
    80005466:	64a2                	ld	s1,8(sp)
    80005468:	6105                	addi	sp,sp,32
    8000546a:	8082                	ret
      p->ofile[fd] = f;
    8000546c:	01a50793          	addi	a5,a0,26
    80005470:	078e                	slli	a5,a5,0x3
    80005472:	963e                	add	a2,a2,a5
    80005474:	e204                	sd	s1,0(a2)
      return fd;
    80005476:	b7f5                	j	80005462 <fdalloc+0x2c>

0000000080005478 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80005478:	715d                	addi	sp,sp,-80
    8000547a:	e486                	sd	ra,72(sp)
    8000547c:	e0a2                	sd	s0,64(sp)
    8000547e:	fc26                	sd	s1,56(sp)
    80005480:	f84a                	sd	s2,48(sp)
    80005482:	f44e                	sd	s3,40(sp)
    80005484:	f052                	sd	s4,32(sp)
    80005486:	ec56                	sd	s5,24(sp)
    80005488:	e85a                	sd	s6,16(sp)
    8000548a:	0880                	addi	s0,sp,80
    8000548c:	8b2e                	mv	s6,a1
    8000548e:	89b2                	mv	s3,a2
    80005490:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80005492:	fb040593          	addi	a1,s0,-80
    80005496:	fffff097          	auipc	ra,0xfffff
    8000549a:	e3e080e7          	jalr	-450(ra) # 800042d4 <nameiparent>
    8000549e:	84aa                	mv	s1,a0
    800054a0:	14050f63          	beqz	a0,800055fe <create+0x186>
    return 0;

  ilock(dp);
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	666080e7          	jalr	1638(ra) # 80003b0a <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0)
    800054ac:	4601                	li	a2,0
    800054ae:	fb040593          	addi	a1,s0,-80
    800054b2:	8526                	mv	a0,s1
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	b3a080e7          	jalr	-1222(ra) # 80003fee <dirlookup>
    800054bc:	8aaa                	mv	s5,a0
    800054be:	c931                	beqz	a0,80005512 <create+0x9a>
  {
    iunlockput(dp);
    800054c0:	8526                	mv	a0,s1
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	8aa080e7          	jalr	-1878(ra) # 80003d6c <iunlockput>
    ilock(ip);
    800054ca:	8556                	mv	a0,s5
    800054cc:	ffffe097          	auipc	ra,0xffffe
    800054d0:	63e080e7          	jalr	1598(ra) # 80003b0a <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800054d4:	000b059b          	sext.w	a1,s6
    800054d8:	4789                	li	a5,2
    800054da:	02f59563          	bne	a1,a5,80005504 <create+0x8c>
    800054de:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdba94>
    800054e2:	37f9                	addiw	a5,a5,-2
    800054e4:	17c2                	slli	a5,a5,0x30
    800054e6:	93c1                	srli	a5,a5,0x30
    800054e8:	4705                	li	a4,1
    800054ea:	00f76d63          	bltu	a4,a5,80005504 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800054ee:	8556                	mv	a0,s5
    800054f0:	60a6                	ld	ra,72(sp)
    800054f2:	6406                	ld	s0,64(sp)
    800054f4:	74e2                	ld	s1,56(sp)
    800054f6:	7942                	ld	s2,48(sp)
    800054f8:	79a2                	ld	s3,40(sp)
    800054fa:	7a02                	ld	s4,32(sp)
    800054fc:	6ae2                	ld	s5,24(sp)
    800054fe:	6b42                	ld	s6,16(sp)
    80005500:	6161                	addi	sp,sp,80
    80005502:	8082                	ret
    iunlockput(ip);
    80005504:	8556                	mv	a0,s5
    80005506:	fffff097          	auipc	ra,0xfffff
    8000550a:	866080e7          	jalr	-1946(ra) # 80003d6c <iunlockput>
    return 0;
    8000550e:	4a81                	li	s5,0
    80005510:	bff9                	j	800054ee <create+0x76>
  if ((ip = ialloc(dp->dev, type)) == 0)
    80005512:	85da                	mv	a1,s6
    80005514:	4088                	lw	a0,0(s1)
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	456080e7          	jalr	1110(ra) # 8000396c <ialloc>
    8000551e:	8a2a                	mv	s4,a0
    80005520:	c539                	beqz	a0,8000556e <create+0xf6>
  ilock(ip);
    80005522:	ffffe097          	auipc	ra,0xffffe
    80005526:	5e8080e7          	jalr	1512(ra) # 80003b0a <ilock>
  ip->major = major;
    8000552a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000552e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005532:	4905                	li	s2,1
    80005534:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005538:	8552                	mv	a0,s4
    8000553a:	ffffe097          	auipc	ra,0xffffe
    8000553e:	504080e7          	jalr	1284(ra) # 80003a3e <iupdate>
  if (type == T_DIR)
    80005542:	000b059b          	sext.w	a1,s6
    80005546:	03258b63          	beq	a1,s2,8000557c <create+0x104>
  if (dirlink(dp, name, ip->inum) < 0)
    8000554a:	004a2603          	lw	a2,4(s4)
    8000554e:	fb040593          	addi	a1,s0,-80
    80005552:	8526                	mv	a0,s1
    80005554:	fffff097          	auipc	ra,0xfffff
    80005558:	cb0080e7          	jalr	-848(ra) # 80004204 <dirlink>
    8000555c:	06054f63          	bltz	a0,800055da <create+0x162>
  iunlockput(dp);
    80005560:	8526                	mv	a0,s1
    80005562:	fffff097          	auipc	ra,0xfffff
    80005566:	80a080e7          	jalr	-2038(ra) # 80003d6c <iunlockput>
  return ip;
    8000556a:	8ad2                	mv	s5,s4
    8000556c:	b749                	j	800054ee <create+0x76>
    iunlockput(dp);
    8000556e:	8526                	mv	a0,s1
    80005570:	ffffe097          	auipc	ra,0xffffe
    80005574:	7fc080e7          	jalr	2044(ra) # 80003d6c <iunlockput>
    return 0;
    80005578:	8ad2                	mv	s5,s4
    8000557a:	bf95                	j	800054ee <create+0x76>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000557c:	004a2603          	lw	a2,4(s4)
    80005580:	00003597          	auipc	a1,0x3
    80005584:	18858593          	addi	a1,a1,392 # 80008708 <syscalls+0x2b8>
    80005588:	8552                	mv	a0,s4
    8000558a:	fffff097          	auipc	ra,0xfffff
    8000558e:	c7a080e7          	jalr	-902(ra) # 80004204 <dirlink>
    80005592:	04054463          	bltz	a0,800055da <create+0x162>
    80005596:	40d0                	lw	a2,4(s1)
    80005598:	00003597          	auipc	a1,0x3
    8000559c:	17858593          	addi	a1,a1,376 # 80008710 <syscalls+0x2c0>
    800055a0:	8552                	mv	a0,s4
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	c62080e7          	jalr	-926(ra) # 80004204 <dirlink>
    800055aa:	02054863          	bltz	a0,800055da <create+0x162>
  if (dirlink(dp, name, ip->inum) < 0)
    800055ae:	004a2603          	lw	a2,4(s4)
    800055b2:	fb040593          	addi	a1,s0,-80
    800055b6:	8526                	mv	a0,s1
    800055b8:	fffff097          	auipc	ra,0xfffff
    800055bc:	c4c080e7          	jalr	-948(ra) # 80004204 <dirlink>
    800055c0:	00054d63          	bltz	a0,800055da <create+0x162>
    dp->nlink++; // for ".."
    800055c4:	04a4d783          	lhu	a5,74(s1)
    800055c8:	2785                	addiw	a5,a5,1
    800055ca:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055ce:	8526                	mv	a0,s1
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	46e080e7          	jalr	1134(ra) # 80003a3e <iupdate>
    800055d8:	b761                	j	80005560 <create+0xe8>
  ip->nlink = 0;
    800055da:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800055de:	8552                	mv	a0,s4
    800055e0:	ffffe097          	auipc	ra,0xffffe
    800055e4:	45e080e7          	jalr	1118(ra) # 80003a3e <iupdate>
  iunlockput(ip);
    800055e8:	8552                	mv	a0,s4
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	782080e7          	jalr	1922(ra) # 80003d6c <iunlockput>
  iunlockput(dp);
    800055f2:	8526                	mv	a0,s1
    800055f4:	ffffe097          	auipc	ra,0xffffe
    800055f8:	778080e7          	jalr	1912(ra) # 80003d6c <iunlockput>
  return 0;
    800055fc:	bdcd                	j	800054ee <create+0x76>
    return 0;
    800055fe:	8aaa                	mv	s5,a0
    80005600:	b5fd                	j	800054ee <create+0x76>

0000000080005602 <sys_dup>:
{
    80005602:	7179                	addi	sp,sp,-48
    80005604:	f406                	sd	ra,40(sp)
    80005606:	f022                	sd	s0,32(sp)
    80005608:	ec26                	sd	s1,24(sp)
    8000560a:	e84a                	sd	s2,16(sp)
    8000560c:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    8000560e:	fd840613          	addi	a2,s0,-40
    80005612:	4581                	li	a1,0
    80005614:	4501                	li	a0,0
    80005616:	00000097          	auipc	ra,0x0
    8000561a:	dc0080e7          	jalr	-576(ra) # 800053d6 <argfd>
    return -1;
    8000561e:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80005620:	02054363          	bltz	a0,80005646 <sys_dup+0x44>
  if ((fd = fdalloc(f)) < 0)
    80005624:	fd843903          	ld	s2,-40(s0)
    80005628:	854a                	mv	a0,s2
    8000562a:	00000097          	auipc	ra,0x0
    8000562e:	e0c080e7          	jalr	-500(ra) # 80005436 <fdalloc>
    80005632:	84aa                	mv	s1,a0
    return -1;
    80005634:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80005636:	00054863          	bltz	a0,80005646 <sys_dup+0x44>
  filedup(f);
    8000563a:	854a                	mv	a0,s2
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	310080e7          	jalr	784(ra) # 8000494c <filedup>
  return fd;
    80005644:	87a6                	mv	a5,s1
}
    80005646:	853e                	mv	a0,a5
    80005648:	70a2                	ld	ra,40(sp)
    8000564a:	7402                	ld	s0,32(sp)
    8000564c:	64e2                	ld	s1,24(sp)
    8000564e:	6942                	ld	s2,16(sp)
    80005650:	6145                	addi	sp,sp,48
    80005652:	8082                	ret

0000000080005654 <sys_read>:
{
    80005654:	7179                	addi	sp,sp,-48
    80005656:	f406                	sd	ra,40(sp)
    80005658:	f022                	sd	s0,32(sp)
    8000565a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000565c:	fd840593          	addi	a1,s0,-40
    80005660:	4505                	li	a0,1
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	824080e7          	jalr	-2012(ra) # 80002e86 <argaddr>
  argint(2, &n);
    8000566a:	fe440593          	addi	a1,s0,-28
    8000566e:	4509                	li	a0,2
    80005670:	ffffd097          	auipc	ra,0xffffd
    80005674:	7f6080e7          	jalr	2038(ra) # 80002e66 <argint>
  if (argfd(0, 0, &f) < 0)
    80005678:	fe840613          	addi	a2,s0,-24
    8000567c:	4581                	li	a1,0
    8000567e:	4501                	li	a0,0
    80005680:	00000097          	auipc	ra,0x0
    80005684:	d56080e7          	jalr	-682(ra) # 800053d6 <argfd>
    80005688:	87aa                	mv	a5,a0
    return -1;
    8000568a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000568c:	0007cc63          	bltz	a5,800056a4 <sys_read+0x50>
  return fileread(f, p, n);
    80005690:	fe442603          	lw	a2,-28(s0)
    80005694:	fd843583          	ld	a1,-40(s0)
    80005698:	fe843503          	ld	a0,-24(s0)
    8000569c:	fffff097          	auipc	ra,0xfffff
    800056a0:	43c080e7          	jalr	1084(ra) # 80004ad8 <fileread>
}
    800056a4:	70a2                	ld	ra,40(sp)
    800056a6:	7402                	ld	s0,32(sp)
    800056a8:	6145                	addi	sp,sp,48
    800056aa:	8082                	ret

00000000800056ac <sys_write>:
{
    800056ac:	7179                	addi	sp,sp,-48
    800056ae:	f406                	sd	ra,40(sp)
    800056b0:	f022                	sd	s0,32(sp)
    800056b2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056b4:	fd840593          	addi	a1,s0,-40
    800056b8:	4505                	li	a0,1
    800056ba:	ffffd097          	auipc	ra,0xffffd
    800056be:	7cc080e7          	jalr	1996(ra) # 80002e86 <argaddr>
  argint(2, &n);
    800056c2:	fe440593          	addi	a1,s0,-28
    800056c6:	4509                	li	a0,2
    800056c8:	ffffd097          	auipc	ra,0xffffd
    800056cc:	79e080e7          	jalr	1950(ra) # 80002e66 <argint>
  if (argfd(0, 0, &f) < 0)
    800056d0:	fe840613          	addi	a2,s0,-24
    800056d4:	4581                	li	a1,0
    800056d6:	4501                	li	a0,0
    800056d8:	00000097          	auipc	ra,0x0
    800056dc:	cfe080e7          	jalr	-770(ra) # 800053d6 <argfd>
    800056e0:	87aa                	mv	a5,a0
    return -1;
    800056e2:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800056e4:	0007cc63          	bltz	a5,800056fc <sys_write+0x50>
  return filewrite(f, p, n);
    800056e8:	fe442603          	lw	a2,-28(s0)
    800056ec:	fd843583          	ld	a1,-40(s0)
    800056f0:	fe843503          	ld	a0,-24(s0)
    800056f4:	fffff097          	auipc	ra,0xfffff
    800056f8:	4a6080e7          	jalr	1190(ra) # 80004b9a <filewrite>
}
    800056fc:	70a2                	ld	ra,40(sp)
    800056fe:	7402                	ld	s0,32(sp)
    80005700:	6145                	addi	sp,sp,48
    80005702:	8082                	ret

0000000080005704 <sys_close>:
{
    80005704:	1101                	addi	sp,sp,-32
    80005706:	ec06                	sd	ra,24(sp)
    80005708:	e822                	sd	s0,16(sp)
    8000570a:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    8000570c:	fe040613          	addi	a2,s0,-32
    80005710:	fec40593          	addi	a1,s0,-20
    80005714:	4501                	li	a0,0
    80005716:	00000097          	auipc	ra,0x0
    8000571a:	cc0080e7          	jalr	-832(ra) # 800053d6 <argfd>
    return -1;
    8000571e:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005720:	02054463          	bltz	a0,80005748 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005724:	ffffc097          	auipc	ra,0xffffc
    80005728:	288080e7          	jalr	648(ra) # 800019ac <myproc>
    8000572c:	fec42783          	lw	a5,-20(s0)
    80005730:	07e9                	addi	a5,a5,26
    80005732:	078e                	slli	a5,a5,0x3
    80005734:	953e                	add	a0,a0,a5
    80005736:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000573a:	fe043503          	ld	a0,-32(s0)
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	260080e7          	jalr	608(ra) # 8000499e <fileclose>
  return 0;
    80005746:	4781                	li	a5,0
}
    80005748:	853e                	mv	a0,a5
    8000574a:	60e2                	ld	ra,24(sp)
    8000574c:	6442                	ld	s0,16(sp)
    8000574e:	6105                	addi	sp,sp,32
    80005750:	8082                	ret

0000000080005752 <sys_fstat>:
{
    80005752:	1101                	addi	sp,sp,-32
    80005754:	ec06                	sd	ra,24(sp)
    80005756:	e822                	sd	s0,16(sp)
    80005758:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000575a:	fe040593          	addi	a1,s0,-32
    8000575e:	4505                	li	a0,1
    80005760:	ffffd097          	auipc	ra,0xffffd
    80005764:	726080e7          	jalr	1830(ra) # 80002e86 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005768:	fe840613          	addi	a2,s0,-24
    8000576c:	4581                	li	a1,0
    8000576e:	4501                	li	a0,0
    80005770:	00000097          	auipc	ra,0x0
    80005774:	c66080e7          	jalr	-922(ra) # 800053d6 <argfd>
    80005778:	87aa                	mv	a5,a0
    return -1;
    8000577a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000577c:	0007ca63          	bltz	a5,80005790 <sys_fstat+0x3e>
  return filestat(f, st);
    80005780:	fe043583          	ld	a1,-32(s0)
    80005784:	fe843503          	ld	a0,-24(s0)
    80005788:	fffff097          	auipc	ra,0xfffff
    8000578c:	2de080e7          	jalr	734(ra) # 80004a66 <filestat>
}
    80005790:	60e2                	ld	ra,24(sp)
    80005792:	6442                	ld	s0,16(sp)
    80005794:	6105                	addi	sp,sp,32
    80005796:	8082                	ret

0000000080005798 <sys_link>:
{
    80005798:	7169                	addi	sp,sp,-304
    8000579a:	f606                	sd	ra,296(sp)
    8000579c:	f222                	sd	s0,288(sp)
    8000579e:	ee26                	sd	s1,280(sp)
    800057a0:	ea4a                	sd	s2,272(sp)
    800057a2:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057a4:	08000613          	li	a2,128
    800057a8:	ed040593          	addi	a1,s0,-304
    800057ac:	4501                	li	a0,0
    800057ae:	ffffd097          	auipc	ra,0xffffd
    800057b2:	6f8080e7          	jalr	1784(ra) # 80002ea6 <argstr>
    return -1;
    800057b6:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057b8:	10054e63          	bltz	a0,800058d4 <sys_link+0x13c>
    800057bc:	08000613          	li	a2,128
    800057c0:	f5040593          	addi	a1,s0,-176
    800057c4:	4505                	li	a0,1
    800057c6:	ffffd097          	auipc	ra,0xffffd
    800057ca:	6e0080e7          	jalr	1760(ra) # 80002ea6 <argstr>
    return -1;
    800057ce:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057d0:	10054263          	bltz	a0,800058d4 <sys_link+0x13c>
  begin_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	d02080e7          	jalr	-766(ra) # 800044d6 <begin_op>
  if ((ip = namei(old)) == 0)
    800057dc:	ed040513          	addi	a0,s0,-304
    800057e0:	fffff097          	auipc	ra,0xfffff
    800057e4:	ad6080e7          	jalr	-1322(ra) # 800042b6 <namei>
    800057e8:	84aa                	mv	s1,a0
    800057ea:	c551                	beqz	a0,80005876 <sys_link+0xde>
  ilock(ip);
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	31e080e7          	jalr	798(ra) # 80003b0a <ilock>
  if (ip->type == T_DIR)
    800057f4:	04449703          	lh	a4,68(s1)
    800057f8:	4785                	li	a5,1
    800057fa:	08f70463          	beq	a4,a5,80005882 <sys_link+0xea>
  ip->nlink++;
    800057fe:	04a4d783          	lhu	a5,74(s1)
    80005802:	2785                	addiw	a5,a5,1
    80005804:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005808:	8526                	mv	a0,s1
    8000580a:	ffffe097          	auipc	ra,0xffffe
    8000580e:	234080e7          	jalr	564(ra) # 80003a3e <iupdate>
  iunlock(ip);
    80005812:	8526                	mv	a0,s1
    80005814:	ffffe097          	auipc	ra,0xffffe
    80005818:	3b8080e7          	jalr	952(ra) # 80003bcc <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    8000581c:	fd040593          	addi	a1,s0,-48
    80005820:	f5040513          	addi	a0,s0,-176
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	ab0080e7          	jalr	-1360(ra) # 800042d4 <nameiparent>
    8000582c:	892a                	mv	s2,a0
    8000582e:	c935                	beqz	a0,800058a2 <sys_link+0x10a>
  ilock(dp);
    80005830:	ffffe097          	auipc	ra,0xffffe
    80005834:	2da080e7          	jalr	730(ra) # 80003b0a <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0)
    80005838:	00092703          	lw	a4,0(s2)
    8000583c:	409c                	lw	a5,0(s1)
    8000583e:	04f71d63          	bne	a4,a5,80005898 <sys_link+0x100>
    80005842:	40d0                	lw	a2,4(s1)
    80005844:	fd040593          	addi	a1,s0,-48
    80005848:	854a                	mv	a0,s2
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	9ba080e7          	jalr	-1606(ra) # 80004204 <dirlink>
    80005852:	04054363          	bltz	a0,80005898 <sys_link+0x100>
  iunlockput(dp);
    80005856:	854a                	mv	a0,s2
    80005858:	ffffe097          	auipc	ra,0xffffe
    8000585c:	514080e7          	jalr	1300(ra) # 80003d6c <iunlockput>
  iput(ip);
    80005860:	8526                	mv	a0,s1
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	462080e7          	jalr	1122(ra) # 80003cc4 <iput>
  end_op();
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	cea080e7          	jalr	-790(ra) # 80004554 <end_op>
  return 0;
    80005872:	4781                	li	a5,0
    80005874:	a085                	j	800058d4 <sys_link+0x13c>
    end_op();
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	cde080e7          	jalr	-802(ra) # 80004554 <end_op>
    return -1;
    8000587e:	57fd                	li	a5,-1
    80005880:	a891                	j	800058d4 <sys_link+0x13c>
    iunlockput(ip);
    80005882:	8526                	mv	a0,s1
    80005884:	ffffe097          	auipc	ra,0xffffe
    80005888:	4e8080e7          	jalr	1256(ra) # 80003d6c <iunlockput>
    end_op();
    8000588c:	fffff097          	auipc	ra,0xfffff
    80005890:	cc8080e7          	jalr	-824(ra) # 80004554 <end_op>
    return -1;
    80005894:	57fd                	li	a5,-1
    80005896:	a83d                	j	800058d4 <sys_link+0x13c>
    iunlockput(dp);
    80005898:	854a                	mv	a0,s2
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	4d2080e7          	jalr	1234(ra) # 80003d6c <iunlockput>
  ilock(ip);
    800058a2:	8526                	mv	a0,s1
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	266080e7          	jalr	614(ra) # 80003b0a <ilock>
  ip->nlink--;
    800058ac:	04a4d783          	lhu	a5,74(s1)
    800058b0:	37fd                	addiw	a5,a5,-1
    800058b2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058b6:	8526                	mv	a0,s1
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	186080e7          	jalr	390(ra) # 80003a3e <iupdate>
  iunlockput(ip);
    800058c0:	8526                	mv	a0,s1
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	4aa080e7          	jalr	1194(ra) # 80003d6c <iunlockput>
  end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	c8a080e7          	jalr	-886(ra) # 80004554 <end_op>
  return -1;
    800058d2:	57fd                	li	a5,-1
}
    800058d4:	853e                	mv	a0,a5
    800058d6:	70b2                	ld	ra,296(sp)
    800058d8:	7412                	ld	s0,288(sp)
    800058da:	64f2                	ld	s1,280(sp)
    800058dc:	6952                	ld	s2,272(sp)
    800058de:	6155                	addi	sp,sp,304
    800058e0:	8082                	ret

00000000800058e2 <sys_unlink>:
{
    800058e2:	7151                	addi	sp,sp,-240
    800058e4:	f586                	sd	ra,232(sp)
    800058e6:	f1a2                	sd	s0,224(sp)
    800058e8:	eda6                	sd	s1,216(sp)
    800058ea:	e9ca                	sd	s2,208(sp)
    800058ec:	e5ce                	sd	s3,200(sp)
    800058ee:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800058f0:	08000613          	li	a2,128
    800058f4:	f3040593          	addi	a1,s0,-208
    800058f8:	4501                	li	a0,0
    800058fa:	ffffd097          	auipc	ra,0xffffd
    800058fe:	5ac080e7          	jalr	1452(ra) # 80002ea6 <argstr>
    80005902:	18054163          	bltz	a0,80005a84 <sys_unlink+0x1a2>
  begin_op();
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	bd0080e7          	jalr	-1072(ra) # 800044d6 <begin_op>
  if ((dp = nameiparent(path, name)) == 0)
    8000590e:	fb040593          	addi	a1,s0,-80
    80005912:	f3040513          	addi	a0,s0,-208
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	9be080e7          	jalr	-1602(ra) # 800042d4 <nameiparent>
    8000591e:	84aa                	mv	s1,a0
    80005920:	c979                	beqz	a0,800059f6 <sys_unlink+0x114>
  ilock(dp);
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	1e8080e7          	jalr	488(ra) # 80003b0a <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000592a:	00003597          	auipc	a1,0x3
    8000592e:	dde58593          	addi	a1,a1,-546 # 80008708 <syscalls+0x2b8>
    80005932:	fb040513          	addi	a0,s0,-80
    80005936:	ffffe097          	auipc	ra,0xffffe
    8000593a:	69e080e7          	jalr	1694(ra) # 80003fd4 <namecmp>
    8000593e:	14050a63          	beqz	a0,80005a92 <sys_unlink+0x1b0>
    80005942:	00003597          	auipc	a1,0x3
    80005946:	dce58593          	addi	a1,a1,-562 # 80008710 <syscalls+0x2c0>
    8000594a:	fb040513          	addi	a0,s0,-80
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	686080e7          	jalr	1670(ra) # 80003fd4 <namecmp>
    80005956:	12050e63          	beqz	a0,80005a92 <sys_unlink+0x1b0>
  if ((ip = dirlookup(dp, name, &off)) == 0)
    8000595a:	f2c40613          	addi	a2,s0,-212
    8000595e:	fb040593          	addi	a1,s0,-80
    80005962:	8526                	mv	a0,s1
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	68a080e7          	jalr	1674(ra) # 80003fee <dirlookup>
    8000596c:	892a                	mv	s2,a0
    8000596e:	12050263          	beqz	a0,80005a92 <sys_unlink+0x1b0>
  ilock(ip);
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	198080e7          	jalr	408(ra) # 80003b0a <ilock>
  if (ip->nlink < 1)
    8000597a:	04a91783          	lh	a5,74(s2)
    8000597e:	08f05263          	blez	a5,80005a02 <sys_unlink+0x120>
  if (ip->type == T_DIR && !isdirempty(ip))
    80005982:	04491703          	lh	a4,68(s2)
    80005986:	4785                	li	a5,1
    80005988:	08f70563          	beq	a4,a5,80005a12 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000598c:	4641                	li	a2,16
    8000598e:	4581                	li	a1,0
    80005990:	fc040513          	addi	a0,s0,-64
    80005994:	ffffb097          	auipc	ra,0xffffb
    80005998:	33e080e7          	jalr	830(ra) # 80000cd2 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000599c:	4741                	li	a4,16
    8000599e:	f2c42683          	lw	a3,-212(s0)
    800059a2:	fc040613          	addi	a2,s0,-64
    800059a6:	4581                	li	a1,0
    800059a8:	8526                	mv	a0,s1
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	50c080e7          	jalr	1292(ra) # 80003eb6 <writei>
    800059b2:	47c1                	li	a5,16
    800059b4:	0af51563          	bne	a0,a5,80005a5e <sys_unlink+0x17c>
  if (ip->type == T_DIR)
    800059b8:	04491703          	lh	a4,68(s2)
    800059bc:	4785                	li	a5,1
    800059be:	0af70863          	beq	a4,a5,80005a6e <sys_unlink+0x18c>
  iunlockput(dp);
    800059c2:	8526                	mv	a0,s1
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	3a8080e7          	jalr	936(ra) # 80003d6c <iunlockput>
  ip->nlink--;
    800059cc:	04a95783          	lhu	a5,74(s2)
    800059d0:	37fd                	addiw	a5,a5,-1
    800059d2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800059d6:	854a                	mv	a0,s2
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	066080e7          	jalr	102(ra) # 80003a3e <iupdate>
  iunlockput(ip);
    800059e0:	854a                	mv	a0,s2
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	38a080e7          	jalr	906(ra) # 80003d6c <iunlockput>
  end_op();
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	b6a080e7          	jalr	-1174(ra) # 80004554 <end_op>
  return 0;
    800059f2:	4501                	li	a0,0
    800059f4:	a84d                	j	80005aa6 <sys_unlink+0x1c4>
    end_op();
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	b5e080e7          	jalr	-1186(ra) # 80004554 <end_op>
    return -1;
    800059fe:	557d                	li	a0,-1
    80005a00:	a05d                	j	80005aa6 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a02:	00003517          	auipc	a0,0x3
    80005a06:	d1650513          	addi	a0,a0,-746 # 80008718 <syscalls+0x2c8>
    80005a0a:	ffffb097          	auipc	ra,0xffffb
    80005a0e:	b36080e7          	jalr	-1226(ra) # 80000540 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005a12:	04c92703          	lw	a4,76(s2)
    80005a16:	02000793          	li	a5,32
    80005a1a:	f6e7f9e3          	bgeu	a5,a4,8000598c <sys_unlink+0xaa>
    80005a1e:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a22:	4741                	li	a4,16
    80005a24:	86ce                	mv	a3,s3
    80005a26:	f1840613          	addi	a2,s0,-232
    80005a2a:	4581                	li	a1,0
    80005a2c:	854a                	mv	a0,s2
    80005a2e:	ffffe097          	auipc	ra,0xffffe
    80005a32:	390080e7          	jalr	912(ra) # 80003dbe <readi>
    80005a36:	47c1                	li	a5,16
    80005a38:	00f51b63          	bne	a0,a5,80005a4e <sys_unlink+0x16c>
    if (de.inum != 0)
    80005a3c:	f1845783          	lhu	a5,-232(s0)
    80005a40:	e7a1                	bnez	a5,80005a88 <sys_unlink+0x1a6>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005a42:	29c1                	addiw	s3,s3,16
    80005a44:	04c92783          	lw	a5,76(s2)
    80005a48:	fcf9ede3          	bltu	s3,a5,80005a22 <sys_unlink+0x140>
    80005a4c:	b781                	j	8000598c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a4e:	00003517          	auipc	a0,0x3
    80005a52:	ce250513          	addi	a0,a0,-798 # 80008730 <syscalls+0x2e0>
    80005a56:	ffffb097          	auipc	ra,0xffffb
    80005a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005a5e:	00003517          	auipc	a0,0x3
    80005a62:	cea50513          	addi	a0,a0,-790 # 80008748 <syscalls+0x2f8>
    80005a66:	ffffb097          	auipc	ra,0xffffb
    80005a6a:	ada080e7          	jalr	-1318(ra) # 80000540 <panic>
    dp->nlink--;
    80005a6e:	04a4d783          	lhu	a5,74(s1)
    80005a72:	37fd                	addiw	a5,a5,-1
    80005a74:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a78:	8526                	mv	a0,s1
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	fc4080e7          	jalr	-60(ra) # 80003a3e <iupdate>
    80005a82:	b781                	j	800059c2 <sys_unlink+0xe0>
    return -1;
    80005a84:	557d                	li	a0,-1
    80005a86:	a005                	j	80005aa6 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a88:	854a                	mv	a0,s2
    80005a8a:	ffffe097          	auipc	ra,0xffffe
    80005a8e:	2e2080e7          	jalr	738(ra) # 80003d6c <iunlockput>
  iunlockput(dp);
    80005a92:	8526                	mv	a0,s1
    80005a94:	ffffe097          	auipc	ra,0xffffe
    80005a98:	2d8080e7          	jalr	728(ra) # 80003d6c <iunlockput>
  end_op();
    80005a9c:	fffff097          	auipc	ra,0xfffff
    80005aa0:	ab8080e7          	jalr	-1352(ra) # 80004554 <end_op>
  return -1;
    80005aa4:	557d                	li	a0,-1
}
    80005aa6:	70ae                	ld	ra,232(sp)
    80005aa8:	740e                	ld	s0,224(sp)
    80005aaa:	64ee                	ld	s1,216(sp)
    80005aac:	694e                	ld	s2,208(sp)
    80005aae:	69ae                	ld	s3,200(sp)
    80005ab0:	616d                	addi	sp,sp,240
    80005ab2:	8082                	ret

0000000080005ab4 <sys_open>:

uint64
sys_open(void)
{
    80005ab4:	7131                	addi	sp,sp,-192
    80005ab6:	fd06                	sd	ra,184(sp)
    80005ab8:	f922                	sd	s0,176(sp)
    80005aba:	f526                	sd	s1,168(sp)
    80005abc:	f14a                	sd	s2,160(sp)
    80005abe:	ed4e                	sd	s3,152(sp)
    80005ac0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005ac2:	f4c40593          	addi	a1,s0,-180
    80005ac6:	4505                	li	a0,1
    80005ac8:	ffffd097          	auipc	ra,0xffffd
    80005acc:	39e080e7          	jalr	926(ra) # 80002e66 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005ad0:	08000613          	li	a2,128
    80005ad4:	f5040593          	addi	a1,s0,-176
    80005ad8:	4501                	li	a0,0
    80005ada:	ffffd097          	auipc	ra,0xffffd
    80005ade:	3cc080e7          	jalr	972(ra) # 80002ea6 <argstr>
    80005ae2:	87aa                	mv	a5,a0
    return -1;
    80005ae4:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005ae6:	0a07c963          	bltz	a5,80005b98 <sys_open+0xe4>

  begin_op();
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	9ec080e7          	jalr	-1556(ra) # 800044d6 <begin_op>

  if (omode & O_CREATE)
    80005af2:	f4c42783          	lw	a5,-180(s0)
    80005af6:	2007f793          	andi	a5,a5,512
    80005afa:	cfc5                	beqz	a5,80005bb2 <sys_open+0xfe>
  {
    ip = create(path, T_FILE, 0, 0);
    80005afc:	4681                	li	a3,0
    80005afe:	4601                	li	a2,0
    80005b00:	4589                	li	a1,2
    80005b02:	f5040513          	addi	a0,s0,-176
    80005b06:	00000097          	auipc	ra,0x0
    80005b0a:	972080e7          	jalr	-1678(ra) # 80005478 <create>
    80005b0e:	84aa                	mv	s1,a0
    if (ip == 0)
    80005b10:	c959                	beqz	a0,80005ba6 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV))
    80005b12:	04449703          	lh	a4,68(s1)
    80005b16:	478d                	li	a5,3
    80005b18:	00f71763          	bne	a4,a5,80005b26 <sys_open+0x72>
    80005b1c:	0464d703          	lhu	a4,70(s1)
    80005b20:	47a5                	li	a5,9
    80005b22:	0ce7ed63          	bltu	a5,a4,80005bfc <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0)
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	dbc080e7          	jalr	-580(ra) # 800048e2 <filealloc>
    80005b2e:	89aa                	mv	s3,a0
    80005b30:	10050363          	beqz	a0,80005c36 <sys_open+0x182>
    80005b34:	00000097          	auipc	ra,0x0
    80005b38:	902080e7          	jalr	-1790(ra) # 80005436 <fdalloc>
    80005b3c:	892a                	mv	s2,a0
    80005b3e:	0e054763          	bltz	a0,80005c2c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE)
    80005b42:	04449703          	lh	a4,68(s1)
    80005b46:	478d                	li	a5,3
    80005b48:	0cf70563          	beq	a4,a5,80005c12 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  }
  else
  {
    f->type = FD_INODE;
    80005b4c:	4789                	li	a5,2
    80005b4e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b52:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b56:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b5a:	f4c42783          	lw	a5,-180(s0)
    80005b5e:	0017c713          	xori	a4,a5,1
    80005b62:	8b05                	andi	a4,a4,1
    80005b64:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b68:	0037f713          	andi	a4,a5,3
    80005b6c:	00e03733          	snez	a4,a4
    80005b70:	00e984a3          	sb	a4,9(s3)

  if ((omode & O_TRUNC) && ip->type == T_FILE)
    80005b74:	4007f793          	andi	a5,a5,1024
    80005b78:	c791                	beqz	a5,80005b84 <sys_open+0xd0>
    80005b7a:	04449703          	lh	a4,68(s1)
    80005b7e:	4789                	li	a5,2
    80005b80:	0af70063          	beq	a4,a5,80005c20 <sys_open+0x16c>
  {
    itrunc(ip);
  }

  iunlock(ip);
    80005b84:	8526                	mv	a0,s1
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	046080e7          	jalr	70(ra) # 80003bcc <iunlock>
  end_op();
    80005b8e:	fffff097          	auipc	ra,0xfffff
    80005b92:	9c6080e7          	jalr	-1594(ra) # 80004554 <end_op>

  return fd;
    80005b96:	854a                	mv	a0,s2
}
    80005b98:	70ea                	ld	ra,184(sp)
    80005b9a:	744a                	ld	s0,176(sp)
    80005b9c:	74aa                	ld	s1,168(sp)
    80005b9e:	790a                	ld	s2,160(sp)
    80005ba0:	69ea                	ld	s3,152(sp)
    80005ba2:	6129                	addi	sp,sp,192
    80005ba4:	8082                	ret
      end_op();
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	9ae080e7          	jalr	-1618(ra) # 80004554 <end_op>
      return -1;
    80005bae:	557d                	li	a0,-1
    80005bb0:	b7e5                	j	80005b98 <sys_open+0xe4>
    if ((ip = namei(path)) == 0)
    80005bb2:	f5040513          	addi	a0,s0,-176
    80005bb6:	ffffe097          	auipc	ra,0xffffe
    80005bba:	700080e7          	jalr	1792(ra) # 800042b6 <namei>
    80005bbe:	84aa                	mv	s1,a0
    80005bc0:	c905                	beqz	a0,80005bf0 <sys_open+0x13c>
    ilock(ip);
    80005bc2:	ffffe097          	auipc	ra,0xffffe
    80005bc6:	f48080e7          	jalr	-184(ra) # 80003b0a <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY)
    80005bca:	04449703          	lh	a4,68(s1)
    80005bce:	4785                	li	a5,1
    80005bd0:	f4f711e3          	bne	a4,a5,80005b12 <sys_open+0x5e>
    80005bd4:	f4c42783          	lw	a5,-180(s0)
    80005bd8:	d7b9                	beqz	a5,80005b26 <sys_open+0x72>
      iunlockput(ip);
    80005bda:	8526                	mv	a0,s1
    80005bdc:	ffffe097          	auipc	ra,0xffffe
    80005be0:	190080e7          	jalr	400(ra) # 80003d6c <iunlockput>
      end_op();
    80005be4:	fffff097          	auipc	ra,0xfffff
    80005be8:	970080e7          	jalr	-1680(ra) # 80004554 <end_op>
      return -1;
    80005bec:	557d                	li	a0,-1
    80005bee:	b76d                	j	80005b98 <sys_open+0xe4>
      end_op();
    80005bf0:	fffff097          	auipc	ra,0xfffff
    80005bf4:	964080e7          	jalr	-1692(ra) # 80004554 <end_op>
      return -1;
    80005bf8:	557d                	li	a0,-1
    80005bfa:	bf79                	j	80005b98 <sys_open+0xe4>
    iunlockput(ip);
    80005bfc:	8526                	mv	a0,s1
    80005bfe:	ffffe097          	auipc	ra,0xffffe
    80005c02:	16e080e7          	jalr	366(ra) # 80003d6c <iunlockput>
    end_op();
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	94e080e7          	jalr	-1714(ra) # 80004554 <end_op>
    return -1;
    80005c0e:	557d                	li	a0,-1
    80005c10:	b761                	j	80005b98 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c12:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c16:	04649783          	lh	a5,70(s1)
    80005c1a:	02f99223          	sh	a5,36(s3)
    80005c1e:	bf25                	j	80005b56 <sys_open+0xa2>
    itrunc(ip);
    80005c20:	8526                	mv	a0,s1
    80005c22:	ffffe097          	auipc	ra,0xffffe
    80005c26:	ff6080e7          	jalr	-10(ra) # 80003c18 <itrunc>
    80005c2a:	bfa9                	j	80005b84 <sys_open+0xd0>
      fileclose(f);
    80005c2c:	854e                	mv	a0,s3
    80005c2e:	fffff097          	auipc	ra,0xfffff
    80005c32:	d70080e7          	jalr	-656(ra) # 8000499e <fileclose>
    iunlockput(ip);
    80005c36:	8526                	mv	a0,s1
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	134080e7          	jalr	308(ra) # 80003d6c <iunlockput>
    end_op();
    80005c40:	fffff097          	auipc	ra,0xfffff
    80005c44:	914080e7          	jalr	-1772(ra) # 80004554 <end_op>
    return -1;
    80005c48:	557d                	li	a0,-1
    80005c4a:	b7b9                	j	80005b98 <sys_open+0xe4>

0000000080005c4c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c4c:	7175                	addi	sp,sp,-144
    80005c4e:	e506                	sd	ra,136(sp)
    80005c50:	e122                	sd	s0,128(sp)
    80005c52:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c54:	fffff097          	auipc	ra,0xfffff
    80005c58:	882080e7          	jalr	-1918(ra) # 800044d6 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
    80005c5c:	08000613          	li	a2,128
    80005c60:	f7040593          	addi	a1,s0,-144
    80005c64:	4501                	li	a0,0
    80005c66:	ffffd097          	auipc	ra,0xffffd
    80005c6a:	240080e7          	jalr	576(ra) # 80002ea6 <argstr>
    80005c6e:	02054963          	bltz	a0,80005ca0 <sys_mkdir+0x54>
    80005c72:	4681                	li	a3,0
    80005c74:	4601                	li	a2,0
    80005c76:	4585                	li	a1,1
    80005c78:	f7040513          	addi	a0,s0,-144
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	7fc080e7          	jalr	2044(ra) # 80005478 <create>
    80005c84:	cd11                	beqz	a0,80005ca0 <sys_mkdir+0x54>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c86:	ffffe097          	auipc	ra,0xffffe
    80005c8a:	0e6080e7          	jalr	230(ra) # 80003d6c <iunlockput>
  end_op();
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	8c6080e7          	jalr	-1850(ra) # 80004554 <end_op>
  return 0;
    80005c96:	4501                	li	a0,0
}
    80005c98:	60aa                	ld	ra,136(sp)
    80005c9a:	640a                	ld	s0,128(sp)
    80005c9c:	6149                	addi	sp,sp,144
    80005c9e:	8082                	ret
    end_op();
    80005ca0:	fffff097          	auipc	ra,0xfffff
    80005ca4:	8b4080e7          	jalr	-1868(ra) # 80004554 <end_op>
    return -1;
    80005ca8:	557d                	li	a0,-1
    80005caa:	b7fd                	j	80005c98 <sys_mkdir+0x4c>

0000000080005cac <sys_mknod>:

uint64
sys_mknod(void)
{
    80005cac:	7135                	addi	sp,sp,-160
    80005cae:	ed06                	sd	ra,152(sp)
    80005cb0:	e922                	sd	s0,144(sp)
    80005cb2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005cb4:	fffff097          	auipc	ra,0xfffff
    80005cb8:	822080e7          	jalr	-2014(ra) # 800044d6 <begin_op>
  argint(1, &major);
    80005cbc:	f6c40593          	addi	a1,s0,-148
    80005cc0:	4505                	li	a0,1
    80005cc2:	ffffd097          	auipc	ra,0xffffd
    80005cc6:	1a4080e7          	jalr	420(ra) # 80002e66 <argint>
  argint(2, &minor);
    80005cca:	f6840593          	addi	a1,s0,-152
    80005cce:	4509                	li	a0,2
    80005cd0:	ffffd097          	auipc	ra,0xffffd
    80005cd4:	196080e7          	jalr	406(ra) # 80002e66 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005cd8:	08000613          	li	a2,128
    80005cdc:	f7040593          	addi	a1,s0,-144
    80005ce0:	4501                	li	a0,0
    80005ce2:	ffffd097          	auipc	ra,0xffffd
    80005ce6:	1c4080e7          	jalr	452(ra) # 80002ea6 <argstr>
    80005cea:	02054b63          	bltz	a0,80005d20 <sys_mknod+0x74>
      (ip = create(path, T_DEVICE, major, minor)) == 0)
    80005cee:	f6841683          	lh	a3,-152(s0)
    80005cf2:	f6c41603          	lh	a2,-148(s0)
    80005cf6:	458d                	li	a1,3
    80005cf8:	f7040513          	addi	a0,s0,-144
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	77c080e7          	jalr	1916(ra) # 80005478 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005d04:	cd11                	beqz	a0,80005d20 <sys_mknod+0x74>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	066080e7          	jalr	102(ra) # 80003d6c <iunlockput>
  end_op();
    80005d0e:	fffff097          	auipc	ra,0xfffff
    80005d12:	846080e7          	jalr	-1978(ra) # 80004554 <end_op>
  return 0;
    80005d16:	4501                	li	a0,0
}
    80005d18:	60ea                	ld	ra,152(sp)
    80005d1a:	644a                	ld	s0,144(sp)
    80005d1c:	610d                	addi	sp,sp,160
    80005d1e:	8082                	ret
    end_op();
    80005d20:	fffff097          	auipc	ra,0xfffff
    80005d24:	834080e7          	jalr	-1996(ra) # 80004554 <end_op>
    return -1;
    80005d28:	557d                	li	a0,-1
    80005d2a:	b7fd                	j	80005d18 <sys_mknod+0x6c>

0000000080005d2c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d2c:	7135                	addi	sp,sp,-160
    80005d2e:	ed06                	sd	ra,152(sp)
    80005d30:	e922                	sd	s0,144(sp)
    80005d32:	e526                	sd	s1,136(sp)
    80005d34:	e14a                	sd	s2,128(sp)
    80005d36:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d38:	ffffc097          	auipc	ra,0xffffc
    80005d3c:	c74080e7          	jalr	-908(ra) # 800019ac <myproc>
    80005d40:	892a                	mv	s2,a0

  begin_op();
    80005d42:	ffffe097          	auipc	ra,0xffffe
    80005d46:	794080e7          	jalr	1940(ra) # 800044d6 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0)
    80005d4a:	08000613          	li	a2,128
    80005d4e:	f6040593          	addi	a1,s0,-160
    80005d52:	4501                	li	a0,0
    80005d54:	ffffd097          	auipc	ra,0xffffd
    80005d58:	152080e7          	jalr	338(ra) # 80002ea6 <argstr>
    80005d5c:	04054b63          	bltz	a0,80005db2 <sys_chdir+0x86>
    80005d60:	f6040513          	addi	a0,s0,-160
    80005d64:	ffffe097          	auipc	ra,0xffffe
    80005d68:	552080e7          	jalr	1362(ra) # 800042b6 <namei>
    80005d6c:	84aa                	mv	s1,a0
    80005d6e:	c131                	beqz	a0,80005db2 <sys_chdir+0x86>
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005d70:	ffffe097          	auipc	ra,0xffffe
    80005d74:	d9a080e7          	jalr	-614(ra) # 80003b0a <ilock>
  if (ip->type != T_DIR)
    80005d78:	04449703          	lh	a4,68(s1)
    80005d7c:	4785                	li	a5,1
    80005d7e:	04f71063          	bne	a4,a5,80005dbe <sys_chdir+0x92>
  {
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d82:	8526                	mv	a0,s1
    80005d84:	ffffe097          	auipc	ra,0xffffe
    80005d88:	e48080e7          	jalr	-440(ra) # 80003bcc <iunlock>
  iput(p->cwd);
    80005d8c:	15093503          	ld	a0,336(s2)
    80005d90:	ffffe097          	auipc	ra,0xffffe
    80005d94:	f34080e7          	jalr	-204(ra) # 80003cc4 <iput>
  end_op();
    80005d98:	ffffe097          	auipc	ra,0xffffe
    80005d9c:	7bc080e7          	jalr	1980(ra) # 80004554 <end_op>
  p->cwd = ip;
    80005da0:	14993823          	sd	s1,336(s2)
  return 0;
    80005da4:	4501                	li	a0,0
}
    80005da6:	60ea                	ld	ra,152(sp)
    80005da8:	644a                	ld	s0,144(sp)
    80005daa:	64aa                	ld	s1,136(sp)
    80005dac:	690a                	ld	s2,128(sp)
    80005dae:	610d                	addi	sp,sp,160
    80005db0:	8082                	ret
    end_op();
    80005db2:	ffffe097          	auipc	ra,0xffffe
    80005db6:	7a2080e7          	jalr	1954(ra) # 80004554 <end_op>
    return -1;
    80005dba:	557d                	li	a0,-1
    80005dbc:	b7ed                	j	80005da6 <sys_chdir+0x7a>
    iunlockput(ip);
    80005dbe:	8526                	mv	a0,s1
    80005dc0:	ffffe097          	auipc	ra,0xffffe
    80005dc4:	fac080e7          	jalr	-84(ra) # 80003d6c <iunlockput>
    end_op();
    80005dc8:	ffffe097          	auipc	ra,0xffffe
    80005dcc:	78c080e7          	jalr	1932(ra) # 80004554 <end_op>
    return -1;
    80005dd0:	557d                	li	a0,-1
    80005dd2:	bfd1                	j	80005da6 <sys_chdir+0x7a>

0000000080005dd4 <sys_exec>:

uint64
sys_exec(void)
{
    80005dd4:	7145                	addi	sp,sp,-464
    80005dd6:	e786                	sd	ra,456(sp)
    80005dd8:	e3a2                	sd	s0,448(sp)
    80005dda:	ff26                	sd	s1,440(sp)
    80005ddc:	fb4a                	sd	s2,432(sp)
    80005dde:	f74e                	sd	s3,424(sp)
    80005de0:	f352                	sd	s4,416(sp)
    80005de2:	ef56                	sd	s5,408(sp)
    80005de4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005de6:	e3840593          	addi	a1,s0,-456
    80005dea:	4505                	li	a0,1
    80005dec:	ffffd097          	auipc	ra,0xffffd
    80005df0:	09a080e7          	jalr	154(ra) # 80002e86 <argaddr>
  if (argstr(0, path, MAXPATH) < 0)
    80005df4:	08000613          	li	a2,128
    80005df8:	f4040593          	addi	a1,s0,-192
    80005dfc:	4501                	li	a0,0
    80005dfe:	ffffd097          	auipc	ra,0xffffd
    80005e02:	0a8080e7          	jalr	168(ra) # 80002ea6 <argstr>
    80005e06:	87aa                	mv	a5,a0
  {
    return -1;
    80005e08:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0)
    80005e0a:	0c07c363          	bltz	a5,80005ed0 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005e0e:	10000613          	li	a2,256
    80005e12:	4581                	li	a1,0
    80005e14:	e4040513          	addi	a0,s0,-448
    80005e18:	ffffb097          	auipc	ra,0xffffb
    80005e1c:	eba080e7          	jalr	-326(ra) # 80000cd2 <memset>
  for (i = 0;; i++)
  {
    if (i >= NELEM(argv))
    80005e20:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e24:	89a6                	mv	s3,s1
    80005e26:	4901                	li	s2,0
    if (i >= NELEM(argv))
    80005e28:	02000a13          	li	s4,32
    80005e2c:	00090a9b          	sext.w	s5,s2
    {
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0)
    80005e30:	00391513          	slli	a0,s2,0x3
    80005e34:	e3040593          	addi	a1,s0,-464
    80005e38:	e3843783          	ld	a5,-456(s0)
    80005e3c:	953e                	add	a0,a0,a5
    80005e3e:	ffffd097          	auipc	ra,0xffffd
    80005e42:	f8a080e7          	jalr	-118(ra) # 80002dc8 <fetchaddr>
    80005e46:	02054a63          	bltz	a0,80005e7a <sys_exec+0xa6>
    {
      goto bad;
    }
    if (uarg == 0)
    80005e4a:	e3043783          	ld	a5,-464(s0)
    80005e4e:	c3b9                	beqz	a5,80005e94 <sys_exec+0xc0>
    {
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e50:	ffffb097          	auipc	ra,0xffffb
    80005e54:	c96080e7          	jalr	-874(ra) # 80000ae6 <kalloc>
    80005e58:	85aa                	mv	a1,a0
    80005e5a:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005e5e:	cd11                	beqz	a0,80005e7a <sys_exec+0xa6>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e60:	6605                	lui	a2,0x1
    80005e62:	e3043503          	ld	a0,-464(s0)
    80005e66:	ffffd097          	auipc	ra,0xffffd
    80005e6a:	fb4080e7          	jalr	-76(ra) # 80002e1a <fetchstr>
    80005e6e:	00054663          	bltz	a0,80005e7a <sys_exec+0xa6>
    if (i >= NELEM(argv))
    80005e72:	0905                	addi	s2,s2,1
    80005e74:	09a1                	addi	s3,s3,8
    80005e76:	fb491be3          	bne	s2,s4,80005e2c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e7a:	f4040913          	addi	s2,s0,-192
    80005e7e:	6088                	ld	a0,0(s1)
    80005e80:	c539                	beqz	a0,80005ece <sys_exec+0xfa>
    kfree(argv[i]);
    80005e82:	ffffb097          	auipc	ra,0xffffb
    80005e86:	b66080e7          	jalr	-1178(ra) # 800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e8a:	04a1                	addi	s1,s1,8
    80005e8c:	ff2499e3          	bne	s1,s2,80005e7e <sys_exec+0xaa>
  return -1;
    80005e90:	557d                	li	a0,-1
    80005e92:	a83d                	j	80005ed0 <sys_exec+0xfc>
      argv[i] = 0;
    80005e94:	0a8e                	slli	s5,s5,0x3
    80005e96:	fc0a8793          	addi	a5,s5,-64
    80005e9a:	00878ab3          	add	s5,a5,s0
    80005e9e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ea2:	e4040593          	addi	a1,s0,-448
    80005ea6:	f4040513          	addi	a0,s0,-192
    80005eaa:	fffff097          	auipc	ra,0xfffff
    80005eae:	16e080e7          	jalr	366(ra) # 80005018 <exec>
    80005eb2:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eb4:	f4040993          	addi	s3,s0,-192
    80005eb8:	6088                	ld	a0,0(s1)
    80005eba:	c901                	beqz	a0,80005eca <sys_exec+0xf6>
    kfree(argv[i]);
    80005ebc:	ffffb097          	auipc	ra,0xffffb
    80005ec0:	b2c080e7          	jalr	-1236(ra) # 800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ec4:	04a1                	addi	s1,s1,8
    80005ec6:	ff3499e3          	bne	s1,s3,80005eb8 <sys_exec+0xe4>
  return ret;
    80005eca:	854a                	mv	a0,s2
    80005ecc:	a011                	j	80005ed0 <sys_exec+0xfc>
  return -1;
    80005ece:	557d                	li	a0,-1
}
    80005ed0:	60be                	ld	ra,456(sp)
    80005ed2:	641e                	ld	s0,448(sp)
    80005ed4:	74fa                	ld	s1,440(sp)
    80005ed6:	795a                	ld	s2,432(sp)
    80005ed8:	79ba                	ld	s3,424(sp)
    80005eda:	7a1a                	ld	s4,416(sp)
    80005edc:	6afa                	ld	s5,408(sp)
    80005ede:	6179                	addi	sp,sp,464
    80005ee0:	8082                	ret

0000000080005ee2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ee2:	7139                	addi	sp,sp,-64
    80005ee4:	fc06                	sd	ra,56(sp)
    80005ee6:	f822                	sd	s0,48(sp)
    80005ee8:	f426                	sd	s1,40(sp)
    80005eea:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005eec:	ffffc097          	auipc	ra,0xffffc
    80005ef0:	ac0080e7          	jalr	-1344(ra) # 800019ac <myproc>
    80005ef4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ef6:	fd840593          	addi	a1,s0,-40
    80005efa:	4501                	li	a0,0
    80005efc:	ffffd097          	auipc	ra,0xffffd
    80005f00:	f8a080e7          	jalr	-118(ra) # 80002e86 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005f04:	fc840593          	addi	a1,s0,-56
    80005f08:	fd040513          	addi	a0,s0,-48
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	dc2080e7          	jalr	-574(ra) # 80004cce <pipealloc>
    return -1;
    80005f14:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005f16:	0c054463          	bltz	a0,80005fde <sys_pipe+0xfc>
  fd0 = -1;
    80005f1a:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0)
    80005f1e:	fd043503          	ld	a0,-48(s0)
    80005f22:	fffff097          	auipc	ra,0xfffff
    80005f26:	514080e7          	jalr	1300(ra) # 80005436 <fdalloc>
    80005f2a:	fca42223          	sw	a0,-60(s0)
    80005f2e:	08054b63          	bltz	a0,80005fc4 <sys_pipe+0xe2>
    80005f32:	fc843503          	ld	a0,-56(s0)
    80005f36:	fffff097          	auipc	ra,0xfffff
    80005f3a:	500080e7          	jalr	1280(ra) # 80005436 <fdalloc>
    80005f3e:	fca42023          	sw	a0,-64(s0)
    80005f42:	06054863          	bltz	a0,80005fb2 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005f46:	4691                	li	a3,4
    80005f48:	fc440613          	addi	a2,s0,-60
    80005f4c:	fd843583          	ld	a1,-40(s0)
    80005f50:	68a8                	ld	a0,80(s1)
    80005f52:	ffffb097          	auipc	ra,0xffffb
    80005f56:	71a080e7          	jalr	1818(ra) # 8000166c <copyout>
    80005f5a:	02054063          	bltz	a0,80005f7a <sys_pipe+0x98>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0)
    80005f5e:	4691                	li	a3,4
    80005f60:	fc040613          	addi	a2,s0,-64
    80005f64:	fd843583          	ld	a1,-40(s0)
    80005f68:	0591                	addi	a1,a1,4
    80005f6a:	68a8                	ld	a0,80(s1)
    80005f6c:	ffffb097          	auipc	ra,0xffffb
    80005f70:	700080e7          	jalr	1792(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f74:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005f76:	06055463          	bgez	a0,80005fde <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005f7a:	fc442783          	lw	a5,-60(s0)
    80005f7e:	07e9                	addi	a5,a5,26
    80005f80:	078e                	slli	a5,a5,0x3
    80005f82:	97a6                	add	a5,a5,s1
    80005f84:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f88:	fc042783          	lw	a5,-64(s0)
    80005f8c:	07e9                	addi	a5,a5,26
    80005f8e:	078e                	slli	a5,a5,0x3
    80005f90:	94be                	add	s1,s1,a5
    80005f92:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f96:	fd043503          	ld	a0,-48(s0)
    80005f9a:	fffff097          	auipc	ra,0xfffff
    80005f9e:	a04080e7          	jalr	-1532(ra) # 8000499e <fileclose>
    fileclose(wf);
    80005fa2:	fc843503          	ld	a0,-56(s0)
    80005fa6:	fffff097          	auipc	ra,0xfffff
    80005faa:	9f8080e7          	jalr	-1544(ra) # 8000499e <fileclose>
    return -1;
    80005fae:	57fd                	li	a5,-1
    80005fb0:	a03d                	j	80005fde <sys_pipe+0xfc>
    if (fd0 >= 0)
    80005fb2:	fc442783          	lw	a5,-60(s0)
    80005fb6:	0007c763          	bltz	a5,80005fc4 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005fba:	07e9                	addi	a5,a5,26
    80005fbc:	078e                	slli	a5,a5,0x3
    80005fbe:	97a6                	add	a5,a5,s1
    80005fc0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005fc4:	fd043503          	ld	a0,-48(s0)
    80005fc8:	fffff097          	auipc	ra,0xfffff
    80005fcc:	9d6080e7          	jalr	-1578(ra) # 8000499e <fileclose>
    fileclose(wf);
    80005fd0:	fc843503          	ld	a0,-56(s0)
    80005fd4:	fffff097          	auipc	ra,0xfffff
    80005fd8:	9ca080e7          	jalr	-1590(ra) # 8000499e <fileclose>
    return -1;
    80005fdc:	57fd                	li	a5,-1
}
    80005fde:	853e                	mv	a0,a5
    80005fe0:	70e2                	ld	ra,56(sp)
    80005fe2:	7442                	ld	s0,48(sp)
    80005fe4:	74a2                	ld	s1,40(sp)
    80005fe6:	6121                	addi	sp,sp,64
    80005fe8:	8082                	ret
    80005fea:	0000                	unimp
    80005fec:	0000                	unimp
	...

0000000080005ff0 <kernelvec>:
    80005ff0:	7111                	addi	sp,sp,-256
    80005ff2:	e006                	sd	ra,0(sp)
    80005ff4:	e40a                	sd	sp,8(sp)
    80005ff6:	e80e                	sd	gp,16(sp)
    80005ff8:	ec12                	sd	tp,24(sp)
    80005ffa:	f016                	sd	t0,32(sp)
    80005ffc:	f41a                	sd	t1,40(sp)
    80005ffe:	f81e                	sd	t2,48(sp)
    80006000:	fc22                	sd	s0,56(sp)
    80006002:	e0a6                	sd	s1,64(sp)
    80006004:	e4aa                	sd	a0,72(sp)
    80006006:	e8ae                	sd	a1,80(sp)
    80006008:	ecb2                	sd	a2,88(sp)
    8000600a:	f0b6                	sd	a3,96(sp)
    8000600c:	f4ba                	sd	a4,104(sp)
    8000600e:	f8be                	sd	a5,112(sp)
    80006010:	fcc2                	sd	a6,120(sp)
    80006012:	e146                	sd	a7,128(sp)
    80006014:	e54a                	sd	s2,136(sp)
    80006016:	e94e                	sd	s3,144(sp)
    80006018:	ed52                	sd	s4,152(sp)
    8000601a:	f156                	sd	s5,160(sp)
    8000601c:	f55a                	sd	s6,168(sp)
    8000601e:	f95e                	sd	s7,176(sp)
    80006020:	fd62                	sd	s8,184(sp)
    80006022:	e1e6                	sd	s9,192(sp)
    80006024:	e5ea                	sd	s10,200(sp)
    80006026:	e9ee                	sd	s11,208(sp)
    80006028:	edf2                	sd	t3,216(sp)
    8000602a:	f1f6                	sd	t4,224(sp)
    8000602c:	f5fa                	sd	t5,232(sp)
    8000602e:	f9fe                	sd	t6,240(sp)
    80006030:	c65fc0ef          	jal	ra,80002c94 <kerneltrap>
    80006034:	6082                	ld	ra,0(sp)
    80006036:	6122                	ld	sp,8(sp)
    80006038:	61c2                	ld	gp,16(sp)
    8000603a:	7282                	ld	t0,32(sp)
    8000603c:	7322                	ld	t1,40(sp)
    8000603e:	73c2                	ld	t2,48(sp)
    80006040:	7462                	ld	s0,56(sp)
    80006042:	6486                	ld	s1,64(sp)
    80006044:	6526                	ld	a0,72(sp)
    80006046:	65c6                	ld	a1,80(sp)
    80006048:	6666                	ld	a2,88(sp)
    8000604a:	7686                	ld	a3,96(sp)
    8000604c:	7726                	ld	a4,104(sp)
    8000604e:	77c6                	ld	a5,112(sp)
    80006050:	7866                	ld	a6,120(sp)
    80006052:	688a                	ld	a7,128(sp)
    80006054:	692a                	ld	s2,136(sp)
    80006056:	69ca                	ld	s3,144(sp)
    80006058:	6a6a                	ld	s4,152(sp)
    8000605a:	7a8a                	ld	s5,160(sp)
    8000605c:	7b2a                	ld	s6,168(sp)
    8000605e:	7bca                	ld	s7,176(sp)
    80006060:	7c6a                	ld	s8,184(sp)
    80006062:	6c8e                	ld	s9,192(sp)
    80006064:	6d2e                	ld	s10,200(sp)
    80006066:	6dce                	ld	s11,208(sp)
    80006068:	6e6e                	ld	t3,216(sp)
    8000606a:	7e8e                	ld	t4,224(sp)
    8000606c:	7f2e                	ld	t5,232(sp)
    8000606e:	7fce                	ld	t6,240(sp)
    80006070:	6111                	addi	sp,sp,256
    80006072:	10200073          	sret
    80006076:	00000013          	nop
    8000607a:	00000013          	nop
    8000607e:	0001                	nop

0000000080006080 <timervec>:
    80006080:	34051573          	csrrw	a0,mscratch,a0
    80006084:	e10c                	sd	a1,0(a0)
    80006086:	e510                	sd	a2,8(a0)
    80006088:	e914                	sd	a3,16(a0)
    8000608a:	6d0c                	ld	a1,24(a0)
    8000608c:	7110                	ld	a2,32(a0)
    8000608e:	6194                	ld	a3,0(a1)
    80006090:	96b2                	add	a3,a3,a2
    80006092:	e194                	sd	a3,0(a1)
    80006094:	4589                	li	a1,2
    80006096:	14459073          	csrw	sip,a1
    8000609a:	6914                	ld	a3,16(a0)
    8000609c:	6510                	ld	a2,8(a0)
    8000609e:	610c                	ld	a1,0(a0)
    800060a0:	34051573          	csrrw	a0,mscratch,a0
    800060a4:	30200073          	mret
	...

00000000800060aa <plicinit>:
//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void)
{
    800060aa:	1141                	addi	sp,sp,-16
    800060ac:	e422                	sd	s0,8(sp)
    800060ae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800060b0:	0c0007b7          	lui	a5,0xc000
    800060b4:	4705                	li	a4,1
    800060b6:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800060b8:	c3d8                	sw	a4,4(a5)
}
    800060ba:	6422                	ld	s0,8(sp)
    800060bc:	0141                	addi	sp,sp,16
    800060be:	8082                	ret

00000000800060c0 <plicinithart>:

void plicinithart(void)
{
    800060c0:	1141                	addi	sp,sp,-16
    800060c2:	e406                	sd	ra,8(sp)
    800060c4:	e022                	sd	s0,0(sp)
    800060c6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	8b8080e7          	jalr	-1864(ra) # 80001980 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060d0:	0085171b          	slliw	a4,a0,0x8
    800060d4:	0c0027b7          	lui	a5,0xc002
    800060d8:	97ba                	add	a5,a5,a4
    800060da:	40200713          	li	a4,1026
    800060de:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    800060e2:	00d5151b          	slliw	a0,a0,0xd
    800060e6:	0c2017b7          	lui	a5,0xc201
    800060ea:	97aa                	add	a5,a5,a0
    800060ec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800060f0:	60a2                	ld	ra,8(sp)
    800060f2:	6402                	ld	s0,0(sp)
    800060f4:	0141                	addi	sp,sp,16
    800060f6:	8082                	ret

00000000800060f8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void)
{
    800060f8:	1141                	addi	sp,sp,-16
    800060fa:	e406                	sd	ra,8(sp)
    800060fc:	e022                	sd	s0,0(sp)
    800060fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006100:	ffffc097          	auipc	ra,0xffffc
    80006104:	880080e7          	jalr	-1920(ra) # 80001980 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80006108:	00d5151b          	slliw	a0,a0,0xd
    8000610c:	0c2017b7          	lui	a5,0xc201
    80006110:	97aa                	add	a5,a5,a0
  return irq;
}
    80006112:	43c8                	lw	a0,4(a5)
    80006114:	60a2                	ld	ra,8(sp)
    80006116:	6402                	ld	s0,0(sp)
    80006118:	0141                	addi	sp,sp,16
    8000611a:	8082                	ret

000000008000611c <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq)
{
    8000611c:	1101                	addi	sp,sp,-32
    8000611e:	ec06                	sd	ra,24(sp)
    80006120:	e822                	sd	s0,16(sp)
    80006122:	e426                	sd	s1,8(sp)
    80006124:	1000                	addi	s0,sp,32
    80006126:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	858080e7          	jalr	-1960(ra) # 80001980 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80006130:	00d5151b          	slliw	a0,a0,0xd
    80006134:	0c2017b7          	lui	a5,0xc201
    80006138:	97aa                	add	a5,a5,a0
    8000613a:	c3c4                	sw	s1,4(a5)
}
    8000613c:	60e2                	ld	ra,24(sp)
    8000613e:	6442                	ld	s0,16(sp)
    80006140:	64a2                	ld	s1,8(sp)
    80006142:	6105                	addi	sp,sp,32
    80006144:	8082                	ret

0000000080006146 <popfront>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void popfront(deque *a)
{
    80006146:	1141                	addi	sp,sp,-16
    80006148:	e422                	sd	s0,8(sp)
    8000614a:	0800                	addi	s0,sp,16
    a->end -= 1;
    8000614c:	20052683          	lw	a3,512(a0)
    80006150:	fff6879b          	addiw	a5,a3,-1
    80006154:	0007871b          	sext.w	a4,a5
    80006158:	20f52023          	sw	a5,512(a0)
    for (int i = 0; i < a->end; i++)
    8000615c:	cf11                	beqz	a4,80006178 <popfront+0x32>
    8000615e:	87aa                	mv	a5,a0
    80006160:	36f9                	addiw	a3,a3,-2
    80006162:	02069713          	slli	a4,a3,0x20
    80006166:	01d75693          	srli	a3,a4,0x1d
    8000616a:	0521                	addi	a0,a0,8
    8000616c:	96aa                	add	a3,a3,a0
    {
        a->n[i] = a->n[i + 1];
    8000616e:	6798                	ld	a4,8(a5)
    80006170:	e398                	sd	a4,0(a5)
    for (int i = 0; i < a->end; i++)
    80006172:	07a1                	addi	a5,a5,8 # c201008 <_entry-0x73dfeff8>
    80006174:	fed79de3          	bne	a5,a3,8000616e <popfront+0x28>
    }
    return;
}
    80006178:	6422                	ld	s0,8(sp)
    8000617a:	0141                	addi	sp,sp,16
    8000617c:	8082                	ret

000000008000617e <pushback>:
void pushback(deque *a, struct proc *x)
{
    if (a->end == NPROC)
    8000617e:	20052783          	lw	a5,512(a0)
    80006182:	04000713          	li	a4,64
    80006186:	00e78c63          	beq	a5,a4,8000619e <pushback+0x20>
    {
        panic("Panic Error");
        return;
    }
    a->n[a->end] = x;
    8000618a:	02079693          	slli	a3,a5,0x20
    8000618e:	01d6d713          	srli	a4,a3,0x1d
    80006192:	972a                	add	a4,a4,a0
    80006194:	e30c                	sd	a1,0(a4)
    a->end += 1;
    80006196:	2785                	addiw	a5,a5,1
    80006198:	20f52023          	sw	a5,512(a0)
    8000619c:	8082                	ret
{
    8000619e:	1141                	addi	sp,sp,-16
    800061a0:	e406                	sd	ra,8(sp)
    800061a2:	e022                	sd	s0,0(sp)
    800061a4:	0800                	addi	s0,sp,16
        panic("Panic Error");
    800061a6:	00002517          	auipc	a0,0x2
    800061aa:	5b250513          	addi	a0,a0,1458 # 80008758 <syscalls+0x308>
    800061ae:	ffffa097          	auipc	ra,0xffffa
    800061b2:	392080e7          	jalr	914(ra) # 80000540 <panic>

00000000800061b6 <front>:
    return;
}
struct proc *front(deque *a)
{
    800061b6:	1141                	addi	sp,sp,-16
    800061b8:	e422                	sd	s0,8(sp)
    800061ba:	0800                	addi	s0,sp,16
    if (a->end == 0)
    800061bc:	20052783          	lw	a5,512(a0)
    800061c0:	c789                	beqz	a5,800061ca <front+0x14>
    {
        return 0;
    }
    return a->n[0];
    800061c2:	6108                	ld	a0,0(a0)
}
    800061c4:	6422                	ld	s0,8(sp)
    800061c6:	0141                	addi	sp,sp,16
    800061c8:	8082                	ret
        return 0;
    800061ca:	4501                	li	a0,0
    800061cc:	bfe5                	j	800061c4 <front+0xe>

00000000800061ce <size>:
int size(deque *a)
{
    800061ce:	1141                	addi	sp,sp,-16
    800061d0:	e422                	sd	s0,8(sp)
    800061d2:	0800                	addi	s0,sp,16
    return a->end;
}
    800061d4:	20052503          	lw	a0,512(a0)
    800061d8:	6422                	ld	s0,8(sp)
    800061da:	0141                	addi	sp,sp,16
    800061dc:	8082                	ret

00000000800061de <delete>:
void delete(deque *a, uint pid)
{
    800061de:	1141                	addi	sp,sp,-16
    800061e0:	e422                	sd	s0,8(sp)
    800061e2:	0800                	addi	s0,sp,16
    int flag = 0;
    for (int i = 0; i < a->end; i++)
    800061e4:	20052e03          	lw	t3,512(a0)
    800061e8:	020e0c63          	beqz	t3,80006220 <delete+0x42>
    800061ec:	87aa                	mv	a5,a0
    800061ee:	000e031b          	sext.w	t1,t3
    800061f2:	4701                	li	a4,0
    int flag = 0;
    800061f4:	4881                	li	a7,0
    {
        if (pid == a->n[i]->pid)
            flag = 1;

        if (flag == 1 && i != NPROC)
    800061f6:	04000e93          	li	t4,64
    800061fa:	4805                	li	a6,1
    800061fc:	a811                	j	80006210 <delete+0x32>
    800061fe:	88c2                	mv	a7,a6
    80006200:	01d70463          	beq	a4,t4,80006208 <delete+0x2a>
            a->n[i] = a->n[i + 1];
    80006204:	6614                	ld	a3,8(a2)
    80006206:	e214                	sd	a3,0(a2)
    for (int i = 0; i < a->end; i++)
    80006208:	2705                	addiw	a4,a4,1
    8000620a:	07a1                	addi	a5,a5,8
    8000620c:	00670a63          	beq	a4,t1,80006220 <delete+0x42>
        if (pid == a->n[i]->pid)
    80006210:	863e                	mv	a2,a5
    80006212:	6394                	ld	a3,0(a5)
    80006214:	5a94                	lw	a3,48(a3)
    80006216:	feb684e3          	beq	a3,a1,800061fe <delete+0x20>
        if (flag == 1 && i != NPROC)
    8000621a:	ff0897e3          	bne	a7,a6,80006208 <delete+0x2a>
    8000621e:	b7c5                	j	800061fe <delete+0x20>
    }
    a->end -= 1;
    80006220:	3e7d                	addiw	t3,t3,-1
    80006222:	21c52023          	sw	t3,512(a0)
    return;
    80006226:	6422                	ld	s0,8(sp)
    80006228:	0141                	addi	sp,sp,16
    8000622a:	8082                	ret

000000008000622c <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000622c:	1141                	addi	sp,sp,-16
    8000622e:	e406                	sd	ra,8(sp)
    80006230:	e022                	sd	s0,0(sp)
    80006232:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80006234:	479d                	li	a5,7
    80006236:	04a7cc63          	blt	a5,a0,8000628e <free_desc+0x62>
    panic("free_desc 1");
  if (disk.free[i])
    8000623a:	0001d797          	auipc	a5,0x1d
    8000623e:	23678793          	addi	a5,a5,566 # 80023470 <disk>
    80006242:	97aa                	add	a5,a5,a0
    80006244:	0187c783          	lbu	a5,24(a5)
    80006248:	ebb9                	bnez	a5,8000629e <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000624a:	00451693          	slli	a3,a0,0x4
    8000624e:	0001d797          	auipc	a5,0x1d
    80006252:	22278793          	addi	a5,a5,546 # 80023470 <disk>
    80006256:	6398                	ld	a4,0(a5)
    80006258:	9736                	add	a4,a4,a3
    8000625a:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000625e:	6398                	ld	a4,0(a5)
    80006260:	9736                	add	a4,a4,a3
    80006262:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006266:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000626a:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000626e:	97aa                	add	a5,a5,a0
    80006270:	4705                	li	a4,1
    80006272:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006276:	0001d517          	auipc	a0,0x1d
    8000627a:	21250513          	addi	a0,a0,530 # 80023488 <disk+0x18>
    8000627e:	ffffc097          	auipc	ra,0xffffc
    80006282:	fae080e7          	jalr	-82(ra) # 8000222c <wakeup>
}
    80006286:	60a2                	ld	ra,8(sp)
    80006288:	6402                	ld	s0,0(sp)
    8000628a:	0141                	addi	sp,sp,16
    8000628c:	8082                	ret
    panic("free_desc 1");
    8000628e:	00002517          	auipc	a0,0x2
    80006292:	4da50513          	addi	a0,a0,1242 # 80008768 <syscalls+0x318>
    80006296:	ffffa097          	auipc	ra,0xffffa
    8000629a:	2aa080e7          	jalr	682(ra) # 80000540 <panic>
    panic("free_desc 2");
    8000629e:	00002517          	auipc	a0,0x2
    800062a2:	4da50513          	addi	a0,a0,1242 # 80008778 <syscalls+0x328>
    800062a6:	ffffa097          	auipc	ra,0xffffa
    800062aa:	29a080e7          	jalr	666(ra) # 80000540 <panic>

00000000800062ae <virtio_disk_init>:
{
    800062ae:	1101                	addi	sp,sp,-32
    800062b0:	ec06                	sd	ra,24(sp)
    800062b2:	e822                	sd	s0,16(sp)
    800062b4:	e426                	sd	s1,8(sp)
    800062b6:	e04a                	sd	s2,0(sp)
    800062b8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800062ba:	00002597          	auipc	a1,0x2
    800062be:	4ce58593          	addi	a1,a1,1230 # 80008788 <syscalls+0x338>
    800062c2:	0001d517          	auipc	a0,0x1d
    800062c6:	2d650513          	addi	a0,a0,726 # 80023598 <disk+0x128>
    800062ca:	ffffb097          	auipc	ra,0xffffb
    800062ce:	87c080e7          	jalr	-1924(ra) # 80000b46 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062d2:	100017b7          	lui	a5,0x10001
    800062d6:	4398                	lw	a4,0(a5)
    800062d8:	2701                	sext.w	a4,a4
    800062da:	747277b7          	lui	a5,0x74727
    800062de:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062e2:	14f71b63          	bne	a4,a5,80006438 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062e6:	100017b7          	lui	a5,0x10001
    800062ea:	43dc                	lw	a5,4(a5)
    800062ec:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062ee:	4709                	li	a4,2
    800062f0:	14e79463          	bne	a5,a4,80006438 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062f4:	100017b7          	lui	a5,0x10001
    800062f8:	479c                	lw	a5,8(a5)
    800062fa:	2781                	sext.w	a5,a5
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062fc:	12e79e63          	bne	a5,a4,80006438 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551)
    80006300:	100017b7          	lui	a5,0x10001
    80006304:	47d8                	lw	a4,12(a5)
    80006306:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006308:	554d47b7          	lui	a5,0x554d4
    8000630c:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006310:	12f71463          	bne	a4,a5,80006438 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006314:	100017b7          	lui	a5,0x10001
    80006318:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000631c:	4705                	li	a4,1
    8000631e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006320:	470d                	li	a4,3
    80006322:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006324:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006326:	c7ffe6b7          	lui	a3,0xc7ffe
    8000632a:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb1af>
    8000632e:	8f75                	and	a4,a4,a3
    80006330:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006332:	472d                	li	a4,11
    80006334:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006336:	5bbc                	lw	a5,112(a5)
    80006338:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000633c:	8ba1                	andi	a5,a5,8
    8000633e:	10078563          	beqz	a5,80006448 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006342:	100017b7          	lui	a5,0x10001
    80006346:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    8000634a:	43fc                	lw	a5,68(a5)
    8000634c:	2781                	sext.w	a5,a5
    8000634e:	10079563          	bnez	a5,80006458 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006352:	100017b7          	lui	a5,0x10001
    80006356:	5bdc                	lw	a5,52(a5)
    80006358:	2781                	sext.w	a5,a5
  if (max == 0)
    8000635a:	10078763          	beqz	a5,80006468 <virtio_disk_init+0x1ba>
  if (max < NUM)
    8000635e:	471d                	li	a4,7
    80006360:	10f77c63          	bgeu	a4,a5,80006478 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80006364:	ffffa097          	auipc	ra,0xffffa
    80006368:	782080e7          	jalr	1922(ra) # 80000ae6 <kalloc>
    8000636c:	0001d497          	auipc	s1,0x1d
    80006370:	10448493          	addi	s1,s1,260 # 80023470 <disk>
    80006374:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006376:	ffffa097          	auipc	ra,0xffffa
    8000637a:	770080e7          	jalr	1904(ra) # 80000ae6 <kalloc>
    8000637e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80006380:	ffffa097          	auipc	ra,0xffffa
    80006384:	766080e7          	jalr	1894(ra) # 80000ae6 <kalloc>
    80006388:	87aa                	mv	a5,a0
    8000638a:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    8000638c:	6088                	ld	a0,0(s1)
    8000638e:	cd6d                	beqz	a0,80006488 <virtio_disk_init+0x1da>
    80006390:	0001d717          	auipc	a4,0x1d
    80006394:	0e873703          	ld	a4,232(a4) # 80023478 <disk+0x8>
    80006398:	cb65                	beqz	a4,80006488 <virtio_disk_init+0x1da>
    8000639a:	c7fd                	beqz	a5,80006488 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    8000639c:	6605                	lui	a2,0x1
    8000639e:	4581                	li	a1,0
    800063a0:	ffffb097          	auipc	ra,0xffffb
    800063a4:	932080e7          	jalr	-1742(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800063a8:	0001d497          	auipc	s1,0x1d
    800063ac:	0c848493          	addi	s1,s1,200 # 80023470 <disk>
    800063b0:	6605                	lui	a2,0x1
    800063b2:	4581                	li	a1,0
    800063b4:	6488                	ld	a0,8(s1)
    800063b6:	ffffb097          	auipc	ra,0xffffb
    800063ba:	91c080e7          	jalr	-1764(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800063be:	6605                	lui	a2,0x1
    800063c0:	4581                	li	a1,0
    800063c2:	6888                	ld	a0,16(s1)
    800063c4:	ffffb097          	auipc	ra,0xffffb
    800063c8:	90e080e7          	jalr	-1778(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063cc:	100017b7          	lui	a5,0x10001
    800063d0:	4721                	li	a4,8
    800063d2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063d4:	4098                	lw	a4,0(s1)
    800063d6:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800063da:	40d8                	lw	a4,4(s1)
    800063dc:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800063e0:	6498                	ld	a4,8(s1)
    800063e2:	0007069b          	sext.w	a3,a4
    800063e6:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063ea:	9701                	srai	a4,a4,0x20
    800063ec:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063f0:	6898                	ld	a4,16(s1)
    800063f2:	0007069b          	sext.w	a3,a4
    800063f6:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800063fa:	9701                	srai	a4,a4,0x20
    800063fc:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006400:	4705                	li	a4,1
    80006402:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006404:	00e48c23          	sb	a4,24(s1)
    80006408:	00e48ca3          	sb	a4,25(s1)
    8000640c:	00e48d23          	sb	a4,26(s1)
    80006410:	00e48da3          	sb	a4,27(s1)
    80006414:	00e48e23          	sb	a4,28(s1)
    80006418:	00e48ea3          	sb	a4,29(s1)
    8000641c:	00e48f23          	sb	a4,30(s1)
    80006420:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006424:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006428:	0727a823          	sw	s2,112(a5)
}
    8000642c:	60e2                	ld	ra,24(sp)
    8000642e:	6442                	ld	s0,16(sp)
    80006430:	64a2                	ld	s1,8(sp)
    80006432:	6902                	ld	s2,0(sp)
    80006434:	6105                	addi	sp,sp,32
    80006436:	8082                	ret
    panic("could not find virtio disk");
    80006438:	00002517          	auipc	a0,0x2
    8000643c:	36050513          	addi	a0,a0,864 # 80008798 <syscalls+0x348>
    80006440:	ffffa097          	auipc	ra,0xffffa
    80006444:	100080e7          	jalr	256(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006448:	00002517          	auipc	a0,0x2
    8000644c:	37050513          	addi	a0,a0,880 # 800087b8 <syscalls+0x368>
    80006450:	ffffa097          	auipc	ra,0xffffa
    80006454:	0f0080e7          	jalr	240(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006458:	00002517          	auipc	a0,0x2
    8000645c:	38050513          	addi	a0,a0,896 # 800087d8 <syscalls+0x388>
    80006460:	ffffa097          	auipc	ra,0xffffa
    80006464:	0e0080e7          	jalr	224(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006468:	00002517          	auipc	a0,0x2
    8000646c:	39050513          	addi	a0,a0,912 # 800087f8 <syscalls+0x3a8>
    80006470:	ffffa097          	auipc	ra,0xffffa
    80006474:	0d0080e7          	jalr	208(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006478:	00002517          	auipc	a0,0x2
    8000647c:	3a050513          	addi	a0,a0,928 # 80008818 <syscalls+0x3c8>
    80006480:	ffffa097          	auipc	ra,0xffffa
    80006484:	0c0080e7          	jalr	192(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006488:	00002517          	auipc	a0,0x2
    8000648c:	3b050513          	addi	a0,a0,944 # 80008838 <syscalls+0x3e8>
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	0b0080e7          	jalr	176(ra) # 80000540 <panic>

0000000080006498 <virtio_disk_rw>:
  }
  return 0;
}

void virtio_disk_rw(struct buf *b, int write)
{
    80006498:	7119                	addi	sp,sp,-128
    8000649a:	fc86                	sd	ra,120(sp)
    8000649c:	f8a2                	sd	s0,112(sp)
    8000649e:	f4a6                	sd	s1,104(sp)
    800064a0:	f0ca                	sd	s2,96(sp)
    800064a2:	ecce                	sd	s3,88(sp)
    800064a4:	e8d2                	sd	s4,80(sp)
    800064a6:	e4d6                	sd	s5,72(sp)
    800064a8:	e0da                	sd	s6,64(sp)
    800064aa:	fc5e                	sd	s7,56(sp)
    800064ac:	f862                	sd	s8,48(sp)
    800064ae:	f466                	sd	s9,40(sp)
    800064b0:	f06a                	sd	s10,32(sp)
    800064b2:	ec6e                	sd	s11,24(sp)
    800064b4:	0100                	addi	s0,sp,128
    800064b6:	8aaa                	mv	s5,a0
    800064b8:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064ba:	00c52d03          	lw	s10,12(a0)
    800064be:	001d1d1b          	slliw	s10,s10,0x1
    800064c2:	1d02                	slli	s10,s10,0x20
    800064c4:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800064c8:	0001d517          	auipc	a0,0x1d
    800064cc:	0d050513          	addi	a0,a0,208 # 80023598 <disk+0x128>
    800064d0:	ffffa097          	auipc	ra,0xffffa
    800064d4:	706080e7          	jalr	1798(ra) # 80000bd6 <acquire>
  for (int i = 0; i < 3; i++)
    800064d8:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++)
    800064da:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064dc:	0001db97          	auipc	s7,0x1d
    800064e0:	f94b8b93          	addi	s7,s7,-108 # 80023470 <disk>
  for (int i = 0; i < 3; i++)
    800064e4:	4b0d                	li	s6,3
  {
    if (alloc3_desc(idx) == 0)
    {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064e6:	0001dc97          	auipc	s9,0x1d
    800064ea:	0b2c8c93          	addi	s9,s9,178 # 80023598 <disk+0x128>
    800064ee:	a08d                	j	80006550 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800064f0:	00fb8733          	add	a4,s7,a5
    800064f4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064f8:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0)
    800064fa:	0207c563          	bltz	a5,80006524 <virtio_disk_rw+0x8c>
  for (int i = 0; i < 3; i++)
    800064fe:	2905                	addiw	s2,s2,1
    80006500:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006502:	05690c63          	beq	s2,s6,8000655a <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006506:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++)
    80006508:	0001d717          	auipc	a4,0x1d
    8000650c:	f6870713          	addi	a4,a4,-152 # 80023470 <disk>
    80006510:	87ce                	mv	a5,s3
    if (disk.free[i])
    80006512:	01874683          	lbu	a3,24(a4)
    80006516:	fee9                	bnez	a3,800064f0 <virtio_disk_rw+0x58>
  for (int i = 0; i < NUM; i++)
    80006518:	2785                	addiw	a5,a5,1
    8000651a:	0705                	addi	a4,a4,1
    8000651c:	fe979be3          	bne	a5,s1,80006512 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006520:	57fd                	li	a5,-1
    80006522:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80006524:	01205d63          	blez	s2,8000653e <virtio_disk_rw+0xa6>
    80006528:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000652a:	000a2503          	lw	a0,0(s4)
    8000652e:	00000097          	auipc	ra,0x0
    80006532:	cfe080e7          	jalr	-770(ra) # 8000622c <free_desc>
      for (int j = 0; j < i; j++)
    80006536:	2d85                	addiw	s11,s11,1
    80006538:	0a11                	addi	s4,s4,4
    8000653a:	ff2d98e3          	bne	s11,s2,8000652a <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000653e:	85e6                	mv	a1,s9
    80006540:	0001d517          	auipc	a0,0x1d
    80006544:	f4850513          	addi	a0,a0,-184 # 80023488 <disk+0x18>
    80006548:	ffffc097          	auipc	ra,0xffffc
    8000654c:	c80080e7          	jalr	-896(ra) # 800021c8 <sleep>
  for (int i = 0; i < 3; i++)
    80006550:	f8040a13          	addi	s4,s0,-128
{
    80006554:	8652                	mv	a2,s4
  for (int i = 0; i < 3; i++)
    80006556:	894e                	mv	s2,s3
    80006558:	b77d                	j	80006506 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000655a:	f8042503          	lw	a0,-128(s0)
    8000655e:	00a50713          	addi	a4,a0,10
    80006562:	0712                	slli	a4,a4,0x4

  if (write)
    80006564:	0001d797          	auipc	a5,0x1d
    80006568:	f0c78793          	addi	a5,a5,-244 # 80023470 <disk>
    8000656c:	00e786b3          	add	a3,a5,a4
    80006570:	01803633          	snez	a2,s8
    80006574:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006576:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    8000657a:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64)buf0;
    8000657e:	f6070613          	addi	a2,a4,-160
    80006582:	6394                	ld	a3,0(a5)
    80006584:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006586:	00870593          	addi	a1,a4,8
    8000658a:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    8000658c:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000658e:	0007b803          	ld	a6,0(a5)
    80006592:	9642                	add	a2,a2,a6
    80006594:	46c1                	li	a3,16
    80006596:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006598:	4585                	li	a1,1
    8000659a:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    8000659e:	f8442683          	lw	a3,-124(s0)
    800065a2:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64)b->data;
    800065a6:	0692                	slli	a3,a3,0x4
    800065a8:	9836                	add	a6,a6,a3
    800065aa:	058a8613          	addi	a2,s5,88
    800065ae:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800065b2:	0007b803          	ld	a6,0(a5)
    800065b6:	96c2                	add	a3,a3,a6
    800065b8:	40000613          	li	a2,1024
    800065bc:	c690                	sw	a2,8(a3)
  if (write)
    800065be:	001c3613          	seqz	a2,s8
    800065c2:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065c6:	00166613          	ori	a2,a2,1
    800065ca:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800065ce:	f8842603          	lw	a2,-120(s0)
    800065d2:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065d6:	00250693          	addi	a3,a0,2
    800065da:	0692                	slli	a3,a3,0x4
    800065dc:	96be                	add	a3,a3,a5
    800065de:	58fd                	li	a7,-1
    800065e0:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    800065e4:	0612                	slli	a2,a2,0x4
    800065e6:	9832                	add	a6,a6,a2
    800065e8:	f9070713          	addi	a4,a4,-112
    800065ec:	973e                	add	a4,a4,a5
    800065ee:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800065f2:	6398                	ld	a4,0(a5)
    800065f4:	9732                	add	a4,a4,a2
    800065f6:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065f8:	4609                	li	a2,2
    800065fa:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800065fe:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006602:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006606:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000660a:	6794                	ld	a3,8(a5)
    8000660c:	0026d703          	lhu	a4,2(a3)
    80006610:	8b1d                	andi	a4,a4,7
    80006612:	0706                	slli	a4,a4,0x1
    80006614:	96ba                	add	a3,a3,a4
    80006616:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000661a:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000661e:	6798                	ld	a4,8(a5)
    80006620:	00275783          	lhu	a5,2(a4)
    80006624:	2785                	addiw	a5,a5,1
    80006626:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000662a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000662e:	100017b7          	lui	a5,0x10001
    80006632:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1)
    80006636:	004aa783          	lw	a5,4(s5)
  {
    sleep(b, &disk.vdisk_lock);
    8000663a:	0001d917          	auipc	s2,0x1d
    8000663e:	f5e90913          	addi	s2,s2,-162 # 80023598 <disk+0x128>
  while (b->disk == 1)
    80006642:	4485                	li	s1,1
    80006644:	00b79c63          	bne	a5,a1,8000665c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006648:	85ca                	mv	a1,s2
    8000664a:	8556                	mv	a0,s5
    8000664c:	ffffc097          	auipc	ra,0xffffc
    80006650:	b7c080e7          	jalr	-1156(ra) # 800021c8 <sleep>
  while (b->disk == 1)
    80006654:	004aa783          	lw	a5,4(s5)
    80006658:	fe9788e3          	beq	a5,s1,80006648 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000665c:	f8042903          	lw	s2,-128(s0)
    80006660:	00290713          	addi	a4,s2,2
    80006664:	0712                	slli	a4,a4,0x4
    80006666:	0001d797          	auipc	a5,0x1d
    8000666a:	e0a78793          	addi	a5,a5,-502 # 80023470 <disk>
    8000666e:	97ba                	add	a5,a5,a4
    80006670:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006674:	0001d997          	auipc	s3,0x1d
    80006678:	dfc98993          	addi	s3,s3,-516 # 80023470 <disk>
    8000667c:	00491713          	slli	a4,s2,0x4
    80006680:	0009b783          	ld	a5,0(s3)
    80006684:	97ba                	add	a5,a5,a4
    80006686:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000668a:	854a                	mv	a0,s2
    8000668c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006690:	00000097          	auipc	ra,0x0
    80006694:	b9c080e7          	jalr	-1124(ra) # 8000622c <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80006698:	8885                	andi	s1,s1,1
    8000669a:	f0ed                	bnez	s1,8000667c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000669c:	0001d517          	auipc	a0,0x1d
    800066a0:	efc50513          	addi	a0,a0,-260 # 80023598 <disk+0x128>
    800066a4:	ffffa097          	auipc	ra,0xffffa
    800066a8:	5e6080e7          	jalr	1510(ra) # 80000c8a <release>
}
    800066ac:	70e6                	ld	ra,120(sp)
    800066ae:	7446                	ld	s0,112(sp)
    800066b0:	74a6                	ld	s1,104(sp)
    800066b2:	7906                	ld	s2,96(sp)
    800066b4:	69e6                	ld	s3,88(sp)
    800066b6:	6a46                	ld	s4,80(sp)
    800066b8:	6aa6                	ld	s5,72(sp)
    800066ba:	6b06                	ld	s6,64(sp)
    800066bc:	7be2                	ld	s7,56(sp)
    800066be:	7c42                	ld	s8,48(sp)
    800066c0:	7ca2                	ld	s9,40(sp)
    800066c2:	7d02                	ld	s10,32(sp)
    800066c4:	6de2                	ld	s11,24(sp)
    800066c6:	6109                	addi	sp,sp,128
    800066c8:	8082                	ret

00000000800066ca <virtio_disk_intr>:

void virtio_disk_intr()
{
    800066ca:	1101                	addi	sp,sp,-32
    800066cc:	ec06                	sd	ra,24(sp)
    800066ce:	e822                	sd	s0,16(sp)
    800066d0:	e426                	sd	s1,8(sp)
    800066d2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066d4:	0001d497          	auipc	s1,0x1d
    800066d8:	d9c48493          	addi	s1,s1,-612 # 80023470 <disk>
    800066dc:	0001d517          	auipc	a0,0x1d
    800066e0:	ebc50513          	addi	a0,a0,-324 # 80023598 <disk+0x128>
    800066e4:	ffffa097          	auipc	ra,0xffffa
    800066e8:	4f2080e7          	jalr	1266(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066ec:	10001737          	lui	a4,0x10001
    800066f0:	533c                	lw	a5,96(a4)
    800066f2:	8b8d                	andi	a5,a5,3
    800066f4:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066f6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx)
    800066fa:	689c                	ld	a5,16(s1)
    800066fc:	0204d703          	lhu	a4,32(s1)
    80006700:	0027d783          	lhu	a5,2(a5)
    80006704:	04f70863          	beq	a4,a5,80006754 <virtio_disk_intr+0x8a>
  {
    __sync_synchronize();
    80006708:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000670c:	6898                	ld	a4,16(s1)
    8000670e:	0204d783          	lhu	a5,32(s1)
    80006712:	8b9d                	andi	a5,a5,7
    80006714:	078e                	slli	a5,a5,0x3
    80006716:	97ba                	add	a5,a5,a4
    80006718:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    8000671a:	00278713          	addi	a4,a5,2
    8000671e:	0712                	slli	a4,a4,0x4
    80006720:	9726                	add	a4,a4,s1
    80006722:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006726:	e721                	bnez	a4,8000676e <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006728:	0789                	addi	a5,a5,2
    8000672a:	0792                	slli	a5,a5,0x4
    8000672c:	97a6                	add	a5,a5,s1
    8000672e:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80006730:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006734:	ffffc097          	auipc	ra,0xffffc
    80006738:	af8080e7          	jalr	-1288(ra) # 8000222c <wakeup>

    disk.used_idx += 1;
    8000673c:	0204d783          	lhu	a5,32(s1)
    80006740:	2785                	addiw	a5,a5,1
    80006742:	17c2                	slli	a5,a5,0x30
    80006744:	93c1                	srli	a5,a5,0x30
    80006746:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx)
    8000674a:	6898                	ld	a4,16(s1)
    8000674c:	00275703          	lhu	a4,2(a4)
    80006750:	faf71ce3          	bne	a4,a5,80006708 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006754:	0001d517          	auipc	a0,0x1d
    80006758:	e4450513          	addi	a0,a0,-444 # 80023598 <disk+0x128>
    8000675c:	ffffa097          	auipc	ra,0xffffa
    80006760:	52e080e7          	jalr	1326(ra) # 80000c8a <release>
}
    80006764:	60e2                	ld	ra,24(sp)
    80006766:	6442                	ld	s0,16(sp)
    80006768:	64a2                	ld	s1,8(sp)
    8000676a:	6105                	addi	sp,sp,32
    8000676c:	8082                	ret
      panic("virtio_disk_intr status");
    8000676e:	00002517          	auipc	a0,0x2
    80006772:	0e250513          	addi	a0,a0,226 # 80008850 <syscalls+0x400>
    80006776:	ffffa097          	auipc	ra,0xffffa
    8000677a:	dca080e7          	jalr	-566(ra) # 80000540 <panic>
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
