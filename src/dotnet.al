dotnet
{
    assembly(BouncyCastle.Crypto)
    {
        type(Org.BouncyCastle.Crypto.Parameters.RsaPrivateCrtKeyParameters; RsaPrivateCrtKeyParameters) { }
        type(Org.BouncyCastle.Crypto.Parameters.RsaKeyParameters; RsaKeyParameters) { }
        type(Org.BouncyCastle.OpenSsl.PemReader; PemReader) { }
        type(Org.BouncyCastle.Crypto.Digests.Sha256Digest; Sha256Digest) { }
        type(Org.BouncyCastle.Crypto.Signers.RsaDigestSigner; RsaDigestSigner) { }
    }
    assembly(mscorlib)
    {
        type(System.IO.TextReader; CustTextReader) { }
        type(System.IO.StringReader; CustStringReader) { }
        type(System.Array; CustArray) { }
        type(System.Text.Encoding; CustTextEncoding) { }
    }

}