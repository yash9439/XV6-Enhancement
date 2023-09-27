
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
  }
}

// what if you pass ridiculous string pointers to system calls?
void copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16

  for (int ai = 0; ai < 2; ai++)
  {
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE | O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	a02080e7          	jalr	-1534(ra) # 5a12 <open>
    if (fd >= 0)
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE | O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	9f0080e7          	jalr	-1552(ra) # 5a12 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if (fd >= 0)
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
    {
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	ed250513          	addi	a0,a0,-302 # 5f10 <malloc+0xf4>
      46:	00006097          	auipc	ra,0x6
      4a:	d1e080e7          	jalr	-738(ra) # 5d64 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	982080e7          	jalr	-1662(ra) # 59d2 <exit>

0000000000000058 <preempt>:
  exit(0);
}

// meant to be run w/ at most two CPUs
void preempt(char *s)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16

#if defined MLFQ || defined FCFS
  exit(0);
      60:	4501                	li	a0,0
      62:	00006097          	auipc	ra,0x6
      66:	970080e7          	jalr	-1680(ra) # 59d2 <exit>

000000000000006a <bsstest>:
char uninit[10000];
void bsstest(char *s)
{
  int i;

  for (i = 0; i < sizeof(uninit); i++)
      6a:	0000a797          	auipc	a5,0xa
      6e:	4fe78793          	addi	a5,a5,1278 # a568 <uninit>
      72:	0000d697          	auipc	a3,0xd
      76:	c0668693          	addi	a3,a3,-1018 # cc78 <buf>
  {
    if (uninit[i] != '\0')
      7a:	0007c703          	lbu	a4,0(a5)
      7e:	e709                	bnez	a4,88 <bsstest+0x1e>
  for (i = 0; i < sizeof(uninit); i++)
      80:	0785                	addi	a5,a5,1
      82:	fed79ce3          	bne	a5,a3,7a <bsstest+0x10>
      86:	8082                	ret
{
      88:	1141                	addi	sp,sp,-16
      8a:	e406                	sd	ra,8(sp)
      8c:	e022                	sd	s0,0(sp)
      8e:	0800                	addi	s0,sp,16
    {
      printf("%s: bss test failed\n", s);
      90:	85aa                	mv	a1,a0
      92:	00006517          	auipc	a0,0x6
      96:	e9e50513          	addi	a0,a0,-354 # 5f30 <malloc+0x114>
      9a:	00006097          	auipc	ra,0x6
      9e:	cca080e7          	jalr	-822(ra) # 5d64 <printf>
      exit(1);
      a2:	4505                	li	a0,1
      a4:	00006097          	auipc	ra,0x6
      a8:	92e080e7          	jalr	-1746(ra) # 59d2 <exit>

00000000000000ac <textwrite>:
    exit(xstatus);
}

// check that writes to text segment fault
void textwrite(char *s)
{
      ac:	1141                	addi	sp,sp,-16
      ae:	e406                	sd	ra,8(sp)
      b0:	e022                	sd	s0,0(sp)
      b2:	0800                	addi	s0,sp,16
  exit(0);
      b4:	4501                	li	a0,0
      b6:	00006097          	auipc	ra,0x6
      ba:	91c080e7          	jalr	-1764(ra) # 59d2 <exit>

00000000000000be <opentest>:
{
      be:	1101                	addi	sp,sp,-32
      c0:	ec06                	sd	ra,24(sp)
      c2:	e822                	sd	s0,16(sp)
      c4:	e426                	sd	s1,8(sp)
      c6:	1000                	addi	s0,sp,32
      c8:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      ca:	4581                	li	a1,0
      cc:	00006517          	auipc	a0,0x6
      d0:	e7c50513          	addi	a0,a0,-388 # 5f48 <malloc+0x12c>
      d4:	00006097          	auipc	ra,0x6
      d8:	93e080e7          	jalr	-1730(ra) # 5a12 <open>
  if (fd < 0)
      dc:	02054663          	bltz	a0,108 <opentest+0x4a>
  close(fd);
      e0:	00006097          	auipc	ra,0x6
      e4:	91a080e7          	jalr	-1766(ra) # 59fa <close>
  fd = open("doesnotexist", 0);
      e8:	4581                	li	a1,0
      ea:	00006517          	auipc	a0,0x6
      ee:	e7e50513          	addi	a0,a0,-386 # 5f68 <malloc+0x14c>
      f2:	00006097          	auipc	ra,0x6
      f6:	920080e7          	jalr	-1760(ra) # 5a12 <open>
  if (fd >= 0)
      fa:	02055563          	bgez	a0,124 <opentest+0x66>
}
      fe:	60e2                	ld	ra,24(sp)
     100:	6442                	ld	s0,16(sp)
     102:	64a2                	ld	s1,8(sp)
     104:	6105                	addi	sp,sp,32
     106:	8082                	ret
    printf("%s: open echo failed!\n", s);
     108:	85a6                	mv	a1,s1
     10a:	00006517          	auipc	a0,0x6
     10e:	e4650513          	addi	a0,a0,-442 # 5f50 <malloc+0x134>
     112:	00006097          	auipc	ra,0x6
     116:	c52080e7          	jalr	-942(ra) # 5d64 <printf>
    exit(1);
     11a:	4505                	li	a0,1
     11c:	00006097          	auipc	ra,0x6
     120:	8b6080e7          	jalr	-1866(ra) # 59d2 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     124:	85a6                	mv	a1,s1
     126:	00006517          	auipc	a0,0x6
     12a:	e5250513          	addi	a0,a0,-430 # 5f78 <malloc+0x15c>
     12e:	00006097          	auipc	ra,0x6
     132:	c36080e7          	jalr	-970(ra) # 5d64 <printf>
    exit(1);
     136:	4505                	li	a0,1
     138:	00006097          	auipc	ra,0x6
     13c:	89a080e7          	jalr	-1894(ra) # 59d2 <exit>

0000000000000140 <truncate2>:
{
     140:	7179                	addi	sp,sp,-48
     142:	f406                	sd	ra,40(sp)
     144:	f022                	sd	s0,32(sp)
     146:	ec26                	sd	s1,24(sp)
     148:	e84a                	sd	s2,16(sp)
     14a:	e44e                	sd	s3,8(sp)
     14c:	1800                	addi	s0,sp,48
     14e:	89aa                	mv	s3,a0
  unlink("truncfile");
     150:	00006517          	auipc	a0,0x6
     154:	e5050513          	addi	a0,a0,-432 # 5fa0 <malloc+0x184>
     158:	00006097          	auipc	ra,0x6
     15c:	8ca080e7          	jalr	-1846(ra) # 5a22 <unlink>
  int fd1 = open("truncfile", O_CREATE | O_TRUNC | O_WRONLY);
     160:	60100593          	li	a1,1537
     164:	00006517          	auipc	a0,0x6
     168:	e3c50513          	addi	a0,a0,-452 # 5fa0 <malloc+0x184>
     16c:	00006097          	auipc	ra,0x6
     170:	8a6080e7          	jalr	-1882(ra) # 5a12 <open>
     174:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     176:	4611                	li	a2,4
     178:	00006597          	auipc	a1,0x6
     17c:	e3858593          	addi	a1,a1,-456 # 5fb0 <malloc+0x194>
     180:	00006097          	auipc	ra,0x6
     184:	872080e7          	jalr	-1934(ra) # 59f2 <write>
  int fd2 = open("truncfile", O_TRUNC | O_WRONLY);
     188:	40100593          	li	a1,1025
     18c:	00006517          	auipc	a0,0x6
     190:	e1450513          	addi	a0,a0,-492 # 5fa0 <malloc+0x184>
     194:	00006097          	auipc	ra,0x6
     198:	87e080e7          	jalr	-1922(ra) # 5a12 <open>
     19c:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     19e:	4605                	li	a2,1
     1a0:	00006597          	auipc	a1,0x6
     1a4:	e1858593          	addi	a1,a1,-488 # 5fb8 <malloc+0x19c>
     1a8:	8526                	mv	a0,s1
     1aa:	00006097          	auipc	ra,0x6
     1ae:	848080e7          	jalr	-1976(ra) # 59f2 <write>
  if (n != -1)
     1b2:	57fd                	li	a5,-1
     1b4:	02f51b63          	bne	a0,a5,1ea <truncate2+0xaa>
  unlink("truncfile");
     1b8:	00006517          	auipc	a0,0x6
     1bc:	de850513          	addi	a0,a0,-536 # 5fa0 <malloc+0x184>
     1c0:	00006097          	auipc	ra,0x6
     1c4:	862080e7          	jalr	-1950(ra) # 5a22 <unlink>
  close(fd1);
     1c8:	8526                	mv	a0,s1
     1ca:	00006097          	auipc	ra,0x6
     1ce:	830080e7          	jalr	-2000(ra) # 59fa <close>
  close(fd2);
     1d2:	854a                	mv	a0,s2
     1d4:	00006097          	auipc	ra,0x6
     1d8:	826080e7          	jalr	-2010(ra) # 59fa <close>
}
     1dc:	70a2                	ld	ra,40(sp)
     1de:	7402                	ld	s0,32(sp)
     1e0:	64e2                	ld	s1,24(sp)
     1e2:	6942                	ld	s2,16(sp)
     1e4:	69a2                	ld	s3,8(sp)
     1e6:	6145                	addi	sp,sp,48
     1e8:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1ea:	862a                	mv	a2,a0
     1ec:	85ce                	mv	a1,s3
     1ee:	00006517          	auipc	a0,0x6
     1f2:	dd250513          	addi	a0,a0,-558 # 5fc0 <malloc+0x1a4>
     1f6:	00006097          	auipc	ra,0x6
     1fa:	b6e080e7          	jalr	-1170(ra) # 5d64 <printf>
    exit(1);
     1fe:	4505                	li	a0,1
     200:	00005097          	auipc	ra,0x5
     204:	7d2080e7          	jalr	2002(ra) # 59d2 <exit>

0000000000000208 <createtest>:
{
     208:	7179                	addi	sp,sp,-48
     20a:	f406                	sd	ra,40(sp)
     20c:	f022                	sd	s0,32(sp)
     20e:	ec26                	sd	s1,24(sp)
     210:	e84a                	sd	s2,16(sp)
     212:	1800                	addi	s0,sp,48
  name[0] = 'a';
     214:	06100793          	li	a5,97
     218:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     21c:	fc040d23          	sb	zero,-38(s0)
     220:	03000493          	li	s1,48
  for (i = 0; i < N; i++)
     224:	06400913          	li	s2,100
    name[1] = '0' + i;
     228:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE | O_RDWR);
     22c:	20200593          	li	a1,514
     230:	fd840513          	addi	a0,s0,-40
     234:	00005097          	auipc	ra,0x5
     238:	7de080e7          	jalr	2014(ra) # 5a12 <open>
    close(fd);
     23c:	00005097          	auipc	ra,0x5
     240:	7be080e7          	jalr	1982(ra) # 59fa <close>
  for (i = 0; i < N; i++)
     244:	2485                	addiw	s1,s1,1
     246:	0ff4f493          	zext.b	s1,s1
     24a:	fd249fe3          	bne	s1,s2,228 <createtest+0x20>
  name[0] = 'a';
     24e:	06100793          	li	a5,97
     252:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     256:	fc040d23          	sb	zero,-38(s0)
     25a:	03000493          	li	s1,48
  for (i = 0; i < N; i++)
     25e:	06400913          	li	s2,100
    name[1] = '0' + i;
     262:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     266:	fd840513          	addi	a0,s0,-40
     26a:	00005097          	auipc	ra,0x5
     26e:	7b8080e7          	jalr	1976(ra) # 5a22 <unlink>
  for (i = 0; i < N; i++)
     272:	2485                	addiw	s1,s1,1
     274:	0ff4f493          	zext.b	s1,s1
     278:	ff2495e3          	bne	s1,s2,262 <createtest+0x5a>
}
     27c:	70a2                	ld	ra,40(sp)
     27e:	7402                	ld	s0,32(sp)
     280:	64e2                	ld	s1,24(sp)
     282:	6942                	ld	s2,16(sp)
     284:	6145                	addi	sp,sp,48
     286:	8082                	ret

0000000000000288 <bigwrite>:
{
     288:	715d                	addi	sp,sp,-80
     28a:	e486                	sd	ra,72(sp)
     28c:	e0a2                	sd	s0,64(sp)
     28e:	fc26                	sd	s1,56(sp)
     290:	f84a                	sd	s2,48(sp)
     292:	f44e                	sd	s3,40(sp)
     294:	f052                	sd	s4,32(sp)
     296:	ec56                	sd	s5,24(sp)
     298:	e85a                	sd	s6,16(sp)
     29a:	e45e                	sd	s7,8(sp)
     29c:	0880                	addi	s0,sp,80
     29e:	8baa                	mv	s7,a0
  unlink("bigwrite");
     2a0:	00006517          	auipc	a0,0x6
     2a4:	d4850513          	addi	a0,a0,-696 # 5fe8 <malloc+0x1cc>
     2a8:	00005097          	auipc	ra,0x5
     2ac:	77a080e7          	jalr	1914(ra) # 5a22 <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471)
     2b0:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2b4:	00006a97          	auipc	s5,0x6
     2b8:	d34a8a93          	addi	s5,s5,-716 # 5fe8 <malloc+0x1cc>
      int cc = write(fd, buf, sz);
     2bc:	0000da17          	auipc	s4,0xd
     2c0:	9bca0a13          	addi	s4,s4,-1604 # cc78 <buf>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471)
     2c4:	6b0d                	lui	s6,0x3
     2c6:	1c9b0b13          	addi	s6,s6,457 # 31c9 <diskfull+0x51>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ca:	20200593          	li	a1,514
     2ce:	8556                	mv	a0,s5
     2d0:	00005097          	auipc	ra,0x5
     2d4:	742080e7          	jalr	1858(ra) # 5a12 <open>
     2d8:	892a                	mv	s2,a0
    if (fd < 0)
     2da:	04054d63          	bltz	a0,334 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2de:	8626                	mv	a2,s1
     2e0:	85d2                	mv	a1,s4
     2e2:	00005097          	auipc	ra,0x5
     2e6:	710080e7          	jalr	1808(ra) # 59f2 <write>
     2ea:	89aa                	mv	s3,a0
      if (cc != sz)
     2ec:	06a49263          	bne	s1,a0,350 <bigwrite+0xc8>
      int cc = write(fd, buf, sz);
     2f0:	8626                	mv	a2,s1
     2f2:	85d2                	mv	a1,s4
     2f4:	854a                	mv	a0,s2
     2f6:	00005097          	auipc	ra,0x5
     2fa:	6fc080e7          	jalr	1788(ra) # 59f2 <write>
      if (cc != sz)
     2fe:	04951a63          	bne	a0,s1,352 <bigwrite+0xca>
    close(fd);
     302:	854a                	mv	a0,s2
     304:	00005097          	auipc	ra,0x5
     308:	6f6080e7          	jalr	1782(ra) # 59fa <close>
    unlink("bigwrite");
     30c:	8556                	mv	a0,s5
     30e:	00005097          	auipc	ra,0x5
     312:	714080e7          	jalr	1812(ra) # 5a22 <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471)
     316:	1d74849b          	addiw	s1,s1,471
     31a:	fb6498e3          	bne	s1,s6,2ca <bigwrite+0x42>
}
     31e:	60a6                	ld	ra,72(sp)
     320:	6406                	ld	s0,64(sp)
     322:	74e2                	ld	s1,56(sp)
     324:	7942                	ld	s2,48(sp)
     326:	79a2                	ld	s3,40(sp)
     328:	7a02                	ld	s4,32(sp)
     32a:	6ae2                	ld	s5,24(sp)
     32c:	6b42                	ld	s6,16(sp)
     32e:	6ba2                	ld	s7,8(sp)
     330:	6161                	addi	sp,sp,80
     332:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	cc250513          	addi	a0,a0,-830 # 5ff8 <malloc+0x1dc>
     33e:	00006097          	auipc	ra,0x6
     342:	a26080e7          	jalr	-1498(ra) # 5d64 <printf>
      exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	68a080e7          	jalr	1674(ra) # 59d2 <exit>
      if (cc != sz)
     350:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     352:	86aa                	mv	a3,a0
     354:	864e                	mv	a2,s3
     356:	85de                	mv	a1,s7
     358:	00006517          	auipc	a0,0x6
     35c:	cc050513          	addi	a0,a0,-832 # 6018 <malloc+0x1fc>
     360:	00006097          	auipc	ra,0x6
     364:	a04080e7          	jalr	-1532(ra) # 5d64 <printf>
        exit(1);
     368:	4505                	li	a0,1
     36a:	00005097          	auipc	ra,0x5
     36e:	668080e7          	jalr	1640(ra) # 59d2 <exit>

0000000000000372 <badwrite>:
// a block to be allocated for a file that is then not freed when the
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void badwrite(char *s)
{
     372:	7179                	addi	sp,sp,-48
     374:	f406                	sd	ra,40(sp)
     376:	f022                	sd	s0,32(sp)
     378:	ec26                	sd	s1,24(sp)
     37a:	e84a                	sd	s2,16(sp)
     37c:	e44e                	sd	s3,8(sp)
     37e:	e052                	sd	s4,0(sp)
     380:	1800                	addi	s0,sp,48
  int assumed_free = 600;

  unlink("junk");
     382:	00006517          	auipc	a0,0x6
     386:	cae50513          	addi	a0,a0,-850 # 6030 <malloc+0x214>
     38a:	00005097          	auipc	ra,0x5
     38e:	698080e7          	jalr	1688(ra) # 5a22 <unlink>
     392:	25800913          	li	s2,600
  for (int i = 0; i < assumed_free; i++)
  {
    int fd = open("junk", O_CREATE | O_WRONLY);
     396:	00006997          	auipc	s3,0x6
     39a:	c9a98993          	addi	s3,s3,-870 # 6030 <malloc+0x214>
    if (fd < 0)
    {
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char *)0xffffffffffL, 1);
     39e:	5a7d                	li	s4,-1
     3a0:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE | O_WRONLY);
     3a4:	20100593          	li	a1,513
     3a8:	854e                	mv	a0,s3
     3aa:	00005097          	auipc	ra,0x5
     3ae:	668080e7          	jalr	1640(ra) # 5a12 <open>
     3b2:	84aa                	mv	s1,a0
    if (fd < 0)
     3b4:	06054b63          	bltz	a0,42a <badwrite+0xb8>
    write(fd, (char *)0xffffffffffL, 1);
     3b8:	4605                	li	a2,1
     3ba:	85d2                	mv	a1,s4
     3bc:	00005097          	auipc	ra,0x5
     3c0:	636080e7          	jalr	1590(ra) # 59f2 <write>
    close(fd);
     3c4:	8526                	mv	a0,s1
     3c6:	00005097          	auipc	ra,0x5
     3ca:	634080e7          	jalr	1588(ra) # 59fa <close>
    unlink("junk");
     3ce:	854e                	mv	a0,s3
     3d0:	00005097          	auipc	ra,0x5
     3d4:	652080e7          	jalr	1618(ra) # 5a22 <unlink>
  for (int i = 0; i < assumed_free; i++)
     3d8:	397d                	addiw	s2,s2,-1
     3da:	fc0915e3          	bnez	s2,3a4 <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE | O_WRONLY);
     3de:	20100593          	li	a1,513
     3e2:	00006517          	auipc	a0,0x6
     3e6:	c4e50513          	addi	a0,a0,-946 # 6030 <malloc+0x214>
     3ea:	00005097          	auipc	ra,0x5
     3ee:	628080e7          	jalr	1576(ra) # 5a12 <open>
     3f2:	84aa                	mv	s1,a0
  if (fd < 0)
     3f4:	04054863          	bltz	a0,444 <badwrite+0xd2>
  {
    printf("open junk failed\n");
    exit(1);
  }
  if (write(fd, "x", 1) != 1)
     3f8:	4605                	li	a2,1
     3fa:	00006597          	auipc	a1,0x6
     3fe:	bbe58593          	addi	a1,a1,-1090 # 5fb8 <malloc+0x19c>
     402:	00005097          	auipc	ra,0x5
     406:	5f0080e7          	jalr	1520(ra) # 59f2 <write>
     40a:	4785                	li	a5,1
     40c:	04f50963          	beq	a0,a5,45e <badwrite+0xec>
  {
    printf("write failed\n");
     410:	00006517          	auipc	a0,0x6
     414:	c4050513          	addi	a0,a0,-960 # 6050 <malloc+0x234>
     418:	00006097          	auipc	ra,0x6
     41c:	94c080e7          	jalr	-1716(ra) # 5d64 <printf>
    exit(1);
     420:	4505                	li	a0,1
     422:	00005097          	auipc	ra,0x5
     426:	5b0080e7          	jalr	1456(ra) # 59d2 <exit>
      printf("open junk failed\n");
     42a:	00006517          	auipc	a0,0x6
     42e:	c0e50513          	addi	a0,a0,-1010 # 6038 <malloc+0x21c>
     432:	00006097          	auipc	ra,0x6
     436:	932080e7          	jalr	-1742(ra) # 5d64 <printf>
      exit(1);
     43a:	4505                	li	a0,1
     43c:	00005097          	auipc	ra,0x5
     440:	596080e7          	jalr	1430(ra) # 59d2 <exit>
    printf("open junk failed\n");
     444:	00006517          	auipc	a0,0x6
     448:	bf450513          	addi	a0,a0,-1036 # 6038 <malloc+0x21c>
     44c:	00006097          	auipc	ra,0x6
     450:	918080e7          	jalr	-1768(ra) # 5d64 <printf>
    exit(1);
     454:	4505                	li	a0,1
     456:	00005097          	auipc	ra,0x5
     45a:	57c080e7          	jalr	1404(ra) # 59d2 <exit>
  }
  close(fd);
     45e:	8526                	mv	a0,s1
     460:	00005097          	auipc	ra,0x5
     464:	59a080e7          	jalr	1434(ra) # 59fa <close>
  unlink("junk");
     468:	00006517          	auipc	a0,0x6
     46c:	bc850513          	addi	a0,a0,-1080 # 6030 <malloc+0x214>
     470:	00005097          	auipc	ra,0x5
     474:	5b2080e7          	jalr	1458(ra) # 5a22 <unlink>

  exit(0);
     478:	4501                	li	a0,0
     47a:	00005097          	auipc	ra,0x5
     47e:	558080e7          	jalr	1368(ra) # 59d2 <exit>

0000000000000482 <outofinodes>:
    unlink(name);
  }
}

void outofinodes(char *s)
{
     482:	715d                	addi	sp,sp,-80
     484:	e486                	sd	ra,72(sp)
     486:	e0a2                	sd	s0,64(sp)
     488:	fc26                	sd	s1,56(sp)
     48a:	f84a                	sd	s2,48(sp)
     48c:	f44e                	sd	s3,40(sp)
     48e:	0880                	addi	s0,sp,80
  int nzz = 32 * 32;
  for (int i = 0; i < nzz; i++)
     490:	4481                	li	s1,0
  {
    char name[32];
    name[0] = 'z';
     492:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
     496:	40000993          	li	s3,1024
    name[0] = 'z';
     49a:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     49e:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4a2:	41f4d71b          	sraiw	a4,s1,0x1f
     4a6:	01b7571b          	srliw	a4,a4,0x1b
     4aa:	009707bb          	addw	a5,a4,s1
     4ae:	4057d69b          	sraiw	a3,a5,0x5
     4b2:	0306869b          	addiw	a3,a3,48
     4b6:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     4ba:	8bfd                	andi	a5,a5,31
     4bc:	9f99                	subw	a5,a5,a4
     4be:	0307879b          	addiw	a5,a5,48
     4c2:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4c6:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     4ca:	fb040513          	addi	a0,s0,-80
     4ce:	00005097          	auipc	ra,0x5
     4d2:	554080e7          	jalr	1364(ra) # 5a22 <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
     4d6:	60200593          	li	a1,1538
     4da:	fb040513          	addi	a0,s0,-80
     4de:	00005097          	auipc	ra,0x5
     4e2:	534080e7          	jalr	1332(ra) # 5a12 <open>
    if (fd < 0)
     4e6:	00054963          	bltz	a0,4f8 <outofinodes+0x76>
    {
      // failure is eventually expected.
      break;
    }
    close(fd);
     4ea:	00005097          	auipc	ra,0x5
     4ee:	510080e7          	jalr	1296(ra) # 59fa <close>
  for (int i = 0; i < nzz; i++)
     4f2:	2485                	addiw	s1,s1,1
     4f4:	fb3493e3          	bne	s1,s3,49a <outofinodes+0x18>
     4f8:	4481                	li	s1,0
  }

  for (int i = 0; i < nzz; i++)
  {
    char name[32];
    name[0] = 'z';
     4fa:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
     4fe:	40000993          	li	s3,1024
    name[0] = 'z';
     502:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     506:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     50a:	41f4d71b          	sraiw	a4,s1,0x1f
     50e:	01b7571b          	srliw	a4,a4,0x1b
     512:	009707bb          	addw	a5,a4,s1
     516:	4057d69b          	sraiw	a3,a5,0x5
     51a:	0306869b          	addiw	a3,a3,48
     51e:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     522:	8bfd                	andi	a5,a5,31
     524:	9f99                	subw	a5,a5,a4
     526:	0307879b          	addiw	a5,a5,48
     52a:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     52e:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     532:	fb040513          	addi	a0,s0,-80
     536:	00005097          	auipc	ra,0x5
     53a:	4ec080e7          	jalr	1260(ra) # 5a22 <unlink>
  for (int i = 0; i < nzz; i++)
     53e:	2485                	addiw	s1,s1,1
     540:	fd3491e3          	bne	s1,s3,502 <outofinodes+0x80>
  }
}
     544:	60a6                	ld	ra,72(sp)
     546:	6406                	ld	s0,64(sp)
     548:	74e2                	ld	s1,56(sp)
     54a:	7942                	ld	s2,48(sp)
     54c:	79a2                	ld	s3,40(sp)
     54e:	6161                	addi	sp,sp,80
     550:	8082                	ret

0000000000000552 <copyin>:
{
     552:	715d                	addi	sp,sp,-80
     554:	e486                	sd	ra,72(sp)
     556:	e0a2                	sd	s0,64(sp)
     558:	fc26                	sd	s1,56(sp)
     55a:	f84a                	sd	s2,48(sp)
     55c:	f44e                	sd	s3,40(sp)
     55e:	f052                	sd	s4,32(sp)
     560:	0880                	addi	s0,sp,80
  uint64 addrs[] = {0x80000000LL, 0xffffffffffffffff};
     562:	4785                	li	a5,1
     564:	07fe                	slli	a5,a5,0x1f
     566:	fcf43023          	sd	a5,-64(s0)
     56a:	57fd                	li	a5,-1
     56c:	fcf43423          	sd	a5,-56(s0)
  for (int ai = 0; ai < 2; ai++)
     570:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     574:	00006a17          	auipc	s4,0x6
     578:	aeca0a13          	addi	s4,s4,-1300 # 6060 <malloc+0x244>
    uint64 addr = addrs[ai];
     57c:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     580:	20100593          	li	a1,513
     584:	8552                	mv	a0,s4
     586:	00005097          	auipc	ra,0x5
     58a:	48c080e7          	jalr	1164(ra) # 5a12 <open>
     58e:	84aa                	mv	s1,a0
    if (fd < 0)
     590:	08054863          	bltz	a0,620 <copyin+0xce>
    int n = write(fd, (void *)addr, 8192);
     594:	6609                	lui	a2,0x2
     596:	85ce                	mv	a1,s3
     598:	00005097          	auipc	ra,0x5
     59c:	45a080e7          	jalr	1114(ra) # 59f2 <write>
    if (n >= 0)
     5a0:	08055d63          	bgez	a0,63a <copyin+0xe8>
    close(fd);
     5a4:	8526                	mv	a0,s1
     5a6:	00005097          	auipc	ra,0x5
     5aa:	454080e7          	jalr	1108(ra) # 59fa <close>
    unlink("copyin1");
     5ae:	8552                	mv	a0,s4
     5b0:	00005097          	auipc	ra,0x5
     5b4:	472080e7          	jalr	1138(ra) # 5a22 <unlink>
    n = write(1, (char *)addr, 8192);
     5b8:	6609                	lui	a2,0x2
     5ba:	85ce                	mv	a1,s3
     5bc:	4505                	li	a0,1
     5be:	00005097          	auipc	ra,0x5
     5c2:	434080e7          	jalr	1076(ra) # 59f2 <write>
    if (n > 0)
     5c6:	08a04963          	bgtz	a0,658 <copyin+0x106>
    if (pipe(fds) < 0)
     5ca:	fb840513          	addi	a0,s0,-72
     5ce:	00005097          	auipc	ra,0x5
     5d2:	414080e7          	jalr	1044(ra) # 59e2 <pipe>
     5d6:	0a054063          	bltz	a0,676 <copyin+0x124>
    n = write(fds[1], (char *)addr, 8192);
     5da:	6609                	lui	a2,0x2
     5dc:	85ce                	mv	a1,s3
     5de:	fbc42503          	lw	a0,-68(s0)
     5e2:	00005097          	auipc	ra,0x5
     5e6:	410080e7          	jalr	1040(ra) # 59f2 <write>
    if (n > 0)
     5ea:	0aa04363          	bgtz	a0,690 <copyin+0x13e>
    close(fds[0]);
     5ee:	fb842503          	lw	a0,-72(s0)
     5f2:	00005097          	auipc	ra,0x5
     5f6:	408080e7          	jalr	1032(ra) # 59fa <close>
    close(fds[1]);
     5fa:	fbc42503          	lw	a0,-68(s0)
     5fe:	00005097          	auipc	ra,0x5
     602:	3fc080e7          	jalr	1020(ra) # 59fa <close>
  for (int ai = 0; ai < 2; ai++)
     606:	0921                	addi	s2,s2,8
     608:	fd040793          	addi	a5,s0,-48
     60c:	f6f918e3          	bne	s2,a5,57c <copyin+0x2a>
}
     610:	60a6                	ld	ra,72(sp)
     612:	6406                	ld	s0,64(sp)
     614:	74e2                	ld	s1,56(sp)
     616:	7942                	ld	s2,48(sp)
     618:	79a2                	ld	s3,40(sp)
     61a:	7a02                	ld	s4,32(sp)
     61c:	6161                	addi	sp,sp,80
     61e:	8082                	ret
      printf("open(copyin1) failed\n");
     620:	00006517          	auipc	a0,0x6
     624:	a4850513          	addi	a0,a0,-1464 # 6068 <malloc+0x24c>
     628:	00005097          	auipc	ra,0x5
     62c:	73c080e7          	jalr	1852(ra) # 5d64 <printf>
      exit(1);
     630:	4505                	li	a0,1
     632:	00005097          	auipc	ra,0x5
     636:	3a0080e7          	jalr	928(ra) # 59d2 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     63a:	862a                	mv	a2,a0
     63c:	85ce                	mv	a1,s3
     63e:	00006517          	auipc	a0,0x6
     642:	a4250513          	addi	a0,a0,-1470 # 6080 <malloc+0x264>
     646:	00005097          	auipc	ra,0x5
     64a:	71e080e7          	jalr	1822(ra) # 5d64 <printf>
      exit(1);
     64e:	4505                	li	a0,1
     650:	00005097          	auipc	ra,0x5
     654:	382080e7          	jalr	898(ra) # 59d2 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     658:	862a                	mv	a2,a0
     65a:	85ce                	mv	a1,s3
     65c:	00006517          	auipc	a0,0x6
     660:	a5450513          	addi	a0,a0,-1452 # 60b0 <malloc+0x294>
     664:	00005097          	auipc	ra,0x5
     668:	700080e7          	jalr	1792(ra) # 5d64 <printf>
      exit(1);
     66c:	4505                	li	a0,1
     66e:	00005097          	auipc	ra,0x5
     672:	364080e7          	jalr	868(ra) # 59d2 <exit>
      printf("pipe() failed\n");
     676:	00006517          	auipc	a0,0x6
     67a:	a6a50513          	addi	a0,a0,-1430 # 60e0 <malloc+0x2c4>
     67e:	00005097          	auipc	ra,0x5
     682:	6e6080e7          	jalr	1766(ra) # 5d64 <printf>
      exit(1);
     686:	4505                	li	a0,1
     688:	00005097          	auipc	ra,0x5
     68c:	34a080e7          	jalr	842(ra) # 59d2 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     690:	862a                	mv	a2,a0
     692:	85ce                	mv	a1,s3
     694:	00006517          	auipc	a0,0x6
     698:	a5c50513          	addi	a0,a0,-1444 # 60f0 <malloc+0x2d4>
     69c:	00005097          	auipc	ra,0x5
     6a0:	6c8080e7          	jalr	1736(ra) # 5d64 <printf>
      exit(1);
     6a4:	4505                	li	a0,1
     6a6:	00005097          	auipc	ra,0x5
     6aa:	32c080e7          	jalr	812(ra) # 59d2 <exit>

00000000000006ae <copyout>:
{
     6ae:	711d                	addi	sp,sp,-96
     6b0:	ec86                	sd	ra,88(sp)
     6b2:	e8a2                	sd	s0,80(sp)
     6b4:	e4a6                	sd	s1,72(sp)
     6b6:	e0ca                	sd	s2,64(sp)
     6b8:	fc4e                	sd	s3,56(sp)
     6ba:	f852                	sd	s4,48(sp)
     6bc:	f456                	sd	s5,40(sp)
     6be:	1080                	addi	s0,sp,96
  uint64 addrs[] = {0x80000000LL, 0xffffffffffffffff};
     6c0:	4785                	li	a5,1
     6c2:	07fe                	slli	a5,a5,0x1f
     6c4:	faf43823          	sd	a5,-80(s0)
     6c8:	57fd                	li	a5,-1
     6ca:	faf43c23          	sd	a5,-72(s0)
  for (int ai = 0; ai < 2; ai++)
     6ce:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     6d2:	00006a17          	auipc	s4,0x6
     6d6:	a4ea0a13          	addi	s4,s4,-1458 # 6120 <malloc+0x304>
    n = write(fds[1], "x", 1);
     6da:	00006a97          	auipc	s5,0x6
     6de:	8dea8a93          	addi	s5,s5,-1826 # 5fb8 <malloc+0x19c>
    uint64 addr = addrs[ai];
     6e2:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     6e6:	4581                	li	a1,0
     6e8:	8552                	mv	a0,s4
     6ea:	00005097          	auipc	ra,0x5
     6ee:	328080e7          	jalr	808(ra) # 5a12 <open>
     6f2:	84aa                	mv	s1,a0
    if (fd < 0)
     6f4:	08054663          	bltz	a0,780 <copyout+0xd2>
    int n = read(fd, (void *)addr, 8192);
     6f8:	6609                	lui	a2,0x2
     6fa:	85ce                	mv	a1,s3
     6fc:	00005097          	auipc	ra,0x5
     700:	2ee080e7          	jalr	750(ra) # 59ea <read>
    if (n > 0)
     704:	08a04b63          	bgtz	a0,79a <copyout+0xec>
    close(fd);
     708:	8526                	mv	a0,s1
     70a:	00005097          	auipc	ra,0x5
     70e:	2f0080e7          	jalr	752(ra) # 59fa <close>
    if (pipe(fds) < 0)
     712:	fa840513          	addi	a0,s0,-88
     716:	00005097          	auipc	ra,0x5
     71a:	2cc080e7          	jalr	716(ra) # 59e2 <pipe>
     71e:	08054d63          	bltz	a0,7b8 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     722:	4605                	li	a2,1
     724:	85d6                	mv	a1,s5
     726:	fac42503          	lw	a0,-84(s0)
     72a:	00005097          	auipc	ra,0x5
     72e:	2c8080e7          	jalr	712(ra) # 59f2 <write>
    if (n != 1)
     732:	4785                	li	a5,1
     734:	08f51f63          	bne	a0,a5,7d2 <copyout+0x124>
    n = read(fds[0], (void *)addr, 8192);
     738:	6609                	lui	a2,0x2
     73a:	85ce                	mv	a1,s3
     73c:	fa842503          	lw	a0,-88(s0)
     740:	00005097          	auipc	ra,0x5
     744:	2aa080e7          	jalr	682(ra) # 59ea <read>
    if (n > 0)
     748:	0aa04263          	bgtz	a0,7ec <copyout+0x13e>
    close(fds[0]);
     74c:	fa842503          	lw	a0,-88(s0)
     750:	00005097          	auipc	ra,0x5
     754:	2aa080e7          	jalr	682(ra) # 59fa <close>
    close(fds[1]);
     758:	fac42503          	lw	a0,-84(s0)
     75c:	00005097          	auipc	ra,0x5
     760:	29e080e7          	jalr	670(ra) # 59fa <close>
  for (int ai = 0; ai < 2; ai++)
     764:	0921                	addi	s2,s2,8
     766:	fc040793          	addi	a5,s0,-64
     76a:	f6f91ce3          	bne	s2,a5,6e2 <copyout+0x34>
}
     76e:	60e6                	ld	ra,88(sp)
     770:	6446                	ld	s0,80(sp)
     772:	64a6                	ld	s1,72(sp)
     774:	6906                	ld	s2,64(sp)
     776:	79e2                	ld	s3,56(sp)
     778:	7a42                	ld	s4,48(sp)
     77a:	7aa2                	ld	s5,40(sp)
     77c:	6125                	addi	sp,sp,96
     77e:	8082                	ret
      printf("open(README) failed\n");
     780:	00006517          	auipc	a0,0x6
     784:	9a850513          	addi	a0,a0,-1624 # 6128 <malloc+0x30c>
     788:	00005097          	auipc	ra,0x5
     78c:	5dc080e7          	jalr	1500(ra) # 5d64 <printf>
      exit(1);
     790:	4505                	li	a0,1
     792:	00005097          	auipc	ra,0x5
     796:	240080e7          	jalr	576(ra) # 59d2 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     79a:	862a                	mv	a2,a0
     79c:	85ce                	mv	a1,s3
     79e:	00006517          	auipc	a0,0x6
     7a2:	9a250513          	addi	a0,a0,-1630 # 6140 <malloc+0x324>
     7a6:	00005097          	auipc	ra,0x5
     7aa:	5be080e7          	jalr	1470(ra) # 5d64 <printf>
      exit(1);
     7ae:	4505                	li	a0,1
     7b0:	00005097          	auipc	ra,0x5
     7b4:	222080e7          	jalr	546(ra) # 59d2 <exit>
      printf("pipe() failed\n");
     7b8:	00006517          	auipc	a0,0x6
     7bc:	92850513          	addi	a0,a0,-1752 # 60e0 <malloc+0x2c4>
     7c0:	00005097          	auipc	ra,0x5
     7c4:	5a4080e7          	jalr	1444(ra) # 5d64 <printf>
      exit(1);
     7c8:	4505                	li	a0,1
     7ca:	00005097          	auipc	ra,0x5
     7ce:	208080e7          	jalr	520(ra) # 59d2 <exit>
      printf("pipe write failed\n");
     7d2:	00006517          	auipc	a0,0x6
     7d6:	99e50513          	addi	a0,a0,-1634 # 6170 <malloc+0x354>
     7da:	00005097          	auipc	ra,0x5
     7de:	58a080e7          	jalr	1418(ra) # 5d64 <printf>
      exit(1);
     7e2:	4505                	li	a0,1
     7e4:	00005097          	auipc	ra,0x5
     7e8:	1ee080e7          	jalr	494(ra) # 59d2 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     7ec:	862a                	mv	a2,a0
     7ee:	85ce                	mv	a1,s3
     7f0:	00006517          	auipc	a0,0x6
     7f4:	99850513          	addi	a0,a0,-1640 # 6188 <malloc+0x36c>
     7f8:	00005097          	auipc	ra,0x5
     7fc:	56c080e7          	jalr	1388(ra) # 5d64 <printf>
      exit(1);
     800:	4505                	li	a0,1
     802:	00005097          	auipc	ra,0x5
     806:	1d0080e7          	jalr	464(ra) # 59d2 <exit>

000000000000080a <truncate1>:
{
     80a:	711d                	addi	sp,sp,-96
     80c:	ec86                	sd	ra,88(sp)
     80e:	e8a2                	sd	s0,80(sp)
     810:	e4a6                	sd	s1,72(sp)
     812:	e0ca                	sd	s2,64(sp)
     814:	fc4e                	sd	s3,56(sp)
     816:	f852                	sd	s4,48(sp)
     818:	f456                	sd	s5,40(sp)
     81a:	1080                	addi	s0,sp,96
     81c:	8aaa                	mv	s5,a0
  unlink("truncfile");
     81e:	00005517          	auipc	a0,0x5
     822:	78250513          	addi	a0,a0,1922 # 5fa0 <malloc+0x184>
     826:	00005097          	auipc	ra,0x5
     82a:	1fc080e7          	jalr	508(ra) # 5a22 <unlink>
  int fd1 = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
     82e:	60100593          	li	a1,1537
     832:	00005517          	auipc	a0,0x5
     836:	76e50513          	addi	a0,a0,1902 # 5fa0 <malloc+0x184>
     83a:	00005097          	auipc	ra,0x5
     83e:	1d8080e7          	jalr	472(ra) # 5a12 <open>
     842:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     844:	4611                	li	a2,4
     846:	00005597          	auipc	a1,0x5
     84a:	76a58593          	addi	a1,a1,1898 # 5fb0 <malloc+0x194>
     84e:	00005097          	auipc	ra,0x5
     852:	1a4080e7          	jalr	420(ra) # 59f2 <write>
  close(fd1);
     856:	8526                	mv	a0,s1
     858:	00005097          	auipc	ra,0x5
     85c:	1a2080e7          	jalr	418(ra) # 59fa <close>
  int fd2 = open("truncfile", O_RDONLY);
     860:	4581                	li	a1,0
     862:	00005517          	auipc	a0,0x5
     866:	73e50513          	addi	a0,a0,1854 # 5fa0 <malloc+0x184>
     86a:	00005097          	auipc	ra,0x5
     86e:	1a8080e7          	jalr	424(ra) # 5a12 <open>
     872:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     874:	02000613          	li	a2,32
     878:	fa040593          	addi	a1,s0,-96
     87c:	00005097          	auipc	ra,0x5
     880:	16e080e7          	jalr	366(ra) # 59ea <read>
  if (n != 4)
     884:	4791                	li	a5,4
     886:	0cf51e63          	bne	a0,a5,962 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY | O_TRUNC);
     88a:	40100593          	li	a1,1025
     88e:	00005517          	auipc	a0,0x5
     892:	71250513          	addi	a0,a0,1810 # 5fa0 <malloc+0x184>
     896:	00005097          	auipc	ra,0x5
     89a:	17c080e7          	jalr	380(ra) # 5a12 <open>
     89e:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     8a0:	4581                	li	a1,0
     8a2:	00005517          	auipc	a0,0x5
     8a6:	6fe50513          	addi	a0,a0,1790 # 5fa0 <malloc+0x184>
     8aa:	00005097          	auipc	ra,0x5
     8ae:	168080e7          	jalr	360(ra) # 5a12 <open>
     8b2:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     8b4:	02000613          	li	a2,32
     8b8:	fa040593          	addi	a1,s0,-96
     8bc:	00005097          	auipc	ra,0x5
     8c0:	12e080e7          	jalr	302(ra) # 59ea <read>
     8c4:	8a2a                	mv	s4,a0
  if (n != 0)
     8c6:	ed4d                	bnez	a0,980 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8c8:	02000613          	li	a2,32
     8cc:	fa040593          	addi	a1,s0,-96
     8d0:	8526                	mv	a0,s1
     8d2:	00005097          	auipc	ra,0x5
     8d6:	118080e7          	jalr	280(ra) # 59ea <read>
     8da:	8a2a                	mv	s4,a0
  if (n != 0)
     8dc:	e971                	bnez	a0,9b0 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     8de:	4619                	li	a2,6
     8e0:	00006597          	auipc	a1,0x6
     8e4:	93858593          	addi	a1,a1,-1736 # 6218 <malloc+0x3fc>
     8e8:	854e                	mv	a0,s3
     8ea:	00005097          	auipc	ra,0x5
     8ee:	108080e7          	jalr	264(ra) # 59f2 <write>
  n = read(fd3, buf, sizeof(buf));
     8f2:	02000613          	li	a2,32
     8f6:	fa040593          	addi	a1,s0,-96
     8fa:	854a                	mv	a0,s2
     8fc:	00005097          	auipc	ra,0x5
     900:	0ee080e7          	jalr	238(ra) # 59ea <read>
  if (n != 6)
     904:	4799                	li	a5,6
     906:	0cf51d63          	bne	a0,a5,9e0 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     90a:	02000613          	li	a2,32
     90e:	fa040593          	addi	a1,s0,-96
     912:	8526                	mv	a0,s1
     914:	00005097          	auipc	ra,0x5
     918:	0d6080e7          	jalr	214(ra) # 59ea <read>
  if (n != 2)
     91c:	4789                	li	a5,2
     91e:	0ef51063          	bne	a0,a5,9fe <truncate1+0x1f4>
  unlink("truncfile");
     922:	00005517          	auipc	a0,0x5
     926:	67e50513          	addi	a0,a0,1662 # 5fa0 <malloc+0x184>
     92a:	00005097          	auipc	ra,0x5
     92e:	0f8080e7          	jalr	248(ra) # 5a22 <unlink>
  close(fd1);
     932:	854e                	mv	a0,s3
     934:	00005097          	auipc	ra,0x5
     938:	0c6080e7          	jalr	198(ra) # 59fa <close>
  close(fd2);
     93c:	8526                	mv	a0,s1
     93e:	00005097          	auipc	ra,0x5
     942:	0bc080e7          	jalr	188(ra) # 59fa <close>
  close(fd3);
     946:	854a                	mv	a0,s2
     948:	00005097          	auipc	ra,0x5
     94c:	0b2080e7          	jalr	178(ra) # 59fa <close>
}
     950:	60e6                	ld	ra,88(sp)
     952:	6446                	ld	s0,80(sp)
     954:	64a6                	ld	s1,72(sp)
     956:	6906                	ld	s2,64(sp)
     958:	79e2                	ld	s3,56(sp)
     95a:	7a42                	ld	s4,48(sp)
     95c:	7aa2                	ld	s5,40(sp)
     95e:	6125                	addi	sp,sp,96
     960:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     962:	862a                	mv	a2,a0
     964:	85d6                	mv	a1,s5
     966:	00006517          	auipc	a0,0x6
     96a:	85250513          	addi	a0,a0,-1966 # 61b8 <malloc+0x39c>
     96e:	00005097          	auipc	ra,0x5
     972:	3f6080e7          	jalr	1014(ra) # 5d64 <printf>
    exit(1);
     976:	4505                	li	a0,1
     978:	00005097          	auipc	ra,0x5
     97c:	05a080e7          	jalr	90(ra) # 59d2 <exit>
    printf("aaa fd3=%d\n", fd3);
     980:	85ca                	mv	a1,s2
     982:	00006517          	auipc	a0,0x6
     986:	85650513          	addi	a0,a0,-1962 # 61d8 <malloc+0x3bc>
     98a:	00005097          	auipc	ra,0x5
     98e:	3da080e7          	jalr	986(ra) # 5d64 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     992:	8652                	mv	a2,s4
     994:	85d6                	mv	a1,s5
     996:	00006517          	auipc	a0,0x6
     99a:	85250513          	addi	a0,a0,-1966 # 61e8 <malloc+0x3cc>
     99e:	00005097          	auipc	ra,0x5
     9a2:	3c6080e7          	jalr	966(ra) # 5d64 <printf>
    exit(1);
     9a6:	4505                	li	a0,1
     9a8:	00005097          	auipc	ra,0x5
     9ac:	02a080e7          	jalr	42(ra) # 59d2 <exit>
    printf("bbb fd2=%d\n", fd2);
     9b0:	85a6                	mv	a1,s1
     9b2:	00006517          	auipc	a0,0x6
     9b6:	85650513          	addi	a0,a0,-1962 # 6208 <malloc+0x3ec>
     9ba:	00005097          	auipc	ra,0x5
     9be:	3aa080e7          	jalr	938(ra) # 5d64 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9c2:	8652                	mv	a2,s4
     9c4:	85d6                	mv	a1,s5
     9c6:	00006517          	auipc	a0,0x6
     9ca:	82250513          	addi	a0,a0,-2014 # 61e8 <malloc+0x3cc>
     9ce:	00005097          	auipc	ra,0x5
     9d2:	396080e7          	jalr	918(ra) # 5d64 <printf>
    exit(1);
     9d6:	4505                	li	a0,1
     9d8:	00005097          	auipc	ra,0x5
     9dc:	ffa080e7          	jalr	-6(ra) # 59d2 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     9e0:	862a                	mv	a2,a0
     9e2:	85d6                	mv	a1,s5
     9e4:	00006517          	auipc	a0,0x6
     9e8:	83c50513          	addi	a0,a0,-1988 # 6220 <malloc+0x404>
     9ec:	00005097          	auipc	ra,0x5
     9f0:	378080e7          	jalr	888(ra) # 5d64 <printf>
    exit(1);
     9f4:	4505                	li	a0,1
     9f6:	00005097          	auipc	ra,0x5
     9fa:	fdc080e7          	jalr	-36(ra) # 59d2 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     9fe:	862a                	mv	a2,a0
     a00:	85d6                	mv	a1,s5
     a02:	00006517          	auipc	a0,0x6
     a06:	83e50513          	addi	a0,a0,-1986 # 6240 <malloc+0x424>
     a0a:	00005097          	auipc	ra,0x5
     a0e:	35a080e7          	jalr	858(ra) # 5d64 <printf>
    exit(1);
     a12:	4505                	li	a0,1
     a14:	00005097          	auipc	ra,0x5
     a18:	fbe080e7          	jalr	-66(ra) # 59d2 <exit>

0000000000000a1c <writetest>:
{
     a1c:	7139                	addi	sp,sp,-64
     a1e:	fc06                	sd	ra,56(sp)
     a20:	f822                	sd	s0,48(sp)
     a22:	f426                	sd	s1,40(sp)
     a24:	f04a                	sd	s2,32(sp)
     a26:	ec4e                	sd	s3,24(sp)
     a28:	e852                	sd	s4,16(sp)
     a2a:	e456                	sd	s5,8(sp)
     a2c:	e05a                	sd	s6,0(sp)
     a2e:	0080                	addi	s0,sp,64
     a30:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE | O_RDWR);
     a32:	20200593          	li	a1,514
     a36:	00006517          	auipc	a0,0x6
     a3a:	82a50513          	addi	a0,a0,-2006 # 6260 <malloc+0x444>
     a3e:	00005097          	auipc	ra,0x5
     a42:	fd4080e7          	jalr	-44(ra) # 5a12 <open>
  if (fd < 0)
     a46:	0a054d63          	bltz	a0,b00 <writetest+0xe4>
     a4a:	892a                	mv	s2,a0
     a4c:	4481                	li	s1,0
    if (write(fd, "aaaaaaaaaa", SZ) != SZ)
     a4e:	00006997          	auipc	s3,0x6
     a52:	83a98993          	addi	s3,s3,-1990 # 6288 <malloc+0x46c>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ)
     a56:	00006a97          	auipc	s5,0x6
     a5a:	86aa8a93          	addi	s5,s5,-1942 # 62c0 <malloc+0x4a4>
  for (i = 0; i < N; i++)
     a5e:	06400a13          	li	s4,100
    if (write(fd, "aaaaaaaaaa", SZ) != SZ)
     a62:	4629                	li	a2,10
     a64:	85ce                	mv	a1,s3
     a66:	854a                	mv	a0,s2
     a68:	00005097          	auipc	ra,0x5
     a6c:	f8a080e7          	jalr	-118(ra) # 59f2 <write>
     a70:	47a9                	li	a5,10
     a72:	0af51563          	bne	a0,a5,b1c <writetest+0x100>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ)
     a76:	4629                	li	a2,10
     a78:	85d6                	mv	a1,s5
     a7a:	854a                	mv	a0,s2
     a7c:	00005097          	auipc	ra,0x5
     a80:	f76080e7          	jalr	-138(ra) # 59f2 <write>
     a84:	47a9                	li	a5,10
     a86:	0af51a63          	bne	a0,a5,b3a <writetest+0x11e>
  for (i = 0; i < N; i++)
     a8a:	2485                	addiw	s1,s1,1
     a8c:	fd449be3          	bne	s1,s4,a62 <writetest+0x46>
  close(fd);
     a90:	854a                	mv	a0,s2
     a92:	00005097          	auipc	ra,0x5
     a96:	f68080e7          	jalr	-152(ra) # 59fa <close>
  fd = open("small", O_RDONLY);
     a9a:	4581                	li	a1,0
     a9c:	00005517          	auipc	a0,0x5
     aa0:	7c450513          	addi	a0,a0,1988 # 6260 <malloc+0x444>
     aa4:	00005097          	auipc	ra,0x5
     aa8:	f6e080e7          	jalr	-146(ra) # 5a12 <open>
     aac:	84aa                	mv	s1,a0
  if (fd < 0)
     aae:	0a054563          	bltz	a0,b58 <writetest+0x13c>
  i = read(fd, buf, N * SZ * 2);
     ab2:	7d000613          	li	a2,2000
     ab6:	0000c597          	auipc	a1,0xc
     aba:	1c258593          	addi	a1,a1,450 # cc78 <buf>
     abe:	00005097          	auipc	ra,0x5
     ac2:	f2c080e7          	jalr	-212(ra) # 59ea <read>
  if (i != N * SZ * 2)
     ac6:	7d000793          	li	a5,2000
     aca:	0af51563          	bne	a0,a5,b74 <writetest+0x158>
  close(fd);
     ace:	8526                	mv	a0,s1
     ad0:	00005097          	auipc	ra,0x5
     ad4:	f2a080e7          	jalr	-214(ra) # 59fa <close>
  if (unlink("small") < 0)
     ad8:	00005517          	auipc	a0,0x5
     adc:	78850513          	addi	a0,a0,1928 # 6260 <malloc+0x444>
     ae0:	00005097          	auipc	ra,0x5
     ae4:	f42080e7          	jalr	-190(ra) # 5a22 <unlink>
     ae8:	0a054463          	bltz	a0,b90 <writetest+0x174>
}
     aec:	70e2                	ld	ra,56(sp)
     aee:	7442                	ld	s0,48(sp)
     af0:	74a2                	ld	s1,40(sp)
     af2:	7902                	ld	s2,32(sp)
     af4:	69e2                	ld	s3,24(sp)
     af6:	6a42                	ld	s4,16(sp)
     af8:	6aa2                	ld	s5,8(sp)
     afa:	6b02                	ld	s6,0(sp)
     afc:	6121                	addi	sp,sp,64
     afe:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     b00:	85da                	mv	a1,s6
     b02:	00005517          	auipc	a0,0x5
     b06:	76650513          	addi	a0,a0,1894 # 6268 <malloc+0x44c>
     b0a:	00005097          	auipc	ra,0x5
     b0e:	25a080e7          	jalr	602(ra) # 5d64 <printf>
    exit(1);
     b12:	4505                	li	a0,1
     b14:	00005097          	auipc	ra,0x5
     b18:	ebe080e7          	jalr	-322(ra) # 59d2 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     b1c:	8626                	mv	a2,s1
     b1e:	85da                	mv	a1,s6
     b20:	00005517          	auipc	a0,0x5
     b24:	77850513          	addi	a0,a0,1912 # 6298 <malloc+0x47c>
     b28:	00005097          	auipc	ra,0x5
     b2c:	23c080e7          	jalr	572(ra) # 5d64 <printf>
      exit(1);
     b30:	4505                	li	a0,1
     b32:	00005097          	auipc	ra,0x5
     b36:	ea0080e7          	jalr	-352(ra) # 59d2 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     b3a:	8626                	mv	a2,s1
     b3c:	85da                	mv	a1,s6
     b3e:	00005517          	auipc	a0,0x5
     b42:	79250513          	addi	a0,a0,1938 # 62d0 <malloc+0x4b4>
     b46:	00005097          	auipc	ra,0x5
     b4a:	21e080e7          	jalr	542(ra) # 5d64 <printf>
      exit(1);
     b4e:	4505                	li	a0,1
     b50:	00005097          	auipc	ra,0x5
     b54:	e82080e7          	jalr	-382(ra) # 59d2 <exit>
    printf("%s: error: open small failed!\n", s);
     b58:	85da                	mv	a1,s6
     b5a:	00005517          	auipc	a0,0x5
     b5e:	79e50513          	addi	a0,a0,1950 # 62f8 <malloc+0x4dc>
     b62:	00005097          	auipc	ra,0x5
     b66:	202080e7          	jalr	514(ra) # 5d64 <printf>
    exit(1);
     b6a:	4505                	li	a0,1
     b6c:	00005097          	auipc	ra,0x5
     b70:	e66080e7          	jalr	-410(ra) # 59d2 <exit>
    printf("%s: read failed\n", s);
     b74:	85da                	mv	a1,s6
     b76:	00005517          	auipc	a0,0x5
     b7a:	7a250513          	addi	a0,a0,1954 # 6318 <malloc+0x4fc>
     b7e:	00005097          	auipc	ra,0x5
     b82:	1e6080e7          	jalr	486(ra) # 5d64 <printf>
    exit(1);
     b86:	4505                	li	a0,1
     b88:	00005097          	auipc	ra,0x5
     b8c:	e4a080e7          	jalr	-438(ra) # 59d2 <exit>
    printf("%s: unlink small failed\n", s);
     b90:	85da                	mv	a1,s6
     b92:	00005517          	auipc	a0,0x5
     b96:	79e50513          	addi	a0,a0,1950 # 6330 <malloc+0x514>
     b9a:	00005097          	auipc	ra,0x5
     b9e:	1ca080e7          	jalr	458(ra) # 5d64 <printf>
    exit(1);
     ba2:	4505                	li	a0,1
     ba4:	00005097          	auipc	ra,0x5
     ba8:	e2e080e7          	jalr	-466(ra) # 59d2 <exit>

0000000000000bac <writebig>:
{
     bac:	7139                	addi	sp,sp,-64
     bae:	fc06                	sd	ra,56(sp)
     bb0:	f822                	sd	s0,48(sp)
     bb2:	f426                	sd	s1,40(sp)
     bb4:	f04a                	sd	s2,32(sp)
     bb6:	ec4e                	sd	s3,24(sp)
     bb8:	e852                	sd	s4,16(sp)
     bba:	e456                	sd	s5,8(sp)
     bbc:	0080                	addi	s0,sp,64
     bbe:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE | O_RDWR);
     bc0:	20200593          	li	a1,514
     bc4:	00005517          	auipc	a0,0x5
     bc8:	78c50513          	addi	a0,a0,1932 # 6350 <malloc+0x534>
     bcc:	00005097          	auipc	ra,0x5
     bd0:	e46080e7          	jalr	-442(ra) # 5a12 <open>
     bd4:	89aa                	mv	s3,a0
  for (i = 0; i < MAXFILE; i++)
     bd6:	4481                	li	s1,0
    ((int *)buf)[0] = i;
     bd8:	0000c917          	auipc	s2,0xc
     bdc:	0a090913          	addi	s2,s2,160 # cc78 <buf>
  for (i = 0; i < MAXFILE; i++)
     be0:	10c00a13          	li	s4,268
  if (fd < 0)
     be4:	06054c63          	bltz	a0,c5c <writebig+0xb0>
    ((int *)buf)[0] = i;
     be8:	00992023          	sw	s1,0(s2)
    if (write(fd, buf, BSIZE) != BSIZE)
     bec:	40000613          	li	a2,1024
     bf0:	85ca                	mv	a1,s2
     bf2:	854e                	mv	a0,s3
     bf4:	00005097          	auipc	ra,0x5
     bf8:	dfe080e7          	jalr	-514(ra) # 59f2 <write>
     bfc:	40000793          	li	a5,1024
     c00:	06f51c63          	bne	a0,a5,c78 <writebig+0xcc>
  for (i = 0; i < MAXFILE; i++)
     c04:	2485                	addiw	s1,s1,1
     c06:	ff4491e3          	bne	s1,s4,be8 <writebig+0x3c>
  close(fd);
     c0a:	854e                	mv	a0,s3
     c0c:	00005097          	auipc	ra,0x5
     c10:	dee080e7          	jalr	-530(ra) # 59fa <close>
  fd = open("big", O_RDONLY);
     c14:	4581                	li	a1,0
     c16:	00005517          	auipc	a0,0x5
     c1a:	73a50513          	addi	a0,a0,1850 # 6350 <malloc+0x534>
     c1e:	00005097          	auipc	ra,0x5
     c22:	df4080e7          	jalr	-524(ra) # 5a12 <open>
     c26:	89aa                	mv	s3,a0
  n = 0;
     c28:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c2a:	0000c917          	auipc	s2,0xc
     c2e:	04e90913          	addi	s2,s2,78 # cc78 <buf>
  if (fd < 0)
     c32:	06054263          	bltz	a0,c96 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     c36:	40000613          	li	a2,1024
     c3a:	85ca                	mv	a1,s2
     c3c:	854e                	mv	a0,s3
     c3e:	00005097          	auipc	ra,0x5
     c42:	dac080e7          	jalr	-596(ra) # 59ea <read>
    if (i == 0)
     c46:	c535                	beqz	a0,cb2 <writebig+0x106>
    else if (i != BSIZE)
     c48:	40000793          	li	a5,1024
     c4c:	0af51f63          	bne	a0,a5,d0a <writebig+0x15e>
    if (((int *)buf)[0] != n)
     c50:	00092683          	lw	a3,0(s2)
     c54:	0c969a63          	bne	a3,s1,d28 <writebig+0x17c>
    n++;
     c58:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c5a:	bff1                	j	c36 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     c5c:	85d6                	mv	a1,s5
     c5e:	00005517          	auipc	a0,0x5
     c62:	6fa50513          	addi	a0,a0,1786 # 6358 <malloc+0x53c>
     c66:	00005097          	auipc	ra,0x5
     c6a:	0fe080e7          	jalr	254(ra) # 5d64 <printf>
    exit(1);
     c6e:	4505                	li	a0,1
     c70:	00005097          	auipc	ra,0x5
     c74:	d62080e7          	jalr	-670(ra) # 59d2 <exit>
      printf("%s: error: write big file failed\n", s, i);
     c78:	8626                	mv	a2,s1
     c7a:	85d6                	mv	a1,s5
     c7c:	00005517          	auipc	a0,0x5
     c80:	6fc50513          	addi	a0,a0,1788 # 6378 <malloc+0x55c>
     c84:	00005097          	auipc	ra,0x5
     c88:	0e0080e7          	jalr	224(ra) # 5d64 <printf>
      exit(1);
     c8c:	4505                	li	a0,1
     c8e:	00005097          	auipc	ra,0x5
     c92:	d44080e7          	jalr	-700(ra) # 59d2 <exit>
    printf("%s: error: open big failed!\n", s);
     c96:	85d6                	mv	a1,s5
     c98:	00005517          	auipc	a0,0x5
     c9c:	70850513          	addi	a0,a0,1800 # 63a0 <malloc+0x584>
     ca0:	00005097          	auipc	ra,0x5
     ca4:	0c4080e7          	jalr	196(ra) # 5d64 <printf>
    exit(1);
     ca8:	4505                	li	a0,1
     caa:	00005097          	auipc	ra,0x5
     cae:	d28080e7          	jalr	-728(ra) # 59d2 <exit>
      if (n == MAXFILE - 1)
     cb2:	10b00793          	li	a5,267
     cb6:	02f48a63          	beq	s1,a5,cea <writebig+0x13e>
  close(fd);
     cba:	854e                	mv	a0,s3
     cbc:	00005097          	auipc	ra,0x5
     cc0:	d3e080e7          	jalr	-706(ra) # 59fa <close>
  if (unlink("big") < 0)
     cc4:	00005517          	auipc	a0,0x5
     cc8:	68c50513          	addi	a0,a0,1676 # 6350 <malloc+0x534>
     ccc:	00005097          	auipc	ra,0x5
     cd0:	d56080e7          	jalr	-682(ra) # 5a22 <unlink>
     cd4:	06054963          	bltz	a0,d46 <writebig+0x19a>
}
     cd8:	70e2                	ld	ra,56(sp)
     cda:	7442                	ld	s0,48(sp)
     cdc:	74a2                	ld	s1,40(sp)
     cde:	7902                	ld	s2,32(sp)
     ce0:	69e2                	ld	s3,24(sp)
     ce2:	6a42                	ld	s4,16(sp)
     ce4:	6aa2                	ld	s5,8(sp)
     ce6:	6121                	addi	sp,sp,64
     ce8:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     cea:	10b00613          	li	a2,267
     cee:	85d6                	mv	a1,s5
     cf0:	00005517          	auipc	a0,0x5
     cf4:	6d050513          	addi	a0,a0,1744 # 63c0 <malloc+0x5a4>
     cf8:	00005097          	auipc	ra,0x5
     cfc:	06c080e7          	jalr	108(ra) # 5d64 <printf>
        exit(1);
     d00:	4505                	li	a0,1
     d02:	00005097          	auipc	ra,0x5
     d06:	cd0080e7          	jalr	-816(ra) # 59d2 <exit>
      printf("%s: read failed %d\n", s, i);
     d0a:	862a                	mv	a2,a0
     d0c:	85d6                	mv	a1,s5
     d0e:	00005517          	auipc	a0,0x5
     d12:	6da50513          	addi	a0,a0,1754 # 63e8 <malloc+0x5cc>
     d16:	00005097          	auipc	ra,0x5
     d1a:	04e080e7          	jalr	78(ra) # 5d64 <printf>
      exit(1);
     d1e:	4505                	li	a0,1
     d20:	00005097          	auipc	ra,0x5
     d24:	cb2080e7          	jalr	-846(ra) # 59d2 <exit>
      printf("%s: read content of block %d is %d\n", s,
     d28:	8626                	mv	a2,s1
     d2a:	85d6                	mv	a1,s5
     d2c:	00005517          	auipc	a0,0x5
     d30:	6d450513          	addi	a0,a0,1748 # 6400 <malloc+0x5e4>
     d34:	00005097          	auipc	ra,0x5
     d38:	030080e7          	jalr	48(ra) # 5d64 <printf>
      exit(1);
     d3c:	4505                	li	a0,1
     d3e:	00005097          	auipc	ra,0x5
     d42:	c94080e7          	jalr	-876(ra) # 59d2 <exit>
    printf("%s: unlink big failed\n", s);
     d46:	85d6                	mv	a1,s5
     d48:	00005517          	auipc	a0,0x5
     d4c:	6e050513          	addi	a0,a0,1760 # 6428 <malloc+0x60c>
     d50:	00005097          	auipc	ra,0x5
     d54:	014080e7          	jalr	20(ra) # 5d64 <printf>
    exit(1);
     d58:	4505                	li	a0,1
     d5a:	00005097          	auipc	ra,0x5
     d5e:	c78080e7          	jalr	-904(ra) # 59d2 <exit>

0000000000000d62 <unlinkread>:
{
     d62:	7179                	addi	sp,sp,-48
     d64:	f406                	sd	ra,40(sp)
     d66:	f022                	sd	s0,32(sp)
     d68:	ec26                	sd	s1,24(sp)
     d6a:	e84a                	sd	s2,16(sp)
     d6c:	e44e                	sd	s3,8(sp)
     d6e:	1800                	addi	s0,sp,48
     d70:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     d72:	20200593          	li	a1,514
     d76:	00005517          	auipc	a0,0x5
     d7a:	6ca50513          	addi	a0,a0,1738 # 6440 <malloc+0x624>
     d7e:	00005097          	auipc	ra,0x5
     d82:	c94080e7          	jalr	-876(ra) # 5a12 <open>
  if (fd < 0)
     d86:	0e054563          	bltz	a0,e70 <unlinkread+0x10e>
     d8a:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     d8c:	4615                	li	a2,5
     d8e:	00005597          	auipc	a1,0x5
     d92:	6e258593          	addi	a1,a1,1762 # 6470 <malloc+0x654>
     d96:	00005097          	auipc	ra,0x5
     d9a:	c5c080e7          	jalr	-932(ra) # 59f2 <write>
  close(fd);
     d9e:	8526                	mv	a0,s1
     da0:	00005097          	auipc	ra,0x5
     da4:	c5a080e7          	jalr	-934(ra) # 59fa <close>
  fd = open("unlinkread", O_RDWR);
     da8:	4589                	li	a1,2
     daa:	00005517          	auipc	a0,0x5
     dae:	69650513          	addi	a0,a0,1686 # 6440 <malloc+0x624>
     db2:	00005097          	auipc	ra,0x5
     db6:	c60080e7          	jalr	-928(ra) # 5a12 <open>
     dba:	84aa                	mv	s1,a0
  if (fd < 0)
     dbc:	0c054863          	bltz	a0,e8c <unlinkread+0x12a>
  if (unlink("unlinkread") != 0)
     dc0:	00005517          	auipc	a0,0x5
     dc4:	68050513          	addi	a0,a0,1664 # 6440 <malloc+0x624>
     dc8:	00005097          	auipc	ra,0x5
     dcc:	c5a080e7          	jalr	-934(ra) # 5a22 <unlink>
     dd0:	ed61                	bnez	a0,ea8 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     dd2:	20200593          	li	a1,514
     dd6:	00005517          	auipc	a0,0x5
     dda:	66a50513          	addi	a0,a0,1642 # 6440 <malloc+0x624>
     dde:	00005097          	auipc	ra,0x5
     de2:	c34080e7          	jalr	-972(ra) # 5a12 <open>
     de6:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     de8:	460d                	li	a2,3
     dea:	00005597          	auipc	a1,0x5
     dee:	6ce58593          	addi	a1,a1,1742 # 64b8 <malloc+0x69c>
     df2:	00005097          	auipc	ra,0x5
     df6:	c00080e7          	jalr	-1024(ra) # 59f2 <write>
  close(fd1);
     dfa:	854a                	mv	a0,s2
     dfc:	00005097          	auipc	ra,0x5
     e00:	bfe080e7          	jalr	-1026(ra) # 59fa <close>
  if (read(fd, buf, sizeof(buf)) != SZ)
     e04:	660d                	lui	a2,0x3
     e06:	0000c597          	auipc	a1,0xc
     e0a:	e7258593          	addi	a1,a1,-398 # cc78 <buf>
     e0e:	8526                	mv	a0,s1
     e10:	00005097          	auipc	ra,0x5
     e14:	bda080e7          	jalr	-1062(ra) # 59ea <read>
     e18:	4795                	li	a5,5
     e1a:	0af51563          	bne	a0,a5,ec4 <unlinkread+0x162>
  if (buf[0] != 'h')
     e1e:	0000c717          	auipc	a4,0xc
     e22:	e5a74703          	lbu	a4,-422(a4) # cc78 <buf>
     e26:	06800793          	li	a5,104
     e2a:	0af71b63          	bne	a4,a5,ee0 <unlinkread+0x17e>
  if (write(fd, buf, 10) != 10)
     e2e:	4629                	li	a2,10
     e30:	0000c597          	auipc	a1,0xc
     e34:	e4858593          	addi	a1,a1,-440 # cc78 <buf>
     e38:	8526                	mv	a0,s1
     e3a:	00005097          	auipc	ra,0x5
     e3e:	bb8080e7          	jalr	-1096(ra) # 59f2 <write>
     e42:	47a9                	li	a5,10
     e44:	0af51c63          	bne	a0,a5,efc <unlinkread+0x19a>
  close(fd);
     e48:	8526                	mv	a0,s1
     e4a:	00005097          	auipc	ra,0x5
     e4e:	bb0080e7          	jalr	-1104(ra) # 59fa <close>
  unlink("unlinkread");
     e52:	00005517          	auipc	a0,0x5
     e56:	5ee50513          	addi	a0,a0,1518 # 6440 <malloc+0x624>
     e5a:	00005097          	auipc	ra,0x5
     e5e:	bc8080e7          	jalr	-1080(ra) # 5a22 <unlink>
}
     e62:	70a2                	ld	ra,40(sp)
     e64:	7402                	ld	s0,32(sp)
     e66:	64e2                	ld	s1,24(sp)
     e68:	6942                	ld	s2,16(sp)
     e6a:	69a2                	ld	s3,8(sp)
     e6c:	6145                	addi	sp,sp,48
     e6e:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     e70:	85ce                	mv	a1,s3
     e72:	00005517          	auipc	a0,0x5
     e76:	5de50513          	addi	a0,a0,1502 # 6450 <malloc+0x634>
     e7a:	00005097          	auipc	ra,0x5
     e7e:	eea080e7          	jalr	-278(ra) # 5d64 <printf>
    exit(1);
     e82:	4505                	li	a0,1
     e84:	00005097          	auipc	ra,0x5
     e88:	b4e080e7          	jalr	-1202(ra) # 59d2 <exit>
    printf("%s: open unlinkread failed\n", s);
     e8c:	85ce                	mv	a1,s3
     e8e:	00005517          	auipc	a0,0x5
     e92:	5ea50513          	addi	a0,a0,1514 # 6478 <malloc+0x65c>
     e96:	00005097          	auipc	ra,0x5
     e9a:	ece080e7          	jalr	-306(ra) # 5d64 <printf>
    exit(1);
     e9e:	4505                	li	a0,1
     ea0:	00005097          	auipc	ra,0x5
     ea4:	b32080e7          	jalr	-1230(ra) # 59d2 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     ea8:	85ce                	mv	a1,s3
     eaa:	00005517          	auipc	a0,0x5
     eae:	5ee50513          	addi	a0,a0,1518 # 6498 <malloc+0x67c>
     eb2:	00005097          	auipc	ra,0x5
     eb6:	eb2080e7          	jalr	-334(ra) # 5d64 <printf>
    exit(1);
     eba:	4505                	li	a0,1
     ebc:	00005097          	auipc	ra,0x5
     ec0:	b16080e7          	jalr	-1258(ra) # 59d2 <exit>
    printf("%s: unlinkread read failed", s);
     ec4:	85ce                	mv	a1,s3
     ec6:	00005517          	auipc	a0,0x5
     eca:	5fa50513          	addi	a0,a0,1530 # 64c0 <malloc+0x6a4>
     ece:	00005097          	auipc	ra,0x5
     ed2:	e96080e7          	jalr	-362(ra) # 5d64 <printf>
    exit(1);
     ed6:	4505                	li	a0,1
     ed8:	00005097          	auipc	ra,0x5
     edc:	afa080e7          	jalr	-1286(ra) # 59d2 <exit>
    printf("%s: unlinkread wrong data\n", s);
     ee0:	85ce                	mv	a1,s3
     ee2:	00005517          	auipc	a0,0x5
     ee6:	5fe50513          	addi	a0,a0,1534 # 64e0 <malloc+0x6c4>
     eea:	00005097          	auipc	ra,0x5
     eee:	e7a080e7          	jalr	-390(ra) # 5d64 <printf>
    exit(1);
     ef2:	4505                	li	a0,1
     ef4:	00005097          	auipc	ra,0x5
     ef8:	ade080e7          	jalr	-1314(ra) # 59d2 <exit>
    printf("%s: unlinkread write failed\n", s);
     efc:	85ce                	mv	a1,s3
     efe:	00005517          	auipc	a0,0x5
     f02:	60250513          	addi	a0,a0,1538 # 6500 <malloc+0x6e4>
     f06:	00005097          	auipc	ra,0x5
     f0a:	e5e080e7          	jalr	-418(ra) # 5d64 <printf>
    exit(1);
     f0e:	4505                	li	a0,1
     f10:	00005097          	auipc	ra,0x5
     f14:	ac2080e7          	jalr	-1342(ra) # 59d2 <exit>

0000000000000f18 <linktest>:
{
     f18:	1101                	addi	sp,sp,-32
     f1a:	ec06                	sd	ra,24(sp)
     f1c:	e822                	sd	s0,16(sp)
     f1e:	e426                	sd	s1,8(sp)
     f20:	e04a                	sd	s2,0(sp)
     f22:	1000                	addi	s0,sp,32
     f24:	892a                	mv	s2,a0
  unlink("lf1");
     f26:	00005517          	auipc	a0,0x5
     f2a:	5fa50513          	addi	a0,a0,1530 # 6520 <malloc+0x704>
     f2e:	00005097          	auipc	ra,0x5
     f32:	af4080e7          	jalr	-1292(ra) # 5a22 <unlink>
  unlink("lf2");
     f36:	00005517          	auipc	a0,0x5
     f3a:	5f250513          	addi	a0,a0,1522 # 6528 <malloc+0x70c>
     f3e:	00005097          	auipc	ra,0x5
     f42:	ae4080e7          	jalr	-1308(ra) # 5a22 <unlink>
  fd = open("lf1", O_CREATE | O_RDWR);
     f46:	20200593          	li	a1,514
     f4a:	00005517          	auipc	a0,0x5
     f4e:	5d650513          	addi	a0,a0,1494 # 6520 <malloc+0x704>
     f52:	00005097          	auipc	ra,0x5
     f56:	ac0080e7          	jalr	-1344(ra) # 5a12 <open>
  if (fd < 0)
     f5a:	10054763          	bltz	a0,1068 <linktest+0x150>
     f5e:	84aa                	mv	s1,a0
  if (write(fd, "hello", SZ) != SZ)
     f60:	4615                	li	a2,5
     f62:	00005597          	auipc	a1,0x5
     f66:	50e58593          	addi	a1,a1,1294 # 6470 <malloc+0x654>
     f6a:	00005097          	auipc	ra,0x5
     f6e:	a88080e7          	jalr	-1400(ra) # 59f2 <write>
     f72:	4795                	li	a5,5
     f74:	10f51863          	bne	a0,a5,1084 <linktest+0x16c>
  close(fd);
     f78:	8526                	mv	a0,s1
     f7a:	00005097          	auipc	ra,0x5
     f7e:	a80080e7          	jalr	-1408(ra) # 59fa <close>
  if (link("lf1", "lf2") < 0)
     f82:	00005597          	auipc	a1,0x5
     f86:	5a658593          	addi	a1,a1,1446 # 6528 <malloc+0x70c>
     f8a:	00005517          	auipc	a0,0x5
     f8e:	59650513          	addi	a0,a0,1430 # 6520 <malloc+0x704>
     f92:	00005097          	auipc	ra,0x5
     f96:	aa0080e7          	jalr	-1376(ra) # 5a32 <link>
     f9a:	10054363          	bltz	a0,10a0 <linktest+0x188>
  unlink("lf1");
     f9e:	00005517          	auipc	a0,0x5
     fa2:	58250513          	addi	a0,a0,1410 # 6520 <malloc+0x704>
     fa6:	00005097          	auipc	ra,0x5
     faa:	a7c080e7          	jalr	-1412(ra) # 5a22 <unlink>
  if (open("lf1", 0) >= 0)
     fae:	4581                	li	a1,0
     fb0:	00005517          	auipc	a0,0x5
     fb4:	57050513          	addi	a0,a0,1392 # 6520 <malloc+0x704>
     fb8:	00005097          	auipc	ra,0x5
     fbc:	a5a080e7          	jalr	-1446(ra) # 5a12 <open>
     fc0:	0e055e63          	bgez	a0,10bc <linktest+0x1a4>
  fd = open("lf2", 0);
     fc4:	4581                	li	a1,0
     fc6:	00005517          	auipc	a0,0x5
     fca:	56250513          	addi	a0,a0,1378 # 6528 <malloc+0x70c>
     fce:	00005097          	auipc	ra,0x5
     fd2:	a44080e7          	jalr	-1468(ra) # 5a12 <open>
     fd6:	84aa                	mv	s1,a0
  if (fd < 0)
     fd8:	10054063          	bltz	a0,10d8 <linktest+0x1c0>
  if (read(fd, buf, sizeof(buf)) != SZ)
     fdc:	660d                	lui	a2,0x3
     fde:	0000c597          	auipc	a1,0xc
     fe2:	c9a58593          	addi	a1,a1,-870 # cc78 <buf>
     fe6:	00005097          	auipc	ra,0x5
     fea:	a04080e7          	jalr	-1532(ra) # 59ea <read>
     fee:	4795                	li	a5,5
     ff0:	10f51263          	bne	a0,a5,10f4 <linktest+0x1dc>
  close(fd);
     ff4:	8526                	mv	a0,s1
     ff6:	00005097          	auipc	ra,0x5
     ffa:	a04080e7          	jalr	-1532(ra) # 59fa <close>
  if (link("lf2", "lf2") >= 0)
     ffe:	00005597          	auipc	a1,0x5
    1002:	52a58593          	addi	a1,a1,1322 # 6528 <malloc+0x70c>
    1006:	852e                	mv	a0,a1
    1008:	00005097          	auipc	ra,0x5
    100c:	a2a080e7          	jalr	-1494(ra) # 5a32 <link>
    1010:	10055063          	bgez	a0,1110 <linktest+0x1f8>
  unlink("lf2");
    1014:	00005517          	auipc	a0,0x5
    1018:	51450513          	addi	a0,a0,1300 # 6528 <malloc+0x70c>
    101c:	00005097          	auipc	ra,0x5
    1020:	a06080e7          	jalr	-1530(ra) # 5a22 <unlink>
  if (link("lf2", "lf1") >= 0)
    1024:	00005597          	auipc	a1,0x5
    1028:	4fc58593          	addi	a1,a1,1276 # 6520 <malloc+0x704>
    102c:	00005517          	auipc	a0,0x5
    1030:	4fc50513          	addi	a0,a0,1276 # 6528 <malloc+0x70c>
    1034:	00005097          	auipc	ra,0x5
    1038:	9fe080e7          	jalr	-1538(ra) # 5a32 <link>
    103c:	0e055863          	bgez	a0,112c <linktest+0x214>
  if (link(".", "lf1") >= 0)
    1040:	00005597          	auipc	a1,0x5
    1044:	4e058593          	addi	a1,a1,1248 # 6520 <malloc+0x704>
    1048:	00005517          	auipc	a0,0x5
    104c:	5e850513          	addi	a0,a0,1512 # 6630 <malloc+0x814>
    1050:	00005097          	auipc	ra,0x5
    1054:	9e2080e7          	jalr	-1566(ra) # 5a32 <link>
    1058:	0e055863          	bgez	a0,1148 <linktest+0x230>
}
    105c:	60e2                	ld	ra,24(sp)
    105e:	6442                	ld	s0,16(sp)
    1060:	64a2                	ld	s1,8(sp)
    1062:	6902                	ld	s2,0(sp)
    1064:	6105                	addi	sp,sp,32
    1066:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    1068:	85ca                	mv	a1,s2
    106a:	00005517          	auipc	a0,0x5
    106e:	4c650513          	addi	a0,a0,1222 # 6530 <malloc+0x714>
    1072:	00005097          	auipc	ra,0x5
    1076:	cf2080e7          	jalr	-782(ra) # 5d64 <printf>
    exit(1);
    107a:	4505                	li	a0,1
    107c:	00005097          	auipc	ra,0x5
    1080:	956080e7          	jalr	-1706(ra) # 59d2 <exit>
    printf("%s: write lf1 failed\n", s);
    1084:	85ca                	mv	a1,s2
    1086:	00005517          	auipc	a0,0x5
    108a:	4c250513          	addi	a0,a0,1218 # 6548 <malloc+0x72c>
    108e:	00005097          	auipc	ra,0x5
    1092:	cd6080e7          	jalr	-810(ra) # 5d64 <printf>
    exit(1);
    1096:	4505                	li	a0,1
    1098:	00005097          	auipc	ra,0x5
    109c:	93a080e7          	jalr	-1734(ra) # 59d2 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    10a0:	85ca                	mv	a1,s2
    10a2:	00005517          	auipc	a0,0x5
    10a6:	4be50513          	addi	a0,a0,1214 # 6560 <malloc+0x744>
    10aa:	00005097          	auipc	ra,0x5
    10ae:	cba080e7          	jalr	-838(ra) # 5d64 <printf>
    exit(1);
    10b2:	4505                	li	a0,1
    10b4:	00005097          	auipc	ra,0x5
    10b8:	91e080e7          	jalr	-1762(ra) # 59d2 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    10bc:	85ca                	mv	a1,s2
    10be:	00005517          	auipc	a0,0x5
    10c2:	4c250513          	addi	a0,a0,1218 # 6580 <malloc+0x764>
    10c6:	00005097          	auipc	ra,0x5
    10ca:	c9e080e7          	jalr	-866(ra) # 5d64 <printf>
    exit(1);
    10ce:	4505                	li	a0,1
    10d0:	00005097          	auipc	ra,0x5
    10d4:	902080e7          	jalr	-1790(ra) # 59d2 <exit>
    printf("%s: open lf2 failed\n", s);
    10d8:	85ca                	mv	a1,s2
    10da:	00005517          	auipc	a0,0x5
    10de:	4d650513          	addi	a0,a0,1238 # 65b0 <malloc+0x794>
    10e2:	00005097          	auipc	ra,0x5
    10e6:	c82080e7          	jalr	-894(ra) # 5d64 <printf>
    exit(1);
    10ea:	4505                	li	a0,1
    10ec:	00005097          	auipc	ra,0x5
    10f0:	8e6080e7          	jalr	-1818(ra) # 59d2 <exit>
    printf("%s: read lf2 failed\n", s);
    10f4:	85ca                	mv	a1,s2
    10f6:	00005517          	auipc	a0,0x5
    10fa:	4d250513          	addi	a0,a0,1234 # 65c8 <malloc+0x7ac>
    10fe:	00005097          	auipc	ra,0x5
    1102:	c66080e7          	jalr	-922(ra) # 5d64 <printf>
    exit(1);
    1106:	4505                	li	a0,1
    1108:	00005097          	auipc	ra,0x5
    110c:	8ca080e7          	jalr	-1846(ra) # 59d2 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    1110:	85ca                	mv	a1,s2
    1112:	00005517          	auipc	a0,0x5
    1116:	4ce50513          	addi	a0,a0,1230 # 65e0 <malloc+0x7c4>
    111a:	00005097          	auipc	ra,0x5
    111e:	c4a080e7          	jalr	-950(ra) # 5d64 <printf>
    exit(1);
    1122:	4505                	li	a0,1
    1124:	00005097          	auipc	ra,0x5
    1128:	8ae080e7          	jalr	-1874(ra) # 59d2 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    112c:	85ca                	mv	a1,s2
    112e:	00005517          	auipc	a0,0x5
    1132:	4da50513          	addi	a0,a0,1242 # 6608 <malloc+0x7ec>
    1136:	00005097          	auipc	ra,0x5
    113a:	c2e080e7          	jalr	-978(ra) # 5d64 <printf>
    exit(1);
    113e:	4505                	li	a0,1
    1140:	00005097          	auipc	ra,0x5
    1144:	892080e7          	jalr	-1902(ra) # 59d2 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    1148:	85ca                	mv	a1,s2
    114a:	00005517          	auipc	a0,0x5
    114e:	4ee50513          	addi	a0,a0,1262 # 6638 <malloc+0x81c>
    1152:	00005097          	auipc	ra,0x5
    1156:	c12080e7          	jalr	-1006(ra) # 5d64 <printf>
    exit(1);
    115a:	4505                	li	a0,1
    115c:	00005097          	auipc	ra,0x5
    1160:	876080e7          	jalr	-1930(ra) # 59d2 <exit>

0000000000001164 <validatetest>:
{
    1164:	7139                	addi	sp,sp,-64
    1166:	fc06                	sd	ra,56(sp)
    1168:	f822                	sd	s0,48(sp)
    116a:	f426                	sd	s1,40(sp)
    116c:	f04a                	sd	s2,32(sp)
    116e:	ec4e                	sd	s3,24(sp)
    1170:	e852                	sd	s4,16(sp)
    1172:	e456                	sd	s5,8(sp)
    1174:	e05a                	sd	s6,0(sp)
    1176:	0080                	addi	s0,sp,64
    1178:	8b2a                	mv	s6,a0
  for (p = 0; p <= (uint)hi; p += PGSIZE)
    117a:	4481                	li	s1,0
    if (link("nosuchfile", (char *)p) != -1)
    117c:	00005997          	auipc	s3,0x5
    1180:	4dc98993          	addi	s3,s3,1244 # 6658 <malloc+0x83c>
    1184:	597d                	li	s2,-1
  for (p = 0; p <= (uint)hi; p += PGSIZE)
    1186:	6a85                	lui	s5,0x1
    1188:	00114a37          	lui	s4,0x114
    if (link("nosuchfile", (char *)p) != -1)
    118c:	85a6                	mv	a1,s1
    118e:	854e                	mv	a0,s3
    1190:	00005097          	auipc	ra,0x5
    1194:	8a2080e7          	jalr	-1886(ra) # 5a32 <link>
    1198:	01251f63          	bne	a0,s2,11b6 <validatetest+0x52>
  for (p = 0; p <= (uint)hi; p += PGSIZE)
    119c:	94d6                	add	s1,s1,s5
    119e:	ff4497e3          	bne	s1,s4,118c <validatetest+0x28>
}
    11a2:	70e2                	ld	ra,56(sp)
    11a4:	7442                	ld	s0,48(sp)
    11a6:	74a2                	ld	s1,40(sp)
    11a8:	7902                	ld	s2,32(sp)
    11aa:	69e2                	ld	s3,24(sp)
    11ac:	6a42                	ld	s4,16(sp)
    11ae:	6aa2                	ld	s5,8(sp)
    11b0:	6b02                	ld	s6,0(sp)
    11b2:	6121                	addi	sp,sp,64
    11b4:	8082                	ret
      printf("%s: link should not succeed\n", s);
    11b6:	85da                	mv	a1,s6
    11b8:	00005517          	auipc	a0,0x5
    11bc:	4b050513          	addi	a0,a0,1200 # 6668 <malloc+0x84c>
    11c0:	00005097          	auipc	ra,0x5
    11c4:	ba4080e7          	jalr	-1116(ra) # 5d64 <printf>
      exit(1);
    11c8:	4505                	li	a0,1
    11ca:	00005097          	auipc	ra,0x5
    11ce:	808080e7          	jalr	-2040(ra) # 59d2 <exit>

00000000000011d2 <bigdir>:
{
    11d2:	715d                	addi	sp,sp,-80
    11d4:	e486                	sd	ra,72(sp)
    11d6:	e0a2                	sd	s0,64(sp)
    11d8:	fc26                	sd	s1,56(sp)
    11da:	f84a                	sd	s2,48(sp)
    11dc:	f44e                	sd	s3,40(sp)
    11de:	f052                	sd	s4,32(sp)
    11e0:	ec56                	sd	s5,24(sp)
    11e2:	e85a                	sd	s6,16(sp)
    11e4:	0880                	addi	s0,sp,80
    11e6:	89aa                	mv	s3,a0
  unlink("bd");
    11e8:	00005517          	auipc	a0,0x5
    11ec:	4a050513          	addi	a0,a0,1184 # 6688 <malloc+0x86c>
    11f0:	00005097          	auipc	ra,0x5
    11f4:	832080e7          	jalr	-1998(ra) # 5a22 <unlink>
  fd = open("bd", O_CREATE);
    11f8:	20000593          	li	a1,512
    11fc:	00005517          	auipc	a0,0x5
    1200:	48c50513          	addi	a0,a0,1164 # 6688 <malloc+0x86c>
    1204:	00005097          	auipc	ra,0x5
    1208:	80e080e7          	jalr	-2034(ra) # 5a12 <open>
  if (fd < 0)
    120c:	0c054963          	bltz	a0,12de <bigdir+0x10c>
  close(fd);
    1210:	00004097          	auipc	ra,0x4
    1214:	7ea080e7          	jalr	2026(ra) # 59fa <close>
  for (i = 0; i < N; i++)
    1218:	4901                	li	s2,0
    name[0] = 'x';
    121a:	07800a93          	li	s5,120
    if (link("bd", name) != 0)
    121e:	00005a17          	auipc	s4,0x5
    1222:	46aa0a13          	addi	s4,s4,1130 # 6688 <malloc+0x86c>
  for (i = 0; i < N; i++)
    1226:	1f400b13          	li	s6,500
    name[0] = 'x';
    122a:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    122e:	41f9571b          	sraiw	a4,s2,0x1f
    1232:	01a7571b          	srliw	a4,a4,0x1a
    1236:	012707bb          	addw	a5,a4,s2
    123a:	4067d69b          	sraiw	a3,a5,0x6
    123e:	0306869b          	addiw	a3,a3,48
    1242:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1246:	03f7f793          	andi	a5,a5,63
    124a:	9f99                	subw	a5,a5,a4
    124c:	0307879b          	addiw	a5,a5,48
    1250:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1254:	fa0409a3          	sb	zero,-77(s0)
    if (link("bd", name) != 0)
    1258:	fb040593          	addi	a1,s0,-80
    125c:	8552                	mv	a0,s4
    125e:	00004097          	auipc	ra,0x4
    1262:	7d4080e7          	jalr	2004(ra) # 5a32 <link>
    1266:	84aa                	mv	s1,a0
    1268:	e949                	bnez	a0,12fa <bigdir+0x128>
  for (i = 0; i < N; i++)
    126a:	2905                	addiw	s2,s2,1
    126c:	fb691fe3          	bne	s2,s6,122a <bigdir+0x58>
  unlink("bd");
    1270:	00005517          	auipc	a0,0x5
    1274:	41850513          	addi	a0,a0,1048 # 6688 <malloc+0x86c>
    1278:	00004097          	auipc	ra,0x4
    127c:	7aa080e7          	jalr	1962(ra) # 5a22 <unlink>
    name[0] = 'x';
    1280:	07800913          	li	s2,120
  for (i = 0; i < N; i++)
    1284:	1f400a13          	li	s4,500
    name[0] = 'x';
    1288:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    128c:	41f4d71b          	sraiw	a4,s1,0x1f
    1290:	01a7571b          	srliw	a4,a4,0x1a
    1294:	009707bb          	addw	a5,a4,s1
    1298:	4067d69b          	sraiw	a3,a5,0x6
    129c:	0306869b          	addiw	a3,a3,48
    12a0:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    12a4:	03f7f793          	andi	a5,a5,63
    12a8:	9f99                	subw	a5,a5,a4
    12aa:	0307879b          	addiw	a5,a5,48
    12ae:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    12b2:	fa0409a3          	sb	zero,-77(s0)
    if (unlink(name) != 0)
    12b6:	fb040513          	addi	a0,s0,-80
    12ba:	00004097          	auipc	ra,0x4
    12be:	768080e7          	jalr	1896(ra) # 5a22 <unlink>
    12c2:	ed21                	bnez	a0,131a <bigdir+0x148>
  for (i = 0; i < N; i++)
    12c4:	2485                	addiw	s1,s1,1
    12c6:	fd4491e3          	bne	s1,s4,1288 <bigdir+0xb6>
}
    12ca:	60a6                	ld	ra,72(sp)
    12cc:	6406                	ld	s0,64(sp)
    12ce:	74e2                	ld	s1,56(sp)
    12d0:	7942                	ld	s2,48(sp)
    12d2:	79a2                	ld	s3,40(sp)
    12d4:	7a02                	ld	s4,32(sp)
    12d6:	6ae2                	ld	s5,24(sp)
    12d8:	6b42                	ld	s6,16(sp)
    12da:	6161                	addi	sp,sp,80
    12dc:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    12de:	85ce                	mv	a1,s3
    12e0:	00005517          	auipc	a0,0x5
    12e4:	3b050513          	addi	a0,a0,944 # 6690 <malloc+0x874>
    12e8:	00005097          	auipc	ra,0x5
    12ec:	a7c080e7          	jalr	-1412(ra) # 5d64 <printf>
    exit(1);
    12f0:	4505                	li	a0,1
    12f2:	00004097          	auipc	ra,0x4
    12f6:	6e0080e7          	jalr	1760(ra) # 59d2 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    12fa:	fb040613          	addi	a2,s0,-80
    12fe:	85ce                	mv	a1,s3
    1300:	00005517          	auipc	a0,0x5
    1304:	3b050513          	addi	a0,a0,944 # 66b0 <malloc+0x894>
    1308:	00005097          	auipc	ra,0x5
    130c:	a5c080e7          	jalr	-1444(ra) # 5d64 <printf>
      exit(1);
    1310:	4505                	li	a0,1
    1312:	00004097          	auipc	ra,0x4
    1316:	6c0080e7          	jalr	1728(ra) # 59d2 <exit>
      printf("%s: bigdir unlink failed", s);
    131a:	85ce                	mv	a1,s3
    131c:	00005517          	auipc	a0,0x5
    1320:	3b450513          	addi	a0,a0,948 # 66d0 <malloc+0x8b4>
    1324:	00005097          	auipc	ra,0x5
    1328:	a40080e7          	jalr	-1472(ra) # 5d64 <printf>
      exit(1);
    132c:	4505                	li	a0,1
    132e:	00004097          	auipc	ra,0x4
    1332:	6a4080e7          	jalr	1700(ra) # 59d2 <exit>

0000000000001336 <pgbug>:
{
    1336:	7179                	addi	sp,sp,-48
    1338:	f406                	sd	ra,40(sp)
    133a:	f022                	sd	s0,32(sp)
    133c:	ec26                	sd	s1,24(sp)
    133e:	1800                	addi	s0,sp,48
  argv[0] = 0;
    1340:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1344:	00008497          	auipc	s1,0x8
    1348:	cbc48493          	addi	s1,s1,-836 # 9000 <big>
    134c:	fd840593          	addi	a1,s0,-40
    1350:	6088                	ld	a0,0(s1)
    1352:	00004097          	auipc	ra,0x4
    1356:	6b8080e7          	jalr	1720(ra) # 5a0a <exec>
  pipe(big);
    135a:	6088                	ld	a0,0(s1)
    135c:	00004097          	auipc	ra,0x4
    1360:	686080e7          	jalr	1670(ra) # 59e2 <pipe>
  exit(0);
    1364:	4501                	li	a0,0
    1366:	00004097          	auipc	ra,0x4
    136a:	66c080e7          	jalr	1644(ra) # 59d2 <exit>

000000000000136e <badarg>:
{
    136e:	7139                	addi	sp,sp,-64
    1370:	fc06                	sd	ra,56(sp)
    1372:	f822                	sd	s0,48(sp)
    1374:	f426                	sd	s1,40(sp)
    1376:	f04a                	sd	s2,32(sp)
    1378:	ec4e                	sd	s3,24(sp)
    137a:	0080                	addi	s0,sp,64
    137c:	64b1                	lui	s1,0xc
    137e:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1de8>
    argv[0] = (char *)0xffffffff;
    1382:	597d                	li	s2,-1
    1384:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    1388:	00005997          	auipc	s3,0x5
    138c:	bc098993          	addi	s3,s3,-1088 # 5f48 <malloc+0x12c>
    argv[0] = (char *)0xffffffff;
    1390:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1394:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1398:	fc040593          	addi	a1,s0,-64
    139c:	854e                	mv	a0,s3
    139e:	00004097          	auipc	ra,0x4
    13a2:	66c080e7          	jalr	1644(ra) # 5a0a <exec>
  for (int i = 0; i < 50000; i++)
    13a6:	34fd                	addiw	s1,s1,-1
    13a8:	f4e5                	bnez	s1,1390 <badarg+0x22>
  exit(0);
    13aa:	4501                	li	a0,0
    13ac:	00004097          	auipc	ra,0x4
    13b0:	626080e7          	jalr	1574(ra) # 59d2 <exit>

00000000000013b4 <copyinstr2>:
{
    13b4:	7155                	addi	sp,sp,-208
    13b6:	e586                	sd	ra,200(sp)
    13b8:	e1a2                	sd	s0,192(sp)
    13ba:	0980                	addi	s0,sp,208
  for (int i = 0; i < MAXPATH; i++)
    13bc:	f6840793          	addi	a5,s0,-152
    13c0:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    13c4:	07800713          	li	a4,120
    13c8:	00e78023          	sb	a4,0(a5)
  for (int i = 0; i < MAXPATH; i++)
    13cc:	0785                	addi	a5,a5,1
    13ce:	fed79de3          	bne	a5,a3,13c8 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    13d2:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    13d6:	f6840513          	addi	a0,s0,-152
    13da:	00004097          	auipc	ra,0x4
    13de:	648080e7          	jalr	1608(ra) # 5a22 <unlink>
  if (ret != -1)
    13e2:	57fd                	li	a5,-1
    13e4:	0ef51063          	bne	a0,a5,14c4 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    13e8:	20100593          	li	a1,513
    13ec:	f6840513          	addi	a0,s0,-152
    13f0:	00004097          	auipc	ra,0x4
    13f4:	622080e7          	jalr	1570(ra) # 5a12 <open>
  if (fd != -1)
    13f8:	57fd                	li	a5,-1
    13fa:	0ef51563          	bne	a0,a5,14e4 <copyinstr2+0x130>
  ret = link(b, b);
    13fe:	f6840593          	addi	a1,s0,-152
    1402:	852e                	mv	a0,a1
    1404:	00004097          	auipc	ra,0x4
    1408:	62e080e7          	jalr	1582(ra) # 5a32 <link>
  if (ret != -1)
    140c:	57fd                	li	a5,-1
    140e:	0ef51b63          	bne	a0,a5,1504 <copyinstr2+0x150>
  char *args[] = {"xx", 0};
    1412:	00006797          	auipc	a5,0x6
    1416:	51678793          	addi	a5,a5,1302 # 7928 <malloc+0x1b0c>
    141a:	f4f43c23          	sd	a5,-168(s0)
    141e:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1422:	f5840593          	addi	a1,s0,-168
    1426:	f6840513          	addi	a0,s0,-152
    142a:	00004097          	auipc	ra,0x4
    142e:	5e0080e7          	jalr	1504(ra) # 5a0a <exec>
  if (ret != -1)
    1432:	57fd                	li	a5,-1
    1434:	0ef51963          	bne	a0,a5,1526 <copyinstr2+0x172>
  int pid = fork();
    1438:	00004097          	auipc	ra,0x4
    143c:	592080e7          	jalr	1426(ra) # 59ca <fork>
  if (pid < 0)
    1440:	10054363          	bltz	a0,1546 <copyinstr2+0x192>
  if (pid == 0)
    1444:	12051463          	bnez	a0,156c <copyinstr2+0x1b8>
    1448:	00008797          	auipc	a5,0x8
    144c:	11878793          	addi	a5,a5,280 # 9560 <big.0>
    1450:	00009697          	auipc	a3,0x9
    1454:	11068693          	addi	a3,a3,272 # a560 <big.0+0x1000>
      big[i] = 'x';
    1458:	07800713          	li	a4,120
    145c:	00e78023          	sb	a4,0(a5)
    for (int i = 0; i < PGSIZE; i++)
    1460:	0785                	addi	a5,a5,1
    1462:	fed79de3          	bne	a5,a3,145c <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1466:	00009797          	auipc	a5,0x9
    146a:	0e078d23          	sb	zero,250(a5) # a560 <big.0+0x1000>
    char *args2[] = {big, big, big, 0};
    146e:	00007797          	auipc	a5,0x7
    1472:	eaa78793          	addi	a5,a5,-342 # 8318 <malloc+0x24fc>
    1476:	6390                	ld	a2,0(a5)
    1478:	6794                	ld	a3,8(a5)
    147a:	6b98                	ld	a4,16(a5)
    147c:	6f9c                	ld	a5,24(a5)
    147e:	f2c43823          	sd	a2,-208(s0)
    1482:	f2d43c23          	sd	a3,-200(s0)
    1486:	f4e43023          	sd	a4,-192(s0)
    148a:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    148e:	f3040593          	addi	a1,s0,-208
    1492:	00005517          	auipc	a0,0x5
    1496:	ab650513          	addi	a0,a0,-1354 # 5f48 <malloc+0x12c>
    149a:	00004097          	auipc	ra,0x4
    149e:	570080e7          	jalr	1392(ra) # 5a0a <exec>
    if (ret != -1)
    14a2:	57fd                	li	a5,-1
    14a4:	0af50e63          	beq	a0,a5,1560 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    14a8:	55fd                	li	a1,-1
    14aa:	00005517          	auipc	a0,0x5
    14ae:	2ce50513          	addi	a0,a0,718 # 6778 <malloc+0x95c>
    14b2:	00005097          	auipc	ra,0x5
    14b6:	8b2080e7          	jalr	-1870(ra) # 5d64 <printf>
      exit(1);
    14ba:	4505                	li	a0,1
    14bc:	00004097          	auipc	ra,0x4
    14c0:	516080e7          	jalr	1302(ra) # 59d2 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    14c4:	862a                	mv	a2,a0
    14c6:	f6840593          	addi	a1,s0,-152
    14ca:	00005517          	auipc	a0,0x5
    14ce:	22650513          	addi	a0,a0,550 # 66f0 <malloc+0x8d4>
    14d2:	00005097          	auipc	ra,0x5
    14d6:	892080e7          	jalr	-1902(ra) # 5d64 <printf>
    exit(1);
    14da:	4505                	li	a0,1
    14dc:	00004097          	auipc	ra,0x4
    14e0:	4f6080e7          	jalr	1270(ra) # 59d2 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    14e4:	862a                	mv	a2,a0
    14e6:	f6840593          	addi	a1,s0,-152
    14ea:	00005517          	auipc	a0,0x5
    14ee:	22650513          	addi	a0,a0,550 # 6710 <malloc+0x8f4>
    14f2:	00005097          	auipc	ra,0x5
    14f6:	872080e7          	jalr	-1934(ra) # 5d64 <printf>
    exit(1);
    14fa:	4505                	li	a0,1
    14fc:	00004097          	auipc	ra,0x4
    1500:	4d6080e7          	jalr	1238(ra) # 59d2 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1504:	86aa                	mv	a3,a0
    1506:	f6840613          	addi	a2,s0,-152
    150a:	85b2                	mv	a1,a2
    150c:	00005517          	auipc	a0,0x5
    1510:	22450513          	addi	a0,a0,548 # 6730 <malloc+0x914>
    1514:	00005097          	auipc	ra,0x5
    1518:	850080e7          	jalr	-1968(ra) # 5d64 <printf>
    exit(1);
    151c:	4505                	li	a0,1
    151e:	00004097          	auipc	ra,0x4
    1522:	4b4080e7          	jalr	1204(ra) # 59d2 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1526:	567d                	li	a2,-1
    1528:	f6840593          	addi	a1,s0,-152
    152c:	00005517          	auipc	a0,0x5
    1530:	22c50513          	addi	a0,a0,556 # 6758 <malloc+0x93c>
    1534:	00005097          	auipc	ra,0x5
    1538:	830080e7          	jalr	-2000(ra) # 5d64 <printf>
    exit(1);
    153c:	4505                	li	a0,1
    153e:	00004097          	auipc	ra,0x4
    1542:	494080e7          	jalr	1172(ra) # 59d2 <exit>
    printf("fork failed\n");
    1546:	00005517          	auipc	a0,0x5
    154a:	69250513          	addi	a0,a0,1682 # 6bd8 <malloc+0xdbc>
    154e:	00005097          	auipc	ra,0x5
    1552:	816080e7          	jalr	-2026(ra) # 5d64 <printf>
    exit(1);
    1556:	4505                	li	a0,1
    1558:	00004097          	auipc	ra,0x4
    155c:	47a080e7          	jalr	1146(ra) # 59d2 <exit>
    exit(747); // OK
    1560:	2eb00513          	li	a0,747
    1564:	00004097          	auipc	ra,0x4
    1568:	46e080e7          	jalr	1134(ra) # 59d2 <exit>
  int st = 0;
    156c:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1570:	f5440513          	addi	a0,s0,-172
    1574:	00004097          	auipc	ra,0x4
    1578:	466080e7          	jalr	1126(ra) # 59da <wait>
  if (st != 747)
    157c:	f5442703          	lw	a4,-172(s0)
    1580:	2eb00793          	li	a5,747
    1584:	00f71663          	bne	a4,a5,1590 <copyinstr2+0x1dc>
}
    1588:	60ae                	ld	ra,200(sp)
    158a:	640e                	ld	s0,192(sp)
    158c:	6169                	addi	sp,sp,208
    158e:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    1590:	00005517          	auipc	a0,0x5
    1594:	21050513          	addi	a0,a0,528 # 67a0 <malloc+0x984>
    1598:	00004097          	auipc	ra,0x4
    159c:	7cc080e7          	jalr	1996(ra) # 5d64 <printf>
    exit(1);
    15a0:	4505                	li	a0,1
    15a2:	00004097          	auipc	ra,0x4
    15a6:	430080e7          	jalr	1072(ra) # 59d2 <exit>

00000000000015aa <truncate3>:
{
    15aa:	7159                	addi	sp,sp,-112
    15ac:	f486                	sd	ra,104(sp)
    15ae:	f0a2                	sd	s0,96(sp)
    15b0:	eca6                	sd	s1,88(sp)
    15b2:	e8ca                	sd	s2,80(sp)
    15b4:	e4ce                	sd	s3,72(sp)
    15b6:	e0d2                	sd	s4,64(sp)
    15b8:	fc56                	sd	s5,56(sp)
    15ba:	1880                	addi	s0,sp,112
    15bc:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE | O_TRUNC | O_WRONLY));
    15be:	60100593          	li	a1,1537
    15c2:	00005517          	auipc	a0,0x5
    15c6:	9de50513          	addi	a0,a0,-1570 # 5fa0 <malloc+0x184>
    15ca:	00004097          	auipc	ra,0x4
    15ce:	448080e7          	jalr	1096(ra) # 5a12 <open>
    15d2:	00004097          	auipc	ra,0x4
    15d6:	428080e7          	jalr	1064(ra) # 59fa <close>
  pid = fork();
    15da:	00004097          	auipc	ra,0x4
    15de:	3f0080e7          	jalr	1008(ra) # 59ca <fork>
  if (pid < 0)
    15e2:	08054063          	bltz	a0,1662 <truncate3+0xb8>
  if (pid == 0)
    15e6:	e969                	bnez	a0,16b8 <truncate3+0x10e>
    15e8:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    15ec:	00005a17          	auipc	s4,0x5
    15f0:	9b4a0a13          	addi	s4,s4,-1612 # 5fa0 <malloc+0x184>
      int n = write(fd, "1234567890", 10);
    15f4:	00005a97          	auipc	s5,0x5
    15f8:	20ca8a93          	addi	s5,s5,524 # 6800 <malloc+0x9e4>
      int fd = open("truncfile", O_WRONLY);
    15fc:	4585                	li	a1,1
    15fe:	8552                	mv	a0,s4
    1600:	00004097          	auipc	ra,0x4
    1604:	412080e7          	jalr	1042(ra) # 5a12 <open>
    1608:	84aa                	mv	s1,a0
      if (fd < 0)
    160a:	06054a63          	bltz	a0,167e <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    160e:	4629                	li	a2,10
    1610:	85d6                	mv	a1,s5
    1612:	00004097          	auipc	ra,0x4
    1616:	3e0080e7          	jalr	992(ra) # 59f2 <write>
      if (n != 10)
    161a:	47a9                	li	a5,10
    161c:	06f51f63          	bne	a0,a5,169a <truncate3+0xf0>
      close(fd);
    1620:	8526                	mv	a0,s1
    1622:	00004097          	auipc	ra,0x4
    1626:	3d8080e7          	jalr	984(ra) # 59fa <close>
      fd = open("truncfile", O_RDONLY);
    162a:	4581                	li	a1,0
    162c:	8552                	mv	a0,s4
    162e:	00004097          	auipc	ra,0x4
    1632:	3e4080e7          	jalr	996(ra) # 5a12 <open>
    1636:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1638:	02000613          	li	a2,32
    163c:	f9840593          	addi	a1,s0,-104
    1640:	00004097          	auipc	ra,0x4
    1644:	3aa080e7          	jalr	938(ra) # 59ea <read>
      close(fd);
    1648:	8526                	mv	a0,s1
    164a:	00004097          	auipc	ra,0x4
    164e:	3b0080e7          	jalr	944(ra) # 59fa <close>
    for (int i = 0; i < 100; i++)
    1652:	39fd                	addiw	s3,s3,-1
    1654:	fa0994e3          	bnez	s3,15fc <truncate3+0x52>
    exit(0);
    1658:	4501                	li	a0,0
    165a:	00004097          	auipc	ra,0x4
    165e:	378080e7          	jalr	888(ra) # 59d2 <exit>
    printf("%s: fork failed\n", s);
    1662:	85ca                	mv	a1,s2
    1664:	00005517          	auipc	a0,0x5
    1668:	16c50513          	addi	a0,a0,364 # 67d0 <malloc+0x9b4>
    166c:	00004097          	auipc	ra,0x4
    1670:	6f8080e7          	jalr	1784(ra) # 5d64 <printf>
    exit(1);
    1674:	4505                	li	a0,1
    1676:	00004097          	auipc	ra,0x4
    167a:	35c080e7          	jalr	860(ra) # 59d2 <exit>
        printf("%s: open failed\n", s);
    167e:	85ca                	mv	a1,s2
    1680:	00005517          	auipc	a0,0x5
    1684:	16850513          	addi	a0,a0,360 # 67e8 <malloc+0x9cc>
    1688:	00004097          	auipc	ra,0x4
    168c:	6dc080e7          	jalr	1756(ra) # 5d64 <printf>
        exit(1);
    1690:	4505                	li	a0,1
    1692:	00004097          	auipc	ra,0x4
    1696:	340080e7          	jalr	832(ra) # 59d2 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    169a:	862a                	mv	a2,a0
    169c:	85ca                	mv	a1,s2
    169e:	00005517          	auipc	a0,0x5
    16a2:	17250513          	addi	a0,a0,370 # 6810 <malloc+0x9f4>
    16a6:	00004097          	auipc	ra,0x4
    16aa:	6be080e7          	jalr	1726(ra) # 5d64 <printf>
        exit(1);
    16ae:	4505                	li	a0,1
    16b0:	00004097          	auipc	ra,0x4
    16b4:	322080e7          	jalr	802(ra) # 59d2 <exit>
    16b8:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    16bc:	00005a17          	auipc	s4,0x5
    16c0:	8e4a0a13          	addi	s4,s4,-1820 # 5fa0 <malloc+0x184>
    int n = write(fd, "xxx", 3);
    16c4:	00005a97          	auipc	s5,0x5
    16c8:	16ca8a93          	addi	s5,s5,364 # 6830 <malloc+0xa14>
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    16cc:	60100593          	li	a1,1537
    16d0:	8552                	mv	a0,s4
    16d2:	00004097          	auipc	ra,0x4
    16d6:	340080e7          	jalr	832(ra) # 5a12 <open>
    16da:	84aa                	mv	s1,a0
    if (fd < 0)
    16dc:	04054763          	bltz	a0,172a <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    16e0:	460d                	li	a2,3
    16e2:	85d6                	mv	a1,s5
    16e4:	00004097          	auipc	ra,0x4
    16e8:	30e080e7          	jalr	782(ra) # 59f2 <write>
    if (n != 3)
    16ec:	478d                	li	a5,3
    16ee:	04f51c63          	bne	a0,a5,1746 <truncate3+0x19c>
    close(fd);
    16f2:	8526                	mv	a0,s1
    16f4:	00004097          	auipc	ra,0x4
    16f8:	306080e7          	jalr	774(ra) # 59fa <close>
  for (int i = 0; i < 150; i++)
    16fc:	39fd                	addiw	s3,s3,-1
    16fe:	fc0997e3          	bnez	s3,16cc <truncate3+0x122>
  wait(&xstatus);
    1702:	fbc40513          	addi	a0,s0,-68
    1706:	00004097          	auipc	ra,0x4
    170a:	2d4080e7          	jalr	724(ra) # 59da <wait>
  unlink("truncfile");
    170e:	00005517          	auipc	a0,0x5
    1712:	89250513          	addi	a0,a0,-1902 # 5fa0 <malloc+0x184>
    1716:	00004097          	auipc	ra,0x4
    171a:	30c080e7          	jalr	780(ra) # 5a22 <unlink>
  exit(xstatus);
    171e:	fbc42503          	lw	a0,-68(s0)
    1722:	00004097          	auipc	ra,0x4
    1726:	2b0080e7          	jalr	688(ra) # 59d2 <exit>
      printf("%s: open failed\n", s);
    172a:	85ca                	mv	a1,s2
    172c:	00005517          	auipc	a0,0x5
    1730:	0bc50513          	addi	a0,a0,188 # 67e8 <malloc+0x9cc>
    1734:	00004097          	auipc	ra,0x4
    1738:	630080e7          	jalr	1584(ra) # 5d64 <printf>
      exit(1);
    173c:	4505                	li	a0,1
    173e:	00004097          	auipc	ra,0x4
    1742:	294080e7          	jalr	660(ra) # 59d2 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1746:	862a                	mv	a2,a0
    1748:	85ca                	mv	a1,s2
    174a:	00005517          	auipc	a0,0x5
    174e:	0ee50513          	addi	a0,a0,238 # 6838 <malloc+0xa1c>
    1752:	00004097          	auipc	ra,0x4
    1756:	612080e7          	jalr	1554(ra) # 5d64 <printf>
      exit(1);
    175a:	4505                	li	a0,1
    175c:	00004097          	auipc	ra,0x4
    1760:	276080e7          	jalr	630(ra) # 59d2 <exit>

0000000000001764 <exectest>:
{
    1764:	715d                	addi	sp,sp,-80
    1766:	e486                	sd	ra,72(sp)
    1768:	e0a2                	sd	s0,64(sp)
    176a:	fc26                	sd	s1,56(sp)
    176c:	f84a                	sd	s2,48(sp)
    176e:	0880                	addi	s0,sp,80
    1770:	892a                	mv	s2,a0
  char *echoargv[] = {"echo", "OK", 0};
    1772:	00004797          	auipc	a5,0x4
    1776:	7d678793          	addi	a5,a5,2006 # 5f48 <malloc+0x12c>
    177a:	fcf43023          	sd	a5,-64(s0)
    177e:	00005797          	auipc	a5,0x5
    1782:	0da78793          	addi	a5,a5,218 # 6858 <malloc+0xa3c>
    1786:	fcf43423          	sd	a5,-56(s0)
    178a:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    178e:	00005517          	auipc	a0,0x5
    1792:	0d250513          	addi	a0,a0,210 # 6860 <malloc+0xa44>
    1796:	00004097          	auipc	ra,0x4
    179a:	28c080e7          	jalr	652(ra) # 5a22 <unlink>
  pid = fork();
    179e:	00004097          	auipc	ra,0x4
    17a2:	22c080e7          	jalr	556(ra) # 59ca <fork>
  if (pid < 0)
    17a6:	04054663          	bltz	a0,17f2 <exectest+0x8e>
    17aa:	84aa                	mv	s1,a0
  if (pid == 0)
    17ac:	e959                	bnez	a0,1842 <exectest+0xde>
    close(1);
    17ae:	4505                	li	a0,1
    17b0:	00004097          	auipc	ra,0x4
    17b4:	24a080e7          	jalr	586(ra) # 59fa <close>
    fd = open("echo-ok", O_CREATE | O_WRONLY);
    17b8:	20100593          	li	a1,513
    17bc:	00005517          	auipc	a0,0x5
    17c0:	0a450513          	addi	a0,a0,164 # 6860 <malloc+0xa44>
    17c4:	00004097          	auipc	ra,0x4
    17c8:	24e080e7          	jalr	590(ra) # 5a12 <open>
    if (fd < 0)
    17cc:	04054163          	bltz	a0,180e <exectest+0xaa>
    if (fd != 1)
    17d0:	4785                	li	a5,1
    17d2:	04f50c63          	beq	a0,a5,182a <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    17d6:	85ca                	mv	a1,s2
    17d8:	00005517          	auipc	a0,0x5
    17dc:	0a850513          	addi	a0,a0,168 # 6880 <malloc+0xa64>
    17e0:	00004097          	auipc	ra,0x4
    17e4:	584080e7          	jalr	1412(ra) # 5d64 <printf>
      exit(1);
    17e8:	4505                	li	a0,1
    17ea:	00004097          	auipc	ra,0x4
    17ee:	1e8080e7          	jalr	488(ra) # 59d2 <exit>
    printf("%s: fork failed\n", s);
    17f2:	85ca                	mv	a1,s2
    17f4:	00005517          	auipc	a0,0x5
    17f8:	fdc50513          	addi	a0,a0,-36 # 67d0 <malloc+0x9b4>
    17fc:	00004097          	auipc	ra,0x4
    1800:	568080e7          	jalr	1384(ra) # 5d64 <printf>
    exit(1);
    1804:	4505                	li	a0,1
    1806:	00004097          	auipc	ra,0x4
    180a:	1cc080e7          	jalr	460(ra) # 59d2 <exit>
      printf("%s: create failed\n", s);
    180e:	85ca                	mv	a1,s2
    1810:	00005517          	auipc	a0,0x5
    1814:	05850513          	addi	a0,a0,88 # 6868 <malloc+0xa4c>
    1818:	00004097          	auipc	ra,0x4
    181c:	54c080e7          	jalr	1356(ra) # 5d64 <printf>
      exit(1);
    1820:	4505                	li	a0,1
    1822:	00004097          	auipc	ra,0x4
    1826:	1b0080e7          	jalr	432(ra) # 59d2 <exit>
    if (exec("echo", echoargv) < 0)
    182a:	fc040593          	addi	a1,s0,-64
    182e:	00004517          	auipc	a0,0x4
    1832:	71a50513          	addi	a0,a0,1818 # 5f48 <malloc+0x12c>
    1836:	00004097          	auipc	ra,0x4
    183a:	1d4080e7          	jalr	468(ra) # 5a0a <exec>
    183e:	02054163          	bltz	a0,1860 <exectest+0xfc>
  if (wait(&xstatus) != pid)
    1842:	fdc40513          	addi	a0,s0,-36
    1846:	00004097          	auipc	ra,0x4
    184a:	194080e7          	jalr	404(ra) # 59da <wait>
    184e:	02951763          	bne	a0,s1,187c <exectest+0x118>
  if (xstatus != 0)
    1852:	fdc42503          	lw	a0,-36(s0)
    1856:	cd0d                	beqz	a0,1890 <exectest+0x12c>
    exit(xstatus);
    1858:	00004097          	auipc	ra,0x4
    185c:	17a080e7          	jalr	378(ra) # 59d2 <exit>
      printf("%s: exec echo failed\n", s);
    1860:	85ca                	mv	a1,s2
    1862:	00005517          	auipc	a0,0x5
    1866:	02e50513          	addi	a0,a0,46 # 6890 <malloc+0xa74>
    186a:	00004097          	auipc	ra,0x4
    186e:	4fa080e7          	jalr	1274(ra) # 5d64 <printf>
      exit(1);
    1872:	4505                	li	a0,1
    1874:	00004097          	auipc	ra,0x4
    1878:	15e080e7          	jalr	350(ra) # 59d2 <exit>
    printf("%s: wait failed!\n", s);
    187c:	85ca                	mv	a1,s2
    187e:	00005517          	auipc	a0,0x5
    1882:	02a50513          	addi	a0,a0,42 # 68a8 <malloc+0xa8c>
    1886:	00004097          	auipc	ra,0x4
    188a:	4de080e7          	jalr	1246(ra) # 5d64 <printf>
    188e:	b7d1                	j	1852 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    1890:	4581                	li	a1,0
    1892:	00005517          	auipc	a0,0x5
    1896:	fce50513          	addi	a0,a0,-50 # 6860 <malloc+0xa44>
    189a:	00004097          	auipc	ra,0x4
    189e:	178080e7          	jalr	376(ra) # 5a12 <open>
  if (fd < 0)
    18a2:	02054a63          	bltz	a0,18d6 <exectest+0x172>
  if (read(fd, buf, 2) != 2)
    18a6:	4609                	li	a2,2
    18a8:	fb840593          	addi	a1,s0,-72
    18ac:	00004097          	auipc	ra,0x4
    18b0:	13e080e7          	jalr	318(ra) # 59ea <read>
    18b4:	4789                	li	a5,2
    18b6:	02f50e63          	beq	a0,a5,18f2 <exectest+0x18e>
    printf("%s: read failed\n", s);
    18ba:	85ca                	mv	a1,s2
    18bc:	00005517          	auipc	a0,0x5
    18c0:	a5c50513          	addi	a0,a0,-1444 # 6318 <malloc+0x4fc>
    18c4:	00004097          	auipc	ra,0x4
    18c8:	4a0080e7          	jalr	1184(ra) # 5d64 <printf>
    exit(1);
    18cc:	4505                	li	a0,1
    18ce:	00004097          	auipc	ra,0x4
    18d2:	104080e7          	jalr	260(ra) # 59d2 <exit>
    printf("%s: open failed\n", s);
    18d6:	85ca                	mv	a1,s2
    18d8:	00005517          	auipc	a0,0x5
    18dc:	f1050513          	addi	a0,a0,-240 # 67e8 <malloc+0x9cc>
    18e0:	00004097          	auipc	ra,0x4
    18e4:	484080e7          	jalr	1156(ra) # 5d64 <printf>
    exit(1);
    18e8:	4505                	li	a0,1
    18ea:	00004097          	auipc	ra,0x4
    18ee:	0e8080e7          	jalr	232(ra) # 59d2 <exit>
  unlink("echo-ok");
    18f2:	00005517          	auipc	a0,0x5
    18f6:	f6e50513          	addi	a0,a0,-146 # 6860 <malloc+0xa44>
    18fa:	00004097          	auipc	ra,0x4
    18fe:	128080e7          	jalr	296(ra) # 5a22 <unlink>
  if (buf[0] == 'O' && buf[1] == 'K')
    1902:	fb844703          	lbu	a4,-72(s0)
    1906:	04f00793          	li	a5,79
    190a:	00f71863          	bne	a4,a5,191a <exectest+0x1b6>
    190e:	fb944703          	lbu	a4,-71(s0)
    1912:	04b00793          	li	a5,75
    1916:	02f70063          	beq	a4,a5,1936 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    191a:	85ca                	mv	a1,s2
    191c:	00005517          	auipc	a0,0x5
    1920:	fa450513          	addi	a0,a0,-92 # 68c0 <malloc+0xaa4>
    1924:	00004097          	auipc	ra,0x4
    1928:	440080e7          	jalr	1088(ra) # 5d64 <printf>
    exit(1);
    192c:	4505                	li	a0,1
    192e:	00004097          	auipc	ra,0x4
    1932:	0a4080e7          	jalr	164(ra) # 59d2 <exit>
    exit(0);
    1936:	4501                	li	a0,0
    1938:	00004097          	auipc	ra,0x4
    193c:	09a080e7          	jalr	154(ra) # 59d2 <exit>

0000000000001940 <pipe1>:
{
    1940:	711d                	addi	sp,sp,-96
    1942:	ec86                	sd	ra,88(sp)
    1944:	e8a2                	sd	s0,80(sp)
    1946:	e4a6                	sd	s1,72(sp)
    1948:	e0ca                	sd	s2,64(sp)
    194a:	fc4e                	sd	s3,56(sp)
    194c:	f852                	sd	s4,48(sp)
    194e:	f456                	sd	s5,40(sp)
    1950:	f05a                	sd	s6,32(sp)
    1952:	ec5e                	sd	s7,24(sp)
    1954:	1080                	addi	s0,sp,96
    1956:	892a                	mv	s2,a0
  if (pipe(fds) != 0)
    1958:	fa840513          	addi	a0,s0,-88
    195c:	00004097          	auipc	ra,0x4
    1960:	086080e7          	jalr	134(ra) # 59e2 <pipe>
    1964:	e93d                	bnez	a0,19da <pipe1+0x9a>
    1966:	84aa                	mv	s1,a0
  pid = fork();
    1968:	00004097          	auipc	ra,0x4
    196c:	062080e7          	jalr	98(ra) # 59ca <fork>
    1970:	8a2a                	mv	s4,a0
  if (pid == 0)
    1972:	c151                	beqz	a0,19f6 <pipe1+0xb6>
  else if (pid > 0)
    1974:	16a05d63          	blez	a0,1aee <pipe1+0x1ae>
    close(fds[1]);
    1978:	fac42503          	lw	a0,-84(s0)
    197c:	00004097          	auipc	ra,0x4
    1980:	07e080e7          	jalr	126(ra) # 59fa <close>
    total = 0;
    1984:	8a26                	mv	s4,s1
    cc = 1;
    1986:	4985                	li	s3,1
    while ((n = read(fds[0], buf, cc)) > 0)
    1988:	0000ba97          	auipc	s5,0xb
    198c:	2f0a8a93          	addi	s5,s5,752 # cc78 <buf>
      if (cc > sizeof(buf))
    1990:	6b0d                	lui	s6,0x3
    while ((n = read(fds[0], buf, cc)) > 0)
    1992:	864e                	mv	a2,s3
    1994:	85d6                	mv	a1,s5
    1996:	fa842503          	lw	a0,-88(s0)
    199a:	00004097          	auipc	ra,0x4
    199e:	050080e7          	jalr	80(ra) # 59ea <read>
    19a2:	10a05163          	blez	a0,1aa4 <pipe1+0x164>
      for (i = 0; i < n; i++)
    19a6:	0000b717          	auipc	a4,0xb
    19aa:	2d270713          	addi	a4,a4,722 # cc78 <buf>
    19ae:	00a4863b          	addw	a2,s1,a0
        if ((buf[i] & 0xff) != (seq++ & 0xff))
    19b2:	00074683          	lbu	a3,0(a4)
    19b6:	0ff4f793          	zext.b	a5,s1
    19ba:	2485                	addiw	s1,s1,1
    19bc:	0cf69063          	bne	a3,a5,1a7c <pipe1+0x13c>
      for (i = 0; i < n; i++)
    19c0:	0705                	addi	a4,a4,1
    19c2:	fec498e3          	bne	s1,a2,19b2 <pipe1+0x72>
      total += n;
    19c6:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    19ca:	0019979b          	slliw	a5,s3,0x1
    19ce:	0007899b          	sext.w	s3,a5
      if (cc > sizeof(buf))
    19d2:	fd3b70e3          	bgeu	s6,s3,1992 <pipe1+0x52>
        cc = sizeof(buf);
    19d6:	89da                	mv	s3,s6
    19d8:	bf6d                	j	1992 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    19da:	85ca                	mv	a1,s2
    19dc:	00005517          	auipc	a0,0x5
    19e0:	efc50513          	addi	a0,a0,-260 # 68d8 <malloc+0xabc>
    19e4:	00004097          	auipc	ra,0x4
    19e8:	380080e7          	jalr	896(ra) # 5d64 <printf>
    exit(1);
    19ec:	4505                	li	a0,1
    19ee:	00004097          	auipc	ra,0x4
    19f2:	fe4080e7          	jalr	-28(ra) # 59d2 <exit>
    close(fds[0]);
    19f6:	fa842503          	lw	a0,-88(s0)
    19fa:	00004097          	auipc	ra,0x4
    19fe:	000080e7          	jalr	ra # 59fa <close>
    for (n = 0; n < N; n++)
    1a02:	0000bb17          	auipc	s6,0xb
    1a06:	276b0b13          	addi	s6,s6,630 # cc78 <buf>
    1a0a:	416004bb          	negw	s1,s6
    1a0e:	0ff4f493          	zext.b	s1,s1
    1a12:	409b0993          	addi	s3,s6,1033
      if (write(fds[1], buf, SZ) != SZ)
    1a16:	8bda                	mv	s7,s6
    for (n = 0; n < N; n++)
    1a18:	6a85                	lui	s5,0x1
    1a1a:	42da8a93          	addi	s5,s5,1069 # 142d <copyinstr2+0x79>
{
    1a1e:	87da                	mv	a5,s6
        buf[i] = seq++;
    1a20:	0097873b          	addw	a4,a5,s1
    1a24:	00e78023          	sb	a4,0(a5)
      for (i = 0; i < SZ; i++)
    1a28:	0785                	addi	a5,a5,1
    1a2a:	fef99be3          	bne	s3,a5,1a20 <pipe1+0xe0>
        buf[i] = seq++;
    1a2e:	409a0a1b          	addiw	s4,s4,1033
      if (write(fds[1], buf, SZ) != SZ)
    1a32:	40900613          	li	a2,1033
    1a36:	85de                	mv	a1,s7
    1a38:	fac42503          	lw	a0,-84(s0)
    1a3c:	00004097          	auipc	ra,0x4
    1a40:	fb6080e7          	jalr	-74(ra) # 59f2 <write>
    1a44:	40900793          	li	a5,1033
    1a48:	00f51c63          	bne	a0,a5,1a60 <pipe1+0x120>
    for (n = 0; n < N; n++)
    1a4c:	24a5                	addiw	s1,s1,9
    1a4e:	0ff4f493          	zext.b	s1,s1
    1a52:	fd5a16e3          	bne	s4,s5,1a1e <pipe1+0xde>
    exit(0);
    1a56:	4501                	li	a0,0
    1a58:	00004097          	auipc	ra,0x4
    1a5c:	f7a080e7          	jalr	-134(ra) # 59d2 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1a60:	85ca                	mv	a1,s2
    1a62:	00005517          	auipc	a0,0x5
    1a66:	e8e50513          	addi	a0,a0,-370 # 68f0 <malloc+0xad4>
    1a6a:	00004097          	auipc	ra,0x4
    1a6e:	2fa080e7          	jalr	762(ra) # 5d64 <printf>
        exit(1);
    1a72:	4505                	li	a0,1
    1a74:	00004097          	auipc	ra,0x4
    1a78:	f5e080e7          	jalr	-162(ra) # 59d2 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1a7c:	85ca                	mv	a1,s2
    1a7e:	00005517          	auipc	a0,0x5
    1a82:	e8a50513          	addi	a0,a0,-374 # 6908 <malloc+0xaec>
    1a86:	00004097          	auipc	ra,0x4
    1a8a:	2de080e7          	jalr	734(ra) # 5d64 <printf>
}
    1a8e:	60e6                	ld	ra,88(sp)
    1a90:	6446                	ld	s0,80(sp)
    1a92:	64a6                	ld	s1,72(sp)
    1a94:	6906                	ld	s2,64(sp)
    1a96:	79e2                	ld	s3,56(sp)
    1a98:	7a42                	ld	s4,48(sp)
    1a9a:	7aa2                	ld	s5,40(sp)
    1a9c:	7b02                	ld	s6,32(sp)
    1a9e:	6be2                	ld	s7,24(sp)
    1aa0:	6125                	addi	sp,sp,96
    1aa2:	8082                	ret
    if (total != N * SZ)
    1aa4:	6785                	lui	a5,0x1
    1aa6:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x79>
    1aaa:	02fa0063          	beq	s4,a5,1aca <pipe1+0x18a>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1aae:	85d2                	mv	a1,s4
    1ab0:	00005517          	auipc	a0,0x5
    1ab4:	e7050513          	addi	a0,a0,-400 # 6920 <malloc+0xb04>
    1ab8:	00004097          	auipc	ra,0x4
    1abc:	2ac080e7          	jalr	684(ra) # 5d64 <printf>
      exit(1);
    1ac0:	4505                	li	a0,1
    1ac2:	00004097          	auipc	ra,0x4
    1ac6:	f10080e7          	jalr	-240(ra) # 59d2 <exit>
    close(fds[0]);
    1aca:	fa842503          	lw	a0,-88(s0)
    1ace:	00004097          	auipc	ra,0x4
    1ad2:	f2c080e7          	jalr	-212(ra) # 59fa <close>
    wait(&xstatus);
    1ad6:	fa440513          	addi	a0,s0,-92
    1ada:	00004097          	auipc	ra,0x4
    1ade:	f00080e7          	jalr	-256(ra) # 59da <wait>
    exit(xstatus);
    1ae2:	fa442503          	lw	a0,-92(s0)
    1ae6:	00004097          	auipc	ra,0x4
    1aea:	eec080e7          	jalr	-276(ra) # 59d2 <exit>
    printf("%s: fork() failed\n", s);
    1aee:	85ca                	mv	a1,s2
    1af0:	00005517          	auipc	a0,0x5
    1af4:	e5050513          	addi	a0,a0,-432 # 6940 <malloc+0xb24>
    1af8:	00004097          	auipc	ra,0x4
    1afc:	26c080e7          	jalr	620(ra) # 5d64 <printf>
    exit(1);
    1b00:	4505                	li	a0,1
    1b02:	00004097          	auipc	ra,0x4
    1b06:	ed0080e7          	jalr	-304(ra) # 59d2 <exit>

0000000000001b0a <exitwait>:
{
    1b0a:	7139                	addi	sp,sp,-64
    1b0c:	fc06                	sd	ra,56(sp)
    1b0e:	f822                	sd	s0,48(sp)
    1b10:	f426                	sd	s1,40(sp)
    1b12:	f04a                	sd	s2,32(sp)
    1b14:	ec4e                	sd	s3,24(sp)
    1b16:	e852                	sd	s4,16(sp)
    1b18:	0080                	addi	s0,sp,64
    1b1a:	8a2a                	mv	s4,a0
  for (i = 0; i < 100; i++)
    1b1c:	4901                	li	s2,0
    1b1e:	06400993          	li	s3,100
    pid = fork();
    1b22:	00004097          	auipc	ra,0x4
    1b26:	ea8080e7          	jalr	-344(ra) # 59ca <fork>
    1b2a:	84aa                	mv	s1,a0
    if (pid < 0)
    1b2c:	02054a63          	bltz	a0,1b60 <exitwait+0x56>
    if (pid)
    1b30:	c151                	beqz	a0,1bb4 <exitwait+0xaa>
      if (wait(&xstate) != pid)
    1b32:	fcc40513          	addi	a0,s0,-52
    1b36:	00004097          	auipc	ra,0x4
    1b3a:	ea4080e7          	jalr	-348(ra) # 59da <wait>
    1b3e:	02951f63          	bne	a0,s1,1b7c <exitwait+0x72>
      if (i != xstate)
    1b42:	fcc42783          	lw	a5,-52(s0)
    1b46:	05279963          	bne	a5,s2,1b98 <exitwait+0x8e>
  for (i = 0; i < 100; i++)
    1b4a:	2905                	addiw	s2,s2,1
    1b4c:	fd391be3          	bne	s2,s3,1b22 <exitwait+0x18>
}
    1b50:	70e2                	ld	ra,56(sp)
    1b52:	7442                	ld	s0,48(sp)
    1b54:	74a2                	ld	s1,40(sp)
    1b56:	7902                	ld	s2,32(sp)
    1b58:	69e2                	ld	s3,24(sp)
    1b5a:	6a42                	ld	s4,16(sp)
    1b5c:	6121                	addi	sp,sp,64
    1b5e:	8082                	ret
      printf("%s: fork failed\n", s);
    1b60:	85d2                	mv	a1,s4
    1b62:	00005517          	auipc	a0,0x5
    1b66:	c6e50513          	addi	a0,a0,-914 # 67d0 <malloc+0x9b4>
    1b6a:	00004097          	auipc	ra,0x4
    1b6e:	1fa080e7          	jalr	506(ra) # 5d64 <printf>
      exit(1);
    1b72:	4505                	li	a0,1
    1b74:	00004097          	auipc	ra,0x4
    1b78:	e5e080e7          	jalr	-418(ra) # 59d2 <exit>
        printf("%s: wait wrong pid\n", s);
    1b7c:	85d2                	mv	a1,s4
    1b7e:	00005517          	auipc	a0,0x5
    1b82:	dda50513          	addi	a0,a0,-550 # 6958 <malloc+0xb3c>
    1b86:	00004097          	auipc	ra,0x4
    1b8a:	1de080e7          	jalr	478(ra) # 5d64 <printf>
        exit(1);
    1b8e:	4505                	li	a0,1
    1b90:	00004097          	auipc	ra,0x4
    1b94:	e42080e7          	jalr	-446(ra) # 59d2 <exit>
        printf("%s: wait wrong exit status\n", s);
    1b98:	85d2                	mv	a1,s4
    1b9a:	00005517          	auipc	a0,0x5
    1b9e:	dd650513          	addi	a0,a0,-554 # 6970 <malloc+0xb54>
    1ba2:	00004097          	auipc	ra,0x4
    1ba6:	1c2080e7          	jalr	450(ra) # 5d64 <printf>
        exit(1);
    1baa:	4505                	li	a0,1
    1bac:	00004097          	auipc	ra,0x4
    1bb0:	e26080e7          	jalr	-474(ra) # 59d2 <exit>
      exit(i);
    1bb4:	854a                	mv	a0,s2
    1bb6:	00004097          	auipc	ra,0x4
    1bba:	e1c080e7          	jalr	-484(ra) # 59d2 <exit>

0000000000001bbe <twochildren>:
{
    1bbe:	1101                	addi	sp,sp,-32
    1bc0:	ec06                	sd	ra,24(sp)
    1bc2:	e822                	sd	s0,16(sp)
    1bc4:	e426                	sd	s1,8(sp)
    1bc6:	e04a                	sd	s2,0(sp)
    1bc8:	1000                	addi	s0,sp,32
    1bca:	892a                	mv	s2,a0
    1bcc:	3e800493          	li	s1,1000
    int pid1 = fork();
    1bd0:	00004097          	auipc	ra,0x4
    1bd4:	dfa080e7          	jalr	-518(ra) # 59ca <fork>
    if (pid1 < 0)
    1bd8:	02054c63          	bltz	a0,1c10 <twochildren+0x52>
    if (pid1 == 0)
    1bdc:	c921                	beqz	a0,1c2c <twochildren+0x6e>
      int pid2 = fork();
    1bde:	00004097          	auipc	ra,0x4
    1be2:	dec080e7          	jalr	-532(ra) # 59ca <fork>
      if (pid2 < 0)
    1be6:	04054763          	bltz	a0,1c34 <twochildren+0x76>
      if (pid2 == 0)
    1bea:	c13d                	beqz	a0,1c50 <twochildren+0x92>
        wait(0);
    1bec:	4501                	li	a0,0
    1bee:	00004097          	auipc	ra,0x4
    1bf2:	dec080e7          	jalr	-532(ra) # 59da <wait>
        wait(0);
    1bf6:	4501                	li	a0,0
    1bf8:	00004097          	auipc	ra,0x4
    1bfc:	de2080e7          	jalr	-542(ra) # 59da <wait>
  for (int i = 0; i < 1000; i++)
    1c00:	34fd                	addiw	s1,s1,-1
    1c02:	f4f9                	bnez	s1,1bd0 <twochildren+0x12>
}
    1c04:	60e2                	ld	ra,24(sp)
    1c06:	6442                	ld	s0,16(sp)
    1c08:	64a2                	ld	s1,8(sp)
    1c0a:	6902                	ld	s2,0(sp)
    1c0c:	6105                	addi	sp,sp,32
    1c0e:	8082                	ret
      printf("%s: fork failed\n", s);
    1c10:	85ca                	mv	a1,s2
    1c12:	00005517          	auipc	a0,0x5
    1c16:	bbe50513          	addi	a0,a0,-1090 # 67d0 <malloc+0x9b4>
    1c1a:	00004097          	auipc	ra,0x4
    1c1e:	14a080e7          	jalr	330(ra) # 5d64 <printf>
      exit(1);
    1c22:	4505                	li	a0,1
    1c24:	00004097          	auipc	ra,0x4
    1c28:	dae080e7          	jalr	-594(ra) # 59d2 <exit>
      exit(0);
    1c2c:	00004097          	auipc	ra,0x4
    1c30:	da6080e7          	jalr	-602(ra) # 59d2 <exit>
        printf("%s: fork failed\n", s);
    1c34:	85ca                	mv	a1,s2
    1c36:	00005517          	auipc	a0,0x5
    1c3a:	b9a50513          	addi	a0,a0,-1126 # 67d0 <malloc+0x9b4>
    1c3e:	00004097          	auipc	ra,0x4
    1c42:	126080e7          	jalr	294(ra) # 5d64 <printf>
        exit(1);
    1c46:	4505                	li	a0,1
    1c48:	00004097          	auipc	ra,0x4
    1c4c:	d8a080e7          	jalr	-630(ra) # 59d2 <exit>
        exit(0);
    1c50:	00004097          	auipc	ra,0x4
    1c54:	d82080e7          	jalr	-638(ra) # 59d2 <exit>

0000000000001c58 <forkfork>:
{
    1c58:	7179                	addi	sp,sp,-48
    1c5a:	f406                	sd	ra,40(sp)
    1c5c:	f022                	sd	s0,32(sp)
    1c5e:	ec26                	sd	s1,24(sp)
    1c60:	1800                	addi	s0,sp,48
    1c62:	84aa                	mv	s1,a0
    int pid = fork();
    1c64:	00004097          	auipc	ra,0x4
    1c68:	d66080e7          	jalr	-666(ra) # 59ca <fork>
    if (pid < 0)
    1c6c:	04054163          	bltz	a0,1cae <forkfork+0x56>
    if (pid == 0)
    1c70:	cd29                	beqz	a0,1cca <forkfork+0x72>
    int pid = fork();
    1c72:	00004097          	auipc	ra,0x4
    1c76:	d58080e7          	jalr	-680(ra) # 59ca <fork>
    if (pid < 0)
    1c7a:	02054a63          	bltz	a0,1cae <forkfork+0x56>
    if (pid == 0)
    1c7e:	c531                	beqz	a0,1cca <forkfork+0x72>
    wait(&xstatus);
    1c80:	fdc40513          	addi	a0,s0,-36
    1c84:	00004097          	auipc	ra,0x4
    1c88:	d56080e7          	jalr	-682(ra) # 59da <wait>
    if (xstatus != 0)
    1c8c:	fdc42783          	lw	a5,-36(s0)
    1c90:	ebbd                	bnez	a5,1d06 <forkfork+0xae>
    wait(&xstatus);
    1c92:	fdc40513          	addi	a0,s0,-36
    1c96:	00004097          	auipc	ra,0x4
    1c9a:	d44080e7          	jalr	-700(ra) # 59da <wait>
    if (xstatus != 0)
    1c9e:	fdc42783          	lw	a5,-36(s0)
    1ca2:	e3b5                	bnez	a5,1d06 <forkfork+0xae>
}
    1ca4:	70a2                	ld	ra,40(sp)
    1ca6:	7402                	ld	s0,32(sp)
    1ca8:	64e2                	ld	s1,24(sp)
    1caa:	6145                	addi	sp,sp,48
    1cac:	8082                	ret
      printf("%s: fork failed", s);
    1cae:	85a6                	mv	a1,s1
    1cb0:	00005517          	auipc	a0,0x5
    1cb4:	ce050513          	addi	a0,a0,-800 # 6990 <malloc+0xb74>
    1cb8:	00004097          	auipc	ra,0x4
    1cbc:	0ac080e7          	jalr	172(ra) # 5d64 <printf>
      exit(1);
    1cc0:	4505                	li	a0,1
    1cc2:	00004097          	auipc	ra,0x4
    1cc6:	d10080e7          	jalr	-752(ra) # 59d2 <exit>
{
    1cca:	0c800493          	li	s1,200
        int pid1 = fork();
    1cce:	00004097          	auipc	ra,0x4
    1cd2:	cfc080e7          	jalr	-772(ra) # 59ca <fork>
        if (pid1 < 0)
    1cd6:	00054f63          	bltz	a0,1cf4 <forkfork+0x9c>
        if (pid1 == 0)
    1cda:	c115                	beqz	a0,1cfe <forkfork+0xa6>
        wait(0);
    1cdc:	4501                	li	a0,0
    1cde:	00004097          	auipc	ra,0x4
    1ce2:	cfc080e7          	jalr	-772(ra) # 59da <wait>
      for (int j = 0; j < 200; j++)
    1ce6:	34fd                	addiw	s1,s1,-1
    1ce8:	f0fd                	bnez	s1,1cce <forkfork+0x76>
      exit(0);
    1cea:	4501                	li	a0,0
    1cec:	00004097          	auipc	ra,0x4
    1cf0:	ce6080e7          	jalr	-794(ra) # 59d2 <exit>
          exit(1);
    1cf4:	4505                	li	a0,1
    1cf6:	00004097          	auipc	ra,0x4
    1cfa:	cdc080e7          	jalr	-804(ra) # 59d2 <exit>
          exit(0);
    1cfe:	00004097          	auipc	ra,0x4
    1d02:	cd4080e7          	jalr	-812(ra) # 59d2 <exit>
      printf("%s: fork in child failed", s);
    1d06:	85a6                	mv	a1,s1
    1d08:	00005517          	auipc	a0,0x5
    1d0c:	c9850513          	addi	a0,a0,-872 # 69a0 <malloc+0xb84>
    1d10:	00004097          	auipc	ra,0x4
    1d14:	054080e7          	jalr	84(ra) # 5d64 <printf>
      exit(1);
    1d18:	4505                	li	a0,1
    1d1a:	00004097          	auipc	ra,0x4
    1d1e:	cb8080e7          	jalr	-840(ra) # 59d2 <exit>

0000000000001d22 <reparent2>:
{
    1d22:	1101                	addi	sp,sp,-32
    1d24:	ec06                	sd	ra,24(sp)
    1d26:	e822                	sd	s0,16(sp)
    1d28:	e426                	sd	s1,8(sp)
    1d2a:	1000                	addi	s0,sp,32
    1d2c:	32000493          	li	s1,800
    int pid1 = fork();
    1d30:	00004097          	auipc	ra,0x4
    1d34:	c9a080e7          	jalr	-870(ra) # 59ca <fork>
    if (pid1 < 0)
    1d38:	00054f63          	bltz	a0,1d56 <reparent2+0x34>
    if (pid1 == 0)
    1d3c:	c915                	beqz	a0,1d70 <reparent2+0x4e>
    wait(0);
    1d3e:	4501                	li	a0,0
    1d40:	00004097          	auipc	ra,0x4
    1d44:	c9a080e7          	jalr	-870(ra) # 59da <wait>
  for (int i = 0; i < 800; i++)
    1d48:	34fd                	addiw	s1,s1,-1
    1d4a:	f0fd                	bnez	s1,1d30 <reparent2+0xe>
  exit(0);
    1d4c:	4501                	li	a0,0
    1d4e:	00004097          	auipc	ra,0x4
    1d52:	c84080e7          	jalr	-892(ra) # 59d2 <exit>
      printf("fork failed\n");
    1d56:	00005517          	auipc	a0,0x5
    1d5a:	e8250513          	addi	a0,a0,-382 # 6bd8 <malloc+0xdbc>
    1d5e:	00004097          	auipc	ra,0x4
    1d62:	006080e7          	jalr	6(ra) # 5d64 <printf>
      exit(1);
    1d66:	4505                	li	a0,1
    1d68:	00004097          	auipc	ra,0x4
    1d6c:	c6a080e7          	jalr	-918(ra) # 59d2 <exit>
      fork();
    1d70:	00004097          	auipc	ra,0x4
    1d74:	c5a080e7          	jalr	-934(ra) # 59ca <fork>
      fork();
    1d78:	00004097          	auipc	ra,0x4
    1d7c:	c52080e7          	jalr	-942(ra) # 59ca <fork>
      exit(0);
    1d80:	4501                	li	a0,0
    1d82:	00004097          	auipc	ra,0x4
    1d86:	c50080e7          	jalr	-944(ra) # 59d2 <exit>

0000000000001d8a <createdelete>:
{
    1d8a:	7175                	addi	sp,sp,-144
    1d8c:	e506                	sd	ra,136(sp)
    1d8e:	e122                	sd	s0,128(sp)
    1d90:	fca6                	sd	s1,120(sp)
    1d92:	f8ca                	sd	s2,112(sp)
    1d94:	f4ce                	sd	s3,104(sp)
    1d96:	f0d2                	sd	s4,96(sp)
    1d98:	ecd6                	sd	s5,88(sp)
    1d9a:	e8da                	sd	s6,80(sp)
    1d9c:	e4de                	sd	s7,72(sp)
    1d9e:	e0e2                	sd	s8,64(sp)
    1da0:	fc66                	sd	s9,56(sp)
    1da2:	0900                	addi	s0,sp,144
    1da4:	8caa                	mv	s9,a0
  for (pi = 0; pi < NCHILD; pi++)
    1da6:	4901                	li	s2,0
    1da8:	4991                	li	s3,4
    pid = fork();
    1daa:	00004097          	auipc	ra,0x4
    1dae:	c20080e7          	jalr	-992(ra) # 59ca <fork>
    1db2:	84aa                	mv	s1,a0
    if (pid < 0)
    1db4:	02054f63          	bltz	a0,1df2 <createdelete+0x68>
    if (pid == 0)
    1db8:	c939                	beqz	a0,1e0e <createdelete+0x84>
  for (pi = 0; pi < NCHILD; pi++)
    1dba:	2905                	addiw	s2,s2,1
    1dbc:	ff3917e3          	bne	s2,s3,1daa <createdelete+0x20>
    1dc0:	4491                	li	s1,4
    wait(&xstatus);
    1dc2:	f7c40513          	addi	a0,s0,-132
    1dc6:	00004097          	auipc	ra,0x4
    1dca:	c14080e7          	jalr	-1004(ra) # 59da <wait>
    if (xstatus != 0)
    1dce:	f7c42903          	lw	s2,-132(s0)
    1dd2:	0e091263          	bnez	s2,1eb6 <createdelete+0x12c>
  for (pi = 0; pi < NCHILD; pi++)
    1dd6:	34fd                	addiw	s1,s1,-1
    1dd8:	f4ed                	bnez	s1,1dc2 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1dda:	f8040123          	sb	zero,-126(s0)
    1dde:	03000993          	li	s3,48
    1de2:	5a7d                	li	s4,-1
    1de4:	07000c13          	li	s8,112
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1de8:	4b21                	li	s6,8
      if ((i == 0 || i >= N / 2) && fd < 0)
    1dea:	4ba5                	li	s7,9
    for (pi = 0; pi < NCHILD; pi++)
    1dec:	07400a93          	li	s5,116
    1df0:	a29d                	j	1f56 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1df2:	85e6                	mv	a1,s9
    1df4:	00005517          	auipc	a0,0x5
    1df8:	de450513          	addi	a0,a0,-540 # 6bd8 <malloc+0xdbc>
    1dfc:	00004097          	auipc	ra,0x4
    1e00:	f68080e7          	jalr	-152(ra) # 5d64 <printf>
      exit(1);
    1e04:	4505                	li	a0,1
    1e06:	00004097          	auipc	ra,0x4
    1e0a:	bcc080e7          	jalr	-1076(ra) # 59d2 <exit>
      name[0] = 'p' + pi;
    1e0e:	0709091b          	addiw	s2,s2,112
    1e12:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1e16:	f8040123          	sb	zero,-126(s0)
      for (i = 0; i < N; i++)
    1e1a:	4951                	li	s2,20
    1e1c:	a015                	j	1e40 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1e1e:	85e6                	mv	a1,s9
    1e20:	00005517          	auipc	a0,0x5
    1e24:	a4850513          	addi	a0,a0,-1464 # 6868 <malloc+0xa4c>
    1e28:	00004097          	auipc	ra,0x4
    1e2c:	f3c080e7          	jalr	-196(ra) # 5d64 <printf>
          exit(1);
    1e30:	4505                	li	a0,1
    1e32:	00004097          	auipc	ra,0x4
    1e36:	ba0080e7          	jalr	-1120(ra) # 59d2 <exit>
      for (i = 0; i < N; i++)
    1e3a:	2485                	addiw	s1,s1,1
    1e3c:	07248863          	beq	s1,s2,1eac <createdelete+0x122>
        name[1] = '0' + i;
    1e40:	0304879b          	addiw	a5,s1,48
    1e44:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1e48:	20200593          	li	a1,514
    1e4c:	f8040513          	addi	a0,s0,-128
    1e50:	00004097          	auipc	ra,0x4
    1e54:	bc2080e7          	jalr	-1086(ra) # 5a12 <open>
        if (fd < 0)
    1e58:	fc0543e3          	bltz	a0,1e1e <createdelete+0x94>
        close(fd);
    1e5c:	00004097          	auipc	ra,0x4
    1e60:	b9e080e7          	jalr	-1122(ra) # 59fa <close>
        if (i > 0 && (i % 2) == 0)
    1e64:	fc905be3          	blez	s1,1e3a <createdelete+0xb0>
    1e68:	0014f793          	andi	a5,s1,1
    1e6c:	f7f9                	bnez	a5,1e3a <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1e6e:	01f4d79b          	srliw	a5,s1,0x1f
    1e72:	9fa5                	addw	a5,a5,s1
    1e74:	4017d79b          	sraiw	a5,a5,0x1
    1e78:	0307879b          	addiw	a5,a5,48
    1e7c:	f8f400a3          	sb	a5,-127(s0)
          if (unlink(name) < 0)
    1e80:	f8040513          	addi	a0,s0,-128
    1e84:	00004097          	auipc	ra,0x4
    1e88:	b9e080e7          	jalr	-1122(ra) # 5a22 <unlink>
    1e8c:	fa0557e3          	bgez	a0,1e3a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1e90:	85e6                	mv	a1,s9
    1e92:	00005517          	auipc	a0,0x5
    1e96:	b2e50513          	addi	a0,a0,-1234 # 69c0 <malloc+0xba4>
    1e9a:	00004097          	auipc	ra,0x4
    1e9e:	eca080e7          	jalr	-310(ra) # 5d64 <printf>
            exit(1);
    1ea2:	4505                	li	a0,1
    1ea4:	00004097          	auipc	ra,0x4
    1ea8:	b2e080e7          	jalr	-1234(ra) # 59d2 <exit>
      exit(0);
    1eac:	4501                	li	a0,0
    1eae:	00004097          	auipc	ra,0x4
    1eb2:	b24080e7          	jalr	-1244(ra) # 59d2 <exit>
      exit(1);
    1eb6:	4505                	li	a0,1
    1eb8:	00004097          	auipc	ra,0x4
    1ebc:	b1a080e7          	jalr	-1254(ra) # 59d2 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1ec0:	f8040613          	addi	a2,s0,-128
    1ec4:	85e6                	mv	a1,s9
    1ec6:	00005517          	auipc	a0,0x5
    1eca:	b1250513          	addi	a0,a0,-1262 # 69d8 <malloc+0xbbc>
    1ece:	00004097          	auipc	ra,0x4
    1ed2:	e96080e7          	jalr	-362(ra) # 5d64 <printf>
        exit(1);
    1ed6:	4505                	li	a0,1
    1ed8:	00004097          	auipc	ra,0x4
    1edc:	afa080e7          	jalr	-1286(ra) # 59d2 <exit>
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1ee0:	054b7163          	bgeu	s6,s4,1f22 <createdelete+0x198>
      if (fd >= 0)
    1ee4:	02055a63          	bgez	a0,1f18 <createdelete+0x18e>
    for (pi = 0; pi < NCHILD; pi++)
    1ee8:	2485                	addiw	s1,s1,1
    1eea:	0ff4f493          	zext.b	s1,s1
    1eee:	05548c63          	beq	s1,s5,1f46 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1ef2:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1ef6:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1efa:	4581                	li	a1,0
    1efc:	f8040513          	addi	a0,s0,-128
    1f00:	00004097          	auipc	ra,0x4
    1f04:	b12080e7          	jalr	-1262(ra) # 5a12 <open>
      if ((i == 0 || i >= N / 2) && fd < 0)
    1f08:	00090463          	beqz	s2,1f10 <createdelete+0x186>
    1f0c:	fd2bdae3          	bge	s7,s2,1ee0 <createdelete+0x156>
    1f10:	fa0548e3          	bltz	a0,1ec0 <createdelete+0x136>
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1f14:	014b7963          	bgeu	s6,s4,1f26 <createdelete+0x19c>
        close(fd);
    1f18:	00004097          	auipc	ra,0x4
    1f1c:	ae2080e7          	jalr	-1310(ra) # 59fa <close>
    1f20:	b7e1                	j	1ee8 <createdelete+0x15e>
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1f22:	fc0543e3          	bltz	a0,1ee8 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1f26:	f8040613          	addi	a2,s0,-128
    1f2a:	85e6                	mv	a1,s9
    1f2c:	00005517          	auipc	a0,0x5
    1f30:	ad450513          	addi	a0,a0,-1324 # 6a00 <malloc+0xbe4>
    1f34:	00004097          	auipc	ra,0x4
    1f38:	e30080e7          	jalr	-464(ra) # 5d64 <printf>
        exit(1);
    1f3c:	4505                	li	a0,1
    1f3e:	00004097          	auipc	ra,0x4
    1f42:	a94080e7          	jalr	-1388(ra) # 59d2 <exit>
  for (i = 0; i < N; i++)
    1f46:	2905                	addiw	s2,s2,1
    1f48:	2a05                	addiw	s4,s4,1
    1f4a:	2985                	addiw	s3,s3,1
    1f4c:	0ff9f993          	zext.b	s3,s3
    1f50:	47d1                	li	a5,20
    1f52:	02f90a63          	beq	s2,a5,1f86 <createdelete+0x1fc>
    for (pi = 0; pi < NCHILD; pi++)
    1f56:	84e2                	mv	s1,s8
    1f58:	bf69                	j	1ef2 <createdelete+0x168>
  for (i = 0; i < N; i++)
    1f5a:	2905                	addiw	s2,s2,1
    1f5c:	0ff97913          	zext.b	s2,s2
    1f60:	2985                	addiw	s3,s3,1
    1f62:	0ff9f993          	zext.b	s3,s3
    1f66:	03490863          	beq	s2,s4,1f96 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1f6a:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1f6c:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1f70:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1f74:	f8040513          	addi	a0,s0,-128
    1f78:	00004097          	auipc	ra,0x4
    1f7c:	aaa080e7          	jalr	-1366(ra) # 5a22 <unlink>
    for (pi = 0; pi < NCHILD; pi++)
    1f80:	34fd                	addiw	s1,s1,-1
    1f82:	f4ed                	bnez	s1,1f6c <createdelete+0x1e2>
    1f84:	bfd9                	j	1f5a <createdelete+0x1d0>
    1f86:	03000993          	li	s3,48
    1f8a:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1f8e:	4a91                	li	s5,4
  for (i = 0; i < N; i++)
    1f90:	08400a13          	li	s4,132
    1f94:	bfd9                	j	1f6a <createdelete+0x1e0>
}
    1f96:	60aa                	ld	ra,136(sp)
    1f98:	640a                	ld	s0,128(sp)
    1f9a:	74e6                	ld	s1,120(sp)
    1f9c:	7946                	ld	s2,112(sp)
    1f9e:	79a6                	ld	s3,104(sp)
    1fa0:	7a06                	ld	s4,96(sp)
    1fa2:	6ae6                	ld	s5,88(sp)
    1fa4:	6b46                	ld	s6,80(sp)
    1fa6:	6ba6                	ld	s7,72(sp)
    1fa8:	6c06                	ld	s8,64(sp)
    1faa:	7ce2                	ld	s9,56(sp)
    1fac:	6149                	addi	sp,sp,144
    1fae:	8082                	ret

0000000000001fb0 <linkunlink>:
{
    1fb0:	711d                	addi	sp,sp,-96
    1fb2:	ec86                	sd	ra,88(sp)
    1fb4:	e8a2                	sd	s0,80(sp)
    1fb6:	e4a6                	sd	s1,72(sp)
    1fb8:	e0ca                	sd	s2,64(sp)
    1fba:	fc4e                	sd	s3,56(sp)
    1fbc:	f852                	sd	s4,48(sp)
    1fbe:	f456                	sd	s5,40(sp)
    1fc0:	f05a                	sd	s6,32(sp)
    1fc2:	ec5e                	sd	s7,24(sp)
    1fc4:	e862                	sd	s8,16(sp)
    1fc6:	e466                	sd	s9,8(sp)
    1fc8:	1080                	addi	s0,sp,96
    1fca:	84aa                	mv	s1,a0
  unlink("x");
    1fcc:	00004517          	auipc	a0,0x4
    1fd0:	fec50513          	addi	a0,a0,-20 # 5fb8 <malloc+0x19c>
    1fd4:	00004097          	auipc	ra,0x4
    1fd8:	a4e080e7          	jalr	-1458(ra) # 5a22 <unlink>
  pid = fork();
    1fdc:	00004097          	auipc	ra,0x4
    1fe0:	9ee080e7          	jalr	-1554(ra) # 59ca <fork>
  if (pid < 0)
    1fe4:	02054b63          	bltz	a0,201a <linkunlink+0x6a>
    1fe8:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1fea:	4c85                	li	s9,1
    1fec:	e119                	bnez	a0,1ff2 <linkunlink+0x42>
    1fee:	06100c93          	li	s9,97
    1ff2:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1ff6:	41c659b7          	lui	s3,0x41c65
    1ffa:	e6d9899b          	addiw	s3,s3,-403 # 41c64e6d <base+0x41c551f5>
    1ffe:	690d                	lui	s2,0x3
    2000:	0399091b          	addiw	s2,s2,57 # 3039 <fourteen+0x65>
    if ((x % 3) == 0)
    2004:	4a0d                	li	s4,3
    else if ((x % 3) == 1)
    2006:	4b05                	li	s6,1
      unlink("x");
    2008:	00004a97          	auipc	s5,0x4
    200c:	fb0a8a93          	addi	s5,s5,-80 # 5fb8 <malloc+0x19c>
      link("cat", "x");
    2010:	00005b97          	auipc	s7,0x5
    2014:	a18b8b93          	addi	s7,s7,-1512 # 6a28 <malloc+0xc0c>
    2018:	a825                	j	2050 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    201a:	85a6                	mv	a1,s1
    201c:	00004517          	auipc	a0,0x4
    2020:	7b450513          	addi	a0,a0,1972 # 67d0 <malloc+0x9b4>
    2024:	00004097          	auipc	ra,0x4
    2028:	d40080e7          	jalr	-704(ra) # 5d64 <printf>
    exit(1);
    202c:	4505                	li	a0,1
    202e:	00004097          	auipc	ra,0x4
    2032:	9a4080e7          	jalr	-1628(ra) # 59d2 <exit>
      close(open("x", O_RDWR | O_CREATE));
    2036:	20200593          	li	a1,514
    203a:	8556                	mv	a0,s5
    203c:	00004097          	auipc	ra,0x4
    2040:	9d6080e7          	jalr	-1578(ra) # 5a12 <open>
    2044:	00004097          	auipc	ra,0x4
    2048:	9b6080e7          	jalr	-1610(ra) # 59fa <close>
  for (i = 0; i < 100; i++)
    204c:	34fd                	addiw	s1,s1,-1
    204e:	c88d                	beqz	s1,2080 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    2050:	033c87bb          	mulw	a5,s9,s3
    2054:	012787bb          	addw	a5,a5,s2
    2058:	00078c9b          	sext.w	s9,a5
    if ((x % 3) == 0)
    205c:	0347f7bb          	remuw	a5,a5,s4
    2060:	dbf9                	beqz	a5,2036 <linkunlink+0x86>
    else if ((x % 3) == 1)
    2062:	01678863          	beq	a5,s6,2072 <linkunlink+0xc2>
      unlink("x");
    2066:	8556                	mv	a0,s5
    2068:	00004097          	auipc	ra,0x4
    206c:	9ba080e7          	jalr	-1606(ra) # 5a22 <unlink>
    2070:	bff1                	j	204c <linkunlink+0x9c>
      link("cat", "x");
    2072:	85d6                	mv	a1,s5
    2074:	855e                	mv	a0,s7
    2076:	00004097          	auipc	ra,0x4
    207a:	9bc080e7          	jalr	-1604(ra) # 5a32 <link>
    207e:	b7f9                	j	204c <linkunlink+0x9c>
  if (pid)
    2080:	020c0463          	beqz	s8,20a8 <linkunlink+0xf8>
    wait(0);
    2084:	4501                	li	a0,0
    2086:	00004097          	auipc	ra,0x4
    208a:	954080e7          	jalr	-1708(ra) # 59da <wait>
}
    208e:	60e6                	ld	ra,88(sp)
    2090:	6446                	ld	s0,80(sp)
    2092:	64a6                	ld	s1,72(sp)
    2094:	6906                	ld	s2,64(sp)
    2096:	79e2                	ld	s3,56(sp)
    2098:	7a42                	ld	s4,48(sp)
    209a:	7aa2                	ld	s5,40(sp)
    209c:	7b02                	ld	s6,32(sp)
    209e:	6be2                	ld	s7,24(sp)
    20a0:	6c42                	ld	s8,16(sp)
    20a2:	6ca2                	ld	s9,8(sp)
    20a4:	6125                	addi	sp,sp,96
    20a6:	8082                	ret
    exit(0);
    20a8:	4501                	li	a0,0
    20aa:	00004097          	auipc	ra,0x4
    20ae:	928080e7          	jalr	-1752(ra) # 59d2 <exit>

00000000000020b2 <forktest>:
{
    20b2:	7179                	addi	sp,sp,-48
    20b4:	f406                	sd	ra,40(sp)
    20b6:	f022                	sd	s0,32(sp)
    20b8:	ec26                	sd	s1,24(sp)
    20ba:	e84a                	sd	s2,16(sp)
    20bc:	e44e                	sd	s3,8(sp)
    20be:	1800                	addi	s0,sp,48
    20c0:	89aa                	mv	s3,a0
  for (n = 0; n < N; n++)
    20c2:	4481                	li	s1,0
    20c4:	3e800913          	li	s2,1000
    pid = fork();
    20c8:	00004097          	auipc	ra,0x4
    20cc:	902080e7          	jalr	-1790(ra) # 59ca <fork>
    if (pid < 0)
    20d0:	02054863          	bltz	a0,2100 <forktest+0x4e>
    if (pid == 0)
    20d4:	c115                	beqz	a0,20f8 <forktest+0x46>
  for (n = 0; n < N; n++)
    20d6:	2485                	addiw	s1,s1,1
    20d8:	ff2498e3          	bne	s1,s2,20c8 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    20dc:	85ce                	mv	a1,s3
    20de:	00005517          	auipc	a0,0x5
    20e2:	96a50513          	addi	a0,a0,-1686 # 6a48 <malloc+0xc2c>
    20e6:	00004097          	auipc	ra,0x4
    20ea:	c7e080e7          	jalr	-898(ra) # 5d64 <printf>
    exit(1);
    20ee:	4505                	li	a0,1
    20f0:	00004097          	auipc	ra,0x4
    20f4:	8e2080e7          	jalr	-1822(ra) # 59d2 <exit>
      exit(0);
    20f8:	00004097          	auipc	ra,0x4
    20fc:	8da080e7          	jalr	-1830(ra) # 59d2 <exit>
  if (n == 0)
    2100:	cc9d                	beqz	s1,213e <forktest+0x8c>
  if (n == N)
    2102:	3e800793          	li	a5,1000
    2106:	fcf48be3          	beq	s1,a5,20dc <forktest+0x2a>
  for (; n > 0; n--)
    210a:	00905b63          	blez	s1,2120 <forktest+0x6e>
    if (wait(0) < 0)
    210e:	4501                	li	a0,0
    2110:	00004097          	auipc	ra,0x4
    2114:	8ca080e7          	jalr	-1846(ra) # 59da <wait>
    2118:	04054163          	bltz	a0,215a <forktest+0xa8>
  for (; n > 0; n--)
    211c:	34fd                	addiw	s1,s1,-1
    211e:	f8e5                	bnez	s1,210e <forktest+0x5c>
  if (wait(0) != -1)
    2120:	4501                	li	a0,0
    2122:	00004097          	auipc	ra,0x4
    2126:	8b8080e7          	jalr	-1864(ra) # 59da <wait>
    212a:	57fd                	li	a5,-1
    212c:	04f51563          	bne	a0,a5,2176 <forktest+0xc4>
}
    2130:	70a2                	ld	ra,40(sp)
    2132:	7402                	ld	s0,32(sp)
    2134:	64e2                	ld	s1,24(sp)
    2136:	6942                	ld	s2,16(sp)
    2138:	69a2                	ld	s3,8(sp)
    213a:	6145                	addi	sp,sp,48
    213c:	8082                	ret
    printf("%s: no fork at all!\n", s);
    213e:	85ce                	mv	a1,s3
    2140:	00005517          	auipc	a0,0x5
    2144:	8f050513          	addi	a0,a0,-1808 # 6a30 <malloc+0xc14>
    2148:	00004097          	auipc	ra,0x4
    214c:	c1c080e7          	jalr	-996(ra) # 5d64 <printf>
    exit(1);
    2150:	4505                	li	a0,1
    2152:	00004097          	auipc	ra,0x4
    2156:	880080e7          	jalr	-1920(ra) # 59d2 <exit>
      printf("%s: wait stopped early\n", s);
    215a:	85ce                	mv	a1,s3
    215c:	00005517          	auipc	a0,0x5
    2160:	91450513          	addi	a0,a0,-1772 # 6a70 <malloc+0xc54>
    2164:	00004097          	auipc	ra,0x4
    2168:	c00080e7          	jalr	-1024(ra) # 5d64 <printf>
      exit(1);
    216c:	4505                	li	a0,1
    216e:	00004097          	auipc	ra,0x4
    2172:	864080e7          	jalr	-1948(ra) # 59d2 <exit>
    printf("%s: wait got too many\n", s);
    2176:	85ce                	mv	a1,s3
    2178:	00005517          	auipc	a0,0x5
    217c:	91050513          	addi	a0,a0,-1776 # 6a88 <malloc+0xc6c>
    2180:	00004097          	auipc	ra,0x4
    2184:	be4080e7          	jalr	-1052(ra) # 5d64 <printf>
    exit(1);
    2188:	4505                	li	a0,1
    218a:	00004097          	auipc	ra,0x4
    218e:	848080e7          	jalr	-1976(ra) # 59d2 <exit>

0000000000002192 <kernmem>:
{
    2192:	715d                	addi	sp,sp,-80
    2194:	e486                	sd	ra,72(sp)
    2196:	e0a2                	sd	s0,64(sp)
    2198:	fc26                	sd	s1,56(sp)
    219a:	f84a                	sd	s2,48(sp)
    219c:	f44e                	sd	s3,40(sp)
    219e:	f052                	sd	s4,32(sp)
    21a0:	ec56                	sd	s5,24(sp)
    21a2:	0880                	addi	s0,sp,80
    21a4:	8a2a                	mv	s4,a0
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000)
    21a6:	4485                	li	s1,1
    21a8:	04fe                	slli	s1,s1,0x1f
    if (xstatus != -1) // did kernel kill child?
    21aa:	5afd                	li	s5,-1
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000)
    21ac:	69b1                	lui	s3,0xc
    21ae:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1de8>
    21b2:	1003d937          	lui	s2,0x1003d
    21b6:	090e                	slli	s2,s2,0x3
    21b8:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d808>
    pid = fork();
    21bc:	00004097          	auipc	ra,0x4
    21c0:	80e080e7          	jalr	-2034(ra) # 59ca <fork>
    if (pid < 0)
    21c4:	02054963          	bltz	a0,21f6 <kernmem+0x64>
    if (pid == 0)
    21c8:	c529                	beqz	a0,2212 <kernmem+0x80>
    wait(&xstatus);
    21ca:	fbc40513          	addi	a0,s0,-68
    21ce:	00004097          	auipc	ra,0x4
    21d2:	80c080e7          	jalr	-2036(ra) # 59da <wait>
    if (xstatus != -1) // did kernel kill child?
    21d6:	fbc42783          	lw	a5,-68(s0)
    21da:	05579d63          	bne	a5,s5,2234 <kernmem+0xa2>
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000)
    21de:	94ce                	add	s1,s1,s3
    21e0:	fd249ee3          	bne	s1,s2,21bc <kernmem+0x2a>
}
    21e4:	60a6                	ld	ra,72(sp)
    21e6:	6406                	ld	s0,64(sp)
    21e8:	74e2                	ld	s1,56(sp)
    21ea:	7942                	ld	s2,48(sp)
    21ec:	79a2                	ld	s3,40(sp)
    21ee:	7a02                	ld	s4,32(sp)
    21f0:	6ae2                	ld	s5,24(sp)
    21f2:	6161                	addi	sp,sp,80
    21f4:	8082                	ret
      printf("%s: fork failed\n", s);
    21f6:	85d2                	mv	a1,s4
    21f8:	00004517          	auipc	a0,0x4
    21fc:	5d850513          	addi	a0,a0,1496 # 67d0 <malloc+0x9b4>
    2200:	00004097          	auipc	ra,0x4
    2204:	b64080e7          	jalr	-1180(ra) # 5d64 <printf>
      exit(1);
    2208:	4505                	li	a0,1
    220a:	00003097          	auipc	ra,0x3
    220e:	7c8080e7          	jalr	1992(ra) # 59d2 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    2212:	0004c683          	lbu	a3,0(s1)
    2216:	8626                	mv	a2,s1
    2218:	85d2                	mv	a1,s4
    221a:	00005517          	auipc	a0,0x5
    221e:	88650513          	addi	a0,a0,-1914 # 6aa0 <malloc+0xc84>
    2222:	00004097          	auipc	ra,0x4
    2226:	b42080e7          	jalr	-1214(ra) # 5d64 <printf>
      exit(1);
    222a:	4505                	li	a0,1
    222c:	00003097          	auipc	ra,0x3
    2230:	7a6080e7          	jalr	1958(ra) # 59d2 <exit>
      exit(1);
    2234:	4505                	li	a0,1
    2236:	00003097          	auipc	ra,0x3
    223a:	79c080e7          	jalr	1948(ra) # 59d2 <exit>

000000000000223e <MAXVAplus>:
{
    223e:	7179                	addi	sp,sp,-48
    2240:	f406                	sd	ra,40(sp)
    2242:	f022                	sd	s0,32(sp)
    2244:	ec26                	sd	s1,24(sp)
    2246:	e84a                	sd	s2,16(sp)
    2248:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    224a:	4785                	li	a5,1
    224c:	179a                	slli	a5,a5,0x26
    224e:	fcf43c23          	sd	a5,-40(s0)
  for (; a != 0; a <<= 1)
    2252:	fd843783          	ld	a5,-40(s0)
    2256:	cf85                	beqz	a5,228e <MAXVAplus+0x50>
    2258:	892a                	mv	s2,a0
    if (xstatus != -1) // did kernel kill child?
    225a:	54fd                	li	s1,-1
    pid = fork();
    225c:	00003097          	auipc	ra,0x3
    2260:	76e080e7          	jalr	1902(ra) # 59ca <fork>
    if (pid < 0)
    2264:	02054b63          	bltz	a0,229a <MAXVAplus+0x5c>
    if (pid == 0)
    2268:	c539                	beqz	a0,22b6 <MAXVAplus+0x78>
    wait(&xstatus);
    226a:	fd440513          	addi	a0,s0,-44
    226e:	00003097          	auipc	ra,0x3
    2272:	76c080e7          	jalr	1900(ra) # 59da <wait>
    if (xstatus != -1) // did kernel kill child?
    2276:	fd442783          	lw	a5,-44(s0)
    227a:	06979463          	bne	a5,s1,22e2 <MAXVAplus+0xa4>
  for (; a != 0; a <<= 1)
    227e:	fd843783          	ld	a5,-40(s0)
    2282:	0786                	slli	a5,a5,0x1
    2284:	fcf43c23          	sd	a5,-40(s0)
    2288:	fd843783          	ld	a5,-40(s0)
    228c:	fbe1                	bnez	a5,225c <MAXVAplus+0x1e>
}
    228e:	70a2                	ld	ra,40(sp)
    2290:	7402                	ld	s0,32(sp)
    2292:	64e2                	ld	s1,24(sp)
    2294:	6942                	ld	s2,16(sp)
    2296:	6145                	addi	sp,sp,48
    2298:	8082                	ret
      printf("%s: fork failed\n", s);
    229a:	85ca                	mv	a1,s2
    229c:	00004517          	auipc	a0,0x4
    22a0:	53450513          	addi	a0,a0,1332 # 67d0 <malloc+0x9b4>
    22a4:	00004097          	auipc	ra,0x4
    22a8:	ac0080e7          	jalr	-1344(ra) # 5d64 <printf>
      exit(1);
    22ac:	4505                	li	a0,1
    22ae:	00003097          	auipc	ra,0x3
    22b2:	724080e7          	jalr	1828(ra) # 59d2 <exit>
      *(char *)a = 99;
    22b6:	fd843783          	ld	a5,-40(s0)
    22ba:	06300713          	li	a4,99
    22be:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    22c2:	fd843603          	ld	a2,-40(s0)
    22c6:	85ca                	mv	a1,s2
    22c8:	00004517          	auipc	a0,0x4
    22cc:	7f850513          	addi	a0,a0,2040 # 6ac0 <malloc+0xca4>
    22d0:	00004097          	auipc	ra,0x4
    22d4:	a94080e7          	jalr	-1388(ra) # 5d64 <printf>
      exit(1);
    22d8:	4505                	li	a0,1
    22da:	00003097          	auipc	ra,0x3
    22de:	6f8080e7          	jalr	1784(ra) # 59d2 <exit>
      exit(1);
    22e2:	4505                	li	a0,1
    22e4:	00003097          	auipc	ra,0x3
    22e8:	6ee080e7          	jalr	1774(ra) # 59d2 <exit>

00000000000022ec <bigargtest>:
{
    22ec:	7179                	addi	sp,sp,-48
    22ee:	f406                	sd	ra,40(sp)
    22f0:	f022                	sd	s0,32(sp)
    22f2:	ec26                	sd	s1,24(sp)
    22f4:	1800                	addi	s0,sp,48
    22f6:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    22f8:	00004517          	auipc	a0,0x4
    22fc:	7e050513          	addi	a0,a0,2016 # 6ad8 <malloc+0xcbc>
    2300:	00003097          	auipc	ra,0x3
    2304:	722080e7          	jalr	1826(ra) # 5a22 <unlink>
  pid = fork();
    2308:	00003097          	auipc	ra,0x3
    230c:	6c2080e7          	jalr	1730(ra) # 59ca <fork>
  if (pid == 0)
    2310:	c121                	beqz	a0,2350 <bigargtest+0x64>
  else if (pid < 0)
    2312:	0a054063          	bltz	a0,23b2 <bigargtest+0xc6>
  wait(&xstatus);
    2316:	fdc40513          	addi	a0,s0,-36
    231a:	00003097          	auipc	ra,0x3
    231e:	6c0080e7          	jalr	1728(ra) # 59da <wait>
  if (xstatus != 0)
    2322:	fdc42503          	lw	a0,-36(s0)
    2326:	e545                	bnez	a0,23ce <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    2328:	4581                	li	a1,0
    232a:	00004517          	auipc	a0,0x4
    232e:	7ae50513          	addi	a0,a0,1966 # 6ad8 <malloc+0xcbc>
    2332:	00003097          	auipc	ra,0x3
    2336:	6e0080e7          	jalr	1760(ra) # 5a12 <open>
  if (fd < 0)
    233a:	08054e63          	bltz	a0,23d6 <bigargtest+0xea>
  close(fd);
    233e:	00003097          	auipc	ra,0x3
    2342:	6bc080e7          	jalr	1724(ra) # 59fa <close>
}
    2346:	70a2                	ld	ra,40(sp)
    2348:	7402                	ld	s0,32(sp)
    234a:	64e2                	ld	s1,24(sp)
    234c:	6145                	addi	sp,sp,48
    234e:	8082                	ret
    2350:	00007797          	auipc	a5,0x7
    2354:	11078793          	addi	a5,a5,272 # 9460 <args.1>
    2358:	00007697          	auipc	a3,0x7
    235c:	20068693          	addi	a3,a3,512 # 9558 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    2360:	00004717          	auipc	a4,0x4
    2364:	78870713          	addi	a4,a4,1928 # 6ae8 <malloc+0xccc>
    2368:	e398                	sd	a4,0(a5)
    for (i = 0; i < MAXARG - 1; i++)
    236a:	07a1                	addi	a5,a5,8
    236c:	fed79ee3          	bne	a5,a3,2368 <bigargtest+0x7c>
    args[MAXARG - 1] = 0;
    2370:	00007597          	auipc	a1,0x7
    2374:	0f058593          	addi	a1,a1,240 # 9460 <args.1>
    2378:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    237c:	00004517          	auipc	a0,0x4
    2380:	bcc50513          	addi	a0,a0,-1076 # 5f48 <malloc+0x12c>
    2384:	00003097          	auipc	ra,0x3
    2388:	686080e7          	jalr	1670(ra) # 5a0a <exec>
    fd = open("bigarg-ok", O_CREATE);
    238c:	20000593          	li	a1,512
    2390:	00004517          	auipc	a0,0x4
    2394:	74850513          	addi	a0,a0,1864 # 6ad8 <malloc+0xcbc>
    2398:	00003097          	auipc	ra,0x3
    239c:	67a080e7          	jalr	1658(ra) # 5a12 <open>
    close(fd);
    23a0:	00003097          	auipc	ra,0x3
    23a4:	65a080e7          	jalr	1626(ra) # 59fa <close>
    exit(0);
    23a8:	4501                	li	a0,0
    23aa:	00003097          	auipc	ra,0x3
    23ae:	628080e7          	jalr	1576(ra) # 59d2 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    23b2:	85a6                	mv	a1,s1
    23b4:	00005517          	auipc	a0,0x5
    23b8:	81450513          	addi	a0,a0,-2028 # 6bc8 <malloc+0xdac>
    23bc:	00004097          	auipc	ra,0x4
    23c0:	9a8080e7          	jalr	-1624(ra) # 5d64 <printf>
    exit(1);
    23c4:	4505                	li	a0,1
    23c6:	00003097          	auipc	ra,0x3
    23ca:	60c080e7          	jalr	1548(ra) # 59d2 <exit>
    exit(xstatus);
    23ce:	00003097          	auipc	ra,0x3
    23d2:	604080e7          	jalr	1540(ra) # 59d2 <exit>
    printf("%s: bigarg test failed!\n", s);
    23d6:	85a6                	mv	a1,s1
    23d8:	00005517          	auipc	a0,0x5
    23dc:	81050513          	addi	a0,a0,-2032 # 6be8 <malloc+0xdcc>
    23e0:	00004097          	auipc	ra,0x4
    23e4:	984080e7          	jalr	-1660(ra) # 5d64 <printf>
    exit(1);
    23e8:	4505                	li	a0,1
    23ea:	00003097          	auipc	ra,0x3
    23ee:	5e8080e7          	jalr	1512(ra) # 59d2 <exit>

00000000000023f2 <stacktest>:
{
    23f2:	7179                	addi	sp,sp,-48
    23f4:	f406                	sd	ra,40(sp)
    23f6:	f022                	sd	s0,32(sp)
    23f8:	ec26                	sd	s1,24(sp)
    23fa:	1800                	addi	s0,sp,48
    23fc:	84aa                	mv	s1,a0
  pid = fork();
    23fe:	00003097          	auipc	ra,0x3
    2402:	5cc080e7          	jalr	1484(ra) # 59ca <fork>
  if (pid == 0)
    2406:	c115                	beqz	a0,242a <stacktest+0x38>
  else if (pid < 0)
    2408:	04054463          	bltz	a0,2450 <stacktest+0x5e>
  wait(&xstatus);
    240c:	fdc40513          	addi	a0,s0,-36
    2410:	00003097          	auipc	ra,0x3
    2414:	5ca080e7          	jalr	1482(ra) # 59da <wait>
  if (xstatus == -1) // kernel killed child?
    2418:	fdc42503          	lw	a0,-36(s0)
    241c:	57fd                	li	a5,-1
    241e:	04f50763          	beq	a0,a5,246c <stacktest+0x7a>
    exit(xstatus);
    2422:	00003097          	auipc	ra,0x3
    2426:	5b0080e7          	jalr	1456(ra) # 59d2 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp"
    242a:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    242c:	77fd                	lui	a5,0xfffff
    242e:	97ba                	add	a5,a5,a4
    2430:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    2434:	85a6                	mv	a1,s1
    2436:	00004517          	auipc	a0,0x4
    243a:	7d250513          	addi	a0,a0,2002 # 6c08 <malloc+0xdec>
    243e:	00004097          	auipc	ra,0x4
    2442:	926080e7          	jalr	-1754(ra) # 5d64 <printf>
    exit(1);
    2446:	4505                	li	a0,1
    2448:	00003097          	auipc	ra,0x3
    244c:	58a080e7          	jalr	1418(ra) # 59d2 <exit>
    printf("%s: fork failed\n", s);
    2450:	85a6                	mv	a1,s1
    2452:	00004517          	auipc	a0,0x4
    2456:	37e50513          	addi	a0,a0,894 # 67d0 <malloc+0x9b4>
    245a:	00004097          	auipc	ra,0x4
    245e:	90a080e7          	jalr	-1782(ra) # 5d64 <printf>
    exit(1);
    2462:	4505                	li	a0,1
    2464:	00003097          	auipc	ra,0x3
    2468:	56e080e7          	jalr	1390(ra) # 59d2 <exit>
    exit(0);
    246c:	4501                	li	a0,0
    246e:	00003097          	auipc	ra,0x3
    2472:	564080e7          	jalr	1380(ra) # 59d2 <exit>

0000000000002476 <manywrites>:
{
    2476:	711d                	addi	sp,sp,-96
    2478:	ec86                	sd	ra,88(sp)
    247a:	e8a2                	sd	s0,80(sp)
    247c:	e4a6                	sd	s1,72(sp)
    247e:	e0ca                	sd	s2,64(sp)
    2480:	fc4e                	sd	s3,56(sp)
    2482:	f852                	sd	s4,48(sp)
    2484:	f456                	sd	s5,40(sp)
    2486:	f05a                	sd	s6,32(sp)
    2488:	ec5e                	sd	s7,24(sp)
    248a:	1080                	addi	s0,sp,96
    248c:	8aaa                	mv	s5,a0
  for (int ci = 0; ci < nchildren; ci++)
    248e:	4981                	li	s3,0
    2490:	4911                	li	s2,4
    int pid = fork();
    2492:	00003097          	auipc	ra,0x3
    2496:	538080e7          	jalr	1336(ra) # 59ca <fork>
    249a:	84aa                	mv	s1,a0
    if (pid < 0)
    249c:	02054963          	bltz	a0,24ce <manywrites+0x58>
    if (pid == 0)
    24a0:	c521                	beqz	a0,24e8 <manywrites+0x72>
  for (int ci = 0; ci < nchildren; ci++)
    24a2:	2985                	addiw	s3,s3,1
    24a4:	ff2997e3          	bne	s3,s2,2492 <manywrites+0x1c>
    24a8:	4491                	li	s1,4
    int st = 0;
    24aa:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    24ae:	fa840513          	addi	a0,s0,-88
    24b2:	00003097          	auipc	ra,0x3
    24b6:	528080e7          	jalr	1320(ra) # 59da <wait>
    if (st != 0)
    24ba:	fa842503          	lw	a0,-88(s0)
    24be:	ed6d                	bnez	a0,25b8 <manywrites+0x142>
  for (int ci = 0; ci < nchildren; ci++)
    24c0:	34fd                	addiw	s1,s1,-1
    24c2:	f4e5                	bnez	s1,24aa <manywrites+0x34>
  exit(0);
    24c4:	4501                	li	a0,0
    24c6:	00003097          	auipc	ra,0x3
    24ca:	50c080e7          	jalr	1292(ra) # 59d2 <exit>
      printf("fork failed\n");
    24ce:	00004517          	auipc	a0,0x4
    24d2:	70a50513          	addi	a0,a0,1802 # 6bd8 <malloc+0xdbc>
    24d6:	00004097          	auipc	ra,0x4
    24da:	88e080e7          	jalr	-1906(ra) # 5d64 <printf>
      exit(1);
    24de:	4505                	li	a0,1
    24e0:	00003097          	auipc	ra,0x3
    24e4:	4f2080e7          	jalr	1266(ra) # 59d2 <exit>
      name[0] = 'b';
    24e8:	06200793          	li	a5,98
    24ec:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    24f0:	0619879b          	addiw	a5,s3,97
    24f4:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    24f8:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    24fc:	fa840513          	addi	a0,s0,-88
    2500:	00003097          	auipc	ra,0x3
    2504:	522080e7          	jalr	1314(ra) # 5a22 <unlink>
    2508:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    250a:	0000ab17          	auipc	s6,0xa
    250e:	76eb0b13          	addi	s6,s6,1902 # cc78 <buf>
        for (int i = 0; i < ci + 1; i++)
    2512:	8a26                	mv	s4,s1
    2514:	0209ce63          	bltz	s3,2550 <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    2518:	20200593          	li	a1,514
    251c:	fa840513          	addi	a0,s0,-88
    2520:	00003097          	auipc	ra,0x3
    2524:	4f2080e7          	jalr	1266(ra) # 5a12 <open>
    2528:	892a                	mv	s2,a0
          if (fd < 0)
    252a:	04054763          	bltz	a0,2578 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    252e:	660d                	lui	a2,0x3
    2530:	85da                	mv	a1,s6
    2532:	00003097          	auipc	ra,0x3
    2536:	4c0080e7          	jalr	1216(ra) # 59f2 <write>
          if (cc != sz)
    253a:	678d                	lui	a5,0x3
    253c:	04f51e63          	bne	a0,a5,2598 <manywrites+0x122>
          close(fd);
    2540:	854a                	mv	a0,s2
    2542:	00003097          	auipc	ra,0x3
    2546:	4b8080e7          	jalr	1208(ra) # 59fa <close>
        for (int i = 0; i < ci + 1; i++)
    254a:	2a05                	addiw	s4,s4,1
    254c:	fd49d6e3          	bge	s3,s4,2518 <manywrites+0xa2>
        unlink(name);
    2550:	fa840513          	addi	a0,s0,-88
    2554:	00003097          	auipc	ra,0x3
    2558:	4ce080e7          	jalr	1230(ra) # 5a22 <unlink>
      for (int iters = 0; iters < howmany; iters++)
    255c:	3bfd                	addiw	s7,s7,-1
    255e:	fa0b9ae3          	bnez	s7,2512 <manywrites+0x9c>
      unlink(name);
    2562:	fa840513          	addi	a0,s0,-88
    2566:	00003097          	auipc	ra,0x3
    256a:	4bc080e7          	jalr	1212(ra) # 5a22 <unlink>
      exit(0);
    256e:	4501                	li	a0,0
    2570:	00003097          	auipc	ra,0x3
    2574:	462080e7          	jalr	1122(ra) # 59d2 <exit>
            printf("%s: cannot create %s\n", s, name);
    2578:	fa840613          	addi	a2,s0,-88
    257c:	85d6                	mv	a1,s5
    257e:	00004517          	auipc	a0,0x4
    2582:	6b250513          	addi	a0,a0,1714 # 6c30 <malloc+0xe14>
    2586:	00003097          	auipc	ra,0x3
    258a:	7de080e7          	jalr	2014(ra) # 5d64 <printf>
            exit(1);
    258e:	4505                	li	a0,1
    2590:	00003097          	auipc	ra,0x3
    2594:	442080e7          	jalr	1090(ra) # 59d2 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    2598:	86aa                	mv	a3,a0
    259a:	660d                	lui	a2,0x3
    259c:	85d6                	mv	a1,s5
    259e:	00004517          	auipc	a0,0x4
    25a2:	a7a50513          	addi	a0,a0,-1414 # 6018 <malloc+0x1fc>
    25a6:	00003097          	auipc	ra,0x3
    25aa:	7be080e7          	jalr	1982(ra) # 5d64 <printf>
            exit(1);
    25ae:	4505                	li	a0,1
    25b0:	00003097          	auipc	ra,0x3
    25b4:	422080e7          	jalr	1058(ra) # 59d2 <exit>
      exit(st);
    25b8:	00003097          	auipc	ra,0x3
    25bc:	41a080e7          	jalr	1050(ra) # 59d2 <exit>

00000000000025c0 <copyinstr3>:
{
    25c0:	7179                	addi	sp,sp,-48
    25c2:	f406                	sd	ra,40(sp)
    25c4:	f022                	sd	s0,32(sp)
    25c6:	ec26                	sd	s1,24(sp)
    25c8:	1800                	addi	s0,sp,48
  sbrk(8192);
    25ca:	6509                	lui	a0,0x2
    25cc:	00003097          	auipc	ra,0x3
    25d0:	48e080e7          	jalr	1166(ra) # 5a5a <sbrk>
  uint64 top = (uint64)sbrk(0);
    25d4:	4501                	li	a0,0
    25d6:	00003097          	auipc	ra,0x3
    25da:	484080e7          	jalr	1156(ra) # 5a5a <sbrk>
  if ((top % PGSIZE) != 0)
    25de:	03451793          	slli	a5,a0,0x34
    25e2:	e3c9                	bnez	a5,2664 <copyinstr3+0xa4>
  top = (uint64)sbrk(0);
    25e4:	4501                	li	a0,0
    25e6:	00003097          	auipc	ra,0x3
    25ea:	474080e7          	jalr	1140(ra) # 5a5a <sbrk>
  if (top % PGSIZE)
    25ee:	03451793          	slli	a5,a0,0x34
    25f2:	e3d9                	bnez	a5,2678 <copyinstr3+0xb8>
  char *b = (char *)(top - 1);
    25f4:	fff50493          	addi	s1,a0,-1 # 1fff <linkunlink+0x4f>
  *b = 'x';
    25f8:	07800793          	li	a5,120
    25fc:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2600:	8526                	mv	a0,s1
    2602:	00003097          	auipc	ra,0x3
    2606:	420080e7          	jalr	1056(ra) # 5a22 <unlink>
  if (ret != -1)
    260a:	57fd                	li	a5,-1
    260c:	08f51363          	bne	a0,a5,2692 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2610:	20100593          	li	a1,513
    2614:	8526                	mv	a0,s1
    2616:	00003097          	auipc	ra,0x3
    261a:	3fc080e7          	jalr	1020(ra) # 5a12 <open>
  if (fd != -1)
    261e:	57fd                	li	a5,-1
    2620:	08f51863          	bne	a0,a5,26b0 <copyinstr3+0xf0>
  ret = link(b, b);
    2624:	85a6                	mv	a1,s1
    2626:	8526                	mv	a0,s1
    2628:	00003097          	auipc	ra,0x3
    262c:	40a080e7          	jalr	1034(ra) # 5a32 <link>
  if (ret != -1)
    2630:	57fd                	li	a5,-1
    2632:	08f51e63          	bne	a0,a5,26ce <copyinstr3+0x10e>
  char *args[] = {"xx", 0};
    2636:	00005797          	auipc	a5,0x5
    263a:	2f278793          	addi	a5,a5,754 # 7928 <malloc+0x1b0c>
    263e:	fcf43823          	sd	a5,-48(s0)
    2642:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2646:	fd040593          	addi	a1,s0,-48
    264a:	8526                	mv	a0,s1
    264c:	00003097          	auipc	ra,0x3
    2650:	3be080e7          	jalr	958(ra) # 5a0a <exec>
  if (ret != -1)
    2654:	57fd                	li	a5,-1
    2656:	08f51c63          	bne	a0,a5,26ee <copyinstr3+0x12e>
}
    265a:	70a2                	ld	ra,40(sp)
    265c:	7402                	ld	s0,32(sp)
    265e:	64e2                	ld	s1,24(sp)
    2660:	6145                	addi	sp,sp,48
    2662:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2664:	0347d513          	srli	a0,a5,0x34
    2668:	6785                	lui	a5,0x1
    266a:	40a7853b          	subw	a0,a5,a0
    266e:	00003097          	auipc	ra,0x3
    2672:	3ec080e7          	jalr	1004(ra) # 5a5a <sbrk>
    2676:	b7bd                	j	25e4 <copyinstr3+0x24>
    printf("oops\n");
    2678:	00004517          	auipc	a0,0x4
    267c:	5d050513          	addi	a0,a0,1488 # 6c48 <malloc+0xe2c>
    2680:	00003097          	auipc	ra,0x3
    2684:	6e4080e7          	jalr	1764(ra) # 5d64 <printf>
    exit(1);
    2688:	4505                	li	a0,1
    268a:	00003097          	auipc	ra,0x3
    268e:	348080e7          	jalr	840(ra) # 59d2 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    2692:	862a                	mv	a2,a0
    2694:	85a6                	mv	a1,s1
    2696:	00004517          	auipc	a0,0x4
    269a:	05a50513          	addi	a0,a0,90 # 66f0 <malloc+0x8d4>
    269e:	00003097          	auipc	ra,0x3
    26a2:	6c6080e7          	jalr	1734(ra) # 5d64 <printf>
    exit(1);
    26a6:	4505                	li	a0,1
    26a8:	00003097          	auipc	ra,0x3
    26ac:	32a080e7          	jalr	810(ra) # 59d2 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    26b0:	862a                	mv	a2,a0
    26b2:	85a6                	mv	a1,s1
    26b4:	00004517          	auipc	a0,0x4
    26b8:	05c50513          	addi	a0,a0,92 # 6710 <malloc+0x8f4>
    26bc:	00003097          	auipc	ra,0x3
    26c0:	6a8080e7          	jalr	1704(ra) # 5d64 <printf>
    exit(1);
    26c4:	4505                	li	a0,1
    26c6:	00003097          	auipc	ra,0x3
    26ca:	30c080e7          	jalr	780(ra) # 59d2 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    26ce:	86aa                	mv	a3,a0
    26d0:	8626                	mv	a2,s1
    26d2:	85a6                	mv	a1,s1
    26d4:	00004517          	auipc	a0,0x4
    26d8:	05c50513          	addi	a0,a0,92 # 6730 <malloc+0x914>
    26dc:	00003097          	auipc	ra,0x3
    26e0:	688080e7          	jalr	1672(ra) # 5d64 <printf>
    exit(1);
    26e4:	4505                	li	a0,1
    26e6:	00003097          	auipc	ra,0x3
    26ea:	2ec080e7          	jalr	748(ra) # 59d2 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    26ee:	567d                	li	a2,-1
    26f0:	85a6                	mv	a1,s1
    26f2:	00004517          	auipc	a0,0x4
    26f6:	06650513          	addi	a0,a0,102 # 6758 <malloc+0x93c>
    26fa:	00003097          	auipc	ra,0x3
    26fe:	66a080e7          	jalr	1642(ra) # 5d64 <printf>
    exit(1);
    2702:	4505                	li	a0,1
    2704:	00003097          	auipc	ra,0x3
    2708:	2ce080e7          	jalr	718(ra) # 59d2 <exit>

000000000000270c <rwsbrk>:
{
    270c:	1101                	addi	sp,sp,-32
    270e:	ec06                	sd	ra,24(sp)
    2710:	e822                	sd	s0,16(sp)
    2712:	e426                	sd	s1,8(sp)
    2714:	e04a                	sd	s2,0(sp)
    2716:	1000                	addi	s0,sp,32
  uint64 a = (uint64)sbrk(8192);
    2718:	6509                	lui	a0,0x2
    271a:	00003097          	auipc	ra,0x3
    271e:	340080e7          	jalr	832(ra) # 5a5a <sbrk>
  if (a == 0xffffffffffffffffLL)
    2722:	57fd                	li	a5,-1
    2724:	06f50263          	beq	a0,a5,2788 <rwsbrk+0x7c>
    2728:	84aa                	mv	s1,a0
  if ((uint64)sbrk(-8192) == 0xffffffffffffffffLL)
    272a:	7579                	lui	a0,0xffffe
    272c:	00003097          	auipc	ra,0x3
    2730:	32e080e7          	jalr	814(ra) # 5a5a <sbrk>
    2734:	57fd                	li	a5,-1
    2736:	06f50663          	beq	a0,a5,27a2 <rwsbrk+0x96>
  fd = open("rwsbrk", O_CREATE | O_WRONLY);
    273a:	20100593          	li	a1,513
    273e:	00004517          	auipc	a0,0x4
    2742:	54a50513          	addi	a0,a0,1354 # 6c88 <malloc+0xe6c>
    2746:	00003097          	auipc	ra,0x3
    274a:	2cc080e7          	jalr	716(ra) # 5a12 <open>
    274e:	892a                	mv	s2,a0
  if (fd < 0)
    2750:	06054663          	bltz	a0,27bc <rwsbrk+0xb0>
  n = write(fd, (void *)(a + 4096), 1024);
    2754:	6785                	lui	a5,0x1
    2756:	94be                	add	s1,s1,a5
    2758:	40000613          	li	a2,1024
    275c:	85a6                	mv	a1,s1
    275e:	00003097          	auipc	ra,0x3
    2762:	294080e7          	jalr	660(ra) # 59f2 <write>
    2766:	862a                	mv	a2,a0
  if (n >= 0)
    2768:	06054763          	bltz	a0,27d6 <rwsbrk+0xca>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a + 4096, n);
    276c:	85a6                	mv	a1,s1
    276e:	00004517          	auipc	a0,0x4
    2772:	53a50513          	addi	a0,a0,1338 # 6ca8 <malloc+0xe8c>
    2776:	00003097          	auipc	ra,0x3
    277a:	5ee080e7          	jalr	1518(ra) # 5d64 <printf>
    exit(1);
    277e:	4505                	li	a0,1
    2780:	00003097          	auipc	ra,0x3
    2784:	252080e7          	jalr	594(ra) # 59d2 <exit>
    printf("sbrk(rwsbrk) failed\n");
    2788:	00004517          	auipc	a0,0x4
    278c:	4c850513          	addi	a0,a0,1224 # 6c50 <malloc+0xe34>
    2790:	00003097          	auipc	ra,0x3
    2794:	5d4080e7          	jalr	1492(ra) # 5d64 <printf>
    exit(1);
    2798:	4505                	li	a0,1
    279a:	00003097          	auipc	ra,0x3
    279e:	238080e7          	jalr	568(ra) # 59d2 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    27a2:	00004517          	auipc	a0,0x4
    27a6:	4c650513          	addi	a0,a0,1222 # 6c68 <malloc+0xe4c>
    27aa:	00003097          	auipc	ra,0x3
    27ae:	5ba080e7          	jalr	1466(ra) # 5d64 <printf>
    exit(1);
    27b2:	4505                	li	a0,1
    27b4:	00003097          	auipc	ra,0x3
    27b8:	21e080e7          	jalr	542(ra) # 59d2 <exit>
    printf("open(rwsbrk) failed\n");
    27bc:	00004517          	auipc	a0,0x4
    27c0:	4d450513          	addi	a0,a0,1236 # 6c90 <malloc+0xe74>
    27c4:	00003097          	auipc	ra,0x3
    27c8:	5a0080e7          	jalr	1440(ra) # 5d64 <printf>
    exit(1);
    27cc:	4505                	li	a0,1
    27ce:	00003097          	auipc	ra,0x3
    27d2:	204080e7          	jalr	516(ra) # 59d2 <exit>
  close(fd);
    27d6:	854a                	mv	a0,s2
    27d8:	00003097          	auipc	ra,0x3
    27dc:	222080e7          	jalr	546(ra) # 59fa <close>
  unlink("rwsbrk");
    27e0:	00004517          	auipc	a0,0x4
    27e4:	4a850513          	addi	a0,a0,1192 # 6c88 <malloc+0xe6c>
    27e8:	00003097          	auipc	ra,0x3
    27ec:	23a080e7          	jalr	570(ra) # 5a22 <unlink>
  fd = open("README", O_RDONLY);
    27f0:	4581                	li	a1,0
    27f2:	00004517          	auipc	a0,0x4
    27f6:	92e50513          	addi	a0,a0,-1746 # 6120 <malloc+0x304>
    27fa:	00003097          	auipc	ra,0x3
    27fe:	218080e7          	jalr	536(ra) # 5a12 <open>
    2802:	892a                	mv	s2,a0
  if (fd < 0)
    2804:	02054963          	bltz	a0,2836 <rwsbrk+0x12a>
  n = read(fd, (void *)(a + 4096), 10);
    2808:	4629                	li	a2,10
    280a:	85a6                	mv	a1,s1
    280c:	00003097          	auipc	ra,0x3
    2810:	1de080e7          	jalr	478(ra) # 59ea <read>
    2814:	862a                	mv	a2,a0
  if (n >= 0)
    2816:	02054d63          	bltz	a0,2850 <rwsbrk+0x144>
    printf("read(fd, %p, 10) returned %d, not -1\n", a + 4096, n);
    281a:	85a6                	mv	a1,s1
    281c:	00004517          	auipc	a0,0x4
    2820:	4bc50513          	addi	a0,a0,1212 # 6cd8 <malloc+0xebc>
    2824:	00003097          	auipc	ra,0x3
    2828:	540080e7          	jalr	1344(ra) # 5d64 <printf>
    exit(1);
    282c:	4505                	li	a0,1
    282e:	00003097          	auipc	ra,0x3
    2832:	1a4080e7          	jalr	420(ra) # 59d2 <exit>
    printf("open(rwsbrk) failed\n");
    2836:	00004517          	auipc	a0,0x4
    283a:	45a50513          	addi	a0,a0,1114 # 6c90 <malloc+0xe74>
    283e:	00003097          	auipc	ra,0x3
    2842:	526080e7          	jalr	1318(ra) # 5d64 <printf>
    exit(1);
    2846:	4505                	li	a0,1
    2848:	00003097          	auipc	ra,0x3
    284c:	18a080e7          	jalr	394(ra) # 59d2 <exit>
  close(fd);
    2850:	854a                	mv	a0,s2
    2852:	00003097          	auipc	ra,0x3
    2856:	1a8080e7          	jalr	424(ra) # 59fa <close>
  exit(0);
    285a:	4501                	li	a0,0
    285c:	00003097          	auipc	ra,0x3
    2860:	176080e7          	jalr	374(ra) # 59d2 <exit>

0000000000002864 <sbrkbasic>:
{
    2864:	7139                	addi	sp,sp,-64
    2866:	fc06                	sd	ra,56(sp)
    2868:	f822                	sd	s0,48(sp)
    286a:	f426                	sd	s1,40(sp)
    286c:	f04a                	sd	s2,32(sp)
    286e:	ec4e                	sd	s3,24(sp)
    2870:	e852                	sd	s4,16(sp)
    2872:	0080                	addi	s0,sp,64
    2874:	8a2a                	mv	s4,a0
  pid = fork();
    2876:	00003097          	auipc	ra,0x3
    287a:	154080e7          	jalr	340(ra) # 59ca <fork>
  if (pid < 0)
    287e:	02054c63          	bltz	a0,28b6 <sbrkbasic+0x52>
  if (pid == 0)
    2882:	ed21                	bnez	a0,28da <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    2884:	40000537          	lui	a0,0x40000
    2888:	00003097          	auipc	ra,0x3
    288c:	1d2080e7          	jalr	466(ra) # 5a5a <sbrk>
    if (a == (char *)0xffffffffffffffffL)
    2890:	57fd                	li	a5,-1
    2892:	02f50f63          	beq	a0,a5,28d0 <sbrkbasic+0x6c>
    for (b = a; b < a + TOOMUCH; b += 4096)
    2896:	400007b7          	lui	a5,0x40000
    289a:	97aa                	add	a5,a5,a0
      *b = 99;
    289c:	06300693          	li	a3,99
    for (b = a; b < a + TOOMUCH; b += 4096)
    28a0:	6705                	lui	a4,0x1
      *b = 99;
    28a2:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0388>
    for (b = a; b < a + TOOMUCH; b += 4096)
    28a6:	953a                	add	a0,a0,a4
    28a8:	fef51de3          	bne	a0,a5,28a2 <sbrkbasic+0x3e>
    exit(1);
    28ac:	4505                	li	a0,1
    28ae:	00003097          	auipc	ra,0x3
    28b2:	124080e7          	jalr	292(ra) # 59d2 <exit>
    printf("fork failed in sbrkbasic\n");
    28b6:	00004517          	auipc	a0,0x4
    28ba:	44a50513          	addi	a0,a0,1098 # 6d00 <malloc+0xee4>
    28be:	00003097          	auipc	ra,0x3
    28c2:	4a6080e7          	jalr	1190(ra) # 5d64 <printf>
    exit(1);
    28c6:	4505                	li	a0,1
    28c8:	00003097          	auipc	ra,0x3
    28cc:	10a080e7          	jalr	266(ra) # 59d2 <exit>
      exit(0);
    28d0:	4501                	li	a0,0
    28d2:	00003097          	auipc	ra,0x3
    28d6:	100080e7          	jalr	256(ra) # 59d2 <exit>
  wait(&xstatus);
    28da:	fcc40513          	addi	a0,s0,-52
    28de:	00003097          	auipc	ra,0x3
    28e2:	0fc080e7          	jalr	252(ra) # 59da <wait>
  if (xstatus == 1)
    28e6:	fcc42703          	lw	a4,-52(s0)
    28ea:	4785                	li	a5,1
    28ec:	00f70d63          	beq	a4,a5,2906 <sbrkbasic+0xa2>
  a = sbrk(0);
    28f0:	4501                	li	a0,0
    28f2:	00003097          	auipc	ra,0x3
    28f6:	168080e7          	jalr	360(ra) # 5a5a <sbrk>
    28fa:	84aa                	mv	s1,a0
  for (i = 0; i < 5000; i++)
    28fc:	4901                	li	s2,0
    28fe:	6985                	lui	s3,0x1
    2900:	38898993          	addi	s3,s3,904 # 1388 <badarg+0x1a>
    2904:	a005                	j	2924 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    2906:	85d2                	mv	a1,s4
    2908:	00004517          	auipc	a0,0x4
    290c:	41850513          	addi	a0,a0,1048 # 6d20 <malloc+0xf04>
    2910:	00003097          	auipc	ra,0x3
    2914:	454080e7          	jalr	1108(ra) # 5d64 <printf>
    exit(1);
    2918:	4505                	li	a0,1
    291a:	00003097          	auipc	ra,0x3
    291e:	0b8080e7          	jalr	184(ra) # 59d2 <exit>
    a = b + 1;
    2922:	84be                	mv	s1,a5
    b = sbrk(1);
    2924:	4505                	li	a0,1
    2926:	00003097          	auipc	ra,0x3
    292a:	134080e7          	jalr	308(ra) # 5a5a <sbrk>
    if (b != a)
    292e:	04951c63          	bne	a0,s1,2986 <sbrkbasic+0x122>
    *b = 1;
    2932:	4785                	li	a5,1
    2934:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2938:	00148793          	addi	a5,s1,1
  for (i = 0; i < 5000; i++)
    293c:	2905                	addiw	s2,s2,1
    293e:	ff3912e3          	bne	s2,s3,2922 <sbrkbasic+0xbe>
  pid = fork();
    2942:	00003097          	auipc	ra,0x3
    2946:	088080e7          	jalr	136(ra) # 59ca <fork>
    294a:	892a                	mv	s2,a0
  if (pid < 0)
    294c:	04054e63          	bltz	a0,29a8 <sbrkbasic+0x144>
  c = sbrk(1);
    2950:	4505                	li	a0,1
    2952:	00003097          	auipc	ra,0x3
    2956:	108080e7          	jalr	264(ra) # 5a5a <sbrk>
  c = sbrk(1);
    295a:	4505                	li	a0,1
    295c:	00003097          	auipc	ra,0x3
    2960:	0fe080e7          	jalr	254(ra) # 5a5a <sbrk>
  if (c != a + 1)
    2964:	0489                	addi	s1,s1,2
    2966:	04a48f63          	beq	s1,a0,29c4 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    296a:	85d2                	mv	a1,s4
    296c:	00004517          	auipc	a0,0x4
    2970:	41450513          	addi	a0,a0,1044 # 6d80 <malloc+0xf64>
    2974:	00003097          	auipc	ra,0x3
    2978:	3f0080e7          	jalr	1008(ra) # 5d64 <printf>
    exit(1);
    297c:	4505                	li	a0,1
    297e:	00003097          	auipc	ra,0x3
    2982:	054080e7          	jalr	84(ra) # 59d2 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    2986:	872a                	mv	a4,a0
    2988:	86a6                	mv	a3,s1
    298a:	864a                	mv	a2,s2
    298c:	85d2                	mv	a1,s4
    298e:	00004517          	auipc	a0,0x4
    2992:	3b250513          	addi	a0,a0,946 # 6d40 <malloc+0xf24>
    2996:	00003097          	auipc	ra,0x3
    299a:	3ce080e7          	jalr	974(ra) # 5d64 <printf>
      exit(1);
    299e:	4505                	li	a0,1
    29a0:	00003097          	auipc	ra,0x3
    29a4:	032080e7          	jalr	50(ra) # 59d2 <exit>
    printf("%s: sbrk test fork failed\n", s);
    29a8:	85d2                	mv	a1,s4
    29aa:	00004517          	auipc	a0,0x4
    29ae:	3b650513          	addi	a0,a0,950 # 6d60 <malloc+0xf44>
    29b2:	00003097          	auipc	ra,0x3
    29b6:	3b2080e7          	jalr	946(ra) # 5d64 <printf>
    exit(1);
    29ba:	4505                	li	a0,1
    29bc:	00003097          	auipc	ra,0x3
    29c0:	016080e7          	jalr	22(ra) # 59d2 <exit>
  if (pid == 0)
    29c4:	00091763          	bnez	s2,29d2 <sbrkbasic+0x16e>
    exit(0);
    29c8:	4501                	li	a0,0
    29ca:	00003097          	auipc	ra,0x3
    29ce:	008080e7          	jalr	8(ra) # 59d2 <exit>
  wait(&xstatus);
    29d2:	fcc40513          	addi	a0,s0,-52
    29d6:	00003097          	auipc	ra,0x3
    29da:	004080e7          	jalr	4(ra) # 59da <wait>
  exit(xstatus);
    29de:	fcc42503          	lw	a0,-52(s0)
    29e2:	00003097          	auipc	ra,0x3
    29e6:	ff0080e7          	jalr	-16(ra) # 59d2 <exit>

00000000000029ea <sbrkmuch>:
{
    29ea:	7179                	addi	sp,sp,-48
    29ec:	f406                	sd	ra,40(sp)
    29ee:	f022                	sd	s0,32(sp)
    29f0:	ec26                	sd	s1,24(sp)
    29f2:	e84a                	sd	s2,16(sp)
    29f4:	e44e                	sd	s3,8(sp)
    29f6:	e052                	sd	s4,0(sp)
    29f8:	1800                	addi	s0,sp,48
    29fa:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    29fc:	4501                	li	a0,0
    29fe:	00003097          	auipc	ra,0x3
    2a02:	05c080e7          	jalr	92(ra) # 5a5a <sbrk>
    2a06:	892a                	mv	s2,a0
  a = sbrk(0);
    2a08:	4501                	li	a0,0
    2a0a:	00003097          	auipc	ra,0x3
    2a0e:	050080e7          	jalr	80(ra) # 5a5a <sbrk>
    2a12:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2a14:	06400537          	lui	a0,0x6400
    2a18:	9d05                	subw	a0,a0,s1
    2a1a:	00003097          	auipc	ra,0x3
    2a1e:	040080e7          	jalr	64(ra) # 5a5a <sbrk>
  if (p != a)
    2a22:	0ca49863          	bne	s1,a0,2af2 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2a26:	4501                	li	a0,0
    2a28:	00003097          	auipc	ra,0x3
    2a2c:	032080e7          	jalr	50(ra) # 5a5a <sbrk>
    2a30:	87aa                	mv	a5,a0
  for (char *pp = a; pp < eee; pp += 4096)
    2a32:	00a4f963          	bgeu	s1,a0,2a44 <sbrkmuch+0x5a>
    *pp = 1;
    2a36:	4685                	li	a3,1
  for (char *pp = a; pp < eee; pp += 4096)
    2a38:	6705                	lui	a4,0x1
    *pp = 1;
    2a3a:	00d48023          	sb	a3,0(s1)
  for (char *pp = a; pp < eee; pp += 4096)
    2a3e:	94ba                	add	s1,s1,a4
    2a40:	fef4ede3          	bltu	s1,a5,2a3a <sbrkmuch+0x50>
  *lastaddr = 99;
    2a44:	064007b7          	lui	a5,0x6400
    2a48:	06300713          	li	a4,99
    2a4c:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0387>
  a = sbrk(0);
    2a50:	4501                	li	a0,0
    2a52:	00003097          	auipc	ra,0x3
    2a56:	008080e7          	jalr	8(ra) # 5a5a <sbrk>
    2a5a:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2a5c:	757d                	lui	a0,0xfffff
    2a5e:	00003097          	auipc	ra,0x3
    2a62:	ffc080e7          	jalr	-4(ra) # 5a5a <sbrk>
  if (c == (char *)0xffffffffffffffffL)
    2a66:	57fd                	li	a5,-1
    2a68:	0af50363          	beq	a0,a5,2b0e <sbrkmuch+0x124>
  c = sbrk(0);
    2a6c:	4501                	li	a0,0
    2a6e:	00003097          	auipc	ra,0x3
    2a72:	fec080e7          	jalr	-20(ra) # 5a5a <sbrk>
  if (c != a - PGSIZE)
    2a76:	77fd                	lui	a5,0xfffff
    2a78:	97a6                	add	a5,a5,s1
    2a7a:	0af51863          	bne	a0,a5,2b2a <sbrkmuch+0x140>
  a = sbrk(0);
    2a7e:	4501                	li	a0,0
    2a80:	00003097          	auipc	ra,0x3
    2a84:	fda080e7          	jalr	-38(ra) # 5a5a <sbrk>
    2a88:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2a8a:	6505                	lui	a0,0x1
    2a8c:	00003097          	auipc	ra,0x3
    2a90:	fce080e7          	jalr	-50(ra) # 5a5a <sbrk>
    2a94:	8a2a                	mv	s4,a0
  if (c != a || sbrk(0) != a + PGSIZE)
    2a96:	0aa49a63          	bne	s1,a0,2b4a <sbrkmuch+0x160>
    2a9a:	4501                	li	a0,0
    2a9c:	00003097          	auipc	ra,0x3
    2aa0:	fbe080e7          	jalr	-66(ra) # 5a5a <sbrk>
    2aa4:	6785                	lui	a5,0x1
    2aa6:	97a6                	add	a5,a5,s1
    2aa8:	0af51163          	bne	a0,a5,2b4a <sbrkmuch+0x160>
  if (*lastaddr == 99)
    2aac:	064007b7          	lui	a5,0x6400
    2ab0:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0387>
    2ab4:	06300793          	li	a5,99
    2ab8:	0af70963          	beq	a4,a5,2b6a <sbrkmuch+0x180>
  a = sbrk(0);
    2abc:	4501                	li	a0,0
    2abe:	00003097          	auipc	ra,0x3
    2ac2:	f9c080e7          	jalr	-100(ra) # 5a5a <sbrk>
    2ac6:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2ac8:	4501                	li	a0,0
    2aca:	00003097          	auipc	ra,0x3
    2ace:	f90080e7          	jalr	-112(ra) # 5a5a <sbrk>
    2ad2:	40a9053b          	subw	a0,s2,a0
    2ad6:	00003097          	auipc	ra,0x3
    2ada:	f84080e7          	jalr	-124(ra) # 5a5a <sbrk>
  if (c != a)
    2ade:	0aa49463          	bne	s1,a0,2b86 <sbrkmuch+0x19c>
}
    2ae2:	70a2                	ld	ra,40(sp)
    2ae4:	7402                	ld	s0,32(sp)
    2ae6:	64e2                	ld	s1,24(sp)
    2ae8:	6942                	ld	s2,16(sp)
    2aea:	69a2                	ld	s3,8(sp)
    2aec:	6a02                	ld	s4,0(sp)
    2aee:	6145                	addi	sp,sp,48
    2af0:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2af2:	85ce                	mv	a1,s3
    2af4:	00004517          	auipc	a0,0x4
    2af8:	2ac50513          	addi	a0,a0,684 # 6da0 <malloc+0xf84>
    2afc:	00003097          	auipc	ra,0x3
    2b00:	268080e7          	jalr	616(ra) # 5d64 <printf>
    exit(1);
    2b04:	4505                	li	a0,1
    2b06:	00003097          	auipc	ra,0x3
    2b0a:	ecc080e7          	jalr	-308(ra) # 59d2 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2b0e:	85ce                	mv	a1,s3
    2b10:	00004517          	auipc	a0,0x4
    2b14:	2d850513          	addi	a0,a0,728 # 6de8 <malloc+0xfcc>
    2b18:	00003097          	auipc	ra,0x3
    2b1c:	24c080e7          	jalr	588(ra) # 5d64 <printf>
    exit(1);
    2b20:	4505                	li	a0,1
    2b22:	00003097          	auipc	ra,0x3
    2b26:	eb0080e7          	jalr	-336(ra) # 59d2 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2b2a:	86aa                	mv	a3,a0
    2b2c:	8626                	mv	a2,s1
    2b2e:	85ce                	mv	a1,s3
    2b30:	00004517          	auipc	a0,0x4
    2b34:	2d850513          	addi	a0,a0,728 # 6e08 <malloc+0xfec>
    2b38:	00003097          	auipc	ra,0x3
    2b3c:	22c080e7          	jalr	556(ra) # 5d64 <printf>
    exit(1);
    2b40:	4505                	li	a0,1
    2b42:	00003097          	auipc	ra,0x3
    2b46:	e90080e7          	jalr	-368(ra) # 59d2 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2b4a:	86d2                	mv	a3,s4
    2b4c:	8626                	mv	a2,s1
    2b4e:	85ce                	mv	a1,s3
    2b50:	00004517          	auipc	a0,0x4
    2b54:	2f850513          	addi	a0,a0,760 # 6e48 <malloc+0x102c>
    2b58:	00003097          	auipc	ra,0x3
    2b5c:	20c080e7          	jalr	524(ra) # 5d64 <printf>
    exit(1);
    2b60:	4505                	li	a0,1
    2b62:	00003097          	auipc	ra,0x3
    2b66:	e70080e7          	jalr	-400(ra) # 59d2 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2b6a:	85ce                	mv	a1,s3
    2b6c:	00004517          	auipc	a0,0x4
    2b70:	30c50513          	addi	a0,a0,780 # 6e78 <malloc+0x105c>
    2b74:	00003097          	auipc	ra,0x3
    2b78:	1f0080e7          	jalr	496(ra) # 5d64 <printf>
    exit(1);
    2b7c:	4505                	li	a0,1
    2b7e:	00003097          	auipc	ra,0x3
    2b82:	e54080e7          	jalr	-428(ra) # 59d2 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2b86:	86aa                	mv	a3,a0
    2b88:	8626                	mv	a2,s1
    2b8a:	85ce                	mv	a1,s3
    2b8c:	00004517          	auipc	a0,0x4
    2b90:	32450513          	addi	a0,a0,804 # 6eb0 <malloc+0x1094>
    2b94:	00003097          	auipc	ra,0x3
    2b98:	1d0080e7          	jalr	464(ra) # 5d64 <printf>
    exit(1);
    2b9c:	4505                	li	a0,1
    2b9e:	00003097          	auipc	ra,0x3
    2ba2:	e34080e7          	jalr	-460(ra) # 59d2 <exit>

0000000000002ba6 <sbrkarg>:
{
    2ba6:	7179                	addi	sp,sp,-48
    2ba8:	f406                	sd	ra,40(sp)
    2baa:	f022                	sd	s0,32(sp)
    2bac:	ec26                	sd	s1,24(sp)
    2bae:	e84a                	sd	s2,16(sp)
    2bb0:	e44e                	sd	s3,8(sp)
    2bb2:	1800                	addi	s0,sp,48
    2bb4:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2bb6:	6505                	lui	a0,0x1
    2bb8:	00003097          	auipc	ra,0x3
    2bbc:	ea2080e7          	jalr	-350(ra) # 5a5a <sbrk>
    2bc0:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE | O_WRONLY);
    2bc2:	20100593          	li	a1,513
    2bc6:	00004517          	auipc	a0,0x4
    2bca:	31250513          	addi	a0,a0,786 # 6ed8 <malloc+0x10bc>
    2bce:	00003097          	auipc	ra,0x3
    2bd2:	e44080e7          	jalr	-444(ra) # 5a12 <open>
    2bd6:	84aa                	mv	s1,a0
  unlink("sbrk");
    2bd8:	00004517          	auipc	a0,0x4
    2bdc:	30050513          	addi	a0,a0,768 # 6ed8 <malloc+0x10bc>
    2be0:	00003097          	auipc	ra,0x3
    2be4:	e42080e7          	jalr	-446(ra) # 5a22 <unlink>
  if (fd < 0)
    2be8:	0404c163          	bltz	s1,2c2a <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0)
    2bec:	6605                	lui	a2,0x1
    2bee:	85ca                	mv	a1,s2
    2bf0:	8526                	mv	a0,s1
    2bf2:	00003097          	auipc	ra,0x3
    2bf6:	e00080e7          	jalr	-512(ra) # 59f2 <write>
    2bfa:	04054663          	bltz	a0,2c46 <sbrkarg+0xa0>
  close(fd);
    2bfe:	8526                	mv	a0,s1
    2c00:	00003097          	auipc	ra,0x3
    2c04:	dfa080e7          	jalr	-518(ra) # 59fa <close>
  a = sbrk(PGSIZE);
    2c08:	6505                	lui	a0,0x1
    2c0a:	00003097          	auipc	ra,0x3
    2c0e:	e50080e7          	jalr	-432(ra) # 5a5a <sbrk>
  if (pipe((int *)a) != 0)
    2c12:	00003097          	auipc	ra,0x3
    2c16:	dd0080e7          	jalr	-560(ra) # 59e2 <pipe>
    2c1a:	e521                	bnez	a0,2c62 <sbrkarg+0xbc>
}
    2c1c:	70a2                	ld	ra,40(sp)
    2c1e:	7402                	ld	s0,32(sp)
    2c20:	64e2                	ld	s1,24(sp)
    2c22:	6942                	ld	s2,16(sp)
    2c24:	69a2                	ld	s3,8(sp)
    2c26:	6145                	addi	sp,sp,48
    2c28:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2c2a:	85ce                	mv	a1,s3
    2c2c:	00004517          	auipc	a0,0x4
    2c30:	2b450513          	addi	a0,a0,692 # 6ee0 <malloc+0x10c4>
    2c34:	00003097          	auipc	ra,0x3
    2c38:	130080e7          	jalr	304(ra) # 5d64 <printf>
    exit(1);
    2c3c:	4505                	li	a0,1
    2c3e:	00003097          	auipc	ra,0x3
    2c42:	d94080e7          	jalr	-620(ra) # 59d2 <exit>
    printf("%s: write sbrk failed\n", s);
    2c46:	85ce                	mv	a1,s3
    2c48:	00004517          	auipc	a0,0x4
    2c4c:	2b050513          	addi	a0,a0,688 # 6ef8 <malloc+0x10dc>
    2c50:	00003097          	auipc	ra,0x3
    2c54:	114080e7          	jalr	276(ra) # 5d64 <printf>
    exit(1);
    2c58:	4505                	li	a0,1
    2c5a:	00003097          	auipc	ra,0x3
    2c5e:	d78080e7          	jalr	-648(ra) # 59d2 <exit>
    printf("%s: pipe() failed\n", s);
    2c62:	85ce                	mv	a1,s3
    2c64:	00004517          	auipc	a0,0x4
    2c68:	c7450513          	addi	a0,a0,-908 # 68d8 <malloc+0xabc>
    2c6c:	00003097          	auipc	ra,0x3
    2c70:	0f8080e7          	jalr	248(ra) # 5d64 <printf>
    exit(1);
    2c74:	4505                	li	a0,1
    2c76:	00003097          	auipc	ra,0x3
    2c7a:	d5c080e7          	jalr	-676(ra) # 59d2 <exit>

0000000000002c7e <argptest>:
{
    2c7e:	1101                	addi	sp,sp,-32
    2c80:	ec06                	sd	ra,24(sp)
    2c82:	e822                	sd	s0,16(sp)
    2c84:	e426                	sd	s1,8(sp)
    2c86:	e04a                	sd	s2,0(sp)
    2c88:	1000                	addi	s0,sp,32
    2c8a:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2c8c:	4581                	li	a1,0
    2c8e:	00004517          	auipc	a0,0x4
    2c92:	28250513          	addi	a0,a0,642 # 6f10 <malloc+0x10f4>
    2c96:	00003097          	auipc	ra,0x3
    2c9a:	d7c080e7          	jalr	-644(ra) # 5a12 <open>
  if (fd < 0)
    2c9e:	02054b63          	bltz	a0,2cd4 <argptest+0x56>
    2ca2:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2ca4:	4501                	li	a0,0
    2ca6:	00003097          	auipc	ra,0x3
    2caa:	db4080e7          	jalr	-588(ra) # 5a5a <sbrk>
    2cae:	567d                	li	a2,-1
    2cb0:	fff50593          	addi	a1,a0,-1
    2cb4:	8526                	mv	a0,s1
    2cb6:	00003097          	auipc	ra,0x3
    2cba:	d34080e7          	jalr	-716(ra) # 59ea <read>
  close(fd);
    2cbe:	8526                	mv	a0,s1
    2cc0:	00003097          	auipc	ra,0x3
    2cc4:	d3a080e7          	jalr	-710(ra) # 59fa <close>
}
    2cc8:	60e2                	ld	ra,24(sp)
    2cca:	6442                	ld	s0,16(sp)
    2ccc:	64a2                	ld	s1,8(sp)
    2cce:	6902                	ld	s2,0(sp)
    2cd0:	6105                	addi	sp,sp,32
    2cd2:	8082                	ret
    printf("%s: open failed\n", s);
    2cd4:	85ca                	mv	a1,s2
    2cd6:	00004517          	auipc	a0,0x4
    2cda:	b1250513          	addi	a0,a0,-1262 # 67e8 <malloc+0x9cc>
    2cde:	00003097          	auipc	ra,0x3
    2ce2:	086080e7          	jalr	134(ra) # 5d64 <printf>
    exit(1);
    2ce6:	4505                	li	a0,1
    2ce8:	00003097          	auipc	ra,0x3
    2cec:	cea080e7          	jalr	-790(ra) # 59d2 <exit>

0000000000002cf0 <sbrkbugs>:
{
    2cf0:	1141                	addi	sp,sp,-16
    2cf2:	e406                	sd	ra,8(sp)
    2cf4:	e022                	sd	s0,0(sp)
    2cf6:	0800                	addi	s0,sp,16
  int pid = fork();
    2cf8:	00003097          	auipc	ra,0x3
    2cfc:	cd2080e7          	jalr	-814(ra) # 59ca <fork>
  if (pid < 0)
    2d00:	02054263          	bltz	a0,2d24 <sbrkbugs+0x34>
  if (pid == 0)
    2d04:	ed0d                	bnez	a0,2d3e <sbrkbugs+0x4e>
    int sz = (uint64)sbrk(0);
    2d06:	00003097          	auipc	ra,0x3
    2d0a:	d54080e7          	jalr	-684(ra) # 5a5a <sbrk>
    sbrk(-sz);
    2d0e:	40a0053b          	negw	a0,a0
    2d12:	00003097          	auipc	ra,0x3
    2d16:	d48080e7          	jalr	-696(ra) # 5a5a <sbrk>
    exit(0);
    2d1a:	4501                	li	a0,0
    2d1c:	00003097          	auipc	ra,0x3
    2d20:	cb6080e7          	jalr	-842(ra) # 59d2 <exit>
    printf("fork failed\n");
    2d24:	00004517          	auipc	a0,0x4
    2d28:	eb450513          	addi	a0,a0,-332 # 6bd8 <malloc+0xdbc>
    2d2c:	00003097          	auipc	ra,0x3
    2d30:	038080e7          	jalr	56(ra) # 5d64 <printf>
    exit(1);
    2d34:	4505                	li	a0,1
    2d36:	00003097          	auipc	ra,0x3
    2d3a:	c9c080e7          	jalr	-868(ra) # 59d2 <exit>
  wait(0);
    2d3e:	4501                	li	a0,0
    2d40:	00003097          	auipc	ra,0x3
    2d44:	c9a080e7          	jalr	-870(ra) # 59da <wait>
  pid = fork();
    2d48:	00003097          	auipc	ra,0x3
    2d4c:	c82080e7          	jalr	-894(ra) # 59ca <fork>
  if (pid < 0)
    2d50:	02054563          	bltz	a0,2d7a <sbrkbugs+0x8a>
  if (pid == 0)
    2d54:	e121                	bnez	a0,2d94 <sbrkbugs+0xa4>
    int sz = (uint64)sbrk(0);
    2d56:	00003097          	auipc	ra,0x3
    2d5a:	d04080e7          	jalr	-764(ra) # 5a5a <sbrk>
    sbrk(-(sz - 3500));
    2d5e:	6785                	lui	a5,0x1
    2d60:	dac7879b          	addiw	a5,a5,-596 # dac <unlinkread+0x4a>
    2d64:	40a7853b          	subw	a0,a5,a0
    2d68:	00003097          	auipc	ra,0x3
    2d6c:	cf2080e7          	jalr	-782(ra) # 5a5a <sbrk>
    exit(0);
    2d70:	4501                	li	a0,0
    2d72:	00003097          	auipc	ra,0x3
    2d76:	c60080e7          	jalr	-928(ra) # 59d2 <exit>
    printf("fork failed\n");
    2d7a:	00004517          	auipc	a0,0x4
    2d7e:	e5e50513          	addi	a0,a0,-418 # 6bd8 <malloc+0xdbc>
    2d82:	00003097          	auipc	ra,0x3
    2d86:	fe2080e7          	jalr	-30(ra) # 5d64 <printf>
    exit(1);
    2d8a:	4505                	li	a0,1
    2d8c:	00003097          	auipc	ra,0x3
    2d90:	c46080e7          	jalr	-954(ra) # 59d2 <exit>
  wait(0);
    2d94:	4501                	li	a0,0
    2d96:	00003097          	auipc	ra,0x3
    2d9a:	c44080e7          	jalr	-956(ra) # 59da <wait>
  pid = fork();
    2d9e:	00003097          	auipc	ra,0x3
    2da2:	c2c080e7          	jalr	-980(ra) # 59ca <fork>
  if (pid < 0)
    2da6:	02054a63          	bltz	a0,2dda <sbrkbugs+0xea>
  if (pid == 0)
    2daa:	e529                	bnez	a0,2df4 <sbrkbugs+0x104>
    sbrk((10 * 4096 + 2048) - (uint64)sbrk(0));
    2dac:	00003097          	auipc	ra,0x3
    2db0:	cae080e7          	jalr	-850(ra) # 5a5a <sbrk>
    2db4:	67ad                	lui	a5,0xb
    2db6:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x298>
    2dba:	40a7853b          	subw	a0,a5,a0
    2dbe:	00003097          	auipc	ra,0x3
    2dc2:	c9c080e7          	jalr	-868(ra) # 5a5a <sbrk>
    sbrk(-10);
    2dc6:	5559                	li	a0,-10
    2dc8:	00003097          	auipc	ra,0x3
    2dcc:	c92080e7          	jalr	-878(ra) # 5a5a <sbrk>
    exit(0);
    2dd0:	4501                	li	a0,0
    2dd2:	00003097          	auipc	ra,0x3
    2dd6:	c00080e7          	jalr	-1024(ra) # 59d2 <exit>
    printf("fork failed\n");
    2dda:	00004517          	auipc	a0,0x4
    2dde:	dfe50513          	addi	a0,a0,-514 # 6bd8 <malloc+0xdbc>
    2de2:	00003097          	auipc	ra,0x3
    2de6:	f82080e7          	jalr	-126(ra) # 5d64 <printf>
    exit(1);
    2dea:	4505                	li	a0,1
    2dec:	00003097          	auipc	ra,0x3
    2df0:	be6080e7          	jalr	-1050(ra) # 59d2 <exit>
  wait(0);
    2df4:	4501                	li	a0,0
    2df6:	00003097          	auipc	ra,0x3
    2dfa:	be4080e7          	jalr	-1052(ra) # 59da <wait>
  exit(0);
    2dfe:	4501                	li	a0,0
    2e00:	00003097          	auipc	ra,0x3
    2e04:	bd2080e7          	jalr	-1070(ra) # 59d2 <exit>

0000000000002e08 <sbrklast>:
{
    2e08:	7179                	addi	sp,sp,-48
    2e0a:	f406                	sd	ra,40(sp)
    2e0c:	f022                	sd	s0,32(sp)
    2e0e:	ec26                	sd	s1,24(sp)
    2e10:	e84a                	sd	s2,16(sp)
    2e12:	e44e                	sd	s3,8(sp)
    2e14:	e052                	sd	s4,0(sp)
    2e16:	1800                	addi	s0,sp,48
  uint64 top = (uint64)sbrk(0);
    2e18:	4501                	li	a0,0
    2e1a:	00003097          	auipc	ra,0x3
    2e1e:	c40080e7          	jalr	-960(ra) # 5a5a <sbrk>
  if ((top % 4096) != 0)
    2e22:	03451793          	slli	a5,a0,0x34
    2e26:	ebd9                	bnez	a5,2ebc <sbrklast+0xb4>
  sbrk(4096);
    2e28:	6505                	lui	a0,0x1
    2e2a:	00003097          	auipc	ra,0x3
    2e2e:	c30080e7          	jalr	-976(ra) # 5a5a <sbrk>
  sbrk(10);
    2e32:	4529                	li	a0,10
    2e34:	00003097          	auipc	ra,0x3
    2e38:	c26080e7          	jalr	-986(ra) # 5a5a <sbrk>
  sbrk(-20);
    2e3c:	5531                	li	a0,-20
    2e3e:	00003097          	auipc	ra,0x3
    2e42:	c1c080e7          	jalr	-996(ra) # 5a5a <sbrk>
  top = (uint64)sbrk(0);
    2e46:	4501                	li	a0,0
    2e48:	00003097          	auipc	ra,0x3
    2e4c:	c12080e7          	jalr	-1006(ra) # 5a5a <sbrk>
    2e50:	84aa                	mv	s1,a0
  char *p = (char *)(top - 64);
    2e52:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0xa8>
  p[0] = 'x';
    2e56:	07800a13          	li	s4,120
    2e5a:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2e5e:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR | O_CREATE);
    2e62:	20200593          	li	a1,514
    2e66:	854a                	mv	a0,s2
    2e68:	00003097          	auipc	ra,0x3
    2e6c:	baa080e7          	jalr	-1110(ra) # 5a12 <open>
    2e70:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2e72:	4605                	li	a2,1
    2e74:	85ca                	mv	a1,s2
    2e76:	00003097          	auipc	ra,0x3
    2e7a:	b7c080e7          	jalr	-1156(ra) # 59f2 <write>
  close(fd);
    2e7e:	854e                	mv	a0,s3
    2e80:	00003097          	auipc	ra,0x3
    2e84:	b7a080e7          	jalr	-1158(ra) # 59fa <close>
  fd = open(p, O_RDWR);
    2e88:	4589                	li	a1,2
    2e8a:	854a                	mv	a0,s2
    2e8c:	00003097          	auipc	ra,0x3
    2e90:	b86080e7          	jalr	-1146(ra) # 5a12 <open>
  p[0] = '\0';
    2e94:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2e98:	4605                	li	a2,1
    2e9a:	85ca                	mv	a1,s2
    2e9c:	00003097          	auipc	ra,0x3
    2ea0:	b4e080e7          	jalr	-1202(ra) # 59ea <read>
  if (p[0] != 'x')
    2ea4:	fc04c783          	lbu	a5,-64(s1)
    2ea8:	03479463          	bne	a5,s4,2ed0 <sbrklast+0xc8>
}
    2eac:	70a2                	ld	ra,40(sp)
    2eae:	7402                	ld	s0,32(sp)
    2eb0:	64e2                	ld	s1,24(sp)
    2eb2:	6942                	ld	s2,16(sp)
    2eb4:	69a2                	ld	s3,8(sp)
    2eb6:	6a02                	ld	s4,0(sp)
    2eb8:	6145                	addi	sp,sp,48
    2eba:	8082                	ret
    sbrk(4096 - (top % 4096));
    2ebc:	0347d513          	srli	a0,a5,0x34
    2ec0:	6785                	lui	a5,0x1
    2ec2:	40a7853b          	subw	a0,a5,a0
    2ec6:	00003097          	auipc	ra,0x3
    2eca:	b94080e7          	jalr	-1132(ra) # 5a5a <sbrk>
    2ece:	bfa9                	j	2e28 <sbrklast+0x20>
    exit(1);
    2ed0:	4505                	li	a0,1
    2ed2:	00003097          	auipc	ra,0x3
    2ed6:	b00080e7          	jalr	-1280(ra) # 59d2 <exit>

0000000000002eda <sbrk8000>:
{
    2eda:	1141                	addi	sp,sp,-16
    2edc:	e406                	sd	ra,8(sp)
    2ede:	e022                	sd	s0,0(sp)
    2ee0:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2ee2:	80000537          	lui	a0,0x80000
    2ee6:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff038c>
    2ee8:	00003097          	auipc	ra,0x3
    2eec:	b72080e7          	jalr	-1166(ra) # 5a5a <sbrk>
  volatile char *top = sbrk(0);
    2ef0:	4501                	li	a0,0
    2ef2:	00003097          	auipc	ra,0x3
    2ef6:	b68080e7          	jalr	-1176(ra) # 5a5a <sbrk>
  *(top - 1) = *(top - 1) + 1;
    2efa:	fff54783          	lbu	a5,-1(a0)
    2efe:	2785                	addiw	a5,a5,1 # 1001 <linktest+0xe9>
    2f00:	0ff7f793          	zext.b	a5,a5
    2f04:	fef50fa3          	sb	a5,-1(a0)
}
    2f08:	60a2                	ld	ra,8(sp)
    2f0a:	6402                	ld	s0,0(sp)
    2f0c:	0141                	addi	sp,sp,16
    2f0e:	8082                	ret

0000000000002f10 <execout>:
{
    2f10:	715d                	addi	sp,sp,-80
    2f12:	e486                	sd	ra,72(sp)
    2f14:	e0a2                	sd	s0,64(sp)
    2f16:	fc26                	sd	s1,56(sp)
    2f18:	f84a                	sd	s2,48(sp)
    2f1a:	f44e                	sd	s3,40(sp)
    2f1c:	f052                	sd	s4,32(sp)
    2f1e:	0880                	addi	s0,sp,80
  for (int avail = 0; avail < 15; avail++)
    2f20:	4901                	li	s2,0
    2f22:	49bd                	li	s3,15
    int pid = fork();
    2f24:	00003097          	auipc	ra,0x3
    2f28:	aa6080e7          	jalr	-1370(ra) # 59ca <fork>
    2f2c:	84aa                	mv	s1,a0
    if (pid < 0)
    2f2e:	02054063          	bltz	a0,2f4e <execout+0x3e>
    else if (pid == 0)
    2f32:	c91d                	beqz	a0,2f68 <execout+0x58>
      wait((int *)0);
    2f34:	4501                	li	a0,0
    2f36:	00003097          	auipc	ra,0x3
    2f3a:	aa4080e7          	jalr	-1372(ra) # 59da <wait>
  for (int avail = 0; avail < 15; avail++)
    2f3e:	2905                	addiw	s2,s2,1
    2f40:	ff3912e3          	bne	s2,s3,2f24 <execout+0x14>
  exit(0);
    2f44:	4501                	li	a0,0
    2f46:	00003097          	auipc	ra,0x3
    2f4a:	a8c080e7          	jalr	-1396(ra) # 59d2 <exit>
      printf("fork failed\n");
    2f4e:	00004517          	auipc	a0,0x4
    2f52:	c8a50513          	addi	a0,a0,-886 # 6bd8 <malloc+0xdbc>
    2f56:	00003097          	auipc	ra,0x3
    2f5a:	e0e080e7          	jalr	-498(ra) # 5d64 <printf>
      exit(1);
    2f5e:	4505                	li	a0,1
    2f60:	00003097          	auipc	ra,0x3
    2f64:	a72080e7          	jalr	-1422(ra) # 59d2 <exit>
        if (a == 0xffffffffffffffffLL)
    2f68:	59fd                	li	s3,-1
        *(char *)(a + 4096 - 1) = 1;
    2f6a:	4a05                	li	s4,1
        uint64 a = (uint64)sbrk(4096);
    2f6c:	6505                	lui	a0,0x1
    2f6e:	00003097          	auipc	ra,0x3
    2f72:	aec080e7          	jalr	-1300(ra) # 5a5a <sbrk>
        if (a == 0xffffffffffffffffLL)
    2f76:	01350763          	beq	a0,s3,2f84 <execout+0x74>
        *(char *)(a + 4096 - 1) = 1;
    2f7a:	6785                	lui	a5,0x1
    2f7c:	97aa                	add	a5,a5,a0
    2f7e:	ff478fa3          	sb	s4,-1(a5) # fff <linktest+0xe7>
      {
    2f82:	b7ed                	j	2f6c <execout+0x5c>
      for (int i = 0; i < avail; i++)
    2f84:	01205a63          	blez	s2,2f98 <execout+0x88>
        sbrk(-4096);
    2f88:	757d                	lui	a0,0xfffff
    2f8a:	00003097          	auipc	ra,0x3
    2f8e:	ad0080e7          	jalr	-1328(ra) # 5a5a <sbrk>
      for (int i = 0; i < avail; i++)
    2f92:	2485                	addiw	s1,s1,1
    2f94:	ff249ae3          	bne	s1,s2,2f88 <execout+0x78>
      close(1);
    2f98:	4505                	li	a0,1
    2f9a:	00003097          	auipc	ra,0x3
    2f9e:	a60080e7          	jalr	-1440(ra) # 59fa <close>
      char *args[] = {"echo", "x", 0};
    2fa2:	00003517          	auipc	a0,0x3
    2fa6:	fa650513          	addi	a0,a0,-90 # 5f48 <malloc+0x12c>
    2faa:	faa43c23          	sd	a0,-72(s0)
    2fae:	00003797          	auipc	a5,0x3
    2fb2:	00a78793          	addi	a5,a5,10 # 5fb8 <malloc+0x19c>
    2fb6:	fcf43023          	sd	a5,-64(s0)
    2fba:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2fbe:	fb840593          	addi	a1,s0,-72
    2fc2:	00003097          	auipc	ra,0x3
    2fc6:	a48080e7          	jalr	-1464(ra) # 5a0a <exec>
      exit(0);
    2fca:	4501                	li	a0,0
    2fcc:	00003097          	auipc	ra,0x3
    2fd0:	a06080e7          	jalr	-1530(ra) # 59d2 <exit>

0000000000002fd4 <fourteen>:
{
    2fd4:	1101                	addi	sp,sp,-32
    2fd6:	ec06                	sd	ra,24(sp)
    2fd8:	e822                	sd	s0,16(sp)
    2fda:	e426                	sd	s1,8(sp)
    2fdc:	1000                	addi	s0,sp,32
    2fde:	84aa                	mv	s1,a0
  if (mkdir("12345678901234") != 0)
    2fe0:	00004517          	auipc	a0,0x4
    2fe4:	10850513          	addi	a0,a0,264 # 70e8 <malloc+0x12cc>
    2fe8:	00003097          	auipc	ra,0x3
    2fec:	a52080e7          	jalr	-1454(ra) # 5a3a <mkdir>
    2ff0:	e165                	bnez	a0,30d0 <fourteen+0xfc>
  if (mkdir("12345678901234/123456789012345") != 0)
    2ff2:	00004517          	auipc	a0,0x4
    2ff6:	f4e50513          	addi	a0,a0,-178 # 6f40 <malloc+0x1124>
    2ffa:	00003097          	auipc	ra,0x3
    2ffe:	a40080e7          	jalr	-1472(ra) # 5a3a <mkdir>
    3002:	e56d                	bnez	a0,30ec <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3004:	20000593          	li	a1,512
    3008:	00004517          	auipc	a0,0x4
    300c:	f9050513          	addi	a0,a0,-112 # 6f98 <malloc+0x117c>
    3010:	00003097          	auipc	ra,0x3
    3014:	a02080e7          	jalr	-1534(ra) # 5a12 <open>
  if (fd < 0)
    3018:	0e054863          	bltz	a0,3108 <fourteen+0x134>
  close(fd);
    301c:	00003097          	auipc	ra,0x3
    3020:	9de080e7          	jalr	-1570(ra) # 59fa <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3024:	4581                	li	a1,0
    3026:	00004517          	auipc	a0,0x4
    302a:	fea50513          	addi	a0,a0,-22 # 7010 <malloc+0x11f4>
    302e:	00003097          	auipc	ra,0x3
    3032:	9e4080e7          	jalr	-1564(ra) # 5a12 <open>
  if (fd < 0)
    3036:	0e054763          	bltz	a0,3124 <fourteen+0x150>
  close(fd);
    303a:	00003097          	auipc	ra,0x3
    303e:	9c0080e7          	jalr	-1600(ra) # 59fa <close>
  if (mkdir("12345678901234/12345678901234") == 0)
    3042:	00004517          	auipc	a0,0x4
    3046:	03e50513          	addi	a0,a0,62 # 7080 <malloc+0x1264>
    304a:	00003097          	auipc	ra,0x3
    304e:	9f0080e7          	jalr	-1552(ra) # 5a3a <mkdir>
    3052:	c57d                	beqz	a0,3140 <fourteen+0x16c>
  if (mkdir("123456789012345/12345678901234") == 0)
    3054:	00004517          	auipc	a0,0x4
    3058:	08450513          	addi	a0,a0,132 # 70d8 <malloc+0x12bc>
    305c:	00003097          	auipc	ra,0x3
    3060:	9de080e7          	jalr	-1570(ra) # 5a3a <mkdir>
    3064:	cd65                	beqz	a0,315c <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    3066:	00004517          	auipc	a0,0x4
    306a:	07250513          	addi	a0,a0,114 # 70d8 <malloc+0x12bc>
    306e:	00003097          	auipc	ra,0x3
    3072:	9b4080e7          	jalr	-1612(ra) # 5a22 <unlink>
  unlink("12345678901234/12345678901234");
    3076:	00004517          	auipc	a0,0x4
    307a:	00a50513          	addi	a0,a0,10 # 7080 <malloc+0x1264>
    307e:	00003097          	auipc	ra,0x3
    3082:	9a4080e7          	jalr	-1628(ra) # 5a22 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    3086:	00004517          	auipc	a0,0x4
    308a:	f8a50513          	addi	a0,a0,-118 # 7010 <malloc+0x11f4>
    308e:	00003097          	auipc	ra,0x3
    3092:	994080e7          	jalr	-1644(ra) # 5a22 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    3096:	00004517          	auipc	a0,0x4
    309a:	f0250513          	addi	a0,a0,-254 # 6f98 <malloc+0x117c>
    309e:	00003097          	auipc	ra,0x3
    30a2:	984080e7          	jalr	-1660(ra) # 5a22 <unlink>
  unlink("12345678901234/123456789012345");
    30a6:	00004517          	auipc	a0,0x4
    30aa:	e9a50513          	addi	a0,a0,-358 # 6f40 <malloc+0x1124>
    30ae:	00003097          	auipc	ra,0x3
    30b2:	974080e7          	jalr	-1676(ra) # 5a22 <unlink>
  unlink("12345678901234");
    30b6:	00004517          	auipc	a0,0x4
    30ba:	03250513          	addi	a0,a0,50 # 70e8 <malloc+0x12cc>
    30be:	00003097          	auipc	ra,0x3
    30c2:	964080e7          	jalr	-1692(ra) # 5a22 <unlink>
}
    30c6:	60e2                	ld	ra,24(sp)
    30c8:	6442                	ld	s0,16(sp)
    30ca:	64a2                	ld	s1,8(sp)
    30cc:	6105                	addi	sp,sp,32
    30ce:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    30d0:	85a6                	mv	a1,s1
    30d2:	00004517          	auipc	a0,0x4
    30d6:	e4650513          	addi	a0,a0,-442 # 6f18 <malloc+0x10fc>
    30da:	00003097          	auipc	ra,0x3
    30de:	c8a080e7          	jalr	-886(ra) # 5d64 <printf>
    exit(1);
    30e2:	4505                	li	a0,1
    30e4:	00003097          	auipc	ra,0x3
    30e8:	8ee080e7          	jalr	-1810(ra) # 59d2 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    30ec:	85a6                	mv	a1,s1
    30ee:	00004517          	auipc	a0,0x4
    30f2:	e7250513          	addi	a0,a0,-398 # 6f60 <malloc+0x1144>
    30f6:	00003097          	auipc	ra,0x3
    30fa:	c6e080e7          	jalr	-914(ra) # 5d64 <printf>
    exit(1);
    30fe:	4505                	li	a0,1
    3100:	00003097          	auipc	ra,0x3
    3104:	8d2080e7          	jalr	-1838(ra) # 59d2 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    3108:	85a6                	mv	a1,s1
    310a:	00004517          	auipc	a0,0x4
    310e:	ebe50513          	addi	a0,a0,-322 # 6fc8 <malloc+0x11ac>
    3112:	00003097          	auipc	ra,0x3
    3116:	c52080e7          	jalr	-942(ra) # 5d64 <printf>
    exit(1);
    311a:	4505                	li	a0,1
    311c:	00003097          	auipc	ra,0x3
    3120:	8b6080e7          	jalr	-1866(ra) # 59d2 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    3124:	85a6                	mv	a1,s1
    3126:	00004517          	auipc	a0,0x4
    312a:	f1a50513          	addi	a0,a0,-230 # 7040 <malloc+0x1224>
    312e:	00003097          	auipc	ra,0x3
    3132:	c36080e7          	jalr	-970(ra) # 5d64 <printf>
    exit(1);
    3136:	4505                	li	a0,1
    3138:	00003097          	auipc	ra,0x3
    313c:	89a080e7          	jalr	-1894(ra) # 59d2 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    3140:	85a6                	mv	a1,s1
    3142:	00004517          	auipc	a0,0x4
    3146:	f5e50513          	addi	a0,a0,-162 # 70a0 <malloc+0x1284>
    314a:	00003097          	auipc	ra,0x3
    314e:	c1a080e7          	jalr	-998(ra) # 5d64 <printf>
    exit(1);
    3152:	4505                	li	a0,1
    3154:	00003097          	auipc	ra,0x3
    3158:	87e080e7          	jalr	-1922(ra) # 59d2 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    315c:	85a6                	mv	a1,s1
    315e:	00004517          	auipc	a0,0x4
    3162:	f9a50513          	addi	a0,a0,-102 # 70f8 <malloc+0x12dc>
    3166:	00003097          	auipc	ra,0x3
    316a:	bfe080e7          	jalr	-1026(ra) # 5d64 <printf>
    exit(1);
    316e:	4505                	li	a0,1
    3170:	00003097          	auipc	ra,0x3
    3174:	862080e7          	jalr	-1950(ra) # 59d2 <exit>

0000000000003178 <diskfull>:
{
    3178:	b9010113          	addi	sp,sp,-1136
    317c:	46113423          	sd	ra,1128(sp)
    3180:	46813023          	sd	s0,1120(sp)
    3184:	44913c23          	sd	s1,1112(sp)
    3188:	45213823          	sd	s2,1104(sp)
    318c:	45313423          	sd	s3,1096(sp)
    3190:	45413023          	sd	s4,1088(sp)
    3194:	43513c23          	sd	s5,1080(sp)
    3198:	43613823          	sd	s6,1072(sp)
    319c:	43713423          	sd	s7,1064(sp)
    31a0:	43813023          	sd	s8,1056(sp)
    31a4:	47010413          	addi	s0,sp,1136
    31a8:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
    31aa:	00004517          	auipc	a0,0x4
    31ae:	f8650513          	addi	a0,a0,-122 # 7130 <malloc+0x1314>
    31b2:	00003097          	auipc	ra,0x3
    31b6:	870080e7          	jalr	-1936(ra) # 5a22 <unlink>
  for (fi = 0; done == 0; fi++)
    31ba:	4a01                	li	s4,0
    name[0] = 'b';
    31bc:	06200b13          	li	s6,98
    name[1] = 'i';
    31c0:	06900a93          	li	s5,105
    name[2] = 'g';
    31c4:	06700993          	li	s3,103
    31c8:	10c00b93          	li	s7,268
    31cc:	aabd                	j	334a <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
    31ce:	b9040613          	addi	a2,s0,-1136
    31d2:	85e2                	mv	a1,s8
    31d4:	00004517          	auipc	a0,0x4
    31d8:	f6c50513          	addi	a0,a0,-148 # 7140 <malloc+0x1324>
    31dc:	00003097          	auipc	ra,0x3
    31e0:	b88080e7          	jalr	-1144(ra) # 5d64 <printf>
      break;
    31e4:	a821                	j	31fc <diskfull+0x84>
        close(fd);
    31e6:	854a                	mv	a0,s2
    31e8:	00003097          	auipc	ra,0x3
    31ec:	812080e7          	jalr	-2030(ra) # 59fa <close>
    close(fd);
    31f0:	854a                	mv	a0,s2
    31f2:	00003097          	auipc	ra,0x3
    31f6:	808080e7          	jalr	-2040(ra) # 59fa <close>
  for (fi = 0; done == 0; fi++)
    31fa:	2a05                	addiw	s4,s4,1
  for (int i = 0; i < nzz; i++)
    31fc:	4481                	li	s1,0
    name[0] = 'z';
    31fe:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
    3202:	08000993          	li	s3,128
    name[0] = 'z';
    3206:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    320a:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    320e:	41f4d71b          	sraiw	a4,s1,0x1f
    3212:	01b7571b          	srliw	a4,a4,0x1b
    3216:	009707bb          	addw	a5,a4,s1
    321a:	4057d69b          	sraiw	a3,a5,0x5
    321e:	0306869b          	addiw	a3,a3,48
    3222:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3226:	8bfd                	andi	a5,a5,31
    3228:	9f99                	subw	a5,a5,a4
    322a:	0307879b          	addiw	a5,a5,48
    322e:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3232:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3236:	bb040513          	addi	a0,s0,-1104
    323a:	00002097          	auipc	ra,0x2
    323e:	7e8080e7          	jalr	2024(ra) # 5a22 <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    3242:	60200593          	li	a1,1538
    3246:	bb040513          	addi	a0,s0,-1104
    324a:	00002097          	auipc	ra,0x2
    324e:	7c8080e7          	jalr	1992(ra) # 5a12 <open>
    if (fd < 0)
    3252:	00054963          	bltz	a0,3264 <diskfull+0xec>
    close(fd);
    3256:	00002097          	auipc	ra,0x2
    325a:	7a4080e7          	jalr	1956(ra) # 59fa <close>
  for (int i = 0; i < nzz; i++)
    325e:	2485                	addiw	s1,s1,1
    3260:	fb3493e3          	bne	s1,s3,3206 <diskfull+0x8e>
  if (mkdir("diskfulldir") == 0)
    3264:	00004517          	auipc	a0,0x4
    3268:	ecc50513          	addi	a0,a0,-308 # 7130 <malloc+0x1314>
    326c:	00002097          	auipc	ra,0x2
    3270:	7ce080e7          	jalr	1998(ra) # 5a3a <mkdir>
    3274:	12050963          	beqz	a0,33a6 <diskfull+0x22e>
  unlink("diskfulldir");
    3278:	00004517          	auipc	a0,0x4
    327c:	eb850513          	addi	a0,a0,-328 # 7130 <malloc+0x1314>
    3280:	00002097          	auipc	ra,0x2
    3284:	7a2080e7          	jalr	1954(ra) # 5a22 <unlink>
  for (int i = 0; i < nzz; i++)
    3288:	4481                	li	s1,0
    name[0] = 'z';
    328a:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
    328e:	08000993          	li	s3,128
    name[0] = 'z';
    3292:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    3296:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    329a:	41f4d71b          	sraiw	a4,s1,0x1f
    329e:	01b7571b          	srliw	a4,a4,0x1b
    32a2:	009707bb          	addw	a5,a4,s1
    32a6:	4057d69b          	sraiw	a3,a5,0x5
    32aa:	0306869b          	addiw	a3,a3,48
    32ae:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    32b2:	8bfd                	andi	a5,a5,31
    32b4:	9f99                	subw	a5,a5,a4
    32b6:	0307879b          	addiw	a5,a5,48
    32ba:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    32be:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    32c2:	bb040513          	addi	a0,s0,-1104
    32c6:	00002097          	auipc	ra,0x2
    32ca:	75c080e7          	jalr	1884(ra) # 5a22 <unlink>
  for (int i = 0; i < nzz; i++)
    32ce:	2485                	addiw	s1,s1,1
    32d0:	fd3491e3          	bne	s1,s3,3292 <diskfull+0x11a>
  for (int i = 0; i < fi; i++)
    32d4:	03405e63          	blez	s4,3310 <diskfull+0x198>
    32d8:	4481                	li	s1,0
    name[0] = 'b';
    32da:	06200a93          	li	s5,98
    name[1] = 'i';
    32de:	06900993          	li	s3,105
    name[2] = 'g';
    32e2:	06700913          	li	s2,103
    name[0] = 'b';
    32e6:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    32ea:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    32ee:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    32f2:	0304879b          	addiw	a5,s1,48
    32f6:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    32fa:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    32fe:	bb040513          	addi	a0,s0,-1104
    3302:	00002097          	auipc	ra,0x2
    3306:	720080e7          	jalr	1824(ra) # 5a22 <unlink>
  for (int i = 0; i < fi; i++)
    330a:	2485                	addiw	s1,s1,1
    330c:	fd449de3          	bne	s1,s4,32e6 <diskfull+0x16e>
}
    3310:	46813083          	ld	ra,1128(sp)
    3314:	46013403          	ld	s0,1120(sp)
    3318:	45813483          	ld	s1,1112(sp)
    331c:	45013903          	ld	s2,1104(sp)
    3320:	44813983          	ld	s3,1096(sp)
    3324:	44013a03          	ld	s4,1088(sp)
    3328:	43813a83          	ld	s5,1080(sp)
    332c:	43013b03          	ld	s6,1072(sp)
    3330:	42813b83          	ld	s7,1064(sp)
    3334:	42013c03          	ld	s8,1056(sp)
    3338:	47010113          	addi	sp,sp,1136
    333c:	8082                	ret
    close(fd);
    333e:	854a                	mv	a0,s2
    3340:	00002097          	auipc	ra,0x2
    3344:	6ba080e7          	jalr	1722(ra) # 59fa <close>
  for (fi = 0; done == 0; fi++)
    3348:	2a05                	addiw	s4,s4,1
    name[0] = 'b';
    334a:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    334e:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    3352:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    3356:	030a079b          	addiw	a5,s4,48
    335a:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    335e:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    3362:	b9040513          	addi	a0,s0,-1136
    3366:	00002097          	auipc	ra,0x2
    336a:	6bc080e7          	jalr	1724(ra) # 5a22 <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    336e:	60200593          	li	a1,1538
    3372:	b9040513          	addi	a0,s0,-1136
    3376:	00002097          	auipc	ra,0x2
    337a:	69c080e7          	jalr	1692(ra) # 5a12 <open>
    337e:	892a                	mv	s2,a0
    if (fd < 0)
    3380:	e40547e3          	bltz	a0,31ce <diskfull+0x56>
    3384:	84de                	mv	s1,s7
      if (write(fd, buf, BSIZE) != BSIZE)
    3386:	40000613          	li	a2,1024
    338a:	bb040593          	addi	a1,s0,-1104
    338e:	854a                	mv	a0,s2
    3390:	00002097          	auipc	ra,0x2
    3394:	662080e7          	jalr	1634(ra) # 59f2 <write>
    3398:	40000793          	li	a5,1024
    339c:	e4f515e3          	bne	a0,a5,31e6 <diskfull+0x6e>
    for (int i = 0; i < MAXFILE; i++)
    33a0:	34fd                	addiw	s1,s1,-1
    33a2:	f0f5                	bnez	s1,3386 <diskfull+0x20e>
    33a4:	bf69                	j	333e <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    33a6:	00004517          	auipc	a0,0x4
    33aa:	dba50513          	addi	a0,a0,-582 # 7160 <malloc+0x1344>
    33ae:	00003097          	auipc	ra,0x3
    33b2:	9b6080e7          	jalr	-1610(ra) # 5d64 <printf>
    33b6:	b5c9                	j	3278 <diskfull+0x100>

00000000000033b8 <iputtest>:
{
    33b8:	1101                	addi	sp,sp,-32
    33ba:	ec06                	sd	ra,24(sp)
    33bc:	e822                	sd	s0,16(sp)
    33be:	e426                	sd	s1,8(sp)
    33c0:	1000                	addi	s0,sp,32
    33c2:	84aa                	mv	s1,a0
  if (mkdir("iputdir") < 0)
    33c4:	00004517          	auipc	a0,0x4
    33c8:	dcc50513          	addi	a0,a0,-564 # 7190 <malloc+0x1374>
    33cc:	00002097          	auipc	ra,0x2
    33d0:	66e080e7          	jalr	1646(ra) # 5a3a <mkdir>
    33d4:	04054563          	bltz	a0,341e <iputtest+0x66>
  if (chdir("iputdir") < 0)
    33d8:	00004517          	auipc	a0,0x4
    33dc:	db850513          	addi	a0,a0,-584 # 7190 <malloc+0x1374>
    33e0:	00002097          	auipc	ra,0x2
    33e4:	662080e7          	jalr	1634(ra) # 5a42 <chdir>
    33e8:	04054963          	bltz	a0,343a <iputtest+0x82>
  if (unlink("../iputdir") < 0)
    33ec:	00004517          	auipc	a0,0x4
    33f0:	de450513          	addi	a0,a0,-540 # 71d0 <malloc+0x13b4>
    33f4:	00002097          	auipc	ra,0x2
    33f8:	62e080e7          	jalr	1582(ra) # 5a22 <unlink>
    33fc:	04054d63          	bltz	a0,3456 <iputtest+0x9e>
  if (chdir("/") < 0)
    3400:	00004517          	auipc	a0,0x4
    3404:	e0050513          	addi	a0,a0,-512 # 7200 <malloc+0x13e4>
    3408:	00002097          	auipc	ra,0x2
    340c:	63a080e7          	jalr	1594(ra) # 5a42 <chdir>
    3410:	06054163          	bltz	a0,3472 <iputtest+0xba>
}
    3414:	60e2                	ld	ra,24(sp)
    3416:	6442                	ld	s0,16(sp)
    3418:	64a2                	ld	s1,8(sp)
    341a:	6105                	addi	sp,sp,32
    341c:	8082                	ret
    printf("%s: mkdir failed\n", s);
    341e:	85a6                	mv	a1,s1
    3420:	00004517          	auipc	a0,0x4
    3424:	d7850513          	addi	a0,a0,-648 # 7198 <malloc+0x137c>
    3428:	00003097          	auipc	ra,0x3
    342c:	93c080e7          	jalr	-1732(ra) # 5d64 <printf>
    exit(1);
    3430:	4505                	li	a0,1
    3432:	00002097          	auipc	ra,0x2
    3436:	5a0080e7          	jalr	1440(ra) # 59d2 <exit>
    printf("%s: chdir iputdir failed\n", s);
    343a:	85a6                	mv	a1,s1
    343c:	00004517          	auipc	a0,0x4
    3440:	d7450513          	addi	a0,a0,-652 # 71b0 <malloc+0x1394>
    3444:	00003097          	auipc	ra,0x3
    3448:	920080e7          	jalr	-1760(ra) # 5d64 <printf>
    exit(1);
    344c:	4505                	li	a0,1
    344e:	00002097          	auipc	ra,0x2
    3452:	584080e7          	jalr	1412(ra) # 59d2 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    3456:	85a6                	mv	a1,s1
    3458:	00004517          	auipc	a0,0x4
    345c:	d8850513          	addi	a0,a0,-632 # 71e0 <malloc+0x13c4>
    3460:	00003097          	auipc	ra,0x3
    3464:	904080e7          	jalr	-1788(ra) # 5d64 <printf>
    exit(1);
    3468:	4505                	li	a0,1
    346a:	00002097          	auipc	ra,0x2
    346e:	568080e7          	jalr	1384(ra) # 59d2 <exit>
    printf("%s: chdir / failed\n", s);
    3472:	85a6                	mv	a1,s1
    3474:	00004517          	auipc	a0,0x4
    3478:	d9450513          	addi	a0,a0,-620 # 7208 <malloc+0x13ec>
    347c:	00003097          	auipc	ra,0x3
    3480:	8e8080e7          	jalr	-1816(ra) # 5d64 <printf>
    exit(1);
    3484:	4505                	li	a0,1
    3486:	00002097          	auipc	ra,0x2
    348a:	54c080e7          	jalr	1356(ra) # 59d2 <exit>

000000000000348e <exitiputtest>:
{
    348e:	7179                	addi	sp,sp,-48
    3490:	f406                	sd	ra,40(sp)
    3492:	f022                	sd	s0,32(sp)
    3494:	ec26                	sd	s1,24(sp)
    3496:	1800                	addi	s0,sp,48
    3498:	84aa                	mv	s1,a0
  pid = fork();
    349a:	00002097          	auipc	ra,0x2
    349e:	530080e7          	jalr	1328(ra) # 59ca <fork>
  if (pid < 0)
    34a2:	04054663          	bltz	a0,34ee <exitiputtest+0x60>
  if (pid == 0)
    34a6:	ed45                	bnez	a0,355e <exitiputtest+0xd0>
    if (mkdir("iputdir") < 0)
    34a8:	00004517          	auipc	a0,0x4
    34ac:	ce850513          	addi	a0,a0,-792 # 7190 <malloc+0x1374>
    34b0:	00002097          	auipc	ra,0x2
    34b4:	58a080e7          	jalr	1418(ra) # 5a3a <mkdir>
    34b8:	04054963          	bltz	a0,350a <exitiputtest+0x7c>
    if (chdir("iputdir") < 0)
    34bc:	00004517          	auipc	a0,0x4
    34c0:	cd450513          	addi	a0,a0,-812 # 7190 <malloc+0x1374>
    34c4:	00002097          	auipc	ra,0x2
    34c8:	57e080e7          	jalr	1406(ra) # 5a42 <chdir>
    34cc:	04054d63          	bltz	a0,3526 <exitiputtest+0x98>
    if (unlink("../iputdir") < 0)
    34d0:	00004517          	auipc	a0,0x4
    34d4:	d0050513          	addi	a0,a0,-768 # 71d0 <malloc+0x13b4>
    34d8:	00002097          	auipc	ra,0x2
    34dc:	54a080e7          	jalr	1354(ra) # 5a22 <unlink>
    34e0:	06054163          	bltz	a0,3542 <exitiputtest+0xb4>
    exit(0);
    34e4:	4501                	li	a0,0
    34e6:	00002097          	auipc	ra,0x2
    34ea:	4ec080e7          	jalr	1260(ra) # 59d2 <exit>
    printf("%s: fork failed\n", s);
    34ee:	85a6                	mv	a1,s1
    34f0:	00003517          	auipc	a0,0x3
    34f4:	2e050513          	addi	a0,a0,736 # 67d0 <malloc+0x9b4>
    34f8:	00003097          	auipc	ra,0x3
    34fc:	86c080e7          	jalr	-1940(ra) # 5d64 <printf>
    exit(1);
    3500:	4505                	li	a0,1
    3502:	00002097          	auipc	ra,0x2
    3506:	4d0080e7          	jalr	1232(ra) # 59d2 <exit>
      printf("%s: mkdir failed\n", s);
    350a:	85a6                	mv	a1,s1
    350c:	00004517          	auipc	a0,0x4
    3510:	c8c50513          	addi	a0,a0,-884 # 7198 <malloc+0x137c>
    3514:	00003097          	auipc	ra,0x3
    3518:	850080e7          	jalr	-1968(ra) # 5d64 <printf>
      exit(1);
    351c:	4505                	li	a0,1
    351e:	00002097          	auipc	ra,0x2
    3522:	4b4080e7          	jalr	1204(ra) # 59d2 <exit>
      printf("%s: child chdir failed\n", s);
    3526:	85a6                	mv	a1,s1
    3528:	00004517          	auipc	a0,0x4
    352c:	cf850513          	addi	a0,a0,-776 # 7220 <malloc+0x1404>
    3530:	00003097          	auipc	ra,0x3
    3534:	834080e7          	jalr	-1996(ra) # 5d64 <printf>
      exit(1);
    3538:	4505                	li	a0,1
    353a:	00002097          	auipc	ra,0x2
    353e:	498080e7          	jalr	1176(ra) # 59d2 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    3542:	85a6                	mv	a1,s1
    3544:	00004517          	auipc	a0,0x4
    3548:	c9c50513          	addi	a0,a0,-868 # 71e0 <malloc+0x13c4>
    354c:	00003097          	auipc	ra,0x3
    3550:	818080e7          	jalr	-2024(ra) # 5d64 <printf>
      exit(1);
    3554:	4505                	li	a0,1
    3556:	00002097          	auipc	ra,0x2
    355a:	47c080e7          	jalr	1148(ra) # 59d2 <exit>
  wait(&xstatus);
    355e:	fdc40513          	addi	a0,s0,-36
    3562:	00002097          	auipc	ra,0x2
    3566:	478080e7          	jalr	1144(ra) # 59da <wait>
  exit(xstatus);
    356a:	fdc42503          	lw	a0,-36(s0)
    356e:	00002097          	auipc	ra,0x2
    3572:	464080e7          	jalr	1124(ra) # 59d2 <exit>

0000000000003576 <dirtest>:
{
    3576:	1101                	addi	sp,sp,-32
    3578:	ec06                	sd	ra,24(sp)
    357a:	e822                	sd	s0,16(sp)
    357c:	e426                	sd	s1,8(sp)
    357e:	1000                	addi	s0,sp,32
    3580:	84aa                	mv	s1,a0
  if (mkdir("dir0") < 0)
    3582:	00004517          	auipc	a0,0x4
    3586:	cb650513          	addi	a0,a0,-842 # 7238 <malloc+0x141c>
    358a:	00002097          	auipc	ra,0x2
    358e:	4b0080e7          	jalr	1200(ra) # 5a3a <mkdir>
    3592:	04054563          	bltz	a0,35dc <dirtest+0x66>
  if (chdir("dir0") < 0)
    3596:	00004517          	auipc	a0,0x4
    359a:	ca250513          	addi	a0,a0,-862 # 7238 <malloc+0x141c>
    359e:	00002097          	auipc	ra,0x2
    35a2:	4a4080e7          	jalr	1188(ra) # 5a42 <chdir>
    35a6:	04054963          	bltz	a0,35f8 <dirtest+0x82>
  if (chdir("..") < 0)
    35aa:	00004517          	auipc	a0,0x4
    35ae:	cae50513          	addi	a0,a0,-850 # 7258 <malloc+0x143c>
    35b2:	00002097          	auipc	ra,0x2
    35b6:	490080e7          	jalr	1168(ra) # 5a42 <chdir>
    35ba:	04054d63          	bltz	a0,3614 <dirtest+0x9e>
  if (unlink("dir0") < 0)
    35be:	00004517          	auipc	a0,0x4
    35c2:	c7a50513          	addi	a0,a0,-902 # 7238 <malloc+0x141c>
    35c6:	00002097          	auipc	ra,0x2
    35ca:	45c080e7          	jalr	1116(ra) # 5a22 <unlink>
    35ce:	06054163          	bltz	a0,3630 <dirtest+0xba>
}
    35d2:	60e2                	ld	ra,24(sp)
    35d4:	6442                	ld	s0,16(sp)
    35d6:	64a2                	ld	s1,8(sp)
    35d8:	6105                	addi	sp,sp,32
    35da:	8082                	ret
    printf("%s: mkdir failed\n", s);
    35dc:	85a6                	mv	a1,s1
    35de:	00004517          	auipc	a0,0x4
    35e2:	bba50513          	addi	a0,a0,-1094 # 7198 <malloc+0x137c>
    35e6:	00002097          	auipc	ra,0x2
    35ea:	77e080e7          	jalr	1918(ra) # 5d64 <printf>
    exit(1);
    35ee:	4505                	li	a0,1
    35f0:	00002097          	auipc	ra,0x2
    35f4:	3e2080e7          	jalr	994(ra) # 59d2 <exit>
    printf("%s: chdir dir0 failed\n", s);
    35f8:	85a6                	mv	a1,s1
    35fa:	00004517          	auipc	a0,0x4
    35fe:	c4650513          	addi	a0,a0,-954 # 7240 <malloc+0x1424>
    3602:	00002097          	auipc	ra,0x2
    3606:	762080e7          	jalr	1890(ra) # 5d64 <printf>
    exit(1);
    360a:	4505                	li	a0,1
    360c:	00002097          	auipc	ra,0x2
    3610:	3c6080e7          	jalr	966(ra) # 59d2 <exit>
    printf("%s: chdir .. failed\n", s);
    3614:	85a6                	mv	a1,s1
    3616:	00004517          	auipc	a0,0x4
    361a:	c4a50513          	addi	a0,a0,-950 # 7260 <malloc+0x1444>
    361e:	00002097          	auipc	ra,0x2
    3622:	746080e7          	jalr	1862(ra) # 5d64 <printf>
    exit(1);
    3626:	4505                	li	a0,1
    3628:	00002097          	auipc	ra,0x2
    362c:	3aa080e7          	jalr	938(ra) # 59d2 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3630:	85a6                	mv	a1,s1
    3632:	00004517          	auipc	a0,0x4
    3636:	c4650513          	addi	a0,a0,-954 # 7278 <malloc+0x145c>
    363a:	00002097          	auipc	ra,0x2
    363e:	72a080e7          	jalr	1834(ra) # 5d64 <printf>
    exit(1);
    3642:	4505                	li	a0,1
    3644:	00002097          	auipc	ra,0x2
    3648:	38e080e7          	jalr	910(ra) # 59d2 <exit>

000000000000364c <subdir>:
{
    364c:	1101                	addi	sp,sp,-32
    364e:	ec06                	sd	ra,24(sp)
    3650:	e822                	sd	s0,16(sp)
    3652:	e426                	sd	s1,8(sp)
    3654:	e04a                	sd	s2,0(sp)
    3656:	1000                	addi	s0,sp,32
    3658:	892a                	mv	s2,a0
  unlink("ff");
    365a:	00004517          	auipc	a0,0x4
    365e:	d6650513          	addi	a0,a0,-666 # 73c0 <malloc+0x15a4>
    3662:	00002097          	auipc	ra,0x2
    3666:	3c0080e7          	jalr	960(ra) # 5a22 <unlink>
  if (mkdir("dd") != 0)
    366a:	00004517          	auipc	a0,0x4
    366e:	c2650513          	addi	a0,a0,-986 # 7290 <malloc+0x1474>
    3672:	00002097          	auipc	ra,0x2
    3676:	3c8080e7          	jalr	968(ra) # 5a3a <mkdir>
    367a:	38051663          	bnez	a0,3a06 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    367e:	20200593          	li	a1,514
    3682:	00004517          	auipc	a0,0x4
    3686:	c2e50513          	addi	a0,a0,-978 # 72b0 <malloc+0x1494>
    368a:	00002097          	auipc	ra,0x2
    368e:	388080e7          	jalr	904(ra) # 5a12 <open>
    3692:	84aa                	mv	s1,a0
  if (fd < 0)
    3694:	38054763          	bltz	a0,3a22 <subdir+0x3d6>
  write(fd, "ff", 2);
    3698:	4609                	li	a2,2
    369a:	00004597          	auipc	a1,0x4
    369e:	d2658593          	addi	a1,a1,-730 # 73c0 <malloc+0x15a4>
    36a2:	00002097          	auipc	ra,0x2
    36a6:	350080e7          	jalr	848(ra) # 59f2 <write>
  close(fd);
    36aa:	8526                	mv	a0,s1
    36ac:	00002097          	auipc	ra,0x2
    36b0:	34e080e7          	jalr	846(ra) # 59fa <close>
  if (unlink("dd") >= 0)
    36b4:	00004517          	auipc	a0,0x4
    36b8:	bdc50513          	addi	a0,a0,-1060 # 7290 <malloc+0x1474>
    36bc:	00002097          	auipc	ra,0x2
    36c0:	366080e7          	jalr	870(ra) # 5a22 <unlink>
    36c4:	36055d63          	bgez	a0,3a3e <subdir+0x3f2>
  if (mkdir("/dd/dd") != 0)
    36c8:	00004517          	auipc	a0,0x4
    36cc:	c4050513          	addi	a0,a0,-960 # 7308 <malloc+0x14ec>
    36d0:	00002097          	auipc	ra,0x2
    36d4:	36a080e7          	jalr	874(ra) # 5a3a <mkdir>
    36d8:	38051163          	bnez	a0,3a5a <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    36dc:	20200593          	li	a1,514
    36e0:	00004517          	auipc	a0,0x4
    36e4:	c5050513          	addi	a0,a0,-944 # 7330 <malloc+0x1514>
    36e8:	00002097          	auipc	ra,0x2
    36ec:	32a080e7          	jalr	810(ra) # 5a12 <open>
    36f0:	84aa                	mv	s1,a0
  if (fd < 0)
    36f2:	38054263          	bltz	a0,3a76 <subdir+0x42a>
  write(fd, "FF", 2);
    36f6:	4609                	li	a2,2
    36f8:	00004597          	auipc	a1,0x4
    36fc:	c6858593          	addi	a1,a1,-920 # 7360 <malloc+0x1544>
    3700:	00002097          	auipc	ra,0x2
    3704:	2f2080e7          	jalr	754(ra) # 59f2 <write>
  close(fd);
    3708:	8526                	mv	a0,s1
    370a:	00002097          	auipc	ra,0x2
    370e:	2f0080e7          	jalr	752(ra) # 59fa <close>
  fd = open("dd/dd/../ff", 0);
    3712:	4581                	li	a1,0
    3714:	00004517          	auipc	a0,0x4
    3718:	c5450513          	addi	a0,a0,-940 # 7368 <malloc+0x154c>
    371c:	00002097          	auipc	ra,0x2
    3720:	2f6080e7          	jalr	758(ra) # 5a12 <open>
    3724:	84aa                	mv	s1,a0
  if (fd < 0)
    3726:	36054663          	bltz	a0,3a92 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    372a:	660d                	lui	a2,0x3
    372c:	00009597          	auipc	a1,0x9
    3730:	54c58593          	addi	a1,a1,1356 # cc78 <buf>
    3734:	00002097          	auipc	ra,0x2
    3738:	2b6080e7          	jalr	694(ra) # 59ea <read>
  if (cc != 2 || buf[0] != 'f')
    373c:	4789                	li	a5,2
    373e:	36f51863          	bne	a0,a5,3aae <subdir+0x462>
    3742:	00009717          	auipc	a4,0x9
    3746:	53674703          	lbu	a4,1334(a4) # cc78 <buf>
    374a:	06600793          	li	a5,102
    374e:	36f71063          	bne	a4,a5,3aae <subdir+0x462>
  close(fd);
    3752:	8526                	mv	a0,s1
    3754:	00002097          	auipc	ra,0x2
    3758:	2a6080e7          	jalr	678(ra) # 59fa <close>
  if (link("dd/dd/ff", "dd/dd/ffff") != 0)
    375c:	00004597          	auipc	a1,0x4
    3760:	c5c58593          	addi	a1,a1,-932 # 73b8 <malloc+0x159c>
    3764:	00004517          	auipc	a0,0x4
    3768:	bcc50513          	addi	a0,a0,-1076 # 7330 <malloc+0x1514>
    376c:	00002097          	auipc	ra,0x2
    3770:	2c6080e7          	jalr	710(ra) # 5a32 <link>
    3774:	34051b63          	bnez	a0,3aca <subdir+0x47e>
  if (unlink("dd/dd/ff") != 0)
    3778:	00004517          	auipc	a0,0x4
    377c:	bb850513          	addi	a0,a0,-1096 # 7330 <malloc+0x1514>
    3780:	00002097          	auipc	ra,0x2
    3784:	2a2080e7          	jalr	674(ra) # 5a22 <unlink>
    3788:	34051f63          	bnez	a0,3ae6 <subdir+0x49a>
  if (open("dd/dd/ff", O_RDONLY) >= 0)
    378c:	4581                	li	a1,0
    378e:	00004517          	auipc	a0,0x4
    3792:	ba250513          	addi	a0,a0,-1118 # 7330 <malloc+0x1514>
    3796:	00002097          	auipc	ra,0x2
    379a:	27c080e7          	jalr	636(ra) # 5a12 <open>
    379e:	36055263          	bgez	a0,3b02 <subdir+0x4b6>
  if (chdir("dd") != 0)
    37a2:	00004517          	auipc	a0,0x4
    37a6:	aee50513          	addi	a0,a0,-1298 # 7290 <malloc+0x1474>
    37aa:	00002097          	auipc	ra,0x2
    37ae:	298080e7          	jalr	664(ra) # 5a42 <chdir>
    37b2:	36051663          	bnez	a0,3b1e <subdir+0x4d2>
  if (chdir("dd/../../dd") != 0)
    37b6:	00004517          	auipc	a0,0x4
    37ba:	c9a50513          	addi	a0,a0,-870 # 7450 <malloc+0x1634>
    37be:	00002097          	auipc	ra,0x2
    37c2:	284080e7          	jalr	644(ra) # 5a42 <chdir>
    37c6:	36051a63          	bnez	a0,3b3a <subdir+0x4ee>
  if (chdir("dd/../../../dd") != 0)
    37ca:	00004517          	auipc	a0,0x4
    37ce:	cb650513          	addi	a0,a0,-842 # 7480 <malloc+0x1664>
    37d2:	00002097          	auipc	ra,0x2
    37d6:	270080e7          	jalr	624(ra) # 5a42 <chdir>
    37da:	36051e63          	bnez	a0,3b56 <subdir+0x50a>
  if (chdir("./..") != 0)
    37de:	00004517          	auipc	a0,0x4
    37e2:	cd250513          	addi	a0,a0,-814 # 74b0 <malloc+0x1694>
    37e6:	00002097          	auipc	ra,0x2
    37ea:	25c080e7          	jalr	604(ra) # 5a42 <chdir>
    37ee:	38051263          	bnez	a0,3b72 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    37f2:	4581                	li	a1,0
    37f4:	00004517          	auipc	a0,0x4
    37f8:	bc450513          	addi	a0,a0,-1084 # 73b8 <malloc+0x159c>
    37fc:	00002097          	auipc	ra,0x2
    3800:	216080e7          	jalr	534(ra) # 5a12 <open>
    3804:	84aa                	mv	s1,a0
  if (fd < 0)
    3806:	38054463          	bltz	a0,3b8e <subdir+0x542>
  if (read(fd, buf, sizeof(buf)) != 2)
    380a:	660d                	lui	a2,0x3
    380c:	00009597          	auipc	a1,0x9
    3810:	46c58593          	addi	a1,a1,1132 # cc78 <buf>
    3814:	00002097          	auipc	ra,0x2
    3818:	1d6080e7          	jalr	470(ra) # 59ea <read>
    381c:	4789                	li	a5,2
    381e:	38f51663          	bne	a0,a5,3baa <subdir+0x55e>
  close(fd);
    3822:	8526                	mv	a0,s1
    3824:	00002097          	auipc	ra,0x2
    3828:	1d6080e7          	jalr	470(ra) # 59fa <close>
  if (open("dd/dd/ff", O_RDONLY) >= 0)
    382c:	4581                	li	a1,0
    382e:	00004517          	auipc	a0,0x4
    3832:	b0250513          	addi	a0,a0,-1278 # 7330 <malloc+0x1514>
    3836:	00002097          	auipc	ra,0x2
    383a:	1dc080e7          	jalr	476(ra) # 5a12 <open>
    383e:	38055463          	bgez	a0,3bc6 <subdir+0x57a>
  if (open("dd/ff/ff", O_CREATE | O_RDWR) >= 0)
    3842:	20200593          	li	a1,514
    3846:	00004517          	auipc	a0,0x4
    384a:	cfa50513          	addi	a0,a0,-774 # 7540 <malloc+0x1724>
    384e:	00002097          	auipc	ra,0x2
    3852:	1c4080e7          	jalr	452(ra) # 5a12 <open>
    3856:	38055663          	bgez	a0,3be2 <subdir+0x596>
  if (open("dd/xx/ff", O_CREATE | O_RDWR) >= 0)
    385a:	20200593          	li	a1,514
    385e:	00004517          	auipc	a0,0x4
    3862:	d1250513          	addi	a0,a0,-750 # 7570 <malloc+0x1754>
    3866:	00002097          	auipc	ra,0x2
    386a:	1ac080e7          	jalr	428(ra) # 5a12 <open>
    386e:	38055863          	bgez	a0,3bfe <subdir+0x5b2>
  if (open("dd", O_CREATE) >= 0)
    3872:	20000593          	li	a1,512
    3876:	00004517          	auipc	a0,0x4
    387a:	a1a50513          	addi	a0,a0,-1510 # 7290 <malloc+0x1474>
    387e:	00002097          	auipc	ra,0x2
    3882:	194080e7          	jalr	404(ra) # 5a12 <open>
    3886:	38055a63          	bgez	a0,3c1a <subdir+0x5ce>
  if (open("dd", O_RDWR) >= 0)
    388a:	4589                	li	a1,2
    388c:	00004517          	auipc	a0,0x4
    3890:	a0450513          	addi	a0,a0,-1532 # 7290 <malloc+0x1474>
    3894:	00002097          	auipc	ra,0x2
    3898:	17e080e7          	jalr	382(ra) # 5a12 <open>
    389c:	38055d63          	bgez	a0,3c36 <subdir+0x5ea>
  if (open("dd", O_WRONLY) >= 0)
    38a0:	4585                	li	a1,1
    38a2:	00004517          	auipc	a0,0x4
    38a6:	9ee50513          	addi	a0,a0,-1554 # 7290 <malloc+0x1474>
    38aa:	00002097          	auipc	ra,0x2
    38ae:	168080e7          	jalr	360(ra) # 5a12 <open>
    38b2:	3a055063          	bgez	a0,3c52 <subdir+0x606>
  if (link("dd/ff/ff", "dd/dd/xx") == 0)
    38b6:	00004597          	auipc	a1,0x4
    38ba:	d4a58593          	addi	a1,a1,-694 # 7600 <malloc+0x17e4>
    38be:	00004517          	auipc	a0,0x4
    38c2:	c8250513          	addi	a0,a0,-894 # 7540 <malloc+0x1724>
    38c6:	00002097          	auipc	ra,0x2
    38ca:	16c080e7          	jalr	364(ra) # 5a32 <link>
    38ce:	3a050063          	beqz	a0,3c6e <subdir+0x622>
  if (link("dd/xx/ff", "dd/dd/xx") == 0)
    38d2:	00004597          	auipc	a1,0x4
    38d6:	d2e58593          	addi	a1,a1,-722 # 7600 <malloc+0x17e4>
    38da:	00004517          	auipc	a0,0x4
    38de:	c9650513          	addi	a0,a0,-874 # 7570 <malloc+0x1754>
    38e2:	00002097          	auipc	ra,0x2
    38e6:	150080e7          	jalr	336(ra) # 5a32 <link>
    38ea:	3a050063          	beqz	a0,3c8a <subdir+0x63e>
  if (link("dd/ff", "dd/dd/ffff") == 0)
    38ee:	00004597          	auipc	a1,0x4
    38f2:	aca58593          	addi	a1,a1,-1334 # 73b8 <malloc+0x159c>
    38f6:	00004517          	auipc	a0,0x4
    38fa:	9ba50513          	addi	a0,a0,-1606 # 72b0 <malloc+0x1494>
    38fe:	00002097          	auipc	ra,0x2
    3902:	134080e7          	jalr	308(ra) # 5a32 <link>
    3906:	3a050063          	beqz	a0,3ca6 <subdir+0x65a>
  if (mkdir("dd/ff/ff") == 0)
    390a:	00004517          	auipc	a0,0x4
    390e:	c3650513          	addi	a0,a0,-970 # 7540 <malloc+0x1724>
    3912:	00002097          	auipc	ra,0x2
    3916:	128080e7          	jalr	296(ra) # 5a3a <mkdir>
    391a:	3a050463          	beqz	a0,3cc2 <subdir+0x676>
  if (mkdir("dd/xx/ff") == 0)
    391e:	00004517          	auipc	a0,0x4
    3922:	c5250513          	addi	a0,a0,-942 # 7570 <malloc+0x1754>
    3926:	00002097          	auipc	ra,0x2
    392a:	114080e7          	jalr	276(ra) # 5a3a <mkdir>
    392e:	3a050863          	beqz	a0,3cde <subdir+0x692>
  if (mkdir("dd/dd/ffff") == 0)
    3932:	00004517          	auipc	a0,0x4
    3936:	a8650513          	addi	a0,a0,-1402 # 73b8 <malloc+0x159c>
    393a:	00002097          	auipc	ra,0x2
    393e:	100080e7          	jalr	256(ra) # 5a3a <mkdir>
    3942:	3a050c63          	beqz	a0,3cfa <subdir+0x6ae>
  if (unlink("dd/xx/ff") == 0)
    3946:	00004517          	auipc	a0,0x4
    394a:	c2a50513          	addi	a0,a0,-982 # 7570 <malloc+0x1754>
    394e:	00002097          	auipc	ra,0x2
    3952:	0d4080e7          	jalr	212(ra) # 5a22 <unlink>
    3956:	3c050063          	beqz	a0,3d16 <subdir+0x6ca>
  if (unlink("dd/ff/ff") == 0)
    395a:	00004517          	auipc	a0,0x4
    395e:	be650513          	addi	a0,a0,-1050 # 7540 <malloc+0x1724>
    3962:	00002097          	auipc	ra,0x2
    3966:	0c0080e7          	jalr	192(ra) # 5a22 <unlink>
    396a:	3c050463          	beqz	a0,3d32 <subdir+0x6e6>
  if (chdir("dd/ff") == 0)
    396e:	00004517          	auipc	a0,0x4
    3972:	94250513          	addi	a0,a0,-1726 # 72b0 <malloc+0x1494>
    3976:	00002097          	auipc	ra,0x2
    397a:	0cc080e7          	jalr	204(ra) # 5a42 <chdir>
    397e:	3c050863          	beqz	a0,3d4e <subdir+0x702>
  if (chdir("dd/xx") == 0)
    3982:	00004517          	auipc	a0,0x4
    3986:	dce50513          	addi	a0,a0,-562 # 7750 <malloc+0x1934>
    398a:	00002097          	auipc	ra,0x2
    398e:	0b8080e7          	jalr	184(ra) # 5a42 <chdir>
    3992:	3c050c63          	beqz	a0,3d6a <subdir+0x71e>
  if (unlink("dd/dd/ffff") != 0)
    3996:	00004517          	auipc	a0,0x4
    399a:	a2250513          	addi	a0,a0,-1502 # 73b8 <malloc+0x159c>
    399e:	00002097          	auipc	ra,0x2
    39a2:	084080e7          	jalr	132(ra) # 5a22 <unlink>
    39a6:	3e051063          	bnez	a0,3d86 <subdir+0x73a>
  if (unlink("dd/ff") != 0)
    39aa:	00004517          	auipc	a0,0x4
    39ae:	90650513          	addi	a0,a0,-1786 # 72b0 <malloc+0x1494>
    39b2:	00002097          	auipc	ra,0x2
    39b6:	070080e7          	jalr	112(ra) # 5a22 <unlink>
    39ba:	3e051463          	bnez	a0,3da2 <subdir+0x756>
  if (unlink("dd") == 0)
    39be:	00004517          	auipc	a0,0x4
    39c2:	8d250513          	addi	a0,a0,-1838 # 7290 <malloc+0x1474>
    39c6:	00002097          	auipc	ra,0x2
    39ca:	05c080e7          	jalr	92(ra) # 5a22 <unlink>
    39ce:	3e050863          	beqz	a0,3dbe <subdir+0x772>
  if (unlink("dd/dd") < 0)
    39d2:	00004517          	auipc	a0,0x4
    39d6:	dee50513          	addi	a0,a0,-530 # 77c0 <malloc+0x19a4>
    39da:	00002097          	auipc	ra,0x2
    39de:	048080e7          	jalr	72(ra) # 5a22 <unlink>
    39e2:	3e054c63          	bltz	a0,3dda <subdir+0x78e>
  if (unlink("dd") < 0)
    39e6:	00004517          	auipc	a0,0x4
    39ea:	8aa50513          	addi	a0,a0,-1878 # 7290 <malloc+0x1474>
    39ee:	00002097          	auipc	ra,0x2
    39f2:	034080e7          	jalr	52(ra) # 5a22 <unlink>
    39f6:	40054063          	bltz	a0,3df6 <subdir+0x7aa>
}
    39fa:	60e2                	ld	ra,24(sp)
    39fc:	6442                	ld	s0,16(sp)
    39fe:	64a2                	ld	s1,8(sp)
    3a00:	6902                	ld	s2,0(sp)
    3a02:	6105                	addi	sp,sp,32
    3a04:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3a06:	85ca                	mv	a1,s2
    3a08:	00004517          	auipc	a0,0x4
    3a0c:	89050513          	addi	a0,a0,-1904 # 7298 <malloc+0x147c>
    3a10:	00002097          	auipc	ra,0x2
    3a14:	354080e7          	jalr	852(ra) # 5d64 <printf>
    exit(1);
    3a18:	4505                	li	a0,1
    3a1a:	00002097          	auipc	ra,0x2
    3a1e:	fb8080e7          	jalr	-72(ra) # 59d2 <exit>
    printf("%s: create dd/ff failed\n", s);
    3a22:	85ca                	mv	a1,s2
    3a24:	00004517          	auipc	a0,0x4
    3a28:	89450513          	addi	a0,a0,-1900 # 72b8 <malloc+0x149c>
    3a2c:	00002097          	auipc	ra,0x2
    3a30:	338080e7          	jalr	824(ra) # 5d64 <printf>
    exit(1);
    3a34:	4505                	li	a0,1
    3a36:	00002097          	auipc	ra,0x2
    3a3a:	f9c080e7          	jalr	-100(ra) # 59d2 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3a3e:	85ca                	mv	a1,s2
    3a40:	00004517          	auipc	a0,0x4
    3a44:	89850513          	addi	a0,a0,-1896 # 72d8 <malloc+0x14bc>
    3a48:	00002097          	auipc	ra,0x2
    3a4c:	31c080e7          	jalr	796(ra) # 5d64 <printf>
    exit(1);
    3a50:	4505                	li	a0,1
    3a52:	00002097          	auipc	ra,0x2
    3a56:	f80080e7          	jalr	-128(ra) # 59d2 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3a5a:	85ca                	mv	a1,s2
    3a5c:	00004517          	auipc	a0,0x4
    3a60:	8b450513          	addi	a0,a0,-1868 # 7310 <malloc+0x14f4>
    3a64:	00002097          	auipc	ra,0x2
    3a68:	300080e7          	jalr	768(ra) # 5d64 <printf>
    exit(1);
    3a6c:	4505                	li	a0,1
    3a6e:	00002097          	auipc	ra,0x2
    3a72:	f64080e7          	jalr	-156(ra) # 59d2 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3a76:	85ca                	mv	a1,s2
    3a78:	00004517          	auipc	a0,0x4
    3a7c:	8c850513          	addi	a0,a0,-1848 # 7340 <malloc+0x1524>
    3a80:	00002097          	auipc	ra,0x2
    3a84:	2e4080e7          	jalr	740(ra) # 5d64 <printf>
    exit(1);
    3a88:	4505                	li	a0,1
    3a8a:	00002097          	auipc	ra,0x2
    3a8e:	f48080e7          	jalr	-184(ra) # 59d2 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3a92:	85ca                	mv	a1,s2
    3a94:	00004517          	auipc	a0,0x4
    3a98:	8e450513          	addi	a0,a0,-1820 # 7378 <malloc+0x155c>
    3a9c:	00002097          	auipc	ra,0x2
    3aa0:	2c8080e7          	jalr	712(ra) # 5d64 <printf>
    exit(1);
    3aa4:	4505                	li	a0,1
    3aa6:	00002097          	auipc	ra,0x2
    3aaa:	f2c080e7          	jalr	-212(ra) # 59d2 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3aae:	85ca                	mv	a1,s2
    3ab0:	00004517          	auipc	a0,0x4
    3ab4:	8e850513          	addi	a0,a0,-1816 # 7398 <malloc+0x157c>
    3ab8:	00002097          	auipc	ra,0x2
    3abc:	2ac080e7          	jalr	684(ra) # 5d64 <printf>
    exit(1);
    3ac0:	4505                	li	a0,1
    3ac2:	00002097          	auipc	ra,0x2
    3ac6:	f10080e7          	jalr	-240(ra) # 59d2 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3aca:	85ca                	mv	a1,s2
    3acc:	00004517          	auipc	a0,0x4
    3ad0:	8fc50513          	addi	a0,a0,-1796 # 73c8 <malloc+0x15ac>
    3ad4:	00002097          	auipc	ra,0x2
    3ad8:	290080e7          	jalr	656(ra) # 5d64 <printf>
    exit(1);
    3adc:	4505                	li	a0,1
    3ade:	00002097          	auipc	ra,0x2
    3ae2:	ef4080e7          	jalr	-268(ra) # 59d2 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3ae6:	85ca                	mv	a1,s2
    3ae8:	00004517          	auipc	a0,0x4
    3aec:	90850513          	addi	a0,a0,-1784 # 73f0 <malloc+0x15d4>
    3af0:	00002097          	auipc	ra,0x2
    3af4:	274080e7          	jalr	628(ra) # 5d64 <printf>
    exit(1);
    3af8:	4505                	li	a0,1
    3afa:	00002097          	auipc	ra,0x2
    3afe:	ed8080e7          	jalr	-296(ra) # 59d2 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3b02:	85ca                	mv	a1,s2
    3b04:	00004517          	auipc	a0,0x4
    3b08:	90c50513          	addi	a0,a0,-1780 # 7410 <malloc+0x15f4>
    3b0c:	00002097          	auipc	ra,0x2
    3b10:	258080e7          	jalr	600(ra) # 5d64 <printf>
    exit(1);
    3b14:	4505                	li	a0,1
    3b16:	00002097          	auipc	ra,0x2
    3b1a:	ebc080e7          	jalr	-324(ra) # 59d2 <exit>
    printf("%s: chdir dd failed\n", s);
    3b1e:	85ca                	mv	a1,s2
    3b20:	00004517          	auipc	a0,0x4
    3b24:	91850513          	addi	a0,a0,-1768 # 7438 <malloc+0x161c>
    3b28:	00002097          	auipc	ra,0x2
    3b2c:	23c080e7          	jalr	572(ra) # 5d64 <printf>
    exit(1);
    3b30:	4505                	li	a0,1
    3b32:	00002097          	auipc	ra,0x2
    3b36:	ea0080e7          	jalr	-352(ra) # 59d2 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3b3a:	85ca                	mv	a1,s2
    3b3c:	00004517          	auipc	a0,0x4
    3b40:	92450513          	addi	a0,a0,-1756 # 7460 <malloc+0x1644>
    3b44:	00002097          	auipc	ra,0x2
    3b48:	220080e7          	jalr	544(ra) # 5d64 <printf>
    exit(1);
    3b4c:	4505                	li	a0,1
    3b4e:	00002097          	auipc	ra,0x2
    3b52:	e84080e7          	jalr	-380(ra) # 59d2 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3b56:	85ca                	mv	a1,s2
    3b58:	00004517          	auipc	a0,0x4
    3b5c:	93850513          	addi	a0,a0,-1736 # 7490 <malloc+0x1674>
    3b60:	00002097          	auipc	ra,0x2
    3b64:	204080e7          	jalr	516(ra) # 5d64 <printf>
    exit(1);
    3b68:	4505                	li	a0,1
    3b6a:	00002097          	auipc	ra,0x2
    3b6e:	e68080e7          	jalr	-408(ra) # 59d2 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3b72:	85ca                	mv	a1,s2
    3b74:	00004517          	auipc	a0,0x4
    3b78:	94450513          	addi	a0,a0,-1724 # 74b8 <malloc+0x169c>
    3b7c:	00002097          	auipc	ra,0x2
    3b80:	1e8080e7          	jalr	488(ra) # 5d64 <printf>
    exit(1);
    3b84:	4505                	li	a0,1
    3b86:	00002097          	auipc	ra,0x2
    3b8a:	e4c080e7          	jalr	-436(ra) # 59d2 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3b8e:	85ca                	mv	a1,s2
    3b90:	00004517          	auipc	a0,0x4
    3b94:	94050513          	addi	a0,a0,-1728 # 74d0 <malloc+0x16b4>
    3b98:	00002097          	auipc	ra,0x2
    3b9c:	1cc080e7          	jalr	460(ra) # 5d64 <printf>
    exit(1);
    3ba0:	4505                	li	a0,1
    3ba2:	00002097          	auipc	ra,0x2
    3ba6:	e30080e7          	jalr	-464(ra) # 59d2 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3baa:	85ca                	mv	a1,s2
    3bac:	00004517          	auipc	a0,0x4
    3bb0:	94450513          	addi	a0,a0,-1724 # 74f0 <malloc+0x16d4>
    3bb4:	00002097          	auipc	ra,0x2
    3bb8:	1b0080e7          	jalr	432(ra) # 5d64 <printf>
    exit(1);
    3bbc:	4505                	li	a0,1
    3bbe:	00002097          	auipc	ra,0x2
    3bc2:	e14080e7          	jalr	-492(ra) # 59d2 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3bc6:	85ca                	mv	a1,s2
    3bc8:	00004517          	auipc	a0,0x4
    3bcc:	94850513          	addi	a0,a0,-1720 # 7510 <malloc+0x16f4>
    3bd0:	00002097          	auipc	ra,0x2
    3bd4:	194080e7          	jalr	404(ra) # 5d64 <printf>
    exit(1);
    3bd8:	4505                	li	a0,1
    3bda:	00002097          	auipc	ra,0x2
    3bde:	df8080e7          	jalr	-520(ra) # 59d2 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3be2:	85ca                	mv	a1,s2
    3be4:	00004517          	auipc	a0,0x4
    3be8:	96c50513          	addi	a0,a0,-1684 # 7550 <malloc+0x1734>
    3bec:	00002097          	auipc	ra,0x2
    3bf0:	178080e7          	jalr	376(ra) # 5d64 <printf>
    exit(1);
    3bf4:	4505                	li	a0,1
    3bf6:	00002097          	auipc	ra,0x2
    3bfa:	ddc080e7          	jalr	-548(ra) # 59d2 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3bfe:	85ca                	mv	a1,s2
    3c00:	00004517          	auipc	a0,0x4
    3c04:	98050513          	addi	a0,a0,-1664 # 7580 <malloc+0x1764>
    3c08:	00002097          	auipc	ra,0x2
    3c0c:	15c080e7          	jalr	348(ra) # 5d64 <printf>
    exit(1);
    3c10:	4505                	li	a0,1
    3c12:	00002097          	auipc	ra,0x2
    3c16:	dc0080e7          	jalr	-576(ra) # 59d2 <exit>
    printf("%s: create dd succeeded!\n", s);
    3c1a:	85ca                	mv	a1,s2
    3c1c:	00004517          	auipc	a0,0x4
    3c20:	98450513          	addi	a0,a0,-1660 # 75a0 <malloc+0x1784>
    3c24:	00002097          	auipc	ra,0x2
    3c28:	140080e7          	jalr	320(ra) # 5d64 <printf>
    exit(1);
    3c2c:	4505                	li	a0,1
    3c2e:	00002097          	auipc	ra,0x2
    3c32:	da4080e7          	jalr	-604(ra) # 59d2 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3c36:	85ca                	mv	a1,s2
    3c38:	00004517          	auipc	a0,0x4
    3c3c:	98850513          	addi	a0,a0,-1656 # 75c0 <malloc+0x17a4>
    3c40:	00002097          	auipc	ra,0x2
    3c44:	124080e7          	jalr	292(ra) # 5d64 <printf>
    exit(1);
    3c48:	4505                	li	a0,1
    3c4a:	00002097          	auipc	ra,0x2
    3c4e:	d88080e7          	jalr	-632(ra) # 59d2 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3c52:	85ca                	mv	a1,s2
    3c54:	00004517          	auipc	a0,0x4
    3c58:	98c50513          	addi	a0,a0,-1652 # 75e0 <malloc+0x17c4>
    3c5c:	00002097          	auipc	ra,0x2
    3c60:	108080e7          	jalr	264(ra) # 5d64 <printf>
    exit(1);
    3c64:	4505                	li	a0,1
    3c66:	00002097          	auipc	ra,0x2
    3c6a:	d6c080e7          	jalr	-660(ra) # 59d2 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3c6e:	85ca                	mv	a1,s2
    3c70:	00004517          	auipc	a0,0x4
    3c74:	9a050513          	addi	a0,a0,-1632 # 7610 <malloc+0x17f4>
    3c78:	00002097          	auipc	ra,0x2
    3c7c:	0ec080e7          	jalr	236(ra) # 5d64 <printf>
    exit(1);
    3c80:	4505                	li	a0,1
    3c82:	00002097          	auipc	ra,0x2
    3c86:	d50080e7          	jalr	-688(ra) # 59d2 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3c8a:	85ca                	mv	a1,s2
    3c8c:	00004517          	auipc	a0,0x4
    3c90:	9ac50513          	addi	a0,a0,-1620 # 7638 <malloc+0x181c>
    3c94:	00002097          	auipc	ra,0x2
    3c98:	0d0080e7          	jalr	208(ra) # 5d64 <printf>
    exit(1);
    3c9c:	4505                	li	a0,1
    3c9e:	00002097          	auipc	ra,0x2
    3ca2:	d34080e7          	jalr	-716(ra) # 59d2 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3ca6:	85ca                	mv	a1,s2
    3ca8:	00004517          	auipc	a0,0x4
    3cac:	9b850513          	addi	a0,a0,-1608 # 7660 <malloc+0x1844>
    3cb0:	00002097          	auipc	ra,0x2
    3cb4:	0b4080e7          	jalr	180(ra) # 5d64 <printf>
    exit(1);
    3cb8:	4505                	li	a0,1
    3cba:	00002097          	auipc	ra,0x2
    3cbe:	d18080e7          	jalr	-744(ra) # 59d2 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3cc2:	85ca                	mv	a1,s2
    3cc4:	00004517          	auipc	a0,0x4
    3cc8:	9c450513          	addi	a0,a0,-1596 # 7688 <malloc+0x186c>
    3ccc:	00002097          	auipc	ra,0x2
    3cd0:	098080e7          	jalr	152(ra) # 5d64 <printf>
    exit(1);
    3cd4:	4505                	li	a0,1
    3cd6:	00002097          	auipc	ra,0x2
    3cda:	cfc080e7          	jalr	-772(ra) # 59d2 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3cde:	85ca                	mv	a1,s2
    3ce0:	00004517          	auipc	a0,0x4
    3ce4:	9c850513          	addi	a0,a0,-1592 # 76a8 <malloc+0x188c>
    3ce8:	00002097          	auipc	ra,0x2
    3cec:	07c080e7          	jalr	124(ra) # 5d64 <printf>
    exit(1);
    3cf0:	4505                	li	a0,1
    3cf2:	00002097          	auipc	ra,0x2
    3cf6:	ce0080e7          	jalr	-800(ra) # 59d2 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3cfa:	85ca                	mv	a1,s2
    3cfc:	00004517          	auipc	a0,0x4
    3d00:	9cc50513          	addi	a0,a0,-1588 # 76c8 <malloc+0x18ac>
    3d04:	00002097          	auipc	ra,0x2
    3d08:	060080e7          	jalr	96(ra) # 5d64 <printf>
    exit(1);
    3d0c:	4505                	li	a0,1
    3d0e:	00002097          	auipc	ra,0x2
    3d12:	cc4080e7          	jalr	-828(ra) # 59d2 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3d16:	85ca                	mv	a1,s2
    3d18:	00004517          	auipc	a0,0x4
    3d1c:	9d850513          	addi	a0,a0,-1576 # 76f0 <malloc+0x18d4>
    3d20:	00002097          	auipc	ra,0x2
    3d24:	044080e7          	jalr	68(ra) # 5d64 <printf>
    exit(1);
    3d28:	4505                	li	a0,1
    3d2a:	00002097          	auipc	ra,0x2
    3d2e:	ca8080e7          	jalr	-856(ra) # 59d2 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3d32:	85ca                	mv	a1,s2
    3d34:	00004517          	auipc	a0,0x4
    3d38:	9dc50513          	addi	a0,a0,-1572 # 7710 <malloc+0x18f4>
    3d3c:	00002097          	auipc	ra,0x2
    3d40:	028080e7          	jalr	40(ra) # 5d64 <printf>
    exit(1);
    3d44:	4505                	li	a0,1
    3d46:	00002097          	auipc	ra,0x2
    3d4a:	c8c080e7          	jalr	-884(ra) # 59d2 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3d4e:	85ca                	mv	a1,s2
    3d50:	00004517          	auipc	a0,0x4
    3d54:	9e050513          	addi	a0,a0,-1568 # 7730 <malloc+0x1914>
    3d58:	00002097          	auipc	ra,0x2
    3d5c:	00c080e7          	jalr	12(ra) # 5d64 <printf>
    exit(1);
    3d60:	4505                	li	a0,1
    3d62:	00002097          	auipc	ra,0x2
    3d66:	c70080e7          	jalr	-912(ra) # 59d2 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3d6a:	85ca                	mv	a1,s2
    3d6c:	00004517          	auipc	a0,0x4
    3d70:	9ec50513          	addi	a0,a0,-1556 # 7758 <malloc+0x193c>
    3d74:	00002097          	auipc	ra,0x2
    3d78:	ff0080e7          	jalr	-16(ra) # 5d64 <printf>
    exit(1);
    3d7c:	4505                	li	a0,1
    3d7e:	00002097          	auipc	ra,0x2
    3d82:	c54080e7          	jalr	-940(ra) # 59d2 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3d86:	85ca                	mv	a1,s2
    3d88:	00003517          	auipc	a0,0x3
    3d8c:	66850513          	addi	a0,a0,1640 # 73f0 <malloc+0x15d4>
    3d90:	00002097          	auipc	ra,0x2
    3d94:	fd4080e7          	jalr	-44(ra) # 5d64 <printf>
    exit(1);
    3d98:	4505                	li	a0,1
    3d9a:	00002097          	auipc	ra,0x2
    3d9e:	c38080e7          	jalr	-968(ra) # 59d2 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3da2:	85ca                	mv	a1,s2
    3da4:	00004517          	auipc	a0,0x4
    3da8:	9d450513          	addi	a0,a0,-1580 # 7778 <malloc+0x195c>
    3dac:	00002097          	auipc	ra,0x2
    3db0:	fb8080e7          	jalr	-72(ra) # 5d64 <printf>
    exit(1);
    3db4:	4505                	li	a0,1
    3db6:	00002097          	auipc	ra,0x2
    3dba:	c1c080e7          	jalr	-996(ra) # 59d2 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3dbe:	85ca                	mv	a1,s2
    3dc0:	00004517          	auipc	a0,0x4
    3dc4:	9d850513          	addi	a0,a0,-1576 # 7798 <malloc+0x197c>
    3dc8:	00002097          	auipc	ra,0x2
    3dcc:	f9c080e7          	jalr	-100(ra) # 5d64 <printf>
    exit(1);
    3dd0:	4505                	li	a0,1
    3dd2:	00002097          	auipc	ra,0x2
    3dd6:	c00080e7          	jalr	-1024(ra) # 59d2 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3dda:	85ca                	mv	a1,s2
    3ddc:	00004517          	auipc	a0,0x4
    3de0:	9ec50513          	addi	a0,a0,-1556 # 77c8 <malloc+0x19ac>
    3de4:	00002097          	auipc	ra,0x2
    3de8:	f80080e7          	jalr	-128(ra) # 5d64 <printf>
    exit(1);
    3dec:	4505                	li	a0,1
    3dee:	00002097          	auipc	ra,0x2
    3df2:	be4080e7          	jalr	-1052(ra) # 59d2 <exit>
    printf("%s: unlink dd failed\n", s);
    3df6:	85ca                	mv	a1,s2
    3df8:	00004517          	auipc	a0,0x4
    3dfc:	9f050513          	addi	a0,a0,-1552 # 77e8 <malloc+0x19cc>
    3e00:	00002097          	auipc	ra,0x2
    3e04:	f64080e7          	jalr	-156(ra) # 5d64 <printf>
    exit(1);
    3e08:	4505                	li	a0,1
    3e0a:	00002097          	auipc	ra,0x2
    3e0e:	bc8080e7          	jalr	-1080(ra) # 59d2 <exit>

0000000000003e12 <rmdot>:
{
    3e12:	1101                	addi	sp,sp,-32
    3e14:	ec06                	sd	ra,24(sp)
    3e16:	e822                	sd	s0,16(sp)
    3e18:	e426                	sd	s1,8(sp)
    3e1a:	1000                	addi	s0,sp,32
    3e1c:	84aa                	mv	s1,a0
  if (mkdir("dots") != 0)
    3e1e:	00004517          	auipc	a0,0x4
    3e22:	9e250513          	addi	a0,a0,-1566 # 7800 <malloc+0x19e4>
    3e26:	00002097          	auipc	ra,0x2
    3e2a:	c14080e7          	jalr	-1004(ra) # 5a3a <mkdir>
    3e2e:	e549                	bnez	a0,3eb8 <rmdot+0xa6>
  if (chdir("dots") != 0)
    3e30:	00004517          	auipc	a0,0x4
    3e34:	9d050513          	addi	a0,a0,-1584 # 7800 <malloc+0x19e4>
    3e38:	00002097          	auipc	ra,0x2
    3e3c:	c0a080e7          	jalr	-1014(ra) # 5a42 <chdir>
    3e40:	e951                	bnez	a0,3ed4 <rmdot+0xc2>
  if (unlink(".") == 0)
    3e42:	00002517          	auipc	a0,0x2
    3e46:	7ee50513          	addi	a0,a0,2030 # 6630 <malloc+0x814>
    3e4a:	00002097          	auipc	ra,0x2
    3e4e:	bd8080e7          	jalr	-1064(ra) # 5a22 <unlink>
    3e52:	cd59                	beqz	a0,3ef0 <rmdot+0xde>
  if (unlink("..") == 0)
    3e54:	00003517          	auipc	a0,0x3
    3e58:	40450513          	addi	a0,a0,1028 # 7258 <malloc+0x143c>
    3e5c:	00002097          	auipc	ra,0x2
    3e60:	bc6080e7          	jalr	-1082(ra) # 5a22 <unlink>
    3e64:	c545                	beqz	a0,3f0c <rmdot+0xfa>
  if (chdir("/") != 0)
    3e66:	00003517          	auipc	a0,0x3
    3e6a:	39a50513          	addi	a0,a0,922 # 7200 <malloc+0x13e4>
    3e6e:	00002097          	auipc	ra,0x2
    3e72:	bd4080e7          	jalr	-1068(ra) # 5a42 <chdir>
    3e76:	e94d                	bnez	a0,3f28 <rmdot+0x116>
  if (unlink("dots/.") == 0)
    3e78:	00004517          	auipc	a0,0x4
    3e7c:	9f050513          	addi	a0,a0,-1552 # 7868 <malloc+0x1a4c>
    3e80:	00002097          	auipc	ra,0x2
    3e84:	ba2080e7          	jalr	-1118(ra) # 5a22 <unlink>
    3e88:	cd55                	beqz	a0,3f44 <rmdot+0x132>
  if (unlink("dots/..") == 0)
    3e8a:	00004517          	auipc	a0,0x4
    3e8e:	a0650513          	addi	a0,a0,-1530 # 7890 <malloc+0x1a74>
    3e92:	00002097          	auipc	ra,0x2
    3e96:	b90080e7          	jalr	-1136(ra) # 5a22 <unlink>
    3e9a:	c179                	beqz	a0,3f60 <rmdot+0x14e>
  if (unlink("dots") != 0)
    3e9c:	00004517          	auipc	a0,0x4
    3ea0:	96450513          	addi	a0,a0,-1692 # 7800 <malloc+0x19e4>
    3ea4:	00002097          	auipc	ra,0x2
    3ea8:	b7e080e7          	jalr	-1154(ra) # 5a22 <unlink>
    3eac:	e961                	bnez	a0,3f7c <rmdot+0x16a>
}
    3eae:	60e2                	ld	ra,24(sp)
    3eb0:	6442                	ld	s0,16(sp)
    3eb2:	64a2                	ld	s1,8(sp)
    3eb4:	6105                	addi	sp,sp,32
    3eb6:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3eb8:	85a6                	mv	a1,s1
    3eba:	00004517          	auipc	a0,0x4
    3ebe:	94e50513          	addi	a0,a0,-1714 # 7808 <malloc+0x19ec>
    3ec2:	00002097          	auipc	ra,0x2
    3ec6:	ea2080e7          	jalr	-350(ra) # 5d64 <printf>
    exit(1);
    3eca:	4505                	li	a0,1
    3ecc:	00002097          	auipc	ra,0x2
    3ed0:	b06080e7          	jalr	-1274(ra) # 59d2 <exit>
    printf("%s: chdir dots failed\n", s);
    3ed4:	85a6                	mv	a1,s1
    3ed6:	00004517          	auipc	a0,0x4
    3eda:	94a50513          	addi	a0,a0,-1718 # 7820 <malloc+0x1a04>
    3ede:	00002097          	auipc	ra,0x2
    3ee2:	e86080e7          	jalr	-378(ra) # 5d64 <printf>
    exit(1);
    3ee6:	4505                	li	a0,1
    3ee8:	00002097          	auipc	ra,0x2
    3eec:	aea080e7          	jalr	-1302(ra) # 59d2 <exit>
    printf("%s: rm . worked!\n", s);
    3ef0:	85a6                	mv	a1,s1
    3ef2:	00004517          	auipc	a0,0x4
    3ef6:	94650513          	addi	a0,a0,-1722 # 7838 <malloc+0x1a1c>
    3efa:	00002097          	auipc	ra,0x2
    3efe:	e6a080e7          	jalr	-406(ra) # 5d64 <printf>
    exit(1);
    3f02:	4505                	li	a0,1
    3f04:	00002097          	auipc	ra,0x2
    3f08:	ace080e7          	jalr	-1330(ra) # 59d2 <exit>
    printf("%s: rm .. worked!\n", s);
    3f0c:	85a6                	mv	a1,s1
    3f0e:	00004517          	auipc	a0,0x4
    3f12:	94250513          	addi	a0,a0,-1726 # 7850 <malloc+0x1a34>
    3f16:	00002097          	auipc	ra,0x2
    3f1a:	e4e080e7          	jalr	-434(ra) # 5d64 <printf>
    exit(1);
    3f1e:	4505                	li	a0,1
    3f20:	00002097          	auipc	ra,0x2
    3f24:	ab2080e7          	jalr	-1358(ra) # 59d2 <exit>
    printf("%s: chdir / failed\n", s);
    3f28:	85a6                	mv	a1,s1
    3f2a:	00003517          	auipc	a0,0x3
    3f2e:	2de50513          	addi	a0,a0,734 # 7208 <malloc+0x13ec>
    3f32:	00002097          	auipc	ra,0x2
    3f36:	e32080e7          	jalr	-462(ra) # 5d64 <printf>
    exit(1);
    3f3a:	4505                	li	a0,1
    3f3c:	00002097          	auipc	ra,0x2
    3f40:	a96080e7          	jalr	-1386(ra) # 59d2 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3f44:	85a6                	mv	a1,s1
    3f46:	00004517          	auipc	a0,0x4
    3f4a:	92a50513          	addi	a0,a0,-1750 # 7870 <malloc+0x1a54>
    3f4e:	00002097          	auipc	ra,0x2
    3f52:	e16080e7          	jalr	-490(ra) # 5d64 <printf>
    exit(1);
    3f56:	4505                	li	a0,1
    3f58:	00002097          	auipc	ra,0x2
    3f5c:	a7a080e7          	jalr	-1414(ra) # 59d2 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3f60:	85a6                	mv	a1,s1
    3f62:	00004517          	auipc	a0,0x4
    3f66:	93650513          	addi	a0,a0,-1738 # 7898 <malloc+0x1a7c>
    3f6a:	00002097          	auipc	ra,0x2
    3f6e:	dfa080e7          	jalr	-518(ra) # 5d64 <printf>
    exit(1);
    3f72:	4505                	li	a0,1
    3f74:	00002097          	auipc	ra,0x2
    3f78:	a5e080e7          	jalr	-1442(ra) # 59d2 <exit>
    printf("%s: unlink dots failed!\n", s);
    3f7c:	85a6                	mv	a1,s1
    3f7e:	00004517          	auipc	a0,0x4
    3f82:	93a50513          	addi	a0,a0,-1734 # 78b8 <malloc+0x1a9c>
    3f86:	00002097          	auipc	ra,0x2
    3f8a:	dde080e7          	jalr	-546(ra) # 5d64 <printf>
    exit(1);
    3f8e:	4505                	li	a0,1
    3f90:	00002097          	auipc	ra,0x2
    3f94:	a42080e7          	jalr	-1470(ra) # 59d2 <exit>

0000000000003f98 <dirfile>:
{
    3f98:	1101                	addi	sp,sp,-32
    3f9a:	ec06                	sd	ra,24(sp)
    3f9c:	e822                	sd	s0,16(sp)
    3f9e:	e426                	sd	s1,8(sp)
    3fa0:	e04a                	sd	s2,0(sp)
    3fa2:	1000                	addi	s0,sp,32
    3fa4:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3fa6:	20000593          	li	a1,512
    3faa:	00004517          	auipc	a0,0x4
    3fae:	92e50513          	addi	a0,a0,-1746 # 78d8 <malloc+0x1abc>
    3fb2:	00002097          	auipc	ra,0x2
    3fb6:	a60080e7          	jalr	-1440(ra) # 5a12 <open>
  if (fd < 0)
    3fba:	0e054d63          	bltz	a0,40b4 <dirfile+0x11c>
  close(fd);
    3fbe:	00002097          	auipc	ra,0x2
    3fc2:	a3c080e7          	jalr	-1476(ra) # 59fa <close>
  if (chdir("dirfile") == 0)
    3fc6:	00004517          	auipc	a0,0x4
    3fca:	91250513          	addi	a0,a0,-1774 # 78d8 <malloc+0x1abc>
    3fce:	00002097          	auipc	ra,0x2
    3fd2:	a74080e7          	jalr	-1420(ra) # 5a42 <chdir>
    3fd6:	cd6d                	beqz	a0,40d0 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    3fd8:	4581                	li	a1,0
    3fda:	00004517          	auipc	a0,0x4
    3fde:	94650513          	addi	a0,a0,-1722 # 7920 <malloc+0x1b04>
    3fe2:	00002097          	auipc	ra,0x2
    3fe6:	a30080e7          	jalr	-1488(ra) # 5a12 <open>
  if (fd >= 0)
    3fea:	10055163          	bgez	a0,40ec <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3fee:	20000593          	li	a1,512
    3ff2:	00004517          	auipc	a0,0x4
    3ff6:	92e50513          	addi	a0,a0,-1746 # 7920 <malloc+0x1b04>
    3ffa:	00002097          	auipc	ra,0x2
    3ffe:	a18080e7          	jalr	-1512(ra) # 5a12 <open>
  if (fd >= 0)
    4002:	10055363          	bgez	a0,4108 <dirfile+0x170>
  if (mkdir("dirfile/xx") == 0)
    4006:	00004517          	auipc	a0,0x4
    400a:	91a50513          	addi	a0,a0,-1766 # 7920 <malloc+0x1b04>
    400e:	00002097          	auipc	ra,0x2
    4012:	a2c080e7          	jalr	-1492(ra) # 5a3a <mkdir>
    4016:	10050763          	beqz	a0,4124 <dirfile+0x18c>
  if (unlink("dirfile/xx") == 0)
    401a:	00004517          	auipc	a0,0x4
    401e:	90650513          	addi	a0,a0,-1786 # 7920 <malloc+0x1b04>
    4022:	00002097          	auipc	ra,0x2
    4026:	a00080e7          	jalr	-1536(ra) # 5a22 <unlink>
    402a:	10050b63          	beqz	a0,4140 <dirfile+0x1a8>
  if (link("README", "dirfile/xx") == 0)
    402e:	00004597          	auipc	a1,0x4
    4032:	8f258593          	addi	a1,a1,-1806 # 7920 <malloc+0x1b04>
    4036:	00002517          	auipc	a0,0x2
    403a:	0ea50513          	addi	a0,a0,234 # 6120 <malloc+0x304>
    403e:	00002097          	auipc	ra,0x2
    4042:	9f4080e7          	jalr	-1548(ra) # 5a32 <link>
    4046:	10050b63          	beqz	a0,415c <dirfile+0x1c4>
  if (unlink("dirfile") != 0)
    404a:	00004517          	auipc	a0,0x4
    404e:	88e50513          	addi	a0,a0,-1906 # 78d8 <malloc+0x1abc>
    4052:	00002097          	auipc	ra,0x2
    4056:	9d0080e7          	jalr	-1584(ra) # 5a22 <unlink>
    405a:	10051f63          	bnez	a0,4178 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    405e:	4589                	li	a1,2
    4060:	00002517          	auipc	a0,0x2
    4064:	5d050513          	addi	a0,a0,1488 # 6630 <malloc+0x814>
    4068:	00002097          	auipc	ra,0x2
    406c:	9aa080e7          	jalr	-1622(ra) # 5a12 <open>
  if (fd >= 0)
    4070:	12055263          	bgez	a0,4194 <dirfile+0x1fc>
  fd = open(".", 0);
    4074:	4581                	li	a1,0
    4076:	00002517          	auipc	a0,0x2
    407a:	5ba50513          	addi	a0,a0,1466 # 6630 <malloc+0x814>
    407e:	00002097          	auipc	ra,0x2
    4082:	994080e7          	jalr	-1644(ra) # 5a12 <open>
    4086:	84aa                	mv	s1,a0
  if (write(fd, "x", 1) > 0)
    4088:	4605                	li	a2,1
    408a:	00002597          	auipc	a1,0x2
    408e:	f2e58593          	addi	a1,a1,-210 # 5fb8 <malloc+0x19c>
    4092:	00002097          	auipc	ra,0x2
    4096:	960080e7          	jalr	-1696(ra) # 59f2 <write>
    409a:	10a04b63          	bgtz	a0,41b0 <dirfile+0x218>
  close(fd);
    409e:	8526                	mv	a0,s1
    40a0:	00002097          	auipc	ra,0x2
    40a4:	95a080e7          	jalr	-1702(ra) # 59fa <close>
}
    40a8:	60e2                	ld	ra,24(sp)
    40aa:	6442                	ld	s0,16(sp)
    40ac:	64a2                	ld	s1,8(sp)
    40ae:	6902                	ld	s2,0(sp)
    40b0:	6105                	addi	sp,sp,32
    40b2:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    40b4:	85ca                	mv	a1,s2
    40b6:	00004517          	auipc	a0,0x4
    40ba:	82a50513          	addi	a0,a0,-2006 # 78e0 <malloc+0x1ac4>
    40be:	00002097          	auipc	ra,0x2
    40c2:	ca6080e7          	jalr	-858(ra) # 5d64 <printf>
    exit(1);
    40c6:	4505                	li	a0,1
    40c8:	00002097          	auipc	ra,0x2
    40cc:	90a080e7          	jalr	-1782(ra) # 59d2 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    40d0:	85ca                	mv	a1,s2
    40d2:	00004517          	auipc	a0,0x4
    40d6:	82e50513          	addi	a0,a0,-2002 # 7900 <malloc+0x1ae4>
    40da:	00002097          	auipc	ra,0x2
    40de:	c8a080e7          	jalr	-886(ra) # 5d64 <printf>
    exit(1);
    40e2:	4505                	li	a0,1
    40e4:	00002097          	auipc	ra,0x2
    40e8:	8ee080e7          	jalr	-1810(ra) # 59d2 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    40ec:	85ca                	mv	a1,s2
    40ee:	00004517          	auipc	a0,0x4
    40f2:	84250513          	addi	a0,a0,-1982 # 7930 <malloc+0x1b14>
    40f6:	00002097          	auipc	ra,0x2
    40fa:	c6e080e7          	jalr	-914(ra) # 5d64 <printf>
    exit(1);
    40fe:	4505                	li	a0,1
    4100:	00002097          	auipc	ra,0x2
    4104:	8d2080e7          	jalr	-1838(ra) # 59d2 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4108:	85ca                	mv	a1,s2
    410a:	00004517          	auipc	a0,0x4
    410e:	82650513          	addi	a0,a0,-2010 # 7930 <malloc+0x1b14>
    4112:	00002097          	auipc	ra,0x2
    4116:	c52080e7          	jalr	-942(ra) # 5d64 <printf>
    exit(1);
    411a:	4505                	li	a0,1
    411c:	00002097          	auipc	ra,0x2
    4120:	8b6080e7          	jalr	-1866(ra) # 59d2 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    4124:	85ca                	mv	a1,s2
    4126:	00004517          	auipc	a0,0x4
    412a:	83250513          	addi	a0,a0,-1998 # 7958 <malloc+0x1b3c>
    412e:	00002097          	auipc	ra,0x2
    4132:	c36080e7          	jalr	-970(ra) # 5d64 <printf>
    exit(1);
    4136:	4505                	li	a0,1
    4138:	00002097          	auipc	ra,0x2
    413c:	89a080e7          	jalr	-1894(ra) # 59d2 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    4140:	85ca                	mv	a1,s2
    4142:	00004517          	auipc	a0,0x4
    4146:	83e50513          	addi	a0,a0,-1986 # 7980 <malloc+0x1b64>
    414a:	00002097          	auipc	ra,0x2
    414e:	c1a080e7          	jalr	-998(ra) # 5d64 <printf>
    exit(1);
    4152:	4505                	li	a0,1
    4154:	00002097          	auipc	ra,0x2
    4158:	87e080e7          	jalr	-1922(ra) # 59d2 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    415c:	85ca                	mv	a1,s2
    415e:	00004517          	auipc	a0,0x4
    4162:	84a50513          	addi	a0,a0,-1974 # 79a8 <malloc+0x1b8c>
    4166:	00002097          	auipc	ra,0x2
    416a:	bfe080e7          	jalr	-1026(ra) # 5d64 <printf>
    exit(1);
    416e:	4505                	li	a0,1
    4170:	00002097          	auipc	ra,0x2
    4174:	862080e7          	jalr	-1950(ra) # 59d2 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    4178:	85ca                	mv	a1,s2
    417a:	00004517          	auipc	a0,0x4
    417e:	85650513          	addi	a0,a0,-1962 # 79d0 <malloc+0x1bb4>
    4182:	00002097          	auipc	ra,0x2
    4186:	be2080e7          	jalr	-1054(ra) # 5d64 <printf>
    exit(1);
    418a:	4505                	li	a0,1
    418c:	00002097          	auipc	ra,0x2
    4190:	846080e7          	jalr	-1978(ra) # 59d2 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    4194:	85ca                	mv	a1,s2
    4196:	00004517          	auipc	a0,0x4
    419a:	85a50513          	addi	a0,a0,-1958 # 79f0 <malloc+0x1bd4>
    419e:	00002097          	auipc	ra,0x2
    41a2:	bc6080e7          	jalr	-1082(ra) # 5d64 <printf>
    exit(1);
    41a6:	4505                	li	a0,1
    41a8:	00002097          	auipc	ra,0x2
    41ac:	82a080e7          	jalr	-2006(ra) # 59d2 <exit>
    printf("%s: write . succeeded!\n", s);
    41b0:	85ca                	mv	a1,s2
    41b2:	00004517          	auipc	a0,0x4
    41b6:	86650513          	addi	a0,a0,-1946 # 7a18 <malloc+0x1bfc>
    41ba:	00002097          	auipc	ra,0x2
    41be:	baa080e7          	jalr	-1110(ra) # 5d64 <printf>
    exit(1);
    41c2:	4505                	li	a0,1
    41c4:	00002097          	auipc	ra,0x2
    41c8:	80e080e7          	jalr	-2034(ra) # 59d2 <exit>

00000000000041cc <iref>:
{
    41cc:	7139                	addi	sp,sp,-64
    41ce:	fc06                	sd	ra,56(sp)
    41d0:	f822                	sd	s0,48(sp)
    41d2:	f426                	sd	s1,40(sp)
    41d4:	f04a                	sd	s2,32(sp)
    41d6:	ec4e                	sd	s3,24(sp)
    41d8:	e852                	sd	s4,16(sp)
    41da:	e456                	sd	s5,8(sp)
    41dc:	e05a                	sd	s6,0(sp)
    41de:	0080                	addi	s0,sp,64
    41e0:	8b2a                	mv	s6,a0
    41e2:	03300913          	li	s2,51
    if (mkdir("irefd") != 0)
    41e6:	00004a17          	auipc	s4,0x4
    41ea:	84aa0a13          	addi	s4,s4,-1974 # 7a30 <malloc+0x1c14>
    mkdir("");
    41ee:	00003497          	auipc	s1,0x3
    41f2:	34a48493          	addi	s1,s1,842 # 7538 <malloc+0x171c>
    link("README", "");
    41f6:	00002a97          	auipc	s5,0x2
    41fa:	f2aa8a93          	addi	s5,s5,-214 # 6120 <malloc+0x304>
    fd = open("xx", O_CREATE);
    41fe:	00003997          	auipc	s3,0x3
    4202:	72a98993          	addi	s3,s3,1834 # 7928 <malloc+0x1b0c>
    4206:	a891                	j	425a <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    4208:	85da                	mv	a1,s6
    420a:	00004517          	auipc	a0,0x4
    420e:	82e50513          	addi	a0,a0,-2002 # 7a38 <malloc+0x1c1c>
    4212:	00002097          	auipc	ra,0x2
    4216:	b52080e7          	jalr	-1198(ra) # 5d64 <printf>
      exit(1);
    421a:	4505                	li	a0,1
    421c:	00001097          	auipc	ra,0x1
    4220:	7b6080e7          	jalr	1974(ra) # 59d2 <exit>
      printf("%s: chdir irefd failed\n", s);
    4224:	85da                	mv	a1,s6
    4226:	00004517          	auipc	a0,0x4
    422a:	82a50513          	addi	a0,a0,-2006 # 7a50 <malloc+0x1c34>
    422e:	00002097          	auipc	ra,0x2
    4232:	b36080e7          	jalr	-1226(ra) # 5d64 <printf>
      exit(1);
    4236:	4505                	li	a0,1
    4238:	00001097          	auipc	ra,0x1
    423c:	79a080e7          	jalr	1946(ra) # 59d2 <exit>
      close(fd);
    4240:	00001097          	auipc	ra,0x1
    4244:	7ba080e7          	jalr	1978(ra) # 59fa <close>
    4248:	a889                	j	429a <iref+0xce>
    unlink("xx");
    424a:	854e                	mv	a0,s3
    424c:	00001097          	auipc	ra,0x1
    4250:	7d6080e7          	jalr	2006(ra) # 5a22 <unlink>
  for (i = 0; i < NINODE + 1; i++)
    4254:	397d                	addiw	s2,s2,-1
    4256:	06090063          	beqz	s2,42b6 <iref+0xea>
    if (mkdir("irefd") != 0)
    425a:	8552                	mv	a0,s4
    425c:	00001097          	auipc	ra,0x1
    4260:	7de080e7          	jalr	2014(ra) # 5a3a <mkdir>
    4264:	f155                	bnez	a0,4208 <iref+0x3c>
    if (chdir("irefd") != 0)
    4266:	8552                	mv	a0,s4
    4268:	00001097          	auipc	ra,0x1
    426c:	7da080e7          	jalr	2010(ra) # 5a42 <chdir>
    4270:	f955                	bnez	a0,4224 <iref+0x58>
    mkdir("");
    4272:	8526                	mv	a0,s1
    4274:	00001097          	auipc	ra,0x1
    4278:	7c6080e7          	jalr	1990(ra) # 5a3a <mkdir>
    link("README", "");
    427c:	85a6                	mv	a1,s1
    427e:	8556                	mv	a0,s5
    4280:	00001097          	auipc	ra,0x1
    4284:	7b2080e7          	jalr	1970(ra) # 5a32 <link>
    fd = open("", O_CREATE);
    4288:	20000593          	li	a1,512
    428c:	8526                	mv	a0,s1
    428e:	00001097          	auipc	ra,0x1
    4292:	784080e7          	jalr	1924(ra) # 5a12 <open>
    if (fd >= 0)
    4296:	fa0555e3          	bgez	a0,4240 <iref+0x74>
    fd = open("xx", O_CREATE);
    429a:	20000593          	li	a1,512
    429e:	854e                	mv	a0,s3
    42a0:	00001097          	auipc	ra,0x1
    42a4:	772080e7          	jalr	1906(ra) # 5a12 <open>
    if (fd >= 0)
    42a8:	fa0541e3          	bltz	a0,424a <iref+0x7e>
      close(fd);
    42ac:	00001097          	auipc	ra,0x1
    42b0:	74e080e7          	jalr	1870(ra) # 59fa <close>
    42b4:	bf59                	j	424a <iref+0x7e>
    42b6:	03300493          	li	s1,51
    chdir("..");
    42ba:	00003997          	auipc	s3,0x3
    42be:	f9e98993          	addi	s3,s3,-98 # 7258 <malloc+0x143c>
    unlink("irefd");
    42c2:	00003917          	auipc	s2,0x3
    42c6:	76e90913          	addi	s2,s2,1902 # 7a30 <malloc+0x1c14>
    chdir("..");
    42ca:	854e                	mv	a0,s3
    42cc:	00001097          	auipc	ra,0x1
    42d0:	776080e7          	jalr	1910(ra) # 5a42 <chdir>
    unlink("irefd");
    42d4:	854a                	mv	a0,s2
    42d6:	00001097          	auipc	ra,0x1
    42da:	74c080e7          	jalr	1868(ra) # 5a22 <unlink>
  for (i = 0; i < NINODE + 1; i++)
    42de:	34fd                	addiw	s1,s1,-1
    42e0:	f4ed                	bnez	s1,42ca <iref+0xfe>
  chdir("/");
    42e2:	00003517          	auipc	a0,0x3
    42e6:	f1e50513          	addi	a0,a0,-226 # 7200 <malloc+0x13e4>
    42ea:	00001097          	auipc	ra,0x1
    42ee:	758080e7          	jalr	1880(ra) # 5a42 <chdir>
}
    42f2:	70e2                	ld	ra,56(sp)
    42f4:	7442                	ld	s0,48(sp)
    42f6:	74a2                	ld	s1,40(sp)
    42f8:	7902                	ld	s2,32(sp)
    42fa:	69e2                	ld	s3,24(sp)
    42fc:	6a42                	ld	s4,16(sp)
    42fe:	6aa2                	ld	s5,8(sp)
    4300:	6b02                	ld	s6,0(sp)
    4302:	6121                	addi	sp,sp,64
    4304:	8082                	ret

0000000000004306 <openiputtest>:
{
    4306:	7179                	addi	sp,sp,-48
    4308:	f406                	sd	ra,40(sp)
    430a:	f022                	sd	s0,32(sp)
    430c:	ec26                	sd	s1,24(sp)
    430e:	1800                	addi	s0,sp,48
    4310:	84aa                	mv	s1,a0
  if (mkdir("oidir") < 0)
    4312:	00003517          	auipc	a0,0x3
    4316:	75650513          	addi	a0,a0,1878 # 7a68 <malloc+0x1c4c>
    431a:	00001097          	auipc	ra,0x1
    431e:	720080e7          	jalr	1824(ra) # 5a3a <mkdir>
    4322:	04054263          	bltz	a0,4366 <openiputtest+0x60>
  pid = fork();
    4326:	00001097          	auipc	ra,0x1
    432a:	6a4080e7          	jalr	1700(ra) # 59ca <fork>
  if (pid < 0)
    432e:	04054a63          	bltz	a0,4382 <openiputtest+0x7c>
  if (pid == 0)
    4332:	e93d                	bnez	a0,43a8 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    4334:	4589                	li	a1,2
    4336:	00003517          	auipc	a0,0x3
    433a:	73250513          	addi	a0,a0,1842 # 7a68 <malloc+0x1c4c>
    433e:	00001097          	auipc	ra,0x1
    4342:	6d4080e7          	jalr	1748(ra) # 5a12 <open>
    if (fd >= 0)
    4346:	04054c63          	bltz	a0,439e <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    434a:	85a6                	mv	a1,s1
    434c:	00003517          	auipc	a0,0x3
    4350:	73c50513          	addi	a0,a0,1852 # 7a88 <malloc+0x1c6c>
    4354:	00002097          	auipc	ra,0x2
    4358:	a10080e7          	jalr	-1520(ra) # 5d64 <printf>
      exit(1);
    435c:	4505                	li	a0,1
    435e:	00001097          	auipc	ra,0x1
    4362:	674080e7          	jalr	1652(ra) # 59d2 <exit>
    printf("%s: mkdir oidir failed\n", s);
    4366:	85a6                	mv	a1,s1
    4368:	00003517          	auipc	a0,0x3
    436c:	70850513          	addi	a0,a0,1800 # 7a70 <malloc+0x1c54>
    4370:	00002097          	auipc	ra,0x2
    4374:	9f4080e7          	jalr	-1548(ra) # 5d64 <printf>
    exit(1);
    4378:	4505                	li	a0,1
    437a:	00001097          	auipc	ra,0x1
    437e:	658080e7          	jalr	1624(ra) # 59d2 <exit>
    printf("%s: fork failed\n", s);
    4382:	85a6                	mv	a1,s1
    4384:	00002517          	auipc	a0,0x2
    4388:	44c50513          	addi	a0,a0,1100 # 67d0 <malloc+0x9b4>
    438c:	00002097          	auipc	ra,0x2
    4390:	9d8080e7          	jalr	-1576(ra) # 5d64 <printf>
    exit(1);
    4394:	4505                	li	a0,1
    4396:	00001097          	auipc	ra,0x1
    439a:	63c080e7          	jalr	1596(ra) # 59d2 <exit>
    exit(0);
    439e:	4501                	li	a0,0
    43a0:	00001097          	auipc	ra,0x1
    43a4:	632080e7          	jalr	1586(ra) # 59d2 <exit>
  sleep(1);
    43a8:	4505                	li	a0,1
    43aa:	00001097          	auipc	ra,0x1
    43ae:	6b8080e7          	jalr	1720(ra) # 5a62 <sleep>
  if (unlink("oidir") != 0)
    43b2:	00003517          	auipc	a0,0x3
    43b6:	6b650513          	addi	a0,a0,1718 # 7a68 <malloc+0x1c4c>
    43ba:	00001097          	auipc	ra,0x1
    43be:	668080e7          	jalr	1640(ra) # 5a22 <unlink>
    43c2:	cd19                	beqz	a0,43e0 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    43c4:	85a6                	mv	a1,s1
    43c6:	00002517          	auipc	a0,0x2
    43ca:	5fa50513          	addi	a0,a0,1530 # 69c0 <malloc+0xba4>
    43ce:	00002097          	auipc	ra,0x2
    43d2:	996080e7          	jalr	-1642(ra) # 5d64 <printf>
    exit(1);
    43d6:	4505                	li	a0,1
    43d8:	00001097          	auipc	ra,0x1
    43dc:	5fa080e7          	jalr	1530(ra) # 59d2 <exit>
  wait(&xstatus);
    43e0:	fdc40513          	addi	a0,s0,-36
    43e4:	00001097          	auipc	ra,0x1
    43e8:	5f6080e7          	jalr	1526(ra) # 59da <wait>
  exit(xstatus);
    43ec:	fdc42503          	lw	a0,-36(s0)
    43f0:	00001097          	auipc	ra,0x1
    43f4:	5e2080e7          	jalr	1506(ra) # 59d2 <exit>

00000000000043f8 <forkforkfork>:
{
    43f8:	1101                	addi	sp,sp,-32
    43fa:	ec06                	sd	ra,24(sp)
    43fc:	e822                	sd	s0,16(sp)
    43fe:	e426                	sd	s1,8(sp)
    4400:	1000                	addi	s0,sp,32
    4402:	84aa                	mv	s1,a0
  unlink("stopforking");
    4404:	00003517          	auipc	a0,0x3
    4408:	6ac50513          	addi	a0,a0,1708 # 7ab0 <malloc+0x1c94>
    440c:	00001097          	auipc	ra,0x1
    4410:	616080e7          	jalr	1558(ra) # 5a22 <unlink>
  int pid = fork();
    4414:	00001097          	auipc	ra,0x1
    4418:	5b6080e7          	jalr	1462(ra) # 59ca <fork>
  if (pid < 0)
    441c:	04054563          	bltz	a0,4466 <forkforkfork+0x6e>
  if (pid == 0)
    4420:	c12d                	beqz	a0,4482 <forkforkfork+0x8a>
  sleep(20); // two seconds
    4422:	4551                	li	a0,20
    4424:	00001097          	auipc	ra,0x1
    4428:	63e080e7          	jalr	1598(ra) # 5a62 <sleep>
  close(open("stopforking", O_CREATE | O_RDWR));
    442c:	20200593          	li	a1,514
    4430:	00003517          	auipc	a0,0x3
    4434:	68050513          	addi	a0,a0,1664 # 7ab0 <malloc+0x1c94>
    4438:	00001097          	auipc	ra,0x1
    443c:	5da080e7          	jalr	1498(ra) # 5a12 <open>
    4440:	00001097          	auipc	ra,0x1
    4444:	5ba080e7          	jalr	1466(ra) # 59fa <close>
  wait(0);
    4448:	4501                	li	a0,0
    444a:	00001097          	auipc	ra,0x1
    444e:	590080e7          	jalr	1424(ra) # 59da <wait>
  sleep(10); // one second
    4452:	4529                	li	a0,10
    4454:	00001097          	auipc	ra,0x1
    4458:	60e080e7          	jalr	1550(ra) # 5a62 <sleep>
}
    445c:	60e2                	ld	ra,24(sp)
    445e:	6442                	ld	s0,16(sp)
    4460:	64a2                	ld	s1,8(sp)
    4462:	6105                	addi	sp,sp,32
    4464:	8082                	ret
    printf("%s: fork failed", s);
    4466:	85a6                	mv	a1,s1
    4468:	00002517          	auipc	a0,0x2
    446c:	52850513          	addi	a0,a0,1320 # 6990 <malloc+0xb74>
    4470:	00002097          	auipc	ra,0x2
    4474:	8f4080e7          	jalr	-1804(ra) # 5d64 <printf>
    exit(1);
    4478:	4505                	li	a0,1
    447a:	00001097          	auipc	ra,0x1
    447e:	558080e7          	jalr	1368(ra) # 59d2 <exit>
      int fd = open("stopforking", 0);
    4482:	00003497          	auipc	s1,0x3
    4486:	62e48493          	addi	s1,s1,1582 # 7ab0 <malloc+0x1c94>
    448a:	4581                	li	a1,0
    448c:	8526                	mv	a0,s1
    448e:	00001097          	auipc	ra,0x1
    4492:	584080e7          	jalr	1412(ra) # 5a12 <open>
      if (fd >= 0)
    4496:	02055463          	bgez	a0,44be <forkforkfork+0xc6>
      if (fork() < 0)
    449a:	00001097          	auipc	ra,0x1
    449e:	530080e7          	jalr	1328(ra) # 59ca <fork>
    44a2:	fe0554e3          	bgez	a0,448a <forkforkfork+0x92>
        close(open("stopforking", O_CREATE | O_RDWR));
    44a6:	20200593          	li	a1,514
    44aa:	8526                	mv	a0,s1
    44ac:	00001097          	auipc	ra,0x1
    44b0:	566080e7          	jalr	1382(ra) # 5a12 <open>
    44b4:	00001097          	auipc	ra,0x1
    44b8:	546080e7          	jalr	1350(ra) # 59fa <close>
    44bc:	b7f9                	j	448a <forkforkfork+0x92>
        exit(0);
    44be:	4501                	li	a0,0
    44c0:	00001097          	auipc	ra,0x1
    44c4:	512080e7          	jalr	1298(ra) # 59d2 <exit>

00000000000044c8 <killstatus>:
{
    44c8:	7139                	addi	sp,sp,-64
    44ca:	fc06                	sd	ra,56(sp)
    44cc:	f822                	sd	s0,48(sp)
    44ce:	f426                	sd	s1,40(sp)
    44d0:	f04a                	sd	s2,32(sp)
    44d2:	ec4e                	sd	s3,24(sp)
    44d4:	e852                	sd	s4,16(sp)
    44d6:	0080                	addi	s0,sp,64
    44d8:	8a2a                	mv	s4,a0
    44da:	06400913          	li	s2,100
    if (xst != -1)
    44de:	59fd                	li	s3,-1
    int pid1 = fork();
    44e0:	00001097          	auipc	ra,0x1
    44e4:	4ea080e7          	jalr	1258(ra) # 59ca <fork>
    44e8:	84aa                	mv	s1,a0
    if (pid1 < 0)
    44ea:	02054f63          	bltz	a0,4528 <killstatus+0x60>
    if (pid1 == 0)
    44ee:	c939                	beqz	a0,4544 <killstatus+0x7c>
    sleep(1);
    44f0:	4505                	li	a0,1
    44f2:	00001097          	auipc	ra,0x1
    44f6:	570080e7          	jalr	1392(ra) # 5a62 <sleep>
    kill(pid1);
    44fa:	8526                	mv	a0,s1
    44fc:	00001097          	auipc	ra,0x1
    4500:	506080e7          	jalr	1286(ra) # 5a02 <kill>
    wait(&xst);
    4504:	fcc40513          	addi	a0,s0,-52
    4508:	00001097          	auipc	ra,0x1
    450c:	4d2080e7          	jalr	1234(ra) # 59da <wait>
    if (xst != -1)
    4510:	fcc42783          	lw	a5,-52(s0)
    4514:	03379d63          	bne	a5,s3,454e <killstatus+0x86>
  for (int i = 0; i < 100; i++)
    4518:	397d                	addiw	s2,s2,-1
    451a:	fc0913e3          	bnez	s2,44e0 <killstatus+0x18>
  exit(0);
    451e:	4501                	li	a0,0
    4520:	00001097          	auipc	ra,0x1
    4524:	4b2080e7          	jalr	1202(ra) # 59d2 <exit>
      printf("%s: fork failed\n", s);
    4528:	85d2                	mv	a1,s4
    452a:	00002517          	auipc	a0,0x2
    452e:	2a650513          	addi	a0,a0,678 # 67d0 <malloc+0x9b4>
    4532:	00002097          	auipc	ra,0x2
    4536:	832080e7          	jalr	-1998(ra) # 5d64 <printf>
      exit(1);
    453a:	4505                	li	a0,1
    453c:	00001097          	auipc	ra,0x1
    4540:	496080e7          	jalr	1174(ra) # 59d2 <exit>
        getpid();
    4544:	00001097          	auipc	ra,0x1
    4548:	50e080e7          	jalr	1294(ra) # 5a52 <getpid>
      while (1)
    454c:	bfe5                	j	4544 <killstatus+0x7c>
      printf("%s: status should be -1\n", s);
    454e:	85d2                	mv	a1,s4
    4550:	00003517          	auipc	a0,0x3
    4554:	57050513          	addi	a0,a0,1392 # 7ac0 <malloc+0x1ca4>
    4558:	00002097          	auipc	ra,0x2
    455c:	80c080e7          	jalr	-2036(ra) # 5d64 <printf>
      exit(1);
    4560:	4505                	li	a0,1
    4562:	00001097          	auipc	ra,0x1
    4566:	470080e7          	jalr	1136(ra) # 59d2 <exit>

000000000000456a <reparent>:
{
    456a:	7179                	addi	sp,sp,-48
    456c:	f406                	sd	ra,40(sp)
    456e:	f022                	sd	s0,32(sp)
    4570:	ec26                	sd	s1,24(sp)
    4572:	e84a                	sd	s2,16(sp)
    4574:	e44e                	sd	s3,8(sp)
    4576:	e052                	sd	s4,0(sp)
    4578:	1800                	addi	s0,sp,48
    457a:	89aa                	mv	s3,a0
  int master_pid = getpid();
    457c:	00001097          	auipc	ra,0x1
    4580:	4d6080e7          	jalr	1238(ra) # 5a52 <getpid>
    4584:	8a2a                	mv	s4,a0
    4586:	0c800913          	li	s2,200
    int pid = fork();
    458a:	00001097          	auipc	ra,0x1
    458e:	440080e7          	jalr	1088(ra) # 59ca <fork>
    4592:	84aa                	mv	s1,a0
    if (pid < 0)
    4594:	02054263          	bltz	a0,45b8 <reparent+0x4e>
    if (pid)
    4598:	cd21                	beqz	a0,45f0 <reparent+0x86>
      if (wait(0) != pid)
    459a:	4501                	li	a0,0
    459c:	00001097          	auipc	ra,0x1
    45a0:	43e080e7          	jalr	1086(ra) # 59da <wait>
    45a4:	02951863          	bne	a0,s1,45d4 <reparent+0x6a>
  for (int i = 0; i < 200; i++)
    45a8:	397d                	addiw	s2,s2,-1
    45aa:	fe0910e3          	bnez	s2,458a <reparent+0x20>
  exit(0);
    45ae:	4501                	li	a0,0
    45b0:	00001097          	auipc	ra,0x1
    45b4:	422080e7          	jalr	1058(ra) # 59d2 <exit>
      printf("%s: fork failed\n", s);
    45b8:	85ce                	mv	a1,s3
    45ba:	00002517          	auipc	a0,0x2
    45be:	21650513          	addi	a0,a0,534 # 67d0 <malloc+0x9b4>
    45c2:	00001097          	auipc	ra,0x1
    45c6:	7a2080e7          	jalr	1954(ra) # 5d64 <printf>
      exit(1);
    45ca:	4505                	li	a0,1
    45cc:	00001097          	auipc	ra,0x1
    45d0:	406080e7          	jalr	1030(ra) # 59d2 <exit>
        printf("%s: wait wrong pid\n", s);
    45d4:	85ce                	mv	a1,s3
    45d6:	00002517          	auipc	a0,0x2
    45da:	38250513          	addi	a0,a0,898 # 6958 <malloc+0xb3c>
    45de:	00001097          	auipc	ra,0x1
    45e2:	786080e7          	jalr	1926(ra) # 5d64 <printf>
        exit(1);
    45e6:	4505                	li	a0,1
    45e8:	00001097          	auipc	ra,0x1
    45ec:	3ea080e7          	jalr	1002(ra) # 59d2 <exit>
      int pid2 = fork();
    45f0:	00001097          	auipc	ra,0x1
    45f4:	3da080e7          	jalr	986(ra) # 59ca <fork>
      if (pid2 < 0)
    45f8:	00054763          	bltz	a0,4606 <reparent+0x9c>
      exit(0);
    45fc:	4501                	li	a0,0
    45fe:	00001097          	auipc	ra,0x1
    4602:	3d4080e7          	jalr	980(ra) # 59d2 <exit>
        kill(master_pid);
    4606:	8552                	mv	a0,s4
    4608:	00001097          	auipc	ra,0x1
    460c:	3fa080e7          	jalr	1018(ra) # 5a02 <kill>
        exit(1);
    4610:	4505                	li	a0,1
    4612:	00001097          	auipc	ra,0x1
    4616:	3c0080e7          	jalr	960(ra) # 59d2 <exit>

000000000000461a <sbrkfail>:
{
    461a:	7119                	addi	sp,sp,-128
    461c:	fc86                	sd	ra,120(sp)
    461e:	f8a2                	sd	s0,112(sp)
    4620:	f4a6                	sd	s1,104(sp)
    4622:	f0ca                	sd	s2,96(sp)
    4624:	ecce                	sd	s3,88(sp)
    4626:	e8d2                	sd	s4,80(sp)
    4628:	e4d6                	sd	s5,72(sp)
    462a:	0100                	addi	s0,sp,128
    462c:	8aaa                	mv	s5,a0
  if (pipe(fds) != 0)
    462e:	fb040513          	addi	a0,s0,-80
    4632:	00001097          	auipc	ra,0x1
    4636:	3b0080e7          	jalr	944(ra) # 59e2 <pipe>
    463a:	e901                	bnez	a0,464a <sbrkfail+0x30>
    463c:	f8040493          	addi	s1,s0,-128
    4640:	fa840993          	addi	s3,s0,-88
    4644:	8926                	mv	s2,s1
    if (pids[i] != -1)
    4646:	5a7d                	li	s4,-1
    4648:	a085                	j	46a8 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    464a:	85d6                	mv	a1,s5
    464c:	00002517          	auipc	a0,0x2
    4650:	28c50513          	addi	a0,a0,652 # 68d8 <malloc+0xabc>
    4654:	00001097          	auipc	ra,0x1
    4658:	710080e7          	jalr	1808(ra) # 5d64 <printf>
    exit(1);
    465c:	4505                	li	a0,1
    465e:	00001097          	auipc	ra,0x1
    4662:	374080e7          	jalr	884(ra) # 59d2 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4666:	00001097          	auipc	ra,0x1
    466a:	3f4080e7          	jalr	1012(ra) # 5a5a <sbrk>
    466e:	064007b7          	lui	a5,0x6400
    4672:	40a7853b          	subw	a0,a5,a0
    4676:	00001097          	auipc	ra,0x1
    467a:	3e4080e7          	jalr	996(ra) # 5a5a <sbrk>
      write(fds[1], "x", 1);
    467e:	4605                	li	a2,1
    4680:	00002597          	auipc	a1,0x2
    4684:	93858593          	addi	a1,a1,-1736 # 5fb8 <malloc+0x19c>
    4688:	fb442503          	lw	a0,-76(s0)
    468c:	00001097          	auipc	ra,0x1
    4690:	366080e7          	jalr	870(ra) # 59f2 <write>
        sleep(1000);
    4694:	3e800513          	li	a0,1000
    4698:	00001097          	auipc	ra,0x1
    469c:	3ca080e7          	jalr	970(ra) # 5a62 <sleep>
      for (;;)
    46a0:	bfd5                	j	4694 <sbrkfail+0x7a>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++)
    46a2:	0911                	addi	s2,s2,4
    46a4:	03390563          	beq	s2,s3,46ce <sbrkfail+0xb4>
    if ((pids[i] = fork()) == 0)
    46a8:	00001097          	auipc	ra,0x1
    46ac:	322080e7          	jalr	802(ra) # 59ca <fork>
    46b0:	00a92023          	sw	a0,0(s2)
    46b4:	d94d                	beqz	a0,4666 <sbrkfail+0x4c>
    if (pids[i] != -1)
    46b6:	ff4506e3          	beq	a0,s4,46a2 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    46ba:	4605                	li	a2,1
    46bc:	faf40593          	addi	a1,s0,-81
    46c0:	fb042503          	lw	a0,-80(s0)
    46c4:	00001097          	auipc	ra,0x1
    46c8:	326080e7          	jalr	806(ra) # 59ea <read>
    46cc:	bfd9                	j	46a2 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    46ce:	6505                	lui	a0,0x1
    46d0:	00001097          	auipc	ra,0x1
    46d4:	38a080e7          	jalr	906(ra) # 5a5a <sbrk>
    46d8:	8a2a                	mv	s4,a0
    if (pids[i] == -1)
    46da:	597d                	li	s2,-1
    46dc:	a021                	j	46e4 <sbrkfail+0xca>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++)
    46de:	0491                	addi	s1,s1,4
    46e0:	01348f63          	beq	s1,s3,46fe <sbrkfail+0xe4>
    if (pids[i] == -1)
    46e4:	4088                	lw	a0,0(s1)
    46e6:	ff250ce3          	beq	a0,s2,46de <sbrkfail+0xc4>
    kill(pids[i]);
    46ea:	00001097          	auipc	ra,0x1
    46ee:	318080e7          	jalr	792(ra) # 5a02 <kill>
    wait(0);
    46f2:	4501                	li	a0,0
    46f4:	00001097          	auipc	ra,0x1
    46f8:	2e6080e7          	jalr	742(ra) # 59da <wait>
    46fc:	b7cd                	j	46de <sbrkfail+0xc4>
  if (c == (char *)0xffffffffffffffffL)
    46fe:	57fd                	li	a5,-1
    4700:	04fa0163          	beq	s4,a5,4742 <sbrkfail+0x128>
  pid = fork();
    4704:	00001097          	auipc	ra,0x1
    4708:	2c6080e7          	jalr	710(ra) # 59ca <fork>
    470c:	84aa                	mv	s1,a0
  if (pid < 0)
    470e:	04054863          	bltz	a0,475e <sbrkfail+0x144>
  if (pid == 0)
    4712:	c525                	beqz	a0,477a <sbrkfail+0x160>
  wait(&xstatus);
    4714:	fbc40513          	addi	a0,s0,-68
    4718:	00001097          	auipc	ra,0x1
    471c:	2c2080e7          	jalr	706(ra) # 59da <wait>
  if (xstatus != -1 && xstatus != 2)
    4720:	fbc42783          	lw	a5,-68(s0)
    4724:	577d                	li	a4,-1
    4726:	00e78563          	beq	a5,a4,4730 <sbrkfail+0x116>
    472a:	4709                	li	a4,2
    472c:	08e79d63          	bne	a5,a4,47c6 <sbrkfail+0x1ac>
}
    4730:	70e6                	ld	ra,120(sp)
    4732:	7446                	ld	s0,112(sp)
    4734:	74a6                	ld	s1,104(sp)
    4736:	7906                	ld	s2,96(sp)
    4738:	69e6                	ld	s3,88(sp)
    473a:	6a46                	ld	s4,80(sp)
    473c:	6aa6                	ld	s5,72(sp)
    473e:	6109                	addi	sp,sp,128
    4740:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4742:	85d6                	mv	a1,s5
    4744:	00003517          	auipc	a0,0x3
    4748:	39c50513          	addi	a0,a0,924 # 7ae0 <malloc+0x1cc4>
    474c:	00001097          	auipc	ra,0x1
    4750:	618080e7          	jalr	1560(ra) # 5d64 <printf>
    exit(1);
    4754:	4505                	li	a0,1
    4756:	00001097          	auipc	ra,0x1
    475a:	27c080e7          	jalr	636(ra) # 59d2 <exit>
    printf("%s: fork failed\n", s);
    475e:	85d6                	mv	a1,s5
    4760:	00002517          	auipc	a0,0x2
    4764:	07050513          	addi	a0,a0,112 # 67d0 <malloc+0x9b4>
    4768:	00001097          	auipc	ra,0x1
    476c:	5fc080e7          	jalr	1532(ra) # 5d64 <printf>
    exit(1);
    4770:	4505                	li	a0,1
    4772:	00001097          	auipc	ra,0x1
    4776:	260080e7          	jalr	608(ra) # 59d2 <exit>
    a = sbrk(0);
    477a:	4501                	li	a0,0
    477c:	00001097          	auipc	ra,0x1
    4780:	2de080e7          	jalr	734(ra) # 5a5a <sbrk>
    4784:	892a                	mv	s2,a0
    sbrk(10 * BIG);
    4786:	3e800537          	lui	a0,0x3e800
    478a:	00001097          	auipc	ra,0x1
    478e:	2d0080e7          	jalr	720(ra) # 5a5a <sbrk>
    for (i = 0; i < 10 * BIG; i += PGSIZE)
    4792:	87ca                	mv	a5,s2
    4794:	3e800737          	lui	a4,0x3e800
    4798:	993a                	add	s2,s2,a4
    479a:	6705                	lui	a4,0x1
      n += *(a + i);
    479c:	0007c683          	lbu	a3,0(a5) # 6400000 <base+0x63f0388>
    47a0:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10 * BIG; i += PGSIZE)
    47a2:	97ba                	add	a5,a5,a4
    47a4:	ff279ce3          	bne	a5,s2,479c <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    47a8:	8626                	mv	a2,s1
    47aa:	85d6                	mv	a1,s5
    47ac:	00003517          	auipc	a0,0x3
    47b0:	35450513          	addi	a0,a0,852 # 7b00 <malloc+0x1ce4>
    47b4:	00001097          	auipc	ra,0x1
    47b8:	5b0080e7          	jalr	1456(ra) # 5d64 <printf>
    exit(1);
    47bc:	4505                	li	a0,1
    47be:	00001097          	auipc	ra,0x1
    47c2:	214080e7          	jalr	532(ra) # 59d2 <exit>
    exit(1);
    47c6:	4505                	li	a0,1
    47c8:	00001097          	auipc	ra,0x1
    47cc:	20a080e7          	jalr	522(ra) # 59d2 <exit>

00000000000047d0 <mem>:
{
    47d0:	7139                	addi	sp,sp,-64
    47d2:	fc06                	sd	ra,56(sp)
    47d4:	f822                	sd	s0,48(sp)
    47d6:	f426                	sd	s1,40(sp)
    47d8:	f04a                	sd	s2,32(sp)
    47da:	ec4e                	sd	s3,24(sp)
    47dc:	0080                	addi	s0,sp,64
    47de:	89aa                	mv	s3,a0
  if ((pid = fork()) == 0)
    47e0:	00001097          	auipc	ra,0x1
    47e4:	1ea080e7          	jalr	490(ra) # 59ca <fork>
    m1 = 0;
    47e8:	4481                	li	s1,0
    while ((m2 = malloc(10001)) != 0)
    47ea:	6909                	lui	s2,0x2
    47ec:	71190913          	addi	s2,s2,1809 # 2711 <rwsbrk+0x5>
  if ((pid = fork()) == 0)
    47f0:	c115                	beqz	a0,4814 <mem+0x44>
    wait(&xstatus);
    47f2:	fcc40513          	addi	a0,s0,-52
    47f6:	00001097          	auipc	ra,0x1
    47fa:	1e4080e7          	jalr	484(ra) # 59da <wait>
    if (xstatus == -1)
    47fe:	fcc42503          	lw	a0,-52(s0)
    4802:	57fd                	li	a5,-1
    4804:	06f50363          	beq	a0,a5,486a <mem+0x9a>
    exit(xstatus);
    4808:	00001097          	auipc	ra,0x1
    480c:	1ca080e7          	jalr	458(ra) # 59d2 <exit>
      *(char **)m2 = m1;
    4810:	e104                	sd	s1,0(a0)
      m1 = m2;
    4812:	84aa                	mv	s1,a0
    while ((m2 = malloc(10001)) != 0)
    4814:	854a                	mv	a0,s2
    4816:	00001097          	auipc	ra,0x1
    481a:	606080e7          	jalr	1542(ra) # 5e1c <malloc>
    481e:	f96d                	bnez	a0,4810 <mem+0x40>
    while (m1)
    4820:	c881                	beqz	s1,4830 <mem+0x60>
      m2 = *(char **)m1;
    4822:	8526                	mv	a0,s1
    4824:	6084                	ld	s1,0(s1)
      free(m1);
    4826:	00001097          	auipc	ra,0x1
    482a:	574080e7          	jalr	1396(ra) # 5d9a <free>
    while (m1)
    482e:	f8f5                	bnez	s1,4822 <mem+0x52>
    m1 = malloc(1024 * 20);
    4830:	6515                	lui	a0,0x5
    4832:	00001097          	auipc	ra,0x1
    4836:	5ea080e7          	jalr	1514(ra) # 5e1c <malloc>
    if (m1 == 0)
    483a:	c911                	beqz	a0,484e <mem+0x7e>
    free(m1);
    483c:	00001097          	auipc	ra,0x1
    4840:	55e080e7          	jalr	1374(ra) # 5d9a <free>
    exit(0);
    4844:	4501                	li	a0,0
    4846:	00001097          	auipc	ra,0x1
    484a:	18c080e7          	jalr	396(ra) # 59d2 <exit>
      printf("couldn't allocate mem?!!\n", s);
    484e:	85ce                	mv	a1,s3
    4850:	00003517          	auipc	a0,0x3
    4854:	2e050513          	addi	a0,a0,736 # 7b30 <malloc+0x1d14>
    4858:	00001097          	auipc	ra,0x1
    485c:	50c080e7          	jalr	1292(ra) # 5d64 <printf>
      exit(1);
    4860:	4505                	li	a0,1
    4862:	00001097          	auipc	ra,0x1
    4866:	170080e7          	jalr	368(ra) # 59d2 <exit>
      exit(0);
    486a:	4501                	li	a0,0
    486c:	00001097          	auipc	ra,0x1
    4870:	166080e7          	jalr	358(ra) # 59d2 <exit>

0000000000004874 <sharedfd>:
{
    4874:	7159                	addi	sp,sp,-112
    4876:	f486                	sd	ra,104(sp)
    4878:	f0a2                	sd	s0,96(sp)
    487a:	eca6                	sd	s1,88(sp)
    487c:	e8ca                	sd	s2,80(sp)
    487e:	e4ce                	sd	s3,72(sp)
    4880:	e0d2                	sd	s4,64(sp)
    4882:	fc56                	sd	s5,56(sp)
    4884:	f85a                	sd	s6,48(sp)
    4886:	f45e                	sd	s7,40(sp)
    4888:	1880                	addi	s0,sp,112
    488a:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    488c:	00003517          	auipc	a0,0x3
    4890:	2c450513          	addi	a0,a0,708 # 7b50 <malloc+0x1d34>
    4894:	00001097          	auipc	ra,0x1
    4898:	18e080e7          	jalr	398(ra) # 5a22 <unlink>
  fd = open("sharedfd", O_CREATE | O_RDWR);
    489c:	20200593          	li	a1,514
    48a0:	00003517          	auipc	a0,0x3
    48a4:	2b050513          	addi	a0,a0,688 # 7b50 <malloc+0x1d34>
    48a8:	00001097          	auipc	ra,0x1
    48ac:	16a080e7          	jalr	362(ra) # 5a12 <open>
  if (fd < 0)
    48b0:	04054a63          	bltz	a0,4904 <sharedfd+0x90>
    48b4:	892a                	mv	s2,a0
  pid = fork();
    48b6:	00001097          	auipc	ra,0x1
    48ba:	114080e7          	jalr	276(ra) # 59ca <fork>
    48be:	89aa                	mv	s3,a0
  memset(buf, pid == 0 ? 'c' : 'p', sizeof(buf));
    48c0:	06300593          	li	a1,99
    48c4:	c119                	beqz	a0,48ca <sharedfd+0x56>
    48c6:	07000593          	li	a1,112
    48ca:	4629                	li	a2,10
    48cc:	fa040513          	addi	a0,s0,-96
    48d0:	00001097          	auipc	ra,0x1
    48d4:	f08080e7          	jalr	-248(ra) # 57d8 <memset>
    48d8:	3e800493          	li	s1,1000
    if (write(fd, buf, sizeof(buf)) != sizeof(buf))
    48dc:	4629                	li	a2,10
    48de:	fa040593          	addi	a1,s0,-96
    48e2:	854a                	mv	a0,s2
    48e4:	00001097          	auipc	ra,0x1
    48e8:	10e080e7          	jalr	270(ra) # 59f2 <write>
    48ec:	47a9                	li	a5,10
    48ee:	02f51963          	bne	a0,a5,4920 <sharedfd+0xac>
  for (i = 0; i < N; i++)
    48f2:	34fd                	addiw	s1,s1,-1
    48f4:	f4e5                	bnez	s1,48dc <sharedfd+0x68>
  if (pid == 0)
    48f6:	04099363          	bnez	s3,493c <sharedfd+0xc8>
    exit(0);
    48fa:	4501                	li	a0,0
    48fc:	00001097          	auipc	ra,0x1
    4900:	0d6080e7          	jalr	214(ra) # 59d2 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4904:	85d2                	mv	a1,s4
    4906:	00003517          	auipc	a0,0x3
    490a:	25a50513          	addi	a0,a0,602 # 7b60 <malloc+0x1d44>
    490e:	00001097          	auipc	ra,0x1
    4912:	456080e7          	jalr	1110(ra) # 5d64 <printf>
    exit(1);
    4916:	4505                	li	a0,1
    4918:	00001097          	auipc	ra,0x1
    491c:	0ba080e7          	jalr	186(ra) # 59d2 <exit>
      printf("%s: write sharedfd failed\n", s);
    4920:	85d2                	mv	a1,s4
    4922:	00003517          	auipc	a0,0x3
    4926:	26650513          	addi	a0,a0,614 # 7b88 <malloc+0x1d6c>
    492a:	00001097          	auipc	ra,0x1
    492e:	43a080e7          	jalr	1082(ra) # 5d64 <printf>
      exit(1);
    4932:	4505                	li	a0,1
    4934:	00001097          	auipc	ra,0x1
    4938:	09e080e7          	jalr	158(ra) # 59d2 <exit>
    wait(&xstatus);
    493c:	f9c40513          	addi	a0,s0,-100
    4940:	00001097          	auipc	ra,0x1
    4944:	09a080e7          	jalr	154(ra) # 59da <wait>
    if (xstatus != 0)
    4948:	f9c42983          	lw	s3,-100(s0)
    494c:	00098763          	beqz	s3,495a <sharedfd+0xe6>
      exit(xstatus);
    4950:	854e                	mv	a0,s3
    4952:	00001097          	auipc	ra,0x1
    4956:	080080e7          	jalr	128(ra) # 59d2 <exit>
  close(fd);
    495a:	854a                	mv	a0,s2
    495c:	00001097          	auipc	ra,0x1
    4960:	09e080e7          	jalr	158(ra) # 59fa <close>
  fd = open("sharedfd", 0);
    4964:	4581                	li	a1,0
    4966:	00003517          	auipc	a0,0x3
    496a:	1ea50513          	addi	a0,a0,490 # 7b50 <malloc+0x1d34>
    496e:	00001097          	auipc	ra,0x1
    4972:	0a4080e7          	jalr	164(ra) # 5a12 <open>
    4976:	8baa                	mv	s7,a0
  nc = np = 0;
    4978:	8ace                	mv	s5,s3
  if (fd < 0)
    497a:	02054563          	bltz	a0,49a4 <sharedfd+0x130>
    497e:	faa40913          	addi	s2,s0,-86
      if (buf[i] == 'c')
    4982:	06300493          	li	s1,99
      if (buf[i] == 'p')
    4986:	07000b13          	li	s6,112
  while ((n = read(fd, buf, sizeof(buf))) > 0)
    498a:	4629                	li	a2,10
    498c:	fa040593          	addi	a1,s0,-96
    4990:	855e                	mv	a0,s7
    4992:	00001097          	auipc	ra,0x1
    4996:	058080e7          	jalr	88(ra) # 59ea <read>
    499a:	02a05f63          	blez	a0,49d8 <sharedfd+0x164>
    499e:	fa040793          	addi	a5,s0,-96
    49a2:	a01d                	j	49c8 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    49a4:	85d2                	mv	a1,s4
    49a6:	00003517          	auipc	a0,0x3
    49aa:	20250513          	addi	a0,a0,514 # 7ba8 <malloc+0x1d8c>
    49ae:	00001097          	auipc	ra,0x1
    49b2:	3b6080e7          	jalr	950(ra) # 5d64 <printf>
    exit(1);
    49b6:	4505                	li	a0,1
    49b8:	00001097          	auipc	ra,0x1
    49bc:	01a080e7          	jalr	26(ra) # 59d2 <exit>
        nc++;
    49c0:	2985                	addiw	s3,s3,1
    for (i = 0; i < sizeof(buf); i++)
    49c2:	0785                	addi	a5,a5,1
    49c4:	fd2783e3          	beq	a5,s2,498a <sharedfd+0x116>
      if (buf[i] == 'c')
    49c8:	0007c703          	lbu	a4,0(a5)
    49cc:	fe970ae3          	beq	a4,s1,49c0 <sharedfd+0x14c>
      if (buf[i] == 'p')
    49d0:	ff6719e3          	bne	a4,s6,49c2 <sharedfd+0x14e>
        np++;
    49d4:	2a85                	addiw	s5,s5,1
    49d6:	b7f5                	j	49c2 <sharedfd+0x14e>
  close(fd);
    49d8:	855e                	mv	a0,s7
    49da:	00001097          	auipc	ra,0x1
    49de:	020080e7          	jalr	32(ra) # 59fa <close>
  unlink("sharedfd");
    49e2:	00003517          	auipc	a0,0x3
    49e6:	16e50513          	addi	a0,a0,366 # 7b50 <malloc+0x1d34>
    49ea:	00001097          	auipc	ra,0x1
    49ee:	038080e7          	jalr	56(ra) # 5a22 <unlink>
  if (nc == N * SZ && np == N * SZ)
    49f2:	6789                	lui	a5,0x2
    49f4:	71078793          	addi	a5,a5,1808 # 2710 <rwsbrk+0x4>
    49f8:	00f99763          	bne	s3,a5,4a06 <sharedfd+0x192>
    49fc:	6789                	lui	a5,0x2
    49fe:	71078793          	addi	a5,a5,1808 # 2710 <rwsbrk+0x4>
    4a02:	02fa8063          	beq	s5,a5,4a22 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4a06:	85d2                	mv	a1,s4
    4a08:	00003517          	auipc	a0,0x3
    4a0c:	1c850513          	addi	a0,a0,456 # 7bd0 <malloc+0x1db4>
    4a10:	00001097          	auipc	ra,0x1
    4a14:	354080e7          	jalr	852(ra) # 5d64 <printf>
    exit(1);
    4a18:	4505                	li	a0,1
    4a1a:	00001097          	auipc	ra,0x1
    4a1e:	fb8080e7          	jalr	-72(ra) # 59d2 <exit>
    exit(0);
    4a22:	4501                	li	a0,0
    4a24:	00001097          	auipc	ra,0x1
    4a28:	fae080e7          	jalr	-82(ra) # 59d2 <exit>

0000000000004a2c <fourfiles>:
{
    4a2c:	7171                	addi	sp,sp,-176
    4a2e:	f506                	sd	ra,168(sp)
    4a30:	f122                	sd	s0,160(sp)
    4a32:	ed26                	sd	s1,152(sp)
    4a34:	e94a                	sd	s2,144(sp)
    4a36:	e54e                	sd	s3,136(sp)
    4a38:	e152                	sd	s4,128(sp)
    4a3a:	fcd6                	sd	s5,120(sp)
    4a3c:	f8da                	sd	s6,112(sp)
    4a3e:	f4de                	sd	s7,104(sp)
    4a40:	f0e2                	sd	s8,96(sp)
    4a42:	ece6                	sd	s9,88(sp)
    4a44:	e8ea                	sd	s10,80(sp)
    4a46:	e4ee                	sd	s11,72(sp)
    4a48:	1900                	addi	s0,sp,176
    4a4a:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = {"f0", "f1", "f2", "f3"};
    4a4e:	00003797          	auipc	a5,0x3
    4a52:	19a78793          	addi	a5,a5,410 # 7be8 <malloc+0x1dcc>
    4a56:	f6f43823          	sd	a5,-144(s0)
    4a5a:	00003797          	auipc	a5,0x3
    4a5e:	19678793          	addi	a5,a5,406 # 7bf0 <malloc+0x1dd4>
    4a62:	f6f43c23          	sd	a5,-136(s0)
    4a66:	00003797          	auipc	a5,0x3
    4a6a:	19278793          	addi	a5,a5,402 # 7bf8 <malloc+0x1ddc>
    4a6e:	f8f43023          	sd	a5,-128(s0)
    4a72:	00003797          	auipc	a5,0x3
    4a76:	18e78793          	addi	a5,a5,398 # 7c00 <malloc+0x1de4>
    4a7a:	f8f43423          	sd	a5,-120(s0)
  for (pi = 0; pi < NCHILD; pi++)
    4a7e:	f7040c13          	addi	s8,s0,-144
  char *names[] = {"f0", "f1", "f2", "f3"};
    4a82:	8962                	mv	s2,s8
  for (pi = 0; pi < NCHILD; pi++)
    4a84:	4481                	li	s1,0
    4a86:	4a11                	li	s4,4
    fname = names[pi];
    4a88:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4a8c:	854e                	mv	a0,s3
    4a8e:	00001097          	auipc	ra,0x1
    4a92:	f94080e7          	jalr	-108(ra) # 5a22 <unlink>
    pid = fork();
    4a96:	00001097          	auipc	ra,0x1
    4a9a:	f34080e7          	jalr	-204(ra) # 59ca <fork>
    if (pid < 0)
    4a9e:	04054463          	bltz	a0,4ae6 <fourfiles+0xba>
    if (pid == 0)
    4aa2:	c12d                	beqz	a0,4b04 <fourfiles+0xd8>
  for (pi = 0; pi < NCHILD; pi++)
    4aa4:	2485                	addiw	s1,s1,1
    4aa6:	0921                	addi	s2,s2,8
    4aa8:	ff4490e3          	bne	s1,s4,4a88 <fourfiles+0x5c>
    4aac:	4491                	li	s1,4
    wait(&xstatus);
    4aae:	f6c40513          	addi	a0,s0,-148
    4ab2:	00001097          	auipc	ra,0x1
    4ab6:	f28080e7          	jalr	-216(ra) # 59da <wait>
    if (xstatus != 0)
    4aba:	f6c42b03          	lw	s6,-148(s0)
    4abe:	0c0b1e63          	bnez	s6,4b9a <fourfiles+0x16e>
  for (pi = 0; pi < NCHILD; pi++)
    4ac2:	34fd                	addiw	s1,s1,-1
    4ac4:	f4ed                	bnez	s1,4aae <fourfiles+0x82>
    4ac6:	03000b93          	li	s7,48
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    4aca:	00008a17          	auipc	s4,0x8
    4ace:	1aea0a13          	addi	s4,s4,430 # cc78 <buf>
    4ad2:	00008a97          	auipc	s5,0x8
    4ad6:	1a7a8a93          	addi	s5,s5,423 # cc79 <buf+0x1>
    if (total != N * SZ)
    4ada:	6d85                	lui	s11,0x1
    4adc:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0xc>
  for (i = 0; i < NCHILD; i++)
    4ae0:	03400d13          	li	s10,52
    4ae4:	aa1d                	j	4c1a <fourfiles+0x1ee>
      printf("fork failed\n", s);
    4ae6:	f5843583          	ld	a1,-168(s0)
    4aea:	00002517          	auipc	a0,0x2
    4aee:	0ee50513          	addi	a0,a0,238 # 6bd8 <malloc+0xdbc>
    4af2:	00001097          	auipc	ra,0x1
    4af6:	272080e7          	jalr	626(ra) # 5d64 <printf>
      exit(1);
    4afa:	4505                	li	a0,1
    4afc:	00001097          	auipc	ra,0x1
    4b00:	ed6080e7          	jalr	-298(ra) # 59d2 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4b04:	20200593          	li	a1,514
    4b08:	854e                	mv	a0,s3
    4b0a:	00001097          	auipc	ra,0x1
    4b0e:	f08080e7          	jalr	-248(ra) # 5a12 <open>
    4b12:	892a                	mv	s2,a0
      if (fd < 0)
    4b14:	04054763          	bltz	a0,4b62 <fourfiles+0x136>
      memset(buf, '0' + pi, SZ);
    4b18:	1f400613          	li	a2,500
    4b1c:	0304859b          	addiw	a1,s1,48
    4b20:	00008517          	auipc	a0,0x8
    4b24:	15850513          	addi	a0,a0,344 # cc78 <buf>
    4b28:	00001097          	auipc	ra,0x1
    4b2c:	cb0080e7          	jalr	-848(ra) # 57d8 <memset>
    4b30:	44b1                	li	s1,12
        if ((n = write(fd, buf, SZ)) != SZ)
    4b32:	00008997          	auipc	s3,0x8
    4b36:	14698993          	addi	s3,s3,326 # cc78 <buf>
    4b3a:	1f400613          	li	a2,500
    4b3e:	85ce                	mv	a1,s3
    4b40:	854a                	mv	a0,s2
    4b42:	00001097          	auipc	ra,0x1
    4b46:	eb0080e7          	jalr	-336(ra) # 59f2 <write>
    4b4a:	85aa                	mv	a1,a0
    4b4c:	1f400793          	li	a5,500
    4b50:	02f51863          	bne	a0,a5,4b80 <fourfiles+0x154>
      for (i = 0; i < N; i++)
    4b54:	34fd                	addiw	s1,s1,-1
    4b56:	f0f5                	bnez	s1,4b3a <fourfiles+0x10e>
      exit(0);
    4b58:	4501                	li	a0,0
    4b5a:	00001097          	auipc	ra,0x1
    4b5e:	e78080e7          	jalr	-392(ra) # 59d2 <exit>
        printf("create failed\n", s);
    4b62:	f5843583          	ld	a1,-168(s0)
    4b66:	00003517          	auipc	a0,0x3
    4b6a:	0a250513          	addi	a0,a0,162 # 7c08 <malloc+0x1dec>
    4b6e:	00001097          	auipc	ra,0x1
    4b72:	1f6080e7          	jalr	502(ra) # 5d64 <printf>
        exit(1);
    4b76:	4505                	li	a0,1
    4b78:	00001097          	auipc	ra,0x1
    4b7c:	e5a080e7          	jalr	-422(ra) # 59d2 <exit>
          printf("write failed %d\n", n);
    4b80:	00003517          	auipc	a0,0x3
    4b84:	09850513          	addi	a0,a0,152 # 7c18 <malloc+0x1dfc>
    4b88:	00001097          	auipc	ra,0x1
    4b8c:	1dc080e7          	jalr	476(ra) # 5d64 <printf>
          exit(1);
    4b90:	4505                	li	a0,1
    4b92:	00001097          	auipc	ra,0x1
    4b96:	e40080e7          	jalr	-448(ra) # 59d2 <exit>
      exit(xstatus);
    4b9a:	855a                	mv	a0,s6
    4b9c:	00001097          	auipc	ra,0x1
    4ba0:	e36080e7          	jalr	-458(ra) # 59d2 <exit>
          printf("wrong char\n", s);
    4ba4:	f5843583          	ld	a1,-168(s0)
    4ba8:	00003517          	auipc	a0,0x3
    4bac:	08850513          	addi	a0,a0,136 # 7c30 <malloc+0x1e14>
    4bb0:	00001097          	auipc	ra,0x1
    4bb4:	1b4080e7          	jalr	436(ra) # 5d64 <printf>
          exit(1);
    4bb8:	4505                	li	a0,1
    4bba:	00001097          	auipc	ra,0x1
    4bbe:	e18080e7          	jalr	-488(ra) # 59d2 <exit>
      total += n;
    4bc2:	00a9093b          	addw	s2,s2,a0
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    4bc6:	660d                	lui	a2,0x3
    4bc8:	85d2                	mv	a1,s4
    4bca:	854e                	mv	a0,s3
    4bcc:	00001097          	auipc	ra,0x1
    4bd0:	e1e080e7          	jalr	-482(ra) # 59ea <read>
    4bd4:	02a05363          	blez	a0,4bfa <fourfiles+0x1ce>
    4bd8:	00008797          	auipc	a5,0x8
    4bdc:	0a078793          	addi	a5,a5,160 # cc78 <buf>
    4be0:	fff5069b          	addiw	a3,a0,-1
    4be4:	1682                	slli	a3,a3,0x20
    4be6:	9281                	srli	a3,a3,0x20
    4be8:	96d6                	add	a3,a3,s5
        if (buf[j] != '0' + i)
    4bea:	0007c703          	lbu	a4,0(a5)
    4bee:	fa971be3          	bne	a4,s1,4ba4 <fourfiles+0x178>
      for (j = 0; j < n; j++)
    4bf2:	0785                	addi	a5,a5,1
    4bf4:	fed79be3          	bne	a5,a3,4bea <fourfiles+0x1be>
    4bf8:	b7e9                	j	4bc2 <fourfiles+0x196>
    close(fd);
    4bfa:	854e                	mv	a0,s3
    4bfc:	00001097          	auipc	ra,0x1
    4c00:	dfe080e7          	jalr	-514(ra) # 59fa <close>
    if (total != N * SZ)
    4c04:	03b91863          	bne	s2,s11,4c34 <fourfiles+0x208>
    unlink(fname);
    4c08:	8566                	mv	a0,s9
    4c0a:	00001097          	auipc	ra,0x1
    4c0e:	e18080e7          	jalr	-488(ra) # 5a22 <unlink>
  for (i = 0; i < NCHILD; i++)
    4c12:	0c21                	addi	s8,s8,8
    4c14:	2b85                	addiw	s7,s7,1
    4c16:	03ab8d63          	beq	s7,s10,4c50 <fourfiles+0x224>
    fname = names[i];
    4c1a:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4c1e:	4581                	li	a1,0
    4c20:	8566                	mv	a0,s9
    4c22:	00001097          	auipc	ra,0x1
    4c26:	df0080e7          	jalr	-528(ra) # 5a12 <open>
    4c2a:	89aa                	mv	s3,a0
    total = 0;
    4c2c:	895a                	mv	s2,s6
        if (buf[j] != '0' + i)
    4c2e:	000b849b          	sext.w	s1,s7
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    4c32:	bf51                	j	4bc6 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    4c34:	85ca                	mv	a1,s2
    4c36:	00003517          	auipc	a0,0x3
    4c3a:	00a50513          	addi	a0,a0,10 # 7c40 <malloc+0x1e24>
    4c3e:	00001097          	auipc	ra,0x1
    4c42:	126080e7          	jalr	294(ra) # 5d64 <printf>
      exit(1);
    4c46:	4505                	li	a0,1
    4c48:	00001097          	auipc	ra,0x1
    4c4c:	d8a080e7          	jalr	-630(ra) # 59d2 <exit>
}
    4c50:	70aa                	ld	ra,168(sp)
    4c52:	740a                	ld	s0,160(sp)
    4c54:	64ea                	ld	s1,152(sp)
    4c56:	694a                	ld	s2,144(sp)
    4c58:	69aa                	ld	s3,136(sp)
    4c5a:	6a0a                	ld	s4,128(sp)
    4c5c:	7ae6                	ld	s5,120(sp)
    4c5e:	7b46                	ld	s6,112(sp)
    4c60:	7ba6                	ld	s7,104(sp)
    4c62:	7c06                	ld	s8,96(sp)
    4c64:	6ce6                	ld	s9,88(sp)
    4c66:	6d46                	ld	s10,80(sp)
    4c68:	6da6                	ld	s11,72(sp)
    4c6a:	614d                	addi	sp,sp,176
    4c6c:	8082                	ret

0000000000004c6e <concreate>:
{
    4c6e:	7135                	addi	sp,sp,-160
    4c70:	ed06                	sd	ra,152(sp)
    4c72:	e922                	sd	s0,144(sp)
    4c74:	e526                	sd	s1,136(sp)
    4c76:	e14a                	sd	s2,128(sp)
    4c78:	fcce                	sd	s3,120(sp)
    4c7a:	f8d2                	sd	s4,112(sp)
    4c7c:	f4d6                	sd	s5,104(sp)
    4c7e:	f0da                	sd	s6,96(sp)
    4c80:	ecde                	sd	s7,88(sp)
    4c82:	1100                	addi	s0,sp,160
    4c84:	89aa                	mv	s3,a0
  file[0] = 'C';
    4c86:	04300793          	li	a5,67
    4c8a:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4c8e:	fa040523          	sb	zero,-86(s0)
  for (i = 0; i < N; i++)
    4c92:	4901                	li	s2,0
    if (pid && (i % 3) == 1)
    4c94:	4b0d                	li	s6,3
    4c96:	4a85                	li	s5,1
      link("C0", file);
    4c98:	00003b97          	auipc	s7,0x3
    4c9c:	fc0b8b93          	addi	s7,s7,-64 # 7c58 <malloc+0x1e3c>
  for (i = 0; i < N; i++)
    4ca0:	02800a13          	li	s4,40
    4ca4:	acc9                	j	4f76 <concreate+0x308>
      link("C0", file);
    4ca6:	fa840593          	addi	a1,s0,-88
    4caa:	855e                	mv	a0,s7
    4cac:	00001097          	auipc	ra,0x1
    4cb0:	d86080e7          	jalr	-634(ra) # 5a32 <link>
    if (pid == 0)
    4cb4:	a465                	j	4f5c <concreate+0x2ee>
    else if (pid == 0 && (i % 5) == 1)
    4cb6:	4795                	li	a5,5
    4cb8:	02f9693b          	remw	s2,s2,a5
    4cbc:	4785                	li	a5,1
    4cbe:	02f90b63          	beq	s2,a5,4cf4 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4cc2:	20200593          	li	a1,514
    4cc6:	fa840513          	addi	a0,s0,-88
    4cca:	00001097          	auipc	ra,0x1
    4cce:	d48080e7          	jalr	-696(ra) # 5a12 <open>
      if (fd < 0)
    4cd2:	26055c63          	bgez	a0,4f4a <concreate+0x2dc>
        printf("concreate create %s failed\n", file);
    4cd6:	fa840593          	addi	a1,s0,-88
    4cda:	00003517          	auipc	a0,0x3
    4cde:	f8650513          	addi	a0,a0,-122 # 7c60 <malloc+0x1e44>
    4ce2:	00001097          	auipc	ra,0x1
    4ce6:	082080e7          	jalr	130(ra) # 5d64 <printf>
        exit(1);
    4cea:	4505                	li	a0,1
    4cec:	00001097          	auipc	ra,0x1
    4cf0:	ce6080e7          	jalr	-794(ra) # 59d2 <exit>
      link("C0", file);
    4cf4:	fa840593          	addi	a1,s0,-88
    4cf8:	00003517          	auipc	a0,0x3
    4cfc:	f6050513          	addi	a0,a0,-160 # 7c58 <malloc+0x1e3c>
    4d00:	00001097          	auipc	ra,0x1
    4d04:	d32080e7          	jalr	-718(ra) # 5a32 <link>
      exit(0);
    4d08:	4501                	li	a0,0
    4d0a:	00001097          	auipc	ra,0x1
    4d0e:	cc8080e7          	jalr	-824(ra) # 59d2 <exit>
        exit(1);
    4d12:	4505                	li	a0,1
    4d14:	00001097          	auipc	ra,0x1
    4d18:	cbe080e7          	jalr	-834(ra) # 59d2 <exit>
  memset(fa, 0, sizeof(fa));
    4d1c:	02800613          	li	a2,40
    4d20:	4581                	li	a1,0
    4d22:	f8040513          	addi	a0,s0,-128
    4d26:	00001097          	auipc	ra,0x1
    4d2a:	ab2080e7          	jalr	-1358(ra) # 57d8 <memset>
  fd = open(".", 0);
    4d2e:	4581                	li	a1,0
    4d30:	00002517          	auipc	a0,0x2
    4d34:	90050513          	addi	a0,a0,-1792 # 6630 <malloc+0x814>
    4d38:	00001097          	auipc	ra,0x1
    4d3c:	cda080e7          	jalr	-806(ra) # 5a12 <open>
    4d40:	892a                	mv	s2,a0
  n = 0;
    4d42:	8aa6                	mv	s5,s1
    if (de.name[0] == 'C' && de.name[2] == '\0')
    4d44:	04300a13          	li	s4,67
      if (i < 0 || i >= sizeof(fa))
    4d48:	02700b13          	li	s6,39
      fa[i] = 1;
    4d4c:	4b85                	li	s7,1
  while (read(fd, &de, sizeof(de)) > 0)
    4d4e:	4641                	li	a2,16
    4d50:	f7040593          	addi	a1,s0,-144
    4d54:	854a                	mv	a0,s2
    4d56:	00001097          	auipc	ra,0x1
    4d5a:	c94080e7          	jalr	-876(ra) # 59ea <read>
    4d5e:	08a05263          	blez	a0,4de2 <concreate+0x174>
    if (de.inum == 0)
    4d62:	f7045783          	lhu	a5,-144(s0)
    4d66:	d7e5                	beqz	a5,4d4e <concreate+0xe0>
    if (de.name[0] == 'C' && de.name[2] == '\0')
    4d68:	f7244783          	lbu	a5,-142(s0)
    4d6c:	ff4791e3          	bne	a5,s4,4d4e <concreate+0xe0>
    4d70:	f7444783          	lbu	a5,-140(s0)
    4d74:	ffe9                	bnez	a5,4d4e <concreate+0xe0>
      i = de.name[1] - '0';
    4d76:	f7344783          	lbu	a5,-141(s0)
    4d7a:	fd07879b          	addiw	a5,a5,-48
    4d7e:	0007871b          	sext.w	a4,a5
      if (i < 0 || i >= sizeof(fa))
    4d82:	02eb6063          	bltu	s6,a4,4da2 <concreate+0x134>
      if (fa[i])
    4d86:	fb070793          	addi	a5,a4,-80 # fb0 <linktest+0x98>
    4d8a:	97a2                	add	a5,a5,s0
    4d8c:	fd07c783          	lbu	a5,-48(a5)
    4d90:	eb8d                	bnez	a5,4dc2 <concreate+0x154>
      fa[i] = 1;
    4d92:	fb070793          	addi	a5,a4,-80
    4d96:	00878733          	add	a4,a5,s0
    4d9a:	fd770823          	sb	s7,-48(a4)
      n++;
    4d9e:	2a85                	addiw	s5,s5,1
    4da0:	b77d                	j	4d4e <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4da2:	f7240613          	addi	a2,s0,-142
    4da6:	85ce                	mv	a1,s3
    4da8:	00003517          	auipc	a0,0x3
    4dac:	ed850513          	addi	a0,a0,-296 # 7c80 <malloc+0x1e64>
    4db0:	00001097          	auipc	ra,0x1
    4db4:	fb4080e7          	jalr	-76(ra) # 5d64 <printf>
        exit(1);
    4db8:	4505                	li	a0,1
    4dba:	00001097          	auipc	ra,0x1
    4dbe:	c18080e7          	jalr	-1000(ra) # 59d2 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4dc2:	f7240613          	addi	a2,s0,-142
    4dc6:	85ce                	mv	a1,s3
    4dc8:	00003517          	auipc	a0,0x3
    4dcc:	ed850513          	addi	a0,a0,-296 # 7ca0 <malloc+0x1e84>
    4dd0:	00001097          	auipc	ra,0x1
    4dd4:	f94080e7          	jalr	-108(ra) # 5d64 <printf>
        exit(1);
    4dd8:	4505                	li	a0,1
    4dda:	00001097          	auipc	ra,0x1
    4dde:	bf8080e7          	jalr	-1032(ra) # 59d2 <exit>
  close(fd);
    4de2:	854a                	mv	a0,s2
    4de4:	00001097          	auipc	ra,0x1
    4de8:	c16080e7          	jalr	-1002(ra) # 59fa <close>
  if (n != N)
    4dec:	02800793          	li	a5,40
    4df0:	00fa9763          	bne	s5,a5,4dfe <concreate+0x190>
    if (((i % 3) == 0 && pid == 0) ||
    4df4:	4a8d                	li	s5,3
    4df6:	4b05                	li	s6,1
  for (i = 0; i < N; i++)
    4df8:	02800a13          	li	s4,40
    4dfc:	a8c9                	j	4ece <concreate+0x260>
    printf("%s: concreate not enough files in directory listing\n", s);
    4dfe:	85ce                	mv	a1,s3
    4e00:	00003517          	auipc	a0,0x3
    4e04:	ec850513          	addi	a0,a0,-312 # 7cc8 <malloc+0x1eac>
    4e08:	00001097          	auipc	ra,0x1
    4e0c:	f5c080e7          	jalr	-164(ra) # 5d64 <printf>
    exit(1);
    4e10:	4505                	li	a0,1
    4e12:	00001097          	auipc	ra,0x1
    4e16:	bc0080e7          	jalr	-1088(ra) # 59d2 <exit>
      printf("%s: fork failed\n", s);
    4e1a:	85ce                	mv	a1,s3
    4e1c:	00002517          	auipc	a0,0x2
    4e20:	9b450513          	addi	a0,a0,-1612 # 67d0 <malloc+0x9b4>
    4e24:	00001097          	auipc	ra,0x1
    4e28:	f40080e7          	jalr	-192(ra) # 5d64 <printf>
      exit(1);
    4e2c:	4505                	li	a0,1
    4e2e:	00001097          	auipc	ra,0x1
    4e32:	ba4080e7          	jalr	-1116(ra) # 59d2 <exit>
      close(open(file, 0));
    4e36:	4581                	li	a1,0
    4e38:	fa840513          	addi	a0,s0,-88
    4e3c:	00001097          	auipc	ra,0x1
    4e40:	bd6080e7          	jalr	-1066(ra) # 5a12 <open>
    4e44:	00001097          	auipc	ra,0x1
    4e48:	bb6080e7          	jalr	-1098(ra) # 59fa <close>
      close(open(file, 0));
    4e4c:	4581                	li	a1,0
    4e4e:	fa840513          	addi	a0,s0,-88
    4e52:	00001097          	auipc	ra,0x1
    4e56:	bc0080e7          	jalr	-1088(ra) # 5a12 <open>
    4e5a:	00001097          	auipc	ra,0x1
    4e5e:	ba0080e7          	jalr	-1120(ra) # 59fa <close>
      close(open(file, 0));
    4e62:	4581                	li	a1,0
    4e64:	fa840513          	addi	a0,s0,-88
    4e68:	00001097          	auipc	ra,0x1
    4e6c:	baa080e7          	jalr	-1110(ra) # 5a12 <open>
    4e70:	00001097          	auipc	ra,0x1
    4e74:	b8a080e7          	jalr	-1142(ra) # 59fa <close>
      close(open(file, 0));
    4e78:	4581                	li	a1,0
    4e7a:	fa840513          	addi	a0,s0,-88
    4e7e:	00001097          	auipc	ra,0x1
    4e82:	b94080e7          	jalr	-1132(ra) # 5a12 <open>
    4e86:	00001097          	auipc	ra,0x1
    4e8a:	b74080e7          	jalr	-1164(ra) # 59fa <close>
      close(open(file, 0));
    4e8e:	4581                	li	a1,0
    4e90:	fa840513          	addi	a0,s0,-88
    4e94:	00001097          	auipc	ra,0x1
    4e98:	b7e080e7          	jalr	-1154(ra) # 5a12 <open>
    4e9c:	00001097          	auipc	ra,0x1
    4ea0:	b5e080e7          	jalr	-1186(ra) # 59fa <close>
      close(open(file, 0));
    4ea4:	4581                	li	a1,0
    4ea6:	fa840513          	addi	a0,s0,-88
    4eaa:	00001097          	auipc	ra,0x1
    4eae:	b68080e7          	jalr	-1176(ra) # 5a12 <open>
    4eb2:	00001097          	auipc	ra,0x1
    4eb6:	b48080e7          	jalr	-1208(ra) # 59fa <close>
    if (pid == 0)
    4eba:	08090363          	beqz	s2,4f40 <concreate+0x2d2>
      wait(0);
    4ebe:	4501                	li	a0,0
    4ec0:	00001097          	auipc	ra,0x1
    4ec4:	b1a080e7          	jalr	-1254(ra) # 59da <wait>
  for (i = 0; i < N; i++)
    4ec8:	2485                	addiw	s1,s1,1
    4eca:	0f448563          	beq	s1,s4,4fb4 <concreate+0x346>
    file[1] = '0' + i;
    4ece:	0304879b          	addiw	a5,s1,48
    4ed2:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    4ed6:	00001097          	auipc	ra,0x1
    4eda:	af4080e7          	jalr	-1292(ra) # 59ca <fork>
    4ede:	892a                	mv	s2,a0
    if (pid < 0)
    4ee0:	f2054de3          	bltz	a0,4e1a <concreate+0x1ac>
    if (((i % 3) == 0 && pid == 0) ||
    4ee4:	0354e73b          	remw	a4,s1,s5
    4ee8:	00a767b3          	or	a5,a4,a0
    4eec:	2781                	sext.w	a5,a5
    4eee:	d7a1                	beqz	a5,4e36 <concreate+0x1c8>
    4ef0:	01671363          	bne	a4,s6,4ef6 <concreate+0x288>
        ((i % 3) == 1 && pid != 0))
    4ef4:	f129                	bnez	a0,4e36 <concreate+0x1c8>
      unlink(file);
    4ef6:	fa840513          	addi	a0,s0,-88
    4efa:	00001097          	auipc	ra,0x1
    4efe:	b28080e7          	jalr	-1240(ra) # 5a22 <unlink>
      unlink(file);
    4f02:	fa840513          	addi	a0,s0,-88
    4f06:	00001097          	auipc	ra,0x1
    4f0a:	b1c080e7          	jalr	-1252(ra) # 5a22 <unlink>
      unlink(file);
    4f0e:	fa840513          	addi	a0,s0,-88
    4f12:	00001097          	auipc	ra,0x1
    4f16:	b10080e7          	jalr	-1264(ra) # 5a22 <unlink>
      unlink(file);
    4f1a:	fa840513          	addi	a0,s0,-88
    4f1e:	00001097          	auipc	ra,0x1
    4f22:	b04080e7          	jalr	-1276(ra) # 5a22 <unlink>
      unlink(file);
    4f26:	fa840513          	addi	a0,s0,-88
    4f2a:	00001097          	auipc	ra,0x1
    4f2e:	af8080e7          	jalr	-1288(ra) # 5a22 <unlink>
      unlink(file);
    4f32:	fa840513          	addi	a0,s0,-88
    4f36:	00001097          	auipc	ra,0x1
    4f3a:	aec080e7          	jalr	-1300(ra) # 5a22 <unlink>
    4f3e:	bfb5                	j	4eba <concreate+0x24c>
      exit(0);
    4f40:	4501                	li	a0,0
    4f42:	00001097          	auipc	ra,0x1
    4f46:	a90080e7          	jalr	-1392(ra) # 59d2 <exit>
      close(fd);
    4f4a:	00001097          	auipc	ra,0x1
    4f4e:	ab0080e7          	jalr	-1360(ra) # 59fa <close>
    if (pid == 0)
    4f52:	bb5d                	j	4d08 <concreate+0x9a>
      close(fd);
    4f54:	00001097          	auipc	ra,0x1
    4f58:	aa6080e7          	jalr	-1370(ra) # 59fa <close>
      wait(&xstatus);
    4f5c:	f6c40513          	addi	a0,s0,-148
    4f60:	00001097          	auipc	ra,0x1
    4f64:	a7a080e7          	jalr	-1414(ra) # 59da <wait>
      if (xstatus != 0)
    4f68:	f6c42483          	lw	s1,-148(s0)
    4f6c:	da0493e3          	bnez	s1,4d12 <concreate+0xa4>
  for (i = 0; i < N; i++)
    4f70:	2905                	addiw	s2,s2,1
    4f72:	db4905e3          	beq	s2,s4,4d1c <concreate+0xae>
    file[1] = '0' + i;
    4f76:	0309079b          	addiw	a5,s2,48
    4f7a:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4f7e:	fa840513          	addi	a0,s0,-88
    4f82:	00001097          	auipc	ra,0x1
    4f86:	aa0080e7          	jalr	-1376(ra) # 5a22 <unlink>
    pid = fork();
    4f8a:	00001097          	auipc	ra,0x1
    4f8e:	a40080e7          	jalr	-1472(ra) # 59ca <fork>
    if (pid && (i % 3) == 1)
    4f92:	d20502e3          	beqz	a0,4cb6 <concreate+0x48>
    4f96:	036967bb          	remw	a5,s2,s6
    4f9a:	d15786e3          	beq	a5,s5,4ca6 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4f9e:	20200593          	li	a1,514
    4fa2:	fa840513          	addi	a0,s0,-88
    4fa6:	00001097          	auipc	ra,0x1
    4faa:	a6c080e7          	jalr	-1428(ra) # 5a12 <open>
      if (fd < 0)
    4fae:	fa0553e3          	bgez	a0,4f54 <concreate+0x2e6>
    4fb2:	b315                	j	4cd6 <concreate+0x68>
}
    4fb4:	60ea                	ld	ra,152(sp)
    4fb6:	644a                	ld	s0,144(sp)
    4fb8:	64aa                	ld	s1,136(sp)
    4fba:	690a                	ld	s2,128(sp)
    4fbc:	79e6                	ld	s3,120(sp)
    4fbe:	7a46                	ld	s4,112(sp)
    4fc0:	7aa6                	ld	s5,104(sp)
    4fc2:	7b06                	ld	s6,96(sp)
    4fc4:	6be6                	ld	s7,88(sp)
    4fc6:	610d                	addi	sp,sp,160
    4fc8:	8082                	ret

0000000000004fca <bigfile>:
{
    4fca:	7139                	addi	sp,sp,-64
    4fcc:	fc06                	sd	ra,56(sp)
    4fce:	f822                	sd	s0,48(sp)
    4fd0:	f426                	sd	s1,40(sp)
    4fd2:	f04a                	sd	s2,32(sp)
    4fd4:	ec4e                	sd	s3,24(sp)
    4fd6:	e852                	sd	s4,16(sp)
    4fd8:	e456                	sd	s5,8(sp)
    4fda:	0080                	addi	s0,sp,64
    4fdc:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4fde:	00003517          	auipc	a0,0x3
    4fe2:	d2250513          	addi	a0,a0,-734 # 7d00 <malloc+0x1ee4>
    4fe6:	00001097          	auipc	ra,0x1
    4fea:	a3c080e7          	jalr	-1476(ra) # 5a22 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4fee:	20200593          	li	a1,514
    4ff2:	00003517          	auipc	a0,0x3
    4ff6:	d0e50513          	addi	a0,a0,-754 # 7d00 <malloc+0x1ee4>
    4ffa:	00001097          	auipc	ra,0x1
    4ffe:	a18080e7          	jalr	-1512(ra) # 5a12 <open>
    5002:	89aa                	mv	s3,a0
  for (i = 0; i < N; i++)
    5004:	4481                	li	s1,0
    memset(buf, i, SZ);
    5006:	00008917          	auipc	s2,0x8
    500a:	c7290913          	addi	s2,s2,-910 # cc78 <buf>
  for (i = 0; i < N; i++)
    500e:	4a51                	li	s4,20
  if (fd < 0)
    5010:	0a054063          	bltz	a0,50b0 <bigfile+0xe6>
    memset(buf, i, SZ);
    5014:	25800613          	li	a2,600
    5018:	85a6                	mv	a1,s1
    501a:	854a                	mv	a0,s2
    501c:	00000097          	auipc	ra,0x0
    5020:	7bc080e7          	jalr	1980(ra) # 57d8 <memset>
    if (write(fd, buf, SZ) != SZ)
    5024:	25800613          	li	a2,600
    5028:	85ca                	mv	a1,s2
    502a:	854e                	mv	a0,s3
    502c:	00001097          	auipc	ra,0x1
    5030:	9c6080e7          	jalr	-1594(ra) # 59f2 <write>
    5034:	25800793          	li	a5,600
    5038:	08f51a63          	bne	a0,a5,50cc <bigfile+0x102>
  for (i = 0; i < N; i++)
    503c:	2485                	addiw	s1,s1,1
    503e:	fd449be3          	bne	s1,s4,5014 <bigfile+0x4a>
  close(fd);
    5042:	854e                	mv	a0,s3
    5044:	00001097          	auipc	ra,0x1
    5048:	9b6080e7          	jalr	-1610(ra) # 59fa <close>
  fd = open("bigfile.dat", 0);
    504c:	4581                	li	a1,0
    504e:	00003517          	auipc	a0,0x3
    5052:	cb250513          	addi	a0,a0,-846 # 7d00 <malloc+0x1ee4>
    5056:	00001097          	auipc	ra,0x1
    505a:	9bc080e7          	jalr	-1604(ra) # 5a12 <open>
    505e:	8a2a                	mv	s4,a0
  total = 0;
    5060:	4981                	li	s3,0
  for (i = 0;; i++)
    5062:	4481                	li	s1,0
    cc = read(fd, buf, SZ / 2);
    5064:	00008917          	auipc	s2,0x8
    5068:	c1490913          	addi	s2,s2,-1004 # cc78 <buf>
  if (fd < 0)
    506c:	06054e63          	bltz	a0,50e8 <bigfile+0x11e>
    cc = read(fd, buf, SZ / 2);
    5070:	12c00613          	li	a2,300
    5074:	85ca                	mv	a1,s2
    5076:	8552                	mv	a0,s4
    5078:	00001097          	auipc	ra,0x1
    507c:	972080e7          	jalr	-1678(ra) # 59ea <read>
    if (cc < 0)
    5080:	08054263          	bltz	a0,5104 <bigfile+0x13a>
    if (cc == 0)
    5084:	c971                	beqz	a0,5158 <bigfile+0x18e>
    if (cc != SZ / 2)
    5086:	12c00793          	li	a5,300
    508a:	08f51b63          	bne	a0,a5,5120 <bigfile+0x156>
    if (buf[0] != i / 2 || buf[SZ / 2 - 1] != i / 2)
    508e:	01f4d79b          	srliw	a5,s1,0x1f
    5092:	9fa5                	addw	a5,a5,s1
    5094:	4017d79b          	sraiw	a5,a5,0x1
    5098:	00094703          	lbu	a4,0(s2)
    509c:	0af71063          	bne	a4,a5,513c <bigfile+0x172>
    50a0:	12b94703          	lbu	a4,299(s2)
    50a4:	08f71c63          	bne	a4,a5,513c <bigfile+0x172>
    total += cc;
    50a8:	12c9899b          	addiw	s3,s3,300
  for (i = 0;; i++)
    50ac:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ / 2);
    50ae:	b7c9                	j	5070 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    50b0:	85d6                	mv	a1,s5
    50b2:	00003517          	auipc	a0,0x3
    50b6:	c5e50513          	addi	a0,a0,-930 # 7d10 <malloc+0x1ef4>
    50ba:	00001097          	auipc	ra,0x1
    50be:	caa080e7          	jalr	-854(ra) # 5d64 <printf>
    exit(1);
    50c2:	4505                	li	a0,1
    50c4:	00001097          	auipc	ra,0x1
    50c8:	90e080e7          	jalr	-1778(ra) # 59d2 <exit>
      printf("%s: write bigfile failed\n", s);
    50cc:	85d6                	mv	a1,s5
    50ce:	00003517          	auipc	a0,0x3
    50d2:	c6250513          	addi	a0,a0,-926 # 7d30 <malloc+0x1f14>
    50d6:	00001097          	auipc	ra,0x1
    50da:	c8e080e7          	jalr	-882(ra) # 5d64 <printf>
      exit(1);
    50de:	4505                	li	a0,1
    50e0:	00001097          	auipc	ra,0x1
    50e4:	8f2080e7          	jalr	-1806(ra) # 59d2 <exit>
    printf("%s: cannot open bigfile\n", s);
    50e8:	85d6                	mv	a1,s5
    50ea:	00003517          	auipc	a0,0x3
    50ee:	c6650513          	addi	a0,a0,-922 # 7d50 <malloc+0x1f34>
    50f2:	00001097          	auipc	ra,0x1
    50f6:	c72080e7          	jalr	-910(ra) # 5d64 <printf>
    exit(1);
    50fa:	4505                	li	a0,1
    50fc:	00001097          	auipc	ra,0x1
    5100:	8d6080e7          	jalr	-1834(ra) # 59d2 <exit>
      printf("%s: read bigfile failed\n", s);
    5104:	85d6                	mv	a1,s5
    5106:	00003517          	auipc	a0,0x3
    510a:	c6a50513          	addi	a0,a0,-918 # 7d70 <malloc+0x1f54>
    510e:	00001097          	auipc	ra,0x1
    5112:	c56080e7          	jalr	-938(ra) # 5d64 <printf>
      exit(1);
    5116:	4505                	li	a0,1
    5118:	00001097          	auipc	ra,0x1
    511c:	8ba080e7          	jalr	-1862(ra) # 59d2 <exit>
      printf("%s: short read bigfile\n", s);
    5120:	85d6                	mv	a1,s5
    5122:	00003517          	auipc	a0,0x3
    5126:	c6e50513          	addi	a0,a0,-914 # 7d90 <malloc+0x1f74>
    512a:	00001097          	auipc	ra,0x1
    512e:	c3a080e7          	jalr	-966(ra) # 5d64 <printf>
      exit(1);
    5132:	4505                	li	a0,1
    5134:	00001097          	auipc	ra,0x1
    5138:	89e080e7          	jalr	-1890(ra) # 59d2 <exit>
      printf("%s: read bigfile wrong data\n", s);
    513c:	85d6                	mv	a1,s5
    513e:	00003517          	auipc	a0,0x3
    5142:	c6a50513          	addi	a0,a0,-918 # 7da8 <malloc+0x1f8c>
    5146:	00001097          	auipc	ra,0x1
    514a:	c1e080e7          	jalr	-994(ra) # 5d64 <printf>
      exit(1);
    514e:	4505                	li	a0,1
    5150:	00001097          	auipc	ra,0x1
    5154:	882080e7          	jalr	-1918(ra) # 59d2 <exit>
  close(fd);
    5158:	8552                	mv	a0,s4
    515a:	00001097          	auipc	ra,0x1
    515e:	8a0080e7          	jalr	-1888(ra) # 59fa <close>
  if (total != N * SZ)
    5162:	678d                	lui	a5,0x3
    5164:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrk8000+0x6>
    5168:	02f99363          	bne	s3,a5,518e <bigfile+0x1c4>
  unlink("bigfile.dat");
    516c:	00003517          	auipc	a0,0x3
    5170:	b9450513          	addi	a0,a0,-1132 # 7d00 <malloc+0x1ee4>
    5174:	00001097          	auipc	ra,0x1
    5178:	8ae080e7          	jalr	-1874(ra) # 5a22 <unlink>
}
    517c:	70e2                	ld	ra,56(sp)
    517e:	7442                	ld	s0,48(sp)
    5180:	74a2                	ld	s1,40(sp)
    5182:	7902                	ld	s2,32(sp)
    5184:	69e2                	ld	s3,24(sp)
    5186:	6a42                	ld	s4,16(sp)
    5188:	6aa2                	ld	s5,8(sp)
    518a:	6121                	addi	sp,sp,64
    518c:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    518e:	85d6                	mv	a1,s5
    5190:	00003517          	auipc	a0,0x3
    5194:	c3850513          	addi	a0,a0,-968 # 7dc8 <malloc+0x1fac>
    5198:	00001097          	auipc	ra,0x1
    519c:	bcc080e7          	jalr	-1076(ra) # 5d64 <printf>
    exit(1);
    51a0:	4505                	li	a0,1
    51a2:	00001097          	auipc	ra,0x1
    51a6:	830080e7          	jalr	-2000(ra) # 59d2 <exit>

00000000000051aa <fsfull>:
{
    51aa:	7171                	addi	sp,sp,-176
    51ac:	f506                	sd	ra,168(sp)
    51ae:	f122                	sd	s0,160(sp)
    51b0:	ed26                	sd	s1,152(sp)
    51b2:	e94a                	sd	s2,144(sp)
    51b4:	e54e                	sd	s3,136(sp)
    51b6:	e152                	sd	s4,128(sp)
    51b8:	fcd6                	sd	s5,120(sp)
    51ba:	f8da                	sd	s6,112(sp)
    51bc:	f4de                	sd	s7,104(sp)
    51be:	f0e2                	sd	s8,96(sp)
    51c0:	ece6                	sd	s9,88(sp)
    51c2:	e8ea                	sd	s10,80(sp)
    51c4:	e4ee                	sd	s11,72(sp)
    51c6:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    51c8:	00003517          	auipc	a0,0x3
    51cc:	c2050513          	addi	a0,a0,-992 # 7de8 <malloc+0x1fcc>
    51d0:	00001097          	auipc	ra,0x1
    51d4:	b94080e7          	jalr	-1132(ra) # 5d64 <printf>
  for (nfiles = 0;; nfiles++)
    51d8:	4481                	li	s1,0
    name[0] = 'f';
    51da:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    51de:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    51e2:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    51e6:	4b29                	li	s6,10
    printf("writing %s\n", name);
    51e8:	00003c97          	auipc	s9,0x3
    51ec:	c10c8c93          	addi	s9,s9,-1008 # 7df8 <malloc+0x1fdc>
    int total = 0;
    51f0:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    51f2:	00008a17          	auipc	s4,0x8
    51f6:	a86a0a13          	addi	s4,s4,-1402 # cc78 <buf>
    name[0] = 'f';
    51fa:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    51fe:	0384c7bb          	divw	a5,s1,s8
    5202:	0307879b          	addiw	a5,a5,48
    5206:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    520a:	0384e7bb          	remw	a5,s1,s8
    520e:	0377c7bb          	divw	a5,a5,s7
    5212:	0307879b          	addiw	a5,a5,48
    5216:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    521a:	0374e7bb          	remw	a5,s1,s7
    521e:	0367c7bb          	divw	a5,a5,s6
    5222:	0307879b          	addiw	a5,a5,48
    5226:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    522a:	0364e7bb          	remw	a5,s1,s6
    522e:	0307879b          	addiw	a5,a5,48
    5232:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    5236:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    523a:	f5040593          	addi	a1,s0,-176
    523e:	8566                	mv	a0,s9
    5240:	00001097          	auipc	ra,0x1
    5244:	b24080e7          	jalr	-1244(ra) # 5d64 <printf>
    int fd = open(name, O_CREATE | O_RDWR);
    5248:	20200593          	li	a1,514
    524c:	f5040513          	addi	a0,s0,-176
    5250:	00000097          	auipc	ra,0x0
    5254:	7c2080e7          	jalr	1986(ra) # 5a12 <open>
    5258:	892a                	mv	s2,a0
    if (fd < 0)
    525a:	0a055663          	bgez	a0,5306 <fsfull+0x15c>
      printf("open %s failed\n", name);
    525e:	f5040593          	addi	a1,s0,-176
    5262:	00003517          	auipc	a0,0x3
    5266:	ba650513          	addi	a0,a0,-1114 # 7e08 <malloc+0x1fec>
    526a:	00001097          	auipc	ra,0x1
    526e:	afa080e7          	jalr	-1286(ra) # 5d64 <printf>
  while (nfiles >= 0)
    5272:	0604c363          	bltz	s1,52d8 <fsfull+0x12e>
    name[0] = 'f';
    5276:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    527a:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    527e:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    5282:	4929                	li	s2,10
  while (nfiles >= 0)
    5284:	5afd                	li	s5,-1
    name[0] = 'f';
    5286:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    528a:	0344c7bb          	divw	a5,s1,s4
    528e:	0307879b          	addiw	a5,a5,48
    5292:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5296:	0344e7bb          	remw	a5,s1,s4
    529a:	0337c7bb          	divw	a5,a5,s3
    529e:	0307879b          	addiw	a5,a5,48
    52a2:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    52a6:	0334e7bb          	remw	a5,s1,s3
    52aa:	0327c7bb          	divw	a5,a5,s2
    52ae:	0307879b          	addiw	a5,a5,48
    52b2:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    52b6:	0324e7bb          	remw	a5,s1,s2
    52ba:	0307879b          	addiw	a5,a5,48
    52be:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    52c2:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    52c6:	f5040513          	addi	a0,s0,-176
    52ca:	00000097          	auipc	ra,0x0
    52ce:	758080e7          	jalr	1880(ra) # 5a22 <unlink>
    nfiles--;
    52d2:	34fd                	addiw	s1,s1,-1
  while (nfiles >= 0)
    52d4:	fb5499e3          	bne	s1,s5,5286 <fsfull+0xdc>
  printf("fsfull test finished\n");
    52d8:	00003517          	auipc	a0,0x3
    52dc:	b5050513          	addi	a0,a0,-1200 # 7e28 <malloc+0x200c>
    52e0:	00001097          	auipc	ra,0x1
    52e4:	a84080e7          	jalr	-1404(ra) # 5d64 <printf>
}
    52e8:	70aa                	ld	ra,168(sp)
    52ea:	740a                	ld	s0,160(sp)
    52ec:	64ea                	ld	s1,152(sp)
    52ee:	694a                	ld	s2,144(sp)
    52f0:	69aa                	ld	s3,136(sp)
    52f2:	6a0a                	ld	s4,128(sp)
    52f4:	7ae6                	ld	s5,120(sp)
    52f6:	7b46                	ld	s6,112(sp)
    52f8:	7ba6                	ld	s7,104(sp)
    52fa:	7c06                	ld	s8,96(sp)
    52fc:	6ce6                	ld	s9,88(sp)
    52fe:	6d46                	ld	s10,80(sp)
    5300:	6da6                	ld	s11,72(sp)
    5302:	614d                	addi	sp,sp,176
    5304:	8082                	ret
    int total = 0;
    5306:	89ee                	mv	s3,s11
      if (cc < BSIZE)
    5308:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    530c:	40000613          	li	a2,1024
    5310:	85d2                	mv	a1,s4
    5312:	854a                	mv	a0,s2
    5314:	00000097          	auipc	ra,0x0
    5318:	6de080e7          	jalr	1758(ra) # 59f2 <write>
      if (cc < BSIZE)
    531c:	00aad563          	bge	s5,a0,5326 <fsfull+0x17c>
      total += cc;
    5320:	00a989bb          	addw	s3,s3,a0
    {
    5324:	b7e5                	j	530c <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    5326:	85ce                	mv	a1,s3
    5328:	00003517          	auipc	a0,0x3
    532c:	af050513          	addi	a0,a0,-1296 # 7e18 <malloc+0x1ffc>
    5330:	00001097          	auipc	ra,0x1
    5334:	a34080e7          	jalr	-1484(ra) # 5d64 <printf>
    close(fd);
    5338:	854a                	mv	a0,s2
    533a:	00000097          	auipc	ra,0x0
    533e:	6c0080e7          	jalr	1728(ra) # 59fa <close>
    if (total == 0)
    5342:	f20988e3          	beqz	s3,5272 <fsfull+0xc8>
  for (nfiles = 0;; nfiles++)
    5346:	2485                	addiw	s1,s1,1
  {
    5348:	bd4d                	j	51fa <fsfull+0x50>

000000000000534a <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int run(void f(char *), char *s)
{
    534a:	7179                	addi	sp,sp,-48
    534c:	f406                	sd	ra,40(sp)
    534e:	f022                	sd	s0,32(sp)
    5350:	ec26                	sd	s1,24(sp)
    5352:	e84a                	sd	s2,16(sp)
    5354:	1800                	addi	s0,sp,48
    5356:	84aa                	mv	s1,a0
    5358:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    535a:	00003517          	auipc	a0,0x3
    535e:	ae650513          	addi	a0,a0,-1306 # 7e40 <malloc+0x2024>
    5362:	00001097          	auipc	ra,0x1
    5366:	a02080e7          	jalr	-1534(ra) # 5d64 <printf>
  if ((pid = fork()) < 0)
    536a:	00000097          	auipc	ra,0x0
    536e:	660080e7          	jalr	1632(ra) # 59ca <fork>
    5372:	02054e63          	bltz	a0,53ae <run+0x64>
  {
    printf("runtest: fork error\n");
    exit(1);
  }
  if (pid == 0)
    5376:	c929                	beqz	a0,53c8 <run+0x7e>
    f(s);
    exit(0);
  }
  else
  {
    wait(&xstatus);
    5378:	fdc40513          	addi	a0,s0,-36
    537c:	00000097          	auipc	ra,0x0
    5380:	65e080e7          	jalr	1630(ra) # 59da <wait>
    if (xstatus != 0)
    5384:	fdc42783          	lw	a5,-36(s0)
    5388:	c7b9                	beqz	a5,53d6 <run+0x8c>
      printf("FAILED\n");
    538a:	00003517          	auipc	a0,0x3
    538e:	ade50513          	addi	a0,a0,-1314 # 7e68 <malloc+0x204c>
    5392:	00001097          	auipc	ra,0x1
    5396:	9d2080e7          	jalr	-1582(ra) # 5d64 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    539a:	fdc42503          	lw	a0,-36(s0)
  }
}
    539e:	00153513          	seqz	a0,a0
    53a2:	70a2                	ld	ra,40(sp)
    53a4:	7402                	ld	s0,32(sp)
    53a6:	64e2                	ld	s1,24(sp)
    53a8:	6942                	ld	s2,16(sp)
    53aa:	6145                	addi	sp,sp,48
    53ac:	8082                	ret
    printf("runtest: fork error\n");
    53ae:	00003517          	auipc	a0,0x3
    53b2:	aa250513          	addi	a0,a0,-1374 # 7e50 <malloc+0x2034>
    53b6:	00001097          	auipc	ra,0x1
    53ba:	9ae080e7          	jalr	-1618(ra) # 5d64 <printf>
    exit(1);
    53be:	4505                	li	a0,1
    53c0:	00000097          	auipc	ra,0x0
    53c4:	612080e7          	jalr	1554(ra) # 59d2 <exit>
    f(s);
    53c8:	854a                	mv	a0,s2
    53ca:	9482                	jalr	s1
    exit(0);
    53cc:	4501                	li	a0,0
    53ce:	00000097          	auipc	ra,0x0
    53d2:	604080e7          	jalr	1540(ra) # 59d2 <exit>
      printf("OK\n");
    53d6:	00003517          	auipc	a0,0x3
    53da:	a9a50513          	addi	a0,a0,-1382 # 7e70 <malloc+0x2054>
    53de:	00001097          	auipc	ra,0x1
    53e2:	986080e7          	jalr	-1658(ra) # 5d64 <printf>
    53e6:	bf55                	j	539a <run+0x50>

00000000000053e8 <runtests>:

int runtests(struct test *tests, char *justone)
{
    53e8:	1101                	addi	sp,sp,-32
    53ea:	ec06                	sd	ra,24(sp)
    53ec:	e822                	sd	s0,16(sp)
    53ee:	e426                	sd	s1,8(sp)
    53f0:	e04a                	sd	s2,0(sp)
    53f2:	1000                	addi	s0,sp,32
    53f4:	84aa                	mv	s1,a0
    53f6:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++)
    53f8:	6508                	ld	a0,8(a0)
    53fa:	ed09                	bnez	a0,5414 <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    53fc:	4501                	li	a0,0
    53fe:	a82d                	j	5438 <runtests+0x50>
      if (!run(t->f, t->s))
    5400:	648c                	ld	a1,8(s1)
    5402:	6088                	ld	a0,0(s1)
    5404:	00000097          	auipc	ra,0x0
    5408:	f46080e7          	jalr	-186(ra) # 534a <run>
    540c:	cd09                	beqz	a0,5426 <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++)
    540e:	04c1                	addi	s1,s1,16
    5410:	6488                	ld	a0,8(s1)
    5412:	c11d                	beqz	a0,5438 <runtests+0x50>
    if ((justone == 0) || strcmp(t->s, justone) == 0)
    5414:	fe0906e3          	beqz	s2,5400 <runtests+0x18>
    5418:	85ca                	mv	a1,s2
    541a:	00000097          	auipc	ra,0x0
    541e:	368080e7          	jalr	872(ra) # 5782 <strcmp>
    5422:	f575                	bnez	a0,540e <runtests+0x26>
    5424:	bff1                	j	5400 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    5426:	00003517          	auipc	a0,0x3
    542a:	a5250513          	addi	a0,a0,-1454 # 7e78 <malloc+0x205c>
    542e:	00001097          	auipc	ra,0x1
    5432:	936080e7          	jalr	-1738(ra) # 5d64 <printf>
        return 1;
    5436:	4505                	li	a0,1
}
    5438:	60e2                	ld	ra,24(sp)
    543a:	6442                	ld	s0,16(sp)
    543c:	64a2                	ld	s1,8(sp)
    543e:	6902                	ld	s2,0(sp)
    5440:	6105                	addi	sp,sp,32
    5442:	8082                	ret

0000000000005444 <countfree>:
// touches the pages to force allocation.
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int countfree()
{
    5444:	7139                	addi	sp,sp,-64
    5446:	fc06                	sd	ra,56(sp)
    5448:	f822                	sd	s0,48(sp)
    544a:	f426                	sd	s1,40(sp)
    544c:	f04a                	sd	s2,32(sp)
    544e:	ec4e                	sd	s3,24(sp)
    5450:	0080                	addi	s0,sp,64
  int fds[2];

  if (pipe(fds) < 0)
    5452:	fc840513          	addi	a0,s0,-56
    5456:	00000097          	auipc	ra,0x0
    545a:	58c080e7          	jalr	1420(ra) # 59e2 <pipe>
    545e:	06054763          	bltz	a0,54cc <countfree+0x88>
  {
    printf("pipe() failed in countfree()\n");
    exit(1);
  }

  int pid = fork();
    5462:	00000097          	auipc	ra,0x0
    5466:	568080e7          	jalr	1384(ra) # 59ca <fork>

  if (pid < 0)
    546a:	06054e63          	bltz	a0,54e6 <countfree+0xa2>
  {
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if (pid == 0)
    546e:	ed51                	bnez	a0,550a <countfree+0xc6>
  {
    close(fds[0]);
    5470:	fc842503          	lw	a0,-56(s0)
    5474:	00000097          	auipc	ra,0x0
    5478:	586080e7          	jalr	1414(ra) # 59fa <close>

    while (1)
    {
      uint64 a = (uint64)sbrk(4096);
      if (a == 0xffffffffffffffff)
    547c:	597d                	li	s2,-1
      {
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    547e:	4485                	li	s1,1

      // report back one more page.
      if (write(fds[1], "x", 1) != 1)
    5480:	00001997          	auipc	s3,0x1
    5484:	b3898993          	addi	s3,s3,-1224 # 5fb8 <malloc+0x19c>
      uint64 a = (uint64)sbrk(4096);
    5488:	6505                	lui	a0,0x1
    548a:	00000097          	auipc	ra,0x0
    548e:	5d0080e7          	jalr	1488(ra) # 5a5a <sbrk>
      if (a == 0xffffffffffffffff)
    5492:	07250763          	beq	a0,s2,5500 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    5496:	6785                	lui	a5,0x1
    5498:	97aa                	add	a5,a5,a0
    549a:	fe978fa3          	sb	s1,-1(a5) # fff <linktest+0xe7>
      if (write(fds[1], "x", 1) != 1)
    549e:	8626                	mv	a2,s1
    54a0:	85ce                	mv	a1,s3
    54a2:	fcc42503          	lw	a0,-52(s0)
    54a6:	00000097          	auipc	ra,0x0
    54aa:	54c080e7          	jalr	1356(ra) # 59f2 <write>
    54ae:	fc950de3          	beq	a0,s1,5488 <countfree+0x44>
      {
        printf("write() failed in countfree()\n");
    54b2:	00003517          	auipc	a0,0x3
    54b6:	a1e50513          	addi	a0,a0,-1506 # 7ed0 <malloc+0x20b4>
    54ba:	00001097          	auipc	ra,0x1
    54be:	8aa080e7          	jalr	-1878(ra) # 5d64 <printf>
        exit(1);
    54c2:	4505                	li	a0,1
    54c4:	00000097          	auipc	ra,0x0
    54c8:	50e080e7          	jalr	1294(ra) # 59d2 <exit>
    printf("pipe() failed in countfree()\n");
    54cc:	00003517          	auipc	a0,0x3
    54d0:	9c450513          	addi	a0,a0,-1596 # 7e90 <malloc+0x2074>
    54d4:	00001097          	auipc	ra,0x1
    54d8:	890080e7          	jalr	-1904(ra) # 5d64 <printf>
    exit(1);
    54dc:	4505                	li	a0,1
    54de:	00000097          	auipc	ra,0x0
    54e2:	4f4080e7          	jalr	1268(ra) # 59d2 <exit>
    printf("fork failed in countfree()\n");
    54e6:	00003517          	auipc	a0,0x3
    54ea:	9ca50513          	addi	a0,a0,-1590 # 7eb0 <malloc+0x2094>
    54ee:	00001097          	auipc	ra,0x1
    54f2:	876080e7          	jalr	-1930(ra) # 5d64 <printf>
    exit(1);
    54f6:	4505                	li	a0,1
    54f8:	00000097          	auipc	ra,0x0
    54fc:	4da080e7          	jalr	1242(ra) # 59d2 <exit>
      }
    }

    exit(0);
    5500:	4501                	li	a0,0
    5502:	00000097          	auipc	ra,0x0
    5506:	4d0080e7          	jalr	1232(ra) # 59d2 <exit>
  }

  close(fds[1]);
    550a:	fcc42503          	lw	a0,-52(s0)
    550e:	00000097          	auipc	ra,0x0
    5512:	4ec080e7          	jalr	1260(ra) # 59fa <close>

  int n = 0;
    5516:	4481                	li	s1,0
  while (1)
  {
    char c;
    int cc = read(fds[0], &c, 1);
    5518:	4605                	li	a2,1
    551a:	fc740593          	addi	a1,s0,-57
    551e:	fc842503          	lw	a0,-56(s0)
    5522:	00000097          	auipc	ra,0x0
    5526:	4c8080e7          	jalr	1224(ra) # 59ea <read>
    if (cc < 0)
    552a:	00054563          	bltz	a0,5534 <countfree+0xf0>
    {
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if (cc == 0)
    552e:	c105                	beqz	a0,554e <countfree+0x10a>
      break;
    n += 1;
    5530:	2485                	addiw	s1,s1,1
  {
    5532:	b7dd                	j	5518 <countfree+0xd4>
      printf("read() failed in countfree()\n");
    5534:	00003517          	auipc	a0,0x3
    5538:	9bc50513          	addi	a0,a0,-1604 # 7ef0 <malloc+0x20d4>
    553c:	00001097          	auipc	ra,0x1
    5540:	828080e7          	jalr	-2008(ra) # 5d64 <printf>
      exit(1);
    5544:	4505                	li	a0,1
    5546:	00000097          	auipc	ra,0x0
    554a:	48c080e7          	jalr	1164(ra) # 59d2 <exit>
  }

  close(fds[0]);
    554e:	fc842503          	lw	a0,-56(s0)
    5552:	00000097          	auipc	ra,0x0
    5556:	4a8080e7          	jalr	1192(ra) # 59fa <close>
  wait((int *)0);
    555a:	4501                	li	a0,0
    555c:	00000097          	auipc	ra,0x0
    5560:	47e080e7          	jalr	1150(ra) # 59da <wait>

  return n;
}
    5564:	8526                	mv	a0,s1
    5566:	70e2                	ld	ra,56(sp)
    5568:	7442                	ld	s0,48(sp)
    556a:	74a2                	ld	s1,40(sp)
    556c:	7902                	ld	s2,32(sp)
    556e:	69e2                	ld	s3,24(sp)
    5570:	6121                	addi	sp,sp,64
    5572:	8082                	ret

0000000000005574 <drivetests>:

int drivetests(int quick, int continuous, char *justone)
{
    5574:	711d                	addi	sp,sp,-96
    5576:	ec86                	sd	ra,88(sp)
    5578:	e8a2                	sd	s0,80(sp)
    557a:	e4a6                	sd	s1,72(sp)
    557c:	e0ca                	sd	s2,64(sp)
    557e:	fc4e                	sd	s3,56(sp)
    5580:	f852                	sd	s4,48(sp)
    5582:	f456                	sd	s5,40(sp)
    5584:	f05a                	sd	s6,32(sp)
    5586:	ec5e                	sd	s7,24(sp)
    5588:	e862                	sd	s8,16(sp)
    558a:	e466                	sd	s9,8(sp)
    558c:	e06a                	sd	s10,0(sp)
    558e:	1080                	addi	s0,sp,96
    5590:	8a2a                	mv	s4,a0
    5592:	89ae                	mv	s3,a1
    5594:	8932                	mv	s2,a2
  do
  {
    printf("usertests starting\n");
    5596:	00003b97          	auipc	s7,0x3
    559a:	97ab8b93          	addi	s7,s7,-1670 # 7f10 <malloc+0x20f4>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone))
    559e:	00004b17          	auipc	s6,0x4
    55a2:	a72b0b13          	addi	s6,s6,-1422 # 9010 <quicktests>
    {
      if (continuous != 2)
    55a6:	4a89                	li	s5,2
        }
      }
    }
    if ((free1 = countfree()) < free0)
    {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    55a8:	00003c97          	auipc	s9,0x3
    55ac:	9a0c8c93          	addi	s9,s9,-1632 # 7f48 <malloc+0x212c>
      if (runtests(slowtests, justone))
    55b0:	00004c17          	auipc	s8,0x4
    55b4:	e30c0c13          	addi	s8,s8,-464 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    55b8:	00003d17          	auipc	s10,0x3
    55bc:	970d0d13          	addi	s10,s10,-1680 # 7f28 <malloc+0x210c>
    55c0:	a839                	j	55de <drivetests+0x6a>
    55c2:	856a                	mv	a0,s10
    55c4:	00000097          	auipc	ra,0x0
    55c8:	7a0080e7          	jalr	1952(ra) # 5d64 <printf>
    55cc:	a081                	j	560c <drivetests+0x98>
    if ((free1 = countfree()) < free0)
    55ce:	00000097          	auipc	ra,0x0
    55d2:	e76080e7          	jalr	-394(ra) # 5444 <countfree>
    55d6:	06954263          	blt	a0,s1,563a <drivetests+0xc6>
      if (continuous != 2)
      {
        return 1;
      }
    }
  } while (continuous);
    55da:	06098f63          	beqz	s3,5658 <drivetests+0xe4>
    printf("usertests starting\n");
    55de:	855e                	mv	a0,s7
    55e0:	00000097          	auipc	ra,0x0
    55e4:	784080e7          	jalr	1924(ra) # 5d64 <printf>
    int free0 = countfree();
    55e8:	00000097          	auipc	ra,0x0
    55ec:	e5c080e7          	jalr	-420(ra) # 5444 <countfree>
    55f0:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone))
    55f2:	85ca                	mv	a1,s2
    55f4:	855a                	mv	a0,s6
    55f6:	00000097          	auipc	ra,0x0
    55fa:	df2080e7          	jalr	-526(ra) # 53e8 <runtests>
    55fe:	c119                	beqz	a0,5604 <drivetests+0x90>
      if (continuous != 2)
    5600:	05599863          	bne	s3,s5,5650 <drivetests+0xdc>
    if (!quick)
    5604:	fc0a15e3          	bnez	s4,55ce <drivetests+0x5a>
      if (justone == 0)
    5608:	fa090de3          	beqz	s2,55c2 <drivetests+0x4e>
      if (runtests(slowtests, justone))
    560c:	85ca                	mv	a1,s2
    560e:	8562                	mv	a0,s8
    5610:	00000097          	auipc	ra,0x0
    5614:	dd8080e7          	jalr	-552(ra) # 53e8 <runtests>
    5618:	d95d                	beqz	a0,55ce <drivetests+0x5a>
        if (continuous != 2)
    561a:	03599d63          	bne	s3,s5,5654 <drivetests+0xe0>
    if ((free1 = countfree()) < free0)
    561e:	00000097          	auipc	ra,0x0
    5622:	e26080e7          	jalr	-474(ra) # 5444 <countfree>
    5626:	fa955ae3          	bge	a0,s1,55da <drivetests+0x66>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    562a:	8626                	mv	a2,s1
    562c:	85aa                	mv	a1,a0
    562e:	8566                	mv	a0,s9
    5630:	00000097          	auipc	ra,0x0
    5634:	734080e7          	jalr	1844(ra) # 5d64 <printf>
      if (continuous != 2)
    5638:	b75d                	j	55de <drivetests+0x6a>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    563a:	8626                	mv	a2,s1
    563c:	85aa                	mv	a1,a0
    563e:	8566                	mv	a0,s9
    5640:	00000097          	auipc	ra,0x0
    5644:	724080e7          	jalr	1828(ra) # 5d64 <printf>
      if (continuous != 2)
    5648:	f9598be3          	beq	s3,s5,55de <drivetests+0x6a>
        return 1;
    564c:	4505                	li	a0,1
    564e:	a031                	j	565a <drivetests+0xe6>
        return 1;
    5650:	4505                	li	a0,1
    5652:	a021                	j	565a <drivetests+0xe6>
          return 1;
    5654:	4505                	li	a0,1
    5656:	a011                	j	565a <drivetests+0xe6>
  return 0;
    5658:	854e                	mv	a0,s3
}
    565a:	60e6                	ld	ra,88(sp)
    565c:	6446                	ld	s0,80(sp)
    565e:	64a6                	ld	s1,72(sp)
    5660:	6906                	ld	s2,64(sp)
    5662:	79e2                	ld	s3,56(sp)
    5664:	7a42                	ld	s4,48(sp)
    5666:	7aa2                	ld	s5,40(sp)
    5668:	7b02                	ld	s6,32(sp)
    566a:	6be2                	ld	s7,24(sp)
    566c:	6c42                	ld	s8,16(sp)
    566e:	6ca2                	ld	s9,8(sp)
    5670:	6d02                	ld	s10,0(sp)
    5672:	6125                	addi	sp,sp,96
    5674:	8082                	ret

0000000000005676 <main>:

int main(int argc, char *argv[])
{
    5676:	1101                	addi	sp,sp,-32
    5678:	ec06                	sd	ra,24(sp)
    567a:	e822                	sd	s0,16(sp)
    567c:	e426                	sd	s1,8(sp)
    567e:	e04a                	sd	s2,0(sp)
    5680:	1000                	addi	s0,sp,32
    5682:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if (argc == 2 && strcmp(argv[1], "-q") == 0)
    5684:	4789                	li	a5,2
    5686:	02f50263          	beq	a0,a5,56aa <main+0x34>
  }
  else if (argc == 2 && argv[1][0] != '-')
  {
    justone = argv[1];
  }
  else if (argc > 1)
    568a:	4785                	li	a5,1
    568c:	06a7cd63          	blt	a5,a0,5706 <main+0x90>
  char *justone = 0;
    5690:	4601                	li	a2,0
  int quick = 0;
    5692:	4501                	li	a0,0
  int continuous = 0;
    5694:	4581                	li	a1,0
  {
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone))
    5696:	00000097          	auipc	ra,0x0
    569a:	ede080e7          	jalr	-290(ra) # 5574 <drivetests>
    569e:	c951                	beqz	a0,5732 <main+0xbc>
  {
    exit(1);
    56a0:	4505                	li	a0,1
    56a2:	00000097          	auipc	ra,0x0
    56a6:	330080e7          	jalr	816(ra) # 59d2 <exit>
    56aa:	892e                	mv	s2,a1
  if (argc == 2 && strcmp(argv[1], "-q") == 0)
    56ac:	00003597          	auipc	a1,0x3
    56b0:	8cc58593          	addi	a1,a1,-1844 # 7f78 <malloc+0x215c>
    56b4:	00893503          	ld	a0,8(s2)
    56b8:	00000097          	auipc	ra,0x0
    56bc:	0ca080e7          	jalr	202(ra) # 5782 <strcmp>
    56c0:	85aa                	mv	a1,a0
    56c2:	cd39                	beqz	a0,5720 <main+0xaa>
  else if (argc == 2 && strcmp(argv[1], "-c") == 0)
    56c4:	00003597          	auipc	a1,0x3
    56c8:	90c58593          	addi	a1,a1,-1780 # 7fd0 <malloc+0x21b4>
    56cc:	00893503          	ld	a0,8(s2)
    56d0:	00000097          	auipc	ra,0x0
    56d4:	0b2080e7          	jalr	178(ra) # 5782 <strcmp>
    56d8:	c931                	beqz	a0,572c <main+0xb6>
  else if (argc == 2 && strcmp(argv[1], "-C") == 0)
    56da:	00003597          	auipc	a1,0x3
    56de:	8ee58593          	addi	a1,a1,-1810 # 7fc8 <malloc+0x21ac>
    56e2:	00893503          	ld	a0,8(s2)
    56e6:	00000097          	auipc	ra,0x0
    56ea:	09c080e7          	jalr	156(ra) # 5782 <strcmp>
    56ee:	cd05                	beqz	a0,5726 <main+0xb0>
  else if (argc == 2 && argv[1][0] != '-')
    56f0:	00893603          	ld	a2,8(s2)
    56f4:	00064703          	lbu	a4,0(a2) # 3000 <fourteen+0x2c>
    56f8:	02d00793          	li	a5,45
    56fc:	00f70563          	beq	a4,a5,5706 <main+0x90>
  int quick = 0;
    5700:	4501                	li	a0,0
  int continuous = 0;
    5702:	4581                	li	a1,0
    5704:	bf49                	j	5696 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    5706:	00003517          	auipc	a0,0x3
    570a:	87a50513          	addi	a0,a0,-1926 # 7f80 <malloc+0x2164>
    570e:	00000097          	auipc	ra,0x0
    5712:	656080e7          	jalr	1622(ra) # 5d64 <printf>
    exit(1);
    5716:	4505                	li	a0,1
    5718:	00000097          	auipc	ra,0x0
    571c:	2ba080e7          	jalr	698(ra) # 59d2 <exit>
  char *justone = 0;
    5720:	4601                	li	a2,0
    quick = 1;
    5722:	4505                	li	a0,1
    5724:	bf8d                	j	5696 <main+0x20>
    continuous = 2;
    5726:	85a6                	mv	a1,s1
  char *justone = 0;
    5728:	4601                	li	a2,0
    572a:	b7b5                	j	5696 <main+0x20>
    572c:	4601                	li	a2,0
    continuous = 1;
    572e:	4585                	li	a1,1
    5730:	b79d                	j	5696 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    5732:	00003517          	auipc	a0,0x3
    5736:	87e50513          	addi	a0,a0,-1922 # 7fb0 <malloc+0x2194>
    573a:	00000097          	auipc	ra,0x0
    573e:	62a080e7          	jalr	1578(ra) # 5d64 <printf>
  exit(0);
    5742:	4501                	li	a0,0
    5744:	00000097          	auipc	ra,0x0
    5748:	28e080e7          	jalr	654(ra) # 59d2 <exit>

000000000000574c <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
    574c:	1141                	addi	sp,sp,-16
    574e:	e406                	sd	ra,8(sp)
    5750:	e022                	sd	s0,0(sp)
    5752:	0800                	addi	s0,sp,16
  extern int main();
  main();
    5754:	00000097          	auipc	ra,0x0
    5758:	f22080e7          	jalr	-222(ra) # 5676 <main>
  exit(0);
    575c:	4501                	li	a0,0
    575e:	00000097          	auipc	ra,0x0
    5762:	274080e7          	jalr	628(ra) # 59d2 <exit>

0000000000005766 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
    5766:	1141                	addi	sp,sp,-16
    5768:	e422                	sd	s0,8(sp)
    576a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
    576c:	87aa                	mv	a5,a0
    576e:	0585                	addi	a1,a1,1
    5770:	0785                	addi	a5,a5,1
    5772:	fff5c703          	lbu	a4,-1(a1)
    5776:	fee78fa3          	sb	a4,-1(a5)
    577a:	fb75                	bnez	a4,576e <strcpy+0x8>
    ;
  return os;
}
    577c:	6422                	ld	s0,8(sp)
    577e:	0141                	addi	sp,sp,16
    5780:	8082                	ret

0000000000005782 <strcmp>:

int strcmp(const char *p, const char *q)
{
    5782:	1141                	addi	sp,sp,-16
    5784:	e422                	sd	s0,8(sp)
    5786:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
    5788:	00054783          	lbu	a5,0(a0)
    578c:	cb91                	beqz	a5,57a0 <strcmp+0x1e>
    578e:	0005c703          	lbu	a4,0(a1)
    5792:	00f71763          	bne	a4,a5,57a0 <strcmp+0x1e>
    p++, q++;
    5796:	0505                	addi	a0,a0,1
    5798:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
    579a:	00054783          	lbu	a5,0(a0)
    579e:	fbe5                	bnez	a5,578e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    57a0:	0005c503          	lbu	a0,0(a1)
}
    57a4:	40a7853b          	subw	a0,a5,a0
    57a8:	6422                	ld	s0,8(sp)
    57aa:	0141                	addi	sp,sp,16
    57ac:	8082                	ret

00000000000057ae <strlen>:

uint strlen(const char *s)
{
    57ae:	1141                	addi	sp,sp,-16
    57b0:	e422                	sd	s0,8(sp)
    57b2:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    57b4:	00054783          	lbu	a5,0(a0)
    57b8:	cf91                	beqz	a5,57d4 <strlen+0x26>
    57ba:	0505                	addi	a0,a0,1
    57bc:	87aa                	mv	a5,a0
    57be:	4685                	li	a3,1
    57c0:	9e89                	subw	a3,a3,a0
    57c2:	00f6853b          	addw	a0,a3,a5
    57c6:	0785                	addi	a5,a5,1
    57c8:	fff7c703          	lbu	a4,-1(a5)
    57cc:	fb7d                	bnez	a4,57c2 <strlen+0x14>
    ;
  return n;
}
    57ce:	6422                	ld	s0,8(sp)
    57d0:	0141                	addi	sp,sp,16
    57d2:	8082                	ret
  for (n = 0; s[n]; n++)
    57d4:	4501                	li	a0,0
    57d6:	bfe5                	j	57ce <strlen+0x20>

00000000000057d8 <memset>:

void *
memset(void *dst, int c, uint n)
{
    57d8:	1141                	addi	sp,sp,-16
    57da:	e422                	sd	s0,8(sp)
    57dc:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++)
    57de:	ca19                	beqz	a2,57f4 <memset+0x1c>
    57e0:	87aa                	mv	a5,a0
    57e2:	1602                	slli	a2,a2,0x20
    57e4:	9201                	srli	a2,a2,0x20
    57e6:	00a60733          	add	a4,a2,a0
  {
    cdst[i] = c;
    57ea:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++)
    57ee:	0785                	addi	a5,a5,1
    57f0:	fee79de3          	bne	a5,a4,57ea <memset+0x12>
  }
  return dst;
}
    57f4:	6422                	ld	s0,8(sp)
    57f6:	0141                	addi	sp,sp,16
    57f8:	8082                	ret

00000000000057fa <strchr>:

char *
strchr(const char *s, char c)
{
    57fa:	1141                	addi	sp,sp,-16
    57fc:	e422                	sd	s0,8(sp)
    57fe:	0800                	addi	s0,sp,16
  for (; *s; s++)
    5800:	00054783          	lbu	a5,0(a0)
    5804:	cb99                	beqz	a5,581a <strchr+0x20>
    if (*s == c)
    5806:	00f58763          	beq	a1,a5,5814 <strchr+0x1a>
  for (; *s; s++)
    580a:	0505                	addi	a0,a0,1
    580c:	00054783          	lbu	a5,0(a0)
    5810:	fbfd                	bnez	a5,5806 <strchr+0xc>
      return (char *)s;
  return 0;
    5812:	4501                	li	a0,0
}
    5814:	6422                	ld	s0,8(sp)
    5816:	0141                	addi	sp,sp,16
    5818:	8082                	ret
  return 0;
    581a:	4501                	li	a0,0
    581c:	bfe5                	j	5814 <strchr+0x1a>

000000000000581e <gets>:

char *
gets(char *buf, int max)
{
    581e:	711d                	addi	sp,sp,-96
    5820:	ec86                	sd	ra,88(sp)
    5822:	e8a2                	sd	s0,80(sp)
    5824:	e4a6                	sd	s1,72(sp)
    5826:	e0ca                	sd	s2,64(sp)
    5828:	fc4e                	sd	s3,56(sp)
    582a:	f852                	sd	s4,48(sp)
    582c:	f456                	sd	s5,40(sp)
    582e:	f05a                	sd	s6,32(sp)
    5830:	ec5e                	sd	s7,24(sp)
    5832:	1080                	addi	s0,sp,96
    5834:	8baa                	mv	s7,a0
    5836:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;)
    5838:	892a                	mv	s2,a0
    583a:	4481                	li	s1,0
  {
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
    583c:	4aa9                	li	s5,10
    583e:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;)
    5840:	89a6                	mv	s3,s1
    5842:	2485                	addiw	s1,s1,1
    5844:	0344d863          	bge	s1,s4,5874 <gets+0x56>
    cc = read(0, &c, 1);
    5848:	4605                	li	a2,1
    584a:	faf40593          	addi	a1,s0,-81
    584e:	4501                	li	a0,0
    5850:	00000097          	auipc	ra,0x0
    5854:	19a080e7          	jalr	410(ra) # 59ea <read>
    if (cc < 1)
    5858:	00a05e63          	blez	a0,5874 <gets+0x56>
    buf[i++] = c;
    585c:	faf44783          	lbu	a5,-81(s0)
    5860:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
    5864:	01578763          	beq	a5,s5,5872 <gets+0x54>
    5868:	0905                	addi	s2,s2,1
    586a:	fd679be3          	bne	a5,s6,5840 <gets+0x22>
  for (i = 0; i + 1 < max;)
    586e:	89a6                	mv	s3,s1
    5870:	a011                	j	5874 <gets+0x56>
    5872:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5874:	99de                	add	s3,s3,s7
    5876:	00098023          	sb	zero,0(s3)
  return buf;
}
    587a:	855e                	mv	a0,s7
    587c:	60e6                	ld	ra,88(sp)
    587e:	6446                	ld	s0,80(sp)
    5880:	64a6                	ld	s1,72(sp)
    5882:	6906                	ld	s2,64(sp)
    5884:	79e2                	ld	s3,56(sp)
    5886:	7a42                	ld	s4,48(sp)
    5888:	7aa2                	ld	s5,40(sp)
    588a:	7b02                	ld	s6,32(sp)
    588c:	6be2                	ld	s7,24(sp)
    588e:	6125                	addi	sp,sp,96
    5890:	8082                	ret

0000000000005892 <stat>:

int stat(const char *n, struct stat *st)
{
    5892:	1101                	addi	sp,sp,-32
    5894:	ec06                	sd	ra,24(sp)
    5896:	e822                	sd	s0,16(sp)
    5898:	e426                	sd	s1,8(sp)
    589a:	e04a                	sd	s2,0(sp)
    589c:	1000                	addi	s0,sp,32
    589e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    58a0:	4581                	li	a1,0
    58a2:	00000097          	auipc	ra,0x0
    58a6:	170080e7          	jalr	368(ra) # 5a12 <open>
  if (fd < 0)
    58aa:	02054563          	bltz	a0,58d4 <stat+0x42>
    58ae:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    58b0:	85ca                	mv	a1,s2
    58b2:	00000097          	auipc	ra,0x0
    58b6:	178080e7          	jalr	376(ra) # 5a2a <fstat>
    58ba:	892a                	mv	s2,a0
  close(fd);
    58bc:	8526                	mv	a0,s1
    58be:	00000097          	auipc	ra,0x0
    58c2:	13c080e7          	jalr	316(ra) # 59fa <close>
  return r;
}
    58c6:	854a                	mv	a0,s2
    58c8:	60e2                	ld	ra,24(sp)
    58ca:	6442                	ld	s0,16(sp)
    58cc:	64a2                	ld	s1,8(sp)
    58ce:	6902                	ld	s2,0(sp)
    58d0:	6105                	addi	sp,sp,32
    58d2:	8082                	ret
    return -1;
    58d4:	597d                	li	s2,-1
    58d6:	bfc5                	j	58c6 <stat+0x34>

00000000000058d8 <atoi>:

int atoi(const char *s)
{
    58d8:	1141                	addi	sp,sp,-16
    58da:	e422                	sd	s0,8(sp)
    58dc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
    58de:	00054683          	lbu	a3,0(a0)
    58e2:	fd06879b          	addiw	a5,a3,-48
    58e6:	0ff7f793          	zext.b	a5,a5
    58ea:	4625                	li	a2,9
    58ec:	02f66863          	bltu	a2,a5,591c <atoi+0x44>
    58f0:	872a                	mv	a4,a0
  n = 0;
    58f2:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
    58f4:	0705                	addi	a4,a4,1
    58f6:	0025179b          	slliw	a5,a0,0x2
    58fa:	9fa9                	addw	a5,a5,a0
    58fc:	0017979b          	slliw	a5,a5,0x1
    5900:	9fb5                	addw	a5,a5,a3
    5902:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
    5906:	00074683          	lbu	a3,0(a4)
    590a:	fd06879b          	addiw	a5,a3,-48
    590e:	0ff7f793          	zext.b	a5,a5
    5912:	fef671e3          	bgeu	a2,a5,58f4 <atoi+0x1c>
  return n;
}
    5916:	6422                	ld	s0,8(sp)
    5918:	0141                	addi	sp,sp,16
    591a:	8082                	ret
  n = 0;
    591c:	4501                	li	a0,0
    591e:	bfe5                	j	5916 <atoi+0x3e>

0000000000005920 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
    5920:	1141                	addi	sp,sp,-16
    5922:	e422                	sd	s0,8(sp)
    5924:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst)
    5926:	02b57463          	bgeu	a0,a1,594e <memmove+0x2e>
  {
    while (n-- > 0)
    592a:	00c05f63          	blez	a2,5948 <memmove+0x28>
    592e:	1602                	slli	a2,a2,0x20
    5930:	9201                	srli	a2,a2,0x20
    5932:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5936:	872a                	mv	a4,a0
      *dst++ = *src++;
    5938:	0585                	addi	a1,a1,1
    593a:	0705                	addi	a4,a4,1
    593c:	fff5c683          	lbu	a3,-1(a1)
    5940:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    5944:	fee79ae3          	bne	a5,a4,5938 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5948:	6422                	ld	s0,8(sp)
    594a:	0141                	addi	sp,sp,16
    594c:	8082                	ret
    dst += n;
    594e:	00c50733          	add	a4,a0,a2
    src += n;
    5952:	95b2                	add	a1,a1,a2
    while (n-- > 0)
    5954:	fec05ae3          	blez	a2,5948 <memmove+0x28>
    5958:	fff6079b          	addiw	a5,a2,-1
    595c:	1782                	slli	a5,a5,0x20
    595e:	9381                	srli	a5,a5,0x20
    5960:	fff7c793          	not	a5,a5
    5964:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5966:	15fd                	addi	a1,a1,-1
    5968:	177d                	addi	a4,a4,-1
    596a:	0005c683          	lbu	a3,0(a1)
    596e:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
    5972:	fee79ae3          	bne	a5,a4,5966 <memmove+0x46>
    5976:	bfc9                	j	5948 <memmove+0x28>

0000000000005978 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
    5978:	1141                	addi	sp,sp,-16
    597a:	e422                	sd	s0,8(sp)
    597c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0)
    597e:	ca05                	beqz	a2,59ae <memcmp+0x36>
    5980:	fff6069b          	addiw	a3,a2,-1
    5984:	1682                	slli	a3,a3,0x20
    5986:	9281                	srli	a3,a3,0x20
    5988:	0685                	addi	a3,a3,1
    598a:	96aa                	add	a3,a3,a0
  {
    if (*p1 != *p2)
    598c:	00054783          	lbu	a5,0(a0)
    5990:	0005c703          	lbu	a4,0(a1)
    5994:	00e79863          	bne	a5,a4,59a4 <memcmp+0x2c>
    {
      return *p1 - *p2;
    }
    p1++;
    5998:	0505                	addi	a0,a0,1
    p2++;
    599a:	0585                	addi	a1,a1,1
  while (n-- > 0)
    599c:	fed518e3          	bne	a0,a3,598c <memcmp+0x14>
  }
  return 0;
    59a0:	4501                	li	a0,0
    59a2:	a019                	j	59a8 <memcmp+0x30>
      return *p1 - *p2;
    59a4:	40e7853b          	subw	a0,a5,a4
}
    59a8:	6422                	ld	s0,8(sp)
    59aa:	0141                	addi	sp,sp,16
    59ac:	8082                	ret
  return 0;
    59ae:	4501                	li	a0,0
    59b0:	bfe5                	j	59a8 <memcmp+0x30>

00000000000059b2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    59b2:	1141                	addi	sp,sp,-16
    59b4:	e406                	sd	ra,8(sp)
    59b6:	e022                	sd	s0,0(sp)
    59b8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    59ba:	00000097          	auipc	ra,0x0
    59be:	f66080e7          	jalr	-154(ra) # 5920 <memmove>
}
    59c2:	60a2                	ld	ra,8(sp)
    59c4:	6402                	ld	s0,0(sp)
    59c6:	0141                	addi	sp,sp,16
    59c8:	8082                	ret

00000000000059ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    59ca:	4885                	li	a7,1
 ecall
    59cc:	00000073          	ecall
 ret
    59d0:	8082                	ret

00000000000059d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
    59d2:	4889                	li	a7,2
 ecall
    59d4:	00000073          	ecall
 ret
    59d8:	8082                	ret

00000000000059da <wait>:
.global wait
wait:
 li a7, SYS_wait
    59da:	488d                	li	a7,3
 ecall
    59dc:	00000073          	ecall
 ret
    59e0:	8082                	ret

00000000000059e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    59e2:	4891                	li	a7,4
 ecall
    59e4:	00000073          	ecall
 ret
    59e8:	8082                	ret

00000000000059ea <read>:
.global read
read:
 li a7, SYS_read
    59ea:	4895                	li	a7,5
 ecall
    59ec:	00000073          	ecall
 ret
    59f0:	8082                	ret

00000000000059f2 <write>:
.global write
write:
 li a7, SYS_write
    59f2:	48c1                	li	a7,16
 ecall
    59f4:	00000073          	ecall
 ret
    59f8:	8082                	ret

00000000000059fa <close>:
.global close
close:
 li a7, SYS_close
    59fa:	48d5                	li	a7,21
 ecall
    59fc:	00000073          	ecall
 ret
    5a00:	8082                	ret

0000000000005a02 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5a02:	4899                	li	a7,6
 ecall
    5a04:	00000073          	ecall
 ret
    5a08:	8082                	ret

0000000000005a0a <exec>:
.global exec
exec:
 li a7, SYS_exec
    5a0a:	489d                	li	a7,7
 ecall
    5a0c:	00000073          	ecall
 ret
    5a10:	8082                	ret

0000000000005a12 <open>:
.global open
open:
 li a7, SYS_open
    5a12:	48bd                	li	a7,15
 ecall
    5a14:	00000073          	ecall
 ret
    5a18:	8082                	ret

0000000000005a1a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5a1a:	48c5                	li	a7,17
 ecall
    5a1c:	00000073          	ecall
 ret
    5a20:	8082                	ret

0000000000005a22 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5a22:	48c9                	li	a7,18
 ecall
    5a24:	00000073          	ecall
 ret
    5a28:	8082                	ret

0000000000005a2a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5a2a:	48a1                	li	a7,8
 ecall
    5a2c:	00000073          	ecall
 ret
    5a30:	8082                	ret

0000000000005a32 <link>:
.global link
link:
 li a7, SYS_link
    5a32:	48cd                	li	a7,19
 ecall
    5a34:	00000073          	ecall
 ret
    5a38:	8082                	ret

0000000000005a3a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5a3a:	48d1                	li	a7,20
 ecall
    5a3c:	00000073          	ecall
 ret
    5a40:	8082                	ret

0000000000005a42 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5a42:	48a5                	li	a7,9
 ecall
    5a44:	00000073          	ecall
 ret
    5a48:	8082                	ret

0000000000005a4a <dup>:
.global dup
dup:
 li a7, SYS_dup
    5a4a:	48a9                	li	a7,10
 ecall
    5a4c:	00000073          	ecall
 ret
    5a50:	8082                	ret

0000000000005a52 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5a52:	48ad                	li	a7,11
 ecall
    5a54:	00000073          	ecall
 ret
    5a58:	8082                	ret

0000000000005a5a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5a5a:	48b1                	li	a7,12
 ecall
    5a5c:	00000073          	ecall
 ret
    5a60:	8082                	ret

0000000000005a62 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5a62:	48b5                	li	a7,13
 ecall
    5a64:	00000073          	ecall
 ret
    5a68:	8082                	ret

0000000000005a6a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5a6a:	48b9                	li	a7,14
 ecall
    5a6c:	00000073          	ecall
 ret
    5a70:	8082                	ret

0000000000005a72 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
    5a72:	48e1                	li	a7,24
 ecall
    5a74:	00000073          	ecall
 ret
    5a78:	8082                	ret

0000000000005a7a <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
    5a7a:	48dd                	li	a7,23
 ecall
    5a7c:	00000073          	ecall
 ret
    5a80:	8082                	ret

0000000000005a82 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
    5a82:	48d9                	li	a7,22
 ecall
    5a84:	00000073          	ecall
 ret
    5a88:	8082                	ret

0000000000005a8a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5a8a:	1101                	addi	sp,sp,-32
    5a8c:	ec06                	sd	ra,24(sp)
    5a8e:	e822                	sd	s0,16(sp)
    5a90:	1000                	addi	s0,sp,32
    5a92:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5a96:	4605                	li	a2,1
    5a98:	fef40593          	addi	a1,s0,-17
    5a9c:	00000097          	auipc	ra,0x0
    5aa0:	f56080e7          	jalr	-170(ra) # 59f2 <write>
}
    5aa4:	60e2                	ld	ra,24(sp)
    5aa6:	6442                	ld	s0,16(sp)
    5aa8:	6105                	addi	sp,sp,32
    5aaa:	8082                	ret

0000000000005aac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5aac:	7139                	addi	sp,sp,-64
    5aae:	fc06                	sd	ra,56(sp)
    5ab0:	f822                	sd	s0,48(sp)
    5ab2:	f426                	sd	s1,40(sp)
    5ab4:	f04a                	sd	s2,32(sp)
    5ab6:	ec4e                	sd	s3,24(sp)
    5ab8:	0080                	addi	s0,sp,64
    5aba:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if (sgn && xx < 0)
    5abc:	c299                	beqz	a3,5ac2 <printint+0x16>
    5abe:	0805c963          	bltz	a1,5b50 <printint+0xa4>
    neg = 1;
    x = -xx;
  }
  else
  {
    x = xx;
    5ac2:	2581                	sext.w	a1,a1
  neg = 0;
    5ac4:	4881                	li	a7,0
    5ac6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5aca:	4701                	li	a4,0
  do
  {
    buf[i++] = digits[x % base];
    5acc:	2601                	sext.w	a2,a2
    5ace:	00003517          	auipc	a0,0x3
    5ad2:	8ca50513          	addi	a0,a0,-1846 # 8398 <digits>
    5ad6:	883a                	mv	a6,a4
    5ad8:	2705                	addiw	a4,a4,1
    5ada:	02c5f7bb          	remuw	a5,a1,a2
    5ade:	1782                	slli	a5,a5,0x20
    5ae0:	9381                	srli	a5,a5,0x20
    5ae2:	97aa                	add	a5,a5,a0
    5ae4:	0007c783          	lbu	a5,0(a5)
    5ae8:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    5aec:	0005879b          	sext.w	a5,a1
    5af0:	02c5d5bb          	divuw	a1,a1,a2
    5af4:	0685                	addi	a3,a3,1
    5af6:	fec7f0e3          	bgeu	a5,a2,5ad6 <printint+0x2a>
  if (neg)
    5afa:	00088c63          	beqz	a7,5b12 <printint+0x66>
    buf[i++] = '-';
    5afe:	fd070793          	addi	a5,a4,-48
    5b02:	00878733          	add	a4,a5,s0
    5b06:	02d00793          	li	a5,45
    5b0a:	fef70823          	sb	a5,-16(a4)
    5b0e:	0028071b          	addiw	a4,a6,2

  while (--i >= 0)
    5b12:	02e05863          	blez	a4,5b42 <printint+0x96>
    5b16:	fc040793          	addi	a5,s0,-64
    5b1a:	00e78933          	add	s2,a5,a4
    5b1e:	fff78993          	addi	s3,a5,-1
    5b22:	99ba                	add	s3,s3,a4
    5b24:	377d                	addiw	a4,a4,-1
    5b26:	1702                	slli	a4,a4,0x20
    5b28:	9301                	srli	a4,a4,0x20
    5b2a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5b2e:	fff94583          	lbu	a1,-1(s2)
    5b32:	8526                	mv	a0,s1
    5b34:	00000097          	auipc	ra,0x0
    5b38:	f56080e7          	jalr	-170(ra) # 5a8a <putc>
  while (--i >= 0)
    5b3c:	197d                	addi	s2,s2,-1
    5b3e:	ff3918e3          	bne	s2,s3,5b2e <printint+0x82>
}
    5b42:	70e2                	ld	ra,56(sp)
    5b44:	7442                	ld	s0,48(sp)
    5b46:	74a2                	ld	s1,40(sp)
    5b48:	7902                	ld	s2,32(sp)
    5b4a:	69e2                	ld	s3,24(sp)
    5b4c:	6121                	addi	sp,sp,64
    5b4e:	8082                	ret
    x = -xx;
    5b50:	40b005bb          	negw	a1,a1
    neg = 1;
    5b54:	4885                	li	a7,1
    x = -xx;
    5b56:	bf85                	j	5ac6 <printint+0x1a>

0000000000005b58 <vprintf>:
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void vprintf(int fd, const char *fmt, va_list ap)
{
    5b58:	7119                	addi	sp,sp,-128
    5b5a:	fc86                	sd	ra,120(sp)
    5b5c:	f8a2                	sd	s0,112(sp)
    5b5e:	f4a6                	sd	s1,104(sp)
    5b60:	f0ca                	sd	s2,96(sp)
    5b62:	ecce                	sd	s3,88(sp)
    5b64:	e8d2                	sd	s4,80(sp)
    5b66:	e4d6                	sd	s5,72(sp)
    5b68:	e0da                	sd	s6,64(sp)
    5b6a:	fc5e                	sd	s7,56(sp)
    5b6c:	f862                	sd	s8,48(sp)
    5b6e:	f466                	sd	s9,40(sp)
    5b70:	f06a                	sd	s10,32(sp)
    5b72:	ec6e                	sd	s11,24(sp)
    5b74:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++)
    5b76:	0005c903          	lbu	s2,0(a1)
    5b7a:	18090f63          	beqz	s2,5d18 <vprintf+0x1c0>
    5b7e:	8aaa                	mv	s5,a0
    5b80:	8b32                	mv	s6,a2
    5b82:	00158493          	addi	s1,a1,1
  state = 0;
    5b86:	4981                	li	s3,0
      else
      {
        putc(fd, c);
      }
    }
    else if (state == '%')
    5b88:	02500a13          	li	s4,37
    5b8c:	4c55                	li	s8,21
    5b8e:	00002c97          	auipc	s9,0x2
    5b92:	7b2c8c93          	addi	s9,s9,1970 # 8340 <malloc+0x2524>
      else if (c == 's')
      {
        s = va_arg(ap, char *);
        if (s == 0)
          s = "(null)";
        while (*s != 0)
    5b96:	02800d93          	li	s11,40
  putc(fd, 'x');
    5b9a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5b9c:	00002b97          	auipc	s7,0x2
    5ba0:	7fcb8b93          	addi	s7,s7,2044 # 8398 <digits>
    5ba4:	a839                	j	5bc2 <vprintf+0x6a>
        putc(fd, c);
    5ba6:	85ca                	mv	a1,s2
    5ba8:	8556                	mv	a0,s5
    5baa:	00000097          	auipc	ra,0x0
    5bae:	ee0080e7          	jalr	-288(ra) # 5a8a <putc>
    5bb2:	a019                	j	5bb8 <vprintf+0x60>
    else if (state == '%')
    5bb4:	01498d63          	beq	s3,s4,5bce <vprintf+0x76>
  for (i = 0; fmt[i]; i++)
    5bb8:	0485                	addi	s1,s1,1
    5bba:	fff4c903          	lbu	s2,-1(s1)
    5bbe:	14090d63          	beqz	s2,5d18 <vprintf+0x1c0>
    if (state == 0)
    5bc2:	fe0999e3          	bnez	s3,5bb4 <vprintf+0x5c>
      if (c == '%')
    5bc6:	ff4910e3          	bne	s2,s4,5ba6 <vprintf+0x4e>
        state = '%';
    5bca:	89d2                	mv	s3,s4
    5bcc:	b7f5                	j	5bb8 <vprintf+0x60>
      if (c == 'd')
    5bce:	11490c63          	beq	s2,s4,5ce6 <vprintf+0x18e>
    5bd2:	f9d9079b          	addiw	a5,s2,-99
    5bd6:	0ff7f793          	zext.b	a5,a5
    5bda:	10fc6e63          	bltu	s8,a5,5cf6 <vprintf+0x19e>
    5bde:	f9d9079b          	addiw	a5,s2,-99
    5be2:	0ff7f713          	zext.b	a4,a5
    5be6:	10ec6863          	bltu	s8,a4,5cf6 <vprintf+0x19e>
    5bea:	00271793          	slli	a5,a4,0x2
    5bee:	97e6                	add	a5,a5,s9
    5bf0:	439c                	lw	a5,0(a5)
    5bf2:	97e6                	add	a5,a5,s9
    5bf4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    5bf6:	008b0913          	addi	s2,s6,8
    5bfa:	4685                	li	a3,1
    5bfc:	4629                	li	a2,10
    5bfe:	000b2583          	lw	a1,0(s6)
    5c02:	8556                	mv	a0,s5
    5c04:	00000097          	auipc	ra,0x0
    5c08:	ea8080e7          	jalr	-344(ra) # 5aac <printint>
    5c0c:	8b4a                	mv	s6,s2
      {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    5c0e:	4981                	li	s3,0
    5c10:	b765                	j	5bb8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5c12:	008b0913          	addi	s2,s6,8
    5c16:	4681                	li	a3,0
    5c18:	4629                	li	a2,10
    5c1a:	000b2583          	lw	a1,0(s6)
    5c1e:	8556                	mv	a0,s5
    5c20:	00000097          	auipc	ra,0x0
    5c24:	e8c080e7          	jalr	-372(ra) # 5aac <printint>
    5c28:	8b4a                	mv	s6,s2
      state = 0;
    5c2a:	4981                	li	s3,0
    5c2c:	b771                	j	5bb8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5c2e:	008b0913          	addi	s2,s6,8
    5c32:	4681                	li	a3,0
    5c34:	866a                	mv	a2,s10
    5c36:	000b2583          	lw	a1,0(s6)
    5c3a:	8556                	mv	a0,s5
    5c3c:	00000097          	auipc	ra,0x0
    5c40:	e70080e7          	jalr	-400(ra) # 5aac <printint>
    5c44:	8b4a                	mv	s6,s2
      state = 0;
    5c46:	4981                	li	s3,0
    5c48:	bf85                	j	5bb8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5c4a:	008b0793          	addi	a5,s6,8
    5c4e:	f8f43423          	sd	a5,-120(s0)
    5c52:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5c56:	03000593          	li	a1,48
    5c5a:	8556                	mv	a0,s5
    5c5c:	00000097          	auipc	ra,0x0
    5c60:	e2e080e7          	jalr	-466(ra) # 5a8a <putc>
  putc(fd, 'x');
    5c64:	07800593          	li	a1,120
    5c68:	8556                	mv	a0,s5
    5c6a:	00000097          	auipc	ra,0x0
    5c6e:	e20080e7          	jalr	-480(ra) # 5a8a <putc>
    5c72:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5c74:	03c9d793          	srli	a5,s3,0x3c
    5c78:	97de                	add	a5,a5,s7
    5c7a:	0007c583          	lbu	a1,0(a5)
    5c7e:	8556                	mv	a0,s5
    5c80:	00000097          	auipc	ra,0x0
    5c84:	e0a080e7          	jalr	-502(ra) # 5a8a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5c88:	0992                	slli	s3,s3,0x4
    5c8a:	397d                	addiw	s2,s2,-1
    5c8c:	fe0914e3          	bnez	s2,5c74 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
    5c90:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5c94:	4981                	li	s3,0
    5c96:	b70d                	j	5bb8 <vprintf+0x60>
        s = va_arg(ap, char *);
    5c98:	008b0913          	addi	s2,s6,8
    5c9c:	000b3983          	ld	s3,0(s6)
        if (s == 0)
    5ca0:	02098163          	beqz	s3,5cc2 <vprintf+0x16a>
        while (*s != 0)
    5ca4:	0009c583          	lbu	a1,0(s3)
    5ca8:	c5ad                	beqz	a1,5d12 <vprintf+0x1ba>
          putc(fd, *s);
    5caa:	8556                	mv	a0,s5
    5cac:	00000097          	auipc	ra,0x0
    5cb0:	dde080e7          	jalr	-546(ra) # 5a8a <putc>
          s++;
    5cb4:	0985                	addi	s3,s3,1
        while (*s != 0)
    5cb6:	0009c583          	lbu	a1,0(s3)
    5cba:	f9e5                	bnez	a1,5caa <vprintf+0x152>
        s = va_arg(ap, char *);
    5cbc:	8b4a                	mv	s6,s2
      state = 0;
    5cbe:	4981                	li	s3,0
    5cc0:	bde5                	j	5bb8 <vprintf+0x60>
          s = "(null)";
    5cc2:	00002997          	auipc	s3,0x2
    5cc6:	67698993          	addi	s3,s3,1654 # 8338 <malloc+0x251c>
        while (*s != 0)
    5cca:	85ee                	mv	a1,s11
    5ccc:	bff9                	j	5caa <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
    5cce:	008b0913          	addi	s2,s6,8
    5cd2:	000b4583          	lbu	a1,0(s6)
    5cd6:	8556                	mv	a0,s5
    5cd8:	00000097          	auipc	ra,0x0
    5cdc:	db2080e7          	jalr	-590(ra) # 5a8a <putc>
    5ce0:	8b4a                	mv	s6,s2
      state = 0;
    5ce2:	4981                	li	s3,0
    5ce4:	bdd1                	j	5bb8 <vprintf+0x60>
        putc(fd, c);
    5ce6:	85d2                	mv	a1,s4
    5ce8:	8556                	mv	a0,s5
    5cea:	00000097          	auipc	ra,0x0
    5cee:	da0080e7          	jalr	-608(ra) # 5a8a <putc>
      state = 0;
    5cf2:	4981                	li	s3,0
    5cf4:	b5d1                	j	5bb8 <vprintf+0x60>
        putc(fd, '%');
    5cf6:	85d2                	mv	a1,s4
    5cf8:	8556                	mv	a0,s5
    5cfa:	00000097          	auipc	ra,0x0
    5cfe:	d90080e7          	jalr	-624(ra) # 5a8a <putc>
        putc(fd, c);
    5d02:	85ca                	mv	a1,s2
    5d04:	8556                	mv	a0,s5
    5d06:	00000097          	auipc	ra,0x0
    5d0a:	d84080e7          	jalr	-636(ra) # 5a8a <putc>
      state = 0;
    5d0e:	4981                	li	s3,0
    5d10:	b565                	j	5bb8 <vprintf+0x60>
        s = va_arg(ap, char *);
    5d12:	8b4a                	mv	s6,s2
      state = 0;
    5d14:	4981                	li	s3,0
    5d16:	b54d                	j	5bb8 <vprintf+0x60>
    }
  }
}
    5d18:	70e6                	ld	ra,120(sp)
    5d1a:	7446                	ld	s0,112(sp)
    5d1c:	74a6                	ld	s1,104(sp)
    5d1e:	7906                	ld	s2,96(sp)
    5d20:	69e6                	ld	s3,88(sp)
    5d22:	6a46                	ld	s4,80(sp)
    5d24:	6aa6                	ld	s5,72(sp)
    5d26:	6b06                	ld	s6,64(sp)
    5d28:	7be2                	ld	s7,56(sp)
    5d2a:	7c42                	ld	s8,48(sp)
    5d2c:	7ca2                	ld	s9,40(sp)
    5d2e:	7d02                	ld	s10,32(sp)
    5d30:	6de2                	ld	s11,24(sp)
    5d32:	6109                	addi	sp,sp,128
    5d34:	8082                	ret

0000000000005d36 <fprintf>:

void fprintf(int fd, const char *fmt, ...)
{
    5d36:	715d                	addi	sp,sp,-80
    5d38:	ec06                	sd	ra,24(sp)
    5d3a:	e822                	sd	s0,16(sp)
    5d3c:	1000                	addi	s0,sp,32
    5d3e:	e010                	sd	a2,0(s0)
    5d40:	e414                	sd	a3,8(s0)
    5d42:	e818                	sd	a4,16(s0)
    5d44:	ec1c                	sd	a5,24(s0)
    5d46:	03043023          	sd	a6,32(s0)
    5d4a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5d4e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5d52:	8622                	mv	a2,s0
    5d54:	00000097          	auipc	ra,0x0
    5d58:	e04080e7          	jalr	-508(ra) # 5b58 <vprintf>
}
    5d5c:	60e2                	ld	ra,24(sp)
    5d5e:	6442                	ld	s0,16(sp)
    5d60:	6161                	addi	sp,sp,80
    5d62:	8082                	ret

0000000000005d64 <printf>:

void printf(const char *fmt, ...)
{
    5d64:	711d                	addi	sp,sp,-96
    5d66:	ec06                	sd	ra,24(sp)
    5d68:	e822                	sd	s0,16(sp)
    5d6a:	1000                	addi	s0,sp,32
    5d6c:	e40c                	sd	a1,8(s0)
    5d6e:	e810                	sd	a2,16(s0)
    5d70:	ec14                	sd	a3,24(s0)
    5d72:	f018                	sd	a4,32(s0)
    5d74:	f41c                	sd	a5,40(s0)
    5d76:	03043823          	sd	a6,48(s0)
    5d7a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5d7e:	00840613          	addi	a2,s0,8
    5d82:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5d86:	85aa                	mv	a1,a0
    5d88:	4505                	li	a0,1
    5d8a:	00000097          	auipc	ra,0x0
    5d8e:	dce080e7          	jalr	-562(ra) # 5b58 <vprintf>
}
    5d92:	60e2                	ld	ra,24(sp)
    5d94:	6442                	ld	s0,16(sp)
    5d96:	6125                	addi	sp,sp,96
    5d98:	8082                	ret

0000000000005d9a <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
    5d9a:	1141                	addi	sp,sp,-16
    5d9c:	e422                	sd	s0,8(sp)
    5d9e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
    5da0:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5da4:	00003797          	auipc	a5,0x3
    5da8:	6ac7b783          	ld	a5,1708(a5) # 9450 <freep>
    5dac:	a02d                	j	5dd6 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr)
  {
    bp->s.size += p->s.ptr->s.size;
    5dae:	4618                	lw	a4,8(a2)
    5db0:	9f2d                	addw	a4,a4,a1
    5db2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5db6:	6398                	ld	a4,0(a5)
    5db8:	6310                	ld	a2,0(a4)
    5dba:	a83d                	j	5df8 <free+0x5e>
  }
  else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp)
  {
    p->s.size += bp->s.size;
    5dbc:	ff852703          	lw	a4,-8(a0)
    5dc0:	9f31                	addw	a4,a4,a2
    5dc2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    5dc4:	ff053683          	ld	a3,-16(a0)
    5dc8:	a091                	j	5e0c <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5dca:	6398                	ld	a4,0(a5)
    5dcc:	00e7e463          	bltu	a5,a4,5dd4 <free+0x3a>
    5dd0:	00e6ea63          	bltu	a3,a4,5de4 <free+0x4a>
{
    5dd4:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5dd6:	fed7fae3          	bgeu	a5,a3,5dca <free+0x30>
    5dda:	6398                	ld	a4,0(a5)
    5ddc:	00e6e463          	bltu	a3,a4,5de4 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5de0:	fee7eae3          	bltu	a5,a4,5dd4 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr)
    5de4:	ff852583          	lw	a1,-8(a0)
    5de8:	6390                	ld	a2,0(a5)
    5dea:	02059813          	slli	a6,a1,0x20
    5dee:	01c85713          	srli	a4,a6,0x1c
    5df2:	9736                	add	a4,a4,a3
    5df4:	fae60de3          	beq	a2,a4,5dae <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    5df8:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp)
    5dfc:	4790                	lw	a2,8(a5)
    5dfe:	02061593          	slli	a1,a2,0x20
    5e02:	01c5d713          	srli	a4,a1,0x1c
    5e06:	973e                	add	a4,a4,a5
    5e08:	fae68ae3          	beq	a3,a4,5dbc <free+0x22>
    p->s.ptr = bp->s.ptr;
    5e0c:	e394                	sd	a3,0(a5)
  }
  else
    p->s.ptr = bp;
  freep = p;
    5e0e:	00003717          	auipc	a4,0x3
    5e12:	64f73123          	sd	a5,1602(a4) # 9450 <freep>
}
    5e16:	6422                	ld	s0,8(sp)
    5e18:	0141                	addi	sp,sp,16
    5e1a:	8082                	ret

0000000000005e1c <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
    5e1c:	7139                	addi	sp,sp,-64
    5e1e:	fc06                	sd	ra,56(sp)
    5e20:	f822                	sd	s0,48(sp)
    5e22:	f426                	sd	s1,40(sp)
    5e24:	f04a                	sd	s2,32(sp)
    5e26:	ec4e                	sd	s3,24(sp)
    5e28:	e852                	sd	s4,16(sp)
    5e2a:	e456                	sd	s5,8(sp)
    5e2c:	e05a                	sd	s6,0(sp)
    5e2e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    5e30:	02051493          	slli	s1,a0,0x20
    5e34:	9081                	srli	s1,s1,0x20
    5e36:	04bd                	addi	s1,s1,15
    5e38:	8091                	srli	s1,s1,0x4
    5e3a:	0014899b          	addiw	s3,s1,1
    5e3e:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0)
    5e40:	00003517          	auipc	a0,0x3
    5e44:	61053503          	ld	a0,1552(a0) # 9450 <freep>
    5e48:	c515                	beqz	a0,5e74 <malloc+0x58>
  {
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
    5e4a:	611c                	ld	a5,0(a0)
  {
    if (p->s.size >= nunits)
    5e4c:	4798                	lw	a4,8(a5)
    5e4e:	02977f63          	bgeu	a4,s1,5e8c <malloc+0x70>
    5e52:	8a4e                	mv	s4,s3
    5e54:	0009871b          	sext.w	a4,s3
    5e58:	6685                	lui	a3,0x1
    5e5a:	00d77363          	bgeu	a4,a3,5e60 <malloc+0x44>
    5e5e:	6a05                	lui	s4,0x1
    5e60:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5e64:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
    5e68:	00003917          	auipc	s2,0x3
    5e6c:	5e890913          	addi	s2,s2,1512 # 9450 <freep>
  if (p == (char *)-1)
    5e70:	5afd                	li	s5,-1
    5e72:	a895                	j	5ee6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    5e74:	0000a797          	auipc	a5,0xa
    5e78:	e0478793          	addi	a5,a5,-508 # fc78 <base>
    5e7c:	00003717          	auipc	a4,0x3
    5e80:	5cf73a23          	sd	a5,1492(a4) # 9450 <freep>
    5e84:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5e86:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits)
    5e8a:	b7e1                	j	5e52 <malloc+0x36>
      if (p->s.size == nunits)
    5e8c:	02e48c63          	beq	s1,a4,5ec4 <malloc+0xa8>
        p->s.size -= nunits;
    5e90:	4137073b          	subw	a4,a4,s3
    5e94:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5e96:	02071693          	slli	a3,a4,0x20
    5e9a:	01c6d713          	srli	a4,a3,0x1c
    5e9e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5ea0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5ea4:	00003717          	auipc	a4,0x3
    5ea8:	5aa73623          	sd	a0,1452(a4) # 9450 <freep>
      return (void *)(p + 1);
    5eac:	01078513          	addi	a0,a5,16
      if ((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5eb0:	70e2                	ld	ra,56(sp)
    5eb2:	7442                	ld	s0,48(sp)
    5eb4:	74a2                	ld	s1,40(sp)
    5eb6:	7902                	ld	s2,32(sp)
    5eb8:	69e2                	ld	s3,24(sp)
    5eba:	6a42                	ld	s4,16(sp)
    5ebc:	6aa2                	ld	s5,8(sp)
    5ebe:	6b02                	ld	s6,0(sp)
    5ec0:	6121                	addi	sp,sp,64
    5ec2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5ec4:	6398                	ld	a4,0(a5)
    5ec6:	e118                	sd	a4,0(a0)
    5ec8:	bff1                	j	5ea4 <malloc+0x88>
  hp->s.size = nu;
    5eca:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
    5ece:	0541                	addi	a0,a0,16
    5ed0:	00000097          	auipc	ra,0x0
    5ed4:	eca080e7          	jalr	-310(ra) # 5d9a <free>
  return freep;
    5ed8:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
    5edc:	d971                	beqz	a0,5eb0 <malloc+0x94>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
    5ede:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits)
    5ee0:	4798                	lw	a4,8(a5)
    5ee2:	fa9775e3          	bgeu	a4,s1,5e8c <malloc+0x70>
    if (p == freep)
    5ee6:	00093703          	ld	a4,0(s2)
    5eea:	853e                	mv	a0,a5
    5eec:	fef719e3          	bne	a4,a5,5ede <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    5ef0:	8552                	mv	a0,s4
    5ef2:	00000097          	auipc	ra,0x0
    5ef6:	b68080e7          	jalr	-1176(ra) # 5a5a <sbrk>
  if (p == (char *)-1)
    5efa:	fd5518e3          	bne	a0,s5,5eca <malloc+0xae>
        return 0;
    5efe:	4501                	li	a0,0
    5f00:	bf45                	j	5eb0 <malloc+0x94>
