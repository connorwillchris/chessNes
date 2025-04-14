#!/usr/bin/python3
import PIL
from PIL import Image

images = [
    "assets/rook.png",
    "assets/knight.png",
    "assets/bishop.png",
    "assets/queen.png",
    "assets/king.png"
]

def bitmap_image(path):
    with Image.open(path) as image:
        image_size = image.size[0]
        # image.getpixel()

        for y in range(image_size):
            for x in range(image_size):
                p = image.getpixel((x, y))
                print(f"X:{x} Y:{y} p:{p}".format(x, y, p))

bitmap_image(images[0])