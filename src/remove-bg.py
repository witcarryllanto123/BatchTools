from rembg import remove
from PIL import Image
import io
import os

def remove_bg(input_path, output_path, threshold=200):
    with open(input_path, 'rb') as input_file:
        input_data = input_file.read()

    output_data = remove(input_data)  # Let rembg handle ONNX automatically

    output_image = Image.open(io.BytesIO(output_data)).convert("RGBA")
    pixels = output_image.load()

    for i in range(output_image.width):
        for j in range(output_image.height):
            r, g, b, a = pixels[i, j]
            if a < threshold:
                pixels[i, j] = (r, g, b, 0)  # Make transparent

    output_image.save(output_path, format="PNG")

# Ensure the directories exist
input_dir = os.path.join(os.getcwd(), "rembg-input")
output_dir = os.path.join(os.getcwd(), "rembg-output")

os.makedirs(input_dir, exist_ok=True)
os.makedirs(output_dir, exist_ok=True)

# File paths
input_image = os.path.join(input_dir, "input_image.png")
output_image = os.path.join(output_dir, "output_image.png")

# Run background removal
remove_bg(input_image, output_image, threshold=200)