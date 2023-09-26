
user/_setpriority:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84ae                	mv	s1,a1
    int priority = atoi(argv[1]);
   e:	6588                	ld	a0,8(a1)
  10:	00000097          	auipc	ra,0x0
  14:	1ba080e7          	jalr	442(ra) # 1ca <atoi>
  18:	892a                	mv	s2,a0
    int pid = atoi(argv[2]);
  1a:	6888                	ld	a0,16(s1)
  1c:	00000097          	auipc	ra,0x0
  20:	1ae080e7          	jalr	430(ra) # 1ca <atoi>
  24:	85aa                	mv	a1,a0

    setpriority(priority, pid);
  26:	854a                	mv	a0,s2
  28:	00000097          	auipc	ra,0x0
  2c:	364080e7          	jalr	868(ra) # 38c <setpriority>

    return 0;
  30:	4501                	li	a0,0
  32:	60e2                	ld	ra,24(sp)
  34:	6442                	ld	s0,16(sp)
  36:	64a2                	ld	s1,8(sp)
  38:	6902                	ld	s2,0(sp)
  3a:	6105                	addi	sp,sp,32
  3c:	8082                	ret

000000000000003e <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
  3e:	1141                	addi	sp,sp,-16
  40:	e406                	sd	ra,8(sp)
  42:	e022                	sd	s0,0(sp)
  44:	0800                	addi	s0,sp,16
  extern int main();
  main();
  46:	00000097          	auipc	ra,0x0
  4a:	fba080e7          	jalr	-70(ra) # 0 <main>
  exit(0);
  4e:	4501                	li	a0,0
  50:	00000097          	auipc	ra,0x0
  54:	274080e7          	jalr	628(ra) # 2c4 <exit>

0000000000000058 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  58:	1141                	addi	sp,sp,-16
  5a:	e422                	sd	s0,8(sp)
  5c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  5e:	87aa                	mv	a5,a0
  60:	0585                	addi	a1,a1,1
  62:	0785                	addi	a5,a5,1
  64:	fff5c703          	lbu	a4,-1(a1)
  68:	fee78fa3          	sb	a4,-1(a5)
  6c:	fb75                	bnez	a4,60 <strcpy+0x8>
    ;
  return os;
}
  6e:	6422                	ld	s0,8(sp)
  70:	0141                	addi	sp,sp,16
  72:	8082                	ret

0000000000000074 <strcmp>:

int strcmp(const char *p, const char *q)
{
  74:	1141                	addi	sp,sp,-16
  76:	e422                	sd	s0,8(sp)
  78:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	cb91                	beqz	a5,92 <strcmp+0x1e>
  80:	0005c703          	lbu	a4,0(a1)
  84:	00f71763          	bne	a4,a5,92 <strcmp+0x1e>
    p++, q++;
  88:	0505                	addi	a0,a0,1
  8a:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  8c:	00054783          	lbu	a5,0(a0)
  90:	fbe5                	bnez	a5,80 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  92:	0005c503          	lbu	a0,0(a1)
}
  96:	40a7853b          	subw	a0,a5,a0
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strlen>:

uint strlen(const char *s)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cf91                	beqz	a5,c6 <strlen+0x26>
  ac:	0505                	addi	a0,a0,1
  ae:	87aa                	mv	a5,a0
  b0:	4685                	li	a3,1
  b2:	9e89                	subw	a3,a3,a0
  b4:	00f6853b          	addw	a0,a3,a5
  b8:	0785                	addi	a5,a5,1
  ba:	fff7c703          	lbu	a4,-1(a5)
  be:	fb7d                	bnez	a4,b4 <strlen+0x14>
    ;
  return n;
}
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret
  for (n = 0; s[n]; n++)
  c6:	4501                	li	a0,0
  c8:	bfe5                	j	c0 <strlen+0x20>

00000000000000ca <memset>:

void *
memset(void *dst, int c, uint n)
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e422                	sd	s0,8(sp)
  ce:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++)
  d0:	ca19                	beqz	a2,e6 <memset+0x1c>
  d2:	87aa                	mv	a5,a0
  d4:	1602                	slli	a2,a2,0x20
  d6:	9201                	srli	a2,a2,0x20
  d8:	00a60733          	add	a4,a2,a0
  {
    cdst[i] = c;
  dc:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++)
  e0:	0785                	addi	a5,a5,1
  e2:	fee79de3          	bne	a5,a4,dc <memset+0x12>
  }
  return dst;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret

00000000000000ec <strchr>:

