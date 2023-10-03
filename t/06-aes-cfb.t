use strict;
use warnings;
use Test::More tests => 7;
use MIME::Base64 qw/encode_base64 decode_base64/;

BEGIN { use_ok('Crypt::OpenSSL::AES') };

# key = substr(sha512_256_hex(rand(1000)), 0, ($ks/4));
my %key = (
          '256' => '73cb25919da0489986fd2fe7b741a396e8c1c04fee92f036bd0db2ea671ed72c',
          '192' => 'adaf02f0bdb7fe3f11a491f69f587ebdc05b649be7dc5283',
          '128' => 'd0ed125796bae73389c28c386e870948',
        );

# iv  = substr(sha512_256_hex(rand(1000)), 0, 32);
my %iv = (
          '128' => '8f64546413aabf98e92b29427aa61ced',
          '192' => 'af9cc72a8bbaef839ecfeb8786e01cdc',
          '256' => '91ddb555ccb98e0ff3f9c68e75450cd7',
        );

# Following data was encrypted with Crypt::Mode::CFB
my %encrypted = (
          '256' => 'Ky+CWT/+P5kDOHqPRQzgkA==',
          '192' => 'OMwFDYJl4dEqPbT4a8p6QA==',
          '128' => 'rNTa7HC2gM8WFCI4UbNWHQ==',
        );

my @keysize = ("128", "192", "256");
foreach my $ks (@keysize) {
    {
        my $coa = Crypt::OpenSSL::AES->new(pack("H*", $key{$ks}),
                                        {
                                        cipher  => "AES-$ks-CFB",
                                        iv      => pack("H*", $iv{$ks}),
                                        });

        my $ciphertext = $coa->encrypt("Hello World. 123");
        ok($ciphertext eq decode_base64($encrypted{$ks}), "Crypt::OpenSSL::AES ($ks) - Created expected ciphertext");

        my $plaintext = $coa->decrypt(decode_base64($encrypted{$ks}));

        ok($plaintext eq "Hello World. 123", "Crypt::Mode::CFB ($ks) - Decrypted with Crypt::OpenSSL::AES");
    }
}

done_testing;
