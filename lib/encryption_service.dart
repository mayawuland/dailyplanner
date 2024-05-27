class CaesarCipher {
  static String encrypt(String plaintext, int shift) {
    String result = '';
    for (int i = 0; i < plaintext.length; i++) {
      String char = plaintext[i];
      if (char != ' ') {
        int asciiValue = char.codeUnitAt(0);
        int shiftedAsciiValue = (asciiValue + shift) % 256; // Modulo 256 agar tidak keluar dari rentang karakter ASCII
        result += String.fromCharCode(shiftedAsciiValue);
      } else {
        result += ' ';
      }
    }
    return result;
  }

  static String decrypt(String ciphertext, int shift) {
    return encrypt(ciphertext, -shift); // Dekripsi sama dengan enkripsi dengan pergeseran negatif
  }
}