char *
strchr(const char *s, char c)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  for (; *s; s++)
  f2:	00054783          	lbu	a5,0(a0)
  f6:	cb99                	beqz	a5,10c <strchr+0x20>
    if (*s == c)
  f8:	00f58763          	beq	a1,a5,106 <strchr+0x1a>
  for (; *s; s++)
  fc:	0505                	addi	a0,a0,1
  fe:	00054783          	lbu	a5,0(a0)
 102:	fbfd                	bnez	a5,f8 <strchr+0xc>
      return (char *)s;
  return 0;
 104:	4501                	li	a0,0
}
 106:	6422                	ld	s0,8(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret
  return 0;
 10c:	4501                	li	a0,0
 10e:	bfe5                	j	106 <strchr+0x1a>

0000000000000110 <gets>:

char *
gets(char *buf, int max)
{
 110:	711d                	addi	sp,sp,-96
 112:	ec86                	sd	ra,88(sp)
 114:	e8a2                	sd	s0,80(sp)
 116:	e4a6                	sd	s1,72(sp)
 118:	e0ca                	sd	s2,64(sp)
 11a:	fc4e                	sd	s3,56(sp)
 11c:	f852                	sd	s4,48(sp)
 11e:	f456                	sd	s5,40(sp)
 120:	f05a                	sd	s6,32(sp)
 122:	ec5e                	sd	s7,24(sp)
 124:	1080                	addi	s0,sp,96
 126:	8baa                	mv	s7,a0
 128:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;)
 12a:	892a                	mv	s2,a0
 12c:	4481                	li	s1,0
  {
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 12e:	4aa9                	li	s5,10
 130:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;)
 132:	89a6                	mv	s3,s1
 134:	2485                	addiw	s1,s1,1
 136:	0344d863          	bge	s1,s4,166 <gets+0x56>
    cc = read(0, &c, 1);
 13a:	4605                	li	a2,1
 13c:	faf40593          	addi	a1,s0,-81
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	19a080e7          	jalr	410(ra) # 2dc <read>
    if (cc < 1)
 14a:	00a05e63          	blez	a0,166 <gets+0x56>
    buf[i++] = c;
 14e:	faf44783          	lbu	a5,-81(s0)
 152:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 156:	01578763          	beq	a5,s5,164 <gets+0x54>
 15a:	0905                	addi	s2,s2,1
 15c:	fd679be3          	bne	a5,s6,132 <gets+0x22>
  for (i = 0; i + 1 < max;)
 160:	89a6                	mv	s3,s1
 162:	a011                	j	166 <gets+0x56>
 164:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 166:	99de                	add	s3,s3,s7
 168:	00098023          	sb	zero,0(s3)
  return buf;
}
 16c:	855e                	mv	a0,s7
 16e:	60e6                	ld	ra,88(sp)
 170:	6446                	ld	s0,80(sp)
 172:	64a6                	ld	s1,72(sp)
 174:	6906                	ld	s2,64(sp)
 176:	79e2                	ld	s3,56(sp)
 178:	7a42                	ld	s4,48(sp)
 17a:	7aa2                	ld	s5,40(sp)
 17c:	7b02                	ld	s6,32(sp)
 17e:	6be2                	ld	s7,24(sp)
 180:	6125                	addi	sp,sp,96
 182:	8082                	ret

0000000000000184 <stat>:

int stat(const char *n, struct stat *st)
{
 184:	1101                	addi	sp,sp,-32
 186:	ec06                	sd	ra,24(sp)
 188:	e822                	sd	s0,16(sp)
 18a:	e426                	sd	s1,8(sp)
 18c:	e04a                	sd	s2,0(sp)
 18e:	1000                	addi	s0,sp,32
 190:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 192:	4581                	li	a1,0
 194:	00000097          	auipc	ra,0x0
 198:	170080e7          	jalr	368(ra) # 304 <open>
  if (fd < 0)
 19c:	02054563          	bltz	a0,1c6 <stat+0x42>
 1a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a2:	85ca                	mv	a1,s2
 1a4:	00000097          	auipc	ra,0x0
 1a8:	178080e7          	jalr	376(ra) # 31c <fstat>
 1ac:	892a                	mv	s2,a0
  close(fd);
 1ae:	8526                	mv	a0,s1
 1b0:	00000097          	auipc	ra,0x0
 1b4:	13c080e7          	jalr	316(ra) # 2ec <close>
  return r;
}
 1b8:	854a                	mv	a0,s2
 1ba:	60e2                	ld	ra,24(sp)
 1bc:	6442                	ld	s0,16(sp)
 1be:	64a2                	ld	s1,8(sp)
 1c0:	6902                	ld	s2,0(sp)
 1c2:	6105                	addi	sp,sp,32
 1c4:	8082                	ret
    return -1;
 1c6:	597d                	li	s2,-1
 1c8:	bfc5                	j	1b8 <stat+0x34>

00000000000001ca <atoi>:

