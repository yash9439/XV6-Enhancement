
user/_schedulertest1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define NFORK 10
#define IO 4

int main()
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
    int n, pid;
    int wtime, rtime;
    int twtime = 0, trtime = 0;
    for (n = 0; n < NFORK; n++)
   e:	4481                	li	s1,0
{
  10:	05f5e937          	lui	s2,0x5f5e
  14:	10090913          	addi	s2,s2,256 # 5f5e100 <base+0x5f5d0f0>
    for (n = 0; n < NFORK; n++)
  18:	49a9                	li	s3,10
{
  1a:	87ca                	mv	a5,s2
    {
        for (int j = 0; j < 100000000; ++j)
  1c:	37fd                	addiw	a5,a5,-1
  1e:	fffd                	bnez	a5,1c <main+0x1c>
        {
        };
        pid = fork();
  20:	00000097          	auipc	ra,0x0
  24:	33e080e7          	jalr	830(ra) # 35e <fork>
#endif
#ifdef PBS
        if (pid != 0)
            setpriority(60 - IO + n, pid); // Will only matter for PBS, set lower priority for IO bound processes
#endif
        if (pid < 0)
  28:	00054963          	bltz	a0,3a <main+0x3a>
        {
            printf("ERR %d\n", n);
            break;
        }
        if (pid == 0)
  2c:	c531                	beqz	a0,78 <main+0x78>
    for (n = 0; n < NFORK; n++)
  2e:	2485                	addiw	s1,s1,1
  30:	ff3495e3          	bne	s1,s3,1a <main+0x1a>
  34:	4901                	li	s2,0
  36:	4981                	li	s3,0
  38:	a041                	j	b8 <main+0xb8>
            printf("ERR %d\n", n);
  3a:	85a6                	mv	a1,s1
  3c:	00001517          	auipc	a0,0x1
  40:	87450513          	addi	a0,a0,-1932 # 8b0 <malloc+0xe8>
  44:	00000097          	auipc	ra,0x0
  48:	6cc080e7          	jalr	1740(ra) # 710 <printf>
#ifdef PBS
            setpriority(60 - IO + n, pid); // Will only matter for PBS, set lower priority for IO bound processes
#endif
        };
    }
    for (; n > 0; n--)
  4c:	fe9044e3          	bgtz	s1,34 <main+0x34>
  50:	4901                	li	s2,0
  52:	4981                	li	s3,0
        {
            trtime += rtime;
            twtime += wtime;
        }
    }
    printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  54:	45a9                	li	a1,10
  56:	02b9c63b          	divw	a2,s3,a1
  5a:	02b945bb          	divw	a1,s2,a1
  5e:	00001517          	auipc	a0,0x1
  62:	87250513          	addi	a0,a0,-1934 # 8d0 <malloc+0x108>
  66:	00000097          	auipc	ra,0x0
  6a:	6aa080e7          	jalr	1706(ra) # 710 <printf>
    exit(0);
  6e:	4501                	li	a0,0
  70:	00000097          	auipc	ra,0x0
  74:	2f6080e7          	jalr	758(ra) # 366 <exit>
            if (n < IO)
  78:	478d                	li	a5,3
  7a:	0297c663          	blt	a5,s1,a6 <main+0xa6>
                sleep(200); // IO bound processes
  7e:	0c800513          	li	a0,200
  82:	00000097          	auipc	ra,0x0
  86:	374080e7          	jalr	884(ra) # 3f6 <sleep>
            printf("Process %d finished\n", n);
  8a:	85a6                	mv	a1,s1
  8c:	00001517          	auipc	a0,0x1
  90:	82c50513          	addi	a0,a0,-2004 # 8b8 <malloc+0xf0>
  94:	00000097          	auipc	ra,0x0
  98:	67c080e7          	jalr	1660(ra) # 710 <printf>
            exit(0);
  9c:	4501                	li	a0,0
  9e:	00000097          	auipc	ra,0x0
  a2:	2c8080e7          	jalr	712(ra) # 366 <exit>
  a6:	800007b7          	lui	a5,0x80000
  aa:	fff7c793          	not	a5,a5
                for (uint64 i = 0; i < n * 1000000000; i++)
  ae:	17fd                	addi	a5,a5,-1 # ffffffff7fffffff <base+0xffffffff7fffefef>
  b0:	fffd                	bnez	a5,ae <main+0xae>
  b2:	bfe1                	j	8a <main+0x8a>
    for (; n > 0; n--)
  b4:	34fd                	addiw	s1,s1,-1
  b6:	dcd9                	beqz	s1,54 <main+0x54>
        if (waitx(0, &wtime, &rtime) >= 0)
  b8:	fc840613          	addi	a2,s0,-56
  bc:	fcc40593          	addi	a1,s0,-52
  c0:	4501                	li	a0,0
  c2:	00000097          	auipc	ra,0x0
  c6:	364080e7          	jalr	868(ra) # 426 <waitx>
  ca:	fe0545e3          	bltz	a0,b4 <main+0xb4>
            trtime += rtime;
  ce:	fc842783          	lw	a5,-56(s0)
  d2:	0127893b          	addw	s2,a5,s2
            twtime += wtime;
  d6:	fcc42783          	lw	a5,-52(s0)
  da:	013789bb          	addw	s3,a5,s3
  de:	bfd9                	j	b4 <main+0xb4>

