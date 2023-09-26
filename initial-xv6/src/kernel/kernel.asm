
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	ac813103          	ld	sp,-1336(sp) # 80008ac8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	ad070713          	addi	a4,a4,-1328 # 80008b20 <timer_scratch>
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
    80000066:	27e78793          	addi	a5,a5,638 # 800062e0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdb94af>
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
    8000012e:	7b2080e7          	jalr	1970(ra) # 800028dc <either_copyin>
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
    8000018e:	ad650513          	addi	a0,a0,-1322 # 80010c60 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	bb8080e7          	jalr	-1096(ra) # 80000d4a <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	ac648493          	addi	s1,s1,-1338 # 80010c60 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	b5690913          	addi	s2,s2,-1194 # 80010cf8 <cons+0x98>
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
    800001cc:	55e080e7          	jalr	1374(ra) # 80002726 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	124080e7          	jalr	292(ra) # 800022fa <sleep>
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
    80000216:	674080e7          	jalr	1652(ra) # 80002886 <either_copyout>
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
    8000022a:	a3a50513          	addi	a0,a0,-1478 # 80010c60 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	bd0080e7          	jalr	-1072(ra) # 80000dfe <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	a2450513          	addi	a0,a0,-1500 # 80010c60 <cons>
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
    80000276:	a8f72323          	sw	a5,-1402(a4) # 80010cf8 <cons+0x98>
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
    800002d0:	99450513          	addi	a0,a0,-1644 # 80010c60 <cons>
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
    800002f6:	640080e7          	jalr	1600(ra) # 80002932 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	96650513          	addi	a0,a0,-1690 # 80010c60 <cons>
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
    80000322:	94270713          	addi	a4,a4,-1726 # 80010c60 <cons>
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
    8000034c:	91878793          	addi	a5,a5,-1768 # 80010c60 <cons>
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
    8000037a:	9827a783          	lw	a5,-1662(a5) # 80010cf8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	8d670713          	addi	a4,a4,-1834 # 80010c60 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	8c648493          	addi	s1,s1,-1850 # 80010c60 <cons>
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
    800003da:	88a70713          	addi	a4,a4,-1910 # 80010c60 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	90f72a23          	sw	a5,-1772(a4) # 80010d00 <cons+0xa0>
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
    80000416:	84e78793          	addi	a5,a5,-1970 # 80010c60 <cons>
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
    8000043a:	8cc7a323          	sw	a2,-1850(a5) # 80010cfc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	8ba50513          	addi	a0,a0,-1862 # 80010cf8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	070080e7          	jalr	112(ra) # 800024b6 <wakeup>
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
    80000464:	80050513          	addi	a0,a0,-2048 # 80010c60 <cons>
    80000468:	00001097          	auipc	ra,0x1
    8000046c:	852080e7          	jalr	-1966(ra) # 80000cba <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00243797          	auipc	a5,0x243
    8000047c:	9c078793          	addi	a5,a5,-1600 # 80242e38 <devsw>
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
    80000550:	7c07aa23          	sw	zero,2004(a5) # 80010d20 <pr+0x18>
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
    80000584:	56f72023          	sw	a5,1376(a4) # 80008ae0 <panicked>
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
    800005c0:	764dad83          	lw	s11,1892(s11) # 80010d20 <pr+0x18>
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
    800005fe:	70e50513          	addi	a0,a0,1806 # 80010d08 <pr>
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
    8000075c:	5b050513          	addi	a0,a0,1456 # 80010d08 <pr>
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
    80000778:	59448493          	addi	s1,s1,1428 # 80010d08 <pr>
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
    800007d8:	55450513          	addi	a0,a0,1364 # 80010d28 <uart_tx_lock>
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
    80000804:	2e07a783          	lw	a5,736(a5) # 80008ae0 <panicked>
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
    8000083c:	2b07b783          	ld	a5,688(a5) # 80008ae8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	2b073703          	ld	a4,688(a4) # 80008af0 <uart_tx_w>
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
    80000866:	4c6a0a13          	addi	s4,s4,1222 # 80010d28 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	27e48493          	addi	s1,s1,638 # 80008ae8 <uart_tx_r>
    if (uart_tx_w == uart_tx_r)
    80000872:	00008997          	auipc	s3,0x8
    80000876:	27e98993          	addi	s3,s3,638 # 80008af0 <uart_tx_w>
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
    80000898:	c22080e7          	jalr	-990(ra) # 800024b6 <wakeup>

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
    800008d4:	45850513          	addi	a0,a0,1112 # 80010d28 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	472080e7          	jalr	1138(ra) # 80000d4a <acquire>
  if (panicked)
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	2007a783          	lw	a5,512(a5) # 80008ae0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	20673703          	ld	a4,518(a4) # 80008af0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	1f67b783          	ld	a5,502(a5) # 80008ae8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	42a98993          	addi	s3,s3,1066 # 80010d28 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	1e248493          	addi	s1,s1,482 # 80008ae8 <uart_tx_r>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	1e290913          	addi	s2,s2,482 # 80008af0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	9dc080e7          	jalr	-1572(ra) # 800022fa <sleep>
  while (uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE)
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	3f448493          	addi	s1,s1,1012 # 80010d28 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	1ae7b423          	sd	a4,424(a5) # 80008af0 <uart_tx_w>
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
    800009be:	36e48493          	addi	s1,s1,878 # 80010d28 <uart_tx_lock>
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
    800009f8:	38c50513          	addi	a0,a0,908 # 80010d80 <page_ref>
    800009fc:	00000097          	auipc	ra,0x0
    80000a00:	34e080e7          	jalr	846(ra) # 80000d4a <acquire>
  if (page_ref.count[(uint64)pa >> 12] <= 0)
    80000a04:	00c4d513          	srli	a0,s1,0xc
    80000a08:	00450713          	addi	a4,a0,4
    80000a0c:	070a                	slli	a4,a4,0x2
    80000a0e:	00010797          	auipc	a5,0x10
    80000a12:	37278793          	addi	a5,a5,882 # 80010d80 <page_ref>
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
    80000a2c:	35870713          	addi	a4,a4,856 # 80010d80 <page_ref>
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
    80000a3c:	34850513          	addi	a0,a0,840 # 80010d80 <page_ref>
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
    80000a68:	31c50513          	addi	a0,a0,796 # 80010d80 <page_ref>
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
    80000a90:	8c478793          	addi	a5,a5,-1852 # 80245350 <end>
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
    80000ad8:	28c90913          	addi	s2,s2,652 # 80010d60 <kmem>
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
    80000b0c:	27850513          	addi	a0,a0,632 # 80010d80 <page_ref>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	23a080e7          	jalr	570(ra) # 80000d4a <acquire>
  if (page_ref.count[(uint64)pa >> 12] < 0)
    80000b18:	00c4d793          	srli	a5,s1,0xc
    80000b1c:	00478693          	addi	a3,a5,4
    80000b20:	068a                	slli	a3,a3,0x2
    80000b22:	00010717          	auipc	a4,0x10
    80000b26:	25e70713          	addi	a4,a4,606 # 80010d80 <page_ref>
    80000b2a:	9736                	add	a4,a4,a3
    80000b2c:	4718                	lw	a4,8(a4)
    80000b2e:	02074463          	bltz	a4,80000b56 <increase_pgreference+0x5a>
  {
    panic("increase_pgreference");
  }
  page_ref.count[(uint64)pa >> 12]++;
    80000b32:	00010517          	auipc	a0,0x10
    80000b36:	24e50513          	addi	a0,a0,590 # 80010d80 <page_ref>
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
    80000bd6:	1ae50513          	addi	a0,a0,430 # 80010d80 <page_ref>
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	0e0080e7          	jalr	224(ra) # 80000cba <initlock>
  acquire(&page_ref.lock);
    80000be2:	00010517          	auipc	a0,0x10
    80000be6:	19e50513          	addi	a0,a0,414 # 80010d80 <page_ref>
    80000bea:	00000097          	auipc	ra,0x0
    80000bee:	160080e7          	jalr	352(ra) # 80000d4a <acquire>
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000bf2:	00010797          	auipc	a5,0x10
    80000bf6:	1a678793          	addi	a5,a5,422 # 80010d98 <page_ref+0x18>
    80000bfa:	00230717          	auipc	a4,0x230
    80000bfe:	19e70713          	addi	a4,a4,414 # 80230d98 <pid_lock>
    page_ref.count[i] = 0;
    80000c02:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000c06:	0791                	addi	a5,a5,4
    80000c08:	fee79de3          	bne	a5,a4,80000c02 <kinit+0x40>
  release(&page_ref.lock);
    80000c0c:	00010517          	auipc	a0,0x10
    80000c10:	17450513          	addi	a0,a0,372 # 80010d80 <page_ref>
    80000c14:	00000097          	auipc	ra,0x0
    80000c18:	1ea080e7          	jalr	490(ra) # 80000dfe <release>
  initlock(&kmem.lock, "kmem");
    80000c1c:	00007597          	auipc	a1,0x7
    80000c20:	48c58593          	addi	a1,a1,1164 # 800080a8 <digits+0x68>
    80000c24:	00010517          	auipc	a0,0x10
    80000c28:	13c50513          	addi	a0,a0,316 # 80010d60 <kmem>
    80000c2c:	00000097          	auipc	ra,0x0
    80000c30:	08e080e7          	jalr	142(ra) # 80000cba <initlock>
  freerange(end, (void *)PHYSTOP);
    80000c34:	45c5                	li	a1,17
    80000c36:	05ee                	slli	a1,a1,0x1b
    80000c38:	00244517          	auipc	a0,0x244
    80000c3c:	71850513          	addi	a0,a0,1816 # 80245350 <end>
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
    80000c5e:	10648493          	addi	s1,s1,262 # 80010d60 <kmem>
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
    80000c76:	0ee50513          	addi	a0,a0,238 # 80010d60 <kmem>
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
    80000cac:	0b850513          	addi	a0,a0,184 # 80010d60 <kmem>
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
    80001000:	afc70713          	addi	a4,a4,-1284 # 80008af8 <started>
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
    80001036:	a44080e7          	jalr	-1468(ra) # 80002a76 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    8000103a:	00005097          	auipc	ra,0x5
    8000103e:	2e6080e7          	jalr	742(ra) # 80006320 <plicinithart>
  }

  scheduler();
    80001042:	00001097          	auipc	ra,0x1
    80001046:	106080e7          	jalr	262(ra) # 80002148 <scheduler>
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
    800010ae:	9a4080e7          	jalr	-1628(ra) # 80002a4e <trapinit>
    trapinithart();     // install kernel trap vector
    800010b2:	00002097          	auipc	ra,0x2
    800010b6:	9c4080e7          	jalr	-1596(ra) # 80002a76 <trapinithart>
    plicinit();         // set up interrupt controller
    800010ba:	00005097          	auipc	ra,0x5
    800010be:	250080e7          	jalr	592(ra) # 8000630a <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    800010c2:	00005097          	auipc	ra,0x5
    800010c6:	25e080e7          	jalr	606(ra) # 80006320 <plicinithart>
    binit();            // buffer cache
    800010ca:	00002097          	auipc	ra,0x2
    800010ce:	3f6080e7          	jalr	1014(ra) # 800034c0 <binit>
    iinit();            // inode table
    800010d2:	00003097          	auipc	ra,0x3
    800010d6:	a96080e7          	jalr	-1386(ra) # 80003b68 <iinit>
    fileinit();         // file table
    800010da:	00004097          	auipc	ra,0x4
    800010de:	a3c080e7          	jalr	-1476(ra) # 80004b16 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010e2:	00005097          	auipc	ra,0x5
    800010e6:	61a080e7          	jalr	1562(ra) # 800066fc <virtio_disk_init>
    userinit();         // first user process
    800010ea:	00001097          	auipc	ra,0x1
    800010ee:	dca080e7          	jalr	-566(ra) # 80001eb4 <userinit>
    __sync_synchronize();
    800010f2:	0ff0000f          	fence
    started = 1;
    800010f6:	4785                	li	a5,1
    800010f8:	00008717          	auipc	a4,0x8
    800010fc:	a0f72023          	sw	a5,-1536(a4) # 80008af8 <started>
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
    80001110:	9f47b783          	ld	a5,-1548(a5) # 80008b00 <kernel_pagetable>
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
    800013cc:	72a7bc23          	sd	a0,1848(a5) # 80008b00 <kernel_pagetable>
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
    80001812:	508080e7          	jalr	1288(ra) # 80002d16 <pgfault>
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
    800019bc:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fdb9cb0>
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
    800019fc:	0022f497          	auipc	s1,0x22f
    80001a00:	7cc48493          	addi	s1,s1,1996 # 802311c8 <proc>
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
    80001a16:	00236a17          	auipc	s4,0x236
    80001a1a:	7b2a0a13          	addi	s4,s4,1970 # 802381c8 <mlfq>
    char *pa = kalloc();
    80001a1e:	fffff097          	auipc	ra,0xfffff
    80001a22:	232080e7          	jalr	562(ra) # 80000c50 <kalloc>
    80001a26:	862a                	mv	a2,a0
    if (pa == 0)
    80001a28:	c131                	beqz	a0,80001a6c <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001a2a:	416485b3          	sub	a1,s1,s6
    80001a2e:	8599                	srai	a1,a1,0x6
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
    80001a50:	1c048493          	addi	s1,s1,448
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
    80001a9c:	30050513          	addi	a0,a0,768 # 80230d98 <pid_lock>
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	21a080e7          	jalr	538(ra) # 80000cba <initlock>
  initlock(&wait_lock, "wait_lock");
    80001aa8:	00006597          	auipc	a1,0x6
    80001aac:	78058593          	addi	a1,a1,1920 # 80008228 <digits+0x1e8>
    80001ab0:	0022f517          	auipc	a0,0x22f
    80001ab4:	30050513          	addi	a0,a0,768 # 80230db0 <wait_lock>
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	202080e7          	jalr	514(ra) # 80000cba <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ac0:	0022f497          	auipc	s1,0x22f
    80001ac4:	70848493          	addi	s1,s1,1800 # 802311c8 <proc>
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
    80001ae2:	00236997          	auipc	s3,0x236
    80001ae6:	6e698993          	addi	s3,s3,1766 # 802381c8 <mlfq>
    initlock(&p->lock, "proc");
    80001aea:	85da                	mv	a1,s6
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	1cc080e7          	jalr	460(ra) # 80000cba <initlock>
    p->state = UNUSED;
    80001af6:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001afa:	415487b3          	sub	a5,s1,s5
    80001afe:	8799                	srai	a5,a5,0x6
    80001b00:	000a3703          	ld	a4,0(s4)
    80001b04:	02e787b3          	mul	a5,a5,a4
    80001b08:	2785                	addiw	a5,a5,1
    80001b0a:	00d7979b          	slliw	a5,a5,0xd
    80001b0e:	40f907b3          	sub	a5,s2,a5
    80001b12:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001b14:	1c048493          	addi	s1,s1,448
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
    80001b50:	27c50513          	addi	a0,a0,636 # 80230dc8 <cpus>
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
    80001b78:	22470713          	addi	a4,a4,548 # 80230d98 <pid_lock>
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
    80001bb0:	e047a783          	lw	a5,-508(a5) # 800089b0 <first.1>
    80001bb4:	eb89                	bnez	a5,80001bc6 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001bb6:	00001097          	auipc	ra,0x1
    80001bba:	ed8080e7          	jalr	-296(ra) # 80002a8e <usertrapret>
}
    80001bbe:	60a2                	ld	ra,8(sp)
    80001bc0:	6402                	ld	s0,0(sp)
    80001bc2:	0141                	addi	sp,sp,16
    80001bc4:	8082                	ret
    first = 0;
    80001bc6:	00007797          	auipc	a5,0x7
    80001bca:	de07a523          	sw	zero,-534(a5) # 800089b0 <first.1>
    fsinit(ROOTDEV);
    80001bce:	4505                	li	a0,1
    80001bd0:	00002097          	auipc	ra,0x2
    80001bd4:	f18080e7          	jalr	-232(ra) # 80003ae8 <fsinit>
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
    80001bea:	1b290913          	addi	s2,s2,434 # 80230d98 <pid_lock>
    80001bee:	854a                	mv	a0,s2
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	15a080e7          	jalr	346(ra) # 80000d4a <acquire>
  pid = nextpid;
    80001bf8:	00007797          	auipc	a5,0x7
    80001bfc:	dbc78793          	addi	a5,a5,-580 # 800089b4 <nextpid>
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
    80001d26:	1b04b503          	ld	a0,432(s1)
    80001d2a:	c509                	beqz	a0,80001d34 <freeproc+0x26>
    kfree((void *)p->alarm_trapframe);
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	d4c080e7          	jalr	-692(ra) # 80000a78 <kfree>
  p->trapframe = 0;
    80001d34:	0404bc23          	sd	zero,88(s1)
  p->alarm_trapframe = 0;
    80001d38:	1a04b823          	sd	zero,432(s1)
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
    80001d88:	44448493          	addi	s1,s1,1092 # 802311c8 <proc>
    80001d8c:	00236917          	auipc	s2,0x236
    80001d90:	43c90913          	addi	s2,s2,1084 # 802381c8 <mlfq>
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
    80001dac:	1c048493          	addi	s1,s1,448
    80001db0:	ff2492e3          	bne	s1,s2,80001d94 <allocproc+0x1c>
  return 0;
    80001db4:	4481                	li	s1,0
    80001db6:	a84d                	j	80001e68 <allocproc+0xf0>
  p->pid = allocpid();
    80001db8:	00000097          	auipc	ra,0x0
    80001dbc:	e22080e7          	jalr	-478(ra) # 80001bda <allocpid>
    80001dc0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001dc2:	4785                	li	a5,1
    80001dc4:	cc9c                	sw	a5,24(s1)
  p->number_of_times_scheduled = 0;
    80001dc6:	1604ac23          	sw	zero,376(s1)
  p->sleeping_ticks = 0;
    80001dca:	1804a223          	sw	zero,388(s1)
  p->running_ticks = 0;
    80001dce:	1804a423          	sw	zero,392(s1)
  p->sleep_start = 0;
    80001dd2:	1604ae23          	sw	zero,380(s1)
  p->reset_niceness = 1;
    80001dd6:	18f4a023          	sw	a5,384(s1)
  p->level = 0;
    80001dda:	1804a623          	sw	zero,396(s1)
  p->change_queue = 1 << p->level;
    80001dde:	18f4aa23          	sw	a5,404(s1)
  p->in_queue = 0;
    80001de2:	1804a823          	sw	zero,400(s1)
  p->enter_ticks = ticks;
    80001de6:	00007797          	auipc	a5,0x7
    80001dea:	d327a783          	lw	a5,-718(a5) # 80008b18 <ticks>
    80001dee:	18f4ac23          	sw	a5,408(s1)
  p->now_ticks = 0;
    80001df2:	1a04a623          	sw	zero,428(s1)
  p->sigalarm_status = 0;
    80001df6:	1a04ac23          	sw	zero,440(s1)
  p->interval = 0;
    80001dfa:	1a04a423          	sw	zero,424(s1)
  p->handler = -1;
    80001dfe:	57fd                	li	a5,-1
    80001e00:	1af4b023          	sd	a5,416(s1)
  p->alarm_trapframe = NULL;
    80001e04:	1a04b823          	sd	zero,432(s1)
  if (forked_process && p->parent)
    80001e08:	00007797          	auipc	a5,0x7
    80001e0c:	d007a783          	lw	a5,-768(a5) # 80008b08 <forked_process>
    80001e10:	e3bd                	bnez	a5,80001e76 <allocproc+0xfe>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e12:	fffff097          	auipc	ra,0xfffff
    80001e16:	e3e080e7          	jalr	-450(ra) # 80000c50 <kalloc>
    80001e1a:	892a                	mv	s2,a0
    80001e1c:	eca8                	sd	a0,88(s1)
    80001e1e:	c13d                	beqz	a0,80001e84 <allocproc+0x10c>
  p->pagetable = proc_pagetable(p);
    80001e20:	8526                	mv	a0,s1
    80001e22:	00000097          	auipc	ra,0x0
    80001e26:	dfe080e7          	jalr	-514(ra) # 80001c20 <proc_pagetable>
    80001e2a:	892a                	mv	s2,a0
    80001e2c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001e2e:	c53d                	beqz	a0,80001e9c <allocproc+0x124>
  memset(&p->context, 0, sizeof(p->context));
    80001e30:	07000613          	li	a2,112
    80001e34:	4581                	li	a1,0
    80001e36:	06048513          	addi	a0,s1,96
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	00c080e7          	jalr	12(ra) # 80000e46 <memset>
  p->context.ra = (uint64)forkret;
    80001e42:	00000797          	auipc	a5,0x0
    80001e46:	d5278793          	addi	a5,a5,-686 # 80001b94 <forkret>
    80001e4a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e4c:	60bc                	ld	a5,64(s1)
    80001e4e:	6705                	lui	a4,0x1
    80001e50:	97ba                	add	a5,a5,a4
    80001e52:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001e54:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001e58:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001e5c:	00007797          	auipc	a5,0x7
    80001e60:	cbc7a783          	lw	a5,-836(a5) # 80008b18 <ticks>
    80001e64:	16f4a623          	sw	a5,364(s1)
}
    80001e68:	8526                	mv	a0,s1
    80001e6a:	60e2                	ld	ra,24(sp)
    80001e6c:	6442                	ld	s0,16(sp)
    80001e6e:	64a2                	ld	s1,8(sp)
    80001e70:	6902                	ld	s2,0(sp)
    80001e72:	6105                	addi	sp,sp,32
    80001e74:	8082                	ret
  if (forked_process && p->parent)
    80001e76:	7c9c                	ld	a5,56(s1)
    80001e78:	dfc9                	beqz	a5,80001e12 <allocproc+0x9a>
    forked_process = 0;
    80001e7a:	00007797          	auipc	a5,0x7
    80001e7e:	c807a723          	sw	zero,-882(a5) # 80008b08 <forked_process>
    80001e82:	bf41                	j	80001e12 <allocproc+0x9a>
    freeproc(p);
    80001e84:	8526                	mv	a0,s1
    80001e86:	00000097          	auipc	ra,0x0
    80001e8a:	e88080e7          	jalr	-376(ra) # 80001d0e <freeproc>
    release(&p->lock);
    80001e8e:	8526                	mv	a0,s1
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	f6e080e7          	jalr	-146(ra) # 80000dfe <release>
    return 0;
    80001e98:	84ca                	mv	s1,s2
    80001e9a:	b7f9                	j	80001e68 <allocproc+0xf0>
    freeproc(p);
    80001e9c:	8526                	mv	a0,s1
    80001e9e:	00000097          	auipc	ra,0x0
    80001ea2:	e70080e7          	jalr	-400(ra) # 80001d0e <freeproc>
    release(&p->lock);
    80001ea6:	8526                	mv	a0,s1
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	f56080e7          	jalr	-170(ra) # 80000dfe <release>
    return 0;
    80001eb0:	84ca                	mv	s1,s2
    80001eb2:	bf5d                	j	80001e68 <allocproc+0xf0>

0000000080001eb4 <userinit>:
{
    80001eb4:	1101                	addi	sp,sp,-32
    80001eb6:	ec06                	sd	ra,24(sp)
    80001eb8:	e822                	sd	s0,16(sp)
    80001eba:	e426                	sd	s1,8(sp)
    80001ebc:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ebe:	00000097          	auipc	ra,0x0
    80001ec2:	eba080e7          	jalr	-326(ra) # 80001d78 <allocproc>
    80001ec6:	84aa                	mv	s1,a0
  initproc = p;
    80001ec8:	00007797          	auipc	a5,0x7
    80001ecc:	c4a7b423          	sd	a0,-952(a5) # 80008b10 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ed0:	03400613          	li	a2,52
    80001ed4:	00007597          	auipc	a1,0x7
    80001ed8:	aec58593          	addi	a1,a1,-1300 # 800089c0 <initcode>
    80001edc:	6928                	ld	a0,80(a0)
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	5ec080e7          	jalr	1516(ra) # 800014ca <uvmfirst>
  p->sz = PGSIZE;
    80001ee6:	6785                	lui	a5,0x1
    80001ee8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001eea:	6cb8                	ld	a4,88(s1)
    80001eec:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001ef0:	6cb8                	ld	a4,88(s1)
    80001ef2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ef4:	4641                	li	a2,16
    80001ef6:	00006597          	auipc	a1,0x6
    80001efa:	34a58593          	addi	a1,a1,842 # 80008240 <digits+0x200>
    80001efe:	15848513          	addi	a0,s1,344
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	08e080e7          	jalr	142(ra) # 80000f90 <safestrcpy>
  p->cwd = namei("/");
    80001f0a:	00006517          	auipc	a0,0x6
    80001f0e:	34650513          	addi	a0,a0,838 # 80008250 <digits+0x210>
    80001f12:	00002097          	auipc	ra,0x2
    80001f16:	600080e7          	jalr	1536(ra) # 80004512 <namei>
    80001f1a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f1e:	478d                	li	a5,3
    80001f20:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f22:	8526                	mv	a0,s1
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	eda080e7          	jalr	-294(ra) # 80000dfe <release>
}
    80001f2c:	60e2                	ld	ra,24(sp)
    80001f2e:	6442                	ld	s0,16(sp)
    80001f30:	64a2                	ld	s1,8(sp)
    80001f32:	6105                	addi	sp,sp,32
    80001f34:	8082                	ret

0000000080001f36 <growproc>:
{
    80001f36:	1101                	addi	sp,sp,-32
    80001f38:	ec06                	sd	ra,24(sp)
    80001f3a:	e822                	sd	s0,16(sp)
    80001f3c:	e426                	sd	s1,8(sp)
    80001f3e:	e04a                	sd	s2,0(sp)
    80001f40:	1000                	addi	s0,sp,32
    80001f42:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001f44:	00000097          	auipc	ra,0x0
    80001f48:	c18080e7          	jalr	-1000(ra) # 80001b5c <myproc>
    80001f4c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f4e:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001f50:	01204c63          	bgtz	s2,80001f68 <growproc+0x32>
  else if (n < 0)
    80001f54:	02094663          	bltz	s2,80001f80 <growproc+0x4a>
  p->sz = sz;
    80001f58:	e4ac                	sd	a1,72(s1)
  return 0;
    80001f5a:	4501                	li	a0,0
}
    80001f5c:	60e2                	ld	ra,24(sp)
    80001f5e:	6442                	ld	s0,16(sp)
    80001f60:	64a2                	ld	s1,8(sp)
    80001f62:	6902                	ld	s2,0(sp)
    80001f64:	6105                	addi	sp,sp,32
    80001f66:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f68:	4691                	li	a3,4
    80001f6a:	00b90633          	add	a2,s2,a1
    80001f6e:	6928                	ld	a0,80(a0)
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	614080e7          	jalr	1556(ra) # 80001584 <uvmalloc>
    80001f78:	85aa                	mv	a1,a0
    80001f7a:	fd79                	bnez	a0,80001f58 <growproc+0x22>
      return -1;
    80001f7c:	557d                	li	a0,-1
    80001f7e:	bff9                	j	80001f5c <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f80:	00b90633          	add	a2,s2,a1
    80001f84:	6928                	ld	a0,80(a0)
    80001f86:	fffff097          	auipc	ra,0xfffff
    80001f8a:	5b6080e7          	jalr	1462(ra) # 8000153c <uvmdealloc>
    80001f8e:	85aa                	mv	a1,a0
    80001f90:	b7e1                	j	80001f58 <growproc+0x22>

0000000080001f92 <fork>:
{
    80001f92:	7139                	addi	sp,sp,-64
    80001f94:	fc06                	sd	ra,56(sp)
    80001f96:	f822                	sd	s0,48(sp)
    80001f98:	f426                	sd	s1,40(sp)
    80001f9a:	f04a                	sd	s2,32(sp)
    80001f9c:	ec4e                	sd	s3,24(sp)
    80001f9e:	e852                	sd	s4,16(sp)
    80001fa0:	e456                	sd	s5,8(sp)
    80001fa2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001fa4:	00000097          	auipc	ra,0x0
    80001fa8:	bb8080e7          	jalr	-1096(ra) # 80001b5c <myproc>
    80001fac:	8aaa                	mv	s5,a0
  if (p->pid > 1)
    80001fae:	5918                	lw	a4,48(a0)
    80001fb0:	4785                	li	a5,1
    80001fb2:	00e7d663          	bge	a5,a4,80001fbe <fork+0x2c>
    forked_process = 1;
    80001fb6:	00007717          	auipc	a4,0x7
    80001fba:	b4f72923          	sw	a5,-1198(a4) # 80008b08 <forked_process>
  if ((np = allocproc()) == 0)
    80001fbe:	00000097          	auipc	ra,0x0
    80001fc2:	dba080e7          	jalr	-582(ra) # 80001d78 <allocproc>
    80001fc6:	89aa                	mv	s3,a0
    80001fc8:	10050f63          	beqz	a0,800020e6 <fork+0x154>
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001fcc:	048ab603          	ld	a2,72(s5)
    80001fd0:	692c                	ld	a1,80(a0)
    80001fd2:	050ab503          	ld	a0,80(s5)
    80001fd6:	fffff097          	auipc	ra,0xfffff
    80001fda:	706080e7          	jalr	1798(ra) # 800016dc <uvmcopy>
    80001fde:	04054c63          	bltz	a0,80002036 <fork+0xa4>
  np->sz = p->sz;
    80001fe2:	048ab783          	ld	a5,72(s5)
    80001fe6:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001fea:	058ab683          	ld	a3,88(s5)
    80001fee:	87b6                	mv	a5,a3
    80001ff0:	0589b703          	ld	a4,88(s3)
    80001ff4:	12068693          	addi	a3,a3,288
    80001ff8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ffc:	6788                	ld	a0,8(a5)
    80001ffe:	6b8c                	ld	a1,16(a5)
    80002000:	6f90                	ld	a2,24(a5)
    80002002:	01073023          	sd	a6,0(a4)
    80002006:	e708                	sd	a0,8(a4)
    80002008:	eb0c                	sd	a1,16(a4)
    8000200a:	ef10                	sd	a2,24(a4)
    8000200c:	02078793          	addi	a5,a5,32
    80002010:	02070713          	addi	a4,a4,32
    80002014:	fed792e3          	bne	a5,a3,80001ff8 <fork+0x66>
  np->tmask = p->tmask;
    80002018:	174aa783          	lw	a5,372(s5)
    8000201c:	16f9aa23          	sw	a5,372(s3)
  np->trapframe->a0 = 0;
    80002020:	0589b783          	ld	a5,88(s3)
    80002024:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002028:	0d0a8493          	addi	s1,s5,208
    8000202c:	0d098913          	addi	s2,s3,208
    80002030:	150a8a13          	addi	s4,s5,336
    80002034:	a00d                	j	80002056 <fork+0xc4>
    freeproc(np);
    80002036:	854e                	mv	a0,s3
    80002038:	00000097          	auipc	ra,0x0
    8000203c:	cd6080e7          	jalr	-810(ra) # 80001d0e <freeproc>
    release(&np->lock);
    80002040:	854e                	mv	a0,s3
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	dbc080e7          	jalr	-580(ra) # 80000dfe <release>
    return -1;
    8000204a:	597d                	li	s2,-1
    8000204c:	a059                	j	800020d2 <fork+0x140>
  for (i = 0; i < NOFILE; i++)
    8000204e:	04a1                	addi	s1,s1,8
    80002050:	0921                	addi	s2,s2,8
    80002052:	01448b63          	beq	s1,s4,80002068 <fork+0xd6>
    if (p->ofile[i])
    80002056:	6088                	ld	a0,0(s1)
    80002058:	d97d                	beqz	a0,8000204e <fork+0xbc>
      np->ofile[i] = filedup(p->ofile[i]);
    8000205a:	00003097          	auipc	ra,0x3
    8000205e:	b4e080e7          	jalr	-1202(ra) # 80004ba8 <filedup>
    80002062:	00a93023          	sd	a0,0(s2)
    80002066:	b7e5                	j	8000204e <fork+0xbc>
  np->cwd = idup(p->cwd);
    80002068:	150ab503          	ld	a0,336(s5)
    8000206c:	00002097          	auipc	ra,0x2
    80002070:	cbc080e7          	jalr	-836(ra) # 80003d28 <idup>
    80002074:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002078:	4641                	li	a2,16
    8000207a:	158a8593          	addi	a1,s5,344
    8000207e:	15898513          	addi	a0,s3,344
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	f0e080e7          	jalr	-242(ra) # 80000f90 <safestrcpy>
  pid = np->pid;
    8000208a:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    8000208e:	854e                	mv	a0,s3
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	d6e080e7          	jalr	-658(ra) # 80000dfe <release>
  acquire(&wait_lock);
    80002098:	0022f497          	auipc	s1,0x22f
    8000209c:	d1848493          	addi	s1,s1,-744 # 80230db0 <wait_lock>
    800020a0:	8526                	mv	a0,s1
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	ca8080e7          	jalr	-856(ra) # 80000d4a <acquire>
  np->parent = p;
    800020aa:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	d4e080e7          	jalr	-690(ra) # 80000dfe <release>
  acquire(&np->lock);
    800020b8:	854e                	mv	a0,s3
    800020ba:	fffff097          	auipc	ra,0xfffff
    800020be:	c90080e7          	jalr	-880(ra) # 80000d4a <acquire>
  np->state = RUNNABLE;
    800020c2:	478d                	li	a5,3
    800020c4:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800020c8:	854e                	mv	a0,s3
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	d34080e7          	jalr	-716(ra) # 80000dfe <release>
}
    800020d2:	854a                	mv	a0,s2
    800020d4:	70e2                	ld	ra,56(sp)
    800020d6:	7442                	ld	s0,48(sp)
    800020d8:	74a2                	ld	s1,40(sp)
    800020da:	7902                	ld	s2,32(sp)
    800020dc:	69e2                	ld	s3,24(sp)
    800020de:	6a42                	ld	s4,16(sp)
    800020e0:	6aa2                	ld	s5,8(sp)
    800020e2:	6121                	addi	sp,sp,64
    800020e4:	8082                	ret
    return -1;
    800020e6:	597d                	li	s2,-1
    800020e8:	b7ed                	j	800020d2 <fork+0x140>

00000000800020ea <update_time>:
{
    800020ea:	7179                	addi	sp,sp,-48
    800020ec:	f406                	sd	ra,40(sp)
    800020ee:	f022                	sd	s0,32(sp)
    800020f0:	ec26                	sd	s1,24(sp)
    800020f2:	e84a                	sd	s2,16(sp)
    800020f4:	e44e                	sd	s3,8(sp)
    800020f6:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    800020f8:	0022f497          	auipc	s1,0x22f
    800020fc:	0d048493          	addi	s1,s1,208 # 802311c8 <proc>
    if (p->state == RUNNING)
    80002100:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002102:	00236917          	auipc	s2,0x236
    80002106:	0c690913          	addi	s2,s2,198 # 802381c8 <mlfq>
    8000210a:	a811                	j	8000211e <update_time+0x34>
    release(&p->lock);
    8000210c:	8526                	mv	a0,s1
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	cf0080e7          	jalr	-784(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002116:	1c048493          	addi	s1,s1,448
    8000211a:	03248063          	beq	s1,s2,8000213a <update_time+0x50>
    acquire(&p->lock);
    8000211e:	8526                	mv	a0,s1
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	c2a080e7          	jalr	-982(ra) # 80000d4a <acquire>
    if (p->state == RUNNING)
    80002128:	4c9c                	lw	a5,24(s1)
    8000212a:	ff3791e3          	bne	a5,s3,8000210c <update_time+0x22>
      p->rtime++;
    8000212e:	1684a783          	lw	a5,360(s1)
    80002132:	2785                	addiw	a5,a5,1
    80002134:	16f4a423          	sw	a5,360(s1)
    80002138:	bfd1                	j	8000210c <update_time+0x22>
}
    8000213a:	70a2                	ld	ra,40(sp)
    8000213c:	7402                	ld	s0,32(sp)
    8000213e:	64e2                	ld	s1,24(sp)
    80002140:	6942                	ld	s2,16(sp)
    80002142:	69a2                	ld	s3,8(sp)
    80002144:	6145                	addi	sp,sp,48
    80002146:	8082                	ret

0000000080002148 <scheduler>:
{
    80002148:	7139                	addi	sp,sp,-64
    8000214a:	fc06                	sd	ra,56(sp)
    8000214c:	f822                	sd	s0,48(sp)
    8000214e:	f426                	sd	s1,40(sp)
    80002150:	f04a                	sd	s2,32(sp)
    80002152:	ec4e                	sd	s3,24(sp)
    80002154:	e852                	sd	s4,16(sp)
    80002156:	e456                	sd	s5,8(sp)
    80002158:	e05a                	sd	s6,0(sp)
    8000215a:	0080                	addi	s0,sp,64
    8000215c:	8792                	mv	a5,tp
  int id = r_tp();
    8000215e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002160:	00779a93          	slli	s5,a5,0x7
    80002164:	0022f717          	auipc	a4,0x22f
    80002168:	c3470713          	addi	a4,a4,-972 # 80230d98 <pid_lock>
    8000216c:	9756                	add	a4,a4,s5
    8000216e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002172:	0022f717          	auipc	a4,0x22f
    80002176:	c5e70713          	addi	a4,a4,-930 # 80230dd0 <cpus+0x8>
    8000217a:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    8000217c:	498d                	li	s3,3
        p->state = RUNNING;
    8000217e:	4b11                	li	s6,4
        c->proc = p;
    80002180:	079e                	slli	a5,a5,0x7
    80002182:	0022fa17          	auipc	s4,0x22f
    80002186:	c16a0a13          	addi	s4,s4,-1002 # 80230d98 <pid_lock>
    8000218a:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    8000218c:	00236917          	auipc	s2,0x236
    80002190:	03c90913          	addi	s2,s2,60 # 802381c8 <mlfq>
  asm volatile("csrr %0, sstatus"
    80002194:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002198:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    8000219c:	10079073          	csrw	sstatus,a5
    800021a0:	0022f497          	auipc	s1,0x22f
    800021a4:	02848493          	addi	s1,s1,40 # 802311c8 <proc>
    800021a8:	a811                	j	800021bc <scheduler+0x74>
      release(&p->lock);
    800021aa:	8526                	mv	a0,s1
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	c52080e7          	jalr	-942(ra) # 80000dfe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800021b4:	1c048493          	addi	s1,s1,448
    800021b8:	fd248ee3          	beq	s1,s2,80002194 <scheduler+0x4c>
      acquire(&p->lock);
    800021bc:	8526                	mv	a0,s1
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	b8c080e7          	jalr	-1140(ra) # 80000d4a <acquire>
      if (p->state == RUNNABLE)
    800021c6:	4c9c                	lw	a5,24(s1)
    800021c8:	ff3791e3          	bne	a5,s3,800021aa <scheduler+0x62>
        p->state = RUNNING;
    800021cc:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800021d0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800021d4:	06048593          	addi	a1,s1,96
    800021d8:	8556                	mv	a0,s5
    800021da:	00001097          	auipc	ra,0x1
    800021de:	80a080e7          	jalr	-2038(ra) # 800029e4 <swtch>
        c->proc = 0;
    800021e2:	020a3823          	sd	zero,48(s4)
    800021e6:	b7d1                	j	800021aa <scheduler+0x62>

00000000800021e8 <sched>:
{
    800021e8:	7179                	addi	sp,sp,-48
    800021ea:	f406                	sd	ra,40(sp)
    800021ec:	f022                	sd	s0,32(sp)
    800021ee:	ec26                	sd	s1,24(sp)
    800021f0:	e84a                	sd	s2,16(sp)
    800021f2:	e44e                	sd	s3,8(sp)
    800021f4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021f6:	00000097          	auipc	ra,0x0
    800021fa:	966080e7          	jalr	-1690(ra) # 80001b5c <myproc>
    800021fe:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	ad0080e7          	jalr	-1328(ra) # 80000cd0 <holding>
    80002208:	c93d                	beqz	a0,8000227e <sched+0x96>
  asm volatile("mv %0, tp"
    8000220a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000220c:	2781                	sext.w	a5,a5
    8000220e:	079e                	slli	a5,a5,0x7
    80002210:	0022f717          	auipc	a4,0x22f
    80002214:	b8870713          	addi	a4,a4,-1144 # 80230d98 <pid_lock>
    80002218:	97ba                	add	a5,a5,a4
    8000221a:	0a87a703          	lw	a4,168(a5)
    8000221e:	4785                	li	a5,1
    80002220:	06f71763          	bne	a4,a5,8000228e <sched+0xa6>
  if (p->state == RUNNING)
    80002224:	4c98                	lw	a4,24(s1)
    80002226:	4791                	li	a5,4
    80002228:	06f70b63          	beq	a4,a5,8000229e <sched+0xb6>
  asm volatile("csrr %0, sstatus"
    8000222c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002230:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002232:	efb5                	bnez	a5,800022ae <sched+0xc6>
  asm volatile("mv %0, tp"
    80002234:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002236:	0022f917          	auipc	s2,0x22f
    8000223a:	b6290913          	addi	s2,s2,-1182 # 80230d98 <pid_lock>
    8000223e:	2781                	sext.w	a5,a5
    80002240:	079e                	slli	a5,a5,0x7
    80002242:	97ca                	add	a5,a5,s2
    80002244:	0ac7a983          	lw	s3,172(a5)
    80002248:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000224a:	2781                	sext.w	a5,a5
    8000224c:	079e                	slli	a5,a5,0x7
    8000224e:	0022f597          	auipc	a1,0x22f
    80002252:	b8258593          	addi	a1,a1,-1150 # 80230dd0 <cpus+0x8>
    80002256:	95be                	add	a1,a1,a5
    80002258:	06048513          	addi	a0,s1,96
    8000225c:	00000097          	auipc	ra,0x0
    80002260:	788080e7          	jalr	1928(ra) # 800029e4 <swtch>
    80002264:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002266:	2781                	sext.w	a5,a5
    80002268:	079e                	slli	a5,a5,0x7
    8000226a:	993e                	add	s2,s2,a5
    8000226c:	0b392623          	sw	s3,172(s2)
}
    80002270:	70a2                	ld	ra,40(sp)
    80002272:	7402                	ld	s0,32(sp)
    80002274:	64e2                	ld	s1,24(sp)
    80002276:	6942                	ld	s2,16(sp)
    80002278:	69a2                	ld	s3,8(sp)
    8000227a:	6145                	addi	sp,sp,48
    8000227c:	8082                	ret
    panic("sched p->lock");
    8000227e:	00006517          	auipc	a0,0x6
    80002282:	fda50513          	addi	a0,a0,-38 # 80008258 <digits+0x218>
    80002286:	ffffe097          	auipc	ra,0xffffe
    8000228a:	2ba080e7          	jalr	698(ra) # 80000540 <panic>
    panic("sched locks");
    8000228e:	00006517          	auipc	a0,0x6
    80002292:	fda50513          	addi	a0,a0,-38 # 80008268 <digits+0x228>
    80002296:	ffffe097          	auipc	ra,0xffffe
    8000229a:	2aa080e7          	jalr	682(ra) # 80000540 <panic>
    panic("sched running");
    8000229e:	00006517          	auipc	a0,0x6
    800022a2:	fda50513          	addi	a0,a0,-38 # 80008278 <digits+0x238>
    800022a6:	ffffe097          	auipc	ra,0xffffe
    800022aa:	29a080e7          	jalr	666(ra) # 80000540 <panic>
    panic("sched interruptible");
    800022ae:	00006517          	auipc	a0,0x6
    800022b2:	fda50513          	addi	a0,a0,-38 # 80008288 <digits+0x248>
    800022b6:	ffffe097          	auipc	ra,0xffffe
    800022ba:	28a080e7          	jalr	650(ra) # 80000540 <panic>

00000000800022be <yield>:
{
    800022be:	1101                	addi	sp,sp,-32
    800022c0:	ec06                	sd	ra,24(sp)
    800022c2:	e822                	sd	s0,16(sp)
    800022c4:	e426                	sd	s1,8(sp)
    800022c6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022c8:	00000097          	auipc	ra,0x0
    800022cc:	894080e7          	jalr	-1900(ra) # 80001b5c <myproc>
    800022d0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	a78080e7          	jalr	-1416(ra) # 80000d4a <acquire>
  p->state = RUNNABLE;
    800022da:	478d                	li	a5,3
    800022dc:	cc9c                	sw	a5,24(s1)
  sched();
    800022de:	00000097          	auipc	ra,0x0
    800022e2:	f0a080e7          	jalr	-246(ra) # 800021e8 <sched>
  release(&p->lock);
    800022e6:	8526                	mv	a0,s1
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	b16080e7          	jalr	-1258(ra) # 80000dfe <release>
}
    800022f0:	60e2                	ld	ra,24(sp)
    800022f2:	6442                	ld	s0,16(sp)
    800022f4:	64a2                	ld	s1,8(sp)
    800022f6:	6105                	addi	sp,sp,32
    800022f8:	8082                	ret

00000000800022fa <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800022fa:	7179                	addi	sp,sp,-48
    800022fc:	f406                	sd	ra,40(sp)
    800022fe:	f022                	sd	s0,32(sp)
    80002300:	ec26                	sd	s1,24(sp)
    80002302:	e84a                	sd	s2,16(sp)
    80002304:	e44e                	sd	s3,8(sp)
    80002306:	1800                	addi	s0,sp,48
    80002308:	89aa                	mv	s3,a0
    8000230a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000230c:	00000097          	auipc	ra,0x0
    80002310:	850080e7          	jalr	-1968(ra) # 80001b5c <myproc>
    80002314:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	a34080e7          	jalr	-1484(ra) # 80000d4a <acquire>
  release(lk);
    8000231e:	854a                	mv	a0,s2
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	ade080e7          	jalr	-1314(ra) # 80000dfe <release>

  // Go to sleep.
  p->sleep_start = ticks;
    80002328:	00006797          	auipc	a5,0x6
    8000232c:	7f07a783          	lw	a5,2032(a5) # 80008b18 <ticks>
    80002330:	16f4ae23          	sw	a5,380(s1)
  p->chan = chan;
    80002334:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002338:	4789                	li	a5,2
    8000233a:	cc9c                	sw	a5,24(s1)

  sched();
    8000233c:	00000097          	auipc	ra,0x0
    80002340:	eac080e7          	jalr	-340(ra) # 800021e8 <sched>

  // Tidy up.
  p->chan = 0;
    80002344:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002348:	8526                	mv	a0,s1
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	ab4080e7          	jalr	-1356(ra) # 80000dfe <release>
  acquire(lk);
    80002352:	854a                	mv	a0,s2
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	9f6080e7          	jalr	-1546(ra) # 80000d4a <acquire>
}
    8000235c:	70a2                	ld	ra,40(sp)
    8000235e:	7402                	ld	s0,32(sp)
    80002360:	64e2                	ld	s1,24(sp)
    80002362:	6942                	ld	s2,16(sp)
    80002364:	69a2                	ld	s3,8(sp)
    80002366:	6145                	addi	sp,sp,48
    80002368:	8082                	ret

000000008000236a <waitx>:
{
    8000236a:	711d                	addi	sp,sp,-96
    8000236c:	ec86                	sd	ra,88(sp)
    8000236e:	e8a2                	sd	s0,80(sp)
    80002370:	e4a6                	sd	s1,72(sp)
    80002372:	e0ca                	sd	s2,64(sp)
    80002374:	fc4e                	sd	s3,56(sp)
    80002376:	f852                	sd	s4,48(sp)
    80002378:	f456                	sd	s5,40(sp)
    8000237a:	f05a                	sd	s6,32(sp)
    8000237c:	ec5e                	sd	s7,24(sp)
    8000237e:	e862                	sd	s8,16(sp)
    80002380:	e466                	sd	s9,8(sp)
    80002382:	e06a                	sd	s10,0(sp)
    80002384:	1080                	addi	s0,sp,96
    80002386:	8b2a                	mv	s6,a0
    80002388:	8bae                	mv	s7,a1
    8000238a:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    8000238c:	fffff097          	auipc	ra,0xfffff
    80002390:	7d0080e7          	jalr	2000(ra) # 80001b5c <myproc>
    80002394:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002396:	0022f517          	auipc	a0,0x22f
    8000239a:	a1a50513          	addi	a0,a0,-1510 # 80230db0 <wait_lock>
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	9ac080e7          	jalr	-1620(ra) # 80000d4a <acquire>
    havekids = 0;
    800023a6:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    800023a8:	4a15                	li	s4,5
        havekids = 1;
    800023aa:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800023ac:	00236997          	auipc	s3,0x236
    800023b0:	e1c98993          	addi	s3,s3,-484 # 802381c8 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800023b4:	0022fd17          	auipc	s10,0x22f
    800023b8:	9fcd0d13          	addi	s10,s10,-1540 # 80230db0 <wait_lock>
    havekids = 0;
    800023bc:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800023be:	0022f497          	auipc	s1,0x22f
    800023c2:	e0a48493          	addi	s1,s1,-502 # 802311c8 <proc>
    800023c6:	a059                	j	8000244c <waitx+0xe2>
          pid = np->pid;
    800023c8:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800023cc:	1684a783          	lw	a5,360(s1)
    800023d0:	00fc2023          	sw	a5,0(s8) # 1000 <_entry-0x7ffff000>
          *wtime = np->etime - np->ctime - np->rtime;
    800023d4:	16c4a703          	lw	a4,364(s1)
    800023d8:	9f3d                	addw	a4,a4,a5
    800023da:	1704a783          	lw	a5,368(s1)
    800023de:	9f99                	subw	a5,a5,a4
    800023e0:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7fdb9cb0>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023e4:	000b0e63          	beqz	s6,80002400 <waitx+0x96>
    800023e8:	4691                	li	a3,4
    800023ea:	02c48613          	addi	a2,s1,44
    800023ee:	85da                	mv	a1,s6
    800023f0:	05093503          	ld	a0,80(s2)
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	3ec080e7          	jalr	1004(ra) # 800017e0 <copyout>
    800023fc:	02054563          	bltz	a0,80002426 <waitx+0xbc>
          freeproc(np);
    80002400:	8526                	mv	a0,s1
    80002402:	00000097          	auipc	ra,0x0
    80002406:	90c080e7          	jalr	-1780(ra) # 80001d0e <freeproc>
          release(&np->lock);
    8000240a:	8526                	mv	a0,s1
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	9f2080e7          	jalr	-1550(ra) # 80000dfe <release>
          release(&wait_lock);
    80002414:	0022f517          	auipc	a0,0x22f
    80002418:	99c50513          	addi	a0,a0,-1636 # 80230db0 <wait_lock>
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	9e2080e7          	jalr	-1566(ra) # 80000dfe <release>
          return pid;
    80002424:	a09d                	j	8000248a <waitx+0x120>
            release(&np->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	9d6080e7          	jalr	-1578(ra) # 80000dfe <release>
            release(&wait_lock);
    80002430:	0022f517          	auipc	a0,0x22f
    80002434:	98050513          	addi	a0,a0,-1664 # 80230db0 <wait_lock>
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	9c6080e7          	jalr	-1594(ra) # 80000dfe <release>
            return -1;
    80002440:	59fd                	li	s3,-1
    80002442:	a0a1                	j	8000248a <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002444:	1c048493          	addi	s1,s1,448
    80002448:	03348463          	beq	s1,s3,80002470 <waitx+0x106>
      if (np->parent == p)
    8000244c:	7c9c                	ld	a5,56(s1)
    8000244e:	ff279be3          	bne	a5,s2,80002444 <waitx+0xda>
        acquire(&np->lock);
    80002452:	8526                	mv	a0,s1
    80002454:	fffff097          	auipc	ra,0xfffff
    80002458:	8f6080e7          	jalr	-1802(ra) # 80000d4a <acquire>
        if (np->state == ZOMBIE)
    8000245c:	4c9c                	lw	a5,24(s1)
    8000245e:	f74785e3          	beq	a5,s4,800023c8 <waitx+0x5e>
        release(&np->lock);
    80002462:	8526                	mv	a0,s1
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	99a080e7          	jalr	-1638(ra) # 80000dfe <release>
        havekids = 1;
    8000246c:	8756                	mv	a4,s5
    8000246e:	bfd9                	j	80002444 <waitx+0xda>
    if (!havekids || p->killed)
    80002470:	c701                	beqz	a4,80002478 <waitx+0x10e>
    80002472:	02892783          	lw	a5,40(s2)
    80002476:	cb8d                	beqz	a5,800024a8 <waitx+0x13e>
      release(&wait_lock);
    80002478:	0022f517          	auipc	a0,0x22f
    8000247c:	93850513          	addi	a0,a0,-1736 # 80230db0 <wait_lock>
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	97e080e7          	jalr	-1666(ra) # 80000dfe <release>
      return -1;
    80002488:	59fd                	li	s3,-1
}
    8000248a:	854e                	mv	a0,s3
    8000248c:	60e6                	ld	ra,88(sp)
    8000248e:	6446                	ld	s0,80(sp)
    80002490:	64a6                	ld	s1,72(sp)
    80002492:	6906                	ld	s2,64(sp)
    80002494:	79e2                	ld	s3,56(sp)
    80002496:	7a42                	ld	s4,48(sp)
    80002498:	7aa2                	ld	s5,40(sp)
    8000249a:	7b02                	ld	s6,32(sp)
    8000249c:	6be2                	ld	s7,24(sp)
    8000249e:	6c42                	ld	s8,16(sp)
    800024a0:	6ca2                	ld	s9,8(sp)
    800024a2:	6d02                	ld	s10,0(sp)
    800024a4:	6125                	addi	sp,sp,96
    800024a6:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024a8:	85ea                	mv	a1,s10
    800024aa:	854a                	mv	a0,s2
    800024ac:	00000097          	auipc	ra,0x0
    800024b0:	e4e080e7          	jalr	-434(ra) # 800022fa <sleep>
    havekids = 0;
    800024b4:	b721                	j	800023bc <waitx+0x52>

00000000800024b6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800024b6:	7139                	addi	sp,sp,-64
    800024b8:	fc06                	sd	ra,56(sp)
    800024ba:	f822                	sd	s0,48(sp)
    800024bc:	f426                	sd	s1,40(sp)
    800024be:	f04a                	sd	s2,32(sp)
    800024c0:	ec4e                	sd	s3,24(sp)
    800024c2:	e852                	sd	s4,16(sp)
    800024c4:	e456                	sd	s5,8(sp)
    800024c6:	e05a                	sd	s6,0(sp)
    800024c8:	0080                	addi	s0,sp,64
    800024ca:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800024cc:	0022f497          	auipc	s1,0x22f
    800024d0:	cfc48493          	addi	s1,s1,-772 # 802311c8 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800024d4:	4989                	li	s3,2
      {
        p->sleeping_ticks += (ticks - p->sleep_start);
    800024d6:	00006b17          	auipc	s6,0x6
    800024da:	642b0b13          	addi	s6,s6,1602 # 80008b18 <ticks>
        p->state = RUNNABLE;
    800024de:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800024e0:	00236917          	auipc	s2,0x236
    800024e4:	ce890913          	addi	s2,s2,-792 # 802381c8 <mlfq>
    800024e8:	a811                	j	800024fc <wakeup+0x46>
      }
      release(&p->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	912080e7          	jalr	-1774(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800024f4:	1c048493          	addi	s1,s1,448
    800024f8:	05248063          	beq	s1,s2,80002538 <wakeup+0x82>
    if (p != myproc())
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	660080e7          	jalr	1632(ra) # 80001b5c <myproc>
    80002504:	fea488e3          	beq	s1,a0,800024f4 <wakeup+0x3e>
      acquire(&p->lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	fffff097          	auipc	ra,0xfffff
    8000250e:	840080e7          	jalr	-1984(ra) # 80000d4a <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002512:	4c9c                	lw	a5,24(s1)
    80002514:	fd379be3          	bne	a5,s3,800024ea <wakeup+0x34>
    80002518:	709c                	ld	a5,32(s1)
    8000251a:	fd4798e3          	bne	a5,s4,800024ea <wakeup+0x34>
        p->sleeping_ticks += (ticks - p->sleep_start);
    8000251e:	1844a703          	lw	a4,388(s1)
    80002522:	000b2783          	lw	a5,0(s6)
    80002526:	9fb9                	addw	a5,a5,a4
    80002528:	17c4a703          	lw	a4,380(s1)
    8000252c:	9f99                	subw	a5,a5,a4
    8000252e:	18f4a223          	sw	a5,388(s1)
        p->state = RUNNABLE;
    80002532:	0154ac23          	sw	s5,24(s1)
    80002536:	bf55                	j	800024ea <wakeup+0x34>
    }
  }
}
    80002538:	70e2                	ld	ra,56(sp)
    8000253a:	7442                	ld	s0,48(sp)
    8000253c:	74a2                	ld	s1,40(sp)
    8000253e:	7902                	ld	s2,32(sp)
    80002540:	69e2                	ld	s3,24(sp)
    80002542:	6a42                	ld	s4,16(sp)
    80002544:	6aa2                	ld	s5,8(sp)
    80002546:	6b02                	ld	s6,0(sp)
    80002548:	6121                	addi	sp,sp,64
    8000254a:	8082                	ret

000000008000254c <reparent>:
{
    8000254c:	7179                	addi	sp,sp,-48
    8000254e:	f406                	sd	ra,40(sp)
    80002550:	f022                	sd	s0,32(sp)
    80002552:	ec26                	sd	s1,24(sp)
    80002554:	e84a                	sd	s2,16(sp)
    80002556:	e44e                	sd	s3,8(sp)
    80002558:	e052                	sd	s4,0(sp)
    8000255a:	1800                	addi	s0,sp,48
    8000255c:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000255e:	0022f497          	auipc	s1,0x22f
    80002562:	c6a48493          	addi	s1,s1,-918 # 802311c8 <proc>
      pp->parent = initproc;
    80002566:	00006a17          	auipc	s4,0x6
    8000256a:	5aaa0a13          	addi	s4,s4,1450 # 80008b10 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000256e:	00236997          	auipc	s3,0x236
    80002572:	c5a98993          	addi	s3,s3,-934 # 802381c8 <mlfq>
    80002576:	a029                	j	80002580 <reparent+0x34>
    80002578:	1c048493          	addi	s1,s1,448
    8000257c:	01348d63          	beq	s1,s3,80002596 <reparent+0x4a>
    if (pp->parent == p)
    80002580:	7c9c                	ld	a5,56(s1)
    80002582:	ff279be3          	bne	a5,s2,80002578 <reparent+0x2c>
      pp->parent = initproc;
    80002586:	000a3503          	ld	a0,0(s4)
    8000258a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000258c:	00000097          	auipc	ra,0x0
    80002590:	f2a080e7          	jalr	-214(ra) # 800024b6 <wakeup>
    80002594:	b7d5                	j	80002578 <reparent+0x2c>
}
    80002596:	70a2                	ld	ra,40(sp)
    80002598:	7402                	ld	s0,32(sp)
    8000259a:	64e2                	ld	s1,24(sp)
    8000259c:	6942                	ld	s2,16(sp)
    8000259e:	69a2                	ld	s3,8(sp)
    800025a0:	6a02                	ld	s4,0(sp)
    800025a2:	6145                	addi	sp,sp,48
    800025a4:	8082                	ret

00000000800025a6 <exit>:
{
    800025a6:	7179                	addi	sp,sp,-48
    800025a8:	f406                	sd	ra,40(sp)
    800025aa:	f022                	sd	s0,32(sp)
    800025ac:	ec26                	sd	s1,24(sp)
    800025ae:	e84a                	sd	s2,16(sp)
    800025b0:	e44e                	sd	s3,8(sp)
    800025b2:	e052                	sd	s4,0(sp)
    800025b4:	1800                	addi	s0,sp,48
    800025b6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025b8:	fffff097          	auipc	ra,0xfffff
    800025bc:	5a4080e7          	jalr	1444(ra) # 80001b5c <myproc>
    800025c0:	89aa                	mv	s3,a0
  if (p == initproc)
    800025c2:	00006797          	auipc	a5,0x6
    800025c6:	54e7b783          	ld	a5,1358(a5) # 80008b10 <initproc>
    800025ca:	0d050493          	addi	s1,a0,208
    800025ce:	15050913          	addi	s2,a0,336
    800025d2:	02a79363          	bne	a5,a0,800025f8 <exit+0x52>
    panic("init exiting");
    800025d6:	00006517          	auipc	a0,0x6
    800025da:	cca50513          	addi	a0,a0,-822 # 800082a0 <digits+0x260>
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	f62080e7          	jalr	-158(ra) # 80000540 <panic>
      fileclose(f);
    800025e6:	00002097          	auipc	ra,0x2
    800025ea:	614080e7          	jalr	1556(ra) # 80004bfa <fileclose>
      p->ofile[fd] = 0;
    800025ee:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800025f2:	04a1                	addi	s1,s1,8
    800025f4:	01248563          	beq	s1,s2,800025fe <exit+0x58>
    if (p->ofile[fd])
    800025f8:	6088                	ld	a0,0(s1)
    800025fa:	f575                	bnez	a0,800025e6 <exit+0x40>
    800025fc:	bfdd                	j	800025f2 <exit+0x4c>
  begin_op();
    800025fe:	00002097          	auipc	ra,0x2
    80002602:	134080e7          	jalr	308(ra) # 80004732 <begin_op>
  iput(p->cwd);
    80002606:	1509b503          	ld	a0,336(s3)
    8000260a:	00002097          	auipc	ra,0x2
    8000260e:	916080e7          	jalr	-1770(ra) # 80003f20 <iput>
  end_op();
    80002612:	00002097          	auipc	ra,0x2
    80002616:	19e080e7          	jalr	414(ra) # 800047b0 <end_op>
  p->cwd = 0;
    8000261a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000261e:	0022e497          	auipc	s1,0x22e
    80002622:	79248493          	addi	s1,s1,1938 # 80230db0 <wait_lock>
    80002626:	8526                	mv	a0,s1
    80002628:	ffffe097          	auipc	ra,0xffffe
    8000262c:	722080e7          	jalr	1826(ra) # 80000d4a <acquire>
  reparent(p);
    80002630:	854e                	mv	a0,s3
    80002632:	00000097          	auipc	ra,0x0
    80002636:	f1a080e7          	jalr	-230(ra) # 8000254c <reparent>
  wakeup(p->parent);
    8000263a:	0389b503          	ld	a0,56(s3)
    8000263e:	00000097          	auipc	ra,0x0
    80002642:	e78080e7          	jalr	-392(ra) # 800024b6 <wakeup>
  acquire(&p->lock);
    80002646:	854e                	mv	a0,s3
    80002648:	ffffe097          	auipc	ra,0xffffe
    8000264c:	702080e7          	jalr	1794(ra) # 80000d4a <acquire>
  p->xstate = status;
    80002650:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002654:	4795                	li	a5,5
    80002656:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000265a:	00006797          	auipc	a5,0x6
    8000265e:	4be7a783          	lw	a5,1214(a5) # 80008b18 <ticks>
    80002662:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    80002666:	8526                	mv	a0,s1
    80002668:	ffffe097          	auipc	ra,0xffffe
    8000266c:	796080e7          	jalr	1942(ra) # 80000dfe <release>
  sched();
    80002670:	00000097          	auipc	ra,0x0
    80002674:	b78080e7          	jalr	-1160(ra) # 800021e8 <sched>
  panic("zombie exit");
    80002678:	00006517          	auipc	a0,0x6
    8000267c:	c3850513          	addi	a0,a0,-968 # 800082b0 <digits+0x270>
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	ec0080e7          	jalr	-320(ra) # 80000540 <panic>

0000000080002688 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002688:	7179                	addi	sp,sp,-48
    8000268a:	f406                	sd	ra,40(sp)
    8000268c:	f022                	sd	s0,32(sp)
    8000268e:	ec26                	sd	s1,24(sp)
    80002690:	e84a                	sd	s2,16(sp)
    80002692:	e44e                	sd	s3,8(sp)
    80002694:	1800                	addi	s0,sp,48
    80002696:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002698:	0022f497          	auipc	s1,0x22f
    8000269c:	b3048493          	addi	s1,s1,-1232 # 802311c8 <proc>
    800026a0:	00236997          	auipc	s3,0x236
    800026a4:	b2898993          	addi	s3,s3,-1240 # 802381c8 <mlfq>
  {
    acquire(&p->lock);
    800026a8:	8526                	mv	a0,s1
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	6a0080e7          	jalr	1696(ra) # 80000d4a <acquire>
    if (p->pid == pid)
    800026b2:	589c                	lw	a5,48(s1)
    800026b4:	01278d63          	beq	a5,s2,800026ce <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026b8:	8526                	mv	a0,s1
    800026ba:	ffffe097          	auipc	ra,0xffffe
    800026be:	744080e7          	jalr	1860(ra) # 80000dfe <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800026c2:	1c048493          	addi	s1,s1,448
    800026c6:	ff3491e3          	bne	s1,s3,800026a8 <kill+0x20>
  }
  return -1;
    800026ca:	557d                	li	a0,-1
    800026cc:	a829                	j	800026e6 <kill+0x5e>
      p->killed = 1;
    800026ce:	4785                	li	a5,1
    800026d0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800026d2:	4c98                	lw	a4,24(s1)
    800026d4:	4789                	li	a5,2
    800026d6:	00f70f63          	beq	a4,a5,800026f4 <kill+0x6c>
      release(&p->lock);
    800026da:	8526                	mv	a0,s1
    800026dc:	ffffe097          	auipc	ra,0xffffe
    800026e0:	722080e7          	jalr	1826(ra) # 80000dfe <release>
      return 0;
    800026e4:	4501                	li	a0,0
}
    800026e6:	70a2                	ld	ra,40(sp)
    800026e8:	7402                	ld	s0,32(sp)
    800026ea:	64e2                	ld	s1,24(sp)
    800026ec:	6942                	ld	s2,16(sp)
    800026ee:	69a2                	ld	s3,8(sp)
    800026f0:	6145                	addi	sp,sp,48
    800026f2:	8082                	ret
        p->state = RUNNABLE;
    800026f4:	478d                	li	a5,3
    800026f6:	cc9c                	sw	a5,24(s1)
    800026f8:	b7cd                	j	800026da <kill+0x52>

00000000800026fa <setkilled>:

void setkilled(struct proc *p)
{
    800026fa:	1101                	addi	sp,sp,-32
    800026fc:	ec06                	sd	ra,24(sp)
    800026fe:	e822                	sd	s0,16(sp)
    80002700:	e426                	sd	s1,8(sp)
    80002702:	1000                	addi	s0,sp,32
    80002704:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	644080e7          	jalr	1604(ra) # 80000d4a <acquire>
  p->killed = 1;
    8000270e:	4785                	li	a5,1
    80002710:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002712:	8526                	mv	a0,s1
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	6ea080e7          	jalr	1770(ra) # 80000dfe <release>
}
    8000271c:	60e2                	ld	ra,24(sp)
    8000271e:	6442                	ld	s0,16(sp)
    80002720:	64a2                	ld	s1,8(sp)
    80002722:	6105                	addi	sp,sp,32
    80002724:	8082                	ret

0000000080002726 <killed>:

int killed(struct proc *p)
{
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	e426                	sd	s1,8(sp)
    8000272e:	e04a                	sd	s2,0(sp)
    80002730:	1000                	addi	s0,sp,32
    80002732:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	616080e7          	jalr	1558(ra) # 80000d4a <acquire>
  k = p->killed;
    8000273c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002740:	8526                	mv	a0,s1
    80002742:	ffffe097          	auipc	ra,0xffffe
    80002746:	6bc080e7          	jalr	1724(ra) # 80000dfe <release>
  return k;
}
    8000274a:	854a                	mv	a0,s2
    8000274c:	60e2                	ld	ra,24(sp)
    8000274e:	6442                	ld	s0,16(sp)
    80002750:	64a2                	ld	s1,8(sp)
    80002752:	6902                	ld	s2,0(sp)
    80002754:	6105                	addi	sp,sp,32
    80002756:	8082                	ret

0000000080002758 <wait>:
{
    80002758:	715d                	addi	sp,sp,-80
    8000275a:	e486                	sd	ra,72(sp)
    8000275c:	e0a2                	sd	s0,64(sp)
    8000275e:	fc26                	sd	s1,56(sp)
    80002760:	f84a                	sd	s2,48(sp)
    80002762:	f44e                	sd	s3,40(sp)
    80002764:	f052                	sd	s4,32(sp)
    80002766:	ec56                	sd	s5,24(sp)
    80002768:	e85a                	sd	s6,16(sp)
    8000276a:	e45e                	sd	s7,8(sp)
    8000276c:	e062                	sd	s8,0(sp)
    8000276e:	0880                	addi	s0,sp,80
    80002770:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002772:	fffff097          	auipc	ra,0xfffff
    80002776:	3ea080e7          	jalr	1002(ra) # 80001b5c <myproc>
    8000277a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000277c:	0022e517          	auipc	a0,0x22e
    80002780:	63450513          	addi	a0,a0,1588 # 80230db0 <wait_lock>
    80002784:	ffffe097          	auipc	ra,0xffffe
    80002788:	5c6080e7          	jalr	1478(ra) # 80000d4a <acquire>
    havekids = 0;
    8000278c:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    8000278e:	4a15                	li	s4,5
        havekids = 1;
    80002790:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002792:	00236997          	auipc	s3,0x236
    80002796:	a3698993          	addi	s3,s3,-1482 # 802381c8 <mlfq>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000279a:	0022ec17          	auipc	s8,0x22e
    8000279e:	616c0c13          	addi	s8,s8,1558 # 80230db0 <wait_lock>
    havekids = 0;
    800027a2:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027a4:	0022f497          	auipc	s1,0x22f
    800027a8:	a2448493          	addi	s1,s1,-1500 # 802311c8 <proc>
    800027ac:	a0bd                	j	8000281a <wait+0xc2>
          pid = pp->pid;
    800027ae:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800027b2:	000b0e63          	beqz	s6,800027ce <wait+0x76>
    800027b6:	4691                	li	a3,4
    800027b8:	02c48613          	addi	a2,s1,44
    800027bc:	85da                	mv	a1,s6
    800027be:	05093503          	ld	a0,80(s2)
    800027c2:	fffff097          	auipc	ra,0xfffff
    800027c6:	01e080e7          	jalr	30(ra) # 800017e0 <copyout>
    800027ca:	02054563          	bltz	a0,800027f4 <wait+0x9c>
          freeproc(pp);
    800027ce:	8526                	mv	a0,s1
    800027d0:	fffff097          	auipc	ra,0xfffff
    800027d4:	53e080e7          	jalr	1342(ra) # 80001d0e <freeproc>
          release(&pp->lock);
    800027d8:	8526                	mv	a0,s1
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	624080e7          	jalr	1572(ra) # 80000dfe <release>
          release(&wait_lock);
    800027e2:	0022e517          	auipc	a0,0x22e
    800027e6:	5ce50513          	addi	a0,a0,1486 # 80230db0 <wait_lock>
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	614080e7          	jalr	1556(ra) # 80000dfe <release>
          return pid;
    800027f2:	a0b5                	j	8000285e <wait+0x106>
            release(&pp->lock);
    800027f4:	8526                	mv	a0,s1
    800027f6:	ffffe097          	auipc	ra,0xffffe
    800027fa:	608080e7          	jalr	1544(ra) # 80000dfe <release>
            release(&wait_lock);
    800027fe:	0022e517          	auipc	a0,0x22e
    80002802:	5b250513          	addi	a0,a0,1458 # 80230db0 <wait_lock>
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	5f8080e7          	jalr	1528(ra) # 80000dfe <release>
            return -1;
    8000280e:	59fd                	li	s3,-1
    80002810:	a0b9                	j	8000285e <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002812:	1c048493          	addi	s1,s1,448
    80002816:	03348463          	beq	s1,s3,8000283e <wait+0xe6>
      if (pp->parent == p)
    8000281a:	7c9c                	ld	a5,56(s1)
    8000281c:	ff279be3          	bne	a5,s2,80002812 <wait+0xba>
        acquire(&pp->lock);
    80002820:	8526                	mv	a0,s1
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	528080e7          	jalr	1320(ra) # 80000d4a <acquire>
        if (pp->state == ZOMBIE)
    8000282a:	4c9c                	lw	a5,24(s1)
    8000282c:	f94781e3          	beq	a5,s4,800027ae <wait+0x56>
        release(&pp->lock);
    80002830:	8526                	mv	a0,s1
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	5cc080e7          	jalr	1484(ra) # 80000dfe <release>
        havekids = 1;
    8000283a:	8756                	mv	a4,s5
    8000283c:	bfd9                	j	80002812 <wait+0xba>
    if (!havekids || killed(p))
    8000283e:	c719                	beqz	a4,8000284c <wait+0xf4>
    80002840:	854a                	mv	a0,s2
    80002842:	00000097          	auipc	ra,0x0
    80002846:	ee4080e7          	jalr	-284(ra) # 80002726 <killed>
    8000284a:	c51d                	beqz	a0,80002878 <wait+0x120>
      release(&wait_lock);
    8000284c:	0022e517          	auipc	a0,0x22e
    80002850:	56450513          	addi	a0,a0,1380 # 80230db0 <wait_lock>
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	5aa080e7          	jalr	1450(ra) # 80000dfe <release>
      return -1;
    8000285c:	59fd                	li	s3,-1
}
    8000285e:	854e                	mv	a0,s3
    80002860:	60a6                	ld	ra,72(sp)
    80002862:	6406                	ld	s0,64(sp)
    80002864:	74e2                	ld	s1,56(sp)
    80002866:	7942                	ld	s2,48(sp)
    80002868:	79a2                	ld	s3,40(sp)
    8000286a:	7a02                	ld	s4,32(sp)
    8000286c:	6ae2                	ld	s5,24(sp)
    8000286e:	6b42                	ld	s6,16(sp)
    80002870:	6ba2                	ld	s7,8(sp)
    80002872:	6c02                	ld	s8,0(sp)
    80002874:	6161                	addi	sp,sp,80
    80002876:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002878:	85e2                	mv	a1,s8
    8000287a:	854a                	mv	a0,s2
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	a7e080e7          	jalr	-1410(ra) # 800022fa <sleep>
    havekids = 0;
    80002884:	bf39                	j	800027a2 <wait+0x4a>

0000000080002886 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002886:	7179                	addi	sp,sp,-48
    80002888:	f406                	sd	ra,40(sp)
    8000288a:	f022                	sd	s0,32(sp)
    8000288c:	ec26                	sd	s1,24(sp)
    8000288e:	e84a                	sd	s2,16(sp)
    80002890:	e44e                	sd	s3,8(sp)
    80002892:	e052                	sd	s4,0(sp)
    80002894:	1800                	addi	s0,sp,48
    80002896:	84aa                	mv	s1,a0
    80002898:	892e                	mv	s2,a1
    8000289a:	89b2                	mv	s3,a2
    8000289c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000289e:	fffff097          	auipc	ra,0xfffff
    800028a2:	2be080e7          	jalr	702(ra) # 80001b5c <myproc>
  if (user_dst)
    800028a6:	c08d                	beqz	s1,800028c8 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800028a8:	86d2                	mv	a3,s4
    800028aa:	864e                	mv	a2,s3
    800028ac:	85ca                	mv	a1,s2
    800028ae:	6928                	ld	a0,80(a0)
    800028b0:	fffff097          	auipc	ra,0xfffff
    800028b4:	f30080e7          	jalr	-208(ra) # 800017e0 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028b8:	70a2                	ld	ra,40(sp)
    800028ba:	7402                	ld	s0,32(sp)
    800028bc:	64e2                	ld	s1,24(sp)
    800028be:	6942                	ld	s2,16(sp)
    800028c0:	69a2                	ld	s3,8(sp)
    800028c2:	6a02                	ld	s4,0(sp)
    800028c4:	6145                	addi	sp,sp,48
    800028c6:	8082                	ret
    memmove((char *)dst, src, len);
    800028c8:	000a061b          	sext.w	a2,s4
    800028cc:	85ce                	mv	a1,s3
    800028ce:	854a                	mv	a0,s2
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	5d2080e7          	jalr	1490(ra) # 80000ea2 <memmove>
    return 0;
    800028d8:	8526                	mv	a0,s1
    800028da:	bff9                	j	800028b8 <either_copyout+0x32>

00000000800028dc <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800028dc:	7179                	addi	sp,sp,-48
    800028de:	f406                	sd	ra,40(sp)
    800028e0:	f022                	sd	s0,32(sp)
    800028e2:	ec26                	sd	s1,24(sp)
    800028e4:	e84a                	sd	s2,16(sp)
    800028e6:	e44e                	sd	s3,8(sp)
    800028e8:	e052                	sd	s4,0(sp)
    800028ea:	1800                	addi	s0,sp,48
    800028ec:	892a                	mv	s2,a0
    800028ee:	84ae                	mv	s1,a1
    800028f0:	89b2                	mv	s3,a2
    800028f2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028f4:	fffff097          	auipc	ra,0xfffff
    800028f8:	268080e7          	jalr	616(ra) # 80001b5c <myproc>
  if (user_src)
    800028fc:	c08d                	beqz	s1,8000291e <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800028fe:	86d2                	mv	a3,s4
    80002900:	864e                	mv	a2,s3
    80002902:	85ca                	mv	a1,s2
    80002904:	6928                	ld	a0,80(a0)
    80002906:	fffff097          	auipc	ra,0xfffff
    8000290a:	fa2080e7          	jalr	-94(ra) # 800018a8 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000290e:	70a2                	ld	ra,40(sp)
    80002910:	7402                	ld	s0,32(sp)
    80002912:	64e2                	ld	s1,24(sp)
    80002914:	6942                	ld	s2,16(sp)
    80002916:	69a2                	ld	s3,8(sp)
    80002918:	6a02                	ld	s4,0(sp)
    8000291a:	6145                	addi	sp,sp,48
    8000291c:	8082                	ret
    memmove(dst, (char *)src, len);
    8000291e:	000a061b          	sext.w	a2,s4
    80002922:	85ce                	mv	a1,s3
    80002924:	854a                	mv	a0,s2
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	57c080e7          	jalr	1404(ra) # 80000ea2 <memmove>
    return 0;
    8000292e:	8526                	mv	a0,s1
    80002930:	bff9                	j	8000290e <either_copyin+0x32>

0000000080002932 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002932:	715d                	addi	sp,sp,-80
    80002934:	e486                	sd	ra,72(sp)
    80002936:	e0a2                	sd	s0,64(sp)
    80002938:	fc26                	sd	s1,56(sp)
    8000293a:	f84a                	sd	s2,48(sp)
    8000293c:	f44e                	sd	s3,40(sp)
    8000293e:	f052                	sd	s4,32(sp)
    80002940:	ec56                	sd	s5,24(sp)
    80002942:	e85a                	sd	s6,16(sp)
    80002944:	e45e                	sd	s7,8(sp)
    80002946:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002948:	00005517          	auipc	a0,0x5
    8000294c:	7c050513          	addi	a0,a0,1984 # 80008108 <digits+0xc8>
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	c3a080e7          	jalr	-966(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002958:	0022f497          	auipc	s1,0x22f
    8000295c:	9c848493          	addi	s1,s1,-1592 # 80231320 <proc+0x158>
    80002960:	00236917          	auipc	s2,0x236
    80002964:	9c090913          	addi	s2,s2,-1600 # 80238320 <mlfq+0x158>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002968:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000296a:	00006997          	auipc	s3,0x6
    8000296e:	95698993          	addi	s3,s3,-1706 # 800082c0 <digits+0x280>
    printf("%d %s %s ctime=%d", p->pid, state, p->name, p->ctime);
    80002972:	00006a97          	auipc	s5,0x6
    80002976:	956a8a93          	addi	s5,s5,-1706 # 800082c8 <digits+0x288>
    printf("\n");
    8000297a:	00005a17          	auipc	s4,0x5
    8000297e:	78ea0a13          	addi	s4,s4,1934 # 80008108 <digits+0xc8>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002982:	00006b97          	auipc	s7,0x6
    80002986:	98eb8b93          	addi	s7,s7,-1650 # 80008310 <states.0>
    8000298a:	a015                	j	800029ae <procdump+0x7c>
    printf("%d %s %s ctime=%d", p->pid, state, p->name, p->ctime);
    8000298c:	4ad8                	lw	a4,20(a3)
    8000298e:	ed86a583          	lw	a1,-296(a3)
    80002992:	8556                	mv	a0,s5
    80002994:	ffffe097          	auipc	ra,0xffffe
    80002998:	bf6080e7          	jalr	-1034(ra) # 8000058a <printf>
    printf("\n");
    8000299c:	8552                	mv	a0,s4
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	bec080e7          	jalr	-1044(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800029a6:	1c048493          	addi	s1,s1,448
    800029aa:	03248263          	beq	s1,s2,800029ce <procdump+0x9c>
    if (p->state == UNUSED)
    800029ae:	86a6                	mv	a3,s1
    800029b0:	ec04a783          	lw	a5,-320(s1)
    800029b4:	dbed                	beqz	a5,800029a6 <procdump+0x74>
      state = "???";
    800029b6:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029b8:	fcfb6ae3          	bltu	s6,a5,8000298c <procdump+0x5a>
    800029bc:	02079713          	slli	a4,a5,0x20
    800029c0:	01d75793          	srli	a5,a4,0x1d
    800029c4:	97de                	add	a5,a5,s7
    800029c6:	6390                	ld	a2,0(a5)
    800029c8:	f271                	bnez	a2,8000298c <procdump+0x5a>
      state = "???";
    800029ca:	864e                	mv	a2,s3
    800029cc:	b7c1                	j	8000298c <procdump+0x5a>
  }
}
    800029ce:	60a6                	ld	ra,72(sp)
    800029d0:	6406                	ld	s0,64(sp)
    800029d2:	74e2                	ld	s1,56(sp)
    800029d4:	7942                	ld	s2,48(sp)
    800029d6:	79a2                	ld	s3,40(sp)
    800029d8:	7a02                	ld	s4,32(sp)
    800029da:	6ae2                	ld	s5,24(sp)
    800029dc:	6b42                	ld	s6,16(sp)
    800029de:	6ba2                	ld	s7,8(sp)
    800029e0:	6161                	addi	sp,sp,80
    800029e2:	8082                	ret

00000000800029e4 <swtch>:
    800029e4:	00153023          	sd	ra,0(a0)
    800029e8:	00253423          	sd	sp,8(a0)
    800029ec:	e900                	sd	s0,16(a0)
    800029ee:	ed04                	sd	s1,24(a0)
    800029f0:	03253023          	sd	s2,32(a0)
    800029f4:	03353423          	sd	s3,40(a0)
    800029f8:	03453823          	sd	s4,48(a0)
    800029fc:	03553c23          	sd	s5,56(a0)
    80002a00:	05653023          	sd	s6,64(a0)
    80002a04:	05753423          	sd	s7,72(a0)
    80002a08:	05853823          	sd	s8,80(a0)
    80002a0c:	05953c23          	sd	s9,88(a0)
    80002a10:	07a53023          	sd	s10,96(a0)
    80002a14:	07b53423          	sd	s11,104(a0)
    80002a18:	0005b083          	ld	ra,0(a1)
    80002a1c:	0085b103          	ld	sp,8(a1)
    80002a20:	6980                	ld	s0,16(a1)
    80002a22:	6d84                	ld	s1,24(a1)
    80002a24:	0205b903          	ld	s2,32(a1)
    80002a28:	0285b983          	ld	s3,40(a1)
    80002a2c:	0305ba03          	ld	s4,48(a1)
    80002a30:	0385ba83          	ld	s5,56(a1)
    80002a34:	0405bb03          	ld	s6,64(a1)
    80002a38:	0485bb83          	ld	s7,72(a1)
    80002a3c:	0505bc03          	ld	s8,80(a1)
    80002a40:	0585bc83          	ld	s9,88(a1)
    80002a44:	0605bd03          	ld	s10,96(a1)
    80002a48:	0685bd83          	ld	s11,104(a1)
    80002a4c:	8082                	ret

0000000080002a4e <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002a4e:	1141                	addi	sp,sp,-16
    80002a50:	e406                	sd	ra,8(sp)
    80002a52:	e022                	sd	s0,0(sp)
    80002a54:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a56:	00006597          	auipc	a1,0x6
    80002a5a:	8ea58593          	addi	a1,a1,-1814 # 80008340 <states.0+0x30>
    80002a5e:	00236517          	auipc	a0,0x236
    80002a62:	19250513          	addi	a0,a0,402 # 80238bf0 <tickslock>
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	254080e7          	jalr	596(ra) # 80000cba <initlock>
}
    80002a6e:	60a2                	ld	ra,8(sp)
    80002a70:	6402                	ld	s0,0(sp)
    80002a72:	0141                	addi	sp,sp,16
    80002a74:	8082                	ret

0000000080002a76 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002a76:	1141                	addi	sp,sp,-16
    80002a78:	e422                	sd	s0,8(sp)
    80002a7a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0"
    80002a7c:	00003797          	auipc	a5,0x3
    80002a80:	7d478793          	addi	a5,a5,2004 # 80006250 <kernelvec>
    80002a84:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a88:	6422                	ld	s0,8(sp)
    80002a8a:	0141                	addi	sp,sp,16
    80002a8c:	8082                	ret

0000000080002a8e <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002a8e:	1141                	addi	sp,sp,-16
    80002a90:	e406                	sd	ra,8(sp)
    80002a92:	e022                	sd	s0,0(sp)
    80002a94:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a96:	fffff097          	auipc	ra,0xfffff
    80002a9a:	0c6080e7          	jalr	198(ra) # 80001b5c <myproc>
  asm volatile("csrr %0, sstatus"
    80002a9e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002aa2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    80002aa4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002aa8:	00004697          	auipc	a3,0x4
    80002aac:	55868693          	addi	a3,a3,1368 # 80007000 <_trampoline>
    80002ab0:	00004717          	auipc	a4,0x4
    80002ab4:	55070713          	addi	a4,a4,1360 # 80007000 <_trampoline>
    80002ab8:	8f15                	sub	a4,a4,a3
    80002aba:	040007b7          	lui	a5,0x4000
    80002abe:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002ac0:	07b2                	slli	a5,a5,0xc
    80002ac2:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0"
    80002ac4:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ac8:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp"
    80002aca:	18002673          	csrr	a2,satp
    80002ace:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ad0:	6d30                	ld	a2,88(a0)
    80002ad2:	6138                	ld	a4,64(a0)
    80002ad4:	6585                	lui	a1,0x1
    80002ad6:	972e                	add	a4,a4,a1
    80002ad8:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ada:	6d38                	ld	a4,88(a0)
    80002adc:	00000617          	auipc	a2,0x0
    80002ae0:	2fa60613          	addi	a2,a2,762 # 80002dd6 <usertrap>
    80002ae4:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002ae6:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp"
    80002ae8:	8612                	mv	a2,tp
    80002aea:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus"
    80002aec:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002af0:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002af4:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0"
    80002af8:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002afc:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0"
    80002afe:	6f18                	ld	a4,24(a4)
    80002b00:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b04:	6928                	ld	a0,80(a0)
    80002b06:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b08:	00004717          	auipc	a4,0x4
    80002b0c:	59470713          	addi	a4,a4,1428 # 8000709c <userret>
    80002b10:	8f15                	sub	a4,a4,a3
    80002b12:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b14:	577d                	li	a4,-1
    80002b16:	177e                	slli	a4,a4,0x3f
    80002b18:	8d59                	or	a0,a0,a4
    80002b1a:	9782                	jalr	a5
}
    80002b1c:	60a2                	ld	ra,8(sp)
    80002b1e:	6402                	ld	s0,0(sp)
    80002b20:	0141                	addi	sp,sp,16
    80002b22:	8082                	ret

0000000080002b24 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002b24:	1141                	addi	sp,sp,-16
    80002b26:	e406                	sd	ra,8(sp)
    80002b28:	e022                	sd	s0,0(sp)
    80002b2a:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    80002b2c:	00236517          	auipc	a0,0x236
    80002b30:	0c450513          	addi	a0,a0,196 # 80238bf0 <tickslock>
    80002b34:	ffffe097          	auipc	ra,0xffffe
    80002b38:	216080e7          	jalr	534(ra) # 80000d4a <acquire>
  ticks++;
    80002b3c:	00006717          	auipc	a4,0x6
    80002b40:	fdc70713          	addi	a4,a4,-36 # 80008b18 <ticks>
    80002b44:	431c                	lw	a5,0(a4)
    80002b46:	2785                	addiw	a5,a5,1
    80002b48:	c31c                	sw	a5,0(a4)
  update_time();
    80002b4a:	fffff097          	auipc	ra,0xfffff
    80002b4e:	5a0080e7          	jalr	1440(ra) # 800020ea <update_time>
  if (myproc() != 0)
    80002b52:	fffff097          	auipc	ra,0xfffff
    80002b56:	00a080e7          	jalr	10(ra) # 80001b5c <myproc>
    80002b5a:	c11d                	beqz	a0,80002b80 <clockintr+0x5c>
  {
    myproc()->running_ticks++;
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	000080e7          	jalr	ra # 80001b5c <myproc>
    80002b64:	18852783          	lw	a5,392(a0)
    80002b68:	2785                	addiw	a5,a5,1
    80002b6a:	18f52423          	sw	a5,392(a0)
    myproc()->change_queue--;
    80002b6e:	fffff097          	auipc	ra,0xfffff
    80002b72:	fee080e7          	jalr	-18(ra) # 80001b5c <myproc>
    80002b76:	19452783          	lw	a5,404(a0)
    80002b7a:	37fd                	addiw	a5,a5,-1
    80002b7c:	18f52a23          	sw	a5,404(a0)
  }
  wakeup(&ticks);
    80002b80:	00006517          	auipc	a0,0x6
    80002b84:	f9850513          	addi	a0,a0,-104 # 80008b18 <ticks>
    80002b88:	00000097          	auipc	ra,0x0
    80002b8c:	92e080e7          	jalr	-1746(ra) # 800024b6 <wakeup>
  release(&tickslock);
    80002b90:	00236517          	auipc	a0,0x236
    80002b94:	06050513          	addi	a0,a0,96 # 80238bf0 <tickslock>
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	266080e7          	jalr	614(ra) # 80000dfe <release>
}
    80002ba0:	60a2                	ld	ra,8(sp)
    80002ba2:	6402                	ld	s0,0(sp)
    80002ba4:	0141                	addi	sp,sp,16
    80002ba6:	8082                	ret

0000000080002ba8 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002ba8:	1101                	addi	sp,sp,-32
    80002baa:	ec06                	sd	ra,24(sp)
    80002bac:	e822                	sd	s0,16(sp)
    80002bae:	e426                	sd	s1,8(sp)
    80002bb0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause"
    80002bb2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002bb6:	00074d63          	bltz	a4,80002bd0 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002bba:	57fd                	li	a5,-1
    80002bbc:	17fe                	slli	a5,a5,0x3f
    80002bbe:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002bc0:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002bc2:	06f70363          	beq	a4,a5,80002c28 <devintr+0x80>
  }
}
    80002bc6:	60e2                	ld	ra,24(sp)
    80002bc8:	6442                	ld	s0,16(sp)
    80002bca:	64a2                	ld	s1,8(sp)
    80002bcc:	6105                	addi	sp,sp,32
    80002bce:	8082                	ret
      (scause & 0xff) == 9)
    80002bd0:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002bd4:	46a5                	li	a3,9
    80002bd6:	fed792e3          	bne	a5,a3,80002bba <devintr+0x12>
    int irq = plic_claim();
    80002bda:	00003097          	auipc	ra,0x3
    80002bde:	77e080e7          	jalr	1918(ra) # 80006358 <plic_claim>
    80002be2:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002be4:	47a9                	li	a5,10
    80002be6:	02f50763          	beq	a0,a5,80002c14 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002bea:	4785                	li	a5,1
    80002bec:	02f50963          	beq	a0,a5,80002c1e <devintr+0x76>
    return 1;
    80002bf0:	4505                	li	a0,1
    else if (irq)
    80002bf2:	d8f1                	beqz	s1,80002bc6 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bf4:	85a6                	mv	a1,s1
    80002bf6:	00005517          	auipc	a0,0x5
    80002bfa:	75250513          	addi	a0,a0,1874 # 80008348 <states.0+0x38>
    80002bfe:	ffffe097          	auipc	ra,0xffffe
    80002c02:	98c080e7          	jalr	-1652(ra) # 8000058a <printf>
      plic_complete(irq);
    80002c06:	8526                	mv	a0,s1
    80002c08:	00003097          	auipc	ra,0x3
    80002c0c:	774080e7          	jalr	1908(ra) # 8000637c <plic_complete>
    return 1;
    80002c10:	4505                	li	a0,1
    80002c12:	bf55                	j	80002bc6 <devintr+0x1e>
      uartintr();
    80002c14:	ffffe097          	auipc	ra,0xffffe
    80002c18:	d84080e7          	jalr	-636(ra) # 80000998 <uartintr>
    80002c1c:	b7ed                	j	80002c06 <devintr+0x5e>
      virtio_disk_intr();
    80002c1e:	00004097          	auipc	ra,0x4
    80002c22:	efa080e7          	jalr	-262(ra) # 80006b18 <virtio_disk_intr>
    80002c26:	b7c5                	j	80002c06 <devintr+0x5e>
    if (cpuid() == 0)
    80002c28:	fffff097          	auipc	ra,0xfffff
    80002c2c:	f08080e7          	jalr	-248(ra) # 80001b30 <cpuid>
    80002c30:	c901                	beqz	a0,80002c40 <devintr+0x98>
  asm volatile("csrr %0, sip"
    80002c32:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c36:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0"
    80002c38:	14479073          	csrw	sip,a5
    return 2;
    80002c3c:	4509                	li	a0,2
    80002c3e:	b761                	j	80002bc6 <devintr+0x1e>
      clockintr();
    80002c40:	00000097          	auipc	ra,0x0
    80002c44:	ee4080e7          	jalr	-284(ra) # 80002b24 <clockintr>
    80002c48:	b7ed                	j	80002c32 <devintr+0x8a>

0000000080002c4a <kerneltrap>:
{
    80002c4a:	7179                	addi	sp,sp,-48
    80002c4c:	f406                	sd	ra,40(sp)
    80002c4e:	f022                	sd	s0,32(sp)
    80002c50:	ec26                	sd	s1,24(sp)
    80002c52:	e84a                	sd	s2,16(sp)
    80002c54:	e44e                	sd	s3,8(sp)
    80002c56:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc"
    80002c58:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus"
    80002c5c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause"
    80002c60:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002c64:	1004f793          	andi	a5,s1,256
    80002c68:	cb85                	beqz	a5,80002c98 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus"
    80002c6a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c6e:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002c70:	ef85                	bnez	a5,80002ca8 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002c72:	00000097          	auipc	ra,0x0
    80002c76:	f36080e7          	jalr	-202(ra) # 80002ba8 <devintr>
    80002c7a:	cd1d                	beqz	a0,80002cb8 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c7c:	4789                	li	a5,2
    80002c7e:	06f50a63          	beq	a0,a5,80002cf2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0"
    80002c82:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0"
    80002c86:	10049073          	csrw	sstatus,s1
}
    80002c8a:	70a2                	ld	ra,40(sp)
    80002c8c:	7402                	ld	s0,32(sp)
    80002c8e:	64e2                	ld	s1,24(sp)
    80002c90:	6942                	ld	s2,16(sp)
    80002c92:	69a2                	ld	s3,8(sp)
    80002c94:	6145                	addi	sp,sp,48
    80002c96:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c98:	00005517          	auipc	a0,0x5
    80002c9c:	6d050513          	addi	a0,a0,1744 # 80008368 <states.0+0x58>
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	8a0080e7          	jalr	-1888(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ca8:	00005517          	auipc	a0,0x5
    80002cac:	6e850513          	addi	a0,a0,1768 # 80008390 <states.0+0x80>
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	890080e7          	jalr	-1904(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002cb8:	85ce                	mv	a1,s3
    80002cba:	00005517          	auipc	a0,0x5
    80002cbe:	6f650513          	addi	a0,a0,1782 # 800083b0 <states.0+0xa0>
    80002cc2:	ffffe097          	auipc	ra,0xffffe
    80002cc6:	8c8080e7          	jalr	-1848(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002cca:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002cce:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cd2:	00005517          	auipc	a0,0x5
    80002cd6:	6ee50513          	addi	a0,a0,1774 # 800083c0 <states.0+0xb0>
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	8b0080e7          	jalr	-1872(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002ce2:	00005517          	auipc	a0,0x5
    80002ce6:	6f650513          	addi	a0,a0,1782 # 800083d8 <states.0+0xc8>
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	856080e7          	jalr	-1962(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cf2:	fffff097          	auipc	ra,0xfffff
    80002cf6:	e6a080e7          	jalr	-406(ra) # 80001b5c <myproc>
    80002cfa:	d541                	beqz	a0,80002c82 <kerneltrap+0x38>
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	e60080e7          	jalr	-416(ra) # 80001b5c <myproc>
    80002d04:	4d18                	lw	a4,24(a0)
    80002d06:	4791                	li	a5,4
    80002d08:	f6f71de3          	bne	a4,a5,80002c82 <kerneltrap+0x38>
    yield();
    80002d0c:	fffff097          	auipc	ra,0xfffff
    80002d10:	5b2080e7          	jalr	1458(ra) # 800022be <yield>
    80002d14:	b7bd                	j	80002c82 <kerneltrap+0x38>

0000000080002d16 <pgfault>:

// -1 means cannot alloc mem
// -2 means the address is invalid
// 0 means ok
int pgfault(uint64 va, pagetable_t pagetable)
{
    80002d16:	7179                	addi	sp,sp,-48
    80002d18:	f406                	sd	ra,40(sp)
    80002d1a:	f022                	sd	s0,32(sp)
    80002d1c:	ec26                	sd	s1,24(sp)
    80002d1e:	e84a                	sd	s2,16(sp)
    80002d20:	e44e                	sd	s3,8(sp)
    80002d22:	e052                	sd	s4,0(sp)
    80002d24:	1800                	addi	s0,sp,48
    80002d26:	84aa                	mv	s1,a0
    80002d28:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d2a:	fffff097          	auipc	ra,0xfffff
    80002d2e:	e32080e7          	jalr	-462(ra) # 80001b5c <myproc>
  if (va >= MAXVA || (va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE && va <= PGROUNDDOWN(p->trapframe->sp)))
    80002d32:	57fd                	li	a5,-1
    80002d34:	83e9                	srli	a5,a5,0x1a
    80002d36:	0897e663          	bltu	a5,s1,80002dc2 <pgfault+0xac>
    80002d3a:	6d38                	ld	a4,88(a0)
    80002d3c:	77fd                	lui	a5,0xfffff
    80002d3e:	7b18                	ld	a4,48(a4)
    80002d40:	8f7d                	and	a4,a4,a5
    80002d42:	97ba                	add	a5,a5,a4
    80002d44:	00f4e463          	bltu	s1,a5,80002d4c <pgfault+0x36>
    80002d48:	06977f63          	bgeu	a4,s1,80002dc6 <pgfault+0xb0>
  {
    return -2;
  }
  va = PGROUNDDOWN(va);
  pte_t *pte = walk(pagetable, va, 0);
    80002d4c:	4601                	li	a2,0
    80002d4e:	75fd                	lui	a1,0xfffff
    80002d50:	8de5                	and	a1,a1,s1
    80002d52:	854a                	mv	a0,s2
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	3d6080e7          	jalr	982(ra) # 8000112a <walk>
    80002d5c:	84aa                	mv	s1,a0
  if (pte == 0)
    80002d5e:	c535                	beqz	a0,80002dca <pgfault+0xb4>
    return -1;
  
  uint64 pa = PTE2PA(*pte);
    80002d60:	611c                	ld	a5,0(a0)
    80002d62:	00a7d913          	srli	s2,a5,0xa
    80002d66:	0932                	slli	s2,s2,0xc
  if (pa == 0)
    80002d68:	06090363          	beqz	s2,80002dce <pgfault+0xb8>
  {
    return -1;
  }
  uint flags = PTE_FLAGS(*pte);
    80002d6c:	0007871b          	sext.w	a4,a5
  if (flags & PTE_C)
    80002d70:	1007f793          	andi	a5,a5,256
    //   printf("sometthing is wrong in mappages in trap.\n");
    // }

    return 0;
  }
  return 0;
    80002d74:	4501                	li	a0,0
  if (flags & PTE_C)
    80002d76:	eb89                	bnez	a5,80002d88 <pgfault+0x72>
}
    80002d78:	70a2                	ld	ra,40(sp)
    80002d7a:	7402                	ld	s0,32(sp)
    80002d7c:	64e2                	ld	s1,24(sp)
    80002d7e:	6942                	ld	s2,16(sp)
    80002d80:	69a2                	ld	s3,8(sp)
    80002d82:	6a02                	ld	s4,0(sp)
    80002d84:	6145                	addi	sp,sp,48
    80002d86:	8082                	ret
    flags = (flags | PTE_W) & (~PTE_C);
    80002d88:	2ff77713          	andi	a4,a4,767
    80002d8c:	00476993          	ori	s3,a4,4
    char *mem = kalloc();
    80002d90:	ffffe097          	auipc	ra,0xffffe
    80002d94:	ec0080e7          	jalr	-320(ra) # 80000c50 <kalloc>
    80002d98:	8a2a                	mv	s4,a0
    if (mem == 0)
    80002d9a:	cd05                	beqz	a0,80002dd2 <pgfault+0xbc>
    memmove(mem, (void *)pa, PGSIZE);
    80002d9c:	6605                	lui	a2,0x1
    80002d9e:	85ca                	mv	a1,s2
    80002da0:	ffffe097          	auipc	ra,0xffffe
    80002da4:	102080e7          	jalr	258(ra) # 80000ea2 <memmove>
    *pte = PA2PTE(mem) | flags;
    80002da8:	00ca5a13          	srli	s4,s4,0xc
    80002dac:	0a2a                	slli	s4,s4,0xa
    80002dae:	0149e733          	or	a4,s3,s4
    80002db2:	e098                	sd	a4,0(s1)
    kfree((void *)pa);
    80002db4:	854a                	mv	a0,s2
    80002db6:	ffffe097          	auipc	ra,0xffffe
    80002dba:	cc2080e7          	jalr	-830(ra) # 80000a78 <kfree>
    return 0;
    80002dbe:	4501                	li	a0,0
    80002dc0:	bf65                	j	80002d78 <pgfault+0x62>
    return -2;
    80002dc2:	5579                	li	a0,-2
    80002dc4:	bf55                	j	80002d78 <pgfault+0x62>
    80002dc6:	5579                	li	a0,-2
    80002dc8:	bf45                	j	80002d78 <pgfault+0x62>
    return -1;
    80002dca:	557d                	li	a0,-1
    80002dcc:	b775                	j	80002d78 <pgfault+0x62>
    return -1;
    80002dce:	557d                	li	a0,-1
    80002dd0:	b765                	j	80002d78 <pgfault+0x62>
      return -1;
    80002dd2:	557d                	li	a0,-1
    80002dd4:	b755                	j	80002d78 <pgfault+0x62>

0000000080002dd6 <usertrap>:
{
    80002dd6:	1101                	addi	sp,sp,-32
    80002dd8:	ec06                	sd	ra,24(sp)
    80002dda:	e822                	sd	s0,16(sp)
    80002ddc:	e426                	sd	s1,8(sp)
    80002dde:	e04a                	sd	s2,0(sp)
    80002de0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80002de2:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002de6:	1007f793          	andi	a5,a5,256
    80002dea:	efad                	bnez	a5,80002e64 <usertrap+0x8e>
  asm volatile("csrw stvec, %0"
    80002dec:	00003797          	auipc	a5,0x3
    80002df0:	46478793          	addi	a5,a5,1124 # 80006250 <kernelvec>
    80002df4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002df8:	fffff097          	auipc	ra,0xfffff
    80002dfc:	d64080e7          	jalr	-668(ra) # 80001b5c <myproc>
    80002e00:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e02:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc"
    80002e04:	14102773          	csrr	a4,sepc
    80002e08:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause"
    80002e0a:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002e0e:	47a1                	li	a5,8
    80002e10:	06f70263          	beq	a4,a5,80002e74 <usertrap+0x9e>
  else if ((which_dev = devintr()) != 0)
    80002e14:	00000097          	auipc	ra,0x0
    80002e18:	d94080e7          	jalr	-620(ra) # 80002ba8 <devintr>
    80002e1c:	892a                	mv	s2,a0
    80002e1e:	ed5d                	bnez	a0,80002edc <usertrap+0x106>
    80002e20:	14202773          	csrr	a4,scause
  else if (r_scause() == 15)
    80002e24:	47bd                	li	a5,15
    80002e26:	0af70063          	beq	a4,a5,80002ec6 <usertrap+0xf0>
    80002e2a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e2e:	5890                	lw	a2,48(s1)
    80002e30:	00005517          	auipc	a0,0x5
    80002e34:	5d850513          	addi	a0,a0,1496 # 80008408 <states.0+0xf8>
    80002e38:	ffffd097          	auipc	ra,0xffffd
    80002e3c:	752080e7          	jalr	1874(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc"
    80002e40:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002e44:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e48:	00005517          	auipc	a0,0x5
    80002e4c:	5f050513          	addi	a0,a0,1520 # 80008438 <states.0+0x128>
    80002e50:	ffffd097          	auipc	ra,0xffffd
    80002e54:	73a080e7          	jalr	1850(ra) # 8000058a <printf>
    setkilled(p);
    80002e58:	8526                	mv	a0,s1
    80002e5a:	00000097          	auipc	ra,0x0
    80002e5e:	8a0080e7          	jalr	-1888(ra) # 800026fa <setkilled>
    80002e62:	a825                	j	80002e9a <usertrap+0xc4>
    panic("usertrap: not from user mode");
    80002e64:	00005517          	auipc	a0,0x5
    80002e68:	58450513          	addi	a0,a0,1412 # 800083e8 <states.0+0xd8>
    80002e6c:	ffffd097          	auipc	ra,0xffffd
    80002e70:	6d4080e7          	jalr	1748(ra) # 80000540 <panic>
    if (killed(p))
    80002e74:	00000097          	auipc	ra,0x0
    80002e78:	8b2080e7          	jalr	-1870(ra) # 80002726 <killed>
    80002e7c:	ed1d                	bnez	a0,80002eba <usertrap+0xe4>
    p->trapframe->epc += 4;
    80002e7e:	6cb8                	ld	a4,88(s1)
    80002e80:	6f1c                	ld	a5,24(a4)
    80002e82:	0791                	addi	a5,a5,4
    80002e84:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus"
    80002e86:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002e8a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002e8e:	10079073          	csrw	sstatus,a5
    syscall();
    80002e92:	00000097          	auipc	ra,0x0
    80002e96:	240080e7          	jalr	576(ra) # 800030d2 <syscall>
  if (killed(p))
    80002e9a:	8526                	mv	a0,s1
    80002e9c:	00000097          	auipc	ra,0x0
    80002ea0:	88a080e7          	jalr	-1910(ra) # 80002726 <killed>
    80002ea4:	e139                	bnez	a0,80002eea <usertrap+0x114>
  usertrapret();
    80002ea6:	00000097          	auipc	ra,0x0
    80002eaa:	be8080e7          	jalr	-1048(ra) # 80002a8e <usertrapret>
}
    80002eae:	60e2                	ld	ra,24(sp)
    80002eb0:	6442                	ld	s0,16(sp)
    80002eb2:	64a2                	ld	s1,8(sp)
    80002eb4:	6902                	ld	s2,0(sp)
    80002eb6:	6105                	addi	sp,sp,32
    80002eb8:	8082                	ret
      exit(-1);
    80002eba:	557d                	li	a0,-1
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	6ea080e7          	jalr	1770(ra) # 800025a6 <exit>
    80002ec4:	bf6d                	j	80002e7e <usertrap+0xa8>
  asm volatile("csrr %0, stval"
    80002ec6:	14302573          	csrr	a0,stval
    int r = pgfault(r_stval(), p->pagetable);
    80002eca:	68ac                	ld	a1,80(s1)
    80002ecc:	00000097          	auipc	ra,0x0
    80002ed0:	e4a080e7          	jalr	-438(ra) # 80002d16 <pgfault>
    if (r)
    80002ed4:	d179                	beqz	a0,80002e9a <usertrap+0xc4>
      p->killed = 1;
    80002ed6:	4785                	li	a5,1
    80002ed8:	d49c                	sw	a5,40(s1)
    80002eda:	b7c1                	j	80002e9a <usertrap+0xc4>
  if (killed(p))
    80002edc:	8526                	mv	a0,s1
    80002ede:	00000097          	auipc	ra,0x0
    80002ee2:	848080e7          	jalr	-1976(ra) # 80002726 <killed>
    80002ee6:	c901                	beqz	a0,80002ef6 <usertrap+0x120>
    80002ee8:	a011                	j	80002eec <usertrap+0x116>
    80002eea:	4901                	li	s2,0
    exit(-1);
    80002eec:	557d                	li	a0,-1
    80002eee:	fffff097          	auipc	ra,0xfffff
    80002ef2:	6b8080e7          	jalr	1720(ra) # 800025a6 <exit>
  if (which_dev == 2)
    80002ef6:	4789                	li	a5,2
    80002ef8:	faf917e3          	bne	s2,a5,80002ea6 <usertrap+0xd0>
    if (p->interval)
    80002efc:	1a84a703          	lw	a4,424(s1)
    80002f00:	cf19                	beqz	a4,80002f1e <usertrap+0x148>
      p->now_ticks++;
    80002f02:	1ac4a783          	lw	a5,428(s1)
    80002f06:	2785                	addiw	a5,a5,1
    80002f08:	0007869b          	sext.w	a3,a5
    80002f0c:	1af4a623          	sw	a5,428(s1)
      if (!p->sigalarm_status && p->interval > 0 && p->now_ticks >= p->interval)
    80002f10:	1b84a783          	lw	a5,440(s1)
    80002f14:	e789                	bnez	a5,80002f1e <usertrap+0x148>
    80002f16:	00e05463          	blez	a4,80002f1e <usertrap+0x148>
    80002f1a:	00e6d763          	bge	a3,a4,80002f28 <usertrap+0x152>
    yield();
    80002f1e:	fffff097          	auipc	ra,0xfffff
    80002f22:	3a0080e7          	jalr	928(ra) # 800022be <yield>
    80002f26:	b741                	j	80002ea6 <usertrap+0xd0>
        p->now_ticks = 0;
    80002f28:	1a04a623          	sw	zero,428(s1)
        p->sigalarm_status = 1;
    80002f2c:	4785                	li	a5,1
    80002f2e:	1af4ac23          	sw	a5,440(s1)
        p->alarm_trapframe = kalloc();
    80002f32:	ffffe097          	auipc	ra,0xffffe
    80002f36:	d1e080e7          	jalr	-738(ra) # 80000c50 <kalloc>
    80002f3a:	1aa4b823          	sd	a0,432(s1)
        memmove(p->alarm_trapframe, p->trapframe, PGSIZE);
    80002f3e:	6605                	lui	a2,0x1
    80002f40:	6cac                	ld	a1,88(s1)
    80002f42:	ffffe097          	auipc	ra,0xffffe
    80002f46:	f60080e7          	jalr	-160(ra) # 80000ea2 <memmove>
        p->trapframe->epc = p->handler;
    80002f4a:	6cbc                	ld	a5,88(s1)
    80002f4c:	1a04b703          	ld	a4,416(s1)
    80002f50:	ef98                	sd	a4,24(a5)
    80002f52:	b7f1                	j	80002f1e <usertrap+0x148>

0000000080002f54 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f54:	1101                	addi	sp,sp,-32
    80002f56:	ec06                	sd	ra,24(sp)
    80002f58:	e822                	sd	s0,16(sp)
    80002f5a:	e426                	sd	s1,8(sp)
    80002f5c:	1000                	addi	s0,sp,32
    80002f5e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f60:	fffff097          	auipc	ra,0xfffff
    80002f64:	bfc080e7          	jalr	-1028(ra) # 80001b5c <myproc>
  switch (n)
    80002f68:	4795                	li	a5,5
    80002f6a:	0497e163          	bltu	a5,s1,80002fac <argraw+0x58>
    80002f6e:	048a                	slli	s1,s1,0x2
    80002f70:	00005717          	auipc	a4,0x5
    80002f74:	61070713          	addi	a4,a4,1552 # 80008580 <states.0+0x270>
    80002f78:	94ba                	add	s1,s1,a4
    80002f7a:	409c                	lw	a5,0(s1)
    80002f7c:	97ba                	add	a5,a5,a4
    80002f7e:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002f80:	6d3c                	ld	a5,88(a0)
    80002f82:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002f84:	60e2                	ld	ra,24(sp)
    80002f86:	6442                	ld	s0,16(sp)
    80002f88:	64a2                	ld	s1,8(sp)
    80002f8a:	6105                	addi	sp,sp,32
    80002f8c:	8082                	ret
    return p->trapframe->a1;
    80002f8e:	6d3c                	ld	a5,88(a0)
    80002f90:	7fa8                	ld	a0,120(a5)
    80002f92:	bfcd                	j	80002f84 <argraw+0x30>
    return p->trapframe->a2;
    80002f94:	6d3c                	ld	a5,88(a0)
    80002f96:	63c8                	ld	a0,128(a5)
    80002f98:	b7f5                	j	80002f84 <argraw+0x30>
    return p->trapframe->a3;
    80002f9a:	6d3c                	ld	a5,88(a0)
    80002f9c:	67c8                	ld	a0,136(a5)
    80002f9e:	b7dd                	j	80002f84 <argraw+0x30>
    return p->trapframe->a4;
    80002fa0:	6d3c                	ld	a5,88(a0)
    80002fa2:	6bc8                	ld	a0,144(a5)
    80002fa4:	b7c5                	j	80002f84 <argraw+0x30>
    return p->trapframe->a5;
    80002fa6:	6d3c                	ld	a5,88(a0)
    80002fa8:	6fc8                	ld	a0,152(a5)
    80002faa:	bfe9                	j	80002f84 <argraw+0x30>
  panic("argraw");
    80002fac:	00005517          	auipc	a0,0x5
    80002fb0:	4ac50513          	addi	a0,a0,1196 # 80008458 <states.0+0x148>
    80002fb4:	ffffd097          	auipc	ra,0xffffd
    80002fb8:	58c080e7          	jalr	1420(ra) # 80000540 <panic>

0000000080002fbc <fetchaddr>:
{
    80002fbc:	1101                	addi	sp,sp,-32
    80002fbe:	ec06                	sd	ra,24(sp)
    80002fc0:	e822                	sd	s0,16(sp)
    80002fc2:	e426                	sd	s1,8(sp)
    80002fc4:	e04a                	sd	s2,0(sp)
    80002fc6:	1000                	addi	s0,sp,32
    80002fc8:	84aa                	mv	s1,a0
    80002fca:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002fcc:	fffff097          	auipc	ra,0xfffff
    80002fd0:	b90080e7          	jalr	-1136(ra) # 80001b5c <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002fd4:	653c                	ld	a5,72(a0)
    80002fd6:	02f4f863          	bgeu	s1,a5,80003006 <fetchaddr+0x4a>
    80002fda:	00848713          	addi	a4,s1,8
    80002fde:	02e7e663          	bltu	a5,a4,8000300a <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002fe2:	46a1                	li	a3,8
    80002fe4:	8626                	mv	a2,s1
    80002fe6:	85ca                	mv	a1,s2
    80002fe8:	6928                	ld	a0,80(a0)
    80002fea:	fffff097          	auipc	ra,0xfffff
    80002fee:	8be080e7          	jalr	-1858(ra) # 800018a8 <copyin>
    80002ff2:	00a03533          	snez	a0,a0
    80002ff6:	40a00533          	neg	a0,a0
}
    80002ffa:	60e2                	ld	ra,24(sp)
    80002ffc:	6442                	ld	s0,16(sp)
    80002ffe:	64a2                	ld	s1,8(sp)
    80003000:	6902                	ld	s2,0(sp)
    80003002:	6105                	addi	sp,sp,32
    80003004:	8082                	ret
    return -1;
    80003006:	557d                	li	a0,-1
    80003008:	bfcd                	j	80002ffa <fetchaddr+0x3e>
    8000300a:	557d                	li	a0,-1
    8000300c:	b7fd                	j	80002ffa <fetchaddr+0x3e>

000000008000300e <fetchstr>:
{
    8000300e:	7179                	addi	sp,sp,-48
    80003010:	f406                	sd	ra,40(sp)
    80003012:	f022                	sd	s0,32(sp)
    80003014:	ec26                	sd	s1,24(sp)
    80003016:	e84a                	sd	s2,16(sp)
    80003018:	e44e                	sd	s3,8(sp)
    8000301a:	1800                	addi	s0,sp,48
    8000301c:	892a                	mv	s2,a0
    8000301e:	84ae                	mv	s1,a1
    80003020:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003022:	fffff097          	auipc	ra,0xfffff
    80003026:	b3a080e7          	jalr	-1222(ra) # 80001b5c <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    8000302a:	86ce                	mv	a3,s3
    8000302c:	864a                	mv	a2,s2
    8000302e:	85a6                	mv	a1,s1
    80003030:	6928                	ld	a0,80(a0)
    80003032:	fffff097          	auipc	ra,0xfffff
    80003036:	904080e7          	jalr	-1788(ra) # 80001936 <copyinstr>
    8000303a:	00054e63          	bltz	a0,80003056 <fetchstr+0x48>
  return strlen(buf);
    8000303e:	8526                	mv	a0,s1
    80003040:	ffffe097          	auipc	ra,0xffffe
    80003044:	f82080e7          	jalr	-126(ra) # 80000fc2 <strlen>
}
    80003048:	70a2                	ld	ra,40(sp)
    8000304a:	7402                	ld	s0,32(sp)
    8000304c:	64e2                	ld	s1,24(sp)
    8000304e:	6942                	ld	s2,16(sp)
    80003050:	69a2                	ld	s3,8(sp)
    80003052:	6145                	addi	sp,sp,48
    80003054:	8082                	ret
    return -1;
    80003056:	557d                	li	a0,-1
    80003058:	bfc5                	j	80003048 <fetchstr+0x3a>

000000008000305a <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    8000305a:	1101                	addi	sp,sp,-32
    8000305c:	ec06                	sd	ra,24(sp)
    8000305e:	e822                	sd	s0,16(sp)
    80003060:	e426                	sd	s1,8(sp)
    80003062:	1000                	addi	s0,sp,32
    80003064:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003066:	00000097          	auipc	ra,0x0
    8000306a:	eee080e7          	jalr	-274(ra) # 80002f54 <argraw>
    8000306e:	c088                	sw	a0,0(s1)
}
    80003070:	60e2                	ld	ra,24(sp)
    80003072:	6442                	ld	s0,16(sp)
    80003074:	64a2                	ld	s1,8(sp)
    80003076:	6105                	addi	sp,sp,32
    80003078:	8082                	ret

000000008000307a <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    8000307a:	1101                	addi	sp,sp,-32
    8000307c:	ec06                	sd	ra,24(sp)
    8000307e:	e822                	sd	s0,16(sp)
    80003080:	e426                	sd	s1,8(sp)
    80003082:	1000                	addi	s0,sp,32
    80003084:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003086:	00000097          	auipc	ra,0x0
    8000308a:	ece080e7          	jalr	-306(ra) # 80002f54 <argraw>
    8000308e:	e088                	sd	a0,0(s1)
}
    80003090:	60e2                	ld	ra,24(sp)
    80003092:	6442                	ld	s0,16(sp)
    80003094:	64a2                	ld	s1,8(sp)
    80003096:	6105                	addi	sp,sp,32
    80003098:	8082                	ret

000000008000309a <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    8000309a:	7179                	addi	sp,sp,-48
    8000309c:	f406                	sd	ra,40(sp)
    8000309e:	f022                	sd	s0,32(sp)
    800030a0:	ec26                	sd	s1,24(sp)
    800030a2:	e84a                	sd	s2,16(sp)
    800030a4:	1800                	addi	s0,sp,48
    800030a6:	84ae                	mv	s1,a1
    800030a8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800030aa:	fd840593          	addi	a1,s0,-40
    800030ae:	00000097          	auipc	ra,0x0
    800030b2:	fcc080e7          	jalr	-52(ra) # 8000307a <argaddr>
  return fetchstr(addr, buf, max);
    800030b6:	864a                	mv	a2,s2
    800030b8:	85a6                	mv	a1,s1
    800030ba:	fd843503          	ld	a0,-40(s0)
    800030be:	00000097          	auipc	ra,0x0
    800030c2:	f50080e7          	jalr	-176(ra) # 8000300e <fetchstr>
}
    800030c6:	70a2                	ld	ra,40(sp)
    800030c8:	7402                	ld	s0,32(sp)
    800030ca:	64e2                	ld	s1,24(sp)
    800030cc:	6942                	ld	s2,16(sp)
    800030ce:	6145                	addi	sp,sp,48
    800030d0:	8082                	ret

00000000800030d2 <syscall>:
    "sigreturn",
    "waitx",
};

void syscall(void)
{
    800030d2:	7179                	addi	sp,sp,-48
    800030d4:	f406                	sd	ra,40(sp)
    800030d6:	f022                	sd	s0,32(sp)
    800030d8:	ec26                	sd	s1,24(sp)
    800030da:	e84a                	sd	s2,16(sp)
    800030dc:	e44e                	sd	s3,8(sp)
    800030de:	e052                	sd	s4,0(sp)
    800030e0:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    800030e2:	fffff097          	auipc	ra,0xfffff
    800030e6:	a7a080e7          	jalr	-1414(ra) # 80001b5c <myproc>
    800030ea:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800030ec:	05853903          	ld	s2,88(a0)
    800030f0:	0a893783          	ld	a5,168(s2)
    800030f4:	0007899b          	sext.w	s3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800030f8:	37fd                	addiw	a5,a5,-1
    800030fa:	475d                	li	a4,23
    800030fc:	06f76e63          	bltu	a4,a5,80003178 <syscall+0xa6>
    80003100:	00399713          	slli	a4,s3,0x3
    80003104:	00005797          	auipc	a5,0x5
    80003108:	49478793          	addi	a5,a5,1172 # 80008598 <syscalls>
    8000310c:	97ba                	add	a5,a5,a4
    8000310e:	639c                	ld	a5,0(a5)
    80003110:	c7a5                	beqz	a5,80003178 <syscall+0xa6>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0

    int arg0 = p->trapframe->a0;
    80003112:	07093a03          	ld	s4,112(s2)
    short argcount = (num == SYS_read || num == SYS_write || num == SYS_mknod || SYS_waitx) ? 3
    : ((num == SYS_exec || num == SYS_fstat || num == SYS_open || num == SYS_link || num == SYS_sigalarm) ? 2
    : ((num == SYS_wait || num == SYS_pipe || num == SYS_kill || num == SYS_chdir || num == SYS_dup || num == SYS_sbrk || num == SYS_sleep || num == SYS_unlink || num == SYS_mkdir || num == SYS_close) ? 1
    : 0));

    p->trapframe->a0 = syscalls[num]();
    80003116:	9782                	jalr	a5
    80003118:	06a93823          	sd	a0,112(s2)

    if ((p->tmask >> num) & 0x1)
    8000311c:	1744a783          	lw	a5,372(s1)
    80003120:	0137d7bb          	srlw	a5,a5,s3
    80003124:	8b85                	andi	a5,a5,1
    80003126:	cba5                	beqz	a5,80003196 <syscall+0xc4>
    {
      printf("%d: syscall %s (", p->pid, syscall_name[num]);
    80003128:	098e                	slli	s3,s3,0x3
    8000312a:	00006797          	auipc	a5,0x6
    8000312e:	8ce78793          	addi	a5,a5,-1842 # 800089f8 <syscall_name>
    80003132:	97ce                	add	a5,a5,s3
    80003134:	6390                	ld	a2,0(a5)
    80003136:	588c                	lw	a1,48(s1)
    80003138:	00005517          	auipc	a0,0x5
    8000313c:	32850513          	addi	a0,a0,808 # 80008460 <states.0+0x150>
    80003140:	ffffd097          	auipc	ra,0xffffd
    80003144:	44a080e7          	jalr	1098(ra) # 8000058a <printf>
      if (argcount == 1)
        printf("%d ", arg0);
      else if (argcount == 2)
        printf("%d %d ", arg0, p->trapframe->a1);
      else if (argcount == 3)
        printf("%d %d %d ", arg0, p->trapframe->a1, p->trapframe->a2);
    80003148:	6cbc                	ld	a5,88(s1)
    8000314a:	63d4                	ld	a3,128(a5)
    8000314c:	7fb0                	ld	a2,120(a5)
    8000314e:	000a059b          	sext.w	a1,s4
    80003152:	00005517          	auipc	a0,0x5
    80003156:	32650513          	addi	a0,a0,806 # 80008478 <states.0+0x168>
    8000315a:	ffffd097          	auipc	ra,0xffffd
    8000315e:	430080e7          	jalr	1072(ra) # 8000058a <printf>

      printf(") -> %d\n", p->trapframe->a0);
    80003162:	6cbc                	ld	a5,88(s1)
    80003164:	7bac                	ld	a1,112(a5)
    80003166:	00005517          	auipc	a0,0x5
    8000316a:	32250513          	addi	a0,a0,802 # 80008488 <states.0+0x178>
    8000316e:	ffffd097          	auipc	ra,0xffffd
    80003172:	41c080e7          	jalr	1052(ra) # 8000058a <printf>
    80003176:	a005                	j	80003196 <syscall+0xc4>
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80003178:	86ce                	mv	a3,s3
    8000317a:	15848613          	addi	a2,s1,344
    8000317e:	588c                	lw	a1,48(s1)
    80003180:	00005517          	auipc	a0,0x5
    80003184:	31850513          	addi	a0,a0,792 # 80008498 <states.0+0x188>
    80003188:	ffffd097          	auipc	ra,0xffffd
    8000318c:	402080e7          	jalr	1026(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003190:	6cbc                	ld	a5,88(s1)
    80003192:	577d                	li	a4,-1
    80003194:	fbb8                	sd	a4,112(a5)
  }
}
    80003196:	70a2                	ld	ra,40(sp)
    80003198:	7402                	ld	s0,32(sp)
    8000319a:	64e2                	ld	s1,24(sp)
    8000319c:	6942                	ld	s2,16(sp)
    8000319e:	69a2                	ld	s3,8(sp)
    800031a0:	6a02                	ld	s4,0(sp)
    800031a2:	6145                	addi	sp,sp,48
    800031a4:	8082                	ret

00000000800031a6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800031a6:	1101                	addi	sp,sp,-32
    800031a8:	ec06                	sd	ra,24(sp)
    800031aa:	e822                	sd	s0,16(sp)
    800031ac:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800031ae:	fec40593          	addi	a1,s0,-20
    800031b2:	4501                	li	a0,0
    800031b4:	00000097          	auipc	ra,0x0
    800031b8:	ea6080e7          	jalr	-346(ra) # 8000305a <argint>
  exit(n);
    800031bc:	fec42503          	lw	a0,-20(s0)
    800031c0:	fffff097          	auipc	ra,0xfffff
    800031c4:	3e6080e7          	jalr	998(ra) # 800025a6 <exit>
  return 0; // not reached
}
    800031c8:	4501                	li	a0,0
    800031ca:	60e2                	ld	ra,24(sp)
    800031cc:	6442                	ld	s0,16(sp)
    800031ce:	6105                	addi	sp,sp,32
    800031d0:	8082                	ret

00000000800031d2 <sys_getpid>:

uint64
sys_getpid(void)
{
    800031d2:	1141                	addi	sp,sp,-16
    800031d4:	e406                	sd	ra,8(sp)
    800031d6:	e022                	sd	s0,0(sp)
    800031d8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800031da:	fffff097          	auipc	ra,0xfffff
    800031de:	982080e7          	jalr	-1662(ra) # 80001b5c <myproc>
}
    800031e2:	5908                	lw	a0,48(a0)
    800031e4:	60a2                	ld	ra,8(sp)
    800031e6:	6402                	ld	s0,0(sp)
    800031e8:	0141                	addi	sp,sp,16
    800031ea:	8082                	ret

00000000800031ec <sys_fork>:

uint64
sys_fork(void)
{
    800031ec:	1141                	addi	sp,sp,-16
    800031ee:	e406                	sd	ra,8(sp)
    800031f0:	e022                	sd	s0,0(sp)
    800031f2:	0800                	addi	s0,sp,16
  return fork();
    800031f4:	fffff097          	auipc	ra,0xfffff
    800031f8:	d9e080e7          	jalr	-610(ra) # 80001f92 <fork>
}
    800031fc:	60a2                	ld	ra,8(sp)
    800031fe:	6402                	ld	s0,0(sp)
    80003200:	0141                	addi	sp,sp,16
    80003202:	8082                	ret

0000000080003204 <sys_wait>:

uint64
sys_wait(void)
{
    80003204:	1101                	addi	sp,sp,-32
    80003206:	ec06                	sd	ra,24(sp)
    80003208:	e822                	sd	s0,16(sp)
    8000320a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000320c:	fe840593          	addi	a1,s0,-24
    80003210:	4501                	li	a0,0
    80003212:	00000097          	auipc	ra,0x0
    80003216:	e68080e7          	jalr	-408(ra) # 8000307a <argaddr>
  return wait(p);
    8000321a:	fe843503          	ld	a0,-24(s0)
    8000321e:	fffff097          	auipc	ra,0xfffff
    80003222:	53a080e7          	jalr	1338(ra) # 80002758 <wait>
}
    80003226:	60e2                	ld	ra,24(sp)
    80003228:	6442                	ld	s0,16(sp)
    8000322a:	6105                	addi	sp,sp,32
    8000322c:	8082                	ret

000000008000322e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000322e:	7179                	addi	sp,sp,-48
    80003230:	f406                	sd	ra,40(sp)
    80003232:	f022                	sd	s0,32(sp)
    80003234:	ec26                	sd	s1,24(sp)
    80003236:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003238:	fdc40593          	addi	a1,s0,-36
    8000323c:	4501                	li	a0,0
    8000323e:	00000097          	auipc	ra,0x0
    80003242:	e1c080e7          	jalr	-484(ra) # 8000305a <argint>
  addr = myproc()->sz;
    80003246:	fffff097          	auipc	ra,0xfffff
    8000324a:	916080e7          	jalr	-1770(ra) # 80001b5c <myproc>
    8000324e:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80003250:	fdc42503          	lw	a0,-36(s0)
    80003254:	fffff097          	auipc	ra,0xfffff
    80003258:	ce2080e7          	jalr	-798(ra) # 80001f36 <growproc>
    8000325c:	00054863          	bltz	a0,8000326c <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003260:	8526                	mv	a0,s1
    80003262:	70a2                	ld	ra,40(sp)
    80003264:	7402                	ld	s0,32(sp)
    80003266:	64e2                	ld	s1,24(sp)
    80003268:	6145                	addi	sp,sp,48
    8000326a:	8082                	ret
    return -1;
    8000326c:	54fd                	li	s1,-1
    8000326e:	bfcd                	j	80003260 <sys_sbrk+0x32>

0000000080003270 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003270:	7139                	addi	sp,sp,-64
    80003272:	fc06                	sd	ra,56(sp)
    80003274:	f822                	sd	s0,48(sp)
    80003276:	f426                	sd	s1,40(sp)
    80003278:	f04a                	sd	s2,32(sp)
    8000327a:	ec4e                	sd	s3,24(sp)
    8000327c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000327e:	fcc40593          	addi	a1,s0,-52
    80003282:	4501                	li	a0,0
    80003284:	00000097          	auipc	ra,0x0
    80003288:	dd6080e7          	jalr	-554(ra) # 8000305a <argint>
  acquire(&tickslock);
    8000328c:	00236517          	auipc	a0,0x236
    80003290:	96450513          	addi	a0,a0,-1692 # 80238bf0 <tickslock>
    80003294:	ffffe097          	auipc	ra,0xffffe
    80003298:	ab6080e7          	jalr	-1354(ra) # 80000d4a <acquire>
  ticks0 = ticks;
    8000329c:	00006917          	auipc	s2,0x6
    800032a0:	87c92903          	lw	s2,-1924(s2) # 80008b18 <ticks>
  while (ticks - ticks0 < n)
    800032a4:	fcc42783          	lw	a5,-52(s0)
    800032a8:	cf9d                	beqz	a5,800032e6 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800032aa:	00236997          	auipc	s3,0x236
    800032ae:	94698993          	addi	s3,s3,-1722 # 80238bf0 <tickslock>
    800032b2:	00006497          	auipc	s1,0x6
    800032b6:	86648493          	addi	s1,s1,-1946 # 80008b18 <ticks>
    if (killed(myproc()))
    800032ba:	fffff097          	auipc	ra,0xfffff
    800032be:	8a2080e7          	jalr	-1886(ra) # 80001b5c <myproc>
    800032c2:	fffff097          	auipc	ra,0xfffff
    800032c6:	464080e7          	jalr	1124(ra) # 80002726 <killed>
    800032ca:	ed15                	bnez	a0,80003306 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800032cc:	85ce                	mv	a1,s3
    800032ce:	8526                	mv	a0,s1
    800032d0:	fffff097          	auipc	ra,0xfffff
    800032d4:	02a080e7          	jalr	42(ra) # 800022fa <sleep>
  while (ticks - ticks0 < n)
    800032d8:	409c                	lw	a5,0(s1)
    800032da:	412787bb          	subw	a5,a5,s2
    800032de:	fcc42703          	lw	a4,-52(s0)
    800032e2:	fce7ece3          	bltu	a5,a4,800032ba <sys_sleep+0x4a>
  }
  release(&tickslock);
    800032e6:	00236517          	auipc	a0,0x236
    800032ea:	90a50513          	addi	a0,a0,-1782 # 80238bf0 <tickslock>
    800032ee:	ffffe097          	auipc	ra,0xffffe
    800032f2:	b10080e7          	jalr	-1264(ra) # 80000dfe <release>
  return 0;
    800032f6:	4501                	li	a0,0
}
    800032f8:	70e2                	ld	ra,56(sp)
    800032fa:	7442                	ld	s0,48(sp)
    800032fc:	74a2                	ld	s1,40(sp)
    800032fe:	7902                	ld	s2,32(sp)
    80003300:	69e2                	ld	s3,24(sp)
    80003302:	6121                	addi	sp,sp,64
    80003304:	8082                	ret
      release(&tickslock);
    80003306:	00236517          	auipc	a0,0x236
    8000330a:	8ea50513          	addi	a0,a0,-1814 # 80238bf0 <tickslock>
    8000330e:	ffffe097          	auipc	ra,0xffffe
    80003312:	af0080e7          	jalr	-1296(ra) # 80000dfe <release>
      return -1;
    80003316:	557d                	li	a0,-1
    80003318:	b7c5                	j	800032f8 <sys_sleep+0x88>

000000008000331a <sys_kill>:

uint64
sys_kill(void)
{
    8000331a:	1101                	addi	sp,sp,-32
    8000331c:	ec06                	sd	ra,24(sp)
    8000331e:	e822                	sd	s0,16(sp)
    80003320:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003322:	fec40593          	addi	a1,s0,-20
    80003326:	4501                	li	a0,0
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	d32080e7          	jalr	-718(ra) # 8000305a <argint>
  return kill(pid);
    80003330:	fec42503          	lw	a0,-20(s0)
    80003334:	fffff097          	auipc	ra,0xfffff
    80003338:	354080e7          	jalr	852(ra) # 80002688 <kill>
}
    8000333c:	60e2                	ld	ra,24(sp)
    8000333e:	6442                	ld	s0,16(sp)
    80003340:	6105                	addi	sp,sp,32
    80003342:	8082                	ret

0000000080003344 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003344:	1101                	addi	sp,sp,-32
    80003346:	ec06                	sd	ra,24(sp)
    80003348:	e822                	sd	s0,16(sp)
    8000334a:	e426                	sd	s1,8(sp)
    8000334c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000334e:	00236517          	auipc	a0,0x236
    80003352:	8a250513          	addi	a0,a0,-1886 # 80238bf0 <tickslock>
    80003356:	ffffe097          	auipc	ra,0xffffe
    8000335a:	9f4080e7          	jalr	-1548(ra) # 80000d4a <acquire>
  xticks = ticks;
    8000335e:	00005497          	auipc	s1,0x5
    80003362:	7ba4a483          	lw	s1,1978(s1) # 80008b18 <ticks>
  release(&tickslock);
    80003366:	00236517          	auipc	a0,0x236
    8000336a:	88a50513          	addi	a0,a0,-1910 # 80238bf0 <tickslock>
    8000336e:	ffffe097          	auipc	ra,0xffffe
    80003372:	a90080e7          	jalr	-1392(ra) # 80000dfe <release>
  return xticks;
}
    80003376:	02049513          	slli	a0,s1,0x20
    8000337a:	9101                	srli	a0,a0,0x20
    8000337c:	60e2                	ld	ra,24(sp)
    8000337e:	6442                	ld	s0,16(sp)
    80003380:	64a2                	ld	s1,8(sp)
    80003382:	6105                	addi	sp,sp,32
    80003384:	8082                	ret

0000000080003386 <sys_sigalarm>:

// sigalarm
uint64 sys_sigalarm(void)
{
    80003386:	1101                	addi	sp,sp,-32
    80003388:	ec06                	sd	ra,24(sp)
    8000338a:	e822                	sd	s0,16(sp)
    8000338c:	1000                	addi	s0,sp,32
  int interval;
  uint64 fn;
  argint(0, &interval);
    8000338e:	fec40593          	addi	a1,s0,-20
    80003392:	4501                	li	a0,0
    80003394:	00000097          	auipc	ra,0x0
    80003398:	cc6080e7          	jalr	-826(ra) # 8000305a <argint>
  argaddr(1, &fn);
    8000339c:	fe040593          	addi	a1,s0,-32
    800033a0:	4505                	li	a0,1
    800033a2:	00000097          	auipc	ra,0x0
    800033a6:	cd8080e7          	jalr	-808(ra) # 8000307a <argaddr>

  struct proc *p = myproc();
    800033aa:	ffffe097          	auipc	ra,0xffffe
    800033ae:	7b2080e7          	jalr	1970(ra) # 80001b5c <myproc>

  p->sigalarm_status = 0;
    800033b2:	1a052c23          	sw	zero,440(a0)
  p->interval = interval;
    800033b6:	fec42783          	lw	a5,-20(s0)
    800033ba:	1af52423          	sw	a5,424(a0)
  p->now_ticks = 0;
    800033be:	1a052623          	sw	zero,428(a0)
  p->handler = fn;
    800033c2:	fe043783          	ld	a5,-32(s0)
    800033c6:	1af53023          	sd	a5,416(a0)

  return 0;
}
    800033ca:	4501                	li	a0,0
    800033cc:	60e2                	ld	ra,24(sp)
    800033ce:	6442                	ld	s0,16(sp)
    800033d0:	6105                	addi	sp,sp,32
    800033d2:	8082                	ret

00000000800033d4 <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    800033d4:	1101                	addi	sp,sp,-32
    800033d6:	ec06                	sd	ra,24(sp)
    800033d8:	e822                	sd	s0,16(sp)
    800033da:	e426                	sd	s1,8(sp)
    800033dc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800033de:	ffffe097          	auipc	ra,0xffffe
    800033e2:	77e080e7          	jalr	1918(ra) # 80001b5c <myproc>
    800033e6:	84aa                	mv	s1,a0

  // Restore Kernel Values
  memmove(p->trapframe, p->alarm_trapframe, PGSIZE);
    800033e8:	6605                	lui	a2,0x1
    800033ea:	1b053583          	ld	a1,432(a0)
    800033ee:	6d28                	ld	a0,88(a0)
    800033f0:	ffffe097          	auipc	ra,0xffffe
    800033f4:	ab2080e7          	jalr	-1358(ra) # 80000ea2 <memmove>
  kfree(p->alarm_trapframe);
    800033f8:	1b04b503          	ld	a0,432(s1)
    800033fc:	ffffd097          	auipc	ra,0xffffd
    80003400:	67c080e7          	jalr	1660(ra) # 80000a78 <kfree>

  p->sigalarm_status = 0;
    80003404:	1a04ac23          	sw	zero,440(s1)
  p->alarm_trapframe = 0;
    80003408:	1a04b823          	sd	zero,432(s1)
  p->now_ticks = 0;
    8000340c:	1a04a623          	sw	zero,428(s1)
  usertrapret();
    80003410:	fffff097          	auipc	ra,0xfffff
    80003414:	67e080e7          	jalr	1662(ra) # 80002a8e <usertrapret>
  return 0;
}
    80003418:	4501                	li	a0,0
    8000341a:	60e2                	ld	ra,24(sp)
    8000341c:	6442                	ld	s0,16(sp)
    8000341e:	64a2                	ld	s1,8(sp)
    80003420:	6105                	addi	sp,sp,32
    80003422:	8082                	ret

0000000080003424 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003424:	7139                	addi	sp,sp,-64
    80003426:	fc06                	sd	ra,56(sp)
    80003428:	f822                	sd	s0,48(sp)
    8000342a:	f426                	sd	s1,40(sp)
    8000342c:	f04a                	sd	s2,32(sp)
    8000342e:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003430:	fd840593          	addi	a1,s0,-40
    80003434:	4501                	li	a0,0
    80003436:	00000097          	auipc	ra,0x0
    8000343a:	c44080e7          	jalr	-956(ra) # 8000307a <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000343e:	fd040593          	addi	a1,s0,-48
    80003442:	4505                	li	a0,1
    80003444:	00000097          	auipc	ra,0x0
    80003448:	c36080e7          	jalr	-970(ra) # 8000307a <argaddr>
  argaddr(2, &addr2);
    8000344c:	fc840593          	addi	a1,s0,-56
    80003450:	4509                	li	a0,2
    80003452:	00000097          	auipc	ra,0x0
    80003456:	c28080e7          	jalr	-984(ra) # 8000307a <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000345a:	fc040613          	addi	a2,s0,-64
    8000345e:	fc440593          	addi	a1,s0,-60
    80003462:	fd843503          	ld	a0,-40(s0)
    80003466:	fffff097          	auipc	ra,0xfffff
    8000346a:	f04080e7          	jalr	-252(ra) # 8000236a <waitx>
    8000346e:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003470:	ffffe097          	auipc	ra,0xffffe
    80003474:	6ec080e7          	jalr	1772(ra) # 80001b5c <myproc>
    80003478:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000347a:	4691                	li	a3,4
    8000347c:	fc440613          	addi	a2,s0,-60
    80003480:	fd043583          	ld	a1,-48(s0)
    80003484:	6928                	ld	a0,80(a0)
    80003486:	ffffe097          	auipc	ra,0xffffe
    8000348a:	35a080e7          	jalr	858(ra) # 800017e0 <copyout>
    return -1;
    8000348e:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003490:	00054f63          	bltz	a0,800034ae <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003494:	4691                	li	a3,4
    80003496:	fc040613          	addi	a2,s0,-64
    8000349a:	fc843583          	ld	a1,-56(s0)
    8000349e:	68a8                	ld	a0,80(s1)
    800034a0:	ffffe097          	auipc	ra,0xffffe
    800034a4:	340080e7          	jalr	832(ra) # 800017e0 <copyout>
    800034a8:	00054a63          	bltz	a0,800034bc <sys_waitx+0x98>
    return -1;
  return ret;
    800034ac:	87ca                	mv	a5,s2
    800034ae:	853e                	mv	a0,a5
    800034b0:	70e2                	ld	ra,56(sp)
    800034b2:	7442                	ld	s0,48(sp)
    800034b4:	74a2                	ld	s1,40(sp)
    800034b6:	7902                	ld	s2,32(sp)
    800034b8:	6121                	addi	sp,sp,64
    800034ba:	8082                	ret
    return -1;
    800034bc:	57fd                	li	a5,-1
    800034be:	bfc5                	j	800034ae <sys_waitx+0x8a>

00000000800034c0 <binit>:
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void binit(void)
{
    800034c0:	7179                	addi	sp,sp,-48
    800034c2:	f406                	sd	ra,40(sp)
    800034c4:	f022                	sd	s0,32(sp)
    800034c6:	ec26                	sd	s1,24(sp)
    800034c8:	e84a                	sd	s2,16(sp)
    800034ca:	e44e                	sd	s3,8(sp)
    800034cc:	e052                	sd	s4,0(sp)
    800034ce:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800034d0:	00005597          	auipc	a1,0x5
    800034d4:	19058593          	addi	a1,a1,400 # 80008660 <syscalls+0xc8>
    800034d8:	00235517          	auipc	a0,0x235
    800034dc:	73050513          	addi	a0,a0,1840 # 80238c08 <bcache>
    800034e0:	ffffd097          	auipc	ra,0xffffd
    800034e4:	7da080e7          	jalr	2010(ra) # 80000cba <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800034e8:	0023d797          	auipc	a5,0x23d
    800034ec:	72078793          	addi	a5,a5,1824 # 80240c08 <bcache+0x8000>
    800034f0:	0023e717          	auipc	a4,0x23e
    800034f4:	98070713          	addi	a4,a4,-1664 # 80240e70 <bcache+0x8268>
    800034f8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034fc:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    80003500:	00235497          	auipc	s1,0x235
    80003504:	72048493          	addi	s1,s1,1824 # 80238c20 <bcache+0x18>
  {
    b->next = bcache.head.next;
    80003508:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000350a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000350c:	00005a17          	auipc	s4,0x5
    80003510:	15ca0a13          	addi	s4,s4,348 # 80008668 <syscalls+0xd0>
    b->next = bcache.head.next;
    80003514:	2b893783          	ld	a5,696(s2)
    80003518:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000351a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000351e:	85d2                	mv	a1,s4
    80003520:	01048513          	addi	a0,s1,16
    80003524:	00001097          	auipc	ra,0x1
    80003528:	4c8080e7          	jalr	1224(ra) # 800049ec <initsleeplock>
    bcache.head.next->prev = b;
    8000352c:	2b893783          	ld	a5,696(s2)
    80003530:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003532:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    80003536:	45848493          	addi	s1,s1,1112
    8000353a:	fd349de3          	bne	s1,s3,80003514 <binit+0x54>
  }
}
    8000353e:	70a2                	ld	ra,40(sp)
    80003540:	7402                	ld	s0,32(sp)
    80003542:	64e2                	ld	s1,24(sp)
    80003544:	6942                	ld	s2,16(sp)
    80003546:	69a2                	ld	s3,8(sp)
    80003548:	6a02                	ld	s4,0(sp)
    8000354a:	6145                	addi	sp,sp,48
    8000354c:	8082                	ret

000000008000354e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    8000354e:	7179                	addi	sp,sp,-48
    80003550:	f406                	sd	ra,40(sp)
    80003552:	f022                	sd	s0,32(sp)
    80003554:	ec26                	sd	s1,24(sp)
    80003556:	e84a                	sd	s2,16(sp)
    80003558:	e44e                	sd	s3,8(sp)
    8000355a:	1800                	addi	s0,sp,48
    8000355c:	892a                	mv	s2,a0
    8000355e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003560:	00235517          	auipc	a0,0x235
    80003564:	6a850513          	addi	a0,a0,1704 # 80238c08 <bcache>
    80003568:	ffffd097          	auipc	ra,0xffffd
    8000356c:	7e2080e7          	jalr	2018(ra) # 80000d4a <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next)
    80003570:	0023e497          	auipc	s1,0x23e
    80003574:	9504b483          	ld	s1,-1712(s1) # 80240ec0 <bcache+0x82b8>
    80003578:	0023e797          	auipc	a5,0x23e
    8000357c:	8f878793          	addi	a5,a5,-1800 # 80240e70 <bcache+0x8268>
    80003580:	02f48f63          	beq	s1,a5,800035be <bread+0x70>
    80003584:	873e                	mv	a4,a5
    80003586:	a021                	j	8000358e <bread+0x40>
    80003588:	68a4                	ld	s1,80(s1)
    8000358a:	02e48a63          	beq	s1,a4,800035be <bread+0x70>
    if (b->dev == dev && b->blockno == blockno)
    8000358e:	449c                	lw	a5,8(s1)
    80003590:	ff279ce3          	bne	a5,s2,80003588 <bread+0x3a>
    80003594:	44dc                	lw	a5,12(s1)
    80003596:	ff3799e3          	bne	a5,s3,80003588 <bread+0x3a>
      b->refcnt++;
    8000359a:	40bc                	lw	a5,64(s1)
    8000359c:	2785                	addiw	a5,a5,1
    8000359e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035a0:	00235517          	auipc	a0,0x235
    800035a4:	66850513          	addi	a0,a0,1640 # 80238c08 <bcache>
    800035a8:	ffffe097          	auipc	ra,0xffffe
    800035ac:	856080e7          	jalr	-1962(ra) # 80000dfe <release>
      acquiresleep(&b->lock);
    800035b0:	01048513          	addi	a0,s1,16
    800035b4:	00001097          	auipc	ra,0x1
    800035b8:	472080e7          	jalr	1138(ra) # 80004a26 <acquiresleep>
      return b;
    800035bc:	a8b9                	j	8000361a <bread+0xcc>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    800035be:	0023e497          	auipc	s1,0x23e
    800035c2:	8fa4b483          	ld	s1,-1798(s1) # 80240eb8 <bcache+0x82b0>
    800035c6:	0023e797          	auipc	a5,0x23e
    800035ca:	8aa78793          	addi	a5,a5,-1878 # 80240e70 <bcache+0x8268>
    800035ce:	00f48863          	beq	s1,a5,800035de <bread+0x90>
    800035d2:	873e                	mv	a4,a5
    if (b->refcnt == 0)
    800035d4:	40bc                	lw	a5,64(s1)
    800035d6:	cf81                	beqz	a5,800035ee <bread+0xa0>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev)
    800035d8:	64a4                	ld	s1,72(s1)
    800035da:	fee49de3          	bne	s1,a4,800035d4 <bread+0x86>
  panic("bget: no buffers");
    800035de:	00005517          	auipc	a0,0x5
    800035e2:	09250513          	addi	a0,a0,146 # 80008670 <syscalls+0xd8>
    800035e6:	ffffd097          	auipc	ra,0xffffd
    800035ea:	f5a080e7          	jalr	-166(ra) # 80000540 <panic>
      b->dev = dev;
    800035ee:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800035f2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800035f6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035fa:	4785                	li	a5,1
    800035fc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035fe:	00235517          	auipc	a0,0x235
    80003602:	60a50513          	addi	a0,a0,1546 # 80238c08 <bcache>
    80003606:	ffffd097          	auipc	ra,0xffffd
    8000360a:	7f8080e7          	jalr	2040(ra) # 80000dfe <release>
      acquiresleep(&b->lock);
    8000360e:	01048513          	addi	a0,s1,16
    80003612:	00001097          	auipc	ra,0x1
    80003616:	414080e7          	jalr	1044(ra) # 80004a26 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid)
    8000361a:	409c                	lw	a5,0(s1)
    8000361c:	cb89                	beqz	a5,8000362e <bread+0xe0>
  {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000361e:	8526                	mv	a0,s1
    80003620:	70a2                	ld	ra,40(sp)
    80003622:	7402                	ld	s0,32(sp)
    80003624:	64e2                	ld	s1,24(sp)
    80003626:	6942                	ld	s2,16(sp)
    80003628:	69a2                	ld	s3,8(sp)
    8000362a:	6145                	addi	sp,sp,48
    8000362c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000362e:	4581                	li	a1,0
    80003630:	8526                	mv	a0,s1
    80003632:	00003097          	auipc	ra,0x3
    80003636:	2b4080e7          	jalr	692(ra) # 800068e6 <virtio_disk_rw>
    b->valid = 1;
    8000363a:	4785                	li	a5,1
    8000363c:	c09c                	sw	a5,0(s1)
  return b;
    8000363e:	b7c5                	j	8000361e <bread+0xd0>

0000000080003640 <bwrite>:

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
    80003640:	1101                	addi	sp,sp,-32
    80003642:	ec06                	sd	ra,24(sp)
    80003644:	e822                	sd	s0,16(sp)
    80003646:	e426                	sd	s1,8(sp)
    80003648:	1000                	addi	s0,sp,32
    8000364a:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    8000364c:	0541                	addi	a0,a0,16
    8000364e:	00001097          	auipc	ra,0x1
    80003652:	472080e7          	jalr	1138(ra) # 80004ac0 <holdingsleep>
    80003656:	cd01                	beqz	a0,8000366e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003658:	4585                	li	a1,1
    8000365a:	8526                	mv	a0,s1
    8000365c:	00003097          	auipc	ra,0x3
    80003660:	28a080e7          	jalr	650(ra) # 800068e6 <virtio_disk_rw>
}
    80003664:	60e2                	ld	ra,24(sp)
    80003666:	6442                	ld	s0,16(sp)
    80003668:	64a2                	ld	s1,8(sp)
    8000366a:	6105                	addi	sp,sp,32
    8000366c:	8082                	ret
    panic("bwrite");
    8000366e:	00005517          	auipc	a0,0x5
    80003672:	01a50513          	addi	a0,a0,26 # 80008688 <syscalls+0xf0>
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	eca080e7          	jalr	-310(ra) # 80000540 <panic>

000000008000367e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)
{
    8000367e:	1101                	addi	sp,sp,-32
    80003680:	ec06                	sd	ra,24(sp)
    80003682:	e822                	sd	s0,16(sp)
    80003684:	e426                	sd	s1,8(sp)
    80003686:	e04a                	sd	s2,0(sp)
    80003688:	1000                	addi	s0,sp,32
    8000368a:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    8000368c:	01050913          	addi	s2,a0,16
    80003690:	854a                	mv	a0,s2
    80003692:	00001097          	auipc	ra,0x1
    80003696:	42e080e7          	jalr	1070(ra) # 80004ac0 <holdingsleep>
    8000369a:	c92d                	beqz	a0,8000370c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000369c:	854a                	mv	a0,s2
    8000369e:	00001097          	auipc	ra,0x1
    800036a2:	3de080e7          	jalr	990(ra) # 80004a7c <releasesleep>

  acquire(&bcache.lock);
    800036a6:	00235517          	auipc	a0,0x235
    800036aa:	56250513          	addi	a0,a0,1378 # 80238c08 <bcache>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	69c080e7          	jalr	1692(ra) # 80000d4a <acquire>
  b->refcnt--;
    800036b6:	40bc                	lw	a5,64(s1)
    800036b8:	37fd                	addiw	a5,a5,-1
    800036ba:	0007871b          	sext.w	a4,a5
    800036be:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0)
    800036c0:	eb05                	bnez	a4,800036f0 <brelse+0x72>
  {
    // no one is waiting for it.
    b->next->prev = b->prev;
    800036c2:	68bc                	ld	a5,80(s1)
    800036c4:	64b8                	ld	a4,72(s1)
    800036c6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800036c8:	64bc                	ld	a5,72(s1)
    800036ca:	68b8                	ld	a4,80(s1)
    800036cc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800036ce:	0023d797          	auipc	a5,0x23d
    800036d2:	53a78793          	addi	a5,a5,1338 # 80240c08 <bcache+0x8000>
    800036d6:	2b87b703          	ld	a4,696(a5)
    800036da:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800036dc:	0023d717          	auipc	a4,0x23d
    800036e0:	79470713          	addi	a4,a4,1940 # 80240e70 <bcache+0x8268>
    800036e4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800036e6:	2b87b703          	ld	a4,696(a5)
    800036ea:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800036ec:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    800036f0:	00235517          	auipc	a0,0x235
    800036f4:	51850513          	addi	a0,a0,1304 # 80238c08 <bcache>
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	706080e7          	jalr	1798(ra) # 80000dfe <release>
}
    80003700:	60e2                	ld	ra,24(sp)
    80003702:	6442                	ld	s0,16(sp)
    80003704:	64a2                	ld	s1,8(sp)
    80003706:	6902                	ld	s2,0(sp)
    80003708:	6105                	addi	sp,sp,32
    8000370a:	8082                	ret
    panic("brelse");
    8000370c:	00005517          	auipc	a0,0x5
    80003710:	f8450513          	addi	a0,a0,-124 # 80008690 <syscalls+0xf8>
    80003714:	ffffd097          	auipc	ra,0xffffd
    80003718:	e2c080e7          	jalr	-468(ra) # 80000540 <panic>

000000008000371c <bpin>:

void bpin(struct buf *b)
{
    8000371c:	1101                	addi	sp,sp,-32
    8000371e:	ec06                	sd	ra,24(sp)
    80003720:	e822                	sd	s0,16(sp)
    80003722:	e426                	sd	s1,8(sp)
    80003724:	1000                	addi	s0,sp,32
    80003726:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003728:	00235517          	auipc	a0,0x235
    8000372c:	4e050513          	addi	a0,a0,1248 # 80238c08 <bcache>
    80003730:	ffffd097          	auipc	ra,0xffffd
    80003734:	61a080e7          	jalr	1562(ra) # 80000d4a <acquire>
  b->refcnt++;
    80003738:	40bc                	lw	a5,64(s1)
    8000373a:	2785                	addiw	a5,a5,1
    8000373c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000373e:	00235517          	auipc	a0,0x235
    80003742:	4ca50513          	addi	a0,a0,1226 # 80238c08 <bcache>
    80003746:	ffffd097          	auipc	ra,0xffffd
    8000374a:	6b8080e7          	jalr	1720(ra) # 80000dfe <release>
}
    8000374e:	60e2                	ld	ra,24(sp)
    80003750:	6442                	ld	s0,16(sp)
    80003752:	64a2                	ld	s1,8(sp)
    80003754:	6105                	addi	sp,sp,32
    80003756:	8082                	ret

0000000080003758 <bunpin>:

void bunpin(struct buf *b)
{
    80003758:	1101                	addi	sp,sp,-32
    8000375a:	ec06                	sd	ra,24(sp)
    8000375c:	e822                	sd	s0,16(sp)
    8000375e:	e426                	sd	s1,8(sp)
    80003760:	1000                	addi	s0,sp,32
    80003762:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003764:	00235517          	auipc	a0,0x235
    80003768:	4a450513          	addi	a0,a0,1188 # 80238c08 <bcache>
    8000376c:	ffffd097          	auipc	ra,0xffffd
    80003770:	5de080e7          	jalr	1502(ra) # 80000d4a <acquire>
  b->refcnt--;
    80003774:	40bc                	lw	a5,64(s1)
    80003776:	37fd                	addiw	a5,a5,-1
    80003778:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000377a:	00235517          	auipc	a0,0x235
    8000377e:	48e50513          	addi	a0,a0,1166 # 80238c08 <bcache>
    80003782:	ffffd097          	auipc	ra,0xffffd
    80003786:	67c080e7          	jalr	1660(ra) # 80000dfe <release>
}
    8000378a:	60e2                	ld	ra,24(sp)
    8000378c:	6442                	ld	s0,16(sp)
    8000378e:	64a2                	ld	s1,8(sp)
    80003790:	6105                	addi	sp,sp,32
    80003792:	8082                	ret

0000000080003794 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003794:	1101                	addi	sp,sp,-32
    80003796:	ec06                	sd	ra,24(sp)
    80003798:	e822                	sd	s0,16(sp)
    8000379a:	e426                	sd	s1,8(sp)
    8000379c:	e04a                	sd	s2,0(sp)
    8000379e:	1000                	addi	s0,sp,32
    800037a0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800037a2:	00d5d59b          	srliw	a1,a1,0xd
    800037a6:	0023e797          	auipc	a5,0x23e
    800037aa:	b3e7a783          	lw	a5,-1218(a5) # 802412e4 <sb+0x1c>
    800037ae:	9dbd                	addw	a1,a1,a5
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	d9e080e7          	jalr	-610(ra) # 8000354e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800037b8:	0074f713          	andi	a4,s1,7
    800037bc:	4785                	li	a5,1
    800037be:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    800037c2:	14ce                	slli	s1,s1,0x33
    800037c4:	90d9                	srli	s1,s1,0x36
    800037c6:	00950733          	add	a4,a0,s1
    800037ca:	05874703          	lbu	a4,88(a4)
    800037ce:	00e7f6b3          	and	a3,a5,a4
    800037d2:	c69d                	beqz	a3,80003800 <bfree+0x6c>
    800037d4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    800037d6:	94aa                	add	s1,s1,a0
    800037d8:	fff7c793          	not	a5,a5
    800037dc:	8f7d                	and	a4,a4,a5
    800037de:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800037e2:	00001097          	auipc	ra,0x1
    800037e6:	126080e7          	jalr	294(ra) # 80004908 <log_write>
  brelse(bp);
    800037ea:	854a                	mv	a0,s2
    800037ec:	00000097          	auipc	ra,0x0
    800037f0:	e92080e7          	jalr	-366(ra) # 8000367e <brelse>
}
    800037f4:	60e2                	ld	ra,24(sp)
    800037f6:	6442                	ld	s0,16(sp)
    800037f8:	64a2                	ld	s1,8(sp)
    800037fa:	6902                	ld	s2,0(sp)
    800037fc:	6105                	addi	sp,sp,32
    800037fe:	8082                	ret
    panic("freeing free block");
    80003800:	00005517          	auipc	a0,0x5
    80003804:	e9850513          	addi	a0,a0,-360 # 80008698 <syscalls+0x100>
    80003808:	ffffd097          	auipc	ra,0xffffd
    8000380c:	d38080e7          	jalr	-712(ra) # 80000540 <panic>

0000000080003810 <balloc>:
{
    80003810:	711d                	addi	sp,sp,-96
    80003812:	ec86                	sd	ra,88(sp)
    80003814:	e8a2                	sd	s0,80(sp)
    80003816:	e4a6                	sd	s1,72(sp)
    80003818:	e0ca                	sd	s2,64(sp)
    8000381a:	fc4e                	sd	s3,56(sp)
    8000381c:	f852                	sd	s4,48(sp)
    8000381e:	f456                	sd	s5,40(sp)
    80003820:	f05a                	sd	s6,32(sp)
    80003822:	ec5e                	sd	s7,24(sp)
    80003824:	e862                	sd	s8,16(sp)
    80003826:	e466                	sd	s9,8(sp)
    80003828:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB)
    8000382a:	0023e797          	auipc	a5,0x23e
    8000382e:	aa27a783          	lw	a5,-1374(a5) # 802412cc <sb+0x4>
    80003832:	cff5                	beqz	a5,8000392e <balloc+0x11e>
    80003834:	8baa                	mv	s7,a0
    80003836:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003838:	0023eb17          	auipc	s6,0x23e
    8000383c:	a90b0b13          	addi	s6,s6,-1392 # 802412c8 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003840:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003842:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003844:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB)
    80003846:	6c89                	lui	s9,0x2
    80003848:	a061                	j	800038d0 <balloc+0xc0>
        bp->data[bi / 8] |= m; // Mark block in use.
    8000384a:	97ca                	add	a5,a5,s2
    8000384c:	8e55                	or	a2,a2,a3
    8000384e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003852:	854a                	mv	a0,s2
    80003854:	00001097          	auipc	ra,0x1
    80003858:	0b4080e7          	jalr	180(ra) # 80004908 <log_write>
        brelse(bp);
    8000385c:	854a                	mv	a0,s2
    8000385e:	00000097          	auipc	ra,0x0
    80003862:	e20080e7          	jalr	-480(ra) # 8000367e <brelse>
  bp = bread(dev, bno);
    80003866:	85a6                	mv	a1,s1
    80003868:	855e                	mv	a0,s7
    8000386a:	00000097          	auipc	ra,0x0
    8000386e:	ce4080e7          	jalr	-796(ra) # 8000354e <bread>
    80003872:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003874:	40000613          	li	a2,1024
    80003878:	4581                	li	a1,0
    8000387a:	05850513          	addi	a0,a0,88
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	5c8080e7          	jalr	1480(ra) # 80000e46 <memset>
  log_write(bp);
    80003886:	854a                	mv	a0,s2
    80003888:	00001097          	auipc	ra,0x1
    8000388c:	080080e7          	jalr	128(ra) # 80004908 <log_write>
  brelse(bp);
    80003890:	854a                	mv	a0,s2
    80003892:	00000097          	auipc	ra,0x0
    80003896:	dec080e7          	jalr	-532(ra) # 8000367e <brelse>
}
    8000389a:	8526                	mv	a0,s1
    8000389c:	60e6                	ld	ra,88(sp)
    8000389e:	6446                	ld	s0,80(sp)
    800038a0:	64a6                	ld	s1,72(sp)
    800038a2:	6906                	ld	s2,64(sp)
    800038a4:	79e2                	ld	s3,56(sp)
    800038a6:	7a42                	ld	s4,48(sp)
    800038a8:	7aa2                	ld	s5,40(sp)
    800038aa:	7b02                	ld	s6,32(sp)
    800038ac:	6be2                	ld	s7,24(sp)
    800038ae:	6c42                	ld	s8,16(sp)
    800038b0:	6ca2                	ld	s9,8(sp)
    800038b2:	6125                	addi	sp,sp,96
    800038b4:	8082                	ret
    brelse(bp);
    800038b6:	854a                	mv	a0,s2
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	dc6080e7          	jalr	-570(ra) # 8000367e <brelse>
  for (b = 0; b < sb.size; b += BPB)
    800038c0:	015c87bb          	addw	a5,s9,s5
    800038c4:	00078a9b          	sext.w	s5,a5
    800038c8:	004b2703          	lw	a4,4(s6)
    800038cc:	06eaf163          	bgeu	s5,a4,8000392e <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800038d0:	41fad79b          	sraiw	a5,s5,0x1f
    800038d4:	0137d79b          	srliw	a5,a5,0x13
    800038d8:	015787bb          	addw	a5,a5,s5
    800038dc:	40d7d79b          	sraiw	a5,a5,0xd
    800038e0:	01cb2583          	lw	a1,28(s6)
    800038e4:	9dbd                	addw	a1,a1,a5
    800038e6:	855e                	mv	a0,s7
    800038e8:	00000097          	auipc	ra,0x0
    800038ec:	c66080e7          	jalr	-922(ra) # 8000354e <bread>
    800038f0:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    800038f2:	004b2503          	lw	a0,4(s6)
    800038f6:	000a849b          	sext.w	s1,s5
    800038fa:	8762                	mv	a4,s8
    800038fc:	faa4fde3          	bgeu	s1,a0,800038b6 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003900:	00777693          	andi	a3,a4,7
    80003904:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0)
    80003908:	41f7579b          	sraiw	a5,a4,0x1f
    8000390c:	01d7d79b          	srliw	a5,a5,0x1d
    80003910:	9fb9                	addw	a5,a5,a4
    80003912:	4037d79b          	sraiw	a5,a5,0x3
    80003916:	00f90633          	add	a2,s2,a5
    8000391a:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000391e:	00c6f5b3          	and	a1,a3,a2
    80003922:	d585                	beqz	a1,8000384a <balloc+0x3a>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++)
    80003924:	2705                	addiw	a4,a4,1
    80003926:	2485                	addiw	s1,s1,1
    80003928:	fd471ae3          	bne	a4,s4,800038fc <balloc+0xec>
    8000392c:	b769                	j	800038b6 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000392e:	00005517          	auipc	a0,0x5
    80003932:	d8250513          	addi	a0,a0,-638 # 800086b0 <syscalls+0x118>
    80003936:	ffffd097          	auipc	ra,0xffffd
    8000393a:	c54080e7          	jalr	-940(ra) # 8000058a <printf>
  return 0;
    8000393e:	4481                	li	s1,0
    80003940:	bfa9                	j	8000389a <balloc+0x8a>

0000000080003942 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003942:	7179                	addi	sp,sp,-48
    80003944:	f406                	sd	ra,40(sp)
    80003946:	f022                	sd	s0,32(sp)
    80003948:	ec26                	sd	s1,24(sp)
    8000394a:	e84a                	sd	s2,16(sp)
    8000394c:	e44e                	sd	s3,8(sp)
    8000394e:	e052                	sd	s4,0(sp)
    80003950:	1800                	addi	s0,sp,48
    80003952:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT)
    80003954:	47ad                	li	a5,11
    80003956:	02b7e863          	bltu	a5,a1,80003986 <bmap+0x44>
  {
    if ((addr = ip->addrs[bn]) == 0)
    8000395a:	02059793          	slli	a5,a1,0x20
    8000395e:	01e7d593          	srli	a1,a5,0x1e
    80003962:	00b504b3          	add	s1,a0,a1
    80003966:	0504a903          	lw	s2,80(s1)
    8000396a:	06091e63          	bnez	s2,800039e6 <bmap+0xa4>
    {
      addr = balloc(ip->dev);
    8000396e:	4108                	lw	a0,0(a0)
    80003970:	00000097          	auipc	ra,0x0
    80003974:	ea0080e7          	jalr	-352(ra) # 80003810 <balloc>
    80003978:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    8000397c:	06090563          	beqz	s2,800039e6 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003980:	0524a823          	sw	s2,80(s1)
    80003984:	a08d                	j	800039e6 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003986:	ff45849b          	addiw	s1,a1,-12
    8000398a:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT)
    8000398e:	0ff00793          	li	a5,255
    80003992:	08e7e563          	bltu	a5,a4,80003a1c <bmap+0xda>
  {
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0)
    80003996:	08052903          	lw	s2,128(a0)
    8000399a:	00091d63          	bnez	s2,800039b4 <bmap+0x72>
    {
      addr = balloc(ip->dev);
    8000399e:	4108                	lw	a0,0(a0)
    800039a0:	00000097          	auipc	ra,0x0
    800039a4:	e70080e7          	jalr	-400(ra) # 80003810 <balloc>
    800039a8:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    800039ac:	02090d63          	beqz	s2,800039e6 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800039b0:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800039b4:	85ca                	mv	a1,s2
    800039b6:	0009a503          	lw	a0,0(s3)
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	b94080e7          	jalr	-1132(ra) # 8000354e <bread>
    800039c2:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800039c4:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0)
    800039c8:	02049713          	slli	a4,s1,0x20
    800039cc:	01e75593          	srli	a1,a4,0x1e
    800039d0:	00b784b3          	add	s1,a5,a1
    800039d4:	0004a903          	lw	s2,0(s1)
    800039d8:	02090063          	beqz	s2,800039f8 <bmap+0xb6>
      {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800039dc:	8552                	mv	a0,s4
    800039de:	00000097          	auipc	ra,0x0
    800039e2:	ca0080e7          	jalr	-864(ra) # 8000367e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800039e6:	854a                	mv	a0,s2
    800039e8:	70a2                	ld	ra,40(sp)
    800039ea:	7402                	ld	s0,32(sp)
    800039ec:	64e2                	ld	s1,24(sp)
    800039ee:	6942                	ld	s2,16(sp)
    800039f0:	69a2                	ld	s3,8(sp)
    800039f2:	6a02                	ld	s4,0(sp)
    800039f4:	6145                	addi	sp,sp,48
    800039f6:	8082                	ret
      addr = balloc(ip->dev);
    800039f8:	0009a503          	lw	a0,0(s3)
    800039fc:	00000097          	auipc	ra,0x0
    80003a00:	e14080e7          	jalr	-492(ra) # 80003810 <balloc>
    80003a04:	0005091b          	sext.w	s2,a0
      if (addr)
    80003a08:	fc090ae3          	beqz	s2,800039dc <bmap+0x9a>
        a[bn] = addr;
    80003a0c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003a10:	8552                	mv	a0,s4
    80003a12:	00001097          	auipc	ra,0x1
    80003a16:	ef6080e7          	jalr	-266(ra) # 80004908 <log_write>
    80003a1a:	b7c9                	j	800039dc <bmap+0x9a>
  panic("bmap: out of range");
    80003a1c:	00005517          	auipc	a0,0x5
    80003a20:	cac50513          	addi	a0,a0,-852 # 800086c8 <syscalls+0x130>
    80003a24:	ffffd097          	auipc	ra,0xffffd
    80003a28:	b1c080e7          	jalr	-1252(ra) # 80000540 <panic>

0000000080003a2c <iget>:
{
    80003a2c:	7179                	addi	sp,sp,-48
    80003a2e:	f406                	sd	ra,40(sp)
    80003a30:	f022                	sd	s0,32(sp)
    80003a32:	ec26                	sd	s1,24(sp)
    80003a34:	e84a                	sd	s2,16(sp)
    80003a36:	e44e                	sd	s3,8(sp)
    80003a38:	e052                	sd	s4,0(sp)
    80003a3a:	1800                	addi	s0,sp,48
    80003a3c:	89aa                	mv	s3,a0
    80003a3e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a40:	0023e517          	auipc	a0,0x23e
    80003a44:	8a850513          	addi	a0,a0,-1880 # 802412e8 <itable>
    80003a48:	ffffd097          	auipc	ra,0xffffd
    80003a4c:	302080e7          	jalr	770(ra) # 80000d4a <acquire>
  empty = 0;
    80003a50:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    80003a52:	0023e497          	auipc	s1,0x23e
    80003a56:	8ae48493          	addi	s1,s1,-1874 # 80241300 <itable+0x18>
    80003a5a:	0023f697          	auipc	a3,0x23f
    80003a5e:	33668693          	addi	a3,a3,822 # 80242d90 <log>
    80003a62:	a039                	j	80003a70 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003a64:	02090b63          	beqz	s2,80003a9a <iget+0x6e>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++)
    80003a68:	08848493          	addi	s1,s1,136
    80003a6c:	02d48a63          	beq	s1,a3,80003aa0 <iget+0x74>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum)
    80003a70:	449c                	lw	a5,8(s1)
    80003a72:	fef059e3          	blez	a5,80003a64 <iget+0x38>
    80003a76:	4098                	lw	a4,0(s1)
    80003a78:	ff3716e3          	bne	a4,s3,80003a64 <iget+0x38>
    80003a7c:	40d8                	lw	a4,4(s1)
    80003a7e:	ff4713e3          	bne	a4,s4,80003a64 <iget+0x38>
      ip->ref++;
    80003a82:	2785                	addiw	a5,a5,1
    80003a84:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a86:	0023e517          	auipc	a0,0x23e
    80003a8a:	86250513          	addi	a0,a0,-1950 # 802412e8 <itable>
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	370080e7          	jalr	880(ra) # 80000dfe <release>
      return ip;
    80003a96:	8926                	mv	s2,s1
    80003a98:	a03d                	j	80003ac6 <iget+0x9a>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003a9a:	f7f9                	bnez	a5,80003a68 <iget+0x3c>
    80003a9c:	8926                	mv	s2,s1
    80003a9e:	b7e9                	j	80003a68 <iget+0x3c>
  if (empty == 0)
    80003aa0:	02090c63          	beqz	s2,80003ad8 <iget+0xac>
  ip->dev = dev;
    80003aa4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003aa8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003aac:	4785                	li	a5,1
    80003aae:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ab2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003ab6:	0023e517          	auipc	a0,0x23e
    80003aba:	83250513          	addi	a0,a0,-1998 # 802412e8 <itable>
    80003abe:	ffffd097          	auipc	ra,0xffffd
    80003ac2:	340080e7          	jalr	832(ra) # 80000dfe <release>
}
    80003ac6:	854a                	mv	a0,s2
    80003ac8:	70a2                	ld	ra,40(sp)
    80003aca:	7402                	ld	s0,32(sp)
    80003acc:	64e2                	ld	s1,24(sp)
    80003ace:	6942                	ld	s2,16(sp)
    80003ad0:	69a2                	ld	s3,8(sp)
    80003ad2:	6a02                	ld	s4,0(sp)
    80003ad4:	6145                	addi	sp,sp,48
    80003ad6:	8082                	ret
    panic("iget: no inodes");
    80003ad8:	00005517          	auipc	a0,0x5
    80003adc:	c0850513          	addi	a0,a0,-1016 # 800086e0 <syscalls+0x148>
    80003ae0:	ffffd097          	auipc	ra,0xffffd
    80003ae4:	a60080e7          	jalr	-1440(ra) # 80000540 <panic>

0000000080003ae8 <fsinit>:
{
    80003ae8:	7179                	addi	sp,sp,-48
    80003aea:	f406                	sd	ra,40(sp)
    80003aec:	f022                	sd	s0,32(sp)
    80003aee:	ec26                	sd	s1,24(sp)
    80003af0:	e84a                	sd	s2,16(sp)
    80003af2:	e44e                	sd	s3,8(sp)
    80003af4:	1800                	addi	s0,sp,48
    80003af6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003af8:	4585                	li	a1,1
    80003afa:	00000097          	auipc	ra,0x0
    80003afe:	a54080e7          	jalr	-1452(ra) # 8000354e <bread>
    80003b02:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b04:	0023d997          	auipc	s3,0x23d
    80003b08:	7c498993          	addi	s3,s3,1988 # 802412c8 <sb>
    80003b0c:	02000613          	li	a2,32
    80003b10:	05850593          	addi	a1,a0,88
    80003b14:	854e                	mv	a0,s3
    80003b16:	ffffd097          	auipc	ra,0xffffd
    80003b1a:	38c080e7          	jalr	908(ra) # 80000ea2 <memmove>
  brelse(bp);
    80003b1e:	8526                	mv	a0,s1
    80003b20:	00000097          	auipc	ra,0x0
    80003b24:	b5e080e7          	jalr	-1186(ra) # 8000367e <brelse>
  if (sb.magic != FSMAGIC)
    80003b28:	0009a703          	lw	a4,0(s3)
    80003b2c:	102037b7          	lui	a5,0x10203
    80003b30:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b34:	02f71263          	bne	a4,a5,80003b58 <fsinit+0x70>
  initlog(dev, &sb);
    80003b38:	0023d597          	auipc	a1,0x23d
    80003b3c:	79058593          	addi	a1,a1,1936 # 802412c8 <sb>
    80003b40:	854a                	mv	a0,s2
    80003b42:	00001097          	auipc	ra,0x1
    80003b46:	b4a080e7          	jalr	-1206(ra) # 8000468c <initlog>
}
    80003b4a:	70a2                	ld	ra,40(sp)
    80003b4c:	7402                	ld	s0,32(sp)
    80003b4e:	64e2                	ld	s1,24(sp)
    80003b50:	6942                	ld	s2,16(sp)
    80003b52:	69a2                	ld	s3,8(sp)
    80003b54:	6145                	addi	sp,sp,48
    80003b56:	8082                	ret
    panic("invalid file system");
    80003b58:	00005517          	auipc	a0,0x5
    80003b5c:	b9850513          	addi	a0,a0,-1128 # 800086f0 <syscalls+0x158>
    80003b60:	ffffd097          	auipc	ra,0xffffd
    80003b64:	9e0080e7          	jalr	-1568(ra) # 80000540 <panic>

0000000080003b68 <iinit>:
{
    80003b68:	7179                	addi	sp,sp,-48
    80003b6a:	f406                	sd	ra,40(sp)
    80003b6c:	f022                	sd	s0,32(sp)
    80003b6e:	ec26                	sd	s1,24(sp)
    80003b70:	e84a                	sd	s2,16(sp)
    80003b72:	e44e                	sd	s3,8(sp)
    80003b74:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b76:	00005597          	auipc	a1,0x5
    80003b7a:	b9258593          	addi	a1,a1,-1134 # 80008708 <syscalls+0x170>
    80003b7e:	0023d517          	auipc	a0,0x23d
    80003b82:	76a50513          	addi	a0,a0,1898 # 802412e8 <itable>
    80003b86:	ffffd097          	auipc	ra,0xffffd
    80003b8a:	134080e7          	jalr	308(ra) # 80000cba <initlock>
  for (i = 0; i < NINODE; i++)
    80003b8e:	0023d497          	auipc	s1,0x23d
    80003b92:	78248493          	addi	s1,s1,1922 # 80241310 <itable+0x28>
    80003b96:	0023f997          	auipc	s3,0x23f
    80003b9a:	20a98993          	addi	s3,s3,522 # 80242da0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b9e:	00005917          	auipc	s2,0x5
    80003ba2:	b7290913          	addi	s2,s2,-1166 # 80008710 <syscalls+0x178>
    80003ba6:	85ca                	mv	a1,s2
    80003ba8:	8526                	mv	a0,s1
    80003baa:	00001097          	auipc	ra,0x1
    80003bae:	e42080e7          	jalr	-446(ra) # 800049ec <initsleeplock>
  for (i = 0; i < NINODE; i++)
    80003bb2:	08848493          	addi	s1,s1,136
    80003bb6:	ff3498e3          	bne	s1,s3,80003ba6 <iinit+0x3e>
}
    80003bba:	70a2                	ld	ra,40(sp)
    80003bbc:	7402                	ld	s0,32(sp)
    80003bbe:	64e2                	ld	s1,24(sp)
    80003bc0:	6942                	ld	s2,16(sp)
    80003bc2:	69a2                	ld	s3,8(sp)
    80003bc4:	6145                	addi	sp,sp,48
    80003bc6:	8082                	ret

0000000080003bc8 <ialloc>:
{
    80003bc8:	715d                	addi	sp,sp,-80
    80003bca:	e486                	sd	ra,72(sp)
    80003bcc:	e0a2                	sd	s0,64(sp)
    80003bce:	fc26                	sd	s1,56(sp)
    80003bd0:	f84a                	sd	s2,48(sp)
    80003bd2:	f44e                	sd	s3,40(sp)
    80003bd4:	f052                	sd	s4,32(sp)
    80003bd6:	ec56                	sd	s5,24(sp)
    80003bd8:	e85a                	sd	s6,16(sp)
    80003bda:	e45e                	sd	s7,8(sp)
    80003bdc:	0880                	addi	s0,sp,80
  for (inum = 1; inum < sb.ninodes; inum++)
    80003bde:	0023d717          	auipc	a4,0x23d
    80003be2:	6f672703          	lw	a4,1782(a4) # 802412d4 <sb+0xc>
    80003be6:	4785                	li	a5,1
    80003be8:	04e7fa63          	bgeu	a5,a4,80003c3c <ialloc+0x74>
    80003bec:	8aaa                	mv	s5,a0
    80003bee:	8bae                	mv	s7,a1
    80003bf0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003bf2:	0023da17          	auipc	s4,0x23d
    80003bf6:	6d6a0a13          	addi	s4,s4,1750 # 802412c8 <sb>
    80003bfa:	00048b1b          	sext.w	s6,s1
    80003bfe:	0044d593          	srli	a1,s1,0x4
    80003c02:	018a2783          	lw	a5,24(s4)
    80003c06:	9dbd                	addw	a1,a1,a5
    80003c08:	8556                	mv	a0,s5
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	944080e7          	jalr	-1724(ra) # 8000354e <bread>
    80003c12:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003c14:	05850993          	addi	s3,a0,88
    80003c18:	00f4f793          	andi	a5,s1,15
    80003c1c:	079a                	slli	a5,a5,0x6
    80003c1e:	99be                	add	s3,s3,a5
    if (dip->type == 0)
    80003c20:	00099783          	lh	a5,0(s3)
    80003c24:	c3a1                	beqz	a5,80003c64 <ialloc+0x9c>
    brelse(bp);
    80003c26:	00000097          	auipc	ra,0x0
    80003c2a:	a58080e7          	jalr	-1448(ra) # 8000367e <brelse>
  for (inum = 1; inum < sb.ninodes; inum++)
    80003c2e:	0485                	addi	s1,s1,1
    80003c30:	00ca2703          	lw	a4,12(s4)
    80003c34:	0004879b          	sext.w	a5,s1
    80003c38:	fce7e1e3          	bltu	a5,a4,80003bfa <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003c3c:	00005517          	auipc	a0,0x5
    80003c40:	adc50513          	addi	a0,a0,-1316 # 80008718 <syscalls+0x180>
    80003c44:	ffffd097          	auipc	ra,0xffffd
    80003c48:	946080e7          	jalr	-1722(ra) # 8000058a <printf>
  return 0;
    80003c4c:	4501                	li	a0,0
}
    80003c4e:	60a6                	ld	ra,72(sp)
    80003c50:	6406                	ld	s0,64(sp)
    80003c52:	74e2                	ld	s1,56(sp)
    80003c54:	7942                	ld	s2,48(sp)
    80003c56:	79a2                	ld	s3,40(sp)
    80003c58:	7a02                	ld	s4,32(sp)
    80003c5a:	6ae2                	ld	s5,24(sp)
    80003c5c:	6b42                	ld	s6,16(sp)
    80003c5e:	6ba2                	ld	s7,8(sp)
    80003c60:	6161                	addi	sp,sp,80
    80003c62:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003c64:	04000613          	li	a2,64
    80003c68:	4581                	li	a1,0
    80003c6a:	854e                	mv	a0,s3
    80003c6c:	ffffd097          	auipc	ra,0xffffd
    80003c70:	1da080e7          	jalr	474(ra) # 80000e46 <memset>
      dip->type = type;
    80003c74:	01799023          	sh	s7,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003c78:	854a                	mv	a0,s2
    80003c7a:	00001097          	auipc	ra,0x1
    80003c7e:	c8e080e7          	jalr	-882(ra) # 80004908 <log_write>
      brelse(bp);
    80003c82:	854a                	mv	a0,s2
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	9fa080e7          	jalr	-1542(ra) # 8000367e <brelse>
      return iget(dev, inum);
    80003c8c:	85da                	mv	a1,s6
    80003c8e:	8556                	mv	a0,s5
    80003c90:	00000097          	auipc	ra,0x0
    80003c94:	d9c080e7          	jalr	-612(ra) # 80003a2c <iget>
    80003c98:	bf5d                	j	80003c4e <ialloc+0x86>

0000000080003c9a <iupdate>:
{
    80003c9a:	1101                	addi	sp,sp,-32
    80003c9c:	ec06                	sd	ra,24(sp)
    80003c9e:	e822                	sd	s0,16(sp)
    80003ca0:	e426                	sd	s1,8(sp)
    80003ca2:	e04a                	sd	s2,0(sp)
    80003ca4:	1000                	addi	s0,sp,32
    80003ca6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ca8:	415c                	lw	a5,4(a0)
    80003caa:	0047d79b          	srliw	a5,a5,0x4
    80003cae:	0023d597          	auipc	a1,0x23d
    80003cb2:	6325a583          	lw	a1,1586(a1) # 802412e0 <sb+0x18>
    80003cb6:	9dbd                	addw	a1,a1,a5
    80003cb8:	4108                	lw	a0,0(a0)
    80003cba:	00000097          	auipc	ra,0x0
    80003cbe:	894080e7          	jalr	-1900(ra) # 8000354e <bread>
    80003cc2:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003cc4:	05850793          	addi	a5,a0,88
    80003cc8:	40d8                	lw	a4,4(s1)
    80003cca:	8b3d                	andi	a4,a4,15
    80003ccc:	071a                	slli	a4,a4,0x6
    80003cce:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003cd0:	04449703          	lh	a4,68(s1)
    80003cd4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003cd8:	04649703          	lh	a4,70(s1)
    80003cdc:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003ce0:	04849703          	lh	a4,72(s1)
    80003ce4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003ce8:	04a49703          	lh	a4,74(s1)
    80003cec:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003cf0:	44f8                	lw	a4,76(s1)
    80003cf2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003cf4:	03400613          	li	a2,52
    80003cf8:	05048593          	addi	a1,s1,80
    80003cfc:	00c78513          	addi	a0,a5,12
    80003d00:	ffffd097          	auipc	ra,0xffffd
    80003d04:	1a2080e7          	jalr	418(ra) # 80000ea2 <memmove>
  log_write(bp);
    80003d08:	854a                	mv	a0,s2
    80003d0a:	00001097          	auipc	ra,0x1
    80003d0e:	bfe080e7          	jalr	-1026(ra) # 80004908 <log_write>
  brelse(bp);
    80003d12:	854a                	mv	a0,s2
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	96a080e7          	jalr	-1686(ra) # 8000367e <brelse>
}
    80003d1c:	60e2                	ld	ra,24(sp)
    80003d1e:	6442                	ld	s0,16(sp)
    80003d20:	64a2                	ld	s1,8(sp)
    80003d22:	6902                	ld	s2,0(sp)
    80003d24:	6105                	addi	sp,sp,32
    80003d26:	8082                	ret

0000000080003d28 <idup>:
{
    80003d28:	1101                	addi	sp,sp,-32
    80003d2a:	ec06                	sd	ra,24(sp)
    80003d2c:	e822                	sd	s0,16(sp)
    80003d2e:	e426                	sd	s1,8(sp)
    80003d30:	1000                	addi	s0,sp,32
    80003d32:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d34:	0023d517          	auipc	a0,0x23d
    80003d38:	5b450513          	addi	a0,a0,1460 # 802412e8 <itable>
    80003d3c:	ffffd097          	auipc	ra,0xffffd
    80003d40:	00e080e7          	jalr	14(ra) # 80000d4a <acquire>
  ip->ref++;
    80003d44:	449c                	lw	a5,8(s1)
    80003d46:	2785                	addiw	a5,a5,1
    80003d48:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d4a:	0023d517          	auipc	a0,0x23d
    80003d4e:	59e50513          	addi	a0,a0,1438 # 802412e8 <itable>
    80003d52:	ffffd097          	auipc	ra,0xffffd
    80003d56:	0ac080e7          	jalr	172(ra) # 80000dfe <release>
}
    80003d5a:	8526                	mv	a0,s1
    80003d5c:	60e2                	ld	ra,24(sp)
    80003d5e:	6442                	ld	s0,16(sp)
    80003d60:	64a2                	ld	s1,8(sp)
    80003d62:	6105                	addi	sp,sp,32
    80003d64:	8082                	ret

0000000080003d66 <ilock>:
{
    80003d66:	1101                	addi	sp,sp,-32
    80003d68:	ec06                	sd	ra,24(sp)
    80003d6a:	e822                	sd	s0,16(sp)
    80003d6c:	e426                	sd	s1,8(sp)
    80003d6e:	e04a                	sd	s2,0(sp)
    80003d70:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003d72:	c115                	beqz	a0,80003d96 <ilock+0x30>
    80003d74:	84aa                	mv	s1,a0
    80003d76:	451c                	lw	a5,8(a0)
    80003d78:	00f05f63          	blez	a5,80003d96 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d7c:	0541                	addi	a0,a0,16
    80003d7e:	00001097          	auipc	ra,0x1
    80003d82:	ca8080e7          	jalr	-856(ra) # 80004a26 <acquiresleep>
  if (ip->valid == 0)
    80003d86:	40bc                	lw	a5,64(s1)
    80003d88:	cf99                	beqz	a5,80003da6 <ilock+0x40>
}
    80003d8a:	60e2                	ld	ra,24(sp)
    80003d8c:	6442                	ld	s0,16(sp)
    80003d8e:	64a2                	ld	s1,8(sp)
    80003d90:	6902                	ld	s2,0(sp)
    80003d92:	6105                	addi	sp,sp,32
    80003d94:	8082                	ret
    panic("ilock");
    80003d96:	00005517          	auipc	a0,0x5
    80003d9a:	99a50513          	addi	a0,a0,-1638 # 80008730 <syscalls+0x198>
    80003d9e:	ffffc097          	auipc	ra,0xffffc
    80003da2:	7a2080e7          	jalr	1954(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003da6:	40dc                	lw	a5,4(s1)
    80003da8:	0047d79b          	srliw	a5,a5,0x4
    80003dac:	0023d597          	auipc	a1,0x23d
    80003db0:	5345a583          	lw	a1,1332(a1) # 802412e0 <sb+0x18>
    80003db4:	9dbd                	addw	a1,a1,a5
    80003db6:	4088                	lw	a0,0(s1)
    80003db8:	fffff097          	auipc	ra,0xfffff
    80003dbc:	796080e7          	jalr	1942(ra) # 8000354e <bread>
    80003dc0:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003dc2:	05850593          	addi	a1,a0,88
    80003dc6:	40dc                	lw	a5,4(s1)
    80003dc8:	8bbd                	andi	a5,a5,15
    80003dca:	079a                	slli	a5,a5,0x6
    80003dcc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003dce:	00059783          	lh	a5,0(a1)
    80003dd2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003dd6:	00259783          	lh	a5,2(a1)
    80003dda:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003dde:	00459783          	lh	a5,4(a1)
    80003de2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003de6:	00659783          	lh	a5,6(a1)
    80003dea:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003dee:	459c                	lw	a5,8(a1)
    80003df0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003df2:	03400613          	li	a2,52
    80003df6:	05b1                	addi	a1,a1,12
    80003df8:	05048513          	addi	a0,s1,80
    80003dfc:	ffffd097          	auipc	ra,0xffffd
    80003e00:	0a6080e7          	jalr	166(ra) # 80000ea2 <memmove>
    brelse(bp);
    80003e04:	854a                	mv	a0,s2
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	878080e7          	jalr	-1928(ra) # 8000367e <brelse>
    ip->valid = 1;
    80003e0e:	4785                	li	a5,1
    80003e10:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003e12:	04449783          	lh	a5,68(s1)
    80003e16:	fbb5                	bnez	a5,80003d8a <ilock+0x24>
      panic("ilock: no type");
    80003e18:	00005517          	auipc	a0,0x5
    80003e1c:	92050513          	addi	a0,a0,-1760 # 80008738 <syscalls+0x1a0>
    80003e20:	ffffc097          	auipc	ra,0xffffc
    80003e24:	720080e7          	jalr	1824(ra) # 80000540 <panic>

0000000080003e28 <iunlock>:
{
    80003e28:	1101                	addi	sp,sp,-32
    80003e2a:	ec06                	sd	ra,24(sp)
    80003e2c:	e822                	sd	s0,16(sp)
    80003e2e:	e426                	sd	s1,8(sp)
    80003e30:	e04a                	sd	s2,0(sp)
    80003e32:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e34:	c905                	beqz	a0,80003e64 <iunlock+0x3c>
    80003e36:	84aa                	mv	s1,a0
    80003e38:	01050913          	addi	s2,a0,16
    80003e3c:	854a                	mv	a0,s2
    80003e3e:	00001097          	auipc	ra,0x1
    80003e42:	c82080e7          	jalr	-894(ra) # 80004ac0 <holdingsleep>
    80003e46:	cd19                	beqz	a0,80003e64 <iunlock+0x3c>
    80003e48:	449c                	lw	a5,8(s1)
    80003e4a:	00f05d63          	blez	a5,80003e64 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e4e:	854a                	mv	a0,s2
    80003e50:	00001097          	auipc	ra,0x1
    80003e54:	c2c080e7          	jalr	-980(ra) # 80004a7c <releasesleep>
}
    80003e58:	60e2                	ld	ra,24(sp)
    80003e5a:	6442                	ld	s0,16(sp)
    80003e5c:	64a2                	ld	s1,8(sp)
    80003e5e:	6902                	ld	s2,0(sp)
    80003e60:	6105                	addi	sp,sp,32
    80003e62:	8082                	ret
    panic("iunlock");
    80003e64:	00005517          	auipc	a0,0x5
    80003e68:	8e450513          	addi	a0,a0,-1820 # 80008748 <syscalls+0x1b0>
    80003e6c:	ffffc097          	auipc	ra,0xffffc
    80003e70:	6d4080e7          	jalr	1748(ra) # 80000540 <panic>

0000000080003e74 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void itrunc(struct inode *ip)
{
    80003e74:	7179                	addi	sp,sp,-48
    80003e76:	f406                	sd	ra,40(sp)
    80003e78:	f022                	sd	s0,32(sp)
    80003e7a:	ec26                	sd	s1,24(sp)
    80003e7c:	e84a                	sd	s2,16(sp)
    80003e7e:	e44e                	sd	s3,8(sp)
    80003e80:	e052                	sd	s4,0(sp)
    80003e82:	1800                	addi	s0,sp,48
    80003e84:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++)
    80003e86:	05050493          	addi	s1,a0,80
    80003e8a:	08050913          	addi	s2,a0,128
    80003e8e:	a021                	j	80003e96 <itrunc+0x22>
    80003e90:	0491                	addi	s1,s1,4
    80003e92:	01248d63          	beq	s1,s2,80003eac <itrunc+0x38>
  {
    if (ip->addrs[i])
    80003e96:	408c                	lw	a1,0(s1)
    80003e98:	dde5                	beqz	a1,80003e90 <itrunc+0x1c>
    {
      bfree(ip->dev, ip->addrs[i]);
    80003e9a:	0009a503          	lw	a0,0(s3)
    80003e9e:	00000097          	auipc	ra,0x0
    80003ea2:	8f6080e7          	jalr	-1802(ra) # 80003794 <bfree>
      ip->addrs[i] = 0;
    80003ea6:	0004a023          	sw	zero,0(s1)
    80003eaa:	b7dd                	j	80003e90 <itrunc+0x1c>
    }
  }

  if (ip->addrs[NDIRECT])
    80003eac:	0809a583          	lw	a1,128(s3)
    80003eb0:	e185                	bnez	a1,80003ed0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003eb2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003eb6:	854e                	mv	a0,s3
    80003eb8:	00000097          	auipc	ra,0x0
    80003ebc:	de2080e7          	jalr	-542(ra) # 80003c9a <iupdate>
}
    80003ec0:	70a2                	ld	ra,40(sp)
    80003ec2:	7402                	ld	s0,32(sp)
    80003ec4:	64e2                	ld	s1,24(sp)
    80003ec6:	6942                	ld	s2,16(sp)
    80003ec8:	69a2                	ld	s3,8(sp)
    80003eca:	6a02                	ld	s4,0(sp)
    80003ecc:	6145                	addi	sp,sp,48
    80003ece:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ed0:	0009a503          	lw	a0,0(s3)
    80003ed4:	fffff097          	auipc	ra,0xfffff
    80003ed8:	67a080e7          	jalr	1658(ra) # 8000354e <bread>
    80003edc:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++)
    80003ede:	05850493          	addi	s1,a0,88
    80003ee2:	45850913          	addi	s2,a0,1112
    80003ee6:	a021                	j	80003eee <itrunc+0x7a>
    80003ee8:	0491                	addi	s1,s1,4
    80003eea:	01248b63          	beq	s1,s2,80003f00 <itrunc+0x8c>
      if (a[j])
    80003eee:	408c                	lw	a1,0(s1)
    80003ef0:	dde5                	beqz	a1,80003ee8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003ef2:	0009a503          	lw	a0,0(s3)
    80003ef6:	00000097          	auipc	ra,0x0
    80003efa:	89e080e7          	jalr	-1890(ra) # 80003794 <bfree>
    80003efe:	b7ed                	j	80003ee8 <itrunc+0x74>
    brelse(bp);
    80003f00:	8552                	mv	a0,s4
    80003f02:	fffff097          	auipc	ra,0xfffff
    80003f06:	77c080e7          	jalr	1916(ra) # 8000367e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f0a:	0809a583          	lw	a1,128(s3)
    80003f0e:	0009a503          	lw	a0,0(s3)
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	882080e7          	jalr	-1918(ra) # 80003794 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f1a:	0809a023          	sw	zero,128(s3)
    80003f1e:	bf51                	j	80003eb2 <itrunc+0x3e>

0000000080003f20 <iput>:
{
    80003f20:	1101                	addi	sp,sp,-32
    80003f22:	ec06                	sd	ra,24(sp)
    80003f24:	e822                	sd	s0,16(sp)
    80003f26:	e426                	sd	s1,8(sp)
    80003f28:	e04a                	sd	s2,0(sp)
    80003f2a:	1000                	addi	s0,sp,32
    80003f2c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f2e:	0023d517          	auipc	a0,0x23d
    80003f32:	3ba50513          	addi	a0,a0,954 # 802412e8 <itable>
    80003f36:	ffffd097          	auipc	ra,0xffffd
    80003f3a:	e14080e7          	jalr	-492(ra) # 80000d4a <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003f3e:	4498                	lw	a4,8(s1)
    80003f40:	4785                	li	a5,1
    80003f42:	02f70363          	beq	a4,a5,80003f68 <iput+0x48>
  ip->ref--;
    80003f46:	449c                	lw	a5,8(s1)
    80003f48:	37fd                	addiw	a5,a5,-1
    80003f4a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f4c:	0023d517          	auipc	a0,0x23d
    80003f50:	39c50513          	addi	a0,a0,924 # 802412e8 <itable>
    80003f54:	ffffd097          	auipc	ra,0xffffd
    80003f58:	eaa080e7          	jalr	-342(ra) # 80000dfe <release>
}
    80003f5c:	60e2                	ld	ra,24(sp)
    80003f5e:	6442                	ld	s0,16(sp)
    80003f60:	64a2                	ld	s1,8(sp)
    80003f62:	6902                	ld	s2,0(sp)
    80003f64:	6105                	addi	sp,sp,32
    80003f66:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0)
    80003f68:	40bc                	lw	a5,64(s1)
    80003f6a:	dff1                	beqz	a5,80003f46 <iput+0x26>
    80003f6c:	04a49783          	lh	a5,74(s1)
    80003f70:	fbf9                	bnez	a5,80003f46 <iput+0x26>
    acquiresleep(&ip->lock);
    80003f72:	01048913          	addi	s2,s1,16
    80003f76:	854a                	mv	a0,s2
    80003f78:	00001097          	auipc	ra,0x1
    80003f7c:	aae080e7          	jalr	-1362(ra) # 80004a26 <acquiresleep>
    release(&itable.lock);
    80003f80:	0023d517          	auipc	a0,0x23d
    80003f84:	36850513          	addi	a0,a0,872 # 802412e8 <itable>
    80003f88:	ffffd097          	auipc	ra,0xffffd
    80003f8c:	e76080e7          	jalr	-394(ra) # 80000dfe <release>
    itrunc(ip);
    80003f90:	8526                	mv	a0,s1
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	ee2080e7          	jalr	-286(ra) # 80003e74 <itrunc>
    ip->type = 0;
    80003f9a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	00000097          	auipc	ra,0x0
    80003fa4:	cfa080e7          	jalr	-774(ra) # 80003c9a <iupdate>
    ip->valid = 0;
    80003fa8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003fac:	854a                	mv	a0,s2
    80003fae:	00001097          	auipc	ra,0x1
    80003fb2:	ace080e7          	jalr	-1330(ra) # 80004a7c <releasesleep>
    acquire(&itable.lock);
    80003fb6:	0023d517          	auipc	a0,0x23d
    80003fba:	33250513          	addi	a0,a0,818 # 802412e8 <itable>
    80003fbe:	ffffd097          	auipc	ra,0xffffd
    80003fc2:	d8c080e7          	jalr	-628(ra) # 80000d4a <acquire>
    80003fc6:	b741                	j	80003f46 <iput+0x26>

0000000080003fc8 <iunlockput>:
{
    80003fc8:	1101                	addi	sp,sp,-32
    80003fca:	ec06                	sd	ra,24(sp)
    80003fcc:	e822                	sd	s0,16(sp)
    80003fce:	e426                	sd	s1,8(sp)
    80003fd0:	1000                	addi	s0,sp,32
    80003fd2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003fd4:	00000097          	auipc	ra,0x0
    80003fd8:	e54080e7          	jalr	-428(ra) # 80003e28 <iunlock>
  iput(ip);
    80003fdc:	8526                	mv	a0,s1
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	f42080e7          	jalr	-190(ra) # 80003f20 <iput>
}
    80003fe6:	60e2                	ld	ra,24(sp)
    80003fe8:	6442                	ld	s0,16(sp)
    80003fea:	64a2                	ld	s1,8(sp)
    80003fec:	6105                	addi	sp,sp,32
    80003fee:	8082                	ret

0000000080003ff0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void stati(struct inode *ip, struct stat *st)
{
    80003ff0:	1141                	addi	sp,sp,-16
    80003ff2:	e422                	sd	s0,8(sp)
    80003ff4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ff6:	411c                	lw	a5,0(a0)
    80003ff8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ffa:	415c                	lw	a5,4(a0)
    80003ffc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ffe:	04451783          	lh	a5,68(a0)
    80004002:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004006:	04a51783          	lh	a5,74(a0)
    8000400a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000400e:	04c56783          	lwu	a5,76(a0)
    80004012:	e99c                	sd	a5,16(a1)
}
    80004014:	6422                	ld	s0,8(sp)
    80004016:	0141                	addi	sp,sp,16
    80004018:	8082                	ret

000000008000401a <readi>:
int readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000401a:	457c                	lw	a5,76(a0)
    8000401c:	0ed7e963          	bltu	a5,a3,8000410e <readi+0xf4>
{
    80004020:	7159                	addi	sp,sp,-112
    80004022:	f486                	sd	ra,104(sp)
    80004024:	f0a2                	sd	s0,96(sp)
    80004026:	eca6                	sd	s1,88(sp)
    80004028:	e8ca                	sd	s2,80(sp)
    8000402a:	e4ce                	sd	s3,72(sp)
    8000402c:	e0d2                	sd	s4,64(sp)
    8000402e:	fc56                	sd	s5,56(sp)
    80004030:	f85a                	sd	s6,48(sp)
    80004032:	f45e                	sd	s7,40(sp)
    80004034:	f062                	sd	s8,32(sp)
    80004036:	ec66                	sd	s9,24(sp)
    80004038:	e86a                	sd	s10,16(sp)
    8000403a:	e46e                	sd	s11,8(sp)
    8000403c:	1880                	addi	s0,sp,112
    8000403e:	8b2a                	mv	s6,a0
    80004040:	8bae                	mv	s7,a1
    80004042:	8a32                	mv	s4,a2
    80004044:	84b6                	mv	s1,a3
    80004046:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80004048:	9f35                	addw	a4,a4,a3
    return 0;
    8000404a:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000404c:	0ad76063          	bltu	a4,a3,800040ec <readi+0xd2>
  if (off + n > ip->size)
    80004050:	00e7f463          	bgeu	a5,a4,80004058 <readi+0x3e>
    n = ip->size - off;
    80004054:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80004058:	0a0a8963          	beqz	s5,8000410a <readi+0xf0>
    8000405c:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000405e:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1)
    80004062:	5c7d                	li	s8,-1
    80004064:	a82d                	j	8000409e <readi+0x84>
    80004066:	020d1d93          	slli	s11,s10,0x20
    8000406a:	020ddd93          	srli	s11,s11,0x20
    8000406e:	05890613          	addi	a2,s2,88
    80004072:	86ee                	mv	a3,s11
    80004074:	963a                	add	a2,a2,a4
    80004076:	85d2                	mv	a1,s4
    80004078:	855e                	mv	a0,s7
    8000407a:	fffff097          	auipc	ra,0xfffff
    8000407e:	80c080e7          	jalr	-2036(ra) # 80002886 <either_copyout>
    80004082:	05850d63          	beq	a0,s8,800040dc <readi+0xc2>
    {
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004086:	854a                	mv	a0,s2
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	5f6080e7          	jalr	1526(ra) # 8000367e <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    80004090:	013d09bb          	addw	s3,s10,s3
    80004094:	009d04bb          	addw	s1,s10,s1
    80004098:	9a6e                	add	s4,s4,s11
    8000409a:	0559f763          	bgeu	s3,s5,800040e8 <readi+0xce>
    uint addr = bmap(ip, off / BSIZE);
    8000409e:	00a4d59b          	srliw	a1,s1,0xa
    800040a2:	855a                	mv	a0,s6
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	89e080e7          	jalr	-1890(ra) # 80003942 <bmap>
    800040ac:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    800040b0:	cd85                	beqz	a1,800040e8 <readi+0xce>
    bp = bread(ip->dev, addr);
    800040b2:	000b2503          	lw	a0,0(s6)
    800040b6:	fffff097          	auipc	ra,0xfffff
    800040ba:	498080e7          	jalr	1176(ra) # 8000354e <bread>
    800040be:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800040c0:	3ff4f713          	andi	a4,s1,1023
    800040c4:	40ec87bb          	subw	a5,s9,a4
    800040c8:	413a86bb          	subw	a3,s5,s3
    800040cc:	8d3e                	mv	s10,a5
    800040ce:	2781                	sext.w	a5,a5
    800040d0:	0006861b          	sext.w	a2,a3
    800040d4:	f8f679e3          	bgeu	a2,a5,80004066 <readi+0x4c>
    800040d8:	8d36                	mv	s10,a3
    800040da:	b771                	j	80004066 <readi+0x4c>
      brelse(bp);
    800040dc:	854a                	mv	a0,s2
    800040de:	fffff097          	auipc	ra,0xfffff
    800040e2:	5a0080e7          	jalr	1440(ra) # 8000367e <brelse>
      tot = -1;
    800040e6:	59fd                	li	s3,-1
  }
  return tot;
    800040e8:	0009851b          	sext.w	a0,s3
}
    800040ec:	70a6                	ld	ra,104(sp)
    800040ee:	7406                	ld	s0,96(sp)
    800040f0:	64e6                	ld	s1,88(sp)
    800040f2:	6946                	ld	s2,80(sp)
    800040f4:	69a6                	ld	s3,72(sp)
    800040f6:	6a06                	ld	s4,64(sp)
    800040f8:	7ae2                	ld	s5,56(sp)
    800040fa:	7b42                	ld	s6,48(sp)
    800040fc:	7ba2                	ld	s7,40(sp)
    800040fe:	7c02                	ld	s8,32(sp)
    80004100:	6ce2                	ld	s9,24(sp)
    80004102:	6d42                	ld	s10,16(sp)
    80004104:	6da2                	ld	s11,8(sp)
    80004106:	6165                	addi	sp,sp,112
    80004108:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, dst += m)
    8000410a:	89d6                	mv	s3,s5
    8000410c:	bff1                	j	800040e8 <readi+0xce>
    return 0;
    8000410e:	4501                	li	a0,0
}
    80004110:	8082                	ret

0000000080004112 <writei>:
int writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80004112:	457c                	lw	a5,76(a0)
    80004114:	10d7e863          	bltu	a5,a3,80004224 <writei+0x112>
{
    80004118:	7159                	addi	sp,sp,-112
    8000411a:	f486                	sd	ra,104(sp)
    8000411c:	f0a2                	sd	s0,96(sp)
    8000411e:	eca6                	sd	s1,88(sp)
    80004120:	e8ca                	sd	s2,80(sp)
    80004122:	e4ce                	sd	s3,72(sp)
    80004124:	e0d2                	sd	s4,64(sp)
    80004126:	fc56                	sd	s5,56(sp)
    80004128:	f85a                	sd	s6,48(sp)
    8000412a:	f45e                	sd	s7,40(sp)
    8000412c:	f062                	sd	s8,32(sp)
    8000412e:	ec66                	sd	s9,24(sp)
    80004130:	e86a                	sd	s10,16(sp)
    80004132:	e46e                	sd	s11,8(sp)
    80004134:	1880                	addi	s0,sp,112
    80004136:	8aaa                	mv	s5,a0
    80004138:	8bae                	mv	s7,a1
    8000413a:	8a32                	mv	s4,a2
    8000413c:	8936                	mv	s2,a3
    8000413e:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80004140:	00e687bb          	addw	a5,a3,a4
    80004144:	0ed7e263          	bltu	a5,a3,80004228 <writei+0x116>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80004148:	00043737          	lui	a4,0x43
    8000414c:	0ef76063          	bltu	a4,a5,8000422c <writei+0x11a>
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80004150:	0c0b0863          	beqz	s6,80004220 <writei+0x10e>
    80004154:	4981                	li	s3,0
  {
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80004156:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1)
    8000415a:	5c7d                	li	s8,-1
    8000415c:	a091                	j	800041a0 <writei+0x8e>
    8000415e:	020d1d93          	slli	s11,s10,0x20
    80004162:	020ddd93          	srli	s11,s11,0x20
    80004166:	05848513          	addi	a0,s1,88
    8000416a:	86ee                	mv	a3,s11
    8000416c:	8652                	mv	a2,s4
    8000416e:	85de                	mv	a1,s7
    80004170:	953a                	add	a0,a0,a4
    80004172:	ffffe097          	auipc	ra,0xffffe
    80004176:	76a080e7          	jalr	1898(ra) # 800028dc <either_copyin>
    8000417a:	07850263          	beq	a0,s8,800041de <writei+0xcc>
    {
      brelse(bp);
      break;
    }
    log_write(bp);
    8000417e:	8526                	mv	a0,s1
    80004180:	00000097          	auipc	ra,0x0
    80004184:	788080e7          	jalr	1928(ra) # 80004908 <log_write>
    brelse(bp);
    80004188:	8526                	mv	a0,s1
    8000418a:	fffff097          	auipc	ra,0xfffff
    8000418e:	4f4080e7          	jalr	1268(ra) # 8000367e <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80004192:	013d09bb          	addw	s3,s10,s3
    80004196:	012d093b          	addw	s2,s10,s2
    8000419a:	9a6e                	add	s4,s4,s11
    8000419c:	0569f663          	bgeu	s3,s6,800041e8 <writei+0xd6>
    uint addr = bmap(ip, off / BSIZE);
    800041a0:	00a9559b          	srliw	a1,s2,0xa
    800041a4:	8556                	mv	a0,s5
    800041a6:	fffff097          	auipc	ra,0xfffff
    800041aa:	79c080e7          	jalr	1948(ra) # 80003942 <bmap>
    800041ae:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    800041b2:	c99d                	beqz	a1,800041e8 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800041b4:	000aa503          	lw	a0,0(s5)
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	396080e7          	jalr	918(ra) # 8000354e <bread>
    800041c0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800041c2:	3ff97713          	andi	a4,s2,1023
    800041c6:	40ec87bb          	subw	a5,s9,a4
    800041ca:	413b06bb          	subw	a3,s6,s3
    800041ce:	8d3e                	mv	s10,a5
    800041d0:	2781                	sext.w	a5,a5
    800041d2:	0006861b          	sext.w	a2,a3
    800041d6:	f8f674e3          	bgeu	a2,a5,8000415e <writei+0x4c>
    800041da:	8d36                	mv	s10,a3
    800041dc:	b749                	j	8000415e <writei+0x4c>
      brelse(bp);
    800041de:	8526                	mv	a0,s1
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	49e080e7          	jalr	1182(ra) # 8000367e <brelse>
  }

  if (off > ip->size)
    800041e8:	04caa783          	lw	a5,76(s5)
    800041ec:	0127f463          	bgeu	a5,s2,800041f4 <writei+0xe2>
    ip->size = off;
    800041f0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800041f4:	8556                	mv	a0,s5
    800041f6:	00000097          	auipc	ra,0x0
    800041fa:	aa4080e7          	jalr	-1372(ra) # 80003c9a <iupdate>

  return tot;
    800041fe:	0009851b          	sext.w	a0,s3
}
    80004202:	70a6                	ld	ra,104(sp)
    80004204:	7406                	ld	s0,96(sp)
    80004206:	64e6                	ld	s1,88(sp)
    80004208:	6946                	ld	s2,80(sp)
    8000420a:	69a6                	ld	s3,72(sp)
    8000420c:	6a06                	ld	s4,64(sp)
    8000420e:	7ae2                	ld	s5,56(sp)
    80004210:	7b42                	ld	s6,48(sp)
    80004212:	7ba2                	ld	s7,40(sp)
    80004214:	7c02                	ld	s8,32(sp)
    80004216:	6ce2                	ld	s9,24(sp)
    80004218:	6d42                	ld	s10,16(sp)
    8000421a:	6da2                	ld	s11,8(sp)
    8000421c:	6165                	addi	sp,sp,112
    8000421e:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m)
    80004220:	89da                	mv	s3,s6
    80004222:	bfc9                	j	800041f4 <writei+0xe2>
    return -1;
    80004224:	557d                	li	a0,-1
}
    80004226:	8082                	ret
    return -1;
    80004228:	557d                	li	a0,-1
    8000422a:	bfe1                	j	80004202 <writei+0xf0>
    return -1;
    8000422c:	557d                	li	a0,-1
    8000422e:	bfd1                	j	80004202 <writei+0xf0>

0000000080004230 <namecmp>:

// Directories

int namecmp(const char *s, const char *t)
{
    80004230:	1141                	addi	sp,sp,-16
    80004232:	e406                	sd	ra,8(sp)
    80004234:	e022                	sd	s0,0(sp)
    80004236:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004238:	4639                	li	a2,14
    8000423a:	ffffd097          	auipc	ra,0xffffd
    8000423e:	cdc080e7          	jalr	-804(ra) # 80000f16 <strncmp>
}
    80004242:	60a2                	ld	ra,8(sp)
    80004244:	6402                	ld	s0,0(sp)
    80004246:	0141                	addi	sp,sp,16
    80004248:	8082                	ret

000000008000424a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000424a:	7139                	addi	sp,sp,-64
    8000424c:	fc06                	sd	ra,56(sp)
    8000424e:	f822                	sd	s0,48(sp)
    80004250:	f426                	sd	s1,40(sp)
    80004252:	f04a                	sd	s2,32(sp)
    80004254:	ec4e                	sd	s3,24(sp)
    80004256:	e852                	sd	s4,16(sp)
    80004258:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    8000425a:	04451703          	lh	a4,68(a0)
    8000425e:	4785                	li	a5,1
    80004260:	00f71a63          	bne	a4,a5,80004274 <dirlookup+0x2a>
    80004264:	892a                	mv	s2,a0
    80004266:	89ae                	mv	s3,a1
    80004268:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de))
    8000426a:	457c                	lw	a5,76(a0)
    8000426c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000426e:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de))
    80004270:	e79d                	bnez	a5,8000429e <dirlookup+0x54>
    80004272:	a8a5                	j	800042ea <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004274:	00004517          	auipc	a0,0x4
    80004278:	4dc50513          	addi	a0,a0,1244 # 80008750 <syscalls+0x1b8>
    8000427c:	ffffc097          	auipc	ra,0xffffc
    80004280:	2c4080e7          	jalr	708(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004284:	00004517          	auipc	a0,0x4
    80004288:	4e450513          	addi	a0,a0,1252 # 80008768 <syscalls+0x1d0>
    8000428c:	ffffc097          	auipc	ra,0xffffc
    80004290:	2b4080e7          	jalr	692(ra) # 80000540 <panic>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004294:	24c1                	addiw	s1,s1,16
    80004296:	04c92783          	lw	a5,76(s2)
    8000429a:	04f4f763          	bgeu	s1,a5,800042e8 <dirlookup+0x9e>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000429e:	4741                	li	a4,16
    800042a0:	86a6                	mv	a3,s1
    800042a2:	fc040613          	addi	a2,s0,-64
    800042a6:	4581                	li	a1,0
    800042a8:	854a                	mv	a0,s2
    800042aa:	00000097          	auipc	ra,0x0
    800042ae:	d70080e7          	jalr	-656(ra) # 8000401a <readi>
    800042b2:	47c1                	li	a5,16
    800042b4:	fcf518e3          	bne	a0,a5,80004284 <dirlookup+0x3a>
    if (de.inum == 0)
    800042b8:	fc045783          	lhu	a5,-64(s0)
    800042bc:	dfe1                	beqz	a5,80004294 <dirlookup+0x4a>
    if (namecmp(name, de.name) == 0)
    800042be:	fc240593          	addi	a1,s0,-62
    800042c2:	854e                	mv	a0,s3
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	f6c080e7          	jalr	-148(ra) # 80004230 <namecmp>
    800042cc:	f561                	bnez	a0,80004294 <dirlookup+0x4a>
      if (poff)
    800042ce:	000a0463          	beqz	s4,800042d6 <dirlookup+0x8c>
        *poff = off;
    800042d2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800042d6:	fc045583          	lhu	a1,-64(s0)
    800042da:	00092503          	lw	a0,0(s2)
    800042de:	fffff097          	auipc	ra,0xfffff
    800042e2:	74e080e7          	jalr	1870(ra) # 80003a2c <iget>
    800042e6:	a011                	j	800042ea <dirlookup+0xa0>
  return 0;
    800042e8:	4501                	li	a0,0
}
    800042ea:	70e2                	ld	ra,56(sp)
    800042ec:	7442                	ld	s0,48(sp)
    800042ee:	74a2                	ld	s1,40(sp)
    800042f0:	7902                	ld	s2,32(sp)
    800042f2:	69e2                	ld	s3,24(sp)
    800042f4:	6a42                	ld	s4,16(sp)
    800042f6:	6121                	addi	sp,sp,64
    800042f8:	8082                	ret

00000000800042fa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    800042fa:	711d                	addi	sp,sp,-96
    800042fc:	ec86                	sd	ra,88(sp)
    800042fe:	e8a2                	sd	s0,80(sp)
    80004300:	e4a6                	sd	s1,72(sp)
    80004302:	e0ca                	sd	s2,64(sp)
    80004304:	fc4e                	sd	s3,56(sp)
    80004306:	f852                	sd	s4,48(sp)
    80004308:	f456                	sd	s5,40(sp)
    8000430a:	f05a                	sd	s6,32(sp)
    8000430c:	ec5e                	sd	s7,24(sp)
    8000430e:	e862                	sd	s8,16(sp)
    80004310:	e466                	sd	s9,8(sp)
    80004312:	e06a                	sd	s10,0(sp)
    80004314:	1080                	addi	s0,sp,96
    80004316:	84aa                	mv	s1,a0
    80004318:	8b2e                	mv	s6,a1
    8000431a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    8000431c:	00054703          	lbu	a4,0(a0)
    80004320:	02f00793          	li	a5,47
    80004324:	02f70363          	beq	a4,a5,8000434a <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004328:	ffffe097          	auipc	ra,0xffffe
    8000432c:	834080e7          	jalr	-1996(ra) # 80001b5c <myproc>
    80004330:	15053503          	ld	a0,336(a0)
    80004334:	00000097          	auipc	ra,0x0
    80004338:	9f4080e7          	jalr	-1548(ra) # 80003d28 <idup>
    8000433c:	8a2a                	mv	s4,a0
  while (*path == '/')
    8000433e:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80004342:	4cb5                	li	s9,13
  len = path - s;
    80004344:	4b81                	li	s7,0

  while ((path = skipelem(path, name)) != 0)
  {
    ilock(ip);
    if (ip->type != T_DIR)
    80004346:	4c05                	li	s8,1
    80004348:	a87d                	j	80004406 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    8000434a:	4585                	li	a1,1
    8000434c:	4505                	li	a0,1
    8000434e:	fffff097          	auipc	ra,0xfffff
    80004352:	6de080e7          	jalr	1758(ra) # 80003a2c <iget>
    80004356:	8a2a                	mv	s4,a0
    80004358:	b7dd                	j	8000433e <namex+0x44>
    {
      iunlockput(ip);
    8000435a:	8552                	mv	a0,s4
    8000435c:	00000097          	auipc	ra,0x0
    80004360:	c6c080e7          	jalr	-916(ra) # 80003fc8 <iunlockput>
      return 0;
    80004364:	4a01                	li	s4,0
  {
    iput(ip);
    return 0;
  }
  return ip;
}
    80004366:	8552                	mv	a0,s4
    80004368:	60e6                	ld	ra,88(sp)
    8000436a:	6446                	ld	s0,80(sp)
    8000436c:	64a6                	ld	s1,72(sp)
    8000436e:	6906                	ld	s2,64(sp)
    80004370:	79e2                	ld	s3,56(sp)
    80004372:	7a42                	ld	s4,48(sp)
    80004374:	7aa2                	ld	s5,40(sp)
    80004376:	7b02                	ld	s6,32(sp)
    80004378:	6be2                	ld	s7,24(sp)
    8000437a:	6c42                	ld	s8,16(sp)
    8000437c:	6ca2                	ld	s9,8(sp)
    8000437e:	6d02                	ld	s10,0(sp)
    80004380:	6125                	addi	sp,sp,96
    80004382:	8082                	ret
      iunlock(ip);
    80004384:	8552                	mv	a0,s4
    80004386:	00000097          	auipc	ra,0x0
    8000438a:	aa2080e7          	jalr	-1374(ra) # 80003e28 <iunlock>
      return ip;
    8000438e:	bfe1                	j	80004366 <namex+0x6c>
      iunlockput(ip);
    80004390:	8552                	mv	a0,s4
    80004392:	00000097          	auipc	ra,0x0
    80004396:	c36080e7          	jalr	-970(ra) # 80003fc8 <iunlockput>
      return 0;
    8000439a:	8a4e                	mv	s4,s3
    8000439c:	b7e9                	j	80004366 <namex+0x6c>
  len = path - s;
    8000439e:	40998633          	sub	a2,s3,s1
    800043a2:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    800043a6:	09acd863          	bge	s9,s10,80004436 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800043aa:	4639                	li	a2,14
    800043ac:	85a6                	mv	a1,s1
    800043ae:	8556                	mv	a0,s5
    800043b0:	ffffd097          	auipc	ra,0xffffd
    800043b4:	af2080e7          	jalr	-1294(ra) # 80000ea2 <memmove>
    800043b8:	84ce                	mv	s1,s3
  while (*path == '/')
    800043ba:	0004c783          	lbu	a5,0(s1)
    800043be:	01279763          	bne	a5,s2,800043cc <namex+0xd2>
    path++;
    800043c2:	0485                	addi	s1,s1,1
  while (*path == '/')
    800043c4:	0004c783          	lbu	a5,0(s1)
    800043c8:	ff278de3          	beq	a5,s2,800043c2 <namex+0xc8>
    ilock(ip);
    800043cc:	8552                	mv	a0,s4
    800043ce:	00000097          	auipc	ra,0x0
    800043d2:	998080e7          	jalr	-1640(ra) # 80003d66 <ilock>
    if (ip->type != T_DIR)
    800043d6:	044a1783          	lh	a5,68(s4)
    800043da:	f98790e3          	bne	a5,s8,8000435a <namex+0x60>
    if (nameiparent && *path == '\0')
    800043de:	000b0563          	beqz	s6,800043e8 <namex+0xee>
    800043e2:	0004c783          	lbu	a5,0(s1)
    800043e6:	dfd9                	beqz	a5,80004384 <namex+0x8a>
    if ((next = dirlookup(ip, name, 0)) == 0)
    800043e8:	865e                	mv	a2,s7
    800043ea:	85d6                	mv	a1,s5
    800043ec:	8552                	mv	a0,s4
    800043ee:	00000097          	auipc	ra,0x0
    800043f2:	e5c080e7          	jalr	-420(ra) # 8000424a <dirlookup>
    800043f6:	89aa                	mv	s3,a0
    800043f8:	dd41                	beqz	a0,80004390 <namex+0x96>
    iunlockput(ip);
    800043fa:	8552                	mv	a0,s4
    800043fc:	00000097          	auipc	ra,0x0
    80004400:	bcc080e7          	jalr	-1076(ra) # 80003fc8 <iunlockput>
    ip = next;
    80004404:	8a4e                	mv	s4,s3
  while (*path == '/')
    80004406:	0004c783          	lbu	a5,0(s1)
    8000440a:	01279763          	bne	a5,s2,80004418 <namex+0x11e>
    path++;
    8000440e:	0485                	addi	s1,s1,1
  while (*path == '/')
    80004410:	0004c783          	lbu	a5,0(s1)
    80004414:	ff278de3          	beq	a5,s2,8000440e <namex+0x114>
  if (*path == 0)
    80004418:	cb9d                	beqz	a5,8000444e <namex+0x154>
  while (*path != '/' && *path != 0)
    8000441a:	0004c783          	lbu	a5,0(s1)
    8000441e:	89a6                	mv	s3,s1
  len = path - s;
    80004420:	8d5e                	mv	s10,s7
    80004422:	865e                	mv	a2,s7
  while (*path != '/' && *path != 0)
    80004424:	01278963          	beq	a5,s2,80004436 <namex+0x13c>
    80004428:	dbbd                	beqz	a5,8000439e <namex+0xa4>
    path++;
    8000442a:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    8000442c:	0009c783          	lbu	a5,0(s3)
    80004430:	ff279ce3          	bne	a5,s2,80004428 <namex+0x12e>
    80004434:	b7ad                	j	8000439e <namex+0xa4>
    memmove(name, s, len);
    80004436:	2601                	sext.w	a2,a2
    80004438:	85a6                	mv	a1,s1
    8000443a:	8556                	mv	a0,s5
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	a66080e7          	jalr	-1434(ra) # 80000ea2 <memmove>
    name[len] = 0;
    80004444:	9d56                	add	s10,s10,s5
    80004446:	000d0023          	sb	zero,0(s10)
    8000444a:	84ce                	mv	s1,s3
    8000444c:	b7bd                	j	800043ba <namex+0xc0>
  if (nameiparent)
    8000444e:	f00b0ce3          	beqz	s6,80004366 <namex+0x6c>
    iput(ip);
    80004452:	8552                	mv	a0,s4
    80004454:	00000097          	auipc	ra,0x0
    80004458:	acc080e7          	jalr	-1332(ra) # 80003f20 <iput>
    return 0;
    8000445c:	4a01                	li	s4,0
    8000445e:	b721                	j	80004366 <namex+0x6c>

0000000080004460 <dirlink>:
{
    80004460:	7139                	addi	sp,sp,-64
    80004462:	fc06                	sd	ra,56(sp)
    80004464:	f822                	sd	s0,48(sp)
    80004466:	f426                	sd	s1,40(sp)
    80004468:	f04a                	sd	s2,32(sp)
    8000446a:	ec4e                	sd	s3,24(sp)
    8000446c:	e852                	sd	s4,16(sp)
    8000446e:	0080                	addi	s0,sp,64
    80004470:	892a                	mv	s2,a0
    80004472:	8a2e                	mv	s4,a1
    80004474:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0)
    80004476:	4601                	li	a2,0
    80004478:	00000097          	auipc	ra,0x0
    8000447c:	dd2080e7          	jalr	-558(ra) # 8000424a <dirlookup>
    80004480:	e93d                	bnez	a0,800044f6 <dirlink+0x96>
  for (off = 0; off < dp->size; off += sizeof(de))
    80004482:	04c92483          	lw	s1,76(s2)
    80004486:	c49d                	beqz	s1,800044b4 <dirlink+0x54>
    80004488:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000448a:	4741                	li	a4,16
    8000448c:	86a6                	mv	a3,s1
    8000448e:	fc040613          	addi	a2,s0,-64
    80004492:	4581                	li	a1,0
    80004494:	854a                	mv	a0,s2
    80004496:	00000097          	auipc	ra,0x0
    8000449a:	b84080e7          	jalr	-1148(ra) # 8000401a <readi>
    8000449e:	47c1                	li	a5,16
    800044a0:	06f51163          	bne	a0,a5,80004502 <dirlink+0xa2>
    if (de.inum == 0)
    800044a4:	fc045783          	lhu	a5,-64(s0)
    800044a8:	c791                	beqz	a5,800044b4 <dirlink+0x54>
  for (off = 0; off < dp->size; off += sizeof(de))
    800044aa:	24c1                	addiw	s1,s1,16
    800044ac:	04c92783          	lw	a5,76(s2)
    800044b0:	fcf4ede3          	bltu	s1,a5,8000448a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800044b4:	4639                	li	a2,14
    800044b6:	85d2                	mv	a1,s4
    800044b8:	fc240513          	addi	a0,s0,-62
    800044bc:	ffffd097          	auipc	ra,0xffffd
    800044c0:	a96080e7          	jalr	-1386(ra) # 80000f52 <strncpy>
  de.inum = inum;
    800044c4:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044c8:	4741                	li	a4,16
    800044ca:	86a6                	mv	a3,s1
    800044cc:	fc040613          	addi	a2,s0,-64
    800044d0:	4581                	li	a1,0
    800044d2:	854a                	mv	a0,s2
    800044d4:	00000097          	auipc	ra,0x0
    800044d8:	c3e080e7          	jalr	-962(ra) # 80004112 <writei>
    800044dc:	1541                	addi	a0,a0,-16
    800044de:	00a03533          	snez	a0,a0
    800044e2:	40a00533          	neg	a0,a0
}
    800044e6:	70e2                	ld	ra,56(sp)
    800044e8:	7442                	ld	s0,48(sp)
    800044ea:	74a2                	ld	s1,40(sp)
    800044ec:	7902                	ld	s2,32(sp)
    800044ee:	69e2                	ld	s3,24(sp)
    800044f0:	6a42                	ld	s4,16(sp)
    800044f2:	6121                	addi	sp,sp,64
    800044f4:	8082                	ret
    iput(ip);
    800044f6:	00000097          	auipc	ra,0x0
    800044fa:	a2a080e7          	jalr	-1494(ra) # 80003f20 <iput>
    return -1;
    800044fe:	557d                	li	a0,-1
    80004500:	b7dd                	j	800044e6 <dirlink+0x86>
      panic("dirlink read");
    80004502:	00004517          	auipc	a0,0x4
    80004506:	27650513          	addi	a0,a0,630 # 80008778 <syscalls+0x1e0>
    8000450a:	ffffc097          	auipc	ra,0xffffc
    8000450e:	036080e7          	jalr	54(ra) # 80000540 <panic>

0000000080004512 <namei>:

struct inode *
namei(char *path)
{
    80004512:	1101                	addi	sp,sp,-32
    80004514:	ec06                	sd	ra,24(sp)
    80004516:	e822                	sd	s0,16(sp)
    80004518:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000451a:	fe040613          	addi	a2,s0,-32
    8000451e:	4581                	li	a1,0
    80004520:	00000097          	auipc	ra,0x0
    80004524:	dda080e7          	jalr	-550(ra) # 800042fa <namex>
}
    80004528:	60e2                	ld	ra,24(sp)
    8000452a:	6442                	ld	s0,16(sp)
    8000452c:	6105                	addi	sp,sp,32
    8000452e:	8082                	ret

0000000080004530 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80004530:	1141                	addi	sp,sp,-16
    80004532:	e406                	sd	ra,8(sp)
    80004534:	e022                	sd	s0,0(sp)
    80004536:	0800                	addi	s0,sp,16
    80004538:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000453a:	4585                	li	a1,1
    8000453c:	00000097          	auipc	ra,0x0
    80004540:	dbe080e7          	jalr	-578(ra) # 800042fa <namex>
}
    80004544:	60a2                	ld	ra,8(sp)
    80004546:	6402                	ld	s0,0(sp)
    80004548:	0141                	addi	sp,sp,16
    8000454a:	8082                	ret

000000008000454c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000454c:	1101                	addi	sp,sp,-32
    8000454e:	ec06                	sd	ra,24(sp)
    80004550:	e822                	sd	s0,16(sp)
    80004552:	e426                	sd	s1,8(sp)
    80004554:	e04a                	sd	s2,0(sp)
    80004556:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004558:	0023f917          	auipc	s2,0x23f
    8000455c:	83890913          	addi	s2,s2,-1992 # 80242d90 <log>
    80004560:	01892583          	lw	a1,24(s2)
    80004564:	02892503          	lw	a0,40(s2)
    80004568:	fffff097          	auipc	ra,0xfffff
    8000456c:	fe6080e7          	jalr	-26(ra) # 8000354e <bread>
    80004570:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80004572:	02c92683          	lw	a3,44(s2)
    80004576:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++)
    80004578:	02d05863          	blez	a3,800045a8 <write_head+0x5c>
    8000457c:	0023f797          	auipc	a5,0x23f
    80004580:	84478793          	addi	a5,a5,-1980 # 80242dc0 <log+0x30>
    80004584:	05c50713          	addi	a4,a0,92
    80004588:	36fd                	addiw	a3,a3,-1
    8000458a:	02069613          	slli	a2,a3,0x20
    8000458e:	01e65693          	srli	a3,a2,0x1e
    80004592:	0023f617          	auipc	a2,0x23f
    80004596:	83260613          	addi	a2,a2,-1998 # 80242dc4 <log+0x34>
    8000459a:	96b2                	add	a3,a3,a2
  {
    hb->block[i] = log.lh.block[i];
    8000459c:	4390                	lw	a2,0(a5)
    8000459e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    800045a0:	0791                	addi	a5,a5,4
    800045a2:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800045a4:	fed79ce3          	bne	a5,a3,8000459c <write_head+0x50>
  }
  bwrite(buf);
    800045a8:	8526                	mv	a0,s1
    800045aa:	fffff097          	auipc	ra,0xfffff
    800045ae:	096080e7          	jalr	150(ra) # 80003640 <bwrite>
  brelse(buf);
    800045b2:	8526                	mv	a0,s1
    800045b4:	fffff097          	auipc	ra,0xfffff
    800045b8:	0ca080e7          	jalr	202(ra) # 8000367e <brelse>
}
    800045bc:	60e2                	ld	ra,24(sp)
    800045be:	6442                	ld	s0,16(sp)
    800045c0:	64a2                	ld	s1,8(sp)
    800045c2:	6902                	ld	s2,0(sp)
    800045c4:	6105                	addi	sp,sp,32
    800045c6:	8082                	ret

00000000800045c8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++)
    800045c8:	0023e797          	auipc	a5,0x23e
    800045cc:	7f47a783          	lw	a5,2036(a5) # 80242dbc <log+0x2c>
    800045d0:	0af05d63          	blez	a5,8000468a <install_trans+0xc2>
{
    800045d4:	7139                	addi	sp,sp,-64
    800045d6:	fc06                	sd	ra,56(sp)
    800045d8:	f822                	sd	s0,48(sp)
    800045da:	f426                	sd	s1,40(sp)
    800045dc:	f04a                	sd	s2,32(sp)
    800045de:	ec4e                	sd	s3,24(sp)
    800045e0:	e852                	sd	s4,16(sp)
    800045e2:	e456                	sd	s5,8(sp)
    800045e4:	e05a                	sd	s6,0(sp)
    800045e6:	0080                	addi	s0,sp,64
    800045e8:	8b2a                	mv	s6,a0
    800045ea:	0023ea97          	auipc	s5,0x23e
    800045ee:	7d6a8a93          	addi	s5,s5,2006 # 80242dc0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++)
    800045f2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    800045f4:	0023e997          	auipc	s3,0x23e
    800045f8:	79c98993          	addi	s3,s3,1948 # 80242d90 <log>
    800045fc:	a00d                	j	8000461e <install_trans+0x56>
    brelse(lbuf);
    800045fe:	854a                	mv	a0,s2
    80004600:	fffff097          	auipc	ra,0xfffff
    80004604:	07e080e7          	jalr	126(ra) # 8000367e <brelse>
    brelse(dbuf);
    80004608:	8526                	mv	a0,s1
    8000460a:	fffff097          	auipc	ra,0xfffff
    8000460e:	074080e7          	jalr	116(ra) # 8000367e <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    80004612:	2a05                	addiw	s4,s4,1
    80004614:	0a91                	addi	s5,s5,4
    80004616:	02c9a783          	lw	a5,44(s3)
    8000461a:	04fa5e63          	bge	s4,a5,80004676 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    8000461e:	0189a583          	lw	a1,24(s3)
    80004622:	014585bb          	addw	a1,a1,s4
    80004626:	2585                	addiw	a1,a1,1
    80004628:	0289a503          	lw	a0,40(s3)
    8000462c:	fffff097          	auipc	ra,0xfffff
    80004630:	f22080e7          	jalr	-222(ra) # 8000354e <bread>
    80004634:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80004636:	000aa583          	lw	a1,0(s5)
    8000463a:	0289a503          	lw	a0,40(s3)
    8000463e:	fffff097          	auipc	ra,0xfffff
    80004642:	f10080e7          	jalr	-240(ra) # 8000354e <bread>
    80004646:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);                  // copy block to dst
    80004648:	40000613          	li	a2,1024
    8000464c:	05890593          	addi	a1,s2,88
    80004650:	05850513          	addi	a0,a0,88
    80004654:	ffffd097          	auipc	ra,0xffffd
    80004658:	84e080e7          	jalr	-1970(ra) # 80000ea2 <memmove>
    bwrite(dbuf);                                            // write dst to disk
    8000465c:	8526                	mv	a0,s1
    8000465e:	fffff097          	auipc	ra,0xfffff
    80004662:	fe2080e7          	jalr	-30(ra) # 80003640 <bwrite>
    if (recovering == 0)
    80004666:	f80b1ce3          	bnez	s6,800045fe <install_trans+0x36>
      bunpin(dbuf);
    8000466a:	8526                	mv	a0,s1
    8000466c:	fffff097          	auipc	ra,0xfffff
    80004670:	0ec080e7          	jalr	236(ra) # 80003758 <bunpin>
    80004674:	b769                	j	800045fe <install_trans+0x36>
}
    80004676:	70e2                	ld	ra,56(sp)
    80004678:	7442                	ld	s0,48(sp)
    8000467a:	74a2                	ld	s1,40(sp)
    8000467c:	7902                	ld	s2,32(sp)
    8000467e:	69e2                	ld	s3,24(sp)
    80004680:	6a42                	ld	s4,16(sp)
    80004682:	6aa2                	ld	s5,8(sp)
    80004684:	6b02                	ld	s6,0(sp)
    80004686:	6121                	addi	sp,sp,64
    80004688:	8082                	ret
    8000468a:	8082                	ret

000000008000468c <initlog>:
{
    8000468c:	7179                	addi	sp,sp,-48
    8000468e:	f406                	sd	ra,40(sp)
    80004690:	f022                	sd	s0,32(sp)
    80004692:	ec26                	sd	s1,24(sp)
    80004694:	e84a                	sd	s2,16(sp)
    80004696:	e44e                	sd	s3,8(sp)
    80004698:	1800                	addi	s0,sp,48
    8000469a:	892a                	mv	s2,a0
    8000469c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000469e:	0023e497          	auipc	s1,0x23e
    800046a2:	6f248493          	addi	s1,s1,1778 # 80242d90 <log>
    800046a6:	00004597          	auipc	a1,0x4
    800046aa:	0e258593          	addi	a1,a1,226 # 80008788 <syscalls+0x1f0>
    800046ae:	8526                	mv	a0,s1
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	60a080e7          	jalr	1546(ra) # 80000cba <initlock>
  log.start = sb->logstart;
    800046b8:	0149a583          	lw	a1,20(s3)
    800046bc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800046be:	0109a783          	lw	a5,16(s3)
    800046c2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800046c4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800046c8:	854a                	mv	a0,s2
    800046ca:	fffff097          	auipc	ra,0xfffff
    800046ce:	e84080e7          	jalr	-380(ra) # 8000354e <bread>
  log.lh.n = lh->n;
    800046d2:	4d34                	lw	a3,88(a0)
    800046d4:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++)
    800046d6:	02d05663          	blez	a3,80004702 <initlog+0x76>
    800046da:	05c50793          	addi	a5,a0,92
    800046de:	0023e717          	auipc	a4,0x23e
    800046e2:	6e270713          	addi	a4,a4,1762 # 80242dc0 <log+0x30>
    800046e6:	36fd                	addiw	a3,a3,-1
    800046e8:	02069613          	slli	a2,a3,0x20
    800046ec:	01e65693          	srli	a3,a2,0x1e
    800046f0:	06050613          	addi	a2,a0,96
    800046f4:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800046f6:	4390                	lw	a2,0(a5)
    800046f8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++)
    800046fa:	0791                	addi	a5,a5,4
    800046fc:	0711                	addi	a4,a4,4
    800046fe:	fed79ce3          	bne	a5,a3,800046f6 <initlog+0x6a>
  brelse(buf);
    80004702:	fffff097          	auipc	ra,0xfffff
    80004706:	f7c080e7          	jalr	-132(ra) # 8000367e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000470a:	4505                	li	a0,1
    8000470c:	00000097          	auipc	ra,0x0
    80004710:	ebc080e7          	jalr	-324(ra) # 800045c8 <install_trans>
  log.lh.n = 0;
    80004714:	0023e797          	auipc	a5,0x23e
    80004718:	6a07a423          	sw	zero,1704(a5) # 80242dbc <log+0x2c>
  write_head(); // clear the log
    8000471c:	00000097          	auipc	ra,0x0
    80004720:	e30080e7          	jalr	-464(ra) # 8000454c <write_head>
}
    80004724:	70a2                	ld	ra,40(sp)
    80004726:	7402                	ld	s0,32(sp)
    80004728:	64e2                	ld	s1,24(sp)
    8000472a:	6942                	ld	s2,16(sp)
    8000472c:	69a2                	ld	s3,8(sp)
    8000472e:	6145                	addi	sp,sp,48
    80004730:	8082                	ret

0000000080004732 <begin_op>:
}

// called at the start of each FS system call.
void begin_op(void)
{
    80004732:	1101                	addi	sp,sp,-32
    80004734:	ec06                	sd	ra,24(sp)
    80004736:	e822                	sd	s0,16(sp)
    80004738:	e426                	sd	s1,8(sp)
    8000473a:	e04a                	sd	s2,0(sp)
    8000473c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000473e:	0023e517          	auipc	a0,0x23e
    80004742:	65250513          	addi	a0,a0,1618 # 80242d90 <log>
    80004746:	ffffc097          	auipc	ra,0xffffc
    8000474a:	604080e7          	jalr	1540(ra) # 80000d4a <acquire>
  while (1)
  {
    if (log.committing)
    8000474e:	0023e497          	auipc	s1,0x23e
    80004752:	64248493          	addi	s1,s1,1602 # 80242d90 <log>
    {
      sleep(&log, &log.lock);
    }
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    80004756:	4979                	li	s2,30
    80004758:	a039                	j	80004766 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000475a:	85a6                	mv	a1,s1
    8000475c:	8526                	mv	a0,s1
    8000475e:	ffffe097          	auipc	ra,0xffffe
    80004762:	b9c080e7          	jalr	-1124(ra) # 800022fa <sleep>
    if (log.committing)
    80004766:	50dc                	lw	a5,36(s1)
    80004768:	fbed                	bnez	a5,8000475a <begin_op+0x28>
    else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE)
    8000476a:	5098                	lw	a4,32(s1)
    8000476c:	2705                	addiw	a4,a4,1
    8000476e:	0007069b          	sext.w	a3,a4
    80004772:	0027179b          	slliw	a5,a4,0x2
    80004776:	9fb9                	addw	a5,a5,a4
    80004778:	0017979b          	slliw	a5,a5,0x1
    8000477c:	54d8                	lw	a4,44(s1)
    8000477e:	9fb9                	addw	a5,a5,a4
    80004780:	00f95963          	bge	s2,a5,80004792 <begin_op+0x60>
    {
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004784:	85a6                	mv	a1,s1
    80004786:	8526                	mv	a0,s1
    80004788:	ffffe097          	auipc	ra,0xffffe
    8000478c:	b72080e7          	jalr	-1166(ra) # 800022fa <sleep>
    80004790:	bfd9                	j	80004766 <begin_op+0x34>
    }
    else
    {
      log.outstanding += 1;
    80004792:	0023e517          	auipc	a0,0x23e
    80004796:	5fe50513          	addi	a0,a0,1534 # 80242d90 <log>
    8000479a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	662080e7          	jalr	1634(ra) # 80000dfe <release>
      break;
    }
  }
}
    800047a4:	60e2                	ld	ra,24(sp)
    800047a6:	6442                	ld	s0,16(sp)
    800047a8:	64a2                	ld	s1,8(sp)
    800047aa:	6902                	ld	s2,0(sp)
    800047ac:	6105                	addi	sp,sp,32
    800047ae:	8082                	ret

00000000800047b0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
    800047b0:	7139                	addi	sp,sp,-64
    800047b2:	fc06                	sd	ra,56(sp)
    800047b4:	f822                	sd	s0,48(sp)
    800047b6:	f426                	sd	s1,40(sp)
    800047b8:	f04a                	sd	s2,32(sp)
    800047ba:	ec4e                	sd	s3,24(sp)
    800047bc:	e852                	sd	s4,16(sp)
    800047be:	e456                	sd	s5,8(sp)
    800047c0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800047c2:	0023e497          	auipc	s1,0x23e
    800047c6:	5ce48493          	addi	s1,s1,1486 # 80242d90 <log>
    800047ca:	8526                	mv	a0,s1
    800047cc:	ffffc097          	auipc	ra,0xffffc
    800047d0:	57e080e7          	jalr	1406(ra) # 80000d4a <acquire>
  log.outstanding -= 1;
    800047d4:	509c                	lw	a5,32(s1)
    800047d6:	37fd                	addiw	a5,a5,-1
    800047d8:	0007891b          	sext.w	s2,a5
    800047dc:	d09c                	sw	a5,32(s1)
  if (log.committing)
    800047de:	50dc                	lw	a5,36(s1)
    800047e0:	e7b9                	bnez	a5,8000482e <end_op+0x7e>
    panic("log.committing");
  if (log.outstanding == 0)
    800047e2:	04091e63          	bnez	s2,8000483e <end_op+0x8e>
  {
    do_commit = 1;
    log.committing = 1;
    800047e6:	0023e497          	auipc	s1,0x23e
    800047ea:	5aa48493          	addi	s1,s1,1450 # 80242d90 <log>
    800047ee:	4785                	li	a5,1
    800047f0:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800047f2:	8526                	mv	a0,s1
    800047f4:	ffffc097          	auipc	ra,0xffffc
    800047f8:	60a080e7          	jalr	1546(ra) # 80000dfe <release>
}

static void
commit()
{
  if (log.lh.n > 0)
    800047fc:	54dc                	lw	a5,44(s1)
    800047fe:	06f04763          	bgtz	a5,8000486c <end_op+0xbc>
    acquire(&log.lock);
    80004802:	0023e497          	auipc	s1,0x23e
    80004806:	58e48493          	addi	s1,s1,1422 # 80242d90 <log>
    8000480a:	8526                	mv	a0,s1
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	53e080e7          	jalr	1342(ra) # 80000d4a <acquire>
    log.committing = 0;
    80004814:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004818:	8526                	mv	a0,s1
    8000481a:	ffffe097          	auipc	ra,0xffffe
    8000481e:	c9c080e7          	jalr	-868(ra) # 800024b6 <wakeup>
    release(&log.lock);
    80004822:	8526                	mv	a0,s1
    80004824:	ffffc097          	auipc	ra,0xffffc
    80004828:	5da080e7          	jalr	1498(ra) # 80000dfe <release>
}
    8000482c:	a03d                	j	8000485a <end_op+0xaa>
    panic("log.committing");
    8000482e:	00004517          	auipc	a0,0x4
    80004832:	f6250513          	addi	a0,a0,-158 # 80008790 <syscalls+0x1f8>
    80004836:	ffffc097          	auipc	ra,0xffffc
    8000483a:	d0a080e7          	jalr	-758(ra) # 80000540 <panic>
    wakeup(&log);
    8000483e:	0023e497          	auipc	s1,0x23e
    80004842:	55248493          	addi	s1,s1,1362 # 80242d90 <log>
    80004846:	8526                	mv	a0,s1
    80004848:	ffffe097          	auipc	ra,0xffffe
    8000484c:	c6e080e7          	jalr	-914(ra) # 800024b6 <wakeup>
  release(&log.lock);
    80004850:	8526                	mv	a0,s1
    80004852:	ffffc097          	auipc	ra,0xffffc
    80004856:	5ac080e7          	jalr	1452(ra) # 80000dfe <release>
}
    8000485a:	70e2                	ld	ra,56(sp)
    8000485c:	7442                	ld	s0,48(sp)
    8000485e:	74a2                	ld	s1,40(sp)
    80004860:	7902                	ld	s2,32(sp)
    80004862:	69e2                	ld	s3,24(sp)
    80004864:	6a42                	ld	s4,16(sp)
    80004866:	6aa2                	ld	s5,8(sp)
    80004868:	6121                	addi	sp,sp,64
    8000486a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++)
    8000486c:	0023ea97          	auipc	s5,0x23e
    80004870:	554a8a93          	addi	s5,s5,1364 # 80242dc0 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80004874:	0023ea17          	auipc	s4,0x23e
    80004878:	51ca0a13          	addi	s4,s4,1308 # 80242d90 <log>
    8000487c:	018a2583          	lw	a1,24(s4)
    80004880:	012585bb          	addw	a1,a1,s2
    80004884:	2585                	addiw	a1,a1,1
    80004886:	028a2503          	lw	a0,40(s4)
    8000488a:	fffff097          	auipc	ra,0xfffff
    8000488e:	cc4080e7          	jalr	-828(ra) # 8000354e <bread>
    80004892:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004894:	000aa583          	lw	a1,0(s5)
    80004898:	028a2503          	lw	a0,40(s4)
    8000489c:	fffff097          	auipc	ra,0xfffff
    800048a0:	cb2080e7          	jalr	-846(ra) # 8000354e <bread>
    800048a4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800048a6:	40000613          	li	a2,1024
    800048aa:	05850593          	addi	a1,a0,88
    800048ae:	05848513          	addi	a0,s1,88
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	5f0080e7          	jalr	1520(ra) # 80000ea2 <memmove>
    bwrite(to); // write the log
    800048ba:	8526                	mv	a0,s1
    800048bc:	fffff097          	auipc	ra,0xfffff
    800048c0:	d84080e7          	jalr	-636(ra) # 80003640 <bwrite>
    brelse(from);
    800048c4:	854e                	mv	a0,s3
    800048c6:	fffff097          	auipc	ra,0xfffff
    800048ca:	db8080e7          	jalr	-584(ra) # 8000367e <brelse>
    brelse(to);
    800048ce:	8526                	mv	a0,s1
    800048d0:	fffff097          	auipc	ra,0xfffff
    800048d4:	dae080e7          	jalr	-594(ra) # 8000367e <brelse>
  for (tail = 0; tail < log.lh.n; tail++)
    800048d8:	2905                	addiw	s2,s2,1
    800048da:	0a91                	addi	s5,s5,4
    800048dc:	02ca2783          	lw	a5,44(s4)
    800048e0:	f8f94ee3          	blt	s2,a5,8000487c <end_op+0xcc>
  {
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    800048e4:	00000097          	auipc	ra,0x0
    800048e8:	c68080e7          	jalr	-920(ra) # 8000454c <write_head>
    install_trans(0); // Now install writes to home locations
    800048ec:	4501                	li	a0,0
    800048ee:	00000097          	auipc	ra,0x0
    800048f2:	cda080e7          	jalr	-806(ra) # 800045c8 <install_trans>
    log.lh.n = 0;
    800048f6:	0023e797          	auipc	a5,0x23e
    800048fa:	4c07a323          	sw	zero,1222(a5) # 80242dbc <log+0x2c>
    write_head(); // Erase the transaction from the log
    800048fe:	00000097          	auipc	ra,0x0
    80004902:	c4e080e7          	jalr	-946(ra) # 8000454c <write_head>
    80004906:	bdf5                	j	80004802 <end_op+0x52>

0000000080004908 <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
    80004908:	1101                	addi	sp,sp,-32
    8000490a:	ec06                	sd	ra,24(sp)
    8000490c:	e822                	sd	s0,16(sp)
    8000490e:	e426                	sd	s1,8(sp)
    80004910:	e04a                	sd	s2,0(sp)
    80004912:	1000                	addi	s0,sp,32
    80004914:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004916:	0023e917          	auipc	s2,0x23e
    8000491a:	47a90913          	addi	s2,s2,1146 # 80242d90 <log>
    8000491e:	854a                	mv	a0,s2
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	42a080e7          	jalr	1066(ra) # 80000d4a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004928:	02c92603          	lw	a2,44(s2)
    8000492c:	47f5                	li	a5,29
    8000492e:	06c7c563          	blt	a5,a2,80004998 <log_write+0x90>
    80004932:	0023e797          	auipc	a5,0x23e
    80004936:	47a7a783          	lw	a5,1146(a5) # 80242dac <log+0x1c>
    8000493a:	37fd                	addiw	a5,a5,-1
    8000493c:	04f65e63          	bge	a2,a5,80004998 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004940:	0023e797          	auipc	a5,0x23e
    80004944:	4707a783          	lw	a5,1136(a5) # 80242db0 <log+0x20>
    80004948:	06f05063          	blez	a5,800049a8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++)
    8000494c:	4781                	li	a5,0
    8000494e:	06c05563          	blez	a2,800049b8 <log_write+0xb0>
  {
    if (log.lh.block[i] == b->blockno) // log absorption
    80004952:	44cc                	lw	a1,12(s1)
    80004954:	0023e717          	auipc	a4,0x23e
    80004958:	46c70713          	addi	a4,a4,1132 # 80242dc0 <log+0x30>
  for (i = 0; i < log.lh.n; i++)
    8000495c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    8000495e:	4314                	lw	a3,0(a4)
    80004960:	04b68c63          	beq	a3,a1,800049b8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++)
    80004964:	2785                	addiw	a5,a5,1
    80004966:	0711                	addi	a4,a4,4
    80004968:	fef61be3          	bne	a2,a5,8000495e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000496c:	0621                	addi	a2,a2,8
    8000496e:	060a                	slli	a2,a2,0x2
    80004970:	0023e797          	auipc	a5,0x23e
    80004974:	42078793          	addi	a5,a5,1056 # 80242d90 <log>
    80004978:	97b2                	add	a5,a5,a2
    8000497a:	44d8                	lw	a4,12(s1)
    8000497c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n)
  { // Add new block to log?
    bpin(b);
    8000497e:	8526                	mv	a0,s1
    80004980:	fffff097          	auipc	ra,0xfffff
    80004984:	d9c080e7          	jalr	-612(ra) # 8000371c <bpin>
    log.lh.n++;
    80004988:	0023e717          	auipc	a4,0x23e
    8000498c:	40870713          	addi	a4,a4,1032 # 80242d90 <log>
    80004990:	575c                	lw	a5,44(a4)
    80004992:	2785                	addiw	a5,a5,1
    80004994:	d75c                	sw	a5,44(a4)
    80004996:	a82d                	j	800049d0 <log_write+0xc8>
    panic("too big a transaction");
    80004998:	00004517          	auipc	a0,0x4
    8000499c:	e0850513          	addi	a0,a0,-504 # 800087a0 <syscalls+0x208>
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	ba0080e7          	jalr	-1120(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    800049a8:	00004517          	auipc	a0,0x4
    800049ac:	e1050513          	addi	a0,a0,-496 # 800087b8 <syscalls+0x220>
    800049b0:	ffffc097          	auipc	ra,0xffffc
    800049b4:	b90080e7          	jalr	-1136(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    800049b8:	00878693          	addi	a3,a5,8
    800049bc:	068a                	slli	a3,a3,0x2
    800049be:	0023e717          	auipc	a4,0x23e
    800049c2:	3d270713          	addi	a4,a4,978 # 80242d90 <log>
    800049c6:	9736                	add	a4,a4,a3
    800049c8:	44d4                	lw	a3,12(s1)
    800049ca:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n)
    800049cc:	faf609e3          	beq	a2,a5,8000497e <log_write+0x76>
  }
  release(&log.lock);
    800049d0:	0023e517          	auipc	a0,0x23e
    800049d4:	3c050513          	addi	a0,a0,960 # 80242d90 <log>
    800049d8:	ffffc097          	auipc	ra,0xffffc
    800049dc:	426080e7          	jalr	1062(ra) # 80000dfe <release>
}
    800049e0:	60e2                	ld	ra,24(sp)
    800049e2:	6442                	ld	s0,16(sp)
    800049e4:	64a2                	ld	s1,8(sp)
    800049e6:	6902                	ld	s2,0(sp)
    800049e8:	6105                	addi	sp,sp,32
    800049ea:	8082                	ret

00000000800049ec <initsleeplock>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock *lk, char *name)
{
    800049ec:	1101                	addi	sp,sp,-32
    800049ee:	ec06                	sd	ra,24(sp)
    800049f0:	e822                	sd	s0,16(sp)
    800049f2:	e426                	sd	s1,8(sp)
    800049f4:	e04a                	sd	s2,0(sp)
    800049f6:	1000                	addi	s0,sp,32
    800049f8:	84aa                	mv	s1,a0
    800049fa:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049fc:	00004597          	auipc	a1,0x4
    80004a00:	ddc58593          	addi	a1,a1,-548 # 800087d8 <syscalls+0x240>
    80004a04:	0521                	addi	a0,a0,8
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	2b4080e7          	jalr	692(ra) # 80000cba <initlock>
  lk->name = name;
    80004a0e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a12:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a16:	0204a423          	sw	zero,40(s1)
}
    80004a1a:	60e2                	ld	ra,24(sp)
    80004a1c:	6442                	ld	s0,16(sp)
    80004a1e:	64a2                	ld	s1,8(sp)
    80004a20:	6902                	ld	s2,0(sp)
    80004a22:	6105                	addi	sp,sp,32
    80004a24:	8082                	ret

0000000080004a26 <acquiresleep>:

void acquiresleep(struct sleeplock *lk)
{
    80004a26:	1101                	addi	sp,sp,-32
    80004a28:	ec06                	sd	ra,24(sp)
    80004a2a:	e822                	sd	s0,16(sp)
    80004a2c:	e426                	sd	s1,8(sp)
    80004a2e:	e04a                	sd	s2,0(sp)
    80004a30:	1000                	addi	s0,sp,32
    80004a32:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a34:	00850913          	addi	s2,a0,8
    80004a38:	854a                	mv	a0,s2
    80004a3a:	ffffc097          	auipc	ra,0xffffc
    80004a3e:	310080e7          	jalr	784(ra) # 80000d4a <acquire>
  while (lk->locked)
    80004a42:	409c                	lw	a5,0(s1)
    80004a44:	cb89                	beqz	a5,80004a56 <acquiresleep+0x30>
  {
    sleep(lk, &lk->lk);
    80004a46:	85ca                	mv	a1,s2
    80004a48:	8526                	mv	a0,s1
    80004a4a:	ffffe097          	auipc	ra,0xffffe
    80004a4e:	8b0080e7          	jalr	-1872(ra) # 800022fa <sleep>
  while (lk->locked)
    80004a52:	409c                	lw	a5,0(s1)
    80004a54:	fbed                	bnez	a5,80004a46 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004a56:	4785                	li	a5,1
    80004a58:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a5a:	ffffd097          	auipc	ra,0xffffd
    80004a5e:	102080e7          	jalr	258(ra) # 80001b5c <myproc>
    80004a62:	591c                	lw	a5,48(a0)
    80004a64:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a66:	854a                	mv	a0,s2
    80004a68:	ffffc097          	auipc	ra,0xffffc
    80004a6c:	396080e7          	jalr	918(ra) # 80000dfe <release>
}
    80004a70:	60e2                	ld	ra,24(sp)
    80004a72:	6442                	ld	s0,16(sp)
    80004a74:	64a2                	ld	s1,8(sp)
    80004a76:	6902                	ld	s2,0(sp)
    80004a78:	6105                	addi	sp,sp,32
    80004a7a:	8082                	ret

0000000080004a7c <releasesleep>:

void releasesleep(struct sleeplock *lk)
{
    80004a7c:	1101                	addi	sp,sp,-32
    80004a7e:	ec06                	sd	ra,24(sp)
    80004a80:	e822                	sd	s0,16(sp)
    80004a82:	e426                	sd	s1,8(sp)
    80004a84:	e04a                	sd	s2,0(sp)
    80004a86:	1000                	addi	s0,sp,32
    80004a88:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a8a:	00850913          	addi	s2,a0,8
    80004a8e:	854a                	mv	a0,s2
    80004a90:	ffffc097          	auipc	ra,0xffffc
    80004a94:	2ba080e7          	jalr	698(ra) # 80000d4a <acquire>
  lk->locked = 0;
    80004a98:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a9c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	ffffe097          	auipc	ra,0xffffe
    80004aa6:	a14080e7          	jalr	-1516(ra) # 800024b6 <wakeup>
  release(&lk->lk);
    80004aaa:	854a                	mv	a0,s2
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	352080e7          	jalr	850(ra) # 80000dfe <release>
}
    80004ab4:	60e2                	ld	ra,24(sp)
    80004ab6:	6442                	ld	s0,16(sp)
    80004ab8:	64a2                	ld	s1,8(sp)
    80004aba:	6902                	ld	s2,0(sp)
    80004abc:	6105                	addi	sp,sp,32
    80004abe:	8082                	ret

0000000080004ac0 <holdingsleep>:

int holdingsleep(struct sleeplock *lk)
{
    80004ac0:	7179                	addi	sp,sp,-48
    80004ac2:	f406                	sd	ra,40(sp)
    80004ac4:	f022                	sd	s0,32(sp)
    80004ac6:	ec26                	sd	s1,24(sp)
    80004ac8:	e84a                	sd	s2,16(sp)
    80004aca:	e44e                	sd	s3,8(sp)
    80004acc:	1800                	addi	s0,sp,48
    80004ace:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004ad0:	00850913          	addi	s2,a0,8
    80004ad4:	854a                	mv	a0,s2
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	274080e7          	jalr	628(ra) # 80000d4a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ade:	409c                	lw	a5,0(s1)
    80004ae0:	ef99                	bnez	a5,80004afe <holdingsleep+0x3e>
    80004ae2:	4481                	li	s1,0
  release(&lk->lk);
    80004ae4:	854a                	mv	a0,s2
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	318080e7          	jalr	792(ra) # 80000dfe <release>
  return r;
}
    80004aee:	8526                	mv	a0,s1
    80004af0:	70a2                	ld	ra,40(sp)
    80004af2:	7402                	ld	s0,32(sp)
    80004af4:	64e2                	ld	s1,24(sp)
    80004af6:	6942                	ld	s2,16(sp)
    80004af8:	69a2                	ld	s3,8(sp)
    80004afa:	6145                	addi	sp,sp,48
    80004afc:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004afe:	0284a983          	lw	s3,40(s1)
    80004b02:	ffffd097          	auipc	ra,0xffffd
    80004b06:	05a080e7          	jalr	90(ra) # 80001b5c <myproc>
    80004b0a:	5904                	lw	s1,48(a0)
    80004b0c:	413484b3          	sub	s1,s1,s3
    80004b10:	0014b493          	seqz	s1,s1
    80004b14:	bfc1                	j	80004ae4 <holdingsleep+0x24>

0000000080004b16 <fileinit>:
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void fileinit(void)
{
    80004b16:	1141                	addi	sp,sp,-16
    80004b18:	e406                	sd	ra,8(sp)
    80004b1a:	e022                	sd	s0,0(sp)
    80004b1c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b1e:	00004597          	auipc	a1,0x4
    80004b22:	cca58593          	addi	a1,a1,-822 # 800087e8 <syscalls+0x250>
    80004b26:	0023e517          	auipc	a0,0x23e
    80004b2a:	3b250513          	addi	a0,a0,946 # 80242ed8 <ftable>
    80004b2e:	ffffc097          	auipc	ra,0xffffc
    80004b32:	18c080e7          	jalr	396(ra) # 80000cba <initlock>
}
    80004b36:	60a2                	ld	ra,8(sp)
    80004b38:	6402                	ld	s0,0(sp)
    80004b3a:	0141                	addi	sp,sp,16
    80004b3c:	8082                	ret

0000000080004b3e <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004b3e:	1101                	addi	sp,sp,-32
    80004b40:	ec06                	sd	ra,24(sp)
    80004b42:	e822                	sd	s0,16(sp)
    80004b44:	e426                	sd	s1,8(sp)
    80004b46:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004b48:	0023e517          	auipc	a0,0x23e
    80004b4c:	39050513          	addi	a0,a0,912 # 80242ed8 <ftable>
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	1fa080e7          	jalr	506(ra) # 80000d4a <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004b58:	0023e497          	auipc	s1,0x23e
    80004b5c:	39848493          	addi	s1,s1,920 # 80242ef0 <ftable+0x18>
    80004b60:	0023f717          	auipc	a4,0x23f
    80004b64:	33070713          	addi	a4,a4,816 # 80243e90 <mt>
  {
    if (f->ref == 0)
    80004b68:	40dc                	lw	a5,4(s1)
    80004b6a:	cf99                	beqz	a5,80004b88 <filealloc+0x4a>
  for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004b6c:	02848493          	addi	s1,s1,40
    80004b70:	fee49ce3          	bne	s1,a4,80004b68 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b74:	0023e517          	auipc	a0,0x23e
    80004b78:	36450513          	addi	a0,a0,868 # 80242ed8 <ftable>
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	282080e7          	jalr	642(ra) # 80000dfe <release>
  return 0;
    80004b84:	4481                	li	s1,0
    80004b86:	a819                	j	80004b9c <filealloc+0x5e>
      f->ref = 1;
    80004b88:	4785                	li	a5,1
    80004b8a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b8c:	0023e517          	auipc	a0,0x23e
    80004b90:	34c50513          	addi	a0,a0,844 # 80242ed8 <ftable>
    80004b94:	ffffc097          	auipc	ra,0xffffc
    80004b98:	26a080e7          	jalr	618(ra) # 80000dfe <release>
}
    80004b9c:	8526                	mv	a0,s1
    80004b9e:	60e2                	ld	ra,24(sp)
    80004ba0:	6442                	ld	s0,16(sp)
    80004ba2:	64a2                	ld	s1,8(sp)
    80004ba4:	6105                	addi	sp,sp,32
    80004ba6:	8082                	ret

0000000080004ba8 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004ba8:	1101                	addi	sp,sp,-32
    80004baa:	ec06                	sd	ra,24(sp)
    80004bac:	e822                	sd	s0,16(sp)
    80004bae:	e426                	sd	s1,8(sp)
    80004bb0:	1000                	addi	s0,sp,32
    80004bb2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004bb4:	0023e517          	auipc	a0,0x23e
    80004bb8:	32450513          	addi	a0,a0,804 # 80242ed8 <ftable>
    80004bbc:	ffffc097          	auipc	ra,0xffffc
    80004bc0:	18e080e7          	jalr	398(ra) # 80000d4a <acquire>
  if (f->ref < 1)
    80004bc4:	40dc                	lw	a5,4(s1)
    80004bc6:	02f05263          	blez	a5,80004bea <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004bca:	2785                	addiw	a5,a5,1
    80004bcc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004bce:	0023e517          	auipc	a0,0x23e
    80004bd2:	30a50513          	addi	a0,a0,778 # 80242ed8 <ftable>
    80004bd6:	ffffc097          	auipc	ra,0xffffc
    80004bda:	228080e7          	jalr	552(ra) # 80000dfe <release>
  return f;
}
    80004bde:	8526                	mv	a0,s1
    80004be0:	60e2                	ld	ra,24(sp)
    80004be2:	6442                	ld	s0,16(sp)
    80004be4:	64a2                	ld	s1,8(sp)
    80004be6:	6105                	addi	sp,sp,32
    80004be8:	8082                	ret
    panic("filedup");
    80004bea:	00004517          	auipc	a0,0x4
    80004bee:	c0650513          	addi	a0,a0,-1018 # 800087f0 <syscalls+0x258>
    80004bf2:	ffffc097          	auipc	ra,0xffffc
    80004bf6:	94e080e7          	jalr	-1714(ra) # 80000540 <panic>

0000000080004bfa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    80004bfa:	7139                	addi	sp,sp,-64
    80004bfc:	fc06                	sd	ra,56(sp)
    80004bfe:	f822                	sd	s0,48(sp)
    80004c00:	f426                	sd	s1,40(sp)
    80004c02:	f04a                	sd	s2,32(sp)
    80004c04:	ec4e                	sd	s3,24(sp)
    80004c06:	e852                	sd	s4,16(sp)
    80004c08:	e456                	sd	s5,8(sp)
    80004c0a:	0080                	addi	s0,sp,64
    80004c0c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c0e:	0023e517          	auipc	a0,0x23e
    80004c12:	2ca50513          	addi	a0,a0,714 # 80242ed8 <ftable>
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	134080e7          	jalr	308(ra) # 80000d4a <acquire>
  if (f->ref < 1)
    80004c1e:	40dc                	lw	a5,4(s1)
    80004c20:	06f05163          	blez	a5,80004c82 <fileclose+0x88>
    panic("fileclose");
  if (--f->ref > 0)
    80004c24:	37fd                	addiw	a5,a5,-1
    80004c26:	0007871b          	sext.w	a4,a5
    80004c2a:	c0dc                	sw	a5,4(s1)
    80004c2c:	06e04363          	bgtz	a4,80004c92 <fileclose+0x98>
  {
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c30:	0004a903          	lw	s2,0(s1)
    80004c34:	0094ca83          	lbu	s5,9(s1)
    80004c38:	0104ba03          	ld	s4,16(s1)
    80004c3c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c40:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004c44:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004c48:	0023e517          	auipc	a0,0x23e
    80004c4c:	29050513          	addi	a0,a0,656 # 80242ed8 <ftable>
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	1ae080e7          	jalr	430(ra) # 80000dfe <release>

  if (ff.type == FD_PIPE)
    80004c58:	4785                	li	a5,1
    80004c5a:	04f90d63          	beq	s2,a5,80004cb4 <fileclose+0xba>
  {
    pipeclose(ff.pipe, ff.writable);
  }
  else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    80004c5e:	3979                	addiw	s2,s2,-2
    80004c60:	4785                	li	a5,1
    80004c62:	0527e063          	bltu	a5,s2,80004ca2 <fileclose+0xa8>
  {
    begin_op();
    80004c66:	00000097          	auipc	ra,0x0
    80004c6a:	acc080e7          	jalr	-1332(ra) # 80004732 <begin_op>
    iput(ff.ip);
    80004c6e:	854e                	mv	a0,s3
    80004c70:	fffff097          	auipc	ra,0xfffff
    80004c74:	2b0080e7          	jalr	688(ra) # 80003f20 <iput>
    end_op();
    80004c78:	00000097          	auipc	ra,0x0
    80004c7c:	b38080e7          	jalr	-1224(ra) # 800047b0 <end_op>
    80004c80:	a00d                	j	80004ca2 <fileclose+0xa8>
    panic("fileclose");
    80004c82:	00004517          	auipc	a0,0x4
    80004c86:	b7650513          	addi	a0,a0,-1162 # 800087f8 <syscalls+0x260>
    80004c8a:	ffffc097          	auipc	ra,0xffffc
    80004c8e:	8b6080e7          	jalr	-1866(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004c92:	0023e517          	auipc	a0,0x23e
    80004c96:	24650513          	addi	a0,a0,582 # 80242ed8 <ftable>
    80004c9a:	ffffc097          	auipc	ra,0xffffc
    80004c9e:	164080e7          	jalr	356(ra) # 80000dfe <release>
  }
}
    80004ca2:	70e2                	ld	ra,56(sp)
    80004ca4:	7442                	ld	s0,48(sp)
    80004ca6:	74a2                	ld	s1,40(sp)
    80004ca8:	7902                	ld	s2,32(sp)
    80004caa:	69e2                	ld	s3,24(sp)
    80004cac:	6a42                	ld	s4,16(sp)
    80004cae:	6aa2                	ld	s5,8(sp)
    80004cb0:	6121                	addi	sp,sp,64
    80004cb2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004cb4:	85d6                	mv	a1,s5
    80004cb6:	8552                	mv	a0,s4
    80004cb8:	00000097          	auipc	ra,0x0
    80004cbc:	34c080e7          	jalr	844(ra) # 80005004 <pipeclose>
    80004cc0:	b7cd                	j	80004ca2 <fileclose+0xa8>

0000000080004cc2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80004cc2:	715d                	addi	sp,sp,-80
    80004cc4:	e486                	sd	ra,72(sp)
    80004cc6:	e0a2                	sd	s0,64(sp)
    80004cc8:	fc26                	sd	s1,56(sp)
    80004cca:	f84a                	sd	s2,48(sp)
    80004ccc:	f44e                	sd	s3,40(sp)
    80004cce:	0880                	addi	s0,sp,80
    80004cd0:	84aa                	mv	s1,a0
    80004cd2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004cd4:	ffffd097          	auipc	ra,0xffffd
    80004cd8:	e88080e7          	jalr	-376(ra) # 80001b5c <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004cdc:	409c                	lw	a5,0(s1)
    80004cde:	37f9                	addiw	a5,a5,-2
    80004ce0:	4705                	li	a4,1
    80004ce2:	04f76763          	bltu	a4,a5,80004d30 <filestat+0x6e>
    80004ce6:	892a                	mv	s2,a0
  {
    ilock(f->ip);
    80004ce8:	6c88                	ld	a0,24(s1)
    80004cea:	fffff097          	auipc	ra,0xfffff
    80004cee:	07c080e7          	jalr	124(ra) # 80003d66 <ilock>
    stati(f->ip, &st);
    80004cf2:	fb840593          	addi	a1,s0,-72
    80004cf6:	6c88                	ld	a0,24(s1)
    80004cf8:	fffff097          	auipc	ra,0xfffff
    80004cfc:	2f8080e7          	jalr	760(ra) # 80003ff0 <stati>
    iunlock(f->ip);
    80004d00:	6c88                	ld	a0,24(s1)
    80004d02:	fffff097          	auipc	ra,0xfffff
    80004d06:	126080e7          	jalr	294(ra) # 80003e28 <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d0a:	46e1                	li	a3,24
    80004d0c:	fb840613          	addi	a2,s0,-72
    80004d10:	85ce                	mv	a1,s3
    80004d12:	05093503          	ld	a0,80(s2)
    80004d16:	ffffd097          	auipc	ra,0xffffd
    80004d1a:	aca080e7          	jalr	-1334(ra) # 800017e0 <copyout>
    80004d1e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d22:	60a6                	ld	ra,72(sp)
    80004d24:	6406                	ld	s0,64(sp)
    80004d26:	74e2                	ld	s1,56(sp)
    80004d28:	7942                	ld	s2,48(sp)
    80004d2a:	79a2                	ld	s3,40(sp)
    80004d2c:	6161                	addi	sp,sp,80
    80004d2e:	8082                	ret
  return -1;
    80004d30:	557d                	li	a0,-1
    80004d32:	bfc5                	j	80004d22 <filestat+0x60>

0000000080004d34 <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    80004d34:	7179                	addi	sp,sp,-48
    80004d36:	f406                	sd	ra,40(sp)
    80004d38:	f022                	sd	s0,32(sp)
    80004d3a:	ec26                	sd	s1,24(sp)
    80004d3c:	e84a                	sd	s2,16(sp)
    80004d3e:	e44e                	sd	s3,8(sp)
    80004d40:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    80004d42:	00854783          	lbu	a5,8(a0)
    80004d46:	c3d5                	beqz	a5,80004dea <fileread+0xb6>
    80004d48:	84aa                	mv	s1,a0
    80004d4a:	89ae                	mv	s3,a1
    80004d4c:	8932                	mv	s2,a2
    return -1;

  if (f->type == FD_PIPE)
    80004d4e:	411c                	lw	a5,0(a0)
    80004d50:	4705                	li	a4,1
    80004d52:	04e78963          	beq	a5,a4,80004da4 <fileread+0x70>
  {
    r = piperead(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004d56:	470d                	li	a4,3
    80004d58:	04e78d63          	beq	a5,a4,80004db2 <fileread+0x7e>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004d5c:	4709                	li	a4,2
    80004d5e:	06e79e63          	bne	a5,a4,80004dda <fileread+0xa6>
  {
    ilock(f->ip);
    80004d62:	6d08                	ld	a0,24(a0)
    80004d64:	fffff097          	auipc	ra,0xfffff
    80004d68:	002080e7          	jalr	2(ra) # 80003d66 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d6c:	874a                	mv	a4,s2
    80004d6e:	5094                	lw	a3,32(s1)
    80004d70:	864e                	mv	a2,s3
    80004d72:	4585                	li	a1,1
    80004d74:	6c88                	ld	a0,24(s1)
    80004d76:	fffff097          	auipc	ra,0xfffff
    80004d7a:	2a4080e7          	jalr	676(ra) # 8000401a <readi>
    80004d7e:	892a                	mv	s2,a0
    80004d80:	00a05563          	blez	a0,80004d8a <fileread+0x56>
      f->off += r;
    80004d84:	509c                	lw	a5,32(s1)
    80004d86:	9fa9                	addw	a5,a5,a0
    80004d88:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d8a:	6c88                	ld	a0,24(s1)
    80004d8c:	fffff097          	auipc	ra,0xfffff
    80004d90:	09c080e7          	jalr	156(ra) # 80003e28 <iunlock>
  {
    panic("fileread");
  }

  return r;
}
    80004d94:	854a                	mv	a0,s2
    80004d96:	70a2                	ld	ra,40(sp)
    80004d98:	7402                	ld	s0,32(sp)
    80004d9a:	64e2                	ld	s1,24(sp)
    80004d9c:	6942                	ld	s2,16(sp)
    80004d9e:	69a2                	ld	s3,8(sp)
    80004da0:	6145                	addi	sp,sp,48
    80004da2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004da4:	6908                	ld	a0,16(a0)
    80004da6:	00000097          	auipc	ra,0x0
    80004daa:	3c6080e7          	jalr	966(ra) # 8000516c <piperead>
    80004dae:	892a                	mv	s2,a0
    80004db0:	b7d5                	j	80004d94 <fileread+0x60>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004db2:	02451783          	lh	a5,36(a0)
    80004db6:	03079693          	slli	a3,a5,0x30
    80004dba:	92c1                	srli	a3,a3,0x30
    80004dbc:	4725                	li	a4,9
    80004dbe:	02d76863          	bltu	a4,a3,80004dee <fileread+0xba>
    80004dc2:	0792                	slli	a5,a5,0x4
    80004dc4:	0023e717          	auipc	a4,0x23e
    80004dc8:	07470713          	addi	a4,a4,116 # 80242e38 <devsw>
    80004dcc:	97ba                	add	a5,a5,a4
    80004dce:	639c                	ld	a5,0(a5)
    80004dd0:	c38d                	beqz	a5,80004df2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004dd2:	4505                	li	a0,1
    80004dd4:	9782                	jalr	a5
    80004dd6:	892a                	mv	s2,a0
    80004dd8:	bf75                	j	80004d94 <fileread+0x60>
    panic("fileread");
    80004dda:	00004517          	auipc	a0,0x4
    80004dde:	a2e50513          	addi	a0,a0,-1490 # 80008808 <syscalls+0x270>
    80004de2:	ffffb097          	auipc	ra,0xffffb
    80004de6:	75e080e7          	jalr	1886(ra) # 80000540 <panic>
    return -1;
    80004dea:	597d                	li	s2,-1
    80004dec:	b765                	j	80004d94 <fileread+0x60>
      return -1;
    80004dee:	597d                	li	s2,-1
    80004df0:	b755                	j	80004d94 <fileread+0x60>
    80004df2:	597d                	li	s2,-1
    80004df4:	b745                	j	80004d94 <fileread+0x60>

0000000080004df6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    80004df6:	715d                	addi	sp,sp,-80
    80004df8:	e486                	sd	ra,72(sp)
    80004dfa:	e0a2                	sd	s0,64(sp)
    80004dfc:	fc26                	sd	s1,56(sp)
    80004dfe:	f84a                	sd	s2,48(sp)
    80004e00:	f44e                	sd	s3,40(sp)
    80004e02:	f052                	sd	s4,32(sp)
    80004e04:	ec56                	sd	s5,24(sp)
    80004e06:	e85a                	sd	s6,16(sp)
    80004e08:	e45e                	sd	s7,8(sp)
    80004e0a:	e062                	sd	s8,0(sp)
    80004e0c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if (f->writable == 0)
    80004e0e:	00954783          	lbu	a5,9(a0)
    80004e12:	10078663          	beqz	a5,80004f1e <filewrite+0x128>
    80004e16:	892a                	mv	s2,a0
    80004e18:	8b2e                	mv	s6,a1
    80004e1a:	8a32                	mv	s4,a2
    return -1;

  if (f->type == FD_PIPE)
    80004e1c:	411c                	lw	a5,0(a0)
    80004e1e:	4705                	li	a4,1
    80004e20:	02e78263          	beq	a5,a4,80004e44 <filewrite+0x4e>
  {
    ret = pipewrite(f->pipe, addr, n);
  }
  else if (f->type == FD_DEVICE)
    80004e24:	470d                	li	a4,3
    80004e26:	02e78663          	beq	a5,a4,80004e52 <filewrite+0x5c>
  {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  }
  else if (f->type == FD_INODE)
    80004e2a:	4709                	li	a4,2
    80004e2c:	0ee79163          	bne	a5,a4,80004f0e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n)
    80004e30:	0ac05d63          	blez	a2,80004eea <filewrite+0xf4>
    int i = 0;
    80004e34:	4981                	li	s3,0
    80004e36:	6b85                	lui	s7,0x1
    80004e38:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004e3c:	6c05                	lui	s8,0x1
    80004e3e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004e42:	a861                	j	80004eda <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004e44:	6908                	ld	a0,16(a0)
    80004e46:	00000097          	auipc	ra,0x0
    80004e4a:	22e080e7          	jalr	558(ra) # 80005074 <pipewrite>
    80004e4e:	8a2a                	mv	s4,a0
    80004e50:	a045                	j	80004ef0 <filewrite+0xfa>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e52:	02451783          	lh	a5,36(a0)
    80004e56:	03079693          	slli	a3,a5,0x30
    80004e5a:	92c1                	srli	a3,a3,0x30
    80004e5c:	4725                	li	a4,9
    80004e5e:	0cd76263          	bltu	a4,a3,80004f22 <filewrite+0x12c>
    80004e62:	0792                	slli	a5,a5,0x4
    80004e64:	0023e717          	auipc	a4,0x23e
    80004e68:	fd470713          	addi	a4,a4,-44 # 80242e38 <devsw>
    80004e6c:	97ba                	add	a5,a5,a4
    80004e6e:	679c                	ld	a5,8(a5)
    80004e70:	cbdd                	beqz	a5,80004f26 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e72:	4505                	li	a0,1
    80004e74:	9782                	jalr	a5
    80004e76:	8a2a                	mv	s4,a0
    80004e78:	a8a5                	j	80004ef0 <filewrite+0xfa>
    80004e7a:	00048a9b          	sext.w	s5,s1
    {
      int n1 = n - i;
      if (n1 > max)
        n1 = max;

      begin_op();
    80004e7e:	00000097          	auipc	ra,0x0
    80004e82:	8b4080e7          	jalr	-1868(ra) # 80004732 <begin_op>
      ilock(f->ip);
    80004e86:	01893503          	ld	a0,24(s2)
    80004e8a:	fffff097          	auipc	ra,0xfffff
    80004e8e:	edc080e7          	jalr	-292(ra) # 80003d66 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e92:	8756                	mv	a4,s5
    80004e94:	02092683          	lw	a3,32(s2)
    80004e98:	01698633          	add	a2,s3,s6
    80004e9c:	4585                	li	a1,1
    80004e9e:	01893503          	ld	a0,24(s2)
    80004ea2:	fffff097          	auipc	ra,0xfffff
    80004ea6:	270080e7          	jalr	624(ra) # 80004112 <writei>
    80004eaa:	84aa                	mv	s1,a0
    80004eac:	00a05763          	blez	a0,80004eba <filewrite+0xc4>
        f->off += r;
    80004eb0:	02092783          	lw	a5,32(s2)
    80004eb4:	9fa9                	addw	a5,a5,a0
    80004eb6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004eba:	01893503          	ld	a0,24(s2)
    80004ebe:	fffff097          	auipc	ra,0xfffff
    80004ec2:	f6a080e7          	jalr	-150(ra) # 80003e28 <iunlock>
      end_op();
    80004ec6:	00000097          	auipc	ra,0x0
    80004eca:	8ea080e7          	jalr	-1814(ra) # 800047b0 <end_op>

      if (r != n1)
    80004ece:	009a9f63          	bne	s5,s1,80004eec <filewrite+0xf6>
      {
        // error from writei
        break;
      }
      i += r;
    80004ed2:	013489bb          	addw	s3,s1,s3
    while (i < n)
    80004ed6:	0149db63          	bge	s3,s4,80004eec <filewrite+0xf6>
      int n1 = n - i;
    80004eda:	413a04bb          	subw	s1,s4,s3
    80004ede:	0004879b          	sext.w	a5,s1
    80004ee2:	f8fbdce3          	bge	s7,a5,80004e7a <filewrite+0x84>
    80004ee6:	84e2                	mv	s1,s8
    80004ee8:	bf49                	j	80004e7a <filewrite+0x84>
    int i = 0;
    80004eea:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004eec:	013a1f63          	bne	s4,s3,80004f0a <filewrite+0x114>
  {
    panic("filewrite");
  }

  return ret;
}
    80004ef0:	8552                	mv	a0,s4
    80004ef2:	60a6                	ld	ra,72(sp)
    80004ef4:	6406                	ld	s0,64(sp)
    80004ef6:	74e2                	ld	s1,56(sp)
    80004ef8:	7942                	ld	s2,48(sp)
    80004efa:	79a2                	ld	s3,40(sp)
    80004efc:	7a02                	ld	s4,32(sp)
    80004efe:	6ae2                	ld	s5,24(sp)
    80004f00:	6b42                	ld	s6,16(sp)
    80004f02:	6ba2                	ld	s7,8(sp)
    80004f04:	6c02                	ld	s8,0(sp)
    80004f06:	6161                	addi	sp,sp,80
    80004f08:	8082                	ret
    ret = (i == n ? n : -1);
    80004f0a:	5a7d                	li	s4,-1
    80004f0c:	b7d5                	j	80004ef0 <filewrite+0xfa>
    panic("filewrite");
    80004f0e:	00004517          	auipc	a0,0x4
    80004f12:	90a50513          	addi	a0,a0,-1782 # 80008818 <syscalls+0x280>
    80004f16:	ffffb097          	auipc	ra,0xffffb
    80004f1a:	62a080e7          	jalr	1578(ra) # 80000540 <panic>
    return -1;
    80004f1e:	5a7d                	li	s4,-1
    80004f20:	bfc1                	j	80004ef0 <filewrite+0xfa>
      return -1;
    80004f22:	5a7d                	li	s4,-1
    80004f24:	b7f1                	j	80004ef0 <filewrite+0xfa>
    80004f26:	5a7d                	li	s4,-1
    80004f28:	b7e1                	j	80004ef0 <filewrite+0xfa>

0000000080004f2a <pipealloc>:
  int readopen;  // read fd is still open
  int writeopen; // write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
    80004f2a:	7179                	addi	sp,sp,-48
    80004f2c:	f406                	sd	ra,40(sp)
    80004f2e:	f022                	sd	s0,32(sp)
    80004f30:	ec26                	sd	s1,24(sp)
    80004f32:	e84a                	sd	s2,16(sp)
    80004f34:	e44e                	sd	s3,8(sp)
    80004f36:	e052                	sd	s4,0(sp)
    80004f38:	1800                	addi	s0,sp,48
    80004f3a:	84aa                	mv	s1,a0
    80004f3c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f3e:	0005b023          	sd	zero,0(a1)
    80004f42:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f46:	00000097          	auipc	ra,0x0
    80004f4a:	bf8080e7          	jalr	-1032(ra) # 80004b3e <filealloc>
    80004f4e:	e088                	sd	a0,0(s1)
    80004f50:	c551                	beqz	a0,80004fdc <pipealloc+0xb2>
    80004f52:	00000097          	auipc	ra,0x0
    80004f56:	bec080e7          	jalr	-1044(ra) # 80004b3e <filealloc>
    80004f5a:	00aa3023          	sd	a0,0(s4)
    80004f5e:	c92d                	beqz	a0,80004fd0 <pipealloc+0xa6>
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004f60:	ffffc097          	auipc	ra,0xffffc
    80004f64:	cf0080e7          	jalr	-784(ra) # 80000c50 <kalloc>
    80004f68:	892a                	mv	s2,a0
    80004f6a:	c125                	beqz	a0,80004fca <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f6c:	4985                	li	s3,1
    80004f6e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f72:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f76:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f7a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f7e:	00003597          	auipc	a1,0x3
    80004f82:	55258593          	addi	a1,a1,1362 # 800084d0 <states.0+0x1c0>
    80004f86:	ffffc097          	auipc	ra,0xffffc
    80004f8a:	d34080e7          	jalr	-716(ra) # 80000cba <initlock>
  (*f0)->type = FD_PIPE;
    80004f8e:	609c                	ld	a5,0(s1)
    80004f90:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f94:	609c                	ld	a5,0(s1)
    80004f96:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f9a:	609c                	ld	a5,0(s1)
    80004f9c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004fa0:	609c                	ld	a5,0(s1)
    80004fa2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004fa6:	000a3783          	ld	a5,0(s4)
    80004faa:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004fae:	000a3783          	ld	a5,0(s4)
    80004fb2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004fb6:	000a3783          	ld	a5,0(s4)
    80004fba:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004fbe:	000a3783          	ld	a5,0(s4)
    80004fc2:	0127b823          	sd	s2,16(a5)
  return 0;
    80004fc6:	4501                	li	a0,0
    80004fc8:	a025                	j	80004ff0 <pipealloc+0xc6>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004fca:	6088                	ld	a0,0(s1)
    80004fcc:	e501                	bnez	a0,80004fd4 <pipealloc+0xaa>
    80004fce:	a039                	j	80004fdc <pipealloc+0xb2>
    80004fd0:	6088                	ld	a0,0(s1)
    80004fd2:	c51d                	beqz	a0,80005000 <pipealloc+0xd6>
    fileclose(*f0);
    80004fd4:	00000097          	auipc	ra,0x0
    80004fd8:	c26080e7          	jalr	-986(ra) # 80004bfa <fileclose>
  if (*f1)
    80004fdc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004fe0:	557d                	li	a0,-1
  if (*f1)
    80004fe2:	c799                	beqz	a5,80004ff0 <pipealloc+0xc6>
    fileclose(*f1);
    80004fe4:	853e                	mv	a0,a5
    80004fe6:	00000097          	auipc	ra,0x0
    80004fea:	c14080e7          	jalr	-1004(ra) # 80004bfa <fileclose>
  return -1;
    80004fee:	557d                	li	a0,-1
}
    80004ff0:	70a2                	ld	ra,40(sp)
    80004ff2:	7402                	ld	s0,32(sp)
    80004ff4:	64e2                	ld	s1,24(sp)
    80004ff6:	6942                	ld	s2,16(sp)
    80004ff8:	69a2                	ld	s3,8(sp)
    80004ffa:	6a02                	ld	s4,0(sp)
    80004ffc:	6145                	addi	sp,sp,48
    80004ffe:	8082                	ret
  return -1;
    80005000:	557d                	li	a0,-1
    80005002:	b7fd                	j	80004ff0 <pipealloc+0xc6>

0000000080005004 <pipeclose>:

void pipeclose(struct pipe *pi, int writable)
{
    80005004:	1101                	addi	sp,sp,-32
    80005006:	ec06                	sd	ra,24(sp)
    80005008:	e822                	sd	s0,16(sp)
    8000500a:	e426                	sd	s1,8(sp)
    8000500c:	e04a                	sd	s2,0(sp)
    8000500e:	1000                	addi	s0,sp,32
    80005010:	84aa                	mv	s1,a0
    80005012:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005014:	ffffc097          	auipc	ra,0xffffc
    80005018:	d36080e7          	jalr	-714(ra) # 80000d4a <acquire>
  if (writable)
    8000501c:	02090d63          	beqz	s2,80005056 <pipeclose+0x52>
  {
    pi->writeopen = 0;
    80005020:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005024:	21848513          	addi	a0,s1,536
    80005028:	ffffd097          	auipc	ra,0xffffd
    8000502c:	48e080e7          	jalr	1166(ra) # 800024b6 <wakeup>
  else
  {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0)
    80005030:	2204b783          	ld	a5,544(s1)
    80005034:	eb95                	bnez	a5,80005068 <pipeclose+0x64>
  {
    release(&pi->lock);
    80005036:	8526                	mv	a0,s1
    80005038:	ffffc097          	auipc	ra,0xffffc
    8000503c:	dc6080e7          	jalr	-570(ra) # 80000dfe <release>
    kfree((char *)pi);
    80005040:	8526                	mv	a0,s1
    80005042:	ffffc097          	auipc	ra,0xffffc
    80005046:	a36080e7          	jalr	-1482(ra) # 80000a78 <kfree>
  }
  else
    release(&pi->lock);
}
    8000504a:	60e2                	ld	ra,24(sp)
    8000504c:	6442                	ld	s0,16(sp)
    8000504e:	64a2                	ld	s1,8(sp)
    80005050:	6902                	ld	s2,0(sp)
    80005052:	6105                	addi	sp,sp,32
    80005054:	8082                	ret
    pi->readopen = 0;
    80005056:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000505a:	21c48513          	addi	a0,s1,540
    8000505e:	ffffd097          	auipc	ra,0xffffd
    80005062:	458080e7          	jalr	1112(ra) # 800024b6 <wakeup>
    80005066:	b7e9                	j	80005030 <pipeclose+0x2c>
    release(&pi->lock);
    80005068:	8526                	mv	a0,s1
    8000506a:	ffffc097          	auipc	ra,0xffffc
    8000506e:	d94080e7          	jalr	-620(ra) # 80000dfe <release>
}
    80005072:	bfe1                	j	8000504a <pipeclose+0x46>

0000000080005074 <pipewrite>:

int pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005074:	711d                	addi	sp,sp,-96
    80005076:	ec86                	sd	ra,88(sp)
    80005078:	e8a2                	sd	s0,80(sp)
    8000507a:	e4a6                	sd	s1,72(sp)
    8000507c:	e0ca                	sd	s2,64(sp)
    8000507e:	fc4e                	sd	s3,56(sp)
    80005080:	f852                	sd	s4,48(sp)
    80005082:	f456                	sd	s5,40(sp)
    80005084:	f05a                	sd	s6,32(sp)
    80005086:	ec5e                	sd	s7,24(sp)
    80005088:	e862                	sd	s8,16(sp)
    8000508a:	1080                	addi	s0,sp,96
    8000508c:	84aa                	mv	s1,a0
    8000508e:	8aae                	mv	s5,a1
    80005090:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005092:	ffffd097          	auipc	ra,0xffffd
    80005096:	aca080e7          	jalr	-1334(ra) # 80001b5c <myproc>
    8000509a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000509c:	8526                	mv	a0,s1
    8000509e:	ffffc097          	auipc	ra,0xffffc
    800050a2:	cac080e7          	jalr	-852(ra) # 80000d4a <acquire>
  while (i < n)
    800050a6:	0b405663          	blez	s4,80005152 <pipewrite+0xde>
  int i = 0;
    800050aa:	4901                	li	s2,0
      sleep(&pi->nwrite, &pi->lock);
    }
    else
    {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050ac:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800050ae:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800050b2:	21c48b93          	addi	s7,s1,540
    800050b6:	a089                	j	800050f8 <pipewrite+0x84>
      release(&pi->lock);
    800050b8:	8526                	mv	a0,s1
    800050ba:	ffffc097          	auipc	ra,0xffffc
    800050be:	d44080e7          	jalr	-700(ra) # 80000dfe <release>
      return -1;
    800050c2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800050c4:	854a                	mv	a0,s2
    800050c6:	60e6                	ld	ra,88(sp)
    800050c8:	6446                	ld	s0,80(sp)
    800050ca:	64a6                	ld	s1,72(sp)
    800050cc:	6906                	ld	s2,64(sp)
    800050ce:	79e2                	ld	s3,56(sp)
    800050d0:	7a42                	ld	s4,48(sp)
    800050d2:	7aa2                	ld	s5,40(sp)
    800050d4:	7b02                	ld	s6,32(sp)
    800050d6:	6be2                	ld	s7,24(sp)
    800050d8:	6c42                	ld	s8,16(sp)
    800050da:	6125                	addi	sp,sp,96
    800050dc:	8082                	ret
      wakeup(&pi->nread);
    800050de:	8562                	mv	a0,s8
    800050e0:	ffffd097          	auipc	ra,0xffffd
    800050e4:	3d6080e7          	jalr	982(ra) # 800024b6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050e8:	85a6                	mv	a1,s1
    800050ea:	855e                	mv	a0,s7
    800050ec:	ffffd097          	auipc	ra,0xffffd
    800050f0:	20e080e7          	jalr	526(ra) # 800022fa <sleep>
  while (i < n)
    800050f4:	07495063          	bge	s2,s4,80005154 <pipewrite+0xe0>
    if (pi->readopen == 0 || killed(pr))
    800050f8:	2204a783          	lw	a5,544(s1)
    800050fc:	dfd5                	beqz	a5,800050b8 <pipewrite+0x44>
    800050fe:	854e                	mv	a0,s3
    80005100:	ffffd097          	auipc	ra,0xffffd
    80005104:	626080e7          	jalr	1574(ra) # 80002726 <killed>
    80005108:	f945                	bnez	a0,800050b8 <pipewrite+0x44>
    if (pi->nwrite == pi->nread + PIPESIZE)
    8000510a:	2184a783          	lw	a5,536(s1)
    8000510e:	21c4a703          	lw	a4,540(s1)
    80005112:	2007879b          	addiw	a5,a5,512
    80005116:	fcf704e3          	beq	a4,a5,800050de <pipewrite+0x6a>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000511a:	4685                	li	a3,1
    8000511c:	01590633          	add	a2,s2,s5
    80005120:	faf40593          	addi	a1,s0,-81
    80005124:	0509b503          	ld	a0,80(s3)
    80005128:	ffffc097          	auipc	ra,0xffffc
    8000512c:	780080e7          	jalr	1920(ra) # 800018a8 <copyin>
    80005130:	03650263          	beq	a0,s6,80005154 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005134:	21c4a783          	lw	a5,540(s1)
    80005138:	0017871b          	addiw	a4,a5,1
    8000513c:	20e4ae23          	sw	a4,540(s1)
    80005140:	1ff7f793          	andi	a5,a5,511
    80005144:	97a6                	add	a5,a5,s1
    80005146:	faf44703          	lbu	a4,-81(s0)
    8000514a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000514e:	2905                	addiw	s2,s2,1
    80005150:	b755                	j	800050f4 <pipewrite+0x80>
  int i = 0;
    80005152:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005154:	21848513          	addi	a0,s1,536
    80005158:	ffffd097          	auipc	ra,0xffffd
    8000515c:	35e080e7          	jalr	862(ra) # 800024b6 <wakeup>
  release(&pi->lock);
    80005160:	8526                	mv	a0,s1
    80005162:	ffffc097          	auipc	ra,0xffffc
    80005166:	c9c080e7          	jalr	-868(ra) # 80000dfe <release>
  return i;
    8000516a:	bfa9                	j	800050c4 <pipewrite+0x50>

000000008000516c <piperead>:

int piperead(struct pipe *pi, uint64 addr, int n)
{
    8000516c:	715d                	addi	sp,sp,-80
    8000516e:	e486                	sd	ra,72(sp)
    80005170:	e0a2                	sd	s0,64(sp)
    80005172:	fc26                	sd	s1,56(sp)
    80005174:	f84a                	sd	s2,48(sp)
    80005176:	f44e                	sd	s3,40(sp)
    80005178:	f052                	sd	s4,32(sp)
    8000517a:	ec56                	sd	s5,24(sp)
    8000517c:	e85a                	sd	s6,16(sp)
    8000517e:	0880                	addi	s0,sp,80
    80005180:	84aa                	mv	s1,a0
    80005182:	892e                	mv	s2,a1
    80005184:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005186:	ffffd097          	auipc	ra,0xffffd
    8000518a:	9d6080e7          	jalr	-1578(ra) # 80001b5c <myproc>
    8000518e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005190:	8526                	mv	a0,s1
    80005192:	ffffc097          	auipc	ra,0xffffc
    80005196:	bb8080e7          	jalr	-1096(ra) # 80000d4a <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen)
    8000519a:	2184a703          	lw	a4,536(s1)
    8000519e:	21c4a783          	lw	a5,540(s1)
    if (killed(pr))
    {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    800051a2:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen)
    800051a6:	02f71763          	bne	a4,a5,800051d4 <piperead+0x68>
    800051aa:	2244a783          	lw	a5,548(s1)
    800051ae:	c39d                	beqz	a5,800051d4 <piperead+0x68>
    if (killed(pr))
    800051b0:	8552                	mv	a0,s4
    800051b2:	ffffd097          	auipc	ra,0xffffd
    800051b6:	574080e7          	jalr	1396(ra) # 80002726 <killed>
    800051ba:	e949                	bnez	a0,8000524c <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); // DOC: piperead-sleep
    800051bc:	85a6                	mv	a1,s1
    800051be:	854e                	mv	a0,s3
    800051c0:	ffffd097          	auipc	ra,0xffffd
    800051c4:	13a080e7          	jalr	314(ra) # 800022fa <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen)
    800051c8:	2184a703          	lw	a4,536(s1)
    800051cc:	21c4a783          	lw	a5,540(s1)
    800051d0:	fcf70de3          	beq	a4,a5,800051aa <piperead+0x3e>
  }
  for (i = 0; i < n; i++)
    800051d4:	4981                	li	s3,0
  { // DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051d6:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++)
    800051d8:	05505463          	blez	s5,80005220 <piperead+0xb4>
    if (pi->nread == pi->nwrite)
    800051dc:	2184a783          	lw	a5,536(s1)
    800051e0:	21c4a703          	lw	a4,540(s1)
    800051e4:	02f70e63          	beq	a4,a5,80005220 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800051e8:	0017871b          	addiw	a4,a5,1
    800051ec:	20e4ac23          	sw	a4,536(s1)
    800051f0:	1ff7f793          	andi	a5,a5,511
    800051f4:	97a6                	add	a5,a5,s1
    800051f6:	0187c783          	lbu	a5,24(a5)
    800051fa:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051fe:	4685                	li	a3,1
    80005200:	fbf40613          	addi	a2,s0,-65
    80005204:	85ca                	mv	a1,s2
    80005206:	050a3503          	ld	a0,80(s4)
    8000520a:	ffffc097          	auipc	ra,0xffffc
    8000520e:	5d6080e7          	jalr	1494(ra) # 800017e0 <copyout>
    80005212:	01650763          	beq	a0,s6,80005220 <piperead+0xb4>
  for (i = 0; i < n; i++)
    80005216:	2985                	addiw	s3,s3,1
    80005218:	0905                	addi	s2,s2,1
    8000521a:	fd3a91e3          	bne	s5,s3,800051dc <piperead+0x70>
    8000521e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite); // DOC: piperead-wakeup
    80005220:	21c48513          	addi	a0,s1,540
    80005224:	ffffd097          	auipc	ra,0xffffd
    80005228:	292080e7          	jalr	658(ra) # 800024b6 <wakeup>
  release(&pi->lock);
    8000522c:	8526                	mv	a0,s1
    8000522e:	ffffc097          	auipc	ra,0xffffc
    80005232:	bd0080e7          	jalr	-1072(ra) # 80000dfe <release>
  return i;
}
    80005236:	854e                	mv	a0,s3
    80005238:	60a6                	ld	ra,72(sp)
    8000523a:	6406                	ld	s0,64(sp)
    8000523c:	74e2                	ld	s1,56(sp)
    8000523e:	7942                	ld	s2,48(sp)
    80005240:	79a2                	ld	s3,40(sp)
    80005242:	7a02                	ld	s4,32(sp)
    80005244:	6ae2                	ld	s5,24(sp)
    80005246:	6b42                	ld	s6,16(sp)
    80005248:	6161                	addi	sp,sp,80
    8000524a:	8082                	ret
      release(&pi->lock);
    8000524c:	8526                	mv	a0,s1
    8000524e:	ffffc097          	auipc	ra,0xffffc
    80005252:	bb0080e7          	jalr	-1104(ra) # 80000dfe <release>
      return -1;
    80005256:	59fd                	li	s3,-1
    80005258:	bff9                	j	80005236 <piperead+0xca>

000000008000525a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000525a:	1141                	addi	sp,sp,-16
    8000525c:	e422                	sd	s0,8(sp)
    8000525e:	0800                	addi	s0,sp,16
    80005260:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80005262:	8905                	andi	a0,a0,1
    80005264:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80005266:	8b89                	andi	a5,a5,2
    80005268:	c399                	beqz	a5,8000526e <flags2perm+0x14>
    perm |= PTE_W;
    8000526a:	00456513          	ori	a0,a0,4
  return perm;
}
    8000526e:	6422                	ld	s0,8(sp)
    80005270:	0141                	addi	sp,sp,16
    80005272:	8082                	ret

0000000080005274 <exec>:

int exec(char *path, char **argv)
{
    80005274:	de010113          	addi	sp,sp,-544
    80005278:	20113c23          	sd	ra,536(sp)
    8000527c:	20813823          	sd	s0,528(sp)
    80005280:	20913423          	sd	s1,520(sp)
    80005284:	21213023          	sd	s2,512(sp)
    80005288:	ffce                	sd	s3,504(sp)
    8000528a:	fbd2                	sd	s4,496(sp)
    8000528c:	f7d6                	sd	s5,488(sp)
    8000528e:	f3da                	sd	s6,480(sp)
    80005290:	efde                	sd	s7,472(sp)
    80005292:	ebe2                	sd	s8,464(sp)
    80005294:	e7e6                	sd	s9,456(sp)
    80005296:	e3ea                	sd	s10,448(sp)
    80005298:	ff6e                	sd	s11,440(sp)
    8000529a:	1400                	addi	s0,sp,544
    8000529c:	892a                	mv	s2,a0
    8000529e:	dea43423          	sd	a0,-536(s0)
    800052a2:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800052a6:	ffffd097          	auipc	ra,0xffffd
    800052aa:	8b6080e7          	jalr	-1866(ra) # 80001b5c <myproc>
    800052ae:	84aa                	mv	s1,a0

  begin_op();
    800052b0:	fffff097          	auipc	ra,0xfffff
    800052b4:	482080e7          	jalr	1154(ra) # 80004732 <begin_op>

  if ((ip = namei(path)) == 0)
    800052b8:	854a                	mv	a0,s2
    800052ba:	fffff097          	auipc	ra,0xfffff
    800052be:	258080e7          	jalr	600(ra) # 80004512 <namei>
    800052c2:	c93d                	beqz	a0,80005338 <exec+0xc4>
    800052c4:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    800052c6:	fffff097          	auipc	ra,0xfffff
    800052ca:	aa0080e7          	jalr	-1376(ra) # 80003d66 <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800052ce:	04000713          	li	a4,64
    800052d2:	4681                	li	a3,0
    800052d4:	e5040613          	addi	a2,s0,-432
    800052d8:	4581                	li	a1,0
    800052da:	8556                	mv	a0,s5
    800052dc:	fffff097          	auipc	ra,0xfffff
    800052e0:	d3e080e7          	jalr	-706(ra) # 8000401a <readi>
    800052e4:	04000793          	li	a5,64
    800052e8:	00f51a63          	bne	a0,a5,800052fc <exec+0x88>
    goto bad;

  if (elf.magic != ELF_MAGIC)
    800052ec:	e5042703          	lw	a4,-432(s0)
    800052f0:	464c47b7          	lui	a5,0x464c4
    800052f4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052f8:	04f70663          	beq	a4,a5,80005344 <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    800052fc:	8556                	mv	a0,s5
    800052fe:	fffff097          	auipc	ra,0xfffff
    80005302:	cca080e7          	jalr	-822(ra) # 80003fc8 <iunlockput>
    end_op();
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	4aa080e7          	jalr	1194(ra) # 800047b0 <end_op>
  }
  return -1;
    8000530e:	557d                	li	a0,-1
}
    80005310:	21813083          	ld	ra,536(sp)
    80005314:	21013403          	ld	s0,528(sp)
    80005318:	20813483          	ld	s1,520(sp)
    8000531c:	20013903          	ld	s2,512(sp)
    80005320:	79fe                	ld	s3,504(sp)
    80005322:	7a5e                	ld	s4,496(sp)
    80005324:	7abe                	ld	s5,488(sp)
    80005326:	7b1e                	ld	s6,480(sp)
    80005328:	6bfe                	ld	s7,472(sp)
    8000532a:	6c5e                	ld	s8,464(sp)
    8000532c:	6cbe                	ld	s9,456(sp)
    8000532e:	6d1e                	ld	s10,448(sp)
    80005330:	7dfa                	ld	s11,440(sp)
    80005332:	22010113          	addi	sp,sp,544
    80005336:	8082                	ret
    end_op();
    80005338:	fffff097          	auipc	ra,0xfffff
    8000533c:	478080e7          	jalr	1144(ra) # 800047b0 <end_op>
    return -1;
    80005340:	557d                	li	a0,-1
    80005342:	b7f9                	j	80005310 <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    80005344:	8526                	mv	a0,s1
    80005346:	ffffd097          	auipc	ra,0xffffd
    8000534a:	8da080e7          	jalr	-1830(ra) # 80001c20 <proc_pagetable>
    8000534e:	8b2a                	mv	s6,a0
    80005350:	d555                	beqz	a0,800052fc <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005352:	e7042783          	lw	a5,-400(s0)
    80005356:	e8845703          	lhu	a4,-376(s0)
    8000535a:	c735                	beqz	a4,800053c6 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000535c:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    8000535e:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    80005362:	6a05                	lui	s4,0x1
    80005364:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005368:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for (i = 0; i < sz; i += PGSIZE)
    8000536c:	6d85                	lui	s11,0x1
    8000536e:	7d7d                	lui	s10,0xfffff
    80005370:	ac3d                	j	800055ae <exec+0x33a>
  {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    80005372:	00003517          	auipc	a0,0x3
    80005376:	4b650513          	addi	a0,a0,1206 # 80008828 <syscalls+0x290>
    8000537a:	ffffb097          	auipc	ra,0xffffb
    8000537e:	1c6080e7          	jalr	454(ra) # 80000540 <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80005382:	874a                	mv	a4,s2
    80005384:	009c86bb          	addw	a3,s9,s1
    80005388:	4581                	li	a1,0
    8000538a:	8556                	mv	a0,s5
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	c8e080e7          	jalr	-882(ra) # 8000401a <readi>
    80005394:	2501                	sext.w	a0,a0
    80005396:	1aa91963          	bne	s2,a0,80005548 <exec+0x2d4>
  for (i = 0; i < sz; i += PGSIZE)
    8000539a:	009d84bb          	addw	s1,s11,s1
    8000539e:	013d09bb          	addw	s3,s10,s3
    800053a2:	1f74f663          	bgeu	s1,s7,8000558e <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    800053a6:	02049593          	slli	a1,s1,0x20
    800053aa:	9181                	srli	a1,a1,0x20
    800053ac:	95e2                	add	a1,a1,s8
    800053ae:	855a                	mv	a0,s6
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	e20080e7          	jalr	-480(ra) # 800011d0 <walkaddr>
    800053b8:	862a                	mv	a2,a0
    if (pa == 0)
    800053ba:	dd45                	beqz	a0,80005372 <exec+0xfe>
      n = PGSIZE;
    800053bc:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    800053be:	fd49f2e3          	bgeu	s3,s4,80005382 <exec+0x10e>
      n = sz - i;
    800053c2:	894e                	mv	s2,s3
    800053c4:	bf7d                	j	80005382 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053c6:	4901                	li	s2,0
  iunlockput(ip);
    800053c8:	8556                	mv	a0,s5
    800053ca:	fffff097          	auipc	ra,0xfffff
    800053ce:	bfe080e7          	jalr	-1026(ra) # 80003fc8 <iunlockput>
  end_op();
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	3de080e7          	jalr	990(ra) # 800047b0 <end_op>
  p = myproc();
    800053da:	ffffc097          	auipc	ra,0xffffc
    800053de:	782080e7          	jalr	1922(ra) # 80001b5c <myproc>
    800053e2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800053e4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800053e8:	6785                	lui	a5,0x1
    800053ea:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800053ec:	97ca                	add	a5,a5,s2
    800053ee:	777d                	lui	a4,0xfffff
    800053f0:	8ff9                	and	a5,a5,a4
    800053f2:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    800053f6:	4691                	li	a3,4
    800053f8:	6609                	lui	a2,0x2
    800053fa:	963e                	add	a2,a2,a5
    800053fc:	85be                	mv	a1,a5
    800053fe:	855a                	mv	a0,s6
    80005400:	ffffc097          	auipc	ra,0xffffc
    80005404:	184080e7          	jalr	388(ra) # 80001584 <uvmalloc>
    80005408:	8c2a                	mv	s8,a0
  ip = 0;
    8000540a:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE, PTE_W)) == 0)
    8000540c:	12050e63          	beqz	a0,80005548 <exec+0x2d4>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005410:	75f9                	lui	a1,0xffffe
    80005412:	95aa                	add	a1,a1,a0
    80005414:	855a                	mv	a0,s6
    80005416:	ffffc097          	auipc	ra,0xffffc
    8000541a:	398080e7          	jalr	920(ra) # 800017ae <uvmclear>
  stackbase = sp - PGSIZE;
    8000541e:	7afd                	lui	s5,0xfffff
    80005420:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    80005422:	df043783          	ld	a5,-528(s0)
    80005426:	6388                	ld	a0,0(a5)
    80005428:	c925                	beqz	a0,80005498 <exec+0x224>
    8000542a:	e9040993          	addi	s3,s0,-368
    8000542e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005432:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005434:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005436:	ffffc097          	auipc	ra,0xffffc
    8000543a:	b8c080e7          	jalr	-1140(ra) # 80000fc2 <strlen>
    8000543e:	0015079b          	addiw	a5,a0,1
    80005442:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005446:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    8000544a:	13596663          	bltu	s2,s5,80005576 <exec+0x302>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000544e:	df043d83          	ld	s11,-528(s0)
    80005452:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005456:	8552                	mv	a0,s4
    80005458:	ffffc097          	auipc	ra,0xffffc
    8000545c:	b6a080e7          	jalr	-1174(ra) # 80000fc2 <strlen>
    80005460:	0015069b          	addiw	a3,a0,1
    80005464:	8652                	mv	a2,s4
    80005466:	85ca                	mv	a1,s2
    80005468:	855a                	mv	a0,s6
    8000546a:	ffffc097          	auipc	ra,0xffffc
    8000546e:	376080e7          	jalr	886(ra) # 800017e0 <copyout>
    80005472:	10054663          	bltz	a0,8000557e <exec+0x30a>
    ustack[argc] = sp;
    80005476:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    8000547a:	0485                	addi	s1,s1,1
    8000547c:	008d8793          	addi	a5,s11,8
    80005480:	def43823          	sd	a5,-528(s0)
    80005484:	008db503          	ld	a0,8(s11)
    80005488:	c911                	beqz	a0,8000549c <exec+0x228>
    if (argc >= MAXARG)
    8000548a:	09a1                	addi	s3,s3,8
    8000548c:	fb3c95e3          	bne	s9,s3,80005436 <exec+0x1c2>
  sz = sz1;
    80005490:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005494:	4a81                	li	s5,0
    80005496:	a84d                	j	80005548 <exec+0x2d4>
  sp = sz;
    80005498:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    8000549a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000549c:	00349793          	slli	a5,s1,0x3
    800054a0:	f9078793          	addi	a5,a5,-112
    800054a4:	97a2                	add	a5,a5,s0
    800054a6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    800054aa:	00148693          	addi	a3,s1,1
    800054ae:	068e                	slli	a3,a3,0x3
    800054b0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800054b4:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    800054b8:	01597663          	bgeu	s2,s5,800054c4 <exec+0x250>
  sz = sz1;
    800054bc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054c0:	4a81                	li	s5,0
    800054c2:	a059                	j	80005548 <exec+0x2d4>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    800054c4:	e9040613          	addi	a2,s0,-368
    800054c8:	85ca                	mv	a1,s2
    800054ca:	855a                	mv	a0,s6
    800054cc:	ffffc097          	auipc	ra,0xffffc
    800054d0:	314080e7          	jalr	788(ra) # 800017e0 <copyout>
    800054d4:	0a054963          	bltz	a0,80005586 <exec+0x312>
  p->trapframe->a1 = sp;
    800054d8:	058bb783          	ld	a5,88(s7)
    800054dc:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    800054e0:	de843783          	ld	a5,-536(s0)
    800054e4:	0007c703          	lbu	a4,0(a5)
    800054e8:	cf11                	beqz	a4,80005504 <exec+0x290>
    800054ea:	0785                	addi	a5,a5,1
    if (*s == '/')
    800054ec:	02f00693          	li	a3,47
    800054f0:	a039                	j	800054fe <exec+0x28a>
      last = s + 1;
    800054f2:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    800054f6:	0785                	addi	a5,a5,1
    800054f8:	fff7c703          	lbu	a4,-1(a5)
    800054fc:	c701                	beqz	a4,80005504 <exec+0x290>
    if (*s == '/')
    800054fe:	fed71ce3          	bne	a4,a3,800054f6 <exec+0x282>
    80005502:	bfc5                	j	800054f2 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005504:	4641                	li	a2,16
    80005506:	de843583          	ld	a1,-536(s0)
    8000550a:	158b8513          	addi	a0,s7,344
    8000550e:	ffffc097          	auipc	ra,0xffffc
    80005512:	a82080e7          	jalr	-1406(ra) # 80000f90 <safestrcpy>
  oldpagetable = p->pagetable;
    80005516:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000551a:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000551e:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    80005522:	058bb783          	ld	a5,88(s7)
    80005526:	e6843703          	ld	a4,-408(s0)
    8000552a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    8000552c:	058bb783          	ld	a5,88(s7)
    80005530:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005534:	85ea                	mv	a1,s10
    80005536:	ffffc097          	auipc	ra,0xffffc
    8000553a:	786080e7          	jalr	1926(ra) # 80001cbc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000553e:	0004851b          	sext.w	a0,s1
    80005542:	b3f9                	j	80005310 <exec+0x9c>
    80005544:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005548:	df843583          	ld	a1,-520(s0)
    8000554c:	855a                	mv	a0,s6
    8000554e:	ffffc097          	auipc	ra,0xffffc
    80005552:	76e080e7          	jalr	1902(ra) # 80001cbc <proc_freepagetable>
  if (ip)
    80005556:	da0a93e3          	bnez	s5,800052fc <exec+0x88>
  return -1;
    8000555a:	557d                	li	a0,-1
    8000555c:	bb55                	j	80005310 <exec+0x9c>
    8000555e:	df243c23          	sd	s2,-520(s0)
    80005562:	b7dd                	j	80005548 <exec+0x2d4>
    80005564:	df243c23          	sd	s2,-520(s0)
    80005568:	b7c5                	j	80005548 <exec+0x2d4>
    8000556a:	df243c23          	sd	s2,-520(s0)
    8000556e:	bfe9                	j	80005548 <exec+0x2d4>
    80005570:	df243c23          	sd	s2,-520(s0)
    80005574:	bfd1                	j	80005548 <exec+0x2d4>
  sz = sz1;
    80005576:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000557a:	4a81                	li	s5,0
    8000557c:	b7f1                	j	80005548 <exec+0x2d4>
  sz = sz1;
    8000557e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005582:	4a81                	li	s5,0
    80005584:	b7d1                	j	80005548 <exec+0x2d4>
  sz = sz1;
    80005586:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000558a:	4a81                	li	s5,0
    8000558c:	bf75                	j	80005548 <exec+0x2d4>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000558e:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005592:	e0843783          	ld	a5,-504(s0)
    80005596:	0017869b          	addiw	a3,a5,1
    8000559a:	e0d43423          	sd	a3,-504(s0)
    8000559e:	e0043783          	ld	a5,-512(s0)
    800055a2:	0387879b          	addiw	a5,a5,56
    800055a6:	e8845703          	lhu	a4,-376(s0)
    800055aa:	e0e6dfe3          	bge	a3,a4,800053c8 <exec+0x154>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800055ae:	2781                	sext.w	a5,a5
    800055b0:	e0f43023          	sd	a5,-512(s0)
    800055b4:	03800713          	li	a4,56
    800055b8:	86be                	mv	a3,a5
    800055ba:	e1840613          	addi	a2,s0,-488
    800055be:	4581                	li	a1,0
    800055c0:	8556                	mv	a0,s5
    800055c2:	fffff097          	auipc	ra,0xfffff
    800055c6:	a58080e7          	jalr	-1448(ra) # 8000401a <readi>
    800055ca:	03800793          	li	a5,56
    800055ce:	f6f51be3          	bne	a0,a5,80005544 <exec+0x2d0>
    if (ph.type != ELF_PROG_LOAD)
    800055d2:	e1842783          	lw	a5,-488(s0)
    800055d6:	4705                	li	a4,1
    800055d8:	fae79de3          	bne	a5,a4,80005592 <exec+0x31e>
    if (ph.memsz < ph.filesz)
    800055dc:	e4043483          	ld	s1,-448(s0)
    800055e0:	e3843783          	ld	a5,-456(s0)
    800055e4:	f6f4ede3          	bltu	s1,a5,8000555e <exec+0x2ea>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    800055e8:	e2843783          	ld	a5,-472(s0)
    800055ec:	94be                	add	s1,s1,a5
    800055ee:	f6f4ebe3          	bltu	s1,a5,80005564 <exec+0x2f0>
    if (ph.vaddr % PGSIZE != 0)
    800055f2:	de043703          	ld	a4,-544(s0)
    800055f6:	8ff9                	and	a5,a5,a4
    800055f8:	fbad                	bnez	a5,8000556a <exec+0x2f6>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055fa:	e1c42503          	lw	a0,-484(s0)
    800055fe:	00000097          	auipc	ra,0x0
    80005602:	c5c080e7          	jalr	-932(ra) # 8000525a <flags2perm>
    80005606:	86aa                	mv	a3,a0
    80005608:	8626                	mv	a2,s1
    8000560a:	85ca                	mv	a1,s2
    8000560c:	855a                	mv	a0,s6
    8000560e:	ffffc097          	auipc	ra,0xffffc
    80005612:	f76080e7          	jalr	-138(ra) # 80001584 <uvmalloc>
    80005616:	dea43c23          	sd	a0,-520(s0)
    8000561a:	d939                	beqz	a0,80005570 <exec+0x2fc>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000561c:	e2843c03          	ld	s8,-472(s0)
    80005620:	e2042c83          	lw	s9,-480(s0)
    80005624:	e3842b83          	lw	s7,-456(s0)
  for (i = 0; i < sz; i += PGSIZE)
    80005628:	f60b83e3          	beqz	s7,8000558e <exec+0x31a>
    8000562c:	89de                	mv	s3,s7
    8000562e:	4481                	li	s1,0
    80005630:	bb9d                	j	800053a6 <exec+0x132>

0000000080005632 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005632:	7179                	addi	sp,sp,-48
    80005634:	f406                	sd	ra,40(sp)
    80005636:	f022                	sd	s0,32(sp)
    80005638:	ec26                	sd	s1,24(sp)
    8000563a:	e84a                	sd	s2,16(sp)
    8000563c:	1800                	addi	s0,sp,48
    8000563e:	892e                	mv	s2,a1
    80005640:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005642:	fdc40593          	addi	a1,s0,-36
    80005646:	ffffe097          	auipc	ra,0xffffe
    8000564a:	a14080e7          	jalr	-1516(ra) # 8000305a <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    8000564e:	fdc42703          	lw	a4,-36(s0)
    80005652:	47bd                	li	a5,15
    80005654:	02e7eb63          	bltu	a5,a4,8000568a <argfd+0x58>
    80005658:	ffffc097          	auipc	ra,0xffffc
    8000565c:	504080e7          	jalr	1284(ra) # 80001b5c <myproc>
    80005660:	fdc42703          	lw	a4,-36(s0)
    80005664:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7fdb9cca>
    80005668:	078e                	slli	a5,a5,0x3
    8000566a:	953e                	add	a0,a0,a5
    8000566c:	611c                	ld	a5,0(a0)
    8000566e:	c385                	beqz	a5,8000568e <argfd+0x5c>
    return -1;
  if (pfd)
    80005670:	00090463          	beqz	s2,80005678 <argfd+0x46>
    *pfd = fd;
    80005674:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80005678:	4501                	li	a0,0
  if (pf)
    8000567a:	c091                	beqz	s1,8000567e <argfd+0x4c>
    *pf = f;
    8000567c:	e09c                	sd	a5,0(s1)
}
    8000567e:	70a2                	ld	ra,40(sp)
    80005680:	7402                	ld	s0,32(sp)
    80005682:	64e2                	ld	s1,24(sp)
    80005684:	6942                	ld	s2,16(sp)
    80005686:	6145                	addi	sp,sp,48
    80005688:	8082                	ret
    return -1;
    8000568a:	557d                	li	a0,-1
    8000568c:	bfcd                	j	8000567e <argfd+0x4c>
    8000568e:	557d                	li	a0,-1
    80005690:	b7fd                	j	8000567e <argfd+0x4c>

0000000080005692 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005692:	1101                	addi	sp,sp,-32
    80005694:	ec06                	sd	ra,24(sp)
    80005696:	e822                	sd	s0,16(sp)
    80005698:	e426                	sd	s1,8(sp)
    8000569a:	1000                	addi	s0,sp,32
    8000569c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000569e:	ffffc097          	auipc	ra,0xffffc
    800056a2:	4be080e7          	jalr	1214(ra) # 80001b5c <myproc>
    800056a6:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++)
    800056a8:	0d050793          	addi	a5,a0,208
    800056ac:	4501                	li	a0,0
    800056ae:	46c1                	li	a3,16
  {
    if (p->ofile[fd] == 0)
    800056b0:	6398                	ld	a4,0(a5)
    800056b2:	cb19                	beqz	a4,800056c8 <fdalloc+0x36>
  for (fd = 0; fd < NOFILE; fd++)
    800056b4:	2505                	addiw	a0,a0,1
    800056b6:	07a1                	addi	a5,a5,8
    800056b8:	fed51ce3          	bne	a0,a3,800056b0 <fdalloc+0x1e>
    {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800056bc:	557d                	li	a0,-1
}
    800056be:	60e2                	ld	ra,24(sp)
    800056c0:	6442                	ld	s0,16(sp)
    800056c2:	64a2                	ld	s1,8(sp)
    800056c4:	6105                	addi	sp,sp,32
    800056c6:	8082                	ret
      p->ofile[fd] = f;
    800056c8:	01a50793          	addi	a5,a0,26
    800056cc:	078e                	slli	a5,a5,0x3
    800056ce:	963e                	add	a2,a2,a5
    800056d0:	e204                	sd	s1,0(a2)
      return fd;
    800056d2:	b7f5                	j	800056be <fdalloc+0x2c>

00000000800056d4 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    800056d4:	715d                	addi	sp,sp,-80
    800056d6:	e486                	sd	ra,72(sp)
    800056d8:	e0a2                	sd	s0,64(sp)
    800056da:	fc26                	sd	s1,56(sp)
    800056dc:	f84a                	sd	s2,48(sp)
    800056de:	f44e                	sd	s3,40(sp)
    800056e0:	f052                	sd	s4,32(sp)
    800056e2:	ec56                	sd	s5,24(sp)
    800056e4:	e85a                	sd	s6,16(sp)
    800056e6:	0880                	addi	s0,sp,80
    800056e8:	8b2e                	mv	s6,a1
    800056ea:	89b2                	mv	s3,a2
    800056ec:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    800056ee:	fb040593          	addi	a1,s0,-80
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	e3e080e7          	jalr	-450(ra) # 80004530 <nameiparent>
    800056fa:	84aa                	mv	s1,a0
    800056fc:	14050f63          	beqz	a0,8000585a <create+0x186>
    return 0;

  ilock(dp);
    80005700:	ffffe097          	auipc	ra,0xffffe
    80005704:	666080e7          	jalr	1638(ra) # 80003d66 <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0)
    80005708:	4601                	li	a2,0
    8000570a:	fb040593          	addi	a1,s0,-80
    8000570e:	8526                	mv	a0,s1
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	b3a080e7          	jalr	-1222(ra) # 8000424a <dirlookup>
    80005718:	8aaa                	mv	s5,a0
    8000571a:	c931                	beqz	a0,8000576e <create+0x9a>
  {
    iunlockput(dp);
    8000571c:	8526                	mv	a0,s1
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	8aa080e7          	jalr	-1878(ra) # 80003fc8 <iunlockput>
    ilock(ip);
    80005726:	8556                	mv	a0,s5
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	63e080e7          	jalr	1598(ra) # 80003d66 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005730:	000b059b          	sext.w	a1,s6
    80005734:	4789                	li	a5,2
    80005736:	02f59563          	bne	a1,a5,80005760 <create+0x8c>
    8000573a:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fdb9cf4>
    8000573e:	37f9                	addiw	a5,a5,-2
    80005740:	17c2                	slli	a5,a5,0x30
    80005742:	93c1                	srli	a5,a5,0x30
    80005744:	4705                	li	a4,1
    80005746:	00f76d63          	bltu	a4,a5,80005760 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000574a:	8556                	mv	a0,s5
    8000574c:	60a6                	ld	ra,72(sp)
    8000574e:	6406                	ld	s0,64(sp)
    80005750:	74e2                	ld	s1,56(sp)
    80005752:	7942                	ld	s2,48(sp)
    80005754:	79a2                	ld	s3,40(sp)
    80005756:	7a02                	ld	s4,32(sp)
    80005758:	6ae2                	ld	s5,24(sp)
    8000575a:	6b42                	ld	s6,16(sp)
    8000575c:	6161                	addi	sp,sp,80
    8000575e:	8082                	ret
    iunlockput(ip);
    80005760:	8556                	mv	a0,s5
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	866080e7          	jalr	-1946(ra) # 80003fc8 <iunlockput>
    return 0;
    8000576a:	4a81                	li	s5,0
    8000576c:	bff9                	j	8000574a <create+0x76>
  if ((ip = ialloc(dp->dev, type)) == 0)
    8000576e:	85da                	mv	a1,s6
    80005770:	4088                	lw	a0,0(s1)
    80005772:	ffffe097          	auipc	ra,0xffffe
    80005776:	456080e7          	jalr	1110(ra) # 80003bc8 <ialloc>
    8000577a:	8a2a                	mv	s4,a0
    8000577c:	c539                	beqz	a0,800057ca <create+0xf6>
  ilock(ip);
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	5e8080e7          	jalr	1512(ra) # 80003d66 <ilock>
  ip->major = major;
    80005786:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000578a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000578e:	4905                	li	s2,1
    80005790:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005794:	8552                	mv	a0,s4
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	504080e7          	jalr	1284(ra) # 80003c9a <iupdate>
  if (type == T_DIR)
    8000579e:	000b059b          	sext.w	a1,s6
    800057a2:	03258b63          	beq	a1,s2,800057d8 <create+0x104>
  if (dirlink(dp, name, ip->inum) < 0)
    800057a6:	004a2603          	lw	a2,4(s4)
    800057aa:	fb040593          	addi	a1,s0,-80
    800057ae:	8526                	mv	a0,s1
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	cb0080e7          	jalr	-848(ra) # 80004460 <dirlink>
    800057b8:	06054f63          	bltz	a0,80005836 <create+0x162>
  iunlockput(dp);
    800057bc:	8526                	mv	a0,s1
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	80a080e7          	jalr	-2038(ra) # 80003fc8 <iunlockput>
  return ip;
    800057c6:	8ad2                	mv	s5,s4
    800057c8:	b749                	j	8000574a <create+0x76>
    iunlockput(dp);
    800057ca:	8526                	mv	a0,s1
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	7fc080e7          	jalr	2044(ra) # 80003fc8 <iunlockput>
    return 0;
    800057d4:	8ad2                	mv	s5,s4
    800057d6:	bf95                	j	8000574a <create+0x76>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800057d8:	004a2603          	lw	a2,4(s4)
    800057dc:	00003597          	auipc	a1,0x3
    800057e0:	06c58593          	addi	a1,a1,108 # 80008848 <syscalls+0x2b0>
    800057e4:	8552                	mv	a0,s4
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	c7a080e7          	jalr	-902(ra) # 80004460 <dirlink>
    800057ee:	04054463          	bltz	a0,80005836 <create+0x162>
    800057f2:	40d0                	lw	a2,4(s1)
    800057f4:	00003597          	auipc	a1,0x3
    800057f8:	05c58593          	addi	a1,a1,92 # 80008850 <syscalls+0x2b8>
    800057fc:	8552                	mv	a0,s4
    800057fe:	fffff097          	auipc	ra,0xfffff
    80005802:	c62080e7          	jalr	-926(ra) # 80004460 <dirlink>
    80005806:	02054863          	bltz	a0,80005836 <create+0x162>
  if (dirlink(dp, name, ip->inum) < 0)
    8000580a:	004a2603          	lw	a2,4(s4)
    8000580e:	fb040593          	addi	a1,s0,-80
    80005812:	8526                	mv	a0,s1
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	c4c080e7          	jalr	-948(ra) # 80004460 <dirlink>
    8000581c:	00054d63          	bltz	a0,80005836 <create+0x162>
    dp->nlink++; // for ".."
    80005820:	04a4d783          	lhu	a5,74(s1)
    80005824:	2785                	addiw	a5,a5,1
    80005826:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000582a:	8526                	mv	a0,s1
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	46e080e7          	jalr	1134(ra) # 80003c9a <iupdate>
    80005834:	b761                	j	800057bc <create+0xe8>
  ip->nlink = 0;
    80005836:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000583a:	8552                	mv	a0,s4
    8000583c:	ffffe097          	auipc	ra,0xffffe
    80005840:	45e080e7          	jalr	1118(ra) # 80003c9a <iupdate>
  iunlockput(ip);
    80005844:	8552                	mv	a0,s4
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	782080e7          	jalr	1922(ra) # 80003fc8 <iunlockput>
  iunlockput(dp);
    8000584e:	8526                	mv	a0,s1
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	778080e7          	jalr	1912(ra) # 80003fc8 <iunlockput>
  return 0;
    80005858:	bdcd                	j	8000574a <create+0x76>
    return 0;
    8000585a:	8aaa                	mv	s5,a0
    8000585c:	b5fd                	j	8000574a <create+0x76>

000000008000585e <sys_dup>:
{
    8000585e:	7179                	addi	sp,sp,-48
    80005860:	f406                	sd	ra,40(sp)
    80005862:	f022                	sd	s0,32(sp)
    80005864:	ec26                	sd	s1,24(sp)
    80005866:	e84a                	sd	s2,16(sp)
    80005868:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    8000586a:	fd840613          	addi	a2,s0,-40
    8000586e:	4581                	li	a1,0
    80005870:	4501                	li	a0,0
    80005872:	00000097          	auipc	ra,0x0
    80005876:	dc0080e7          	jalr	-576(ra) # 80005632 <argfd>
    return -1;
    8000587a:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    8000587c:	02054363          	bltz	a0,800058a2 <sys_dup+0x44>
  if ((fd = fdalloc(f)) < 0)
    80005880:	fd843903          	ld	s2,-40(s0)
    80005884:	854a                	mv	a0,s2
    80005886:	00000097          	auipc	ra,0x0
    8000588a:	e0c080e7          	jalr	-500(ra) # 80005692 <fdalloc>
    8000588e:	84aa                	mv	s1,a0
    return -1;
    80005890:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80005892:	00054863          	bltz	a0,800058a2 <sys_dup+0x44>
  filedup(f);
    80005896:	854a                	mv	a0,s2
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	310080e7          	jalr	784(ra) # 80004ba8 <filedup>
  return fd;
    800058a0:	87a6                	mv	a5,s1
}
    800058a2:	853e                	mv	a0,a5
    800058a4:	70a2                	ld	ra,40(sp)
    800058a6:	7402                	ld	s0,32(sp)
    800058a8:	64e2                	ld	s1,24(sp)
    800058aa:	6942                	ld	s2,16(sp)
    800058ac:	6145                	addi	sp,sp,48
    800058ae:	8082                	ret

00000000800058b0 <sys_read>:
{
    800058b0:	7179                	addi	sp,sp,-48
    800058b2:	f406                	sd	ra,40(sp)
    800058b4:	f022                	sd	s0,32(sp)
    800058b6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800058b8:	fd840593          	addi	a1,s0,-40
    800058bc:	4505                	li	a0,1
    800058be:	ffffd097          	auipc	ra,0xffffd
    800058c2:	7bc080e7          	jalr	1980(ra) # 8000307a <argaddr>
  argint(2, &n);
    800058c6:	fe440593          	addi	a1,s0,-28
    800058ca:	4509                	li	a0,2
    800058cc:	ffffd097          	auipc	ra,0xffffd
    800058d0:	78e080e7          	jalr	1934(ra) # 8000305a <argint>
  if (argfd(0, 0, &f) < 0)
    800058d4:	fe840613          	addi	a2,s0,-24
    800058d8:	4581                	li	a1,0
    800058da:	4501                	li	a0,0
    800058dc:	00000097          	auipc	ra,0x0
    800058e0:	d56080e7          	jalr	-682(ra) # 80005632 <argfd>
    800058e4:	87aa                	mv	a5,a0
    return -1;
    800058e6:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800058e8:	0007cc63          	bltz	a5,80005900 <sys_read+0x50>
  return fileread(f, p, n);
    800058ec:	fe442603          	lw	a2,-28(s0)
    800058f0:	fd843583          	ld	a1,-40(s0)
    800058f4:	fe843503          	ld	a0,-24(s0)
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	43c080e7          	jalr	1084(ra) # 80004d34 <fileread>
}
    80005900:	70a2                	ld	ra,40(sp)
    80005902:	7402                	ld	s0,32(sp)
    80005904:	6145                	addi	sp,sp,48
    80005906:	8082                	ret

0000000080005908 <sys_write>:
{
    80005908:	7179                	addi	sp,sp,-48
    8000590a:	f406                	sd	ra,40(sp)
    8000590c:	f022                	sd	s0,32(sp)
    8000590e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005910:	fd840593          	addi	a1,s0,-40
    80005914:	4505                	li	a0,1
    80005916:	ffffd097          	auipc	ra,0xffffd
    8000591a:	764080e7          	jalr	1892(ra) # 8000307a <argaddr>
  argint(2, &n);
    8000591e:	fe440593          	addi	a1,s0,-28
    80005922:	4509                	li	a0,2
    80005924:	ffffd097          	auipc	ra,0xffffd
    80005928:	736080e7          	jalr	1846(ra) # 8000305a <argint>
  if (argfd(0, 0, &f) < 0)
    8000592c:	fe840613          	addi	a2,s0,-24
    80005930:	4581                	li	a1,0
    80005932:	4501                	li	a0,0
    80005934:	00000097          	auipc	ra,0x0
    80005938:	cfe080e7          	jalr	-770(ra) # 80005632 <argfd>
    8000593c:	87aa                	mv	a5,a0
    return -1;
    8000593e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005940:	0007cc63          	bltz	a5,80005958 <sys_write+0x50>
  return filewrite(f, p, n);
    80005944:	fe442603          	lw	a2,-28(s0)
    80005948:	fd843583          	ld	a1,-40(s0)
    8000594c:	fe843503          	ld	a0,-24(s0)
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	4a6080e7          	jalr	1190(ra) # 80004df6 <filewrite>
}
    80005958:	70a2                	ld	ra,40(sp)
    8000595a:	7402                	ld	s0,32(sp)
    8000595c:	6145                	addi	sp,sp,48
    8000595e:	8082                	ret

0000000080005960 <sys_close>:
{
    80005960:	1101                	addi	sp,sp,-32
    80005962:	ec06                	sd	ra,24(sp)
    80005964:	e822                	sd	s0,16(sp)
    80005966:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005968:	fe040613          	addi	a2,s0,-32
    8000596c:	fec40593          	addi	a1,s0,-20
    80005970:	4501                	li	a0,0
    80005972:	00000097          	auipc	ra,0x0
    80005976:	cc0080e7          	jalr	-832(ra) # 80005632 <argfd>
    return -1;
    8000597a:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    8000597c:	02054463          	bltz	a0,800059a4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005980:	ffffc097          	auipc	ra,0xffffc
    80005984:	1dc080e7          	jalr	476(ra) # 80001b5c <myproc>
    80005988:	fec42783          	lw	a5,-20(s0)
    8000598c:	07e9                	addi	a5,a5,26
    8000598e:	078e                	slli	a5,a5,0x3
    80005990:	953e                	add	a0,a0,a5
    80005992:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005996:	fe043503          	ld	a0,-32(s0)
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	260080e7          	jalr	608(ra) # 80004bfa <fileclose>
  return 0;
    800059a2:	4781                	li	a5,0
}
    800059a4:	853e                	mv	a0,a5
    800059a6:	60e2                	ld	ra,24(sp)
    800059a8:	6442                	ld	s0,16(sp)
    800059aa:	6105                	addi	sp,sp,32
    800059ac:	8082                	ret

00000000800059ae <sys_fstat>:
{
    800059ae:	1101                	addi	sp,sp,-32
    800059b0:	ec06                	sd	ra,24(sp)
    800059b2:	e822                	sd	s0,16(sp)
    800059b4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800059b6:	fe040593          	addi	a1,s0,-32
    800059ba:	4505                	li	a0,1
    800059bc:	ffffd097          	auipc	ra,0xffffd
    800059c0:	6be080e7          	jalr	1726(ra) # 8000307a <argaddr>
  if (argfd(0, 0, &f) < 0)
    800059c4:	fe840613          	addi	a2,s0,-24
    800059c8:	4581                	li	a1,0
    800059ca:	4501                	li	a0,0
    800059cc:	00000097          	auipc	ra,0x0
    800059d0:	c66080e7          	jalr	-922(ra) # 80005632 <argfd>
    800059d4:	87aa                	mv	a5,a0
    return -1;
    800059d6:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800059d8:	0007ca63          	bltz	a5,800059ec <sys_fstat+0x3e>
  return filestat(f, st);
    800059dc:	fe043583          	ld	a1,-32(s0)
    800059e0:	fe843503          	ld	a0,-24(s0)
    800059e4:	fffff097          	auipc	ra,0xfffff
    800059e8:	2de080e7          	jalr	734(ra) # 80004cc2 <filestat>
}
    800059ec:	60e2                	ld	ra,24(sp)
    800059ee:	6442                	ld	s0,16(sp)
    800059f0:	6105                	addi	sp,sp,32
    800059f2:	8082                	ret

00000000800059f4 <sys_link>:
{
    800059f4:	7169                	addi	sp,sp,-304
    800059f6:	f606                	sd	ra,296(sp)
    800059f8:	f222                	sd	s0,288(sp)
    800059fa:	ee26                	sd	s1,280(sp)
    800059fc:	ea4a                	sd	s2,272(sp)
    800059fe:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a00:	08000613          	li	a2,128
    80005a04:	ed040593          	addi	a1,s0,-304
    80005a08:	4501                	li	a0,0
    80005a0a:	ffffd097          	auipc	ra,0xffffd
    80005a0e:	690080e7          	jalr	1680(ra) # 8000309a <argstr>
    return -1;
    80005a12:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a14:	10054e63          	bltz	a0,80005b30 <sys_link+0x13c>
    80005a18:	08000613          	li	a2,128
    80005a1c:	f5040593          	addi	a1,s0,-176
    80005a20:	4505                	li	a0,1
    80005a22:	ffffd097          	auipc	ra,0xffffd
    80005a26:	678080e7          	jalr	1656(ra) # 8000309a <argstr>
    return -1;
    80005a2a:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a2c:	10054263          	bltz	a0,80005b30 <sys_link+0x13c>
  begin_op();
    80005a30:	fffff097          	auipc	ra,0xfffff
    80005a34:	d02080e7          	jalr	-766(ra) # 80004732 <begin_op>
  if ((ip = namei(old)) == 0)
    80005a38:	ed040513          	addi	a0,s0,-304
    80005a3c:	fffff097          	auipc	ra,0xfffff
    80005a40:	ad6080e7          	jalr	-1322(ra) # 80004512 <namei>
    80005a44:	84aa                	mv	s1,a0
    80005a46:	c551                	beqz	a0,80005ad2 <sys_link+0xde>
  ilock(ip);
    80005a48:	ffffe097          	auipc	ra,0xffffe
    80005a4c:	31e080e7          	jalr	798(ra) # 80003d66 <ilock>
  if (ip->type == T_DIR)
    80005a50:	04449703          	lh	a4,68(s1)
    80005a54:	4785                	li	a5,1
    80005a56:	08f70463          	beq	a4,a5,80005ade <sys_link+0xea>
  ip->nlink++;
    80005a5a:	04a4d783          	lhu	a5,74(s1)
    80005a5e:	2785                	addiw	a5,a5,1
    80005a60:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a64:	8526                	mv	a0,s1
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	234080e7          	jalr	564(ra) # 80003c9a <iupdate>
  iunlock(ip);
    80005a6e:	8526                	mv	a0,s1
    80005a70:	ffffe097          	auipc	ra,0xffffe
    80005a74:	3b8080e7          	jalr	952(ra) # 80003e28 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005a78:	fd040593          	addi	a1,s0,-48
    80005a7c:	f5040513          	addi	a0,s0,-176
    80005a80:	fffff097          	auipc	ra,0xfffff
    80005a84:	ab0080e7          	jalr	-1360(ra) # 80004530 <nameiparent>
    80005a88:	892a                	mv	s2,a0
    80005a8a:	c935                	beqz	a0,80005afe <sys_link+0x10a>
  ilock(dp);
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	2da080e7          	jalr	730(ra) # 80003d66 <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0)
    80005a94:	00092703          	lw	a4,0(s2)
    80005a98:	409c                	lw	a5,0(s1)
    80005a9a:	04f71d63          	bne	a4,a5,80005af4 <sys_link+0x100>
    80005a9e:	40d0                	lw	a2,4(s1)
    80005aa0:	fd040593          	addi	a1,s0,-48
    80005aa4:	854a                	mv	a0,s2
    80005aa6:	fffff097          	auipc	ra,0xfffff
    80005aaa:	9ba080e7          	jalr	-1606(ra) # 80004460 <dirlink>
    80005aae:	04054363          	bltz	a0,80005af4 <sys_link+0x100>
  iunlockput(dp);
    80005ab2:	854a                	mv	a0,s2
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	514080e7          	jalr	1300(ra) # 80003fc8 <iunlockput>
  iput(ip);
    80005abc:	8526                	mv	a0,s1
    80005abe:	ffffe097          	auipc	ra,0xffffe
    80005ac2:	462080e7          	jalr	1122(ra) # 80003f20 <iput>
  end_op();
    80005ac6:	fffff097          	auipc	ra,0xfffff
    80005aca:	cea080e7          	jalr	-790(ra) # 800047b0 <end_op>
  return 0;
    80005ace:	4781                	li	a5,0
    80005ad0:	a085                	j	80005b30 <sys_link+0x13c>
    end_op();
    80005ad2:	fffff097          	auipc	ra,0xfffff
    80005ad6:	cde080e7          	jalr	-802(ra) # 800047b0 <end_op>
    return -1;
    80005ada:	57fd                	li	a5,-1
    80005adc:	a891                	j	80005b30 <sys_link+0x13c>
    iunlockput(ip);
    80005ade:	8526                	mv	a0,s1
    80005ae0:	ffffe097          	auipc	ra,0xffffe
    80005ae4:	4e8080e7          	jalr	1256(ra) # 80003fc8 <iunlockput>
    end_op();
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	cc8080e7          	jalr	-824(ra) # 800047b0 <end_op>
    return -1;
    80005af0:	57fd                	li	a5,-1
    80005af2:	a83d                	j	80005b30 <sys_link+0x13c>
    iunlockput(dp);
    80005af4:	854a                	mv	a0,s2
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	4d2080e7          	jalr	1234(ra) # 80003fc8 <iunlockput>
  ilock(ip);
    80005afe:	8526                	mv	a0,s1
    80005b00:	ffffe097          	auipc	ra,0xffffe
    80005b04:	266080e7          	jalr	614(ra) # 80003d66 <ilock>
  ip->nlink--;
    80005b08:	04a4d783          	lhu	a5,74(s1)
    80005b0c:	37fd                	addiw	a5,a5,-1
    80005b0e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	186080e7          	jalr	390(ra) # 80003c9a <iupdate>
  iunlockput(ip);
    80005b1c:	8526                	mv	a0,s1
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	4aa080e7          	jalr	1194(ra) # 80003fc8 <iunlockput>
  end_op();
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	c8a080e7          	jalr	-886(ra) # 800047b0 <end_op>
  return -1;
    80005b2e:	57fd                	li	a5,-1
}
    80005b30:	853e                	mv	a0,a5
    80005b32:	70b2                	ld	ra,296(sp)
    80005b34:	7412                	ld	s0,288(sp)
    80005b36:	64f2                	ld	s1,280(sp)
    80005b38:	6952                	ld	s2,272(sp)
    80005b3a:	6155                	addi	sp,sp,304
    80005b3c:	8082                	ret

0000000080005b3e <sys_unlink>:
{
    80005b3e:	7151                	addi	sp,sp,-240
    80005b40:	f586                	sd	ra,232(sp)
    80005b42:	f1a2                	sd	s0,224(sp)
    80005b44:	eda6                	sd	s1,216(sp)
    80005b46:	e9ca                	sd	s2,208(sp)
    80005b48:	e5ce                	sd	s3,200(sp)
    80005b4a:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005b4c:	08000613          	li	a2,128
    80005b50:	f3040593          	addi	a1,s0,-208
    80005b54:	4501                	li	a0,0
    80005b56:	ffffd097          	auipc	ra,0xffffd
    80005b5a:	544080e7          	jalr	1348(ra) # 8000309a <argstr>
    80005b5e:	18054163          	bltz	a0,80005ce0 <sys_unlink+0x1a2>
  begin_op();
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	bd0080e7          	jalr	-1072(ra) # 80004732 <begin_op>
  if ((dp = nameiparent(path, name)) == 0)
    80005b6a:	fb040593          	addi	a1,s0,-80
    80005b6e:	f3040513          	addi	a0,s0,-208
    80005b72:	fffff097          	auipc	ra,0xfffff
    80005b76:	9be080e7          	jalr	-1602(ra) # 80004530 <nameiparent>
    80005b7a:	84aa                	mv	s1,a0
    80005b7c:	c979                	beqz	a0,80005c52 <sys_unlink+0x114>
  ilock(dp);
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	1e8080e7          	jalr	488(ra) # 80003d66 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b86:	00003597          	auipc	a1,0x3
    80005b8a:	cc258593          	addi	a1,a1,-830 # 80008848 <syscalls+0x2b0>
    80005b8e:	fb040513          	addi	a0,s0,-80
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	69e080e7          	jalr	1694(ra) # 80004230 <namecmp>
    80005b9a:	14050a63          	beqz	a0,80005cee <sys_unlink+0x1b0>
    80005b9e:	00003597          	auipc	a1,0x3
    80005ba2:	cb258593          	addi	a1,a1,-846 # 80008850 <syscalls+0x2b8>
    80005ba6:	fb040513          	addi	a0,s0,-80
    80005baa:	ffffe097          	auipc	ra,0xffffe
    80005bae:	686080e7          	jalr	1670(ra) # 80004230 <namecmp>
    80005bb2:	12050e63          	beqz	a0,80005cee <sys_unlink+0x1b0>
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005bb6:	f2c40613          	addi	a2,s0,-212
    80005bba:	fb040593          	addi	a1,s0,-80
    80005bbe:	8526                	mv	a0,s1
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	68a080e7          	jalr	1674(ra) # 8000424a <dirlookup>
    80005bc8:	892a                	mv	s2,a0
    80005bca:	12050263          	beqz	a0,80005cee <sys_unlink+0x1b0>
  ilock(ip);
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	198080e7          	jalr	408(ra) # 80003d66 <ilock>
  if (ip->nlink < 1)
    80005bd6:	04a91783          	lh	a5,74(s2)
    80005bda:	08f05263          	blez	a5,80005c5e <sys_unlink+0x120>
  if (ip->type == T_DIR && !isdirempty(ip))
    80005bde:	04491703          	lh	a4,68(s2)
    80005be2:	4785                	li	a5,1
    80005be4:	08f70563          	beq	a4,a5,80005c6e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005be8:	4641                	li	a2,16
    80005bea:	4581                	li	a1,0
    80005bec:	fc040513          	addi	a0,s0,-64
    80005bf0:	ffffb097          	auipc	ra,0xffffb
    80005bf4:	256080e7          	jalr	598(ra) # 80000e46 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bf8:	4741                	li	a4,16
    80005bfa:	f2c42683          	lw	a3,-212(s0)
    80005bfe:	fc040613          	addi	a2,s0,-64
    80005c02:	4581                	li	a1,0
    80005c04:	8526                	mv	a0,s1
    80005c06:	ffffe097          	auipc	ra,0xffffe
    80005c0a:	50c080e7          	jalr	1292(ra) # 80004112 <writei>
    80005c0e:	47c1                	li	a5,16
    80005c10:	0af51563          	bne	a0,a5,80005cba <sys_unlink+0x17c>
  if (ip->type == T_DIR)
    80005c14:	04491703          	lh	a4,68(s2)
    80005c18:	4785                	li	a5,1
    80005c1a:	0af70863          	beq	a4,a5,80005cca <sys_unlink+0x18c>
  iunlockput(dp);
    80005c1e:	8526                	mv	a0,s1
    80005c20:	ffffe097          	auipc	ra,0xffffe
    80005c24:	3a8080e7          	jalr	936(ra) # 80003fc8 <iunlockput>
  ip->nlink--;
    80005c28:	04a95783          	lhu	a5,74(s2)
    80005c2c:	37fd                	addiw	a5,a5,-1
    80005c2e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c32:	854a                	mv	a0,s2
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	066080e7          	jalr	102(ra) # 80003c9a <iupdate>
  iunlockput(ip);
    80005c3c:	854a                	mv	a0,s2
    80005c3e:	ffffe097          	auipc	ra,0xffffe
    80005c42:	38a080e7          	jalr	906(ra) # 80003fc8 <iunlockput>
  end_op();
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	b6a080e7          	jalr	-1174(ra) # 800047b0 <end_op>
  return 0;
    80005c4e:	4501                	li	a0,0
    80005c50:	a84d                	j	80005d02 <sys_unlink+0x1c4>
    end_op();
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	b5e080e7          	jalr	-1186(ra) # 800047b0 <end_op>
    return -1;
    80005c5a:	557d                	li	a0,-1
    80005c5c:	a05d                	j	80005d02 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005c5e:	00003517          	auipc	a0,0x3
    80005c62:	bfa50513          	addi	a0,a0,-1030 # 80008858 <syscalls+0x2c0>
    80005c66:	ffffb097          	auipc	ra,0xffffb
    80005c6a:	8da080e7          	jalr	-1830(ra) # 80000540 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005c6e:	04c92703          	lw	a4,76(s2)
    80005c72:	02000793          	li	a5,32
    80005c76:	f6e7f9e3          	bgeu	a5,a4,80005be8 <sys_unlink+0xaa>
    80005c7a:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c7e:	4741                	li	a4,16
    80005c80:	86ce                	mv	a3,s3
    80005c82:	f1840613          	addi	a2,s0,-232
    80005c86:	4581                	li	a1,0
    80005c88:	854a                	mv	a0,s2
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	390080e7          	jalr	912(ra) # 8000401a <readi>
    80005c92:	47c1                	li	a5,16
    80005c94:	00f51b63          	bne	a0,a5,80005caa <sys_unlink+0x16c>
    if (de.inum != 0)
    80005c98:	f1845783          	lhu	a5,-232(s0)
    80005c9c:	e7a1                	bnez	a5,80005ce4 <sys_unlink+0x1a6>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
    80005c9e:	29c1                	addiw	s3,s3,16
    80005ca0:	04c92783          	lw	a5,76(s2)
    80005ca4:	fcf9ede3          	bltu	s3,a5,80005c7e <sys_unlink+0x140>
    80005ca8:	b781                	j	80005be8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005caa:	00003517          	auipc	a0,0x3
    80005cae:	bc650513          	addi	a0,a0,-1082 # 80008870 <syscalls+0x2d8>
    80005cb2:	ffffb097          	auipc	ra,0xffffb
    80005cb6:	88e080e7          	jalr	-1906(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005cba:	00003517          	auipc	a0,0x3
    80005cbe:	bce50513          	addi	a0,a0,-1074 # 80008888 <syscalls+0x2f0>
    80005cc2:	ffffb097          	auipc	ra,0xffffb
    80005cc6:	87e080e7          	jalr	-1922(ra) # 80000540 <panic>
    dp->nlink--;
    80005cca:	04a4d783          	lhu	a5,74(s1)
    80005cce:	37fd                	addiw	a5,a5,-1
    80005cd0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005cd4:	8526                	mv	a0,s1
    80005cd6:	ffffe097          	auipc	ra,0xffffe
    80005cda:	fc4080e7          	jalr	-60(ra) # 80003c9a <iupdate>
    80005cde:	b781                	j	80005c1e <sys_unlink+0xe0>
    return -1;
    80005ce0:	557d                	li	a0,-1
    80005ce2:	a005                	j	80005d02 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005ce4:	854a                	mv	a0,s2
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	2e2080e7          	jalr	738(ra) # 80003fc8 <iunlockput>
  iunlockput(dp);
    80005cee:	8526                	mv	a0,s1
    80005cf0:	ffffe097          	auipc	ra,0xffffe
    80005cf4:	2d8080e7          	jalr	728(ra) # 80003fc8 <iunlockput>
  end_op();
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	ab8080e7          	jalr	-1352(ra) # 800047b0 <end_op>
  return -1;
    80005d00:	557d                	li	a0,-1
}
    80005d02:	70ae                	ld	ra,232(sp)
    80005d04:	740e                	ld	s0,224(sp)
    80005d06:	64ee                	ld	s1,216(sp)
    80005d08:	694e                	ld	s2,208(sp)
    80005d0a:	69ae                	ld	s3,200(sp)
    80005d0c:	616d                	addi	sp,sp,240
    80005d0e:	8082                	ret

0000000080005d10 <sys_open>:

uint64
sys_open(void)
{
    80005d10:	7131                	addi	sp,sp,-192
    80005d12:	fd06                	sd	ra,184(sp)
    80005d14:	f922                	sd	s0,176(sp)
    80005d16:	f526                	sd	s1,168(sp)
    80005d18:	f14a                	sd	s2,160(sp)
    80005d1a:	ed4e                	sd	s3,152(sp)
    80005d1c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005d1e:	f4c40593          	addi	a1,s0,-180
    80005d22:	4505                	li	a0,1
    80005d24:	ffffd097          	auipc	ra,0xffffd
    80005d28:	336080e7          	jalr	822(ra) # 8000305a <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005d2c:	08000613          	li	a2,128
    80005d30:	f5040593          	addi	a1,s0,-176
    80005d34:	4501                	li	a0,0
    80005d36:	ffffd097          	auipc	ra,0xffffd
    80005d3a:	364080e7          	jalr	868(ra) # 8000309a <argstr>
    80005d3e:	87aa                	mv	a5,a0
    return -1;
    80005d40:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005d42:	0a07c963          	bltz	a5,80005df4 <sys_open+0xe4>

  begin_op();
    80005d46:	fffff097          	auipc	ra,0xfffff
    80005d4a:	9ec080e7          	jalr	-1556(ra) # 80004732 <begin_op>

  if (omode & O_CREATE)
    80005d4e:	f4c42783          	lw	a5,-180(s0)
    80005d52:	2007f793          	andi	a5,a5,512
    80005d56:	cfc5                	beqz	a5,80005e0e <sys_open+0xfe>
  {
    ip = create(path, T_FILE, 0, 0);
    80005d58:	4681                	li	a3,0
    80005d5a:	4601                	li	a2,0
    80005d5c:	4589                	li	a1,2
    80005d5e:	f5040513          	addi	a0,s0,-176
    80005d62:	00000097          	auipc	ra,0x0
    80005d66:	972080e7          	jalr	-1678(ra) # 800056d4 <create>
    80005d6a:	84aa                	mv	s1,a0
    if (ip == 0)
    80005d6c:	c959                	beqz	a0,80005e02 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV))
    80005d6e:	04449703          	lh	a4,68(s1)
    80005d72:	478d                	li	a5,3
    80005d74:	00f71763          	bne	a4,a5,80005d82 <sys_open+0x72>
    80005d78:	0464d703          	lhu	a4,70(s1)
    80005d7c:	47a5                	li	a5,9
    80005d7e:	0ce7ed63          	bltu	a5,a4,80005e58 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0)
    80005d82:	fffff097          	auipc	ra,0xfffff
    80005d86:	dbc080e7          	jalr	-580(ra) # 80004b3e <filealloc>
    80005d8a:	89aa                	mv	s3,a0
    80005d8c:	10050363          	beqz	a0,80005e92 <sys_open+0x182>
    80005d90:	00000097          	auipc	ra,0x0
    80005d94:	902080e7          	jalr	-1790(ra) # 80005692 <fdalloc>
    80005d98:	892a                	mv	s2,a0
    80005d9a:	0e054763          	bltz	a0,80005e88 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE)
    80005d9e:	04449703          	lh	a4,68(s1)
    80005da2:	478d                	li	a5,3
    80005da4:	0cf70563          	beq	a4,a5,80005e6e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  }
  else
  {
    f->type = FD_INODE;
    80005da8:	4789                	li	a5,2
    80005daa:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005dae:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005db2:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005db6:	f4c42783          	lw	a5,-180(s0)
    80005dba:	0017c713          	xori	a4,a5,1
    80005dbe:	8b05                	andi	a4,a4,1
    80005dc0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005dc4:	0037f713          	andi	a4,a5,3
    80005dc8:	00e03733          	snez	a4,a4
    80005dcc:	00e984a3          	sb	a4,9(s3)

  if ((omode & O_TRUNC) && ip->type == T_FILE)
    80005dd0:	4007f793          	andi	a5,a5,1024
    80005dd4:	c791                	beqz	a5,80005de0 <sys_open+0xd0>
    80005dd6:	04449703          	lh	a4,68(s1)
    80005dda:	4789                	li	a5,2
    80005ddc:	0af70063          	beq	a4,a5,80005e7c <sys_open+0x16c>
  {
    itrunc(ip);
  }

  iunlock(ip);
    80005de0:	8526                	mv	a0,s1
    80005de2:	ffffe097          	auipc	ra,0xffffe
    80005de6:	046080e7          	jalr	70(ra) # 80003e28 <iunlock>
  end_op();
    80005dea:	fffff097          	auipc	ra,0xfffff
    80005dee:	9c6080e7          	jalr	-1594(ra) # 800047b0 <end_op>

  return fd;
    80005df2:	854a                	mv	a0,s2
}
    80005df4:	70ea                	ld	ra,184(sp)
    80005df6:	744a                	ld	s0,176(sp)
    80005df8:	74aa                	ld	s1,168(sp)
    80005dfa:	790a                	ld	s2,160(sp)
    80005dfc:	69ea                	ld	s3,152(sp)
    80005dfe:	6129                	addi	sp,sp,192
    80005e00:	8082                	ret
      end_op();
    80005e02:	fffff097          	auipc	ra,0xfffff
    80005e06:	9ae080e7          	jalr	-1618(ra) # 800047b0 <end_op>
      return -1;
    80005e0a:	557d                	li	a0,-1
    80005e0c:	b7e5                	j	80005df4 <sys_open+0xe4>
    if ((ip = namei(path)) == 0)
    80005e0e:	f5040513          	addi	a0,s0,-176
    80005e12:	ffffe097          	auipc	ra,0xffffe
    80005e16:	700080e7          	jalr	1792(ra) # 80004512 <namei>
    80005e1a:	84aa                	mv	s1,a0
    80005e1c:	c905                	beqz	a0,80005e4c <sys_open+0x13c>
    ilock(ip);
    80005e1e:	ffffe097          	auipc	ra,0xffffe
    80005e22:	f48080e7          	jalr	-184(ra) # 80003d66 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY)
    80005e26:	04449703          	lh	a4,68(s1)
    80005e2a:	4785                	li	a5,1
    80005e2c:	f4f711e3          	bne	a4,a5,80005d6e <sys_open+0x5e>
    80005e30:	f4c42783          	lw	a5,-180(s0)
    80005e34:	d7b9                	beqz	a5,80005d82 <sys_open+0x72>
      iunlockput(ip);
    80005e36:	8526                	mv	a0,s1
    80005e38:	ffffe097          	auipc	ra,0xffffe
    80005e3c:	190080e7          	jalr	400(ra) # 80003fc8 <iunlockput>
      end_op();
    80005e40:	fffff097          	auipc	ra,0xfffff
    80005e44:	970080e7          	jalr	-1680(ra) # 800047b0 <end_op>
      return -1;
    80005e48:	557d                	li	a0,-1
    80005e4a:	b76d                	j	80005df4 <sys_open+0xe4>
      end_op();
    80005e4c:	fffff097          	auipc	ra,0xfffff
    80005e50:	964080e7          	jalr	-1692(ra) # 800047b0 <end_op>
      return -1;
    80005e54:	557d                	li	a0,-1
    80005e56:	bf79                	j	80005df4 <sys_open+0xe4>
    iunlockput(ip);
    80005e58:	8526                	mv	a0,s1
    80005e5a:	ffffe097          	auipc	ra,0xffffe
    80005e5e:	16e080e7          	jalr	366(ra) # 80003fc8 <iunlockput>
    end_op();
    80005e62:	fffff097          	auipc	ra,0xfffff
    80005e66:	94e080e7          	jalr	-1714(ra) # 800047b0 <end_op>
    return -1;
    80005e6a:	557d                	li	a0,-1
    80005e6c:	b761                	j	80005df4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005e6e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005e72:	04649783          	lh	a5,70(s1)
    80005e76:	02f99223          	sh	a5,36(s3)
    80005e7a:	bf25                	j	80005db2 <sys_open+0xa2>
    itrunc(ip);
    80005e7c:	8526                	mv	a0,s1
    80005e7e:	ffffe097          	auipc	ra,0xffffe
    80005e82:	ff6080e7          	jalr	-10(ra) # 80003e74 <itrunc>
    80005e86:	bfa9                	j	80005de0 <sys_open+0xd0>
      fileclose(f);
    80005e88:	854e                	mv	a0,s3
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	d70080e7          	jalr	-656(ra) # 80004bfa <fileclose>
    iunlockput(ip);
    80005e92:	8526                	mv	a0,s1
    80005e94:	ffffe097          	auipc	ra,0xffffe
    80005e98:	134080e7          	jalr	308(ra) # 80003fc8 <iunlockput>
    end_op();
    80005e9c:	fffff097          	auipc	ra,0xfffff
    80005ea0:	914080e7          	jalr	-1772(ra) # 800047b0 <end_op>
    return -1;
    80005ea4:	557d                	li	a0,-1
    80005ea6:	b7b9                	j	80005df4 <sys_open+0xe4>

0000000080005ea8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ea8:	7175                	addi	sp,sp,-144
    80005eaa:	e506                	sd	ra,136(sp)
    80005eac:	e122                	sd	s0,128(sp)
    80005eae:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005eb0:	fffff097          	auipc	ra,0xfffff
    80005eb4:	882080e7          	jalr	-1918(ra) # 80004732 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
    80005eb8:	08000613          	li	a2,128
    80005ebc:	f7040593          	addi	a1,s0,-144
    80005ec0:	4501                	li	a0,0
    80005ec2:	ffffd097          	auipc	ra,0xffffd
    80005ec6:	1d8080e7          	jalr	472(ra) # 8000309a <argstr>
    80005eca:	02054963          	bltz	a0,80005efc <sys_mkdir+0x54>
    80005ece:	4681                	li	a3,0
    80005ed0:	4601                	li	a2,0
    80005ed2:	4585                	li	a1,1
    80005ed4:	f7040513          	addi	a0,s0,-144
    80005ed8:	fffff097          	auipc	ra,0xfffff
    80005edc:	7fc080e7          	jalr	2044(ra) # 800056d4 <create>
    80005ee0:	cd11                	beqz	a0,80005efc <sys_mkdir+0x54>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ee2:	ffffe097          	auipc	ra,0xffffe
    80005ee6:	0e6080e7          	jalr	230(ra) # 80003fc8 <iunlockput>
  end_op();
    80005eea:	fffff097          	auipc	ra,0xfffff
    80005eee:	8c6080e7          	jalr	-1850(ra) # 800047b0 <end_op>
  return 0;
    80005ef2:	4501                	li	a0,0
}
    80005ef4:	60aa                	ld	ra,136(sp)
    80005ef6:	640a                	ld	s0,128(sp)
    80005ef8:	6149                	addi	sp,sp,144
    80005efa:	8082                	ret
    end_op();
    80005efc:	fffff097          	auipc	ra,0xfffff
    80005f00:	8b4080e7          	jalr	-1868(ra) # 800047b0 <end_op>
    return -1;
    80005f04:	557d                	li	a0,-1
    80005f06:	b7fd                	j	80005ef4 <sys_mkdir+0x4c>

0000000080005f08 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f08:	7135                	addi	sp,sp,-160
    80005f0a:	ed06                	sd	ra,152(sp)
    80005f0c:	e922                	sd	s0,144(sp)
    80005f0e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f10:	fffff097          	auipc	ra,0xfffff
    80005f14:	822080e7          	jalr	-2014(ra) # 80004732 <begin_op>
  argint(1, &major);
    80005f18:	f6c40593          	addi	a1,s0,-148
    80005f1c:	4505                	li	a0,1
    80005f1e:	ffffd097          	auipc	ra,0xffffd
    80005f22:	13c080e7          	jalr	316(ra) # 8000305a <argint>
  argint(2, &minor);
    80005f26:	f6840593          	addi	a1,s0,-152
    80005f2a:	4509                	li	a0,2
    80005f2c:	ffffd097          	auipc	ra,0xffffd
    80005f30:	12e080e7          	jalr	302(ra) # 8000305a <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005f34:	08000613          	li	a2,128
    80005f38:	f7040593          	addi	a1,s0,-144
    80005f3c:	4501                	li	a0,0
    80005f3e:	ffffd097          	auipc	ra,0xffffd
    80005f42:	15c080e7          	jalr	348(ra) # 8000309a <argstr>
    80005f46:	02054b63          	bltz	a0,80005f7c <sys_mknod+0x74>
      (ip = create(path, T_DEVICE, major, minor)) == 0)
    80005f4a:	f6841683          	lh	a3,-152(s0)
    80005f4e:	f6c41603          	lh	a2,-148(s0)
    80005f52:	458d                	li	a1,3
    80005f54:	f7040513          	addi	a0,s0,-144
    80005f58:	fffff097          	auipc	ra,0xfffff
    80005f5c:	77c080e7          	jalr	1916(ra) # 800056d4 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005f60:	cd11                	beqz	a0,80005f7c <sys_mknod+0x74>
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f62:	ffffe097          	auipc	ra,0xffffe
    80005f66:	066080e7          	jalr	102(ra) # 80003fc8 <iunlockput>
  end_op();
    80005f6a:	fffff097          	auipc	ra,0xfffff
    80005f6e:	846080e7          	jalr	-1978(ra) # 800047b0 <end_op>
  return 0;
    80005f72:	4501                	li	a0,0
}
    80005f74:	60ea                	ld	ra,152(sp)
    80005f76:	644a                	ld	s0,144(sp)
    80005f78:	610d                	addi	sp,sp,160
    80005f7a:	8082                	ret
    end_op();
    80005f7c:	fffff097          	auipc	ra,0xfffff
    80005f80:	834080e7          	jalr	-1996(ra) # 800047b0 <end_op>
    return -1;
    80005f84:	557d                	li	a0,-1
    80005f86:	b7fd                	j	80005f74 <sys_mknod+0x6c>

0000000080005f88 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f88:	7135                	addi	sp,sp,-160
    80005f8a:	ed06                	sd	ra,152(sp)
    80005f8c:	e922                	sd	s0,144(sp)
    80005f8e:	e526                	sd	s1,136(sp)
    80005f90:	e14a                	sd	s2,128(sp)
    80005f92:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f94:	ffffc097          	auipc	ra,0xffffc
    80005f98:	bc8080e7          	jalr	-1080(ra) # 80001b5c <myproc>
    80005f9c:	892a                	mv	s2,a0

  begin_op();
    80005f9e:	ffffe097          	auipc	ra,0xffffe
    80005fa2:	794080e7          	jalr	1940(ra) # 80004732 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0)
    80005fa6:	08000613          	li	a2,128
    80005faa:	f6040593          	addi	a1,s0,-160
    80005fae:	4501                	li	a0,0
    80005fb0:	ffffd097          	auipc	ra,0xffffd
    80005fb4:	0ea080e7          	jalr	234(ra) # 8000309a <argstr>
    80005fb8:	04054b63          	bltz	a0,8000600e <sys_chdir+0x86>
    80005fbc:	f6040513          	addi	a0,s0,-160
    80005fc0:	ffffe097          	auipc	ra,0xffffe
    80005fc4:	552080e7          	jalr	1362(ra) # 80004512 <namei>
    80005fc8:	84aa                	mv	s1,a0
    80005fca:	c131                	beqz	a0,8000600e <sys_chdir+0x86>
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005fcc:	ffffe097          	auipc	ra,0xffffe
    80005fd0:	d9a080e7          	jalr	-614(ra) # 80003d66 <ilock>
  if (ip->type != T_DIR)
    80005fd4:	04449703          	lh	a4,68(s1)
    80005fd8:	4785                	li	a5,1
    80005fda:	04f71063          	bne	a4,a5,8000601a <sys_chdir+0x92>
  {
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005fde:	8526                	mv	a0,s1
    80005fe0:	ffffe097          	auipc	ra,0xffffe
    80005fe4:	e48080e7          	jalr	-440(ra) # 80003e28 <iunlock>
  iput(p->cwd);
    80005fe8:	15093503          	ld	a0,336(s2)
    80005fec:	ffffe097          	auipc	ra,0xffffe
    80005ff0:	f34080e7          	jalr	-204(ra) # 80003f20 <iput>
  end_op();
    80005ff4:	ffffe097          	auipc	ra,0xffffe
    80005ff8:	7bc080e7          	jalr	1980(ra) # 800047b0 <end_op>
  p->cwd = ip;
    80005ffc:	14993823          	sd	s1,336(s2)
  return 0;
    80006000:	4501                	li	a0,0
}
    80006002:	60ea                	ld	ra,152(sp)
    80006004:	644a                	ld	s0,144(sp)
    80006006:	64aa                	ld	s1,136(sp)
    80006008:	690a                	ld	s2,128(sp)
    8000600a:	610d                	addi	sp,sp,160
    8000600c:	8082                	ret
    end_op();
    8000600e:	ffffe097          	auipc	ra,0xffffe
    80006012:	7a2080e7          	jalr	1954(ra) # 800047b0 <end_op>
    return -1;
    80006016:	557d                	li	a0,-1
    80006018:	b7ed                	j	80006002 <sys_chdir+0x7a>
    iunlockput(ip);
    8000601a:	8526                	mv	a0,s1
    8000601c:	ffffe097          	auipc	ra,0xffffe
    80006020:	fac080e7          	jalr	-84(ra) # 80003fc8 <iunlockput>
    end_op();
    80006024:	ffffe097          	auipc	ra,0xffffe
    80006028:	78c080e7          	jalr	1932(ra) # 800047b0 <end_op>
    return -1;
    8000602c:	557d                	li	a0,-1
    8000602e:	bfd1                	j	80006002 <sys_chdir+0x7a>

0000000080006030 <sys_exec>:

uint64
sys_exec(void)
{
    80006030:	7145                	addi	sp,sp,-464
    80006032:	e786                	sd	ra,456(sp)
    80006034:	e3a2                	sd	s0,448(sp)
    80006036:	ff26                	sd	s1,440(sp)
    80006038:	fb4a                	sd	s2,432(sp)
    8000603a:	f74e                	sd	s3,424(sp)
    8000603c:	f352                	sd	s4,416(sp)
    8000603e:	ef56                	sd	s5,408(sp)
    80006040:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006042:	e3840593          	addi	a1,s0,-456
    80006046:	4505                	li	a0,1
    80006048:	ffffd097          	auipc	ra,0xffffd
    8000604c:	032080e7          	jalr	50(ra) # 8000307a <argaddr>
  if (argstr(0, path, MAXPATH) < 0)
    80006050:	08000613          	li	a2,128
    80006054:	f4040593          	addi	a1,s0,-192
    80006058:	4501                	li	a0,0
    8000605a:	ffffd097          	auipc	ra,0xffffd
    8000605e:	040080e7          	jalr	64(ra) # 8000309a <argstr>
    80006062:	87aa                	mv	a5,a0
  {
    return -1;
    80006064:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0)
    80006066:	0c07c363          	bltz	a5,8000612c <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    8000606a:	10000613          	li	a2,256
    8000606e:	4581                	li	a1,0
    80006070:	e4040513          	addi	a0,s0,-448
    80006074:	ffffb097          	auipc	ra,0xffffb
    80006078:	dd2080e7          	jalr	-558(ra) # 80000e46 <memset>
  for (i = 0;; i++)
  {
    if (i >= NELEM(argv))
    8000607c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006080:	89a6                	mv	s3,s1
    80006082:	4901                	li	s2,0
    if (i >= NELEM(argv))
    80006084:	02000a13          	li	s4,32
    80006088:	00090a9b          	sext.w	s5,s2
    {
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0)
    8000608c:	00391513          	slli	a0,s2,0x3
    80006090:	e3040593          	addi	a1,s0,-464
    80006094:	e3843783          	ld	a5,-456(s0)
    80006098:	953e                	add	a0,a0,a5
    8000609a:	ffffd097          	auipc	ra,0xffffd
    8000609e:	f22080e7          	jalr	-222(ra) # 80002fbc <fetchaddr>
    800060a2:	02054a63          	bltz	a0,800060d6 <sys_exec+0xa6>
    {
      goto bad;
    }
    if (uarg == 0)
    800060a6:	e3043783          	ld	a5,-464(s0)
    800060aa:	c3b9                	beqz	a5,800060f0 <sys_exec+0xc0>
    {
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800060ac:	ffffb097          	auipc	ra,0xffffb
    800060b0:	ba4080e7          	jalr	-1116(ra) # 80000c50 <kalloc>
    800060b4:	85aa                	mv	a1,a0
    800060b6:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800060ba:	cd11                	beqz	a0,800060d6 <sys_exec+0xa6>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060bc:	6605                	lui	a2,0x1
    800060be:	e3043503          	ld	a0,-464(s0)
    800060c2:	ffffd097          	auipc	ra,0xffffd
    800060c6:	f4c080e7          	jalr	-180(ra) # 8000300e <fetchstr>
    800060ca:	00054663          	bltz	a0,800060d6 <sys_exec+0xa6>
    if (i >= NELEM(argv))
    800060ce:	0905                	addi	s2,s2,1
    800060d0:	09a1                	addi	s3,s3,8
    800060d2:	fb491be3          	bne	s2,s4,80006088 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060d6:	f4040913          	addi	s2,s0,-192
    800060da:	6088                	ld	a0,0(s1)
    800060dc:	c539                	beqz	a0,8000612a <sys_exec+0xfa>
    kfree(argv[i]);
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	99a080e7          	jalr	-1638(ra) # 80000a78 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060e6:	04a1                	addi	s1,s1,8
    800060e8:	ff2499e3          	bne	s1,s2,800060da <sys_exec+0xaa>
  return -1;
    800060ec:	557d                	li	a0,-1
    800060ee:	a83d                	j	8000612c <sys_exec+0xfc>
      argv[i] = 0;
    800060f0:	0a8e                	slli	s5,s5,0x3
    800060f2:	fc0a8793          	addi	a5,s5,-64
    800060f6:	00878ab3          	add	s5,a5,s0
    800060fa:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800060fe:	e4040593          	addi	a1,s0,-448
    80006102:	f4040513          	addi	a0,s0,-192
    80006106:	fffff097          	auipc	ra,0xfffff
    8000610a:	16e080e7          	jalr	366(ra) # 80005274 <exec>
    8000610e:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006110:	f4040993          	addi	s3,s0,-192
    80006114:	6088                	ld	a0,0(s1)
    80006116:	c901                	beqz	a0,80006126 <sys_exec+0xf6>
    kfree(argv[i]);
    80006118:	ffffb097          	auipc	ra,0xffffb
    8000611c:	960080e7          	jalr	-1696(ra) # 80000a78 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006120:	04a1                	addi	s1,s1,8
    80006122:	ff3499e3          	bne	s1,s3,80006114 <sys_exec+0xe4>
  return ret;
    80006126:	854a                	mv	a0,s2
    80006128:	a011                	j	8000612c <sys_exec+0xfc>
  return -1;
    8000612a:	557d                	li	a0,-1
}
    8000612c:	60be                	ld	ra,456(sp)
    8000612e:	641e                	ld	s0,448(sp)
    80006130:	74fa                	ld	s1,440(sp)
    80006132:	795a                	ld	s2,432(sp)
    80006134:	79ba                	ld	s3,424(sp)
    80006136:	7a1a                	ld	s4,416(sp)
    80006138:	6afa                	ld	s5,408(sp)
    8000613a:	6179                	addi	sp,sp,464
    8000613c:	8082                	ret

000000008000613e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000613e:	7139                	addi	sp,sp,-64
    80006140:	fc06                	sd	ra,56(sp)
    80006142:	f822                	sd	s0,48(sp)
    80006144:	f426                	sd	s1,40(sp)
    80006146:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006148:	ffffc097          	auipc	ra,0xffffc
    8000614c:	a14080e7          	jalr	-1516(ra) # 80001b5c <myproc>
    80006150:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006152:	fd840593          	addi	a1,s0,-40
    80006156:	4501                	li	a0,0
    80006158:	ffffd097          	auipc	ra,0xffffd
    8000615c:	f22080e7          	jalr	-222(ra) # 8000307a <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80006160:	fc840593          	addi	a1,s0,-56
    80006164:	fd040513          	addi	a0,s0,-48
    80006168:	fffff097          	auipc	ra,0xfffff
    8000616c:	dc2080e7          	jalr	-574(ra) # 80004f2a <pipealloc>
    return -1;
    80006170:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80006172:	0c054463          	bltz	a0,8000623a <sys_pipe+0xfc>
  fd0 = -1;
    80006176:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0)
    8000617a:	fd043503          	ld	a0,-48(s0)
    8000617e:	fffff097          	auipc	ra,0xfffff
    80006182:	514080e7          	jalr	1300(ra) # 80005692 <fdalloc>
    80006186:	fca42223          	sw	a0,-60(s0)
    8000618a:	08054b63          	bltz	a0,80006220 <sys_pipe+0xe2>
    8000618e:	fc843503          	ld	a0,-56(s0)
    80006192:	fffff097          	auipc	ra,0xfffff
    80006196:	500080e7          	jalr	1280(ra) # 80005692 <fdalloc>
    8000619a:	fca42023          	sw	a0,-64(s0)
    8000619e:	06054863          	bltz	a0,8000620e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800061a2:	4691                	li	a3,4
    800061a4:	fc440613          	addi	a2,s0,-60
    800061a8:	fd843583          	ld	a1,-40(s0)
    800061ac:	68a8                	ld	a0,80(s1)
    800061ae:	ffffb097          	auipc	ra,0xffffb
    800061b2:	632080e7          	jalr	1586(ra) # 800017e0 <copyout>
    800061b6:	02054063          	bltz	a0,800061d6 <sys_pipe+0x98>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0)
    800061ba:	4691                	li	a3,4
    800061bc:	fc040613          	addi	a2,s0,-64
    800061c0:	fd843583          	ld	a1,-40(s0)
    800061c4:	0591                	addi	a1,a1,4
    800061c6:	68a8                	ld	a0,80(s1)
    800061c8:	ffffb097          	auipc	ra,0xffffb
    800061cc:	618080e7          	jalr	1560(ra) # 800017e0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800061d0:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800061d2:	06055463          	bgez	a0,8000623a <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800061d6:	fc442783          	lw	a5,-60(s0)
    800061da:	07e9                	addi	a5,a5,26
    800061dc:	078e                	slli	a5,a5,0x3
    800061de:	97a6                	add	a5,a5,s1
    800061e0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800061e4:	fc042783          	lw	a5,-64(s0)
    800061e8:	07e9                	addi	a5,a5,26
    800061ea:	078e                	slli	a5,a5,0x3
    800061ec:	94be                	add	s1,s1,a5
    800061ee:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800061f2:	fd043503          	ld	a0,-48(s0)
    800061f6:	fffff097          	auipc	ra,0xfffff
    800061fa:	a04080e7          	jalr	-1532(ra) # 80004bfa <fileclose>
    fileclose(wf);
    800061fe:	fc843503          	ld	a0,-56(s0)
    80006202:	fffff097          	auipc	ra,0xfffff
    80006206:	9f8080e7          	jalr	-1544(ra) # 80004bfa <fileclose>
    return -1;
    8000620a:	57fd                	li	a5,-1
    8000620c:	a03d                	j	8000623a <sys_pipe+0xfc>
    if (fd0 >= 0)
    8000620e:	fc442783          	lw	a5,-60(s0)
    80006212:	0007c763          	bltz	a5,80006220 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006216:	07e9                	addi	a5,a5,26
    80006218:	078e                	slli	a5,a5,0x3
    8000621a:	97a6                	add	a5,a5,s1
    8000621c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006220:	fd043503          	ld	a0,-48(s0)
    80006224:	fffff097          	auipc	ra,0xfffff
    80006228:	9d6080e7          	jalr	-1578(ra) # 80004bfa <fileclose>
    fileclose(wf);
    8000622c:	fc843503          	ld	a0,-56(s0)
    80006230:	fffff097          	auipc	ra,0xfffff
    80006234:	9ca080e7          	jalr	-1590(ra) # 80004bfa <fileclose>
    return -1;
    80006238:	57fd                	li	a5,-1
}
    8000623a:	853e                	mv	a0,a5
    8000623c:	70e2                	ld	ra,56(sp)
    8000623e:	7442                	ld	s0,48(sp)
    80006240:	74a2                	ld	s1,40(sp)
    80006242:	6121                	addi	sp,sp,64
    80006244:	8082                	ret
	...

0000000080006250 <kernelvec>:
    80006250:	7111                	addi	sp,sp,-256
    80006252:	e006                	sd	ra,0(sp)
    80006254:	e40a                	sd	sp,8(sp)
    80006256:	e80e                	sd	gp,16(sp)
    80006258:	ec12                	sd	tp,24(sp)
    8000625a:	f016                	sd	t0,32(sp)
    8000625c:	f41a                	sd	t1,40(sp)
    8000625e:	f81e                	sd	t2,48(sp)
    80006260:	fc22                	sd	s0,56(sp)
    80006262:	e0a6                	sd	s1,64(sp)
    80006264:	e4aa                	sd	a0,72(sp)
    80006266:	e8ae                	sd	a1,80(sp)
    80006268:	ecb2                	sd	a2,88(sp)
    8000626a:	f0b6                	sd	a3,96(sp)
    8000626c:	f4ba                	sd	a4,104(sp)
    8000626e:	f8be                	sd	a5,112(sp)
    80006270:	fcc2                	sd	a6,120(sp)
    80006272:	e146                	sd	a7,128(sp)
    80006274:	e54a                	sd	s2,136(sp)
    80006276:	e94e                	sd	s3,144(sp)
    80006278:	ed52                	sd	s4,152(sp)
    8000627a:	f156                	sd	s5,160(sp)
    8000627c:	f55a                	sd	s6,168(sp)
    8000627e:	f95e                	sd	s7,176(sp)
    80006280:	fd62                	sd	s8,184(sp)
    80006282:	e1e6                	sd	s9,192(sp)
    80006284:	e5ea                	sd	s10,200(sp)
    80006286:	e9ee                	sd	s11,208(sp)
    80006288:	edf2                	sd	t3,216(sp)
    8000628a:	f1f6                	sd	t4,224(sp)
    8000628c:	f5fa                	sd	t5,232(sp)
    8000628e:	f9fe                	sd	t6,240(sp)
    80006290:	9bbfc0ef          	jal	ra,80002c4a <kerneltrap>
    80006294:	6082                	ld	ra,0(sp)
    80006296:	6122                	ld	sp,8(sp)
    80006298:	61c2                	ld	gp,16(sp)
    8000629a:	7282                	ld	t0,32(sp)
    8000629c:	7322                	ld	t1,40(sp)
    8000629e:	73c2                	ld	t2,48(sp)
    800062a0:	7462                	ld	s0,56(sp)
    800062a2:	6486                	ld	s1,64(sp)
    800062a4:	6526                	ld	a0,72(sp)
    800062a6:	65c6                	ld	a1,80(sp)
    800062a8:	6666                	ld	a2,88(sp)
    800062aa:	7686                	ld	a3,96(sp)
    800062ac:	7726                	ld	a4,104(sp)
    800062ae:	77c6                	ld	a5,112(sp)
    800062b0:	7866                	ld	a6,120(sp)
    800062b2:	688a                	ld	a7,128(sp)
    800062b4:	692a                	ld	s2,136(sp)
    800062b6:	69ca                	ld	s3,144(sp)
    800062b8:	6a6a                	ld	s4,152(sp)
    800062ba:	7a8a                	ld	s5,160(sp)
    800062bc:	7b2a                	ld	s6,168(sp)
    800062be:	7bca                	ld	s7,176(sp)
    800062c0:	7c6a                	ld	s8,184(sp)
    800062c2:	6c8e                	ld	s9,192(sp)
    800062c4:	6d2e                	ld	s10,200(sp)
    800062c6:	6dce                	ld	s11,208(sp)
    800062c8:	6e6e                	ld	t3,216(sp)
    800062ca:	7e8e                	ld	t4,224(sp)
    800062cc:	7f2e                	ld	t5,232(sp)
    800062ce:	7fce                	ld	t6,240(sp)
    800062d0:	6111                	addi	sp,sp,256
    800062d2:	10200073          	sret
    800062d6:	00000013          	nop
    800062da:	00000013          	nop
    800062de:	0001                	nop

00000000800062e0 <timervec>:
    800062e0:	34051573          	csrrw	a0,mscratch,a0
    800062e4:	e10c                	sd	a1,0(a0)
    800062e6:	e510                	sd	a2,8(a0)
    800062e8:	e914                	sd	a3,16(a0)
    800062ea:	6d0c                	ld	a1,24(a0)
    800062ec:	7110                	ld	a2,32(a0)
    800062ee:	6194                	ld	a3,0(a1)
    800062f0:	96b2                	add	a3,a3,a2
    800062f2:	e194                	sd	a3,0(a1)
    800062f4:	4589                	li	a1,2
    800062f6:	14459073          	csrw	sip,a1
    800062fa:	6914                	ld	a3,16(a0)
    800062fc:	6510                	ld	a2,8(a0)
    800062fe:	610c                	ld	a1,0(a0)
    80006300:	34051573          	csrrw	a0,mscratch,a0
    80006304:	30200073          	mret
	...

000000008000630a <plicinit>:
//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void)
{
    8000630a:	1141                	addi	sp,sp,-16
    8000630c:	e422                	sd	s0,8(sp)
    8000630e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80006310:	0c0007b7          	lui	a5,0xc000
    80006314:	4705                	li	a4,1
    80006316:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80006318:	c3d8                	sw	a4,4(a5)
}
    8000631a:	6422                	ld	s0,8(sp)
    8000631c:	0141                	addi	sp,sp,16
    8000631e:	8082                	ret

0000000080006320 <plicinithart>:

void plicinithart(void)
{
    80006320:	1141                	addi	sp,sp,-16
    80006322:	e406                	sd	ra,8(sp)
    80006324:	e022                	sd	s0,0(sp)
    80006326:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006328:	ffffc097          	auipc	ra,0xffffc
    8000632c:	808080e7          	jalr	-2040(ra) # 80001b30 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006330:	0085171b          	slliw	a4,a0,0x8
    80006334:	0c0027b7          	lui	a5,0xc002
    80006338:	97ba                	add	a5,a5,a4
    8000633a:	40200713          	li	a4,1026
    8000633e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80006342:	00d5151b          	slliw	a0,a0,0xd
    80006346:	0c2017b7          	lui	a5,0xc201
    8000634a:	97aa                	add	a5,a5,a0
    8000634c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006350:	60a2                	ld	ra,8(sp)
    80006352:	6402                	ld	s0,0(sp)
    80006354:	0141                	addi	sp,sp,16
    80006356:	8082                	ret

0000000080006358 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void)
{
    80006358:	1141                	addi	sp,sp,-16
    8000635a:	e406                	sd	ra,8(sp)
    8000635c:	e022                	sd	s0,0(sp)
    8000635e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006360:	ffffb097          	auipc	ra,0xffffb
    80006364:	7d0080e7          	jalr	2000(ra) # 80001b30 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80006368:	00d5151b          	slliw	a0,a0,0xd
    8000636c:	0c2017b7          	lui	a5,0xc201
    80006370:	97aa                	add	a5,a5,a0
  return irq;
}
    80006372:	43c8                	lw	a0,4(a5)
    80006374:	60a2                	ld	ra,8(sp)
    80006376:	6402                	ld	s0,0(sp)
    80006378:	0141                	addi	sp,sp,16
    8000637a:	8082                	ret

000000008000637c <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq)
{
    8000637c:	1101                	addi	sp,sp,-32
    8000637e:	ec06                	sd	ra,24(sp)
    80006380:	e822                	sd	s0,16(sp)
    80006382:	e426                	sd	s1,8(sp)
    80006384:	1000                	addi	s0,sp,32
    80006386:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006388:	ffffb097          	auipc	ra,0xffffb
    8000638c:	7a8080e7          	jalr	1960(ra) # 80001b30 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80006390:	00d5151b          	slliw	a0,a0,0xd
    80006394:	0c2017b7          	lui	a5,0xc201
    80006398:	97aa                	add	a5,a5,a0
    8000639a:	c3c4                	sw	s1,4(a5)
}
    8000639c:	60e2                	ld	ra,24(sp)
    8000639e:	6442                	ld	s0,16(sp)
    800063a0:	64a2                	ld	s1,8(sp)
    800063a2:	6105                	addi	sp,sp,32
    800063a4:	8082                	ret

00000000800063a6 <sgenrand>:
static unsigned long mt[N]; /* the array for the state vector  */
static int mti = N + 1;     /* mti==N+1 means mt[N] is not initialized */

/* initializing the array with a NONZERO seed */
void sgenrand(unsigned long seed)
{
    800063a6:	1141                	addi	sp,sp,-16
    800063a8:	e422                	sd	s0,8(sp)
    800063aa:	0800                	addi	s0,sp,16
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0] = seed & 0xffffffff;
    800063ac:	0023e717          	auipc	a4,0x23e
    800063b0:	ae470713          	addi	a4,a4,-1308 # 80243e90 <mt>
    800063b4:	1502                	slli	a0,a0,0x20
    800063b6:	9101                	srli	a0,a0,0x20
    800063b8:	e308                	sd	a0,0(a4)
    for (mti = 1; mti < N; mti++)
    800063ba:	0023f597          	auipc	a1,0x23f
    800063be:	e4e58593          	addi	a1,a1,-434 # 80245208 <mt+0x1378>
        mt[mti] = (69069 * mt[mti - 1]) & 0xffffffff;
    800063c2:	6645                	lui	a2,0x11
    800063c4:	dcd60613          	addi	a2,a2,-563 # 10dcd <_entry-0x7ffef233>
    800063c8:	56fd                	li	a3,-1
    800063ca:	9281                	srli	a3,a3,0x20
    800063cc:	631c                	ld	a5,0(a4)
    800063ce:	02c787b3          	mul	a5,a5,a2
    800063d2:	8ff5                	and	a5,a5,a3
    800063d4:	e71c                	sd	a5,8(a4)
    for (mti = 1; mti < N; mti++)
    800063d6:	0721                	addi	a4,a4,8
    800063d8:	feb71ae3          	bne	a4,a1,800063cc <sgenrand+0x26>
    800063dc:	27000793          	li	a5,624
    800063e0:	00002717          	auipc	a4,0x2
    800063e4:	5cf72c23          	sw	a5,1496(a4) # 800089b8 <mti>
}
    800063e8:	6422                	ld	s0,8(sp)
    800063ea:	0141                	addi	sp,sp,16
    800063ec:	8082                	ret

00000000800063ee <genrand>:

long /* for integer generation */
genrand()
{
    800063ee:	1141                	addi	sp,sp,-16
    800063f0:	e406                	sd	ra,8(sp)
    800063f2:	e022                	sd	s0,0(sp)
    800063f4:	0800                	addi	s0,sp,16
    unsigned long y;
    static unsigned long mag01[2] = {0x0, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N)
    800063f6:	00002797          	auipc	a5,0x2
    800063fa:	5c27a783          	lw	a5,1474(a5) # 800089b8 <mti>
    800063fe:	26f00713          	li	a4,623
    80006402:	0ef75963          	bge	a4,a5,800064f4 <genrand+0x106>
    { /* generate N words at one time */
        int kk;

        if (mti == N + 1)   /* if sgenrand() has not been called, */
    80006406:	27100713          	li	a4,625
    8000640a:	12e78e63          	beq	a5,a4,80006546 <genrand+0x158>
            sgenrand(4357); /* a default initial seed is used   */

        for (kk = 0; kk < N - M; kk++)
    8000640e:	0023e817          	auipc	a6,0x23e
    80006412:	a8280813          	addi	a6,a6,-1406 # 80243e90 <mt>
    80006416:	0023ee17          	auipc	t3,0x23e
    8000641a:	192e0e13          	addi	t3,t3,402 # 802445a8 <mt+0x718>
{
    8000641e:	8742                	mv	a4,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    80006420:	4885                	li	a7,1
    80006422:	08fe                	slli	a7,a7,0x1f
    80006424:	80000537          	lui	a0,0x80000
    80006428:	fff54513          	not	a0,a0
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    8000642c:	6585                	lui	a1,0x1
    8000642e:	c6858593          	addi	a1,a1,-920 # c68 <_entry-0x7ffff398>
    80006432:	00002317          	auipc	t1,0x2
    80006436:	46630313          	addi	t1,t1,1126 # 80008898 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    8000643a:	631c                	ld	a5,0(a4)
    8000643c:	0117f7b3          	and	a5,a5,a7
    80006440:	6714                	ld	a3,8(a4)
    80006442:	8ee9                	and	a3,a3,a0
    80006444:	8fd5                	or	a5,a5,a3
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
    80006446:	00b70633          	add	a2,a4,a1
    8000644a:	0017d693          	srli	a3,a5,0x1
    8000644e:	6210                	ld	a2,0(a2)
    80006450:	8eb1                	xor	a3,a3,a2
    80006452:	8b85                	andi	a5,a5,1
    80006454:	078e                	slli	a5,a5,0x3
    80006456:	979a                	add	a5,a5,t1
    80006458:	639c                	ld	a5,0(a5)
    8000645a:	8fb5                	xor	a5,a5,a3
    8000645c:	e31c                	sd	a5,0(a4)
        for (kk = 0; kk < N - M; kk++)
    8000645e:	0721                	addi	a4,a4,8
    80006460:	fdc71de3          	bne	a4,t3,8000643a <genrand+0x4c>
        }
        for (; kk < N - 1; kk++)
    80006464:	6605                	lui	a2,0x1
    80006466:	c6060613          	addi	a2,a2,-928 # c60 <_entry-0x7ffff3a0>
    8000646a:	9642                	add	a2,a2,a6
        {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    8000646c:	4505                	li	a0,1
    8000646e:	057e                	slli	a0,a0,0x1f
    80006470:	800005b7          	lui	a1,0x80000
    80006474:	fff5c593          	not	a1,a1
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    80006478:	00002897          	auipc	a7,0x2
    8000647c:	42088893          	addi	a7,a7,1056 # 80008898 <mag01.0>
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
    80006480:	71883783          	ld	a5,1816(a6)
    80006484:	8fe9                	and	a5,a5,a0
    80006486:	72083703          	ld	a4,1824(a6)
    8000648a:	8f6d                	and	a4,a4,a1
    8000648c:	8fd9                	or	a5,a5,a4
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1];
    8000648e:	0017d713          	srli	a4,a5,0x1
    80006492:	00083683          	ld	a3,0(a6)
    80006496:	8f35                	xor	a4,a4,a3
    80006498:	8b85                	andi	a5,a5,1
    8000649a:	078e                	slli	a5,a5,0x3
    8000649c:	97c6                	add	a5,a5,a7
    8000649e:	639c                	ld	a5,0(a5)
    800064a0:	8fb9                	xor	a5,a5,a4
    800064a2:	70f83c23          	sd	a5,1816(a6)
        for (; kk < N - 1; kk++)
    800064a6:	0821                	addi	a6,a6,8
    800064a8:	fcc81ce3          	bne	a6,a2,80006480 <genrand+0x92>
        }
        y = (mt[N - 1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
    800064ac:	0023f697          	auipc	a3,0x23f
    800064b0:	9e468693          	addi	a3,a3,-1564 # 80244e90 <mt+0x1000>
    800064b4:	3786b783          	ld	a5,888(a3)
    800064b8:	4705                	li	a4,1
    800064ba:	077e                	slli	a4,a4,0x1f
    800064bc:	8ff9                	and	a5,a5,a4
    800064be:	0023e717          	auipc	a4,0x23e
    800064c2:	9d273703          	ld	a4,-1582(a4) # 80243e90 <mt>
    800064c6:	1706                	slli	a4,a4,0x21
    800064c8:	9305                	srli	a4,a4,0x21
    800064ca:	8fd9                	or	a5,a5,a4
        mt[N - 1] = mt[M - 1] ^ (y >> 1) ^ mag01[y & 0x1];
    800064cc:	0017d713          	srli	a4,a5,0x1
    800064d0:	c606b603          	ld	a2,-928(a3)
    800064d4:	8f31                	xor	a4,a4,a2
    800064d6:	8b85                	andi	a5,a5,1
    800064d8:	078e                	slli	a5,a5,0x3
    800064da:	00002617          	auipc	a2,0x2
    800064de:	3be60613          	addi	a2,a2,958 # 80008898 <mag01.0>
    800064e2:	97b2                	add	a5,a5,a2
    800064e4:	639c                	ld	a5,0(a5)
    800064e6:	8fb9                	xor	a5,a5,a4
    800064e8:	36f6bc23          	sd	a5,888(a3)

        mti = 0;
    800064ec:	00002797          	auipc	a5,0x2
    800064f0:	4c07a623          	sw	zero,1228(a5) # 800089b8 <mti>
    }

    y = mt[mti++];
    800064f4:	00002717          	auipc	a4,0x2
    800064f8:	4c470713          	addi	a4,a4,1220 # 800089b8 <mti>
    800064fc:	431c                	lw	a5,0(a4)
    800064fe:	0017869b          	addiw	a3,a5,1
    80006502:	c314                	sw	a3,0(a4)
    80006504:	078e                	slli	a5,a5,0x3
    80006506:	0023e717          	auipc	a4,0x23e
    8000650a:	98a70713          	addi	a4,a4,-1654 # 80243e90 <mt>
    8000650e:	97ba                	add	a5,a5,a4
    80006510:	639c                	ld	a5,0(a5)
    y ^= TEMPERING_SHIFT_U(y);
    80006512:	00b7d713          	srli	a4,a5,0xb
    80006516:	8f3d                	xor	a4,a4,a5
    y ^= TEMPERING_SHIFT_S(y) & TEMPERING_MASK_B;
    80006518:	013a67b7          	lui	a5,0x13a6
    8000651c:	8ad78793          	addi	a5,a5,-1875 # 13a58ad <_entry-0x7ec5a753>
    80006520:	8ff9                	and	a5,a5,a4
    80006522:	079e                	slli	a5,a5,0x7
    80006524:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_T(y) & TEMPERING_MASK_C;
    80006526:	00f79713          	slli	a4,a5,0xf
    8000652a:	077e36b7          	lui	a3,0x77e3
    8000652e:	0696                	slli	a3,a3,0x5
    80006530:	8f75                	and	a4,a4,a3
    80006532:	8fb9                	xor	a5,a5,a4
    y ^= TEMPERING_SHIFT_L(y);
    80006534:	0127d513          	srli	a0,a5,0x12
    80006538:	8d3d                	xor	a0,a0,a5

    // Strip off uppermost bit because we want a long,
    // not an unsigned long
    return y & RAND_MAX;
    8000653a:	1506                	slli	a0,a0,0x21
}
    8000653c:	9105                	srli	a0,a0,0x21
    8000653e:	60a2                	ld	ra,8(sp)
    80006540:	6402                	ld	s0,0(sp)
    80006542:	0141                	addi	sp,sp,16
    80006544:	8082                	ret
            sgenrand(4357); /* a default initial seed is used   */
    80006546:	6505                	lui	a0,0x1
    80006548:	10550513          	addi	a0,a0,261 # 1105 <_entry-0x7fffeefb>
    8000654c:	00000097          	auipc	ra,0x0
    80006550:	e5a080e7          	jalr	-422(ra) # 800063a6 <sgenrand>
    80006554:	bd6d                	j	8000640e <genrand+0x20>

0000000080006556 <random_at_most>:

// Assumes 0 <= max <= RAND_MAX
// Returns in the half-open interval [0, max]
long random_at_most(long max)
{
    80006556:	1101                	addi	sp,sp,-32
    80006558:	ec06                	sd	ra,24(sp)
    8000655a:	e822                	sd	s0,16(sp)
    8000655c:	e426                	sd	s1,8(sp)
    8000655e:	e04a                	sd	s2,0(sp)
    80006560:	1000                	addi	s0,sp,32
    unsigned long
        // max <= RAND_MAX < ULONG_MAX, so this is okay.
        num_bins = (unsigned long)max + 1,
    80006562:	0505                	addi	a0,a0,1
        num_rand = (unsigned long)RAND_MAX + 1,
        bin_size = num_rand / num_bins,
    80006564:	4785                	li	a5,1
    80006566:	07fe                	slli	a5,a5,0x1f
    80006568:	02a7d933          	divu	s2,a5,a0
        defect = num_rand % num_bins;
    8000656c:	02a7f7b3          	remu	a5,a5,a0
    do
    {
        x = genrand();
    }
    // This is carefully written not to overflow
    while (num_rand - defect <= (unsigned long)x);
    80006570:	4485                	li	s1,1
    80006572:	04fe                	slli	s1,s1,0x1f
    80006574:	8c9d                	sub	s1,s1,a5
        x = genrand();
    80006576:	00000097          	auipc	ra,0x0
    8000657a:	e78080e7          	jalr	-392(ra) # 800063ee <genrand>
    while (num_rand - defect <= (unsigned long)x);
    8000657e:	fe957ce3          	bgeu	a0,s1,80006576 <random_at_most+0x20>

    // Truncated division is intentional
    return x / bin_size;
    80006582:	03255533          	divu	a0,a0,s2
    80006586:	60e2                	ld	ra,24(sp)
    80006588:	6442                	ld	s0,16(sp)
    8000658a:	64a2                	ld	s1,8(sp)
    8000658c:	6902                	ld	s2,0(sp)
    8000658e:	6105                	addi	sp,sp,32
    80006590:	8082                	ret

0000000080006592 <popfront>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void popfront(deque *a)
{
    80006592:	1141                	addi	sp,sp,-16
    80006594:	e422                	sd	s0,8(sp)
    80006596:	0800                	addi	s0,sp,16
    for (int i = 0; i < a->end - 1; i++)
    80006598:	20052683          	lw	a3,512(a0)
    8000659c:	fff6861b          	addiw	a2,a3,-1 # 77e2fff <_entry-0x7881d001>
    800065a0:	0006079b          	sext.w	a5,a2
    800065a4:	cf99                	beqz	a5,800065c2 <popfront+0x30>
    800065a6:	87aa                	mv	a5,a0
    800065a8:	36f9                	addiw	a3,a3,-2
    800065aa:	02069713          	slli	a4,a3,0x20
    800065ae:	01d75693          	srli	a3,a4,0x1d
    800065b2:	00850713          	addi	a4,a0,8
    800065b6:	96ba                	add	a3,a3,a4
    {
        a->n[i] = a->n[i + 1];
    800065b8:	6798                	ld	a4,8(a5)
    800065ba:	e398                	sd	a4,0(a5)
    for (int i = 0; i < a->end - 1; i++)
    800065bc:	07a1                	addi	a5,a5,8
    800065be:	fed79de3          	bne	a5,a3,800065b8 <popfront+0x26>
    }
    a->end--;
    800065c2:	20c52023          	sw	a2,512(a0)
    return;
}
    800065c6:	6422                	ld	s0,8(sp)
    800065c8:	0141                	addi	sp,sp,16
    800065ca:	8082                	ret

00000000800065cc <pushback>:
void pushback(deque *a, struct proc *x)
{
    if (a->end == NPROC)
    800065cc:	20052783          	lw	a5,512(a0)
    800065d0:	04000713          	li	a4,64
    800065d4:	00e78c63          	beq	a5,a4,800065ec <pushback+0x20>
    {
        panic("Error!");
        return;
    }
    a->n[a->end] = x;
    800065d8:	02079693          	slli	a3,a5,0x20
    800065dc:	01d6d713          	srli	a4,a3,0x1d
    800065e0:	972a                	add	a4,a4,a0
    800065e2:	e30c                	sd	a1,0(a4)
    a->end++;
    800065e4:	2785                	addiw	a5,a5,1
    800065e6:	20f52023          	sw	a5,512(a0)
    800065ea:	8082                	ret
{
    800065ec:	1141                	addi	sp,sp,-16
    800065ee:	e406                	sd	ra,8(sp)
    800065f0:	e022                	sd	s0,0(sp)
    800065f2:	0800                	addi	s0,sp,16
        panic("Error!");
    800065f4:	00002517          	auipc	a0,0x2
    800065f8:	2b450513          	addi	a0,a0,692 # 800088a8 <mag01.0+0x10>
    800065fc:	ffffa097          	auipc	ra,0xffffa
    80006600:	f44080e7          	jalr	-188(ra) # 80000540 <panic>

0000000080006604 <front>:
    return;
}
struct proc *front(deque *a)
{
    80006604:	1141                	addi	sp,sp,-16
    80006606:	e422                	sd	s0,8(sp)
    80006608:	0800                	addi	s0,sp,16
    if (a->end == 0)
    8000660a:	20052783          	lw	a5,512(a0)
    8000660e:	c789                	beqz	a5,80006618 <front+0x14>
    {
        return 0;
    }
    return a->n[0];
    80006610:	6108                	ld	a0,0(a0)
}
    80006612:	6422                	ld	s0,8(sp)
    80006614:	0141                	addi	sp,sp,16
    80006616:	8082                	ret
        return 0;
    80006618:	4501                	li	a0,0
    8000661a:	bfe5                	j	80006612 <front+0xe>

000000008000661c <size>:
int size(deque *a)
{
    8000661c:	1141                	addi	sp,sp,-16
    8000661e:	e422                	sd	s0,8(sp)
    80006620:	0800                	addi	s0,sp,16
    return a->end;
}
    80006622:	20052503          	lw	a0,512(a0)
    80006626:	6422                	ld	s0,8(sp)
    80006628:	0141                	addi	sp,sp,16
    8000662a:	8082                	ret

000000008000662c <delete>:
void delete (deque *a, uint pid)
{
    8000662c:	1141                	addi	sp,sp,-16
    8000662e:	e422                	sd	s0,8(sp)
    80006630:	0800                	addi	s0,sp,16
    int flag = 0;
    for (int i = 0; i < a->end; i++)
    80006632:	20052e03          	lw	t3,512(a0)
    80006636:	020e0c63          	beqz	t3,8000666e <delete+0x42>
    8000663a:	87aa                	mv	a5,a0
    8000663c:	000e031b          	sext.w	t1,t3
    80006640:	4701                	li	a4,0
    int flag = 0;
    80006642:	4881                	li	a7,0
    {
        if (pid == a->n[i]->pid)
        {
            flag = 1;
        }
        if (flag == 1 && i != NPROC)
    80006644:	04000e93          	li	t4,64
    80006648:	4805                	li	a6,1
    8000664a:	a811                	j	8000665e <delete+0x32>
    8000664c:	88c2                	mv	a7,a6
    8000664e:	01d70463          	beq	a4,t4,80006656 <delete+0x2a>
        {
            a->n[i] = a->n[i + 1];
    80006652:	6614                	ld	a3,8(a2)
    80006654:	e214                	sd	a3,0(a2)
    for (int i = 0; i < a->end; i++)
    80006656:	2705                	addiw	a4,a4,1
    80006658:	07a1                	addi	a5,a5,8
    8000665a:	00670a63          	beq	a4,t1,8000666e <delete+0x42>
        if (pid == a->n[i]->pid)
    8000665e:	863e                	mv	a2,a5
    80006660:	6394                	ld	a3,0(a5)
    80006662:	5a94                	lw	a3,48(a3)
    80006664:	feb684e3          	beq	a3,a1,8000664c <delete+0x20>
        if (flag == 1 && i != NPROC)
    80006668:	ff0897e3          	bne	a7,a6,80006656 <delete+0x2a>
    8000666c:	b7c5                	j	8000664c <delete+0x20>
        }
    }
    a->end--;
    8000666e:	3e7d                	addiw	t3,t3,-1
    80006670:	21c52023          	sw	t3,512(a0)
    return;
    80006674:	6422                	ld	s0,8(sp)
    80006676:	0141                	addi	sp,sp,16
    80006678:	8082                	ret

000000008000667a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000667a:	1141                	addi	sp,sp,-16
    8000667c:	e406                	sd	ra,8(sp)
    8000667e:	e022                	sd	s0,0(sp)
    80006680:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80006682:	479d                	li	a5,7
    80006684:	04a7cc63          	blt	a5,a0,800066dc <free_desc+0x62>
    panic("free_desc 1");
  if (disk.free[i])
    80006688:	0023f797          	auipc	a5,0x23f
    8000668c:	b8878793          	addi	a5,a5,-1144 # 80245210 <disk>
    80006690:	97aa                	add	a5,a5,a0
    80006692:	0187c783          	lbu	a5,24(a5)
    80006696:	ebb9                	bnez	a5,800066ec <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006698:	00451693          	slli	a3,a0,0x4
    8000669c:	0023f797          	auipc	a5,0x23f
    800066a0:	b7478793          	addi	a5,a5,-1164 # 80245210 <disk>
    800066a4:	6398                	ld	a4,0(a5)
    800066a6:	9736                	add	a4,a4,a3
    800066a8:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800066ac:	6398                	ld	a4,0(a5)
    800066ae:	9736                	add	a4,a4,a3
    800066b0:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800066b4:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800066b8:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800066bc:	97aa                	add	a5,a5,a0
    800066be:	4705                	li	a4,1
    800066c0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800066c4:	0023f517          	auipc	a0,0x23f
    800066c8:	b6450513          	addi	a0,a0,-1180 # 80245228 <disk+0x18>
    800066cc:	ffffc097          	auipc	ra,0xffffc
    800066d0:	dea080e7          	jalr	-534(ra) # 800024b6 <wakeup>
}
    800066d4:	60a2                	ld	ra,8(sp)
    800066d6:	6402                	ld	s0,0(sp)
    800066d8:	0141                	addi	sp,sp,16
    800066da:	8082                	ret
    panic("free_desc 1");
    800066dc:	00002517          	auipc	a0,0x2
    800066e0:	1d450513          	addi	a0,a0,468 # 800088b0 <mag01.0+0x18>
    800066e4:	ffffa097          	auipc	ra,0xffffa
    800066e8:	e5c080e7          	jalr	-420(ra) # 80000540 <panic>
    panic("free_desc 2");
    800066ec:	00002517          	auipc	a0,0x2
    800066f0:	1d450513          	addi	a0,a0,468 # 800088c0 <mag01.0+0x28>
    800066f4:	ffffa097          	auipc	ra,0xffffa
    800066f8:	e4c080e7          	jalr	-436(ra) # 80000540 <panic>

00000000800066fc <virtio_disk_init>:
{
    800066fc:	1101                	addi	sp,sp,-32
    800066fe:	ec06                	sd	ra,24(sp)
    80006700:	e822                	sd	s0,16(sp)
    80006702:	e426                	sd	s1,8(sp)
    80006704:	e04a                	sd	s2,0(sp)
    80006706:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006708:	00002597          	auipc	a1,0x2
    8000670c:	1c858593          	addi	a1,a1,456 # 800088d0 <mag01.0+0x38>
    80006710:	0023f517          	auipc	a0,0x23f
    80006714:	c2850513          	addi	a0,a0,-984 # 80245338 <disk+0x128>
    80006718:	ffffa097          	auipc	ra,0xffffa
    8000671c:	5a2080e7          	jalr	1442(ra) # 80000cba <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006720:	100017b7          	lui	a5,0x10001
    80006724:	4398                	lw	a4,0(a5)
    80006726:	2701                	sext.w	a4,a4
    80006728:	747277b7          	lui	a5,0x74727
    8000672c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006730:	14f71b63          	bne	a4,a5,80006886 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006734:	100017b7          	lui	a5,0x10001
    80006738:	43dc                	lw	a5,4(a5)
    8000673a:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000673c:	4709                	li	a4,2
    8000673e:	14e79463          	bne	a5,a4,80006886 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006742:	100017b7          	lui	a5,0x10001
    80006746:	479c                	lw	a5,8(a5)
    80006748:	2781                	sext.w	a5,a5
      *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000674a:	12e79e63          	bne	a5,a4,80006886 <virtio_disk_init+0x18a>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551)
    8000674e:	100017b7          	lui	a5,0x10001
    80006752:	47d8                	lw	a4,12(a5)
    80006754:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006756:	554d47b7          	lui	a5,0x554d4
    8000675a:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000675e:	12f71463          	bne	a4,a5,80006886 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006762:	100017b7          	lui	a5,0x10001
    80006766:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000676a:	4705                	li	a4,1
    8000676c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000676e:	470d                	li	a4,3
    80006770:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006772:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006774:	c7ffe6b7          	lui	a3,0xc7ffe
    80006778:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db940f>
    8000677c:	8f75                	and	a4,a4,a3
    8000677e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006780:	472d                	li	a4,11
    80006782:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006784:	5bbc                	lw	a5,112(a5)
    80006786:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000678a:	8ba1                	andi	a5,a5,8
    8000678c:	10078563          	beqz	a5,80006896 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006790:	100017b7          	lui	a5,0x10001
    80006794:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80006798:	43fc                	lw	a5,68(a5)
    8000679a:	2781                	sext.w	a5,a5
    8000679c:	10079563          	bnez	a5,800068a6 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800067a0:	100017b7          	lui	a5,0x10001
    800067a4:	5bdc                	lw	a5,52(a5)
    800067a6:	2781                	sext.w	a5,a5
  if (max == 0)
    800067a8:	10078763          	beqz	a5,800068b6 <virtio_disk_init+0x1ba>
  if (max < NUM)
    800067ac:	471d                	li	a4,7
    800067ae:	10f77c63          	bgeu	a4,a5,800068c6 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800067b2:	ffffa097          	auipc	ra,0xffffa
    800067b6:	49e080e7          	jalr	1182(ra) # 80000c50 <kalloc>
    800067ba:	0023f497          	auipc	s1,0x23f
    800067be:	a5648493          	addi	s1,s1,-1450 # 80245210 <disk>
    800067c2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800067c4:	ffffa097          	auipc	ra,0xffffa
    800067c8:	48c080e7          	jalr	1164(ra) # 80000c50 <kalloc>
    800067cc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800067ce:	ffffa097          	auipc	ra,0xffffa
    800067d2:	482080e7          	jalr	1154(ra) # 80000c50 <kalloc>
    800067d6:	87aa                	mv	a5,a0
    800067d8:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800067da:	6088                	ld	a0,0(s1)
    800067dc:	cd6d                	beqz	a0,800068d6 <virtio_disk_init+0x1da>
    800067de:	0023f717          	auipc	a4,0x23f
    800067e2:	a3a73703          	ld	a4,-1478(a4) # 80245218 <disk+0x8>
    800067e6:	cb65                	beqz	a4,800068d6 <virtio_disk_init+0x1da>
    800067e8:	c7fd                	beqz	a5,800068d6 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800067ea:	6605                	lui	a2,0x1
    800067ec:	4581                	li	a1,0
    800067ee:	ffffa097          	auipc	ra,0xffffa
    800067f2:	658080e7          	jalr	1624(ra) # 80000e46 <memset>
  memset(disk.avail, 0, PGSIZE);
    800067f6:	0023f497          	auipc	s1,0x23f
    800067fa:	a1a48493          	addi	s1,s1,-1510 # 80245210 <disk>
    800067fe:	6605                	lui	a2,0x1
    80006800:	4581                	li	a1,0
    80006802:	6488                	ld	a0,8(s1)
    80006804:	ffffa097          	auipc	ra,0xffffa
    80006808:	642080e7          	jalr	1602(ra) # 80000e46 <memset>
  memset(disk.used, 0, PGSIZE);
    8000680c:	6605                	lui	a2,0x1
    8000680e:	4581                	li	a1,0
    80006810:	6888                	ld	a0,16(s1)
    80006812:	ffffa097          	auipc	ra,0xffffa
    80006816:	634080e7          	jalr	1588(ra) # 80000e46 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000681a:	100017b7          	lui	a5,0x10001
    8000681e:	4721                	li	a4,8
    80006820:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006822:	4098                	lw	a4,0(s1)
    80006824:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006828:	40d8                	lw	a4,4(s1)
    8000682a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000682e:	6498                	ld	a4,8(s1)
    80006830:	0007069b          	sext.w	a3,a4
    80006834:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006838:	9701                	srai	a4,a4,0x20
    8000683a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000683e:	6898                	ld	a4,16(s1)
    80006840:	0007069b          	sext.w	a3,a4
    80006844:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006848:	9701                	srai	a4,a4,0x20
    8000684a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000684e:	4705                	li	a4,1
    80006850:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006852:	00e48c23          	sb	a4,24(s1)
    80006856:	00e48ca3          	sb	a4,25(s1)
    8000685a:	00e48d23          	sb	a4,26(s1)
    8000685e:	00e48da3          	sb	a4,27(s1)
    80006862:	00e48e23          	sb	a4,28(s1)
    80006866:	00e48ea3          	sb	a4,29(s1)
    8000686a:	00e48f23          	sb	a4,30(s1)
    8000686e:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006872:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006876:	0727a823          	sw	s2,112(a5)
}
    8000687a:	60e2                	ld	ra,24(sp)
    8000687c:	6442                	ld	s0,16(sp)
    8000687e:	64a2                	ld	s1,8(sp)
    80006880:	6902                	ld	s2,0(sp)
    80006882:	6105                	addi	sp,sp,32
    80006884:	8082                	ret
    panic("could not find virtio disk");
    80006886:	00002517          	auipc	a0,0x2
    8000688a:	05a50513          	addi	a0,a0,90 # 800088e0 <mag01.0+0x48>
    8000688e:	ffffa097          	auipc	ra,0xffffa
    80006892:	cb2080e7          	jalr	-846(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006896:	00002517          	auipc	a0,0x2
    8000689a:	06a50513          	addi	a0,a0,106 # 80008900 <mag01.0+0x68>
    8000689e:	ffffa097          	auipc	ra,0xffffa
    800068a2:	ca2080e7          	jalr	-862(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    800068a6:	00002517          	auipc	a0,0x2
    800068aa:	07a50513          	addi	a0,a0,122 # 80008920 <mag01.0+0x88>
    800068ae:	ffffa097          	auipc	ra,0xffffa
    800068b2:	c92080e7          	jalr	-878(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    800068b6:	00002517          	auipc	a0,0x2
    800068ba:	08a50513          	addi	a0,a0,138 # 80008940 <mag01.0+0xa8>
    800068be:	ffffa097          	auipc	ra,0xffffa
    800068c2:	c82080e7          	jalr	-894(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    800068c6:	00002517          	auipc	a0,0x2
    800068ca:	09a50513          	addi	a0,a0,154 # 80008960 <mag01.0+0xc8>
    800068ce:	ffffa097          	auipc	ra,0xffffa
    800068d2:	c72080e7          	jalr	-910(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800068d6:	00002517          	auipc	a0,0x2
    800068da:	0aa50513          	addi	a0,a0,170 # 80008980 <mag01.0+0xe8>
    800068de:	ffffa097          	auipc	ra,0xffffa
    800068e2:	c62080e7          	jalr	-926(ra) # 80000540 <panic>

00000000800068e6 <virtio_disk_rw>:
  }
  return 0;
}

void virtio_disk_rw(struct buf *b, int write)
{
    800068e6:	7119                	addi	sp,sp,-128
    800068e8:	fc86                	sd	ra,120(sp)
    800068ea:	f8a2                	sd	s0,112(sp)
    800068ec:	f4a6                	sd	s1,104(sp)
    800068ee:	f0ca                	sd	s2,96(sp)
    800068f0:	ecce                	sd	s3,88(sp)
    800068f2:	e8d2                	sd	s4,80(sp)
    800068f4:	e4d6                	sd	s5,72(sp)
    800068f6:	e0da                	sd	s6,64(sp)
    800068f8:	fc5e                	sd	s7,56(sp)
    800068fa:	f862                	sd	s8,48(sp)
    800068fc:	f466                	sd	s9,40(sp)
    800068fe:	f06a                	sd	s10,32(sp)
    80006900:	ec6e                	sd	s11,24(sp)
    80006902:	0100                	addi	s0,sp,128
    80006904:	8aaa                	mv	s5,a0
    80006906:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006908:	00c52d03          	lw	s10,12(a0)
    8000690c:	001d1d1b          	slliw	s10,s10,0x1
    80006910:	1d02                	slli	s10,s10,0x20
    80006912:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006916:	0023f517          	auipc	a0,0x23f
    8000691a:	a2250513          	addi	a0,a0,-1502 # 80245338 <disk+0x128>
    8000691e:	ffffa097          	auipc	ra,0xffffa
    80006922:	42c080e7          	jalr	1068(ra) # 80000d4a <acquire>
  for (int i = 0; i < 3; i++)
    80006926:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++)
    80006928:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000692a:	0023fb97          	auipc	s7,0x23f
    8000692e:	8e6b8b93          	addi	s7,s7,-1818 # 80245210 <disk>
  for (int i = 0; i < 3; i++)
    80006932:	4b0d                	li	s6,3
  {
    if (alloc3_desc(idx) == 0)
    {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006934:	0023fc97          	auipc	s9,0x23f
    80006938:	a04c8c93          	addi	s9,s9,-1532 # 80245338 <disk+0x128>
    8000693c:	a08d                	j	8000699e <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000693e:	00fb8733          	add	a4,s7,a5
    80006942:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006946:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0)
    80006948:	0207c563          	bltz	a5,80006972 <virtio_disk_rw+0x8c>
  for (int i = 0; i < 3; i++)
    8000694c:	2905                	addiw	s2,s2,1
    8000694e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006950:	05690c63          	beq	s2,s6,800069a8 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006954:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++)
    80006956:	0023f717          	auipc	a4,0x23f
    8000695a:	8ba70713          	addi	a4,a4,-1862 # 80245210 <disk>
    8000695e:	87ce                	mv	a5,s3
    if (disk.free[i])
    80006960:	01874683          	lbu	a3,24(a4)
    80006964:	fee9                	bnez	a3,8000693e <virtio_disk_rw+0x58>
  for (int i = 0; i < NUM; i++)
    80006966:	2785                	addiw	a5,a5,1
    80006968:	0705                	addi	a4,a4,1
    8000696a:	fe979be3          	bne	a5,s1,80006960 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000696e:	57fd                	li	a5,-1
    80006970:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80006972:	01205d63          	blez	s2,8000698c <virtio_disk_rw+0xa6>
    80006976:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006978:	000a2503          	lw	a0,0(s4)
    8000697c:	00000097          	auipc	ra,0x0
    80006980:	cfe080e7          	jalr	-770(ra) # 8000667a <free_desc>
      for (int j = 0; j < i; j++)
    80006984:	2d85                	addiw	s11,s11,1
    80006986:	0a11                	addi	s4,s4,4
    80006988:	ff2d98e3          	bne	s11,s2,80006978 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000698c:	85e6                	mv	a1,s9
    8000698e:	0023f517          	auipc	a0,0x23f
    80006992:	89a50513          	addi	a0,a0,-1894 # 80245228 <disk+0x18>
    80006996:	ffffc097          	auipc	ra,0xffffc
    8000699a:	964080e7          	jalr	-1692(ra) # 800022fa <sleep>
  for (int i = 0; i < 3; i++)
    8000699e:	f8040a13          	addi	s4,s0,-128
{
    800069a2:	8652                	mv	a2,s4
  for (int i = 0; i < 3; i++)
    800069a4:	894e                	mv	s2,s3
    800069a6:	b77d                	j	80006954 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800069a8:	f8042503          	lw	a0,-128(s0)
    800069ac:	00a50713          	addi	a4,a0,10
    800069b0:	0712                	slli	a4,a4,0x4

  if (write)
    800069b2:	0023f797          	auipc	a5,0x23f
    800069b6:	85e78793          	addi	a5,a5,-1954 # 80245210 <disk>
    800069ba:	00e786b3          	add	a3,a5,a4
    800069be:	01803633          	snez	a2,s8
    800069c2:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800069c4:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800069c8:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64)buf0;
    800069cc:	f6070613          	addi	a2,a4,-160
    800069d0:	6394                	ld	a3,0(a5)
    800069d2:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800069d4:	00870593          	addi	a1,a4,8
    800069d8:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    800069da:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800069dc:	0007b803          	ld	a6,0(a5)
    800069e0:	9642                	add	a2,a2,a6
    800069e2:	46c1                	li	a3,16
    800069e4:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800069e6:	4585                	li	a1,1
    800069e8:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800069ec:	f8442683          	lw	a3,-124(s0)
    800069f0:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64)b->data;
    800069f4:	0692                	slli	a3,a3,0x4
    800069f6:	9836                	add	a6,a6,a3
    800069f8:	058a8613          	addi	a2,s5,88
    800069fc:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006a00:	0007b803          	ld	a6,0(a5)
    80006a04:	96c2                	add	a3,a3,a6
    80006a06:	40000613          	li	a2,1024
    80006a0a:	c690                	sw	a2,8(a3)
  if (write)
    80006a0c:	001c3613          	seqz	a2,s8
    80006a10:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006a14:	00166613          	ori	a2,a2,1
    80006a18:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006a1c:	f8842603          	lw	a2,-120(s0)
    80006a20:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006a24:	00250693          	addi	a3,a0,2
    80006a28:	0692                	slli	a3,a3,0x4
    80006a2a:	96be                	add	a3,a3,a5
    80006a2c:	58fd                	li	a7,-1
    80006a2e:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80006a32:	0612                	slli	a2,a2,0x4
    80006a34:	9832                	add	a6,a6,a2
    80006a36:	f9070713          	addi	a4,a4,-112
    80006a3a:	973e                	add	a4,a4,a5
    80006a3c:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006a40:	6398                	ld	a4,0(a5)
    80006a42:	9732                	add	a4,a4,a2
    80006a44:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006a46:	4609                	li	a2,2
    80006a48:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006a4c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006a50:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006a54:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006a58:	6794                	ld	a3,8(a5)
    80006a5a:	0026d703          	lhu	a4,2(a3)
    80006a5e:	8b1d                	andi	a4,a4,7
    80006a60:	0706                	slli	a4,a4,0x1
    80006a62:	96ba                	add	a3,a3,a4
    80006a64:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006a68:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006a6c:	6798                	ld	a4,8(a5)
    80006a6e:	00275783          	lhu	a5,2(a4)
    80006a72:	2785                	addiw	a5,a5,1
    80006a74:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006a78:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006a7c:	100017b7          	lui	a5,0x10001
    80006a80:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1)
    80006a84:	004aa783          	lw	a5,4(s5)
  {
    sleep(b, &disk.vdisk_lock);
    80006a88:	0023f917          	auipc	s2,0x23f
    80006a8c:	8b090913          	addi	s2,s2,-1872 # 80245338 <disk+0x128>
  while (b->disk == 1)
    80006a90:	4485                	li	s1,1
    80006a92:	00b79c63          	bne	a5,a1,80006aaa <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006a96:	85ca                	mv	a1,s2
    80006a98:	8556                	mv	a0,s5
    80006a9a:	ffffc097          	auipc	ra,0xffffc
    80006a9e:	860080e7          	jalr	-1952(ra) # 800022fa <sleep>
  while (b->disk == 1)
    80006aa2:	004aa783          	lw	a5,4(s5)
    80006aa6:	fe9788e3          	beq	a5,s1,80006a96 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006aaa:	f8042903          	lw	s2,-128(s0)
    80006aae:	00290713          	addi	a4,s2,2
    80006ab2:	0712                	slli	a4,a4,0x4
    80006ab4:	0023e797          	auipc	a5,0x23e
    80006ab8:	75c78793          	addi	a5,a5,1884 # 80245210 <disk>
    80006abc:	97ba                	add	a5,a5,a4
    80006abe:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006ac2:	0023e997          	auipc	s3,0x23e
    80006ac6:	74e98993          	addi	s3,s3,1870 # 80245210 <disk>
    80006aca:	00491713          	slli	a4,s2,0x4
    80006ace:	0009b783          	ld	a5,0(s3)
    80006ad2:	97ba                	add	a5,a5,a4
    80006ad4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006ad8:	854a                	mv	a0,s2
    80006ada:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006ade:	00000097          	auipc	ra,0x0
    80006ae2:	b9c080e7          	jalr	-1124(ra) # 8000667a <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80006ae6:	8885                	andi	s1,s1,1
    80006ae8:	f0ed                	bnez	s1,80006aca <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006aea:	0023f517          	auipc	a0,0x23f
    80006aee:	84e50513          	addi	a0,a0,-1970 # 80245338 <disk+0x128>
    80006af2:	ffffa097          	auipc	ra,0xffffa
    80006af6:	30c080e7          	jalr	780(ra) # 80000dfe <release>
}
    80006afa:	70e6                	ld	ra,120(sp)
    80006afc:	7446                	ld	s0,112(sp)
    80006afe:	74a6                	ld	s1,104(sp)
    80006b00:	7906                	ld	s2,96(sp)
    80006b02:	69e6                	ld	s3,88(sp)
    80006b04:	6a46                	ld	s4,80(sp)
    80006b06:	6aa6                	ld	s5,72(sp)
    80006b08:	6b06                	ld	s6,64(sp)
    80006b0a:	7be2                	ld	s7,56(sp)
    80006b0c:	7c42                	ld	s8,48(sp)
    80006b0e:	7ca2                	ld	s9,40(sp)
    80006b10:	7d02                	ld	s10,32(sp)
    80006b12:	6de2                	ld	s11,24(sp)
    80006b14:	6109                	addi	sp,sp,128
    80006b16:	8082                	ret

0000000080006b18 <virtio_disk_intr>:

void virtio_disk_intr()
{
    80006b18:	1101                	addi	sp,sp,-32
    80006b1a:	ec06                	sd	ra,24(sp)
    80006b1c:	e822                	sd	s0,16(sp)
    80006b1e:	e426                	sd	s1,8(sp)
    80006b20:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006b22:	0023e497          	auipc	s1,0x23e
    80006b26:	6ee48493          	addi	s1,s1,1774 # 80245210 <disk>
    80006b2a:	0023f517          	auipc	a0,0x23f
    80006b2e:	80e50513          	addi	a0,a0,-2034 # 80245338 <disk+0x128>
    80006b32:	ffffa097          	auipc	ra,0xffffa
    80006b36:	218080e7          	jalr	536(ra) # 80000d4a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006b3a:	10001737          	lui	a4,0x10001
    80006b3e:	533c                	lw	a5,96(a4)
    80006b40:	8b8d                	andi	a5,a5,3
    80006b42:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006b44:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx)
    80006b48:	689c                	ld	a5,16(s1)
    80006b4a:	0204d703          	lhu	a4,32(s1)
    80006b4e:	0027d783          	lhu	a5,2(a5)
    80006b52:	04f70863          	beq	a4,a5,80006ba2 <virtio_disk_intr+0x8a>
  {
    __sync_synchronize();
    80006b56:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006b5a:	6898                	ld	a4,16(s1)
    80006b5c:	0204d783          	lhu	a5,32(s1)
    80006b60:	8b9d                	andi	a5,a5,7
    80006b62:	078e                	slli	a5,a5,0x3
    80006b64:	97ba                	add	a5,a5,a4
    80006b66:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80006b68:	00278713          	addi	a4,a5,2
    80006b6c:	0712                	slli	a4,a4,0x4
    80006b6e:	9726                	add	a4,a4,s1
    80006b70:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006b74:	e721                	bnez	a4,80006bbc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006b76:	0789                	addi	a5,a5,2
    80006b78:	0792                	slli	a5,a5,0x4
    80006b7a:	97a6                	add	a5,a5,s1
    80006b7c:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80006b7e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006b82:	ffffc097          	auipc	ra,0xffffc
    80006b86:	934080e7          	jalr	-1740(ra) # 800024b6 <wakeup>

    disk.used_idx += 1;
    80006b8a:	0204d783          	lhu	a5,32(s1)
    80006b8e:	2785                	addiw	a5,a5,1
    80006b90:	17c2                	slli	a5,a5,0x30
    80006b92:	93c1                	srli	a5,a5,0x30
    80006b94:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx)
    80006b98:	6898                	ld	a4,16(s1)
    80006b9a:	00275703          	lhu	a4,2(a4)
    80006b9e:	faf71ce3          	bne	a4,a5,80006b56 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006ba2:	0023e517          	auipc	a0,0x23e
    80006ba6:	79650513          	addi	a0,a0,1942 # 80245338 <disk+0x128>
    80006baa:	ffffa097          	auipc	ra,0xffffa
    80006bae:	254080e7          	jalr	596(ra) # 80000dfe <release>
}
    80006bb2:	60e2                	ld	ra,24(sp)
    80006bb4:	6442                	ld	s0,16(sp)
    80006bb6:	64a2                	ld	s1,8(sp)
    80006bb8:	6105                	addi	sp,sp,32
    80006bba:	8082                	ret
      panic("virtio_disk_intr status");
    80006bbc:	00002517          	auipc	a0,0x2
    80006bc0:	ddc50513          	addi	a0,a0,-548 # 80008998 <mag01.0+0x100>
    80006bc4:	ffffa097          	auipc	ra,0xffffa
    80006bc8:	97c080e7          	jalr	-1668(ra) # 80000540 <panic>
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