int atoi(const char *s)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 1d0:	00054683          	lbu	a3,0(a0)
 1d4:	fd06879b          	addiw	a5,a3,-48
 1d8:	0ff7f793          	zext.b	a5,a5
 1dc:	4625                	li	a2,9
 1de:	02f66863          	bltu	a2,a5,20e <atoi+0x44>
 1e2:	872a                	mv	a4,a0
  n = 0;
 1e4:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 1e6:	0705                	addi	a4,a4,1
 1e8:	0025179b          	slliw	a5,a0,0x2
 1ec:	9fa9                	addw	a5,a5,a0
 1ee:	0017979b          	slliw	a5,a5,0x1
 1f2:	9fb5                	addw	a5,a5,a3
 1f4:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 1f8:	00074683          	lbu	a3,0(a4)
 1fc:	fd06879b          	addiw	a5,a3,-48
 200:	0ff7f793          	zext.b	a5,a5
 204:	fef671e3          	bgeu	a2,a5,1e6 <atoi+0x1c>
  return n;
}
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  n = 0;
 20e:	4501                	li	a0,0
 210:	bfe5                	j	208 <atoi+0x3e>

0000000000000212 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst)
 218:	02b57463          	bgeu	a0,a1,240 <memmove+0x2e>
  {
    while (n-- > 0)
 21c:	00c05f63          	blez	a2,23a <memmove+0x28>
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 228:	872a                	mv	a4,a0
      *dst++ = *src++;
 22a:	0585                	addi	a1,a1,1
 22c:	0705                	addi	a4,a4,1
 22e:	fff5c683          	lbu	a3,-1(a1)
 232:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 236:	fee79ae3          	bne	a5,a4,22a <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
    dst += n;
 240:	00c50733          	add	a4,a0,a2
    src += n;
 244:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 246:	fec05ae3          	blez	a2,23a <memmove+0x28>
 24a:	fff6079b          	addiw	a5,a2,-1
 24e:	1782                	slli	a5,a5,0x20
 250:	9381                	srli	a5,a5,0x20
 252:	fff7c793          	not	a5,a5
 256:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 258:	15fd                	addi	a1,a1,-1
 25a:	177d                	addi	a4,a4,-1
 25c:	0005c683          	lbu	a3,0(a1)
 260:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 264:	fee79ae3          	bne	a5,a4,258 <memmove+0x46>
 268:	bfc9                	j	23a <memmove+0x28>

000000000000026a <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0)
 270:	ca05                	beqz	a2,2a0 <memcmp+0x36>
 272:	fff6069b          	addiw	a3,a2,-1
 276:	1682                	slli	a3,a3,0x20
 278:	9281                	srli	a3,a3,0x20
 27a:	0685                	addi	a3,a3,1
 27c:	96aa                	add	a3,a3,a0
  {
    if (*p1 != *p2)
 27e:	00054783          	lbu	a5,0(a0)
 282:	0005c703          	lbu	a4,0(a1)
 286:	00e79863          	bne	a5,a4,296 <memcmp+0x2c>
    {
      return *p1 - *p2;
    }
    p1++;
 28a:	0505                	addi	a0,a0,1
    p2++;
 28c:	0585                	addi	a1,a1,1
  while (n-- > 0)
 28e:	fed518e3          	bne	a0,a3,27e <memcmp+0x14>
  }
  return 0;
 292:	4501                	li	a0,0
 294:	a019                	j	29a <memcmp+0x30>
      return *p1 - *p2;
 296:	40e7853b          	subw	a0,a5,a4
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret
  return 0;
 2a0:	4501                	li	a0,0
 2a2:	bfe5                	j	29a <memcmp+0x30>