00000000000000e0 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
  e0:	1141                	addi	sp,sp,-16
  e2:	e406                	sd	ra,8(sp)
  e4:	e022                	sd	s0,0(sp)
  e6:	0800                	addi	s0,sp,16
  extern int main();
  main();
  e8:	00000097          	auipc	ra,0x0
  ec:	f18080e7          	jalr	-232(ra) # 0 <main>
  exit(0);
  f0:	4501                	li	a0,0
  f2:	00000097          	auipc	ra,0x0
  f6:	274080e7          	jalr	628(ra) # 366 <exit>

00000000000000fa <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e422                	sd	s0,8(sp)
  fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 100:	87aa                	mv	a5,a0
 102:	0585                	addi	a1,a1,1
 104:	0785                	addi	a5,a5,1
 106:	fff5c703          	lbu	a4,-1(a1)
 10a:	fee78fa3          	sb	a4,-1(a5)
 10e:	fb75                	bnez	a4,102 <strcpy+0x8>
    ;
  return os;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret

0000000000000116 <strcmp>:

int strcmp(const char *p, const char *q)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 11c:	00054783          	lbu	a5,0(a0)
 120:	cb91                	beqz	a5,134 <strcmp+0x1e>
 122:	0005c703          	lbu	a4,0(a1)
 126:	00f71763          	bne	a4,a5,134 <strcmp+0x1e>
    p++, q++;
 12a:	0505                	addi	a0,a0,1
 12c:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 12e:	00054783          	lbu	a5,0(a0)
 132:	fbe5                	bnez	a5,122 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 134:	0005c503          	lbu	a0,0(a1)
}
 138:	40a7853b          	subw	a0,a5,a0
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret

0000000000000142 <strlen>:

uint strlen(const char *s)
{
 142:	1141                	addi	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 148:	00054783          	lbu	a5,0(a0)
 14c:	cf91                	beqz	a5,168 <strlen+0x26>
 14e:	0505                	addi	a0,a0,1
 150:	87aa                	mv	a5,a0
 152:	4685                	li	a3,1
 154:	9e89                	subw	a3,a3,a0
 156:	00f6853b          	addw	a0,a3,a5
 15a:	0785                	addi	a5,a5,1
 15c:	fff7c703          	lbu	a4,-1(a5)
 160:	fb7d                	bnez	a4,156 <strlen+0x14>
    ;
  return n;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret
  for (n = 0; s[n]; n++)
 168:	4501                	li	a0,0
 16a:	bfe5                	j	162 <strlen+0x20>

000000000000016c <memset>:

void *
memset(void *dst, int c, uint n)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++)
 172:	ca19                	beqz	a2,188 <memset+0x1c>
 174:	87aa                	mv	a5,a0
 176:	1602                	slli	a2,a2,0x20
 178:	9201                	srli	a2,a2,0x20
 17a:	00a60733          	add	a4,a2,a0
  {
    cdst[i] = c;
 17e:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++)
 182:	0785                	addi	a5,a5,1
 184:	fee79de3          	bne	a5,a4,17e <memset+0x12>
  }
  return dst;
}
 188:	6422                	ld	s0,8(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret

000000000000018e <strchr>:

char *
strchr(const char *s, char c)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e422                	sd	s0,8(sp)
 192:	0800                	addi	s0,sp,16
  for (; *s; s++)
 194:	00054783          	lbu	a5,0(a0)
 198:	cb99                	beqz	a5,1ae <strchr+0x20>
    if (*s == c)
 19a:	00f58763          	beq	a1,a5,1a8 <strchr+0x1a>
  for (; *s; s++)
 19e:	0505                	addi	a0,a0,1
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbfd                	bnez	a5,19a <strchr+0xc>
      return (char *)s;
  return 0;
 1a6:	4501                	li	a0,0
}
 1a8:	6422                	ld	s0,8(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret
  return 0;
 1ae:	4501                	li	a0,0
 1b0:	bfe5                	j	1a8 <strchr+0x1a>

00000000000001b2 <gets>:

char *
gets(char *buf, int max)
{
 1b2:	711d                	addi	sp,sp,-96
 1b4:	ec86                	sd	ra,88(sp)
 1b6:	e8a2                	sd	s0,80(sp)
 1b8:	e4a6                	sd	s1,72(sp)
 1ba:	e0ca                	sd	s2,64(sp)
 1bc:	fc4e                	sd	s3,56(sp)
 1be:	f852                	sd	s4,48(sp)
 1c0:	f456                	sd	s5,40(sp)
 1c2:	f05a                	sd	s6,32(sp)
 1c4:	ec5e                	sd	s7,24(sp)
 1c6:	1080                	addi	s0,sp,96
 1c8:	8baa                	mv	s7,a0
 1ca:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;)
 1cc:	892a                	mv	s2,a0
 1ce:	4481                	li	s1,0
  {
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 1d0:	4aa9                	li	s5,10
 1d2:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;)
 1d4:	89a6                	mv	s3,s1
 1d6:	2485                	addiw	s1,s1,1
 1d8:	0344d863          	bge	s1,s4,208 <gets+0x56>
    cc = read(0, &c, 1);
 1dc:	4605                	li	a2,1
 1de:	faf40593          	addi	a1,s0,-81
 1e2:	4501                	li	a0,0
 1e4:	00000097          	auipc	ra,0x0
 1e8:	19a080e7          	jalr	410(ra) # 37e <read>
    if (cc < 1)
 1ec:	00a05e63          	blez	a0,208 <gets+0x56>
    buf[i++] = c;
 1f0:	faf44783          	lbu	a5,-81(s0)
 1f4:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 1f8:	01578763          	beq	a5,s5,206 <gets+0x54>
 1fc:	0905                	addi	s2,s2,1
 1fe:	fd679be3          	bne	a5,s6,1d4 <gets+0x22>
  for (i = 0; i + 1 < max;)
 202:	89a6                	mv	s3,s1
 204:	a011                	j	208 <gets+0x56>
 206:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 208:	99de                	add	s3,s3,s7
 20a:	00098023          	sb	zero,0(s3)
  return buf;
}
 20e:	855e                	mv	a0,s7
 210:	60e6                	ld	ra,88(sp)
 212:	6446                	ld	s0,80(sp)
 214:	64a6                	ld	s1,72(sp)
 216:	6906                	ld	s2,64(sp)
 218:	79e2                	ld	s3,56(sp)
 21a:	7a42                	ld	s4,48(sp)
 21c:	7aa2                	ld	s5,40(sp)
 21e:	7b02                	ld	s6,32(sp)
 220:	6be2                	ld	s7,24(sp)
 222:	6125                	addi	sp,sp,96
 224:	8082                	ret

