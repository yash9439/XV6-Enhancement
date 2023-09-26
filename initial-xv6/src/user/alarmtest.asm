
user/_alarmtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <periodic>:
}

volatile static int count;

void periodic()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    count = count + 1;
   8:	00001797          	auipc	a5,0x1
   c:	ff87a783          	lw	a5,-8(a5) # 1000 <count>
  10:	2785                	addiw	a5,a5,1
  12:	00001717          	auipc	a4,0x1
  16:	fef72723          	sw	a5,-18(a4) # 1000 <count>
    printf("alarm!\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	c1650513          	addi	a0,a0,-1002 # c30 <malloc+0xec>
  22:	00001097          	auipc	ra,0x1
  26:	a6a080e7          	jalr	-1430(ra) # a8c <printf>
    sigreturn();
  2a:	00000097          	auipc	ra,0x0
  2e:	770080e7          	jalr	1904(ra) # 79a <sigreturn>
}
  32:	60a2                	ld	ra,8(sp)
  34:	6402                	ld	s0,0(sp)
  36:	0141                	addi	sp,sp,16
  38:	8082                	ret

000000000000003a <slow_handler>:
        printf("test2 passed\n");
    }
}

void slow_handler()
{
  3a:	1101                	addi	sp,sp,-32
  3c:	ec06                	sd	ra,24(sp)
  3e:	e822                	sd	s0,16(sp)
  40:	e426                	sd	s1,8(sp)
  42:	1000                	addi	s0,sp,32
    count++;
  44:	00001497          	auipc	s1,0x1
  48:	fbc48493          	addi	s1,s1,-68 # 1000 <count>
  4c:	00001797          	auipc	a5,0x1
  50:	fb47a783          	lw	a5,-76(a5) # 1000 <count>
  54:	2785                	addiw	a5,a5,1
  56:	c09c                	sw	a5,0(s1)
    printf("alarm!\n");
  58:	00001517          	auipc	a0,0x1
  5c:	bd850513          	addi	a0,a0,-1064 # c30 <malloc+0xec>
  60:	00001097          	auipc	ra,0x1
  64:	a2c080e7          	jalr	-1492(ra) # a8c <printf>
    if (count > 1)
  68:	4098                	lw	a4,0(s1)
  6a:	2701                	sext.w	a4,a4
  6c:	4685                	li	a3,1
  6e:	1dcd67b7          	lui	a5,0x1dcd6
  72:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
  76:	02e6c463          	blt	a3,a4,9e <slow_handler+0x64>
        printf("test2 failed: alarm handler called more than once\n");
        exit(1);
    }
    for (int i = 0; i < 1000 * 500000; i++)
    {
        asm volatile("nop"); // avoid compiler optimizing away loop
  7a:	0001                	nop
    for (int i = 0; i < 1000 * 500000; i++)
  7c:	37fd                	addiw	a5,a5,-1
  7e:	fff5                	bnez	a5,7a <slow_handler+0x40>
    }
    sigalarm(0, 0);
  80:	4581                	li	a1,0
  82:	4501                	li	a0,0
  84:	00000097          	auipc	ra,0x0
  88:	71e080e7          	jalr	1822(ra) # 7a2 <sigalarm>
    sigreturn();
  8c:	00000097          	auipc	ra,0x0
  90:	70e080e7          	jalr	1806(ra) # 79a <sigreturn>
}
  94:	60e2                	ld	ra,24(sp)
  96:	6442                	ld	s0,16(sp)
  98:	64a2                	ld	s1,8(sp)
  9a:	6105                	addi	sp,sp,32
  9c:	8082                	ret
        printf("test2 failed: alarm handler called more than once\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	b9a50513          	addi	a0,a0,-1126 # c38 <malloc+0xf4>
  a6:	00001097          	auipc	ra,0x1
  aa:	9e6080e7          	jalr	-1562(ra) # a8c <printf>
        exit(1);
  ae:	4505                	li	a0,1
  b0:	00000097          	auipc	ra,0x0
  b4:	64a080e7          	jalr	1610(ra) # 6fa <exit>

00000000000000b8 <dummy_handler>:

//
// dummy alarm handler; after running immediately uninstall
// itself and finish signal handling
void dummy_handler()
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e406                	sd	ra,8(sp)
  bc:	e022                	sd	s0,0(sp)
  be:	0800                	addi	s0,sp,16
    sigalarm(0, 0);
  c0:	4581                	li	a1,0
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	6de080e7          	jalr	1758(ra) # 7a2 <sigalarm>
    sigreturn();
  cc:	00000097          	auipc	ra,0x0
  d0:	6ce080e7          	jalr	1742(ra) # 79a <sigreturn>
}
  d4:	60a2                	ld	ra,8(sp)
  d6:	6402                	ld	s0,0(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <test0>:
{
  dc:	7139                	addi	sp,sp,-64
  de:	fc06                	sd	ra,56(sp)
  e0:	f822                	sd	s0,48(sp)
  e2:	f426                	sd	s1,40(sp)
  e4:	f04a                	sd	s2,32(sp)
  e6:	ec4e                	sd	s3,24(sp)
  e8:	e852                	sd	s4,16(sp)
  ea:	e456                	sd	s5,8(sp)
  ec:	0080                	addi	s0,sp,64
    printf("test0 start\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	b8250513          	addi	a0,a0,-1150 # c70 <malloc+0x12c>
  f6:	00001097          	auipc	ra,0x1
  fa:	996080e7          	jalr	-1642(ra) # a8c <printf>
    count = 0;
  fe:	00001797          	auipc	a5,0x1
 102:	f007a123          	sw	zero,-254(a5) # 1000 <count>
    sigalarm(2, periodic);
 106:	00000597          	auipc	a1,0x0
 10a:	efa58593          	addi	a1,a1,-262 # 0 <periodic>
 10e:	4509                	li	a0,2
 110:	00000097          	auipc	ra,0x0
 114:	692080e7          	jalr	1682(ra) # 7a2 <sigalarm>
    for (i = 0; i < 1000 * 500000; i++)
 118:	4481                	li	s1,0
        if ((i % 1000000) == 0)
 11a:	000f4937          	lui	s2,0xf4
 11e:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf3230>
            write(2, ".", 1);
 122:	00001a97          	auipc	s5,0x1
 126:	b5ea8a93          	addi	s5,s5,-1186 # c80 <malloc+0x13c>
        if (count > 0)
 12a:	00001a17          	auipc	s4,0x1
 12e:	ed6a0a13          	addi	s4,s4,-298 # 1000 <count>
    for (i = 0; i < 1000 * 500000; i++)
 132:	1dcd69b7          	lui	s3,0x1dcd6
 136:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 13a:	a809                	j	14c <test0+0x70>
        if (count > 0)
 13c:	000a2783          	lw	a5,0(s4)
 140:	2781                	sext.w	a5,a5
 142:	02f04063          	bgtz	a5,162 <test0+0x86>
    for (i = 0; i < 1000 * 500000; i++)
 146:	2485                	addiw	s1,s1,1
 148:	01348d63          	beq	s1,s3,162 <test0+0x86>
        if ((i % 1000000) == 0)
 14c:	0324e7bb          	remw	a5,s1,s2
 150:	f7f5                	bnez	a5,13c <test0+0x60>
            write(2, ".", 1);
 152:	4605                	li	a2,1
 154:	85d6                	mv	a1,s5
 156:	4509                	li	a0,2
 158:	00000097          	auipc	ra,0x0
 15c:	5c2080e7          	jalr	1474(ra) # 71a <write>
 160:	bff1                	j	13c <test0+0x60>
    sigalarm(0, 0);
 162:	4581                	li	a1,0
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	63c080e7          	jalr	1596(ra) # 7a2 <sigalarm>
    if (count > 0)
 16e:	00001797          	auipc	a5,0x1
 172:	e927a783          	lw	a5,-366(a5) # 1000 <count>
 176:	02f05363          	blez	a5,19c <test0+0xc0>
        printf("test0 passed\n");
 17a:	00001517          	auipc	a0,0x1
 17e:	b0e50513          	addi	a0,a0,-1266 # c88 <malloc+0x144>
 182:	00001097          	auipc	ra,0x1
 186:	90a080e7          	jalr	-1782(ra) # a8c <printf>
}
 18a:	70e2                	ld	ra,56(sp)
 18c:	7442                	ld	s0,48(sp)
 18e:	74a2                	ld	s1,40(sp)
 190:	7902                	ld	s2,32(sp)
 192:	69e2                	ld	s3,24(sp)
 194:	6a42                	ld	s4,16(sp)
 196:	6aa2                	ld	s5,8(sp)
 198:	6121                	addi	sp,sp,64
 19a:	8082                	ret
        printf("\ntest0 failed: the kernel never called the alarm handler\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	afc50513          	addi	a0,a0,-1284 # c98 <malloc+0x154>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	8e8080e7          	jalr	-1816(ra) # a8c <printf>
}
 1ac:	bff9                	j	18a <test0+0xae>

00000000000001ae <foo>:
{
 1ae:	1101                	addi	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e426                	sd	s1,8(sp)
 1b6:	1000                	addi	s0,sp,32
 1b8:	84ae                	mv	s1,a1
    if ((i % 25000000) == 0)
 1ba:	017d87b7          	lui	a5,0x17d8
 1be:	8407879b          	addiw	a5,a5,-1984 # 17d7840 <base+0x17d6830>
 1c2:	02f5653b          	remw	a0,a0,a5
 1c6:	c909                	beqz	a0,1d8 <foo+0x2a>
    *j += 1;
 1c8:	409c                	lw	a5,0(s1)
 1ca:	2785                	addiw	a5,a5,1
 1cc:	c09c                	sw	a5,0(s1)
}
 1ce:	60e2                	ld	ra,24(sp)
 1d0:	6442                	ld	s0,16(sp)
 1d2:	64a2                	ld	s1,8(sp)
 1d4:	6105                	addi	sp,sp,32
 1d6:	8082                	ret
        write(2, ".", 1);
 1d8:	4605                	li	a2,1
 1da:	00001597          	auipc	a1,0x1
 1de:	aa658593          	addi	a1,a1,-1370 # c80 <malloc+0x13c>
 1e2:	4509                	li	a0,2
 1e4:	00000097          	auipc	ra,0x0
 1e8:	536080e7          	jalr	1334(ra) # 71a <write>
 1ec:	bff1                	j	1c8 <foo+0x1a>

00000000000001ee <test1>:
{
 1ee:	7139                	addi	sp,sp,-64
 1f0:	fc06                	sd	ra,56(sp)
 1f2:	f822                	sd	s0,48(sp)
 1f4:	f426                	sd	s1,40(sp)
 1f6:	f04a                	sd	s2,32(sp)
 1f8:	ec4e                	sd	s3,24(sp)
 1fa:	e852                	sd	s4,16(sp)
 1fc:	0080                	addi	s0,sp,64
    printf("test1 start\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	ada50513          	addi	a0,a0,-1318 # cd8 <malloc+0x194>
 206:	00001097          	auipc	ra,0x1
 20a:	886080e7          	jalr	-1914(ra) # a8c <printf>
    count = 0;
 20e:	00001797          	auipc	a5,0x1
 212:	de07a923          	sw	zero,-526(a5) # 1000 <count>
    j = 0;
 216:	fc042623          	sw	zero,-52(s0)
    sigalarm(2, periodic);
 21a:	00000597          	auipc	a1,0x0
 21e:	de658593          	addi	a1,a1,-538 # 0 <periodic>
 222:	4509                	li	a0,2
 224:	00000097          	auipc	ra,0x0
 228:	57e080e7          	jalr	1406(ra) # 7a2 <sigalarm>
    for (i = 0; i < 500000000; i++)
 22c:	4481                	li	s1,0
        if (count >= 10)
 22e:	00001a17          	auipc	s4,0x1
 232:	dd2a0a13          	addi	s4,s4,-558 # 1000 <count>
 236:	49a5                	li	s3,9
    for (i = 0; i < 500000000; i++)
 238:	1dcd6937          	lui	s2,0x1dcd6
 23c:	50090913          	addi	s2,s2,1280 # 1dcd6500 <base+0x1dcd54f0>
        if (count >= 10)
 240:	000a2783          	lw	a5,0(s4)
 244:	2781                	sext.w	a5,a5
 246:	00f9cc63          	blt	s3,a5,25e <test1+0x70>
        foo(i, &j);
 24a:	fcc40593          	addi	a1,s0,-52
 24e:	8526                	mv	a0,s1
 250:	00000097          	auipc	ra,0x0
 254:	f5e080e7          	jalr	-162(ra) # 1ae <foo>
    for (i = 0; i < 500000000; i++)
 258:	2485                	addiw	s1,s1,1
 25a:	ff2493e3          	bne	s1,s2,240 <test1+0x52>
    printf("done\n");
 25e:	00001517          	auipc	a0,0x1
 262:	a8a50513          	addi	a0,a0,-1398 # ce8 <malloc+0x1a4>
 266:	00001097          	auipc	ra,0x1
 26a:	826080e7          	jalr	-2010(ra) # a8c <printf>
    if (count < 10)
 26e:	00001717          	auipc	a4,0x1
 272:	d9272703          	lw	a4,-622(a4) # 1000 <count>
 276:	47a5                	li	a5,9
 278:	02e7d663          	bge	a5,a4,2a4 <test1+0xb6>
    else if (i != j)
 27c:	fcc42783          	lw	a5,-52(s0)
 280:	02978b63          	beq	a5,s1,2b6 <test1+0xc8>
        printf("\ntest1 failed: foo() executed fewer times than it was called\n");
 284:	00001517          	auipc	a0,0x1
 288:	a9c50513          	addi	a0,a0,-1380 # d20 <malloc+0x1dc>
 28c:	00001097          	auipc	ra,0x1
 290:	800080e7          	jalr	-2048(ra) # a8c <printf>
}
 294:	70e2                	ld	ra,56(sp)
 296:	7442                	ld	s0,48(sp)
 298:	74a2                	ld	s1,40(sp)
 29a:	7902                	ld	s2,32(sp)
 29c:	69e2                	ld	s3,24(sp)
 29e:	6a42                	ld	s4,16(sp)
 2a0:	6121                	addi	sp,sp,64
 2a2:	8082                	ret
        printf("\ntest1 failed: too few calls to the handler\n");
 2a4:	00001517          	auipc	a0,0x1
 2a8:	a4c50513          	addi	a0,a0,-1460 # cf0 <malloc+0x1ac>
 2ac:	00000097          	auipc	ra,0x0
 2b0:	7e0080e7          	jalr	2016(ra) # a8c <printf>
 2b4:	b7c5                	j	294 <test1+0xa6>
        printf("test1 passed\n");
 2b6:	00001517          	auipc	a0,0x1
 2ba:	aaa50513          	addi	a0,a0,-1366 # d60 <malloc+0x21c>
 2be:	00000097          	auipc	ra,0x0
 2c2:	7ce080e7          	jalr	1998(ra) # a8c <printf>
}
 2c6:	b7f9                	j	294 <test1+0xa6>

00000000000002c8 <test2>:
{
 2c8:	715d                	addi	sp,sp,-80
 2ca:	e486                	sd	ra,72(sp)
 2cc:	e0a2                	sd	s0,64(sp)
 2ce:	fc26                	sd	s1,56(sp)
 2d0:	f84a                	sd	s2,48(sp)
 2d2:	f44e                	sd	s3,40(sp)
 2d4:	f052                	sd	s4,32(sp)
 2d6:	ec56                	sd	s5,24(sp)
 2d8:	0880                	addi	s0,sp,80
    printf("test2 start\n");
 2da:	00001517          	auipc	a0,0x1
 2de:	a9650513          	addi	a0,a0,-1386 # d70 <malloc+0x22c>
 2e2:	00000097          	auipc	ra,0x0
 2e6:	7aa080e7          	jalr	1962(ra) # a8c <printf>
    if ((pid = fork()) < 0)
 2ea:	00000097          	auipc	ra,0x0
 2ee:	408080e7          	jalr	1032(ra) # 6f2 <fork>
 2f2:	04054263          	bltz	a0,336 <test2+0x6e>
 2f6:	84aa                	mv	s1,a0
    if (pid == 0)
 2f8:	e539                	bnez	a0,346 <test2+0x7e>
        count = 0;
 2fa:	00001797          	auipc	a5,0x1
 2fe:	d007a323          	sw	zero,-762(a5) # 1000 <count>
        sigalarm(2, slow_handler);
 302:	00000597          	auipc	a1,0x0
 306:	d3858593          	addi	a1,a1,-712 # 3a <slow_handler>
 30a:	4509                	li	a0,2
 30c:	00000097          	auipc	ra,0x0
 310:	496080e7          	jalr	1174(ra) # 7a2 <sigalarm>
            if ((i % 1000000) == 0)
 314:	000f4937          	lui	s2,0xf4
 318:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf3230>
                write(2, ".", 1);
 31c:	00001a97          	auipc	s5,0x1
 320:	964a8a93          	addi	s5,s5,-1692 # c80 <malloc+0x13c>
            if (count > 0)
 324:	00001a17          	auipc	s4,0x1
 328:	cdca0a13          	addi	s4,s4,-804 # 1000 <count>
        for (i = 0; i < 1000 * 500000; i++)
 32c:	1dcd69b7          	lui	s3,0x1dcd6
 330:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 334:	a099                	j	37a <test2+0xb2>
        printf("test2: fork failed\n");
 336:	00001517          	auipc	a0,0x1
 33a:	a4a50513          	addi	a0,a0,-1462 # d80 <malloc+0x23c>
 33e:	00000097          	auipc	ra,0x0
 342:	74e080e7          	jalr	1870(ra) # a8c <printf>
    wait(&status);
 346:	fbc40513          	addi	a0,s0,-68
 34a:	00000097          	auipc	ra,0x0
 34e:	3b8080e7          	jalr	952(ra) # 702 <wait>
    if (status == 0)
 352:	fbc42783          	lw	a5,-68(s0)
 356:	c7a5                	beqz	a5,3be <test2+0xf6>
}
 358:	60a6                	ld	ra,72(sp)
 35a:	6406                	ld	s0,64(sp)
 35c:	74e2                	ld	s1,56(sp)
 35e:	7942                	ld	s2,48(sp)
 360:	79a2                	ld	s3,40(sp)
 362:	7a02                	ld	s4,32(sp)
 364:	6ae2                	ld	s5,24(sp)
 366:	6161                	addi	sp,sp,80
 368:	8082                	ret
            if (count > 0)
 36a:	000a2783          	lw	a5,0(s4)
 36e:	2781                	sext.w	a5,a5
 370:	02f04063          	bgtz	a5,390 <test2+0xc8>
        for (i = 0; i < 1000 * 500000; i++)
 374:	2485                	addiw	s1,s1,1
 376:	01348d63          	beq	s1,s3,390 <test2+0xc8>
            if ((i % 1000000) == 0)
 37a:	0324e7bb          	remw	a5,s1,s2
 37e:	f7f5                	bnez	a5,36a <test2+0xa2>
                write(2, ".", 1);
 380:	4605                	li	a2,1
 382:	85d6                	mv	a1,s5
 384:	4509                	li	a0,2
 386:	00000097          	auipc	ra,0x0
 38a:	394080e7          	jalr	916(ra) # 71a <write>
 38e:	bff1                	j	36a <test2+0xa2>
        if (count == 0)
 390:	00001797          	auipc	a5,0x1
 394:	c707a783          	lw	a5,-912(a5) # 1000 <count>
 398:	ef91                	bnez	a5,3b4 <test2+0xec>
            printf("\ntest2 failed: alarm not called\n");
 39a:	00001517          	auipc	a0,0x1
 39e:	9fe50513          	addi	a0,a0,-1538 # d98 <malloc+0x254>
 3a2:	00000097          	auipc	ra,0x0
 3a6:	6ea080e7          	jalr	1770(ra) # a8c <printf>
            exit(1);
 3aa:	4505                	li	a0,1
 3ac:	00000097          	auipc	ra,0x0
 3b0:	34e080e7          	jalr	846(ra) # 6fa <exit>
        exit(0);
 3b4:	4501                	li	a0,0
 3b6:	00000097          	auipc	ra,0x0
 3ba:	344080e7          	jalr	836(ra) # 6fa <exit>
        printf("test2 passed\n");
 3be:	00001517          	auipc	a0,0x1
 3c2:	a0250513          	addi	a0,a0,-1534 # dc0 <malloc+0x27c>
 3c6:	00000097          	auipc	ra,0x0
 3ca:	6c6080e7          	jalr	1734(ra) # a8c <printf>
}
 3ce:	b769                	j	358 <test2+0x90>

00000000000003d0 <test3>:

//
// tests that the return from sys_sigreturn() does not
// modify the a0 register
void test3()
{
 3d0:	1141                	addi	sp,sp,-16
 3d2:	e406                	sd	ra,8(sp)
 3d4:	e022                	sd	s0,0(sp)
 3d6:	0800                	addi	s0,sp,16
    uint64 a0;

    sigalarm(1, dummy_handler);
 3d8:	00000597          	auipc	a1,0x0
 3dc:	ce058593          	addi	a1,a1,-800 # b8 <dummy_handler>
 3e0:	4505                	li	a0,1
 3e2:	00000097          	auipc	ra,0x0
 3e6:	3c0080e7          	jalr	960(ra) # 7a2 <sigalarm>
    printf("test3 start\n");
 3ea:	00001517          	auipc	a0,0x1
 3ee:	9e650513          	addi	a0,a0,-1562 # dd0 <malloc+0x28c>
 3f2:	00000097          	auipc	ra,0x0
 3f6:	69a080e7          	jalr	1690(ra) # a8c <printf>

    asm volatile("lui a5, 0");
 3fa:	000007b7          	lui	a5,0x0
    asm volatile("addi a0, a5, 0xac"
 3fe:	0ac78513          	addi	a0,a5,172 # ac <slow_handler+0x72>
 402:	1dcd67b7          	lui	a5,0x1dcd6
 406:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
                 :
                 :
                 : "a0");
    for (int i = 0; i < 500000000; i++)
 40a:	37fd                	addiw	a5,a5,-1
 40c:	fffd                	bnez	a5,40a <test3+0x3a>
        ;
    asm volatile("mv %0, a0"
 40e:	872a                	mv	a4,a0
                 : "=r"(a0));

    if (a0 != 0xac)
 410:	0ac00793          	li	a5,172
 414:	00f70e63          	beq	a4,a5,430 <test3+0x60>
        printf("test3 failed: register a0 changed\n");
 418:	00001517          	auipc	a0,0x1
 41c:	9c850513          	addi	a0,a0,-1592 # de0 <malloc+0x29c>
 420:	00000097          	auipc	ra,0x0
 424:	66c080e7          	jalr	1644(ra) # a8c <printf>
    else
        printf("test3 passed\n");
}
 428:	60a2                	ld	ra,8(sp)
 42a:	6402                	ld	s0,0(sp)
 42c:	0141                	addi	sp,sp,16
 42e:	8082                	ret
        printf("test3 passed\n");
 430:	00001517          	auipc	a0,0x1
 434:	9d850513          	addi	a0,a0,-1576 # e08 <malloc+0x2c4>
 438:	00000097          	auipc	ra,0x0
 43c:	654080e7          	jalr	1620(ra) # a8c <printf>
}
 440:	b7e5                	j	428 <test3+0x58>

