
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
      14:	b94080e7          	jalr	-1132(ra) # 5ba4 <open>
    if (fd >= 0)
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE | O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	b82080e7          	jalr	-1150(ra) # 5ba4 <open>
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
      42:	06250513          	addi	a0,a0,98 # 60a0 <malloc+0xea>
      46:	00006097          	auipc	ra,0x6
      4a:	eb8080e7          	jalr	-328(ra) # 5efe <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	b14080e7          	jalr	-1260(ra) # 5b64 <exit>

0000000000000058 <bsstest>:
char uninit[10000];
void bsstest(char *s)
{
  int i;

  for (i = 0; i < sizeof(uninit); i++)
      58:	0000a797          	auipc	a5,0xa
      5c:	51078793          	addi	a5,a5,1296 # a568 <uninit>
      60:	0000d697          	auipc	a3,0xd
      64:	c1868693          	addi	a3,a3,-1000 # cc78 <buf>
  {
    if (uninit[i] != '\0')
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for (i = 0; i < sizeof(uninit); i++)
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
    {
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	04050513          	addi	a0,a0,64 # 60c0 <malloc+0x10a>
      88:	00006097          	auipc	ra,0x6
      8c:	e76080e7          	jalr	-394(ra) # 5efe <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00006097          	auipc	ra,0x6
      96:	ad2080e7          	jalr	-1326(ra) # 5b64 <exit>

000000000000009a <textwrite>:
    exit(xstatus);
}

// check that writes to text segment fault
void textwrite(char *s)
{
      9a:	1141                	addi	sp,sp,-16
      9c:	e406                	sd	ra,8(sp)
      9e:	e022                	sd	s0,0(sp)
      a0:	0800                	addi	s0,sp,16
  exit(0);
      a2:	4501                	li	a0,0
      a4:	00006097          	auipc	ra,0x6
      a8:	ac0080e7          	jalr	-1344(ra) # 5b64 <exit>

00000000000000ac <opentest>:
{
      ac:	1101                	addi	sp,sp,-32
      ae:	ec06                	sd	ra,24(sp)
      b0:	e822                	sd	s0,16(sp)
      b2:	e426                	sd	s1,8(sp)
      b4:	1000                	addi	s0,sp,32
      b6:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      b8:	4581                	li	a1,0
      ba:	00006517          	auipc	a0,0x6
      be:	01e50513          	addi	a0,a0,30 # 60d8 <malloc+0x122>
      c2:	00006097          	auipc	ra,0x6
      c6:	ae2080e7          	jalr	-1310(ra) # 5ba4 <open>
  if (fd < 0)
      ca:	02054663          	bltz	a0,f6 <opentest+0x4a>
  close(fd);
      ce:	00006097          	auipc	ra,0x6
      d2:	abe080e7          	jalr	-1346(ra) # 5b8c <close>
  fd = open("doesnotexist", 0);
      d6:	4581                	li	a1,0
      d8:	00006517          	auipc	a0,0x6
      dc:	02050513          	addi	a0,a0,32 # 60f8 <malloc+0x142>
      e0:	00006097          	auipc	ra,0x6
      e4:	ac4080e7          	jalr	-1340(ra) # 5ba4 <open>
  if (fd >= 0)
      e8:	02055563          	bgez	a0,112 <opentest+0x66>
}
      ec:	60e2                	ld	ra,24(sp)
      ee:	6442                	ld	s0,16(sp)
      f0:	64a2                	ld	s1,8(sp)
      f2:	6105                	addi	sp,sp,32
      f4:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f6:	85a6                	mv	a1,s1
      f8:	00006517          	auipc	a0,0x6
      fc:	fe850513          	addi	a0,a0,-24 # 60e0 <malloc+0x12a>
     100:	00006097          	auipc	ra,0x6
     104:	dfe080e7          	jalr	-514(ra) # 5efe <printf>
    exit(1);
     108:	4505                	li	a0,1
     10a:	00006097          	auipc	ra,0x6
     10e:	a5a080e7          	jalr	-1446(ra) # 5b64 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     112:	85a6                	mv	a1,s1
     114:	00006517          	auipc	a0,0x6
     118:	ff450513          	addi	a0,a0,-12 # 6108 <malloc+0x152>
     11c:	00006097          	auipc	ra,0x6
     120:	de2080e7          	jalr	-542(ra) # 5efe <printf>
    exit(1);
     124:	4505                	li	a0,1
     126:	00006097          	auipc	ra,0x6
     12a:	a3e080e7          	jalr	-1474(ra) # 5b64 <exit>

000000000000012e <truncate2>:
{
     12e:	7179                	addi	sp,sp,-48
     130:	f406                	sd	ra,40(sp)
     132:	f022                	sd	s0,32(sp)
     134:	ec26                	sd	s1,24(sp)
     136:	e84a                	sd	s2,16(sp)
     138:	e44e                	sd	s3,8(sp)
     13a:	1800                	addi	s0,sp,48
     13c:	89aa                	mv	s3,a0
  unlink("truncfile");
     13e:	00006517          	auipc	a0,0x6
     142:	ff250513          	addi	a0,a0,-14 # 6130 <malloc+0x17a>
     146:	00006097          	auipc	ra,0x6
     14a:	a6e080e7          	jalr	-1426(ra) # 5bb4 <unlink>
  int fd1 = open("truncfile", O_CREATE | O_TRUNC | O_WRONLY);
     14e:	60100593          	li	a1,1537
     152:	00006517          	auipc	a0,0x6
     156:	fde50513          	addi	a0,a0,-34 # 6130 <malloc+0x17a>
     15a:	00006097          	auipc	ra,0x6
     15e:	a4a080e7          	jalr	-1462(ra) # 5ba4 <open>
     162:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     164:	4611                	li	a2,4
     166:	00006597          	auipc	a1,0x6
     16a:	fda58593          	addi	a1,a1,-38 # 6140 <malloc+0x18a>
     16e:	00006097          	auipc	ra,0x6
     172:	a16080e7          	jalr	-1514(ra) # 5b84 <write>
  int fd2 = open("truncfile", O_TRUNC | O_WRONLY);
     176:	40100593          	li	a1,1025
     17a:	00006517          	auipc	a0,0x6
     17e:	fb650513          	addi	a0,a0,-74 # 6130 <malloc+0x17a>
     182:	00006097          	auipc	ra,0x6
     186:	a22080e7          	jalr	-1502(ra) # 5ba4 <open>
     18a:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     18c:	4605                	li	a2,1
     18e:	00006597          	auipc	a1,0x6
     192:	fba58593          	addi	a1,a1,-70 # 6148 <malloc+0x192>
     196:	8526                	mv	a0,s1
     198:	00006097          	auipc	ra,0x6
     19c:	9ec080e7          	jalr	-1556(ra) # 5b84 <write>
  if (n != -1)
     1a0:	57fd                	li	a5,-1
     1a2:	02f51b63          	bne	a0,a5,1d8 <truncate2+0xaa>
  unlink("truncfile");
     1a6:	00006517          	auipc	a0,0x6
     1aa:	f8a50513          	addi	a0,a0,-118 # 6130 <malloc+0x17a>
     1ae:	00006097          	auipc	ra,0x6
     1b2:	a06080e7          	jalr	-1530(ra) # 5bb4 <unlink>
  close(fd1);
     1b6:	8526                	mv	a0,s1
     1b8:	00006097          	auipc	ra,0x6
     1bc:	9d4080e7          	jalr	-1580(ra) # 5b8c <close>
  close(fd2);
     1c0:	854a                	mv	a0,s2
     1c2:	00006097          	auipc	ra,0x6
     1c6:	9ca080e7          	jalr	-1590(ra) # 5b8c <close>
}
     1ca:	70a2                	ld	ra,40(sp)
     1cc:	7402                	ld	s0,32(sp)
     1ce:	64e2                	ld	s1,24(sp)
     1d0:	6942                	ld	s2,16(sp)
     1d2:	69a2                	ld	s3,8(sp)
     1d4:	6145                	addi	sp,sp,48
     1d6:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1d8:	862a                	mv	a2,a0
     1da:	85ce                	mv	a1,s3
     1dc:	00006517          	auipc	a0,0x6
     1e0:	f7450513          	addi	a0,a0,-140 # 6150 <malloc+0x19a>
     1e4:	00006097          	auipc	ra,0x6
     1e8:	d1a080e7          	jalr	-742(ra) # 5efe <printf>
    exit(1);
     1ec:	4505                	li	a0,1
     1ee:	00006097          	auipc	ra,0x6
     1f2:	976080e7          	jalr	-1674(ra) # 5b64 <exit>

00000000000001f6 <createtest>:
{
     1f6:	7179                	addi	sp,sp,-48
     1f8:	f406                	sd	ra,40(sp)
     1fa:	f022                	sd	s0,32(sp)
     1fc:	ec26                	sd	s1,24(sp)
     1fe:	e84a                	sd	s2,16(sp)
     200:	1800                	addi	s0,sp,48
  name[0] = 'a';
     202:	06100793          	li	a5,97
     206:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     20a:	fc040d23          	sb	zero,-38(s0)
     20e:	03000493          	li	s1,48
  for (i = 0; i < N; i++)
     212:	06400913          	li	s2,100
    name[1] = '0' + i;
     216:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE | O_RDWR);
     21a:	20200593          	li	a1,514
     21e:	fd840513          	addi	a0,s0,-40
     222:	00006097          	auipc	ra,0x6
     226:	982080e7          	jalr	-1662(ra) # 5ba4 <open>
    close(fd);
     22a:	00006097          	auipc	ra,0x6
     22e:	962080e7          	jalr	-1694(ra) # 5b8c <close>
  for (i = 0; i < N; i++)
     232:	2485                	addiw	s1,s1,1
     234:	0ff4f493          	zext.b	s1,s1
     238:	fd249fe3          	bne	s1,s2,216 <createtest+0x20>
  name[0] = 'a';
     23c:	06100793          	li	a5,97
     240:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     244:	fc040d23          	sb	zero,-38(s0)
     248:	03000493          	li	s1,48
  for (i = 0; i < N; i++)
     24c:	06400913          	li	s2,100
    name[1] = '0' + i;
     250:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     254:	fd840513          	addi	a0,s0,-40
     258:	00006097          	auipc	ra,0x6
     25c:	95c080e7          	jalr	-1700(ra) # 5bb4 <unlink>
  for (i = 0; i < N; i++)
     260:	2485                	addiw	s1,s1,1
     262:	0ff4f493          	zext.b	s1,s1
     266:	ff2495e3          	bne	s1,s2,250 <createtest+0x5a>
}
     26a:	70a2                	ld	ra,40(sp)
     26c:	7402                	ld	s0,32(sp)
     26e:	64e2                	ld	s1,24(sp)
     270:	6942                	ld	s2,16(sp)
     272:	6145                	addi	sp,sp,48
     274:	8082                	ret

0000000000000276 <bigwrite>:
{
     276:	715d                	addi	sp,sp,-80
     278:	e486                	sd	ra,72(sp)
     27a:	e0a2                	sd	s0,64(sp)
     27c:	fc26                	sd	s1,56(sp)
     27e:	f84a                	sd	s2,48(sp)
     280:	f44e                	sd	s3,40(sp)
     282:	f052                	sd	s4,32(sp)
     284:	ec56                	sd	s5,24(sp)
     286:	e85a                	sd	s6,16(sp)
     288:	e45e                	sd	s7,8(sp)
     28a:	0880                	addi	s0,sp,80
     28c:	8baa                	mv	s7,a0
  unlink("bigwrite");
     28e:	00006517          	auipc	a0,0x6
     292:	eea50513          	addi	a0,a0,-278 # 6178 <malloc+0x1c2>
     296:	00006097          	auipc	ra,0x6
     29a:	91e080e7          	jalr	-1762(ra) # 5bb4 <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471)
     29e:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a2:	00006a97          	auipc	s5,0x6
     2a6:	ed6a8a93          	addi	s5,s5,-298 # 6178 <malloc+0x1c2>
      int cc = write(fd, buf, sz);
     2aa:	0000da17          	auipc	s4,0xd
     2ae:	9cea0a13          	addi	s4,s4,-1586 # cc78 <buf>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471)
     2b2:	6b0d                	lui	s6,0x3
     2b4:	1c9b0b13          	addi	s6,s6,457 # 31c9 <diskfull+0x63>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2b8:	20200593          	li	a1,514
     2bc:	8556                	mv	a0,s5
     2be:	00006097          	auipc	ra,0x6
     2c2:	8e6080e7          	jalr	-1818(ra) # 5ba4 <open>
     2c6:	892a                	mv	s2,a0
    if (fd < 0)
     2c8:	04054d63          	bltz	a0,322 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	00006097          	auipc	ra,0x6
     2d4:	8b4080e7          	jalr	-1868(ra) # 5b84 <write>
     2d8:	89aa                	mv	s3,a0
      if (cc != sz)
     2da:	06a49263          	bne	s1,a0,33e <bigwrite+0xc8>
      int cc = write(fd, buf, sz);
     2de:	8626                	mv	a2,s1
     2e0:	85d2                	mv	a1,s4
     2e2:	854a                	mv	a0,s2
     2e4:	00006097          	auipc	ra,0x6
     2e8:	8a0080e7          	jalr	-1888(ra) # 5b84 <write>
      if (cc != sz)
     2ec:	04951a63          	bne	a0,s1,340 <bigwrite+0xca>
    close(fd);
     2f0:	854a                	mv	a0,s2
     2f2:	00006097          	auipc	ra,0x6
     2f6:	89a080e7          	jalr	-1894(ra) # 5b8c <close>
    unlink("bigwrite");
     2fa:	8556                	mv	a0,s5
     2fc:	00006097          	auipc	ra,0x6
     300:	8b8080e7          	jalr	-1864(ra) # 5bb4 <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471)
     304:	1d74849b          	addiw	s1,s1,471
     308:	fb6498e3          	bne	s1,s6,2b8 <bigwrite+0x42>
}
     30c:	60a6                	ld	ra,72(sp)
     30e:	6406                	ld	s0,64(sp)
     310:	74e2                	ld	s1,56(sp)
     312:	7942                	ld	s2,48(sp)
     314:	79a2                	ld	s3,40(sp)
     316:	7a02                	ld	s4,32(sp)
     318:	6ae2                	ld	s5,24(sp)
     31a:	6b42                	ld	s6,16(sp)
     31c:	6ba2                	ld	s7,8(sp)
     31e:	6161                	addi	sp,sp,80
     320:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     322:	85de                	mv	a1,s7
     324:	00006517          	auipc	a0,0x6
     328:	e6450513          	addi	a0,a0,-412 # 6188 <malloc+0x1d2>
     32c:	00006097          	auipc	ra,0x6
     330:	bd2080e7          	jalr	-1070(ra) # 5efe <printf>
      exit(1);
     334:	4505                	li	a0,1
     336:	00006097          	auipc	ra,0x6
     33a:	82e080e7          	jalr	-2002(ra) # 5b64 <exit>
      if (cc != sz)
     33e:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     340:	86aa                	mv	a3,a0
     342:	864e                	mv	a2,s3
     344:	85de                	mv	a1,s7
     346:	00006517          	auipc	a0,0x6
     34a:	e6250513          	addi	a0,a0,-414 # 61a8 <malloc+0x1f2>
     34e:	00006097          	auipc	ra,0x6
     352:	bb0080e7          	jalr	-1104(ra) # 5efe <printf>
        exit(1);
     356:	4505                	li	a0,1
     358:	00006097          	auipc	ra,0x6
     35c:	80c080e7          	jalr	-2036(ra) # 5b64 <exit>

0000000000000360 <badwrite>:
// a block to be allocated for a file that is then not freed when the
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void badwrite(char *s)
{
     360:	7179                	addi	sp,sp,-48
     362:	f406                	sd	ra,40(sp)
     364:	f022                	sd	s0,32(sp)
     366:	ec26                	sd	s1,24(sp)
     368:	e84a                	sd	s2,16(sp)
     36a:	e44e                	sd	s3,8(sp)
     36c:	e052                	sd	s4,0(sp)
     36e:	1800                	addi	s0,sp,48
  int assumed_free = 600;

  unlink("junk");
     370:	00006517          	auipc	a0,0x6
     374:	e5050513          	addi	a0,a0,-432 # 61c0 <malloc+0x20a>
     378:	00006097          	auipc	ra,0x6
     37c:	83c080e7          	jalr	-1988(ra) # 5bb4 <unlink>
     380:	25800913          	li	s2,600
  for (int i = 0; i < assumed_free; i++)
  {
    int fd = open("junk", O_CREATE | O_WRONLY);
     384:	00006997          	auipc	s3,0x6
     388:	e3c98993          	addi	s3,s3,-452 # 61c0 <malloc+0x20a>
    if (fd < 0)
    {
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char *)0xffffffffffL, 1);
     38c:	5a7d                	li	s4,-1
     38e:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE | O_WRONLY);
     392:	20100593          	li	a1,513
     396:	854e                	mv	a0,s3
     398:	00006097          	auipc	ra,0x6
     39c:	80c080e7          	jalr	-2036(ra) # 5ba4 <open>
     3a0:	84aa                	mv	s1,a0
    if (fd < 0)
     3a2:	06054b63          	bltz	a0,418 <badwrite+0xb8>
    write(fd, (char *)0xffffffffffL, 1);
     3a6:	4605                	li	a2,1
     3a8:	85d2                	mv	a1,s4
     3aa:	00005097          	auipc	ra,0x5
     3ae:	7da080e7          	jalr	2010(ra) # 5b84 <write>
    close(fd);
     3b2:	8526                	mv	a0,s1
     3b4:	00005097          	auipc	ra,0x5
     3b8:	7d8080e7          	jalr	2008(ra) # 5b8c <close>
    unlink("junk");
     3bc:	854e                	mv	a0,s3
     3be:	00005097          	auipc	ra,0x5
     3c2:	7f6080e7          	jalr	2038(ra) # 5bb4 <unlink>
  for (int i = 0; i < assumed_free; i++)
     3c6:	397d                	addiw	s2,s2,-1
     3c8:	fc0915e3          	bnez	s2,392 <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE | O_WRONLY);
     3cc:	20100593          	li	a1,513
     3d0:	00006517          	auipc	a0,0x6
     3d4:	df050513          	addi	a0,a0,-528 # 61c0 <malloc+0x20a>
     3d8:	00005097          	auipc	ra,0x5
     3dc:	7cc080e7          	jalr	1996(ra) # 5ba4 <open>
     3e0:	84aa                	mv	s1,a0
  if (fd < 0)
     3e2:	04054863          	bltz	a0,432 <badwrite+0xd2>
  {
    printf("open junk failed\n");
    exit(1);
  }
  if (write(fd, "x", 1) != 1)
     3e6:	4605                	li	a2,1
     3e8:	00006597          	auipc	a1,0x6
     3ec:	d6058593          	addi	a1,a1,-672 # 6148 <malloc+0x192>
     3f0:	00005097          	auipc	ra,0x5
     3f4:	794080e7          	jalr	1940(ra) # 5b84 <write>
     3f8:	4785                	li	a5,1
     3fa:	04f50963          	beq	a0,a5,44c <badwrite+0xec>
  {
    printf("write failed\n");
     3fe:	00006517          	auipc	a0,0x6
     402:	de250513          	addi	a0,a0,-542 # 61e0 <malloc+0x22a>
     406:	00006097          	auipc	ra,0x6
     40a:	af8080e7          	jalr	-1288(ra) # 5efe <printf>
    exit(1);
     40e:	4505                	li	a0,1
     410:	00005097          	auipc	ra,0x5
     414:	754080e7          	jalr	1876(ra) # 5b64 <exit>
      printf("open junk failed\n");
     418:	00006517          	auipc	a0,0x6
     41c:	db050513          	addi	a0,a0,-592 # 61c8 <malloc+0x212>
     420:	00006097          	auipc	ra,0x6
     424:	ade080e7          	jalr	-1314(ra) # 5efe <printf>
      exit(1);
     428:	4505                	li	a0,1
     42a:	00005097          	auipc	ra,0x5
     42e:	73a080e7          	jalr	1850(ra) # 5b64 <exit>
    printf("open junk failed\n");
     432:	00006517          	auipc	a0,0x6
     436:	d9650513          	addi	a0,a0,-618 # 61c8 <malloc+0x212>
     43a:	00006097          	auipc	ra,0x6
     43e:	ac4080e7          	jalr	-1340(ra) # 5efe <printf>
    exit(1);
     442:	4505                	li	a0,1
     444:	00005097          	auipc	ra,0x5
     448:	720080e7          	jalr	1824(ra) # 5b64 <exit>
  }
  close(fd);
     44c:	8526                	mv	a0,s1
     44e:	00005097          	auipc	ra,0x5
     452:	73e080e7          	jalr	1854(ra) # 5b8c <close>
  unlink("junk");
     456:	00006517          	auipc	a0,0x6
     45a:	d6a50513          	addi	a0,a0,-662 # 61c0 <malloc+0x20a>
     45e:	00005097          	auipc	ra,0x5
     462:	756080e7          	jalr	1878(ra) # 5bb4 <unlink>

  exit(0);
     466:	4501                	li	a0,0
     468:	00005097          	auipc	ra,0x5
     46c:	6fc080e7          	jalr	1788(ra) # 5b64 <exit>

0000000000000470 <outofinodes>:
    unlink(name);
  }
}

void outofinodes(char *s)
{
     470:	715d                	addi	sp,sp,-80
     472:	e486                	sd	ra,72(sp)
     474:	e0a2                	sd	s0,64(sp)
     476:	fc26                	sd	s1,56(sp)
     478:	f84a                	sd	s2,48(sp)
     47a:	f44e                	sd	s3,40(sp)
     47c:	0880                	addi	s0,sp,80
  int nzz = 32 * 32;
  for (int i = 0; i < nzz; i++)
     47e:	4481                	li	s1,0
  {
    char name[32];
    name[0] = 'z';
     480:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
     484:	40000993          	li	s3,1024
    name[0] = 'z';
     488:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     48c:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     490:	41f4d71b          	sraiw	a4,s1,0x1f
     494:	01b7571b          	srliw	a4,a4,0x1b
     498:	009707bb          	addw	a5,a4,s1
     49c:	4057d69b          	sraiw	a3,a5,0x5
     4a0:	0306869b          	addiw	a3,a3,48
     4a4:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     4a8:	8bfd                	andi	a5,a5,31
     4aa:	9f99                	subw	a5,a5,a4
     4ac:	0307879b          	addiw	a5,a5,48
     4b0:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4b4:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     4b8:	fb040513          	addi	a0,s0,-80
     4bc:	00005097          	auipc	ra,0x5
     4c0:	6f8080e7          	jalr	1784(ra) # 5bb4 <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
     4c4:	60200593          	li	a1,1538
     4c8:	fb040513          	addi	a0,s0,-80
     4cc:	00005097          	auipc	ra,0x5
     4d0:	6d8080e7          	jalr	1752(ra) # 5ba4 <open>
    if (fd < 0)
     4d4:	00054963          	bltz	a0,4e6 <outofinodes+0x76>
    {
      // failure is eventually expected.
      break;
    }
    close(fd);
     4d8:	00005097          	auipc	ra,0x5
     4dc:	6b4080e7          	jalr	1716(ra) # 5b8c <close>
  for (int i = 0; i < nzz; i++)
     4e0:	2485                	addiw	s1,s1,1
     4e2:	fb3493e3          	bne	s1,s3,488 <outofinodes+0x18>
     4e6:	4481                	li	s1,0
  }

  for (int i = 0; i < nzz; i++)
  {
    char name[32];
    name[0] = 'z';
     4e8:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
     4ec:	40000993          	li	s3,1024
    name[0] = 'z';
     4f0:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     4f4:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4f8:	41f4d71b          	sraiw	a4,s1,0x1f
     4fc:	01b7571b          	srliw	a4,a4,0x1b
     500:	009707bb          	addw	a5,a4,s1
     504:	4057d69b          	sraiw	a3,a5,0x5
     508:	0306869b          	addiw	a3,a3,48
     50c:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     510:	8bfd                	andi	a5,a5,31
     512:	9f99                	subw	a5,a5,a4
     514:	0307879b          	addiw	a5,a5,48
     518:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     51c:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     520:	fb040513          	addi	a0,s0,-80
     524:	00005097          	auipc	ra,0x5
     528:	690080e7          	jalr	1680(ra) # 5bb4 <unlink>
  for (int i = 0; i < nzz; i++)
     52c:	2485                	addiw	s1,s1,1
     52e:	fd3491e3          	bne	s1,s3,4f0 <outofinodes+0x80>
  }
}
     532:	60a6                	ld	ra,72(sp)
     534:	6406                	ld	s0,64(sp)
     536:	74e2                	ld	s1,56(sp)
     538:	7942                	ld	s2,48(sp)
     53a:	79a2                	ld	s3,40(sp)
     53c:	6161                	addi	sp,sp,80
     53e:	8082                	ret

0000000000000540 <copyin>:
{
     540:	715d                	addi	sp,sp,-80
     542:	e486                	sd	ra,72(sp)
     544:	e0a2                	sd	s0,64(sp)
     546:	fc26                	sd	s1,56(sp)
     548:	f84a                	sd	s2,48(sp)
     54a:	f44e                	sd	s3,40(sp)
     54c:	f052                	sd	s4,32(sp)
     54e:	0880                	addi	s0,sp,80
  uint64 addrs[] = {0x80000000LL, 0xffffffffffffffff};
     550:	4785                	li	a5,1
     552:	07fe                	slli	a5,a5,0x1f
     554:	fcf43023          	sd	a5,-64(s0)
     558:	57fd                	li	a5,-1
     55a:	fcf43423          	sd	a5,-56(s0)
  for (int ai = 0; ai < 2; ai++)
     55e:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     562:	00006a17          	auipc	s4,0x6
     566:	c8ea0a13          	addi	s4,s4,-882 # 61f0 <malloc+0x23a>
    uint64 addr = addrs[ai];
     56a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     56e:	20100593          	li	a1,513
     572:	8552                	mv	a0,s4
     574:	00005097          	auipc	ra,0x5
     578:	630080e7          	jalr	1584(ra) # 5ba4 <open>
     57c:	84aa                	mv	s1,a0
    if (fd < 0)
     57e:	08054863          	bltz	a0,60e <copyin+0xce>
    int n = write(fd, (void *)addr, 8192);
     582:	6609                	lui	a2,0x2
     584:	85ce                	mv	a1,s3
     586:	00005097          	auipc	ra,0x5
     58a:	5fe080e7          	jalr	1534(ra) # 5b84 <write>
    if (n >= 0)
     58e:	08055d63          	bgez	a0,628 <copyin+0xe8>
    close(fd);
     592:	8526                	mv	a0,s1
     594:	00005097          	auipc	ra,0x5
     598:	5f8080e7          	jalr	1528(ra) # 5b8c <close>
    unlink("copyin1");
     59c:	8552                	mv	a0,s4
     59e:	00005097          	auipc	ra,0x5
     5a2:	616080e7          	jalr	1558(ra) # 5bb4 <unlink>
    n = write(1, (char *)addr, 8192);
     5a6:	6609                	lui	a2,0x2
     5a8:	85ce                	mv	a1,s3
     5aa:	4505                	li	a0,1
     5ac:	00005097          	auipc	ra,0x5
     5b0:	5d8080e7          	jalr	1496(ra) # 5b84 <write>
    if (n > 0)
     5b4:	08a04963          	bgtz	a0,646 <copyin+0x106>
    if (pipe(fds) < 0)
     5b8:	fb840513          	addi	a0,s0,-72
     5bc:	00005097          	auipc	ra,0x5
     5c0:	5b8080e7          	jalr	1464(ra) # 5b74 <pipe>
     5c4:	0a054063          	bltz	a0,664 <copyin+0x124>
    n = write(fds[1], (char *)addr, 8192);
     5c8:	6609                	lui	a2,0x2
     5ca:	85ce                	mv	a1,s3
     5cc:	fbc42503          	lw	a0,-68(s0)
     5d0:	00005097          	auipc	ra,0x5
     5d4:	5b4080e7          	jalr	1460(ra) # 5b84 <write>
    if (n > 0)
     5d8:	0aa04363          	bgtz	a0,67e <copyin+0x13e>
    close(fds[0]);
     5dc:	fb842503          	lw	a0,-72(s0)
     5e0:	00005097          	auipc	ra,0x5
     5e4:	5ac080e7          	jalr	1452(ra) # 5b8c <close>
    close(fds[1]);
     5e8:	fbc42503          	lw	a0,-68(s0)
     5ec:	00005097          	auipc	ra,0x5
     5f0:	5a0080e7          	jalr	1440(ra) # 5b8c <close>
  for (int ai = 0; ai < 2; ai++)
     5f4:	0921                	addi	s2,s2,8
     5f6:	fd040793          	addi	a5,s0,-48
     5fa:	f6f918e3          	bne	s2,a5,56a <copyin+0x2a>
}
     5fe:	60a6                	ld	ra,72(sp)
     600:	6406                	ld	s0,64(sp)
     602:	74e2                	ld	s1,56(sp)
     604:	7942                	ld	s2,48(sp)
     606:	79a2                	ld	s3,40(sp)
     608:	7a02                	ld	s4,32(sp)
     60a:	6161                	addi	sp,sp,80
     60c:	8082                	ret
      printf("open(copyin1) failed\n");
     60e:	00006517          	auipc	a0,0x6
     612:	bea50513          	addi	a0,a0,-1046 # 61f8 <malloc+0x242>
     616:	00006097          	auipc	ra,0x6
     61a:	8e8080e7          	jalr	-1816(ra) # 5efe <printf>
      exit(1);
     61e:	4505                	li	a0,1
     620:	00005097          	auipc	ra,0x5
     624:	544080e7          	jalr	1348(ra) # 5b64 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     628:	862a                	mv	a2,a0
     62a:	85ce                	mv	a1,s3
     62c:	00006517          	auipc	a0,0x6
     630:	be450513          	addi	a0,a0,-1052 # 6210 <malloc+0x25a>
     634:	00006097          	auipc	ra,0x6
     638:	8ca080e7          	jalr	-1846(ra) # 5efe <printf>
      exit(1);
     63c:	4505                	li	a0,1
     63e:	00005097          	auipc	ra,0x5
     642:	526080e7          	jalr	1318(ra) # 5b64 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     646:	862a                	mv	a2,a0
     648:	85ce                	mv	a1,s3
     64a:	00006517          	auipc	a0,0x6
     64e:	bf650513          	addi	a0,a0,-1034 # 6240 <malloc+0x28a>
     652:	00006097          	auipc	ra,0x6
     656:	8ac080e7          	jalr	-1876(ra) # 5efe <printf>
      exit(1);
     65a:	4505                	li	a0,1
     65c:	00005097          	auipc	ra,0x5
     660:	508080e7          	jalr	1288(ra) # 5b64 <exit>
      printf("pipe() failed\n");
     664:	00006517          	auipc	a0,0x6
     668:	c0c50513          	addi	a0,a0,-1012 # 6270 <malloc+0x2ba>
     66c:	00006097          	auipc	ra,0x6
     670:	892080e7          	jalr	-1902(ra) # 5efe <printf>
      exit(1);
     674:	4505                	li	a0,1
     676:	00005097          	auipc	ra,0x5
     67a:	4ee080e7          	jalr	1262(ra) # 5b64 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     67e:	862a                	mv	a2,a0
     680:	85ce                	mv	a1,s3
     682:	00006517          	auipc	a0,0x6
     686:	bfe50513          	addi	a0,a0,-1026 # 6280 <malloc+0x2ca>
     68a:	00006097          	auipc	ra,0x6
     68e:	874080e7          	jalr	-1932(ra) # 5efe <printf>
      exit(1);
     692:	4505                	li	a0,1
     694:	00005097          	auipc	ra,0x5
     698:	4d0080e7          	jalr	1232(ra) # 5b64 <exit>

000000000000069c <copyout>:
{
     69c:	711d                	addi	sp,sp,-96
     69e:	ec86                	sd	ra,88(sp)
     6a0:	e8a2                	sd	s0,80(sp)
     6a2:	e4a6                	sd	s1,72(sp)
     6a4:	e0ca                	sd	s2,64(sp)
     6a6:	fc4e                	sd	s3,56(sp)
     6a8:	f852                	sd	s4,48(sp)
     6aa:	f456                	sd	s5,40(sp)
     6ac:	1080                	addi	s0,sp,96
  uint64 addrs[] = {0x80000000LL, 0xffffffffffffffff};
     6ae:	4785                	li	a5,1
     6b0:	07fe                	slli	a5,a5,0x1f
     6b2:	faf43823          	sd	a5,-80(s0)
     6b6:	57fd                	li	a5,-1
     6b8:	faf43c23          	sd	a5,-72(s0)
  for (int ai = 0; ai < 2; ai++)
     6bc:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     6c0:	00006a17          	auipc	s4,0x6
     6c4:	bf0a0a13          	addi	s4,s4,-1040 # 62b0 <malloc+0x2fa>
    n = write(fds[1], "x", 1);
     6c8:	00006a97          	auipc	s5,0x6
     6cc:	a80a8a93          	addi	s5,s5,-1408 # 6148 <malloc+0x192>
    uint64 addr = addrs[ai];
     6d0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     6d4:	4581                	li	a1,0
     6d6:	8552                	mv	a0,s4
     6d8:	00005097          	auipc	ra,0x5
     6dc:	4cc080e7          	jalr	1228(ra) # 5ba4 <open>
     6e0:	84aa                	mv	s1,a0
    if (fd < 0)
     6e2:	08054663          	bltz	a0,76e <copyout+0xd2>
    int n = read(fd, (void *)addr, 8192);
     6e6:	6609                	lui	a2,0x2
     6e8:	85ce                	mv	a1,s3
     6ea:	00005097          	auipc	ra,0x5
     6ee:	492080e7          	jalr	1170(ra) # 5b7c <read>
    if (n > 0)
     6f2:	08a04b63          	bgtz	a0,788 <copyout+0xec>
    close(fd);
     6f6:	8526                	mv	a0,s1
     6f8:	00005097          	auipc	ra,0x5
     6fc:	494080e7          	jalr	1172(ra) # 5b8c <close>
    if (pipe(fds) < 0)
     700:	fa840513          	addi	a0,s0,-88
     704:	00005097          	auipc	ra,0x5
     708:	470080e7          	jalr	1136(ra) # 5b74 <pipe>
     70c:	08054d63          	bltz	a0,7a6 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     710:	4605                	li	a2,1
     712:	85d6                	mv	a1,s5
     714:	fac42503          	lw	a0,-84(s0)
     718:	00005097          	auipc	ra,0x5
     71c:	46c080e7          	jalr	1132(ra) # 5b84 <write>
    if (n != 1)
     720:	4785                	li	a5,1
     722:	08f51f63          	bne	a0,a5,7c0 <copyout+0x124>
    n = read(fds[0], (void *)addr, 8192);
     726:	6609                	lui	a2,0x2
     728:	85ce                	mv	a1,s3
     72a:	fa842503          	lw	a0,-88(s0)
     72e:	00005097          	auipc	ra,0x5
     732:	44e080e7          	jalr	1102(ra) # 5b7c <read>
    if (n > 0)
     736:	0aa04263          	bgtz	a0,7da <copyout+0x13e>
    close(fds[0]);
     73a:	fa842503          	lw	a0,-88(s0)
     73e:	00005097          	auipc	ra,0x5
     742:	44e080e7          	jalr	1102(ra) # 5b8c <close>
    close(fds[1]);
     746:	fac42503          	lw	a0,-84(s0)
     74a:	00005097          	auipc	ra,0x5
     74e:	442080e7          	jalr	1090(ra) # 5b8c <close>
  for (int ai = 0; ai < 2; ai++)
     752:	0921                	addi	s2,s2,8
     754:	fc040793          	addi	a5,s0,-64
     758:	f6f91ce3          	bne	s2,a5,6d0 <copyout+0x34>
}
     75c:	60e6                	ld	ra,88(sp)
     75e:	6446                	ld	s0,80(sp)
     760:	64a6                	ld	s1,72(sp)
     762:	6906                	ld	s2,64(sp)
     764:	79e2                	ld	s3,56(sp)
     766:	7a42                	ld	s4,48(sp)
     768:	7aa2                	ld	s5,40(sp)
     76a:	6125                	addi	sp,sp,96
     76c:	8082                	ret
      printf("open(README) failed\n");
     76e:	00006517          	auipc	a0,0x6
     772:	b4a50513          	addi	a0,a0,-1206 # 62b8 <malloc+0x302>
     776:	00005097          	auipc	ra,0x5
     77a:	788080e7          	jalr	1928(ra) # 5efe <printf>
      exit(1);
     77e:	4505                	li	a0,1
     780:	00005097          	auipc	ra,0x5
     784:	3e4080e7          	jalr	996(ra) # 5b64 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     788:	862a                	mv	a2,a0
     78a:	85ce                	mv	a1,s3
     78c:	00006517          	auipc	a0,0x6
     790:	b4450513          	addi	a0,a0,-1212 # 62d0 <malloc+0x31a>
     794:	00005097          	auipc	ra,0x5
     798:	76a080e7          	jalr	1898(ra) # 5efe <printf>
      exit(1);
     79c:	4505                	li	a0,1
     79e:	00005097          	auipc	ra,0x5
     7a2:	3c6080e7          	jalr	966(ra) # 5b64 <exit>
      printf("pipe() failed\n");
     7a6:	00006517          	auipc	a0,0x6
     7aa:	aca50513          	addi	a0,a0,-1334 # 6270 <malloc+0x2ba>
     7ae:	00005097          	auipc	ra,0x5
     7b2:	750080e7          	jalr	1872(ra) # 5efe <printf>
      exit(1);
     7b6:	4505                	li	a0,1
     7b8:	00005097          	auipc	ra,0x5
     7bc:	3ac080e7          	jalr	940(ra) # 5b64 <exit>
      printf("pipe write failed\n");
     7c0:	00006517          	auipc	a0,0x6
     7c4:	b4050513          	addi	a0,a0,-1216 # 6300 <malloc+0x34a>
     7c8:	00005097          	auipc	ra,0x5
     7cc:	736080e7          	jalr	1846(ra) # 5efe <printf>
      exit(1);
     7d0:	4505                	li	a0,1
     7d2:	00005097          	auipc	ra,0x5
     7d6:	392080e7          	jalr	914(ra) # 5b64 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     7da:	862a                	mv	a2,a0
     7dc:	85ce                	mv	a1,s3
     7de:	00006517          	auipc	a0,0x6
     7e2:	b3a50513          	addi	a0,a0,-1222 # 6318 <malloc+0x362>
     7e6:	00005097          	auipc	ra,0x5
     7ea:	718080e7          	jalr	1816(ra) # 5efe <printf>
      exit(1);
     7ee:	4505                	li	a0,1
     7f0:	00005097          	auipc	ra,0x5
     7f4:	374080e7          	jalr	884(ra) # 5b64 <exit>

00000000000007f8 <truncate1>:
{
     7f8:	711d                	addi	sp,sp,-96
     7fa:	ec86                	sd	ra,88(sp)
     7fc:	e8a2                	sd	s0,80(sp)
     7fe:	e4a6                	sd	s1,72(sp)
     800:	e0ca                	sd	s2,64(sp)
     802:	fc4e                	sd	s3,56(sp)
     804:	f852                	sd	s4,48(sp)
     806:	f456                	sd	s5,40(sp)
     808:	1080                	addi	s0,sp,96
     80a:	8aaa                	mv	s5,a0
  unlink("truncfile");
     80c:	00006517          	auipc	a0,0x6
     810:	92450513          	addi	a0,a0,-1756 # 6130 <malloc+0x17a>
     814:	00005097          	auipc	ra,0x5
     818:	3a0080e7          	jalr	928(ra) # 5bb4 <unlink>
  int fd1 = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
     81c:	60100593          	li	a1,1537
     820:	00006517          	auipc	a0,0x6
     824:	91050513          	addi	a0,a0,-1776 # 6130 <malloc+0x17a>
     828:	00005097          	auipc	ra,0x5
     82c:	37c080e7          	jalr	892(ra) # 5ba4 <open>
     830:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     832:	4611                	li	a2,4
     834:	00006597          	auipc	a1,0x6
     838:	90c58593          	addi	a1,a1,-1780 # 6140 <malloc+0x18a>
     83c:	00005097          	auipc	ra,0x5
     840:	348080e7          	jalr	840(ra) # 5b84 <write>
  close(fd1);
     844:	8526                	mv	a0,s1
     846:	00005097          	auipc	ra,0x5
     84a:	346080e7          	jalr	838(ra) # 5b8c <close>
  int fd2 = open("truncfile", O_RDONLY);
     84e:	4581                	li	a1,0
     850:	00006517          	auipc	a0,0x6
     854:	8e050513          	addi	a0,a0,-1824 # 6130 <malloc+0x17a>
     858:	00005097          	auipc	ra,0x5
     85c:	34c080e7          	jalr	844(ra) # 5ba4 <open>
     860:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     862:	02000613          	li	a2,32
     866:	fa040593          	addi	a1,s0,-96
     86a:	00005097          	auipc	ra,0x5
     86e:	312080e7          	jalr	786(ra) # 5b7c <read>
  if (n != 4)
     872:	4791                	li	a5,4
     874:	0cf51e63          	bne	a0,a5,950 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY | O_TRUNC);
     878:	40100593          	li	a1,1025
     87c:	00006517          	auipc	a0,0x6
     880:	8b450513          	addi	a0,a0,-1868 # 6130 <malloc+0x17a>
     884:	00005097          	auipc	ra,0x5
     888:	320080e7          	jalr	800(ra) # 5ba4 <open>
     88c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     88e:	4581                	li	a1,0
     890:	00006517          	auipc	a0,0x6
     894:	8a050513          	addi	a0,a0,-1888 # 6130 <malloc+0x17a>
     898:	00005097          	auipc	ra,0x5
     89c:	30c080e7          	jalr	780(ra) # 5ba4 <open>
     8a0:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     8a2:	02000613          	li	a2,32
     8a6:	fa040593          	addi	a1,s0,-96
     8aa:	00005097          	auipc	ra,0x5
     8ae:	2d2080e7          	jalr	722(ra) # 5b7c <read>
     8b2:	8a2a                	mv	s4,a0
  if (n != 0)
     8b4:	ed4d                	bnez	a0,96e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8b6:	02000613          	li	a2,32
     8ba:	fa040593          	addi	a1,s0,-96
     8be:	8526                	mv	a0,s1
     8c0:	00005097          	auipc	ra,0x5
     8c4:	2bc080e7          	jalr	700(ra) # 5b7c <read>
     8c8:	8a2a                	mv	s4,a0
  if (n != 0)
     8ca:	e971                	bnez	a0,99e <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     8cc:	4619                	li	a2,6
     8ce:	00006597          	auipc	a1,0x6
     8d2:	ada58593          	addi	a1,a1,-1318 # 63a8 <malloc+0x3f2>
     8d6:	854e                	mv	a0,s3
     8d8:	00005097          	auipc	ra,0x5
     8dc:	2ac080e7          	jalr	684(ra) # 5b84 <write>
  n = read(fd3, buf, sizeof(buf));
     8e0:	02000613          	li	a2,32
     8e4:	fa040593          	addi	a1,s0,-96
     8e8:	854a                	mv	a0,s2
     8ea:	00005097          	auipc	ra,0x5
     8ee:	292080e7          	jalr	658(ra) # 5b7c <read>
  if (n != 6)
     8f2:	4799                	li	a5,6
     8f4:	0cf51d63          	bne	a0,a5,9ce <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     8f8:	02000613          	li	a2,32
     8fc:	fa040593          	addi	a1,s0,-96
     900:	8526                	mv	a0,s1
     902:	00005097          	auipc	ra,0x5
     906:	27a080e7          	jalr	634(ra) # 5b7c <read>
  if (n != 2)
     90a:	4789                	li	a5,2
     90c:	0ef51063          	bne	a0,a5,9ec <truncate1+0x1f4>
  unlink("truncfile");
     910:	00006517          	auipc	a0,0x6
     914:	82050513          	addi	a0,a0,-2016 # 6130 <malloc+0x17a>
     918:	00005097          	auipc	ra,0x5
     91c:	29c080e7          	jalr	668(ra) # 5bb4 <unlink>
  close(fd1);
     920:	854e                	mv	a0,s3
     922:	00005097          	auipc	ra,0x5
     926:	26a080e7          	jalr	618(ra) # 5b8c <close>
  close(fd2);
     92a:	8526                	mv	a0,s1
     92c:	00005097          	auipc	ra,0x5
     930:	260080e7          	jalr	608(ra) # 5b8c <close>
  close(fd3);
     934:	854a                	mv	a0,s2
     936:	00005097          	auipc	ra,0x5
     93a:	256080e7          	jalr	598(ra) # 5b8c <close>
}
     93e:	60e6                	ld	ra,88(sp)
     940:	6446                	ld	s0,80(sp)
     942:	64a6                	ld	s1,72(sp)
     944:	6906                	ld	s2,64(sp)
     946:	79e2                	ld	s3,56(sp)
     948:	7a42                	ld	s4,48(sp)
     94a:	7aa2                	ld	s5,40(sp)
     94c:	6125                	addi	sp,sp,96
     94e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     950:	862a                	mv	a2,a0
     952:	85d6                	mv	a1,s5
     954:	00006517          	auipc	a0,0x6
     958:	9f450513          	addi	a0,a0,-1548 # 6348 <malloc+0x392>
     95c:	00005097          	auipc	ra,0x5
     960:	5a2080e7          	jalr	1442(ra) # 5efe <printf>
    exit(1);
     964:	4505                	li	a0,1
     966:	00005097          	auipc	ra,0x5
     96a:	1fe080e7          	jalr	510(ra) # 5b64 <exit>
    printf("aaa fd3=%d\n", fd3);
     96e:	85ca                	mv	a1,s2
     970:	00006517          	auipc	a0,0x6
     974:	9f850513          	addi	a0,a0,-1544 # 6368 <malloc+0x3b2>
     978:	00005097          	auipc	ra,0x5
     97c:	586080e7          	jalr	1414(ra) # 5efe <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     980:	8652                	mv	a2,s4
     982:	85d6                	mv	a1,s5
     984:	00006517          	auipc	a0,0x6
     988:	9f450513          	addi	a0,a0,-1548 # 6378 <malloc+0x3c2>
     98c:	00005097          	auipc	ra,0x5
     990:	572080e7          	jalr	1394(ra) # 5efe <printf>
    exit(1);
     994:	4505                	li	a0,1
     996:	00005097          	auipc	ra,0x5
     99a:	1ce080e7          	jalr	462(ra) # 5b64 <exit>
    printf("bbb fd2=%d\n", fd2);
     99e:	85a6                	mv	a1,s1
     9a0:	00006517          	auipc	a0,0x6
     9a4:	9f850513          	addi	a0,a0,-1544 # 6398 <malloc+0x3e2>
     9a8:	00005097          	auipc	ra,0x5
     9ac:	556080e7          	jalr	1366(ra) # 5efe <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9b0:	8652                	mv	a2,s4
     9b2:	85d6                	mv	a1,s5
     9b4:	00006517          	auipc	a0,0x6
     9b8:	9c450513          	addi	a0,a0,-1596 # 6378 <malloc+0x3c2>
     9bc:	00005097          	auipc	ra,0x5
     9c0:	542080e7          	jalr	1346(ra) # 5efe <printf>
    exit(1);
     9c4:	4505                	li	a0,1
     9c6:	00005097          	auipc	ra,0x5
     9ca:	19e080e7          	jalr	414(ra) # 5b64 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     9ce:	862a                	mv	a2,a0
     9d0:	85d6                	mv	a1,s5
     9d2:	00006517          	auipc	a0,0x6
     9d6:	9de50513          	addi	a0,a0,-1570 # 63b0 <malloc+0x3fa>
     9da:	00005097          	auipc	ra,0x5
     9de:	524080e7          	jalr	1316(ra) # 5efe <printf>
    exit(1);
     9e2:	4505                	li	a0,1
     9e4:	00005097          	auipc	ra,0x5
     9e8:	180080e7          	jalr	384(ra) # 5b64 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     9ec:	862a                	mv	a2,a0
     9ee:	85d6                	mv	a1,s5
     9f0:	00006517          	auipc	a0,0x6
     9f4:	9e050513          	addi	a0,a0,-1568 # 63d0 <malloc+0x41a>
     9f8:	00005097          	auipc	ra,0x5
     9fc:	506080e7          	jalr	1286(ra) # 5efe <printf>
    exit(1);
     a00:	4505                	li	a0,1
     a02:	00005097          	auipc	ra,0x5
     a06:	162080e7          	jalr	354(ra) # 5b64 <exit>

0000000000000a0a <writetest>:
{
     a0a:	7139                	addi	sp,sp,-64
     a0c:	fc06                	sd	ra,56(sp)
     a0e:	f822                	sd	s0,48(sp)
     a10:	f426                	sd	s1,40(sp)
     a12:	f04a                	sd	s2,32(sp)
     a14:	ec4e                	sd	s3,24(sp)
     a16:	e852                	sd	s4,16(sp)
     a18:	e456                	sd	s5,8(sp)
     a1a:	e05a                	sd	s6,0(sp)
     a1c:	0080                	addi	s0,sp,64
     a1e:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE | O_RDWR);
     a20:	20200593          	li	a1,514
     a24:	00006517          	auipc	a0,0x6
     a28:	9cc50513          	addi	a0,a0,-1588 # 63f0 <malloc+0x43a>
     a2c:	00005097          	auipc	ra,0x5
     a30:	178080e7          	jalr	376(ra) # 5ba4 <open>
  if (fd < 0)
     a34:	0a054d63          	bltz	a0,aee <writetest+0xe4>
     a38:	892a                	mv	s2,a0
     a3a:	4481                	li	s1,0
    if (write(fd, "aaaaaaaaaa", SZ) != SZ)
     a3c:	00006997          	auipc	s3,0x6
     a40:	9dc98993          	addi	s3,s3,-1572 # 6418 <malloc+0x462>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ)
     a44:	00006a97          	auipc	s5,0x6
     a48:	a0ca8a93          	addi	s5,s5,-1524 # 6450 <malloc+0x49a>
  for (i = 0; i < N; i++)
     a4c:	06400a13          	li	s4,100
    if (write(fd, "aaaaaaaaaa", SZ) != SZ)
     a50:	4629                	li	a2,10
     a52:	85ce                	mv	a1,s3
     a54:	854a                	mv	a0,s2
     a56:	00005097          	auipc	ra,0x5
     a5a:	12e080e7          	jalr	302(ra) # 5b84 <write>
     a5e:	47a9                	li	a5,10
     a60:	0af51563          	bne	a0,a5,b0a <writetest+0x100>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ)
     a64:	4629                	li	a2,10
     a66:	85d6                	mv	a1,s5
     a68:	854a                	mv	a0,s2
     a6a:	00005097          	auipc	ra,0x5
     a6e:	11a080e7          	jalr	282(ra) # 5b84 <write>
     a72:	47a9                	li	a5,10
     a74:	0af51a63          	bne	a0,a5,b28 <writetest+0x11e>
  for (i = 0; i < N; i++)
     a78:	2485                	addiw	s1,s1,1
     a7a:	fd449be3          	bne	s1,s4,a50 <writetest+0x46>
  close(fd);
     a7e:	854a                	mv	a0,s2
     a80:	00005097          	auipc	ra,0x5
     a84:	10c080e7          	jalr	268(ra) # 5b8c <close>
  fd = open("small", O_RDONLY);
     a88:	4581                	li	a1,0
     a8a:	00006517          	auipc	a0,0x6
     a8e:	96650513          	addi	a0,a0,-1690 # 63f0 <malloc+0x43a>
     a92:	00005097          	auipc	ra,0x5
     a96:	112080e7          	jalr	274(ra) # 5ba4 <open>
     a9a:	84aa                	mv	s1,a0
  if (fd < 0)
     a9c:	0a054563          	bltz	a0,b46 <writetest+0x13c>
  i = read(fd, buf, N * SZ * 2);
     aa0:	7d000613          	li	a2,2000
     aa4:	0000c597          	auipc	a1,0xc
     aa8:	1d458593          	addi	a1,a1,468 # cc78 <buf>
     aac:	00005097          	auipc	ra,0x5
     ab0:	0d0080e7          	jalr	208(ra) # 5b7c <read>
  if (i != N * SZ * 2)
     ab4:	7d000793          	li	a5,2000
     ab8:	0af51563          	bne	a0,a5,b62 <writetest+0x158>
  close(fd);
     abc:	8526                	mv	a0,s1
     abe:	00005097          	auipc	ra,0x5
     ac2:	0ce080e7          	jalr	206(ra) # 5b8c <close>
  if (unlink("small") < 0)
     ac6:	00006517          	auipc	a0,0x6
     aca:	92a50513          	addi	a0,a0,-1750 # 63f0 <malloc+0x43a>
     ace:	00005097          	auipc	ra,0x5
     ad2:	0e6080e7          	jalr	230(ra) # 5bb4 <unlink>
     ad6:	0a054463          	bltz	a0,b7e <writetest+0x174>
}
     ada:	70e2                	ld	ra,56(sp)
     adc:	7442                	ld	s0,48(sp)
     ade:	74a2                	ld	s1,40(sp)
     ae0:	7902                	ld	s2,32(sp)
     ae2:	69e2                	ld	s3,24(sp)
     ae4:	6a42                	ld	s4,16(sp)
     ae6:	6aa2                	ld	s5,8(sp)
     ae8:	6b02                	ld	s6,0(sp)
     aea:	6121                	addi	sp,sp,64
     aec:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     aee:	85da                	mv	a1,s6
     af0:	00006517          	auipc	a0,0x6
     af4:	90850513          	addi	a0,a0,-1784 # 63f8 <malloc+0x442>
     af8:	00005097          	auipc	ra,0x5
     afc:	406080e7          	jalr	1030(ra) # 5efe <printf>
    exit(1);
     b00:	4505                	li	a0,1
     b02:	00005097          	auipc	ra,0x5
     b06:	062080e7          	jalr	98(ra) # 5b64 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     b0a:	8626                	mv	a2,s1
     b0c:	85da                	mv	a1,s6
     b0e:	00006517          	auipc	a0,0x6
     b12:	91a50513          	addi	a0,a0,-1766 # 6428 <malloc+0x472>
     b16:	00005097          	auipc	ra,0x5
     b1a:	3e8080e7          	jalr	1000(ra) # 5efe <printf>
      exit(1);
     b1e:	4505                	li	a0,1
     b20:	00005097          	auipc	ra,0x5
     b24:	044080e7          	jalr	68(ra) # 5b64 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     b28:	8626                	mv	a2,s1
     b2a:	85da                	mv	a1,s6
     b2c:	00006517          	auipc	a0,0x6
     b30:	93450513          	addi	a0,a0,-1740 # 6460 <malloc+0x4aa>
     b34:	00005097          	auipc	ra,0x5
     b38:	3ca080e7          	jalr	970(ra) # 5efe <printf>
      exit(1);
     b3c:	4505                	li	a0,1
     b3e:	00005097          	auipc	ra,0x5
     b42:	026080e7          	jalr	38(ra) # 5b64 <exit>
    printf("%s: error: open small failed!\n", s);
     b46:	85da                	mv	a1,s6
     b48:	00006517          	auipc	a0,0x6
     b4c:	94050513          	addi	a0,a0,-1728 # 6488 <malloc+0x4d2>
     b50:	00005097          	auipc	ra,0x5
     b54:	3ae080e7          	jalr	942(ra) # 5efe <printf>
    exit(1);
     b58:	4505                	li	a0,1
     b5a:	00005097          	auipc	ra,0x5
     b5e:	00a080e7          	jalr	10(ra) # 5b64 <exit>
    printf("%s: read failed\n", s);
     b62:	85da                	mv	a1,s6
     b64:	00006517          	auipc	a0,0x6
     b68:	94450513          	addi	a0,a0,-1724 # 64a8 <malloc+0x4f2>
     b6c:	00005097          	auipc	ra,0x5
     b70:	392080e7          	jalr	914(ra) # 5efe <printf>
    exit(1);
     b74:	4505                	li	a0,1
     b76:	00005097          	auipc	ra,0x5
     b7a:	fee080e7          	jalr	-18(ra) # 5b64 <exit>
    printf("%s: unlink small failed\n", s);
     b7e:	85da                	mv	a1,s6
     b80:	00006517          	auipc	a0,0x6
     b84:	94050513          	addi	a0,a0,-1728 # 64c0 <malloc+0x50a>
     b88:	00005097          	auipc	ra,0x5
     b8c:	376080e7          	jalr	886(ra) # 5efe <printf>
    exit(1);
     b90:	4505                	li	a0,1
     b92:	00005097          	auipc	ra,0x5
     b96:	fd2080e7          	jalr	-46(ra) # 5b64 <exit>

0000000000000b9a <writebig>:
{
     b9a:	7139                	addi	sp,sp,-64
     b9c:	fc06                	sd	ra,56(sp)
     b9e:	f822                	sd	s0,48(sp)
     ba0:	f426                	sd	s1,40(sp)
     ba2:	f04a                	sd	s2,32(sp)
     ba4:	ec4e                	sd	s3,24(sp)
     ba6:	e852                	sd	s4,16(sp)
     ba8:	e456                	sd	s5,8(sp)
     baa:	0080                	addi	s0,sp,64
     bac:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE | O_RDWR);
     bae:	20200593          	li	a1,514
     bb2:	00006517          	auipc	a0,0x6
     bb6:	92e50513          	addi	a0,a0,-1746 # 64e0 <malloc+0x52a>
     bba:	00005097          	auipc	ra,0x5
     bbe:	fea080e7          	jalr	-22(ra) # 5ba4 <open>
     bc2:	89aa                	mv	s3,a0
  for (i = 0; i < MAXFILE; i++)
     bc4:	4481                	li	s1,0
    ((int *)buf)[0] = i;
     bc6:	0000c917          	auipc	s2,0xc
     bca:	0b290913          	addi	s2,s2,178 # cc78 <buf>
  for (i = 0; i < MAXFILE; i++)
     bce:	10c00a13          	li	s4,268
  if (fd < 0)
     bd2:	06054c63          	bltz	a0,c4a <writebig+0xb0>
    ((int *)buf)[0] = i;
     bd6:	00992023          	sw	s1,0(s2)
    if (write(fd, buf, BSIZE) != BSIZE)
     bda:	40000613          	li	a2,1024
     bde:	85ca                	mv	a1,s2
     be0:	854e                	mv	a0,s3
     be2:	00005097          	auipc	ra,0x5
     be6:	fa2080e7          	jalr	-94(ra) # 5b84 <write>
     bea:	40000793          	li	a5,1024
     bee:	06f51c63          	bne	a0,a5,c66 <writebig+0xcc>
  for (i = 0; i < MAXFILE; i++)
     bf2:	2485                	addiw	s1,s1,1
     bf4:	ff4491e3          	bne	s1,s4,bd6 <writebig+0x3c>
  close(fd);
     bf8:	854e                	mv	a0,s3
     bfa:	00005097          	auipc	ra,0x5
     bfe:	f92080e7          	jalr	-110(ra) # 5b8c <close>
  fd = open("big", O_RDONLY);
     c02:	4581                	li	a1,0
     c04:	00006517          	auipc	a0,0x6
     c08:	8dc50513          	addi	a0,a0,-1828 # 64e0 <malloc+0x52a>
     c0c:	00005097          	auipc	ra,0x5
     c10:	f98080e7          	jalr	-104(ra) # 5ba4 <open>
     c14:	89aa                	mv	s3,a0
  n = 0;
     c16:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c18:	0000c917          	auipc	s2,0xc
     c1c:	06090913          	addi	s2,s2,96 # cc78 <buf>
  if (fd < 0)
     c20:	06054263          	bltz	a0,c84 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     c24:	40000613          	li	a2,1024
     c28:	85ca                	mv	a1,s2
     c2a:	854e                	mv	a0,s3
     c2c:	00005097          	auipc	ra,0x5
     c30:	f50080e7          	jalr	-176(ra) # 5b7c <read>
    if (i == 0)
     c34:	c535                	beqz	a0,ca0 <writebig+0x106>
    else if (i != BSIZE)
     c36:	40000793          	li	a5,1024
     c3a:	0af51f63          	bne	a0,a5,cf8 <writebig+0x15e>
    if (((int *)buf)[0] != n)
     c3e:	00092683          	lw	a3,0(s2)
     c42:	0c969a63          	bne	a3,s1,d16 <writebig+0x17c>
    n++;
     c46:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c48:	bff1                	j	c24 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     c4a:	85d6                	mv	a1,s5
     c4c:	00006517          	auipc	a0,0x6
     c50:	89c50513          	addi	a0,a0,-1892 # 64e8 <malloc+0x532>
     c54:	00005097          	auipc	ra,0x5
     c58:	2aa080e7          	jalr	682(ra) # 5efe <printf>
    exit(1);
     c5c:	4505                	li	a0,1
     c5e:	00005097          	auipc	ra,0x5
     c62:	f06080e7          	jalr	-250(ra) # 5b64 <exit>
      printf("%s: error: write big file failed\n", s, i);
     c66:	8626                	mv	a2,s1
     c68:	85d6                	mv	a1,s5
     c6a:	00006517          	auipc	a0,0x6
     c6e:	89e50513          	addi	a0,a0,-1890 # 6508 <malloc+0x552>
     c72:	00005097          	auipc	ra,0x5
     c76:	28c080e7          	jalr	652(ra) # 5efe <printf>
      exit(1);
     c7a:	4505                	li	a0,1
     c7c:	00005097          	auipc	ra,0x5
     c80:	ee8080e7          	jalr	-280(ra) # 5b64 <exit>
    printf("%s: error: open big failed!\n", s);
     c84:	85d6                	mv	a1,s5
     c86:	00006517          	auipc	a0,0x6
     c8a:	8aa50513          	addi	a0,a0,-1878 # 6530 <malloc+0x57a>
     c8e:	00005097          	auipc	ra,0x5
     c92:	270080e7          	jalr	624(ra) # 5efe <printf>
    exit(1);
     c96:	4505                	li	a0,1
     c98:	00005097          	auipc	ra,0x5
     c9c:	ecc080e7          	jalr	-308(ra) # 5b64 <exit>
      if (n == MAXFILE - 1)
     ca0:	10b00793          	li	a5,267
     ca4:	02f48a63          	beq	s1,a5,cd8 <writebig+0x13e>
  close(fd);
     ca8:	854e                	mv	a0,s3
     caa:	00005097          	auipc	ra,0x5
     cae:	ee2080e7          	jalr	-286(ra) # 5b8c <close>
  if (unlink("big") < 0)
     cb2:	00006517          	auipc	a0,0x6
     cb6:	82e50513          	addi	a0,a0,-2002 # 64e0 <malloc+0x52a>
     cba:	00005097          	auipc	ra,0x5
     cbe:	efa080e7          	jalr	-262(ra) # 5bb4 <unlink>
     cc2:	06054963          	bltz	a0,d34 <writebig+0x19a>
}
     cc6:	70e2                	ld	ra,56(sp)
     cc8:	7442                	ld	s0,48(sp)
     cca:	74a2                	ld	s1,40(sp)
     ccc:	7902                	ld	s2,32(sp)
     cce:	69e2                	ld	s3,24(sp)
     cd0:	6a42                	ld	s4,16(sp)
     cd2:	6aa2                	ld	s5,8(sp)
     cd4:	6121                	addi	sp,sp,64
     cd6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     cd8:	10b00613          	li	a2,267
     cdc:	85d6                	mv	a1,s5
     cde:	00006517          	auipc	a0,0x6
     ce2:	87250513          	addi	a0,a0,-1934 # 6550 <malloc+0x59a>
     ce6:	00005097          	auipc	ra,0x5
     cea:	218080e7          	jalr	536(ra) # 5efe <printf>
        exit(1);
     cee:	4505                	li	a0,1
     cf0:	00005097          	auipc	ra,0x5
     cf4:	e74080e7          	jalr	-396(ra) # 5b64 <exit>
      printf("%s: read failed %d\n", s, i);
     cf8:	862a                	mv	a2,a0
     cfa:	85d6                	mv	a1,s5
     cfc:	00006517          	auipc	a0,0x6
     d00:	87c50513          	addi	a0,a0,-1924 # 6578 <malloc+0x5c2>
     d04:	00005097          	auipc	ra,0x5
     d08:	1fa080e7          	jalr	506(ra) # 5efe <printf>
      exit(1);
     d0c:	4505                	li	a0,1
     d0e:	00005097          	auipc	ra,0x5
     d12:	e56080e7          	jalr	-426(ra) # 5b64 <exit>
      printf("%s: read content of block %d is %d\n", s,
     d16:	8626                	mv	a2,s1
     d18:	85d6                	mv	a1,s5
     d1a:	00006517          	auipc	a0,0x6
     d1e:	87650513          	addi	a0,a0,-1930 # 6590 <malloc+0x5da>
     d22:	00005097          	auipc	ra,0x5
     d26:	1dc080e7          	jalr	476(ra) # 5efe <printf>
      exit(1);
     d2a:	4505                	li	a0,1
     d2c:	00005097          	auipc	ra,0x5
     d30:	e38080e7          	jalr	-456(ra) # 5b64 <exit>
    printf("%s: unlink big failed\n", s);
     d34:	85d6                	mv	a1,s5
     d36:	00006517          	auipc	a0,0x6
     d3a:	88250513          	addi	a0,a0,-1918 # 65b8 <malloc+0x602>
     d3e:	00005097          	auipc	ra,0x5
     d42:	1c0080e7          	jalr	448(ra) # 5efe <printf>
    exit(1);
     d46:	4505                	li	a0,1
     d48:	00005097          	auipc	ra,0x5
     d4c:	e1c080e7          	jalr	-484(ra) # 5b64 <exit>

0000000000000d50 <unlinkread>:
{
     d50:	7179                	addi	sp,sp,-48
     d52:	f406                	sd	ra,40(sp)
     d54:	f022                	sd	s0,32(sp)
     d56:	ec26                	sd	s1,24(sp)
     d58:	e84a                	sd	s2,16(sp)
     d5a:	e44e                	sd	s3,8(sp)
     d5c:	1800                	addi	s0,sp,48
     d5e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     d60:	20200593          	li	a1,514
     d64:	00006517          	auipc	a0,0x6
     d68:	86c50513          	addi	a0,a0,-1940 # 65d0 <malloc+0x61a>
     d6c:	00005097          	auipc	ra,0x5
     d70:	e38080e7          	jalr	-456(ra) # 5ba4 <open>
  if (fd < 0)
     d74:	0e054563          	bltz	a0,e5e <unlinkread+0x10e>
     d78:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     d7a:	4615                	li	a2,5
     d7c:	00006597          	auipc	a1,0x6
     d80:	88458593          	addi	a1,a1,-1916 # 6600 <malloc+0x64a>
     d84:	00005097          	auipc	ra,0x5
     d88:	e00080e7          	jalr	-512(ra) # 5b84 <write>
  close(fd);
     d8c:	8526                	mv	a0,s1
     d8e:	00005097          	auipc	ra,0x5
     d92:	dfe080e7          	jalr	-514(ra) # 5b8c <close>
  fd = open("unlinkread", O_RDWR);
     d96:	4589                	li	a1,2
     d98:	00006517          	auipc	a0,0x6
     d9c:	83850513          	addi	a0,a0,-1992 # 65d0 <malloc+0x61a>
     da0:	00005097          	auipc	ra,0x5
     da4:	e04080e7          	jalr	-508(ra) # 5ba4 <open>
     da8:	84aa                	mv	s1,a0
  if (fd < 0)
     daa:	0c054863          	bltz	a0,e7a <unlinkread+0x12a>
  if (unlink("unlinkread") != 0)
     dae:	00006517          	auipc	a0,0x6
     db2:	82250513          	addi	a0,a0,-2014 # 65d0 <malloc+0x61a>
     db6:	00005097          	auipc	ra,0x5
     dba:	dfe080e7          	jalr	-514(ra) # 5bb4 <unlink>
     dbe:	ed61                	bnez	a0,e96 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     dc0:	20200593          	li	a1,514
     dc4:	00006517          	auipc	a0,0x6
     dc8:	80c50513          	addi	a0,a0,-2036 # 65d0 <malloc+0x61a>
     dcc:	00005097          	auipc	ra,0x5
     dd0:	dd8080e7          	jalr	-552(ra) # 5ba4 <open>
     dd4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     dd6:	460d                	li	a2,3
     dd8:	00006597          	auipc	a1,0x6
     ddc:	87058593          	addi	a1,a1,-1936 # 6648 <malloc+0x692>
     de0:	00005097          	auipc	ra,0x5
     de4:	da4080e7          	jalr	-604(ra) # 5b84 <write>
  close(fd1);
     de8:	854a                	mv	a0,s2
     dea:	00005097          	auipc	ra,0x5
     dee:	da2080e7          	jalr	-606(ra) # 5b8c <close>
  if (read(fd, buf, sizeof(buf)) != SZ)
     df2:	660d                	lui	a2,0x3
     df4:	0000c597          	auipc	a1,0xc
     df8:	e8458593          	addi	a1,a1,-380 # cc78 <buf>
     dfc:	8526                	mv	a0,s1
     dfe:	00005097          	auipc	ra,0x5
     e02:	d7e080e7          	jalr	-642(ra) # 5b7c <read>
     e06:	4795                	li	a5,5
     e08:	0af51563          	bne	a0,a5,eb2 <unlinkread+0x162>
  if (buf[0] != 'h')
     e0c:	0000c717          	auipc	a4,0xc
     e10:	e6c74703          	lbu	a4,-404(a4) # cc78 <buf>
     e14:	06800793          	li	a5,104
     e18:	0af71b63          	bne	a4,a5,ece <unlinkread+0x17e>
  if (write(fd, buf, 10) != 10)
     e1c:	4629                	li	a2,10
     e1e:	0000c597          	auipc	a1,0xc
     e22:	e5a58593          	addi	a1,a1,-422 # cc78 <buf>
     e26:	8526                	mv	a0,s1
     e28:	00005097          	auipc	ra,0x5
     e2c:	d5c080e7          	jalr	-676(ra) # 5b84 <write>
     e30:	47a9                	li	a5,10
     e32:	0af51c63          	bne	a0,a5,eea <unlinkread+0x19a>
  close(fd);
     e36:	8526                	mv	a0,s1
     e38:	00005097          	auipc	ra,0x5
     e3c:	d54080e7          	jalr	-684(ra) # 5b8c <close>
  unlink("unlinkread");
     e40:	00005517          	auipc	a0,0x5
     e44:	79050513          	addi	a0,a0,1936 # 65d0 <malloc+0x61a>
     e48:	00005097          	auipc	ra,0x5
     e4c:	d6c080e7          	jalr	-660(ra) # 5bb4 <unlink>
}
     e50:	70a2                	ld	ra,40(sp)
     e52:	7402                	ld	s0,32(sp)
     e54:	64e2                	ld	s1,24(sp)
     e56:	6942                	ld	s2,16(sp)
     e58:	69a2                	ld	s3,8(sp)
     e5a:	6145                	addi	sp,sp,48
     e5c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     e5e:	85ce                	mv	a1,s3
     e60:	00005517          	auipc	a0,0x5
     e64:	78050513          	addi	a0,a0,1920 # 65e0 <malloc+0x62a>
     e68:	00005097          	auipc	ra,0x5
     e6c:	096080e7          	jalr	150(ra) # 5efe <printf>
    exit(1);
     e70:	4505                	li	a0,1
     e72:	00005097          	auipc	ra,0x5
     e76:	cf2080e7          	jalr	-782(ra) # 5b64 <exit>
    printf("%s: open unlinkread failed\n", s);
     e7a:	85ce                	mv	a1,s3
     e7c:	00005517          	auipc	a0,0x5
     e80:	78c50513          	addi	a0,a0,1932 # 6608 <malloc+0x652>
     e84:	00005097          	auipc	ra,0x5
     e88:	07a080e7          	jalr	122(ra) # 5efe <printf>
    exit(1);
     e8c:	4505                	li	a0,1
     e8e:	00005097          	auipc	ra,0x5
     e92:	cd6080e7          	jalr	-810(ra) # 5b64 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     e96:	85ce                	mv	a1,s3
     e98:	00005517          	auipc	a0,0x5
     e9c:	79050513          	addi	a0,a0,1936 # 6628 <malloc+0x672>
     ea0:	00005097          	auipc	ra,0x5
     ea4:	05e080e7          	jalr	94(ra) # 5efe <printf>
    exit(1);
     ea8:	4505                	li	a0,1
     eaa:	00005097          	auipc	ra,0x5
     eae:	cba080e7          	jalr	-838(ra) # 5b64 <exit>
    printf("%s: unlinkread read failed", s);
     eb2:	85ce                	mv	a1,s3
     eb4:	00005517          	auipc	a0,0x5
     eb8:	79c50513          	addi	a0,a0,1948 # 6650 <malloc+0x69a>
     ebc:	00005097          	auipc	ra,0x5
     ec0:	042080e7          	jalr	66(ra) # 5efe <printf>
    exit(1);
     ec4:	4505                	li	a0,1
     ec6:	00005097          	auipc	ra,0x5
     eca:	c9e080e7          	jalr	-866(ra) # 5b64 <exit>
    printf("%s: unlinkread wrong data\n", s);
     ece:	85ce                	mv	a1,s3
     ed0:	00005517          	auipc	a0,0x5
     ed4:	7a050513          	addi	a0,a0,1952 # 6670 <malloc+0x6ba>
     ed8:	00005097          	auipc	ra,0x5
     edc:	026080e7          	jalr	38(ra) # 5efe <printf>
    exit(1);
     ee0:	4505                	li	a0,1
     ee2:	00005097          	auipc	ra,0x5
     ee6:	c82080e7          	jalr	-894(ra) # 5b64 <exit>
    printf("%s: unlinkread write failed\n", s);
     eea:	85ce                	mv	a1,s3
     eec:	00005517          	auipc	a0,0x5
     ef0:	7a450513          	addi	a0,a0,1956 # 6690 <malloc+0x6da>
     ef4:	00005097          	auipc	ra,0x5
     ef8:	00a080e7          	jalr	10(ra) # 5efe <printf>
    exit(1);
     efc:	4505                	li	a0,1
     efe:	00005097          	auipc	ra,0x5
     f02:	c66080e7          	jalr	-922(ra) # 5b64 <exit>

0000000000000f06 <linktest>:
{
     f06:	1101                	addi	sp,sp,-32
     f08:	ec06                	sd	ra,24(sp)
     f0a:	e822                	sd	s0,16(sp)
     f0c:	e426                	sd	s1,8(sp)
     f0e:	e04a                	sd	s2,0(sp)
     f10:	1000                	addi	s0,sp,32
     f12:	892a                	mv	s2,a0
  unlink("lf1");
     f14:	00005517          	auipc	a0,0x5
     f18:	79c50513          	addi	a0,a0,1948 # 66b0 <malloc+0x6fa>
     f1c:	00005097          	auipc	ra,0x5
     f20:	c98080e7          	jalr	-872(ra) # 5bb4 <unlink>
  unlink("lf2");
     f24:	00005517          	auipc	a0,0x5
     f28:	79450513          	addi	a0,a0,1940 # 66b8 <malloc+0x702>
     f2c:	00005097          	auipc	ra,0x5
     f30:	c88080e7          	jalr	-888(ra) # 5bb4 <unlink>
  fd = open("lf1", O_CREATE | O_RDWR);
     f34:	20200593          	li	a1,514
     f38:	00005517          	auipc	a0,0x5
     f3c:	77850513          	addi	a0,a0,1912 # 66b0 <malloc+0x6fa>
     f40:	00005097          	auipc	ra,0x5
     f44:	c64080e7          	jalr	-924(ra) # 5ba4 <open>
  if (fd < 0)
     f48:	10054763          	bltz	a0,1056 <linktest+0x150>
     f4c:	84aa                	mv	s1,a0
  if (write(fd, "hello", SZ) != SZ)
     f4e:	4615                	li	a2,5
     f50:	00005597          	auipc	a1,0x5
     f54:	6b058593          	addi	a1,a1,1712 # 6600 <malloc+0x64a>
     f58:	00005097          	auipc	ra,0x5
     f5c:	c2c080e7          	jalr	-980(ra) # 5b84 <write>
     f60:	4795                	li	a5,5
     f62:	10f51863          	bne	a0,a5,1072 <linktest+0x16c>
  close(fd);
     f66:	8526                	mv	a0,s1
     f68:	00005097          	auipc	ra,0x5
     f6c:	c24080e7          	jalr	-988(ra) # 5b8c <close>
  if (link("lf1", "lf2") < 0)
     f70:	00005597          	auipc	a1,0x5
     f74:	74858593          	addi	a1,a1,1864 # 66b8 <malloc+0x702>
     f78:	00005517          	auipc	a0,0x5
     f7c:	73850513          	addi	a0,a0,1848 # 66b0 <malloc+0x6fa>
     f80:	00005097          	auipc	ra,0x5
     f84:	c44080e7          	jalr	-956(ra) # 5bc4 <link>
     f88:	10054363          	bltz	a0,108e <linktest+0x188>
  unlink("lf1");
     f8c:	00005517          	auipc	a0,0x5
     f90:	72450513          	addi	a0,a0,1828 # 66b0 <malloc+0x6fa>
     f94:	00005097          	auipc	ra,0x5
     f98:	c20080e7          	jalr	-992(ra) # 5bb4 <unlink>
  if (open("lf1", 0) >= 0)
     f9c:	4581                	li	a1,0
     f9e:	00005517          	auipc	a0,0x5
     fa2:	71250513          	addi	a0,a0,1810 # 66b0 <malloc+0x6fa>
     fa6:	00005097          	auipc	ra,0x5
     faa:	bfe080e7          	jalr	-1026(ra) # 5ba4 <open>
     fae:	0e055e63          	bgez	a0,10aa <linktest+0x1a4>
  fd = open("lf2", 0);
     fb2:	4581                	li	a1,0
     fb4:	00005517          	auipc	a0,0x5
     fb8:	70450513          	addi	a0,a0,1796 # 66b8 <malloc+0x702>
     fbc:	00005097          	auipc	ra,0x5
     fc0:	be8080e7          	jalr	-1048(ra) # 5ba4 <open>
     fc4:	84aa                	mv	s1,a0
  if (fd < 0)
     fc6:	10054063          	bltz	a0,10c6 <linktest+0x1c0>
  if (read(fd, buf, sizeof(buf)) != SZ)
     fca:	660d                	lui	a2,0x3
     fcc:	0000c597          	auipc	a1,0xc
     fd0:	cac58593          	addi	a1,a1,-852 # cc78 <buf>
     fd4:	00005097          	auipc	ra,0x5
     fd8:	ba8080e7          	jalr	-1112(ra) # 5b7c <read>
     fdc:	4795                	li	a5,5
     fde:	10f51263          	bne	a0,a5,10e2 <linktest+0x1dc>
  close(fd);
     fe2:	8526                	mv	a0,s1
     fe4:	00005097          	auipc	ra,0x5
     fe8:	ba8080e7          	jalr	-1112(ra) # 5b8c <close>
  if (link("lf2", "lf2") >= 0)
     fec:	00005597          	auipc	a1,0x5
     ff0:	6cc58593          	addi	a1,a1,1740 # 66b8 <malloc+0x702>
     ff4:	852e                	mv	a0,a1
     ff6:	00005097          	auipc	ra,0x5
     ffa:	bce080e7          	jalr	-1074(ra) # 5bc4 <link>
     ffe:	10055063          	bgez	a0,10fe <linktest+0x1f8>
  unlink("lf2");
    1002:	00005517          	auipc	a0,0x5
    1006:	6b650513          	addi	a0,a0,1718 # 66b8 <malloc+0x702>
    100a:	00005097          	auipc	ra,0x5
    100e:	baa080e7          	jalr	-1110(ra) # 5bb4 <unlink>
  if (link("lf2", "lf1") >= 0)
    1012:	00005597          	auipc	a1,0x5
    1016:	69e58593          	addi	a1,a1,1694 # 66b0 <malloc+0x6fa>
    101a:	00005517          	auipc	a0,0x5
    101e:	69e50513          	addi	a0,a0,1694 # 66b8 <malloc+0x702>
    1022:	00005097          	auipc	ra,0x5
    1026:	ba2080e7          	jalr	-1118(ra) # 5bc4 <link>
    102a:	0e055863          	bgez	a0,111a <linktest+0x214>
  if (link(".", "lf1") >= 0)
    102e:	00005597          	auipc	a1,0x5
    1032:	68258593          	addi	a1,a1,1666 # 66b0 <malloc+0x6fa>
    1036:	00005517          	auipc	a0,0x5
    103a:	78a50513          	addi	a0,a0,1930 # 67c0 <malloc+0x80a>
    103e:	00005097          	auipc	ra,0x5
    1042:	b86080e7          	jalr	-1146(ra) # 5bc4 <link>
    1046:	0e055863          	bgez	a0,1136 <linktest+0x230>
}
    104a:	60e2                	ld	ra,24(sp)
    104c:	6442                	ld	s0,16(sp)
    104e:	64a2                	ld	s1,8(sp)
    1050:	6902                	ld	s2,0(sp)
    1052:	6105                	addi	sp,sp,32
    1054:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    1056:	85ca                	mv	a1,s2
    1058:	00005517          	auipc	a0,0x5
    105c:	66850513          	addi	a0,a0,1640 # 66c0 <malloc+0x70a>
    1060:	00005097          	auipc	ra,0x5
    1064:	e9e080e7          	jalr	-354(ra) # 5efe <printf>
    exit(1);
    1068:	4505                	li	a0,1
    106a:	00005097          	auipc	ra,0x5
    106e:	afa080e7          	jalr	-1286(ra) # 5b64 <exit>
    printf("%s: write lf1 failed\n", s);
    1072:	85ca                	mv	a1,s2
    1074:	00005517          	auipc	a0,0x5
    1078:	66450513          	addi	a0,a0,1636 # 66d8 <malloc+0x722>
    107c:	00005097          	auipc	ra,0x5
    1080:	e82080e7          	jalr	-382(ra) # 5efe <printf>
    exit(1);
    1084:	4505                	li	a0,1
    1086:	00005097          	auipc	ra,0x5
    108a:	ade080e7          	jalr	-1314(ra) # 5b64 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    108e:	85ca                	mv	a1,s2
    1090:	00005517          	auipc	a0,0x5
    1094:	66050513          	addi	a0,a0,1632 # 66f0 <malloc+0x73a>
    1098:	00005097          	auipc	ra,0x5
    109c:	e66080e7          	jalr	-410(ra) # 5efe <printf>
    exit(1);
    10a0:	4505                	li	a0,1
    10a2:	00005097          	auipc	ra,0x5
    10a6:	ac2080e7          	jalr	-1342(ra) # 5b64 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    10aa:	85ca                	mv	a1,s2
    10ac:	00005517          	auipc	a0,0x5
    10b0:	66450513          	addi	a0,a0,1636 # 6710 <malloc+0x75a>
    10b4:	00005097          	auipc	ra,0x5
    10b8:	e4a080e7          	jalr	-438(ra) # 5efe <printf>
    exit(1);
    10bc:	4505                	li	a0,1
    10be:	00005097          	auipc	ra,0x5
    10c2:	aa6080e7          	jalr	-1370(ra) # 5b64 <exit>
    printf("%s: open lf2 failed\n", s);
    10c6:	85ca                	mv	a1,s2
    10c8:	00005517          	auipc	a0,0x5
    10cc:	67850513          	addi	a0,a0,1656 # 6740 <malloc+0x78a>
    10d0:	00005097          	auipc	ra,0x5
    10d4:	e2e080e7          	jalr	-466(ra) # 5efe <printf>
    exit(1);
    10d8:	4505                	li	a0,1
    10da:	00005097          	auipc	ra,0x5
    10de:	a8a080e7          	jalr	-1398(ra) # 5b64 <exit>
    printf("%s: read lf2 failed\n", s);
    10e2:	85ca                	mv	a1,s2
    10e4:	00005517          	auipc	a0,0x5
    10e8:	67450513          	addi	a0,a0,1652 # 6758 <malloc+0x7a2>
    10ec:	00005097          	auipc	ra,0x5
    10f0:	e12080e7          	jalr	-494(ra) # 5efe <printf>
    exit(1);
    10f4:	4505                	li	a0,1
    10f6:	00005097          	auipc	ra,0x5
    10fa:	a6e080e7          	jalr	-1426(ra) # 5b64 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    10fe:	85ca                	mv	a1,s2
    1100:	00005517          	auipc	a0,0x5
    1104:	67050513          	addi	a0,a0,1648 # 6770 <malloc+0x7ba>
    1108:	00005097          	auipc	ra,0x5
    110c:	df6080e7          	jalr	-522(ra) # 5efe <printf>
    exit(1);
    1110:	4505                	li	a0,1
    1112:	00005097          	auipc	ra,0x5
    1116:	a52080e7          	jalr	-1454(ra) # 5b64 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    111a:	85ca                	mv	a1,s2
    111c:	00005517          	auipc	a0,0x5
    1120:	67c50513          	addi	a0,a0,1660 # 6798 <malloc+0x7e2>
    1124:	00005097          	auipc	ra,0x5
    1128:	dda080e7          	jalr	-550(ra) # 5efe <printf>
    exit(1);
    112c:	4505                	li	a0,1
    112e:	00005097          	auipc	ra,0x5
    1132:	a36080e7          	jalr	-1482(ra) # 5b64 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    1136:	85ca                	mv	a1,s2
    1138:	00005517          	auipc	a0,0x5
    113c:	69050513          	addi	a0,a0,1680 # 67c8 <malloc+0x812>
    1140:	00005097          	auipc	ra,0x5
    1144:	dbe080e7          	jalr	-578(ra) # 5efe <printf>
    exit(1);
    1148:	4505                	li	a0,1
    114a:	00005097          	auipc	ra,0x5
    114e:	a1a080e7          	jalr	-1510(ra) # 5b64 <exit>

0000000000001152 <validatetest>:
{
    1152:	7139                	addi	sp,sp,-64
    1154:	fc06                	sd	ra,56(sp)
    1156:	f822                	sd	s0,48(sp)
    1158:	f426                	sd	s1,40(sp)
    115a:	f04a                	sd	s2,32(sp)
    115c:	ec4e                	sd	s3,24(sp)
    115e:	e852                	sd	s4,16(sp)
    1160:	e456                	sd	s5,8(sp)
    1162:	e05a                	sd	s6,0(sp)
    1164:	0080                	addi	s0,sp,64
    1166:	8b2a                	mv	s6,a0
  for (p = 0; p <= (uint)hi; p += PGSIZE)
    1168:	4481                	li	s1,0
    if (link("nosuchfile", (char *)p) != -1)
    116a:	00005997          	auipc	s3,0x5
    116e:	67e98993          	addi	s3,s3,1662 # 67e8 <malloc+0x832>
    1172:	597d                	li	s2,-1
  for (p = 0; p <= (uint)hi; p += PGSIZE)
    1174:	6a85                	lui	s5,0x1
    1176:	00114a37          	lui	s4,0x114
    if (link("nosuchfile", (char *)p) != -1)
    117a:	85a6                	mv	a1,s1
    117c:	854e                	mv	a0,s3
    117e:	00005097          	auipc	ra,0x5
    1182:	a46080e7          	jalr	-1466(ra) # 5bc4 <link>
    1186:	01251f63          	bne	a0,s2,11a4 <validatetest+0x52>
  for (p = 0; p <= (uint)hi; p += PGSIZE)
    118a:	94d6                	add	s1,s1,s5
    118c:	ff4497e3          	bne	s1,s4,117a <validatetest+0x28>
}
    1190:	70e2                	ld	ra,56(sp)
    1192:	7442                	ld	s0,48(sp)
    1194:	74a2                	ld	s1,40(sp)
    1196:	7902                	ld	s2,32(sp)
    1198:	69e2                	ld	s3,24(sp)
    119a:	6a42                	ld	s4,16(sp)
    119c:	6aa2                	ld	s5,8(sp)
    119e:	6b02                	ld	s6,0(sp)
    11a0:	6121                	addi	sp,sp,64
    11a2:	8082                	ret
      printf("%s: link should not succeed\n", s);
    11a4:	85da                	mv	a1,s6
    11a6:	00005517          	auipc	a0,0x5
    11aa:	65250513          	addi	a0,a0,1618 # 67f8 <malloc+0x842>
    11ae:	00005097          	auipc	ra,0x5
    11b2:	d50080e7          	jalr	-688(ra) # 5efe <printf>
      exit(1);
    11b6:	4505                	li	a0,1
    11b8:	00005097          	auipc	ra,0x5
    11bc:	9ac080e7          	jalr	-1620(ra) # 5b64 <exit>

00000000000011c0 <bigdir>:
{
    11c0:	715d                	addi	sp,sp,-80
    11c2:	e486                	sd	ra,72(sp)
    11c4:	e0a2                	sd	s0,64(sp)
    11c6:	fc26                	sd	s1,56(sp)
    11c8:	f84a                	sd	s2,48(sp)
    11ca:	f44e                	sd	s3,40(sp)
    11cc:	f052                	sd	s4,32(sp)
    11ce:	ec56                	sd	s5,24(sp)
    11d0:	e85a                	sd	s6,16(sp)
    11d2:	0880                	addi	s0,sp,80
    11d4:	89aa                	mv	s3,a0
  unlink("bd");
    11d6:	00005517          	auipc	a0,0x5
    11da:	64250513          	addi	a0,a0,1602 # 6818 <malloc+0x862>
    11de:	00005097          	auipc	ra,0x5
    11e2:	9d6080e7          	jalr	-1578(ra) # 5bb4 <unlink>
  fd = open("bd", O_CREATE);
    11e6:	20000593          	li	a1,512
    11ea:	00005517          	auipc	a0,0x5
    11ee:	62e50513          	addi	a0,a0,1582 # 6818 <malloc+0x862>
    11f2:	00005097          	auipc	ra,0x5
    11f6:	9b2080e7          	jalr	-1614(ra) # 5ba4 <open>
  if (fd < 0)
    11fa:	0c054963          	bltz	a0,12cc <bigdir+0x10c>
  close(fd);
    11fe:	00005097          	auipc	ra,0x5
    1202:	98e080e7          	jalr	-1650(ra) # 5b8c <close>
  for (i = 0; i < N; i++)
    1206:	4901                	li	s2,0
    name[0] = 'x';
    1208:	07800a93          	li	s5,120
    if (link("bd", name) != 0)
    120c:	00005a17          	auipc	s4,0x5
    1210:	60ca0a13          	addi	s4,s4,1548 # 6818 <malloc+0x862>
  for (i = 0; i < N; i++)
    1214:	1f400b13          	li	s6,500
    name[0] = 'x';
    1218:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    121c:	41f9571b          	sraiw	a4,s2,0x1f
    1220:	01a7571b          	srliw	a4,a4,0x1a
    1224:	012707bb          	addw	a5,a4,s2
    1228:	4067d69b          	sraiw	a3,a5,0x6
    122c:	0306869b          	addiw	a3,a3,48
    1230:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1234:	03f7f793          	andi	a5,a5,63
    1238:	9f99                	subw	a5,a5,a4
    123a:	0307879b          	addiw	a5,a5,48
    123e:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1242:	fa0409a3          	sb	zero,-77(s0)
    if (link("bd", name) != 0)
    1246:	fb040593          	addi	a1,s0,-80
    124a:	8552                	mv	a0,s4
    124c:	00005097          	auipc	ra,0x5
    1250:	978080e7          	jalr	-1672(ra) # 5bc4 <link>
    1254:	84aa                	mv	s1,a0
    1256:	e949                	bnez	a0,12e8 <bigdir+0x128>
  for (i = 0; i < N; i++)
    1258:	2905                	addiw	s2,s2,1
    125a:	fb691fe3          	bne	s2,s6,1218 <bigdir+0x58>
  unlink("bd");
    125e:	00005517          	auipc	a0,0x5
    1262:	5ba50513          	addi	a0,a0,1466 # 6818 <malloc+0x862>
    1266:	00005097          	auipc	ra,0x5
    126a:	94e080e7          	jalr	-1714(ra) # 5bb4 <unlink>
    name[0] = 'x';
    126e:	07800913          	li	s2,120
  for (i = 0; i < N; i++)
    1272:	1f400a13          	li	s4,500
    name[0] = 'x';
    1276:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    127a:	41f4d71b          	sraiw	a4,s1,0x1f
    127e:	01a7571b          	srliw	a4,a4,0x1a
    1282:	009707bb          	addw	a5,a4,s1
    1286:	4067d69b          	sraiw	a3,a5,0x6
    128a:	0306869b          	addiw	a3,a3,48
    128e:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1292:	03f7f793          	andi	a5,a5,63
    1296:	9f99                	subw	a5,a5,a4
    1298:	0307879b          	addiw	a5,a5,48
    129c:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    12a0:	fa0409a3          	sb	zero,-77(s0)
    if (unlink(name) != 0)
    12a4:	fb040513          	addi	a0,s0,-80
    12a8:	00005097          	auipc	ra,0x5
    12ac:	90c080e7          	jalr	-1780(ra) # 5bb4 <unlink>
    12b0:	ed21                	bnez	a0,1308 <bigdir+0x148>
  for (i = 0; i < N; i++)
    12b2:	2485                	addiw	s1,s1,1
    12b4:	fd4491e3          	bne	s1,s4,1276 <bigdir+0xb6>
}
    12b8:	60a6                	ld	ra,72(sp)
    12ba:	6406                	ld	s0,64(sp)
    12bc:	74e2                	ld	s1,56(sp)
    12be:	7942                	ld	s2,48(sp)
    12c0:	79a2                	ld	s3,40(sp)
    12c2:	7a02                	ld	s4,32(sp)
    12c4:	6ae2                	ld	s5,24(sp)
    12c6:	6b42                	ld	s6,16(sp)
    12c8:	6161                	addi	sp,sp,80
    12ca:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    12cc:	85ce                	mv	a1,s3
    12ce:	00005517          	auipc	a0,0x5
    12d2:	55250513          	addi	a0,a0,1362 # 6820 <malloc+0x86a>
    12d6:	00005097          	auipc	ra,0x5
    12da:	c28080e7          	jalr	-984(ra) # 5efe <printf>
    exit(1);
    12de:	4505                	li	a0,1
    12e0:	00005097          	auipc	ra,0x5
    12e4:	884080e7          	jalr	-1916(ra) # 5b64 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    12e8:	fb040613          	addi	a2,s0,-80
    12ec:	85ce                	mv	a1,s3
    12ee:	00005517          	auipc	a0,0x5
    12f2:	55250513          	addi	a0,a0,1362 # 6840 <malloc+0x88a>
    12f6:	00005097          	auipc	ra,0x5
    12fa:	c08080e7          	jalr	-1016(ra) # 5efe <printf>
      exit(1);
    12fe:	4505                	li	a0,1
    1300:	00005097          	auipc	ra,0x5
    1304:	864080e7          	jalr	-1948(ra) # 5b64 <exit>
      printf("%s: bigdir unlink failed", s);
    1308:	85ce                	mv	a1,s3
    130a:	00005517          	auipc	a0,0x5
    130e:	55650513          	addi	a0,a0,1366 # 6860 <malloc+0x8aa>
    1312:	00005097          	auipc	ra,0x5
    1316:	bec080e7          	jalr	-1044(ra) # 5efe <printf>
      exit(1);
    131a:	4505                	li	a0,1
    131c:	00005097          	auipc	ra,0x5
    1320:	848080e7          	jalr	-1976(ra) # 5b64 <exit>

0000000000001324 <pgbug>:
{
    1324:	7179                	addi	sp,sp,-48
    1326:	f406                	sd	ra,40(sp)
    1328:	f022                	sd	s0,32(sp)
    132a:	ec26                	sd	s1,24(sp)
    132c:	1800                	addi	s0,sp,48
  argv[0] = 0;
    132e:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1332:	00008497          	auipc	s1,0x8
    1336:	cce48493          	addi	s1,s1,-818 # 9000 <big>
    133a:	fd840593          	addi	a1,s0,-40
    133e:	6088                	ld	a0,0(s1)
    1340:	00005097          	auipc	ra,0x5
    1344:	85c080e7          	jalr	-1956(ra) # 5b9c <exec>
  pipe(big);
    1348:	6088                	ld	a0,0(s1)
    134a:	00005097          	auipc	ra,0x5
    134e:	82a080e7          	jalr	-2006(ra) # 5b74 <pipe>
  exit(0);
    1352:	4501                	li	a0,0
    1354:	00005097          	auipc	ra,0x5
    1358:	810080e7          	jalr	-2032(ra) # 5b64 <exit>

000000000000135c <badarg>:
{
    135c:	7139                	addi	sp,sp,-64
    135e:	fc06                	sd	ra,56(sp)
    1360:	f822                	sd	s0,48(sp)
    1362:	f426                	sd	s1,40(sp)
    1364:	f04a                	sd	s2,32(sp)
    1366:	ec4e                	sd	s3,24(sp)
    1368:	0080                	addi	s0,sp,64
    136a:	64b1                	lui	s1,0xc
    136c:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1de8>
    argv[0] = (char *)0xffffffff;
    1370:	597d                	li	s2,-1
    1372:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    1376:	00005997          	auipc	s3,0x5
    137a:	d6298993          	addi	s3,s3,-670 # 60d8 <malloc+0x122>
    argv[0] = (char *)0xffffffff;
    137e:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1382:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1386:	fc040593          	addi	a1,s0,-64
    138a:	854e                	mv	a0,s3
    138c:	00005097          	auipc	ra,0x5
    1390:	810080e7          	jalr	-2032(ra) # 5b9c <exec>
  for (int i = 0; i < 50000; i++)
    1394:	34fd                	addiw	s1,s1,-1
    1396:	f4e5                	bnez	s1,137e <badarg+0x22>
  exit(0);
    1398:	4501                	li	a0,0
    139a:	00004097          	auipc	ra,0x4
    139e:	7ca080e7          	jalr	1994(ra) # 5b64 <exit>

00000000000013a2 <copyinstr2>:
{
    13a2:	7155                	addi	sp,sp,-208
    13a4:	e586                	sd	ra,200(sp)
    13a6:	e1a2                	sd	s0,192(sp)
    13a8:	0980                	addi	s0,sp,208
  for (int i = 0; i < MAXPATH; i++)
    13aa:	f6840793          	addi	a5,s0,-152
    13ae:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    13b2:	07800713          	li	a4,120
    13b6:	00e78023          	sb	a4,0(a5)
  for (int i = 0; i < MAXPATH; i++)
    13ba:	0785                	addi	a5,a5,1
    13bc:	fed79de3          	bne	a5,a3,13b6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    13c0:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    13c4:	f6840513          	addi	a0,s0,-152
    13c8:	00004097          	auipc	ra,0x4
    13cc:	7ec080e7          	jalr	2028(ra) # 5bb4 <unlink>
  if (ret != -1)
    13d0:	57fd                	li	a5,-1
    13d2:	0ef51063          	bne	a0,a5,14b2 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    13d6:	20100593          	li	a1,513
    13da:	f6840513          	addi	a0,s0,-152
    13de:	00004097          	auipc	ra,0x4
    13e2:	7c6080e7          	jalr	1990(ra) # 5ba4 <open>
  if (fd != -1)
    13e6:	57fd                	li	a5,-1
    13e8:	0ef51563          	bne	a0,a5,14d2 <copyinstr2+0x130>
  ret = link(b, b);
    13ec:	f6840593          	addi	a1,s0,-152
    13f0:	852e                	mv	a0,a1
    13f2:	00004097          	auipc	ra,0x4
    13f6:	7d2080e7          	jalr	2002(ra) # 5bc4 <link>
  if (ret != -1)
    13fa:	57fd                	li	a5,-1
    13fc:	0ef51b63          	bne	a0,a5,14f2 <copyinstr2+0x150>
  char *args[] = {"xx", 0};
    1400:	00006797          	auipc	a5,0x6
    1404:	6b878793          	addi	a5,a5,1720 # 7ab8 <malloc+0x1b02>
    1408:	f4f43c23          	sd	a5,-168(s0)
    140c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1410:	f5840593          	addi	a1,s0,-168
    1414:	f6840513          	addi	a0,s0,-152
    1418:	00004097          	auipc	ra,0x4
    141c:	784080e7          	jalr	1924(ra) # 5b9c <exec>
  if (ret != -1)
    1420:	57fd                	li	a5,-1
    1422:	0ef51963          	bne	a0,a5,1514 <copyinstr2+0x172>
  int pid = fork();
    1426:	00004097          	auipc	ra,0x4
    142a:	736080e7          	jalr	1846(ra) # 5b5c <fork>
  if (pid < 0)
    142e:	10054363          	bltz	a0,1534 <copyinstr2+0x192>
  if (pid == 0)
    1432:	12051463          	bnez	a0,155a <copyinstr2+0x1b8>
    1436:	00008797          	auipc	a5,0x8
    143a:	12a78793          	addi	a5,a5,298 # 9560 <big.0>
    143e:	00009697          	auipc	a3,0x9
    1442:	12268693          	addi	a3,a3,290 # a560 <big.0+0x1000>
      big[i] = 'x';
    1446:	07800713          	li	a4,120
    144a:	00e78023          	sb	a4,0(a5)
    for (int i = 0; i < PGSIZE; i++)
    144e:	0785                	addi	a5,a5,1
    1450:	fed79de3          	bne	a5,a3,144a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1454:	00009797          	auipc	a5,0x9
    1458:	10078623          	sb	zero,268(a5) # a560 <big.0+0x1000>
    char *args2[] = {big, big, big, 0};
    145c:	00007797          	auipc	a5,0x7
    1460:	09c78793          	addi	a5,a5,156 # 84f8 <malloc+0x2542>
    1464:	6390                	ld	a2,0(a5)
    1466:	6794                	ld	a3,8(a5)
    1468:	6b98                	ld	a4,16(a5)
    146a:	6f9c                	ld	a5,24(a5)
    146c:	f2c43823          	sd	a2,-208(s0)
    1470:	f2d43c23          	sd	a3,-200(s0)
    1474:	f4e43023          	sd	a4,-192(s0)
    1478:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    147c:	f3040593          	addi	a1,s0,-208
    1480:	00005517          	auipc	a0,0x5
    1484:	c5850513          	addi	a0,a0,-936 # 60d8 <malloc+0x122>
    1488:	00004097          	auipc	ra,0x4
    148c:	714080e7          	jalr	1812(ra) # 5b9c <exec>
    if (ret != -1)
    1490:	57fd                	li	a5,-1
    1492:	0af50e63          	beq	a0,a5,154e <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1496:	55fd                	li	a1,-1
    1498:	00005517          	auipc	a0,0x5
    149c:	47050513          	addi	a0,a0,1136 # 6908 <malloc+0x952>
    14a0:	00005097          	auipc	ra,0x5
    14a4:	a5e080e7          	jalr	-1442(ra) # 5efe <printf>
      exit(1);
    14a8:	4505                	li	a0,1
    14aa:	00004097          	auipc	ra,0x4
    14ae:	6ba080e7          	jalr	1722(ra) # 5b64 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    14b2:	862a                	mv	a2,a0
    14b4:	f6840593          	addi	a1,s0,-152
    14b8:	00005517          	auipc	a0,0x5
    14bc:	3c850513          	addi	a0,a0,968 # 6880 <malloc+0x8ca>
    14c0:	00005097          	auipc	ra,0x5
    14c4:	a3e080e7          	jalr	-1474(ra) # 5efe <printf>
    exit(1);
    14c8:	4505                	li	a0,1
    14ca:	00004097          	auipc	ra,0x4
    14ce:	69a080e7          	jalr	1690(ra) # 5b64 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    14d2:	862a                	mv	a2,a0
    14d4:	f6840593          	addi	a1,s0,-152
    14d8:	00005517          	auipc	a0,0x5
    14dc:	3c850513          	addi	a0,a0,968 # 68a0 <malloc+0x8ea>
    14e0:	00005097          	auipc	ra,0x5
    14e4:	a1e080e7          	jalr	-1506(ra) # 5efe <printf>
    exit(1);
    14e8:	4505                	li	a0,1
    14ea:	00004097          	auipc	ra,0x4
    14ee:	67a080e7          	jalr	1658(ra) # 5b64 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    14f2:	86aa                	mv	a3,a0
    14f4:	f6840613          	addi	a2,s0,-152
    14f8:	85b2                	mv	a1,a2
    14fa:	00005517          	auipc	a0,0x5
    14fe:	3c650513          	addi	a0,a0,966 # 68c0 <malloc+0x90a>
    1502:	00005097          	auipc	ra,0x5
    1506:	9fc080e7          	jalr	-1540(ra) # 5efe <printf>
    exit(1);
    150a:	4505                	li	a0,1
    150c:	00004097          	auipc	ra,0x4
    1510:	658080e7          	jalr	1624(ra) # 5b64 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1514:	567d                	li	a2,-1
    1516:	f6840593          	addi	a1,s0,-152
    151a:	00005517          	auipc	a0,0x5
    151e:	3ce50513          	addi	a0,a0,974 # 68e8 <malloc+0x932>
    1522:	00005097          	auipc	ra,0x5
    1526:	9dc080e7          	jalr	-1572(ra) # 5efe <printf>
    exit(1);
    152a:	4505                	li	a0,1
    152c:	00004097          	auipc	ra,0x4
    1530:	638080e7          	jalr	1592(ra) # 5b64 <exit>
    printf("fork failed\n");
    1534:	00006517          	auipc	a0,0x6
    1538:	83450513          	addi	a0,a0,-1996 # 6d68 <malloc+0xdb2>
    153c:	00005097          	auipc	ra,0x5
    1540:	9c2080e7          	jalr	-1598(ra) # 5efe <printf>
    exit(1);
    1544:	4505                	li	a0,1
    1546:	00004097          	auipc	ra,0x4
    154a:	61e080e7          	jalr	1566(ra) # 5b64 <exit>
    exit(747); // OK
    154e:	2eb00513          	li	a0,747
    1552:	00004097          	auipc	ra,0x4
    1556:	612080e7          	jalr	1554(ra) # 5b64 <exit>
  int st = 0;
    155a:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    155e:	f5440513          	addi	a0,s0,-172
    1562:	00004097          	auipc	ra,0x4
    1566:	60a080e7          	jalr	1546(ra) # 5b6c <wait>
  if (st != 747)
    156a:	f5442703          	lw	a4,-172(s0)
    156e:	2eb00793          	li	a5,747
    1572:	00f71663          	bne	a4,a5,157e <copyinstr2+0x1dc>
}
    1576:	60ae                	ld	ra,200(sp)
    1578:	640e                	ld	s0,192(sp)
    157a:	6169                	addi	sp,sp,208
    157c:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    157e:	00005517          	auipc	a0,0x5
    1582:	3b250513          	addi	a0,a0,946 # 6930 <malloc+0x97a>
    1586:	00005097          	auipc	ra,0x5
    158a:	978080e7          	jalr	-1672(ra) # 5efe <printf>
    exit(1);
    158e:	4505                	li	a0,1
    1590:	00004097          	auipc	ra,0x4
    1594:	5d4080e7          	jalr	1492(ra) # 5b64 <exit>

0000000000001598 <truncate3>:
{
    1598:	7159                	addi	sp,sp,-112
    159a:	f486                	sd	ra,104(sp)
    159c:	f0a2                	sd	s0,96(sp)
    159e:	eca6                	sd	s1,88(sp)
    15a0:	e8ca                	sd	s2,80(sp)
    15a2:	e4ce                	sd	s3,72(sp)
    15a4:	e0d2                	sd	s4,64(sp)
    15a6:	fc56                	sd	s5,56(sp)
    15a8:	1880                	addi	s0,sp,112
    15aa:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE | O_TRUNC | O_WRONLY));
    15ac:	60100593          	li	a1,1537
    15b0:	00005517          	auipc	a0,0x5
    15b4:	b8050513          	addi	a0,a0,-1152 # 6130 <malloc+0x17a>
    15b8:	00004097          	auipc	ra,0x4
    15bc:	5ec080e7          	jalr	1516(ra) # 5ba4 <open>
    15c0:	00004097          	auipc	ra,0x4
    15c4:	5cc080e7          	jalr	1484(ra) # 5b8c <close>
  pid = fork();
    15c8:	00004097          	auipc	ra,0x4
    15cc:	594080e7          	jalr	1428(ra) # 5b5c <fork>
  if (pid < 0)
    15d0:	08054063          	bltz	a0,1650 <truncate3+0xb8>
  if (pid == 0)
    15d4:	e969                	bnez	a0,16a6 <truncate3+0x10e>
    15d6:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    15da:	00005a17          	auipc	s4,0x5
    15de:	b56a0a13          	addi	s4,s4,-1194 # 6130 <malloc+0x17a>
      int n = write(fd, "1234567890", 10);
    15e2:	00005a97          	auipc	s5,0x5
    15e6:	3aea8a93          	addi	s5,s5,942 # 6990 <malloc+0x9da>
      int fd = open("truncfile", O_WRONLY);
    15ea:	4585                	li	a1,1
    15ec:	8552                	mv	a0,s4
    15ee:	00004097          	auipc	ra,0x4
    15f2:	5b6080e7          	jalr	1462(ra) # 5ba4 <open>
    15f6:	84aa                	mv	s1,a0
      if (fd < 0)
    15f8:	06054a63          	bltz	a0,166c <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    15fc:	4629                	li	a2,10
    15fe:	85d6                	mv	a1,s5
    1600:	00004097          	auipc	ra,0x4
    1604:	584080e7          	jalr	1412(ra) # 5b84 <write>
      if (n != 10)
    1608:	47a9                	li	a5,10
    160a:	06f51f63          	bne	a0,a5,1688 <truncate3+0xf0>
      close(fd);
    160e:	8526                	mv	a0,s1
    1610:	00004097          	auipc	ra,0x4
    1614:	57c080e7          	jalr	1404(ra) # 5b8c <close>
      fd = open("truncfile", O_RDONLY);
    1618:	4581                	li	a1,0
    161a:	8552                	mv	a0,s4
    161c:	00004097          	auipc	ra,0x4
    1620:	588080e7          	jalr	1416(ra) # 5ba4 <open>
    1624:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1626:	02000613          	li	a2,32
    162a:	f9840593          	addi	a1,s0,-104
    162e:	00004097          	auipc	ra,0x4
    1632:	54e080e7          	jalr	1358(ra) # 5b7c <read>
      close(fd);
    1636:	8526                	mv	a0,s1
    1638:	00004097          	auipc	ra,0x4
    163c:	554080e7          	jalr	1364(ra) # 5b8c <close>
    for (int i = 0; i < 100; i++)
    1640:	39fd                	addiw	s3,s3,-1
    1642:	fa0994e3          	bnez	s3,15ea <truncate3+0x52>
    exit(0);
    1646:	4501                	li	a0,0
    1648:	00004097          	auipc	ra,0x4
    164c:	51c080e7          	jalr	1308(ra) # 5b64 <exit>
    printf("%s: fork failed\n", s);
    1650:	85ca                	mv	a1,s2
    1652:	00005517          	auipc	a0,0x5
    1656:	30e50513          	addi	a0,a0,782 # 6960 <malloc+0x9aa>
    165a:	00005097          	auipc	ra,0x5
    165e:	8a4080e7          	jalr	-1884(ra) # 5efe <printf>
    exit(1);
    1662:	4505                	li	a0,1
    1664:	00004097          	auipc	ra,0x4
    1668:	500080e7          	jalr	1280(ra) # 5b64 <exit>
        printf("%s: open failed\n", s);
    166c:	85ca                	mv	a1,s2
    166e:	00005517          	auipc	a0,0x5
    1672:	30a50513          	addi	a0,a0,778 # 6978 <malloc+0x9c2>
    1676:	00005097          	auipc	ra,0x5
    167a:	888080e7          	jalr	-1912(ra) # 5efe <printf>
        exit(1);
    167e:	4505                	li	a0,1
    1680:	00004097          	auipc	ra,0x4
    1684:	4e4080e7          	jalr	1252(ra) # 5b64 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1688:	862a                	mv	a2,a0
    168a:	85ca                	mv	a1,s2
    168c:	00005517          	auipc	a0,0x5
    1690:	31450513          	addi	a0,a0,788 # 69a0 <malloc+0x9ea>
    1694:	00005097          	auipc	ra,0x5
    1698:	86a080e7          	jalr	-1942(ra) # 5efe <printf>
        exit(1);
    169c:	4505                	li	a0,1
    169e:	00004097          	auipc	ra,0x4
    16a2:	4c6080e7          	jalr	1222(ra) # 5b64 <exit>
    16a6:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    16aa:	00005a17          	auipc	s4,0x5
    16ae:	a86a0a13          	addi	s4,s4,-1402 # 6130 <malloc+0x17a>
    int n = write(fd, "xxx", 3);
    16b2:	00005a97          	auipc	s5,0x5
    16b6:	30ea8a93          	addi	s5,s5,782 # 69c0 <malloc+0xa0a>
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    16ba:	60100593          	li	a1,1537
    16be:	8552                	mv	a0,s4
    16c0:	00004097          	auipc	ra,0x4
    16c4:	4e4080e7          	jalr	1252(ra) # 5ba4 <open>
    16c8:	84aa                	mv	s1,a0
    if (fd < 0)
    16ca:	04054763          	bltz	a0,1718 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    16ce:	460d                	li	a2,3
    16d0:	85d6                	mv	a1,s5
    16d2:	00004097          	auipc	ra,0x4
    16d6:	4b2080e7          	jalr	1202(ra) # 5b84 <write>
    if (n != 3)
    16da:	478d                	li	a5,3
    16dc:	04f51c63          	bne	a0,a5,1734 <truncate3+0x19c>
    close(fd);
    16e0:	8526                	mv	a0,s1
    16e2:	00004097          	auipc	ra,0x4
    16e6:	4aa080e7          	jalr	1194(ra) # 5b8c <close>
  for (int i = 0; i < 150; i++)
    16ea:	39fd                	addiw	s3,s3,-1
    16ec:	fc0997e3          	bnez	s3,16ba <truncate3+0x122>
  wait(&xstatus);
    16f0:	fbc40513          	addi	a0,s0,-68
    16f4:	00004097          	auipc	ra,0x4
    16f8:	478080e7          	jalr	1144(ra) # 5b6c <wait>
  unlink("truncfile");
    16fc:	00005517          	auipc	a0,0x5
    1700:	a3450513          	addi	a0,a0,-1484 # 6130 <malloc+0x17a>
    1704:	00004097          	auipc	ra,0x4
    1708:	4b0080e7          	jalr	1200(ra) # 5bb4 <unlink>
  exit(xstatus);
    170c:	fbc42503          	lw	a0,-68(s0)
    1710:	00004097          	auipc	ra,0x4
    1714:	454080e7          	jalr	1108(ra) # 5b64 <exit>
      printf("%s: open failed\n", s);
    1718:	85ca                	mv	a1,s2
    171a:	00005517          	auipc	a0,0x5
    171e:	25e50513          	addi	a0,a0,606 # 6978 <malloc+0x9c2>
    1722:	00004097          	auipc	ra,0x4
    1726:	7dc080e7          	jalr	2012(ra) # 5efe <printf>
      exit(1);
    172a:	4505                	li	a0,1
    172c:	00004097          	auipc	ra,0x4
    1730:	438080e7          	jalr	1080(ra) # 5b64 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1734:	862a                	mv	a2,a0
    1736:	85ca                	mv	a1,s2
    1738:	00005517          	auipc	a0,0x5
    173c:	29050513          	addi	a0,a0,656 # 69c8 <malloc+0xa12>
    1740:	00004097          	auipc	ra,0x4
    1744:	7be080e7          	jalr	1982(ra) # 5efe <printf>
      exit(1);
    1748:	4505                	li	a0,1
    174a:	00004097          	auipc	ra,0x4
    174e:	41a080e7          	jalr	1050(ra) # 5b64 <exit>

0000000000001752 <exectest>:
{
    1752:	715d                	addi	sp,sp,-80
    1754:	e486                	sd	ra,72(sp)
    1756:	e0a2                	sd	s0,64(sp)
    1758:	fc26                	sd	s1,56(sp)
    175a:	f84a                	sd	s2,48(sp)
    175c:	0880                	addi	s0,sp,80
    175e:	892a                	mv	s2,a0
  char *echoargv[] = {"echo", "OK", 0};
    1760:	00005797          	auipc	a5,0x5
    1764:	97878793          	addi	a5,a5,-1672 # 60d8 <malloc+0x122>
    1768:	fcf43023          	sd	a5,-64(s0)
    176c:	00005797          	auipc	a5,0x5
    1770:	27c78793          	addi	a5,a5,636 # 69e8 <malloc+0xa32>
    1774:	fcf43423          	sd	a5,-56(s0)
    1778:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    177c:	00005517          	auipc	a0,0x5
    1780:	27450513          	addi	a0,a0,628 # 69f0 <malloc+0xa3a>
    1784:	00004097          	auipc	ra,0x4
    1788:	430080e7          	jalr	1072(ra) # 5bb4 <unlink>
  pid = fork();
    178c:	00004097          	auipc	ra,0x4
    1790:	3d0080e7          	jalr	976(ra) # 5b5c <fork>
  if (pid < 0)
    1794:	04054663          	bltz	a0,17e0 <exectest+0x8e>
    1798:	84aa                	mv	s1,a0
  if (pid == 0)
    179a:	e959                	bnez	a0,1830 <exectest+0xde>
    close(1);
    179c:	4505                	li	a0,1
    179e:	00004097          	auipc	ra,0x4
    17a2:	3ee080e7          	jalr	1006(ra) # 5b8c <close>
    fd = open("echo-ok", O_CREATE | O_WRONLY);
    17a6:	20100593          	li	a1,513
    17aa:	00005517          	auipc	a0,0x5
    17ae:	24650513          	addi	a0,a0,582 # 69f0 <malloc+0xa3a>
    17b2:	00004097          	auipc	ra,0x4
    17b6:	3f2080e7          	jalr	1010(ra) # 5ba4 <open>
    if (fd < 0)
    17ba:	04054163          	bltz	a0,17fc <exectest+0xaa>
    if (fd != 1)
    17be:	4785                	li	a5,1
    17c0:	04f50c63          	beq	a0,a5,1818 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    17c4:	85ca                	mv	a1,s2
    17c6:	00005517          	auipc	a0,0x5
    17ca:	24a50513          	addi	a0,a0,586 # 6a10 <malloc+0xa5a>
    17ce:	00004097          	auipc	ra,0x4
    17d2:	730080e7          	jalr	1840(ra) # 5efe <printf>
      exit(1);
    17d6:	4505                	li	a0,1
    17d8:	00004097          	auipc	ra,0x4
    17dc:	38c080e7          	jalr	908(ra) # 5b64 <exit>
    printf("%s: fork failed\n", s);
    17e0:	85ca                	mv	a1,s2
    17e2:	00005517          	auipc	a0,0x5
    17e6:	17e50513          	addi	a0,a0,382 # 6960 <malloc+0x9aa>
    17ea:	00004097          	auipc	ra,0x4
    17ee:	714080e7          	jalr	1812(ra) # 5efe <printf>
    exit(1);
    17f2:	4505                	li	a0,1
    17f4:	00004097          	auipc	ra,0x4
    17f8:	370080e7          	jalr	880(ra) # 5b64 <exit>
      printf("%s: create failed\n", s);
    17fc:	85ca                	mv	a1,s2
    17fe:	00005517          	auipc	a0,0x5
    1802:	1fa50513          	addi	a0,a0,506 # 69f8 <malloc+0xa42>
    1806:	00004097          	auipc	ra,0x4
    180a:	6f8080e7          	jalr	1784(ra) # 5efe <printf>
      exit(1);
    180e:	4505                	li	a0,1
    1810:	00004097          	auipc	ra,0x4
    1814:	354080e7          	jalr	852(ra) # 5b64 <exit>
    if (exec("echo", echoargv) < 0)
    1818:	fc040593          	addi	a1,s0,-64
    181c:	00005517          	auipc	a0,0x5
    1820:	8bc50513          	addi	a0,a0,-1860 # 60d8 <malloc+0x122>
    1824:	00004097          	auipc	ra,0x4
    1828:	378080e7          	jalr	888(ra) # 5b9c <exec>
    182c:	02054163          	bltz	a0,184e <exectest+0xfc>
  if (wait(&xstatus) != pid)
    1830:	fdc40513          	addi	a0,s0,-36
    1834:	00004097          	auipc	ra,0x4
    1838:	338080e7          	jalr	824(ra) # 5b6c <wait>
    183c:	02951763          	bne	a0,s1,186a <exectest+0x118>
  if (xstatus != 0)
    1840:	fdc42503          	lw	a0,-36(s0)
    1844:	cd0d                	beqz	a0,187e <exectest+0x12c>
    exit(xstatus);
    1846:	00004097          	auipc	ra,0x4
    184a:	31e080e7          	jalr	798(ra) # 5b64 <exit>
      printf("%s: exec echo failed\n", s);
    184e:	85ca                	mv	a1,s2
    1850:	00005517          	auipc	a0,0x5
    1854:	1d050513          	addi	a0,a0,464 # 6a20 <malloc+0xa6a>
    1858:	00004097          	auipc	ra,0x4
    185c:	6a6080e7          	jalr	1702(ra) # 5efe <printf>
      exit(1);
    1860:	4505                	li	a0,1
    1862:	00004097          	auipc	ra,0x4
    1866:	302080e7          	jalr	770(ra) # 5b64 <exit>
    printf("%s: wait failed!\n", s);
    186a:	85ca                	mv	a1,s2
    186c:	00005517          	auipc	a0,0x5
    1870:	1cc50513          	addi	a0,a0,460 # 6a38 <malloc+0xa82>
    1874:	00004097          	auipc	ra,0x4
    1878:	68a080e7          	jalr	1674(ra) # 5efe <printf>
    187c:	b7d1                	j	1840 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    187e:	4581                	li	a1,0
    1880:	00005517          	auipc	a0,0x5
    1884:	17050513          	addi	a0,a0,368 # 69f0 <malloc+0xa3a>
    1888:	00004097          	auipc	ra,0x4
    188c:	31c080e7          	jalr	796(ra) # 5ba4 <open>
  if (fd < 0)
    1890:	02054a63          	bltz	a0,18c4 <exectest+0x172>
  if (read(fd, buf, 2) != 2)
    1894:	4609                	li	a2,2
    1896:	fb840593          	addi	a1,s0,-72
    189a:	00004097          	auipc	ra,0x4
    189e:	2e2080e7          	jalr	738(ra) # 5b7c <read>
    18a2:	4789                	li	a5,2
    18a4:	02f50e63          	beq	a0,a5,18e0 <exectest+0x18e>
    printf("%s: read failed\n", s);
    18a8:	85ca                	mv	a1,s2
    18aa:	00005517          	auipc	a0,0x5
    18ae:	bfe50513          	addi	a0,a0,-1026 # 64a8 <malloc+0x4f2>
    18b2:	00004097          	auipc	ra,0x4
    18b6:	64c080e7          	jalr	1612(ra) # 5efe <printf>
    exit(1);
    18ba:	4505                	li	a0,1
    18bc:	00004097          	auipc	ra,0x4
    18c0:	2a8080e7          	jalr	680(ra) # 5b64 <exit>
    printf("%s: open failed\n", s);
    18c4:	85ca                	mv	a1,s2
    18c6:	00005517          	auipc	a0,0x5
    18ca:	0b250513          	addi	a0,a0,178 # 6978 <malloc+0x9c2>
    18ce:	00004097          	auipc	ra,0x4
    18d2:	630080e7          	jalr	1584(ra) # 5efe <printf>
    exit(1);
    18d6:	4505                	li	a0,1
    18d8:	00004097          	auipc	ra,0x4
    18dc:	28c080e7          	jalr	652(ra) # 5b64 <exit>
  unlink("echo-ok");
    18e0:	00005517          	auipc	a0,0x5
    18e4:	11050513          	addi	a0,a0,272 # 69f0 <malloc+0xa3a>
    18e8:	00004097          	auipc	ra,0x4
    18ec:	2cc080e7          	jalr	716(ra) # 5bb4 <unlink>
  if (buf[0] == 'O' && buf[1] == 'K')
    18f0:	fb844703          	lbu	a4,-72(s0)
    18f4:	04f00793          	li	a5,79
    18f8:	00f71863          	bne	a4,a5,1908 <exectest+0x1b6>
    18fc:	fb944703          	lbu	a4,-71(s0)
    1900:	04b00793          	li	a5,75
    1904:	02f70063          	beq	a4,a5,1924 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1908:	85ca                	mv	a1,s2
    190a:	00005517          	auipc	a0,0x5
    190e:	14650513          	addi	a0,a0,326 # 6a50 <malloc+0xa9a>
    1912:	00004097          	auipc	ra,0x4
    1916:	5ec080e7          	jalr	1516(ra) # 5efe <printf>
    exit(1);
    191a:	4505                	li	a0,1
    191c:	00004097          	auipc	ra,0x4
    1920:	248080e7          	jalr	584(ra) # 5b64 <exit>
    exit(0);
    1924:	4501                	li	a0,0
    1926:	00004097          	auipc	ra,0x4
    192a:	23e080e7          	jalr	574(ra) # 5b64 <exit>

000000000000192e <pipe1>:
{
    192e:	711d                	addi	sp,sp,-96
    1930:	ec86                	sd	ra,88(sp)
    1932:	e8a2                	sd	s0,80(sp)
    1934:	e4a6                	sd	s1,72(sp)
    1936:	e0ca                	sd	s2,64(sp)
    1938:	fc4e                	sd	s3,56(sp)
    193a:	f852                	sd	s4,48(sp)
    193c:	f456                	sd	s5,40(sp)
    193e:	f05a                	sd	s6,32(sp)
    1940:	ec5e                	sd	s7,24(sp)
    1942:	1080                	addi	s0,sp,96
    1944:	892a                	mv	s2,a0
  if (pipe(fds) != 0)
    1946:	fa840513          	addi	a0,s0,-88
    194a:	00004097          	auipc	ra,0x4
    194e:	22a080e7          	jalr	554(ra) # 5b74 <pipe>
    1952:	e93d                	bnez	a0,19c8 <pipe1+0x9a>
    1954:	84aa                	mv	s1,a0
  pid = fork();
    1956:	00004097          	auipc	ra,0x4
    195a:	206080e7          	jalr	518(ra) # 5b5c <fork>
    195e:	8a2a                	mv	s4,a0
  if (pid == 0)
    1960:	c151                	beqz	a0,19e4 <pipe1+0xb6>
  else if (pid > 0)
    1962:	16a05d63          	blez	a0,1adc <pipe1+0x1ae>
    close(fds[1]);
    1966:	fac42503          	lw	a0,-84(s0)
    196a:	00004097          	auipc	ra,0x4
    196e:	222080e7          	jalr	546(ra) # 5b8c <close>
    total = 0;
    1972:	8a26                	mv	s4,s1
    cc = 1;
    1974:	4985                	li	s3,1
    while ((n = read(fds[0], buf, cc)) > 0)
    1976:	0000ba97          	auipc	s5,0xb
    197a:	302a8a93          	addi	s5,s5,770 # cc78 <buf>
      if (cc > sizeof(buf))
    197e:	6b0d                	lui	s6,0x3
    while ((n = read(fds[0], buf, cc)) > 0)
    1980:	864e                	mv	a2,s3
    1982:	85d6                	mv	a1,s5
    1984:	fa842503          	lw	a0,-88(s0)
    1988:	00004097          	auipc	ra,0x4
    198c:	1f4080e7          	jalr	500(ra) # 5b7c <read>
    1990:	10a05163          	blez	a0,1a92 <pipe1+0x164>
      for (i = 0; i < n; i++)
    1994:	0000b717          	auipc	a4,0xb
    1998:	2e470713          	addi	a4,a4,740 # cc78 <buf>
    199c:	00a4863b          	addw	a2,s1,a0
        if ((buf[i] & 0xff) != (seq++ & 0xff))
    19a0:	00074683          	lbu	a3,0(a4)
    19a4:	0ff4f793          	zext.b	a5,s1
    19a8:	2485                	addiw	s1,s1,1
    19aa:	0cf69063          	bne	a3,a5,1a6a <pipe1+0x13c>
      for (i = 0; i < n; i++)
    19ae:	0705                	addi	a4,a4,1
    19b0:	fec498e3          	bne	s1,a2,19a0 <pipe1+0x72>
      total += n;
    19b4:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    19b8:	0019979b          	slliw	a5,s3,0x1
    19bc:	0007899b          	sext.w	s3,a5
      if (cc > sizeof(buf))
    19c0:	fd3b70e3          	bgeu	s6,s3,1980 <pipe1+0x52>
        cc = sizeof(buf);
    19c4:	89da                	mv	s3,s6
    19c6:	bf6d                	j	1980 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    19c8:	85ca                	mv	a1,s2
    19ca:	00005517          	auipc	a0,0x5
    19ce:	09e50513          	addi	a0,a0,158 # 6a68 <malloc+0xab2>
    19d2:	00004097          	auipc	ra,0x4
    19d6:	52c080e7          	jalr	1324(ra) # 5efe <printf>
    exit(1);
    19da:	4505                	li	a0,1
    19dc:	00004097          	auipc	ra,0x4
    19e0:	188080e7          	jalr	392(ra) # 5b64 <exit>
    close(fds[0]);
    19e4:	fa842503          	lw	a0,-88(s0)
    19e8:	00004097          	auipc	ra,0x4
    19ec:	1a4080e7          	jalr	420(ra) # 5b8c <close>
    for (n = 0; n < N; n++)
    19f0:	0000bb17          	auipc	s6,0xb
    19f4:	288b0b13          	addi	s6,s6,648 # cc78 <buf>
    19f8:	416004bb          	negw	s1,s6
    19fc:	0ff4f493          	zext.b	s1,s1
    1a00:	409b0993          	addi	s3,s6,1033
      if (write(fds[1], buf, SZ) != SZ)
    1a04:	8bda                	mv	s7,s6
    for (n = 0; n < N; n++)
    1a06:	6a85                	lui	s5,0x1
    1a08:	42da8a93          	addi	s5,s5,1069 # 142d <copyinstr2+0x8b>
{
    1a0c:	87da                	mv	a5,s6
        buf[i] = seq++;
    1a0e:	0097873b          	addw	a4,a5,s1
    1a12:	00e78023          	sb	a4,0(a5)
      for (i = 0; i < SZ; i++)
    1a16:	0785                	addi	a5,a5,1
    1a18:	fef99be3          	bne	s3,a5,1a0e <pipe1+0xe0>
        buf[i] = seq++;
    1a1c:	409a0a1b          	addiw	s4,s4,1033
      if (write(fds[1], buf, SZ) != SZ)
    1a20:	40900613          	li	a2,1033
    1a24:	85de                	mv	a1,s7
    1a26:	fac42503          	lw	a0,-84(s0)
    1a2a:	00004097          	auipc	ra,0x4
    1a2e:	15a080e7          	jalr	346(ra) # 5b84 <write>
    1a32:	40900793          	li	a5,1033
    1a36:	00f51c63          	bne	a0,a5,1a4e <pipe1+0x120>
    for (n = 0; n < N; n++)
    1a3a:	24a5                	addiw	s1,s1,9
    1a3c:	0ff4f493          	zext.b	s1,s1
    1a40:	fd5a16e3          	bne	s4,s5,1a0c <pipe1+0xde>
    exit(0);
    1a44:	4501                	li	a0,0
    1a46:	00004097          	auipc	ra,0x4
    1a4a:	11e080e7          	jalr	286(ra) # 5b64 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1a4e:	85ca                	mv	a1,s2
    1a50:	00005517          	auipc	a0,0x5
    1a54:	03050513          	addi	a0,a0,48 # 6a80 <malloc+0xaca>
    1a58:	00004097          	auipc	ra,0x4
    1a5c:	4a6080e7          	jalr	1190(ra) # 5efe <printf>
        exit(1);
    1a60:	4505                	li	a0,1
    1a62:	00004097          	auipc	ra,0x4
    1a66:	102080e7          	jalr	258(ra) # 5b64 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1a6a:	85ca                	mv	a1,s2
    1a6c:	00005517          	auipc	a0,0x5
    1a70:	02c50513          	addi	a0,a0,44 # 6a98 <malloc+0xae2>
    1a74:	00004097          	auipc	ra,0x4
    1a78:	48a080e7          	jalr	1162(ra) # 5efe <printf>
}
    1a7c:	60e6                	ld	ra,88(sp)
    1a7e:	6446                	ld	s0,80(sp)
    1a80:	64a6                	ld	s1,72(sp)
    1a82:	6906                	ld	s2,64(sp)
    1a84:	79e2                	ld	s3,56(sp)
    1a86:	7a42                	ld	s4,48(sp)
    1a88:	7aa2                	ld	s5,40(sp)
    1a8a:	7b02                	ld	s6,32(sp)
    1a8c:	6be2                	ld	s7,24(sp)
    1a8e:	6125                	addi	sp,sp,96
    1a90:	8082                	ret
    if (total != N * SZ)
    1a92:	6785                	lui	a5,0x1
    1a94:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x8b>
    1a98:	02fa0063          	beq	s4,a5,1ab8 <pipe1+0x18a>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1a9c:	85d2                	mv	a1,s4
    1a9e:	00005517          	auipc	a0,0x5
    1aa2:	01250513          	addi	a0,a0,18 # 6ab0 <malloc+0xafa>
    1aa6:	00004097          	auipc	ra,0x4
    1aaa:	458080e7          	jalr	1112(ra) # 5efe <printf>
      exit(1);
    1aae:	4505                	li	a0,1
    1ab0:	00004097          	auipc	ra,0x4
    1ab4:	0b4080e7          	jalr	180(ra) # 5b64 <exit>
    close(fds[0]);
    1ab8:	fa842503          	lw	a0,-88(s0)
    1abc:	00004097          	auipc	ra,0x4
    1ac0:	0d0080e7          	jalr	208(ra) # 5b8c <close>
    wait(&xstatus);
    1ac4:	fa440513          	addi	a0,s0,-92
    1ac8:	00004097          	auipc	ra,0x4
    1acc:	0a4080e7          	jalr	164(ra) # 5b6c <wait>
    exit(xstatus);
    1ad0:	fa442503          	lw	a0,-92(s0)
    1ad4:	00004097          	auipc	ra,0x4
    1ad8:	090080e7          	jalr	144(ra) # 5b64 <exit>
    printf("%s: fork() failed\n", s);
    1adc:	85ca                	mv	a1,s2
    1ade:	00005517          	auipc	a0,0x5
    1ae2:	ff250513          	addi	a0,a0,-14 # 6ad0 <malloc+0xb1a>
    1ae6:	00004097          	auipc	ra,0x4
    1aea:	418080e7          	jalr	1048(ra) # 5efe <printf>
    exit(1);
    1aee:	4505                	li	a0,1
    1af0:	00004097          	auipc	ra,0x4
    1af4:	074080e7          	jalr	116(ra) # 5b64 <exit>

0000000000001af8 <exitwait>:
{
    1af8:	7139                	addi	sp,sp,-64
    1afa:	fc06                	sd	ra,56(sp)
    1afc:	f822                	sd	s0,48(sp)
    1afe:	f426                	sd	s1,40(sp)
    1b00:	f04a                	sd	s2,32(sp)
    1b02:	ec4e                	sd	s3,24(sp)
    1b04:	e852                	sd	s4,16(sp)
    1b06:	0080                	addi	s0,sp,64
    1b08:	8a2a                	mv	s4,a0
  for (i = 0; i < 100; i++)
    1b0a:	4901                	li	s2,0
    1b0c:	06400993          	li	s3,100
    pid = fork();
    1b10:	00004097          	auipc	ra,0x4
    1b14:	04c080e7          	jalr	76(ra) # 5b5c <fork>
    1b18:	84aa                	mv	s1,a0
    if (pid < 0)
    1b1a:	02054a63          	bltz	a0,1b4e <exitwait+0x56>
    if (pid)
    1b1e:	c151                	beqz	a0,1ba2 <exitwait+0xaa>
      if (wait(&xstate) != pid)
    1b20:	fcc40513          	addi	a0,s0,-52
    1b24:	00004097          	auipc	ra,0x4
    1b28:	048080e7          	jalr	72(ra) # 5b6c <wait>
    1b2c:	02951f63          	bne	a0,s1,1b6a <exitwait+0x72>
      if (i != xstate)
    1b30:	fcc42783          	lw	a5,-52(s0)
    1b34:	05279963          	bne	a5,s2,1b86 <exitwait+0x8e>
  for (i = 0; i < 100; i++)
    1b38:	2905                	addiw	s2,s2,1
    1b3a:	fd391be3          	bne	s2,s3,1b10 <exitwait+0x18>
}
    1b3e:	70e2                	ld	ra,56(sp)
    1b40:	7442                	ld	s0,48(sp)
    1b42:	74a2                	ld	s1,40(sp)
    1b44:	7902                	ld	s2,32(sp)
    1b46:	69e2                	ld	s3,24(sp)
    1b48:	6a42                	ld	s4,16(sp)
    1b4a:	6121                	addi	sp,sp,64
    1b4c:	8082                	ret
      printf("%s: fork failed\n", s);
    1b4e:	85d2                	mv	a1,s4
    1b50:	00005517          	auipc	a0,0x5
    1b54:	e1050513          	addi	a0,a0,-496 # 6960 <malloc+0x9aa>
    1b58:	00004097          	auipc	ra,0x4
    1b5c:	3a6080e7          	jalr	934(ra) # 5efe <printf>
      exit(1);
    1b60:	4505                	li	a0,1
    1b62:	00004097          	auipc	ra,0x4
    1b66:	002080e7          	jalr	2(ra) # 5b64 <exit>
        printf("%s: wait wrong pid\n", s);
    1b6a:	85d2                	mv	a1,s4
    1b6c:	00005517          	auipc	a0,0x5
    1b70:	f7c50513          	addi	a0,a0,-132 # 6ae8 <malloc+0xb32>
    1b74:	00004097          	auipc	ra,0x4
    1b78:	38a080e7          	jalr	906(ra) # 5efe <printf>
        exit(1);
    1b7c:	4505                	li	a0,1
    1b7e:	00004097          	auipc	ra,0x4
    1b82:	fe6080e7          	jalr	-26(ra) # 5b64 <exit>
        printf("%s: wait wrong exit status\n", s);
    1b86:	85d2                	mv	a1,s4
    1b88:	00005517          	auipc	a0,0x5
    1b8c:	f7850513          	addi	a0,a0,-136 # 6b00 <malloc+0xb4a>
    1b90:	00004097          	auipc	ra,0x4
    1b94:	36e080e7          	jalr	878(ra) # 5efe <printf>
        exit(1);
    1b98:	4505                	li	a0,1
    1b9a:	00004097          	auipc	ra,0x4
    1b9e:	fca080e7          	jalr	-54(ra) # 5b64 <exit>
      exit(i);
    1ba2:	854a                	mv	a0,s2
    1ba4:	00004097          	auipc	ra,0x4
    1ba8:	fc0080e7          	jalr	-64(ra) # 5b64 <exit>

0000000000001bac <twochildren>:
{
    1bac:	1101                	addi	sp,sp,-32
    1bae:	ec06                	sd	ra,24(sp)
    1bb0:	e822                	sd	s0,16(sp)
    1bb2:	e426                	sd	s1,8(sp)
    1bb4:	e04a                	sd	s2,0(sp)
    1bb6:	1000                	addi	s0,sp,32
    1bb8:	892a                	mv	s2,a0
    1bba:	3e800493          	li	s1,1000
    int pid1 = fork();
    1bbe:	00004097          	auipc	ra,0x4
    1bc2:	f9e080e7          	jalr	-98(ra) # 5b5c <fork>
    if (pid1 < 0)
    1bc6:	02054c63          	bltz	a0,1bfe <twochildren+0x52>
    if (pid1 == 0)
    1bca:	c921                	beqz	a0,1c1a <twochildren+0x6e>
      int pid2 = fork();
    1bcc:	00004097          	auipc	ra,0x4
    1bd0:	f90080e7          	jalr	-112(ra) # 5b5c <fork>
      if (pid2 < 0)
    1bd4:	04054763          	bltz	a0,1c22 <twochildren+0x76>
      if (pid2 == 0)
    1bd8:	c13d                	beqz	a0,1c3e <twochildren+0x92>
        wait(0);
    1bda:	4501                	li	a0,0
    1bdc:	00004097          	auipc	ra,0x4
    1be0:	f90080e7          	jalr	-112(ra) # 5b6c <wait>
        wait(0);
    1be4:	4501                	li	a0,0
    1be6:	00004097          	auipc	ra,0x4
    1bea:	f86080e7          	jalr	-122(ra) # 5b6c <wait>
  for (int i = 0; i < 1000; i++)
    1bee:	34fd                	addiw	s1,s1,-1
    1bf0:	f4f9                	bnez	s1,1bbe <twochildren+0x12>
}
    1bf2:	60e2                	ld	ra,24(sp)
    1bf4:	6442                	ld	s0,16(sp)
    1bf6:	64a2                	ld	s1,8(sp)
    1bf8:	6902                	ld	s2,0(sp)
    1bfa:	6105                	addi	sp,sp,32
    1bfc:	8082                	ret
      printf("%s: fork failed\n", s);
    1bfe:	85ca                	mv	a1,s2
    1c00:	00005517          	auipc	a0,0x5
    1c04:	d6050513          	addi	a0,a0,-672 # 6960 <malloc+0x9aa>
    1c08:	00004097          	auipc	ra,0x4
    1c0c:	2f6080e7          	jalr	758(ra) # 5efe <printf>
      exit(1);
    1c10:	4505                	li	a0,1
    1c12:	00004097          	auipc	ra,0x4
    1c16:	f52080e7          	jalr	-174(ra) # 5b64 <exit>
      exit(0);
    1c1a:	00004097          	auipc	ra,0x4
    1c1e:	f4a080e7          	jalr	-182(ra) # 5b64 <exit>
        printf("%s: fork failed\n", s);
    1c22:	85ca                	mv	a1,s2
    1c24:	00005517          	auipc	a0,0x5
    1c28:	d3c50513          	addi	a0,a0,-708 # 6960 <malloc+0x9aa>
    1c2c:	00004097          	auipc	ra,0x4
    1c30:	2d2080e7          	jalr	722(ra) # 5efe <printf>
        exit(1);
    1c34:	4505                	li	a0,1
    1c36:	00004097          	auipc	ra,0x4
    1c3a:	f2e080e7          	jalr	-210(ra) # 5b64 <exit>
        exit(0);
    1c3e:	00004097          	auipc	ra,0x4
    1c42:	f26080e7          	jalr	-218(ra) # 5b64 <exit>

0000000000001c46 <forkfork>:
{
    1c46:	7179                	addi	sp,sp,-48
    1c48:	f406                	sd	ra,40(sp)
    1c4a:	f022                	sd	s0,32(sp)
    1c4c:	ec26                	sd	s1,24(sp)
    1c4e:	1800                	addi	s0,sp,48
    1c50:	84aa                	mv	s1,a0
    int pid = fork();
    1c52:	00004097          	auipc	ra,0x4
    1c56:	f0a080e7          	jalr	-246(ra) # 5b5c <fork>
    if (pid < 0)
    1c5a:	04054163          	bltz	a0,1c9c <forkfork+0x56>
    if (pid == 0)
    1c5e:	cd29                	beqz	a0,1cb8 <forkfork+0x72>
    int pid = fork();
    1c60:	00004097          	auipc	ra,0x4
    1c64:	efc080e7          	jalr	-260(ra) # 5b5c <fork>
    if (pid < 0)
    1c68:	02054a63          	bltz	a0,1c9c <forkfork+0x56>
    if (pid == 0)
    1c6c:	c531                	beqz	a0,1cb8 <forkfork+0x72>
    wait(&xstatus);
    1c6e:	fdc40513          	addi	a0,s0,-36
    1c72:	00004097          	auipc	ra,0x4
    1c76:	efa080e7          	jalr	-262(ra) # 5b6c <wait>
    if (xstatus != 0)
    1c7a:	fdc42783          	lw	a5,-36(s0)
    1c7e:	ebbd                	bnez	a5,1cf4 <forkfork+0xae>
    wait(&xstatus);
    1c80:	fdc40513          	addi	a0,s0,-36
    1c84:	00004097          	auipc	ra,0x4
    1c88:	ee8080e7          	jalr	-280(ra) # 5b6c <wait>
    if (xstatus != 0)
    1c8c:	fdc42783          	lw	a5,-36(s0)
    1c90:	e3b5                	bnez	a5,1cf4 <forkfork+0xae>
}
    1c92:	70a2                	ld	ra,40(sp)
    1c94:	7402                	ld	s0,32(sp)
    1c96:	64e2                	ld	s1,24(sp)
    1c98:	6145                	addi	sp,sp,48
    1c9a:	8082                	ret
      printf("%s: fork failed", s);
    1c9c:	85a6                	mv	a1,s1
    1c9e:	00005517          	auipc	a0,0x5
    1ca2:	e8250513          	addi	a0,a0,-382 # 6b20 <malloc+0xb6a>
    1ca6:	00004097          	auipc	ra,0x4
    1caa:	258080e7          	jalr	600(ra) # 5efe <printf>
      exit(1);
    1cae:	4505                	li	a0,1
    1cb0:	00004097          	auipc	ra,0x4
    1cb4:	eb4080e7          	jalr	-332(ra) # 5b64 <exit>
{
    1cb8:	0c800493          	li	s1,200
        int pid1 = fork();
    1cbc:	00004097          	auipc	ra,0x4
    1cc0:	ea0080e7          	jalr	-352(ra) # 5b5c <fork>
        if (pid1 < 0)
    1cc4:	00054f63          	bltz	a0,1ce2 <forkfork+0x9c>
        if (pid1 == 0)
    1cc8:	c115                	beqz	a0,1cec <forkfork+0xa6>
        wait(0);
    1cca:	4501                	li	a0,0
    1ccc:	00004097          	auipc	ra,0x4
    1cd0:	ea0080e7          	jalr	-352(ra) # 5b6c <wait>
      for (int j = 0; j < 200; j++)
    1cd4:	34fd                	addiw	s1,s1,-1
    1cd6:	f0fd                	bnez	s1,1cbc <forkfork+0x76>
      exit(0);
    1cd8:	4501                	li	a0,0
    1cda:	00004097          	auipc	ra,0x4
    1cde:	e8a080e7          	jalr	-374(ra) # 5b64 <exit>
          exit(1);
    1ce2:	4505                	li	a0,1
    1ce4:	00004097          	auipc	ra,0x4
    1ce8:	e80080e7          	jalr	-384(ra) # 5b64 <exit>
          exit(0);
    1cec:	00004097          	auipc	ra,0x4
    1cf0:	e78080e7          	jalr	-392(ra) # 5b64 <exit>
      printf("%s: fork in child failed", s);
    1cf4:	85a6                	mv	a1,s1
    1cf6:	00005517          	auipc	a0,0x5
    1cfa:	e3a50513          	addi	a0,a0,-454 # 6b30 <malloc+0xb7a>
    1cfe:	00004097          	auipc	ra,0x4
    1d02:	200080e7          	jalr	512(ra) # 5efe <printf>
      exit(1);
    1d06:	4505                	li	a0,1
    1d08:	00004097          	auipc	ra,0x4
    1d0c:	e5c080e7          	jalr	-420(ra) # 5b64 <exit>

0000000000001d10 <reparent2>:
{
    1d10:	1101                	addi	sp,sp,-32
    1d12:	ec06                	sd	ra,24(sp)
    1d14:	e822                	sd	s0,16(sp)
    1d16:	e426                	sd	s1,8(sp)
    1d18:	1000                	addi	s0,sp,32
    1d1a:	32000493          	li	s1,800
    int pid1 = fork();
    1d1e:	00004097          	auipc	ra,0x4
    1d22:	e3e080e7          	jalr	-450(ra) # 5b5c <fork>
    if (pid1 < 0)
    1d26:	00054f63          	bltz	a0,1d44 <reparent2+0x34>
    if (pid1 == 0)
    1d2a:	c915                	beqz	a0,1d5e <reparent2+0x4e>
    wait(0);
    1d2c:	4501                	li	a0,0
    1d2e:	00004097          	auipc	ra,0x4
    1d32:	e3e080e7          	jalr	-450(ra) # 5b6c <wait>
  for (int i = 0; i < 800; i++)
    1d36:	34fd                	addiw	s1,s1,-1
    1d38:	f0fd                	bnez	s1,1d1e <reparent2+0xe>
  exit(0);
    1d3a:	4501                	li	a0,0
    1d3c:	00004097          	auipc	ra,0x4
    1d40:	e28080e7          	jalr	-472(ra) # 5b64 <exit>
      printf("fork failed\n");
    1d44:	00005517          	auipc	a0,0x5
    1d48:	02450513          	addi	a0,a0,36 # 6d68 <malloc+0xdb2>
    1d4c:	00004097          	auipc	ra,0x4
    1d50:	1b2080e7          	jalr	434(ra) # 5efe <printf>
      exit(1);
    1d54:	4505                	li	a0,1
    1d56:	00004097          	auipc	ra,0x4
    1d5a:	e0e080e7          	jalr	-498(ra) # 5b64 <exit>
      fork();
    1d5e:	00004097          	auipc	ra,0x4
    1d62:	dfe080e7          	jalr	-514(ra) # 5b5c <fork>
      fork();
    1d66:	00004097          	auipc	ra,0x4
    1d6a:	df6080e7          	jalr	-522(ra) # 5b5c <fork>
      exit(0);
    1d6e:	4501                	li	a0,0
    1d70:	00004097          	auipc	ra,0x4
    1d74:	df4080e7          	jalr	-524(ra) # 5b64 <exit>

0000000000001d78 <createdelete>:
{
    1d78:	7175                	addi	sp,sp,-144
    1d7a:	e506                	sd	ra,136(sp)
    1d7c:	e122                	sd	s0,128(sp)
    1d7e:	fca6                	sd	s1,120(sp)
    1d80:	f8ca                	sd	s2,112(sp)
    1d82:	f4ce                	sd	s3,104(sp)
    1d84:	f0d2                	sd	s4,96(sp)
    1d86:	ecd6                	sd	s5,88(sp)
    1d88:	e8da                	sd	s6,80(sp)
    1d8a:	e4de                	sd	s7,72(sp)
    1d8c:	e0e2                	sd	s8,64(sp)
    1d8e:	fc66                	sd	s9,56(sp)
    1d90:	0900                	addi	s0,sp,144
    1d92:	8caa                	mv	s9,a0
  for (pi = 0; pi < NCHILD; pi++)
    1d94:	4901                	li	s2,0
    1d96:	4991                	li	s3,4
    pid = fork();
    1d98:	00004097          	auipc	ra,0x4
    1d9c:	dc4080e7          	jalr	-572(ra) # 5b5c <fork>
    1da0:	84aa                	mv	s1,a0
    if (pid < 0)
    1da2:	02054f63          	bltz	a0,1de0 <createdelete+0x68>
    if (pid == 0)
    1da6:	c939                	beqz	a0,1dfc <createdelete+0x84>
  for (pi = 0; pi < NCHILD; pi++)
    1da8:	2905                	addiw	s2,s2,1
    1daa:	ff3917e3          	bne	s2,s3,1d98 <createdelete+0x20>
    1dae:	4491                	li	s1,4
    wait(&xstatus);
    1db0:	f7c40513          	addi	a0,s0,-132
    1db4:	00004097          	auipc	ra,0x4
    1db8:	db8080e7          	jalr	-584(ra) # 5b6c <wait>
    if (xstatus != 0)
    1dbc:	f7c42903          	lw	s2,-132(s0)
    1dc0:	0e091263          	bnez	s2,1ea4 <createdelete+0x12c>
  for (pi = 0; pi < NCHILD; pi++)
    1dc4:	34fd                	addiw	s1,s1,-1
    1dc6:	f4ed                	bnez	s1,1db0 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1dc8:	f8040123          	sb	zero,-126(s0)
    1dcc:	03000993          	li	s3,48
    1dd0:	5a7d                	li	s4,-1
    1dd2:	07000c13          	li	s8,112
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1dd6:	4b21                	li	s6,8
      if ((i == 0 || i >= N / 2) && fd < 0)
    1dd8:	4ba5                	li	s7,9
    for (pi = 0; pi < NCHILD; pi++)
    1dda:	07400a93          	li	s5,116
    1dde:	a29d                	j	1f44 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1de0:	85e6                	mv	a1,s9
    1de2:	00005517          	auipc	a0,0x5
    1de6:	f8650513          	addi	a0,a0,-122 # 6d68 <malloc+0xdb2>
    1dea:	00004097          	auipc	ra,0x4
    1dee:	114080e7          	jalr	276(ra) # 5efe <printf>
      exit(1);
    1df2:	4505                	li	a0,1
    1df4:	00004097          	auipc	ra,0x4
    1df8:	d70080e7          	jalr	-656(ra) # 5b64 <exit>
      name[0] = 'p' + pi;
    1dfc:	0709091b          	addiw	s2,s2,112
    1e00:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1e04:	f8040123          	sb	zero,-126(s0)
      for (i = 0; i < N; i++)
    1e08:	4951                	li	s2,20
    1e0a:	a015                	j	1e2e <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1e0c:	85e6                	mv	a1,s9
    1e0e:	00005517          	auipc	a0,0x5
    1e12:	bea50513          	addi	a0,a0,-1046 # 69f8 <malloc+0xa42>
    1e16:	00004097          	auipc	ra,0x4
    1e1a:	0e8080e7          	jalr	232(ra) # 5efe <printf>
          exit(1);
    1e1e:	4505                	li	a0,1
    1e20:	00004097          	auipc	ra,0x4
    1e24:	d44080e7          	jalr	-700(ra) # 5b64 <exit>
      for (i = 0; i < N; i++)
    1e28:	2485                	addiw	s1,s1,1
    1e2a:	07248863          	beq	s1,s2,1e9a <createdelete+0x122>
        name[1] = '0' + i;
    1e2e:	0304879b          	addiw	a5,s1,48
    1e32:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1e36:	20200593          	li	a1,514
    1e3a:	f8040513          	addi	a0,s0,-128
    1e3e:	00004097          	auipc	ra,0x4
    1e42:	d66080e7          	jalr	-666(ra) # 5ba4 <open>
        if (fd < 0)
    1e46:	fc0543e3          	bltz	a0,1e0c <createdelete+0x94>
        close(fd);
    1e4a:	00004097          	auipc	ra,0x4
    1e4e:	d42080e7          	jalr	-702(ra) # 5b8c <close>
        if (i > 0 && (i % 2) == 0)
    1e52:	fc905be3          	blez	s1,1e28 <createdelete+0xb0>
    1e56:	0014f793          	andi	a5,s1,1
    1e5a:	f7f9                	bnez	a5,1e28 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1e5c:	01f4d79b          	srliw	a5,s1,0x1f
    1e60:	9fa5                	addw	a5,a5,s1
    1e62:	4017d79b          	sraiw	a5,a5,0x1
    1e66:	0307879b          	addiw	a5,a5,48
    1e6a:	f8f400a3          	sb	a5,-127(s0)
          if (unlink(name) < 0)
    1e6e:	f8040513          	addi	a0,s0,-128
    1e72:	00004097          	auipc	ra,0x4
    1e76:	d42080e7          	jalr	-702(ra) # 5bb4 <unlink>
    1e7a:	fa0557e3          	bgez	a0,1e28 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1e7e:	85e6                	mv	a1,s9
    1e80:	00005517          	auipc	a0,0x5
    1e84:	cd050513          	addi	a0,a0,-816 # 6b50 <malloc+0xb9a>
    1e88:	00004097          	auipc	ra,0x4
    1e8c:	076080e7          	jalr	118(ra) # 5efe <printf>
            exit(1);
    1e90:	4505                	li	a0,1
    1e92:	00004097          	auipc	ra,0x4
    1e96:	cd2080e7          	jalr	-814(ra) # 5b64 <exit>
      exit(0);
    1e9a:	4501                	li	a0,0
    1e9c:	00004097          	auipc	ra,0x4
    1ea0:	cc8080e7          	jalr	-824(ra) # 5b64 <exit>
      exit(1);
    1ea4:	4505                	li	a0,1
    1ea6:	00004097          	auipc	ra,0x4
    1eaa:	cbe080e7          	jalr	-834(ra) # 5b64 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1eae:	f8040613          	addi	a2,s0,-128
    1eb2:	85e6                	mv	a1,s9
    1eb4:	00005517          	auipc	a0,0x5
    1eb8:	cb450513          	addi	a0,a0,-844 # 6b68 <malloc+0xbb2>
    1ebc:	00004097          	auipc	ra,0x4
    1ec0:	042080e7          	jalr	66(ra) # 5efe <printf>
        exit(1);
    1ec4:	4505                	li	a0,1
    1ec6:	00004097          	auipc	ra,0x4
    1eca:	c9e080e7          	jalr	-866(ra) # 5b64 <exit>
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1ece:	054b7163          	bgeu	s6,s4,1f10 <createdelete+0x198>
      if (fd >= 0)
    1ed2:	02055a63          	bgez	a0,1f06 <createdelete+0x18e>
    for (pi = 0; pi < NCHILD; pi++)
    1ed6:	2485                	addiw	s1,s1,1
    1ed8:	0ff4f493          	zext.b	s1,s1
    1edc:	05548c63          	beq	s1,s5,1f34 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1ee0:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1ee4:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1ee8:	4581                	li	a1,0
    1eea:	f8040513          	addi	a0,s0,-128
    1eee:	00004097          	auipc	ra,0x4
    1ef2:	cb6080e7          	jalr	-842(ra) # 5ba4 <open>
      if ((i == 0 || i >= N / 2) && fd < 0)
    1ef6:	00090463          	beqz	s2,1efe <createdelete+0x186>
    1efa:	fd2bdae3          	bge	s7,s2,1ece <createdelete+0x156>
    1efe:	fa0548e3          	bltz	a0,1eae <createdelete+0x136>
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1f02:	014b7963          	bgeu	s6,s4,1f14 <createdelete+0x19c>
        close(fd);
    1f06:	00004097          	auipc	ra,0x4
    1f0a:	c86080e7          	jalr	-890(ra) # 5b8c <close>
    1f0e:	b7e1                	j	1ed6 <createdelete+0x15e>
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1f10:	fc0543e3          	bltz	a0,1ed6 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1f14:	f8040613          	addi	a2,s0,-128
    1f18:	85e6                	mv	a1,s9
    1f1a:	00005517          	auipc	a0,0x5
    1f1e:	c7650513          	addi	a0,a0,-906 # 6b90 <malloc+0xbda>
    1f22:	00004097          	auipc	ra,0x4
    1f26:	fdc080e7          	jalr	-36(ra) # 5efe <printf>
        exit(1);
    1f2a:	4505                	li	a0,1
    1f2c:	00004097          	auipc	ra,0x4
    1f30:	c38080e7          	jalr	-968(ra) # 5b64 <exit>
  for (i = 0; i < N; i++)
    1f34:	2905                	addiw	s2,s2,1
    1f36:	2a05                	addiw	s4,s4,1
    1f38:	2985                	addiw	s3,s3,1
    1f3a:	0ff9f993          	zext.b	s3,s3
    1f3e:	47d1                	li	a5,20
    1f40:	02f90a63          	beq	s2,a5,1f74 <createdelete+0x1fc>
    for (pi = 0; pi < NCHILD; pi++)
    1f44:	84e2                	mv	s1,s8
    1f46:	bf69                	j	1ee0 <createdelete+0x168>
  for (i = 0; i < N; i++)
    1f48:	2905                	addiw	s2,s2,1
    1f4a:	0ff97913          	zext.b	s2,s2
    1f4e:	2985                	addiw	s3,s3,1
    1f50:	0ff9f993          	zext.b	s3,s3
    1f54:	03490863          	beq	s2,s4,1f84 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1f58:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1f5a:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1f5e:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1f62:	f8040513          	addi	a0,s0,-128
    1f66:	00004097          	auipc	ra,0x4
    1f6a:	c4e080e7          	jalr	-946(ra) # 5bb4 <unlink>
    for (pi = 0; pi < NCHILD; pi++)
    1f6e:	34fd                	addiw	s1,s1,-1
    1f70:	f4ed                	bnez	s1,1f5a <createdelete+0x1e2>
    1f72:	bfd9                	j	1f48 <createdelete+0x1d0>
    1f74:	03000993          	li	s3,48
    1f78:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1f7c:	4a91                	li	s5,4
  for (i = 0; i < N; i++)
    1f7e:	08400a13          	li	s4,132
    1f82:	bfd9                	j	1f58 <createdelete+0x1e0>
}
    1f84:	60aa                	ld	ra,136(sp)
    1f86:	640a                	ld	s0,128(sp)
    1f88:	74e6                	ld	s1,120(sp)
    1f8a:	7946                	ld	s2,112(sp)
    1f8c:	79a6                	ld	s3,104(sp)
    1f8e:	7a06                	ld	s4,96(sp)
    1f90:	6ae6                	ld	s5,88(sp)
    1f92:	6b46                	ld	s6,80(sp)
    1f94:	6ba6                	ld	s7,72(sp)
    1f96:	6c06                	ld	s8,64(sp)
    1f98:	7ce2                	ld	s9,56(sp)
    1f9a:	6149                	addi	sp,sp,144
    1f9c:	8082                	ret

0000000000001f9e <linkunlink>:
{
    1f9e:	711d                	addi	sp,sp,-96
    1fa0:	ec86                	sd	ra,88(sp)
    1fa2:	e8a2                	sd	s0,80(sp)
    1fa4:	e4a6                	sd	s1,72(sp)
    1fa6:	e0ca                	sd	s2,64(sp)
    1fa8:	fc4e                	sd	s3,56(sp)
    1faa:	f852                	sd	s4,48(sp)
    1fac:	f456                	sd	s5,40(sp)
    1fae:	f05a                	sd	s6,32(sp)
    1fb0:	ec5e                	sd	s7,24(sp)
    1fb2:	e862                	sd	s8,16(sp)
    1fb4:	e466                	sd	s9,8(sp)
    1fb6:	1080                	addi	s0,sp,96
    1fb8:	84aa                	mv	s1,a0
  unlink("x");
    1fba:	00004517          	auipc	a0,0x4
    1fbe:	18e50513          	addi	a0,a0,398 # 6148 <malloc+0x192>
    1fc2:	00004097          	auipc	ra,0x4
    1fc6:	bf2080e7          	jalr	-1038(ra) # 5bb4 <unlink>
  pid = fork();
    1fca:	00004097          	auipc	ra,0x4
    1fce:	b92080e7          	jalr	-1134(ra) # 5b5c <fork>
  if (pid < 0)
    1fd2:	02054b63          	bltz	a0,2008 <linkunlink+0x6a>
    1fd6:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1fd8:	4c85                	li	s9,1
    1fda:	e119                	bnez	a0,1fe0 <linkunlink+0x42>
    1fdc:	06100c93          	li	s9,97
    1fe0:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1fe4:	41c659b7          	lui	s3,0x41c65
    1fe8:	e6d9899b          	addiw	s3,s3,-403 # 41c64e6d <base+0x41c551f5>
    1fec:	690d                	lui	s2,0x3
    1fee:	0399091b          	addiw	s2,s2,57 # 3039 <fourteen+0x77>
    if ((x % 3) == 0)
    1ff2:	4a0d                	li	s4,3
    else if ((x % 3) == 1)
    1ff4:	4b05                	li	s6,1
      unlink("x");
    1ff6:	00004a97          	auipc	s5,0x4
    1ffa:	152a8a93          	addi	s5,s5,338 # 6148 <malloc+0x192>
      link("cat", "x");
    1ffe:	00005b97          	auipc	s7,0x5
    2002:	bbab8b93          	addi	s7,s7,-1094 # 6bb8 <malloc+0xc02>
    2006:	a825                	j	203e <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    2008:	85a6                	mv	a1,s1
    200a:	00005517          	auipc	a0,0x5
    200e:	95650513          	addi	a0,a0,-1706 # 6960 <malloc+0x9aa>
    2012:	00004097          	auipc	ra,0x4
    2016:	eec080e7          	jalr	-276(ra) # 5efe <printf>
    exit(1);
    201a:	4505                	li	a0,1
    201c:	00004097          	auipc	ra,0x4
    2020:	b48080e7          	jalr	-1208(ra) # 5b64 <exit>
      close(open("x", O_RDWR | O_CREATE));
    2024:	20200593          	li	a1,514
    2028:	8556                	mv	a0,s5
    202a:	00004097          	auipc	ra,0x4
    202e:	b7a080e7          	jalr	-1158(ra) # 5ba4 <open>
    2032:	00004097          	auipc	ra,0x4
    2036:	b5a080e7          	jalr	-1190(ra) # 5b8c <close>
  for (i = 0; i < 100; i++)
    203a:	34fd                	addiw	s1,s1,-1
    203c:	c88d                	beqz	s1,206e <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    203e:	033c87bb          	mulw	a5,s9,s3
    2042:	012787bb          	addw	a5,a5,s2
    2046:	00078c9b          	sext.w	s9,a5
    if ((x % 3) == 0)
    204a:	0347f7bb          	remuw	a5,a5,s4
    204e:	dbf9                	beqz	a5,2024 <linkunlink+0x86>
    else if ((x % 3) == 1)
    2050:	01678863          	beq	a5,s6,2060 <linkunlink+0xc2>
      unlink("x");
    2054:	8556                	mv	a0,s5
    2056:	00004097          	auipc	ra,0x4
    205a:	b5e080e7          	jalr	-1186(ra) # 5bb4 <unlink>
    205e:	bff1                	j	203a <linkunlink+0x9c>
      link("cat", "x");
    2060:	85d6                	mv	a1,s5
    2062:	855e                	mv	a0,s7
    2064:	00004097          	auipc	ra,0x4
    2068:	b60080e7          	jalr	-1184(ra) # 5bc4 <link>
    206c:	b7f9                	j	203a <linkunlink+0x9c>
  if (pid)
    206e:	020c0463          	beqz	s8,2096 <linkunlink+0xf8>
    wait(0);
    2072:	4501                	li	a0,0
    2074:	00004097          	auipc	ra,0x4
    2078:	af8080e7          	jalr	-1288(ra) # 5b6c <wait>
}
    207c:	60e6                	ld	ra,88(sp)
    207e:	6446                	ld	s0,80(sp)
    2080:	64a6                	ld	s1,72(sp)
    2082:	6906                	ld	s2,64(sp)
    2084:	79e2                	ld	s3,56(sp)
    2086:	7a42                	ld	s4,48(sp)
    2088:	7aa2                	ld	s5,40(sp)
    208a:	7b02                	ld	s6,32(sp)
    208c:	6be2                	ld	s7,24(sp)
    208e:	6c42                	ld	s8,16(sp)
    2090:	6ca2                	ld	s9,8(sp)
    2092:	6125                	addi	sp,sp,96
    2094:	8082                	ret
    exit(0);
    2096:	4501                	li	a0,0
    2098:	00004097          	auipc	ra,0x4
    209c:	acc080e7          	jalr	-1332(ra) # 5b64 <exit>

00000000000020a0 <forktest>:
{
    20a0:	7179                	addi	sp,sp,-48
    20a2:	f406                	sd	ra,40(sp)
    20a4:	f022                	sd	s0,32(sp)
    20a6:	ec26                	sd	s1,24(sp)
    20a8:	e84a                	sd	s2,16(sp)
    20aa:	e44e                	sd	s3,8(sp)
    20ac:	1800                	addi	s0,sp,48
    20ae:	89aa                	mv	s3,a0
  for (n = 0; n < N; n++)
    20b0:	4481                	li	s1,0
    20b2:	3e800913          	li	s2,1000
    pid = fork();
    20b6:	00004097          	auipc	ra,0x4
    20ba:	aa6080e7          	jalr	-1370(ra) # 5b5c <fork>
    if (pid < 0)
    20be:	02054863          	bltz	a0,20ee <forktest+0x4e>
    if (pid == 0)
    20c2:	c115                	beqz	a0,20e6 <forktest+0x46>
  for (n = 0; n < N; n++)
    20c4:	2485                	addiw	s1,s1,1
    20c6:	ff2498e3          	bne	s1,s2,20b6 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    20ca:	85ce                	mv	a1,s3
    20cc:	00005517          	auipc	a0,0x5
    20d0:	b0c50513          	addi	a0,a0,-1268 # 6bd8 <malloc+0xc22>
    20d4:	00004097          	auipc	ra,0x4
    20d8:	e2a080e7          	jalr	-470(ra) # 5efe <printf>
    exit(1);
    20dc:	4505                	li	a0,1
    20de:	00004097          	auipc	ra,0x4
    20e2:	a86080e7          	jalr	-1402(ra) # 5b64 <exit>
      exit(0);
    20e6:	00004097          	auipc	ra,0x4
    20ea:	a7e080e7          	jalr	-1410(ra) # 5b64 <exit>
  if (n == 0)
    20ee:	cc9d                	beqz	s1,212c <forktest+0x8c>
  if (n == N)
    20f0:	3e800793          	li	a5,1000
    20f4:	fcf48be3          	beq	s1,a5,20ca <forktest+0x2a>
  for (; n > 0; n--)
    20f8:	00905b63          	blez	s1,210e <forktest+0x6e>
    if (wait(0) < 0)
    20fc:	4501                	li	a0,0
    20fe:	00004097          	auipc	ra,0x4
    2102:	a6e080e7          	jalr	-1426(ra) # 5b6c <wait>
    2106:	04054163          	bltz	a0,2148 <forktest+0xa8>
  for (; n > 0; n--)
    210a:	34fd                	addiw	s1,s1,-1
    210c:	f8e5                	bnez	s1,20fc <forktest+0x5c>
  if (wait(0) != -1)
    210e:	4501                	li	a0,0
    2110:	00004097          	auipc	ra,0x4
    2114:	a5c080e7          	jalr	-1444(ra) # 5b6c <wait>
    2118:	57fd                	li	a5,-1
    211a:	04f51563          	bne	a0,a5,2164 <forktest+0xc4>
}
    211e:	70a2                	ld	ra,40(sp)
    2120:	7402                	ld	s0,32(sp)
    2122:	64e2                	ld	s1,24(sp)
    2124:	6942                	ld	s2,16(sp)
    2126:	69a2                	ld	s3,8(sp)
    2128:	6145                	addi	sp,sp,48
    212a:	8082                	ret
    printf("%s: no fork at all!\n", s);
    212c:	85ce                	mv	a1,s3
    212e:	00005517          	auipc	a0,0x5
    2132:	a9250513          	addi	a0,a0,-1390 # 6bc0 <malloc+0xc0a>
    2136:	00004097          	auipc	ra,0x4
    213a:	dc8080e7          	jalr	-568(ra) # 5efe <printf>
    exit(1);
    213e:	4505                	li	a0,1
    2140:	00004097          	auipc	ra,0x4
    2144:	a24080e7          	jalr	-1500(ra) # 5b64 <exit>
      printf("%s: wait stopped early\n", s);
    2148:	85ce                	mv	a1,s3
    214a:	00005517          	auipc	a0,0x5
    214e:	ab650513          	addi	a0,a0,-1354 # 6c00 <malloc+0xc4a>
    2152:	00004097          	auipc	ra,0x4
    2156:	dac080e7          	jalr	-596(ra) # 5efe <printf>
      exit(1);
    215a:	4505                	li	a0,1
    215c:	00004097          	auipc	ra,0x4
    2160:	a08080e7          	jalr	-1528(ra) # 5b64 <exit>
    printf("%s: wait got too many\n", s);
    2164:	85ce                	mv	a1,s3
    2166:	00005517          	auipc	a0,0x5
    216a:	ab250513          	addi	a0,a0,-1358 # 6c18 <malloc+0xc62>
    216e:	00004097          	auipc	ra,0x4
    2172:	d90080e7          	jalr	-624(ra) # 5efe <printf>
    exit(1);
    2176:	4505                	li	a0,1
    2178:	00004097          	auipc	ra,0x4
    217c:	9ec080e7          	jalr	-1556(ra) # 5b64 <exit>

0000000000002180 <kernmem>:
{
    2180:	715d                	addi	sp,sp,-80
    2182:	e486                	sd	ra,72(sp)
    2184:	e0a2                	sd	s0,64(sp)
    2186:	fc26                	sd	s1,56(sp)
    2188:	f84a                	sd	s2,48(sp)
    218a:	f44e                	sd	s3,40(sp)
    218c:	f052                	sd	s4,32(sp)
    218e:	ec56                	sd	s5,24(sp)
    2190:	0880                	addi	s0,sp,80
    2192:	8a2a                	mv	s4,a0
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000)
    2194:	4485                	li	s1,1
    2196:	04fe                	slli	s1,s1,0x1f
    if (xstatus != -1) // did kernel kill child?
    2198:	5afd                	li	s5,-1
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000)
    219a:	69b1                	lui	s3,0xc
    219c:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1de8>
    21a0:	1003d937          	lui	s2,0x1003d
    21a4:	090e                	slli	s2,s2,0x3
    21a6:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d808>
    pid = fork();
    21aa:	00004097          	auipc	ra,0x4
    21ae:	9b2080e7          	jalr	-1614(ra) # 5b5c <fork>
    if (pid < 0)
    21b2:	02054963          	bltz	a0,21e4 <kernmem+0x64>
    if (pid == 0)
    21b6:	c529                	beqz	a0,2200 <kernmem+0x80>
    wait(&xstatus);
    21b8:	fbc40513          	addi	a0,s0,-68
    21bc:	00004097          	auipc	ra,0x4
    21c0:	9b0080e7          	jalr	-1616(ra) # 5b6c <wait>
    if (xstatus != -1) // did kernel kill child?
    21c4:	fbc42783          	lw	a5,-68(s0)
    21c8:	05579d63          	bne	a5,s5,2222 <kernmem+0xa2>
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000)
    21cc:	94ce                	add	s1,s1,s3
    21ce:	fd249ee3          	bne	s1,s2,21aa <kernmem+0x2a>
}
    21d2:	60a6                	ld	ra,72(sp)
    21d4:	6406                	ld	s0,64(sp)
    21d6:	74e2                	ld	s1,56(sp)
    21d8:	7942                	ld	s2,48(sp)
    21da:	79a2                	ld	s3,40(sp)
    21dc:	7a02                	ld	s4,32(sp)
    21de:	6ae2                	ld	s5,24(sp)
    21e0:	6161                	addi	sp,sp,80
    21e2:	8082                	ret
      printf("%s: fork failed\n", s);
    21e4:	85d2                	mv	a1,s4
    21e6:	00004517          	auipc	a0,0x4
    21ea:	77a50513          	addi	a0,a0,1914 # 6960 <malloc+0x9aa>
    21ee:	00004097          	auipc	ra,0x4
    21f2:	d10080e7          	jalr	-752(ra) # 5efe <printf>
      exit(1);
    21f6:	4505                	li	a0,1
    21f8:	00004097          	auipc	ra,0x4
    21fc:	96c080e7          	jalr	-1684(ra) # 5b64 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    2200:	0004c683          	lbu	a3,0(s1)
    2204:	8626                	mv	a2,s1
    2206:	85d2                	mv	a1,s4
    2208:	00005517          	auipc	a0,0x5
    220c:	a2850513          	addi	a0,a0,-1496 # 6c30 <malloc+0xc7a>
    2210:	00004097          	auipc	ra,0x4
    2214:	cee080e7          	jalr	-786(ra) # 5efe <printf>
      exit(1);
    2218:	4505                	li	a0,1
    221a:	00004097          	auipc	ra,0x4
    221e:	94a080e7          	jalr	-1718(ra) # 5b64 <exit>
      exit(1);
    2222:	4505                	li	a0,1
    2224:	00004097          	auipc	ra,0x4
    2228:	940080e7          	jalr	-1728(ra) # 5b64 <exit>

000000000000222c <MAXVAplus>:
{
    222c:	7179                	addi	sp,sp,-48
    222e:	f406                	sd	ra,40(sp)
    2230:	f022                	sd	s0,32(sp)
    2232:	ec26                	sd	s1,24(sp)
    2234:	e84a                	sd	s2,16(sp)
    2236:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    2238:	4785                	li	a5,1
    223a:	179a                	slli	a5,a5,0x26
    223c:	fcf43c23          	sd	a5,-40(s0)
  for (; a != 0; a <<= 1)
    2240:	fd843783          	ld	a5,-40(s0)
    2244:	cf85                	beqz	a5,227c <MAXVAplus+0x50>
    2246:	892a                	mv	s2,a0
    if (xstatus != -1) // did kernel kill child?
    2248:	54fd                	li	s1,-1
    pid = fork();
    224a:	00004097          	auipc	ra,0x4
    224e:	912080e7          	jalr	-1774(ra) # 5b5c <fork>
    if (pid < 0)
    2252:	02054b63          	bltz	a0,2288 <MAXVAplus+0x5c>
    if (pid == 0)
    2256:	c539                	beqz	a0,22a4 <MAXVAplus+0x78>
    wait(&xstatus);
    2258:	fd440513          	addi	a0,s0,-44
    225c:	00004097          	auipc	ra,0x4
    2260:	910080e7          	jalr	-1776(ra) # 5b6c <wait>
    if (xstatus != -1) // did kernel kill child?
    2264:	fd442783          	lw	a5,-44(s0)
    2268:	06979463          	bne	a5,s1,22d0 <MAXVAplus+0xa4>
  for (; a != 0; a <<= 1)
    226c:	fd843783          	ld	a5,-40(s0)
    2270:	0786                	slli	a5,a5,0x1
    2272:	fcf43c23          	sd	a5,-40(s0)
    2276:	fd843783          	ld	a5,-40(s0)
    227a:	fbe1                	bnez	a5,224a <MAXVAplus+0x1e>
}
    227c:	70a2                	ld	ra,40(sp)
    227e:	7402                	ld	s0,32(sp)
    2280:	64e2                	ld	s1,24(sp)
    2282:	6942                	ld	s2,16(sp)
    2284:	6145                	addi	sp,sp,48
    2286:	8082                	ret
      printf("%s: fork failed\n", s);
    2288:	85ca                	mv	a1,s2
    228a:	00004517          	auipc	a0,0x4
    228e:	6d650513          	addi	a0,a0,1750 # 6960 <malloc+0x9aa>
    2292:	00004097          	auipc	ra,0x4
    2296:	c6c080e7          	jalr	-916(ra) # 5efe <printf>
      exit(1);
    229a:	4505                	li	a0,1
    229c:	00004097          	auipc	ra,0x4
    22a0:	8c8080e7          	jalr	-1848(ra) # 5b64 <exit>
      *(char *)a = 99;
    22a4:	fd843783          	ld	a5,-40(s0)
    22a8:	06300713          	li	a4,99
    22ac:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    22b0:	fd843603          	ld	a2,-40(s0)
    22b4:	85ca                	mv	a1,s2
    22b6:	00005517          	auipc	a0,0x5
    22ba:	99a50513          	addi	a0,a0,-1638 # 6c50 <malloc+0xc9a>
    22be:	00004097          	auipc	ra,0x4
    22c2:	c40080e7          	jalr	-960(ra) # 5efe <printf>
      exit(1);
    22c6:	4505                	li	a0,1
    22c8:	00004097          	auipc	ra,0x4
    22cc:	89c080e7          	jalr	-1892(ra) # 5b64 <exit>
      exit(1);
    22d0:	4505                	li	a0,1
    22d2:	00004097          	auipc	ra,0x4
    22d6:	892080e7          	jalr	-1902(ra) # 5b64 <exit>

00000000000022da <bigargtest>:
{
    22da:	7179                	addi	sp,sp,-48
    22dc:	f406                	sd	ra,40(sp)
    22de:	f022                	sd	s0,32(sp)
    22e0:	ec26                	sd	s1,24(sp)
    22e2:	1800                	addi	s0,sp,48
    22e4:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    22e6:	00005517          	auipc	a0,0x5
    22ea:	98250513          	addi	a0,a0,-1662 # 6c68 <malloc+0xcb2>
    22ee:	00004097          	auipc	ra,0x4
    22f2:	8c6080e7          	jalr	-1850(ra) # 5bb4 <unlink>
  pid = fork();
    22f6:	00004097          	auipc	ra,0x4
    22fa:	866080e7          	jalr	-1946(ra) # 5b5c <fork>
  if (pid == 0)
    22fe:	c121                	beqz	a0,233e <bigargtest+0x64>
  else if (pid < 0)
    2300:	0a054063          	bltz	a0,23a0 <bigargtest+0xc6>
  wait(&xstatus);
    2304:	fdc40513          	addi	a0,s0,-36
    2308:	00004097          	auipc	ra,0x4
    230c:	864080e7          	jalr	-1948(ra) # 5b6c <wait>
  if (xstatus != 0)
    2310:	fdc42503          	lw	a0,-36(s0)
    2314:	e545                	bnez	a0,23bc <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    2316:	4581                	li	a1,0
    2318:	00005517          	auipc	a0,0x5
    231c:	95050513          	addi	a0,a0,-1712 # 6c68 <malloc+0xcb2>
    2320:	00004097          	auipc	ra,0x4
    2324:	884080e7          	jalr	-1916(ra) # 5ba4 <open>
  if (fd < 0)
    2328:	08054e63          	bltz	a0,23c4 <bigargtest+0xea>
  close(fd);
    232c:	00004097          	auipc	ra,0x4
    2330:	860080e7          	jalr	-1952(ra) # 5b8c <close>
}
    2334:	70a2                	ld	ra,40(sp)
    2336:	7402                	ld	s0,32(sp)
    2338:	64e2                	ld	s1,24(sp)
    233a:	6145                	addi	sp,sp,48
    233c:	8082                	ret
    233e:	00007797          	auipc	a5,0x7
    2342:	12278793          	addi	a5,a5,290 # 9460 <args.1>
    2346:	00007697          	auipc	a3,0x7
    234a:	21268693          	addi	a3,a3,530 # 9558 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    234e:	00005717          	auipc	a4,0x5
    2352:	92a70713          	addi	a4,a4,-1750 # 6c78 <malloc+0xcc2>
    2356:	e398                	sd	a4,0(a5)
    for (i = 0; i < MAXARG - 1; i++)
    2358:	07a1                	addi	a5,a5,8
    235a:	fed79ee3          	bne	a5,a3,2356 <bigargtest+0x7c>
    args[MAXARG - 1] = 0;
    235e:	00007597          	auipc	a1,0x7
    2362:	10258593          	addi	a1,a1,258 # 9460 <args.1>
    2366:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    236a:	00004517          	auipc	a0,0x4
    236e:	d6e50513          	addi	a0,a0,-658 # 60d8 <malloc+0x122>
    2372:	00004097          	auipc	ra,0x4
    2376:	82a080e7          	jalr	-2006(ra) # 5b9c <exec>
    fd = open("bigarg-ok", O_CREATE);
    237a:	20000593          	li	a1,512
    237e:	00005517          	auipc	a0,0x5
    2382:	8ea50513          	addi	a0,a0,-1814 # 6c68 <malloc+0xcb2>
    2386:	00004097          	auipc	ra,0x4
    238a:	81e080e7          	jalr	-2018(ra) # 5ba4 <open>
    close(fd);
    238e:	00003097          	auipc	ra,0x3
    2392:	7fe080e7          	jalr	2046(ra) # 5b8c <close>
    exit(0);
    2396:	4501                	li	a0,0
    2398:	00003097          	auipc	ra,0x3
    239c:	7cc080e7          	jalr	1996(ra) # 5b64 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    23a0:	85a6                	mv	a1,s1
    23a2:	00005517          	auipc	a0,0x5
    23a6:	9b650513          	addi	a0,a0,-1610 # 6d58 <malloc+0xda2>
    23aa:	00004097          	auipc	ra,0x4
    23ae:	b54080e7          	jalr	-1196(ra) # 5efe <printf>
    exit(1);
    23b2:	4505                	li	a0,1
    23b4:	00003097          	auipc	ra,0x3
    23b8:	7b0080e7          	jalr	1968(ra) # 5b64 <exit>
    exit(xstatus);
    23bc:	00003097          	auipc	ra,0x3
    23c0:	7a8080e7          	jalr	1960(ra) # 5b64 <exit>
    printf("%s: bigarg test failed!\n", s);
    23c4:	85a6                	mv	a1,s1
    23c6:	00005517          	auipc	a0,0x5
    23ca:	9b250513          	addi	a0,a0,-1614 # 6d78 <malloc+0xdc2>
    23ce:	00004097          	auipc	ra,0x4
    23d2:	b30080e7          	jalr	-1232(ra) # 5efe <printf>
    exit(1);
    23d6:	4505                	li	a0,1
    23d8:	00003097          	auipc	ra,0x3
    23dc:	78c080e7          	jalr	1932(ra) # 5b64 <exit>

00000000000023e0 <stacktest>:
{
    23e0:	7179                	addi	sp,sp,-48
    23e2:	f406                	sd	ra,40(sp)
    23e4:	f022                	sd	s0,32(sp)
    23e6:	ec26                	sd	s1,24(sp)
    23e8:	1800                	addi	s0,sp,48
    23ea:	84aa                	mv	s1,a0
  pid = fork();
    23ec:	00003097          	auipc	ra,0x3
    23f0:	770080e7          	jalr	1904(ra) # 5b5c <fork>
  if (pid == 0)
    23f4:	c115                	beqz	a0,2418 <stacktest+0x38>
  else if (pid < 0)
    23f6:	04054463          	bltz	a0,243e <stacktest+0x5e>
  wait(&xstatus);
    23fa:	fdc40513          	addi	a0,s0,-36
    23fe:	00003097          	auipc	ra,0x3
    2402:	76e080e7          	jalr	1902(ra) # 5b6c <wait>
  if (xstatus == -1) // kernel killed child?
    2406:	fdc42503          	lw	a0,-36(s0)
    240a:	57fd                	li	a5,-1
    240c:	04f50763          	beq	a0,a5,245a <stacktest+0x7a>
    exit(xstatus);
    2410:	00003097          	auipc	ra,0x3
    2414:	754080e7          	jalr	1876(ra) # 5b64 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp"
    2418:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    241a:	77fd                	lui	a5,0xfffff
    241c:	97ba                	add	a5,a5,a4
    241e:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    2422:	85a6                	mv	a1,s1
    2424:	00005517          	auipc	a0,0x5
    2428:	97450513          	addi	a0,a0,-1676 # 6d98 <malloc+0xde2>
    242c:	00004097          	auipc	ra,0x4
    2430:	ad2080e7          	jalr	-1326(ra) # 5efe <printf>
    exit(1);
    2434:	4505                	li	a0,1
    2436:	00003097          	auipc	ra,0x3
    243a:	72e080e7          	jalr	1838(ra) # 5b64 <exit>
    printf("%s: fork failed\n", s);
    243e:	85a6                	mv	a1,s1
    2440:	00004517          	auipc	a0,0x4
    2444:	52050513          	addi	a0,a0,1312 # 6960 <malloc+0x9aa>
    2448:	00004097          	auipc	ra,0x4
    244c:	ab6080e7          	jalr	-1354(ra) # 5efe <printf>
    exit(1);
    2450:	4505                	li	a0,1
    2452:	00003097          	auipc	ra,0x3
    2456:	712080e7          	jalr	1810(ra) # 5b64 <exit>
    exit(0);
    245a:	4501                	li	a0,0
    245c:	00003097          	auipc	ra,0x3
    2460:	708080e7          	jalr	1800(ra) # 5b64 <exit>

0000000000002464 <manywrites>:
{
    2464:	711d                	addi	sp,sp,-96
    2466:	ec86                	sd	ra,88(sp)
    2468:	e8a2                	sd	s0,80(sp)
    246a:	e4a6                	sd	s1,72(sp)
    246c:	e0ca                	sd	s2,64(sp)
    246e:	fc4e                	sd	s3,56(sp)
    2470:	f852                	sd	s4,48(sp)
    2472:	f456                	sd	s5,40(sp)
    2474:	f05a                	sd	s6,32(sp)
    2476:	ec5e                	sd	s7,24(sp)
    2478:	1080                	addi	s0,sp,96
    247a:	8aaa                	mv	s5,a0
  for (int ci = 0; ci < nchildren; ci++)
    247c:	4981                	li	s3,0
    247e:	4911                	li	s2,4
    int pid = fork();
    2480:	00003097          	auipc	ra,0x3
    2484:	6dc080e7          	jalr	1756(ra) # 5b5c <fork>
    2488:	84aa                	mv	s1,a0
    if (pid < 0)
    248a:	02054963          	bltz	a0,24bc <manywrites+0x58>
    if (pid == 0)
    248e:	c521                	beqz	a0,24d6 <manywrites+0x72>
  for (int ci = 0; ci < nchildren; ci++)
    2490:	2985                	addiw	s3,s3,1
    2492:	ff2997e3          	bne	s3,s2,2480 <manywrites+0x1c>
    2496:	4491                	li	s1,4
    int st = 0;
    2498:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    249c:	fa840513          	addi	a0,s0,-88
    24a0:	00003097          	auipc	ra,0x3
    24a4:	6cc080e7          	jalr	1740(ra) # 5b6c <wait>
    if (st != 0)
    24a8:	fa842503          	lw	a0,-88(s0)
    24ac:	ed6d                	bnez	a0,25a6 <manywrites+0x142>
  for (int ci = 0; ci < nchildren; ci++)
    24ae:	34fd                	addiw	s1,s1,-1
    24b0:	f4e5                	bnez	s1,2498 <manywrites+0x34>
  exit(0);
    24b2:	4501                	li	a0,0
    24b4:	00003097          	auipc	ra,0x3
    24b8:	6b0080e7          	jalr	1712(ra) # 5b64 <exit>
      printf("fork failed\n");
    24bc:	00005517          	auipc	a0,0x5
    24c0:	8ac50513          	addi	a0,a0,-1876 # 6d68 <malloc+0xdb2>
    24c4:	00004097          	auipc	ra,0x4
    24c8:	a3a080e7          	jalr	-1478(ra) # 5efe <printf>
      exit(1);
    24cc:	4505                	li	a0,1
    24ce:	00003097          	auipc	ra,0x3
    24d2:	696080e7          	jalr	1686(ra) # 5b64 <exit>
      name[0] = 'b';
    24d6:	06200793          	li	a5,98
    24da:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    24de:	0619879b          	addiw	a5,s3,97
    24e2:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    24e6:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    24ea:	fa840513          	addi	a0,s0,-88
    24ee:	00003097          	auipc	ra,0x3
    24f2:	6c6080e7          	jalr	1734(ra) # 5bb4 <unlink>
    24f6:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    24f8:	0000ab17          	auipc	s6,0xa
    24fc:	780b0b13          	addi	s6,s6,1920 # cc78 <buf>
        for (int i = 0; i < ci + 1; i++)
    2500:	8a26                	mv	s4,s1
    2502:	0209ce63          	bltz	s3,253e <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    2506:	20200593          	li	a1,514
    250a:	fa840513          	addi	a0,s0,-88
    250e:	00003097          	auipc	ra,0x3
    2512:	696080e7          	jalr	1686(ra) # 5ba4 <open>
    2516:	892a                	mv	s2,a0
          if (fd < 0)
    2518:	04054763          	bltz	a0,2566 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    251c:	660d                	lui	a2,0x3
    251e:	85da                	mv	a1,s6
    2520:	00003097          	auipc	ra,0x3
    2524:	664080e7          	jalr	1636(ra) # 5b84 <write>
          if (cc != sz)
    2528:	678d                	lui	a5,0x3
    252a:	04f51e63          	bne	a0,a5,2586 <manywrites+0x122>
          close(fd);
    252e:	854a                	mv	a0,s2
    2530:	00003097          	auipc	ra,0x3
    2534:	65c080e7          	jalr	1628(ra) # 5b8c <close>
        for (int i = 0; i < ci + 1; i++)
    2538:	2a05                	addiw	s4,s4,1
    253a:	fd49d6e3          	bge	s3,s4,2506 <manywrites+0xa2>
        unlink(name);
    253e:	fa840513          	addi	a0,s0,-88
    2542:	00003097          	auipc	ra,0x3
    2546:	672080e7          	jalr	1650(ra) # 5bb4 <unlink>
      for (int iters = 0; iters < howmany; iters++)
    254a:	3bfd                	addiw	s7,s7,-1
    254c:	fa0b9ae3          	bnez	s7,2500 <manywrites+0x9c>
      unlink(name);
    2550:	fa840513          	addi	a0,s0,-88
    2554:	00003097          	auipc	ra,0x3
    2558:	660080e7          	jalr	1632(ra) # 5bb4 <unlink>
      exit(0);
    255c:	4501                	li	a0,0
    255e:	00003097          	auipc	ra,0x3
    2562:	606080e7          	jalr	1542(ra) # 5b64 <exit>
            printf("%s: cannot create %s\n", s, name);
    2566:	fa840613          	addi	a2,s0,-88
    256a:	85d6                	mv	a1,s5
    256c:	00005517          	auipc	a0,0x5
    2570:	85450513          	addi	a0,a0,-1964 # 6dc0 <malloc+0xe0a>
    2574:	00004097          	auipc	ra,0x4
    2578:	98a080e7          	jalr	-1654(ra) # 5efe <printf>
            exit(1);
    257c:	4505                	li	a0,1
    257e:	00003097          	auipc	ra,0x3
    2582:	5e6080e7          	jalr	1510(ra) # 5b64 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    2586:	86aa                	mv	a3,a0
    2588:	660d                	lui	a2,0x3
    258a:	85d6                	mv	a1,s5
    258c:	00004517          	auipc	a0,0x4
    2590:	c1c50513          	addi	a0,a0,-996 # 61a8 <malloc+0x1f2>
    2594:	00004097          	auipc	ra,0x4
    2598:	96a080e7          	jalr	-1686(ra) # 5efe <printf>
            exit(1);
    259c:	4505                	li	a0,1
    259e:	00003097          	auipc	ra,0x3
    25a2:	5c6080e7          	jalr	1478(ra) # 5b64 <exit>
      exit(st);
    25a6:	00003097          	auipc	ra,0x3
    25aa:	5be080e7          	jalr	1470(ra) # 5b64 <exit>

00000000000025ae <copyinstr3>:
{
    25ae:	7179                	addi	sp,sp,-48
    25b0:	f406                	sd	ra,40(sp)
    25b2:	f022                	sd	s0,32(sp)
    25b4:	ec26                	sd	s1,24(sp)
    25b6:	1800                	addi	s0,sp,48
  sbrk(8192);
    25b8:	6509                	lui	a0,0x2
    25ba:	00003097          	auipc	ra,0x3
    25be:	632080e7          	jalr	1586(ra) # 5bec <sbrk>
  uint64 top = (uint64)sbrk(0);
    25c2:	4501                	li	a0,0
    25c4:	00003097          	auipc	ra,0x3
    25c8:	628080e7          	jalr	1576(ra) # 5bec <sbrk>
  if ((top % PGSIZE) != 0)
    25cc:	03451793          	slli	a5,a0,0x34
    25d0:	e3c9                	bnez	a5,2652 <copyinstr3+0xa4>
  top = (uint64)sbrk(0);
    25d2:	4501                	li	a0,0
    25d4:	00003097          	auipc	ra,0x3
    25d8:	618080e7          	jalr	1560(ra) # 5bec <sbrk>
  if (top % PGSIZE)
    25dc:	03451793          	slli	a5,a0,0x34
    25e0:	e3d9                	bnez	a5,2666 <copyinstr3+0xb8>
  char *b = (char *)(top - 1);
    25e2:	fff50493          	addi	s1,a0,-1 # 1fff <linkunlink+0x61>
  *b = 'x';
    25e6:	07800793          	li	a5,120
    25ea:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    25ee:	8526                	mv	a0,s1
    25f0:	00003097          	auipc	ra,0x3
    25f4:	5c4080e7          	jalr	1476(ra) # 5bb4 <unlink>
  if (ret != -1)
    25f8:	57fd                	li	a5,-1
    25fa:	08f51363          	bne	a0,a5,2680 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    25fe:	20100593          	li	a1,513
    2602:	8526                	mv	a0,s1
    2604:	00003097          	auipc	ra,0x3
    2608:	5a0080e7          	jalr	1440(ra) # 5ba4 <open>
  if (fd != -1)
    260c:	57fd                	li	a5,-1
    260e:	08f51863          	bne	a0,a5,269e <copyinstr3+0xf0>
  ret = link(b, b);
    2612:	85a6                	mv	a1,s1
    2614:	8526                	mv	a0,s1
    2616:	00003097          	auipc	ra,0x3
    261a:	5ae080e7          	jalr	1454(ra) # 5bc4 <link>
  if (ret != -1)
    261e:	57fd                	li	a5,-1
    2620:	08f51e63          	bne	a0,a5,26bc <copyinstr3+0x10e>
  char *args[] = {"xx", 0};
    2624:	00005797          	auipc	a5,0x5
    2628:	49478793          	addi	a5,a5,1172 # 7ab8 <malloc+0x1b02>
    262c:	fcf43823          	sd	a5,-48(s0)
    2630:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2634:	fd040593          	addi	a1,s0,-48
    2638:	8526                	mv	a0,s1
    263a:	00003097          	auipc	ra,0x3
    263e:	562080e7          	jalr	1378(ra) # 5b9c <exec>
  if (ret != -1)
    2642:	57fd                	li	a5,-1
    2644:	08f51c63          	bne	a0,a5,26dc <copyinstr3+0x12e>
}
    2648:	70a2                	ld	ra,40(sp)
    264a:	7402                	ld	s0,32(sp)
    264c:	64e2                	ld	s1,24(sp)
    264e:	6145                	addi	sp,sp,48
    2650:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2652:	0347d513          	srli	a0,a5,0x34
    2656:	6785                	lui	a5,0x1
    2658:	40a7853b          	subw	a0,a5,a0
    265c:	00003097          	auipc	ra,0x3
    2660:	590080e7          	jalr	1424(ra) # 5bec <sbrk>
    2664:	b7bd                	j	25d2 <copyinstr3+0x24>
    printf("oops\n");
    2666:	00004517          	auipc	a0,0x4
    266a:	77250513          	addi	a0,a0,1906 # 6dd8 <malloc+0xe22>
    266e:	00004097          	auipc	ra,0x4
    2672:	890080e7          	jalr	-1904(ra) # 5efe <printf>
    exit(1);
    2676:	4505                	li	a0,1
    2678:	00003097          	auipc	ra,0x3
    267c:	4ec080e7          	jalr	1260(ra) # 5b64 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    2680:	862a                	mv	a2,a0
    2682:	85a6                	mv	a1,s1
    2684:	00004517          	auipc	a0,0x4
    2688:	1fc50513          	addi	a0,a0,508 # 6880 <malloc+0x8ca>
    268c:	00004097          	auipc	ra,0x4
    2690:	872080e7          	jalr	-1934(ra) # 5efe <printf>
    exit(1);
    2694:	4505                	li	a0,1
    2696:	00003097          	auipc	ra,0x3
    269a:	4ce080e7          	jalr	1230(ra) # 5b64 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    269e:	862a                	mv	a2,a0
    26a0:	85a6                	mv	a1,s1
    26a2:	00004517          	auipc	a0,0x4
    26a6:	1fe50513          	addi	a0,a0,510 # 68a0 <malloc+0x8ea>
    26aa:	00004097          	auipc	ra,0x4
    26ae:	854080e7          	jalr	-1964(ra) # 5efe <printf>
    exit(1);
    26b2:	4505                	li	a0,1
    26b4:	00003097          	auipc	ra,0x3
    26b8:	4b0080e7          	jalr	1200(ra) # 5b64 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    26bc:	86aa                	mv	a3,a0
    26be:	8626                	mv	a2,s1
    26c0:	85a6                	mv	a1,s1
    26c2:	00004517          	auipc	a0,0x4
    26c6:	1fe50513          	addi	a0,a0,510 # 68c0 <malloc+0x90a>
    26ca:	00004097          	auipc	ra,0x4
    26ce:	834080e7          	jalr	-1996(ra) # 5efe <printf>
    exit(1);
    26d2:	4505                	li	a0,1
    26d4:	00003097          	auipc	ra,0x3
    26d8:	490080e7          	jalr	1168(ra) # 5b64 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    26dc:	567d                	li	a2,-1
    26de:	85a6                	mv	a1,s1
    26e0:	00004517          	auipc	a0,0x4
    26e4:	20850513          	addi	a0,a0,520 # 68e8 <malloc+0x932>
    26e8:	00004097          	auipc	ra,0x4
    26ec:	816080e7          	jalr	-2026(ra) # 5efe <printf>
    exit(1);
    26f0:	4505                	li	a0,1
    26f2:	00003097          	auipc	ra,0x3
    26f6:	472080e7          	jalr	1138(ra) # 5b64 <exit>

00000000000026fa <rwsbrk>:
{
    26fa:	1101                	addi	sp,sp,-32
    26fc:	ec06                	sd	ra,24(sp)
    26fe:	e822                	sd	s0,16(sp)
    2700:	e426                	sd	s1,8(sp)
    2702:	e04a                	sd	s2,0(sp)
    2704:	1000                	addi	s0,sp,32
  uint64 a = (uint64)sbrk(8192);
    2706:	6509                	lui	a0,0x2
    2708:	00003097          	auipc	ra,0x3
    270c:	4e4080e7          	jalr	1252(ra) # 5bec <sbrk>
  if (a == 0xffffffffffffffffLL)
    2710:	57fd                	li	a5,-1
    2712:	06f50263          	beq	a0,a5,2776 <rwsbrk+0x7c>
    2716:	84aa                	mv	s1,a0
  if ((uint64)sbrk(-8192) == 0xffffffffffffffffLL)
    2718:	7579                	lui	a0,0xffffe
    271a:	00003097          	auipc	ra,0x3
    271e:	4d2080e7          	jalr	1234(ra) # 5bec <sbrk>
    2722:	57fd                	li	a5,-1
    2724:	06f50663          	beq	a0,a5,2790 <rwsbrk+0x96>
  fd = open("rwsbrk", O_CREATE | O_WRONLY);
    2728:	20100593          	li	a1,513
    272c:	00004517          	auipc	a0,0x4
    2730:	6ec50513          	addi	a0,a0,1772 # 6e18 <malloc+0xe62>
    2734:	00003097          	auipc	ra,0x3
    2738:	470080e7          	jalr	1136(ra) # 5ba4 <open>
    273c:	892a                	mv	s2,a0
  if (fd < 0)
    273e:	06054663          	bltz	a0,27aa <rwsbrk+0xb0>
  n = write(fd, (void *)(a + 4096), 1024);
    2742:	6785                	lui	a5,0x1
    2744:	94be                	add	s1,s1,a5
    2746:	40000613          	li	a2,1024
    274a:	85a6                	mv	a1,s1
    274c:	00003097          	auipc	ra,0x3
    2750:	438080e7          	jalr	1080(ra) # 5b84 <write>
    2754:	862a                	mv	a2,a0
  if (n >= 0)
    2756:	06054763          	bltz	a0,27c4 <rwsbrk+0xca>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a + 4096, n);
    275a:	85a6                	mv	a1,s1
    275c:	00004517          	auipc	a0,0x4
    2760:	6dc50513          	addi	a0,a0,1756 # 6e38 <malloc+0xe82>
    2764:	00003097          	auipc	ra,0x3
    2768:	79a080e7          	jalr	1946(ra) # 5efe <printf>
    exit(1);
    276c:	4505                	li	a0,1
    276e:	00003097          	auipc	ra,0x3
    2772:	3f6080e7          	jalr	1014(ra) # 5b64 <exit>
    printf("sbrk(rwsbrk) failed\n");
    2776:	00004517          	auipc	a0,0x4
    277a:	66a50513          	addi	a0,a0,1642 # 6de0 <malloc+0xe2a>
    277e:	00003097          	auipc	ra,0x3
    2782:	780080e7          	jalr	1920(ra) # 5efe <printf>
    exit(1);
    2786:	4505                	li	a0,1
    2788:	00003097          	auipc	ra,0x3
    278c:	3dc080e7          	jalr	988(ra) # 5b64 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    2790:	00004517          	auipc	a0,0x4
    2794:	66850513          	addi	a0,a0,1640 # 6df8 <malloc+0xe42>
    2798:	00003097          	auipc	ra,0x3
    279c:	766080e7          	jalr	1894(ra) # 5efe <printf>
    exit(1);
    27a0:	4505                	li	a0,1
    27a2:	00003097          	auipc	ra,0x3
    27a6:	3c2080e7          	jalr	962(ra) # 5b64 <exit>
    printf("open(rwsbrk) failed\n");
    27aa:	00004517          	auipc	a0,0x4
    27ae:	67650513          	addi	a0,a0,1654 # 6e20 <malloc+0xe6a>
    27b2:	00003097          	auipc	ra,0x3
    27b6:	74c080e7          	jalr	1868(ra) # 5efe <printf>
    exit(1);
    27ba:	4505                	li	a0,1
    27bc:	00003097          	auipc	ra,0x3
    27c0:	3a8080e7          	jalr	936(ra) # 5b64 <exit>
  close(fd);
    27c4:	854a                	mv	a0,s2
    27c6:	00003097          	auipc	ra,0x3
    27ca:	3c6080e7          	jalr	966(ra) # 5b8c <close>
  unlink("rwsbrk");
    27ce:	00004517          	auipc	a0,0x4
    27d2:	64a50513          	addi	a0,a0,1610 # 6e18 <malloc+0xe62>
    27d6:	00003097          	auipc	ra,0x3
    27da:	3de080e7          	jalr	990(ra) # 5bb4 <unlink>
  fd = open("README", O_RDONLY);
    27de:	4581                	li	a1,0
    27e0:	00004517          	auipc	a0,0x4
    27e4:	ad050513          	addi	a0,a0,-1328 # 62b0 <malloc+0x2fa>
    27e8:	00003097          	auipc	ra,0x3
    27ec:	3bc080e7          	jalr	956(ra) # 5ba4 <open>
    27f0:	892a                	mv	s2,a0
  if (fd < 0)
    27f2:	02054963          	bltz	a0,2824 <rwsbrk+0x12a>
  n = read(fd, (void *)(a + 4096), 10);
    27f6:	4629                	li	a2,10
    27f8:	85a6                	mv	a1,s1
    27fa:	00003097          	auipc	ra,0x3
    27fe:	382080e7          	jalr	898(ra) # 5b7c <read>
    2802:	862a                	mv	a2,a0
  if (n >= 0)
    2804:	02054d63          	bltz	a0,283e <rwsbrk+0x144>
    printf("read(fd, %p, 10) returned %d, not -1\n", a + 4096, n);
    2808:	85a6                	mv	a1,s1
    280a:	00004517          	auipc	a0,0x4
    280e:	65e50513          	addi	a0,a0,1630 # 6e68 <malloc+0xeb2>
    2812:	00003097          	auipc	ra,0x3
    2816:	6ec080e7          	jalr	1772(ra) # 5efe <printf>
    exit(1);
    281a:	4505                	li	a0,1
    281c:	00003097          	auipc	ra,0x3
    2820:	348080e7          	jalr	840(ra) # 5b64 <exit>
    printf("open(rwsbrk) failed\n");
    2824:	00004517          	auipc	a0,0x4
    2828:	5fc50513          	addi	a0,a0,1532 # 6e20 <malloc+0xe6a>
    282c:	00003097          	auipc	ra,0x3
    2830:	6d2080e7          	jalr	1746(ra) # 5efe <printf>
    exit(1);
    2834:	4505                	li	a0,1
    2836:	00003097          	auipc	ra,0x3
    283a:	32e080e7          	jalr	814(ra) # 5b64 <exit>
  close(fd);
    283e:	854a                	mv	a0,s2
    2840:	00003097          	auipc	ra,0x3
    2844:	34c080e7          	jalr	844(ra) # 5b8c <close>
  exit(0);
    2848:	4501                	li	a0,0
    284a:	00003097          	auipc	ra,0x3
    284e:	31a080e7          	jalr	794(ra) # 5b64 <exit>

0000000000002852 <sbrkbasic>:
{
    2852:	7139                	addi	sp,sp,-64
    2854:	fc06                	sd	ra,56(sp)
    2856:	f822                	sd	s0,48(sp)
    2858:	f426                	sd	s1,40(sp)
    285a:	f04a                	sd	s2,32(sp)
    285c:	ec4e                	sd	s3,24(sp)
    285e:	e852                	sd	s4,16(sp)
    2860:	0080                	addi	s0,sp,64
    2862:	8a2a                	mv	s4,a0
  pid = fork();
    2864:	00003097          	auipc	ra,0x3
    2868:	2f8080e7          	jalr	760(ra) # 5b5c <fork>
  if (pid < 0)
    286c:	02054c63          	bltz	a0,28a4 <sbrkbasic+0x52>
  if (pid == 0)
    2870:	ed21                	bnez	a0,28c8 <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    2872:	40000537          	lui	a0,0x40000
    2876:	00003097          	auipc	ra,0x3
    287a:	376080e7          	jalr	886(ra) # 5bec <sbrk>
    if (a == (char *)0xffffffffffffffffL)
    287e:	57fd                	li	a5,-1
    2880:	02f50f63          	beq	a0,a5,28be <sbrkbasic+0x6c>
    for (b = a; b < a + TOOMUCH; b += 4096)
    2884:	400007b7          	lui	a5,0x40000
    2888:	97aa                	add	a5,a5,a0
      *b = 99;
    288a:	06300693          	li	a3,99
    for (b = a; b < a + TOOMUCH; b += 4096)
    288e:	6705                	lui	a4,0x1
      *b = 99;
    2890:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0388>
    for (b = a; b < a + TOOMUCH; b += 4096)
    2894:	953a                	add	a0,a0,a4
    2896:	fef51de3          	bne	a0,a5,2890 <sbrkbasic+0x3e>
    exit(1);
    289a:	4505                	li	a0,1
    289c:	00003097          	auipc	ra,0x3
    28a0:	2c8080e7          	jalr	712(ra) # 5b64 <exit>
    printf("fork failed in sbrkbasic\n");
    28a4:	00004517          	auipc	a0,0x4
    28a8:	5ec50513          	addi	a0,a0,1516 # 6e90 <malloc+0xeda>
    28ac:	00003097          	auipc	ra,0x3
    28b0:	652080e7          	jalr	1618(ra) # 5efe <printf>
    exit(1);
    28b4:	4505                	li	a0,1
    28b6:	00003097          	auipc	ra,0x3
    28ba:	2ae080e7          	jalr	686(ra) # 5b64 <exit>
      exit(0);
    28be:	4501                	li	a0,0
    28c0:	00003097          	auipc	ra,0x3
    28c4:	2a4080e7          	jalr	676(ra) # 5b64 <exit>
  wait(&xstatus);
    28c8:	fcc40513          	addi	a0,s0,-52
    28cc:	00003097          	auipc	ra,0x3
    28d0:	2a0080e7          	jalr	672(ra) # 5b6c <wait>
  if (xstatus == 1)
    28d4:	fcc42703          	lw	a4,-52(s0)
    28d8:	4785                	li	a5,1
    28da:	00f70d63          	beq	a4,a5,28f4 <sbrkbasic+0xa2>
  a = sbrk(0);
    28de:	4501                	li	a0,0
    28e0:	00003097          	auipc	ra,0x3
    28e4:	30c080e7          	jalr	780(ra) # 5bec <sbrk>
    28e8:	84aa                	mv	s1,a0
  for (i = 0; i < 5000; i++)
    28ea:	4901                	li	s2,0
    28ec:	6985                	lui	s3,0x1
    28ee:	38898993          	addi	s3,s3,904 # 1388 <badarg+0x2c>
    28f2:	a005                	j	2912 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    28f4:	85d2                	mv	a1,s4
    28f6:	00004517          	auipc	a0,0x4
    28fa:	5ba50513          	addi	a0,a0,1466 # 6eb0 <malloc+0xefa>
    28fe:	00003097          	auipc	ra,0x3
    2902:	600080e7          	jalr	1536(ra) # 5efe <printf>
    exit(1);
    2906:	4505                	li	a0,1
    2908:	00003097          	auipc	ra,0x3
    290c:	25c080e7          	jalr	604(ra) # 5b64 <exit>
    a = b + 1;
    2910:	84be                	mv	s1,a5
    b = sbrk(1);
    2912:	4505                	li	a0,1
    2914:	00003097          	auipc	ra,0x3
    2918:	2d8080e7          	jalr	728(ra) # 5bec <sbrk>
    if (b != a)
    291c:	04951c63          	bne	a0,s1,2974 <sbrkbasic+0x122>
    *b = 1;
    2920:	4785                	li	a5,1
    2922:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2926:	00148793          	addi	a5,s1,1
  for (i = 0; i < 5000; i++)
    292a:	2905                	addiw	s2,s2,1
    292c:	ff3912e3          	bne	s2,s3,2910 <sbrkbasic+0xbe>
  pid = fork();
    2930:	00003097          	auipc	ra,0x3
    2934:	22c080e7          	jalr	556(ra) # 5b5c <fork>
    2938:	892a                	mv	s2,a0
  if (pid < 0)
    293a:	04054e63          	bltz	a0,2996 <sbrkbasic+0x144>
  c = sbrk(1);
    293e:	4505                	li	a0,1
    2940:	00003097          	auipc	ra,0x3
    2944:	2ac080e7          	jalr	684(ra) # 5bec <sbrk>
  c = sbrk(1);
    2948:	4505                	li	a0,1
    294a:	00003097          	auipc	ra,0x3
    294e:	2a2080e7          	jalr	674(ra) # 5bec <sbrk>
  if (c != a + 1)
    2952:	0489                	addi	s1,s1,2
    2954:	04a48f63          	beq	s1,a0,29b2 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    2958:	85d2                	mv	a1,s4
    295a:	00004517          	auipc	a0,0x4
    295e:	5b650513          	addi	a0,a0,1462 # 6f10 <malloc+0xf5a>
    2962:	00003097          	auipc	ra,0x3
    2966:	59c080e7          	jalr	1436(ra) # 5efe <printf>
    exit(1);
    296a:	4505                	li	a0,1
    296c:	00003097          	auipc	ra,0x3
    2970:	1f8080e7          	jalr	504(ra) # 5b64 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    2974:	872a                	mv	a4,a0
    2976:	86a6                	mv	a3,s1
    2978:	864a                	mv	a2,s2
    297a:	85d2                	mv	a1,s4
    297c:	00004517          	auipc	a0,0x4
    2980:	55450513          	addi	a0,a0,1364 # 6ed0 <malloc+0xf1a>
    2984:	00003097          	auipc	ra,0x3
    2988:	57a080e7          	jalr	1402(ra) # 5efe <printf>
      exit(1);
    298c:	4505                	li	a0,1
    298e:	00003097          	auipc	ra,0x3
    2992:	1d6080e7          	jalr	470(ra) # 5b64 <exit>
    printf("%s: sbrk test fork failed\n", s);
    2996:	85d2                	mv	a1,s4
    2998:	00004517          	auipc	a0,0x4
    299c:	55850513          	addi	a0,a0,1368 # 6ef0 <malloc+0xf3a>
    29a0:	00003097          	auipc	ra,0x3
    29a4:	55e080e7          	jalr	1374(ra) # 5efe <printf>
    exit(1);
    29a8:	4505                	li	a0,1
    29aa:	00003097          	auipc	ra,0x3
    29ae:	1ba080e7          	jalr	442(ra) # 5b64 <exit>
  if (pid == 0)
    29b2:	00091763          	bnez	s2,29c0 <sbrkbasic+0x16e>
    exit(0);
    29b6:	4501                	li	a0,0
    29b8:	00003097          	auipc	ra,0x3
    29bc:	1ac080e7          	jalr	428(ra) # 5b64 <exit>
  wait(&xstatus);
    29c0:	fcc40513          	addi	a0,s0,-52
    29c4:	00003097          	auipc	ra,0x3
    29c8:	1a8080e7          	jalr	424(ra) # 5b6c <wait>
  exit(xstatus);
    29cc:	fcc42503          	lw	a0,-52(s0)
    29d0:	00003097          	auipc	ra,0x3
    29d4:	194080e7          	jalr	404(ra) # 5b64 <exit>

00000000000029d8 <sbrkmuch>:
{
    29d8:	7179                	addi	sp,sp,-48
    29da:	f406                	sd	ra,40(sp)
    29dc:	f022                	sd	s0,32(sp)
    29de:	ec26                	sd	s1,24(sp)
    29e0:	e84a                	sd	s2,16(sp)
    29e2:	e44e                	sd	s3,8(sp)
    29e4:	e052                	sd	s4,0(sp)
    29e6:	1800                	addi	s0,sp,48
    29e8:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    29ea:	4501                	li	a0,0
    29ec:	00003097          	auipc	ra,0x3
    29f0:	200080e7          	jalr	512(ra) # 5bec <sbrk>
    29f4:	892a                	mv	s2,a0
  a = sbrk(0);
    29f6:	4501                	li	a0,0
    29f8:	00003097          	auipc	ra,0x3
    29fc:	1f4080e7          	jalr	500(ra) # 5bec <sbrk>
    2a00:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2a02:	06400537          	lui	a0,0x6400
    2a06:	9d05                	subw	a0,a0,s1
    2a08:	00003097          	auipc	ra,0x3
    2a0c:	1e4080e7          	jalr	484(ra) # 5bec <sbrk>
  if (p != a)
    2a10:	0ca49863          	bne	s1,a0,2ae0 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2a14:	4501                	li	a0,0
    2a16:	00003097          	auipc	ra,0x3
    2a1a:	1d6080e7          	jalr	470(ra) # 5bec <sbrk>
    2a1e:	87aa                	mv	a5,a0
  for (char *pp = a; pp < eee; pp += 4096)
    2a20:	00a4f963          	bgeu	s1,a0,2a32 <sbrkmuch+0x5a>
    *pp = 1;
    2a24:	4685                	li	a3,1
  for (char *pp = a; pp < eee; pp += 4096)
    2a26:	6705                	lui	a4,0x1
    *pp = 1;
    2a28:	00d48023          	sb	a3,0(s1)
  for (char *pp = a; pp < eee; pp += 4096)
    2a2c:	94ba                	add	s1,s1,a4
    2a2e:	fef4ede3          	bltu	s1,a5,2a28 <sbrkmuch+0x50>
  *lastaddr = 99;
    2a32:	064007b7          	lui	a5,0x6400
    2a36:	06300713          	li	a4,99
    2a3a:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0387>
  a = sbrk(0);
    2a3e:	4501                	li	a0,0
    2a40:	00003097          	auipc	ra,0x3
    2a44:	1ac080e7          	jalr	428(ra) # 5bec <sbrk>
    2a48:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2a4a:	757d                	lui	a0,0xfffff
    2a4c:	00003097          	auipc	ra,0x3
    2a50:	1a0080e7          	jalr	416(ra) # 5bec <sbrk>
  if (c == (char *)0xffffffffffffffffL)
    2a54:	57fd                	li	a5,-1
    2a56:	0af50363          	beq	a0,a5,2afc <sbrkmuch+0x124>
  c = sbrk(0);
    2a5a:	4501                	li	a0,0
    2a5c:	00003097          	auipc	ra,0x3
    2a60:	190080e7          	jalr	400(ra) # 5bec <sbrk>
  if (c != a - PGSIZE)
    2a64:	77fd                	lui	a5,0xfffff
    2a66:	97a6                	add	a5,a5,s1
    2a68:	0af51863          	bne	a0,a5,2b18 <sbrkmuch+0x140>
  a = sbrk(0);
    2a6c:	4501                	li	a0,0
    2a6e:	00003097          	auipc	ra,0x3
    2a72:	17e080e7          	jalr	382(ra) # 5bec <sbrk>
    2a76:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2a78:	6505                	lui	a0,0x1
    2a7a:	00003097          	auipc	ra,0x3
    2a7e:	172080e7          	jalr	370(ra) # 5bec <sbrk>
    2a82:	8a2a                	mv	s4,a0
  if (c != a || sbrk(0) != a + PGSIZE)
    2a84:	0aa49a63          	bne	s1,a0,2b38 <sbrkmuch+0x160>
    2a88:	4501                	li	a0,0
    2a8a:	00003097          	auipc	ra,0x3
    2a8e:	162080e7          	jalr	354(ra) # 5bec <sbrk>
    2a92:	6785                	lui	a5,0x1
    2a94:	97a6                	add	a5,a5,s1
    2a96:	0af51163          	bne	a0,a5,2b38 <sbrkmuch+0x160>
  if (*lastaddr == 99)
    2a9a:	064007b7          	lui	a5,0x6400
    2a9e:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0387>
    2aa2:	06300793          	li	a5,99
    2aa6:	0af70963          	beq	a4,a5,2b58 <sbrkmuch+0x180>
  a = sbrk(0);
    2aaa:	4501                	li	a0,0
    2aac:	00003097          	auipc	ra,0x3
    2ab0:	140080e7          	jalr	320(ra) # 5bec <sbrk>
    2ab4:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2ab6:	4501                	li	a0,0
    2ab8:	00003097          	auipc	ra,0x3
    2abc:	134080e7          	jalr	308(ra) # 5bec <sbrk>
    2ac0:	40a9053b          	subw	a0,s2,a0
    2ac4:	00003097          	auipc	ra,0x3
    2ac8:	128080e7          	jalr	296(ra) # 5bec <sbrk>
  if (c != a)
    2acc:	0aa49463          	bne	s1,a0,2b74 <sbrkmuch+0x19c>
}
    2ad0:	70a2                	ld	ra,40(sp)
    2ad2:	7402                	ld	s0,32(sp)
    2ad4:	64e2                	ld	s1,24(sp)
    2ad6:	6942                	ld	s2,16(sp)
    2ad8:	69a2                	ld	s3,8(sp)
    2ada:	6a02                	ld	s4,0(sp)
    2adc:	6145                	addi	sp,sp,48
    2ade:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2ae0:	85ce                	mv	a1,s3
    2ae2:	00004517          	auipc	a0,0x4
    2ae6:	44e50513          	addi	a0,a0,1102 # 6f30 <malloc+0xf7a>
    2aea:	00003097          	auipc	ra,0x3
    2aee:	414080e7          	jalr	1044(ra) # 5efe <printf>
    exit(1);
    2af2:	4505                	li	a0,1
    2af4:	00003097          	auipc	ra,0x3
    2af8:	070080e7          	jalr	112(ra) # 5b64 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2afc:	85ce                	mv	a1,s3
    2afe:	00004517          	auipc	a0,0x4
    2b02:	47a50513          	addi	a0,a0,1146 # 6f78 <malloc+0xfc2>
    2b06:	00003097          	auipc	ra,0x3
    2b0a:	3f8080e7          	jalr	1016(ra) # 5efe <printf>
    exit(1);
    2b0e:	4505                	li	a0,1
    2b10:	00003097          	auipc	ra,0x3
    2b14:	054080e7          	jalr	84(ra) # 5b64 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2b18:	86aa                	mv	a3,a0
    2b1a:	8626                	mv	a2,s1
    2b1c:	85ce                	mv	a1,s3
    2b1e:	00004517          	auipc	a0,0x4
    2b22:	47a50513          	addi	a0,a0,1146 # 6f98 <malloc+0xfe2>
    2b26:	00003097          	auipc	ra,0x3
    2b2a:	3d8080e7          	jalr	984(ra) # 5efe <printf>
    exit(1);
    2b2e:	4505                	li	a0,1
    2b30:	00003097          	auipc	ra,0x3
    2b34:	034080e7          	jalr	52(ra) # 5b64 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2b38:	86d2                	mv	a3,s4
    2b3a:	8626                	mv	a2,s1
    2b3c:	85ce                	mv	a1,s3
    2b3e:	00004517          	auipc	a0,0x4
    2b42:	49a50513          	addi	a0,a0,1178 # 6fd8 <malloc+0x1022>
    2b46:	00003097          	auipc	ra,0x3
    2b4a:	3b8080e7          	jalr	952(ra) # 5efe <printf>
    exit(1);
    2b4e:	4505                	li	a0,1
    2b50:	00003097          	auipc	ra,0x3
    2b54:	014080e7          	jalr	20(ra) # 5b64 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2b58:	85ce                	mv	a1,s3
    2b5a:	00004517          	auipc	a0,0x4
    2b5e:	4ae50513          	addi	a0,a0,1198 # 7008 <malloc+0x1052>
    2b62:	00003097          	auipc	ra,0x3
    2b66:	39c080e7          	jalr	924(ra) # 5efe <printf>
    exit(1);
    2b6a:	4505                	li	a0,1
    2b6c:	00003097          	auipc	ra,0x3
    2b70:	ff8080e7          	jalr	-8(ra) # 5b64 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2b74:	86aa                	mv	a3,a0
    2b76:	8626                	mv	a2,s1
    2b78:	85ce                	mv	a1,s3
    2b7a:	00004517          	auipc	a0,0x4
    2b7e:	4c650513          	addi	a0,a0,1222 # 7040 <malloc+0x108a>
    2b82:	00003097          	auipc	ra,0x3
    2b86:	37c080e7          	jalr	892(ra) # 5efe <printf>
    exit(1);
    2b8a:	4505                	li	a0,1
    2b8c:	00003097          	auipc	ra,0x3
    2b90:	fd8080e7          	jalr	-40(ra) # 5b64 <exit>

0000000000002b94 <sbrkarg>:
{
    2b94:	7179                	addi	sp,sp,-48
    2b96:	f406                	sd	ra,40(sp)
    2b98:	f022                	sd	s0,32(sp)
    2b9a:	ec26                	sd	s1,24(sp)
    2b9c:	e84a                	sd	s2,16(sp)
    2b9e:	e44e                	sd	s3,8(sp)
    2ba0:	1800                	addi	s0,sp,48
    2ba2:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2ba4:	6505                	lui	a0,0x1
    2ba6:	00003097          	auipc	ra,0x3
    2baa:	046080e7          	jalr	70(ra) # 5bec <sbrk>
    2bae:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE | O_WRONLY);
    2bb0:	20100593          	li	a1,513
    2bb4:	00004517          	auipc	a0,0x4
    2bb8:	4b450513          	addi	a0,a0,1204 # 7068 <malloc+0x10b2>
    2bbc:	00003097          	auipc	ra,0x3
    2bc0:	fe8080e7          	jalr	-24(ra) # 5ba4 <open>
    2bc4:	84aa                	mv	s1,a0
  unlink("sbrk");
    2bc6:	00004517          	auipc	a0,0x4
    2bca:	4a250513          	addi	a0,a0,1186 # 7068 <malloc+0x10b2>
    2bce:	00003097          	auipc	ra,0x3
    2bd2:	fe6080e7          	jalr	-26(ra) # 5bb4 <unlink>
  if (fd < 0)
    2bd6:	0404c163          	bltz	s1,2c18 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0)
    2bda:	6605                	lui	a2,0x1
    2bdc:	85ca                	mv	a1,s2
    2bde:	8526                	mv	a0,s1
    2be0:	00003097          	auipc	ra,0x3
    2be4:	fa4080e7          	jalr	-92(ra) # 5b84 <write>
    2be8:	04054663          	bltz	a0,2c34 <sbrkarg+0xa0>
  close(fd);
    2bec:	8526                	mv	a0,s1
    2bee:	00003097          	auipc	ra,0x3
    2bf2:	f9e080e7          	jalr	-98(ra) # 5b8c <close>
  a = sbrk(PGSIZE);
    2bf6:	6505                	lui	a0,0x1
    2bf8:	00003097          	auipc	ra,0x3
    2bfc:	ff4080e7          	jalr	-12(ra) # 5bec <sbrk>
  if (pipe((int *)a) != 0)
    2c00:	00003097          	auipc	ra,0x3
    2c04:	f74080e7          	jalr	-140(ra) # 5b74 <pipe>
    2c08:	e521                	bnez	a0,2c50 <sbrkarg+0xbc>
}
    2c0a:	70a2                	ld	ra,40(sp)
    2c0c:	7402                	ld	s0,32(sp)
    2c0e:	64e2                	ld	s1,24(sp)
    2c10:	6942                	ld	s2,16(sp)
    2c12:	69a2                	ld	s3,8(sp)
    2c14:	6145                	addi	sp,sp,48
    2c16:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2c18:	85ce                	mv	a1,s3
    2c1a:	00004517          	auipc	a0,0x4
    2c1e:	45650513          	addi	a0,a0,1110 # 7070 <malloc+0x10ba>
    2c22:	00003097          	auipc	ra,0x3
    2c26:	2dc080e7          	jalr	732(ra) # 5efe <printf>
    exit(1);
    2c2a:	4505                	li	a0,1
    2c2c:	00003097          	auipc	ra,0x3
    2c30:	f38080e7          	jalr	-200(ra) # 5b64 <exit>
    printf("%s: write sbrk failed\n", s);
    2c34:	85ce                	mv	a1,s3
    2c36:	00004517          	auipc	a0,0x4
    2c3a:	45250513          	addi	a0,a0,1106 # 7088 <malloc+0x10d2>
    2c3e:	00003097          	auipc	ra,0x3
    2c42:	2c0080e7          	jalr	704(ra) # 5efe <printf>
    exit(1);
    2c46:	4505                	li	a0,1
    2c48:	00003097          	auipc	ra,0x3
    2c4c:	f1c080e7          	jalr	-228(ra) # 5b64 <exit>
    printf("%s: pipe() failed\n", s);
    2c50:	85ce                	mv	a1,s3
    2c52:	00004517          	auipc	a0,0x4
    2c56:	e1650513          	addi	a0,a0,-490 # 6a68 <malloc+0xab2>
    2c5a:	00003097          	auipc	ra,0x3
    2c5e:	2a4080e7          	jalr	676(ra) # 5efe <printf>
    exit(1);
    2c62:	4505                	li	a0,1
    2c64:	00003097          	auipc	ra,0x3
    2c68:	f00080e7          	jalr	-256(ra) # 5b64 <exit>

0000000000002c6c <argptest>:
{
    2c6c:	1101                	addi	sp,sp,-32
    2c6e:	ec06                	sd	ra,24(sp)
    2c70:	e822                	sd	s0,16(sp)
    2c72:	e426                	sd	s1,8(sp)
    2c74:	e04a                	sd	s2,0(sp)
    2c76:	1000                	addi	s0,sp,32
    2c78:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2c7a:	4581                	li	a1,0
    2c7c:	00004517          	auipc	a0,0x4
    2c80:	42450513          	addi	a0,a0,1060 # 70a0 <malloc+0x10ea>
    2c84:	00003097          	auipc	ra,0x3
    2c88:	f20080e7          	jalr	-224(ra) # 5ba4 <open>
  if (fd < 0)
    2c8c:	02054b63          	bltz	a0,2cc2 <argptest+0x56>
    2c90:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2c92:	4501                	li	a0,0
    2c94:	00003097          	auipc	ra,0x3
    2c98:	f58080e7          	jalr	-168(ra) # 5bec <sbrk>
    2c9c:	567d                	li	a2,-1
    2c9e:	fff50593          	addi	a1,a0,-1
    2ca2:	8526                	mv	a0,s1
    2ca4:	00003097          	auipc	ra,0x3
    2ca8:	ed8080e7          	jalr	-296(ra) # 5b7c <read>
  close(fd);
    2cac:	8526                	mv	a0,s1
    2cae:	00003097          	auipc	ra,0x3
    2cb2:	ede080e7          	jalr	-290(ra) # 5b8c <close>
}
    2cb6:	60e2                	ld	ra,24(sp)
    2cb8:	6442                	ld	s0,16(sp)
    2cba:	64a2                	ld	s1,8(sp)
    2cbc:	6902                	ld	s2,0(sp)
    2cbe:	6105                	addi	sp,sp,32
    2cc0:	8082                	ret
    printf("%s: open failed\n", s);
    2cc2:	85ca                	mv	a1,s2
    2cc4:	00004517          	auipc	a0,0x4
    2cc8:	cb450513          	addi	a0,a0,-844 # 6978 <malloc+0x9c2>
    2ccc:	00003097          	auipc	ra,0x3
    2cd0:	232080e7          	jalr	562(ra) # 5efe <printf>
    exit(1);
    2cd4:	4505                	li	a0,1
    2cd6:	00003097          	auipc	ra,0x3
    2cda:	e8e080e7          	jalr	-370(ra) # 5b64 <exit>

0000000000002cde <sbrkbugs>:
{
    2cde:	1141                	addi	sp,sp,-16
    2ce0:	e406                	sd	ra,8(sp)
    2ce2:	e022                	sd	s0,0(sp)
    2ce4:	0800                	addi	s0,sp,16
  int pid = fork();
    2ce6:	00003097          	auipc	ra,0x3
    2cea:	e76080e7          	jalr	-394(ra) # 5b5c <fork>
  if (pid < 0)
    2cee:	02054263          	bltz	a0,2d12 <sbrkbugs+0x34>
  if (pid == 0)
    2cf2:	ed0d                	bnez	a0,2d2c <sbrkbugs+0x4e>
    int sz = (uint64)sbrk(0);
    2cf4:	00003097          	auipc	ra,0x3
    2cf8:	ef8080e7          	jalr	-264(ra) # 5bec <sbrk>
    sbrk(-sz);
    2cfc:	40a0053b          	negw	a0,a0
    2d00:	00003097          	auipc	ra,0x3
    2d04:	eec080e7          	jalr	-276(ra) # 5bec <sbrk>
    exit(0);
    2d08:	4501                	li	a0,0
    2d0a:	00003097          	auipc	ra,0x3
    2d0e:	e5a080e7          	jalr	-422(ra) # 5b64 <exit>
    printf("fork failed\n");
    2d12:	00004517          	auipc	a0,0x4
    2d16:	05650513          	addi	a0,a0,86 # 6d68 <malloc+0xdb2>
    2d1a:	00003097          	auipc	ra,0x3
    2d1e:	1e4080e7          	jalr	484(ra) # 5efe <printf>
    exit(1);
    2d22:	4505                	li	a0,1
    2d24:	00003097          	auipc	ra,0x3
    2d28:	e40080e7          	jalr	-448(ra) # 5b64 <exit>
  wait(0);
    2d2c:	4501                	li	a0,0
    2d2e:	00003097          	auipc	ra,0x3
    2d32:	e3e080e7          	jalr	-450(ra) # 5b6c <wait>
  pid = fork();
    2d36:	00003097          	auipc	ra,0x3
    2d3a:	e26080e7          	jalr	-474(ra) # 5b5c <fork>
  if (pid < 0)
    2d3e:	02054563          	bltz	a0,2d68 <sbrkbugs+0x8a>
  if (pid == 0)
    2d42:	e121                	bnez	a0,2d82 <sbrkbugs+0xa4>
    int sz = (uint64)sbrk(0);
    2d44:	00003097          	auipc	ra,0x3
    2d48:	ea8080e7          	jalr	-344(ra) # 5bec <sbrk>
    sbrk(-(sz - 3500));
    2d4c:	6785                	lui	a5,0x1
    2d4e:	dac7879b          	addiw	a5,a5,-596 # dac <unlinkread+0x5c>
    2d52:	40a7853b          	subw	a0,a5,a0
    2d56:	00003097          	auipc	ra,0x3
    2d5a:	e96080e7          	jalr	-362(ra) # 5bec <sbrk>
    exit(0);
    2d5e:	4501                	li	a0,0
    2d60:	00003097          	auipc	ra,0x3
    2d64:	e04080e7          	jalr	-508(ra) # 5b64 <exit>
    printf("fork failed\n");
    2d68:	00004517          	auipc	a0,0x4
    2d6c:	00050513          	mv	a0,a0
    2d70:	00003097          	auipc	ra,0x3
    2d74:	18e080e7          	jalr	398(ra) # 5efe <printf>
    exit(1);
    2d78:	4505                	li	a0,1
    2d7a:	00003097          	auipc	ra,0x3
    2d7e:	dea080e7          	jalr	-534(ra) # 5b64 <exit>
  wait(0);
    2d82:	4501                	li	a0,0
    2d84:	00003097          	auipc	ra,0x3
    2d88:	de8080e7          	jalr	-536(ra) # 5b6c <wait>
  pid = fork();
    2d8c:	00003097          	auipc	ra,0x3
    2d90:	dd0080e7          	jalr	-560(ra) # 5b5c <fork>
  if (pid < 0)
    2d94:	02054a63          	bltz	a0,2dc8 <sbrkbugs+0xea>
  if (pid == 0)
    2d98:	e529                	bnez	a0,2de2 <sbrkbugs+0x104>
    sbrk((10 * 4096 + 2048) - (uint64)sbrk(0));
    2d9a:	00003097          	auipc	ra,0x3
    2d9e:	e52080e7          	jalr	-430(ra) # 5bec <sbrk>
    2da2:	67ad                	lui	a5,0xb
    2da4:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x298>
    2da8:	40a7853b          	subw	a0,a5,a0
    2dac:	00003097          	auipc	ra,0x3
    2db0:	e40080e7          	jalr	-448(ra) # 5bec <sbrk>
    sbrk(-10);
    2db4:	5559                	li	a0,-10
    2db6:	00003097          	auipc	ra,0x3
    2dba:	e36080e7          	jalr	-458(ra) # 5bec <sbrk>
    exit(0);
    2dbe:	4501                	li	a0,0
    2dc0:	00003097          	auipc	ra,0x3
    2dc4:	da4080e7          	jalr	-604(ra) # 5b64 <exit>
    printf("fork failed\n");
    2dc8:	00004517          	auipc	a0,0x4
    2dcc:	fa050513          	addi	a0,a0,-96 # 6d68 <malloc+0xdb2>
    2dd0:	00003097          	auipc	ra,0x3
    2dd4:	12e080e7          	jalr	302(ra) # 5efe <printf>
    exit(1);
    2dd8:	4505                	li	a0,1
    2dda:	00003097          	auipc	ra,0x3
    2dde:	d8a080e7          	jalr	-630(ra) # 5b64 <exit>
  wait(0);
    2de2:	4501                	li	a0,0
    2de4:	00003097          	auipc	ra,0x3
    2de8:	d88080e7          	jalr	-632(ra) # 5b6c <wait>
  exit(0);
    2dec:	4501                	li	a0,0
    2dee:	00003097          	auipc	ra,0x3
    2df2:	d76080e7          	jalr	-650(ra) # 5b64 <exit>

0000000000002df6 <sbrklast>:
{
    2df6:	7179                	addi	sp,sp,-48
    2df8:	f406                	sd	ra,40(sp)
    2dfa:	f022                	sd	s0,32(sp)
    2dfc:	ec26                	sd	s1,24(sp)
    2dfe:	e84a                	sd	s2,16(sp)
    2e00:	e44e                	sd	s3,8(sp)
    2e02:	e052                	sd	s4,0(sp)
    2e04:	1800                	addi	s0,sp,48
  uint64 top = (uint64)sbrk(0);
    2e06:	4501                	li	a0,0
    2e08:	00003097          	auipc	ra,0x3
    2e0c:	de4080e7          	jalr	-540(ra) # 5bec <sbrk>
  if ((top % 4096) != 0)
    2e10:	03451793          	slli	a5,a0,0x34
    2e14:	ebd9                	bnez	a5,2eaa <sbrklast+0xb4>
  sbrk(4096);
    2e16:	6505                	lui	a0,0x1
    2e18:	00003097          	auipc	ra,0x3
    2e1c:	dd4080e7          	jalr	-556(ra) # 5bec <sbrk>
  sbrk(10);
    2e20:	4529                	li	a0,10
    2e22:	00003097          	auipc	ra,0x3
    2e26:	dca080e7          	jalr	-566(ra) # 5bec <sbrk>
  sbrk(-20);
    2e2a:	5531                	li	a0,-20
    2e2c:	00003097          	auipc	ra,0x3
    2e30:	dc0080e7          	jalr	-576(ra) # 5bec <sbrk>
  top = (uint64)sbrk(0);
    2e34:	4501                	li	a0,0
    2e36:	00003097          	auipc	ra,0x3
    2e3a:	db6080e7          	jalr	-586(ra) # 5bec <sbrk>
    2e3e:	84aa                	mv	s1,a0
  char *p = (char *)(top - 64);
    2e40:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0xba>
  p[0] = 'x';
    2e44:	07800a13          	li	s4,120
    2e48:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2e4c:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR | O_CREATE);
    2e50:	20200593          	li	a1,514
    2e54:	854a                	mv	a0,s2
    2e56:	00003097          	auipc	ra,0x3
    2e5a:	d4e080e7          	jalr	-690(ra) # 5ba4 <open>
    2e5e:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2e60:	4605                	li	a2,1
    2e62:	85ca                	mv	a1,s2
    2e64:	00003097          	auipc	ra,0x3
    2e68:	d20080e7          	jalr	-736(ra) # 5b84 <write>
  close(fd);
    2e6c:	854e                	mv	a0,s3
    2e6e:	00003097          	auipc	ra,0x3
    2e72:	d1e080e7          	jalr	-738(ra) # 5b8c <close>
  fd = open(p, O_RDWR);
    2e76:	4589                	li	a1,2
    2e78:	854a                	mv	a0,s2
    2e7a:	00003097          	auipc	ra,0x3
    2e7e:	d2a080e7          	jalr	-726(ra) # 5ba4 <open>
  p[0] = '\0';
    2e82:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2e86:	4605                	li	a2,1
    2e88:	85ca                	mv	a1,s2
    2e8a:	00003097          	auipc	ra,0x3
    2e8e:	cf2080e7          	jalr	-782(ra) # 5b7c <read>
  if (p[0] != 'x')
    2e92:	fc04c783          	lbu	a5,-64(s1)
    2e96:	03479463          	bne	a5,s4,2ebe <sbrklast+0xc8>
}
    2e9a:	70a2                	ld	ra,40(sp)
    2e9c:	7402                	ld	s0,32(sp)
    2e9e:	64e2                	ld	s1,24(sp)
    2ea0:	6942                	ld	s2,16(sp)
    2ea2:	69a2                	ld	s3,8(sp)
    2ea4:	6a02                	ld	s4,0(sp)
    2ea6:	6145                	addi	sp,sp,48
    2ea8:	8082                	ret
    sbrk(4096 - (top % 4096));
    2eaa:	0347d513          	srli	a0,a5,0x34
    2eae:	6785                	lui	a5,0x1
    2eb0:	40a7853b          	subw	a0,a5,a0
    2eb4:	00003097          	auipc	ra,0x3
    2eb8:	d38080e7          	jalr	-712(ra) # 5bec <sbrk>
    2ebc:	bfa9                	j	2e16 <sbrklast+0x20>
    exit(1);
    2ebe:	4505                	li	a0,1
    2ec0:	00003097          	auipc	ra,0x3
    2ec4:	ca4080e7          	jalr	-860(ra) # 5b64 <exit>

0000000000002ec8 <sbrk8000>:
{
    2ec8:	1141                	addi	sp,sp,-16
    2eca:	e406                	sd	ra,8(sp)
    2ecc:	e022                	sd	s0,0(sp)
    2ece:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2ed0:	80000537          	lui	a0,0x80000
    2ed4:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff038c>
    2ed6:	00003097          	auipc	ra,0x3
    2eda:	d16080e7          	jalr	-746(ra) # 5bec <sbrk>
  volatile char *top = sbrk(0);
    2ede:	4501                	li	a0,0
    2ee0:	00003097          	auipc	ra,0x3
    2ee4:	d0c080e7          	jalr	-756(ra) # 5bec <sbrk>
  *(top - 1) = *(top - 1) + 1;
    2ee8:	fff54783          	lbu	a5,-1(a0)
    2eec:	2785                	addiw	a5,a5,1 # 1001 <linktest+0xfb>
    2eee:	0ff7f793          	zext.b	a5,a5
    2ef2:	fef50fa3          	sb	a5,-1(a0)
}
    2ef6:	60a2                	ld	ra,8(sp)
    2ef8:	6402                	ld	s0,0(sp)
    2efa:	0141                	addi	sp,sp,16
    2efc:	8082                	ret

0000000000002efe <execout>:
{
    2efe:	715d                	addi	sp,sp,-80
    2f00:	e486                	sd	ra,72(sp)
    2f02:	e0a2                	sd	s0,64(sp)
    2f04:	fc26                	sd	s1,56(sp)
    2f06:	f84a                	sd	s2,48(sp)
    2f08:	f44e                	sd	s3,40(sp)
    2f0a:	f052                	sd	s4,32(sp)
    2f0c:	0880                	addi	s0,sp,80
  for (int avail = 0; avail < 15; avail++)
    2f0e:	4901                	li	s2,0
    2f10:	49bd                	li	s3,15
    int pid = fork();
    2f12:	00003097          	auipc	ra,0x3
    2f16:	c4a080e7          	jalr	-950(ra) # 5b5c <fork>
    2f1a:	84aa                	mv	s1,a0
    if (pid < 0)
    2f1c:	02054063          	bltz	a0,2f3c <execout+0x3e>
    else if (pid == 0)
    2f20:	c91d                	beqz	a0,2f56 <execout+0x58>
      wait((int *)0);
    2f22:	4501                	li	a0,0
    2f24:	00003097          	auipc	ra,0x3
    2f28:	c48080e7          	jalr	-952(ra) # 5b6c <wait>
  for (int avail = 0; avail < 15; avail++)
    2f2c:	2905                	addiw	s2,s2,1
    2f2e:	ff3912e3          	bne	s2,s3,2f12 <execout+0x14>
  exit(0);
    2f32:	4501                	li	a0,0
    2f34:	00003097          	auipc	ra,0x3
    2f38:	c30080e7          	jalr	-976(ra) # 5b64 <exit>
      printf("fork failed\n");
    2f3c:	00004517          	auipc	a0,0x4
    2f40:	e2c50513          	addi	a0,a0,-468 # 6d68 <malloc+0xdb2>
    2f44:	00003097          	auipc	ra,0x3
    2f48:	fba080e7          	jalr	-70(ra) # 5efe <printf>
      exit(1);
    2f4c:	4505                	li	a0,1
    2f4e:	00003097          	auipc	ra,0x3
    2f52:	c16080e7          	jalr	-1002(ra) # 5b64 <exit>
        if (a == 0xffffffffffffffffLL)
    2f56:	59fd                	li	s3,-1
        *(char *)(a + 4096 - 1) = 1;
    2f58:	4a05                	li	s4,1
        uint64 a = (uint64)sbrk(4096);
    2f5a:	6505                	lui	a0,0x1
    2f5c:	00003097          	auipc	ra,0x3
    2f60:	c90080e7          	jalr	-880(ra) # 5bec <sbrk>
        if (a == 0xffffffffffffffffLL)
    2f64:	01350763          	beq	a0,s3,2f72 <execout+0x74>
        *(char *)(a + 4096 - 1) = 1;
    2f68:	6785                	lui	a5,0x1
    2f6a:	97aa                	add	a5,a5,a0
    2f6c:	ff478fa3          	sb	s4,-1(a5) # fff <linktest+0xf9>
      {
    2f70:	b7ed                	j	2f5a <execout+0x5c>
      for (int i = 0; i < avail; i++)
    2f72:	01205a63          	blez	s2,2f86 <execout+0x88>
        sbrk(-4096);
    2f76:	757d                	lui	a0,0xfffff
    2f78:	00003097          	auipc	ra,0x3
    2f7c:	c74080e7          	jalr	-908(ra) # 5bec <sbrk>
      for (int i = 0; i < avail; i++)
    2f80:	2485                	addiw	s1,s1,1
    2f82:	ff249ae3          	bne	s1,s2,2f76 <execout+0x78>
      close(1);
    2f86:	4505                	li	a0,1
    2f88:	00003097          	auipc	ra,0x3
    2f8c:	c04080e7          	jalr	-1020(ra) # 5b8c <close>
      char *args[] = {"echo", "x", 0};
    2f90:	00003517          	auipc	a0,0x3
    2f94:	14850513          	addi	a0,a0,328 # 60d8 <malloc+0x122>
    2f98:	faa43c23          	sd	a0,-72(s0)
    2f9c:	00003797          	auipc	a5,0x3
    2fa0:	1ac78793          	addi	a5,a5,428 # 6148 <malloc+0x192>
    2fa4:	fcf43023          	sd	a5,-64(s0)
    2fa8:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2fac:	fb840593          	addi	a1,s0,-72
    2fb0:	00003097          	auipc	ra,0x3
    2fb4:	bec080e7          	jalr	-1044(ra) # 5b9c <exec>
      exit(0);
    2fb8:	4501                	li	a0,0
    2fba:	00003097          	auipc	ra,0x3
    2fbe:	baa080e7          	jalr	-1110(ra) # 5b64 <exit>

0000000000002fc2 <fourteen>:
{
    2fc2:	1101                	addi	sp,sp,-32
    2fc4:	ec06                	sd	ra,24(sp)
    2fc6:	e822                	sd	s0,16(sp)
    2fc8:	e426                	sd	s1,8(sp)
    2fca:	1000                	addi	s0,sp,32
    2fcc:	84aa                	mv	s1,a0
  if (mkdir("12345678901234") != 0)
    2fce:	00004517          	auipc	a0,0x4
    2fd2:	2aa50513          	addi	a0,a0,682 # 7278 <malloc+0x12c2>
    2fd6:	00003097          	auipc	ra,0x3
    2fda:	bf6080e7          	jalr	-1034(ra) # 5bcc <mkdir>
    2fde:	e165                	bnez	a0,30be <fourteen+0xfc>
  if (mkdir("12345678901234/123456789012345") != 0)
    2fe0:	00004517          	auipc	a0,0x4
    2fe4:	0f050513          	addi	a0,a0,240 # 70d0 <malloc+0x111a>
    2fe8:	00003097          	auipc	ra,0x3
    2fec:	be4080e7          	jalr	-1052(ra) # 5bcc <mkdir>
    2ff0:	e56d                	bnez	a0,30da <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2ff2:	20000593          	li	a1,512
    2ff6:	00004517          	auipc	a0,0x4
    2ffa:	13250513          	addi	a0,a0,306 # 7128 <malloc+0x1172>
    2ffe:	00003097          	auipc	ra,0x3
    3002:	ba6080e7          	jalr	-1114(ra) # 5ba4 <open>
  if (fd < 0)
    3006:	0e054863          	bltz	a0,30f6 <fourteen+0x134>
  close(fd);
    300a:	00003097          	auipc	ra,0x3
    300e:	b82080e7          	jalr	-1150(ra) # 5b8c <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3012:	4581                	li	a1,0
    3014:	00004517          	auipc	a0,0x4
    3018:	18c50513          	addi	a0,a0,396 # 71a0 <malloc+0x11ea>
    301c:	00003097          	auipc	ra,0x3
    3020:	b88080e7          	jalr	-1144(ra) # 5ba4 <open>
  if (fd < 0)
    3024:	0e054763          	bltz	a0,3112 <fourteen+0x150>
  close(fd);
    3028:	00003097          	auipc	ra,0x3
    302c:	b64080e7          	jalr	-1180(ra) # 5b8c <close>
  if (mkdir("12345678901234/12345678901234") == 0)
    3030:	00004517          	auipc	a0,0x4
    3034:	1e050513          	addi	a0,a0,480 # 7210 <malloc+0x125a>
    3038:	00003097          	auipc	ra,0x3
    303c:	b94080e7          	jalr	-1132(ra) # 5bcc <mkdir>
    3040:	c57d                	beqz	a0,312e <fourteen+0x16c>
  if (mkdir("123456789012345/12345678901234") == 0)
    3042:	00004517          	auipc	a0,0x4
    3046:	22650513          	addi	a0,a0,550 # 7268 <malloc+0x12b2>
    304a:	00003097          	auipc	ra,0x3
    304e:	b82080e7          	jalr	-1150(ra) # 5bcc <mkdir>
    3052:	cd65                	beqz	a0,314a <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    3054:	00004517          	auipc	a0,0x4
    3058:	21450513          	addi	a0,a0,532 # 7268 <malloc+0x12b2>
    305c:	00003097          	auipc	ra,0x3
    3060:	b58080e7          	jalr	-1192(ra) # 5bb4 <unlink>
  unlink("12345678901234/12345678901234");
    3064:	00004517          	auipc	a0,0x4
    3068:	1ac50513          	addi	a0,a0,428 # 7210 <malloc+0x125a>
    306c:	00003097          	auipc	ra,0x3
    3070:	b48080e7          	jalr	-1208(ra) # 5bb4 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    3074:	00004517          	auipc	a0,0x4
    3078:	12c50513          	addi	a0,a0,300 # 71a0 <malloc+0x11ea>
    307c:	00003097          	auipc	ra,0x3
    3080:	b38080e7          	jalr	-1224(ra) # 5bb4 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    3084:	00004517          	auipc	a0,0x4
    3088:	0a450513          	addi	a0,a0,164 # 7128 <malloc+0x1172>
    308c:	00003097          	auipc	ra,0x3
    3090:	b28080e7          	jalr	-1240(ra) # 5bb4 <unlink>
  unlink("12345678901234/123456789012345");
    3094:	00004517          	auipc	a0,0x4
    3098:	03c50513          	addi	a0,a0,60 # 70d0 <malloc+0x111a>
    309c:	00003097          	auipc	ra,0x3
    30a0:	b18080e7          	jalr	-1256(ra) # 5bb4 <unlink>
  unlink("12345678901234");
    30a4:	00004517          	auipc	a0,0x4
    30a8:	1d450513          	addi	a0,a0,468 # 7278 <malloc+0x12c2>
    30ac:	00003097          	auipc	ra,0x3
    30b0:	b08080e7          	jalr	-1272(ra) # 5bb4 <unlink>
}
    30b4:	60e2                	ld	ra,24(sp)
    30b6:	6442                	ld	s0,16(sp)
    30b8:	64a2                	ld	s1,8(sp)
    30ba:	6105                	addi	sp,sp,32
    30bc:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    30be:	85a6                	mv	a1,s1
    30c0:	00004517          	auipc	a0,0x4
    30c4:	fe850513          	addi	a0,a0,-24 # 70a8 <malloc+0x10f2>
    30c8:	00003097          	auipc	ra,0x3
    30cc:	e36080e7          	jalr	-458(ra) # 5efe <printf>
    exit(1);
    30d0:	4505                	li	a0,1
    30d2:	00003097          	auipc	ra,0x3
    30d6:	a92080e7          	jalr	-1390(ra) # 5b64 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    30da:	85a6                	mv	a1,s1
    30dc:	00004517          	auipc	a0,0x4
    30e0:	01450513          	addi	a0,a0,20 # 70f0 <malloc+0x113a>
    30e4:	00003097          	auipc	ra,0x3
    30e8:	e1a080e7          	jalr	-486(ra) # 5efe <printf>
    exit(1);
    30ec:	4505                	li	a0,1
    30ee:	00003097          	auipc	ra,0x3
    30f2:	a76080e7          	jalr	-1418(ra) # 5b64 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    30f6:	85a6                	mv	a1,s1
    30f8:	00004517          	auipc	a0,0x4
    30fc:	06050513          	addi	a0,a0,96 # 7158 <malloc+0x11a2>
    3100:	00003097          	auipc	ra,0x3
    3104:	dfe080e7          	jalr	-514(ra) # 5efe <printf>
    exit(1);
    3108:	4505                	li	a0,1
    310a:	00003097          	auipc	ra,0x3
    310e:	a5a080e7          	jalr	-1446(ra) # 5b64 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    3112:	85a6                	mv	a1,s1
    3114:	00004517          	auipc	a0,0x4
    3118:	0bc50513          	addi	a0,a0,188 # 71d0 <malloc+0x121a>
    311c:	00003097          	auipc	ra,0x3
    3120:	de2080e7          	jalr	-542(ra) # 5efe <printf>
    exit(1);
    3124:	4505                	li	a0,1
    3126:	00003097          	auipc	ra,0x3
    312a:	a3e080e7          	jalr	-1474(ra) # 5b64 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    312e:	85a6                	mv	a1,s1
    3130:	00004517          	auipc	a0,0x4
    3134:	10050513          	addi	a0,a0,256 # 7230 <malloc+0x127a>
    3138:	00003097          	auipc	ra,0x3
    313c:	dc6080e7          	jalr	-570(ra) # 5efe <printf>
    exit(1);
    3140:	4505                	li	a0,1
    3142:	00003097          	auipc	ra,0x3
    3146:	a22080e7          	jalr	-1502(ra) # 5b64 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    314a:	85a6                	mv	a1,s1
    314c:	00004517          	auipc	a0,0x4
    3150:	13c50513          	addi	a0,a0,316 # 7288 <malloc+0x12d2>
    3154:	00003097          	auipc	ra,0x3
    3158:	daa080e7          	jalr	-598(ra) # 5efe <printf>
    exit(1);
    315c:	4505                	li	a0,1
    315e:	00003097          	auipc	ra,0x3
    3162:	a06080e7          	jalr	-1530(ra) # 5b64 <exit>

0000000000003166 <diskfull>:
{
    3166:	b9010113          	addi	sp,sp,-1136
    316a:	46113423          	sd	ra,1128(sp)
    316e:	46813023          	sd	s0,1120(sp)
    3172:	44913c23          	sd	s1,1112(sp)
    3176:	45213823          	sd	s2,1104(sp)
    317a:	45313423          	sd	s3,1096(sp)
    317e:	45413023          	sd	s4,1088(sp)
    3182:	43513c23          	sd	s5,1080(sp)
    3186:	43613823          	sd	s6,1072(sp)
    318a:	43713423          	sd	s7,1064(sp)
    318e:	43813023          	sd	s8,1056(sp)
    3192:	47010413          	addi	s0,sp,1136
    3196:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
    3198:	00004517          	auipc	a0,0x4
    319c:	12850513          	addi	a0,a0,296 # 72c0 <malloc+0x130a>
    31a0:	00003097          	auipc	ra,0x3
    31a4:	a14080e7          	jalr	-1516(ra) # 5bb4 <unlink>
  for (fi = 0; done == 0; fi++)
    31a8:	4a01                	li	s4,0
    name[0] = 'b';
    31aa:	06200b13          	li	s6,98
    name[1] = 'i';
    31ae:	06900a93          	li	s5,105
    name[2] = 'g';
    31b2:	06700993          	li	s3,103
    31b6:	10c00b93          	li	s7,268
    31ba:	aabd                	j	3338 <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
    31bc:	b9040613          	addi	a2,s0,-1136
    31c0:	85e2                	mv	a1,s8
    31c2:	00004517          	auipc	a0,0x4
    31c6:	10e50513          	addi	a0,a0,270 # 72d0 <malloc+0x131a>
    31ca:	00003097          	auipc	ra,0x3
    31ce:	d34080e7          	jalr	-716(ra) # 5efe <printf>
      break;
    31d2:	a821                	j	31ea <diskfull+0x84>
        close(fd);
    31d4:	854a                	mv	a0,s2
    31d6:	00003097          	auipc	ra,0x3
    31da:	9b6080e7          	jalr	-1610(ra) # 5b8c <close>
    close(fd);
    31de:	854a                	mv	a0,s2
    31e0:	00003097          	auipc	ra,0x3
    31e4:	9ac080e7          	jalr	-1620(ra) # 5b8c <close>
  for (fi = 0; done == 0; fi++)
    31e8:	2a05                	addiw	s4,s4,1
  for (int i = 0; i < nzz; i++)
    31ea:	4481                	li	s1,0
    name[0] = 'z';
    31ec:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
    31f0:	08000993          	li	s3,128
    name[0] = 'z';
    31f4:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    31f8:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    31fc:	41f4d71b          	sraiw	a4,s1,0x1f
    3200:	01b7571b          	srliw	a4,a4,0x1b
    3204:	009707bb          	addw	a5,a4,s1
    3208:	4057d69b          	sraiw	a3,a5,0x5
    320c:	0306869b          	addiw	a3,a3,48
    3210:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3214:	8bfd                	andi	a5,a5,31
    3216:	9f99                	subw	a5,a5,a4
    3218:	0307879b          	addiw	a5,a5,48
    321c:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3220:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3224:	bb040513          	addi	a0,s0,-1104
    3228:	00003097          	auipc	ra,0x3
    322c:	98c080e7          	jalr	-1652(ra) # 5bb4 <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    3230:	60200593          	li	a1,1538
    3234:	bb040513          	addi	a0,s0,-1104
    3238:	00003097          	auipc	ra,0x3
    323c:	96c080e7          	jalr	-1684(ra) # 5ba4 <open>
    if (fd < 0)
    3240:	00054963          	bltz	a0,3252 <diskfull+0xec>
    close(fd);
    3244:	00003097          	auipc	ra,0x3
    3248:	948080e7          	jalr	-1720(ra) # 5b8c <close>
  for (int i = 0; i < nzz; i++)
    324c:	2485                	addiw	s1,s1,1
    324e:	fb3493e3          	bne	s1,s3,31f4 <diskfull+0x8e>
  if (mkdir("diskfulldir") == 0)
    3252:	00004517          	auipc	a0,0x4
    3256:	06e50513          	addi	a0,a0,110 # 72c0 <malloc+0x130a>
    325a:	00003097          	auipc	ra,0x3
    325e:	972080e7          	jalr	-1678(ra) # 5bcc <mkdir>
    3262:	12050963          	beqz	a0,3394 <diskfull+0x22e>
  unlink("diskfulldir");
    3266:	00004517          	auipc	a0,0x4
    326a:	05a50513          	addi	a0,a0,90 # 72c0 <malloc+0x130a>
    326e:	00003097          	auipc	ra,0x3
    3272:	946080e7          	jalr	-1722(ra) # 5bb4 <unlink>
  for (int i = 0; i < nzz; i++)
    3276:	4481                	li	s1,0
    name[0] = 'z';
    3278:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
    327c:	08000993          	li	s3,128
    name[0] = 'z';
    3280:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    3284:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    3288:	41f4d71b          	sraiw	a4,s1,0x1f
    328c:	01b7571b          	srliw	a4,a4,0x1b
    3290:	009707bb          	addw	a5,a4,s1
    3294:	4057d69b          	sraiw	a3,a5,0x5
    3298:	0306869b          	addiw	a3,a3,48
    329c:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    32a0:	8bfd                	andi	a5,a5,31
    32a2:	9f99                	subw	a5,a5,a4
    32a4:	0307879b          	addiw	a5,a5,48
    32a8:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    32ac:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    32b0:	bb040513          	addi	a0,s0,-1104
    32b4:	00003097          	auipc	ra,0x3
    32b8:	900080e7          	jalr	-1792(ra) # 5bb4 <unlink>
  for (int i = 0; i < nzz; i++)
    32bc:	2485                	addiw	s1,s1,1
    32be:	fd3491e3          	bne	s1,s3,3280 <diskfull+0x11a>
  for (int i = 0; i < fi; i++)
    32c2:	03405e63          	blez	s4,32fe <diskfull+0x198>
    32c6:	4481                	li	s1,0
    name[0] = 'b';
    32c8:	06200a93          	li	s5,98
    name[1] = 'i';
    32cc:	06900993          	li	s3,105
    name[2] = 'g';
    32d0:	06700913          	li	s2,103
    name[0] = 'b';
    32d4:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    32d8:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    32dc:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    32e0:	0304879b          	addiw	a5,s1,48
    32e4:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    32e8:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    32ec:	bb040513          	addi	a0,s0,-1104
    32f0:	00003097          	auipc	ra,0x3
    32f4:	8c4080e7          	jalr	-1852(ra) # 5bb4 <unlink>
  for (int i = 0; i < fi; i++)
    32f8:	2485                	addiw	s1,s1,1
    32fa:	fd449de3          	bne	s1,s4,32d4 <diskfull+0x16e>
}
    32fe:	46813083          	ld	ra,1128(sp)
    3302:	46013403          	ld	s0,1120(sp)
    3306:	45813483          	ld	s1,1112(sp)
    330a:	45013903          	ld	s2,1104(sp)
    330e:	44813983          	ld	s3,1096(sp)
    3312:	44013a03          	ld	s4,1088(sp)
    3316:	43813a83          	ld	s5,1080(sp)
    331a:	43013b03          	ld	s6,1072(sp)
    331e:	42813b83          	ld	s7,1064(sp)
    3322:	42013c03          	ld	s8,1056(sp)
    3326:	47010113          	addi	sp,sp,1136
    332a:	8082                	ret
    close(fd);
    332c:	854a                	mv	a0,s2
    332e:	00003097          	auipc	ra,0x3
    3332:	85e080e7          	jalr	-1954(ra) # 5b8c <close>
  for (fi = 0; done == 0; fi++)
    3336:	2a05                	addiw	s4,s4,1
    name[0] = 'b';
    3338:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    333c:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    3340:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    3344:	030a079b          	addiw	a5,s4,48
    3348:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    334c:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    3350:	b9040513          	addi	a0,s0,-1136
    3354:	00003097          	auipc	ra,0x3
    3358:	860080e7          	jalr	-1952(ra) # 5bb4 <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    335c:	60200593          	li	a1,1538
    3360:	b9040513          	addi	a0,s0,-1136
    3364:	00003097          	auipc	ra,0x3
    3368:	840080e7          	jalr	-1984(ra) # 5ba4 <open>
    336c:	892a                	mv	s2,a0
    if (fd < 0)
    336e:	e40547e3          	bltz	a0,31bc <diskfull+0x56>
    3372:	84de                	mv	s1,s7
      if (write(fd, buf, BSIZE) != BSIZE)
    3374:	40000613          	li	a2,1024
    3378:	bb040593          	addi	a1,s0,-1104
    337c:	854a                	mv	a0,s2
    337e:	00003097          	auipc	ra,0x3
    3382:	806080e7          	jalr	-2042(ra) # 5b84 <write>
    3386:	40000793          	li	a5,1024
    338a:	e4f515e3          	bne	a0,a5,31d4 <diskfull+0x6e>
    for (int i = 0; i < MAXFILE; i++)
    338e:	34fd                	addiw	s1,s1,-1
    3390:	f0f5                	bnez	s1,3374 <diskfull+0x20e>
    3392:	bf69                	j	332c <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    3394:	00004517          	auipc	a0,0x4
    3398:	f5c50513          	addi	a0,a0,-164 # 72f0 <malloc+0x133a>
    339c:	00003097          	auipc	ra,0x3
    33a0:	b62080e7          	jalr	-1182(ra) # 5efe <printf>
    33a4:	b5c9                	j	3266 <diskfull+0x100>

00000000000033a6 <iputtest>:
{
    33a6:	1101                	addi	sp,sp,-32
    33a8:	ec06                	sd	ra,24(sp)
    33aa:	e822                	sd	s0,16(sp)
    33ac:	e426                	sd	s1,8(sp)
    33ae:	1000                	addi	s0,sp,32
    33b0:	84aa                	mv	s1,a0
  if (mkdir("iputdir") < 0)
    33b2:	00004517          	auipc	a0,0x4
    33b6:	f6e50513          	addi	a0,a0,-146 # 7320 <malloc+0x136a>
    33ba:	00003097          	auipc	ra,0x3
    33be:	812080e7          	jalr	-2030(ra) # 5bcc <mkdir>
    33c2:	04054563          	bltz	a0,340c <iputtest+0x66>
  if (chdir("iputdir") < 0)
    33c6:	00004517          	auipc	a0,0x4
    33ca:	f5a50513          	addi	a0,a0,-166 # 7320 <malloc+0x136a>
    33ce:	00003097          	auipc	ra,0x3
    33d2:	806080e7          	jalr	-2042(ra) # 5bd4 <chdir>
    33d6:	04054963          	bltz	a0,3428 <iputtest+0x82>
  if (unlink("../iputdir") < 0)
    33da:	00004517          	auipc	a0,0x4
    33de:	f8650513          	addi	a0,a0,-122 # 7360 <malloc+0x13aa>
    33e2:	00002097          	auipc	ra,0x2
    33e6:	7d2080e7          	jalr	2002(ra) # 5bb4 <unlink>
    33ea:	04054d63          	bltz	a0,3444 <iputtest+0x9e>
  if (chdir("/") < 0)
    33ee:	00004517          	auipc	a0,0x4
    33f2:	fa250513          	addi	a0,a0,-94 # 7390 <malloc+0x13da>
    33f6:	00002097          	auipc	ra,0x2
    33fa:	7de080e7          	jalr	2014(ra) # 5bd4 <chdir>
    33fe:	06054163          	bltz	a0,3460 <iputtest+0xba>
}
    3402:	60e2                	ld	ra,24(sp)
    3404:	6442                	ld	s0,16(sp)
    3406:	64a2                	ld	s1,8(sp)
    3408:	6105                	addi	sp,sp,32
    340a:	8082                	ret
    printf("%s: mkdir failed\n", s);
    340c:	85a6                	mv	a1,s1
    340e:	00004517          	auipc	a0,0x4
    3412:	f1a50513          	addi	a0,a0,-230 # 7328 <malloc+0x1372>
    3416:	00003097          	auipc	ra,0x3
    341a:	ae8080e7          	jalr	-1304(ra) # 5efe <printf>
    exit(1);
    341e:	4505                	li	a0,1
    3420:	00002097          	auipc	ra,0x2
    3424:	744080e7          	jalr	1860(ra) # 5b64 <exit>
    printf("%s: chdir iputdir failed\n", s);
    3428:	85a6                	mv	a1,s1
    342a:	00004517          	auipc	a0,0x4
    342e:	f1650513          	addi	a0,a0,-234 # 7340 <malloc+0x138a>
    3432:	00003097          	auipc	ra,0x3
    3436:	acc080e7          	jalr	-1332(ra) # 5efe <printf>
    exit(1);
    343a:	4505                	li	a0,1
    343c:	00002097          	auipc	ra,0x2
    3440:	728080e7          	jalr	1832(ra) # 5b64 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    3444:	85a6                	mv	a1,s1
    3446:	00004517          	auipc	a0,0x4
    344a:	f2a50513          	addi	a0,a0,-214 # 7370 <malloc+0x13ba>
    344e:	00003097          	auipc	ra,0x3
    3452:	ab0080e7          	jalr	-1360(ra) # 5efe <printf>
    exit(1);
    3456:	4505                	li	a0,1
    3458:	00002097          	auipc	ra,0x2
    345c:	70c080e7          	jalr	1804(ra) # 5b64 <exit>
    printf("%s: chdir / failed\n", s);
    3460:	85a6                	mv	a1,s1
    3462:	00004517          	auipc	a0,0x4
    3466:	f3650513          	addi	a0,a0,-202 # 7398 <malloc+0x13e2>
    346a:	00003097          	auipc	ra,0x3
    346e:	a94080e7          	jalr	-1388(ra) # 5efe <printf>
    exit(1);
    3472:	4505                	li	a0,1
    3474:	00002097          	auipc	ra,0x2
    3478:	6f0080e7          	jalr	1776(ra) # 5b64 <exit>

000000000000347c <exitiputtest>:
{
    347c:	7179                	addi	sp,sp,-48
    347e:	f406                	sd	ra,40(sp)
    3480:	f022                	sd	s0,32(sp)
    3482:	ec26                	sd	s1,24(sp)
    3484:	1800                	addi	s0,sp,48
    3486:	84aa                	mv	s1,a0
  pid = fork();
    3488:	00002097          	auipc	ra,0x2
    348c:	6d4080e7          	jalr	1748(ra) # 5b5c <fork>
  if (pid < 0)
    3490:	04054663          	bltz	a0,34dc <exitiputtest+0x60>
  if (pid == 0)
    3494:	ed45                	bnez	a0,354c <exitiputtest+0xd0>
    if (mkdir("iputdir") < 0)
    3496:	00004517          	auipc	a0,0x4
    349a:	e8a50513          	addi	a0,a0,-374 # 7320 <malloc+0x136a>
    349e:	00002097          	auipc	ra,0x2
    34a2:	72e080e7          	jalr	1838(ra) # 5bcc <mkdir>
    34a6:	04054963          	bltz	a0,34f8 <exitiputtest+0x7c>
    if (chdir("iputdir") < 0)
    34aa:	00004517          	auipc	a0,0x4
    34ae:	e7650513          	addi	a0,a0,-394 # 7320 <malloc+0x136a>
    34b2:	00002097          	auipc	ra,0x2
    34b6:	722080e7          	jalr	1826(ra) # 5bd4 <chdir>
    34ba:	04054d63          	bltz	a0,3514 <exitiputtest+0x98>
    if (unlink("../iputdir") < 0)
    34be:	00004517          	auipc	a0,0x4
    34c2:	ea250513          	addi	a0,a0,-350 # 7360 <malloc+0x13aa>
    34c6:	00002097          	auipc	ra,0x2
    34ca:	6ee080e7          	jalr	1774(ra) # 5bb4 <unlink>
    34ce:	06054163          	bltz	a0,3530 <exitiputtest+0xb4>
    exit(0);
    34d2:	4501                	li	a0,0
    34d4:	00002097          	auipc	ra,0x2
    34d8:	690080e7          	jalr	1680(ra) # 5b64 <exit>
    printf("%s: fork failed\n", s);
    34dc:	85a6                	mv	a1,s1
    34de:	00003517          	auipc	a0,0x3
    34e2:	48250513          	addi	a0,a0,1154 # 6960 <malloc+0x9aa>
    34e6:	00003097          	auipc	ra,0x3
    34ea:	a18080e7          	jalr	-1512(ra) # 5efe <printf>
    exit(1);
    34ee:	4505                	li	a0,1
    34f0:	00002097          	auipc	ra,0x2
    34f4:	674080e7          	jalr	1652(ra) # 5b64 <exit>
      printf("%s: mkdir failed\n", s);
    34f8:	85a6                	mv	a1,s1
    34fa:	00004517          	auipc	a0,0x4
    34fe:	e2e50513          	addi	a0,a0,-466 # 7328 <malloc+0x1372>
    3502:	00003097          	auipc	ra,0x3
    3506:	9fc080e7          	jalr	-1540(ra) # 5efe <printf>
      exit(1);
    350a:	4505                	li	a0,1
    350c:	00002097          	auipc	ra,0x2
    3510:	658080e7          	jalr	1624(ra) # 5b64 <exit>
      printf("%s: child chdir failed\n", s);
    3514:	85a6                	mv	a1,s1
    3516:	00004517          	auipc	a0,0x4
    351a:	e9a50513          	addi	a0,a0,-358 # 73b0 <malloc+0x13fa>
    351e:	00003097          	auipc	ra,0x3
    3522:	9e0080e7          	jalr	-1568(ra) # 5efe <printf>
      exit(1);
    3526:	4505                	li	a0,1
    3528:	00002097          	auipc	ra,0x2
    352c:	63c080e7          	jalr	1596(ra) # 5b64 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    3530:	85a6                	mv	a1,s1
    3532:	00004517          	auipc	a0,0x4
    3536:	e3e50513          	addi	a0,a0,-450 # 7370 <malloc+0x13ba>
    353a:	00003097          	auipc	ra,0x3
    353e:	9c4080e7          	jalr	-1596(ra) # 5efe <printf>
      exit(1);
    3542:	4505                	li	a0,1
    3544:	00002097          	auipc	ra,0x2
    3548:	620080e7          	jalr	1568(ra) # 5b64 <exit>
  wait(&xstatus);
    354c:	fdc40513          	addi	a0,s0,-36
    3550:	00002097          	auipc	ra,0x2
    3554:	61c080e7          	jalr	1564(ra) # 5b6c <wait>
  exit(xstatus);
    3558:	fdc42503          	lw	a0,-36(s0)
    355c:	00002097          	auipc	ra,0x2
    3560:	608080e7          	jalr	1544(ra) # 5b64 <exit>

0000000000003564 <dirtest>:
{
    3564:	1101                	addi	sp,sp,-32
    3566:	ec06                	sd	ra,24(sp)
    3568:	e822                	sd	s0,16(sp)
    356a:	e426                	sd	s1,8(sp)
    356c:	1000                	addi	s0,sp,32
    356e:	84aa                	mv	s1,a0
  if (mkdir("dir0") < 0)
    3570:	00004517          	auipc	a0,0x4
    3574:	e5850513          	addi	a0,a0,-424 # 73c8 <malloc+0x1412>
    3578:	00002097          	auipc	ra,0x2
    357c:	654080e7          	jalr	1620(ra) # 5bcc <mkdir>
    3580:	04054563          	bltz	a0,35ca <dirtest+0x66>
  if (chdir("dir0") < 0)
    3584:	00004517          	auipc	a0,0x4
    3588:	e4450513          	addi	a0,a0,-444 # 73c8 <malloc+0x1412>
    358c:	00002097          	auipc	ra,0x2
    3590:	648080e7          	jalr	1608(ra) # 5bd4 <chdir>
    3594:	04054963          	bltz	a0,35e6 <dirtest+0x82>
  if (chdir("..") < 0)
    3598:	00004517          	auipc	a0,0x4
    359c:	e5050513          	addi	a0,a0,-432 # 73e8 <malloc+0x1432>
    35a0:	00002097          	auipc	ra,0x2
    35a4:	634080e7          	jalr	1588(ra) # 5bd4 <chdir>
    35a8:	04054d63          	bltz	a0,3602 <dirtest+0x9e>
  if (unlink("dir0") < 0)
    35ac:	00004517          	auipc	a0,0x4
    35b0:	e1c50513          	addi	a0,a0,-484 # 73c8 <malloc+0x1412>
    35b4:	00002097          	auipc	ra,0x2
    35b8:	600080e7          	jalr	1536(ra) # 5bb4 <unlink>
    35bc:	06054163          	bltz	a0,361e <dirtest+0xba>
}
    35c0:	60e2                	ld	ra,24(sp)
    35c2:	6442                	ld	s0,16(sp)
    35c4:	64a2                	ld	s1,8(sp)
    35c6:	6105                	addi	sp,sp,32
    35c8:	8082                	ret
    printf("%s: mkdir failed\n", s);
    35ca:	85a6                	mv	a1,s1
    35cc:	00004517          	auipc	a0,0x4
    35d0:	d5c50513          	addi	a0,a0,-676 # 7328 <malloc+0x1372>
    35d4:	00003097          	auipc	ra,0x3
    35d8:	92a080e7          	jalr	-1750(ra) # 5efe <printf>
    exit(1);
    35dc:	4505                	li	a0,1
    35de:	00002097          	auipc	ra,0x2
    35e2:	586080e7          	jalr	1414(ra) # 5b64 <exit>
    printf("%s: chdir dir0 failed\n", s);
    35e6:	85a6                	mv	a1,s1
    35e8:	00004517          	auipc	a0,0x4
    35ec:	de850513          	addi	a0,a0,-536 # 73d0 <malloc+0x141a>
    35f0:	00003097          	auipc	ra,0x3
    35f4:	90e080e7          	jalr	-1778(ra) # 5efe <printf>
    exit(1);
    35f8:	4505                	li	a0,1
    35fa:	00002097          	auipc	ra,0x2
    35fe:	56a080e7          	jalr	1386(ra) # 5b64 <exit>
    printf("%s: chdir .. failed\n", s);
    3602:	85a6                	mv	a1,s1
    3604:	00004517          	auipc	a0,0x4
    3608:	dec50513          	addi	a0,a0,-532 # 73f0 <malloc+0x143a>
    360c:	00003097          	auipc	ra,0x3
    3610:	8f2080e7          	jalr	-1806(ra) # 5efe <printf>
    exit(1);
    3614:	4505                	li	a0,1
    3616:	00002097          	auipc	ra,0x2
    361a:	54e080e7          	jalr	1358(ra) # 5b64 <exit>
    printf("%s: unlink dir0 failed\n", s);
    361e:	85a6                	mv	a1,s1
    3620:	00004517          	auipc	a0,0x4
    3624:	de850513          	addi	a0,a0,-536 # 7408 <malloc+0x1452>
    3628:	00003097          	auipc	ra,0x3
    362c:	8d6080e7          	jalr	-1834(ra) # 5efe <printf>
    exit(1);
    3630:	4505                	li	a0,1
    3632:	00002097          	auipc	ra,0x2
    3636:	532080e7          	jalr	1330(ra) # 5b64 <exit>

000000000000363a <subdir>:
{
    363a:	1101                	addi	sp,sp,-32
    363c:	ec06                	sd	ra,24(sp)
    363e:	e822                	sd	s0,16(sp)
    3640:	e426                	sd	s1,8(sp)
    3642:	e04a                	sd	s2,0(sp)
    3644:	1000                	addi	s0,sp,32
    3646:	892a                	mv	s2,a0
  unlink("ff");
    3648:	00004517          	auipc	a0,0x4
    364c:	f0850513          	addi	a0,a0,-248 # 7550 <malloc+0x159a>
    3650:	00002097          	auipc	ra,0x2
    3654:	564080e7          	jalr	1380(ra) # 5bb4 <unlink>
  if (mkdir("dd") != 0)
    3658:	00004517          	auipc	a0,0x4
    365c:	dc850513          	addi	a0,a0,-568 # 7420 <malloc+0x146a>
    3660:	00002097          	auipc	ra,0x2
    3664:	56c080e7          	jalr	1388(ra) # 5bcc <mkdir>
    3668:	38051663          	bnez	a0,39f4 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    366c:	20200593          	li	a1,514
    3670:	00004517          	auipc	a0,0x4
    3674:	dd050513          	addi	a0,a0,-560 # 7440 <malloc+0x148a>
    3678:	00002097          	auipc	ra,0x2
    367c:	52c080e7          	jalr	1324(ra) # 5ba4 <open>
    3680:	84aa                	mv	s1,a0
  if (fd < 0)
    3682:	38054763          	bltz	a0,3a10 <subdir+0x3d6>
  write(fd, "ff", 2);
    3686:	4609                	li	a2,2
    3688:	00004597          	auipc	a1,0x4
    368c:	ec858593          	addi	a1,a1,-312 # 7550 <malloc+0x159a>
    3690:	00002097          	auipc	ra,0x2
    3694:	4f4080e7          	jalr	1268(ra) # 5b84 <write>
  close(fd);
    3698:	8526                	mv	a0,s1
    369a:	00002097          	auipc	ra,0x2
    369e:	4f2080e7          	jalr	1266(ra) # 5b8c <close>
  if (unlink("dd") >= 0)
    36a2:	00004517          	auipc	a0,0x4
    36a6:	d7e50513          	addi	a0,a0,-642 # 7420 <malloc+0x146a>
    36aa:	00002097          	auipc	ra,0x2
    36ae:	50a080e7          	jalr	1290(ra) # 5bb4 <unlink>
    36b2:	36055d63          	bgez	a0,3a2c <subdir+0x3f2>
  if (mkdir("/dd/dd") != 0)
    36b6:	00004517          	auipc	a0,0x4
    36ba:	de250513          	addi	a0,a0,-542 # 7498 <malloc+0x14e2>
    36be:	00002097          	auipc	ra,0x2
    36c2:	50e080e7          	jalr	1294(ra) # 5bcc <mkdir>
    36c6:	38051163          	bnez	a0,3a48 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    36ca:	20200593          	li	a1,514
    36ce:	00004517          	auipc	a0,0x4
    36d2:	df250513          	addi	a0,a0,-526 # 74c0 <malloc+0x150a>
    36d6:	00002097          	auipc	ra,0x2
    36da:	4ce080e7          	jalr	1230(ra) # 5ba4 <open>
    36de:	84aa                	mv	s1,a0
  if (fd < 0)
    36e0:	38054263          	bltz	a0,3a64 <subdir+0x42a>
  write(fd, "FF", 2);
    36e4:	4609                	li	a2,2
    36e6:	00004597          	auipc	a1,0x4
    36ea:	e0a58593          	addi	a1,a1,-502 # 74f0 <malloc+0x153a>
    36ee:	00002097          	auipc	ra,0x2
    36f2:	496080e7          	jalr	1174(ra) # 5b84 <write>
  close(fd);
    36f6:	8526                	mv	a0,s1
    36f8:	00002097          	auipc	ra,0x2
    36fc:	494080e7          	jalr	1172(ra) # 5b8c <close>
  fd = open("dd/dd/../ff", 0);
    3700:	4581                	li	a1,0
    3702:	00004517          	auipc	a0,0x4
    3706:	df650513          	addi	a0,a0,-522 # 74f8 <malloc+0x1542>
    370a:	00002097          	auipc	ra,0x2
    370e:	49a080e7          	jalr	1178(ra) # 5ba4 <open>
    3712:	84aa                	mv	s1,a0
  if (fd < 0)
    3714:	36054663          	bltz	a0,3a80 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3718:	660d                	lui	a2,0x3
    371a:	00009597          	auipc	a1,0x9
    371e:	55e58593          	addi	a1,a1,1374 # cc78 <buf>
    3722:	00002097          	auipc	ra,0x2
    3726:	45a080e7          	jalr	1114(ra) # 5b7c <read>
  if (cc != 2 || buf[0] != 'f')
    372a:	4789                	li	a5,2
    372c:	36f51863          	bne	a0,a5,3a9c <subdir+0x462>
    3730:	00009717          	auipc	a4,0x9
    3734:	54874703          	lbu	a4,1352(a4) # cc78 <buf>
    3738:	06600793          	li	a5,102
    373c:	36f71063          	bne	a4,a5,3a9c <subdir+0x462>
  close(fd);
    3740:	8526                	mv	a0,s1
    3742:	00002097          	auipc	ra,0x2
    3746:	44a080e7          	jalr	1098(ra) # 5b8c <close>
  if (link("dd/dd/ff", "dd/dd/ffff") != 0)
    374a:	00004597          	auipc	a1,0x4
    374e:	dfe58593          	addi	a1,a1,-514 # 7548 <malloc+0x1592>
    3752:	00004517          	auipc	a0,0x4
    3756:	d6e50513          	addi	a0,a0,-658 # 74c0 <malloc+0x150a>
    375a:	00002097          	auipc	ra,0x2
    375e:	46a080e7          	jalr	1130(ra) # 5bc4 <link>
    3762:	34051b63          	bnez	a0,3ab8 <subdir+0x47e>
  if (unlink("dd/dd/ff") != 0)
    3766:	00004517          	auipc	a0,0x4
    376a:	d5a50513          	addi	a0,a0,-678 # 74c0 <malloc+0x150a>
    376e:	00002097          	auipc	ra,0x2
    3772:	446080e7          	jalr	1094(ra) # 5bb4 <unlink>
    3776:	34051f63          	bnez	a0,3ad4 <subdir+0x49a>
  if (open("dd/dd/ff", O_RDONLY) >= 0)
    377a:	4581                	li	a1,0
    377c:	00004517          	auipc	a0,0x4
    3780:	d4450513          	addi	a0,a0,-700 # 74c0 <malloc+0x150a>
    3784:	00002097          	auipc	ra,0x2
    3788:	420080e7          	jalr	1056(ra) # 5ba4 <open>
    378c:	36055263          	bgez	a0,3af0 <subdir+0x4b6>
  if (chdir("dd") != 0)
    3790:	00004517          	auipc	a0,0x4
    3794:	c9050513          	addi	a0,a0,-880 # 7420 <malloc+0x146a>
    3798:	00002097          	auipc	ra,0x2
    379c:	43c080e7          	jalr	1084(ra) # 5bd4 <chdir>
    37a0:	36051663          	bnez	a0,3b0c <subdir+0x4d2>
  if (chdir("dd/../../dd") != 0)
    37a4:	00004517          	auipc	a0,0x4
    37a8:	e3c50513          	addi	a0,a0,-452 # 75e0 <malloc+0x162a>
    37ac:	00002097          	auipc	ra,0x2
    37b0:	428080e7          	jalr	1064(ra) # 5bd4 <chdir>
    37b4:	36051a63          	bnez	a0,3b28 <subdir+0x4ee>
  if (chdir("dd/../../../dd") != 0)
    37b8:	00004517          	auipc	a0,0x4
    37bc:	e5850513          	addi	a0,a0,-424 # 7610 <malloc+0x165a>
    37c0:	00002097          	auipc	ra,0x2
    37c4:	414080e7          	jalr	1044(ra) # 5bd4 <chdir>
    37c8:	36051e63          	bnez	a0,3b44 <subdir+0x50a>
  if (chdir("./..") != 0)
    37cc:	00004517          	auipc	a0,0x4
    37d0:	e7450513          	addi	a0,a0,-396 # 7640 <malloc+0x168a>
    37d4:	00002097          	auipc	ra,0x2
    37d8:	400080e7          	jalr	1024(ra) # 5bd4 <chdir>
    37dc:	38051263          	bnez	a0,3b60 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    37e0:	4581                	li	a1,0
    37e2:	00004517          	auipc	a0,0x4
    37e6:	d6650513          	addi	a0,a0,-666 # 7548 <malloc+0x1592>
    37ea:	00002097          	auipc	ra,0x2
    37ee:	3ba080e7          	jalr	954(ra) # 5ba4 <open>
    37f2:	84aa                	mv	s1,a0
  if (fd < 0)
    37f4:	38054463          	bltz	a0,3b7c <subdir+0x542>
  if (read(fd, buf, sizeof(buf)) != 2)
    37f8:	660d                	lui	a2,0x3
    37fa:	00009597          	auipc	a1,0x9
    37fe:	47e58593          	addi	a1,a1,1150 # cc78 <buf>
    3802:	00002097          	auipc	ra,0x2
    3806:	37a080e7          	jalr	890(ra) # 5b7c <read>
    380a:	4789                	li	a5,2
    380c:	38f51663          	bne	a0,a5,3b98 <subdir+0x55e>
  close(fd);
    3810:	8526                	mv	a0,s1
    3812:	00002097          	auipc	ra,0x2
    3816:	37a080e7          	jalr	890(ra) # 5b8c <close>
  if (open("dd/dd/ff", O_RDONLY) >= 0)
    381a:	4581                	li	a1,0
    381c:	00004517          	auipc	a0,0x4
    3820:	ca450513          	addi	a0,a0,-860 # 74c0 <malloc+0x150a>
    3824:	00002097          	auipc	ra,0x2
    3828:	380080e7          	jalr	896(ra) # 5ba4 <open>
    382c:	38055463          	bgez	a0,3bb4 <subdir+0x57a>
  if (open("dd/ff/ff", O_CREATE | O_RDWR) >= 0)
    3830:	20200593          	li	a1,514
    3834:	00004517          	auipc	a0,0x4
    3838:	e9c50513          	addi	a0,a0,-356 # 76d0 <malloc+0x171a>
    383c:	00002097          	auipc	ra,0x2
    3840:	368080e7          	jalr	872(ra) # 5ba4 <open>
    3844:	38055663          	bgez	a0,3bd0 <subdir+0x596>
  if (open("dd/xx/ff", O_CREATE | O_RDWR) >= 0)
    3848:	20200593          	li	a1,514
    384c:	00004517          	auipc	a0,0x4
    3850:	eb450513          	addi	a0,a0,-332 # 7700 <malloc+0x174a>
    3854:	00002097          	auipc	ra,0x2
    3858:	350080e7          	jalr	848(ra) # 5ba4 <open>
    385c:	38055863          	bgez	a0,3bec <subdir+0x5b2>
  if (open("dd", O_CREATE) >= 0)
    3860:	20000593          	li	a1,512
    3864:	00004517          	auipc	a0,0x4
    3868:	bbc50513          	addi	a0,a0,-1092 # 7420 <malloc+0x146a>
    386c:	00002097          	auipc	ra,0x2
    3870:	338080e7          	jalr	824(ra) # 5ba4 <open>
    3874:	38055a63          	bgez	a0,3c08 <subdir+0x5ce>
  if (open("dd", O_RDWR) >= 0)
    3878:	4589                	li	a1,2
    387a:	00004517          	auipc	a0,0x4
    387e:	ba650513          	addi	a0,a0,-1114 # 7420 <malloc+0x146a>
    3882:	00002097          	auipc	ra,0x2
    3886:	322080e7          	jalr	802(ra) # 5ba4 <open>
    388a:	38055d63          	bgez	a0,3c24 <subdir+0x5ea>
  if (open("dd", O_WRONLY) >= 0)
    388e:	4585                	li	a1,1
    3890:	00004517          	auipc	a0,0x4
    3894:	b9050513          	addi	a0,a0,-1136 # 7420 <malloc+0x146a>
    3898:	00002097          	auipc	ra,0x2
    389c:	30c080e7          	jalr	780(ra) # 5ba4 <open>
    38a0:	3a055063          	bgez	a0,3c40 <subdir+0x606>
  if (link("dd/ff/ff", "dd/dd/xx") == 0)
    38a4:	00004597          	auipc	a1,0x4
    38a8:	eec58593          	addi	a1,a1,-276 # 7790 <malloc+0x17da>
    38ac:	00004517          	auipc	a0,0x4
    38b0:	e2450513          	addi	a0,a0,-476 # 76d0 <malloc+0x171a>
    38b4:	00002097          	auipc	ra,0x2
    38b8:	310080e7          	jalr	784(ra) # 5bc4 <link>
    38bc:	3a050063          	beqz	a0,3c5c <subdir+0x622>
  if (link("dd/xx/ff", "dd/dd/xx") == 0)
    38c0:	00004597          	auipc	a1,0x4
    38c4:	ed058593          	addi	a1,a1,-304 # 7790 <malloc+0x17da>
    38c8:	00004517          	auipc	a0,0x4
    38cc:	e3850513          	addi	a0,a0,-456 # 7700 <malloc+0x174a>
    38d0:	00002097          	auipc	ra,0x2
    38d4:	2f4080e7          	jalr	756(ra) # 5bc4 <link>
    38d8:	3a050063          	beqz	a0,3c78 <subdir+0x63e>
  if (link("dd/ff", "dd/dd/ffff") == 0)
    38dc:	00004597          	auipc	a1,0x4
    38e0:	c6c58593          	addi	a1,a1,-916 # 7548 <malloc+0x1592>
    38e4:	00004517          	auipc	a0,0x4
    38e8:	b5c50513          	addi	a0,a0,-1188 # 7440 <malloc+0x148a>
    38ec:	00002097          	auipc	ra,0x2
    38f0:	2d8080e7          	jalr	728(ra) # 5bc4 <link>
    38f4:	3a050063          	beqz	a0,3c94 <subdir+0x65a>
  if (mkdir("dd/ff/ff") == 0)
    38f8:	00004517          	auipc	a0,0x4
    38fc:	dd850513          	addi	a0,a0,-552 # 76d0 <malloc+0x171a>
    3900:	00002097          	auipc	ra,0x2
    3904:	2cc080e7          	jalr	716(ra) # 5bcc <mkdir>
    3908:	3a050463          	beqz	a0,3cb0 <subdir+0x676>
  if (mkdir("dd/xx/ff") == 0)
    390c:	00004517          	auipc	a0,0x4
    3910:	df450513          	addi	a0,a0,-524 # 7700 <malloc+0x174a>
    3914:	00002097          	auipc	ra,0x2
    3918:	2b8080e7          	jalr	696(ra) # 5bcc <mkdir>
    391c:	3a050863          	beqz	a0,3ccc <subdir+0x692>
  if (mkdir("dd/dd/ffff") == 0)
    3920:	00004517          	auipc	a0,0x4
    3924:	c2850513          	addi	a0,a0,-984 # 7548 <malloc+0x1592>
    3928:	00002097          	auipc	ra,0x2
    392c:	2a4080e7          	jalr	676(ra) # 5bcc <mkdir>
    3930:	3a050c63          	beqz	a0,3ce8 <subdir+0x6ae>
  if (unlink("dd/xx/ff") == 0)
    3934:	00004517          	auipc	a0,0x4
    3938:	dcc50513          	addi	a0,a0,-564 # 7700 <malloc+0x174a>
    393c:	00002097          	auipc	ra,0x2
    3940:	278080e7          	jalr	632(ra) # 5bb4 <unlink>
    3944:	3c050063          	beqz	a0,3d04 <subdir+0x6ca>
  if (unlink("dd/ff/ff") == 0)
    3948:	00004517          	auipc	a0,0x4
    394c:	d8850513          	addi	a0,a0,-632 # 76d0 <malloc+0x171a>
    3950:	00002097          	auipc	ra,0x2
    3954:	264080e7          	jalr	612(ra) # 5bb4 <unlink>
    3958:	3c050463          	beqz	a0,3d20 <subdir+0x6e6>
  if (chdir("dd/ff") == 0)
    395c:	00004517          	auipc	a0,0x4
    3960:	ae450513          	addi	a0,a0,-1308 # 7440 <malloc+0x148a>
    3964:	00002097          	auipc	ra,0x2
    3968:	270080e7          	jalr	624(ra) # 5bd4 <chdir>
    396c:	3c050863          	beqz	a0,3d3c <subdir+0x702>
  if (chdir("dd/xx") == 0)
    3970:	00004517          	auipc	a0,0x4
    3974:	f7050513          	addi	a0,a0,-144 # 78e0 <malloc+0x192a>
    3978:	00002097          	auipc	ra,0x2
    397c:	25c080e7          	jalr	604(ra) # 5bd4 <chdir>
    3980:	3c050c63          	beqz	a0,3d58 <subdir+0x71e>
  if (unlink("dd/dd/ffff") != 0)
    3984:	00004517          	auipc	a0,0x4
    3988:	bc450513          	addi	a0,a0,-1084 # 7548 <malloc+0x1592>
    398c:	00002097          	auipc	ra,0x2
    3990:	228080e7          	jalr	552(ra) # 5bb4 <unlink>
    3994:	3e051063          	bnez	a0,3d74 <subdir+0x73a>
  if (unlink("dd/ff") != 0)
    3998:	00004517          	auipc	a0,0x4
    399c:	aa850513          	addi	a0,a0,-1368 # 7440 <malloc+0x148a>
    39a0:	00002097          	auipc	ra,0x2
    39a4:	214080e7          	jalr	532(ra) # 5bb4 <unlink>
    39a8:	3e051463          	bnez	a0,3d90 <subdir+0x756>
  if (unlink("dd") == 0)
    39ac:	00004517          	auipc	a0,0x4
    39b0:	a7450513          	addi	a0,a0,-1420 # 7420 <malloc+0x146a>
    39b4:	00002097          	auipc	ra,0x2
    39b8:	200080e7          	jalr	512(ra) # 5bb4 <unlink>
    39bc:	3e050863          	beqz	a0,3dac <subdir+0x772>
  if (unlink("dd/dd") < 0)
    39c0:	00004517          	auipc	a0,0x4
    39c4:	f9050513          	addi	a0,a0,-112 # 7950 <malloc+0x199a>
    39c8:	00002097          	auipc	ra,0x2
    39cc:	1ec080e7          	jalr	492(ra) # 5bb4 <unlink>
    39d0:	3e054c63          	bltz	a0,3dc8 <subdir+0x78e>
  if (unlink("dd") < 0)
    39d4:	00004517          	auipc	a0,0x4
    39d8:	a4c50513          	addi	a0,a0,-1460 # 7420 <malloc+0x146a>
    39dc:	00002097          	auipc	ra,0x2
    39e0:	1d8080e7          	jalr	472(ra) # 5bb4 <unlink>
    39e4:	40054063          	bltz	a0,3de4 <subdir+0x7aa>
}
    39e8:	60e2                	ld	ra,24(sp)
    39ea:	6442                	ld	s0,16(sp)
    39ec:	64a2                	ld	s1,8(sp)
    39ee:	6902                	ld	s2,0(sp)
    39f0:	6105                	addi	sp,sp,32
    39f2:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    39f4:	85ca                	mv	a1,s2
    39f6:	00004517          	auipc	a0,0x4
    39fa:	a3250513          	addi	a0,a0,-1486 # 7428 <malloc+0x1472>
    39fe:	00002097          	auipc	ra,0x2
    3a02:	500080e7          	jalr	1280(ra) # 5efe <printf>
    exit(1);
    3a06:	4505                	li	a0,1
    3a08:	00002097          	auipc	ra,0x2
    3a0c:	15c080e7          	jalr	348(ra) # 5b64 <exit>
    printf("%s: create dd/ff failed\n", s);
    3a10:	85ca                	mv	a1,s2
    3a12:	00004517          	auipc	a0,0x4
    3a16:	a3650513          	addi	a0,a0,-1482 # 7448 <malloc+0x1492>
    3a1a:	00002097          	auipc	ra,0x2
    3a1e:	4e4080e7          	jalr	1252(ra) # 5efe <printf>
    exit(1);
    3a22:	4505                	li	a0,1
    3a24:	00002097          	auipc	ra,0x2
    3a28:	140080e7          	jalr	320(ra) # 5b64 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3a2c:	85ca                	mv	a1,s2
    3a2e:	00004517          	auipc	a0,0x4
    3a32:	a3a50513          	addi	a0,a0,-1478 # 7468 <malloc+0x14b2>
    3a36:	00002097          	auipc	ra,0x2
    3a3a:	4c8080e7          	jalr	1224(ra) # 5efe <printf>
    exit(1);
    3a3e:	4505                	li	a0,1
    3a40:	00002097          	auipc	ra,0x2
    3a44:	124080e7          	jalr	292(ra) # 5b64 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3a48:	85ca                	mv	a1,s2
    3a4a:	00004517          	auipc	a0,0x4
    3a4e:	a5650513          	addi	a0,a0,-1450 # 74a0 <malloc+0x14ea>
    3a52:	00002097          	auipc	ra,0x2
    3a56:	4ac080e7          	jalr	1196(ra) # 5efe <printf>
    exit(1);
    3a5a:	4505                	li	a0,1
    3a5c:	00002097          	auipc	ra,0x2
    3a60:	108080e7          	jalr	264(ra) # 5b64 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3a64:	85ca                	mv	a1,s2
    3a66:	00004517          	auipc	a0,0x4
    3a6a:	a6a50513          	addi	a0,a0,-1430 # 74d0 <malloc+0x151a>
    3a6e:	00002097          	auipc	ra,0x2
    3a72:	490080e7          	jalr	1168(ra) # 5efe <printf>
    exit(1);
    3a76:	4505                	li	a0,1
    3a78:	00002097          	auipc	ra,0x2
    3a7c:	0ec080e7          	jalr	236(ra) # 5b64 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3a80:	85ca                	mv	a1,s2
    3a82:	00004517          	auipc	a0,0x4
    3a86:	a8650513          	addi	a0,a0,-1402 # 7508 <malloc+0x1552>
    3a8a:	00002097          	auipc	ra,0x2
    3a8e:	474080e7          	jalr	1140(ra) # 5efe <printf>
    exit(1);
    3a92:	4505                	li	a0,1
    3a94:	00002097          	auipc	ra,0x2
    3a98:	0d0080e7          	jalr	208(ra) # 5b64 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3a9c:	85ca                	mv	a1,s2
    3a9e:	00004517          	auipc	a0,0x4
    3aa2:	a8a50513          	addi	a0,a0,-1398 # 7528 <malloc+0x1572>
    3aa6:	00002097          	auipc	ra,0x2
    3aaa:	458080e7          	jalr	1112(ra) # 5efe <printf>
    exit(1);
    3aae:	4505                	li	a0,1
    3ab0:	00002097          	auipc	ra,0x2
    3ab4:	0b4080e7          	jalr	180(ra) # 5b64 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3ab8:	85ca                	mv	a1,s2
    3aba:	00004517          	auipc	a0,0x4
    3abe:	a9e50513          	addi	a0,a0,-1378 # 7558 <malloc+0x15a2>
    3ac2:	00002097          	auipc	ra,0x2
    3ac6:	43c080e7          	jalr	1084(ra) # 5efe <printf>
    exit(1);
    3aca:	4505                	li	a0,1
    3acc:	00002097          	auipc	ra,0x2
    3ad0:	098080e7          	jalr	152(ra) # 5b64 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3ad4:	85ca                	mv	a1,s2
    3ad6:	00004517          	auipc	a0,0x4
    3ada:	aaa50513          	addi	a0,a0,-1366 # 7580 <malloc+0x15ca>
    3ade:	00002097          	auipc	ra,0x2
    3ae2:	420080e7          	jalr	1056(ra) # 5efe <printf>
    exit(1);
    3ae6:	4505                	li	a0,1
    3ae8:	00002097          	auipc	ra,0x2
    3aec:	07c080e7          	jalr	124(ra) # 5b64 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3af0:	85ca                	mv	a1,s2
    3af2:	00004517          	auipc	a0,0x4
    3af6:	aae50513          	addi	a0,a0,-1362 # 75a0 <malloc+0x15ea>
    3afa:	00002097          	auipc	ra,0x2
    3afe:	404080e7          	jalr	1028(ra) # 5efe <printf>
    exit(1);
    3b02:	4505                	li	a0,1
    3b04:	00002097          	auipc	ra,0x2
    3b08:	060080e7          	jalr	96(ra) # 5b64 <exit>
    printf("%s: chdir dd failed\n", s);
    3b0c:	85ca                	mv	a1,s2
    3b0e:	00004517          	auipc	a0,0x4
    3b12:	aba50513          	addi	a0,a0,-1350 # 75c8 <malloc+0x1612>
    3b16:	00002097          	auipc	ra,0x2
    3b1a:	3e8080e7          	jalr	1000(ra) # 5efe <printf>
    exit(1);
    3b1e:	4505                	li	a0,1
    3b20:	00002097          	auipc	ra,0x2
    3b24:	044080e7          	jalr	68(ra) # 5b64 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3b28:	85ca                	mv	a1,s2
    3b2a:	00004517          	auipc	a0,0x4
    3b2e:	ac650513          	addi	a0,a0,-1338 # 75f0 <malloc+0x163a>
    3b32:	00002097          	auipc	ra,0x2
    3b36:	3cc080e7          	jalr	972(ra) # 5efe <printf>
    exit(1);
    3b3a:	4505                	li	a0,1
    3b3c:	00002097          	auipc	ra,0x2
    3b40:	028080e7          	jalr	40(ra) # 5b64 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3b44:	85ca                	mv	a1,s2
    3b46:	00004517          	auipc	a0,0x4
    3b4a:	ada50513          	addi	a0,a0,-1318 # 7620 <malloc+0x166a>
    3b4e:	00002097          	auipc	ra,0x2
    3b52:	3b0080e7          	jalr	944(ra) # 5efe <printf>
    exit(1);
    3b56:	4505                	li	a0,1
    3b58:	00002097          	auipc	ra,0x2
    3b5c:	00c080e7          	jalr	12(ra) # 5b64 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3b60:	85ca                	mv	a1,s2
    3b62:	00004517          	auipc	a0,0x4
    3b66:	ae650513          	addi	a0,a0,-1306 # 7648 <malloc+0x1692>
    3b6a:	00002097          	auipc	ra,0x2
    3b6e:	394080e7          	jalr	916(ra) # 5efe <printf>
    exit(1);
    3b72:	4505                	li	a0,1
    3b74:	00002097          	auipc	ra,0x2
    3b78:	ff0080e7          	jalr	-16(ra) # 5b64 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3b7c:	85ca                	mv	a1,s2
    3b7e:	00004517          	auipc	a0,0x4
    3b82:	ae250513          	addi	a0,a0,-1310 # 7660 <malloc+0x16aa>
    3b86:	00002097          	auipc	ra,0x2
    3b8a:	378080e7          	jalr	888(ra) # 5efe <printf>
    exit(1);
    3b8e:	4505                	li	a0,1
    3b90:	00002097          	auipc	ra,0x2
    3b94:	fd4080e7          	jalr	-44(ra) # 5b64 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3b98:	85ca                	mv	a1,s2
    3b9a:	00004517          	auipc	a0,0x4
    3b9e:	ae650513          	addi	a0,a0,-1306 # 7680 <malloc+0x16ca>
    3ba2:	00002097          	auipc	ra,0x2
    3ba6:	35c080e7          	jalr	860(ra) # 5efe <printf>
    exit(1);
    3baa:	4505                	li	a0,1
    3bac:	00002097          	auipc	ra,0x2
    3bb0:	fb8080e7          	jalr	-72(ra) # 5b64 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3bb4:	85ca                	mv	a1,s2
    3bb6:	00004517          	auipc	a0,0x4
    3bba:	aea50513          	addi	a0,a0,-1302 # 76a0 <malloc+0x16ea>
    3bbe:	00002097          	auipc	ra,0x2
    3bc2:	340080e7          	jalr	832(ra) # 5efe <printf>
    exit(1);
    3bc6:	4505                	li	a0,1
    3bc8:	00002097          	auipc	ra,0x2
    3bcc:	f9c080e7          	jalr	-100(ra) # 5b64 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3bd0:	85ca                	mv	a1,s2
    3bd2:	00004517          	auipc	a0,0x4
    3bd6:	b0e50513          	addi	a0,a0,-1266 # 76e0 <malloc+0x172a>
    3bda:	00002097          	auipc	ra,0x2
    3bde:	324080e7          	jalr	804(ra) # 5efe <printf>
    exit(1);
    3be2:	4505                	li	a0,1
    3be4:	00002097          	auipc	ra,0x2
    3be8:	f80080e7          	jalr	-128(ra) # 5b64 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3bec:	85ca                	mv	a1,s2
    3bee:	00004517          	auipc	a0,0x4
    3bf2:	b2250513          	addi	a0,a0,-1246 # 7710 <malloc+0x175a>
    3bf6:	00002097          	auipc	ra,0x2
    3bfa:	308080e7          	jalr	776(ra) # 5efe <printf>
    exit(1);
    3bfe:	4505                	li	a0,1
    3c00:	00002097          	auipc	ra,0x2
    3c04:	f64080e7          	jalr	-156(ra) # 5b64 <exit>
    printf("%s: create dd succeeded!\n", s);
    3c08:	85ca                	mv	a1,s2
    3c0a:	00004517          	auipc	a0,0x4
    3c0e:	b2650513          	addi	a0,a0,-1242 # 7730 <malloc+0x177a>
    3c12:	00002097          	auipc	ra,0x2
    3c16:	2ec080e7          	jalr	748(ra) # 5efe <printf>
    exit(1);
    3c1a:	4505                	li	a0,1
    3c1c:	00002097          	auipc	ra,0x2
    3c20:	f48080e7          	jalr	-184(ra) # 5b64 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3c24:	85ca                	mv	a1,s2
    3c26:	00004517          	auipc	a0,0x4
    3c2a:	b2a50513          	addi	a0,a0,-1238 # 7750 <malloc+0x179a>
    3c2e:	00002097          	auipc	ra,0x2
    3c32:	2d0080e7          	jalr	720(ra) # 5efe <printf>
    exit(1);
    3c36:	4505                	li	a0,1
    3c38:	00002097          	auipc	ra,0x2
    3c3c:	f2c080e7          	jalr	-212(ra) # 5b64 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3c40:	85ca                	mv	a1,s2
    3c42:	00004517          	auipc	a0,0x4
    3c46:	b2e50513          	addi	a0,a0,-1234 # 7770 <malloc+0x17ba>
    3c4a:	00002097          	auipc	ra,0x2
    3c4e:	2b4080e7          	jalr	692(ra) # 5efe <printf>
    exit(1);
    3c52:	4505                	li	a0,1
    3c54:	00002097          	auipc	ra,0x2
    3c58:	f10080e7          	jalr	-240(ra) # 5b64 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3c5c:	85ca                	mv	a1,s2
    3c5e:	00004517          	auipc	a0,0x4
    3c62:	b4250513          	addi	a0,a0,-1214 # 77a0 <malloc+0x17ea>
    3c66:	00002097          	auipc	ra,0x2
    3c6a:	298080e7          	jalr	664(ra) # 5efe <printf>
    exit(1);
    3c6e:	4505                	li	a0,1
    3c70:	00002097          	auipc	ra,0x2
    3c74:	ef4080e7          	jalr	-268(ra) # 5b64 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3c78:	85ca                	mv	a1,s2
    3c7a:	00004517          	auipc	a0,0x4
    3c7e:	b4e50513          	addi	a0,a0,-1202 # 77c8 <malloc+0x1812>
    3c82:	00002097          	auipc	ra,0x2
    3c86:	27c080e7          	jalr	636(ra) # 5efe <printf>
    exit(1);
    3c8a:	4505                	li	a0,1
    3c8c:	00002097          	auipc	ra,0x2
    3c90:	ed8080e7          	jalr	-296(ra) # 5b64 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3c94:	85ca                	mv	a1,s2
    3c96:	00004517          	auipc	a0,0x4
    3c9a:	b5a50513          	addi	a0,a0,-1190 # 77f0 <malloc+0x183a>
    3c9e:	00002097          	auipc	ra,0x2
    3ca2:	260080e7          	jalr	608(ra) # 5efe <printf>
    exit(1);
    3ca6:	4505                	li	a0,1
    3ca8:	00002097          	auipc	ra,0x2
    3cac:	ebc080e7          	jalr	-324(ra) # 5b64 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3cb0:	85ca                	mv	a1,s2
    3cb2:	00004517          	auipc	a0,0x4
    3cb6:	b6650513          	addi	a0,a0,-1178 # 7818 <malloc+0x1862>
    3cba:	00002097          	auipc	ra,0x2
    3cbe:	244080e7          	jalr	580(ra) # 5efe <printf>
    exit(1);
    3cc2:	4505                	li	a0,1
    3cc4:	00002097          	auipc	ra,0x2
    3cc8:	ea0080e7          	jalr	-352(ra) # 5b64 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3ccc:	85ca                	mv	a1,s2
    3cce:	00004517          	auipc	a0,0x4
    3cd2:	b6a50513          	addi	a0,a0,-1174 # 7838 <malloc+0x1882>
    3cd6:	00002097          	auipc	ra,0x2
    3cda:	228080e7          	jalr	552(ra) # 5efe <printf>
    exit(1);
    3cde:	4505                	li	a0,1
    3ce0:	00002097          	auipc	ra,0x2
    3ce4:	e84080e7          	jalr	-380(ra) # 5b64 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3ce8:	85ca                	mv	a1,s2
    3cea:	00004517          	auipc	a0,0x4
    3cee:	b6e50513          	addi	a0,a0,-1170 # 7858 <malloc+0x18a2>
    3cf2:	00002097          	auipc	ra,0x2
    3cf6:	20c080e7          	jalr	524(ra) # 5efe <printf>
    exit(1);
    3cfa:	4505                	li	a0,1
    3cfc:	00002097          	auipc	ra,0x2
    3d00:	e68080e7          	jalr	-408(ra) # 5b64 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3d04:	85ca                	mv	a1,s2
    3d06:	00004517          	auipc	a0,0x4
    3d0a:	b7a50513          	addi	a0,a0,-1158 # 7880 <malloc+0x18ca>
    3d0e:	00002097          	auipc	ra,0x2
    3d12:	1f0080e7          	jalr	496(ra) # 5efe <printf>
    exit(1);
    3d16:	4505                	li	a0,1
    3d18:	00002097          	auipc	ra,0x2
    3d1c:	e4c080e7          	jalr	-436(ra) # 5b64 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3d20:	85ca                	mv	a1,s2
    3d22:	00004517          	auipc	a0,0x4
    3d26:	b7e50513          	addi	a0,a0,-1154 # 78a0 <malloc+0x18ea>
    3d2a:	00002097          	auipc	ra,0x2
    3d2e:	1d4080e7          	jalr	468(ra) # 5efe <printf>
    exit(1);
    3d32:	4505                	li	a0,1
    3d34:	00002097          	auipc	ra,0x2
    3d38:	e30080e7          	jalr	-464(ra) # 5b64 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3d3c:	85ca                	mv	a1,s2
    3d3e:	00004517          	auipc	a0,0x4
    3d42:	b8250513          	addi	a0,a0,-1150 # 78c0 <malloc+0x190a>
    3d46:	00002097          	auipc	ra,0x2
    3d4a:	1b8080e7          	jalr	440(ra) # 5efe <printf>
    exit(1);
    3d4e:	4505                	li	a0,1
    3d50:	00002097          	auipc	ra,0x2
    3d54:	e14080e7          	jalr	-492(ra) # 5b64 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3d58:	85ca                	mv	a1,s2
    3d5a:	00004517          	auipc	a0,0x4
    3d5e:	b8e50513          	addi	a0,a0,-1138 # 78e8 <malloc+0x1932>
    3d62:	00002097          	auipc	ra,0x2
    3d66:	19c080e7          	jalr	412(ra) # 5efe <printf>
    exit(1);
    3d6a:	4505                	li	a0,1
    3d6c:	00002097          	auipc	ra,0x2
    3d70:	df8080e7          	jalr	-520(ra) # 5b64 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3d74:	85ca                	mv	a1,s2
    3d76:	00004517          	auipc	a0,0x4
    3d7a:	80a50513          	addi	a0,a0,-2038 # 7580 <malloc+0x15ca>
    3d7e:	00002097          	auipc	ra,0x2
    3d82:	180080e7          	jalr	384(ra) # 5efe <printf>
    exit(1);
    3d86:	4505                	li	a0,1
    3d88:	00002097          	auipc	ra,0x2
    3d8c:	ddc080e7          	jalr	-548(ra) # 5b64 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3d90:	85ca                	mv	a1,s2
    3d92:	00004517          	auipc	a0,0x4
    3d96:	b7650513          	addi	a0,a0,-1162 # 7908 <malloc+0x1952>
    3d9a:	00002097          	auipc	ra,0x2
    3d9e:	164080e7          	jalr	356(ra) # 5efe <printf>
    exit(1);
    3da2:	4505                	li	a0,1
    3da4:	00002097          	auipc	ra,0x2
    3da8:	dc0080e7          	jalr	-576(ra) # 5b64 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3dac:	85ca                	mv	a1,s2
    3dae:	00004517          	auipc	a0,0x4
    3db2:	b7a50513          	addi	a0,a0,-1158 # 7928 <malloc+0x1972>
    3db6:	00002097          	auipc	ra,0x2
    3dba:	148080e7          	jalr	328(ra) # 5efe <printf>
    exit(1);
    3dbe:	4505                	li	a0,1
    3dc0:	00002097          	auipc	ra,0x2
    3dc4:	da4080e7          	jalr	-604(ra) # 5b64 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3dc8:	85ca                	mv	a1,s2
    3dca:	00004517          	auipc	a0,0x4
    3dce:	b8e50513          	addi	a0,a0,-1138 # 7958 <malloc+0x19a2>
    3dd2:	00002097          	auipc	ra,0x2
    3dd6:	12c080e7          	jalr	300(ra) # 5efe <printf>
    exit(1);
    3dda:	4505                	li	a0,1
    3ddc:	00002097          	auipc	ra,0x2
    3de0:	d88080e7          	jalr	-632(ra) # 5b64 <exit>
    printf("%s: unlink dd failed\n", s);
    3de4:	85ca                	mv	a1,s2
    3de6:	00004517          	auipc	a0,0x4
    3dea:	b9250513          	addi	a0,a0,-1134 # 7978 <malloc+0x19c2>
    3dee:	00002097          	auipc	ra,0x2
    3df2:	110080e7          	jalr	272(ra) # 5efe <printf>
    exit(1);
    3df6:	4505                	li	a0,1
    3df8:	00002097          	auipc	ra,0x2
    3dfc:	d6c080e7          	jalr	-660(ra) # 5b64 <exit>

0000000000003e00 <rmdot>:
{
    3e00:	1101                	addi	sp,sp,-32
    3e02:	ec06                	sd	ra,24(sp)
    3e04:	e822                	sd	s0,16(sp)
    3e06:	e426                	sd	s1,8(sp)
    3e08:	1000                	addi	s0,sp,32
    3e0a:	84aa                	mv	s1,a0
  if (mkdir("dots") != 0)
    3e0c:	00004517          	auipc	a0,0x4
    3e10:	b8450513          	addi	a0,a0,-1148 # 7990 <malloc+0x19da>
    3e14:	00002097          	auipc	ra,0x2
    3e18:	db8080e7          	jalr	-584(ra) # 5bcc <mkdir>
    3e1c:	e549                	bnez	a0,3ea6 <rmdot+0xa6>
  if (chdir("dots") != 0)
    3e1e:	00004517          	auipc	a0,0x4
    3e22:	b7250513          	addi	a0,a0,-1166 # 7990 <malloc+0x19da>
    3e26:	00002097          	auipc	ra,0x2
    3e2a:	dae080e7          	jalr	-594(ra) # 5bd4 <chdir>
    3e2e:	e951                	bnez	a0,3ec2 <rmdot+0xc2>
  if (unlink(".") == 0)
    3e30:	00003517          	auipc	a0,0x3
    3e34:	99050513          	addi	a0,a0,-1648 # 67c0 <malloc+0x80a>
    3e38:	00002097          	auipc	ra,0x2
    3e3c:	d7c080e7          	jalr	-644(ra) # 5bb4 <unlink>
    3e40:	cd59                	beqz	a0,3ede <rmdot+0xde>
  if (unlink("..") == 0)
    3e42:	00003517          	auipc	a0,0x3
    3e46:	5a650513          	addi	a0,a0,1446 # 73e8 <malloc+0x1432>
    3e4a:	00002097          	auipc	ra,0x2
    3e4e:	d6a080e7          	jalr	-662(ra) # 5bb4 <unlink>
    3e52:	c545                	beqz	a0,3efa <rmdot+0xfa>
  if (chdir("/") != 0)
    3e54:	00003517          	auipc	a0,0x3
    3e58:	53c50513          	addi	a0,a0,1340 # 7390 <malloc+0x13da>
    3e5c:	00002097          	auipc	ra,0x2
    3e60:	d78080e7          	jalr	-648(ra) # 5bd4 <chdir>
    3e64:	e94d                	bnez	a0,3f16 <rmdot+0x116>
  if (unlink("dots/.") == 0)
    3e66:	00004517          	auipc	a0,0x4
    3e6a:	b9250513          	addi	a0,a0,-1134 # 79f8 <malloc+0x1a42>
    3e6e:	00002097          	auipc	ra,0x2
    3e72:	d46080e7          	jalr	-698(ra) # 5bb4 <unlink>
    3e76:	cd55                	beqz	a0,3f32 <rmdot+0x132>
  if (unlink("dots/..") == 0)
    3e78:	00004517          	auipc	a0,0x4
    3e7c:	ba850513          	addi	a0,a0,-1112 # 7a20 <malloc+0x1a6a>
    3e80:	00002097          	auipc	ra,0x2
    3e84:	d34080e7          	jalr	-716(ra) # 5bb4 <unlink>
    3e88:	c179                	beqz	a0,3f4e <rmdot+0x14e>
  if (unlink("dots") != 0)
    3e8a:	00004517          	auipc	a0,0x4
    3e8e:	b0650513          	addi	a0,a0,-1274 # 7990 <malloc+0x19da>
    3e92:	00002097          	auipc	ra,0x2
    3e96:	d22080e7          	jalr	-734(ra) # 5bb4 <unlink>
    3e9a:	e961                	bnez	a0,3f6a <rmdot+0x16a>
}
    3e9c:	60e2                	ld	ra,24(sp)
    3e9e:	6442                	ld	s0,16(sp)
    3ea0:	64a2                	ld	s1,8(sp)
    3ea2:	6105                	addi	sp,sp,32
    3ea4:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3ea6:	85a6                	mv	a1,s1
    3ea8:	00004517          	auipc	a0,0x4
    3eac:	af050513          	addi	a0,a0,-1296 # 7998 <malloc+0x19e2>
    3eb0:	00002097          	auipc	ra,0x2
    3eb4:	04e080e7          	jalr	78(ra) # 5efe <printf>
    exit(1);
    3eb8:	4505                	li	a0,1
    3eba:	00002097          	auipc	ra,0x2
    3ebe:	caa080e7          	jalr	-854(ra) # 5b64 <exit>
    printf("%s: chdir dots failed\n", s);
    3ec2:	85a6                	mv	a1,s1
    3ec4:	00004517          	auipc	a0,0x4
    3ec8:	aec50513          	addi	a0,a0,-1300 # 79b0 <malloc+0x19fa>
    3ecc:	00002097          	auipc	ra,0x2
    3ed0:	032080e7          	jalr	50(ra) # 5efe <printf>
    exit(1);
    3ed4:	4505                	li	a0,1
    3ed6:	00002097          	auipc	ra,0x2
    3eda:	c8e080e7          	jalr	-882(ra) # 5b64 <exit>
    printf("%s: rm . worked!\n", s);
    3ede:	85a6                	mv	a1,s1
    3ee0:	00004517          	auipc	a0,0x4
    3ee4:	ae850513          	addi	a0,a0,-1304 # 79c8 <malloc+0x1a12>
    3ee8:	00002097          	auipc	ra,0x2
    3eec:	016080e7          	jalr	22(ra) # 5efe <printf>
    exit(1);
    3ef0:	4505                	li	a0,1
    3ef2:	00002097          	auipc	ra,0x2
    3ef6:	c72080e7          	jalr	-910(ra) # 5b64 <exit>
    printf("%s: rm .. worked!\n", s);
    3efa:	85a6                	mv	a1,s1
    3efc:	00004517          	auipc	a0,0x4
    3f00:	ae450513          	addi	a0,a0,-1308 # 79e0 <malloc+0x1a2a>
    3f04:	00002097          	auipc	ra,0x2
    3f08:	ffa080e7          	jalr	-6(ra) # 5efe <printf>
    exit(1);
    3f0c:	4505                	li	a0,1
    3f0e:	00002097          	auipc	ra,0x2
    3f12:	c56080e7          	jalr	-938(ra) # 5b64 <exit>
    printf("%s: chdir / failed\n", s);
    3f16:	85a6                	mv	a1,s1
    3f18:	00003517          	auipc	a0,0x3
    3f1c:	48050513          	addi	a0,a0,1152 # 7398 <malloc+0x13e2>
    3f20:	00002097          	auipc	ra,0x2
    3f24:	fde080e7          	jalr	-34(ra) # 5efe <printf>
    exit(1);
    3f28:	4505                	li	a0,1
    3f2a:	00002097          	auipc	ra,0x2
    3f2e:	c3a080e7          	jalr	-966(ra) # 5b64 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3f32:	85a6                	mv	a1,s1
    3f34:	00004517          	auipc	a0,0x4
    3f38:	acc50513          	addi	a0,a0,-1332 # 7a00 <malloc+0x1a4a>
    3f3c:	00002097          	auipc	ra,0x2
    3f40:	fc2080e7          	jalr	-62(ra) # 5efe <printf>
    exit(1);
    3f44:	4505                	li	a0,1
    3f46:	00002097          	auipc	ra,0x2
    3f4a:	c1e080e7          	jalr	-994(ra) # 5b64 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3f4e:	85a6                	mv	a1,s1
    3f50:	00004517          	auipc	a0,0x4
    3f54:	ad850513          	addi	a0,a0,-1320 # 7a28 <malloc+0x1a72>
    3f58:	00002097          	auipc	ra,0x2
    3f5c:	fa6080e7          	jalr	-90(ra) # 5efe <printf>
    exit(1);
    3f60:	4505                	li	a0,1
    3f62:	00002097          	auipc	ra,0x2
    3f66:	c02080e7          	jalr	-1022(ra) # 5b64 <exit>
    printf("%s: unlink dots failed!\n", s);
    3f6a:	85a6                	mv	a1,s1
    3f6c:	00004517          	auipc	a0,0x4
    3f70:	adc50513          	addi	a0,a0,-1316 # 7a48 <malloc+0x1a92>
    3f74:	00002097          	auipc	ra,0x2
    3f78:	f8a080e7          	jalr	-118(ra) # 5efe <printf>
    exit(1);
    3f7c:	4505                	li	a0,1
    3f7e:	00002097          	auipc	ra,0x2
    3f82:	be6080e7          	jalr	-1050(ra) # 5b64 <exit>

0000000000003f86 <dirfile>:
{
    3f86:	1101                	addi	sp,sp,-32
    3f88:	ec06                	sd	ra,24(sp)
    3f8a:	e822                	sd	s0,16(sp)
    3f8c:	e426                	sd	s1,8(sp)
    3f8e:	e04a                	sd	s2,0(sp)
    3f90:	1000                	addi	s0,sp,32
    3f92:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3f94:	20000593          	li	a1,512
    3f98:	00004517          	auipc	a0,0x4
    3f9c:	ad050513          	addi	a0,a0,-1328 # 7a68 <malloc+0x1ab2>
    3fa0:	00002097          	auipc	ra,0x2
    3fa4:	c04080e7          	jalr	-1020(ra) # 5ba4 <open>
  if (fd < 0)
    3fa8:	0e054d63          	bltz	a0,40a2 <dirfile+0x11c>
  close(fd);
    3fac:	00002097          	auipc	ra,0x2
    3fb0:	be0080e7          	jalr	-1056(ra) # 5b8c <close>
  if (chdir("dirfile") == 0)
    3fb4:	00004517          	auipc	a0,0x4
    3fb8:	ab450513          	addi	a0,a0,-1356 # 7a68 <malloc+0x1ab2>
    3fbc:	00002097          	auipc	ra,0x2
    3fc0:	c18080e7          	jalr	-1000(ra) # 5bd4 <chdir>
    3fc4:	cd6d                	beqz	a0,40be <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    3fc6:	4581                	li	a1,0
    3fc8:	00004517          	auipc	a0,0x4
    3fcc:	ae850513          	addi	a0,a0,-1304 # 7ab0 <malloc+0x1afa>
    3fd0:	00002097          	auipc	ra,0x2
    3fd4:	bd4080e7          	jalr	-1068(ra) # 5ba4 <open>
  if (fd >= 0)
    3fd8:	10055163          	bgez	a0,40da <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3fdc:	20000593          	li	a1,512
    3fe0:	00004517          	auipc	a0,0x4
    3fe4:	ad050513          	addi	a0,a0,-1328 # 7ab0 <malloc+0x1afa>
    3fe8:	00002097          	auipc	ra,0x2
    3fec:	bbc080e7          	jalr	-1092(ra) # 5ba4 <open>
  if (fd >= 0)
    3ff0:	10055363          	bgez	a0,40f6 <dirfile+0x170>
  if (mkdir("dirfile/xx") == 0)
    3ff4:	00004517          	auipc	a0,0x4
    3ff8:	abc50513          	addi	a0,a0,-1348 # 7ab0 <malloc+0x1afa>
    3ffc:	00002097          	auipc	ra,0x2
    4000:	bd0080e7          	jalr	-1072(ra) # 5bcc <mkdir>
    4004:	10050763          	beqz	a0,4112 <dirfile+0x18c>
  if (unlink("dirfile/xx") == 0)
    4008:	00004517          	auipc	a0,0x4
    400c:	aa850513          	addi	a0,a0,-1368 # 7ab0 <malloc+0x1afa>
    4010:	00002097          	auipc	ra,0x2
    4014:	ba4080e7          	jalr	-1116(ra) # 5bb4 <unlink>
    4018:	10050b63          	beqz	a0,412e <dirfile+0x1a8>
  if (link("README", "dirfile/xx") == 0)
    401c:	00004597          	auipc	a1,0x4
    4020:	a9458593          	addi	a1,a1,-1388 # 7ab0 <malloc+0x1afa>
    4024:	00002517          	auipc	a0,0x2
    4028:	28c50513          	addi	a0,a0,652 # 62b0 <malloc+0x2fa>
    402c:	00002097          	auipc	ra,0x2
    4030:	b98080e7          	jalr	-1128(ra) # 5bc4 <link>
    4034:	10050b63          	beqz	a0,414a <dirfile+0x1c4>
  if (unlink("dirfile") != 0)
    4038:	00004517          	auipc	a0,0x4
    403c:	a3050513          	addi	a0,a0,-1488 # 7a68 <malloc+0x1ab2>
    4040:	00002097          	auipc	ra,0x2
    4044:	b74080e7          	jalr	-1164(ra) # 5bb4 <unlink>
    4048:	10051f63          	bnez	a0,4166 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    404c:	4589                	li	a1,2
    404e:	00002517          	auipc	a0,0x2
    4052:	77250513          	addi	a0,a0,1906 # 67c0 <malloc+0x80a>
    4056:	00002097          	auipc	ra,0x2
    405a:	b4e080e7          	jalr	-1202(ra) # 5ba4 <open>
  if (fd >= 0)
    405e:	12055263          	bgez	a0,4182 <dirfile+0x1fc>
  fd = open(".", 0);
    4062:	4581                	li	a1,0
    4064:	00002517          	auipc	a0,0x2
    4068:	75c50513          	addi	a0,a0,1884 # 67c0 <malloc+0x80a>
    406c:	00002097          	auipc	ra,0x2
    4070:	b38080e7          	jalr	-1224(ra) # 5ba4 <open>
    4074:	84aa                	mv	s1,a0
  if (write(fd, "x", 1) > 0)
    4076:	4605                	li	a2,1
    4078:	00002597          	auipc	a1,0x2
    407c:	0d058593          	addi	a1,a1,208 # 6148 <malloc+0x192>
    4080:	00002097          	auipc	ra,0x2
    4084:	b04080e7          	jalr	-1276(ra) # 5b84 <write>
    4088:	10a04b63          	bgtz	a0,419e <dirfile+0x218>
  close(fd);
    408c:	8526                	mv	a0,s1
    408e:	00002097          	auipc	ra,0x2
    4092:	afe080e7          	jalr	-1282(ra) # 5b8c <close>
}
    4096:	60e2                	ld	ra,24(sp)
    4098:	6442                	ld	s0,16(sp)
    409a:	64a2                	ld	s1,8(sp)
    409c:	6902                	ld	s2,0(sp)
    409e:	6105                	addi	sp,sp,32
    40a0:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    40a2:	85ca                	mv	a1,s2
    40a4:	00004517          	auipc	a0,0x4
    40a8:	9cc50513          	addi	a0,a0,-1588 # 7a70 <malloc+0x1aba>
    40ac:	00002097          	auipc	ra,0x2
    40b0:	e52080e7          	jalr	-430(ra) # 5efe <printf>
    exit(1);
    40b4:	4505                	li	a0,1
    40b6:	00002097          	auipc	ra,0x2
    40ba:	aae080e7          	jalr	-1362(ra) # 5b64 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    40be:	85ca                	mv	a1,s2
    40c0:	00004517          	auipc	a0,0x4
    40c4:	9d050513          	addi	a0,a0,-1584 # 7a90 <malloc+0x1ada>
    40c8:	00002097          	auipc	ra,0x2
    40cc:	e36080e7          	jalr	-458(ra) # 5efe <printf>
    exit(1);
    40d0:	4505                	li	a0,1
    40d2:	00002097          	auipc	ra,0x2
    40d6:	a92080e7          	jalr	-1390(ra) # 5b64 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    40da:	85ca                	mv	a1,s2
    40dc:	00004517          	auipc	a0,0x4
    40e0:	9e450513          	addi	a0,a0,-1564 # 7ac0 <malloc+0x1b0a>
    40e4:	00002097          	auipc	ra,0x2
    40e8:	e1a080e7          	jalr	-486(ra) # 5efe <printf>
    exit(1);
    40ec:	4505                	li	a0,1
    40ee:	00002097          	auipc	ra,0x2
    40f2:	a76080e7          	jalr	-1418(ra) # 5b64 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    40f6:	85ca                	mv	a1,s2
    40f8:	00004517          	auipc	a0,0x4
    40fc:	9c850513          	addi	a0,a0,-1592 # 7ac0 <malloc+0x1b0a>
    4100:	00002097          	auipc	ra,0x2
    4104:	dfe080e7          	jalr	-514(ra) # 5efe <printf>
    exit(1);
    4108:	4505                	li	a0,1
    410a:	00002097          	auipc	ra,0x2
    410e:	a5a080e7          	jalr	-1446(ra) # 5b64 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    4112:	85ca                	mv	a1,s2
    4114:	00004517          	auipc	a0,0x4
    4118:	9d450513          	addi	a0,a0,-1580 # 7ae8 <malloc+0x1b32>
    411c:	00002097          	auipc	ra,0x2
    4120:	de2080e7          	jalr	-542(ra) # 5efe <printf>
    exit(1);
    4124:	4505                	li	a0,1
    4126:	00002097          	auipc	ra,0x2
    412a:	a3e080e7          	jalr	-1474(ra) # 5b64 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    412e:	85ca                	mv	a1,s2
    4130:	00004517          	auipc	a0,0x4
    4134:	9e050513          	addi	a0,a0,-1568 # 7b10 <malloc+0x1b5a>
    4138:	00002097          	auipc	ra,0x2
    413c:	dc6080e7          	jalr	-570(ra) # 5efe <printf>
    exit(1);
    4140:	4505                	li	a0,1
    4142:	00002097          	auipc	ra,0x2
    4146:	a22080e7          	jalr	-1502(ra) # 5b64 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    414a:	85ca                	mv	a1,s2
    414c:	00004517          	auipc	a0,0x4
    4150:	9ec50513          	addi	a0,a0,-1556 # 7b38 <malloc+0x1b82>
    4154:	00002097          	auipc	ra,0x2
    4158:	daa080e7          	jalr	-598(ra) # 5efe <printf>
    exit(1);
    415c:	4505                	li	a0,1
    415e:	00002097          	auipc	ra,0x2
    4162:	a06080e7          	jalr	-1530(ra) # 5b64 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    4166:	85ca                	mv	a1,s2
    4168:	00004517          	auipc	a0,0x4
    416c:	9f850513          	addi	a0,a0,-1544 # 7b60 <malloc+0x1baa>
    4170:	00002097          	auipc	ra,0x2
    4174:	d8e080e7          	jalr	-626(ra) # 5efe <printf>
    exit(1);
    4178:	4505                	li	a0,1
    417a:	00002097          	auipc	ra,0x2
    417e:	9ea080e7          	jalr	-1558(ra) # 5b64 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    4182:	85ca                	mv	a1,s2
    4184:	00004517          	auipc	a0,0x4
    4188:	9fc50513          	addi	a0,a0,-1540 # 7b80 <malloc+0x1bca>
    418c:	00002097          	auipc	ra,0x2
    4190:	d72080e7          	jalr	-654(ra) # 5efe <printf>
    exit(1);
    4194:	4505                	li	a0,1
    4196:	00002097          	auipc	ra,0x2
    419a:	9ce080e7          	jalr	-1586(ra) # 5b64 <exit>
    printf("%s: write . succeeded!\n", s);
    419e:	85ca                	mv	a1,s2
    41a0:	00004517          	auipc	a0,0x4
    41a4:	a0850513          	addi	a0,a0,-1528 # 7ba8 <malloc+0x1bf2>
    41a8:	00002097          	auipc	ra,0x2
    41ac:	d56080e7          	jalr	-682(ra) # 5efe <printf>
    exit(1);
    41b0:	4505                	li	a0,1
    41b2:	00002097          	auipc	ra,0x2
    41b6:	9b2080e7          	jalr	-1614(ra) # 5b64 <exit>

00000000000041ba <iref>:
{
    41ba:	7139                	addi	sp,sp,-64
    41bc:	fc06                	sd	ra,56(sp)
    41be:	f822                	sd	s0,48(sp)
    41c0:	f426                	sd	s1,40(sp)
    41c2:	f04a                	sd	s2,32(sp)
    41c4:	ec4e                	sd	s3,24(sp)
    41c6:	e852                	sd	s4,16(sp)
    41c8:	e456                	sd	s5,8(sp)
    41ca:	e05a                	sd	s6,0(sp)
    41cc:	0080                	addi	s0,sp,64
    41ce:	8b2a                	mv	s6,a0
    41d0:	03300913          	li	s2,51
    if (mkdir("irefd") != 0)
    41d4:	00004a17          	auipc	s4,0x4
    41d8:	9eca0a13          	addi	s4,s4,-1556 # 7bc0 <malloc+0x1c0a>
    mkdir("");
    41dc:	00003497          	auipc	s1,0x3
    41e0:	4ec48493          	addi	s1,s1,1260 # 76c8 <malloc+0x1712>
    link("README", "");
    41e4:	00002a97          	auipc	s5,0x2
    41e8:	0cca8a93          	addi	s5,s5,204 # 62b0 <malloc+0x2fa>
    fd = open("xx", O_CREATE);
    41ec:	00004997          	auipc	s3,0x4
    41f0:	8cc98993          	addi	s3,s3,-1844 # 7ab8 <malloc+0x1b02>
    41f4:	a891                	j	4248 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    41f6:	85da                	mv	a1,s6
    41f8:	00004517          	auipc	a0,0x4
    41fc:	9d050513          	addi	a0,a0,-1584 # 7bc8 <malloc+0x1c12>
    4200:	00002097          	auipc	ra,0x2
    4204:	cfe080e7          	jalr	-770(ra) # 5efe <printf>
      exit(1);
    4208:	4505                	li	a0,1
    420a:	00002097          	auipc	ra,0x2
    420e:	95a080e7          	jalr	-1702(ra) # 5b64 <exit>
      printf("%s: chdir irefd failed\n", s);
    4212:	85da                	mv	a1,s6
    4214:	00004517          	auipc	a0,0x4
    4218:	9cc50513          	addi	a0,a0,-1588 # 7be0 <malloc+0x1c2a>
    421c:	00002097          	auipc	ra,0x2
    4220:	ce2080e7          	jalr	-798(ra) # 5efe <printf>
      exit(1);
    4224:	4505                	li	a0,1
    4226:	00002097          	auipc	ra,0x2
    422a:	93e080e7          	jalr	-1730(ra) # 5b64 <exit>
      close(fd);
    422e:	00002097          	auipc	ra,0x2
    4232:	95e080e7          	jalr	-1698(ra) # 5b8c <close>
    4236:	a889                	j	4288 <iref+0xce>
    unlink("xx");
    4238:	854e                	mv	a0,s3
    423a:	00002097          	auipc	ra,0x2
    423e:	97a080e7          	jalr	-1670(ra) # 5bb4 <unlink>
  for (i = 0; i < NINODE + 1; i++)
    4242:	397d                	addiw	s2,s2,-1
    4244:	06090063          	beqz	s2,42a4 <iref+0xea>
    if (mkdir("irefd") != 0)
    4248:	8552                	mv	a0,s4
    424a:	00002097          	auipc	ra,0x2
    424e:	982080e7          	jalr	-1662(ra) # 5bcc <mkdir>
    4252:	f155                	bnez	a0,41f6 <iref+0x3c>
    if (chdir("irefd") != 0)
    4254:	8552                	mv	a0,s4
    4256:	00002097          	auipc	ra,0x2
    425a:	97e080e7          	jalr	-1666(ra) # 5bd4 <chdir>
    425e:	f955                	bnez	a0,4212 <iref+0x58>
    mkdir("");
    4260:	8526                	mv	a0,s1
    4262:	00002097          	auipc	ra,0x2
    4266:	96a080e7          	jalr	-1686(ra) # 5bcc <mkdir>
    link("README", "");
    426a:	85a6                	mv	a1,s1
    426c:	8556                	mv	a0,s5
    426e:	00002097          	auipc	ra,0x2
    4272:	956080e7          	jalr	-1706(ra) # 5bc4 <link>
    fd = open("", O_CREATE);
    4276:	20000593          	li	a1,512
    427a:	8526                	mv	a0,s1
    427c:	00002097          	auipc	ra,0x2
    4280:	928080e7          	jalr	-1752(ra) # 5ba4 <open>
    if (fd >= 0)
    4284:	fa0555e3          	bgez	a0,422e <iref+0x74>
    fd = open("xx", O_CREATE);
    4288:	20000593          	li	a1,512
    428c:	854e                	mv	a0,s3
    428e:	00002097          	auipc	ra,0x2
    4292:	916080e7          	jalr	-1770(ra) # 5ba4 <open>
    if (fd >= 0)
    4296:	fa0541e3          	bltz	a0,4238 <iref+0x7e>
      close(fd);
    429a:	00002097          	auipc	ra,0x2
    429e:	8f2080e7          	jalr	-1806(ra) # 5b8c <close>
    42a2:	bf59                	j	4238 <iref+0x7e>
    42a4:	03300493          	li	s1,51
    chdir("..");
    42a8:	00003997          	auipc	s3,0x3
    42ac:	14098993          	addi	s3,s3,320 # 73e8 <malloc+0x1432>
    unlink("irefd");
    42b0:	00004917          	auipc	s2,0x4
    42b4:	91090913          	addi	s2,s2,-1776 # 7bc0 <malloc+0x1c0a>
    chdir("..");
    42b8:	854e                	mv	a0,s3
    42ba:	00002097          	auipc	ra,0x2
    42be:	91a080e7          	jalr	-1766(ra) # 5bd4 <chdir>
    unlink("irefd");
    42c2:	854a                	mv	a0,s2
    42c4:	00002097          	auipc	ra,0x2
    42c8:	8f0080e7          	jalr	-1808(ra) # 5bb4 <unlink>
  for (i = 0; i < NINODE + 1; i++)
    42cc:	34fd                	addiw	s1,s1,-1
    42ce:	f4ed                	bnez	s1,42b8 <iref+0xfe>
  chdir("/");
    42d0:	00003517          	auipc	a0,0x3
    42d4:	0c050513          	addi	a0,a0,192 # 7390 <malloc+0x13da>
    42d8:	00002097          	auipc	ra,0x2
    42dc:	8fc080e7          	jalr	-1796(ra) # 5bd4 <chdir>
}
    42e0:	70e2                	ld	ra,56(sp)
    42e2:	7442                	ld	s0,48(sp)
    42e4:	74a2                	ld	s1,40(sp)
    42e6:	7902                	ld	s2,32(sp)
    42e8:	69e2                	ld	s3,24(sp)
    42ea:	6a42                	ld	s4,16(sp)
    42ec:	6aa2                	ld	s5,8(sp)
    42ee:	6b02                	ld	s6,0(sp)
    42f0:	6121                	addi	sp,sp,64
    42f2:	8082                	ret

00000000000042f4 <openiputtest>:
{
    42f4:	7179                	addi	sp,sp,-48
    42f6:	f406                	sd	ra,40(sp)
    42f8:	f022                	sd	s0,32(sp)
    42fa:	ec26                	sd	s1,24(sp)
    42fc:	1800                	addi	s0,sp,48
    42fe:	84aa                	mv	s1,a0
  if (mkdir("oidir") < 0)
    4300:	00004517          	auipc	a0,0x4
    4304:	8f850513          	addi	a0,a0,-1800 # 7bf8 <malloc+0x1c42>
    4308:	00002097          	auipc	ra,0x2
    430c:	8c4080e7          	jalr	-1852(ra) # 5bcc <mkdir>
    4310:	04054263          	bltz	a0,4354 <openiputtest+0x60>
  pid = fork();
    4314:	00002097          	auipc	ra,0x2
    4318:	848080e7          	jalr	-1976(ra) # 5b5c <fork>
  if (pid < 0)
    431c:	04054a63          	bltz	a0,4370 <openiputtest+0x7c>
  if (pid == 0)
    4320:	e93d                	bnez	a0,4396 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    4322:	4589                	li	a1,2
    4324:	00004517          	auipc	a0,0x4
    4328:	8d450513          	addi	a0,a0,-1836 # 7bf8 <malloc+0x1c42>
    432c:	00002097          	auipc	ra,0x2
    4330:	878080e7          	jalr	-1928(ra) # 5ba4 <open>
    if (fd >= 0)
    4334:	04054c63          	bltz	a0,438c <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    4338:	85a6                	mv	a1,s1
    433a:	00004517          	auipc	a0,0x4
    433e:	8de50513          	addi	a0,a0,-1826 # 7c18 <malloc+0x1c62>
    4342:	00002097          	auipc	ra,0x2
    4346:	bbc080e7          	jalr	-1092(ra) # 5efe <printf>
      exit(1);
    434a:	4505                	li	a0,1
    434c:	00002097          	auipc	ra,0x2
    4350:	818080e7          	jalr	-2024(ra) # 5b64 <exit>
    printf("%s: mkdir oidir failed\n", s);
    4354:	85a6                	mv	a1,s1
    4356:	00004517          	auipc	a0,0x4
    435a:	8aa50513          	addi	a0,a0,-1878 # 7c00 <malloc+0x1c4a>
    435e:	00002097          	auipc	ra,0x2
    4362:	ba0080e7          	jalr	-1120(ra) # 5efe <printf>
    exit(1);
    4366:	4505                	li	a0,1
    4368:	00001097          	auipc	ra,0x1
    436c:	7fc080e7          	jalr	2044(ra) # 5b64 <exit>
    printf("%s: fork failed\n", s);
    4370:	85a6                	mv	a1,s1
    4372:	00002517          	auipc	a0,0x2
    4376:	5ee50513          	addi	a0,a0,1518 # 6960 <malloc+0x9aa>
    437a:	00002097          	auipc	ra,0x2
    437e:	b84080e7          	jalr	-1148(ra) # 5efe <printf>
    exit(1);
    4382:	4505                	li	a0,1
    4384:	00001097          	auipc	ra,0x1
    4388:	7e0080e7          	jalr	2016(ra) # 5b64 <exit>
    exit(0);
    438c:	4501                	li	a0,0
    438e:	00001097          	auipc	ra,0x1
    4392:	7d6080e7          	jalr	2006(ra) # 5b64 <exit>
  sleep(1);
    4396:	4505                	li	a0,1
    4398:	00002097          	auipc	ra,0x2
    439c:	85c080e7          	jalr	-1956(ra) # 5bf4 <sleep>
  if (unlink("oidir") != 0)
    43a0:	00004517          	auipc	a0,0x4
    43a4:	85850513          	addi	a0,a0,-1960 # 7bf8 <malloc+0x1c42>
    43a8:	00002097          	auipc	ra,0x2
    43ac:	80c080e7          	jalr	-2036(ra) # 5bb4 <unlink>
    43b0:	cd19                	beqz	a0,43ce <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    43b2:	85a6                	mv	a1,s1
    43b4:	00002517          	auipc	a0,0x2
    43b8:	79c50513          	addi	a0,a0,1948 # 6b50 <malloc+0xb9a>
    43bc:	00002097          	auipc	ra,0x2
    43c0:	b42080e7          	jalr	-1214(ra) # 5efe <printf>
    exit(1);
    43c4:	4505                	li	a0,1
    43c6:	00001097          	auipc	ra,0x1
    43ca:	79e080e7          	jalr	1950(ra) # 5b64 <exit>
  wait(&xstatus);
    43ce:	fdc40513          	addi	a0,s0,-36
    43d2:	00001097          	auipc	ra,0x1
    43d6:	79a080e7          	jalr	1946(ra) # 5b6c <wait>
  exit(xstatus);
    43da:	fdc42503          	lw	a0,-36(s0)
    43de:	00001097          	auipc	ra,0x1
    43e2:	786080e7          	jalr	1926(ra) # 5b64 <exit>

00000000000043e6 <forkforkfork>:
{
    43e6:	1101                	addi	sp,sp,-32
    43e8:	ec06                	sd	ra,24(sp)
    43ea:	e822                	sd	s0,16(sp)
    43ec:	e426                	sd	s1,8(sp)
    43ee:	1000                	addi	s0,sp,32
    43f0:	84aa                	mv	s1,a0
  unlink("stopforking");
    43f2:	00004517          	auipc	a0,0x4
    43f6:	84e50513          	addi	a0,a0,-1970 # 7c40 <malloc+0x1c8a>
    43fa:	00001097          	auipc	ra,0x1
    43fe:	7ba080e7          	jalr	1978(ra) # 5bb4 <unlink>
  int pid = fork();
    4402:	00001097          	auipc	ra,0x1
    4406:	75a080e7          	jalr	1882(ra) # 5b5c <fork>
  if (pid < 0)
    440a:	04054563          	bltz	a0,4454 <forkforkfork+0x6e>
  if (pid == 0)
    440e:	c12d                	beqz	a0,4470 <forkforkfork+0x8a>
  sleep(20); // two seconds
    4410:	4551                	li	a0,20
    4412:	00001097          	auipc	ra,0x1
    4416:	7e2080e7          	jalr	2018(ra) # 5bf4 <sleep>
  close(open("stopforking", O_CREATE | O_RDWR));
    441a:	20200593          	li	a1,514
    441e:	00004517          	auipc	a0,0x4
    4422:	82250513          	addi	a0,a0,-2014 # 7c40 <malloc+0x1c8a>
    4426:	00001097          	auipc	ra,0x1
    442a:	77e080e7          	jalr	1918(ra) # 5ba4 <open>
    442e:	00001097          	auipc	ra,0x1
    4432:	75e080e7          	jalr	1886(ra) # 5b8c <close>
  wait(0);
    4436:	4501                	li	a0,0
    4438:	00001097          	auipc	ra,0x1
    443c:	734080e7          	jalr	1844(ra) # 5b6c <wait>
  sleep(10); // one second
    4440:	4529                	li	a0,10
    4442:	00001097          	auipc	ra,0x1
    4446:	7b2080e7          	jalr	1970(ra) # 5bf4 <sleep>
}
    444a:	60e2                	ld	ra,24(sp)
    444c:	6442                	ld	s0,16(sp)
    444e:	64a2                	ld	s1,8(sp)
    4450:	6105                	addi	sp,sp,32
    4452:	8082                	ret
    printf("%s: fork failed", s);
    4454:	85a6                	mv	a1,s1
    4456:	00002517          	auipc	a0,0x2
    445a:	6ca50513          	addi	a0,a0,1738 # 6b20 <malloc+0xb6a>
    445e:	00002097          	auipc	ra,0x2
    4462:	aa0080e7          	jalr	-1376(ra) # 5efe <printf>
    exit(1);
    4466:	4505                	li	a0,1
    4468:	00001097          	auipc	ra,0x1
    446c:	6fc080e7          	jalr	1788(ra) # 5b64 <exit>
      int fd = open("stopforking", 0);
    4470:	00003497          	auipc	s1,0x3
    4474:	7d048493          	addi	s1,s1,2000 # 7c40 <malloc+0x1c8a>
    4478:	4581                	li	a1,0
    447a:	8526                	mv	a0,s1
    447c:	00001097          	auipc	ra,0x1
    4480:	728080e7          	jalr	1832(ra) # 5ba4 <open>
      if (fd >= 0)
    4484:	02055463          	bgez	a0,44ac <forkforkfork+0xc6>
      if (fork() < 0)
    4488:	00001097          	auipc	ra,0x1
    448c:	6d4080e7          	jalr	1748(ra) # 5b5c <fork>
    4490:	fe0554e3          	bgez	a0,4478 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE | O_RDWR));
    4494:	20200593          	li	a1,514
    4498:	8526                	mv	a0,s1
    449a:	00001097          	auipc	ra,0x1
    449e:	70a080e7          	jalr	1802(ra) # 5ba4 <open>
    44a2:	00001097          	auipc	ra,0x1
    44a6:	6ea080e7          	jalr	1770(ra) # 5b8c <close>
    44aa:	b7f9                	j	4478 <forkforkfork+0x92>
        exit(0);
    44ac:	4501                	li	a0,0
    44ae:	00001097          	auipc	ra,0x1
    44b2:	6b6080e7          	jalr	1718(ra) # 5b64 <exit>

00000000000044b6 <killstatus>:
{
    44b6:	7139                	addi	sp,sp,-64
    44b8:	fc06                	sd	ra,56(sp)
    44ba:	f822                	sd	s0,48(sp)
    44bc:	f426                	sd	s1,40(sp)
    44be:	f04a                	sd	s2,32(sp)
    44c0:	ec4e                	sd	s3,24(sp)
    44c2:	e852                	sd	s4,16(sp)
    44c4:	0080                	addi	s0,sp,64
    44c6:	8a2a                	mv	s4,a0
    44c8:	06400913          	li	s2,100
    if (xst != -1)
    44cc:	59fd                	li	s3,-1
    int pid1 = fork();
    44ce:	00001097          	auipc	ra,0x1
    44d2:	68e080e7          	jalr	1678(ra) # 5b5c <fork>
    44d6:	84aa                	mv	s1,a0
    if (pid1 < 0)
    44d8:	02054f63          	bltz	a0,4516 <killstatus+0x60>
    if (pid1 == 0)
    44dc:	c939                	beqz	a0,4532 <killstatus+0x7c>
    sleep(1);
    44de:	4505                	li	a0,1
    44e0:	00001097          	auipc	ra,0x1
    44e4:	714080e7          	jalr	1812(ra) # 5bf4 <sleep>
    kill(pid1);
    44e8:	8526                	mv	a0,s1
    44ea:	00001097          	auipc	ra,0x1
    44ee:	6aa080e7          	jalr	1706(ra) # 5b94 <kill>
    wait(&xst);
    44f2:	fcc40513          	addi	a0,s0,-52
    44f6:	00001097          	auipc	ra,0x1
    44fa:	676080e7          	jalr	1654(ra) # 5b6c <wait>
    if (xst != -1)
    44fe:	fcc42783          	lw	a5,-52(s0)
    4502:	03379d63          	bne	a5,s3,453c <killstatus+0x86>
  for (int i = 0; i < 100; i++)
    4506:	397d                	addiw	s2,s2,-1
    4508:	fc0913e3          	bnez	s2,44ce <killstatus+0x18>
  exit(0);
    450c:	4501                	li	a0,0
    450e:	00001097          	auipc	ra,0x1
    4512:	656080e7          	jalr	1622(ra) # 5b64 <exit>
      printf("%s: fork failed\n", s);
    4516:	85d2                	mv	a1,s4
    4518:	00002517          	auipc	a0,0x2
    451c:	44850513          	addi	a0,a0,1096 # 6960 <malloc+0x9aa>
    4520:	00002097          	auipc	ra,0x2
    4524:	9de080e7          	jalr	-1570(ra) # 5efe <printf>
      exit(1);
    4528:	4505                	li	a0,1
    452a:	00001097          	auipc	ra,0x1
    452e:	63a080e7          	jalr	1594(ra) # 5b64 <exit>
        getpid();
    4532:	00001097          	auipc	ra,0x1
    4536:	6b2080e7          	jalr	1714(ra) # 5be4 <getpid>
      while (1)
    453a:	bfe5                	j	4532 <killstatus+0x7c>
      printf("%s: status should be -1\n", s);
    453c:	85d2                	mv	a1,s4
    453e:	00003517          	auipc	a0,0x3
    4542:	71250513          	addi	a0,a0,1810 # 7c50 <malloc+0x1c9a>
    4546:	00002097          	auipc	ra,0x2
    454a:	9b8080e7          	jalr	-1608(ra) # 5efe <printf>
      exit(1);
    454e:	4505                	li	a0,1
    4550:	00001097          	auipc	ra,0x1
    4554:	614080e7          	jalr	1556(ra) # 5b64 <exit>

0000000000004558 <preempt>:
{
    4558:	7139                	addi	sp,sp,-64
    455a:	fc06                	sd	ra,56(sp)
    455c:	f822                	sd	s0,48(sp)
    455e:	f426                	sd	s1,40(sp)
    4560:	f04a                	sd	s2,32(sp)
    4562:	ec4e                	sd	s3,24(sp)
    4564:	e852                	sd	s4,16(sp)
    4566:	0080                	addi	s0,sp,64
    4568:	892a                	mv	s2,a0
  pid1 = fork();
    456a:	00001097          	auipc	ra,0x1
    456e:	5f2080e7          	jalr	1522(ra) # 5b5c <fork>
  if (pid1 < 0)
    4572:	00054563          	bltz	a0,457c <preempt+0x24>
    4576:	84aa                	mv	s1,a0
  if (pid1 == 0)
    4578:	e105                	bnez	a0,4598 <preempt+0x40>
    for (;;)
    457a:	a001                	j	457a <preempt+0x22>
    printf("%s: fork failed", s);
    457c:	85ca                	mv	a1,s2
    457e:	00002517          	auipc	a0,0x2
    4582:	5a250513          	addi	a0,a0,1442 # 6b20 <malloc+0xb6a>
    4586:	00002097          	auipc	ra,0x2
    458a:	978080e7          	jalr	-1672(ra) # 5efe <printf>
    exit(1);
    458e:	4505                	li	a0,1
    4590:	00001097          	auipc	ra,0x1
    4594:	5d4080e7          	jalr	1492(ra) # 5b64 <exit>
  pid2 = fork();
    4598:	00001097          	auipc	ra,0x1
    459c:	5c4080e7          	jalr	1476(ra) # 5b5c <fork>
    45a0:	89aa                	mv	s3,a0
  if (pid2 < 0)
    45a2:	00054463          	bltz	a0,45aa <preempt+0x52>
  if (pid2 == 0)
    45a6:	e105                	bnez	a0,45c6 <preempt+0x6e>
    for (;;)
    45a8:	a001                	j	45a8 <preempt+0x50>
    printf("%s: fork failed\n", s);
    45aa:	85ca                	mv	a1,s2
    45ac:	00002517          	auipc	a0,0x2
    45b0:	3b450513          	addi	a0,a0,948 # 6960 <malloc+0x9aa>
    45b4:	00002097          	auipc	ra,0x2
    45b8:	94a080e7          	jalr	-1718(ra) # 5efe <printf>
    exit(1);
    45bc:	4505                	li	a0,1
    45be:	00001097          	auipc	ra,0x1
    45c2:	5a6080e7          	jalr	1446(ra) # 5b64 <exit>
  pipe(pfds);
    45c6:	fc840513          	addi	a0,s0,-56
    45ca:	00001097          	auipc	ra,0x1
    45ce:	5aa080e7          	jalr	1450(ra) # 5b74 <pipe>
  pid3 = fork();
    45d2:	00001097          	auipc	ra,0x1
    45d6:	58a080e7          	jalr	1418(ra) # 5b5c <fork>
    45da:	8a2a                	mv	s4,a0
  if (pid3 < 0)
    45dc:	02054e63          	bltz	a0,4618 <preempt+0xc0>
  if (pid3 == 0)
    45e0:	e525                	bnez	a0,4648 <preempt+0xf0>
    close(pfds[0]);
    45e2:	fc842503          	lw	a0,-56(s0)
    45e6:	00001097          	auipc	ra,0x1
    45ea:	5a6080e7          	jalr	1446(ra) # 5b8c <close>
    if (write(pfds[1], "x", 1) != 1)
    45ee:	4605                	li	a2,1
    45f0:	00002597          	auipc	a1,0x2
    45f4:	b5858593          	addi	a1,a1,-1192 # 6148 <malloc+0x192>
    45f8:	fcc42503          	lw	a0,-52(s0)
    45fc:	00001097          	auipc	ra,0x1
    4600:	588080e7          	jalr	1416(ra) # 5b84 <write>
    4604:	4785                	li	a5,1
    4606:	02f51763          	bne	a0,a5,4634 <preempt+0xdc>
    close(pfds[1]);
    460a:	fcc42503          	lw	a0,-52(s0)
    460e:	00001097          	auipc	ra,0x1
    4612:	57e080e7          	jalr	1406(ra) # 5b8c <close>
    for (;;)
    4616:	a001                	j	4616 <preempt+0xbe>
    printf("%s: fork failed\n", s);
    4618:	85ca                	mv	a1,s2
    461a:	00002517          	auipc	a0,0x2
    461e:	34650513          	addi	a0,a0,838 # 6960 <malloc+0x9aa>
    4622:	00002097          	auipc	ra,0x2
    4626:	8dc080e7          	jalr	-1828(ra) # 5efe <printf>
    exit(1);
    462a:	4505                	li	a0,1
    462c:	00001097          	auipc	ra,0x1
    4630:	538080e7          	jalr	1336(ra) # 5b64 <exit>
      printf("%s: preempt write error", s);
    4634:	85ca                	mv	a1,s2
    4636:	00003517          	auipc	a0,0x3
    463a:	63a50513          	addi	a0,a0,1594 # 7c70 <malloc+0x1cba>
    463e:	00002097          	auipc	ra,0x2
    4642:	8c0080e7          	jalr	-1856(ra) # 5efe <printf>
    4646:	b7d1                	j	460a <preempt+0xb2>
  close(pfds[1]);
    4648:	fcc42503          	lw	a0,-52(s0)
    464c:	00001097          	auipc	ra,0x1
    4650:	540080e7          	jalr	1344(ra) # 5b8c <close>
  if (read(pfds[0], buf, sizeof(buf)) != 1)
    4654:	660d                	lui	a2,0x3
    4656:	00008597          	auipc	a1,0x8
    465a:	62258593          	addi	a1,a1,1570 # cc78 <buf>
    465e:	fc842503          	lw	a0,-56(s0)
    4662:	00001097          	auipc	ra,0x1
    4666:	51a080e7          	jalr	1306(ra) # 5b7c <read>
    466a:	4785                	li	a5,1
    466c:	02f50363          	beq	a0,a5,4692 <preempt+0x13a>
    printf("%s: preempt read error", s);
    4670:	85ca                	mv	a1,s2
    4672:	00003517          	auipc	a0,0x3
    4676:	61650513          	addi	a0,a0,1558 # 7c88 <malloc+0x1cd2>
    467a:	00002097          	auipc	ra,0x2
    467e:	884080e7          	jalr	-1916(ra) # 5efe <printf>
}
    4682:	70e2                	ld	ra,56(sp)
    4684:	7442                	ld	s0,48(sp)
    4686:	74a2                	ld	s1,40(sp)
    4688:	7902                	ld	s2,32(sp)
    468a:	69e2                	ld	s3,24(sp)
    468c:	6a42                	ld	s4,16(sp)
    468e:	6121                	addi	sp,sp,64
    4690:	8082                	ret
  close(pfds[0]);
    4692:	fc842503          	lw	a0,-56(s0)
    4696:	00001097          	auipc	ra,0x1
    469a:	4f6080e7          	jalr	1270(ra) # 5b8c <close>
  printf("kill... ");
    469e:	00003517          	auipc	a0,0x3
    46a2:	60250513          	addi	a0,a0,1538 # 7ca0 <malloc+0x1cea>
    46a6:	00002097          	auipc	ra,0x2
    46aa:	858080e7          	jalr	-1960(ra) # 5efe <printf>
  kill(pid1);
    46ae:	8526                	mv	a0,s1
    46b0:	00001097          	auipc	ra,0x1
    46b4:	4e4080e7          	jalr	1252(ra) # 5b94 <kill>
  kill(pid2);
    46b8:	854e                	mv	a0,s3
    46ba:	00001097          	auipc	ra,0x1
    46be:	4da080e7          	jalr	1242(ra) # 5b94 <kill>
  kill(pid3);
    46c2:	8552                	mv	a0,s4
    46c4:	00001097          	auipc	ra,0x1
    46c8:	4d0080e7          	jalr	1232(ra) # 5b94 <kill>
  printf("wait... ");
    46cc:	00003517          	auipc	a0,0x3
    46d0:	5e450513          	addi	a0,a0,1508 # 7cb0 <malloc+0x1cfa>
    46d4:	00002097          	auipc	ra,0x2
    46d8:	82a080e7          	jalr	-2006(ra) # 5efe <printf>
  wait(0);
    46dc:	4501                	li	a0,0
    46de:	00001097          	auipc	ra,0x1
    46e2:	48e080e7          	jalr	1166(ra) # 5b6c <wait>
  wait(0);
    46e6:	4501                	li	a0,0
    46e8:	00001097          	auipc	ra,0x1
    46ec:	484080e7          	jalr	1156(ra) # 5b6c <wait>
  wait(0);
    46f0:	4501                	li	a0,0
    46f2:	00001097          	auipc	ra,0x1
    46f6:	47a080e7          	jalr	1146(ra) # 5b6c <wait>
    46fa:	b761                	j	4682 <preempt+0x12a>

00000000000046fc <reparent>:
{
    46fc:	7179                	addi	sp,sp,-48
    46fe:	f406                	sd	ra,40(sp)
    4700:	f022                	sd	s0,32(sp)
    4702:	ec26                	sd	s1,24(sp)
    4704:	e84a                	sd	s2,16(sp)
    4706:	e44e                	sd	s3,8(sp)
    4708:	e052                	sd	s4,0(sp)
    470a:	1800                	addi	s0,sp,48
    470c:	89aa                	mv	s3,a0
  int master_pid = getpid();
    470e:	00001097          	auipc	ra,0x1
    4712:	4d6080e7          	jalr	1238(ra) # 5be4 <getpid>
    4716:	8a2a                	mv	s4,a0
    4718:	0c800913          	li	s2,200
    int pid = fork();
    471c:	00001097          	auipc	ra,0x1
    4720:	440080e7          	jalr	1088(ra) # 5b5c <fork>
    4724:	84aa                	mv	s1,a0
    if (pid < 0)
    4726:	02054263          	bltz	a0,474a <reparent+0x4e>
    if (pid)
    472a:	cd21                	beqz	a0,4782 <reparent+0x86>
      if (wait(0) != pid)
    472c:	4501                	li	a0,0
    472e:	00001097          	auipc	ra,0x1
    4732:	43e080e7          	jalr	1086(ra) # 5b6c <wait>
    4736:	02951863          	bne	a0,s1,4766 <reparent+0x6a>
  for (int i = 0; i < 200; i++)
    473a:	397d                	addiw	s2,s2,-1
    473c:	fe0910e3          	bnez	s2,471c <reparent+0x20>
  exit(0);
    4740:	4501                	li	a0,0
    4742:	00001097          	auipc	ra,0x1
    4746:	422080e7          	jalr	1058(ra) # 5b64 <exit>
      printf("%s: fork failed\n", s);
    474a:	85ce                	mv	a1,s3
    474c:	00002517          	auipc	a0,0x2
    4750:	21450513          	addi	a0,a0,532 # 6960 <malloc+0x9aa>
    4754:	00001097          	auipc	ra,0x1
    4758:	7aa080e7          	jalr	1962(ra) # 5efe <printf>
      exit(1);
    475c:	4505                	li	a0,1
    475e:	00001097          	auipc	ra,0x1
    4762:	406080e7          	jalr	1030(ra) # 5b64 <exit>
        printf("%s: wait wrong pid\n", s);
    4766:	85ce                	mv	a1,s3
    4768:	00002517          	auipc	a0,0x2
    476c:	38050513          	addi	a0,a0,896 # 6ae8 <malloc+0xb32>
    4770:	00001097          	auipc	ra,0x1
    4774:	78e080e7          	jalr	1934(ra) # 5efe <printf>
        exit(1);
    4778:	4505                	li	a0,1
    477a:	00001097          	auipc	ra,0x1
    477e:	3ea080e7          	jalr	1002(ra) # 5b64 <exit>
      int pid2 = fork();
    4782:	00001097          	auipc	ra,0x1
    4786:	3da080e7          	jalr	986(ra) # 5b5c <fork>
      if (pid2 < 0)
    478a:	00054763          	bltz	a0,4798 <reparent+0x9c>
      exit(0);
    478e:	4501                	li	a0,0
    4790:	00001097          	auipc	ra,0x1
    4794:	3d4080e7          	jalr	980(ra) # 5b64 <exit>
        kill(master_pid);
    4798:	8552                	mv	a0,s4
    479a:	00001097          	auipc	ra,0x1
    479e:	3fa080e7          	jalr	1018(ra) # 5b94 <kill>
        exit(1);
    47a2:	4505                	li	a0,1
    47a4:	00001097          	auipc	ra,0x1
    47a8:	3c0080e7          	jalr	960(ra) # 5b64 <exit>

00000000000047ac <sbrkfail>:
{
    47ac:	7119                	addi	sp,sp,-128
    47ae:	fc86                	sd	ra,120(sp)
    47b0:	f8a2                	sd	s0,112(sp)
    47b2:	f4a6                	sd	s1,104(sp)
    47b4:	f0ca                	sd	s2,96(sp)
    47b6:	ecce                	sd	s3,88(sp)
    47b8:	e8d2                	sd	s4,80(sp)
    47ba:	e4d6                	sd	s5,72(sp)
    47bc:	0100                	addi	s0,sp,128
    47be:	8aaa                	mv	s5,a0
  if (pipe(fds) != 0)
    47c0:	fb040513          	addi	a0,s0,-80
    47c4:	00001097          	auipc	ra,0x1
    47c8:	3b0080e7          	jalr	944(ra) # 5b74 <pipe>
    47cc:	e901                	bnez	a0,47dc <sbrkfail+0x30>
    47ce:	f8040493          	addi	s1,s0,-128
    47d2:	fa840993          	addi	s3,s0,-88
    47d6:	8926                	mv	s2,s1
    if (pids[i] != -1)
    47d8:	5a7d                	li	s4,-1
    47da:	a085                	j	483a <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    47dc:	85d6                	mv	a1,s5
    47de:	00002517          	auipc	a0,0x2
    47e2:	28a50513          	addi	a0,a0,650 # 6a68 <malloc+0xab2>
    47e6:	00001097          	auipc	ra,0x1
    47ea:	718080e7          	jalr	1816(ra) # 5efe <printf>
    exit(1);
    47ee:	4505                	li	a0,1
    47f0:	00001097          	auipc	ra,0x1
    47f4:	374080e7          	jalr	884(ra) # 5b64 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    47f8:	00001097          	auipc	ra,0x1
    47fc:	3f4080e7          	jalr	1012(ra) # 5bec <sbrk>
    4800:	064007b7          	lui	a5,0x6400
    4804:	40a7853b          	subw	a0,a5,a0
    4808:	00001097          	auipc	ra,0x1
    480c:	3e4080e7          	jalr	996(ra) # 5bec <sbrk>
      write(fds[1], "x", 1);
    4810:	4605                	li	a2,1
    4812:	00002597          	auipc	a1,0x2
    4816:	93658593          	addi	a1,a1,-1738 # 6148 <malloc+0x192>
    481a:	fb442503          	lw	a0,-76(s0)
    481e:	00001097          	auipc	ra,0x1
    4822:	366080e7          	jalr	870(ra) # 5b84 <write>
        sleep(1000);
    4826:	3e800513          	li	a0,1000
    482a:	00001097          	auipc	ra,0x1
    482e:	3ca080e7          	jalr	970(ra) # 5bf4 <sleep>
      for (;;)
    4832:	bfd5                	j	4826 <sbrkfail+0x7a>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++)
    4834:	0911                	addi	s2,s2,4
    4836:	03390563          	beq	s2,s3,4860 <sbrkfail+0xb4>
    if ((pids[i] = fork()) == 0)
    483a:	00001097          	auipc	ra,0x1
    483e:	322080e7          	jalr	802(ra) # 5b5c <fork>
    4842:	00a92023          	sw	a0,0(s2)
    4846:	d94d                	beqz	a0,47f8 <sbrkfail+0x4c>
    if (pids[i] != -1)
    4848:	ff4506e3          	beq	a0,s4,4834 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    484c:	4605                	li	a2,1
    484e:	faf40593          	addi	a1,s0,-81
    4852:	fb042503          	lw	a0,-80(s0)
    4856:	00001097          	auipc	ra,0x1
    485a:	326080e7          	jalr	806(ra) # 5b7c <read>
    485e:	bfd9                	j	4834 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4860:	6505                	lui	a0,0x1
    4862:	00001097          	auipc	ra,0x1
    4866:	38a080e7          	jalr	906(ra) # 5bec <sbrk>
    486a:	8a2a                	mv	s4,a0
    if (pids[i] == -1)
    486c:	597d                	li	s2,-1
    486e:	a021                	j	4876 <sbrkfail+0xca>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++)
    4870:	0491                	addi	s1,s1,4
    4872:	01348f63          	beq	s1,s3,4890 <sbrkfail+0xe4>
    if (pids[i] == -1)
    4876:	4088                	lw	a0,0(s1)
    4878:	ff250ce3          	beq	a0,s2,4870 <sbrkfail+0xc4>
    kill(pids[i]);
    487c:	00001097          	auipc	ra,0x1
    4880:	318080e7          	jalr	792(ra) # 5b94 <kill>
    wait(0);
    4884:	4501                	li	a0,0
    4886:	00001097          	auipc	ra,0x1
    488a:	2e6080e7          	jalr	742(ra) # 5b6c <wait>
    488e:	b7cd                	j	4870 <sbrkfail+0xc4>
  if (c == (char *)0xffffffffffffffffL)
    4890:	57fd                	li	a5,-1
    4892:	04fa0163          	beq	s4,a5,48d4 <sbrkfail+0x128>
  pid = fork();
    4896:	00001097          	auipc	ra,0x1
    489a:	2c6080e7          	jalr	710(ra) # 5b5c <fork>
    489e:	84aa                	mv	s1,a0
  if (pid < 0)
    48a0:	04054863          	bltz	a0,48f0 <sbrkfail+0x144>
  if (pid == 0)
    48a4:	c525                	beqz	a0,490c <sbrkfail+0x160>
  wait(&xstatus);
    48a6:	fbc40513          	addi	a0,s0,-68
    48aa:	00001097          	auipc	ra,0x1
    48ae:	2c2080e7          	jalr	706(ra) # 5b6c <wait>
  if (xstatus != -1 && xstatus != 2)
    48b2:	fbc42783          	lw	a5,-68(s0)
    48b6:	577d                	li	a4,-1
    48b8:	00e78563          	beq	a5,a4,48c2 <sbrkfail+0x116>
    48bc:	4709                	li	a4,2
    48be:	08e79d63          	bne	a5,a4,4958 <sbrkfail+0x1ac>
}
    48c2:	70e6                	ld	ra,120(sp)
    48c4:	7446                	ld	s0,112(sp)
    48c6:	74a6                	ld	s1,104(sp)
    48c8:	7906                	ld	s2,96(sp)
    48ca:	69e6                	ld	s3,88(sp)
    48cc:	6a46                	ld	s4,80(sp)
    48ce:	6aa6                	ld	s5,72(sp)
    48d0:	6109                	addi	sp,sp,128
    48d2:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    48d4:	85d6                	mv	a1,s5
    48d6:	00003517          	auipc	a0,0x3
    48da:	3ea50513          	addi	a0,a0,1002 # 7cc0 <malloc+0x1d0a>
    48de:	00001097          	auipc	ra,0x1
    48e2:	620080e7          	jalr	1568(ra) # 5efe <printf>
    exit(1);
    48e6:	4505                	li	a0,1
    48e8:	00001097          	auipc	ra,0x1
    48ec:	27c080e7          	jalr	636(ra) # 5b64 <exit>
    printf("%s: fork failed\n", s);
    48f0:	85d6                	mv	a1,s5
    48f2:	00002517          	auipc	a0,0x2
    48f6:	06e50513          	addi	a0,a0,110 # 6960 <malloc+0x9aa>
    48fa:	00001097          	auipc	ra,0x1
    48fe:	604080e7          	jalr	1540(ra) # 5efe <printf>
    exit(1);
    4902:	4505                	li	a0,1
    4904:	00001097          	auipc	ra,0x1
    4908:	260080e7          	jalr	608(ra) # 5b64 <exit>
    a = sbrk(0);
    490c:	4501                	li	a0,0
    490e:	00001097          	auipc	ra,0x1
    4912:	2de080e7          	jalr	734(ra) # 5bec <sbrk>
    4916:	892a                	mv	s2,a0
    sbrk(10 * BIG);
    4918:	3e800537          	lui	a0,0x3e800
    491c:	00001097          	auipc	ra,0x1
    4920:	2d0080e7          	jalr	720(ra) # 5bec <sbrk>
    for (i = 0; i < 10 * BIG; i += PGSIZE)
    4924:	87ca                	mv	a5,s2
    4926:	3e800737          	lui	a4,0x3e800
    492a:	993a                	add	s2,s2,a4
    492c:	6705                	lui	a4,0x1
      n += *(a + i);
    492e:	0007c683          	lbu	a3,0(a5) # 6400000 <base+0x63f0388>
    4932:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10 * BIG; i += PGSIZE)
    4934:	97ba                	add	a5,a5,a4
    4936:	ff279ce3          	bne	a5,s2,492e <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    493a:	8626                	mv	a2,s1
    493c:	85d6                	mv	a1,s5
    493e:	00003517          	auipc	a0,0x3
    4942:	3a250513          	addi	a0,a0,930 # 7ce0 <malloc+0x1d2a>
    4946:	00001097          	auipc	ra,0x1
    494a:	5b8080e7          	jalr	1464(ra) # 5efe <printf>
    exit(1);
    494e:	4505                	li	a0,1
    4950:	00001097          	auipc	ra,0x1
    4954:	214080e7          	jalr	532(ra) # 5b64 <exit>
    exit(1);
    4958:	4505                	li	a0,1
    495a:	00001097          	auipc	ra,0x1
    495e:	20a080e7          	jalr	522(ra) # 5b64 <exit>

0000000000004962 <mem>:
{
    4962:	7139                	addi	sp,sp,-64
    4964:	fc06                	sd	ra,56(sp)
    4966:	f822                	sd	s0,48(sp)
    4968:	f426                	sd	s1,40(sp)
    496a:	f04a                	sd	s2,32(sp)
    496c:	ec4e                	sd	s3,24(sp)
    496e:	0080                	addi	s0,sp,64
    4970:	89aa                	mv	s3,a0
  if ((pid = fork()) == 0)
    4972:	00001097          	auipc	ra,0x1
    4976:	1ea080e7          	jalr	490(ra) # 5b5c <fork>
    m1 = 0;
    497a:	4481                	li	s1,0
    while ((m2 = malloc(10001)) != 0)
    497c:	6909                	lui	s2,0x2
    497e:	71190913          	addi	s2,s2,1809 # 2711 <rwsbrk+0x17>
  if ((pid = fork()) == 0)
    4982:	c115                	beqz	a0,49a6 <mem+0x44>
    wait(&xstatus);
    4984:	fcc40513          	addi	a0,s0,-52
    4988:	00001097          	auipc	ra,0x1
    498c:	1e4080e7          	jalr	484(ra) # 5b6c <wait>
    if (xstatus == -1)
    4990:	fcc42503          	lw	a0,-52(s0)
    4994:	57fd                	li	a5,-1
    4996:	06f50363          	beq	a0,a5,49fc <mem+0x9a>
    exit(xstatus);
    499a:	00001097          	auipc	ra,0x1
    499e:	1ca080e7          	jalr	458(ra) # 5b64 <exit>
      *(char **)m2 = m1;
    49a2:	e104                	sd	s1,0(a0)
      m1 = m2;
    49a4:	84aa                	mv	s1,a0
    while ((m2 = malloc(10001)) != 0)
    49a6:	854a                	mv	a0,s2
    49a8:	00001097          	auipc	ra,0x1
    49ac:	60e080e7          	jalr	1550(ra) # 5fb6 <malloc>
    49b0:	f96d                	bnez	a0,49a2 <mem+0x40>
    while (m1)
    49b2:	c881                	beqz	s1,49c2 <mem+0x60>
      m2 = *(char **)m1;
    49b4:	8526                	mv	a0,s1
    49b6:	6084                	ld	s1,0(s1)
      free(m1);
    49b8:	00001097          	auipc	ra,0x1
    49bc:	57c080e7          	jalr	1404(ra) # 5f34 <free>
    while (m1)
    49c0:	f8f5                	bnez	s1,49b4 <mem+0x52>
    m1 = malloc(1024 * 20);
    49c2:	6515                	lui	a0,0x5
    49c4:	00001097          	auipc	ra,0x1
    49c8:	5f2080e7          	jalr	1522(ra) # 5fb6 <malloc>
    if (m1 == 0)
    49cc:	c911                	beqz	a0,49e0 <mem+0x7e>
    free(m1);
    49ce:	00001097          	auipc	ra,0x1
    49d2:	566080e7          	jalr	1382(ra) # 5f34 <free>
    exit(0);
    49d6:	4501                	li	a0,0
    49d8:	00001097          	auipc	ra,0x1
    49dc:	18c080e7          	jalr	396(ra) # 5b64 <exit>
      printf("couldn't allocate mem?!!\n", s);
    49e0:	85ce                	mv	a1,s3
    49e2:	00003517          	auipc	a0,0x3
    49e6:	32e50513          	addi	a0,a0,814 # 7d10 <malloc+0x1d5a>
    49ea:	00001097          	auipc	ra,0x1
    49ee:	514080e7          	jalr	1300(ra) # 5efe <printf>
      exit(1);
    49f2:	4505                	li	a0,1
    49f4:	00001097          	auipc	ra,0x1
    49f8:	170080e7          	jalr	368(ra) # 5b64 <exit>
      exit(0);
    49fc:	4501                	li	a0,0
    49fe:	00001097          	auipc	ra,0x1
    4a02:	166080e7          	jalr	358(ra) # 5b64 <exit>

0000000000004a06 <sharedfd>:
{
    4a06:	7159                	addi	sp,sp,-112
    4a08:	f486                	sd	ra,104(sp)
    4a0a:	f0a2                	sd	s0,96(sp)
    4a0c:	eca6                	sd	s1,88(sp)
    4a0e:	e8ca                	sd	s2,80(sp)
    4a10:	e4ce                	sd	s3,72(sp)
    4a12:	e0d2                	sd	s4,64(sp)
    4a14:	fc56                	sd	s5,56(sp)
    4a16:	f85a                	sd	s6,48(sp)
    4a18:	f45e                	sd	s7,40(sp)
    4a1a:	1880                	addi	s0,sp,112
    4a1c:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4a1e:	00003517          	auipc	a0,0x3
    4a22:	31250513          	addi	a0,a0,786 # 7d30 <malloc+0x1d7a>
    4a26:	00001097          	auipc	ra,0x1
    4a2a:	18e080e7          	jalr	398(ra) # 5bb4 <unlink>
  fd = open("sharedfd", O_CREATE | O_RDWR);
    4a2e:	20200593          	li	a1,514
    4a32:	00003517          	auipc	a0,0x3
    4a36:	2fe50513          	addi	a0,a0,766 # 7d30 <malloc+0x1d7a>
    4a3a:	00001097          	auipc	ra,0x1
    4a3e:	16a080e7          	jalr	362(ra) # 5ba4 <open>
  if (fd < 0)
    4a42:	04054a63          	bltz	a0,4a96 <sharedfd+0x90>
    4a46:	892a                	mv	s2,a0
  pid = fork();
    4a48:	00001097          	auipc	ra,0x1
    4a4c:	114080e7          	jalr	276(ra) # 5b5c <fork>
    4a50:	89aa                	mv	s3,a0
  memset(buf, pid == 0 ? 'c' : 'p', sizeof(buf));
    4a52:	06300593          	li	a1,99
    4a56:	c119                	beqz	a0,4a5c <sharedfd+0x56>
    4a58:	07000593          	li	a1,112
    4a5c:	4629                	li	a2,10
    4a5e:	fa040513          	addi	a0,s0,-96
    4a62:	00001097          	auipc	ra,0x1
    4a66:	f08080e7          	jalr	-248(ra) # 596a <memset>
    4a6a:	3e800493          	li	s1,1000
    if (write(fd, buf, sizeof(buf)) != sizeof(buf))
    4a6e:	4629                	li	a2,10
    4a70:	fa040593          	addi	a1,s0,-96
    4a74:	854a                	mv	a0,s2
    4a76:	00001097          	auipc	ra,0x1
    4a7a:	10e080e7          	jalr	270(ra) # 5b84 <write>
    4a7e:	47a9                	li	a5,10
    4a80:	02f51963          	bne	a0,a5,4ab2 <sharedfd+0xac>
  for (i = 0; i < N; i++)
    4a84:	34fd                	addiw	s1,s1,-1
    4a86:	f4e5                	bnez	s1,4a6e <sharedfd+0x68>
  if (pid == 0)
    4a88:	04099363          	bnez	s3,4ace <sharedfd+0xc8>
    exit(0);
    4a8c:	4501                	li	a0,0
    4a8e:	00001097          	auipc	ra,0x1
    4a92:	0d6080e7          	jalr	214(ra) # 5b64 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4a96:	85d2                	mv	a1,s4
    4a98:	00003517          	auipc	a0,0x3
    4a9c:	2a850513          	addi	a0,a0,680 # 7d40 <malloc+0x1d8a>
    4aa0:	00001097          	auipc	ra,0x1
    4aa4:	45e080e7          	jalr	1118(ra) # 5efe <printf>
    exit(1);
    4aa8:	4505                	li	a0,1
    4aaa:	00001097          	auipc	ra,0x1
    4aae:	0ba080e7          	jalr	186(ra) # 5b64 <exit>
      printf("%s: write sharedfd failed\n", s);
    4ab2:	85d2                	mv	a1,s4
    4ab4:	00003517          	auipc	a0,0x3
    4ab8:	2b450513          	addi	a0,a0,692 # 7d68 <malloc+0x1db2>
    4abc:	00001097          	auipc	ra,0x1
    4ac0:	442080e7          	jalr	1090(ra) # 5efe <printf>
      exit(1);
    4ac4:	4505                	li	a0,1
    4ac6:	00001097          	auipc	ra,0x1
    4aca:	09e080e7          	jalr	158(ra) # 5b64 <exit>
    wait(&xstatus);
    4ace:	f9c40513          	addi	a0,s0,-100
    4ad2:	00001097          	auipc	ra,0x1
    4ad6:	09a080e7          	jalr	154(ra) # 5b6c <wait>
    if (xstatus != 0)
    4ada:	f9c42983          	lw	s3,-100(s0)
    4ade:	00098763          	beqz	s3,4aec <sharedfd+0xe6>
      exit(xstatus);
    4ae2:	854e                	mv	a0,s3
    4ae4:	00001097          	auipc	ra,0x1
    4ae8:	080080e7          	jalr	128(ra) # 5b64 <exit>
  close(fd);
    4aec:	854a                	mv	a0,s2
    4aee:	00001097          	auipc	ra,0x1
    4af2:	09e080e7          	jalr	158(ra) # 5b8c <close>
  fd = open("sharedfd", 0);
    4af6:	4581                	li	a1,0
    4af8:	00003517          	auipc	a0,0x3
    4afc:	23850513          	addi	a0,a0,568 # 7d30 <malloc+0x1d7a>
    4b00:	00001097          	auipc	ra,0x1
    4b04:	0a4080e7          	jalr	164(ra) # 5ba4 <open>
    4b08:	8baa                	mv	s7,a0
  nc = np = 0;
    4b0a:	8ace                	mv	s5,s3
  if (fd < 0)
    4b0c:	02054563          	bltz	a0,4b36 <sharedfd+0x130>
    4b10:	faa40913          	addi	s2,s0,-86
      if (buf[i] == 'c')
    4b14:	06300493          	li	s1,99
      if (buf[i] == 'p')
    4b18:	07000b13          	li	s6,112
  while ((n = read(fd, buf, sizeof(buf))) > 0)
    4b1c:	4629                	li	a2,10
    4b1e:	fa040593          	addi	a1,s0,-96
    4b22:	855e                	mv	a0,s7
    4b24:	00001097          	auipc	ra,0x1
    4b28:	058080e7          	jalr	88(ra) # 5b7c <read>
    4b2c:	02a05f63          	blez	a0,4b6a <sharedfd+0x164>
    4b30:	fa040793          	addi	a5,s0,-96
    4b34:	a01d                	j	4b5a <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4b36:	85d2                	mv	a1,s4
    4b38:	00003517          	auipc	a0,0x3
    4b3c:	25050513          	addi	a0,a0,592 # 7d88 <malloc+0x1dd2>
    4b40:	00001097          	auipc	ra,0x1
    4b44:	3be080e7          	jalr	958(ra) # 5efe <printf>
    exit(1);
    4b48:	4505                	li	a0,1
    4b4a:	00001097          	auipc	ra,0x1
    4b4e:	01a080e7          	jalr	26(ra) # 5b64 <exit>
        nc++;
    4b52:	2985                	addiw	s3,s3,1
    for (i = 0; i < sizeof(buf); i++)
    4b54:	0785                	addi	a5,a5,1
    4b56:	fd2783e3          	beq	a5,s2,4b1c <sharedfd+0x116>
      if (buf[i] == 'c')
    4b5a:	0007c703          	lbu	a4,0(a5)
    4b5e:	fe970ae3          	beq	a4,s1,4b52 <sharedfd+0x14c>
      if (buf[i] == 'p')
    4b62:	ff6719e3          	bne	a4,s6,4b54 <sharedfd+0x14e>
        np++;
    4b66:	2a85                	addiw	s5,s5,1
    4b68:	b7f5                	j	4b54 <sharedfd+0x14e>
  close(fd);
    4b6a:	855e                	mv	a0,s7
    4b6c:	00001097          	auipc	ra,0x1
    4b70:	020080e7          	jalr	32(ra) # 5b8c <close>
  unlink("sharedfd");
    4b74:	00003517          	auipc	a0,0x3
    4b78:	1bc50513          	addi	a0,a0,444 # 7d30 <malloc+0x1d7a>
    4b7c:	00001097          	auipc	ra,0x1
    4b80:	038080e7          	jalr	56(ra) # 5bb4 <unlink>
  if (nc == N * SZ && np == N * SZ)
    4b84:	6789                	lui	a5,0x2
    4b86:	71078793          	addi	a5,a5,1808 # 2710 <rwsbrk+0x16>
    4b8a:	00f99763          	bne	s3,a5,4b98 <sharedfd+0x192>
    4b8e:	6789                	lui	a5,0x2
    4b90:	71078793          	addi	a5,a5,1808 # 2710 <rwsbrk+0x16>
    4b94:	02fa8063          	beq	s5,a5,4bb4 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4b98:	85d2                	mv	a1,s4
    4b9a:	00003517          	auipc	a0,0x3
    4b9e:	21650513          	addi	a0,a0,534 # 7db0 <malloc+0x1dfa>
    4ba2:	00001097          	auipc	ra,0x1
    4ba6:	35c080e7          	jalr	860(ra) # 5efe <printf>
    exit(1);
    4baa:	4505                	li	a0,1
    4bac:	00001097          	auipc	ra,0x1
    4bb0:	fb8080e7          	jalr	-72(ra) # 5b64 <exit>
    exit(0);
    4bb4:	4501                	li	a0,0
    4bb6:	00001097          	auipc	ra,0x1
    4bba:	fae080e7          	jalr	-82(ra) # 5b64 <exit>

0000000000004bbe <fourfiles>:
{
    4bbe:	7171                	addi	sp,sp,-176
    4bc0:	f506                	sd	ra,168(sp)
    4bc2:	f122                	sd	s0,160(sp)
    4bc4:	ed26                	sd	s1,152(sp)
    4bc6:	e94a                	sd	s2,144(sp)
    4bc8:	e54e                	sd	s3,136(sp)
    4bca:	e152                	sd	s4,128(sp)
    4bcc:	fcd6                	sd	s5,120(sp)
    4bce:	f8da                	sd	s6,112(sp)
    4bd0:	f4de                	sd	s7,104(sp)
    4bd2:	f0e2                	sd	s8,96(sp)
    4bd4:	ece6                	sd	s9,88(sp)
    4bd6:	e8ea                	sd	s10,80(sp)
    4bd8:	e4ee                	sd	s11,72(sp)
    4bda:	1900                	addi	s0,sp,176
    4bdc:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = {"f0", "f1", "f2", "f3"};
    4be0:	00003797          	auipc	a5,0x3
    4be4:	1e878793          	addi	a5,a5,488 # 7dc8 <malloc+0x1e12>
    4be8:	f6f43823          	sd	a5,-144(s0)
    4bec:	00003797          	auipc	a5,0x3
    4bf0:	1e478793          	addi	a5,a5,484 # 7dd0 <malloc+0x1e1a>
    4bf4:	f6f43c23          	sd	a5,-136(s0)
    4bf8:	00003797          	auipc	a5,0x3
    4bfc:	1e078793          	addi	a5,a5,480 # 7dd8 <malloc+0x1e22>
    4c00:	f8f43023          	sd	a5,-128(s0)
    4c04:	00003797          	auipc	a5,0x3
    4c08:	1dc78793          	addi	a5,a5,476 # 7de0 <malloc+0x1e2a>
    4c0c:	f8f43423          	sd	a5,-120(s0)
  for (pi = 0; pi < NCHILD; pi++)
    4c10:	f7040c13          	addi	s8,s0,-144
  char *names[] = {"f0", "f1", "f2", "f3"};
    4c14:	8962                	mv	s2,s8
  for (pi = 0; pi < NCHILD; pi++)
    4c16:	4481                	li	s1,0
    4c18:	4a11                	li	s4,4
    fname = names[pi];
    4c1a:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4c1e:	854e                	mv	a0,s3
    4c20:	00001097          	auipc	ra,0x1
    4c24:	f94080e7          	jalr	-108(ra) # 5bb4 <unlink>
    pid = fork();
    4c28:	00001097          	auipc	ra,0x1
    4c2c:	f34080e7          	jalr	-204(ra) # 5b5c <fork>
    if (pid < 0)
    4c30:	04054463          	bltz	a0,4c78 <fourfiles+0xba>
    if (pid == 0)
    4c34:	c12d                	beqz	a0,4c96 <fourfiles+0xd8>
  for (pi = 0; pi < NCHILD; pi++)
    4c36:	2485                	addiw	s1,s1,1
    4c38:	0921                	addi	s2,s2,8
    4c3a:	ff4490e3          	bne	s1,s4,4c1a <fourfiles+0x5c>
    4c3e:	4491                	li	s1,4
    wait(&xstatus);
    4c40:	f6c40513          	addi	a0,s0,-148
    4c44:	00001097          	auipc	ra,0x1
    4c48:	f28080e7          	jalr	-216(ra) # 5b6c <wait>
    if (xstatus != 0)
    4c4c:	f6c42b03          	lw	s6,-148(s0)
    4c50:	0c0b1e63          	bnez	s6,4d2c <fourfiles+0x16e>
  for (pi = 0; pi < NCHILD; pi++)
    4c54:	34fd                	addiw	s1,s1,-1
    4c56:	f4ed                	bnez	s1,4c40 <fourfiles+0x82>
    4c58:	03000b93          	li	s7,48
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    4c5c:	00008a17          	auipc	s4,0x8
    4c60:	01ca0a13          	addi	s4,s4,28 # cc78 <buf>
    4c64:	00008a97          	auipc	s5,0x8
    4c68:	015a8a93          	addi	s5,s5,21 # cc79 <buf+0x1>
    if (total != N * SZ)
    4c6c:	6d85                	lui	s11,0x1
    4c6e:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0x1e>
  for (i = 0; i < NCHILD; i++)
    4c72:	03400d13          	li	s10,52
    4c76:	aa1d                	j	4dac <fourfiles+0x1ee>
      printf("fork failed\n", s);
    4c78:	f5843583          	ld	a1,-168(s0)
    4c7c:	00002517          	auipc	a0,0x2
    4c80:	0ec50513          	addi	a0,a0,236 # 6d68 <malloc+0xdb2>
    4c84:	00001097          	auipc	ra,0x1
    4c88:	27a080e7          	jalr	634(ra) # 5efe <printf>
      exit(1);
    4c8c:	4505                	li	a0,1
    4c8e:	00001097          	auipc	ra,0x1
    4c92:	ed6080e7          	jalr	-298(ra) # 5b64 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4c96:	20200593          	li	a1,514
    4c9a:	854e                	mv	a0,s3
    4c9c:	00001097          	auipc	ra,0x1
    4ca0:	f08080e7          	jalr	-248(ra) # 5ba4 <open>
    4ca4:	892a                	mv	s2,a0
      if (fd < 0)
    4ca6:	04054763          	bltz	a0,4cf4 <fourfiles+0x136>
      memset(buf, '0' + pi, SZ);
    4caa:	1f400613          	li	a2,500
    4cae:	0304859b          	addiw	a1,s1,48
    4cb2:	00008517          	auipc	a0,0x8
    4cb6:	fc650513          	addi	a0,a0,-58 # cc78 <buf>
    4cba:	00001097          	auipc	ra,0x1
    4cbe:	cb0080e7          	jalr	-848(ra) # 596a <memset>
    4cc2:	44b1                	li	s1,12
        if ((n = write(fd, buf, SZ)) != SZ)
    4cc4:	00008997          	auipc	s3,0x8
    4cc8:	fb498993          	addi	s3,s3,-76 # cc78 <buf>
    4ccc:	1f400613          	li	a2,500
    4cd0:	85ce                	mv	a1,s3
    4cd2:	854a                	mv	a0,s2
    4cd4:	00001097          	auipc	ra,0x1
    4cd8:	eb0080e7          	jalr	-336(ra) # 5b84 <write>
    4cdc:	85aa                	mv	a1,a0
    4cde:	1f400793          	li	a5,500
    4ce2:	02f51863          	bne	a0,a5,4d12 <fourfiles+0x154>
      for (i = 0; i < N; i++)
    4ce6:	34fd                	addiw	s1,s1,-1
    4ce8:	f0f5                	bnez	s1,4ccc <fourfiles+0x10e>
      exit(0);
    4cea:	4501                	li	a0,0
    4cec:	00001097          	auipc	ra,0x1
    4cf0:	e78080e7          	jalr	-392(ra) # 5b64 <exit>
        printf("create failed\n", s);
    4cf4:	f5843583          	ld	a1,-168(s0)
    4cf8:	00003517          	auipc	a0,0x3
    4cfc:	0f050513          	addi	a0,a0,240 # 7de8 <malloc+0x1e32>
    4d00:	00001097          	auipc	ra,0x1
    4d04:	1fe080e7          	jalr	510(ra) # 5efe <printf>
        exit(1);
    4d08:	4505                	li	a0,1
    4d0a:	00001097          	auipc	ra,0x1
    4d0e:	e5a080e7          	jalr	-422(ra) # 5b64 <exit>
          printf("write failed %d\n", n);
    4d12:	00003517          	auipc	a0,0x3
    4d16:	0e650513          	addi	a0,a0,230 # 7df8 <malloc+0x1e42>
    4d1a:	00001097          	auipc	ra,0x1
    4d1e:	1e4080e7          	jalr	484(ra) # 5efe <printf>
          exit(1);
    4d22:	4505                	li	a0,1
    4d24:	00001097          	auipc	ra,0x1
    4d28:	e40080e7          	jalr	-448(ra) # 5b64 <exit>
      exit(xstatus);
    4d2c:	855a                	mv	a0,s6
    4d2e:	00001097          	auipc	ra,0x1
    4d32:	e36080e7          	jalr	-458(ra) # 5b64 <exit>
          printf("wrong char\n", s);
    4d36:	f5843583          	ld	a1,-168(s0)
    4d3a:	00003517          	auipc	a0,0x3
    4d3e:	0d650513          	addi	a0,a0,214 # 7e10 <malloc+0x1e5a>
    4d42:	00001097          	auipc	ra,0x1
    4d46:	1bc080e7          	jalr	444(ra) # 5efe <printf>
          exit(1);
    4d4a:	4505                	li	a0,1
    4d4c:	00001097          	auipc	ra,0x1
    4d50:	e18080e7          	jalr	-488(ra) # 5b64 <exit>
      total += n;
    4d54:	00a9093b          	addw	s2,s2,a0
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    4d58:	660d                	lui	a2,0x3
    4d5a:	85d2                	mv	a1,s4
    4d5c:	854e                	mv	a0,s3
    4d5e:	00001097          	auipc	ra,0x1
    4d62:	e1e080e7          	jalr	-482(ra) # 5b7c <read>
    4d66:	02a05363          	blez	a0,4d8c <fourfiles+0x1ce>
    4d6a:	00008797          	auipc	a5,0x8
    4d6e:	f0e78793          	addi	a5,a5,-242 # cc78 <buf>
    4d72:	fff5069b          	addiw	a3,a0,-1
    4d76:	1682                	slli	a3,a3,0x20
    4d78:	9281                	srli	a3,a3,0x20
    4d7a:	96d6                	add	a3,a3,s5
        if (buf[j] != '0' + i)
    4d7c:	0007c703          	lbu	a4,0(a5)
    4d80:	fa971be3          	bne	a4,s1,4d36 <fourfiles+0x178>
      for (j = 0; j < n; j++)
    4d84:	0785                	addi	a5,a5,1
    4d86:	fed79be3          	bne	a5,a3,4d7c <fourfiles+0x1be>
    4d8a:	b7e9                	j	4d54 <fourfiles+0x196>
    close(fd);
    4d8c:	854e                	mv	a0,s3
    4d8e:	00001097          	auipc	ra,0x1
    4d92:	dfe080e7          	jalr	-514(ra) # 5b8c <close>
    if (total != N * SZ)
    4d96:	03b91863          	bne	s2,s11,4dc6 <fourfiles+0x208>
    unlink(fname);
    4d9a:	8566                	mv	a0,s9
    4d9c:	00001097          	auipc	ra,0x1
    4da0:	e18080e7          	jalr	-488(ra) # 5bb4 <unlink>
  for (i = 0; i < NCHILD; i++)
    4da4:	0c21                	addi	s8,s8,8
    4da6:	2b85                	addiw	s7,s7,1
    4da8:	03ab8d63          	beq	s7,s10,4de2 <fourfiles+0x224>
    fname = names[i];
    4dac:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4db0:	4581                	li	a1,0
    4db2:	8566                	mv	a0,s9
    4db4:	00001097          	auipc	ra,0x1
    4db8:	df0080e7          	jalr	-528(ra) # 5ba4 <open>
    4dbc:	89aa                	mv	s3,a0
    total = 0;
    4dbe:	895a                	mv	s2,s6
        if (buf[j] != '0' + i)
    4dc0:	000b849b          	sext.w	s1,s7
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    4dc4:	bf51                	j	4d58 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    4dc6:	85ca                	mv	a1,s2
    4dc8:	00003517          	auipc	a0,0x3
    4dcc:	05850513          	addi	a0,a0,88 # 7e20 <malloc+0x1e6a>
    4dd0:	00001097          	auipc	ra,0x1
    4dd4:	12e080e7          	jalr	302(ra) # 5efe <printf>
      exit(1);
    4dd8:	4505                	li	a0,1
    4dda:	00001097          	auipc	ra,0x1
    4dde:	d8a080e7          	jalr	-630(ra) # 5b64 <exit>
}
    4de2:	70aa                	ld	ra,168(sp)
    4de4:	740a                	ld	s0,160(sp)
    4de6:	64ea                	ld	s1,152(sp)
    4de8:	694a                	ld	s2,144(sp)
    4dea:	69aa                	ld	s3,136(sp)
    4dec:	6a0a                	ld	s4,128(sp)
    4dee:	7ae6                	ld	s5,120(sp)
    4df0:	7b46                	ld	s6,112(sp)
    4df2:	7ba6                	ld	s7,104(sp)
    4df4:	7c06                	ld	s8,96(sp)
    4df6:	6ce6                	ld	s9,88(sp)
    4df8:	6d46                	ld	s10,80(sp)
    4dfa:	6da6                	ld	s11,72(sp)
    4dfc:	614d                	addi	sp,sp,176
    4dfe:	8082                	ret

0000000000004e00 <concreate>:
{
    4e00:	7135                	addi	sp,sp,-160
    4e02:	ed06                	sd	ra,152(sp)
    4e04:	e922                	sd	s0,144(sp)
    4e06:	e526                	sd	s1,136(sp)
    4e08:	e14a                	sd	s2,128(sp)
    4e0a:	fcce                	sd	s3,120(sp)
    4e0c:	f8d2                	sd	s4,112(sp)
    4e0e:	f4d6                	sd	s5,104(sp)
    4e10:	f0da                	sd	s6,96(sp)
    4e12:	ecde                	sd	s7,88(sp)
    4e14:	1100                	addi	s0,sp,160
    4e16:	89aa                	mv	s3,a0
  file[0] = 'C';
    4e18:	04300793          	li	a5,67
    4e1c:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4e20:	fa040523          	sb	zero,-86(s0)
  for (i = 0; i < N; i++)
    4e24:	4901                	li	s2,0
    if (pid && (i % 3) == 1)
    4e26:	4b0d                	li	s6,3
    4e28:	4a85                	li	s5,1
      link("C0", file);
    4e2a:	00003b97          	auipc	s7,0x3
    4e2e:	00eb8b93          	addi	s7,s7,14 # 7e38 <malloc+0x1e82>
  for (i = 0; i < N; i++)
    4e32:	02800a13          	li	s4,40
    4e36:	acc9                	j	5108 <concreate+0x308>
      link("C0", file);
    4e38:	fa840593          	addi	a1,s0,-88
    4e3c:	855e                	mv	a0,s7
    4e3e:	00001097          	auipc	ra,0x1
    4e42:	d86080e7          	jalr	-634(ra) # 5bc4 <link>
    if (pid == 0)
    4e46:	a465                	j	50ee <concreate+0x2ee>
    else if (pid == 0 && (i % 5) == 1)
    4e48:	4795                	li	a5,5
    4e4a:	02f9693b          	remw	s2,s2,a5
    4e4e:	4785                	li	a5,1
    4e50:	02f90b63          	beq	s2,a5,4e86 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4e54:	20200593          	li	a1,514
    4e58:	fa840513          	addi	a0,s0,-88
    4e5c:	00001097          	auipc	ra,0x1
    4e60:	d48080e7          	jalr	-696(ra) # 5ba4 <open>
      if (fd < 0)
    4e64:	26055c63          	bgez	a0,50dc <concreate+0x2dc>
        printf("concreate create %s failed\n", file);
    4e68:	fa840593          	addi	a1,s0,-88
    4e6c:	00003517          	auipc	a0,0x3
    4e70:	fd450513          	addi	a0,a0,-44 # 7e40 <malloc+0x1e8a>
    4e74:	00001097          	auipc	ra,0x1
    4e78:	08a080e7          	jalr	138(ra) # 5efe <printf>
        exit(1);
    4e7c:	4505                	li	a0,1
    4e7e:	00001097          	auipc	ra,0x1
    4e82:	ce6080e7          	jalr	-794(ra) # 5b64 <exit>
      link("C0", file);
    4e86:	fa840593          	addi	a1,s0,-88
    4e8a:	00003517          	auipc	a0,0x3
    4e8e:	fae50513          	addi	a0,a0,-82 # 7e38 <malloc+0x1e82>
    4e92:	00001097          	auipc	ra,0x1
    4e96:	d32080e7          	jalr	-718(ra) # 5bc4 <link>
      exit(0);
    4e9a:	4501                	li	a0,0
    4e9c:	00001097          	auipc	ra,0x1
    4ea0:	cc8080e7          	jalr	-824(ra) # 5b64 <exit>
        exit(1);
    4ea4:	4505                	li	a0,1
    4ea6:	00001097          	auipc	ra,0x1
    4eaa:	cbe080e7          	jalr	-834(ra) # 5b64 <exit>
  memset(fa, 0, sizeof(fa));
    4eae:	02800613          	li	a2,40
    4eb2:	4581                	li	a1,0
    4eb4:	f8040513          	addi	a0,s0,-128
    4eb8:	00001097          	auipc	ra,0x1
    4ebc:	ab2080e7          	jalr	-1358(ra) # 596a <memset>
  fd = open(".", 0);
    4ec0:	4581                	li	a1,0
    4ec2:	00002517          	auipc	a0,0x2
    4ec6:	8fe50513          	addi	a0,a0,-1794 # 67c0 <malloc+0x80a>
    4eca:	00001097          	auipc	ra,0x1
    4ece:	cda080e7          	jalr	-806(ra) # 5ba4 <open>
    4ed2:	892a                	mv	s2,a0
  n = 0;
    4ed4:	8aa6                	mv	s5,s1
    if (de.name[0] == 'C' && de.name[2] == '\0')
    4ed6:	04300a13          	li	s4,67
      if (i < 0 || i >= sizeof(fa))
    4eda:	02700b13          	li	s6,39
      fa[i] = 1;
    4ede:	4b85                	li	s7,1
  while (read(fd, &de, sizeof(de)) > 0)
    4ee0:	4641                	li	a2,16
    4ee2:	f7040593          	addi	a1,s0,-144
    4ee6:	854a                	mv	a0,s2
    4ee8:	00001097          	auipc	ra,0x1
    4eec:	c94080e7          	jalr	-876(ra) # 5b7c <read>
    4ef0:	08a05263          	blez	a0,4f74 <concreate+0x174>
    if (de.inum == 0)
    4ef4:	f7045783          	lhu	a5,-144(s0)
    4ef8:	d7e5                	beqz	a5,4ee0 <concreate+0xe0>
    if (de.name[0] == 'C' && de.name[2] == '\0')
    4efa:	f7244783          	lbu	a5,-142(s0)
    4efe:	ff4791e3          	bne	a5,s4,4ee0 <concreate+0xe0>
    4f02:	f7444783          	lbu	a5,-140(s0)
    4f06:	ffe9                	bnez	a5,4ee0 <concreate+0xe0>
      i = de.name[1] - '0';
    4f08:	f7344783          	lbu	a5,-141(s0)
    4f0c:	fd07879b          	addiw	a5,a5,-48
    4f10:	0007871b          	sext.w	a4,a5
      if (i < 0 || i >= sizeof(fa))
    4f14:	02eb6063          	bltu	s6,a4,4f34 <concreate+0x134>
      if (fa[i])
    4f18:	fb070793          	addi	a5,a4,-80 # fb0 <linktest+0xaa>
    4f1c:	97a2                	add	a5,a5,s0
    4f1e:	fd07c783          	lbu	a5,-48(a5)
    4f22:	eb8d                	bnez	a5,4f54 <concreate+0x154>
      fa[i] = 1;
    4f24:	fb070793          	addi	a5,a4,-80
    4f28:	00878733          	add	a4,a5,s0
    4f2c:	fd770823          	sb	s7,-48(a4)
      n++;
    4f30:	2a85                	addiw	s5,s5,1
    4f32:	b77d                	j	4ee0 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4f34:	f7240613          	addi	a2,s0,-142
    4f38:	85ce                	mv	a1,s3
    4f3a:	00003517          	auipc	a0,0x3
    4f3e:	f2650513          	addi	a0,a0,-218 # 7e60 <malloc+0x1eaa>
    4f42:	00001097          	auipc	ra,0x1
    4f46:	fbc080e7          	jalr	-68(ra) # 5efe <printf>
        exit(1);
    4f4a:	4505                	li	a0,1
    4f4c:	00001097          	auipc	ra,0x1
    4f50:	c18080e7          	jalr	-1000(ra) # 5b64 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4f54:	f7240613          	addi	a2,s0,-142
    4f58:	85ce                	mv	a1,s3
    4f5a:	00003517          	auipc	a0,0x3
    4f5e:	f2650513          	addi	a0,a0,-218 # 7e80 <malloc+0x1eca>
    4f62:	00001097          	auipc	ra,0x1
    4f66:	f9c080e7          	jalr	-100(ra) # 5efe <printf>
        exit(1);
    4f6a:	4505                	li	a0,1
    4f6c:	00001097          	auipc	ra,0x1
    4f70:	bf8080e7          	jalr	-1032(ra) # 5b64 <exit>
  close(fd);
    4f74:	854a                	mv	a0,s2
    4f76:	00001097          	auipc	ra,0x1
    4f7a:	c16080e7          	jalr	-1002(ra) # 5b8c <close>
  if (n != N)
    4f7e:	02800793          	li	a5,40
    4f82:	00fa9763          	bne	s5,a5,4f90 <concreate+0x190>
    if (((i % 3) == 0 && pid == 0) ||
    4f86:	4a8d                	li	s5,3
    4f88:	4b05                	li	s6,1
  for (i = 0; i < N; i++)
    4f8a:	02800a13          	li	s4,40
    4f8e:	a8c9                	j	5060 <concreate+0x260>
    printf("%s: concreate not enough files in directory listing\n", s);
    4f90:	85ce                	mv	a1,s3
    4f92:	00003517          	auipc	a0,0x3
    4f96:	f1650513          	addi	a0,a0,-234 # 7ea8 <malloc+0x1ef2>
    4f9a:	00001097          	auipc	ra,0x1
    4f9e:	f64080e7          	jalr	-156(ra) # 5efe <printf>
    exit(1);
    4fa2:	4505                	li	a0,1
    4fa4:	00001097          	auipc	ra,0x1
    4fa8:	bc0080e7          	jalr	-1088(ra) # 5b64 <exit>
      printf("%s: fork failed\n", s);
    4fac:	85ce                	mv	a1,s3
    4fae:	00002517          	auipc	a0,0x2
    4fb2:	9b250513          	addi	a0,a0,-1614 # 6960 <malloc+0x9aa>
    4fb6:	00001097          	auipc	ra,0x1
    4fba:	f48080e7          	jalr	-184(ra) # 5efe <printf>
      exit(1);
    4fbe:	4505                	li	a0,1
    4fc0:	00001097          	auipc	ra,0x1
    4fc4:	ba4080e7          	jalr	-1116(ra) # 5b64 <exit>
      close(open(file, 0));
    4fc8:	4581                	li	a1,0
    4fca:	fa840513          	addi	a0,s0,-88
    4fce:	00001097          	auipc	ra,0x1
    4fd2:	bd6080e7          	jalr	-1066(ra) # 5ba4 <open>
    4fd6:	00001097          	auipc	ra,0x1
    4fda:	bb6080e7          	jalr	-1098(ra) # 5b8c <close>
      close(open(file, 0));
    4fde:	4581                	li	a1,0
    4fe0:	fa840513          	addi	a0,s0,-88
    4fe4:	00001097          	auipc	ra,0x1
    4fe8:	bc0080e7          	jalr	-1088(ra) # 5ba4 <open>
    4fec:	00001097          	auipc	ra,0x1
    4ff0:	ba0080e7          	jalr	-1120(ra) # 5b8c <close>
      close(open(file, 0));
    4ff4:	4581                	li	a1,0
    4ff6:	fa840513          	addi	a0,s0,-88
    4ffa:	00001097          	auipc	ra,0x1
    4ffe:	baa080e7          	jalr	-1110(ra) # 5ba4 <open>
    5002:	00001097          	auipc	ra,0x1
    5006:	b8a080e7          	jalr	-1142(ra) # 5b8c <close>
      close(open(file, 0));
    500a:	4581                	li	a1,0
    500c:	fa840513          	addi	a0,s0,-88
    5010:	00001097          	auipc	ra,0x1
    5014:	b94080e7          	jalr	-1132(ra) # 5ba4 <open>
    5018:	00001097          	auipc	ra,0x1
    501c:	b74080e7          	jalr	-1164(ra) # 5b8c <close>
      close(open(file, 0));
    5020:	4581                	li	a1,0
    5022:	fa840513          	addi	a0,s0,-88
    5026:	00001097          	auipc	ra,0x1
    502a:	b7e080e7          	jalr	-1154(ra) # 5ba4 <open>
    502e:	00001097          	auipc	ra,0x1
    5032:	b5e080e7          	jalr	-1186(ra) # 5b8c <close>
      close(open(file, 0));
    5036:	4581                	li	a1,0
    5038:	fa840513          	addi	a0,s0,-88
    503c:	00001097          	auipc	ra,0x1
    5040:	b68080e7          	jalr	-1176(ra) # 5ba4 <open>
    5044:	00001097          	auipc	ra,0x1
    5048:	b48080e7          	jalr	-1208(ra) # 5b8c <close>
    if (pid == 0)
    504c:	08090363          	beqz	s2,50d2 <concreate+0x2d2>
      wait(0);
    5050:	4501                	li	a0,0
    5052:	00001097          	auipc	ra,0x1
    5056:	b1a080e7          	jalr	-1254(ra) # 5b6c <wait>
  for (i = 0; i < N; i++)
    505a:	2485                	addiw	s1,s1,1
    505c:	0f448563          	beq	s1,s4,5146 <concreate+0x346>
    file[1] = '0' + i;
    5060:	0304879b          	addiw	a5,s1,48
    5064:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    5068:	00001097          	auipc	ra,0x1
    506c:	af4080e7          	jalr	-1292(ra) # 5b5c <fork>
    5070:	892a                	mv	s2,a0
    if (pid < 0)
    5072:	f2054de3          	bltz	a0,4fac <concreate+0x1ac>
    if (((i % 3) == 0 && pid == 0) ||
    5076:	0354e73b          	remw	a4,s1,s5
    507a:	00a767b3          	or	a5,a4,a0
    507e:	2781                	sext.w	a5,a5
    5080:	d7a1                	beqz	a5,4fc8 <concreate+0x1c8>
    5082:	01671363          	bne	a4,s6,5088 <concreate+0x288>
        ((i % 3) == 1 && pid != 0))
    5086:	f129                	bnez	a0,4fc8 <concreate+0x1c8>
      unlink(file);
    5088:	fa840513          	addi	a0,s0,-88
    508c:	00001097          	auipc	ra,0x1
    5090:	b28080e7          	jalr	-1240(ra) # 5bb4 <unlink>
      unlink(file);
    5094:	fa840513          	addi	a0,s0,-88
    5098:	00001097          	auipc	ra,0x1
    509c:	b1c080e7          	jalr	-1252(ra) # 5bb4 <unlink>
      unlink(file);
    50a0:	fa840513          	addi	a0,s0,-88
    50a4:	00001097          	auipc	ra,0x1
    50a8:	b10080e7          	jalr	-1264(ra) # 5bb4 <unlink>
      unlink(file);
    50ac:	fa840513          	addi	a0,s0,-88
    50b0:	00001097          	auipc	ra,0x1
    50b4:	b04080e7          	jalr	-1276(ra) # 5bb4 <unlink>
      unlink(file);
    50b8:	fa840513          	addi	a0,s0,-88
    50bc:	00001097          	auipc	ra,0x1
    50c0:	af8080e7          	jalr	-1288(ra) # 5bb4 <unlink>
      unlink(file);
    50c4:	fa840513          	addi	a0,s0,-88
    50c8:	00001097          	auipc	ra,0x1
    50cc:	aec080e7          	jalr	-1300(ra) # 5bb4 <unlink>
    50d0:	bfb5                	j	504c <concreate+0x24c>
      exit(0);
    50d2:	4501                	li	a0,0
    50d4:	00001097          	auipc	ra,0x1
    50d8:	a90080e7          	jalr	-1392(ra) # 5b64 <exit>
      close(fd);
    50dc:	00001097          	auipc	ra,0x1
    50e0:	ab0080e7          	jalr	-1360(ra) # 5b8c <close>
    if (pid == 0)
    50e4:	bb5d                	j	4e9a <concreate+0x9a>
      close(fd);
    50e6:	00001097          	auipc	ra,0x1
    50ea:	aa6080e7          	jalr	-1370(ra) # 5b8c <close>
      wait(&xstatus);
    50ee:	f6c40513          	addi	a0,s0,-148
    50f2:	00001097          	auipc	ra,0x1
    50f6:	a7a080e7          	jalr	-1414(ra) # 5b6c <wait>
      if (xstatus != 0)
    50fa:	f6c42483          	lw	s1,-148(s0)
    50fe:	da0493e3          	bnez	s1,4ea4 <concreate+0xa4>
  for (i = 0; i < N; i++)
    5102:	2905                	addiw	s2,s2,1
    5104:	db4905e3          	beq	s2,s4,4eae <concreate+0xae>
    file[1] = '0' + i;
    5108:	0309079b          	addiw	a5,s2,48
    510c:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    5110:	fa840513          	addi	a0,s0,-88
    5114:	00001097          	auipc	ra,0x1
    5118:	aa0080e7          	jalr	-1376(ra) # 5bb4 <unlink>
    pid = fork();
    511c:	00001097          	auipc	ra,0x1
    5120:	a40080e7          	jalr	-1472(ra) # 5b5c <fork>
    if (pid && (i % 3) == 1)
    5124:	d20502e3          	beqz	a0,4e48 <concreate+0x48>
    5128:	036967bb          	remw	a5,s2,s6
    512c:	d15786e3          	beq	a5,s5,4e38 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    5130:	20200593          	li	a1,514
    5134:	fa840513          	addi	a0,s0,-88
    5138:	00001097          	auipc	ra,0x1
    513c:	a6c080e7          	jalr	-1428(ra) # 5ba4 <open>
      if (fd < 0)
    5140:	fa0553e3          	bgez	a0,50e6 <concreate+0x2e6>
    5144:	b315                	j	4e68 <concreate+0x68>
}
    5146:	60ea                	ld	ra,152(sp)
    5148:	644a                	ld	s0,144(sp)
    514a:	64aa                	ld	s1,136(sp)
    514c:	690a                	ld	s2,128(sp)
    514e:	79e6                	ld	s3,120(sp)
    5150:	7a46                	ld	s4,112(sp)
    5152:	7aa6                	ld	s5,104(sp)
    5154:	7b06                	ld	s6,96(sp)
    5156:	6be6                	ld	s7,88(sp)
    5158:	610d                	addi	sp,sp,160
    515a:	8082                	ret

000000000000515c <bigfile>:
{
    515c:	7139                	addi	sp,sp,-64
    515e:	fc06                	sd	ra,56(sp)
    5160:	f822                	sd	s0,48(sp)
    5162:	f426                	sd	s1,40(sp)
    5164:	f04a                	sd	s2,32(sp)
    5166:	ec4e                	sd	s3,24(sp)
    5168:	e852                	sd	s4,16(sp)
    516a:	e456                	sd	s5,8(sp)
    516c:	0080                	addi	s0,sp,64
    516e:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    5170:	00003517          	auipc	a0,0x3
    5174:	d7050513          	addi	a0,a0,-656 # 7ee0 <malloc+0x1f2a>
    5178:	00001097          	auipc	ra,0x1
    517c:	a3c080e7          	jalr	-1476(ra) # 5bb4 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    5180:	20200593          	li	a1,514
    5184:	00003517          	auipc	a0,0x3
    5188:	d5c50513          	addi	a0,a0,-676 # 7ee0 <malloc+0x1f2a>
    518c:	00001097          	auipc	ra,0x1
    5190:	a18080e7          	jalr	-1512(ra) # 5ba4 <open>
    5194:	89aa                	mv	s3,a0
  for (i = 0; i < N; i++)
    5196:	4481                	li	s1,0
    memset(buf, i, SZ);
    5198:	00008917          	auipc	s2,0x8
    519c:	ae090913          	addi	s2,s2,-1312 # cc78 <buf>
  for (i = 0; i < N; i++)
    51a0:	4a51                	li	s4,20
  if (fd < 0)
    51a2:	0a054063          	bltz	a0,5242 <bigfile+0xe6>
    memset(buf, i, SZ);
    51a6:	25800613          	li	a2,600
    51aa:	85a6                	mv	a1,s1
    51ac:	854a                	mv	a0,s2
    51ae:	00000097          	auipc	ra,0x0
    51b2:	7bc080e7          	jalr	1980(ra) # 596a <memset>
    if (write(fd, buf, SZ) != SZ)
    51b6:	25800613          	li	a2,600
    51ba:	85ca                	mv	a1,s2
    51bc:	854e                	mv	a0,s3
    51be:	00001097          	auipc	ra,0x1
    51c2:	9c6080e7          	jalr	-1594(ra) # 5b84 <write>
    51c6:	25800793          	li	a5,600
    51ca:	08f51a63          	bne	a0,a5,525e <bigfile+0x102>
  for (i = 0; i < N; i++)
    51ce:	2485                	addiw	s1,s1,1
    51d0:	fd449be3          	bne	s1,s4,51a6 <bigfile+0x4a>
  close(fd);
    51d4:	854e                	mv	a0,s3
    51d6:	00001097          	auipc	ra,0x1
    51da:	9b6080e7          	jalr	-1610(ra) # 5b8c <close>
  fd = open("bigfile.dat", 0);
    51de:	4581                	li	a1,0
    51e0:	00003517          	auipc	a0,0x3
    51e4:	d0050513          	addi	a0,a0,-768 # 7ee0 <malloc+0x1f2a>
    51e8:	00001097          	auipc	ra,0x1
    51ec:	9bc080e7          	jalr	-1604(ra) # 5ba4 <open>
    51f0:	8a2a                	mv	s4,a0
  total = 0;
    51f2:	4981                	li	s3,0
  for (i = 0;; i++)
    51f4:	4481                	li	s1,0
    cc = read(fd, buf, SZ / 2);
    51f6:	00008917          	auipc	s2,0x8
    51fa:	a8290913          	addi	s2,s2,-1406 # cc78 <buf>
  if (fd < 0)
    51fe:	06054e63          	bltz	a0,527a <bigfile+0x11e>
    cc = read(fd, buf, SZ / 2);
    5202:	12c00613          	li	a2,300
    5206:	85ca                	mv	a1,s2
    5208:	8552                	mv	a0,s4
    520a:	00001097          	auipc	ra,0x1
    520e:	972080e7          	jalr	-1678(ra) # 5b7c <read>
    if (cc < 0)
    5212:	08054263          	bltz	a0,5296 <bigfile+0x13a>
    if (cc == 0)
    5216:	c971                	beqz	a0,52ea <bigfile+0x18e>
    if (cc != SZ / 2)
    5218:	12c00793          	li	a5,300
    521c:	08f51b63          	bne	a0,a5,52b2 <bigfile+0x156>
    if (buf[0] != i / 2 || buf[SZ / 2 - 1] != i / 2)
    5220:	01f4d79b          	srliw	a5,s1,0x1f
    5224:	9fa5                	addw	a5,a5,s1
    5226:	4017d79b          	sraiw	a5,a5,0x1
    522a:	00094703          	lbu	a4,0(s2)
    522e:	0af71063          	bne	a4,a5,52ce <bigfile+0x172>
    5232:	12b94703          	lbu	a4,299(s2)
    5236:	08f71c63          	bne	a4,a5,52ce <bigfile+0x172>
    total += cc;
    523a:	12c9899b          	addiw	s3,s3,300
  for (i = 0;; i++)
    523e:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ / 2);
    5240:	b7c9                	j	5202 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    5242:	85d6                	mv	a1,s5
    5244:	00003517          	auipc	a0,0x3
    5248:	cac50513          	addi	a0,a0,-852 # 7ef0 <malloc+0x1f3a>
    524c:	00001097          	auipc	ra,0x1
    5250:	cb2080e7          	jalr	-846(ra) # 5efe <printf>
    exit(1);
    5254:	4505                	li	a0,1
    5256:	00001097          	auipc	ra,0x1
    525a:	90e080e7          	jalr	-1778(ra) # 5b64 <exit>
      printf("%s: write bigfile failed\n", s);
    525e:	85d6                	mv	a1,s5
    5260:	00003517          	auipc	a0,0x3
    5264:	cb050513          	addi	a0,a0,-848 # 7f10 <malloc+0x1f5a>
    5268:	00001097          	auipc	ra,0x1
    526c:	c96080e7          	jalr	-874(ra) # 5efe <printf>
      exit(1);
    5270:	4505                	li	a0,1
    5272:	00001097          	auipc	ra,0x1
    5276:	8f2080e7          	jalr	-1806(ra) # 5b64 <exit>
    printf("%s: cannot open bigfile\n", s);
    527a:	85d6                	mv	a1,s5
    527c:	00003517          	auipc	a0,0x3
    5280:	cb450513          	addi	a0,a0,-844 # 7f30 <malloc+0x1f7a>
    5284:	00001097          	auipc	ra,0x1
    5288:	c7a080e7          	jalr	-902(ra) # 5efe <printf>
    exit(1);
    528c:	4505                	li	a0,1
    528e:	00001097          	auipc	ra,0x1
    5292:	8d6080e7          	jalr	-1834(ra) # 5b64 <exit>
      printf("%s: read bigfile failed\n", s);
    5296:	85d6                	mv	a1,s5
    5298:	00003517          	auipc	a0,0x3
    529c:	cb850513          	addi	a0,a0,-840 # 7f50 <malloc+0x1f9a>
    52a0:	00001097          	auipc	ra,0x1
    52a4:	c5e080e7          	jalr	-930(ra) # 5efe <printf>
      exit(1);
    52a8:	4505                	li	a0,1
    52aa:	00001097          	auipc	ra,0x1
    52ae:	8ba080e7          	jalr	-1862(ra) # 5b64 <exit>
      printf("%s: short read bigfile\n", s);
    52b2:	85d6                	mv	a1,s5
    52b4:	00003517          	auipc	a0,0x3
    52b8:	cbc50513          	addi	a0,a0,-836 # 7f70 <malloc+0x1fba>
    52bc:	00001097          	auipc	ra,0x1
    52c0:	c42080e7          	jalr	-958(ra) # 5efe <printf>
      exit(1);
    52c4:	4505                	li	a0,1
    52c6:	00001097          	auipc	ra,0x1
    52ca:	89e080e7          	jalr	-1890(ra) # 5b64 <exit>
      printf("%s: read bigfile wrong data\n", s);
    52ce:	85d6                	mv	a1,s5
    52d0:	00003517          	auipc	a0,0x3
    52d4:	cb850513          	addi	a0,a0,-840 # 7f88 <malloc+0x1fd2>
    52d8:	00001097          	auipc	ra,0x1
    52dc:	c26080e7          	jalr	-986(ra) # 5efe <printf>
      exit(1);
    52e0:	4505                	li	a0,1
    52e2:	00001097          	auipc	ra,0x1
    52e6:	882080e7          	jalr	-1918(ra) # 5b64 <exit>
  close(fd);
    52ea:	8552                	mv	a0,s4
    52ec:	00001097          	auipc	ra,0x1
    52f0:	8a0080e7          	jalr	-1888(ra) # 5b8c <close>
  if (total != N * SZ)
    52f4:	678d                	lui	a5,0x3
    52f6:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrk8000+0x18>
    52fa:	02f99363          	bne	s3,a5,5320 <bigfile+0x1c4>
  unlink("bigfile.dat");
    52fe:	00003517          	auipc	a0,0x3
    5302:	be250513          	addi	a0,a0,-1054 # 7ee0 <malloc+0x1f2a>
    5306:	00001097          	auipc	ra,0x1
    530a:	8ae080e7          	jalr	-1874(ra) # 5bb4 <unlink>
}
    530e:	70e2                	ld	ra,56(sp)
    5310:	7442                	ld	s0,48(sp)
    5312:	74a2                	ld	s1,40(sp)
    5314:	7902                	ld	s2,32(sp)
    5316:	69e2                	ld	s3,24(sp)
    5318:	6a42                	ld	s4,16(sp)
    531a:	6aa2                	ld	s5,8(sp)
    531c:	6121                	addi	sp,sp,64
    531e:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    5320:	85d6                	mv	a1,s5
    5322:	00003517          	auipc	a0,0x3
    5326:	c8650513          	addi	a0,a0,-890 # 7fa8 <malloc+0x1ff2>
    532a:	00001097          	auipc	ra,0x1
    532e:	bd4080e7          	jalr	-1068(ra) # 5efe <printf>
    exit(1);
    5332:	4505                	li	a0,1
    5334:	00001097          	auipc	ra,0x1
    5338:	830080e7          	jalr	-2000(ra) # 5b64 <exit>

000000000000533c <fsfull>:
{
    533c:	7171                	addi	sp,sp,-176
    533e:	f506                	sd	ra,168(sp)
    5340:	f122                	sd	s0,160(sp)
    5342:	ed26                	sd	s1,152(sp)
    5344:	e94a                	sd	s2,144(sp)
    5346:	e54e                	sd	s3,136(sp)
    5348:	e152                	sd	s4,128(sp)
    534a:	fcd6                	sd	s5,120(sp)
    534c:	f8da                	sd	s6,112(sp)
    534e:	f4de                	sd	s7,104(sp)
    5350:	f0e2                	sd	s8,96(sp)
    5352:	ece6                	sd	s9,88(sp)
    5354:	e8ea                	sd	s10,80(sp)
    5356:	e4ee                	sd	s11,72(sp)
    5358:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    535a:	00003517          	auipc	a0,0x3
    535e:	c6e50513          	addi	a0,a0,-914 # 7fc8 <malloc+0x2012>
    5362:	00001097          	auipc	ra,0x1
    5366:	b9c080e7          	jalr	-1124(ra) # 5efe <printf>
  for (nfiles = 0;; nfiles++)
    536a:	4481                	li	s1,0
    name[0] = 'f';
    536c:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    5370:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    5374:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    5378:	4b29                	li	s6,10
    printf("writing %s\n", name);
    537a:	00003c97          	auipc	s9,0x3
    537e:	c5ec8c93          	addi	s9,s9,-930 # 7fd8 <malloc+0x2022>
    int total = 0;
    5382:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    5384:	00008a17          	auipc	s4,0x8
    5388:	8f4a0a13          	addi	s4,s4,-1804 # cc78 <buf>
    name[0] = 'f';
    538c:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    5390:	0384c7bb          	divw	a5,s1,s8
    5394:	0307879b          	addiw	a5,a5,48
    5398:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    539c:	0384e7bb          	remw	a5,s1,s8
    53a0:	0377c7bb          	divw	a5,a5,s7
    53a4:	0307879b          	addiw	a5,a5,48
    53a8:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    53ac:	0374e7bb          	remw	a5,s1,s7
    53b0:	0367c7bb          	divw	a5,a5,s6
    53b4:	0307879b          	addiw	a5,a5,48
    53b8:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    53bc:	0364e7bb          	remw	a5,s1,s6
    53c0:	0307879b          	addiw	a5,a5,48
    53c4:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    53c8:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    53cc:	f5040593          	addi	a1,s0,-176
    53d0:	8566                	mv	a0,s9
    53d2:	00001097          	auipc	ra,0x1
    53d6:	b2c080e7          	jalr	-1236(ra) # 5efe <printf>
    int fd = open(name, O_CREATE | O_RDWR);
    53da:	20200593          	li	a1,514
    53de:	f5040513          	addi	a0,s0,-176
    53e2:	00000097          	auipc	ra,0x0
    53e6:	7c2080e7          	jalr	1986(ra) # 5ba4 <open>
    53ea:	892a                	mv	s2,a0
    if (fd < 0)
    53ec:	0a055663          	bgez	a0,5498 <fsfull+0x15c>
      printf("open %s failed\n", name);
    53f0:	f5040593          	addi	a1,s0,-176
    53f4:	00003517          	auipc	a0,0x3
    53f8:	bf450513          	addi	a0,a0,-1036 # 7fe8 <malloc+0x2032>
    53fc:	00001097          	auipc	ra,0x1
    5400:	b02080e7          	jalr	-1278(ra) # 5efe <printf>
  while (nfiles >= 0)
    5404:	0604c363          	bltz	s1,546a <fsfull+0x12e>
    name[0] = 'f';
    5408:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    540c:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    5410:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    5414:	4929                	li	s2,10
  while (nfiles >= 0)
    5416:	5afd                	li	s5,-1
    name[0] = 'f';
    5418:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    541c:	0344c7bb          	divw	a5,s1,s4
    5420:	0307879b          	addiw	a5,a5,48
    5424:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5428:	0344e7bb          	remw	a5,s1,s4
    542c:	0337c7bb          	divw	a5,a5,s3
    5430:	0307879b          	addiw	a5,a5,48
    5434:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5438:	0334e7bb          	remw	a5,s1,s3
    543c:	0327c7bb          	divw	a5,a5,s2
    5440:	0307879b          	addiw	a5,a5,48
    5444:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    5448:	0324e7bb          	remw	a5,s1,s2
    544c:	0307879b          	addiw	a5,a5,48
    5450:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    5454:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    5458:	f5040513          	addi	a0,s0,-176
    545c:	00000097          	auipc	ra,0x0
    5460:	758080e7          	jalr	1880(ra) # 5bb4 <unlink>
    nfiles--;
    5464:	34fd                	addiw	s1,s1,-1
  while (nfiles >= 0)
    5466:	fb5499e3          	bne	s1,s5,5418 <fsfull+0xdc>
  printf("fsfull test finished\n");
    546a:	00003517          	auipc	a0,0x3
    546e:	b9e50513          	addi	a0,a0,-1122 # 8008 <malloc+0x2052>
    5472:	00001097          	auipc	ra,0x1
    5476:	a8c080e7          	jalr	-1396(ra) # 5efe <printf>
}
    547a:	70aa                	ld	ra,168(sp)
    547c:	740a                	ld	s0,160(sp)
    547e:	64ea                	ld	s1,152(sp)
    5480:	694a                	ld	s2,144(sp)
    5482:	69aa                	ld	s3,136(sp)
    5484:	6a0a                	ld	s4,128(sp)
    5486:	7ae6                	ld	s5,120(sp)
    5488:	7b46                	ld	s6,112(sp)
    548a:	7ba6                	ld	s7,104(sp)
    548c:	7c06                	ld	s8,96(sp)
    548e:	6ce6                	ld	s9,88(sp)
    5490:	6d46                	ld	s10,80(sp)
    5492:	6da6                	ld	s11,72(sp)
    5494:	614d                	addi	sp,sp,176
    5496:	8082                	ret
    int total = 0;
    5498:	89ee                	mv	s3,s11
      if (cc < BSIZE)
    549a:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    549e:	40000613          	li	a2,1024
    54a2:	85d2                	mv	a1,s4
    54a4:	854a                	mv	a0,s2
    54a6:	00000097          	auipc	ra,0x0
    54aa:	6de080e7          	jalr	1758(ra) # 5b84 <write>
      if (cc < BSIZE)
    54ae:	00aad563          	bge	s5,a0,54b8 <fsfull+0x17c>
      total += cc;
    54b2:	00a989bb          	addw	s3,s3,a0
    {
    54b6:	b7e5                	j	549e <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    54b8:	85ce                	mv	a1,s3
    54ba:	00003517          	auipc	a0,0x3
    54be:	b3e50513          	addi	a0,a0,-1218 # 7ff8 <malloc+0x2042>
    54c2:	00001097          	auipc	ra,0x1
    54c6:	a3c080e7          	jalr	-1476(ra) # 5efe <printf>
    close(fd);
    54ca:	854a                	mv	a0,s2
    54cc:	00000097          	auipc	ra,0x0
    54d0:	6c0080e7          	jalr	1728(ra) # 5b8c <close>
    if (total == 0)
    54d4:	f20988e3          	beqz	s3,5404 <fsfull+0xc8>
  for (nfiles = 0;; nfiles++)
    54d8:	2485                	addiw	s1,s1,1
  {
    54da:	bd4d                	j	538c <fsfull+0x50>

00000000000054dc <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int run(void f(char *), char *s)
{
    54dc:	7179                	addi	sp,sp,-48
    54de:	f406                	sd	ra,40(sp)
    54e0:	f022                	sd	s0,32(sp)
    54e2:	ec26                	sd	s1,24(sp)
    54e4:	e84a                	sd	s2,16(sp)
    54e6:	1800                	addi	s0,sp,48
    54e8:	84aa                	mv	s1,a0
    54ea:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    54ec:	00003517          	auipc	a0,0x3
    54f0:	b3450513          	addi	a0,a0,-1228 # 8020 <malloc+0x206a>
    54f4:	00001097          	auipc	ra,0x1
    54f8:	a0a080e7          	jalr	-1526(ra) # 5efe <printf>
  if ((pid = fork()) < 0)
    54fc:	00000097          	auipc	ra,0x0
    5500:	660080e7          	jalr	1632(ra) # 5b5c <fork>
    5504:	02054e63          	bltz	a0,5540 <run+0x64>
  {
    printf("runtest: fork error\n");
    exit(1);
  }
  if (pid == 0)
    5508:	c929                	beqz	a0,555a <run+0x7e>
    f(s);
    exit(0);
  }
  else
  {
    wait(&xstatus);
    550a:	fdc40513          	addi	a0,s0,-36
    550e:	00000097          	auipc	ra,0x0
    5512:	65e080e7          	jalr	1630(ra) # 5b6c <wait>
    if (xstatus != 0)
    5516:	fdc42783          	lw	a5,-36(s0)
    551a:	c7b9                	beqz	a5,5568 <run+0x8c>
      printf("FAILED\n");
    551c:	00003517          	auipc	a0,0x3
    5520:	b2c50513          	addi	a0,a0,-1236 # 8048 <malloc+0x2092>
    5524:	00001097          	auipc	ra,0x1
    5528:	9da080e7          	jalr	-1574(ra) # 5efe <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    552c:	fdc42503          	lw	a0,-36(s0)
  }
}
    5530:	00153513          	seqz	a0,a0
    5534:	70a2                	ld	ra,40(sp)
    5536:	7402                	ld	s0,32(sp)
    5538:	64e2                	ld	s1,24(sp)
    553a:	6942                	ld	s2,16(sp)
    553c:	6145                	addi	sp,sp,48
    553e:	8082                	ret
    printf("runtest: fork error\n");
    5540:	00003517          	auipc	a0,0x3
    5544:	af050513          	addi	a0,a0,-1296 # 8030 <malloc+0x207a>
    5548:	00001097          	auipc	ra,0x1
    554c:	9b6080e7          	jalr	-1610(ra) # 5efe <printf>
    exit(1);
    5550:	4505                	li	a0,1
    5552:	00000097          	auipc	ra,0x0
    5556:	612080e7          	jalr	1554(ra) # 5b64 <exit>
    f(s);
    555a:	854a                	mv	a0,s2
    555c:	9482                	jalr	s1
    exit(0);
    555e:	4501                	li	a0,0
    5560:	00000097          	auipc	ra,0x0
    5564:	604080e7          	jalr	1540(ra) # 5b64 <exit>
      printf("OK\n");
    5568:	00003517          	auipc	a0,0x3
    556c:	ae850513          	addi	a0,a0,-1304 # 8050 <malloc+0x209a>
    5570:	00001097          	auipc	ra,0x1
    5574:	98e080e7          	jalr	-1650(ra) # 5efe <printf>
    5578:	bf55                	j	552c <run+0x50>

000000000000557a <runtests>:

int runtests(struct test *tests, char *justone)
{
    557a:	1101                	addi	sp,sp,-32
    557c:	ec06                	sd	ra,24(sp)
    557e:	e822                	sd	s0,16(sp)
    5580:	e426                	sd	s1,8(sp)
    5582:	e04a                	sd	s2,0(sp)
    5584:	1000                	addi	s0,sp,32
    5586:	84aa                	mv	s1,a0
    5588:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++)
    558a:	6508                	ld	a0,8(a0)
    558c:	ed09                	bnez	a0,55a6 <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    558e:	4501                	li	a0,0
    5590:	a82d                	j	55ca <runtests+0x50>
      if (!run(t->f, t->s))
    5592:	648c                	ld	a1,8(s1)
    5594:	6088                	ld	a0,0(s1)
    5596:	00000097          	auipc	ra,0x0
    559a:	f46080e7          	jalr	-186(ra) # 54dc <run>
    559e:	cd09                	beqz	a0,55b8 <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++)
    55a0:	04c1                	addi	s1,s1,16
    55a2:	6488                	ld	a0,8(s1)
    55a4:	c11d                	beqz	a0,55ca <runtests+0x50>
    if ((justone == 0) || strcmp(t->s, justone) == 0)
    55a6:	fe0906e3          	beqz	s2,5592 <runtests+0x18>
    55aa:	85ca                	mv	a1,s2
    55ac:	00000097          	auipc	ra,0x0
    55b0:	368080e7          	jalr	872(ra) # 5914 <strcmp>
    55b4:	f575                	bnez	a0,55a0 <runtests+0x26>
    55b6:	bff1                	j	5592 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    55b8:	00003517          	auipc	a0,0x3
    55bc:	aa050513          	addi	a0,a0,-1376 # 8058 <malloc+0x20a2>
    55c0:	00001097          	auipc	ra,0x1
    55c4:	93e080e7          	jalr	-1730(ra) # 5efe <printf>
        return 1;
    55c8:	4505                	li	a0,1
}
    55ca:	60e2                	ld	ra,24(sp)
    55cc:	6442                	ld	s0,16(sp)
    55ce:	64a2                	ld	s1,8(sp)
    55d0:	6902                	ld	s2,0(sp)
    55d2:	6105                	addi	sp,sp,32
    55d4:	8082                	ret

00000000000055d6 <countfree>:
// touches the pages to force allocation.
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int countfree()
{
    55d6:	7139                	addi	sp,sp,-64
    55d8:	fc06                	sd	ra,56(sp)
    55da:	f822                	sd	s0,48(sp)
    55dc:	f426                	sd	s1,40(sp)
    55de:	f04a                	sd	s2,32(sp)
    55e0:	ec4e                	sd	s3,24(sp)
    55e2:	0080                	addi	s0,sp,64
  int fds[2];

  if (pipe(fds) < 0)
    55e4:	fc840513          	addi	a0,s0,-56
    55e8:	00000097          	auipc	ra,0x0
    55ec:	58c080e7          	jalr	1420(ra) # 5b74 <pipe>
    55f0:	06054763          	bltz	a0,565e <countfree+0x88>
  {
    printf("pipe() failed in countfree()\n");
    exit(1);
  }

  int pid = fork();
    55f4:	00000097          	auipc	ra,0x0
    55f8:	568080e7          	jalr	1384(ra) # 5b5c <fork>

  if (pid < 0)
    55fc:	06054e63          	bltz	a0,5678 <countfree+0xa2>
  {
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if (pid == 0)
    5600:	ed51                	bnez	a0,569c <countfree+0xc6>
  {
    close(fds[0]);
    5602:	fc842503          	lw	a0,-56(s0)
    5606:	00000097          	auipc	ra,0x0
    560a:	586080e7          	jalr	1414(ra) # 5b8c <close>

    while (1)
    {
      uint64 a = (uint64)sbrk(4096);
      if (a == 0xffffffffffffffff)
    560e:	597d                	li	s2,-1
      {
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    5610:	4485                	li	s1,1

      // report back one more page.
      if (write(fds[1], "x", 1) != 1)
    5612:	00001997          	auipc	s3,0x1
    5616:	b3698993          	addi	s3,s3,-1226 # 6148 <malloc+0x192>
      uint64 a = (uint64)sbrk(4096);
    561a:	6505                	lui	a0,0x1
    561c:	00000097          	auipc	ra,0x0
    5620:	5d0080e7          	jalr	1488(ra) # 5bec <sbrk>
      if (a == 0xffffffffffffffff)
    5624:	07250763          	beq	a0,s2,5692 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    5628:	6785                	lui	a5,0x1
    562a:	97aa                	add	a5,a5,a0
    562c:	fe978fa3          	sb	s1,-1(a5) # fff <linktest+0xf9>
      if (write(fds[1], "x", 1) != 1)
    5630:	8626                	mv	a2,s1
    5632:	85ce                	mv	a1,s3
    5634:	fcc42503          	lw	a0,-52(s0)
    5638:	00000097          	auipc	ra,0x0
    563c:	54c080e7          	jalr	1356(ra) # 5b84 <write>
    5640:	fc950de3          	beq	a0,s1,561a <countfree+0x44>
      {
        printf("write() failed in countfree()\n");
    5644:	00003517          	auipc	a0,0x3
    5648:	a6c50513          	addi	a0,a0,-1428 # 80b0 <malloc+0x20fa>
    564c:	00001097          	auipc	ra,0x1
    5650:	8b2080e7          	jalr	-1870(ra) # 5efe <printf>
        exit(1);
    5654:	4505                	li	a0,1
    5656:	00000097          	auipc	ra,0x0
    565a:	50e080e7          	jalr	1294(ra) # 5b64 <exit>
    printf("pipe() failed in countfree()\n");
    565e:	00003517          	auipc	a0,0x3
    5662:	a1250513          	addi	a0,a0,-1518 # 8070 <malloc+0x20ba>
    5666:	00001097          	auipc	ra,0x1
    566a:	898080e7          	jalr	-1896(ra) # 5efe <printf>
    exit(1);
    566e:	4505                	li	a0,1
    5670:	00000097          	auipc	ra,0x0
    5674:	4f4080e7          	jalr	1268(ra) # 5b64 <exit>
    printf("fork failed in countfree()\n");
    5678:	00003517          	auipc	a0,0x3
    567c:	a1850513          	addi	a0,a0,-1512 # 8090 <malloc+0x20da>
    5680:	00001097          	auipc	ra,0x1
    5684:	87e080e7          	jalr	-1922(ra) # 5efe <printf>
    exit(1);
    5688:	4505                	li	a0,1
    568a:	00000097          	auipc	ra,0x0
    568e:	4da080e7          	jalr	1242(ra) # 5b64 <exit>
      }
    }

    exit(0);
    5692:	4501                	li	a0,0
    5694:	00000097          	auipc	ra,0x0
    5698:	4d0080e7          	jalr	1232(ra) # 5b64 <exit>
  }

  close(fds[1]);
    569c:	fcc42503          	lw	a0,-52(s0)
    56a0:	00000097          	auipc	ra,0x0
    56a4:	4ec080e7          	jalr	1260(ra) # 5b8c <close>

  int n = 0;
    56a8:	4481                	li	s1,0
  while (1)
  {
    char c;
    int cc = read(fds[0], &c, 1);
    56aa:	4605                	li	a2,1
    56ac:	fc740593          	addi	a1,s0,-57
    56b0:	fc842503          	lw	a0,-56(s0)
    56b4:	00000097          	auipc	ra,0x0
    56b8:	4c8080e7          	jalr	1224(ra) # 5b7c <read>
    if (cc < 0)
    56bc:	00054563          	bltz	a0,56c6 <countfree+0xf0>
    {
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if (cc == 0)
    56c0:	c105                	beqz	a0,56e0 <countfree+0x10a>
      break;
    n += 1;
    56c2:	2485                	addiw	s1,s1,1
  {
    56c4:	b7dd                	j	56aa <countfree+0xd4>
      printf("read() failed in countfree()\n");
    56c6:	00003517          	auipc	a0,0x3
    56ca:	a0a50513          	addi	a0,a0,-1526 # 80d0 <malloc+0x211a>
    56ce:	00001097          	auipc	ra,0x1
    56d2:	830080e7          	jalr	-2000(ra) # 5efe <printf>
      exit(1);
    56d6:	4505                	li	a0,1
    56d8:	00000097          	auipc	ra,0x0
    56dc:	48c080e7          	jalr	1164(ra) # 5b64 <exit>
  }

  close(fds[0]);
    56e0:	fc842503          	lw	a0,-56(s0)
    56e4:	00000097          	auipc	ra,0x0
    56e8:	4a8080e7          	jalr	1192(ra) # 5b8c <close>
  wait((int *)0);
    56ec:	4501                	li	a0,0
    56ee:	00000097          	auipc	ra,0x0
    56f2:	47e080e7          	jalr	1150(ra) # 5b6c <wait>

  return n;
}
    56f6:	8526                	mv	a0,s1
    56f8:	70e2                	ld	ra,56(sp)
    56fa:	7442                	ld	s0,48(sp)
    56fc:	74a2                	ld	s1,40(sp)
    56fe:	7902                	ld	s2,32(sp)
    5700:	69e2                	ld	s3,24(sp)
    5702:	6121                	addi	sp,sp,64
    5704:	8082                	ret

0000000000005706 <drivetests>:

int drivetests(int quick, int continuous, char *justone)
{
    5706:	711d                	addi	sp,sp,-96
    5708:	ec86                	sd	ra,88(sp)
    570a:	e8a2                	sd	s0,80(sp)
    570c:	e4a6                	sd	s1,72(sp)
    570e:	e0ca                	sd	s2,64(sp)
    5710:	fc4e                	sd	s3,56(sp)
    5712:	f852                	sd	s4,48(sp)
    5714:	f456                	sd	s5,40(sp)
    5716:	f05a                	sd	s6,32(sp)
    5718:	ec5e                	sd	s7,24(sp)
    571a:	e862                	sd	s8,16(sp)
    571c:	e466                	sd	s9,8(sp)
    571e:	e06a                	sd	s10,0(sp)
    5720:	1080                	addi	s0,sp,96
    5722:	8a2a                	mv	s4,a0
    5724:	89ae                	mv	s3,a1
    5726:	8932                	mv	s2,a2
  do
  {
    printf("usertests starting\n");
    5728:	00003b97          	auipc	s7,0x3
    572c:	9c8b8b93          	addi	s7,s7,-1592 # 80f0 <malloc+0x213a>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone))
    5730:	00004b17          	auipc	s6,0x4
    5734:	8e0b0b13          	addi	s6,s6,-1824 # 9010 <quicktests>
    {
      if (continuous != 2)
    5738:	4a89                	li	s5,2
        }
      }
    }
    if ((free1 = countfree()) < free0)
    {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    573a:	00003c97          	auipc	s9,0x3
    573e:	9eec8c93          	addi	s9,s9,-1554 # 8128 <malloc+0x2172>
      if (runtests(slowtests, justone))
    5742:	00004c17          	auipc	s8,0x4
    5746:	c9ec0c13          	addi	s8,s8,-866 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    574a:	00003d17          	auipc	s10,0x3
    574e:	9bed0d13          	addi	s10,s10,-1602 # 8108 <malloc+0x2152>
    5752:	a839                	j	5770 <drivetests+0x6a>
    5754:	856a                	mv	a0,s10
    5756:	00000097          	auipc	ra,0x0
    575a:	7a8080e7          	jalr	1960(ra) # 5efe <printf>
    575e:	a081                	j	579e <drivetests+0x98>
    if ((free1 = countfree()) < free0)
    5760:	00000097          	auipc	ra,0x0
    5764:	e76080e7          	jalr	-394(ra) # 55d6 <countfree>
    5768:	06954263          	blt	a0,s1,57cc <drivetests+0xc6>
      if (continuous != 2)
      {
        return 1;
      }
    }
  } while (continuous);
    576c:	06098f63          	beqz	s3,57ea <drivetests+0xe4>
    printf("usertests starting\n");
    5770:	855e                	mv	a0,s7
    5772:	00000097          	auipc	ra,0x0
    5776:	78c080e7          	jalr	1932(ra) # 5efe <printf>
    int free0 = countfree();
    577a:	00000097          	auipc	ra,0x0
    577e:	e5c080e7          	jalr	-420(ra) # 55d6 <countfree>
    5782:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone))
    5784:	85ca                	mv	a1,s2
    5786:	855a                	mv	a0,s6
    5788:	00000097          	auipc	ra,0x0
    578c:	df2080e7          	jalr	-526(ra) # 557a <runtests>
    5790:	c119                	beqz	a0,5796 <drivetests+0x90>
      if (continuous != 2)
    5792:	05599863          	bne	s3,s5,57e2 <drivetests+0xdc>
    if (!quick)
    5796:	fc0a15e3          	bnez	s4,5760 <drivetests+0x5a>
      if (justone == 0)
    579a:	fa090de3          	beqz	s2,5754 <drivetests+0x4e>
      if (runtests(slowtests, justone))
    579e:	85ca                	mv	a1,s2
    57a0:	8562                	mv	a0,s8
    57a2:	00000097          	auipc	ra,0x0
    57a6:	dd8080e7          	jalr	-552(ra) # 557a <runtests>
    57aa:	d95d                	beqz	a0,5760 <drivetests+0x5a>
        if (continuous != 2)
    57ac:	03599d63          	bne	s3,s5,57e6 <drivetests+0xe0>
    if ((free1 = countfree()) < free0)
    57b0:	00000097          	auipc	ra,0x0
    57b4:	e26080e7          	jalr	-474(ra) # 55d6 <countfree>
    57b8:	fa955ae3          	bge	a0,s1,576c <drivetests+0x66>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    57bc:	8626                	mv	a2,s1
    57be:	85aa                	mv	a1,a0
    57c0:	8566                	mv	a0,s9
    57c2:	00000097          	auipc	ra,0x0
    57c6:	73c080e7          	jalr	1852(ra) # 5efe <printf>
      if (continuous != 2)
    57ca:	b75d                	j	5770 <drivetests+0x6a>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    57cc:	8626                	mv	a2,s1
    57ce:	85aa                	mv	a1,a0
    57d0:	8566                	mv	a0,s9
    57d2:	00000097          	auipc	ra,0x0
    57d6:	72c080e7          	jalr	1836(ra) # 5efe <printf>
      if (continuous != 2)
    57da:	f9598be3          	beq	s3,s5,5770 <drivetests+0x6a>
        return 1;
    57de:	4505                	li	a0,1
    57e0:	a031                	j	57ec <drivetests+0xe6>
        return 1;
    57e2:	4505                	li	a0,1
    57e4:	a021                	j	57ec <drivetests+0xe6>
          return 1;
    57e6:	4505                	li	a0,1
    57e8:	a011                	j	57ec <drivetests+0xe6>
  return 0;
    57ea:	854e                	mv	a0,s3
}
    57ec:	60e6                	ld	ra,88(sp)
    57ee:	6446                	ld	s0,80(sp)
    57f0:	64a6                	ld	s1,72(sp)
    57f2:	6906                	ld	s2,64(sp)
    57f4:	79e2                	ld	s3,56(sp)
    57f6:	7a42                	ld	s4,48(sp)
    57f8:	7aa2                	ld	s5,40(sp)
    57fa:	7b02                	ld	s6,32(sp)
    57fc:	6be2                	ld	s7,24(sp)
    57fe:	6c42                	ld	s8,16(sp)
    5800:	6ca2                	ld	s9,8(sp)
    5802:	6d02                	ld	s10,0(sp)
    5804:	6125                	addi	sp,sp,96
    5806:	8082                	ret

0000000000005808 <main>:

int main(int argc, char *argv[])
{
    5808:	1101                	addi	sp,sp,-32
    580a:	ec06                	sd	ra,24(sp)
    580c:	e822                	sd	s0,16(sp)
    580e:	e426                	sd	s1,8(sp)
    5810:	e04a                	sd	s2,0(sp)
    5812:	1000                	addi	s0,sp,32
    5814:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if (argc == 2 && strcmp(argv[1], "-q") == 0)
    5816:	4789                	li	a5,2
    5818:	02f50263          	beq	a0,a5,583c <main+0x34>
  }
  else if (argc == 2 && argv[1][0] != '-')
  {
    justone = argv[1];
  }
  else if (argc > 1)
    581c:	4785                	li	a5,1
    581e:	06a7cd63          	blt	a5,a0,5898 <main+0x90>
  char *justone = 0;
    5822:	4601                	li	a2,0
  int quick = 0;
    5824:	4501                	li	a0,0
  int continuous = 0;
    5826:	4581                	li	a1,0
  {
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone))
    5828:	00000097          	auipc	ra,0x0
    582c:	ede080e7          	jalr	-290(ra) # 5706 <drivetests>
    5830:	c951                	beqz	a0,58c4 <main+0xbc>
  {
    exit(1);
    5832:	4505                	li	a0,1
    5834:	00000097          	auipc	ra,0x0
    5838:	330080e7          	jalr	816(ra) # 5b64 <exit>
    583c:	892e                	mv	s2,a1
  if (argc == 2 && strcmp(argv[1], "-q") == 0)
    583e:	00003597          	auipc	a1,0x3
    5842:	91a58593          	addi	a1,a1,-1766 # 8158 <malloc+0x21a2>
    5846:	00893503          	ld	a0,8(s2)
    584a:	00000097          	auipc	ra,0x0
    584e:	0ca080e7          	jalr	202(ra) # 5914 <strcmp>
    5852:	85aa                	mv	a1,a0
    5854:	cd39                	beqz	a0,58b2 <main+0xaa>
  else if (argc == 2 && strcmp(argv[1], "-c") == 0)
    5856:	00003597          	auipc	a1,0x3
    585a:	95a58593          	addi	a1,a1,-1702 # 81b0 <malloc+0x21fa>
    585e:	00893503          	ld	a0,8(s2)
    5862:	00000097          	auipc	ra,0x0
    5866:	0b2080e7          	jalr	178(ra) # 5914 <strcmp>
    586a:	c931                	beqz	a0,58be <main+0xb6>
  else if (argc == 2 && strcmp(argv[1], "-C") == 0)
    586c:	00003597          	auipc	a1,0x3
    5870:	93c58593          	addi	a1,a1,-1732 # 81a8 <malloc+0x21f2>
    5874:	00893503          	ld	a0,8(s2)
    5878:	00000097          	auipc	ra,0x0
    587c:	09c080e7          	jalr	156(ra) # 5914 <strcmp>
    5880:	cd05                	beqz	a0,58b8 <main+0xb0>
  else if (argc == 2 && argv[1][0] != '-')
    5882:	00893603          	ld	a2,8(s2)
    5886:	00064703          	lbu	a4,0(a2) # 3000 <fourteen+0x3e>
    588a:	02d00793          	li	a5,45
    588e:	00f70563          	beq	a4,a5,5898 <main+0x90>
  int quick = 0;
    5892:	4501                	li	a0,0
  int continuous = 0;
    5894:	4581                	li	a1,0
    5896:	bf49                	j	5828 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    5898:	00003517          	auipc	a0,0x3
    589c:	8c850513          	addi	a0,a0,-1848 # 8160 <malloc+0x21aa>
    58a0:	00000097          	auipc	ra,0x0
    58a4:	65e080e7          	jalr	1630(ra) # 5efe <printf>
    exit(1);
    58a8:	4505                	li	a0,1
    58aa:	00000097          	auipc	ra,0x0
    58ae:	2ba080e7          	jalr	698(ra) # 5b64 <exit>
  char *justone = 0;
    58b2:	4601                	li	a2,0
    quick = 1;
    58b4:	4505                	li	a0,1
    58b6:	bf8d                	j	5828 <main+0x20>
    continuous = 2;
    58b8:	85a6                	mv	a1,s1
  char *justone = 0;
    58ba:	4601                	li	a2,0
    58bc:	b7b5                	j	5828 <main+0x20>
    58be:	4601                	li	a2,0
    continuous = 1;
    58c0:	4585                	li	a1,1
    58c2:	b79d                	j	5828 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    58c4:	00003517          	auipc	a0,0x3
    58c8:	8cc50513          	addi	a0,a0,-1844 # 8190 <malloc+0x21da>
    58cc:	00000097          	auipc	ra,0x0
    58d0:	632080e7          	jalr	1586(ra) # 5efe <printf>
  exit(0);
    58d4:	4501                	li	a0,0
    58d6:	00000097          	auipc	ra,0x0
    58da:	28e080e7          	jalr	654(ra) # 5b64 <exit>

00000000000058de <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
    58de:	1141                	addi	sp,sp,-16
    58e0:	e406                	sd	ra,8(sp)
    58e2:	e022                	sd	s0,0(sp)
    58e4:	0800                	addi	s0,sp,16
  extern int main();
  main();
    58e6:	00000097          	auipc	ra,0x0
    58ea:	f22080e7          	jalr	-222(ra) # 5808 <main>
  exit(0);
    58ee:	4501                	li	a0,0
    58f0:	00000097          	auipc	ra,0x0
    58f4:	274080e7          	jalr	628(ra) # 5b64 <exit>

00000000000058f8 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
    58f8:	1141                	addi	sp,sp,-16
    58fa:	e422                	sd	s0,8(sp)
    58fc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
    58fe:	87aa                	mv	a5,a0
    5900:	0585                	addi	a1,a1,1
    5902:	0785                	addi	a5,a5,1
    5904:	fff5c703          	lbu	a4,-1(a1)
    5908:	fee78fa3          	sb	a4,-1(a5)
    590c:	fb75                	bnez	a4,5900 <strcpy+0x8>
    ;
  return os;
}
    590e:	6422                	ld	s0,8(sp)
    5910:	0141                	addi	sp,sp,16
    5912:	8082                	ret

0000000000005914 <strcmp>:

int strcmp(const char *p, const char *q)
{
    5914:	1141                	addi	sp,sp,-16
    5916:	e422                	sd	s0,8(sp)
    5918:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
    591a:	00054783          	lbu	a5,0(a0)
    591e:	cb91                	beqz	a5,5932 <strcmp+0x1e>
    5920:	0005c703          	lbu	a4,0(a1)
    5924:	00f71763          	bne	a4,a5,5932 <strcmp+0x1e>
    p++, q++;
    5928:	0505                	addi	a0,a0,1
    592a:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
    592c:	00054783          	lbu	a5,0(a0)
    5930:	fbe5                	bnez	a5,5920 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5932:	0005c503          	lbu	a0,0(a1)
}
    5936:	40a7853b          	subw	a0,a5,a0
    593a:	6422                	ld	s0,8(sp)
    593c:	0141                	addi	sp,sp,16
    593e:	8082                	ret

0000000000005940 <strlen>:

uint strlen(const char *s)
{
    5940:	1141                	addi	sp,sp,-16
    5942:	e422                	sd	s0,8(sp)
    5944:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    5946:	00054783          	lbu	a5,0(a0)
    594a:	cf91                	beqz	a5,5966 <strlen+0x26>
    594c:	0505                	addi	a0,a0,1
    594e:	87aa                	mv	a5,a0
    5950:	4685                	li	a3,1
    5952:	9e89                	subw	a3,a3,a0
    5954:	00f6853b          	addw	a0,a3,a5
    5958:	0785                	addi	a5,a5,1
    595a:	fff7c703          	lbu	a4,-1(a5)
    595e:	fb7d                	bnez	a4,5954 <strlen+0x14>
    ;
  return n;
}
    5960:	6422                	ld	s0,8(sp)
    5962:	0141                	addi	sp,sp,16
    5964:	8082                	ret
  for (n = 0; s[n]; n++)
    5966:	4501                	li	a0,0
    5968:	bfe5                	j	5960 <strlen+0x20>

000000000000596a <memset>:

void *
memset(void *dst, int c, uint n)
{
    596a:	1141                	addi	sp,sp,-16
    596c:	e422                	sd	s0,8(sp)
    596e:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++)
    5970:	ca19                	beqz	a2,5986 <memset+0x1c>
    5972:	87aa                	mv	a5,a0
    5974:	1602                	slli	a2,a2,0x20
    5976:	9201                	srli	a2,a2,0x20
    5978:	00a60733          	add	a4,a2,a0
  {
    cdst[i] = c;
    597c:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++)
    5980:	0785                	addi	a5,a5,1
    5982:	fee79de3          	bne	a5,a4,597c <memset+0x12>
  }
  return dst;
}
    5986:	6422                	ld	s0,8(sp)
    5988:	0141                	addi	sp,sp,16
    598a:	8082                	ret

000000000000598c <strchr>:

char *
strchr(const char *s, char c)
{
    598c:	1141                	addi	sp,sp,-16
    598e:	e422                	sd	s0,8(sp)
    5990:	0800                	addi	s0,sp,16
  for (; *s; s++)
    5992:	00054783          	lbu	a5,0(a0)
    5996:	cb99                	beqz	a5,59ac <strchr+0x20>
    if (*s == c)
    5998:	00f58763          	beq	a1,a5,59a6 <strchr+0x1a>
  for (; *s; s++)
    599c:	0505                	addi	a0,a0,1
    599e:	00054783          	lbu	a5,0(a0)
    59a2:	fbfd                	bnez	a5,5998 <strchr+0xc>
      return (char *)s;
  return 0;
    59a4:	4501                	li	a0,0
}
    59a6:	6422                	ld	s0,8(sp)
    59a8:	0141                	addi	sp,sp,16
    59aa:	8082                	ret
  return 0;
    59ac:	4501                	li	a0,0
    59ae:	bfe5                	j	59a6 <strchr+0x1a>

00000000000059b0 <gets>:

char *
gets(char *buf, int max)
{
    59b0:	711d                	addi	sp,sp,-96
    59b2:	ec86                	sd	ra,88(sp)
    59b4:	e8a2                	sd	s0,80(sp)
    59b6:	e4a6                	sd	s1,72(sp)
    59b8:	e0ca                	sd	s2,64(sp)
    59ba:	fc4e                	sd	s3,56(sp)
    59bc:	f852                	sd	s4,48(sp)
    59be:	f456                	sd	s5,40(sp)
    59c0:	f05a                	sd	s6,32(sp)
    59c2:	ec5e                	sd	s7,24(sp)
    59c4:	1080                	addi	s0,sp,96
    59c6:	8baa                	mv	s7,a0
    59c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;)
    59ca:	892a                	mv	s2,a0
    59cc:	4481                	li	s1,0
  {
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
    59ce:	4aa9                	li	s5,10
    59d0:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;)
    59d2:	89a6                	mv	s3,s1
    59d4:	2485                	addiw	s1,s1,1
    59d6:	0344d863          	bge	s1,s4,5a06 <gets+0x56>
    cc = read(0, &c, 1);
    59da:	4605                	li	a2,1
    59dc:	faf40593          	addi	a1,s0,-81
    59e0:	4501                	li	a0,0
    59e2:	00000097          	auipc	ra,0x0
    59e6:	19a080e7          	jalr	410(ra) # 5b7c <read>
    if (cc < 1)
    59ea:	00a05e63          	blez	a0,5a06 <gets+0x56>
    buf[i++] = c;
    59ee:	faf44783          	lbu	a5,-81(s0)
    59f2:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
    59f6:	01578763          	beq	a5,s5,5a04 <gets+0x54>
    59fa:	0905                	addi	s2,s2,1
    59fc:	fd679be3          	bne	a5,s6,59d2 <gets+0x22>
  for (i = 0; i + 1 < max;)
    5a00:	89a6                	mv	s3,s1
    5a02:	a011                	j	5a06 <gets+0x56>
    5a04:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5a06:	99de                	add	s3,s3,s7
    5a08:	00098023          	sb	zero,0(s3)
  return buf;
}
    5a0c:	855e                	mv	a0,s7
    5a0e:	60e6                	ld	ra,88(sp)
    5a10:	6446                	ld	s0,80(sp)
    5a12:	64a6                	ld	s1,72(sp)
    5a14:	6906                	ld	s2,64(sp)
    5a16:	79e2                	ld	s3,56(sp)
    5a18:	7a42                	ld	s4,48(sp)
    5a1a:	7aa2                	ld	s5,40(sp)
    5a1c:	7b02                	ld	s6,32(sp)
    5a1e:	6be2                	ld	s7,24(sp)
    5a20:	6125                	addi	sp,sp,96
    5a22:	8082                	ret

0000000000005a24 <stat>:

int stat(const char *n, struct stat *st)
{
    5a24:	1101                	addi	sp,sp,-32
    5a26:	ec06                	sd	ra,24(sp)
    5a28:	e822                	sd	s0,16(sp)
    5a2a:	e426                	sd	s1,8(sp)
    5a2c:	e04a                	sd	s2,0(sp)
    5a2e:	1000                	addi	s0,sp,32
    5a30:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5a32:	4581                	li	a1,0
    5a34:	00000097          	auipc	ra,0x0
    5a38:	170080e7          	jalr	368(ra) # 5ba4 <open>
  if (fd < 0)
    5a3c:	02054563          	bltz	a0,5a66 <stat+0x42>
    5a40:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5a42:	85ca                	mv	a1,s2
    5a44:	00000097          	auipc	ra,0x0
    5a48:	178080e7          	jalr	376(ra) # 5bbc <fstat>
    5a4c:	892a                	mv	s2,a0
  close(fd);
    5a4e:	8526                	mv	a0,s1
    5a50:	00000097          	auipc	ra,0x0
    5a54:	13c080e7          	jalr	316(ra) # 5b8c <close>
  return r;
}
    5a58:	854a                	mv	a0,s2
    5a5a:	60e2                	ld	ra,24(sp)
    5a5c:	6442                	ld	s0,16(sp)
    5a5e:	64a2                	ld	s1,8(sp)
    5a60:	6902                	ld	s2,0(sp)
    5a62:	6105                	addi	sp,sp,32
    5a64:	8082                	ret
    return -1;
    5a66:	597d                	li	s2,-1
    5a68:	bfc5                	j	5a58 <stat+0x34>

0000000000005a6a <atoi>:

int atoi(const char *s)
{
    5a6a:	1141                	addi	sp,sp,-16
    5a6c:	e422                	sd	s0,8(sp)
    5a6e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
    5a70:	00054683          	lbu	a3,0(a0)
    5a74:	fd06879b          	addiw	a5,a3,-48
    5a78:	0ff7f793          	zext.b	a5,a5
    5a7c:	4625                	li	a2,9
    5a7e:	02f66863          	bltu	a2,a5,5aae <atoi+0x44>
    5a82:	872a                	mv	a4,a0
  n = 0;
    5a84:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
    5a86:	0705                	addi	a4,a4,1
    5a88:	0025179b          	slliw	a5,a0,0x2
    5a8c:	9fa9                	addw	a5,a5,a0
    5a8e:	0017979b          	slliw	a5,a5,0x1
    5a92:	9fb5                	addw	a5,a5,a3
    5a94:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
    5a98:	00074683          	lbu	a3,0(a4)
    5a9c:	fd06879b          	addiw	a5,a3,-48
    5aa0:	0ff7f793          	zext.b	a5,a5
    5aa4:	fef671e3          	bgeu	a2,a5,5a86 <atoi+0x1c>
  return n;
}
    5aa8:	6422                	ld	s0,8(sp)
    5aaa:	0141                	addi	sp,sp,16
    5aac:	8082                	ret
  n = 0;
    5aae:	4501                	li	a0,0
    5ab0:	bfe5                	j	5aa8 <atoi+0x3e>

0000000000005ab2 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
    5ab2:	1141                	addi	sp,sp,-16
    5ab4:	e422                	sd	s0,8(sp)
    5ab6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst)
    5ab8:	02b57463          	bgeu	a0,a1,5ae0 <memmove+0x2e>
  {
    while (n-- > 0)
    5abc:	00c05f63          	blez	a2,5ada <memmove+0x28>
    5ac0:	1602                	slli	a2,a2,0x20
    5ac2:	9201                	srli	a2,a2,0x20
    5ac4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5ac8:	872a                	mv	a4,a0
      *dst++ = *src++;
    5aca:	0585                	addi	a1,a1,1
    5acc:	0705                	addi	a4,a4,1
    5ace:	fff5c683          	lbu	a3,-1(a1)
    5ad2:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    5ad6:	fee79ae3          	bne	a5,a4,5aca <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5ada:	6422                	ld	s0,8(sp)
    5adc:	0141                	addi	sp,sp,16
    5ade:	8082                	ret
    dst += n;
    5ae0:	00c50733          	add	a4,a0,a2
    src += n;
    5ae4:	95b2                	add	a1,a1,a2
    while (n-- > 0)
    5ae6:	fec05ae3          	blez	a2,5ada <memmove+0x28>
    5aea:	fff6079b          	addiw	a5,a2,-1
    5aee:	1782                	slli	a5,a5,0x20
    5af0:	9381                	srli	a5,a5,0x20
    5af2:	fff7c793          	not	a5,a5
    5af6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5af8:	15fd                	addi	a1,a1,-1
    5afa:	177d                	addi	a4,a4,-1
    5afc:	0005c683          	lbu	a3,0(a1)
    5b00:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
    5b04:	fee79ae3          	bne	a5,a4,5af8 <memmove+0x46>
    5b08:	bfc9                	j	5ada <memmove+0x28>

0000000000005b0a <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
    5b0a:	1141                	addi	sp,sp,-16
    5b0c:	e422                	sd	s0,8(sp)
    5b0e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0)
    5b10:	ca05                	beqz	a2,5b40 <memcmp+0x36>
    5b12:	fff6069b          	addiw	a3,a2,-1
    5b16:	1682                	slli	a3,a3,0x20
    5b18:	9281                	srli	a3,a3,0x20
    5b1a:	0685                	addi	a3,a3,1
    5b1c:	96aa                	add	a3,a3,a0
  {
    if (*p1 != *p2)
    5b1e:	00054783          	lbu	a5,0(a0)
    5b22:	0005c703          	lbu	a4,0(a1)
    5b26:	00e79863          	bne	a5,a4,5b36 <memcmp+0x2c>
    {
      return *p1 - *p2;
    }
    p1++;
    5b2a:	0505                	addi	a0,a0,1
    p2++;
    5b2c:	0585                	addi	a1,a1,1
  while (n-- > 0)
    5b2e:	fed518e3          	bne	a0,a3,5b1e <memcmp+0x14>
  }
  return 0;
    5b32:	4501                	li	a0,0
    5b34:	a019                	j	5b3a <memcmp+0x30>
      return *p1 - *p2;
    5b36:	40e7853b          	subw	a0,a5,a4
}
    5b3a:	6422                	ld	s0,8(sp)
    5b3c:	0141                	addi	sp,sp,16
    5b3e:	8082                	ret
  return 0;
    5b40:	4501                	li	a0,0
    5b42:	bfe5                	j	5b3a <memcmp+0x30>

0000000000005b44 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5b44:	1141                	addi	sp,sp,-16
    5b46:	e406                	sd	ra,8(sp)
    5b48:	e022                	sd	s0,0(sp)
    5b4a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5b4c:	00000097          	auipc	ra,0x0
    5b50:	f66080e7          	jalr	-154(ra) # 5ab2 <memmove>
}
    5b54:	60a2                	ld	ra,8(sp)
    5b56:	6402                	ld	s0,0(sp)
    5b58:	0141                	addi	sp,sp,16
    5b5a:	8082                	ret

0000000000005b5c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5b5c:	4885                	li	a7,1
 ecall
    5b5e:	00000073          	ecall
 ret
    5b62:	8082                	ret

0000000000005b64 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5b64:	4889                	li	a7,2
 ecall
    5b66:	00000073          	ecall
 ret
    5b6a:	8082                	ret

0000000000005b6c <wait>:
.global wait
wait:
 li a7, SYS_wait
    5b6c:	488d                	li	a7,3
 ecall
    5b6e:	00000073          	ecall
 ret
    5b72:	8082                	ret

0000000000005b74 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5b74:	4891                	li	a7,4
 ecall
    5b76:	00000073          	ecall
 ret
    5b7a:	8082                	ret

0000000000005b7c <read>:
.global read
read:
 li a7, SYS_read
    5b7c:	4895                	li	a7,5
 ecall
    5b7e:	00000073          	ecall
 ret
    5b82:	8082                	ret

0000000000005b84 <write>:
.global write
write:
 li a7, SYS_write
    5b84:	48c1                	li	a7,16
 ecall
    5b86:	00000073          	ecall
 ret
    5b8a:	8082                	ret

0000000000005b8c <close>:
.global close
close:
 li a7, SYS_close
    5b8c:	48d5                	li	a7,21
 ecall
    5b8e:	00000073          	ecall
 ret
    5b92:	8082                	ret

0000000000005b94 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5b94:	4899                	li	a7,6
 ecall
    5b96:	00000073          	ecall
 ret
    5b9a:	8082                	ret

0000000000005b9c <exec>:
.global exec
exec:
 li a7, SYS_exec
    5b9c:	489d                	li	a7,7
 ecall
    5b9e:	00000073          	ecall
 ret
    5ba2:	8082                	ret

0000000000005ba4 <open>:
.global open
open:
 li a7, SYS_open
    5ba4:	48bd                	li	a7,15
 ecall
    5ba6:	00000073          	ecall
 ret
    5baa:	8082                	ret

0000000000005bac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5bac:	48c5                	li	a7,17
 ecall
    5bae:	00000073          	ecall
 ret
    5bb2:	8082                	ret

0000000000005bb4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5bb4:	48c9                	li	a7,18
 ecall
    5bb6:	00000073          	ecall
 ret
    5bba:	8082                	ret

0000000000005bbc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5bbc:	48a1                	li	a7,8
 ecall
    5bbe:	00000073          	ecall
 ret
    5bc2:	8082                	ret

0000000000005bc4 <link>:
.global link
link:
 li a7, SYS_link
    5bc4:	48cd                	li	a7,19
 ecall
    5bc6:	00000073          	ecall
 ret
    5bca:	8082                	ret

0000000000005bcc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5bcc:	48d1                	li	a7,20
 ecall
    5bce:	00000073          	ecall
 ret
    5bd2:	8082                	ret

0000000000005bd4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5bd4:	48a5                	li	a7,9
 ecall
    5bd6:	00000073          	ecall
 ret
    5bda:	8082                	ret

0000000000005bdc <dup>:
.global dup
dup:
 li a7, SYS_dup
    5bdc:	48a9                	li	a7,10
 ecall
    5bde:	00000073          	ecall
 ret
    5be2:	8082                	ret

0000000000005be4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5be4:	48ad                	li	a7,11
 ecall
    5be6:	00000073          	ecall
 ret
    5bea:	8082                	ret

0000000000005bec <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5bec:	48b1                	li	a7,12
 ecall
    5bee:	00000073          	ecall
 ret
    5bf2:	8082                	ret

0000000000005bf4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5bf4:	48b5                	li	a7,13
 ecall
    5bf6:	00000073          	ecall
 ret
    5bfa:	8082                	ret

0000000000005bfc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5bfc:	48b9                	li	a7,14
 ecall
    5bfe:	00000073          	ecall
 ret
    5c02:	8082                	ret

0000000000005c04 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
    5c04:	48dd                	li	a7,23
 ecall
    5c06:	00000073          	ecall
 ret
    5c0a:	8082                	ret

0000000000005c0c <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
    5c0c:	48e5                	li	a7,25
 ecall
    5c0e:	00000073          	ecall
 ret
    5c12:	8082                	ret

0000000000005c14 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
    5c14:	48e1                	li	a7,24
 ecall
    5c16:	00000073          	ecall
 ret
    5c1a:	8082                	ret

0000000000005c1c <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
    5c1c:	48e9                	li	a7,26
 ecall
    5c1e:	00000073          	ecall
 ret
    5c22:	8082                	ret

0000000000005c24 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5c24:	1101                	addi	sp,sp,-32
    5c26:	ec06                	sd	ra,24(sp)
    5c28:	e822                	sd	s0,16(sp)
    5c2a:	1000                	addi	s0,sp,32
    5c2c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5c30:	4605                	li	a2,1
    5c32:	fef40593          	addi	a1,s0,-17
    5c36:	00000097          	auipc	ra,0x0
    5c3a:	f4e080e7          	jalr	-178(ra) # 5b84 <write>
}
    5c3e:	60e2                	ld	ra,24(sp)
    5c40:	6442                	ld	s0,16(sp)
    5c42:	6105                	addi	sp,sp,32
    5c44:	8082                	ret

0000000000005c46 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5c46:	7139                	addi	sp,sp,-64
    5c48:	fc06                	sd	ra,56(sp)
    5c4a:	f822                	sd	s0,48(sp)
    5c4c:	f426                	sd	s1,40(sp)
    5c4e:	f04a                	sd	s2,32(sp)
    5c50:	ec4e                	sd	s3,24(sp)
    5c52:	0080                	addi	s0,sp,64
    5c54:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if (sgn && xx < 0)
    5c56:	c299                	beqz	a3,5c5c <printint+0x16>
    5c58:	0805c963          	bltz	a1,5cea <printint+0xa4>
    neg = 1;
    x = -xx;
  }
  else
  {
    x = xx;
    5c5c:	2581                	sext.w	a1,a1
  neg = 0;
    5c5e:	4881                	li	a7,0
    5c60:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5c64:	4701                	li	a4,0
  do
  {
    buf[i++] = digits[x % base];
    5c66:	2601                	sext.w	a2,a2
    5c68:	00003517          	auipc	a0,0x3
    5c6c:	91050513          	addi	a0,a0,-1776 # 8578 <digits>
    5c70:	883a                	mv	a6,a4
    5c72:	2705                	addiw	a4,a4,1
    5c74:	02c5f7bb          	remuw	a5,a1,a2
    5c78:	1782                	slli	a5,a5,0x20
    5c7a:	9381                	srli	a5,a5,0x20
    5c7c:	97aa                	add	a5,a5,a0
    5c7e:	0007c783          	lbu	a5,0(a5)
    5c82:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    5c86:	0005879b          	sext.w	a5,a1
    5c8a:	02c5d5bb          	divuw	a1,a1,a2
    5c8e:	0685                	addi	a3,a3,1
    5c90:	fec7f0e3          	bgeu	a5,a2,5c70 <printint+0x2a>
  if (neg)
    5c94:	00088c63          	beqz	a7,5cac <printint+0x66>
    buf[i++] = '-';
    5c98:	fd070793          	addi	a5,a4,-48
    5c9c:	00878733          	add	a4,a5,s0
    5ca0:	02d00793          	li	a5,45
    5ca4:	fef70823          	sb	a5,-16(a4)
    5ca8:	0028071b          	addiw	a4,a6,2

  while (--i >= 0)
    5cac:	02e05863          	blez	a4,5cdc <printint+0x96>
    5cb0:	fc040793          	addi	a5,s0,-64
    5cb4:	00e78933          	add	s2,a5,a4
    5cb8:	fff78993          	addi	s3,a5,-1
    5cbc:	99ba                	add	s3,s3,a4
    5cbe:	377d                	addiw	a4,a4,-1
    5cc0:	1702                	slli	a4,a4,0x20
    5cc2:	9301                	srli	a4,a4,0x20
    5cc4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5cc8:	fff94583          	lbu	a1,-1(s2)
    5ccc:	8526                	mv	a0,s1
    5cce:	00000097          	auipc	ra,0x0
    5cd2:	f56080e7          	jalr	-170(ra) # 5c24 <putc>
  while (--i >= 0)
    5cd6:	197d                	addi	s2,s2,-1
    5cd8:	ff3918e3          	bne	s2,s3,5cc8 <printint+0x82>
}
    5cdc:	70e2                	ld	ra,56(sp)
    5cde:	7442                	ld	s0,48(sp)
    5ce0:	74a2                	ld	s1,40(sp)
    5ce2:	7902                	ld	s2,32(sp)
    5ce4:	69e2                	ld	s3,24(sp)
    5ce6:	6121                	addi	sp,sp,64
    5ce8:	8082                	ret
    x = -xx;
    5cea:	40b005bb          	negw	a1,a1
    neg = 1;
    5cee:	4885                	li	a7,1
    x = -xx;
    5cf0:	bf85                	j	5c60 <printint+0x1a>

0000000000005cf2 <vprintf>:
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void vprintf(int fd, const char *fmt, va_list ap)
{
    5cf2:	7119                	addi	sp,sp,-128
    5cf4:	fc86                	sd	ra,120(sp)
    5cf6:	f8a2                	sd	s0,112(sp)
    5cf8:	f4a6                	sd	s1,104(sp)
    5cfa:	f0ca                	sd	s2,96(sp)
    5cfc:	ecce                	sd	s3,88(sp)
    5cfe:	e8d2                	sd	s4,80(sp)
    5d00:	e4d6                	sd	s5,72(sp)
    5d02:	e0da                	sd	s6,64(sp)
    5d04:	fc5e                	sd	s7,56(sp)
    5d06:	f862                	sd	s8,48(sp)
    5d08:	f466                	sd	s9,40(sp)
    5d0a:	f06a                	sd	s10,32(sp)
    5d0c:	ec6e                	sd	s11,24(sp)
    5d0e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++)
    5d10:	0005c903          	lbu	s2,0(a1)
    5d14:	18090f63          	beqz	s2,5eb2 <vprintf+0x1c0>
    5d18:	8aaa                	mv	s5,a0
    5d1a:	8b32                	mv	s6,a2
    5d1c:	00158493          	addi	s1,a1,1
  state = 0;
    5d20:	4981                	li	s3,0
      else
      {
        putc(fd, c);
      }
    }
    else if (state == '%')
    5d22:	02500a13          	li	s4,37
    5d26:	4c55                	li	s8,21
    5d28:	00002c97          	auipc	s9,0x2
    5d2c:	7f8c8c93          	addi	s9,s9,2040 # 8520 <malloc+0x256a>
      else if (c == 's')
      {
        s = va_arg(ap, char *);
        if (s == 0)
          s = "(null)";
        while (*s != 0)
    5d30:	02800d93          	li	s11,40
  putc(fd, 'x');
    5d34:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5d36:	00003b97          	auipc	s7,0x3
    5d3a:	842b8b93          	addi	s7,s7,-1982 # 8578 <digits>
    5d3e:	a839                	j	5d5c <vprintf+0x6a>
        putc(fd, c);
    5d40:	85ca                	mv	a1,s2
    5d42:	8556                	mv	a0,s5
    5d44:	00000097          	auipc	ra,0x0
    5d48:	ee0080e7          	jalr	-288(ra) # 5c24 <putc>
    5d4c:	a019                	j	5d52 <vprintf+0x60>
    else if (state == '%')
    5d4e:	01498d63          	beq	s3,s4,5d68 <vprintf+0x76>
  for (i = 0; fmt[i]; i++)
    5d52:	0485                	addi	s1,s1,1
    5d54:	fff4c903          	lbu	s2,-1(s1)
    5d58:	14090d63          	beqz	s2,5eb2 <vprintf+0x1c0>
    if (state == 0)
    5d5c:	fe0999e3          	bnez	s3,5d4e <vprintf+0x5c>
      if (c == '%')
    5d60:	ff4910e3          	bne	s2,s4,5d40 <vprintf+0x4e>
        state = '%';
    5d64:	89d2                	mv	s3,s4
    5d66:	b7f5                	j	5d52 <vprintf+0x60>
      if (c == 'd')
    5d68:	11490c63          	beq	s2,s4,5e80 <vprintf+0x18e>
    5d6c:	f9d9079b          	addiw	a5,s2,-99
    5d70:	0ff7f793          	zext.b	a5,a5
    5d74:	10fc6e63          	bltu	s8,a5,5e90 <vprintf+0x19e>
    5d78:	f9d9079b          	addiw	a5,s2,-99
    5d7c:	0ff7f713          	zext.b	a4,a5
    5d80:	10ec6863          	bltu	s8,a4,5e90 <vprintf+0x19e>
    5d84:	00271793          	slli	a5,a4,0x2
    5d88:	97e6                	add	a5,a5,s9
    5d8a:	439c                	lw	a5,0(a5)
    5d8c:	97e6                	add	a5,a5,s9
    5d8e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    5d90:	008b0913          	addi	s2,s6,8
    5d94:	4685                	li	a3,1
    5d96:	4629                	li	a2,10
    5d98:	000b2583          	lw	a1,0(s6)
    5d9c:	8556                	mv	a0,s5
    5d9e:	00000097          	auipc	ra,0x0
    5da2:	ea8080e7          	jalr	-344(ra) # 5c46 <printint>
    5da6:	8b4a                	mv	s6,s2
      {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    5da8:	4981                	li	s3,0
    5daa:	b765                	j	5d52 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5dac:	008b0913          	addi	s2,s6,8
    5db0:	4681                	li	a3,0
    5db2:	4629                	li	a2,10
    5db4:	000b2583          	lw	a1,0(s6)
    5db8:	8556                	mv	a0,s5
    5dba:	00000097          	auipc	ra,0x0
    5dbe:	e8c080e7          	jalr	-372(ra) # 5c46 <printint>
    5dc2:	8b4a                	mv	s6,s2
      state = 0;
    5dc4:	4981                	li	s3,0
    5dc6:	b771                	j	5d52 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5dc8:	008b0913          	addi	s2,s6,8
    5dcc:	4681                	li	a3,0
    5dce:	866a                	mv	a2,s10
    5dd0:	000b2583          	lw	a1,0(s6)
    5dd4:	8556                	mv	a0,s5
    5dd6:	00000097          	auipc	ra,0x0
    5dda:	e70080e7          	jalr	-400(ra) # 5c46 <printint>
    5dde:	8b4a                	mv	s6,s2
      state = 0;
    5de0:	4981                	li	s3,0
    5de2:	bf85                	j	5d52 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5de4:	008b0793          	addi	a5,s6,8
    5de8:	f8f43423          	sd	a5,-120(s0)
    5dec:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5df0:	03000593          	li	a1,48
    5df4:	8556                	mv	a0,s5
    5df6:	00000097          	auipc	ra,0x0
    5dfa:	e2e080e7          	jalr	-466(ra) # 5c24 <putc>
  putc(fd, 'x');
    5dfe:	07800593          	li	a1,120
    5e02:	8556                	mv	a0,s5
    5e04:	00000097          	auipc	ra,0x0
    5e08:	e20080e7          	jalr	-480(ra) # 5c24 <putc>
    5e0c:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5e0e:	03c9d793          	srli	a5,s3,0x3c
    5e12:	97de                	add	a5,a5,s7
    5e14:	0007c583          	lbu	a1,0(a5)
    5e18:	8556                	mv	a0,s5
    5e1a:	00000097          	auipc	ra,0x0
    5e1e:	e0a080e7          	jalr	-502(ra) # 5c24 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5e22:	0992                	slli	s3,s3,0x4
    5e24:	397d                	addiw	s2,s2,-1
    5e26:	fe0914e3          	bnez	s2,5e0e <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
    5e2a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5e2e:	4981                	li	s3,0
    5e30:	b70d                	j	5d52 <vprintf+0x60>
        s = va_arg(ap, char *);
    5e32:	008b0913          	addi	s2,s6,8
    5e36:	000b3983          	ld	s3,0(s6)
        if (s == 0)
    5e3a:	02098163          	beqz	s3,5e5c <vprintf+0x16a>
        while (*s != 0)
    5e3e:	0009c583          	lbu	a1,0(s3)
    5e42:	c5ad                	beqz	a1,5eac <vprintf+0x1ba>
          putc(fd, *s);
    5e44:	8556                	mv	a0,s5
    5e46:	00000097          	auipc	ra,0x0
    5e4a:	dde080e7          	jalr	-546(ra) # 5c24 <putc>
          s++;
    5e4e:	0985                	addi	s3,s3,1
        while (*s != 0)
    5e50:	0009c583          	lbu	a1,0(s3)
    5e54:	f9e5                	bnez	a1,5e44 <vprintf+0x152>
        s = va_arg(ap, char *);
    5e56:	8b4a                	mv	s6,s2
      state = 0;
    5e58:	4981                	li	s3,0
    5e5a:	bde5                	j	5d52 <vprintf+0x60>
          s = "(null)";
    5e5c:	00002997          	auipc	s3,0x2
    5e60:	6bc98993          	addi	s3,s3,1724 # 8518 <malloc+0x2562>
        while (*s != 0)
    5e64:	85ee                	mv	a1,s11
    5e66:	bff9                	j	5e44 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
    5e68:	008b0913          	addi	s2,s6,8
    5e6c:	000b4583          	lbu	a1,0(s6)
    5e70:	8556                	mv	a0,s5
    5e72:	00000097          	auipc	ra,0x0
    5e76:	db2080e7          	jalr	-590(ra) # 5c24 <putc>
    5e7a:	8b4a                	mv	s6,s2
      state = 0;
    5e7c:	4981                	li	s3,0
    5e7e:	bdd1                	j	5d52 <vprintf+0x60>
        putc(fd, c);
    5e80:	85d2                	mv	a1,s4
    5e82:	8556                	mv	a0,s5
    5e84:	00000097          	auipc	ra,0x0
    5e88:	da0080e7          	jalr	-608(ra) # 5c24 <putc>
      state = 0;
    5e8c:	4981                	li	s3,0
    5e8e:	b5d1                	j	5d52 <vprintf+0x60>
        putc(fd, '%');
    5e90:	85d2                	mv	a1,s4
    5e92:	8556                	mv	a0,s5
    5e94:	00000097          	auipc	ra,0x0
    5e98:	d90080e7          	jalr	-624(ra) # 5c24 <putc>
        putc(fd, c);
    5e9c:	85ca                	mv	a1,s2
    5e9e:	8556                	mv	a0,s5
    5ea0:	00000097          	auipc	ra,0x0
    5ea4:	d84080e7          	jalr	-636(ra) # 5c24 <putc>
      state = 0;
    5ea8:	4981                	li	s3,0
    5eaa:	b565                	j	5d52 <vprintf+0x60>
        s = va_arg(ap, char *);
    5eac:	8b4a                	mv	s6,s2
      state = 0;
    5eae:	4981                	li	s3,0
    5eb0:	b54d                	j	5d52 <vprintf+0x60>
    }
  }
}
    5eb2:	70e6                	ld	ra,120(sp)
    5eb4:	7446                	ld	s0,112(sp)
    5eb6:	74a6                	ld	s1,104(sp)
    5eb8:	7906                	ld	s2,96(sp)
    5eba:	69e6                	ld	s3,88(sp)
    5ebc:	6a46                	ld	s4,80(sp)
    5ebe:	6aa6                	ld	s5,72(sp)
    5ec0:	6b06                	ld	s6,64(sp)
    5ec2:	7be2                	ld	s7,56(sp)
    5ec4:	7c42                	ld	s8,48(sp)
    5ec6:	7ca2                	ld	s9,40(sp)
    5ec8:	7d02                	ld	s10,32(sp)
    5eca:	6de2                	ld	s11,24(sp)
    5ecc:	6109                	addi	sp,sp,128
    5ece:	8082                	ret

0000000000005ed0 <fprintf>:

void fprintf(int fd, const char *fmt, ...)
{
    5ed0:	715d                	addi	sp,sp,-80
    5ed2:	ec06                	sd	ra,24(sp)
    5ed4:	e822                	sd	s0,16(sp)
    5ed6:	1000                	addi	s0,sp,32
    5ed8:	e010                	sd	a2,0(s0)
    5eda:	e414                	sd	a3,8(s0)
    5edc:	e818                	sd	a4,16(s0)
    5ede:	ec1c                	sd	a5,24(s0)
    5ee0:	03043023          	sd	a6,32(s0)
    5ee4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5ee8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5eec:	8622                	mv	a2,s0
    5eee:	00000097          	auipc	ra,0x0
    5ef2:	e04080e7          	jalr	-508(ra) # 5cf2 <vprintf>
}
    5ef6:	60e2                	ld	ra,24(sp)
    5ef8:	6442                	ld	s0,16(sp)
    5efa:	6161                	addi	sp,sp,80
    5efc:	8082                	ret

0000000000005efe <printf>:

void printf(const char *fmt, ...)
{
    5efe:	711d                	addi	sp,sp,-96
    5f00:	ec06                	sd	ra,24(sp)
    5f02:	e822                	sd	s0,16(sp)
    5f04:	1000                	addi	s0,sp,32
    5f06:	e40c                	sd	a1,8(s0)
    5f08:	e810                	sd	a2,16(s0)
    5f0a:	ec14                	sd	a3,24(s0)
    5f0c:	f018                	sd	a4,32(s0)
    5f0e:	f41c                	sd	a5,40(s0)
    5f10:	03043823          	sd	a6,48(s0)
    5f14:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5f18:	00840613          	addi	a2,s0,8
    5f1c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5f20:	85aa                	mv	a1,a0
    5f22:	4505                	li	a0,1
    5f24:	00000097          	auipc	ra,0x0
    5f28:	dce080e7          	jalr	-562(ra) # 5cf2 <vprintf>
}
    5f2c:	60e2                	ld	ra,24(sp)
    5f2e:	6442                	ld	s0,16(sp)
    5f30:	6125                	addi	sp,sp,96
    5f32:	8082                	ret

0000000000005f34 <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
    5f34:	1141                	addi	sp,sp,-16
    5f36:	e422                	sd	s0,8(sp)
    5f38:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
    5f3a:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5f3e:	00003797          	auipc	a5,0x3
    5f42:	5127b783          	ld	a5,1298(a5) # 9450 <freep>
    5f46:	a02d                	j	5f70 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr)
  {
    bp->s.size += p->s.ptr->s.size;
    5f48:	4618                	lw	a4,8(a2)
    5f4a:	9f2d                	addw	a4,a4,a1
    5f4c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5f50:	6398                	ld	a4,0(a5)
    5f52:	6310                	ld	a2,0(a4)
    5f54:	a83d                	j	5f92 <free+0x5e>
  }
  else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp)
  {
    p->s.size += bp->s.size;
    5f56:	ff852703          	lw	a4,-8(a0)
    5f5a:	9f31                	addw	a4,a4,a2
    5f5c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    5f5e:	ff053683          	ld	a3,-16(a0)
    5f62:	a091                	j	5fa6 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5f64:	6398                	ld	a4,0(a5)
    5f66:	00e7e463          	bltu	a5,a4,5f6e <free+0x3a>
    5f6a:	00e6ea63          	bltu	a3,a4,5f7e <free+0x4a>
{
    5f6e:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5f70:	fed7fae3          	bgeu	a5,a3,5f64 <free+0x30>
    5f74:	6398                	ld	a4,0(a5)
    5f76:	00e6e463          	bltu	a3,a4,5f7e <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5f7a:	fee7eae3          	bltu	a5,a4,5f6e <free+0x3a>
  if (bp + bp->s.size == p->s.ptr)
    5f7e:	ff852583          	lw	a1,-8(a0)
    5f82:	6390                	ld	a2,0(a5)
    5f84:	02059813          	slli	a6,a1,0x20
    5f88:	01c85713          	srli	a4,a6,0x1c
    5f8c:	9736                	add	a4,a4,a3
    5f8e:	fae60de3          	beq	a2,a4,5f48 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    5f92:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp)
    5f96:	4790                	lw	a2,8(a5)
    5f98:	02061593          	slli	a1,a2,0x20
    5f9c:	01c5d713          	srli	a4,a1,0x1c
    5fa0:	973e                	add	a4,a4,a5
    5fa2:	fae68ae3          	beq	a3,a4,5f56 <free+0x22>
    p->s.ptr = bp->s.ptr;
    5fa6:	e394                	sd	a3,0(a5)
  }
  else
    p->s.ptr = bp;
  freep = p;
    5fa8:	00003717          	auipc	a4,0x3
    5fac:	4af73423          	sd	a5,1192(a4) # 9450 <freep>
}
    5fb0:	6422                	ld	s0,8(sp)
    5fb2:	0141                	addi	sp,sp,16
    5fb4:	8082                	ret

0000000000005fb6 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
    5fb6:	7139                	addi	sp,sp,-64
    5fb8:	fc06                	sd	ra,56(sp)
    5fba:	f822                	sd	s0,48(sp)
    5fbc:	f426                	sd	s1,40(sp)
    5fbe:	f04a                	sd	s2,32(sp)
    5fc0:	ec4e                	sd	s3,24(sp)
    5fc2:	e852                	sd	s4,16(sp)
    5fc4:	e456                	sd	s5,8(sp)
    5fc6:	e05a                	sd	s6,0(sp)
    5fc8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    5fca:	02051493          	slli	s1,a0,0x20
    5fce:	9081                	srli	s1,s1,0x20
    5fd0:	04bd                	addi	s1,s1,15
    5fd2:	8091                	srli	s1,s1,0x4
    5fd4:	0014899b          	addiw	s3,s1,1
    5fd8:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0)
    5fda:	00003517          	auipc	a0,0x3
    5fde:	47653503          	ld	a0,1142(a0) # 9450 <freep>
    5fe2:	c515                	beqz	a0,600e <malloc+0x58>
  {
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
    5fe4:	611c                	ld	a5,0(a0)
  {
    if (p->s.size >= nunits)
    5fe6:	4798                	lw	a4,8(a5)
    5fe8:	02977f63          	bgeu	a4,s1,6026 <malloc+0x70>
    5fec:	8a4e                	mv	s4,s3
    5fee:	0009871b          	sext.w	a4,s3
    5ff2:	6685                	lui	a3,0x1
    5ff4:	00d77363          	bgeu	a4,a3,5ffa <malloc+0x44>
    5ff8:	6a05                	lui	s4,0x1
    5ffa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5ffe:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
    6002:	00003917          	auipc	s2,0x3
    6006:	44e90913          	addi	s2,s2,1102 # 9450 <freep>
  if (p == (char *)-1)
    600a:	5afd                	li	s5,-1
    600c:	a895                	j	6080 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    600e:	0000a797          	auipc	a5,0xa
    6012:	c6a78793          	addi	a5,a5,-918 # fc78 <base>
    6016:	00003717          	auipc	a4,0x3
    601a:	42f73d23          	sd	a5,1082(a4) # 9450 <freep>
    601e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    6020:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits)
    6024:	b7e1                	j	5fec <malloc+0x36>
      if (p->s.size == nunits)
    6026:	02e48c63          	beq	s1,a4,605e <malloc+0xa8>
        p->s.size -= nunits;
    602a:	4137073b          	subw	a4,a4,s3
    602e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    6030:	02071693          	slli	a3,a4,0x20
    6034:	01c6d713          	srli	a4,a3,0x1c
    6038:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    603a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    603e:	00003717          	auipc	a4,0x3
    6042:	40a73923          	sd	a0,1042(a4) # 9450 <freep>
      return (void *)(p + 1);
    6046:	01078513          	addi	a0,a5,16
      if ((p = morecore(nunits)) == 0)
        return 0;
  }
}
    604a:	70e2                	ld	ra,56(sp)
    604c:	7442                	ld	s0,48(sp)
    604e:	74a2                	ld	s1,40(sp)
    6050:	7902                	ld	s2,32(sp)
    6052:	69e2                	ld	s3,24(sp)
    6054:	6a42                	ld	s4,16(sp)
    6056:	6aa2                	ld	s5,8(sp)
    6058:	6b02                	ld	s6,0(sp)
    605a:	6121                	addi	sp,sp,64
    605c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    605e:	6398                	ld	a4,0(a5)
    6060:	e118                	sd	a4,0(a0)
    6062:	bff1                	j	603e <malloc+0x88>
  hp->s.size = nu;
    6064:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
    6068:	0541                	addi	a0,a0,16
    606a:	00000097          	auipc	ra,0x0
    606e:	eca080e7          	jalr	-310(ra) # 5f34 <free>
  return freep;
    6072:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
    6076:	d971                	beqz	a0,604a <malloc+0x94>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
    6078:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits)
    607a:	4798                	lw	a4,8(a5)
    607c:	fa9775e3          	bgeu	a4,s1,6026 <malloc+0x70>
    if (p == freep)
    6080:	00093703          	ld	a4,0(s2)
    6084:	853e                	mv	a0,a5
    6086:	fef719e3          	bne	a4,a5,6078 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    608a:	8552                	mv	a0,s4
    608c:	00000097          	auipc	ra,0x0
    6090:	b60080e7          	jalr	-1184(ra) # 5bec <sbrk>
  if (p == (char *)-1)
    6094:	fd5518e3          	bne	a0,s5,6064 <malloc+0xae>
        return 0;
    6098:	4501                	li	a0,0
    609a:	bf45                	j	604a <malloc+0x94>
