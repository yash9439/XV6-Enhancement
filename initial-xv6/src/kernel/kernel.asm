
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b1013103          	ld	sp,-1264(sp) # 80008b10 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	b2070713          	addi	a4,a4,-1248 # 80008b70 <timer_scratch>
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
    80000066:	2ee78793          	addi	a5,a5,750 # 80006350 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdb925f>
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
    8000012e:	7c6080e7          	jalr	1990(ra) # 800028f0 <either_copyin>
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
    8000018e:	b2650513          	addi	a0,a0,-1242 # 80010cb0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	bb8080e7          	jalr	-1096(ra) # 80000d4a <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	b1648493          	addi	s1,s1,-1258 # 80010cb0 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	ba690913          	addi	s2,s2,-1114 # 80010d48 <cons+0x98>
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
    800001c4:	99c080e7          	jalr	-1636(ra) # 80001b5c <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	572080e7          	jalr	1394(ra) # 8000273a <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	138080e7          	jalr	312(ra) # 8000230e <sleep>
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
    80000216:	688080e7          	jalr	1672(ra) # 8000289a <either_copyout>
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
    8000022a:	a8a50513          	addi	a0,a0,-1398 # 80010cb0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	bd0080e7          	jalr	-1072(ra) # 80000dfe <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	a7450513          	addi	a0,a0,-1420 # 80010cb0 <cons>
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
    80000276:	acf72b23          	sw	a5,-1322(a4) # 80010d48 <cons+0x98>
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
    800002d0:	9e450513          	addi	a0,a0,-1564 # 80010cb0 <cons>
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
    800002f6:	654080e7          	jalr	1620(ra) # 80002946 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	9b650513          	addi	a0,a0,-1610 # 80010cb0 <cons>
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
    80000322:	99270713          	addi	a4,a4,-1646 # 80010cb0 <cons>
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
    8000034c:	96878793          	addi	a5,a5,-1688 # 80010cb0 <cons>
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
    8000037a:	9d27a783          	lw	a5,-1582(a5) # 80010d48 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	92670713          	addi	a4,a4,-1754 # 80010cb0 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	91648493          	addi	s1,s1,-1770 # 80010cb0 <cons>
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
    800003da:	8da70713          	addi	a4,a4,-1830 # 80010cb0 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	96f72223          	sw	a5,-1692(a4) # 80010d50 <cons+0xa0>
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
    80000416:	89e78793          	addi	a5,a5,-1890 # 80010cb0 <cons>
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
    8000043a:	90c7ab23          	sw	a2,-1770(a5) # 80010d4c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	90a50513          	addi	a0,a0,-1782 # 80010d48 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	084080e7          	jalr	132(ra) # 800024ca <wakeup>
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
    80000464:	85050513          	addi	a0,a0,-1968 # 80010cb0 <cons>
    80000468:	00001097          	auipc	ra,0x1
    8000046c:	852080e7          	jalr	-1966(ra) # 80000cba <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00243797          	auipc	a5,0x243
    8000047c:	c1078793          	addi	a5,a5,-1008 # 80243088 <devsw>
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
    80000550:	8207a223          	sw	zero,-2012(a5) # 80010d70 <pr+0x18>
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
    80000584:	5af72823          	sw	a5,1456(a4) # 80008b30 <panicked>
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
    800005c0:	7b4dad83          	lw	s11,1972(s11) # 80010d70 <pr+0x18>
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
    800005fe:	75e50513          	addi	a0,a0,1886 # 80010d58 <pr>
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
    8000075c:	60050513          	addi	a0,a0,1536 # 80010d58 <pr>
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
    80000778:	5e448493          	addi	s1,s1,1508 # 80010d58 <pr>
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
    800007d8:	5a450513          	addi	a0,a0,1444 # 80010d78 <uart_tx_lock>
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
    80000804:	3307a783          	lw	a5,816(a5) # 80008b30 <panicked>
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
    8000083c:	3007b783          	ld	a5,768(a5) # 80008b38 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	30073703          	ld	a4,768(a4) # 80008b40 <uart_tx_w>
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
    80000866:	516a0a13          	addi	s4,s4,1302 # 80010d78 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	2ce48493          	addi	s1,s1,718 # 80008b38 <uart_tx_r>
    if (uart_tx_w == uart_tx_r)
    80000872:	00008997          	auipc	s3,0x8
    80000876:	2ce98993          	addi	s3,s3,718 # 80008b40 <uart_tx_w>
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
    80000898:	c36080e7          	jalr	-970(ra) # 800024ca <wakeup>

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
    800008d4:	4a850513          	addi	a0,a0,1192 # 80010d78 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	472080e7          	jalr	1138(ra) # 80000d4a <acquire>
  if (panicked)
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	2507a783          	lw	a5,592(a5) # 80008b30 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	25673703          	ld	a4,598(a4) # 80008b40 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	2467b783          	ld	a5,582(a5) # 80008b38 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	47a98993          	addi	s3,s3,1146 # 80010d78 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	23248493          	addi	s1,s1,562 # 80008b38 <uart_tx_r>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	23290913          	addi	s2,s2,562 # 80008b40 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	9f0080e7          	jalr	-1552(ra) # 8000230e <sleep>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	44448493          	addi	s1,s1,1092 # 80010d78 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	1ee7bc23          	sd	a4,504(a5) # 80008b40 <uart_tx_w>
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
    800009be:	3be48493          	addi	s1,s1,958 # 80010d78 <uart_tx_lock>
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
    800009f8:	3dc50513          	addi	a0,a0,988 # 80010dd0 <page_ref>
    800009fc:	00000097          	auipc	ra,0x0
    80000a00:	34e080e7          	jalr	846(ra) # 80000d4a <acquire>
  if (page_ref.count[(uint64)pa >> 12] <= 0)
    80000a04:	00c4d513          	srli	a0,s1,0xc
    80000a08:	00450713          	addi	a4,a0,4
    80000a0c:	070a                	slli	a4,a4,0x2
    80000a0e:	00010797          	auipc	a5,0x10
    80000a12:	3c278793          	addi	a5,a5,962 # 80010dd0 <page_ref>
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
    80000a2c:	3a870713          	addi	a4,a4,936 # 80010dd0 <page_ref>
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
    80000a3c:	39850513          	addi	a0,a0,920 # 80010dd0 <page_ref>
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
    80000a68:	36c50513          	addi	a0,a0,876 # 80010dd0 <page_ref>
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
    80000a90:	b1478793          	addi	a5,a5,-1260 # 802455a0 <end>
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
    80000ad8:	2dc90913          	addi	s2,s2,732 # 80010db0 <kmem>
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
    80000b0c:	2c850513          	addi	a0,a0,712 # 80010dd0 <page_ref>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	23a080e7          	jalr	570(ra) # 80000d4a <acquire>
  if (page_ref.count[(uint64)pa >> 12] < 0)
    80000b18:	00c4d793          	srli	a5,s1,0xc
    80000b1c:	00478693          	addi	a3,a5,4
    80000b20:	068a                	slli	a3,a3,0x2
    80000b22:	00010717          	auipc	a4,0x10
    80000b26:	2ae70713          	addi	a4,a4,686 # 80010dd0 <page_ref>
    80000b2a:	9736                	add	a4,a4,a3
    80000b2c:	4718                	lw	a4,8(a4)
    80000b2e:	02074463          	bltz	a4,80000b56 <increase_pgreference+0x5a>
  {
    panic("increase_pgreference");
  }
  page_ref.count[(uint64)pa >> 12]++;
    80000b32:	00010517          	auipc	a0,0x10
    80000b36:	29e50513          	addi	a0,a0,670 # 80010dd0 <page_ref>
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
    80000bd6:	1fe50513          	addi	a0,a0,510 # 80010dd0 <page_ref>
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	0e0080e7          	jalr	224(ra) # 80000cba <initlock>
  acquire(&page_ref.lock);
    80000be2:	00010517          	auipc	a0,0x10
    80000be6:	1ee50513          	addi	a0,a0,494 # 80010dd0 <page_ref>
    80000bea:	00000097          	auipc	ra,0x0
    80000bee:	160080e7          	jalr	352(ra) # 80000d4a <acquire>
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000bf2:	00010797          	auipc	a5,0x10
    80000bf6:	1f678793          	addi	a5,a5,502 # 80010de8 <page_ref+0x18>
    80000bfa:	00230717          	auipc	a4,0x230
    80000bfe:	1ee70713          	addi	a4,a4,494 # 80230de8 <pid_lock>
    page_ref.count[i] = 0;
    80000c02:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000c06:	0791                	addi	a5,a5,4
    80000c08:	fee79de3          	bne	a5,a4,80000c02 <kinit+0x40>
  release(&page_ref.lock);
    80000c0c:	00010517          	auipc	a0,0x10
    80000c10:	1c450513          	addi	a0,a0,452 # 80010dd0 <page_ref>
    80000c14:	00000097          	auipc	ra,0x0
    80000c18:	1ea080e7          	jalr	490(ra) # 80000dfe <release>
  initlock(&kmem.lock, "kmem");
    80000c1c:	00007597          	auipc	a1,0x7
    80000c20:	48c58593          	addi	a1,a1,1164 # 800080a8 <digits+0x68>
    80000c24:	00010517          	auipc	a0,0x10
    80000c28:	18c50513          	addi	a0,a0,396 # 80010db0 <kmem>
    80000c2c:	00000097          	auipc	ra,0x0
    80000c30:	08e080e7          	jalr	142(ra) # 80000cba <initlock>
  freerange(end, (void *)PHYSTOP);
    80000c34:	45c5                	li	a1,17
    80000c36:	05ee                	slli	a1,a1,0x1b
    80000c38:	00245517          	auipc	a0,0x245
    80000c3c:	96850513          	addi	a0,a0,-1688 # 802455a0 <end>
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
    80000c5e:	15648493          	addi	s1,s1,342 # 80010db0 <kmem>
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
    80000c76:	13e50513          	addi	a0,a0,318 # 80010db0 <kmem>
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
    80000cac:	10850513          	addi	a0,a0,264 # 80010db0 <kmem>
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
    80000ce8:	e5c080e7          	jalr	-420(ra) # 80001b40 <mycpu>
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
    80000d1a:	e2a080e7          	jalr	-470(ra) # 80001b40 <mycpu>
    80000d1e:	5d3c                	lw	a5,120(a0)
    80000d20:	cf89                	beqz	a5,80000d3a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d22:	00001097          	auipc	ra,0x1
    80000d26:	e1e080e7          	jalr	-482(ra) # 80001b40 <mycpu>
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
    80000d3e:	e06080e7          	jalr	-506(ra) # 80001b40 <mycpu>
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
    80000d7e:	dc6080e7          	jalr	-570(ra) # 80001b40 <mycpu>
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
    80000daa:	d9a080e7          	jalr	-614(ra) # 80001b40 <mycpu>
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
    80000ff8:	b3c080e7          	jalr	-1220(ra) # 80001b30 <cpuid>
    __sync_synchronize();
    started = 1;
  }
  else
  {
    while (started == 0)
    80000ffc:	00008717          	auipc	a4,0x8
    80001000:	b4c70713          	addi	a4,a4,-1204 # 80008b48 <started>
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
    80001014:	b20080e7          	jalr	-1248(ra) # 80001b30 <cpuid>
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
    80001036:	a5e080e7          	jalr	-1442(ra) # 80002a90 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    8000103a:	00005097          	auipc	ra,0x5
    8000103e:	356080e7          	jalr	854(ra) # 80006390 <plicinithart>
  }

  scheduler();
    80001042:	00001097          	auipc	ra,0x1
    80001046:	11a080e7          	jalr	282(ra) # 8000215c <scheduler>
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
    800010a6:	9da080e7          	jalr	-1574(ra) # 80001a7c <procinit>
    trapinit();         // trap vectors
    800010aa:	00002097          	auipc	ra,0x2
    800010ae:	9be080e7          	jalr	-1602(ra) # 80002a68 <trapinit>
    trapinithart();     // install kernel trap vector
    800010b2:	00002097          	auipc	ra,0x2
    800010b6:	9de080e7          	jalr	-1570(ra) # 80002a90 <trapinithart>
    plicinit();         // set up interrupt controller
    800010ba:	00005097          	auipc	ra,0x5
    800010be:	2c0080e7          	jalr	704(ra) # 8000637a <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    800010c2:	00005097          	auipc	ra,0x5
    800010c6:	2ce080e7          	jalr	718(ra) # 80006390 <plicinithart>
    binit();            // buffer cache
    800010ca:	00002097          	auipc	ra,0x2
    800010ce:	464080e7          	jalr	1124(ra) # 8000352e <binit>
    iinit();            // inode table
    800010d2:	00003097          	auipc	ra,0x3
    800010d6:	b04080e7          	jalr	-1276(ra) # 80003bd6 <iinit>
    fileinit();         // file table
    800010da:	00004097          	auipc	ra,0x4
    800010de:	aaa080e7          	jalr	-1366(ra) # 80004b84 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010e2:	00005097          	auipc	ra,0x5
    800010e6:	68a080e7          	jalr	1674(ra) # 8000676c <virtio_disk_init>
    userinit();         // first user process
    800010ea:	00001097          	auipc	ra,0x1
    800010ee:	dde080e7          	jalr	-546(ra) # 80001ec8 <userinit>
    __sync_synchronize();
    800010f2:	0ff0000f          	fence
    started = 1;
    800010f6:	4785                	li	a5,1
    800010f8:	00008717          	auipc	a4,0x8
    800010fc:	a4f72823          	sw	a5,-1456(a4) # 80008b48 <started>
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
    80001110:	a447b783          	ld	a5,-1468(a5) # 80008b50 <kernel_pagetable>
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
    800013a6:	644080e7          	jalr	1604(ra) # 800019e6 <proc_mapstacks>
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
    800013cc:	78a7b423          	sd	a0,1928(a5) # 80008b50 <kernel_pagetable>
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

00000000800016dc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE)
    800016dc:	c679                	beqz	a2,800017aa <uvmcopy+0xce>
{
    800016de:	715d                	addi	sp,sp,-80
    800016e0:	e486                	sd	ra,72(sp)
    800016e2:	e0a2                	sd	s0,64(sp)
    800016e4:	fc26                	sd	s1,56(sp)
    800016e6:	f84a                	sd	s2,48(sp)
    800016e8:	f44e                	sd	s3,40(sp)
    800016ea:	f052                	sd	s4,32(sp)
    800016ec:	ec56                	sd	s5,24(sp)
    800016ee:	e85a                	sd	s6,16(sp)
    800016f0:	e45e                	sd	s7,8(sp)
    800016f2:	0880                	addi	s0,sp,80
    800016f4:	8b2a                	mv	s6,a0
    800016f6:	8aae                	mv	s5,a1
    800016f8:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE)
    800016fa:	4981                	li	s3,0
  {
    if ((pte = walk(old, i, 0)) == 0)
    800016fc:	4601                	li	a2,0
    800016fe:	85ce                	mv	a1,s3
    80001700:	855a                	mv	a0,s6
    80001702:	00000097          	auipc	ra,0x0
    80001706:	a28080e7          	jalr	-1496(ra) # 8000112a <walk>
    8000170a:	c531                	beqz	a0,80001756 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    8000170c:	6118                	ld	a4,0(a0)
    8000170e:	00177793          	andi	a5,a4,1
    80001712:	cbb1                	beqz	a5,80001766 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001714:	00a75593          	srli	a1,a4,0xa
    80001718:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000171c:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80001720:	fffff097          	auipc	ra,0xfffff
    80001724:	530080e7          	jalr	1328(ra) # 80000c50 <kalloc>
    80001728:	892a                	mv	s2,a0
    8000172a:	c939                	beqz	a0,80001780 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    8000172c:	6605                	lui	a2,0x1
    8000172e:	85de                	mv	a1,s7
    80001730:	fffff097          	auipc	ra,0xfffff
    80001734:	772080e7          	jalr	1906(ra) # 80000ea2 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80001738:	8726                	mv	a4,s1
    8000173a:	86ca                	mv	a3,s2
    8000173c:	6605                	lui	a2,0x1
    8000173e:	85ce                	mv	a1,s3
    80001740:	8556                	mv	a0,s5
    80001742:	00000097          	auipc	ra,0x0
    80001746:	ad0080e7          	jalr	-1328(ra) # 80001212 <mappages>
    8000174a:	e515                	bnez	a0,80001776 <uvmcopy+0x9a>
  for (i = 0; i < sz; i += PGSIZE)
    8000174c:	6785                	lui	a5,0x1
    8000174e:	99be                	add	s3,s3,a5
    80001750:	fb49e6e3          	bltu	s3,s4,800016fc <uvmcopy+0x20>
    80001754:	a081                	j	80001794 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001756:	00007517          	auipc	a0,0x7
    8000175a:	a7250513          	addi	a0,a0,-1422 # 800081c8 <digits+0x188>
    8000175e:	fffff097          	auipc	ra,0xfffff
    80001762:	de2080e7          	jalr	-542(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    80001766:	00007517          	auipc	a0,0x7
    8000176a:	a8250513          	addi	a0,a0,-1406 # 800081e8 <digits+0x1a8>
    8000176e:	fffff097          	auipc	ra,0xfffff
    80001772:	dd2080e7          	jalr	-558(ra) # 80000540 <panic>
    {
      kfree(mem);
    80001776:	854a                	mv	a0,s2
    80001778:	fffff097          	auipc	ra,0xfffff
    8000177c:	300080e7          	jalr	768(ra) # 80000a78 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001780:	4685                	li	a3,1
    80001782:	00c9d613          	srli	a2,s3,0xc
    80001786:	4581                	li	a1,0
    80001788:	8556                	mv	a0,s5
    8000178a:	00000097          	auipc	ra,0x0
    8000178e:	c4e080e7          	jalr	-946(ra) # 800013d8 <uvmunmap>
  return -1;
    80001792:	557d                	li	a0,-1
}
    80001794:	60a6                	ld	ra,72(sp)
    80001796:	6406                	ld	s0,64(sp)
    80001798:	74e2                	ld	s1,56(sp)
    8000179a:	7942                	ld	s2,48(sp)
    8000179c:	79a2                	ld	s3,40(sp)
    8000179e:	7a02                	ld	s4,32(sp)
    800017a0:	6ae2                	ld	s5,24(sp)
    800017a2:	6b42                	ld	s6,16(sp)
    800017a4:	6ba2                	ld	s7,8(sp)
    800017a6:	6161                	addi	sp,sp,80
    800017a8:	8082                	ret
  return 0;
    800017aa:	4501                	li	a0,0
}
    800017ac:	8082                	ret

00000000800017ae <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    800017ae:	1141                	addi	sp,sp,-16
    800017b0:	e406                	sd	ra,8(sp)
    800017b2:	e022                	sd	s0,0(sp)
    800017b4:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800017b6:	4601                	li	a2,0
    800017b8:	00000097          	auipc	ra,0x0
    800017bc:	972080e7          	jalr	-1678(ra) # 8000112a <walk>
  if (pte == 0)
    800017c0:	c901                	beqz	a0,800017d0 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017c2:	611c                	ld	a5,0(a0)
    800017c4:	9bbd                	andi	a5,a5,-17
    800017c6:	e11c                	sd	a5,0(a0)
}
    800017c8:	60a2                	ld	ra,8(sp)
    800017ca:	6402                	ld	s0,0(sp)
    800017cc:	0141                	addi	sp,sp,16
    800017ce:	8082                	ret
    panic("uvmclear");
    800017d0:	00007517          	auipc	a0,0x7
    800017d4:	a3850513          	addi	a0,a0,-1480 # 80008208 <digits+0x1c8>
    800017d8:	fffff097          	auipc	ra,0xfffff
    800017dc:	d68080e7          	jalr	-664(ra) # 80000540 <panic>

00000000800017e0 <copyout>:
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    800017e0:	c6c5                	beqz	a3,80001888 <copyout+0xa8>
{
    800017e2:	711d                	addi	sp,sp,-96
    800017e4:	ec86                	sd	ra,88(sp)
    800017e6:	e8a2                	sd	s0,80(sp)
    800017e8:	e4a6                	sd	s1,72(sp)
    800017ea:	e0ca                	sd	s2,64(sp)
    800017ec:	fc4e                	sd	s3,56(sp)
    800017ee:	f852                	sd	s4,48(sp)
    800017f0:	f456                	sd	s5,40(sp)
    800017f2:	f05a                	sd	s6,32(sp)
    800017f4:	ec5e                	sd	s7,24(sp)
    800017f6:	e862                	sd	s8,16(sp)
    800017f8:	e466                	sd	s9,8(sp)
    800017fa:	1080                	addi	s0,sp,96
    800017fc:	8baa                	mv	s7,a0
    800017fe:	8a2e                	mv	s4,a1
    80001800:	8b32                	mv	s6,a2
    80001802:	8ab6                	mv	s5,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80001804:	7cfd                	lui	s9,0xfffff
    }

    if (pa0 == 0)
      return -1;

    n = PGSIZE - (dstva - va0);
    80001806:	6c05                	lui	s8,0x1
    80001808:	a091                	j	8000184c <copyout+0x6c>
      pgfault(va0, pagetable);
    8000180a:	85de                	mv	a1,s7
    8000180c:	854a                	mv	a0,s2
    8000180e:	00001097          	auipc	ra,0x1
    80001812:	522080e7          	jalr	1314(ra) # 80002d30 <pgfault>
      pa0 = walkaddr(pagetable, va0);
    80001816:	85ca                	mv	a1,s2
    80001818:	855e                	mv	a0,s7
    8000181a:	00000097          	auipc	ra,0x0
    8000181e:	9b6080e7          	jalr	-1610(ra) # 800011d0 <walkaddr>
    80001822:	89aa                	mv	s3,a0
    if (pa0 == 0)
    80001824:	e929                	bnez	a0,80001876 <copyout+0x96>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	a09d                	j	8000188e <copyout+0xae>
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000182a:	412a0533          	sub	a0,s4,s2
    8000182e:	0004861b          	sext.w	a2,s1
    80001832:	85da                	mv	a1,s6
    80001834:	954e                	add	a0,a0,s3
    80001836:	fffff097          	auipc	ra,0xfffff
    8000183a:	66c080e7          	jalr	1644(ra) # 80000ea2 <memmove>

    len -= n;
    8000183e:	409a8ab3          	sub	s5,s5,s1
    src += n;
    80001842:	9b26                	add	s6,s6,s1
    dstva = va0 + PGSIZE;
    80001844:	01890a33          	add	s4,s2,s8
  while (len > 0)
    80001848:	020a8e63          	beqz	s5,80001884 <copyout+0xa4>
    va0 = PGROUNDDOWN(dstva);
    8000184c:	019a7933          	and	s2,s4,s9
    pa0 = walkaddr(pagetable, va0);
    80001850:	85ca                	mv	a1,s2
    80001852:	855e                	mv	a0,s7
    80001854:	00000097          	auipc	ra,0x0
    80001858:	97c080e7          	jalr	-1668(ra) # 800011d0 <walkaddr>
    8000185c:	89aa                	mv	s3,a0
    if (pa0 == 0)
    8000185e:	c51d                	beqz	a0,8000188c <copyout+0xac>
    if (PTE_FLAGS(*(walk(pagetable, va0, 0))) & PTE_C)
    80001860:	4601                	li	a2,0
    80001862:	85ca                	mv	a1,s2
    80001864:	855e                	mv	a0,s7
    80001866:	00000097          	auipc	ra,0x0
    8000186a:	8c4080e7          	jalr	-1852(ra) # 8000112a <walk>
    8000186e:	611c                	ld	a5,0(a0)
    80001870:	1007f793          	andi	a5,a5,256
    80001874:	fbd9                	bnez	a5,8000180a <copyout+0x2a>
    n = PGSIZE - (dstva - va0);
    80001876:	414904b3          	sub	s1,s2,s4
    8000187a:	94e2                	add	s1,s1,s8
    8000187c:	fa9af7e3          	bgeu	s5,s1,8000182a <copyout+0x4a>
    80001880:	84d6                	mv	s1,s5
    80001882:	b765                	j	8000182a <copyout+0x4a>
  }
  return 0;
    80001884:	4501                	li	a0,0
    80001886:	a021                	j	8000188e <copyout+0xae>
    80001888:	4501                	li	a0,0
}
    8000188a:	8082                	ret
      return -1;
    8000188c:	557d                	li	a0,-1
}
    8000188e:	60e6                	ld	ra,88(sp)
    80001890:	6446                	ld	s0,80(sp)
    80001892:	64a6                	ld	s1,72(sp)
    80001894:	6906                	ld	s2,64(sp)
    80001896:	79e2                	ld	s3,56(sp)
    80001898:	7a42                	ld	s4,48(sp)
    8000189a:	7aa2                	ld	s5,40(sp)
    8000189c:	7b02                	ld	s6,32(sp)
    8000189e:	6be2                	ld	s7,24(sp)
    800018a0:	6c42                	ld	s8,16(sp)
    800018a2:	6ca2                	ld	s9,8(sp)
    800018a4:	6125                	addi	sp,sp,96
    800018a6:	8082                	ret

00000000800018a8 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    800018a8:	caa5                	beqz	a3,80001918 <copyin+0x70>
{
    800018aa:	715d                	addi	sp,sp,-80
    800018ac:	e486                	sd	ra,72(sp)
    800018ae:	e0a2                	sd	s0,64(sp)
    800018b0:	fc26                	sd	s1,56(sp)
    800018b2:	f84a                	sd	s2,48(sp)
    800018b4:	f44e                	sd	s3,40(sp)
    800018b6:	f052                	sd	s4,32(sp)
    800018b8:	ec56                	sd	s5,24(sp)
    800018ba:	e85a                	sd	s6,16(sp)
    800018bc:	e45e                	sd	s7,8(sp)
    800018be:	e062                	sd	s8,0(sp)
    800018c0:	0880                	addi	s0,sp,80
    800018c2:	8b2a                	mv	s6,a0
    800018c4:	8a2e                	mv	s4,a1
    800018c6:	8c32                	mv	s8,a2
    800018c8:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    800018ca:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018cc:	6a85                	lui	s5,0x1
    800018ce:	a01d                	j	800018f4 <copyin+0x4c>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018d0:	018505b3          	add	a1,a0,s8
    800018d4:	0004861b          	sext.w	a2,s1
    800018d8:	412585b3          	sub	a1,a1,s2
    800018dc:	8552                	mv	a0,s4
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	5c4080e7          	jalr	1476(ra) # 80000ea2 <memmove>

    len -= n;
    800018e6:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018ea:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018ec:	01590c33          	add	s8,s2,s5
  while (len > 0)
    800018f0:	02098263          	beqz	s3,80001914 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018f4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018f8:	85ca                	mv	a1,s2
    800018fa:	855a                	mv	a0,s6
    800018fc:	00000097          	auipc	ra,0x0
    80001900:	8d4080e7          	jalr	-1836(ra) # 800011d0 <walkaddr>
    if (pa0 == 0)
    80001904:	cd01                	beqz	a0,8000191c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001906:	418904b3          	sub	s1,s2,s8
    8000190a:	94d6                	add	s1,s1,s5
    8000190c:	fc99f2e3          	bgeu	s3,s1,800018d0 <copyin+0x28>
    80001910:	84ce                	mv	s1,s3
    80001912:	bf7d                	j	800018d0 <copyin+0x28>
  }
  return 0;
    80001914:	4501                	li	a0,0
    80001916:	a021                	j	8000191e <copyin+0x76>
    80001918:	4501                	li	a0,0
}
    8000191a:	8082                	ret
      return -1;
    8000191c:	557d                	li	a0,-1
}
    8000191e:	60a6                	ld	ra,72(sp)
    80001920:	6406                	ld	s0,64(sp)
    80001922:	74e2                	ld	s1,56(sp)
    80001924:	7942                	ld	s2,48(sp)
    80001926:	79a2                	ld	s3,40(sp)
    80001928:	7a02                	ld	s4,32(sp)
    8000192a:	6ae2                	ld	s5,24(sp)
    8000192c:	6b42                	ld	s6,16(sp)
    8000192e:	6ba2                	ld	s7,8(sp)
    80001930:	6c02                	ld	s8,0(sp)
    80001932:	6161                	addi	sp,sp,80
    80001934:	8082                	ret

0000000080001936 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80001936:	c2dd                	beqz	a3,800019dc <copyinstr+0xa6>
{
    80001938:	715d                	addi	sp,sp,-80
    8000193a:	e486                	sd	ra,72(sp)
    8000193c:	e0a2                	sd	s0,64(sp)
    8000193e:	fc26                	sd	s1,56(sp)
    80001940:	f84a                	sd	s2,48(sp)
    80001942:	f44e                	sd	s3,40(sp)
    80001944:	f052                	sd	s4,32(sp)
    80001946:	ec56                	sd	s5,24(sp)
    80001948:	e85a                	sd	s6,16(sp)
    8000194a:	e45e                	sd	s7,8(sp)
    8000194c:	0880                	addi	s0,sp,80
    8000194e:	8a2a                	mv	s4,a0
    80001950:	8b2e                	mv	s6,a1
    80001952:	8bb2                	mv	s7,a2
    80001954:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80001956:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001958:	6985                	lui	s3,0x1
    8000195a:	a02d                	j	80001984 <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    8000195c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001960:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80001962:	37fd                	addiw	a5,a5,-1
    80001964:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    80001968:	60a6                	ld	ra,72(sp)
    8000196a:	6406                	ld	s0,64(sp)
    8000196c:	74e2                	ld	s1,56(sp)
    8000196e:	7942                	ld	s2,48(sp)
    80001970:	79a2                	ld	s3,40(sp)
    80001972:	7a02                	ld	s4,32(sp)
    80001974:	6ae2                	ld	s5,24(sp)
    80001976:	6b42                	ld	s6,16(sp)
    80001978:	6ba2                	ld	s7,8(sp)
    8000197a:	6161                	addi	sp,sp,80
    8000197c:	8082                	ret
    srcva = va0 + PGSIZE;
    8000197e:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80001982:	c8a9                	beqz	s1,800019d4 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001984:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001988:	85ca                	mv	a1,s2
    8000198a:	8552                	mv	a0,s4
    8000198c:	00000097          	auipc	ra,0x0
    80001990:	844080e7          	jalr	-1980(ra) # 800011d0 <walkaddr>
    if (pa0 == 0)
    80001994:	c131                	beqz	a0,800019d8 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001996:	417906b3          	sub	a3,s2,s7
    8000199a:	96ce                	add	a3,a3,s3
    8000199c:	00d4f363          	bgeu	s1,a3,800019a2 <copyinstr+0x6c>
    800019a0:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    800019a2:	955e                	add	a0,a0,s7
    800019a4:	41250533          	sub	a0,a0,s2
    while (n > 0)
    800019a8:	daf9                	beqz	a3,8000197e <copyinstr+0x48>
    800019aa:	87da                	mv	a5,s6
      if (*p == '\0')
    800019ac:	41650633          	sub	a2,a0,s6
    800019b0:	fff48593          	addi	a1,s1,-1
    800019b4:	95da                	add	a1,a1,s6
    while (n > 0)
    800019b6:	96da                	add	a3,a3,s6
      if (*p == '\0')
    800019b8:	00f60733          	add	a4,a2,a5
    800019bc:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fdb9a60>
    800019c0:	df51                	beqz	a4,8000195c <copyinstr+0x26>
        *dst = *p;
    800019c2:	00e78023          	sb	a4,0(a5)
      --max;
    800019c6:	40f584b3          	sub	s1,a1,a5
      dst++;
    800019ca:	0785                	addi	a5,a5,1
    while (n > 0)
    800019cc:	fed796e3          	bne	a5,a3,800019b8 <copyinstr+0x82>
      dst++;
    800019d0:	8b3e                	mv	s6,a5
    800019d2:	b775                	j	8000197e <copyinstr+0x48>
    800019d4:	4781                	li	a5,0
    800019d6:	b771                	j	80001962 <copyinstr+0x2c>
      return -1;
    800019d8:	557d                	li	a0,-1
    800019da:	b779                	j	80001968 <copyinstr+0x32>
  int got_null = 0;
    800019dc:	4781                	li	a5,0
  if (got_null)
    800019de:	37fd                	addiw	a5,a5,-1
    800019e0:	0007851b          	sext.w	a0,a5
}
    800019e4:	8082                	ret

00000000800019e6 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    800019e6:	7139                	addi	sp,sp,-64
    800019e8:	fc06                	sd	ra,56(sp)
    800019ea:	f822                	sd	s0,48(sp)
    800019ec:	f426                	sd	s1,40(sp)
    800019ee:	f04a                	sd	s2,32(sp)
    800019f0:	ec4e                	sd	s3,24(sp)
    800019f2:	e852                	sd	s4,16(sp)
    800019f4:	e456                	sd	s5,8(sp)
    800019f6:	e05a                	sd	s6,0(sp)
    800019f8:	0080                	addi	s0,sp,64
    800019fa:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800019fc:	00230497          	auipc	s1,0x230
    80001a00:	81c48493          	addi	s1,s1,-2020 # 80231218 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001a04:	8b26                	mv	s6,s1
    80001a06:	00006a97          	auipc	s5,0x6
    80001a0a:	5faa8a93          	addi	s5,s5,1530 # 80008000 <etext>
    80001a0e:	04000937          	lui	s2,0x4000
    80001a12:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a14:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a16:	00237a17          	auipc	s4,0x237
    80001a1a:	a02a0a13          	addi	s4,s4,-1534 # 80238418 <mlfq>
    char *pa = kalloc();
    80001a1e:	fffff097          	auipc	ra,0xfffff
    80001a22:	232080e7          	jalr	562(ra) # 80000c50 <kalloc>
    80001a26:	862a                	mv	a2,a0
    if (pa == 0)
    80001a28:	c131                	beqz	a0,80001a6c <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001a2a:	416485b3          	sub	a1,s1,s6
    80001a2e:	858d                	srai	a1,a1,0x3
    80001a30:	000ab783          	ld	a5,0(s5)
    80001a34:	02f585b3          	mul	a1,a1,a5
    80001a38:	2585                	addiw	a1,a1,1
    80001a3a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a3e:	4719                	li	a4,6
    80001a40:	6685                	lui	a3,0x1
    80001a42:	40b905b3          	sub	a1,s2,a1
    80001a46:	854e                	mv	a0,s3
    80001a48:	00000097          	auipc	ra,0x0
    80001a4c:	86a080e7          	jalr	-1942(ra) # 800012b2 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a50:	1c848493          	addi	s1,s1,456
    80001a54:	fd4495e3          	bne	s1,s4,80001a1e <proc_mapstacks+0x38>
  }
}
    80001a58:	70e2                	ld	ra,56(sp)
    80001a5a:	7442                	ld	s0,48(sp)
    80001a5c:	74a2                	ld	s1,40(sp)
    80001a5e:	7902                	ld	s2,32(sp)
    80001a60:	69e2                	ld	s3,24(sp)
    80001a62:	6a42                	ld	s4,16(sp)
    80001a64:	6aa2                	ld	s5,8(sp)
    80001a66:	6b02                	ld	s6,0(sp)
    80001a68:	6121                	addi	sp,sp,64
    80001a6a:	8082                	ret
      panic("kalloc");
    80001a6c:	00006517          	auipc	a0,0x6
    80001a70:	7ac50513          	addi	a0,a0,1964 # 80008218 <digits+0x1d8>
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	acc080e7          	jalr	-1332(ra) # 80000540 <panic>

0000000080001a7c <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001a7c:	7139                	addi	sp,sp,-64
    80001a7e:	fc06                	sd	ra,56(sp)
    80001a80:	f822                	sd	s0,48(sp)
    80001a82:	f426                	sd	s1,40(sp)
    80001a84:	f04a                	sd	s2,32(sp)
    80001a86:	ec4e                	sd	s3,24(sp)
    80001a88:	e852                	sd	s4,16(sp)
    80001a8a:	e456                	sd	s5,8(sp)
    80001a8c:	e05a                	sd	s6,0(sp)
    80001a8e:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001a90:	00006597          	auipc	a1,0x6
    80001a94:	79058593          	addi	a1,a1,1936 # 80008220 <digits+0x1e0>
    80001a98:	0022f517          	auipc	a0,0x22f
    80001a9c:	35050513          	addi	a0,a0,848 # 80230de8 <pid_lock>
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	21a080e7          	jalr	538(ra) # 80000cba <initlock>
  initlock(&wait_lock, "wait_lock");
    80001aa8:	00006597          	auipc	a1,0x6
    80001aac:	78058593          	addi	a1,a1,1920 # 80008228 <digits+0x1e8>
    80001ab0:	0022f517          	auipc	a0,0x22f
    80001ab4:	35050513          	addi	a0,a0,848 # 80230e00 <wait_lock>
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	202080e7          	jalr	514(ra) # 80000cba <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ac0:	0022f497          	auipc	s1,0x22f
    80001ac4:	75848493          	addi	s1,s1,1880 # 80231218 <proc>
  {
    initlock(&p->lock, "proc");
    80001ac8:	00006b17          	auipc	s6,0x6
    80001acc:	770b0b13          	addi	s6,s6,1904 # 80008238 <digits+0x1f8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001ad0:	8aa6                	mv	s5,s1
    80001ad2:	00006a17          	auipc	s4,0x6
    80001ad6:	52ea0a13          	addi	s4,s4,1326 # 80008000 <etext>
    80001ada:	04000937          	lui	s2,0x4000
    80001ade:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001ae0:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001ae2:	00237997          	auipc	s3,0x237
    80001ae6:	93698993          	addi	s3,s3,-1738 # 80238418 <mlfq>
    initlock(&p->lock, "proc");
    80001aea:	85da                	mv	a1,s6
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	1cc080e7          	jalr	460(ra) # 80000cba <initlock>
    p->state = UNUSED;
    80001af6:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001afa:	415487b3          	sub	a5,s1,s5
    80001afe:	878d                	srai	a5,a5,0x3
    80001b00:	000a3703          	ld	a4,0(s4)
    80001b04:	02e787b3          	mul	a5,a5,a4
    80001b08:	2785                	addiw	a5,a5,1
    80001b0a:	00d7979b          	slliw	a5,a5,0xd
    80001b0e:	40f907b3          	sub	a5,s2,a5
    80001b12:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001b14:	1c848493          	addi	s1,s1,456
    80001b18:	fd3499e3          	bne	s1,s3,80001aea <procinit+0x6e>
  }
}
    80001b1c:	70e2                	ld	ra,56(sp)
    80001b1e:	7442                	ld	s0,48(sp)
    80001b20:	74a2                	ld	s1,40(sp)
    80001b22:	7902                	ld	s2,32(sp)
    80001b24:	69e2                	ld	s3,24(sp)
    80001b26:	6a42                	ld	s4,16(sp)
    80001b28:	6aa2                	ld	s5,8(sp)
    80001b2a:	6b02                	ld	s6,0(sp)
    80001b2c:	6121                	addi	sp,sp,64
    80001b2e:	8082                	ret

0000000080001b30 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001b30:	1141                	addi	sp,sp,-16
    80001b32:	e422                	sd	s0,8(sp)
    80001b34:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp"
    80001b36:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b38:	2501                	sext.w	a0,a0
    80001b3a:	6422                	ld	s0,8(sp)
    80001b3c:	0141                	addi	sp,sp,16
    80001b3e:	8082                	ret

0000000080001b40 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001b40:	1141                	addi	sp,sp,-16
    80001b42:	e422                	sd	s0,8(sp)
    80001b44:	0800                	addi	s0,sp,16
    80001b46:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b48:	2781                	sext.w	a5,a5
    80001b4a:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b4c:	0022f517          	auipc	a0,0x22f
    80001b50:	2cc50513          	addi	a0,a0,716 # 80230e18 <cpus>
    80001b54:	953e                	add	a0,a0,a5
    80001b56:	6422                	ld	s0,8(sp)
    80001b58:	0141                	addi	sp,sp,16
    80001b5a:	8082                	ret

0000000080001b5c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001b5c:	1101                	addi	sp,sp,-32
    80001b5e:	ec06                	sd	ra,24(sp)
    80001b60:	e822                	sd	s0,16(sp)
    80001b62:	e426                	sd	s1,8(sp)
    80001b64:	1000                	addi	s0,sp,32
  push_off();
    80001b66:	fffff097          	auipc	ra,0xfffff
    80001b6a:	198080e7          	jalr	408(ra) # 80000cfe <push_off>
    80001b6e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b70:	2781                	sext.w	a5,a5
    80001b72:	079e                	slli	a5,a5,0x7
    80001b74:	0022f717          	auipc	a4,0x22f
    80001b78:	27470713          	addi	a4,a4,628 # 80230de8 <pid_lock>
    80001b7c:	97ba                	add	a5,a5,a4
    80001b7e:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b80:	fffff097          	auipc	ra,0xfffff
    80001b84:	21e080e7          	jalr	542(ra) # 80000d9e <pop_off>
  return p;
}
    80001b88:	8526                	mv	a0,s1
    80001b8a:	60e2                	ld	ra,24(sp)
    80001b8c:	6442                	ld	s0,16(sp)
    80001b8e:	64a2                	ld	s1,8(sp)
    80001b90:	6105                	addi	sp,sp,32
    80001b92:	8082                	ret

0000000080001b94 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b94:	1141                	addi	sp,sp,-16
    80001b96:	e406                	sd	ra,8(sp)
    80001b98:	e022                	sd	s0,0(sp)
    80001b9a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b9c:	00000097          	auipc	ra,0x0
    80001ba0:	fc0080e7          	jalr	-64(ra) # 80001b5c <myproc>
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	25a080e7          	jalr	602(ra) # 80000dfe <release>

  if (first)
    80001bac:	00007797          	auipc	a5,0x7
    80001bb0:	e447a783          	lw	a5,-444(a5) # 800089f0 <first.1>
    80001bb4:	eb89                	bnez	a5,80001bc6 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001bb6:	00001097          	auipc	ra,0x1
    80001bba:	ef2080e7          	jalr	-270(ra) # 80002aa8 <usertrapret>
}
    80001bbe:	60a2                	ld	ra,8(sp)
    80001bc0:	6402                	ld	s0,0(sp)
    80001bc2:	0141                	addi	sp,sp,16
    80001bc4:	8082                	ret
    first = 0;
    80001bc6:	00007797          	auipc	a5,0x7
    80001bca:	e207a523          	sw	zero,-470(a5) # 800089f0 <first.1>
    fsinit(ROOTDEV);
    80001bce:	4505                	li	a0,1
    80001bd0:	00002097          	auipc	ra,0x2
    80001bd4:	f86080e7          	jalr	-122(ra) # 80003b56 <fsinit>
    80001bd8:	bff9                	j	80001bb6 <forkret+0x22>

0000000080001bda <allocpid>:
{
    80001bda:	1101                	addi	sp,sp,-32
    80001bdc:	ec06                	sd	ra,24(sp)
    80001bde:	e822                	sd	s0,16(sp)
    80001be0:	e426                	sd	s1,8(sp)
    80001be2:	e04a                	sd	s2,0(sp)
    80001be4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001be6:	0022f917          	auipc	s2,0x22f
    80001bea:	20290913          	addi	s2,s2,514 # 80230de8 <pid_lock>
    80001bee:	854a                	mv	a0,s2
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	15a080e7          	jalr	346(ra) # 80000d4a <acquire>
  pid = nextpid;
    80001bf8:	00007797          	auipc	a5,0x7
    80001bfc:	dfc78793          	addi	a5,a5,-516 # 800089f4 <nextpid>
    80001c00:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c02:	0014871b          	addiw	a4,s1,1
    80001c06:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c08:	854a                	mv	a0,s2
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	1f4080e7          	jalr	500(ra) # 80000dfe <release>
}
    80001c12:	8526                	mv	a0,s1
    80001c14:	60e2                	ld	ra,24(sp)
    80001c16:	6442                	ld	s0,16(sp)
    80001c18:	64a2                	ld	s1,8(sp)
    80001c1a:	6902                	ld	s2,0(sp)
    80001c1c:	6105                	addi	sp,sp,32
    80001c1e:	8082                	ret

0000000080001c20 <proc_pagetable>:
{
    80001c20:	1101                	addi	sp,sp,-32
    80001c22:	ec06                	sd	ra,24(sp)
    80001c24:	e822                	sd	s0,16(sp)
    80001c26:	e426                	sd	s1,8(sp)
    80001c28:	e04a                	sd	s2,0(sp)
    80001c2a:	1000                	addi	s0,sp,32
    80001c2c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c2e:	00000097          	auipc	ra,0x0
    80001c32:	86e080e7          	jalr	-1938(ra) # 8000149c <uvmcreate>
    80001c36:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001c38:	c121                	beqz	a0,80001c78 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c3a:	4729                	li	a4,10
    80001c3c:	00005697          	auipc	a3,0x5
    80001c40:	3c468693          	addi	a3,a3,964 # 80007000 <_trampoline>
    80001c44:	6605                	lui	a2,0x1
    80001c46:	040005b7          	lui	a1,0x4000
    80001c4a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c4c:	05b2                	slli	a1,a1,0xc
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	5c4080e7          	jalr	1476(ra) # 80001212 <mappages>
    80001c56:	02054863          	bltz	a0,80001c86 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c5a:	4719                	li	a4,6
    80001c5c:	05893683          	ld	a3,88(s2)
    80001c60:	6605                	lui	a2,0x1
    80001c62:	020005b7          	lui	a1,0x2000
    80001c66:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c68:	05b6                	slli	a1,a1,0xd
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	5a6080e7          	jalr	1446(ra) # 80001212 <mappages>
    80001c74:	02054163          	bltz	a0,80001c96 <proc_pagetable+0x76>
}
    80001c78:	8526                	mv	a0,s1
    80001c7a:	60e2                	ld	ra,24(sp)
    80001c7c:	6442                	ld	s0,16(sp)
    80001c7e:	64a2                	ld	s1,8(sp)
    80001c80:	6902                	ld	s2,0(sp)
    80001c82:	6105                	addi	sp,sp,32
    80001c84:	8082                	ret
    uvmfree(pagetable, 0);
    80001c86:	4581                	li	a1,0
    80001c88:	8526                	mv	a0,s1
    80001c8a:	00000097          	auipc	ra,0x0
    80001c8e:	a18080e7          	jalr	-1512(ra) # 800016a2 <uvmfree>
    return 0;
    80001c92:	4481                	li	s1,0
    80001c94:	b7d5                	j	80001c78 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c96:	4681                	li	a3,0
    80001c98:	4605                	li	a2,1
    80001c9a:	040005b7          	lui	a1,0x4000
    80001c9e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ca0:	05b2                	slli	a1,a1,0xc
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	734080e7          	jalr	1844(ra) # 800013d8 <uvmunmap>
    uvmfree(pagetable, 0);
    80001cac:	4581                	li	a1,0
    80001cae:	8526                	mv	a0,s1
    80001cb0:	00000097          	auipc	ra,0x0
    80001cb4:	9f2080e7          	jalr	-1550(ra) # 800016a2 <uvmfree>
    return 0;
    80001cb8:	4481                	li	s1,0
    80001cba:	bf7d                	j	80001c78 <proc_pagetable+0x58>

0000000080001cbc <proc_freepagetable>:
{
    80001cbc:	1101                	addi	sp,sp,-32
    80001cbe:	ec06                	sd	ra,24(sp)
    80001cc0:	e822                	sd	s0,16(sp)
    80001cc2:	e426                	sd	s1,8(sp)
    80001cc4:	e04a                	sd	s2,0(sp)
    80001cc6:	1000                	addi	s0,sp,32
    80001cc8:	84aa                	mv	s1,a0
    80001cca:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ccc:	4681                	li	a3,0
    80001cce:	4605                	li	a2,1
    80001cd0:	040005b7          	lui	a1,0x4000
    80001cd4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cd6:	05b2                	slli	a1,a1,0xc
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	700080e7          	jalr	1792(ra) # 800013d8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ce0:	4681                	li	a3,0
    80001ce2:	4605                	li	a2,1
    80001ce4:	020005b7          	lui	a1,0x2000
    80001ce8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cea:	05b6                	slli	a1,a1,0xd
    80001cec:	8526                	mv	a0,s1
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	6ea080e7          	jalr	1770(ra) # 800013d8 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cf6:	85ca                	mv	a1,s2
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	00000097          	auipc	ra,0x0
    80001cfe:	9a8080e7          	jalr	-1624(ra) # 800016a2 <uvmfree>
}
    80001d02:	60e2                	ld	ra,24(sp)
    80001d04:	6442                	ld	s0,16(sp)
    80001d06:	64a2                	ld	s1,8(sp)
    80001d08:	6902                	ld	s2,0(sp)
    80001d0a:	6105                	addi	sp,sp,32
    80001d0c:	8082                	ret

0000000080001d0e <freeproc>:
{
    80001d0e:	1101                	addi	sp,sp,-32
    80001d10:	ec06                	sd	ra,24(sp)
    80001d12:	e822                	sd	s0,16(sp)
    80001d14:	e426                	sd	s1,8(sp)
    80001d16:	1000                	addi	s0,sp,32
    80001d18:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001d1a:	6d28                	ld	a0,88(a0)
    80001d1c:	c509                	beqz	a0,80001d26 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	d5a080e7          	jalr	-678(ra) # 80000a78 <kfree>
  if (p->alarm_trapframe)
    80001d26:	1b84b503          	ld	a0,440(s1)
    80001d2a:	c509                	beqz	a0,80001d34 <freeproc+0x26>
    kfree((void *)p->alarm_trapframe);
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	d4c080e7          	jalr	-692(ra) # 80000a78 <kfree>
  p->trapframe = 0;
    80001d34:	0404bc23          	sd	zero,88(s1)
  p->alarm_trapframe = 0;
    80001d38:	1a04bc23          	sd	zero,440(s1)
  if (p->pagetable)
    80001d3c:	68a8                	ld	a0,80(s1)
    80001d3e:	c511                	beqz	a0,80001d4a <freeproc+0x3c>
    proc_freepagetable(p->pagetable, p->sz);
    80001d40:	64ac                	ld	a1,72(s1)
    80001d42:	00000097          	auipc	ra,0x0
    80001d46:	f7a080e7          	jalr	-134(ra) # 80001cbc <proc_freepagetable>
  p->pagetable = 0;
    80001d4a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d4e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d52:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d56:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d5a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d5e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d62:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d66:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d6a:	0004ac23          	sw	zero,24(s1)
}
    80001d6e:	60e2                	ld	ra,24(sp)
    80001d70:	6442                	ld	s0,16(sp)
    80001d72:	64a2                	ld	s1,8(sp)
    80001d74:	6105                	addi	sp,sp,32
    80001d76:	8082                	ret

0000000080001d78 <allocproc>:
{
    80001d78:	1101                	addi	sp,sp,-32
    80001d7a:	ec06                	sd	ra,24(sp)
    80001d7c:	e822                	sd	s0,16(sp)
    80001d7e:	e426                	sd	s1,8(sp)
    80001d80:	e04a                	sd	s2,0(sp)
    80001d82:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001d84:	0022f497          	auipc	s1,0x22f
    80001d88:	49448493          	addi	s1,s1,1172 # 80231218 <proc>
    80001d8c:	00236917          	auipc	s2,0x236
    80001d90:	68c90913          	addi	s2,s2,1676 # 80238418 <mlfq>
    acquire(&p->lock);
    80001d94:	8526                	mv	a0,s1
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	fb4080e7          	jalr	-76(ra) # 80000d4a <acquire>
    if (p->state == UNUSED)
    80001d9e:	4c9c                	lw	a5,24(s1)
    80001da0:	cf81                	beqz	a5,80001db8 <allocproc+0x40>
      release(&p->lock);
    80001da2:	8526                	mv	a0,s1
    80001da4:	fffff097          	auipc	ra,0xfffff
    80001da8:	05a080e7          	jalr	90(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001dac:	1c848493          	addi	s1,s1,456
    80001db0:	ff2492e3          	bne	s1,s2,80001d94 <allocproc+0x1c>
  return 0;
    80001db4:	4481                	li	s1,0
    80001db6:	a87d                	j	80001e74 <allocproc+0xfc>
  p->pid = allocpid();
    80001db8:	00000097          	auipc	ra,0x0
    80001dbc:	e22080e7          	jalr	-478(ra) # 80001bda <allocpid>
    80001dc0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001dc2:	4785                	li	a5,1
    80001dc4:	cc9c                	sw	a5,24(s1)
  p->tickets = 1;
    80001dc6:	16f4ac23          	sw	a5,376(s1)
  p->static_priority = 60;
    80001dca:	03c00713          	li	a4,60
    80001dce:	18e4a023          	sw	a4,384(s1)
  p->number_of_times_scheduled = 0;
    80001dd2:	1604ae23          	sw	zero,380(s1)
  p->sleeping_ticks = 0;
    80001dd6:	1804a623          	sw	zero,396(s1)
  p->running_ticks = 0;
    80001dda:	1804a823          	sw	zero,400(s1)
  p->sleep_start = 0;
    80001dde:	1804a223          	sw	zero,388(s1)
  p->reset_niceness = 1;
    80001de2:	18f4a423          	sw	a5,392(s1)
  p->level = 0;
    80001de6:	1804aa23          	sw	zero,404(s1)
  p->change_queue = 1 << p->level;
    80001dea:	18f4ae23          	sw	a5,412(s1)
  p->in_queue = 0;
    80001dee:	1804ac23          	sw	zero,408(s1)
  p->enter_ticks = ticks;
    80001df2:	00007797          	auipc	a5,0x7
    80001df6:	d767a783          	lw	a5,-650(a5) # 80008b68 <ticks>
    80001dfa:	1af4a023          	sw	a5,416(s1)
  p->now_ticks = 0;
    80001dfe:	1a04aa23          	sw	zero,436(s1)
  p->sigalarm_status = 0;
    80001e02:	1c04a023          	sw	zero,448(s1)
  p->interval = 0;
    80001e06:	1a04a823          	sw	zero,432(s1)
  p->handler = -1;
    80001e0a:	57fd                	li	a5,-1
    80001e0c:	1af4b423          	sd	a5,424(s1)
  p->alarm_trapframe = NULL;
    80001e10:	1a04bc23          	sd	zero,440(s1)
  if (forked_process && p->parent)
    80001e14:	00007797          	auipc	a5,0x7
    80001e18:	d447a783          	lw	a5,-700(a5) # 80008b58 <forked_process>
    80001e1c:	e3bd                	bnez	a5,80001e82 <allocproc+0x10a>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e1e:	fffff097          	auipc	ra,0xfffff
    80001e22:	e32080e7          	jalr	-462(ra) # 80000c50 <kalloc>
    80001e26:	892a                	mv	s2,a0
    80001e28:	eca8                	sd	a0,88(s1)
    80001e2a:	c53d                	beqz	a0,80001e98 <allocproc+0x120>
  p->pagetable = proc_pagetable(p);
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	00000097          	auipc	ra,0x0
    80001e32:	df2080e7          	jalr	-526(ra) # 80001c20 <proc_pagetable>
    80001e36:	892a                	mv	s2,a0
    80001e38:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001e3a:	c93d                	beqz	a0,80001eb0 <allocproc+0x138>
  memset(&p->context, 0, sizeof(p->context));
    80001e3c:	07000613          	li	a2,112
    80001e40:	4581                	li	a1,0
    80001e42:	06048513          	addi	a0,s1,96
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	000080e7          	jalr	ra # 80000e46 <memset>
  p->context.ra = (uint64)forkret;
    80001e4e:	00000797          	auipc	a5,0x0
    80001e52:	d4678793          	addi	a5,a5,-698 # 80001b94 <forkret>
    80001e56:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e58:	60bc                	ld	a5,64(s1)
    80001e5a:	6705                	lui	a4,0x1
    80001e5c:	97ba                	add	a5,a5,a4
    80001e5e:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001e60:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001e64:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001e68:	00007797          	auipc	a5,0x7
    80001e6c:	d007a783          	lw	a5,-768(a5) # 80008b68 <ticks>
    80001e70:	16f4a623          	sw	a5,364(s1)
}
    80001e74:	8526                	mv	a0,s1
    80001e76:	60e2                	ld	ra,24(sp)
    80001e78:	6442                	ld	s0,16(sp)
    80001e7a:	64a2                	ld	s1,8(sp)
    80001e7c:	6902                	ld	s2,0(sp)
    80001e7e:	6105                	addi	sp,sp,32
    80001e80:	8082                	ret
  if (forked_process && p->parent)
    80001e82:	7c9c                	ld	a5,56(s1)
    80001e84:	dfc9                	beqz	a5,80001e1e <allocproc+0xa6>
    p->tickets = p->parent->tickets;
    80001e86:	1787a783          	lw	a5,376(a5)
    80001e8a:	16f4ac23          	sw	a5,376(s1)
    forked_process = 0;
    80001e8e:	00007797          	auipc	a5,0x7
    80001e92:	cc07a523          	sw	zero,-822(a5) # 80008b58 <forked_process>
    80001e96:	b761                	j	80001e1e <allocproc+0xa6>
    freeproc(p);
    80001e98:	8526                	mv	a0,s1
    80001e9a:	00000097          	auipc	ra,0x0
    80001e9e:	e74080e7          	jalr	-396(ra) # 80001d0e <freeproc>
    release(&p->lock);
    80001ea2:	8526                	mv	a0,s1
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	f5a080e7          	jalr	-166(ra) # 80000dfe <release>
    return 0;
    80001eac:	84ca                	mv	s1,s2
    80001eae:	b7d9                	j	80001e74 <allocproc+0xfc>
    freeproc(p);
    80001eb0:	8526                	mv	a0,s1
    80001eb2:	00000097          	auipc	ra,0x0
    80001eb6:	e5c080e7          	jalr	-420(ra) # 80001d0e <freeproc>
    release(&p->lock);
    80001eba:	8526                	mv	a0,s1
    80001ebc:	fffff097          	auipc	ra,0xfffff
    80001ec0:	f42080e7          	jalr	-190(ra) # 80000dfe <release>
    return 0;
    80001ec4:	84ca                	mv	s1,s2
    80001ec6:	b77d                	j	80001e74 <allocproc+0xfc>

0000000080001ec8 <userinit>:
{
    80001ec8:	1101                	addi	sp,sp,-32
    80001eca:	ec06                	sd	ra,24(sp)
    80001ecc:	e822                	sd	s0,16(sp)
    80001ece:	e426                	sd	s1,8(sp)
    80001ed0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ed2:	00000097          	auipc	ra,0x0
    80001ed6:	ea6080e7          	jalr	-346(ra) # 80001d78 <allocproc>
    80001eda:	84aa                	mv	s1,a0
  initproc = p;
    80001edc:	00007797          	auipc	a5,0x7
    80001ee0:	c8a7b223          	sd	a0,-892(a5) # 80008b60 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ee4:	03400613          	li	a2,52
    80001ee8:	00007597          	auipc	a1,0x7
    80001eec:	b1858593          	addi	a1,a1,-1256 # 80008a00 <initcode>
    80001ef0:	6928                	ld	a0,80(a0)
    80001ef2:	fffff097          	auipc	ra,0xfffff
    80001ef6:	5d8080e7          	jalr	1496(ra) # 800014ca <uvmfirst>
  p->sz = PGSIZE;
    80001efa:	6785                	lui	a5,0x1
    80001efc:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001efe:	6cb8                	ld	a4,88(s1)
    80001f00:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001f04:	6cb8                	ld	a4,88(s1)
    80001f06:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f08:	4641                	li	a2,16
    80001f0a:	00006597          	auipc	a1,0x6
    80001f0e:	33658593          	addi	a1,a1,822 # 80008240 <digits+0x200>
    80001f12:	15848513          	addi	a0,s1,344
    80001f16:	fffff097          	auipc	ra,0xfffff
    80001f1a:	07a080e7          	jalr	122(ra) # 80000f90 <safestrcpy>
  p->cwd = namei("/");
    80001f1e:	00006517          	auipc	a0,0x6
    80001f22:	33250513          	addi	a0,a0,818 # 80008250 <digits+0x210>
    80001f26:	00002097          	auipc	ra,0x2
    80001f2a:	65a080e7          	jalr	1626(ra) # 80004580 <namei>
    80001f2e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f32:	478d                	li	a5,3
    80001f34:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	ec6080e7          	jalr	-314(ra) # 80000dfe <release>
}
    80001f40:	60e2                	ld	ra,24(sp)
    80001f42:	6442                	ld	s0,16(sp)
    80001f44:	64a2                	ld	s1,8(sp)
    80001f46:	6105                	addi	sp,sp,32
    80001f48:	8082                	ret

0000000080001f4a <growproc>:
{
    80001f4a:	1101                	addi	sp,sp,-32
    80001f4c:	ec06                	sd	ra,24(sp)
    80001f4e:	e822                	sd	s0,16(sp)
    80001f50:	e426                	sd	s1,8(sp)
    80001f52:	e04a                	sd	s2,0(sp)
    80001f54:	1000                	addi	s0,sp,32
    80001f56:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	c04080e7          	jalr	-1020(ra) # 80001b5c <myproc>
    80001f60:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f62:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001f64:	01204c63          	bgtz	s2,80001f7c <growproc+0x32>
  else if (n < 0)
    80001f68:	02094663          	bltz	s2,80001f94 <growproc+0x4a>
  p->sz = sz;
    80001f6c:	e4ac                	sd	a1,72(s1)
  return 0;
    80001f6e:	4501                	li	a0,0
}
    80001f70:	60e2                	ld	ra,24(sp)
    80001f72:	6442                	ld	s0,16(sp)
    80001f74:	64a2                	ld	s1,8(sp)
    80001f76:	6902                	ld	s2,0(sp)
    80001f78:	6105                	addi	sp,sp,32
    80001f7a:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f7c:	4691                	li	a3,4
    80001f7e:	00b90633          	add	a2,s2,a1
    80001f82:	6928                	ld	a0,80(a0)
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	600080e7          	jalr	1536(ra) # 80001584 <uvmalloc>
    80001f8c:	85aa                	mv	a1,a0
    80001f8e:	fd79                	bnez	a0,80001f6c <growproc+0x22>
      return -1;
    80001f90:	557d                	li	a0,-1
    80001f92:	bff9                	j	80001f70 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f94:	00b90633          	add	a2,s2,a1
    80001f98:	6928                	ld	a0,80(a0)
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	5a2080e7          	jalr	1442(ra) # 8000153c <uvmdealloc>
    80001fa2:	85aa                	mv	a1,a0
    80001fa4:	b7e1                	j	80001f6c <growproc+0x22>

0000000080001fa6 <fork>:
{
    80001fa6:	7139                	addi	sp,sp,-64
    80001fa8:	fc06                	sd	ra,56(sp)
    80001faa:	f822                	sd	s0,48(sp)
    80001fac:	f426                	sd	s1,40(sp)
    80001fae:	f04a                	sd	s2,32(sp)
    80001fb0:	ec4e                	sd	s3,24(sp)
    80001fb2:	e852                	sd	s4,16(sp)
    80001fb4:	e456                	sd	s5,8(sp)
    80001fb6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001fb8:	00000097          	auipc	ra,0x0
    80001fbc:	ba4080e7          	jalr	-1116(ra) # 80001b5c <myproc>
    80001fc0:	8aaa                	mv	s5,a0
  if (p->pid > 1)
    80001fc2:	5918                	lw	a4,48(a0)
    80001fc4:	4785                	li	a5,1
    80001fc6:	00e7d663          	bge	a5,a4,80001fd2 <fork+0x2c>
    forked_process = 1;
    80001fca:	00007717          	auipc	a4,0x7
    80001fce:	b8f72723          	sw	a5,-1138(a4) # 80008b58 <forked_process>
  if ((np = allocproc()) == 0)
    80001fd2:	00000097          	auipc	ra,0x0
    80001fd6:	da6080e7          	jalr	-602(ra) # 80001d78 <allocproc>
    80001fda:	89aa                	mv	s3,a0
    80001fdc:	10050f63          	beqz	a0,800020fa <fork+0x154>
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001fe0:	048ab603          	ld	a2,72(s5)
    80001fe4:	692c                	ld	a1,80(a0)
    80001fe6:	050ab503          	ld	a0,80(s5)
    80001fea:	fffff097          	auipc	ra,0xfffff
    80001fee:	6f2080e7          	jalr	1778(ra) # 800016dc <uvmcopy>
    80001ff2:	04054c63          	bltz	a0,8000204a <fork+0xa4>
  np->sz = p->sz;
    80001ff6:	048ab783          	ld	a5,72(s5)
    80001ffa:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ffe:	058ab683          	ld	a3,88(s5)
    80002002:	87b6                	mv	a5,a3
    80002004:	0589b703          	ld	a4,88(s3)
    80002008:	12068693          	addi	a3,a3,288
    8000200c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002010:	6788                	ld	a0,8(a5)
    80002012:	6b8c                	ld	a1,16(a5)
    80002014:	6f90                	ld	a2,24(a5)
    80002016:	01073023          	sd	a6,0(a4)
    8000201a:	e708                	sd	a0,8(a4)
    8000201c:	eb0c                	sd	a1,16(a4)
    8000201e:	ef10                	sd	a2,24(a4)
    80002020:	02078793          	addi	a5,a5,32
    80002024:	02070713          	addi	a4,a4,32
    80002028:	fed792e3          	bne	a5,a3,8000200c <fork+0x66>
  np->tmask = p->tmask;
    8000202c:	174aa783          	lw	a5,372(s5)
    80002030:	16f9aa23          	sw	a5,372(s3)
  np->trapframe->a0 = 0;
    80002034:	0589b783          	ld	a5,88(s3)
    80002038:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    8000203c:	0d0a8493          	addi	s1,s5,208
    80002040:	0d098913          	addi	s2,s3,208
    80002044:	150a8a13          	addi	s4,s5,336
    80002048:	a00d                	j	8000206a <fork+0xc4>
    freeproc(np);
    8000204a:	854e                	mv	a0,s3
    8000204c:	00000097          	auipc	ra,0x0
    80002050:	cc2080e7          	jalr	-830(ra) # 80001d0e <freeproc>
    release(&np->lock);
    80002054:	854e                	mv	a0,s3
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	da8080e7          	jalr	-600(ra) # 80000dfe <release>
    return -1;
    8000205e:	597d                	li	s2,-1
    80002060:	a059                	j	800020e6 <fork+0x140>
  for (i = 0; i < NOFILE; i++)
    80002062:	04a1                	addi	s1,s1,8
    80002064:	0921                	addi	s2,s2,8
    80002066:	01448b63          	beq	s1,s4,8000207c <fork+0xd6>
    if (p->ofile[i])
    8000206a:	6088                	ld	a0,0(s1)
    8000206c:	d97d                	beqz	a0,80002062 <fork+0xbc>
      np->ofile[i] = filedup(p->ofile[i]);
    8000206e:	00003097          	auipc	ra,0x3
    80002072:	ba8080e7          	jalr	-1112(ra) # 80004c16 <filedup>
    80002076:	00a93023          	sd	a0,0(s2)
    8000207a:	b7e5                	j	80002062 <fork+0xbc>
  np->cwd = idup(p->cwd);
    8000207c:	150ab503          	ld	a0,336(s5)
    80002080:	00002097          	auipc	ra,0x2
    80002084:	d16080e7          	jalr	-746(ra) # 80003d96 <idup>
    80002088:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000208c:	4641                	li	a2,16
    8000208e:	158a8593          	addi	a1,s5,344
    80002092:	15898513          	addi	a0,s3,344
    80002096:	fffff097          	auipc	ra,0xfffff
    8000209a:	efa080e7          	jalr	-262(ra) # 80000f90 <safestrcpy>
  pid = np->pid;
    8000209e:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    800020a2:	854e                	mv	a0,s3
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	d5a080e7          	jalr	-678(ra) # 80000dfe <release>
  acquire(&wait_lock);
    800020ac:	0022f497          	auipc	s1,0x22f
    800020b0:	d5448493          	addi	s1,s1,-684 # 80230e00 <wait_lock>
    800020b4:	8526                	mv	a0,s1
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	c94080e7          	jalr	-876(ra) # 80000d4a <acquire>
  np->parent = p;
    800020be:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	d3a080e7          	jalr	-710(ra) # 80000dfe <release>
  acquire(&np->lock);
    800020cc:	854e                	mv	a0,s3
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	c7c080e7          	jalr	-900(ra) # 80000d4a <acquire>
  np->state = RUNNABLE;
    800020d6:	478d                	li	a5,3
    800020d8:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800020dc:	854e                	mv	a0,s3
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	d20080e7          	jalr	-736(ra) # 80000dfe <release>
}
    800020e6:	854a                	mv	a0,s2
    800020e8:	70e2                	ld	ra,56(sp)
    800020ea:	7442                	ld	s0,48(sp)
    800020ec:	74a2                	ld	s1,40(sp)
    800020ee:	7902                	ld	s2,32(sp)
    800020f0:	69e2                	ld	s3,24(sp)
    800020f2:	6a42                	ld	s4,16(sp)
    800020f4:	6aa2                	ld	s5,8(sp)
    800020f6:	6121                	addi	sp,sp,64
    800020f8:	8082                	ret
    return -1;
    800020fa:	597d                	li	s2,-1
    800020fc:	b7ed                	j	800020e6 <fork+0x140>

00000000800020fe <update_time>:
{
    800020fe:	7179                	addi	sp,sp,-48
    80002100:	f406                	sd	ra,40(sp)
    80002102:	f022                	sd	s0,32(sp)
    80002104:	ec26                	sd	s1,24(sp)
    80002106:	e84a                	sd	s2,16(sp)
    80002108:	e44e                	sd	s3,8(sp)
    8000210a:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    8000210c:	0022f497          	auipc	s1,0x22f
    80002110:	10c48493          	addi	s1,s1,268 # 80231218 <proc>
    if (p->state == RUNNING)
    80002114:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002116:	00236917          	auipc	s2,0x236
    8000211a:	30290913          	addi	s2,s2,770 # 80238418 <mlfq>
    8000211e:	a811                	j	80002132 <update_time+0x34>
    release(&p->lock);
    80002120:	8526                	mv	a0,s1
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	cdc080e7          	jalr	-804(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000212a:	1c848493          	addi	s1,s1,456
    8000212e:	03248063          	beq	s1,s2,8000214e <update_time+0x50>
    acquire(&p->lock);
    80002132:	8526                	mv	a0,s1
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	c16080e7          	jalr	-1002(ra) # 80000d4a <acquire>
    if (p->state == RUNNING)
    8000213c:	4c9c                	lw	a5,24(s1)
    8000213e:	ff3791e3          	bne	a5,s3,80002120 <update_time+0x22>
      p->rtime++;
    80002142:	1684a783          	lw	a5,360(s1)
    80002146:	2785                	addiw	a5,a5,1
    80002148:	16f4a423          	sw	a5,360(s1)
    8000214c:	bfd1                	j	80002120 <update_time+0x22>
}
    8000214e:	70a2                	ld	ra,40(sp)
    80002150:	7402                	ld	s0,32(sp)
    80002152:	64e2                	ld	s1,24(sp)
    80002154:	6942                	ld	s2,16(sp)
    80002156:	69a2                	ld	s3,8(sp)
    80002158:	6145                	addi	sp,sp,48
    8000215a:	8082                	ret

000000008000215c <scheduler>:
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
    80002170:	8792                	mv	a5,tp
  int id = r_tp();
    80002172:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002174:	00779a93          	slli	s5,a5,0x7
    80002178:	0022f717          	auipc	a4,0x22f
    8000217c:	c7070713          	addi	a4,a4,-912 # 80230de8 <pid_lock>
    80002180:	9756                	add	a4,a4,s5
    80002182:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002186:	0022f717          	auipc	a4,0x22f
    8000218a:	c9a70713          	addi	a4,a4,-870 # 80230e20 <cpus+0x8>
    8000218e:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80002190:	498d                	li	s3,3
        p->state = RUNNING;
    80002192:	4b11                	li	s6,4
        c->proc = p;
    80002194:	079e                	slli	a5,a5,0x7
    80002196:	0022fa17          	auipc	s4,0x22f
    8000219a:	c52a0a13          	addi	s4,s4,-942 # 80230de8 <pid_lock>
    8000219e:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800021a0:	00236917          	auipc	s2,0x236
    800021a4:	27890913          	addi	s2,s2,632 # 80238418 <mlfq>
  asm volatile("csrr %0, sstatus"
    800021a8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800021ac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    800021b0:	10079073          	csrw	sstatus,a5
    800021b4:	0022f497          	auipc	s1,0x22f
    800021b8:	06448493          	addi	s1,s1,100 # 80231218 <proc>
    800021bc:	a811                	j	800021d0 <scheduler+0x74>
      release(&p->lock);
    800021be:	8526                	mv	a0,s1
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	c3e080e7          	jalr	-962(ra) # 80000dfe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800021c8:	1c848493          	addi	s1,s1,456
    800021cc:	fd248ee3          	beq	s1,s2,800021a8 <scheduler+0x4c>
      acquire(&p->lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	b78080e7          	jalr	-1160(ra) # 80000d4a <acquire>
      if (p->state == RUNNABLE)
    800021da:	4c9c                	lw	a5,24(s1)
    800021dc:	ff3791e3          	bne	a5,s3,800021be <scheduler+0x62>
        p->state = RUNNING;
    800021e0:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800021e4:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800021e8:	06048593          	addi	a1,s1,96
    800021ec:	8556                	mv	a0,s5
    800021ee:	00001097          	auipc	ra,0x1
    800021f2:	810080e7          	jalr	-2032(ra) # 800029fe <swtch>
        c->proc = 0;
    800021f6:	020a3823          	sd	zero,48(s4)
    800021fa:	b7d1                	j	800021be <scheduler+0x62>

00000000800021fc <sched>:
{
    800021fc:	7179                	addi	sp,sp,-48
    800021fe:	f406                	sd	ra,40(sp)
    80002200:	f022                	sd	s0,32(sp)
    80002202:	ec26                	sd	s1,24(sp)
    80002204:	e84a                	sd	s2,16(sp)
    80002206:	e44e                	sd	s3,8(sp)
    80002208:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000220a:	00000097          	auipc	ra,0x0
    8000220e:	952080e7          	jalr	-1710(ra) # 80001b5c <myproc>
    80002212:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	abc080e7          	jalr	-1348(ra) # 80000cd0 <holding>
    8000221c:	c93d                	beqz	a0,80002292 <sched+0x96>
  asm volatile("mv %0, tp"
    8000221e:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002220:	2781                	sext.w	a5,a5
    80002222:	079e                	slli	a5,a5,0x7
    80002224:	0022f717          	auipc	a4,0x22f
    80002228:	bc470713          	addi	a4,a4,-1084 # 80230de8 <pid_lock>
    8000222c:	97ba                	add	a5,a5,a4
    8000222e:	0a87a703          	lw	a4,168(a5)
    80002232:	4785                	li	a5,1
    80002234:	06f71763          	bne	a4,a5,800022a2 <sched+0xa6>
  if (p->state == RUNNING)
    80002238:	4c98                	lw	a4,24(s1)
    8000223a:	4791                	li	a5,4
    8000223c:	06f70b63          	beq	a4,a5,800022b2 <sched+0xb6>
  asm volatile("csrr %0, sstatus"
    80002240:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002244:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002246:	efb5                	bnez	a5,800022c2 <sched+0xc6>
  asm volatile("mv %0, tp"
    80002248:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000224a:	0022f917          	auipc	s2,0x22f
    8000224e:	b9e90913          	addi	s2,s2,-1122 # 80230de8 <pid_lock>
    80002252:	2781                	sext.w	a5,a5
    80002254:	079e                	slli	a5,a5,0x7
    80002256:	97ca                	add	a5,a5,s2
    80002258:	0ac7a983          	lw	s3,172(a5)
    8000225c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000225e:	2781                	sext.w	a5,a5
    80002260:	079e                	slli	a5,a5,0x7
    80002262:	0022f597          	auipc	a1,0x22f
    80002266:	bbe58593          	addi	a1,a1,-1090 # 80230e20 <cpus+0x8>
    8000226a:	95be                	add	a1,a1,a5
    8000226c:	06048513          	addi	a0,s1,96
    80002270:	00000097          	auipc	ra,0x0
    80002274:	78e080e7          	jalr	1934(ra) # 800029fe <swtch>
    80002278:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000227a:	2781                	sext.w	a5,a5
    8000227c:	079e                	slli	a5,a5,0x7
    8000227e:	993e                	add	s2,s2,a5
    80002280:	0b392623          	sw	s3,172(s2)
}
    80002284:	70a2                	ld	ra,40(sp)
    80002286:	7402                	ld	s0,32(sp)
    80002288:	64e2                	ld	s1,24(sp)
    8000228a:	6942                	ld	s2,16(sp)
    8000228c:	69a2                	ld	s3,8(sp)
    8000228e:	6145                	addi	sp,sp,48
    80002290:	8082                	ret
    panic("sched p->lock");
    80002292:	00006517          	auipc	a0,0x6
    80002296:	fc650513          	addi	a0,a0,-58 # 80008258 <digits+0x218>
    8000229a:	ffffe097          	auipc	ra,0xffffe
    8000229e:	2a6080e7          	jalr	678(ra) # 80000540 <panic>
    panic("sched locks");
    800022a2:	00006517          	auipc	a0,0x6
    800022a6:	fc650513          	addi	a0,a0,-58 # 80008268 <digits+0x228>
    800022aa:	ffffe097          	auipc	ra,0xffffe
    800022ae:	296080e7          	jalr	662(ra) # 80000540 <panic>
    panic("sched running");
    800022b2:	00006517          	auipc	a0,0x6
    800022b6:	fc650513          	addi	a0,a0,-58 # 80008278 <digits+0x238>
    800022ba:	ffffe097          	auipc	ra,0xffffe
    800022be:	286080e7          	jalr	646(ra) # 80000540 <panic>
    panic("sched interruptible");
    800022c2:	00006517          	auipc	a0,0x6
    800022c6:	fc650513          	addi	a0,a0,-58 # 80008288 <digits+0x248>
    800022ca:	ffffe097          	auipc	ra,0xffffe
    800022ce:	276080e7          	jalr	630(ra) # 80000540 <panic>

00000000800022d2 <yield>:
{
    800022d2:	1101                	addi	sp,sp,-32
    800022d4:	ec06                	sd	ra,24(sp)
    800022d6:	e822                	sd	s0,16(sp)
    800022d8:	e426                	sd	s1,8(sp)
    800022da:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022dc:	00000097          	auipc	ra,0x0
    800022e0:	880080e7          	jalr	-1920(ra) # 80001b5c <myproc>
    800022e4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	a64080e7          	jalr	-1436(ra) # 80000d4a <acquire>
  p->state = RUNNABLE;
    800022ee:	478d                	li	a5,3
    800022f0:	cc9c                	sw	a5,24(s1)
  sched();
    800022f2:	00000097          	auipc	ra,0x0
    800022f6:	f0a080e7          	jalr	-246(ra) # 800021fc <sched>
  release(&p->lock);
    800022fa:	8526                	mv	a0,s1
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	b02080e7          	jalr	-1278(ra) # 80000dfe <release>
}
    80002304:	60e2                	ld	ra,24(sp)
    80002306:	6442                	ld	s0,16(sp)
    80002308:	64a2                	ld	s1,8(sp)
    8000230a:	6105                	addi	sp,sp,32
    8000230c:	8082                	ret

000000008000230e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000230e:	7179                	addi	sp,sp,-48
    80002310:	f406                	sd	ra,40(sp)
    80002312:	f022                	sd	s0,32(sp)
    80002314:	ec26                	sd	s1,24(sp)
    80002316:	e84a                	sd	s2,16(sp)
    80002318:	e44e                	sd	s3,8(sp)
    8000231a:	1800                	addi	s0,sp,48
    8000231c:	89aa                	mv	s3,a0
    8000231e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002320:	00000097          	auipc	ra,0x0
    80002324:	83c080e7          	jalr	-1988(ra) # 80001b5c <myproc>
    80002328:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	a20080e7          	jalr	-1504(ra) # 80000d4a <acquire>
  release(lk);
    80002332:	854a                	mv	a0,s2
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	aca080e7          	jalr	-1334(ra) # 80000dfe <release>

  // Go to sleep.
  p->sleep_start = ticks;
    8000233c:	00007797          	auipc	a5,0x7
    80002340:	82c7a783          	lw	a5,-2004(a5) # 80008b68 <ticks>
    80002344:	18f4a223          	sw	a5,388(s1)
  p->chan = chan;
    80002348:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000234c:	4789                	li	a5,2
    8000234e:	cc9c                	sw	a5,24(s1)

  sched();
    80002350:	00000097          	auipc	ra,0x0
    80002354:	eac080e7          	jalr	-340(ra) # 800021fc <sched>

  // Tidy up.
  p->chan = 0;
    80002358:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000235c:	8526                	mv	a0,s1
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	aa0080e7          	jalr	-1376(ra) # 80000dfe <release>
  acquire(lk);
    80002366:	854a                	mv	a0,s2
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	9e2080e7          	jalr	-1566(ra) # 80000d4a <acquire>
}
    80002370:	70a2                	ld	ra,40(sp)
    80002372:	7402                	ld	s0,32(sp)
    80002374:	64e2                	ld	s1,24(sp)
    80002376:	6942                	ld	s2,16(sp)
    80002378:	69a2                	ld	s3,8(sp)
    8000237a:	6145                	addi	sp,sp,48
    8000237c:	8082                	ret

000000008000237e <waitx>:
{
    8000237e:	711d                	addi	sp,sp,-96
    80002380:	ec86                	sd	ra,88(sp)
    80002382:	e8a2                	sd	s0,80(sp)
    80002384:	e4a6                	sd	s1,72(sp)
    80002386:	e0ca                	sd	s2,64(sp)
    80002388:	fc4e                	sd	s3,56(sp)
    8000238a:	f852                	sd	s4,48(sp)
    8000238c:	f456                	sd	s5,40(sp)
    8000238e:	f05a                	sd	s6,32(sp)
    80002390:	ec5e                	sd	s7,24(sp)
    80002392:	e862                	sd	s8,16(sp)
    80002394:	e466                	sd	s9,8(sp)
    80002396:	e06a                	sd	s10,0(sp)
    80002398:	1080                	addi	s0,sp,96
    8000239a:	8b2a                	mv	s6,a0
    8000239c:	8bae                	mv	s7,a1
    8000239e:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	7bc080e7          	jalr	1980(ra) # 80001b5c <myproc>
    800023a8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023aa:	0022f517          	auipc	a0,0x22f
    800023ae:	a5650513          	addi	a0,a0,-1450 # 80230e00 <wait_lock>
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	998080e7          	jalr	-1640(ra) # 80000d4a <acquire>
    havekids = 0;
    800023ba:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    800023bc:	4a15                	li	s4,5
        havekids = 1;
    800023be:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800023c0:	00236997          	auipc	s3,0x236
    800023c4:	05898993          	addi	s3,s3,88 # 80238418 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800023c8:	0022fd17          	auipc	s10,0x22f
    800023cc:	a38d0d13          	addi	s10,s10,-1480 # 80230e00 <wait_lock>
    havekids = 0;
    800023d0:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800023d2:	0022f497          	auipc	s1,0x22f
    800023d6:	e4648493          	addi	s1,s1,-442 # 80231218 <proc>
    800023da:	a059                	j	80002460 <waitx+0xe2>
          pid = np->pid;
    800023dc:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800023e0:	1684a783          	lw	a5,360(s1)
    800023e4:	00fc2023          	sw	a5,0(s8) # 1000 <_entry-0x7ffff000>
          *wtime = np->etime - np->ctime - np->rtime;
    800023e8:	16c4a703          	lw	a4,364(s1)
    800023ec:	9f3d                	addw	a4,a4,a5
    800023ee:	1704a783          	lw	a5,368(s1)
    800023f2:	9f99                	subw	a5,a5,a4
    800023f4:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7fdb9a60>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023f8:	000b0e63          	beqz	s6,80002414 <waitx+0x96>
    800023fc:	4691                	li	a3,4
    800023fe:	02c48613          	addi	a2,s1,44
    80002402:	85da                	mv	a1,s6
    80002404:	05093503          	ld	a0,80(s2)
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	3d8080e7          	jalr	984(ra) # 800017e0 <copyout>
    80002410:	02054563          	bltz	a0,8000243a <waitx+0xbc>
          freeproc(np);
    80002414:	8526                	mv	a0,s1
    80002416:	00000097          	auipc	ra,0x0
    8000241a:	8f8080e7          	jalr	-1800(ra) # 80001d0e <freeproc>
          release(&np->lock);
    8000241e:	8526                	mv	a0,s1
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	9de080e7          	jalr	-1570(ra) # 80000dfe <release>
          release(&wait_lock);
    80002428:	0022f517          	auipc	a0,0x22f
    8000242c:	9d850513          	addi	a0,a0,-1576 # 80230e00 <wait_lock>
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	9ce080e7          	jalr	-1586(ra) # 80000dfe <release>
          return pid;
    80002438:	a09d                	j	8000249e <waitx+0x120>
            release(&np->lock);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	9c2080e7          	jalr	-1598(ra) # 80000dfe <release>
            release(&wait_lock);
    80002444:	0022f517          	auipc	a0,0x22f
    80002448:	9bc50513          	addi	a0,a0,-1604 # 80230e00 <wait_lock>
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	9b2080e7          	jalr	-1614(ra) # 80000dfe <release>
            return -1;
    80002454:	59fd                	li	s3,-1
    80002456:	a0a1                	j	8000249e <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002458:	1c848493          	addi	s1,s1,456
    8000245c:	03348463          	beq	s1,s3,80002484 <waitx+0x106>
      if (np->parent == p)
    80002460:	7c9c                	ld	a5,56(s1)
    80002462:	ff279be3          	bne	a5,s2,80002458 <waitx+0xda>
        acquire(&np->lock);
    80002466:	8526                	mv	a0,s1
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	8e2080e7          	jalr	-1822(ra) # 80000d4a <acquire>
        if (np->state == ZOMBIE)
    80002470:	4c9c                	lw	a5,24(s1)
    80002472:	f74785e3          	beq	a5,s4,800023dc <waitx+0x5e>
        release(&np->lock);
    80002476:	8526                	mv	a0,s1
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	986080e7          	jalr	-1658(ra) # 80000dfe <release>
        havekids = 1;
    80002480:	8756                	mv	a4,s5
    80002482:	bfd9                	j	80002458 <waitx+0xda>
    if (!havekids || p->killed)
    80002484:	c701                	beqz	a4,8000248c <waitx+0x10e>
    80002486:	02892783          	lw	a5,40(s2)
    8000248a:	cb8d                	beqz	a5,800024bc <waitx+0x13e>
      release(&wait_lock);
    8000248c:	0022f517          	auipc	a0,0x22f
    80002490:	97450513          	addi	a0,a0,-1676 # 80230e00 <wait_lock>
    80002494:	fffff097          	auipc	ra,0xfffff
    80002498:	96a080e7          	jalr	-1686(ra) # 80000dfe <release>
      return -1;
    8000249c:	59fd                	li	s3,-1
}
    8000249e:	854e                	mv	a0,s3
    800024a0:	60e6                	ld	ra,88(sp)
    800024a2:	6446                	ld	s0,80(sp)
    800024a4:	64a6                	ld	s1,72(sp)
    800024a6:	6906                	ld	s2,64(sp)
    800024a8:	79e2                	ld	s3,56(sp)
    800024aa:	7a42                	ld	s4,48(sp)
    800024ac:	7aa2                	ld	s5,40(sp)
    800024ae:	7b02                	ld	s6,32(sp)
    800024b0:	6be2                	ld	s7,24(sp)
    800024b2:	6c42                	ld	s8,16(sp)
    800024b4:	6ca2                	ld	s9,8(sp)
    800024b6:	6d02                	ld	s10,0(sp)
    800024b8:	6125                	addi	sp,sp,96
    800024ba:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024bc:	85ea                	mv	a1,s10
    800024be:	854a                	mv	a0,s2
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	e4e080e7          	jalr	-434(ra) # 8000230e <sleep>
    havekids = 0;
    800024c8:	b721                	j	800023d0 <waitx+0x52>

00000000800024ca <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800024ca:	7139                	addi	sp,sp,-64
    800024cc:	fc06                	sd	ra,56(sp)
    800024ce:	f822                	sd	s0,48(sp)
    800024d0:	f426                	sd	s1,40(sp)
    800024d2:	f04a                	sd	s2,32(sp)
    800024d4:	ec4e                	sd	s3,24(sp)
    800024d6:	e852                	sd	s4,16(sp)
    800024d8:	e456                	sd	s5,8(sp)
    800024da:	e05a                	sd	s6,0(sp)
    800024dc:	0080                	addi	s0,sp,64
    800024de:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800024e0:	0022f497          	auipc	s1,0x22f
    800024e4:	d3848493          	addi	s1,s1,-712 # 80231218 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800024e8:	4989                	li	s3,2
      {
        p->sleeping_ticks += (ticks - p->sleep_start);
    800024ea:	00006b17          	auipc	s6,0x6
    800024ee:	67eb0b13          	addi	s6,s6,1662 # 80008b68 <ticks>
        p->state = RUNNABLE;
    800024f2:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800024f4:	00236917          	auipc	s2,0x236
    800024f8:	f2490913          	addi	s2,s2,-220 # 80238418 <mlfq>
    800024fc:	a811                	j	80002510 <wakeup+0x46>
      }
      release(&p->lock);
    800024fe:	8526                	mv	a0,s1
    80002500:	fffff097          	auipc	ra,0xfffff
    80002504:	8fe080e7          	jalr	-1794(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002508:	1c848493          	addi	s1,s1,456
    8000250c:	05248063          	beq	s1,s2,8000254c <wakeup+0x82>
    if (p != myproc())
    80002510:	fffff097          	auipc	ra,0xfffff
    80002514:	64c080e7          	jalr	1612(ra) # 80001b5c <myproc>
    80002518:	fea488e3          	beq	s1,a0,80002508 <wakeup+0x3e>
      acquire(&p->lock);
    8000251c:	8526                	mv	a0,s1
    8000251e:	fffff097          	auipc	ra,0xfffff
    80002522:	82c080e7          	jalr	-2004(ra) # 80000d4a <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002526:	4c9c                	lw	a5,24(s1)
    80002528:	fd379be3          	bne	a5,s3,800024fe <wakeup+0x34>
    8000252c:	709c                	ld	a5,32(s1)
    8000252e:	fd4798e3          	bne	a5,s4,800024fe <wakeup+0x34>
        p->sleeping_ticks += (ticks - p->sleep_start);
    80002532:	18c4a703          	lw	a4,396(s1)
    80002536:	000b2783          	lw	a5,0(s6)
    8000253a:	9fb9                	addw	a5,a5,a4
    8000253c:	1844a703          	lw	a4,388(s1)
    80002540:	9f99                	subw	a5,a5,a4
    80002542:	18f4a623          	sw	a5,396(s1)
        p->state = RUNNABLE;
    80002546:	0154ac23          	sw	s5,24(s1)
    8000254a:	bf55                	j	800024fe <wakeup+0x34>
    }
  }
}
    8000254c:	70e2                	ld	ra,56(sp)
    8000254e:	7442                	ld	s0,48(sp)
    80002550:	74a2                	ld	s1,40(sp)
    80002552:	7902                	ld	s2,32(sp)
    80002554:	69e2                	ld	s3,24(sp)
    80002556:	6a42                	ld	s4,16(sp)
    80002558:	6aa2                	ld	s5,8(sp)
    8000255a:	6b02                	ld	s6,0(sp)
    8000255c:	6121                	addi	sp,sp,64
    8000255e:	8082                	ret

0000000080002560 <reparent>:
{
    80002560:	7179                	addi	sp,sp,-48
    80002562:	f406                	sd	ra,40(sp)
    80002564:	f022                	sd	s0,32(sp)
    80002566:	ec26                	sd	s1,24(sp)
    80002568:	e84a                	sd	s2,16(sp)
    8000256a:	e44e                	sd	s3,8(sp)
    8000256c:	e052                	sd	s4,0(sp)
    8000256e:	1800                	addi	s0,sp,48
    80002570:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002572:	0022f497          	auipc	s1,0x22f
    80002576:	ca648493          	addi	s1,s1,-858 # 80231218 <proc>
      pp->parent = initproc;
    8000257a:	00006a17          	auipc	s4,0x6
    8000257e:	5e6a0a13          	addi	s4,s4,1510 # 80008b60 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002582:	00236997          	auipc	s3,0x236
    80002586:	e9698993          	addi	s3,s3,-362 # 80238418 <mlfq>
    8000258a:	a029                	j	80002594 <reparent+0x34>
    8000258c:	1c848493          	addi	s1,s1,456
    80002590:	01348d63          	beq	s1,s3,800025aa <reparent+0x4a>
    if (pp->parent == p)
    80002594:	7c9c                	ld	a5,56(s1)
    80002596:	ff279be3          	bne	a5,s2,8000258c <reparent+0x2c>
      pp->parent = initproc;
    8000259a:	000a3503          	ld	a0,0(s4)
    8000259e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800025a0:	00000097          	auipc	ra,0x0
    800025a4:	f2a080e7          	jalr	-214(ra) # 800024ca <wakeup>
    800025a8:	b7d5                	j	8000258c <reparent+0x2c>
}
    800025aa:	70a2                	ld	ra,40(sp)
    800025ac:	7402                	ld	s0,32(sp)
    800025ae:	64e2                	ld	s1,24(sp)
    800025b0:	6942                	ld	s2,16(sp)
    800025b2:	69a2                	ld	s3,8(sp)
    800025b4:	6a02                	ld	s4,0(sp)
    800025b6:	6145                	addi	sp,sp,48
    800025b8:	8082                	ret

00000000800025ba <exit>:
{
    800025ba:	7179                	addi	sp,sp,-48
    800025bc:	f406                	sd	ra,40(sp)
    800025be:	f022                	sd	s0,32(sp)
    800025c0:	ec26                	sd	s1,24(sp)
    800025c2:	e84a                	sd	s2,16(sp)
    800025c4:	e44e                	sd	s3,8(sp)
    800025c6:	e052                	sd	s4,0(sp)
    800025c8:	1800                	addi	s0,sp,48
    800025ca:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025cc:	fffff097          	auipc	ra,0xfffff
    800025d0:	590080e7          	jalr	1424(ra) # 80001b5c <myproc>
    800025d4:	89aa                	mv	s3,a0
  if (p == initproc)
    800025d6:	00006797          	auipc	a5,0x6
    800025da:	58a7b783          	ld	a5,1418(a5) # 80008b60 <initproc>
    800025de:	0d050493          	addi	s1,a0,208
    800025e2:	15050913          	addi	s2,a0,336
    800025e6:	02a79363          	bne	a5,a0,8000260c <exit+0x52>
    panic("init exiting");
    800025ea:	00006517          	auipc	a0,0x6
    800025ee:	cb650513          	addi	a0,a0,-842 # 800082a0 <digits+0x260>
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	f4e080e7          	jalr	-178(ra) # 80000540 <panic>
      fileclose(f);
    800025fa:	00002097          	auipc	ra,0x2
    800025fe:	66e080e7          	jalr	1646(ra) # 80004c68 <fileclose>
      p->ofile[fd] = 0;
    80002602:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002606:	04a1                	addi	s1,s1,8
    80002608:	01248563          	beq	s1,s2,80002612 <exit+0x58>
    if (p->ofile[fd])
    8000260c:	6088                	ld	a0,0(s1)
    8000260e:	f575                	bnez	a0,800025fa <exit+0x40>
    80002610:	bfdd                	j	80002606 <exit+0x4c>
  begin_op();
    80002612:	00002097          	auipc	ra,0x2
    80002616:	18e080e7          	jalr	398(ra) # 800047a0 <begin_op>
  iput(p->cwd);
    8000261a:	1509b503          	ld	a0,336(s3)
    8000261e:	00002097          	auipc	ra,0x2
    80002622:	970080e7          	jalr	-1680(ra) # 80003f8e <iput>
  end_op();
    80002626:	00002097          	auipc	ra,0x2
    8000262a:	1f8080e7          	jalr	504(ra) # 8000481e <end_op>
  p->cwd = 0;
    8000262e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002632:	0022e497          	auipc	s1,0x22e
    80002636:	7ce48493          	addi	s1,s1,1998 # 80230e00 <wait_lock>
    8000263a:	8526                	mv	a0,s1
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	70e080e7          	jalr	1806(ra) # 80000d4a <acquire>
  reparent(p);
    80002644:	854e                	mv	a0,s3
    80002646:	00000097          	auipc	ra,0x0
    8000264a:	f1a080e7          	jalr	-230(ra) # 80002560 <reparent>
  wakeup(p->parent);
    8000264e:	0389b503          	ld	a0,56(s3)
    80002652:	00000097          	auipc	ra,0x0
    80002656:	e78080e7          	jalr	-392(ra) # 800024ca <wakeup>
  acquire(&p->lock);
    8000265a:	854e                	mv	a0,s3
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	6ee080e7          	jalr	1774(ra) # 80000d4a <acquire>
  p->xstate = status;
    80002664:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002668:	4795                	li	a5,5
    8000266a:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000266e:	00006797          	auipc	a5,0x6
    80002672:	4fa7a783          	lw	a5,1274(a5) # 80008b68 <ticks>
    80002676:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000267a:	8526                	mv	a0,s1
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	782080e7          	jalr	1922(ra) # 80000dfe <release>
  sched();
    80002684:	00000097          	auipc	ra,0x0
    80002688:	b78080e7          	jalr	-1160(ra) # 800021fc <sched>
  panic("zombie exit");
    8000268c:	00006517          	auipc	a0,0x6
    80002690:	c2450513          	addi	a0,a0,-988 # 800082b0 <digits+0x270>
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	eac080e7          	jalr	-340(ra) # 80000540 <panic>

000000008000269c <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000269c:	7179                	addi	sp,sp,-48
    8000269e:	f406                	sd	ra,40(sp)
    800026a0:	f022                	sd	s0,32(sp)
    800026a2:	ec26                	sd	s1,24(sp)
    800026a4:	e84a                	sd	s2,16(sp)
    800026a6:	e44e                	sd	s3,8(sp)
    800026a8:	1800                	addi	s0,sp,48
    800026aa:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800026ac:	0022f497          	auipc	s1,0x22f
    800026b0:	b6c48493          	addi	s1,s1,-1172 # 80231218 <proc>
    800026b4:	00236997          	auipc	s3,0x236
    800026b8:	d6498993          	addi	s3,s3,-668 # 80238418 <mlfq>
  {
    acquire(&p->lock);
    800026bc:	8526                	mv	a0,s1
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	68c080e7          	jalr	1676(ra) # 80000d4a <acquire>
    if (p->pid == pid)
    800026c6:	589c                	lw	a5,48(s1)
    800026c8:	01278d63          	beq	a5,s2,800026e2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026cc:	8526                	mv	a0,s1
    800026ce:	ffffe097          	auipc	ra,0xffffe
    800026d2:	730080e7          	jalr	1840(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800026d6:	1c848493          	addi	s1,s1,456
    800026da:	ff3491e3          	bne	s1,s3,800026bc <kill+0x20>
  }
  return -1;
    800026de:	557d                	li	a0,-1
    800026e0:	a829                	j	800026fa <kill+0x5e>
      p->killed = 1;
    800026e2:	4785                	li	a5,1
    800026e4:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800026e6:	4c98                	lw	a4,24(s1)
    800026e8:	4789                	li	a5,2
    800026ea:	00f70f63          	beq	a4,a5,80002708 <kill+0x6c>
      release(&p->lock);
    800026ee:	8526                	mv	a0,s1
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	70e080e7          	jalr	1806(ra) # 80000dfe <release>
      return 0;
    800026f8:	4501                	li	a0,0
}
    800026fa:	70a2                	ld	ra,40(sp)
    800026fc:	7402                	ld	s0,32(sp)
    800026fe:	64e2                	ld	s1,24(sp)
    80002700:	6942                	ld	s2,16(sp)
    80002702:	69a2                	ld	s3,8(sp)
    80002704:	6145                	addi	sp,sp,48
    80002706:	8082                	ret
        p->state = RUNNABLE;
    80002708:	478d                	li	a5,3
    8000270a:	cc9c                	sw	a5,24(s1)
    8000270c:	b7cd                	j	800026ee <kill+0x52>

000000008000270e <setkilled>:

void setkilled(struct proc *p)
{
    8000270e:	1101                	addi	sp,sp,-32
    80002710:	ec06                	sd	ra,24(sp)
    80002712:	e822                	sd	s0,16(sp)
    80002714:	e426                	sd	s1,8(sp)
    80002716:	1000                	addi	s0,sp,32
    80002718:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	630080e7          	jalr	1584(ra) # 80000d4a <acquire>
  p->killed = 1;
    80002722:	4785                	li	a5,1
    80002724:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002726:	8526                	mv	a0,s1
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	6d6080e7          	jalr	1750(ra) # 80000dfe <release>
}
    80002730:	60e2                	ld	ra,24(sp)
    80002732:	6442                	ld	s0,16(sp)
    80002734:	64a2                	ld	s1,8(sp)
    80002736:	6105                	addi	sp,sp,32
    80002738:	8082                	ret

000000008000273a <killed>:

int killed(struct proc *p)
{
    8000273a:	1101                	addi	sp,sp,-32
    8000273c:	ec06                	sd	ra,24(sp)
    8000273e:	e822                	sd	s0,16(sp)
    80002740:	e426                	sd	s1,8(sp)
    80002742:	e04a                	sd	s2,0(sp)
    80002744:	1000                	addi	s0,sp,32
    80002746:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	602080e7          	jalr	1538(ra) # 80000d4a <acquire>
  k = p->killed;
    80002750:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002754:	8526                	mv	a0,s1
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	6a8080e7          	jalr	1704(ra) # 80000dfe <release>
  return k;
}
    8000275e:	854a                	mv	a0,s2
    80002760:	60e2                	ld	ra,24(sp)
    80002762:	6442                	ld	s0,16(sp)
    80002764:	64a2                	ld	s1,8(sp)
    80002766:	6902                	ld	s2,0(sp)
    80002768:	6105                	addi	sp,sp,32
    8000276a:	8082                	ret

000000008000276c <wait>:
{
    8000276c:	715d                	addi	sp,sp,-80
    8000276e:	e486                	sd	ra,72(sp)
    80002770:	e0a2                	sd	s0,64(sp)
    80002772:	fc26                	sd	s1,56(sp)
    80002774:	f84a                	sd	s2,48(sp)
    80002776:	f44e                	sd	s3,40(sp)
    80002778:	f052                	sd	s4,32(sp)
    8000277a:	ec56                	sd	s5,24(sp)
    8000277c:	e85a                	sd	s6,16(sp)
    8000277e:	e45e                	sd	s7,8(sp)
    80002780:	e062                	sd	s8,0(sp)
    80002782:	0880                	addi	s0,sp,80
    80002784:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002786:	fffff097          	auipc	ra,0xfffff
    8000278a:	3d6080e7          	jalr	982(ra) # 80001b5c <myproc>
    8000278e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002790:	0022e517          	auipc	a0,0x22e
    80002794:	67050513          	addi	a0,a0,1648 # 80230e00 <wait_lock>
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	5b2080e7          	jalr	1458(ra) # 80000d4a <acquire>
    havekids = 0;
    800027a0:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800027a2:	4a15                	li	s4,5
        havekids = 1;
    800027a4:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027a6:	00236997          	auipc	s3,0x236
    800027aa:	c7298993          	addi	s3,s3,-910 # 80238418 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027ae:	0022ec17          	auipc	s8,0x22e
    800027b2:	652c0c13          	addi	s8,s8,1618 # 80230e00 <wait_lock>
    havekids = 0;
    800027b6:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027b8:	0022f497          	auipc	s1,0x22f
    800027bc:	a6048493          	addi	s1,s1,-1440 # 80231218 <proc>
    800027c0:	a0bd                	j	8000282e <wait+0xc2>
          pid = pp->pid;
    800027c2:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800027c6:	000b0e63          	beqz	s6,800027e2 <wait+0x76>
    800027ca:	4691                	li	a3,4
    800027cc:	02c48613          	addi	a2,s1,44
    800027d0:	85da                	mv	a1,s6
    800027d2:	05093503          	ld	a0,80(s2)
    800027d6:	fffff097          	auipc	ra,0xfffff
    800027da:	00a080e7          	jalr	10(ra) # 800017e0 <copyout>
    800027de:	02054563          	bltz	a0,80002808 <wait+0x9c>
          freeproc(pp);
    800027e2:	8526                	mv	a0,s1
    800027e4:	fffff097          	auipc	ra,0xfffff
    800027e8:	52a080e7          	jalr	1322(ra) # 80001d0e <freeproc>
          release(&pp->lock);
    800027ec:	8526                	mv	a0,s1
    800027ee:	ffffe097          	auipc	ra,0xffffe
    800027f2:	610080e7          	jalr	1552(ra) # 80000dfe <release>
          release(&wait_lock);
    800027f6:	0022e517          	auipc	a0,0x22e
    800027fa:	60a50513          	addi	a0,a0,1546 # 80230e00 <wait_lock>
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	600080e7          	jalr	1536(ra) # 80000dfe <release>
          return pid;
    80002806:	a0b5                	j	80002872 <wait+0x106>
            release(&pp->lock);
    80002808:	8526                	mv	a0,s1
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	5f4080e7          	jalr	1524(ra) # 80000dfe <release>
            release(&wait_lock);
    80002812:	0022e517          	auipc	a0,0x22e
    80002816:	5ee50513          	addi	a0,a0,1518 # 80230e00 <wait_lock>
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	5e4080e7          	jalr	1508(ra) # 80000dfe <release>
            return -1;
    80002822:	59fd                	li	s3,-1
    80002824:	a0b9                	j	80002872 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002826:	1c848493          	addi	s1,s1,456
    8000282a:	03348463          	beq	s1,s3,80002852 <wait+0xe6>
      if (pp->parent == p)
    8000282e:	7c9c                	ld	a5,56(s1)
    80002830:	ff279be3          	bne	a5,s2,80002826 <wait+0xba>
        acquire(&pp->lock);
    80002834:	8526                	mv	a0,s1
    80002836:	ffffe097          	auipc	ra,0xffffe
    8000283a:	514080e7          	jalr	1300(ra) # 80000d4a <acquire>
        if (pp->state == ZOMBIE)
    8000283e:	4c9c                	lw	a5,24(s1)
    80002840:	f94781e3          	beq	a5,s4,800027c2 <wait+0x56>
        release(&pp->lock);
    80002844:	8526                	mv	a0,s1
    80002846:	ffffe097          	auipc	ra,0xffffe
    8000284a:	5b8080e7          	jalr	1464(ra) # 80000dfe <release>
        havekids = 1;
    8000284e:	8756                	mv	a4,s5
    80002850:	bfd9                	j	80002826 <wait+0xba>
    if (!havekids || killed(p))
    80002852:	c719                	beqz	a4,80002860 <wait+0xf4>
    80002854:	854a                	mv	a0,s2
    80002856:	00000097          	auipc	ra,0x0
    8000285a:	ee4080e7          	jalr	-284(ra) # 8000273a <killed>
    8000285e:	c51d                	beqz	a0,8000288c <wait+0x120>
      release(&wait_lock);
    80002860:	0022e517          	auipc	a0,0x22e
    80002864:	5a050513          	addi	a0,a0,1440 # 80230e00 <wait_lock>
    80002868:	ffffe097          	auipc	ra,0xffffe
    8000286c:	596080e7          	jalr	1430(ra) # 80000dfe <release>
      return -1;
    80002870:	59fd                	li	s3,-1
}
    80002872:	854e                	mv	a0,s3
    80002874:	60a6                	ld	ra,72(sp)
    80002876:	6406                	ld	s0,64(sp)
    80002878:	74e2                	ld	s1,56(sp)
    8000287a:	7942                	ld	s2,48(sp)
    8000287c:	79a2                	ld	s3,40(sp)
    8000287e:	7a02                	ld	s4,32(sp)
    80002880:	6ae2                	ld	s5,24(sp)
    80002882:	6b42                	ld	s6,16(sp)
    80002884:	6ba2                	ld	s7,8(sp)
    80002886:	6c02                	ld	s8,0(sp)
    80002888:	6161                	addi	sp,sp,80
    8000288a:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000288c:	85e2                	mv	a1,s8
    8000288e:	854a                	mv	a0,s2
    80002890:	00000097          	auipc	ra,0x0
    80002894:	a7e080e7          	jalr	-1410(ra) # 8000230e <sleep>
    havekids = 0;
    80002898:	bf39                	j	800027b6 <wait+0x4a>

000000008000289a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000289a:	7179                	addi	sp,sp,-48
    8000289c:	f406                	sd	ra,40(sp)
    8000289e:	f022                	sd	s0,32(sp)
    800028a0:	ec26                	sd	s1,24(sp)
    800028a2:	e84a                	sd	s2,16(sp)
    800028a4:	e44e                	sd	s3,8(sp)
    800028a6:	e052                	sd	s4,0(sp)
    800028a8:	1800                	addi	s0,sp,48
    800028aa:	84aa                	mv	s1,a0
    800028ac:	892e                	mv	s2,a1
    800028ae:	89b2                	mv	s3,a2
    800028b0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028b2:	fffff097          	auipc	ra,0xfffff
    800028b6:	2aa080e7          	jalr	682(ra) # 80001b5c <myproc>
  if (user_dst)
    800028ba:	c08d                	beqz	s1,800028dc <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800028bc:	86d2                	mv	a3,s4
    800028be:	864e                	mv	a2,s3
    800028c0:	85ca                	mv	a1,s2
    800028c2:	6928                	ld	a0,80(a0)
    800028c4:	fffff097          	auipc	ra,0xfffff
    800028c8:	f1c080e7          	jalr	-228(ra) # 800017e0 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028cc:	70a2                	ld	ra,40(sp)
    800028ce:	7402                	ld	s0,32(sp)
    800028d0:	64e2                	ld	s1,24(sp)
    800028d2:	6942                	ld	s2,16(sp)
    800028d4:	69a2                	ld	s3,8(sp)
    800028d6:	6a02                	ld	s4,0(sp)
    800028d8:	6145                	addi	sp,sp,48
    800028da:	8082                	ret
    memmove((char *)dst, src, len);
    800028dc:	000a061b          	sext.w	a2,s4
    800028e0:	85ce                	mv	a1,s3
    800028e2:	854a                	mv	a0,s2
    800028e4:	ffffe097          	auipc	ra,0xffffe
    800028e8:	5be080e7          	jalr	1470(ra) # 80000ea2 <memmove>
    return 0;
    800028ec:	8526                	mv	a0,s1
    800028ee:	bff9                	j	800028cc <either_copyout+0x32>

00000000800028f0 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800028f0:	7179                	addi	sp,sp,-48
    800028f2:	f406                	sd	ra,40(sp)
    800028f4:	f022                	sd	s0,32(sp)
    800028f6:	ec26                	sd	s1,24(sp)
    800028f8:	e84a                	sd	s2,16(sp)
    800028fa:	e44e                	sd	s3,8(sp)
    800028fc:	e052                	sd	s4,0(sp)
    800028fe:	1800                	addi	s0,sp,48
    80002900:	892a                	mv	s2,a0
    80002902:	84ae                	mv	s1,a1
    80002904:	89b2                	mv	s3,a2
    80002906:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002908:	fffff097          	auipc	ra,0xfffff
    8000290c:	254080e7          	jalr	596(ra) # 80001b5c <myproc>
  if (user_src)
    80002910:	c08d                	beqz	s1,80002932 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002912:	86d2                	mv	a3,s4
    80002914:	864e                	mv	a2,s3
    80002916:	85ca                	mv	a1,s2
    80002918:	6928                	ld	a0,80(a0)
    8000291a:	fffff097          	auipc	ra,0xfffff
    8000291e:	f8e080e7          	jalr	-114(ra) # 800018a8 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002922:	70a2                	ld	ra,40(sp)
    80002924:	7402                	ld	s0,32(sp)
    80002926:	64e2                	ld	s1,24(sp)
    80002928:	6942                	ld	s2,16(sp)
    8000292a:	69a2                	ld	s3,8(sp)
    8000292c:	6a02                	ld	s4,0(sp)
    8000292e:	6145                	addi	sp,sp,48
    80002930:	8082                	ret
    memmove(dst, (char *)src, len);
    80002932:	000a061b          	sext.w	a2,s4
    80002936:	85ce                	mv	a1,s3
    80002938:	854a                	mv	a0,s2
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	568080e7          	jalr	1384(ra) # 80000ea2 <memmove>
    return 0;
    80002942:	8526                	mv	a0,s1
    80002944:	bff9                	j	80002922 <either_copyin+0x32>

0000000080002946 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002946:	715d                	addi	sp,sp,-80
    80002948:	e486                	sd	ra,72(sp)
    8000294a:	e0a2                	sd	s0,64(sp)
    8000294c:	fc26                	sd	s1,56(sp)
    8000294e:	f84a                	sd	s2,48(sp)
    80002950:	f44e                	sd	s3,40(sp)
    80002952:	f052                	sd	s4,32(sp)
    80002954:	ec56                	sd	s5,24(sp)
    80002956:	e85a                	sd	s6,16(sp)
    80002958:	e45e                	sd	s7,8(sp)
    8000295a:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000295c:	00005517          	auipc	a0,0x5
    80002960:	7ac50513          	addi	a0,a0,1964 # 80008108 <digits+0xc8>
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	c26080e7          	jalr	-986(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000296c:	0022f497          	auipc	s1,0x22f
    80002970:	a0448493          	addi	s1,s1,-1532 # 80231370 <proc+0x158>
    80002974:	00236917          	auipc	s2,0x236
    80002978:	bfc90913          	addi	s2,s2,-1028 # 80238570 <mlfq+0x158>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000297c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000297e:	00006997          	auipc	s3,0x6
    80002982:	94298993          	addi	s3,s3,-1726 # 800082c0 <digits+0x280>
    printf("%d %s %s ctime=%d tickets=%d static_prior=%d", p->pid, state, p->name, p->ctime, p->tickets, p->static_priority);
    80002986:	00006a97          	auipc	s5,0x6
    8000298a:	942a8a93          	addi	s5,s5,-1726 # 800082c8 <digits+0x288>
    printf("\n");
    8000298e:	00005a17          	auipc	s4,0x5
    80002992:	77aa0a13          	addi	s4,s4,1914 # 80008108 <digits+0xc8>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002996:	00006b97          	auipc	s7,0x6
    8000299a:	992b8b93          	addi	s7,s7,-1646 # 80008328 <states.0>
    8000299e:	a02d                	j	800029c8 <procdump+0x82>
    printf("%d %s %s ctime=%d tickets=%d static_prior=%d", p->pid, state, p->name, p->ctime, p->tickets, p->static_priority);
    800029a0:	0286a803          	lw	a6,40(a3)
    800029a4:	529c                	lw	a5,32(a3)
    800029a6:	4ad8                	lw	a4,20(a3)
    800029a8:	ed86a583          	lw	a1,-296(a3)
    800029ac:	8556                	mv	a0,s5
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	bdc080e7          	jalr	-1060(ra) # 8000058a <printf>
    printf("\n");
    800029b6:	8552                	mv	a0,s4
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	bd2080e7          	jalr	-1070(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800029c0:	1c848493          	addi	s1,s1,456
    800029c4:	03248263          	beq	s1,s2,800029e8 <procdump+0xa2>
    if (p->state == UNUSED)
    800029c8:	86a6                	mv	a3,s1
    800029ca:	ec04a783          	lw	a5,-320(s1)
    800029ce:	dbed                	beqz	a5,800029c0 <procdump+0x7a>
      state = "???";
    800029d0:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029d2:	fcfb67e3          	bltu	s6,a5,800029a0 <procdump+0x5a>
    800029d6:	02079713          	slli	a4,a5,0x20
    800029da:	01d75793          	srli	a5,a4,0x1d
    800029de:	97de                	add	a5,a5,s7
    800029e0:	6390                	ld	a2,0(a5)
    800029e2:	fe5d                	bnez	a2,800029a0 <procdump+0x5a>
      state = "???";
    800029e4:	864e                	mv	a2,s3
    800029e6:	bf6d                	j	800029a0 <procdump+0x5a>
  }
}
    800029e8:	60a6                	ld	ra,72(sp)
    800029ea:	6406                	ld	s0,64(sp)
    800029ec:	74e2                	ld	s1,56(sp)
    800029ee:	7942                	ld	s2,48(sp)
    800029f0:	79a2                	ld	s3,40(sp)
    800029f2:	7a02                	ld	s4,32(sp)
    800029f4:	6ae2                	ld	s5,24(sp)
    800029f6:	6b42                	ld	s6,16(sp)
    800029f8:	6ba2                	ld	s7,8(sp)
    800029fa:	6161                	addi	sp,sp,80
    800029fc:	8082                	ret

00000000800029fe <swtch>:
    800029fe:	00153023          	sd	ra,0(a0)
    80002a02:	00253423          	sd	sp,8(a0)
    80002a06:	e900                	sd	s0,16(a0)
    80002a08:	ed04                	sd	s1,24(a0)
    80002a0a:	03253023          	sd	s2,32(a0)
    80002a0e:	03353423          	sd	s3,40(a0)
    80002a12:	03453823          	sd	s4,48(a0)
    80002a16:	03553c23          	sd	s5,56(a0)
    80002a1a:	05653023          	sd	s6,64(a0)
    80002a1e:	05753423          	sd	s7,72(a0)
    80002a22:	05853823          	sd	s8,80(a0)
    80002a26:	05953c23          	sd	s9,88(a0)
    80002a2a:	07a53023          	sd	s10,96(a0)
    80002a2e:	07b53423          	sd	s11,104(a0)
    80002a32:	0005b083          	ld	ra,0(a1)
    80002a36:	0085b103          	ld	sp,8(a1)
    80002a3a:	6980                	ld	s0,16(a1)
    80002a3c:	6d84                	ld	s1,24(a1)
    80002a3e:	0205b903          	ld	s2,32(a1)
    80002a42:	0285b983          	ld	s3,40(a1)
    80002a46:	0305ba03          	ld	s4,48(a1)
    80002a4a:	0385ba83          	ld	s5,56(a1)
    80002a4e:	0405bb03          	ld	s6,64(a1)
    80002a52:	0485bb83          	ld	s7,72(a1)
    80002a56:	0505bc03          	ld	s8,80(a1)
    80002a5a:	0585bc83          	ld	s9,88(a1)
    80002a5e:	0605bd03          	ld	s10,96(a1)
    80002a62:	0685bd83          	ld	s11,104(a1)
    80002a66:	8082                	ret

0000000080002a68 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002a68:	1141                	addi	sp,sp,-16
    80002a6a:	e406                	sd	ra,8(sp)
    80002a6c:	e022                	sd	s0,0(sp)
    80002a6e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a70:	00006597          	auipc	a1,0x6
    80002a74:	8e858593          	addi	a1,a1,-1816 # 80008358 <states.0+0x30>
    80002a78:	00236517          	auipc	a0,0x236
    80002a7c:	3c850513          	addi	a0,a0,968 # 80238e40 <tickslock>
    80002a80:	ffffe097          	auipc	ra,0xffffe
    80002a84:	23a080e7          	jalr	570(ra) # 80000cba <initlock>
}
    80002a88:	60a2                	ld	ra,8(sp)
    80002a8a:	6402                	ld	s0,0(sp)
    80002a8c:	0141                	addi	sp,sp,16
    80002a8e:	8082                	ret

0000000080002a90 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002a90:	1141                	addi	sp,sp,-16
    80002a92:	e422                	sd	s0,8(sp)
    80002a94:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0"
    80002a96:	00004797          	auipc	a5,0x4
    80002a9a:	82a78793          	addi	a5,a5,-2006 # 800062c0 <kernelvec>
    80002a9e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002aa2:	6422                	ld	s0,8(sp)
    80002aa4:	0141                	addi	sp,sp,16
    80002aa6:	8082                	ret

0000000080002aa8 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002aa8:	1141                	addi	sp,sp,-16
    80002aaa:	e406                	sd	ra,8(sp)
    80002aac:	e022                	sd	s0,0(sp)
    80002aae:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	0ac080e7          	jalr	172(ra) # 80001b5c <myproc>
  asm volatile("csrr %0, sstatus"
    80002ab8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002abc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    80002abe:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002ac2:	00004697          	auipc	a3,0x4
    80002ac6:	53e68693          	addi	a3,a3,1342 # 80007000 <_trampoline>
    80002aca:	00004717          	auipc	a4,0x4
    80002ace:	53670713          	addi	a4,a4,1334 # 80007000 <_trampoline>
    80002ad2:	8f15                	sub	a4,a4,a3
    80002ad4:	040007b7          	lui	a5,0x4000
    80002ad8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002ada:	07b2                	slli	a5,a5,0xc
    80002adc:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0"
    80002ade:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ae2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp"
    80002ae4:	18002673          	csrr	a2,satp
    80002ae8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002aea:	6d30                	ld	a2,88(a0)
    80002aec:	6138                	ld	a4,64(a0)
    80002aee:	6585                	lui	a1,0x1
    80002af0:	972e                	add	a4,a4,a1
    80002af2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002af4:	6d38                	ld	a4,88(a0)
    80002af6:	00000617          	auipc	a2,0x0
    80002afa:	2fa60613          	addi	a2,a2,762 # 80002df0 <usertrap>
    80002afe:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002b00:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp"
    80002b02:	8612                	mv	a2,tp
    80002b04:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus"
    80002b06:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b0a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b0e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0"
    80002b12:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b16:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0"
    80002b18:	6f18                	ld	a4,24(a4)
    80002b1a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b1e:	6928                	ld	a0,80(a0)
    80002b20:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b22:	00004717          	auipc	a4,0x4
    80002b26:	57a70713          	addi	a4,a4,1402 # 8000709c <userret>
    80002b2a:	8f15                	sub	a4,a4,a3
    80002b2c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b2e:	577d                	li	a4,-1
    80002b30:	177e                	slli	a4,a4,0x3f
    80002b32:	8d59                	or	a0,a0,a4
    80002b34:	9782                	jalr	a5
}
    80002b36:	60a2                	ld	ra,8(sp)
    80002b38:	6402                	ld	s0,0(sp)
    80002b3a:	0141                	addi	sp,sp,16
    80002b3c:	8082                	ret

0000000080002b3e <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002b3e:	1141                	addi	sp,sp,-16
    80002b40:	e406                	sd	ra,8(sp)
    80002b42:	e022                	sd	s0,0(sp)
    80002b44:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    80002b46:	00236517          	auipc	a0,0x236
    80002b4a:	2fa50513          	addi	a0,a0,762 # 80238e40 <tickslock>
    80002b4e:	ffffe097          	auipc	ra,0xffffe
    80002b52:	1fc080e7          	jalr	508(ra) # 80000d4a <acquire>
  ticks++;
    80002b56:	00006717          	auipc	a4,0x6
    80002b5a:	01270713          	addi	a4,a4,18 # 80008b68 <ticks>
    80002b5e:	431c                	lw	a5,0(a4)
    80002b60:	2785                	addiw	a5,a5,1
    80002b62:	c31c                	sw	a5,0(a4)
  update_time();
    80002b64:	fffff097          	auipc	ra,0xfffff
    80002b68:	59a080e7          	jalr	1434(ra) # 800020fe <update_time>
  if (myproc() != 0)
    80002b6c:	fffff097          	auipc	ra,0xfffff
    80002b70:	ff0080e7          	jalr	-16(ra) # 80001b5c <myproc>
    80002b74:	c11d                	beqz	a0,80002b9a <clockintr+0x5c>
  {
    myproc()->running_ticks++;
    80002b76:	fffff097          	auipc	ra,0xfffff
    80002b7a:	fe6080e7          	jalr	-26(ra) # 80001b5c <myproc>
    80002b7e:	19052783          	lw	a5,400(a0)
    80002b82:	2785                	addiw	a5,a5,1
    80002b84:	18f52823          	sw	a5,400(a0)
    myproc()->change_queue--;
    80002b88:	fffff097          	auipc	ra,0xfffff
    80002b8c:	fd4080e7          	jalr	-44(ra) # 80001b5c <myproc>
    80002b90:	19c52783          	lw	a5,412(a0)
    80002b94:	37fd                	addiw	a5,a5,-1
    80002b96:	18f52e23          	sw	a5,412(a0)
  }
  wakeup(&ticks);
    80002b9a:	00006517          	auipc	a0,0x6
    80002b9e:	fce50513          	addi	a0,a0,-50 # 80008b68 <ticks>
    80002ba2:	00000097          	auipc	ra,0x0
    80002ba6:	928080e7          	jalr	-1752(ra) # 800024ca <wakeup>
  release(&tickslock);
    80002baa:	00236517          	auipc	a0,0x236
    80002bae:	29650513          	addi	a0,a0,662 # 80238e40 <tickslock>
    80002bb2:	ffffe097          	auipc	ra,0xffffe
    80002bb6:	24c080e7          	jalr	588(ra) # 80000dfe <release>
}
    80002bba:	60a2                	ld	ra,8(sp)
    80002bbc:	6402                	ld	s0,0(sp)
    80002bbe:	0141                	addi	sp,sp,16
    80002bc0:	8082                	ret

0000000080002bc2 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002bc2:	1101                	addi	sp,sp,-32
    80002bc4:	ec06                	sd	ra,24(sp)
    80002bc6:	e822                	sd	s0,16(sp)
    80002bc8:	e426                	sd	s1,8(sp)
    80002bca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause"
    80002bcc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002bd0:	00074d63          	bltz	a4,80002bea <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002bd4:	57fd                	li	a5,-1
    80002bd6:	17fe                	slli	a5,a5,0x3f
    80002bd8:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002bda:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002bdc:	06f70363          	beq	a4,a5,80002c42 <devintr+0x80>
  }
}
    80002be0:	60e2                	ld	ra,24(sp)
    80002be2:	6442                	ld	s0,16(sp)
    80002be4:	64a2                	ld	s1,8(sp)
    80002be6:	6105                	addi	sp,sp,32
    80002be8:	8082                	ret
      (scause & 0xff) == 9)
    80002bea:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002bee:	46a5                	li	a3,9
    80002bf0:	fed792e3          	bne	a5,a3,80002bd4 <devintr+0x12>
    int irq = plic_claim();
    80002bf4:	00003097          	auipc	ra,0x3
    80002bf8:	7d4080e7          	jalr	2004(ra) # 800063c8 <plic_claim>
    80002bfc:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002bfe:	47a9                	li	a5,10
    80002c00:	02f50763          	beq	a0,a5,80002c2e <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002c04:	4785                	li	a5,1
    80002c06:	02f50963          	beq	a0,a5,80002c38 <devintr+0x76>
    return 1;
    80002c0a:	4505                	li	a0,1
    else if (irq)
    80002c0c:	d8f1                	beqz	s1,80002be0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c0e:	85a6                	mv	a1,s1
    80002c10:	00005517          	auipc	a0,0x5
    80002c14:	75050513          	addi	a0,a0,1872 # 80008360 <states.0+0x38>
    80002c18:	ffffe097          	auipc	ra,0xffffe
    80002c1c:	972080e7          	jalr	-1678(ra) # 8000058a <printf>
      plic_complete(irq);
    80002c20:	8526                	mv	a0,s1
    80002c22:	00003097          	auipc	ra,0x3
    80002c26:	7ca080e7          	jalr	1994(ra) # 800063ec <plic_complete>
    return 1;
    80002c2a:	4505                	li	a0,1
    80002c2c:	bf55                	j	80002be0 <devintr+0x1e>
      uartintr();
    80002c2e:	ffffe097          	auipc	ra,0xffffe
    80002c32:	d6a080e7          	jalr	-662(ra) # 80000998 <uartintr>
    80002c36:	b7ed                	j	80002c20 <devintr+0x5e>
      virtio_disk_intr();
    80002c38:	00004097          	auipc	ra,0x4
    80002c3c:	f50080e7          	jalr	-176(ra) # 80006b88 <virtio_disk_intr>
    80002c40:	b7c5                	j	80002c20 <devintr+0x5e>
    if (cpuid() == 0)
    80002c42:	fffff097          	auipc	ra,0xfffff
    80002c46:	eee080e7          	jalr	-274(ra) # 80001b30 <cpuid>
    80002c4a:	c901                	beqz	a0,80002c5a <devintr+0x98>
  asm volatile("csrr %0, sip"
    80002c4c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c50:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0"
    80002c52:	14479073          	csrw	sip,a5
    return 2;
    80002c56:	4509                	li	a0,2
    80002c58:	b761                	j	80002be0 <devintr+0x1e>
      clockintr();
    80002c5a:	00000097          	auipc	ra,0x0
    80002c5e:	ee4080e7          	jalr	-284(ra) # 80002b3e <clockintr>
    80002c62:	b7ed                	j	80002c4c <devintr+0x8a>

0000000080002c64 <kerneltrap>:
{
    80002c64:	7179                	addi	sp,sp,-48
    80002c66:	f406                	sd	ra,40(sp)
    80002c68:	f022                	sd	s0,32(sp)
    80002c6a:	ec26                	sd	s1,24(sp)
    80002c6c:	e84a                	sd	s2,16(sp)
    80002c6e:	e44e                	sd	s3,8(sp)
    80002c70:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc"
    80002c72:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus"
    80002c76:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause"
    80002c7a:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002c7e:	1004f793          	andi	a5,s1,256
    80002c82:	cb85                	beqz	a5,80002cb2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus"
    80002c84:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c88:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002c8a:	ef85                	bnez	a5,80002cc2 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002c8c:	00000097          	auipc	ra,0x0
    80002c90:	f36080e7          	jalr	-202(ra) # 80002bc2 <devintr>
    80002c94:	cd1d                	beqz	a0,80002cd2 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c96:	4789                	li	a5,2
    80002c98:	06f50a63          	beq	a0,a5,80002d0c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0"
    80002c9c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0"
    80002ca0:	10049073          	csrw	sstatus,s1
}
    80002ca4:	70a2                	ld	ra,40(sp)
    80002ca6:	7402                	ld	s0,32(sp)
    80002ca8:	64e2                	ld	s1,24(sp)
    80002caa:	6942                	ld	s2,16(sp)
    80002cac:	69a2                	ld	s3,8(sp)
    80002cae:	6145                	addi	sp,sp,48
    80002cb0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cb2:	00005517          	auipc	a0,0x5
    80002cb6:	6ce50513          	addi	a0,a0,1742 # 80008380 <states.0+0x58>
    80002cba:	ffffe097          	auipc	ra,0xffffe
    80002cbe:	886080e7          	jalr	-1914(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002cc2:	00005517          	auipc	a0,0x5
    80002cc6:	6e650513          	addi	a0,a0,1766 # 800083a8 <states.0+0x80>
    80002cca:	ffffe097          	auipc	ra,0xffffe
    80002cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002cd2:	85ce                	mv	a1,s3
    80002cd4:	00005517          	auipc	a0,0x5
    80002cd8:	6f450513          	addi	a0,a0,1780 # 800083c8 <states.0+0xa0>
    80002cdc:	ffffe097          	auipc	ra,0xffffe
    80002ce0:	8ae080e7          	jalr	-1874(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002ce4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002ce8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cec:	00005517          	auipc	a0,0x5
    80002cf0:	6ec50513          	addi	a0,a0,1772 # 800083d8 <states.0+0xb0>
    80002cf4:	ffffe097          	auipc	ra,0xffffe
    80002cf8:	896080e7          	jalr	-1898(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002cfc:	00005517          	auipc	a0,0x5
    80002d00:	6f450513          	addi	a0,a0,1780 # 800083f0 <states.0+0xc8>
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	83c080e7          	jalr	-1988(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d0c:	fffff097          	auipc	ra,0xfffff
    80002d10:	e50080e7          	jalr	-432(ra) # 80001b5c <myproc>
    80002d14:	d541                	beqz	a0,80002c9c <kerneltrap+0x38>
    80002d16:	fffff097          	auipc	ra,0xfffff
    80002d1a:	e46080e7          	jalr	-442(ra) # 80001b5c <myproc>
    80002d1e:	4d18                	lw	a4,24(a0)
    80002d20:	4791                	li	a5,4
    80002d22:	f6f71de3          	bne	a4,a5,80002c9c <kerneltrap+0x38>
    yield();
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	5ac080e7          	jalr	1452(ra) # 800022d2 <yield>
    80002d2e:	b7bd                	j	80002c9c <kerneltrap+0x38>

0000000080002d30 <pgfault>:

// -1 means cannot alloc mem
// -2 means the address is invalid
// 0 means ok
int pgfault(uint64 va, pagetable_t pagetable)
{
    80002d30:	7179                	addi	sp,sp,-48
    80002d32:	f406                	sd	ra,40(sp)
    80002d34:	f022                	sd	s0,32(sp)
    80002d36:	ec26                	sd	s1,24(sp)
    80002d38:	e84a                	sd	s2,16(sp)
    80002d3a:	e44e                	sd	s3,8(sp)
    80002d3c:	e052                	sd	s4,0(sp)
    80002d3e:	1800                	addi	s0,sp,48
    80002d40:	84aa                	mv	s1,a0
    80002d42:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d44:	fffff097          	auipc	ra,0xfffff
    80002d48:	e18080e7          	jalr	-488(ra) # 80001b5c <myproc>
  if (va >= MAXVA || (va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE && va <= PGROUNDDOWN(p->trapframe->sp)))
    80002d4c:	57fd                	li	a5,-1
    80002d4e:	83e9                	srli	a5,a5,0x1a
    80002d50:	0897e663          	bltu	a5,s1,80002ddc <pgfault+0xac>
    80002d54:	6d38                	ld	a4,88(a0)
    80002d56:	77fd                	lui	a5,0xfffff
    80002d58:	7b18                	ld	a4,48(a4)
    80002d5a:	8f7d                	and	a4,a4,a5
    80002d5c:	97ba                	add	a5,a5,a4
    80002d5e:	00f4e463          	bltu	s1,a5,80002d66 <pgfault+0x36>
    80002d62:	06977f63          	bgeu	a4,s1,80002de0 <pgfault+0xb0>
  {
    return -2;
  }
  va = PGROUNDDOWN(va);
  pte_t *pte = walk(pagetable, va, 0);
    80002d66:	4601                	li	a2,0
    80002d68:	75fd                	lui	a1,0xfffff
    80002d6a:	8de5                	and	a1,a1,s1
    80002d6c:	854a                	mv	a0,s2
    80002d6e:	ffffe097          	auipc	ra,0xffffe
    80002d72:	3bc080e7          	jalr	956(ra) # 8000112a <walk>
    80002d76:	84aa                	mv	s1,a0
  if (pte == 0)
    80002d78:	c535                	beqz	a0,80002de4 <pgfault+0xb4>
    return -1;
  
  uint64 pa = PTE2PA(*pte);
    80002d7a:	611c                	ld	a5,0(a0)
    80002d7c:	00a7d913          	srli	s2,a5,0xa
    80002d80:	0932                	slli	s2,s2,0xc
  if (pa == 0)
    80002d82:	06090363          	beqz	s2,80002de8 <pgfault+0xb8>
  {
    return -1;
  }
  uint flags = PTE_FLAGS(*pte);
    80002d86:	0007871b          	sext.w	a4,a5
  if (flags & PTE_C)
    80002d8a:	1007f793          	andi	a5,a5,256
    //   printf("sometthing is wrong in mappages in trap.\n");
    // }

    return 0;
  }
  return 0;
    80002d8e:	4501                	li	a0,0
  if (flags & PTE_C)
    80002d90:	eb89                	bnez	a5,80002da2 <pgfault+0x72>
}
    80002d92:	70a2                	ld	ra,40(sp)
    80002d94:	7402                	ld	s0,32(sp)
    80002d96:	64e2                	ld	s1,24(sp)
    80002d98:	6942                	ld	s2,16(sp)
    80002d9a:	69a2                	ld	s3,8(sp)
    80002d9c:	6a02                	ld	s4,0(sp)
    80002d9e:	6145                	addi	sp,sp,48
    80002da0:	8082                	ret
    flags = (flags | PTE_W) & (~PTE_C);
    80002da2:	2ff77713          	andi	a4,a4,767
    80002da6:	00476993          	ori	s3,a4,4
    char *mem = kalloc();
    80002daa:	ffffe097          	auipc	ra,0xffffe
    80002dae:	ea6080e7          	jalr	-346(ra) # 80000c50 <kalloc>
    80002db2:	8a2a                	mv	s4,a0
    if (mem == 0)
    80002db4:	cd05                	beqz	a0,80002dec <pgfault+0xbc>
    memmove(mem, (void *)pa, PGSIZE);
    80002db6:	6605                	lui	a2,0x1
    80002db8:	85ca                	mv	a1,s2
    80002dba:	ffffe097          	auipc	ra,0xffffe
    80002dbe:	0e8080e7          	jalr	232(ra) # 80000ea2 <memmove>
    *pte = PA2PTE(mem) | flags;
    80002dc2:	00ca5a13          	srli	s4,s4,0xc
    80002dc6:	0a2a                	slli	s4,s4,0xa
    80002dc8:	0149e733          	or	a4,s3,s4
    80002dcc:	e098                	sd	a4,0(s1)
    kfree((void *)pa);
    80002dce:	854a                	mv	a0,s2
    80002dd0:	ffffe097          	auipc	ra,0xffffe
    80002dd4:	ca8080e7          	jalr	-856(ra) # 80000a78 <kfree>
    return 0;
    80002dd8:	4501                	li	a0,0
    80002dda:	bf65                	j	80002d92 <pgfault+0x62>
    return -2;
    80002ddc:	5579                	li	a0,-2
    80002dde:	bf55                	j	80002d92 <pgfault+0x62>
    80002de0:	5579                	li	a0,-2
    80002de2:	bf45                	j	80002d92 <pgfault+0x62>
    return -1;
    80002de4:	557d                	li	a0,-1
    80002de6:	b775                	j	80002d92 <pgfault+0x62>
    return -1;
    80002de8:	557d                	li	a0,-1
    80002dea:	b765                	j	80002d92 <pgfault+0x62>
      return -1;
    80002dec:	557d                	li	a0,-1
    80002dee:	b755                	j	80002d92 <pgfault+0x62>

0000000080002df0 <usertrap>:
{
    80002df0:	1101                	addi	sp,sp,-32
    80002df2:	ec06                	sd	ra,24(sp)
    80002df4:	e822                	sd	s0,16(sp)
    80002df6:	e426                	sd	s1,8(sp)
    80002df8:	e04a                	sd	s2,0(sp)
    80002dfa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80002dfc:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002e00:	1007f793          	andi	a5,a5,256
    80002e04:	efad                	bnez	a5,80002e7e <usertrap+0x8e>
  asm volatile("csrw stvec, %0"
    80002e06:	00003797          	auipc	a5,0x3
    80002e0a:	4ba78793          	addi	a5,a5,1210 # 800062c0 <kernelvec>
    80002e0e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e12:	fffff097          	auipc	ra,0xfffff
    80002e16:	d4a080e7          	jalr	-694(ra) # 80001b5c <myproc>
    80002e1a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e1c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc"
    80002e1e:	14102773          	csrr	a4,sepc
    80002e22:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause"
    80002e24:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002e28:	47a1                	li	a5,8
    80002e2a:	06f70263          	beq	a4,a5,80002e8e <usertrap+0x9e>
  else if ((which_dev = devintr()) != 0)
    80002e2e:	00000097          	auipc	ra,0x0
    80002e32:	d94080e7          	jalr	-620(ra) # 80002bc2 <devintr>
    80002e36:	892a                	mv	s2,a0
    80002e38:	ed5d                	bnez	a0,80002ef6 <usertrap+0x106>
    80002e3a:	14202773          	csrr	a4,scause
  else if (r_scause() == 15)
    80002e3e:	47bd                	li	a5,15
    80002e40:	0af70063          	beq	a4,a5,80002ee0 <usertrap+0xf0>
    80002e44:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e48:	5890                	lw	a2,48(s1)
    80002e4a:	00005517          	auipc	a0,0x5
    80002e4e:	5d650513          	addi	a0,a0,1494 # 80008420 <states.0+0xf8>
    80002e52:	ffffd097          	auipc	ra,0xffffd
    80002e56:	738080e7          	jalr	1848(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002e5a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002e5e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e62:	00005517          	auipc	a0,0x5
    80002e66:	5ee50513          	addi	a0,a0,1518 # 80008450 <states.0+0x128>
    80002e6a:	ffffd097          	auipc	ra,0xffffd
    80002e6e:	720080e7          	jalr	1824(ra) # 8000058a <printf>
    setkilled(p);
    80002e72:	8526                	mv	a0,s1
    80002e74:	00000097          	auipc	ra,0x0
    80002e78:	89a080e7          	jalr	-1894(ra) # 8000270e <setkilled>
    80002e7c:	a825                	j	80002eb4 <usertrap+0xc4>
    panic("usertrap: not from user mode");
    80002e7e:	00005517          	auipc	a0,0x5
    80002e82:	58250513          	addi	a0,a0,1410 # 80008400 <states.0+0xd8>
    80002e86:	ffffd097          	auipc	ra,0xffffd
    80002e8a:	6ba080e7          	jalr	1722(ra) # 80000540 <panic>
    if (killed(p))
    80002e8e:	00000097          	auipc	ra,0x0
    80002e92:	8ac080e7          	jalr	-1876(ra) # 8000273a <killed>
    80002e96:	ed1d                	bnez	a0,80002ed4 <usertrap+0xe4>
    p->trapframe->epc += 4;
    80002e98:	6cb8                	ld	a4,88(s1)
    80002e9a:	6f1c                	ld	a5,24(a4)
    80002e9c:	0791                	addi	a5,a5,4
    80002e9e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus"
    80002ea0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ea4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002ea8:	10079073          	csrw	sstatus,a5
    syscall();
    80002eac:	00000097          	auipc	ra,0x0
    80002eb0:	240080e7          	jalr	576(ra) # 800030ec <syscall>
  if (killed(p))
    80002eb4:	8526                	mv	a0,s1
    80002eb6:	00000097          	auipc	ra,0x0
    80002eba:	884080e7          	jalr	-1916(ra) # 8000273a <killed>
    80002ebe:	e139                	bnez	a0,80002f04 <usertrap+0x114>
  usertrapret();
    80002ec0:	00000097          	auipc	ra,0x0
    80002ec4:	be8080e7          	jalr	-1048(ra) # 80002aa8 <usertrapret>
}
    80002ec8:	60e2                	ld	ra,24(sp)
    80002eca:	6442                	ld	s0,16(sp)
    80002ecc:	64a2                	ld	s1,8(sp)
    80002ece:	6902                	ld	s2,0(sp)
    80002ed0:	6105                	addi	sp,sp,32
    80002ed2:	8082                	ret
      exit(-1);
    80002ed4:	557d                	li	a0,-1
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	6e4080e7          	jalr	1764(ra) # 800025ba <exit>
    80002ede:	bf6d                	j	80002e98 <usertrap+0xa8>
  asm volatile("csrr %0, stval"
    80002ee0:	14302573          	csrr	a0,stval
    int r = pgfault(r_stval(), p->pagetable);
    80002ee4:	68ac                	ld	a1,80(s1)
    80002ee6:	00000097          	auipc	ra,0x0
    80002eea:	e4a080e7          	jalr	-438(ra) # 80002d30 <pgfault>
    if (r)
    80002eee:	d179                	beqz	a0,80002eb4 <usertrap+0xc4>
      p->killed = 1;
    80002ef0:	4785                	li	a5,1
    80002ef2:	d49c                	sw	a5,40(s1)
    80002ef4:	b7c1                	j	80002eb4 <usertrap+0xc4>
  if (killed(p))
    80002ef6:	8526                	mv	a0,s1
    80002ef8:	00000097          	auipc	ra,0x0
    80002efc:	842080e7          	jalr	-1982(ra) # 8000273a <killed>
    80002f00:	c901                	beqz	a0,80002f10 <usertrap+0x120>
    80002f02:	a011                	j	80002f06 <usertrap+0x116>
    80002f04:	4901                	li	s2,0
    exit(-1);
    80002f06:	557d                	li	a0,-1
    80002f08:	fffff097          	auipc	ra,0xfffff
    80002f0c:	6b2080e7          	jalr	1714(ra) # 800025ba <exit>
  if (which_dev == 2)
    80002f10:	4789                	li	a5,2
    80002f12:	faf917e3          	bne	s2,a5,80002ec0 <usertrap+0xd0>
    if (p->interval)
    80002f16:	1b04a703          	lw	a4,432(s1)
    80002f1a:	cf19                	beqz	a4,80002f38 <usertrap+0x148>
      p->now_ticks++;
    80002f1c:	1b44a783          	lw	a5,436(s1)
    80002f20:	2785                	addiw	a5,a5,1
    80002f22:	0007869b          	sext.w	a3,a5
    80002f26:	1af4aa23          	sw	a5,436(s1)
      if (!p->sigalarm_status && p->interval > 0 && p->now_ticks >= p->interval)
    80002f2a:	1c04a783          	lw	a5,448(s1)
    80002f2e:	e789                	bnez	a5,80002f38 <usertrap+0x148>
    80002f30:	00e05463          	blez	a4,80002f38 <usertrap+0x148>
    80002f34:	00e6d763          	bge	a3,a4,80002f42 <usertrap+0x152>
    yield();
    80002f38:	fffff097          	auipc	ra,0xfffff
    80002f3c:	39a080e7          	jalr	922(ra) # 800022d2 <yield>
    80002f40:	b741                	j	80002ec0 <usertrap+0xd0>
        p->now_ticks = 0;
    80002f42:	1a04aa23          	sw	zero,436(s1)
        p->sigalarm_status = 1;
    80002f46:	4785                	li	a5,1
    80002f48:	1cf4a023          	sw	a5,448(s1)
        p->alarm_trapframe = kalloc();
    80002f4c:	ffffe097          	auipc	ra,0xffffe
    80002f50:	d04080e7          	jalr	-764(ra) # 80000c50 <kalloc>
    80002f54:	1aa4bc23          	sd	a0,440(s1)
        memmove(p->alarm_trapframe, p->trapframe, PGSIZE);
    80002f58:	6605                	lui	a2,0x1
    80002f5a:	6cac                	ld	a1,88(s1)
    80002f5c:	ffffe097          	auipc	ra,0xffffe
    80002f60:	f46080e7          	jalr	-186(ra) # 80000ea2 <memmove>
        p->trapframe->epc = p->handler;
    80002f64:	6cbc                	ld	a5,88(s1)
    80002f66:	1a84b703          	ld	a4,424(s1)
    80002f6a:	ef98                	sd	a4,24(a5)
    80002f6c:	b7f1                	j	80002f38 <usertrap+0x148>

0000000080002f6e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f6e:	1101                	addi	sp,sp,-32
    80002f70:	ec06                	sd	ra,24(sp)
    80002f72:	e822                	sd	s0,16(sp)
    80002f74:	e426                	sd	s1,8(sp)
    80002f76:	1000                	addi	s0,sp,32
    80002f78:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	be2080e7          	jalr	-1054(ra) # 80001b5c <myproc>
  switch (n)
    80002f82:	4795                	li	a5,5
    80002f84:	0497e163          	bltu	a5,s1,80002fc6 <argraw+0x58>
    80002f88:	048a                	slli	s1,s1,0x2
    80002f8a:	00005717          	auipc	a4,0x5
    80002f8e:	61e70713          	addi	a4,a4,1566 # 800085a8 <states.0+0x280>
    80002f92:	94ba                	add	s1,s1,a4
    80002f94:	409c                	lw	a5,0(s1)
    80002f96:	97ba                	add	a5,a5,a4
    80002f98:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002f9a:	6d3c                	ld	a5,88(a0)
    80002f9c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002f9e:	60e2                	ld	ra,24(sp)
    80002fa0:	6442                	ld	s0,16(sp)
    80002fa2:	64a2                	ld	s1,8(sp)
    80002fa4:	6105                	addi	sp,sp,32
    80002fa6:	8082                	ret
    return p->trapframe->a1;
    80002fa8:	6d3c                	ld	a5,88(a0)
    80002faa:	7fa8                	ld	a0,120(a5)
    80002fac:	bfcd                	j	80002f9e <argraw+0x30>
    return p->trapframe->a2;
    80002fae:	6d3c                	ld	a5,88(a0)
    80002fb0:	63c8                	ld	a0,128(a5)
    80002fb2:	b7f5                	j	80002f9e <argraw+0x30>
    return p->trapframe->a3;
    80002fb4:	6d3c                	ld	a5,88(a0)
    80002fb6:	67c8                	ld	a0,136(a5)
    80002fb8:	b7dd                	j	80002f9e <argraw+0x30>
    return p->trapframe->a4;
    80002fba:	6d3c                	ld	a5,88(a0)
    80002fbc:	6bc8                	ld	a0,144(a5)
    80002fbe:	b7c5                	j	80002f9e <argraw+0x30>
    return p->trapframe->a5;
    80002fc0:	6d3c                	ld	a5,88(a0)
    80002fc2:	6fc8                	ld	a0,152(a5)
    80002fc4:	bfe9                	j	80002f9e <argraw+0x30>
  panic("argraw");
    80002fc6:	00005517          	auipc	a0,0x5
    80002fca:	4aa50513          	addi	a0,a0,1194 # 80008470 <states.0+0x148>
    80002fce:	ffffd097          	auipc	ra,0xffffd
    80002fd2:	572080e7          	jalr	1394(ra) # 80000540 <panic>

0000000080002fd6 <fetchaddr>:
{
    80002fd6:	1101                	addi	sp,sp,-32
    80002fd8:	ec06                	sd	ra,24(sp)
    80002fda:	e822                	sd	s0,16(sp)
    80002fdc:	e426                	sd	s1,8(sp)
    80002fde:	e04a                	sd	s2,0(sp)
    80002fe0:	1000                	addi	s0,sp,32
    80002fe2:	84aa                	mv	s1,a0
    80002fe4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002fe6:	fffff097          	auipc	ra,0xfffff
    80002fea:	b76080e7          	jalr	-1162(ra) # 80001b5c <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002fee:	653c                	ld	a5,72(a0)
    80002ff0:	02f4f863          	bgeu	s1,a5,80003020 <fetchaddr+0x4a>
    80002ff4:	00848713          	addi	a4,s1,8
    80002ff8:	02e7e663          	bltu	a5,a4,80003024 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ffc:	46a1                	li	a3,8
    80002ffe:	8626                	mv	a2,s1
    80003000:	85ca                	mv	a1,s2
    80003002:	6928                	ld	a0,80(a0)
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	8a4080e7          	jalr	-1884(ra) # 800018a8 <copyin>
    8000300c:	00a03533          	snez	a0,a0
    80003010:	40a00533          	neg	a0,a0
}
    80003014:	60e2                	ld	ra,24(sp)
    80003016:	6442                	ld	s0,16(sp)
    80003018:	64a2                	ld	s1,8(sp)
    8000301a:	6902                	ld	s2,0(sp)
    8000301c:	6105                	addi	sp,sp,32
    8000301e:	8082                	ret
    return -1;
    80003020:	557d                	li	a0,-1
    80003022:	bfcd                	j	80003014 <fetchaddr+0x3e>
    80003024:	557d                	li	a0,-1
    80003026:	b7fd                	j	80003014 <fetchaddr+0x3e>

0000000080003028 <fetchstr>:
{
    80003028:	7179                	addi	sp,sp,-48
    8000302a:	f406                	sd	ra,40(sp)
    8000302c:	f022                	sd	s0,32(sp)
    8000302e:	ec26                	sd	s1,24(sp)
    80003030:	e84a                	sd	s2,16(sp)
    80003032:	e44e                	sd	s3,8(sp)
    80003034:	1800                	addi	s0,sp,48
    80003036:	892a                	mv	s2,a0
    80003038:	84ae                	mv	s1,a1
    8000303a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000303c:	fffff097          	auipc	ra,0xfffff
    80003040:	b20080e7          	jalr	-1248(ra) # 80001b5c <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003044:	86ce                	mv	a3,s3
    80003046:	864a                	mv	a2,s2
    80003048:	85a6                	mv	a1,s1
    8000304a:	6928                	ld	a0,80(a0)
    8000304c:	fffff097          	auipc	ra,0xfffff
    80003050:	8ea080e7          	jalr	-1814(ra) # 80001936 <copyinstr>
    80003054:	00054e63          	bltz	a0,80003070 <fetchstr+0x48>
  return strlen(buf);
    80003058:	8526                	mv	a0,s1
    8000305a:	ffffe097          	auipc	ra,0xffffe
    8000305e:	f68080e7          	jalr	-152(ra) # 80000fc2 <strlen>
}
    80003062:	70a2                	ld	ra,40(sp)
    80003064:	7402                	ld	s0,32(sp)
    80003066:	64e2                	ld	s1,24(sp)
    80003068:	6942                	ld	s2,16(sp)
    8000306a:	69a2                	ld	s3,8(sp)
    8000306c:	6145                	addi	sp,sp,48
    8000306e:	8082                	ret
    return -1;
    80003070:	557d                	li	a0,-1
    80003072:	bfc5                	j	80003062 <fetchstr+0x3a>

0000000080003074 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003074:	1101                	addi	sp,sp,-32
    80003076:	ec06                	sd	ra,24(sp)
    80003078:	e822                	sd	s0,16(sp)
    8000307a:	e426                	sd	s1,8(sp)
    8000307c:	1000                	addi	s0,sp,32
    8000307e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003080:	00000097          	auipc	ra,0x0
    80003084:	eee080e7          	jalr	-274(ra) # 80002f6e <argraw>
    80003088:	c088                	sw	a0,0(s1)
}
    8000308a:	60e2                	ld	ra,24(sp)
    8000308c:	6442                	ld	s0,16(sp)
    8000308e:	64a2                	ld	s1,8(sp)
    80003090:	6105                	addi	sp,sp,32
    80003092:	8082                	ret

0000000080003094 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003094:	1101                	addi	sp,sp,-32
    80003096:	ec06                	sd	ra,24(sp)
    80003098:	e822                	sd	s0,16(sp)
    8000309a:	e426                	sd	s1,8(sp)
    8000309c:	1000                	addi	s0,sp,32
    8000309e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030a0:	00000097          	auipc	ra,0x0
    800030a4:	ece080e7          	jalr	-306(ra) # 80002f6e <argraw>
    800030a8:	e088                	sd	a0,0(s1)
}
    800030aa:	60e2                	ld	ra,24(sp)
    800030ac:	6442                	ld	s0,16(sp)
    800030ae:	64a2                	ld	s1,8(sp)
    800030b0:	6105                	addi	sp,sp,32
    800030b2:	8082                	ret

00000000800030b4 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    800030b4:	7179                	addi	sp,sp,-48
    800030b6:	f406                	sd	ra,40(sp)
    800030b8:	f022                	sd	s0,32(sp)
    800030ba:	ec26                	sd	s1,24(sp)
    800030bc:	e84a                	sd	s2,16(sp)
    800030be:	1800                	addi	s0,sp,48
    800030c0:	84ae                	mv	s1,a1
    800030c2:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800030c4:	fd840593          	addi	a1,s0,-40
    800030c8:	00000097          	auipc	ra,0x0
    800030cc:	fcc080e7          	jalr	-52(ra) # 80003094 <argaddr>
  return fetchstr(addr, buf, max);
    800030d0:	864a                	mv	a2,s2
    800030d2:	85a6                	mv	a1,s1
    800030d4:	fd843503          	ld	a0,-40(s0)
    800030d8:	00000097          	auipc	ra,0x0
    800030dc:	f50080e7          	jalr	-176(ra) # 80003028 <fetchstr>
}
    800030e0:	70a2                	ld	ra,40(sp)
    800030e2:	7402                	ld	s0,32(sp)
    800030e4:	64e2                	ld	s1,24(sp)
    800030e6:	6942                	ld	s2,16(sp)
    800030e8:	6145                	addi	sp,sp,48
    800030ea:	8082                	ret

00000000800030ec <syscall>:
    "sigreturn",
    "waitx",
};

void syscall(void)
{
    800030ec:	7179                	addi	sp,sp,-48
    800030ee:	f406                	sd	ra,40(sp)
    800030f0:	f022                	sd	s0,32(sp)
    800030f2:	ec26                	sd	s1,24(sp)
    800030f4:	e84a                	sd	s2,16(sp)
    800030f6:	e44e                	sd	s3,8(sp)
    800030f8:	e052                	sd	s4,0(sp)
    800030fa:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    800030fc:	fffff097          	auipc	ra,0xfffff
    80003100:	a60080e7          	jalr	-1440(ra) # 80001b5c <myproc>
    80003104:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003106:	05853903          	ld	s2,88(a0)
    8000310a:	0a893783          	ld	a5,168(s2)
    8000310e:	0007899b          	sext.w	s3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003112:	37fd                	addiw	a5,a5,-1
    80003114:	4765                	li	a4,25
    80003116:	06f76e63          	bltu	a4,a5,80003192 <syscall+0xa6>
    8000311a:	00399713          	slli	a4,s3,0x3
    8000311e:	00005797          	auipc	a5,0x5
    80003122:	4a278793          	addi	a5,a5,1186 # 800085c0 <syscalls>
    80003126:	97ba                	add	a5,a5,a4
    80003128:	639c                	ld	a5,0(a5)
    8000312a:	c7a5                	beqz	a5,80003192 <syscall+0xa6>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0

    int arg0 = p->trapframe->a0;
    8000312c:	07093a03          	ld	s4,112(s2)
    short argcount = (num == SYS_read || num == SYS_write || num == SYS_mknod || SYS_waitx) ? 3
    : ((num == SYS_exec || num == SYS_fstat || num == SYS_open || num == SYS_link || num == SYS_sigalarm) ? 2
    : ((num == SYS_wait || num == SYS_pipe || num == SYS_kill || num == SYS_chdir || num == SYS_dup || num == SYS_sbrk || num == SYS_sleep || num == SYS_unlink || num == SYS_mkdir || num == SYS_close || num == SYS_settickets) ? 1
    : 0));

    p->trapframe->a0 = syscalls[num]();
    80003130:	9782                	jalr	a5
    80003132:	06a93823          	sd	a0,112(s2)

    if ((p->tmask >> num) & 0x1)
    80003136:	1744a783          	lw	a5,372(s1)
    8000313a:	0137d7bb          	srlw	a5,a5,s3
    8000313e:	8b85                	andi	a5,a5,1
    80003140:	cba5                	beqz	a5,800031b0 <syscall+0xc4>
    {
      printf("%d: syscall %s (", p->pid, syscall_name[num]);
    80003142:	098e                	slli	s3,s3,0x3
    80003144:	00006797          	auipc	a5,0x6
    80003148:	8f478793          	addi	a5,a5,-1804 # 80008a38 <syscall_name>
    8000314c:	97ce                	add	a5,a5,s3
    8000314e:	6390                	ld	a2,0(a5)
    80003150:	588c                	lw	a1,48(s1)
    80003152:	00005517          	auipc	a0,0x5
    80003156:	32650513          	addi	a0,a0,806 # 80008478 <states.0+0x150>
    8000315a:	ffffd097          	auipc	ra,0xffffd
    8000315e:	430080e7          	jalr	1072(ra) # 8000058a <printf>
      if (argcount == 1)
        printf("%d ", arg0);
      else if (argcount == 2)
        printf("%d %d ", arg0, p->trapframe->a1);
      else if (argcount == 3)
        printf("%d %d %d ", arg0, p->trapframe->a1, p->trapframe->a2);
    80003162:	6cbc                	ld	a5,88(s1)
    80003164:	63d4                	ld	a3,128(a5)
    80003166:	7fb0                	ld	a2,120(a5)
    80003168:	000a059b          	sext.w	a1,s4
    8000316c:	00005517          	auipc	a0,0x5
    80003170:	32450513          	addi	a0,a0,804 # 80008490 <states.0+0x168>
    80003174:	ffffd097          	auipc	ra,0xffffd
    80003178:	416080e7          	jalr	1046(ra) # 8000058a <printf>

      printf(") -> %d\n", p->trapframe->a0);
    8000317c:	6cbc                	ld	a5,88(s1)
    8000317e:	7bac                	ld	a1,112(a5)
    80003180:	00005517          	auipc	a0,0x5
    80003184:	32050513          	addi	a0,a0,800 # 800084a0 <states.0+0x178>
    80003188:	ffffd097          	auipc	ra,0xffffd
    8000318c:	402080e7          	jalr	1026(ra) # 8000058a <printf>
    80003190:	a005                	j	800031b0 <syscall+0xc4>
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80003192:	86ce                	mv	a3,s3
    80003194:	15848613          	addi	a2,s1,344
    80003198:	588c                	lw	a1,48(s1)
    8000319a:	00005517          	auipc	a0,0x5
    8000319e:	31650513          	addi	a0,a0,790 # 800084b0 <states.0+0x188>
    800031a2:	ffffd097          	auipc	ra,0xffffd
    800031a6:	3e8080e7          	jalr	1000(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800031aa:	6cbc                	ld	a5,88(s1)
    800031ac:	577d                	li	a4,-1
    800031ae:	fbb8                	sd	a4,112(a5)
  }
}
    800031b0:	70a2                	ld	ra,40(sp)
    800031b2:	7402                	ld	s0,32(sp)
    800031b4:	64e2                	ld	s1,24(sp)
    800031b6:	6942                	ld	s2,16(sp)
    800031b8:	69a2                	ld	s3,8(sp)
    800031ba:	6a02                	ld	s4,0(sp)
    800031bc:	6145                	addi	sp,sp,48
    800031be:	8082                	ret

00000000800031c0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800031c0:	1101                	addi	sp,sp,-32
    800031c2:	ec06                	sd	ra,24(sp)
    800031c4:	e822                	sd	s0,16(sp)
    800031c6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800031c8:	fec40593          	addi	a1,s0,-20
    800031cc:	4501                	li	a0,0
    800031ce:	00000097          	auipc	ra,0x0
    800031d2:	ea6080e7          	jalr	-346(ra) # 80003074 <argint>
  exit(n);
    800031d6:	fec42503          	lw	a0,-20(s0)
    800031da:	fffff097          	auipc	ra,0xfffff
    800031de:	3e0080e7          	jalr	992(ra) # 800025ba <exit>
  return 0; // not reached
}
    800031e2:	4501                	li	a0,0
    800031e4:	60e2                	ld	ra,24(sp)
    800031e6:	6442                	ld	s0,16(sp)
    800031e8:	6105                	addi	sp,sp,32
    800031ea:	8082                	ret

00000000800031ec <sys_getpid>:

uint64
sys_getpid(void)
{
    800031ec:	1141                	addi	sp,sp,-16
    800031ee:	e406                	sd	ra,8(sp)
    800031f0:	e022                	sd	s0,0(sp)
    800031f2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800031f4:	fffff097          	auipc	ra,0xfffff
    800031f8:	968080e7          	jalr	-1688(ra) # 80001b5c <myproc>
}
    800031fc:	5908                	lw	a0,48(a0)
    800031fe:	60a2                	ld	ra,8(sp)
    80003200:	6402                	ld	s0,0(sp)
    80003202:	0141                	addi	sp,sp,16
    80003204:	8082                	ret

0000000080003206 <sys_fork>:

uint64
sys_fork(void)
{
    80003206:	1141                	addi	sp,sp,-16
    80003208:	e406                	sd	ra,8(sp)
    8000320a:	e022                	sd	s0,0(sp)
    8000320c:	0800                	addi	s0,sp,16
  return fork();
    8000320e:	fffff097          	auipc	ra,0xfffff
    80003212:	d98080e7          	jalr	-616(ra) # 80001fa6 <fork>
}
    80003216:	60a2                	ld	ra,8(sp)
    80003218:	6402                	ld	s0,0(sp)
    8000321a:	0141                	addi	sp,sp,16
    8000321c:	8082                	ret

000000008000321e <sys_wait>:

uint64
sys_wait(void)
{
    8000321e:	1101                	addi	sp,sp,-32
    80003220:	ec06                	sd	ra,24(sp)
    80003222:	e822                	sd	s0,16(sp)
    80003224:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003226:	fe840593          	addi	a1,s0,-24
    8000322a:	4501                	li	a0,0
    8000322c:	00000097          	auipc	ra,0x0
    80003230:	e68080e7          	jalr	-408(ra) # 80003094 <argaddr>
  return wait(p);
    80003234:	fe843503          	ld	a0,-24(s0)
    80003238:	fffff097          	auipc	ra,0xfffff
    8000323c:	534080e7          	jalr	1332(ra) # 8000276c <wait>
}
    80003240:	60e2                	ld	ra,24(sp)
    80003242:	6442                	ld	s0,16(sp)
    80003244:	6105                	addi	sp,sp,32
    80003246:	8082                	ret

0000000080003248 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003248:	7139                	addi	sp,sp,-64
    8000324a:	fc06                	sd	ra,56(sp)
    8000324c:	f822                	sd	s0,48(sp)
    8000324e:	f426                	sd	s1,40(sp)
    80003250:	f04a                	sd	s2,32(sp)
    80003252:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003254:	fd840593          	addi	a1,s0,-40
    80003258:	4501                	li	a0,0
    8000325a:	00000097          	auipc	ra,0x0
    8000325e:	e3a080e7          	jalr	-454(ra) # 80003094 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003262:	fd040593          	addi	a1,s0,-48
    80003266:	4505                	li	a0,1
    80003268:	00000097          	auipc	ra,0x0
    8000326c:	e2c080e7          	jalr	-468(ra) # 80003094 <argaddr>
  argaddr(2, &addr2);
    80003270:	fc840593          	addi	a1,s0,-56
    80003274:	4509                	li	a0,2
    80003276:	00000097          	auipc	ra,0x0
    8000327a:	e1e080e7          	jalr	-482(ra) # 80003094 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000327e:	fc040613          	addi	a2,s0,-64
    80003282:	fc440593          	addi	a1,s0,-60
    80003286:	fd843503          	ld	a0,-40(s0)
    8000328a:	fffff097          	auipc	ra,0xfffff
    8000328e:	0f4080e7          	jalr	244(ra) # 8000237e <waitx>
    80003292:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003294:	fffff097          	auipc	ra,0xfffff
    80003298:	8c8080e7          	jalr	-1848(ra) # 80001b5c <myproc>
    8000329c:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000329e:	4691                	li	a3,4
    800032a0:	fc440613          	addi	a2,s0,-60
    800032a4:	fd043583          	ld	a1,-48(s0)
    800032a8:	6928                	ld	a0,80(a0)
    800032aa:	ffffe097          	auipc	ra,0xffffe
    800032ae:	536080e7          	jalr	1334(ra) # 800017e0 <copyout>
    return -1;
    800032b2:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800032b4:	00054f63          	bltz	a0,800032d2 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800032b8:	4691                	li	a3,4
    800032ba:	fc040613          	addi	a2,s0,-64
    800032be:	fc843583          	ld	a1,-56(s0)
    800032c2:	68a8                	ld	a0,80(s1)
    800032c4:	ffffe097          	auipc	ra,0xffffe
    800032c8:	51c080e7          	jalr	1308(ra) # 800017e0 <copyout>
    800032cc:	00054a63          	bltz	a0,800032e0 <sys_waitx+0x98>
    return -1;
  return ret;
    800032d0:	87ca                	mv	a5,s2
}
    800032d2:	853e                	mv	a0,a5
    800032d4:	70e2                	ld	ra,56(sp)
    800032d6:	7442                	ld	s0,48(sp)
    800032d8:	74a2                	ld	s1,40(sp)
    800032da:	7902                	ld	s2,32(sp)
    800032dc:	6121                	addi	sp,sp,64
    800032de:	8082                	ret
    return -1;
    800032e0:	57fd                	li	a5,-1
    800032e2:	bfc5                	j	800032d2 <sys_waitx+0x8a>

00000000800032e4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800032e4:	7179                	addi	sp,sp,-48
    800032e6:	f406                	sd	ra,40(sp)
    800032e8:	f022                	sd	s0,32(sp)
    800032ea:	ec26                	sd	s1,24(sp)
    800032ec:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800032ee:	fdc40593          	addi	a1,s0,-36
    800032f2:	4501                	li	a0,0
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	d80080e7          	jalr	-640(ra) # 80003074 <argint>
  addr = myproc()->sz;
    800032fc:	fffff097          	auipc	ra,0xfffff
    80003300:	860080e7          	jalr	-1952(ra) # 80001b5c <myproc>
    80003304:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80003306:	fdc42503          	lw	a0,-36(s0)
    8000330a:	fffff097          	auipc	ra,0xfffff
    8000330e:	c40080e7          	jalr	-960(ra) # 80001f4a <growproc>
    80003312:	00054863          	bltz	a0,80003322 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003316:	8526                	mv	a0,s1
    80003318:	70a2                	ld	ra,40(sp)
    8000331a:	7402                	ld	s0,32(sp)
    8000331c:	64e2                	ld	s1,24(sp)
    8000331e:	6145                	addi	sp,sp,48
    80003320:	8082                	ret
    return -1;
    80003322:	54fd                	li	s1,-1
    80003324:	bfcd                	j	80003316 <sys_sbrk+0x32>

0000000080003326 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003326:	7139                	addi	sp,sp,-64
    80003328:	fc06                	sd	ra,56(sp)
    8000332a:	f822                	sd	s0,48(sp)
    8000332c:	f426                	sd	s1,40(sp)
    8000332e:	f04a                	sd	s2,32(sp)
    80003330:	ec4e                	sd	s3,24(sp)
    80003332:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003334:	fcc40593          	addi	a1,s0,-52
    80003338:	4501                	li	a0,0
    8000333a:	00000097          	auipc	ra,0x0
    8000333e:	d3a080e7          	jalr	-710(ra) # 80003074 <argint>
  acquire(&tickslock);
    80003342:	00236517          	auipc	a0,0x236
    80003346:	afe50513          	addi	a0,a0,-1282 # 80238e40 <tickslock>
    8000334a:	ffffe097          	auipc	ra,0xffffe
    8000334e:	a00080e7          	jalr	-1536(ra) # 80000d4a <acquire>
  ticks0 = ticks;
    80003352:	00006917          	auipc	s2,0x6
    80003356:	81692903          	lw	s2,-2026(s2) # 80008b68 <ticks>
  while (ticks - ticks0 < n)
    8000335a:	fcc42783          	lw	a5,-52(s0)
    8000335e:	cf9d                	beqz	a5,8000339c <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003360:	00236997          	auipc	s3,0x236
    80003364:	ae098993          	addi	s3,s3,-1312 # 80238e40 <tickslock>
    80003368:	00006497          	auipc	s1,0x6
    8000336c:	80048493          	addi	s1,s1,-2048 # 80008b68 <ticks>
    if (killed(myproc()))
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	7ec080e7          	jalr	2028(ra) # 80001b5c <myproc>
    80003378:	fffff097          	auipc	ra,0xfffff
    8000337c:	3c2080e7          	jalr	962(ra) # 8000273a <killed>
    80003380:	ed15                	bnez	a0,800033bc <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003382:	85ce                	mv	a1,s3
    80003384:	8526                	mv	a0,s1
    80003386:	fffff097          	auipc	ra,0xfffff
    8000338a:	f88080e7          	jalr	-120(ra) # 8000230e <sleep>
  while (ticks - ticks0 < n)
    8000338e:	409c                	lw	a5,0(s1)
    80003390:	412787bb          	subw	a5,a5,s2
    80003394:	fcc42703          	lw	a4,-52(s0)
    80003398:	fce7ece3          	bltu	a5,a4,80003370 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000339c:	00236517          	auipc	a0,0x236
    800033a0:	aa450513          	addi	a0,a0,-1372 # 80238e40 <tickslock>
    800033a4:	ffffe097          	auipc	ra,0xffffe
    800033a8:	a5a080e7          	jalr	-1446(ra) # 80000dfe <release>
  return 0;
    800033ac:	4501                	li	a0,0
}
    800033ae:	70e2                	ld	ra,56(sp)
    800033b0:	7442                	ld	s0,48(sp)
    800033b2:	74a2                	ld	s1,40(sp)
    800033b4:	7902                	ld	s2,32(sp)
    800033b6:	69e2                	ld	s3,24(sp)
    800033b8:	6121                	addi	sp,sp,64
    800033ba:	8082                	ret
      release(&tickslock);
    800033bc:	00236517          	auipc	a0,0x236
    800033c0:	a8450513          	addi	a0,a0,-1404 # 80238e40 <tickslock>
    800033c4:	ffffe097          	auipc	ra,0xffffe
    800033c8:	a3a080e7          	jalr	-1478(ra) # 80000dfe <release>
      return -1;
    800033cc:	557d                	li	a0,-1
    800033ce:	b7c5                	j	800033ae <sys_sleep+0x88>

00000000800033d0 <sys_kill>:

uint64
sys_kill(void)
{
    800033d0:	1101                	addi	sp,sp,-32
    800033d2:	ec06                	sd	ra,24(sp)
    800033d4:	e822                	sd	s0,16(sp)
    800033d6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800033d8:	fec40593          	addi	a1,s0,-20
    800033dc:	4501                	li	a0,0
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	c96080e7          	jalr	-874(ra) # 80003074 <argint>
  return kill(pid);
    800033e6:	fec42503          	lw	a0,-20(s0)
    800033ea:	fffff097          	auipc	ra,0xfffff
    800033ee:	2b2080e7          	jalr	690(ra) # 8000269c <kill>
}
    800033f2:	60e2                	ld	ra,24(sp)
    800033f4:	6442                	ld	s0,16(sp)
    800033f6:	6105                	addi	sp,sp,32
    800033f8:	8082                	ret

00000000800033fa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800033fa:	1101                	addi	sp,sp,-32
    800033fc:	ec06                	sd	ra,24(sp)
    800033fe:	e822                	sd	s0,16(sp)
    80003400:	e426                	sd	s1,8(sp)
    80003402:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003404:	00236517          	auipc	a0,0x236
    80003408:	a3c50513          	addi	a0,a0,-1476 # 80238e40 <tickslock>
    8000340c:	ffffe097          	auipc	ra,0xffffe
    80003410:	93e080e7          	jalr	-1730(ra) # 80000d4a <acquire>
  xticks = ticks;
    80003414:	00005497          	auipc	s1,0x5
    80003418:	7544a483          	lw	s1,1876(s1) # 80008b68 <ticks>
  release(&tickslock);
    8000341c:	00236517          	auipc	a0,0x236
    80003420:	a2450513          	addi	a0,a0,-1500 # 80238e40 <tickslock>
    80003424:	ffffe097          	auipc	ra,0xffffe
    80003428:	9da080e7          	jalr	-1574(ra) # 80000dfe <release>
  return xticks;
}
    8000342c:	02049513          	slli	a0,s1,0x20
    80003430:	9101                	srli	a0,a0,0x20
    80003432:	60e2                	ld	ra,24(sp)
    80003434:	6442                	ld	s0,16(sp)
    80003436:	64a2                	ld	s1,8(sp)
    80003438:	6105                	addi	sp,sp,32
    8000343a:	8082                	ret

000000008000343c <sys_settickets>:


// system setticket
int sys_settickets(void)
{
    8000343c:	7179                	addi	sp,sp,-48
    8000343e:	f406                	sd	ra,40(sp)
    80003440:	f022                	sd	s0,32(sp)
    80003442:	ec26                	sd	s1,24(sp)
    80003444:	1800                	addi	s0,sp,48
  int number;
  argint(0, &number);
    80003446:	fdc40593          	addi	a1,s0,-36
    8000344a:	4501                	li	a0,0
    8000344c:	00000097          	auipc	ra,0x0
    80003450:	c28080e7          	jalr	-984(ra) # 80003074 <argint>
  acquire(&(myproc())->lock);
    80003454:	ffffe097          	auipc	ra,0xffffe
    80003458:	708080e7          	jalr	1800(ra) # 80001b5c <myproc>
    8000345c:	ffffe097          	auipc	ra,0xffffe
    80003460:	8ee080e7          	jalr	-1810(ra) # 80000d4a <acquire>
  myproc()->tickets = number;
    80003464:	fdc42483          	lw	s1,-36(s0)
    80003468:	ffffe097          	auipc	ra,0xffffe
    8000346c:	6f4080e7          	jalr	1780(ra) # 80001b5c <myproc>
    80003470:	16952c23          	sw	s1,376(a0)
  release(&(myproc())->lock);
    80003474:	ffffe097          	auipc	ra,0xffffe
    80003478:	6e8080e7          	jalr	1768(ra) # 80001b5c <myproc>
    8000347c:	ffffe097          	auipc	ra,0xffffe
    80003480:	982080e7          	jalr	-1662(ra) # 80000dfe <release>
  return 0;
}
    80003484:	4501                	li	a0,0
    80003486:	70a2                	ld	ra,40(sp)
    80003488:	7402                	ld	s0,32(sp)
    8000348a:	64e2                	ld	s1,24(sp)
    8000348c:	6145                	addi	sp,sp,48
    8000348e:	8082                	ret

0000000080003490 <sys_sigalarm>:

// sigalarm
uint64 sys_sigalarm(void)
{
    80003490:	1101                	addi	sp,sp,-32
    80003492:	ec06                	sd	ra,24(sp)
    80003494:	e822                	sd	s0,16(sp)
    80003496:	1000                	addi	s0,sp,32
  int interval;
  uint64 fn;
  argint(0, &interval);
    80003498:	fec40593          	addi	a1,s0,-20
    8000349c:	4501                	li	a0,0
    8000349e:	00000097          	auipc	ra,0x0
    800034a2:	bd6080e7          	jalr	-1066(ra) # 80003074 <argint>
  argaddr(1, &fn);
    800034a6:	fe040593          	addi	a1,s0,-32
    800034aa:	4505                	li	a0,1
    800034ac:	00000097          	auipc	ra,0x0
    800034b0:	be8080e7          	jalr	-1048(ra) # 80003094 <argaddr>

  struct proc *p = myproc();
    800034b4:	ffffe097          	auipc	ra,0xffffe
    800034b8:	6a8080e7          	jalr	1704(ra) # 80001b5c <myproc>

  p->sigalarm_status = 0;
    800034bc:	1c052023          	sw	zero,448(a0)
  p->interval = interval;
    800034c0:	fec42783          	lw	a5,-20(s0)
    800034c4:	1af52823          	sw	a5,432(a0)
  p->now_ticks = 0;
    800034c8:	1a052a23          	sw	zero,436(a0)
  p->handler = fn;
    800034cc:	fe043783          	ld	a5,-32(s0)
    800034d0:	1af53423          	sd	a5,424(a0)

  return 0;
}
    800034d4:	4501                	li	a0,0
    800034d6:	60e2                	ld	ra,24(sp)
    800034d8:	6442                	ld	s0,16(sp)
    800034da:	6105                	addi	sp,sp,32
    800034dc:	8082                	ret

00000000800034de <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    800034de:	1101                	addi	sp,sp,-32
    800034e0:	ec06                	sd	ra,24(sp)
    800034e2:	e822                	sd	s0,16(sp)
    800034e4:	e426                	sd	s1,8(sp)
    800034e6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800034e8:	ffffe097          	auipc	ra,0xffffe
    800034ec:	674080e7          	jalr	1652(ra) # 80001b5c <myproc>
    800034f0:	84aa                	mv	s1,a0

  // Restore Kernel Values
  memmove(p->trapframe, p->alarm_trapframe, PGSIZE);
    800034f2:	6605                	lui	a2,0x1
    800034f4:	1b853583          	ld	a1,440(a0)
    800034f8:	6d28                	ld	a0,88(a0)
    800034fa:	ffffe097          	auipc	ra,0xffffe
    800034fe:	9a8080e7          	jalr	-1624(ra) # 80000ea2 <memmove>
  kfree(p->alarm_trapframe);
    80003502:	1b84b503          	ld	a0,440(s1)
    80003506:	ffffd097          	auipc	ra,0xffffd
    8000350a:	572080e7          	jalr	1394(ra) # 80000a78 <kfree>

  p->sigalarm_status = 0;
    8000350e:	1c04a023          	sw	zero,448(s1)
  p->alarm_trapframe = 0;
    80003512:	1a04bc23          	sd	zero,440(s1)
  p->now_ticks = 0;
    80003516:	1a04aa23          	sw	zero,436(s1)
  usertrapret();
    8000351a:	fffff097          	auipc	ra,0xfffff
    8000351e:	58e080e7          	jalr	1422(ra) # 80002aa8 <usertrapret>
  return 0;
}
    80003522:	4501                	li	a0,0
    80003524:	60e2                	ld	ra,24(sp)
    80003526:	6442                	ld	s0,16(sp)
    80003528:	64a2                	ld	s1,8(sp)
    8000352a:	6105                	addi	sp,sp,32
    8000352c:	8082                	ret

000000008000352e <binit>:
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void binit(void)
{
    8000352e:	7179                	addi	sp,sp,-48
    80003530:	f406                	sd	ra,40(sp)
    80003532:	f022                	sd	s0,32(sp)
    80003534:	ec26                	sd	s1,24(sp)
    80003536:	e84a                	sd	s2,16(sp)
    80003538:	e44e                	sd	s3,8(sp)
    8000353a:	e052                	sd	s4,0(sp)
    8000353c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000353e:	00005597          	auipc	a1,0x5
    80003542:	15a58593          	addi	a1,a1,346 # 80008698 <syscalls+0xd8>
    80003546:	00236517          	auipc	a0,0x236
    8000354a:	91250513          	addi	a0,a0,-1774 # 80238e58 <bcache>
    8000354e:	ffffd097          	auipc	ra,0xffffd
    80003552:	76c080e7          	jalr	1900(ra) # 80000cba <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003556:	0023e797          	auipc	a5,0x23e
    8000355a:	90278793          	addi	a5,a5,-1790 # 80240e58 <bcache+0x8000>
    8000355e:	0023e717          	auipc	a4,0x23e
    80003562:	b6270713          	addi	a4,a4,-1182 # 802410c0 <bcache+0x8268>
    80003566:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000356a:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    8000356e:	00236497          	auipc	s1,0x236
    80003572:	90248493          	addi	s1,s1,-1790 # 80238e70 <bcache+0x18>
  {
    b->next = bcache.head.next;
    80003576:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003578:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000357a:	00005a17          	auipc	s4,0x5
    8000357e:	126a0a13          	addi	s4,s4,294 # 800086a0 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003582:	2b893783          	ld	a5,696(s2)
    80003586:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003588:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000358c:	85d2                	mv	a1,s4
    8000358e:	01048513          	addi	a0,s1,16
    80003592:	00001097          	auipc	ra,0x1
    80003596:	4c8080e7          	jalr	1224(ra) # 80004a5a <initsleeplock>
    bcache.head.next->prev = b;
    8000359a:	2b893783          	ld	a5,696(s2)
    8000359e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800035a0:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    800035a4:	45848493          	addi	s1,s1,1112
    800035a8:	fd349de3          	bne	s1,s3,80003582 <binit+0x54>
  }
}
    800035ac:	70a2                	ld	ra,40(sp)
    800035ae:	7402                	ld	s0,32(sp)
    800035b0:	64e2                	ld	s1,24(sp)
    800035b2:	6942                	ld	s2,16(sp)
    800035b4:	69a2                	ld	s3,8(sp)
    800035b6:	6a02                	ld	s4,0(sp)
    800035b8:	6145                	addi	sp,sp,48
    800035ba:	8082                	ret

00000000800035bc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    800035bc:	7179                	addi	sp,sp,-48
    800035be:	f406                	sd	ra,40(sp)
    800035c0:	f022                	sd	s0,32(sp)
    800035c2:	ec26                	sd	s1,24(sp)
    800035c4:	e84a                	sd	s2,16(sp)
    800035c6:	e44e                	sd	s3,8(sp)
    800035c8:	1800                	addi	s0,sp,48
    800035ca:	892a                	mv	s2,a0
    800035cc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800035ce:	00236517          	auipc	a0,0x236
    800035d2:	88a50513          	addi	a0,a0,-1910 # 80238e58 <bcache>
    800035d6:	ffffd097          	auipc	ra,0xffffd
    800035da:	774080e7          	jalr	1908(ra) # 80000d4a <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next)
    800035de:	0023e497          	auipc	s1,0x23e
    800035e2:	b324b483          	ld	s1,-1230(s1) # 80241110 <bcache+0x82b8>
    800035e6:	0023e797          	auipc	a5,0x23e
    800035ea:	ada78793          	addi	a5,a5,-1318 # 802410c0 <bcache+0x8268>
    800035ee:	02f48f63          	beq	s1,a5,8000362c <bread+0x70>
    800035f2:	873e                	mv	a4,a5
    800035f4:	a021                	j	800035fc <bread+0x40>
    800035f6:	68a4                	ld	s1,80(s1)
    800035f8:	02e48a63          	beq	s1,a4,8000362c <bread+0x70>
    if (b->dev == dev && b->blockno == blockno)
    800035fc:	449c                	lw	a5,8(s1)
    800035fe:	ff279ce3          	bne	a5,s2,800035f6 <bread+0x3a>
    80003602:	44dc                	lw	a5,12(s1)
    80003604:	ff3799e3          	bne	a5,s3,800035f6 <bread+0x3a>
      b->refcnt++;
    80003608:	40bc                	lw	a5,64(s1)
    8000360a:	2785                	addiw	a5,a5,1
    8000360c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000360e:	00236517          	auipc	a0,0x236
    80003612:	84a50513          	addi	a0,a0,-1974 # 80238e58 <bcache>
    80003616:	ffffd097          	auipc	ra,0xffffd
    8000361a:	7e8080e7          	jalr	2024(ra) # 80000dfe <release>
      acquiresleep(&b->lock);
    8000361e:	01048513          	addi	a0,s1,16
    80003622:	00001097          	auipc	ra,0x1
    80003626:	472080e7          	jalr	1138(ra) # 80004a94 <acquiresleep>
      return b;
    8000362a:	a8b9                	j	80003688 <bread+0xcc>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    8000362c:	0023e497          	auipc	s1,0x23e
    80003630:	adc4b483          	ld	s1,-1316(s1) # 80241108 <bcache+0x82b0>
    80003634:	0023e797          	auipc	a5,0x23e
    80003638:	a8c78793          	addi	a5,a5,-1396 # 802410c0 <bcache+0x8268>
    8000363c:	00f48863          	beq	s1,a5,8000364c <bread+0x90>
    80003640:	873e                	mv	a4,a5
    if (b->refcnt == 0)
    80003642:	40bc                	lw	a5,64(s1)
    80003644:	cf81                	beqz	a5,8000365c <bread+0xa0>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    80003646:	64a4                	ld	s1,72(s1)
    80003648:	fee49de3          	bne	s1,a4,80003642 <bread+0x86>
  panic("bget: no buffers");
    8000364c:	00005517          	auipc	a0,0x5
    80003650:	05c50513          	addi	a0,a0,92 # 800086a8 <syscalls+0xe8>
    80003654:	ffffd097          	auipc	ra,0xffffd
    80003658:	eec080e7          	jalr	-276(ra) # 80000540 <panic>
      b->dev = dev;
    8000365c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003660:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003664:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003668:	4785                	li	a5,1
    8000366a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000366c:	00235517          	auipc	a0,0x235
    80003670:	7ec50513          	addi	a0,a0,2028 # 80238e58 <bcache>
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	78a080e7          	jalr	1930(ra) # 80000dfe <release>
      acquiresleep(&b->lock);
    8000367c:	01048513          	addi	a0,s1,16
    80003680:	00001097          	auipc	ra,0x1
    80003684:	414080e7          	jalr	1044(ra) # 80004a94 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid)
    80003688:	409c                	lw	a5,0(s1)
    8000368a:	cb89                	beqz	a5,8000369c <bread+0xe0>
  {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000368c:	8526                	mv	a0,s1
    8000368e:	70a2                	ld	ra,40(sp)
    80003690:	7402                	ld	s0,32(sp)
    80003692:	64e2                	ld	s1,24(sp)
    80003694:	6942                	ld	s2,16(sp)
    80003696:	69a2                	ld	s3,8(sp)
    80003698:	6145                	addi	sp,sp,48
    8000369a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000369c:	4581                	li	a1,0
    8000369e:	8526                	mv	a0,s1
    800036a0:	00003097          	auipc	ra,0x3
    800036a4:	2b6080e7          	jalr	694(ra) # 80006956 <virtio_disk_rw>
    b->valid = 1;
    800036a8:	4785                	li	a5,1
    800036aa:	c09c                	sw	a5,0(s1)
  return b;
    800036ac:	b7c5                	j	8000368c <bread+0xd0>

00000000800036ae <bwrite>:

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
    800036ae:	1101                	addi	sp,sp,-32
    800036b0:	ec06                	sd	ra,24(sp)
    800036b2:	e822                	sd	s0,16(sp)
    800036b4:	e426                	sd	s1,8(sp)
    800036b6:	1000                	addi	s0,sp,32
    800036b8:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800036ba:	0541                	addi	a0,a0,16
    800036bc:	00001097          	auipc	ra,0x1
    800036c0:	472080e7          	jalr	1138(ra) # 80004b2e <holdingsleep>
    800036c4:	cd01                	beqz	a0,800036dc <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800036c6:	4585                	li	a1,1
    800036c8:	8526                	mv	a0,s1
    800036ca:	00003097          	auipc	ra,0x3
    800036ce:	28c080e7          	jalr	652(ra) # 80006956 <virtio_disk_rw>
}
    800036d2:	60e2                	ld	ra,24(sp)
    800036d4:	6442                	ld	s0,16(sp)
    800036d6:	64a2                	ld	s1,8(sp)
    800036d8:	6105                	addi	sp,sp,32
    800036da:	8082                	ret
    panic("bwrite");
    800036dc:	00005517          	auipc	a0,0x5
    800036e0:	fe450513          	addi	a0,a0,-28 # 800086c0 <syscalls+0x100>
    800036e4:	ffffd097          	auipc	ra,0xffffd
    800036e8:	e5c080e7          	jalr	-420(ra) # 80000540 <panic>

00000000800036ec <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)
{
    800036ec:	1101                	addi	sp,sp,-32
    800036ee:	ec06                	sd	ra,24(sp)
    800036f0:	e822                	sd	s0,16(sp)
    800036f2:	e426                	sd	s1,8(sp)
    800036f4:	e04a                	sd	s2,0(sp)
    800036f6:	1000                	addi	s0,sp,32
    800036f8:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800036fa:	01050913          	addi	s2,a0,16
    800036fe:	854a                	mv	a0,s2
    80003700:	00001097          	auipc	ra,0x1
    80003704:	42e080e7          	jalr	1070(ra) # 80004b2e <holdingsleep>
    80003708:	c92d                	beqz	a0,8000377a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000370a:	854a                	mv	a0,s2
    8000370c:	00001097          	auipc	ra,0x1
    80003710:	3de080e7          	jalr	990(ra) # 80004aea <releasesleep>

  acquire(&bcache.lock);
    80003714:	00235517          	auipc	a0,0x235
    80003718:	74450513          	addi	a0,a0,1860 # 80238e58 <bcache>
    8000371c:	ffffd097          	auipc	ra,0xffffd
    80003720:	62e080e7          	jalr	1582(ra) # 80000d4a <acquire>
  b->refcnt--;
    80003724:	40bc                	lw	a5,64(s1)
    80003726:	37fd                	addiw	a5,a5,-1
    80003728:	0007871b          	sext.w	a4,a5
    8000372c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0)
    8000372e:	eb05                	bnez	a4,8000375e <brelse+0x72>
  {
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003730:	68bc                	ld	a5,80(s1)
    80003732:	64b8                	ld	a4,72(s1)
    80003734:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003736:	64bc                	ld	a5,72(s1)
    80003738:	68b8                	ld	a4,80(s1)
    8000373a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000373c:	0023d797          	auipc	a5,0x23d
    80003740:	71c78793          	addi	a5,a5,1820 # 80240e58 <bcache+0x8000>
    80003744:	2b87b703          	ld	a4,696(a5)
    80003748:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000374a:	0023e717          	auipc	a4,0x23e
    8000374e:	97670713          	addi	a4,a4,-1674 # 802410c0 <bcache+0x8268>
    80003752:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003754:	2b87b703          	ld	a4,696(a5)
    80003758:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000375a:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    8000375e:	00235517          	auipc	a0,0x235
    80003762:	6fa50513          	addi	a0,a0,1786 # 80238e58 <bcache>
    80003766:	ffffd097          	auipc	ra,0xffffd
    8000376a:	698080e7          	jalr	1688(ra) # 80000dfe <release>
}
    8000376e:	60e2                	ld	ra,24(sp)
    80003770:	6442                	ld	s0,16(sp)
    80003772:	64a2                	ld	s1,8(sp)
    80003774:	6902                	ld	s2,0(sp)
    80003776:	6105                	addi	sp,sp,32
    80003778:	8082                	ret
    panic("brelse");
    8000377a:	00005517          	auipc	a0,0x5
    8000377e:	f4e50513          	addi	a0,a0,-178 # 800086c8 <syscalls+0x108>
    80003782:	ffffd097          	auipc	ra,0xffffd
    80003786:	dbe080e7          	jalr	-578(ra) # 80000540 <panic>

000000008000378a <bpin>:

void bpin(struct buf *b)
{
    8000378a:	1101                	addi	sp,sp,-32
    8000378c:	ec06                	sd	ra,24(sp)
    8000378e:	e822                	sd	s0,16(sp)
    80003790:	e426                	sd	s1,8(sp)
    80003792:	1000                	addi	s0,sp,32
    80003794:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003796:	00235517          	auipc	a0,0x235
    8000379a:	6c250513          	addi	a0,a0,1730 # 80238e58 <bcache>
    8000379e:	ffffd097          	auipc	ra,0xffffd
    800037a2:	5ac080e7          	jalr	1452(ra) # 80000d4a <acquire>
  b->refcnt++;
    800037a6:	40bc                	lw	a5,64(s1)
    800037a8:	2785                	addiw	a5,a5,1
    800037aa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037ac:	00235517          	auipc	a0,0x235
    800037b0:	6ac50513          	addi	a0,a0,1708 # 80238e58 <bcache>
    800037b4:	ffffd097          	auipc	ra,0xffffd
    800037b8:	64a080e7          	jalr	1610(ra) # 80000dfe <release>
}
    800037bc:	60e2                	ld	ra,24(sp)
    800037be:	6442                	ld	s0,16(sp)
    800037c0:	64a2                	ld	s1,8(sp)
    800037c2:	6105                	addi	sp,sp,32
    800037c4:	8082                	ret

00000000800037c6 <bunpin>:

void bunpin(struct buf *b)
{
    800037c6:	1101                	addi	sp,sp,-32
    800037c8:	ec06                	sd	ra,24(sp)
    800037ca:	e822                	sd	s0,16(sp)
    800037cc:	e426                	sd	s1,8(sp)
    800037ce:	1000                	addi	s0,sp,32
    800037d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037d2:	00235517          	auipc	a0,0x235
    800037d6:	68650513          	addi	a0,a0,1670 # 80238e58 <bcache>
    800037da:	ffffd097          	auipc	ra,0xffffd
    800037de:	570080e7          	jalr	1392(ra) # 80000d4a <acquire>
  b->refcnt--;
    800037e2:	40bc                	lw	a5,64(s1)
    800037e4:	37fd                	addiw	a5,a5,-1
    800037e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037e8:	00235517          	auipc	a0,0x235
    800037ec:	67050513          	addi	a0,a0,1648 # 80238e58 <bcache>
    800037f0:	ffffd097          	auipc	ra,0xffffd
    800037f4:	60e080e7          	jalr	1550(ra) # 80000dfe <release>
}
    800037f8:	60e2                	ld	ra,24(sp)
    800037fa:	6442                	ld	s0,16(sp)
    800037fc:	64a2                	ld	s1,8(sp)
    800037fe:	6105                	addi	sp,sp,32
    80003800:	8082                	ret

0000000080003802 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003802:	1101                	addi	sp,sp,-32
    80003804:	ec06                	sd	ra,24(sp)
    80003806:	e822                	sd	s0,16(sp)
    80003808:	e426                	sd	s1,8(sp)
    8000380a:	e04a                	sd	s2,0(sp)
    8000380c:	1000                	addi	s0,sp,32
    8000380e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003810:	00d5d59b          	srliw	a1,a1,0xd
    80003814:	0023e797          	auipc	a5,0x23e
    80003818:	d207a783          	lw	a5,-736(a5) # 80241534 <sb+0x1c>
    8000381c:	9dbd                	addw	a1,a1,a5
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	d9e080e7          	jalr	-610(ra) # 800035bc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003826:	0074f713          	andi	a4,s1,7
    8000382a:	4785                	li	a5,1
    8000382c:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80003830:	14ce                	slli	s1,s1,0x33
    80003832:	90d9                	srli	s1,s1,0x36
    80003834:	00950733          	add	a4,a0,s1
    80003838:	05874703          	lbu	a4,88(a4)
    8000383c:	00e7f6b3          	and	a3,a5,a4
    80003840:	c69d                	beqz	a3,8000386e <bfree+0x6c>
    80003842:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80003844:	94aa                	add	s1,s1,a0
    80003846:	fff7c793          	not	a5,a5
    8000384a:	8f7d                	and	a4,a4,a5
    8000384c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003850:	00001097          	auipc	ra,0x1
    80003854:	126080e7          	jalr	294(ra) # 80004976 <log_write>
  brelse(bp);
    80003858:	854a                	mv	a0,s2
    8000385a:	00000097          	auipc	ra,0x0
    8000385e:	e92080e7          	jalr	-366(ra) # 800036ec <brelse>
}
    80003862:	60e2                	ld	ra,24(sp)
    80003864:	6442                	ld	s0,16(sp)
    80003866:	64a2                	ld	s1,8(sp)
    80003868:	6902                	ld	s2,0(sp)
    8000386a:	6105                	addi	sp,sp,32
    8000386c:	8082                	ret
    panic("freeing free block");
    8000386e:	00005517          	auipc	a0,0x5
    80003872:	e6250513          	addi	a0,a0,-414 # 800086d0 <syscalls+0x110>
    80003876:	ffffd097          	auipc	ra,0xffffd
    8000387a:	cca080e7          	jalr	-822(ra) # 80000540 <panic>

000000008000387e <balloc>:
{
    8000387e:	711d                	addi	sp,sp,-96
    80003880:	ec86                	sd	ra,88(sp)
    80003882:	e8a2                	sd	s0,80(sp)
    80003884:	e4a6                	sd	s1,72(sp)
    80003886:	e0ca                	sd	s2,64(sp)
    80003888:	fc4e                	sd	s3,56(sp)
    8000388a:	f852                	sd	s4,48(sp)
    8000388c:	f456                	sd	s5,40(sp)
    8000388e:	f05a                	sd	s6,32(sp)
    80003890:	ec5e                	sd	s7,24(sp)
    80003892:	e862                	sd	s8,16(sp)
    80003894:	e466                	sd	s9,8(sp)
    80003896:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB)
    80003898:	0023e797          	auipc	a5,0x23e
    8000389c:	c847a783          	lw	a5,-892(a5) # 8024151c <sb+0x4>
    800038a0:	cff5                	beqz	a5,8000399c <balloc+0x11e>
    800038a2:	8baa                	mv	s7,a0
    800038a4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800038a6:	0023eb17          	auipc	s6,0x23e
    800038aa:	c72b0b13          	addi	s6,s6,-910 # 80241518 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800038ae:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800038b0:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800038b2:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB)
    800038b4:	6c89                	lui	s9,0x2
    800038b6:	a061                	j	8000393e <balloc+0xc0>
        bp->data[bi / 8] |= m; // Mark block in use.
    800038b8:	97ca                	add	a5,a5,s2
    800038ba:	8e55                	or	a2,a2,a3
    800038bc:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800038c0:	854a                	mv	a0,s2
    800038c2:	00001097          	auipc	ra,0x1
    800038c6:	0b4080e7          	jalr	180(ra) # 80004976 <log_write>
        brelse(bp);
    800038ca:	854a                	mv	a0,s2
    800038cc:	00000097          	auipc	ra,0x0
    800038d0:	e20080e7          	jalr	-480(ra) # 800036ec <brelse>
  bp = bread(dev, bno);
    800038d4:	85a6                	mv	a1,s1
    800038d6:	855e                	mv	a0,s7
    800038d8:	00000097          	auipc	ra,0x0
    800038dc:	ce4080e7          	jalr	-796(ra) # 800035bc <bread>
    800038e0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038e2:	40000613          	li	a2,1024
    800038e6:	4581                	li	a1,0
    800038e8:	05850513          	addi	a0,a0,88
    800038ec:	ffffd097          	auipc	ra,0xffffd
    800038f0:	55a080e7          	jalr	1370(ra) # 80000e46 <memset>
  log_write(bp);
    800038f4:	854a                	mv	a0,s2
    800038f6:	00001097          	auipc	ra,0x1
    800038fa:	080080e7          	jalr	128(ra) # 80004976 <log_write>
  brelse(bp);
    800038fe:	854a                	mv	a0,s2
    80003900:	00000097          	auipc	ra,0x0
    80003904:	dec080e7          	jalr	-532(ra) # 800036ec <brelse>
}
    80003908:	8526                	mv	a0,s1
    8000390a:	60e6                	ld	ra,88(sp)
    8000390c:	6446                	ld	s0,80(sp)
    8000390e:	64a6                	ld	s1,72(sp)
    80003910:	6906                	ld	s2,64(sp)
    80003912:	79e2                	ld	s3,56(sp)
    80003914:	7a42                	ld	s4,48(sp)
    80003916:	7aa2                	ld	s5,40(sp)
    80003918:	7b02                	ld	s6,32(sp)
    8000391a:	6be2                	ld	s7,24(sp)
    8000391c:	6c42                	ld	s8,16(sp)
    8000391e:	6ca2                	ld	s9,8(sp)
    80003920:	6125                	addi	sp,sp,96
    80003922:	8082                	ret
    brelse(bp);
    80003924:	854a                	mv	a0,s2
    80003926:	00000097          	auipc	ra,0x0
    8000392a:	dc6080e7          	jalr	-570(ra) # 800036ec <brelse>
  for (b = 0; b < sb.size; b += BPB)
    8000392e:	015c87bb          	addw	a5,s9,s5
    80003932:	00078a9b          	sext.w	s5,a5
    80003936:	004b2703          	lw	a4,4(s6)
    8000393a:	06eaf163          	bgeu	s5,a4,8000399c <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000393e:	41fad79b          	sraiw	a5,s5,0x1f
    80003942:	0137d79b          	srliw	a5,a5,0x13
    80003946:	015787bb          	addw	a5,a5,s5
    8000394a:	40d7d79b          	sraiw	a5,a5,0xd
    8000394e:	01cb2583          	lw	a1,28(s6)
    80003952:	9dbd                	addw	a1,a1,a5
    80003954:	855e                	mv	a0,s7
    80003956:	00000097          	auipc	ra,0x0
    8000395a:	c66080e7          	jalr	-922(ra) # 800035bc <bread>
    8000395e:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003960:	004b2503          	lw	a0,4(s6)
    80003964:	000a849b          	sext.w	s1,s5
    80003968:	8762                	mv	a4,s8
    8000396a:	faa4fde3          	bgeu	s1,a0,80003924 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000396e:	00777693          	andi	a3,a4,7
    80003972:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0)
    80003976:	41f7579b          	sraiw	a5,a4,0x1f
    8000397a:	01d7d79b          	srliw	a5,a5,0x1d
    8000397e:	9fb9                	addw	a5,a5,a4
    80003980:	4037d79b          	sraiw	a5,a5,0x3
    80003984:	00f90633          	add	a2,s2,a5
    80003988:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000398c:	00c6f5b3          	and	a1,a3,a2
    80003990:	d585                	beqz	a1,800038b8 <balloc+0x3a>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003992:	2705                	addiw	a4,a4,1
    80003994:	2485                	addiw	s1,s1,1
    80003996:	fd471ae3          	bne	a4,s4,8000396a <balloc+0xec>
    8000399a:	b769                	j	80003924 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000399c:	00005517          	auipc	a0,0x5
    800039a0:	d4c50513          	addi	a0,a0,-692 # 800086e8 <syscalls+0x128>
    800039a4:	ffffd097          	auipc	ra,0xffffd
    800039a8:	be6080e7          	jalr	-1050(ra) # 8000058a <printf>
  return 0;
    800039ac:	4481                	li	s1,0
    800039ae:	bfa9                	j	80003908 <balloc+0x8a>

00000000800039b0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800039b0:	7179                	addi	sp,sp,-48
    800039b2:	f406                	sd	ra,40(sp)
    800039b4:	f022                	sd	s0,32(sp)
    800039b6:	ec26                	sd	s1,24(sp)
    800039b8:	e84a                	sd	s2,16(sp)
    800039ba:	e44e                	sd	s3,8(sp)
    800039bc:	e052                	sd	s4,0(sp)
    800039be:	1800                	addi	s0,sp,48
    800039c0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT)
    800039c2:	47ad                	li	a5,11
    800039c4:	02b7e863          	bltu	a5,a1,800039f4 <bmap+0x44>
  {
    if ((addr = ip->addrs[bn]) == 0)
    800039c8:	02059793          	slli	a5,a1,0x20
    800039cc:	01e7d593          	srli	a1,a5,0x1e
    800039d0:	00b504b3          	add	s1,a0,a1
    800039d4:	0504a903          	lw	s2,80(s1)
    800039d8:	06091e63          	bnez	s2,80003a54 <bmap+0xa4>
    {
      addr = balloc(ip->dev);
    800039dc:	4108                	lw	a0,0(a0)
    800039de:	00000097          	auipc	ra,0x0
    800039e2:	ea0080e7          	jalr	-352(ra) # 8000387e <balloc>
    800039e6:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    800039ea:	06090563          	beqz	s2,80003a54 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800039ee:	0524a823          	sw	s2,80(s1)
    800039f2:	a08d                	j	80003a54 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800039f4:	ff45849b          	addiw	s1,a1,-12
    800039f8:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT)
    800039fc:	0ff00793          	li	a5,255
    80003a00:	08e7e563          	bltu	a5,a4,80003a8a <bmap+0xda>
  {
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0)
    80003a04:	08052903          	lw	s2,128(a0)
    80003a08:	00091d63          	bnez	s2,80003a22 <bmap+0x72>
    {
      addr = balloc(ip->dev);
    80003a0c:	4108                	lw	a0,0(a0)
    80003a0e:	00000097          	auipc	ra,0x0
    80003a12:	e70080e7          	jalr	-400(ra) # 8000387e <balloc>
    80003a16:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003a1a:	02090d63          	beqz	s2,80003a54 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003a1e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003a22:	85ca                	mv	a1,s2
    80003a24:	0009a503          	lw	a0,0(s3)
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	b94080e7          	jalr	-1132(ra) # 800035bc <bread>
    80003a30:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003a32:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0)
    80003a36:	02049713          	slli	a4,s1,0x20
    80003a3a:	01e75593          	srli	a1,a4,0x1e
    80003a3e:	00b784b3          	add	s1,a5,a1
    80003a42:	0004a903          	lw	s2,0(s1)
    80003a46:	02090063          	beqz	s2,80003a66 <bmap+0xb6>
      {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003a4a:	8552                	mv	a0,s4
    80003a4c:	00000097          	auipc	ra,0x0
    80003a50:	ca0080e7          	jalr	-864(ra) # 800036ec <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003a54:	854a                	mv	a0,s2
    80003a56:	70a2                	ld	ra,40(sp)
    80003a58:	7402                	ld	s0,32(sp)
    80003a5a:	64e2                	ld	s1,24(sp)
    80003a5c:	6942                	ld	s2,16(sp)
    80003a5e:	69a2                	ld	s3,8(sp)
    80003a60:	6a02                	ld	s4,0(sp)
    80003a62:	6145                	addi	sp,sp,48
    80003a64:	8082                	ret
      addr = balloc(ip->dev);
    80003a66:	0009a503          	lw	a0,0(s3)
    80003a6a:	00000097          	auipc	ra,0x0
    80003a6e:	e14080e7          	jalr	-492(ra) # 8000387e <balloc>
    80003a72:	0005091b          	sext.w	s2,a0
      if (addr)
    80003a76:	fc090ae3          	beqz	s2,80003a4a <bmap+0x9a>
        a[bn] = addr;
    80003a7a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003a7e:	8552                	mv	a0,s4
    80003a80:	00001097          	auipc	ra,0x1
    80003a84:	ef6080e7          	jalr	-266(ra) # 80004976 <log_write>
    80003a88:	b7c9                	j	80003a4a <bmap+0x9a>
  panic("bmap: out of range");
    80003a8a:	00005517          	auipc	a0,0x5
    80003a8e:	c7650513          	addi	a0,a0,-906 # 80008700 <syscalls+0x140>
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	aae080e7          	jalr	-1362(ra) # 80000540 <panic>

0000000080003a9a <iget>:
{
    80003a9a:	7179                	addi	sp,sp,-48
    80003a9c:	f406                	sd	ra,40(sp)
    80003a9e:	f022                	sd	s0,32(sp)
    80003aa0:	ec26                	sd	s1,24(sp)
    80003aa2:	e84a                	sd	s2,16(sp)
    80003aa4:	e44e                	sd	s3,8(sp)
    80003aa6:	e052                	sd	s4,0(sp)
    80003aa8:	1800                	addi	s0,sp,48
    80003aaa:	89aa                	mv	s3,a0
    80003aac:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003aae:	0023e517          	auipc	a0,0x23e
    80003ab2:	a8a50513          	addi	a0,a0,-1398 # 80241538 <itable>
    80003ab6:	ffffd097          	auipc	ra,0xffffd
    80003aba:	294080e7          	jalr	660(ra) # 80000d4a <acquire>
  empty = 0;
    80003abe:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    80003ac0:	0023e497          	auipc	s1,0x23e
    80003ac4:	a9048493          	addi	s1,s1,-1392 # 80241550 <itable+0x18>
    80003ac8:	0023f697          	auipc	a3,0x23f
    80003acc:	51868693          	addi	a3,a3,1304 # 80242fe0 <log>
    80003ad0:	a039                	j	80003ade <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003ad2:	02090b63          	beqz	s2,80003b08 <iget+0x6e>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    80003ad6:	08848493          	addi	s1,s1,136
    80003ada:	02d48a63          	beq	s1,a3,80003b0e <iget+0x74>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum)
    80003ade:	449c                	lw	a5,8(s1)
    80003ae0:	fef059e3          	blez	a5,80003ad2 <iget+0x38>
    80003ae4:	4098                	lw	a4,0(s1)
    80003ae6:	ff3716e3          	bne	a4,s3,80003ad2 <iget+0x38>
    80003aea:	40d8                	lw	a4,4(s1)
    80003aec:	ff4713e3          	bne	a4,s4,80003ad2 <iget+0x38>
      ip->ref++;
    80003af0:	2785                	addiw	a5,a5,1
    80003af2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003af4:	0023e517          	auipc	a0,0x23e
    80003af8:	a4450513          	addi	a0,a0,-1468 # 80241538 <itable>
    80003afc:	ffffd097          	auipc	ra,0xffffd
    80003b00:	302080e7          	jalr	770(ra) # 80000dfe <release>
      return ip;
    80003b04:	8926                	mv	s2,s1
    80003b06:	a03d                	j	80003b34 <iget+0x9a>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003b08:	f7f9                	bnez	a5,80003ad6 <iget+0x3c>
    80003b0a:	8926                	mv	s2,s1
    80003b0c:	b7e9                	j	80003ad6 <iget+0x3c>
  if (empty == 0)
    80003b0e:	02090c63          	beqz	s2,80003b46 <iget+0xac>
  ip->dev = dev;
    80003b12:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b16:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b1a:	4785                	li	a5,1
    80003b1c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b20:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b24:	0023e517          	auipc	a0,0x23e
    80003b28:	a1450513          	addi	a0,a0,-1516 # 80241538 <itable>
    80003b2c:	ffffd097          	auipc	ra,0xffffd
    80003b30:	2d2080e7          	jalr	722(ra) # 80000dfe <release>
}
    80003b34:	854a                	mv	a0,s2
    80003b36:	70a2                	ld	ra,40(sp)
    80003b38:	7402                	ld	s0,32(sp)
    80003b3a:	64e2                	ld	s1,24(sp)
    80003b3c:	6942                	ld	s2,16(sp)
    80003b3e:	69a2                	ld	s3,8(sp)
    80003b40:	6a02                	ld	s4,0(sp)
    80003b42:	6145                	addi	sp,sp,48
    80003b44:	8082                	ret
    panic("iget: no inodes");
    80003b46:	00005517          	auipc	a0,0x5
    80003b4a:	bd250513          	addi	a0,a0,-1070 # 80008718 <syscalls+0x158>
    80003b4e:	ffffd097          	auipc	ra,0xffffd
    80003b52:	9f2080e7          	jalr	-1550(ra) # 80000540 <panic>

0000000080003b56 <fsinit>:
{
    80003b56:	7179                	addi	sp,sp,-48
    80003b58:	f406                	sd	ra,40(sp)
    80003b5a:	f022                	sd	s0,32(sp)
    80003b5c:	ec26                	sd	s1,24(sp)
    80003b5e:	e84a                	sd	s2,16(sp)
    80003b60:	e44e                	sd	s3,8(sp)
    80003b62:	1800                	addi	s0,sp,48
    80003b64:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b66:	4585                	li	a1,1
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	a54080e7          	jalr	-1452(ra) # 800035bc <bread>
    80003b70:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b72:	0023e997          	auipc	s3,0x23e
    80003b76:	9a698993          	addi	s3,s3,-1626 # 80241518 <sb>
    80003b7a:	02000613          	li	a2,32
    80003b7e:	05850593          	addi	a1,a0,88
    80003b82:	854e                	mv	a0,s3
    80003b84:	ffffd097          	auipc	ra,0xffffd
    80003b88:	31e080e7          	jalr	798(ra) # 80000ea2 <memmove>
  brelse(bp);
    80003b8c:	8526                	mv	a0,s1
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	b5e080e7          	jalr	-1186(ra) # 800036ec <brelse>
  if (sb.magic != FSMAGIC)
    80003b96:	0009a703          	lw	a4,0(s3)
    80003b9a:	102037b7          	lui	a5,0x10203
    80003b9e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ba2:	02f71263          	bne	a4,a5,80003bc6 <fsinit+0x70>
  initlog(dev, &sb);
    80003ba6:	0023e597          	auipc	a1,0x23e
    80003baa:	97258593          	addi	a1,a1,-1678 # 80241518 <sb>
    80003bae:	854a                	mv	a0,s2
    80003bb0:	00001097          	auipc	ra,0x1
    80003bb4:	b4a080e7          	jalr	-1206(ra) # 800046fa <initlog>
}
    80003bb8:	70a2                	ld	ra,40(sp)
    80003bba:	7402                	ld	s0,32(sp)
    80003bbc:	64e2                	ld	s1,24(sp)
    80003bbe:	6942                	ld	s2,16(sp)
    80003bc0:	69a2                	ld	s3,8(sp)
    80003bc2:	6145                	addi	sp,sp,48
    80003bc4:	8082                	ret
    panic("invalid file system");
    80003bc6:	00005517          	auipc	a0,0x5
    80003bca:	b6250513          	addi	a0,a0,-1182 # 80008728 <syscalls+0x168>
    80003bce:	ffffd097          	auipc	ra,0xffffd
    80003bd2:	972080e7          	jalr	-1678(ra) # 80000540 <panic>

0000000080003bd6 <iinit>:
{
    80003bd6:	7179                	addi	sp,sp,-48
    80003bd8:	f406                	sd	ra,40(sp)
    80003bda:	f022                	sd	s0,32(sp)
    80003bdc:	ec26                	sd	s1,24(sp)
    80003bde:	e84a                	sd	s2,16(sp)
    80003be0:	e44e                	sd	s3,8(sp)
    80003be2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003be4:	00005597          	auipc	a1,0x5
    80003be8:	b5c58593          	addi	a1,a1,-1188 # 80008740 <syscalls+0x180>
    80003bec:	0023e517          	auipc	a0,0x23e
    80003bf0:	94c50513          	addi	a0,a0,-1716 # 80241538 <itable>
    80003bf4:	ffffd097          	auipc	ra,0xffffd
    80003bf8:	0c6080e7          	jalr	198(ra) # 80000cba <initlock>
  for (i = 0; i < NINODE; i++)
    80003bfc:	0023e497          	auipc	s1,0x23e
    80003c00:	96448493          	addi	s1,s1,-1692 # 80241560 <itable+0x28>
    80003c04:	0023f997          	auipc	s3,0x23f
    80003c08:	3ec98993          	addi	s3,s3,1004 # 80242ff0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c0c:	00005917          	auipc	s2,0x5
    80003c10:	b3c90913          	addi	s2,s2,-1220 # 80008748 <syscalls+0x188>
    80003c14:	85ca                	mv	a1,s2
    80003c16:	8526                	mv	a0,s1
    80003c18:	00001097          	auipc	ra,0x1
    80003c1c:	e42080e7          	jalr	-446(ra) # 80004a5a <initsleeplock>
  for (i = 0; i < NINODE; i++)
    80003c20:	08848493          	addi	s1,s1,136
    80003c24:	ff3498e3          	bne	s1,s3,80003c14 <iinit+0x3e>
}
    80003c28:	70a2                	ld	ra,40(sp)
    80003c2a:	7402                	ld	s0,32(sp)
    80003c2c:	64e2                	ld	s1,24(sp)
    80003c2e:	6942                	ld	s2,16(sp)
    80003c30:	69a2                	ld	s3,8(sp)
    80003c32:	6145                	addi	sp,sp,48
    80003c34:	8082                	ret

0000000080003c36 <ialloc>:
{
    80003c36:	715d                	addi	sp,sp,-80
    80003c38:	e486                	sd	ra,72(sp)
    80003c3a:	e0a2                	sd	s0,64(sp)
    80003c3c:	fc26                	sd	s1,56(sp)
    80003c3e:	f84a                	sd	s2,48(sp)
    80003c40:	f44e                	sd	s3,40(sp)
    80003c42:	f052                	sd	s4,32(sp)
    80003c44:	ec56                	sd	s5,24(sp)
    80003c46:	e85a                	sd	s6,16(sp)
    80003c48:	e45e                	sd	s7,8(sp)
    80003c4a:	0880                	addi	s0,sp,80
  for (inum = 1; inum < sb.ninodes; inum++)
    80003c4c:	0023e717          	auipc	a4,0x23e
    80003c50:	8d872703          	lw	a4,-1832(a4) # 80241524 <sb+0xc>
    80003c54:	4785                	li	a5,1
    80003c56:	04e7fa63          	bgeu	a5,a4,80003caa <ialloc+0x74>
    80003c5a:	8aaa                	mv	s5,a0
    80003c5c:	8bae                	mv	s7,a1
    80003c5e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c60:	0023ea17          	auipc	s4,0x23e
    80003c64:	8b8a0a13          	addi	s4,s4,-1864 # 80241518 <sb>
    80003c68:	00048b1b          	sext.w	s6,s1
    80003c6c:	0044d593          	srli	a1,s1,0x4
    80003c70:	018a2783          	lw	a5,24(s4)
    80003c74:	9dbd                	addw	a1,a1,a5
    80003c76:	8556                	mv	a0,s5
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	944080e7          	jalr	-1724(ra) # 800035bc <bread>
    80003c80:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003c82:	05850993          	addi	s3,a0,88
    80003c86:	00f4f793          	andi	a5,s1,15
    80003c8a:	079a                	slli	a5,a5,0x6
    80003c8c:	99be                	add	s3,s3,a5
    if (dip->type == 0)
    80003c8e:	00099783          	lh	a5,0(s3)
    80003c92:	c3a1                	beqz	a5,80003cd2 <ialloc+0x9c>
    brelse(bp);
    80003c94:	00000097          	auipc	ra,0x0
    80003c98:	a58080e7          	jalr	-1448(ra) # 800036ec <brelse>
  for (inum = 1; inum < sb.ninodes; inum++)
    80003c9c:	0485                	addi	s1,s1,1
    80003c9e:	00ca2703          	lw	a4,12(s4)
    80003ca2:	0004879b          	sext.w	a5,s1
    80003ca6:	fce7e1e3          	bltu	a5,a4,80003c68 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003caa:	00005517          	auipc	a0,0x5
    80003cae:	aa650513          	addi	a0,a0,-1370 # 80008750 <syscalls+0x190>
    80003cb2:	ffffd097          	auipc	ra,0xffffd
    80003cb6:	8d8080e7          	jalr	-1832(ra) # 8000058a <printf>
  return 0;
    80003cba:	4501                	li	a0,0
}
    80003cbc:	60a6                	ld	ra,72(sp)
    80003cbe:	6406                	ld	s0,64(sp)
    80003cc0:	74e2                	ld	s1,56(sp)
    80003cc2:	7942                	ld	s2,48(sp)
    80003cc4:	79a2                	ld	s3,40(sp)
    80003cc6:	7a02                	ld	s4,32(sp)
    80003cc8:	6ae2                	ld	s5,24(sp)
    80003cca:	6b42                	ld	s6,16(sp)
    80003ccc:	6ba2                	ld	s7,8(sp)
    80003cce:	6161                	addi	sp,sp,80
    80003cd0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003cd2:	04000613          	li	a2,64
    80003cd6:	4581                	li	a1,0
    80003cd8:	854e                	mv	a0,s3
    80003cda:	ffffd097          	auipc	ra,0xffffd
    80003cde:	16c080e7          	jalr	364(ra) # 80000e46 <memset>
      dip->type = type;
    80003ce2:	01799023          	sh	s7,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003ce6:	854a                	mv	a0,s2
    80003ce8:	00001097          	auipc	ra,0x1
    80003cec:	c8e080e7          	jalr	-882(ra) # 80004976 <log_write>
      brelse(bp);
    80003cf0:	854a                	mv	a0,s2
    80003cf2:	00000097          	auipc	ra,0x0
    80003cf6:	9fa080e7          	jalr	-1542(ra) # 800036ec <brelse>
      return iget(dev, inum);
    80003cfa:	85da                	mv	a1,s6
    80003cfc:	8556                	mv	a0,s5
    80003cfe:	00000097          	auipc	ra,0x0
    80003d02:	d9c080e7          	jalr	-612(ra) # 80003a9a <iget>
    80003d06:	bf5d                	j	80003cbc <ialloc+0x86>

0000000080003d08 <iupdate>:
{
    80003d08:	1101                	addi	sp,sp,-32
    80003d0a:	ec06                	sd	ra,24(sp)
    80003d0c:	e822                	sd	s0,16(sp)
    80003d0e:	e426                	sd	s1,8(sp)
    80003d10:	e04a                	sd	s2,0(sp)
    80003d12:	1000                	addi	s0,sp,32
    80003d14:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d16:	415c                	lw	a5,4(a0)
    80003d18:	0047d79b          	srliw	a5,a5,0x4
    80003d1c:	0023e597          	auipc	a1,0x23e
    80003d20:	8145a583          	lw	a1,-2028(a1) # 80241530 <sb+0x18>
    80003d24:	9dbd                	addw	a1,a1,a5
    80003d26:	4108                	lw	a0,0(a0)
    80003d28:	00000097          	auipc	ra,0x0
    80003d2c:	894080e7          	jalr	-1900(ra) # 800035bc <bread>
    80003d30:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003d32:	05850793          	addi	a5,a0,88
    80003d36:	40d8                	lw	a4,4(s1)
    80003d38:	8b3d                	andi	a4,a4,15
    80003d3a:	071a                	slli	a4,a4,0x6
    80003d3c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003d3e:	04449703          	lh	a4,68(s1)
    80003d42:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003d46:	04649703          	lh	a4,70(s1)
    80003d4a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003d4e:	04849703          	lh	a4,72(s1)
    80003d52:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003d56:	04a49703          	lh	a4,74(s1)
    80003d5a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003d5e:	44f8                	lw	a4,76(s1)
    80003d60:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d62:	03400613          	li	a2,52
    80003d66:	05048593          	addi	a1,s1,80
    80003d6a:	00c78513          	addi	a0,a5,12
    80003d6e:	ffffd097          	auipc	ra,0xffffd
    80003d72:	134080e7          	jalr	308(ra) # 80000ea2 <memmove>
  log_write(bp);
    80003d76:	854a                	mv	a0,s2
    80003d78:	00001097          	auipc	ra,0x1
    80003d7c:	bfe080e7          	jalr	-1026(ra) # 80004976 <log_write>
  brelse(bp);
    80003d80:	854a                	mv	a0,s2
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	96a080e7          	jalr	-1686(ra) # 800036ec <brelse>
}
    80003d8a:	60e2                	ld	ra,24(sp)
    80003d8c:	6442                	ld	s0,16(sp)
    80003d8e:	64a2                	ld	s1,8(sp)
    80003d90:	6902                	ld	s2,0(sp)
    80003d92:	6105                	addi	sp,sp,32
    80003d94:	8082                	ret

0000000080003d96 <idup>:
{
    80003d96:	1101                	addi	sp,sp,-32
    80003d98:	ec06                	sd	ra,24(sp)
    80003d9a:	e822                	sd	s0,16(sp)
    80003d9c:	e426                	sd	s1,8(sp)
    80003d9e:	1000                	addi	s0,sp,32
    80003da0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003da2:	0023d517          	auipc	a0,0x23d
    80003da6:	79650513          	addi	a0,a0,1942 # 80241538 <itable>
    80003daa:	ffffd097          	auipc	ra,0xffffd
    80003dae:	fa0080e7          	jalr	-96(ra) # 80000d4a <acquire>
  ip->ref++;
    80003db2:	449c                	lw	a5,8(s1)
    80003db4:	2785                	addiw	a5,a5,1
    80003db6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003db8:	0023d517          	auipc	a0,0x23d
    80003dbc:	78050513          	addi	a0,a0,1920 # 80241538 <itable>
    80003dc0:	ffffd097          	auipc	ra,0xffffd
    80003dc4:	03e080e7          	jalr	62(ra) # 80000dfe <release>
}
    80003dc8:	8526                	mv	a0,s1
    80003dca:	60e2                	ld	ra,24(sp)
    80003dcc:	6442                	ld	s0,16(sp)
    80003dce:	64a2                	ld	s1,8(sp)
    80003dd0:	6105                	addi	sp,sp,32
    80003dd2:	8082                	ret

0000000080003dd4 <ilock>:
{
    80003dd4:	1101                	addi	sp,sp,-32
    80003dd6:	ec06                	sd	ra,24(sp)
    80003dd8:	e822                	sd	s0,16(sp)
    80003dda:	e426                	sd	s1,8(sp)
    80003ddc:	e04a                	sd	s2,0(sp)
    80003dde:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003de0:	c115                	beqz	a0,80003e04 <ilock+0x30>
    80003de2:	84aa                	mv	s1,a0
    80003de4:	451c                	lw	a5,8(a0)
    80003de6:	00f05f63          	blez	a5,80003e04 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003dea:	0541                	addi	a0,a0,16
    80003dec:	00001097          	auipc	ra,0x1
    80003df0:	ca8080e7          	jalr	-856(ra) # 80004a94 <acquiresleep>
  if (ip->valid == 0)
    80003df4:	40bc                	lw	a5,64(s1)
    80003df6:	cf99                	beqz	a5,80003e14 <ilock+0x40>
}
    80003df8:	60e2                	ld	ra,24(sp)
    80003dfa:	6442                	ld	s0,16(sp)
    80003dfc:	64a2                	ld	s1,8(sp)
    80003dfe:	6902                	ld	s2,0(sp)
    80003e00:	6105                	addi	sp,sp,32
    80003e02:	8082                	ret
    panic("ilock");
    80003e04:	00005517          	auipc	a0,0x5
    80003e08:	96450513          	addi	a0,a0,-1692 # 80008768 <syscalls+0x1a8>
    80003e0c:	ffffc097          	auipc	ra,0xffffc
    80003e10:	734080e7          	jalr	1844(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e14:	40dc                	lw	a5,4(s1)
    80003e16:	0047d79b          	srliw	a5,a5,0x4
    80003e1a:	0023d597          	auipc	a1,0x23d
    80003e1e:	7165a583          	lw	a1,1814(a1) # 80241530 <sb+0x18>
    80003e22:	9dbd                	addw	a1,a1,a5
    80003e24:	4088                	lw	a0,0(s1)
    80003e26:	fffff097          	auipc	ra,0xfffff
    80003e2a:	796080e7          	jalr	1942(ra) # 800035bc <bread>
    80003e2e:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003e30:	05850593          	addi	a1,a0,88
    80003e34:	40dc                	lw	a5,4(s1)
    80003e36:	8bbd                	andi	a5,a5,15
    80003e38:	079a                	slli	a5,a5,0x6
    80003e3a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e3c:	00059783          	lh	a5,0(a1)
    80003e40:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e44:	00259783          	lh	a5,2(a1)
    80003e48:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e4c:	00459783          	lh	a5,4(a1)
    80003e50:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e54:	00659783          	lh	a5,6(a1)
    80003e58:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e5c:	459c                	lw	a5,8(a1)
    80003e5e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e60:	03400613          	li	a2,52
    80003e64:	05b1                	addi	a1,a1,12
    80003e66:	05048513          	addi	a0,s1,80
    80003e6a:	ffffd097          	auipc	ra,0xffffd
    80003e6e:	038080e7          	jalr	56(ra) # 80000ea2 <memmove>
    brelse(bp);
    80003e72:	854a                	mv	a0,s2
    80003e74:	00000097          	auipc	ra,0x0
    80003e78:	878080e7          	jalr	-1928(ra) # 800036ec <brelse>
    ip->valid = 1;
    80003e7c:	4785                	li	a5,1
    80003e7e:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003e80:	04449783          	lh	a5,68(s1)
    80003e84:	fbb5                	bnez	a5,80003df8 <ilock+0x24>
      panic("ilock: no type");
    80003e86:	00005517          	auipc	a0,0x5
    80003e8a:	8ea50513          	addi	a0,a0,-1814 # 80008770 <syscalls+0x1b0>
    80003e8e:	ffffc097          	auipc	ra,0xffffc
    80003e92:	6b2080e7          	jalr	1714(ra) # 80000540 <panic>

0000000080003e96 <iunlock>:
{
    80003e96:	1101                	addi	sp,sp,-32
    80003e98:	ec06                	sd	ra,24(sp)
    80003e9a:	e822                	sd	s0,16(sp)
    80003e9c:	e426                	sd	s1,8(sp)
    80003e9e:	e04a                	sd	s2,0(sp)
    80003ea0:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ea2:	c905                	beqz	a0,80003ed2 <iunlock+0x3c>
    80003ea4:	84aa                	mv	s1,a0
    80003ea6:	01050913          	addi	s2,a0,16
    80003eaa:	854a                	mv	a0,s2
    80003eac:	00001097          	auipc	ra,0x1
    80003eb0:	c82080e7          	jalr	-894(ra) # 80004b2e <holdingsleep>
    80003eb4:	cd19                	beqz	a0,80003ed2 <iunlock+0x3c>
    80003eb6:	449c                	lw	a5,8(s1)
    80003eb8:	00f05d63          	blez	a5,80003ed2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ebc:	854a                	mv	a0,s2
    80003ebe:	00001097          	auipc	ra,0x1
    80003ec2:	c2c080e7          	jalr	-980(ra) # 80004aea <releasesleep>
}
    80003ec6:	60e2                	ld	ra,24(sp)
    80003ec8:	6442                	ld	s0,16(sp)
    80003eca:	64a2                	ld	s1,8(sp)
    80003ecc:	6902                	ld	s2,0(sp)
    80003ece:	6105                	addi	sp,sp,32
    80003ed0:	8082                	ret
    panic("iunlock");
    80003ed2:	00005517          	auipc	a0,0x5
    80003ed6:	8ae50513          	addi	a0,a0,-1874 # 80008780 <syscalls+0x1c0>
    80003eda:	ffffc097          	auipc	ra,0xffffc
    80003ede:	666080e7          	jalr	1638(ra) # 80000540 <panic>

0000000080003ee2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void itrunc(struct inode *ip)
{
    80003ee2:	7179                	addi	sp,sp,-48
    80003ee4:	f406                	sd	ra,40(sp)
    80003ee6:	f022                	sd	s0,32(sp)
    80003ee8:	ec26                	sd	s1,24(sp)
    80003eea:	e84a                	sd	s2,16(sp)
    80003eec:	e44e                	sd	s3,8(sp)
    80003eee:	e052                	sd	s4,0(sp)
    80003ef0:	1800                	addi	s0,sp,48
    80003ef2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++)
    80003ef4:	05050493          	addi	s1,a0,80
    80003ef8:	08050913          	addi	s2,a0,128
    80003efc:	a021                	j	80003f04 <itrunc+0x22>
    80003efe:	0491                	addi	s1,s1,4
    80003f00:	01248d63          	beq	s1,s2,80003f1a <itrunc+0x38>
  {
    if (ip->addrs[i])
    80003f04:	408c                	lw	a1,0(s1)
    80003f06:	dde5                	beqz	a1,80003efe <itrunc+0x1c>
    {
      bfree(ip->dev, ip->addrs[i]);
    80003f08:	0009a503          	lw	a0,0(s3)
    80003f0c:	00000097          	auipc	ra,0x0
    80003f10:	8f6080e7          	jalr	-1802(ra) # 80003802 <bfree>
      ip->addrs[i] = 0;
    80003f14:	0004a023          	sw	zero,0(s1)
    80003f18:	b7dd                	j	80003efe <itrunc+0x1c>
    }
  }

  if (ip->addrs[NDIRECT])
    80003f1a:	0809a583          	lw	a1,128(s3)
    80003f1e:	e185                	bnez	a1,80003f3e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f20:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f24:	854e                	mv	a0,s3
    80003f26:	00000097          	auipc	ra,0x0
    80003f2a:	de2080e7          	jalr	-542(ra) # 80003d08 <iupdate>
}
    80003f2e:	70a2                	ld	ra,40(sp)
    80003f30:	7402                	ld	s0,32(sp)
    80003f32:	64e2                	ld	s1,24(sp)
    80003f34:	6942                	ld	s2,16(sp)
    80003f36:	69a2                	ld	s3,8(sp)
    80003f38:	6a02                	ld	s4,0(sp)
    80003f3a:	6145                	addi	sp,sp,48
    80003f3c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f3e:	0009a503          	lw	a0,0(s3)
    80003f42:	fffff097          	auipc	ra,0xfffff
    80003f46:	67a080e7          	jalr	1658(ra) # 800035bc <bread>
    80003f4a:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++)
    80003f4c:	05850493          	addi	s1,a0,88
    80003f50:	45850913          	addi	s2,a0,1112
    80003f54:	a021                	j	80003f5c <itrunc+0x7a>
    80003f56:	0491                	addi	s1,s1,4
    80003f58:	01248b63          	beq	s1,s2,80003f6e <itrunc+0x8c>
      if (a[j])
    80003f5c:	408c                	lw	a1,0(s1)
    80003f5e:	dde5                	beqz	a1,80003f56 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003f60:	0009a503          	lw	a0,0(s3)
    80003f64:	00000097          	auipc	ra,0x0
    80003f68:	89e080e7          	jalr	-1890(ra) # 80003802 <bfree>
    80003f6c:	b7ed                	j	80003f56 <itrunc+0x74>
    brelse(bp);
    80003f6e:	8552                	mv	a0,s4
    80003f70:	fffff097          	auipc	ra,0xfffff
    80003f74:	77c080e7          	jalr	1916(ra) # 800036ec <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f78:	0809a583          	lw	a1,128(s3)
    80003f7c:	0009a503          	lw	a0,0(s3)
    80003f80:	00000097          	auipc	ra,0x0
    80003f84:	882080e7          	jalr	-1918(ra) # 80003802 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f88:	0809a023          	sw	zero,128(s3)
    80003f8c:	bf51                	j	80003f20 <itrunc+0x3e>

0000000080003f8e <iput>:
{
    80003f8e:	1101                	addi	sp,sp,-32
    80003f90:	ec06                	sd	ra,24(sp)
    80003f92:	e822                	sd	s0,16(sp)
    80003f94:	e426                	sd	s1,8(sp)
    80003f96:	e04a                	sd	s2,0(sp)
    80003f98:	1000                	addi	s0,sp,32
    80003f9a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f9c:	0023d517          	auipc	a0,0x23d
    80003fa0:	59c50513          	addi	a0,a0,1436 # 80241538 <itable>
    80003fa4:	ffffd097          	auipc	ra,0xffffd
    80003fa8:	da6080e7          	jalr	-602(ra) # 80000d4a <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003fac:	4498                	lw	a4,8(s1)
    80003fae:	4785                	li	a5,1
    80003fb0:	02f70363          	beq	a4,a5,80003fd6 <iput+0x48>
  ip->ref--;
    80003fb4:	449c                	lw	a5,8(s1)
    80003fb6:	37fd                	addiw	a5,a5,-1
    80003fb8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003fba:	0023d517          	auipc	a0,0x23d
    80003fbe:	57e50513          	addi	a0,a0,1406 # 80241538 <itable>
    80003fc2:	ffffd097          	auipc	ra,0xffffd
    80003fc6:	e3c080e7          	jalr	-452(ra) # 80000dfe <release>
}
    80003fca:	60e2                	ld	ra,24(sp)
    80003fcc:	6442                	ld	s0,16(sp)
    80003fce:	64a2                	ld	s1,8(sp)
    80003fd0:	6902                	ld	s2,0(sp)
    80003fd2:	6105                	addi	sp,sp,32
    80003fd4:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003fd6:	40bc                	lw	a5,64(s1)
    80003fd8:	dff1                	beqz	a5,80003fb4 <iput+0x26>
    80003fda:	04a49783          	lh	a5,74(s1)
    80003fde:	fbf9                	bnez	a5,80003fb4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003fe0:	01048913          	addi	s2,s1,16
    80003fe4:	854a                	mv	a0,s2
    80003fe6:	00001097          	auipc	ra,0x1
    80003fea:	aae080e7          	jalr	-1362(ra) # 80004a94 <acquiresleep>
    release(&itable.lock);
    80003fee:	0023d517          	auipc	a0,0x23d
    80003ff2:	54a50513          	addi	a0,a0,1354 # 80241538 <itable>
    80003ff6:	ffffd097          	auipc	ra,0xffffd
    80003ffa:	e08080e7          	jalr	-504(ra) # 80000dfe <release>
    itrunc(ip);
    80003ffe:	8526                	mv	a0,s1
    80004000:	00000097          	auipc	ra,0x0
    80004004:	ee2080e7          	jalr	-286(ra) # 80003ee2 <itrunc>
    ip->type = 0;
    80004008:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000400c:	8526                	mv	a0,s1
    8000400e:	00000097          	auipc	ra,0x0
    80004012:	cfa080e7          	jalr	-774(ra) # 80003d08 <iupdate>
    ip->valid = 0;
    80004016:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000401a:	854a                	mv	a0,s2
    8000401c:	00001097          	auipc	ra,0x1
    80004020:	ace080e7          	jalr	-1330(ra) # 80004aea <releasesleep>
    acquire(&itable.lock);
    80004024:	0023d517          	auipc	a0,0x23d
    80004028:	51450513          	addi	a0,a0,1300 # 80241538 <itable>
    8000402c:	ffffd097          	auipc	ra,0xffffd
    80004030:	d1e080e7          	jalr	-738(ra) # 80000d4a <acquire>
    80004034:	b741                	j	80003fb4 <iput+0x26>

0000000080004036 <iunlockput>:
{
    80004036:	1101                	addi	sp,sp,-32
    80004038:	ec06                	sd	ra,24(sp)
    8000403a:	e822                	sd	s0,16(sp)
    8000403c:	e426                	sd	s1,8(sp)
    8000403e:	1000                	addi	s0,sp,32
    80004040:	84aa                	mv	s1,a0
  iunlock(ip);
    80004042:	00000097          	auipc	ra,0x0
    80004046:	e54080e7          	jalr	-428(ra) # 80003e96 <iunlock>
  iput(ip);
    8000404a:	8526                	mv	a0,s1
    8000404c:	00000097          	auipc	ra,0x0
    80004050:	f42080e7          	jalr	-190(ra) # 80003f8e <iput>
}
    80004054:	60e2                	ld	ra,24(sp)
    80004056:	6442                	ld	s0,16(sp)
    80004058:	64a2                	ld	s1,8(sp)
    8000405a:	6105                	addi	sp,sp,32
    8000405c:	8082                	ret

000000008000405e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void stati(struct inode *ip, struct stat *st)
{
    8000405e:	1141                	addi	sp,sp,-16
    80004060:	e422                	sd	s0,8(sp)
    80004062:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004064:	411c                	lw	a5,0(a0)
    80004066:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004068:	415c                	lw	a5,4(a0)
    8000406a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000406c:	04451783          	lh	a5,68(a0)
    80004070:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004074:	04a51783          	lh	a5,74(a0)
    80004078:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000407c:	04c56783          	lwu	a5,76(a0)
    80004080:	e99c                	sd	a5,16(a1)
}
    80004082:	6422                	ld	s0,8(sp)
    80004084:	0141                	addi	sp,sp,16
    80004086:	8082                	ret

0000000080004088 <readi>:
int readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80004088:	457c                	lw	a5,76(a0)
    8000408a:	0ed7e963          	bltu	a5,a3,8000417c <readi+0xf4>
{
    8000408e:	7159                	addi	sp,sp,-112
    80004090:	f486                	sd	ra,104(sp)
    80004092:	f0a2                	sd	s0,96(sp)
    80004094:	eca6                	sd	s1,88(sp)
    80004096:	e8ca                	sd	s2,80(sp)
    80004098:	e4ce                	sd	s3,72(sp)
    8000409a:	e0d2                	sd	s4,64(sp)
    8000409c:	fc56                	sd	s5,56(sp)
    8000409e:	f85a                	sd	s6,48(sp)
    800040a0:	f45e                	sd	s7,40(sp)
    800040a2:	f062                	sd	s8,32(sp)
    800040a4:	ec66                	sd	s9,24(sp)
    800040a6:	e86a                	sd	s10,16(sp)
    800040a8:	e46e                	sd	s11,8(sp)
    800040aa:	1880                	addi	s0,sp,112
    800040ac:	8b2a                	mv	s6,a0
    800040ae:	8bae                	mv	s7,a1
    800040b0:	8a32                	mv	s4,a2
    800040b2:	84b6                	mv	s1,a3
    800040b4:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800040b6:	9f35                	addw	a4,a4,a3
    return 0;
    800040b8:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800040ba:	0ad76063          	bltu	a4,a3,8000415a <readi+0xd2>
  if (off + n > ip->size)
    800040be:	00e7f463          	bgeu	a5,a4,800040c6 <readi+0x3e>
    n = ip->size - off;
    800040c2:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    800040c6:	0a0a8963          	beqz	s5,80004178 <readi+0xf0>
    800040ca:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800040cc:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1)
    800040d0:	5c7d                	li	s8,-1
    800040d2:	a82d                	j	8000410c <readi+0x84>
    800040d4:	020d1d93          	slli	s11,s10,0x20
    800040d8:	020ddd93          	srli	s11,s11,0x20
    800040dc:	05890613          	addi	a2,s2,88
    800040e0:	86ee                	mv	a3,s11
    800040e2:	963a                	add	a2,a2,a4
    800040e4:	85d2                	mv	a1,s4
    800040e6:	855e                	mv	a0,s7
    800040e8:	ffffe097          	auipc	ra,0xffffe
    800040ec:	7b2080e7          	jalr	1970(ra) # 8000289a <either_copyout>
    800040f0:	05850d63          	beq	a0,s8,8000414a <readi+0xc2>
    {
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800040f4:	854a                	mv	a0,s2
    800040f6:	fffff097          	auipc	ra,0xfffff
    800040fa:	5f6080e7          	jalr	1526(ra) # 800036ec <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    800040fe:	013d09bb          	addw	s3,s10,s3
    80004102:	009d04bb          	addw	s1,s10,s1
    80004106:	9a6e                	add	s4,s4,s11
    80004108:	0559f763          	bgeu	s3,s5,80004156 <readi+0xce>
    uint addr = bmap(ip, off / BSIZE);
    8000410c:	00a4d59b          	srliw	a1,s1,0xa
    80004110:	855a                	mv	a0,s6
    80004112:	00000097          	auipc	ra,0x0
    80004116:	89e080e7          	jalr	-1890(ra) # 800039b0 <bmap>
    8000411a:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    8000411e:	cd85                	beqz	a1,80004156 <readi+0xce>
    bp = bread(ip->dev, addr);
    80004120:	000b2503          	lw	a0,0(s6)
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	498080e7          	jalr	1176(ra) # 800035bc <bread>
    8000412c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000412e:	3ff4f713          	andi	a4,s1,1023
    80004132:	40ec87bb          	subw	a5,s9,a4
    80004136:	413a86bb          	subw	a3,s5,s3
    8000413a:	8d3e                	mv	s10,a5
    8000413c:	2781                	sext.w	a5,a5
    8000413e:	0006861b          	sext.w	a2,a3
    80004142:	f8f679e3          	bgeu	a2,a5,800040d4 <readi+0x4c>
    80004146:	8d36                	mv	s10,a3
    80004148:	b771                	j	800040d4 <readi+0x4c>
      brelse(bp);
    8000414a:	854a                	mv	a0,s2
    8000414c:	fffff097          	auipc	ra,0xfffff
    80004150:	5a0080e7          	jalr	1440(ra) # 800036ec <brelse>
      tot = -1;
    80004154:	59fd                	li	s3,-1
  }
  return tot;
    80004156:	0009851b          	sext.w	a0,s3
}
    8000415a:	70a6                	ld	ra,104(sp)
    8000415c:	7406                	ld	s0,96(sp)
    8000415e:	64e6                	ld	s1,88(sp)
    80004160:	6946                	ld	s2,80(sp)
    80004162:	69a6                	ld	s3,72(sp)
    80004164:	6a06                	ld	s4,64(sp)
    80004166:	7ae2                	ld	s5,56(sp)
    80004168:	7b42                	ld	s6,48(sp)
    8000416a:	7ba2                	ld	s7,40(sp)
    8000416c:	7c02                	ld	s8,32(sp)
    8000416e:	6ce2                	ld	s9,24(sp)
    80004170:	6d42                	ld	s10,16(sp)
    80004172:	6da2                	ld	s11,8(sp)
    80004174:	6165                	addi	sp,sp,112
    80004176:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80004178:	89d6                	mv	s3,s5
    8000417a:	bff1                	j	80004156 <readi+0xce>
    return 0;
    8000417c:	4501                	li	a0,0
}
    8000417e:	8082                	ret

0000000080004180 <writei>:
int writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80004180:	457c                	lw	a5,76(a0)
    80004182:	10d7e863          	bltu	a5,a3,80004292 <writei+0x112>
{
    80004186:	7159                	addi	sp,sp,-112
    80004188:	f486                	sd	ra,104(sp)
    8000418a:	f0a2                	sd	s0,96(sp)
    8000418c:	eca6                	sd	s1,88(sp)
    8000418e:	e8ca                	sd	s2,80(sp)
    80004190:	e4ce                	sd	s3,72(sp)
    80004192:	e0d2                	sd	s4,64(sp)
    80004194:	fc56                	sd	s5,56(sp)
    80004196:	f85a                	sd	s6,48(sp)
    80004198:	f45e                	sd	s7,40(sp)
    8000419a:	f062                	sd	s8,32(sp)
    8000419c:	ec66                	sd	s9,24(sp)
    8000419e:	e86a                	sd	s10,16(sp)
    800041a0:	e46e                	sd	s11,8(sp)
    800041a2:	1880                	addi	s0,sp,112
    800041a4:	8aaa                	mv	s5,a0
    800041a6:	8bae                	mv	s7,a1
    800041a8:	8a32                	mv	s4,a2
    800041aa:	8936                	mv	s2,a3
    800041ac:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800041ae:	00e687bb          	addw	a5,a3,a4
    800041b2:	0ed7e263          	bltu	a5,a3,80004296 <writei+0x116>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800041b6:	00043737          	lui	a4,0x43
    800041ba:	0ef76063          	bltu	a4,a5,8000429a <writei+0x11a>
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m)
    800041be:	0c0b0863          	beqz	s6,8000428e <writei+0x10e>
    800041c2:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800041c4:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1)
    800041c8:	5c7d                	li	s8,-1
    800041ca:	a091                	j	8000420e <writei+0x8e>
    800041cc:	020d1d93          	slli	s11,s10,0x20
    800041d0:	020ddd93          	srli	s11,s11,0x20
    800041d4:	05848513          	addi	a0,s1,88
    800041d8:	86ee                	mv	a3,s11
    800041da:	8652                	mv	a2,s4
    800041dc:	85de                	mv	a1,s7
    800041de:	953a                	add	a0,a0,a4
    800041e0:	ffffe097          	auipc	ra,0xffffe
    800041e4:	710080e7          	jalr	1808(ra) # 800028f0 <either_copyin>
    800041e8:	07850263          	beq	a0,s8,8000424c <writei+0xcc>
    {
      brelse(bp);
      break;
    }
    log_write(bp);
    800041ec:	8526                	mv	a0,s1
    800041ee:	00000097          	auipc	ra,0x0
    800041f2:	788080e7          	jalr	1928(ra) # 80004976 <log_write>
    brelse(bp);
    800041f6:	8526                	mv	a0,s1
    800041f8:	fffff097          	auipc	ra,0xfffff
    800041fc:	4f4080e7          	jalr	1268(ra) # 800036ec <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80004200:	013d09bb          	addw	s3,s10,s3
    80004204:	012d093b          	addw	s2,s10,s2
    80004208:	9a6e                	add	s4,s4,s11
    8000420a:	0569f663          	bgeu	s3,s6,80004256 <writei+0xd6>
    uint addr = bmap(ip, off / BSIZE);
    8000420e:	00a9559b          	srliw	a1,s2,0xa
    80004212:	8556                	mv	a0,s5
    80004214:	fffff097          	auipc	ra,0xfffff
    80004218:	79c080e7          	jalr	1948(ra) # 800039b0 <bmap>
    8000421c:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80004220:	c99d                	beqz	a1,80004256 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004222:	000aa503          	lw	a0,0(s5)
    80004226:	fffff097          	auipc	ra,0xfffff
    8000422a:	396080e7          	jalr	918(ra) # 800035bc <bread>
    8000422e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80004230:	3ff97713          	andi	a4,s2,1023
    80004234:	40ec87bb          	subw	a5,s9,a4
    80004238:	413b06bb          	subw	a3,s6,s3
    8000423c:	8d3e                	mv	s10,a5
    8000423e:	2781                	sext.w	a5,a5
    80004240:	0006861b          	sext.w	a2,a3
    80004244:	f8f674e3          	bgeu	a2,a5,800041cc <writei+0x4c>
    80004248:	8d36                	mv	s10,a3
    8000424a:	b749                	j	800041cc <writei+0x4c>
      brelse(bp);
    8000424c:	8526                	mv	a0,s1
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	49e080e7          	jalr	1182(ra) # 800036ec <brelse>
  }

  if (off > ip->size)
    80004256:	04caa783          	lw	a5,76(s5)
    8000425a:	0127f463          	bgeu	a5,s2,80004262 <writei+0xe2>
    ip->size = off;
    8000425e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004262:	8556                	mv	a0,s5
    80004264:	00000097          	auipc	ra,0x0
    80004268:	aa4080e7          	jalr	-1372(ra) # 80003d08 <iupdate>

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
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    8000428e:	89da                	mv	s3,s6
    80004290:	bfc9                	j	80004262 <writei+0xe2>
    return -1;
    80004292:	557d                	li	a0,-1
}
    80004294:	8082                	ret
    return -1;
    80004296:	557d                	li	a0,-1
    80004298:	bfe1                	j	80004270 <writei+0xf0>
    return -1;
    8000429a:	557d                	li	a0,-1
    8000429c:	bfd1                	j	80004270 <writei+0xf0>

000000008000429e <namecmp>:

// Directories

int namecmp(const char *s, const char *t)
{
    8000429e:	1141                	addi	sp,sp,-16
    800042a0:	e406                	sd	ra,8(sp)
    800042a2:	e022                	sd	s0,0(sp)
    800042a4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800042a6:	4639                	li	a2,14
    800042a8:	ffffd097          	auipc	ra,0xffffd
    800042ac:	c6e080e7          	jalr	-914(ra) # 80000f16 <strncmp>
}
    800042b0:	60a2                	ld	ra,8(sp)
    800042b2:	6402                	ld	s0,0(sp)
    800042b4:	0141                	addi	sp,sp,16
    800042b6:	8082                	ret

00000000800042b8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800042b8:	7139                	addi	sp,sp,-64
    800042ba:	fc06                	sd	ra,56(sp)
    800042bc:	f822                	sd	s0,48(sp)
    800042be:	f426                	sd	s1,40(sp)
    800042c0:	f04a                	sd	s2,32(sp)
    800042c2:	ec4e                	sd	s3,24(sp)
    800042c4:	e852                	sd	s4,16(sp)
    800042c6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800042c8:	04451703          	lh	a4,68(a0)
    800042cc:	4785                	li	a5,1
    800042ce:	00f71a63          	bne	a4,a5,800042e2 <dirlookup+0x2a>
    800042d2:	892a                	mv	s2,a0
    800042d4:	89ae                	mv	s3,a1
    800042d6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de))
    800042d8:	457c                	lw	a5,76(a0)
    800042da:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800042dc:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de))
    800042de:	e79d                	bnez	a5,8000430c <dirlookup+0x54>
    800042e0:	a8a5                	j	80004358 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800042e2:	00004517          	auipc	a0,0x4
    800042e6:	4a650513          	addi	a0,a0,1190 # 80008788 <syscalls+0x1c8>
    800042ea:	ffffc097          	auipc	ra,0xffffc
    800042ee:	256080e7          	jalr	598(ra) # 80000540 <panic>
      panic("dirlookup read");
    800042f2:	00004517          	auipc	a0,0x4
    800042f6:	4ae50513          	addi	a0,a0,1198 # 800087a0 <syscalls+0x1e0>
    800042fa:	ffffc097          	auipc	ra,0xffffc
    800042fe:	246080e7          	jalr	582(ra) # 80000540 <panic>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004302:	24c1                	addiw	s1,s1,16
    80004304:	04c92783          	lw	a5,76(s2)
    80004308:	04f4f763          	bgeu	s1,a5,80004356 <dirlookup+0x9e>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000430c:	4741                	li	a4,16
    8000430e:	86a6                	mv	a3,s1
    80004310:	fc040613          	addi	a2,s0,-64
    80004314:	4581                	li	a1,0
    80004316:	854a                	mv	a0,s2
    80004318:	00000097          	auipc	ra,0x0
    8000431c:	d70080e7          	jalr	-656(ra) # 80004088 <readi>
    80004320:	47c1                	li	a5,16
    80004322:	fcf518e3          	bne	a0,a5,800042f2 <dirlookup+0x3a>
    if (de.inum == 0)
    80004326:	fc045783          	lhu	a5,-64(s0)
    8000432a:	dfe1                	beqz	a5,80004302 <dirlookup+0x4a>
    if (namecmp(name, de.name) == 0)
    8000432c:	fc240593          	addi	a1,s0,-62
    80004330:	854e                	mv	a0,s3
    80004332:	00000097          	auipc	ra,0x0
    80004336:	f6c080e7          	jalr	-148(ra) # 8000429e <namecmp>
    8000433a:	f561                	bnez	a0,80004302 <dirlookup+0x4a>
      if (poff)
    8000433c:	000a0463          	beqz	s4,80004344 <dirlookup+0x8c>
        *poff = off;
    80004340:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004344:	fc045583          	lhu	a1,-64(s0)
    80004348:	00092503          	lw	a0,0(s2)
    8000434c:	fffff097          	auipc	ra,0xfffff
    80004350:	74e080e7          	jalr	1870(ra) # 80003a9a <iget>
    80004354:	a011                	j	80004358 <dirlookup+0xa0>
  return 0;
    80004356:	4501                	li	a0,0
}
    80004358:	70e2                	ld	ra,56(sp)
    8000435a:	7442                	ld	s0,48(sp)
    8000435c:	74a2                	ld	s1,40(sp)
    8000435e:	7902                	ld	s2,32(sp)
    80004360:	69e2                	ld	s3,24(sp)
    80004362:	6a42                	ld	s4,16(sp)
    80004364:	6121                	addi	sp,sp,64
    80004366:	8082                	ret

0000000080004368 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80004368:	711d                	addi	sp,sp,-96
    8000436a:	ec86                	sd	ra,88(sp)
    8000436c:	e8a2                	sd	s0,80(sp)
    8000436e:	e4a6                	sd	s1,72(sp)
    80004370:	e0ca                	sd	s2,64(sp)
    80004372:	fc4e                	sd	s3,56(sp)
    80004374:	f852                	sd	s4,48(sp)
    80004376:	f456                	sd	s5,40(sp)
    80004378:	f05a                	sd	s6,32(sp)
    8000437a:	ec5e                	sd	s7,24(sp)
    8000437c:	e862                	sd	s8,16(sp)
    8000437e:	e466                	sd	s9,8(sp)
    80004380:	e06a                	sd	s10,0(sp)
    80004382:	1080                	addi	s0,sp,96
    80004384:	84aa                	mv	s1,a0
    80004386:	8b2e                	mv	s6,a1
    80004388:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    8000438a:	00054703          	lbu	a4,0(a0)
    8000438e:	02f00793          	li	a5,47
    80004392:	02f70363          	beq	a4,a5,800043b8 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004396:	ffffd097          	auipc	ra,0xffffd
    8000439a:	7c6080e7          	jalr	1990(ra) # 80001b5c <myproc>
    8000439e:	15053503          	ld	a0,336(a0)
    800043a2:	00000097          	auipc	ra,0x0
    800043a6:	9f4080e7          	jalr	-1548(ra) # 80003d96 <idup>
    800043aa:	8a2a                	mv	s4,a0
  while (*path == '/')
    800043ac:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    800043b0:	4cb5                	li	s9,13
  len = path - s;
    800043b2:	4b81                	li	s7,0

  while ((path = skipelem(path, name)) != 0)
  {
    ilock(ip);
    if (ip->type != T_DIR)
    800043b4:	4c05                	li	s8,1
    800043b6:	a87d                	j	80004474 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800043b8:	4585                	li	a1,1
    800043ba:	4505                	li	a0,1
    800043bc:	fffff097          	auipc	ra,0xfffff
    800043c0:	6de080e7          	jalr	1758(ra) # 80003a9a <iget>
    800043c4:	8a2a                	mv	s4,a0
    800043c6:	b7dd                	j	800043ac <namex+0x44>
    {
      iunlockput(ip);
    800043c8:	8552                	mv	a0,s4
    800043ca:	00000097          	auipc	ra,0x0
    800043ce:	c6c080e7          	jalr	-916(ra) # 80004036 <iunlockput>
      return 0;
    800043d2:	4a01                	li	s4,0
  {
    iput(ip);
    return 0;
  }
  return ip;
}
    800043d4:	8552                	mv	a0,s4
    800043d6:	60e6                	ld	ra,88(sp)
    800043d8:	6446                	ld	s0,80(sp)
    800043da:	64a6                	ld	s1,72(sp)
    800043dc:	6906                	ld	s2,64(sp)
    800043de:	79e2                	ld	s3,56(sp)
    800043e0:	7a42                	ld	s4,48(sp)
    800043e2:	7aa2                	ld	s5,40(sp)
    800043e4:	7b02                	ld	s6,32(sp)
    800043e6:	6be2                	ld	s7,24(sp)
    800043e8:	6c42                	ld	s8,16(sp)
    800043ea:	6ca2                	ld	s9,8(sp)
    800043ec:	6d02                	ld	s10,0(sp)
    800043ee:	6125                	addi	sp,sp,96
    800043f0:	8082                	ret
      iunlock(ip);
    800043f2:	8552                	mv	a0,s4
    800043f4:	00000097          	auipc	ra,0x0
    800043f8:	aa2080e7          	jalr	-1374(ra) # 80003e96 <iunlock>
      return ip;
    800043fc:	bfe1                	j	800043d4 <namex+0x6c>
      iunlockput(ip);
    800043fe:	8552                	mv	a0,s4
    80004400:	00000097          	auipc	ra,0x0
    80004404:	c36080e7          	jalr	-970(ra) # 80004036 <iunlockput>
      return 0;
    80004408:	8a4e                	mv	s4,s3
    8000440a:	b7e9                	j	800043d4 <namex+0x6c>
  len = path - s;
    8000440c:	40998633          	sub	a2,s3,s1
    80004410:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80004414:	09acd863          	bge	s9,s10,800044a4 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004418:	4639                	li	a2,14
    8000441a:	85a6                	mv	a1,s1
    8000441c:	8556                	mv	a0,s5
    8000441e:	ffffd097          	auipc	ra,0xffffd
    80004422:	a84080e7          	jalr	-1404(ra) # 80000ea2 <memmove>
    80004426:	84ce                	mv	s1,s3
  while (*path == '/')
    80004428:	0004c783          	lbu	a5,0(s1)
    8000442c:	01279763          	bne	a5,s2,8000443a <namex+0xd2>
    path++;
    80004430:	0485                	addi	s1,s1,1
  while (*path == '/')
    80004432:	0004c783          	lbu	a5,0(s1)
    80004436:	ff278de3          	beq	a5,s2,80004430 <namex+0xc8>
    ilock(ip);
    8000443a:	8552                	mv	a0,s4
    8000443c:	00000097          	auipc	ra,0x0
    80004440:	998080e7          	jalr	-1640(ra) # 80003dd4 <ilock>
    if (ip->type != T_DIR)
    80004444:	044a1783          	lh	a5,68(s4)
    80004448:	f98790e3          	bne	a5,s8,800043c8 <namex+0x60>
    if (nameiparent && *path == '\0')
    8000444c:	000b0563          	beqz	s6,80004456 <namex+0xee>
    80004450:	0004c783          	lbu	a5,0(s1)
    80004454:	dfd9                	beqz	a5,800043f2 <namex+0x8a>
    if ((next = dirlookup(ip, name, 0)) == 0)
    80004456:	865e                	mv	a2,s7
    80004458:	85d6                	mv	a1,s5
    8000445a:	8552                	mv	a0,s4
    8000445c:	00000097          	auipc	ra,0x0
    80004460:	e5c080e7          	jalr	-420(ra) # 800042b8 <dirlookup>
    80004464:	89aa                	mv	s3,a0
    80004466:	dd41                	beqz	a0,800043fe <namex+0x96>
    iunlockput(ip);
    80004468:	8552                	mv	a0,s4
    8000446a:	00000097          	auipc	ra,0x0
    8000446e:	bcc080e7          	jalr	-1076(ra) # 80004036 <iunlockput>
    ip = next;
    80004472:	8a4e                	mv	s4,s3
  while (*path == '/')
    80004474:	0004c783          	lbu	a5,0(s1)
    80004478:	01279763          	bne	a5,s2,80004486 <namex+0x11e>
    path++;
    8000447c:	0485                	addi	s1,s1,1
  while (*path == '/')
    8000447e:	0004c783          	lbu	a5,0(s1)
    80004482:	ff278de3          	beq	a5,s2,8000447c <namex+0x114>
  if (*path == 0)
    80004486:	cb9d                	beqz	a5,800044bc <namex+0x154>
  while (*path != '/' && *path != 0)
    80004488:	0004c783          	lbu	a5,0(s1)
    8000448c:	89a6                	mv	s3,s1
  len = path - s;
    8000448e:	8d5e                	mv	s10,s7
    80004490:	865e                	mv	a2,s7
  while (*path != '/' && *path != 0)
    80004492:	01278963          	beq	a5,s2,800044a4 <namex+0x13c>
    80004496:	dbbd                	beqz	a5,8000440c <namex+0xa4>
    path++;
    80004498:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    8000449a:	0009c783          	lbu	a5,0(s3)
    8000449e:	ff279ce3          	bne	a5,s2,80004496 <namex+0x12e>
    800044a2:	b7ad                	j	8000440c <namex+0xa4>
    memmove(name, s, len);
    800044a4:	2601                	sext.w	a2,a2
    800044a6:	85a6                	mv	a1,s1
    800044a8:	8556                	mv	a0,s5
    800044aa:	ffffd097          	auipc	ra,0xffffd
    800044ae:	9f8080e7          	jalr	-1544(ra) # 80000ea2 <memmove>
    name[len] = 0;
    800044b2:	9d56                	add	s10,s10,s5
    800044b4:	000d0023          	sb	zero,0(s10)
    800044b8:	84ce                	mv	s1,s3
    800044ba:	b7bd                	j	80004428 <namex+0xc0>
  if (nameiparent)
    800044bc:	f00b0ce3          	beqz	s6,800043d4 <namex+0x6c>
    iput(ip);
    800044c0:	8552                	mv	a0,s4
    800044c2:	00000097          	auipc	ra,0x0
    800044c6:	acc080e7          	jalr	-1332(ra) # 80003f8e <iput>
    return 0;
    800044ca:	4a01                	li	s4,0
    800044cc:	b721                	j	800043d4 <namex+0x6c>

00000000800044ce <dirlink>:
{
    800044ce:	7139                	addi	sp,sp,-64
    800044d0:	fc06                	sd	ra,56(sp)
    800044d2:	f822                	sd	s0,48(sp)
    800044d4:	f426                	sd	s1,40(sp)
    800044d6:	f04a                	sd	s2,32(sp)
    800044d8:	ec4e                	sd	s3,24(sp)
    800044da:	e852                	sd	s4,16(sp)
    800044dc:	0080                	addi	s0,sp,64
    800044de:	892a                	mv	s2,a0
    800044e0:	8a2e                	mv	s4,a1
    800044e2:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0)
    800044e4:	4601                	li	a2,0
    800044e6:	00000097          	auipc	ra,0x0
    800044ea:	dd2080e7          	jalr	-558(ra) # 800042b8 <dirlookup>
    800044ee:	e93d                	bnez	a0,80004564 <dirlink+0x96>
  for (off = 0; off < dp->size; off += sizeof(de))
    800044f0:	04c92483          	lw	s1,76(s2)
    800044f4:	c49d                	beqz	s1,80004522 <dirlink+0x54>
    800044f6:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044f8:	4741                	li	a4,16
    800044fa:	86a6                	mv	a3,s1
    800044fc:	fc040613          	addi	a2,s0,-64
    80004500:	4581                	li	a1,0
    80004502:	854a                	mv	a0,s2
    80004504:	00000097          	auipc	ra,0x0
    80004508:	b84080e7          	jalr	-1148(ra) # 80004088 <readi>
    8000450c:	47c1                	li	a5,16
    8000450e:	06f51163          	bne	a0,a5,80004570 <dirlink+0xa2>
    if (de.inum == 0)
    80004512:	fc045783          	lhu	a5,-64(s0)
    80004516:	c791                	beqz	a5,80004522 <dirlink+0x54>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004518:	24c1                	addiw	s1,s1,16
    8000451a:	04c92783          	lw	a5,76(s2)
    8000451e:	fcf4ede3          	bltu	s1,a5,800044f8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004522:	4639                	li	a2,14
    80004524:	85d2                	mv	a1,s4
    80004526:	fc240513          	addi	a0,s0,-62
    8000452a:	ffffd097          	auipc	ra,0xffffd
    8000452e:	a28080e7          	jalr	-1496(ra) # 80000f52 <strncpy>
  de.inum = inum;
    80004532:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004536:	4741                	li	a4,16
    80004538:	86a6                	mv	a3,s1
    8000453a:	fc040613          	addi	a2,s0,-64
    8000453e:	4581                	li	a1,0
    80004540:	854a                	mv	a0,s2
    80004542:	00000097          	auipc	ra,0x0
    80004546:	c3e080e7          	jalr	-962(ra) # 80004180 <writei>
    8000454a:	1541                	addi	a0,a0,-16
    8000454c:	00a03533          	snez	a0,a0
    80004550:	40a00533          	neg	a0,a0
}
    80004554:	70e2                	ld	ra,56(sp)
    80004556:	7442                	ld	s0,48(sp)
    80004558:	74a2                	ld	s1,40(sp)
    8000455a:	7902                	ld	s2,32(sp)
    8000455c:	69e2                	ld	s3,24(sp)
    8000455e:	6a42                	ld	s4,16(sp)
    80004560:	6121                	addi	sp,sp,64
    80004562:	8082                	ret
    iput(ip);
    80004564:	00000097          	auipc	ra,0x0
    80004568:	a2a080e7          	jalr	-1494(ra) # 80003f8e <iput>
    return -1;
    8000456c:	557d                	li	a0,-1
    8000456e:	b7dd                	j	80004554 <dirlink+0x86>
      panic("dirlink read");
    80004570:	00004517          	auipc	a0,0x4
    80004574:	24050513          	addi	a0,a0,576 # 800087b0 <syscalls+0x1f0>
    80004578:	ffffc097          	auipc	ra,0xffffc
    8000457c:	fc8080e7          	jalr	-56(ra) # 80000540 <panic>

0000000080004580 <namei>:

struct inode *
namei(char *path)
{
    80004580:	1101                	addi	sp,sp,-32
    80004582:	ec06                	sd	ra,24(sp)
    80004584:	e822                	sd	s0,16(sp)
    80004586:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004588:	fe040613          	addi	a2,s0,-32
    8000458c:	4581                	li	a1,0
    8000458e:	00000097          	auipc	ra,0x0
    80004592:	dda080e7          	jalr	-550(ra) # 80004368 <namex>
}
    80004596:	60e2                	ld	ra,24(sp)
    80004598:	6442                	ld	s0,16(sp)
    8000459a:	6105                	addi	sp,sp,32
    8000459c:	8082                	ret

000000008000459e <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    8000459e:	1141                	addi	sp,sp,-16
    800045a0:	e406                	sd	ra,8(sp)
    800045a2:	e022                	sd	s0,0(sp)
    800045a4:	0800                	addi	s0,sp,16
    800045a6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800045a8:	4585                	li	a1,1
    800045aa:	00000097          	auipc	ra,0x0
    800045ae:	dbe080e7          	jalr	-578(ra) # 80004368 <namex>
}
    800045b2:	60a2                	ld	ra,8(sp)
    800045b4:	6402                	ld	s0,0(sp)
    800045b6:	0141                	addi	sp,sp,16
    800045b8:	8082                	ret

00000000800045ba <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800045ba:	1101                	addi	sp,sp,-32
    800045bc:	ec06                	sd	ra,24(sp)
    800045be:	e822                	sd	s0,16(sp)
    800045c0:	e426                	sd	s1,8(sp)
    800045c2:	e04a                	sd	s2,0(sp)
    800045c4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800045c6:	0023f917          	auipc	s2,0x23f
    800045ca:	a1a90913          	addi	s2,s2,-1510 # 80242fe0 <log>
    800045ce:	01892583          	lw	a1,24(s2)
    800045d2:	02892503          	lw	a0,40(s2)
    800045d6:	fffff097          	auipc	ra,0xfffff
    800045da:	fe6080e7          	jalr	-26(ra) # 800035bc <bread>
    800045de:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    800045e0:	02c92683          	lw	a3,44(s2)
    800045e4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++)
    800045e6:	02d05863          	blez	a3,80004616 <write_head+0x5c>
    800045ea:	0023f797          	auipc	a5,0x23f
    800045ee:	a2678793          	addi	a5,a5,-1498 # 80243010 <log+0x30>
    800045f2:	05c50713          	addi	a4,a0,92
    800045f6:	36fd                	addiw	a3,a3,-1
    800045f8:	02069613          	slli	a2,a3,0x20
    800045fc:	01e65693          	srli	a3,a2,0x1e
    80004600:	0023f617          	auipc	a2,0x23f
    80004604:	a1460613          	addi	a2,a2,-1516 # 80243014 <log+0x34>
    80004608:	96b2                	add	a3,a3,a2
  {
    hb->block[i] = log.lh.block[i];
    8000460a:	4390                	lw	a2,0(a5)
    8000460c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    8000460e:	0791                	addi	a5,a5,4
    80004610:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004612:	fed79ce3          	bne	a5,a3,8000460a <write_head+0x50>
  }
  bwrite(buf);
    80004616:	8526                	mv	a0,s1
    80004618:	fffff097          	auipc	ra,0xfffff
    8000461c:	096080e7          	jalr	150(ra) # 800036ae <bwrite>
  brelse(buf);
    80004620:	8526                	mv	a0,s1
    80004622:	fffff097          	auipc	ra,0xfffff
    80004626:	0ca080e7          	jalr	202(ra) # 800036ec <brelse>
}
    8000462a:	60e2                	ld	ra,24(sp)
    8000462c:	6442                	ld	s0,16(sp)
    8000462e:	64a2                	ld	s1,8(sp)
    80004630:	6902                	ld	s2,0(sp)
    80004632:	6105                	addi	sp,sp,32
    80004634:	8082                	ret

0000000080004636 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++)
    80004636:	0023f797          	auipc	a5,0x23f
    8000463a:	9d67a783          	lw	a5,-1578(a5) # 8024300c <log+0x2c>
    8000463e:	0af05d63          	blez	a5,800046f8 <install_trans+0xc2>
{
    80004642:	7139                	addi	sp,sp,-64
    80004644:	fc06                	sd	ra,56(sp)
    80004646:	f822                	sd	s0,48(sp)
    80004648:	f426                	sd	s1,40(sp)
    8000464a:	f04a                	sd	s2,32(sp)
    8000464c:	ec4e                	sd	s3,24(sp)
    8000464e:	e852                	sd	s4,16(sp)
    80004650:	e456                	sd	s5,8(sp)
    80004652:	e05a                	sd	s6,0(sp)
    80004654:	0080                	addi	s0,sp,64
    80004656:	8b2a                	mv	s6,a0
    80004658:	0023fa97          	auipc	s5,0x23f
    8000465c:	9b8a8a93          	addi	s5,s5,-1608 # 80243010 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++)
    80004660:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80004662:	0023f997          	auipc	s3,0x23f
    80004666:	97e98993          	addi	s3,s3,-1666 # 80242fe0 <log>
    8000466a:	a00d                	j	8000468c <install_trans+0x56>
    brelse(lbuf);
    8000466c:	854a                	mv	a0,s2
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	07e080e7          	jalr	126(ra) # 800036ec <brelse>
    brelse(dbuf);
    80004676:	8526                	mv	a0,s1
    80004678:	fffff097          	auipc	ra,0xfffff
    8000467c:	074080e7          	jalr	116(ra) # 800036ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    80004680:	2a05                	addiw	s4,s4,1
    80004682:	0a91                	addi	s5,s5,4
    80004684:	02c9a783          	lw	a5,44(s3)
    80004688:	04fa5e63          	bge	s4,a5,800046e4 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    8000468c:	0189a583          	lw	a1,24(s3)
    80004690:	014585bb          	addw	a1,a1,s4
    80004694:	2585                	addiw	a1,a1,1
    80004696:	0289a503          	lw	a0,40(s3)
    8000469a:	fffff097          	auipc	ra,0xfffff
    8000469e:	f22080e7          	jalr	-222(ra) # 800035bc <bread>
    800046a2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    800046a4:	000aa583          	lw	a1,0(s5)
    800046a8:	0289a503          	lw	a0,40(s3)
    800046ac:	fffff097          	auipc	ra,0xfffff
    800046b0:	f10080e7          	jalr	-240(ra) # 800035bc <bread>
    800046b4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);                  // copy block to dst
    800046b6:	40000613          	li	a2,1024
    800046ba:	05890593          	addi	a1,s2,88
    800046be:	05850513          	addi	a0,a0,88
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	7e0080e7          	jalr	2016(ra) # 80000ea2 <memmove>
    bwrite(dbuf);                                            // write dst to disk
    800046ca:	8526                	mv	a0,s1
    800046cc:	fffff097          	auipc	ra,0xfffff
    800046d0:	fe2080e7          	jalr	-30(ra) # 800036ae <bwrite>
    if (recovering == 0)
    800046d4:	f80b1ce3          	bnez	s6,8000466c <install_trans+0x36>
      bunpin(dbuf);
    800046d8:	8526                	mv	a0,s1
    800046da:	fffff097          	auipc	ra,0xfffff
    800046de:	0ec080e7          	jalr	236(ra) # 800037c6 <bunpin>
    800046e2:	b769                	j	8000466c <install_trans+0x36>
}
    800046e4:	70e2                	ld	ra,56(sp)
    800046e6:	7442                	ld	s0,48(sp)
    800046e8:	74a2                	ld	s1,40(sp)
    800046ea:	7902                	ld	s2,32(sp)
    800046ec:	69e2                	ld	s3,24(sp)
    800046ee:	6a42                	ld	s4,16(sp)
    800046f0:	6aa2                	ld	s5,8(sp)
    800046f2:	6b02                	ld	s6,0(sp)
    800046f4:	6121                	addi	sp,sp,64
    800046f6:	8082                	ret
    800046f8:	8082                	ret

00000000800046fa <initlog>:
{
    800046fa:	7179                	addi	sp,sp,-48
    800046fc:	f406                	sd	ra,40(sp)
    800046fe:	f022                	sd	s0,32(sp)
    80004700:	ec26                	sd	s1,24(sp)
    80004702:	e84a                	sd	s2,16(sp)
    80004704:	e44e                	sd	s3,8(sp)
    80004706:	1800                	addi	s0,sp,48
    80004708:	892a                	mv	s2,a0
    8000470a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000470c:	0023f497          	auipc	s1,0x23f
    80004710:	8d448493          	addi	s1,s1,-1836 # 80242fe0 <log>
    80004714:	00004597          	auipc	a1,0x4
    80004718:	0ac58593          	addi	a1,a1,172 # 800087c0 <syscalls+0x200>
    8000471c:	8526                	mv	a0,s1
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	59c080e7          	jalr	1436(ra) # 80000cba <initlock>
  log.start = sb->logstart;
    80004726:	0149a583          	lw	a1,20(s3)
    8000472a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000472c:	0109a783          	lw	a5,16(s3)
    80004730:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004732:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004736:	854a                	mv	a0,s2
    80004738:	fffff097          	auipc	ra,0xfffff
    8000473c:	e84080e7          	jalr	-380(ra) # 800035bc <bread>
  log.lh.n = lh->n;
    80004740:	4d34                	lw	a3,88(a0)
    80004742:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++)
    80004744:	02d05663          	blez	a3,80004770 <initlog+0x76>
    80004748:	05c50793          	addi	a5,a0,92
    8000474c:	0023f717          	auipc	a4,0x23f
    80004750:	8c470713          	addi	a4,a4,-1852 # 80243010 <log+0x30>
    80004754:	36fd                	addiw	a3,a3,-1
    80004756:	02069613          	slli	a2,a3,0x20
    8000475a:	01e65693          	srli	a3,a2,0x1e
    8000475e:	06050613          	addi	a2,a0,96
    80004762:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004764:	4390                	lw	a2,0(a5)
    80004766:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    80004768:	0791                	addi	a5,a5,4
    8000476a:	0711                	addi	a4,a4,4
    8000476c:	fed79ce3          	bne	a5,a3,80004764 <initlog+0x6a>
  brelse(buf);
    80004770:	fffff097          	auipc	ra,0xfffff
    80004774:	f7c080e7          	jalr	-132(ra) # 800036ec <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004778:	4505                	li	a0,1
    8000477a:	00000097          	auipc	ra,0x0
    8000477e:	ebc080e7          	jalr	-324(ra) # 80004636 <install_trans>
  log.lh.n = 0;
    80004782:	0023f797          	auipc	a5,0x23f
    80004786:	8807a523          	sw	zero,-1910(a5) # 8024300c <log+0x2c>
  write_head(); // clear the log
    8000478a:	00000097          	auipc	ra,0x0
    8000478e:	e30080e7          	jalr	-464(ra) # 800045ba <write_head>
}
    80004792:	70a2                	ld	ra,40(sp)
    80004794:	7402                	ld	s0,32(sp)
    80004796:	64e2                	ld	s1,24(sp)
    80004798:	6942                	ld	s2,16(sp)
    8000479a:	69a2                	ld	s3,8(sp)
    8000479c:	6145                	addi	sp,sp,48
    8000479e:	8082                	ret

00000000800047a0 <begin_op>:
}

// called at the start of each FS system call.
void begin_op(void)
{
    800047a0:	1101                	addi	sp,sp,-32
    800047a2:	ec06                	sd	ra,24(sp)
    800047a4:	e822                	sd	s0,16(sp)
    800047a6:	e426                	sd	s1,8(sp)
    800047a8:	e04a                	sd	s2,0(sp)
    800047aa:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800047ac:	0023f517          	auipc	a0,0x23f
    800047b0:	83450513          	addi	a0,a0,-1996 # 80242fe0 <log>
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	596080e7          	jalr	1430(ra) # 80000d4a <acquire>
  while (1)
  {
    if (log.committing)
    800047bc:	0023f497          	auipc	s1,0x23f
    800047c0:	82448493          	addi	s1,s1,-2012 # 80242fe0 <log>
    {
      sleep(&log, &log.lock);
    }
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    800047c4:	4979                	li	s2,30
    800047c6:	a039                	j	800047d4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800047c8:	85a6                	mv	a1,s1
    800047ca:	8526                	mv	a0,s1
    800047cc:	ffffe097          	auipc	ra,0xffffe
    800047d0:	b42080e7          	jalr	-1214(ra) # 8000230e <sleep>
    if (log.committing)
    800047d4:	50dc                	lw	a5,36(s1)
    800047d6:	fbed                	bnez	a5,800047c8 <begin_op+0x28>
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    800047d8:	5098                	lw	a4,32(s1)
    800047da:	2705                	addiw	a4,a4,1
    800047dc:	0007069b          	sext.w	a3,a4
    800047e0:	0027179b          	slliw	a5,a4,0x2
    800047e4:	9fb9                	addw	a5,a5,a4
    800047e6:	0017979b          	slliw	a5,a5,0x1
    800047ea:	54d8                	lw	a4,44(s1)
    800047ec:	9fb9                	addw	a5,a5,a4
    800047ee:	00f95963          	bge	s2,a5,80004800 <begin_op+0x60>
    {
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800047f2:	85a6                	mv	a1,s1
    800047f4:	8526                	mv	a0,s1
    800047f6:	ffffe097          	auipc	ra,0xffffe
    800047fa:	b18080e7          	jalr	-1256(ra) # 8000230e <sleep>
    800047fe:	bfd9                	j	800047d4 <begin_op+0x34>
    }
    else
    {
      log.outstanding += 1;
    80004800:	0023e517          	auipc	a0,0x23e
    80004804:	7e050513          	addi	a0,a0,2016 # 80242fe0 <log>
    80004808:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000480a:	ffffc097          	auipc	ra,0xffffc
    8000480e:	5f4080e7          	jalr	1524(ra) # 80000dfe <release>
      break;
    }
  }
}
    80004812:	60e2                	ld	ra,24(sp)
    80004814:	6442                	ld	s0,16(sp)
    80004816:	64a2                	ld	s1,8(sp)
    80004818:	6902                	ld	s2,0(sp)
    8000481a:	6105                	addi	sp,sp,32
    8000481c:	8082                	ret

000000008000481e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
    8000481e:	7139                	addi	sp,sp,-64
    80004820:	fc06                	sd	ra,56(sp)
    80004822:	f822                	sd	s0,48(sp)
    80004824:	f426                	sd	s1,40(sp)
    80004826:	f04a                	sd	s2,32(sp)
    80004828:	ec4e                	sd	s3,24(sp)
    8000482a:	e852                	sd	s4,16(sp)
    8000482c:	e456                	sd	s5,8(sp)
    8000482e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004830:	0023e497          	auipc	s1,0x23e
    80004834:	7b048493          	addi	s1,s1,1968 # 80242fe0 <log>
    80004838:	8526                	mv	a0,s1
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	510080e7          	jalr	1296(ra) # 80000d4a <acquire>
  log.outstanding -= 1;
    80004842:	509c                	lw	a5,32(s1)
    80004844:	37fd                	addiw	a5,a5,-1
    80004846:	0007891b          	sext.w	s2,a5
    8000484a:	d09c                	sw	a5,32(s1)
  if (log.committing)
    8000484c:	50dc                	lw	a5,36(s1)
    8000484e:	e7b9                	bnez	a5,8000489c <end_op+0x7e>
    panic("log.committing");
  if (log.outstanding == 0)
    80004850:	04091e63          	bnez	s2,800048ac <end_op+0x8e>
  {
    do_commit = 1;
    log.committing = 1;
    80004854:	0023e497          	auipc	s1,0x23e
    80004858:	78c48493          	addi	s1,s1,1932 # 80242fe0 <log>
    8000485c:	4785                	li	a5,1
    8000485e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004860:	8526                	mv	a0,s1
    80004862:	ffffc097          	auipc	ra,0xffffc
    80004866:	59c080e7          	jalr	1436(ra) # 80000dfe <release>
}

static void
commit()
{
  if (log.lh.n > 0)
    8000486a:	54dc                	lw	a5,44(s1)
    8000486c:	06f04763          	bgtz	a5,800048da <end_op+0xbc>
    acquire(&log.lock);
    80004870:	0023e497          	auipc	s1,0x23e
    80004874:	77048493          	addi	s1,s1,1904 # 80242fe0 <log>
    80004878:	8526                	mv	a0,s1
    8000487a:	ffffc097          	auipc	ra,0xffffc
    8000487e:	4d0080e7          	jalr	1232(ra) # 80000d4a <acquire>
    log.committing = 0;
    80004882:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004886:	8526                	mv	a0,s1
    80004888:	ffffe097          	auipc	ra,0xffffe
    8000488c:	c42080e7          	jalr	-958(ra) # 800024ca <wakeup>
    release(&log.lock);
    80004890:	8526                	mv	a0,s1
    80004892:	ffffc097          	auipc	ra,0xffffc
    80004896:	56c080e7          	jalr	1388(ra) # 80000dfe <release>
}
    8000489a:	a03d                	j	800048c8 <end_op+0xaa>
    panic("log.committing");
    8000489c:	00004517          	auipc	a0,0x4
    800048a0:	f2c50513          	addi	a0,a0,-212 # 800087c8 <syscalls+0x208>
    800048a4:	ffffc097          	auipc	ra,0xffffc
    800048a8:	c9c080e7          	jalr	-868(ra) # 80000540 <panic>
    wakeup(&log);
    800048ac:	0023e497          	auipc	s1,0x23e
    800048b0:	73448493          	addi	s1,s1,1844 # 80242fe0 <log>
    800048b4:	8526                	mv	a0,s1
    800048b6:	ffffe097          	auipc	ra,0xffffe
    800048ba:	c14080e7          	jalr	-1004(ra) # 800024ca <wakeup>
  release(&log.lock);
    800048be:	8526                	mv	a0,s1
    800048c0:	ffffc097          	auipc	ra,0xffffc
    800048c4:	53e080e7          	jalr	1342(ra) # 80000dfe <release>
}
    800048c8:	70e2                	ld	ra,56(sp)
    800048ca:	7442                	ld	s0,48(sp)
    800048cc:	74a2                	ld	s1,40(sp)
    800048ce:	7902                	ld	s2,32(sp)
    800048d0:	69e2                	ld	s3,24(sp)
    800048d2:	6a42                	ld	s4,16(sp)
    800048d4:	6aa2                	ld	s5,8(sp)
    800048d6:	6121                	addi	sp,sp,64
    800048d8:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++)
    800048da:	0023ea97          	auipc	s5,0x23e
    800048de:	736a8a93          	addi	s5,s5,1846 # 80243010 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    800048e2:	0023ea17          	auipc	s4,0x23e
    800048e6:	6fea0a13          	addi	s4,s4,1790 # 80242fe0 <log>
    800048ea:	018a2583          	lw	a1,24(s4)
    800048ee:	012585bb          	addw	a1,a1,s2
    800048f2:	2585                	addiw	a1,a1,1
    800048f4:	028a2503          	lw	a0,40(s4)
    800048f8:	fffff097          	auipc	ra,0xfffff
    800048fc:	cc4080e7          	jalr	-828(ra) # 800035bc <bread>
    80004900:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004902:	000aa583          	lw	a1,0(s5)
    80004906:	028a2503          	lw	a0,40(s4)
    8000490a:	fffff097          	auipc	ra,0xfffff
    8000490e:	cb2080e7          	jalr	-846(ra) # 800035bc <bread>
    80004912:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004914:	40000613          	li	a2,1024
    80004918:	05850593          	addi	a1,a0,88
    8000491c:	05848513          	addi	a0,s1,88
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	582080e7          	jalr	1410(ra) # 80000ea2 <memmove>
    bwrite(to); // write the log
    80004928:	8526                	mv	a0,s1
    8000492a:	fffff097          	auipc	ra,0xfffff
    8000492e:	d84080e7          	jalr	-636(ra) # 800036ae <bwrite>
    brelse(from);
    80004932:	854e                	mv	a0,s3
    80004934:	fffff097          	auipc	ra,0xfffff
    80004938:	db8080e7          	jalr	-584(ra) # 800036ec <brelse>
    brelse(to);
    8000493c:	8526                	mv	a0,s1
    8000493e:	fffff097          	auipc	ra,0xfffff
    80004942:	dae080e7          	jalr	-594(ra) # 800036ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    80004946:	2905                	addiw	s2,s2,1
    80004948:	0a91                	addi	s5,s5,4
    8000494a:	02ca2783          	lw	a5,44(s4)
    8000494e:	f8f94ee3          	blt	s2,a5,800048ea <end_op+0xcc>
  {
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80004952:	00000097          	auipc	ra,0x0
    80004956:	c68080e7          	jalr	-920(ra) # 800045ba <write_head>
    install_trans(0); // Now install writes to home locations
    8000495a:	4501                	li	a0,0
    8000495c:	00000097          	auipc	ra,0x0
    80004960:	cda080e7          	jalr	-806(ra) # 80004636 <install_trans>
    log.lh.n = 0;
    80004964:	0023e797          	auipc	a5,0x23e
    80004968:	6a07a423          	sw	zero,1704(a5) # 8024300c <log+0x2c>
    write_head(); // Erase the transaction from the log
    8000496c:	00000097          	auipc	ra,0x0
    80004970:	c4e080e7          	jalr	-946(ra) # 800045ba <write_head>
    80004974:	bdf5                	j	80004870 <end_op+0x52>

0000000080004976 <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
    80004976:	1101                	addi	sp,sp,-32
    80004978:	ec06                	sd	ra,24(sp)
    8000497a:	e822                	sd	s0,16(sp)
    8000497c:	e426                	sd	s1,8(sp)
    8000497e:	e04a                	sd	s2,0(sp)
    80004980:	1000                	addi	s0,sp,32
    80004982:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004984:	0023e917          	auipc	s2,0x23e
    80004988:	65c90913          	addi	s2,s2,1628 # 80242fe0 <log>
    8000498c:	854a                	mv	a0,s2
    8000498e:	ffffc097          	auipc	ra,0xffffc
    80004992:	3bc080e7          	jalr	956(ra) # 80000d4a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004996:	02c92603          	lw	a2,44(s2)
    8000499a:	47f5                	li	a5,29
    8000499c:	06c7c563          	blt	a5,a2,80004a06 <log_write+0x90>
    800049a0:	0023e797          	auipc	a5,0x23e
    800049a4:	65c7a783          	lw	a5,1628(a5) # 80242ffc <log+0x1c>
    800049a8:	37fd                	addiw	a5,a5,-1
    800049aa:	04f65e63          	bge	a2,a5,80004a06 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800049ae:	0023e797          	auipc	a5,0x23e
    800049b2:	6527a783          	lw	a5,1618(a5) # 80243000 <log+0x20>
    800049b6:	06f05063          	blez	a5,80004a16 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++)
    800049ba:	4781                	li	a5,0
    800049bc:	06c05563          	blez	a2,80004a26 <log_write+0xb0>
  {
    if (log.lh.block[i] == b->blockno) // log absorption
    800049c0:	44cc                	lw	a1,12(s1)
    800049c2:	0023e717          	auipc	a4,0x23e
    800049c6:	64e70713          	addi	a4,a4,1614 # 80243010 <log+0x30>
  for (i = 0; i < log.lh.n; i++)
    800049ca:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    800049cc:	4314                	lw	a3,0(a4)
    800049ce:	04b68c63          	beq	a3,a1,80004a26 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++)
    800049d2:	2785                	addiw	a5,a5,1
    800049d4:	0711                	addi	a4,a4,4
    800049d6:	fef61be3          	bne	a2,a5,800049cc <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800049da:	0621                	addi	a2,a2,8
    800049dc:	060a                	slli	a2,a2,0x2
    800049de:	0023e797          	auipc	a5,0x23e
    800049e2:	60278793          	addi	a5,a5,1538 # 80242fe0 <log>
    800049e6:	97b2                	add	a5,a5,a2
    800049e8:	44d8                	lw	a4,12(s1)
    800049ea:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n)
  { // Add new block to log?
    bpin(b);
    800049ec:	8526                	mv	a0,s1
    800049ee:	fffff097          	auipc	ra,0xfffff
    800049f2:	d9c080e7          	jalr	-612(ra) # 8000378a <bpin>
    log.lh.n++;
    800049f6:	0023e717          	auipc	a4,0x23e
    800049fa:	5ea70713          	addi	a4,a4,1514 # 80242fe0 <log>
    800049fe:	575c                	lw	a5,44(a4)
    80004a00:	2785                	addiw	a5,a5,1
    80004a02:	d75c                	sw	a5,44(a4)
    80004a04:	a82d                	j	80004a3e <log_write+0xc8>
    panic("too big a transaction");
    80004a06:	00004517          	auipc	a0,0x4
    80004a0a:	dd250513          	addi	a0,a0,-558 # 800087d8 <syscalls+0x218>
    80004a0e:	ffffc097          	auipc	ra,0xffffc
    80004a12:	b32080e7          	jalr	-1230(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004a16:	00004517          	auipc	a0,0x4
    80004a1a:	dda50513          	addi	a0,a0,-550 # 800087f0 <syscalls+0x230>
    80004a1e:	ffffc097          	auipc	ra,0xffffc
    80004a22:	b22080e7          	jalr	-1246(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004a26:	00878693          	addi	a3,a5,8
    80004a2a:	068a                	slli	a3,a3,0x2
    80004a2c:	0023e717          	auipc	a4,0x23e
    80004a30:	5b470713          	addi	a4,a4,1460 # 80242fe0 <log>
    80004a34:	9736                	add	a4,a4,a3
    80004a36:	44d4                	lw	a3,12(s1)
    80004a38:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n)
    80004a3a:	faf609e3          	beq	a2,a5,800049ec <log_write+0x76>
  }
  release(&log.lock);
    80004a3e:	0023e517          	auipc	a0,0x23e
    80004a42:	5a250513          	addi	a0,a0,1442 # 80242fe0 <log>
    80004a46:	ffffc097          	auipc	ra,0xffffc
    80004a4a:	3b8080e7          	jalr	952(ra) # 80000dfe <release>
}
    80004a4e:	60e2                	ld	ra,24(sp)
    80004a50:	6442                	ld	s0,16(sp)
    80004a52:	64a2                	ld	s1,8(sp)
    80004a54:	6902                	ld	s2,0(sp)
    80004a56:	6105                	addi	sp,sp,32
    80004a58:	8082                	ret

0000000080004a5a <initsleeplock>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock *lk, char *name)
{
    80004a5a:	1101                	addi	sp,sp,-32
    80004a5c:	ec06                	sd	ra,24(sp)
    80004a5e:	e822                	sd	s0,16(sp)
    80004a60:	e426                	sd	s1,8(sp)
    80004a62:	e04a                	sd	s2,0(sp)
    80004a64:	1000                	addi	s0,sp,32
    80004a66:	84aa                	mv	s1,a0
    80004a68:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a6a:	00004597          	auipc	a1,0x4
    80004a6e:	da658593          	addi	a1,a1,-602 # 80008810 <syscalls+0x250>
    80004a72:	0521                	addi	a0,a0,8
    80004a74:	ffffc097          	auipc	ra,0xffffc
    80004a78:	246080e7          	jalr	582(ra) # 80000cba <initlock>
  lk->name = name;
    80004a7c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a80:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a84:	0204a423          	sw	zero,40(s1)
}
    80004a88:	60e2                	ld	ra,24(sp)
    80004a8a:	6442                	ld	s0,16(sp)
    80004a8c:	64a2                	ld	s1,8(sp)
    80004a8e:	6902                	ld	s2,0(sp)
    80004a90:	6105                	addi	sp,sp,32
    80004a92:	8082                	ret

0000000080004a94 <acquiresleep>:

void acquiresleep(struct sleeplock *lk)
{
    80004a94:	1101                	addi	sp,sp,-32
    80004a96:	ec06                	sd	ra,24(sp)
    80004a98:	e822                	sd	s0,16(sp)
    80004a9a:	e426                	sd	s1,8(sp)
    80004a9c:	e04a                	sd	s2,0(sp)
    80004a9e:	1000                	addi	s0,sp,32
    80004aa0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004aa2:	00850913          	addi	s2,a0,8
    80004aa6:	854a                	mv	a0,s2
    80004aa8:	ffffc097          	auipc	ra,0xffffc
    80004aac:	2a2080e7          	jalr	674(ra) # 80000d4a <acquire>
  while (lk->locked)
    80004ab0:	409c                	lw	a5,0(s1)
    80004ab2:	cb89                	beqz	a5,80004ac4 <acquiresleep+0x30>
  {
    sleep(lk, &lk->lk);
    80004ab4:	85ca                	mv	a1,s2
    80004ab6:	8526                	mv	a0,s1
    80004ab8:	ffffe097          	auipc	ra,0xffffe
    80004abc:	856080e7          	jalr	-1962(ra) # 8000230e <sleep>
  while (lk->locked)
    80004ac0:	409c                	lw	a5,0(s1)
    80004ac2:	fbed                	bnez	a5,80004ab4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004ac4:	4785                	li	a5,1
    80004ac6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ac8:	ffffd097          	auipc	ra,0xffffd
    80004acc:	094080e7          	jalr	148(ra) # 80001b5c <myproc>
    80004ad0:	591c                	lw	a5,48(a0)
    80004ad2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ad4:	854a                	mv	a0,s2
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	328080e7          	jalr	808(ra) # 80000dfe <release>
}
    80004ade:	60e2                	ld	ra,24(sp)
    80004ae0:	6442                	ld	s0,16(sp)
    80004ae2:	64a2                	ld	s1,8(sp)
    80004ae4:	6902                	ld	s2,0(sp)
    80004ae6:	6105                	addi	sp,sp,32
    80004ae8:	8082                	ret

0000000080004aea <releasesleep>:

void releasesleep(struct sleeplock *lk)
{
    80004aea:	1101                	addi	sp,sp,-32
    80004aec:	ec06                	sd	ra,24(sp)
    80004aee:	e822                	sd	s0,16(sp)
    80004af0:	e426                	sd	s1,8(sp)
    80004af2:	e04a                	sd	s2,0(sp)
    80004af4:	1000                	addi	s0,sp,32
    80004af6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004af8:	00850913          	addi	s2,a0,8
    80004afc:	854a                	mv	a0,s2
    80004afe:	ffffc097          	auipc	ra,0xffffc
    80004b02:	24c080e7          	jalr	588(ra) # 80000d4a <acquire>
  lk->locked = 0;
    80004b06:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b0a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004b0e:	8526                	mv	a0,s1
    80004b10:	ffffe097          	auipc	ra,0xffffe
    80004b14:	9ba080e7          	jalr	-1606(ra) # 800024ca <wakeup>
  release(&lk->lk);
    80004b18:	854a                	mv	a0,s2
    80004b1a:	ffffc097          	auipc	ra,0xffffc
    80004b1e:	2e4080e7          	jalr	740(ra) # 80000dfe <release>
}
    80004b22:	60e2                	ld	ra,24(sp)
    80004b24:	6442                	ld	s0,16(sp)
    80004b26:	64a2                	ld	s1,8(sp)
    80004b28:	6902                	ld	s2,0(sp)
    80004b2a:	6105                	addi	sp,sp,32
    80004b2c:	8082                	ret

0000000080004b2e <holdingsleep>:

int holdingsleep(struct sleeplock *lk)
{
    80004b2e:	7179                	addi	sp,sp,-48
    80004b30:	f406                	sd	ra,40(sp)
    80004b32:	f022                	sd	s0,32(sp)
    80004b34:	ec26                	sd	s1,24(sp)
    80004b36:	e84a                	sd	s2,16(sp)
    80004b38:	e44e                	sd	s3,8(sp)
    80004b3a:	1800                	addi	s0,sp,48
    80004b3c:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004b3e:	00850913          	addi	s2,a0,8
    80004b42:	854a                	mv	a0,s2
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	206080e7          	jalr	518(ra) # 80000d4a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b4c:	409c                	lw	a5,0(s1)
    80004b4e:	ef99                	bnez	a5,80004b6c <holdingsleep+0x3e>
    80004b50:	4481                	li	s1,0
  release(&lk->lk);
    80004b52:	854a                	mv	a0,s2
    80004b54:	ffffc097          	auipc	ra,0xffffc
    80004b58:	2aa080e7          	jalr	682(ra) # 80000dfe <release>
  return r;
}
    80004b5c:	8526                	mv	a0,s1
    80004b5e:	70a2                	ld	ra,40(sp)
    80004b60:	7402                	ld	s0,32(sp)
    80004b62:	64e2                	ld	s1,24(sp)
    80004b64:	6942                	ld	s2,16(sp)
    80004b66:	69a2                	ld	s3,8(sp)
    80004b68:	6145                	addi	sp,sp,48
    80004b6a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b6c:	0284a983          	lw	s3,40(s1)
    80004b70:	ffffd097          	auipc	ra,0xffffd
    80004b74:	fec080e7          	jalr	-20(ra) # 80001b5c <myproc>
    80004b78:	5904                	lw	s1,48(a0)
    80004b7a:	413484b3          	sub	s1,s1,s3
    80004b7e:	0014b493          	seqz	s1,s1
    80004b82:	bfc1                	j	80004b52 <holdingsleep+0x24>

0000000080004b84 <fileinit>:
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void fileinit(void)
{
    80004b84:	1141                	addi	sp,sp,-16
    80004b86:	e406                	sd	ra,8(sp)
    80004b88:	e022                	sd	s0,0(sp)
    80004b8a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b8c:	00004597          	auipc	a1,0x4
    80004b90:	c9458593          	addi	a1,a1,-876 # 80008820 <syscalls+0x260>
    80004b94:	0023e517          	auipc	a0,0x23e
    80004b98:	59450513          	addi	a0,a0,1428 # 80243128 <ftable>
    80004b9c:	ffffc097          	auipc	ra,0xffffc
    80004ba0:	11e080e7          	jalr	286(ra) # 80000cba <initlock>
}
    80004ba4:	60a2                	ld	ra,8(sp)
    80004ba6:	6402                	ld	s0,0(sp)
    80004ba8:	0141                	addi	sp,sp,16
    80004baa:	8082                	ret

0000000080004bac <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004bac:	1101                	addi	sp,sp,-32
    80004bae:	ec06                	sd	ra,24(sp)
    80004bb0:	e822                	sd	s0,16(sp)
    80004bb2:	e426                	sd	s1,8(sp)
    80004bb4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004bb6:	0023e517          	auipc	a0,0x23e
    80004bba:	57250513          	addi	a0,a0,1394 # 80243128 <ftable>
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	18c080e7          	jalr	396(ra) # 80000d4a <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004bc6:	0023e497          	auipc	s1,0x23e
    80004bca:	57a48493          	addi	s1,s1,1402 # 80243140 <ftable+0x18>
    80004bce:	0023f717          	auipc	a4,0x23f
    80004bd2:	51270713          	addi	a4,a4,1298 # 802440e0 <mt>
  {
    if (f->ref == 0)
    80004bd6:	40dc                	lw	a5,4(s1)
    80004bd8:	cf99                	beqz	a5,80004bf6 <filealloc+0x4a>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004bda:	02848493          	addi	s1,s1,40
    80004bde:	fee49ce3          	bne	s1,a4,80004bd6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004be2:	0023e517          	auipc	a0,0x23e
    80004be6:	54650513          	addi	a0,a0,1350 # 80243128 <ftable>
    80004bea:	ffffc097          	auipc	ra,0xffffc
    80004bee:	214080e7          	jalr	532(ra) # 80000dfe <release>
  return 0;
    80004bf2:	4481                	li	s1,0
    80004bf4:	a819                	j	80004c0a <filealloc+0x5e>
      f->ref = 1;
    80004bf6:	4785                	li	a5,1
    80004bf8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004bfa:	0023e517          	auipc	a0,0x23e
    80004bfe:	52e50513          	addi	a0,a0,1326 # 80243128 <ftable>
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	1fc080e7          	jalr	508(ra) # 80000dfe <release>
}
    80004c0a:	8526                	mv	a0,s1
    80004c0c:	60e2                	ld	ra,24(sp)
    80004c0e:	6442                	ld	s0,16(sp)
    80004c10:	64a2                	ld	s1,8(sp)
    80004c12:	6105                	addi	sp,sp,32
    80004c14:	8082                	ret

0000000080004c16 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004c16:	1101                	addi	sp,sp,-32
    80004c18:	ec06                	sd	ra,24(sp)
    80004c1a:	e822                	sd	s0,16(sp)
    80004c1c:	e426                	sd	s1,8(sp)
    80004c1e:	1000                	addi	s0,sp,32
    80004c20:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c22:	0023e517          	auipc	a0,0x23e
    80004c26:	50650513          	addi	a0,a0,1286 # 80243128 <ftable>
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	120080e7          	jalr	288(ra) # 80000d4a <acquire>
  if (f->ref < 1)
    80004c32:	40dc                	lw	a5,4(s1)
    80004c34:	02f05263          	blez	a5,80004c58 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004c38:	2785                	addiw	a5,a5,1
    80004c3a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c3c:	0023e517          	auipc	a0,0x23e
    80004c40:	4ec50513          	addi	a0,a0,1260 # 80243128 <ftable>
    80004c44:	ffffc097          	auipc	ra,0xffffc
    80004c48:	1ba080e7          	jalr	442(ra) # 80000dfe <release>
  return f;
}
    80004c4c:	8526                	mv	a0,s1
    80004c4e:	60e2                	ld	ra,24(sp)
    80004c50:	6442                	ld	s0,16(sp)
    80004c52:	64a2                	ld	s1,8(sp)
    80004c54:	6105                	addi	sp,sp,32
    80004c56:	8082                	ret
    panic("filedup");
    80004c58:	00004517          	auipc	a0,0x4
    80004c5c:	bd050513          	addi	a0,a0,-1072 # 80008828 <syscalls+0x268>
    80004c60:	ffffc097          	auipc	ra,0xffffc
    80004c64:	8e0080e7          	jalr	-1824(ra) # 80000540 <panic>

0000000080004c68 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    80004c68:	7139                	addi	sp,sp,-64
    80004c6a:	fc06                	sd	ra,56(sp)
    80004c6c:	f822                	sd	s0,48(sp)
    80004c6e:	f426                	sd	s1,40(sp)
    80004c70:	f04a                	sd	s2,32(sp)
    80004c72:	ec4e                	sd	s3,24(sp)
    80004c74:	e852                	sd	s4,16(sp)
    80004c76:	e456                	sd	s5,8(sp)
    80004c78:	0080                	addi	s0,sp,64
    80004c7a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c7c:	0023e517          	auipc	a0,0x23e
    80004c80:	4ac50513          	addi	a0,a0,1196 # 80243128 <ftable>
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	0c6080e7          	jalr	198(ra) # 80000d4a <acquire>
  if (f->ref < 1)
    80004c8c:	40dc                	lw	a5,4(s1)
    80004c8e:	06f05163          	blez	a5,80004cf0 <fileclose+0x88>
    panic("fileclose");
  if (--f->ref > 0)
    80004c92:	37fd                	addiw	a5,a5,-1
    80004c94:	0007871b          	sext.w	a4,a5
    80004c98:	c0dc                	sw	a5,4(s1)
    80004c9a:	06e04363          	bgtz	a4,80004d00 <fileclose+0x98>
  {
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c9e:	0004a903          	lw	s2,0(s1)
    80004ca2:	0094ca83          	lbu	s5,9(s1)
    80004ca6:	0104ba03          	ld	s4,16(s1)
    80004caa:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004cae:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004cb2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004cb6:	0023e517          	auipc	a0,0x23e
    80004cba:	47250513          	addi	a0,a0,1138 # 80243128 <ftable>
    80004cbe:	ffffc097          	auipc	ra,0xffffc
    80004cc2:	140080e7          	jalr	320(ra) # 80000dfe <release>

  if (ff.type == FD_PIPE)
    80004cc6:	4785                	li	a5,1
    80004cc8:	04f90d63          	beq	s2,a5,80004d22 <fileclose+0xba>
  {
    pipeclose(ff.pipe, ff.writable);
  }
  else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    80004ccc:	3979                	addiw	s2,s2,-2
    80004cce:	4785                	li	a5,1
    80004cd0:	0527e063          	bltu	a5,s2,80004d10 <fileclose+0xa8>
  {
    begin_op();
    80004cd4:	00000097          	auipc	ra,0x0
    80004cd8:	acc080e7          	jalr	-1332(ra) # 800047a0 <begin_op>
    iput(ff.ip);
    80004cdc:	854e                	mv	a0,s3
    80004cde:	fffff097          	auipc	ra,0xfffff
    80004ce2:	2b0080e7          	jalr	688(ra) # 80003f8e <iput>
    end_op();
    80004ce6:	00000097          	auipc	ra,0x0
    80004cea:	b38080e7          	jalr	-1224(ra) # 8000481e <end_op>
    80004cee:	a00d                	j	80004d10 <fileclose+0xa8>
    panic("fileclose");
    80004cf0:	00004517          	auipc	a0,0x4
    80004cf4:	b4050513          	addi	a0,a0,-1216 # 80008830 <syscalls+0x270>
    80004cf8:	ffffc097          	auipc	ra,0xffffc
    80004cfc:	848080e7          	jalr	-1976(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004d00:	0023e517          	auipc	a0,0x23e
    80004d04:	42850513          	addi	a0,a0,1064 # 80243128 <ftable>
    80004d08:	ffffc097          	auipc	ra,0xffffc
    80004d0c:	0f6080e7          	jalr	246(ra) # 80000dfe <release>
  }
}
    80004d10:	70e2                	ld	ra,56(sp)
    80004d12:	7442                	ld	s0,48(sp)
    80004d14:	74a2                	ld	s1,40(sp)
    80004d16:	7902                	ld	s2,32(sp)
    80004d18:	69e2                	ld	s3,24(sp)
    80004d1a:	6a42                	ld	s4,16(sp)
    80004d1c:	6aa2                	ld	s5,8(sp)
    80004d1e:	6121                	addi	sp,sp,64
    80004d20:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d22:	85d6                	mv	a1,s5
    80004d24:	8552                	mv	a0,s4
    80004d26:	00000097          	auipc	ra,0x0
    80004d2a:	34c080e7          	jalr	844(ra) # 80005072 <pipeclose>
    80004d2e:	b7cd                	j	80004d10 <fileclose+0xa8>

0000000080004d30 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80004d30:	715d                	addi	sp,sp,-80
    80004d32:	e486                	sd	ra,72(sp)
    80004d34:	e0a2                	sd	s0,64(sp)
    80004d36:	fc26                	sd	s1,56(sp)
    80004d38:	f84a                	sd	s2,48(sp)
    80004d3a:	f44e                	sd	s3,40(sp)
    80004d3c:	0880                	addi	s0,sp,80
    80004d3e:	84aa                	mv	s1,a0
    80004d40:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d42:	ffffd097          	auipc	ra,0xffffd
    80004d46:	e1a080e7          	jalr	-486(ra) # 80001b5c <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004d4a:	409c                	lw	a5,0(s1)
    80004d4c:	37f9                	addiw	a5,a5,-2
    80004d4e:	4705                	li	a4,1
    80004d50:	04f76763          	bltu	a4,a5,80004d9e <filestat+0x6e>
    80004d54:	892a                	mv	s2,a0
  {
    ilock(f->ip);
    80004d56:	6c88                	ld	a0,24(s1)
    80004d58:	fffff097          	auipc	ra,0xfffff
    80004d5c:	07c080e7          	jalr	124(ra) # 80003dd4 <ilock>
    stati(f->ip, &st);
    80004d60:	fb840593          	addi	a1,s0,-72
    80004d64:	6c88                	ld	a0,24(s1)
    80004d66:	fffff097          	auipc	ra,0xfffff
    80004d6a:	2f8080e7          	jalr	760(ra) # 8000405e <stati>
    iunlock(f->ip);
    80004d6e:	6c88                	ld	a0,24(s1)
    80004d70:	fffff097          	auipc	ra,0xfffff
    80004d74:	126080e7          	jalr	294(ra) # 80003e96 <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d78:	46e1                	li	a3,24
    80004d7a:	fb840613          	addi	a2,s0,-72
    80004d7e:	85ce                	mv	a1,s3
    80004d80:	05093503          	ld	a0,80(s2)
    80004d84:	ffffd097          	auipc	ra,0xffffd
    80004d88:	a5c080e7          	jalr	-1444(ra) # 800017e0 <copyout>
    80004d8c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d90:	60a6                	ld	ra,72(sp)
    80004d92:	6406                	ld	s0,64(sp)
    80004d94:	74e2                	ld	s1,56(sp)
    80004d96:	7942                	ld	s2,48(sp)
    80004d98:	79a2                	ld	s3,40(sp)
    80004d9a:	6161                	addi	sp,sp,80
    80004d9c:	8082                	ret
  return -1;
    80004d9e:	557d                	li	a0,-1
    80004da0:	bfc5                	j	80004d90 <filestat+0x60>

0000000080004da2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    80004da2:	7179                	addi	sp,sp,-48
    80004da4:	f406                	sd	ra,40(sp)
    80004da6:	f022                	sd	s0,32(sp)
    80004da8:	ec26                	sd	s1,24(sp)
    80004daa:	e84a                	sd	s2,16(sp)
    80004dac:	e44e                	sd	s3,8(sp)
    80004dae:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    80004db0:	00854783          	lbu	a5,8(a0)
    80004db4:	c3d5                	beqz	a5,80004e58 <fileread+0xb6>
    80004db6:	84aa                	mv	s1,a0
    80004db8:	89ae                	mv	s3,a1
    80004dba:	8932                	mv	s2,a2
    return -1;

  if (f->type == FD_PIPE)
    80004dbc:	411c                	lw	a5,0(a0)
    80004dbe:	4705                	li	a4,1
    80004dc0:	04e78963          	beq	a5,a4,80004e12 <fileread+0x70>
  {
    r = piperead(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004dc4:	470d                	li	a4,3
    80004dc6:	04e78d63          	beq	a5,a4,80004e20 <fileread+0x7e>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004dca:	4709                	li	a4,2
    80004dcc:	06e79e63          	bne	a5,a4,80004e48 <fileread+0xa6>
  {
    ilock(f->ip);
    80004dd0:	6d08                	ld	a0,24(a0)
    80004dd2:	fffff097          	auipc	ra,0xfffff
    80004dd6:	002080e7          	jalr	2(ra) # 80003dd4 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004dda:	874a                	mv	a4,s2
    80004ddc:	5094                	lw	a3,32(s1)
    80004dde:	864e                	mv	a2,s3
    80004de0:	4585                	li	a1,1
    80004de2:	6c88                	ld	a0,24(s1)
    80004de4:	fffff097          	auipc	ra,0xfffff
    80004de8:	2a4080e7          	jalr	676(ra) # 80004088 <readi>
    80004dec:	892a                	mv	s2,a0
    80004dee:	00a05563          	blez	a0,80004df8 <fileread+0x56>
      f->off += r;
    80004df2:	509c                	lw	a5,32(s1)
    80004df4:	9fa9                	addw	a5,a5,a0
    80004df6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004df8:	6c88                	ld	a0,24(s1)
    80004dfa:	fffff097          	auipc	ra,0xfffff
    80004dfe:	09c080e7          	jalr	156(ra) # 80003e96 <iunlock>
  {
    panic("fileread");
  }

  return r;
}
    80004e02:	854a                	mv	a0,s2
    80004e04:	70a2                	ld	ra,40(sp)
    80004e06:	7402                	ld	s0,32(sp)
    80004e08:	64e2                	ld	s1,24(sp)
    80004e0a:	6942                	ld	s2,16(sp)
    80004e0c:	69a2                	ld	s3,8(sp)
    80004e0e:	6145                	addi	sp,sp,48
    80004e10:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e12:	6908                	ld	a0,16(a0)
    80004e14:	00000097          	auipc	ra,0x0
    80004e18:	3c6080e7          	jalr	966(ra) # 800051da <piperead>
    80004e1c:	892a                	mv	s2,a0
    80004e1e:	b7d5                	j	80004e02 <fileread+0x60>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e20:	02451783          	lh	a5,36(a0)
    80004e24:	03079693          	slli	a3,a5,0x30
    80004e28:	92c1                	srli	a3,a3,0x30
    80004e2a:	4725                	li	a4,9
    80004e2c:	02d76863          	bltu	a4,a3,80004e5c <fileread+0xba>
    80004e30:	0792                	slli	a5,a5,0x4
    80004e32:	0023e717          	auipc	a4,0x23e
    80004e36:	25670713          	addi	a4,a4,598 # 80243088 <devsw>
    80004e3a:	97ba                	add	a5,a5,a4
    80004e3c:	639c                	ld	a5,0(a5)
    80004e3e:	c38d                	beqz	a5,80004e60 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004e40:	4505                	li	a0,1
    80004e42:	9782                	jalr	a5
    80004e44:	892a                	mv	s2,a0
    80004e46:	bf75                	j	80004e02 <fileread+0x60>
    panic("fileread");
    80004e48:	00004517          	auipc	a0,0x4
    80004e4c:	9f850513          	addi	a0,a0,-1544 # 80008840 <syscalls+0x280>
    80004e50:	ffffb097          	auipc	ra,0xffffb
    80004e54:	6f0080e7          	jalr	1776(ra) # 80000540 <panic>
    return -1;
    80004e58:	597d                	li	s2,-1
    80004e5a:	b765                	j	80004e02 <fileread+0x60>
      return -1;
    80004e5c:	597d                	li	s2,-1
    80004e5e:	b755                	j	80004e02 <fileread+0x60>
    80004e60:	597d                	li	s2,-1
    80004e62:	b745                	j	80004e02 <fileread+0x60>

0000000080004e64 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    80004e64:	715d                	addi	sp,sp,-80
    80004e66:	e486                	sd	ra,72(sp)
    80004e68:	e0a2                	sd	s0,64(sp)
    80004e6a:	fc26                	sd	s1,56(sp)
    80004e6c:	f84a                	sd	s2,48(sp)
    80004e6e:	f44e                	sd	s3,40(sp)
    80004e70:	f052                	sd	s4,32(sp)
    80004e72:	ec56                	sd	s5,24(sp)
    80004e74:	e85a                	sd	s6,16(sp)
    80004e76:	e45e                	sd	s7,8(sp)
    80004e78:	e062                	sd	s8,0(sp)
    80004e7a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if (f->writable == 0)
    80004e7c:	00954783          	lbu	a5,9(a0)
    80004e80:	10078663          	beqz	a5,80004f8c <filewrite+0x128>
    80004e84:	892a                	mv	s2,a0
    80004e86:	8b2e                	mv	s6,a1
    80004e88:	8a32                	mv	s4,a2
    return -1;

  if (f->type == FD_PIPE)
    80004e8a:	411c                	lw	a5,0(a0)
    80004e8c:	4705                	li	a4,1
    80004e8e:	02e78263          	beq	a5,a4,80004eb2 <filewrite+0x4e>
  {
    ret = pipewrite(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004e92:	470d                	li	a4,3
    80004e94:	02e78663          	beq	a5,a4,80004ec0 <filewrite+0x5c>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004e98:	4709                	li	a4,2
    80004e9a:	0ee79163          	bne	a5,a4,80004f7c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n)
    80004e9e:	0ac05d63          	blez	a2,80004f58 <filewrite+0xf4>
    int i = 0;
    80004ea2:	4981                	li	s3,0
    80004ea4:	6b85                	lui	s7,0x1
    80004ea6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004eaa:	6c05                	lui	s8,0x1
    80004eac:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004eb0:	a861                	j	80004f48 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004eb2:	6908                	ld	a0,16(a0)
    80004eb4:	00000097          	auipc	ra,0x0
    80004eb8:	22e080e7          	jalr	558(ra) # 800050e2 <pipewrite>
    80004ebc:	8a2a                	mv	s4,a0
    80004ebe:	a045                	j	80004f5e <filewrite+0xfa>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ec0:	02451783          	lh	a5,36(a0)
    80004ec4:	03079693          	slli	a3,a5,0x30
    80004ec8:	92c1                	srli	a3,a3,0x30
    80004eca:	4725                	li	a4,9
    80004ecc:	0cd76263          	bltu	a4,a3,80004f90 <filewrite+0x12c>
    80004ed0:	0792                	slli	a5,a5,0x4
    80004ed2:	0023e717          	auipc	a4,0x23e
    80004ed6:	1b670713          	addi	a4,a4,438 # 80243088 <devsw>
    80004eda:	97ba                	add	a5,a5,a4
    80004edc:	679c                	ld	a5,8(a5)
    80004ede:	cbdd                	beqz	a5,80004f94 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ee0:	4505                	li	a0,1
    80004ee2:	9782                	jalr	a5
    80004ee4:	8a2a                	mv	s4,a0
    80004ee6:	a8a5                	j	80004f5e <filewrite+0xfa>
    80004ee8:	00048a9b          	sext.w	s5,s1
    {
      int n1 = n - i;
      if (n1 > max)
        n1 = max;

      begin_op();
    80004eec:	00000097          	auipc	ra,0x0
    80004ef0:	8b4080e7          	jalr	-1868(ra) # 800047a0 <begin_op>
      ilock(f->ip);
    80004ef4:	01893503          	ld	a0,24(s2)
    80004ef8:	fffff097          	auipc	ra,0xfffff
    80004efc:	edc080e7          	jalr	-292(ra) # 80003dd4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004f00:	8756                	mv	a4,s5
    80004f02:	02092683          	lw	a3,32(s2)
    80004f06:	01698633          	add	a2,s3,s6
    80004f0a:	4585                	li	a1,1
    80004f0c:	01893503          	ld	a0,24(s2)
    80004f10:	fffff097          	auipc	ra,0xfffff
    80004f14:	270080e7          	jalr	624(ra) # 80004180 <writei>
    80004f18:	84aa                	mv	s1,a0
    80004f1a:	00a05763          	blez	a0,80004f28 <filewrite+0xc4>
        f->off += r;
    80004f1e:	02092783          	lw	a5,32(s2)
    80004f22:	9fa9                	addw	a5,a5,a0
    80004f24:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f28:	01893503          	ld	a0,24(s2)
    80004f2c:	fffff097          	auipc	ra,0xfffff
    80004f30:	f6a080e7          	jalr	-150(ra) # 80003e96 <iunlock>
      end_op();
    80004f34:	00000097          	auipc	ra,0x0
    80004f38:	8ea080e7          	jalr	-1814(ra) # 8000481e <end_op>

      if (r != n1)
    80004f3c:	009a9f63          	bne	s5,s1,80004f5a <filewrite+0xf6>
      {
        // error from writei
        break;
      }
      i += r;
    80004f40:	013489bb          	addw	s3,s1,s3
    while (i < n)
    80004f44:	0149db63          	bge	s3,s4,80004f5a <filewrite+0xf6>
      int n1 = n - i;
    80004f48:	413a04bb          	subw	s1,s4,s3
    80004f4c:	0004879b          	sext.w	a5,s1
    80004f50:	f8fbdce3          	bge	s7,a5,80004ee8 <filewrite+0x84>
    80004f54:	84e2                	mv	s1,s8
    80004f56:	bf49                	j	80004ee8 <filewrite+0x84>
    int i = 0;
    80004f58:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f5a:	013a1f63          	bne	s4,s3,80004f78 <filewrite+0x114>
  {
    panic("filewrite");
  }

  return ret;
}
    80004f5e:	8552                	mv	a0,s4
    80004f60:	60a6                	ld	ra,72(sp)
    80004f62:	6406                	ld	s0,64(sp)
    80004f64:	74e2                	ld	s1,56(sp)
    80004f66:	7942                	ld	s2,48(sp)
    80004f68:	79a2                	ld	s3,40(sp)
    80004f6a:	7a02                	ld	s4,32(sp)
    80004f6c:	6ae2                	ld	s5,24(sp)
    80004f6e:	6b42                	ld	s6,16(sp)
    80004f70:	6ba2                	ld	s7,8(sp)
    80004f72:	6c02                	ld	s8,0(sp)
    80004f74:	6161                	addi	sp,sp,80
    80004f76:	8082                	ret
    ret = (i == n ? n : -1);
    80004f78:	5a7d                	li	s4,-1
    80004f7a:	b7d5                	j	80004f5e <filewrite+0xfa>
    panic("filewrite");
    80004f7c:	00004517          	auipc	a0,0x4
    80004f80:	8d450513          	addi	a0,a0,-1836 # 80008850 <syscalls+0x290>
    80004f84:	ffffb097          	auipc	ra,0xffffb
    80004f88:	5bc080e7          	jalr	1468(ra) # 80000540 <panic>
    return -1;
    80004f8c:	5a7d                	li	s4,-1
    80004f8e:	bfc1                	j	80004f5e <filewrite+0xfa>
      return -1;
    80004f90:	5a7d                	li	s4,-1
    80004f92:	b7f1                	j	80004f5e <filewrite+0xfa>
    80004f94:	5a7d                	li	s4,-1
    80004f96:	b7e1                	j	80004f5e <filewrite+0xfa>

0000000080004f98 <pipealloc>:
  int readopen;  // read fd is still open
  int writeopen; // write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
    80004f98:	7179                	addi	sp,sp,-48
    80004f9a:	f406                	sd	ra,40(sp)
    80004f9c:	f022                	sd	s0,32(sp)
    80004f9e:	ec26                	sd	s1,24(sp)
    80004fa0:	e84a                	sd	s2,16(sp)
    80004fa2:	e44e                	sd	s3,8(sp)
    80004fa4:	e052                	sd	s4,0(sp)
    80004fa6:	1800                	addi	s0,sp,48
    80004fa8:	84aa                	mv	s1,a0
    80004faa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004fac:	0005b023          	sd	zero,0(a1)
    80004fb0:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004fb4:	00000097          	auipc	ra,0x0
    80004fb8:	bf8080e7          	jalr	-1032(ra) # 80004bac <filealloc>
    80004fbc:	e088                	sd	a0,0(s1)
    80004fbe:	c551                	beqz	a0,8000504a <pipealloc+0xb2>
    80004fc0:	00000097          	auipc	ra,0x0
    80004fc4:	bec080e7          	jalr	-1044(ra) # 80004bac <filealloc>
    80004fc8:	00aa3023          	sd	a0,0(s4)
    80004fcc:	c92d                	beqz	a0,8000503e <pipealloc+0xa6>
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004fce:	ffffc097          	auipc	ra,0xffffc
    80004fd2:	c82080e7          	jalr	-894(ra) # 80000c50 <kalloc>
    80004fd6:	892a                	mv	s2,a0
    80004fd8:	c125                	beqz	a0,80005038 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004fda:	4985                	li	s3,1
    80004fdc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004fe0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004fe4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004fe8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004fec:	00003597          	auipc	a1,0x3
    80004ff0:	4fc58593          	addi	a1,a1,1276 # 800084e8 <states.0+0x1c0>
    80004ff4:	ffffc097          	auipc	ra,0xffffc
    80004ff8:	cc6080e7          	jalr	-826(ra) # 80000cba <initlock>
  (*f0)->type = FD_PIPE;
    80004ffc:	609c                	ld	a5,0(s1)
    80004ffe:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005002:	609c                	ld	a5,0(s1)
    80005004:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005008:	609c                	ld	a5,0(s1)
    8000500a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000500e:	609c                	ld	a5,0(s1)
    80005010:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005014:	000a3783          	ld	a5,0(s4)
    80005018:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000501c:	000a3783          	ld	a5,0(s4)
    80005020:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005024:	000a3783          	ld	a5,0(s4)
    80005028:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000502c:	000a3783          	ld	a5,0(s4)
    80005030:	0127b823          	sd	s2,16(a5)
  return 0;
    80005034:	4501                	li	a0,0
    80005036:	a025                	j	8000505e <pipealloc+0xc6>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80005038:	6088                	ld	a0,0(s1)
    8000503a:	e501                	bnez	a0,80005042 <pipealloc+0xaa>
    8000503c:	a039                	j	8000504a <pipealloc+0xb2>
    8000503e:	6088                	ld	a0,0(s1)
    80005040:	c51d                	beqz	a0,8000506e <pipealloc+0xd6>
    fileclose(*f0);
    80005042:	00000097          	auipc	ra,0x0
    80005046:	c26080e7          	jalr	-986(ra) # 80004c68 <fileclose>
  if (*f1)
    8000504a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000504e:	557d                	li	a0,-1
  if (*f1)
    80005050:	c799                	beqz	a5,8000505e <pipealloc+0xc6>
    fileclose(*f1);
    80005052:	853e                	mv	a0,a5
    80005054:	00000097          	auipc	ra,0x0
    80005058:	c14080e7          	jalr	-1004(ra) # 80004c68 <fileclose>
  return -1;
    8000505c:	557d                	li	a0,-1
}
    8000505e:	70a2                	ld	ra,40(sp)
    80005060:	7402                	ld	s0,32(sp)
    80005062:	64e2                	ld	s1,24(sp)
    80005064:	6942                	ld	s2,16(sp)
    80005066:	69a2                	ld	s3,8(sp)
    80005068:	6a02                	ld	s4,0(sp)
    8000506a:	6145                	addi	sp,sp,48
    8000506c:	8082                	ret
  return -1;
    8000506e:	557d                	li	a0,-1
    80005070:	b7fd                	j	8000505e <pipealloc+0xc6>

0000000080005072 <pipeclose>:

void pipeclose(struct pipe *pi, int writable)
{
    80005072:	1101                	addi	sp,sp,-32
    80005074:	ec06                	sd	ra,24(sp)
    80005076:	e822                	sd	s0,16(sp)
    80005078:	e426                	sd	s1,8(sp)
    8000507a:	e04a                	sd	s2,0(sp)
    8000507c:	1000                	addi	s0,sp,32
    8000507e:	84aa                	mv	s1,a0
    80005080:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005082:	ffffc097          	auipc	ra,0xffffc
    80005086:	cc8080e7          	jalr	-824(ra) # 80000d4a <acquire>
  if (writable)
    8000508a:	02090d63          	beqz	s2,800050c4 <pipeclose+0x52>
  {
    pi->writeopen = 0;
    8000508e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005092:	21848513          	addi	a0,s1,536
    80005096:	ffffd097          	auipc	ra,0xffffd
    8000509a:	434080e7          	jalr	1076(ra) # 800024ca <wakeup>
  else
  {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0)
    8000509e:	2204b783          	ld	a5,544(s1)
    800050a2:	eb95                	bnez	a5,800050d6 <pipeclose+0x64>
  {
    release(&pi->lock);
    800050a4:	8526                	mv	a0,s1
    800050a6:	ffffc097          	auipc	ra,0xffffc
    800050aa:	d58080e7          	jalr	-680(ra) # 80000dfe <release>
    kfree((char *)pi);
    800050ae:	8526                	mv	a0,s1
    800050b0:	ffffc097          	auipc	ra,0xffffc
    800050b4:	9c8080e7          	jalr	-1592(ra) # 80000a78 <kfree>
  }
  else
    release(&pi->lock);
}
    800050b8:	60e2                	ld	ra,24(sp)
    800050ba:	6442                	ld	s0,16(sp)
    800050bc:	64a2                	ld	s1,8(sp)
    800050be:	6902                	ld	s2,0(sp)
    800050c0:	6105                	addi	sp,sp,32
    800050c2:	8082                	ret
    pi->readopen = 0;
    800050c4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800050c8:	21c48513          	addi	a0,s1,540
    800050cc:	ffffd097          	auipc	ra,0xffffd
    800050d0:	3fe080e7          	jalr	1022(ra) # 800024ca <wakeup>
    800050d4:	b7e9                	j	8000509e <pipeclose+0x2c>
    release(&pi->lock);
    800050d6:	8526                	mv	a0,s1
    800050d8:	ffffc097          	auipc	ra,0xffffc
    800050dc:	d26080e7          	jalr	-730(ra) # 80000dfe <release>
}
    800050e0:	bfe1                	j	800050b8 <pipeclose+0x46>

00000000800050e2 <pipewrite>:

int pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800050e2:	711d                	addi	sp,sp,-96
    800050e4:	ec86                	sd	ra,88(sp)
    800050e6:	e8a2                	sd	s0,80(sp)
    800050e8:	e4a6                	sd	s1,72(sp)
    800050ea:	e0ca                	sd	s2,64(sp)
    800050ec:	fc4e                	sd	s3,56(sp)
    800050ee:	f852                	sd	s4,48(sp)
    800050f0:	f456                	sd	s5,40(sp)
    800050f2:	f05a                	sd	s6,32(sp)
    800050f4:	ec5e                	sd	s7,24(sp)
    800050f6:	e862                	sd	s8,16(sp)
    800050f8:	1080                	addi	s0,sp,96
    800050fa:	84aa                	mv	s1,a0
    800050fc:	8aae                	mv	s5,a1
    800050fe:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005100:	ffffd097          	auipc	ra,0xffffd
    80005104:	a5c080e7          	jalr	-1444(ra) # 80001b5c <myproc>
    80005108:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000510a:	8526                	mv	a0,s1
    8000510c:	ffffc097          	auipc	ra,0xffffc
    80005110:	c3e080e7          	jalr	-962(ra) # 80000d4a <acquire>
  while (i < n)
    80005114:	0b405663          	blez	s4,800051c0 <pipewrite+0xde>
  int i = 0;
    80005118:	4901                	li	s2,0
      sleep(&pi->nwrite, &pi->lock);
    }
    else
    {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000511a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000511c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005120:	21c48b93          	addi	s7,s1,540
    80005124:	a089                	j	80005166 <pipewrite+0x84>
      release(&pi->lock);
    80005126:	8526                	mv	a0,s1
    80005128:	ffffc097          	auipc	ra,0xffffc
    8000512c:	cd6080e7          	jalr	-810(ra) # 80000dfe <release>
      return -1;
    80005130:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005132:	854a                	mv	a0,s2
    80005134:	60e6                	ld	ra,88(sp)
    80005136:	6446                	ld	s0,80(sp)
    80005138:	64a6                	ld	s1,72(sp)
    8000513a:	6906                	ld	s2,64(sp)
    8000513c:	79e2                	ld	s3,56(sp)
    8000513e:	7a42                	ld	s4,48(sp)
    80005140:	7aa2                	ld	s5,40(sp)
    80005142:	7b02                	ld	s6,32(sp)
    80005144:	6be2                	ld	s7,24(sp)
    80005146:	6c42                	ld	s8,16(sp)
    80005148:	6125                	addi	sp,sp,96
    8000514a:	8082                	ret
      wakeup(&pi->nread);
    8000514c:	8562                	mv	a0,s8
    8000514e:	ffffd097          	auipc	ra,0xffffd
    80005152:	37c080e7          	jalr	892(ra) # 800024ca <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005156:	85a6                	mv	a1,s1
    80005158:	855e                	mv	a0,s7
    8000515a:	ffffd097          	auipc	ra,0xffffd
    8000515e:	1b4080e7          	jalr	436(ra) # 8000230e <sleep>
  while (i < n)
    80005162:	07495063          	bge	s2,s4,800051c2 <pipewrite+0xe0>
    if (pi->readopen == 0 || killed(pr))
    80005166:	2204a783          	lw	a5,544(s1)
    8000516a:	dfd5                	beqz	a5,80005126 <pipewrite+0x44>
    8000516c:	854e                	mv	a0,s3
    8000516e:	ffffd097          	auipc	ra,0xffffd
    80005172:	5cc080e7          	jalr	1484(ra) # 8000273a <killed>
    80005176:	f945                	bnez	a0,80005126 <pipewrite+0x44>
    if (pi->nwrite == pi->nread + PIPESIZE)
    80005178:	2184a783          	lw	a5,536(s1)
    8000517c:	21c4a703          	lw	a4,540(s1)
    80005180:	2007879b          	addiw	a5,a5,512
    80005184:	fcf704e3          	beq	a4,a5,8000514c <pipewrite+0x6a>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005188:	4685                	li	a3,1
    8000518a:	01590633          	add	a2,s2,s5
    8000518e:	faf40593          	addi	a1,s0,-81
    80005192:	0509b503          	ld	a0,80(s3)
    80005196:	ffffc097          	auipc	ra,0xffffc
    8000519a:	712080e7          	jalr	1810(ra) # 800018a8 <copyin>
    8000519e:	03650263          	beq	a0,s6,800051c2 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800051a2:	21c4a783          	lw	a5,540(s1)
    800051a6:	0017871b          	addiw	a4,a5,1
    800051aa:	20e4ae23          	sw	a4,540(s1)
    800051ae:	1ff7f793          	andi	a5,a5,511
    800051b2:	97a6                	add	a5,a5,s1
    800051b4:	faf44703          	lbu	a4,-81(s0)
    800051b8:	00e78c23          	sb	a4,24(a5)
      i++;
    800051bc:	2905                	addiw	s2,s2,1
    800051be:	b755                	j	80005162 <pipewrite+0x80>
  int i = 0;
    800051c0:	4901                	li	s2,0
  wakeup(&pi->nread);
    800051c2:	21848513          	addi	a0,s1,536
    800051c6:	ffffd097          	auipc	ra,0xffffd
    800051ca:	304080e7          	jalr	772(ra) # 800024ca <wakeup>
  release(&pi->lock);
    800051ce:	8526                	mv	a0,s1
    800051d0:	ffffc097          	auipc	ra,0xffffc
    800051d4:	c2e080e7          	jalr	-978(ra) # 80000dfe <release>
  return i;
    800051d8:	bfa9                	j	80005132 <pipewrite+0x50>

00000000800051da <piperead>:

int piperead(struct pipe *pi, uint64 addr, int n)
{
    800051da:	715d                	addi	sp,sp,-80
    800051dc:	e486                	sd	ra,72(sp)
    800051de:	e0a2                	sd	s0,64(sp)
    800051e0:	fc26                	sd	s1,56(sp)
    800051e2:	f84a                	sd	s2,48(sp)
    800051e4:	f44e                	sd	s3,40(sp)
    800051e6:	f052                	sd	s4,32(sp)
    800051e8:	ec56                	sd	s5,24(sp)
    800051ea:	e85a                	sd	s6,16(sp)
    800051ec:	0880                	addi	s0,sp,80
    800051ee:	84aa                	mv	s1,a0
    800051f0:	892e                	mv	s2,a1
    800051f2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800051f4:	ffffd097          	auipc	ra,0xffffd
    800051f8:	968080e7          	jalr	-1688(ra) # 80001b5c <myproc>
    800051fc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800051fe:	8526                	mv	a0,s1
    80005200:	ffffc097          	auipc	ra,0xffffc
    80005204:	b4a080e7          	jalr	-1206(ra) # 80000d4a <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80005208:	2184a703          	lw	a4,536(s1)
    8000520c:	21c4a783          	lw	a5,540(s1)
    if (killed(pr))
    {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80005210:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen)
    80005214:	02f71763          	bne	a4,a5,80005242 <piperead+0x68>
    80005218:	2244a783          	lw	a5,548(s1)
    8000521c:	c39d                	beqz	a5,80005242 <piperead+0x68>
    if (killed(pr))
    8000521e:	8552                	mv	a0,s4
    80005220:	ffffd097          	auipc	ra,0xffffd
    80005224:	51a080e7          	jalr	1306(ra) # 8000273a <killed>
    80005228:	e949                	bnez	a0,800052ba <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    8000522a:	85a6                	mv	a1,s1
    8000522c:	854e                	mv	a0,s3
    8000522e:	ffffd097          	auipc	ra,0xffffd
    80005232:	0e0080e7          	jalr	224(ra) # 8000230e <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80005236:	2184a703          	lw	a4,536(s1)
    8000523a:	21c4a783          	lw	a5,540(s1)
    8000523e:	fcf70de3          	beq	a4,a5,80005218 <piperead+0x3e>
  }
  for (i = 0; i < n; i++)
    80005242:	4981                	li	s3,0
  { // DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005244:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++)
    80005246:	05505463          	blez	s5,8000528e <piperead+0xb4>
    if (pi->nread == pi->nwrite)
    8000524a:	2184a783          	lw	a5,536(s1)
    8000524e:	21c4a703          	lw	a4,540(s1)
    80005252:	02f70e63          	beq	a4,a5,8000528e <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005256:	0017871b          	addiw	a4,a5,1
    8000525a:	20e4ac23          	sw	a4,536(s1)
    8000525e:	1ff7f793          	andi	a5,a5,511
    80005262:	97a6                	add	a5,a5,s1
    80005264:	0187c783          	lbu	a5,24(a5)
    80005268:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000526c:	4685                	li	a3,1
    8000526e:	fbf40613          	addi	a2,s0,-65
    80005272:	85ca                	mv	a1,s2
    80005274:	050a3503          	ld	a0,80(s4)
    80005278:	ffffc097          	auipc	ra,0xffffc
    8000527c:	568080e7          	jalr	1384(ra) # 800017e0 <copyout>
    80005280:	01650763          	beq	a0,s6,8000528e <piperead+0xb4>
  for (i = 0; i < n; i++)
    80005284:	2985                	addiw	s3,s3,1
    80005286:	0905                	addi	s2,s2,1
    80005288:	fd3a91e3          	bne	s5,s3,8000524a <piperead+0x70>
    8000528c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite); // DOC: piperead-wakeup
    8000528e:	21c48513          	addi	a0,s1,540
    80005292:	ffffd097          	auipc	ra,0xffffd
    80005296:	238080e7          	jalr	568(ra) # 800024ca <wakeup>
  release(&pi->lock);
    8000529a:	8526                	mv	a0,s1
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	b62080e7          	jalr	-1182(ra) # 80000dfe <release>
  return i;
}
    800052a4:	854e                	mv	a0,s3
    800052a6:	60a6                	ld	ra,72(sp)
    800052a8:	6406                	ld	s0,64(sp)
    800052aa:	74e2                	ld	s1,56(sp)
    800052ac:	7942                	ld	s2,48(sp)
    800052ae:	79a2                	ld	s3,40(sp)
    800052b0:	7a02                	ld	s4,32(sp)
    800052b2:	6ae2                	ld	s5,24(sp)
    800052b4:	6b42                	ld	s6,16(sp)
    800052b6:	6161                	addi	sp,sp,80
    800052b8:	8082                	ret
      release(&pi->lock);
    800052ba:	8526                	mv	a0,s1
    800052bc:	ffffc097          	auipc	ra,0xffffc
    800052c0:	b42080e7          	jalr	-1214(ra) # 80000dfe <release>
      return -1;
    800052c4:	59fd                	li	s3,-1
    800052c6:	bff9                	j	800052a4 <piperead+0xca>

00000000800052c8 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800052c8:	1141                	addi	sp,sp,-16
    800052ca:	e422                	sd	s0,8(sp)
    800052cc:	0800                	addi	s0,sp,16
    800052ce:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800052d0:	8905                	andi	a0,a0,1
    800052d2:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    800052d4:	8b89                	andi	a5,a5,2
    800052d6:	c399                	beqz	a5,800052dc <flags2perm+0x14>
    perm |= PTE_W;
    800052d8:	00456513          	ori	a0,a0,4
  return perm;
}
    800052dc:	6422                	ld	s0,8(sp)
    800052de:	0141                	addi	sp,sp,16
    800052e0:	8082                	ret

00000000800052e2 <exec>:

int exec(char *path, char **argv)
{
    800052e2:	de010113          	addi	sp,sp,-544
    800052e6:	20113c23          	sd	ra,536(sp)
    800052ea:	20813823          	sd	s0,528(sp)
    800052ee:	20913423          	sd	s1,520(sp)
    800052f2:	21213023          	sd	s2,512(sp)
    800052f6:	ffce                	sd	s3,504(sp)
    800052f8:	fbd2                	sd	s4,496(sp)
    800052fa:	f7d6                	sd	s5,488(sp)
    800052fc:	f3da                	sd	s6,480(sp)
    800052fe:	efde                	sd	s7,472(sp)
    80005300:	ebe2                	sd	s8,464(sp)
    80005302:	e7e6                	sd	s9,456(sp)
    80005304:	e3ea                	sd	s10,448(sp)
    80005306:	ff6e                	sd	s11,440(sp)
    80005308:	1400                	addi	s0,sp,544
    8000530a:	892a                	mv	s2,a0
    8000530c:	dea43423          	sd	a0,-536(s0)
    80005310:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005314:	ffffd097          	auipc	ra,0xffffd
    80005318:	848080e7          	jalr	-1976(ra) # 80001b5c <myproc>
    8000531c:	84aa                	mv	s1,a0

  begin_op();
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	482080e7          	jalr	1154(ra) # 800047a0 <begin_op>

  if ((ip = namei(path)) == 0)
    80005326:	854a                	mv	a0,s2
    80005328:	fffff097          	auipc	ra,0xfffff
    8000532c:	258080e7          	jalr	600(ra) # 80004580 <namei>
    80005330:	c93d                	beqz	a0,800053a6 <exec+0xc4>
    80005332:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005334:	fffff097          	auipc	ra,0xfffff
    80005338:	aa0080e7          	jalr	-1376(ra) # 80003dd4 <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000533c:	04000713          	li	a4,64
    80005340:	4681                	li	a3,0
    80005342:	e5040613          	addi	a2,s0,-432
    80005346:	4581                	li	a1,0
    80005348:	8556                	mv	a0,s5
    8000534a:	fffff097          	auipc	ra,0xfffff
    8000534e:	d3e080e7          	jalr	-706(ra) # 80004088 <readi>
    80005352:	04000793          	li	a5,64
    80005356:	00f51a63          	bne	a0,a5,8000536a <exec+0x88>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    8000535a:	e5042703          	lw	a4,-432(s0)
    8000535e:	464c47b7          	lui	a5,0x464c4
    80005362:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005366:	04f70663          	beq	a4,a5,800053b2 <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    8000536a:	8556                	mv	a0,s5
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	cca080e7          	jalr	-822(ra) # 80004036 <iunlockput>
    end_op();
    80005374:	fffff097          	auipc	ra,0xfffff
    80005378:	4aa080e7          	jalr	1194(ra) # 8000481e <end_op>
  }
  return -1;
    8000537c:	557d                	li	a0,-1
}
    8000537e:	21813083          	ld	ra,536(sp)
    80005382:	21013403          	ld	s0,528(sp)
    80005386:	20813483          	ld	s1,520(sp)
    8000538a:	20013903          	ld	s2,512(sp)
    8000538e:	79fe                	ld	s3,504(sp)
    80005390:	7a5e                	ld	s4,496(sp)
    80005392:	7abe                	ld	s5,488(sp)
    80005394:	7b1e                	ld	s6,480(sp)
    80005396:	6bfe                	ld	s7,472(sp)
    80005398:	6c5e                	ld	s8,464(sp)
    8000539a:	6cbe                	ld	s9,456(sp)
    8000539c:	6d1e                	ld	s10,448(sp)
    8000539e:	7dfa                	ld	s11,440(sp)
    800053a0:	22010113          	addi	sp,sp,544
    800053a4:	8082                	ret
    end_op();
    800053a6:	fffff097          	auipc	ra,0xfffff
    800053aa:	478080e7          	jalr	1144(ra) # 8000481e <end_op>
    return -1;
    800053ae:	557d                	li	a0,-1
    800053b0:	b7f9                	j	8000537e <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    800053b2:	8526                	mv	a0,s1
    800053b4:	ffffd097          	auipc	ra,0xffffd
    800053b8:	86c080e7          	jalr	-1940(ra) # 80001c20 <proc_pagetable>
    800053bc:	8b2a                	mv	s6,a0
    800053be:	d555                	beqz	a0,8000536a <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800053c0:	e7042783          	lw	a5,-400(s0)
    800053c4:	e8845703          	lhu	a4,-376(s0)
    800053c8:	c735                	beqz	a4,80005434 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053ca:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800053cc:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    800053d0:	6a05                	lui	s4,0x1
    800053d2:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800053d6:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for (i = 0; i < sz; i += PGSIZE)
    800053da:	6d85                	lui	s11,0x1
    800053dc:	7d7d                	lui	s10,0xfffff
    800053de:	ac3d                	j	8000561c <exec+0x33a>
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    800053e0:	00003517          	auipc	a0,0x3
    800053e4:	48050513          	addi	a0,a0,1152 # 80008860 <syscalls+0x2a0>
    800053e8:	ffffb097          	auipc	ra,0xffffb
    800053ec:	158080e7          	jalr	344(ra) # 80000540 <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800053f0:	874a                	mv	a4,s2
    800053f2:	009c86bb          	addw	a3,s9,s1
    800053f6:	4581                	li	a1,0
    800053f8:	8556                	mv	a0,s5
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	c8e080e7          	jalr	-882(ra) # 80004088 <readi>
    80005402:	2501                	sext.w	a0,a0
    80005404:	1aa91963          	bne	s2,a0,800055b6 <exec+0x2d4>
  for (i = 0; i < sz; i += PGSIZE)
    80005408:	009d84bb          	addw	s1,s11,s1
    8000540c:	013d09bb          	addw	s3,s10,s3
    80005410:	1f74f663          	bgeu	s1,s7,800055fc <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005414:	02049593          	slli	a1,s1,0x20
    80005418:	9181                	srli	a1,a1,0x20
    8000541a:	95e2                	add	a1,a1,s8
    8000541c:	855a                	mv	a0,s6
    8000541e:	ffffc097          	auipc	ra,0xffffc
    80005422:	db2080e7          	jalr	-590(ra) # 800011d0 <walkaddr>
    80005426:	862a                	mv	a2,a0
    if (pa == 0)
    80005428:	dd45                	beqz	a0,800053e0 <exec+0xfe>
      n = PGSIZE;
    8000542a:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    8000542c:	fd49f2e3          	bgeu	s3,s4,800053f0 <exec+0x10e>
      n = sz - i;
    80005430:	894e                	mv	s2,s3
    80005432:	bf7d                	j	800053f0 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005434:	4901                	li	s2,0
  iunlockput(ip);
    80005436:	8556                	mv	a0,s5
    80005438:	fffff097          	auipc	ra,0xfffff
    8000543c:	bfe080e7          	jalr	-1026(ra) # 80004036 <iunlockput>
  end_op();
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	3de080e7          	jalr	990(ra) # 8000481e <end_op>
  p = myproc();
    80005448:	ffffc097          	auipc	ra,0xffffc
    8000544c:	714080e7          	jalr	1812(ra) # 80001b5c <myproc>
    80005450:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005452:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005456:	6785                	lui	a5,0x1
    80005458:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000545a:	97ca                	add	a5,a5,s2
    8000545c:	777d                	lui	a4,0xfffff
    8000545e:	8ff9                	and	a5,a5,a4
    80005460:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    80005464:	4691                	li	a3,4
    80005466:	6609                	lui	a2,0x2
    80005468:	963e                	add	a2,a2,a5
    8000546a:	85be                	mv	a1,a5
    8000546c:	855a                	mv	a0,s6
    8000546e:	ffffc097          	auipc	ra,0xffffc
    80005472:	116080e7          	jalr	278(ra) # 80001584 <uvmalloc>
    80005476:	8c2a                	mv	s8,a0
  ip = 0;
    80005478:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    8000547a:	12050e63          	beqz	a0,800055b6 <exec+0x2d4>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    8000547e:	75f9                	lui	a1,0xffffe
    80005480:	95aa                	add	a1,a1,a0
    80005482:	855a                	mv	a0,s6
    80005484:	ffffc097          	auipc	ra,0xffffc
    80005488:	32a080e7          	jalr	810(ra) # 800017ae <uvmclear>
  stackbase = sp - PGSIZE;
    8000548c:	7afd                	lui	s5,0xfffff
    8000548e:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    80005490:	df043783          	ld	a5,-528(s0)
    80005494:	6388                	ld	a0,0(a5)
    80005496:	c925                	beqz	a0,80005506 <exec+0x224>
    80005498:	e9040993          	addi	s3,s0,-368
    8000549c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800054a0:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    800054a2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800054a4:	ffffc097          	auipc	ra,0xffffc
    800054a8:	b1e080e7          	jalr	-1250(ra) # 80000fc2 <strlen>
    800054ac:	0015079b          	addiw	a5,a0,1
    800054b0:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054b4:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    800054b8:	13596663          	bltu	s2,s5,800055e4 <exec+0x302>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054bc:	df043d83          	ld	s11,-528(s0)
    800054c0:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800054c4:	8552                	mv	a0,s4
    800054c6:	ffffc097          	auipc	ra,0xffffc
    800054ca:	afc080e7          	jalr	-1284(ra) # 80000fc2 <strlen>
    800054ce:	0015069b          	addiw	a3,a0,1
    800054d2:	8652                	mv	a2,s4
    800054d4:	85ca                	mv	a1,s2
    800054d6:	855a                	mv	a0,s6
    800054d8:	ffffc097          	auipc	ra,0xffffc
    800054dc:	308080e7          	jalr	776(ra) # 800017e0 <copyout>
    800054e0:	10054663          	bltz	a0,800055ec <exec+0x30a>
    ustack[argc] = sp;
    800054e4:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    800054e8:	0485                	addi	s1,s1,1
    800054ea:	008d8793          	addi	a5,s11,8
    800054ee:	def43823          	sd	a5,-528(s0)
    800054f2:	008db503          	ld	a0,8(s11)
    800054f6:	c911                	beqz	a0,8000550a <exec+0x228>
    if (argc >= MAXARG)
    800054f8:	09a1                	addi	s3,s3,8
    800054fa:	fb3c95e3          	bne	s9,s3,800054a4 <exec+0x1c2>
  sz = sz1;
    800054fe:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005502:	4a81                	li	s5,0
    80005504:	a84d                	j	800055b6 <exec+0x2d4>
  sp = sz;
    80005506:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005508:	4481                	li	s1,0
  ustack[argc] = 0;
    8000550a:	00349793          	slli	a5,s1,0x3
    8000550e:	f9078793          	addi	a5,a5,-112
    80005512:	97a2                	add	a5,a5,s0
    80005514:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80005518:	00148693          	addi	a3,s1,1
    8000551c:	068e                	slli	a3,a3,0x3
    8000551e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005522:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    80005526:	01597663          	bgeu	s2,s5,80005532 <exec+0x250>
  sz = sz1;
    8000552a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000552e:	4a81                	li	s5,0
    80005530:	a059                	j	800055b6 <exec+0x2d4>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    80005532:	e9040613          	addi	a2,s0,-368
    80005536:	85ca                	mv	a1,s2
    80005538:	855a                	mv	a0,s6
    8000553a:	ffffc097          	auipc	ra,0xffffc
    8000553e:	2a6080e7          	jalr	678(ra) # 800017e0 <copyout>
    80005542:	0a054963          	bltz	a0,800055f4 <exec+0x312>
  p->trapframe->a1 = sp;
    80005546:	058bb783          	ld	a5,88(s7)
    8000554a:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    8000554e:	de843783          	ld	a5,-536(s0)
    80005552:	0007c703          	lbu	a4,0(a5)
    80005556:	cf11                	beqz	a4,80005572 <exec+0x290>
    80005558:	0785                	addi	a5,a5,1
    if (*s == '/')
    8000555a:	02f00693          	li	a3,47
    8000555e:	a039                	j	8000556c <exec+0x28a>
      last = s + 1;
    80005560:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    80005564:	0785                	addi	a5,a5,1
    80005566:	fff7c703          	lbu	a4,-1(a5)
    8000556a:	c701                	beqz	a4,80005572 <exec+0x290>
    if (*s == '/')
    8000556c:	fed71ce3          	bne	a4,a3,80005564 <exec+0x282>
    80005570:	bfc5                	j	80005560 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005572:	4641                	li	a2,16
    80005574:	de843583          	ld	a1,-536(s0)
    80005578:	158b8513          	addi	a0,s7,344
    8000557c:	ffffc097          	auipc	ra,0xffffc
    80005580:	a14080e7          	jalr	-1516(ra) # 80000f90 <safestrcpy>
  oldpagetable = p->pagetable;
    80005584:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005588:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000558c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    80005590:	058bb783          	ld	a5,88(s7)
    80005594:	e6843703          	ld	a4,-408(s0)
    80005598:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    8000559a:	058bb783          	ld	a5,88(s7)
    8000559e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800055a2:	85ea                	mv	a1,s10
    800055a4:	ffffc097          	auipc	ra,0xffffc
    800055a8:	718080e7          	jalr	1816(ra) # 80001cbc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800055ac:	0004851b          	sext.w	a0,s1
    800055b0:	b3f9                	j	8000537e <exec+0x9c>
    800055b2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800055b6:	df843583          	ld	a1,-520(s0)
    800055ba:	855a                	mv	a0,s6
    800055bc:	ffffc097          	auipc	ra,0xffffc
    800055c0:	700080e7          	jalr	1792(ra) # 80001cbc <proc_freepagetable>
  if (ip)
    800055c4:	da0a93e3          	bnez	s5,8000536a <exec+0x88>
  return -1;
    800055c8:	557d                	li	a0,-1
    800055ca:	bb55                	j	8000537e <exec+0x9c>
    800055cc:	df243c23          	sd	s2,-520(s0)
    800055d0:	b7dd                	j	800055b6 <exec+0x2d4>
    800055d2:	df243c23          	sd	s2,-520(s0)
    800055d6:	b7c5                	j	800055b6 <exec+0x2d4>
    800055d8:	df243c23          	sd	s2,-520(s0)
    800055dc:	bfe9                	j	800055b6 <exec+0x2d4>
    800055de:	df243c23          	sd	s2,-520(s0)
    800055e2:	bfd1                	j	800055b6 <exec+0x2d4>
  sz = sz1;
    800055e4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055e8:	4a81                	li	s5,0
    800055ea:	b7f1                	j	800055b6 <exec+0x2d4>
  sz = sz1;
    800055ec:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055f0:	4a81                	li	s5,0
    800055f2:	b7d1                	j	800055b6 <exec+0x2d4>
  sz = sz1;
    800055f4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055f8:	4a81                	li	s5,0
    800055fa:	bf75                	j	800055b6 <exec+0x2d4>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055fc:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005600:	e0843783          	ld	a5,-504(s0)
    80005604:	0017869b          	addiw	a3,a5,1
    80005608:	e0d43423          	sd	a3,-504(s0)
    8000560c:	e0043783          	ld	a5,-512(s0)
    80005610:	0387879b          	addiw	a5,a5,56
    80005614:	e8845703          	lhu	a4,-376(s0)
    80005618:	e0e6dfe3          	bge	a3,a4,80005436 <exec+0x154>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000561c:	2781                	sext.w	a5,a5
    8000561e:	e0f43023          	sd	a5,-512(s0)
    80005622:	03800713          	li	a4,56
    80005626:	86be                	mv	a3,a5
    80005628:	e1840613          	addi	a2,s0,-488
    8000562c:	4581                	li	a1,0
    8000562e:	8556                	mv	a0,s5
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	a58080e7          	jalr	-1448(ra) # 80004088 <readi>
    80005638:	03800793          	li	a5,56
    8000563c:	f6f51be3          	bne	a0,a5,800055b2 <exec+0x2d0>
    if (ph.type != ELF_PROG_LOAD)
    80005640:	e1842783          	lw	a5,-488(s0)
    80005644:	4705                	li	a4,1
    80005646:	fae79de3          	bne	a5,a4,80005600 <exec+0x31e>
    if (ph.memsz < ph.filesz)
    8000564a:	e4043483          	ld	s1,-448(s0)
    8000564e:	e3843783          	ld	a5,-456(s0)
    80005652:	f6f4ede3          	bltu	s1,a5,800055cc <exec+0x2ea>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80005656:	e2843783          	ld	a5,-472(s0)
    8000565a:	94be                	add	s1,s1,a5
    8000565c:	f6f4ebe3          	bltu	s1,a5,800055d2 <exec+0x2f0>
    if (ph.vaddr % PGSIZE != 0)
    80005660:	de043703          	ld	a4,-544(s0)
    80005664:	8ff9                	and	a5,a5,a4
    80005666:	fbad                	bnez	a5,800055d8 <exec+0x2f6>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005668:	e1c42503          	lw	a0,-484(s0)
    8000566c:	00000097          	auipc	ra,0x0
    80005670:	c5c080e7          	jalr	-932(ra) # 800052c8 <flags2perm>
    80005674:	86aa                	mv	a3,a0
    80005676:	8626                	mv	a2,s1
    80005678:	85ca                	mv	a1,s2
    8000567a:	855a                	mv	a0,s6
    8000567c:	ffffc097          	auipc	ra,0xffffc
    80005680:	f08080e7          	jalr	-248(ra) # 80001584 <uvmalloc>
    80005684:	dea43c23          	sd	a0,-520(s0)
    80005688:	d939                	beqz	a0,800055de <exec+0x2fc>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000568a:	e2843c03          	ld	s8,-472(s0)
    8000568e:	e2042c83          	lw	s9,-480(s0)
    80005692:	e3842b83          	lw	s7,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    80005696:	f60b83e3          	beqz	s7,800055fc <exec+0x31a>
    8000569a:	89de                	mv	s3,s7
    8000569c:	4481                	li	s1,0
    8000569e:	bb9d                	j	80005414 <exec+0x132>

00000000800056a0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800056a0:	7179                	addi	sp,sp,-48
    800056a2:	f406                	sd	ra,40(sp)
    800056a4:	f022                	sd	s0,32(sp)
    800056a6:	ec26                	sd	s1,24(sp)
    800056a8:	e84a                	sd	s2,16(sp)
    800056aa:	1800                	addi	s0,sp,48
    800056ac:	892e                	mv	s2,a1
    800056ae:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800056b0:	fdc40593          	addi	a1,s0,-36
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	9c0080e7          	jalr	-1600(ra) # 80003074 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    800056bc:	fdc42703          	lw	a4,-36(s0)
    800056c0:	47bd                	li	a5,15
    800056c2:	02e7eb63          	bltu	a5,a4,800056f8 <argfd+0x58>
    800056c6:	ffffc097          	auipc	ra,0xffffc
    800056ca:	496080e7          	jalr	1174(ra) # 80001b5c <myproc>
    800056ce:	fdc42703          	lw	a4,-36(s0)
    800056d2:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7fdb9a7a>
    800056d6:	078e                	slli	a5,a5,0x3
    800056d8:	953e                	add	a0,a0,a5
    800056da:	611c                	ld	a5,0(a0)
    800056dc:	c385                	beqz	a5,800056fc <argfd+0x5c>
    return -1;
  if (pfd)
    800056de:	00090463          	beqz	s2,800056e6 <argfd+0x46>
    *pfd = fd;
    800056e2:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    800056e6:	4501                	li	a0,0
  if (pf)
    800056e8:	c091                	beqz	s1,800056ec <argfd+0x4c>
    *pf = f;
    800056ea:	e09c                	sd	a5,0(s1)
}
    800056ec:	70a2                	ld	ra,40(sp)
    800056ee:	7402                	ld	s0,32(sp)
    800056f0:	64e2                	ld	s1,24(sp)
    800056f2:	6942                	ld	s2,16(sp)
    800056f4:	6145                	addi	sp,sp,48
    800056f6:	8082                	ret
    return -1;
    800056f8:	557d                	li	a0,-1
    800056fa:	bfcd                	j	800056ec <argfd+0x4c>
    800056fc:	557d                	li	a0,-1
    800056fe:	b7fd                	j	800056ec <argfd+0x4c>

0000000080005700 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005700:	1101                	addi	sp,sp,-32
    80005702:	ec06                	sd	ra,24(sp)
    80005704:	e822                	sd	s0,16(sp)
    80005706:	e426                	sd	s1,8(sp)
    80005708:	1000                	addi	s0,sp,32
    8000570a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000570c:	ffffc097          	auipc	ra,0xffffc
    80005710:	450080e7          	jalr	1104(ra) # 80001b5c <myproc>
    80005714:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++)
    80005716:	0d050793          	addi	a5,a0,208
    8000571a:	4501                	li	a0,0
    8000571c:	46c1                	li	a3,16
  {
    if (p->ofile[fd] == 0)
    8000571e:	6398                	ld	a4,0(a5)
    80005720:	cb19                	beqz	a4,80005736 <fdalloc+0x36>
  for (fd = 0; fd < NOFILE; fd++)
    80005722:	2505                	addiw	a0,a0,1
    80005724:	07a1                	addi	a5,a5,8
    80005726:	fed51ce3          	bne	a0,a3,8000571e <fdalloc+0x1e>
    {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000572a:	557d                	li	a0,-1
}
    8000572c:	60e2                	ld	ra,24(sp)
    8000572e:	6442                	ld	s0,16(sp)
    80005730:	64a2                	ld	s1,8(sp)
    80005732:	6105                	addi	sp,sp,32
    80005734:	8082                	ret
      p->ofile[fd] = f;
    80005736:	01a50793          	addi	a5,a0,26
    8000573a:	078e                	slli	a5,a5,0x3
    8000573c:	963e                	add	a2,a2,a5
    8000573e:	e204                	sd	s1,0(a2)
      return fd;
    80005740:	b7f5                	j	8000572c <fdalloc+0x2c>

0000000080005742 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80005742:	715d                	addi	sp,sp,-80
    80005744:	e486                	sd	ra,72(sp)
    80005746:	e0a2                	sd	s0,64(sp)
    80005748:	fc26                	sd	s1,56(sp)
    8000574a:	f84a                	sd	s2,48(sp)
    8000574c:	f44e                	sd	s3,40(sp)
    8000574e:	f052                	sd	s4,32(sp)
    80005750:	ec56                	sd	s5,24(sp)
    80005752:	e85a                	sd	s6,16(sp)
    80005754:	0880                	addi	s0,sp,80
    80005756:	8b2e                	mv	s6,a1
    80005758:	89b2                	mv	s3,a2
    8000575a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    8000575c:	fb040593          	addi	a1,s0,-80
    80005760:	fffff097          	auipc	ra,0xfffff
    80005764:	e3e080e7          	jalr	-450(ra) # 8000459e <nameiparent>
    80005768:	84aa                	mv	s1,a0
    8000576a:	14050f63          	beqz	a0,800058c8 <create+0x186>
    return 0;

  ilock(dp);
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	666080e7          	jalr	1638(ra) # 80003dd4 <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0)
    80005776:	4601                	li	a2,0
    80005778:	fb040593          	addi	a1,s0,-80
    8000577c:	8526                	mv	a0,s1
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	b3a080e7          	jalr	-1222(ra) # 800042b8 <dirlookup>
    80005786:	8aaa                	mv	s5,a0
    80005788:	c931                	beqz	a0,800057dc <create+0x9a>
  {
    iunlockput(dp);
    8000578a:	8526                	mv	a0,s1
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	8aa080e7          	jalr	-1878(ra) # 80004036 <iunlockput>
    ilock(ip);
    80005794:	8556                	mv	a0,s5
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	63e080e7          	jalr	1598(ra) # 80003dd4 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000579e:	000b059b          	sext.w	a1,s6
    800057a2:	4789                	li	a5,2
    800057a4:	02f59563          	bne	a1,a5,800057ce <create+0x8c>
    800057a8:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fdb9aa4>
    800057ac:	37f9                	addiw	a5,a5,-2
    800057ae:	17c2                	slli	a5,a5,0x30
    800057b0:	93c1                	srli	a5,a5,0x30
    800057b2:	4705                	li	a4,1
    800057b4:	00f76d63          	bltu	a4,a5,800057ce <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800057b8:	8556                	mv	a0,s5
    800057ba:	60a6                	ld	ra,72(sp)
    800057bc:	6406                	ld	s0,64(sp)
    800057be:	74e2                	ld	s1,56(sp)
    800057c0:	7942                	ld	s2,48(sp)
    800057c2:	79a2                	ld	s3,40(sp)
    800057c4:	7a02                	ld	s4,32(sp)
    800057c6:	6ae2                	ld	s5,24(sp)
    800057c8:	6b42                	ld	s6,16(sp)
    800057ca:	6161                	addi	sp,sp,80
    800057cc:	8082                	ret
    iunlockput(ip);
    800057ce:	8556                	mv	a0,s5
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	866080e7          	jalr	-1946(ra) # 80004036 <iunlockput>
    return 0;
    800057d8:	4a81                	li	s5,0
    800057da:	bff9                	j	800057b8 <create+0x76>
  if ((ip = ialloc(dp->dev, type)) == 0)
    800057dc:	85da                	mv	a1,s6
    800057de:	4088                	lw	a0,0(s1)
    800057e0:	ffffe097          	auipc	ra,0xffffe
    800057e4:	456080e7          	jalr	1110(ra) # 80003c36 <ialloc>
    800057e8:	8a2a                	mv	s4,a0
    800057ea:	c539                	beqz	a0,80005838 <create+0xf6>
  ilock(ip);
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	5e8080e7          	jalr	1512(ra) # 80003dd4 <ilock>
  ip->major = major;
    800057f4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800057f8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800057fc:	4905                	li	s2,1
    800057fe:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005802:	8552                	mv	a0,s4
    80005804:	ffffe097          	auipc	ra,0xffffe
    80005808:	504080e7          	jalr	1284(ra) # 80003d08 <iupdate>
  if (type == T_DIR)
    8000580c:	000b059b          	sext.w	a1,s6
    80005810:	03258b63          	beq	a1,s2,80005846 <create+0x104>
  if (dirlink(dp, name, ip->inum) < 0)
    80005814:	004a2603          	lw	a2,4(s4)
    80005818:	fb040593          	addi	a1,s0,-80
    8000581c:	8526                	mv	a0,s1
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	cb0080e7          	jalr	-848(ra) # 800044ce <dirlink>
    80005826:	06054f63          	bltz	a0,800058a4 <create+0x162>
  iunlockput(dp);
    8000582a:	8526                	mv	a0,s1
    8000582c:	fffff097          	auipc	ra,0xfffff
    80005830:	80a080e7          	jalr	-2038(ra) # 80004036 <iunlockput>
  return ip;
    80005834:	8ad2                	mv	s5,s4
    80005836:	b749                	j	800057b8 <create+0x76>
    iunlockput(dp);
    80005838:	8526                	mv	a0,s1
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	7fc080e7          	jalr	2044(ra) # 80004036 <iunlockput>
    return 0;
    80005842:	8ad2                	mv	s5,s4
    80005844:	bf95                	j	800057b8 <create+0x76>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005846:	004a2603          	lw	a2,4(s4)
    8000584a:	00003597          	auipc	a1,0x3
    8000584e:	03658593          	addi	a1,a1,54 # 80008880 <syscalls+0x2c0>
    80005852:	8552                	mv	a0,s4
    80005854:	fffff097          	auipc	ra,0xfffff
    80005858:	c7a080e7          	jalr	-902(ra) # 800044ce <dirlink>
    8000585c:	04054463          	bltz	a0,800058a4 <create+0x162>
    80005860:	40d0                	lw	a2,4(s1)
    80005862:	00003597          	auipc	a1,0x3
    80005866:	02658593          	addi	a1,a1,38 # 80008888 <syscalls+0x2c8>
    8000586a:	8552                	mv	a0,s4
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	c62080e7          	jalr	-926(ra) # 800044ce <dirlink>
    80005874:	02054863          	bltz	a0,800058a4 <create+0x162>
  if (dirlink(dp, name, ip->inum) < 0)
    80005878:	004a2603          	lw	a2,4(s4)
    8000587c:	fb040593          	addi	a1,s0,-80
    80005880:	8526                	mv	a0,s1
    80005882:	fffff097          	auipc	ra,0xfffff
    80005886:	c4c080e7          	jalr	-948(ra) # 800044ce <dirlink>
    8000588a:	00054d63          	bltz	a0,800058a4 <create+0x162>
    dp->nlink++; // for ".."
    8000588e:	04a4d783          	lhu	a5,74(s1)
    80005892:	2785                	addiw	a5,a5,1
    80005894:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005898:	8526                	mv	a0,s1
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	46e080e7          	jalr	1134(ra) # 80003d08 <iupdate>
    800058a2:	b761                	j	8000582a <create+0xe8>
  ip->nlink = 0;
    800058a4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800058a8:	8552                	mv	a0,s4
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	45e080e7          	jalr	1118(ra) # 80003d08 <iupdate>
  iunlockput(ip);
    800058b2:	8552                	mv	a0,s4
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	782080e7          	jalr	1922(ra) # 80004036 <iunlockput>
  iunlockput(dp);
    800058bc:	8526                	mv	a0,s1
    800058be:	ffffe097          	auipc	ra,0xffffe
    800058c2:	778080e7          	jalr	1912(ra) # 80004036 <iunlockput>
  return 0;
    800058c6:	bdcd                	j	800057b8 <create+0x76>
    return 0;
    800058c8:	8aaa                	mv	s5,a0
    800058ca:	b5fd                	j	800057b8 <create+0x76>

00000000800058cc <sys_dup>:
{
    800058cc:	7179                	addi	sp,sp,-48
    800058ce:	f406                	sd	ra,40(sp)
    800058d0:	f022                	sd	s0,32(sp)
    800058d2:	ec26                	sd	s1,24(sp)
    800058d4:	e84a                	sd	s2,16(sp)
    800058d6:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    800058d8:	fd840613          	addi	a2,s0,-40
    800058dc:	4581                	li	a1,0
    800058de:	4501                	li	a0,0
    800058e0:	00000097          	auipc	ra,0x0
    800058e4:	dc0080e7          	jalr	-576(ra) # 800056a0 <argfd>
    return -1;
    800058e8:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    800058ea:	02054363          	bltz	a0,80005910 <sys_dup+0x44>
  if ((fd = fdalloc(f)) < 0)
    800058ee:	fd843903          	ld	s2,-40(s0)
    800058f2:	854a                	mv	a0,s2
    800058f4:	00000097          	auipc	ra,0x0
    800058f8:	e0c080e7          	jalr	-500(ra) # 80005700 <fdalloc>
    800058fc:	84aa                	mv	s1,a0
    return -1;
    800058fe:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80005900:	00054863          	bltz	a0,80005910 <sys_dup+0x44>
  filedup(f);
    80005904:	854a                	mv	a0,s2
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	310080e7          	jalr	784(ra) # 80004c16 <filedup>
  return fd;
    8000590e:	87a6                	mv	a5,s1
}
    80005910:	853e                	mv	a0,a5
    80005912:	70a2                	ld	ra,40(sp)
    80005914:	7402                	ld	s0,32(sp)
    80005916:	64e2                	ld	s1,24(sp)
    80005918:	6942                	ld	s2,16(sp)
    8000591a:	6145                	addi	sp,sp,48
    8000591c:	8082                	ret

000000008000591e <sys_read>:
{
    8000591e:	7179                	addi	sp,sp,-48
    80005920:	f406                	sd	ra,40(sp)
    80005922:	f022                	sd	s0,32(sp)
    80005924:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005926:	fd840593          	addi	a1,s0,-40
    8000592a:	4505                	li	a0,1
    8000592c:	ffffd097          	auipc	ra,0xffffd
    80005930:	768080e7          	jalr	1896(ra) # 80003094 <argaddr>
  argint(2, &n);
    80005934:	fe440593          	addi	a1,s0,-28
    80005938:	4509                	li	a0,2
    8000593a:	ffffd097          	auipc	ra,0xffffd
    8000593e:	73a080e7          	jalr	1850(ra) # 80003074 <argint>
  if (argfd(0, 0, &f) < 0)
    80005942:	fe840613          	addi	a2,s0,-24
    80005946:	4581                	li	a1,0
    80005948:	4501                	li	a0,0
    8000594a:	00000097          	auipc	ra,0x0
    8000594e:	d56080e7          	jalr	-682(ra) # 800056a0 <argfd>
    80005952:	87aa                	mv	a5,a0
    return -1;
    80005954:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005956:	0007cc63          	bltz	a5,8000596e <sys_read+0x50>
  return fileread(f, p, n);
    8000595a:	fe442603          	lw	a2,-28(s0)
    8000595e:	fd843583          	ld	a1,-40(s0)
    80005962:	fe843503          	ld	a0,-24(s0)
    80005966:	fffff097          	auipc	ra,0xfffff
    8000596a:	43c080e7          	jalr	1084(ra) # 80004da2 <fileread>
}
    8000596e:	70a2                	ld	ra,40(sp)
    80005970:	7402                	ld	s0,32(sp)
    80005972:	6145                	addi	sp,sp,48
    80005974:	8082                	ret

0000000080005976 <sys_write>:
{
    80005976:	7179                	addi	sp,sp,-48
    80005978:	f406                	sd	ra,40(sp)
    8000597a:	f022                	sd	s0,32(sp)
    8000597c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000597e:	fd840593          	addi	a1,s0,-40
    80005982:	4505                	li	a0,1
    80005984:	ffffd097          	auipc	ra,0xffffd
    80005988:	710080e7          	jalr	1808(ra) # 80003094 <argaddr>
  argint(2, &n);
    8000598c:	fe440593          	addi	a1,s0,-28
    80005990:	4509                	li	a0,2
    80005992:	ffffd097          	auipc	ra,0xffffd
    80005996:	6e2080e7          	jalr	1762(ra) # 80003074 <argint>
  if (argfd(0, 0, &f) < 0)
    8000599a:	fe840613          	addi	a2,s0,-24
    8000599e:	4581                	li	a1,0
    800059a0:	4501                	li	a0,0
    800059a2:	00000097          	auipc	ra,0x0
    800059a6:	cfe080e7          	jalr	-770(ra) # 800056a0 <argfd>
    800059aa:	87aa                	mv	a5,a0
    return -1;
    800059ac:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800059ae:	0007cc63          	bltz	a5,800059c6 <sys_write+0x50>
  return filewrite(f, p, n);
    800059b2:	fe442603          	lw	a2,-28(s0)
    800059b6:	fd843583          	ld	a1,-40(s0)
    800059ba:	fe843503          	ld	a0,-24(s0)
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	4a6080e7          	jalr	1190(ra) # 80004e64 <filewrite>
}
    800059c6:	70a2                	ld	ra,40(sp)
    800059c8:	7402                	ld	s0,32(sp)
    800059ca:	6145                	addi	sp,sp,48
    800059cc:	8082                	ret

00000000800059ce <sys_close>:
{
    800059ce:	1101                	addi	sp,sp,-32
    800059d0:	ec06                	sd	ra,24(sp)
    800059d2:	e822                	sd	s0,16(sp)
    800059d4:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800059d6:	fe040613          	addi	a2,s0,-32
    800059da:	fec40593          	addi	a1,s0,-20
    800059de:	4501                	li	a0,0
    800059e0:	00000097          	auipc	ra,0x0
    800059e4:	cc0080e7          	jalr	-832(ra) # 800056a0 <argfd>
    return -1;
    800059e8:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    800059ea:	02054463          	bltz	a0,80005a12 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800059ee:	ffffc097          	auipc	ra,0xffffc
    800059f2:	16e080e7          	jalr	366(ra) # 80001b5c <myproc>
    800059f6:	fec42783          	lw	a5,-20(s0)
    800059fa:	07e9                	addi	a5,a5,26
    800059fc:	078e                	slli	a5,a5,0x3
    800059fe:	953e                	add	a0,a0,a5
    80005a00:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005a04:	fe043503          	ld	a0,-32(s0)
    80005a08:	fffff097          	auipc	ra,0xfffff
    80005a0c:	260080e7          	jalr	608(ra) # 80004c68 <fileclose>
  return 0;
    80005a10:	4781                	li	a5,0
}
    80005a12:	853e                	mv	a0,a5
    80005a14:	60e2                	ld	ra,24(sp)
    80005a16:	6442                	ld	s0,16(sp)
    80005a18:	6105                	addi	sp,sp,32
    80005a1a:	8082                	ret

0000000080005a1c <sys_fstat>:
{
    80005a1c:	1101                	addi	sp,sp,-32
    80005a1e:	ec06                	sd	ra,24(sp)
    80005a20:	e822                	sd	s0,16(sp)
    80005a22:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005a24:	fe040593          	addi	a1,s0,-32
    80005a28:	4505                	li	a0,1
    80005a2a:	ffffd097          	auipc	ra,0xffffd
    80005a2e:	66a080e7          	jalr	1642(ra) # 80003094 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005a32:	fe840613          	addi	a2,s0,-24
    80005a36:	4581                	li	a1,0
    80005a38:	4501                	li	a0,0
    80005a3a:	00000097          	auipc	ra,0x0
    80005a3e:	c66080e7          	jalr	-922(ra) # 800056a0 <argfd>
    80005a42:	87aa                	mv	a5,a0
    return -1;
    80005a44:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005a46:	0007ca63          	bltz	a5,80005a5a <sys_fstat+0x3e>
  return filestat(f, st);
    80005a4a:	fe043583          	ld	a1,-32(s0)
    80005a4e:	fe843503          	ld	a0,-24(s0)
    80005a52:	fffff097          	auipc	ra,0xfffff
    80005a56:	2de080e7          	jalr	734(ra) # 80004d30 <filestat>
}
    80005a5a:	60e2                	ld	ra,24(sp)
    80005a5c:	6442                	ld	s0,16(sp)
    80005a5e:	6105                	addi	sp,sp,32
    80005a60:	8082                	ret

0000000080005a62 <sys_link>:
{
    80005a62:	7169                	addi	sp,sp,-304
    80005a64:	f606                	sd	ra,296(sp)
    80005a66:	f222                	sd	s0,288(sp)
    80005a68:	ee26                	sd	s1,280(sp)
    80005a6a:	ea4a                	sd	s2,272(sp)
    80005a6c:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a6e:	08000613          	li	a2,128
    80005a72:	ed040593          	addi	a1,s0,-304
    80005a76:	4501                	li	a0,0
    80005a78:	ffffd097          	auipc	ra,0xffffd
    80005a7c:	63c080e7          	jalr	1596(ra) # 800030b4 <argstr>
    return -1;
    80005a80:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a82:	10054e63          	bltz	a0,80005b9e <sys_link+0x13c>
    80005a86:	08000613          	li	a2,128
    80005a8a:	f5040593          	addi	a1,s0,-176
    80005a8e:	4505                	li	a0,1
    80005a90:	ffffd097          	auipc	ra,0xffffd
    80005a94:	624080e7          	jalr	1572(ra) # 800030b4 <argstr>
    return -1;
    80005a98:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a9a:	10054263          	bltz	a0,80005b9e <sys_link+0x13c>
  begin_op();
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	d02080e7          	jalr	-766(ra) # 800047a0 <begin_op>
  if ((ip = namei(old)) == 0)
    80005aa6:	ed040513          	addi	a0,s0,-304
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	ad6080e7          	jalr	-1322(ra) # 80004580 <namei>
    80005ab2:	84aa                	mv	s1,a0
    80005ab4:	c551                	beqz	a0,80005b40 <sys_link+0xde>
  ilock(ip);
    80005ab6:	ffffe097          	auipc	ra,0xffffe
    80005aba:	31e080e7          	jalr	798(ra) # 80003dd4 <ilock>
  if (ip->type == T_DIR)
    80005abe:	04449703          	lh	a4,68(s1)
    80005ac2:	4785                	li	a5,1
    80005ac4:	08f70463          	beq	a4,a5,80005b4c <sys_link+0xea>
  ip->nlink++;
    80005ac8:	04a4d783          	lhu	a5,74(s1)
    80005acc:	2785                	addiw	a5,a5,1
    80005ace:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ad2:	8526                	mv	a0,s1
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	234080e7          	jalr	564(ra) # 80003d08 <iupdate>
  iunlock(ip);
    80005adc:	8526                	mv	a0,s1
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	3b8080e7          	jalr	952(ra) # 80003e96 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005ae6:	fd040593          	addi	a1,s0,-48
    80005aea:	f5040513          	addi	a0,s0,-176
    80005aee:	fffff097          	auipc	ra,0xfffff
    80005af2:	ab0080e7          	jalr	-1360(ra) # 8000459e <nameiparent>
    80005af6:	892a                	mv	s2,a0
    80005af8:	c935                	beqz	a0,80005b6c <sys_link+0x10a>
  ilock(dp);
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	2da080e7          	jalr	730(ra) # 80003dd4 <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0)
    80005b02:	00092703          	lw	a4,0(s2)
    80005b06:	409c                	lw	a5,0(s1)
    80005b08:	04f71d63          	bne	a4,a5,80005b62 <sys_link+0x100>
    80005b0c:	40d0                	lw	a2,4(s1)
    80005b0e:	fd040593          	addi	a1,s0,-48
    80005b12:	854a                	mv	a0,s2
    80005b14:	fffff097          	auipc	ra,0xfffff
    80005b18:	9ba080e7          	jalr	-1606(ra) # 800044ce <dirlink>
    80005b1c:	04054363          	bltz	a0,80005b62 <sys_link+0x100>
  iunlockput(dp);
    80005b20:	854a                	mv	a0,s2
    80005b22:	ffffe097          	auipc	ra,0xffffe
    80005b26:	514080e7          	jalr	1300(ra) # 80004036 <iunlockput>
  iput(ip);
    80005b2a:	8526                	mv	a0,s1
    80005b2c:	ffffe097          	auipc	ra,0xffffe
    80005b30:	462080e7          	jalr	1122(ra) # 80003f8e <iput>
  end_op();
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	cea080e7          	jalr	-790(ra) # 8000481e <end_op>
  return 0;
    80005b3c:	4781                	li	a5,0
    80005b3e:	a085                	j	80005b9e <sys_link+0x13c>
    end_op();
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	cde080e7          	jalr	-802(ra) # 8000481e <end_op>
    return -1;
    80005b48:	57fd                	li	a5,-1
    80005b4a:	a891                	j	80005b9e <sys_link+0x13c>
    iunlockput(ip);
    80005b4c:	8526                	mv	a0,s1
    80005b4e:	ffffe097          	auipc	ra,0xffffe
    80005b52:	4e8080e7          	jalr	1256(ra) # 80004036 <iunlockput>
    end_op();
    80005b56:	fffff097          	auipc	ra,0xfffff
    80005b5a:	cc8080e7          	jalr	-824(ra) # 8000481e <end_op>
    return -1;
    80005b5e:	57fd                	li	a5,-1
    80005b60:	a83d                	j	80005b9e <sys_link+0x13c>
    iunlockput(dp);
    80005b62:	854a                	mv	a0,s2
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	4d2080e7          	jalr	1234(ra) # 80004036 <iunlockput>
  ilock(ip);
    80005b6c:	8526                	mv	a0,s1
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	266080e7          	jalr	614(ra) # 80003dd4 <ilock>
  ip->nlink--;
    80005b76:	04a4d783          	lhu	a5,74(s1)
    80005b7a:	37fd                	addiw	a5,a5,-1
    80005b7c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b80:	8526                	mv	a0,s1
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	186080e7          	jalr	390(ra) # 80003d08 <iupdate>
  iunlockput(ip);
    80005b8a:	8526                	mv	a0,s1
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	4aa080e7          	jalr	1194(ra) # 80004036 <iunlockput>
  end_op();
    80005b94:	fffff097          	auipc	ra,0xfffff
    80005b98:	c8a080e7          	jalr	-886(ra) # 8000481e <end_op>
  return -1;
    80005b9c:	57fd                	li	a5,-1
}
    80005b9e:	853e                	mv	a0,a5
    80005ba0:	70b2                	ld	ra,296(sp)
    80005ba2:	7412                	ld	s0,288(sp)
    80005ba4:	64f2                	ld	s1,280(sp)
    80005ba6:	6952                	ld	s2,272(sp)
    80005ba8:	6155                	addi	sp,sp,304
    80005baa:	8082                	ret

0000000080005bac <sys_unlink>:
{
    80005bac:	7151                	addi	sp,sp,-240
    80005bae:	f586                	sd	ra,232(sp)
    80005bb0:	f1a2                	sd	s0,224(sp)
    80005bb2:	eda6                	sd	s1,216(sp)
    80005bb4:	e9ca                	sd	s2,208(sp)
    80005bb6:	e5ce                	sd	s3,200(sp)
    80005bb8:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005bba:	08000613          	li	a2,128
    80005bbe:	f3040593          	addi	a1,s0,-208
    80005bc2:	4501                	li	a0,0
    80005bc4:	ffffd097          	auipc	ra,0xffffd
    80005bc8:	4f0080e7          	jalr	1264(ra) # 800030b4 <argstr>
    80005bcc:	18054163          	bltz	a0,80005d4e <sys_unlink+0x1a2>
  begin_op();
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	bd0080e7          	jalr	-1072(ra) # 800047a0 <begin_op>
  if ((dp = nameiparent(path, name)) == 0)
    80005bd8:	fb040593          	addi	a1,s0,-80
    80005bdc:	f3040513          	addi	a0,s0,-208
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	9be080e7          	jalr	-1602(ra) # 8000459e <nameiparent>
    80005be8:	84aa                	mv	s1,a0
    80005bea:	c979                	beqz	a0,80005cc0 <sys_unlink+0x114>
  ilock(dp);
    80005bec:	ffffe097          	auipc	ra,0xffffe
    80005bf0:	1e8080e7          	jalr	488(ra) # 80003dd4 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005bf4:	00003597          	auipc	a1,0x3
    80005bf8:	c8c58593          	addi	a1,a1,-884 # 80008880 <syscalls+0x2c0>
    80005bfc:	fb040513          	addi	a0,s0,-80
    80005c00:	ffffe097          	auipc	ra,0xffffe
    80005c04:	69e080e7          	jalr	1694(ra) # 8000429e <namecmp>
    80005c08:	14050a63          	beqz	a0,80005d5c <sys_unlink+0x1b0>
    80005c0c:	00003597          	auipc	a1,0x3
    80005c10:	c7c58593          	addi	a1,a1,-900 # 80008888 <syscalls+0x2c8>
    80005c14:	fb040513          	addi	a0,s0,-80
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	686080e7          	jalr	1670(ra) # 8000429e <namecmp>
    80005c20:	12050e63          	beqz	a0,80005d5c <sys_unlink+0x1b0>
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005c24:	f2c40613          	addi	a2,s0,-212
    80005c28:	fb040593          	addi	a1,s0,-80
    80005c2c:	8526                	mv	a0,s1
    80005c2e:	ffffe097          	auipc	ra,0xffffe
    80005c32:	68a080e7          	jalr	1674(ra) # 800042b8 <dirlookup>
    80005c36:	892a                	mv	s2,a0
    80005c38:	12050263          	beqz	a0,80005d5c <sys_unlink+0x1b0>
  ilock(ip);
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	198080e7          	jalr	408(ra) # 80003dd4 <ilock>
  if (ip->nlink < 1)
    80005c44:	04a91783          	lh	a5,74(s2)
    80005c48:	08f05263          	blez	a5,80005ccc <sys_unlink+0x120>
  if (ip->type == T_DIR && !isdirempty(ip))
    80005c4c:	04491703          	lh	a4,68(s2)
    80005c50:	4785                	li	a5,1
    80005c52:	08f70563          	beq	a4,a5,80005cdc <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005c56:	4641                	li	a2,16
    80005c58:	4581                	li	a1,0
    80005c5a:	fc040513          	addi	a0,s0,-64
    80005c5e:	ffffb097          	auipc	ra,0xffffb
    80005c62:	1e8080e7          	jalr	488(ra) # 80000e46 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c66:	4741                	li	a4,16
    80005c68:	f2c42683          	lw	a3,-212(s0)
    80005c6c:	fc040613          	addi	a2,s0,-64
    80005c70:	4581                	li	a1,0
    80005c72:	8526                	mv	a0,s1
    80005c74:	ffffe097          	auipc	ra,0xffffe
    80005c78:	50c080e7          	jalr	1292(ra) # 80004180 <writei>
    80005c7c:	47c1                	li	a5,16
    80005c7e:	0af51563          	bne	a0,a5,80005d28 <sys_unlink+0x17c>
  if (ip->type == T_DIR)
    80005c82:	04491703          	lh	a4,68(s2)
    80005c86:	4785                	li	a5,1
    80005c88:	0af70863          	beq	a4,a5,80005d38 <sys_unlink+0x18c>
  iunlockput(dp);
    80005c8c:	8526                	mv	a0,s1
    80005c8e:	ffffe097          	auipc	ra,0xffffe
    80005c92:	3a8080e7          	jalr	936(ra) # 80004036 <iunlockput>
  ip->nlink--;
    80005c96:	04a95783          	lhu	a5,74(s2)
    80005c9a:	37fd                	addiw	a5,a5,-1
    80005c9c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005ca0:	854a                	mv	a0,s2
    80005ca2:	ffffe097          	auipc	ra,0xffffe
    80005ca6:	066080e7          	jalr	102(ra) # 80003d08 <iupdate>
  iunlockput(ip);
    80005caa:	854a                	mv	a0,s2
    80005cac:	ffffe097          	auipc	ra,0xffffe
    80005cb0:	38a080e7          	jalr	906(ra) # 80004036 <iunlockput>
  end_op();
    80005cb4:	fffff097          	auipc	ra,0xfffff
    80005cb8:	b6a080e7          	jalr	-1174(ra) # 8000481e <end_op>
  return 0;
    80005cbc:	4501                	li	a0,0
    80005cbe:	a84d                	j	80005d70 <sys_unlink+0x1c4>
    end_op();
    80005cc0:	fffff097          	auipc	ra,0xfffff
    80005cc4:	b5e080e7          	jalr	-1186(ra) # 8000481e <end_op>
    return -1;
    80005cc8:	557d                	li	a0,-1
    80005cca:	a05d                	j	80005d70 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005ccc:	00003517          	auipc	a0,0x3
    80005cd0:	bc450513          	addi	a0,a0,-1084 # 80008890 <syscalls+0x2d0>
    80005cd4:	ffffb097          	auipc	ra,0xffffb
    80005cd8:	86c080e7          	jalr	-1940(ra) # 80000540 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005cdc:	04c92703          	lw	a4,76(s2)
    80005ce0:	02000793          	li	a5,32
    80005ce4:	f6e7f9e3          	bgeu	a5,a4,80005c56 <sys_unlink+0xaa>
    80005ce8:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005cec:	4741                	li	a4,16
    80005cee:	86ce                	mv	a3,s3
    80005cf0:	f1840613          	addi	a2,s0,-232
    80005cf4:	4581                	li	a1,0
    80005cf6:	854a                	mv	a0,s2
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	390080e7          	jalr	912(ra) # 80004088 <readi>
    80005d00:	47c1                	li	a5,16
    80005d02:	00f51b63          	bne	a0,a5,80005d18 <sys_unlink+0x16c>
    if (de.inum != 0)
    80005d06:	f1845783          	lhu	a5,-232(s0)
    80005d0a:	e7a1                	bnez	a5,80005d52 <sys_unlink+0x1a6>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005d0c:	29c1                	addiw	s3,s3,16
    80005d0e:	04c92783          	lw	a5,76(s2)
    80005d12:	fcf9ede3          	bltu	s3,a5,80005cec <sys_unlink+0x140>
    80005d16:	b781                	j	80005c56 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005d18:	00003517          	auipc	a0,0x3
    80005d1c:	b9050513          	addi	a0,a0,-1136 # 800088a8 <syscalls+0x2e8>
    80005d20:	ffffb097          	auipc	ra,0xffffb
    80005d24:	820080e7          	jalr	-2016(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005d28:	00003517          	auipc	a0,0x3
    80005d2c:	b9850513          	addi	a0,a0,-1128 # 800088c0 <syscalls+0x300>
    80005d30:	ffffb097          	auipc	ra,0xffffb
    80005d34:	810080e7          	jalr	-2032(ra) # 80000540 <panic>
    dp->nlink--;
    80005d38:	04a4d783          	lhu	a5,74(s1)
    80005d3c:	37fd                	addiw	a5,a5,-1
    80005d3e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005d42:	8526                	mv	a0,s1
    80005d44:	ffffe097          	auipc	ra,0xffffe
    80005d48:	fc4080e7          	jalr	-60(ra) # 80003d08 <iupdate>
    80005d4c:	b781                	j	80005c8c <sys_unlink+0xe0>
    return -1;
    80005d4e:	557d                	li	a0,-1
    80005d50:	a005                	j	80005d70 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005d52:	854a                	mv	a0,s2
    80005d54:	ffffe097          	auipc	ra,0xffffe
    80005d58:	2e2080e7          	jalr	738(ra) # 80004036 <iunlockput>
  iunlockput(dp);
    80005d5c:	8526                	mv	a0,s1
    80005d5e:	ffffe097          	auipc	ra,0xffffe
    80005d62:	2d8080e7          	jalr	728(ra) # 80004036 <iunlockput>
  end_op();
    80005d66:	fffff097          	auipc	ra,0xfffff
    80005d6a:	ab8080e7          	jalr	-1352(ra) # 8000481e <end_op>
  return -1;
    80005d6e:	557d                	li	a0,-1
}
    80005d70:	70ae                	ld	ra,232(sp)
    80005d72:	740e                	ld	s0,224(sp)
    80005d74:	64ee                	ld	s1,216(sp)
    80005d76:	694e                	ld	s2,208(sp)
    80005d78:	69ae                	ld	s3,200(sp)
    80005d7a:	616d                	addi	sp,sp,240
    80005d7c:	8082                	ret

0000000080005d7e <sys_open>:

uint64
sys_open(void)
{
    80005d7e:	7131                	addi	sp,sp,-192
    80005d80:	fd06                	sd	ra,184(sp)
    80005d82:	f922                	sd	s0,176(sp)
    80005d84:	f526                	sd	s1,168(sp)
    80005d86:	f14a                	sd	s2,160(sp)
    80005d88:	ed4e                	sd	s3,152(sp)
    80005d8a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005d8c:	f4c40593          	addi	a1,s0,-180
    80005d90:	4505                	li	a0,1
    80005d92:	ffffd097          	auipc	ra,0xffffd
    80005d96:	2e2080e7          	jalr	738(ra) # 80003074 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005d9a:	08000613          	li	a2,128
    80005d9e:	f5040593          	addi	a1,s0,-176
    80005da2:	4501                	li	a0,0
    80005da4:	ffffd097          	auipc	ra,0xffffd
    80005da8:	310080e7          	jalr	784(ra) # 800030b4 <argstr>
    80005dac:	87aa                	mv	a5,a0
    return -1;
    80005dae:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005db0:	0a07c963          	bltz	a5,80005e62 <sys_open+0xe4>

  begin_op();
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	9ec080e7          	jalr	-1556(ra) # 800047a0 <begin_op>

  if (omode & O_CREATE)
    80005dbc:	f4c42783          	lw	a5,-180(s0)
    80005dc0:	2007f793          	andi	a5,a5,512
    80005dc4:	cfc5                	beqz	a5,80005e7c <sys_open+0xfe>
  {
    ip = create(path, T_FILE, 0, 0);
    80005dc6:	4681                	li	a3,0
    80005dc8:	4601                	li	a2,0
    80005dca:	4589                	li	a1,2
    80005dcc:	f5040513          	addi	a0,s0,-176
    80005dd0:	00000097          	auipc	ra,0x0
    80005dd4:	972080e7          	jalr	-1678(ra) # 80005742 <create>
    80005dd8:	84aa                	mv	s1,a0
    if (ip == 0)
    80005dda:	c959                	beqz	a0,80005e70 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV))
    80005ddc:	04449703          	lh	a4,68(s1)
    80005de0:	478d                	li	a5,3
    80005de2:	00f71763          	bne	a4,a5,80005df0 <sys_open+0x72>
    80005de6:	0464d703          	lhu	a4,70(s1)
    80005dea:	47a5                	li	a5,9
    80005dec:	0ce7ed63          	bltu	a5,a4,80005ec6 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0)
    80005df0:	fffff097          	auipc	ra,0xfffff
    80005df4:	dbc080e7          	jalr	-580(ra) # 80004bac <filealloc>
    80005df8:	89aa                	mv	s3,a0
    80005dfa:	10050363          	beqz	a0,80005f00 <sys_open+0x182>
    80005dfe:	00000097          	auipc	ra,0x0
    80005e02:	902080e7          	jalr	-1790(ra) # 80005700 <fdalloc>
    80005e06:	892a                	mv	s2,a0
    80005e08:	0e054763          	bltz	a0,80005ef6 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE)
    80005e0c:	04449703          	lh	a4,68(s1)
    80005e10:	478d                	li	a5,3
    80005e12:	0cf70563          	beq	a4,a5,80005edc <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  }
  else
  {
    f->type = FD_INODE;
    80005e16:	4789                	li	a5,2
    80005e18:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005e1c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005e20:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005e24:	f4c42783          	lw	a5,-180(s0)
    80005e28:	0017c713          	xori	a4,a5,1
    80005e2c:	8b05                	andi	a4,a4,1
    80005e2e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005e32:	0037f713          	andi	a4,a5,3
    80005e36:	00e03733          	snez	a4,a4
    80005e3a:	00e984a3          	sb	a4,9(s3)

  if ((omode & O_TRUNC) && ip->type == T_FILE)
    80005e3e:	4007f793          	andi	a5,a5,1024
    80005e42:	c791                	beqz	a5,80005e4e <sys_open+0xd0>
    80005e44:	04449703          	lh	a4,68(s1)
    80005e48:	4789                	li	a5,2
    80005e4a:	0af70063          	beq	a4,a5,80005eea <sys_open+0x16c>
  {
    itrunc(ip);
  }

  iunlock(ip);
    80005e4e:	8526                	mv	a0,s1
    80005e50:	ffffe097          	auipc	ra,0xffffe
    80005e54:	046080e7          	jalr	70(ra) # 80003e96 <iunlock>
  end_op();
    80005e58:	fffff097          	auipc	ra,0xfffff
    80005e5c:	9c6080e7          	jalr	-1594(ra) # 8000481e <end_op>

  return fd;
    80005e60:	854a                	mv	a0,s2
}
    80005e62:	70ea                	ld	ra,184(sp)
    80005e64:	744a                	ld	s0,176(sp)
    80005e66:	74aa                	ld	s1,168(sp)
    80005e68:	790a                	ld	s2,160(sp)
    80005e6a:	69ea                	ld	s3,152(sp)
    80005e6c:	6129                	addi	sp,sp,192
    80005e6e:	8082                	ret
      end_op();
    80005e70:	fffff097          	auipc	ra,0xfffff
    80005e74:	9ae080e7          	jalr	-1618(ra) # 8000481e <end_op>
      return -1;
    80005e78:	557d                	li	a0,-1
    80005e7a:	b7e5                	j	80005e62 <sys_open+0xe4>
    if ((ip = namei(path)) == 0)
    80005e7c:	f5040513          	addi	a0,s0,-176
    80005e80:	ffffe097          	auipc	ra,0xffffe
    80005e84:	700080e7          	jalr	1792(ra) # 80004580 <namei>
    80005e88:	84aa                	mv	s1,a0
    80005e8a:	c905                	beqz	a0,80005eba <sys_open+0x13c>
    ilock(ip);
    80005e8c:	ffffe097          	auipc	ra,0xffffe
    80005e90:	f48080e7          	jalr	-184(ra) # 80003dd4 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY)
    80005e94:	04449703          	lh	a4,68(s1)
    80005e98:	4785                	li	a5,1
    80005e9a:	f4f711e3          	bne	a4,a5,80005ddc <sys_open+0x5e>
    80005e9e:	f4c42783          	lw	a5,-180(s0)
    80005ea2:	d7b9                	beqz	a5,80005df0 <sys_open+0x72>
      iunlockput(ip);
    80005ea4:	8526                	mv	a0,s1
    80005ea6:	ffffe097          	auipc	ra,0xffffe
    80005eaa:	190080e7          	jalr	400(ra) # 80004036 <iunlockput>
      end_op();
    80005eae:	fffff097          	auipc	ra,0xfffff
    80005eb2:	970080e7          	jalr	-1680(ra) # 8000481e <end_op>
      return -1;
    80005eb6:	557d                	li	a0,-1
    80005eb8:	b76d                	j	80005e62 <sys_open+0xe4>
      end_op();
    80005eba:	fffff097          	auipc	ra,0xfffff
    80005ebe:	964080e7          	jalr	-1692(ra) # 8000481e <end_op>
      return -1;
    80005ec2:	557d                	li	a0,-1
    80005ec4:	bf79                	j	80005e62 <sys_open+0xe4>
    iunlockput(ip);
    80005ec6:	8526                	mv	a0,s1
    80005ec8:	ffffe097          	auipc	ra,0xffffe
    80005ecc:	16e080e7          	jalr	366(ra) # 80004036 <iunlockput>
    end_op();
    80005ed0:	fffff097          	auipc	ra,0xfffff
    80005ed4:	94e080e7          	jalr	-1714(ra) # 8000481e <end_op>
    return -1;
    80005ed8:	557d                	li	a0,-1
    80005eda:	b761                	j	80005e62 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005edc:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ee0:	04649783          	lh	a5,70(s1)
    80005ee4:	02f99223          	sh	a5,36(s3)
    80005ee8:	bf25                	j	80005e20 <sys_open+0xa2>
    itrunc(ip);
    80005eea:	8526                	mv	a0,s1
    80005eec:	ffffe097          	auipc	ra,0xffffe
    80005ef0:	ff6080e7          	jalr	-10(ra) # 80003ee2 <itrunc>
    80005ef4:	bfa9                	j	80005e4e <sys_open+0xd0>
      fileclose(f);
    80005ef6:	854e                	mv	a0,s3
    80005ef8:	fffff097          	auipc	ra,0xfffff
    80005efc:	d70080e7          	jalr	-656(ra) # 80004c68 <fileclose>
    iunlockput(ip);
    80005f00:	8526                	mv	a0,s1
    80005f02:	ffffe097          	auipc	ra,0xffffe
    80005f06:	134080e7          	jalr	308(ra) # 80004036 <iunlockput>
    end_op();
    80005f0a:	fffff097          	auipc	ra,0xfffff
    80005f0e:	914080e7          	jalr	-1772(ra) # 8000481e <end_op>
    return -1;
    80005f12:	557d                	li	a0,-1
    80005f14:	b7b9                	j	80005e62 <sys_open+0xe4>

0000000080005f16 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005f16:	7175                	addi	sp,sp,-144
    80005f18:	e506                	sd	ra,136(sp)
    80005f1a:	e122                	sd	s0,128(sp)
    80005f1c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005f1e:	fffff097          	auipc	ra,0xfffff
    80005f22:	882080e7          	jalr	-1918(ra) # 800047a0 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
    80005f26:	08000613          	li	a2,128
    80005f2a:	f7040593          	addi	a1,s0,-144
    80005f2e:	4501                	li	a0,0
    80005f30:	ffffd097          	auipc	ra,0xffffd
    80005f34:	184080e7          	jalr	388(ra) # 800030b4 <argstr>
    80005f38:	02054963          	bltz	a0,80005f6a <sys_mkdir+0x54>
    80005f3c:	4681                	li	a3,0
    80005f3e:	4601                	li	a2,0
    80005f40:	4585                	li	a1,1
    80005f42:	f7040513          	addi	a0,s0,-144
    80005f46:	fffff097          	auipc	ra,0xfffff
    80005f4a:	7fc080e7          	jalr	2044(ra) # 80005742 <create>
    80005f4e:	cd11                	beqz	a0,80005f6a <sys_mkdir+0x54>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f50:	ffffe097          	auipc	ra,0xffffe
    80005f54:	0e6080e7          	jalr	230(ra) # 80004036 <iunlockput>
  end_op();
    80005f58:	fffff097          	auipc	ra,0xfffff
    80005f5c:	8c6080e7          	jalr	-1850(ra) # 8000481e <end_op>
  return 0;
    80005f60:	4501                	li	a0,0
}
    80005f62:	60aa                	ld	ra,136(sp)
    80005f64:	640a                	ld	s0,128(sp)
    80005f66:	6149                	addi	sp,sp,144
    80005f68:	8082                	ret
    end_op();
    80005f6a:	fffff097          	auipc	ra,0xfffff
    80005f6e:	8b4080e7          	jalr	-1868(ra) # 8000481e <end_op>
    return -1;
    80005f72:	557d                	li	a0,-1
    80005f74:	b7fd                	j	80005f62 <sys_mkdir+0x4c>

0000000080005f76 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f76:	7135                	addi	sp,sp,-160
    80005f78:	ed06                	sd	ra,152(sp)
    80005f7a:	e922                	sd	s0,144(sp)
    80005f7c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f7e:	fffff097          	auipc	ra,0xfffff
    80005f82:	822080e7          	jalr	-2014(ra) # 800047a0 <begin_op>
  argint(1, &major);
    80005f86:	f6c40593          	addi	a1,s0,-148
    80005f8a:	4505                	li	a0,1
    80005f8c:	ffffd097          	auipc	ra,0xffffd
    80005f90:	0e8080e7          	jalr	232(ra) # 80003074 <argint>
  argint(2, &minor);
    80005f94:	f6840593          	addi	a1,s0,-152
    80005f98:	4509                	li	a0,2
    80005f9a:	ffffd097          	auipc	ra,0xffffd
    80005f9e:	0da080e7          	jalr	218(ra) # 80003074 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005fa2:	08000613          	li	a2,128
    80005fa6:	f7040593          	addi	a1,s0,-144
    80005faa:	4501                	li	a0,0
    80005fac:	ffffd097          	auipc	ra,0xffffd
    80005fb0:	108080e7          	jalr	264(ra) # 800030b4 <argstr>
    80005fb4:	02054b63          	bltz	a0,80005fea <sys_mknod+0x74>
      (ip = create(path, T_DEVICE, major, minor)) == 0)
    80005fb8:	f6841683          	lh	a3,-152(s0)
    80005fbc:	f6c41603          	lh	a2,-148(s0)
    80005fc0:	458d                	li	a1,3
    80005fc2:	f7040513          	addi	a0,s0,-144
    80005fc6:	fffff097          	auipc	ra,0xfffff
    80005fca:	77c080e7          	jalr	1916(ra) # 80005742 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005fce:	cd11                	beqz	a0,80005fea <sys_mknod+0x74>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005fd0:	ffffe097          	auipc	ra,0xffffe
    80005fd4:	066080e7          	jalr	102(ra) # 80004036 <iunlockput>
  end_op();
    80005fd8:	fffff097          	auipc	ra,0xfffff
    80005fdc:	846080e7          	jalr	-1978(ra) # 8000481e <end_op>
  return 0;
    80005fe0:	4501                	li	a0,0
}
    80005fe2:	60ea                	ld	ra,152(sp)
    80005fe4:	644a                	ld	s0,144(sp)
    80005fe6:	610d                	addi	sp,sp,160
    80005fe8:	8082                	ret
    end_op();
    80005fea:	fffff097          	auipc	ra,0xfffff
    80005fee:	834080e7          	jalr	-1996(ra) # 8000481e <end_op>
    return -1;
    80005ff2:	557d                	li	a0,-1
    80005ff4:	b7fd                	j	80005fe2 <sys_mknod+0x6c>

0000000080005ff6 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ff6:	7135                	addi	sp,sp,-160
    80005ff8:	ed06                	sd	ra,152(sp)
    80005ffa:	e922                	sd	s0,144(sp)
    80005ffc:	e526                	sd	s1,136(sp)
    80005ffe:	e14a                	sd	s2,128(sp)
    80006000:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006002:	ffffc097          	auipc	ra,0xffffc
    80006006:	b5a080e7          	jalr	-1190(ra) # 80001b5c <myproc>
    8000600a:	892a                	mv	s2,a0

  begin_op();
    8000600c:	ffffe097          	auipc	ra,0xffffe
    80006010:	794080e7          	jalr	1940(ra) # 800047a0 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0)
    80006014:	08000613          	li	a2,128
    80006018:	f6040593          	addi	a1,s0,-160
    8000601c:	4501                	li	a0,0
    8000601e:	ffffd097          	auipc	ra,0xffffd
    80006022:	096080e7          	jalr	150(ra) # 800030b4 <argstr>
    80006026:	04054b63          	bltz	a0,8000607c <sys_chdir+0x86>
    8000602a:	f6040513          	addi	a0,s0,-160
    8000602e:	ffffe097          	auipc	ra,0xffffe
    80006032:	552080e7          	jalr	1362(ra) # 80004580 <namei>
    80006036:	84aa                	mv	s1,a0
    80006038:	c131                	beqz	a0,8000607c <sys_chdir+0x86>
  {
    end_op();
    return -1;
  }
  ilock(ip);
    8000603a:	ffffe097          	auipc	ra,0xffffe
    8000603e:	d9a080e7          	jalr	-614(ra) # 80003dd4 <ilock>
  if (ip->type != T_DIR)
    80006042:	04449703          	lh	a4,68(s1)
    80006046:	4785                	li	a5,1
    80006048:	04f71063          	bne	a4,a5,80006088 <sys_chdir+0x92>
  {
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000604c:	8526                	mv	a0,s1
    8000604e:	ffffe097          	auipc	ra,0xffffe
    80006052:	e48080e7          	jalr	-440(ra) # 80003e96 <iunlock>
  iput(p->cwd);
    80006056:	15093503          	ld	a0,336(s2)
    8000605a:	ffffe097          	auipc	ra,0xffffe
    8000605e:	f34080e7          	jalr	-204(ra) # 80003f8e <iput>
  end_op();
    80006062:	ffffe097          	auipc	ra,0xffffe
    80006066:	7bc080e7          	jalr	1980(ra) # 8000481e <end_op>
  p->cwd = ip;
    8000606a:	14993823          	sd	s1,336(s2)
  return 0;
    8000606e:	4501                	li	a0,0
}
    80006070:	60ea                	ld	ra,152(sp)
    80006072:	644a                	ld	s0,144(sp)
    80006074:	64aa                	ld	s1,136(sp)
    80006076:	690a                	ld	s2,128(sp)
    80006078:	610d                	addi	sp,sp,160
    8000607a:	8082                	ret
    end_op();
    8000607c:	ffffe097          	auipc	ra,0xffffe
    80006080:	7a2080e7          	jalr	1954(ra) # 8000481e <end_op>
    return -1;
    80006084:	557d                	li	a0,-1
    80006086:	b7ed                	j	80006070 <sys_chdir+0x7a>
    iunlockput(ip);
    80006088:	8526                	mv	a0,s1
    8000608a:	ffffe097          	auipc	ra,0xffffe
    8000608e:	fac080e7          	jalr	-84(ra) # 80004036 <iunlockput>
    end_op();
    80006092:	ffffe097          	auipc	ra,0xffffe
    80006096:	78c080e7          	jalr	1932(ra) # 8000481e <end_op>
    return -1;
    8000609a:	557d                	li	a0,-1
    8000609c:	bfd1                	j	80006070 <sys_chdir+0x7a>

000000008000609e <sys_exec>:

uint64
sys_exec(void)
{
    8000609e:	7145                	addi	sp,sp,-464
    800060a0:	e786                	sd	ra,456(sp)
    800060a2:	e3a2                	sd	s0,448(sp)
    800060a4:	ff26                	sd	s1,440(sp)
    800060a6:	fb4a                	sd	s2,432(sp)
    800060a8:	f74e                	sd	s3,424(sp)
    800060aa:	f352                	sd	s4,416(sp)
    800060ac:	ef56                	sd	s5,408(sp)
    800060ae:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800060b0:	e3840593          	addi	a1,s0,-456
    800060b4:	4505                	li	a0,1
    800060b6:	ffffd097          	auipc	ra,0xffffd
    800060ba:	fde080e7          	jalr	-34(ra) # 80003094 <argaddr>
  if (argstr(0, path, MAXPATH) < 0)
    800060be:	08000613          	li	a2,128
    800060c2:	f4040593          	addi	a1,s0,-192
    800060c6:	4501                	li	a0,0
    800060c8:	ffffd097          	auipc	ra,0xffffd
    800060cc:	fec080e7          	jalr	-20(ra) # 800030b4 <argstr>
    800060d0:	87aa                	mv	a5,a0
  {
    return -1;
    800060d2:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0)
    800060d4:	0c07c363          	bltz	a5,8000619a <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800060d8:	10000613          	li	a2,256
    800060dc:	4581                	li	a1,0
    800060de:	e4040513          	addi	a0,s0,-448
    800060e2:	ffffb097          	auipc	ra,0xffffb
    800060e6:	d64080e7          	jalr	-668(ra) # 80000e46 <memset>
  for (i = 0;; i++)
  {
    if (i >= NELEM(argv))
    800060ea:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800060ee:	89a6                	mv	s3,s1
    800060f0:	4901                	li	s2,0
    if (i >= NELEM(argv))
    800060f2:	02000a13          	li	s4,32
    800060f6:	00090a9b          	sext.w	s5,s2
    {
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0)
    800060fa:	00391513          	slli	a0,s2,0x3
    800060fe:	e3040593          	addi	a1,s0,-464
    80006102:	e3843783          	ld	a5,-456(s0)
    80006106:	953e                	add	a0,a0,a5
    80006108:	ffffd097          	auipc	ra,0xffffd
    8000610c:	ece080e7          	jalr	-306(ra) # 80002fd6 <fetchaddr>
    80006110:	02054a63          	bltz	a0,80006144 <sys_exec+0xa6>
    {
      goto bad;
    }
    if (uarg == 0)
    80006114:	e3043783          	ld	a5,-464(s0)
    80006118:	c3b9                	beqz	a5,8000615e <sys_exec+0xc0>
    {
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000611a:	ffffb097          	auipc	ra,0xffffb
    8000611e:	b36080e7          	jalr	-1226(ra) # 80000c50 <kalloc>
    80006122:	85aa                	mv	a1,a0
    80006124:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80006128:	cd11                	beqz	a0,80006144 <sys_exec+0xa6>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000612a:	6605                	lui	a2,0x1
    8000612c:	e3043503          	ld	a0,-464(s0)
    80006130:	ffffd097          	auipc	ra,0xffffd
    80006134:	ef8080e7          	jalr	-264(ra) # 80003028 <fetchstr>
    80006138:	00054663          	bltz	a0,80006144 <sys_exec+0xa6>
    if (i >= NELEM(argv))
    8000613c:	0905                	addi	s2,s2,1
    8000613e:	09a1                	addi	s3,s3,8
    80006140:	fb491be3          	bne	s2,s4,800060f6 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006144:	f4040913          	addi	s2,s0,-192
    80006148:	6088                	ld	a0,0(s1)
    8000614a:	c539                	beqz	a0,80006198 <sys_exec+0xfa>
    kfree(argv[i]);
    8000614c:	ffffb097          	auipc	ra,0xffffb
    80006150:	92c080e7          	jalr	-1748(ra) # 80000a78 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006154:	04a1                	addi	s1,s1,8
    80006156:	ff2499e3          	bne	s1,s2,80006148 <sys_exec+0xaa>
  return -1;
    8000615a:	557d                	li	a0,-1
    8000615c:	a83d                	j	8000619a <sys_exec+0xfc>
      argv[i] = 0;
    8000615e:	0a8e                	slli	s5,s5,0x3
    80006160:	fc0a8793          	addi	a5,s5,-64
    80006164:	00878ab3          	add	s5,a5,s0
    80006168:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000616c:	e4040593          	addi	a1,s0,-448
    80006170:	f4040513          	addi	a0,s0,-192
    80006174:	fffff097          	auipc	ra,0xfffff
    80006178:	16e080e7          	jalr	366(ra) # 800052e2 <exec>
    8000617c:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000617e:	f4040993          	addi	s3,s0,-192
    80006182:	6088                	ld	a0,0(s1)
    80006184:	c901                	beqz	a0,80006194 <sys_exec+0xf6>
    kfree(argv[i]);
    80006186:	ffffb097          	auipc	ra,0xffffb
    8000618a:	8f2080e7          	jalr	-1806(ra) # 80000a78 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000618e:	04a1                	addi	s1,s1,8
    80006190:	ff3499e3          	bne	s1,s3,80006182 <sys_exec+0xe4>
  return ret;
    80006194:	854a                	mv	a0,s2
    80006196:	a011                	j	8000619a <sys_exec+0xfc>
  return -1;
    80006198:	557d                	li	a0,-1
}
    8000619a:	60be                	ld	ra,456(sp)
    8000619c:	641e                	ld	s0,448(sp)
    8000619e:	74fa                	ld	s1,440(sp)
    800061a0:	795a                	ld	s2,432(sp)
    800061a2:	79ba                	ld	s3,424(sp)
    800061a4:	7a1a                	ld	s4,416(sp)
    800061a6:	6afa                	ld	s5,408(sp)
    800061a8:	6179                	addi	sp,sp,464
    800061aa:	8082                	ret

00000000800061ac <sys_pipe>:

uint64
sys_pipe(void)
{
    800061ac:	7139                	addi	sp,sp,-64
    800061ae:	fc06                	sd	ra,56(sp)
    800061b0:	f822                	sd	s0,48(sp)
    800061b2:	f426                	sd	s1,40(sp)
    800061b4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800061b6:	ffffc097          	auipc	ra,0xffffc
    800061ba:	9a6080e7          	jalr	-1626(ra) # 80001b5c <myproc>
    800061be:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800061c0:	fd840593          	addi	a1,s0,-40
    800061c4:	4501                	li	a0,0
    800061c6:	ffffd097          	auipc	ra,0xffffd
    800061ca:	ece080e7          	jalr	-306(ra) # 80003094 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800061ce:	fc840593          	addi	a1,s0,-56
    800061d2:	fd040513          	addi	a0,s0,-48
    800061d6:	fffff097          	auipc	ra,0xfffff
    800061da:	dc2080e7          	jalr	-574(ra) # 80004f98 <pipealloc>
    return -1;
    800061de:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800061e0:	0c054463          	bltz	a0,800062a8 <sys_pipe+0xfc>
  fd0 = -1;
    800061e4:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0)
    800061e8:	fd043503          	ld	a0,-48(s0)
    800061ec:	fffff097          	auipc	ra,0xfffff
    800061f0:	514080e7          	jalr	1300(ra) # 80005700 <fdalloc>
    800061f4:	fca42223          	sw	a0,-60(s0)
    800061f8:	08054b63          	bltz	a0,8000628e <sys_pipe+0xe2>
    800061fc:	fc843503          	ld	a0,-56(s0)
    80006200:	fffff097          	auipc	ra,0xfffff
    80006204:	500080e7          	jalr	1280(ra) # 80005700 <fdalloc>
    80006208:	fca42023          	sw	a0,-64(s0)
    8000620c:	06054863          	bltz	a0,8000627c <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80006210:	4691                	li	a3,4
    80006212:	fc440613          	addi	a2,s0,-60
    80006216:	fd843583          	ld	a1,-40(s0)
    8000621a:	68a8                	ld	a0,80(s1)
    8000621c:	ffffb097          	auipc	ra,0xffffb
    80006220:	5c4080e7          	jalr	1476(ra) # 800017e0 <copyout>
    80006224:	02054063          	bltz	a0,80006244 <sys_pipe+0x98>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0)
    80006228:	4691                	li	a3,4
    8000622a:	fc040613          	addi	a2,s0,-64
    8000622e:	fd843583          	ld	a1,-40(s0)
    80006232:	0591                	addi	a1,a1,4
    80006234:	68a8                	ld	a0,80(s1)
    80006236:	ffffb097          	auipc	ra,0xffffb
    8000623a:	5aa080e7          	jalr	1450(ra) # 800017e0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000623e:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80006240:	06055463          	bgez	a0,800062a8 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006244:	fc442783          	lw	a5,-60(s0)
    80006248:	07e9                	addi	a5,a5,26
    8000624a:	078e                	slli	a5,a5,0x3
    8000624c:	97a6                	add	a5,a5,s1
    8000624e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006252:	fc042783          	lw	a5,-64(s0)
    80006256:	07e9                	addi	a5,a5,26
    80006258:	078e                	slli	a5,a5,0x3
    8000625a:	94be                	add	s1,s1,a5
    8000625c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006260:	fd043503          	ld	a0,-48(s0)
    80006264:	fffff097          	auipc	ra,0xfffff
    80006268:	a04080e7          	jalr	-1532(ra) # 80004c68 <fileclose>
    fileclose(wf);
    8000626c:	fc843503          	ld	a0,-56(s0)
    80006270:	fffff097          	auipc	ra,0xfffff
    80006274:	9f8080e7          	jalr	-1544(ra) # 80004c68 <fileclose>
    return -1;
    80006278:	57fd                	li	a5,-1
    8000627a:	a03d                	j	800062a8 <sys_pipe+0xfc>
    if (fd0 >= 0)
    8000627c:	fc442783          	lw	a5,-60(s0)
    80006280:	0007c763          	bltz	a5,8000628e <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006284:	07e9                	addi	a5,a5,26
    80006286:	078e                	slli	a5,a5,0x3
    80006288:	97a6                	add	a5,a5,s1
    8000628a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000628e:	fd043503          	ld	a0,-48(s0)
    80006292:	fffff097          	auipc	ra,0xfffff
    80006296:	9d6080e7          	jalr	-1578(ra) # 80004c68 <fileclose>
    fileclose(wf);
    8000629a:	fc843503          	ld	a0,-56(s0)
    8000629e:	fffff097          	auipc	ra,0xfffff
    800062a2:	9ca080e7          	jalr	-1590(ra) # 80004c68 <fileclose>
    return -1;
    800062a6:	57fd                	li	a5,-1
}
    800062a8:	853e                	mv	a0,a5
    800062aa:	70e2                	ld	ra,56(sp)
    800062ac:	7442                	ld	s0,48(sp)
    800062ae:	74a2                	ld	s1,40(sp)
    800062b0:	6121                	addi	sp,sp,64
    800062b2:	8082                	ret
	...

00000000800062c0 <kernelvec>:
    800062c0:	7111                	addi	sp,sp,-256
    800062c2:	e006                	sd	ra,0(sp)
    800062c4:	e40a                	sd	sp,8(sp)
    800062c6:	e80e                	sd	gp,16(sp)
    800062c8:	ec12                	sd	tp,24(sp)
    800062ca:	f016                	sd	t0,32(sp)
    800062cc:	f41a                	sd	t1,40(sp)
    800062ce:	f81e                	sd	t2,48(sp)
    800062d0:	fc22                	sd	s0,56(sp)
    800062d2:	e0a6                	sd	s1,64(sp)
    800062d4:	e4aa                	sd	a0,72(sp)
    800062d6:	e8ae                	sd	a1,80(sp)
    800062d8:	ecb2                	sd	a2,88(sp)
    800062da:	f0b6                	sd	a3,96(sp)
    800062dc:	f4ba                	sd	a4,104(sp)
    800062de:	f8be                	sd	a5,112(sp)
    800062e0:	fcc2                	sd	a6,120(sp)
    800062e2:	e146                	sd	a7,128(sp)
    800062e4:	e54a                	sd	s2,136(sp)
    800062e6:	e94e                	sd	s3,144(sp)
    800062e8:	ed52                	sd	s4,152(sp)
    800062ea:	f156                	sd	s5,160(sp)
    800062ec:	f55a                	sd	s6,168(sp)
    800062ee:	f95e                	sd	s7,176(sp)
    800062f0:	fd62                	sd	s8,184(sp)
    800062f2:	e1e6                	sd	s9,192(sp)
    800062f4:	e5ea                	sd	s10,200(sp)
    800062f6:	e9ee                	sd	s11,208(sp)
    800062f8:	edf2                	sd	t3,216(sp)
    800062fa:	f1f6                	sd	t4,224(sp)
    800062fc:	f5fa                	sd	t5,232(sp)
    800062fe:	f9fe                	sd	t6,240(sp)
    80006300:	965fc0ef          	jal	ra,80002c64 <kerneltrap>
    80006304:	6082                	ld	ra,0(sp)
    80006306:	6122                	ld	sp,8(sp)
    80006308:	61c2                	ld	gp,16(sp)
    8000630a:	7282                	ld	t0,32(sp)
    8000630c:	7322                	ld	t1,40(sp)
    8000630e:	73c2                	ld	t2,48(sp)
    80006310:	7462                	ld	s0,56(sp)
    80006312:	6486                	ld	s1,64(sp)
    80006314:	6526                	ld	a0,72(sp)
    80006316:	65c6                	ld	a1,80(sp)
    80006318:	6666                	ld	a2,88(sp)
    8000631a:	7686                	ld	a3,96(sp)
    8000631c:	7726                	ld	a4,104(sp)
    8000631e:	77c6                	ld	a5,112(sp)
    80006320:	7866                	ld	a6,120(sp)
    80006322:	688a                	ld	a7,128(sp)
    80006324:	692a                	ld	s2,136(sp)
    80006326:	69ca                	ld	s3,144(sp)
    80006328:	6a6a                	ld	s4,152(sp)
    8000632a:	7a8a                	ld	s5,160(sp)
    8000632c:	7b2a                	ld	s6,168(sp)
    8000632e:	7bca                	ld	s7,176(sp)
    80006330:	7c6a                	ld	s8,184(sp)
    80006332:	6c8e                	ld	s9,192(sp)
    80006334:	6d2e                	ld	s10,200(sp)
    80006336:	6dce                	ld	s11,208(sp)
    80006338:	6e6e                	ld	t3,216(sp)
    8000633a:	7e8e                	ld	t4,224(sp)
    8000633c:	7f2e                	ld	t5,232(sp)
    8000633e:	7fce                	ld	t6,240(sp)
    80006340:	6111                	addi	sp,sp,256
    80006342:	10200073          	sret
    80006346:	00000013          	nop
    8000634a:	00000013          	nop
    8000634e:	0001                	nop

0000000080006350 <timervec>:
    80006350:	34051573          	csrrw	a0,mscratch,a0
    80006354:	e10c                	sd	a1,0(a0)
    80006356:	e510                	sd	a2,8(a0)
    80006358:	e914                	sd	a3,16(a0)
    8000635a:	6d0c                	ld	a1,24(a0)
    8000635c:	7110                	ld	a2,32(a0)
    8000635e:	6194                	ld	a3,0(a1)
    80006360:	96b2                	add	a3,a3,a2
    80006362:	e194                	sd	a3,0(a1)
    80006364:	4589                	li	a1,2
    80006366:	14459073          	csrw	sip,a1
    8000636a:	6914                	ld	a3,16(a0)
    8000636c:	6510                	ld	a2,8(a0)
    8000636e:	610c                	ld	a1,0(a0)
    80006370:	34051573          	csrrw	a0,mscratch,a0
    80006374:	30200073          	mret
	...

000000008000637a <plicinit>:
//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void)
{
    8000637a:	1141                	addi	sp,sp,-16
    8000637c:	e422                	sd	s0,8(sp)
    8000637e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80006380:	0c0007b7          	lui	a5,0xc000
    80006384:	4705                	li	a4,1
    80006386:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80006388:	c3d8                	sw	a4,4(a5)
}
    8000638a:	6422                	ld	s0,8(sp)
    8000638c:	0141                	addi	sp,sp,16
    8000638e:	8082                	ret

0000000080006390 <plicinithart>:

void plicinithart(void)
{
    80006390:	1141                	addi	sp,sp,-16
    80006392:	e406                	sd	ra,8(sp)
    80006394:	e022                	sd	s0,0(sp)
    80006396:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006398:	ffffb097          	auipc	ra,0xffffb
    8000639c:	798080e7          	jalr	1944(ra) # 80001b30 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800063a0:	0085171b          	slliw	a4,a0,0x8
    800063a4:	0c0027b7          	lui	a5,0xc002
    800063a8:	97ba                	add	a5,a5,a4
    800063aa:	40200713          	li	a4,1026
    800063ae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    800063b2:	00d5151b          	slliw	a0,a0,0xd
    800063b6:	0c2017b7          	lui	a5,0xc201
    800063ba:	97aa                	add	a5,a5,a0
    800063bc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800063c0:	60a2                	ld	ra,8(sp)
    800063c2:	6402                	ld	s0,0(sp)
    800063c4:	0141                	addi	sp,sp,16
    800063c6:	8082                	ret

00000000800063c8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void)
{
    800063c8:	1141                	addi	sp,sp,-16
    800063ca:	e406                	sd	ra,8(sp)
    800063cc:	e022                	sd	s0,0(sp)
    800063ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800063d0:	ffffb097          	auipc	ra,0xffffb
    800063d4:	760080e7          	jalr	1888(ra) # 80001b30 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    800063d8:	00d5151b          	slliw	a0,a0,0xd
    800063dc:	0c2017b7          	lui	a5,0xc201
    800063e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800063e2:	43c8                	lw	a0,4(a5)
    800063e4:	60a2                	ld	ra,8(sp)
    800063e6:	6402                	ld	s0,0(sp)
    800063e8:	0141                	addi	sp,sp,16
    800063ea:	8082                	ret

00000000800063ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq)
{
    800063ec:	1101                	addi	sp,sp,-32
    800063ee:	ec06                	sd	ra,24(sp)
    800063f0:	e822                	sd	s0,16(sp)
    800063f2:	e426                	sd	s1,8(sp)
    800063f4:	1000                	addi	s0,sp,32
    800063f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800063f8:	ffffb097          	auipc	ra,0xffffb
    800063fc:	738080e7          	jalr	1848(ra) # 80001b30 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80006400:	00d5151b          	slliw	a0,a0,0xd
    80006404:	0c2017b7          	lui	a5,0xc201
    80006408:	97aa                	add	a5,a5,a0
    8000640a:	c3c4                	sw	s1,4(a5)
}
    8000640c:	60e2                	ld	ra,24(sp)
    8000640e:	6442                	ld	s0,16(sp)
    80006410:	64a2                	ld	s1,8(sp)
    80006412:	6105                	addi	sp,sp,32
    80006414:	8082                	ret

0000000080006416 <sgenrand>:
static unsigned long mt[N]; /* the array for the state vector  */
static int mti = N + 1;     /* mti==N+1 means mt[N] is not initialized */

/* initializing the array with a NONZERO seed */
void sgenrand(unsigned long seed)
{
    80006416:	1141                	addi	sp,sp,-16
    80006418:	e422                	sd	s0,8(sp)
    8000641a:	0800                	addi	s0,sp,16
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0] = seed & 0xffffffff;
    8000641c:	0023e717          	auipc	a4,0x23e
    80006420:	cc470713          	addi	a4,a4,-828 # 802440e0 <mt>
    80006424:	1502                	slli	a0,a0,0x20
    80006426:	9101                	srli	a0,a0,0x20
    80006428:	e308                	sd	a0,0(a4)
    for (mti = 1; mti < N; mti++)
    8000642a:	0023f597          	auipc	a1,0x23f
    8000642e:	02e58593          	addi	a1,a1,46 # 80245458 <mt+0x1378>
        mt[mti] = (69069 * mt[mti - 1]) & 0xffffffff;
    80006432:	6645                	lui	a2,0x11
    80006434:	dcd60613          	addi	a2,a2,-563 # 10dcd <_entry-0x7ffef233>
    80006438:	56fd                	li	a3,-1
    8000643a:	9281                	srli	a3,a3,0x20
    8000643c:	631c                	ld	a5,0(a4)
    8000643e:	02c787b3          	mul	a5,a5,a2
    80006442:	8ff5                	and	a5,a5,a3
    80006444:	e71c                	sd	a5,8(a4)
    for (mti = 1; mti < N; mti++)
    80006446:	0721                	addi	a4,a4,8
    80006448:	feb71ae3          	bne	a4,a1,8000643c <sgenrand+0x26>
    8000644c:	27000793          	li	a5,624
    80006450:	00002717          	auipc	a4,0x2
    80006454:	5af72423          	sw	a5,1448(a4) # 800089f8 <mti>
}
    80006458:	6422                	ld	s0,8(sp)
    8000645a:	0141                	addi	sp,sp,16
    8000645c:	8082                	ret

000000008000645e <genrand>:

long /* for integer generation */
genrand()
{
    8000645e:	1141                	addi	sp,sp,-16
    80006460:	e406                	sd	ra,8(sp)
    80006462:	e022                	sd	s0,0(sp)
    80006464:	0800                	addi	s0,sp,16
    unsigned long y;
    static unsigned long mag01[2] = {0x0, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N)
    80006466:	00002797          	auipc	a5,0x2
    8000646a:	5927a783          	lw	a5,1426(a5) # 800089f8 <mti>
    8000646e:	26f00713          	li	a4,623
    80006472:	0ef75963          	bge	a4,a5,80006564 <genrand+0x106>
    { /* generate N words at one time */
        int kk;

        if (mti == N + 1)   /* if sgenrand() has not been called, */
    80006476:	27100713          	li	a4,625
    8000647a:	12e78e63          	beq	a5,a4,800065b6 <genrand+0x158>
            sgenrand(4357); /* a default initial seed is used   */

        for (kk = 0; kk < N - M; kk++)
    8000647e:	0023e817          	auipc	a6,0x23e
    80006482:	c6280813          	addi	a6,a6,-926 # 802440e0 <mt>
    80006486:	0023ee17          	auipc	t3,0x23e
    8000648a:	372e0e13          	addi	t3,t3,882 # 802447f8 <mt+0x718>
{
    8000648e:	8742                	mv	a4,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    80006490:	4885                	li	a7,1
    80006492:	08fe                	slli	a7,a7,0x1f
    80006494:	80000537          	lui	a0,0x80000
    80006498:	fff54513          	not	a0,a0
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    8000649c:	6585                	lui	a1,0x1
    8000649e:	c6858593          	addi	a1,a1,-920 # c68 <_entry-0x7ffff398>
    800064a2:	00002317          	auipc	t1,0x2
    800064a6:	42e30313          	addi	t1,t1,1070 # 800088d0 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800064aa:	631c                	ld	a5,0(a4)
    800064ac:	0117f7b3          	and	a5,a5,a7
    800064b0:	6714                	ld	a3,8(a4)
    800064b2:	8ee9                	and	a3,a3,a0
    800064b4:	8fd5                	or	a5,a5,a3
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    800064b6:	00b70633          	add	a2,a4,a1
    800064ba:	0017d693          	srli	a3,a5,0x1
    800064be:	6210                	ld	a2,0(a2)
    800064c0:	8eb1                	xor	a3,a3,a2
    800064c2:	8b85                	andi	a5,a5,1
    800064c4:	078e                	slli	a5,a5,0x3
    800064c6:	979a                	add	a5,a5,t1
    800064c8:	639c                	ld	a5,0(a5)
    800064ca:	8fb5                	xor	a5,a5,a3
    800064cc:	e31c                	sd	a5,0(a4)
        for (kk = 0; kk < N - M; kk++)
    800064ce:	0721                	addi	a4,a4,8
    800064d0:	fdc71de3          	bne	a4,t3,800064aa <genrand+0x4c>
        }
        for (; kk < N - 1; kk++)
    800064d4:	6605                	lui	a2,0x1
    800064d6:	c6060613          	addi	a2,a2,-928 # c60 <_entry-0x7ffff3a0>
    800064da:	9642                	add	a2,a2,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800064dc:	4505                	li	a0,1
    800064de:	057e                	slli	a0,a0,0x1f
    800064e0:	800005b7          	lui	a1,0x80000
    800064e4:	fff5c593          	not	a1,a1
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    800064e8:	00002897          	auipc	a7,0x2
    800064ec:	3e888893          	addi	a7,a7,1000 # 800088d0 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    800064f0:	71883783          	ld	a5,1816(a6)
    800064f4:	8fe9                	and	a5,a5,a0
    800064f6:	72083703          	ld	a4,1824(a6)
    800064fa:	8f6d                	and	a4,a4,a1
    800064fc:	8fd9                	or	a5,a5,a4
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    800064fe:	0017d713          	srli	a4,a5,0x1
    80006502:	00083683          	ld	a3,0(a6)
    80006506:	8f35                	xor	a4,a4,a3
    80006508:	8b85                	andi	a5,a5,1
    8000650a:	078e                	slli	a5,a5,0x3
    8000650c:	97c6                	add	a5,a5,a7
    8000650e:	639c                	ld	a5,0(a5)
    80006510:	8fb9                	xor	a5,a5,a4
    80006512:	70f83c23          	sd	a5,1816(a6)
        for (; kk < N - 1; kk++)
    80006516:	0821                	addi	a6,a6,8
    80006518:	fcc81ce3          	bne	a6,a2,800064f0 <genrand+0x92>
        }
        y = (mt[N - 1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
    8000651c:	0023f697          	auipc	a3,0x23f
    80006520:	bc468693          	addi	a3,a3,-1084 # 802450e0 <mt+0x1000>
    80006524:	3786b783          	ld	a5,888(a3)
    80006528:	4705                	li	a4,1
    8000652a:	077e                	slli	a4,a4,0x1f
    8000652c:	8ff9                	and	a5,a5,a4
    8000652e:	0023e717          	auipc	a4,0x23e
    80006532:	bb273703          	ld	a4,-1102(a4) # 802440e0 <mt>
    80006536:	1706                	slli	a4,a4,0x21
    80006538:	9305                	srli	a4,a4,0x21
    8000653a:	8fd9                	or	a5,a5,a4
        mt[N - 1] = mt[M - 1] ^ (y >> 1) ^ mag01[y & 0x1];
    8000653c:	0017d713          	srli	a4,a5,0x1
    80006540:	c606b603          	ld	a2,-928(a3)
    80006544:	8f31                	xor	a4,a4,a2
    80006546:	8b85                	andi	a5,a5,1
    80006548:	078e                	slli	a5,a5,0x3
    8000654a:	00002617          	auipc	a2,0x2
    8000654e:	38660613          	addi	a2,a2,902 # 800088d0 <mag01.0>
    80006552:	97b2                	add	a5,a5,a2
    80006554:	639c                	ld	a5,0(a5)
    80006556:	8fb9                	xor	a5,a5,a4
    80006558:	36f6bc23          	sd	a5,888(a3)

        mti = 0;
    8000655c:	00002797          	auipc	a5,0x2
    80006560:	4807ae23          	sw	zero,1180(a5) # 800089f8 <mti>
    }

    y = mt[mti++];
    80006564:	00002717          	auipc	a4,0x2
    80006568:	49470713          	addi	a4,a4,1172 # 800089f8 <mti>
    8000656c:	431c                	lw	a5,0(a4)
    8000656e:	0017869b          	addiw	a3,a5,1
    80006572:	c314                	sw	a3,0(a4)
    80006574:	078e                	slli	a5,a5,0x3
    80006576:	0023e717          	auipc	a4,0x23e
    8000657a:	b6a70713          	addi	a4,a4,-1174 # 802440e0 <mt>
    8000657e:	97ba                	add	a5,a5,a4
    80006580:	639c                	ld	a5,0(a5)
    y ^= TEMPERING_SHIFT_U(y);
    80006582:	00b7d713          	srli	a4,a5,0xb
    80006586:	8f3d                	xor	a4,a4,a5
    y ^= TEMPERING_SHIFT_S(y) & TEMPERING_MASK_B;
    80006588:	013a67b7          	lui	a5,0x13a6
    8000658c:	8ad78793          	addi	a5,a5,-1875 # 13a58ad <_entry-0x7ec5a753>
    80006590:	8ff9                	and	a5,a5,a4
    80006592:	079e                	slli	a5,a5,0x7
    80006594:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_T(y) & TEMPERING_MASK_C;
    80006596:	00f79713          	slli	a4,a5,0xf
    8000659a:	077e36b7          	lui	a3,0x77e3
    8000659e:	0696                	slli	a3,a3,0x5
    800065a0:	8f75                	and	a4,a4,a3
    800065a2:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_L(y);
    800065a4:	0127d513          	srli	a0,a5,0x12
    800065a8:	8d3d                	xor	a0,a0,a5

    // Strip off uppermost bit because we want a long,
    // not an unsigned long
    return y & RAND_MAX;
    800065aa:	1506                	slli	a0,a0,0x21
}
    800065ac:	9105                	srli	a0,a0,0x21
    800065ae:	60a2                	ld	ra,8(sp)
    800065b0:	6402                	ld	s0,0(sp)
    800065b2:	0141                	addi	sp,sp,16
    800065b4:	8082                	ret
            sgenrand(4357); /* a default initial seed is used   */
    800065b6:	6505                	lui	a0,0x1
    800065b8:	10550513          	addi	a0,a0,261 # 1105 <_entry-0x7fffeefb>
    800065bc:	00000097          	auipc	ra,0x0
    800065c0:	e5a080e7          	jalr	-422(ra) # 80006416 <sgenrand>
    800065c4:	bd6d                	j	8000647e <genrand+0x20>

00000000800065c6 <random_at_most>:

// Assumes 0 <= max <= RAND_MAX
// Returns in the half-open interval [0, max]
long random_at_most(long max)
{
    800065c6:	1101                	addi	sp,sp,-32
    800065c8:	ec06                	sd	ra,24(sp)
    800065ca:	e822                	sd	s0,16(sp)
    800065cc:	e426                	sd	s1,8(sp)
    800065ce:	e04a                	sd	s2,0(sp)
    800065d0:	1000                	addi	s0,sp,32
    unsigned long
        // max <= RAND_MAX < ULONG_MAX, so this is okay.
        num_bins = (unsigned long)max + 1,
    800065d2:	0505                	addi	a0,a0,1
        num_rand = (unsigned long)RAND_MAX + 1,
        bin_size = num_rand / num_bins,
    800065d4:	4785                	li	a5,1
    800065d6:	07fe                	slli	a5,a5,0x1f
    800065d8:	02a7d933          	divu	s2,a5,a0
        defect = num_rand % num_bins;
    800065dc:	02a7f7b3          	remu	a5,a5,a0
    do
    {
        x = genrand();
    }
    // This is carefully written not to overflow
    while (num_rand - defect <= (unsigned long)x);
    800065e0:	4485                	li	s1,1
    800065e2:	04fe                	slli	s1,s1,0x1f
    800065e4:	8c9d                	sub	s1,s1,a5
        x = genrand();
    800065e6:	00000097          	auipc	ra,0x0
    800065ea:	e78080e7          	jalr	-392(ra) # 8000645e <genrand>
    while (num_rand - defect <= (unsigned long)x);
    800065ee:	fe957ce3          	bgeu	a0,s1,800065e6 <random_at_most+0x20>

    // Truncated division is intentional
    return x / bin_size;
    800065f2:	03255533          	divu	a0,a0,s2
    800065f6:	60e2                	ld	ra,24(sp)
    800065f8:	6442                	ld	s0,16(sp)
    800065fa:	64a2                	ld	s1,8(sp)
    800065fc:	6902                	ld	s2,0(sp)
    800065fe:	6105                	addi	sp,sp,32
    80006600:	8082                	ret

0000000080006602 <popfront>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void popfront(deque *a)
{
    80006602:	1141                	addi	sp,sp,-16
    80006604:	e422                	sd	s0,8(sp)
    80006606:	0800                	addi	s0,sp,16
    for (int i = 0; i < a->end - 1; i++)
    80006608:	20052683          	lw	a3,512(a0)
    8000660c:	fff6861b          	addiw	a2,a3,-1 # 77e2fff <_entry-0x7881d001>
    80006610:	0006079b          	sext.w	a5,a2
    80006614:	cf99                	beqz	a5,80006632 <popfront+0x30>
    80006616:	87aa                	mv	a5,a0
    80006618:	36f9                	addiw	a3,a3,-2
    8000661a:	02069713          	slli	a4,a3,0x20
    8000661e:	01d75693          	srli	a3,a4,0x1d
    80006622:	00850713          	addi	a4,a0,8
    80006626:	96ba                	add	a3,a3,a4
    {
        a->n[i] = a->n[i + 1];
    80006628:	6798                	ld	a4,8(a5)
    8000662a:	e398                	sd	a4,0(a5)
    for (int i = 0; i < a->end - 1; i++)
    8000662c:	07a1                	addi	a5,a5,8
    8000662e:	fed79de3          	bne	a5,a3,80006628 <popfront+0x26>
    }
    a->end--;
    80006632:	20c52023          	sw	a2,512(a0)
    return;
}
    80006636:	6422                	ld	s0,8(sp)
    80006638:	0141                	addi	sp,sp,16
    8000663a:	8082                	ret

000000008000663c <pushback>:
void pushback(deque *a, struct proc *x)
{
    if (a->end == NPROC)
    8000663c:	20052783          	lw	a5,512(a0)
    80006640:	04000713          	li	a4,64
    80006644:	00e78c63          	beq	a5,a4,8000665c <pushback+0x20>
    {
        panic("Error!");
        return;
    }
    a->n[a->end] = x;
    80006648:	02079693          	slli	a3,a5,0x20
    8000664c:	01d6d713          	srli	a4,a3,0x1d
    80006650:	972a                	add	a4,a4,a0
    80006652:	e30c                	sd	a1,0(a4)
    a->end++;
    80006654:	2785                	addiw	a5,a5,1
    80006656:	20f52023          	sw	a5,512(a0)
    8000665a:	8082                	ret
{
    8000665c:	1141                	addi	sp,sp,-16
    8000665e:	e406                	sd	ra,8(sp)
    80006660:	e022                	sd	s0,0(sp)
    80006662:	0800                	addi	s0,sp,16
        panic("Error!");
    80006664:	00002517          	auipc	a0,0x2
    80006668:	27c50513          	addi	a0,a0,636 # 800088e0 <mag01.0+0x10>
    8000666c:	ffffa097          	auipc	ra,0xffffa
    80006670:	ed4080e7          	jalr	-300(ra) # 80000540 <panic>

0000000080006674 <front>:
    return;
}
struct proc *front(deque *a)
{
    80006674:	1141                	addi	sp,sp,-16
    80006676:	e422                	sd	s0,8(sp)
    80006678:	0800                	addi	s0,sp,16
    if (a->end == 0)
    8000667a:	20052783          	lw	a5,512(a0)
    8000667e:	c789                	beqz	a5,80006688 <front+0x14>
    {
        return 0;
    }
    return a->n[0];
    80006680:	6108                	ld	a0,0(a0)
}
    80006682:	6422                	ld	s0,8(sp)
    80006684:	0141                	addi	sp,sp,16
    80006686:	8082                	ret
        return 0;
    80006688:	4501                	li	a0,0
    8000668a:	bfe5                	j	80006682 <front+0xe>

000000008000668c <size>:
int size(deque *a)
{
    8000668c:	1141                	addi	sp,sp,-16
    8000668e:	e422                	sd	s0,8(sp)
    80006690:	0800                	addi	s0,sp,16
    return a->end;
}
    80006692:	20052503          	lw	a0,512(a0)
    80006696:	6422                	ld	s0,8(sp)
    80006698:	0141                	addi	sp,sp,16
    8000669a:	8082                	ret

000000008000669c <delete>:
void delete (deque *a, uint pid)
{
    8000669c:	1141                	addi	sp,sp,-16
    8000669e:	e422                	sd	s0,8(sp)
    800066a0:	0800                	addi	s0,sp,16
    int flag = 0;
    for (int i = 0; i < a->end; i++)
    800066a2:	20052e03          	lw	t3,512(a0)
    800066a6:	020e0c63          	beqz	t3,800066de <delete+0x42>
    800066aa:	87aa                	mv	a5,a0
    800066ac:	000e031b          	sext.w	t1,t3
    800066b0:	4701                	li	a4,0
    int flag = 0;
    800066b2:	4881                	li	a7,0
    {
        if (pid == a->n[i]->pid)
        {
            flag = 1;
        }
        if (flag == 1 && i != NPROC)
    800066b4:	04000e93          	li	t4,64
    800066b8:	4805                	li	a6,1
    800066ba:	a811                	j	800066ce <delete+0x32>
    800066bc:	88c2                	mv	a7,a6
    800066be:	01d70463          	beq	a4,t4,800066c6 <delete+0x2a>
        {
            a->n[i] = a->n[i + 1];
    800066c2:	6614                	ld	a3,8(a2)
    800066c4:	e214                	sd	a3,0(a2)
    for (int i = 0; i < a->end; i++)
    800066c6:	2705                	addiw	a4,a4,1
    800066c8:	07a1                	addi	a5,a5,8
    800066ca:	00670a63          	beq	a4,t1,800066de <delete+0x42>
        if (pid == a->n[i]->pid)
    800066ce:	863e                	mv	a2,a5
    800066d0:	6394                	ld	a3,0(a5)
    800066d2:	5a94                	lw	a3,48(a3)
    800066d4:	feb684e3          	beq	a3,a1,800066bc <delete+0x20>
        if (flag == 1 && i != NPROC)
    800066d8:	ff0897e3          	bne	a7,a6,800066c6 <delete+0x2a>
    800066dc:	b7c5                	j	800066bc <delete+0x20>
        }
    }
    a->end--;
    800066de:	3e7d                	addiw	t3,t3,-1
    800066e0:	21c52023          	sw	t3,512(a0)
    return;
    800066e4:	6422                	ld	s0,8(sp)
    800066e6:	0141                	addi	sp,sp,16
    800066e8:	8082                	ret

00000000800066ea <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800066ea:	1141                	addi	sp,sp,-16
    800066ec:	e406                	sd	ra,8(sp)
    800066ee:	e022                	sd	s0,0(sp)
    800066f0:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800066f2:	479d                	li	a5,7
    800066f4:	04a7cc63          	blt	a5,a0,8000674c <free_desc+0x62>
    panic("free_desc 1");
  if (disk.free[i])
    800066f8:	0023f797          	auipc	a5,0x23f
    800066fc:	d6878793          	addi	a5,a5,-664 # 80245460 <disk>
    80006700:	97aa                	add	a5,a5,a0
    80006702:	0187c783          	lbu	a5,24(a5)
    80006706:	ebb9                	bnez	a5,8000675c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006708:	00451693          	slli	a3,a0,0x4
    8000670c:	0023f797          	auipc	a5,0x23f
    80006710:	d5478793          	addi	a5,a5,-684 # 80245460 <disk>
    80006714:	6398                	ld	a4,0(a5)
    80006716:	9736                	add	a4,a4,a3
    80006718:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000671c:	6398                	ld	a4,0(a5)
    8000671e:	9736                	add	a4,a4,a3
    80006720:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006724:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006728:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000672c:	97aa                	add	a5,a5,a0
    8000672e:	4705                	li	a4,1
    80006730:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006734:	0023f517          	auipc	a0,0x23f
    80006738:	d4450513          	addi	a0,a0,-700 # 80245478 <disk+0x18>
    8000673c:	ffffc097          	auipc	ra,0xffffc
    80006740:	d8e080e7          	jalr	-626(ra) # 800024ca <wakeup>
}
    80006744:	60a2                	ld	ra,8(sp)
    80006746:	6402                	ld	s0,0(sp)
    80006748:	0141                	addi	sp,sp,16
    8000674a:	8082                	ret
    panic("free_desc 1");
    8000674c:	00002517          	auipc	a0,0x2
    80006750:	19c50513          	addi	a0,a0,412 # 800088e8 <mag01.0+0x18>
    80006754:	ffffa097          	auipc	ra,0xffffa
    80006758:	dec080e7          	jalr	-532(ra) # 80000540 <panic>
    panic("free_desc 2");
    8000675c:	00002517          	auipc	a0,0x2
    80006760:	19c50513          	addi	a0,a0,412 # 800088f8 <mag01.0+0x28>
    80006764:	ffffa097          	auipc	ra,0xffffa
    80006768:	ddc080e7          	jalr	-548(ra) # 80000540 <panic>

000000008000676c <virtio_disk_init>:
{
    8000676c:	1101                	addi	sp,sp,-32
    8000676e:	ec06                	sd	ra,24(sp)
    80006770:	e822                	sd	s0,16(sp)
    80006772:	e426                	sd	s1,8(sp)
    80006774:	e04a                	sd	s2,0(sp)
    80006776:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006778:	00002597          	auipc	a1,0x2
    8000677c:	19058593          	addi	a1,a1,400 # 80008908 <mag01.0+0x38>
    80006780:	0023f517          	auipc	a0,0x23f
    80006784:	e0850513          	addi	a0,a0,-504 # 80245588 <disk+0x128>
    80006788:	ffffa097          	auipc	ra,0xffffa
    8000678c:	532080e7          	jalr	1330(ra) # 80000cba <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006790:	100017b7          	lui	a5,0x10001
    80006794:	4398                	lw	a4,0(a5)
    80006796:	2701                	sext.w	a4,a4
    80006798:	747277b7          	lui	a5,0x74727
    8000679c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800067a0:	14f71b63          	bne	a4,a5,800068f6 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800067a4:	100017b7          	lui	a5,0x10001
    800067a8:	43dc                	lw	a5,4(a5)
    800067aa:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800067ac:	4709                	li	a4,2
    800067ae:	14e79463          	bne	a5,a4,800068f6 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800067b2:	100017b7          	lui	a5,0x10001
    800067b6:	479c                	lw	a5,8(a5)
    800067b8:	2781                	sext.w	a5,a5
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    800067ba:	12e79e63          	bne	a5,a4,800068f6 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551)
    800067be:	100017b7          	lui	a5,0x10001
    800067c2:	47d8                	lw	a4,12(a5)
    800067c4:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800067c6:	554d47b7          	lui	a5,0x554d4
    800067ca:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800067ce:	12f71463          	bne	a4,a5,800068f6 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800067d2:	100017b7          	lui	a5,0x10001
    800067d6:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800067da:	4705                	li	a4,1
    800067dc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067de:	470d                	li	a4,3
    800067e0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800067e2:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800067e4:	c7ffe6b7          	lui	a3,0xc7ffe
    800067e8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db91bf>
    800067ec:	8f75                	and	a4,a4,a3
    800067ee:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067f0:	472d                	li	a4,11
    800067f2:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800067f4:	5bbc                	lw	a5,112(a5)
    800067f6:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800067fa:	8ba1                	andi	a5,a5,8
    800067fc:	10078563          	beqz	a5,80006906 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006800:	100017b7          	lui	a5,0x10001
    80006804:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80006808:	43fc                	lw	a5,68(a5)
    8000680a:	2781                	sext.w	a5,a5
    8000680c:	10079563          	bnez	a5,80006916 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006810:	100017b7          	lui	a5,0x10001
    80006814:	5bdc                	lw	a5,52(a5)
    80006816:	2781                	sext.w	a5,a5
  if (max == 0)
    80006818:	10078763          	beqz	a5,80006926 <virtio_disk_init+0x1ba>
  if (max < NUM)
    8000681c:	471d                	li	a4,7
    8000681e:	10f77c63          	bgeu	a4,a5,80006936 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80006822:	ffffa097          	auipc	ra,0xffffa
    80006826:	42e080e7          	jalr	1070(ra) # 80000c50 <kalloc>
    8000682a:	0023f497          	auipc	s1,0x23f
    8000682e:	c3648493          	addi	s1,s1,-970 # 80245460 <disk>
    80006832:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006834:	ffffa097          	auipc	ra,0xffffa
    80006838:	41c080e7          	jalr	1052(ra) # 80000c50 <kalloc>
    8000683c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000683e:	ffffa097          	auipc	ra,0xffffa
    80006842:	412080e7          	jalr	1042(ra) # 80000c50 <kalloc>
    80006846:	87aa                	mv	a5,a0
    80006848:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    8000684a:	6088                	ld	a0,0(s1)
    8000684c:	cd6d                	beqz	a0,80006946 <virtio_disk_init+0x1da>
    8000684e:	0023f717          	auipc	a4,0x23f
    80006852:	c1a73703          	ld	a4,-998(a4) # 80245468 <disk+0x8>
    80006856:	cb65                	beqz	a4,80006946 <virtio_disk_init+0x1da>
    80006858:	c7fd                	beqz	a5,80006946 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    8000685a:	6605                	lui	a2,0x1
    8000685c:	4581                	li	a1,0
    8000685e:	ffffa097          	auipc	ra,0xffffa
    80006862:	5e8080e7          	jalr	1512(ra) # 80000e46 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006866:	0023f497          	auipc	s1,0x23f
    8000686a:	bfa48493          	addi	s1,s1,-1030 # 80245460 <disk>
    8000686e:	6605                	lui	a2,0x1
    80006870:	4581                	li	a1,0
    80006872:	6488                	ld	a0,8(s1)
    80006874:	ffffa097          	auipc	ra,0xffffa
    80006878:	5d2080e7          	jalr	1490(ra) # 80000e46 <memset>
  memset(disk.used, 0, PGSIZE);
    8000687c:	6605                	lui	a2,0x1
    8000687e:	4581                	li	a1,0
    80006880:	6888                	ld	a0,16(s1)
    80006882:	ffffa097          	auipc	ra,0xffffa
    80006886:	5c4080e7          	jalr	1476(ra) # 80000e46 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000688a:	100017b7          	lui	a5,0x10001
    8000688e:	4721                	li	a4,8
    80006890:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006892:	4098                	lw	a4,0(s1)
    80006894:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006898:	40d8                	lw	a4,4(s1)
    8000689a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000689e:	6498                	ld	a4,8(s1)
    800068a0:	0007069b          	sext.w	a3,a4
    800068a4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800068a8:	9701                	srai	a4,a4,0x20
    800068aa:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800068ae:	6898                	ld	a4,16(s1)
    800068b0:	0007069b          	sext.w	a3,a4
    800068b4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800068b8:	9701                	srai	a4,a4,0x20
    800068ba:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800068be:	4705                	li	a4,1
    800068c0:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800068c2:	00e48c23          	sb	a4,24(s1)
    800068c6:	00e48ca3          	sb	a4,25(s1)
    800068ca:	00e48d23          	sb	a4,26(s1)
    800068ce:	00e48da3          	sb	a4,27(s1)
    800068d2:	00e48e23          	sb	a4,28(s1)
    800068d6:	00e48ea3          	sb	a4,29(s1)
    800068da:	00e48f23          	sb	a4,30(s1)
    800068de:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800068e2:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800068e6:	0727a823          	sw	s2,112(a5)
}
    800068ea:	60e2                	ld	ra,24(sp)
    800068ec:	6442                	ld	s0,16(sp)
    800068ee:	64a2                	ld	s1,8(sp)
    800068f0:	6902                	ld	s2,0(sp)
    800068f2:	6105                	addi	sp,sp,32
    800068f4:	8082                	ret
    panic("could not find virtio disk");
    800068f6:	00002517          	auipc	a0,0x2
    800068fa:	02250513          	addi	a0,a0,34 # 80008918 <mag01.0+0x48>
    800068fe:	ffffa097          	auipc	ra,0xffffa
    80006902:	c42080e7          	jalr	-958(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006906:	00002517          	auipc	a0,0x2
    8000690a:	03250513          	addi	a0,a0,50 # 80008938 <mag01.0+0x68>
    8000690e:	ffffa097          	auipc	ra,0xffffa
    80006912:	c32080e7          	jalr	-974(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006916:	00002517          	auipc	a0,0x2
    8000691a:	04250513          	addi	a0,a0,66 # 80008958 <mag01.0+0x88>
    8000691e:	ffffa097          	auipc	ra,0xffffa
    80006922:	c22080e7          	jalr	-990(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006926:	00002517          	auipc	a0,0x2
    8000692a:	05250513          	addi	a0,a0,82 # 80008978 <mag01.0+0xa8>
    8000692e:	ffffa097          	auipc	ra,0xffffa
    80006932:	c12080e7          	jalr	-1006(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006936:	00002517          	auipc	a0,0x2
    8000693a:	06250513          	addi	a0,a0,98 # 80008998 <mag01.0+0xc8>
    8000693e:	ffffa097          	auipc	ra,0xffffa
    80006942:	c02080e7          	jalr	-1022(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006946:	00002517          	auipc	a0,0x2
    8000694a:	07250513          	addi	a0,a0,114 # 800089b8 <mag01.0+0xe8>
    8000694e:	ffffa097          	auipc	ra,0xffffa
    80006952:	bf2080e7          	jalr	-1038(ra) # 80000540 <panic>

0000000080006956 <virtio_disk_rw>:
  }
  return 0;
}

void virtio_disk_rw(struct buf *b, int write)
{
    80006956:	7119                	addi	sp,sp,-128
    80006958:	fc86                	sd	ra,120(sp)
    8000695a:	f8a2                	sd	s0,112(sp)
    8000695c:	f4a6                	sd	s1,104(sp)
    8000695e:	f0ca                	sd	s2,96(sp)
    80006960:	ecce                	sd	s3,88(sp)
    80006962:	e8d2                	sd	s4,80(sp)
    80006964:	e4d6                	sd	s5,72(sp)
    80006966:	e0da                	sd	s6,64(sp)
    80006968:	fc5e                	sd	s7,56(sp)
    8000696a:	f862                	sd	s8,48(sp)
    8000696c:	f466                	sd	s9,40(sp)
    8000696e:	f06a                	sd	s10,32(sp)
    80006970:	ec6e                	sd	s11,24(sp)
    80006972:	0100                	addi	s0,sp,128
    80006974:	8aaa                	mv	s5,a0
    80006976:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006978:	00c52d03          	lw	s10,12(a0)
    8000697c:	001d1d1b          	slliw	s10,s10,0x1
    80006980:	1d02                	slli	s10,s10,0x20
    80006982:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006986:	0023f517          	auipc	a0,0x23f
    8000698a:	c0250513          	addi	a0,a0,-1022 # 80245588 <disk+0x128>
    8000698e:	ffffa097          	auipc	ra,0xffffa
    80006992:	3bc080e7          	jalr	956(ra) # 80000d4a <acquire>
  for (int i = 0; i < 3; i++)
    80006996:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++)
    80006998:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000699a:	0023fb97          	auipc	s7,0x23f
    8000699e:	ac6b8b93          	addi	s7,s7,-1338 # 80245460 <disk>
  for (int i = 0; i < 3; i++)
    800069a2:	4b0d                	li	s6,3
  {
    if (alloc3_desc(idx) == 0)
    {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800069a4:	0023fc97          	auipc	s9,0x23f
    800069a8:	be4c8c93          	addi	s9,s9,-1052 # 80245588 <disk+0x128>
    800069ac:	a08d                	j	80006a0e <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800069ae:	00fb8733          	add	a4,s7,a5
    800069b2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800069b6:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0)
    800069b8:	0207c563          	bltz	a5,800069e2 <virtio_disk_rw+0x8c>
  for (int i = 0; i < 3; i++)
    800069bc:	2905                	addiw	s2,s2,1
    800069be:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800069c0:	05690c63          	beq	s2,s6,80006a18 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800069c4:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++)
    800069c6:	0023f717          	auipc	a4,0x23f
    800069ca:	a9a70713          	addi	a4,a4,-1382 # 80245460 <disk>
    800069ce:	87ce                	mv	a5,s3
    if (disk.free[i])
    800069d0:	01874683          	lbu	a3,24(a4)
    800069d4:	fee9                	bnez	a3,800069ae <virtio_disk_rw+0x58>
  for (int i = 0; i < NUM; i++)
    800069d6:	2785                	addiw	a5,a5,1
    800069d8:	0705                	addi	a4,a4,1
    800069da:	fe979be3          	bne	a5,s1,800069d0 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800069de:	57fd                	li	a5,-1
    800069e0:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    800069e2:	01205d63          	blez	s2,800069fc <virtio_disk_rw+0xa6>
    800069e6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800069e8:	000a2503          	lw	a0,0(s4)
    800069ec:	00000097          	auipc	ra,0x0
    800069f0:	cfe080e7          	jalr	-770(ra) # 800066ea <free_desc>
      for (int j = 0; j < i; j++)
    800069f4:	2d85                	addiw	s11,s11,1
    800069f6:	0a11                	addi	s4,s4,4
    800069f8:	ff2d98e3          	bne	s11,s2,800069e8 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800069fc:	85e6                	mv	a1,s9
    800069fe:	0023f517          	auipc	a0,0x23f
    80006a02:	a7a50513          	addi	a0,a0,-1414 # 80245478 <disk+0x18>
    80006a06:	ffffc097          	auipc	ra,0xffffc
    80006a0a:	908080e7          	jalr	-1784(ra) # 8000230e <sleep>
  for (int i = 0; i < 3; i++)
    80006a0e:	f8040a13          	addi	s4,s0,-128
{
    80006a12:	8652                	mv	a2,s4
  for (int i = 0; i < 3; i++)
    80006a14:	894e                	mv	s2,s3
    80006a16:	b77d                	j	800069c4 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a18:	f8042503          	lw	a0,-128(s0)
    80006a1c:	00a50713          	addi	a4,a0,10
    80006a20:	0712                	slli	a4,a4,0x4

  if (write)
    80006a22:	0023f797          	auipc	a5,0x23f
    80006a26:	a3e78793          	addi	a5,a5,-1474 # 80245460 <disk>
    80006a2a:	00e786b3          	add	a3,a5,a4
    80006a2e:	01803633          	snez	a2,s8
    80006a32:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006a34:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006a38:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80006a3c:	f6070613          	addi	a2,a4,-160
    80006a40:	6394                	ld	a3,0(a5)
    80006a42:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a44:	00870593          	addi	a1,a4,8
    80006a48:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80006a4a:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006a4c:	0007b803          	ld	a6,0(a5)
    80006a50:	9642                	add	a2,a2,a6
    80006a52:	46c1                	li	a3,16
    80006a54:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006a56:	4585                	li	a1,1
    80006a58:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006a5c:	f8442683          	lw	a3,-124(s0)
    80006a60:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80006a64:	0692                	slli	a3,a3,0x4
    80006a66:	9836                	add	a6,a6,a3
    80006a68:	058a8613          	addi	a2,s5,88
    80006a6c:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006a70:	0007b803          	ld	a6,0(a5)
    80006a74:	96c2                	add	a3,a3,a6
    80006a76:	40000613          	li	a2,1024
    80006a7a:	c690                	sw	a2,8(a3)
  if (write)
    80006a7c:	001c3613          	seqz	a2,s8
    80006a80:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006a84:	00166613          	ori	a2,a2,1
    80006a88:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006a8c:	f8842603          	lw	a2,-120(s0)
    80006a90:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006a94:	00250693          	addi	a3,a0,2
    80006a98:	0692                	slli	a3,a3,0x4
    80006a9a:	96be                	add	a3,a3,a5
    80006a9c:	58fd                	li	a7,-1
    80006a9e:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80006aa2:	0612                	slli	a2,a2,0x4
    80006aa4:	9832                	add	a6,a6,a2
    80006aa6:	f9070713          	addi	a4,a4,-112
    80006aaa:	973e                	add	a4,a4,a5
    80006aac:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006ab0:	6398                	ld	a4,0(a5)
    80006ab2:	9732                	add	a4,a4,a2
    80006ab4:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006ab6:	4609                	li	a2,2
    80006ab8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006abc:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006ac0:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006ac4:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006ac8:	6794                	ld	a3,8(a5)
    80006aca:	0026d703          	lhu	a4,2(a3)
    80006ace:	8b1d                	andi	a4,a4,7
    80006ad0:	0706                	slli	a4,a4,0x1
    80006ad2:	96ba                	add	a3,a3,a4
    80006ad4:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006ad8:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006adc:	6798                	ld	a4,8(a5)
    80006ade:	00275783          	lhu	a5,2(a4)
    80006ae2:	2785                	addiw	a5,a5,1
    80006ae4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006ae8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006aec:	100017b7          	lui	a5,0x10001
    80006af0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1)
    80006af4:	004aa783          	lw	a5,4(s5)
  {
    sleep(b, &disk.vdisk_lock);
    80006af8:	0023f917          	auipc	s2,0x23f
    80006afc:	a9090913          	addi	s2,s2,-1392 # 80245588 <disk+0x128>
  while (b->disk == 1)
    80006b00:	4485                	li	s1,1
    80006b02:	00b79c63          	bne	a5,a1,80006b1a <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006b06:	85ca                	mv	a1,s2
    80006b08:	8556                	mv	a0,s5
    80006b0a:	ffffc097          	auipc	ra,0xffffc
    80006b0e:	804080e7          	jalr	-2044(ra) # 8000230e <sleep>
  while (b->disk == 1)
    80006b12:	004aa783          	lw	a5,4(s5)
    80006b16:	fe9788e3          	beq	a5,s1,80006b06 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006b1a:	f8042903          	lw	s2,-128(s0)
    80006b1e:	00290713          	addi	a4,s2,2
    80006b22:	0712                	slli	a4,a4,0x4
    80006b24:	0023f797          	auipc	a5,0x23f
    80006b28:	93c78793          	addi	a5,a5,-1732 # 80245460 <disk>
    80006b2c:	97ba                	add	a5,a5,a4
    80006b2e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006b32:	0023f997          	auipc	s3,0x23f
    80006b36:	92e98993          	addi	s3,s3,-1746 # 80245460 <disk>
    80006b3a:	00491713          	slli	a4,s2,0x4
    80006b3e:	0009b783          	ld	a5,0(s3)
    80006b42:	97ba                	add	a5,a5,a4
    80006b44:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006b48:	854a                	mv	a0,s2
    80006b4a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006b4e:	00000097          	auipc	ra,0x0
    80006b52:	b9c080e7          	jalr	-1124(ra) # 800066ea <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80006b56:	8885                	andi	s1,s1,1
    80006b58:	f0ed                	bnez	s1,80006b3a <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006b5a:	0023f517          	auipc	a0,0x23f
    80006b5e:	a2e50513          	addi	a0,a0,-1490 # 80245588 <disk+0x128>
    80006b62:	ffffa097          	auipc	ra,0xffffa
    80006b66:	29c080e7          	jalr	668(ra) # 80000dfe <release>
}
    80006b6a:	70e6                	ld	ra,120(sp)
    80006b6c:	7446                	ld	s0,112(sp)
    80006b6e:	74a6                	ld	s1,104(sp)
    80006b70:	7906                	ld	s2,96(sp)
    80006b72:	69e6                	ld	s3,88(sp)
    80006b74:	6a46                	ld	s4,80(sp)
    80006b76:	6aa6                	ld	s5,72(sp)
    80006b78:	6b06                	ld	s6,64(sp)
    80006b7a:	7be2                	ld	s7,56(sp)
    80006b7c:	7c42                	ld	s8,48(sp)
    80006b7e:	7ca2                	ld	s9,40(sp)
    80006b80:	7d02                	ld	s10,32(sp)
    80006b82:	6de2                	ld	s11,24(sp)
    80006b84:	6109                	addi	sp,sp,128
    80006b86:	8082                	ret

0000000080006b88 <virtio_disk_intr>:

void virtio_disk_intr()
{
    80006b88:	1101                	addi	sp,sp,-32
    80006b8a:	ec06                	sd	ra,24(sp)
    80006b8c:	e822                	sd	s0,16(sp)
    80006b8e:	e426                	sd	s1,8(sp)
    80006b90:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006b92:	0023f497          	auipc	s1,0x23f
    80006b96:	8ce48493          	addi	s1,s1,-1842 # 80245460 <disk>
    80006b9a:	0023f517          	auipc	a0,0x23f
    80006b9e:	9ee50513          	addi	a0,a0,-1554 # 80245588 <disk+0x128>
    80006ba2:	ffffa097          	auipc	ra,0xffffa
    80006ba6:	1a8080e7          	jalr	424(ra) # 80000d4a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006baa:	10001737          	lui	a4,0x10001
    80006bae:	533c                	lw	a5,96(a4)
    80006bb0:	8b8d                	andi	a5,a5,3
    80006bb2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006bb4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx)
    80006bb8:	689c                	ld	a5,16(s1)
    80006bba:	0204d703          	lhu	a4,32(s1)
    80006bbe:	0027d783          	lhu	a5,2(a5)
    80006bc2:	04f70863          	beq	a4,a5,80006c12 <virtio_disk_intr+0x8a>
  {
    __sync_synchronize();
    80006bc6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006bca:	6898                	ld	a4,16(s1)
    80006bcc:	0204d783          	lhu	a5,32(s1)
    80006bd0:	8b9d                	andi	a5,a5,7
    80006bd2:	078e                	slli	a5,a5,0x3
    80006bd4:	97ba                	add	a5,a5,a4
    80006bd6:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80006bd8:	00278713          	addi	a4,a5,2
    80006bdc:	0712                	slli	a4,a4,0x4
    80006bde:	9726                	add	a4,a4,s1
    80006be0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006be4:	e721                	bnez	a4,80006c2c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006be6:	0789                	addi	a5,a5,2
    80006be8:	0792                	slli	a5,a5,0x4
    80006bea:	97a6                	add	a5,a5,s1
    80006bec:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80006bee:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006bf2:	ffffc097          	auipc	ra,0xffffc
    80006bf6:	8d8080e7          	jalr	-1832(ra) # 800024ca <wakeup>

    disk.used_idx += 1;
    80006bfa:	0204d783          	lhu	a5,32(s1)
    80006bfe:	2785                	addiw	a5,a5,1
    80006c00:	17c2                	slli	a5,a5,0x30
    80006c02:	93c1                	srli	a5,a5,0x30
    80006c04:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx)
    80006c08:	6898                	ld	a4,16(s1)
    80006c0a:	00275703          	lhu	a4,2(a4)
    80006c0e:	faf71ce3          	bne	a4,a5,80006bc6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006c12:	0023f517          	auipc	a0,0x23f
    80006c16:	97650513          	addi	a0,a0,-1674 # 80245588 <disk+0x128>
    80006c1a:	ffffa097          	auipc	ra,0xffffa
    80006c1e:	1e4080e7          	jalr	484(ra) # 80000dfe <release>
}
    80006c22:	60e2                	ld	ra,24(sp)
    80006c24:	6442                	ld	s0,16(sp)
    80006c26:	64a2                	ld	s1,8(sp)
    80006c28:	6105                	addi	sp,sp,32
    80006c2a:	8082                	ret
      panic("virtio_disk_intr status");
    80006c2c:	00002517          	auipc	a0,0x2
    80006c30:	da450513          	addi	a0,a0,-604 # 800089d0 <mag01.0+0x100>
    80006c34:	ffffa097          	auipc	ra,0xffffa
    80006c38:	90c080e7          	jalr	-1780(ra) # 80000540 <panic>
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