0000000000000442 <main>:
{
 442:	1141                	addi	sp,sp,-16
 444:	e406                	sd	ra,8(sp)
 446:	e022                	sd	s0,0(sp)
 448:	0800                	addi	s0,sp,16
    test0();
 44a:	00000097          	auipc	ra,0x0
 44e:	c92080e7          	jalr	-878(ra) # dc <test0>
    test1();
 452:	00000097          	auipc	ra,0x0
 456:	d9c080e7          	jalr	-612(ra) # 1ee <test1>
    test2();
 45a:	00000097          	auipc	ra,0x0
 45e:	e6e080e7          	jalr	-402(ra) # 2c8 <test2>
    test3();
 462:	00000097          	auipc	ra,0x0
 466:	f6e080e7          	jalr	-146(ra) # 3d0 <test3>
    exit(0);
 46a:	4501                	li	a0,0
 46c:	00000097          	auipc	ra,0x0
 470:	28e080e7          	jalr	654(ra) # 6fa <exit>

0000000000000474 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 474:	1141                	addi	sp,sp,-16
 476:	e406                	sd	ra,8(sp)
 478:	e022                	sd	s0,0(sp)
 47a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 47c:	00000097          	auipc	ra,0x0
 480:	fc6080e7          	jalr	-58(ra) # 442 <main>
  exit(0);
 484:	4501                	li	a0,0
 486:	00000097          	auipc	ra,0x0
 48a:	274080e7          	jalr	628(ra) # 6fa <exit>

000000000000048e <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 48e:	1141                	addi	sp,sp,-16
 490:	e422                	sd	s0,8(sp)
 492:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 494:	87aa                	mv	a5,a0
 496:	0585                	addi	a1,a1,1
 498:	0785                	addi	a5,a5,1
 49a:	fff5c703          	lbu	a4,-1(a1)
 49e:	fee78fa3          	sb	a4,-1(a5)
 4a2:	fb75                	bnez	a4,496 <strcpy+0x8>
    ;
  return os;
}
 4a4:	6422                	ld	s0,8(sp)
 4a6:	0141                	addi	sp,sp,16
 4a8:	8082                	ret