0000000000000226 <stat>:

int stat(const char *n, struct stat *st)
{
 226:	1101                	addi	sp,sp,-32
 228:	ec06                	sd	ra,24(sp)
 22a:	e822                	sd	s0,16(sp)
 22c:	e426                	sd	s1,8(sp)
 22e:	e04a                	sd	s2,0(sp)
 230:	1000                	addi	s0,sp,32
 232:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 234:	4581                	li	a1,0
 236:	00000097          	auipc	ra,0x0
 23a:	170080e7          	jalr	368(ra) # 3a6 <open>
  if (fd < 0)
 23e:	02054563          	bltz	a0,268 <stat+0x42>
 242:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 244:	85ca                	mv	a1,s2
 246:	00000097          	auipc	ra,0x0
 24a:	178080e7          	jalr	376(ra) # 3be <fstat>
 24e:	892a                	mv	s2,a0
  close(fd);
 250:	8526                	mv	a0,s1
 252:	00000097          	auipc	ra,0x0
 256:	13c080e7          	jalr	316(ra) # 38e <close>
  return r;
}
 25a:	854a                	mv	a0,s2
 25c:	60e2                	ld	ra,24(sp)
 25e:	6442                	ld	s0,16(sp)
 260:	64a2                	ld	s1,8(sp)
 262:	6902                	ld	s2,0(sp)
 264:	6105                	addi	sp,sp,32
 266:	8082                	ret
    return -1;
 268:	597d                	li	s2,-1
 26a:	bfc5                	j	25a <stat+0x34>

000000000000026c <atoi>:

int atoi(const char *s)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 272:	00054683          	lbu	a3,0(a0)
 276:	fd06879b          	addiw	a5,a3,-48
 27a:	0ff7f793          	zext.b	a5,a5
 27e:	4625                	li	a2,9
 280:	02f66863          	bltu	a2,a5,2b0 <atoi+0x44>
 284:	872a                	mv	a4,a0
  n = 0;
 286:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 288:	0705                	addi	a4,a4,1
 28a:	0025179b          	slliw	a5,a0,0x2
 28e:	9fa9                	addw	a5,a5,a0
 290:	0017979b          	slliw	a5,a5,0x1
 294:	9fb5                	addw	a5,a5,a3
 296:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 29a:	00074683          	lbu	a3,0(a4)
 29e:	fd06879b          	addiw	a5,a3,-48
 2a2:	0ff7f793          	zext.b	a5,a5
 2a6:	fef671e3          	bgeu	a2,a5,288 <atoi+0x1c>
  return n;
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
  n = 0;
 2b0:	4501                	li	a0,0
 2b2:	bfe5                	j	2aa <atoi+0x3e>