00000000000002a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e406                	sd	ra,8(sp)
 2a8:	e022                	sd	s0,0(sp)
 2aa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ac:	00000097          	auipc	ra,0x0
 2b0:	f66080e7          	jalr	-154(ra) # 212 <memmove>
}
 2b4:	60a2                	ld	ra,8(sp)
 2b6:	6402                	ld	s0,0(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret

00000000000002bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2bc:	4885                	li	a7,1
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c4:	4889                	li	a7,2
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2cc:	488d                	li	a7,3
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d4:	4891                	li	a7,4
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <read>:
.global read
read:
 li a7, SYS_read
 2dc:	4895                	li	a7,5
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <write>:
.global write
write:
 li a7, SYS_write
 2e4:	48c1                	li	a7,16
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <close>:
.global close
close:
 li a7, SYS_close
 2ec:	48d5                	li	a7,21
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f4:	4899                	li	a7,6
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 2fc:	489d                	li	a7,7
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <open>:
.global open
open:
 li a7, SYS_open
 304:	48bd                	li	a7,15
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 30c:	48c5                	li	a7,17
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 314:	48c9                	li	a7,18
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 31c:	48a1                	li	a7,8
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <link>:
.global link
link:
 li a7, SYS_link
 324:	48cd                	li	a7,19
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 32c:	48d1                	li	a7,20
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 334:	48a5                	li	a7,9
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <dup>:
.global dup
dup:
 li a7, SYS_dup
 33c:	48a9                	li	a7,10
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 344:	48ad                	li	a7,11
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 34c:	48b1                	li	a7,12
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 354:	48b5                	li	a7,13
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 35c:	48b9                	li	a7,14
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <trace>:
.global trace
trace:
 li a7, SYS_trace
 364:	48d9                	li	a7,22
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 36c:	48dd                	li	a7,23
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 374:	48e5                	li	a7,25
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 37c:	48e1                	li	a7,24
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 384:	48e9                	li	a7,26
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 38c:	48ed                	li	a7,27
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 394:	1101                	addi	sp,sp,-32
 396:	ec06                	sd	ra,24(sp)
 398:	e822                	sd	s0,16(sp)
 39a:	1000                	addi	s0,sp,32
 39c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a0:	4605                	li	a2,1
 3a2:	fef40593          	addi	a1,s0,-17
 3a6:	00000097          	auipc	ra,0x0
 3aa:	f3e080e7          	jalr	-194(ra) # 2e4 <write>
}
 3ae:	60e2                	ld	ra,24(sp)
 3b0:	6442                	ld	s0,16(sp)
 3b2:	6105                	addi	sp,sp,32
 3b4:	8082                	ret