00000000000004aa <strcmp>:

int strcmp(const char *p, const char *q)
{
 4aa:	1141                	addi	sp,sp,-16
 4ac:	e422                	sd	s0,8(sp)
 4ae:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 4b0:	00054783          	lbu	a5,0(a0)
 4b4:	cb91                	beqz	a5,4c8 <strcmp+0x1e>
 4b6:	0005c703          	lbu	a4,0(a1)
 4ba:	00f71763          	bne	a4,a5,4c8 <strcmp+0x1e>
    p++, q++;
 4be:	0505                	addi	a0,a0,1
 4c0:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 4c2:	00054783          	lbu	a5,0(a0)
 4c6:	fbe5                	bnez	a5,4b6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4c8:	0005c503          	lbu	a0,0(a1)
}
 4cc:	40a7853b          	subw	a0,a5,a0
 4d0:	6422                	ld	s0,8(sp)
 4d2:	0141                	addi	sp,sp,16
 4d4:	8082                	ret

00000000000004d6 <strlen>:

uint strlen(const char *s)
{
 4d6:	1141                	addi	sp,sp,-16
 4d8:	e422                	sd	s0,8(sp)
 4da:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 4dc:	00054783          	lbu	a5,0(a0)
 4e0:	cf91                	beqz	a5,4fc <strlen+0x26>
 4e2:	0505                	addi	a0,a0,1
 4e4:	87aa                	mv	a5,a0
 4e6:	4685                	li	a3,1
 4e8:	9e89                	subw	a3,a3,a0
 4ea:	00f6853b          	addw	a0,a3,a5
 4ee:	0785                	addi	a5,a5,1
 4f0:	fff7c703          	lbu	a4,-1(a5)
 4f4:	fb7d                	bnez	a4,4ea <strlen+0x14>
    ;
  return n;
}
 4f6:	6422                	ld	s0,8(sp)
 4f8:	0141                	addi	sp,sp,16
 4fa:	8082                	ret
  for (n = 0; s[n]; n++)
 4fc:	4501                	li	a0,0
 4fe:	bfe5                	j	4f6 <strlen+0x20>

