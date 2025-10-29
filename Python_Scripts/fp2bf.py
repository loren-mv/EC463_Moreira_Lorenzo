import struct

def fp32_to_bfloat16(value, from_hex=False):
    """
    Convert a 32-bit float to bfloat16 (round-to-nearest-even).
    Accepts either a float or a hex string if from_hex=True.
    """
    # If input is hex string, interpret it as raw bits
    if from_hex:
        fp32_int = int(value, 16)
    else:
        # Pack float into IEEE 754 binary32 format
        fp32_int = struct.unpack('>I', struct.pack('>f', value))[0]

    # Extract top 16 bits (truncation base)
    top = (fp32_int >> 16) & 0xFFFF
    lower = fp32_int & 0xFFFF

    # Round to nearest even
    lsb = (top & 1)             # least significant bit of truncated result
    round_bit = (lower >> 15) & 1
    rest = lower & 0x7FFF
    if (round_bit and (rest > 0 or lsb)):
        top += 1
        # Handle exponent overflow (Inf)
        if top == 0x8000:
            top = 0x7F80  # infinity pattern for BF16

    return top


def to_binary16(x):
    """Return a 16-bit binary string."""
    return format(x, '016b')


def test_cases():
    tests = [
        ("3F800000", "+1.0"),
        ("C0000000", "-2.0"),
        ("3F000000", "+0.5"),
        ("42C80000", "+100.0"),
        ("00800000", "Smallest + normal"),
        ("00000000", "+0.0"),
        ("80000000", "-0.0"),
        ("7F800000", "+Inf"),
        ("FF800000", "-Inf"),
        ("7FC00000", "NaN")
    ]

    print("=====================================")
    print("  FP32 -> BF16 Conversion Results")
    print("=====================================")
    for hexval, label in tests:
        bf16 = fp32_to_bfloat16(hexval, from_hex=True)
        print(f"{label:20s} | FP32: {hexval} | BF16: {to_binary16(bf16)} ({bf16:04X})")
    print("=====================================")


if __name__ == "__main__":
    test_cases()