00000000000003b6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b6:	7139                	addi	sp,sp,-64
 3b8:	fc06                	sd	ra,56(sp)
 3ba:	f822                	sd	s0,48(sp)
 3bc:	f426                	sd	s1,40(sp)
 3be:	f04a                	sd	s2,32(sp)
 3c0:	ec4e                	sd	s3,24(sp)
 3c2:	0080                	addi	s0,sp,64
 3c4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if (sgn && xx < 0)
 3c6:	c299                	beqz	a3,3cc <printint+0x16>
 3c8:	0805c963          	bltz	a1,45a <printint+0xa4>
    neg = 1;
    x = -xx;
  }
  else
  {
    x = xx;
 3cc:	2581                	sext.w	a1,a1
  neg = 0;
 3ce:	4881                	li	a7,0
 3d0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3d4:	4701                	li	a4,0
  do
  {
    buf[i++] = digits[x % base];
 3d6:	2601                	sext.w	a2,a2
 3d8:	00000517          	auipc	a0,0x0
 3dc:	49850513          	addi	a0,a0,1176 # 870 <digits>
 3e0:	883a                	mv	a6,a4
 3e2:	2705                	addiw	a4,a4,1
 3e4:	02c5f7bb          	remuw	a5,a1,a2
 3e8:	1782                	slli	a5,a5,0x20
 3ea:	9381                	srli	a5,a5,0x20
 3ec:	97aa                	add	a5,a5,a0
 3ee:	0007c783          	lbu	a5,0(a5)
 3f2:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 3f6:	0005879b          	sext.w	a5,a1
 3fa:	02c5d5bb          	divuw	a1,a1,a2
 3fe:	0685                	addi	a3,a3,1
 400:	fec7f0e3          	bgeu	a5,a2,3e0 <printint+0x2a>
  if (neg)
 404:	00088c63          	beqz	a7,41c <printint+0x66>
    buf[i++] = '-';
 408:	fd070793          	addi	a5,a4,-48
 40c:	00878733          	add	a4,a5,s0
 410:	02d00793          	li	a5,45
 414:	fef70823          	sb	a5,-16(a4)
 418:	0028071b          	addiw	a4,a6,2

  while (--i >= 0)
 41c:	02e05863          	blez	a4,44c <printint+0x96>
 420:	fc040793          	addi	a5,s0,-64
 424:	00e78933          	add	s2,a5,a4
 428:	fff78993          	addi	s3,a5,-1
 42c:	99ba                	add	s3,s3,a4
 42e:	377d                	addiw	a4,a4,-1
 430:	1702                	slli	a4,a4,0x20
 432:	9301                	srli	a4,a4,0x20
 434:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 438:	fff94583          	lbu	a1,-1(s2)
 43c:	8526                	mv	a0,s1
 43e:	00000097          	auipc	ra,0x0
 442:	f56080e7          	jalr	-170(ra) # 394 <putc>
  while (--i >= 0)
 446:	197d                	addi	s2,s2,-1
 448:	ff3918e3          	bne	s2,s3,438 <printint+0x82>
}
 44c:	70e2                	ld	ra,56(sp)
 44e:	7442                	ld	s0,48(sp)
 450:	74a2                	ld	s1,40(sp)
 452:	7902                	ld	s2,32(sp)
 454:	69e2                	ld	s3,24(sp)
 456:	6121                	addi	sp,sp,64
 458:	8082                	ret
    x = -xx;
 45a:	40b005bb          	negw	a1,a1
    neg = 1;
 45e:	4885                	li	a7,1
    x = -xx;
 460:	bf85                	j	3d0 <printint+0x1a>

0000000000000462 <vprintf>:
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void vprintf(int fd, const char *fmt, va_list ap)
{
 462:	7119                	addi	sp,sp,-128
 464:	fc86                	sd	ra,120(sp)
 466:	f8a2                	sd	s0,112(sp)
 468:	f4a6                	sd	s1,104(sp)
 46a:	f0ca                	sd	s2,96(sp)
 46c:	ecce                	sd	s3,88(sp)
 46e:	e8d2                	sd	s4,80(sp)
 470:	e4d6                	sd	s5,72(sp)
 472:	e0da                	sd	s6,64(sp)
 474:	fc5e                	sd	s7,56(sp)
 476:	f862                	sd	s8,48(sp)
 478:	f466                	sd	s9,40(sp)
 47a:	f06a                	sd	s10,32(sp)
 47c:	ec6e                	sd	s11,24(sp)
 47e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++)
 480:	0005c903          	lbu	s2,0(a1)
 484:	18090f63          	beqz	s2,622 <vprintf+0x1c0>
 488:	8aaa                	mv	s5,a0
 48a:	8b32                	mv	s6,a2
 48c:	00158493          	addi	s1,a1,1
  state = 0;
 490:	4981                	li	s3,0
      else
      {
        putc(fd, c);
      }
    }
    else if (state == '%')
 492:	02500a13          	li	s4,37
 496:	4c55                	li	s8,21
 498:	00000c97          	auipc	s9,0x0
 49c:	380c8c93          	addi	s9,s9,896 # 818 <malloc+0xf2>
      else if (c == 's')
      {
        s = va_arg(ap, char *);
        if (s == 0)
          s = "(null)";
        while (*s != 0)
 4a0:	02800d93          	li	s11,40
  putc(fd, 'x');
 4a4:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4a6:	00000b97          	auipc	s7,0x0
 4aa:	3cab8b93          	addi	s7,s7,970 # 870 <digits>
 4ae:	a839                	j	4cc <vprintf+0x6a>
        putc(fd, c);
 4b0:	85ca                	mv	a1,s2
 4b2:	8556                	mv	a0,s5
 4b4:	00000097          	auipc	ra,0x0
 4b8:	ee0080e7          	jalr	-288(ra) # 394 <putc>
 4bc:	a019                	j	4c2 <vprintf+0x60>
    else if (state == '%')
 4be:	01498d63          	beq	s3,s4,4d8 <vprintf+0x76>
  for (i = 0; fmt[i]; i++)
 4c2:	0485                	addi	s1,s1,1
 4c4:	fff4c903          	lbu	s2,-1(s1)
 4c8:	14090d63          	beqz	s2,622 <vprintf+0x1c0>
    if (state == 0)
 4cc:	fe0999e3          	bnez	s3,4be <vprintf+0x5c>
      if (c == '%')
 4d0:	ff4910e3          	bne	s2,s4,4b0 <vprintf+0x4e>
        state = '%';
 4d4:	89d2                	mv	s3,s4
 4d6:	b7f5                	j	4c2 <vprintf+0x60>
      if (c == 'd')
 4d8:	11490c63          	beq	s2,s4,5f0 <vprintf+0x18e>
 4dc:	f9d9079b          	addiw	a5,s2,-99
 4e0:	0ff7f793          	zext.b	a5,a5
 4e4:	10fc6e63          	bltu	s8,a5,600 <vprintf+0x19e>
 4e8:	f9d9079b          	addiw	a5,s2,-99
 4ec:	0ff7f713          	zext.b	a4,a5
 4f0:	10ec6863          	bltu	s8,a4,600 <vprintf+0x19e>
 4f4:	00271793          	slli	a5,a4,0x2
 4f8:	97e6                	add	a5,a5,s9
 4fa:	439c                	lw	a5,0(a5)
 4fc:	97e6                	add	a5,a5,s9
 4fe:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 500:	008b0913          	addi	s2,s6,8
 504:	4685                	li	a3,1
 506:	4629                	li	a2,10
 508:	000b2583          	lw	a1,0(s6)
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	ea8080e7          	jalr	-344(ra) # 3b6 <printint>
 516:	8b4a                	mv	s6,s2
      {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 518:	4981                	li	s3,0
 51a:	b765                	j	4c2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 51c:	008b0913          	addi	s2,s6,8
 520:	4681                	li	a3,0
 522:	4629                	li	a2,10
 524:	000b2583          	lw	a1,0(s6)
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	e8c080e7          	jalr	-372(ra) # 3b6 <printint>
 532:	8b4a                	mv	s6,s2
      state = 0;
 534:	4981                	li	s3,0
 536:	b771                	j	4c2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 538:	008b0913          	addi	s2,s6,8
 53c:	4681                	li	a3,0
 53e:	866a                	mv	a2,s10
 540:	000b2583          	lw	a1,0(s6)
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	e70080e7          	jalr	-400(ra) # 3b6 <printint>
 54e:	8b4a                	mv	s6,s2
      state = 0;
 550:	4981                	li	s3,0
 552:	bf85                	j	4c2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 554:	008b0793          	addi	a5,s6,8
 558:	f8f43423          	sd	a5,-120(s0)
 55c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 560:	03000593          	li	a1,48
 564:	8556                	mv	a0,s5
 566:	00000097          	auipc	ra,0x0
 56a:	e2e080e7          	jalr	-466(ra) # 394 <putc>
  putc(fd, 'x');
 56e:	07800593          	li	a1,120
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e20080e7          	jalr	-480(ra) # 394 <putc>
 57c:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 57e:	03c9d793          	srli	a5,s3,0x3c
 582:	97de                	add	a5,a5,s7
 584:	0007c583          	lbu	a1,0(a5)
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	e0a080e7          	jalr	-502(ra) # 394 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 592:	0992                	slli	s3,s3,0x4
 594:	397d                	addiw	s2,s2,-1
 596:	fe0914e3          	bnez	s2,57e <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 59a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	b70d                	j	4c2 <vprintf+0x60>
        s = va_arg(ap, char *);
 5a2:	008b0913          	addi	s2,s6,8
 5a6:	000b3983          	ld	s3,0(s6)
        if (s == 0)
 5aa:	02098163          	beqz	s3,5cc <vprintf+0x16a>
        while (*s != 0)
 5ae:	0009c583          	lbu	a1,0(s3)
 5b2:	c5ad                	beqz	a1,61c <vprintf+0x1ba>
          putc(fd, *s);
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	dde080e7          	jalr	-546(ra) # 394 <putc>
          s++;
 5be:	0985                	addi	s3,s3,1
        while (*s != 0)
 5c0:	0009c583          	lbu	a1,0(s3)
 5c4:	f9e5                	bnez	a1,5b4 <vprintf+0x152>
        s = va_arg(ap, char *);
 5c6:	8b4a                	mv	s6,s2
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bde5                	j	4c2 <vprintf+0x60>
          s = "(null)";
 5cc:	00000997          	auipc	s3,0x0
 5d0:	24498993          	addi	s3,s3,580 # 810 <malloc+0xea>
        while (*s != 0)
 5d4:	85ee                	mv	a1,s11
 5d6:	bff9                	j	5b4 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 5d8:	008b0913          	addi	s2,s6,8
 5dc:	000b4583          	lbu	a1,0(s6)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	db2080e7          	jalr	-590(ra) # 394 <putc>
 5ea:	8b4a                	mv	s6,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	bdd1                	j	4c2 <vprintf+0x60>
        putc(fd, c);
 5f0:	85d2                	mv	a1,s4
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	da0080e7          	jalr	-608(ra) # 394 <putc>
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b5d1                	j	4c2 <vprintf+0x60>
        putc(fd, '%');
 600:	85d2                	mv	a1,s4
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	d90080e7          	jalr	-624(ra) # 394 <putc>
        putc(fd, c);
 60c:	85ca                	mv	a1,s2
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	d84080e7          	jalr	-636(ra) # 394 <putc>
      state = 0;
 618:	4981                	li	s3,0
 61a:	b565                	j	4c2 <vprintf+0x60>
        s = va_arg(ap, char *);
 61c:	8b4a                	mv	s6,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	b54d                	j	4c2 <vprintf+0x60>
    }
  }
}
 622:	70e6                	ld	ra,120(sp)
 624:	7446                	ld	s0,112(sp)
 626:	74a6                	ld	s1,104(sp)
 628:	7906                	ld	s2,96(sp)
 62a:	69e6                	ld	s3,88(sp)
 62c:	6a46                	ld	s4,80(sp)
 62e:	6aa6                	ld	s5,72(sp)
 630:	6b06                	ld	s6,64(sp)
 632:	7be2                	ld	s7,56(sp)
 634:	7c42                	ld	s8,48(sp)
 636:	7ca2                	ld	s9,40(sp)
 638:	7d02                	ld	s10,32(sp)
 63a:	6de2                	ld	s11,24(sp)
 63c:	6109                	addi	sp,sp,128
 63e:	8082                	ret