0000000000000500 <memset>:

void *
memset(void *dst, int c, uint n)
{
 500:	1141                	addi	sp,sp,-16
 502:	e422                	sd	s0,8(sp)
 504:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++)
 506:	ca19                	beqz	a2,51c <memset+0x1c>
 508:	87aa                	mv	a5,a0
 50a:	1602                	slli	a2,a2,0x20
 50c:	9201                	srli	a2,a2,0x20
 50e:	00a60733          	add	a4,a2,a0
  {
    cdst[i] = c;
 512:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++)
 516:	0785                	addi	a5,a5,1
 518:	fee79de3          	bne	a5,a4,512 <memset+0x12>
  }
  return dst;
}
 51c:	6422                	ld	s0,8(sp)
 51e:	0141                	addi	sp,sp,16
 520:	8082                	ret

0000000000000522 <strchr>:

char *
strchr(const char *s, char c)
{
 522:	1141                	addi	sp,sp,-16
 524:	e422                	sd	s0,8(sp)
 526:	0800                	addi	s0,sp,16
  for (; *s; s++)
 528:	00054783          	lbu	a5,0(a0)
 52c:	cb99                	beqz	a5,542 <strchr+0x20>
    if (*s == c)
 52e:	00f58763          	beq	a1,a5,53c <strchr+0x1a>
  for (; *s; s++)
 532:	0505                	addi	a0,a0,1
 534:	00054783          	lbu	a5,0(a0)
 538:	fbfd                	bnez	a5,52e <strchr+0xc>
      return (char *)s;
  return 0;
 53a:	4501                	li	a0,0
}
 53c:	6422                	ld	s0,8(sp)
 53e:	0141                	addi	sp,sp,16
 540:	8082                	ret
  return 0;
 542:	4501                	li	a0,0
 544:	bfe5                	j	53c <strchr+0x1a>

0000000000000546 <gets>:

char *
gets(char *buf, int max)
{
 546:	711d                	addi	sp,sp,-96
 548:	ec86                	sd	ra,88(sp)
 54a:	e8a2                	sd	s0,80(sp)
 54c:	e4a6                	sd	s1,72(sp)
 54e:	e0ca                	sd	s2,64(sp)
 550:	fc4e                	sd	s3,56(sp)
 552:	f852                	sd	s4,48(sp)
 554:	f456                	sd	s5,40(sp)
 556:	f05a                	sd	s6,32(sp)
 558:	ec5e                	sd	s7,24(sp)
 55a:	1080                	addi	s0,sp,96
 55c:	8baa                	mv	s7,a0
 55e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;)
 560:	892a                	mv	s2,a0
 562:	4481                	li	s1,0
  {
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 564:	4aa9                	li	s5,10
 566:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;)
 568:	89a6                	mv	s3,s1
 56a:	2485                	addiw	s1,s1,1
 56c:	0344d863          	bge	s1,s4,59c <gets+0x56>
    cc = read(0, &c, 1);
 570:	4605                	li	a2,1
 572:	faf40593          	addi	a1,s0,-81
 576:	4501                	li	a0,0
 578:	00000097          	auipc	ra,0x0
 57c:	19a080e7          	jalr	410(ra) # 712 <read>
    if (cc < 1)
 580:	00a05e63          	blez	a0,59c <gets+0x56>
    buf[i++] = c;
 584:	faf44783          	lbu	a5,-81(s0)
 588:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 58c:	01578763          	beq	a5,s5,59a <gets+0x54>
 590:	0905                	addi	s2,s2,1
 592:	fd679be3          	bne	a5,s6,568 <gets+0x22>
  for (i = 0; i + 1 < max;)
 596:	89a6                	mv	s3,s1
 598:	a011                	j	59c <gets+0x56>
 59a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 59c:	99de                	add	s3,s3,s7
 59e:	00098023          	sb	zero,0(s3)
  return buf;
}
 5a2:	855e                	mv	a0,s7
 5a4:	60e6                	ld	ra,88(sp)
 5a6:	6446                	ld	s0,80(sp)
 5a8:	64a6                	ld	s1,72(sp)
 5aa:	6906                	ld	s2,64(sp)
 5ac:	79e2                	ld	s3,56(sp)
 5ae:	7a42                	ld	s4,48(sp)
 5b0:	7aa2                	ld	s5,40(sp)
 5b2:	7b02                	ld	s6,32(sp)
 5b4:	6be2                	ld	s7,24(sp)
 5b6:	6125                	addi	sp,sp,96
 5b8:	8082                	ret

00000000000005ba <stat>:

int stat(const char *n, struct stat *st)
{
 5ba:	1101                	addi	sp,sp,-32
 5bc:	ec06                	sd	ra,24(sp)
 5be:	e822                	sd	s0,16(sp)
 5c0:	e426                	sd	s1,8(sp)
 5c2:	e04a                	sd	s2,0(sp)
 5c4:	1000                	addi	s0,sp,32
 5c6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5c8:	4581                	li	a1,0
 5ca:	00000097          	auipc	ra,0x0
 5ce:	170080e7          	jalr	368(ra) # 73a <open>
  if (fd < 0)
 5d2:	02054563          	bltz	a0,5fc <stat+0x42>
 5d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5d8:	85ca                	mv	a1,s2
 5da:	00000097          	auipc	ra,0x0
 5de:	178080e7          	jalr	376(ra) # 752 <fstat>
 5e2:	892a                	mv	s2,a0
  close(fd);
 5e4:	8526                	mv	a0,s1
 5e6:	00000097          	auipc	ra,0x0
 5ea:	13c080e7          	jalr	316(ra) # 722 <close>
  return r;
}
 5ee:	854a                	mv	a0,s2
 5f0:	60e2                	ld	ra,24(sp)
 5f2:	6442                	ld	s0,16(sp)
 5f4:	64a2                	ld	s1,8(sp)
 5f6:	6902                	ld	s2,0(sp)
 5f8:	6105                	addi	sp,sp,32
 5fa:	8082                	ret
    return -1;
 5fc:	597d                	li	s2,-1
 5fe:	bfc5                	j	5ee <stat+0x34>

