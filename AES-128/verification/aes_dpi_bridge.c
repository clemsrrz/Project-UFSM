#include <stdint.h>
#include "aes.h" 

// Fonction de pont pour le chiffrement appelée par SystemVerilog
void c_aes_encrypt(const uint8_t msg[16], const uint8_t *key, uint8_t *out) {
    struct AES_ctx ctx;
    
    // 1. Initialiser le contexte avec la clé
    AES_init_ctx(&ctx, key);
    
    // 2. Copier le message dans le buffer de sortie
    for(int i = 0; i < 16; i++) {
        out[i] = msg[i];
    }
    
    // 3. Appeler la fonction de chiffrement ECB
    AES_ECB_encrypt(&ctx, out);
}

// Fonction de pont pour le déchiffrement appelée par SystemVerilog
void c_aes_decrypt(const uint8_t msg[16], const uint8_t *key, uint8_t *out) {
    struct AES_ctx ctx;
    
    AES_init_ctx(&ctx, key);
    
    for(int i = 0; i < 16; i++) {
        out[i] = msg[i];
    }
    
    // Appeler la fonction de déchiffrement ECB 
    AES_ECB_decrypt(&ctx, out);
}