#include <stdio.h>
#include <stdint.h>

// WRAPPERS ZBA
static inline int sh1add(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x20C5A533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int sh2add(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x20C5C533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int sh3add(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x20C5E533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

// WRAPPERS ZBS (REGISTER FORMAT)
static inline int bclr(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x48C59533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int bset(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x28C59533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int binv(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x68C59533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int bext(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x48C5D533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

// WRAPPERS ZBS (IMMEDIATE FORMAT)
static inline int bclri_5(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x48559513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int bseti_5(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x28559513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int binvi_5(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x68559513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int bexti_5(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x4855D513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

// WRAPPERS ZBC (REGISTER FORMAT)
static inline int clmul(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x0AC59533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int clmulr(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x0AC5A533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int clmulh(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x0AC5B533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

// MODELE DE REFERENCE LOGICIEL POUR ZBC (multiplication sans retenue)
// Le produit complet P(x) = rs1(x) * rs2(x) tient sur 63 bits (2*32-1).
// On le calcule sur 64 bits en logiciel, puis on en extrait :
//   - clmul  = bits [31:0]  de P  (partie basse)
//   - clmulh = bits [63:32] de P  (partie haute, decalage de 32)
//   - clmulr = bits [62:31] de P  (version "reversee", decalage de 31)
static inline uint64_t clmul_full64(uint32_t a, uint32_t b) {
    uint64_t result = 0;
    for (int i = 0; i < 32; i++) {
        if ((b >> i) & 1u)
            result ^= ((uint64_t)a) << i;
    }
    return result;
}

static inline uint32_t ref_clmul(uint32_t a, uint32_t b) {
    return (uint32_t)(clmul_full64(a, b) & 0xFFFFFFFFu);
}

static inline uint32_t ref_clmulh(uint32_t a, uint32_t b) {
    return (uint32_t)(clmul_full64(a, b) >> 32);
}

static inline uint32_t ref_clmulr(uint32_t a, uint32_t b) {
    return (uint32_t)((clmul_full64(a, b) >> 31) & 0xFFFFFFFFu);
}

// WRAPPERS ZBB (REGISTER FORMAT)
static inline int zbb_andn(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x40C5F533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbb_orn(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x40C5E533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbb_xnor(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x40C5C533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbb_min(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x0AC5C533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbb_minu(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x0AC5D533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbb_max(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x0AC5E533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbb_maxu(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x0AC5F533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbb_rol(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x60C59533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbb_ror(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x60C5D533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbb_zexth(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x0805C533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

// WRAPPERS ZBB (IMMEDIATE / SINGLE-OPERAND FORMAT)
static inline int zbb_clz(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x60059513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int zbb_ctz(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x60159513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int zbb_cpop(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x60259513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int zbb_sextb(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x60459513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int zbb_sexth(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x60559513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int zbb_rori_5(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x6055D513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int zbb_orcb(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x2875D513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int zbb_rev8(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x6985D513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

// MODELE DE REFERENCE LOGICIEL POUR ZBB
static inline uint32_t ref_clz(uint32_t x) {
    if (x == 0) return 32;
    uint32_t n = 0;
    while (!(x & 0x80000000u)) { x <<= 1; n++; }
    return n;
}

static inline uint32_t ref_ctz(uint32_t x) {
    if (x == 0) return 32;
    uint32_t n = 0;
    while (!(x & 1u)) { x >>= 1; n++; }
    return n;
}

static inline uint32_t ref_cpop(uint32_t x) {
    uint32_t n = 0;
    while (x) { n += x & 1u; x >>= 1; }
    return n;
}

static inline int32_t ref_sextb(uint32_t x) {
    return (int32_t)(int8_t)(x & 0xFFu);
}

static inline int32_t ref_sexth(uint32_t x) {
    return (int32_t)(int16_t)(x & 0xFFFFu);
}

static inline uint32_t ref_zexth(uint32_t x) {
    return x & 0xFFFFu;
}

static inline uint32_t ref_orcb(uint32_t x) {
    uint32_t r = 0;
    for (int i = 0; i < 4; i++) {
        uint32_t byte = (x >> (i * 8)) & 0xFFu;
        r |= (byte != 0) ? (0xFFu << (i * 8)) : 0;
    }
    return r;
}

static inline uint32_t ref_rev8(uint32_t x) {
    return ((x & 0x000000FFu) << 24) |
           ((x & 0x0000FF00u) << 8)  |
           ((x & 0x00FF0000u) >> 8)  |
           ((x & 0xFF000000u) >> 24);
}

static inline uint32_t ref_rol(uint32_t x, uint32_t shamt) {
    shamt &= 31u;
    return (x << shamt) | (x >> ((32u - shamt) & 31u));
}

static inline uint32_t ref_ror(uint32_t x, uint32_t shamt) {
    shamt &= 31u;
    return (x >> shamt) | (x << ((32u - shamt) & 31u));
}

// WRAPPERS ZBKB (REGISTER FORMAT)
static inline int zbkb_pack(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x08C5C533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbkb_packh(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x08C5F533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

// WRAPPERS ZBKB (UNARY FORMAT)
static inline int zbkb_brev8(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x6875D513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int zbkb_zip(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x08F59513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

static inline int zbkb_unzip(int rs1) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;

    asm volatile (
        ".4byte 0x08F5D513\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1)
    );
    return r_rd;
}

// WRAPPERS ZBKC (memes encodages que Zbc, pour tester le chemin ZBKC seul)
static inline int zbkc_clmul(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x0AC59533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbkc_clmulh(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x0AC5B533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

// WRAPPERS ZBKX (REGISTER FORMAT)
static inline int zbkx_xperm4(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x28C5A533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

static inline int zbkx_xperm8(int rs1, int rs2) {
    register int r_rd  asm("a0");
    register int r_rs1 asm("a1") = rs1;
    register int r_rs2 asm("a2") = rs2;

    asm volatile (
        ".4byte 0x28C5C533\n\t"
        : "=r"(r_rd)
        : "r"(r_rs1), "r"(r_rs2)
    );
    return r_rd;
}

// MODELES DE REFERENCE LOGICIELS POUR ZBKB / ZBKX
static inline uint32_t ref_pack(uint32_t rs1, uint32_t rs2) {
    return ((rs2 & 0xFFFFu) << 16) | (rs1 & 0xFFFFu);
}

static inline uint32_t ref_packh(uint32_t rs1, uint32_t rs2) {
    return ((rs2 & 0xFFu) << 8) | (rs1 & 0xFFu);
}

static inline uint32_t ref_brev8(uint32_t x) {
    uint32_t r = 0;
    for (int byte = 0; byte < 4; byte++) {
        uint8_t b = (x >> (byte * 8)) & 0xFFu;
        uint8_t rb = 0;
        for (int bit = 0; bit < 8; bit++) {
            if (b & (1u << bit)) rb |= (uint8_t)(1u << (7 - bit));
        }
        r |= ((uint32_t)rb) << (byte * 8);
    }
    return r;
}

static inline uint32_t ref_zip(uint32_t x) {
    uint32_t r = 0;
    for (int i = 0; i < 16; i++) {
        if (x & (1u << i))        r |= (1u << (2 * i));
        if (x & (1u << (i + 16))) r |= (1u << (2 * i + 1));
    }
    return r;
}

static inline uint32_t ref_unzip(uint32_t x) {
    uint32_t r = 0;
    for (int i = 0; i < 16; i++) {
        if (x & (1u << (2 * i)))     r |= (1u << i);
        if (x & (1u << (2 * i + 1))) r |= (1u << (i + 16));
    }
    return r;
}

static inline uint32_t ref_xperm4(uint32_t rs1, uint32_t rs2) {
    uint32_t r = 0;
    for (int k = 0; k < 8; k++) {
        uint32_t idx = (rs2 >> (k * 4)) & 0xFu;
        uint32_t val = (idx < 8u) ? ((rs1 >> (idx * 4)) & 0xFu) : 0u;
        r |= val << (k * 4);
    }
    return r;
}

static inline uint32_t ref_xperm8(uint32_t rs1, uint32_t rs2) {
    uint32_t r = 0;
    for (int k = 0; k < 4; k++) {
        uint32_t idx = (rs2 >> (k * 8)) & 0xFFu;
        uint32_t val = (idx < 4u) ? ((rs1 >> (idx * 8)) & 0xFFu) : 0u;
        r |= val << (k * 8);
    }
    return r;
}

int main() {
    int rs1, rs2, rd;
    int expected;

    printf("======================================\n");
    printf("         TESTS EXTENSION ZBA          \n");
    printf("======================================\n\n");

    // Test Zba 1 : sh1add
    rs1 = 0x00000003;
    rs2 = 0x00000005;
    expected = (rs1 << 1) + rs2;
    rd = sh1add(rs1, rs2);
    printf("=== sh1add ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zba 2 : sh2add
    rs1 = 0x00000007;
    rs2 = 0x00000002;
    expected = (rs1 << 2) + rs2;
    rd = sh2add(rs1, rs2);
    printf("=== sh2add ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zba 3 : sh3add
    rs1 = 0x0000000F;
    rs2 = 0x00000001;
    expected = (rs1 << 3) + rs2;
    rd = sh3add(rs1, rs2);
    printf("=== sh3add ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    printf("======================================\n");
    printf("         TESTS EXTENSION ZBS          \n");
    printf("======================================\n\n");

    // Test Zbs 1 : bclr 
    rs1 = 0x0000000F; 
    rs2 = 3;          
    expected = rs1 & ~(1U << rs2);
    rd = bclr(rs1, rs2);
    printf("=== bclr ===\nrs1 = 0x%08x | bit = %d\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbs 2 : bset 
    rs1 = 0x0000000A; 
    rs2 = 4;          
    expected = rs1 | (1U << rs2); 
    rd = bset(rs1, rs2);
    printf("=== bset ===\nrs1 = 0x%08x | bit = %d\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbs 3 : binv 
    rs1 = 0x0000000F; 
    rs2 = 1;         
    expected = rs1 ^ (1U << rs2); 
    rd = binv(rs1, rs2);
    printf("=== binv ===\nrs1 = 0x%08x | bit = %d\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbs 4 : bext 
    rs1 = 0x00000004; 
    rs2 = 2;
    expected = (rs1 >> rs2) & 1U; 
    rd = bext(rs1, rs2);
    printf("=== bext ===\nrs1 = 0x%08x | bit = %d\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbs 5 : bclri 
    rs1 = 0x0000003F; 
    expected = rs1 & ~(1U << 5); 
    rd = bclri_5(rs1);
    printf("=== bclri (imm=5) ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbs 6 : bseti 
    rs1 = 0x0000000F; 
    expected = rs1 | (1U << 5); 
    rd = bseti_5(rs1);
    printf("=== bseti (imm=5) ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbs 7 : binvi 
    rs1 = 0x0000002F; 
    expected = rs1 ^ (1U << 5); 
    rd = binvi_5(rs1);
    printf("=== binvi (imm=5) ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbs 8 : bexti 
    rs1 = 0x00000020; 
    expected = (rs1 >> 5) & 1U; 
    rd = bexti_5(rs1);
    printf("=== bexti (imm=5) ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    printf("======================================\n");
    printf("         TESTS EXTENSION ZBC          \n");
    printf("======================================\n\n");

    // Test Zbc 1 : clmul 
    rs1 = 0x00000005;
    rs2 = 0x00000003;
    expected = (int)ref_clmul((uint32_t)rs1, (uint32_t)rs2);
    rd = clmul(rs1, rs2);
    printf("=== clmul ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbc 2 : clmul (valeurs plus grandes, pour verifier le XOR/decalage)
    rs1 = 0x12345678;
    rs2 = (int)0x9ABCDEF0;
    expected = (int)ref_clmul((uint32_t)rs1,adjustable  (uint32_t)rs2);
    rd = clmul(rs1, rs2);
    printf("=== clmul (valeurs larges) ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbc 3 : clmulh (partie haute du produit sur des valeurs qui debordent 32 bits)
    rs1 = (int)0xFFFFFFFF;
    rs2 = (int)0xFFFFFFFF;
    expected = (int)ref_clmulh((uint32_t)rs1, (uint32_t)rs2);
    rd = clmulh(rs1, rs2);
    printf("=== clmulh ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbc 4 : clmulh (valeurs plus quelconques)
    rs1 = 0x12345678;
    rs2 = (int)0x9ABCDEF0;
    expected = (int)ref_clmulh((uint32_t)rs1, (uint32_t)rs2);
    rd = clmulh(rs1, rs2);
    printf("=== clmulh (valeurs larges) ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbc 5 : clmulr 
    rs1 = (int)0xFFFFFFFF;
    rs2 = (int)0xFFFFFFFF;
    expected = (int)ref_clmulr((uint32_t)rs1, (uint32_t)rs2);
    rd = clmulr(rs1, rs2);
    printf("=== clmulr ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbc 6 : clmulr (valeurs plus quelconques)
    rs1 = 0x12345678;
    rs2 = (int)0x9ABCDEF0;
    expected = (int)ref_clmulr((uint32_t)rs1, (uint32_t)rs2);
    rd = clmulr(rs1, rs2);
    printf("=== clmulr (valeurs larges) ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    printf("======================================\n");
    printf("         TESTS EXTENSION ZBB          \n");
    printf("======================================\n\n");

    // Test Zbb 1 : andn
    rs1 = 0x0000000F;
    rs2 = 0x00000003;
    expected = (int)(((uint32_t)rs1) & ~((uint32_t)rs2)); 
    rd = zbb_andn(rs1, rs2);
    printf("=== andn ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 2 : orn
    rs1 = 0x0000000A;
    rs2 = 0x0000000F;
    expected = (int)(((uint32_t)rs1) | ~((uint32_t)rs2));
    rd = zbb_orn(rs1, rs2);
    printf("=== orn ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 3 : xnor
    rs1 = 0x0000000F;
    rs2 = 0x000000F0;
    expected = (int)(~(((uint32_t)rs1) ^ ((uint32_t)rs2)));
    rd = zbb_xnor(rs1, rs2);
    printf("=== xnor ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 4 : min (signe)
    rs1 = -5;
    rs2 = 3;
    expected = (rs1 < rs2) ? rs1 : rs2; 
    rd = zbb_min(rs1, rs2);
    printf("=== min ===\nrs1 = %d | rs2 = %d\nrd  = %d | attendu = %d -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 5 : minu (non signe)
    rs1 = -5;
    rs2 = 3;
    expected = (int)(((uint32_t)rs1 < (uint32_t)rs2) ? (uint32_t)rs1 : (uint32_t)rs2); // 3
    rd = zbb_minu(rs1, rs2);
    printf("=== minu ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 6 : max (signe)
    rs1 = -5;
    rs2 = 3;
    expected = (rs1 > rs2) ? rs1 : rs2;
    rd = zbb_max(rs1, rs2);
    printf("=== max ===\nrs1 = %d | rs2 = %d\nrd  = %d | attendu = %d -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 7 : maxu (non signe)
    rs1 = -5;
    rs2 = 3;
    expected = (int)(((uint32_t)rs1 > (uint32_t)rs2) ? (uint32_t)rs1 : (uint32_t)rs2); // -5
    rd = zbb_maxu(rs1, rs2);
    printf("=== maxu ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 8 : rol
    rs1 = (int)0x80000001;
    rs2 = 1; 
    expected = (int)ref_rol((uint32_t)rs1, (uint32_t)rs2); 
    rd = zbb_rol(rs1, rs2);
    printf("=== rol ===\nrs1 = 0x%08x | shamt = %d\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 9 : ror
    rs1 = 0x00000003;
    rs2 = 1; 
    expected = (int)ref_ror((uint32_t)rs1, (uint32_t)rs2);
    rd = zbb_ror(rs1, rs2);
    printf("=== ror ===\nrs1 = 0x%08x | shamt = %d\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 10 : zext.h
    rs1 = (int)0xFFFF1234;
    expected = (int)ref_zexth((uint32_t)rs1);
    rd = zbb_zexth(rs1);
    printf("=== zext.h ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 11 : clz 
    rs1 = 0x0000000F; 
    expected = (int)ref_clz((uint32_t)rs1); 
    rd = zbb_clz(rs1);
    printf("=== clz ===\nrs1 = 0x%08x\nrd  = %d | attendu = %d -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");


    // Test Zbb 12 : ctz 
    rs1 = 0x00000008; 
    expected = (int)ref_ctz((uint32_t)rs1);
    rd = zbb_ctz(rs1);
    printf("=== ctz ===\nrs1 = 0x%08x\nrd  = %d | attendu = %d -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");


    // Test Zbb 13 : cpop
    rs1 = (int)0xF0F0F0F0;
    expected = (int)ref_cpop((uint32_t)rs1); 
    rd = zbb_cpop(rs1);
    printf("=== cpop ===\nrs1 = 0x%08x\nrd  = %d | attendu = %d -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 14 : sext.b 
    rs1 = 0x00000080; 
    expected = ref_sextb((uint32_t)rs1); 
    rd = zbb_sextb(rs1);
    printf("=== sext.b ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 15 : sext.h 
    rs1 = 0x00008000; 
    expected = ref_sexth((uint32_t)rs1); 
    rd = zbb_sexth(rs1);
    printf("=== sext.h ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 16 : rori 
    rs1 = 0x00000020; 
    expected = (int)ref_ror((uint32_t)rs1, 5); 
    rd = zbb_rori_5(rs1);
    printf("=== rori (imm=5) ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 17 : orc.b
    rs1 = 0x00FF0001; 
    expected = (int)ref_orcb((uint32_t)rs1);
    rd = zbb_orcb(rs1);
    printf("=== orc.b ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbb 18 : rev8
    rs1 = 0x12345678;
    expected = (int)ref_rev8((uint32_t)rs1); 
    rd = zbb_rev8(rs1);
    printf("=== rev8 ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    printf("======================================\n");
    printf("         TESTS EXTENSION ZBKB         \n");
    printf("======================================\n\n");

    // Test Zbkb 1 : pack
    rs1 = (int)0xAAAA1234;
    rs2 = (int)0xBBBB5678;
    expected = (int)ref_pack((uint32_t)rs1, (uint32_t)rs2); 
    rd = zbkb_pack(rs1, rs2);
    printf("=== pack ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");


    // Test Zbkb 3 : packh
    rs1 = (int)0x11112299;
    rs2 = (int)0x222233AA;
    expected = (int)ref_packh((uint32_t)rs1, (uint32_t)rs2);
    rd = zbkb_packh(rs1, rs2);
    printf("=== packh ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbkb 4 : brev8
    rs1 = 0x12345678;
    expected = (int)ref_brev8((uint32_t)rs1); 
    rd = zbkb_brev8(rs1);
    printf("=== brev8 ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbkb 5 : zip
    rs1 = (int)0x0000FFFF;
    expected = (int)ref_zip((uint32_t)rs1); 
    rd = zbkb_zip(rs1);
    printf("=== zip ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbkb 6 : unzip 
    rs1 = (int)ref_zip(0x0000FFFF); 
    expected = 0x0000FFFF;
    rd = zbkb_unzip(rs1);
    printf("=== unzip (inverse de zip) ===\nrs1 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rd, expected, (rd == expected) ? "OK" : "FAIL");

    printf("======================================\n");
    printf("         TESTS EXTENSION ZBKC         \n");
    printf("======================================\n\n");

    // Test Zbkc 1 : clmul (meme modele de reference que Zbc)
    rs1 = 0x00000005;
    rs2 = 0x00000003;
    expected = (int)ref_clmul((uint32_t)rs1, (uint32_t)rs2); 
    rd = zbkc_clmul(rs1, rs2);
    printf("=== clmul (Zbkc) ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    // Test Zbkc 2 : clmulh
    rs1 = (int)0xFFFFFFFF;
    rs2 = (int)0xFFFFFFFF;
    expected = (int)ref_clmulh((uint32_t)rs1, (uint32_t)rs2);
    rd = zbkc_clmulh(rs1, rs2);
    printf("=== clmulh (Zbkc) ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");

    printf("======================================\n");
    printf("         TESTS EXTENSION ZBKX          \n");
    printf("======================================\n\n");

    // Test Zbkx 1 : xperm4 
    rs1 = (int)0x76543210; 
    rs2 = (int)0x01234567; 
    expected = (int)ref_xperm4((uint32_t)rs1, (uint32_t)rs2);
    rd = zbkx_xperm4(rs1, rs2);
    printf("=== xperm4 ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");


    // Test Zbkx 3 : xperm8 
    rs1 = (int)0xDDCCBBAA; 
    rs2 = (int)0x00010203; 
    expected = (int)ref_xperm8((uint32_t)rs1, (uint32_t)rs2);
    rd = zbkx_xperm8(rs1, rs2);
    printf("=== xperm8 ===\nrs1 = 0x%08x | rs2 = 0x%08x\nrd  = 0x%08x | attendu = 0x%08x -> %s\n\n",
           rs1, rs2, rd, expected, (rd == expected) ? "OK" : "FAIL");


    return 0;
}