0000000000000600 <atoi>:

int atoi(const char *s)
{
 600:	1141                	addi	sp,sp,-16
 602:	e422                	sd	s0,8(sp)
 604:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 606:	00054683          	lbu	a3,0(a0)
 60a:	fd06879b          	addiw	a5,a3,-48
 60e:	0ff7f793          	zext.b	a5,a5
 612:	4625                	li	a2,9
 614:	02f66863          	bltu	a2,a5,644 <atoi+0x44>
 618:	872a                	mv	a4,a0
  n = 0;
 61a:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 61c:	0705                	addi	a4,a4,1
 61e:	0025179b          	slliw	a5,a0,0x2
 622:	9fa9                	addw	a5,a5,a0
 624:	0017979b          	slliw	a5,a5,0x1
 628:	9fb5                	addw	a5,a5,a3
 62a:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 62e:	00074683          	lbu	a3,0(a4)
 632:	fd06879b          	addiw	a5,a3,-48
 636:	0ff7f793          	zext.b	a5,a5
 63a:	fef671e3          	bgeu	a2,a5,61c <atoi+0x1c>
  return n;
}
 63e:	6422                	ld	s0,8(sp)
 640:	0141                	addi	sp,sp,16
 642:	8082                	ret
  n = 0;
 644:	4501                	li	a0,0
 646:	bfe5                	j	63e <atoi+0x3e>

0000000000000648 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 648:	1141                	addi	sp,sp,-16
 64a:	e422                	sd	s0,8(sp)
 64c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst)
 64e:	02b57463          	bgeu	a0,a1,676 <memmove+0x2e>
  {
    while (n-- > 0)
 652:	00c05f63          	blez	a2,670 <memmove+0x28>
 656:	1602                	slli	a2,a2,0x20
 658:	9201                	srli	a2,a2,0x20
 65a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 65e:	872a                	mv	a4,a0
      *dst++ = *src++;
 660:	0585                	addi	a1,a1,1
 662:	0705                	addi	a4,a4,1
 664:	fff5c683          	lbu	a3,-1(a1)
 668:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 66c:	fee79ae3          	bne	a5,a4,660 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 670:	6422                	ld	s0,8(sp)
 672:	0141                	addi	sp,sp,16
 674:	8082                	ret
    dst += n;
 676:	00c50733          	add	a4,a0,a2
    src += n;
 67a:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 67c:	fec05ae3          	blez	a2,670 <memmove+0x28>
 680:	fff6079b          	addiw	a5,a2,-1
 684:	1782                	slli	a5,a5,0x20
 686:	9381                	srli	a5,a5,0x20
 688:	fff7c793          	not	a5,a5
 68c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 68e:	15fd                	addi	a1,a1,-1
 690:	177d                	addi	a4,a4,-1
 692:	0005c683          	lbu	a3,0(a1)
 696:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 69a:	fee79ae3          	bne	a5,a4,68e <memmove+0x46>
 69e:	bfc9                	j	670 <memmove+0x28>

00000000000006a0 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 6a0:	1141                	addi	sp,sp,-16
 6a2:	e422                	sd	s0,8(sp)
 6a4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0)
 6a6:	ca05                	beqz	a2,6d6 <memcmp+0x36>
 6a8:	fff6069b          	addiw	a3,a2,-1
 6ac:	1682                	slli	a3,a3,0x20
 6ae:	9281                	srli	a3,a3,0x20
 6b0:	0685                	addi	a3,a3,1
 6b2:	96aa                	add	a3,a3,a0
  {
    if (*p1 != *p2)
 6b4:	00054783          	lbu	a5,0(a0)
 6b8:	0005c703          	lbu	a4,0(a1)
 6bc:	00e79863          	bne	a5,a4,6cc <memcmp+0x2c>
    {
      return *p1 - *p2;
    }
    p1++;
 6c0:	0505                	addi	a0,a0,1
    p2++;
 6c2:	0585                	addi	a1,a1,1
  while (n-- > 0)
 6c4:	fed518e3          	bne	a0,a3,6b4 <memcmp+0x14>
  }
  return 0;
 6c8:	4501                	li	a0,0
 6ca:	a019                	j	6d0 <memcmp+0x30>
      return *p1 - *p2;
 6cc:	40e7853b          	subw	a0,a5,a4
}
 6d0:	6422                	ld	s0,8(sp)
 6d2:	0141                	addi	sp,sp,16
 6d4:	8082                	ret
  return 0;
 6d6:	4501                	li	a0,0
 6d8:	bfe5                	j	6d0 <memcmp+0x30>

00000000000006da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6da:	1141                	addi	sp,sp,-16
 6dc:	e406                	sd	ra,8(sp)
 6de:	e022                	sd	s0,0(sp)
 6e0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6e2:	00000097          	auipc	ra,0x0
 6e6:	f66080e7          	jalr	-154(ra) # 648 <memmove>
}
 6ea:	60a2                	ld	ra,8(sp)
 6ec:	6402                	ld	s0,0(sp)
 6ee:	0141                	addi	sp,sp,16
 6f0:	8082                	ret

00000000000006f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6f2:	4885                	li	a7,1
 ecall
 6f4:	00000073          	ecall
 ret
 6f8:	8082                	ret

00000000000006fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 6fa:	4889                	li	a7,2
 ecall
 6fc:	00000073          	ecall
 ret
 700:	8082                	ret

0000000000000702 <wait>:
.global wait
wait:
 li a7, SYS_wait
 702:	488d                	li	a7,3
 ecall
 704:	00000073          	ecall
 ret
 708:	8082                	ret

000000000000070a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 70a:	4891                	li	a7,4
 ecall
 70c:	00000073          	ecall
 ret
 710:	8082                	ret

0000000000000712 <read>:
.global read
read:
 li a7, SYS_read
 712:	4895                	li	a7,5
 ecall
 714:	00000073          	ecall
 ret
 718:	8082                	ret

000000000000071a <write>:
.global write
write:
 li a7, SYS_write
 71a:	48c1                	li	a7,16
 ecall
 71c:	00000073          	ecall
 ret
 720:	8082                	ret

0000000000000722 <close>:
.global close
close:
 li a7, SYS_close
 722:	48d5                	li	a7,21
 ecall
 724:	00000073          	ecall
 ret
 728:	8082                	ret

000000000000072a <kill>:
.global kill
kill:
 li a7, SYS_kill
 72a:	4899                	li	a7,6
 ecall
 72c:	00000073          	ecall
 ret
 730:	8082                	ret

0000000000000732 <exec>:
.global exec
exec:
 li a7, SYS_exec
 732:	489d                	li	a7,7
 ecall
 734:	00000073          	ecall
 ret
 738:	8082                	ret

000000000000073a <open>:
.global open
open:
 li a7, SYS_open
 73a:	48bd                	li	a7,15
 ecall
 73c:	00000073          	ecall
 ret
 740:	8082                	ret

0000000000000742 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 742:	48c5                	li	a7,17
 ecall
 744:	00000073          	ecall
 ret
 748:	8082                	ret

000000000000074a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 74a:	48c9                	li	a7,18
 ecall
 74c:	00000073          	ecall
 ret
 750:	8082                	ret

0000000000000752 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 752:	48a1                	li	a7,8
 ecall
 754:	00000073          	ecall
 ret
 758:	8082                	ret

000000000000075a <link>:
.global link
link:
 li a7, SYS_link
 75a:	48cd                	li	a7,19
 ecall
 75c:	00000073          	ecall
 ret
 760:	8082                	ret

0000000000000762 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 762:	48d1                	li	a7,20
 ecall
 764:	00000073          	ecall
 ret
 768:	8082                	ret

000000000000076a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 76a:	48a5                	li	a7,9
 ecall
 76c:	00000073          	ecall
 ret
 770:	8082                	ret

0000000000000772 <dup>:
.global dup
dup:
 li a7, SYS_dup
 772:	48a9                	li	a7,10
 ecall
 774:	00000073          	ecall
 ret
 778:	8082                	ret

