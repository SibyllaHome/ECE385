from PIL import Image

im = Image.open('../assets/Background.jpg')
f = open('../assets/memory_content.txt','w')

# get size
(w , h) = im.size
print(w,h)

im_out = Image.new('RGB', (w, h))
pixels_out = im_out.load()

# convert to rgb
rgb_im = im.convert('RGB')

for y in xrange(0,h):
    for x in xrange(0,w):
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

        f.write(bin(o).lstrip('-0b').zfill(8))
        if (x % 2 == 1): f.write("\n")

im_out.save("../assets/converted.jpg")
f.close()