00000000000002b4 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e422                	sd	s0,8(sp)
 2b8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst)
 2ba:	02b57463          	bgeu	a0,a1,2e2 <memmove+0x2e>
  {
    while (n-- > 0)
 2be:	00c05f63          	blez	a2,2dc <memmove+0x28>
 2c2:	1602                	slli	a2,a2,0x20
 2c4:	9201                	srli	a2,a2,0x20
 2c6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ca:	872a                	mv	a4,a0
      *dst++ = *src++;
 2cc:	0585                	addi	a1,a1,1
 2ce:	0705                	addi	a4,a4,1
 2d0:	fff5c683          	lbu	a3,-1(a1)
 2d4:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 2d8:	fee79ae3          	bne	a5,a4,2cc <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2dc:	6422                	ld	s0,8(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret
    dst += n;
 2e2:	00c50733          	add	a4,a0,a2
    src += n;
 2e6:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 2e8:	fec05ae3          	blez	a2,2dc <memmove+0x28>
 2ec:	fff6079b          	addiw	a5,a2,-1
 2f0:	1782                	slli	a5,a5,0x20
 2f2:	9381                	srli	a5,a5,0x20
 2f4:	fff7c793          	not	a5,a5
 2f8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fa:	15fd                	addi	a1,a1,-1
 2fc:	177d                	addi	a4,a4,-1
 2fe:	0005c683          	lbu	a3,0(a1)
 302:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 306:	fee79ae3          	bne	a5,a4,2fa <memmove+0x46>
 30a:	bfc9                	j	2dc <memmove+0x28>

000000000000030c <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0)
 312:	ca05                	beqz	a2,342 <memcmp+0x36>
 314:	fff6069b          	addiw	a3,a2,-1
 318:	1682                	slli	a3,a3,0x20
 31a:	9281                	srli	a3,a3,0x20
 31c:	0685                	addi	a3,a3,1
 31e:	96aa                	add	a3,a3,a0
  {
    if (*p1 != *p2)
 320:	00054783          	lbu	a5,0(a0)
 324:	0005c703          	lbu	a4,0(a1)
 328:	00e79863          	bne	a5,a4,338 <memcmp+0x2c>
    {
      return *p1 - *p2;
    }
    p1++;
 32c:	0505                	addi	a0,a0,1
    p2++;
 32e:	0585                	addi	a1,a1,1
  while (n-- > 0)
 330:	fed518e3          	bne	a0,a3,320 <memcmp+0x14>
  }
  return 0;
 334:	4501                	li	a0,0
 336:	a019                	j	33c <memcmp+0x30>
      return *p1 - *p2;
 338:	40e7853b          	subw	a0,a5,a4
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  return 0;
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <memcmp+0x30>

0000000000000346 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 34e:	00000097          	auipc	ra,0x0
 352:	f66080e7          	jalr	-154(ra) # 2b4 <memmove>
}
 356:	60a2                	ld	ra,8(sp)
 358:	6402                	ld	s0,0(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret

000000000000035e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 35e:	4885                	li	a7,1
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <exit>:
.global exit
exit:
 li a7, SYS_exit
 366:	4889                	li	a7,2
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <wait>:
.global wait
wait:
 li a7, SYS_wait
 36e:	488d                	li	a7,3
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 376:	4891                	li	a7,4
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <read>:
.global read
read:
 li a7, SYS_read
 37e:	4895                	li	a7,5
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <write>:
.global write
write:
 li a7, SYS_write
 386:	48c1                	li	a7,16
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <close>:
.global close
close:
 li a7, SYS_close
 38e:	48d5                	li	a7,21
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <kill>:
.global kill
kill:
 li a7, SYS_kill
 396:	4899                	li	a7,6
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <exec>:
.global exec
exec:
 li a7, SYS_exec
 39e:	489d                	li	a7,7
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <open>:
.global open
open:
 li a7, SYS_open
 3a6:	48bd                	li	a7,15
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ae:	48c5                	li	a7,17
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b6:	48c9                	li	a7,18
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3be:	48a1                	li	a7,8
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <link>:
.global link
link:
 li a7, SYS_link
 3c6:	48cd                	li	a7,19
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ce:	48d1                	li	a7,20
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d6:	48a5                	li	a7,9
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <dup>:
.global dup
dup:
 li a7, SYS_dup
 3de:	48a9                	li	a7,10
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e6:	48ad                	li	a7,11
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ee:	48b1                	li	a7,12
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3f6:	48b5                	li	a7,13
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3fe:	48b9                	li	a7,14
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <trace>:
.global trace
trace:
 li a7, SYS_trace
 406:	48d9                	li	a7,22
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 40e:	48dd                	li	a7,23
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 416:	48e5                	li	a7,25
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 41e:	48e1                	li	a7,24
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 426:	48e9                	li	a7,26
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 42e:	48ed                	li	a7,27
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 436:	1101                	addi	sp,sp,-32
 438:	ec06                	sd	ra,24(sp)
 43a:	e822                	sd	s0,16(sp)
 43c:	1000                	addi	s0,sp,32
 43e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 442:	4605                	li	a2,1
 444:	fef40593          	addi	a1,s0,-17
 448:	00000097          	auipc	ra,0x0
 44c:	f3e080e7          	jalr	-194(ra) # 386 <write>
}
 450:	60e2                	ld	ra,24(sp)
 452:	6442                	ld	s0,16(sp)
 454:	6105                	addi	sp,sp,32
 456:	8082                	ret