000000000000077a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 77a:	48ad                	li	a7,11
 ecall
 77c:	00000073          	ecall
 ret
 780:	8082                	ret

0000000000000782 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 782:	48b1                	li	a7,12
 ecall
 784:	00000073          	ecall
 ret
 788:	8082                	ret

000000000000078a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 78a:	48b5                	li	a7,13
 ecall
 78c:	00000073          	ecall
 ret
 790:	8082                	ret

0000000000000792 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 792:	48b9                	li	a7,14
 ecall
 794:	00000073          	ecall
 ret
 798:	8082                	ret

000000000000079a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 79a:	48e1                	li	a7,24
 ecall
 79c:	00000073          	ecall
 ret
 7a0:	8082                	ret

00000000000007a2 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 7a2:	48dd                	li	a7,23
 ecall
 7a4:	00000073          	ecall
 ret
 7a8:	8082                	ret

00000000000007aa <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 7aa:	48d9                	li	a7,22
 ecall
 7ac:	00000073          	ecall
 ret
 7b0:	8082                	ret

00000000000007b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7b2:	1101                	addi	sp,sp,-32
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	1000                	addi	s0,sp,32
 7ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7be:	4605                	li	a2,1
 7c0:	fef40593          	addi	a1,s0,-17
 7c4:	00000097          	auipc	ra,0x0
 7c8:	f56080e7          	jalr	-170(ra) # 71a <write>
}
 7cc:	60e2                	ld	ra,24(sp)
 7ce:	6442                	ld	s0,16(sp)
 7d0:	6105                	addi	sp,sp,32
 7d2:	8082                	ret

