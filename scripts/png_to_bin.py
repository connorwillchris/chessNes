#!/usr/bin/python3
import PIL
from PIL import Image

ALPHA = (0, 0, 0, 0)

images = [
    "assets/rook.png",
    "assets/knight.png",
    "assets/bishop.png",
    "assets/queen.png",
    "assets/king.png",
    "assets/pawn.png"
]

def bitmap_image(path):
    with Image.open(path) as image:
        image_size = image.size[0]

        for y in range(image_size):
            print(".byte %", end="")

            for x in range(8):
                p = image.getpixel((x, y))

                if p != ALPHA:
                    print("1", end="")
                else:
                    print("0", end="")
            
            print("")

#bitmap_image(images[5])
bitmap_image("assets/selection.png")