0000000000000458 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 458:	7139                	addi	sp,sp,-64
 45a:	fc06                	sd	ra,56(sp)
 45c:	f822                	sd	s0,48(sp)
 45e:	f426                	sd	s1,40(sp)
 460:	f04a                	sd	s2,32(sp)
 462:	ec4e                	sd	s3,24(sp)
 464:	0080                	addi	s0,sp,64
 466:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if (sgn && xx < 0)
 468:	c299                	beqz	a3,46e <printint+0x16>
 46a:	0805c963          	bltz	a1,4fc <printint+0xa4>
    neg = 1;
    x = -xx;
  }
  else
  {
    x = xx;
 46e:	2581                	sext.w	a1,a1
  neg = 0;
 470:	4881                	li	a7,0
 472:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 476:	4701                	li	a4,0
  do
  {
    buf[i++] = digits[x % base];
 478:	2601                	sext.w	a2,a2
 47a:	00000517          	auipc	a0,0x0
 47e:	4d650513          	addi	a0,a0,1238 # 950 <digits>
 482:	883a                	mv	a6,a4
 484:	2705                	addiw	a4,a4,1
 486:	02c5f7bb          	remuw	a5,a1,a2
 48a:	1782                	slli	a5,a5,0x20
 48c:	9381                	srli	a5,a5,0x20
 48e:	97aa                	add	a5,a5,a0
 490:	0007c783          	lbu	a5,0(a5)
 494:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 498:	0005879b          	sext.w	a5,a1
 49c:	02c5d5bb          	divuw	a1,a1,a2
 4a0:	0685                	addi	a3,a3,1
 4a2:	fec7f0e3          	bgeu	a5,a2,482 <printint+0x2a>
  if (neg)
 4a6:	00088c63          	beqz	a7,4be <printint+0x66>
    buf[i++] = '-';
 4aa:	fd070793          	addi	a5,a4,-48
 4ae:	00878733          	add	a4,a5,s0
 4b2:	02d00793          	li	a5,45
 4b6:	fef70823          	sb	a5,-16(a4)
 4ba:	0028071b          	addiw	a4,a6,2

  while (--i >= 0)
 4be:	02e05863          	blez	a4,4ee <printint+0x96>
 4c2:	fc040793          	addi	a5,s0,-64
 4c6:	00e78933          	add	s2,a5,a4
 4ca:	fff78993          	addi	s3,a5,-1
 4ce:	99ba                	add	s3,s3,a4
 4d0:	377d                	addiw	a4,a4,-1
 4d2:	1702                	slli	a4,a4,0x20
 4d4:	9301                	srli	a4,a4,0x20
 4d6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4da:	fff94583          	lbu	a1,-1(s2)
 4de:	8526                	mv	a0,s1
 4e0:	00000097          	auipc	ra,0x0
 4e4:	f56080e7          	jalr	-170(ra) # 436 <putc>
  while (--i >= 0)
 4e8:	197d                	addi	s2,s2,-1
 4ea:	ff3918e3          	bne	s2,s3,4da <printint+0x82>
}
 4ee:	70e2                	ld	ra,56(sp)
 4f0:	7442                	ld	s0,48(sp)
 4f2:	74a2                	ld	s1,40(sp)
 4f4:	7902                	ld	s2,32(sp)
 4f6:	69e2                	ld	s3,24(sp)
 4f8:	6121                	addi	sp,sp,64
 4fa:	8082                	ret
    x = -xx;
 4fc:	40b005bb          	negw	a1,a1
    neg = 1;
 500:	4885                	li	a7,1
    x = -xx;
 502:	bf85                	j	472 <printint+0x1a>

0000000000000504 <vprintf>:
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void vprintf(int fd, const char *fmt, va_list ap)
{
 504:	7119                	addi	sp,sp,-128
 506:	fc86                	sd	ra,120(sp)
 508:	f8a2                	sd	s0,112(sp)
 50a:	f4a6                	sd	s1,104(sp)
 50c:	f0ca                	sd	s2,96(sp)
 50e:	ecce                	sd	s3,88(sp)
 510:	e8d2                	sd	s4,80(sp)
 512:	e4d6                	sd	s5,72(sp)
 514:	e0da                	sd	s6,64(sp)
 516:	fc5e                	sd	s7,56(sp)
 518:	f862                	sd	s8,48(sp)
 51a:	f466                	sd	s9,40(sp)
 51c:	f06a                	sd	s10,32(sp)
 51e:	ec6e                	sd	s11,24(sp)
 520:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++)
 522:	0005c903          	lbu	s2,0(a1)
 526:	18090f63          	beqz	s2,6c4 <vprintf+0x1c0>
 52a:	8aaa                	mv	s5,a0
 52c:	8b32                	mv	s6,a2
 52e:	00158493          	addi	s1,a1,1
  state = 0;
 532:	4981                	li	s3,0
      else
      {
        putc(fd, c);
      }
    }
    else if (state == '%')
 534:	02500a13          	li	s4,37
 538:	4c55                	li	s8,21
 53a:	00000c97          	auipc	s9,0x0
 53e:	3bec8c93          	addi	s9,s9,958 # 8f8 <malloc+0x130>
      else if (c == 's')
      {
        s = va_arg(ap, char *);
        if (s == 0)
          s = "(null)";
        while (*s != 0)
 542:	02800d93          	li	s11,40
  putc(fd, 'x');
 546:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 548:	00000b97          	auipc	s7,0x0
 54c:	408b8b93          	addi	s7,s7,1032 # 950 <digits>
 550:	a839                	j	56e <vprintf+0x6a>
        putc(fd, c);
 552:	85ca                	mv	a1,s2
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	ee0080e7          	jalr	-288(ra) # 436 <putc>
 55e:	a019                	j	564 <vprintf+0x60>
    else if (state == '%')
 560:	01498d63          	beq	s3,s4,57a <vprintf+0x76>
  for (i = 0; fmt[i]; i++)
 564:	0485                	addi	s1,s1,1
 566:	fff4c903          	lbu	s2,-1(s1)
 56a:	14090d63          	beqz	s2,6c4 <vprintf+0x1c0>
    if (state == 0)
 56e:	fe0999e3          	bnez	s3,560 <vprintf+0x5c>
      if (c == '%')
 572:	ff4910e3          	bne	s2,s4,552 <vprintf+0x4e>
        state = '%';
 576:	89d2                	mv	s3,s4
 578:	b7f5                	j	564 <vprintf+0x60>
      if (c == 'd')
 57a:	11490c63          	beq	s2,s4,692 <vprintf+0x18e>
 57e:	f9d9079b          	addiw	a5,s2,-99
 582:	0ff7f793          	zext.b	a5,a5
 586:	10fc6e63          	bltu	s8,a5,6a2 <vprintf+0x19e>
 58a:	f9d9079b          	addiw	a5,s2,-99
 58e:	0ff7f713          	zext.b	a4,a5
 592:	10ec6863          	bltu	s8,a4,6a2 <vprintf+0x19e>
 596:	00271793          	slli	a5,a4,0x2
 59a:	97e6                	add	a5,a5,s9
 59c:	439c                	lw	a5,0(a5)
 59e:	97e6                	add	a5,a5,s9
 5a0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5a2:	008b0913          	addi	s2,s6,8
 5a6:	4685                	li	a3,1
 5a8:	4629                	li	a2,10
 5aa:	000b2583          	lw	a1,0(s6)
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	ea8080e7          	jalr	-344(ra) # 458 <printint>
 5b8:	8b4a                	mv	s6,s2
      {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	b765                	j	564 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5be:	008b0913          	addi	s2,s6,8
 5c2:	4681                	li	a3,0
 5c4:	4629                	li	a2,10
 5c6:	000b2583          	lw	a1,0(s6)
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	e8c080e7          	jalr	-372(ra) # 458 <printint>
 5d4:	8b4a                	mv	s6,s2
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	b771                	j	564 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5da:	008b0913          	addi	s2,s6,8
 5de:	4681                	li	a3,0
 5e0:	866a                	mv	a2,s10
 5e2:	000b2583          	lw	a1,0(s6)
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	e70080e7          	jalr	-400(ra) # 458 <printint>
 5f0:	8b4a                	mv	s6,s2
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	bf85                	j	564 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5f6:	008b0793          	addi	a5,s6,8
 5fa:	f8f43423          	sd	a5,-120(s0)
 5fe:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 602:	03000593          	li	a1,48
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	e2e080e7          	jalr	-466(ra) # 436 <putc>
  putc(fd, 'x');
 610:	07800593          	li	a1,120
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e20080e7          	jalr	-480(ra) # 436 <putc>
 61e:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 620:	03c9d793          	srli	a5,s3,0x3c
 624:	97de                	add	a5,a5,s7
 626:	0007c583          	lbu	a1,0(a5)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e0a080e7          	jalr	-502(ra) # 436 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 634:	0992                	slli	s3,s3,0x4
 636:	397d                	addiw	s2,s2,-1
 638:	fe0914e3          	bnez	s2,620 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 63c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 640:	4981                	li	s3,0
 642:	b70d                	j	564 <vprintf+0x60>
        s = va_arg(ap, char *);
 644:	008b0913          	addi	s2,s6,8
 648:	000b3983          	ld	s3,0(s6)
        if (s == 0)
 64c:	02098163          	beqz	s3,66e <vprintf+0x16a>
        while (*s != 0)
 650:	0009c583          	lbu	a1,0(s3)
 654:	c5ad                	beqz	a1,6be <vprintf+0x1ba>
          putc(fd, *s);
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	dde080e7          	jalr	-546(ra) # 436 <putc>
          s++;
 660:	0985                	addi	s3,s3,1
        while (*s != 0)
 662:	0009c583          	lbu	a1,0(s3)
 666:	f9e5                	bnez	a1,656 <vprintf+0x152>
        s = va_arg(ap, char *);
 668:	8b4a                	mv	s6,s2
      state = 0;
 66a:	4981                	li	s3,0
 66c:	bde5                	j	564 <vprintf+0x60>
          s = "(null)";
 66e:	00000997          	auipc	s3,0x0
 672:	28298993          	addi	s3,s3,642 # 8f0 <malloc+0x128>
        while (*s != 0)
 676:	85ee                	mv	a1,s11
 678:	bff9                	j	656 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 67a:	008b0913          	addi	s2,s6,8
 67e:	000b4583          	lbu	a1,0(s6)
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	db2080e7          	jalr	-590(ra) # 436 <putc>
 68c:	8b4a                	mv	s6,s2
      state = 0;
 68e:	4981                	li	s3,0
 690:	bdd1                	j	564 <vprintf+0x60>
        putc(fd, c);
 692:	85d2                	mv	a1,s4
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	da0080e7          	jalr	-608(ra) # 436 <putc>
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	b5d1                	j	564 <vprintf+0x60>
        putc(fd, '%');
 6a2:	85d2                	mv	a1,s4
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	d90080e7          	jalr	-624(ra) # 436 <putc>
        putc(fd, c);
 6ae:	85ca                	mv	a1,s2
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	d84080e7          	jalr	-636(ra) # 436 <putc>
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b565                	j	564 <vprintf+0x60>
        s = va_arg(ap, char *);
 6be:	8b4a                	mv	s6,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b54d                	j	564 <vprintf+0x60>
    }
  }
}
 6c4:	70e6                	ld	ra,120(sp)
 6c6:	7446                	ld	s0,112(sp)
 6c8:	74a6                	ld	s1,104(sp)
 6ca:	7906                	ld	s2,96(sp)
 6cc:	69e6                	ld	s3,88(sp)
 6ce:	6a46                	ld	s4,80(sp)
 6d0:	6aa6                	ld	s5,72(sp)
 6d2:	6b06                	ld	s6,64(sp)
 6d4:	7be2                	ld	s7,56(sp)
 6d6:	7c42                	ld	s8,48(sp)
 6d8:	7ca2                	ld	s9,40(sp)
 6da:	7d02                	ld	s10,32(sp)
 6dc:	6de2                	ld	s11,24(sp)
 6de:	6109                	addi	sp,sp,128
 6e0:	8082                	ret

