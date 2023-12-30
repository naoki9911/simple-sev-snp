# Simple AMD SEV-SNP Example

```
# Setup Rust environment
~$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
~$ rustup target add x86_64-unknown-linux-musl

~$ git clone --recursive https://github.com/naoki9911/simple-sev-snp
~$ cd simple-sev-snp

# Build SEV-SNP guest tools
~/simple-sev-snp$ cd snpguest
~/simple-sev-snp/snpguest$ cargo build --target x86_64-unknown-linux-musl
~/simple-sev-snp/snpguest$ cd ../

# Create small initrd with alpine rootfs
~/simple-sev-snp$ ./create_rootfs.sh

# Generate private keys to sign launch digests 
~/simple-sev-snp$ ./gen_key.sh

# Then, launch with measurement!
~/simple-sev-snp$ sudo ./launch.sh

# You can get Attestation Report with snpguest
~ # ./snpguest report report.bin req.txt --random
~ # ./snpguest display report report.bin

Attestation Report (1184 bytes):
Version:                      2
Guest SVN:                    0

    Guest Policy (196608):
    ABI Major:     0
    ABI Minor:     0
    SMT Allowed:   1
    Migrate MA:    0
    Debug Allowed: 0
    Single Socket: 0
Family ID:
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
...
```
