
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a9813103          	ld	sp,-1384(sp) # 80008a98 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	aa070713          	addi	a4,a4,-1376 # 80008af0 <timer_scratch>
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
    80000066:	06e78793          	addi	a5,a5,110 # 800060d0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdb94df>
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
    8000012e:	5ba080e7          	jalr	1466(ra) # 800026e4 <either_copyin>
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
    8000018e:	aa650513          	addi	a0,a0,-1370 # 80010c30 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	bb8080e7          	jalr	-1096(ra) # 80000d4a <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	a9648493          	addi	s1,s1,-1386 # 80010c30 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	b2690913          	addi	s2,s2,-1242 # 80010cc8 <cons+0x98>
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
    800001c4:	960080e7          	jalr	-1696(ra) # 80001b20 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	366080e7          	jalr	870(ra) # 8000252e <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	078080e7          	jalr	120(ra) # 8000224e <sleep>
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
    80000216:	47c080e7          	jalr	1148(ra) # 8000268e <either_copyout>
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
    8000022a:	a0a50513          	addi	a0,a0,-1526 # 80010c30 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	bd0080e7          	jalr	-1072(ra) # 80000dfe <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	9f450513          	addi	a0,a0,-1548 # 80010c30 <cons>
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
    80000276:	a4f72b23          	sw	a5,-1450(a4) # 80010cc8 <cons+0x98>
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
    800002d0:	96450513          	addi	a0,a0,-1692 # 80010c30 <cons>
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
    800002f6:	448080e7          	jalr	1096(ra) # 8000273a <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	93650513          	addi	a0,a0,-1738 # 80010c30 <cons>
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
    80000322:	91270713          	addi	a4,a4,-1774 # 80010c30 <cons>
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
    8000034c:	8e878793          	addi	a5,a5,-1816 # 80010c30 <cons>
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
    8000037a:	9527a783          	lw	a5,-1710(a5) # 80010cc8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	8a670713          	addi	a4,a4,-1882 # 80010c30 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	89648493          	addi	s1,s1,-1898 # 80010c30 <cons>
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
    800003da:	85a70713          	addi	a4,a4,-1958 # 80010c30 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	8ef72223          	sw	a5,-1820(a4) # 80010cd0 <cons+0xa0>
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
    80000416:	81e78793          	addi	a5,a5,-2018 # 80010c30 <cons>
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
    8000043a:	88c7ab23          	sw	a2,-1898(a5) # 80010ccc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	88a50513          	addi	a0,a0,-1910 # 80010cc8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	e78080e7          	jalr	-392(ra) # 800022be <wakeup>
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
    80000464:	7d050513          	addi	a0,a0,2000 # 80010c30 <cons>
    80000468:	00001097          	auipc	ra,0x1
    8000046c:	852080e7          	jalr	-1966(ra) # 80000cba <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00243797          	auipc	a5,0x243
    8000047c:	99078793          	addi	a5,a5,-1648 # 80242e08 <devsw>
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
    80000550:	7a07a223          	sw	zero,1956(a5) # 80010cf0 <pr+0x18>
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
    80000584:	52f72823          	sw	a5,1328(a4) # 80008ab0 <panicked>
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
    800005c0:	734dad83          	lw	s11,1844(s11) # 80010cf0 <pr+0x18>
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
    800005fe:	6de50513          	addi	a0,a0,1758 # 80010cd8 <pr>
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
    8000075c:	58050513          	addi	a0,a0,1408 # 80010cd8 <pr>
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
    80000778:	56448493          	addi	s1,s1,1380 # 80010cd8 <pr>
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
    800007d8:	52450513          	addi	a0,a0,1316 # 80010cf8 <uart_tx_lock>
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
    80000804:	2b07a783          	lw	a5,688(a5) # 80008ab0 <panicked>
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
    8000083c:	2807b783          	ld	a5,640(a5) # 80008ab8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	28073703          	ld	a4,640(a4) # 80008ac0 <uart_tx_w>
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
    80000866:	496a0a13          	addi	s4,s4,1174 # 80010cf8 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	24e48493          	addi	s1,s1,590 # 80008ab8 <uart_tx_r>
    if (uart_tx_w == uart_tx_r)
    80000872:	00008997          	auipc	s3,0x8
    80000876:	24e98993          	addi	s3,s3,590 # 80008ac0 <uart_tx_w>
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
    80000898:	a2a080e7          	jalr	-1494(ra) # 800022be <wakeup>

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
    800008d4:	42850513          	addi	a0,a0,1064 # 80010cf8 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	472080e7          	jalr	1138(ra) # 80000d4a <acquire>
  if (panicked)
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	1d07a783          	lw	a5,464(a5) # 80008ab0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	1d673703          	ld	a4,470(a4) # 80008ac0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	1c67b783          	ld	a5,454(a5) # 80008ab8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	3fa98993          	addi	s3,s3,1018 # 80010cf8 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	1b248493          	addi	s1,s1,434 # 80008ab8 <uart_tx_r>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	1b290913          	addi	s2,s2,434 # 80008ac0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	930080e7          	jalr	-1744(ra) # 8000224e <sleep>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	3c448493          	addi	s1,s1,964 # 80010cf8 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	16e7bc23          	sd	a4,376(a5) # 80008ac0 <uart_tx_w>
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
    800009be:	33e48493          	addi	s1,s1,830 # 80010cf8 <uart_tx_lock>
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
    800009f8:	35c50513          	addi	a0,a0,860 # 80010d50 <page_ref>
    800009fc:	00000097          	auipc	ra,0x0
    80000a00:	34e080e7          	jalr	846(ra) # 80000d4a <acquire>
  if (page_ref.count[(uint64)pa >> 12] <= 0)
    80000a04:	00c4d513          	srli	a0,s1,0xc
    80000a08:	00450713          	addi	a4,a0,4
    80000a0c:	070a                	slli	a4,a4,0x2
    80000a0e:	00010797          	auipc	a5,0x10
    80000a12:	34278793          	addi	a5,a5,834 # 80010d50 <page_ref>
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
    80000a2c:	32870713          	addi	a4,a4,808 # 80010d50 <page_ref>
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
    80000a3c:	31850513          	addi	a0,a0,792 # 80010d50 <page_ref>
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
    80000a68:	2ec50513          	addi	a0,a0,748 # 80010d50 <page_ref>
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
    80000a90:	89478793          	addi	a5,a5,-1900 # 80245320 <end>
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
    80000ad8:	25c90913          	addi	s2,s2,604 # 80010d30 <kmem>
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
    80000b0c:	24850513          	addi	a0,a0,584 # 80010d50 <page_ref>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	23a080e7          	jalr	570(ra) # 80000d4a <acquire>
  if (page_ref.count[(uint64)pa >> 12] < 0)
    80000b18:	00c4d793          	srli	a5,s1,0xc
    80000b1c:	00478693          	addi	a3,a5,4
    80000b20:	068a                	slli	a3,a3,0x2
    80000b22:	00010717          	auipc	a4,0x10
    80000b26:	22e70713          	addi	a4,a4,558 # 80010d50 <page_ref>
    80000b2a:	9736                	add	a4,a4,a3
    80000b2c:	4718                	lw	a4,8(a4)
    80000b2e:	02074463          	bltz	a4,80000b56 <increase_pgreference+0x5a>
  {
    panic("increase_pgreference");
  }
  page_ref.count[(uint64)pa >> 12]++;
    80000b32:	00010517          	auipc	a0,0x10
    80000b36:	21e50513          	addi	a0,a0,542 # 80010d50 <page_ref>
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
    80000bd6:	17e50513          	addi	a0,a0,382 # 80010d50 <page_ref>
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	0e0080e7          	jalr	224(ra) # 80000cba <initlock>
  acquire(&page_ref.lock);
    80000be2:	00010517          	auipc	a0,0x10
    80000be6:	16e50513          	addi	a0,a0,366 # 80010d50 <page_ref>
    80000bea:	00000097          	auipc	ra,0x0
    80000bee:	160080e7          	jalr	352(ra) # 80000d4a <acquire>
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000bf2:	00010797          	auipc	a5,0x10
    80000bf6:	17678793          	addi	a5,a5,374 # 80010d68 <page_ref+0x18>
    80000bfa:	00230717          	auipc	a4,0x230
    80000bfe:	16e70713          	addi	a4,a4,366 # 80230d68 <pid_lock>
    page_ref.count[i] = 0;
    80000c02:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000c06:	0791                	addi	a5,a5,4
    80000c08:	fee79de3          	bne	a5,a4,80000c02 <kinit+0x40>
  release(&page_ref.lock);
    80000c0c:	00010517          	auipc	a0,0x10
    80000c10:	14450513          	addi	a0,a0,324 # 80010d50 <page_ref>
    80000c14:	00000097          	auipc	ra,0x0
    80000c18:	1ea080e7          	jalr	490(ra) # 80000dfe <release>
  initlock(&kmem.lock, "kmem");
    80000c1c:	00007597          	auipc	a1,0x7
    80000c20:	48c58593          	addi	a1,a1,1164 # 800080a8 <digits+0x68>
    80000c24:	00010517          	auipc	a0,0x10
    80000c28:	10c50513          	addi	a0,a0,268 # 80010d30 <kmem>
    80000c2c:	00000097          	auipc	ra,0x0
    80000c30:	08e080e7          	jalr	142(ra) # 80000cba <initlock>
  freerange(end, (void *)PHYSTOP);
    80000c34:	45c5                	li	a1,17
    80000c36:	05ee                	slli	a1,a1,0x1b
    80000c38:	00244517          	auipc	a0,0x244
    80000c3c:	6e850513          	addi	a0,a0,1768 # 80245320 <end>
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
    80000c5e:	0d648493          	addi	s1,s1,214 # 80010d30 <kmem>
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
    80000c76:	0be50513          	addi	a0,a0,190 # 80010d30 <kmem>
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
    80000cac:	08850513          	addi	a0,a0,136 # 80010d30 <kmem>
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
    80000ce8:	e20080e7          	jalr	-480(ra) # 80001b04 <mycpu>
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
    80000d1a:	dee080e7          	jalr	-530(ra) # 80001b04 <mycpu>
    80000d1e:	5d3c                	lw	a5,120(a0)
    80000d20:	cf89                	beqz	a5,80000d3a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d22:	00001097          	auipc	ra,0x1
    80000d26:	de2080e7          	jalr	-542(ra) # 80001b04 <mycpu>
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
    80000d3e:	dca080e7          	jalr	-566(ra) # 80001b04 <mycpu>
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
    80000d7e:	d8a080e7          	jalr	-630(ra) # 80001b04 <mycpu>
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
    80000daa:	d5e080e7          	jalr	-674(ra) # 80001b04 <mycpu>
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
    80000ff8:	b00080e7          	jalr	-1280(ra) # 80001af4 <cpuid>
    __sync_synchronize();
    started = 1;
  }
  else
  {
    while (started == 0)
    80000ffc:	00008717          	auipc	a4,0x8
    80001000:	acc70713          	addi	a4,a4,-1332 # 80008ac8 <started>
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
    80001014:	ae4080e7          	jalr	-1308(ra) # 80001af4 <cpuid>
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
    80001036:	9f6080e7          	jalr	-1546(ra) # 80002a28 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    8000103a:	00005097          	auipc	ra,0x5
    8000103e:	0d6080e7          	jalr	214(ra) # 80006110 <plicinithart>
  }

  scheduler();
    80001042:	00001097          	auipc	ra,0x1
    80001046:	05a080e7          	jalr	90(ra) # 8000209c <scheduler>
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
    800010a6:	99e080e7          	jalr	-1634(ra) # 80001a40 <procinit>
    trapinit();         // trap vectors
    800010aa:	00002097          	auipc	ra,0x2
    800010ae:	956080e7          	jalr	-1706(ra) # 80002a00 <trapinit>
    trapinithart();     // install kernel trap vector
    800010b2:	00002097          	auipc	ra,0x2
    800010b6:	976080e7          	jalr	-1674(ra) # 80002a28 <trapinithart>
    plicinit();         // set up interrupt controller
    800010ba:	00005097          	auipc	ra,0x5
    800010be:	040080e7          	jalr	64(ra) # 800060fa <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    800010c2:	00005097          	auipc	ra,0x5
    800010c6:	04e080e7          	jalr	78(ra) # 80006110 <plicinithart>
    binit();            // buffer cache
    800010ca:	00002097          	auipc	ra,0x2
    800010ce:	1e2080e7          	jalr	482(ra) # 800032ac <binit>
    iinit();            // inode table
    800010d2:	00003097          	auipc	ra,0x3
    800010d6:	882080e7          	jalr	-1918(ra) # 80003954 <iinit>
    fileinit();         // file table
    800010da:	00004097          	auipc	ra,0x4
    800010de:	828080e7          	jalr	-2008(ra) # 80004902 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010e2:	00005097          	auipc	ra,0x5
    800010e6:	40a080e7          	jalr	1034(ra) # 800064ec <virtio_disk_init>
    userinit();         // first user process
    800010ea:	00001097          	auipc	ra,0x1
    800010ee:	d7c080e7          	jalr	-644(ra) # 80001e66 <userinit>
    __sync_synchronize();
    800010f2:	0ff0000f          	fence
    started = 1;
    800010f6:	4785                	li	a5,1
    800010f8:	00008717          	auipc	a4,0x8
    800010fc:	9cf72823          	sw	a5,-1584(a4) # 80008ac8 <started>
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
    80001110:	9c47b783          	ld	a5,-1596(a5) # 80008ad0 <kernel_pagetable>
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
    800013a6:	608080e7          	jalr	1544(ra) # 800019aa <proc_mapstacks>
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
    800013cc:	70a7b423          	sd	a0,1800(a5) # 80008ad0 <kernel_pagetable>
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
    800017e0:	c6bd                	beqz	a3,8000184e <copyout+0x6e>
{
    800017e2:	715d                	addi	sp,sp,-80
    800017e4:	e486                	sd	ra,72(sp)
    800017e6:	e0a2                	sd	s0,64(sp)
    800017e8:	fc26                	sd	s1,56(sp)
    800017ea:	f84a                	sd	s2,48(sp)
    800017ec:	f44e                	sd	s3,40(sp)
    800017ee:	f052                	sd	s4,32(sp)
    800017f0:	ec56                	sd	s5,24(sp)
    800017f2:	e85a                	sd	s6,16(sp)
    800017f4:	e45e                	sd	s7,8(sp)
    800017f6:	e062                	sd	s8,0(sp)
    800017f8:	0880                	addi	s0,sp,80
    800017fa:	8b2a                	mv	s6,a0
    800017fc:	8c2e                	mv	s8,a1
    800017fe:	8a32                	mv	s4,a2
    80001800:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80001802:	7bfd                	lui	s7,0xfffff
    // }

    // if (pa0 == 0)
    //   return -1;

    n = PGSIZE - (dstva - va0);
    80001804:	6a85                	lui	s5,0x1
    80001806:	a015                	j	8000182a <copyout+0x4a>
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001808:	9562                	add	a0,a0,s8
    8000180a:	0004861b          	sext.w	a2,s1
    8000180e:	85d2                	mv	a1,s4
    80001810:	41250533          	sub	a0,a0,s2
    80001814:	fffff097          	auipc	ra,0xfffff
    80001818:	68e080e7          	jalr	1678(ra) # 80000ea2 <memmove>

    len -= n;
    8000181c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001820:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001822:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80001826:	02098263          	beqz	s3,8000184a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000182a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000182e:	85ca                	mv	a1,s2
    80001830:	855a                	mv	a0,s6
    80001832:	00000097          	auipc	ra,0x0
    80001836:	99e080e7          	jalr	-1634(ra) # 800011d0 <walkaddr>
    if (pa0 == 0)
    8000183a:	cd01                	beqz	a0,80001852 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000183c:	418904b3          	sub	s1,s2,s8
    80001840:	94d6                	add	s1,s1,s5
    80001842:	fc99f3e3          	bgeu	s3,s1,80001808 <copyout+0x28>
    80001846:	84ce                	mv	s1,s3
    80001848:	b7c1                	j	80001808 <copyout+0x28>
  }
  return 0;
    8000184a:	4501                	li	a0,0
    8000184c:	a021                	j	80001854 <copyout+0x74>
    8000184e:	4501                	li	a0,0
}
    80001850:	8082                	ret
      return -1;
    80001852:	557d                	li	a0,-1
}
    80001854:	60a6                	ld	ra,72(sp)
    80001856:	6406                	ld	s0,64(sp)
    80001858:	74e2                	ld	s1,56(sp)
    8000185a:	7942                	ld	s2,48(sp)
    8000185c:	79a2                	ld	s3,40(sp)
    8000185e:	7a02                	ld	s4,32(sp)
    80001860:	6ae2                	ld	s5,24(sp)
    80001862:	6b42                	ld	s6,16(sp)
    80001864:	6ba2                	ld	s7,8(sp)
    80001866:	6c02                	ld	s8,0(sp)
    80001868:	6161                	addi	sp,sp,80
    8000186a:	8082                	ret

000000008000186c <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    8000186c:	caa5                	beqz	a3,800018dc <copyin+0x70>
{
    8000186e:	715d                	addi	sp,sp,-80
    80001870:	e486                	sd	ra,72(sp)
    80001872:	e0a2                	sd	s0,64(sp)
    80001874:	fc26                	sd	s1,56(sp)
    80001876:	f84a                	sd	s2,48(sp)
    80001878:	f44e                	sd	s3,40(sp)
    8000187a:	f052                	sd	s4,32(sp)
    8000187c:	ec56                	sd	s5,24(sp)
    8000187e:	e85a                	sd	s6,16(sp)
    80001880:	e45e                	sd	s7,8(sp)
    80001882:	e062                	sd	s8,0(sp)
    80001884:	0880                	addi	s0,sp,80
    80001886:	8b2a                	mv	s6,a0
    80001888:	8a2e                	mv	s4,a1
    8000188a:	8c32                	mv	s8,a2
    8000188c:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    8000188e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001890:	6a85                	lui	s5,0x1
    80001892:	a01d                	j	800018b8 <copyin+0x4c>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001894:	018505b3          	add	a1,a0,s8
    80001898:	0004861b          	sext.w	a2,s1
    8000189c:	412585b3          	sub	a1,a1,s2
    800018a0:	8552                	mv	a0,s4
    800018a2:	fffff097          	auipc	ra,0xfffff
    800018a6:	600080e7          	jalr	1536(ra) # 80000ea2 <memmove>

    len -= n;
    800018aa:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018ae:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018b0:	01590c33          	add	s8,s2,s5
  while (len > 0)
    800018b4:	02098263          	beqz	s3,800018d8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018b8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018bc:	85ca                	mv	a1,s2
    800018be:	855a                	mv	a0,s6
    800018c0:	00000097          	auipc	ra,0x0
    800018c4:	910080e7          	jalr	-1776(ra) # 800011d0 <walkaddr>
    if (pa0 == 0)
    800018c8:	cd01                	beqz	a0,800018e0 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018ca:	418904b3          	sub	s1,s2,s8
    800018ce:	94d6                	add	s1,s1,s5
    800018d0:	fc99f2e3          	bgeu	s3,s1,80001894 <copyin+0x28>
    800018d4:	84ce                	mv	s1,s3
    800018d6:	bf7d                	j	80001894 <copyin+0x28>
  }
  return 0;
    800018d8:	4501                	li	a0,0
    800018da:	a021                	j	800018e2 <copyin+0x76>
    800018dc:	4501                	li	a0,0
}
    800018de:	8082                	ret
      return -1;
    800018e0:	557d                	li	a0,-1
}
    800018e2:	60a6                	ld	ra,72(sp)
    800018e4:	6406                	ld	s0,64(sp)
    800018e6:	74e2                	ld	s1,56(sp)
    800018e8:	7942                	ld	s2,48(sp)
    800018ea:	79a2                	ld	s3,40(sp)
    800018ec:	7a02                	ld	s4,32(sp)
    800018ee:	6ae2                	ld	s5,24(sp)
    800018f0:	6b42                	ld	s6,16(sp)
    800018f2:	6ba2                	ld	s7,8(sp)
    800018f4:	6c02                	ld	s8,0(sp)
    800018f6:	6161                	addi	sp,sp,80
    800018f8:	8082                	ret

00000000800018fa <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    800018fa:	c2dd                	beqz	a3,800019a0 <copyinstr+0xa6>
{
    800018fc:	715d                	addi	sp,sp,-80
    800018fe:	e486                	sd	ra,72(sp)
    80001900:	e0a2                	sd	s0,64(sp)
    80001902:	fc26                	sd	s1,56(sp)
    80001904:	f84a                	sd	s2,48(sp)
    80001906:	f44e                	sd	s3,40(sp)
    80001908:	f052                	sd	s4,32(sp)
    8000190a:	ec56                	sd	s5,24(sp)
    8000190c:	e85a                	sd	s6,16(sp)
    8000190e:	e45e                	sd	s7,8(sp)
    80001910:	0880                	addi	s0,sp,80
    80001912:	8a2a                	mv	s4,a0
    80001914:	8b2e                	mv	s6,a1
    80001916:	8bb2                	mv	s7,a2
    80001918:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    8000191a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000191c:	6985                	lui	s3,0x1
    8000191e:	a02d                	j	80001948 <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    80001920:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001924:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80001926:	37fd                	addiw	a5,a5,-1
    80001928:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    8000192c:	60a6                	ld	ra,72(sp)
    8000192e:	6406                	ld	s0,64(sp)
    80001930:	74e2                	ld	s1,56(sp)
    80001932:	7942                	ld	s2,48(sp)
    80001934:	79a2                	ld	s3,40(sp)
    80001936:	7a02                	ld	s4,32(sp)
    80001938:	6ae2                	ld	s5,24(sp)
    8000193a:	6b42                	ld	s6,16(sp)
    8000193c:	6ba2                	ld	s7,8(sp)
    8000193e:	6161                	addi	sp,sp,80
    80001940:	8082                	ret
    srcva = va0 + PGSIZE;
    80001942:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80001946:	c8a9                	beqz	s1,80001998 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001948:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000194c:	85ca                	mv	a1,s2
    8000194e:	8552                	mv	a0,s4
    80001950:	00000097          	auipc	ra,0x0
    80001954:	880080e7          	jalr	-1920(ra) # 800011d0 <walkaddr>
    if (pa0 == 0)
    80001958:	c131                	beqz	a0,8000199c <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000195a:	417906b3          	sub	a3,s2,s7
    8000195e:	96ce                	add	a3,a3,s3
    80001960:	00d4f363          	bgeu	s1,a3,80001966 <copyinstr+0x6c>
    80001964:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80001966:	955e                	add	a0,a0,s7
    80001968:	41250533          	sub	a0,a0,s2
    while (n > 0)
    8000196c:	daf9                	beqz	a3,80001942 <copyinstr+0x48>
    8000196e:	87da                	mv	a5,s6
      if (*p == '\0')
    80001970:	41650633          	sub	a2,a0,s6
    80001974:	fff48593          	addi	a1,s1,-1
    80001978:	95da                	add	a1,a1,s6
    while (n > 0)
    8000197a:	96da                	add	a3,a3,s6
      if (*p == '\0')
    8000197c:	00f60733          	add	a4,a2,a5
    80001980:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fdb9ce0>
    80001984:	df51                	beqz	a4,80001920 <copyinstr+0x26>
        *dst = *p;
    80001986:	00e78023          	sb	a4,0(a5)
      --max;
    8000198a:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000198e:	0785                	addi	a5,a5,1
    while (n > 0)
    80001990:	fed796e3          	bne	a5,a3,8000197c <copyinstr+0x82>
      dst++;
    80001994:	8b3e                	mv	s6,a5
    80001996:	b775                	j	80001942 <copyinstr+0x48>
    80001998:	4781                	li	a5,0
    8000199a:	b771                	j	80001926 <copyinstr+0x2c>
      return -1;
    8000199c:	557d                	li	a0,-1
    8000199e:	b779                	j	8000192c <copyinstr+0x32>
  int got_null = 0;
    800019a0:	4781                	li	a5,0
  if (got_null)
    800019a2:	37fd                	addiw	a5,a5,-1
    800019a4:	0007851b          	sext.w	a0,a5
}
    800019a8:	8082                	ret

00000000800019aa <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    800019aa:	7139                	addi	sp,sp,-64
    800019ac:	fc06                	sd	ra,56(sp)
    800019ae:	f822                	sd	s0,48(sp)
    800019b0:	f426                	sd	s1,40(sp)
    800019b2:	f04a                	sd	s2,32(sp)
    800019b4:	ec4e                	sd	s3,24(sp)
    800019b6:	e852                	sd	s4,16(sp)
    800019b8:	e456                	sd	s5,8(sp)
    800019ba:	e05a                	sd	s6,0(sp)
    800019bc:	0080                	addi	s0,sp,64
    800019be:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800019c0:	0022f497          	auipc	s1,0x22f
    800019c4:	7d848493          	addi	s1,s1,2008 # 80231198 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800019c8:	8b26                	mv	s6,s1
    800019ca:	00006a97          	auipc	s5,0x6
    800019ce:	636a8a93          	addi	s5,s5,1590 # 80008000 <etext>
    800019d2:	04000937          	lui	s2,0x4000
    800019d6:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019d8:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800019da:	00236a17          	auipc	s4,0x236
    800019de:	7bea0a13          	addi	s4,s4,1982 # 80238198 <mlfq>
    char *pa = kalloc();
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	26e080e7          	jalr	622(ra) # 80000c50 <kalloc>
    800019ea:	862a                	mv	a2,a0
    if (pa == 0)
    800019ec:	c131                	beqz	a0,80001a30 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    800019ee:	416485b3          	sub	a1,s1,s6
    800019f2:	8599                	srai	a1,a1,0x6
    800019f4:	000ab783          	ld	a5,0(s5)
    800019f8:	02f585b3          	mul	a1,a1,a5
    800019fc:	2585                	addiw	a1,a1,1
    800019fe:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a02:	4719                	li	a4,6
    80001a04:	6685                	lui	a3,0x1
    80001a06:	40b905b3          	sub	a1,s2,a1
    80001a0a:	854e                	mv	a0,s3
    80001a0c:	00000097          	auipc	ra,0x0
    80001a10:	8a6080e7          	jalr	-1882(ra) # 800012b2 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a14:	1c048493          	addi	s1,s1,448
    80001a18:	fd4495e3          	bne	s1,s4,800019e2 <proc_mapstacks+0x38>
  }
}
    80001a1c:	70e2                	ld	ra,56(sp)
    80001a1e:	7442                	ld	s0,48(sp)
    80001a20:	74a2                	ld	s1,40(sp)
    80001a22:	7902                	ld	s2,32(sp)
    80001a24:	69e2                	ld	s3,24(sp)
    80001a26:	6a42                	ld	s4,16(sp)
    80001a28:	6aa2                	ld	s5,8(sp)
    80001a2a:	6b02                	ld	s6,0(sp)
    80001a2c:	6121                	addi	sp,sp,64
    80001a2e:	8082                	ret
      panic("kalloc");
    80001a30:	00006517          	auipc	a0,0x6
    80001a34:	7e850513          	addi	a0,a0,2024 # 80008218 <digits+0x1d8>
    80001a38:	fffff097          	auipc	ra,0xfffff
    80001a3c:	b08080e7          	jalr	-1272(ra) # 80000540 <panic>

0000000080001a40 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001a40:	7139                	addi	sp,sp,-64
    80001a42:	fc06                	sd	ra,56(sp)
    80001a44:	f822                	sd	s0,48(sp)
    80001a46:	f426                	sd	s1,40(sp)
    80001a48:	f04a                	sd	s2,32(sp)
    80001a4a:	ec4e                	sd	s3,24(sp)
    80001a4c:	e852                	sd	s4,16(sp)
    80001a4e:	e456                	sd	s5,8(sp)
    80001a50:	e05a                	sd	s6,0(sp)
    80001a52:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001a54:	00006597          	auipc	a1,0x6
    80001a58:	7cc58593          	addi	a1,a1,1996 # 80008220 <digits+0x1e0>
    80001a5c:	0022f517          	auipc	a0,0x22f
    80001a60:	30c50513          	addi	a0,a0,780 # 80230d68 <pid_lock>
    80001a64:	fffff097          	auipc	ra,0xfffff
    80001a68:	256080e7          	jalr	598(ra) # 80000cba <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a6c:	00006597          	auipc	a1,0x6
    80001a70:	7bc58593          	addi	a1,a1,1980 # 80008228 <digits+0x1e8>
    80001a74:	0022f517          	auipc	a0,0x22f
    80001a78:	30c50513          	addi	a0,a0,780 # 80230d80 <wait_lock>
    80001a7c:	fffff097          	auipc	ra,0xfffff
    80001a80:	23e080e7          	jalr	574(ra) # 80000cba <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a84:	0022f497          	auipc	s1,0x22f
    80001a88:	71448493          	addi	s1,s1,1812 # 80231198 <proc>
  {
    initlock(&p->lock, "proc");
    80001a8c:	00006b17          	auipc	s6,0x6
    80001a90:	7acb0b13          	addi	s6,s6,1964 # 80008238 <digits+0x1f8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001a94:	8aa6                	mv	s5,s1
    80001a96:	00006a17          	auipc	s4,0x6
    80001a9a:	56aa0a13          	addi	s4,s4,1386 # 80008000 <etext>
    80001a9e:	04000937          	lui	s2,0x4000
    80001aa2:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001aa4:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001aa6:	00236997          	auipc	s3,0x236
    80001aaa:	6f298993          	addi	s3,s3,1778 # 80238198 <mlfq>
    initlock(&p->lock, "proc");
    80001aae:	85da                	mv	a1,s6
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	fffff097          	auipc	ra,0xfffff
    80001ab6:	208080e7          	jalr	520(ra) # 80000cba <initlock>
    p->state = UNUSED;
    80001aba:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001abe:	415487b3          	sub	a5,s1,s5
    80001ac2:	8799                	srai	a5,a5,0x6
    80001ac4:	000a3703          	ld	a4,0(s4)
    80001ac8:	02e787b3          	mul	a5,a5,a4
    80001acc:	2785                	addiw	a5,a5,1
    80001ace:	00d7979b          	slliw	a5,a5,0xd
    80001ad2:	40f907b3          	sub	a5,s2,a5
    80001ad6:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001ad8:	1c048493          	addi	s1,s1,448
    80001adc:	fd3499e3          	bne	s1,s3,80001aae <procinit+0x6e>
  }
}
    80001ae0:	70e2                	ld	ra,56(sp)
    80001ae2:	7442                	ld	s0,48(sp)
    80001ae4:	74a2                	ld	s1,40(sp)
    80001ae6:	7902                	ld	s2,32(sp)
    80001ae8:	69e2                	ld	s3,24(sp)
    80001aea:	6a42                	ld	s4,16(sp)
    80001aec:	6aa2                	ld	s5,8(sp)
    80001aee:	6b02                	ld	s6,0(sp)
    80001af0:	6121                	addi	sp,sp,64
    80001af2:	8082                	ret

0000000080001af4 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001af4:	1141                	addi	sp,sp,-16
    80001af6:	e422                	sd	s0,8(sp)
    80001af8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp"
    80001afa:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001afc:	2501                	sext.w	a0,a0
    80001afe:	6422                	ld	s0,8(sp)
    80001b00:	0141                	addi	sp,sp,16
    80001b02:	8082                	ret

0000000080001b04 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001b04:	1141                	addi	sp,sp,-16
    80001b06:	e422                	sd	s0,8(sp)
    80001b08:	0800                	addi	s0,sp,16
    80001b0a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b0c:	2781                	sext.w	a5,a5
    80001b0e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b10:	0022f517          	auipc	a0,0x22f
    80001b14:	28850513          	addi	a0,a0,648 # 80230d98 <cpus>
    80001b18:	953e                	add	a0,a0,a5
    80001b1a:	6422                	ld	s0,8(sp)
    80001b1c:	0141                	addi	sp,sp,16
    80001b1e:	8082                	ret

0000000080001b20 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001b20:	1101                	addi	sp,sp,-32
    80001b22:	ec06                	sd	ra,24(sp)
    80001b24:	e822                	sd	s0,16(sp)
    80001b26:	e426                	sd	s1,8(sp)
    80001b28:	1000                	addi	s0,sp,32
  push_off();
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	1d4080e7          	jalr	468(ra) # 80000cfe <push_off>
    80001b32:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b34:	2781                	sext.w	a5,a5
    80001b36:	079e                	slli	a5,a5,0x7
    80001b38:	0022f717          	auipc	a4,0x22f
    80001b3c:	23070713          	addi	a4,a4,560 # 80230d68 <pid_lock>
    80001b40:	97ba                	add	a5,a5,a4
    80001b42:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	25a080e7          	jalr	602(ra) # 80000d9e <pop_off>
  return p;
}
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	60e2                	ld	ra,24(sp)
    80001b50:	6442                	ld	s0,16(sp)
    80001b52:	64a2                	ld	s1,8(sp)
    80001b54:	6105                	addi	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b58:	1141                	addi	sp,sp,-16
    80001b5a:	e406                	sd	ra,8(sp)
    80001b5c:	e022                	sd	s0,0(sp)
    80001b5e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b60:	00000097          	auipc	ra,0x0
    80001b64:	fc0080e7          	jalr	-64(ra) # 80001b20 <myproc>
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	296080e7          	jalr	662(ra) # 80000dfe <release>

  if (first)
    80001b70:	00007797          	auipc	a5,0x7
    80001b74:	e107a783          	lw	a5,-496(a5) # 80008980 <first.1>
    80001b78:	eb89                	bnez	a5,80001b8a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b7a:	00001097          	auipc	ra,0x1
    80001b7e:	ec6080e7          	jalr	-314(ra) # 80002a40 <usertrapret>
}
    80001b82:	60a2                	ld	ra,8(sp)
    80001b84:	6402                	ld	s0,0(sp)
    80001b86:	0141                	addi	sp,sp,16
    80001b88:	8082                	ret
    first = 0;
    80001b8a:	00007797          	auipc	a5,0x7
    80001b8e:	de07ab23          	sw	zero,-522(a5) # 80008980 <first.1>
    fsinit(ROOTDEV);
    80001b92:	4505                	li	a0,1
    80001b94:	00002097          	auipc	ra,0x2
    80001b98:	d40080e7          	jalr	-704(ra) # 800038d4 <fsinit>
    80001b9c:	bff9                	j	80001b7a <forkret+0x22>

0000000080001b9e <allocpid>:
{
    80001b9e:	1101                	addi	sp,sp,-32
    80001ba0:	ec06                	sd	ra,24(sp)
    80001ba2:	e822                	sd	s0,16(sp)
    80001ba4:	e426                	sd	s1,8(sp)
    80001ba6:	e04a                	sd	s2,0(sp)
    80001ba8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001baa:	0022f917          	auipc	s2,0x22f
    80001bae:	1be90913          	addi	s2,s2,446 # 80230d68 <pid_lock>
    80001bb2:	854a                	mv	a0,s2
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	196080e7          	jalr	406(ra) # 80000d4a <acquire>
  pid = nextpid;
    80001bbc:	00007797          	auipc	a5,0x7
    80001bc0:	dc878793          	addi	a5,a5,-568 # 80008984 <nextpid>
    80001bc4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bc6:	0014871b          	addiw	a4,s1,1
    80001bca:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bcc:	854a                	mv	a0,s2
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	230080e7          	jalr	560(ra) # 80000dfe <release>
}
    80001bd6:	8526                	mv	a0,s1
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6902                	ld	s2,0(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret

0000000080001be4 <proc_pagetable>:
{
    80001be4:	1101                	addi	sp,sp,-32
    80001be6:	ec06                	sd	ra,24(sp)
    80001be8:	e822                	sd	s0,16(sp)
    80001bea:	e426                	sd	s1,8(sp)
    80001bec:	e04a                	sd	s2,0(sp)
    80001bee:	1000                	addi	s0,sp,32
    80001bf0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bf2:	00000097          	auipc	ra,0x0
    80001bf6:	8aa080e7          	jalr	-1878(ra) # 8000149c <uvmcreate>
    80001bfa:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001bfc:	c121                	beqz	a0,80001c3c <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bfe:	4729                	li	a4,10
    80001c00:	00005697          	auipc	a3,0x5
    80001c04:	40068693          	addi	a3,a3,1024 # 80007000 <_trampoline>
    80001c08:	6605                	lui	a2,0x1
    80001c0a:	040005b7          	lui	a1,0x4000
    80001c0e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c10:	05b2                	slli	a1,a1,0xc
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	600080e7          	jalr	1536(ra) # 80001212 <mappages>
    80001c1a:	02054863          	bltz	a0,80001c4a <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c1e:	4719                	li	a4,6
    80001c20:	05893683          	ld	a3,88(s2)
    80001c24:	6605                	lui	a2,0x1
    80001c26:	020005b7          	lui	a1,0x2000
    80001c2a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c2c:	05b6                	slli	a1,a1,0xd
    80001c2e:	8526                	mv	a0,s1
    80001c30:	fffff097          	auipc	ra,0xfffff
    80001c34:	5e2080e7          	jalr	1506(ra) # 80001212 <mappages>
    80001c38:	02054163          	bltz	a0,80001c5a <proc_pagetable+0x76>
}
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	60e2                	ld	ra,24(sp)
    80001c40:	6442                	ld	s0,16(sp)
    80001c42:	64a2                	ld	s1,8(sp)
    80001c44:	6902                	ld	s2,0(sp)
    80001c46:	6105                	addi	sp,sp,32
    80001c48:	8082                	ret
    uvmfree(pagetable, 0);
    80001c4a:	4581                	li	a1,0
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	00000097          	auipc	ra,0x0
    80001c52:	a54080e7          	jalr	-1452(ra) # 800016a2 <uvmfree>
    return 0;
    80001c56:	4481                	li	s1,0
    80001c58:	b7d5                	j	80001c3c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c5a:	4681                	li	a3,0
    80001c5c:	4605                	li	a2,1
    80001c5e:	040005b7          	lui	a1,0x4000
    80001c62:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c64:	05b2                	slli	a1,a1,0xc
    80001c66:	8526                	mv	a0,s1
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	770080e7          	jalr	1904(ra) # 800013d8 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c70:	4581                	li	a1,0
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	a2e080e7          	jalr	-1490(ra) # 800016a2 <uvmfree>
    return 0;
    80001c7c:	4481                	li	s1,0
    80001c7e:	bf7d                	j	80001c3c <proc_pagetable+0x58>

0000000080001c80 <proc_freepagetable>:
{
    80001c80:	1101                	addi	sp,sp,-32
    80001c82:	ec06                	sd	ra,24(sp)
    80001c84:	e822                	sd	s0,16(sp)
    80001c86:	e426                	sd	s1,8(sp)
    80001c88:	e04a                	sd	s2,0(sp)
    80001c8a:	1000                	addi	s0,sp,32
    80001c8c:	84aa                	mv	s1,a0
    80001c8e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c90:	4681                	li	a3,0
    80001c92:	4605                	li	a2,1
    80001c94:	040005b7          	lui	a1,0x4000
    80001c98:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c9a:	05b2                	slli	a1,a1,0xc
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	73c080e7          	jalr	1852(ra) # 800013d8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ca4:	4681                	li	a3,0
    80001ca6:	4605                	li	a2,1
    80001ca8:	020005b7          	lui	a1,0x2000
    80001cac:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cae:	05b6                	slli	a1,a1,0xd
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	726080e7          	jalr	1830(ra) # 800013d8 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cba:	85ca                	mv	a1,s2
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	00000097          	auipc	ra,0x0
    80001cc2:	9e4080e7          	jalr	-1564(ra) # 800016a2 <uvmfree>
}
    80001cc6:	60e2                	ld	ra,24(sp)
    80001cc8:	6442                	ld	s0,16(sp)
    80001cca:	64a2                	ld	s1,8(sp)
    80001ccc:	6902                	ld	s2,0(sp)
    80001cce:	6105                	addi	sp,sp,32
    80001cd0:	8082                	ret

0000000080001cd2 <freeproc>:
{
    80001cd2:	1101                	addi	sp,sp,-32
    80001cd4:	ec06                	sd	ra,24(sp)
    80001cd6:	e822                	sd	s0,16(sp)
    80001cd8:	e426                	sd	s1,8(sp)
    80001cda:	1000                	addi	s0,sp,32
    80001cdc:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001cde:	6d28                	ld	a0,88(a0)
    80001ce0:	c509                	beqz	a0,80001cea <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	d96080e7          	jalr	-618(ra) # 80000a78 <kfree>
  p->trapframe = 0;
    80001cea:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001cee:	68a8                	ld	a0,80(s1)
    80001cf0:	c511                	beqz	a0,80001cfc <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001cf2:	64ac                	ld	a1,72(s1)
    80001cf4:	00000097          	auipc	ra,0x0
    80001cf8:	f8c080e7          	jalr	-116(ra) # 80001c80 <proc_freepagetable>
  p->pagetable = 0;
    80001cfc:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d00:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d04:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d08:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d0c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d10:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d14:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d18:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d1c:	0004ac23          	sw	zero,24(s1)
}
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6105                	addi	sp,sp,32
    80001d28:	8082                	ret

0000000080001d2a <allocproc>:
{
    80001d2a:	1101                	addi	sp,sp,-32
    80001d2c:	ec06                	sd	ra,24(sp)
    80001d2e:	e822                	sd	s0,16(sp)
    80001d30:	e426                	sd	s1,8(sp)
    80001d32:	e04a                	sd	s2,0(sp)
    80001d34:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001d36:	0022f497          	auipc	s1,0x22f
    80001d3a:	46248493          	addi	s1,s1,1122 # 80231198 <proc>
    80001d3e:	00236917          	auipc	s2,0x236
    80001d42:	45a90913          	addi	s2,s2,1114 # 80238198 <mlfq>
    acquire(&p->lock);
    80001d46:	8526                	mv	a0,s1
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	002080e7          	jalr	2(ra) # 80000d4a <acquire>
    if (p->state == UNUSED)
    80001d50:	4c9c                	lw	a5,24(s1)
    80001d52:	cf81                	beqz	a5,80001d6a <allocproc+0x40>
      release(&p->lock);
    80001d54:	8526                	mv	a0,s1
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	0a8080e7          	jalr	168(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001d5e:	1c048493          	addi	s1,s1,448
    80001d62:	ff2492e3          	bne	s1,s2,80001d46 <allocproc+0x1c>
  return 0;
    80001d66:	4481                	li	s1,0
    80001d68:	a84d                	j	80001e1a <allocproc+0xf0>
  p->pid = allocpid();
    80001d6a:	00000097          	auipc	ra,0x0
    80001d6e:	e34080e7          	jalr	-460(ra) # 80001b9e <allocpid>
    80001d72:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d74:	4785                	li	a5,1
    80001d76:	cc9c                	sw	a5,24(s1)
  p->number_of_times_scheduled = 0;
    80001d78:	1604ac23          	sw	zero,376(s1)
  p->sleeping_ticks = 0;
    80001d7c:	1804a223          	sw	zero,388(s1)
  p->running_ticks = 0;
    80001d80:	1804a423          	sw	zero,392(s1)
  p->sleep_start = 0;
    80001d84:	1604ae23          	sw	zero,380(s1)
  p->reset_niceness = 1;
    80001d88:	18f4a023          	sw	a5,384(s1)
  p->level = 0;
    80001d8c:	1804a623          	sw	zero,396(s1)
  p->change_queue = 1 << p->level;
    80001d90:	18f4aa23          	sw	a5,404(s1)
  p->in_queue = 0;
    80001d94:	1804a823          	sw	zero,400(s1)
  p->enter_ticks = ticks;
    80001d98:	00007797          	auipc	a5,0x7
    80001d9c:	d507a783          	lw	a5,-688(a5) # 80008ae8 <ticks>
    80001da0:	18f4ac23          	sw	a5,408(s1)
  p->now_ticks = 0;
    80001da4:	1a04a623          	sw	zero,428(s1)
  p->sigalarm_status = 0;
    80001da8:	1a04ac23          	sw	zero,440(s1)
  p->interval = 0;
    80001dac:	1a04a423          	sw	zero,424(s1)
  p->handler = -1;
    80001db0:	57fd                	li	a5,-1
    80001db2:	1af4b023          	sd	a5,416(s1)
  p->alarm_trapframe = NULL;
    80001db6:	1a04b823          	sd	zero,432(s1)
  if (forked_process && p->parent)
    80001dba:	00007797          	auipc	a5,0x7
    80001dbe:	d1e7a783          	lw	a5,-738(a5) # 80008ad8 <forked_process>
    80001dc2:	e3bd                	bnez	a5,80001e28 <allocproc+0xfe>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	e8c080e7          	jalr	-372(ra) # 80000c50 <kalloc>
    80001dcc:	892a                	mv	s2,a0
    80001dce:	eca8                	sd	a0,88(s1)
    80001dd0:	c13d                	beqz	a0,80001e36 <allocproc+0x10c>
  p->pagetable = proc_pagetable(p);
    80001dd2:	8526                	mv	a0,s1
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	e10080e7          	jalr	-496(ra) # 80001be4 <proc_pagetable>
    80001ddc:	892a                	mv	s2,a0
    80001dde:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001de0:	c53d                	beqz	a0,80001e4e <allocproc+0x124>
  memset(&p->context, 0, sizeof(p->context));
    80001de2:	07000613          	li	a2,112
    80001de6:	4581                	li	a1,0
    80001de8:	06048513          	addi	a0,s1,96
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	05a080e7          	jalr	90(ra) # 80000e46 <memset>
  p->context.ra = (uint64)forkret;
    80001df4:	00000797          	auipc	a5,0x0
    80001df8:	d6478793          	addi	a5,a5,-668 # 80001b58 <forkret>
    80001dfc:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001dfe:	60bc                	ld	a5,64(s1)
    80001e00:	6705                	lui	a4,0x1
    80001e02:	97ba                	add	a5,a5,a4
    80001e04:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001e06:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001e0a:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001e0e:	00007797          	auipc	a5,0x7
    80001e12:	cda7a783          	lw	a5,-806(a5) # 80008ae8 <ticks>
    80001e16:	16f4a623          	sw	a5,364(s1)
}
    80001e1a:	8526                	mv	a0,s1
    80001e1c:	60e2                	ld	ra,24(sp)
    80001e1e:	6442                	ld	s0,16(sp)
    80001e20:	64a2                	ld	s1,8(sp)
    80001e22:	6902                	ld	s2,0(sp)
    80001e24:	6105                	addi	sp,sp,32
    80001e26:	8082                	ret
  if (forked_process && p->parent)
    80001e28:	7c9c                	ld	a5,56(s1)
    80001e2a:	dfc9                	beqz	a5,80001dc4 <allocproc+0x9a>
    forked_process = 0;
    80001e2c:	00007797          	auipc	a5,0x7
    80001e30:	ca07a623          	sw	zero,-852(a5) # 80008ad8 <forked_process>
    80001e34:	bf41                	j	80001dc4 <allocproc+0x9a>
    freeproc(p);
    80001e36:	8526                	mv	a0,s1
    80001e38:	00000097          	auipc	ra,0x0
    80001e3c:	e9a080e7          	jalr	-358(ra) # 80001cd2 <freeproc>
    release(&p->lock);
    80001e40:	8526                	mv	a0,s1
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	fbc080e7          	jalr	-68(ra) # 80000dfe <release>
    return 0;
    80001e4a:	84ca                	mv	s1,s2
    80001e4c:	b7f9                	j	80001e1a <allocproc+0xf0>
    freeproc(p);
    80001e4e:	8526                	mv	a0,s1
    80001e50:	00000097          	auipc	ra,0x0
    80001e54:	e82080e7          	jalr	-382(ra) # 80001cd2 <freeproc>
    release(&p->lock);
    80001e58:	8526                	mv	a0,s1
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	fa4080e7          	jalr	-92(ra) # 80000dfe <release>
    return 0;
    80001e62:	84ca                	mv	s1,s2
    80001e64:	bf5d                	j	80001e1a <allocproc+0xf0>

0000000080001e66 <userinit>:
{
    80001e66:	1101                	addi	sp,sp,-32
    80001e68:	ec06                	sd	ra,24(sp)
    80001e6a:	e822                	sd	s0,16(sp)
    80001e6c:	e426                	sd	s1,8(sp)
    80001e6e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e70:	00000097          	auipc	ra,0x0
    80001e74:	eba080e7          	jalr	-326(ra) # 80001d2a <allocproc>
    80001e78:	84aa                	mv	s1,a0
  initproc = p;
    80001e7a:	00007797          	auipc	a5,0x7
    80001e7e:	c6a7b323          	sd	a0,-922(a5) # 80008ae0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e82:	03400613          	li	a2,52
    80001e86:	00007597          	auipc	a1,0x7
    80001e8a:	b0a58593          	addi	a1,a1,-1270 # 80008990 <initcode>
    80001e8e:	6928                	ld	a0,80(a0)
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	63a080e7          	jalr	1594(ra) # 800014ca <uvmfirst>
  p->sz = PGSIZE;
    80001e98:	6785                	lui	a5,0x1
    80001e9a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001e9c:	6cb8                	ld	a4,88(s1)
    80001e9e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001ea2:	6cb8                	ld	a4,88(s1)
    80001ea4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ea6:	4641                	li	a2,16
    80001ea8:	00006597          	auipc	a1,0x6
    80001eac:	39858593          	addi	a1,a1,920 # 80008240 <digits+0x200>
    80001eb0:	15848513          	addi	a0,s1,344
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	0dc080e7          	jalr	220(ra) # 80000f90 <safestrcpy>
  p->cwd = namei("/");
    80001ebc:	00006517          	auipc	a0,0x6
    80001ec0:	39450513          	addi	a0,a0,916 # 80008250 <digits+0x210>
    80001ec4:	00002097          	auipc	ra,0x2
    80001ec8:	43a080e7          	jalr	1082(ra) # 800042fe <namei>
    80001ecc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ed0:	478d                	li	a5,3
    80001ed2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	f28080e7          	jalr	-216(ra) # 80000dfe <release>
}
    80001ede:	60e2                	ld	ra,24(sp)
    80001ee0:	6442                	ld	s0,16(sp)
    80001ee2:	64a2                	ld	s1,8(sp)
    80001ee4:	6105                	addi	sp,sp,32
    80001ee6:	8082                	ret

0000000080001ee8 <growproc>:
{
    80001ee8:	1101                	addi	sp,sp,-32
    80001eea:	ec06                	sd	ra,24(sp)
    80001eec:	e822                	sd	s0,16(sp)
    80001eee:	e426                	sd	s1,8(sp)
    80001ef0:	e04a                	sd	s2,0(sp)
    80001ef2:	1000                	addi	s0,sp,32
    80001ef4:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001ef6:	00000097          	auipc	ra,0x0
    80001efa:	c2a080e7          	jalr	-982(ra) # 80001b20 <myproc>
    80001efe:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f00:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001f02:	01204c63          	bgtz	s2,80001f1a <growproc+0x32>
  else if (n < 0)
    80001f06:	02094663          	bltz	s2,80001f32 <growproc+0x4a>
  p->sz = sz;
    80001f0a:	e4ac                	sd	a1,72(s1)
  return 0;
    80001f0c:	4501                	li	a0,0
}
    80001f0e:	60e2                	ld	ra,24(sp)
    80001f10:	6442                	ld	s0,16(sp)
    80001f12:	64a2                	ld	s1,8(sp)
    80001f14:	6902                	ld	s2,0(sp)
    80001f16:	6105                	addi	sp,sp,32
    80001f18:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f1a:	4691                	li	a3,4
    80001f1c:	00b90633          	add	a2,s2,a1
    80001f20:	6928                	ld	a0,80(a0)
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	662080e7          	jalr	1634(ra) # 80001584 <uvmalloc>
    80001f2a:	85aa                	mv	a1,a0
    80001f2c:	fd79                	bnez	a0,80001f0a <growproc+0x22>
      return -1;
    80001f2e:	557d                	li	a0,-1
    80001f30:	bff9                	j	80001f0e <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f32:	00b90633          	add	a2,s2,a1
    80001f36:	6928                	ld	a0,80(a0)
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	604080e7          	jalr	1540(ra) # 8000153c <uvmdealloc>
    80001f40:	85aa                	mv	a1,a0
    80001f42:	b7e1                	j	80001f0a <growproc+0x22>

0000000080001f44 <fork>:
{
    80001f44:	7139                	addi	sp,sp,-64
    80001f46:	fc06                	sd	ra,56(sp)
    80001f48:	f822                	sd	s0,48(sp)
    80001f4a:	f426                	sd	s1,40(sp)
    80001f4c:	f04a                	sd	s2,32(sp)
    80001f4e:	ec4e                	sd	s3,24(sp)
    80001f50:	e852                	sd	s4,16(sp)
    80001f52:	e456                	sd	s5,8(sp)
    80001f54:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001f56:	00000097          	auipc	ra,0x0
    80001f5a:	bca080e7          	jalr	-1078(ra) # 80001b20 <myproc>
    80001f5e:	8aaa                	mv	s5,a0
  if (p->pid > 1)
    80001f60:	5918                	lw	a4,48(a0)
    80001f62:	4785                	li	a5,1
    80001f64:	00e7d663          	bge	a5,a4,80001f70 <fork+0x2c>
    forked_process = 1;
    80001f68:	00007717          	auipc	a4,0x7
    80001f6c:	b6f72823          	sw	a5,-1168(a4) # 80008ad8 <forked_process>
  if ((np = allocproc()) == 0)
    80001f70:	00000097          	auipc	ra,0x0
    80001f74:	dba080e7          	jalr	-582(ra) # 80001d2a <allocproc>
    80001f78:	89aa                	mv	s3,a0
    80001f7a:	10050f63          	beqz	a0,80002098 <fork+0x154>
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001f7e:	048ab603          	ld	a2,72(s5)
    80001f82:	692c                	ld	a1,80(a0)
    80001f84:	050ab503          	ld	a0,80(s5)
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	754080e7          	jalr	1876(ra) # 800016dc <uvmcopy>
    80001f90:	04054c63          	bltz	a0,80001fe8 <fork+0xa4>
  np->sz = p->sz;
    80001f94:	048ab783          	ld	a5,72(s5)
    80001f98:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f9c:	058ab683          	ld	a3,88(s5)
    80001fa0:	87b6                	mv	a5,a3
    80001fa2:	0589b703          	ld	a4,88(s3)
    80001fa6:	12068693          	addi	a3,a3,288
    80001faa:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001fae:	6788                	ld	a0,8(a5)
    80001fb0:	6b8c                	ld	a1,16(a5)
    80001fb2:	6f90                	ld	a2,24(a5)
    80001fb4:	01073023          	sd	a6,0(a4)
    80001fb8:	e708                	sd	a0,8(a4)
    80001fba:	eb0c                	sd	a1,16(a4)
    80001fbc:	ef10                	sd	a2,24(a4)
    80001fbe:	02078793          	addi	a5,a5,32
    80001fc2:	02070713          	addi	a4,a4,32
    80001fc6:	fed792e3          	bne	a5,a3,80001faa <fork+0x66>
  np->tmask = p->tmask;
    80001fca:	174aa783          	lw	a5,372(s5)
    80001fce:	16f9aa23          	sw	a5,372(s3)
  np->trapframe->a0 = 0;
    80001fd2:	0589b783          	ld	a5,88(s3)
    80001fd6:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001fda:	0d0a8493          	addi	s1,s5,208
    80001fde:	0d098913          	addi	s2,s3,208
    80001fe2:	150a8a13          	addi	s4,s5,336
    80001fe6:	a00d                	j	80002008 <fork+0xc4>
    freeproc(np);
    80001fe8:	854e                	mv	a0,s3
    80001fea:	00000097          	auipc	ra,0x0
    80001fee:	ce8080e7          	jalr	-792(ra) # 80001cd2 <freeproc>
    release(&np->lock);
    80001ff2:	854e                	mv	a0,s3
    80001ff4:	fffff097          	auipc	ra,0xfffff
    80001ff8:	e0a080e7          	jalr	-502(ra) # 80000dfe <release>
    return -1;
    80001ffc:	597d                	li	s2,-1
    80001ffe:	a059                	j	80002084 <fork+0x140>
  for (i = 0; i < NOFILE; i++)
    80002000:	04a1                	addi	s1,s1,8
    80002002:	0921                	addi	s2,s2,8
    80002004:	01448b63          	beq	s1,s4,8000201a <fork+0xd6>
    if (p->ofile[i])
    80002008:	6088                	ld	a0,0(s1)
    8000200a:	d97d                	beqz	a0,80002000 <fork+0xbc>
      np->ofile[i] = filedup(p->ofile[i]);
    8000200c:	00003097          	auipc	ra,0x3
    80002010:	988080e7          	jalr	-1656(ra) # 80004994 <filedup>
    80002014:	00a93023          	sd	a0,0(s2)
    80002018:	b7e5                	j	80002000 <fork+0xbc>
  np->cwd = idup(p->cwd);
    8000201a:	150ab503          	ld	a0,336(s5)
    8000201e:	00002097          	auipc	ra,0x2
    80002022:	af6080e7          	jalr	-1290(ra) # 80003b14 <idup>
    80002026:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000202a:	4641                	li	a2,16
    8000202c:	158a8593          	addi	a1,s5,344
    80002030:	15898513          	addi	a0,s3,344
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	f5c080e7          	jalr	-164(ra) # 80000f90 <safestrcpy>
  pid = np->pid;
    8000203c:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002040:	854e                	mv	a0,s3
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	dbc080e7          	jalr	-580(ra) # 80000dfe <release>
  acquire(&wait_lock);
    8000204a:	0022f497          	auipc	s1,0x22f
    8000204e:	d3648493          	addi	s1,s1,-714 # 80230d80 <wait_lock>
    80002052:	8526                	mv	a0,s1
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	cf6080e7          	jalr	-778(ra) # 80000d4a <acquire>
  np->parent = p;
    8000205c:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002060:	8526                	mv	a0,s1
    80002062:	fffff097          	auipc	ra,0xfffff
    80002066:	d9c080e7          	jalr	-612(ra) # 80000dfe <release>
  acquire(&np->lock);
    8000206a:	854e                	mv	a0,s3
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	cde080e7          	jalr	-802(ra) # 80000d4a <acquire>
  np->state = RUNNABLE;
    80002074:	478d                	li	a5,3
    80002076:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000207a:	854e                	mv	a0,s3
    8000207c:	fffff097          	auipc	ra,0xfffff
    80002080:	d82080e7          	jalr	-638(ra) # 80000dfe <release>
}
    80002084:	854a                	mv	a0,s2
    80002086:	70e2                	ld	ra,56(sp)
    80002088:	7442                	ld	s0,48(sp)
    8000208a:	74a2                	ld	s1,40(sp)
    8000208c:	7902                	ld	s2,32(sp)
    8000208e:	69e2                	ld	s3,24(sp)
    80002090:	6a42                	ld	s4,16(sp)
    80002092:	6aa2                	ld	s5,8(sp)
    80002094:	6121                	addi	sp,sp,64
    80002096:	8082                	ret
    return -1;
    80002098:	597d                	li	s2,-1
    8000209a:	b7ed                	j	80002084 <fork+0x140>

000000008000209c <scheduler>:
{
    8000209c:	7139                	addi	sp,sp,-64
    8000209e:	fc06                	sd	ra,56(sp)
    800020a0:	f822                	sd	s0,48(sp)
    800020a2:	f426                	sd	s1,40(sp)
    800020a4:	f04a                	sd	s2,32(sp)
    800020a6:	ec4e                	sd	s3,24(sp)
    800020a8:	e852                	sd	s4,16(sp)
    800020aa:	e456                	sd	s5,8(sp)
    800020ac:	e05a                	sd	s6,0(sp)
    800020ae:	0080                	addi	s0,sp,64
    800020b0:	8792                	mv	a5,tp
  int id = r_tp();
    800020b2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800020b4:	00779a93          	slli	s5,a5,0x7
    800020b8:	0022f717          	auipc	a4,0x22f
    800020bc:	cb070713          	addi	a4,a4,-848 # 80230d68 <pid_lock>
    800020c0:	9756                	add	a4,a4,s5
    800020c2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800020c6:	0022f717          	auipc	a4,0x22f
    800020ca:	cda70713          	addi	a4,a4,-806 # 80230da0 <cpus+0x8>
    800020ce:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    800020d0:	498d                	li	s3,3
        p->state = RUNNING;
    800020d2:	4b11                	li	s6,4
        c->proc = p;
    800020d4:	079e                	slli	a5,a5,0x7
    800020d6:	0022fa17          	auipc	s4,0x22f
    800020da:	c92a0a13          	addi	s4,s4,-878 # 80230d68 <pid_lock>
    800020de:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800020e0:	00236917          	auipc	s2,0x236
    800020e4:	0b890913          	addi	s2,s2,184 # 80238198 <mlfq>
  asm volatile("csrr %0, sstatus"
    800020e8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020ec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    800020f0:	10079073          	csrw	sstatus,a5
    800020f4:	0022f497          	auipc	s1,0x22f
    800020f8:	0a448493          	addi	s1,s1,164 # 80231198 <proc>
    800020fc:	a811                	j	80002110 <scheduler+0x74>
      release(&p->lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	cfe080e7          	jalr	-770(ra) # 80000dfe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002108:	1c048493          	addi	s1,s1,448
    8000210c:	fd248ee3          	beq	s1,s2,800020e8 <scheduler+0x4c>
      acquire(&p->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	c38080e7          	jalr	-968(ra) # 80000d4a <acquire>
      if (p->state == RUNNABLE)
    8000211a:	4c9c                	lw	a5,24(s1)
    8000211c:	ff3791e3          	bne	a5,s3,800020fe <scheduler+0x62>
        p->state = RUNNING;
    80002120:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002124:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002128:	06048593          	addi	a1,s1,96
    8000212c:	8556                	mv	a0,s5
    8000212e:	00001097          	auipc	ra,0x1
    80002132:	868080e7          	jalr	-1944(ra) # 80002996 <swtch>
        c->proc = 0;
    80002136:	020a3823          	sd	zero,48(s4)
    8000213a:	b7d1                	j	800020fe <scheduler+0x62>

000000008000213c <sched>:
{
    8000213c:	7179                	addi	sp,sp,-48
    8000213e:	f406                	sd	ra,40(sp)
    80002140:	f022                	sd	s0,32(sp)
    80002142:	ec26                	sd	s1,24(sp)
    80002144:	e84a                	sd	s2,16(sp)
    80002146:	e44e                	sd	s3,8(sp)
    80002148:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000214a:	00000097          	auipc	ra,0x0
    8000214e:	9d6080e7          	jalr	-1578(ra) # 80001b20 <myproc>
    80002152:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	b7c080e7          	jalr	-1156(ra) # 80000cd0 <holding>
    8000215c:	c93d                	beqz	a0,800021d2 <sched+0x96>
  asm volatile("mv %0, tp"
    8000215e:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002160:	2781                	sext.w	a5,a5
    80002162:	079e                	slli	a5,a5,0x7
    80002164:	0022f717          	auipc	a4,0x22f
    80002168:	c0470713          	addi	a4,a4,-1020 # 80230d68 <pid_lock>
    8000216c:	97ba                	add	a5,a5,a4
    8000216e:	0a87a703          	lw	a4,168(a5)
    80002172:	4785                	li	a5,1
    80002174:	06f71763          	bne	a4,a5,800021e2 <sched+0xa6>
  if (p->state == RUNNING)
    80002178:	4c98                	lw	a4,24(s1)
    8000217a:	4791                	li	a5,4
    8000217c:	06f70b63          	beq	a4,a5,800021f2 <sched+0xb6>
  asm volatile("csrr %0, sstatus"
    80002180:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002184:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002186:	efb5                	bnez	a5,80002202 <sched+0xc6>
  asm volatile("mv %0, tp"
    80002188:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000218a:	0022f917          	auipc	s2,0x22f
    8000218e:	bde90913          	addi	s2,s2,-1058 # 80230d68 <pid_lock>
    80002192:	2781                	sext.w	a5,a5
    80002194:	079e                	slli	a5,a5,0x7
    80002196:	97ca                	add	a5,a5,s2
    80002198:	0ac7a983          	lw	s3,172(a5)
    8000219c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000219e:	2781                	sext.w	a5,a5
    800021a0:	079e                	slli	a5,a5,0x7
    800021a2:	0022f597          	auipc	a1,0x22f
    800021a6:	bfe58593          	addi	a1,a1,-1026 # 80230da0 <cpus+0x8>
    800021aa:	95be                	add	a1,a1,a5
    800021ac:	06048513          	addi	a0,s1,96
    800021b0:	00000097          	auipc	ra,0x0
    800021b4:	7e6080e7          	jalr	2022(ra) # 80002996 <swtch>
    800021b8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021ba:	2781                	sext.w	a5,a5
    800021bc:	079e                	slli	a5,a5,0x7
    800021be:	993e                	add	s2,s2,a5
    800021c0:	0b392623          	sw	s3,172(s2)
}
    800021c4:	70a2                	ld	ra,40(sp)
    800021c6:	7402                	ld	s0,32(sp)
    800021c8:	64e2                	ld	s1,24(sp)
    800021ca:	6942                	ld	s2,16(sp)
    800021cc:	69a2                	ld	s3,8(sp)
    800021ce:	6145                	addi	sp,sp,48
    800021d0:	8082                	ret
    panic("sched p->lock");
    800021d2:	00006517          	auipc	a0,0x6
    800021d6:	08650513          	addi	a0,a0,134 # 80008258 <digits+0x218>
    800021da:	ffffe097          	auipc	ra,0xffffe
    800021de:	366080e7          	jalr	870(ra) # 80000540 <panic>
    panic("sched locks");
    800021e2:	00006517          	auipc	a0,0x6
    800021e6:	08650513          	addi	a0,a0,134 # 80008268 <digits+0x228>
    800021ea:	ffffe097          	auipc	ra,0xffffe
    800021ee:	356080e7          	jalr	854(ra) # 80000540 <panic>
    panic("sched running");
    800021f2:	00006517          	auipc	a0,0x6
    800021f6:	08650513          	addi	a0,a0,134 # 80008278 <digits+0x238>
    800021fa:	ffffe097          	auipc	ra,0xffffe
    800021fe:	346080e7          	jalr	838(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002202:	00006517          	auipc	a0,0x6
    80002206:	08650513          	addi	a0,a0,134 # 80008288 <digits+0x248>
    8000220a:	ffffe097          	auipc	ra,0xffffe
    8000220e:	336080e7          	jalr	822(ra) # 80000540 <panic>

0000000080002212 <yield>:
{
    80002212:	1101                	addi	sp,sp,-32
    80002214:	ec06                	sd	ra,24(sp)
    80002216:	e822                	sd	s0,16(sp)
    80002218:	e426                	sd	s1,8(sp)
    8000221a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000221c:	00000097          	auipc	ra,0x0
    80002220:	904080e7          	jalr	-1788(ra) # 80001b20 <myproc>
    80002224:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	b24080e7          	jalr	-1244(ra) # 80000d4a <acquire>
  p->state = RUNNABLE;
    8000222e:	478d                	li	a5,3
    80002230:	cc9c                	sw	a5,24(s1)
  sched();
    80002232:	00000097          	auipc	ra,0x0
    80002236:	f0a080e7          	jalr	-246(ra) # 8000213c <sched>
  release(&p->lock);
    8000223a:	8526                	mv	a0,s1
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	bc2080e7          	jalr	-1086(ra) # 80000dfe <release>
}
    80002244:	60e2                	ld	ra,24(sp)
    80002246:	6442                	ld	s0,16(sp)
    80002248:	64a2                	ld	s1,8(sp)
    8000224a:	6105                	addi	sp,sp,32
    8000224c:	8082                	ret

000000008000224e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000224e:	7179                	addi	sp,sp,-48
    80002250:	f406                	sd	ra,40(sp)
    80002252:	f022                	sd	s0,32(sp)
    80002254:	ec26                	sd	s1,24(sp)
    80002256:	e84a                	sd	s2,16(sp)
    80002258:	e44e                	sd	s3,8(sp)
    8000225a:	1800                	addi	s0,sp,48
    8000225c:	89aa                	mv	s3,a0
    8000225e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002260:	00000097          	auipc	ra,0x0
    80002264:	8c0080e7          	jalr	-1856(ra) # 80001b20 <myproc>
    80002268:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	ae0080e7          	jalr	-1312(ra) # 80000d4a <acquire>
  release(lk);
    80002272:	854a                	mv	a0,s2
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	b8a080e7          	jalr	-1142(ra) # 80000dfe <release>

  // Go to sleep.
  p->sleep_start = ticks;
    8000227c:	00007797          	auipc	a5,0x7
    80002280:	86c7a783          	lw	a5,-1940(a5) # 80008ae8 <ticks>
    80002284:	16f4ae23          	sw	a5,380(s1)
  p->chan = chan;
    80002288:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000228c:	4789                	li	a5,2
    8000228e:	cc9c                	sw	a5,24(s1)

  sched();
    80002290:	00000097          	auipc	ra,0x0
    80002294:	eac080e7          	jalr	-340(ra) # 8000213c <sched>

  // Tidy up.
  p->chan = 0;
    80002298:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000229c:	8526                	mv	a0,s1
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	b60080e7          	jalr	-1184(ra) # 80000dfe <release>
  acquire(lk);
    800022a6:	854a                	mv	a0,s2
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	aa2080e7          	jalr	-1374(ra) # 80000d4a <acquire>
}
    800022b0:	70a2                	ld	ra,40(sp)
    800022b2:	7402                	ld	s0,32(sp)
    800022b4:	64e2                	ld	s1,24(sp)
    800022b6:	6942                	ld	s2,16(sp)
    800022b8:	69a2                	ld	s3,8(sp)
    800022ba:	6145                	addi	sp,sp,48
    800022bc:	8082                	ret

00000000800022be <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800022be:	7139                	addi	sp,sp,-64
    800022c0:	fc06                	sd	ra,56(sp)
    800022c2:	f822                	sd	s0,48(sp)
    800022c4:	f426                	sd	s1,40(sp)
    800022c6:	f04a                	sd	s2,32(sp)
    800022c8:	ec4e                	sd	s3,24(sp)
    800022ca:	e852                	sd	s4,16(sp)
    800022cc:	e456                	sd	s5,8(sp)
    800022ce:	e05a                	sd	s6,0(sp)
    800022d0:	0080                	addi	s0,sp,64
    800022d2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800022d4:	0022f497          	auipc	s1,0x22f
    800022d8:	ec448493          	addi	s1,s1,-316 # 80231198 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800022dc:	4989                	li	s3,2
      {
        p->sleeping_ticks += (ticks - p->sleep_start);
    800022de:	00007b17          	auipc	s6,0x7
    800022e2:	80ab0b13          	addi	s6,s6,-2038 # 80008ae8 <ticks>
        p->state = RUNNABLE;
    800022e6:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800022e8:	00236917          	auipc	s2,0x236
    800022ec:	eb090913          	addi	s2,s2,-336 # 80238198 <mlfq>
    800022f0:	a811                	j	80002304 <wakeup+0x46>
      }
      release(&p->lock);
    800022f2:	8526                	mv	a0,s1
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	b0a080e7          	jalr	-1270(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800022fc:	1c048493          	addi	s1,s1,448
    80002300:	05248063          	beq	s1,s2,80002340 <wakeup+0x82>
    if (p != myproc())
    80002304:	00000097          	auipc	ra,0x0
    80002308:	81c080e7          	jalr	-2020(ra) # 80001b20 <myproc>
    8000230c:	fea488e3          	beq	s1,a0,800022fc <wakeup+0x3e>
      acquire(&p->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	a38080e7          	jalr	-1480(ra) # 80000d4a <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000231a:	4c9c                	lw	a5,24(s1)
    8000231c:	fd379be3          	bne	a5,s3,800022f2 <wakeup+0x34>
    80002320:	709c                	ld	a5,32(s1)
    80002322:	fd4798e3          	bne	a5,s4,800022f2 <wakeup+0x34>
        p->sleeping_ticks += (ticks - p->sleep_start);
    80002326:	1844a703          	lw	a4,388(s1)
    8000232a:	000b2783          	lw	a5,0(s6)
    8000232e:	9fb9                	addw	a5,a5,a4
    80002330:	17c4a703          	lw	a4,380(s1)
    80002334:	9f99                	subw	a5,a5,a4
    80002336:	18f4a223          	sw	a5,388(s1)
        p->state = RUNNABLE;
    8000233a:	0154ac23          	sw	s5,24(s1)
    8000233e:	bf55                	j	800022f2 <wakeup+0x34>
    }
  }
}
    80002340:	70e2                	ld	ra,56(sp)
    80002342:	7442                	ld	s0,48(sp)
    80002344:	74a2                	ld	s1,40(sp)
    80002346:	7902                	ld	s2,32(sp)
    80002348:	69e2                	ld	s3,24(sp)
    8000234a:	6a42                	ld	s4,16(sp)
    8000234c:	6aa2                	ld	s5,8(sp)
    8000234e:	6b02                	ld	s6,0(sp)
    80002350:	6121                	addi	sp,sp,64
    80002352:	8082                	ret

0000000080002354 <reparent>:
{
    80002354:	7179                	addi	sp,sp,-48
    80002356:	f406                	sd	ra,40(sp)
    80002358:	f022                	sd	s0,32(sp)
    8000235a:	ec26                	sd	s1,24(sp)
    8000235c:	e84a                	sd	s2,16(sp)
    8000235e:	e44e                	sd	s3,8(sp)
    80002360:	e052                	sd	s4,0(sp)
    80002362:	1800                	addi	s0,sp,48
    80002364:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002366:	0022f497          	auipc	s1,0x22f
    8000236a:	e3248493          	addi	s1,s1,-462 # 80231198 <proc>
      pp->parent = initproc;
    8000236e:	00006a17          	auipc	s4,0x6
    80002372:	772a0a13          	addi	s4,s4,1906 # 80008ae0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002376:	00236997          	auipc	s3,0x236
    8000237a:	e2298993          	addi	s3,s3,-478 # 80238198 <mlfq>
    8000237e:	a029                	j	80002388 <reparent+0x34>
    80002380:	1c048493          	addi	s1,s1,448
    80002384:	01348d63          	beq	s1,s3,8000239e <reparent+0x4a>
    if (pp->parent == p)
    80002388:	7c9c                	ld	a5,56(s1)
    8000238a:	ff279be3          	bne	a5,s2,80002380 <reparent+0x2c>
      pp->parent = initproc;
    8000238e:	000a3503          	ld	a0,0(s4)
    80002392:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002394:	00000097          	auipc	ra,0x0
    80002398:	f2a080e7          	jalr	-214(ra) # 800022be <wakeup>
    8000239c:	b7d5                	j	80002380 <reparent+0x2c>
}
    8000239e:	70a2                	ld	ra,40(sp)
    800023a0:	7402                	ld	s0,32(sp)
    800023a2:	64e2                	ld	s1,24(sp)
    800023a4:	6942                	ld	s2,16(sp)
    800023a6:	69a2                	ld	s3,8(sp)
    800023a8:	6a02                	ld	s4,0(sp)
    800023aa:	6145                	addi	sp,sp,48
    800023ac:	8082                	ret

00000000800023ae <exit>:
{
    800023ae:	7179                	addi	sp,sp,-48
    800023b0:	f406                	sd	ra,40(sp)
    800023b2:	f022                	sd	s0,32(sp)
    800023b4:	ec26                	sd	s1,24(sp)
    800023b6:	e84a                	sd	s2,16(sp)
    800023b8:	e44e                	sd	s3,8(sp)
    800023ba:	e052                	sd	s4,0(sp)
    800023bc:	1800                	addi	s0,sp,48
    800023be:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	760080e7          	jalr	1888(ra) # 80001b20 <myproc>
    800023c8:	89aa                	mv	s3,a0
  if (p == initproc)
    800023ca:	00006797          	auipc	a5,0x6
    800023ce:	7167b783          	ld	a5,1814(a5) # 80008ae0 <initproc>
    800023d2:	0d050493          	addi	s1,a0,208
    800023d6:	15050913          	addi	s2,a0,336
    800023da:	02a79363          	bne	a5,a0,80002400 <exit+0x52>
    panic("init exiting");
    800023de:	00006517          	auipc	a0,0x6
    800023e2:	ec250513          	addi	a0,a0,-318 # 800082a0 <digits+0x260>
    800023e6:	ffffe097          	auipc	ra,0xffffe
    800023ea:	15a080e7          	jalr	346(ra) # 80000540 <panic>
      fileclose(f);
    800023ee:	00002097          	auipc	ra,0x2
    800023f2:	5f8080e7          	jalr	1528(ra) # 800049e6 <fileclose>
      p->ofile[fd] = 0;
    800023f6:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800023fa:	04a1                	addi	s1,s1,8
    800023fc:	01248563          	beq	s1,s2,80002406 <exit+0x58>
    if (p->ofile[fd])
    80002400:	6088                	ld	a0,0(s1)
    80002402:	f575                	bnez	a0,800023ee <exit+0x40>
    80002404:	bfdd                	j	800023fa <exit+0x4c>
  begin_op();
    80002406:	00002097          	auipc	ra,0x2
    8000240a:	118080e7          	jalr	280(ra) # 8000451e <begin_op>
  iput(p->cwd);
    8000240e:	1509b503          	ld	a0,336(s3)
    80002412:	00002097          	auipc	ra,0x2
    80002416:	8fa080e7          	jalr	-1798(ra) # 80003d0c <iput>
  end_op();
    8000241a:	00002097          	auipc	ra,0x2
    8000241e:	182080e7          	jalr	386(ra) # 8000459c <end_op>
  p->cwd = 0;
    80002422:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002426:	0022f497          	auipc	s1,0x22f
    8000242a:	95a48493          	addi	s1,s1,-1702 # 80230d80 <wait_lock>
    8000242e:	8526                	mv	a0,s1
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	91a080e7          	jalr	-1766(ra) # 80000d4a <acquire>
  reparent(p);
    80002438:	854e                	mv	a0,s3
    8000243a:	00000097          	auipc	ra,0x0
    8000243e:	f1a080e7          	jalr	-230(ra) # 80002354 <reparent>
  wakeup(p->parent);
    80002442:	0389b503          	ld	a0,56(s3)
    80002446:	00000097          	auipc	ra,0x0
    8000244a:	e78080e7          	jalr	-392(ra) # 800022be <wakeup>
  acquire(&p->lock);
    8000244e:	854e                	mv	a0,s3
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	8fa080e7          	jalr	-1798(ra) # 80000d4a <acquire>
  p->xstate = status;
    80002458:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000245c:	4795                	li	a5,5
    8000245e:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002462:	00006797          	auipc	a5,0x6
    80002466:	6867a783          	lw	a5,1670(a5) # 80008ae8 <ticks>
    8000246a:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	98e080e7          	jalr	-1650(ra) # 80000dfe <release>
  sched();
    80002478:	00000097          	auipc	ra,0x0
    8000247c:	cc4080e7          	jalr	-828(ra) # 8000213c <sched>
  panic("zombie exit");
    80002480:	00006517          	auipc	a0,0x6
    80002484:	e3050513          	addi	a0,a0,-464 # 800082b0 <digits+0x270>
    80002488:	ffffe097          	auipc	ra,0xffffe
    8000248c:	0b8080e7          	jalr	184(ra) # 80000540 <panic>

0000000080002490 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002490:	7179                	addi	sp,sp,-48
    80002492:	f406                	sd	ra,40(sp)
    80002494:	f022                	sd	s0,32(sp)
    80002496:	ec26                	sd	s1,24(sp)
    80002498:	e84a                	sd	s2,16(sp)
    8000249a:	e44e                	sd	s3,8(sp)
    8000249c:	1800                	addi	s0,sp,48
    8000249e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800024a0:	0022f497          	auipc	s1,0x22f
    800024a4:	cf848493          	addi	s1,s1,-776 # 80231198 <proc>
    800024a8:	00236997          	auipc	s3,0x236
    800024ac:	cf098993          	addi	s3,s3,-784 # 80238198 <mlfq>
  {
    acquire(&p->lock);
    800024b0:	8526                	mv	a0,s1
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	898080e7          	jalr	-1896(ra) # 80000d4a <acquire>
    if (p->pid == pid)
    800024ba:	589c                	lw	a5,48(s1)
    800024bc:	01278d63          	beq	a5,s2,800024d6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024c0:	8526                	mv	a0,s1
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	93c080e7          	jalr	-1732(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800024ca:	1c048493          	addi	s1,s1,448
    800024ce:	ff3491e3          	bne	s1,s3,800024b0 <kill+0x20>
  }
  return -1;
    800024d2:	557d                	li	a0,-1
    800024d4:	a829                	j	800024ee <kill+0x5e>
      p->killed = 1;
    800024d6:	4785                	li	a5,1
    800024d8:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800024da:	4c98                	lw	a4,24(s1)
    800024dc:	4789                	li	a5,2
    800024de:	00f70f63          	beq	a4,a5,800024fc <kill+0x6c>
      release(&p->lock);
    800024e2:	8526                	mv	a0,s1
    800024e4:	fffff097          	auipc	ra,0xfffff
    800024e8:	91a080e7          	jalr	-1766(ra) # 80000dfe <release>
      return 0;
    800024ec:	4501                	li	a0,0
}
    800024ee:	70a2                	ld	ra,40(sp)
    800024f0:	7402                	ld	s0,32(sp)
    800024f2:	64e2                	ld	s1,24(sp)
    800024f4:	6942                	ld	s2,16(sp)
    800024f6:	69a2                	ld	s3,8(sp)
    800024f8:	6145                	addi	sp,sp,48
    800024fa:	8082                	ret
        p->state = RUNNABLE;
    800024fc:	478d                	li	a5,3
    800024fe:	cc9c                	sw	a5,24(s1)
    80002500:	b7cd                	j	800024e2 <kill+0x52>

0000000080002502 <setkilled>:

void setkilled(struct proc *p)
{
    80002502:	1101                	addi	sp,sp,-32
    80002504:	ec06                	sd	ra,24(sp)
    80002506:	e822                	sd	s0,16(sp)
    80002508:	e426                	sd	s1,8(sp)
    8000250a:	1000                	addi	s0,sp,32
    8000250c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	83c080e7          	jalr	-1988(ra) # 80000d4a <acquire>
  p->killed = 1;
    80002516:	4785                	li	a5,1
    80002518:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000251a:	8526                	mv	a0,s1
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	8e2080e7          	jalr	-1822(ra) # 80000dfe <release>
}
    80002524:	60e2                	ld	ra,24(sp)
    80002526:	6442                	ld	s0,16(sp)
    80002528:	64a2                	ld	s1,8(sp)
    8000252a:	6105                	addi	sp,sp,32
    8000252c:	8082                	ret

000000008000252e <killed>:

int killed(struct proc *p)
{
    8000252e:	1101                	addi	sp,sp,-32
    80002530:	ec06                	sd	ra,24(sp)
    80002532:	e822                	sd	s0,16(sp)
    80002534:	e426                	sd	s1,8(sp)
    80002536:	e04a                	sd	s2,0(sp)
    80002538:	1000                	addi	s0,sp,32
    8000253a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000253c:	fffff097          	auipc	ra,0xfffff
    80002540:	80e080e7          	jalr	-2034(ra) # 80000d4a <acquire>
  k = p->killed;
    80002544:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002548:	8526                	mv	a0,s1
    8000254a:	fffff097          	auipc	ra,0xfffff
    8000254e:	8b4080e7          	jalr	-1868(ra) # 80000dfe <release>
  return k;
}
    80002552:	854a                	mv	a0,s2
    80002554:	60e2                	ld	ra,24(sp)
    80002556:	6442                	ld	s0,16(sp)
    80002558:	64a2                	ld	s1,8(sp)
    8000255a:	6902                	ld	s2,0(sp)
    8000255c:	6105                	addi	sp,sp,32
    8000255e:	8082                	ret

0000000080002560 <wait>:
{
    80002560:	715d                	addi	sp,sp,-80
    80002562:	e486                	sd	ra,72(sp)
    80002564:	e0a2                	sd	s0,64(sp)
    80002566:	fc26                	sd	s1,56(sp)
    80002568:	f84a                	sd	s2,48(sp)
    8000256a:	f44e                	sd	s3,40(sp)
    8000256c:	f052                	sd	s4,32(sp)
    8000256e:	ec56                	sd	s5,24(sp)
    80002570:	e85a                	sd	s6,16(sp)
    80002572:	e45e                	sd	s7,8(sp)
    80002574:	e062                	sd	s8,0(sp)
    80002576:	0880                	addi	s0,sp,80
    80002578:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000257a:	fffff097          	auipc	ra,0xfffff
    8000257e:	5a6080e7          	jalr	1446(ra) # 80001b20 <myproc>
    80002582:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002584:	0022e517          	auipc	a0,0x22e
    80002588:	7fc50513          	addi	a0,a0,2044 # 80230d80 <wait_lock>
    8000258c:	ffffe097          	auipc	ra,0xffffe
    80002590:	7be080e7          	jalr	1982(ra) # 80000d4a <acquire>
    havekids = 0;
    80002594:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002596:	4a15                	li	s4,5
        havekids = 1;
    80002598:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000259a:	00236997          	auipc	s3,0x236
    8000259e:	bfe98993          	addi	s3,s3,-1026 # 80238198 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800025a2:	0022ec17          	auipc	s8,0x22e
    800025a6:	7dec0c13          	addi	s8,s8,2014 # 80230d80 <wait_lock>
    havekids = 0;
    800025aa:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800025ac:	0022f497          	auipc	s1,0x22f
    800025b0:	bec48493          	addi	s1,s1,-1044 # 80231198 <proc>
    800025b4:	a0bd                	j	80002622 <wait+0xc2>
          pid = pp->pid;
    800025b6:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025ba:	000b0e63          	beqz	s6,800025d6 <wait+0x76>
    800025be:	4691                	li	a3,4
    800025c0:	02c48613          	addi	a2,s1,44
    800025c4:	85da                	mv	a1,s6
    800025c6:	05093503          	ld	a0,80(s2)
    800025ca:	fffff097          	auipc	ra,0xfffff
    800025ce:	216080e7          	jalr	534(ra) # 800017e0 <copyout>
    800025d2:	02054563          	bltz	a0,800025fc <wait+0x9c>
          freeproc(pp);
    800025d6:	8526                	mv	a0,s1
    800025d8:	fffff097          	auipc	ra,0xfffff
    800025dc:	6fa080e7          	jalr	1786(ra) # 80001cd2 <freeproc>
          release(&pp->lock);
    800025e0:	8526                	mv	a0,s1
    800025e2:	fffff097          	auipc	ra,0xfffff
    800025e6:	81c080e7          	jalr	-2020(ra) # 80000dfe <release>
          release(&wait_lock);
    800025ea:	0022e517          	auipc	a0,0x22e
    800025ee:	79650513          	addi	a0,a0,1942 # 80230d80 <wait_lock>
    800025f2:	fffff097          	auipc	ra,0xfffff
    800025f6:	80c080e7          	jalr	-2036(ra) # 80000dfe <release>
          return pid;
    800025fa:	a0b5                	j	80002666 <wait+0x106>
            release(&pp->lock);
    800025fc:	8526                	mv	a0,s1
    800025fe:	fffff097          	auipc	ra,0xfffff
    80002602:	800080e7          	jalr	-2048(ra) # 80000dfe <release>
            release(&wait_lock);
    80002606:	0022e517          	auipc	a0,0x22e
    8000260a:	77a50513          	addi	a0,a0,1914 # 80230d80 <wait_lock>
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	7f0080e7          	jalr	2032(ra) # 80000dfe <release>
            return -1;
    80002616:	59fd                	li	s3,-1
    80002618:	a0b9                	j	80002666 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000261a:	1c048493          	addi	s1,s1,448
    8000261e:	03348463          	beq	s1,s3,80002646 <wait+0xe6>
      if (pp->parent == p)
    80002622:	7c9c                	ld	a5,56(s1)
    80002624:	ff279be3          	bne	a5,s2,8000261a <wait+0xba>
        acquire(&pp->lock);
    80002628:	8526                	mv	a0,s1
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	720080e7          	jalr	1824(ra) # 80000d4a <acquire>
        if (pp->state == ZOMBIE)
    80002632:	4c9c                	lw	a5,24(s1)
    80002634:	f94781e3          	beq	a5,s4,800025b6 <wait+0x56>
        release(&pp->lock);
    80002638:	8526                	mv	a0,s1
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	7c4080e7          	jalr	1988(ra) # 80000dfe <release>
        havekids = 1;
    80002642:	8756                	mv	a4,s5
    80002644:	bfd9                	j	8000261a <wait+0xba>
    if (!havekids || killed(p))
    80002646:	c719                	beqz	a4,80002654 <wait+0xf4>
    80002648:	854a                	mv	a0,s2
    8000264a:	00000097          	auipc	ra,0x0
    8000264e:	ee4080e7          	jalr	-284(ra) # 8000252e <killed>
    80002652:	c51d                	beqz	a0,80002680 <wait+0x120>
      release(&wait_lock);
    80002654:	0022e517          	auipc	a0,0x22e
    80002658:	72c50513          	addi	a0,a0,1836 # 80230d80 <wait_lock>
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	7a2080e7          	jalr	1954(ra) # 80000dfe <release>
      return -1;
    80002664:	59fd                	li	s3,-1
}
    80002666:	854e                	mv	a0,s3
    80002668:	60a6                	ld	ra,72(sp)
    8000266a:	6406                	ld	s0,64(sp)
    8000266c:	74e2                	ld	s1,56(sp)
    8000266e:	7942                	ld	s2,48(sp)
    80002670:	79a2                	ld	s3,40(sp)
    80002672:	7a02                	ld	s4,32(sp)
    80002674:	6ae2                	ld	s5,24(sp)
    80002676:	6b42                	ld	s6,16(sp)
    80002678:	6ba2                	ld	s7,8(sp)
    8000267a:	6c02                	ld	s8,0(sp)
    8000267c:	6161                	addi	sp,sp,80
    8000267e:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002680:	85e2                	mv	a1,s8
    80002682:	854a                	mv	a0,s2
    80002684:	00000097          	auipc	ra,0x0
    80002688:	bca080e7          	jalr	-1078(ra) # 8000224e <sleep>
    havekids = 0;
    8000268c:	bf39                	j	800025aa <wait+0x4a>

000000008000268e <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000268e:	7179                	addi	sp,sp,-48
    80002690:	f406                	sd	ra,40(sp)
    80002692:	f022                	sd	s0,32(sp)
    80002694:	ec26                	sd	s1,24(sp)
    80002696:	e84a                	sd	s2,16(sp)
    80002698:	e44e                	sd	s3,8(sp)
    8000269a:	e052                	sd	s4,0(sp)
    8000269c:	1800                	addi	s0,sp,48
    8000269e:	84aa                	mv	s1,a0
    800026a0:	892e                	mv	s2,a1
    800026a2:	89b2                	mv	s3,a2
    800026a4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026a6:	fffff097          	auipc	ra,0xfffff
    800026aa:	47a080e7          	jalr	1146(ra) # 80001b20 <myproc>
  if (user_dst)
    800026ae:	c08d                	beqz	s1,800026d0 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800026b0:	86d2                	mv	a3,s4
    800026b2:	864e                	mv	a2,s3
    800026b4:	85ca                	mv	a1,s2
    800026b6:	6928                	ld	a0,80(a0)
    800026b8:	fffff097          	auipc	ra,0xfffff
    800026bc:	128080e7          	jalr	296(ra) # 800017e0 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026c0:	70a2                	ld	ra,40(sp)
    800026c2:	7402                	ld	s0,32(sp)
    800026c4:	64e2                	ld	s1,24(sp)
    800026c6:	6942                	ld	s2,16(sp)
    800026c8:	69a2                	ld	s3,8(sp)
    800026ca:	6a02                	ld	s4,0(sp)
    800026cc:	6145                	addi	sp,sp,48
    800026ce:	8082                	ret
    memmove((char *)dst, src, len);
    800026d0:	000a061b          	sext.w	a2,s4
    800026d4:	85ce                	mv	a1,s3
    800026d6:	854a                	mv	a0,s2
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	7ca080e7          	jalr	1994(ra) # 80000ea2 <memmove>
    return 0;
    800026e0:	8526                	mv	a0,s1
    800026e2:	bff9                	j	800026c0 <either_copyout+0x32>

00000000800026e4 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026e4:	7179                	addi	sp,sp,-48
    800026e6:	f406                	sd	ra,40(sp)
    800026e8:	f022                	sd	s0,32(sp)
    800026ea:	ec26                	sd	s1,24(sp)
    800026ec:	e84a                	sd	s2,16(sp)
    800026ee:	e44e                	sd	s3,8(sp)
    800026f0:	e052                	sd	s4,0(sp)
    800026f2:	1800                	addi	s0,sp,48
    800026f4:	892a                	mv	s2,a0
    800026f6:	84ae                	mv	s1,a1
    800026f8:	89b2                	mv	s3,a2
    800026fa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026fc:	fffff097          	auipc	ra,0xfffff
    80002700:	424080e7          	jalr	1060(ra) # 80001b20 <myproc>
  if (user_src)
    80002704:	c08d                	beqz	s1,80002726 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002706:	86d2                	mv	a3,s4
    80002708:	864e                	mv	a2,s3
    8000270a:	85ca                	mv	a1,s2
    8000270c:	6928                	ld	a0,80(a0)
    8000270e:	fffff097          	auipc	ra,0xfffff
    80002712:	15e080e7          	jalr	350(ra) # 8000186c <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002716:	70a2                	ld	ra,40(sp)
    80002718:	7402                	ld	s0,32(sp)
    8000271a:	64e2                	ld	s1,24(sp)
    8000271c:	6942                	ld	s2,16(sp)
    8000271e:	69a2                	ld	s3,8(sp)
    80002720:	6a02                	ld	s4,0(sp)
    80002722:	6145                	addi	sp,sp,48
    80002724:	8082                	ret
    memmove(dst, (char *)src, len);
    80002726:	000a061b          	sext.w	a2,s4
    8000272a:	85ce                	mv	a1,s3
    8000272c:	854a                	mv	a0,s2
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	774080e7          	jalr	1908(ra) # 80000ea2 <memmove>
    return 0;
    80002736:	8526                	mv	a0,s1
    80002738:	bff9                	j	80002716 <either_copyin+0x32>

000000008000273a <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000273a:	715d                	addi	sp,sp,-80
    8000273c:	e486                	sd	ra,72(sp)
    8000273e:	e0a2                	sd	s0,64(sp)
    80002740:	fc26                	sd	s1,56(sp)
    80002742:	f84a                	sd	s2,48(sp)
    80002744:	f44e                	sd	s3,40(sp)
    80002746:	f052                	sd	s4,32(sp)
    80002748:	ec56                	sd	s5,24(sp)
    8000274a:	e85a                	sd	s6,16(sp)
    8000274c:	e45e                	sd	s7,8(sp)
    8000274e:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002750:	00006517          	auipc	a0,0x6
    80002754:	9b850513          	addi	a0,a0,-1608 # 80008108 <digits+0xc8>
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	e32080e7          	jalr	-462(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002760:	0022f497          	auipc	s1,0x22f
    80002764:	b9048493          	addi	s1,s1,-1136 # 802312f0 <proc+0x158>
    80002768:	00236917          	auipc	s2,0x236
    8000276c:	b8890913          	addi	s2,s2,-1144 # 802382f0 <mlfq+0x158>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002770:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002772:	00006997          	auipc	s3,0x6
    80002776:	b4e98993          	addi	s3,s3,-1202 # 800082c0 <digits+0x280>
    printf("%d %s %s ctime=%d", p->pid, state, p->name, p->ctime);
    8000277a:	00006a97          	auipc	s5,0x6
    8000277e:	b4ea8a93          	addi	s5,s5,-1202 # 800082c8 <digits+0x288>
    printf("\n");
    80002782:	00006a17          	auipc	s4,0x6
    80002786:	986a0a13          	addi	s4,s4,-1658 # 80008108 <digits+0xc8>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000278a:	00006b97          	auipc	s7,0x6
    8000278e:	b86b8b93          	addi	s7,s7,-1146 # 80008310 <states.0>
    80002792:	a015                	j	800027b6 <procdump+0x7c>
    printf("%d %s %s ctime=%d", p->pid, state, p->name, p->ctime);
    80002794:	4ad8                	lw	a4,20(a3)
    80002796:	ed86a583          	lw	a1,-296(a3)
    8000279a:	8556                	mv	a0,s5
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	dee080e7          	jalr	-530(ra) # 8000058a <printf>
    printf("\n");
    800027a4:	8552                	mv	a0,s4
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	de4080e7          	jalr	-540(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800027ae:	1c048493          	addi	s1,s1,448
    800027b2:	03248263          	beq	s1,s2,800027d6 <procdump+0x9c>
    if (p->state == UNUSED)
    800027b6:	86a6                	mv	a3,s1
    800027b8:	ec04a783          	lw	a5,-320(s1)
    800027bc:	dbed                	beqz	a5,800027ae <procdump+0x74>
      state = "???";
    800027be:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027c0:	fcfb6ae3          	bltu	s6,a5,80002794 <procdump+0x5a>
    800027c4:	02079713          	slli	a4,a5,0x20
    800027c8:	01d75793          	srli	a5,a4,0x1d
    800027cc:	97de                	add	a5,a5,s7
    800027ce:	6390                	ld	a2,0(a5)
    800027d0:	f271                	bnez	a2,80002794 <procdump+0x5a>
      state = "???";
    800027d2:	864e                	mv	a2,s3
    800027d4:	b7c1                	j	80002794 <procdump+0x5a>
  }
}
    800027d6:	60a6                	ld	ra,72(sp)
    800027d8:	6406                	ld	s0,64(sp)
    800027da:	74e2                	ld	s1,56(sp)
    800027dc:	7942                	ld	s2,48(sp)
    800027de:	79a2                	ld	s3,40(sp)
    800027e0:	7a02                	ld	s4,32(sp)
    800027e2:	6ae2                	ld	s5,24(sp)
    800027e4:	6b42                	ld	s6,16(sp)
    800027e6:	6ba2                	ld	s7,8(sp)
    800027e8:	6161                	addi	sp,sp,80
    800027ea:	8082                	ret

00000000800027ec <waitx>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    800027ec:	711d                	addi	sp,sp,-96
    800027ee:	ec86                	sd	ra,88(sp)
    800027f0:	e8a2                	sd	s0,80(sp)
    800027f2:	e4a6                	sd	s1,72(sp)
    800027f4:	e0ca                	sd	s2,64(sp)
    800027f6:	fc4e                	sd	s3,56(sp)
    800027f8:	f852                	sd	s4,48(sp)
    800027fa:	f456                	sd	s5,40(sp)
    800027fc:	f05a                	sd	s6,32(sp)
    800027fe:	ec5e                	sd	s7,24(sp)
    80002800:	e862                	sd	s8,16(sp)
    80002802:	e466                	sd	s9,8(sp)
    80002804:	e06a                	sd	s10,0(sp)
    80002806:	1080                	addi	s0,sp,96
    80002808:	8b2a                	mv	s6,a0
    8000280a:	8bae                	mv	s7,a1
    8000280c:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000280e:	fffff097          	auipc	ra,0xfffff
    80002812:	312080e7          	jalr	786(ra) # 80001b20 <myproc>
    80002816:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002818:	0022e517          	auipc	a0,0x22e
    8000281c:	56850513          	addi	a0,a0,1384 # 80230d80 <wait_lock>
    80002820:	ffffe097          	auipc	ra,0xffffe
    80002824:	52a080e7          	jalr	1322(ra) # 80000d4a <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002828:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    8000282a:	4a15                	li	s4,5
        havekids = 1;
    8000282c:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    8000282e:	00236997          	auipc	s3,0x236
    80002832:	96a98993          	addi	s3,s3,-1686 # 80238198 <mlfq>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002836:	0022ed17          	auipc	s10,0x22e
    8000283a:	54ad0d13          	addi	s10,s10,1354 # 80230d80 <wait_lock>
    havekids = 0;
    8000283e:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002840:	0022f497          	auipc	s1,0x22f
    80002844:	95848493          	addi	s1,s1,-1704 # 80231198 <proc>
    80002848:	a059                	j	800028ce <waitx+0xe2>
          pid = np->pid;
    8000284a:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000284e:	1684a783          	lw	a5,360(s1)
    80002852:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002856:	16c4a703          	lw	a4,364(s1)
    8000285a:	9f3d                	addw	a4,a4,a5
    8000285c:	1704a783          	lw	a5,368(s1)
    80002860:	9f99                	subw	a5,a5,a4
    80002862:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002866:	000b0e63          	beqz	s6,80002882 <waitx+0x96>
    8000286a:	4691                	li	a3,4
    8000286c:	02c48613          	addi	a2,s1,44
    80002870:	85da                	mv	a1,s6
    80002872:	05093503          	ld	a0,80(s2)
    80002876:	fffff097          	auipc	ra,0xfffff
    8000287a:	f6a080e7          	jalr	-150(ra) # 800017e0 <copyout>
    8000287e:	02054563          	bltz	a0,800028a8 <waitx+0xbc>
          freeproc(np);
    80002882:	8526                	mv	a0,s1
    80002884:	fffff097          	auipc	ra,0xfffff
    80002888:	44e080e7          	jalr	1102(ra) # 80001cd2 <freeproc>
          release(&np->lock);
    8000288c:	8526                	mv	a0,s1
    8000288e:	ffffe097          	auipc	ra,0xffffe
    80002892:	570080e7          	jalr	1392(ra) # 80000dfe <release>
          release(&wait_lock);
    80002896:	0022e517          	auipc	a0,0x22e
    8000289a:	4ea50513          	addi	a0,a0,1258 # 80230d80 <wait_lock>
    8000289e:	ffffe097          	auipc	ra,0xffffe
    800028a2:	560080e7          	jalr	1376(ra) # 80000dfe <release>
          return pid;
    800028a6:	a09d                	j	8000290c <waitx+0x120>
            release(&np->lock);
    800028a8:	8526                	mv	a0,s1
    800028aa:	ffffe097          	auipc	ra,0xffffe
    800028ae:	554080e7          	jalr	1364(ra) # 80000dfe <release>
            release(&wait_lock);
    800028b2:	0022e517          	auipc	a0,0x22e
    800028b6:	4ce50513          	addi	a0,a0,1230 # 80230d80 <wait_lock>
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	544080e7          	jalr	1348(ra) # 80000dfe <release>
            return -1;
    800028c2:	59fd                	li	s3,-1
    800028c4:	a0a1                	j	8000290c <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    800028c6:	1c048493          	addi	s1,s1,448
    800028ca:	03348463          	beq	s1,s3,800028f2 <waitx+0x106>
      if (np->parent == p)
    800028ce:	7c9c                	ld	a5,56(s1)
    800028d0:	ff279be3          	bne	a5,s2,800028c6 <waitx+0xda>
        acquire(&np->lock);
    800028d4:	8526                	mv	a0,s1
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	474080e7          	jalr	1140(ra) # 80000d4a <acquire>
        if (np->state == ZOMBIE)
    800028de:	4c9c                	lw	a5,24(s1)
    800028e0:	f74785e3          	beq	a5,s4,8000284a <waitx+0x5e>
        release(&np->lock);
    800028e4:	8526                	mv	a0,s1
    800028e6:	ffffe097          	auipc	ra,0xffffe
    800028ea:	518080e7          	jalr	1304(ra) # 80000dfe <release>
        havekids = 1;
    800028ee:	8756                	mv	a4,s5
    800028f0:	bfd9                	j	800028c6 <waitx+0xda>
    if (!havekids || p->killed)
    800028f2:	c701                	beqz	a4,800028fa <waitx+0x10e>
    800028f4:	02892783          	lw	a5,40(s2)
    800028f8:	cb8d                	beqz	a5,8000292a <waitx+0x13e>
      release(&wait_lock);
    800028fa:	0022e517          	auipc	a0,0x22e
    800028fe:	48650513          	addi	a0,a0,1158 # 80230d80 <wait_lock>
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	4fc080e7          	jalr	1276(ra) # 80000dfe <release>
      return -1;
    8000290a:	59fd                	li	s3,-1
  }
}
    8000290c:	854e                	mv	a0,s3
    8000290e:	60e6                	ld	ra,88(sp)
    80002910:	6446                	ld	s0,80(sp)
    80002912:	64a6                	ld	s1,72(sp)
    80002914:	6906                	ld	s2,64(sp)
    80002916:	79e2                	ld	s3,56(sp)
    80002918:	7a42                	ld	s4,48(sp)
    8000291a:	7aa2                	ld	s5,40(sp)
    8000291c:	7b02                	ld	s6,32(sp)
    8000291e:	6be2                	ld	s7,24(sp)
    80002920:	6c42                	ld	s8,16(sp)
    80002922:	6ca2                	ld	s9,8(sp)
    80002924:	6d02                	ld	s10,0(sp)
    80002926:	6125                	addi	sp,sp,96
    80002928:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000292a:	85ea                	mv	a1,s10
    8000292c:	854a                	mv	a0,s2
    8000292e:	00000097          	auipc	ra,0x0
    80002932:	920080e7          	jalr	-1760(ra) # 8000224e <sleep>
    havekids = 0;
    80002936:	b721                	j	8000283e <waitx+0x52>

0000000080002938 <update_time>:

void update_time()
{
    80002938:	7179                	addi	sp,sp,-48
    8000293a:	f406                	sd	ra,40(sp)
    8000293c:	f022                	sd	s0,32(sp)
    8000293e:	ec26                	sd	s1,24(sp)
    80002940:	e84a                	sd	s2,16(sp)
    80002942:	e44e                	sd	s3,8(sp)
    80002944:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002946:	0022f497          	auipc	s1,0x22f
    8000294a:	85248493          	addi	s1,s1,-1966 # 80231198 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    8000294e:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002950:	00236917          	auipc	s2,0x236
    80002954:	84890913          	addi	s2,s2,-1976 # 80238198 <mlfq>
    80002958:	a811                	j	8000296c <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    8000295a:	8526                	mv	a0,s1
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	4a2080e7          	jalr	1186(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002964:	1c048493          	addi	s1,s1,448
    80002968:	03248063          	beq	s1,s2,80002988 <update_time+0x50>
    acquire(&p->lock);
    8000296c:	8526                	mv	a0,s1
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	3dc080e7          	jalr	988(ra) # 80000d4a <acquire>
    if (p->state == RUNNING)
    80002976:	4c9c                	lw	a5,24(s1)
    80002978:	ff3791e3          	bne	a5,s3,8000295a <update_time+0x22>
      p->rtime++;
    8000297c:	1684a783          	lw	a5,360(s1)
    80002980:	2785                	addiw	a5,a5,1
    80002982:	16f4a423          	sw	a5,360(s1)
    80002986:	bfd1                	j	8000295a <update_time+0x22>
  }
    80002988:	70a2                	ld	ra,40(sp)
    8000298a:	7402                	ld	s0,32(sp)
    8000298c:	64e2                	ld	s1,24(sp)
    8000298e:	6942                	ld	s2,16(sp)
    80002990:	69a2                	ld	s3,8(sp)
    80002992:	6145                	addi	sp,sp,48
    80002994:	8082                	ret

0000000080002996 <swtch>:
    80002996:	00153023          	sd	ra,0(a0)
    8000299a:	00253423          	sd	sp,8(a0)
    8000299e:	e900                	sd	s0,16(a0)
    800029a0:	ed04                	sd	s1,24(a0)
    800029a2:	03253023          	sd	s2,32(a0)
    800029a6:	03353423          	sd	s3,40(a0)
    800029aa:	03453823          	sd	s4,48(a0)
    800029ae:	03553c23          	sd	s5,56(a0)
    800029b2:	05653023          	sd	s6,64(a0)
    800029b6:	05753423          	sd	s7,72(a0)
    800029ba:	05853823          	sd	s8,80(a0)
    800029be:	05953c23          	sd	s9,88(a0)
    800029c2:	07a53023          	sd	s10,96(a0)
    800029c6:	07b53423          	sd	s11,104(a0)
    800029ca:	0005b083          	ld	ra,0(a1)
    800029ce:	0085b103          	ld	sp,8(a1)
    800029d2:	6980                	ld	s0,16(a1)
    800029d4:	6d84                	ld	s1,24(a1)
    800029d6:	0205b903          	ld	s2,32(a1)
    800029da:	0285b983          	ld	s3,40(a1)
    800029de:	0305ba03          	ld	s4,48(a1)
    800029e2:	0385ba83          	ld	s5,56(a1)
    800029e6:	0405bb03          	ld	s6,64(a1)
    800029ea:	0485bb83          	ld	s7,72(a1)
    800029ee:	0505bc03          	ld	s8,80(a1)
    800029f2:	0585bc83          	ld	s9,88(a1)
    800029f6:	0605bd03          	ld	s10,96(a1)
    800029fa:	0685bd83          	ld	s11,104(a1)
    800029fe:	8082                	ret

0000000080002a00 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002a00:	1141                	addi	sp,sp,-16
    80002a02:	e406                	sd	ra,8(sp)
    80002a04:	e022                	sd	s0,0(sp)
    80002a06:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a08:	00006597          	auipc	a1,0x6
    80002a0c:	93858593          	addi	a1,a1,-1736 # 80008340 <states.0+0x30>
    80002a10:	00236517          	auipc	a0,0x236
    80002a14:	1b050513          	addi	a0,a0,432 # 80238bc0 <tickslock>
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	2a2080e7          	jalr	674(ra) # 80000cba <initlock>
}
    80002a20:	60a2                	ld	ra,8(sp)
    80002a22:	6402                	ld	s0,0(sp)
    80002a24:	0141                	addi	sp,sp,16
    80002a26:	8082                	ret

0000000080002a28 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002a28:	1141                	addi	sp,sp,-16
    80002a2a:	e422                	sd	s0,8(sp)
    80002a2c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0"
    80002a2e:	00003797          	auipc	a5,0x3
    80002a32:	61278793          	addi	a5,a5,1554 # 80006040 <kernelvec>
    80002a36:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a3a:	6422                	ld	s0,8(sp)
    80002a3c:	0141                	addi	sp,sp,16
    80002a3e:	8082                	ret

0000000080002a40 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002a40:	1141                	addi	sp,sp,-16
    80002a42:	e406                	sd	ra,8(sp)
    80002a44:	e022                	sd	s0,0(sp)
    80002a46:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a48:	fffff097          	auipc	ra,0xfffff
    80002a4c:	0d8080e7          	jalr	216(ra) # 80001b20 <myproc>
  asm volatile("csrr %0, sstatus"
    80002a50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a54:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    80002a56:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a5a:	00004697          	auipc	a3,0x4
    80002a5e:	5a668693          	addi	a3,a3,1446 # 80007000 <_trampoline>
    80002a62:	00004717          	auipc	a4,0x4
    80002a66:	59e70713          	addi	a4,a4,1438 # 80007000 <_trampoline>
    80002a6a:	8f15                	sub	a4,a4,a3
    80002a6c:	040007b7          	lui	a5,0x4000
    80002a70:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002a72:	07b2                	slli	a5,a5,0xc
    80002a74:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0"
    80002a76:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a7a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp"
    80002a7c:	18002673          	csrr	a2,satp
    80002a80:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a82:	6d30                	ld	a2,88(a0)
    80002a84:	6138                	ld	a4,64(a0)
    80002a86:	6585                	lui	a1,0x1
    80002a88:	972e                	add	a4,a4,a1
    80002a8a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a8c:	6d38                	ld	a4,88(a0)
    80002a8e:	00000617          	auipc	a2,0x0
    80002a92:	13e60613          	addi	a2,a2,318 # 80002bcc <usertrap>
    80002a96:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002a98:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp"
    80002a9a:	8612                	mv	a2,tp
    80002a9c:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus"
    80002a9e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002aa2:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002aa6:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0"
    80002aaa:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002aae:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0"
    80002ab0:	6f18                	ld	a4,24(a4)
    80002ab2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ab6:	6928                	ld	a0,80(a0)
    80002ab8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002aba:	00004717          	auipc	a4,0x4
    80002abe:	5e270713          	addi	a4,a4,1506 # 8000709c <userret>
    80002ac2:	8f15                	sub	a4,a4,a3
    80002ac4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002ac6:	577d                	li	a4,-1
    80002ac8:	177e                	slli	a4,a4,0x3f
    80002aca:	8d59                	or	a0,a0,a4
    80002acc:	9782                	jalr	a5
}
    80002ace:	60a2                	ld	ra,8(sp)
    80002ad0:	6402                	ld	s0,0(sp)
    80002ad2:	0141                	addi	sp,sp,16
    80002ad4:	8082                	ret

0000000080002ad6 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002ad6:	1101                	addi	sp,sp,-32
    80002ad8:	ec06                	sd	ra,24(sp)
    80002ada:	e822                	sd	s0,16(sp)
    80002adc:	e426                	sd	s1,8(sp)
    80002ade:	e04a                	sd	s2,0(sp)
    80002ae0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ae2:	00236917          	auipc	s2,0x236
    80002ae6:	0de90913          	addi	s2,s2,222 # 80238bc0 <tickslock>
    80002aea:	854a                	mv	a0,s2
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	25e080e7          	jalr	606(ra) # 80000d4a <acquire>
  ticks++;
    80002af4:	00006497          	auipc	s1,0x6
    80002af8:	ff448493          	addi	s1,s1,-12 # 80008ae8 <ticks>
    80002afc:	409c                	lw	a5,0(s1)
    80002afe:	2785                	addiw	a5,a5,1
    80002b00:	c09c                	sw	a5,0(s1)
  update_time();
    80002b02:	00000097          	auipc	ra,0x0
    80002b06:	e36080e7          	jalr	-458(ra) # 80002938 <update_time>
  // if (myproc() != 0)
  // {
  //   myproc()->running_ticks++;
  //   myproc()->change_queue--;
  // }
  wakeup(&ticks);
    80002b0a:	8526                	mv	a0,s1
    80002b0c:	fffff097          	auipc	ra,0xfffff
    80002b10:	7b2080e7          	jalr	1970(ra) # 800022be <wakeup>
  release(&tickslock);
    80002b14:	854a                	mv	a0,s2
    80002b16:	ffffe097          	auipc	ra,0xffffe
    80002b1a:	2e8080e7          	jalr	744(ra) # 80000dfe <release>
}
    80002b1e:	60e2                	ld	ra,24(sp)
    80002b20:	6442                	ld	s0,16(sp)
    80002b22:	64a2                	ld	s1,8(sp)
    80002b24:	6902                	ld	s2,0(sp)
    80002b26:	6105                	addi	sp,sp,32
    80002b28:	8082                	ret

0000000080002b2a <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002b2a:	1101                	addi	sp,sp,-32
    80002b2c:	ec06                	sd	ra,24(sp)
    80002b2e:	e822                	sd	s0,16(sp)
    80002b30:	e426                	sd	s1,8(sp)
    80002b32:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause"
    80002b34:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002b38:	00074d63          	bltz	a4,80002b52 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002b3c:	57fd                	li	a5,-1
    80002b3e:	17fe                	slli	a5,a5,0x3f
    80002b40:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002b42:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002b44:	06f70363          	beq	a4,a5,80002baa <devintr+0x80>
  }
}
    80002b48:	60e2                	ld	ra,24(sp)
    80002b4a:	6442                	ld	s0,16(sp)
    80002b4c:	64a2                	ld	s1,8(sp)
    80002b4e:	6105                	addi	sp,sp,32
    80002b50:	8082                	ret
      (scause & 0xff) == 9)
    80002b52:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002b56:	46a5                	li	a3,9
    80002b58:	fed792e3          	bne	a5,a3,80002b3c <devintr+0x12>
    int irq = plic_claim();
    80002b5c:	00003097          	auipc	ra,0x3
    80002b60:	5ec080e7          	jalr	1516(ra) # 80006148 <plic_claim>
    80002b64:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002b66:	47a9                	li	a5,10
    80002b68:	02f50763          	beq	a0,a5,80002b96 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002b6c:	4785                	li	a5,1
    80002b6e:	02f50963          	beq	a0,a5,80002ba0 <devintr+0x76>
    return 1;
    80002b72:	4505                	li	a0,1
    else if (irq)
    80002b74:	d8f1                	beqz	s1,80002b48 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b76:	85a6                	mv	a1,s1
    80002b78:	00005517          	auipc	a0,0x5
    80002b7c:	7d050513          	addi	a0,a0,2000 # 80008348 <states.0+0x38>
    80002b80:	ffffe097          	auipc	ra,0xffffe
    80002b84:	a0a080e7          	jalr	-1526(ra) # 8000058a <printf>
      plic_complete(irq);
    80002b88:	8526                	mv	a0,s1
    80002b8a:	00003097          	auipc	ra,0x3
    80002b8e:	5e2080e7          	jalr	1506(ra) # 8000616c <plic_complete>
    return 1;
    80002b92:	4505                	li	a0,1
    80002b94:	bf55                	j	80002b48 <devintr+0x1e>
      uartintr();
    80002b96:	ffffe097          	auipc	ra,0xffffe
    80002b9a:	e02080e7          	jalr	-510(ra) # 80000998 <uartintr>
    80002b9e:	b7ed                	j	80002b88 <devintr+0x5e>
      virtio_disk_intr();
    80002ba0:	00004097          	auipc	ra,0x4
    80002ba4:	d68080e7          	jalr	-664(ra) # 80006908 <virtio_disk_intr>
    80002ba8:	b7c5                	j	80002b88 <devintr+0x5e>
    if (cpuid() == 0)
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	f4a080e7          	jalr	-182(ra) # 80001af4 <cpuid>
    80002bb2:	c901                	beqz	a0,80002bc2 <devintr+0x98>
  asm volatile("csrr %0, sip"
    80002bb4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002bb8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0"
    80002bba:	14479073          	csrw	sip,a5
    return 2;
    80002bbe:	4509                	li	a0,2
    80002bc0:	b761                	j	80002b48 <devintr+0x1e>
      clockintr();
    80002bc2:	00000097          	auipc	ra,0x0
    80002bc6:	f14080e7          	jalr	-236(ra) # 80002ad6 <clockintr>
    80002bca:	b7ed                	j	80002bb4 <devintr+0x8a>

0000000080002bcc <usertrap>:
{
    80002bcc:	1101                	addi	sp,sp,-32
    80002bce:	ec06                	sd	ra,24(sp)
    80002bd0:	e822                	sd	s0,16(sp)
    80002bd2:	e426                	sd	s1,8(sp)
    80002bd4:	e04a                	sd	s2,0(sp)
    80002bd6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80002bd8:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002bdc:	1007f793          	andi	a5,a5,256
    80002be0:	e3b1                	bnez	a5,80002c24 <usertrap+0x58>
  asm volatile("csrw stvec, %0"
    80002be2:	00003797          	auipc	a5,0x3
    80002be6:	45e78793          	addi	a5,a5,1118 # 80006040 <kernelvec>
    80002bea:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bee:	fffff097          	auipc	ra,0xfffff
    80002bf2:	f32080e7          	jalr	-206(ra) # 80001b20 <myproc>
    80002bf6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bf8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc"
    80002bfa:	14102773          	csrr	a4,sepc
    80002bfe:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause"
    80002c00:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002c04:	47a1                	li	a5,8
    80002c06:	02f70763          	beq	a4,a5,80002c34 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	f20080e7          	jalr	-224(ra) # 80002b2a <devintr>
    80002c12:	892a                	mv	s2,a0
    80002c14:	c151                	beqz	a0,80002c98 <usertrap+0xcc>
  if (killed(p))
    80002c16:	8526                	mv	a0,s1
    80002c18:	00000097          	auipc	ra,0x0
    80002c1c:	916080e7          	jalr	-1770(ra) # 8000252e <killed>
    80002c20:	c929                	beqz	a0,80002c72 <usertrap+0xa6>
    80002c22:	a099                	j	80002c68 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002c24:	00005517          	auipc	a0,0x5
    80002c28:	74450513          	addi	a0,a0,1860 # 80008368 <states.0+0x58>
    80002c2c:	ffffe097          	auipc	ra,0xffffe
    80002c30:	914080e7          	jalr	-1772(ra) # 80000540 <panic>
    if (killed(p))
    80002c34:	00000097          	auipc	ra,0x0
    80002c38:	8fa080e7          	jalr	-1798(ra) # 8000252e <killed>
    80002c3c:	e921                	bnez	a0,80002c8c <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002c3e:	6cb8                	ld	a4,88(s1)
    80002c40:	6f1c                	ld	a5,24(a4)
    80002c42:	0791                	addi	a5,a5,4
    80002c44:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus"
    80002c46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c4a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002c4e:	10079073          	csrw	sstatus,a5
    syscall();
    80002c52:	00000097          	auipc	ra,0x0
    80002c56:	2d4080e7          	jalr	724(ra) # 80002f26 <syscall>
  if (killed(p))
    80002c5a:	8526                	mv	a0,s1
    80002c5c:	00000097          	auipc	ra,0x0
    80002c60:	8d2080e7          	jalr	-1838(ra) # 8000252e <killed>
    80002c64:	c911                	beqz	a0,80002c78 <usertrap+0xac>
    80002c66:	4901                	li	s2,0
    exit(-1);
    80002c68:	557d                	li	a0,-1
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	744080e7          	jalr	1860(ra) # 800023ae <exit>
  if (which_dev == 2)
    80002c72:	4789                	li	a5,2
    80002c74:	04f90f63          	beq	s2,a5,80002cd2 <usertrap+0x106>
  usertrapret();
    80002c78:	00000097          	auipc	ra,0x0
    80002c7c:	dc8080e7          	jalr	-568(ra) # 80002a40 <usertrapret>
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	64a2                	ld	s1,8(sp)
    80002c86:	6902                	ld	s2,0(sp)
    80002c88:	6105                	addi	sp,sp,32
    80002c8a:	8082                	ret
      exit(-1);
    80002c8c:	557d                	li	a0,-1
    80002c8e:	fffff097          	auipc	ra,0xfffff
    80002c92:	720080e7          	jalr	1824(ra) # 800023ae <exit>
    80002c96:	b765                	j	80002c3e <usertrap+0x72>
  asm volatile("csrr %0, scause"
    80002c98:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c9c:	5890                	lw	a2,48(s1)
    80002c9e:	00005517          	auipc	a0,0x5
    80002ca2:	6ea50513          	addi	a0,a0,1770 # 80008388 <states.0+0x78>
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	8e4080e7          	jalr	-1820(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002cae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002cb2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cb6:	00005517          	auipc	a0,0x5
    80002cba:	70250513          	addi	a0,a0,1794 # 800083b8 <states.0+0xa8>
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	8cc080e7          	jalr	-1844(ra) # 8000058a <printf>
    setkilled(p);
    80002cc6:	8526                	mv	a0,s1
    80002cc8:	00000097          	auipc	ra,0x0
    80002ccc:	83a080e7          	jalr	-1990(ra) # 80002502 <setkilled>
    80002cd0:	b769                	j	80002c5a <usertrap+0x8e>
    yield();
    80002cd2:	fffff097          	auipc	ra,0xfffff
    80002cd6:	540080e7          	jalr	1344(ra) # 80002212 <yield>
    80002cda:	bf79                	j	80002c78 <usertrap+0xac>

0000000080002cdc <kerneltrap>:
{
    80002cdc:	7179                	addi	sp,sp,-48
    80002cde:	f406                	sd	ra,40(sp)
    80002ce0:	f022                	sd	s0,32(sp)
    80002ce2:	ec26                	sd	s1,24(sp)
    80002ce4:	e84a                	sd	s2,16(sp)
    80002ce6:	e44e                	sd	s3,8(sp)
    80002ce8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc"
    80002cea:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus"
    80002cee:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause"
    80002cf2:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002cf6:	1004f793          	andi	a5,s1,256
    80002cfa:	cb85                	beqz	a5,80002d2a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus"
    80002cfc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d00:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002d02:	ef85                	bnez	a5,80002d3a <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002d04:	00000097          	auipc	ra,0x0
    80002d08:	e26080e7          	jalr	-474(ra) # 80002b2a <devintr>
    80002d0c:	cd1d                	beqz	a0,80002d4a <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d0e:	4789                	li	a5,2
    80002d10:	06f50a63          	beq	a0,a5,80002d84 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0"
    80002d14:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0"
    80002d18:	10049073          	csrw	sstatus,s1
}
    80002d1c:	70a2                	ld	ra,40(sp)
    80002d1e:	7402                	ld	s0,32(sp)
    80002d20:	64e2                	ld	s1,24(sp)
    80002d22:	6942                	ld	s2,16(sp)
    80002d24:	69a2                	ld	s3,8(sp)
    80002d26:	6145                	addi	sp,sp,48
    80002d28:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d2a:	00005517          	auipc	a0,0x5
    80002d2e:	6ae50513          	addi	a0,a0,1710 # 800083d8 <states.0+0xc8>
    80002d32:	ffffe097          	auipc	ra,0xffffe
    80002d36:	80e080e7          	jalr	-2034(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d3a:	00005517          	auipc	a0,0x5
    80002d3e:	6c650513          	addi	a0,a0,1734 # 80008400 <states.0+0xf0>
    80002d42:	ffffd097          	auipc	ra,0xffffd
    80002d46:	7fe080e7          	jalr	2046(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002d4a:	85ce                	mv	a1,s3
    80002d4c:	00005517          	auipc	a0,0x5
    80002d50:	6d450513          	addi	a0,a0,1748 # 80008420 <states.0+0x110>
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	836080e7          	jalr	-1994(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002d5c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002d60:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d64:	00005517          	auipc	a0,0x5
    80002d68:	6cc50513          	addi	a0,a0,1740 # 80008430 <states.0+0x120>
    80002d6c:	ffffe097          	auipc	ra,0xffffe
    80002d70:	81e080e7          	jalr	-2018(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002d74:	00005517          	auipc	a0,0x5
    80002d78:	6d450513          	addi	a0,a0,1748 # 80008448 <states.0+0x138>
    80002d7c:	ffffd097          	auipc	ra,0xffffd
    80002d80:	7c4080e7          	jalr	1988(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	d9c080e7          	jalr	-612(ra) # 80001b20 <myproc>
    80002d8c:	d541                	beqz	a0,80002d14 <kerneltrap+0x38>
    80002d8e:	fffff097          	auipc	ra,0xfffff
    80002d92:	d92080e7          	jalr	-622(ra) # 80001b20 <myproc>
    80002d96:	4d18                	lw	a4,24(a0)
    80002d98:	4791                	li	a5,4
    80002d9a:	f6f71de3          	bne	a4,a5,80002d14 <kerneltrap+0x38>
    yield();
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	474080e7          	jalr	1140(ra) # 80002212 <yield>
    80002da6:	b7bd                	j	80002d14 <kerneltrap+0x38>

0000000080002da8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002da8:	1101                	addi	sp,sp,-32
    80002daa:	ec06                	sd	ra,24(sp)
    80002dac:	e822                	sd	s0,16(sp)
    80002dae:	e426                	sd	s1,8(sp)
    80002db0:	1000                	addi	s0,sp,32
    80002db2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002db4:	fffff097          	auipc	ra,0xfffff
    80002db8:	d6c080e7          	jalr	-660(ra) # 80001b20 <myproc>
  switch (n)
    80002dbc:	4795                	li	a5,5
    80002dbe:	0497e163          	bltu	a5,s1,80002e00 <argraw+0x58>
    80002dc2:	048a                	slli	s1,s1,0x2
    80002dc4:	00005717          	auipc	a4,0x5
    80002dc8:	78470713          	addi	a4,a4,1924 # 80008548 <states.0+0x238>
    80002dcc:	94ba                	add	s1,s1,a4
    80002dce:	409c                	lw	a5,0(s1)
    80002dd0:	97ba                	add	a5,a5,a4
    80002dd2:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002dd4:	6d3c                	ld	a5,88(a0)
    80002dd6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002dd8:	60e2                	ld	ra,24(sp)
    80002dda:	6442                	ld	s0,16(sp)
    80002ddc:	64a2                	ld	s1,8(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret
    return p->trapframe->a1;
    80002de2:	6d3c                	ld	a5,88(a0)
    80002de4:	7fa8                	ld	a0,120(a5)
    80002de6:	bfcd                	j	80002dd8 <argraw+0x30>
    return p->trapframe->a2;
    80002de8:	6d3c                	ld	a5,88(a0)
    80002dea:	63c8                	ld	a0,128(a5)
    80002dec:	b7f5                	j	80002dd8 <argraw+0x30>
    return p->trapframe->a3;
    80002dee:	6d3c                	ld	a5,88(a0)
    80002df0:	67c8                	ld	a0,136(a5)
    80002df2:	b7dd                	j	80002dd8 <argraw+0x30>
    return p->trapframe->a4;
    80002df4:	6d3c                	ld	a5,88(a0)
    80002df6:	6bc8                	ld	a0,144(a5)
    80002df8:	b7c5                	j	80002dd8 <argraw+0x30>
    return p->trapframe->a5;
    80002dfa:	6d3c                	ld	a5,88(a0)
    80002dfc:	6fc8                	ld	a0,152(a5)
    80002dfe:	bfe9                	j	80002dd8 <argraw+0x30>
  panic("argraw");
    80002e00:	00005517          	auipc	a0,0x5
    80002e04:	65850513          	addi	a0,a0,1624 # 80008458 <states.0+0x148>
    80002e08:	ffffd097          	auipc	ra,0xffffd
    80002e0c:	738080e7          	jalr	1848(ra) # 80000540 <panic>

0000000080002e10 <fetchaddr>:
{
    80002e10:	1101                	addi	sp,sp,-32
    80002e12:	ec06                	sd	ra,24(sp)
    80002e14:	e822                	sd	s0,16(sp)
    80002e16:	e426                	sd	s1,8(sp)
    80002e18:	e04a                	sd	s2,0(sp)
    80002e1a:	1000                	addi	s0,sp,32
    80002e1c:	84aa                	mv	s1,a0
    80002e1e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	d00080e7          	jalr	-768(ra) # 80001b20 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e28:	653c                	ld	a5,72(a0)
    80002e2a:	02f4f863          	bgeu	s1,a5,80002e5a <fetchaddr+0x4a>
    80002e2e:	00848713          	addi	a4,s1,8
    80002e32:	02e7e663          	bltu	a5,a4,80002e5e <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e36:	46a1                	li	a3,8
    80002e38:	8626                	mv	a2,s1
    80002e3a:	85ca                	mv	a1,s2
    80002e3c:	6928                	ld	a0,80(a0)
    80002e3e:	fffff097          	auipc	ra,0xfffff
    80002e42:	a2e080e7          	jalr	-1490(ra) # 8000186c <copyin>
    80002e46:	00a03533          	snez	a0,a0
    80002e4a:	40a00533          	neg	a0,a0
}
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	64a2                	ld	s1,8(sp)
    80002e54:	6902                	ld	s2,0(sp)
    80002e56:	6105                	addi	sp,sp,32
    80002e58:	8082                	ret
    return -1;
    80002e5a:	557d                	li	a0,-1
    80002e5c:	bfcd                	j	80002e4e <fetchaddr+0x3e>
    80002e5e:	557d                	li	a0,-1
    80002e60:	b7fd                	j	80002e4e <fetchaddr+0x3e>

0000000080002e62 <fetchstr>:
{
    80002e62:	7179                	addi	sp,sp,-48
    80002e64:	f406                	sd	ra,40(sp)
    80002e66:	f022                	sd	s0,32(sp)
    80002e68:	ec26                	sd	s1,24(sp)
    80002e6a:	e84a                	sd	s2,16(sp)
    80002e6c:	e44e                	sd	s3,8(sp)
    80002e6e:	1800                	addi	s0,sp,48
    80002e70:	892a                	mv	s2,a0
    80002e72:	84ae                	mv	s1,a1
    80002e74:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e76:	fffff097          	auipc	ra,0xfffff
    80002e7a:	caa080e7          	jalr	-854(ra) # 80001b20 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e7e:	86ce                	mv	a3,s3
    80002e80:	864a                	mv	a2,s2
    80002e82:	85a6                	mv	a1,s1
    80002e84:	6928                	ld	a0,80(a0)
    80002e86:	fffff097          	auipc	ra,0xfffff
    80002e8a:	a74080e7          	jalr	-1420(ra) # 800018fa <copyinstr>
    80002e8e:	00054e63          	bltz	a0,80002eaa <fetchstr+0x48>
  return strlen(buf);
    80002e92:	8526                	mv	a0,s1
    80002e94:	ffffe097          	auipc	ra,0xffffe
    80002e98:	12e080e7          	jalr	302(ra) # 80000fc2 <strlen>
}
    80002e9c:	70a2                	ld	ra,40(sp)
    80002e9e:	7402                	ld	s0,32(sp)
    80002ea0:	64e2                	ld	s1,24(sp)
    80002ea2:	6942                	ld	s2,16(sp)
    80002ea4:	69a2                	ld	s3,8(sp)
    80002ea6:	6145                	addi	sp,sp,48
    80002ea8:	8082                	ret
    return -1;
    80002eaa:	557d                	li	a0,-1
    80002eac:	bfc5                	j	80002e9c <fetchstr+0x3a>

0000000080002eae <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002eae:	1101                	addi	sp,sp,-32
    80002eb0:	ec06                	sd	ra,24(sp)
    80002eb2:	e822                	sd	s0,16(sp)
    80002eb4:	e426                	sd	s1,8(sp)
    80002eb6:	1000                	addi	s0,sp,32
    80002eb8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eba:	00000097          	auipc	ra,0x0
    80002ebe:	eee080e7          	jalr	-274(ra) # 80002da8 <argraw>
    80002ec2:	c088                	sw	a0,0(s1)
}
    80002ec4:	60e2                	ld	ra,24(sp)
    80002ec6:	6442                	ld	s0,16(sp)
    80002ec8:	64a2                	ld	s1,8(sp)
    80002eca:	6105                	addi	sp,sp,32
    80002ecc:	8082                	ret

0000000080002ece <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002ece:	1101                	addi	sp,sp,-32
    80002ed0:	ec06                	sd	ra,24(sp)
    80002ed2:	e822                	sd	s0,16(sp)
    80002ed4:	e426                	sd	s1,8(sp)
    80002ed6:	1000                	addi	s0,sp,32
    80002ed8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eda:	00000097          	auipc	ra,0x0
    80002ede:	ece080e7          	jalr	-306(ra) # 80002da8 <argraw>
    80002ee2:	e088                	sd	a0,0(s1)
}
    80002ee4:	60e2                	ld	ra,24(sp)
    80002ee6:	6442                	ld	s0,16(sp)
    80002ee8:	64a2                	ld	s1,8(sp)
    80002eea:	6105                	addi	sp,sp,32
    80002eec:	8082                	ret

0000000080002eee <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002eee:	7179                	addi	sp,sp,-48
    80002ef0:	f406                	sd	ra,40(sp)
    80002ef2:	f022                	sd	s0,32(sp)
    80002ef4:	ec26                	sd	s1,24(sp)
    80002ef6:	e84a                	sd	s2,16(sp)
    80002ef8:	1800                	addi	s0,sp,48
    80002efa:	84ae                	mv	s1,a1
    80002efc:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002efe:	fd840593          	addi	a1,s0,-40
    80002f02:	00000097          	auipc	ra,0x0
    80002f06:	fcc080e7          	jalr	-52(ra) # 80002ece <argaddr>
  return fetchstr(addr, buf, max);
    80002f0a:	864a                	mv	a2,s2
    80002f0c:	85a6                	mv	a1,s1
    80002f0e:	fd843503          	ld	a0,-40(s0)
    80002f12:	00000097          	auipc	ra,0x0
    80002f16:	f50080e7          	jalr	-176(ra) # 80002e62 <fetchstr>
}
    80002f1a:	70a2                	ld	ra,40(sp)
    80002f1c:	7402                	ld	s0,32(sp)
    80002f1e:	64e2                	ld	s1,24(sp)
    80002f20:	6942                	ld	s2,16(sp)
    80002f22:	6145                	addi	sp,sp,48
    80002f24:	8082                	ret

0000000080002f26 <syscall>:
    "sigreturn",
    "waitx",
};

void syscall(void)
{
    80002f26:	1101                	addi	sp,sp,-32
    80002f28:	ec06                	sd	ra,24(sp)
    80002f2a:	e822                	sd	s0,16(sp)
    80002f2c:	e426                	sd	s1,8(sp)
    80002f2e:	e04a                	sd	s2,0(sp)
    80002f30:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002f32:	fffff097          	auipc	ra,0xfffff
    80002f36:	bee080e7          	jalr	-1042(ra) # 80001b20 <myproc>
    80002f3a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f3c:	05853903          	ld	s2,88(a0)
    80002f40:	0a893783          	ld	a5,168(s2)
    80002f44:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002f48:	37fd                	addiw	a5,a5,-1
    80002f4a:	475d                	li	a4,23
    80002f4c:	00f76f63          	bltu	a4,a5,80002f6a <syscall+0x44>
    80002f50:	00369713          	slli	a4,a3,0x3
    80002f54:	00005797          	auipc	a5,0x5
    80002f58:	60c78793          	addi	a5,a5,1548 # 80008560 <syscalls>
    80002f5c:	97ba                	add	a5,a5,a4
    80002f5e:	639c                	ld	a5,0(a5)
    80002f60:	c789                	beqz	a5,80002f6a <syscall+0x44>
    // short argcount = (num == SYS_read || num == SYS_write || num == SYS_mknod || SYS_waitx) ? 3
    // : ((num == SYS_exec || num == SYS_fstat || num == SYS_open || num == SYS_link || num == SYS_sigalarm) ? 2
    // : ((num == SYS_wait || num == SYS_pipe || num == SYS_kill || num == SYS_chdir || num == SYS_dup || num == SYS_sbrk || num == SYS_sleep || num == SYS_unlink || num == SYS_mkdir || num == SYS_close) ? 1
    // : 0));

    p->trapframe->a0 = syscalls[num]();
    80002f62:	9782                	jalr	a5
    80002f64:	06a93823          	sd	a0,112(s2)
    80002f68:	a839                	j	80002f86 <syscall+0x60>
    //   printf(") -> %d\n", p->trapframe->a0);
    // }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002f6a:	15848613          	addi	a2,s1,344
    80002f6e:	588c                	lw	a1,48(s1)
    80002f70:	00005517          	auipc	a0,0x5
    80002f74:	4f050513          	addi	a0,a0,1264 # 80008460 <states.0+0x150>
    80002f78:	ffffd097          	auipc	ra,0xffffd
    80002f7c:	612080e7          	jalr	1554(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f80:	6cbc                	ld	a5,88(s1)
    80002f82:	577d                	li	a4,-1
    80002f84:	fbb8                	sd	a4,112(a5)
  }
}
    80002f86:	60e2                	ld	ra,24(sp)
    80002f88:	6442                	ld	s0,16(sp)
    80002f8a:	64a2                	ld	s1,8(sp)
    80002f8c:	6902                	ld	s2,0(sp)
    80002f8e:	6105                	addi	sp,sp,32
    80002f90:	8082                	ret

0000000080002f92 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f92:	1101                	addi	sp,sp,-32
    80002f94:	ec06                	sd	ra,24(sp)
    80002f96:	e822                	sd	s0,16(sp)
    80002f98:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f9a:	fec40593          	addi	a1,s0,-20
    80002f9e:	4501                	li	a0,0
    80002fa0:	00000097          	auipc	ra,0x0
    80002fa4:	f0e080e7          	jalr	-242(ra) # 80002eae <argint>
  exit(n);
    80002fa8:	fec42503          	lw	a0,-20(s0)
    80002fac:	fffff097          	auipc	ra,0xfffff
    80002fb0:	402080e7          	jalr	1026(ra) # 800023ae <exit>
  return 0; // not reached
}
    80002fb4:	4501                	li	a0,0
    80002fb6:	60e2                	ld	ra,24(sp)
    80002fb8:	6442                	ld	s0,16(sp)
    80002fba:	6105                	addi	sp,sp,32
    80002fbc:	8082                	ret

0000000080002fbe <sys_getpid>:

uint64
sys_getpid(void)
{
    80002fbe:	1141                	addi	sp,sp,-16
    80002fc0:	e406                	sd	ra,8(sp)
    80002fc2:	e022                	sd	s0,0(sp)
    80002fc4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	b5a080e7          	jalr	-1190(ra) # 80001b20 <myproc>
}
    80002fce:	5908                	lw	a0,48(a0)
    80002fd0:	60a2                	ld	ra,8(sp)
    80002fd2:	6402                	ld	s0,0(sp)
    80002fd4:	0141                	addi	sp,sp,16
    80002fd6:	8082                	ret

0000000080002fd8 <sys_fork>:

uint64
sys_fork(void)
{
    80002fd8:	1141                	addi	sp,sp,-16
    80002fda:	e406                	sd	ra,8(sp)
    80002fdc:	e022                	sd	s0,0(sp)
    80002fde:	0800                	addi	s0,sp,16
  return fork();
    80002fe0:	fffff097          	auipc	ra,0xfffff
    80002fe4:	f64080e7          	jalr	-156(ra) # 80001f44 <fork>
}
    80002fe8:	60a2                	ld	ra,8(sp)
    80002fea:	6402                	ld	s0,0(sp)
    80002fec:	0141                	addi	sp,sp,16
    80002fee:	8082                	ret

0000000080002ff0 <sys_wait>:

uint64
sys_wait(void)
{
    80002ff0:	1101                	addi	sp,sp,-32
    80002ff2:	ec06                	sd	ra,24(sp)
    80002ff4:	e822                	sd	s0,16(sp)
    80002ff6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ff8:	fe840593          	addi	a1,s0,-24
    80002ffc:	4501                	li	a0,0
    80002ffe:	00000097          	auipc	ra,0x0
    80003002:	ed0080e7          	jalr	-304(ra) # 80002ece <argaddr>
  return wait(p);
    80003006:	fe843503          	ld	a0,-24(s0)
    8000300a:	fffff097          	auipc	ra,0xfffff
    8000300e:	556080e7          	jalr	1366(ra) # 80002560 <wait>
}
    80003012:	60e2                	ld	ra,24(sp)
    80003014:	6442                	ld	s0,16(sp)
    80003016:	6105                	addi	sp,sp,32
    80003018:	8082                	ret

000000008000301a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000301a:	7179                	addi	sp,sp,-48
    8000301c:	f406                	sd	ra,40(sp)
    8000301e:	f022                	sd	s0,32(sp)
    80003020:	ec26                	sd	s1,24(sp)
    80003022:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003024:	fdc40593          	addi	a1,s0,-36
    80003028:	4501                	li	a0,0
    8000302a:	00000097          	auipc	ra,0x0
    8000302e:	e84080e7          	jalr	-380(ra) # 80002eae <argint>
  addr = myproc()->sz;
    80003032:	fffff097          	auipc	ra,0xfffff
    80003036:	aee080e7          	jalr	-1298(ra) # 80001b20 <myproc>
    8000303a:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    8000303c:	fdc42503          	lw	a0,-36(s0)
    80003040:	fffff097          	auipc	ra,0xfffff
    80003044:	ea8080e7          	jalr	-344(ra) # 80001ee8 <growproc>
    80003048:	00054863          	bltz	a0,80003058 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000304c:	8526                	mv	a0,s1
    8000304e:	70a2                	ld	ra,40(sp)
    80003050:	7402                	ld	s0,32(sp)
    80003052:	64e2                	ld	s1,24(sp)
    80003054:	6145                	addi	sp,sp,48
    80003056:	8082                	ret
    return -1;
    80003058:	54fd                	li	s1,-1
    8000305a:	bfcd                	j	8000304c <sys_sbrk+0x32>

000000008000305c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000305c:	7139                	addi	sp,sp,-64
    8000305e:	fc06                	sd	ra,56(sp)
    80003060:	f822                	sd	s0,48(sp)
    80003062:	f426                	sd	s1,40(sp)
    80003064:	f04a                	sd	s2,32(sp)
    80003066:	ec4e                	sd	s3,24(sp)
    80003068:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000306a:	fcc40593          	addi	a1,s0,-52
    8000306e:	4501                	li	a0,0
    80003070:	00000097          	auipc	ra,0x0
    80003074:	e3e080e7          	jalr	-450(ra) # 80002eae <argint>
  acquire(&tickslock);
    80003078:	00236517          	auipc	a0,0x236
    8000307c:	b4850513          	addi	a0,a0,-1208 # 80238bc0 <tickslock>
    80003080:	ffffe097          	auipc	ra,0xffffe
    80003084:	cca080e7          	jalr	-822(ra) # 80000d4a <acquire>
  ticks0 = ticks;
    80003088:	00006917          	auipc	s2,0x6
    8000308c:	a6092903          	lw	s2,-1440(s2) # 80008ae8 <ticks>
  while (ticks - ticks0 < n)
    80003090:	fcc42783          	lw	a5,-52(s0)
    80003094:	cf9d                	beqz	a5,800030d2 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003096:	00236997          	auipc	s3,0x236
    8000309a:	b2a98993          	addi	s3,s3,-1238 # 80238bc0 <tickslock>
    8000309e:	00006497          	auipc	s1,0x6
    800030a2:	a4a48493          	addi	s1,s1,-1462 # 80008ae8 <ticks>
    if (killed(myproc()))
    800030a6:	fffff097          	auipc	ra,0xfffff
    800030aa:	a7a080e7          	jalr	-1414(ra) # 80001b20 <myproc>
    800030ae:	fffff097          	auipc	ra,0xfffff
    800030b2:	480080e7          	jalr	1152(ra) # 8000252e <killed>
    800030b6:	ed15                	bnez	a0,800030f2 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800030b8:	85ce                	mv	a1,s3
    800030ba:	8526                	mv	a0,s1
    800030bc:	fffff097          	auipc	ra,0xfffff
    800030c0:	192080e7          	jalr	402(ra) # 8000224e <sleep>
  while (ticks - ticks0 < n)
    800030c4:	409c                	lw	a5,0(s1)
    800030c6:	412787bb          	subw	a5,a5,s2
    800030ca:	fcc42703          	lw	a4,-52(s0)
    800030ce:	fce7ece3          	bltu	a5,a4,800030a6 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800030d2:	00236517          	auipc	a0,0x236
    800030d6:	aee50513          	addi	a0,a0,-1298 # 80238bc0 <tickslock>
    800030da:	ffffe097          	auipc	ra,0xffffe
    800030de:	d24080e7          	jalr	-732(ra) # 80000dfe <release>
  return 0;
    800030e2:	4501                	li	a0,0
}
    800030e4:	70e2                	ld	ra,56(sp)
    800030e6:	7442                	ld	s0,48(sp)
    800030e8:	74a2                	ld	s1,40(sp)
    800030ea:	7902                	ld	s2,32(sp)
    800030ec:	69e2                	ld	s3,24(sp)
    800030ee:	6121                	addi	sp,sp,64
    800030f0:	8082                	ret
      release(&tickslock);
    800030f2:	00236517          	auipc	a0,0x236
    800030f6:	ace50513          	addi	a0,a0,-1330 # 80238bc0 <tickslock>
    800030fa:	ffffe097          	auipc	ra,0xffffe
    800030fe:	d04080e7          	jalr	-764(ra) # 80000dfe <release>
      return -1;
    80003102:	557d                	li	a0,-1
    80003104:	b7c5                	j	800030e4 <sys_sleep+0x88>

0000000080003106 <sys_kill>:

uint64
sys_kill(void)
{
    80003106:	1101                	addi	sp,sp,-32
    80003108:	ec06                	sd	ra,24(sp)
    8000310a:	e822                	sd	s0,16(sp)
    8000310c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000310e:	fec40593          	addi	a1,s0,-20
    80003112:	4501                	li	a0,0
    80003114:	00000097          	auipc	ra,0x0
    80003118:	d9a080e7          	jalr	-614(ra) # 80002eae <argint>
  return kill(pid);
    8000311c:	fec42503          	lw	a0,-20(s0)
    80003120:	fffff097          	auipc	ra,0xfffff
    80003124:	370080e7          	jalr	880(ra) # 80002490 <kill>
}
    80003128:	60e2                	ld	ra,24(sp)
    8000312a:	6442                	ld	s0,16(sp)
    8000312c:	6105                	addi	sp,sp,32
    8000312e:	8082                	ret

0000000080003130 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003130:	1101                	addi	sp,sp,-32
    80003132:	ec06                	sd	ra,24(sp)
    80003134:	e822                	sd	s0,16(sp)
    80003136:	e426                	sd	s1,8(sp)
    80003138:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000313a:	00236517          	auipc	a0,0x236
    8000313e:	a8650513          	addi	a0,a0,-1402 # 80238bc0 <tickslock>
    80003142:	ffffe097          	auipc	ra,0xffffe
    80003146:	c08080e7          	jalr	-1016(ra) # 80000d4a <acquire>
  xticks = ticks;
    8000314a:	00006497          	auipc	s1,0x6
    8000314e:	99e4a483          	lw	s1,-1634(s1) # 80008ae8 <ticks>
  release(&tickslock);
    80003152:	00236517          	auipc	a0,0x236
    80003156:	a6e50513          	addi	a0,a0,-1426 # 80238bc0 <tickslock>
    8000315a:	ffffe097          	auipc	ra,0xffffe
    8000315e:	ca4080e7          	jalr	-860(ra) # 80000dfe <release>
  return xticks;
}
    80003162:	02049513          	slli	a0,s1,0x20
    80003166:	9101                	srli	a0,a0,0x20
    80003168:	60e2                	ld	ra,24(sp)
    8000316a:	6442                	ld	s0,16(sp)
    8000316c:	64a2                	ld	s1,8(sp)
    8000316e:	6105                	addi	sp,sp,32
    80003170:	8082                	ret

0000000080003172 <sys_sigalarm>:

// sigalarm
uint64 sys_sigalarm(void)
{
    80003172:	1101                	addi	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	1000                	addi	s0,sp,32
  int interval;
  uint64 fn;
  argint(0, &interval);
    8000317a:	fec40593          	addi	a1,s0,-20
    8000317e:	4501                	li	a0,0
    80003180:	00000097          	auipc	ra,0x0
    80003184:	d2e080e7          	jalr	-722(ra) # 80002eae <argint>
  argaddr(1, &fn);
    80003188:	fe040593          	addi	a1,s0,-32
    8000318c:	4505                	li	a0,1
    8000318e:	00000097          	auipc	ra,0x0
    80003192:	d40080e7          	jalr	-704(ra) # 80002ece <argaddr>

  struct proc *p = myproc();
    80003196:	fffff097          	auipc	ra,0xfffff
    8000319a:	98a080e7          	jalr	-1654(ra) # 80001b20 <myproc>

  p->sigalarm_status = 0;
    8000319e:	1a052c23          	sw	zero,440(a0)
  p->interval = interval;
    800031a2:	fec42783          	lw	a5,-20(s0)
    800031a6:	1af52423          	sw	a5,424(a0)
  p->now_ticks = 0;
    800031aa:	1a052623          	sw	zero,428(a0)
  p->handler = fn;
    800031ae:	fe043783          	ld	a5,-32(s0)
    800031b2:	1af53023          	sd	a5,416(a0)

  return 0;
}
    800031b6:	4501                	li	a0,0
    800031b8:	60e2                	ld	ra,24(sp)
    800031ba:	6442                	ld	s0,16(sp)
    800031bc:	6105                	addi	sp,sp,32
    800031be:	8082                	ret

00000000800031c0 <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    800031c0:	1101                	addi	sp,sp,-32
    800031c2:	ec06                	sd	ra,24(sp)
    800031c4:	e822                	sd	s0,16(sp)
    800031c6:	e426                	sd	s1,8(sp)
    800031c8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800031ca:	fffff097          	auipc	ra,0xfffff
    800031ce:	956080e7          	jalr	-1706(ra) # 80001b20 <myproc>
    800031d2:	84aa                	mv	s1,a0

  // Restore Kernel Values
  memmove(p->trapframe, p->alarm_trapframe, PGSIZE);
    800031d4:	6605                	lui	a2,0x1
    800031d6:	1b053583          	ld	a1,432(a0)
    800031da:	6d28                	ld	a0,88(a0)
    800031dc:	ffffe097          	auipc	ra,0xffffe
    800031e0:	cc6080e7          	jalr	-826(ra) # 80000ea2 <memmove>
  kfree(p->alarm_trapframe);
    800031e4:	1b04b503          	ld	a0,432(s1)
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	890080e7          	jalr	-1904(ra) # 80000a78 <kfree>

  p->sigalarm_status = 0;
    800031f0:	1a04ac23          	sw	zero,440(s1)
  p->alarm_trapframe = 0;
    800031f4:	1a04b823          	sd	zero,432(s1)
  p->now_ticks = 0;
    800031f8:	1a04a623          	sw	zero,428(s1)
  usertrapret();
    800031fc:	00000097          	auipc	ra,0x0
    80003200:	844080e7          	jalr	-1980(ra) # 80002a40 <usertrapret>
  return 0;
}
    80003204:	4501                	li	a0,0
    80003206:	60e2                	ld	ra,24(sp)
    80003208:	6442                	ld	s0,16(sp)
    8000320a:	64a2                	ld	s1,8(sp)
    8000320c:	6105                	addi	sp,sp,32
    8000320e:	8082                	ret

0000000080003210 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003210:	7139                	addi	sp,sp,-64
    80003212:	fc06                	sd	ra,56(sp)
    80003214:	f822                	sd	s0,48(sp)
    80003216:	f426                	sd	s1,40(sp)
    80003218:	f04a                	sd	s2,32(sp)
    8000321a:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000321c:	fd840593          	addi	a1,s0,-40
    80003220:	4501                	li	a0,0
    80003222:	00000097          	auipc	ra,0x0
    80003226:	cac080e7          	jalr	-852(ra) # 80002ece <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000322a:	fd040593          	addi	a1,s0,-48
    8000322e:	4505                	li	a0,1
    80003230:	00000097          	auipc	ra,0x0
    80003234:	c9e080e7          	jalr	-866(ra) # 80002ece <argaddr>
  argaddr(2, &addr2);
    80003238:	fc840593          	addi	a1,s0,-56
    8000323c:	4509                	li	a0,2
    8000323e:	00000097          	auipc	ra,0x0
    80003242:	c90080e7          	jalr	-880(ra) # 80002ece <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003246:	fc040613          	addi	a2,s0,-64
    8000324a:	fc440593          	addi	a1,s0,-60
    8000324e:	fd843503          	ld	a0,-40(s0)
    80003252:	fffff097          	auipc	ra,0xfffff
    80003256:	59a080e7          	jalr	1434(ra) # 800027ec <waitx>
    8000325a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000325c:	fffff097          	auipc	ra,0xfffff
    80003260:	8c4080e7          	jalr	-1852(ra) # 80001b20 <myproc>
    80003264:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003266:	4691                	li	a3,4
    80003268:	fc440613          	addi	a2,s0,-60
    8000326c:	fd043583          	ld	a1,-48(s0)
    80003270:	6928                	ld	a0,80(a0)
    80003272:	ffffe097          	auipc	ra,0xffffe
    80003276:	56e080e7          	jalr	1390(ra) # 800017e0 <copyout>
    return -1;
    8000327a:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000327c:	00054f63          	bltz	a0,8000329a <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003280:	4691                	li	a3,4
    80003282:	fc040613          	addi	a2,s0,-64
    80003286:	fc843583          	ld	a1,-56(s0)
    8000328a:	68a8                	ld	a0,80(s1)
    8000328c:	ffffe097          	auipc	ra,0xffffe
    80003290:	554080e7          	jalr	1364(ra) # 800017e0 <copyout>
    80003294:	00054a63          	bltz	a0,800032a8 <sys_waitx+0x98>
    return -1;
  return ret;
    80003298:	87ca                	mv	a5,s2
    8000329a:	853e                	mv	a0,a5
    8000329c:	70e2                	ld	ra,56(sp)
    8000329e:	7442                	ld	s0,48(sp)
    800032a0:	74a2                	ld	s1,40(sp)
    800032a2:	7902                	ld	s2,32(sp)
    800032a4:	6121                	addi	sp,sp,64
    800032a6:	8082                	ret
    return -1;
    800032a8:	57fd                	li	a5,-1
    800032aa:	bfc5                	j	8000329a <sys_waitx+0x8a>

00000000800032ac <binit>:
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void binit(void)
{
    800032ac:	7179                	addi	sp,sp,-48
    800032ae:	f406                	sd	ra,40(sp)
    800032b0:	f022                	sd	s0,32(sp)
    800032b2:	ec26                	sd	s1,24(sp)
    800032b4:	e84a                	sd	s2,16(sp)
    800032b6:	e44e                	sd	s3,8(sp)
    800032b8:	e052                	sd	s4,0(sp)
    800032ba:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800032bc:	00005597          	auipc	a1,0x5
    800032c0:	36c58593          	addi	a1,a1,876 # 80008628 <syscalls+0xc8>
    800032c4:	00236517          	auipc	a0,0x236
    800032c8:	91450513          	addi	a0,a0,-1772 # 80238bd8 <bcache>
    800032cc:	ffffe097          	auipc	ra,0xffffe
    800032d0:	9ee080e7          	jalr	-1554(ra) # 80000cba <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800032d4:	0023e797          	auipc	a5,0x23e
    800032d8:	90478793          	addi	a5,a5,-1788 # 80240bd8 <bcache+0x8000>
    800032dc:	0023e717          	auipc	a4,0x23e
    800032e0:	b6470713          	addi	a4,a4,-1180 # 80240e40 <bcache+0x8268>
    800032e4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800032e8:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    800032ec:	00236497          	auipc	s1,0x236
    800032f0:	90448493          	addi	s1,s1,-1788 # 80238bf0 <bcache+0x18>
  {
    b->next = bcache.head.next;
    800032f4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800032f6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800032f8:	00005a17          	auipc	s4,0x5
    800032fc:	338a0a13          	addi	s4,s4,824 # 80008630 <syscalls+0xd0>
    b->next = bcache.head.next;
    80003300:	2b893783          	ld	a5,696(s2)
    80003304:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003306:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000330a:	85d2                	mv	a1,s4
    8000330c:	01048513          	addi	a0,s1,16
    80003310:	00001097          	auipc	ra,0x1
    80003314:	4c8080e7          	jalr	1224(ra) # 800047d8 <initsleeplock>
    bcache.head.next->prev = b;
    80003318:	2b893783          	ld	a5,696(s2)
    8000331c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000331e:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    80003322:	45848493          	addi	s1,s1,1112
    80003326:	fd349de3          	bne	s1,s3,80003300 <binit+0x54>
  }
}
    8000332a:	70a2                	ld	ra,40(sp)
    8000332c:	7402                	ld	s0,32(sp)
    8000332e:	64e2                	ld	s1,24(sp)
    80003330:	6942                	ld	s2,16(sp)
    80003332:	69a2                	ld	s3,8(sp)
    80003334:	6a02                	ld	s4,0(sp)
    80003336:	6145                	addi	sp,sp,48
    80003338:	8082                	ret

000000008000333a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    8000333a:	7179                	addi	sp,sp,-48
    8000333c:	f406                	sd	ra,40(sp)
    8000333e:	f022                	sd	s0,32(sp)
    80003340:	ec26                	sd	s1,24(sp)
    80003342:	e84a                	sd	s2,16(sp)
    80003344:	e44e                	sd	s3,8(sp)
    80003346:	1800                	addi	s0,sp,48
    80003348:	892a                	mv	s2,a0
    8000334a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000334c:	00236517          	auipc	a0,0x236
    80003350:	88c50513          	addi	a0,a0,-1908 # 80238bd8 <bcache>
    80003354:	ffffe097          	auipc	ra,0xffffe
    80003358:	9f6080e7          	jalr	-1546(ra) # 80000d4a <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next)
    8000335c:	0023e497          	auipc	s1,0x23e
    80003360:	b344b483          	ld	s1,-1228(s1) # 80240e90 <bcache+0x82b8>
    80003364:	0023e797          	auipc	a5,0x23e
    80003368:	adc78793          	addi	a5,a5,-1316 # 80240e40 <bcache+0x8268>
    8000336c:	02f48f63          	beq	s1,a5,800033aa <bread+0x70>
    80003370:	873e                	mv	a4,a5
    80003372:	a021                	j	8000337a <bread+0x40>
    80003374:	68a4                	ld	s1,80(s1)
    80003376:	02e48a63          	beq	s1,a4,800033aa <bread+0x70>
    if (b->dev == dev && b->blockno == blockno)
    8000337a:	449c                	lw	a5,8(s1)
    8000337c:	ff279ce3          	bne	a5,s2,80003374 <bread+0x3a>
    80003380:	44dc                	lw	a5,12(s1)
    80003382:	ff3799e3          	bne	a5,s3,80003374 <bread+0x3a>
      b->refcnt++;
    80003386:	40bc                	lw	a5,64(s1)
    80003388:	2785                	addiw	a5,a5,1
    8000338a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000338c:	00236517          	auipc	a0,0x236
    80003390:	84c50513          	addi	a0,a0,-1972 # 80238bd8 <bcache>
    80003394:	ffffe097          	auipc	ra,0xffffe
    80003398:	a6a080e7          	jalr	-1430(ra) # 80000dfe <release>
      acquiresleep(&b->lock);
    8000339c:	01048513          	addi	a0,s1,16
    800033a0:	00001097          	auipc	ra,0x1
    800033a4:	472080e7          	jalr	1138(ra) # 80004812 <acquiresleep>
      return b;
    800033a8:	a8b9                	j	80003406 <bread+0xcc>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    800033aa:	0023e497          	auipc	s1,0x23e
    800033ae:	ade4b483          	ld	s1,-1314(s1) # 80240e88 <bcache+0x82b0>
    800033b2:	0023e797          	auipc	a5,0x23e
    800033b6:	a8e78793          	addi	a5,a5,-1394 # 80240e40 <bcache+0x8268>
    800033ba:	00f48863          	beq	s1,a5,800033ca <bread+0x90>
    800033be:	873e                	mv	a4,a5
    if (b->refcnt == 0)
    800033c0:	40bc                	lw	a5,64(s1)
    800033c2:	cf81                	beqz	a5,800033da <bread+0xa0>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    800033c4:	64a4                	ld	s1,72(s1)
    800033c6:	fee49de3          	bne	s1,a4,800033c0 <bread+0x86>
  panic("bget: no buffers");
    800033ca:	00005517          	auipc	a0,0x5
    800033ce:	26e50513          	addi	a0,a0,622 # 80008638 <syscalls+0xd8>
    800033d2:	ffffd097          	auipc	ra,0xffffd
    800033d6:	16e080e7          	jalr	366(ra) # 80000540 <panic>
      b->dev = dev;
    800033da:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800033de:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800033e2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800033e6:	4785                	li	a5,1
    800033e8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033ea:	00235517          	auipc	a0,0x235
    800033ee:	7ee50513          	addi	a0,a0,2030 # 80238bd8 <bcache>
    800033f2:	ffffe097          	auipc	ra,0xffffe
    800033f6:	a0c080e7          	jalr	-1524(ra) # 80000dfe <release>
      acquiresleep(&b->lock);
    800033fa:	01048513          	addi	a0,s1,16
    800033fe:	00001097          	auipc	ra,0x1
    80003402:	414080e7          	jalr	1044(ra) # 80004812 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid)
    80003406:	409c                	lw	a5,0(s1)
    80003408:	cb89                	beqz	a5,8000341a <bread+0xe0>
  {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000340a:	8526                	mv	a0,s1
    8000340c:	70a2                	ld	ra,40(sp)
    8000340e:	7402                	ld	s0,32(sp)
    80003410:	64e2                	ld	s1,24(sp)
    80003412:	6942                	ld	s2,16(sp)
    80003414:	69a2                	ld	s3,8(sp)
    80003416:	6145                	addi	sp,sp,48
    80003418:	8082                	ret
    virtio_disk_rw(b, 0);
    8000341a:	4581                	li	a1,0
    8000341c:	8526                	mv	a0,s1
    8000341e:	00003097          	auipc	ra,0x3
    80003422:	2b8080e7          	jalr	696(ra) # 800066d6 <virtio_disk_rw>
    b->valid = 1;
    80003426:	4785                	li	a5,1
    80003428:	c09c                	sw	a5,0(s1)
  return b;
    8000342a:	b7c5                	j	8000340a <bread+0xd0>

000000008000342c <bwrite>:

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
    8000342c:	1101                	addi	sp,sp,-32
    8000342e:	ec06                	sd	ra,24(sp)
    80003430:	e822                	sd	s0,16(sp)
    80003432:	e426                	sd	s1,8(sp)
    80003434:	1000                	addi	s0,sp,32
    80003436:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003438:	0541                	addi	a0,a0,16
    8000343a:	00001097          	auipc	ra,0x1
    8000343e:	472080e7          	jalr	1138(ra) # 800048ac <holdingsleep>
    80003442:	cd01                	beqz	a0,8000345a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003444:	4585                	li	a1,1
    80003446:	8526                	mv	a0,s1
    80003448:	00003097          	auipc	ra,0x3
    8000344c:	28e080e7          	jalr	654(ra) # 800066d6 <virtio_disk_rw>
}
    80003450:	60e2                	ld	ra,24(sp)
    80003452:	6442                	ld	s0,16(sp)
    80003454:	64a2                	ld	s1,8(sp)
    80003456:	6105                	addi	sp,sp,32
    80003458:	8082                	ret
    panic("bwrite");
    8000345a:	00005517          	auipc	a0,0x5
    8000345e:	1f650513          	addi	a0,a0,502 # 80008650 <syscalls+0xf0>
    80003462:	ffffd097          	auipc	ra,0xffffd
    80003466:	0de080e7          	jalr	222(ra) # 80000540 <panic>

000000008000346a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)
{
    8000346a:	1101                	addi	sp,sp,-32
    8000346c:	ec06                	sd	ra,24(sp)
    8000346e:	e822                	sd	s0,16(sp)
    80003470:	e426                	sd	s1,8(sp)
    80003472:	e04a                	sd	s2,0(sp)
    80003474:	1000                	addi	s0,sp,32
    80003476:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003478:	01050913          	addi	s2,a0,16
    8000347c:	854a                	mv	a0,s2
    8000347e:	00001097          	auipc	ra,0x1
    80003482:	42e080e7          	jalr	1070(ra) # 800048ac <holdingsleep>
    80003486:	c92d                	beqz	a0,800034f8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003488:	854a                	mv	a0,s2
    8000348a:	00001097          	auipc	ra,0x1
    8000348e:	3de080e7          	jalr	990(ra) # 80004868 <releasesleep>

  acquire(&bcache.lock);
    80003492:	00235517          	auipc	a0,0x235
    80003496:	74650513          	addi	a0,a0,1862 # 80238bd8 <bcache>
    8000349a:	ffffe097          	auipc	ra,0xffffe
    8000349e:	8b0080e7          	jalr	-1872(ra) # 80000d4a <acquire>
  b->refcnt--;
    800034a2:	40bc                	lw	a5,64(s1)
    800034a4:	37fd                	addiw	a5,a5,-1
    800034a6:	0007871b          	sext.w	a4,a5
    800034aa:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0)
    800034ac:	eb05                	bnez	a4,800034dc <brelse+0x72>
  {
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034ae:	68bc                	ld	a5,80(s1)
    800034b0:	64b8                	ld	a4,72(s1)
    800034b2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800034b4:	64bc                	ld	a5,72(s1)
    800034b6:	68b8                	ld	a4,80(s1)
    800034b8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800034ba:	0023d797          	auipc	a5,0x23d
    800034be:	71e78793          	addi	a5,a5,1822 # 80240bd8 <bcache+0x8000>
    800034c2:	2b87b703          	ld	a4,696(a5)
    800034c6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034c8:	0023e717          	auipc	a4,0x23e
    800034cc:	97870713          	addi	a4,a4,-1672 # 80240e40 <bcache+0x8268>
    800034d0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034d2:	2b87b703          	ld	a4,696(a5)
    800034d6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800034d8:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    800034dc:	00235517          	auipc	a0,0x235
    800034e0:	6fc50513          	addi	a0,a0,1788 # 80238bd8 <bcache>
    800034e4:	ffffe097          	auipc	ra,0xffffe
    800034e8:	91a080e7          	jalr	-1766(ra) # 80000dfe <release>
}
    800034ec:	60e2                	ld	ra,24(sp)
    800034ee:	6442                	ld	s0,16(sp)
    800034f0:	64a2                	ld	s1,8(sp)
    800034f2:	6902                	ld	s2,0(sp)
    800034f4:	6105                	addi	sp,sp,32
    800034f6:	8082                	ret
    panic("brelse");
    800034f8:	00005517          	auipc	a0,0x5
    800034fc:	16050513          	addi	a0,a0,352 # 80008658 <syscalls+0xf8>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	040080e7          	jalr	64(ra) # 80000540 <panic>

0000000080003508 <bpin>:

void bpin(struct buf *b)
{
    80003508:	1101                	addi	sp,sp,-32
    8000350a:	ec06                	sd	ra,24(sp)
    8000350c:	e822                	sd	s0,16(sp)
    8000350e:	e426                	sd	s1,8(sp)
    80003510:	1000                	addi	s0,sp,32
    80003512:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003514:	00235517          	auipc	a0,0x235
    80003518:	6c450513          	addi	a0,a0,1732 # 80238bd8 <bcache>
    8000351c:	ffffe097          	auipc	ra,0xffffe
    80003520:	82e080e7          	jalr	-2002(ra) # 80000d4a <acquire>
  b->refcnt++;
    80003524:	40bc                	lw	a5,64(s1)
    80003526:	2785                	addiw	a5,a5,1
    80003528:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000352a:	00235517          	auipc	a0,0x235
    8000352e:	6ae50513          	addi	a0,a0,1710 # 80238bd8 <bcache>
    80003532:	ffffe097          	auipc	ra,0xffffe
    80003536:	8cc080e7          	jalr	-1844(ra) # 80000dfe <release>
}
    8000353a:	60e2                	ld	ra,24(sp)
    8000353c:	6442                	ld	s0,16(sp)
    8000353e:	64a2                	ld	s1,8(sp)
    80003540:	6105                	addi	sp,sp,32
    80003542:	8082                	ret

0000000080003544 <bunpin>:

void bunpin(struct buf *b)
{
    80003544:	1101                	addi	sp,sp,-32
    80003546:	ec06                	sd	ra,24(sp)
    80003548:	e822                	sd	s0,16(sp)
    8000354a:	e426                	sd	s1,8(sp)
    8000354c:	1000                	addi	s0,sp,32
    8000354e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003550:	00235517          	auipc	a0,0x235
    80003554:	68850513          	addi	a0,a0,1672 # 80238bd8 <bcache>
    80003558:	ffffd097          	auipc	ra,0xffffd
    8000355c:	7f2080e7          	jalr	2034(ra) # 80000d4a <acquire>
  b->refcnt--;
    80003560:	40bc                	lw	a5,64(s1)
    80003562:	37fd                	addiw	a5,a5,-1
    80003564:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003566:	00235517          	auipc	a0,0x235
    8000356a:	67250513          	addi	a0,a0,1650 # 80238bd8 <bcache>
    8000356e:	ffffe097          	auipc	ra,0xffffe
    80003572:	890080e7          	jalr	-1904(ra) # 80000dfe <release>
}
    80003576:	60e2                	ld	ra,24(sp)
    80003578:	6442                	ld	s0,16(sp)
    8000357a:	64a2                	ld	s1,8(sp)
    8000357c:	6105                	addi	sp,sp,32
    8000357e:	8082                	ret

0000000080003580 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003580:	1101                	addi	sp,sp,-32
    80003582:	ec06                	sd	ra,24(sp)
    80003584:	e822                	sd	s0,16(sp)
    80003586:	e426                	sd	s1,8(sp)
    80003588:	e04a                	sd	s2,0(sp)
    8000358a:	1000                	addi	s0,sp,32
    8000358c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000358e:	00d5d59b          	srliw	a1,a1,0xd
    80003592:	0023e797          	auipc	a5,0x23e
    80003596:	d227a783          	lw	a5,-734(a5) # 802412b4 <sb+0x1c>
    8000359a:	9dbd                	addw	a1,a1,a5
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	d9e080e7          	jalr	-610(ra) # 8000333a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035a4:	0074f713          	andi	a4,s1,7
    800035a8:	4785                	li	a5,1
    800035aa:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    800035ae:	14ce                	slli	s1,s1,0x33
    800035b0:	90d9                	srli	s1,s1,0x36
    800035b2:	00950733          	add	a4,a0,s1
    800035b6:	05874703          	lbu	a4,88(a4)
    800035ba:	00e7f6b3          	and	a3,a5,a4
    800035be:	c69d                	beqz	a3,800035ec <bfree+0x6c>
    800035c0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    800035c2:	94aa                	add	s1,s1,a0
    800035c4:	fff7c793          	not	a5,a5
    800035c8:	8f7d                	and	a4,a4,a5
    800035ca:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800035ce:	00001097          	auipc	ra,0x1
    800035d2:	126080e7          	jalr	294(ra) # 800046f4 <log_write>
  brelse(bp);
    800035d6:	854a                	mv	a0,s2
    800035d8:	00000097          	auipc	ra,0x0
    800035dc:	e92080e7          	jalr	-366(ra) # 8000346a <brelse>
}
    800035e0:	60e2                	ld	ra,24(sp)
    800035e2:	6442                	ld	s0,16(sp)
    800035e4:	64a2                	ld	s1,8(sp)
    800035e6:	6902                	ld	s2,0(sp)
    800035e8:	6105                	addi	sp,sp,32
    800035ea:	8082                	ret
    panic("freeing free block");
    800035ec:	00005517          	auipc	a0,0x5
    800035f0:	07450513          	addi	a0,a0,116 # 80008660 <syscalls+0x100>
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	f4c080e7          	jalr	-180(ra) # 80000540 <panic>

00000000800035fc <balloc>:
{
    800035fc:	711d                	addi	sp,sp,-96
    800035fe:	ec86                	sd	ra,88(sp)
    80003600:	e8a2                	sd	s0,80(sp)
    80003602:	e4a6                	sd	s1,72(sp)
    80003604:	e0ca                	sd	s2,64(sp)
    80003606:	fc4e                	sd	s3,56(sp)
    80003608:	f852                	sd	s4,48(sp)
    8000360a:	f456                	sd	s5,40(sp)
    8000360c:	f05a                	sd	s6,32(sp)
    8000360e:	ec5e                	sd	s7,24(sp)
    80003610:	e862                	sd	s8,16(sp)
    80003612:	e466                	sd	s9,8(sp)
    80003614:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB)
    80003616:	0023e797          	auipc	a5,0x23e
    8000361a:	c867a783          	lw	a5,-890(a5) # 8024129c <sb+0x4>
    8000361e:	cff5                	beqz	a5,8000371a <balloc+0x11e>
    80003620:	8baa                	mv	s7,a0
    80003622:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003624:	0023eb17          	auipc	s6,0x23e
    80003628:	c74b0b13          	addi	s6,s6,-908 # 80241298 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    8000362c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000362e:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003630:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB)
    80003632:	6c89                	lui	s9,0x2
    80003634:	a061                	j	800036bc <balloc+0xc0>
        bp->data[bi / 8] |= m; // Mark block in use.
    80003636:	97ca                	add	a5,a5,s2
    80003638:	8e55                	or	a2,a2,a3
    8000363a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000363e:	854a                	mv	a0,s2
    80003640:	00001097          	auipc	ra,0x1
    80003644:	0b4080e7          	jalr	180(ra) # 800046f4 <log_write>
        brelse(bp);
    80003648:	854a                	mv	a0,s2
    8000364a:	00000097          	auipc	ra,0x0
    8000364e:	e20080e7          	jalr	-480(ra) # 8000346a <brelse>
  bp = bread(dev, bno);
    80003652:	85a6                	mv	a1,s1
    80003654:	855e                	mv	a0,s7
    80003656:	00000097          	auipc	ra,0x0
    8000365a:	ce4080e7          	jalr	-796(ra) # 8000333a <bread>
    8000365e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003660:	40000613          	li	a2,1024
    80003664:	4581                	li	a1,0
    80003666:	05850513          	addi	a0,a0,88
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	7dc080e7          	jalr	2012(ra) # 80000e46 <memset>
  log_write(bp);
    80003672:	854a                	mv	a0,s2
    80003674:	00001097          	auipc	ra,0x1
    80003678:	080080e7          	jalr	128(ra) # 800046f4 <log_write>
  brelse(bp);
    8000367c:	854a                	mv	a0,s2
    8000367e:	00000097          	auipc	ra,0x0
    80003682:	dec080e7          	jalr	-532(ra) # 8000346a <brelse>
}
    80003686:	8526                	mv	a0,s1
    80003688:	60e6                	ld	ra,88(sp)
    8000368a:	6446                	ld	s0,80(sp)
    8000368c:	64a6                	ld	s1,72(sp)
    8000368e:	6906                	ld	s2,64(sp)
    80003690:	79e2                	ld	s3,56(sp)
    80003692:	7a42                	ld	s4,48(sp)
    80003694:	7aa2                	ld	s5,40(sp)
    80003696:	7b02                	ld	s6,32(sp)
    80003698:	6be2                	ld	s7,24(sp)
    8000369a:	6c42                	ld	s8,16(sp)
    8000369c:	6ca2                	ld	s9,8(sp)
    8000369e:	6125                	addi	sp,sp,96
    800036a0:	8082                	ret
    brelse(bp);
    800036a2:	854a                	mv	a0,s2
    800036a4:	00000097          	auipc	ra,0x0
    800036a8:	dc6080e7          	jalr	-570(ra) # 8000346a <brelse>
  for (b = 0; b < sb.size; b += BPB)
    800036ac:	015c87bb          	addw	a5,s9,s5
    800036b0:	00078a9b          	sext.w	s5,a5
    800036b4:	004b2703          	lw	a4,4(s6)
    800036b8:	06eaf163          	bgeu	s5,a4,8000371a <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800036bc:	41fad79b          	sraiw	a5,s5,0x1f
    800036c0:	0137d79b          	srliw	a5,a5,0x13
    800036c4:	015787bb          	addw	a5,a5,s5
    800036c8:	40d7d79b          	sraiw	a5,a5,0xd
    800036cc:	01cb2583          	lw	a1,28(s6)
    800036d0:	9dbd                	addw	a1,a1,a5
    800036d2:	855e                	mv	a0,s7
    800036d4:	00000097          	auipc	ra,0x0
    800036d8:	c66080e7          	jalr	-922(ra) # 8000333a <bread>
    800036dc:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800036de:	004b2503          	lw	a0,4(s6)
    800036e2:	000a849b          	sext.w	s1,s5
    800036e6:	8762                	mv	a4,s8
    800036e8:	faa4fde3          	bgeu	s1,a0,800036a2 <balloc+0xa6>
      m = 1 << (bi % 8);
    800036ec:	00777693          	andi	a3,a4,7
    800036f0:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0)
    800036f4:	41f7579b          	sraiw	a5,a4,0x1f
    800036f8:	01d7d79b          	srliw	a5,a5,0x1d
    800036fc:	9fb9                	addw	a5,a5,a4
    800036fe:	4037d79b          	sraiw	a5,a5,0x3
    80003702:	00f90633          	add	a2,s2,a5
    80003706:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000370a:	00c6f5b3          	and	a1,a3,a2
    8000370e:	d585                	beqz	a1,80003636 <balloc+0x3a>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003710:	2705                	addiw	a4,a4,1
    80003712:	2485                	addiw	s1,s1,1
    80003714:	fd471ae3          	bne	a4,s4,800036e8 <balloc+0xec>
    80003718:	b769                	j	800036a2 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000371a:	00005517          	auipc	a0,0x5
    8000371e:	f5e50513          	addi	a0,a0,-162 # 80008678 <syscalls+0x118>
    80003722:	ffffd097          	auipc	ra,0xffffd
    80003726:	e68080e7          	jalr	-408(ra) # 8000058a <printf>
  return 0;
    8000372a:	4481                	li	s1,0
    8000372c:	bfa9                	j	80003686 <balloc+0x8a>

000000008000372e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000372e:	7179                	addi	sp,sp,-48
    80003730:	f406                	sd	ra,40(sp)
    80003732:	f022                	sd	s0,32(sp)
    80003734:	ec26                	sd	s1,24(sp)
    80003736:	e84a                	sd	s2,16(sp)
    80003738:	e44e                	sd	s3,8(sp)
    8000373a:	e052                	sd	s4,0(sp)
    8000373c:	1800                	addi	s0,sp,48
    8000373e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT)
    80003740:	47ad                	li	a5,11
    80003742:	02b7e863          	bltu	a5,a1,80003772 <bmap+0x44>
  {
    if ((addr = ip->addrs[bn]) == 0)
    80003746:	02059793          	slli	a5,a1,0x20
    8000374a:	01e7d593          	srli	a1,a5,0x1e
    8000374e:	00b504b3          	add	s1,a0,a1
    80003752:	0504a903          	lw	s2,80(s1)
    80003756:	06091e63          	bnez	s2,800037d2 <bmap+0xa4>
    {
      addr = balloc(ip->dev);
    8000375a:	4108                	lw	a0,0(a0)
    8000375c:	00000097          	auipc	ra,0x0
    80003760:	ea0080e7          	jalr	-352(ra) # 800035fc <balloc>
    80003764:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003768:	06090563          	beqz	s2,800037d2 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000376c:	0524a823          	sw	s2,80(s1)
    80003770:	a08d                	j	800037d2 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003772:	ff45849b          	addiw	s1,a1,-12
    80003776:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT)
    8000377a:	0ff00793          	li	a5,255
    8000377e:	08e7e563          	bltu	a5,a4,80003808 <bmap+0xda>
  {
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0)
    80003782:	08052903          	lw	s2,128(a0)
    80003786:	00091d63          	bnez	s2,800037a0 <bmap+0x72>
    {
      addr = balloc(ip->dev);
    8000378a:	4108                	lw	a0,0(a0)
    8000378c:	00000097          	auipc	ra,0x0
    80003790:	e70080e7          	jalr	-400(ra) # 800035fc <balloc>
    80003794:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003798:	02090d63          	beqz	s2,800037d2 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000379c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800037a0:	85ca                	mv	a1,s2
    800037a2:	0009a503          	lw	a0,0(s3)
    800037a6:	00000097          	auipc	ra,0x0
    800037aa:	b94080e7          	jalr	-1132(ra) # 8000333a <bread>
    800037ae:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800037b0:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0)
    800037b4:	02049713          	slli	a4,s1,0x20
    800037b8:	01e75593          	srli	a1,a4,0x1e
    800037bc:	00b784b3          	add	s1,a5,a1
    800037c0:	0004a903          	lw	s2,0(s1)
    800037c4:	02090063          	beqz	s2,800037e4 <bmap+0xb6>
      {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800037c8:	8552                	mv	a0,s4
    800037ca:	00000097          	auipc	ra,0x0
    800037ce:	ca0080e7          	jalr	-864(ra) # 8000346a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800037d2:	854a                	mv	a0,s2
    800037d4:	70a2                	ld	ra,40(sp)
    800037d6:	7402                	ld	s0,32(sp)
    800037d8:	64e2                	ld	s1,24(sp)
    800037da:	6942                	ld	s2,16(sp)
    800037dc:	69a2                	ld	s3,8(sp)
    800037de:	6a02                	ld	s4,0(sp)
    800037e0:	6145                	addi	sp,sp,48
    800037e2:	8082                	ret
      addr = balloc(ip->dev);
    800037e4:	0009a503          	lw	a0,0(s3)
    800037e8:	00000097          	auipc	ra,0x0
    800037ec:	e14080e7          	jalr	-492(ra) # 800035fc <balloc>
    800037f0:	0005091b          	sext.w	s2,a0
      if (addr)
    800037f4:	fc090ae3          	beqz	s2,800037c8 <bmap+0x9a>
        a[bn] = addr;
    800037f8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800037fc:	8552                	mv	a0,s4
    800037fe:	00001097          	auipc	ra,0x1
    80003802:	ef6080e7          	jalr	-266(ra) # 800046f4 <log_write>
    80003806:	b7c9                	j	800037c8 <bmap+0x9a>
  panic("bmap: out of range");
    80003808:	00005517          	auipc	a0,0x5
    8000380c:	e8850513          	addi	a0,a0,-376 # 80008690 <syscalls+0x130>
    80003810:	ffffd097          	auipc	ra,0xffffd
    80003814:	d30080e7          	jalr	-720(ra) # 80000540 <panic>

0000000080003818 <iget>:
{
    80003818:	7179                	addi	sp,sp,-48
    8000381a:	f406                	sd	ra,40(sp)
    8000381c:	f022                	sd	s0,32(sp)
    8000381e:	ec26                	sd	s1,24(sp)
    80003820:	e84a                	sd	s2,16(sp)
    80003822:	e44e                	sd	s3,8(sp)
    80003824:	e052                	sd	s4,0(sp)
    80003826:	1800                	addi	s0,sp,48
    80003828:	89aa                	mv	s3,a0
    8000382a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000382c:	0023e517          	auipc	a0,0x23e
    80003830:	a8c50513          	addi	a0,a0,-1396 # 802412b8 <itable>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	516080e7          	jalr	1302(ra) # 80000d4a <acquire>
  empty = 0;
    8000383c:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    8000383e:	0023e497          	auipc	s1,0x23e
    80003842:	a9248493          	addi	s1,s1,-1390 # 802412d0 <itable+0x18>
    80003846:	0023f697          	auipc	a3,0x23f
    8000384a:	51a68693          	addi	a3,a3,1306 # 80242d60 <log>
    8000384e:	a039                	j	8000385c <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003850:	02090b63          	beqz	s2,80003886 <iget+0x6e>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    80003854:	08848493          	addi	s1,s1,136
    80003858:	02d48a63          	beq	s1,a3,8000388c <iget+0x74>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum)
    8000385c:	449c                	lw	a5,8(s1)
    8000385e:	fef059e3          	blez	a5,80003850 <iget+0x38>
    80003862:	4098                	lw	a4,0(s1)
    80003864:	ff3716e3          	bne	a4,s3,80003850 <iget+0x38>
    80003868:	40d8                	lw	a4,4(s1)
    8000386a:	ff4713e3          	bne	a4,s4,80003850 <iget+0x38>
      ip->ref++;
    8000386e:	2785                	addiw	a5,a5,1
    80003870:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003872:	0023e517          	auipc	a0,0x23e
    80003876:	a4650513          	addi	a0,a0,-1466 # 802412b8 <itable>
    8000387a:	ffffd097          	auipc	ra,0xffffd
    8000387e:	584080e7          	jalr	1412(ra) # 80000dfe <release>
      return ip;
    80003882:	8926                	mv	s2,s1
    80003884:	a03d                	j	800038b2 <iget+0x9a>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003886:	f7f9                	bnez	a5,80003854 <iget+0x3c>
    80003888:	8926                	mv	s2,s1
    8000388a:	b7e9                	j	80003854 <iget+0x3c>
  if (empty == 0)
    8000388c:	02090c63          	beqz	s2,800038c4 <iget+0xac>
  ip->dev = dev;
    80003890:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003894:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003898:	4785                	li	a5,1
    8000389a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000389e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800038a2:	0023e517          	auipc	a0,0x23e
    800038a6:	a1650513          	addi	a0,a0,-1514 # 802412b8 <itable>
    800038aa:	ffffd097          	auipc	ra,0xffffd
    800038ae:	554080e7          	jalr	1364(ra) # 80000dfe <release>
}
    800038b2:	854a                	mv	a0,s2
    800038b4:	70a2                	ld	ra,40(sp)
    800038b6:	7402                	ld	s0,32(sp)
    800038b8:	64e2                	ld	s1,24(sp)
    800038ba:	6942                	ld	s2,16(sp)
    800038bc:	69a2                	ld	s3,8(sp)
    800038be:	6a02                	ld	s4,0(sp)
    800038c0:	6145                	addi	sp,sp,48
    800038c2:	8082                	ret
    panic("iget: no inodes");
    800038c4:	00005517          	auipc	a0,0x5
    800038c8:	de450513          	addi	a0,a0,-540 # 800086a8 <syscalls+0x148>
    800038cc:	ffffd097          	auipc	ra,0xffffd
    800038d0:	c74080e7          	jalr	-908(ra) # 80000540 <panic>

00000000800038d4 <fsinit>:
{
    800038d4:	7179                	addi	sp,sp,-48
    800038d6:	f406                	sd	ra,40(sp)
    800038d8:	f022                	sd	s0,32(sp)
    800038da:	ec26                	sd	s1,24(sp)
    800038dc:	e84a                	sd	s2,16(sp)
    800038de:	e44e                	sd	s3,8(sp)
    800038e0:	1800                	addi	s0,sp,48
    800038e2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800038e4:	4585                	li	a1,1
    800038e6:	00000097          	auipc	ra,0x0
    800038ea:	a54080e7          	jalr	-1452(ra) # 8000333a <bread>
    800038ee:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800038f0:	0023e997          	auipc	s3,0x23e
    800038f4:	9a898993          	addi	s3,s3,-1624 # 80241298 <sb>
    800038f8:	02000613          	li	a2,32
    800038fc:	05850593          	addi	a1,a0,88
    80003900:	854e                	mv	a0,s3
    80003902:	ffffd097          	auipc	ra,0xffffd
    80003906:	5a0080e7          	jalr	1440(ra) # 80000ea2 <memmove>
  brelse(bp);
    8000390a:	8526                	mv	a0,s1
    8000390c:	00000097          	auipc	ra,0x0
    80003910:	b5e080e7          	jalr	-1186(ra) # 8000346a <brelse>
  if (sb.magic != FSMAGIC)
    80003914:	0009a703          	lw	a4,0(s3)
    80003918:	102037b7          	lui	a5,0x10203
    8000391c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003920:	02f71263          	bne	a4,a5,80003944 <fsinit+0x70>
  initlog(dev, &sb);
    80003924:	0023e597          	auipc	a1,0x23e
    80003928:	97458593          	addi	a1,a1,-1676 # 80241298 <sb>
    8000392c:	854a                	mv	a0,s2
    8000392e:	00001097          	auipc	ra,0x1
    80003932:	b4a080e7          	jalr	-1206(ra) # 80004478 <initlog>
}
    80003936:	70a2                	ld	ra,40(sp)
    80003938:	7402                	ld	s0,32(sp)
    8000393a:	64e2                	ld	s1,24(sp)
    8000393c:	6942                	ld	s2,16(sp)
    8000393e:	69a2                	ld	s3,8(sp)
    80003940:	6145                	addi	sp,sp,48
    80003942:	8082                	ret
    panic("invalid file system");
    80003944:	00005517          	auipc	a0,0x5
    80003948:	d7450513          	addi	a0,a0,-652 # 800086b8 <syscalls+0x158>
    8000394c:	ffffd097          	auipc	ra,0xffffd
    80003950:	bf4080e7          	jalr	-1036(ra) # 80000540 <panic>

0000000080003954 <iinit>:
{
    80003954:	7179                	addi	sp,sp,-48
    80003956:	f406                	sd	ra,40(sp)
    80003958:	f022                	sd	s0,32(sp)
    8000395a:	ec26                	sd	s1,24(sp)
    8000395c:	e84a                	sd	s2,16(sp)
    8000395e:	e44e                	sd	s3,8(sp)
    80003960:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003962:	00005597          	auipc	a1,0x5
    80003966:	d6e58593          	addi	a1,a1,-658 # 800086d0 <syscalls+0x170>
    8000396a:	0023e517          	auipc	a0,0x23e
    8000396e:	94e50513          	addi	a0,a0,-1714 # 802412b8 <itable>
    80003972:	ffffd097          	auipc	ra,0xffffd
    80003976:	348080e7          	jalr	840(ra) # 80000cba <initlock>
  for (i = 0; i < NINODE; i++)
    8000397a:	0023e497          	auipc	s1,0x23e
    8000397e:	96648493          	addi	s1,s1,-1690 # 802412e0 <itable+0x28>
    80003982:	0023f997          	auipc	s3,0x23f
    80003986:	3ee98993          	addi	s3,s3,1006 # 80242d70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000398a:	00005917          	auipc	s2,0x5
    8000398e:	d4e90913          	addi	s2,s2,-690 # 800086d8 <syscalls+0x178>
    80003992:	85ca                	mv	a1,s2
    80003994:	8526                	mv	a0,s1
    80003996:	00001097          	auipc	ra,0x1
    8000399a:	e42080e7          	jalr	-446(ra) # 800047d8 <initsleeplock>
  for (i = 0; i < NINODE; i++)
    8000399e:	08848493          	addi	s1,s1,136
    800039a2:	ff3498e3          	bne	s1,s3,80003992 <iinit+0x3e>
}
    800039a6:	70a2                	ld	ra,40(sp)
    800039a8:	7402                	ld	s0,32(sp)
    800039aa:	64e2                	ld	s1,24(sp)
    800039ac:	6942                	ld	s2,16(sp)
    800039ae:	69a2                	ld	s3,8(sp)
    800039b0:	6145                	addi	sp,sp,48
    800039b2:	8082                	ret

00000000800039b4 <ialloc>:
{
    800039b4:	715d                	addi	sp,sp,-80
    800039b6:	e486                	sd	ra,72(sp)
    800039b8:	e0a2                	sd	s0,64(sp)
    800039ba:	fc26                	sd	s1,56(sp)
    800039bc:	f84a                	sd	s2,48(sp)
    800039be:	f44e                	sd	s3,40(sp)
    800039c0:	f052                	sd	s4,32(sp)
    800039c2:	ec56                	sd	s5,24(sp)
    800039c4:	e85a                	sd	s6,16(sp)
    800039c6:	e45e                	sd	s7,8(sp)
    800039c8:	0880                	addi	s0,sp,80
  for (inum = 1; inum < sb.ninodes; inum++)
    800039ca:	0023e717          	auipc	a4,0x23e
    800039ce:	8da72703          	lw	a4,-1830(a4) # 802412a4 <sb+0xc>
    800039d2:	4785                	li	a5,1
    800039d4:	04e7fa63          	bgeu	a5,a4,80003a28 <ialloc+0x74>
    800039d8:	8aaa                	mv	s5,a0
    800039da:	8bae                	mv	s7,a1
    800039dc:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039de:	0023ea17          	auipc	s4,0x23e
    800039e2:	8baa0a13          	addi	s4,s4,-1862 # 80241298 <sb>
    800039e6:	00048b1b          	sext.w	s6,s1
    800039ea:	0044d593          	srli	a1,s1,0x4
    800039ee:	018a2783          	lw	a5,24(s4)
    800039f2:	9dbd                	addw	a1,a1,a5
    800039f4:	8556                	mv	a0,s5
    800039f6:	00000097          	auipc	ra,0x0
    800039fa:	944080e7          	jalr	-1724(ra) # 8000333a <bread>
    800039fe:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003a00:	05850993          	addi	s3,a0,88
    80003a04:	00f4f793          	andi	a5,s1,15
    80003a08:	079a                	slli	a5,a5,0x6
    80003a0a:	99be                	add	s3,s3,a5
    if (dip->type == 0)
    80003a0c:	00099783          	lh	a5,0(s3)
    80003a10:	c3a1                	beqz	a5,80003a50 <ialloc+0x9c>
    brelse(bp);
    80003a12:	00000097          	auipc	ra,0x0
    80003a16:	a58080e7          	jalr	-1448(ra) # 8000346a <brelse>
  for (inum = 1; inum < sb.ninodes; inum++)
    80003a1a:	0485                	addi	s1,s1,1
    80003a1c:	00ca2703          	lw	a4,12(s4)
    80003a20:	0004879b          	sext.w	a5,s1
    80003a24:	fce7e1e3          	bltu	a5,a4,800039e6 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003a28:	00005517          	auipc	a0,0x5
    80003a2c:	cb850513          	addi	a0,a0,-840 # 800086e0 <syscalls+0x180>
    80003a30:	ffffd097          	auipc	ra,0xffffd
    80003a34:	b5a080e7          	jalr	-1190(ra) # 8000058a <printf>
  return 0;
    80003a38:	4501                	li	a0,0
}
    80003a3a:	60a6                	ld	ra,72(sp)
    80003a3c:	6406                	ld	s0,64(sp)
    80003a3e:	74e2                	ld	s1,56(sp)
    80003a40:	7942                	ld	s2,48(sp)
    80003a42:	79a2                	ld	s3,40(sp)
    80003a44:	7a02                	ld	s4,32(sp)
    80003a46:	6ae2                	ld	s5,24(sp)
    80003a48:	6b42                	ld	s6,16(sp)
    80003a4a:	6ba2                	ld	s7,8(sp)
    80003a4c:	6161                	addi	sp,sp,80
    80003a4e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a50:	04000613          	li	a2,64
    80003a54:	4581                	li	a1,0
    80003a56:	854e                	mv	a0,s3
    80003a58:	ffffd097          	auipc	ra,0xffffd
    80003a5c:	3ee080e7          	jalr	1006(ra) # 80000e46 <memset>
      dip->type = type;
    80003a60:	01799023          	sh	s7,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003a64:	854a                	mv	a0,s2
    80003a66:	00001097          	auipc	ra,0x1
    80003a6a:	c8e080e7          	jalr	-882(ra) # 800046f4 <log_write>
      brelse(bp);
    80003a6e:	854a                	mv	a0,s2
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	9fa080e7          	jalr	-1542(ra) # 8000346a <brelse>
      return iget(dev, inum);
    80003a78:	85da                	mv	a1,s6
    80003a7a:	8556                	mv	a0,s5
    80003a7c:	00000097          	auipc	ra,0x0
    80003a80:	d9c080e7          	jalr	-612(ra) # 80003818 <iget>
    80003a84:	bf5d                	j	80003a3a <ialloc+0x86>

0000000080003a86 <iupdate>:
{
    80003a86:	1101                	addi	sp,sp,-32
    80003a88:	ec06                	sd	ra,24(sp)
    80003a8a:	e822                	sd	s0,16(sp)
    80003a8c:	e426                	sd	s1,8(sp)
    80003a8e:	e04a                	sd	s2,0(sp)
    80003a90:	1000                	addi	s0,sp,32
    80003a92:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a94:	415c                	lw	a5,4(a0)
    80003a96:	0047d79b          	srliw	a5,a5,0x4
    80003a9a:	0023e597          	auipc	a1,0x23e
    80003a9e:	8165a583          	lw	a1,-2026(a1) # 802412b0 <sb+0x18>
    80003aa2:	9dbd                	addw	a1,a1,a5
    80003aa4:	4108                	lw	a0,0(a0)
    80003aa6:	00000097          	auipc	ra,0x0
    80003aaa:	894080e7          	jalr	-1900(ra) # 8000333a <bread>
    80003aae:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003ab0:	05850793          	addi	a5,a0,88
    80003ab4:	40d8                	lw	a4,4(s1)
    80003ab6:	8b3d                	andi	a4,a4,15
    80003ab8:	071a                	slli	a4,a4,0x6
    80003aba:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003abc:	04449703          	lh	a4,68(s1)
    80003ac0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003ac4:	04649703          	lh	a4,70(s1)
    80003ac8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003acc:	04849703          	lh	a4,72(s1)
    80003ad0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003ad4:	04a49703          	lh	a4,74(s1)
    80003ad8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003adc:	44f8                	lw	a4,76(s1)
    80003ade:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ae0:	03400613          	li	a2,52
    80003ae4:	05048593          	addi	a1,s1,80
    80003ae8:	00c78513          	addi	a0,a5,12
    80003aec:	ffffd097          	auipc	ra,0xffffd
    80003af0:	3b6080e7          	jalr	950(ra) # 80000ea2 <memmove>
  log_write(bp);
    80003af4:	854a                	mv	a0,s2
    80003af6:	00001097          	auipc	ra,0x1
    80003afa:	bfe080e7          	jalr	-1026(ra) # 800046f4 <log_write>
  brelse(bp);
    80003afe:	854a                	mv	a0,s2
    80003b00:	00000097          	auipc	ra,0x0
    80003b04:	96a080e7          	jalr	-1686(ra) # 8000346a <brelse>
}
    80003b08:	60e2                	ld	ra,24(sp)
    80003b0a:	6442                	ld	s0,16(sp)
    80003b0c:	64a2                	ld	s1,8(sp)
    80003b0e:	6902                	ld	s2,0(sp)
    80003b10:	6105                	addi	sp,sp,32
    80003b12:	8082                	ret

0000000080003b14 <idup>:
{
    80003b14:	1101                	addi	sp,sp,-32
    80003b16:	ec06                	sd	ra,24(sp)
    80003b18:	e822                	sd	s0,16(sp)
    80003b1a:	e426                	sd	s1,8(sp)
    80003b1c:	1000                	addi	s0,sp,32
    80003b1e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b20:	0023d517          	auipc	a0,0x23d
    80003b24:	79850513          	addi	a0,a0,1944 # 802412b8 <itable>
    80003b28:	ffffd097          	auipc	ra,0xffffd
    80003b2c:	222080e7          	jalr	546(ra) # 80000d4a <acquire>
  ip->ref++;
    80003b30:	449c                	lw	a5,8(s1)
    80003b32:	2785                	addiw	a5,a5,1
    80003b34:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b36:	0023d517          	auipc	a0,0x23d
    80003b3a:	78250513          	addi	a0,a0,1922 # 802412b8 <itable>
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	2c0080e7          	jalr	704(ra) # 80000dfe <release>
}
    80003b46:	8526                	mv	a0,s1
    80003b48:	60e2                	ld	ra,24(sp)
    80003b4a:	6442                	ld	s0,16(sp)
    80003b4c:	64a2                	ld	s1,8(sp)
    80003b4e:	6105                	addi	sp,sp,32
    80003b50:	8082                	ret

0000000080003b52 <ilock>:
{
    80003b52:	1101                	addi	sp,sp,-32
    80003b54:	ec06                	sd	ra,24(sp)
    80003b56:	e822                	sd	s0,16(sp)
    80003b58:	e426                	sd	s1,8(sp)
    80003b5a:	e04a                	sd	s2,0(sp)
    80003b5c:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003b5e:	c115                	beqz	a0,80003b82 <ilock+0x30>
    80003b60:	84aa                	mv	s1,a0
    80003b62:	451c                	lw	a5,8(a0)
    80003b64:	00f05f63          	blez	a5,80003b82 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b68:	0541                	addi	a0,a0,16
    80003b6a:	00001097          	auipc	ra,0x1
    80003b6e:	ca8080e7          	jalr	-856(ra) # 80004812 <acquiresleep>
  if (ip->valid == 0)
    80003b72:	40bc                	lw	a5,64(s1)
    80003b74:	cf99                	beqz	a5,80003b92 <ilock+0x40>
}
    80003b76:	60e2                	ld	ra,24(sp)
    80003b78:	6442                	ld	s0,16(sp)
    80003b7a:	64a2                	ld	s1,8(sp)
    80003b7c:	6902                	ld	s2,0(sp)
    80003b7e:	6105                	addi	sp,sp,32
    80003b80:	8082                	ret
    panic("ilock");
    80003b82:	00005517          	auipc	a0,0x5
    80003b86:	b7650513          	addi	a0,a0,-1162 # 800086f8 <syscalls+0x198>
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	9b6080e7          	jalr	-1610(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b92:	40dc                	lw	a5,4(s1)
    80003b94:	0047d79b          	srliw	a5,a5,0x4
    80003b98:	0023d597          	auipc	a1,0x23d
    80003b9c:	7185a583          	lw	a1,1816(a1) # 802412b0 <sb+0x18>
    80003ba0:	9dbd                	addw	a1,a1,a5
    80003ba2:	4088                	lw	a0,0(s1)
    80003ba4:	fffff097          	auipc	ra,0xfffff
    80003ba8:	796080e7          	jalr	1942(ra) # 8000333a <bread>
    80003bac:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003bae:	05850593          	addi	a1,a0,88
    80003bb2:	40dc                	lw	a5,4(s1)
    80003bb4:	8bbd                	andi	a5,a5,15
    80003bb6:	079a                	slli	a5,a5,0x6
    80003bb8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003bba:	00059783          	lh	a5,0(a1)
    80003bbe:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003bc2:	00259783          	lh	a5,2(a1)
    80003bc6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003bca:	00459783          	lh	a5,4(a1)
    80003bce:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003bd2:	00659783          	lh	a5,6(a1)
    80003bd6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003bda:	459c                	lw	a5,8(a1)
    80003bdc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003bde:	03400613          	li	a2,52
    80003be2:	05b1                	addi	a1,a1,12
    80003be4:	05048513          	addi	a0,s1,80
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	2ba080e7          	jalr	698(ra) # 80000ea2 <memmove>
    brelse(bp);
    80003bf0:	854a                	mv	a0,s2
    80003bf2:	00000097          	auipc	ra,0x0
    80003bf6:	878080e7          	jalr	-1928(ra) # 8000346a <brelse>
    ip->valid = 1;
    80003bfa:	4785                	li	a5,1
    80003bfc:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003bfe:	04449783          	lh	a5,68(s1)
    80003c02:	fbb5                	bnez	a5,80003b76 <ilock+0x24>
      panic("ilock: no type");
    80003c04:	00005517          	auipc	a0,0x5
    80003c08:	afc50513          	addi	a0,a0,-1284 # 80008700 <syscalls+0x1a0>
    80003c0c:	ffffd097          	auipc	ra,0xffffd
    80003c10:	934080e7          	jalr	-1740(ra) # 80000540 <panic>

0000000080003c14 <iunlock>:
{
    80003c14:	1101                	addi	sp,sp,-32
    80003c16:	ec06                	sd	ra,24(sp)
    80003c18:	e822                	sd	s0,16(sp)
    80003c1a:	e426                	sd	s1,8(sp)
    80003c1c:	e04a                	sd	s2,0(sp)
    80003c1e:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c20:	c905                	beqz	a0,80003c50 <iunlock+0x3c>
    80003c22:	84aa                	mv	s1,a0
    80003c24:	01050913          	addi	s2,a0,16
    80003c28:	854a                	mv	a0,s2
    80003c2a:	00001097          	auipc	ra,0x1
    80003c2e:	c82080e7          	jalr	-894(ra) # 800048ac <holdingsleep>
    80003c32:	cd19                	beqz	a0,80003c50 <iunlock+0x3c>
    80003c34:	449c                	lw	a5,8(s1)
    80003c36:	00f05d63          	blez	a5,80003c50 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c3a:	854a                	mv	a0,s2
    80003c3c:	00001097          	auipc	ra,0x1
    80003c40:	c2c080e7          	jalr	-980(ra) # 80004868 <releasesleep>
}
    80003c44:	60e2                	ld	ra,24(sp)
    80003c46:	6442                	ld	s0,16(sp)
    80003c48:	64a2                	ld	s1,8(sp)
    80003c4a:	6902                	ld	s2,0(sp)
    80003c4c:	6105                	addi	sp,sp,32
    80003c4e:	8082                	ret
    panic("iunlock");
    80003c50:	00005517          	auipc	a0,0x5
    80003c54:	ac050513          	addi	a0,a0,-1344 # 80008710 <syscalls+0x1b0>
    80003c58:	ffffd097          	auipc	ra,0xffffd
    80003c5c:	8e8080e7          	jalr	-1816(ra) # 80000540 <panic>

0000000080003c60 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void itrunc(struct inode *ip)
{
    80003c60:	7179                	addi	sp,sp,-48
    80003c62:	f406                	sd	ra,40(sp)
    80003c64:	f022                	sd	s0,32(sp)
    80003c66:	ec26                	sd	s1,24(sp)
    80003c68:	e84a                	sd	s2,16(sp)
    80003c6a:	e44e                	sd	s3,8(sp)
    80003c6c:	e052                	sd	s4,0(sp)
    80003c6e:	1800                	addi	s0,sp,48
    80003c70:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++)
    80003c72:	05050493          	addi	s1,a0,80
    80003c76:	08050913          	addi	s2,a0,128
    80003c7a:	a021                	j	80003c82 <itrunc+0x22>
    80003c7c:	0491                	addi	s1,s1,4
    80003c7e:	01248d63          	beq	s1,s2,80003c98 <itrunc+0x38>
  {
    if (ip->addrs[i])
    80003c82:	408c                	lw	a1,0(s1)
    80003c84:	dde5                	beqz	a1,80003c7c <itrunc+0x1c>
    {
      bfree(ip->dev, ip->addrs[i]);
    80003c86:	0009a503          	lw	a0,0(s3)
    80003c8a:	00000097          	auipc	ra,0x0
    80003c8e:	8f6080e7          	jalr	-1802(ra) # 80003580 <bfree>
      ip->addrs[i] = 0;
    80003c92:	0004a023          	sw	zero,0(s1)
    80003c96:	b7dd                	j	80003c7c <itrunc+0x1c>
    }
  }

  if (ip->addrs[NDIRECT])
    80003c98:	0809a583          	lw	a1,128(s3)
    80003c9c:	e185                	bnez	a1,80003cbc <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c9e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ca2:	854e                	mv	a0,s3
    80003ca4:	00000097          	auipc	ra,0x0
    80003ca8:	de2080e7          	jalr	-542(ra) # 80003a86 <iupdate>
}
    80003cac:	70a2                	ld	ra,40(sp)
    80003cae:	7402                	ld	s0,32(sp)
    80003cb0:	64e2                	ld	s1,24(sp)
    80003cb2:	6942                	ld	s2,16(sp)
    80003cb4:	69a2                	ld	s3,8(sp)
    80003cb6:	6a02                	ld	s4,0(sp)
    80003cb8:	6145                	addi	sp,sp,48
    80003cba:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003cbc:	0009a503          	lw	a0,0(s3)
    80003cc0:	fffff097          	auipc	ra,0xfffff
    80003cc4:	67a080e7          	jalr	1658(ra) # 8000333a <bread>
    80003cc8:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++)
    80003cca:	05850493          	addi	s1,a0,88
    80003cce:	45850913          	addi	s2,a0,1112
    80003cd2:	a021                	j	80003cda <itrunc+0x7a>
    80003cd4:	0491                	addi	s1,s1,4
    80003cd6:	01248b63          	beq	s1,s2,80003cec <itrunc+0x8c>
      if (a[j])
    80003cda:	408c                	lw	a1,0(s1)
    80003cdc:	dde5                	beqz	a1,80003cd4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003cde:	0009a503          	lw	a0,0(s3)
    80003ce2:	00000097          	auipc	ra,0x0
    80003ce6:	89e080e7          	jalr	-1890(ra) # 80003580 <bfree>
    80003cea:	b7ed                	j	80003cd4 <itrunc+0x74>
    brelse(bp);
    80003cec:	8552                	mv	a0,s4
    80003cee:	fffff097          	auipc	ra,0xfffff
    80003cf2:	77c080e7          	jalr	1916(ra) # 8000346a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003cf6:	0809a583          	lw	a1,128(s3)
    80003cfa:	0009a503          	lw	a0,0(s3)
    80003cfe:	00000097          	auipc	ra,0x0
    80003d02:	882080e7          	jalr	-1918(ra) # 80003580 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d06:	0809a023          	sw	zero,128(s3)
    80003d0a:	bf51                	j	80003c9e <itrunc+0x3e>

0000000080003d0c <iput>:
{
    80003d0c:	1101                	addi	sp,sp,-32
    80003d0e:	ec06                	sd	ra,24(sp)
    80003d10:	e822                	sd	s0,16(sp)
    80003d12:	e426                	sd	s1,8(sp)
    80003d14:	e04a                	sd	s2,0(sp)
    80003d16:	1000                	addi	s0,sp,32
    80003d18:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d1a:	0023d517          	auipc	a0,0x23d
    80003d1e:	59e50513          	addi	a0,a0,1438 # 802412b8 <itable>
    80003d22:	ffffd097          	auipc	ra,0xffffd
    80003d26:	028080e7          	jalr	40(ra) # 80000d4a <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003d2a:	4498                	lw	a4,8(s1)
    80003d2c:	4785                	li	a5,1
    80003d2e:	02f70363          	beq	a4,a5,80003d54 <iput+0x48>
  ip->ref--;
    80003d32:	449c                	lw	a5,8(s1)
    80003d34:	37fd                	addiw	a5,a5,-1
    80003d36:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d38:	0023d517          	auipc	a0,0x23d
    80003d3c:	58050513          	addi	a0,a0,1408 # 802412b8 <itable>
    80003d40:	ffffd097          	auipc	ra,0xffffd
    80003d44:	0be080e7          	jalr	190(ra) # 80000dfe <release>
}
    80003d48:	60e2                	ld	ra,24(sp)
    80003d4a:	6442                	ld	s0,16(sp)
    80003d4c:	64a2                	ld	s1,8(sp)
    80003d4e:	6902                	ld	s2,0(sp)
    80003d50:	6105                	addi	sp,sp,32
    80003d52:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003d54:	40bc                	lw	a5,64(s1)
    80003d56:	dff1                	beqz	a5,80003d32 <iput+0x26>
    80003d58:	04a49783          	lh	a5,74(s1)
    80003d5c:	fbf9                	bnez	a5,80003d32 <iput+0x26>
    acquiresleep(&ip->lock);
    80003d5e:	01048913          	addi	s2,s1,16
    80003d62:	854a                	mv	a0,s2
    80003d64:	00001097          	auipc	ra,0x1
    80003d68:	aae080e7          	jalr	-1362(ra) # 80004812 <acquiresleep>
    release(&itable.lock);
    80003d6c:	0023d517          	auipc	a0,0x23d
    80003d70:	54c50513          	addi	a0,a0,1356 # 802412b8 <itable>
    80003d74:	ffffd097          	auipc	ra,0xffffd
    80003d78:	08a080e7          	jalr	138(ra) # 80000dfe <release>
    itrunc(ip);
    80003d7c:	8526                	mv	a0,s1
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	ee2080e7          	jalr	-286(ra) # 80003c60 <itrunc>
    ip->type = 0;
    80003d86:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d8a:	8526                	mv	a0,s1
    80003d8c:	00000097          	auipc	ra,0x0
    80003d90:	cfa080e7          	jalr	-774(ra) # 80003a86 <iupdate>
    ip->valid = 0;
    80003d94:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d98:	854a                	mv	a0,s2
    80003d9a:	00001097          	auipc	ra,0x1
    80003d9e:	ace080e7          	jalr	-1330(ra) # 80004868 <releasesleep>
    acquire(&itable.lock);
    80003da2:	0023d517          	auipc	a0,0x23d
    80003da6:	51650513          	addi	a0,a0,1302 # 802412b8 <itable>
    80003daa:	ffffd097          	auipc	ra,0xffffd
    80003dae:	fa0080e7          	jalr	-96(ra) # 80000d4a <acquire>
    80003db2:	b741                	j	80003d32 <iput+0x26>

0000000080003db4 <iunlockput>:
{
    80003db4:	1101                	addi	sp,sp,-32
    80003db6:	ec06                	sd	ra,24(sp)
    80003db8:	e822                	sd	s0,16(sp)
    80003dba:	e426                	sd	s1,8(sp)
    80003dbc:	1000                	addi	s0,sp,32
    80003dbe:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	e54080e7          	jalr	-428(ra) # 80003c14 <iunlock>
  iput(ip);
    80003dc8:	8526                	mv	a0,s1
    80003dca:	00000097          	auipc	ra,0x0
    80003dce:	f42080e7          	jalr	-190(ra) # 80003d0c <iput>
}
    80003dd2:	60e2                	ld	ra,24(sp)
    80003dd4:	6442                	ld	s0,16(sp)
    80003dd6:	64a2                	ld	s1,8(sp)
    80003dd8:	6105                	addi	sp,sp,32
    80003dda:	8082                	ret

0000000080003ddc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void stati(struct inode *ip, struct stat *st)
{
    80003ddc:	1141                	addi	sp,sp,-16
    80003dde:	e422                	sd	s0,8(sp)
    80003de0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003de2:	411c                	lw	a5,0(a0)
    80003de4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003de6:	415c                	lw	a5,4(a0)
    80003de8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003dea:	04451783          	lh	a5,68(a0)
    80003dee:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003df2:	04a51783          	lh	a5,74(a0)
    80003df6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003dfa:	04c56783          	lwu	a5,76(a0)
    80003dfe:	e99c                	sd	a5,16(a1)
}
    80003e00:	6422                	ld	s0,8(sp)
    80003e02:	0141                	addi	sp,sp,16
    80003e04:	8082                	ret

0000000080003e06 <readi>:
int readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003e06:	457c                	lw	a5,76(a0)
    80003e08:	0ed7e963          	bltu	a5,a3,80003efa <readi+0xf4>
{
    80003e0c:	7159                	addi	sp,sp,-112
    80003e0e:	f486                	sd	ra,104(sp)
    80003e10:	f0a2                	sd	s0,96(sp)
    80003e12:	eca6                	sd	s1,88(sp)
    80003e14:	e8ca                	sd	s2,80(sp)
    80003e16:	e4ce                	sd	s3,72(sp)
    80003e18:	e0d2                	sd	s4,64(sp)
    80003e1a:	fc56                	sd	s5,56(sp)
    80003e1c:	f85a                	sd	s6,48(sp)
    80003e1e:	f45e                	sd	s7,40(sp)
    80003e20:	f062                	sd	s8,32(sp)
    80003e22:	ec66                	sd	s9,24(sp)
    80003e24:	e86a                	sd	s10,16(sp)
    80003e26:	e46e                	sd	s11,8(sp)
    80003e28:	1880                	addi	s0,sp,112
    80003e2a:	8b2a                	mv	s6,a0
    80003e2c:	8bae                	mv	s7,a1
    80003e2e:	8a32                	mv	s4,a2
    80003e30:	84b6                	mv	s1,a3
    80003e32:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003e34:	9f35                	addw	a4,a4,a3
    return 0;
    80003e36:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003e38:	0ad76063          	bltu	a4,a3,80003ed8 <readi+0xd2>
  if (off + n > ip->size)
    80003e3c:	00e7f463          	bgeu	a5,a4,80003e44 <readi+0x3e>
    n = ip->size - off;
    80003e40:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003e44:	0a0a8963          	beqz	s5,80003ef6 <readi+0xf0>
    80003e48:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003e4a:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1)
    80003e4e:	5c7d                	li	s8,-1
    80003e50:	a82d                	j	80003e8a <readi+0x84>
    80003e52:	020d1d93          	slli	s11,s10,0x20
    80003e56:	020ddd93          	srli	s11,s11,0x20
    80003e5a:	05890613          	addi	a2,s2,88
    80003e5e:	86ee                	mv	a3,s11
    80003e60:	963a                	add	a2,a2,a4
    80003e62:	85d2                	mv	a1,s4
    80003e64:	855e                	mv	a0,s7
    80003e66:	fffff097          	auipc	ra,0xfffff
    80003e6a:	828080e7          	jalr	-2008(ra) # 8000268e <either_copyout>
    80003e6e:	05850d63          	beq	a0,s8,80003ec8 <readi+0xc2>
    {
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e72:	854a                	mv	a0,s2
    80003e74:	fffff097          	auipc	ra,0xfffff
    80003e78:	5f6080e7          	jalr	1526(ra) # 8000346a <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003e7c:	013d09bb          	addw	s3,s10,s3
    80003e80:	009d04bb          	addw	s1,s10,s1
    80003e84:	9a6e                	add	s4,s4,s11
    80003e86:	0559f763          	bgeu	s3,s5,80003ed4 <readi+0xce>
    uint addr = bmap(ip, off / BSIZE);
    80003e8a:	00a4d59b          	srliw	a1,s1,0xa
    80003e8e:	855a                	mv	a0,s6
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	89e080e7          	jalr	-1890(ra) # 8000372e <bmap>
    80003e98:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003e9c:	cd85                	beqz	a1,80003ed4 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003e9e:	000b2503          	lw	a0,0(s6)
    80003ea2:	fffff097          	auipc	ra,0xfffff
    80003ea6:	498080e7          	jalr	1176(ra) # 8000333a <bread>
    80003eaa:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003eac:	3ff4f713          	andi	a4,s1,1023
    80003eb0:	40ec87bb          	subw	a5,s9,a4
    80003eb4:	413a86bb          	subw	a3,s5,s3
    80003eb8:	8d3e                	mv	s10,a5
    80003eba:	2781                	sext.w	a5,a5
    80003ebc:	0006861b          	sext.w	a2,a3
    80003ec0:	f8f679e3          	bgeu	a2,a5,80003e52 <readi+0x4c>
    80003ec4:	8d36                	mv	s10,a3
    80003ec6:	b771                	j	80003e52 <readi+0x4c>
      brelse(bp);
    80003ec8:	854a                	mv	a0,s2
    80003eca:	fffff097          	auipc	ra,0xfffff
    80003ece:	5a0080e7          	jalr	1440(ra) # 8000346a <brelse>
      tot = -1;
    80003ed2:	59fd                	li	s3,-1
  }
  return tot;
    80003ed4:	0009851b          	sext.w	a0,s3
}
    80003ed8:	70a6                	ld	ra,104(sp)
    80003eda:	7406                	ld	s0,96(sp)
    80003edc:	64e6                	ld	s1,88(sp)
    80003ede:	6946                	ld	s2,80(sp)
    80003ee0:	69a6                	ld	s3,72(sp)
    80003ee2:	6a06                	ld	s4,64(sp)
    80003ee4:	7ae2                	ld	s5,56(sp)
    80003ee6:	7b42                	ld	s6,48(sp)
    80003ee8:	7ba2                	ld	s7,40(sp)
    80003eea:	7c02                	ld	s8,32(sp)
    80003eec:	6ce2                	ld	s9,24(sp)
    80003eee:	6d42                	ld	s10,16(sp)
    80003ef0:	6da2                	ld	s11,8(sp)
    80003ef2:	6165                	addi	sp,sp,112
    80003ef4:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80003ef6:	89d6                	mv	s3,s5
    80003ef8:	bff1                	j	80003ed4 <readi+0xce>
    return 0;
    80003efa:	4501                	li	a0,0
}
    80003efc:	8082                	ret

0000000080003efe <writei>:
int writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003efe:	457c                	lw	a5,76(a0)
    80003f00:	10d7e863          	bltu	a5,a3,80004010 <writei+0x112>
{
    80003f04:	7159                	addi	sp,sp,-112
    80003f06:	f486                	sd	ra,104(sp)
    80003f08:	f0a2                	sd	s0,96(sp)
    80003f0a:	eca6                	sd	s1,88(sp)
    80003f0c:	e8ca                	sd	s2,80(sp)
    80003f0e:	e4ce                	sd	s3,72(sp)
    80003f10:	e0d2                	sd	s4,64(sp)
    80003f12:	fc56                	sd	s5,56(sp)
    80003f14:	f85a                	sd	s6,48(sp)
    80003f16:	f45e                	sd	s7,40(sp)
    80003f18:	f062                	sd	s8,32(sp)
    80003f1a:	ec66                	sd	s9,24(sp)
    80003f1c:	e86a                	sd	s10,16(sp)
    80003f1e:	e46e                	sd	s11,8(sp)
    80003f20:	1880                	addi	s0,sp,112
    80003f22:	8aaa                	mv	s5,a0
    80003f24:	8bae                	mv	s7,a1
    80003f26:	8a32                	mv	s4,a2
    80003f28:	8936                	mv	s2,a3
    80003f2a:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003f2c:	00e687bb          	addw	a5,a3,a4
    80003f30:	0ed7e263          	bltu	a5,a3,80004014 <writei+0x116>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003f34:	00043737          	lui	a4,0x43
    80003f38:	0ef76063          	bltu	a4,a5,80004018 <writei+0x11a>
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003f3c:	0c0b0863          	beqz	s6,8000400c <writei+0x10e>
    80003f40:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003f42:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1)
    80003f46:	5c7d                	li	s8,-1
    80003f48:	a091                	j	80003f8c <writei+0x8e>
    80003f4a:	020d1d93          	slli	s11,s10,0x20
    80003f4e:	020ddd93          	srli	s11,s11,0x20
    80003f52:	05848513          	addi	a0,s1,88
    80003f56:	86ee                	mv	a3,s11
    80003f58:	8652                	mv	a2,s4
    80003f5a:	85de                	mv	a1,s7
    80003f5c:	953a                	add	a0,a0,a4
    80003f5e:	ffffe097          	auipc	ra,0xffffe
    80003f62:	786080e7          	jalr	1926(ra) # 800026e4 <either_copyin>
    80003f66:	07850263          	beq	a0,s8,80003fca <writei+0xcc>
    {
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f6a:	8526                	mv	a0,s1
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	788080e7          	jalr	1928(ra) # 800046f4 <log_write>
    brelse(bp);
    80003f74:	8526                	mv	a0,s1
    80003f76:	fffff097          	auipc	ra,0xfffff
    80003f7a:	4f4080e7          	jalr	1268(ra) # 8000346a <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80003f7e:	013d09bb          	addw	s3,s10,s3
    80003f82:	012d093b          	addw	s2,s10,s2
    80003f86:	9a6e                	add	s4,s4,s11
    80003f88:	0569f663          	bgeu	s3,s6,80003fd4 <writei+0xd6>
    uint addr = bmap(ip, off / BSIZE);
    80003f8c:	00a9559b          	srliw	a1,s2,0xa
    80003f90:	8556                	mv	a0,s5
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	79c080e7          	jalr	1948(ra) # 8000372e <bmap>
    80003f9a:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003f9e:	c99d                	beqz	a1,80003fd4 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003fa0:	000aa503          	lw	a0,0(s5)
    80003fa4:	fffff097          	auipc	ra,0xfffff
    80003fa8:	396080e7          	jalr	918(ra) # 8000333a <bread>
    80003fac:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003fae:	3ff97713          	andi	a4,s2,1023
    80003fb2:	40ec87bb          	subw	a5,s9,a4
    80003fb6:	413b06bb          	subw	a3,s6,s3
    80003fba:	8d3e                	mv	s10,a5
    80003fbc:	2781                	sext.w	a5,a5
    80003fbe:	0006861b          	sext.w	a2,a3
    80003fc2:	f8f674e3          	bgeu	a2,a5,80003f4a <writei+0x4c>
    80003fc6:	8d36                	mv	s10,a3
    80003fc8:	b749                	j	80003f4a <writei+0x4c>
      brelse(bp);
    80003fca:	8526                	mv	a0,s1
    80003fcc:	fffff097          	auipc	ra,0xfffff
    80003fd0:	49e080e7          	jalr	1182(ra) # 8000346a <brelse>
  }

  if (off > ip->size)
    80003fd4:	04caa783          	lw	a5,76(s5)
    80003fd8:	0127f463          	bgeu	a5,s2,80003fe0 <writei+0xe2>
    ip->size = off;
    80003fdc:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003fe0:	8556                	mv	a0,s5
    80003fe2:	00000097          	auipc	ra,0x0
    80003fe6:	aa4080e7          	jalr	-1372(ra) # 80003a86 <iupdate>

  return tot;
    80003fea:	0009851b          	sext.w	a0,s3
}
    80003fee:	70a6                	ld	ra,104(sp)
    80003ff0:	7406                	ld	s0,96(sp)
    80003ff2:	64e6                	ld	s1,88(sp)
    80003ff4:	6946                	ld	s2,80(sp)
    80003ff6:	69a6                	ld	s3,72(sp)
    80003ff8:	6a06                	ld	s4,64(sp)
    80003ffa:	7ae2                	ld	s5,56(sp)
    80003ffc:	7b42                	ld	s6,48(sp)
    80003ffe:	7ba2                	ld	s7,40(sp)
    80004000:	7c02                	ld	s8,32(sp)
    80004002:	6ce2                	ld	s9,24(sp)
    80004004:	6d42                	ld	s10,16(sp)
    80004006:	6da2                	ld	s11,8(sp)
    80004008:	6165                	addi	sp,sp,112
    8000400a:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    8000400c:	89da                	mv	s3,s6
    8000400e:	bfc9                	j	80003fe0 <writei+0xe2>
    return -1;
    80004010:	557d                	li	a0,-1
}
    80004012:	8082                	ret
    return -1;
    80004014:	557d                	li	a0,-1
    80004016:	bfe1                	j	80003fee <writei+0xf0>
    return -1;
    80004018:	557d                	li	a0,-1
    8000401a:	bfd1                	j	80003fee <writei+0xf0>

000000008000401c <namecmp>:

// Directories

int namecmp(const char *s, const char *t)
{
    8000401c:	1141                	addi	sp,sp,-16
    8000401e:	e406                	sd	ra,8(sp)
    80004020:	e022                	sd	s0,0(sp)
    80004022:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004024:	4639                	li	a2,14
    80004026:	ffffd097          	auipc	ra,0xffffd
    8000402a:	ef0080e7          	jalr	-272(ra) # 80000f16 <strncmp>
}
    8000402e:	60a2                	ld	ra,8(sp)
    80004030:	6402                	ld	s0,0(sp)
    80004032:	0141                	addi	sp,sp,16
    80004034:	8082                	ret

0000000080004036 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004036:	7139                	addi	sp,sp,-64
    80004038:	fc06                	sd	ra,56(sp)
    8000403a:	f822                	sd	s0,48(sp)
    8000403c:	f426                	sd	s1,40(sp)
    8000403e:	f04a                	sd	s2,32(sp)
    80004040:	ec4e                	sd	s3,24(sp)
    80004042:	e852                	sd	s4,16(sp)
    80004044:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80004046:	04451703          	lh	a4,68(a0)
    8000404a:	4785                	li	a5,1
    8000404c:	00f71a63          	bne	a4,a5,80004060 <dirlookup+0x2a>
    80004050:	892a                	mv	s2,a0
    80004052:	89ae                	mv	s3,a1
    80004054:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de))
    80004056:	457c                	lw	a5,76(a0)
    80004058:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000405a:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de))
    8000405c:	e79d                	bnez	a5,8000408a <dirlookup+0x54>
    8000405e:	a8a5                	j	800040d6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004060:	00004517          	auipc	a0,0x4
    80004064:	6b850513          	addi	a0,a0,1720 # 80008718 <syscalls+0x1b8>
    80004068:	ffffc097          	auipc	ra,0xffffc
    8000406c:	4d8080e7          	jalr	1240(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004070:	00004517          	auipc	a0,0x4
    80004074:	6c050513          	addi	a0,a0,1728 # 80008730 <syscalls+0x1d0>
    80004078:	ffffc097          	auipc	ra,0xffffc
    8000407c:	4c8080e7          	jalr	1224(ra) # 80000540 <panic>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004080:	24c1                	addiw	s1,s1,16
    80004082:	04c92783          	lw	a5,76(s2)
    80004086:	04f4f763          	bgeu	s1,a5,800040d4 <dirlookup+0x9e>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000408a:	4741                	li	a4,16
    8000408c:	86a6                	mv	a3,s1
    8000408e:	fc040613          	addi	a2,s0,-64
    80004092:	4581                	li	a1,0
    80004094:	854a                	mv	a0,s2
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	d70080e7          	jalr	-656(ra) # 80003e06 <readi>
    8000409e:	47c1                	li	a5,16
    800040a0:	fcf518e3          	bne	a0,a5,80004070 <dirlookup+0x3a>
    if (de.inum == 0)
    800040a4:	fc045783          	lhu	a5,-64(s0)
    800040a8:	dfe1                	beqz	a5,80004080 <dirlookup+0x4a>
    if (namecmp(name, de.name) == 0)
    800040aa:	fc240593          	addi	a1,s0,-62
    800040ae:	854e                	mv	a0,s3
    800040b0:	00000097          	auipc	ra,0x0
    800040b4:	f6c080e7          	jalr	-148(ra) # 8000401c <namecmp>
    800040b8:	f561                	bnez	a0,80004080 <dirlookup+0x4a>
      if (poff)
    800040ba:	000a0463          	beqz	s4,800040c2 <dirlookup+0x8c>
        *poff = off;
    800040be:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800040c2:	fc045583          	lhu	a1,-64(s0)
    800040c6:	00092503          	lw	a0,0(s2)
    800040ca:	fffff097          	auipc	ra,0xfffff
    800040ce:	74e080e7          	jalr	1870(ra) # 80003818 <iget>
    800040d2:	a011                	j	800040d6 <dirlookup+0xa0>
  return 0;
    800040d4:	4501                	li	a0,0
}
    800040d6:	70e2                	ld	ra,56(sp)
    800040d8:	7442                	ld	s0,48(sp)
    800040da:	74a2                	ld	s1,40(sp)
    800040dc:	7902                	ld	s2,32(sp)
    800040de:	69e2                	ld	s3,24(sp)
    800040e0:	6a42                	ld	s4,16(sp)
    800040e2:	6121                	addi	sp,sp,64
    800040e4:	8082                	ret

00000000800040e6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    800040e6:	711d                	addi	sp,sp,-96
    800040e8:	ec86                	sd	ra,88(sp)
    800040ea:	e8a2                	sd	s0,80(sp)
    800040ec:	e4a6                	sd	s1,72(sp)
    800040ee:	e0ca                	sd	s2,64(sp)
    800040f0:	fc4e                	sd	s3,56(sp)
    800040f2:	f852                	sd	s4,48(sp)
    800040f4:	f456                	sd	s5,40(sp)
    800040f6:	f05a                	sd	s6,32(sp)
    800040f8:	ec5e                	sd	s7,24(sp)
    800040fa:	e862                	sd	s8,16(sp)
    800040fc:	e466                	sd	s9,8(sp)
    800040fe:	e06a                	sd	s10,0(sp)
    80004100:	1080                	addi	s0,sp,96
    80004102:	84aa                	mv	s1,a0
    80004104:	8b2e                	mv	s6,a1
    80004106:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80004108:	00054703          	lbu	a4,0(a0)
    8000410c:	02f00793          	li	a5,47
    80004110:	02f70363          	beq	a4,a5,80004136 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004114:	ffffe097          	auipc	ra,0xffffe
    80004118:	a0c080e7          	jalr	-1524(ra) # 80001b20 <myproc>
    8000411c:	15053503          	ld	a0,336(a0)
    80004120:	00000097          	auipc	ra,0x0
    80004124:	9f4080e7          	jalr	-1548(ra) # 80003b14 <idup>
    80004128:	8a2a                	mv	s4,a0
  while (*path == '/')
    8000412a:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    8000412e:	4cb5                	li	s9,13
  len = path - s;
    80004130:	4b81                	li	s7,0

  while ((path = skipelem(path, name)) != 0)
  {
    ilock(ip);
    if (ip->type != T_DIR)
    80004132:	4c05                	li	s8,1
    80004134:	a87d                	j	800041f2 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004136:	4585                	li	a1,1
    80004138:	4505                	li	a0,1
    8000413a:	fffff097          	auipc	ra,0xfffff
    8000413e:	6de080e7          	jalr	1758(ra) # 80003818 <iget>
    80004142:	8a2a                	mv	s4,a0
    80004144:	b7dd                	j	8000412a <namex+0x44>
    {
      iunlockput(ip);
    80004146:	8552                	mv	a0,s4
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	c6c080e7          	jalr	-916(ra) # 80003db4 <iunlockput>
      return 0;
    80004150:	4a01                	li	s4,0
  {
    iput(ip);
    return 0;
  }
  return ip;
}
    80004152:	8552                	mv	a0,s4
    80004154:	60e6                	ld	ra,88(sp)
    80004156:	6446                	ld	s0,80(sp)
    80004158:	64a6                	ld	s1,72(sp)
    8000415a:	6906                	ld	s2,64(sp)
    8000415c:	79e2                	ld	s3,56(sp)
    8000415e:	7a42                	ld	s4,48(sp)
    80004160:	7aa2                	ld	s5,40(sp)
    80004162:	7b02                	ld	s6,32(sp)
    80004164:	6be2                	ld	s7,24(sp)
    80004166:	6c42                	ld	s8,16(sp)
    80004168:	6ca2                	ld	s9,8(sp)
    8000416a:	6d02                	ld	s10,0(sp)
    8000416c:	6125                	addi	sp,sp,96
    8000416e:	8082                	ret
      iunlock(ip);
    80004170:	8552                	mv	a0,s4
    80004172:	00000097          	auipc	ra,0x0
    80004176:	aa2080e7          	jalr	-1374(ra) # 80003c14 <iunlock>
      return ip;
    8000417a:	bfe1                	j	80004152 <namex+0x6c>
      iunlockput(ip);
    8000417c:	8552                	mv	a0,s4
    8000417e:	00000097          	auipc	ra,0x0
    80004182:	c36080e7          	jalr	-970(ra) # 80003db4 <iunlockput>
      return 0;
    80004186:	8a4e                	mv	s4,s3
    80004188:	b7e9                	j	80004152 <namex+0x6c>
  len = path - s;
    8000418a:	40998633          	sub	a2,s3,s1
    8000418e:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80004192:	09acd863          	bge	s9,s10,80004222 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004196:	4639                	li	a2,14
    80004198:	85a6                	mv	a1,s1
    8000419a:	8556                	mv	a0,s5
    8000419c:	ffffd097          	auipc	ra,0xffffd
    800041a0:	d06080e7          	jalr	-762(ra) # 80000ea2 <memmove>
    800041a4:	84ce                	mv	s1,s3
  while (*path == '/')
    800041a6:	0004c783          	lbu	a5,0(s1)
    800041aa:	01279763          	bne	a5,s2,800041b8 <namex+0xd2>
    path++;
    800041ae:	0485                	addi	s1,s1,1
  while (*path == '/')
    800041b0:	0004c783          	lbu	a5,0(s1)
    800041b4:	ff278de3          	beq	a5,s2,800041ae <namex+0xc8>
    ilock(ip);
    800041b8:	8552                	mv	a0,s4
    800041ba:	00000097          	auipc	ra,0x0
    800041be:	998080e7          	jalr	-1640(ra) # 80003b52 <ilock>
    if (ip->type != T_DIR)
    800041c2:	044a1783          	lh	a5,68(s4)
    800041c6:	f98790e3          	bne	a5,s8,80004146 <namex+0x60>
    if (nameiparent && *path == '\0')
    800041ca:	000b0563          	beqz	s6,800041d4 <namex+0xee>
    800041ce:	0004c783          	lbu	a5,0(s1)
    800041d2:	dfd9                	beqz	a5,80004170 <namex+0x8a>
    if ((next = dirlookup(ip, name, 0)) == 0)
    800041d4:	865e                	mv	a2,s7
    800041d6:	85d6                	mv	a1,s5
    800041d8:	8552                	mv	a0,s4
    800041da:	00000097          	auipc	ra,0x0
    800041de:	e5c080e7          	jalr	-420(ra) # 80004036 <dirlookup>
    800041e2:	89aa                	mv	s3,a0
    800041e4:	dd41                	beqz	a0,8000417c <namex+0x96>
    iunlockput(ip);
    800041e6:	8552                	mv	a0,s4
    800041e8:	00000097          	auipc	ra,0x0
    800041ec:	bcc080e7          	jalr	-1076(ra) # 80003db4 <iunlockput>
    ip = next;
    800041f0:	8a4e                	mv	s4,s3
  while (*path == '/')
    800041f2:	0004c783          	lbu	a5,0(s1)
    800041f6:	01279763          	bne	a5,s2,80004204 <namex+0x11e>
    path++;
    800041fa:	0485                	addi	s1,s1,1
  while (*path == '/')
    800041fc:	0004c783          	lbu	a5,0(s1)
    80004200:	ff278de3          	beq	a5,s2,800041fa <namex+0x114>
  if (*path == 0)
    80004204:	cb9d                	beqz	a5,8000423a <namex+0x154>
  while (*path != '/' && *path != 0)
    80004206:	0004c783          	lbu	a5,0(s1)
    8000420a:	89a6                	mv	s3,s1
  len = path - s;
    8000420c:	8d5e                	mv	s10,s7
    8000420e:	865e                	mv	a2,s7
  while (*path != '/' && *path != 0)
    80004210:	01278963          	beq	a5,s2,80004222 <namex+0x13c>
    80004214:	dbbd                	beqz	a5,8000418a <namex+0xa4>
    path++;
    80004216:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80004218:	0009c783          	lbu	a5,0(s3)
    8000421c:	ff279ce3          	bne	a5,s2,80004214 <namex+0x12e>
    80004220:	b7ad                	j	8000418a <namex+0xa4>
    memmove(name, s, len);
    80004222:	2601                	sext.w	a2,a2
    80004224:	85a6                	mv	a1,s1
    80004226:	8556                	mv	a0,s5
    80004228:	ffffd097          	auipc	ra,0xffffd
    8000422c:	c7a080e7          	jalr	-902(ra) # 80000ea2 <memmove>
    name[len] = 0;
    80004230:	9d56                	add	s10,s10,s5
    80004232:	000d0023          	sb	zero,0(s10)
    80004236:	84ce                	mv	s1,s3
    80004238:	b7bd                	j	800041a6 <namex+0xc0>
  if (nameiparent)
    8000423a:	f00b0ce3          	beqz	s6,80004152 <namex+0x6c>
    iput(ip);
    8000423e:	8552                	mv	a0,s4
    80004240:	00000097          	auipc	ra,0x0
    80004244:	acc080e7          	jalr	-1332(ra) # 80003d0c <iput>
    return 0;
    80004248:	4a01                	li	s4,0
    8000424a:	b721                	j	80004152 <namex+0x6c>

000000008000424c <dirlink>:
{
    8000424c:	7139                	addi	sp,sp,-64
    8000424e:	fc06                	sd	ra,56(sp)
    80004250:	f822                	sd	s0,48(sp)
    80004252:	f426                	sd	s1,40(sp)
    80004254:	f04a                	sd	s2,32(sp)
    80004256:	ec4e                	sd	s3,24(sp)
    80004258:	e852                	sd	s4,16(sp)
    8000425a:	0080                	addi	s0,sp,64
    8000425c:	892a                	mv	s2,a0
    8000425e:	8a2e                	mv	s4,a1
    80004260:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0)
    80004262:	4601                	li	a2,0
    80004264:	00000097          	auipc	ra,0x0
    80004268:	dd2080e7          	jalr	-558(ra) # 80004036 <dirlookup>
    8000426c:	e93d                	bnez	a0,800042e2 <dirlink+0x96>
  for (off = 0; off < dp->size; off += sizeof(de))
    8000426e:	04c92483          	lw	s1,76(s2)
    80004272:	c49d                	beqz	s1,800042a0 <dirlink+0x54>
    80004274:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004276:	4741                	li	a4,16
    80004278:	86a6                	mv	a3,s1
    8000427a:	fc040613          	addi	a2,s0,-64
    8000427e:	4581                	li	a1,0
    80004280:	854a                	mv	a0,s2
    80004282:	00000097          	auipc	ra,0x0
    80004286:	b84080e7          	jalr	-1148(ra) # 80003e06 <readi>
    8000428a:	47c1                	li	a5,16
    8000428c:	06f51163          	bne	a0,a5,800042ee <dirlink+0xa2>
    if (de.inum == 0)
    80004290:	fc045783          	lhu	a5,-64(s0)
    80004294:	c791                	beqz	a5,800042a0 <dirlink+0x54>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004296:	24c1                	addiw	s1,s1,16
    80004298:	04c92783          	lw	a5,76(s2)
    8000429c:	fcf4ede3          	bltu	s1,a5,80004276 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042a0:	4639                	li	a2,14
    800042a2:	85d2                	mv	a1,s4
    800042a4:	fc240513          	addi	a0,s0,-62
    800042a8:	ffffd097          	auipc	ra,0xffffd
    800042ac:	caa080e7          	jalr	-854(ra) # 80000f52 <strncpy>
  de.inum = inum;
    800042b0:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042b4:	4741                	li	a4,16
    800042b6:	86a6                	mv	a3,s1
    800042b8:	fc040613          	addi	a2,s0,-64
    800042bc:	4581                	li	a1,0
    800042be:	854a                	mv	a0,s2
    800042c0:	00000097          	auipc	ra,0x0
    800042c4:	c3e080e7          	jalr	-962(ra) # 80003efe <writei>
    800042c8:	1541                	addi	a0,a0,-16
    800042ca:	00a03533          	snez	a0,a0
    800042ce:	40a00533          	neg	a0,a0
}
    800042d2:	70e2                	ld	ra,56(sp)
    800042d4:	7442                	ld	s0,48(sp)
    800042d6:	74a2                	ld	s1,40(sp)
    800042d8:	7902                	ld	s2,32(sp)
    800042da:	69e2                	ld	s3,24(sp)
    800042dc:	6a42                	ld	s4,16(sp)
    800042de:	6121                	addi	sp,sp,64
    800042e0:	8082                	ret
    iput(ip);
    800042e2:	00000097          	auipc	ra,0x0
    800042e6:	a2a080e7          	jalr	-1494(ra) # 80003d0c <iput>
    return -1;
    800042ea:	557d                	li	a0,-1
    800042ec:	b7dd                	j	800042d2 <dirlink+0x86>
      panic("dirlink read");
    800042ee:	00004517          	auipc	a0,0x4
    800042f2:	45250513          	addi	a0,a0,1106 # 80008740 <syscalls+0x1e0>
    800042f6:	ffffc097          	auipc	ra,0xffffc
    800042fa:	24a080e7          	jalr	586(ra) # 80000540 <panic>

00000000800042fe <namei>:

struct inode *
namei(char *path)
{
    800042fe:	1101                	addi	sp,sp,-32
    80004300:	ec06                	sd	ra,24(sp)
    80004302:	e822                	sd	s0,16(sp)
    80004304:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004306:	fe040613          	addi	a2,s0,-32
    8000430a:	4581                	li	a1,0
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	dda080e7          	jalr	-550(ra) # 800040e6 <namex>
}
    80004314:	60e2                	ld	ra,24(sp)
    80004316:	6442                	ld	s0,16(sp)
    80004318:	6105                	addi	sp,sp,32
    8000431a:	8082                	ret

000000008000431c <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    8000431c:	1141                	addi	sp,sp,-16
    8000431e:	e406                	sd	ra,8(sp)
    80004320:	e022                	sd	s0,0(sp)
    80004322:	0800                	addi	s0,sp,16
    80004324:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004326:	4585                	li	a1,1
    80004328:	00000097          	auipc	ra,0x0
    8000432c:	dbe080e7          	jalr	-578(ra) # 800040e6 <namex>
}
    80004330:	60a2                	ld	ra,8(sp)
    80004332:	6402                	ld	s0,0(sp)
    80004334:	0141                	addi	sp,sp,16
    80004336:	8082                	ret

0000000080004338 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004338:	1101                	addi	sp,sp,-32
    8000433a:	ec06                	sd	ra,24(sp)
    8000433c:	e822                	sd	s0,16(sp)
    8000433e:	e426                	sd	s1,8(sp)
    80004340:	e04a                	sd	s2,0(sp)
    80004342:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004344:	0023f917          	auipc	s2,0x23f
    80004348:	a1c90913          	addi	s2,s2,-1508 # 80242d60 <log>
    8000434c:	01892583          	lw	a1,24(s2)
    80004350:	02892503          	lw	a0,40(s2)
    80004354:	fffff097          	auipc	ra,0xfffff
    80004358:	fe6080e7          	jalr	-26(ra) # 8000333a <bread>
    8000435c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    8000435e:	02c92683          	lw	a3,44(s2)
    80004362:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++)
    80004364:	02d05863          	blez	a3,80004394 <write_head+0x5c>
    80004368:	0023f797          	auipc	a5,0x23f
    8000436c:	a2878793          	addi	a5,a5,-1496 # 80242d90 <log+0x30>
    80004370:	05c50713          	addi	a4,a0,92
    80004374:	36fd                	addiw	a3,a3,-1
    80004376:	02069613          	slli	a2,a3,0x20
    8000437a:	01e65693          	srli	a3,a2,0x1e
    8000437e:	0023f617          	auipc	a2,0x23f
    80004382:	a1660613          	addi	a2,a2,-1514 # 80242d94 <log+0x34>
    80004386:	96b2                	add	a3,a3,a2
  {
    hb->block[i] = log.lh.block[i];
    80004388:	4390                	lw	a2,0(a5)
    8000438a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    8000438c:	0791                	addi	a5,a5,4
    8000438e:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004390:	fed79ce3          	bne	a5,a3,80004388 <write_head+0x50>
  }
  bwrite(buf);
    80004394:	8526                	mv	a0,s1
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	096080e7          	jalr	150(ra) # 8000342c <bwrite>
  brelse(buf);
    8000439e:	8526                	mv	a0,s1
    800043a0:	fffff097          	auipc	ra,0xfffff
    800043a4:	0ca080e7          	jalr	202(ra) # 8000346a <brelse>
}
    800043a8:	60e2                	ld	ra,24(sp)
    800043aa:	6442                	ld	s0,16(sp)
    800043ac:	64a2                	ld	s1,8(sp)
    800043ae:	6902                	ld	s2,0(sp)
    800043b0:	6105                	addi	sp,sp,32
    800043b2:	8082                	ret

00000000800043b4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++)
    800043b4:	0023f797          	auipc	a5,0x23f
    800043b8:	9d87a783          	lw	a5,-1576(a5) # 80242d8c <log+0x2c>
    800043bc:	0af05d63          	blez	a5,80004476 <install_trans+0xc2>
{
    800043c0:	7139                	addi	sp,sp,-64
    800043c2:	fc06                	sd	ra,56(sp)
    800043c4:	f822                	sd	s0,48(sp)
    800043c6:	f426                	sd	s1,40(sp)
    800043c8:	f04a                	sd	s2,32(sp)
    800043ca:	ec4e                	sd	s3,24(sp)
    800043cc:	e852                	sd	s4,16(sp)
    800043ce:	e456                	sd	s5,8(sp)
    800043d0:	e05a                	sd	s6,0(sp)
    800043d2:	0080                	addi	s0,sp,64
    800043d4:	8b2a                	mv	s6,a0
    800043d6:	0023fa97          	auipc	s5,0x23f
    800043da:	9baa8a93          	addi	s5,s5,-1606 # 80242d90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++)
    800043de:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    800043e0:	0023f997          	auipc	s3,0x23f
    800043e4:	98098993          	addi	s3,s3,-1664 # 80242d60 <log>
    800043e8:	a00d                	j	8000440a <install_trans+0x56>
    brelse(lbuf);
    800043ea:	854a                	mv	a0,s2
    800043ec:	fffff097          	auipc	ra,0xfffff
    800043f0:	07e080e7          	jalr	126(ra) # 8000346a <brelse>
    brelse(dbuf);
    800043f4:	8526                	mv	a0,s1
    800043f6:	fffff097          	auipc	ra,0xfffff
    800043fa:	074080e7          	jalr	116(ra) # 8000346a <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    800043fe:	2a05                	addiw	s4,s4,1
    80004400:	0a91                	addi	s5,s5,4
    80004402:	02c9a783          	lw	a5,44(s3)
    80004406:	04fa5e63          	bge	s4,a5,80004462 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    8000440a:	0189a583          	lw	a1,24(s3)
    8000440e:	014585bb          	addw	a1,a1,s4
    80004412:	2585                	addiw	a1,a1,1
    80004414:	0289a503          	lw	a0,40(s3)
    80004418:	fffff097          	auipc	ra,0xfffff
    8000441c:	f22080e7          	jalr	-222(ra) # 8000333a <bread>
    80004420:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80004422:	000aa583          	lw	a1,0(s5)
    80004426:	0289a503          	lw	a0,40(s3)
    8000442a:	fffff097          	auipc	ra,0xfffff
    8000442e:	f10080e7          	jalr	-240(ra) # 8000333a <bread>
    80004432:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);                  // copy block to dst
    80004434:	40000613          	li	a2,1024
    80004438:	05890593          	addi	a1,s2,88
    8000443c:	05850513          	addi	a0,a0,88
    80004440:	ffffd097          	auipc	ra,0xffffd
    80004444:	a62080e7          	jalr	-1438(ra) # 80000ea2 <memmove>
    bwrite(dbuf);                                            // write dst to disk
    80004448:	8526                	mv	a0,s1
    8000444a:	fffff097          	auipc	ra,0xfffff
    8000444e:	fe2080e7          	jalr	-30(ra) # 8000342c <bwrite>
    if (recovering == 0)
    80004452:	f80b1ce3          	bnez	s6,800043ea <install_trans+0x36>
      bunpin(dbuf);
    80004456:	8526                	mv	a0,s1
    80004458:	fffff097          	auipc	ra,0xfffff
    8000445c:	0ec080e7          	jalr	236(ra) # 80003544 <bunpin>
    80004460:	b769                	j	800043ea <install_trans+0x36>
}
    80004462:	70e2                	ld	ra,56(sp)
    80004464:	7442                	ld	s0,48(sp)
    80004466:	74a2                	ld	s1,40(sp)
    80004468:	7902                	ld	s2,32(sp)
    8000446a:	69e2                	ld	s3,24(sp)
    8000446c:	6a42                	ld	s4,16(sp)
    8000446e:	6aa2                	ld	s5,8(sp)
    80004470:	6b02                	ld	s6,0(sp)
    80004472:	6121                	addi	sp,sp,64
    80004474:	8082                	ret
    80004476:	8082                	ret

0000000080004478 <initlog>:
{
    80004478:	7179                	addi	sp,sp,-48
    8000447a:	f406                	sd	ra,40(sp)
    8000447c:	f022                	sd	s0,32(sp)
    8000447e:	ec26                	sd	s1,24(sp)
    80004480:	e84a                	sd	s2,16(sp)
    80004482:	e44e                	sd	s3,8(sp)
    80004484:	1800                	addi	s0,sp,48
    80004486:	892a                	mv	s2,a0
    80004488:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000448a:	0023f497          	auipc	s1,0x23f
    8000448e:	8d648493          	addi	s1,s1,-1834 # 80242d60 <log>
    80004492:	00004597          	auipc	a1,0x4
    80004496:	2be58593          	addi	a1,a1,702 # 80008750 <syscalls+0x1f0>
    8000449a:	8526                	mv	a0,s1
    8000449c:	ffffd097          	auipc	ra,0xffffd
    800044a0:	81e080e7          	jalr	-2018(ra) # 80000cba <initlock>
  log.start = sb->logstart;
    800044a4:	0149a583          	lw	a1,20(s3)
    800044a8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800044aa:	0109a783          	lw	a5,16(s3)
    800044ae:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800044b0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044b4:	854a                	mv	a0,s2
    800044b6:	fffff097          	auipc	ra,0xfffff
    800044ba:	e84080e7          	jalr	-380(ra) # 8000333a <bread>
  log.lh.n = lh->n;
    800044be:	4d34                	lw	a3,88(a0)
    800044c0:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++)
    800044c2:	02d05663          	blez	a3,800044ee <initlog+0x76>
    800044c6:	05c50793          	addi	a5,a0,92
    800044ca:	0023f717          	auipc	a4,0x23f
    800044ce:	8c670713          	addi	a4,a4,-1850 # 80242d90 <log+0x30>
    800044d2:	36fd                	addiw	a3,a3,-1
    800044d4:	02069613          	slli	a2,a3,0x20
    800044d8:	01e65693          	srli	a3,a2,0x1e
    800044dc:	06050613          	addi	a2,a0,96
    800044e0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800044e2:	4390                	lw	a2,0(a5)
    800044e4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    800044e6:	0791                	addi	a5,a5,4
    800044e8:	0711                	addi	a4,a4,4
    800044ea:	fed79ce3          	bne	a5,a3,800044e2 <initlog+0x6a>
  brelse(buf);
    800044ee:	fffff097          	auipc	ra,0xfffff
    800044f2:	f7c080e7          	jalr	-132(ra) # 8000346a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800044f6:	4505                	li	a0,1
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	ebc080e7          	jalr	-324(ra) # 800043b4 <install_trans>
  log.lh.n = 0;
    80004500:	0023f797          	auipc	a5,0x23f
    80004504:	8807a623          	sw	zero,-1908(a5) # 80242d8c <log+0x2c>
  write_head(); // clear the log
    80004508:	00000097          	auipc	ra,0x0
    8000450c:	e30080e7          	jalr	-464(ra) # 80004338 <write_head>
}
    80004510:	70a2                	ld	ra,40(sp)
    80004512:	7402                	ld	s0,32(sp)
    80004514:	64e2                	ld	s1,24(sp)
    80004516:	6942                	ld	s2,16(sp)
    80004518:	69a2                	ld	s3,8(sp)
    8000451a:	6145                	addi	sp,sp,48
    8000451c:	8082                	ret

000000008000451e <begin_op>:
}

// called at the start of each FS system call.
void begin_op(void)
{
    8000451e:	1101                	addi	sp,sp,-32
    80004520:	ec06                	sd	ra,24(sp)
    80004522:	e822                	sd	s0,16(sp)
    80004524:	e426                	sd	s1,8(sp)
    80004526:	e04a                	sd	s2,0(sp)
    80004528:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000452a:	0023f517          	auipc	a0,0x23f
    8000452e:	83650513          	addi	a0,a0,-1994 # 80242d60 <log>
    80004532:	ffffd097          	auipc	ra,0xffffd
    80004536:	818080e7          	jalr	-2024(ra) # 80000d4a <acquire>
  while (1)
  {
    if (log.committing)
    8000453a:	0023f497          	auipc	s1,0x23f
    8000453e:	82648493          	addi	s1,s1,-2010 # 80242d60 <log>
    {
      sleep(&log, &log.lock);
    }
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    80004542:	4979                	li	s2,30
    80004544:	a039                	j	80004552 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004546:	85a6                	mv	a1,s1
    80004548:	8526                	mv	a0,s1
    8000454a:	ffffe097          	auipc	ra,0xffffe
    8000454e:	d04080e7          	jalr	-764(ra) # 8000224e <sleep>
    if (log.committing)
    80004552:	50dc                	lw	a5,36(s1)
    80004554:	fbed                	bnez	a5,80004546 <begin_op+0x28>
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    80004556:	5098                	lw	a4,32(s1)
    80004558:	2705                	addiw	a4,a4,1
    8000455a:	0007069b          	sext.w	a3,a4
    8000455e:	0027179b          	slliw	a5,a4,0x2
    80004562:	9fb9                	addw	a5,a5,a4
    80004564:	0017979b          	slliw	a5,a5,0x1
    80004568:	54d8                	lw	a4,44(s1)
    8000456a:	9fb9                	addw	a5,a5,a4
    8000456c:	00f95963          	bge	s2,a5,8000457e <begin_op+0x60>
    {
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004570:	85a6                	mv	a1,s1
    80004572:	8526                	mv	a0,s1
    80004574:	ffffe097          	auipc	ra,0xffffe
    80004578:	cda080e7          	jalr	-806(ra) # 8000224e <sleep>
    8000457c:	bfd9                	j	80004552 <begin_op+0x34>
    }
    else
    {
      log.outstanding += 1;
    8000457e:	0023e517          	auipc	a0,0x23e
    80004582:	7e250513          	addi	a0,a0,2018 # 80242d60 <log>
    80004586:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004588:	ffffd097          	auipc	ra,0xffffd
    8000458c:	876080e7          	jalr	-1930(ra) # 80000dfe <release>
      break;
    }
  }
}
    80004590:	60e2                	ld	ra,24(sp)
    80004592:	6442                	ld	s0,16(sp)
    80004594:	64a2                	ld	s1,8(sp)
    80004596:	6902                	ld	s2,0(sp)
    80004598:	6105                	addi	sp,sp,32
    8000459a:	8082                	ret

000000008000459c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
    8000459c:	7139                	addi	sp,sp,-64
    8000459e:	fc06                	sd	ra,56(sp)
    800045a0:	f822                	sd	s0,48(sp)
    800045a2:	f426                	sd	s1,40(sp)
    800045a4:	f04a                	sd	s2,32(sp)
    800045a6:	ec4e                	sd	s3,24(sp)
    800045a8:	e852                	sd	s4,16(sp)
    800045aa:	e456                	sd	s5,8(sp)
    800045ac:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045ae:	0023e497          	auipc	s1,0x23e
    800045b2:	7b248493          	addi	s1,s1,1970 # 80242d60 <log>
    800045b6:	8526                	mv	a0,s1
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	792080e7          	jalr	1938(ra) # 80000d4a <acquire>
  log.outstanding -= 1;
    800045c0:	509c                	lw	a5,32(s1)
    800045c2:	37fd                	addiw	a5,a5,-1
    800045c4:	0007891b          	sext.w	s2,a5
    800045c8:	d09c                	sw	a5,32(s1)
  if (log.committing)
    800045ca:	50dc                	lw	a5,36(s1)
    800045cc:	e7b9                	bnez	a5,8000461a <end_op+0x7e>
    panic("log.committing");
  if (log.outstanding == 0)
    800045ce:	04091e63          	bnez	s2,8000462a <end_op+0x8e>
  {
    do_commit = 1;
    log.committing = 1;
    800045d2:	0023e497          	auipc	s1,0x23e
    800045d6:	78e48493          	addi	s1,s1,1934 # 80242d60 <log>
    800045da:	4785                	li	a5,1
    800045dc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045de:	8526                	mv	a0,s1
    800045e0:	ffffd097          	auipc	ra,0xffffd
    800045e4:	81e080e7          	jalr	-2018(ra) # 80000dfe <release>
}

static void
commit()
{
  if (log.lh.n > 0)
    800045e8:	54dc                	lw	a5,44(s1)
    800045ea:	06f04763          	bgtz	a5,80004658 <end_op+0xbc>
    acquire(&log.lock);
    800045ee:	0023e497          	auipc	s1,0x23e
    800045f2:	77248493          	addi	s1,s1,1906 # 80242d60 <log>
    800045f6:	8526                	mv	a0,s1
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	752080e7          	jalr	1874(ra) # 80000d4a <acquire>
    log.committing = 0;
    80004600:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004604:	8526                	mv	a0,s1
    80004606:	ffffe097          	auipc	ra,0xffffe
    8000460a:	cb8080e7          	jalr	-840(ra) # 800022be <wakeup>
    release(&log.lock);
    8000460e:	8526                	mv	a0,s1
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	7ee080e7          	jalr	2030(ra) # 80000dfe <release>
}
    80004618:	a03d                	j	80004646 <end_op+0xaa>
    panic("log.committing");
    8000461a:	00004517          	auipc	a0,0x4
    8000461e:	13e50513          	addi	a0,a0,318 # 80008758 <syscalls+0x1f8>
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	f1e080e7          	jalr	-226(ra) # 80000540 <panic>
    wakeup(&log);
    8000462a:	0023e497          	auipc	s1,0x23e
    8000462e:	73648493          	addi	s1,s1,1846 # 80242d60 <log>
    80004632:	8526                	mv	a0,s1
    80004634:	ffffe097          	auipc	ra,0xffffe
    80004638:	c8a080e7          	jalr	-886(ra) # 800022be <wakeup>
  release(&log.lock);
    8000463c:	8526                	mv	a0,s1
    8000463e:	ffffc097          	auipc	ra,0xffffc
    80004642:	7c0080e7          	jalr	1984(ra) # 80000dfe <release>
}
    80004646:	70e2                	ld	ra,56(sp)
    80004648:	7442                	ld	s0,48(sp)
    8000464a:	74a2                	ld	s1,40(sp)
    8000464c:	7902                	ld	s2,32(sp)
    8000464e:	69e2                	ld	s3,24(sp)
    80004650:	6a42                	ld	s4,16(sp)
    80004652:	6aa2                	ld	s5,8(sp)
    80004654:	6121                	addi	sp,sp,64
    80004656:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++)
    80004658:	0023ea97          	auipc	s5,0x23e
    8000465c:	738a8a93          	addi	s5,s5,1848 # 80242d90 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80004660:	0023ea17          	auipc	s4,0x23e
    80004664:	700a0a13          	addi	s4,s4,1792 # 80242d60 <log>
    80004668:	018a2583          	lw	a1,24(s4)
    8000466c:	012585bb          	addw	a1,a1,s2
    80004670:	2585                	addiw	a1,a1,1
    80004672:	028a2503          	lw	a0,40(s4)
    80004676:	fffff097          	auipc	ra,0xfffff
    8000467a:	cc4080e7          	jalr	-828(ra) # 8000333a <bread>
    8000467e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004680:	000aa583          	lw	a1,0(s5)
    80004684:	028a2503          	lw	a0,40(s4)
    80004688:	fffff097          	auipc	ra,0xfffff
    8000468c:	cb2080e7          	jalr	-846(ra) # 8000333a <bread>
    80004690:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004692:	40000613          	li	a2,1024
    80004696:	05850593          	addi	a1,a0,88
    8000469a:	05848513          	addi	a0,s1,88
    8000469e:	ffffd097          	auipc	ra,0xffffd
    800046a2:	804080e7          	jalr	-2044(ra) # 80000ea2 <memmove>
    bwrite(to); // write the log
    800046a6:	8526                	mv	a0,s1
    800046a8:	fffff097          	auipc	ra,0xfffff
    800046ac:	d84080e7          	jalr	-636(ra) # 8000342c <bwrite>
    brelse(from);
    800046b0:	854e                	mv	a0,s3
    800046b2:	fffff097          	auipc	ra,0xfffff
    800046b6:	db8080e7          	jalr	-584(ra) # 8000346a <brelse>
    brelse(to);
    800046ba:	8526                	mv	a0,s1
    800046bc:	fffff097          	auipc	ra,0xfffff
    800046c0:	dae080e7          	jalr	-594(ra) # 8000346a <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    800046c4:	2905                	addiw	s2,s2,1
    800046c6:	0a91                	addi	s5,s5,4
    800046c8:	02ca2783          	lw	a5,44(s4)
    800046cc:	f8f94ee3          	blt	s2,a5,80004668 <end_op+0xcc>
  {
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    800046d0:	00000097          	auipc	ra,0x0
    800046d4:	c68080e7          	jalr	-920(ra) # 80004338 <write_head>
    install_trans(0); // Now install writes to home locations
    800046d8:	4501                	li	a0,0
    800046da:	00000097          	auipc	ra,0x0
    800046de:	cda080e7          	jalr	-806(ra) # 800043b4 <install_trans>
    log.lh.n = 0;
    800046e2:	0023e797          	auipc	a5,0x23e
    800046e6:	6a07a523          	sw	zero,1706(a5) # 80242d8c <log+0x2c>
    write_head(); // Erase the transaction from the log
    800046ea:	00000097          	auipc	ra,0x0
    800046ee:	c4e080e7          	jalr	-946(ra) # 80004338 <write_head>
    800046f2:	bdf5                	j	800045ee <end_op+0x52>

00000000800046f4 <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
    800046f4:	1101                	addi	sp,sp,-32
    800046f6:	ec06                	sd	ra,24(sp)
    800046f8:	e822                	sd	s0,16(sp)
    800046fa:	e426                	sd	s1,8(sp)
    800046fc:	e04a                	sd	s2,0(sp)
    800046fe:	1000                	addi	s0,sp,32
    80004700:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004702:	0023e917          	auipc	s2,0x23e
    80004706:	65e90913          	addi	s2,s2,1630 # 80242d60 <log>
    8000470a:	854a                	mv	a0,s2
    8000470c:	ffffc097          	auipc	ra,0xffffc
    80004710:	63e080e7          	jalr	1598(ra) # 80000d4a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004714:	02c92603          	lw	a2,44(s2)
    80004718:	47f5                	li	a5,29
    8000471a:	06c7c563          	blt	a5,a2,80004784 <log_write+0x90>
    8000471e:	0023e797          	auipc	a5,0x23e
    80004722:	65e7a783          	lw	a5,1630(a5) # 80242d7c <log+0x1c>
    80004726:	37fd                	addiw	a5,a5,-1
    80004728:	04f65e63          	bge	a2,a5,80004784 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000472c:	0023e797          	auipc	a5,0x23e
    80004730:	6547a783          	lw	a5,1620(a5) # 80242d80 <log+0x20>
    80004734:	06f05063          	blez	a5,80004794 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++)
    80004738:	4781                	li	a5,0
    8000473a:	06c05563          	blez	a2,800047a4 <log_write+0xb0>
  {
    if (log.lh.block[i] == b->blockno) // log absorption
    8000473e:	44cc                	lw	a1,12(s1)
    80004740:	0023e717          	auipc	a4,0x23e
    80004744:	65070713          	addi	a4,a4,1616 # 80242d90 <log+0x30>
  for (i = 0; i < log.lh.n; i++)
    80004748:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    8000474a:	4314                	lw	a3,0(a4)
    8000474c:	04b68c63          	beq	a3,a1,800047a4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++)
    80004750:	2785                	addiw	a5,a5,1
    80004752:	0711                	addi	a4,a4,4
    80004754:	fef61be3          	bne	a2,a5,8000474a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004758:	0621                	addi	a2,a2,8
    8000475a:	060a                	slli	a2,a2,0x2
    8000475c:	0023e797          	auipc	a5,0x23e
    80004760:	60478793          	addi	a5,a5,1540 # 80242d60 <log>
    80004764:	97b2                	add	a5,a5,a2
    80004766:	44d8                	lw	a4,12(s1)
    80004768:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n)
  { // Add new block to log?
    bpin(b);
    8000476a:	8526                	mv	a0,s1
    8000476c:	fffff097          	auipc	ra,0xfffff
    80004770:	d9c080e7          	jalr	-612(ra) # 80003508 <bpin>
    log.lh.n++;
    80004774:	0023e717          	auipc	a4,0x23e
    80004778:	5ec70713          	addi	a4,a4,1516 # 80242d60 <log>
    8000477c:	575c                	lw	a5,44(a4)
    8000477e:	2785                	addiw	a5,a5,1
    80004780:	d75c                	sw	a5,44(a4)
    80004782:	a82d                	j	800047bc <log_write+0xc8>
    panic("too big a transaction");
    80004784:	00004517          	auipc	a0,0x4
    80004788:	fe450513          	addi	a0,a0,-28 # 80008768 <syscalls+0x208>
    8000478c:	ffffc097          	auipc	ra,0xffffc
    80004790:	db4080e7          	jalr	-588(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004794:	00004517          	auipc	a0,0x4
    80004798:	fec50513          	addi	a0,a0,-20 # 80008780 <syscalls+0x220>
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	da4080e7          	jalr	-604(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    800047a4:	00878693          	addi	a3,a5,8
    800047a8:	068a                	slli	a3,a3,0x2
    800047aa:	0023e717          	auipc	a4,0x23e
    800047ae:	5b670713          	addi	a4,a4,1462 # 80242d60 <log>
    800047b2:	9736                	add	a4,a4,a3
    800047b4:	44d4                	lw	a3,12(s1)
    800047b6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n)
    800047b8:	faf609e3          	beq	a2,a5,8000476a <log_write+0x76>
  }
  release(&log.lock);
    800047bc:	0023e517          	auipc	a0,0x23e
    800047c0:	5a450513          	addi	a0,a0,1444 # 80242d60 <log>
    800047c4:	ffffc097          	auipc	ra,0xffffc
    800047c8:	63a080e7          	jalr	1594(ra) # 80000dfe <release>
}
    800047cc:	60e2                	ld	ra,24(sp)
    800047ce:	6442                	ld	s0,16(sp)
    800047d0:	64a2                	ld	s1,8(sp)
    800047d2:	6902                	ld	s2,0(sp)
    800047d4:	6105                	addi	sp,sp,32
    800047d6:	8082                	ret

00000000800047d8 <initsleeplock>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock *lk, char *name)
{
    800047d8:	1101                	addi	sp,sp,-32
    800047da:	ec06                	sd	ra,24(sp)
    800047dc:	e822                	sd	s0,16(sp)
    800047de:	e426                	sd	s1,8(sp)
    800047e0:	e04a                	sd	s2,0(sp)
    800047e2:	1000                	addi	s0,sp,32
    800047e4:	84aa                	mv	s1,a0
    800047e6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800047e8:	00004597          	auipc	a1,0x4
    800047ec:	fb858593          	addi	a1,a1,-72 # 800087a0 <syscalls+0x240>
    800047f0:	0521                	addi	a0,a0,8
    800047f2:	ffffc097          	auipc	ra,0xffffc
    800047f6:	4c8080e7          	jalr	1224(ra) # 80000cba <initlock>
  lk->name = name;
    800047fa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800047fe:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004802:	0204a423          	sw	zero,40(s1)
}
    80004806:	60e2                	ld	ra,24(sp)
    80004808:	6442                	ld	s0,16(sp)
    8000480a:	64a2                	ld	s1,8(sp)
    8000480c:	6902                	ld	s2,0(sp)
    8000480e:	6105                	addi	sp,sp,32
    80004810:	8082                	ret

0000000080004812 <acquiresleep>:

void acquiresleep(struct sleeplock *lk)
{
    80004812:	1101                	addi	sp,sp,-32
    80004814:	ec06                	sd	ra,24(sp)
    80004816:	e822                	sd	s0,16(sp)
    80004818:	e426                	sd	s1,8(sp)
    8000481a:	e04a                	sd	s2,0(sp)
    8000481c:	1000                	addi	s0,sp,32
    8000481e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004820:	00850913          	addi	s2,a0,8
    80004824:	854a                	mv	a0,s2
    80004826:	ffffc097          	auipc	ra,0xffffc
    8000482a:	524080e7          	jalr	1316(ra) # 80000d4a <acquire>
  while (lk->locked)
    8000482e:	409c                	lw	a5,0(s1)
    80004830:	cb89                	beqz	a5,80004842 <acquiresleep+0x30>
  {
    sleep(lk, &lk->lk);
    80004832:	85ca                	mv	a1,s2
    80004834:	8526                	mv	a0,s1
    80004836:	ffffe097          	auipc	ra,0xffffe
    8000483a:	a18080e7          	jalr	-1512(ra) # 8000224e <sleep>
  while (lk->locked)
    8000483e:	409c                	lw	a5,0(s1)
    80004840:	fbed                	bnez	a5,80004832 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004842:	4785                	li	a5,1
    80004844:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004846:	ffffd097          	auipc	ra,0xffffd
    8000484a:	2da080e7          	jalr	730(ra) # 80001b20 <myproc>
    8000484e:	591c                	lw	a5,48(a0)
    80004850:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004852:	854a                	mv	a0,s2
    80004854:	ffffc097          	auipc	ra,0xffffc
    80004858:	5aa080e7          	jalr	1450(ra) # 80000dfe <release>
}
    8000485c:	60e2                	ld	ra,24(sp)
    8000485e:	6442                	ld	s0,16(sp)
    80004860:	64a2                	ld	s1,8(sp)
    80004862:	6902                	ld	s2,0(sp)
    80004864:	6105                	addi	sp,sp,32
    80004866:	8082                	ret

0000000080004868 <releasesleep>:

void releasesleep(struct sleeplock *lk)
{
    80004868:	1101                	addi	sp,sp,-32
    8000486a:	ec06                	sd	ra,24(sp)
    8000486c:	e822                	sd	s0,16(sp)
    8000486e:	e426                	sd	s1,8(sp)
    80004870:	e04a                	sd	s2,0(sp)
    80004872:	1000                	addi	s0,sp,32
    80004874:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004876:	00850913          	addi	s2,a0,8
    8000487a:	854a                	mv	a0,s2
    8000487c:	ffffc097          	auipc	ra,0xffffc
    80004880:	4ce080e7          	jalr	1230(ra) # 80000d4a <acquire>
  lk->locked = 0;
    80004884:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004888:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000488c:	8526                	mv	a0,s1
    8000488e:	ffffe097          	auipc	ra,0xffffe
    80004892:	a30080e7          	jalr	-1488(ra) # 800022be <wakeup>
  release(&lk->lk);
    80004896:	854a                	mv	a0,s2
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	566080e7          	jalr	1382(ra) # 80000dfe <release>
}
    800048a0:	60e2                	ld	ra,24(sp)
    800048a2:	6442                	ld	s0,16(sp)
    800048a4:	64a2                	ld	s1,8(sp)
    800048a6:	6902                	ld	s2,0(sp)
    800048a8:	6105                	addi	sp,sp,32
    800048aa:	8082                	ret

00000000800048ac <holdingsleep>:

int holdingsleep(struct sleeplock *lk)
{
    800048ac:	7179                	addi	sp,sp,-48
    800048ae:	f406                	sd	ra,40(sp)
    800048b0:	f022                	sd	s0,32(sp)
    800048b2:	ec26                	sd	s1,24(sp)
    800048b4:	e84a                	sd	s2,16(sp)
    800048b6:	e44e                	sd	s3,8(sp)
    800048b8:	1800                	addi	s0,sp,48
    800048ba:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800048bc:	00850913          	addi	s2,a0,8
    800048c0:	854a                	mv	a0,s2
    800048c2:	ffffc097          	auipc	ra,0xffffc
    800048c6:	488080e7          	jalr	1160(ra) # 80000d4a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048ca:	409c                	lw	a5,0(s1)
    800048cc:	ef99                	bnez	a5,800048ea <holdingsleep+0x3e>
    800048ce:	4481                	li	s1,0
  release(&lk->lk);
    800048d0:	854a                	mv	a0,s2
    800048d2:	ffffc097          	auipc	ra,0xffffc
    800048d6:	52c080e7          	jalr	1324(ra) # 80000dfe <release>
  return r;
}
    800048da:	8526                	mv	a0,s1
    800048dc:	70a2                	ld	ra,40(sp)
    800048de:	7402                	ld	s0,32(sp)
    800048e0:	64e2                	ld	s1,24(sp)
    800048e2:	6942                	ld	s2,16(sp)
    800048e4:	69a2                	ld	s3,8(sp)
    800048e6:	6145                	addi	sp,sp,48
    800048e8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800048ea:	0284a983          	lw	s3,40(s1)
    800048ee:	ffffd097          	auipc	ra,0xffffd
    800048f2:	232080e7          	jalr	562(ra) # 80001b20 <myproc>
    800048f6:	5904                	lw	s1,48(a0)
    800048f8:	413484b3          	sub	s1,s1,s3
    800048fc:	0014b493          	seqz	s1,s1
    80004900:	bfc1                	j	800048d0 <holdingsleep+0x24>

0000000080004902 <fileinit>:
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void fileinit(void)
{
    80004902:	1141                	addi	sp,sp,-16
    80004904:	e406                	sd	ra,8(sp)
    80004906:	e022                	sd	s0,0(sp)
    80004908:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000490a:	00004597          	auipc	a1,0x4
    8000490e:	ea658593          	addi	a1,a1,-346 # 800087b0 <syscalls+0x250>
    80004912:	0023e517          	auipc	a0,0x23e
    80004916:	59650513          	addi	a0,a0,1430 # 80242ea8 <ftable>
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	3a0080e7          	jalr	928(ra) # 80000cba <initlock>
}
    80004922:	60a2                	ld	ra,8(sp)
    80004924:	6402                	ld	s0,0(sp)
    80004926:	0141                	addi	sp,sp,16
    80004928:	8082                	ret

000000008000492a <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000492a:	1101                	addi	sp,sp,-32
    8000492c:	ec06                	sd	ra,24(sp)
    8000492e:	e822                	sd	s0,16(sp)
    80004930:	e426                	sd	s1,8(sp)
    80004932:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004934:	0023e517          	auipc	a0,0x23e
    80004938:	57450513          	addi	a0,a0,1396 # 80242ea8 <ftable>
    8000493c:	ffffc097          	auipc	ra,0xffffc
    80004940:	40e080e7          	jalr	1038(ra) # 80000d4a <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004944:	0023e497          	auipc	s1,0x23e
    80004948:	57c48493          	addi	s1,s1,1404 # 80242ec0 <ftable+0x18>
    8000494c:	0023f717          	auipc	a4,0x23f
    80004950:	51470713          	addi	a4,a4,1300 # 80243e60 <mt>
  {
    if (f->ref == 0)
    80004954:	40dc                	lw	a5,4(s1)
    80004956:	cf99                	beqz	a5,80004974 <filealloc+0x4a>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004958:	02848493          	addi	s1,s1,40
    8000495c:	fee49ce3          	bne	s1,a4,80004954 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004960:	0023e517          	auipc	a0,0x23e
    80004964:	54850513          	addi	a0,a0,1352 # 80242ea8 <ftable>
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	496080e7          	jalr	1174(ra) # 80000dfe <release>
  return 0;
    80004970:	4481                	li	s1,0
    80004972:	a819                	j	80004988 <filealloc+0x5e>
      f->ref = 1;
    80004974:	4785                	li	a5,1
    80004976:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004978:	0023e517          	auipc	a0,0x23e
    8000497c:	53050513          	addi	a0,a0,1328 # 80242ea8 <ftable>
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	47e080e7          	jalr	1150(ra) # 80000dfe <release>
}
    80004988:	8526                	mv	a0,s1
    8000498a:	60e2                	ld	ra,24(sp)
    8000498c:	6442                	ld	s0,16(sp)
    8000498e:	64a2                	ld	s1,8(sp)
    80004990:	6105                	addi	sp,sp,32
    80004992:	8082                	ret

0000000080004994 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004994:	1101                	addi	sp,sp,-32
    80004996:	ec06                	sd	ra,24(sp)
    80004998:	e822                	sd	s0,16(sp)
    8000499a:	e426                	sd	s1,8(sp)
    8000499c:	1000                	addi	s0,sp,32
    8000499e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049a0:	0023e517          	auipc	a0,0x23e
    800049a4:	50850513          	addi	a0,a0,1288 # 80242ea8 <ftable>
    800049a8:	ffffc097          	auipc	ra,0xffffc
    800049ac:	3a2080e7          	jalr	930(ra) # 80000d4a <acquire>
  if (f->ref < 1)
    800049b0:	40dc                	lw	a5,4(s1)
    800049b2:	02f05263          	blez	a5,800049d6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049b6:	2785                	addiw	a5,a5,1
    800049b8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049ba:	0023e517          	auipc	a0,0x23e
    800049be:	4ee50513          	addi	a0,a0,1262 # 80242ea8 <ftable>
    800049c2:	ffffc097          	auipc	ra,0xffffc
    800049c6:	43c080e7          	jalr	1084(ra) # 80000dfe <release>
  return f;
}
    800049ca:	8526                	mv	a0,s1
    800049cc:	60e2                	ld	ra,24(sp)
    800049ce:	6442                	ld	s0,16(sp)
    800049d0:	64a2                	ld	s1,8(sp)
    800049d2:	6105                	addi	sp,sp,32
    800049d4:	8082                	ret
    panic("filedup");
    800049d6:	00004517          	auipc	a0,0x4
    800049da:	de250513          	addi	a0,a0,-542 # 800087b8 <syscalls+0x258>
    800049de:	ffffc097          	auipc	ra,0xffffc
    800049e2:	b62080e7          	jalr	-1182(ra) # 80000540 <panic>

00000000800049e6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    800049e6:	7139                	addi	sp,sp,-64
    800049e8:	fc06                	sd	ra,56(sp)
    800049ea:	f822                	sd	s0,48(sp)
    800049ec:	f426                	sd	s1,40(sp)
    800049ee:	f04a                	sd	s2,32(sp)
    800049f0:	ec4e                	sd	s3,24(sp)
    800049f2:	e852                	sd	s4,16(sp)
    800049f4:	e456                	sd	s5,8(sp)
    800049f6:	0080                	addi	s0,sp,64
    800049f8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800049fa:	0023e517          	auipc	a0,0x23e
    800049fe:	4ae50513          	addi	a0,a0,1198 # 80242ea8 <ftable>
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	348080e7          	jalr	840(ra) # 80000d4a <acquire>
  if (f->ref < 1)
    80004a0a:	40dc                	lw	a5,4(s1)
    80004a0c:	06f05163          	blez	a5,80004a6e <fileclose+0x88>
    panic("fileclose");
  if (--f->ref > 0)
    80004a10:	37fd                	addiw	a5,a5,-1
    80004a12:	0007871b          	sext.w	a4,a5
    80004a16:	c0dc                	sw	a5,4(s1)
    80004a18:	06e04363          	bgtz	a4,80004a7e <fileclose+0x98>
  {
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a1c:	0004a903          	lw	s2,0(s1)
    80004a20:	0094ca83          	lbu	s5,9(s1)
    80004a24:	0104ba03          	ld	s4,16(s1)
    80004a28:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a2c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a30:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a34:	0023e517          	auipc	a0,0x23e
    80004a38:	47450513          	addi	a0,a0,1140 # 80242ea8 <ftable>
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	3c2080e7          	jalr	962(ra) # 80000dfe <release>

  if (ff.type == FD_PIPE)
    80004a44:	4785                	li	a5,1
    80004a46:	04f90d63          	beq	s2,a5,80004aa0 <fileclose+0xba>
  {
    pipeclose(ff.pipe, ff.writable);
  }
  else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    80004a4a:	3979                	addiw	s2,s2,-2
    80004a4c:	4785                	li	a5,1
    80004a4e:	0527e063          	bltu	a5,s2,80004a8e <fileclose+0xa8>
  {
    begin_op();
    80004a52:	00000097          	auipc	ra,0x0
    80004a56:	acc080e7          	jalr	-1332(ra) # 8000451e <begin_op>
    iput(ff.ip);
    80004a5a:	854e                	mv	a0,s3
    80004a5c:	fffff097          	auipc	ra,0xfffff
    80004a60:	2b0080e7          	jalr	688(ra) # 80003d0c <iput>
    end_op();
    80004a64:	00000097          	auipc	ra,0x0
    80004a68:	b38080e7          	jalr	-1224(ra) # 8000459c <end_op>
    80004a6c:	a00d                	j	80004a8e <fileclose+0xa8>
    panic("fileclose");
    80004a6e:	00004517          	auipc	a0,0x4
    80004a72:	d5250513          	addi	a0,a0,-686 # 800087c0 <syscalls+0x260>
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	aca080e7          	jalr	-1334(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004a7e:	0023e517          	auipc	a0,0x23e
    80004a82:	42a50513          	addi	a0,a0,1066 # 80242ea8 <ftable>
    80004a86:	ffffc097          	auipc	ra,0xffffc
    80004a8a:	378080e7          	jalr	888(ra) # 80000dfe <release>
  }
}
    80004a8e:	70e2                	ld	ra,56(sp)
    80004a90:	7442                	ld	s0,48(sp)
    80004a92:	74a2                	ld	s1,40(sp)
    80004a94:	7902                	ld	s2,32(sp)
    80004a96:	69e2                	ld	s3,24(sp)
    80004a98:	6a42                	ld	s4,16(sp)
    80004a9a:	6aa2                	ld	s5,8(sp)
    80004a9c:	6121                	addi	sp,sp,64
    80004a9e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004aa0:	85d6                	mv	a1,s5
    80004aa2:	8552                	mv	a0,s4
    80004aa4:	00000097          	auipc	ra,0x0
    80004aa8:	34c080e7          	jalr	844(ra) # 80004df0 <pipeclose>
    80004aac:	b7cd                	j	80004a8e <fileclose+0xa8>

0000000080004aae <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80004aae:	715d                	addi	sp,sp,-80
    80004ab0:	e486                	sd	ra,72(sp)
    80004ab2:	e0a2                	sd	s0,64(sp)
    80004ab4:	fc26                	sd	s1,56(sp)
    80004ab6:	f84a                	sd	s2,48(sp)
    80004ab8:	f44e                	sd	s3,40(sp)
    80004aba:	0880                	addi	s0,sp,80
    80004abc:	84aa                	mv	s1,a0
    80004abe:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ac0:	ffffd097          	auipc	ra,0xffffd
    80004ac4:	060080e7          	jalr	96(ra) # 80001b20 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004ac8:	409c                	lw	a5,0(s1)
    80004aca:	37f9                	addiw	a5,a5,-2
    80004acc:	4705                	li	a4,1
    80004ace:	04f76763          	bltu	a4,a5,80004b1c <filestat+0x6e>
    80004ad2:	892a                	mv	s2,a0
  {
    ilock(f->ip);
    80004ad4:	6c88                	ld	a0,24(s1)
    80004ad6:	fffff097          	auipc	ra,0xfffff
    80004ada:	07c080e7          	jalr	124(ra) # 80003b52 <ilock>
    stati(f->ip, &st);
    80004ade:	fb840593          	addi	a1,s0,-72
    80004ae2:	6c88                	ld	a0,24(s1)
    80004ae4:	fffff097          	auipc	ra,0xfffff
    80004ae8:	2f8080e7          	jalr	760(ra) # 80003ddc <stati>
    iunlock(f->ip);
    80004aec:	6c88                	ld	a0,24(s1)
    80004aee:	fffff097          	auipc	ra,0xfffff
    80004af2:	126080e7          	jalr	294(ra) # 80003c14 <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004af6:	46e1                	li	a3,24
    80004af8:	fb840613          	addi	a2,s0,-72
    80004afc:	85ce                	mv	a1,s3
    80004afe:	05093503          	ld	a0,80(s2)
    80004b02:	ffffd097          	auipc	ra,0xffffd
    80004b06:	cde080e7          	jalr	-802(ra) # 800017e0 <copyout>
    80004b0a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b0e:	60a6                	ld	ra,72(sp)
    80004b10:	6406                	ld	s0,64(sp)
    80004b12:	74e2                	ld	s1,56(sp)
    80004b14:	7942                	ld	s2,48(sp)
    80004b16:	79a2                	ld	s3,40(sp)
    80004b18:	6161                	addi	sp,sp,80
    80004b1a:	8082                	ret
  return -1;
    80004b1c:	557d                	li	a0,-1
    80004b1e:	bfc5                	j	80004b0e <filestat+0x60>

0000000080004b20 <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    80004b20:	7179                	addi	sp,sp,-48
    80004b22:	f406                	sd	ra,40(sp)
    80004b24:	f022                	sd	s0,32(sp)
    80004b26:	ec26                	sd	s1,24(sp)
    80004b28:	e84a                	sd	s2,16(sp)
    80004b2a:	e44e                	sd	s3,8(sp)
    80004b2c:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    80004b2e:	00854783          	lbu	a5,8(a0)
    80004b32:	c3d5                	beqz	a5,80004bd6 <fileread+0xb6>
    80004b34:	84aa                	mv	s1,a0
    80004b36:	89ae                	mv	s3,a1
    80004b38:	8932                	mv	s2,a2
    return -1;

  if (f->type == FD_PIPE)
    80004b3a:	411c                	lw	a5,0(a0)
    80004b3c:	4705                	li	a4,1
    80004b3e:	04e78963          	beq	a5,a4,80004b90 <fileread+0x70>
  {
    r = piperead(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004b42:	470d                	li	a4,3
    80004b44:	04e78d63          	beq	a5,a4,80004b9e <fileread+0x7e>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004b48:	4709                	li	a4,2
    80004b4a:	06e79e63          	bne	a5,a4,80004bc6 <fileread+0xa6>
  {
    ilock(f->ip);
    80004b4e:	6d08                	ld	a0,24(a0)
    80004b50:	fffff097          	auipc	ra,0xfffff
    80004b54:	002080e7          	jalr	2(ra) # 80003b52 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b58:	874a                	mv	a4,s2
    80004b5a:	5094                	lw	a3,32(s1)
    80004b5c:	864e                	mv	a2,s3
    80004b5e:	4585                	li	a1,1
    80004b60:	6c88                	ld	a0,24(s1)
    80004b62:	fffff097          	auipc	ra,0xfffff
    80004b66:	2a4080e7          	jalr	676(ra) # 80003e06 <readi>
    80004b6a:	892a                	mv	s2,a0
    80004b6c:	00a05563          	blez	a0,80004b76 <fileread+0x56>
      f->off += r;
    80004b70:	509c                	lw	a5,32(s1)
    80004b72:	9fa9                	addw	a5,a5,a0
    80004b74:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b76:	6c88                	ld	a0,24(s1)
    80004b78:	fffff097          	auipc	ra,0xfffff
    80004b7c:	09c080e7          	jalr	156(ra) # 80003c14 <iunlock>
  {
    panic("fileread");
  }

  return r;
}
    80004b80:	854a                	mv	a0,s2
    80004b82:	70a2                	ld	ra,40(sp)
    80004b84:	7402                	ld	s0,32(sp)
    80004b86:	64e2                	ld	s1,24(sp)
    80004b88:	6942                	ld	s2,16(sp)
    80004b8a:	69a2                	ld	s3,8(sp)
    80004b8c:	6145                	addi	sp,sp,48
    80004b8e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b90:	6908                	ld	a0,16(a0)
    80004b92:	00000097          	auipc	ra,0x0
    80004b96:	3c6080e7          	jalr	966(ra) # 80004f58 <piperead>
    80004b9a:	892a                	mv	s2,a0
    80004b9c:	b7d5                	j	80004b80 <fileread+0x60>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b9e:	02451783          	lh	a5,36(a0)
    80004ba2:	03079693          	slli	a3,a5,0x30
    80004ba6:	92c1                	srli	a3,a3,0x30
    80004ba8:	4725                	li	a4,9
    80004baa:	02d76863          	bltu	a4,a3,80004bda <fileread+0xba>
    80004bae:	0792                	slli	a5,a5,0x4
    80004bb0:	0023e717          	auipc	a4,0x23e
    80004bb4:	25870713          	addi	a4,a4,600 # 80242e08 <devsw>
    80004bb8:	97ba                	add	a5,a5,a4
    80004bba:	639c                	ld	a5,0(a5)
    80004bbc:	c38d                	beqz	a5,80004bde <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004bbe:	4505                	li	a0,1
    80004bc0:	9782                	jalr	a5
    80004bc2:	892a                	mv	s2,a0
    80004bc4:	bf75                	j	80004b80 <fileread+0x60>
    panic("fileread");
    80004bc6:	00004517          	auipc	a0,0x4
    80004bca:	c0a50513          	addi	a0,a0,-1014 # 800087d0 <syscalls+0x270>
    80004bce:	ffffc097          	auipc	ra,0xffffc
    80004bd2:	972080e7          	jalr	-1678(ra) # 80000540 <panic>
    return -1;
    80004bd6:	597d                	li	s2,-1
    80004bd8:	b765                	j	80004b80 <fileread+0x60>
      return -1;
    80004bda:	597d                	li	s2,-1
    80004bdc:	b755                	j	80004b80 <fileread+0x60>
    80004bde:	597d                	li	s2,-1
    80004be0:	b745                	j	80004b80 <fileread+0x60>

0000000080004be2 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    80004be2:	715d                	addi	sp,sp,-80
    80004be4:	e486                	sd	ra,72(sp)
    80004be6:	e0a2                	sd	s0,64(sp)
    80004be8:	fc26                	sd	s1,56(sp)
    80004bea:	f84a                	sd	s2,48(sp)
    80004bec:	f44e                	sd	s3,40(sp)
    80004bee:	f052                	sd	s4,32(sp)
    80004bf0:	ec56                	sd	s5,24(sp)
    80004bf2:	e85a                	sd	s6,16(sp)
    80004bf4:	e45e                	sd	s7,8(sp)
    80004bf6:	e062                	sd	s8,0(sp)
    80004bf8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if (f->writable == 0)
    80004bfa:	00954783          	lbu	a5,9(a0)
    80004bfe:	10078663          	beqz	a5,80004d0a <filewrite+0x128>
    80004c02:	892a                	mv	s2,a0
    80004c04:	8b2e                	mv	s6,a1
    80004c06:	8a32                	mv	s4,a2
    return -1;

  if (f->type == FD_PIPE)
    80004c08:	411c                	lw	a5,0(a0)
    80004c0a:	4705                	li	a4,1
    80004c0c:	02e78263          	beq	a5,a4,80004c30 <filewrite+0x4e>
  {
    ret = pipewrite(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004c10:	470d                	li	a4,3
    80004c12:	02e78663          	beq	a5,a4,80004c3e <filewrite+0x5c>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004c16:	4709                	li	a4,2
    80004c18:	0ee79163          	bne	a5,a4,80004cfa <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n)
    80004c1c:	0ac05d63          	blez	a2,80004cd6 <filewrite+0xf4>
    int i = 0;
    80004c20:	4981                	li	s3,0
    80004c22:	6b85                	lui	s7,0x1
    80004c24:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004c28:	6c05                	lui	s8,0x1
    80004c2a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004c2e:	a861                	j	80004cc6 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004c30:	6908                	ld	a0,16(a0)
    80004c32:	00000097          	auipc	ra,0x0
    80004c36:	22e080e7          	jalr	558(ra) # 80004e60 <pipewrite>
    80004c3a:	8a2a                	mv	s4,a0
    80004c3c:	a045                	j	80004cdc <filewrite+0xfa>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c3e:	02451783          	lh	a5,36(a0)
    80004c42:	03079693          	slli	a3,a5,0x30
    80004c46:	92c1                	srli	a3,a3,0x30
    80004c48:	4725                	li	a4,9
    80004c4a:	0cd76263          	bltu	a4,a3,80004d0e <filewrite+0x12c>
    80004c4e:	0792                	slli	a5,a5,0x4
    80004c50:	0023e717          	auipc	a4,0x23e
    80004c54:	1b870713          	addi	a4,a4,440 # 80242e08 <devsw>
    80004c58:	97ba                	add	a5,a5,a4
    80004c5a:	679c                	ld	a5,8(a5)
    80004c5c:	cbdd                	beqz	a5,80004d12 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c5e:	4505                	li	a0,1
    80004c60:	9782                	jalr	a5
    80004c62:	8a2a                	mv	s4,a0
    80004c64:	a8a5                	j	80004cdc <filewrite+0xfa>
    80004c66:	00048a9b          	sext.w	s5,s1
    {
      int n1 = n - i;
      if (n1 > max)
        n1 = max;

      begin_op();
    80004c6a:	00000097          	auipc	ra,0x0
    80004c6e:	8b4080e7          	jalr	-1868(ra) # 8000451e <begin_op>
      ilock(f->ip);
    80004c72:	01893503          	ld	a0,24(s2)
    80004c76:	fffff097          	auipc	ra,0xfffff
    80004c7a:	edc080e7          	jalr	-292(ra) # 80003b52 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c7e:	8756                	mv	a4,s5
    80004c80:	02092683          	lw	a3,32(s2)
    80004c84:	01698633          	add	a2,s3,s6
    80004c88:	4585                	li	a1,1
    80004c8a:	01893503          	ld	a0,24(s2)
    80004c8e:	fffff097          	auipc	ra,0xfffff
    80004c92:	270080e7          	jalr	624(ra) # 80003efe <writei>
    80004c96:	84aa                	mv	s1,a0
    80004c98:	00a05763          	blez	a0,80004ca6 <filewrite+0xc4>
        f->off += r;
    80004c9c:	02092783          	lw	a5,32(s2)
    80004ca0:	9fa9                	addw	a5,a5,a0
    80004ca2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ca6:	01893503          	ld	a0,24(s2)
    80004caa:	fffff097          	auipc	ra,0xfffff
    80004cae:	f6a080e7          	jalr	-150(ra) # 80003c14 <iunlock>
      end_op();
    80004cb2:	00000097          	auipc	ra,0x0
    80004cb6:	8ea080e7          	jalr	-1814(ra) # 8000459c <end_op>

      if (r != n1)
    80004cba:	009a9f63          	bne	s5,s1,80004cd8 <filewrite+0xf6>
      {
        // error from writei
        break;
      }
      i += r;
    80004cbe:	013489bb          	addw	s3,s1,s3
    while (i < n)
    80004cc2:	0149db63          	bge	s3,s4,80004cd8 <filewrite+0xf6>
      int n1 = n - i;
    80004cc6:	413a04bb          	subw	s1,s4,s3
    80004cca:	0004879b          	sext.w	a5,s1
    80004cce:	f8fbdce3          	bge	s7,a5,80004c66 <filewrite+0x84>
    80004cd2:	84e2                	mv	s1,s8
    80004cd4:	bf49                	j	80004c66 <filewrite+0x84>
    int i = 0;
    80004cd6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004cd8:	013a1f63          	bne	s4,s3,80004cf6 <filewrite+0x114>
  {
    panic("filewrite");
  }

  return ret;
}
    80004cdc:	8552                	mv	a0,s4
    80004cde:	60a6                	ld	ra,72(sp)
    80004ce0:	6406                	ld	s0,64(sp)
    80004ce2:	74e2                	ld	s1,56(sp)
    80004ce4:	7942                	ld	s2,48(sp)
    80004ce6:	79a2                	ld	s3,40(sp)
    80004ce8:	7a02                	ld	s4,32(sp)
    80004cea:	6ae2                	ld	s5,24(sp)
    80004cec:	6b42                	ld	s6,16(sp)
    80004cee:	6ba2                	ld	s7,8(sp)
    80004cf0:	6c02                	ld	s8,0(sp)
    80004cf2:	6161                	addi	sp,sp,80
    80004cf4:	8082                	ret
    ret = (i == n ? n : -1);
    80004cf6:	5a7d                	li	s4,-1
    80004cf8:	b7d5                	j	80004cdc <filewrite+0xfa>
    panic("filewrite");
    80004cfa:	00004517          	auipc	a0,0x4
    80004cfe:	ae650513          	addi	a0,a0,-1306 # 800087e0 <syscalls+0x280>
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	83e080e7          	jalr	-1986(ra) # 80000540 <panic>
    return -1;
    80004d0a:	5a7d                	li	s4,-1
    80004d0c:	bfc1                	j	80004cdc <filewrite+0xfa>
      return -1;
    80004d0e:	5a7d                	li	s4,-1
    80004d10:	b7f1                	j	80004cdc <filewrite+0xfa>
    80004d12:	5a7d                	li	s4,-1
    80004d14:	b7e1                	j	80004cdc <filewrite+0xfa>

0000000080004d16 <pipealloc>:
  int readopen;  // read fd is still open
  int writeopen; // write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
    80004d16:	7179                	addi	sp,sp,-48
    80004d18:	f406                	sd	ra,40(sp)
    80004d1a:	f022                	sd	s0,32(sp)
    80004d1c:	ec26                	sd	s1,24(sp)
    80004d1e:	e84a                	sd	s2,16(sp)
    80004d20:	e44e                	sd	s3,8(sp)
    80004d22:	e052                	sd	s4,0(sp)
    80004d24:	1800                	addi	s0,sp,48
    80004d26:	84aa                	mv	s1,a0
    80004d28:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d2a:	0005b023          	sd	zero,0(a1)
    80004d2e:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d32:	00000097          	auipc	ra,0x0
    80004d36:	bf8080e7          	jalr	-1032(ra) # 8000492a <filealloc>
    80004d3a:	e088                	sd	a0,0(s1)
    80004d3c:	c551                	beqz	a0,80004dc8 <pipealloc+0xb2>
    80004d3e:	00000097          	auipc	ra,0x0
    80004d42:	bec080e7          	jalr	-1044(ra) # 8000492a <filealloc>
    80004d46:	00aa3023          	sd	a0,0(s4)
    80004d4a:	c92d                	beqz	a0,80004dbc <pipealloc+0xa6>
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004d4c:	ffffc097          	auipc	ra,0xffffc
    80004d50:	f04080e7          	jalr	-252(ra) # 80000c50 <kalloc>
    80004d54:	892a                	mv	s2,a0
    80004d56:	c125                	beqz	a0,80004db6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d58:	4985                	li	s3,1
    80004d5a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d5e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d62:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d66:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d6a:	00003597          	auipc	a1,0x3
    80004d6e:	72e58593          	addi	a1,a1,1838 # 80008498 <states.0+0x188>
    80004d72:	ffffc097          	auipc	ra,0xffffc
    80004d76:	f48080e7          	jalr	-184(ra) # 80000cba <initlock>
  (*f0)->type = FD_PIPE;
    80004d7a:	609c                	ld	a5,0(s1)
    80004d7c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d80:	609c                	ld	a5,0(s1)
    80004d82:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d86:	609c                	ld	a5,0(s1)
    80004d88:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d8c:	609c                	ld	a5,0(s1)
    80004d8e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d92:	000a3783          	ld	a5,0(s4)
    80004d96:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d9a:	000a3783          	ld	a5,0(s4)
    80004d9e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004da2:	000a3783          	ld	a5,0(s4)
    80004da6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004daa:	000a3783          	ld	a5,0(s4)
    80004dae:	0127b823          	sd	s2,16(a5)
  return 0;
    80004db2:	4501                	li	a0,0
    80004db4:	a025                	j	80004ddc <pipealloc+0xc6>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004db6:	6088                	ld	a0,0(s1)
    80004db8:	e501                	bnez	a0,80004dc0 <pipealloc+0xaa>
    80004dba:	a039                	j	80004dc8 <pipealloc+0xb2>
    80004dbc:	6088                	ld	a0,0(s1)
    80004dbe:	c51d                	beqz	a0,80004dec <pipealloc+0xd6>
    fileclose(*f0);
    80004dc0:	00000097          	auipc	ra,0x0
    80004dc4:	c26080e7          	jalr	-986(ra) # 800049e6 <fileclose>
  if (*f1)
    80004dc8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004dcc:	557d                	li	a0,-1
  if (*f1)
    80004dce:	c799                	beqz	a5,80004ddc <pipealloc+0xc6>
    fileclose(*f1);
    80004dd0:	853e                	mv	a0,a5
    80004dd2:	00000097          	auipc	ra,0x0
    80004dd6:	c14080e7          	jalr	-1004(ra) # 800049e6 <fileclose>
  return -1;
    80004dda:	557d                	li	a0,-1
}
    80004ddc:	70a2                	ld	ra,40(sp)
    80004dde:	7402                	ld	s0,32(sp)
    80004de0:	64e2                	ld	s1,24(sp)
    80004de2:	6942                	ld	s2,16(sp)
    80004de4:	69a2                	ld	s3,8(sp)
    80004de6:	6a02                	ld	s4,0(sp)
    80004de8:	6145                	addi	sp,sp,48
    80004dea:	8082                	ret
  return -1;
    80004dec:	557d                	li	a0,-1
    80004dee:	b7fd                	j	80004ddc <pipealloc+0xc6>

0000000080004df0 <pipeclose>:

void pipeclose(struct pipe *pi, int writable)
{
    80004df0:	1101                	addi	sp,sp,-32
    80004df2:	ec06                	sd	ra,24(sp)
    80004df4:	e822                	sd	s0,16(sp)
    80004df6:	e426                	sd	s1,8(sp)
    80004df8:	e04a                	sd	s2,0(sp)
    80004dfa:	1000                	addi	s0,sp,32
    80004dfc:	84aa                	mv	s1,a0
    80004dfe:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e00:	ffffc097          	auipc	ra,0xffffc
    80004e04:	f4a080e7          	jalr	-182(ra) # 80000d4a <acquire>
  if (writable)
    80004e08:	02090d63          	beqz	s2,80004e42 <pipeclose+0x52>
  {
    pi->writeopen = 0;
    80004e0c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e10:	21848513          	addi	a0,s1,536
    80004e14:	ffffd097          	auipc	ra,0xffffd
    80004e18:	4aa080e7          	jalr	1194(ra) # 800022be <wakeup>
  else
  {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0)
    80004e1c:	2204b783          	ld	a5,544(s1)
    80004e20:	eb95                	bnez	a5,80004e54 <pipeclose+0x64>
  {
    release(&pi->lock);
    80004e22:	8526                	mv	a0,s1
    80004e24:	ffffc097          	auipc	ra,0xffffc
    80004e28:	fda080e7          	jalr	-38(ra) # 80000dfe <release>
    kfree((char *)pi);
    80004e2c:	8526                	mv	a0,s1
    80004e2e:	ffffc097          	auipc	ra,0xffffc
    80004e32:	c4a080e7          	jalr	-950(ra) # 80000a78 <kfree>
  }
  else
    release(&pi->lock);
}
    80004e36:	60e2                	ld	ra,24(sp)
    80004e38:	6442                	ld	s0,16(sp)
    80004e3a:	64a2                	ld	s1,8(sp)
    80004e3c:	6902                	ld	s2,0(sp)
    80004e3e:	6105                	addi	sp,sp,32
    80004e40:	8082                	ret
    pi->readopen = 0;
    80004e42:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e46:	21c48513          	addi	a0,s1,540
    80004e4a:	ffffd097          	auipc	ra,0xffffd
    80004e4e:	474080e7          	jalr	1140(ra) # 800022be <wakeup>
    80004e52:	b7e9                	j	80004e1c <pipeclose+0x2c>
    release(&pi->lock);
    80004e54:	8526                	mv	a0,s1
    80004e56:	ffffc097          	auipc	ra,0xffffc
    80004e5a:	fa8080e7          	jalr	-88(ra) # 80000dfe <release>
}
    80004e5e:	bfe1                	j	80004e36 <pipeclose+0x46>

0000000080004e60 <pipewrite>:

int pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e60:	711d                	addi	sp,sp,-96
    80004e62:	ec86                	sd	ra,88(sp)
    80004e64:	e8a2                	sd	s0,80(sp)
    80004e66:	e4a6                	sd	s1,72(sp)
    80004e68:	e0ca                	sd	s2,64(sp)
    80004e6a:	fc4e                	sd	s3,56(sp)
    80004e6c:	f852                	sd	s4,48(sp)
    80004e6e:	f456                	sd	s5,40(sp)
    80004e70:	f05a                	sd	s6,32(sp)
    80004e72:	ec5e                	sd	s7,24(sp)
    80004e74:	e862                	sd	s8,16(sp)
    80004e76:	1080                	addi	s0,sp,96
    80004e78:	84aa                	mv	s1,a0
    80004e7a:	8aae                	mv	s5,a1
    80004e7c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e7e:	ffffd097          	auipc	ra,0xffffd
    80004e82:	ca2080e7          	jalr	-862(ra) # 80001b20 <myproc>
    80004e86:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e88:	8526                	mv	a0,s1
    80004e8a:	ffffc097          	auipc	ra,0xffffc
    80004e8e:	ec0080e7          	jalr	-320(ra) # 80000d4a <acquire>
  while (i < n)
    80004e92:	0b405663          	blez	s4,80004f3e <pipewrite+0xde>
  int i = 0;
    80004e96:	4901                	li	s2,0
      sleep(&pi->nwrite, &pi->lock);
    }
    else
    {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e98:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e9a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e9e:	21c48b93          	addi	s7,s1,540
    80004ea2:	a089                	j	80004ee4 <pipewrite+0x84>
      release(&pi->lock);
    80004ea4:	8526                	mv	a0,s1
    80004ea6:	ffffc097          	auipc	ra,0xffffc
    80004eaa:	f58080e7          	jalr	-168(ra) # 80000dfe <release>
      return -1;
    80004eae:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004eb0:	854a                	mv	a0,s2
    80004eb2:	60e6                	ld	ra,88(sp)
    80004eb4:	6446                	ld	s0,80(sp)
    80004eb6:	64a6                	ld	s1,72(sp)
    80004eb8:	6906                	ld	s2,64(sp)
    80004eba:	79e2                	ld	s3,56(sp)
    80004ebc:	7a42                	ld	s4,48(sp)
    80004ebe:	7aa2                	ld	s5,40(sp)
    80004ec0:	7b02                	ld	s6,32(sp)
    80004ec2:	6be2                	ld	s7,24(sp)
    80004ec4:	6c42                	ld	s8,16(sp)
    80004ec6:	6125                	addi	sp,sp,96
    80004ec8:	8082                	ret
      wakeup(&pi->nread);
    80004eca:	8562                	mv	a0,s8
    80004ecc:	ffffd097          	auipc	ra,0xffffd
    80004ed0:	3f2080e7          	jalr	1010(ra) # 800022be <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ed4:	85a6                	mv	a1,s1
    80004ed6:	855e                	mv	a0,s7
    80004ed8:	ffffd097          	auipc	ra,0xffffd
    80004edc:	376080e7          	jalr	886(ra) # 8000224e <sleep>
  while (i < n)
    80004ee0:	07495063          	bge	s2,s4,80004f40 <pipewrite+0xe0>
    if (pi->readopen == 0 || killed(pr))
    80004ee4:	2204a783          	lw	a5,544(s1)
    80004ee8:	dfd5                	beqz	a5,80004ea4 <pipewrite+0x44>
    80004eea:	854e                	mv	a0,s3
    80004eec:	ffffd097          	auipc	ra,0xffffd
    80004ef0:	642080e7          	jalr	1602(ra) # 8000252e <killed>
    80004ef4:	f945                	bnez	a0,80004ea4 <pipewrite+0x44>
    if (pi->nwrite == pi->nread + PIPESIZE)
    80004ef6:	2184a783          	lw	a5,536(s1)
    80004efa:	21c4a703          	lw	a4,540(s1)
    80004efe:	2007879b          	addiw	a5,a5,512
    80004f02:	fcf704e3          	beq	a4,a5,80004eca <pipewrite+0x6a>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f06:	4685                	li	a3,1
    80004f08:	01590633          	add	a2,s2,s5
    80004f0c:	faf40593          	addi	a1,s0,-81
    80004f10:	0509b503          	ld	a0,80(s3)
    80004f14:	ffffd097          	auipc	ra,0xffffd
    80004f18:	958080e7          	jalr	-1704(ra) # 8000186c <copyin>
    80004f1c:	03650263          	beq	a0,s6,80004f40 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f20:	21c4a783          	lw	a5,540(s1)
    80004f24:	0017871b          	addiw	a4,a5,1
    80004f28:	20e4ae23          	sw	a4,540(s1)
    80004f2c:	1ff7f793          	andi	a5,a5,511
    80004f30:	97a6                	add	a5,a5,s1
    80004f32:	faf44703          	lbu	a4,-81(s0)
    80004f36:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f3a:	2905                	addiw	s2,s2,1
    80004f3c:	b755                	j	80004ee0 <pipewrite+0x80>
  int i = 0;
    80004f3e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004f40:	21848513          	addi	a0,s1,536
    80004f44:	ffffd097          	auipc	ra,0xffffd
    80004f48:	37a080e7          	jalr	890(ra) # 800022be <wakeup>
  release(&pi->lock);
    80004f4c:	8526                	mv	a0,s1
    80004f4e:	ffffc097          	auipc	ra,0xffffc
    80004f52:	eb0080e7          	jalr	-336(ra) # 80000dfe <release>
  return i;
    80004f56:	bfa9                	j	80004eb0 <pipewrite+0x50>

0000000080004f58 <piperead>:

int piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f58:	715d                	addi	sp,sp,-80
    80004f5a:	e486                	sd	ra,72(sp)
    80004f5c:	e0a2                	sd	s0,64(sp)
    80004f5e:	fc26                	sd	s1,56(sp)
    80004f60:	f84a                	sd	s2,48(sp)
    80004f62:	f44e                	sd	s3,40(sp)
    80004f64:	f052                	sd	s4,32(sp)
    80004f66:	ec56                	sd	s5,24(sp)
    80004f68:	e85a                	sd	s6,16(sp)
    80004f6a:	0880                	addi	s0,sp,80
    80004f6c:	84aa                	mv	s1,a0
    80004f6e:	892e                	mv	s2,a1
    80004f70:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f72:	ffffd097          	auipc	ra,0xffffd
    80004f76:	bae080e7          	jalr	-1106(ra) # 80001b20 <myproc>
    80004f7a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	dcc080e7          	jalr	-564(ra) # 80000d4a <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004f86:	2184a703          	lw	a4,536(s1)
    80004f8a:	21c4a783          	lw	a5,540(s1)
    if (killed(pr))
    {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004f8e:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004f92:	02f71763          	bne	a4,a5,80004fc0 <piperead+0x68>
    80004f96:	2244a783          	lw	a5,548(s1)
    80004f9a:	c39d                	beqz	a5,80004fc0 <piperead+0x68>
    if (killed(pr))
    80004f9c:	8552                	mv	a0,s4
    80004f9e:	ffffd097          	auipc	ra,0xffffd
    80004fa2:	590080e7          	jalr	1424(ra) # 8000252e <killed>
    80004fa6:	e949                	bnez	a0,80005038 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    80004fa8:	85a6                	mv	a1,s1
    80004faa:	854e                	mv	a0,s3
    80004fac:	ffffd097          	auipc	ra,0xffffd
    80004fb0:	2a2080e7          	jalr	674(ra) # 8000224e <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen)
    80004fb4:	2184a703          	lw	a4,536(s1)
    80004fb8:	21c4a783          	lw	a5,540(s1)
    80004fbc:	fcf70de3          	beq	a4,a5,80004f96 <piperead+0x3e>
  }
  for (i = 0; i < n; i++)
    80004fc0:	4981                	li	s3,0
  { // DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fc2:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++)
    80004fc4:	05505463          	blez	s5,8000500c <piperead+0xb4>
    if (pi->nread == pi->nwrite)
    80004fc8:	2184a783          	lw	a5,536(s1)
    80004fcc:	21c4a703          	lw	a4,540(s1)
    80004fd0:	02f70e63          	beq	a4,a5,8000500c <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fd4:	0017871b          	addiw	a4,a5,1
    80004fd8:	20e4ac23          	sw	a4,536(s1)
    80004fdc:	1ff7f793          	andi	a5,a5,511
    80004fe0:	97a6                	add	a5,a5,s1
    80004fe2:	0187c783          	lbu	a5,24(a5)
    80004fe6:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fea:	4685                	li	a3,1
    80004fec:	fbf40613          	addi	a2,s0,-65
    80004ff0:	85ca                	mv	a1,s2
    80004ff2:	050a3503          	ld	a0,80(s4)
    80004ff6:	ffffc097          	auipc	ra,0xffffc
    80004ffa:	7ea080e7          	jalr	2026(ra) # 800017e0 <copyout>
    80004ffe:	01650763          	beq	a0,s6,8000500c <piperead+0xb4>
  for (i = 0; i < n; i++)
    80005002:	2985                	addiw	s3,s3,1
    80005004:	0905                	addi	s2,s2,1
    80005006:	fd3a91e3          	bne	s5,s3,80004fc8 <piperead+0x70>
    8000500a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite); // DOC: piperead-wakeup
    8000500c:	21c48513          	addi	a0,s1,540
    80005010:	ffffd097          	auipc	ra,0xffffd
    80005014:	2ae080e7          	jalr	686(ra) # 800022be <wakeup>
  release(&pi->lock);
    80005018:	8526                	mv	a0,s1
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	de4080e7          	jalr	-540(ra) # 80000dfe <release>
  return i;
}
    80005022:	854e                	mv	a0,s3
    80005024:	60a6                	ld	ra,72(sp)
    80005026:	6406                	ld	s0,64(sp)
    80005028:	74e2                	ld	s1,56(sp)
    8000502a:	7942                	ld	s2,48(sp)
    8000502c:	79a2                	ld	s3,40(sp)
    8000502e:	7a02                	ld	s4,32(sp)
    80005030:	6ae2                	ld	s5,24(sp)
    80005032:	6b42                	ld	s6,16(sp)
    80005034:	6161                	addi	sp,sp,80
    80005036:	8082                	ret
      release(&pi->lock);
    80005038:	8526                	mv	a0,s1
    8000503a:	ffffc097          	auipc	ra,0xffffc
    8000503e:	dc4080e7          	jalr	-572(ra) # 80000dfe <release>
      return -1;
    80005042:	59fd                	li	s3,-1
    80005044:	bff9                	j	80005022 <piperead+0xca>

0000000080005046 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005046:	1141                	addi	sp,sp,-16
    80005048:	e422                	sd	s0,8(sp)
    8000504a:	0800                	addi	s0,sp,16
    8000504c:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    8000504e:	8905                	andi	a0,a0,1
    80005050:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80005052:	8b89                	andi	a5,a5,2
    80005054:	c399                	beqz	a5,8000505a <flags2perm+0x14>
    perm |= PTE_W;
    80005056:	00456513          	ori	a0,a0,4
  return perm;
}
    8000505a:	6422                	ld	s0,8(sp)
    8000505c:	0141                	addi	sp,sp,16
    8000505e:	8082                	ret

0000000080005060 <exec>:

int exec(char *path, char **argv)
{
    80005060:	de010113          	addi	sp,sp,-544
    80005064:	20113c23          	sd	ra,536(sp)
    80005068:	20813823          	sd	s0,528(sp)
    8000506c:	20913423          	sd	s1,520(sp)
    80005070:	21213023          	sd	s2,512(sp)
    80005074:	ffce                	sd	s3,504(sp)
    80005076:	fbd2                	sd	s4,496(sp)
    80005078:	f7d6                	sd	s5,488(sp)
    8000507a:	f3da                	sd	s6,480(sp)
    8000507c:	efde                	sd	s7,472(sp)
    8000507e:	ebe2                	sd	s8,464(sp)
    80005080:	e7e6                	sd	s9,456(sp)
    80005082:	e3ea                	sd	s10,448(sp)
    80005084:	ff6e                	sd	s11,440(sp)
    80005086:	1400                	addi	s0,sp,544
    80005088:	892a                	mv	s2,a0
    8000508a:	dea43423          	sd	a0,-536(s0)
    8000508e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005092:	ffffd097          	auipc	ra,0xffffd
    80005096:	a8e080e7          	jalr	-1394(ra) # 80001b20 <myproc>
    8000509a:	84aa                	mv	s1,a0

  begin_op();
    8000509c:	fffff097          	auipc	ra,0xfffff
    800050a0:	482080e7          	jalr	1154(ra) # 8000451e <begin_op>

  if ((ip = namei(path)) == 0)
    800050a4:	854a                	mv	a0,s2
    800050a6:	fffff097          	auipc	ra,0xfffff
    800050aa:	258080e7          	jalr	600(ra) # 800042fe <namei>
    800050ae:	c93d                	beqz	a0,80005124 <exec+0xc4>
    800050b0:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    800050b2:	fffff097          	auipc	ra,0xfffff
    800050b6:	aa0080e7          	jalr	-1376(ra) # 80003b52 <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800050ba:	04000713          	li	a4,64
    800050be:	4681                	li	a3,0
    800050c0:	e5040613          	addi	a2,s0,-432
    800050c4:	4581                	li	a1,0
    800050c6:	8556                	mv	a0,s5
    800050c8:	fffff097          	auipc	ra,0xfffff
    800050cc:	d3e080e7          	jalr	-706(ra) # 80003e06 <readi>
    800050d0:	04000793          	li	a5,64
    800050d4:	00f51a63          	bne	a0,a5,800050e8 <exec+0x88>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    800050d8:	e5042703          	lw	a4,-432(s0)
    800050dc:	464c47b7          	lui	a5,0x464c4
    800050e0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050e4:	04f70663          	beq	a4,a5,80005130 <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    800050e8:	8556                	mv	a0,s5
    800050ea:	fffff097          	auipc	ra,0xfffff
    800050ee:	cca080e7          	jalr	-822(ra) # 80003db4 <iunlockput>
    end_op();
    800050f2:	fffff097          	auipc	ra,0xfffff
    800050f6:	4aa080e7          	jalr	1194(ra) # 8000459c <end_op>
  }
  return -1;
    800050fa:	557d                	li	a0,-1
}
    800050fc:	21813083          	ld	ra,536(sp)
    80005100:	21013403          	ld	s0,528(sp)
    80005104:	20813483          	ld	s1,520(sp)
    80005108:	20013903          	ld	s2,512(sp)
    8000510c:	79fe                	ld	s3,504(sp)
    8000510e:	7a5e                	ld	s4,496(sp)
    80005110:	7abe                	ld	s5,488(sp)
    80005112:	7b1e                	ld	s6,480(sp)
    80005114:	6bfe                	ld	s7,472(sp)
    80005116:	6c5e                	ld	s8,464(sp)
    80005118:	6cbe                	ld	s9,456(sp)
    8000511a:	6d1e                	ld	s10,448(sp)
    8000511c:	7dfa                	ld	s11,440(sp)
    8000511e:	22010113          	addi	sp,sp,544
    80005122:	8082                	ret
    end_op();
    80005124:	fffff097          	auipc	ra,0xfffff
    80005128:	478080e7          	jalr	1144(ra) # 8000459c <end_op>
    return -1;
    8000512c:	557d                	li	a0,-1
    8000512e:	b7f9                	j	800050fc <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    80005130:	8526                	mv	a0,s1
    80005132:	ffffd097          	auipc	ra,0xffffd
    80005136:	ab2080e7          	jalr	-1358(ra) # 80001be4 <proc_pagetable>
    8000513a:	8b2a                	mv	s6,a0
    8000513c:	d555                	beqz	a0,800050e8 <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    8000513e:	e7042783          	lw	a5,-400(s0)
    80005142:	e8845703          	lhu	a4,-376(s0)
    80005146:	c735                	beqz	a4,800051b2 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005148:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    8000514a:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    8000514e:	6a05                	lui	s4,0x1
    80005150:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005154:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for (i = 0; i < sz; i += PGSIZE)
    80005158:	6d85                	lui	s11,0x1
    8000515a:	7d7d                	lui	s10,0xfffff
    8000515c:	ac3d                	j	8000539a <exec+0x33a>
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    8000515e:	00003517          	auipc	a0,0x3
    80005162:	69250513          	addi	a0,a0,1682 # 800087f0 <syscalls+0x290>
    80005166:	ffffb097          	auipc	ra,0xffffb
    8000516a:	3da080e7          	jalr	986(ra) # 80000540 <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    8000516e:	874a                	mv	a4,s2
    80005170:	009c86bb          	addw	a3,s9,s1
    80005174:	4581                	li	a1,0
    80005176:	8556                	mv	a0,s5
    80005178:	fffff097          	auipc	ra,0xfffff
    8000517c:	c8e080e7          	jalr	-882(ra) # 80003e06 <readi>
    80005180:	2501                	sext.w	a0,a0
    80005182:	1aa91963          	bne	s2,a0,80005334 <exec+0x2d4>
  for (i = 0; i < sz; i += PGSIZE)
    80005186:	009d84bb          	addw	s1,s11,s1
    8000518a:	013d09bb          	addw	s3,s10,s3
    8000518e:	1f74f663          	bgeu	s1,s7,8000537a <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005192:	02049593          	slli	a1,s1,0x20
    80005196:	9181                	srli	a1,a1,0x20
    80005198:	95e2                	add	a1,a1,s8
    8000519a:	855a                	mv	a0,s6
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	034080e7          	jalr	52(ra) # 800011d0 <walkaddr>
    800051a4:	862a                	mv	a2,a0
    if (pa == 0)
    800051a6:	dd45                	beqz	a0,8000515e <exec+0xfe>
      n = PGSIZE;
    800051a8:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    800051aa:	fd49f2e3          	bgeu	s3,s4,8000516e <exec+0x10e>
      n = sz - i;
    800051ae:	894e                	mv	s2,s3
    800051b0:	bf7d                	j	8000516e <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051b2:	4901                	li	s2,0
  iunlockput(ip);
    800051b4:	8556                	mv	a0,s5
    800051b6:	fffff097          	auipc	ra,0xfffff
    800051ba:	bfe080e7          	jalr	-1026(ra) # 80003db4 <iunlockput>
  end_op();
    800051be:	fffff097          	auipc	ra,0xfffff
    800051c2:	3de080e7          	jalr	990(ra) # 8000459c <end_op>
  p = myproc();
    800051c6:	ffffd097          	auipc	ra,0xffffd
    800051ca:	95a080e7          	jalr	-1702(ra) # 80001b20 <myproc>
    800051ce:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800051d0:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800051d4:	6785                	lui	a5,0x1
    800051d6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800051d8:	97ca                	add	a5,a5,s2
    800051da:	777d                	lui	a4,0xfffff
    800051dc:	8ff9                	and	a5,a5,a4
    800051de:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    800051e2:	4691                	li	a3,4
    800051e4:	6609                	lui	a2,0x2
    800051e6:	963e                	add	a2,a2,a5
    800051e8:	85be                	mv	a1,a5
    800051ea:	855a                	mv	a0,s6
    800051ec:	ffffc097          	auipc	ra,0xffffc
    800051f0:	398080e7          	jalr	920(ra) # 80001584 <uvmalloc>
    800051f4:	8c2a                	mv	s8,a0
  ip = 0;
    800051f6:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    800051f8:	12050e63          	beqz	a0,80005334 <exec+0x2d4>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    800051fc:	75f9                	lui	a1,0xffffe
    800051fe:	95aa                	add	a1,a1,a0
    80005200:	855a                	mv	a0,s6
    80005202:	ffffc097          	auipc	ra,0xffffc
    80005206:	5ac080e7          	jalr	1452(ra) # 800017ae <uvmclear>
  stackbase = sp - PGSIZE;
    8000520a:	7afd                	lui	s5,0xfffff
    8000520c:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    8000520e:	df043783          	ld	a5,-528(s0)
    80005212:	6388                	ld	a0,0(a5)
    80005214:	c925                	beqz	a0,80005284 <exec+0x224>
    80005216:	e9040993          	addi	s3,s0,-368
    8000521a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000521e:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005220:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005222:	ffffc097          	auipc	ra,0xffffc
    80005226:	da0080e7          	jalr	-608(ra) # 80000fc2 <strlen>
    8000522a:	0015079b          	addiw	a5,a0,1
    8000522e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005232:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    80005236:	13596663          	bltu	s2,s5,80005362 <exec+0x302>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000523a:	df043d83          	ld	s11,-528(s0)
    8000523e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005242:	8552                	mv	a0,s4
    80005244:	ffffc097          	auipc	ra,0xffffc
    80005248:	d7e080e7          	jalr	-642(ra) # 80000fc2 <strlen>
    8000524c:	0015069b          	addiw	a3,a0,1
    80005250:	8652                	mv	a2,s4
    80005252:	85ca                	mv	a1,s2
    80005254:	855a                	mv	a0,s6
    80005256:	ffffc097          	auipc	ra,0xffffc
    8000525a:	58a080e7          	jalr	1418(ra) # 800017e0 <copyout>
    8000525e:	10054663          	bltz	a0,8000536a <exec+0x30a>
    ustack[argc] = sp;
    80005262:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    80005266:	0485                	addi	s1,s1,1
    80005268:	008d8793          	addi	a5,s11,8
    8000526c:	def43823          	sd	a5,-528(s0)
    80005270:	008db503          	ld	a0,8(s11)
    80005274:	c911                	beqz	a0,80005288 <exec+0x228>
    if (argc >= MAXARG)
    80005276:	09a1                	addi	s3,s3,8
    80005278:	fb3c95e3          	bne	s9,s3,80005222 <exec+0x1c2>
  sz = sz1;
    8000527c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005280:	4a81                	li	s5,0
    80005282:	a84d                	j	80005334 <exec+0x2d4>
  sp = sz;
    80005284:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005286:	4481                	li	s1,0
  ustack[argc] = 0;
    80005288:	00349793          	slli	a5,s1,0x3
    8000528c:	f9078793          	addi	a5,a5,-112
    80005290:	97a2                	add	a5,a5,s0
    80005292:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80005296:	00148693          	addi	a3,s1,1
    8000529a:	068e                	slli	a3,a3,0x3
    8000529c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800052a0:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    800052a4:	01597663          	bgeu	s2,s5,800052b0 <exec+0x250>
  sz = sz1;
    800052a8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052ac:	4a81                	li	s5,0
    800052ae:	a059                	j	80005334 <exec+0x2d4>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    800052b0:	e9040613          	addi	a2,s0,-368
    800052b4:	85ca                	mv	a1,s2
    800052b6:	855a                	mv	a0,s6
    800052b8:	ffffc097          	auipc	ra,0xffffc
    800052bc:	528080e7          	jalr	1320(ra) # 800017e0 <copyout>
    800052c0:	0a054963          	bltz	a0,80005372 <exec+0x312>
  p->trapframe->a1 = sp;
    800052c4:	058bb783          	ld	a5,88(s7)
    800052c8:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    800052cc:	de843783          	ld	a5,-536(s0)
    800052d0:	0007c703          	lbu	a4,0(a5)
    800052d4:	cf11                	beqz	a4,800052f0 <exec+0x290>
    800052d6:	0785                	addi	a5,a5,1
    if (*s == '/')
    800052d8:	02f00693          	li	a3,47
    800052dc:	a039                	j	800052ea <exec+0x28a>
      last = s + 1;
    800052de:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    800052e2:	0785                	addi	a5,a5,1
    800052e4:	fff7c703          	lbu	a4,-1(a5)
    800052e8:	c701                	beqz	a4,800052f0 <exec+0x290>
    if (*s == '/')
    800052ea:	fed71ce3          	bne	a4,a3,800052e2 <exec+0x282>
    800052ee:	bfc5                	j	800052de <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800052f0:	4641                	li	a2,16
    800052f2:	de843583          	ld	a1,-536(s0)
    800052f6:	158b8513          	addi	a0,s7,344
    800052fa:	ffffc097          	auipc	ra,0xffffc
    800052fe:	c96080e7          	jalr	-874(ra) # 80000f90 <safestrcpy>
  oldpagetable = p->pagetable;
    80005302:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005306:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000530a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    8000530e:	058bb783          	ld	a5,88(s7)
    80005312:	e6843703          	ld	a4,-408(s0)
    80005316:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005318:	058bb783          	ld	a5,88(s7)
    8000531c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005320:	85ea                	mv	a1,s10
    80005322:	ffffd097          	auipc	ra,0xffffd
    80005326:	95e080e7          	jalr	-1698(ra) # 80001c80 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000532a:	0004851b          	sext.w	a0,s1
    8000532e:	b3f9                	j	800050fc <exec+0x9c>
    80005330:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005334:	df843583          	ld	a1,-520(s0)
    80005338:	855a                	mv	a0,s6
    8000533a:	ffffd097          	auipc	ra,0xffffd
    8000533e:	946080e7          	jalr	-1722(ra) # 80001c80 <proc_freepagetable>
  if (ip)
    80005342:	da0a93e3          	bnez	s5,800050e8 <exec+0x88>
  return -1;
    80005346:	557d                	li	a0,-1
    80005348:	bb55                	j	800050fc <exec+0x9c>
    8000534a:	df243c23          	sd	s2,-520(s0)
    8000534e:	b7dd                	j	80005334 <exec+0x2d4>
    80005350:	df243c23          	sd	s2,-520(s0)
    80005354:	b7c5                	j	80005334 <exec+0x2d4>
    80005356:	df243c23          	sd	s2,-520(s0)
    8000535a:	bfe9                	j	80005334 <exec+0x2d4>
    8000535c:	df243c23          	sd	s2,-520(s0)
    80005360:	bfd1                	j	80005334 <exec+0x2d4>
  sz = sz1;
    80005362:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005366:	4a81                	li	s5,0
    80005368:	b7f1                	j	80005334 <exec+0x2d4>
  sz = sz1;
    8000536a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000536e:	4a81                	li	s5,0
    80005370:	b7d1                	j	80005334 <exec+0x2d4>
  sz = sz1;
    80005372:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005376:	4a81                	li	s5,0
    80005378:	bf75                	j	80005334 <exec+0x2d4>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000537a:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    8000537e:	e0843783          	ld	a5,-504(s0)
    80005382:	0017869b          	addiw	a3,a5,1
    80005386:	e0d43423          	sd	a3,-504(s0)
    8000538a:	e0043783          	ld	a5,-512(s0)
    8000538e:	0387879b          	addiw	a5,a5,56
    80005392:	e8845703          	lhu	a4,-376(s0)
    80005396:	e0e6dfe3          	bge	a3,a4,800051b4 <exec+0x154>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000539a:	2781                	sext.w	a5,a5
    8000539c:	e0f43023          	sd	a5,-512(s0)
    800053a0:	03800713          	li	a4,56
    800053a4:	86be                	mv	a3,a5
    800053a6:	e1840613          	addi	a2,s0,-488
    800053aa:	4581                	li	a1,0
    800053ac:	8556                	mv	a0,s5
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	a58080e7          	jalr	-1448(ra) # 80003e06 <readi>
    800053b6:	03800793          	li	a5,56
    800053ba:	f6f51be3          	bne	a0,a5,80005330 <exec+0x2d0>
    if (ph.type != ELF_PROG_LOAD)
    800053be:	e1842783          	lw	a5,-488(s0)
    800053c2:	4705                	li	a4,1
    800053c4:	fae79de3          	bne	a5,a4,8000537e <exec+0x31e>
    if (ph.memsz < ph.filesz)
    800053c8:	e4043483          	ld	s1,-448(s0)
    800053cc:	e3843783          	ld	a5,-456(s0)
    800053d0:	f6f4ede3          	bltu	s1,a5,8000534a <exec+0x2ea>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    800053d4:	e2843783          	ld	a5,-472(s0)
    800053d8:	94be                	add	s1,s1,a5
    800053da:	f6f4ebe3          	bltu	s1,a5,80005350 <exec+0x2f0>
    if (ph.vaddr % PGSIZE != 0)
    800053de:	de043703          	ld	a4,-544(s0)
    800053e2:	8ff9                	and	a5,a5,a4
    800053e4:	fbad                	bnez	a5,80005356 <exec+0x2f6>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053e6:	e1c42503          	lw	a0,-484(s0)
    800053ea:	00000097          	auipc	ra,0x0
    800053ee:	c5c080e7          	jalr	-932(ra) # 80005046 <flags2perm>
    800053f2:	86aa                	mv	a3,a0
    800053f4:	8626                	mv	a2,s1
    800053f6:	85ca                	mv	a1,s2
    800053f8:	855a                	mv	a0,s6
    800053fa:	ffffc097          	auipc	ra,0xffffc
    800053fe:	18a080e7          	jalr	394(ra) # 80001584 <uvmalloc>
    80005402:	dea43c23          	sd	a0,-520(s0)
    80005406:	d939                	beqz	a0,8000535c <exec+0x2fc>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005408:	e2843c03          	ld	s8,-472(s0)
    8000540c:	e2042c83          	lw	s9,-480(s0)
    80005410:	e3842b83          	lw	s7,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    80005414:	f60b83e3          	beqz	s7,8000537a <exec+0x31a>
    80005418:	89de                	mv	s3,s7
    8000541a:	4481                	li	s1,0
    8000541c:	bb9d                	j	80005192 <exec+0x132>

000000008000541e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000541e:	7179                	addi	sp,sp,-48
    80005420:	f406                	sd	ra,40(sp)
    80005422:	f022                	sd	s0,32(sp)
    80005424:	ec26                	sd	s1,24(sp)
    80005426:	e84a                	sd	s2,16(sp)
    80005428:	1800                	addi	s0,sp,48
    8000542a:	892e                	mv	s2,a1
    8000542c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000542e:	fdc40593          	addi	a1,s0,-36
    80005432:	ffffe097          	auipc	ra,0xffffe
    80005436:	a7c080e7          	jalr	-1412(ra) # 80002eae <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    8000543a:	fdc42703          	lw	a4,-36(s0)
    8000543e:	47bd                	li	a5,15
    80005440:	02e7eb63          	bltu	a5,a4,80005476 <argfd+0x58>
    80005444:	ffffc097          	auipc	ra,0xffffc
    80005448:	6dc080e7          	jalr	1756(ra) # 80001b20 <myproc>
    8000544c:	fdc42703          	lw	a4,-36(s0)
    80005450:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7fdb9cfa>
    80005454:	078e                	slli	a5,a5,0x3
    80005456:	953e                	add	a0,a0,a5
    80005458:	611c                	ld	a5,0(a0)
    8000545a:	c385                	beqz	a5,8000547a <argfd+0x5c>
    return -1;
  if (pfd)
    8000545c:	00090463          	beqz	s2,80005464 <argfd+0x46>
    *pfd = fd;
    80005460:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80005464:	4501                	li	a0,0
  if (pf)
    80005466:	c091                	beqz	s1,8000546a <argfd+0x4c>
    *pf = f;
    80005468:	e09c                	sd	a5,0(s1)
}
    8000546a:	70a2                	ld	ra,40(sp)
    8000546c:	7402                	ld	s0,32(sp)
    8000546e:	64e2                	ld	s1,24(sp)
    80005470:	6942                	ld	s2,16(sp)
    80005472:	6145                	addi	sp,sp,48
    80005474:	8082                	ret
    return -1;
    80005476:	557d                	li	a0,-1
    80005478:	bfcd                	j	8000546a <argfd+0x4c>
    8000547a:	557d                	li	a0,-1
    8000547c:	b7fd                	j	8000546a <argfd+0x4c>

000000008000547e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000547e:	1101                	addi	sp,sp,-32
    80005480:	ec06                	sd	ra,24(sp)
    80005482:	e822                	sd	s0,16(sp)
    80005484:	e426                	sd	s1,8(sp)
    80005486:	1000                	addi	s0,sp,32
    80005488:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000548a:	ffffc097          	auipc	ra,0xffffc
    8000548e:	696080e7          	jalr	1686(ra) # 80001b20 <myproc>
    80005492:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++)
    80005494:	0d050793          	addi	a5,a0,208
    80005498:	4501                	li	a0,0
    8000549a:	46c1                	li	a3,16
  {
    if (p->ofile[fd] == 0)
    8000549c:	6398                	ld	a4,0(a5)
    8000549e:	cb19                	beqz	a4,800054b4 <fdalloc+0x36>
  for (fd = 0; fd < NOFILE; fd++)
    800054a0:	2505                	addiw	a0,a0,1
    800054a2:	07a1                	addi	a5,a5,8
    800054a4:	fed51ce3          	bne	a0,a3,8000549c <fdalloc+0x1e>
    {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800054a8:	557d                	li	a0,-1
}
    800054aa:	60e2                	ld	ra,24(sp)
    800054ac:	6442                	ld	s0,16(sp)
    800054ae:	64a2                	ld	s1,8(sp)
    800054b0:	6105                	addi	sp,sp,32
    800054b2:	8082                	ret
      p->ofile[fd] = f;
    800054b4:	01a50793          	addi	a5,a0,26
    800054b8:	078e                	slli	a5,a5,0x3
    800054ba:	963e                	add	a2,a2,a5
    800054bc:	e204                	sd	s1,0(a2)
      return fd;
    800054be:	b7f5                	j	800054aa <fdalloc+0x2c>

00000000800054c0 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    800054c0:	715d                	addi	sp,sp,-80
    800054c2:	e486                	sd	ra,72(sp)
    800054c4:	e0a2                	sd	s0,64(sp)
    800054c6:	fc26                	sd	s1,56(sp)
    800054c8:	f84a                	sd	s2,48(sp)
    800054ca:	f44e                	sd	s3,40(sp)
    800054cc:	f052                	sd	s4,32(sp)
    800054ce:	ec56                	sd	s5,24(sp)
    800054d0:	e85a                	sd	s6,16(sp)
    800054d2:	0880                	addi	s0,sp,80
    800054d4:	8b2e                	mv	s6,a1
    800054d6:	89b2                	mv	s3,a2
    800054d8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    800054da:	fb040593          	addi	a1,s0,-80
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	e3e080e7          	jalr	-450(ra) # 8000431c <nameiparent>
    800054e6:	84aa                	mv	s1,a0
    800054e8:	14050f63          	beqz	a0,80005646 <create+0x186>
    return 0;

  ilock(dp);
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	666080e7          	jalr	1638(ra) # 80003b52 <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0)
    800054f4:	4601                	li	a2,0
    800054f6:	fb040593          	addi	a1,s0,-80
    800054fa:	8526                	mv	a0,s1
    800054fc:	fffff097          	auipc	ra,0xfffff
    80005500:	b3a080e7          	jalr	-1222(ra) # 80004036 <dirlookup>
    80005504:	8aaa                	mv	s5,a0
    80005506:	c931                	beqz	a0,8000555a <create+0x9a>
  {
    iunlockput(dp);
    80005508:	8526                	mv	a0,s1
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	8aa080e7          	jalr	-1878(ra) # 80003db4 <iunlockput>
    ilock(ip);
    80005512:	8556                	mv	a0,s5
    80005514:	ffffe097          	auipc	ra,0xffffe
    80005518:	63e080e7          	jalr	1598(ra) # 80003b52 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000551c:	000b059b          	sext.w	a1,s6
    80005520:	4789                	li	a5,2
    80005522:	02f59563          	bne	a1,a5,8000554c <create+0x8c>
    80005526:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fdb9d24>
    8000552a:	37f9                	addiw	a5,a5,-2
    8000552c:	17c2                	slli	a5,a5,0x30
    8000552e:	93c1                	srli	a5,a5,0x30
    80005530:	4705                	li	a4,1
    80005532:	00f76d63          	bltu	a4,a5,8000554c <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005536:	8556                	mv	a0,s5
    80005538:	60a6                	ld	ra,72(sp)
    8000553a:	6406                	ld	s0,64(sp)
    8000553c:	74e2                	ld	s1,56(sp)
    8000553e:	7942                	ld	s2,48(sp)
    80005540:	79a2                	ld	s3,40(sp)
    80005542:	7a02                	ld	s4,32(sp)
    80005544:	6ae2                	ld	s5,24(sp)
    80005546:	6b42                	ld	s6,16(sp)
    80005548:	6161                	addi	sp,sp,80
    8000554a:	8082                	ret
    iunlockput(ip);
    8000554c:	8556                	mv	a0,s5
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	866080e7          	jalr	-1946(ra) # 80003db4 <iunlockput>
    return 0;
    80005556:	4a81                	li	s5,0
    80005558:	bff9                	j	80005536 <create+0x76>
  if ((ip = ialloc(dp->dev, type)) == 0)
    8000555a:	85da                	mv	a1,s6
    8000555c:	4088                	lw	a0,0(s1)
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	456080e7          	jalr	1110(ra) # 800039b4 <ialloc>
    80005566:	8a2a                	mv	s4,a0
    80005568:	c539                	beqz	a0,800055b6 <create+0xf6>
  ilock(ip);
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	5e8080e7          	jalr	1512(ra) # 80003b52 <ilock>
  ip->major = major;
    80005572:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005576:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000557a:	4905                	li	s2,1
    8000557c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005580:	8552                	mv	a0,s4
    80005582:	ffffe097          	auipc	ra,0xffffe
    80005586:	504080e7          	jalr	1284(ra) # 80003a86 <iupdate>
  if (type == T_DIR)
    8000558a:	000b059b          	sext.w	a1,s6
    8000558e:	03258b63          	beq	a1,s2,800055c4 <create+0x104>
  if (dirlink(dp, name, ip->inum) < 0)
    80005592:	004a2603          	lw	a2,4(s4)
    80005596:	fb040593          	addi	a1,s0,-80
    8000559a:	8526                	mv	a0,s1
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	cb0080e7          	jalr	-848(ra) # 8000424c <dirlink>
    800055a4:	06054f63          	bltz	a0,80005622 <create+0x162>
  iunlockput(dp);
    800055a8:	8526                	mv	a0,s1
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	80a080e7          	jalr	-2038(ra) # 80003db4 <iunlockput>
  return ip;
    800055b2:	8ad2                	mv	s5,s4
    800055b4:	b749                	j	80005536 <create+0x76>
    iunlockput(dp);
    800055b6:	8526                	mv	a0,s1
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	7fc080e7          	jalr	2044(ra) # 80003db4 <iunlockput>
    return 0;
    800055c0:	8ad2                	mv	s5,s4
    800055c2:	bf95                	j	80005536 <create+0x76>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800055c4:	004a2603          	lw	a2,4(s4)
    800055c8:	00003597          	auipc	a1,0x3
    800055cc:	24858593          	addi	a1,a1,584 # 80008810 <syscalls+0x2b0>
    800055d0:	8552                	mv	a0,s4
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	c7a080e7          	jalr	-902(ra) # 8000424c <dirlink>
    800055da:	04054463          	bltz	a0,80005622 <create+0x162>
    800055de:	40d0                	lw	a2,4(s1)
    800055e0:	00003597          	auipc	a1,0x3
    800055e4:	23858593          	addi	a1,a1,568 # 80008818 <syscalls+0x2b8>
    800055e8:	8552                	mv	a0,s4
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	c62080e7          	jalr	-926(ra) # 8000424c <dirlink>
    800055f2:	02054863          	bltz	a0,80005622 <create+0x162>
  if (dirlink(dp, name, ip->inum) < 0)
    800055f6:	004a2603          	lw	a2,4(s4)
    800055fa:	fb040593          	addi	a1,s0,-80
    800055fe:	8526                	mv	a0,s1
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	c4c080e7          	jalr	-948(ra) # 8000424c <dirlink>
    80005608:	00054d63          	bltz	a0,80005622 <create+0x162>
    dp->nlink++; // for ".."
    8000560c:	04a4d783          	lhu	a5,74(s1)
    80005610:	2785                	addiw	a5,a5,1
    80005612:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005616:	8526                	mv	a0,s1
    80005618:	ffffe097          	auipc	ra,0xffffe
    8000561c:	46e080e7          	jalr	1134(ra) # 80003a86 <iupdate>
    80005620:	b761                	j	800055a8 <create+0xe8>
  ip->nlink = 0;
    80005622:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005626:	8552                	mv	a0,s4
    80005628:	ffffe097          	auipc	ra,0xffffe
    8000562c:	45e080e7          	jalr	1118(ra) # 80003a86 <iupdate>
  iunlockput(ip);
    80005630:	8552                	mv	a0,s4
    80005632:	ffffe097          	auipc	ra,0xffffe
    80005636:	782080e7          	jalr	1922(ra) # 80003db4 <iunlockput>
  iunlockput(dp);
    8000563a:	8526                	mv	a0,s1
    8000563c:	ffffe097          	auipc	ra,0xffffe
    80005640:	778080e7          	jalr	1912(ra) # 80003db4 <iunlockput>
  return 0;
    80005644:	bdcd                	j	80005536 <create+0x76>
    return 0;
    80005646:	8aaa                	mv	s5,a0
    80005648:	b5fd                	j	80005536 <create+0x76>

000000008000564a <sys_dup>:
{
    8000564a:	7179                	addi	sp,sp,-48
    8000564c:	f406                	sd	ra,40(sp)
    8000564e:	f022                	sd	s0,32(sp)
    80005650:	ec26                	sd	s1,24(sp)
    80005652:	e84a                	sd	s2,16(sp)
    80005654:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80005656:	fd840613          	addi	a2,s0,-40
    8000565a:	4581                	li	a1,0
    8000565c:	4501                	li	a0,0
    8000565e:	00000097          	auipc	ra,0x0
    80005662:	dc0080e7          	jalr	-576(ra) # 8000541e <argfd>
    return -1;
    80005666:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80005668:	02054363          	bltz	a0,8000568e <sys_dup+0x44>
  if ((fd = fdalloc(f)) < 0)
    8000566c:	fd843903          	ld	s2,-40(s0)
    80005670:	854a                	mv	a0,s2
    80005672:	00000097          	auipc	ra,0x0
    80005676:	e0c080e7          	jalr	-500(ra) # 8000547e <fdalloc>
    8000567a:	84aa                	mv	s1,a0
    return -1;
    8000567c:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    8000567e:	00054863          	bltz	a0,8000568e <sys_dup+0x44>
  filedup(f);
    80005682:	854a                	mv	a0,s2
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	310080e7          	jalr	784(ra) # 80004994 <filedup>
  return fd;
    8000568c:	87a6                	mv	a5,s1
}
    8000568e:	853e                	mv	a0,a5
    80005690:	70a2                	ld	ra,40(sp)
    80005692:	7402                	ld	s0,32(sp)
    80005694:	64e2                	ld	s1,24(sp)
    80005696:	6942                	ld	s2,16(sp)
    80005698:	6145                	addi	sp,sp,48
    8000569a:	8082                	ret

000000008000569c <sys_read>:
{
    8000569c:	7179                	addi	sp,sp,-48
    8000569e:	f406                	sd	ra,40(sp)
    800056a0:	f022                	sd	s0,32(sp)
    800056a2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056a4:	fd840593          	addi	a1,s0,-40
    800056a8:	4505                	li	a0,1
    800056aa:	ffffe097          	auipc	ra,0xffffe
    800056ae:	824080e7          	jalr	-2012(ra) # 80002ece <argaddr>
  argint(2, &n);
    800056b2:	fe440593          	addi	a1,s0,-28
    800056b6:	4509                	li	a0,2
    800056b8:	ffffd097          	auipc	ra,0xffffd
    800056bc:	7f6080e7          	jalr	2038(ra) # 80002eae <argint>
  if (argfd(0, 0, &f) < 0)
    800056c0:	fe840613          	addi	a2,s0,-24
    800056c4:	4581                	li	a1,0
    800056c6:	4501                	li	a0,0
    800056c8:	00000097          	auipc	ra,0x0
    800056cc:	d56080e7          	jalr	-682(ra) # 8000541e <argfd>
    800056d0:	87aa                	mv	a5,a0
    return -1;
    800056d2:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800056d4:	0007cc63          	bltz	a5,800056ec <sys_read+0x50>
  return fileread(f, p, n);
    800056d8:	fe442603          	lw	a2,-28(s0)
    800056dc:	fd843583          	ld	a1,-40(s0)
    800056e0:	fe843503          	ld	a0,-24(s0)
    800056e4:	fffff097          	auipc	ra,0xfffff
    800056e8:	43c080e7          	jalr	1084(ra) # 80004b20 <fileread>
}
    800056ec:	70a2                	ld	ra,40(sp)
    800056ee:	7402                	ld	s0,32(sp)
    800056f0:	6145                	addi	sp,sp,48
    800056f2:	8082                	ret

00000000800056f4 <sys_write>:
{
    800056f4:	7179                	addi	sp,sp,-48
    800056f6:	f406                	sd	ra,40(sp)
    800056f8:	f022                	sd	s0,32(sp)
    800056fa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056fc:	fd840593          	addi	a1,s0,-40
    80005700:	4505                	li	a0,1
    80005702:	ffffd097          	auipc	ra,0xffffd
    80005706:	7cc080e7          	jalr	1996(ra) # 80002ece <argaddr>
  argint(2, &n);
    8000570a:	fe440593          	addi	a1,s0,-28
    8000570e:	4509                	li	a0,2
    80005710:	ffffd097          	auipc	ra,0xffffd
    80005714:	79e080e7          	jalr	1950(ra) # 80002eae <argint>
  if (argfd(0, 0, &f) < 0)
    80005718:	fe840613          	addi	a2,s0,-24
    8000571c:	4581                	li	a1,0
    8000571e:	4501                	li	a0,0
    80005720:	00000097          	auipc	ra,0x0
    80005724:	cfe080e7          	jalr	-770(ra) # 8000541e <argfd>
    80005728:	87aa                	mv	a5,a0
    return -1;
    8000572a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000572c:	0007cc63          	bltz	a5,80005744 <sys_write+0x50>
  return filewrite(f, p, n);
    80005730:	fe442603          	lw	a2,-28(s0)
    80005734:	fd843583          	ld	a1,-40(s0)
    80005738:	fe843503          	ld	a0,-24(s0)
    8000573c:	fffff097          	auipc	ra,0xfffff
    80005740:	4a6080e7          	jalr	1190(ra) # 80004be2 <filewrite>
}
    80005744:	70a2                	ld	ra,40(sp)
    80005746:	7402                	ld	s0,32(sp)
    80005748:	6145                	addi	sp,sp,48
    8000574a:	8082                	ret

000000008000574c <sys_close>:
{
    8000574c:	1101                	addi	sp,sp,-32
    8000574e:	ec06                	sd	ra,24(sp)
    80005750:	e822                	sd	s0,16(sp)
    80005752:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005754:	fe040613          	addi	a2,s0,-32
    80005758:	fec40593          	addi	a1,s0,-20
    8000575c:	4501                	li	a0,0
    8000575e:	00000097          	auipc	ra,0x0
    80005762:	cc0080e7          	jalr	-832(ra) # 8000541e <argfd>
    return -1;
    80005766:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005768:	02054463          	bltz	a0,80005790 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000576c:	ffffc097          	auipc	ra,0xffffc
    80005770:	3b4080e7          	jalr	948(ra) # 80001b20 <myproc>
    80005774:	fec42783          	lw	a5,-20(s0)
    80005778:	07e9                	addi	a5,a5,26
    8000577a:	078e                	slli	a5,a5,0x3
    8000577c:	953e                	add	a0,a0,a5
    8000577e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005782:	fe043503          	ld	a0,-32(s0)
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	260080e7          	jalr	608(ra) # 800049e6 <fileclose>
  return 0;
    8000578e:	4781                	li	a5,0
}
    80005790:	853e                	mv	a0,a5
    80005792:	60e2                	ld	ra,24(sp)
    80005794:	6442                	ld	s0,16(sp)
    80005796:	6105                	addi	sp,sp,32
    80005798:	8082                	ret

000000008000579a <sys_fstat>:
{
    8000579a:	1101                	addi	sp,sp,-32
    8000579c:	ec06                	sd	ra,24(sp)
    8000579e:	e822                	sd	s0,16(sp)
    800057a0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800057a2:	fe040593          	addi	a1,s0,-32
    800057a6:	4505                	li	a0,1
    800057a8:	ffffd097          	auipc	ra,0xffffd
    800057ac:	726080e7          	jalr	1830(ra) # 80002ece <argaddr>
  if (argfd(0, 0, &f) < 0)
    800057b0:	fe840613          	addi	a2,s0,-24
    800057b4:	4581                	li	a1,0
    800057b6:	4501                	li	a0,0
    800057b8:	00000097          	auipc	ra,0x0
    800057bc:	c66080e7          	jalr	-922(ra) # 8000541e <argfd>
    800057c0:	87aa                	mv	a5,a0
    return -1;
    800057c2:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800057c4:	0007ca63          	bltz	a5,800057d8 <sys_fstat+0x3e>
  return filestat(f, st);
    800057c8:	fe043583          	ld	a1,-32(s0)
    800057cc:	fe843503          	ld	a0,-24(s0)
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	2de080e7          	jalr	734(ra) # 80004aae <filestat>
}
    800057d8:	60e2                	ld	ra,24(sp)
    800057da:	6442                	ld	s0,16(sp)
    800057dc:	6105                	addi	sp,sp,32
    800057de:	8082                	ret

00000000800057e0 <sys_link>:
{
    800057e0:	7169                	addi	sp,sp,-304
    800057e2:	f606                	sd	ra,296(sp)
    800057e4:	f222                	sd	s0,288(sp)
    800057e6:	ee26                	sd	s1,280(sp)
    800057e8:	ea4a                	sd	s2,272(sp)
    800057ea:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057ec:	08000613          	li	a2,128
    800057f0:	ed040593          	addi	a1,s0,-304
    800057f4:	4501                	li	a0,0
    800057f6:	ffffd097          	auipc	ra,0xffffd
    800057fa:	6f8080e7          	jalr	1784(ra) # 80002eee <argstr>
    return -1;
    800057fe:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005800:	10054e63          	bltz	a0,8000591c <sys_link+0x13c>
    80005804:	08000613          	li	a2,128
    80005808:	f5040593          	addi	a1,s0,-176
    8000580c:	4505                	li	a0,1
    8000580e:	ffffd097          	auipc	ra,0xffffd
    80005812:	6e0080e7          	jalr	1760(ra) # 80002eee <argstr>
    return -1;
    80005816:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005818:	10054263          	bltz	a0,8000591c <sys_link+0x13c>
  begin_op();
    8000581c:	fffff097          	auipc	ra,0xfffff
    80005820:	d02080e7          	jalr	-766(ra) # 8000451e <begin_op>
  if ((ip = namei(old)) == 0)
    80005824:	ed040513          	addi	a0,s0,-304
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	ad6080e7          	jalr	-1322(ra) # 800042fe <namei>
    80005830:	84aa                	mv	s1,a0
    80005832:	c551                	beqz	a0,800058be <sys_link+0xde>
  ilock(ip);
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	31e080e7          	jalr	798(ra) # 80003b52 <ilock>
  if (ip->type == T_DIR)
    8000583c:	04449703          	lh	a4,68(s1)
    80005840:	4785                	li	a5,1
    80005842:	08f70463          	beq	a4,a5,800058ca <sys_link+0xea>
  ip->nlink++;
    80005846:	04a4d783          	lhu	a5,74(s1)
    8000584a:	2785                	addiw	a5,a5,1
    8000584c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005850:	8526                	mv	a0,s1
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	234080e7          	jalr	564(ra) # 80003a86 <iupdate>
  iunlock(ip);
    8000585a:	8526                	mv	a0,s1
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	3b8080e7          	jalr	952(ra) # 80003c14 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005864:	fd040593          	addi	a1,s0,-48
    80005868:	f5040513          	addi	a0,s0,-176
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	ab0080e7          	jalr	-1360(ra) # 8000431c <nameiparent>
    80005874:	892a                	mv	s2,a0
    80005876:	c935                	beqz	a0,800058ea <sys_link+0x10a>
  ilock(dp);
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	2da080e7          	jalr	730(ra) # 80003b52 <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0)
    80005880:	00092703          	lw	a4,0(s2)
    80005884:	409c                	lw	a5,0(s1)
    80005886:	04f71d63          	bne	a4,a5,800058e0 <sys_link+0x100>
    8000588a:	40d0                	lw	a2,4(s1)
    8000588c:	fd040593          	addi	a1,s0,-48
    80005890:	854a                	mv	a0,s2
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	9ba080e7          	jalr	-1606(ra) # 8000424c <dirlink>
    8000589a:	04054363          	bltz	a0,800058e0 <sys_link+0x100>
  iunlockput(dp);
    8000589e:	854a                	mv	a0,s2
    800058a0:	ffffe097          	auipc	ra,0xffffe
    800058a4:	514080e7          	jalr	1300(ra) # 80003db4 <iunlockput>
  iput(ip);
    800058a8:	8526                	mv	a0,s1
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	462080e7          	jalr	1122(ra) # 80003d0c <iput>
  end_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	cea080e7          	jalr	-790(ra) # 8000459c <end_op>
  return 0;
    800058ba:	4781                	li	a5,0
    800058bc:	a085                	j	8000591c <sys_link+0x13c>
    end_op();
    800058be:	fffff097          	auipc	ra,0xfffff
    800058c2:	cde080e7          	jalr	-802(ra) # 8000459c <end_op>
    return -1;
    800058c6:	57fd                	li	a5,-1
    800058c8:	a891                	j	8000591c <sys_link+0x13c>
    iunlockput(ip);
    800058ca:	8526                	mv	a0,s1
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	4e8080e7          	jalr	1256(ra) # 80003db4 <iunlockput>
    end_op();
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	cc8080e7          	jalr	-824(ra) # 8000459c <end_op>
    return -1;
    800058dc:	57fd                	li	a5,-1
    800058de:	a83d                	j	8000591c <sys_link+0x13c>
    iunlockput(dp);
    800058e0:	854a                	mv	a0,s2
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	4d2080e7          	jalr	1234(ra) # 80003db4 <iunlockput>
  ilock(ip);
    800058ea:	8526                	mv	a0,s1
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	266080e7          	jalr	614(ra) # 80003b52 <ilock>
  ip->nlink--;
    800058f4:	04a4d783          	lhu	a5,74(s1)
    800058f8:	37fd                	addiw	a5,a5,-1
    800058fa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058fe:	8526                	mv	a0,s1
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	186080e7          	jalr	390(ra) # 80003a86 <iupdate>
  iunlockput(ip);
    80005908:	8526                	mv	a0,s1
    8000590a:	ffffe097          	auipc	ra,0xffffe
    8000590e:	4aa080e7          	jalr	1194(ra) # 80003db4 <iunlockput>
  end_op();
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	c8a080e7          	jalr	-886(ra) # 8000459c <end_op>
  return -1;
    8000591a:	57fd                	li	a5,-1
}
    8000591c:	853e                	mv	a0,a5
    8000591e:	70b2                	ld	ra,296(sp)
    80005920:	7412                	ld	s0,288(sp)
    80005922:	64f2                	ld	s1,280(sp)
    80005924:	6952                	ld	s2,272(sp)
    80005926:	6155                	addi	sp,sp,304
    80005928:	8082                	ret

000000008000592a <sys_unlink>:
{
    8000592a:	7151                	addi	sp,sp,-240
    8000592c:	f586                	sd	ra,232(sp)
    8000592e:	f1a2                	sd	s0,224(sp)
    80005930:	eda6                	sd	s1,216(sp)
    80005932:	e9ca                	sd	s2,208(sp)
    80005934:	e5ce                	sd	s3,200(sp)
    80005936:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005938:	08000613          	li	a2,128
    8000593c:	f3040593          	addi	a1,s0,-208
    80005940:	4501                	li	a0,0
    80005942:	ffffd097          	auipc	ra,0xffffd
    80005946:	5ac080e7          	jalr	1452(ra) # 80002eee <argstr>
    8000594a:	18054163          	bltz	a0,80005acc <sys_unlink+0x1a2>
  begin_op();
    8000594e:	fffff097          	auipc	ra,0xfffff
    80005952:	bd0080e7          	jalr	-1072(ra) # 8000451e <begin_op>
  if ((dp = nameiparent(path, name)) == 0)
    80005956:	fb040593          	addi	a1,s0,-80
    8000595a:	f3040513          	addi	a0,s0,-208
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	9be080e7          	jalr	-1602(ra) # 8000431c <nameiparent>
    80005966:	84aa                	mv	s1,a0
    80005968:	c979                	beqz	a0,80005a3e <sys_unlink+0x114>
  ilock(dp);
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	1e8080e7          	jalr	488(ra) # 80003b52 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005972:	00003597          	auipc	a1,0x3
    80005976:	e9e58593          	addi	a1,a1,-354 # 80008810 <syscalls+0x2b0>
    8000597a:	fb040513          	addi	a0,s0,-80
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	69e080e7          	jalr	1694(ra) # 8000401c <namecmp>
    80005986:	14050a63          	beqz	a0,80005ada <sys_unlink+0x1b0>
    8000598a:	00003597          	auipc	a1,0x3
    8000598e:	e8e58593          	addi	a1,a1,-370 # 80008818 <syscalls+0x2b8>
    80005992:	fb040513          	addi	a0,s0,-80
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	686080e7          	jalr	1670(ra) # 8000401c <namecmp>
    8000599e:	12050e63          	beqz	a0,80005ada <sys_unlink+0x1b0>
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800059a2:	f2c40613          	addi	a2,s0,-212
    800059a6:	fb040593          	addi	a1,s0,-80
    800059aa:	8526                	mv	a0,s1
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	68a080e7          	jalr	1674(ra) # 80004036 <dirlookup>
    800059b4:	892a                	mv	s2,a0
    800059b6:	12050263          	beqz	a0,80005ada <sys_unlink+0x1b0>
  ilock(ip);
    800059ba:	ffffe097          	auipc	ra,0xffffe
    800059be:	198080e7          	jalr	408(ra) # 80003b52 <ilock>
  if (ip->nlink < 1)
    800059c2:	04a91783          	lh	a5,74(s2)
    800059c6:	08f05263          	blez	a5,80005a4a <sys_unlink+0x120>
  if (ip->type == T_DIR && !isdirempty(ip))
    800059ca:	04491703          	lh	a4,68(s2)
    800059ce:	4785                	li	a5,1
    800059d0:	08f70563          	beq	a4,a5,80005a5a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800059d4:	4641                	li	a2,16
    800059d6:	4581                	li	a1,0
    800059d8:	fc040513          	addi	a0,s0,-64
    800059dc:	ffffb097          	auipc	ra,0xffffb
    800059e0:	46a080e7          	jalr	1130(ra) # 80000e46 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059e4:	4741                	li	a4,16
    800059e6:	f2c42683          	lw	a3,-212(s0)
    800059ea:	fc040613          	addi	a2,s0,-64
    800059ee:	4581                	li	a1,0
    800059f0:	8526                	mv	a0,s1
    800059f2:	ffffe097          	auipc	ra,0xffffe
    800059f6:	50c080e7          	jalr	1292(ra) # 80003efe <writei>
    800059fa:	47c1                	li	a5,16
    800059fc:	0af51563          	bne	a0,a5,80005aa6 <sys_unlink+0x17c>
  if (ip->type == T_DIR)
    80005a00:	04491703          	lh	a4,68(s2)
    80005a04:	4785                	li	a5,1
    80005a06:	0af70863          	beq	a4,a5,80005ab6 <sys_unlink+0x18c>
  iunlockput(dp);
    80005a0a:	8526                	mv	a0,s1
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	3a8080e7          	jalr	936(ra) # 80003db4 <iunlockput>
  ip->nlink--;
    80005a14:	04a95783          	lhu	a5,74(s2)
    80005a18:	37fd                	addiw	a5,a5,-1
    80005a1a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a1e:	854a                	mv	a0,s2
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	066080e7          	jalr	102(ra) # 80003a86 <iupdate>
  iunlockput(ip);
    80005a28:	854a                	mv	a0,s2
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	38a080e7          	jalr	906(ra) # 80003db4 <iunlockput>
  end_op();
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	b6a080e7          	jalr	-1174(ra) # 8000459c <end_op>
  return 0;
    80005a3a:	4501                	li	a0,0
    80005a3c:	a84d                	j	80005aee <sys_unlink+0x1c4>
    end_op();
    80005a3e:	fffff097          	auipc	ra,0xfffff
    80005a42:	b5e080e7          	jalr	-1186(ra) # 8000459c <end_op>
    return -1;
    80005a46:	557d                	li	a0,-1
    80005a48:	a05d                	j	80005aee <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a4a:	00003517          	auipc	a0,0x3
    80005a4e:	dd650513          	addi	a0,a0,-554 # 80008820 <syscalls+0x2c0>
    80005a52:	ffffb097          	auipc	ra,0xffffb
    80005a56:	aee080e7          	jalr	-1298(ra) # 80000540 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005a5a:	04c92703          	lw	a4,76(s2)
    80005a5e:	02000793          	li	a5,32
    80005a62:	f6e7f9e3          	bgeu	a5,a4,800059d4 <sys_unlink+0xaa>
    80005a66:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a6a:	4741                	li	a4,16
    80005a6c:	86ce                	mv	a3,s3
    80005a6e:	f1840613          	addi	a2,s0,-232
    80005a72:	4581                	li	a1,0
    80005a74:	854a                	mv	a0,s2
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	390080e7          	jalr	912(ra) # 80003e06 <readi>
    80005a7e:	47c1                	li	a5,16
    80005a80:	00f51b63          	bne	a0,a5,80005a96 <sys_unlink+0x16c>
    if (de.inum != 0)
    80005a84:	f1845783          	lhu	a5,-232(s0)
    80005a88:	e7a1                	bnez	a5,80005ad0 <sys_unlink+0x1a6>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005a8a:	29c1                	addiw	s3,s3,16
    80005a8c:	04c92783          	lw	a5,76(s2)
    80005a90:	fcf9ede3          	bltu	s3,a5,80005a6a <sys_unlink+0x140>
    80005a94:	b781                	j	800059d4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a96:	00003517          	auipc	a0,0x3
    80005a9a:	da250513          	addi	a0,a0,-606 # 80008838 <syscalls+0x2d8>
    80005a9e:	ffffb097          	auipc	ra,0xffffb
    80005aa2:	aa2080e7          	jalr	-1374(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005aa6:	00003517          	auipc	a0,0x3
    80005aaa:	daa50513          	addi	a0,a0,-598 # 80008850 <syscalls+0x2f0>
    80005aae:	ffffb097          	auipc	ra,0xffffb
    80005ab2:	a92080e7          	jalr	-1390(ra) # 80000540 <panic>
    dp->nlink--;
    80005ab6:	04a4d783          	lhu	a5,74(s1)
    80005aba:	37fd                	addiw	a5,a5,-1
    80005abc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ac0:	8526                	mv	a0,s1
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	fc4080e7          	jalr	-60(ra) # 80003a86 <iupdate>
    80005aca:	b781                	j	80005a0a <sys_unlink+0xe0>
    return -1;
    80005acc:	557d                	li	a0,-1
    80005ace:	a005                	j	80005aee <sys_unlink+0x1c4>
    iunlockput(ip);
    80005ad0:	854a                	mv	a0,s2
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	2e2080e7          	jalr	738(ra) # 80003db4 <iunlockput>
  iunlockput(dp);
    80005ada:	8526                	mv	a0,s1
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	2d8080e7          	jalr	728(ra) # 80003db4 <iunlockput>
  end_op();
    80005ae4:	fffff097          	auipc	ra,0xfffff
    80005ae8:	ab8080e7          	jalr	-1352(ra) # 8000459c <end_op>
  return -1;
    80005aec:	557d                	li	a0,-1
}
    80005aee:	70ae                	ld	ra,232(sp)
    80005af0:	740e                	ld	s0,224(sp)
    80005af2:	64ee                	ld	s1,216(sp)
    80005af4:	694e                	ld	s2,208(sp)
    80005af6:	69ae                	ld	s3,200(sp)
    80005af8:	616d                	addi	sp,sp,240
    80005afa:	8082                	ret

0000000080005afc <sys_open>:

uint64
sys_open(void)
{
    80005afc:	7131                	addi	sp,sp,-192
    80005afe:	fd06                	sd	ra,184(sp)
    80005b00:	f922                	sd	s0,176(sp)
    80005b02:	f526                	sd	s1,168(sp)
    80005b04:	f14a                	sd	s2,160(sp)
    80005b06:	ed4e                	sd	s3,152(sp)
    80005b08:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b0a:	f4c40593          	addi	a1,s0,-180
    80005b0e:	4505                	li	a0,1
    80005b10:	ffffd097          	auipc	ra,0xffffd
    80005b14:	39e080e7          	jalr	926(ra) # 80002eae <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005b18:	08000613          	li	a2,128
    80005b1c:	f5040593          	addi	a1,s0,-176
    80005b20:	4501                	li	a0,0
    80005b22:	ffffd097          	auipc	ra,0xffffd
    80005b26:	3cc080e7          	jalr	972(ra) # 80002eee <argstr>
    80005b2a:	87aa                	mv	a5,a0
    return -1;
    80005b2c:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005b2e:	0a07c963          	bltz	a5,80005be0 <sys_open+0xe4>

  begin_op();
    80005b32:	fffff097          	auipc	ra,0xfffff
    80005b36:	9ec080e7          	jalr	-1556(ra) # 8000451e <begin_op>

  if (omode & O_CREATE)
    80005b3a:	f4c42783          	lw	a5,-180(s0)
    80005b3e:	2007f793          	andi	a5,a5,512
    80005b42:	cfc5                	beqz	a5,80005bfa <sys_open+0xfe>
  {
    ip = create(path, T_FILE, 0, 0);
    80005b44:	4681                	li	a3,0
    80005b46:	4601                	li	a2,0
    80005b48:	4589                	li	a1,2
    80005b4a:	f5040513          	addi	a0,s0,-176
    80005b4e:	00000097          	auipc	ra,0x0
    80005b52:	972080e7          	jalr	-1678(ra) # 800054c0 <create>
    80005b56:	84aa                	mv	s1,a0
    if (ip == 0)
    80005b58:	c959                	beqz	a0,80005bee <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV))
    80005b5a:	04449703          	lh	a4,68(s1)
    80005b5e:	478d                	li	a5,3
    80005b60:	00f71763          	bne	a4,a5,80005b6e <sys_open+0x72>
    80005b64:	0464d703          	lhu	a4,70(s1)
    80005b68:	47a5                	li	a5,9
    80005b6a:	0ce7ed63          	bltu	a5,a4,80005c44 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0)
    80005b6e:	fffff097          	auipc	ra,0xfffff
    80005b72:	dbc080e7          	jalr	-580(ra) # 8000492a <filealloc>
    80005b76:	89aa                	mv	s3,a0
    80005b78:	10050363          	beqz	a0,80005c7e <sys_open+0x182>
    80005b7c:	00000097          	auipc	ra,0x0
    80005b80:	902080e7          	jalr	-1790(ra) # 8000547e <fdalloc>
    80005b84:	892a                	mv	s2,a0
    80005b86:	0e054763          	bltz	a0,80005c74 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE)
    80005b8a:	04449703          	lh	a4,68(s1)
    80005b8e:	478d                	li	a5,3
    80005b90:	0cf70563          	beq	a4,a5,80005c5a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  }
  else
  {
    f->type = FD_INODE;
    80005b94:	4789                	li	a5,2
    80005b96:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b9a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b9e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ba2:	f4c42783          	lw	a5,-180(s0)
    80005ba6:	0017c713          	xori	a4,a5,1
    80005baa:	8b05                	andi	a4,a4,1
    80005bac:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005bb0:	0037f713          	andi	a4,a5,3
    80005bb4:	00e03733          	snez	a4,a4
    80005bb8:	00e984a3          	sb	a4,9(s3)

  if ((omode & O_TRUNC) && ip->type == T_FILE)
    80005bbc:	4007f793          	andi	a5,a5,1024
    80005bc0:	c791                	beqz	a5,80005bcc <sys_open+0xd0>
    80005bc2:	04449703          	lh	a4,68(s1)
    80005bc6:	4789                	li	a5,2
    80005bc8:	0af70063          	beq	a4,a5,80005c68 <sys_open+0x16c>
  {
    itrunc(ip);
  }

  iunlock(ip);
    80005bcc:	8526                	mv	a0,s1
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	046080e7          	jalr	70(ra) # 80003c14 <iunlock>
  end_op();
    80005bd6:	fffff097          	auipc	ra,0xfffff
    80005bda:	9c6080e7          	jalr	-1594(ra) # 8000459c <end_op>

  return fd;
    80005bde:	854a                	mv	a0,s2
}
    80005be0:	70ea                	ld	ra,184(sp)
    80005be2:	744a                	ld	s0,176(sp)
    80005be4:	74aa                	ld	s1,168(sp)
    80005be6:	790a                	ld	s2,160(sp)
    80005be8:	69ea                	ld	s3,152(sp)
    80005bea:	6129                	addi	sp,sp,192
    80005bec:	8082                	ret
      end_op();
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	9ae080e7          	jalr	-1618(ra) # 8000459c <end_op>
      return -1;
    80005bf6:	557d                	li	a0,-1
    80005bf8:	b7e5                	j	80005be0 <sys_open+0xe4>
    if ((ip = namei(path)) == 0)
    80005bfa:	f5040513          	addi	a0,s0,-176
    80005bfe:	ffffe097          	auipc	ra,0xffffe
    80005c02:	700080e7          	jalr	1792(ra) # 800042fe <namei>
    80005c06:	84aa                	mv	s1,a0
    80005c08:	c905                	beqz	a0,80005c38 <sys_open+0x13c>
    ilock(ip);
    80005c0a:	ffffe097          	auipc	ra,0xffffe
    80005c0e:	f48080e7          	jalr	-184(ra) # 80003b52 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY)
    80005c12:	04449703          	lh	a4,68(s1)
    80005c16:	4785                	li	a5,1
    80005c18:	f4f711e3          	bne	a4,a5,80005b5a <sys_open+0x5e>
    80005c1c:	f4c42783          	lw	a5,-180(s0)
    80005c20:	d7b9                	beqz	a5,80005b6e <sys_open+0x72>
      iunlockput(ip);
    80005c22:	8526                	mv	a0,s1
    80005c24:	ffffe097          	auipc	ra,0xffffe
    80005c28:	190080e7          	jalr	400(ra) # 80003db4 <iunlockput>
      end_op();
    80005c2c:	fffff097          	auipc	ra,0xfffff
    80005c30:	970080e7          	jalr	-1680(ra) # 8000459c <end_op>
      return -1;
    80005c34:	557d                	li	a0,-1
    80005c36:	b76d                	j	80005be0 <sys_open+0xe4>
      end_op();
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	964080e7          	jalr	-1692(ra) # 8000459c <end_op>
      return -1;
    80005c40:	557d                	li	a0,-1
    80005c42:	bf79                	j	80005be0 <sys_open+0xe4>
    iunlockput(ip);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	16e080e7          	jalr	366(ra) # 80003db4 <iunlockput>
    end_op();
    80005c4e:	fffff097          	auipc	ra,0xfffff
    80005c52:	94e080e7          	jalr	-1714(ra) # 8000459c <end_op>
    return -1;
    80005c56:	557d                	li	a0,-1
    80005c58:	b761                	j	80005be0 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c5a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c5e:	04649783          	lh	a5,70(s1)
    80005c62:	02f99223          	sh	a5,36(s3)
    80005c66:	bf25                	j	80005b9e <sys_open+0xa2>
    itrunc(ip);
    80005c68:	8526                	mv	a0,s1
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	ff6080e7          	jalr	-10(ra) # 80003c60 <itrunc>
    80005c72:	bfa9                	j	80005bcc <sys_open+0xd0>
      fileclose(f);
    80005c74:	854e                	mv	a0,s3
    80005c76:	fffff097          	auipc	ra,0xfffff
    80005c7a:	d70080e7          	jalr	-656(ra) # 800049e6 <fileclose>
    iunlockput(ip);
    80005c7e:	8526                	mv	a0,s1
    80005c80:	ffffe097          	auipc	ra,0xffffe
    80005c84:	134080e7          	jalr	308(ra) # 80003db4 <iunlockput>
    end_op();
    80005c88:	fffff097          	auipc	ra,0xfffff
    80005c8c:	914080e7          	jalr	-1772(ra) # 8000459c <end_op>
    return -1;
    80005c90:	557d                	li	a0,-1
    80005c92:	b7b9                	j	80005be0 <sys_open+0xe4>

0000000080005c94 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c94:	7175                	addi	sp,sp,-144
    80005c96:	e506                	sd	ra,136(sp)
    80005c98:	e122                	sd	s0,128(sp)
    80005c9a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	882080e7          	jalr	-1918(ra) # 8000451e <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
    80005ca4:	08000613          	li	a2,128
    80005ca8:	f7040593          	addi	a1,s0,-144
    80005cac:	4501                	li	a0,0
    80005cae:	ffffd097          	auipc	ra,0xffffd
    80005cb2:	240080e7          	jalr	576(ra) # 80002eee <argstr>
    80005cb6:	02054963          	bltz	a0,80005ce8 <sys_mkdir+0x54>
    80005cba:	4681                	li	a3,0
    80005cbc:	4601                	li	a2,0
    80005cbe:	4585                	li	a1,1
    80005cc0:	f7040513          	addi	a0,s0,-144
    80005cc4:	fffff097          	auipc	ra,0xfffff
    80005cc8:	7fc080e7          	jalr	2044(ra) # 800054c0 <create>
    80005ccc:	cd11                	beqz	a0,80005ce8 <sys_mkdir+0x54>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cce:	ffffe097          	auipc	ra,0xffffe
    80005cd2:	0e6080e7          	jalr	230(ra) # 80003db4 <iunlockput>
  end_op();
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	8c6080e7          	jalr	-1850(ra) # 8000459c <end_op>
  return 0;
    80005cde:	4501                	li	a0,0
}
    80005ce0:	60aa                	ld	ra,136(sp)
    80005ce2:	640a                	ld	s0,128(sp)
    80005ce4:	6149                	addi	sp,sp,144
    80005ce6:	8082                	ret
    end_op();
    80005ce8:	fffff097          	auipc	ra,0xfffff
    80005cec:	8b4080e7          	jalr	-1868(ra) # 8000459c <end_op>
    return -1;
    80005cf0:	557d                	li	a0,-1
    80005cf2:	b7fd                	j	80005ce0 <sys_mkdir+0x4c>

0000000080005cf4 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005cf4:	7135                	addi	sp,sp,-160
    80005cf6:	ed06                	sd	ra,152(sp)
    80005cf8:	e922                	sd	s0,144(sp)
    80005cfa:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	822080e7          	jalr	-2014(ra) # 8000451e <begin_op>
  argint(1, &major);
    80005d04:	f6c40593          	addi	a1,s0,-148
    80005d08:	4505                	li	a0,1
    80005d0a:	ffffd097          	auipc	ra,0xffffd
    80005d0e:	1a4080e7          	jalr	420(ra) # 80002eae <argint>
  argint(2, &minor);
    80005d12:	f6840593          	addi	a1,s0,-152
    80005d16:	4509                	li	a0,2
    80005d18:	ffffd097          	auipc	ra,0xffffd
    80005d1c:	196080e7          	jalr	406(ra) # 80002eae <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005d20:	08000613          	li	a2,128
    80005d24:	f7040593          	addi	a1,s0,-144
    80005d28:	4501                	li	a0,0
    80005d2a:	ffffd097          	auipc	ra,0xffffd
    80005d2e:	1c4080e7          	jalr	452(ra) # 80002eee <argstr>
    80005d32:	02054b63          	bltz	a0,80005d68 <sys_mknod+0x74>
      (ip = create(path, T_DEVICE, major, minor)) == 0)
    80005d36:	f6841683          	lh	a3,-152(s0)
    80005d3a:	f6c41603          	lh	a2,-148(s0)
    80005d3e:	458d                	li	a1,3
    80005d40:	f7040513          	addi	a0,s0,-144
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	77c080e7          	jalr	1916(ra) # 800054c0 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005d4c:	cd11                	beqz	a0,80005d68 <sys_mknod+0x74>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d4e:	ffffe097          	auipc	ra,0xffffe
    80005d52:	066080e7          	jalr	102(ra) # 80003db4 <iunlockput>
  end_op();
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	846080e7          	jalr	-1978(ra) # 8000459c <end_op>
  return 0;
    80005d5e:	4501                	li	a0,0
}
    80005d60:	60ea                	ld	ra,152(sp)
    80005d62:	644a                	ld	s0,144(sp)
    80005d64:	610d                	addi	sp,sp,160
    80005d66:	8082                	ret
    end_op();
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	834080e7          	jalr	-1996(ra) # 8000459c <end_op>
    return -1;
    80005d70:	557d                	li	a0,-1
    80005d72:	b7fd                	j	80005d60 <sys_mknod+0x6c>

0000000080005d74 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d74:	7135                	addi	sp,sp,-160
    80005d76:	ed06                	sd	ra,152(sp)
    80005d78:	e922                	sd	s0,144(sp)
    80005d7a:	e526                	sd	s1,136(sp)
    80005d7c:	e14a                	sd	s2,128(sp)
    80005d7e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d80:	ffffc097          	auipc	ra,0xffffc
    80005d84:	da0080e7          	jalr	-608(ra) # 80001b20 <myproc>
    80005d88:	892a                	mv	s2,a0

  begin_op();
    80005d8a:	ffffe097          	auipc	ra,0xffffe
    80005d8e:	794080e7          	jalr	1940(ra) # 8000451e <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0)
    80005d92:	08000613          	li	a2,128
    80005d96:	f6040593          	addi	a1,s0,-160
    80005d9a:	4501                	li	a0,0
    80005d9c:	ffffd097          	auipc	ra,0xffffd
    80005da0:	152080e7          	jalr	338(ra) # 80002eee <argstr>
    80005da4:	04054b63          	bltz	a0,80005dfa <sys_chdir+0x86>
    80005da8:	f6040513          	addi	a0,s0,-160
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	552080e7          	jalr	1362(ra) # 800042fe <namei>
    80005db4:	84aa                	mv	s1,a0
    80005db6:	c131                	beqz	a0,80005dfa <sys_chdir+0x86>
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	d9a080e7          	jalr	-614(ra) # 80003b52 <ilock>
  if (ip->type != T_DIR)
    80005dc0:	04449703          	lh	a4,68(s1)
    80005dc4:	4785                	li	a5,1
    80005dc6:	04f71063          	bne	a4,a5,80005e06 <sys_chdir+0x92>
  {
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005dca:	8526                	mv	a0,s1
    80005dcc:	ffffe097          	auipc	ra,0xffffe
    80005dd0:	e48080e7          	jalr	-440(ra) # 80003c14 <iunlock>
  iput(p->cwd);
    80005dd4:	15093503          	ld	a0,336(s2)
    80005dd8:	ffffe097          	auipc	ra,0xffffe
    80005ddc:	f34080e7          	jalr	-204(ra) # 80003d0c <iput>
  end_op();
    80005de0:	ffffe097          	auipc	ra,0xffffe
    80005de4:	7bc080e7          	jalr	1980(ra) # 8000459c <end_op>
  p->cwd = ip;
    80005de8:	14993823          	sd	s1,336(s2)
  return 0;
    80005dec:	4501                	li	a0,0
}
    80005dee:	60ea                	ld	ra,152(sp)
    80005df0:	644a                	ld	s0,144(sp)
    80005df2:	64aa                	ld	s1,136(sp)
    80005df4:	690a                	ld	s2,128(sp)
    80005df6:	610d                	addi	sp,sp,160
    80005df8:	8082                	ret
    end_op();
    80005dfa:	ffffe097          	auipc	ra,0xffffe
    80005dfe:	7a2080e7          	jalr	1954(ra) # 8000459c <end_op>
    return -1;
    80005e02:	557d                	li	a0,-1
    80005e04:	b7ed                	j	80005dee <sys_chdir+0x7a>
    iunlockput(ip);
    80005e06:	8526                	mv	a0,s1
    80005e08:	ffffe097          	auipc	ra,0xffffe
    80005e0c:	fac080e7          	jalr	-84(ra) # 80003db4 <iunlockput>
    end_op();
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	78c080e7          	jalr	1932(ra) # 8000459c <end_op>
    return -1;
    80005e18:	557d                	li	a0,-1
    80005e1a:	bfd1                	j	80005dee <sys_chdir+0x7a>

0000000080005e1c <sys_exec>:

uint64
sys_exec(void)
{
    80005e1c:	7145                	addi	sp,sp,-464
    80005e1e:	e786                	sd	ra,456(sp)
    80005e20:	e3a2                	sd	s0,448(sp)
    80005e22:	ff26                	sd	s1,440(sp)
    80005e24:	fb4a                	sd	s2,432(sp)
    80005e26:	f74e                	sd	s3,424(sp)
    80005e28:	f352                	sd	s4,416(sp)
    80005e2a:	ef56                	sd	s5,408(sp)
    80005e2c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e2e:	e3840593          	addi	a1,s0,-456
    80005e32:	4505                	li	a0,1
    80005e34:	ffffd097          	auipc	ra,0xffffd
    80005e38:	09a080e7          	jalr	154(ra) # 80002ece <argaddr>
  if (argstr(0, path, MAXPATH) < 0)
    80005e3c:	08000613          	li	a2,128
    80005e40:	f4040593          	addi	a1,s0,-192
    80005e44:	4501                	li	a0,0
    80005e46:	ffffd097          	auipc	ra,0xffffd
    80005e4a:	0a8080e7          	jalr	168(ra) # 80002eee <argstr>
    80005e4e:	87aa                	mv	a5,a0
  {
    return -1;
    80005e50:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0)
    80005e52:	0c07c363          	bltz	a5,80005f18 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005e56:	10000613          	li	a2,256
    80005e5a:	4581                	li	a1,0
    80005e5c:	e4040513          	addi	a0,s0,-448
    80005e60:	ffffb097          	auipc	ra,0xffffb
    80005e64:	fe6080e7          	jalr	-26(ra) # 80000e46 <memset>
  for (i = 0;; i++)
  {
    if (i >= NELEM(argv))
    80005e68:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e6c:	89a6                	mv	s3,s1
    80005e6e:	4901                	li	s2,0
    if (i >= NELEM(argv))
    80005e70:	02000a13          	li	s4,32
    80005e74:	00090a9b          	sext.w	s5,s2
    {
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0)
    80005e78:	00391513          	slli	a0,s2,0x3
    80005e7c:	e3040593          	addi	a1,s0,-464
    80005e80:	e3843783          	ld	a5,-456(s0)
    80005e84:	953e                	add	a0,a0,a5
    80005e86:	ffffd097          	auipc	ra,0xffffd
    80005e8a:	f8a080e7          	jalr	-118(ra) # 80002e10 <fetchaddr>
    80005e8e:	02054a63          	bltz	a0,80005ec2 <sys_exec+0xa6>
    {
      goto bad;
    }
    if (uarg == 0)
    80005e92:	e3043783          	ld	a5,-464(s0)
    80005e96:	c3b9                	beqz	a5,80005edc <sys_exec+0xc0>
    {
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e98:	ffffb097          	auipc	ra,0xffffb
    80005e9c:	db8080e7          	jalr	-584(ra) # 80000c50 <kalloc>
    80005ea0:	85aa                	mv	a1,a0
    80005ea2:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005ea6:	cd11                	beqz	a0,80005ec2 <sys_exec+0xa6>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ea8:	6605                	lui	a2,0x1
    80005eaa:	e3043503          	ld	a0,-464(s0)
    80005eae:	ffffd097          	auipc	ra,0xffffd
    80005eb2:	fb4080e7          	jalr	-76(ra) # 80002e62 <fetchstr>
    80005eb6:	00054663          	bltz	a0,80005ec2 <sys_exec+0xa6>
    if (i >= NELEM(argv))
    80005eba:	0905                	addi	s2,s2,1
    80005ebc:	09a1                	addi	s3,s3,8
    80005ebe:	fb491be3          	bne	s2,s4,80005e74 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ec2:	f4040913          	addi	s2,s0,-192
    80005ec6:	6088                	ld	a0,0(s1)
    80005ec8:	c539                	beqz	a0,80005f16 <sys_exec+0xfa>
    kfree(argv[i]);
    80005eca:	ffffb097          	auipc	ra,0xffffb
    80005ece:	bae080e7          	jalr	-1106(ra) # 80000a78 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ed2:	04a1                	addi	s1,s1,8
    80005ed4:	ff2499e3          	bne	s1,s2,80005ec6 <sys_exec+0xaa>
  return -1;
    80005ed8:	557d                	li	a0,-1
    80005eda:	a83d                	j	80005f18 <sys_exec+0xfc>
      argv[i] = 0;
    80005edc:	0a8e                	slli	s5,s5,0x3
    80005ede:	fc0a8793          	addi	a5,s5,-64
    80005ee2:	00878ab3          	add	s5,a5,s0
    80005ee6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005eea:	e4040593          	addi	a1,s0,-448
    80005eee:	f4040513          	addi	a0,s0,-192
    80005ef2:	fffff097          	auipc	ra,0xfffff
    80005ef6:	16e080e7          	jalr	366(ra) # 80005060 <exec>
    80005efa:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005efc:	f4040993          	addi	s3,s0,-192
    80005f00:	6088                	ld	a0,0(s1)
    80005f02:	c901                	beqz	a0,80005f12 <sys_exec+0xf6>
    kfree(argv[i]);
    80005f04:	ffffb097          	auipc	ra,0xffffb
    80005f08:	b74080e7          	jalr	-1164(ra) # 80000a78 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f0c:	04a1                	addi	s1,s1,8
    80005f0e:	ff3499e3          	bne	s1,s3,80005f00 <sys_exec+0xe4>
  return ret;
    80005f12:	854a                	mv	a0,s2
    80005f14:	a011                	j	80005f18 <sys_exec+0xfc>
  return -1;
    80005f16:	557d                	li	a0,-1
}
    80005f18:	60be                	ld	ra,456(sp)
    80005f1a:	641e                	ld	s0,448(sp)
    80005f1c:	74fa                	ld	s1,440(sp)
    80005f1e:	795a                	ld	s2,432(sp)
    80005f20:	79ba                	ld	s3,424(sp)
    80005f22:	7a1a                	ld	s4,416(sp)
    80005f24:	6afa                	ld	s5,408(sp)
    80005f26:	6179                	addi	sp,sp,464
    80005f28:	8082                	ret

0000000080005f2a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f2a:	7139                	addi	sp,sp,-64
    80005f2c:	fc06                	sd	ra,56(sp)
    80005f2e:	f822                	sd	s0,48(sp)
    80005f30:	f426                	sd	s1,40(sp)
    80005f32:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f34:	ffffc097          	auipc	ra,0xffffc
    80005f38:	bec080e7          	jalr	-1044(ra) # 80001b20 <myproc>
    80005f3c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f3e:	fd840593          	addi	a1,s0,-40
    80005f42:	4501                	li	a0,0
    80005f44:	ffffd097          	auipc	ra,0xffffd
    80005f48:	f8a080e7          	jalr	-118(ra) # 80002ece <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005f4c:	fc840593          	addi	a1,s0,-56
    80005f50:	fd040513          	addi	a0,s0,-48
    80005f54:	fffff097          	auipc	ra,0xfffff
    80005f58:	dc2080e7          	jalr	-574(ra) # 80004d16 <pipealloc>
    return -1;
    80005f5c:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005f5e:	0c054463          	bltz	a0,80006026 <sys_pipe+0xfc>
  fd0 = -1;
    80005f62:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0)
    80005f66:	fd043503          	ld	a0,-48(s0)
    80005f6a:	fffff097          	auipc	ra,0xfffff
    80005f6e:	514080e7          	jalr	1300(ra) # 8000547e <fdalloc>
    80005f72:	fca42223          	sw	a0,-60(s0)
    80005f76:	08054b63          	bltz	a0,8000600c <sys_pipe+0xe2>
    80005f7a:	fc843503          	ld	a0,-56(s0)
    80005f7e:	fffff097          	auipc	ra,0xfffff
    80005f82:	500080e7          	jalr	1280(ra) # 8000547e <fdalloc>
    80005f86:	fca42023          	sw	a0,-64(s0)
    80005f8a:	06054863          	bltz	a0,80005ffa <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005f8e:	4691                	li	a3,4
    80005f90:	fc440613          	addi	a2,s0,-60
    80005f94:	fd843583          	ld	a1,-40(s0)
    80005f98:	68a8                	ld	a0,80(s1)
    80005f9a:	ffffc097          	auipc	ra,0xffffc
    80005f9e:	846080e7          	jalr	-1978(ra) # 800017e0 <copyout>
    80005fa2:	02054063          	bltz	a0,80005fc2 <sys_pipe+0x98>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0)
    80005fa6:	4691                	li	a3,4
    80005fa8:	fc040613          	addi	a2,s0,-64
    80005fac:	fd843583          	ld	a1,-40(s0)
    80005fb0:	0591                	addi	a1,a1,4
    80005fb2:	68a8                	ld	a0,80(s1)
    80005fb4:	ffffc097          	auipc	ra,0xffffc
    80005fb8:	82c080e7          	jalr	-2004(ra) # 800017e0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005fbc:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005fbe:	06055463          	bgez	a0,80006026 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005fc2:	fc442783          	lw	a5,-60(s0)
    80005fc6:	07e9                	addi	a5,a5,26
    80005fc8:	078e                	slli	a5,a5,0x3
    80005fca:	97a6                	add	a5,a5,s1
    80005fcc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005fd0:	fc042783          	lw	a5,-64(s0)
    80005fd4:	07e9                	addi	a5,a5,26
    80005fd6:	078e                	slli	a5,a5,0x3
    80005fd8:	94be                	add	s1,s1,a5
    80005fda:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fde:	fd043503          	ld	a0,-48(s0)
    80005fe2:	fffff097          	auipc	ra,0xfffff
    80005fe6:	a04080e7          	jalr	-1532(ra) # 800049e6 <fileclose>
    fileclose(wf);
    80005fea:	fc843503          	ld	a0,-56(s0)
    80005fee:	fffff097          	auipc	ra,0xfffff
    80005ff2:	9f8080e7          	jalr	-1544(ra) # 800049e6 <fileclose>
    return -1;
    80005ff6:	57fd                	li	a5,-1
    80005ff8:	a03d                	j	80006026 <sys_pipe+0xfc>
    if (fd0 >= 0)
    80005ffa:	fc442783          	lw	a5,-60(s0)
    80005ffe:	0007c763          	bltz	a5,8000600c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006002:	07e9                	addi	a5,a5,26
    80006004:	078e                	slli	a5,a5,0x3
    80006006:	97a6                	add	a5,a5,s1
    80006008:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000600c:	fd043503          	ld	a0,-48(s0)
    80006010:	fffff097          	auipc	ra,0xfffff
    80006014:	9d6080e7          	jalr	-1578(ra) # 800049e6 <fileclose>
    fileclose(wf);
    80006018:	fc843503          	ld	a0,-56(s0)
    8000601c:	fffff097          	auipc	ra,0xfffff
    80006020:	9ca080e7          	jalr	-1590(ra) # 800049e6 <fileclose>
    return -1;
    80006024:	57fd                	li	a5,-1
}
    80006026:	853e                	mv	a0,a5
    80006028:	70e2                	ld	ra,56(sp)
    8000602a:	7442                	ld	s0,48(sp)
    8000602c:	74a2                	ld	s1,40(sp)
    8000602e:	6121                	addi	sp,sp,64
    80006030:	8082                	ret
	...

0000000080006040 <kernelvec>:
    80006040:	7111                	addi	sp,sp,-256
    80006042:	e006                	sd	ra,0(sp)
    80006044:	e40a                	sd	sp,8(sp)
    80006046:	e80e                	sd	gp,16(sp)
    80006048:	ec12                	sd	tp,24(sp)
    8000604a:	f016                	sd	t0,32(sp)
    8000604c:	f41a                	sd	t1,40(sp)
    8000604e:	f81e                	sd	t2,48(sp)
    80006050:	fc22                	sd	s0,56(sp)
    80006052:	e0a6                	sd	s1,64(sp)
    80006054:	e4aa                	sd	a0,72(sp)
    80006056:	e8ae                	sd	a1,80(sp)
    80006058:	ecb2                	sd	a2,88(sp)
    8000605a:	f0b6                	sd	a3,96(sp)
    8000605c:	f4ba                	sd	a4,104(sp)
    8000605e:	f8be                	sd	a5,112(sp)
    80006060:	fcc2                	sd	a6,120(sp)
    80006062:	e146                	sd	a7,128(sp)
    80006064:	e54a                	sd	s2,136(sp)
    80006066:	e94e                	sd	s3,144(sp)
    80006068:	ed52                	sd	s4,152(sp)
    8000606a:	f156                	sd	s5,160(sp)
    8000606c:	f55a                	sd	s6,168(sp)
    8000606e:	f95e                	sd	s7,176(sp)
    80006070:	fd62                	sd	s8,184(sp)
    80006072:	e1e6                	sd	s9,192(sp)
    80006074:	e5ea                	sd	s10,200(sp)
    80006076:	e9ee                	sd	s11,208(sp)
    80006078:	edf2                	sd	t3,216(sp)
    8000607a:	f1f6                	sd	t4,224(sp)
    8000607c:	f5fa                	sd	t5,232(sp)
    8000607e:	f9fe                	sd	t6,240(sp)
    80006080:	c5dfc0ef          	jal	ra,80002cdc <kerneltrap>
    80006084:	6082                	ld	ra,0(sp)
    80006086:	6122                	ld	sp,8(sp)
    80006088:	61c2                	ld	gp,16(sp)
    8000608a:	7282                	ld	t0,32(sp)
    8000608c:	7322                	ld	t1,40(sp)
    8000608e:	73c2                	ld	t2,48(sp)
    80006090:	7462                	ld	s0,56(sp)
    80006092:	6486                	ld	s1,64(sp)
    80006094:	6526                	ld	a0,72(sp)
    80006096:	65c6                	ld	a1,80(sp)
    80006098:	6666                	ld	a2,88(sp)
    8000609a:	7686                	ld	a3,96(sp)
    8000609c:	7726                	ld	a4,104(sp)
    8000609e:	77c6                	ld	a5,112(sp)
    800060a0:	7866                	ld	a6,120(sp)
    800060a2:	688a                	ld	a7,128(sp)
    800060a4:	692a                	ld	s2,136(sp)
    800060a6:	69ca                	ld	s3,144(sp)
    800060a8:	6a6a                	ld	s4,152(sp)
    800060aa:	7a8a                	ld	s5,160(sp)
    800060ac:	7b2a                	ld	s6,168(sp)
    800060ae:	7bca                	ld	s7,176(sp)
    800060b0:	7c6a                	ld	s8,184(sp)
    800060b2:	6c8e                	ld	s9,192(sp)
    800060b4:	6d2e                	ld	s10,200(sp)
    800060b6:	6dce                	ld	s11,208(sp)
    800060b8:	6e6e                	ld	t3,216(sp)
    800060ba:	7e8e                	ld	t4,224(sp)
    800060bc:	7f2e                	ld	t5,232(sp)
    800060be:	7fce                	ld	t6,240(sp)
    800060c0:	6111                	addi	sp,sp,256
    800060c2:	10200073          	sret
    800060c6:	00000013          	nop
    800060ca:	00000013          	nop
    800060ce:	0001                	nop

00000000800060d0 <timervec>:
    800060d0:	34051573          	csrrw	a0,mscratch,a0
    800060d4:	e10c                	sd	a1,0(a0)
    800060d6:	e510                	sd	a2,8(a0)
    800060d8:	e914                	sd	a3,16(a0)
    800060da:	6d0c                	ld	a1,24(a0)
    800060dc:	7110                	ld	a2,32(a0)
    800060de:	6194                	ld	a3,0(a1)
    800060e0:	96b2                	add	a3,a3,a2
    800060e2:	e194                	sd	a3,0(a1)
    800060e4:	4589                	li	a1,2
    800060e6:	14459073          	csrw	sip,a1
    800060ea:	6914                	ld	a3,16(a0)
    800060ec:	6510                	ld	a2,8(a0)
    800060ee:	610c                	ld	a1,0(a0)
    800060f0:	34051573          	csrrw	a0,mscratch,a0
    800060f4:	30200073          	mret
	...

00000000800060fa <plicinit>:
//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void)
{
    800060fa:	1141                	addi	sp,sp,-16
    800060fc:	e422                	sd	s0,8(sp)
    800060fe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80006100:	0c0007b7          	lui	a5,0xc000
    80006104:	4705                	li	a4,1
    80006106:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80006108:	c3d8                	sw	a4,4(a5)
}
    8000610a:	6422                	ld	s0,8(sp)
    8000610c:	0141                	addi	sp,sp,16
    8000610e:	8082                	ret

0000000080006110 <plicinithart>:

void plicinithart(void)
{
    80006110:	1141                	addi	sp,sp,-16
    80006112:	e406                	sd	ra,8(sp)
    80006114:	e022                	sd	s0,0(sp)
    80006116:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006118:	ffffc097          	auipc	ra,0xffffc
    8000611c:	9dc080e7          	jalr	-1572(ra) # 80001af4 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006120:	0085171b          	slliw	a4,a0,0x8
    80006124:	0c0027b7          	lui	a5,0xc002
    80006128:	97ba                	add	a5,a5,a4
    8000612a:	40200713          	li	a4,1026
    8000612e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80006132:	00d5151b          	slliw	a0,a0,0xd
    80006136:	0c2017b7          	lui	a5,0xc201
    8000613a:	97aa                	add	a5,a5,a0
    8000613c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006140:	60a2                	ld	ra,8(sp)
    80006142:	6402                	ld	s0,0(sp)
    80006144:	0141                	addi	sp,sp,16
    80006146:	8082                	ret

0000000080006148 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void)
{
    80006148:	1141                	addi	sp,sp,-16
    8000614a:	e406                	sd	ra,8(sp)
    8000614c:	e022                	sd	s0,0(sp)
    8000614e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006150:	ffffc097          	auipc	ra,0xffffc
    80006154:	9a4080e7          	jalr	-1628(ra) # 80001af4 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80006158:	00d5151b          	slliw	a0,a0,0xd
    8000615c:	0c2017b7          	lui	a5,0xc201
    80006160:	97aa                	add	a5,a5,a0
  return irq;
}
    80006162:	43c8                	lw	a0,4(a5)
    80006164:	60a2                	ld	ra,8(sp)
    80006166:	6402                	ld	s0,0(sp)
    80006168:	0141                	addi	sp,sp,16
    8000616a:	8082                	ret

000000008000616c <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq)
{
    8000616c:	1101                	addi	sp,sp,-32
    8000616e:	ec06                	sd	ra,24(sp)
    80006170:	e822                	sd	s0,16(sp)
    80006172:	e426                	sd	s1,8(sp)
    80006174:	1000                	addi	s0,sp,32
    80006176:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006178:	ffffc097          	auipc	ra,0xffffc
    8000617c:	97c080e7          	jalr	-1668(ra) # 80001af4 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80006180:	00d5151b          	slliw	a0,a0,0xd
    80006184:	0c2017b7          	lui	a5,0xc201
    80006188:	97aa                	add	a5,a5,a0
    8000618a:	c3c4                	sw	s1,4(a5)
}
    8000618c:	60e2                	ld	ra,24(sp)
    8000618e:	6442                	ld	s0,16(sp)
    80006190:	64a2                	ld	s1,8(sp)
    80006192:	6105                	addi	sp,sp,32
    80006194:	8082                	ret

0000000080006196 <sgenrand>:
static unsigned long mt[N]; /* the array for the state vector  */
static int mti = N + 1;     /* mti==N+1 means mt[N] is not initialized */

/* initializing the array with a NONZERO seed */
void sgenrand(unsigned long seed)
{
    80006196:	1141                	addi	sp,sp,-16
    80006198:	e422                	sd	s0,8(sp)
    8000619a:	0800                	addi	s0,sp,16
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0] = seed & 0xffffffff;
    8000619c:	0023e717          	auipc	a4,0x23e
    800061a0:	cc470713          	addi	a4,a4,-828 # 80243e60 <mt>
    800061a4:	1502                	slli	a0,a0,0x20
    800061a6:	9101                	srli	a0,a0,0x20
    800061a8:	e308                	sd	a0,0(a4)
    for (mti = 1; mti < N; mti++)
    800061aa:	0023f597          	auipc	a1,0x23f
    800061ae:	02e58593          	addi	a1,a1,46 # 802451d8 <mt+0x1378>
        mt[mti] = (69069 * mt[mti - 1]) & 0xffffffff;
    800061b2:	6645                	lui	a2,0x11
    800061b4:	dcd60613          	addi	a2,a2,-563 # 10dcd <_entry-0x7ffef233>
    800061b8:	56fd                	li	a3,-1
    800061ba:	9281                	srli	a3,a3,0x20
    800061bc:	631c                	ld	a5,0(a4)
    800061be:	02c787b3          	mul	a5,a5,a2
    800061c2:	8ff5                	and	a5,a5,a3
    800061c4:	e71c                	sd	a5,8(a4)
    for (mti = 1; mti < N; mti++)
    800061c6:	0721                	addi	a4,a4,8
    800061c8:	feb71ae3          	bne	a4,a1,800061bc <sgenrand+0x26>
    800061cc:	27000793          	li	a5,624
    800061d0:	00002717          	auipc	a4,0x2
    800061d4:	7af72c23          	sw	a5,1976(a4) # 80008988 <mti>
}
    800061d8:	6422                	ld	s0,8(sp)
    800061da:	0141                	addi	sp,sp,16
    800061dc:	8082                	ret

00000000800061de <genrand>:

long /* for integer generation */
genrand()
{
    800061de:	1141                	addi	sp,sp,-16
    800061e0:	e406                	sd	ra,8(sp)
    800061e2:	e022                	sd	s0,0(sp)
    800061e4:	0800                	addi	s0,sp,16
    unsigned long y;
    static unsigned long mag01[2] = {0x0, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N)
    800061e6:	00002797          	auipc	a5,0x2
    800061ea:	7a27a783          	lw	a5,1954(a5) # 80008988 <mti>
    800061ee:	26f00713          	li	a4,623
    800061f2:	0ef75963          	bge	a4,a5,800062e4 <genrand+0x106>
    { /* generate N words at one time */
        int kk;

        if (mti == N + 1)   /* if sgenrand() has not been called, */
    800061f6:	27100713          	li	a4,625
    800061fa:	12e78e63          	beq	a5,a4,80006336 <genrand+0x158>
            sgenrand(4357); /* a default initial seed is used   */

        for (kk = 0; kk < N - M; kk++)
    800061fe:	0023e817          	auipc	a6,0x23e
    80006202:	c6280813          	addi	a6,a6,-926 # 80243e60 <mt>
    80006206:	0023ee17          	auipc	t3,0x23e
    8000620a:	372e0e13          	addi	t3,t3,882 # 80244578 <mt+0x718>
{
    8000620e:	8742                	mv	a4,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    80006210:	4885                	li	a7,1
    80006212:	08fe                	slli	a7,a7,0x1f
    80006214:	80000537          	lui	a0,0x80000
    80006218:	fff54513          	not	a0,a0
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    8000621c:	6585                	lui	a1,0x1
    8000621e:	c6858593          	addi	a1,a1,-920 # c68 <_entry-0x7ffff398>
    80006222:	00002317          	auipc	t1,0x2
    80006226:	63e30313          	addi	t1,t1,1598 # 80008860 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    8000622a:	631c                	ld	a5,0(a4)
    8000622c:	0117f7b3          	and	a5,a5,a7
    80006230:	6714                	ld	a3,8(a4)
    80006232:	8ee9                	and	a3,a3,a0
    80006234:	8fd5                	or	a5,a5,a3
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    80006236:	00b70633          	add	a2,a4,a1
    8000623a:	0017d693          	srli	a3,a5,0x1
    8000623e:	6210                	ld	a2,0(a2)
    80006240:	8eb1                	xor	a3,a3,a2
    80006242:	8b85                	andi	a5,a5,1
    80006244:	078e                	slli	a5,a5,0x3
    80006246:	979a                	add	a5,a5,t1
    80006248:	639c                	ld	a5,0(a5)
    8000624a:	8fb5                	xor	a5,a5,a3
    8000624c:	e31c                	sd	a5,0(a4)
        for (kk = 0; kk < N - M; kk++)
    8000624e:	0721                	addi	a4,a4,8
    80006250:	fdc71de3          	bne	a4,t3,8000622a <genrand+0x4c>
        }
        for (; kk < N - 1; kk++)
    80006254:	6605                	lui	a2,0x1
    80006256:	c6060613          	addi	a2,a2,-928 # c60 <_entry-0x7ffff3a0>
    8000625a:	9642                	add	a2,a2,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    8000625c:	4505                	li	a0,1
    8000625e:	057e                	slli	a0,a0,0x1f
    80006260:	800005b7          	lui	a1,0x80000
    80006264:	fff5c593          	not	a1,a1
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    80006268:	00002897          	auipc	a7,0x2
    8000626c:	5f888893          	addi	a7,a7,1528 # 80008860 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    80006270:	71883783          	ld	a5,1816(a6)
    80006274:	8fe9                	and	a5,a5,a0
    80006276:	72083703          	ld	a4,1824(a6)
    8000627a:	8f6d                	and	a4,a4,a1
    8000627c:	8fd9                	or	a5,a5,a4
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    8000627e:	0017d713          	srli	a4,a5,0x1
    80006282:	00083683          	ld	a3,0(a6)
    80006286:	8f35                	xor	a4,a4,a3
    80006288:	8b85                	andi	a5,a5,1
    8000628a:	078e                	slli	a5,a5,0x3
    8000628c:	97c6                	add	a5,a5,a7
    8000628e:	639c                	ld	a5,0(a5)
    80006290:	8fb9                	xor	a5,a5,a4
    80006292:	70f83c23          	sd	a5,1816(a6)
        for (; kk < N - 1; kk++)
    80006296:	0821                	addi	a6,a6,8
    80006298:	fcc81ce3          	bne	a6,a2,80006270 <genrand+0x92>
        }
        y = (mt[N - 1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
    8000629c:	0023f697          	auipc	a3,0x23f
    800062a0:	bc468693          	addi	a3,a3,-1084 # 80244e60 <mt+0x1000>
    800062a4:	3786b783          	ld	a5,888(a3)
    800062a8:	4705                	li	a4,1
    800062aa:	077e                	slli	a4,a4,0x1f
    800062ac:	8ff9                	and	a5,a5,a4
    800062ae:	0023e717          	auipc	a4,0x23e
    800062b2:	bb273703          	ld	a4,-1102(a4) # 80243e60 <mt>
    800062b6:	1706                	slli	a4,a4,0x21
    800062b8:	9305                	srli	a4,a4,0x21
    800062ba:	8fd9                	or	a5,a5,a4
        mt[N - 1] = mt[M - 1] ^ (y >> 1) ^ mag01[y & 0x1];
    800062bc:	0017d713          	srli	a4,a5,0x1
    800062c0:	c606b603          	ld	a2,-928(a3)
    800062c4:	8f31                	xor	a4,a4,a2
    800062c6:	8b85                	andi	a5,a5,1
    800062c8:	078e                	slli	a5,a5,0x3
    800062ca:	00002617          	auipc	a2,0x2
    800062ce:	59660613          	addi	a2,a2,1430 # 80008860 <mag01.0>
    800062d2:	97b2                	add	a5,a5,a2
    800062d4:	639c                	ld	a5,0(a5)
    800062d6:	8fb9                	xor	a5,a5,a4
    800062d8:	36f6bc23          	sd	a5,888(a3)

        mti = 0;
    800062dc:	00002797          	auipc	a5,0x2
    800062e0:	6a07a623          	sw	zero,1708(a5) # 80008988 <mti>
    }

    y = mt[mti++];
    800062e4:	00002717          	auipc	a4,0x2
    800062e8:	6a470713          	addi	a4,a4,1700 # 80008988 <mti>
    800062ec:	431c                	lw	a5,0(a4)
    800062ee:	0017869b          	addiw	a3,a5,1
    800062f2:	c314                	sw	a3,0(a4)
    800062f4:	078e                	slli	a5,a5,0x3
    800062f6:	0023e717          	auipc	a4,0x23e
    800062fa:	b6a70713          	addi	a4,a4,-1174 # 80243e60 <mt>
    800062fe:	97ba                	add	a5,a5,a4
    80006300:	639c                	ld	a5,0(a5)
    y ^= TEMPERING_SHIFT_U(y);
    80006302:	00b7d713          	srli	a4,a5,0xb
    80006306:	8f3d                	xor	a4,a4,a5
    y ^= TEMPERING_SHIFT_S(y) & TEMPERING_MASK_B;
    80006308:	013a67b7          	lui	a5,0x13a6
    8000630c:	8ad78793          	addi	a5,a5,-1875 # 13a58ad <_entry-0x7ec5a753>
    80006310:	8ff9                	and	a5,a5,a4
    80006312:	079e                	slli	a5,a5,0x7
    80006314:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_T(y) & TEMPERING_MASK_C;
    80006316:	00f79713          	slli	a4,a5,0xf
    8000631a:	077e36b7          	lui	a3,0x77e3
    8000631e:	0696                	slli	a3,a3,0x5
    80006320:	8f75                	and	a4,a4,a3
    80006322:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_L(y);
    80006324:	0127d513          	srli	a0,a5,0x12
    80006328:	8d3d                	xor	a0,a0,a5

    // Strip off uppermost bit because we want a long,
    // not an unsigned long
    return y & RAND_MAX;
    8000632a:	1506                	slli	a0,a0,0x21
}
    8000632c:	9105                	srli	a0,a0,0x21
    8000632e:	60a2                	ld	ra,8(sp)
    80006330:	6402                	ld	s0,0(sp)
    80006332:	0141                	addi	sp,sp,16
    80006334:	8082                	ret
            sgenrand(4357); /* a default initial seed is used   */
    80006336:	6505                	lui	a0,0x1
    80006338:	10550513          	addi	a0,a0,261 # 1105 <_entry-0x7fffeefb>
    8000633c:	00000097          	auipc	ra,0x0
    80006340:	e5a080e7          	jalr	-422(ra) # 80006196 <sgenrand>
    80006344:	bd6d                	j	800061fe <genrand+0x20>

0000000080006346 <random_at_most>:

// Assumes 0 <= max <= RAND_MAX
// Returns in the half-open interval [0, max]
long random_at_most(long max)
{
    80006346:	1101                	addi	sp,sp,-32
    80006348:	ec06                	sd	ra,24(sp)
    8000634a:	e822                	sd	s0,16(sp)
    8000634c:	e426                	sd	s1,8(sp)
    8000634e:	e04a                	sd	s2,0(sp)
    80006350:	1000                	addi	s0,sp,32
    unsigned long
        // max <= RAND_MAX < ULONG_MAX, so this is okay.
        num_bins = (unsigned long)max + 1,
    80006352:	0505                	addi	a0,a0,1
        num_rand = (unsigned long)RAND_MAX + 1,
        bin_size = num_rand / num_bins,
    80006354:	4785                	li	a5,1
    80006356:	07fe                	slli	a5,a5,0x1f
    80006358:	02a7d933          	divu	s2,a5,a0
        defect = num_rand % num_bins;
    8000635c:	02a7f7b3          	remu	a5,a5,a0
    do
    {
        x = genrand();
    }
    // This is carefully written not to overflow
    while (num_rand - defect <= (unsigned long)x);
    80006360:	4485                	li	s1,1
    80006362:	04fe                	slli	s1,s1,0x1f
    80006364:	8c9d                	sub	s1,s1,a5
        x = genrand();
    80006366:	00000097          	auipc	ra,0x0
    8000636a:	e78080e7          	jalr	-392(ra) # 800061de <genrand>
    while (num_rand - defect <= (unsigned long)x);
    8000636e:	fe957ce3          	bgeu	a0,s1,80006366 <random_at_most+0x20>

    // Truncated division is intentional
    return x / bin_size;
    80006372:	03255533          	divu	a0,a0,s2
    80006376:	60e2                	ld	ra,24(sp)
    80006378:	6442                	ld	s0,16(sp)
    8000637a:	64a2                	ld	s1,8(sp)
    8000637c:	6902                	ld	s2,0(sp)
    8000637e:	6105                	addi	sp,sp,32
    80006380:	8082                	ret

0000000080006382 <popfront>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void popfront(deque *a)
{
    80006382:	1141                	addi	sp,sp,-16
    80006384:	e422                	sd	s0,8(sp)
    80006386:	0800                	addi	s0,sp,16
    for (int i = 0; i < a->end - 1; i++)
    80006388:	20052683          	lw	a3,512(a0)
    8000638c:	fff6861b          	addiw	a2,a3,-1 # 77e2fff <_entry-0x7881d001>
    80006390:	0006079b          	sext.w	a5,a2
    80006394:	cf99                	beqz	a5,800063b2 <popfront+0x30>
    80006396:	87aa                	mv	a5,a0
    80006398:	36f9                	addiw	a3,a3,-2
    8000639a:	02069713          	slli	a4,a3,0x20
    8000639e:	01d75693          	srli	a3,a4,0x1d
    800063a2:	00850713          	addi	a4,a0,8
    800063a6:	96ba                	add	a3,a3,a4
    {
        a->n[i] = a->n[i + 1];
    800063a8:	6798                	ld	a4,8(a5)
    800063aa:	e398                	sd	a4,0(a5)
    for (int i = 0; i < a->end - 1; i++)
    800063ac:	07a1                	addi	a5,a5,8
    800063ae:	fed79de3          	bne	a5,a3,800063a8 <popfront+0x26>
    }
    a->end--;
    800063b2:	20c52023          	sw	a2,512(a0)
    return;
}
    800063b6:	6422                	ld	s0,8(sp)
    800063b8:	0141                	addi	sp,sp,16
    800063ba:	8082                	ret

00000000800063bc <pushback>:
void pushback(deque *a, struct proc *x)
{
    if (a->end == NPROC)
    800063bc:	20052783          	lw	a5,512(a0)
    800063c0:	04000713          	li	a4,64
    800063c4:	00e78c63          	beq	a5,a4,800063dc <pushback+0x20>
    {
        panic("Error!");
        return;
    }
    a->n[a->end] = x;
    800063c8:	02079693          	slli	a3,a5,0x20
    800063cc:	01d6d713          	srli	a4,a3,0x1d
    800063d0:	972a                	add	a4,a4,a0
    800063d2:	e30c                	sd	a1,0(a4)
    a->end++;
    800063d4:	2785                	addiw	a5,a5,1
    800063d6:	20f52023          	sw	a5,512(a0)
    800063da:	8082                	ret
{
    800063dc:	1141                	addi	sp,sp,-16
    800063de:	e406                	sd	ra,8(sp)
    800063e0:	e022                	sd	s0,0(sp)
    800063e2:	0800                	addi	s0,sp,16
        panic("Error!");
    800063e4:	00002517          	auipc	a0,0x2
    800063e8:	48c50513          	addi	a0,a0,1164 # 80008870 <mag01.0+0x10>
    800063ec:	ffffa097          	auipc	ra,0xffffa
    800063f0:	154080e7          	jalr	340(ra) # 80000540 <panic>

00000000800063f4 <front>:
    return;
}
struct proc *front(deque *a)
{
    800063f4:	1141                	addi	sp,sp,-16
    800063f6:	e422                	sd	s0,8(sp)
    800063f8:	0800                	addi	s0,sp,16
    if (a->end == 0)
    800063fa:	20052783          	lw	a5,512(a0)
    800063fe:	c789                	beqz	a5,80006408 <front+0x14>
    {
        return 0;
    }
    return a->n[0];
    80006400:	6108                	ld	a0,0(a0)
}
    80006402:	6422                	ld	s0,8(sp)
    80006404:	0141                	addi	sp,sp,16
    80006406:	8082                	ret
        return 0;
    80006408:	4501                	li	a0,0
    8000640a:	bfe5                	j	80006402 <front+0xe>

000000008000640c <size>:
int size(deque *a)
{
    8000640c:	1141                	addi	sp,sp,-16
    8000640e:	e422                	sd	s0,8(sp)
    80006410:	0800                	addi	s0,sp,16
    return a->end;
}
    80006412:	20052503          	lw	a0,512(a0)
    80006416:	6422                	ld	s0,8(sp)
    80006418:	0141                	addi	sp,sp,16
    8000641a:	8082                	ret

000000008000641c <delete>:
void delete (deque *a, uint pid)
{
    8000641c:	1141                	addi	sp,sp,-16
    8000641e:	e422                	sd	s0,8(sp)
    80006420:	0800                	addi	s0,sp,16
    int flag = 0;
    for (int i = 0; i < a->end; i++)
    80006422:	20052e03          	lw	t3,512(a0)
    80006426:	020e0c63          	beqz	t3,8000645e <delete+0x42>
    8000642a:	87aa                	mv	a5,a0
    8000642c:	000e031b          	sext.w	t1,t3
    80006430:	4701                	li	a4,0
    int flag = 0;
    80006432:	4881                	li	a7,0
    {
        if (pid == a->n[i]->pid)
        {
            flag = 1;
        }
        if (flag == 1 && i != NPROC)
    80006434:	04000e93          	li	t4,64
    80006438:	4805                	li	a6,1
    8000643a:	a811                	j	8000644e <delete+0x32>
    8000643c:	88c2                	mv	a7,a6
    8000643e:	01d70463          	beq	a4,t4,80006446 <delete+0x2a>
        {
            a->n[i] = a->n[i + 1];
    80006442:	6614                	ld	a3,8(a2)
    80006444:	e214                	sd	a3,0(a2)
    for (int i = 0; i < a->end; i++)
    80006446:	2705                	addiw	a4,a4,1
    80006448:	07a1                	addi	a5,a5,8
    8000644a:	00670a63          	beq	a4,t1,8000645e <delete+0x42>
        if (pid == a->n[i]->pid)
    8000644e:	863e                	mv	a2,a5
    80006450:	6394                	ld	a3,0(a5)
    80006452:	5a94                	lw	a3,48(a3)
    80006454:	feb684e3          	beq	a3,a1,8000643c <delete+0x20>
        if (flag == 1 && i != NPROC)
    80006458:	ff0897e3          	bne	a7,a6,80006446 <delete+0x2a>
    8000645c:	b7c5                	j	8000643c <delete+0x20>
        }
    }
    a->end--;
    8000645e:	3e7d                	addiw	t3,t3,-1
    80006460:	21c52023          	sw	t3,512(a0)
    return;
    80006464:	6422                	ld	s0,8(sp)
    80006466:	0141                	addi	sp,sp,16
    80006468:	8082                	ret

000000008000646a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000646a:	1141                	addi	sp,sp,-16
    8000646c:	e406                	sd	ra,8(sp)
    8000646e:	e022                	sd	s0,0(sp)
    80006470:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80006472:	479d                	li	a5,7
    80006474:	04a7cc63          	blt	a5,a0,800064cc <free_desc+0x62>
    panic("free_desc 1");
  if (disk.free[i])
    80006478:	0023f797          	auipc	a5,0x23f
    8000647c:	d6878793          	addi	a5,a5,-664 # 802451e0 <disk>
    80006480:	97aa                	add	a5,a5,a0
    80006482:	0187c783          	lbu	a5,24(a5)
    80006486:	ebb9                	bnez	a5,800064dc <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006488:	00451693          	slli	a3,a0,0x4
    8000648c:	0023f797          	auipc	a5,0x23f
    80006490:	d5478793          	addi	a5,a5,-684 # 802451e0 <disk>
    80006494:	6398                	ld	a4,0(a5)
    80006496:	9736                	add	a4,a4,a3
    80006498:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000649c:	6398                	ld	a4,0(a5)
    8000649e:	9736                	add	a4,a4,a3
    800064a0:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800064a4:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800064a8:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800064ac:	97aa                	add	a5,a5,a0
    800064ae:	4705                	li	a4,1
    800064b0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800064b4:	0023f517          	auipc	a0,0x23f
    800064b8:	d4450513          	addi	a0,a0,-700 # 802451f8 <disk+0x18>
    800064bc:	ffffc097          	auipc	ra,0xffffc
    800064c0:	e02080e7          	jalr	-510(ra) # 800022be <wakeup>
}
    800064c4:	60a2                	ld	ra,8(sp)
    800064c6:	6402                	ld	s0,0(sp)
    800064c8:	0141                	addi	sp,sp,16
    800064ca:	8082                	ret
    panic("free_desc 1");
    800064cc:	00002517          	auipc	a0,0x2
    800064d0:	3ac50513          	addi	a0,a0,940 # 80008878 <mag01.0+0x18>
    800064d4:	ffffa097          	auipc	ra,0xffffa
    800064d8:	06c080e7          	jalr	108(ra) # 80000540 <panic>
    panic("free_desc 2");
    800064dc:	00002517          	auipc	a0,0x2
    800064e0:	3ac50513          	addi	a0,a0,940 # 80008888 <mag01.0+0x28>
    800064e4:	ffffa097          	auipc	ra,0xffffa
    800064e8:	05c080e7          	jalr	92(ra) # 80000540 <panic>

00000000800064ec <virtio_disk_init>:
{
    800064ec:	1101                	addi	sp,sp,-32
    800064ee:	ec06                	sd	ra,24(sp)
    800064f0:	e822                	sd	s0,16(sp)
    800064f2:	e426                	sd	s1,8(sp)
    800064f4:	e04a                	sd	s2,0(sp)
    800064f6:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800064f8:	00002597          	auipc	a1,0x2
    800064fc:	3a058593          	addi	a1,a1,928 # 80008898 <mag01.0+0x38>
    80006500:	0023f517          	auipc	a0,0x23f
    80006504:	e0850513          	addi	a0,a0,-504 # 80245308 <disk+0x128>
    80006508:	ffffa097          	auipc	ra,0xffffa
    8000650c:	7b2080e7          	jalr	1970(ra) # 80000cba <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006510:	100017b7          	lui	a5,0x10001
    80006514:	4398                	lw	a4,0(a5)
    80006516:	2701                	sext.w	a4,a4
    80006518:	747277b7          	lui	a5,0x74727
    8000651c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006520:	14f71b63          	bne	a4,a5,80006676 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006524:	100017b7          	lui	a5,0x10001
    80006528:	43dc                	lw	a5,4(a5)
    8000652a:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000652c:	4709                	li	a4,2
    8000652e:	14e79463          	bne	a5,a4,80006676 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006532:	100017b7          	lui	a5,0x10001
    80006536:	479c                	lw	a5,8(a5)
    80006538:	2781                	sext.w	a5,a5
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000653a:	12e79e63          	bne	a5,a4,80006676 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551)
    8000653e:	100017b7          	lui	a5,0x10001
    80006542:	47d8                	lw	a4,12(a5)
    80006544:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006546:	554d47b7          	lui	a5,0x554d4
    8000654a:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000654e:	12f71463          	bne	a4,a5,80006676 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006552:	100017b7          	lui	a5,0x10001
    80006556:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000655a:	4705                	li	a4,1
    8000655c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000655e:	470d                	li	a4,3
    80006560:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006562:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006564:	c7ffe6b7          	lui	a3,0xc7ffe
    80006568:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db943f>
    8000656c:	8f75                	and	a4,a4,a3
    8000656e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006570:	472d                	li	a4,11
    80006572:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006574:	5bbc                	lw	a5,112(a5)
    80006576:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000657a:	8ba1                	andi	a5,a5,8
    8000657c:	10078563          	beqz	a5,80006686 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006580:	100017b7          	lui	a5,0x10001
    80006584:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80006588:	43fc                	lw	a5,68(a5)
    8000658a:	2781                	sext.w	a5,a5
    8000658c:	10079563          	bnez	a5,80006696 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006590:	100017b7          	lui	a5,0x10001
    80006594:	5bdc                	lw	a5,52(a5)
    80006596:	2781                	sext.w	a5,a5
  if (max == 0)
    80006598:	10078763          	beqz	a5,800066a6 <virtio_disk_init+0x1ba>
  if (max < NUM)
    8000659c:	471d                	li	a4,7
    8000659e:	10f77c63          	bgeu	a4,a5,800066b6 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800065a2:	ffffa097          	auipc	ra,0xffffa
    800065a6:	6ae080e7          	jalr	1710(ra) # 80000c50 <kalloc>
    800065aa:	0023f497          	auipc	s1,0x23f
    800065ae:	c3648493          	addi	s1,s1,-970 # 802451e0 <disk>
    800065b2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800065b4:	ffffa097          	auipc	ra,0xffffa
    800065b8:	69c080e7          	jalr	1692(ra) # 80000c50 <kalloc>
    800065bc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800065be:	ffffa097          	auipc	ra,0xffffa
    800065c2:	692080e7          	jalr	1682(ra) # 80000c50 <kalloc>
    800065c6:	87aa                	mv	a5,a0
    800065c8:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800065ca:	6088                	ld	a0,0(s1)
    800065cc:	cd6d                	beqz	a0,800066c6 <virtio_disk_init+0x1da>
    800065ce:	0023f717          	auipc	a4,0x23f
    800065d2:	c1a73703          	ld	a4,-998(a4) # 802451e8 <disk+0x8>
    800065d6:	cb65                	beqz	a4,800066c6 <virtio_disk_init+0x1da>
    800065d8:	c7fd                	beqz	a5,800066c6 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800065da:	6605                	lui	a2,0x1
    800065dc:	4581                	li	a1,0
    800065de:	ffffb097          	auipc	ra,0xffffb
    800065e2:	868080e7          	jalr	-1944(ra) # 80000e46 <memset>
  memset(disk.avail, 0, PGSIZE);
    800065e6:	0023f497          	auipc	s1,0x23f
    800065ea:	bfa48493          	addi	s1,s1,-1030 # 802451e0 <disk>
    800065ee:	6605                	lui	a2,0x1
    800065f0:	4581                	li	a1,0
    800065f2:	6488                	ld	a0,8(s1)
    800065f4:	ffffb097          	auipc	ra,0xffffb
    800065f8:	852080e7          	jalr	-1966(ra) # 80000e46 <memset>
  memset(disk.used, 0, PGSIZE);
    800065fc:	6605                	lui	a2,0x1
    800065fe:	4581                	li	a1,0
    80006600:	6888                	ld	a0,16(s1)
    80006602:	ffffb097          	auipc	ra,0xffffb
    80006606:	844080e7          	jalr	-1980(ra) # 80000e46 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000660a:	100017b7          	lui	a5,0x10001
    8000660e:	4721                	li	a4,8
    80006610:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006612:	4098                	lw	a4,0(s1)
    80006614:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006618:	40d8                	lw	a4,4(s1)
    8000661a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000661e:	6498                	ld	a4,8(s1)
    80006620:	0007069b          	sext.w	a3,a4
    80006624:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006628:	9701                	srai	a4,a4,0x20
    8000662a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000662e:	6898                	ld	a4,16(s1)
    80006630:	0007069b          	sext.w	a3,a4
    80006634:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006638:	9701                	srai	a4,a4,0x20
    8000663a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000663e:	4705                	li	a4,1
    80006640:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006642:	00e48c23          	sb	a4,24(s1)
    80006646:	00e48ca3          	sb	a4,25(s1)
    8000664a:	00e48d23          	sb	a4,26(s1)
    8000664e:	00e48da3          	sb	a4,27(s1)
    80006652:	00e48e23          	sb	a4,28(s1)
    80006656:	00e48ea3          	sb	a4,29(s1)
    8000665a:	00e48f23          	sb	a4,30(s1)
    8000665e:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006662:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006666:	0727a823          	sw	s2,112(a5)
}
    8000666a:	60e2                	ld	ra,24(sp)
    8000666c:	6442                	ld	s0,16(sp)
    8000666e:	64a2                	ld	s1,8(sp)
    80006670:	6902                	ld	s2,0(sp)
    80006672:	6105                	addi	sp,sp,32
    80006674:	8082                	ret
    panic("could not find virtio disk");
    80006676:	00002517          	auipc	a0,0x2
    8000667a:	23250513          	addi	a0,a0,562 # 800088a8 <mag01.0+0x48>
    8000667e:	ffffa097          	auipc	ra,0xffffa
    80006682:	ec2080e7          	jalr	-318(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006686:	00002517          	auipc	a0,0x2
    8000668a:	24250513          	addi	a0,a0,578 # 800088c8 <mag01.0+0x68>
    8000668e:	ffffa097          	auipc	ra,0xffffa
    80006692:	eb2080e7          	jalr	-334(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006696:	00002517          	auipc	a0,0x2
    8000669a:	25250513          	addi	a0,a0,594 # 800088e8 <mag01.0+0x88>
    8000669e:	ffffa097          	auipc	ra,0xffffa
    800066a2:	ea2080e7          	jalr	-350(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    800066a6:	00002517          	auipc	a0,0x2
    800066aa:	26250513          	addi	a0,a0,610 # 80008908 <mag01.0+0xa8>
    800066ae:	ffffa097          	auipc	ra,0xffffa
    800066b2:	e92080e7          	jalr	-366(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    800066b6:	00002517          	auipc	a0,0x2
    800066ba:	27250513          	addi	a0,a0,626 # 80008928 <mag01.0+0xc8>
    800066be:	ffffa097          	auipc	ra,0xffffa
    800066c2:	e82080e7          	jalr	-382(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800066c6:	00002517          	auipc	a0,0x2
    800066ca:	28250513          	addi	a0,a0,642 # 80008948 <mag01.0+0xe8>
    800066ce:	ffffa097          	auipc	ra,0xffffa
    800066d2:	e72080e7          	jalr	-398(ra) # 80000540 <panic>

00000000800066d6 <virtio_disk_rw>:
  }
  return 0;
}

void virtio_disk_rw(struct buf *b, int write)
{
    800066d6:	7119                	addi	sp,sp,-128
    800066d8:	fc86                	sd	ra,120(sp)
    800066da:	f8a2                	sd	s0,112(sp)
    800066dc:	f4a6                	sd	s1,104(sp)
    800066de:	f0ca                	sd	s2,96(sp)
    800066e0:	ecce                	sd	s3,88(sp)
    800066e2:	e8d2                	sd	s4,80(sp)
    800066e4:	e4d6                	sd	s5,72(sp)
    800066e6:	e0da                	sd	s6,64(sp)
    800066e8:	fc5e                	sd	s7,56(sp)
    800066ea:	f862                	sd	s8,48(sp)
    800066ec:	f466                	sd	s9,40(sp)
    800066ee:	f06a                	sd	s10,32(sp)
    800066f0:	ec6e                	sd	s11,24(sp)
    800066f2:	0100                	addi	s0,sp,128
    800066f4:	8aaa                	mv	s5,a0
    800066f6:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800066f8:	00c52d03          	lw	s10,12(a0)
    800066fc:	001d1d1b          	slliw	s10,s10,0x1
    80006700:	1d02                	slli	s10,s10,0x20
    80006702:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006706:	0023f517          	auipc	a0,0x23f
    8000670a:	c0250513          	addi	a0,a0,-1022 # 80245308 <disk+0x128>
    8000670e:	ffffa097          	auipc	ra,0xffffa
    80006712:	63c080e7          	jalr	1596(ra) # 80000d4a <acquire>
  for (int i = 0; i < 3; i++)
    80006716:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++)
    80006718:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000671a:	0023fb97          	auipc	s7,0x23f
    8000671e:	ac6b8b93          	addi	s7,s7,-1338 # 802451e0 <disk>
  for (int i = 0; i < 3; i++)
    80006722:	4b0d                	li	s6,3
  {
    if (alloc3_desc(idx) == 0)
    {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006724:	0023fc97          	auipc	s9,0x23f
    80006728:	be4c8c93          	addi	s9,s9,-1052 # 80245308 <disk+0x128>
    8000672c:	a08d                	j	8000678e <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000672e:	00fb8733          	add	a4,s7,a5
    80006732:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006736:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0)
    80006738:	0207c563          	bltz	a5,80006762 <virtio_disk_rw+0x8c>
  for (int i = 0; i < 3; i++)
    8000673c:	2905                	addiw	s2,s2,1
    8000673e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006740:	05690c63          	beq	s2,s6,80006798 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006744:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++)
    80006746:	0023f717          	auipc	a4,0x23f
    8000674a:	a9a70713          	addi	a4,a4,-1382 # 802451e0 <disk>
    8000674e:	87ce                	mv	a5,s3
    if (disk.free[i])
    80006750:	01874683          	lbu	a3,24(a4)
    80006754:	fee9                	bnez	a3,8000672e <virtio_disk_rw+0x58>
  for (int i = 0; i < NUM; i++)
    80006756:	2785                	addiw	a5,a5,1
    80006758:	0705                	addi	a4,a4,1
    8000675a:	fe979be3          	bne	a5,s1,80006750 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000675e:	57fd                	li	a5,-1
    80006760:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80006762:	01205d63          	blez	s2,8000677c <virtio_disk_rw+0xa6>
    80006766:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006768:	000a2503          	lw	a0,0(s4)
    8000676c:	00000097          	auipc	ra,0x0
    80006770:	cfe080e7          	jalr	-770(ra) # 8000646a <free_desc>
      for (int j = 0; j < i; j++)
    80006774:	2d85                	addiw	s11,s11,1
    80006776:	0a11                	addi	s4,s4,4
    80006778:	ff2d98e3          	bne	s11,s2,80006768 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000677c:	85e6                	mv	a1,s9
    8000677e:	0023f517          	auipc	a0,0x23f
    80006782:	a7a50513          	addi	a0,a0,-1414 # 802451f8 <disk+0x18>
    80006786:	ffffc097          	auipc	ra,0xffffc
    8000678a:	ac8080e7          	jalr	-1336(ra) # 8000224e <sleep>
  for (int i = 0; i < 3; i++)
    8000678e:	f8040a13          	addi	s4,s0,-128
{
    80006792:	8652                	mv	a2,s4
  for (int i = 0; i < 3; i++)
    80006794:	894e                	mv	s2,s3
    80006796:	b77d                	j	80006744 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006798:	f8042503          	lw	a0,-128(s0)
    8000679c:	00a50713          	addi	a4,a0,10
    800067a0:	0712                	slli	a4,a4,0x4

  if (write)
    800067a2:	0023f797          	auipc	a5,0x23f
    800067a6:	a3e78793          	addi	a5,a5,-1474 # 802451e0 <disk>
    800067aa:	00e786b3          	add	a3,a5,a4
    800067ae:	01803633          	snez	a2,s8
    800067b2:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800067b4:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800067b8:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64)buf0;
    800067bc:	f6070613          	addi	a2,a4,-160
    800067c0:	6394                	ld	a3,0(a5)
    800067c2:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067c4:	00870593          	addi	a1,a4,8
    800067c8:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    800067ca:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800067cc:	0007b803          	ld	a6,0(a5)
    800067d0:	9642                	add	a2,a2,a6
    800067d2:	46c1                	li	a3,16
    800067d4:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800067d6:	4585                	li	a1,1
    800067d8:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800067dc:	f8442683          	lw	a3,-124(s0)
    800067e0:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64)b->data;
    800067e4:	0692                	slli	a3,a3,0x4
    800067e6:	9836                	add	a6,a6,a3
    800067e8:	058a8613          	addi	a2,s5,88
    800067ec:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800067f0:	0007b803          	ld	a6,0(a5)
    800067f4:	96c2                	add	a3,a3,a6
    800067f6:	40000613          	li	a2,1024
    800067fa:	c690                	sw	a2,8(a3)
  if (write)
    800067fc:	001c3613          	seqz	a2,s8
    80006800:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006804:	00166613          	ori	a2,a2,1
    80006808:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000680c:	f8842603          	lw	a2,-120(s0)
    80006810:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006814:	00250693          	addi	a3,a0,2
    80006818:	0692                	slli	a3,a3,0x4
    8000681a:	96be                	add	a3,a3,a5
    8000681c:	58fd                	li	a7,-1
    8000681e:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80006822:	0612                	slli	a2,a2,0x4
    80006824:	9832                	add	a6,a6,a2
    80006826:	f9070713          	addi	a4,a4,-112
    8000682a:	973e                	add	a4,a4,a5
    8000682c:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006830:	6398                	ld	a4,0(a5)
    80006832:	9732                	add	a4,a4,a2
    80006834:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006836:	4609                	li	a2,2
    80006838:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    8000683c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006840:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006844:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006848:	6794                	ld	a3,8(a5)
    8000684a:	0026d703          	lhu	a4,2(a3)
    8000684e:	8b1d                	andi	a4,a4,7
    80006850:	0706                	slli	a4,a4,0x1
    80006852:	96ba                	add	a3,a3,a4
    80006854:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006858:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000685c:	6798                	ld	a4,8(a5)
    8000685e:	00275783          	lhu	a5,2(a4)
    80006862:	2785                	addiw	a5,a5,1
    80006864:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006868:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000686c:	100017b7          	lui	a5,0x10001
    80006870:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1)
    80006874:	004aa783          	lw	a5,4(s5)
  {
    sleep(b, &disk.vdisk_lock);
    80006878:	0023f917          	auipc	s2,0x23f
    8000687c:	a9090913          	addi	s2,s2,-1392 # 80245308 <disk+0x128>
  while (b->disk == 1)
    80006880:	4485                	li	s1,1
    80006882:	00b79c63          	bne	a5,a1,8000689a <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006886:	85ca                	mv	a1,s2
    80006888:	8556                	mv	a0,s5
    8000688a:	ffffc097          	auipc	ra,0xffffc
    8000688e:	9c4080e7          	jalr	-1596(ra) # 8000224e <sleep>
  while (b->disk == 1)
    80006892:	004aa783          	lw	a5,4(s5)
    80006896:	fe9788e3          	beq	a5,s1,80006886 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000689a:	f8042903          	lw	s2,-128(s0)
    8000689e:	00290713          	addi	a4,s2,2
    800068a2:	0712                	slli	a4,a4,0x4
    800068a4:	0023f797          	auipc	a5,0x23f
    800068a8:	93c78793          	addi	a5,a5,-1732 # 802451e0 <disk>
    800068ac:	97ba                	add	a5,a5,a4
    800068ae:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800068b2:	0023f997          	auipc	s3,0x23f
    800068b6:	92e98993          	addi	s3,s3,-1746 # 802451e0 <disk>
    800068ba:	00491713          	slli	a4,s2,0x4
    800068be:	0009b783          	ld	a5,0(s3)
    800068c2:	97ba                	add	a5,a5,a4
    800068c4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800068c8:	854a                	mv	a0,s2
    800068ca:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800068ce:	00000097          	auipc	ra,0x0
    800068d2:	b9c080e7          	jalr	-1124(ra) # 8000646a <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    800068d6:	8885                	andi	s1,s1,1
    800068d8:	f0ed                	bnez	s1,800068ba <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800068da:	0023f517          	auipc	a0,0x23f
    800068de:	a2e50513          	addi	a0,a0,-1490 # 80245308 <disk+0x128>
    800068e2:	ffffa097          	auipc	ra,0xffffa
    800068e6:	51c080e7          	jalr	1308(ra) # 80000dfe <release>
}
    800068ea:	70e6                	ld	ra,120(sp)
    800068ec:	7446                	ld	s0,112(sp)
    800068ee:	74a6                	ld	s1,104(sp)
    800068f0:	7906                	ld	s2,96(sp)
    800068f2:	69e6                	ld	s3,88(sp)
    800068f4:	6a46                	ld	s4,80(sp)
    800068f6:	6aa6                	ld	s5,72(sp)
    800068f8:	6b06                	ld	s6,64(sp)
    800068fa:	7be2                	ld	s7,56(sp)
    800068fc:	7c42                	ld	s8,48(sp)
    800068fe:	7ca2                	ld	s9,40(sp)
    80006900:	7d02                	ld	s10,32(sp)
    80006902:	6de2                	ld	s11,24(sp)
    80006904:	6109                	addi	sp,sp,128
    80006906:	8082                	ret

0000000080006908 <virtio_disk_intr>:

void virtio_disk_intr()
{
    80006908:	1101                	addi	sp,sp,-32
    8000690a:	ec06                	sd	ra,24(sp)
    8000690c:	e822                	sd	s0,16(sp)
    8000690e:	e426                	sd	s1,8(sp)
    80006910:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006912:	0023f497          	auipc	s1,0x23f
    80006916:	8ce48493          	addi	s1,s1,-1842 # 802451e0 <disk>
    8000691a:	0023f517          	auipc	a0,0x23f
    8000691e:	9ee50513          	addi	a0,a0,-1554 # 80245308 <disk+0x128>
    80006922:	ffffa097          	auipc	ra,0xffffa
    80006926:	428080e7          	jalr	1064(ra) # 80000d4a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000692a:	10001737          	lui	a4,0x10001
    8000692e:	533c                	lw	a5,96(a4)
    80006930:	8b8d                	andi	a5,a5,3
    80006932:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006934:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx)
    80006938:	689c                	ld	a5,16(s1)
    8000693a:	0204d703          	lhu	a4,32(s1)
    8000693e:	0027d783          	lhu	a5,2(a5)
    80006942:	04f70863          	beq	a4,a5,80006992 <virtio_disk_intr+0x8a>
  {
    __sync_synchronize();
    80006946:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000694a:	6898                	ld	a4,16(s1)
    8000694c:	0204d783          	lhu	a5,32(s1)
    80006950:	8b9d                	andi	a5,a5,7
    80006952:	078e                	slli	a5,a5,0x3
    80006954:	97ba                	add	a5,a5,a4
    80006956:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80006958:	00278713          	addi	a4,a5,2
    8000695c:	0712                	slli	a4,a4,0x4
    8000695e:	9726                	add	a4,a4,s1
    80006960:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006964:	e721                	bnez	a4,800069ac <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006966:	0789                	addi	a5,a5,2
    80006968:	0792                	slli	a5,a5,0x4
    8000696a:	97a6                	add	a5,a5,s1
    8000696c:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    8000696e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006972:	ffffc097          	auipc	ra,0xffffc
    80006976:	94c080e7          	jalr	-1716(ra) # 800022be <wakeup>

    disk.used_idx += 1;
    8000697a:	0204d783          	lhu	a5,32(s1)
    8000697e:	2785                	addiw	a5,a5,1
    80006980:	17c2                	slli	a5,a5,0x30
    80006982:	93c1                	srli	a5,a5,0x30
    80006984:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx)
    80006988:	6898                	ld	a4,16(s1)
    8000698a:	00275703          	lhu	a4,2(a4)
    8000698e:	faf71ce3          	bne	a4,a5,80006946 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006992:	0023f517          	auipc	a0,0x23f
    80006996:	97650513          	addi	a0,a0,-1674 # 80245308 <disk+0x128>
    8000699a:	ffffa097          	auipc	ra,0xffffa
    8000699e:	464080e7          	jalr	1124(ra) # 80000dfe <release>
}
    800069a2:	60e2                	ld	ra,24(sp)
    800069a4:	6442                	ld	s0,16(sp)
    800069a6:	64a2                	ld	s1,8(sp)
    800069a8:	6105                	addi	sp,sp,32
    800069aa:	8082                	ret
      panic("virtio_disk_intr status");
    800069ac:	00002517          	auipc	a0,0x2
    800069b0:	fb450513          	addi	a0,a0,-76 # 80008960 <mag01.0+0x100>
    800069b4:	ffffa097          	auipc	ra,0xffffa
    800069b8:	b8c080e7          	jalr	-1140(ra) # 80000540 <panic>
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
