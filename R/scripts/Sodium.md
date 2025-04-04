

```r
# Load the necessary library
library(sodium)

# Step 1: Encrypt Data

# Generate a key from a passphrase
key <- hash(charToRaw("This is a secret passphrase"))

# Data to encrypt (example dataset)
msg <- serialize(iris, NULL)

# Generate a random nonce (24 bytes)
nonce <- random(24)

# Encrypt the data using the key and nonce
cipher <- data_encrypt(msg, key, nonce)
cipher

# Convert to base64 for easier handling
cipher_base64 <- base64enc::base64encode(cipher)
nonce_base64 <- base64enc::base64encode(nonce)
key_base64 <- base64enc::base64encode(key)

# Save the encrypted data, nonce, and key to files
writeLines(cipher_base64, "cipher.txt")
writeLines(nonce_base64, "nonce.txt")
writeLines(key_base64, "key.txt")

# Step 2: Decrypt Data

# Load the encrypted data, nonce, and key from files
cipher_loaded <- base64enc::base64decode(readLines("cipher.txt"))
nonce_loaded <- base64enc::base64decode(readLines("nonce.txt"))
key_loaded <- base64enc::base64decode(readLines("key.txt"))

# Decrypt the data using the loaded key and nonce
orig <- data_decrypt(cipher_loaded, key_loaded, nonce_loaded)

data <- unserialize(orig)

# Check if the decrypted data is identical to the original data
print(identical(iris, unserialize(orig))) # Should print TRUE if decryption is successful

# Step 3: Encrypt Again with the Same Key and Nonce

# Encrypt the data again using the same key and nonce
cipher_again <- data_encrypt(msg, key_loaded, nonce_loaded)

# Check if the new encrypted data is identical to the original encrypted data
print(identical(cipher, cipher_again))

```