00000000000007d4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7d4:	7139                	addi	sp,sp,-64
 7d6:	fc06                	sd	ra,56(sp)
 7d8:	f822                	sd	s0,48(sp)
 7da:	f426                	sd	s1,40(sp)
 7dc:	f04a                	sd	s2,32(sp)
 7de:	ec4e                	sd	s3,24(sp)
 7e0:	0080                	addi	s0,sp,64
 7e2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if (sgn && xx < 0)
 7e4:	c299                	beqz	a3,7ea <printint+0x16>
 7e6:	0805c963          	bltz	a1,878 <printint+0xa4>
    neg = 1;
    x = -xx;
  }
  else
  {
    x = xx;
 7ea:	2581                	sext.w	a1,a1
  neg = 0;
 7ec:	4881                	li	a7,0
 7ee:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7f2:	4701                	li	a4,0
  do
  {
    buf[i++] = digits[x % base];
 7f4:	2601                	sext.w	a2,a2
 7f6:	00000517          	auipc	a0,0x0
 7fa:	68250513          	addi	a0,a0,1666 # e78 <digits>
 7fe:	883a                	mv	a6,a4
 800:	2705                	addiw	a4,a4,1
 802:	02c5f7bb          	remuw	a5,a1,a2
 806:	1782                	slli	a5,a5,0x20
 808:	9381                	srli	a5,a5,0x20
 80a:	97aa                	add	a5,a5,a0
 80c:	0007c783          	lbu	a5,0(a5)
 810:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 814:	0005879b          	sext.w	a5,a1
 818:	02c5d5bb          	divuw	a1,a1,a2
 81c:	0685                	addi	a3,a3,1
 81e:	fec7f0e3          	bgeu	a5,a2,7fe <printint+0x2a>
  if (neg)
 822:	00088c63          	beqz	a7,83a <printint+0x66>
    buf[i++] = '-';
 826:	fd070793          	addi	a5,a4,-48
 82a:	00878733          	add	a4,a5,s0
 82e:	02d00793          	li	a5,45
 832:	fef70823          	sb	a5,-16(a4)
 836:	0028071b          	addiw	a4,a6,2

  while (--i >= 0)
 83a:	02e05863          	blez	a4,86a <printint+0x96>
 83e:	fc040793          	addi	a5,s0,-64
 842:	00e78933          	add	s2,a5,a4
 846:	fff78993          	addi	s3,a5,-1
 84a:	99ba                	add	s3,s3,a4
 84c:	377d                	addiw	a4,a4,-1
 84e:	1702                	slli	a4,a4,0x20
 850:	9301                	srli	a4,a4,0x20
 852:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 856:	fff94583          	lbu	a1,-1(s2)
 85a:	8526                	mv	a0,s1
 85c:	00000097          	auipc	ra,0x0
 860:	f56080e7          	jalr	-170(ra) # 7b2 <putc>
  while (--i >= 0)
 864:	197d                	addi	s2,s2,-1
 866:	ff3918e3          	bne	s2,s3,856 <printint+0x82>
}
 86a:	70e2                	ld	ra,56(sp)
 86c:	7442                	ld	s0,48(sp)
 86e:	74a2                	ld	s1,40(sp)
 870:	7902                	ld	s2,32(sp)
 872:	69e2                	ld	s3,24(sp)
 874:	6121                	addi	sp,sp,64
 876:	8082                	ret
    x = -xx;
 878:	40b005bb          	negw	a1,a1
    neg = 1;
 87c:	4885                	li	a7,1
    x = -xx;
 87e:	bf85                	j	7ee <printint+0x1a>

0000000000000880 <vprintf>:
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void vprintf(int fd, const char *fmt, va_list ap)
{
 880:	7119                	addi	sp,sp,-128
 882:	fc86                	sd	ra,120(sp)
 884:	f8a2                	sd	s0,112(sp)
 886:	f4a6                	sd	s1,104(sp)
 888:	f0ca                	sd	s2,96(sp)
 88a:	ecce                	sd	s3,88(sp)
 88c:	e8d2                	sd	s4,80(sp)
 88e:	e4d6                	sd	s5,72(sp)
 890:	e0da                	sd	s6,64(sp)
 892:	fc5e                	sd	s7,56(sp)
 894:	f862                	sd	s8,48(sp)
 896:	f466                	sd	s9,40(sp)
 898:	f06a                	sd	s10,32(sp)
 89a:	ec6e                	sd	s11,24(sp)
 89c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++)
 89e:	0005c903          	lbu	s2,0(a1)
 8a2:	18090f63          	beqz	s2,a40 <vprintf+0x1c0>
 8a6:	8aaa                	mv	s5,a0
 8a8:	8b32                	mv	s6,a2
 8aa:	00158493          	addi	s1,a1,1
  state = 0;
 8ae:	4981                	li	s3,0
      else
      {
        putc(fd, c);
      }
    }
    else if (state == '%')
 8b0:	02500a13          	li	s4,37
 8b4:	4c55                	li	s8,21
 8b6:	00000c97          	auipc	s9,0x0
 8ba:	56ac8c93          	addi	s9,s9,1386 # e20 <malloc+0x2dc>
      else if (c == 's')
      {
        s = va_arg(ap, char *);
        if (s == 0)
          s = "(null)";
        while (*s != 0)
 8be:	02800d93          	li	s11,40
  putc(fd, 'x');
 8c2:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8c4:	00000b97          	auipc	s7,0x0
 8c8:	5b4b8b93          	addi	s7,s7,1460 # e78 <digits>
 8cc:	a839                	j	8ea <vprintf+0x6a>
        putc(fd, c);
 8ce:	85ca                	mv	a1,s2
 8d0:	8556                	mv	a0,s5
 8d2:	00000097          	auipc	ra,0x0
 8d6:	ee0080e7          	jalr	-288(ra) # 7b2 <putc>
 8da:	a019                	j	8e0 <vprintf+0x60>
    else if (state == '%')
 8dc:	01498d63          	beq	s3,s4,8f6 <vprintf+0x76>
  for (i = 0; fmt[i]; i++)
 8e0:	0485                	addi	s1,s1,1
 8e2:	fff4c903          	lbu	s2,-1(s1)
 8e6:	14090d63          	beqz	s2,a40 <vprintf+0x1c0>
    if (state == 0)
 8ea:	fe0999e3          	bnez	s3,8dc <vprintf+0x5c>
      if (c == '%')
 8ee:	ff4910e3          	bne	s2,s4,8ce <vprintf+0x4e>
        state = '%';
 8f2:	89d2                	mv	s3,s4
 8f4:	b7f5                	j	8e0 <vprintf+0x60>
      if (c == 'd')
 8f6:	11490c63          	beq	s2,s4,a0e <vprintf+0x18e>
 8fa:	f9d9079b          	addiw	a5,s2,-99
 8fe:	0ff7f793          	zext.b	a5,a5
 902:	10fc6e63          	bltu	s8,a5,a1e <vprintf+0x19e>
 906:	f9d9079b          	addiw	a5,s2,-99
 90a:	0ff7f713          	zext.b	a4,a5
 90e:	10ec6863          	bltu	s8,a4,a1e <vprintf+0x19e>
 912:	00271793          	slli	a5,a4,0x2
 916:	97e6                	add	a5,a5,s9
 918:	439c                	lw	a5,0(a5)
 91a:	97e6                	add	a5,a5,s9
 91c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 91e:	008b0913          	addi	s2,s6,8
 922:	4685                	li	a3,1
 924:	4629                	li	a2,10
 926:	000b2583          	lw	a1,0(s6)
 92a:	8556                	mv	a0,s5
 92c:	00000097          	auipc	ra,0x0
 930:	ea8080e7          	jalr	-344(ra) # 7d4 <printint>
 934:	8b4a                	mv	s6,s2
      {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 936:	4981                	li	s3,0
 938:	b765                	j	8e0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 93a:	008b0913          	addi	s2,s6,8
 93e:	4681                	li	a3,0
 940:	4629                	li	a2,10
 942:	000b2583          	lw	a1,0(s6)
 946:	8556                	mv	a0,s5
 948:	00000097          	auipc	ra,0x0
 94c:	e8c080e7          	jalr	-372(ra) # 7d4 <printint>
 950:	8b4a                	mv	s6,s2
      state = 0;
 952:	4981                	li	s3,0
 954:	b771                	j	8e0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 956:	008b0913          	addi	s2,s6,8
 95a:	4681                	li	a3,0
 95c:	866a                	mv	a2,s10
 95e:	000b2583          	lw	a1,0(s6)
 962:	8556                	mv	a0,s5
 964:	00000097          	auipc	ra,0x0
 968:	e70080e7          	jalr	-400(ra) # 7d4 <printint>
 96c:	8b4a                	mv	s6,s2
      state = 0;
 96e:	4981                	li	s3,0
 970:	bf85                	j	8e0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 972:	008b0793          	addi	a5,s6,8
 976:	f8f43423          	sd	a5,-120(s0)
 97a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 97e:	03000593          	li	a1,48
 982:	8556                	mv	a0,s5
 984:	00000097          	auipc	ra,0x0
 988:	e2e080e7          	jalr	-466(ra) # 7b2 <putc>
  putc(fd, 'x');
 98c:	07800593          	li	a1,120
 990:	8556                	mv	a0,s5
 992:	00000097          	auipc	ra,0x0
 996:	e20080e7          	jalr	-480(ra) # 7b2 <putc>
 99a:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 99c:	03c9d793          	srli	a5,s3,0x3c
 9a0:	97de                	add	a5,a5,s7
 9a2:	0007c583          	lbu	a1,0(a5)
 9a6:	8556                	mv	a0,s5
 9a8:	00000097          	auipc	ra,0x0
 9ac:	e0a080e7          	jalr	-502(ra) # 7b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9b0:	0992                	slli	s3,s3,0x4
 9b2:	397d                	addiw	s2,s2,-1
 9b4:	fe0914e3          	bnez	s2,99c <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 9b8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 9bc:	4981                	li	s3,0
 9be:	b70d                	j	8e0 <vprintf+0x60>
        s = va_arg(ap, char *);
 9c0:	008b0913          	addi	s2,s6,8
 9c4:	000b3983          	ld	s3,0(s6)
        if (s == 0)
 9c8:	02098163          	beqz	s3,9ea <vprintf+0x16a>
        while (*s != 0)
 9cc:	0009c583          	lbu	a1,0(s3)
 9d0:	c5ad                	beqz	a1,a3a <vprintf+0x1ba>
          putc(fd, *s);
 9d2:	8556                	mv	a0,s5
 9d4:	00000097          	auipc	ra,0x0
 9d8:	dde080e7          	jalr	-546(ra) # 7b2 <putc>
          s++;
 9dc:	0985                	addi	s3,s3,1
        while (*s != 0)
 9de:	0009c583          	lbu	a1,0(s3)
 9e2:	f9e5                	bnez	a1,9d2 <vprintf+0x152>
        s = va_arg(ap, char *);
 9e4:	8b4a                	mv	s6,s2
      state = 0;
 9e6:	4981                	li	s3,0
 9e8:	bde5                	j	8e0 <vprintf+0x60>
          s = "(null)";
 9ea:	00000997          	auipc	s3,0x0
 9ee:	42e98993          	addi	s3,s3,1070 # e18 <malloc+0x2d4>
        while (*s != 0)
 9f2:	85ee                	mv	a1,s11
 9f4:	bff9                	j	9d2 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 9f6:	008b0913          	addi	s2,s6,8
 9fa:	000b4583          	lbu	a1,0(s6)
 9fe:	8556                	mv	a0,s5
 a00:	00000097          	auipc	ra,0x0
 a04:	db2080e7          	jalr	-590(ra) # 7b2 <putc>
 a08:	8b4a                	mv	s6,s2
      state = 0;
 a0a:	4981                	li	s3,0
 a0c:	bdd1                	j	8e0 <vprintf+0x60>
        putc(fd, c);
 a0e:	85d2                	mv	a1,s4
 a10:	8556                	mv	a0,s5
 a12:	00000097          	auipc	ra,0x0
 a16:	da0080e7          	jalr	-608(ra) # 7b2 <putc>
      state = 0;
 a1a:	4981                	li	s3,0
 a1c:	b5d1                	j	8e0 <vprintf+0x60>
        putc(fd, '%');
 a1e:	85d2                	mv	a1,s4
 a20:	8556                	mv	a0,s5
 a22:	00000097          	auipc	ra,0x0
 a26:	d90080e7          	jalr	-624(ra) # 7b2 <putc>
        putc(fd, c);
 a2a:	85ca                	mv	a1,s2
 a2c:	8556                	mv	a0,s5
 a2e:	00000097          	auipc	ra,0x0
 a32:	d84080e7          	jalr	-636(ra) # 7b2 <putc>
      state = 0;
 a36:	4981                	li	s3,0
 a38:	b565                	j	8e0 <vprintf+0x60>
        s = va_arg(ap, char *);
 a3a:	8b4a                	mv	s6,s2
      state = 0;
 a3c:	4981                	li	s3,0
 a3e:	b54d                	j	8e0 <vprintf+0x60>
    }
  }
}
 a40:	70e6                	ld	ra,120(sp)
 a42:	7446                	ld	s0,112(sp)
 a44:	74a6                	ld	s1,104(sp)
 a46:	7906                	ld	s2,96(sp)
 a48:	69e6                	ld	s3,88(sp)
 a4a:	6a46                	ld	s4,80(sp)
 a4c:	6aa6                	ld	s5,72(sp)
 a4e:	6b06                	ld	s6,64(sp)
 a50:	7be2                	ld	s7,56(sp)
 a52:	7c42                	ld	s8,48(sp)
 a54:	7ca2                	ld	s9,40(sp)
 a56:	7d02                	ld	s10,32(sp)
 a58:	6de2                	ld	s11,24(sp)
 a5a:	6109                	addi	sp,sp,128
 a5c:	8082                	ret

0000000000000a5e <fprintf>:

void fprintf(int fd, const char *fmt, ...)
{
 a5e:	715d                	addi	sp,sp,-80
 a60:	ec06                	sd	ra,24(sp)
 a62:	e822                	sd	s0,16(sp)
 a64:	1000                	addi	s0,sp,32
 a66:	e010                	sd	a2,0(s0)
 a68:	e414                	sd	a3,8(s0)
 a6a:	e818                	sd	a4,16(s0)
 a6c:	ec1c                	sd	a5,24(s0)
 a6e:	03043023          	sd	a6,32(s0)
 a72:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a76:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a7a:	8622                	mv	a2,s0
 a7c:	00000097          	auipc	ra,0x0
 a80:	e04080e7          	jalr	-508(ra) # 880 <vprintf>
}
 a84:	60e2                	ld	ra,24(sp)
 a86:	6442                	ld	s0,16(sp)
 a88:	6161                	addi	sp,sp,80
 a8a:	8082                	ret

0000000000000a8c <printf>:

