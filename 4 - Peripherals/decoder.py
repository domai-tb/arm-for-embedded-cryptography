#!/usr/bin/python3

def decode(encoded_data):
    width = None
    height = None
    decoded_rgb = list()

    ############## WRITE YOUR CODE BELOW ##############

    width = int.from_bytes(bytes(encoded_data[0:3]), byteorder="little")
    height = int.from_bytes(bytes(encoded_data[4:7]), byteorder="little")

    # reverse swap := unknown_function_1
    for i in range(8, len(encoded_data) - 1, 2):
        encoded_data[i], encoded_data[i+1] = encoded_data[i+1], encoded_data[i]

    # derandomnization
    for i in range(8, len(encoded_data) - 1, 1):
        if ((i > 8) and ( i % 4) == 0):
            continue
        decoded_rgb.append(encoded_data[i])

    # reverse unknown_function_2 ...
    temp = 171
    for i in range(0, len(decoded_rgb) - 1, 1):
        if ( ( (decoded_rgb[i] ^ temp) & 7) == 3):
            temp_byte = decoded_rgb[i]
            decoded_rgb[i] = decoded_rgb[i] ^ temp
            temp = temp_byte
        
    ############## WRITE YOUR CODE ABOVE ##############

    return width, height, decoded_rgb


###########################################
###########################################
###########################################

import image_data

print("decoding image data...")

w,h,rgb = decode(list(image_data.bytes))

import sys

if not w:
    print("no width specified")
    sys.exit(1)

if not h:
    print("no height specified")
    sys.exit(1)

if (len(rgb) % 3) != 0:
    print("rgb data length is not a multiple of 3")
    sys.exit(1)

with open("decoded.ppm", "wt") as file:
    # write output to ppm format (https://en.wikipedia.org/wiki/Netpbm_format#PPM_example)
    file.write("P3\n{} {}\n255\n".format(w, h))
    for i in range(0, len(rgb), 3):
        file.write(" ".join(str(x) for x in rgb[i:i+3])+"\n")


def djb_hash(data):
    digest = 5381
    for i, x in enumerate(data):
        digest = (((digest << 5) + digest) + x) & 0xFFFFFFFF
    return digest

if djb_hash([w,h]+rgb) != 0xc434b9d0:
    print("error: checksum of your data did not match the correct checksum, the image has wrong pixels")
else:
    print("success: checksum of your data matches the correct checksum")