00000000000006e2 <fprintf>:

void fprintf(int fd, const char *fmt, ...)
{
 6e2:	715d                	addi	sp,sp,-80
 6e4:	ec06                	sd	ra,24(sp)
 6e6:	e822                	sd	s0,16(sp)
 6e8:	1000                	addi	s0,sp,32
 6ea:	e010                	sd	a2,0(s0)
 6ec:	e414                	sd	a3,8(s0)
 6ee:	e818                	sd	a4,16(s0)
 6f0:	ec1c                	sd	a5,24(s0)
 6f2:	03043023          	sd	a6,32(s0)
 6f6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6fa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6fe:	8622                	mv	a2,s0
 700:	00000097          	auipc	ra,0x0
 704:	e04080e7          	jalr	-508(ra) # 504 <vprintf>
}
 708:	60e2                	ld	ra,24(sp)
 70a:	6442                	ld	s0,16(sp)
 70c:	6161                	addi	sp,sp,80
 70e:	8082                	ret

0000000000000710 <printf>:

void printf(const char *fmt, ...)
{
 710:	711d                	addi	sp,sp,-96
 712:	ec06                	sd	ra,24(sp)
 714:	e822                	sd	s0,16(sp)
 716:	1000                	addi	s0,sp,32
 718:	e40c                	sd	a1,8(s0)
 71a:	e810                	sd	a2,16(s0)
 71c:	ec14                	sd	a3,24(s0)
 71e:	f018                	sd	a4,32(s0)
 720:	f41c                	sd	a5,40(s0)
 722:	03043823          	sd	a6,48(s0)
 726:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 72a:	00840613          	addi	a2,s0,8
 72e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 732:	85aa                	mv	a1,a0
 734:	4505                	li	a0,1
 736:	00000097          	auipc	ra,0x0
 73a:	dce080e7          	jalr	-562(ra) # 504 <vprintf>
}
 73e:	60e2                	ld	ra,24(sp)
 740:	6442                	ld	s0,16(sp)
 742:	6125                	addi	sp,sp,96
 744:	8082                	ret

