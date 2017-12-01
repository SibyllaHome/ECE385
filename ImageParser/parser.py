from PIL import Image

im = Image.open('../assets/background.jpg')
f = open('../assets/memory_content.txt','w')
hexfile = open('../assets/content.hex','w')

# get size
(w , h) = im.size
print(w,h)

im_out = Image.new('RGB', (w, h))
pixels_out = im_out.load()

# convert to rgb
rgb_im = im.convert('RGB')

for y in range(0,h):
    for x in range(0,w):
        (r, g, b) = rgb_im.getpixel((x, y))
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
        hexfile.write(h_string)
        if (x % 2 == 0):
            f.write("mem_array[" + str((y*w+x)/2) + "] = 16'h" + h_string)
        if (x % 2 == 1):
            f.write(h_string + ";\n")

im_out.save("../assets/converted.jpg")

im_p1 = Image.open('../assets/spritesheet_p1.png')
im_p1 = im_p1.convert('RGB')

for y in range(0,h):
    for x in range(0,w):
        (r, g, b) = im_p1.getpixel((x, y))
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
        hexfile.write(h_string)
        if (x % 2 == 0):
            f.write("mem_array[" + str(((y*w+x)/2)+38400) + "] = 16'h" + h_string)
        if (x % 2 == 1):
            f.write(h_string + ";\n")
            
im_out.save("../assets/converted_sprite.jpg")
f.close()
hexfile.close()