0000000000000640 <fprintf>:

void fprintf(int fd, const char *fmt, ...)
{
 640:	715d                	addi	sp,sp,-80
 642:	ec06                	sd	ra,24(sp)
 644:	e822                	sd	s0,16(sp)
 646:	1000                	addi	s0,sp,32
 648:	e010                	sd	a2,0(s0)
 64a:	e414                	sd	a3,8(s0)
 64c:	e818                	sd	a4,16(s0)
 64e:	ec1c                	sd	a5,24(s0)
 650:	03043023          	sd	a6,32(s0)
 654:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 658:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 65c:	8622                	mv	a2,s0
 65e:	00000097          	auipc	ra,0x0
 662:	e04080e7          	jalr	-508(ra) # 462 <vprintf>
}
 666:	60e2                	ld	ra,24(sp)
 668:	6442                	ld	s0,16(sp)
 66a:	6161                	addi	sp,sp,80
 66c:	8082                	ret

000000000000066e <printf>:

void printf(const char *fmt, ...)
{
 66e:	711d                	addi	sp,sp,-96
 670:	ec06                	sd	ra,24(sp)
 672:	e822                	sd	s0,16(sp)
 674:	1000                	addi	s0,sp,32
 676:	e40c                	sd	a1,8(s0)
 678:	e810                	sd	a2,16(s0)
 67a:	ec14                	sd	a3,24(s0)
 67c:	f018                	sd	a4,32(s0)
 67e:	f41c                	sd	a5,40(s0)
 680:	03043823          	sd	a6,48(s0)
 684:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 688:	00840613          	addi	a2,s0,8
 68c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 690:	85aa                	mv	a1,a0
 692:	4505                	li	a0,1
 694:	00000097          	auipc	ra,0x0
 698:	dce080e7          	jalr	-562(ra) # 462 <vprintf>
}
 69c:	60e2                	ld	ra,24(sp)
 69e:	6442                	ld	s0,16(sp)
 6a0:	6125                	addi	sp,sp,96
 6a2:	8082                	ret