0000000000000746 <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
 746:	1141                	addi	sp,sp,-16
 748:	e422                	sd	s0,8(sp)
 74a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 74c:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 750:	00001797          	auipc	a5,0x1
 754:	8b07b783          	ld	a5,-1872(a5) # 1000 <freep>
 758:	a02d                	j	782 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr)
  {
    bp->s.size += p->s.ptr->s.size;
 75a:	4618                	lw	a4,8(a2)
 75c:	9f2d                	addw	a4,a4,a1
 75e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 762:	6398                	ld	a4,0(a5)
 764:	6310                	ld	a2,0(a4)
 766:	a83d                	j	7a4 <free+0x5e>
  }
  else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp)
  {
    p->s.size += bp->s.size;
 768:	ff852703          	lw	a4,-8(a0)
 76c:	9f31                	addw	a4,a4,a2
 76e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 770:	ff053683          	ld	a3,-16(a0)
 774:	a091                	j	7b8 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 776:	6398                	ld	a4,0(a5)
 778:	00e7e463          	bltu	a5,a4,780 <free+0x3a>
 77c:	00e6ea63          	bltu	a3,a4,790 <free+0x4a>
{
 780:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 782:	fed7fae3          	bgeu	a5,a3,776 <free+0x30>
 786:	6398                	ld	a4,0(a5)
 788:	00e6e463          	bltu	a3,a4,790 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78c:	fee7eae3          	bltu	a5,a4,780 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr)
 790:	ff852583          	lw	a1,-8(a0)
 794:	6390                	ld	a2,0(a5)
 796:	02059813          	slli	a6,a1,0x20
 79a:	01c85713          	srli	a4,a6,0x1c
 79e:	9736                	add	a4,a4,a3
 7a0:	fae60de3          	beq	a2,a4,75a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a4:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp)
 7a8:	4790                	lw	a2,8(a5)
 7aa:	02061593          	slli	a1,a2,0x20
 7ae:	01c5d713          	srli	a4,a1,0x1c
 7b2:	973e                	add	a4,a4,a5
 7b4:	fae68ae3          	beq	a3,a4,768 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b8:	e394                	sd	a3,0(a5)
  }
  else
    p->s.ptr = bp;
  freep = p;
 7ba:	00001717          	auipc	a4,0x1
 7be:	84f73323          	sd	a5,-1978(a4) # 1000 <freep>
}
 7c2:	6422                	ld	s0,8(sp)
 7c4:	0141                	addi	sp,sp,16
 7c6:	8082                	ret