void printf(const char *fmt, ...)
{
 a8c:	711d                	addi	sp,sp,-96
 a8e:	ec06                	sd	ra,24(sp)
 a90:	e822                	sd	s0,16(sp)
 a92:	1000                	addi	s0,sp,32
 a94:	e40c                	sd	a1,8(s0)
 a96:	e810                	sd	a2,16(s0)
 a98:	ec14                	sd	a3,24(s0)
 a9a:	f018                	sd	a4,32(s0)
 a9c:	f41c                	sd	a5,40(s0)
 a9e:	03043823          	sd	a6,48(s0)
 aa2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 aa6:	00840613          	addi	a2,s0,8
 aaa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 aae:	85aa                	mv	a1,a0
 ab0:	4505                	li	a0,1
 ab2:	00000097          	auipc	ra,0x0
 ab6:	dce080e7          	jalr	-562(ra) # 880 <vprintf>
}
 aba:	60e2                	ld	ra,24(sp)
 abc:	6442                	ld	s0,16(sp)
 abe:	6125                	addi	sp,sp,96
 ac0:	8082                	ret

0000000000000ac2 <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
 ac2:	1141                	addi	sp,sp,-16
 ac4:	e422                	sd	s0,8(sp)
 ac6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 ac8:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 acc:	00000797          	auipc	a5,0x0
 ad0:	53c7b783          	ld	a5,1340(a5) # 1008 <freep>
 ad4:	a02d                	j	afe <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr)
  {
    bp->s.size += p->s.ptr->s.size;
 ad6:	4618                	lw	a4,8(a2)
 ad8:	9f2d                	addw	a4,a4,a1
 ada:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ade:	6398                	ld	a4,0(a5)
 ae0:	6310                	ld	a2,0(a4)
 ae2:	a83d                	j	b20 <free+0x5e>
  }
  else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp)
  {
    p->s.size += bp->s.size;
 ae4:	ff852703          	lw	a4,-8(a0)
 ae8:	9f31                	addw	a4,a4,a2
 aea:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 aec:	ff053683          	ld	a3,-16(a0)
 af0:	a091                	j	b34 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 af2:	6398                	ld	a4,0(a5)
 af4:	00e7e463          	bltu	a5,a4,afc <free+0x3a>
 af8:	00e6ea63          	bltu	a3,a4,b0c <free+0x4a>
{
 afc:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 afe:	fed7fae3          	bgeu	a5,a3,af2 <free+0x30>
 b02:	6398                	ld	a4,0(a5)
 b04:	00e6e463          	bltu	a3,a4,b0c <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b08:	fee7eae3          	bltu	a5,a4,afc <free+0x3a>
  if (bp + bp->s.size == p->s.ptr)
 b0c:	ff852583          	lw	a1,-8(a0)
 b10:	6390                	ld	a2,0(a5)
 b12:	02059813          	slli	a6,a1,0x20
 b16:	01c85713          	srli	a4,a6,0x1c
 b1a:	9736                	add	a4,a4,a3
 b1c:	fae60de3          	beq	a2,a4,ad6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 b20:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp)
 b24:	4790                	lw	a2,8(a5)
 b26:	02061593          	slli	a1,a2,0x20
 b2a:	01c5d713          	srli	a4,a1,0x1c
 b2e:	973e                	add	a4,a4,a5
 b30:	fae68ae3          	beq	a3,a4,ae4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 b34:	e394                	sd	a3,0(a5)
  }
  else
    p->s.ptr = bp;
  freep = p;
 b36:	00000717          	auipc	a4,0x0
 b3a:	4cf73923          	sd	a5,1234(a4) # 1008 <freep>
}
 b3e:	6422                	ld	s0,8(sp)
 b40:	0141                	addi	sp,sp,16
 b42:	8082                	ret

0000000000000b44 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 b44:	7139                	addi	sp,sp,-64
 b46:	fc06                	sd	ra,56(sp)
 b48:	f822                	sd	s0,48(sp)
 b4a:	f426                	sd	s1,40(sp)
 b4c:	f04a                	sd	s2,32(sp)
 b4e:	ec4e                	sd	s3,24(sp)
 b50:	e852                	sd	s4,16(sp)
 b52:	e456                	sd	s5,8(sp)
 b54:	e05a                	sd	s6,0(sp)
 b56:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 b58:	02051493          	slli	s1,a0,0x20
 b5c:	9081                	srli	s1,s1,0x20
 b5e:	04bd                	addi	s1,s1,15
 b60:	8091                	srli	s1,s1,0x4
 b62:	0014899b          	addiw	s3,s1,1
 b66:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0)
 b68:	00000517          	auipc	a0,0x0
 b6c:	4a053503          	ld	a0,1184(a0) # 1008 <freep>
 b70:	c515                	beqz	a0,b9c <malloc+0x58>
  {
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
 b72:	611c                	ld	a5,0(a0)
  {
    if (p->s.size >= nunits)
 b74:	4798                	lw	a4,8(a5)
 b76:	02977f63          	bgeu	a4,s1,bb4 <malloc+0x70>
 b7a:	8a4e                	mv	s4,s3
 b7c:	0009871b          	sext.w	a4,s3
 b80:	6685                	lui	a3,0x1
 b82:	00d77363          	bgeu	a4,a3,b88 <malloc+0x44>
 b86:	6a05                	lui	s4,0x1
 b88:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b8c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 b90:	00000917          	auipc	s2,0x0
 b94:	47890913          	addi	s2,s2,1144 # 1008 <freep>
  if (p == (char *)-1)
 b98:	5afd                	li	s5,-1
 b9a:	a895                	j	c0e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 b9c:	00000797          	auipc	a5,0x0
 ba0:	47478793          	addi	a5,a5,1140 # 1010 <base>
 ba4:	00000717          	auipc	a4,0x0
 ba8:	46f73223          	sd	a5,1124(a4) # 1008 <freep>
 bac:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bae:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits)
 bb2:	b7e1                	j	b7a <malloc+0x36>
      if (p->s.size == nunits)
 bb4:	02e48c63          	beq	s1,a4,bec <malloc+0xa8>
        p->s.size -= nunits;
 bb8:	4137073b          	subw	a4,a4,s3
 bbc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bbe:	02071693          	slli	a3,a4,0x20
 bc2:	01c6d713          	srli	a4,a3,0x1c
 bc6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bc8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bcc:	00000717          	auipc	a4,0x0
 bd0:	42a73e23          	sd	a0,1084(a4) # 1008 <freep>
      return (void *)(p + 1);
 bd4:	01078513          	addi	a0,a5,16
      if ((p = morecore(nunits)) == 0)
        return 0;
  }
}
 bd8:	70e2                	ld	ra,56(sp)
 bda:	7442                	ld	s0,48(sp)
 bdc:	74a2                	ld	s1,40(sp)
 bde:	7902                	ld	s2,32(sp)
 be0:	69e2                	ld	s3,24(sp)
 be2:	6a42                	ld	s4,16(sp)
 be4:	6aa2                	ld	s5,8(sp)
 be6:	6b02                	ld	s6,0(sp)
 be8:	6121                	addi	sp,sp,64
 bea:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 bec:	6398                	ld	a4,0(a5)
 bee:	e118                	sd	a4,0(a0)
 bf0:	bff1                	j	bcc <malloc+0x88>
  hp->s.size = nu;
 bf2:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 bf6:	0541                	addi	a0,a0,16
 bf8:	00000097          	auipc	ra,0x0
 bfc:	eca080e7          	jalr	-310(ra) # ac2 <free>
  return freep;
 c00:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 c04:	d971                	beqz	a0,bd8 <malloc+0x94>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
 c06:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits)
 c08:	4798                	lw	a4,8(a5)
 c0a:	fa9775e3          	bgeu	a4,s1,bb4 <malloc+0x70>
    if (p == freep)
 c0e:	00093703          	ld	a4,0(s2)
 c12:	853e                	mv	a0,a5
 c14:	fef719e3          	bne	a4,a5,c06 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 c18:	8552                	mv	a0,s4
 c1a:	00000097          	auipc	ra,0x0
 c1e:	b68080e7          	jalr	-1176(ra) # 782 <sbrk>
  if (p == (char *)-1)
 c22:	fd5518e3          	bne	a0,s5,bf2 <malloc+0xae>
        return 0;
 c26:	4501                	li	a0,0
 c28:	bf45                	j	bd8 <malloc+0x94>
