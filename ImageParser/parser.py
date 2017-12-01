from PIL import Image

def read_rgb_8_bit(image_name, output_im, output_file, output_hex):
    image = Image.open(image_name)
    (w , h) = image.size
    image_rgb = image.convert('RGB')

    im_out = Image.new('RGB', (w, h))
    pixels_out = im_out.load()

    for y in range(0,h):
        for x in range(0,w):
            (r, g, b) = image_rgb.getpixel((x, y))
            # b_r, b_g, b_b = bin(r).lstrip('-0b').zfill(8), bin(g).lstrip('-0b').zfill(8), bin(b).lstrip('-0b').zfill(8)
            # print (b_r, b_g, b_b)
            # print ""
            r = r & int('11100000',2)
            g = (g & int('11100000',2))
            b = (b & int('11000000',2))

            pixels_out[x,y] = (r,g,b)

            # perform bitshift
            r = r
            g = g >> 3
            b = b >> 6
            o = r + g + b

            h_string = hex(o).lstrip('-0x').zfill(2)
            output_hex.write(h_string)
            if (x % 2 == 0):
                output_file.write("mem_array[" + str((y*w+x)/2) + "] = 16'h" + h_string)
            if (x % 2 == 1):
                output_file.write(h_string + ";\n")

    im_out.save(output_im)

text = open('../assets/memory_content.txt','w')
hexfile = open('../assets/content.hex','w')

read_rgb_8_bit('../assets/640x480/background.jpg','../assets/640x480/converted/background.jpg', text, hexfile)
read_rgb_8_bit('../assets/640x480/fighter1.png','../assets/640x480/converted/fighter1.png', text, hexfile)

text.close()
hexfile.close()