00000000000007c8 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 7c8:	7139                	addi	sp,sp,-64
 7ca:	fc06                	sd	ra,56(sp)
 7cc:	f822                	sd	s0,48(sp)
 7ce:	f426                	sd	s1,40(sp)
 7d0:	f04a                	sd	s2,32(sp)
 7d2:	ec4e                	sd	s3,24(sp)
 7d4:	e852                	sd	s4,16(sp)
 7d6:	e456                	sd	s5,8(sp)
 7d8:	e05a                	sd	s6,0(sp)
 7da:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 7dc:	02051493          	slli	s1,a0,0x20
 7e0:	9081                	srli	s1,s1,0x20
 7e2:	04bd                	addi	s1,s1,15
 7e4:	8091                	srli	s1,s1,0x4
 7e6:	0014899b          	addiw	s3,s1,1
 7ea:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0)
 7ec:	00001517          	auipc	a0,0x1
 7f0:	81453503          	ld	a0,-2028(a0) # 1000 <freep>
 7f4:	c515                	beqz	a0,820 <malloc+0x58>
  {
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
 7f6:	611c                	ld	a5,0(a0)
  {
    if (p->s.size >= nunits)
 7f8:	4798                	lw	a4,8(a5)
 7fa:	02977f63          	bgeu	a4,s1,838 <malloc+0x70>
 7fe:	8a4e                	mv	s4,s3
 800:	0009871b          	sext.w	a4,s3
 804:	6685                	lui	a3,0x1
 806:	00d77363          	bgeu	a4,a3,80c <malloc+0x44>
 80a:	6a05                	lui	s4,0x1
 80c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 810:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 814:	00000917          	auipc	s2,0x0
 818:	7ec90913          	addi	s2,s2,2028 # 1000 <freep>
  if (p == (char *)-1)
 81c:	5afd                	li	s5,-1
 81e:	a895                	j	892 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 820:	00000797          	auipc	a5,0x0
 824:	7f078793          	addi	a5,a5,2032 # 1010 <base>
 828:	00000717          	auipc	a4,0x0
 82c:	7cf73c23          	sd	a5,2008(a4) # 1000 <freep>
 830:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 832:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits)
 836:	b7e1                	j	7fe <malloc+0x36>
      if (p->s.size == nunits)
 838:	02e48c63          	beq	s1,a4,870 <malloc+0xa8>
        p->s.size -= nunits;
 83c:	4137073b          	subw	a4,a4,s3
 840:	c798                	sw	a4,8(a5)
        p += p->s.size;
 842:	02071693          	slli	a3,a4,0x20
 846:	01c6d713          	srli	a4,a3,0x1c
 84a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 84c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 850:	00000717          	auipc	a4,0x0
 854:	7aa73823          	sd	a0,1968(a4) # 1000 <freep>
      return (void *)(p + 1);
 858:	01078513          	addi	a0,a5,16
      if ((p = morecore(nunits)) == 0)
        return 0;
  }
}
 85c:	70e2                	ld	ra,56(sp)
 85e:	7442                	ld	s0,48(sp)
 860:	74a2                	ld	s1,40(sp)
 862:	7902                	ld	s2,32(sp)
 864:	69e2                	ld	s3,24(sp)
 866:	6a42                	ld	s4,16(sp)
 868:	6aa2                	ld	s5,8(sp)
 86a:	6b02                	ld	s6,0(sp)
 86c:	6121                	addi	sp,sp,64
 86e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 870:	6398                	ld	a4,0(a5)
 872:	e118                	sd	a4,0(a0)
 874:	bff1                	j	850 <malloc+0x88>
  hp->s.size = nu;
 876:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 87a:	0541                	addi	a0,a0,16
 87c:	00000097          	auipc	ra,0x0
 880:	eca080e7          	jalr	-310(ra) # 746 <free>
  return freep;
 884:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 888:	d971                	beqz	a0,85c <malloc+0x94>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
 88a:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits)
 88c:	4798                	lw	a4,8(a5)
 88e:	fa9775e3          	bgeu	a4,s1,838 <malloc+0x70>
    if (p == freep)
 892:	00093703          	ld	a4,0(s2)
 896:	853e                	mv	a0,a5
 898:	fef719e3          	bne	a4,a5,88a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 89c:	8552                	mv	a0,s4
 89e:	00000097          	auipc	ra,0x0
 8a2:	b50080e7          	jalr	-1200(ra) # 3ee <sbrk>
  if (p == (char *)-1)
 8a6:	fd5518e3          	bne	a0,s5,876 <malloc+0xae>
        return 0;
 8aa:	4501                	li	a0,0
 8ac:	bf45                	j	85c <malloc+0x94>