00000000000006a4 <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
 6a4:	1141                	addi	sp,sp,-16
 6a6:	e422                	sd	s0,8(sp)
 6a8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 6aa:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ae:	00001797          	auipc	a5,0x1
 6b2:	9527b783          	ld	a5,-1710(a5) # 1000 <freep>
 6b6:	a02d                	j	6e0 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr)
  {
    bp->s.size += p->s.ptr->s.size;
 6b8:	4618                	lw	a4,8(a2)
 6ba:	9f2d                	addw	a4,a4,a1
 6bc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c0:	6398                	ld	a4,0(a5)
 6c2:	6310                	ld	a2,0(a4)
 6c4:	a83d                	j	702 <free+0x5e>
  }
  else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp)
  {
    p->s.size += bp->s.size;
 6c6:	ff852703          	lw	a4,-8(a0)
 6ca:	9f31                	addw	a4,a4,a2
 6cc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6ce:	ff053683          	ld	a3,-16(a0)
 6d2:	a091                	j	716 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d4:	6398                	ld	a4,0(a5)
 6d6:	00e7e463          	bltu	a5,a4,6de <free+0x3a>
 6da:	00e6ea63          	bltu	a3,a4,6ee <free+0x4a>
{
 6de:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e0:	fed7fae3          	bgeu	a5,a3,6d4 <free+0x30>
 6e4:	6398                	ld	a4,0(a5)
 6e6:	00e6e463          	bltu	a3,a4,6ee <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ea:	fee7eae3          	bltu	a5,a4,6de <free+0x3a>
  if (bp + bp->s.size == p->s.ptr)
 6ee:	ff852583          	lw	a1,-8(a0)
 6f2:	6390                	ld	a2,0(a5)
 6f4:	02059813          	slli	a6,a1,0x20
 6f8:	01c85713          	srli	a4,a6,0x1c
 6fc:	9736                	add	a4,a4,a3
 6fe:	fae60de3          	beq	a2,a4,6b8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 702:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp)
 706:	4790                	lw	a2,8(a5)
 708:	02061593          	slli	a1,a2,0x20
 70c:	01c5d713          	srli	a4,a1,0x1c
 710:	973e                	add	a4,a4,a5
 712:	fae68ae3          	beq	a3,a4,6c6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 716:	e394                	sd	a3,0(a5)
  }
  else
    p->s.ptr = bp;
  freep = p;
 718:	00001717          	auipc	a4,0x1
 71c:	8ef73423          	sd	a5,-1816(a4) # 1000 <freep>
}
 720:	6422                	ld	s0,8(sp)
 722:	0141                	addi	sp,sp,16
 724:	8082                	ret

0000000000000726 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 726:	7139                	addi	sp,sp,-64
 728:	fc06                	sd	ra,56(sp)
 72a:	f822                	sd	s0,48(sp)
 72c:	f426                	sd	s1,40(sp)
 72e:	f04a                	sd	s2,32(sp)
 730:	ec4e                	sd	s3,24(sp)
 732:	e852                	sd	s4,16(sp)
 734:	e456                	sd	s5,8(sp)
 736:	e05a                	sd	s6,0(sp)
 738:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 73a:	02051493          	slli	s1,a0,0x20
 73e:	9081                	srli	s1,s1,0x20
 740:	04bd                	addi	s1,s1,15
 742:	8091                	srli	s1,s1,0x4
 744:	0014899b          	addiw	s3,s1,1
 748:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0)
 74a:	00001517          	auipc	a0,0x1
 74e:	8b653503          	ld	a0,-1866(a0) # 1000 <freep>
 752:	c515                	beqz	a0,77e <malloc+0x58>
  {
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
 754:	611c                	ld	a5,0(a0)
  {
    if (p->s.size >= nunits)
 756:	4798                	lw	a4,8(a5)
 758:	02977f63          	bgeu	a4,s1,796 <malloc+0x70>
 75c:	8a4e                	mv	s4,s3
 75e:	0009871b          	sext.w	a4,s3
 762:	6685                	lui	a3,0x1
 764:	00d77363          	bgeu	a4,a3,76a <malloc+0x44>
 768:	6a05                	lui	s4,0x1
 76a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 76e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 772:	00001917          	auipc	s2,0x1
 776:	88e90913          	addi	s2,s2,-1906 # 1000 <freep>
  if (p == (char *)-1)
 77a:	5afd                	li	s5,-1
 77c:	a895                	j	7f0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 77e:	00001797          	auipc	a5,0x1
 782:	89278793          	addi	a5,a5,-1902 # 1010 <base>
 786:	00001717          	auipc	a4,0x1
 78a:	86f73d23          	sd	a5,-1926(a4) # 1000 <freep>
 78e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 790:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits)
 794:	b7e1                	j	75c <malloc+0x36>
      if (p->s.size == nunits)
 796:	02e48c63          	beq	s1,a4,7ce <malloc+0xa8>
        p->s.size -= nunits;
 79a:	4137073b          	subw	a4,a4,s3
 79e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7a0:	02071693          	slli	a3,a4,0x20
 7a4:	01c6d713          	srli	a4,a3,0x1c
 7a8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7aa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ae:	00001717          	auipc	a4,0x1
 7b2:	84a73923          	sd	a0,-1966(a4) # 1000 <freep>
      return (void *)(p + 1);
 7b6:	01078513          	addi	a0,a5,16
      if ((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7ba:	70e2                	ld	ra,56(sp)
 7bc:	7442                	ld	s0,48(sp)
 7be:	74a2                	ld	s1,40(sp)
 7c0:	7902                	ld	s2,32(sp)
 7c2:	69e2                	ld	s3,24(sp)
 7c4:	6a42                	ld	s4,16(sp)
 7c6:	6aa2                	ld	s5,8(sp)
 7c8:	6b02                	ld	s6,0(sp)
 7ca:	6121                	addi	sp,sp,64
 7cc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7ce:	6398                	ld	a4,0(a5)
 7d0:	e118                	sd	a4,0(a0)
 7d2:	bff1                	j	7ae <malloc+0x88>
  hp->s.size = nu;
 7d4:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 7d8:	0541                	addi	a0,a0,16
 7da:	00000097          	auipc	ra,0x0
 7de:	eca080e7          	jalr	-310(ra) # 6a4 <free>
  return freep;
 7e2:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 7e6:	d971                	beqz	a0,7ba <malloc+0x94>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr)
 7e8:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits)
 7ea:	4798                	lw	a4,8(a5)
 7ec:	fa9775e3          	bgeu	a4,s1,796 <malloc+0x70>
    if (p == freep)
 7f0:	00093703          	ld	a4,0(s2)
 7f4:	853e                	mv	a0,a5
 7f6:	fef719e3          	bne	a4,a5,7e8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7fa:	8552                	mv	a0,s4
 7fc:	00000097          	auipc	ra,0x0
 800:	b50080e7          	jalr	-1200(ra) # 34c <sbrk>
  if (p == (char *)-1)
 804:	fd5518e3          	bne	a0,s5,7d4 <malloc+0xae>
        return 0;
 808:	4501                	li	a0,0
 80a:	bf45                	j	7ba <malloc+0x94>
